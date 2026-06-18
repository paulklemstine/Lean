# Summary of changes for run 824559dd-cd92-4dbc-9a54-ac95387b38f6
Created a single self-contained Lean file `Catalog/Computation/IIT/ClassicalBitChain.lean` formalizing a finite classical surrogate of integrated information (`Φ_min`) for bit chains. It compiles cleanly with no `sorry`/placeholders and depends only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

Scope is kept entirely within finite classical probability on `Fin n → Bool` configurations (computable finite sums, no measure theory, no quantum/tensor-network machinery).

Key contents:
- `IsProbDist p`: nonnegativity + total mass 1 over the finite configuration space.
- Cut infrastructure: `cutEquiv k hk : (Fin k → Bool) × (Fin (n-k) → Bool) ≃ (Fin n → Bool)` (built from `Fin.appendEquiv`), the forward map `recombine`, the inverse-law simp lemma `cutEquiv_symm_recombine`, and the Fubini-style sum decomposition `sum_eq_sum_recombine`.
- `leftMarginal` / `rightMarginal` by summing over the opposite block.
- `CutIndependent` (factorization through the two marginals) and `FactorsAcross` (factorization through some left/right factors).
- `cutScore` (0 if independent, else 1), `NontrivialCut` (1 ≤ k < n), and `PhiMin` (0 iff some nontrivial independent cut exists).

Required theorems proved:
- `cutIndependent_of_factorsAcross`: for a genuine probability distribution, any factorization upgrades to genuine cut independence.
- `cutScore_eq_zero_of_factorization`: a factorized distribution scores 0 at the cut.
- `phiMin_eq_zero_of_exists_factorization` (and `phiMin_eq_zero_of_exists_cutIndependent`): a nontrivial witnessing cut forces `PhiMin p = 0`.
- Product-distribution constructor `productDist` with `productDist_isProbDist`, `productDist_factorsAcross`, and `productDist_cutIndependent`.
- Concrete example: `uniform2` (uniform distribution on a 2-bit chain as a product of two fair bits across the middle cut) with `uniform2_isProbDist` and `uniform2_phiMin_zero : PhiMin uniform2 = 0`.

The file includes module documentation explaining the surrogate notion and listing the exact results. The project's pre-existing default build targets are unrelated and were left untouched; the new file was verified by compiling it directly.