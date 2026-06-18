# Summary of changes for run 5723a655-c781-468f-a331-9aefaa109501
Created `Catalog/Applications/EGFOrderProfile.lean`, a small self-contained bridge package about the order profile of exponential generating functions over `ℚ`. It imports only `Catalog.Applications.CombinatorialSpecies` (which transitively provides Mathlib) and works in the existing `CombinatorialSpecies` namespace, reusing `egf`, `coeff_egf`, `egf_add`, `egf_mul`, and the `binConv` convolution.

Contents:
- `coeff_egf_eq` — restates the coefficient formula `coeff n (egf a) = a n / n!` (directly from the existing `coeff_egf`).
- `coeff_egf_ne_zero_iff` and `coeff_egf_eq_zero_iff` — the central support equivalence: a coefficient vanishes (resp. is nonzero) iff the sequence term does, using `(n! : ℚ) ≠ 0`.
- `egfOrder a := PowerSeries.order (egf a)`, with a `@[simp]` unfolding lemma.
- `min_egfOrder_le_egfOrder_add` — the ultrametric bound for pointwise addition, from `egf_add` and Mathlib's `min_order_le_order_add`.
- `egfOrder_binConv` — exact additivity of the order under the binomial convolution. Since `ℚ` has no zero divisors, Mathlib's `order_mul` gives equality directly (no weakening needed), and `egfOrder_binConv_le` records the corresponding lower bound.
- `le_egfOrder_iff` — a support criterion specializing the generic order characterization (`coeff_of_lt_order` / `nat_le_order`) through the coefficient-support equivalence: `↑n ≤ egfOrder a ↔ ∀ i < n, a i = 0`.

The file contains no `sorry`, no axioms, no tropical/truncation machinery or unrelated material, and compiles cleanly (verified by building the `CombinatorialSpecies` dependency and elaborating the new file against it with no errors).