import Mathlib

/-!
# Full layer normalization: centering, variance scaling, and the learned affine stage

The catalog file `Catalog/MachineLearning/TransformerArchitecture.lean` deliberately
formalizes only the *learned affine* part of layer normalization (`affineNorm`), noting that
the data-dependent centering and variance normalization is a different, nonlinear operation.

This file adds the missing nonlinear stage and studies its exact symmetry group:

* `layerNorm_shift_invariant` — invariance under adding a constant to every coordinate;
* `layerNorm_pos_smul` — invariance under positive rescaling (with the ε-budget rescaled
  accordingly), and `layerNorm_neg_smul` showing that a negative scaling flips the sign, so
  the invariance group is exactly the shifts and the *positive* dilations;
* `layerNorm_not_neg_smul_invariant` — the sharp boundary: for a nonconstant input the
  negative-scaling symmetry genuinely fails;
* `sum_layerNorm_eq_zero`, `sum_sq_layerNorm` — the output has mean zero and second moment
  `n * v / (v + ε)`, hence exactly unit variance at `ε = 0`;
* `layerNorm_idempotent` — layer normalization is idempotent on nonconstant inputs;
* `fullLayerNorm_shift_invariant`, `fullLayerNorm_comp_affine` — composing the nonlinear
  normalization with the learned affine stage of the catalog file.
-/

open scoped BigOperators

namespace LayerNorm

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Number of coordinates, as a real number. -/
noncomputable def dim (ι : Type*) [Fintype ι] : ℝ := (Fintype.card ι : ℝ)

theorem dim_pos : 0 < dim ι := by
  have h : 0 < Fintype.card ι := Fintype.card_pos
  simpa [dim] using (by exact_mod_cast h : (0:ℝ) < (Fintype.card ι : ℝ))

theorem dim_ne_zero : (dim ι) ≠ 0 := ne_of_gt dim_pos

/-- Coordinatewise mean of a feature vector. -/
noncomputable def mean (x : ι → ℝ) : ℝ := (∑ i, x i) / dim ι

/-- Coordinatewise (population) variance of a feature vector. -/
noncomputable def var (x : ι → ℝ) : ℝ := (∑ i, (x i - mean x) ^ 2) / dim ι

/-- Layer normalization with numerical stabilizer `ε`: centre, then divide by
`√(variance + ε)`. -/
noncomputable def layerNorm (eps : ℝ) (x : ι → ℝ) : ι → ℝ :=
  fun i => (x i - mean x) / Real.sqrt (var x + eps)

/-- The learned affine stage, as in the catalog transformer file. -/
def affineNorm (scale bias x : ι → ℝ) : ι → ℝ := fun i => scale i * x i + bias i

/-- Standard full layer normalization: nonlinear normalization followed by a learned
coordinatewise affine map. -/
noncomputable def fullLayerNorm (scale bias : ι → ℝ) (eps : ℝ) (x : ι → ℝ) : ι → ℝ :=
  affineNorm scale bias (layerNorm eps x)

/-! ### Basic identities -/

theorem sum_centered (x : ι → ℝ) : ∑ i, (x i - mean x) = 0 := by
  have h : dim ι ≠ 0 := dim_ne_zero
  rw [Finset.sum_sub_distrib]
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mean, dim] at h ⊢
  field_simp
  ring

theorem mean_add_const (x : ι → ℝ) (c : ℝ) :
    mean (fun i => x i + c) = mean x + c := by
  have h : dim ι ≠ 0 := dim_ne_zero
  simp only [mean, dim, Finset.sum_add_distrib, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul] at h ⊢
  field_simp

omit [Nonempty ι] in
theorem mean_smul (a : ℝ) (x : ι → ℝ) :
    mean (fun i => a * x i) = a * mean x := by
  simp only [mean, ← Finset.mul_sum]
  ring

theorem var_add_const (x : ι → ℝ) (c : ℝ) :
    var (fun i => x i + c) = var x := by
  simp only [var, mean_add_const]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  ring_nf

omit [Nonempty ι] in
theorem var_smul (a : ℝ) (x : ι → ℝ) :
    var (fun i => a * x i) = a ^ 2 * var x := by
  simp only [var, mean_smul]
  rw [Finset.sum_congr rfl (g := fun i => a ^ 2 * (x i - mean x) ^ 2)
    (fun i _ => by ring), ← Finset.mul_sum]
  ring

theorem var_nonneg (x : ι → ℝ) : 0 ≤ var x := by
  apply div_nonneg _ (le_of_lt dim_pos)
  exact Finset.sum_nonneg fun i _ => sq_nonneg _

theorem sum_sq_centered (x : ι → ℝ) :
    ∑ i, (x i - mean x) ^ 2 = dim ι * var x := by
  have h : dim ι ≠ 0 := dim_ne_zero
  rw [var]
  field_simp

