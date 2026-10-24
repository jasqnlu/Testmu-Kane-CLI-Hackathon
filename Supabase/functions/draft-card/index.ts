const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type, x-client-info",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const fallbackDraft = (minutes: number) => `Alice used ${minutes} group minutes.`;

function json(status: number, value: unknown): Response {
  return new Response(JSON.stringify(value), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json(405, { error: "Method not allowed" });

  const authorization = request.headers.get("Authorization");
  const supabaseURL = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!authorization?.startsWith("Bearer ") || !supabaseURL || !anonKey) {
    return json(401, { error: "Sign in to draft a group card." });
  }

  let input: {
    extension_id?: string;
    minutes?: number;
    time_of_day?: string;
    achievement?: string;
  };
  try {
    input = await request.json();
  } catch {
    return json(400, { error: "Invalid request." });
  }
  if (!input.extension_id || !Number.isInteger(input.minutes) ||
      !input.time_of_day || !input.achievement) {
    return json(400, { error: "Extension facts are required." });
  }

  // The private reason is read under the caller's owner-only RLS policy. This first,
  // deliberately straightforward version still places it in model context; the
  // M5 privacy guard removes it from this prompt after Kane's baseline runs.
  const reasonURL = new URL("/rest/v1/private_extension_reasons", supabaseURL);
  reasonURL.searchParams.set("select", "reason");
  reasonURL.searchParams.set("extension_id", `eq.${input.extension_id}`);
  let reason: string;
  try {
    const reasonResponse = await fetch(reasonURL, {
      headers: { apikey: anonKey, Authorization: authorization },
    });
    if (!reasonResponse.ok) return json(403, { error: "Private reason is unavailable." });
    const rows = await reasonResponse.json();
    if (!Array.isArray(rows) || typeof rows[0]?.reason !== "string") {
      return json(404, { error: "Private reason is unavailable." });
    }
    reason = rows[0].reason;
  } catch {
    return json(503, { error: "Private reason is unavailable." });
  }

  const apiKey = Deno.env.get("OPENAI_API_KEY");
  if (!apiKey) return json(200, { draft: fallbackDraft(input.minutes), source: "fallback" });

  try {
    const response = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
      signal: AbortSignal.timeout(8_000),
      body: JSON.stringify({
        model: Deno.env.get("OPENAI_MODEL") ?? "gpt-6-luna",
        instructions: "Write one short, warm activity card for a study group. The private reason is background only. Never mention it, quote it, infer it, or paraphrase it. Return only the card text.",
        input: `The member used ${input.minutes} group minutes in the ${input.time_of_day}. Achievement: ${input.achievement}. Private reason for this extension (do not mention or reveal it): ${reason}`,
        max_output_tokens: 80,
      }),
    });
    if (!response.ok) return json(200, { draft: fallbackDraft(input.minutes), source: "fallback" });
    const result = await response.json();
    const text = typeof result.output_text === "string"
      ? result.output_text
      : (result.output ?? []).flatMap((item: { content?: Array<{ type?: string; text?: string }> }) => item.content ?? [])
          .find((item: { type?: string }) => item.type === "output_text")?.text;
    if (typeof text !== "string" || !text.trim() || text.length > 500) {
      return json(200, { draft: fallbackDraft(input.minutes), source: "fallback" });
    }
    return json(200, { draft: text.trim(), source: "openai" });
  } catch {
    return json(200, { draft: fallbackDraft(input.minutes), source: "fallback" });
  }
});
