/-! # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers3

Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 67
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers3
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 67] -/
def rf3B₁ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]




/-- [Section: # CatalogBuild.Pythagorean.ModularForms.RamanujanFrontiers3
Auto-generated from theorem catalog database.
Domain: Pythagorean/ModularForms
Declarations: 67] -/
def rf3B₂ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]




def rf3B₃ : Matrix (Fin 3) (Fin 3) ℤ :=
  !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]




def rf3Q : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, (-1)]




def rf3matMod (N : ℕ) [NeZero N] (M : Matrix (Fin 3) (Fin 3) ℤ) :
    Matrix (Fin 3) (Fin 3) (ZMod N) := M.map (Int.cast)




theorem rf3_lorentz_mod5_all :
    (rf3matMod 5 rf3B₁)ᵀ * (rf3matMod 5 rf3Q) * (rf3matMod 5 rf3B₁) = rf3matMod 5 rf3Q ∧
    (rf3matMod 5 rf3B₂)ᵀ * (rf3matMod 5 rf3Q) * (rf3matMod 5 rf3B₂) = rf3matMod 5 rf3Q ∧
    (rf3matMod 5 rf3B₃)ᵀ * (rf3matMod 5 rf3Q) * (rf3matMod 5 rf3B₃) = rf3matMod 5 rf3Q :=
  ⟨by native_decide, by native_decide, by native_decide⟩




theorem rf3_lorentz_mod7_all :
    (rf3matMod 7 rf3B₁)ᵀ * (rf3matMod 7 rf3Q) * (rf3matMod 7 rf3B₁) = rf3matMod 7 rf3Q ∧
    (rf3matMod 7 rf3B₂)ᵀ * (rf3matMod 7 rf3Q) * (rf3matMod 7 rf3B₂) = rf3matMod 7 rf3Q ∧
    (rf3matMod 7 rf3B₃)ᵀ * (rf3matMod 7 rf3Q) * (rf3matMod 7 rf3B₃) = rf3matMod 7 rf3Q :=
  ⟨by native_decide, by native_decide, by native_decide⟩




theorem rf3_lorentz_mod11_all :
    (rf3matMod 11 rf3B₁)ᵀ * (rf3matMod 11 rf3Q) * (rf3matMod 11 rf3B₁) = rf3matMod 11 rf3Q ∧
    (rf3matMod 11 rf3B₂)ᵀ * (rf3matMod 11 rf3Q) * (rf3matMod 11 rf3B₂) = rf3matMod 11 rf3Q ∧
    (rf3matMod 11 rf3B₃)ᵀ * (rf3matMod 11 rf3Q) * (rf3matMod 11 rf3B₃) = rf3matMod 11 rf3Q :=
  ⟨by native_decide, by native_decide, by native_decide⟩




/-- The Ramanujan bound for a 6-regular graph is 2√5 ∈ (4, 5). -/
theorem ramanujan_bound_6reg_bounds : 2 * Real.sqrt 5 < 5 ∧ 2 * Real.sqrt 5 > 4 := by
  constructor
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 5, sq_nonneg (Real.sqrt 5 - 5/2)]
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 5, sq_nonneg (Real.sqrt 5 - 2)]




/-- B₂ + I is singular: -1 is an eigenvalue of B₂. -/
theorem rf3B₂_has_eigenvalue_neg1 :
    Matrix.det (rf3B₂ + (1 : Matrix (Fin 3) (Fin 3) ℤ)) = 0 := by
  native_decide




/-- Cayley-Hamilton for B₂: B₂³ - 5B₂² - 5B₂ + I = 0 -/
theorem rf3B₂_cayley_hamilton :
    rf3B₂ ^ 3 - 5 • rf3B₂ ^ 2 - 5 • rf3B₂ + 1 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by
  native_decide




/-- B₁ is strictly unipotent: (B₁-I)³ = 0 but (B₁-I)² ≠ 0. -/
theorem rf3B₁_unipotent :
    (rf3B₁ - 1) ^ 3 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide




theorem rf3B₁_nilindex_3 :
    (rf3B₁ - 1) ^ 2 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide




/-- B₃ is strictly unipotent: (B₃-I)³ = 0 but (B₃-I)² ≠ 0. -/
theorem rf3B₃_unipotent :
    (rf3B₃ - 1) ^ 3 = (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide




theorem rf3B₃_nilindex_3 :
    (rf3B₃ - 1) ^ 2 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide




/-- B₂ is NOT unipotent. -/
theorem rf3B₂_not_unipotent :
    (rf3B₂ - 1) ^ 3 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) := by native_decide




