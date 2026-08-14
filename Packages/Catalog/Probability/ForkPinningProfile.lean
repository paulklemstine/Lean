/-
# The capacity profile of an index-two conductor (conjecture C9, resolved with a correction)

`ForkPinningExtremal` proves that for a *balanced* congruence observable (an index-two
conductor, e.g. the Jacobi sign) a fork of density `d ≤ 1/2` satisfies

`I(X ; Y) ≤ binEntropy d − binEntropy (2d) / 2`,

with equality exactly for single-coset forks.  Conjecture **C9** of `FUTURE_DIRECTIONS.md` asked
for the analysis of the resulting one-dimensional profile

`C(d) := binEntropy d − binEntropy (2d) / 2`.

This file settles it, and in doing so *corrects* two of the guesses in the conjecture:

* `ForkPinning.cosetProfile_eq` : the exact closed form
  `C(d) = d log 2 − (1−d) log(1−d) + (1−2d) log(1−2d)/2`;
* `ForkPinning.cosetProfile_nonneg`, `ForkPinning.cosetProfile_half` : `0 ≤ C(d)` on `[0,1/2]`
  and `C(1/2) = log 2`, so the profile does interpolate from `0` to the one-bit capacity;
* `ForkPinning.cosetProfile_strictMonoOn` : `C` is *strictly increasing* on `[0, 1/2]`
  (conjectured);
* `ForkPinning.abs_cosetProfile_sub_le` and `ForkPinning.cosetProfile_div_tendsto` : the rare-fork
  asymptotic is `C(d) = d log 2 + O(d²)`, i.e. `C(d)/d → log 2`.  **This refutes the guess
  `C(d) = d log(1/d)(1+o(1))` made in C9**: a rare fork carries a bounded number of nats per unit
  of density, not a logarithmically growing one;
* `ForkPinning.pinnedFraction_tendsto_zero` : consequently the pinned fraction `C(d)/binEntropy d`
  tends to `0` as `d → 0⁺`, **refuting the guess that it decreases only to `1/2`**.  Rare
  splitting types are asymptotically *unpredictable* from an index-two conductor, even though
  they are extremal at their own density.

The corrected picture: the profile rises from `0` to `log 2` monotonically, the pinned fraction
rises from `0` to `1`, and the loss for rare forks is total rather than a factor of two.
-/

import Probability.ForkPinningExtremal
import Probability.ForkPinningSharpConstant

namespace ForkPinning

open Real Filter Topology Set

/-! ## The profile and its closed form -/

/-- The extremal (single-coset) information profile of an index-two conductor. -/
noncomputable def cosetProfile (d : ℝ) : ℝ := Real.binEntropy d - Real.binEntropy (2 * d) / 2

/-- The extremal theorem, restated with the profile. -/
theorem mutualInfo_le_cosetProfile {Ω : Type*} [Fintype Ω] [Nonempty Ω]
    (X Y : Ω → Bool) (hX : prb X true = 1 / 2) (hd : prb Y true ≤ 1 / 2) :
    mutualInfo X Y ≤ cosetProfile (prb Y true) :=
  mutualInfo_le_singleCoset X Y hX hd

/-- Closed form of the profile for `d > 0`. -/
theorem cosetProfile_eq (d : ℝ) (hd : 0 < d) :
    cosetProfile d
      = d * Real.log 2 - (1 - d) * Real.log (1 - d) + (1 - 2 * d) * Real.log (1 - 2 * d) / 2 := by
  have h2d : Real.log (2 * d) = Real.log 2 + Real.log d :=
    Real.log_mul (by norm_num) (ne_of_gt hd)
  simp only [cosetProfile, Real.binEntropy, Real.log_inv]
  rw [h2d]
  ring

/-- At density `1/2` the profile is the full one-bit capacity. -/
@[simp] theorem cosetProfile_half : cosetProfile (1 / 2) = Real.log 2 := by
  simp [cosetProfile, show (1 : ℝ) / 2 = 2⁻¹ by norm_num]

/-- The profile is non-negative on `[0, 1/2]`: it is a genuine information quantity. -/
theorem cosetProfile_nonneg (d : ℝ) (hd0 : 0 ≤ d) (hd1 : d ≤ 1 / 2) : 0 ≤ cosetProfile d := by
  have h := binEntropy_add_le d d hd0 hd0 (by linarith)
  rw [show d + d = 2 * d by ring] at h
  simp only [cosetProfile]
  linarith

/-! ## Monotonicity -/

