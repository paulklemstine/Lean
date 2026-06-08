/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Speculative.BSD.Definitions

/-!
# BSD Algebraic Side Positivity and Nonvanishing

## Main results

* `bsdAlgebraicSide_pos`: Strict positivity of the BSD algebraic side under
  standard hypotheses (all invariants positive/nonzero).
* `bsdAlgebraicSide_ne_zero`: Nonvanishing variant.
* `bsdAlgebraicSide_nonneg`: Nonnegativity under weaker hypotheses.

## Proof strategy

Strategy A (ordered-field positivity): Expand `bsdAlgebraicSide` into its
product/quotient form and apply `mul_pos`, `div_pos`, `pow_pos`, etc.
This is direct and fully supported by Mathlib's ordered algebra hierarchy.
-/

/-
**Strict positivity of the BSD algebraic side.**
Under standard hypotheses — real period positive, regulator positive,
Sha order positive, Tamagawa product positive, torsion order positive —
the algebraic side of BSD is strictly positive.

This theorem certifies that the BSD ratio `L*(E,1) / bsdAlgebraicSide(E)`
has a well-defined, positive denominator, enabling safe division in
verified numerical checks.
-/
theorem bsdAlgebraicSide_pos
    (D : BSDData)
    (hΩ : 0 < D.realPeriod)
    (hR : 0 < D.regulator)
    (hSha : 0 < D.shaOrder)
    (hTamagawa : 0 < D.tamagawa)
    (hTor : 0 < D.torsionOrder) :
    0 < bsdAlgebraicSide D := by
  exact div_pos ( mul_pos ( mul_pos ( mul_pos hΩ hR ) ( Nat.cast_pos.mpr hSha ) ) ( Nat.cast_pos.mpr hTamagawa ) ) ( sq_pos_of_pos ( Nat.cast_pos.mpr hTor ) )

/-
**Nonvanishing of the BSD algebraic side.**
Under nonvanishing hypotheses on all constituent invariants,
the algebraic side of BSD is nonzero.
-/
theorem bsdAlgebraicSide_ne_zero
    (D : BSDData)
    (hΩ : D.realPeriod ≠ 0)
    (hR : D.regulator ≠ 0)
    (hSha : D.shaOrder ≠ 0)
    (hTamagawa : D.tamagawa ≠ 0)
    (hTor : D.torsionOrder ≠ 0) :
    bsdAlgebraicSide D ≠ 0 := by
  exact div_ne_zero ( mul_ne_zero ( mul_ne_zero ( mul_ne_zero hΩ hR ) ( Nat.cast_ne_zero.mpr hSha ) ) ( Nat.cast_ne_zero.mpr hTamagawa ) ) ( pow_ne_zero 2 ( Nat.cast_ne_zero.mpr hTor ) )

/-
**Nonnegativity of the BSD algebraic side** under weaker hypotheses.
-/
theorem bsdAlgebraicSide_nonneg
    (D : BSDData)
    (hΩ : 0 ≤ D.realPeriod)
    (hR : 0 ≤ D.regulator) :
    0 ≤ bsdAlgebraicSide D := by
  exact div_nonneg ( mul_nonneg ( mul_nonneg ( mul_nonneg hΩ hR ) ( Nat.cast_nonneg _ ) ) ( Nat.cast_nonneg _ ) ) ( sq_nonneg _ )

/-!
## Commentary

**Strategy A succeeded**: The algebraic side is a product of nonneg/positive terms
divided by a positive square. Mathlib's `mul_pos`, `div_pos`, `Nat.cast_pos`, and
`sq_pos_of_pos` close all goals cleanly.

**Strategy B (generic positivity for weighted products) was deferred**: While
architecturally useful for future Euler product constructions, it adds complexity
without benefit for the single-fraction BSD formula.

**Strategy C (logarithmic version) was deferred**: Opens doors to asymptotic study
but requires additional `Real.log` infrastructure not needed here.
-/