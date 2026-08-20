import Catalog.Geometry.HyperbolicBerggrenTreeDepth
import Catalog.NumberTheory.BerggrenStarSteps

/-!
# The step length along the Pell spine, and the step-length trichotomy

`NumberTheory.BerggrenStarSteps` showed that the hyperbolic steps along a parabolic
(star) arm of the Berggren tree tend to `0`.  This file computes the exact opposite
behaviour along the hyperbolic (middle) spine: the step lengths converge to the
**translation length** `log(1 + √2)` of the corresponding hyperbolic isometry.

## Main results

* `pell_invariant` : along the middle spine `m² - 2mn - n² = (-1)^{k+1}`; the seeds of the
  spine are exactly the solutions of the two Pell equations `(m-n)² - 2n² = ±1`.
* `mspine_cross_sq_one` : consequently the *seed cross product* of two consecutive spine
  nodes is `±1`, so by `cosh_dist_hpoint_pair` the step satisfies
  `cosh d_k = (1 + m_k² + m_{k+1}²)/(2 m_k m_{k+1})`  (`mspine_step_cosh`).
* `mspine_ratio_tendsto_silver` : the ratio `r_k = m_{k+1}/m_k` obeys the Gauss-type
  recursion `r_{k+1} = 2 + 1/r_k`, is trapped in `[2, 5/2]`, and converges to the silver
  ratio `1 + √2` at rate `4^{-k}`.
* `mspine_step_tendsto_log_silver` : hence `d_k → log(1 + √2)`, the translation length.
* `berggren_step_trichotomy` : the punchline.  Along a star arm the steps tend to `0`,
  along the spine they tend to the positive constant `log(1+√2)`.  This is the metric
  reason why the parabolic arms are seen as *lines converging to a boundary point* while
  the spine is seen as a *geodesic* marching off at unit speed.
-/

namespace BerggrenSpineStep

open Real HyperbolicBerggrenGeodesics BerggrenStarSteps UpperHalfPlane Filter Topology

noncomputable section

/-! ## Part 1. The Pell spine in coordinates -/

/-- First coordinate of the `k`-th node of the middle spine (a Pell number). -/
def pm (k : ℕ) : ℕ := (mspine k).1

/-- Second coordinate of the `k`-th node of the middle spine. -/
def pn (k : ℕ) : ℕ := (mspine k).2

@[simp] theorem pm_zero : pm 0 = 2 := rfl
@[simp] theorem pn_zero : pn 0 = 1 := rfl

theorem pm_succ (k : ℕ) : pm (k + 1) = 2 * pm k + pn k := rfl
theorem pn_succ (k : ℕ) : pn (k + 1) = pm k := rfl

theorem pn_pos (k : ℕ) : 0 < pn k := (mspine_isSeed k).pos
theorem pn_lt_pm (k : ℕ) : pn k < pm k := (mspine_isSeed k).lt
theorem pm_pos (k : ℕ) : 0 < pm k := lt_trans (pn_pos k) (pn_lt_pm k)

/-- The Pell recursion `m_{k+2} = 2 m_{k+1} + m_k`. -/
theorem pm_rec (k : ℕ) : pm (k + 2) = 2 * pm (k + 1) + pm k := by
  rw [pm_succ (k + 1), pn_succ]

/-- **The Pell invariant of the middle spine**: `m² - 2mn - n² = (-1)^{k+1}`. -/
theorem pell_invariant (k : ℕ) :
    ((pm k : ℤ) ^ 2 - 2 * (pm k : ℤ) * (pn k : ℤ) - (pn k : ℤ) ^ 2) = (-1) ^ (k + 1) := by
  induction k with
  | zero => simp
  | succ k ih =>
      have h1 : (pm (k + 1) : ℤ) = 2 * (pm k : ℤ) + (pn k : ℤ) := by
        rw [pm_succ]; push_cast; ring
      have h2 : (pn (k + 1) : ℤ) = (pm k : ℤ) := by rw [pn_succ]
      have hp : ((-1 : ℤ)) ^ (k + 1 + 1) = -((-1 : ℤ)) ^ (k + 1) := by ring
      rw [h1, h2, hp, ← ih]
      ring

