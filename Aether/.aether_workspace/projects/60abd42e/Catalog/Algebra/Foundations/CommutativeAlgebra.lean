import Mathlib

/-! # CatalogBuild.Algebra.Foundations.CommutativeAlgebra

Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 7
-/


/-- [Section: # CatalogBuild.Algebra.Foundations.CommutativeAlgebra
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 7] -/
theorem ideal_mul_le_inf' {R : Type*} [CommRing R] (I J : Ideal R) :
    I * J ≤ I ⊓ J := Ideal.mul_le_inf




/-- [Section: # CatalogBuild.Algebra.Foundations.CommutativeAlgebra
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 7] -/
theorem maximal_is_prime' {R : Type*} [CommRing R] (I : Ideal R)
    [hI : I.IsMaximal] : I.IsPrime := Ideal.IsMaximal.isPrime hI




theorem int_noetherian' : IsNoetherianRing ℤ := inferInstance




theorem quotient_noetherian' {R : Type*} [CommRing R] [IsNoetherianRing R]
    (I : Ideal R) : IsNoetherianRing (R ⧸ I) := inferInstance




theorem polynomial_noetherian' {R : Type*} [CommRing R] [IsNoetherianRing R] :
    IsNoetherianRing R[X] := inferInstance




theorem crt_coprime' {R : Type*} [CommRing R] (I J : Ideal R) (h : I ⊔ J = ⊤) :
    I ⊓ J = I * J :=
  Ideal.inf_eq_mul_of_isCoprime (Ideal.isCoprime_iff_sup_eq.mpr h)




theorem finite_domain_is_field' (R : Type*) [CommRing R] [IsDomain R]
    [Finite R] : IsField R :=
  Finite.isField_of_domain R



