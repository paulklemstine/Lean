import Algebra.ParallelResidualBlocks

/-!
# Invertible residual blocks and the dual max-certificate

A residual block `x ↦ x + r x` with certificate `K < 1` is a *perturbation of the
identity by a contraction*.  On a complete space it is then a bi-Lipschitz bijection,
with inverse Lipschitz constant at most `(1 - K)⁻¹`.

This file proves that the **inverse certificates obey the very same max rule** as the
forward certificates: the parallel product of two invertible residual blocks is
invertible with inverse Lipschitz bound

`(1 - max K₁ K₂)⁻¹ = max ((1 - K₁)⁻¹) ((1 - K₂)⁻¹)`,

and this bound is sharp — attained by the inward dilations `x ↦ (1 - K) x`.  So the
invertible residual blocks form a sub-*groupoid* on which the certificate calculus is
strictly monoidal in both directions.

Main results:

* `ResidualBlock.antilipschitz` — `K < 1` gives `AntilipschitzWith (1 - K)⁻¹`;
* `ResidualBlock.surjective`, `ResidualBlock.bijective` — Banach fixed point;
* `ResidualBlock.inverse_lipschitz` — the inverse map is `(1 - K)⁻¹`-Lipschitz;
* `parallel_inverse_lipschitz_bound` — the max rule for inverse certificates;
* `parallel_inverse_isLeast` together with `coDilation_inverse_eq` — sharpness of that
  rule for every `K₁, K₂ < 1`.
-/

open NNReal ResidualCert

namespace ParallelResidualBlocks

namespace ResidualBlock

variable {X : Type*} [NormedAddCommGroup X] {K : ℝ≥0}

/-- A residual block whose certificate is `< 1` is an expansion-bounded (antilipschitz)
perturbation of the identity. -/
theorem antilipschitz (B : ResidualBlock X K) (hK : K < 1) :
    AntilipschitzWith (1 - K)⁻¹ B.toFun := by
  have h := (AntilipschitzWith.id (α := X)).add_lipschitzWith B.residual_lipschitz
    (by simpa using hK)
  simpa [toFun] using h

/-- In particular such a block is injective. -/
theorem injective (B : ResidualBlock X K) (hK : K < 1) : Function.Injective B.toFun :=
  (B.antilipschitz hK).injective

/-- **Banach fixed point.**  On a complete space, a residual block with certificate `< 1`
is surjective: `x + r x = y` is solvable for every `y`. -/
theorem surjective [CompleteSpace X] (B : ResidualBlock X K) (hK : K < 1) :
    Function.Surjective B.toFun := by
  haveI : Nonempty X := ⟨0⟩
  intro y
  have hlip : LipschitzWith K (fun x => y - B.residual x) := by
    have h : LipschitzWith (0 + K) (fun x => y + -B.residual x) :=
      (LipschitzWith.const y).add B.residual_lipschitz.neg
    simpa [sub_eq_add_neg] using h
  have hc : ContractingWith K (fun x => y - B.residual x) := ⟨hK, hlip⟩
  refine ⟨ContractingWith.fixedPoint _ hc, ?_⟩
  have hfix : y - B.residual (ContractingWith.fixedPoint _ hc)
      = ContractingWith.fixedPoint _ hc := hc.fixedPoint_isFixedPt
  have h2 : (y - B.residual (ContractingWith.fixedPoint _ hc))
      + B.residual (ContractingWith.fixedPoint _ hc) = y := by abel
  rw [hfix] at h2
  simpa only [toFun] using h2

theorem bijective [CompleteSpace X] (B : ResidualBlock X K) (hK : K < 1) :
    Function.Bijective B.toFun :=
  ⟨B.injective hK, B.surjective hK⟩

/-- The inverse map of a residual block (`Function.invFun`; it is a genuine two-sided
inverse as soon as the certificate is `< 1`, see `inverse_leftInverse`). -/
noncomputable def inverse (B : ResidualBlock X K) : X → X := Function.invFun B.toFun

theorem inverse_rightInverse [CompleteSpace X] (B : ResidualBlock X K) (hK : K < 1) :
    Function.RightInverse B.inverse B.toFun :=
  Function.rightInverse_invFun (B.surjective hK)

theorem inverse_leftInverse (B : ResidualBlock X K) (hK : K < 1) :
    Function.LeftInverse B.inverse B.toFun :=
  Function.leftInverse_invFun (B.injective hK)

/-- **Inverse gain bound.**  The inverse of a residual block with certificate `K < 1`
is `(1 - K)⁻¹`-Lipschitz. -/
theorem inverse_lipschitz [CompleteSpace X] (B : ResidualBlock X K) (hK : K < 1) :
    LipschitzWith (1 - K)⁻¹ B.inverse := by
  refine LipschitzWith.of_dist_le_mul fun a b => ?_
  have h := (B.antilipschitz hK).le_mul_dist (B.inverse a) (B.inverse b)
  rwa [B.inverse_rightInverse hK a, B.inverse_rightInverse hK b] at h

end ResidualBlock

/-! ### The max rule for inverse certificates -/

/-- Arithmetic core: `(1 - max a b)⁻¹ = max (1 - a)⁻¹ (1 - b)⁻¹` for `a, b < 1`. -/
theorem inv_one_sub_max (a b : ℝ≥0) (ha : a < 1) (hb : b < 1) :
    (1 - max a b)⁻¹ = max (1 - a)⁻¹ (1 - b)⁻¹ := by
  rcases le_total a b with h | h
  · rw [max_eq_right h, max_eq_right]
    exact inv_anti₀ (tsub_pos_of_lt hb) (tsub_le_tsub_left h 1)
  · rw [max_eq_left h, max_eq_left]
    exact inv_anti₀ (tsub_pos_of_lt ha) (tsub_le_tsub_left h 1)

