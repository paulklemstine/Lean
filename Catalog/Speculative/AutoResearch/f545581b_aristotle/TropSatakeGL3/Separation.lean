/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Separation Lemmas for Weight Triples via Weyl Chamber Walls

## Overview

We prove that any two distinct weight triples `μ ≠ ν` can be separated by
evaluating at a test point on one of the two Weyl chamber walls (Facet12 or
Facet23). The key structural result is that the `adjacentData` projection
family is injective.

The separation is achieved via *asymptotic rays*: on each wall, the evaluation
pairing reduces to a 2D linear form, and by choosing one coordinate large, we
lexicographically separate distinct exponents.

## Key Results

* `adjacentData_injective` — the two GL₂ projections together are injective
* `facet12_strict_separation` / `facet23_strict_separation` — ray separation
* `pair_strictly_separated_on_wall` — oriented separation on walls
-/
import TropSatakeGL3.Defs

namespace TropSatakeGL3

/-
The adjacent data map is injective: the second component gives `μ₁`, the
    first gives `μ₁+μ₂` (hence `μ₂`), and `μ₃` from either component.
-/
theorem adjacentData_injective : Function.Injective adjacentData := by
  unfold adjacentData; intro μ ν h; aesop;

/-
On Facet12, distinct projected exponents `(μ₁+μ₂, μ₃) ≠ (ν₁+ν₂, ν₃)` can be
    strictly separated: there exists `(a, a, b)` with `evalWeight μ < evalWeight ν`.
-/
theorem facet12_strict_separation
    {μ ν : Wt} (h : (μ.1 + μ.2.1, μ.2.2) ≠ (ν.1 + ν.2.1, ν.2.2)) :
    ∃ a b : ℤ, evalWeight μ (a, a, b) < evalWeight ν (a, a, b) := by
  contrapose! h;
  unfold evalWeight at h;
  have := h 1 0; have := h 0 1; have := h ( -1 ) 0; have := h 0 ( -1 ) ; norm_num at * ;
  constructor <;> linarith

/-
On Facet23, distinct projected exponents `(μ₁, μ₂+μ₃) ≠ (ν₁, ν₂+ν₃)` can be
    strictly separated: there exists `(a, b, b)` with `evalWeight μ < evalWeight ν`.
-/
theorem facet23_strict_separation
    {μ ν : Wt} (h : (μ.1, μ.2.1 + μ.2.2) ≠ (ν.1, ν.2.1 + ν.2.2)) :
    ∃ a b : ℤ, evalWeight μ (a, b, b) < evalWeight ν (a, b, b) := by
  simp +zetaDelta at *;
  contrapose! h;
  constructor <;> have := h 1 0 <;> have := h 0 1 <;> have := h ( -1 ) 0 <;> have := h 0 ( -1 ) <;> norm_num [ evalWeight ] at * <;> linarith

/-
Any two distinct weight triples can be strictly separated on some Weyl wall.
    This combines `adjacentData_injective` with facet-wise separation.
-/
theorem pair_strictly_separated_on_wall
    {μ ν : Wt} (hneq : μ ≠ ν) :
    ∃ x : TestPt,
      (x ∈ Facet12 ∨ x ∈ Facet23) ∧
      evalWeight μ x < evalWeight ν x := by
  by_cases h1 : (μ.1 + μ.2.1, μ.2.2) = (ν.1 + ν.2.1, ν.2.2);
  · -- Since the first components are equal, the second components must differ.
    have h2 : (μ.1, μ.2.1 + μ.2.2) ≠ (ν.1, ν.2.1 + ν.2.2) := by
      grind;
    exact Exists.elim ( facet23_strict_separation h2 ) fun a ha => Exists.elim ha fun b hb => ⟨ ( a, b, b ), Or.inr rfl, hb ⟩;
  · exact Exists.elim ( facet12_strict_separation h1 ) fun a ha => Exists.elim ha fun b hb => ⟨ ( a, a, b ), Or.inl rfl, hb ⟩

/-- Given a finite set of weights and a target `μ`, for each competitor `ν`,
    there is a wall test point strictly separating μ from ν. -/
theorem finite_pairwise_separation (S : Finset Wt)
    (μ : Wt) :
    ∀ ν ∈ S, ν ≠ μ →
      ∃ x : TestPt, (x ∈ Facet12 ∨ x ∈ Facet23) ∧
        evalWeight μ x < evalWeight ν x :=
  fun _ _ hne => pair_strictly_separated_on_wall hne.symm

end TropSatakeGL3