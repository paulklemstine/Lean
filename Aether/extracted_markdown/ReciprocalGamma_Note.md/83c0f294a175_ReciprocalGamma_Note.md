# Research note: a reciprocal-Gamma theorem package

## Scope

`Catalog/SpecialFunctions/ReciprocalGamma.lean` is a single, narrow, fully proven Lean file
collecting a coherent package of facts about the complex Gamma function `Complex.Gamma` and,
centrally, its reciprocal `s ↦ (Γ s)⁻¹`. The file contains no `sorry`, compiles against the
project's Mathlib (Lean `v4.28.0`), and deliberately excludes any zeta-function,
hypergeometric, or other unrelated material.

## The theorem package

All declarations live in the `ReciprocalGamma` namespace.

1. **Meromorphy of Gamma** — `gamma_meromorphic : Meromorphic Complex.Gamma`.
   `Γ` is meromorphic on all of `ℂ`.

2. **Reciprocal Gamma is entire** — `one_div_gamma_differentiable :
   Differentiable ℂ (fun s => (Γ s)⁻¹)` with the local companion
   `one_div_gamma_analyticAt (z) : AnalyticAt ℂ (fun s => (Γ s)⁻¹) z`.
   The strongest convenient global notion available in Mathlib for this map is
   `Differentiable ℂ`; analyticity at each point follows from it.

3. **Zero locus of reciprocal Gamma** — `one_div_gamma_eq_zero_iff (z) :
   (Γ z)⁻¹ = 0 ↔ ∃ n : ℕ, z = -(n : ℂ)`.
   The reciprocal vanishes exactly at the nonpositive integers.

4. **Factorial interpolation** — `gamma_natCast_add_one (n : ℕ) :
   Γ (n + 1) = (Nat.factorial n : ℂ)`.

5. **Poles of Gamma** — `gamma_pole_iff (z) :
   meromorphicOrderAt Complex.Gamma z < 0 ↔ ∃ n : ℕ, z = -(n : ℂ)`.
   In meromorphic language, `Γ` has a pole (strictly negative order) at `z` precisely at the
   nonpositive integers.

   Two supporting lemmas are exposed/used: `one_div_gamma_analyticOrderAt_ne_top`
   (the entire reciprocal never has infinite analytic order, because it is not locally zero —
   it equals `1` at `s = 1`), and a small private arithmetic lemma `neg_double_coe` over
   `WithTop ℤ`.

## How statement (5) is derived from the entire picture

The pole statement is obtained without any new analysis, purely by transporting the entire
description of `g := fun s => (Γ s)⁻¹` through the order calculus:

* Since `g` is analytic at `z`, `meromorphicOrderAt g z = ENat.map Nat.cast (analyticOrderAt g z)`
  (`AnalyticAt.meromorphicOrderAt_eq`).
* `meromorphicOrderAt g z = - meromorphicOrderAt Γ z` (`meromorphicOrderAt_inv`), hence
  `meromorphicOrderAt Γ z = - ENat.map Nat.cast (analyticOrderAt g z)`.
* `analyticOrderAt g z = 0 ↔ g z ≠ 0` (`AnalyticAt.analyticOrderAt_eq_zero`), and the analytic
  order is finite (`one_div_gamma_analyticOrderAt_ne_top`, via `analyticOrderAt_eq_top` and the
  identity theorem `AnalyticOnNhd.eqOn_zero_of_preconnected_of_eventuallyEq_zero`).
* Therefore `meromorphicOrderAt Γ z < 0 ↔ g z = 0 ↔ Γ z = 0 ↔ ∃ n, z = -n`
  (`Complex.Gamma_eq_zero_iff`).

## Key imported Mathlib facts

* `Meromorphic.Gamma`
* `Complex.differentiable_one_div_Gamma`
* `Complex.Gamma_eq_zero_iff`
* `Complex.Gamma_nat_eq_factorial`
* `Complex.Gamma_one`
* `AnalyticAt.meromorphicOrderAt_eq`, `meromorphicOrderAt_inv`
* `AnalyticAt.analyticOrderAt_eq_zero`, `analyticOrderAt_eq_top`
* `AnalyticOnNhd.eqOn_zero_of_preconnected_of_eventuallyEq_zero`
* `WithTop.LinearOrderedAddCommGroup.coe_neg`, `WithTop.coe_lt_coe`, `ENat.map_coe`

## Build

The module is registered in `lakefile.toml` as a dedicated `lean_lib` (`SpecialFunctions`,
`srcDir = "."`, glob `Catalog.SpecialFunctions.ReciprocalGamma`) and builds with

```
lake build Catalog.SpecialFunctions.ReciprocalGamma
```

`#print axioms ReciprocalGamma.gamma_pole_iff` reports only `propext`, `Classical.choice`,
`Quot.sound`.

## What remains for future work

This package stops at the reciprocal-entire and pole-location picture. Stronger Gamma results
not formalised here include:

* the exact simple-pole structure with residues `Res_{z=-n} Γ = (-1)ⁿ / n!`;
* the Weierstrass and Euler infinite-product representations of `1/Γ`;
* the reflection formula `Γ(z) Γ(1 - z) = π / sin(π z)`;
* the duplication / Gauss multiplication formulas;
* the Bohr–Mollerup characterisation of `Γ`.
