/-
# Boundary of the additive uncertainty principle

The additive uncertainty principle `|supp f| + |supp f̂| ≥ p + 1` is a *prime-order* phenomenon
and is strictly stronger than the Donoho–Stark product bound `|supp f| · |supp f̂| ≥ p`
(`FourierCyclic.uncertainty_zmod`).  This file makes both statements precise and proves them.

* `PrimeUncertainty.product_bound_does_not_imply_sum_bound` : for every `p ≥ 5` there are
  admissible cardinalities satisfying the product bound but violating the sum bound, so no
  purely arithmetic manipulation of the Donoho–Stark inequality can give the additive one.
* `PrimeUncertainty.sum_bound_fails_zmod_four` : an explicit `f` on the *composite* group
  `ZMod 4` with `|supp f| = |supp f̂| = 2`; the product bound is attained with equality while
  the additive bound `4 + 1` fails.  Primality is therefore essential.
* `PrimeUncertainty.sum_bound_sharp_delta` and `PrimeUncertainty.sum_bound_sharp_character` :
  the additive bound is attained at both ends of the scale — by Dirac deltas
  (`1 + p`) and by characters (`p + 1`).
-/

import Mathlib
import MachineLearning.PrimeUncertainty.SumBound

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

/-! ## The sum bound is strictly stronger than the product bound -/

/-- **Strict strengthening.**  For every `p ≥ 5` there are cardinalities `a, b ≥ 1` obeying the
Donoho–Stark product bound `p ≤ a * b` but violating the additive bound `a + b ≥ p + 1`.
Hence the additive uncertainty principle is not a formal consequence of the product one. -/
theorem product_bound_does_not_imply_sum_bound (p : ℕ) (hp : 5 ≤ p) :
    ∃ a b : ℕ, 0 < a ∧ 0 < b ∧ p ≤ a * b ∧ a + b < p + 1 := by
  refine ⟨2, (p + 1) / 2, by norm_num, by omega, ?_, by omega⟩
  omega

/-! ## Primality is essential: a counterexample on `ZMod 4` -/

/-- The indicator of the subgroup `{0, 2} ⊆ ZMod 4`. -/
noncomputable def sub2 : ZMod 4 → ℂ := fun x => if x = 0 then 1 else if x = 2 then 1 else 0

@[simp] theorem sub2_zero : sub2 0 = 1 := by
  unfold sub2; rw [if_pos rfl]

@[simp] theorem sub2_one : sub2 1 = 0 := by
  unfold sub2
  rw [if_neg (by decide : ¬((1 : ZMod 4) = 0)), if_neg (by decide : ¬((1 : ZMod 4) = 2))]

@[simp] theorem sub2_two : sub2 2 = 1 := by
  unfold sub2
  rw [if_neg (by decide : ¬((2 : ZMod 4) = 0)), if_pos rfl]

@[simp] theorem sub2_three : sub2 3 = 0 := by
  unfold sub2
  rw [if_neg (by decide : ¬((3 : ZMod 4) = 0)), if_neg (by decide : ¬((3 : ZMod 4) = 2))]

theorem zmod_four_cases (x : ZMod 4) : x = 0 ∨ x = 1 ∨ x = 2 ∨ x = 3 := by revert x; decide

theorem supp_sub2 : supp sub2 = ({0, 2} : Finset (ZMod 4)) := by
  ext x
  rw [mem_supp]
  rcases zmod_four_cases x with rfl | rfl | rfl | rfl <;> simp +decide

/-- `ω^{-2} = -1` in `ZMod 4`: the nontrivial square root of unity. -/
theorem ez_neg_two_four : ez (-2 : ZMod 4) = -1 := by
  have hsq : ez (-2 : ZMod 4) ^ 2 = 1 := by
    rw [pow_two, ← ez_add, show (-2 : ZMod 4) + (-2 : ZMod 4) = 0 from by decide, ez_zero]
  have hne : ez (-2 : ZMod 4) ≠ 1 := by
    intro h
    have h0 : ez (-2 : ZMod 4) = ez (0 : ZMod 4) := by rw [h, ez_zero]
    have h1 := ez_injective h0
    revert h1
    decide
  have hfac : (ez (-2 : ZMod 4) - 1) * (ez (-2 : ZMod 4) + 1) = 0 := by linear_combination hsq
  rcases mul_eq_zero.1 hfac with h | h
  · exact absurd (sub_eq_zero.1 h) hne
  · linear_combination h

theorem dft_sub2 (k : ZMod 4) : dftZMod sub2 k = 1 + ez (-(k * 2)) := by
  rw [dftZMod_eq_sum_ez]
  have hrestrict : ∑ x : ZMod 4, ez (-(k * x)) * sub2 x
      = ∑ x ∈ ({0, 2} : Finset (ZMod 4)), ez (-(k * x)) * sub2 x := by
    refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
    intro x _ hx
    have hcase : ∀ y : ZMod 4, y ∉ ({0, 2} : Finset (ZMod 4)) → y = 1 ∨ y = 3 := by decide
    rcases hcase x hx with rfl | rfl <;> simp
  rw [hrestrict, Finset.sum_pair (by decide : (0 : ZMod 4) ≠ 2)]
  simp

theorem supp_dft_sub2 : supp (dftZMod sub2) = ({0, 2} : Finset (ZMod 4)) := by
  have h0 : (-((0 : ZMod 4) * 2)) = 0 := by decide
  have h1 : (-((1 : ZMod 4) * 2)) = -2 := by decide
  have h2 : (-((2 : ZMod 4) * 2)) = 0 := by decide
  have h3 : (-((3 : ZMod 4) * 2)) = -2 := by decide
  ext x
  rw [mem_supp, dft_sub2]
  rcases zmod_four_cases x with rfl | rfl | rfl | rfl
  · rw [h0, ez_zero]; norm_num
  · rw [h1, ez_neg_two_four]; norm_num; decide
  · rw [h2, ez_zero]; norm_num
  · rw [h3, ez_neg_two_four]; norm_num; decide

