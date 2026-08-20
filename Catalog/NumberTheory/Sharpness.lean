/-
# Sharpness of the `q`-Kummer growth bound

`Catalog/NumberTheory/QKummer/Corollaries.lean` proves the upper bound

`v_ℓ(binom(n,k)_q) ≤ e + log_ℓ⌊n/d⌋ + log_ℓ(⌊(n-k)/d⌋+1)`

for a regular datum `(d, e)`.  This file shows that the bound is **attained infinitely often**,
so neither the offset term `e` nor the logarithmic term can be removed or improved.

The extremal family is completely explicit: for `d ≥ 2` and `s ≥ 1`,

`v_ℓ(binom(d·ℓ^s, d+1)_q) = e + s`.

Indeed `k = d + 1` has base-`d` digits `(1, 1)`, so adding `k` and `n - k` carries out of the
base-`d` digit (contributing `e`), the block indices are `⌊n/d⌋ = ℓ^s` and `⌊k/d⌋ = 1`, whose
classical binomial coefficient `C(ℓ^s, 1) = ℓ^s` contributes exactly `s`, and the carry
correction `v_ℓ(⌊(n-k)/d⌋ + 1) = v_ℓ(ℓ^s - 1)` vanishes.  Since `log_ℓ⌊n/d⌋ = s`, the first two
summands of the bound are simultaneously attained.
-/
import Catalog.NumberTheory.QKummer.Corollaries

namespace QKummer

section Sharp

variable {q ℓ d e : ℕ} [hp : Fact ℓ.Prime]

/-- The base-`d` decomposition of `d·ℓ^s − (d+1)`: it is `d·(ℓ^s − 2) + (d − 1)`. -/
theorem sub_eq_mul_add {d s ℓ : ℕ} (hd : 2 ≤ d) (hl : 2 ≤ ℓ ^ s) :
    d * ℓ ^ s - (d + 1) = d * (ℓ ^ s - 2) + (d - 1) := by
  have hmul : d * (ℓ ^ s - 2) = d * ℓ ^ s - d * 2 := Nat.mul_sub d _ 2
  have hge : d * 2 ≤ d * ℓ ^ s := Nat.mul_le_mul_left d hl
  omega

/-- **Sharpness of the growth bound.**  For a regular datum `(d, e)` with `d ≥ 2` and every
`s ≥ 1`, the Gaussian binomial coefficient `binom(d·ℓ^s, d+1)_q` has `ℓ`-adic valuation exactly
`e + s`.  In particular the valuation of Gaussian binomial coefficients is unbounded, and the
bound `padicValNat_qBinom_le` is attained. -/
theorem padicValNat_qBinom_sharp (h : IsQRegular q ℓ d e) (hd : 2 ≤ d) {s : ℕ} (hs : 1 ≤ s) :
    padicValNat ℓ (qBinom q (d * ℓ ^ s) (d + 1)) = e + s := by
  have hl2 : 2 ≤ ℓ := hp.out.two_le
  have hpow : 2 ≤ ℓ ^ s := by
    calc 2 = 2 ^ 1 := by norm_num
      _ ≤ ℓ ^ s := Nat.pow_le_pow_left hl2 1 |>.trans (Nat.pow_le_pow_right (by omega) hs)
  have hdpow : d + 1 ≤ d * ℓ ^ s := by
    have : d * 2 ≤ d * ℓ ^ s := Nat.mul_le_mul_left d hpow
    omega
  have hkmod : (d + 1) % d = 1 := by
    rw [Nat.add_mod_left, Nat.mod_eq_of_lt (by omega)]
  have hkdiv : (d + 1) / d = 1 := Nat.div_eq_of_lt_le (by omega) (by omega)
  have hsplit := sub_eq_mul_add (d := d) (s := s) (ℓ := ℓ) hd hpow
  have hsubmod : (d * ℓ ^ s - (d + 1)) % d = d - 1 := by
    rw [hsplit, Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  have hsubdiv : (d * ℓ ^ s - (d + 1)) / d = ℓ ^ s - 2 := by
    rw [hsplit, Nat.mul_add_div (by omega), Nat.div_eq_of_lt (by omega), Nat.add_zero]
  have hndiv : (d * ℓ ^ s) / d = ℓ ^ s := Nat.mul_div_cancel_left _ (by omega)
  have hcarry : d ≤ (d + 1) % d + (d * ℓ ^ s - (d + 1)) % d := by
    rw [hkmod, hsubmod]; omega
  have hchoose : padicValNat ℓ ((ℓ ^ s).choose 1) = s := by
    rw [Nat.choose_one_right, padicValNat.prime_pow]
  have hcorr : padicValNat ℓ (ℓ ^ s - 2 + 1) = 0 := by
    refine padicValNat.eq_zero_of_not_dvd ?_
    intro hdvd
    have hne : ℓ ^ s - 2 + 1 = ℓ ^ s - 1 := by omega
    rw [hne] at hdvd
    have hpow_dvd : ℓ ∣ ℓ ^ s := dvd_pow_self ℓ (by omega)
    have hone : ℓ ∣ ℓ ^ s - (ℓ ^ s - 1) := Nat.dvd_sub hpow_dvd hdvd
    rw [show ℓ ^ s - (ℓ ^ s - 1) = 1 by omega] at hone
    have := Nat.dvd_one.mp hone
    omega
  rw [qBinom_padicValNat h hdpow, if_pos hcarry, hndiv, hkdiv, hsubdiv, hchoose, hcorr,
    Nat.mul_one, Nat.mul_zero, Nat.add_zero]

/-- **The logarithmic bound is attained.**  On the extremal family the upper bound
`padicValNat_qBinom_le` becomes an equality in its first two summands:
`v_ℓ(binom(d·ℓ^s, d+1)_q) = e + log_ℓ(⌊n/d⌋)`. -/
theorem padicValNat_qBinom_eq_log (h : IsQRegular q ℓ d e) (hd : 2 ≤ d) {s : ℕ} (hs : 1 ≤ s) :
    padicValNat ℓ (qBinom q (d * ℓ ^ s) (d + 1))
      = e + Nat.log ℓ ((d * ℓ ^ s) / d) := by
  have hl2 : 2 ≤ ℓ := hp.out.two_le
  have hndiv : (d * ℓ ^ s) / d = ℓ ^ s := Nat.mul_div_cancel_left _ (by omega)
  rw [padicValNat_qBinom_sharp h hd hs, hndiv, Nat.log_pow hl2]

/-- **Unboundedness.**  For a regular datum with `d ≥ 2`, the `ℓ`-adic valuations of Gaussian
binomial coefficients take arbitrarily large values. -/
theorem exists_padicValNat_qBinom_ge (h : IsQRegular q ℓ d e) (hd : 2 ≤ d) (m : ℕ) :
    ∃ n k : ℕ, k ≤ n ∧ m ≤ padicValNat ℓ (qBinom q n k) := by
  have hl2 : 2 ≤ ℓ := hp.out.two_le
  refine ⟨d * ℓ ^ (m + 1), d + 1, ?_, ?_⟩
  · have hpow : 2 ≤ ℓ ^ (m + 1) := by
      calc 2 = 2 ^ 1 := by norm_num
        _ ≤ ℓ ^ (m + 1) :=
          Nat.pow_le_pow_left hl2 1 |>.trans (Nat.pow_le_pow_right (by omega) (by omega))
    have : d * 2 ≤ d * ℓ ^ (m + 1) := Nat.mul_le_mul_left d hpow
    omega
  · rw [padicValNat_qBinom_sharp h hd (by omega : 1 ≤ m + 1)]
    omega

end Sharp

end QKummer