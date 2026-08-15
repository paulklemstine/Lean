import Mathlib
import Novelty.SplitCountChannel

/-!
# The true decay rate of the split-count channel: `Is n = O(log n / n²)`

`Catalog/Novelty/SplitCountChannel.lean` proves `Is n → 0` through the crude
bound `Is n ≤ H₂(1/n)`, which only gives `Is n = O(log n / n)`.  That bound is
off by a whole factor of `n`, and the difference matters: it is the difference
between the split-count being a `1/n`-sized channel (a "residue dial" one could
hope to amplify) and a `1/n²`-sized one.

This file proves the sharp order of magnitude:

* `Is_eq_logSum` : an exact four-cell expansion of `Is n · log 2`;
* `Is_le_logBound` : `Is n ≤ (3 + log n) / (n² log 2)` for every real `n ≥ 2`;
* `Is_ge_logBound` : `Is n ≥ (1 + log n) / (n² log 2)`, the matching lower bound;
* `Is_sharp_rate` : hence the sharp law `n² · Is n / log₂ n → 1`;
* `Is_mul_self_tendsto_zero` : in particular `n · Is n → 0`.

Two conjectures recorded in `FUTURE_DIRECTIONS.md` after the first cycle are
therefore **false**, and we refute them formally:

* `not_exists_linear_lower_bound` refutes "`Is n ≥ c/n` for an absolute
  constant `c > 0`" (former Conjecture 4);
* `not_tendsto_one_of_scaled` refutes "`Is n · n / log₂ n → 1`"
  (former Conjecture 3).

The mechanism is visible in the expansion: the only cell that carries a
logarithm is `s = 2` (both factors split), whose probability is `1/n²`, and the
remaining cells contribute a total of at most `3/n²` because
`−log(1 − 1/n) ≤ (1/n)/(1 − 1/n)` and the `s = 0` cell of the majority class has
a *negative* log-ratio.
-/

namespace SplitCountDecay

open Finset Real Filter SplitCountLaw SplitCountChannel

variable {n : ℝ}

/-- **Exact four-cell expansion.**  Only four of the six cells of the fork table
are nonzero, and their log-ratios are `1/(1−x)`, `1/x` and `(1−2x)/(1−x)²` with
`x = 1/n`. -/
theorem Is_eq_logSum (hn : 2 ≤ n) :
    Is n * Real.log 2
      = 3 * (1 / n) * (1 - 1 / n) * (-Real.log (1 - 1 / n))
        + (1 / n) ^ 2 * Real.log n
        + (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hne : n ≠ 0 := ne_of_gt hn0
  have hn1 : (n : ℝ) - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hl2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  -- the four nonzero cells have log-ratios `(1-x)⁻¹`, `n` and `(1-2x)/(1-x)²`
  have r00 : (1 / n * ((n - 1) / n)) / (1 / n * ((n - 1) / n) ^ 2) = (1 - 1 / n)⁻¹ := by
    field_simp
  have r02 : (1 / n * (1 / n)) / (1 / n * (1 / n ^ 2)) = n := by
    field_simp
  have r11 : ((n - 1) / n * (2 / n)) / (((n - 1) / n) * (2 * (n - 1) / n ^ 2))
      = (1 - 1 / n)⁻¹ := by
    field_simp
  have r10 : ((n - 1) / n * ((n - 2) / n)) / (((n - 1) / n) * ((n - 1) / n) ^ 2)
      = (1 - 2 / n) / (1 - 1 / n) ^ 2 := by
    field_simp
  have hrow := rowMarg_forkJoint hn
  have hcol := colMarg_forkJoint hn
  simp only [Is, mutualInfo, hcol, hrow, Fin.sum_univ_two, Fin.sum_univ_three, forkJoint, prior,
    SplitCountChannel.cond, binom2, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
    Matrix.cons_val_two, Matrix.tail_cons, mul_zero, zero_mul]
  rw [r00, r02, r10, r11]
  simp only [Real.logb, Real.log_inv]
  generalize Real.log (1 - 1 / n) = L
  generalize Real.log n = M
  generalize Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) = K
  field_simp
  ring

