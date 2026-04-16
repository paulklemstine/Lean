/-! # CatalogBuild.Pythagorean.Berggren.BerggrenQuadruples

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 23
-/

import Mathlib

/-- The Lorentz form for triples: Q(a,b,c) = a² + b² - c² -/
def Q_triple (v : Fin 3 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2



/-- The Lorentz form for quadruples: Q₄(a,b,c,d) = a² + b² + c² - d² -/
def Q_quad (v : Fin 4 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 - v 3 ^ 2



/-- The Lorentz metric matrix for triples -/
def Q₃_matrix : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]



/-- B₁ maps (3,4,5) to (5,12,13), a Pythagorean triple -/
theorem B₁_child : B₁ *ᵥ ![3, 4, 5] = ![5, 12, 13] := by native_decide



/-- B₂ maps (3,4,5) to (21,20,29), a Pythagorean triple -/
theorem B₂_child : B₂ *ᵥ ![3, 4, 5] = ![21, 20, 29] := by native_decide



/-- B₃ maps (3,4,5) to (15,8,17), a Pythagorean triple -/
theorem B₃_child : B₃ *ᵥ ![3, 4, 5] = ![15, 8, 17] := by native_decide



/-- (5, 12, 13) is a Pythagorean triple -/
theorem child1_is_pyth : IsPythTriple 5 12 13 := by
  unfold IsPythTriple; norm_num



/-- (21, 20, 29) is a Pythagorean triple -/
theorem child2_is_pyth : IsPythTriple 21 20 29 := by
  unfold IsPythTriple; norm_num



/-- (15, 8, 17) is a Pythagorean triple -/
theorem child3_is_pyth : IsPythTriple 15 8 17 := by
  unfold IsPythTriple; norm_num



/-- The quaternionic parametrization produces Q₄ = 0 -/
theorem quadParam_null (m n p q : ℤ) : Q_quad (quadParam m n p q) = 0 := by
  unfold Q_quad quadParam
  simp
  ring



/-- (0,1,1,1) parametrizes (1,2,2,3) (up to sign) -/
theorem param_example_1 :
    quadParam 0 1 1 1 0 = -1 ∧
    quadParam 0 1 1 1 1 = 2 ∧
    quadParam 0 1 1 1 2 = 2 ∧
    quadParam 0 1 1 1 3 = 3 := by
  unfold quadParam; simp



/-- (1,1,1,2) parametrizes a quadruple related to (2,3,6,7) -/
theorem param_example_2 :
    quadParam 1 1 1 2 3 = 7 := by
  unfold quadParam; simp



/-- The Lorentz metric matrix for quadruples: diag(1,1,1,-1) -/
def Q₄_matrix : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, -1]



/-- The Pythagorean equation is equivalent to the null cone condition -/
theorem pyth_quad_iff_null (a b c d : ℤ) :
    IsPythQuad a b c d ↔ Q_quad ![a, b, c, d] = 0 := by
  unfold IsPythQuad Q_quad
  constructor
  · intro h
    simp [Matrix.cons_val_zero, Matrix.cons_val_one]
    omega
  · intro h
    simp [Matrix.cons_val_zero, Matrix.cons_val_one] at h
    omega



/-- R₁₂ preserves the Lorentz form -/
theorem R₁₂_preserves : R₁₂ᵀ * Q₄_matrix * R₁₂ = Q₄_matrix := by native_decide



/-- R₁₃ preserves the Lorentz form -/
theorem R₁₃_preserves : R₁₃ᵀ * Q₄_matrix * R₁₃ = Q₄_matrix := by native_decide



/-- R₁₂ has finite order (order 4) — it squares to a reflection, fourth power is identity -/
theorem R₁₂_order_4 : R₁₂ ^ 4 = 1 := by native_decide



/-- R₁₃ has finite order (order 4) -/
theorem R₁₃_order_4 : R₁₃ ^ 4 = 1 := by native_decide



/-- The permutation matrix swapping coordinates 0 and 1 is in O(3,1;ℤ).
This shows O(3,1;ℤ) has more symmetry than O(2,1;ℤ). -/
def swap01 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![0, 1, 0, 0; 1, 0, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1]



/-- [Section: # CatalogBuild.Pythagorean.Berggren.BerggrenQuadruples
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 23] -/
theorem swap01_preserves : swap01ᵀ * Q₄_matrix * swap01 = Q₄_matrix := by native_decide



/-- The permutation matrix swapping coordinates 1 and 2 is in O(3,1;ℤ).
Together with swap01, this generates S₃ acting on the spatial coordinates.
O(2,1;ℤ) has no such spatial permutation symmetry (only 2 spatial coords). -/
def swap12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 0, 1, 0; 0, 1, 0, 0; 0, 0, 0, 1]



theorem swap12_preserves : swap12ᵀ * Q₄_matrix * swap12 = Q₄_matrix := by native_decide



/-- swap01 and swap12 commute with each other when composed in a specific way,
witnessing non-trivial abelian structure in O(3,1;ℤ). -/
theorem spatial_swaps_generate_S3 :
    swap01 * swap12 * swap01 = swap12 * swap01 * swap12 := by native_decide


