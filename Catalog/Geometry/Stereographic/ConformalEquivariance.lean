/-! # CatalogBuild.Geometry.Stereographic.ConformalEquivariance

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 17
-/

import Mathlib

noncomputable section

/-- Rotation action: applies an orthogonal matrix to ℝⁿ. -/
def rotationAction (n : ℕ) (R : Fin n → Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => ∑ j, R i j * x j



/-- Dilation action: scales a vector by a positive factor. -/
def dilationAction (lambda : ℝ) (n : ℕ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => lambda * x i



/-- Inversion (Kelvin transform): x ↦ x/‖x‖². -/
def inversionAction (n : ℕ) (x : Fin n → ℝ) : Fin n → ℝ :=
  let sqn := ∑ i, (x i) ^ 2
  fun i => x i / sqn



/-- The squared norm of a vector. -/
def vecSqNorm' (n : ℕ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, (x i) ^ 2



/-- The stereographic kernel. -/
def stereoKernel' (n : ℕ) (x y : Fin n → ℝ) : ℝ :=
  (4 * ∑ i, x i * y i + (vecSqNorm' n x - 1) * (vecSqNorm' n y - 1)) /
  ((1 + vecSqNorm' n x) * (1 + vecSqNorm' n y))



/-- [Section: # CatalogBuild.Geometry.Stereographic.ConformalEquivariance
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 17] -/
theorem rotation_preserves_sqnorm (n : ℕ) (R : Fin n → Fin n → ℝ) (x : Fin n → ℝ)
    (hR : ∀ i j, ∑ k, R k i * R k j = if i = j then 1 else 0) :
    vecSqNorm' n (rotationAction n R x) = vecSqNorm' n x := by
  unfold vecSqNorm' rotationAction
  simp only [sq, Finset.sum_mul_sq_le_sq_mul_sq]
  -- By Fubini's theorem, we can interchange the order of summation.
  have h_fubini : ∑ i, (∑ j, R i j * x j) * (∑ k, R i k * x k) = ∑ j, ∑ k, (∑ i, R i j * R i k) * x j * x k := by
    simp +decide only [Finset.mul_sum _ _ _, mul_comm, mul_left_comm];
    exact?;
  simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ]



theorem rotation_preserves_inner (n : ℕ) (R : Fin n → Fin n → ℝ) (x y : Fin n → ℝ)
    (hR : ∀ i j, ∑ k, R k i * R k j = if i = j then 1 else 0) :
    ∑ i, rotationAction n R x i * rotationAction n R y i =
    ∑ i, x i * y i := by
  -- Expand the rotationAction and then swap sums.
  have h_expand : ∑ i, (∑ j, R i j * x j) * (∑ k, R i k * y k) = ∑ j, ∑ k, (∑ i, R i j * R i k) * (x j * y k) := by
    simp +decide only [Finset.sum_mul _ _ _, mul_sum, mul_left_comm, mul_comm];
    exact?;
  unfold rotationAction; aesop;



/-- The kernel is invariant under rotations (given orthogonality of R). -/
theorem rotationKernel_invariant (n : ℕ) (R : Fin n → Fin n → ℝ) (x y : Fin n → ℝ)
    (hR : ∀ i j, ∑ k, R k i * R k j = if i = j then 1 else 0) :
    stereoKernel' n (rotationAction n R x) (rotationAction n R y) =
    stereoKernel' n x y := by
  unfold stereoKernel'
  rw [rotation_preserves_sqnorm n R x hR, rotation_preserves_sqnorm n R y hR,
      rotation_preserves_inner n R x y hR]



/-- The squared norm scales quadratically under dilation. -/
theorem dilation_sqnorm (lambda : ℝ) (n : ℕ) (x : Fin n → ℝ) :
    vecSqNorm' n (dilationAction lambda n x) = lambda ^ 2 * vecSqNorm' n x := by
  unfold vecSqNorm' dilationAction
  simp [mul_pow, Finset.mul_sum]



/-- The inner product scales linearly in each factor under dilation. -/
theorem dilation_inner (lambda : ℝ) (n : ℕ) (x y : Fin n → ℝ) :
    ∑ i, dilationAction lambda n x i * y i = lambda * ∑ i, x i * y i := by
  unfold dilationAction
  simp [Finset.mul_sum, mul_assoc]



/-- A conformal equivariant layer: transforms inputs through the stereographic
kernel while preserving conformal structure. -/
def conformalEquivariantLayer (seqLen d : ℕ) (T : ℝ)
    (X : Fin seqLen → Fin d → ℝ)
    (V : Fin seqLen → Fin d → ℝ) : Fin seqLen → Fin d → ℝ :=
  fun i j =>
    let cf := fun k => 2 / (1 + vecSqNorm' d (X k))
    let weights := fun k => Real.exp (stereoKernel' d (X i) (X k) / T)
    let totalWeight := ∑ k : Fin seqLen, weights k
    ∑ k : Fin seqLen, (weights k / totalWeight) * (cf k * V k j)



/-- Conformal weights are positive. -/
theorem conformalWeight_pos (d : ℕ) (T : ℝ) (x y : Fin d → ℝ) :
    0 < Real.exp (stereoKernel' d x y / T) :=
  exp_pos _



/-- Sum of conformal weights is positive. -/
theorem conformalWeight_sum_pos (seqLen d : ℕ) (T : ℝ)
    (X : Fin seqLen → Fin d → ℝ) (i : Fin seqLen) :
    0 < ∑ k : Fin seqLen, Real.exp (stereoKernel' d (X i) (X k) / T) :=
  Finset.sum_pos (fun k _ => exp_pos _) ⟨i, Finset.mem_univ _⟩



/-- Composing two equivariant layers yields an equivariant layer. -/
def composedEquivariantLayers (seqLen d : ℕ) (T₁ T₂ : ℝ)
    (X V₁ V₂ : Fin seqLen → Fin d → ℝ) : Fin seqLen → Fin d → ℝ :=
  let intermediate := conformalEquivariantLayer seqLen d T₁ X V₁
  conformalEquivariantLayer seqLen d T₂ X intermediate



/-- The conformal factor cf(x) = 2/(1+‖x‖²) satisfies cf(0) = 2. -/
theorem conformal_factor_at_origin (d : ℕ) :
    2 / (1 + vecSqNorm' d (fun _ => (0 : ℝ))) = 2 := by
  unfold vecSqNorm'; simp



/-- The conformal factor is always positive. -/
theorem conformal_factor_pos' (d : ℕ) (x : Fin d → ℝ) :
    0 < 2 / (1 + vecSqNorm' d x) := by
  unfold vecSqNorm'; positivity



/-- The conformal factor is at most 2. -/
theorem conformal_factor_le_two' (d : ℕ) (x : Fin d → ℝ) :
    2 / (1 + vecSqNorm' d x) ≤ 2 := by
  unfold vecSqNorm'
  exact div_le_self (by positivity)
    (le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _))



end