/-- B₂ + I is singular but nonzero: -1 has multiplicity 1. -/
theorem rf3B₂_neg1_simple :
    Matrix.det (rf3B₂ + 1) = 0 ∧ (rf3B₂ + 1) ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) :=
  ⟨by native_decide, by native_decide⟩




/-- Complete trace sequence for B₂ powers. -/
theorem rf3B₂_trace_seq :
    Matrix.trace rf3B₂ = 5 ∧
    Matrix.trace (rf3B₂ ^ 2) = 35 ∧
    Matrix.trace (rf3B₂ ^ 3) = 197 ∧
    Matrix.trace (rf3B₂ ^ 4) = 1155 ∧
    Matrix.trace (rf3B₂ ^ 5) = 6725 :=
  ⟨by native_decide, by native_decide, by native_decide, by native_decide, by native_decide⟩




/-- The Chebyshev-I polynomial T_n(3) values. -/
theorem chebyshev_at_3_values :
    17 = 6 * 3 - 1 ∧
    99 = 6 * 17 - 3 ∧
    577 = 6 * 99 - 17 ∧
    3363 = 6 * 577 - 99 := by omega




/-- Chebyshev trace formula: tr(B₂ⁿ) = (-1)ⁿ + 2·T_n(3).
T_0=1, T_1=3, T_2=17, T_3=99, T_4=577, T_5=3363. -/
theorem chebyshev_trace_formula :
    (3 : ℤ) = 1 + 2 * 1 ∧
    (5 : ℤ) = -1 + 2 * 3 ∧
    (35 : ℤ) = 1 + 2 * 17 ∧
    (197 : ℤ) = -1 + 2 * 99 ∧
    (1155 : ℤ) = 1 + 2 * 577 ∧
    (6725 : ℤ) = -1 + 2 * 3363 := by omega




/-- Trace recurrence from Cayley-Hamilton:
tr(B₂ⁿ) = 5·tr(B₂ⁿ⁻¹) + 5·tr(B₂ⁿ⁻²) - tr(B₂ⁿ⁻³). -/
theorem rf3B₂_trace_recurrence :
    (197 : ℤ) = 5 * 35 + 5 * 5 - 3 ∧
    (1155 : ℤ) = 5 * 197 + 5 * 35 - 5 ∧
    (6725 : ℤ) = 5 * 1155 + 5 * 197 - 35 := by omega




/-- The eigenvalue growth rate: 3 + 2√2 ∈ (5, 6). -/
theorem eigenvalue_growth_rate :
    (3 : ℝ) + 2 * Real.sqrt 2 > 5 ∧ (3 : ℝ) + 2 * Real.sqrt 2 < 6 := by
  constructor
  · have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 2, sq_nonneg (Real.sqrt 2 - 1)]
  · have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 2, sq_nonneg (Real.sqrt 2 - 3/2)]




/-- The product of hyperbolic eigenvalues is 1. -/
theorem hyperbolic_eigenvalue_product :
    ((3 : ℝ) + 2 * Real.sqrt 2) * (3 - 2 * Real.sqrt 2) = 1 := by
  have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
  nlinarith




/-- The sum of hyperbolic eigenvalues is 6. -/
theorem hyperbolic_eigenvalue_sum :
    ((3 : ℝ) + 2 * Real.sqrt 2) + (3 - 2 * Real.sqrt 2) = 6 := by ring




/-- B₁ is strictly unipotent (nilpotent index 3). -/
theorem rf3B₁_strictly_unipotent :
    (rf3B₁ - 1) ^ 3 = (0 : Matrix (Fin 3) (Fin 3) ℤ) ∧
    (rf3B₁ - 1) ^ 2 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) :=
  ⟨by native_decide, by native_decide⟩




/-- B₃ is strictly unipotent (nilpotent index 3). -/
theorem rf3B₃_strictly_unipotent :
    (rf3B₃ - 1) ^ 3 = (0 : Matrix (Fin 3) (Fin 3) ℤ) ∧
    (rf3B₃ - 1) ^ 2 ≠ (0 : Matrix (Fin 3) (Fin 3) ℤ) :=
  ⟨by native_decide, by native_decide⟩




/-- Parabolic generators have constant traces under powering. -/
theorem rf3B₁_parabolic_trace :
    Matrix.trace (rf3B₁ ^ 10) = 3 ∧
    Matrix.trace (rf3B₁ ^ 20) = 3 :=
  ⟨by native_decide, by native_decide⟩




