# THEOREM TRACE (internal anti-hallucination ledger)

Source of truth: the Phase A concept statement and the Phase A future-directions
block, which name the proved theorems for the `h = 1` (Fano plane, `PG(2,2)`)
case of additive strong blocking sets. Only the names below are referenced in
the public deliverables; no theorem is invented or renamed into a grander claim.

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `IsLine` | Predicate selecting the 7 lines of `PG(2,2)`; each line is a 3-element subset of the 7 points (a 2-dimensional subspace of `F_2^3`). | "Lines" section | Def. 2.2 |
| `StrongBlocking` | A set `S` of points is strong blocking iff for every line `ℓ`, the points `S ∩ ℓ` span `ℓ`; over `F_2` this is `|S ∩ ℓ| ≥ 2`. | "What blocking means" | Def. 2.4 |
| `strongBlocking_iff_card` | `StrongBlocking S ↔ 6 ≤ S.card`: a subset of the 7 Fano points is strong blocking iff it omits at most one point. | Main theorem (plain language + example) | Theorem 3.1 |
| `leastSize_strongBlocking` | `IsLeast {n | ∃ S, StrongBlocking S ∧ S.card = n} 6`: the minimum size of a strong blocking set in `PG(2,2)` is exactly 6. | Main theorem (the number 6) | Theorem 3.4 |

Coding corollary (stated, not a separate Lean name): under the projective-system
correspondence, `leastSize_strongBlocking` is equivalent to "the shortest
nondegenerate minimal binary linear code of dimension 3 has length 6."

No other theorem names are asserted as proved. Conjectures 1–5 are clearly marked
as open in both documents and in `future_directions`.
