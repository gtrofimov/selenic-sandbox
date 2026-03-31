---
name: convert-to-parasoft-recording
description: 'Execute a UI flow using Selenium MCP and save the result as a Parasoft Selenic recording JSON file. Use when users say: convert to Parasoft recording, record this flow as a Parasoft recording, capture as a Parasoft recording, save as a Parasoft recording, or as a Parasoft recording.'
argument-hint: '[required] description of the flow to execute, or name of existing Selenium MCP flow to convert'
user-invocable: true
---

# Convert to Parasoft Recording

## What This Skill Produces
- Executes a described UI flow live using Selenium MCP.
- Translates each captured interaction into a Parasoft Selenic recording event.
- Writes a valid `localhost-<timestamp>.json` recording file in the workspace root.
- Validates the JSON before completing.

## When To Use
- User describes a UI flow and wants it captured as a Parasoft Selenic test recording.
- User says "convert to Parasoft recording", "as a Parasoft recording", or "capture as a Parasoft recording".
- A Selenium MCP session has just been completed and the user wants to persist it as a recording.

## Prerequisites
- The target web application is running and reachable.
- Selenium MCP tools are available (`mcp_selenium_*`).

---

## Procedure

### Step 1 — Start the browser
Always start Chrome with the password store argument per project rules:
```json
{
  "browser": "chrome",
  "options": {
    "arguments": ["--password-store=basic"]
  }
}
```

Enforcement rules for Step 1:
- Treat this flag as mandatory with no exceptions.
- Before sending the `mcp_selenium_start_browser` call, verify `options.arguments` contains `--password-store=basic`.
- If other Chrome flags are needed, keep `--password-store=basic` in the same `options.arguments` array.
- If Chrome was launched without this flag, close the browser session and relaunch with the correct payload before continuing.

### Step 2 — Execute the described flow
- Navigate to the starting URL.
- Perform each step of the described flow using Selenium MCP tools.
- After each interaction, record the following for that step:
  - `userAction` (see mapping below)
  - `locator` + `term` (the strategy and value used to find the element)
  - `data` (value typed, option selected, or visible text of the clicked element)
  - `url` (current page URL at time of interaction)
  - `title` (page `<title>`)
  - `identifiers.tagName`, `identifiers.type`, `identifiers.role`, `identifiers.label`

### Step 3 — Capture a verification step (assertion)
- After the final meaningful action, capture the resulting state as a verification event.
- Read the element that reflects the outcome (e.g., a status label).
- Record as `eventType: 14` (see schema below).

### Step 4 — Build the JSON
Construct the recording using the schema defined in the **JSON Schema** section.

### Step 5 — Name and write the file
- Filename format: `localhost-<YYYY-MM-DD-HH-mm-ss>.json`
- Use the current date/time for the timestamp.
- Write the file to the workspace root.

### Step 6 — Validate
Run: `python3 -m json.tool <filename>.json > /dev/null && echo "Valid JSON"`

---

## JSON Schema

### Top-level structure
```json
{
  "testName": "localhost-<YYYY-MM-DD-HH-mm-ss>",
  "description": "<short description of what the flow does>",
  "timestamp": "<JS-style timestamp, e.g. Mon Mar 31 2026 12:00:00 GMT-0700 (Pacific Daylight Time)>",
  "version": "2.2025.1204.2233",
  "webUIEvents": [ ...events... ],
  "requirements": {
    "type": "@req",
    "id": "<test ID, e.g. PGT-123 or a descriptive slug>",
    "url": ""
  }
}
```

### Action event (eventType 4)
Use `eventType: 4` for every user interaction (type, click, select, etc.).
```json
{
  "eventType": 4,
  "params": {
    "userAction": "<see userAction mapping>",
    "locator": "<locator strategy>",
    "term": "<locator value>",
    "data": "<value typed / option label / visible text>",
    "url": "<current page URL>",
    "title": "<page title>",
    "identifiers": {
      "tagName": "<uppercase tag, e.g. INPUT, BUTTON, SELECT, A>",
      "type": "<HTML type attribute, or null>",
      "role": "<ARIA role, or null>",
      "label": "<associated label text, or null>"
    },
    "windowIndex": 3,
    "windowName": ""
  }
}
```

### Assertion event (eventType 14)
Use `eventType: 14` for the final verification step.
```json
{
  "eventType": 14,
  "params": {
    "locator": "<locator strategy>",
    "term": "<locator value for the element being asserted>",
    "data": "<expected text content>",
    "url": "<current page URL>",
    "title": "<page title>",
    "tagName": "<uppercase tag>",
    "identifiers": {
      "tagName": "<uppercase tag>",
      "role": "<ARIA role, or null>",
      "label": "<associated label, or null>"
    },
    "windowIndex": 3,
    "windowName": ""
  }
}
```

---

## userAction Mapping

| Interaction | `userAction` value | Notes |
|---|---|---|
| Type into a text field | `type` | Use for plain text inputs |
| Type into a password field | `type_password` | Use when `input[type=password]` |
| Click a button, link, or element | `click` | Set `data` to visible text or empty string |
| Select a dropdown option | `select` | Set `data` to `label=<option text>` |

## Locator Strategy Values
Use these exact strings for the `locator` field:

| Strategy | `locator` value |
|---|---|
| By ID | `id` |
| By name attribute | `name` |
| By XPath | `xpath` |
| By CSS selector | `css selector` |
| By class name | `class name` |

---

## Decision Points

- **Flow not described clearly enough:**
  Ask the user for the starting URL and each step before proceeding.

- **Element found by multiple strategies:**
  Prefer `id` > `name` > `css selector` > `xpath`.

- **No obvious assertion target:**
  Ask the user what outcome should be verified, or use the page title / a status element.

- **Test ID / requirements ID unknown:**
  Use a descriptive slug (e.g. `FLOW-APPROVER`) and note it should be updated to match the real test management ID.

- **File already exists at the same timestamp:**
  Append a short suffix (e.g. `-2`) to avoid overwriting.

---

## Completion Checks
- JSON file exists in workspace root.
- `python3 -m json.tool` exits 0.
- `webUIEvents` contains at least one `eventType: 4` and one `eventType: 14`.
- `version` is exactly `"2.2025.1204.2233"`.
- `requirements.id` is set to a non-empty value.
