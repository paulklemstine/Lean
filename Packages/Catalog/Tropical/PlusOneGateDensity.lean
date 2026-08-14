import Mathlib
import Tropical.PlusOneWilliamsCore

/-!
# Density of the discriminant gate: exactly half the bases work

The round-16 experiment observed that the Williams `p + 1` method succeeds
exactly on the instances with `(D | p) = -1`, where `D = P² - 4`. This file
answers the immediate follow-up question: *how many bases open the gate at a
given prime?*

The answer is exactly half of them. Writing `A_p = {P ∈ 𝔽_p : P² - 4 is a
square}` for the set of *bad* bases, the trace parametrisation
`P = a + a⁻¹` identifies `A_p` with the image of `𝔽_p^×` under a map that is
two-to-one away from `a = ±1`, giving

* `card_disc_square` : `#A_p = (p + 1)/2`,
* `card_gate_open`  : `#{P : P² - 4 is a non-residue} = (p - 1)/2`.

So a random base opens the gate with probability `(p-1)/(2p) → 1/2`, and the
three classical bases `3, 5, 7` cannot do better than `3/4` (not `7/8`) because
`D₃ = 5` and `D₇ = 45` share a square class
(`PlusOneWilliams.legendreSym_mul_sq`).
-/

namespace PlusOneGateDensity

open Finset PlusOneWilliams

