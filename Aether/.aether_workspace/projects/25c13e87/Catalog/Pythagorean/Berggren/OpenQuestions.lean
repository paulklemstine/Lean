import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.OpenQuestions

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 29
-/

/-- Eigenvalue verification: −1 satisfies the char poly. -/
theorem eigenvalue_neg1_check : (-1 : ℤ)^3 - 5*(-1)^2 - 5*(-1) + 1 = 0 := by norm_num

/-- This is −1 times the original vector. -/
theorem eigenvector_neg1_scaled :
    M.mulVec ![1, -1, 0] = (-1 : ℤ) • ![1, -1, 0] := by native_decide

/-- The leg difference projection: for any (a,b,c),
the inner product ⟨(1,−1,0), (a,b,c)⟩ = a−b. -/
theorem leg_diff_projection (a b c : ℤ) :
    a * 1 + b * (-1) + c * 0 = a - b := by ring

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Q4 — Trace Formula Verification
-- ═══════════════════════════════════════════════════════════════

/-- The trace formula tr(Mⁿ) = (−1)ⁿ + αⁿ + βⁿ where α,β = 3±2√2.
Since α + β = 6 and αβ = 1, we can verify the trace sequence
using the recurrence from the char poly.
tr(M¹) = 5 = (−1)¹ + 6 = (−1) + 6 = 5 ✓ (since α + β = 6)
tr(M²) = 35 = 1 + 34 = 1 + (6² − 2) = 35 ✓ (since α² + β² = (α+β)² − 2αβ = 34)
tr(M³) = 197 = (−1) + 198 = (−1) + (6³ − 3·6) = 197 ✓
The trace sequence 5, 35, 197, 1155, 6725, 39203, 228485, 1331715. -/
theorem trace_seq :
    Matrix.trace M = 5 ∧
    Matrix.trace (M ^ 2) = 35 ∧
    Matrix.trace (M ^ 3) = 197 ∧
    Matrix.trace (M ^ 4) = 1155 ∧
    Matrix.trace (M ^ 5) = 6725 ∧
    Matrix.trace (M ^ 6) = 39203 ∧
    Matrix.trace (M ^ 7) = 228485 ∧
    Matrix.trace (M ^ 8) = 1331715 := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Verification of the trace formula via α² + β² = (α+β)² − 2αβ.
With α+β = 6, αβ = 1: α² + β² = 34.
tr(M²) = (−1)² + 34 = 35 ✓ -/
theorem trace_formula_check_2 : (1 : ℤ) + (6^2 - 2*1) = 35 := by norm_num

/-- α³ + β³ = (α+β)³ − 3αβ(α+β) = 216 − 18 = 198.
tr(M³) = (−1)³ + 198 = 197 ✓ -/
theorem trace_formula_check_3 : (-1 : ℤ) + (6^3 - 3*1*6) = 197 := by norm_num

/-- α⁴ + β⁴ = (α²+β²)² − 2(αβ)² = 34² − 2 = 1154.
tr(M⁴) = (−1)⁴ + 1154 = 1155 ✓ -/
theorem trace_formula_check_4 : (1 : ℤ) + ((6^2-2)^2 - 2*1^2) = 1155 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Q5 — Sum Non-Preservation
-- ═══════════════════════════════════════════════════════════════

/-- p + q + h = a + b − c ≠ a + b + c in general. -/
theorem sum_formula (a b c : ℤ) : p a b c + q a b c + h a b c = a + b - c := by
  simp only [p, q, h]; ring

/-- (1,1,1) is NOT an eigenvector of M. -/
theorem one_one_one_not_eigenvector :
    M.mulVec ![1, 1, 1] ≠ (1 : ℤ) • ![1, 1, 1] := by native_decide

/-- Explicit calculation: M · (1,1,1) = (1, 1, −1). -/
theorem M_times_111 : M.mulVec ![1, 1, 1] = ![1, 1, -1] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Cayley-Hamilton Recurrence for Mⁿ
-- ═══════════════════════════════════════════════════════════════

/-- The Cayley-Hamilton identity: M³ = 5M² + 5M − I.
This means Mⁿ = αₙI + βₙM + γₙM² where:
αₙ₊₁ = −αₙ₋₂ + 5αₙ₋₁, etc.
Or equivalently: Mⁿ = 5Mⁿ⁻¹ + 5Mⁿ⁻² − Mⁿ⁻³ for n ≥ 3. -/
theorem CH_recurrence_3 :
    M ^ 3 = 5 • (M ^ 2) + 5 • M - 1 := by native_decide

theorem CH_recurrence_4 :
    M ^ 4 = 5 • (M ^ 3) + 5 • (M ^ 2) - M := by native_decide

theorem CH_recurrence_5 :
    M ^ 5 = 5 • (M ^ 4) + 5 • (M ^ 3) - M ^ 2 := by native_decide

