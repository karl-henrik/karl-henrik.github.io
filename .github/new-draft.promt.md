# LLM Prompt: Auto-draft blog post in my voice (karl-henrik.github.io)

Your job:
- Create a **draft** Jekyll post in `_posts/`.
- Use my voice, tone, and formatting conventions learned from prior posts in this repo.
- Infer and align categories/tags style/ordering/letter-case based on existing posts. If unsure, pick the closest match to past usage.
- Keep structure, pacing, and phrasing consistent with my historical writing.

Inputs I will provide (replace placeholders):
- title: "{{title}}"
- date: "{{date}}" (YYYY-MM-DD or ISO8601)
- categories: [{{categories}}]
- tags: [{{tags}}]
- writing_prompt: "{{what-to-write-about (short brief or bullet list)}}"

Required front matter:
```
---
title: "{{title}}"
date: {{date}}
categories: [{{categories}}]
tags: [{{tags}}]
draft: true
---
```

Output requirements:
- Create file at `_posts/YYYY-MM-DD-{{slugified-title}}.md` (slug: lowercase, hyphens).
- Begin with the YAML front matter above, then the body.
- Body: match my voice; open with a concise intro paragraph; use headings; keep flow similar to my past posts. If helpful, weave in callbacks to prior themes you detect in the repo.
- If mentioning images, note missing assets explicitly (do not invent paths).
- Keep Markdown clean and compatible with Jekyll; prefer inline links; keep code fences only when relevant.
- Return **only** the final Markdown file content, nothing else.

Style & consistency heuristics:
- Match sentence rhythm, typical phrase choices, and level of informality/formality from previous posts.
- Mirror typical post length and paragraph cadence unless the writing_prompt implies otherwise.
- Keep category/tag casing and ordering consistent with past patterns; avoid introducing near-duplicates.
- If the writing_prompt is sparse, expand with reasonable, on-brand detail; avoid speculative claims.

Example values (for reference only, not to hardcode):
title: "Two Talks, Countless Conversations: My KCDC 2025 Experience"
date: 2025-08-20
categories: [Public Speaking, Conferences]
tags: [speaking, community, KCDC, Career, Developers, Legacy Code]
writing_prompt: "Summarize my KCDC 2025 talks, hallway conversations, lessons on legacy code modernization, and community takeaways."
