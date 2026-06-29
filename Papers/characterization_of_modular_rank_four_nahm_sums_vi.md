# Theorem Trace — Discriminant Invariants for Rank-Four Nahm Sums

Internal anti-hallucination ledger. Every name below is taken verbatim from the
Phase A Lean file `Catalog/Applications/NahmSums/Discriminant.lean`. No other
theorems are asserted in the packaging deliverables.

| Lean name | Kind | Mathematical statement | In ARTICLE.md | In RESEARCH_PAPER.md |
|---|---|---|---|---|
| `NahmRank4.disc` | def | `disc H := H.det`, the discriminant of a Nahm datum = determinant of the integer Hessian `H`. | Yes (defined as "the discriminant") | Yes (Definition: discriminant) |
| `NahmRank4.det_congr` | theorem | For matrices `S, H` over a commutative ring: `(Sᵀ * H * S).det = (S.det)^2 * H.det`. | Yes (transformation law in words + formula) | Yes (Theorem 1, with proof sketch) |
| `NahmRank4.disc_invariant` | theorem | If `det S = ±1` then `disc (Sᵀ * H * S) = disc H`. | Yes (unimodular invariance) | Yes (Theorem 2, with proof sketch) |
| `NahmRank4.disc_directSum_mul` | theorem | `(fromBlocks A 0 0 D).det = A.det * D.det`. | Yes (direct-sum multiplicativity) | Yes (Theorem 3, with proof sketch) |
| `NahmRank4.disc_diagonal` | theorem | `disc (diagonal d) = ∏ i, d i`. | Yes (diagonal product) | Yes (Theorem 4, with proof sketch) |
| `NahmRank4.realizable` | theorem | For `d ∈ {8,12,16}` there is a symmetric integer Hessian `H` with positive diagonal and `disc H = d`; witnesses `diag(2,2,2,1)`, `diag(2,2,3,1)`, `diag(2,2,2,2)`. | Yes (the three witnesses) | Yes (Theorem 5, with witnesses) |

## Claims NOT proved in the Lean file (must remain conjectural in prose)
- The modularity ⇔ `det H ∈ {8,12,16}` biconditional itself (the grand conjecture).
- `target_characterization`, `target_factorization`, `DiscriminantSet.lean`,
  `QPochhammer.lean` — referenced only in the Phase A future-directions text; their
  contents are NOT in the provided Lean output, so they appear only inside the
  verbatim `future_directions` field, never as established results in prose.