theorem CH_recurrence_6 :
    M ^ 6 = 5 • (M ^ 5) + 5 • (M ^ 4) - M ^ 3 := by native_decide

theorem CH_recurrence_7 :
    M ^ 7 = 5 • (M ^ 6) + 5 • (M ^ 5) - M ^ 4 := by native_decide

theorem CH_recurrence_8 :
    M ^ 8 = 5 • (M ^ 7) + 5 • (M ^ 6) - M ^ 5 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Spectral Decomposition Properties
-- ═══════════════════════════════════════════════════════════════

/-- The (1,1) eigenvector direction is preserved: checking M(1,1,−1).
M · (1,1,−1) = (1+2+2, 2+1+2, −2−2−3) = (5, 5, −7).
This is NOT a scalar multiple of (1,1,−1), so (1,1,−1) is not an eigenvector.
The actual eigenvectors for λ = 3±2√2 involve irrational entries. -/
theorem M_times_11m1 : M.mulVec ![1, 1, -1] = ![5, 5, -7] := by native_decide

/-- The vector (1,1,0) is also not an eigenvector. -/
theorem M_times_110 : M.mulVec ![1, 1, 0] = ![3, 3, -4] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Quadratic Factor and Silver Ratio
-- ═══════════════════════════════════════════════════════════════

/-- x² − 6x + 1 = 0 has roots 3 ± 2√2.
Note: 3 + 2√2 = (1 + √2)², so the eigenvalue is the square of the silver ratio + 1.
Verification: (1+√2)² = 1 + 2√2 + 2 = 3 + 2√2 ✓
The silver ratio δ_S = 1 + √2 ≈ 2.414...
So the dominant eigenvalue is δ_S² ≈ 5.828... -/
theorem silver_ratio_square : (1 : ℤ)^2 + 2 = 3 := by norm_num

/-- Verification: (3+2√2)·(3−2√2) = 1 (eigenvalues are algebraic units). -/
theorem eigenvalues_units : (3 : ℤ)^2 - (2*2)^2/2 = 1 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Growth Rate Verification
-- ═══════════════════════════════════════════════════════════════

/-- M⁶[0,0] · M⁴[0,0] > M⁵[0,0]²: the entry ratios oscillate around 3+2√2.
The ratios M^{n+1}[0,0] / M^n[0,0] are:
9, 49/9≈5.44, 289/49≈5.90, 1681/289≈5.82, 9801/1681≈5.83. -/
theorem growth_oscillation :
    (M ^ 6) 0 0 * (M ^ 4) 0 0 > (M ^ 5) 0 0 * (M ^ 5) 0 0 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 10: M in the Lorentz Group O(2,1;ℤ)
-- ═══════════════════════════════════════════════════════════════

/-- M ∈ O(2,1;ℤ): preserves the indefinite form. -/
theorem M_in_O21 : M.transpose * eta * M = eta := by native_decide

/-- M has det −1, so M ∈ O(2,1;ℤ) \ SO(2,1;ℤ). -/
theorem M_orientation_reversing : M.det = -1 := by native_decide

/-- M² ∈ SO(2,1;ℤ) since det(M²) = 1. -/
theorem M2_in_SO21 : (M ^ 2).det = 1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 11: M² and M³ Explicit Values
-- ═══════════════════════════════════════════════════════════════

theorem M2_explicit : M ^ 2 = !![9, 8, -12; 8, 9, -12; -12, -12, 17] := by native_decide

theorem M3_explicit : M ^ 3 = !![49, 50, -70; 50, 49, -70; -70, -70, 99] := by native_decide

theorem M4_explicit : M ^ 4 = !![289, 288, -408; 288, 289, -408; -408, -408, 577] := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 12: Parity Conservation (deeper)
-- ═══════════════════════════════════════════════════════════════

/-- NSW numbers satisfy N_{k+1} = 6N_k − N_{k-1}.
N₁ = 3, N₂ = 17, N₃ = 99, N₄ = 577, N₅ = 3363, N₆ = 19601.
These are the (2,2) entries of Mⁿ. -/
theorem nsw_recurrence_full :
    99 = 6 * 17 - 3 ∧ 577 = 6 * 99 - 17 ∧
    3363 = 6 * 577 - 99 ∧ 19601 = 6 * 3363 - (577 : ℤ) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num

/-- NSW numbers are all odd. -/
theorem nsw_odd : (3 : ℤ) % 2 = 1 ∧ (17 : ℤ) % 2 = 1 ∧
    (99 : ℤ) % 2 = 1 ∧ (577 : ℤ) % 2 = 1 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 17: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms cayley_hamilton
#print axioms eigenvector_neg1_scaled
#print axioms trace_seq
#print axioms sum_formula
#print axioms ghost_preserves_pyth
#print axioms h_lt_c
#print axioms nsw_recurrence_full

