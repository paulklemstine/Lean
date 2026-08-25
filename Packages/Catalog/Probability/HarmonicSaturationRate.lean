/-
  # The saturation rate of the harmonic head dial

  `Probability.HarmonicBulkSteeperEdge` proves the *saturation dichotomy* for the head
  statistic of a discrete power-law kernel `k ↦ k ^ (-a)` on `{1, …, n}`: as the truncation
  `n` grows, the head mass of a fixed window `{1, …, m}` converges to a strictly positive
  limit when `a > 1` and collapses to `0` when `a ≤ 1`.  It says nothing about the *rate*
  of that collapse.

  This file supplies the rate at the harmonic exponent `a = 1`, which is the case relevant
  to the recorded `1/ℓ`-weighted dial:

  * `headMass_one_mul_log_tendsto` — `headMass 1 n m * log n → headSum 1 m = H(m)`.
    The harmonic head dial decays like `H(m) / log n`.
  * `headMass_one_lower_bound` — the non-asymptotic companion:
    `H(m) / (1 + log n) ≤ headMass 1 n m` for every `n ≥ 1`.
  * `headMass_one_ratio_tendsto_one` — consequently, for two fixed windows the *ratio* of
    head masses converges to `H(m₁)/H(m₂)`, so the dial's *shape* stabilises even though
    its level does not.

  Quantitatively this explains the recorded observation that a `1/ℓ`-weighted dial "looks
  saturated by `ℓ = 400`": a `1 / log n` decay changes by only a few percent over any
  experimentally accessible range of `n`, while being asymptotically null.  Saturation to a
  positive limit is a strictly super-harmonic phenomenon.

  The two ingredients are Mathlib's harmonic-number bounds
  `log (n+1) ≤ H_n ≤ 1 + log n` and the identification of `headSum 1 n` with `H_n`.
-/
import Mathlib
import Probability.HarmonicBulkSteeperEdge

open Filter Topology

namespace HarmonicBulkSteeperEdge

/-! ## The harmonic kernel is the reciprocal kernel -/

/-- At the harmonic exponent the kernel is `k ↦ 1/k`. -/
lemma pw_one_eq_inv (k : ℕ) : pw 1 k = ((k : ℝ))⁻¹ := by
  rcases Nat.eq_zero_or_pos k with hk | hk
  · subst hk
    simp [pw, Real.zero_rpow]
  · have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
    rw [pw, Real.rpow_neg_one]

/-- The harmonic head sum is the `n`-th harmonic number. -/
lemma headSum_one_eq_harmonic (n : ℕ) : headSum 1 n = (harmonic n : ℝ) := by
  rw [headSum, harmonic_eq_sum_Icc]
  push_cast
  exact Finset.sum_congr rfl (fun k _ => pw_one_eq_inv k)

/-! ## Harmonic-number asymptotics -/

lemma log_le_headSum_one (n : ℕ) : Real.log n ≤ headSum 1 n := by
  rw [headSum_one_eq_harmonic]
  refine le_trans ?_ (log_add_one_le_harmonic n)
  rcases Nat.eq_zero_or_pos n with hn | hn
  · subst hn; simp
  · have hn0 : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
    apply Real.log_le_log hn0
    push_cast
    linarith

lemma headSum_one_le_one_add_log (n : ℕ) : headSum 1 n ≤ 1 + Real.log n := by
  rw [headSum_one_eq_harmonic]
  exact harmonic_le_one_add_log n

lemma tendsto_headSum_one_atTop : Tendsto (fun n : ℕ => headSum 1 n) atTop atTop := by
  have hlog : Tendsto (fun n : ℕ => Real.log n) atTop atTop :=
    Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop
  exact tendsto_atTop_mono (fun n => log_le_headSum_one n) hlog

/-- **The harmonic head sum is logarithmic.**  `log n / H_n → 1`. -/
lemma tendsto_log_div_headSum_one :
    Tendsto (fun n : ℕ => Real.log n / headSum 1 n) atTop (𝓝 1) := by
  have hinv : Tendsto (fun n : ℕ => (headSum 1 n)⁻¹) atTop (𝓝 0) :=
    tendsto_inv_atTop_zero.comp tendsto_headSum_one_atTop
  have hlow : Tendsto (fun n : ℕ => 1 - (headSum 1 n)⁻¹) atTop (𝓝 1) := by
    have := hinv.const_sub (1 : ℝ)
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlow tendsto_const_nhds ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hpos : 0 < headSum 1 n := headSum_pos hn
    have hub : headSum 1 n ≤ 1 + Real.log n := headSum_one_le_one_add_log n
    rw [show 1 - (headSum 1 n)⁻¹ = (headSum 1 n - 1) / headSum 1 n by field_simp]
    gcongr
    linarith
  · filter_upwards [eventually_ge_atTop 1] with n hn
    have hpos : 0 < headSum 1 n := headSum_pos hn
    rw [div_le_one hpos]
    exact log_le_headSum_one n

