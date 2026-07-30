import Mathlib

/-!
# Three-sample tropical training as a gradient flow

A one-parameter tropical neuron is represented by its projective translation `x`.
After subtracting the three fixed tropical feature values from the labels, training
with tropical `L¹` loss becomes minimization of the sum of three absolute residuals.
For ordered residual targets `a ≤ m ≤ c`, the middle target `m` is the unique
minimizer.

The map `tropicalFlow m t x` is the unit-speed piecewise-linear (sub)gradient flow:
it moves `x` toward `m`, without overshooting.  The main theorem identifies its
fixed points with the empirical-risk minimizers and proves finite-time, hence
asymptotic, convergence from every initialization.  This gives a precise bridge
between three-sample neural-network optimization, median statistics, and tropical
piecewise-linear dynamics.
-/

noncomputable section

open Filter Set Topology

namespace EMLTropicalGradientFlow

/-- Tropical `L¹` empirical loss of a scalar neuron on three reduced samples. -/
def threePointLoss (a m c x : ℝ) : ℝ :=
  |x - a| + |x - m| + |x - c|

/-- Unit-speed piecewise-linear flow toward `m`, clipped to avoid overshoot. -/
def tropicalFlow (m t x : ℝ) : ℝ :=
  if x < m then min m (x + t) else max m (x - t)

/-- The median of three ordered targets minimizes their absolute-error loss. -/
theorem median_minimizes {a m c : ℝ} (ham : a ≤ m) (hmc : m ≤ c) (x : ℝ) :
    threePointLoss a m c m ≤ threePointLoss a m c x := by
  unfold threePointLoss
  simp only [sub_self, abs_zero, add_zero]
  have h1 : |m - a| = m - a := abs_of_nonneg (by linarith)
  have h2 : |m - c| = c - m := by rw [abs_sub_comm]; exact abs_of_nonneg (by linarith)
  have h3 : |x - a| + |x - c| ≥ c - a := by
    have : |c - a| ≤ |x - a| + |x - c| := by
      calc |c - a| = |(x - a) - (x - c)| := by ring_nf
        _ ≤ |x - a| + |x - c| := abs_sub _ _
    rwa [abs_of_nonneg (by linarith : c - a ≥ 0)] at this
  linarith [abs_nonneg (x - m)]

/-- Strictness to the left of the median. -/
theorem loss_strict_left {a m c x : ℝ} (ham : a ≤ m) (hmc : m ≤ c) (hx : x < m) :
    threePointLoss a m c m < threePointLoss a m c x := by
  simp [threePointLoss]
  have hm_a : m - a ≥ 0 := sub_nonneg.mpr ham
  have hm_c : m - c ≤ 0 := sub_nonpos.mpr hmc
  have hx_m : x - m < 0 := sub_neg.mpr hx
  have hx_c : x - c < 0 := sub_neg.mpr (hx.trans_le hmc)
  rw [abs_of_nonneg hm_a, abs_of_nonpos hm_c, abs_of_neg hx_m, abs_of_neg hx_c]
  ring_nf
  by_cases hxa : x < a
  · have : -a + x < 0 := by linarith
    rw [abs_of_neg this]
    nlinarith
  · have : -a + x ≥ 0 := by linarith [not_lt.mp hxa]
    rw [abs_of_nonneg this]
    nlinarith

/-- Strictness to the right of the median. -/
theorem loss_strict_right {a m c x : ℝ} (ham : a ≤ m) (hmc : m ≤ c) (hx : m < x) :
    threePointLoss a m c m < threePointLoss a m c x := by
  unfold threePointLoss
  simp only [sub_self]
  have ha : m - a = |m - a| := (abs_of_nonneg (by linarith : m - a ≥ 0)).symm
  have hc : m - c = -|m - c| := by rw [abs_of_nonpos (by linarith : m - c ≤ 0)]; ring
  have ha : |m - a| = m - a := abs_of_nonneg (by linarith : m - a ≥ 0)
  have hc : |m - c| = c - m := by rw [abs_of_nonpos (by linarith : m - c ≤ 0)]; ring
  have ha' : |x - a| = x - a := abs_of_nonneg (by linarith : x - a ≥ 0)
  have hm' : |x - m| = x - m := abs_of_nonneg (by linarith : x - m ≥ 0)
  by_cases hxc : x ≤ c
  · -- Case x ≤ c: |x - c| = c - x
    have hxc_abs : |x - c| = c - x := by rw [abs_of_nonpos (by linarith : x - c ≤ 0)]; ring
    simp [ha, hc, ha', hm', hxc_abs]
    linarith
  · -- Case x > c: |x - c| = x - c
    push_neg at hxc
    have hxc_abs : |x - c| = x - c := abs_of_nonneg (by linarith : x - c ≥ 0)
    simp [ha, hc, ha', hm', hxc_abs]
    linarith

