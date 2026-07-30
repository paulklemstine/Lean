import Mathlib

/-!
# Exact nullspace geometry for finite exp-log models

This file deepens the finite EML analysis from a single common exponential scale to
an arbitrary feature `g₁`.  It proves a general Gram/nullspace theorem for Fisher
matrices, applies it to the three-parameter exp-log model

`exp(θ₁ g₁(x)) * log(θ₂ g₂(x) + θ₃)`,

and isolates the precise obstruction caused by a constant exponential feature.
The result is stronger than merely exhibiting a zero determinant: every null
Fisher direction is characterized pointwise as a vanishing centered directional
score.
-/

noncomputable section

open Finset
open scoped BigOperators

namespace EMLInformationGeometryDeepening

variable {ι : Type*} [Fintype ι]
variable {d : ℕ}

/-- Center a collection of score functions with respect to weights `p`. -/
def centeredScore (p : ι → ℝ) (s : ι → Fin d → ℝ) (i : ι) (j : Fin d) : ℝ :=
  s i j - ∑ k, p k * s k j

/-- The finite Fisher matrix is the weighted Gram matrix of centered scores. -/
def fisherMatrix (p : ι → ℝ) (s : ι → Fin d → ℝ) (j k : Fin d) : ℝ :=
  ∑ i, p i * centeredScore p s i j * centeredScore p s i k

/-- A tangent vector contracted with the centered score. -/
def directionalScore (p : ι → ℝ) (s : ι → Fin d → ℝ)
    (v : Fin d → ℝ) (i : ι) : ℝ :=
  ∑ j, v j * centeredScore p s i j

/-- The Fisher quadratic form is an expectation of a square. -/
theorem fisher_quadForm_eq_sum_sq (p : ι → ℝ) (s : ι → Fin d → ℝ)
    (v : Fin d → ℝ) :
    (∑ j, ∑ k, v j * fisherMatrix p s j k * v k) =
      ∑ i, p i * directionalScore p s v i ^ 2 := by
  unfold fisherMatrix directionalScore
  simp_rw [sq, Finset.mul_sum, Finset.sum_mul]
  simp_rw [mul_assoc, mul_comm, mul_left_comm]
  rw [Finset.sum_comm, Finset.sum_comm, Finset.sum_comm]
  conv_rhs =>
    arg 2
    ext x
    arg 2
    ext x_1
    rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  conv_lhs => arg 2; ext y; rw [Finset.sum_comm]
  rw [Finset.sum_comm]
  ac_rfl

/-- Every finite Fisher matrix with nonnegative weights is positive semidefinite. -/
theorem fisher_positiveSemidefinite (p : ι → ℝ) (s : ι → Fin d → ℝ)
    (hp : ∀ i, 0 ≤ p i) (v : Fin d → ℝ) :
    0 ≤ ∑ j, ∑ k, v j * fisherMatrix p s j k * v k := by
  rw [fisher_quadForm_eq_sum_sq]
  apply Finset.sum_nonneg
  intro i _
  apply mul_nonneg (hp i)
  apply sq_nonneg

