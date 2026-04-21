/-! # CatalogBuild.Pythagorean.Berggren.HyperbolicGeometry

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 32
-/

import Mathlib

theorem lorentz_M4 : (M^4).transpose * eta * (M^4) = eta := by native_decide

theorem lorentz_M5 : (M^5).transpose * eta * (M^5) = eta := by native_decide

theorem lorentz_M6 : (M^6).transpose * eta * (M^6) = eta := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 2: Null Cone (Pythagorean triples)
-- ═══════════════════════════════════════════════════════════════

-- Pythagorean triples lie on the null cone η(v,v) = 0

theorem null_cone_345 : (3 : ℤ)^2 + 4^2 - 5^2 = 0 := by norm_num

theorem null_cone_51213 : (5 : ℤ)^2 + 12^2 - 13^2 = 0 := by norm_num

theorem null_cone_81517 : (8 : ℤ)^2 + 15^2 - 17^2 = 0 := by norm_num

-- The ghost map preserves the null cone

theorem ghost_preserves_null (a b c : ℤ) (hp : a^2 + b^2 - c^2 = 0) :
    (a + 2*b - 2*c)^2 + (2*a + b - 2*c)^2 - (-2*a - 2*b + 3*c)^2 = 0 := by nlinarith

-- ═══════════════════════════════════════════════════════════════
-- Section 3: Eigenvector Analysis
-- ═══════════════════════════════════════════════════════════════

-- (1,−1,0) is a spacelike eigenvector: η((1,−1,0), (1,−1,0)) = 2

theorem eigvec_spacelike : (1 : ℤ)^2 + (-1)^2 - 0^2 = 2 := by norm_num

theorem eigvec_neg1 : M.mulVec ![1, -1, 0] = ![-1, 1, 0] := by native_decide

theorem M_on_110 : M.mulVec ![1, 1, 0] = ![3, 3, -4] := by native_decide

-- ═══════════════════════════════════════════════════════════════
-- Section 4: Hyperboloid Points (orbit of the origin)
-- ═══════════════════════════════════════════════════════════════

-- (0,0,1) is on the upper hyperboloid: x²+y²−z² = −1

theorem center_hyperboloid : (0 : ℤ)^2 + 0^2 - 1^2 = -1 := by norm_num

-- M · (0,0,1) = (−2,−2,3): on the hyperboloid

theorem M_center : M.mulVec ![0, 0, 1] = ![-2, -2, 3] := by native_decide

theorem M_center_on_hyp : (-2 : ℤ)^2 + (-2)^2 - 3^2 = -1 := by norm_num

-- M² · (0,0,1) = (−12,−12,17): on the hyperboloid

theorem M2_center : (M^2).mulVec ![0, 0, 1] = ![-12, -12, 17] := by native_decide

theorem M2_center_on_hyp : (-12 : ℤ)^2 + (-12)^2 - 17^2 = -1 := by norm_num

-- M³ · (0,0,1) = (−70,−70,99): on the hyperboloid

theorem M3_center : (M^3).mulVec ![0, 0, 1] = ![-70, -70, 99] := by native_decide

theorem M3_center_on_hyp : (-70 : ℤ)^2 + (-70)^2 - 99^2 = -1 := by norm_num

-- M⁴ · (0,0,1) = (−408,−408,577): on the hyperboloid

theorem M4_center : (M^4).mulVec ![0, 0, 1] = ![-408, -408, 577] := by native_decide

theorem M4_center_on_hyp : (-408 : ℤ)^2 + (-408)^2 - 577^2 = -1 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 5: Translation Length
-- ═══════════════════════════════════════════════════════════════

-- cosh(d_n) = −η(o, M^n·o) = M^n[2,2] = NSW(n)
-- Computed via the Minkowski inner product: −η((0,0,1), M^n·(0,0,1)) = M^n[2,2]

theorem hyp_dist_1 : (0 : ℤ) * (-2) + 0 * (-2) + 1 * 3 = 3 := by norm_num

theorem hyp_dist_2 : (0 : ℤ) * (-12) + 0 * (-12) + 1 * 17 = 17 := by norm_num

theorem hyp_dist_3 : (0 : ℤ) * (-70) + 0 * (-70) + 1 * 99 = 99 := by norm_num

-- The doubling relation: 2·cosh²(d) − 1 = cosh(2d)
-- i.e., 2·3² − 1 = 17 (checks out!)

theorem nsw_doubling : 2 * (3 : ℤ)^2 - 1 = 17 := by norm_num

theorem nsw_doubling_2 : 2 * (17 : ℤ)^2 - 1 = 577 := by norm_num

-- ═══════════════════════════════════════════════════════════════
-- Section 6: Poincaré Disk Coordinates
-- ═══════════════════════════════════════════════════════════════

-- Projection (x,y,z) → (x/(z+1), y/(z+1))
-- Orbit: (0,0) → (−1/2, −1/2) → (−2/3, −2/3) → (−7/10, −7/10)

theorem disk_coord_1 : ((-2 : ℚ)) / (3 + 1) = -1/2 := by norm_num

theorem disk_coord_2 : ((-12 : ℚ)) / (17 + 1) = -2/3 := by norm_num

theorem disk_coord_3 : ((-70 : ℚ)) / (99 + 1) = -7/10 := by norm_num

theorem disk_coord_4 : ((-408 : ℚ)) / (577 + 1) = -408/578 := by norm_num

-- The coordinates approach (−1/√2, −1/√2) ≈ (−0.707, −0.707)
-- Verified: ratio -408/578 ≈ -0.7058...

theorem disk_approaching : (408 : ℚ) * 408 * 2 < 578 * 578 := by norm_num
-- i.e., |x| < 1/√2 still, but approaching

-- ═══════════════════════════════════════════════════════════════
-- Section 7: Berggren Tree as Tessellation
-- ═══════════════════════════════════════════════════════════════


def B3 : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

-- All three matrices preserve the Lorentz form

theorem M_is_B2_inv : B2 * M = 1 := by native_decide

theorem M_is_B2_inv' : M * B2 = 1 := by native_decide

-- The three children of (3,4,5) in the Berggren tree
