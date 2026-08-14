/-
# Capacity of a binary fork: one bit, attained exactly at the balanced coset forks

`ForkPinningCore` proves the two capacity bounds `I(X;Y) ≤ H Y` and `I(X;Y) ≤ log |κ|`.  For a
*binary* fork these combine into the hard ceiling `I ≤ log 2`: no congruence observable, however
large its conductor, can extract more than one bit from a two-valued splitting statistic.  This
file closes conjecture **C2** of `FUTURE_DIRECTIONS.md` by determining exactly when the ceiling
is attained.

Main results:

* `ForkPinning.entropy_bool_eq_log_two_iff` : `H Y = log 2` iff the fork is balanced (the strict
  maximum-entropy statement for two-valued statistics).
* `ForkPinning.mutualInfo_bool_le_log_two` : the one-bit ceiling.
* `ForkPinning.capacity_attained_iff` : `I(X;Y) = log 2` **iff** `X` determines `Y` *and* `Y` is
  balanced — capacity is attained exactly at the balanced forks that the observable pins.
* `ForkPinning.prb_hom_uniform` : a surjective character is uniformly distributed on a uniform
  group (the counting input).
* `ForkPinning.prb_signBool_true` : the sign of a uniformly random permutation of `Fin n`,
  `n ≥ 2`, is balanced.
* `ForkPinning.sign_attains_capacity` and `ForkPinning.sign_capacity_attained_iff` : for `Sₙ`
  the supremum `log 2` is attained, and *only* by the two forks `sign` and `¬sign` — the exact
  formal counterpart of the measurement "the only congruence structure in the whole `S₄`
  splitting is the sign".
-/

import Probability.ForkPinningGalois

namespace ForkPinning

open Finset Real

/-! ## The strict maximum-entropy statement for binary forks -/

section BoolEntropy

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

lemma prb_true_add_false (Y : Ω → Bool) : prb Y true + prb Y false = 1 := by
  have h := sum_prb Y
  simpa [Fintype.sum_bool, add_comm] using h

/-- One term of the max-entropy comparison, in strict form away from the balanced point. -/
lemma negMulLog_sub_half_lt {p : ℝ} (hp : 0 ≤ p) (hne : p ≠ 1 / 2) :
    negMulLog p - p * Real.log 2 < 1 / 2 - p := by
  rcases eq_or_lt_of_le hp with h0 | h0
  · rw [← h0]
    simp only [negMulLog_zero, zero_mul, sub_zero]
    norm_num
  · have hx : 1 / (2 * p) ≠ 1 := by
      intro hx
      apply hne
      field_simp at hx
      linarith
    have hlog : Real.log (1 / (2 * p)) < 1 / (2 * p) - 1 :=
      Real.log_lt_sub_one_of_pos (by positivity) hx
    have hid : negMulLog p - p * Real.log 2 = p * Real.log (1 / (2 * p)) := by
      rw [Real.log_div one_ne_zero (by positivity),
        Real.log_mul (by norm_num) (ne_of_gt h0), Real.log_one, negMulLog]
      ring
    have hmul := mul_lt_mul_of_pos_left hlog h0
    have hfield : p * (1 / (2 * p) - 1) = 1 / 2 - p := by field_simp
    rw [hid]
    nlinarith [hmul, hfield]

/-- One term of the max-entropy comparison, non-strict form. -/
lemma negMulLog_sub_half_le {p : ℝ} (hp : 0 ≤ p) :
    negMulLog p - p * Real.log 2 ≤ 1 / 2 - p := by
  rcases eq_or_ne p (1 / 2) with h | h
  · subst h
    have : negMulLog (1 / 2 : ℝ) = (1 / 2) * Real.log 2 := by
      rw [negMulLog, Real.log_div one_ne_zero (by norm_num), Real.log_one]
      ring
    rw [this]
    norm_num
  · exact le_of_lt (negMulLog_sub_half_lt hp h)

/-- **Strict maximum entropy for a two-valued statistic.**  An unbalanced fork has entropy
strictly below one bit. -/
theorem entropy_bool_lt_log_two (Y : Ω → Bool) (hne : prb Y true ≠ 1 / 2) :
    H Y < Real.log 2 := by
  have hsum := prb_true_add_false Y
  have ht := negMulLog_sub_half_lt (prb_nonneg Y true) hne
  have hf := negMulLog_sub_half_le (prb_nonneg Y false)
  have hH : H Y = negMulLog (prb Y false) + negMulLog (prb Y true) := H_bool Y
  have hlog : prb Y true * Real.log 2 + prb Y false * Real.log 2 = Real.log 2 := by
    rw [← add_mul, hsum, one_mul]
  linarith [ht, hf, hH, hsum, hlog]

/-- **Balanced forks, and only they, carry a full bit.** -/
theorem entropy_bool_eq_log_two_iff (Y : Ω → Bool) :
    H Y = Real.log 2 ↔ prb Y true = 1 / 2 := by
  constructor
  · intro hH
    by_contra hne
    exact absurd hH (ne_of_lt (entropy_bool_lt_log_two Y hne))
  · intro hbal
    have hf : prb Y false = 1 / 2 := by
      have := prb_true_add_false Y
      linarith [hbal]
    have hhalf : negMulLog (1 / 2 : ℝ) = (1 / 2) * Real.log 2 := by
      rw [negMulLog, Real.log_div one_ne_zero (by norm_num), Real.log_one]
      ring
    rw [H_bool Y, hbal, hf, hhalf]
    ring

