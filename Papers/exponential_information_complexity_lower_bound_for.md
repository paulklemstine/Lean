# THEOREM_TRACE (internal anti-hallucination ledger)

Every claim in `ARTICLE.md`, `RESEARCH_PAPER.md`, and `RESEARCH_PAPER.tex` traces to a
Lean declaration that actually appears in the Phase A source files. No theorem is invented
or renamed into a grander claim.

## Proven declarations (ground truth)

### `Catalog/Computation/HammingBallDiscrepancy.lean`
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `hammingDist_add_right` | `hammingDist (x+a) (y+a) = hammingDist x y` (translation invariance) | "the ruler doesn't care where you stand" | Lemma 1 |
| `ball_eq_image` | `ball r z = (ball r 0).image (· + z)` | implicit in translation paragraph | Lemma 2 |
| `ball_card_eq` | `(ball r z).card = (ball r 0).card` (volume independent of centre) | "every ball is the same size" | Theorem 2 |
| `card_centres_containing` | `#{z : d(c,z) ≤ r} = |B_r(0)|` | dual counting step | Lemma 3 |
| `sum_inter_ball` | `∑_z |C ∩ B_r(z)| = |C|·|B_r(0)|` (exact averaging identity) | MAIN — "the headline identity" | Theorem 1 (main) |
| `card_bad_centres_le` | `#{z : t ≤ |C ∩ B_r(z)|}·t ≤ |C|·|B_r(0)|` (Markov) | "few centres can be crowded" | Theorem 3 |

### `Catalog/Computation/HammingBallVolume.lean`
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `sphere_card` | `|S_r(0)| = C(n,r)·(q-1)^r` | "counting at exactly distance r" | Lemma 4 |
| `ball_card_eq_sum_sphere` | `|B_r(0)| = ∑_{i≤r} |S_i(0)|` | ball = stacked shells | Lemma 5 |
| `ball_card_formula` | `|B_r(0)| = ∑_{i≤r} C(n,i)(q-1)^i` | explicit volume formula | Theorem 4 |

### `Catalog/Computation/LinearCodeCosets.lean`
| Lean name | Statement | Article | Paper |
|---|---|---|---|
| `inter_ball_coset_invariant` | coset translation preserves `|C ∩ B_r(z)|` | "shifting a code" | Lemma 6 |
| `inter_ball_eq_of_sub_mem` | same intersection count when centres differ by codeword | "code-periodicity" | Lemma 6 cor. |

## Curse / duality names (concept + Phase A future directions ONLY)
These appear in the concept framing and Phase A future-directions text, NOT proven in the
files above. They are mentioned in the paper's "Discussion / Future Work" and in
`future_directions` of PACKAGE.json, explicitly labelled as the companion framework /
open program. They are NOT stated as proved theorems anywhere in the prose:
`curse_of_dimensionality`, `Rule.sum_err_ge`, `Rule.empty_cell_of_lt`,
`exists_centre_ge_average`.
