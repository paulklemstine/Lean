/-! # CatalogBuild.Algebra.RepresentationTheory.RepresentationTheory

Auto-generated from theorem catalog database.
Domain: Algebra/RepresentationTheory
Declarations: 8
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.RepresentationTheory.RepresentationTheory
Auto-generated from theorem catalog database.
Domain: Algebra/RepresentationTheory
Declarations: 8] -/
theorem sign_rep_identity : Equiv.Perm.sign (1 : Equiv.Perm (Fin 3)) = 1 := by simp





/-- [Section: # CatalogBuild.Algebra.RepresentationTheory.RepresentationTheory
Auto-generated from theorem catalog database.
Domain: Algebra/RepresentationTheory
Declarations: 8] -/
theorem sign_swap' : Equiv.Perm.sign (Equiv.swap (0 : Fin 3) 1) = -1 := by native_decide





/-- [Section: # CatalogBuild.Algebra.RepresentationTheory.RepresentationTheory
Auto-generated from theorem catalog database.
Domain: Algebra/RepresentationTheory
Declarations: 8] -/
theorem regular_rep_dim (n : ℕ) [NeZero n] :
    Fintype.card (ZMod n) = n := ZMod.card n





theorem sym2_dim' : Nat.choose (2 + 2 - 1) 2 = 3 := by native_decide





theorem symn_dim' (n : ℕ) : Nat.choose (n + 1) 1 = n + 1 := by simp





theorem moonshine_dimension' : 196884 = 196883 + 1 := by norm_num




theorem mckay_first' : 196884 = 1 + 196883 := by norm_num




theorem mckay_second' : 21493760 = 1 + 196883 + 21296876 := by norm_num




