Create a complete Lean 4 file in `Catalog/Applications/EGFOrderProfile.lean` that formalizes a minimal, robust EGF support/order bridge over `ℚ` inside the existing `CombinatorialSpecies` namespace.

Primary instruction: keep the scope tight and only prove statements that are directly supported by the current API from `Catalog.Applications.CombinatorialSpecies` and imported Mathlib `PowerSeries` lemmas. Do not invent a larger theory if the necessary order lemmas are absent.

Required targets:

1. Import the most relevant existing file(s), preferably just:
   - `Catalog.Applications.CombinatorialSpecies`

2. In namespace `CombinatorialSpecies`, prove the coefficient restatement:
   - `theorem coeff_egf_eq (a : ℕ → ℚ) (n : ℕ) : PowerSeries.coeff (R := ℚ) n (egf a) = a n / n.factorial := ...`
   This should simply reuse the existing `coeff_egf` theorem.

3. Prove exact zero/nonzero equivalences using that `(n.factorial : ℚ) ≠ 0`:
   - `theorem coeff_egf_eq_zero_iff (a : ℕ → ℚ) (n : ℕ) : PowerSeries.coeff (R := ℚ) n (egf a) = 0 ↔ a n = 0 := ...`
   - `theorem coeff_egf_ne_zero_iff (a : ℕ → ℚ) (n : ℕ) : PowerSeries.coeff (R := ℚ) n (egf a) ≠ 0 ↔ a n ≠ 0 := ...`

4. Derive finite-range support/truncation corollaries that avoid any fragile order API if necessary. For example, prove one or more of the following equivalent formulations:
   - `theorem egf_coeff_vanishes_below_iff (a : ℕ → ℚ) (N : ℕ) : (∀ m < N, PowerSeries.coeff (R := ℚ) m (egf a) = 0) ↔ (∀ m < N, a m = 0) := ...`
   - optionally also the nonzero/support version for existence of an index below `N`.

5. Only if the exact `PowerSeries.order` API is already available and easy to use, define:
   - `def egfOrder (a : ℕ → ℚ) : ℕ∞ := PowerSeries.order (egf a)`
   and prove only the basic support criterion:
   - `theorem le_egfOrder_iff (a : ℕ → ℚ) (N : ℕ) : ↑N ≤ egfOrder a ↔ ∀ m < N, a m = 0 := ...`
   This theorem should be obtained by combining the standard order characterization for power series with `coeff_egf_eq_zero_iff`.

6. Explicitly do NOT attempt the following unless the needed lemmas are already present under the imported names and require almost no additional infrastructure:
   - `min_egfOrder_le_egfOrder_add`
   - `egfOrder_binConv`
   - `egfOrder_binConv_le`
   If those lemmas are not immediately available, omit them entirely. A smaller complete file is preferred over a broader incomplete one.

7. Keep the file clean:
   - no `sorry`
   - no pasted unrelated declarations
   - no broken theorem statements
   - concise module docstring explaining that this file transfers coefficient support information from a sequence `a` to its EGF over `ℚ`

8. If the `PowerSeries.order` characterization theorem has a different exact name than expected, adapt to the real API. The goal is a compiling file, not adherence to guessed names.

The final result should be a self-contained bridge package with precise, modest theorems that definitely compile against the current library.