/-! # CatalogBuild.Pythagorean.Berggren.PellClosedForm

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 88
-/

import Mathlib

/-- [Section: # CatalogBuild.Pythagorean.Berggren.PellClosedForm
Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 88] -/
theorem M1_00_sq : M 0 0 = 1^2 := by native_decide


theorem M2_00_sq : (M ^ 2) 0 0 = 3^2 := by native_decide


theorem M3_00_sq : (M ^ 3) 0 0 = 7^2 := by native_decide


theorem M4_00_sq : (M ^ 4) 0 0 = 17^2 := by native_decide


theorem M5_00_sq : (M ^ 5) 0 0 = 41^2 := by native_decide


theorem M6_00_sq : (M ^ 6) 0 0 = 99^2 := by native_decide


theorem M7_00_sq : (M ^ 7) 0 0 = 239^2 := by native_decide


theorem M8_00_sq : (M ^ 8) 0 0 = 577^2 := by native_decide

-- Companion Pell recurrence: H_{n+1} = 2H_n + H_{n-1}


theorem comp_pell_rec_1 : (3 : ℤ) = 2 * 1 + 1 := by norm_num


theorem comp_pell_rec_2 : (7 : ℤ) = 2 * 3 + 1 := by norm_num


theorem comp_pell_rec_3 : (17 : ℤ) = 2 * 7 + 3 := by norm_num


theorem comp_pell_rec_4 : (41 : ℤ) = 2 * 17 + 7 := by norm_num


theorem comp_pell_rec_5 : (99 : ℤ) = 2 * 41 + 17 := by norm_num


theorem comp_pell_rec_6 : (239 : ℤ) = 2 * 99 + 41 := by norm_num


theorem comp_pell_rec_7 : (577 : ℤ) = 2 * 239 + 99 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 2: NSW Numbers (M[2,2] entries)
-- ═══════════════════════════════════════════════════════════════

-- NSW numbers: 3, 17, 99, 577, 3363, 19601, 114243, 665857
-- Recurrence: N_{k+1} = 6N_k − N_{k-1}


theorem M1_22 : M 2 2 = 3 := by native_decide


theorem M2_22 : (M ^ 2) 2 2 = 17 := by native_decide


theorem M3_22 : (M ^ 3) 2 2 = 99 := by native_decide


theorem M4_22 : (M ^ 4) 2 2 = 577 := by native_decide


theorem M5_22 : (M ^ 5) 2 2 = 3363 := by native_decide


theorem M6_22 : (M ^ 6) 2 2 = 19601 := by native_decide


theorem M7_22 : (M ^ 7) 2 2 = 114243 := by native_decide


theorem M8_22 : (M ^ 8) 2 2 = 665857 := by native_decide

-- NSW recurrence N_{k+1} = 6N_k − N_{k-1}
-- with N_0 = 1 (the identity): 6*1 - ... Actually using indices from the matrix:


theorem nsw_rec_3 : (99 : ℤ) = 6 * 17 - 3 := by norm_num


theorem nsw_rec_4 : (577 : ℤ) = 6 * 99 - 17 := by norm_num


theorem nsw_rec_5 : (3363 : ℤ) = 6 * 577 - 99 := by norm_num


theorem nsw_rec_6 : (19601 : ℤ) = 6 * 3363 - 577 := by norm_num


theorem nsw_rec_7 : (114243 : ℤ) = 6 * 19601 - 3363 := by norm_num


theorem nsw_rec_8 : (665857 : ℤ) = 6 * 114243 - 19601 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 3: M[0,2] Entries
-- ═══════════════════════════════════════════════════════════════

-- |M^n[0,2]| = 2, 12, 70, 408, 2378, 13860, 80782, 470832


theorem M1_02 : M 0 2 = -2 := by native_decide


theorem M2_02 : (M ^ 2) 0 2 = -12 := by native_decide


theorem M3_02 : (M ^ 3) 0 2 = -70 := by native_decide


theorem M4_02 : (M ^ 4) 0 2 = -408 := by native_decide


theorem M5_02 : (M ^ 5) 0 2 = -2378 := by native_decide


theorem M6_02 : (M ^ 6) 0 2 = -13860 := by native_decide


theorem M7_02 : (M ^ 7) 0 2 = -80782 := by native_decide


theorem M8_02 : (M ^ 8) 0 2 = -470832 := by native_decide

