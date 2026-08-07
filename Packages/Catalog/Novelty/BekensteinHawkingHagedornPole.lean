import Novelty.BekensteinHawkingEnsembles

/-!
# The order of the Hagedorn pole: exact residues for the mean area and the variance

`Novelty.BekensteinHawkingEnsembles` proves *qualitative* ensemble inequivalence at the
Hagedorn point of the quantum isolated horizon: both the partition function
`Z(x) = ∑_A W(A) x^A` and the canonical mean area `⟨A⟩(x)` diverge as the fugacity `x`
approaches `x_c = 1/(2+√2)` from below.  `FUTURE_DIRECTIONS.md`, Conjecture 2, asks for the
*quantitative* form: the order of the pole and the sign of the horizon specific heat.

This file closes that conjecture.  Using the exact microstate closed form
`4 W(A) = (1+√2)(2+√2)^A + (1-√2)(2-√2)^A` we compute the first two canonical moments in
closed form and read off the exact residues.

## Main results

* `areaWeighted_closed_form` : `∑_A A W(A) x^A = 2x(1-x)/(2x²-4x+1)²`;
* `areaSqWeighted_closed_form` : `∑_A A² W(A) x^A = 2x(4x³-6x²+2x+1)/(2x²-4x+1)³`;
* `meanArea_closed_form` : `⟨A⟩(x) = 2x / ((2x²-4x+1)(1-x))` — the mean horizon area is a
  rational function of the fugacity with a **simple** pole at `x_c`;
* `areaVariance_closed_form` : `⟨A²⟩ - ⟨A⟩² = 2x(4x³-6x²+1) / ((2x²-4x+1)²(1-x)²)`, a
  **double** pole at `x_c`;
* `areaVariance_pos` : the variance — hence the horizon specific heat `C = β²·Var` — is
  strictly positive throughout the subcritical regime `0 < x < x_c`: the canonical horizon
  is thermodynamically stable below the Hagedorn temperature;
* `meanArea_pole_residue` : `(x_c - x)·⟨A⟩(x) → x_c` as `x ↑ x_c`, so the pole of the mean
  area is simple with residue exactly `x_c = 1/(2+√2)`;
* `areaVariance_pole_residue` : `(x_c - x)²·Var(x) → x_c²`, so the pole of the variance is
  of order exactly two with residue `x_c²`;
* `areaVariance_tendsto_atTop` : consequently the variance, and with it the specific heat,
  diverges at the Hagedorn point.

Every statement is an exact identity or an exact limit: no asymptotic estimate is involved.
The two residues `x_c` and `x_c²` are the quantitative content of the Hagedorn transition.
-/

open Filter Topology

namespace BekensteinHawking

/-! ## The spectral coefficients of the microstate count -/

/-- The weight of the dominant eigenvalue `2+√2` in the closed form of `W`. -/
noncomputable def specA : ℝ := (1 + Real.sqrt 2) / 4

/-- The weight of the subdominant eigenvalue `2-√2` in the closed form of `W`. -/
noncomputable def specB : ℝ := (1 - Real.sqrt 2) / 4

lemma specA_add_specB : specA + specB = 1 / 2 := by
  unfold specA specB; ring

lemma growth_add_growth' : growth + growth' = 4 := by
  unfold growth growth'; ring

lemma growth_mul_growth' : growth * growth' = 2 := by
  unfold growth growth'; nlinarith [sqrt_two_sq]

lemma spec_moment_one : specA * growth + specB * growth' = 2 := by
  unfold specA specB growth growth'; nlinarith [sqrt_two_sq]

lemma spec_moment_one' : specA * growth' + specB * growth = 0 := by
  unfold specA specB growth growth'; nlinarith [sqrt_two_sq]

lemma spec_moment_two : specA * growth ^ 2 + specB * growth' ^ 2 = 7 := by
  unfold specA specB growth growth'; nlinarith [sqrt_two_sq]

lemma spec_moment_two' : specA * growth' ^ 2 + specB * growth ^ 2 = -1 := by
  unfold specA specB growth growth'; nlinarith [sqrt_two_sq]

/-- The closed form of the microstate count in spectral notation. -/
lemma hStates_spectral (n : ℕ) (hn : 1 ≤ n) :
    (hStates n : ℝ) = specA * growth ^ n + specB * growth' ^ n := by
  have h := hStates_closed_form n hn
  unfold specA specB
  linarith