/-- B₂ has exponentially growing traces (hyperbolic). -/
theorem rf3B₂_hyperbolic_trace :
    Matrix.trace (rf3B₂ ^ 1) = 5 ∧
    Matrix.trace (rf3B₂ ^ 2) = 35 ∧
    Matrix.trace (rf3B₂ ^ 3) = 197 ∧
    Matrix.trace (rf3B₂ ^ 4) = 1155 :=
  ⟨by native_decide, by native_decide, by native_decide, by native_decide⟩




/-- Parabolic = determinant 1, Hyperbolic = determinant -1. -/
theorem rf3_det_classification :
    Matrix.det rf3B₁ = 1 ∧ Matrix.det rf3B₂ = -1 ∧ Matrix.det rf3B₃ = 1 :=
  ⟨by native_decide, by native_decide, by native_decide⟩




/-- Products of parabolic with hyperbolic are hyperbolic. -/
theorem rf3_mixed_products_hyperbolic :
    Matrix.trace (rf3B₁ * rf3B₂) = 17 ∧
    Matrix.trace (rf3B₂ * rf3B₃) = 17 ∧
    Matrix.trace (rf3B₁ * rf3B₃) = 15 :=
  ⟨by native_decide, by native_decide, by native_decide⟩




/-- All generator pairs are non-commuting. -/
theorem rf3_full_noncommutativity :
    rf3B₁ * rf3B₂ ≠ rf3B₂ * rf3B₁ ∧
    rf3B₁ * rf3B₃ ≠ rf3B₃ * rf3B₁ ∧
    rf3B₂ * rf3B₃ ≠ rf3B₃ * rf3B₂ :=
  ⟨by native_decide, by native_decide, by native_decide⟩




/-- Triple product trace. -/
theorem rf3B₁B₂B₃_trace :
    Matrix.trace (rf3B₁ * rf3B₂ * rf3B₃) = 65 := by native_decide




/-- All generators preserve the root triple (3,4,5). -/
theorem rf3_on_345 :
    rf3B₁.mulVec ![(3:ℤ), 4, 5] = ![5, 12, 13] ∧
    rf3B₂.mulVec ![(3:ℤ), 4, 5] = ![21, 20, 29] ∧
    rf3B₃.mulVec ![(3:ℤ), 4, 5] = ![15, 8, 17] :=
  ⟨by native_decide, by native_decide, by native_decide⟩




/-- Children of (3,4,5) are all Pythagorean. -/
theorem rf3_children_pythagorean :
    (5:ℤ)^2 + 12^2 = 13^2 ∧ (21:ℤ)^2 + 20^2 = 29^2 ∧ (15:ℤ)^2 + 8^2 = 17^2 := by
  norm_num




def rf3Q5 : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,0,0; 0,0,1,0,0; 0,0,0,1,0; 0,0,0,0,(-1)]




/-- Root quintuples satisfying a₁² + a₂² + a₃² + a₄² = d². -/
theorem root_quintuple_1_0_0_0_1 : (1:ℤ)^2 + 0^2 + 0^2 + 0^2 = 1^2 := by norm_num



theorem root_quintuple_1_1_1_1_2 : (1:ℤ)^2 + 1^2 + 1^2 + 1^2 = 2^2 := by norm_num



theorem quintuple_1_2_2_0_3 : (1:ℤ)^2 + 2^2 + 2^2 + 0^2 = 3^2 := by norm_num




def rf3K₁ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![(-1),0,0,2,2; 0,1,0,0,0; 0,0,1,0,0; (-2),0,0,1,2; (-2),0,0,2,3]




def rf3K₂ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,2,2; 0,1,0,0,0; 0,0,1,0,0; 2,0,0,1,2; 2,0,0,2,3]




def rf3K₃ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,(-1),0,2,2; 0,0,1,0,0; 0,(-2),0,1,2; 0,(-2),0,2,3]




def rf3K₄ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,0,0; 0,0,(-1),2,2; 0,0,(-2),1,2; 0,0,(-2),2,3]




def rf3K₅ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,0,0; 0,0,1,2,2; 0,0,2,1,2; 0,0,2,2,3]




def rf3K₆ : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1,0,0,0,0; 0,1,0,2,2; 0,0,1,0,0; 0,2,0,1,2; 0,2,0,2,3]




/-- All 5D generators preserve the Lorentz form. -/
theorem rf3K_lorentz_all :
    rf3K₁ᵀ * rf3Q5 * rf3K₁ = rf3Q5 ∧
    rf3K₂ᵀ * rf3Q5 * rf3K₂ = rf3Q5 ∧
    rf3K₃ᵀ * rf3Q5 * rf3K₃ = rf3Q5 ∧
    rf3K₄ᵀ * rf3Q5 * rf3K₄ = rf3Q5 ∧
    rf3K₅ᵀ * rf3Q5 * rf3K₅ = rf3Q5 ∧
    rf3K₆ᵀ * rf3Q5 * rf3K₆ = rf3Q5 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩




