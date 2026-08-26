/-
# Synthesis: what the additive uncertainty principle gives, and where it is now known

This file collects the second-cycle consequences of the previous three files.

* `PrimeUncertainty.product_bound_of_sum_bound` : the additive bound *implies* the
  Donoho–Stark product bound (`(a-1)(b-1) ≥ 0`), so the additive statement is a genuine
  strengthening — combined with `product_bound_does_not_imply_sum_bound`, the implication is
  strict in exactly one direction.
* `PrimeUncertainty.four_mul_le_sum_sq` : conversely, the product bound alone only yields
  `|supp f| + |supp f̂| ≥ 2√n`, and this holds for *every* modulus.
* `PrimeUncertainty.sum_bound_of_card_supp_dft_le_two` : the additive bound whenever the
  spectrum has at most two points (dual of the small-support case).
* `PrimeUncertainty.sum_bound_of_regime` : the **master theorem** listing all four regimes in
  which the additive uncertainty principle is proved here.
* `PrimeUncertainty.det_ne_zero_of_card_le_two` : Chebotarev's nonsingularity for all minors
  of size at most two.
-/

import Mathlib
import Catalog.MachineLearning.PrimeUncertainty.Chebotarev

open Finset Polynomial FourierFA FourierCyclic
open scoped Real

namespace PrimeUncertainty

variable {p : ℕ}

/-! ## Comparing the two uncertainty inequalities -/

/-- **The additive bound implies the multiplicative one.**  If `a, b ≥ 1` and `a + b ≥ p + 1`
then `a * b ≥ p`; so Tao's inequality really is a strengthening of Donoho–Stark. -/
theorem product_bound_of_sum_bound {a b p : ℕ} (ha : 1 ≤ a) (hb : 1 ≤ b)
    (hsum : p + 1 ≤ a + b) : p ≤ a * b := by
  obtain ⟨x, rfl⟩ := Nat.exists_eq_add_of_le ha
  obtain ⟨y, rfl⟩ := Nat.exists_eq_add_of_le hb
  nlinarith [Nat.zero_le (x * y)]

/-- Elementary AM–GM in `ℕ`: `4ab ≤ (a+b)²`. -/
theorem four_mul_le_add_sq (x y : ℕ) : 4 * (x * y) ≤ (x + y) ^ 2 := by
  rcases le_total x y with h | h
  · obtain ⟨t, rfl⟩ := Nat.exists_eq_add_of_le h
    nlinarith [Nat.zero_le t]
  · obtain ⟨t, rfl⟩ := Nat.exists_eq_add_of_le h
    nlinarith [Nat.zero_le t]

/-- What the multiplicative bound alone gives: `(|supp f| + |supp f̂|)² ≥ 4n`, i.e. the sum of
the support sizes is at least `2√n`.  This is `o(n)` and hence far weaker than `n + 1`. -/
theorem four_mul_le_sum_sq {n : ℕ} [NeZero n] (f : ZMod n → ℂ) (hf : f ≠ 0) :
    4 * n ≤ ((supp f).card + (supp (dftZMod f)).card) ^ 2 := by
  have hprod := FourierCyclic.uncertainty_zmod f hf
  calc 4 * n ≤ 4 * ((supp f).card * (supp (dftZMod f)).card) := by omega
    _ ≤ ((supp f).card + (supp (dftZMod f)).card) ^ 2 := four_mul_le_add_sq _ _

/-! ## New regimes -/

section Prime

variable [hp : Fact p.Prime]

/-- **Dual small-spectrum case.**  If the spectrum of `f` has at most two points then the
additive bound holds. -/
theorem sum_bound_of_card_supp_dft_le_two (f : ZMod p → ℂ) (hf : f ≠ 0)
    (hcard : (supp (dftZMod f)).card ≤ 2) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  have hg := sum_bound_of_card_supp_le_two (dftZMod f) (dft_ne_zero f hf) hcard
  rw [card_supp_dft_dft f] at hg
  omega

/-- If the spectrum is a single point then `f` is (a multiple of) a character, so its support is
everything.  In particular the additive bound is attained. -/
theorem card_supp_eq_of_card_supp_dft_eq_one (f : ZMod p → ℂ) (hf : f ≠ 0)
    (hcard : (supp (dftZMod f)).card = 1) : (supp f).card = p := by
  have h := sum_bound_of_card_supp_dft_le_two f hf (by omega)
  have hle : (supp f).card ≤ p := by
    calc (supp f).card ≤ (Finset.univ : Finset (ZMod p)).card := Finset.card_le_card (subset_univ _)
      _ = p := card_univ_zmod
  omega

/-- **Master theorem.**  The additive uncertainty principle `|supp f| + |supp f̂| ≥ p + 1` is
established here in four regimes: small support, small spectrum, support an arithmetic
progression, spectrum an arithmetic progression. -/
theorem sum_bound_of_regime (f : ZMod p → ℂ) (hf : f ≠ 0)
    (h : (supp f).card ≤ 2 ∨ (supp (dftZMod f)).card ≤ 2 ∨
      (∃ a d : ZMod p, ∃ m : ℕ, d ≠ 0 ∧ m ≤ p ∧
        supp f = (range m).image (fun j : ℕ => a + (j : ZMod p) * d)) ∨
      (∃ a d : ZMod p, ∃ m : ℕ, d ≠ 0 ∧ m ≤ p ∧
        supp (dftZMod f) = (range m).image (fun j : ℕ => a + (j : ZMod p) * d))) :
    p + 1 ≤ (supp f).card + (supp (dftZMod f)).card := by
  rcases h with h | h | ⟨a, d, m, hd, hm, hAP⟩ | ⟨a, d, m, hd, hm, hAP⟩
  · exact sum_bound_of_card_supp_le_two f hf h
  · exact sum_bound_of_card_supp_dft_le_two f hf h
  · exact sum_bound_of_supp_eq_AP f hf a d hd m hm hAP
  · exact sum_bound_of_supp_dft_eq_AP f hf a d hd m hm hAP

/-! ## Chebotarev for small minors -/

/-- Every minor of the DFT matrix of size at most two is nonsingular. -/
theorem det_ne_zero_of_card_le_two {n : ℕ} (hn : n ≤ 2) (S T : Fin n → ZMod p)
    (hS : Function.Injective S) (hT : Function.Injective T) :
    (Matrix.of fun j k : Fin n => ez (S j * T k)).det ≠ 0 := by
  interval_cases n
  · simp
  · rw [Matrix.det_fin_one]
    exact ez_ne_zero _
  · have hne : S 1 ≠ S 0 := fun h => by
      have := hS h
      revert this
      decide
    have hd : S 1 - S 0 ≠ 0 := sub_ne_zero.2 hne
    have hEq : (Matrix.of fun j k : Fin 2 => ez (S j * T k))
        = (Matrix.of (fun j k : Fin 2 =>
            ez ((S 0 + ((j : ℕ) : ZMod p) * (S 1 - S 0)) * T k))) := by
      ext j k
      fin_cases j
      · norm_num
      · norm_num
    rw [hEq]
    exact det_ne_zero_of_AP_rows (S 0) (S 1 - S 0) hd T hT

end Prime

end PrimeUncertainty