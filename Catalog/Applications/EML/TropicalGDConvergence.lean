import Applications.EML.TropicalGradientFlow
import Shared.NeuralCoding.Relu

/-!
# Discrete gradient descent for a tropical EML translation neuron

This file turns the continuous clipped flow from `TropicalGradientFlow` into a
fixed-step discrete optimizer.  The trainable tropical model is the max-plus
monomial `z ↦ z + θ`; such monomials are tropical polynomials and hence tropical
rational functions.  On three ordered reduced samples, its `L¹` loss is the
piecewise-linear objective `threePointLoss`.

The main results give an exact parameter-error formula, finite termination,
pointwise convergence of the trained tropical rational functions, an explicit
loss rate, and an exact realization of every update by two ReLU units.
-/

noncomputable section

open Filter Set Topology
open EMLTropicalGradientFlow

namespace EMLTropicalGD

/-- A one-variable max-plus monomial, viewed as a tropical rational model. -/
def tropicalAffine (θ z : ℝ) : ℝ := z + θ

/-- Fixed-step tropical gradient descent, in closed form after `n` updates. -/
def gdIter (m η x : ℝ) (n : ℕ) : ℝ :=
  tropicalFlow m ((n : ℝ) * η) x

/-- Exact distance-to-optimum formula for the clipped piecewise-linear flow. -/
theorem tropicalFlow_distance {m t x : ℝ} :
    |tropicalFlow m t x - m| = max 0 (|x - m| - t) := by
  unfold tropicalFlow
  split_ifs with hxm
  · rw [abs_of_neg (sub_neg.mpr hxm)]
    by_cases hreach : m ≤ x + t
    · rw [min_eq_left hreach]
      simp
      linarith
    · rw [min_eq_right (le_of_not_ge hreach)]
      rw [abs_of_nonpos (by linarith : x + t - m ≤ 0)]
      rw [max_eq_right]
      · ring
      · linarith
  · have hmx : m ≤ x := le_of_not_gt hxm
    rw [abs_of_nonneg (sub_nonneg.mpr hmx)]
    by_cases hreach : x - t ≤ m
    · rw [max_eq_left hreach]
      simp
      linarith
    · rw [max_eq_right (le_of_not_ge hreach)]
      rw [abs_of_nonneg (by linarith : 0 ≤ x - t - m)]
      rw [max_eq_right]
      · ring
      · linarith

/-- Exact discrete convergence rate in parameter distance. -/
theorem gdIter_distance {m η x : ℝ} (n : ℕ) :
    |gdIter m η x n - m| = max 0 (|x - m| - (n : ℝ) * η) := by
  exact tropicalFlow_distance

/-- Once cumulative step length covers the initial error, descent is exactly at the minimizer. -/
theorem gdIter_eq_median_of_distance_le {m η x : ℝ} {n : ℕ}
    (hcover : |x - m| ≤ (n : ℝ) * η) :
    gdIter m η x n = m := by
  exact tropicalFlow_eq_median hcover

