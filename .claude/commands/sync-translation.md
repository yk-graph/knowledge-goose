# /sync-translation — Sync Documentation Translations

Keeps the Japanese translations under `docs/ja/` in sync with the English source files under `docs/`.

## Steps

1. List all `.md` files directly under `docs/` (English primary files)
2. For each file, check whether `docs/ja/<filename>` exists
3. Compare structure between the two versions:
   - Same heading hierarchy (H1, H2, H3 count and order)
   - Same tables (column count and row order)
   - Code blocks are reproduced verbatim (do NOT translate code)
4. Update `docs/ja/<filename>` to reflect any changes in the English version:
   - Translate new sections naturally (not word-for-word)
   - Remove sections that were deleted from the English version
5. Verify the language switcher is present at the top of both files

## Language Switcher Format

English file (`docs/<filename>`):

```
> Available in: English | [日本語](./ja/<filename>)
```

Japanese file (`docs/ja/<filename>`):

```
> Available in: [English](../<filename>) | 日本語
```

## Rules

- **Code blocks**: reproduce exactly as-is — do not translate identifiers, comments inside code, or commands
- **Technical terms**: keep in English (e.g. "Server Action", "migration", "schema", "MCP")
- **Tone**: match the tone of the English source (technical + concise)
- **Do not ask for confirmation** — run and report which files were updated

## Output

After completing, report:

- Files updated: list
- Files already in sync: list
- Files missing a Japanese version (created from scratch): list
