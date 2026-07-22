import Mathlib

/-!
# Alcubierre shift metrics: Lorentzian algebra, negative energy, and chronology

This file isolates three rigorous pointwise consequences of the standard Alcubierre
line element

`ds² = -dt² + (dx - β dt)² + dy² + dz²`, where `β = vₛ f(rₛ)`.

The results do **not** claim a full solution of the Einstein equations.  Instead they
formalize a reusable algebraic core and two cross-domain bridges:

* the shift metric is a Lorentzian quadratic form obtained from Minkowski space by
  an invertible shear;
* the usual Alcubierre Eulerian energy-density formula is the negative of a squared
  Euclidean transverse gradient, linking energy-condition violation to convex
  quadratic optimization;
* existence of a global time coordinate turns causal reachability into a strict
  order, excluding closed future-directed causal chains in this chart.
-/

namespace AlcubierreWarpDrive

/-- A tangent vector in coordinates `(t,x,y,z)`. -/
abbrev Tangent := Fin 4 → ℝ

/-- The local orthonormal-frame components for shift `β = vₛ f(rₛ)`. -/
def localFrame (β : ℝ) (X : Tangent) : Tangent :=
  ![X 0, X 1 - β * X 0, X 2, X 3]

/-- The pointwise Alcubierre quadratic form. -/
def metricQ (β : ℝ) (X : Tangent) : ℝ :=
  -(X 0)^2 + (X 1 - β * X 0)^2 + (X 2)^2 + (X 3)^2

/-- The associated symmetric bilinear form. -/
def metricB (β : ℝ) (X Y : Tangent) : ℝ :=
  -(X 0) * Y 0 + (X 1 - β * X 0) * (Y 1 - β * Y 0) +
    X 2 * Y 2 + X 3 * Y 3

/-- The inverse shear from the local orthonormal frame to chart components. -/
def fromLocalFrame (β : ℝ) (U : Tangent) : Tangent :=
  ![U 0, U 1 + β * U 0, U 2, U 3]

lemma localFrame_fromLocalFrame (β : ℝ) (U : Tangent) :
    localFrame β (fromLocalFrame β U) = U := by
  ext i
  fin_cases i <;> simp [localFrame, fromLocalFrame]

lemma fromLocalFrame_localFrame (β : ℝ) (X : Tangent) :
    fromLocalFrame β (localFrame β X) = X := by
  funext i
  fin_cases i <;> simp [localFrame, fromLocalFrame]

/-- Bridge to ordinary Minkowski geometry: the warp shift is exactly a shear. -/
theorem metricQ_eq_minkowski_after_shear (β : ℝ) (X : Tangent) :
    metricQ β X = -(localFrame β X 0)^2 + (localFrame β X 1)^2 +
      (localFrame β X 2)^2 + (localFrame β X 3)^2 := by
  rfl

/-- The Alcubierre bilinear form is nondegenerate for every real shift. -/
theorem metric_nondegenerate (β : ℝ) (X : Tangent)
    (h : ∀ Y : Tangent, metricB β X Y = 0) : X = 0 := by
  have h0 := h ![1, 0, 0, 0]
  have h1 := h ![0, 1, 0, 0]
  have h2 := h ![0, 0, 1, 0]
  have h3 := h ![0, 0, 0, 1]
  simp [metricB] at h0 h1 h2 h3
  rw [h1] at h0
  simp at h0
  have hx1 : X 1 = 0 := by rw [h0] at h1; simp at h1; linarith
  funext i
  fin_cases i <;> simp [h0, hx1, h2, h3]

/-- A unit timelike vector comoving with the bubble. -/
def bubbleTime (β : ℝ) : Tangent := ![1, β, 0, 0]

/-- Three coordinate spatial unit vectors. -/
def spatialX : Tangent := ![0, 1, 0, 0]
def spatialY : Tangent := ![0, 0, 1, 0]
def spatialZ : Tangent := ![0, 0, 0, 1]

/-- Explicit Lorentz-signature certificate: one negative and three positive axes. -/
theorem lorentz_signature_certificate (β : ℝ) :
    metricQ β (bubbleTime β) = -1 ∧
    metricQ β spatialX = 1 ∧ metricQ β spatialY = 1 ∧ metricQ β spatialZ = 1 ∧
    metricB β (bubbleTime β) spatialX = 0 ∧
    metricB β (bubbleTime β) spatialY = 0 ∧
    metricB β (bubbleTime β) spatialZ = 0 := by
  simp [metricQ, metricB, bubbleTime, spatialX, spatialY, spatialZ]