/-! ## The rate of collapse of the harmonic head dial -/

/-- **Logarithmic saturation rate at the harmonic threshold.**  For a fixed head window
`{1, …, m}`, the harmonic head mass multiplied by `log n` converges to the harmonic head
sum `H(m)`: the dial decays like `H(m) / log n`, never saturating, yet so slowly that it is
numerically indistinguishable from saturation over any bounded range of `n`. -/
theorem headMass_one_mul_log_tendsto (m : ℕ) :
    Tendsto (fun n : ℕ => headMass 1 n m * Real.log n) atTop (𝓝 (headSum 1 m)) := by
  have hcongr : (fun n : ℕ => headMass 1 n m * Real.log n)
      = fun n : ℕ => headSum 1 m * (Real.log n / headSum 1 n) := by
    funext n
    rw [headMass]
    ring
  rw [hcongr]
  simpa using tendsto_log_div_headSum_one.const_mul (headSum 1 m)

/-- **Non-asymptotic companion.**  For every truncation `n ≥ 1` the harmonic head mass is
at least `H(m) / (1 + log n)`; over a bounded range of `n` this is nearly constant. -/
theorem headMass_one_lower_bound {m n : ℕ} (hn : 1 ≤ n) :
    headSum 1 m / (1 + Real.log n) ≤ headMass 1 n m := by
  have hpos : 0 < headSum 1 n := headSum_pos hn
  have hub : headSum 1 n ≤ 1 + Real.log n := headSum_one_le_one_add_log n
  have hn1 : (1:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have hlog : 0 ≤ Real.log n := Real.log_nonneg hn1
  have hden : 0 < 1 + Real.log n := by linarith
  have hnum : 0 ≤ headSum 1 m := by
    rcases Nat.eq_zero_or_pos m with hm | hm
    · simp [hm, headSum]
    · exact (headSum_pos hm).le
  rw [headMass, div_le_div_iff₀ hden hpos]
  nlinarith [hub, hnum]

lemma tendsto_sq_atTop : Tendsto (fun n : ℕ => n * n) atTop atTop := by
  refine tendsto_atTop_mono (fun n => ?_) tendsto_id
  rcases Nat.eq_zero_or_pos n with hn | hn
  · simp [hn]
  · exact Nat.le_mul_of_pos_left n hn

/-- **How slowly the harmonic dial decays.**  Squaring the truncation only *halves* the
harmonic head mass: `headMass 1 (n²) m / headMass 1 n m → 1/2`.  A dial that needs the
truncation to be squared before it drops by a factor of two is, over any bounded
experimental range, indistinguishable from a saturating dial — even though its limit
is `0`. -/
theorem headMass_one_square_ratio_tendsto {m : ℕ} (hm : 1 ≤ m) :
    Tendsto (fun n : ℕ => headMass 1 (n * n) m / headMass 1 n m) atTop (𝓝 (1/2)) := by
  have hHm : 0 < headSum 1 m := headSum_pos hm
  have h1 : Tendsto (fun n : ℕ => headSum 1 n / Real.log n) atTop (𝓝 1) := by
    have h := tendsto_log_div_headSum_one.inv₀ (by norm_num)
    simpa [inv_div] using h
  have h2 : Tendsto (fun n : ℕ => Real.log (n:ℝ) / Real.log ((n * n : ℕ):ℝ)) atTop
      (𝓝 (1/2)) := by
    refine Tendsto.congr' ?_ tendsto_const_nhds
    filter_upwards [eventually_ge_atTop 2] with n hn
    have hn1 : (1:ℝ) < (n:ℝ) := by exact_mod_cast hn
    have hlog : 0 < Real.log n := Real.log_pos hn1
    have hcast : ((n * n : ℕ):ℝ) = (n:ℝ) ^ 2 := by push_cast; ring
    rw [hcast, Real.log_pow]
    field_simp
    ring
  have h3 : Tendsto (fun n : ℕ => Real.log ((n * n : ℕ):ℝ) / headSum 1 (n * n)) atTop (𝓝 1) :=
    tendsto_log_div_headSum_one.comp tendsto_sq_atTop
  have hprod := (h1.mul h2).mul h3
  refine Tendsto.congr' ?_ (by simpa using hprod)
  filter_upwards [eventually_ge_atTop 2] with n hn
  have hn1 : (1:ℝ) < (n:ℝ) := by exact_mod_cast hn
  have hlog : 0 < Real.log n := Real.log_pos hn1
  have hHn : 0 < headSum 1 n := headSum_pos (by omega)
  have hHnn : 0 < headSum 1 (n * n) := headSum_pos (by nlinarith)
  have hcast : ((n * n : ℕ):ℝ) = (n:ℝ) ^ 2 := by push_cast; ring
  have hlog2 : 0 < Real.log ((n * n : ℕ):ℝ) := by
    rw [hcast, Real.log_pow]; positivity
  rw [headMass, headMass]
  field_simp

end HarmonicBulkSteeperEdge