/-- With full support, the Fisher nullspace consists exactly of directions whose
centered directional score vanishes at every sample. -/
theorem fisher_quadForm_eq_zero_iff (p : ι → ℝ) (s : ι → Fin d → ℝ)
    (hp : ∀ i, 0 < p i) (v : Fin d → ℝ) :
    (∑ j, ∑ k, v j * fisherMatrix p s j k * v k) = 0 ↔
      ∀ i, directionalScore p s v i = 0 := by
  have hsum : ∑ j, ∑ k, v j * fisherMatrix p s j k * v k = ∑ i, p i * directionalScore p s v i ^ 2 := by
    simp only [fisherMatrix, directionalScore, pow_two]
    simp_rw [Finset.mul_sum, Finset.sum_mul]
    -- First swap the inner sums (k ↔ i), then outer sums (j ↔ i)
    have h₁ : ∀ j, ∑ k, ∑ i, v j * (p i * centeredScore p s i j * centeredScore p s i k) * v k =
              ∑ i, ∑ k, v j * (p i * centeredScore p s i j * centeredScore p s i k) * v k := fun j =>
      Finset.sum_comm
    simp_rw [h₁]
    rw [Finset.sum_comm]
    -- Both sides now have ∑ y : ι, ∑ x : Fin d, ∑ k : Fin d
    apply Finset.sum_congr rfl
    intro y _
    apply Finset.sum_congr rfl
    intro x _
    simp_rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro k _
    ring
  rw [hsum]
  -- Now prove: (∑ i, p i * directionalScore p s v i ^ 2) = 0 ↔ ∀ i, directionalScore p s v i = 0
  constructor
  · intro h i
    rw [Finset.sum_eq_zero_iff_of_nonneg (fun j _ => mul_nonneg (le_of_lt (hp j)) (sq_nonneg _))] at h
    specialize h i (Finset.mem_univ i)
    simp only [mul_eq_zero] at h
    rw [← sq_eq_zero_iff]
    exact h.resolve_left (ne_of_gt (hp i))
  · intro h
    simp [h]

/-- Unnormalized weight of the three-parameter finite EML model. -/
def emlRaw (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ) (i : ι) : ℝ :=
  Real.exp (θ 0 * g₁ i) * Real.log (θ 1 * g₂ i + θ 2)

/-- Partition function of the EML model. -/
def emlMass (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ) : ℝ :=
  ∑ i, emlRaw g₁ g₂ θ i

/-- Normalized EML probability. -/
def emlProbability (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ) (i : ι) : ℝ :=
  emlRaw g₁ g₂ θ i / emlMass g₁ g₂ θ

/-- The three raw logarithmic parameter scores. -/
def emlRawScore (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ) (i : ι) : Fin 3 → ℝ
  | 0 => g₁ i
  | 1 => g₂ i / ((θ 1 * g₂ i + θ 2) * Real.log (θ 1 * g₂ i + θ 2))
  | 2 => 1 / ((θ 1 * g₂ i + θ 2) * Real.log (θ 1 * g₂ i + θ 2))

omit [Fintype ι] in
/-- If every log argument exceeds one, every unnormalized EML weight is positive. -/
theorem emlRaw_pos (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ)
    (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) (i : ι) :
    0 < emlRaw g₁ g₂ θ i := by
  unfold emlRaw
  apply mul_pos
  · exact Real.exp_pos _
  · exact Real.log_pos (hlog i)

/-- On a nonempty finite sample space, the EML partition function is positive. -/
theorem emlMass_pos [Nonempty ι] (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ)
    (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) :
    0 < emlMass g₁ g₂ θ := by
  unfold emlMass
  apply Finset.sum_pos'
  · intro i _
    exact le_of_lt (emlRaw_pos g₁ g₂ θ hlog i)
  · exact ⟨Classical.arbitrary ι, Finset.mem_univ _, emlRaw_pos g₁ g₂ θ hlog _⟩

/-- Under the natural domain condition, normalized EML probabilities have full support. -/
theorem emlProbability_pos [Nonempty ι] (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ)
    (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) (i : ι) :
    0 < emlProbability g₁ g₂ θ i := by
  unfold emlProbability
  exact div_pos (emlRaw_pos g₁ g₂ θ hlog i) (emlMass_pos g₁ g₂ θ hlog)

/-- The normalized EML weights sum to one. -/
theorem emlProbability_sum [Nonempty ι] (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ)
    (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) :
    ∑ i, emlProbability g₁ g₂ θ i = 1 := by
  unfold emlProbability emlMass
  rw [← Finset.sum_div]
  have hne : ∑ i, emlRaw g₁ g₂ θ i ≠ 0 := ne_of_gt (emlMass_pos g₁ g₂ θ hlog)
  rw [div_self hne]

/-- The three-parameter EML Fisher matrix. -/
def emlFisher (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ) : Fin 3 → Fin 3 → ℝ :=
  fisherMatrix (emlProbability g₁ g₂ θ) (emlRawScore g₁ g₂ θ)