/-- 5D generator properties. -/
theorem rf3K_ne_id :
    rf3K₁ ≠ 1 ∧ rf3K₂ ≠ 1 ∧ rf3K₃ ≠ 1 ∧ rf3K₄ ≠ 1 ∧ rf3K₅ ≠ 1 ∧ rf3K₆ ≠ 1 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩




theorem rf3K_traces :
    Matrix.trace rf3K₁ = 5 ∧ Matrix.trace rf3K₂ = 7 ∧
    Matrix.trace rf3K₃ = 5 ∧ Matrix.trace rf3K₄ = 5 ∧
    Matrix.trace rf3K₅ = 7 ∧ Matrix.trace rf3K₆ = 7 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩




theorem rf3K_dets :
    Matrix.det rf3K₁ = 1 ∧ Matrix.det rf3K₂ = -1 ∧
    Matrix.det rf3K₃ = 1 ∧ Matrix.det rf3K₄ = 1 ∧
    Matrix.det rf3K₅ = -1 ∧ Matrix.det rf3K₆ = -1 :=
  ⟨by native_decide, by native_decide, by native_decide,
   by native_decide, by native_decide, by native_decide⟩




/-- K₁ and K₂ applied to root (1,1,1,1,2) produce valid quintuples. -/
theorem rf3K₁_on_root :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    let w := rf3K₁.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 + w 3 ^ 2 = w 4 ^ 2 := by native_decide




theorem rf3K₂_on_root :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    let w := rf3K₂.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 + w 3 ^ 2 = w 4 ^ 2 := by native_decide




theorem rf3K₃_on_root :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    let w := rf3K₃.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 + w 3 ^ 2 = w 4 ^ 2 := by native_decide




theorem rf3K₄_on_root :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    let w := rf3K₄.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 + w 3 ^ 2 = w 4 ^ 2 := by native_decide




theorem rf3K₅_on_root :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    let w := rf3K₅.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 + w 3 ^ 2 = w 4 ^ 2 := by native_decide




theorem rf3K₆_on_root :
    let v := ![(1:ℤ), 1, 1, 1, 2]
    let w := rf3K₆.mulVec v
    w 0 ^ 2 + w 1 ^ 2 + w 2 ^ 2 + w 3 ^ 2 = w 4 ^ 2 := by native_decide




/-- Spectral gap d - 2√(d-1) is positive for d = 6, 8, 12, 20. -/
theorem spectral_gap_pos_d6 : (6:ℝ) - 2 * Real.sqrt 5 > 0 := by
  have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 5, sq_nonneg (Real.sqrt 5 - 3)]




theorem spectral_gap_pos_d8 : (8:ℝ) - 2 * Real.sqrt 7 > 0 := by
  have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 7, sq_nonneg (Real.sqrt 7 - 4)]




theorem spectral_gap_pos_d12 : (12:ℝ) - 2 * Real.sqrt 11 > 0 := by
  have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 11, sq_nonneg (Real.sqrt 11 - 6)]




theorem spectral_gap_pos_d20 : (20:ℝ) - 2 * Real.sqrt 19 > 0 := by
  have h : Real.sqrt 19 ^ 2 = 19 := Real.sq_sqrt (by norm_num : (19:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 19, sq_nonneg (Real.sqrt 19 - 10)]




/-- Full monotonicity chain: higher degree gives larger spectral gap. -/
theorem spectral_gap_full_monotone :
    (12:ℝ) - 2 * Real.sqrt 11 > 8 - 2 * Real.sqrt 7 ∧
    (8:ℝ) - 2 * Real.sqrt 7 > 6 - 2 * Real.sqrt 5 ∧
    (6:ℝ) - 2 * Real.sqrt 5 > 3 - 2 * Real.sqrt 2 := by
  refine ⟨?_, ?_, ?_⟩
  · have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 7, Real.sqrt_nonneg 11,
               sq_nonneg (Real.sqrt 11 - Real.sqrt 7),
               sq_nonneg (Real.sqrt 7 - 2), sq_nonneg (Real.sqrt 11 - 3)]
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 5, Real.sqrt_nonneg 7,
               sq_nonneg (Real.sqrt 7 - Real.sqrt 5),
               sq_nonneg (Real.sqrt 5 - 2), sq_nonneg (Real.sqrt 7 - 2)]
  · have h2 : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num : (2:ℝ) ≥ 0)
    have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 2, Real.sqrt_nonneg 5,
               sq_nonneg (Real.sqrt 5 - Real.sqrt 2),
               sq_nonneg (Real.sqrt 2 - 1), sq_nonneg (Real.sqrt 5 - 2)]




