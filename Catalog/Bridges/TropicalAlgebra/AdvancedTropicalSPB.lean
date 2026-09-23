import Mathlib
import Logic.StrangeLoops.Core
-- MISSING MODULE (not present in this repository): import Pythagorean.Pythagorean.TropicalAssociativity_1
import Pythagorean.TropicalAlgebra.TropicalSPB

/-! # CatalogBuild.Bridges.AdvancedTropicalSPB

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14
-/

noncomputable section

/-- [Section: # Advanced Tropical SPB: Semigroup Structure and New Identities] -/
theorem tspb_neg_self (x : ℝ) : tspb x (-x) = |x| := by
  unfold tspb;
  grind

/-- [Section: # CatalogBuild.Bridges.AdvancedTropicalSPB
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 14] -/
theorem tspb_self (x : ℝ) : tspb x x = -|x| := by
  unfold tspb; cases abs_cases x <;> simp +decide [ * ] ;
  linarith

/-- tspb(-x,-y) = tspb(x,y). -/
theorem tspb_neg_neg (x y : ℝ) : tspb (-x) (-y) = tspb x y := by
  simp only [TropicalAssoc.tspb_abs_formula]
  congr 1; congr 1
  · rw [show -x - -y = -(x - y) from by ring, abs_neg]
  · rw [show -x + -y = -(x + y) from by ring, abs_neg]

/-- 0 is a right absorbing element. -/
theorem tspb_zero_absorb_right (x : ℝ) : tspb 0 x = 0 := by
  rw [TropicalSPBResults.tspb_comm]; exact TropicalSPBResults.tspb_zero_absorb x

/-- Triple: tspb(tspb(x,x), x) = tspb(-|x|, x). -/
theorem tspb_triple (x : ℝ) : tspb (tspb x x) x = tspb (-|x|) x := by
  rw [tspb_self]

/-- Quadruple: tspb(tspb(x,x), tspb(x,x)) = -|x|. -/
theorem tspb_quadruple (x : ℝ) : tspb (tspb x x) (tspb x x) = -|x| := by
  rw [tspb_self, tspb_self]; simp [abs_neg, abs_abs]

/-- tspb is antitone on [0, ∞). -/
theorem tspb_antitone_nonneg (x x' y : ℝ) (hx : 0 ≤ x) (hx' : x ≤ x') (hy : 0 ≤ y) :
    tspb x' y ≤ tspb x y := by
  rw [TropicalSPBResults.tspb_nonneg x' y (by linarith) hy,
      TropicalSPBResults.tspb_nonneg x y hx hy]
  linarith [min_le_min_right y hx']

/-- tspb is monotone on (−∞, 0]. -/
theorem tspb_monotone_nonpos (x x' y : ℝ) (hx : x ≤ x') (hx' : x' ≤ 0) (hy : y ≤ 0) :
    tspb x y ≤ tspb x' y := by
  rw [TropicalSPBResults.tspb_nonpos x y (by linarith) hy,
      TropicalSPBResults.tspb_nonpos x' y hx' hy]
  exact max_le_max_right y hx

theorem tspb_2_3 : tspb 2 3 = -2 := by
  rw [TropicalSPBResults.tspb_nonneg 2 3 (by norm_num) (by norm_num)]; norm_num

theorem tspb_neg1_neg2 : tspb (-1) (-2) = -1 := by
  rw [TropicalSPBResults.tspb_nonpos (-1) (-2) (by norm_num) (by norm_num)]; norm_num

theorem tspb_1_neg1 : tspb 1 (-1) = 1 := by
  unfold tspb; norm_num [max_def]

theorem semigroup_comm (x y : ℝ) : tspb x y = tspb y x :=
  TropicalSPBResults.tspb_comm x y

theorem semigroup_assoc (x y z : ℝ) : tspb (tspb x y) z = tspb x (tspb y z) :=
  TropicalAssoc.tspb_assoc x y z

theorem semigroup_zero (x : ℝ) : tspb x 0 = 0 :=
  TropicalSPBResults.tspb_zero_absorb x

end