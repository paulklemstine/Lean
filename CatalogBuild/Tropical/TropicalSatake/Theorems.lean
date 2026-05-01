/-! # CatalogBuild.Tropical.TropicalSatake.Theorems

Auto-generated from theorem catalog database.
Domain: Tropical/TropicalSatake
Declarations: 9
-/

import RequestProject.TropicalSatake.Defs

/-- [Section: ## Tropical elementary symmetric polynomials are symmetric] -/
theorem tropicalESymm_isSymmetric (k : ℕ) : (tropicalESymm k).IsSymmetric :=
  MvPolynomial.esymm_isSymmetric (Fin 3) T k


/-- In MvPolynomial over a tropical semiring, p + p = p. -/
theorem MvPolynomial.tropical_add_self (p : TropPoly) : p + p = p := by
  ext m
  simp [MvPolynomial.coeff_add]


/-- [Section: ## Key lemma: Tropical product simplification for fundamental coweights] -/
lemma tropicalMonomialPerm_omega1 (σ : Equiv.Perm (Fin 3)) :
    tropicalMonomialPerm DominantCoweight.omega1 σ = X (σ⁻¹ 0) := by
      unfold tropicalMonomialPerm;
      fin_cases σ <;> simp +decide [ Fin.prod_univ_three ];
      all_goals erw [ show DominantCoweight.omega1.val = ![1, 0, 0] from rfl ] ; simp +decide [ Equiv.swap_apply_def ] ;


lemma tropicalMonomialPerm_omega3 (σ : Equiv.Perm (Fin 3)) :
    tropicalMonomialPerm DominantCoweight.omega3 σ = X 0 * X 1 * X 2 := by
      fin_cases σ <;> simp +decide [ tropicalMonomialPerm ];
      all_goals erw [ Fin.prod_univ_three ] ;
      all_goals erw [ pow_one, pow_one, pow_one ] ;


/-- [Section: ## Fundamental coweight theorems] -/
theorem satake_omega1 :
    tropicalSatakeMap DominantCoweight.omega1 = tropicalESymm 1 := by
      unfold tropicalSatakeMap tropicalSchurPolynomial tropicalESymm;
      convert MvPolynomial.tropical_add_self _ using 1;
      rw [ Finset.sum_congr rfl fun x hx => tropicalMonomialPerm_omega1 x ] ; simp +decide [ Fin.sum_univ_three ] ; ring!;
      rw [ show ( Finset.univ : Finset ( Equiv.Perm ( Fin 3 ) ) ) = { Equiv.refl ( Fin 3 ), Equiv.swap 0 1, Equiv.swap 0 2, Equiv.swap 1 2, Equiv.swap 0 1 * Equiv.swap 1 2, Equiv.swap 0 2 * Equiv.swap 1 2 } by decide ] ; simp +decide [ Finset.sum ] ; ring!;


theorem satake_omega2 :
    tropicalSatakeMap DominantCoweight.omega2 = tropicalESymm 2 := by
      convert MvPolynomial.tropical_add_self _ using 1;
      unfold tropicalSatakeMap tropicalESymm tropicalSchurPolynomial tropicalMonomialPerm DominantCoweight.omega2; simp +decide [ Fin.prod_univ_three ] ; ring;
      rw [ show ( Finset.univ : Finset ( Equiv.Perm ( Fin 3 ) ) ) = { Equiv.refl _, Equiv.swap 0 1, Equiv.swap 0 2, Equiv.swap 1 2, Equiv.swap 0 1 * Equiv.swap 0 2, Equiv.swap 0 1 * Equiv.swap 1 2 } by decide ] ; simp +decide [ Finset.sum ] ; ring!;
      rw [ show ( esymm ( Fin 3 ) T 2 : TropPoly ) = X 0 * X 1 + X 0 * X 2 + X 1 * X 2 by
            simp +decide [ esymm ];
            rw [ show ( Finset.powersetCard 2 Finset.univ : Finset ( Finset ( Fin 3 ) ) ) = { { 0, 1 }, { 0, 2 }, { 1, 2 } } by decide ] ; simp +decide [ Finset.sum ] ; ring!; ] ; ring!;
      simp +decide [ Equiv.swap_apply_def ] ; ring!;


theorem satake_omega3 :
    tropicalSatakeMap DominantCoweight.omega3 = tropicalESymm 3 := by
      unfold tropicalSatakeMap tropicalSchurPolynomial tropicalESymm;
      unfold tropicalMonomialPerm; simp +decide [ esymm ] ;
      rw [ Finset.sum_eq_card_nsmul ] <;> norm_num;
      rotate_right;
      exact ∏ i, X i;
      · rw [ Finset.sum_eq_single ( Finset.univ : Finset ( Fin 3 ) ) ] <;> simp +decide;
        norm_cast;
      · simp +decide [ DominantCoweight.omega3 ];
        intro a; fin_cases a <;> simp +decide [ Fin.prod_univ_succ ] ;
        · simp +decide [ Equiv.swap_apply_def ];
        · exact pow_one _;
        · simp +decide [ Equiv.swap_apply_def ];
        · exact pow_one _;
        · simp +decide [ Equiv.swap_apply_def ]


/-- [Section: ## Symmetry of tropical Schur polynomials] -/
theorem tropicalSchurPolynomial_isSymmetric (mu : DominantCoweight) :
    (tropicalSchurPolynomial mu).IsSymmetric := by
      unfold tropicalSchurPolynomial;
      -- By definition of tropical Schur polynomial, it is the sum of monomials over all permutations.
      intro σ
      simp [tropicalMonomialPerm];
      refine' Finset.sum_bij ( fun x _ => x * σ.symm ) _ _ _ _ <;> simp +decide [ Equiv.Perm.ext_iff ];
      · exact fun b => ⟨ b * σ, fun x => by simp +decide ⟩;
      · intro a; rw [ ← Equiv.prod_comp σ.symm ] ; simp +decide ;


/-- **Tropical Satake Isomorphism for GL₃ (Fundamental Coweight Images).**
The tropical Satake transform sends the three fundamental double-coset indicators
to the three elementary symmetric polynomials in the tropical semiring. -/
theorem tropical_satake_fundamental_coweights :
    tropicalSatakeMap DominantCoweight.omega1 = tropicalESymm 1 ∧
    tropicalSatakeMap DominantCoweight.omega2 = tropicalESymm 2 ∧
    tropicalSatakeMap DominantCoweight.omega3 = tropicalESymm 3 :=
  ⟨satake_omega1, satake_omega2, satake_omega3⟩
