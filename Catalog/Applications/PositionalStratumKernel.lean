/-
# F2 : the canonical positional prior `b ∝ r^{-3/2}` and the capture curve

The scale × balance formulation says that *balance is position*: the balance coordinate is
`s = r^{-1/2}`, and the reporting prior that is uniform in the balance coordinate is the
canonical kernel

  `b(r) = 1 / (2 · r · √r)  =  ½ · r^{-3/2}`,

whose primitive is the capture CDF `x(r) = 1 - r^{-1/2}`.

What is proved.

* `canonicalKernel_hasDerivAt`, `canonical_integral` — the kernel integrates to the capture
  CDF: `∫_1^R b = 1 - R^{-1/2}`.  Equivalently (`canonical_is_uniform_in_balance`) the mass
  the canonical prior gives to `[1,R]` equals the *length of the balance interval*
  `[R^{-1/2}, 1]`: the canonical prior is exactly the uniform prior in the balance
  coordinate.
* `captureProb_linear` — the capture curve is **exactly linear** in `μ = 1 - R^{-1/2}` with
  slope `1/(1 - R_max^{-1/2})`, i.e. `P(μ) = μ / (1 - R_max^{-1/2})`.
* `kernel_unique_of_capture_law` — the converse: *linear iff canonical*.  A continuous
  reporting density whose capture curve is proportional to `1 - R^{-1/2}` must be a
  multiple of the canonical kernel.  So the canonical prior is not a convention but the
  unique shape compatible with a linear capture curve.
* `capture_curve_not_linear_of_uniform` — a concrete non-canonical prior (the uniform
  density on `[1, R_max]`) has a capture curve that is *not* proportional to the canonical
  one, confirming the "only if" direction has content.
-/
import Mathlib

namespace PositionalStratum

open Real MeasureTheory intervalIntegral

noncomputable section

/-- The canonical reporting kernel `b(r) = ½ r^{-3/2}`. -/
def canonicalKernel (r : ℝ) : ℝ := 1 / (2 * r * Real.sqrt r)

/-- The capture CDF `x(r) = 1 - r^{-1/2}` (= the balance coordinate measured from the
top of the scale). -/
def captureCDF (r : ℝ) : ℝ := 1 - 1 / Real.sqrt r

lemma captureCDF_one : captureCDF 1 = 0 := by
  simp [captureCDF]

/-- The capture CDF is a primitive of the canonical kernel. -/
theorem canonicalKernel_hasDerivAt {r : ℝ} (hr : 0 < r) :
    HasDerivAt captureCDF (canonicalKernel r) r := by
  have hsq : Real.sqrt r ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hr)
  have hs : HasDerivAt Real.sqrt (1 / (2 * Real.sqrt r)) r := Real.hasDerivAt_sqrt (ne_of_gt hr)
  have hinv : HasDerivAt (fun x => (Real.sqrt x)⁻¹)
      (-(1 / (2 * Real.sqrt r)) / Real.sqrt r ^ 2) r := hs.inv hsq
  have hsub := (hasDerivAt_const r (1 : ℝ)).sub hinv
  have hsq2 : Real.sqrt r ^ 2 = r := Real.sq_sqrt hr.le
  have hval : 0 - -(1 / (2 * Real.sqrt r)) / Real.sqrt r ^ 2 = canonicalKernel r := by
    rw [hsq2, canonicalKernel]
    field_simp
    ring
  have : HasDerivAt (fun x => 1 - (Real.sqrt x)⁻¹) (canonicalKernel r) r := by
    rw [← hval]; exact hsub
  have hcast : captureCDF = fun x => 1 - (Real.sqrt x)⁻¹ := by
    funext x; rw [captureCDF, one_div]
  rw [hcast]
  exact this

lemma canonicalKernel_continuousOn {R : ℝ} (hR : 1 ≤ R) :
    ContinuousOn canonicalKernel (Set.uIcc (1 : ℝ) R) := by
  have hsub : Set.uIcc (1 : ℝ) R ⊆ Set.Ici (1 : ℝ) := by
    rw [Set.uIcc_of_le hR]
    exact Set.Icc_subset_Ici_self
  intro x hx
  have hx1 : (1 : ℝ) ≤ x := hsub hx
  have hxpos : (0 : ℝ) < x := by linarith
  have hden : 2 * x * Real.sqrt x ≠ 0 := by
    have : 0 < Real.sqrt x := Real.sqrt_pos.mpr hxpos
    positivity
  refine ContinuousAt.continuousWithinAt ?_
  have hcont : ContinuousAt (fun y : ℝ => 2 * y * Real.sqrt y) x := by
    exact (continuousAt_const.mul continuousAt_id).mul (Real.continuous_sqrt.continuousAt)
  exact continuousAt_const.div hcont hden

/-- **The canonical kernel integrates to the capture CDF**: `∫_1^R ½ r^{-3/2} = 1 - R^{-1/2}`. -/
theorem canonical_integral {R : ℝ} (hR : 1 ≤ R) :
    ∫ r in (1 : ℝ)..R, canonicalKernel r = captureCDF R := by
  have hderiv : ∀ r ∈ Set.uIcc (1 : ℝ) R, HasDerivAt captureCDF (canonicalKernel r) r := by
    intro r hr
    have hsub : Set.uIcc (1 : ℝ) R ⊆ Set.Ici (1 : ℝ) := by
      rw [Set.uIcc_of_le hR]; exact Set.Icc_subset_Ici_self
    have hr1 : (1 : ℝ) ≤ r := hsub hr
    exact canonicalKernel_hasDerivAt (by linarith)
  have hint : IntervalIntegrable canonicalKernel volume 1 R :=
    (canonicalKernel_continuousOn hR).intervalIntegrable
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hint, captureCDF_one, sub_zero]

