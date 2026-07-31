/-
# Exact fibers of the radical Montgomery 2-isogeny

This file strengthens `RadicalMontgomery` from correctness and an
`X`-coordinate fiber calculation to a classification of the complete affine
fibers away from the kernel and ramification locus.  The nontrivial point in a
fiber is the explicit deck transform

`(x,y) ↦ (x⁻¹, -(y*x⁻²))`.

The results also verify that this transform preserves the source Montgomery
curve and is an involution wherever the rational formulas are defined.
-/
import Cryptography.IsogenySIDH.RadicalMontgomery

namespace Cryptography.IsogenySIDH

section ExactFibers

variable {K : Type*} [Field K]

/-- The nontrivial deck transformation of the affine degree-two quotient. -/
def radicalTwoDeck (P : K × K) : K × K :=
  (P.1⁻¹, -(P.2 * P.1⁻¹ ^ 2))

/-- The deck transformation preserves the source Montgomery equation away
from its pole. -/
theorem radicalTwoDeck_on_curve {A x y : K} (hx : x ≠ 0)
    (hP : OnMontgomery A (x, y)) :
    OnMontgomery A (radicalTwoDeck (x, y)) := by
  dsimp [OnMontgomery] at hP
  dsimp [OnMontgomery, radicalTwoDeck]
  field_simp
  linear_combination hP

/-- Applying the nontrivial deck transformation twice recovers the original
point. -/
theorem radicalTwoDeck_involutive {x y : K} (hx : x ≠ 0) :
    radicalTwoDeck (radicalTwoDeck (x, y)) = (x, y) := by
  apply Prod.ext
  · simp [radicalTwoDeck, hx]
  · dsimp [radicalTwoDeck]
    field_simp

/-- Quotient evaluation is constant on the orbit of the deck involution. -/
theorem radicalTwoEval_deck (x y : K) (hx : x ≠ 0) :
    radicalTwoEval (radicalTwoDeck (x, y)) = radicalTwoEval (x, y) := by
  exact radicalTwoEval_deck_invariant hx

/-- Away from `x² = 1`, equality of complete affine quotient outputs has
exactly two explanations: the input points coincide, or one is the explicit
deck transform of the other.  This is the exact unramified fiber theorem for
the rational degree-two map. -/
theorem radicalTwoEval_fiber_iff {x y z w : K}
    (hx : x ≠ 0) (hz : z ≠ 0) (hbranch : x ^ 2 ≠ 1) :
    radicalTwoEval (x, y) = radicalTwoEval (z, w) ↔
      (z = x ∧ w = y) ∨ (z = x⁻¹ ∧ w = -(y * x⁻¹ ^ 2)) := by
  have hc : 1 - x⁻¹ ^ 2 ≠ 0 := by
    intro hc
    apply hbranch
    field_simp [hx] at hc ⊢
    linear_combination hc
  constructor
  · intro h
    have hfst := congrArg Prod.fst h
    have hsnd := congrArg Prod.snd h
    dsimp [radicalTwoEval] at hfst hsnd
    rcases quotient_fiber_classification hx hz hfst with heq | hprod
    · left
      subst z
      exact ⟨rfl, mul_right_cancel₀ hc hsnd.symm⟩
    · right
      have hzx : z = x⁻¹ := by
        apply (mul_left_cancel₀ hx)
        rw [mul_inv_cancel₀ hx]
        exact hprod
      subst z
      refine ⟨rfl, ?_⟩
      apply mul_right_cancel₀ hc
      field_simp [hx] at hsnd ⊢
      linear_combination hsnd
  · intro h
    rcases h with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rfl
    · exact (radicalTwoEval_deck_invariant hx).symm

/-- Off the ramification locus, the deck mate is genuinely different from the
original affine point. -/
theorem radicalTwoDeck_ne {x y : K} (hx : x ≠ 0) (hbranch : x ^ 2 ≠ 1) :
    radicalTwoDeck (x, y) ≠ (x, y) := by
  intro h
  have hxcoord := congrArg Prod.fst h
  dsimp [radicalTwoDeck] at hxcoord
  apply hbranch
  calc
    x ^ 2 = x * x := by ring
    _ = 1 := by
      nth_rewrite 2 [← hxcoord]
      exact mul_inv_cancel₀ hx

/-- On a source-curve point away from poles and ramification, the complete
fiber consists precisely of the point and its distinct deck mate, and both
points remain on the source curve. -/
theorem radicalTwoEval_exact_two_fiber {A x y z w : K}
    (hx : x ≠ 0) (hbranch : x ^ 2 ≠ 1)
    (hP : OnMontgomery A (x, y)) (hz : z ≠ 0) :
    (OnMontgomery A (radicalTwoDeck (x, y)) ∧
      radicalTwoDeck (x, y) ≠ (x, y)) ∧
    (radicalTwoEval (z, w) = radicalTwoEval (x, y) ↔
      (z, w) = (x, y) ∨ (z, w) = radicalTwoDeck (x, y)) := by
  constructor
  · exact ⟨radicalTwoDeck_on_curve hx hP, radicalTwoDeck_ne hx hbranch⟩
  · constructor
    · intro h
      rcases (radicalTwoEval_fiber_iff hx hz hbranch).mp h.symm with h | h
      · left
        exact Prod.ext h.1 h.2
      · right
        exact Prod.ext h.1 h.2
    · intro h
      rcases h with h | h
      · exact congrArg radicalTwoEval h
      · rw [h]
        exact radicalTwoEval_deck x y hx

end ExactFibers

end Cryptography.IsogenySIDH