/-- Every positive fixed step reaches the optimum after finitely many updates. -/
theorem gdIter_finite_termination {m η x : ℝ} (hη : 0 < η) :
    ∃ N : ℕ, ∀ n ≥ N, gdIter m η x n = m := by
  obtain ⟨N, hN⟩ := exists_nat_gt (|x - m| / η)
  refine ⟨N, ?_⟩
  intro n hn
  apply gdIter_eq_median_of_distance_le
  have hNcover : |x - m| < (N : ℝ) * η := by
    rw [← div_lt_iff₀ hη]
    exact_mod_cast hN
  have hcast : (N : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  nlinarith

/-- Discrete tropical gradient descent converges to the unique median parameter. -/
theorem gdIter_tendsto {m η x : ℝ} (hη : 0 < η) :
    Tendsto (gdIter m η x) atTop (𝓝 m) := by
  obtain ⟨N, hN⟩ := gdIter_finite_termination (m := m) (x := x) hη
  apply tendsto_const_nhds.congr'
  filter_upwards [eventually_ge_atTop N] with n hn
  exact (hN n hn).symm

/-- Parameter distance is exactly pointwise prediction distance for tropical monomials. -/
theorem tropicalAffine_error (θ m z : ℝ) :
    |tropicalAffine θ z - tropicalAffine m z| = |θ - m| := by
  congr 1
  simp [tropicalAffine]

/-- The trained tropical rational functions converge pointwise to the minimizing model. -/
theorem trained_tropical_rational_converges {m η x : ℝ} (hη : 0 < η) (z : ℝ) :
    Tendsto (fun n : ℕ => tropicalAffine (gdIter m η x n) z) atTop
      (𝓝 (tropicalAffine m z)) := by
  simpa [tropicalAffine, add_comm] using (gdIter_tendsto (m := m) (x := x) hη).const_add z

/-- Changing the scalar tropical parameter by `δ` changes the three-sample loss by at most `3|δ|`. -/
theorem threePointLoss_lipschitz (a m c θ : ℝ) :
    threePointLoss a m c θ - threePointLoss a m c m ≤ 3 * |θ - m| := by
  unfold threePointLoss
  have ha := abs_sub_abs_le_abs_sub (θ - a) (m - a)
  have hm : |θ - m| - |m - m| ≤ |θ - m| := by simp
  have hc := abs_sub_abs_le_abs_sub (θ - c) (m - c)
  have hea : |(θ - a) - (m - a)| = |θ - m| := by
    congr 1
    ring
  have hec : |(θ - c) - (m - c)| = |θ - m| := by
    congr 1
    ring
  rw [hea] at ha
  rw [hec] at hc
  linarith

/-- Explicit tropical training-loss rate, with finite termination of the excess loss. -/
theorem gdIter_loss_rate {a m c x η : ℝ} (ham : a ≤ m) (hmc : m ≤ c)
    (n : ℕ) :
    0 ≤ threePointLoss a m c (gdIter m η x n) - threePointLoss a m c m ∧
    threePointLoss a m c (gdIter m η x n) - threePointLoss a m c m ≤
      3 * max 0 (|x - m| - (n : ℝ) * η) := by
  constructor
  · linarith [median_minimizes ham hmc (gdIter m η x n)]
  · rw [← gdIter_distance]
    exact threePointLoss_lipschitz a m c (gdIter m η x n)

/-- A tropical clipped gradient update is exactly a signed pair of shifted ReLUs. -/
theorem tropicalFlow_eq_two_relu {m t x : ℝ} (ht : 0 ≤ t) :
    tropicalFlow m t x =
      m + relu (x - m - t) - relu (m - x - t) := by
  unfold tropicalFlow relu
  by_cases hxm : x < m
  · rw [if_pos hxm]
    have hright : x - m - t ≤ 0 := by linarith
    rw [max_eq_right hright]
    by_cases hreach : m ≤ x + t
    · rw [min_eq_left hreach]
      have : m - x - t ≤ 0 := by linarith
      rw [max_eq_right this]
      ring
    · rw [min_eq_right (le_of_not_ge hreach)]
      have : 0 ≤ m - x - t := by linarith
      rw [max_eq_left this]
      ring
  · rw [if_neg hxm]
    have hmx : m ≤ x := le_of_not_gt hxm
    have hleft : m - x - t ≤ 0 := by linarith
    rw [max_eq_right hleft]
    by_cases hreach : x - t ≤ m
    · rw [max_eq_left hreach]
      have : x - m - t ≤ 0 := by linarith
      rw [max_eq_right this]
      ring
    · rw [max_eq_right (le_of_not_ge hreach)]
      have : 0 ≤ x - m - t := by linarith
      rw [max_eq_left this]
      ring

/-- Comparison theorem: tropical EML descent and a width-two ReLU network have identical iterates. -/
theorem gdIter_eq_two_relu {m η x : ℝ} (hη : 0 ≤ η) (n : ℕ) :
    gdIter m η x n =
      m + relu (x - m - (n : ℝ) * η) - relu (m - x - (n : ℝ) * η) := by
  exact tropicalFlow_eq_two_relu (mul_nonneg (Nat.cast_nonneg n) hη)

/-- Main learning theorem: positive-step training converges pointwise, and its limit
parameter is the unique empirical-risk minimizer. -/
theorem training_convergence_and_optimality {a m c x η : ℝ}
    (ham : a ≤ m) (hmc : m ≤ c) (hη : 0 < η) :
    (∀ z : ℝ, Tendsto (fun n : ℕ => tropicalAffine (gdIter m η x n) z) atTop
      (𝓝 (tropicalAffine m z))) ∧
    (∀ θ : ℝ, threePointLoss a m c m ≤ threePointLoss a m c θ) ∧
    (∀ θ : ℝ, (∀ y : ℝ, threePointLoss a m c θ ≤ threePointLoss a m c y) → θ = m) := by
  refine ⟨fun z => trained_tropical_rational_converges hη z,
    fun θ => median_minimizes ham hmc θ, ?_⟩
  intro θ hθ
  exact (minimizes_iff_median ham hmc).mp hθ

/-! Kernel-checked representative iterates and loss values. -/

example : gdIter 1 2 (-4) 0 = -4 := by norm_num [gdIter, tropicalFlow]
example : gdIter 1 2 (-4) 1 = -2 := by norm_num [gdIter, tropicalFlow]
example : gdIter 1 2 (-4) 2 = 0 := by norm_num [gdIter, tropicalFlow]
example : gdIter 1 2 (-4) 3 = 1 := by norm_num [gdIter, tropicalFlow]
example : tropicalAffine (gdIter 1 2 (-4) 3) 7 = 8 := by
  norm_num [gdIter, tropicalFlow, tropicalAffine]

end EMLTropicalGD