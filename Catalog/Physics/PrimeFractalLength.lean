/-
# Prime reciprocal-log telescoping series

We study the sequence `a k = 1 / log (p k)`, where `p k` is the `k`-th prime,
and the telescoping increments `d k = a k - a (k+1)`.

## Main results

* `partialLength_eq` : the partial sum `L n = ∑_{k<n} d k` telescopes to `a 0 - a n`.
* `a_tendsto_zero`   : `a n → 0` as `n → ∞`.
* `tendsto_partialLength` : `L n → 1 / log 2`.
* `hasSum_d` / `tsum_primeCurveLength` : the full series sums to `1 / log 2`.
-/
import Mathlib

open Filter Topology Real

namespace PrimeFractalLength

/-- The `k`-th prime number. -/
noncomputable def p (k : ℕ) : ℕ := Nat.nth Nat.Prime k

/-- The reciprocal log of the `k`-th prime. -/
noncomputable def a (k : ℕ) : ℝ := 1 / Real.log (p k)

/-- Telescoping increment between consecutive terms. -/
noncomputable def d (k : ℕ) : ℝ := a k - a (k + 1)

/-- Partial sum of the telescoping increments. -/
noncomputable def L (n : ℕ) : ℝ := ∑ k ∈ Finset.range n, d k

/-- The `0`-th prime is `2`. -/
theorem p_zero : p 0 = 2 := by
  have h : Nat.count Nat.Prime 2 = 0 := by decide
  have := Nat.nth_count (p := Nat.Prime) (n := 2) (by norm_num)
  rwa [h] at this

/-- Every prime `p k` is at least `2`. -/
theorem two_le_p (k : ℕ) : 2 ≤ p k := (Nat.prime_nth_prime k).two_le

/-- `log (p k)` is positive. -/
theorem log_p_pos (k : ℕ) : 0 < Real.log (p k) := by
  apply Real.log_pos
  have : (2 : ℝ) ≤ (p k : ℝ) := by exact_mod_cast two_le_p k
  linarith

/-- The increments are nonnegative (the sequence `a` is decreasing). -/
theorem d_nonneg (k : ℕ) : 0 ≤ d k := by
  have hlt : p k < p (k + 1) :=
    Nat.nth_strictMono Nat.infinite_setOf_prime (Nat.lt_succ_self k)
  have hloglt : Real.log (p k) ≤ Real.log (p (k + 1)) :=
    Real.log_le_log (by exact_mod_cast (two_le_p k).trans_lt' (by norm_num))
      (by exact_mod_cast hlt.le)
  simp only [d, a, sub_nonneg]
  exact one_div_le_one_div_of_le (log_p_pos k) hloglt

/-- The partial sum telescopes: `L n = a 0 - a n`. -/
theorem partialLength_eq (n : ℕ) : L n = a 0 - a n := by
  induction n with
  | zero => simp [L]
  | succ m ih => rw [L, Finset.sum_range_succ, ← L, ih, d]; ring

/-- `a 0 = 1 / log 2`. -/
theorem a_zero : a 0 = 1 / Real.log 2 := by
  rw [a, p_zero]; norm_num

/-- `a n → 0` as `n → ∞`. -/
theorem a_tendsto_zero : Tendsto a atTop (𝓝 0) := by
  have hp : Tendsto (fun n => ((Nat.nth Nat.Prime n : ℕ) : ℝ)) atTop atTop :=
    tendsto_natCast_atTop_atTop.comp
      (Nat.nth_strictMono Nat.infinite_setOf_prime).tendsto_atTop
  have hlog : Tendsto (fun n => Real.log (p n)) atTop atTop :=
    Real.tendsto_log_atTop.comp hp
  have := tendsto_inv_atTop_zero.comp hlog
  exact this.congr (fun n => by simp [a, one_div, Function.comp])

/-- The partial sums converge to `1 / log 2`. -/
theorem tendsto_partialLength : Tendsto L atTop (𝓝 (1 / Real.log 2)) := by
  have ht : Tendsto (fun n => a 0 - a n) atTop (𝓝 (a 0 - 0)) :=
    tendsto_const_nhds.sub a_tendsto_zero
  simp only [sub_zero] at ht
  have hL : Tendsto L atTop (𝓝 (a 0)) := ht.congr (fun n => (partialLength_eq n).symm)
  rwa [a_zero] at hL

/-- The series `∑ d k` has sum `1 / log 2`. -/
theorem hasSum_d : HasSum d (1 / Real.log 2) :=
  (hasSum_iff_tendsto_nat_of_nonneg d_nonneg _).mpr tendsto_partialLength

/-- The total length of the prime reciprocal-log curve is `1 / log 2`. -/
theorem tsum_primeCurveLength : ∑' k, d k = 1 / Real.log 2 := hasSum_d.tsum_eq

end PrimeFractalLength