/-- **The canonical prior is the uniform prior in the balance coordinate.**  The canonical
mass of the scale window `[1, R]` is exactly the length of the balance window
`[R^{-1/2}, 1]`, i.e. `s = r^{-1/2}` transports the canonical kernel to Lebesgue measure. -/
theorem canonical_is_uniform_in_balance {R : ℝ} (hR : 1 ≤ R) :
    ∫ r in (1 : ℝ)..R, canonicalKernel r = 1 - 1 / Real.sqrt R := by
  rw [canonical_integral hR, captureCDF]

/-- The capture probability of the retained window `[1,R]` inside the population
`[1, R_max]`, under the canonical reporting prior. -/
def captureProb (Rmax R : ℝ) : ℝ :=
  (∫ r in (1 : ℝ)..R, canonicalKernel r) / ∫ r in (1 : ℝ)..Rmax, canonicalKernel r

lemma captureCDF_pos {R : ℝ} (hR : 1 < R) : 0 < captureCDF R := by
  have h0 : (0 : ℝ) < R := by linarith
  have hs : 1 < Real.sqrt R := by
    have := Real.sqrt_lt_sqrt (by norm_num) hR
    simpa using this
  rw [captureCDF, sub_pos, div_lt_one (by linarith)]
  exact hs

/-- **The capture curve is exactly linear in the balance coordinate.**  Writing
`μ = 1 - R^{-1/2}` for the retained balance mass, `P(μ) = μ / (1 - R_max^{-1/2})`. -/
theorem captureProb_linear {Rmax R : ℝ} (hR : 1 ≤ R) (hmax : 1 < Rmax) :
    captureProb Rmax R = (1 / captureCDF Rmax) * captureCDF R := by
  rw [captureProb, canonical_integral hR, canonical_integral hmax.le]
  field_simp

/-- **Linear iff canonical.**  If a continuous reporting density has a capture curve
proportional to `1 - R^{-1/2}`, it *is* a multiple of the canonical kernel `½ r^{-3/2}`. -/
theorem kernel_unique_of_capture_law {g : ℝ → ℝ} (hg : Continuous g) {c : ℝ}
    (h : ∀ R : ℝ, 1 ≤ R → (∫ r in (1 : ℝ)..R, g r) = c * captureCDF R) :
    ∀ r : ℝ, 1 < r → g r = c * canonicalKernel r := by
  intro r hr
  have hG : HasDerivAt (fun u => ∫ x in (1 : ℝ)..u, g x) (g r) r :=
    intervalIntegral.integral_hasDerivAt_right (hg.intervalIntegrable _ _)
      (hg.stronglyMeasurableAtFilter _ _) hg.continuousAt
  have hF : HasDerivAt (fun u => c * captureCDF u) (c * canonicalKernel r) r :=
    (canonicalKernel_hasDerivAt (by linarith)).const_mul c
  have heq : (fun u => c * captureCDF u) =ᶠ[nhds r] fun u => ∫ x in (1 : ℝ)..u, g x := by
    filter_upwards [Ioi_mem_nhds hr] with u hu
    exact (h u (le_of_lt hu)).symm
  exact (hG.congr_of_eventuallyEq heq).unique hF

/-- **The "only if" direction has content.**  The uniform reporting prior on `[1, R_max]`
is *not* canonical: at `R_max = 4` its capture curve at `R = 2` is `1/3`, whereas the
canonical curve there is `(1 - 1/√2)/(1/2) = 2 - √2 ≈ 0.5858`. -/
theorem capture_curve_not_linear_of_uniform :
    (∫ _r in (1 : ℝ)..2, (1 : ℝ) / 3) / (∫ _r in (1 : ℝ)..4, (1 : ℝ) / 3)
      ≠ captureProb 4 2 := by
  have h1 : (∫ _r in (1 : ℝ)..2, (1 : ℝ) / 3) = 1 / 3 := by
    rw [intervalIntegral.integral_const]
    norm_num
  have h2 : (∫ _r in (1 : ℝ)..4, (1 : ℝ) / 3) = 1 := by
    rw [intervalIntegral.integral_const]
    norm_num
  have hcap : captureProb 4 2 = 2 - Real.sqrt 2 := by
    rw [captureProb_linear (by norm_num) (by norm_num), captureCDF, captureCDF]
    have h4 : Real.sqrt 4 = 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]
    have hs2 : Real.sqrt 2 > 0 := Real.sqrt_pos.mpr (by norm_num)
    have hsq : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)
    rw [h4]
    field_simp
    nlinarith [hsq, hs2]
  rw [h1, h2, hcap]
  have hlt : Real.sqrt 2 < 3 / 2 := by
    nlinarith [Real.sq_sqrt (by norm_num : (0:ℝ) ≤ 2), Real.sqrt_nonneg 2]
  intro hcon
  nlinarith [hcon, hlt]

end

end PositionalStratum