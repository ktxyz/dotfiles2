---
description: Review the current branch's diff (staged + commit range)
argument-hint: "[focus]"
---
Review the changes in ${1:-the current working tree}.

Steps:
1. Run `git diff HEAD` (and `git log --oneline main..HEAD` for context).
2. Report findings as: **Blocking** / **Suggested** / **Nit** — max 20 lines, no praise.
3. Focus on: correctness, security (secrets, injection), API breakage, and unnecessary churn.
4. Do not restate the diff; assume I read it. Cite `file:line` for each finding.