end BoolEntropy

/-! ## The one-bit ceiling and its attainment -/

section Capacity

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]
variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- **The one-bit ceiling.**  No observable extracts more than one bit from a binary fork. -/
theorem mutualInfo_bool_le_log_two (X : Ω → κ) (Y : Ω → Bool) :
    mutualInfo X Y ≤ Real.log 2 := by
  refine le_trans (mutualInfo_le_entropy X Y) ?_
  have hcard : (Fintype.card Bool : ℝ) = 2 := by norm_num
  have := entropy_le_log_card (Ω := Ω) Y
  rwa [hcard] at this

/-- **C2, attainment.**  The capacity `log 2` is reached exactly at the balanced forks that the
observable determines. -/
theorem capacity_attained_iff (X : Ω → κ) (Y : Ω → Bool) :
    mutualInfo X Y = Real.log 2 ↔ Determines X Y ∧ prb Y true = 1 / 2 := by
  constructor
  · intro hI
    have hHY : H Y ≤ Real.log 2 := by
      have hcard : (Fintype.card Bool : ℝ) = 2 := by norm_num
      have := entropy_le_log_card (Ω := Ω) Y
      rwa [hcard] at this
    have hle : mutualInfo X Y ≤ H Y := mutualInfo_le_entropy X Y
    have hHeq : H Y = Real.log 2 := le_antisymm hHY (by rw [← hI]; exact hle)
    refine ⟨(pinned_iff_determines X Y).mp (by rw [hI, hHeq]), ?_⟩
    exact (entropy_bool_eq_log_two_iff Y).mp hHeq
  · rintro ⟨hdet, hbal⟩
    rw [(pinned_iff_determines X Y).mpr hdet]
    exact (entropy_bool_eq_log_two_iff Y).mpr hbal

end Capacity

/-! ## Surjective characters are uniform -/

section Uniform

variable {G : Type*} [Group G] [Fintype G] [Nonempty G]
variable {A : Type*} [Group A] [Fintype A] [DecidableEq A]

