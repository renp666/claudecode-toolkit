---
name: code-simplification
description: Simplifies code for clarity. Use when refactoring code for clarity without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be.
---
# Code Simplification

Source: https://github.com/addyosmani/agent-skills (⭐22.8K)

## Overview

Simplify code by reducing complexity while preserving exact behavior. The goal is not fewer lines — it's code that is easier to read, understand, modify, and debug.

## When to Use

- After a feature is working and tests pass, but the implementation feels heavier than it needs to be
- During code review when readability or complexity issues are flagged
- When you encounter deeply nested logic, long functions, or unclear names
- When consolidating related logic scattered across files

**When NOT to use:**
- Code is already clean and readable — don't simplify for the sake of it
- You don't understand what the code does yet — comprehend before you simplify
- The code is performance-critical and the "simpler" version would be measurably slower

## The Five Principles

### 1. Preserve Behavior Exactly

Don't change what the code does — only how it expresses it. All inputs, outputs, side effects, error behavior, and edge cases must remain identical.

### 2. Follow Project Conventions

Simplification means making code more consistent with the codebase, not imposing external preferences. Match the project's style for import ordering, function declaration style, naming conventions, error handling patterns, and type annotation depth.

### 3. Prefer Clarity Over Cleverness

Explicit code is better than compact code when the compact version requires a mental pause to parse.

### 4. Maintain Balance

Simplification has a failure mode: over-simplification. Watch for:
- **Inlining too aggressively** — removing a helper that gave a concept a name
- **Combining unrelated logic** — two simple functions merged into one complex function
- **Removing "unnecessary" abstraction** — some abstractions exist for extensibility or testability

### 5. Scope to What Changed

Default to simplifying recently modified code. Avoid drive-by refactors of unrelated code unless explicitly asked to broaden scope.

## Simplification Process

### Step 1: Understand Before Touching (Chesterton's Fence)

Before changing or removing anything, understand why it exists.

```
BEFORE SIMPLIFYING, ANSWER:
- What is this code's responsibility?
- What calls it? What does it call?
- What are the edge cases and error paths?
- Are there tests that define the expected behavior?
- Why might it have been written this way?
```

### Step 2: Identify Simplification Opportunities

**Structural complexity:**

| Pattern | Signal | Simplification |
|---------|--------|----------------|
| Deep nesting (3+ levels) | Hard to follow control flow | Extract conditions into guard clauses or helper functions |
| Long functions (50+ lines) | Multiple responsibilities | Split into focused functions with descriptive names |
| Boolean parameter flags | `doThing(true, false, true)` | Replace with options objects or separate functions |
| Repeated conditionals | Same `if` check in multiple places | Extract to a well-named predicate function |

**Naming and readability:**

| Pattern | Signal | Simplification |
|---------|--------|----------------|
| Generic names | `data`, `result`, `temp` | Rename to describe content |
| Comments explaining "what" | `// increment counter` above `count++` | Delete — the code is clear enough |
| Comments explaining "why" | `// Retry because the API is flaky` | Keep — they carry intent the code can't express |

**Redundancy:**

| Pattern | Signal | Simplification |
|---------|--------|----------------|
| Duplicated logic | Same 5+ lines in multiple places | Extract to a shared function |
| Dead code | Unreachable branches, unused variables | Remove |
| Unnecessary abstractions | Wrapper that adds no value | Inline |

### Step 3: Apply Changes Incrementally

Make one simplification at a time. Run tests after each change.

**The Rule of 500:** If a refactoring would touch more than 500 lines, invest in automation (codemods, AST transforms) rather than making changes by hand.

### Step 4: Verify the Result

```
COMPARE BEFORE AND AFTER:
- Is the simplified version genuinely easier to understand?
- Did you introduce any new patterns inconsistent with the codebase?
- Is the diff clean and reviewable?
- Would a teammate approve this change?
```

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's working, no need to touch it" | Working code that's hard to read will be hard to fix when it breaks. |
| "Fewer lines is always simpler" | A 1-line nested ternary is not simpler than a 5-line if/else. |
| "This abstraction might be useful later" | Don't preserve speculative abstractions. Remove and re-add when needed. |
| "I'll refactor while adding this feature" | Separate refactoring from feature work. Mixed changes are harder to review. |

## Verification

- [ ] All existing tests pass without modification
- [ ] Build succeeds with no new warnings
- [ ] Each simplification is a reviewable, incremental change
- [ ] No error handling was removed or weakened
- [ ] No dead code was left behind