-- The |M^n[0,2]| values satisfy a 6-recurrence:
-- |M^{n+1}[0,2]| = 6|M^n[0,2]| - |M^{n-1}[0,2]|


theorem m02_rec_3 : (70 : ℤ) = 6 * 12 - 2 := by norm_num


theorem m02_rec_4 : (408 : ℤ) = 6 * 70 - 12 := by norm_num


theorem m02_rec_5 : (2378 : ℤ) = 6 * 408 - 70 := by norm_num


theorem m02_rec_6 : (13860 : ℤ) = 6 * 2378 - 408 := by norm_num


theorem m02_rec_7 : (80782 : ℤ) = 6 * 13860 - 2378 := by norm_num


theorem m02_rec_8 : (470832 : ℤ) = 6 * 80782 - 13860 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Structural Symmetry of M^n
-- ═══════════════════════════════════════════════════════════════

-- M^n[0,0] = M^n[1,1]


theorem sym_00_11_1 : M 0 0 = M 1 1 := by native_decide


theorem sym_00_11_2 : (M ^ 2) 0 0 = (M ^ 2) 1 1 := by native_decide


theorem sym_00_11_3 : (M ^ 3) 0 0 = (M ^ 3) 1 1 := by native_decide


theorem sym_00_11_4 : (M ^ 4) 0 0 = (M ^ 4) 1 1 := by native_decide


theorem sym_00_11_5 : (M ^ 5) 0 0 = (M ^ 5) 1 1 := by native_decide


theorem sym_00_11_6 : (M ^ 6) 0 0 = (M ^ 6) 1 1 := by native_decide


theorem sym_00_11_7 : (M ^ 7) 0 0 = (M ^ 7) 1 1 := by native_decide


theorem sym_00_11_8 : (M ^ 8) 0 0 = (M ^ 8) 1 1 := by native_decide

-- M^n[0,2] = M^n[1,2]


theorem sym_02_12_1 : M 0 2 = M 1 2 := by native_decide


theorem sym_02_12_2 : (M ^ 2) 0 2 = (M ^ 2) 1 2 := by native_decide


theorem sym_02_12_3 : (M ^ 3) 0 2 = (M ^ 3) 1 2 := by native_decide


theorem sym_02_12_4 : (M ^ 4) 0 2 = (M ^ 4) 1 2 := by native_decide

-- M^n[2,0] = M^n[2,1]


theorem sym_20_21_1 : M 2 0 = M 2 1 := by native_decide


theorem sym_20_21_2 : (M ^ 2) 2 0 = (M ^ 2) 2 1 := by native_decide


theorem sym_20_21_3 : (M ^ 3) 2 0 = (M ^ 3) 2 1 := by native_decide


theorem sym_20_21_4 : (M ^ 4) 2 0 = (M ^ 4) 2 1 := by native_decide

-- Off-diagonal alternation: M^n[0,1] − M^n[0,0] = (−1)^(n+1)
-- n=1: 2-1=1, n=2: 8-9=-1, n=3: 50-49=1, n=4: 288-289=-1, ...


theorem offdiag_alt_1 : (M ^ 1) 0 1 - (M ^ 1) 0 0 = 1 := by native_decide


theorem offdiag_alt_2 : (M ^ 2) 0 1 - (M ^ 2) 0 0 = -1 := by native_decide


theorem offdiag_alt_3 : (M ^ 3) 0 1 - (M ^ 3) 0 0 = 1 := by native_decide


theorem offdiag_alt_4 : (M ^ 4) 0 1 - (M ^ 4) 0 0 = -1 := by native_decide


theorem offdiag_alt_5 : (M ^ 5) 0 1 - (M ^ 5) 0 0 = 1 := by native_decide


theorem offdiag_alt_6 : (M ^ 6) 0 1 - (M ^ 6) 0 0 = -1 := by native_decide


theorem offdiag_alt_7 : (M ^ 7) 0 1 - (M ^ 7) 0 0 = 1 := by native_decide


theorem offdiag_alt_8 : (M ^ 8) 0 1 - (M ^ 8) 0 0 = -1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 5: M is symmetric
-- ═══════════════════════════════════════════════════════════════


theorem M_sym : M = M.transpose := by native_decide


theorem M2_sym_full : M ^ 2 = (M ^ 2).transpose := by native_decide


theorem M3_sym_full : M ^ 3 = (M ^ 3).transpose := by native_decide