/-! ## A second-moment geometric series -/

lemma two_mul_choose_two (n : ℕ) : 2 * ((n + 2).choose 2) = (n + 1) * (n + 2) := by
  induction n with
  | zero => decide
  | succ n ih =>
    rw [show n + 1 + 2 = (n + 2) + 1 by ring, Nat.choose_succ_succ (n + 2) 1,
      Nat.choose_one_right]
    ring_nf
    ring_nf at ih
    omega

/-- `∑ n² r^n = r(1+r)/(1-r)³` for `|r| < 1`.  Obtained from the second binomial
transform `∑ C(n+2,2) r^n = (1-r)^{-3}` via `n² = (n+1)(n+2) - 3n - 2`. -/
lemma hasSum_sq_mul_geometric {r : ℝ} (hr : ‖r‖ < 1) :
    HasSum (fun n : ℕ => (n : ℝ) ^ 2 * r ^ n) (r * (1 + r) / (1 - r) ^ 3) := by
  have h2 := hasSum_choose_mul_geometric_of_norm_lt_one (𝕜 := ℝ) 2 hr
  have h1 := hasSum_coe_mul_geometric_of_norm_lt_one hr
  have h0 := hasSum_geometric_of_norm_lt_one hr
  have hne : (1 : ℝ) - r ≠ 0 := by
    intro h
    rw [show r = 1 by linarith] at hr
    simp at hr
  have H := ((h2.mul_left 2).sub (h1.mul_left 3)).sub (h0.mul_left 2)
  have hval : 2 * (1 / (1 - r) ^ (2 + 1)) - 3 * (r / (1 - r) ^ 2) - 2 * (1 - r)⁻¹
      = r * (1 + r) / (1 - r) ^ 3 := by
    field_simp
    ring
  rw [hval] at H
  refine H.congr_fun ?_
  intro n
  have hc : ((n + 2).choose 2 : ℝ) = ((n : ℝ) + 1) * ((n : ℝ) + 2) / 2 := by
    have h := two_mul_choose_two n
    have h' : ((2 * ((n + 2).choose 2) : ℕ) : ℝ) = (((n + 1) * (n + 2) : ℕ) : ℝ) := by
      exact_mod_cast h
    push_cast at h'
    linarith
  rw [hc]
  ring

/-! ## Closed forms for the canonical moments -/

section Moments

variable {x : ℝ}

lemma norm_growth_mul_lt (hx0 : 0 ≤ x) (hx : x < growth⁻¹) : ‖growth * x‖ < 1 := by
  have hgpos : (0:ℝ) < growth := growth_pos
  have hgx : growth * x < 1 := by
    have h := mul_lt_mul_of_pos_left hx hgpos
    rwa [mul_inv_cancel₀ (ne_of_gt hgpos)] at h
  rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
  exact hgx

lemma norm_growth'_mul_lt (hx0 : 0 ≤ x) (hx : x < growth⁻¹) : ‖growth' * x‖ < 1 := by
  have hgpos : (0:ℝ) < growth' := growth'_pos
  have h1 : growth' * x ≤ growth * x := mul_le_mul_of_nonneg_right growth'_le_growth hx0
  have h2 : growth * x < 1 := by
    have := norm_growth_mul_lt hx0 hx
    rwa [Real.norm_eq_abs, abs_of_nonneg (by positivity [growth_pos])] at this
  rw [Real.norm_eq_abs, abs_of_nonneg (by positivity)]
  linarith

lemma one_sub_growth_mul_ne (hx0 : 0 ≤ x) (hx : x < growth⁻¹) : (1 : ℝ) - growth * x ≠ 0 := by
  have h := norm_growth_mul_lt hx0 hx
  rw [Real.norm_eq_abs, abs_of_nonneg (by positivity [growth_pos])] at h
  intro hc; linarith

