import Mathlib

/-!
# Barrier-4 positional converse, stratum T2: adaptive saturation `V(W) = log₂ W + ½`

The T2 stratum studies the *adaptive* (query-then-scan) cost curve on a window of width `W`:
after `k` binary queries the surviving window has width `W / 2^k`, and a residual linear scan of
a window of width `w` costs `w / 2` on average.  This gives the **cost curve**

`netCost W k = W / 2^(k+1) + k`   (residual scan + queries already paid).

Four things are proved.

* `marginal_net_identity` : the *net* marginal-value identity
  `cost(k) − cost(k+1) = W / 2^(k+2) − 1`, exactly (the *gross* form, without the `−1` query
  charge, is false — see `gross_marginal_identity_fails`).
* `saturation_exact` / `dpVal_eq` : on dyadic windows `W = 2^m` the **pinned** value saturates
  exactly: `netCost (2^m) m = m + 1/2 = log₂ W + 1/2`, and this is precisely the fixed point of
  the halving recursion `V(2W) = V(W) + 1`, `V(1) = 1/2`.
* `netCost_dyadic_ge` together with `netCost_pin_sub_one` and `netCost_pin_sub_two` : the pin is
  **not** the argmin.  On `W = 2^m` the minimum of the cost curve equals `m` and is attained at
  the two offsets `k = m − 1` and `k = m − 2`; the pinned value `m + 1/2` sits a half query above
  it (`pin_not_argmin`).  Three distinct `k`'s (the pin `log₂ W`, the argmin `log₂ W − 1`, and the
  economic optimum one query further out) must therefore be kept apart.
* `netCost_bracket` : for a general window `W ≥ 1` the closed form `log₂ W + 1/2` is an upper
  bound for the optimised curve which is **never undercut by more than `1/2`**:
  `log₂ W − 1/2 ≤ min_k netCost W k ≤ log₂ W + 1/2`, the upper bound being attained exactly on
  dyadic `W`.
-/

namespace Barrier4

open Real

/-! ## 1. The cost curve and the halving DP -/

/-- Expected total cost after committing to `k` binary queries on a window of width `W`:
`k` queries already paid plus the average residual scan `W / 2^(k+1)`. -/
noncomputable def netCost (W : ℝ) (k : ℕ) : ℝ := W / 2 ^ (k + 1) + k

/-- The halving DP: `V(1) = 1/2`, `V(2W) = V(W) + 1`, indexed by the dyadic exponent. -/
noncomputable def dpVal : ℕ → ℝ
  | 0 => 1 / 2
  | m + 1 => dpVal m + 1

/-- The DP solves in closed form. -/
theorem dpVal_eq (m : ℕ) : dpVal m = m + 1 / 2 := by
  induction m with
  | zero => simp [dpVal]
  | succ n ih => rw [dpVal, ih]; push_cast; ring

/-- The DP value is the value of the cost curve at the **pin** `k = log₂ W`. -/
theorem dpVal_eq_netCost_pin (m : ℕ) : dpVal m = netCost (2 ^ m) m := by
  rw [dpVal_eq, netCost]
  have : (2:ℝ) ^ m / 2 ^ (m + 1) = 1 / 2 := by
    rw [pow_succ]
    field_simp
  rw [this]; ring

/-- **T2 saturation, exact form.**  On every dyadic window the pinned cost is `log₂ W + 1/2`. -/
theorem saturation_exact (m : ℕ) :
    netCost ((2:ℝ) ^ m) m = Real.logb 2 ((2:ℝ) ^ m) + 1 / 2 := by
  rw [← dpVal_eq_netCost_pin, dpVal_eq, Real.logb_pow, Real.logb_self_eq_one (by norm_num)]
  ring

/-- The recursion in cost-curve form: doubling the window costs exactly one extra query. -/
theorem netCost_dyadic_recursion (m : ℕ) :
    netCost ((2:ℝ) ^ (m + 1)) (m + 1) = netCost ((2:ℝ) ^ m) m + 1 := by
  rw [← dpVal_eq_netCost_pin, ← dpVal_eq_netCost_pin, dpVal]

/-! ## 1b. The curve is *generated* by iterated halving -/

