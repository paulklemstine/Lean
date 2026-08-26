import Physics.StackSquareCoreBasic

/-!
# Stack polyominoes with a square core: growth and asymptotics

The counting function `a(n) = stackSC n` of `Physics.StackSquareCoreBasic` is here shown to
sit strictly in the *stretched exponential* regime: it grows faster than any polynomial but
slower than any exponential, with

  `c √n ≤ log a(n) ≤ C √n log n`  (for `n` large).

In the statistical-mechanics reading of stacks as a discrete interface model, this says that
the entropy density `log a(n) / n` of square-core stacks vanishes, in contrast with the
exponential growth of unrestricted polyomino counts.

## Main results

* `stackSC_strictMono` : `a(n) < a(n+1)` for `n ≥ 4`;
* `log_stackSC_ge` : `((√n - 2)/2)·log 2 ≤ log a(n)` for `n ≥ 100`;
* `log_stackSC_le` : `log a(n) ≤ 4 √n (log 2 + log n)` for `n ≥ 1`;
* `stackSC_log_sqrt_bounds` : the two-sided bound above;
* `stackSC_log_div_tendsto_zero` : `log a(n)/n → 0`.
-/

namespace Physics.StackSquareCore

open Filter Real Asymptotics Finset

/-- `a` is strictly increasing from `n = 4` on: the `k = 2` layer gains one stack at each
step while no other layer can lose one. -/
theorem stackSC_strictMono (n : ℕ) (hn : 4 ≤ n) : stackSC n < stackSC (n + 1) := by
  rw [stackSC, stackSC]
  have hext : ∑ k ∈ range (n + 2), (if k * k ≤ n then conv (k - 1) (n - k * k) else 0)
      = ∑ k ∈ range (n + 1), (if k * k ≤ n then conv (k - 1) (n - k * k) else 0) := by
    rw [Finset.sum_range_succ, if_neg (by nlinarith), add_zero]
  refine lt_of_le_of_lt (le_of_eq hext.symm) (Finset.sum_lt_sum ?_ ?_)
  · intro k _
    by_cases hkn : k * k ≤ n
    · rw [if_pos hkn, if_pos (by omega : k * k ≤ n + 1)]
      match k, hkn with
      | 0, _ =>
          show conv 0 (n - 0 * 0) ≤ conv 0 (n + 1 - 0 * 0)
          simp only [conv_zero_left]; split_ifs <;> omega
      | 1, _ =>
          show conv 0 (n - 1 * 1) ≤ conv 0 (n + 1 - 1 * 1)
          simp only [conv_zero_left]; split_ifs <;> omega
      | (k + 2), hkn => exact conv_mono (k + 2 - 1) (by omega) (by omega)
    · rw [if_neg hkn]; exact Nat.zero_le _
  · refine ⟨2, Finset.mem_range.2 (by omega), ?_⟩
    rw [if_pos (by omega : 2 * 2 ≤ n), if_pos (by omega : 2 * 2 ≤ n + 1)]
    show conv 1 (n - 2 * 2) < conv 1 (n + 1 - 2 * 2)
    rw [conv_one_left, conv_one_left]
    omega

lemma sqrt_lt_natSqrt_add_one (n : ℕ) : Real.sqrt n < (Nat.sqrt n : ℝ) + 1 := by
  have h : (n : ℝ) < ((Nat.sqrt n : ℝ) + 1) ^ 2 := by
    have := Nat.lt_succ_sqrt n
    have hc : (n : ℝ) < ((Nat.sqrt n + 1 : ℕ) : ℝ) * ((Nat.sqrt n + 1 : ℕ) : ℝ) := by
      exact_mod_cast this
    push_cast at hc
    nlinarith [hc]
  have h0 : (0:ℝ) ≤ (Nat.sqrt n : ℝ) + 1 := by positivity
  nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ (n:ℝ) by positivity),
    Real.sqrt_nonneg (n : ℝ), h, h0]

