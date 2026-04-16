/-! # CatalogBuild.Speculative.SPBBridge.SPBNewResults

Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 5
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBBridge.SPBNewResults
Auto-generated from theorem catalog database.
Domain: Speculative/SPBBridge
Declarations: 5] -/
theorem spb_reciprocal_factored (a b : ℝ) (ha : a ≠ 0) (hb : b ≠ 0)
    (hab : 1 - (1/a) * (1/b) ≠ 0) :
    spb (1/a) (1/b) = 1 ↔ (a - 1) * (b - 1) = 2 := by
  unfold spb;
  grind



theorem euler_machin_unique (a b : ℤ) (ha : 2 ≤ a) (hb : 2 ≤ b) (hab : a ≤ b)
    (hspb : (a - 1) * (b - 1) = 2) :
    a = 2 ∧ b = 3 := by
  constructor <;> nlinarith



theorem hutton_formula : spb (spb (1/3 : ℝ) (1/3)) (1/7) = 1 := by
  unfold spb; norm_num



theorem spb_hasDerivAt (a x₀ : ℝ) (h : 1 - x₀ * a ≠ 0) :
    HasDerivAt (fun x => spb x a) ((1 + a ^ 2) / (1 - x₀ * a) ^ 2) x₀ := by
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x₀ ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_id x₀ ) ( hasDerivAt_const _ _ ) ) ) h using 1 ; ring;
  norm_num ; ring



theorem neg_one_square_iff_mod4 (p : ℕ) [hp : Fact (Nat.Prime p)] (hp2 : p ≠ 2) :
    IsSquare (-1 : ZMod p) ↔ p % 4 = 1 := by
  rw [ FiniteField.isSquare_neg_one_iff ];
  cases Nat.Prime.eq_two_or_odd hp.1 <;> simp_all +decide;
  lia



end