/-- The genuine adaptive process: with no queries left the residual window of width `W` is
scanned at average cost `W/2`; each query costs `1` and halves the window. -/
noncomputable def halvingCost : ℝ → ℕ → ℝ
  | W, 0 => W / 2
  | W, (k + 1) => 1 + halvingCost (W / 2) k

/-- **The T2 cost curve is not an ansatz.**  It is exactly the value of the `k`-fold halving
process, for every window width. -/
theorem halvingCost_eq_netCost (k : ℕ) (W : ℝ) : halvingCost W k = netCost W k := by
  induction k generalizing W with
  | zero => simp [halvingCost, netCost]
  | succ n ih =>
      rw [halvingCost, ih]
      simp only [netCost]
      have h : (2:ℝ) ^ (n + 1 + 1) = 2 ^ (n + 1) * 2 := by ring
      rw [h]
      push_cast
      field_simp
      ring

/-- Consequently the saturation value `log₂ W + 1/2` is the value of the halving process run to
the pin. -/
theorem halvingCost_pin (m : ℕ) : halvingCost ((2:ℝ) ^ m) m = (m : ℝ) + 1 / 2 := by
  rw [halvingCost_eq_netCost, ← dpVal_eq_netCost_pin, dpVal_eq]

/-! ## 2. The marginal-value identity -/

/-- **Exact NET marginal-value identity.**  One more query is worth the halved residual scan it
saves, minus the unit charge for the query itself. -/
theorem marginal_net_identity (W : ℝ) (k : ℕ) :
    netCost W k - netCost W (k + 1) = W / 2 ^ (k + 2) - 1 := by
  simp only [netCost]
  have h : (2:ℝ) ^ (k + 2) = 2 ^ (k + 1) * 2 := by ring
  rw [h]
  push_cast
  field_simp
  ring

/-- **The drafted GROSS form is false.**  Dropping the unit query charge breaks the identity
already at `W = 4, k = 0`. -/
theorem gross_marginal_identity_fails :
    netCost 4 0 - netCost 4 (0 + 1) ≠ (4:ℝ) / 2 ^ (0 + 2) := by
  simp only [netCost]
  norm_num

/-! ## 3. The pin is not the argmin -/

/-- Lower envelope on a dyadic window: the cost curve never drops below `m = log₂ W`. -/
theorem netCost_dyadic_ge (m k : ℕ) : (m : ℝ) ≤ netCost ((2:ℝ) ^ m) k := by
  rcases le_or_gt m k with h | h
  · have hpos : 0 < (2:ℝ) ^ m / 2 ^ (k + 1) := by positivity
    have : (m : ℝ) ≤ (k : ℝ) := by exact_mod_cast h
    simp only [netCost]; linarith
  · -- `k ≤ m - 1`; write `m = k + 1 + d`
    obtain ⟨d, rfl⟩ : ∃ d, m = k + 1 + d := ⟨m - k - 1, by omega⟩
    have hpow : (2:ℝ) ^ (k + 1 + d) / 2 ^ (k + 1) = 2 ^ d := by
      rw [pow_add]
      field_simp
    have hd : (d : ℝ) + 1 ≤ 2 ^ d := by
      have : d + 1 ≤ 2 ^ d := Nat.lt_two_pow_self
      exact_mod_cast this
    simp only [netCost, hpow]
    push_cast
    linarith

/-- The minimum is attained one query *below* the pin. -/
theorem netCost_pin_sub_one (m : ℕ) :
    netCost ((2:ℝ) ^ (m + 1)) m = ((m : ℝ) + 1) := by
  simp only [netCost]
  rw [div_self (by positivity)]
  ring

/-- …and also two queries below the pin: the argmin offsets are `{−2, −1}`. -/
theorem netCost_pin_sub_two (m : ℕ) :
    netCost ((2:ℝ) ^ (m + 2)) m = ((m : ℝ) + 2) := by
  simp only [netCost]
  have : (2:ℝ) ^ (m + 2) / 2 ^ (m + 1) = 2 := by
    rw [pow_succ]
    field_simp
  rw [this]
  ring