/-- The seed cross product of two consecutive spine nodes is `±1`; squared, it is `1`. -/
theorem mspine_cross_sq_one (k : ℕ) :
    ((pn k : ℝ) * (pm (k + 1) : ℝ) - (pn (k + 1) : ℝ) * (pm k : ℝ)) ^ 2 = 1 := by
  have hZ : ((pn k : ℤ) * (pm (k + 1) : ℤ) - (pn (k + 1) : ℤ) * (pm k : ℤ)) ^ 2 = 1 := by
    have h1 : (pm (k + 1) : ℤ) = 2 * (pm k : ℤ) + (pn k : ℤ) := by
      rw [pm_succ]; push_cast; ring
    have h2 : (pn (k + 1) : ℤ) = (pm k : ℤ) := by rw [pn_succ]
    have hinv := pell_invariant k
    have hpm : ((-1 : ℤ) ^ (k + 1)) ^ 2 = 1 := by
      rw [← pow_mul, mul_comm, pow_mul]
      simp
    rw [h1, h2]
    calc ((pn k : ℤ) * (2 * (pm k : ℤ) + (pn k : ℤ)) - (pm k : ℤ) * (pm k : ℤ)) ^ 2
        = ((pm k : ℤ) ^ 2 - 2 * (pm k : ℤ) * (pn k : ℤ) - (pn k : ℤ) ^ 2) ^ 2 := by ring
      _ = 1 := by rw [hinv]; exact hpm
  exact_mod_cast hZ

/-! ## Part 2. The exact step length along the spine -/

/-- **Exact step length along the middle spine.** -/
theorem mspine_step_cosh (k : ℕ) :
    Real.cosh (dist (hpoint (pm k) (pn k) (pm_pos k)) (hpoint (pm (k + 1)) (pn (k + 1))
        (pm_pos (k + 1))))
      = (1 + (pm k : ℝ) ^ 2 + (pm (k + 1) : ℝ) ^ 2) / (2 * (pm k : ℝ) * (pm (k + 1) : ℝ)) := by
  rw [cosh_dist_hpoint_pair, mspine_cross_sq_one k]

/-! ## Part 3. The ratio of consecutive Pell numbers -/

/-- The ratio of consecutive spine coordinates. -/
def ratio (k : ℕ) : ℝ := (pm (k + 1) : ℝ) / (pm k : ℝ)

theorem pm_cast_pos (k : ℕ) : (0 : ℝ) < (pm k : ℝ) := by exact_mod_cast pm_pos k

/-- The Gauss-type recursion `r_{k+1} = 2 + 1/r_k`. -/
theorem ratio_rec (k : ℕ) : ratio (k + 1) = 2 + 1 / ratio k := by
  have h0 : (0 : ℝ) < (pm k : ℝ) := pm_cast_pos k
  have h1 : (0 : ℝ) < (pm (k + 1) : ℝ) := pm_cast_pos (k + 1)
  have hrec : ((pm (k + 2) : ℕ) : ℝ) = 2 * (pm (k + 1) : ℝ) + (pm k : ℝ) := by
    rw [pm_rec]; push_cast; ring
  simp only [ratio, hrec]
  field_simp

theorem ratio_zero : ratio 0 = 5 / 2 := by
  simp only [ratio, pm_zero]
  norm_num [pm_succ, pn_zero, pm_zero]

/-- The ratios are trapped in `[2, 5/2]`. -/
theorem ratio_bounds (k : ℕ) : 2 ≤ ratio k ∧ ratio k ≤ 5 / 2 := by
  induction k with
  | zero => rw [ratio_zero]; norm_num
  | succ k ih =>
      obtain ⟨h1, h2⟩ := ih
      have hpos : (0 : ℝ) < ratio k := by linarith
      rw [ratio_rec]
      constructor
      · have : 0 < 1 / ratio k := by positivity
        linarith
      · have : 1 / ratio k ≤ 1 / 2 := by
          rw [div_le_div_iff₀ hpos (by norm_num)]
          linarith
        linarith

