import Mathlib

/-!
# A toolkit for decimal digit sequences of real numbers

This file develops the elementary but missing infrastructure needed to reason about the
*decimal expansion* of a real number, on top of `Real.ofDigits` / `Real.digits`
(`Mathlib/Analysis/Real/OfDigits.lean`).

Mathlib provides `Real.ofDigits_digits`: reading the digits of `x ∈ [0,1)` and summing them
back returns `x`.  The opposite direction — *the digit sequence you prescribe is the digit
sequence you get* — is not in Mathlib, and it is exactly what is needed to build real numbers
with a designed digit statistic.  We prove it here under the (necessary) hypothesis that no
digit equals `9`, which rules out the `0.999… = 1.000…` ambiguity.

## Main results

* `Pyth.headVal_eq` / `Pyth.pow_mul_ofDigits`: the exact "integer part + tail" decomposition
  `10 ^ n * ofDigits d = headVal d n + ofDigits (d ∘ (· + n))`.
* `Pyth.digits_ofDigits`: prescribed digits are recovered, `Real.digits (ofDigits d) 10 = d`.
* `Pyth.irrational_ofDigits_of_gaps`: a digit sequence containing arbitrarily long runs of
  zeros which is not eventually zero produces an **irrational** number.
* `Pyth.not_irrational_ofDigits_of_eventually_periodic`: an eventually periodic digit
  sequence produces a **rational** number.

Together the last two items are the precise content of "irrationality forbids eventual
periodicity of the digits — and nothing else".
-/

namespace Pyth

open Filter Real

/-! ## Bounds for `Real.ofDigits` -/

/-- Every term of the defining series of `Real.ofDigits` is nonnegative. -/
theorem ofDigitsTerm_nonneg' {b : ℕ} (d : ℕ → Fin b) (i : ℕ) : 0 ≤ Real.ofDigitsTerm d i :=
  Real.ofDigitsTerm_nonneg