/-- **The sharp upper bound.** `Is n ≤ (3 + log n)/(n² log 2)`: the split-count
channel is a `1/n²` channel, not a `1/n` channel. -/
theorem Is_le_logBound (hn : 2 ≤ n) :
    Is n ≤ (3 + Real.log n) / (n ^ 2 * Real.log 2) := by
  have hn0 : (0:ℝ) < n := by linarith
  have hne : n ≠ 0 := ne_of_gt hn0
  have hn1 : (n : ℝ) - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hx1 : (0:ℝ) < 1 - 1 / n := by rw [sub_pos, div_lt_one hn0]; linarith
  have hx2 : (0:ℝ) ≤ 1 - 2 / n := by
    rw [sub_nonneg, div_le_one hn0]; linarith
  -- the majority-class `s = 0` cell has a nonpositive log-ratio
  have hthird : (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) ≤ 0 := by
    have hle : (1 - 2 / n) / (1 - 1 / n) ^ 2 ≤ 1 := by
      rw [div_le_one (by positivity)]
      have hdiff : (1 - 1 / n) ^ 2 - (1 - 2 / n) = (1 / n) ^ 2 := by ring
      linarith [sq_nonneg (1 / n), hdiff]
    have := Real.log_nonpos (by positivity) hle
    have hco : 0 ≤ (1 - 1 / n) * (1 - 2 / n) := by positivity
    exact mul_nonpos_of_nonneg_of_nonpos hco this
  -- `-log (1 - x) ≤ x / (1 - x)`
  have hfirst : 3 * (1 / n) * (1 - 1 / n) * (-Real.log (1 - 1 / n)) ≤ 3 * (1 / n) ^ 2 := by
    have hlog : -Real.log (1 - 1 / n) ≤ (1 / n) / (1 - 1 / n) := by
      have h := Real.log_le_sub_one_of_pos (show (0:ℝ) < 1 / (1 - 1 / n) by positivity)
      rw [Real.log_div one_ne_zero (ne_of_gt hx1), Real.log_one, zero_sub] at h
      have : 1 / (1 - 1 / n) - 1 = (1 / n) / (1 - 1 / n) := by field_simp; ring
      linarith [this ▸ h]
    have hco : 0 ≤ 3 * (1 / n) * (1 - 1 / n) := by positivity
    calc 3 * (1 / n) * (1 - 1 / n) * (-Real.log (1 - 1 / n))
        ≤ 3 * (1 / n) * (1 - 1 / n) * ((1 / n) / (1 - 1 / n)) := by
          exact mul_le_mul_of_nonneg_left hlog hco
      _ = 3 * (1 / n) ^ 2 := by field_simp
  have hkey := Is_eq_logSum hn
  have hbound : Is n * Real.log 2 ≤ (3 + Real.log n) * (1 / n) ^ 2 := by
    rw [hkey]; nlinarith [hfirst, hthird]
  rw [le_div_iff₀ (by positivity)]
  calc Is n * (n ^ 2 * Real.log 2) = (Is n * Real.log 2) * n ^ 2 := by ring
    _ ≤ ((3 + Real.log n) * (1 / n) ^ 2) * n ^ 2 := by
        exact mul_le_mul_of_nonneg_right hbound (by positivity)
    _ = 3 + Real.log n := by field_simp

/-- `y · log y ≥ y - 1` for every `y ≥ 0` (with the junk value `log 0 = 0`). -/
lemma mul_log_ge_sub_one {y : ℝ} (hy : 0 ≤ y) : y - 1 ≤ y * Real.log y := by
  rcases eq_or_lt_of_le hy with h | h
  · simp [← h]
  · have h1 := Real.log_le_sub_one_of_pos (show (0:ℝ) < 1 / y by positivity)
    rw [Real.log_div one_ne_zero (ne_of_gt h), Real.log_one, zero_sub] at h1
    have h2 : y * (-Real.log y) ≤ y * (1 / y - 1) := mul_le_mul_of_nonneg_left h1 (le_of_lt h)
    have h3 : y * (1 / y - 1) = 1 - y := by field_simp
    nlinarith [h2, h3]

