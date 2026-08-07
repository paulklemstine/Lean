import Novelty.BekensteinHawkingHagedornPole

/-!
# The third cumulant of the horizon area and the order of its Hagedorn pole

`Novelty.BekensteinHawkingHagedornPole` computed the first two canonical moments of the
horizon-area ensemble in closed form and identified the exact pole structure at the Hagedorn
fugacity `x_c = 1/(2+√2)`: a simple pole of the mean area with residue `x_c`, and a double
pole of the variance with residue `x_c²`.  `FUTURE_DIRECTIONS.md` (next-cycle sub-conjecture 3)
conjectured the continuation of this pattern one step further: the third cumulant should have a
pole of order exactly three with residue `2 x_c³ = 2!·x_c³`.

This file closes that sub-conjecture.

## Main results

* `hasSum_cube_mul_geometric` : `∑ n³ r^n = r(1 + 4r + r²)/(1-r)⁴` for `‖r‖ < 1`, obtained from
  the third binomial transform via `n³ = 6·C(n+3,3) − 12·C(n+2,2) + 7n + 6`;
* `areaCubeWeighted_closed_form` :
  `∑_A A³ W(A) x^A = 2x(1 + 12x − 20x² + 20x⁴ − 16x⁵)/(2x² − 4x + 1)⁴`;
* `areaThirdCumulant_closed_form` :
  `κ₃(x) = 2x(1 + 5x − 36x² + 56x³ − 4x⁴ − 36x⁵ + 16x⁶)/((2x² − 4x + 1)³(1−x)³)`;
* `areaThirdCumulant_pos` : the horizon-area distribution is strictly **right-skewed** at every
  subcritical fugacity;
* `areaThirdCumulant_pole_residue` : `(x_c − x)³·κ₃(x) → 2 x_c³` as `x ↑ x_c`, i.e. the pole has
  order exactly three and residue exactly `2 x_c³`;
* `areaThirdCumulant_tendsto_atTop` : consequently `κ₃` diverges at the Hagedorn point.

Together with the two previous cycles this establishes the pattern `κ_m ~ (m−1)!·x_c^m/(x_c−x)^m`
for `m = 1, 2, 3`.
-/

open Filter Topology

namespace BekensteinHawking

/-! ## A third-moment geometric series -/

lemma six_mul_choose_three (n : ℕ) : 6 * ((n + 3).choose 3) = (n + 1) * (n + 2) * (n + 3) := by
  induction n with
  | zero => decide
  | succ n ih =>
    have hstep : (n + 1 + 3).choose 3 = (n + 3).choose 2 + (n + 3).choose 3 := by
      rw [show n + 1 + 3 = (n + 3) + 1 by ring, Nat.choose_succ_succ (n + 3) 2]
    have h2 : 2 * ((n + 3).choose 2) = (n + 2) * (n + 3) := two_mul_choose_two (n + 1)
    have h6 : 6 * ((n + 3).choose 2) = 3 * ((n + 2) * (n + 3)) := by omega
    calc 6 * ((n + 1 + 3).choose 3)
        = 6 * ((n + 3).choose 2) + 6 * ((n + 3).choose 3) := by rw [hstep]; ring
      _ = 3 * ((n + 2) * (n + 3)) + (n + 1) * (n + 2) * (n + 3) := by rw [h6, ih]
      _ = (n + 1 + 1) * (n + 1 + 2) * (n + 1 + 3) := by ring