lemma one_sub_growth'_mul_ne (hx0 : 0 ≤ x) (hx : x < growth⁻¹) : (1 : ℝ) - growth' * x ≠ 0 := by
  have h := norm_growth'_mul_lt hx0 hx
  rw [Real.norm_eq_abs, abs_of_nonneg (by positivity [growth'_pos])] at h
  intro hc; linarith

/-- The factorisation of the denominator of the partition function into the two
eigenvalue factors. -/
lemma denom_factor (x : ℝ) :
    (1 - growth * x) * (1 - growth' * x) = 2 * x ^ 2 - 4 * x + 1 := by
  linear_combination (-x) * growth_add_growth' + x ^ 2 * growth_mul_growth'

lemma denom_ne (hx0 : 0 ≤ x) (hx : x < growth⁻¹) : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := by
  rw [← denom_factor x]
  exact mul_ne_zero (one_sub_growth_mul_ne hx0 hx) (one_sub_growth'_mul_ne hx0 hx)

/-- **Closed form of the area-weighted partition sum.** -/
theorem areaWeighted_closed_form (hx0 : 0 ≤ x) (hx : x < growth⁻¹) :
    areaWeighted x = 2 * x * (1 - x) / (2 * x ^ 2 - 4 * x + 1) ^ 2 := by
  have hu := norm_growth_mul_lt hx0 hx
  have hv := norm_growth'_mul_lt hx0 hx
  have hune := one_sub_growth_mul_ne hx0 hx
  have hvne := one_sub_growth'_mul_ne hx0 hx
  have H := ((hasSum_coe_mul_geometric_of_norm_lt_one hu).mul_left specA).add
    ((hasSum_coe_mul_geometric_of_norm_lt_one hv).mul_left specB)
  have hterm : ∀ n : ℕ, (n : ℝ) * ((hStates n : ℝ) * x ^ n)
      = specA * ((n : ℝ) * (growth * x) ^ n) + specB * ((n : ℝ) * (growth' * x) ^ n) := by
    intro n
    match n with
    | 0 => simp
    | (m + 1) =>
      rw [hStates_spectral (m + 1) (by omega), mul_pow, mul_pow]
      ring
  have hsum : HasSum (fun n : ℕ => (n : ℝ) * ((hStates n : ℝ) * x ^ n))
      (specA * (growth * x / (1 - growth * x) ^ 2)
        + specB * (growth' * x / (1 - growth' * x) ^ 2)) := H.congr_fun hterm
  rw [areaWeighted, hsum.tsum_eq]
  -- pure algebra from here on
  have key : specA * (growth * x) * (1 - growth' * x) ^ 2
      + specB * (growth' * x) * (1 - growth * x) ^ 2 = 2 * x * (1 - x) := by
    have expand : specA * (growth * x) * (1 - growth' * x) ^ 2
        + specB * (growth' * x) * (1 - growth * x) ^ 2
        = (specA * growth + specB * growth') * x
          - 2 * (growth * growth') * (specA + specB) * x ^ 2
          + (growth * growth') * (specA * growth' + specB * growth) * x ^ 3 := by ring
    rw [expand, spec_moment_one, growth_mul_growth', specA_add_specB, spec_moment_one']
    ring
  have hu2 : (1 - growth * x) ^ 2 ≠ 0 := pow_ne_zero 2 hune
  have hv2 : (1 - growth' * x) ^ 2 ≠ 0 := pow_ne_zero 2 hvne
  have hnum : specA * (growth * x) * (1 - growth' * x) ^ 2
      + (1 - growth * x) ^ 2 * (specB * (growth' * x)) = 2 * x * (1 - x) := by
    linear_combination key
  have hden : (1 - growth * x) ^ 2 * (1 - growth' * x) ^ 2 = (2 * x ^ 2 - 4 * x + 1) ^ 2 := by
    rw [← denom_factor]; ring
  rw [← mul_div_assoc, ← mul_div_assoc, div_add_div _ _ hu2 hv2, hnum, hden]

/-- The second-moment partition sum `∑ A² W(A) x^A`. -/
noncomputable def areaSqWeighted (x : ℝ) : ℝ := ∑' n : ℕ, (n : ℝ) ^ 2 * ((hStates n : ℝ) * x ^ n)

/-- **Closed form of the second-moment partition sum.** -/
theorem areaSqWeighted_closed_form (hx0 : 0 ≤ x) (hx : x < growth⁻¹) :
    areaSqWeighted x
      = 2 * x * (4 * x ^ 3 - 6 * x ^ 2 + 2 * x + 1) / (2 * x ^ 2 - 4 * x + 1) ^ 3 := by
  have hu := norm_growth_mul_lt hx0 hx
  have hv := norm_growth'_mul_lt hx0 hx
  have hune := one_sub_growth_mul_ne hx0 hx
  have hvne := one_sub_growth'_mul_ne hx0 hx
  have H := ((hasSum_sq_mul_geometric hu).mul_left specA).add
    ((hasSum_sq_mul_geometric hv).mul_left specB)
  have hterm : ∀ n : ℕ, (n : ℝ) ^ 2 * ((hStates n : ℝ) * x ^ n)
      = specA * ((n : ℝ) ^ 2 * (growth * x) ^ n)
        + specB * ((n : ℝ) ^ 2 * (growth' * x) ^ n) := by
    intro n
    match n with
    | 0 => simp
    | (m + 1) =>
      rw [hStates_spectral (m + 1) (by omega), mul_pow, mul_pow]
      ring
  have hsum : HasSum (fun n : ℕ => (n : ℝ) ^ 2 * ((hStates n : ℝ) * x ^ n))
      (specA * ((growth * x) * (1 + growth * x) / (1 - growth * x) ^ 3)
        + specB * ((growth' * x) * (1 + growth' * x) / (1 - growth' * x) ^ 3)) :=
    H.congr_fun hterm
  rw [areaSqWeighted, hsum.tsum_eq]
  have key : specA * (growth * x) * (1 + growth * x) * (1 - growth' * x) ^ 3
      + specB * (growth' * x) * (1 + growth' * x) * (1 - growth * x) ^ 3
      = 2 * x * (4 * x ^ 3 - 6 * x ^ 2 + 2 * x + 1) := by
    have expand : specA * (growth * x) * (1 + growth * x) * (1 - growth' * x) ^ 3
        + specB * (growth' * x) * (1 + growth' * x) * (1 - growth * x) ^ 3
        = (specA * growth + specB * growth') * x
          + (specA * growth ^ 2 + specB * growth' ^ 2) * x ^ 2
          - 3 * (growth * growth') * (specA + specB) * x ^ 2
          - 3 * (growth * growth') * (specA * growth + specB * growth') * x ^ 3
          + 3 * (growth * growth') * (specA * growth' + specB * growth) * x ^ 3
          + 3 * (growth * growth') ^ 2 * (specA + specB) * x ^ 4
          - (growth * growth') * (specA * growth' ^ 2 + specB * growth ^ 2) * x ^ 4
          - (growth * growth') ^ 2 * (specA * growth' + specB * growth) * x ^ 5 := by ring
    rw [expand, spec_moment_one, spec_moment_two, spec_moment_two', spec_moment_one',
      specA_add_specB, growth_mul_growth']
    ring
  have hu3 : (1 - growth * x) ^ 3 ≠ 0 := pow_ne_zero 3 hune
  have hv3 : (1 - growth' * x) ^ 3 ≠ 0 := pow_ne_zero 3 hvne
  have hnum : specA * ((growth * x) * (1 + growth * x)) * (1 - growth' * x) ^ 3
      + (1 - growth * x) ^ 3 * (specB * ((growth' * x) * (1 + growth' * x)))
      = 2 * x * (4 * x ^ 3 - 6 * x ^ 2 + 2 * x + 1) := by
    linear_combination key
  have hden : (1 - growth * x) ^ 3 * (1 - growth' * x) ^ 3 = (2 * x ^ 2 - 4 * x + 1) ^ 3 := by
    rw [← denom_factor]; ring
  rw [← mul_div_assoc, ← mul_div_assoc, div_add_div _ _ hu3 hv3, hnum, hden]

end Moments

/-! ## The mean area and the variance as rational functions -/

lemma hagedornFugacity_eq : hagedornFugacity = (2 - Real.sqrt 2) / 2 := by
  have hg : growth ≠ 0 := ne_of_gt growth_pos
  rw [hagedornFugacity, eq_div_iff (by norm_num : (2:ℝ) ≠ 0), inv_mul_eq_div,
    div_eq_iff hg]
  unfold growth
  nlinarith [sqrt_two_sq]

lemma hagedornFugacity_lt_one : hagedornFugacity < 1 := by
  rw [hagedornFugacity_eq]
  nlinarith [one_lt_sqrt_two]

/-- **The mean horizon area is a rational function of the fugacity with a simple pole.** -/
theorem meanArea_closed_form {x : ℝ} (hx0 : 0 < x) (hx : x < hagedornFugacity) :
    meanArea x = 2 * x / ((2 * x ^ 2 - 4 * x + 1) * (1 - x)) := by
  have hx' : x < growth⁻¹ := hx
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxlt1 : x < 1 := lt_trans hx hagedornFugacity_lt_one
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := denom_ne hx0' hx'
  have h1x : (1:ℝ) - x ≠ 0 := by intro h; linarith
  rw [meanArea, areaWeighted_closed_form hx0' hx',
    show partitionFunction x = (1 - x) ^ 2 / (2 * x ^ 2 - 4 * x + 1) from
      partition_function_closed_form x hx0' hx']
  field_simp

/-- The canonical variance of the horizon area, i.e. `⟨A²⟩ - ⟨A⟩²`.  Up to the factor `β²`
this is the horizon specific heat. -/
noncomputable def areaVariance (x : ℝ) : ℝ :=
  areaSqWeighted x / partitionFunction x - (meanArea x) ^ 2

/-- **The variance of the horizon area is a rational function with a double pole.** -/
theorem areaVariance_closed_form {x : ℝ} (hx0 : 0 < x) (hx : x < hagedornFugacity) :
    areaVariance x
      = 2 * x * (4 * x ^ 3 - 6 * x ^ 2 + 1) / ((2 * x ^ 2 - 4 * x + 1) ^ 2 * (1 - x) ^ 2) := by
  have hx' : x < growth⁻¹ := hx
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxlt1 : x < 1 := lt_trans hx hagedornFugacity_lt_one
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := denom_ne hx0' hx'
  have h1x : (1:ℝ) - x ≠ 0 := by intro h; linarith
  rw [areaVariance, areaSqWeighted_closed_form hx0' hx', meanArea_closed_form hx0 hx,
    show partitionFunction x = (1 - x) ^ 2 / (2 * x ^ 2 - 4 * x + 1) from
      partition_function_closed_form x hx0' hx']
  field_simp
  ring

/-- **Thermodynamic stability below the Hagedorn temperature.**  The canonical variance of
the horizon area — equivalently, up to the positive factor `β²`, the horizon specific heat
— is strictly positive on the whole subcritical range of fugacities. -/
theorem areaVariance_pos {x : ℝ} (hx0 : 0 < x) (hx : x < hagedornFugacity) :
    0 < areaVariance x := by
  have hx' : x < growth⁻¹ := hx
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxhalf : x < 1 / 2 := by
    have h := hagedornFugacity_eq ▸ hx
    nlinarith [one_lt_sqrt_two]
  have hxlt1 : x < 1 := by linarith
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := denom_ne hx0' hx'
  have h1x : (0:ℝ) < 1 - x := by linarith
  have hnum : 0 < 4 * x ^ 3 - 6 * x ^ 2 + 1 := by
    have hfac : 4 * x ^ 3 - 6 * x ^ 2 + 1 = (1 - 2 * x) * (1 + 2 * x - 2 * x ^ 2) := by ring
    rw [hfac]
    have h1 : 0 < 1 - 2 * x := by linarith
    have h2 : 0 < 1 + 2 * x - 2 * x ^ 2 := by nlinarith
    positivity
  rw [areaVariance_closed_form hx0 hx]
  have hD2 : 0 < (2 * x ^ 2 - 4 * x + 1) ^ 2 := by positivity
  have h1x2 : 0 < (1 - x) ^ 2 := by positivity
  positivity

/-! ## The exact residues at the Hagedorn point -/

/-- The unphysical root `1 + 1/√2` of the partition-function denominator. -/
noncomputable def hagedornFugacity' : ℝ := (2 + Real.sqrt 2) / 2

lemma denom_root_factor (x : ℝ) :
    2 * x ^ 2 - 4 * x + 1 = 2 * (x - hagedornFugacity) * (x - hagedornFugacity') := by
  rw [hagedornFugacity_eq, hagedornFugacity']
  nlinarith [sqrt_two_sq]

lemma hagedornFugacity'_sub : hagedornFugacity' - hagedornFugacity = Real.sqrt 2 := by
  rw [hagedornFugacity_eq, hagedornFugacity']; ring

lemma one_sub_hagedornFugacity : 1 - hagedornFugacity = Real.sqrt 2 / 2 := by
  rw [hagedornFugacity_eq]; ring

/-- **The pole of the mean horizon area at the Hagedorn point is simple, with residue
exactly `x_c = 1/(2+√2)`.**  This is the quantitative form of the ensemble inequivalence
proved in `meanArea_tendsto_atTop`: the mean area blows up exactly like `x_c/(x_c - x)`. -/
theorem meanArea_pole_residue :
    Tendsto (fun x : ℝ => (hagedornFugacity - x) * meanArea x) (𝓝[<] hagedornFugacity)
      (𝓝 hagedornFugacity) := by
  set c := hagedornFugacity with hc
  set c' := hagedornFugacity' with hc'
  have hq : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hcc' : c' - c = Real.sqrt 2 := hagedornFugacity'_sub
  have h1c : 1 - c = Real.sqrt 2 / 2 := one_sub_hagedornFugacity
  set F : ℝ → ℝ := fun x => x / ((c' - x) * (1 - x)) with hF
  have hden : (c' - c) * (1 - c) ≠ 0 := by
    rw [hcc', h1c]
    have := one_lt_sqrt_two
    intro h
    nlinarith
  have hFc : F c = c := by
    have : (c' - c) * (1 - c) = 1 := by
      rw [hcc', h1c]; nlinarith [hq]
    rw [hF]
    simp only [this, div_one]
  have hcont : ContinuousAt F c := by
    apply ContinuousAt.div continuousAt_id
    · exact (continuousAt_const.sub continuousAt_id).mul (continuousAt_const.sub continuousAt_id)
    · exact hden
  have hlim : Tendsto F (𝓝[<] c) (𝓝 c) := by
    have h : Tendsto F (𝓝[<] c) (𝓝 (F c)) := hcont.continuousWithinAt
    rwa [hFc] at h
  refine hlim.congr' ?_
  filter_upwards [eventually_pos_nhdsWithin, self_mem_nhdsWithin] with x hx0 hxlt
  have hxlt' : x < c := hxlt
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxlt1 : x < 1 := lt_trans hxlt' hagedornFugacity_lt_one
  have h1x : (1:ℝ) - x ≠ 0 := by intro h; linarith
  have hcx : c - x ≠ 0 := by intro h; linarith
  have hc'x : c' - x ≠ 0 := by
    have : c < c' := by
      have := one_lt_sqrt_two
      nlinarith [hcc']
    intro h; linarith
  have hxc : x - c ≠ 0 := fun h => hcx (by linarith [sub_eq_zero.mp h])
  have hxc' : x - c' ≠ 0 := fun h => hc'x (by linarith [sub_eq_zero.mp h])
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := denom_ne hx0' hxlt'
  rw [hF]
  simp only
  rw [meanArea_closed_form hx0 hxlt', denom_root_factor x, ← hc, ← hc']
  field_simp
  ring

/-- **The pole of the horizon-area variance at the Hagedorn point has order exactly two,
with residue `x_c²`.**  Equivalently `Var(x) ~ x_c²/(x_c-x)²`: the specific heat diverges
with a double pole, so the Hagedorn point is a genuine (second-order-type) breakdown of the
canonical ensemble rather than a mere shift of the equilibrium area. -/
theorem areaVariance_pole_residue :
    Tendsto (fun x : ℝ => (hagedornFugacity - x) ^ 2 * areaVariance x) (𝓝[<] hagedornFugacity)
      (𝓝 (hagedornFugacity ^ 2)) := by
  set c := hagedornFugacity with hc
  set c' := hagedornFugacity' with hc'
  have hq : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hcc' : c' - c = Real.sqrt 2 := hagedornFugacity'_sub
  have h1c : 1 - c = Real.sqrt 2 / 2 := one_sub_hagedornFugacity
  set G : ℝ → ℝ := fun x => x * (4 * x ^ 3 - 6 * x ^ 2 + 1) / (2 * (c' - x) ^ 2 * (1 - x) ^ 2)
    with hG
  have hprod : (c' - c) * (1 - c) = 1 := by rw [hcc', h1c]; nlinarith [hq]
  have hden : 2 * (c' - c) ^ 2 * (1 - c) ^ 2 ≠ 0 := by
    have : ((c' - c) * (1 - c)) ^ 2 = 1 := by rw [hprod]; ring
    intro h
    nlinarith [this]
  -- the value of the numerator at the critical point, using `2c² - 4c + 1 = 0`
  have hcroot : 2 * c ^ 2 - 4 * c + 1 = 0 := by
    rw [hc, hagedornFugacity_eq]; nlinarith [hq]
  have hnumc : 4 * c ^ 3 - 6 * c ^ 2 + 1 = 2 * c := by nlinarith [hcroot]
  have hGc : G c = c ^ 2 := by
    have hd : 2 * (c' - c) ^ 2 * (1 - c) ^ 2 = 2 := by
      have : ((c' - c) * (1 - c)) ^ 2 = 1 := by rw [hprod]; ring
      nlinarith [this]
    rw [hG]
    simp only [hd, hnumc]
    ring
  have hcont : ContinuousAt G c := by
    apply ContinuousAt.div
    · exact continuousAt_id.mul (by fun_prop)
    · fun_prop
    · exact hden
  have hlim : Tendsto G (𝓝[<] c) (𝓝 (c ^ 2)) := by
    have h : Tendsto G (𝓝[<] c) (𝓝 (G c)) := hcont.continuousWithinAt
    rwa [hGc] at h
  refine hlim.congr' ?_
  filter_upwards [eventually_pos_nhdsWithin, self_mem_nhdsWithin] with x hx0 hxlt
  have hxlt' : x < c := hxlt
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxlt1 : x < 1 := lt_trans hxlt' hagedornFugacity_lt_one
  have h1x : (1:ℝ) - x ≠ 0 := by intro h; linarith
  have hcx : c - x ≠ 0 := by intro h; linarith
  have hc'x : c' - x ≠ 0 := by
    have : c < c' := by
      have := one_lt_sqrt_two
      nlinarith [hcc']
    intro h; linarith
  have hxc : x - c ≠ 0 := fun h => hcx (by linarith [sub_eq_zero.mp h])
  have hxc' : x - c' ≠ 0 := fun h => hc'x (by linarith [sub_eq_zero.mp h])
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := denom_ne hx0' hxlt'
  rw [hG]
  simp only
  rw [areaVariance_closed_form hx0 hxlt', denom_root_factor x, ← hc, ← hc']
  field_simp
  ring

/-- **Divergence of the horizon specific heat at the Hagedorn point.**  The canonical
variance of the area — positive and finite at every subcritical fugacity by
`areaVariance_pos` — diverges as the Hagedorn point is approached. -/
theorem areaVariance_tendsto_atTop :
    Tendsto areaVariance (𝓝[<] hagedornFugacity) atTop := by
  set c := hagedornFugacity with hc
  have hcpos : 0 < c := hagedornFugacity_pos
  have hnum := areaVariance_pole_residue
  have hden : Tendsto (fun x : ℝ => ((c - x) ^ 2)⁻¹) (𝓝[<] c) atTop := by
    refine Filter.Tendsto.inv_tendsto_nhdsGT_zero ?_
    rw [tendsto_nhdsWithin_iff]
    constructor
    · have : Tendsto (fun x : ℝ => (c - x) ^ 2) (𝓝[<] c) (𝓝 ((c - c) ^ 2)) := by
        exact ((continuousAt_const.sub continuousAt_id).pow 2).continuousWithinAt
      simpa using this
    · filter_upwards [self_mem_nhdsWithin] with x hx
      have : x < c := hx
      have h : 0 < c - x := by linarith
      simp only [Set.mem_Ioi]
      positivity
  have hmul := Filter.Tendsto.pos_mul_atTop (pow_pos hcpos 2) hnum hden
  refine hmul.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with x hx
  have hxlt : x < c := hx
  have h : ((c - x) ^ 2) ≠ 0 := pow_ne_zero 2 (sub_ne_zero_of_ne (ne_of_lt hxlt).symm)
  rw [← hc, mul_comm ((c - x) ^ 2) (areaVariance x), mul_inv_cancel_right₀ h]

end BekensteinHawking