lemma log_stackSC_ge (n : ℕ) (hn : 100 ≤ n) :
    (Real.sqrt n - 2) / 2 * Real.log 2 ≤ Real.log (stackSC n) := by
  set s := Nat.sqrt n with hs
  set m := s / 2 with hm
  have hs2 : s * s ≤ n := Nat.sqrt_le n
  have hs10 : 10 ≤ s := Nat.le_sqrt.2 (by nlinarith)
  have h2m : 2 * m ≤ s := by omega
  have hcond : 3 * m * m + 11 * m + 8 ≤ 2 * n := by nlinarith
  have hpow : 2 ^ m ≤ stackSC n := two_pow_le_stackSC m n hcond
  have hposR : (0 : ℝ) < (2 : ℝ) ^ m := by positivity
  have hle : ((2 : ℝ) ^ m) ≤ (stackSC n : ℝ) := by exact_mod_cast hpow
  have hlog : (m : ℝ) * Real.log 2 ≤ Real.log (stackSC n) := by
    calc (m : ℝ) * Real.log 2 = Real.log ((2 : ℝ) ^ m) := by rw [Real.log_pow]
      _ ≤ Real.log (stackSC n) := Real.log_le_log hposR hle
  have hmR : (Real.sqrt n - 2) / 2 ≤ (m : ℝ) := by
    have h1 : Real.sqrt n < (s : ℝ) + 1 := sqrt_lt_natSqrt_add_one n
    have h2 : (s : ℝ) ≤ 2 * (m : ℝ) + 1 := by
      have : s ≤ 2 * m + 1 := by omega
      exact_mod_cast this
    linarith
  have hlog2 : (0:ℝ) ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  calc (Real.sqrt n - 2) / 2 * Real.log 2 ≤ (m : ℝ) * Real.log 2 :=
        mul_le_mul_of_nonneg_right hmR hlog2
    _ ≤ Real.log (stackSC n) := hlog

lemma natSqrt_le_sqrt (n : ℕ) : (Nat.sqrt n : ℝ) ≤ Real.sqrt n := by
  rw [Real.le_sqrt (by positivity) (by positivity)]
  have := Nat.sqrt_le' n
  calc ((Nat.sqrt n : ℝ)) ^ 2 = ((Nat.sqrt n ^ 2 : ℕ) : ℝ) := by push_cast; ring
    _ ≤ (n : ℝ) := by exact_mod_cast this

lemma log_stackSC_le (n : ℕ) (hn : 1 ≤ n) :
    Real.log (stackSC n) ≤ 4 * Real.sqrt n * (Real.log 2 + Real.log n) := by
  have hn' : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hs1 : (1 : ℝ) ≤ Real.sqrt n := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt hn'
  have hlogn1 : Real.log ((n : ℝ) + 1) ≤ Real.log 2 + Real.log n := by
    have h2 : ((n : ℝ) + 1) ≤ 2 * n := by linarith
    calc Real.log ((n : ℝ) + 1) ≤ Real.log (2 * n) := Real.log_le_log (by positivity) h2
      _ = Real.log 2 + Real.log n := Real.log_mul (by norm_num) (by positivity)
  have hlogpos : 0 ≤ Real.log ((n : ℝ) + 1) := Real.log_nonneg (by linarith)
  have hbound : (stackSC n : ℝ) ≤ ((n : ℝ) + 1) ^ (2 * Nat.sqrt n + 2) := by
    have := stackSC_le_pow n
    have hc : ((stackSC n : ℕ) : ℝ) ≤ (((n + 1) ^ (2 * Nat.sqrt n + 2) : ℕ) : ℝ) := by
      exact_mod_cast this
    simpa using hc
  have hlog : Real.log (stackSC n) ≤ (2 * (Nat.sqrt n : ℝ) + 2) * Real.log ((n : ℝ) + 1) := by
    rcases Nat.eq_zero_or_pos (stackSC n) with h0 | h0
    · rw [h0]
      simp only [Nat.cast_zero, Real.log_zero]
      have : (0:ℝ) ≤ 2 * (Nat.sqrt n : ℝ) + 2 := by positivity
      exact mul_nonneg this hlogpos
    · have hpos : (0 : ℝ) < (stackSC n : ℝ) := by exact_mod_cast h0
      calc Real.log (stackSC n) ≤ Real.log (((n : ℝ) + 1) ^ (2 * Nat.sqrt n + 2)) :=
            Real.log_le_log hpos hbound
        _ = ((2 * Nat.sqrt n + 2 : ℕ) : ℝ) * Real.log ((n : ℝ) + 1) := Real.log_pow _ _
        _ = (2 * (Nat.sqrt n : ℝ) + 2) * Real.log ((n : ℝ) + 1) := by push_cast; ring
  have hcoef : 2 * (Nat.sqrt n : ℝ) + 2 ≤ 4 * Real.sqrt n := by
    have := natSqrt_le_sqrt n
    linarith
  calc Real.log (stackSC n) ≤ (2 * (Nat.sqrt n : ℝ) + 2) * Real.log ((n : ℝ) + 1) := hlog
    _ ≤ (4 * Real.sqrt n) * Real.log ((n : ℝ) + 1) := by
        exact mul_le_mul_of_nonneg_right hcoef hlogpos
    _ ≤ (4 * Real.sqrt n) * (Real.log 2 + Real.log n) := by
        refine mul_le_mul_of_nonneg_left hlogn1 (by positivity)

