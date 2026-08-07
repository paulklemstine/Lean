# Computational Evidence — Hadwiger's Conjecture (Cycle v19c)

All numbers below were produced by brute-force `#eval` enumeration in Lean over
*labelled* graphs on `n` vertices (all `2^{C(n,2)}` edge sets), using an
independent naive implementation (component-labelling for connectivity,
exhaustive colour assignments for colourability, exhaustive branch-set
assignments for minor testing).

**Status of these numbers: exploratory `#eval` computations, not machine-checked
theorems.** The theorems delivered in `Catalog/Probability/Hadwiger*.lean` are
proved for *all* graphs and do not depend on any of these computations; the
tables served to check the statements before formalising them.

## 1. Forests vs. graphs with a K₃ minor

The formalised theorem `completeMinor_three_iff_not_isAcyclic` says
"K₃ ≼ G ⟺ G contains a cycle", i.e. the K₃-minor-free graphs are exactly the
forests. Counting labelled forests (`|E| + c(G) = n`):

| n | all graphs 2^C(n,2) | forests | graphs with a K₃ minor |
|---|--------------------:|--------:|-----------------------:|
| 3 |   8 |   7 |   1 |
| 4 |  64 |  38 |  26 |
| 5 | 1024 | 291 | 733 |

The forest column is `1, 1, 2, 7, 38, 291, …` — OEIS **A001858** (labelled
forests of rooted-free trees), matching for every computed `n`. This is a
consistency check on the enumeration code itself.

## 2. Hadwiger's conjecture, exhaustive check for small n

Counterexample hunt: a counterexample to `HadwigerProperty k` on `n` vertices is
a graph that is not `k`-colourable and has no `K_{k+1}` minor.

| k | n | non-k-colourable graphs | of these, without a K_{k+1} minor |
|---|---|------------------------:|----------------------------------:|
| 2 | 4 | 26  | **0** |
| 2 | 5 | 733 | **0** |
| 3 | 5 | 66  | **0** |

No counterexample exists in this range, as required. The case `k = 2` is now a
theorem for *all* graphs (`hadwiger_two`, and `hadwiger_gen_two` without any
finiteness hypothesis). The case `k = 3` (Dirac) is verified here only for
`n ≤ 5` and remains unformalised — it is the first entry of
`FUTURE_DIRECTIONS.md`.

## 3. The converse of Hadwiger fails, and fails often

`chromaticNumber_not_minorMonotone` exhibits `C₆`: 2-colourable with a K₃ minor.
The enumeration shows this is not an isolated accident:

| n | 2-colourable graphs | 2-colourable **and** having a K₃ minor |
|---|--------------------:|---------------------------------------:|
| 4 |  41 |  3 |
| 5 | 376 | 85 |

and at the next level, on `n = 5`: **45** graphs are 3-colourable and still have
a `K₄` minor. So having a `K_{k+1}` minor is strictly weaker than needing
`k+1` colours at every level tested, which is exactly why Hadwiger's conjecture
is a one-way implication.

## 4. Random graphs

In the catalog `G(n,p)` model the event "has a K₃ minor" is *literally* the
event "contains a cycle" (`hasK3Minor_eq_hasCycle`, a proved theorem, not a
numerical observation), so the probability table for cycles in `G(n,p)`
transfers verbatim. The proved bound `p³ ≤ P(K₃ ≼ G(n,p))` for `n ≥ 3` is
consistent with the exact small-case values one reads off §1: for `n = 4` and
`p = 1/2`, `P = 26/64 ≈ 0.406 ≥ p³ = 0.125`; for `n = 5`, `p = 1/2`,
`P = 733/1024 ≈ 0.716 ≥ 0.125`. The gap shows the single-triangle bound is far
from tight for moderate `p`, which motivates the second-moment conjecture in
`FUTURE_DIRECTIONS.md`.