/-- `∑ n³ r^n = r(1 + 4r + r²)/(1-r)⁴` for `|r| < 1`.  Obtained from the third binomial
transform `∑ C(n+3,3) r^n = (1-r)^{-4}` via `n³ = 6·C(n+3,3) − 12·C(n+2,2) + 7n + 6`. -/
lemma hasSum_cube_mul_geometric {r : ℝ} (hr : ‖r‖ < 1) :
    HasSum (fun n : ℕ => (n : ℝ) ^ 3 * r ^ n) (r * (1 + 4 * r + r ^ 2) / (1 - r) ^ 4) := by
  have h3 := hasSum_choose_mul_geometric_of_norm_lt_one (𝕜 := ℝ) 3 hr
  have h2 := hasSum_choose_mul_geometric_of_norm_lt_one (𝕜 := ℝ) 2 hr
  have h1 := hasSum_coe_mul_geometric_of_norm_lt_one hr
  have h0 := hasSum_geometric_of_norm_lt_one hr
  have hne : (1 : ℝ) - r ≠ 0 := by
    intro h
    rw [show r = 1 by linarith] at hr
    simp at hr
  have H := (((h3.mul_left 6).sub (h2.mul_left 12)).add (h1.mul_left 7)).add (h0.mul_left 6)
  have hval : 6 * (1 / (1 - r) ^ (3 + 1)) - 12 * (1 / (1 - r) ^ (2 + 1))
      + 7 * (r / (1 - r) ^ 2) + 6 * (1 - r)⁻¹ = r * (1 + 4 * r + r ^ 2) / (1 - r) ^ 4 := by
    field_simp
    ring
  rw [hval] at H
  refine H.congr_fun ?_
  intro n
  have hc3 : ((n + 3).choose 3 : ℝ) = ((n : ℝ) + 1) * ((n : ℝ) + 2) * ((n : ℝ) + 3) / 6 := by
    have h := six_mul_choose_three n
    have h' : ((6 * ((n + 3).choose 3) : ℕ) : ℝ) = (((n + 1) * (n + 2) * (n + 3) : ℕ) : ℝ) := by
      exact_mod_cast h
    push_cast at h'
    linarith
  have hc2 : ((n + 2).choose 2 : ℝ) = ((n : ℝ) + 1) * ((n : ℝ) + 2) / 2 := by
    have h := two_mul_choose_two n
    have h' : ((2 * ((n + 2).choose 2) : ℕ) : ℝ) = (((n + 1) * (n + 2) : ℕ) : ℝ) := by
      exact_mod_cast h
    push_cast at h'
    linarith
  rw [hc3, hc2]
  ring

/-! ## The third spectral moments -/

lemma spec_moment_three : specA * growth ^ 3 + specB * growth' ^ 3 = 24 := by
  unfold specA specB growth growth'
  linear_combination (Real.sqrt 2 ^ 2 / 2 + 10) * sqrt_two_sq

lemma spec_moment_three' : specA * growth' ^ 3 + specB * growth ^ 3 = -4 := by
  unfold specA specB growth growth'
  linear_combination (-Real.sqrt 2 ^ 2 / 2 - 4) * sqrt_two_sq

/-! ## The closed form of the third moment -/

section Moments

variable {x : ℝ}

/-- The third-moment partition sum `∑ A³ W(A) x^A`. -/
noncomputable def areaCubeWeighted (x : ℝ) : ℝ := ∑' n : ℕ, (n : ℝ) ^ 3 * ((hStates n : ℝ) * x ^ n)

