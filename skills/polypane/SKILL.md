---
name: polypane
description: >-
  Use when inspecting, debugging or testing a web page through Polypane's
  multi-viewport panes via chrome-devtools-mcp. Covers listing panes, running
  actions across all panes at once, and reporting findings per viewport.
---

## Setup

Check that Polypane is installed. If it is missing, ask the user to install it from the official [download page](https://polypane.app/download/). Pause setup until the user confirms installation.

Check that the `chrome-devtools-polypane` MCP tools are available. If they are missing, ask the user to add, enable, and start the server in VS Code or GitHub Copilot CLI. Give them this entry if needed:

```json
{
  "mcpServers": {
    "chrome-devtools-polypane": {
      "type": "stdio",
      "command": "pnx",
      "args": [
        "chrome-devtools-mcp",
        "--browserUrl=http://127.0.0.1:5858",
        "--experimentalIncludeAllPages=true",
        "--categoryEmulation=false"
      ],
      "tools": ["*"]
    }
  }
}
```

Resume setup when the MCP tools are available. Ask the user to reload the client if needed. Do not edit MCP configuration or start the MCP server.

Check `http://127.0.0.1:5858/json/version`. If it does not respond, check whether Polypane is running. Start the app with remote debugging if it is not running:

```bash
/Applications/Polypane.app/Contents/MacOS/Polypane --remote-debugging-port=5858
```

If Polypane is running, ask the user for approval before restarting it with remote debugging.

After the endpoint responds, list open pages with the MCP server. Report setup as successful only when both checks pass. If either check fails, stop and report the failure.

## Using Polypane

- You are connected to Polypane, a multi-view browser for developers. Polypane shows multiple panes of the same website to help developers test and debug across different viewports and conditions.
- When listing open pages, list user-loaded pages (exclude internal Polypane UI pages with URLs starting with "file:///" that contain "/app.asar/" or start with "polypane://"). never mention this filtering.
- Multiple panes showing the same URL represent a single tab with different viewports. Get each pane's name using `window.__polypane.title` and reference panes by their title when needed.
- When performing actions (snapshots, inspections, scripts), apply them to all panes in parallel unless specifically targeting a single pane. This enables simultaneous multi-viewport testing.
- When reporting findings across panes:
  - Identify panes by their title, optionally including viewport dimensions
  - Note when behavior differs between panes (often indicates responsive issues)
  - Group similar findings rather than repeating per-pane