/-- **The pin is not the argmin.**  On `W = 2^(m+1)` the pinned value `m + 3/2` strictly exceeds
the minimum `m + 1`, which is attained at both offsets `−1` and `−2`. -/
theorem pin_not_argmin (m : ℕ) :
    netCost ((2:ℝ) ^ (m + 1)) m < netCost ((2:ℝ) ^ (m + 1)) (m + 1) ∧
      netCost ((2:ℝ) ^ (m + 1)) m = netCost ((2:ℝ) ^ (m + 1)) (m + 1) - 1 / 2 := by
  have h1 : netCost ((2:ℝ) ^ (m + 1)) (m + 1) = (m : ℝ) + 1 + 1 / 2 := by
    have := saturation_exact (m + 1)
    rw [← dpVal_eq_netCost_pin, dpVal_eq]
    push_cast; ring
  rw [netCost_pin_sub_one m, h1]
  constructor <;> linarith

/-- The exact half-query gap between the two conventions, on every dyadic window. -/
theorem pin_argmin_gap (m : ℕ) :
    netCost ((2:ℝ) ^ (m + 1)) (m + 1) - netCost ((2:ℝ) ^ (m + 1)) m = 1 / 2 := by
  have := (pin_not_argmin m).2
  linarith

/-! ## 4. The general-`W` bracket -/

private lemma logb_two_eq (x : ℝ) : Real.logb 2 x = Real.log x / Real.log 2 := rfl

private lemma log_two_pos : 0 < Real.log 2 := Real.log_pos (by norm_num)

/-- Key scalar inequality: `log₂ u ≤ u − 1/2` for every `u > 0`. -/
private lemma logb_le_sub_half {u : ℝ} (hu : 0 < u) : Real.logb 2 u ≤ u - 1 / 2 := by
  have hs : 0 < Real.sqrt u := Real.sqrt_pos.mpr hu
  have hlog : Real.log (Real.sqrt u) ≤ Real.sqrt u - 1 := Real.log_le_sub_one_of_pos hs
  have hhalf : Real.log u = 2 * Real.log (Real.sqrt u) := by
    rw [Real.log_sqrt hu.le]; ring
  have hsq : Real.sqrt u ^ 2 = u := Real.sq_sqrt hu.le
  have hl2 : 0.6931471803 < Real.log 2 := Real.log_two_gt_d9
  have hl2' : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have key : Real.log u ≤ (u - 1 / 2) * Real.log 2 := by
    have h1 : Real.log u ≤ 2 * (Real.sqrt u - 1) := by rw [hhalf]; linarith
    nlinarith [sq_nonneg (Real.sqrt u - 1.5), Real.sqrt_nonneg u]
  rw [logb_two_eq, div_le_iff₀ log_two_pos]
  exact key

/-- **Lower bracket.**  For every window and every number of queries the cost curve stays above
`log₂ W − 1/2`: the closed form `log₂ W + 1/2` is never undercut by more than one half query. -/
theorem netCost_ge_logb_sub_half {W : ℝ} (hW : 0 < W) (k : ℕ) :
    Real.logb 2 W - 1 / 2 ≤ netCost W k := by
  set u : ℝ := W / 2 ^ (k + 1) with hu_def
  have hu : 0 < u := by positivity
  have hsplit : Real.logb 2 W = Real.logb 2 u + (k + 1) := by
    have h2 : W = u * 2 ^ (k + 1) := by rw [hu_def]; field_simp
    rw [h2, Real.logb_mul (ne_of_gt hu) (by positivity), Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)]
    push_cast
    ring
  have := logb_le_sub_half hu
  simp only [netCost, ← hu_def]
  rw [hsplit]
  linarith

