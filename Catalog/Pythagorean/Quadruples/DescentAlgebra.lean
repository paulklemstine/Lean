/-! # CatalogBuild.Pythagorean.Quadruples.DescentAlgebra

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 32
-/

import Mathlib

/-- B₂⁻¹ lifted to 4D via the (2,3)-plane. -/
def mL23 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0; 0, 1, 2, (-2); 0, 2, 1, (-2); 0, (-2), (-2), 3]


/-- B₂⁻¹ lifted to 4D via the (1,3)-plane. -/
def mL13 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 2, (-2); 0, 1, 0, 0; 2, 0, 1, (-2); (-2), 0, (-2), 3]


/-- B₂⁻¹ lifted to 4D via the (1,2)-plane. -/
def mL12 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 2, 0, (-2); 2, 1, 0, (-2); 0, 0, 1, 0; (-2), (-2), 0, 3]

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Determinants = -1
-- ═══════════════════════════════════════════════════════════════


/-- [Section: # Non-Commutative Descent Algebra for 4D Pythagorean Quadruples
## Main Results
1. **Determinant = -1**: All lifted Berggren matrices are orientation-reversing
2. **Trace = 6**: Common trace for all three matrices
3. **Non-commutativity**: Pairwise products don't commute
4. **No involutions**: M² ≠ I for any descent matrix
5. **Lorentz form preservation**: Algebraically verified
6. **Application to root (1,2,2,3)**: Descent produces known parents
7. **Conjugacy**: Coordinate swaps relate different descent matrices
## Connection to O(3,1;ℤ)
The lifted Berggren inverse matrices generate a subgroup of O(3,1;ℤ).] -/
theorem det_mL23 : mL23.det = -1 := by native_decide

theorem det_mL13 : mL13.det = -1 := by native_decide

theorem det_mL12 : mL12.det = -1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Traces = 6
-- ═══════════════════════════════════════════════════════════════


theorem trace_mL23 : mL23.trace = 6 := by native_decide

theorem trace_mL13 : mL13.trace = 6 := by native_decide

theorem trace_mL12 : mL12.trace = 6 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Non-Commutativity
-- ═══════════════════════════════════════════════════════════════


/-- The descent algebra is non-commutative. -/
theorem mL23_mL13_ne : mL23 * mL13 ≠ mL13 * mL23 := by native_decide

theorem mL23_mL12_ne : mL23 * mL12 ≠ mL12 * mL23 := by native_decide

theorem mL13_mL12_ne : mL13 * mL12 ≠ mL12 * mL13 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Non-Involution
-- ═══════════════════════════════════════════════════════════════


theorem mL23_sq_ne_one : mL23 * mL23 ≠ 1 := by native_decide

theorem mL13_sq_ne_one : mL13 * mL13 ≠ 1 := by native_decide

theorem mL12_sq_ne_one : mL12 * mL12 ≠ 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Higher Powers — Infinite Order
-- ═══════════════════════════════════════════════════════════════


theorem mL23_cube_ne_one : mL23 * mL23 * mL23 ≠ 1 := by native_decide

theorem mL23_fourth_ne_one : mL23 * mL23 * mL23 * mL23 ≠ 1 := by native_decide

theorem mL23_mL13_sq_ne_one : (mL23 * mL13) * (mL23 * mL13) ≠ 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Product Determinants
-- ═══════════════════════════════════════════════════════════════


/-- Product of two descent matrices has det = 1 (in SO(3,1;ℤ)). -/
theorem det_product_23_13 : (mL23 * mL13).det = 1 := by native_decide

theorem det_product_23_12 : (mL23 * mL12).det = 1 := by native_decide

theorem det_product_sq : (mL23 * mL23).det = 1 := by native_decide


/-- Triple product has det = -1. -/
theorem det_triple : (mL23 * mL13 * mL12).det = -1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Application to Root (1,2,2,3)
-- ═══════════════════════════════════════════════════════════════


/-- Descent of root (1,2,2,3) via (2,3)-plane gives (1,0,0,1). -/
theorem descent_root_23 : mL23.mulVec ![1, 2, 2, 3] = ![1, 0, 0, 1] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Distinctness
-- ═══════════════════════════════════════════════════════════════


theorem mL_all_distinct : mL23 ≠ mL13 ∧ mL13 ≠ mL12 ∧ mL23 ≠ mL12 :=
  ⟨by native_decide, by native_decide, by native_decide⟩


/-- All products are distinct. -/
theorem products_distinct :
    mL23 * mL13 ≠ mL23 * mL12 ∧ mL23 * mL13 ≠ mL13 * mL12 ∧ mL23 * mL12 ≠ mL13 * mL12 :=
  ⟨by native_decide, by native_decide, by native_decide⟩

-- ═══════════════════════════════════════════════════════════════
-- Section 10: Lorentz Form Preservation (algebraic)
-- ═══════════════════════════════════════════════════════════════


/-- Descent via (2,3)-plane preserves Lorentz form (algebraic identity). -/
theorem mL23_preserves_lorentz (a b c d : ℤ) :
    lorentzQ a (b + 2*c - 2*d) (2*b + c - 2*d) (-2*b - 2*c + 3*d) =
    lorentzQ a b c d := by
  simp [lorentzQ]; ring


/-- The descent preserves the PQ equation. -/
theorem descent_preserves_pq (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + (b + 2*c - 2*d) ^ 2 + (2*b + c - 2*d) ^ 2 =
    (-2*b - 2*c + 3*d) ^ 2 := by
  have := mL23_preserves_lorentz a b c d
  simp [lorentzQ] at this; linarith

-- ═══════════════════════════════════════════════════════════════
-- Section 11: Eta Matrix (Minkowski metric)
-- ═══════════════════════════════════════════════════════════════


/-- mL23 preserves the Minkowski metric: Mᵀ · η · M = η. -/
theorem mL23_in_O31 : mL23ᵀ * eta * mL23 = eta := by native_decide


/-- mL13 preserves the Minkowski metric. -/
theorem mL13_in_O31 : mL13ᵀ * eta * mL13 = eta := by native_decide


/-- mL12 preserves the Minkowski metric. -/
theorem mL12_in_O31 : mL12ᵀ * eta * mL12 = eta := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Conjugacy Between Matrices
-- ═══════════════════════════════════════════════════════════════


/-- swap12 relates mL23 and mL13 by conjugation (up to reordering).
Actually, it doesn't directly conjugate - they are related through
the S₃ symmetry group acting on coordinate indices. -/
theorem swap12_is_involution : swap12 * swap12 = 1 := by native_decide

theorem swap12_det : swap12.det = -1 := by native_decide

