# Project Guidelines

## Selenium MCP Browser Startup
When using Selenium MCP to open a browser, always start Chrome with the password store argument below.

This is mandatory with no exceptions: do not call `mcp_selenium_start_browser` for Chrome unless `--password-store=basic` is present in `options.arguments`.

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

Before each Chrome browser start, verify the outgoing payload still includes `--password-store=basic`.
If a Chrome browser was started without this flag, close that session and start a new one with the correct payload.

## Selenium Test Authoring
Always use the Page Object Model (POM) pattern when creating or modifying Selenium tests.

- Every distinct page or component must have a dedicated page object class under `src/test/java/com/parasoft/demo/pages/`
- Page object classes must extend `BasePage` and use `PageFactory.initElements` in their constructor
- Expose page interactions as public methods; keep all `@FindBy` locators private to the page object
- Test classes must not contain raw `WebDriver`, `By`, `WebElement`, or `WebDriverWait` calls — delegate to page object methods only

## Parasoft Recording Skill
When the user says **"convert to Parasoft recording"**, **"as a Parasoft recording"**, **"capture as a Parasoft recording"**, or **"save as a Parasoft recording"**, invoke the `convert-to-parasoft-recording` skill located at `.github/skills/convert-to-parasoft-recording/SKILL.md`.

Read that skill file before proceeding.