theorem M4_sym_full : M ^ 4 = (M ^ 4).transpose := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Pell Equation from Lorentz Constraint
-- ═══════════════════════════════════════════════════════════════

-- d² − 2c² = 1 where d = M^n[2,2], c = |M^n[0,2]|


theorem pell_eq_4 : (577 : ℤ)^2 - 2 * 408^2 = 1 := by norm_num


theorem pell_eq_5 : (3363 : ℤ)^2 - 2 * 2378^2 = 1 := by norm_num


theorem pell_eq_6 : (19601 : ℤ)^2 - 2 * 13860^2 = 1 := by norm_num


theorem pell_eq_7 : (114243 : ℤ)^2 - 2 * 80782^2 = 1 := by norm_num


theorem pell_eq_8 : (665857 : ℤ)^2 - 2 * 470832^2 = 1 := by norm_num

-- Column 0 Lorentz constraint: a² + b² − c² = 1 where a,b,c are column 0 entries


theorem lorentz_col0_1 :
    (M 0 0)^2 + (M 1 0)^2 - (M 2 0)^2 = 1 := by native_decide


theorem lorentz_col0_2 :
    ((M^2) 0 0)^2 + ((M^2) 1 0)^2 - ((M^2) 2 0)^2 = 1 := by native_decide


theorem lorentz_col0_3 :
    ((M^3) 0 0)^2 + ((M^3) 1 0)^2 - ((M^3) 2 0)^2 = 1 := by native_decide


theorem lorentz_col0_4 :
    ((M^4) 0 0)^2 + ((M^4) 1 0)^2 - ((M^4) 2 0)^2 = 1 := by native_decide

-- Column 2 Lorentz constraint: a² + b² − c² = −1


theorem lorentz_col2_1 :
    (M 0 2)^2 + (M 1 2)^2 - (M 2 2)^2 = -1 := by native_decide


theorem lorentz_col2_2 :
    ((M^2) 0 2)^2 + ((M^2) 1 2)^2 - ((M^2) 2 2)^2 = -1 := by native_decide


theorem lorentz_col2_3 :
    ((M^3) 0 2)^2 + ((M^3) 1 2)^2 - ((M^3) 2 2)^2 = -1 := by native_decide


theorem lorentz_col2_4 :
    ((M^4) 0 2)^2 + ((M^4) 1 2)^2 - ((M^4) 2 2)^2 = -1 := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Growth Rate Oscillation
-- ═══════════════════════════════════════════════════════════════

-- The ratios converge from alternating sides: checks that
-- M^{n+1}[0,0] · M^{n-1}[0,0] oscillates around M^n[0,0]²


theorem growth_oscillation_check :
    (M ^ 3) 0 0 * M 0 0 < (M ^ 2) 0 0 * (M ^ 2) 0 0 ∧
    (M ^ 4) 0 0 * (M ^ 2) 0 0 > (M ^ 3) 0 0 * (M ^ 3) 0 0 ∧
    (M ^ 5) 0 0 * (M ^ 3) 0 0 < (M ^ 4) 0 0 * (M ^ 4) 0 0 ∧
    (M ^ 6) 0 0 * (M ^ 4) 0 0 > (M ^ 5) 0 0 * (M ^ 5) 0 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 8: Cayley-Hamilton Coefficients
-- ═══════════════════════════════════════════════════════════════

-- M^n = α_n · I + β_n · M + γ_n · M²


theorem CH_coeff_3 : M ^ 3 = (-1) • (1 : Matrix (Fin 3) (Fin 3) ℤ) + 5 • M + 5 • M ^ 2 := by
  native_decide


theorem CH_coeff_4 : M ^ 4 = (-5) • (1 : Matrix (Fin 3) (Fin 3) ℤ) + 24 • M + 30 • M ^ 2 := by
  native_decide


theorem CH_coeff_5 :
    M ^ 5 = (-30) • (1 : Matrix (Fin 3) (Fin 3) ℤ) + 145 • M + 174 • M ^ 2 := by
  native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 9: Axiom Verification
-- ═══════════════════════════════════════════════════════════════

#print axioms M8_00_sq
#print axioms M8_22
#print axioms M8_02
#print axioms offdiag_alt_8
#print axioms pell_eq_8
#print axioms growth_oscillation_check
#print axioms CH_coeff_5
#print axioms lorentz_col2_4