/-- **The profile is strictly increasing on `[0, 1/2]`.**  Denser forks are always better
pinned by an index-two conductor. -/
theorem cosetProfile_strictMonoOn : StrictMonoOn cosetProfile (Icc 0 (1 / 2)) := by
  have hcont : ContinuousOn cosetProfile (Icc 0 (1 / 2)) := by
    apply Continuous.continuousOn
    unfold cosetProfile
    fun_prop
  refine strictMonoOn_of_deriv_pos (convex_Icc _ _) hcont ?_
  intro d hd
  rw [interior_Icc] at hd
  obtain ⟨hd0, hd1⟩ := hd
  have h2d0 : (2 : ℝ) * d ≠ 0 := by positivity
  have h2d1 : (2 : ℝ) * d ≠ 1 := by intro h; linarith
  have hbase : HasDerivAt (fun x : ℝ => 2 * x) 2 d := by
    simpa using (hasDerivAt_id d).const_mul (2 : ℝ)
  have h1 : HasDerivAt Real.binEntropy (Real.log (1 - d) - Real.log d) d :=
    Real.hasDerivAt_binEntropy (ne_of_gt hd0) (by intro h; rw [h] at hd1; linarith)
  have h2 : HasDerivAt (fun x : ℝ => Real.binEntropy (2 * x))
      ((Real.log (1 - 2 * d) - Real.log (2 * d)) * 2) d :=
    (Real.hasDerivAt_binEntropy h2d0 h2d1).comp d hbase
  have h3 : HasDerivAt cosetProfile
      ((Real.log (1 - d) - Real.log d)
        - ((Real.log (1 - 2 * d) - Real.log (2 * d)) * 2) / 2) d :=
    h1.sub (h2.div_const 2)
  rw [h3.deriv, Real.log_mul (by norm_num) (ne_of_gt hd0)]
  have hlt : Real.log (1 - 2 * d) < Real.log (1 - d) :=
    Real.log_lt_log (by linarith) (by linarith)
  have hlog2 := Real.log_pos (by norm_num : (1 : ℝ) < 2)
  linarith

/-! ## The rare-fork asymptotic -/