/-- **The matching lower bound.** `Is n ≥ (1 + log n)/(n² log 2)`: the `1/n²`
order of magnitude is sharp, and the logarithm really is there. -/
theorem Is_ge_logBound (hn : 2 ≤ n) :
    (1 + Real.log n) / (n ^ 2 * Real.log 2) ≤ Is n := by
  have hn0 : (0:ℝ) < n := by linarith
  have hne : n ≠ 0 := ne_of_gt hn0
  have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hn1 : (n : ℝ) - 1 ≠ 0 := by intro h; rw [sub_eq_zero] at h; linarith
  have hx1 : (0:ℝ) < 1 - 1 / n := by rw [sub_pos, div_lt_one hn0]; linarith
  have hx1ne : (1:ℝ) - 1 / n ≠ 0 := ne_of_gt hx1
  have hxh : (1:ℝ) / n ≤ 1 / 2 := by rw [div_le_div_iff₀ hn0 (by norm_num)]; linarith
  have hx2 : (0:ℝ) ≤ 1 - 2 / n := by rw [sub_nonneg, div_le_one hn0]; linarith
  -- first cell: `-log (1-x) ≥ x`
  have hfirst : 3 * (1 / n) ^ 2 * (1 - 1 / n)
      ≤ 3 * (1 / n) * (1 - 1 / n) * (-Real.log (1 - 1 / n)) := by
    have hlog : (1:ℝ) / n ≤ -Real.log (1 - 1 / n) := by
      have h := Real.log_le_sub_one_of_pos hx1
      linarith
    have hco : (0:ℝ) ≤ 3 * (1 / n) * (1 - 1 / n) := by positivity
    nlinarith [mul_le_mul_of_nonneg_left hlog hco]
  -- third cell: `v log v ≥ v - 1` with `v = (1-2x)/(1-x)²`
  have hthird : -((1 - 1 / n) * (1 / n) ^ 2)
      ≤ (1 - 1 / n) * (1 - 2 / n) * Real.log ((1 - 2 / n) / (1 - 1 / n) ^ 2) := by
    set v : ℝ := (1 - 2 / n) / (1 - 1 / n) ^ 2 with hv
    have hvnn : 0 ≤ v := by rw [hv]; positivity
    have hveq : (1 - 1 / n) * (1 - 2 / n) = (1 - 1 / n) ^ 3 * v := by
      rw [hv]; field_simp
    have hcube : (0:ℝ) ≤ (1 - 1 / n) ^ 3 := by positivity
    have hstep : (1 - 1 / n) ^ 3 * (v - 1) ≤ (1 - 1 / n) ^ 3 * (v * Real.log v) :=
      mul_le_mul_of_nonneg_left (mul_log_ge_sub_one hvnn) hcube
    have hval : (1 - 1 / n) ^ 3 * (v - 1) = -((1 - 1 / n) * (1 / n) ^ 2) := by
      rw [hv]; field_simp; ring
    rw [hveq, mul_assoc]
    linarith [hstep, hval]
  have hkey := Is_eq_logSum hn
  have hbound : (1 + Real.log n) * (1 / n) ^ 2 ≤ Is n * Real.log 2 := by
    rw [hkey]
    nlinarith [hfirst, hthird, hxh]
  rw [div_le_iff₀ (by positivity)]
  calc (1 + Real.log n) = ((1 + Real.log n) * (1 / n) ^ 2) * n ^ 2 := by field_simp
    _ ≤ (Is n * Real.log 2) * n ^ 2 := mul_le_mul_of_nonneg_right hbound (by positivity)
    _ = Is n * (n ^ 2 * Real.log 2) := by ring

/-- The comparison function `(3 + log x)/(x · log 2)` tends to `0`. -/
lemma tendsto_logBound : Tendsto (fun x : ℝ => (3 + Real.log x) / (x * Real.log 2)) atTop
    (nhds 0) := by
  have hl2 : (Real.log 2) ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  have h0 := Real.tendsto_pow_log_div_mul_add_atTop (Real.log 2) 0 0 hl2
  have h1 := Real.tendsto_pow_log_div_mul_add_atTop (Real.log 2) 0 1 hl2
  have hsum : Tendsto
      (fun x : ℝ => 3 * (Real.log x ^ 0 / (Real.log 2 * x + 0))
        + Real.log x ^ 1 / (Real.log 2 * x + 0)) atTop (nhds 0) := by
    simpa using (h0.const_mul (3:ℝ)).add h1
  refine hsum.congr' ?_
  filter_upwards [eventually_gt_atTop (0:ℝ)] with x hx
  field_simp
  ring

/-- **The channel is a `1/n²` channel:** `n · Is n → 0`. -/
theorem Is_mul_self_tendsto_zero : Tendsto (fun x : ℝ => x * Is x) atTop (nhds 0) := by
  refine squeeze_zero' ?_ ?_ tendsto_logBound
  · filter_upwards [eventually_ge_atTop (2:ℝ)] with x hx
    exact mul_nonneg (by linarith) (Is_nonneg hx)
  · filter_upwards [eventually_ge_atTop (2:ℝ)] with x hx
    have hx0 : (0:ℝ) < x := by linarith
    have := Is_le_logBound hx
    calc x * Is x ≤ x * ((3 + Real.log x) / (x ^ 2 * Real.log 2)) :=
          mul_le_mul_of_nonneg_left this (le_of_lt hx0)
      _ = (3 + Real.log x) / (x * Real.log 2) := by
          field_simp

