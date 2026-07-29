import Mathlib

/-!
# Fisher information of a normalized exp-log neuron

On a finite sample space, this file studies the normalized weights

`exp(a) * log(b * xᵢ + 1)`.

The common factor `exp(a)` cancels from the associated probability distribution.
Consequently the parameter `a` is not identifiable: its score vanishes, the
corresponding row and column of the Fisher matrix vanish, and the two-parameter
Fisher matrix is singular.  Thus this single-neuron family cannot carry a
nondegenerate two-dimensional Hessian metric, let alone a hyperbolic metric of
constant negative curvature, without changing the model or quotienting out the
redundant scale parameter.
-/

noncomputable section

open Finset
open scoped BigOperators

namespace EMLInformationGeometry

variable {ι : Type*} [Fintype ι]

/-- The logarithmic activation of sample `i`. -/
def activation (x : ι → ℝ) (b : ℝ) (i : ι) : ℝ :=
  Real.log (b * x i + 1)

/-- The total logarithmic activation. -/
def activationMass (x : ι → ℝ) (b : ℝ) : ℝ :=
  ∑ i, activation x b i

/-- The unnormalized exp-log weight of sample `i`. -/
def rawWeight (x : ι → ℝ) (a b : ℝ) (i : ι) : ℝ :=
  Real.exp a * activation x b i

/-- The partition function of the finite exp-log model. -/
def partition (x : ι → ℝ) (a b : ℝ) : ℝ :=
  ∑ i, rawWeight x a b i

/-- The normalized exp-log probability weight. -/
def probability (x : ι → ℝ) (a b : ℝ) (i : ι) : ℝ :=
  rawWeight x a b i / partition x a b

/-- The partition function factors into the exponential scale and activation mass. -/
theorem partition_factor (x : ι → ℝ) (a b : ℝ) :
    partition x a b = Real.exp a * activationMass x b := by
  simp [partition, rawWeight, activationMass, Finset.mul_sum]

omit [Fintype ι] in
/-- Positive inputs and a positive shape parameter give positive activations. -/
theorem activation_pos (x : ι → ℝ) (b : ℝ) (hb : 0 < b)
    (hx : ∀ i, 0 < x i) (i : ι) :
    0 < activation x b i := by
  apply Real.log_pos
  dsimp [activation]
  nlinarith [mul_pos hb (hx i)]

/-- On a nonempty sample space, positive inputs give positive activation mass. -/
theorem activationMass_pos [Nonempty ι] (x : ι → ℝ) (b : ℝ) (hb : 0 < b)
    (hx : ∀ i, 0 < x i) :
    0 < activationMass x b := by
  apply Finset.sum_pos
  · intro i _
    exact activation_pos x b hb hx i
  · exact Finset.univ_nonempty

/-- Normalization cancels the exponential scale parameter exactly. -/
theorem probability_scale_cancels (x : ι → ℝ) (a b : ℝ) (i : ι)
    (hmass : activationMass x b ≠ 0) :
    probability x a b i = activation x b i / activationMass x b := by
  rw [probability, partition_factor]
  unfold rawWeight
  field_simp [Real.exp_ne_zero, hmass]

/-- The normalized exp-log distribution is independent of `a`. -/
theorem probability_independent_of_scale (x : ι → ℝ) (a₁ a₂ b : ℝ) (i : ι)
    (hmass : activationMass x b ≠ 0) :
    probability x a₁ b i = probability x a₂ b i := by
  rw [probability_scale_cancels x a₁ b i hmass,
    probability_scale_cancels x a₂ b i hmass]

/-- When the activation mass is nonzero, the normalized weights sum to one. -/
theorem probability_sum (x : ι → ℝ) (a b : ℝ)
    (hmass : activationMass x b ≠ 0) :
    ∑ i, probability x a b i = 1 := by
  simp_rw [probability_scale_cancels x a b _ hmass]
  rw [← Finset.sum_div]
  exact div_self hmass

/-- Under positive inputs, the normalized exp-log weights form a strictly positive
probability distribution. -/
theorem probability_pos [Nonempty ι] (x : ι → ℝ) (a b : ℝ) (hb : 0 < b)
    (hx : ∀ i, 0 < x i) (i : ι) :
    0 < probability x a b i := by
  rw [probability_scale_cancels x a b i (ne_of_gt (activationMass_pos x b hb hx))]
  exact div_pos (activation_pos x b hb hx i) (activationMass_pos x b hb hx)

/-- The normalized score in the common scale direction.  The first term is the
logarithmic derivative of each raw weight and the second is that of the partition. -/
def scaleScore (x : ι → ℝ) (a b : ℝ) : ℝ :=
  1 - partition x a b / partition x a b

