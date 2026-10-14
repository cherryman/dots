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