/-- For three ordered samples, empirical-risk minimization is exactly the median condition. -/
theorem minimizes_iff_median {a m c x : ℝ} (ham : a ≤ m) (hmc : m ≤ c) :
    (∀ y : ℝ, threePointLoss a m c x ≤ threePointLoss a m c y) ↔ x = m := by
  constructor
  · intro h
    rcases lt_trichotomy x m with hxm | hxm | hmx
    · exact (not_lt_of_ge (h m) (loss_strict_left ham hmc hxm)).elim
    · exact hxm
    · exact (not_lt_of_ge (h m) (loss_strict_right ham hmc hmx)).elim
  · rintro rfl y
    exact median_minimizes ham hmc y

/-- The tropical flow reaches the median once elapsed time covers the initial distance. -/
theorem tropicalFlow_eq_median {m t x : ℝ} (ht : |x - m| ≤ t) :
    tropicalFlow m t x = m := by
  unfold tropicalFlow
  split_ifs with h
  · rw [min_eq_left]
    linarith [abs_le.mp ht]
  · rw [max_eq_left]
    linarith [abs_le.mp ht]

/-- A point fixed by every positive-time flow map is precisely the median. -/
theorem fixed_for_all_positive_iff {m x : ℝ} :
    (∀ t : ℝ, 0 < t → tropicalFlow m t x = x) ↔ x = m := by
  constructor
  · intro h
    let t := |x - m| + 1
    have ht : 0 < t := by dsimp [t]; positivity
    have hreached : tropicalFlow m t x = m :=
      tropicalFlow_eq_median (by dsimp [t]; linarith)
    exact (hreached.symm.trans (h t ht)).symm
  · rintro rfl t ht
    simp [tropicalFlow, le_of_lt ht]

/-- Every trajectory reaches its median in finite time and therefore converges. -/
theorem tropicalFlow_converges (m x : ℝ) :
    Tendsto (fun t : ℝ => tropicalFlow m t x) atTop (𝓝 m) := by
  apply tendsto_const_nhds.congr'
  filter_upwards [eventually_ge_atTop |x - m|] with t ht
  exact (tropicalFlow_eq_median ht).symm

/--
**Connector theorem.** For a scalar tropical neuron trained on three ordered
reduced data points, the statistical median/minimum-loss condition is equivalent
to dynamical stationarity of the tropical gradient flow.  Moreover every
initialization converges to this unique fixed point (indeed after time `|x-m|`).
-/
theorem three_sample_training_connector {a m c x : ℝ} (ham : a ≤ m) (hmc : m ≤ c) :
    ((∀ y : ℝ, threePointLoss a m c x ≤ threePointLoss a m c y) ↔
      (∀ t : ℝ, 0 < t → tropicalFlow m t x = x)) ∧
    (∀ x₀ : ℝ, Tendsto (fun t : ℝ => tropicalFlow m t x₀) atTop (𝓝 m)) := by
  constructor
  · rw [minimizes_iff_median ham hmc, fixed_for_all_positive_iff]
  · exact tropicalFlow_converges m

/-! ## Kernel-checked small cases

These concrete examples serve as compact computational evidence: they check the
loss landscape and finite-time flow for representative integral data.
-/

example : threePointLoss (-2) 1 5 1 = 7 := by norm_num [threePointLoss]
example : threePointLoss (-2) 1 5 (-1) = 9 := by norm_num [threePointLoss]
example : threePointLoss (-2) 1 5 4 = 10 := by norm_num [threePointLoss]
example : tropicalFlow 1 3 (-2) = 1 := by norm_num [tropicalFlow]
example : tropicalFlow 1 10 5 = 1 := by norm_num [tropicalFlow]

end EMLTropicalGradientFlow