/-- The silver ratio `1 + √2` is the fixed point of `t ↦ 2 + 1/t`. -/
def silver : ℝ := 1 + Real.sqrt 2

theorem sqrt_two_bounds : (1.41 : ℝ) < Real.sqrt 2 ∧ Real.sqrt 2 < 1.415 := by
  constructor
  · nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]
  · nlinarith [Real.sq_sqrt (show (0:ℝ) ≤ 2 by norm_num), Real.sqrt_nonneg 2]

theorem silver_bounds : 2 ≤ silver ∧ silver ≤ 5 / 2 := by
  obtain ⟨h1, h2⟩ := sqrt_two_bounds
  constructor <;> simp only [silver] <;> linarith

theorem silver_pos : 0 < silver := by have := silver_bounds.1; linarith

theorem silver_fixed : 2 + 1 / silver = silver := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hpos : (0 : ℝ) < silver := silver_pos
  rw [eq_comm, ← sub_eq_iff_eq_add', eq_div_iff (ne_of_gt hpos)]
  simp only [silver]
  nlinarith [h2]

/-- **The ratio converges to the silver ratio at rate `4^{-k}`.** -/
theorem ratio_dist_silver (k : ℕ) : |ratio k - silver| ≤ (1 / 4) ^ k * (1 / 2) := by
  induction k with
  | zero =>
      rw [ratio_zero]
      obtain ⟨h1, h2⟩ := sqrt_two_bounds
      simp only [silver, pow_zero, one_mul]
      rw [abs_le]
      constructor <;> linarith
  | succ k ih =>
      obtain ⟨hb1, hb2⟩ := ratio_bounds k
      have hpos : (0 : ℝ) < ratio k := by linarith
      have hsil : 2 ≤ silver := silver_bounds.1
      have hden0 : (0 : ℝ) < ratio k * silver := mul_pos hpos silver_pos
      have hsq : silver ^ 2 = 2 * silver + 1 := by
        have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
        simp only [silver]; nlinarith [h2]
      have he : ratio (k + 1) - silver = (silver - ratio k) / (ratio k * silver) := by
        rw [ratio_rec, eq_div_iff (ne_of_gt hden0)]
        field_simp
        nlinarith [hsq]
      have hstep : |ratio (k + 1) - silver| = |ratio k - silver| / (ratio k * silver) := by
        rw [he, abs_div, abs_of_pos hden0, abs_sub_comm]
      rw [hstep]
      have hden : (4 : ℝ) ≤ ratio k * silver := by nlinarith
      have hnum : |ratio k - silver| ≤ (1 / 4) ^ k * (1 / 2) := ih
      have hq : |ratio k - silver| / (ratio k * silver) ≤ |ratio k - silver| / 4 := by
        apply div_le_div_of_nonneg_left (abs_nonneg _) (by norm_num) hden
      calc |ratio k - silver| / (ratio k * silver) ≤ |ratio k - silver| / 4 := hq
        _ ≤ ((1 / 4) ^ k * (1 / 2)) / 4 := by
            apply div_le_div_of_nonneg_right hnum (by norm_num)
        _ = (1 / 4) ^ (k + 1) * (1 / 2) := by ring

theorem ratio_tendsto_silver : Tendsto ratio atTop (𝓝 silver) := by
  rw [tendsto_iff_dist_tendsto_zero]
  apply squeeze_zero (fun k => dist_nonneg) (g := fun k : ℕ => (1 / 4 : ℝ) ^ k * (1 / 2))
  · intro k
    rw [Real.dist_eq]
    exact ratio_dist_silver k
  · have : Tendsto (fun k : ℕ => (1 / 4 : ℝ) ^ k) atTop (𝓝 0) :=
      tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
    simpa using this.mul_const (1 / 2 : ℝ)

/-! ## Part 4. The step length converges to the translation length -/

theorem pm_ge_two_pow (k : ℕ) : (2 : ℝ) ^ (k + 1) ≤ (pm k : ℝ) := by
  have := mspine_fst_ge k
  have : ((2 : ℕ) ^ (k + 1) : ℝ) ≤ ((pm k : ℕ) : ℝ) := by exact_mod_cast this
  simpa using this

theorem pm_ge_nat (k : ℕ) : k ≤ pm k := by
  induction k with
  | zero => simp [pm_zero]
  | succ k ih =>
      have hp := pn_pos k
      rw [pm_succ]
      omega

theorem pm_tendsto_atTop : Tendsto (fun k : ℕ => (pm k : ℝ)) atTop atTop :=
  tendsto_atTop_mono (fun k => by exact_mod_cast pm_ge_nat k) tendsto_natCast_atTop_atTop

/-- The step's hyperbolic cosine converges to `(silver + 1/silver)/2 = cosh (log silver)`. -/
theorem mspine_step_cosh_tendsto :
    Tendsto (fun k : ℕ => Real.cosh (dist (hpoint (pm k) (pn k) (pm_pos k))
        (hpoint (pm (k + 1)) (pn (k + 1)) (pm_pos (k + 1))))) atTop
      (𝓝 ((silver + 1 / silver) / 2)) := by
  have hEq : ∀ k : ℕ, Real.cosh (dist (hpoint (pm k) (pn k) (pm_pos k))
      (hpoint (pm (k + 1)) (pn (k + 1)) (pm_pos (k + 1))))
      = 1 / (2 * (pm k : ℝ) * (pm (k + 1) : ℝ)) + (ratio k + 1 / ratio k) / 2 := by
    intro k
    have h0 : (0 : ℝ) < (pm k : ℝ) := pm_cast_pos k
    have h1 : (0 : ℝ) < (pm (k + 1) : ℝ) := pm_cast_pos (k + 1)
    rw [mspine_step_cosh k]
    simp only [ratio]
    field_simp
    ring
  simp only [hEq]
  have hfirst : Tendsto (fun k : ℕ => 1 / (2 * (pm k : ℝ) * (pm (k + 1) : ℝ))) atTop (𝓝 0) := by
    have hshift : Tendsto (fun k : ℕ => (pm (k + 1) : ℝ)) atTop atTop :=
      pm_tendsto_atTop.comp (tendsto_add_atTop_nat 1)
    have hleft : Tendsto (fun k : ℕ => 2 * (pm k : ℝ)) atTop atTop :=
      Filter.Tendsto.const_mul_atTop (show (0:ℝ) < 2 by norm_num) pm_tendsto_atTop
    exact Filter.Tendsto.div_atTop tendsto_const_nhds
      (Filter.Tendsto.atTop_mul_atTop₀ hleft hshift)
  have hsecond : Tendsto (fun k : ℕ => (ratio k + 1 / ratio k) / 2) atTop
      (𝓝 ((silver + 1 / silver) / 2)) := by
    have hne : silver ≠ 0 := ne_of_gt silver_pos
    exact ((ratio_tendsto_silver.add
      ((tendsto_const_nhds).div ratio_tendsto_silver hne)).div_const 2)
  simpa using hfirst.add hsecond

/-- If the hyperbolic cosines of a nonnegative sequence converge to `cosh L` with `L ≥ 0`,
then the sequence converges to `L`. -/
theorem tendsto_of_cosh_tendsto {d : ℕ → ℝ} {L : ℝ} (hd : ∀ k, 0 ≤ d k) (hL : 0 ≤ L)
    (h : Tendsto (fun k => Real.cosh (d k)) atTop (𝓝 (Real.cosh L))) :
    Tendsto d atTop (𝓝 L) := by
  rw [Metric.tendsto_atTop]
  intro ε hε
  rw [Metric.tendsto_atTop] at h
  have hb : Real.cosh L < Real.cosh (L + ε) := by
    rw [Real.cosh_lt_cosh, abs_of_nonneg hL, abs_of_nonneg (by linarith : (0:ℝ) ≤ L + ε)]
    linarith
  by_cases hLe : L < ε
  · obtain ⟨K, hK⟩ := h (Real.cosh (L + ε) - Real.cosh L) (by linarith)
    refine ⟨K, fun k hk => ?_⟩
    have h1 := hK k hk
    rw [Real.dist_eq, abs_lt] at h1
    have h2 : Real.cosh (d k) < Real.cosh (L + ε) := by linarith [h1.2]
    have h3 : d k < L + ε := lt_of_cosh_lt (hd k) (by linarith) h2
    rw [Real.dist_eq, abs_lt]
    exact ⟨by linarith [hd k], by linarith⟩
  · push_neg at hLe
    have hLa : (0 : ℝ) ≤ L - ε := by linarith
    have ha : Real.cosh (L - ε) < Real.cosh L := by
      rw [Real.cosh_lt_cosh, abs_of_nonneg hLa, abs_of_nonneg hL]
      linarith
    obtain ⟨K, hK⟩ := h (min (Real.cosh (L + ε) - Real.cosh L) (Real.cosh L - Real.cosh (L - ε)))
      (lt_min (by linarith) (by linarith))
    refine ⟨K, fun k hk => ?_⟩
    have h1 := hK k hk
    rw [Real.dist_eq, abs_lt] at h1
    have hmin1 : min (Real.cosh (L + ε) - Real.cosh L) (Real.cosh L - Real.cosh (L - ε))
        ≤ Real.cosh (L + ε) - Real.cosh L := min_le_left _ _
    have hmin2 : min (Real.cosh (L + ε) - Real.cosh L) (Real.cosh L - Real.cosh (L - ε))
        ≤ Real.cosh L - Real.cosh (L - ε) := min_le_right _ _
    have h2 : Real.cosh (d k) < Real.cosh (L + ε) := by linarith [h1.2]
    have h3 : Real.cosh (L - ε) < Real.cosh (d k) := by linarith [h1.1]
    have h4 : d k < L + ε := lt_of_cosh_lt (hd k) (by linarith) h2
    have h5 : L - ε < d k := lt_of_cosh_lt hLa (hd k) h3
    rw [Real.dist_eq, abs_lt]
    exact ⟨by linarith, by linarith⟩

/-- **The step length along the Pell spine converges to the translation length
`log(1 + √2)`.** -/
theorem mspine_step_tendsto_log_silver :
    Tendsto (fun k : ℕ => dist (hpoint (pm k) (pn k) (pm_pos k))
        (hpoint (pm (k + 1)) (pn (k + 1)) (pm_pos (k + 1)))) atTop (𝓝 (Real.log silver)) := by
  have hcosh : Real.cosh (Real.log silver) = (silver + 1 / silver) / 2 := by
    rw [Real.cosh_eq, Real.exp_log silver_pos, Real.exp_neg, Real.exp_log silver_pos]
    field_simp
  have hLnn : 0 ≤ Real.log silver := Real.log_nonneg (by linarith [silver_bounds.1])
  apply tendsto_of_cosh_tendsto (fun k => dist_nonneg) hLnn
  rw [hcosh]
  exact mspine_step_cosh_tendsto

theorem log_silver_pos : 0 < Real.log silver :=
  Real.log_pos (by linarith [silver_bounds.1])

/-! ## Part 5. The step-length trichotomy -/

/-- **Step-length trichotomy.**  Along a parabolic (star) arm the hyperbolic step lengths
tend to `0`, while along the hyperbolic (Pell) spine they tend to the positive constant
`log(1+√2)`.  The two visual features of the picture — radiating lines that accumulate on
the boundary, and a geodesic spine — are exactly these two regimes. -/
theorem berggren_step_trichotomy (n u : ℕ) (hu : 0 < u) (h : ∀ k : ℕ, 0 < n + (k + 1) * u) :
    Tendsto (fun k : ℕ => dist (hpoint (n + (k + 1) * u) (n + k * u) (h k))
        (hpoint (n + (k + 2) * u) (n + (k + 1) * u) (h (k + 1)))) atTop (𝓝 0) ∧
      Tendsto (fun k : ℕ => dist (hpoint (pm k) (pn k) (pm_pos k))
        (hpoint (pm (k + 1)) (pn (k + 1)) (pm_pos (k + 1)))) atTop (𝓝 (Real.log silver)) ∧
      0 < Real.log silver :=
  ⟨BerggrenStarSteps.armL_step_tendsto_zero n u hu h, mspine_step_tendsto_log_silver,
    log_silver_pos⟩

end

end BerggrenSpineStep