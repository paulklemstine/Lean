/-! # CatalogBuild.Bridges.RingTheoryBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 4
-/

import Mathlib

noncomputable section

/-- **Maximal ideals are prime**: I is maximal ⟹ I is prime.
Fundamental inclusion: maximal ⊂ prime. -/
theorem maximal_imp_prime {R : Type*} [CommSemiring R]
    {I : Ideal R} (h : I.IsMaximal) :
    I.IsPrime :=
  Ideal.IsMaximal.isPrime h


/-- **R/I is a field when I is maximal**: The quotient by a maximal
ideal is a field. THE MOST IMPORTANT correspondence in commutative
algebra — maximal ideals ↔ fields ↔ points. -/
noncomputable instance quotient_field_of_maximal {R : Type*} [CommRing R]
    (I : Ideal R) [h : I.IsMaximal] :
    Field (R ⧸ I) :=
  Ideal.Quotient.field I


/-- **R/I is an integral domain ⟺ I is prime**.
Prime ideals ↔ integral domains ↔ irreducible subvarieties. -/
theorem quotient_domain_iff_prime {R : Type*} [Ring R]
    (I : Ideal R) [I.IsTwoSided] :
    IsDomain (R ⧸ I) ↔ I.IsPrime :=
  Ideal.Quotient.isDomain_iff_prime I


/-- Every field is an integral domain.
This follows from the fact that nonzero elements are invertible. -/
theorem field_imp_domain (K : Type*) [Field K] :
    IsDomain K :=
  instIsDomain


end
