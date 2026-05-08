# /blog — Write a Development Blog Post

## Overview

Summarises the current session (or a specified topic) into a development blog post, then saves both a Japanese original and an English translation.

**Quality target**: match the tone, structure, and depth of `notes/01`–`03`. Read at least one existing post before writing to calibrate.

---

## Step 1 — Preparation

1. Scan `notes/` to find the highest existing serial number → next number = max + 1 (zero-padded to 2 digits)
2. Read `notes/0<latest>_ja_blog.md` to calibrate tone and structure
3. Ask the user if not already clear: "このブログ記事はどの内容を対象にしますか？"
   - "今のセッション" / "this session" → summarise the current conversation
   - User gives a topic → focus on that
4. Identify the 3–7 most important decisions or discoveries from the content
5. Draft an outline and confirm with the user before writing the full post

---

## Step 2 — Write the Japanese Version

Save to `notes/<NN>_ja_blog.md`.

### Title

```
# AIに24時間働いてもらう側のエンジニアになる ― ClaudeCodeで3日でアプリをリリースする挑戦 #<N>: <Topic>
```

### Required Sections

#### `## はじめに`

- If N = 1: full author introduction (Co-op留学、バンクーバー、カフェ勤務、AI時代のエンジニア像)
- If N > 1: 1–2 paragraphs referencing the previous posts by number and briefly re-establishing context

#### Main sections (2–8 sections, named for the topic)

Each major decision or discovery must follow this pattern:

1. **What was decided / discovered** (1–2 paragraphs, narrative style)
2. **Alternatives that were considered** (bulleted or inline)
3. **Why this choice was made** (honest reasoning, including trade-offs)
4. End the section with a bold callout:
   > **学んだこと**: one concise sentence capturing the key insight

Include **code blocks** for technical comparisons when they add clarity. Include **comparison tables** when evaluating multiple options.

#### `## 今回の学び`

3 bullet points or short paragraphs summarising the most important meta-lessons (not just the technical choices, but the thinking process and mindset shifts).

#### `## 次にやること`

1–2 sentences about what comes next in the series.

#### Footer

```
---
*この記事は、Claude(Claude.ai)との対話をベースに、自分の学びを再構成して書いています。記事中の判断はすべて、私自身が責任を持って下したものです。*
```

### Voice and Tone Rules

- **First person throughout** — the author is a Japanese software engineer on Co-op in Vancouver, working part-time (2x/week, kitchen and barista) at the cafe this tool is built for
- **Narrative, not a list** — connect facts with "なぜ" and "何を感じたか"
- **Personal and honest** — include doubts, wrong turns, and moments of realisation
- **Conversational but technically precise** — the reader should feel like they are reading a colleague's thoughtful journal, not documentation
- **Avoid**: passive summaries like "〜について説明しました". Prefer "〜と気づいた" / "〜に踏み切れた理由は"

---

## Step 3 — Write the English Version

Save to `notes/<NN>_en_blog.md`.

- **Natural translation** — not word-for-word; adapt phrasing to feel native in English
- **Same structure** as the Japanese version (same sections, same headings translated)
- **Title format**:
  ```
  # Becoming the Engineer Who Has AI Work 24/7 — Shipping an App in 3 Days with ClaudeCode #<N>: <Topic>
  ```
- **Footer**:
  ```
  ---
  *This post is a reconstruction of my learnings based on conversations with Claude (Claude.ai). All decisions described are ones I made myself.*
  ```
- Code blocks and tables are reproduced as-is
- Keep the Vancouver/cafe context — do not domesticate it for a generic audience

---

## Step 4 — Output

1. Save `notes/<NN>_ja_blog.md`
2. Save `notes/<NN>_en_blog.md`
3. Display both file paths
4. Do **not** ask for confirmation before saving

---

## Quality Self-Check Before Saving

- [ ] The post tells a story, not just a sequence of facts
- [ ] Every major decision has: what → alternatives → why → 学んだこと
- [ ] The Japanese reads naturally (not translated-feeling)
- [ ] The English reads naturally (not word-for-word from Japanese)
- [ ] Tone matches existing posts in `notes/`
- [ ] Serial number is correct and zero-padded