/-- **Upper bracket at the dyadic scale.**  If `2^k ≤ W < 2^(k+1)` then the cost curve at `k`
already meets the closed form `log₂ W + 1/2`. -/
theorem netCost_le_logb_add_half {W : ℝ} {k : ℕ} (h1 : (2:ℝ) ^ k ≤ W) (h2 : W < 2 ^ (k + 1)) :
    netCost W k ≤ Real.logb 2 W + 1 / 2 := by
  have hpos : (0:ℝ) < 2 ^ k := by positivity
  have hW : 0 < W := lt_of_lt_of_le hpos h1
  set t : ℝ := W / 2 ^ k with ht_def
  have ht1 : 1 ≤ t := by rw [ht_def, le_div_iff₀ hpos]; linarith
  have ht2 : t < 2 := by
    rw [ht_def, div_lt_iff₀ hpos]
    calc W < 2 ^ (k + 1) := h2
      _ = 2 * 2 ^ k := by ring
  have ht0 : 0 < t := lt_of_lt_of_le zero_lt_one ht1
  have hsplit : Real.logb 2 W = Real.logb 2 t + k := by
    have hWt : W = t * 2 ^ k := by rw [ht_def]; field_simp
    rw [hWt, Real.logb_mul (ne_of_gt ht0) (by positivity), Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)]
    ring
  -- `log t ≥ 1 - 1/t` and `t < 2 < 2 / log 2` give `t/2 - 1/2 ≤ log₂ t`
  have hlog : 1 - 1 / t ≤ Real.log t := by
    have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < 1 / t by positivity)
    rw [Real.log_div one_ne_zero (ne_of_gt ht0), Real.log_one] at h
    have : Real.log t ≥ 1 - 1 / t := by linarith
    linarith
  have hl2 : 0.6931471803 < Real.log 2 := Real.log_two_gt_d9
  have hl2' : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hkey : (t / 2 - 1 / 2) * Real.log 2 ≤ Real.log t := by
    have h1t : (t - 1) / t ≤ Real.log t := by
      have : 1 - 1 / t = (t - 1) / t := by field_simp
      linarith [this ▸ hlog]
    have hstep : (t / 2 - 1 / 2) * Real.log 2 ≤ (t - 1) / t := by
      rw [le_div_iff₀ ht0]
      nlinarith [mul_nonneg (sub_nonneg.2 ht1) (sub_nonneg.2 ht2.le)]
    linarith
  have hlogb : t / 2 - 1 / 2 ≤ Real.logb 2 t := by
    rw [logb_two_eq, le_div_iff₀ log_two_pos]
    exact hkey
  have hcost : netCost W k = t / 2 + k := by
    simp only [netCost, ht_def]
    rw [pow_succ]
    field_simp
  rw [hcost, hsplit]
  linarith

/-- Every window of width at least `1` sits in a unique dyadic scale. -/
theorem exists_dyadic_scale {W : ℝ} (hW : 1 ≤ W) : ∃ k : ℕ, (2:ℝ) ^ k ≤ W ∧ W < 2 ^ (k + 1) := by
  classical
  have hex : ∃ n : ℕ, W < 2 ^ n := pow_unbounded_of_one_lt W (show (1:ℝ) < 2 by norm_num)
  have hn : W < 2 ^ (Nat.find hex) := Nat.find_spec hex
  have hn0 : Nat.find hex ≠ 0 := by
    intro h
    rw [h] at hn
    norm_num at hn
    linarith
  obtain ⟨k, hk⟩ : ∃ k, Nat.find hex = k + 1 := ⟨Nat.find hex - 1, by omega⟩
  refine ⟨k, ?_, by rw [← hk]; exact hn⟩
  have hmin := Nat.find_min hex (m := k) (by omega)
  push_neg at hmin
  exact hmin

/-- **T2 bracket.**  For every window `W ≥ 1` the optimised cost curve is sandwiched:
`log₂ W − 1/2 ≤ netCost W k ≤ log₂ W + 1/2` for the dyadic-scale choice of `k`, and the lower
bound holds for *all* `k`.  On dyadic `W` the upper bound is attained exactly (at the pin). -/
theorem netCost_bracket {W : ℝ} (hW : 1 ≤ W) :
    (∀ k : ℕ, Real.logb 2 W - 1 / 2 ≤ netCost W k) ∧
      ∃ k : ℕ, netCost W k ≤ Real.logb 2 W + 1 / 2 := by
  refine ⟨fun k => netCost_ge_logb_sub_half (lt_of_lt_of_le zero_lt_one hW) k, ?_⟩
  obtain ⟨k, h1, h2⟩ := exists_dyadic_scale hW
  exact ⟨k, netCost_le_logb_add_half h1 h2⟩

end Barrier4