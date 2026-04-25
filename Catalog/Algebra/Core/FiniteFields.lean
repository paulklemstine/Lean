import Mathlib
import Pythagorean.Core

/-! # CatalogBuild.Pythagorean.FiniteFields

Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 1
-/

noncomputable section

/-- -1 is a square mod p iff p ≡ 1 (mod 4), for odd primes. -/
theorem neg_one_square_iff (hp2 : p ≠ 2) :
    IsSquare (-1 : ZMod p) ↔ p % 4 = 1 := by
  rw [FiniteField.isSquare_neg_one_iff, ZMod.card]
  rcases (Fact.out : Nat.Prime p).eq_two_or_odd with rfl | hodd
  · exact absurd rfl hp2
  · omega

end
