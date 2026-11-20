commits made by an agent must include an `Assisted-by` tag in the following format:

```
Assisted-by: AGENT_NAME:MODEL_VERSION
```

where:

    AGENT_NAME is the name of the AI tool or framework
    MODEL_VERSION is the specific model version used

examples:

```
Assisted-by: Claude:claude-3-opus
Assisted-by: Codex:gpt-5.6-sol
```

agents MUST NOT add `Co-authored-by` or `Signed-off-by` tags.

agents MUST NOT commit on my behalf unless asked.

## Attribution on GitHub comments

Anything an agent posts to GitHub under my account (PR and issue comments, review comments,
review summaries, replies to bots) uses this schema:

    > [!NOTE]\n> 🤖 **<model> <verb> on behalf of Sheheryar**\n\n<body>[\n\n---<edits>]

- `<model>`: human-readable name and version, e.g. `Claude Opus 5.5`
- `<verb>`: `responding` when replying in an existing thread, otherwise `writing`
- A bot command (e.g. `@coderabbitai review`) goes in `<body>` like any other text
- `<edits>`: one `\n🤖 *Updated by <model>: <one-line summary>*` per agent edit, oldest first.
  The first edit adds the `---` separator. Later edits append a line below it.
