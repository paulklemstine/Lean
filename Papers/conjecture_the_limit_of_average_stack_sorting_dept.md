# THEOREM TRACE (internal anti-hallucination ledger)

Every result communicated in `ARTICLE.md` and `RESEARCH_PAPER.md` maps to a
declaration in the Phase A Lean output. No result is stated that is not below.

## Source file A — `StackSortingDepth.lean` (shipped in the project)
Path: `Catalog/8e92c627_retry1_aristotle/Applications/StackSortingDepth.lean`

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `popLess` | def | pop stack entries `< x`, return (popped, rest) | "the popping rule" | Def. 2.1 |
| `sortPass` | def | one left-to-right pass with a stack | "one pass of the machine" | Def. 2.2 |
| `stackSort` | def | `sortPass l []` — West's map `s` | "the sorting pass" | Def. 2.3 |
| `popLess_perm` | lemma | `(popLess x s).1 ++ (popLess x s).2 ~ s` | (implicit) | Lemma 3.1 |
| `sortPass_perm` | lemma | `sortPass xs stk ~ xs ++ stk` | (implicit) | Lemma 3.2 |
| `stackSort_perm` | lemma | `stackSort l ~ l` | "never loses or invents" | Thm 3.3 |
| `stackSort_length` | lemma | `(stackSort l).length = l.length` | "keeps the length" | Cor 3.4 |
| `sortPass_lt_singleton` | lemma | strict-incr `xs`, `m<` all ⇒ `sortPass xs [m] = m::xs` | (implicit) | Lemma 4.1 |
| `stackSort_strictSorted_eq` | lemma | strictly increasing ⇒ fixed point | "sorted is a fixed point" | Thm 4.2 |
| `depthAux` | def | bounded iteration counter | "bounded search" | Def. 5.1 |
| `depth` | def | least #passes to reach the sort | "the depth statistic" | Def. 5.2 |
| `depth_sorted` | lemma | sorted ⇒ depth 0 | "already sorted = depth 0" | Cor 5.3 |
| `permsN` | def | all permutations of `[1..n]` | "all n! orderings" | Def. 6.1 |
| `permsN_complete` | lemma | `p ∈ permsN n ↔ p ~ [1..n]` | "exactly the permutations" | Lemma 6.2 |
| `depthDist` | def | depth histogram of `S_n` | "the depth histogram" | Def. 6.3 |
| `stackSortableCount` | def | #perms with depth ≤ 1 | "one-pass sortable count" | Def. 7.1 |
| `depthLe1_card_eq_catalan_four` | theorem | `stackSortableCount 4 = catalan 4` (=14) | "Catalan law, n=4" | Thm 7.2 |
| `depthLe1_card_eq_catalan_five` | theorem | `stackSortableCount 5 = catalan 5` (=42) | "Catalan law, n=5" | Thm 7.3 |
| `depthLe1_card_eq_catalan_six` | theorem | `stackSortableCount 6 = catalan 6` (=132) | "Catalan law, n=6" | Thm 7.4 |

## Source file B — `DefantConstant.lean` (Phase A analytic kernel)
Constant: `defantConst := 3/5 * (7 - 8 * Real.log 2)`

| Lean name | Kind | Statement | Article | Paper |
|---|---|---|---|---|
| `defantConst` | def | `λ = (3/5)(7 - 8 ln 2)` | "the magic number" | Def. 8.1 |
| `defantConst_eq` | theorem | `λ = 21/5 - 24/5 ln 2` | "linear form" | Lemma 8.2 |
| `defantConst_bounds` | theorem | `0.8728 < λ < 0.8729` | "between 0.8728 and 0.8729" | Thm 8.3 |
| `defantConst_pos` | theorem | `0 < λ` | "positive density" | Cor 8.4 |
| `defantConst_lt_one` | theorem | `λ < 1` | "sub-linear" | Cor 8.5 |
| `defantConst_lt_seven_eighths` | theorem | `λ < 7/8` | "below 7/8" | Cor 8.6 |
| `golombDickman_bound_lt_defant` | theorem | `0.6244 < λ` (so `G < λ`) | "beats Golomb–Dickman" | Thm 8.7 |

Numeric sanity (verifiable, used in demo.py):
- `λ ≈ 0.872892`, `ln 2 ≈ 0.6931472`, `G ≈ 0.6243299885`.
- depth histograms: n=3 `[(0,1),(1,4),(2,1)]`; n=6 `[(0,1),(1,131),(2,276),(3,198),(4,90),(5,24)]`.
- `D_n/n`: 0.365 (n=4) → 0.387 (n=5) → 0.407 (n=6), rising slowly toward λ.
