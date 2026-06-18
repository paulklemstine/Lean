# Summary of changes for run 9bb27b6f-d08b-4fa5-9ab5-bdd0b37a7eb9
Added a new, fully-proved Lean development of the Erdős probabilistic lower bound on Ramsey numbers, plus a research-directions file.

## New file: `Catalog/MachineLearning/ProbabilisticMethod/RamseyLowerBound.lean`

This replaces the catalog's earlier *placeholder* Ramsey statements (e.g. `ProbabilisticMethod.erdos_ramsey_counting`, whose conclusion was the vacuous `∃ i : Fin (2^(n choose 2)), True`, and `constructive_ramsey_conjecture`) with theorems whose conclusions carry genuine combinatorial content. Edges of `K_n` are modeled as 2-element subsets of `Fin n` and colorings as functions `Edge n → Bool`.

Main theorems (all proved, no `sorry`):
- `erdos_ramsey_exists`: if `2 * (n choose k) < 2^(k choose 2)` then there exists a 2-coloring of the edges of `K_n` with **no** monochromatic `K_k`. Specializing to `n < 2^(k/2)` recovers Erdős's classical `R(k,k) > 2^(k/2)`.
- `ramsey_lower_bound`: the same witness avoids both a red and a blue `K_k`, i.e. `R(k,k) > n`.
- `erdos_ramsey_asymmetric`: the off-diagonal strengthening — under the cleared-denominator hypothesis `C(n,s)·2^(E-C(s,2)) + C(n,t)·2^(E-C(t,2)) < 2^E` (E = n choose 2) there is a coloring with no red `K_s` and no blue `K_t`, i.e. `R(s,t) > n`. This strictly generalizes the diagonal theorem.
- `mono_clique_k2`: the sharp boundary case — for `k = 2` every coloring has a monochromatic `K_2`, proving the counting hypothesis cannot simply be dropped.

Supporting (all proved): `edge_card`, `coloring_card`, `inside_card`, `card_monoOn_le`, `card_constOn_le` — the exact clique-counting cardinalities that make the first-moment/union-bound argument constructive at the counting level.

The proof method is the first-moment method: it bounds the number of "bad" colorings strictly below the total `2^(n choose 2)`, so a good coloring must exist. It builds on the catalog's first-moment philosophy in `Speculative/ProbabilisticMethod/Core.lean` (`first_moment_principle`, `union_bound_existence`) but instantiates it with real cardinalities, and connects to the extremal-graph-theory material via the directions file.

Verification: the file builds successfully (module `MachineLearning.ProbabilisticMethod.RamseyLowerBound`), contains zero `sorry`, and every result depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`. Proof-sketch comments are included as `-- !-- ... -- !--` blocks.

## New file: `Catalog/MachineLearning/ProbabilisticMethod/FUTURE_DIRECTIONS.md`

Five falsifiable research directions extending the work, each with a "The key insight is..." sentence and a "Why now?" justification: (1) a Ramsey-number object and the closed form `R(k,k) > ⌊2^(k/2)⌋`; (2) derandomization by conditional expectations (constructive Ramsey); (3) Property B and the symmetric/Moser–Tardos Lovász Local Lemma; (4) a Ramsey–Turán bridge using Mathlib's existing Turán theorem; (5) the deletion/alteration method for a stronger constant.