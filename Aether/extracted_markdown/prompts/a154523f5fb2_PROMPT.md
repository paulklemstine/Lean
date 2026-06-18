Produce exactly one Lean file, focused only on weighted graph cuts on finite types, with no unrelated definitions or theorems.

Goal: formalize and completely prove submodularity of the cut functional.

Setting:
- Let `V` be a finite type with `[Fintype V] [DecidableEq V]`.
- Let `w : V → V → ℝ`.
- Assume nonnegativity: `hw : ∀ u v, 0 ≤ w u v`.
- For `A : Finset V`, define the cut
  `cut w A := ∑ u in A, ∑ v in (Finset.univ \ A), w u v`.

Main theorem to prove:
- `cut_submodular : cut w (A ∪ B) + cut w (A ∩ B) ≤ cut w A + cut w B`.

Required proof strategy:
1. Stay entirely within this graph-cut problem. Do not introduce number theory, dynamics, topology, simplicial complexes, or any other domain.
2. First define `cut` cleanly using `Finset.univ \ A` for the complement.
3. Prove a helper lemma expanding the cut as a sum over all ordered pairs, e.g. over `Finset.univ.product Finset.univ`, where the summand is `w u v` when `u ∈ A` and `v ∉ A`, otherwise `0`. You may implement this either via `if` expressions or by filtering the product finset.
4. Reduce the main inequality to a pointwise inequality for each ordered pair `(u,v)`.
5. Perform explicit case analysis on the four booleans recording membership of `u` in `A`, `u` in `B`, `v` in `A`, and `v` in `B`. The coefficient of `w u v` on the left must be shown ≤ the coefficient on the right in each case.
6. Use `hw u v` to pass from coefficient inequalities to inequalities of weighted summands.
7. Keep the development elementary and robust. If a helper lemma about `Finset.mem_union`, `Finset.mem_inter`, `Finset.mem_sdiff`, or `by_cases h : x ∈ A` is useful, add it.
8. Do not leave any theorem unfinished. No `sorry`, no placeholders, no incomplete declarations.

Important simplifications:
- Do not assume symmetry of `w` unless you discover it is strictly necessary; it should not be needed for submodularity of the directed cut expression above.
- It is acceptable to prove only the main theorem and the minimal helper lemmas needed for it.
- Prefer a short, type-checking, self-contained file over a more ambitious development.

Suggested theorem/definition names:
- `cut`
- `cut_eq_sum_product_indicator` (or similar)
- `cut_submodular`

Deliverable:
- A single Lean file that compiles cleanly in mathlib, containing only this finite weighted-cut formalization and complete proofs.