/-- A vector has zero variance exactly when it is constant. -/
theorem var_eq_zero_iff (x : ι → ℝ) : var x = 0 ↔ ∀ i, x i = mean x := by
  constructor
  · intro h i
    have hs : ∑ j, (x j - mean x) ^ 2 = 0 := by
      rw [sum_sq_centered, h, mul_zero]
    have := (Finset.sum_eq_zero_iff_of_nonneg
      (fun j _ => sq_nonneg (x j - mean x))).mp hs i (Finset.mem_univ i)
    have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
    linarith
  · intro h
    simp only [var]
    rw [Finset.sum_eq_zero fun i _ => by rw [h i]; ring, zero_div]

/-! ### The exact symmetry group of layer normalization -/

/-- **Shift invariance.**  Adding the same constant to every coordinate leaves layer
normalization unchanged. -/
theorem layerNorm_shift_invariant (eps c : ℝ) (x : ι → ℝ) :
    layerNorm eps (fun i => x i + c) = layerNorm eps x := by
  funext i
  simp only [layerNorm, mean_add_const, var_add_const]
  ring_nf

omit [Nonempty ι] in
/-- **Positive-scale invariance.**  Rescaling the input by `a > 0` and the stabilizer by
`a²` leaves layer normalization unchanged.  In particular (`eps = 0`) layer normalization is
invariant under all positive dilations. -/
theorem layerNorm_pos_smul (eps a : ℝ) (ha : 0 < a) (x : ι → ℝ) :
    layerNorm (a ^ 2 * eps) (fun i => a * x i) = layerNorm eps x := by
  funext i
  simp only [layerNorm, mean_smul, var_smul]
  have hfac : a ^ 2 * var x + a ^ 2 * eps = a ^ 2 * (var x + eps) := by ring
  rw [hfac, Real.sqrt_mul (sq_nonneg a), Real.sqrt_sq (le_of_lt ha)]
  rw [show a * x i - a * mean x = a * (x i - mean x) by ring]
  exact mul_div_mul_left _ _ (ne_of_gt ha)

omit [Nonempty ι] in
/-- **Negative scalings flip the sign.**  Together with `layerNorm_pos_smul` this pins down
the symmetry group: shifts and positive dilations act trivially, negative dilations act by
`-1`. -/
theorem layerNorm_neg_smul (eps a : ℝ) (ha : a < 0) (x : ι → ℝ) :
    layerNorm (a ^ 2 * eps) (fun i => a * x i) = fun i => -(layerNorm eps x i) := by
  funext i
  simp only [layerNorm, mean_smul, var_smul]
  have hfac : a ^ 2 * var x + a ^ 2 * eps = a ^ 2 * (var x + eps) := by ring
  rw [hfac, Real.sqrt_mul (sq_nonneg a), Real.sqrt_sq_eq_abs, abs_of_neg ha]
  rw [show a * x i - a * mean x = a * (x i - mean x) by ring]
  rw [show -a * Real.sqrt (var x + eps) = (-a) * Real.sqrt (var x + eps) from rfl]
  rw [show a * (x i - mean x) = (-a) * (-(x i - mean x)) by ring]
  rw [mul_div_mul_left _ _ (by linarith : -a ≠ 0)]
  ring

/-- **Sharpness of the positivity hypothesis.**  For a nonconstant input, negative scaling
really does change the normalized output, so the invariance in `layerNorm_pos_smul` cannot be
extended to all nonzero scalings. -/
theorem layerNorm_not_neg_smul_invariant (eps a : ℝ) (ha : a < 0) (x : ι → ℝ)
    (heps : 0 ≤ eps) (hx : var x ≠ 0) :
    layerNorm (a ^ 2 * eps) (fun i => a * x i) ≠ layerNorm eps x := by
  intro hcontra
  rw [layerNorm_neg_smul eps a ha x] at hcontra
  obtain ⟨i, hi⟩ : ∃ i, x i ≠ mean x := by
    by_contra hall
    push_neg at hall
    exact hx ((var_eq_zero_iff x).mpr hall)
  have hval := congrFun hcontra i
  have hvpos : 0 < var x + eps := lt_of_lt_of_le (lt_of_le_of_ne (var_nonneg x) (Ne.symm hx))
    (by linarith)
  have hs : 0 < Real.sqrt (var x + eps) := Real.sqrt_pos.mpr hvpos
  simp only [layerNorm] at hval
  have : (x i - mean x) / Real.sqrt (var x + eps) = 0 := by linarith [hval]
  rw [div_eq_zero_iff] at this
  rcases this with h | h
  · exact hi (by linarith)
  · exact absurd h (ne_of_gt hs)