omit [Nonempty G] [Fintype A] in
/-- Left translation carries one fibre of a homomorphism onto another. -/
lemma card_fiber_hom_eq (f : G →* A) {a b : A} (g₀ : G) (hg₀ : f g₀ = b * a⁻¹) :
    (fiber (fun g : G => f g) a).card = (fiber (fun g : G => f g) b).card := by
  refine Finset.card_bij (fun g _ => g₀ * g) (fun g hg => ?_) (fun g _ g' _ h => ?_)
    (fun g hg => ?_)
  · simp only [fiber, mem_filter, mem_univ, true_and] at hg ⊢
    rw [map_mul, hg₀, hg]
    group
  · exact mul_left_cancel h
  · refine ⟨g₀⁻¹ * g, ?_, by group⟩
    simp only [fiber, mem_filter, mem_univ, true_and] at hg ⊢
    rw [map_mul, map_inv, hg₀, hg]
    group

/-- **A surjective character of a finite group is uniformly distributed.** -/
theorem prb_hom_uniform (f : G →* A) (hf : Function.Surjective f) (a : A) :
    prb (fun g : G => f g) a = 1 / Fintype.card A := by
  have hconst : ∀ b : A, prb (fun g : G => f g) b = prb (fun g : G => f g) a := by
    intro b
    obtain ⟨g₀, hg₀⟩ := hf (a * b⁻¹)
    rw [prb, prb, card_fiber_hom_eq f g₀ hg₀]
  have hsum : ∑ b : A, prb (fun g : G => f g) b = 1 := sum_prb _
  rw [Finset.sum_congr rfl (fun b _ => hconst b), Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul] at hsum
  have hA : (0 : ℝ) < Fintype.card A := by exact_mod_cast Fintype.card_pos
  field_simp at hsum ⊢
  linarith [hsum]

end Uniform

/-! ## The sign character attains the capacity, and nothing else does -/

section Sign

variable {n : ℕ}

/-- For `n ≥ 2` the sign of a uniformly random permutation is a balanced fork. -/
theorem prb_signBool_true (hn : 2 ≤ n) :
    prb (signBool : Equiv.Perm (Fin n) → Bool) true = 1 / 2 := by
  haveI : Nontrivial (Fin n) :=
    ⟨⟨⟨0, by omega⟩, ⟨1, by omega⟩, by simp [Fin.ext_iff]⟩⟩
  have hfib : fiber (signBool : Equiv.Perm (Fin n) → Bool) true
      = fiber (fun σ : Equiv.Perm (Fin n) => Equiv.Perm.sign σ) 1 := by
    ext σ
    simp [fiber, signBool]
  have hcard : Fintype.card ℤˣ = 2 := by decide
  rw [prb, hfib, ← prb, prb_hom_uniform (Equiv.Perm.sign : Equiv.Perm (Fin n) →* ℤˣ)
    (Equiv.Perm.sign_surjective (Fin n)) 1, hcard]
  norm_num

/-- **The capacity is attained by the sign character.** -/
theorem sign_attains_capacity (hn : 2 ≤ n) :
    mutualInfo (signBool : Equiv.Perm (Fin n) → Bool)
      (signBool : Equiv.Perm (Fin n) → Bool) = Real.log 2 :=
  (capacity_attained_iff _ _).mpr ⟨fun _ _ h => h, prb_signBool_true hn⟩

/-- A fork determined by the sign is one of the four sign-measurable forks; balancedness rules
out the two constant ones. -/
theorem sign_determined_balanced (hn : 2 ≤ n) (Y : Equiv.Perm (Fin n) → Bool)
    (hdet : Determines (signBool : Equiv.Perm (Fin n) → Bool) Y)
    (hbal : prb Y true = 1 / 2) :
    Y = (signBool : Equiv.Perm (Fin n) → Bool) ∨
      Y = fun σ : Equiv.Perm (Fin n) => !(signBool σ) := by
  haveI : Nontrivial (Fin n) :=
    ⟨⟨⟨0, by omega⟩, ⟨1, by omega⟩, by simp [Fin.ext_iff]⟩⟩
  set τ : Equiv.Perm (Fin n) := Equiv.swap (⟨0, by omega⟩ : Fin n) ⟨1, by omega⟩ with hτdef
  have hone : (signBool : Equiv.Perm (Fin n) → Bool) 1 = true := by
    simp [signBool]
  have hτ : (signBool : Equiv.Perm (Fin n) → Bool) τ = false := by
    have hsign : Equiv.Perm.sign τ = -1 := by
      rw [hτdef, Equiv.Perm.sign_swap]
      simp [Fin.ext_iff]
    simp [signBool, hsign]
  have hval : ∀ σ : Equiv.Perm (Fin n), Y σ = if signBool σ then Y 1 else Y τ := by
    intro σ
    by_cases hs : signBool σ = true
    · rw [if_pos hs]
      exact hdet σ 1 (by rw [hs, hone])
    · have hs' : signBool σ = false := by simpa using hs
      rw [if_neg (by simp [hs'])]
      exact hdet σ τ (by rw [hs', hτ])
  have hfalse : prb (fun _ : Equiv.Perm (Fin n) => false) true = 0 := by
    rw [prb, fiber_const_ne (by simp)]
    simp
  have htrue : prb (fun _ : Equiv.Perm (Fin n) => true) true = 1 := by
    have hpos : (0 : ℝ) < Fintype.card (Equiv.Perm (Fin n)) := by
      exact_mod_cast Fintype.card_pos
    rw [prb, fiber_const_self]
    simp only [Finset.card_univ]
    field_simp
  cases h1 : Y 1 <;> cases h2 : Y τ
  · -- `Y` is constantly `false`, contradicting balancedness
    exfalso
    have hconst : Y = fun _ => false := by
      funext σ
      rw [hval σ, h1, h2]
      simp
    rw [hconst, hfalse] at hbal
    norm_num at hbal
  · right
    funext σ
    rw [hval σ, h1, h2]
    simp
  · left
    funext σ
    rw [hval σ, h1, h2]
    simp
  · -- `Y` is constantly `true`, contradicting balancedness
    exfalso
    have hconst : Y = fun _ => true := by
      funext σ
      rw [hval σ, h1, h2]
      simp
    rw [hconst, htrue] at hbal
    norm_num at hbal

/-- **C2, closed for the symmetric group.**  The sign character's capacity `log 2` is attained
by exactly two forks: the sign itself and its negation. -/
theorem sign_capacity_attained_iff (hn : 2 ≤ n) (Y : Equiv.Perm (Fin n) → Bool) :
    mutualInfo (signBool : Equiv.Perm (Fin n) → Bool) Y = Real.log 2
      ↔ (Y = (signBool : Equiv.Perm (Fin n) → Bool) ∨
          Y = fun σ : Equiv.Perm (Fin n) => !(signBool σ)) := by
  constructor
  · intro hI
    obtain ⟨hdet, hbal⟩ := (capacity_attained_iff _ _).mp hI
    exact sign_determined_balanced hn Y hdet hbal
  · intro hY
    refine (capacity_attained_iff _ _).mpr ⟨?_, ?_⟩
    · rcases hY with rfl | rfl
      · exact fun _ _ h => h
      · exact fun _ _ h => by simp [h]
    · rcases hY with rfl | rfl
      · exact prb_signBool_true hn
      · have hfib : fiber (fun σ : Equiv.Perm (Fin n) => !(signBool σ)) true
            = fiber (signBool : Equiv.Perm (Fin n) → Bool) false := by
          ext σ
          simp [fiber]
        have hsum := prb_true_add_false (signBool : Equiv.Perm (Fin n) → Bool)
        rw [prb, hfib, ← prb]
        have := prb_signBool_true (n := n) hn
        linarith [hsum]

end Sign

end ForkPinning