/-- **The profile is linear, not `d log (1/d)`, at small densities:**
`|C(d) − d log 2| ≤ 4 d²` for `0 < d ≤ 1/4`. -/
theorem abs_cosetProfile_sub_le (d : ℝ) (hd0 : 0 < d) (hd1 : d ≤ 1 / 4) :
    |cosetProfile d - d * Real.log 2| ≤ 4 * d ^ 2 := by
  set ea := Real.log (1 - d) + d + d ^ 2 / 2 with hea
  set eb := Real.log (1 - 2 * d) + 2 * d + (2 * d) ^ 2 / 2 with heb
  have hba : |ea| ≤ 2 * d ^ 3 := abs_log_one_sub_taylor_le hd0.le (by linarith)
  have hbb : |eb| ≤ 2 * (2 * d) ^ 3 := abs_log_one_sub_taylor_le (by linarith) (by linarith)
  have hbb' : |eb| ≤ 16 * d ^ 3 := hbb.trans (le_of_eq (by ring))
  have hid : cosetProfile d - d * Real.log 2
      = d ^ 2 / 2 + (3 / 2) * d ^ 3 - (1 - d) * ea + (1 - 2 * d) * eb / 2 := by
    rw [cosetProfile_eq d hd0, hea, heb]; ring
  have t1 : |(1 - d) * ea| ≤ 2 * d ^ 3 := by
    rw [abs_mul, abs_of_nonneg (by linarith : (0 : ℝ) ≤ 1 - d)]
    nlinarith [abs_nonneg ea, hba]
  have t2 : |(1 - 2 * d) * eb / 2| ≤ 8 * d ^ 3 := by
    rw [abs_div, abs_mul, abs_of_nonneg (by linarith : (0 : ℝ) ≤ 1 - 2 * d),
      abs_of_nonneg (by norm_num : (0 : ℝ) ≤ (2 : ℝ))]
    nlinarith [abs_nonneg eb, hbb']
  have hpoly : |d ^ 2 / 2 + (3 / 2) * d ^ 3| = d ^ 2 / 2 + (3 / 2) * d ^ 3 :=
    abs_of_nonneg (by positivity)
  calc |cosetProfile d - d * Real.log 2|
      = |(d ^ 2 / 2 + (3 / 2) * d ^ 3 - (1 - d) * ea) + (1 - 2 * d) * eb / 2| := by rw [hid]
    _ ≤ |d ^ 2 / 2 + (3 / 2) * d ^ 3 - (1 - d) * ea| + |(1 - 2 * d) * eb / 2| := abs_add_le _ _
    _ ≤ (|d ^ 2 / 2 + (3 / 2) * d ^ 3| + |(1 - d) * ea|) + |(1 - 2 * d) * eb / 2| :=
        add_le_add (abs_sub _ _) (le_refl _)
    _ ≤ (d ^ 2 / 2 + (3 / 2) * d ^ 3 + 2 * d ^ 3) + 8 * d ^ 3 := by rw [hpoly]; linarith
    _ ≤ 4 * d ^ 2 := by nlinarith

/-- **The rare-fork limit.**  `C(d)/d → log 2` as `d → 0⁺`: a rare extremal fork carries exactly
`log 2` nats per unit of density.  (Conjecture C9 guessed `C(d) ∼ d log(1/d)`; that is false.) -/
theorem cosetProfile_div_tendsto :
    Tendsto (fun d : ℝ => cosetProfile d / d) (𝓝[>] 0) (𝓝 (Real.log 2)) := by
  have hzero : Tendsto (fun d : ℝ => cosetProfile d / d - Real.log 2) (𝓝[>] 0) (𝓝 0) := by
    refine squeeze_zero_norm' (a := fun d : ℝ => 4 * d) ?_ ?_
    · have hsmall : ∀ᶠ d : ℝ in 𝓝[>] 0, d < 1 / 4 :=
        (gt_mem_nhds (by norm_num : (0 : ℝ) < 1 / 4)).filter_mono nhdsWithin_le_nhds
      filter_upwards [self_mem_nhdsWithin, hsmall] with d hd0 hd1
      have hd0 : (0 : ℝ) < d := hd0
      have hkey := abs_cosetProfile_sub_le d hd0 hd1.le
      have hsplit : cosetProfile d / d - Real.log 2
          = (cosetProfile d - d * Real.log 2) / d := by field_simp
      rw [Real.norm_eq_abs, hsplit, abs_div, abs_of_pos hd0, div_le_iff₀ hd0]
      calc |cosetProfile d - d * Real.log 2| ≤ 4 * d ^ 2 := hkey
        _ = 4 * d * d := by ring
    · have : Continuous (fun d : ℝ => 4 * d) := by fun_prop
      simpa using (this.tendsto 0).mono_left nhdsWithin_le_nhds
  simpa using hzero.add_const (Real.log 2)

/-! ## The pinned fraction of a rare fork -/

/-- A pointwise upper bound for the pinned fraction of the extremal fork of density `d`. -/
theorem pinnedFraction_le (d : ℝ) (hd0 : 0 < d) (hd1 : d ≤ 1 / 4) :
    cosetProfile d / Real.binEntropy d ≤ (Real.log 2 + 4 * d) / Real.log (1 / d) := by
  have hd1' : d < 1 := by linarith
  have hlog : Real.log (1 / d) = -Real.log d := by simp [one_div]
  have hlogpos : 0 < Real.log (1 / d) := by
    rw [hlog]
    have := Real.log_neg hd0 hd1'
    linarith
  have hHlb : d * Real.log (1 / d) ≤ Real.binEntropy d := by
    rw [Real.binEntropy, hlog, Real.log_inv, Real.log_inv]
    have hnn : 0 ≤ (1 - d) * -Real.log (1 - d) := by
      have h1d : Real.log (1 - d) ≤ 0 := Real.log_nonpos (by linarith) (by linarith)
      nlinarith
    nlinarith
  have hnum : cosetProfile d ≤ d * (Real.log 2 + 4 * d) := by
    have := (abs_le.mp (abs_cosetProfile_sub_le d hd0 hd1)).2
    nlinarith
  calc cosetProfile d / Real.binEntropy d
      ≤ (d * (Real.log 2 + 4 * d)) / (d * Real.log (1 / d)) :=
        div_le_div₀ (by positivity) hnum (by positivity) hHlb
    _ = (Real.log 2 + 4 * d) / Real.log (1 / d) := by
        rw [mul_div_mul_left _ _ (ne_of_gt hd0)]

/-- **The pinned fraction of a rare fork tends to zero.**  Even the *extremal* fork of density `d`
gives up an asymptotically vanishing fraction of its entropy to an index-two conductor.  This
refutes the C9 guess that the pinned fraction decreases only to `1/2`. -/
theorem pinnedFraction_tendsto_zero :
    Tendsto (fun d : ℝ => cosetProfile d / Real.binEntropy d) (𝓝[>] 0) (𝓝 0) := by
  have hsmall : ∀ᶠ d : ℝ in 𝓝[>] 0, d < 1 / 4 :=
    (gt_mem_nhds (by norm_num : (0 : ℝ) < 1 / 4)).filter_mono nhdsWithin_le_nhds
  have hupper : Tendsto (fun d : ℝ => (Real.log 2 + 4 * d) / Real.log (1 / d)) (𝓝[>] 0) (𝓝 0) := by
    have hnum : Tendsto (fun d : ℝ => Real.log 2 + 4 * d) (𝓝[>] 0) (𝓝 (Real.log 2)) := by
      have hc : Continuous (fun d : ℝ => Real.log 2 + 4 * d) := by fun_prop
      simpa using (hc.tendsto 0).mono_left nhdsWithin_le_nhds
    have hden : Tendsto (fun d : ℝ => Real.log (1 / d)) (𝓝[>] 0) atTop := by
      refine (tendsto_neg_atBot_atTop.comp Real.tendsto_log_nhdsGT_zero).congr ?_
      intro d
      simp [one_div]
    exact hnum.div_atTop hden
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [self_mem_nhdsWithin, hsmall] with d hd0 hd1
    have hd0 : (0 : ℝ) < d := hd0
    exact div_nonneg (cosetProfile_nonneg d hd0.le (by linarith)) (Real.binEntropy_nonneg hd0.le
      (by linarith))
  · filter_upwards [self_mem_nhdsWithin, hsmall] with d hd0 hd1
    have hd0 : (0 : ℝ) < d := hd0
    exact pinnedFraction_le d hd0 hd1.le

end ForkPinning