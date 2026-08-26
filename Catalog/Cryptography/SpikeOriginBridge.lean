/-
# Discrete–continuum bridge for the excluded fraction

Continuation of `Cryptography.SpikeOriginCounting`.

The exact integer count of the sub-`2⁹⁵` (tiny-residue) window points is
`m − s` with `m = ⌊√(N + 2⁹⁵ − 1)⌋`, `s = ⌊√N⌋` (`card_lowBand`), while the continuum model
predicts the fraction `u₀(N) = (√(1 + 2⁹⁵/N) − 1)/2` (`crossingPos`).  Here the two are
compared:

* `crossingPos_eq` rewrites `u₀` as `(√(N + 2⁹⁵) − √N)/(2√N)`;
* `count_bridge` shows the integer count differs from the continuum length by at most `2`;
* `fraction_bridge` turns this into `|(m − s)/(2s) − u₀(N)| ≤ 3/s`.

At `96` bits `s ≥ 2⁴⁷`, so the discrete and continuum excluded fractions agree to about
fourteen decimal digits: discretisation can never explain a discrepancy in a fitted edge
weight.
-/
import Mathlib
import Cryptography.SpikeOriginCounting

namespace SpikeOrigin

/-! ## Real bounds for the integer square root -/

lemma natSqrt_le_real (n : ℕ) : (Nat.sqrt n : ℝ) ≤ Real.sqrt n := by
  have h : ((Nat.sqrt n : ℝ)) ^ 2 ≤ (n : ℝ) := by exact_mod_cast Nat.sqrt_le' n
  exact (Real.le_sqrt (by positivity) (by positivity)).2 h