/-- Future-directed causal vectors in this chart. -/
def FutureCausal (β : ℝ) (X : Tangent) : Prop :=
  0 < X 0 ∧ metricQ β X ≤ 0

/-- Local causality bounds peculiar velocity relative to the bubble by light speed. -/
theorem no_local_ftl (β : ℝ) (X : Tangent) (h : FutureCausal β X) :
    |X 1 / X 0 - β| ≤ 1 := by
  -- Extract the conditions from FutureCausal
  rw [FutureCausal] at h
  obtain ⟨hX0_pos, hQ_nonpos⟩ := h
  -- metricQ β X = -(X 0)^2 + (X 1 - β * X 0)^2 + (X 2)^2 + (X 3)^2
  rw [metricQ] at hQ_nonpos
  -- We need to show |X 1 / X 0 - β| ≤ 1
  -- This is |(X 1 - β * X 0) / X 0| ≤ 1
  have h_eq : X 1 / X 0 - β = (X 1 - β * X 0) / X 0 := by
    field_simp
  rw [h_eq]
  have h_abs : |(X 1 - β * X 0) / X 0| = |X 1 - β * X 0| / X 0 := by
    rw [abs_div, abs_of_pos hX0_pos]
  rw [h_abs]
  -- Need |X 1 - β * X 0| ≤ X 0
  -- From hQ_nonpos: -(X 0)^2 + (X 1 - β * X 0)^2 + (X 2)^2 + (X 3)^2 ≤ 0
  -- So (X 1 - β * X 0)^2 ≤ (X 0)^2 - (X 2)^2 - (X 3)^2 ≤ (X 0)^2
  have h_sq_le : (X 1 - β * X 0)^2 ≤ (X 0)^2 := by
    have : (X 1 - β * X 0)^2 + (X 2)^2 + (X 3)^2 ≤ (X 0)^2 := by linarith
    nlinarith [sq_nonneg (X 2), sq_nonneg (X 3)]
  have h_abs_le : |X 1 - β * X 0| ≤ X 0 := by
    rw [← Real.sqrt_sq_eq_abs]
    rw [Real.sqrt_le_left (le_of_lt hX0_pos)]
    exact h_sq_le
  exact div_le_one_of_le₀ h_abs_le (le_of_lt hX0_pos)

/-- Coordinate-superluminal motion can coexist with strictly timelike local motion.
This is the precise pointwise sense in which a large shift produces effective FTL
without a local violation of the light cone. -/
theorem coordinate_ftl_without_local_ftl (β : ℝ) (hβ : 1 < β) :
    FutureCausal β (bubbleTime β) ∧
    (bubbleTime β 1 / bubbleTime β 0) > 1 ∧
    |bubbleTime β 1 / bubbleTime β 0 - β| = 0 := by
  constructor
  · constructor
    · simp [bubbleTime]
    · simp [metricQ, bubbleTime]
  constructor
  · simp [bubbleTime]; linarith
  · simp [bubbleTime]

/-- In the usual shift-flow interpretation, the longitudinal expansion scalar is
`v ∂ₓf`.  A positive shape derivative behind the bubble and a negative derivative
ahead therefore have opposite expansion signs. -/
def longitudinalExpansion (v shapeDerivative : ℝ) : ℝ := v * shapeDerivative

/-- A sign certificate for expansion behind and contraction ahead of a
positive-velocity bubble. -/
theorem expansion_behind_contraction_ahead
    (v rearDerivative frontDerivative : ℝ)
    (hv : 0 < v) (hrear : 0 < rearDerivative) (hfront : frontDerivative < 0) :
    0 < longitudinalExpansion v rearDerivative ∧
      longitudinalExpansion v frontDerivative < 0 := by
  simp [longitudinalExpansion]
  exact ⟨mul_pos hv hrear, mul_neg_of_pos_of_neg hv hfront⟩

section Energy

/-- The algebraic content of the Eulerian Alcubierre energy density.  The positive
constant `κ` absorbs conventional factors such as `1/(32π)`. -/
def energyDensity (κ v dy dz : ℝ) : ℝ :=
  -κ * v^2 * (dy^2 + dz^2)

/-- Energy-condition bridge: density is nonpositive because it is the negative of
an Euclidean squared norm. -/
theorem energyDensity_nonpos (κ v dy dz : ℝ) (hκ : 0 ≤ κ) :
    energyDensity κ v dy dz ≤ 0 := by
  unfold energyDensity
  have h1 : 0 ≤ v^2 := sq_nonneg v
  have h2 : 0 ≤ dy^2 + dz^2 := add_nonneg (sq_nonneg dy) (sq_nonneg dz)
  have h3 : 0 ≤ κ * v^2 := mul_nonneg hκ h1
  have h4 : 0 ≤ κ * v^2 * (dy^2 + dz^2) := mul_nonneg h3 h2
  linarith

