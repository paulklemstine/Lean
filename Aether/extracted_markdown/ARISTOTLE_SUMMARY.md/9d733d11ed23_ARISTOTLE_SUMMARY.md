# Summary of changes for run 1135025d-4cea-46ad-8e71-4c829476c2c8
Created a single self-contained Lean file at `Catalog/MachineLearning/WeightedGraphCut.lean` formalizing and fully proving submodularity of the directed weighted graph cut on a finite type.

Contents (only this topic, no unrelated material):
- `cut w A := ∑ u ∈ A, ∑ v ∈ Finset.univ \ A, w u v` — the directed weighted cut, using `Finset.univ \ A` for the complement.
- `cut_eq_sum_product_indicator` — helper lemma expressing the cut as a sum over all ordered pairs `(u, v) ∈ Finset.univ : Finset (V × V)` of the indicator term `if u ∈ A ∧ v ∉ A then w u v else 0`.
- `cut_submodular` — the main theorem: for nonnegative weights `hw : ∀ u v, 0 ≤ w u v`, `cut w (A ∪ B) + cut w (A ∩ B) ≤ cut w A + cut w B`.

The proof follows the requested strategy: rewrite all four cuts via the indicator-sum lemma, combine into a single `Finset.sum_le_sum`, reduce to a pointwise inequality per ordered pair, and discharge it by case analysis on the four membership booleans (`u ∈ A`, `v ∈ A`, `u ∈ B`, `v ∈ B`), using `hw u v ≥ 0` to conclude. Symmetry of `w` is not assumed or needed.

The file builds cleanly against mathlib with no `sorry`, and both declarations depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.