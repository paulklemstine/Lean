/-! # CatalogBuild.SPBBridge.FiniteFields

Auto-generated from theorem catalog database.
Domain: SPBBridge
Declarations: 1
-/

import Mathlib
import SPBBridge.Core

noncomputable section

theorem neg_one_square_iff (hp2 : p ≠ 2) :
    IsSquare (-1 : ZMod p) ↔ p % 4 = 1 := by
  rw [FiniteField.isSquare_neg_one_iff, ZMod.card]
  rcases (Fact.out : Nat.Prime p).eq_two_or_odd with rfl | hodd
  · exact absurd rfl hp2
  · omega

/-! ## Computational Verification -/

-- These instance declarations are needed for native_decide

end