/-- Nontrivial transverse shape gradient forces strictly negative density whenever
`κ` and the bubble speed are nonzero. -/
theorem energyDensity_strictly_negative (κ v dy dz : ℝ)
    (hκ : 0 < κ) (hv : v ≠ 0) (hgrad : dy ≠ 0 ∨ dz ≠ 0) :
    energyDensity κ v dy dz < 0 := by
  rw [energyDensity]
  have hv2 : 0 < v ^ 2 := by positivity
  have hgrad_pos : 0 < dy ^ 2 + dz ^ 2 := by
    cases hgrad with
    | inl hdy => positivity
    | inr hdz => positivity
  have hprod : 0 < κ * v ^ 2 * (dy ^ 2 + dz ^ 2) := by positivity
  linarith

/-- The density is homogeneous of degree two in bubble speed. -/
theorem energyDensity_speed_scaling (κ a v dy dz : ℝ) :
    energyDensity κ (a * v) dy dz = a^2 * energyDensity κ v dy dz := by
  simp [energyDensity]
  ring

/-- Exact small cases used as computational checks of sign and quadratic scaling. -/
theorem energyDensity_small_cases :
    energyDensity 1 0 3 4 = 0 ∧
    energyDensity 1 1 3 4 = -25 ∧
    energyDensity 1 2 3 4 = -100 ∧
    energyDensity 1 3 3 4 = -225 := by
  norm_num [energyDensity]

/-- A finite quadrature model of total energy. -/
def sampledEnergy {ι : Type*} [Fintype ι]
    (κ v : ℝ) (weight dy dz : ι → ℝ) : ℝ :=
  ∑ i, weight i * energyDensity κ v (dy i) (dz i)

/-- The quadratic speed law survives arbitrary finite spatial quadrature.  Thus the
standard density formula naturally predicts `v²`, not the conjectured linear `v`,
unless other parameters themselves depend on speed. -/
theorem sampledEnergy_speed_scaling {ι : Type*} [Fintype ι]
    (κ a v : ℝ) (weight dy dz : ι → ℝ) :
    sampledEnergy κ (a * v) weight dy dz =
      a^2 * sampledEnergy κ v weight dy dz := by
  simp only [sampledEnergy, energyDensity_speed_scaling]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- With nonnegative quadrature weights, sampled total energy is nonpositive. -/
theorem sampledEnergy_nonpos {ι : Type*} [Fintype ι]
    (κ v : ℝ) (weight dy dz : ι → ℝ) (hκ : 0 ≤ κ)
    (hw : ∀ i, 0 ≤ weight i) : sampledEnergy κ v weight dy dz ≤ 0 := by
  simp [sampledEnergy]
  apply Finset.sum_nonpos
  intro i _
  apply mul_nonpos_of_nonneg_of_nonpos (hw i)
  exact energyDensity_nonpos κ v (dy i) (dz i) hκ

end Energy

section Chronology

/-- An event retains only the global time coordinate needed for chronology. -/
structure Event where
  time : ℝ

/-- A finite future-directed causal chain: every segment strictly raises global time. -/
def FutureChain (γ : ℕ → Event) (n : ℕ) : Prop :=
  ∀ i < n, (γ i).time < (γ (i + 1)).time

lemma futureChain_time_strict (γ : ℕ → Event) (n : ℕ)
    (h : FutureChain γ n) (hn : 0 < n) : (γ 0).time < (γ n).time := by
  induction n with
  | zero => contradiction
  | succ n ih =>
    cases n with
    | zero => exact h 0 (by norm_num)
    | succ n' =>
      have := ih (fun i hi => h i (Nat.lt_succ_of_lt hi)) (by linarith)
      exact lt_trans this (h (n' + 1) (by linarith))

/-- Causality/order-theory bridge: a global time function makes future causal
reachability irreflexive, so no nonempty finite future-directed causal chain closes. -/
theorem no_closed_future_causal_chain (γ : ℕ → Event) (n : ℕ)
    (hn : 0 < n) (hchain : FutureChain γ n) : γ n ≠ γ 0 := by
  intro heq
  have := futureChain_time_strict γ n hchain hn
  rw [heq] at this
  exact lt_irrefl _ this

end Chronology

end AlcubierreWarpDrive