variable {X Y : Type*} [NormedAddCommGroup X] [NormedAddCommGroup Y]
variable {K₁ K₂ : ℝ≥0}

/-- **Dual max rule.**  If two residual blocks have certificates `K₁, K₂ < 1`, their
parallel product is invertible and its inverse is Lipschitz with constant
`max ((1 - K₁)⁻¹) ((1 - K₂)⁻¹)`: the inverse certificates obey exactly the same
tensor-product (max) rule as the forward ones. -/
theorem parallel_inverse_lipschitz_bound [CompleteSpace X] [CompleteSpace Y]
    (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂) (h₁ : K₁ < 1) (h₂ : K₂ < 1) :
    LipschitzWith (max (1 - K₁)⁻¹ (1 - K₂)⁻¹) (B₁.par B₂).inverse := by
  have hK : ResidualCert.par K₁ K₂ < 1 := max_lt h₁ h₂
  have h := (B₁.par B₂).inverse_lipschitz hK
  rwa [show (1 - ResidualCert.par K₁ K₂)⁻¹ = max (1 - K₁)⁻¹ (1 - K₂)⁻¹ from
    inv_one_sub_max K₁ K₂ h₁ h₂] at h

/-- The parallel product of two invertible residual blocks is a bijection of `X × Y`. -/
theorem parallel_bijective [CompleteSpace X] [CompleteSpace Y]
    (B₁ : ResidualBlock X K₁) (B₂ : ResidualBlock Y K₂) (h₁ : K₁ < 1) (h₂ : K₂ < 1) :
    Function.Bijective (Prod.map B₁.toFun B₂.toFun) := by
  have := (B₁.par B₂).bijective (max_lt h₁ h₂)
  rwa [ResidualBlock.par_toFun] at this

/-- The inward dilation block on `ℝ`: residual `x ↦ -K * x`, certificate exactly `K`,
computing the contraction `x ↦ (1 - K) x`. -/
def coDilationBlock (K : ℝ≥0) : ResidualBlock ℝ K where
  residual := fun x => -(K : ℝ) * x
  residual_lipschitz := by
    refine LipschitzWith.of_dist_le_mul fun x y => ?_
    rw [Real.dist_eq, Real.dist_eq,
      show -(K : ℝ) * x - -(K : ℝ) * y = -((K : ℝ) * (x - y)) by ring,
      abs_neg, abs_mul, abs_of_nonneg K.coe_nonneg]

@[simp] theorem coDilationBlock_toFun (K : ℝ≥0) :
    (coDilationBlock K).toFun = fun x : ℝ => ((1 : ℝ) - (K : ℝ)) * x := by
  funext x
  simp only [ResidualBlock.toFun, coDilationBlock]
  ring

theorem coe_inv_one_sub (K : ℝ≥0) (hK : K ≤ 1) :
    (((1 - K : ℝ≥0))⁻¹ : ℝ) = ((1 : ℝ) - (K : ℝ))⁻¹ := by
  rw [NNReal.coe_sub hK, NNReal.coe_one]

/-- The inverse of an inward dilation block is the outward dilation by `(1 - K)⁻¹`. -/
theorem coDilation_inverse_eq (K : ℝ≥0) (hK : K < 1) :
    (coDilationBlock K).inverse = fun y : ℝ => (((1 - K : ℝ≥0))⁻¹ : ℝ) * y := by
  have hpos : (0 : ℝ) < 1 - (K : ℝ) := by
    have : (K : ℝ) < 1 := by exact_mod_cast hK
    linarith
  funext y
  refine (coDilationBlock K).injective hK ?_
  rw [(coDilationBlock K).inverse_rightInverse hK y, coDilationBlock_toFun,
    coe_inv_one_sub K hK.le]
  show y = ((1 : ℝ) - (K : ℝ)) * (((1 : ℝ) - (K : ℝ))⁻¹ * y)
  field_simp

/-- **Sharpness of the dual max rule.**  For any `a b : ℝ≥0`, the parallel pair of
dilations by `a` and `b` has least Lipschitz constant `max a b`; applied to
`a = (1 - K₁)⁻¹`, `b = (1 - K₂)⁻¹` this shows the inverse bound of
`parallel_inverse_lipschitz_bound` is attained by the inward dilation blocks. -/
theorem parallel_inverse_isLeast (K₁ K₂ : ℝ≥0) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map (fun x : ℝ => ((1 - K₁ : ℝ≥0)⁻¹ : ℝ) * x)
          (fun y : ℝ => ((1 - K₂ : ℝ≥0)⁻¹ : ℝ) * y))}
      (max (1 - K₁)⁻¹ (1 - K₂)⁻¹) :=
  isLeast_lipschitz_prod_dilation _ _

/-- Assembled statement: for `K₁, K₂ < 1` the parallel product of the inward dilation
blocks is invertible, and its inverse has *least* Lipschitz constant exactly
`max ((1 - K₁)⁻¹) ((1 - K₂)⁻¹)`. -/
theorem parallel_inverse_sharp (K₁ K₂ : ℝ≥0) (h₁ : K₁ < 1) (h₂ : K₂ < 1) :
    IsLeast {L : ℝ≥0 | LipschitzWith L
        (Prod.map (coDilationBlock K₁).inverse (coDilationBlock K₂).inverse)}
      (max (1 - K₁)⁻¹ (1 - K₂)⁻¹) := by
  rw [coDilation_inverse_eq K₁ h₁, coDilation_inverse_eq K₂ h₂]
  exact parallel_inverse_isLeast K₁ K₂

end ParallelResidualBlocks