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

const privateReasonFamilies: Record<string, string[]> = {
  chemistry: ["chemistry", "chemical", "science", "lab", "laboratory"],
  test: ["test", "exam", "quiz", "assessment"],
  anxiety: ["anxiety", "anxious", "stress", "stressed", "worry", "worried", "nervous"],
};

function words(value: string): Set<string> {
  return new Set(value.toLowerCase().match(/[a-z0-9]+/g) ?? []);
}

function normalized(value: string): string {
  return (value.toLowerCase().match(/[a-z0-9]+/g) ?? []).join(" ");
}

function disclosesPrivateReason(candidate: string, reason: string): boolean {
  const draftWords = words(candidate);
  const reasonWords = words(reason);
  const normalizedDraft = normalized(candidate);
  const normalizedReason = normalized(reason);
  if (normalizedReason && normalizedDraft.includes(normalizedReason)) return true;

  const highSignal = [...reasonWords].filter((word) => word.length >= 5);
  if (highSignal.some((word) => draftWords.has(word))) return true;

  const matchingFamilies = Object.entries(privateReasonFamilies)
    .filter(([term]) => reasonWords.has(term));
  const familyMatches = matchingFamilies.filter(([, variants]) => variants.some((word) => draftWords.has(word)));
  return matchingFamilies.length >= 2 && familyMatches.length >= 2;
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

  // Read the reason under the caller's owner-only RLS policy for a server-side
  // response check. The reason is never sent to the model.
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

  const deadline = Date.now() + 8_000;
  for (let attempt = 0; attempt < 2; attempt += 1) {
    const remaining = deadline - Date.now();
    if (remaining <= 0) break;
    try {
      const response = await fetch("https://api.openai.com/v1/responses", {
        method: "POST",
        headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
        signal: AbortSignal.timeout(remaining),
        body: JSON.stringify({
          model: Deno.env.get("OPENAI_MODEL") ?? "gpt-6-luna",
          instructions: attempt === 0
            ? "Write one short, warm activity card for a study group using only the supplied group activity facts. Return only the card text."
            : "Write one short, warm, generic group activity card. Do not mention personal challenges or reasons. Return only the card text.",
          input: `The member used ${input.minutes} group minutes in the ${input.time_of_day}. Achievement: ${input.achievement}.`,
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
      const candidate = text.trim();
      if (disclosesPrivateReason(candidate, reason)) continue;
      return json(200, { draft: candidate, source: "openai" });
    } catch {
      return json(200, { draft: fallbackDraft(input.minutes), source: "fallback" });
    }
  }
  return json(200, { draft: fallbackDraft(input.minutes), source: "fallback" });
});