lemma real_sqrt_lt_natSqrt_succ (n : ℕ) : Real.sqrt n < (Nat.sqrt n : ℝ) + 1 := by
  have h : (n : ℝ) < ((Nat.sqrt n : ℝ) + 1) ^ 2 := by
    have := Nat.lt_succ_sqrt' n
    exact_mod_cast this
  exact (Real.sqrt_lt' (by positivity)).2 h

lemma sqrt_le_sqrt_pred_add_one {x : ℝ} (hx : 1 ≤ x) :
    Real.sqrt x ≤ Real.sqrt (x - 1) + 1 := by
  have h0 : (0:ℝ) ≤ x - 1 := by linarith
  have h1 : Real.sqrt (x - 1) ^ 2 = x - 1 := Real.sq_sqrt h0
  have h2 : 0 ≤ Real.sqrt (x - 1) := Real.sqrt_nonneg _
  have h3 : Real.sqrt x ^ 2 = x := Real.sq_sqrt (by linarith)
  nlinarith [Real.sqrt_nonneg x]

/-! ## The crossing position as a difference of square roots -/

theorem crossingPos_eq {N : ℝ} (hN : 0 < N) :
    crossingPos N = (Real.sqrt (N + 2 ^ 95) - Real.sqrt N) / (2 * Real.sqrt N) := by
  have hA : 0 < Real.sqrt N := Real.sqrt_pos.2 hN
  have hsplit : Real.sqrt (1 + 2 ^ 95 / N) = Real.sqrt (N + 2 ^ 95) / Real.sqrt N := by
    rw [← Real.sqrt_div' _ (le_of_lt hN)]
    congr 1
    field_simp
  unfold crossingPos
  rw [hsplit]
  field_simp

/-! ## The bridge -/

/-- The integer count of tiny-residue positions differs from the continuum length by at
most `2`. -/
theorem count_bridge (N : ℕ) (hN : 1 ≤ N) :
    |((Nat.sqrt (N + 2 ^ 95 - 1) : ℝ) - (Nat.sqrt N : ℝ))
      - (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N)| ≤ 2 := by
  set s := Nat.sqrt N with hs
  set m := Nat.sqrt (N + 2 ^ 95 - 1) with hm
  have hcast : ((N + 2 ^ 95 - 1 : ℕ) : ℝ) = (N : ℝ) + 2 ^ 95 - 1 := by
    have : (1 : ℕ) ≤ N + 2 ^ 95 := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hmC : (m : ℝ) ≤ Real.sqrt ((N : ℝ) + 2 ^ 95 - 1) := by
    have := natSqrt_le_real (N + 2 ^ 95 - 1)
    rwa [hcast] at this
  have hCm : Real.sqrt ((N : ℝ) + 2 ^ 95 - 1) < (m : ℝ) + 1 := by
    have := real_sqrt_lt_natSqrt_succ (N + 2 ^ 95 - 1)
    rwa [hcast] at this
  have hCB : Real.sqrt ((N : ℝ) + 2 ^ 95 - 1) ≤ Real.sqrt ((N : ℝ) + 2 ^ 95) :=
    Real.sqrt_le_sqrt (by linarith)
  have hBC : Real.sqrt ((N : ℝ) + 2 ^ 95) ≤ Real.sqrt ((N : ℝ) + 2 ^ 95 - 1) + 1 := by
    have h1 : (1:ℝ) ≤ (N : ℝ) + 2 ^ 95 := by
      have h : (1:ℝ) ≤ (N:ℝ) := by exact_mod_cast hN
      nlinarith
    simpa using sqrt_le_sqrt_pred_add_one h1
  have hsA : (s : ℝ) ≤ Real.sqrt N := natSqrt_le_real N
  have hAs : Real.sqrt N < (s : ℝ) + 1 := real_sqrt_lt_natSqrt_succ N
  rw [abs_le]
  constructor <;> linarith

/-- Normalised form of the bridge: the exact discrete excluded fraction and the continuum
crossing position agree to `3/s`.  For `96`-bit moduli `s ≥ 2⁴⁷`, so the agreement is to
about fourteen decimal digits. -/
theorem fraction_bridge {N : ℕ} (hlo : 2 ^ 95 ≤ N) :
    |((Nat.sqrt (N + 2 ^ 95 - 1) : ℝ) - (Nat.sqrt N : ℝ)) / (2 * (Nat.sqrt N : ℝ))
      - crossingPos (N : ℝ)| ≤ 3 / (Nat.sqrt N : ℝ) := by
  set s := Nat.sqrt N with hs
  set m := Nat.sqrt (N + 2 ^ 95 - 1) with hm
  have hNpos : (0:ℝ) < (N : ℝ) := by
    have : (0:ℕ) < N := lt_of_lt_of_le (by positivity) hlo
    exact_mod_cast this
  have hs1 : (1:ℝ) ≤ (s : ℝ) := by
    have : 1 ≤ s := by
      rw [hs]
      exact Nat.le_sqrt.2 (by omega)
    exact_mod_cast this
  have hA : (s : ℝ) ≤ Real.sqrt N := natSqrt_le_real N
  have hAs : Real.sqrt N < (s : ℝ) + 1 := real_sqrt_lt_natSqrt_succ N
  have hApos : (0:ℝ) < Real.sqrt N := by linarith
  have hspos : (0:ℝ) < (s : ℝ) := by linarith
  -- the continuum difference `B − A` is nonnegative and at most `A`
  have hAsq : Real.sqrt N ^ 2 = (N : ℝ) := Real.sq_sqrt (le_of_lt hNpos)
  have hBsq : Real.sqrt ((N : ℝ) + 2 ^ 95) ^ 2 = (N : ℝ) + 2 ^ 95 :=
    Real.sq_sqrt (by positivity)
  have hBpos : (0:ℝ) ≤ Real.sqrt ((N : ℝ) + 2 ^ 95) := Real.sqrt_nonneg _
  have hAB : Real.sqrt N ≤ Real.sqrt ((N : ℝ) + 2 ^ 95) :=
    Real.sqrt_le_sqrt (by nlinarith)
  have hTN : (2:ℝ) ^ 95 ≤ (N : ℝ) := by exact_mod_cast hlo
  have hBle : Real.sqrt ((N : ℝ) + 2 ^ 95) ≤ 2 * Real.sqrt N := by
    nlinarith
  -- decomposition
  have hbridge := count_bridge N (by omega)
  rw [crossingPos_eq hNpos]
  have hkey : ((m : ℝ) - s) / (2 * (s : ℝ))
      - (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N) / (2 * Real.sqrt N)
      = (((m : ℝ) - s) - (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N)) / (2 * (s : ℝ))
        + (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N) * (Real.sqrt N - (s : ℝ))
            / (2 * (s : ℝ) * Real.sqrt N) := by
    field_simp
    ring
  rw [hkey]
  have h1 : |(((m : ℝ) - s) - (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N)) / (2 * (s : ℝ))|
      ≤ 1 / (s : ℝ) := by
    rw [abs_div, abs_of_pos (show (0:ℝ) < 2 * (s:ℝ) by linarith)]
    rw [div_le_div_iff₀ (by linarith) hspos]
    nlinarith [hbridge]
  have h2nonneg : 0 ≤ (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N) * (Real.sqrt N - (s : ℝ))
      / (2 * (s : ℝ) * Real.sqrt N) := by
    apply div_nonneg
    · nlinarith
    · positivity
  have h2 : (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N) * (Real.sqrt N - (s : ℝ))
      / (2 * (s : ℝ) * Real.sqrt N) ≤ 1 / (s : ℝ) := by
    rw [div_le_div_iff₀ (by positivity) hspos]
    have hBA : Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N ≤ Real.sqrt N := by linarith
    have hAsle : Real.sqrt N - (s : ℝ) ≤ 1 := by linarith
    have hAs0 : (0:ℝ) ≤ Real.sqrt N - (s : ℝ) := by linarith
    have hBA0 : (0:ℝ) ≤ Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N := by linarith
    have hprod : (Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N) * (Real.sqrt N - (s : ℝ))
        ≤ Real.sqrt N * 1 := mul_le_mul hBA hAsle hAs0 (le_of_lt hApos)
    nlinarith
  have habs2 : |(Real.sqrt ((N : ℝ) + 2 ^ 95) - Real.sqrt N) * (Real.sqrt N - (s : ℝ))
      / (2 * (s : ℝ) * Real.sqrt N)| ≤ 1 / (s : ℝ) := by
    rw [abs_of_nonneg h2nonneg]; exact h2
  calc |_ + _| ≤ _ + _ := abs_add_le _ _
    _ ≤ 1 / (s : ℝ) + 1 / (s : ℝ) := add_le_add h1 habs2
    _ ≤ 3 / (s : ℝ) := by
        have h : (1:ℝ) / (s:ℝ) + 1 / (s:ℝ) = 2 / (s:ℝ) := by ring
        rw [h, div_le_div_iff₀ hspos hspos]
        nlinarith

end SpikeOrigin