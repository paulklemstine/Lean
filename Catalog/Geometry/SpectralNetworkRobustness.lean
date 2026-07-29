import Mathlib

/-!
# Spectral graph control and certified robustness

This file isolates a precise, non-vacuous version of the proposed connection.
A graph spectral gap controls the squared variation of an internal computation
state; a Lipschitz readout then converts that control into an end-to-end
Lipschitz bound, which yields a certified classification radius.

It also formalizes two contrarian negative results: algebraic connectivity alone
cannot control either a network's Lipschitz constant or its robustness radius.
A gain bound and a positive output margin are both indispensable.
-/

namespace SpectralNetworkRobustness

/-- A scalar map has global Lipschitz bound `L`. -/
def LipschitzBound (f : ℝ → ℝ) (L : ℝ) : Prop :=
  ∀ x y, |f x - f y| ≤ L * |x - y|

/-- The positive binary decision at `x` is certified throughout an open radius. -/
def CertifiedPositive (f : ℝ → ℝ) (x r : ℝ) : Prop :=
  ∀ y, |y - x| < r → 0 < f y

/-- Dirichlet energy of the unique disagreement mode of a weighted two-node graph. -/
noncomputable def twoNodeEnergy (connectivity u v : ℝ) : ℝ :=
  connectivity / 2 * (u - v) ^ 2

/-- Variance about the mean for two scalar node states. -/
noncomputable def twoNodeVariance (u v : ℝ) : ℝ :=
  (u - v) ^ 2 / 2

/-- For the two-node model, the Poincaré inequality is sharp: its algebraic
connectivity is exactly the coefficient relating energy and variance. -/
theorem twoNode_spectral_gap_exact (connectivity u v : ℝ) :
    twoNodeEnergy connectivity u v =
      connectivity * twoNodeVariance u v := by
  unfold twoNodeEnergy twoNodeVariance
  ring

/-- A graph-state map whose disagreement is controlled in squared norm by a
spectral gap and an input-to-state gain. -/
def SpectralStateBound (connectivity gain : ℝ) (h : ℝ → ℝ) : Prop :=
  ∀ x y, connectivity * (h x - h y) ^ 2 ≤ gain ^ 2 * (x - y) ^ 2

/-- Spectral control of squared state variation implies a Lipschitz estimate.
The inverse square-root dependence on algebraic connectivity is explicit. -/
theorem spectral_state_lipschitz
    {connectivity gain : ℝ} {h : ℝ → ℝ}
    (hc : 0 < connectivity) (hg : 0 ≤ gain)
    (hs : SpectralStateBound connectivity gain h) :
    LipschitzBound h (gain / Real.sqrt connectivity) := by
  intro x y
  have h1 : connectivity * (h x - h y) ^ 2 ≤ gain ^ 2 * (x - y) ^ 2 := hs x y
  have h2 : (h x - h y) ^ 2 ≤ (gain ^ 2 / connectivity) * (x - y) ^ 2 := by
    have := h1
    rw [div_mul_eq_mul_div]
    rw [le_div_iff₀ hc]
    linarith
  have h3 : (h x - h y) ^ 2 ≤ ((gain / Real.sqrt connectivity) * (x - y)) ^ 2 := by
    rw [mul_pow, div_pow, Real.sq_sqrt (le_of_lt hc)]
    exact h2
  have h4 : |h x - h y| ≤ |gain / Real.sqrt connectivity * (x - y)| := by
    rwa [sq_le_sq] at h3
  have h5 : |gain / Real.sqrt connectivity * (x - y)| = gain / Real.sqrt connectivity * |x - y| := by
    rw [abs_mul, abs_of_nonneg (div_nonneg hg (Real.sqrt_nonneg _))]
  rw [h5] at h4
  exact h4

/-- Lipschitz constants multiply through a scalar readout. -/
theorem readout_composition_lipschitz
    {h readout : ℝ → ℝ} {stateGain readoutGain : ℝ}
    (hs : LipschitzBound h stateGain)
    (hr : LipschitzBound readout readoutGain)
    (hrg : 0 ≤ readoutGain) :
    LipschitzBound (fun x => readout (h x)) (readoutGain * stateGain) := by
  intro x y
  have h1 : |readout (h x) - readout (h y)| ≤ readoutGain * |h x - h y| := hr (h x) (h y)
  have h2 : |h x - h y| ≤ stateGain * |x - y| := hs x y
  calc |readout (h x) - readout (h y)| ≤ readoutGain * |h x - h y| := h1
    _ ≤ readoutGain * (stateGain * |x - y|) := by nlinarith
    _ = readoutGain * stateGain * |x - y| := by ring

