# Theorem Trace (internal anti-hallucination ledger)

All names below are taken verbatim from the Phase A Lean output in
`Catalog/Novelty/GridLipschitzMass.lean` and
`Catalog/Novelty/GridLipschitzMassBoundary.lean`. No result outside this list is
claimed in ARTICLE.md or RESEARCH_PAPER.md.

| Lean name | Kind | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|---|
| `gridMass` | def | `gridMass f m n = ∑_{i<m} ∑_{j<n} |f i j|` | "total mass" intro | Def. 1 |
| `triBound` | def | `triBound m n = n·(m(m−1)/2) + m·(n(n−1)/2)` (ℕ) | "the magic number" | Def. 2 |
| `cell_row_le` | lemma | If `f 0 0 = 0` and rows are 1-Lipschitz and `0<n`, then `|f i 0| ≤ i` for `i<m` | "walking along the bottom" | Lemma 1 |
| `cell_abs_le` | lemma | If anchored and both rows/cols 1-Lipschitz, then `|f i j| ≤ i+j` for `i<m, j<n` | "distance from the corner" | Lemma 2 |
| `sum_grid_add` | lemma | `∑_{i<m}∑_{j<n} (i+j) = triBound m n` | "adding up the staircase" | Lemma 3 |
| `gridMass_le` | theorem | anchored + 1-Lipschitz ⇒ `gridMass f m n ≤ triBound m n` | Main theorem | Theorem 1 |
| `staircase` | def | `staircase i j = i + j` | "the staircase" | Def. 3 |
| `staircase_admissible` | theorem | `staircase 0 0 = 0` and staircase is 1-Lipschitz on all edges | "it's legal" | Prop. 1 |
| `gridMass_staircase` | theorem | `gridMass staircase m n = triBound m n` | sharpness | Theorem 2 |
| `gridMass_neg_staircase` | theorem | `gridMass (−staircase) m n = triBound m n` | sharpness, two extremes | Theorem 3 |
| `constant_unbounded_mass` | theorem | constant `f ≡ C` is 1-Lipschitz but has mass `m·n·|C|`, unbounded (anchor is load-bearing) | "why the anchor matters" | Theorem 4 |

Notes:
- `gridMass_const` is referenced in Phase A future directions (constant contribution `m·n·|c|`); it is only mentioned in the Future Directions section, not claimed as a standalone proved headline result.