/-- **Vanishing entropy density**: `log a(n) / n → 0`, so square-core stacks are far less
numerous than general polyominoes (whose count grows exponentially in the area). -/
theorem stackSC_log_div_tendsto_zero :
    Tendsto (fun n : ℕ => Real.log (stackSC n) / n) atTop (nhds 0) := by
  have hlogdiv : Tendsto (fun n : ℕ => Real.log n / Real.sqrt n) atTop (nhds 0) := by
    have h : Real.log =o[atTop] fun x : ℝ => x ^ (1 / 2 : ℝ) :=
      isLittleO_log_rpow_atTop (by norm_num)
    have h' : Tendsto (fun x : ℝ => Real.log x / Real.sqrt x) atTop (nhds 0) := by
      refine h.tendsto_div_nhds_zero.congr' ?_
      filter_upwards [eventually_ge_atTop (0 : ℝ)] with x _
      rw [Real.sqrt_eq_rpow]
    exact h'.comp tendsto_natCast_atTop_atTop
  have hinv : Tendsto (fun n : ℕ => 1 / Real.sqrt n) atTop (nhds 0) := by
    have h1 : Tendsto (fun n : ℕ => Real.sqrt n) atTop atTop :=
      tendsto_sqrt_atTop.comp tendsto_natCast_atTop_atTop
    simpa [one_div] using h1.inv_tendsto_atTop
  have hg : Tendsto
      (fun n : ℕ => 4 * Real.log 2 * (1 / Real.sqrt n) + 4 * (Real.log n / Real.sqrt n))
      atTop (nhds 0) := by
    simpa using (hinv.const_mul (4 * Real.log 2)).add (hlogdiv.const_mul 4)
  refine squeeze_zero' ?_ ?_ hg
  · filter_upwards [eventually_ge_atTop 4] with n hn
    have h1 : 1 ≤ stackSC n := stackSC_pos n (by omega) (by omega)
    have h2 : (1 : ℝ) ≤ (stackSC n : ℝ) := by exact_mod_cast h1
    exact div_nonneg (Real.log_nonneg h2) (by positivity)
  · filter_upwards [eventually_ge_atTop 4] with n hn
    have hnpos : (0 : ℝ) < (n : ℝ) := by
      have : (0:ℕ) < n := by omega
      exact_mod_cast this
    have hspos : (0 : ℝ) < Real.sqrt n := Real.sqrt_pos.2 hnpos
    have hss : Real.sqrt n * Real.sqrt n = (n : ℝ) := Real.mul_self_sqrt (le_of_lt hnpos)
    rw [div_le_iff₀ hnpos]
    have hle := log_stackSC_le n (by omega)
    calc Real.log (stackSC n) ≤ 4 * Real.sqrt n * (Real.log 2 + Real.log n) := hle
      _ = (4 * Real.log 2 * (1 / Real.sqrt n) + 4 * (Real.log n / Real.sqrt n)) * n := by
          field_simp
          ring_nf
          nlinarith [hss]

/-- **Stretched-exponential growth, two-sided.** -/
theorem stackSC_log_sqrt_bounds (n : ℕ) (hn : 100 ≤ n) :
    (Real.sqrt n - 2) / 2 * Real.log 2 ≤ Real.log (stackSC n) ∧
      Real.log (stackSC n) ≤ 4 * Real.sqrt n * (Real.log 2 + Real.log n) :=
  ⟨log_stackSC_ge n hn, log_stackSC_le n (by omega)⟩

end Physics.StackSquareCore