/-! ### Moments of the normalized output -/

/-- The normalized output has mean zero. -/
theorem sum_layerNorm_eq_zero (eps : ℝ) (x : ι → ℝ) :
    ∑ i, layerNorm eps x i = 0 := by
  simp only [layerNorm, ← Finset.sum_div, sum_centered, zero_div]

theorem mean_layerNorm (eps : ℝ) (x : ι → ℝ) : mean (layerNorm eps x) = 0 := by
  rw [mean, sum_layerNorm_eq_zero, zero_div]

/-- The second moment of the normalized output is `n · v / (v + ε)`. -/
theorem sum_sq_layerNorm (eps : ℝ) (x : ι → ℝ) (h : 0 < var x + eps) :
    ∑ i, (layerNorm eps x i) ^ 2 = dim ι * var x / (var x + eps) := by
  simp only [layerNorm, div_pow]
  rw [Real.sq_sqrt (le_of_lt h), ← Finset.sum_div, sum_sq_centered]

/-- **Unit variance.**  With no stabilizer, a nonconstant input is mapped to a vector of
variance exactly one. -/
theorem var_layerNorm_eq_one (x : ι → ℝ) (hx : var x ≠ 0) :
    var (layerNorm 0 x) = 1 := by
  have hpos : 0 < var x + 0 := by
    have := var_nonneg x
    cases lt_or_eq_of_le this with
    | inl h => linarith
    | inr h => exact absurd h.symm hx
  have hsum := sum_sq_layerNorm 0 x hpos
  simp only [var, mean_layerNorm, sub_zero]
  rw [hsum]
  have h : dim ι ≠ 0 := dim_ne_zero
  field_simp
  ring

/-- **Idempotence.**  Layer normalization is a projection onto the mean-zero,
unit-variance sphere. -/
theorem layerNorm_idempotent (x : ι → ℝ) (hx : var x ≠ 0) :
    layerNorm 0 (layerNorm 0 x) = layerNorm 0 x := by
  funext i
  simp only [layerNorm, mean_layerNorm, var_layerNorm_eq_one x hx, sub_zero, add_zero,
    Real.sqrt_one, div_one]

/-- Degenerate inputs collapse to zero. -/
theorem layerNorm_const (eps c : ℝ) : layerNorm eps (fun _ : ι => c) = fun _ => 0 := by
  funext i
  have hmean : mean (fun _ : ι => c) = c := by
    have h : dim ι ≠ 0 := dim_ne_zero
    simp only [mean, dim, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at h ⊢
    field_simp
  simp only [layerNorm, hmean, sub_self, zero_div]

/-! ### Composition with the learned affine stage -/

/-- The full layer normalization inherits shift invariance from its nonlinear stage. -/
theorem fullLayerNorm_shift_invariant (scale bias : ι → ℝ) (eps c : ℝ) (x : ι → ℝ) :
    fullLayerNorm scale bias eps (fun i => x i + c) = fullLayerNorm scale bias eps x := by
  simp only [fullLayerNorm, layerNorm_shift_invariant]

omit [Nonempty ι] in
/-- The full layer normalization inherits positive-scale invariance. -/
theorem fullLayerNorm_pos_smul (scale bias : ι → ℝ) (eps a : ℝ) (ha : 0 < a) (x : ι → ℝ) :
    fullLayerNorm scale bias (a ^ 2 * eps) (fun i => a * x i)
      = fullLayerNorm scale bias eps x := by
  simp only [fullLayerNorm, layerNorm_pos_smul eps a ha]

omit [Nonempty ι] in
/-- Two stacked learned affine stages collapse into one, so a full layer normalization
followed by another affine stage is again a full layer normalization. -/
theorem fullLayerNorm_comp_affine (s₁ b₁ s₂ b₂ : ι → ℝ) (eps : ℝ) (x : ι → ℝ) :
    affineNorm s₂ b₂ (fullLayerNorm s₁ b₁ eps x)
      = fullLayerNorm (fun i => s₂ i * s₁ i) (fun i => s₂ i * b₁ i + b₂ i) eps x := by
  funext i
  simp only [fullLayerNorm, affineNorm]
  ring

/-- The mean of a full layer normalization output is determined by the learned bias alone:
all input dependence beyond the normalization is affine. -/
theorem mean_fullLayerNorm_of_const_scale (c : ℝ) (bias : ι → ℝ) (eps : ℝ) (x : ι → ℝ) :
    mean (fullLayerNorm (fun _ => c) bias eps x) = mean bias := by
  simp only [fullLayerNorm, affineNorm, mean, Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [show ∑ i, layerNorm eps x i = 0 from sum_layerNorm_eq_zero eps x]
  simp

end LayerNorm