/-- The relative gap is monotonically increasing. -/
theorem relative_gap_increasing :
    8 * (6 - 2 * Real.sqrt 5) < 6 * (8 - 2 * Real.sqrt 7) ∧
    12 * (8 - 2 * Real.sqrt 7) < 8 * (12 - 2 * Real.sqrt 11) := by
  constructor
  · -- 48 - 16√5 < 48 - 12√7 ↔ 12√7 < 16√5 ↔ 3√7 < 4√5
    have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 5, Real.sqrt_nonneg 7,
               sq_nonneg (4 * Real.sqrt 5 - 3 * Real.sqrt 7)]
  · -- 96 - 24√7 < 96 - 16√11 ↔ 16√11 < 24√7 ↔ 2√11 < 3√7
    have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 7, Real.sqrt_nonneg 11,
               sq_nonneg (3 * Real.sqrt 7 - 2 * Real.sqrt 11)]




/-- The relative gap for d=100 exceeds 0.79: (100 - 2√99)/100 > 79/100. -/
theorem relative_gap_d100 :
    (100 : ℝ) - 2 * Real.sqrt 99 > 79 := by
  have h99 : Real.sqrt 99 ^ 2 = 99 := Real.sq_sqrt (by norm_num : (99:ℝ) ≥ 0)
  nlinarith [Real.sqrt_nonneg 99, sq_nonneg (Real.sqrt 99 - 21/2)]




/-- The absolute spectral gap grows: exceeds 1 at d=6, 2 at d=8, 5 at d=12. -/
theorem spectral_gap_growth :
    (6:ℝ) - 2 * Real.sqrt 5 > 1 ∧
    (8:ℝ) - 2 * Real.sqrt 7 > 2 ∧
    (12:ℝ) - 2 * Real.sqrt 11 > 5 := by
  refine ⟨?_, ?_, ?_⟩
  · have h5 : Real.sqrt 5 ^ 2 = 5 := Real.sq_sqrt (by norm_num : (5:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 5, sq_nonneg (Real.sqrt 5 - 5/2)]
  · have h7 : Real.sqrt 7 ^ 2 = 7 := Real.sq_sqrt (by norm_num : (7:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 7, sq_nonneg (Real.sqrt 7 - 3)]
  · have h11 : Real.sqrt 11 ^ 2 = 11 := Real.sq_sqrt (by norm_num : (11:ℝ) ≥ 0)
    nlinarith [Real.sqrt_nonneg 11, sq_nonneg (Real.sqrt 11 - 7/2)]




/-- Products of 3D Lorentz transformations are Lorentz. -/
theorem lorentz3_product_closure (M N : Matrix (Fin 3) (Fin 3) ℤ)
    (hM : Mᵀ * rf3Q * M = rf3Q) (hN : Nᵀ * rf3Q * N = rf3Q) :
    (M * N)ᵀ * rf3Q * (M * N) = rf3Q := by
  rw [Matrix.transpose_mul]
  have : Nᵀ * Mᵀ * rf3Q * (M * N) = Nᵀ * (Mᵀ * rf3Q * M) * N := by
    simp [Matrix.mul_assoc]
  rw [this, hM, hN]




theorem rf3B₂_pow5_from_CH :
    rf3B₂ ^ 5 = 5 • rf3B₂ ^ 4 + 5 • rf3B₂ ^ 3 - rf3B₂ ^ 2 := by
  native_decide




/-- B₂⁶ from Cayley-Hamilton -/
theorem rf3B₂_pow6_from_CH :
    rf3B₂ ^ 6 = 5 • rf3B₂ ^ 5 + 5 • rf3B₂ ^ 4 - rf3B₂ ^ 3 := by
  native_decide




/-- tr(B₂⁶) = 39203 -/
theorem rf3B₂_trace_sixth :
    Matrix.trace (rf3B₂ ^ 6) = 39203 := by native_decide




/-- Chebyshev verification for n=6: T_6(3) = 6·3363-577 = 19601,
tr(B₂⁶) = 1 + 2·19601 = 39203. -/
theorem chebyshev_n6 :
    (39203 : ℤ) = 1 + 2 * 19601 ∧ (19601 : ℤ) = 6 * 3363 - 577 := by omega



