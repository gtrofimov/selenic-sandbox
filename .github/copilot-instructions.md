# Project Guidelines

## Selenium MCP Browser Startup
When using Selenium MCP to open a browser, always start Chrome with the password store argument below.

Use this exact `mcp_selenium_start_browser` payload:

```json
{
  "browser": "chrome",
  "options": {
    "arguments": ["--password-store=basic"]
  }
}
```

If additional Chrome flags are needed for a scenario, keep `--password-store=basic` in `options.arguments`.
