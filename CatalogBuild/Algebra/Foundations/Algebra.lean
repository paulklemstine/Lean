/-! # CatalogBuild.Algebra.Foundations.Algebra

Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 5
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.Foundations.Algebra
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 5] -/
theorem lagrange_theorem {G : Type*} [Group G] [Fintype G]
    (H : Subgroup G) [Fintype H] :
    Fintype.card H ∣ Fintype.card G := by
      convert Subgroup.card_subgroup_dvd_card H using 1 ; aesop;
      rw [ Nat.card_eq_fintype_card ]





/-- [Section: # CatalogBuild.Algebra.Foundations.Algebra
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 5] -/
theorem prime_order_cyclic {G : Type*} [Group G] [Fintype G]
    (hp : (Fintype.card G).Prime) : IsCyclic G := by
      haveI := Fact.mk hp; exact isCyclic_of_prime_card ( by aesop ) ;





/-- [Section: # CatalogBuild.Algebra.Foundations.Algebra
Auto-generated from theorem catalog database.
Domain: Algebra/Foundations
Declarations: 5] -/
theorem irreducible_is_prime_in_pid {R : Type*} [CommRing R] [IsDomain R]
    [IsPrincipalIdealRing R] {p : R} (hp : Irreducible p) : Prime p := by
      convert hp.prime





theorem crt_coprime (m n : ℕ) (hm : 0 < m) (hn : 0 < n) (hcoprime : Nat.Coprime m n)
    (a b : ℕ) : ∃ x : ℕ, x % m = a % m ∧ x % n = b % n := by
      have := Nat.chineseRemainder hcoprime a b; aesop;





theorem x_sq_plus_one_irreducible :
    Irreducible (Polynomial.X ^ 2 + 1 : Polynomial ℚ) := by
      -- We'll use that $x^2 + 1$ is the cyclotomic polynomial $\Phi_4(x)$.
      have h_cyclotomic : Polynomial.X ^ 2 + 1 = Polynomial.cyclotomic 4 ℚ := by
        rw [ show ( 4 : ℕ ) = 2 ^ 2 by norm_num, Polynomial.cyclotomic_prime_pow_eq_geom_sum ] ; norm_num;
        norm_num +zetaDelta at *
      rw [h_cyclotomic] ; exact Polynomial.cyclotomic.irreducible_rat (by decide)