/-- The scale score vanishes wherever normalization is defined. -/
theorem scaleScore_eq_zero (x : ι → ℝ) (a b : ℝ)
    (hmass : activationMass x b ≠ 0) :
    scaleScore x a b = 0 := by
  have hp : partition x a b ≠ 0 := by
    rw [partition_factor]
    exact mul_ne_zero (Real.exp_ne_zero a) hmass
  simp [scaleScore, hp]

/-- The Fisher information in the exponential scale direction. -/
def fisherAA (x : ι → ℝ) (a b : ℝ) : ℝ :=
  ∑ i, probability x a b i * scaleScore x a b ^ 2

/-- The Fisher information of the scale parameter is zero. -/
theorem fisherAA_eq_zero (x : ι → ℝ) (a b : ℝ)
    (hmass : activationMass x b ≠ 0) :
    fisherAA x a b = 0 := by
  simp [fisherAA, scaleScore_eq_zero x a b hmass]

/-- The Fisher pairing between the scale score and an arbitrary second score. -/
def fisherScaleAgainst (x : ι → ℝ) (a b : ℝ) (score : ι → ℝ) : ℝ :=
  ∑ i, probability x a b i * scaleScore x a b * score i

/-- Every mixed Fisher term involving the redundant scale direction vanishes. -/
theorem fisherScaleAgainst_eq_zero (x : ι → ℝ) (a b : ℝ) (score : ι → ℝ)
    (hmass : activationMass x b ≠ 0) :
    fisherScaleAgainst x a b score = 0 := by
  simp [fisherScaleAgainst, scaleScore_eq_zero x a b hmass]

/-- The two-parameter Fisher matrix, with the true scale score in coordinate zero
and an arbitrary candidate score for the shape parameter in coordinate one. -/
def fisherMatrix (x : ι → ℝ) (a b : ℝ) (shapeScore : ι → ℝ) :
    Fin 2 → Fin 2 → ℝ :=
  fun j k => ∑ i, probability x a b i *
    (if j = 0 then scaleScore x a b else shapeScore i) *
    (if k = 0 then scaleScore x a b else shapeScore i)

/-- The determinant of the two-parameter Fisher matrix. -/
def fisherDeterminant (x : ι → ℝ) (a b : ℝ) (shapeScore : ι → ℝ) : ℝ :=
  fisherMatrix x a b shapeScore 0 0 * fisherMatrix x a b shapeScore 1 1 -
    fisherMatrix x a b shapeScore 0 1 * fisherMatrix x a b shapeScore 1 0

/-- The scale row of the Fisher matrix is zero. -/
theorem fisherMatrix_scale_row_zero (x : ι → ℝ) (a b : ℝ)
    (shapeScore : ι → ℝ) (hmass : activationMass x b ≠ 0) (k : Fin 2) :
    fisherMatrix x a b shapeScore 0 k = 0 := by
  simp [fisherMatrix, scaleScore_eq_zero x a b hmass]

/-- The scale column of the Fisher matrix is zero. -/
theorem fisherMatrix_scale_column_zero (x : ι → ℝ) (a b : ℝ)
    (shapeScore : ι → ℝ) (hmass : activationMass x b ≠ 0) (j : Fin 2) :
    fisherMatrix x a b shapeScore j 0 = 0 := by
  simp [fisherMatrix, scaleScore_eq_zero x a b hmass]

/-- The two-parameter Fisher matrix is singular for every possible shape score. -/
theorem fisherDeterminant_eq_zero (x : ι → ℝ) (a b : ℝ)
    (shapeScore : ι → ℝ) (hmass : activationMass x b ≠ 0) :
    fisherDeterminant x a b shapeScore = 0 := by
  simp [fisherDeterminant, fisherMatrix_scale_row_zero x a b shapeScore hmass]

/-- The Fisher quadratic form vanishes on the nonzero scale-coordinate vector,
so it cannot be positive definite on the proposed two-parameter space. -/
theorem fisher_not_positive_definite (x : ι → ℝ) (a b : ℝ)
    (shapeScore : ι → ℝ) (hmass : activationMass x b ≠ 0) :
    ∃ v : Fin 2 → ℝ, v ≠ 0 ∧
      ∑ j, ∑ k, v j * fisherMatrix x a b shapeScore j k * v k = 0 := by
  refine ⟨fun j => if j = 0 then 1 else 0, ?_, ?_⟩
  · intro hv
    have hzero := congrFun hv 0
    simp at hzero
  · simp [fisherMatrix_scale_column_zero x a b shapeScore hmass]

end EMLInformationGeometry