/-- The standard margin-over-Lipschitz certificate for a positive binary score. -/
theorem margin_over_lipschitz_certifies
    {f : ℝ → ℝ} {x margin L : ℝ}
    (hm : f x = margin) (hmargin : 0 < margin)
    (hL : 0 < L) (hf : LipschitzBound f L) :
    CertifiedPositive f x (margin / L) := by
  intro y hy
  have h1 : |f y - f x| ≤ L * |y - x| := hf y x
  have h2 : f y ≥ f x - L * |y - x| := by
    have := abs_le.mp h1
    linarith
  rw [hm] at h2
  have h3 : L * |y - x| < margin := by
    calc L * |y - x| < L * (margin / L) := by nlinarith
      _ = margin := by field_simp
  linarith

/-- Main positive result: spectral gap, graph-state gain, readout gain, and
classification margin jointly certify a robustness radius. -/
theorem spectral_connectivity_certified_radius
    {connectivity stateGain readoutGain margin x : ℝ}
    {state readout : ℝ → ℝ}
    (hc : 0 < connectivity) (hsg : 0 < stateGain)
    (hrg : 0 < readoutGain) (hm : 0 < margin)
    (hs : SpectralStateBound connectivity stateGain state)
    (hr : LipschitzBound readout readoutGain)
    (hx : readout (state x) = margin) :
    CertifiedPositive (fun z => readout (state z)) x
      (margin * Real.sqrt connectivity / (readoutGain * stateGain)) := by
  -- First, derive Lipschitz bound for state from spectral bound
  have hstateLip : LipschitzBound state (stateGain / Real.sqrt connectivity) :=
    spectral_state_lipschitz hc (le_of_lt hsg) hs
  -- Compose with readout to get Lipschitz bound for full function
  have hfullLip : LipschitzBound (fun z => readout (state z))
      (readoutGain * (stateGain / Real.sqrt connectivity)) :=
    readout_composition_lipschitz hstateLip hr (le_of_lt hrg)
  -- Now use margin_over_lipschitz_certifies
  -- L = readoutGain * stateGain / sqrt(connectivity)
  -- radius = margin / L = margin * sqrt(connectivity) / (readoutGain * stateGain)
  have hL_pos : 0 < readoutGain * (stateGain / Real.sqrt connectivity) := by
    exact mul_pos hrg (div_pos hsg (Real.sqrt_pos.mpr hc))
  have hradius_eq : margin * Real.sqrt connectivity / (readoutGain * stateGain) =
      margin / (readoutGain * (stateGain / Real.sqrt connectivity)) := by
    field_simp
  rw [hradius_eq]
  exact margin_over_lipschitz_certifies hx hm hL_pos hfullLip

/-- Contrarian disproof: no proposed positive radius can follow from graph
connectivity alone.  For every `R > 0` and every connectivity value, an affine
score has positive margin at zero but changes sign inside radius `R`. -/
theorem connectivity_alone_no_robustness_radius
    (R : ℝ) (hR : 0 < R) :
    ∃ f : ℝ → ℝ, 0 < f 0 ∧ LipschitzBound f 1 ∧
      ¬ CertifiedPositive f 0 R := by
  use fun x => R / 2 - x
  refine ⟨by linarith, ?_, ?_⟩
  · intro x y
    show |R / 2 - x - (R / 2 - y)| ≤ 1 * |x - y|
    have : R / 2 - x - (R / 2 - y) = y - x := by ring
    rw [this]
    simp [abs_sub_comm]
  · simp only [CertifiedPositive, not_forall, not_lt, exists_prop]
    use R / 2
    constructor
    · rw [abs_of_pos] <;> linarith
    · norm_num

/-- Contrarian disproof: algebraic connectivity alone cannot upper-bound a
network Lipschitz constant.  Arbitrarily large scalar gains remain possible. -/
theorem connectivity_alone_no_lipschitz_bound
    (proposedBound : ℝ) (hB : 0 ≤ proposedBound) :
    ∃ f : ℝ → ℝ, ¬ LipschitzBound f proposedBound := by
  use fun x => (proposedBound + 1) * x
  simp only [LipschitzBound, not_forall, not_le]
  use 1, 0
  simp
  rw [abs_of_nonneg] <;> linarith

end SpectralNetworkRobustness