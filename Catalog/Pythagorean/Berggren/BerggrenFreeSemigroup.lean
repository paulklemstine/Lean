/-! # CatalogBuild.Pythagorean.Berggren.BerggrenFreeSemigroup

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 57
-/

import Mathlib

theorem BF1_ne_BF2 : BF1 ≠ BF2 := by native_decide

theorem BF1_ne_BF3 : BF1 ≠ BF3 := by native_decide

theorem BF2_ne_BF3 : BF2 ≠ BF3 := by native_decide

theorem BF1_ne_one : BF1 ≠ 1 := by native_decide

theorem BF2_ne_one : BF2 ≠ 1 := by native_decide

theorem BF3_ne_one : BF3 ≠ 1 := by native_decide


theorem BF12_ne_BF21 : BF1 * BF2 ≠ BF2 * BF1 := by native_decide

theorem BF13_ne_BF31 : BF1 * BF3 ≠ BF3 * BF1 := by native_decide

theorem BF23_ne_BF32 : BF2 * BF3 ≠ BF3 * BF2 := by native_decide


theorem BF11_ne_one : BF1 * BF1 ≠ 1 := by native_decide

theorem BF12_ne_one : BF1 * BF2 ≠ 1 := by native_decide

theorem BF13_ne_one : BF1 * BF3 ≠ 1 := by native_decide

theorem BF21_ne_one : BF2 * BF1 ≠ 1 := by native_decide

theorem BF22_ne_one : BF2 * BF2 ≠ 1 := by native_decide

theorem BF23_ne_one : BF2 * BF3 ≠ 1 := by native_decide

theorem BF31_ne_one : BF3 * BF1 ≠ 1 := by native_decide

theorem BF32_ne_one : BF3 * BF2 ≠ 1 := by native_decide

theorem BF33_ne_one : BF3 * BF3 ≠ 1 := by native_decide


theorem d2_11_21 : BF1*BF1 ≠ BF2*BF1 := by native_decide

theorem d2_11_22 : BF1*BF1 ≠ BF2*BF2 := by native_decide

theorem d2_11_23 : BF1*BF1 ≠ BF2*BF3 := by native_decide

theorem d2_12_21 : BF1*BF2 ≠ BF2*BF1 := by native_decide

theorem d2_12_22 : BF1*BF2 ≠ BF2*BF2 := by native_decide

theorem d2_12_23 : BF1*BF2 ≠ BF2*BF3 := by native_decide

theorem d2_13_21 : BF1*BF3 ≠ BF2*BF1 := by native_decide

theorem d2_13_22 : BF1*BF3 ≠ BF2*BF2 := by native_decide

theorem d2_13_23 : BF1*BF3 ≠ BF2*BF3 := by native_decide

-- Row 1 vs Row 3

theorem d2_11_31 : BF1*BF1 ≠ BF3*BF1 := by native_decide

theorem d2_11_32 : BF1*BF1 ≠ BF3*BF2 := by native_decide

theorem d2_11_33 : BF1*BF1 ≠ BF3*BF3 := by native_decide

theorem d2_12_31 : BF1*BF2 ≠ BF3*BF1 := by native_decide

theorem d2_12_32 : BF1*BF2 ≠ BF3*BF2 := by native_decide

theorem d2_12_33 : BF1*BF2 ≠ BF3*BF3 := by native_decide

theorem d2_13_31 : BF1*BF3 ≠ BF3*BF1 := by native_decide

theorem d2_13_32 : BF1*BF3 ≠ BF3*BF2 := by native_decide

theorem d2_13_33 : BF1*BF3 ≠ BF3*BF3 := by native_decide

-- Row 2 vs Row 3

theorem d2_21_31 : BF2*BF1 ≠ BF3*BF1 := by native_decide

theorem d2_21_32 : BF2*BF1 ≠ BF3*BF2 := by native_decide

theorem d2_21_33 : BF2*BF1 ≠ BF3*BF3 := by native_decide

theorem d2_22_31 : BF2*BF2 ≠ BF3*BF1 := by native_decide

theorem d2_22_32 : BF2*BF2 ≠ BF3*BF2 := by native_decide

theorem d2_22_33 : BF2*BF2 ≠ BF3*BF3 := by native_decide

theorem d2_23_31 : BF2*BF3 ≠ BF3*BF1 := by native_decide

theorem d2_23_32 : BF2*BF3 ≠ BF3*BF2 := by native_decide

theorem d2_23_33 : BF2*BF3 ≠ BF3*BF3 := by native_decide

-- Within Row 1

theorem d2_11_12 : BF1*BF1 ≠ BF1*BF2 := by native_decide

theorem d2_11_13 : BF1*BF1 ≠ BF1*BF3 := by native_decide

theorem d2_12_13 : BF1*BF2 ≠ BF1*BF3 := by native_decide

-- Within Row 2

theorem d2_21_22 : BF2*BF1 ≠ BF2*BF2 := by native_decide

theorem d2_21_23 : BF2*BF1 ≠ BF2*BF3 := by native_decide

theorem d2_22_23 : BF2*BF2 ≠ BF2*BF3 := by native_decide

-- Within Row 3

theorem d2_31_32 : BF3*BF1 ≠ BF3*BF2 := by native_decide

theorem d2_31_33 : BF3*BF1 ≠ BF3*BF3 := by native_decide

theorem d2_32_33 : BF3*BF2 ≠ BF3*BF3 := by native_decide


theorem SwapS_invol : SwapS * SwapS = 1 := by native_decide


theorem BF3_conjugate : SwapS * BF1 * SwapS = BF3 := by native_decide


theorem BF2_self_conjugate : SwapS * BF2 * SwapS = BF2 := by native_decide

