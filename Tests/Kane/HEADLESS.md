# Kane simulator transport on Xcode 27

The installed Xcode 27 uses DeviceHub and has no `Contents/Developer/Applications/Simulator.app`. Kane's bundled Appium simulator driver attempts to open that older UI path by default, so the initial M0 run exited 2 before any test steps. This is an environment failure.

`Scripts/with-kane-simulator.sh` starts the installed, unmodified Kane Appium bundle with the supported `appium:isHeadless=true` capability. It supplies the server through Kane's `KANE_APPIUM_URL` override. The simulator still runs locally; Kane still controls all UI actions and collects evidence. Headless mode skips the separate simulator display window.

Run a standalone Kane objective with this wrapper, copying device and OS exactly from `kane-cli devices list --target simulator --agent`:

```bash
Scripts/with-kane-simulator.sh env KANE_CLI_USER_AGENT=codex kane-cli run \
  "Open Weave and verify the sign-in screen is visible" \
  --target simulator --app ./builds/Weave.zip \
  --device-name "iPhone 17 Pro" --os-version 26.5 --agent
```

`Scripts/verify.sh smoke` already uses the wrapper. For another free port, set `WEAVE_APPIUM_PORT=4726` before the wrapper. Its startup wait is bounded; logs remain in a temporary `weave-appium.*` directory. The wrapper returns the command's exit code and stops only the server it started.

If the selected port is occupied, the wrapper refuses to reuse or change that server. To intentionally use an existing Appium server already configured for headless simulator sessions, set `KANE_APPIUM_URL=http://127.0.0.1:4725`. A supplied URL bypasses server management entirely; the caller owns that server's configuration and lifetime.

The wrapper checks only Appium's `/status` endpoint. It does not create Appium sessions or perform UI automation. No Xcode files or managed dependencies are patched.

References: [Appium simulator capabilities](https://appium.github.io/appium-xcuitest-driver/10.43/reference/capabilities/) documents `appium:isHeadless`; [Appium server arguments](https://appium.io/docs/en/latest/reference/cli/server/) documents `--default-capabilities`. Kane CLI's installed transport code reads the `KANE_APPIUM_URL` override before starting its managed server.
