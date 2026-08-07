import Mathlib
import Novelty.Counting

/-! # Entropy dimension of an exponentially growing counting function

If a counting function `f : ℕ → ℝ` is squeezed between `kⁿ` and `k^(n+1)` for a base
`k > 1`, then its *entropy dimension* `log (f n) / n` converges to `log k`.  This is the
asymptotic statement that fixes the metric normalisation of a syntactic proof space:
volume growth of rate `k` means entropy density `log k`.
-/

namespace ProofSpace

open Filter Topology

/-- **Entropy dimension of an exponentially squeezed count.** -/
theorem dimension_eq_log (k : ℝ) (hk : 1 < k) (f : ℕ → ℝ)
    (hlb : ∀ n, k ^ n ≤ f n) (hub : ∀ n, f n ≤ k ^ (n + 1)) :
    Tendsto (fun n : ℕ => Real.log (f n) / n) atTop (𝓝 (Real.log k)) := by
  have hk0 : (0 : ℝ) < k := lt_trans zero_lt_one hk
  have hlogk : 0 < Real.log k := Real.log_pos hk
  -- lower and upper bounds for `log (f n) / n`
  have hlow : ∀ n : ℕ, 1 ≤ n → Real.log k ≤ Real.log (f n) / n := by
    intro n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
    have h1 : (n : ℝ) * Real.log k ≤ Real.log (f n) := by
      have := Real.log_le_log (by positivity) (hlb n)
      rwa [Real.log_pow] at this
    rw [le_div_iff₀ hn0]
    linarith
  have hhigh : ∀ n : ℕ, 1 ≤ n → Real.log (f n) / n ≤ (1 + 1 / n) * Real.log k := by
    intro n hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
    have hfpos : 0 < f n := lt_of_lt_of_le (by positivity) (hlb n)
    have h1 : Real.log (f n) ≤ ((n : ℝ) + 1) * Real.log k := by
      have := Real.log_le_log hfpos (hub n)
      rwa [Real.log_pow, Nat.cast_add, Nat.cast_one] at this
    rw [div_le_iff₀ hn0]
    have hrw : ((n : ℝ) + 1) * Real.log k = (1 + 1 / n) * Real.log k * n := by
      field_simp
    linarith [hrw ▸ h1]
  -- the two bounding sequences converge to `log k`
  have hconst : Tendsto (fun _ : ℕ => Real.log k) atTop (𝓝 (Real.log k)) := tendsto_const_nhds
  have hupper : Tendsto (fun n : ℕ => (1 + 1 / (n : ℝ)) * Real.log k) atTop (𝓝 (Real.log k)) := by
    have h1 : Tendsto (fun n : ℕ => 1 + 1 / (n : ℝ)) atTop (𝓝 (1 + 0)) :=
      tendsto_const_nhds.add tendsto_one_div_atTop_nhds_zero_nat
    rw [add_zero] at h1
    simpa using h1.mul (tendsto_const_nhds (x := Real.log k))
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hconst hupper ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn using hlow n hn
  · filter_upwards [eventually_ge_atTop 1] with n hn using hhigh n hn

/-- The entropy dimension of the syntactic proof space over a `k`-letter alphabet is
`log k`. -/
theorem dimension_S (k : ℕ) (hk : 2 ≤ k) :
    Tendsto (fun n : ℕ => Real.log (S k n) / n) atTop (𝓝 (Real.log k)) := by
  refine dimension_eq_log (k : ℝ) (by exact_mod_cast hk) (fun n => (S k n : ℝ)) ?_ ?_
  · intro n
    have := pow_le_S k n
    push_cast
    exact_mod_cast this
  · intro n
    have := S_le_pow k n hk
    push_cast
    exact_mod_cast this

end ProofSpace