/-- The spectral identity behind the closed form of the third moment: after clearing the two
eigenvalue denominators the numerator is the polynomial `2x(1 + 12x − 20x² + 20x⁴ − 16x⁵)`. -/
lemma cube_spectral_key (x : ℝ) :
    specA * (growth * x) * (1 + 4 * (growth * x) + (growth * x) ^ 2) * (1 - growth' * x) ^ 4
      + specB * (growth' * x) * (1 + 4 * (growth' * x) + (growth' * x) ^ 2)
          * (1 - growth * x) ^ 4
      = 2 * x * (1 + 12 * x - 20 * x ^ 2 + 20 * x ^ 4 - 16 * x ^ 5) := by
  unfold specA specB growth growth'
  linear_combination
    ((1 : ℝ) / 2 * x + 12 * x ^ 2 - 2 * x ^ 3 - 64 * x ^ 4 + 92 * x ^ 5 - 16 * x ^ 6
      - 32 * x ^ 7 + 23 / 2 * Real.sqrt 2 ^ 2 * x ^ 3 + 16 * Real.sqrt 2 ^ 2 * x ^ 4
      - 74 * Real.sqrt 2 ^ 2 * x ^ 5 + 24 * Real.sqrt 2 ^ 2 * x ^ 6
      + 24 * Real.sqrt 2 ^ 2 * x ^ 7 + 23 / 2 * Real.sqrt 2 ^ 4 * x ^ 5
      - 4 * Real.sqrt 2 ^ 4 * x ^ 6 - 6 * Real.sqrt 2 ^ 4 * x ^ 7
      + 1 / 2 * Real.sqrt 2 ^ 6 * x ^ 7) * sqrt_two_sq

/-- **Closed form of the third-moment partition sum.** -/
theorem areaCubeWeighted_closed_form (hx0 : 0 ≤ x) (hx : x < growth⁻¹) :
    areaCubeWeighted x
      = 2 * x * (1 + 12 * x - 20 * x ^ 2 + 20 * x ^ 4 - 16 * x ^ 5)
          / (2 * x ^ 2 - 4 * x + 1) ^ 4 := by
  have hu := norm_growth_mul_lt hx0 hx
  have hv := norm_growth'_mul_lt hx0 hx
  have hune := one_sub_growth_mul_ne hx0 hx
  have hvne := one_sub_growth'_mul_ne hx0 hx
  have H := ((hasSum_cube_mul_geometric hu).mul_left specA).add
    ((hasSum_cube_mul_geometric hv).mul_left specB)
  have hterm : ∀ n : ℕ, (n : ℝ) ^ 3 * ((hStates n : ℝ) * x ^ n)
      = specA * ((n : ℝ) ^ 3 * (growth * x) ^ n)
        + specB * ((n : ℝ) ^ 3 * (growth' * x) ^ n) := by
    intro n
    match n with
    | 0 => simp
    | (m + 1) =>
      rw [hStates_spectral (m + 1) (by omega), mul_pow, mul_pow]
      ring
  have hsum : HasSum (fun n : ℕ => (n : ℝ) ^ 3 * ((hStates n : ℝ) * x ^ n))
      (specA * ((growth * x) * (1 + 4 * (growth * x) + (growth * x) ^ 2)
          / (1 - growth * x) ^ 4)
        + specB * ((growth' * x) * (1 + 4 * (growth' * x) + (growth' * x) ^ 2)
          / (1 - growth' * x) ^ 4)) := H.congr_fun hterm
  rw [areaCubeWeighted, hsum.tsum_eq]
  have hu4 : (1 - growth * x) ^ 4 ≠ 0 := pow_ne_zero 4 hune
  have hv4 : (1 - growth' * x) ^ 4 ≠ 0 := pow_ne_zero 4 hvne
  have hnum : specA * ((growth * x) * (1 + 4 * (growth * x) + (growth * x) ^ 2))
      * (1 - growth' * x) ^ 4
      + (1 - growth * x) ^ 4
        * (specB * ((growth' * x) * (1 + 4 * (growth' * x) + (growth' * x) ^ 2)))
      = 2 * x * (1 + 12 * x - 20 * x ^ 2 + 20 * x ^ 4 - 16 * x ^ 5) := by
    linear_combination cube_spectral_key x
  have hden : (1 - growth * x) ^ 4 * (1 - growth' * x) ^ 4 = (2 * x ^ 2 - 4 * x + 1) ^ 4 := by
    rw [← denom_factor]; ring
  rw [← mul_div_assoc, ← mul_div_assoc, div_add_div _ _ hu4 hv4, hnum, hden]

end Moments

/-! ## The third cumulant -/

/-- The third **cumulant** (equivalently, the third central moment) of the horizon area in the
canonical ensemble: `⟨A³⟩ − 3⟨A²⟩⟨A⟩ + 2⟨A⟩³`.  Its sign measures the skewness of the
area distribution. -/
noncomputable def areaThirdCumulant (x : ℝ) : ℝ :=
  areaCubeWeighted x / partitionFunction x
    - 3 * (areaSqWeighted x / partitionFunction x) * meanArea x
    + 2 * (meanArea x) ^ 3

/-- **The third cumulant of the horizon area is a rational function of the fugacity with a
pole of order three at the Hagedorn point.** -/
theorem areaThirdCumulant_closed_form {x : ℝ} (hx0 : 0 < x) (hx : x < hagedornFugacity) :
    areaThirdCumulant x
      = 2 * x * (1 + 5 * x - 36 * x ^ 2 + 56 * x ^ 3 - 4 * x ^ 4 - 36 * x ^ 5 + 16 * x ^ 6)
          / ((2 * x ^ 2 - 4 * x + 1) ^ 3 * (1 - x) ^ 3) := by
  have hx' : x < growth⁻¹ := hx
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxlt1 : x < 1 := lt_trans hx hagedornFugacity_lt_one
  have hDne : 2 * x ^ 2 - 4 * x + 1 ≠ 0 := denom_ne hx0' hx'
  have h1x : (1:ℝ) - x ≠ 0 := by intro h; linarith
  rw [areaThirdCumulant, areaCubeWeighted_closed_form hx0' hx',
    areaSqWeighted_closed_form hx0' hx', meanArea_closed_form hx0 hx,
    show partitionFunction x = (1 - x) ^ 2 / (2 * x ^ 2 - 4 * x + 1) from
      partition_function_closed_form x hx0' hx']
  field_simp
  ring

/-- The partition-function denominator is strictly positive in the subcritical regime. -/
lemma denom_pos {x : ℝ} (hx : x < hagedornFugacity) :
    0 < 2 * x ^ 2 - 4 * x + 1 := by
  have hcc' : hagedornFugacity' - hagedornFugacity = Real.sqrt 2 := hagedornFugacity'_sub
  have hlt : hagedornFugacity < hagedornFugacity' := by
    have := one_lt_sqrt_two
    linarith
  rw [denom_root_factor x]
  have h1 : x - hagedornFugacity < 0 := by linarith
  have h2 : x - hagedornFugacity' < 0 := by linarith
  have := mul_pos_of_neg_of_neg h1 h2
  linarith

/-- **The horizon-area distribution is right-skewed at every subcritical fugacity.**  The third
cumulant is strictly positive on the whole range `0 < x < x_c`: large fluctuations towards
*larger* areas dominate, which is the microscopic signature of the coming Hagedorn blow-up. -/
theorem areaThirdCumulant_pos {x : ℝ} (hx0 : 0 < x) (hx : x < hagedornFugacity) :
    0 < areaThirdCumulant x := by
  have hx0' : (0:ℝ) ≤ x := le_of_lt hx0
  have hxhalf : x < 1 / 2 := by
    have h := hagedornFugacity_eq ▸ hx
    nlinarith [one_lt_sqrt_two]
  have hxlt1 : x < 1 := by linarith
  have hD : 0 < 2 * x ^ 2 - 4 * x + 1 := denom_pos hx
  have h1x : (0:ℝ) < 1 - x := by linarith
  have hnum : 0 < 1 + 5 * x - 36 * x ^ 2 + 56 * x ^ 3 - 4 * x ^ 4 - 36 * x ^ 5 + 16 * x ^ 6 := by
    nlinarith [sq_nonneg x, sq_nonneg (x - 1/2), sq_nonneg (x ^ 2 - x),
      sq_nonneg (x ^ 3 - x ^ 2), pow_pos hx0 3, pow_pos hx0 4, pow_pos hx0 5, pow_pos hx0 6]
  rw [areaThirdCumulant_closed_form hx0 hx]
  have hD3 : 0 < (2 * x ^ 2 - 4 * x + 1) ^ 3 := by positivity
  have h1x3 : 0 < (1 - x) ^ 3 := by positivity
  positivity

/-- **The pole of the third cumulant at the Hagedorn point has order exactly three, with
residue `2 x_c³`.**  Together with `meanArea_pole_residue` (residue `0!·x_c`) and
`areaVariance_pole_residue` (residue `1!·x_c²`) this confirms the pattern
`κ_m ~ (m−1)!·x_c^m/(x_c − x)^m` for `m = 1, 2, 3`. -/
theorem areaThirdCumulant_pole_residue :
    Tendsto (fun x : ℝ => (hagedornFugacity - x) ^ 3 * areaThirdCumulant x)
      (𝓝[<] hagedornFugacity) (𝓝 (2 * hagedornFugacity ^ 3)) := by
  set c := hagedornFugacity with hc
  set c' := hagedornFugacity' with hc'
  have hq : Real.sqrt 2 ^ 2 = 2 := sqrt_two_sq
  have hcc' : c' - c = Real.sqrt 2 := hagedornFugacity'_sub
  have h1c : 1 - c = Real.sqrt 2 / 2 := one_sub_hagedornFugacity
  set G : ℝ → ℝ := fun x =>
    x * (1 + 5 * x - 36 * x ^ 2 + 56 * x ^ 3 - 4 * x ^ 4 - 36 * x ^ 5 + 16 * x ^ 6)
      / (4 * (c' - x) ^ 3 * (1 - x) ^ 3) with hG
  have hprod : (c' - c) * (1 - c) = 1 := by rw [hcc', h1c]; nlinarith [hq]
  have hcube : (c' - c) ^ 3 * (1 - c) ^ 3 = 1 := by
    have : ((c' - c) * (1 - c)) ^ 3 = 1 := by rw [hprod]; norm_num
    linear_combination this
  have hden : 4 * (c' - c) ^ 3 * (1 - c) ^ 3 ≠ 0 := by
    intro h
    nlinarith [hcube]
  have hcroot : 2 * c ^ 2 - 4 * c + 1 = 0 := by
    rw [hc, hagedornFugacity_eq]; nlinarith [hq]
  have hnumc : 1 + 5 * c - 36 * c ^ 2 + 56 * c ^ 3 - 4 * c ^ 4 - 36 * c ^ 5 + 16 * c ^ 6
      = 8 * c ^ 2 := by
    linear_combination (1 + 9 * c - 10 * c ^ 2 - 2 * c ^ 3 + 8 * c ^ 4) * hcroot
  have hGc : G c = 2 * c ^ 3 := by
    have hd : 4 * (c' - c) ^ 3 * (1 - c) ^ 3 = 4 := by
      have := hcube; linarith
    rw [hG]
    simp only [hnumc, hd]
    ring
  have hcont : ContinuousAt G c := by
    apply ContinuousAt.div
    · exact continuousAt_id.mul (by fun_prop)
    · fun_prop
    · exact hden
  have hlim : Tendsto G (𝓝[<] c) (𝓝 (2 * c ^ 3)) := by
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
  rw [areaThirdCumulant_closed_form hx0 hxlt', denom_root_factor x, ← hc, ← hc']
  field_simp
  ring

/-- **Divergence of the third cumulant at the Hagedorn point.**  Positive and finite at every
subcritical fugacity by `areaThirdCumulant_pos`, the skewness of the horizon-area distribution
blows up as the Hagedorn temperature is approached. -/
theorem areaThirdCumulant_tendsto_atTop :
    Tendsto areaThirdCumulant (𝓝[<] hagedornFugacity) atTop := by
  set c := hagedornFugacity with hc
  have hcpos : 0 < c := hagedornFugacity_pos
  have hnum := areaThirdCumulant_pole_residue
  have hden : Tendsto (fun x : ℝ => ((c - x) ^ 3)⁻¹) (𝓝[<] c) atTop := by
    refine Filter.Tendsto.inv_tendsto_nhdsGT_zero ?_
    rw [tendsto_nhdsWithin_iff]
    constructor
    · have : Tendsto (fun x : ℝ => (c - x) ^ 3) (𝓝[<] c) (𝓝 ((c - c) ^ 3)) :=
        ((continuousAt_const.sub continuousAt_id).pow 3).continuousWithinAt
      simpa using this
    · filter_upwards [self_mem_nhdsWithin] with x hx
      have hxc : x < c := hx
      have h : 0 < c - x := by linarith
      simp only [Set.mem_Ioi]
      positivity
  have hpos : (0:ℝ) < 2 * c ^ 3 := by positivity
  have hmul := Filter.Tendsto.pos_mul_atTop hpos hnum hden
  refine hmul.congr' ?_
  filter_upwards [self_mem_nhdsWithin] with x hx
  have hxlt : x < c := hx
  have h : ((c - x) ^ 3) ≠ 0 := pow_ne_zero 3 (sub_ne_zero_of_ne (ne_of_lt hxlt).symm)
  rw [← hc, mul_comm ((c - x) ^ 3) (areaThirdCumulant x), mul_inv_cancel_right₀ h]

end BekensteinHawking