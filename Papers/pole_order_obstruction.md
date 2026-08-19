# Computational Evidence — Pole-order obstruction

All claims in this note were first explored with truncated Laurent arithmetic
(exploratory, *not* machine-checked), and the ones that survived were then
formalized and proved in Lean; the Lean files
`Catalog/Shared/PoleOrderObstruction.lean` and
`Catalog/Shared/PoleOrderObstructionDeep.lean` are the verified artifacts.
One numerical instance below (`m = 2`, moonshine data) is *also* verified in Lean
as `PoleOrderObstruction.coeff_zero_prod_J_mul_T2A`.

## 1. Small-case calculations with genuine moonshine data

Truncated Laurent multiplication of the first few normalized McKay–Thompson
series (constant terms `0`, as in the standard normalization):

```
T_1A = J  = q⁻¹ + 196884 q + 21493760 q² + 864299970 q³ + ⋯
T_2A      = q⁻¹ +   4372 q +    96256 q² + ⋯
T_3A      = q⁻¹ +    783 q +     8672 q² + ⋯
```

| m | order of ∏ | leading coeff | coeff at 1−m | coeff at 2−m | Newton RHS `2Σa₁ + (Σa₀)² − Σa₀²` |
|---|-----------|---------------|--------------|--------------|-----------------------------------|
| 1 | −1 | 1 | 0 | 196884 | 393768 = 2·196884 |
| 2 | −2 | 1 | 0 | 201256 | 402512 = 2·201256 |
| 3 | −3 | 1 | 0 | 202039 | 404078 = 2·202039 |

Observations, all confirmed by the Lean theorems:

* the order is exactly `−m` (`orderTop_prod_normalized`);
* the leading coefficient stays `1` (`leadingCoeff_prod_normalized`);
* the coefficient at `1 − m` is `Σ a₀ = 0` (`coeff_prod_normalized_subleading`,
  `coeff_prod_traceLaurent_194_subleading_eq_zero`);
* `2·(coeff at 2−m)` equals `2Σa₁ + (Σa₀)² − Σa₀²`
  (`coeff_prod_normalized_subsubleading`).  Here `201256 = 196884 + 4372` and
  `202039 = 196884 + 4372 + 783`.

## 2. Counterexample hunt: nonzero constant terms

To be sure the identities are not artifacts of the vanishing constant terms, the
same computation was run on the artificial family

```
A = q⁻¹ + 5 q⁰ + 7 q,   B = q⁻¹ − 3 q⁰ + 2 q,   C = q⁻¹ + 11 q⁰ − 4 q
```

| m | order of ∏ | coeff at 1−m | Σ a₀ | 2·(coeff at 2−m) | Newton RHS |
|---|-----------|--------------|------|------------------|------------|
| 1 | −1 | 5  | 5  | 14  | 14  |
| 2 | −2 | 2  | 2  | −12 | −12 |
| 3 | −3 | 13 | 13 | 24  | 24  |

No counterexample was found: order is `−m` in every case, the coefficient at
`1 − m` is exactly `Σ a₀`, and the Newton identity holds on the nose (note the
value `−12`, which is not of the form `2Σa₁`; the elementary-symmetric
correction `(Σa₀)² − Σa₀²` is genuinely present).

## 3. Why no counterexample can exist

The exploration also suggested the structural reason, which is what the Lean
development actually proves: `orderTop` on `ℂ⸨X⸩` is an additive valuation whose
restriction to units is a *group homomorphism* onto `ℤ`
(`orderMonoidHom_surjective`), and each normalized series factors uniquely as
`q⁻¹ · u` with `u` a unit power series of constant term `1`
(`exists_unique_unit_factorization`).  Multiplying `m` of them multiplies the
`q⁻¹` factors and the units separately; the unit part can never contribute to the
order, so no cancellation of poles is possible.

## 4. OEIS

No OEIS lookup was possible in this offline environment, so no OEIS
identification is claimed here.  The input coefficient sequences are the
standard published McKay–Thompson data (`1, 196884, 21493760, 864299970, …` for
`J = j − 744`, and `1, 4372, 96256, …` for the class `2A`); the derived sequence
of subleading coefficients `196884, 201256, 202039, …` consists of partial sums
of the first coefficients and is not expected to be a named entry.