/-- If all digits are at most `8`, the value of the expansion is at most `8/9 < 1`.
This strict bound is what makes digit recovery possible. -/
theorem ofDigits_le_of_le_eight (d : ℕ → Fin 10) (hd : ∀ i, (d i : ℕ) ≤ 8) :
    Real.ofDigits d ≤ 8 / 9 := by
  have hsum : Summable (Real.ofDigitsTerm d) := Real.summable_ofDigitsTerm
  have hgeo : Summable (fun n : ℕ => (8 / 10 : ℝ) * (1 / 10 : ℝ) ^ n) :=
    (summable_geometric_of_lt_one (by norm_num) (by norm_num)).mul_left _
  have hterm : ∀ n, Real.ofDigitsTerm d n ≤ (8 / 10 : ℝ) * (1 / 10 : ℝ) ^ n := by
    intro n
    have h1 : ((d n : ℕ) : ℝ) ≤ 8 := by exact_mod_cast hd n
    have hp : (0 : ℝ) < (10 : ℝ) ^ (n + 1) := by positivity
    have key : (8 / 10 : ℝ) * (1 / 10 : ℝ) ^ n = 8 * ((10:ℝ) ^ (n + 1))⁻¹ := by
      rw [pow_succ]; field_simp; rw [← mul_pow]; norm_num
    have hterm' : Real.ofDigitsTerm d n = ((d n : ℕ) : ℝ) * ((10:ℝ) ^ (n + 1))⁻¹ := by
      simp [Real.ofDigitsTerm]
    rw [key, hterm']
    exact mul_le_mul_of_nonneg_right h1 (le_of_lt (inv_pos.mpr hp))
  calc Real.ofDigits d = ∑' n, Real.ofDigitsTerm d n := rfl
    _ ≤ ∑' n, (8 / 10 : ℝ) * (1 / 10 : ℝ) ^ n := hsum.tsum_le_tsum hterm hgeo
    _ = 8 / 9 := by
        rw [tsum_mul_left, tsum_geometric_of_lt_one (by norm_num) (by norm_num)]
        norm_num

theorem ofDigits_lt_one_of_le_eight (d : ℕ → Fin 10) (hd : ∀ i, (d i : ℕ) ≤ 8) :
    Real.ofDigits d < 1 :=
  lt_of_le_of_lt (ofDigits_le_of_le_eight d hd) (by norm_num)

/-- If some digit is nonzero, the expansion is (strictly) positive. -/
theorem ofDigits_pos {b : ℕ} (d : ℕ → Fin b) (j : ℕ) (hj : (d j : ℕ) ≠ 0) :
    0 < Real.ofDigits d := by
  have hsum : Summable (Real.ofDigitsTerm d) := Real.summable_ofDigitsTerm
  have hb : 0 < b := Fin.pos (d j)
  have hpos : 0 < Real.ofDigitsTerm d j := by
    have h1 : (0 : ℝ) < ((d j : ℕ) : ℝ) := by
      have : 0 < (d j : ℕ) := Nat.pos_of_ne_zero hj
      exact_mod_cast this
    have h2 : (0 : ℝ) < ((b : ℝ) ^ (j + 1))⁻¹ := by
      have : (0 : ℝ) < (b : ℝ) := by exact_mod_cast hb
      positivity
    simpa [Real.ofDigitsTerm] using mul_pos h1 h2
  calc (0:ℝ) < Real.ofDigitsTerm d j := hpos
    _ ≤ ∑' n, Real.ofDigitsTerm d n := hsum.le_tsum j (fun i _ => Real.ofDigitsTerm_nonneg)

/-! ## The integer part of `10 ^ n * ofDigits d` -/

/-- `headVal d n` is the natural number `d₀d₁…d_{n-1}` read in base ten. -/
def headVal (d : ℕ → Fin 10) : ℕ → ℕ
  | 0 => 0
  | (n + 1) => 10 * headVal d n + (d n : ℕ)

@[simp] theorem headVal_zero (d : ℕ → Fin 10) : headVal d 0 = 0 := rfl

@[simp] theorem headVal_succ (d : ℕ → Fin 10) (n : ℕ) :
    headVal d (n + 1) = 10 * headVal d n + (d n : ℕ) := rfl

theorem headVal_eq_zero (d : ℕ → Fin 10) {L : ℕ} (h : ∀ j < L, (d j : ℕ) = 0) :
    headVal d L = 0 := by
  induction L with
  | zero => rfl
  | succ L ih =>
      have h' : ∀ j < L, (d j : ℕ) = 0 := fun j hj => h j (by omega)
      simp [headVal_succ, ih h', h L (by omega)]

/-- Scaling the truncated series by `10 ^ n` gives exactly the natural number `headVal d n`. -/
theorem headVal_eq (d : ℕ → Fin 10) (n : ℕ) :
    (10 : ℝ) ^ n * ∑ i ∈ Finset.range n, Real.ofDigitsTerm d i = (headVal d n : ℝ) := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, mul_add, pow_succ]
      have h1 : (10:ℝ) ^ n * 10 * ∑ i ∈ Finset.range n, Real.ofDigitsTerm d i
          = 10 * ((10:ℝ) ^ n * ∑ i ∈ Finset.range n, Real.ofDigitsTerm d i) := by ring
      have h2 : (10:ℝ) ^ n * 10 * Real.ofDigitsTerm d n = ((d n : ℕ) : ℝ) := by
        simp only [Real.ofDigitsTerm]
        rw [show (((10:ℕ)) : ℝ) = (10 : ℝ) by norm_num, pow_succ]
        field_simp
      rw [h1, ih, h2, headVal_succ]
      push_cast
      ring

/-- The fundamental decomposition: `10 ^ n * ofDigits d` is the integer `headVal d n` plus the
tail expansion, which lies in `[0, 1)` as soon as no digit is a `9`. -/
theorem pow_mul_ofDigits (d : ℕ → Fin 10) (n : ℕ) :
    (10 : ℝ) ^ n * Real.ofDigits d
      = (headVal d n : ℝ) + Real.ofDigits (fun i => d (i + n)) := by
  have h := Real.ofDigits_eq_sum_add_ofDigits d n
  have h10 : ((10 : ℕ) : ℝ) = (10 : ℝ) := by norm_num
  rw [h10] at h
  rw [h, mul_add, headVal_eq d n]
  congr 1
  rw [← mul_assoc, mul_inv_cancel₀ (by positivity), one_mul]

/-- A run of `L` leading zeros scales the expansion down by `10 ^ L`. -/
theorem ofDigits_of_leading_zeros (d : ℕ → Fin 10) {L : ℕ} (h : ∀ j < L, (d j : ℕ) = 0) :
    Real.ofDigits d = ((10 : ℝ) ^ L)⁻¹ * Real.ofDigits (fun i => d (i + L)) := by
  have := pow_mul_ofDigits d L
  rw [headVal_eq_zero d h, Nat.cast_zero, zero_add] at this
  rw [eq_inv_mul_iff_mul_eq₀ (by positivity : ((10:ℝ) ^ L) ≠ 0)]
  exact this

/-! ## Digit recovery -/

/-- **Prescribed digits are recovered.**  If no digit of the sequence `d` equals `9`, then the
decimal digits of the real number `Real.ofDigits d` are exactly `d`.  (Some hypothesis of this
kind is necessary: `0.999… = 1.000…`.) -/
theorem digits_ofDigits (d : ℕ → Fin 10) (hd : ∀ i, (d i : ℕ) ≤ 8) :
    Real.digits (Real.ofDigits d) 10 = d := by
  funext k
  have hkey : (10 : ℝ) ^ (k + 1) * Real.ofDigits d
      = (headVal d (k + 1) : ℝ) + Real.ofDigits (fun i => d (i + (k + 1))) :=
    pow_mul_ofDigits d (k + 1)
  set T := Real.ofDigits (fun i => d (i + (k + 1))) with hT
  have hT0 : 0 ≤ T := Real.ofDigits_nonneg _
  have hT1 : T < 1 := ofDigits_lt_one_of_le_eight _ (fun i => hd _)
  have hfloor : ⌊Real.ofDigits d * (10:ℝ) ^ (k + 1)⌋₊ = headVal d (k + 1) := by
    have : Real.ofDigits d * (10:ℝ) ^ (k + 1) = T + (headVal d (k + 1) : ℕ) := by
      rw [mul_comm]; rw [hkey]; ring
    rw [this, Nat.floor_add_natCast hT0, Nat.floor_eq_zero.mpr hT1, zero_add]
  have : Real.digits (Real.ofDigits d) 10 k
      = Fin.ofNat _ ⌊Real.ofDigits d * (10:ℝ) ^ (k + 1)⌋₊ := by
    simp [Real.digits]
  rw [this, hfloor]
  apply Fin.ext
  rw [Fin.val_ofNat, headVal_succ]
  have hlt : (d k : ℕ) < 10 := (d k).isLt
  omega

/-! ## Irrationality from long gaps -/

/-- **Long runs of zeros force irrationality.**  If the digit sequence `d` (with no digit
equal to `9`) contains, for every `L`, a run of `L` consecutive zeros that is followed later on
by a nonzero digit, then `Real.ofDigits d` is irrational.

This is a Liouville-type argument: after cutting at the beginning of a long zero run the
remaining tail is positive but smaller than `10 ^ (-L)`, while a rational number of
denominator `q` has all its nonzero "tails" bounded below by `1/q`. -/
theorem irrational_ofDigits_of_gaps (d : ℕ → Fin 10) (hd : ∀ i, (d i : ℕ) ≤ 8)
    (hgap : ∀ L : ℕ, ∃ k : ℕ, (∀ j, k ≤ j → j < k + L → (d j : ℕ) = 0) ∧
      ∃ j, k + L ≤ j ∧ (d j : ℕ) ≠ 0) :
    Irrational (Real.ofDigits d) := by
  set x := Real.ofDigits d with hx
  rintro ⟨q, hq⟩
  -- denominator bound
  set b : ℕ := q.den with hb
  have hbpos : 0 < b := q.pos
  -- choose a long enough gap
  obtain ⟨k, hzeros, j, hjge, hjne⟩ := hgap (b + 1)
  set L := b + 1 with hL
  -- the tail at position k
  have hdecomp : (10 : ℝ) ^ k * x = (headVal d k : ℝ) + Real.ofDigits (fun i => d (i + k)) :=
    pow_mul_ofDigits d k
  set T := Real.ofDigits (fun i => d (i + k)) with hTdef
  -- T is small
  have hTsmall : T ≤ ((10:ℝ) ^ L)⁻¹ * (8 / 9) := by
    have hz : ∀ i < L, ((fun i => d (i + k)) i : ℕ) = 0 := by
      intro i hi
      exact hzeros (i + k) (by omega) (by omega)
    rw [hTdef, ofDigits_of_leading_zeros (fun i => d (i + k)) hz]
    have h1 : Real.ofDigits (fun i => d (i + L + k)) ≤ 8 / 9 :=
      ofDigits_le_of_le_eight _ (fun i => hd _)
    have h2 : (0:ℝ) < ((10:ℝ) ^ L)⁻¹ := by positivity
    have : Real.ofDigits (fun i => (fun i => d (i + k)) (i + L)) ≤ 8/9 := by
      simpa [add_comm, add_left_comm, add_assoc] using
        ofDigits_le_of_le_eight (fun i => d (i + L + k)) (fun i => hd _)
    exact mul_le_mul_of_nonneg_left this (le_of_lt h2)
  -- T is positive
  have hTpos : 0 < T := by
    refine ofDigits_pos (fun i => d (i + k)) (j - k) ?_
    have : j - k + k = j := by omega
    simpa [this] using hjne
  -- b * T is a positive integer
  set N : ℤ := 10 ^ k * q.num - (b : ℤ) * (headVal d k : ℤ) with hN
  have hqden : ((q.den : ℝ)) ≠ 0 := by exact_mod_cast q.den_ne_zero
  have hcast : (N : ℝ) = (b : ℝ) * T := by
    have hqr : (q : ℝ) = (q.num : ℝ) / (q.den : ℝ) := by rw [Rat.cast_def]
    have hxq : x = (q.num : ℝ) / (q.den : ℝ) := by rw [← hq, hqr]
    have : T = (10:ℝ) ^ k * x - (headVal d k : ℝ) := by rw [hdecomp]; ring
    rw [this, hxq, hN]
    push_cast [hb]
    field_simp
  have hNpos : (0:ℝ) < (N : ℝ) := by
    rw [hcast]
    have : (0:ℝ) < (b : ℝ) := by exact_mod_cast hbpos
    exact mul_pos this hTpos
  have hN1 : (1 : ℝ) ≤ (N : ℝ) := by
    have : (0:ℤ) < N := by exact_mod_cast hNpos
    exact_mod_cast this
  -- combine: 1 ≤ b * T ≤ b * (8/9) / 10 ^ L < 1
  have hbR : (0:ℝ) < (b : ℝ) := by exact_mod_cast hbpos
  have hupper : (b : ℝ) * T ≤ (b : ℝ) * (((10:ℝ) ^ L)⁻¹ * (8 / 9)) :=
    mul_le_mul_of_nonneg_left hTsmall (le_of_lt hbR)
  have hpowbig : (b : ℝ) < (10:ℝ) ^ L := by
    have h1 : (b : ℝ) < (2:ℝ) ^ L := by
      have : b < 2 ^ L := by
        have := Nat.lt_two_pow_self (n := b)
        calc b < 2 ^ b := this
          _ ≤ 2 ^ L := Nat.pow_le_pow_right (by norm_num) (by omega)
      exact_mod_cast this
    have h2 : (2:ℝ) ^ L ≤ (10:ℝ) ^ L := by
      apply pow_le_pow_left₀ (by norm_num) (by norm_num)
    linarith
  have hpowpos : (0:ℝ) < (10:ℝ) ^ L := by positivity
  have : (b : ℝ) * (((10:ℝ) ^ L)⁻¹ * (8 / 9)) < 1 := by
    have hbP : (b : ℝ) / (10:ℝ) ^ L < 1 := (div_lt_one hpowpos).mpr hpowbig
    have hbP0 : (0:ℝ) ≤ (b : ℝ) / (10:ℝ) ^ L := by positivity
    have hrw : (b : ℝ) * (((10:ℝ) ^ L)⁻¹ * (8 / 9)) = (8 / 9) * ((b : ℝ) / (10:ℝ) ^ L) := by
      field_simp
    rw [hrw]
    nlinarith
  rw [hcast] at hN1
  linarith

/-! ## Rationality from eventual periodicity -/

/-- **Eventually periodic digits give a rational number.**  This is the exact converse
boundary of the previous theorem: irrationality of a decimal expansion is *equivalent* to the
failure of eventual periodicity, and says nothing whatsoever about digit frequencies. -/
theorem not_irrational_ofDigits_of_eventually_periodic (d : ℕ → Fin 10) (n p : ℕ) (hp : 0 < p)
    (hper : ∀ i, d (i + p + n) = d (i + n)) :
    ¬ Irrational (Real.ofDigits d) := by
  set e : ℕ → Fin 10 := fun i => d (i + n) with he
  set u : ℝ := Real.ofDigits e with hu
  have hshift : (10:ℝ) ^ p * u = (headVal e p : ℝ) + Real.ofDigits (fun i => e (i + p)) :=
    pow_mul_ofDigits e p
  have hfun : (fun i => e (i + p)) = e := by
    funext i
    simp only [he]
    exact hper i
  rw [hfun] at hshift
  -- u = headVal e p / (10 ^ p - 1)
  have hden : (0:ℝ) < (10:ℝ) ^ p - 1 := by
    have : (1:ℝ) < (10:ℝ) ^ p := by
      apply one_lt_pow₀ (by norm_num) (by omega)
    linarith
  have huval : u = (headVal e p : ℝ) / ((10:ℝ) ^ p - 1) := by
    field_simp
    linarith [hshift]
  -- x = headVal d n / 10 ^ n + u / 10 ^ n
  have hx : (10:ℝ) ^ n * Real.ofDigits d = (headVal d n : ℝ) + u := pow_mul_ofDigits d n
  set Q : ℚ := (headVal d n : ℚ) / 10 ^ n + (headVal e p : ℚ) / (((10:ℚ) ^ p - 1) * 10 ^ n)
    with hQ
  have hdenq : ((10:ℚ) ^ p - 1) ≠ 0 := by
    have : (1:ℚ) < (10:ℚ) ^ p := one_lt_pow₀ (by norm_num) (by omega)
    linarith
  have h10n : ((10:ℝ) ^ n) ≠ 0 := by positivity
  have hx' : Real.ofDigits d = ((headVal d n : ℝ) + u) / (10:ℝ) ^ n := by
    field_simp
    linarith [hx]
  have hval : Real.ofDigits d = (Q : ℝ) := by
    rw [hx', huval, hQ]
    push_cast
    field_simp
  rw [hval]
  exact Rat.not_irrational Q

end Pyth