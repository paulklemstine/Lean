# Summary of changes
## Verification of Theorem 4.1 (ADE Tower from PPTs)

Theorem 4.1 from the paper claims:
- **(i)** SL(2, 𝔽₃) is the binary tetrahedral group of order 24, corresponding to E₆ under the McKay correspondence.
- **(ii)** SL(2, 𝔽₅) is the binary icosahedral group of order 120, corresponding to E₈ under the McKay correspondence.

### What was verified

I formalized and machine-verified the core computational claims in `RequestProject/Thm41.lean`:

1. **`thm41_sl2_F3_card`**: `|SL(2, 𝔽₃)| = 24` — proved via `native_decide` (direct computation over the finite group).
2. **`thm41_sl2_F5_card`**: `|SL(2, 𝔽₅)| = 120` — proved via `native_decide`.
3. **`thm41_order_formula_p3`**: The order formula `3 · (3² − 1) = 24` — proved via `norm_num`.
4. **`thm41_order_formula_p5`**: The order formula `5 · (5² − 1) = 120` — proved via `norm_num`.

All proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Lean.ofReduceBool`, `Lean.trustCompiler`, `Quot.sound`).

### What was not verified

The McKay correspondence itself (associating Dynkin diagrams E₆ and E₈ to these groups as finite subgroups of SL(2, ℂ)) is beyond current Mathlib coverage and was not formalized. The group isomorphisms SL(2, 𝔽₃) ≅ binary tetrahedral and SL(2, 𝔽₅) ≅ binary icosahedral are also not formalized, as Mathlib does not currently define these groups. However, the order computations — which are the concrete numerical claims in the theorem — are fully verified.