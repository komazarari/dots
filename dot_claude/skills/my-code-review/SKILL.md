---
name: my-code-review
description: Personal code review skill — reviews diffs or files with a structured checklist covering correctness, security, maintainability, and performance.
user_invocable: true
argument: Optional. A file path, branch name, or PR URL to review. If omitted, reviews staged/unstaged changes.
---

# My Code Review

You are performing a code review on behalf of the user. Follow the review process below thoroughly.

## 1. Determine the review target

- If an argument is provided:
  - **File path** → review that file in its current state.
  - **Branch name** → review `git diff main...<branch>` (adjust base branch as needed).
  - **PR URL** → fetch the PR diff with `gh pr diff <number>`.
- If no argument is provided → review `git diff` (unstaged) and `git diff --cached` (staged).

Read the full diff before making any comments.

## 2. Review checklist

Evaluate the changes against each of the following categories. Only raise points that are **actionable and relevant** to the actual diff — do not nitpick or comment on unchanged code.

### Correctness
- Does the logic match the stated intent (commit message, PR description, ticket)?
- Are edge cases handled (nil/null, empty collections, boundary values, concurrency)?
- Are error paths handled correctly — no swallowed errors, no misleading messages?
- Do type conversions, casts, or serialization round-trip safely?

### Security
- Is user input validated and sanitized at the boundary?
- Are there risks of injection (SQL, command, XSS, template injection)?
- Are secrets, tokens, or credentials kept out of code and logs?
- Are permissions / authorization checks in place where needed?

### Maintainability & Readability
- Is the naming clear and consistent with the surrounding codebase?
- Is the abstraction level appropriate — no premature generalization, no unnecessary indirection?
- Are new dependencies justified and well-vetted?
- Is dead code, commented-out code, or debug artifacts left behind?

### Performance
- Are there obvious O(n²) or worse patterns where a better approach exists?
- Are expensive operations (I/O, network, heavy computation) inside tight loops?
- Are large allocations, unbounded caches, or missing pagination introduced?

### Testing
- Are new behaviors covered by tests?
- Do tests assert the right things (not just "no error")?
- Are test names and structure clear about what scenario they cover?

## 3. Output format

Present findings grouped by file, then by severity:

- **Must fix** — bugs, security issues, data-loss risks.
- **Should fix** — maintainability or correctness concerns likely to cause problems.
- **Suggestion** — style, naming, minor improvements — take or leave.

For each finding, include:
1. **File and line reference** (e.g., `src/handler.go:42`)
2. **What** — one-sentence description of the issue.
3. **Why** — the impact or risk if left as-is.
4. **Suggested fix** — a concrete code snippet or action when possible.

If the changes look good, say so briefly — do not manufacture issues.

## 4. Summary

End with a short summary:
- Overall assessment (approve / request changes / comment only).
- The single most important thing to address, if any.