/-- **Half the bases are bad.** For an odd prime `p`, the discriminant
`P² - 4` is a square for exactly `(p+1)/2` of the `p` bases `P ∈ 𝔽_p`. -/
theorem card_disc_square (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    (univ.filter (fun P : ZMod p => IsSquare (P ^ 2 - 4))).card = (p + 1) / 2 := by
  classical
  have hp' : p.Prime := Fact.out
  have hodd : p % 2 = 1 := hp'.eq_two_or_odd.resolve_left hp2
  have hp3 : 3 ≤ p := by
    have := hp'.two_le
    omega
  have h2ne : (2 : ZMod p) ≠ 0 := by
    have h2 : ((2 : ℕ) : ZMod p) ≠ 0 := by
      rw [Ne, ZMod.natCast_eq_zero_iff]
      intro h
      exact hp2 ((Nat.prime_dvd_prime_iff_eq hp' Nat.prime_two).mp h)
    simpa using h2
  have h4ne : (4 : ZMod p) ≠ 0 := by
    intro h
    exact h2ne (by
      have : (2 : ZMod p) * 2 = 0 := by rw [show (2 : ZMod p) * 2 = 4 by ring, h]
      rcases mul_eq_zero.mp this with h' | h' <;> exact h')
  set A : Finset (ZMod p) := univ.filter (fun P : ZMod p => IsSquare (P ^ 2 - 4)) with hA
  set S : Finset (ZMod p) := univ.filter (fun a : ZMod p => a ≠ 0) with hS
  have hmemS : ∀ x : ZMod p, x ∈ S ↔ x ≠ 0 := by intro x; simp [hS]
  have hmemA : ∀ P : ZMod p, P ∈ A ↔ IsSquare (P ^ 2 - 4) := by intro P; simp [hA]
  -- the trace map
  set g : ZMod p → ZMod p := fun a => a + a⁻¹ with hg
  -- every trace is a bad base
  have himg : ∀ a : ZMod p, a ≠ 0 → IsSquare ((g a) ^ 2 - 4) := by
    intro a ha
    refine ⟨a - a⁻¹, ?_⟩
    have hai : a * a⁻¹ = 1 := mul_inv_cancel₀ ha
    show (a + a⁻¹) ^ 2 - 4 = (a - a⁻¹) * (a - a⁻¹)
    linear_combination 4 * hai
  -- every bad base is a trace
  have hroot : ∀ P : ZMod p, IsSquare (P ^ 2 - 4) → ∃ a : ZMod p, a ≠ 0 ∧ g a = P := by
    intro P hPs
    obtain ⟨t, ht⟩ := hPs
    have ht2 : t ^ 2 = P ^ 2 - 4 := by rw [ht]; ring
    obtain ⟨a, b, hab, hsum⟩ := roots_of_disc_sqrt p hp2 P t ht2
    have ha0 : a ≠ 0 := by
      intro h; rw [h, zero_mul] at hab; exact zero_ne_one hab
    refine ⟨a, ha0, ?_⟩
    show a + a⁻¹ = P
    rw [inv_eq_of_mul_eq_one_right hab]
    exact hsum
  have himage : S.image g = A := by
    ext P
    simp only [Finset.mem_image, hmemA]
    constructor
    · rintro ⟨a, haS, rfl⟩
      exact himg a ((hmemS a).mp haS)
    · intro hP
      obtain ⟨a, ha0, hga⟩ := hroot P hP
      exact ⟨a, (hmemS a).mpr ha0, hga⟩
  -- the fibres
  have hfib : ∀ P ∈ A, (S.filter (fun a => g a = P)).card
      = if P = 2 ∨ P = -2 then 1 else 2 := by
    intro P hP
    obtain ⟨a, ha0, hga⟩ := hroot P ((hmemA P).mp hP)
    have hai : a * a⁻¹ = 1 := mul_inv_cancel₀ ha0
    have hia0 : a⁻¹ ≠ 0 := inv_ne_zero ha0
    have hset : S.filter (fun x => g x = P) = {a, a⁻¹} := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton, hmemS]
      constructor
      · rintro ⟨hx0, hgx⟩
        have hxi : x * x⁻¹ = 1 := mul_inv_cancel₀ hx0
        have h2 : x * x + 1 = x * P := by
          have h1 : x * (x + x⁻¹) = x * P := by rw [show x + x⁻¹ = P from hgx]
          rw [← h1]; linear_combination -hxi
        have key : (x - a) * (x - a⁻¹) = 0 := by
          have h3 : (x - a) * (x - a⁻¹) = x * x - (a + a⁻¹) * x + a * a⁻¹ := by ring
          rw [h3, hai, show a + a⁻¹ = P from hga]
          linear_combination h2
        rcases mul_eq_zero.mp key with h | h
        · exact Or.inl (sub_eq_zero.mp h)
        · exact Or.inr (sub_eq_zero.mp h)
      · rintro (rfl | rfl)
        · exact ⟨ha0, hga⟩
        · refine ⟨hia0, ?_⟩
          show a⁻¹ + a⁻¹⁻¹ = P
          rw [inv_inv, add_comm]
          exact hga
    rw [hset]
    by_cases hcase : P = 2 ∨ P = -2
    · rw [if_pos hcase]
      have hinv : a⁻¹ = a := by
        rcases hcase with rfl | rfl
        · have hsq : (a - 1) * (a - 1) = 0 := by
            have h1 : a + a⁻¹ = 2 := hga
            have h2 : a * a + 1 = a * 2 := by
              have := congrArg (fun z => a * z) h1
              simp only at this
              rw [← this]; linear_combination -hai
            linear_combination h2
          have ha1 : a = 1 := by
            rcases mul_eq_zero.mp hsq with h | h <;> exact sub_eq_zero.mp h
          rw [ha1, inv_one]
        · have hsq : (a + 1) * (a + 1) = 0 := by
            have h1 : a + a⁻¹ = -2 := hga
            have h2 : a * a + 1 = a * (-2) := by
              have := congrArg (fun z => a * z) h1
              simp only at this
              rw [← this]; linear_combination -hai
            linear_combination h2
          have ha1 : a = -1 := by
            rcases mul_eq_zero.mp hsq with h | h <;>
              · have := eq_neg_of_add_eq_zero_left h
                simpa using this
          rw [ha1]
          simp
      rw [hinv]
      simp
    · rw [if_neg hcase]
      have hne : a ≠ a⁻¹ := by
        intro h
        have hsq : a * a = 1 := by nth_rewrite 2 [h]; exact hai
        have hP2 : P = 2 ∨ P = -2 := by
          have h1 : (a - 1) * (a + 1) = 0 := by linear_combination hsq
          have hval : a + a⁻¹ = P := hga
          rcases mul_eq_zero.mp h1 with h2 | h2
          · left
            have ha1 : a = 1 := sub_eq_zero.mp h2
            rw [ha1, inv_one] at hval
            rw [← hval]; norm_num
          · right
            have ha1 : a = -1 := by
              have h3 := eq_neg_of_add_eq_zero_left h2
              simpa using h3
            rw [ha1, show ((-1 : ZMod p))⁻¹ = -1 from by simp] at hval
            rw [← hval]; norm_num
        exact hcase hP2
      rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
  -- counting: the fibres of the trace map partition `𝔽_p^×`
  have hScard : S.card = p - 1 := by
    have h : S = univ.erase 0 := by ext a; simp [hS, Finset.mem_erase]
    rw [h, Finset.card_erase_of_mem (Finset.mem_univ 0), Finset.card_univ, ZMod.card]
  have hcard : S.card = ∑ P ∈ A, (S.filter (fun a => g a = P)).card := by
    rw [← himage]
    exact Finset.card_eq_sum_card_image g S
  have hsum : ∑ P ∈ A, (S.filter (fun a => g a = P)).card
      = ∑ P ∈ A, (if P = 2 ∨ P = -2 then 1 else 2) := Finset.sum_congr rfl hfib
  have hmem2 : (2 : ZMod p) ∈ A := (hmemA 2).mpr ⟨0, by norm_num⟩
  have hmemn2 : (-2 : ZMod p) ∈ A := (hmemA (-2)).mpr ⟨0, by norm_num⟩
  have h2n2 : (2 : ZMod p) ≠ -2 := by
    intro h
    exact h4ne (by linear_combination h)
  have hspecial : A.filter (fun P => P = 2 ∨ P = -2) = {2, -2} := by
    ext P
    simp only [Finset.mem_filter, Finset.mem_insert, Finset.mem_singleton]
    constructor
    · rintro ⟨-, h⟩; exact h
    · rintro (rfl | rfl)
      · exact ⟨hmem2, Or.inl rfl⟩
      · exact ⟨hmemn2, Or.inr rfl⟩
  have hspecialcard : (A.filter (fun P => P = 2 ∨ P = -2)).card = 2 := by
    rw [hspecial, Finset.card_insert_of_notMem (by simpa using h2n2), Finset.card_singleton]
  have hsplit : (A.filter (fun P => P = 2 ∨ P = -2)).card
      + (A.filter (fun P => ¬ (P = 2 ∨ P = -2))).card = A.card :=
    Finset.card_filter_add_card_filter_not _
  rw [hcard, hsum, Finset.sum_ite, Finset.sum_const, Finset.sum_const, smul_eq_mul,
    smul_eq_mul, hspecialcard] at hScard
  omega

/-- **Half the bases open the gate.** For an odd prime `p` the discriminant
`P² - 4` is a non-residue for exactly `(p-1)/2` of the `p` bases, so a random
base makes the Williams method work at `p` with probability `(p-1)/(2p)`. -/
theorem card_gate_open (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2) :
    (univ.filter (fun P : ZMod p => ¬ IsSquare (P ^ 2 - 4))).card = (p - 1) / 2 := by
  classical
  have hp' : p.Prime := Fact.out
  have hodd : p % 2 = 1 := hp'.eq_two_or_odd.resolve_left hp2
  have hp3 : 3 ≤ p := by
    have := hp'.two_le
    omega
  have h := Finset.card_filter_add_card_filter_not (s := (univ : Finset (ZMod p)))
    (fun P => IsSquare (P ^ 2 - 4))
  rw [card_disc_square p hp2, Finset.card_univ, ZMod.card] at h
  omega

/-- Sanity check at `p = 11`: six of the eleven bases are bad, five open the
gate, matching `(p+1)/2 = 6` and `(p-1)/2 = 5`. -/
theorem card_disc_square_eleven :
    (univ.filter (fun P : ZMod 11 => IsSquare (P ^ 2 - 4))).card = 6 := by decide

end PlusOneGateDensity