/-- `(c + log x)/log x → 1`. -/
lemma tendsto_const_add_log_div_log (c : ℝ) :
    Tendsto (fun x : ℝ => (c + Real.log x) / Real.log x) atTop (nhds 1) := by
  have hlog : Tendsto (fun x : ℝ => Real.log x) atTop atTop := Real.tendsto_log_atTop
  have h1 : Tendsto (fun x : ℝ => c / Real.log x + 1) atTop (nhds (0 + 1)) :=
    (tendsto_const_nhds.div_atTop hlog).add tendsto_const_nhds
  rw [zero_add] at h1
  refine h1.congr' ?_
  filter_upwards [eventually_gt_atTop (1:ℝ)] with x hx
  have hne : Real.log x ≠ 0 := ne_of_gt (Real.log_pos hx)
  field_simp

/-- **The sharp asymptotic law.** `n² · Is n / log₂ n → 1`: the split-count
channel carries exactly `(log₂ n)/n² (1 + o(1))` bits. -/
theorem Is_sharp_rate :
    Tendsto (fun x : ℝ => x ^ 2 * Is x / Real.logb 2 x) atTop (nhds 1) := by
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' (tendsto_const_add_log_div_log 1)
    (tendsto_const_add_log_div_log 3) ?_ ?_
  · filter_upwards [eventually_ge_atTop (3:ℝ)] with x hx
    have hx0 : (0:ℝ) < x := by linarith
    have hlogpos : (0:ℝ) < Real.log x := Real.log_pos (by linarith)
    have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    have h := Is_ge_logBound (show (2:ℝ) ≤ x by linarith)
    rw [div_le_iff₀ (by positivity)] at h
    rw [Real.logb, div_div_eq_mul_div, div_le_div_iff_of_pos_right hlogpos]
    nlinarith [h]
  · filter_upwards [eventually_ge_atTop (3:ℝ)] with x hx
    have hx0 : (0:ℝ) < x := by linarith
    have hlogpos : (0:ℝ) < Real.log x := Real.log_pos (by linarith)
    have hl2 : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    have h := Is_le_logBound (show (2:ℝ) ≤ x by linarith)
    rw [le_div_iff₀ (by positivity)] at h
    rw [Real.logb, div_div_eq_mul_div, div_le_div_iff_of_pos_right hlogpos]
    nlinarith [h]

/-- **Refutation of the `c/n` lower bound** (former Conjecture 4): there is no
absolute constant `c > 0` with `Is n ≥ c/n` for all orders. -/
theorem not_exists_linear_lower_bound :
    ¬ ∃ c : ℝ, 0 < c ∧ ∀ x : ℝ, 2 ≤ x → c / x ≤ Is x := by
  rintro ⟨c, hc, hlb⟩
  have hev := (Is_mul_self_tendsto_zero.eventually (eventually_lt_nhds hc)).and
    (eventually_ge_atTop (2:ℝ))
  obtain ⟨x, hx1, hx2⟩ := hev.exists
  have hx0 : (0:ℝ) < x := by linarith
  have : c ≤ x * Is x := by
    have := hlb x hx2
    rw [div_le_iff₀ hx0] at this
    linarith [this]
  linarith

/-- **Refutation of the `log₂ n / n` decay rate** (former Conjecture 3): the
scaled quantity `Is n · n / log₂ n` tends to `0`, not to `1`. -/
theorem not_tendsto_one_of_scaled :
    ¬ Tendsto (fun x : ℝ => Is x * x / Real.logb 2 x) atTop (nhds 1) := by
  intro hone
  have hzero : Tendsto (fun x : ℝ => Is x * x / Real.logb 2 x) atTop (nhds 0) := by
    have hlog : Tendsto (fun x : ℝ => 1 / Real.logb 2 x) atTop (nhds 0) := by
      have : Tendsto (fun x : ℝ => Real.logb 2 x) atTop atTop :=
        Real.tendsto_logb_atTop (by norm_num)
      exact this.inv_tendsto_atTop.congr (fun x => (one_div _).symm)
    have := (Is_mul_self_tendsto_zero.mul hlog)
    simpa [mul_comm, div_eq_mul_inv, mul_assoc, one_div] using this
  have := tendsto_nhds_unique hone hzero
  norm_num at this

end SplitCountDecay