Formalize a complete Lean 4 development of a discrete holographic entropy functional on finite weighted graphs, with all proofs fully present and no `sorry`. Work in a finite type `V` with `[Fintype V] [DecidableEq V]`. Let `w : V → V → ℝ` be a weight function. Define a cut functional on `Finset V` by summing over all ordered pairs `(u,v)` with `u ∈ A` and `v ∉ A`; you may define it directly as a double `Finset.univ.sum` with an `if` term, or equivalently via indicators if that is easier for proofs.

Be disciplined about assumptions:
- For nonnegativity and inequality theorems, assume `hw_nonneg : ∀ u v, 0 ≤ w u v`.
- For complement invariance `cut A = cut Aᶜ`, additionally assume symmetry `hw_symm : ∀ u v, w u v = w v u`.

Target a file that is self-contained and definitely compiles. Prefer a smaller set of fully proved theorems over a larger set with fragile proof scripts.

Required core results:
1. Definition of `cut` for `Finset V`.
2. `cut_nonneg`.
3. `cut_empty` and `cut_univ`.
4. `cut_compl` under symmetric weights, where complement is taken inside `Finset.univ`.
5. A union upper bound such as `cut (A ∪ B) ≤ cut A + cut B`.
6. The main theorem: submodularity / strong subadditivity in graph-cut form,
   `cut (A ∪ B) + cut (A ∩ B) ≤ cut A + cut B`.
7. At least one clean corollary, e.g. nonnegativity of the mutual-information-style quantity
   `cut A + cut B - cut (A ∪ B) - cut (A ∩ B)`.

Recommended proof strategy:
- Express every theorem as an inequality between finite double sums.
- Reduce to a pointwise inequality for each pair `(u,v)`.
- Prove the pointwise claim by case splitting on the propositions `u ∈ A`, `u ∈ B`, `v ∈ A`, `v ∈ B` or on the relevant induced booleans.
- Use `Finset.sum_le_sum` to lift pointwise inequalities to sums.
- Keep complement lemmas explicit and simple; if complement over `Finset` becomes awkward, define a local `compl (A : Finset V) : Finset V := Finset.univ.filter fun x => x ∉ A` and prove basic membership lemmas first.

Important: avoid speculative physics claims in theorem statements. The deliverable is a mathematically precise formalization of a weighted graph cut entropy functional inspired by holography. Include concise module documentation explaining that this is a discrete combinatorial analogue of Ryu–Takayanagi entropy, but keep the mathematics elementary and fully verified.

If you find Araki–Lieb awkward in this setup, omit it unless it falls out cleanly from the established inequalities. Completeness and proof robustness are the priority.