/-- **Primality is essential.**  On the composite group `ZMod 4` the indicator of the subgroup
`{0, 2}` has `|supp f| = |supp f̂| = 2`.  The Donoho–Stark product bound is attained with
equality (`2 · 2 = 4`), but the additive bound `|supp f| + |supp f̂| ≥ 4 + 1` fails. -/
theorem sum_bound_fails_zmod_four :
    ∃ f : ZMod 4 → ℂ, f ≠ 0 ∧
      (supp f).card * (supp (dftZMod f)).card = 4 ∧
      (supp f).card + (supp (dftZMod f)).card < 4 + 1 := by
  refine ⟨sub2, ?_, ?_, ?_⟩
  · intro h
    have h0 : sub2 0 = 0 := by rw [h]; rfl
    rw [sub2_zero] at h0
    exact one_ne_zero h0
  · rw [supp_sub2, supp_dft_sub2]; decide
  · rw [supp_sub2, supp_dft_sub2]; decide

/-! ## Sharpness of the additive bound at both ends -/

variable {p : ℕ} [hp : Fact p.Prime]

/-- The DFT of a Dirac delta never vanishes, so `|supp δ_a| + |supp δ̂_a| = 1 + p`: the additive
bound is attained. -/
theorem sum_bound_sharp_delta (a : ZMod p) :
    (supp (delta a)).card + (supp (dftZMod (delta a))).card = p + 1 := by
  classical
  have hd : ∀ k : ZMod p, dftZMod (delta a) k = ez (-(k * a)) := by
    intro k
    rw [dftZMod_eq_sum_ez]
    rw [Finset.sum_eq_single_of_mem a (Finset.mem_univ a)]
    · simp [delta]
    · intro b _ hb
      simp [delta, hb]
  have hsupp : supp (dftZMod (delta a)) = Finset.univ := by
    ext k
    simp only [mem_supp, Finset.mem_univ, iff_true, hd k]
    exact ez_ne_zero _
  rw [hsupp, supp_delta, card_univ_zmod]
  rw [Finset.card_singleton, Nat.add_comm]

/-- The full character sum `∑_{y} ω^{y}` vanishes (`p ≥ 2`). -/
theorem sum_ez_univ_eq_zero : ∑ y : ZMod p, ez y = 0 := by
  classical
  have h1lt : 1 < p := (Fact.out : p.Prime).one_lt
  have hone : om p ≠ 1 := (om_isPrimitiveRoot (p := p)).ne_one h1lt
  have hrange : ∑ y : ZMod p, ez y = ∑ m ∈ range p, om p ^ m := by
    refine Finset.sum_nbij' (fun y => ZMod.val y) (fun m => (m : ZMod p)) ?_ ?_ ?_ ?_ ?_
    · intro y _; exact Finset.mem_range.2 (ZMod.val_lt y)
    · intro m _; exact Finset.mem_univ _
    · intro y _; simp [ZMod.natCast_val, ZMod.cast_id]
    · intro m hm; exact ZMod.val_natCast_of_lt (Finset.mem_range.1 hm)
    · intro y _; rfl
  rw [hrange, geom_sum_eq hone, om_pow_p, sub_self, zero_div]

/-- The DFT of the character `x ↦ ω^{bx}` is `p` times the Dirac delta at `b`. -/
theorem dft_character (b : ZMod p) (k : ZMod p) :
    dftZMod (fun x => ez (b * x)) k = if k = b then (p : ℂ) else 0 := by
  classical
  have hcomb : ∀ x : ZMod p, ez (-(k * x)) * ez (b * x) = ez ((b - k) * x) := by
    intro x
    rw [← ez_add]
    congr 1
    ring
  rw [dftZMod_eq_sum_ez]
  simp_rw [hcomb]
  by_cases hk : k = b
  · subst hk
    simp
  · have hbk : b - k ≠ 0 := sub_ne_zero.2 (Ne.symm hk)
    have hbij : ∑ x : ZMod p, ez ((b - k) * x) = ∑ y : ZMod p, ez y :=
      Fintype.sum_equiv (Equiv.mulLeft₀ (b - k) hbk) _ _ (fun x => rfl)
    rw [hbij, sum_ez_univ_eq_zero, if_neg hk]

/-- **Sharpness at the other end.**  A character has full support and a one-point spectrum, so
`|supp f| + |supp f̂| = p + 1`: the additive bound is attained. -/
theorem sum_bound_sharp_character (b : ZMod p) :
    (supp (fun x : ZMod p => ez (b * x))).card
      + (supp (dftZMod (fun x : ZMod p => ez (b * x)))).card = p + 1 := by
  classical
  have hp : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.2 (NeZero.ne p)
  have hsupp : supp (fun x : ZMod p => ez (b * x)) = Finset.univ := by
    ext x
    simp only [mem_supp, Finset.mem_univ, iff_true]
    exact ez_ne_zero _
  have hspec : supp (dftZMod (fun x : ZMod p => ez (b * x))) = {b} := by
    ext k
    rw [mem_supp, dft_character b k, Finset.mem_singleton]
    by_cases hk : k = b <;> simp [hk, hp]
  rw [hsupp, hspec, card_univ_zmod]
  rw [Finset.card_singleton]

end PrimeUncertainty