/-- The EML Fisher matrix is positive semidefinite throughout its natural domain. -/
theorem emlFisher_positiveSemidefinite [Nonempty ι]
    (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ)
    (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) (v : Fin 3 → ℝ) :
    0 ≤ ∑ j, ∑ k, v j * emlFisher g₁ g₂ θ j k * v k := by
  exact fisher_positiveSemidefinite _ _
    (fun i => le_of_lt (emlProbability_pos g₁ g₂ θ hlog i)) v

/-- Exact local identifiability criterion: an EML parameter direction has zero
Fisher information iff its centered directional raw score vanishes pointwise. -/
theorem emlFisher_null_iff [Nonempty ι]
    (g₁ g₂ : ι → ℝ) (θ : Fin 3 → ℝ)
    (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) (v : Fin 3 → ℝ) :
    (∑ j, ∑ k, v j * emlFisher g₁ g₂ θ j k * v k) = 0 ↔
      ∀ i, directionalScore (emlProbability g₁ g₂ θ)
        (emlRawScore g₁ g₂ θ) v i = 0 := by
  exact fisher_quadForm_eq_zero_iff _ _
    (fun i => emlProbability_pos g₁ g₂ θ hlog i) v

/-- A constant exponential feature creates a genuine gauge direction: changing
`θ₁` does not change any normalized probability. -/
theorem probability_independent_of_theta_one [Nonempty ι]
    (g₁ g₂ : ι → ℝ) (c : ℝ) (hg₁ : ∀ i, g₁ i = c)
    (θ θ' : Fin 3 → ℝ) (hrest : θ 1 = θ' 1 ∧ θ 2 = θ' 2) (i : ι) :
    emlProbability g₁ g₂ θ i = emlProbability g₁ g₂ θ' i := by
  obtain ⟨hθ1, hθ2⟩ := hrest
  unfold emlProbability emlMass emlRaw
  simp_rw [hg₁, hθ1, hθ2]
  rw [← Finset.mul_sum, ← Finset.mul_sum]
  rw [mul_div_mul_left _ _ (Real.exp_ne_zero _),
    mul_div_mul_left _ _ (Real.exp_ne_zero _)]

/-- Contrarian conclusion: when `g₁` is constant, the first coordinate vector is
always a nonzero null direction of the full three-parameter EML Fisher matrix. -/
theorem constant_feature_forces_fisher_degeneracy [Nonempty ι]
    (g₁ g₂ : ι → ℝ) (c : ℝ) (hg₁ : ∀ i, g₁ i = c)
    (θ : Fin 3 → ℝ) (hlog : ∀ i, 1 < θ 1 * g₂ i + θ 2) :
    let e₁ : Fin 3 → ℝ := fun j => if j = 0 then 1 else 0
    e₁ ≠ 0 ∧
      (∑ j, ∑ k, e₁ j * emlFisher g₁ g₂ θ j k * e₁ k) = 0 := by
  have he₁_ne_zero : (fun j : Fin 3 => if j = 0 then (1 : ℝ) else 0) ≠ 0 := by
    intro h
    have := congr_fun h 0
    simp at this
  have h_quadratic : ∑ j, ∑ k, (fun j => if j = 0 then (1 : ℝ) else 0) j * emlFisher g₁ g₂ θ j k * (fun j => if j = 0 then (1 : ℝ) else 0) k = emlFisher g₁ g₂ θ 0 0 := by
    simp
  constructor
  · exact he₁_ne_zero
  · rw [h_quadratic]
    unfold emlFisher
    simp only [fisherMatrix]
    have h_centered_zero : ∀ i, centeredScore (emlProbability g₁ g₂ θ) (emlRawScore g₁ g₂ θ) i 0 = 0 := by
      intro i
      unfold centeredScore emlRawScore
      simp_rw [hg₁]
      rw [← Finset.sum_mul]
      simp [emlProbability_sum g₁ g₂ θ hlog]
    simp_rw [h_centered_zero]
    simp

end EMLInformationGeometryDeepening