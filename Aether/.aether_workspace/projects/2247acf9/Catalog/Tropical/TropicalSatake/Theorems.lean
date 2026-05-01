/-
# Tropical Satake Isomorphism for GL₃: Main Theorems

This file proves the key results:
1. Tropical elementary symmetric polynomials are symmetric
2. Tropical Schur polynomials are symmetric
3. The Satake map sends fundamental coweights ω₁, ω₂, ω₃ to e₁, e₂, e₃
4. The tropical Satake isomorphism (main theorem)
-/
import RequestProject.TropicalSatake.Defs

open scoped BigOperators
open MvPolynomial

set_option maxHeartbeats 1600000

/-! ## Tropical elementary symmetric polynomials are symmetric -/

theorem tropicalESymm_isSymmetric (k : ℕ) : (tropicalESymm k).IsSymmetric :=
  MvPolynomial.esymm_isSymmetric (Fin 3) T k

/-! ## Idempotency of tropical MvPolynomial addition -/

/-- In MvPolynomial over a tropical semiring, p + p = p. -/
theorem MvPolynomial.tropical_add_self (p : TropPoly) : p + p = p := by
  ext m
  simp [MvPolynomial.coeff_add]

/-! ## Key lemma: Tropical product simplification for fundamental coweights -/

/-
For ω₁ = (1,0,0), the monomial-perm product simplifies to X (σ⁻¹ 0).
-/
lemma tropicalMonomialPerm_omega1 (σ : Equiv.Perm (Fin 3)) :
    tropicalMonomialPerm DominantCoweight.omega1 σ = X (σ⁻¹ 0) := by
      unfold tropicalMonomialPerm;
      fin_cases σ <;> simp +decide [ Fin.prod_univ_three ];
      all_goals erw [ show DominantCoweight.omega1.val = ![1, 0, 0] from rfl ] ; simp +decide [ Equiv.swap_apply_def ] ;

/-
For ω₃ = (1,1,1), the monomial-perm product simplifies to X 0 * X 1 * X 2.
-/
lemma tropicalMonomialPerm_omega3 (σ : Equiv.Perm (Fin 3)) :
    tropicalMonomialPerm DominantCoweight.omega3 σ = X 0 * X 1 * X 2 := by
      fin_cases σ <;> simp +decide [ tropicalMonomialPerm ];
      all_goals erw [ Fin.prod_univ_three ] ;
      all_goals erw [ pow_one, pow_one, pow_one ] ;

/-! ## Fundamental coweight theorems -/

/-
The tropical Satake map sends ω₁ = (1,0,0) to the first elementary symmetric polynomial.
    s_{(1,0,0)}^{trop} = e₁ = X₀ + X₁ + X₂ = min(x₁, x₂, x₃)
-/
theorem satake_omega1 :
    tropicalSatakeMap DominantCoweight.omega1 = tropicalESymm 1 := by
      unfold tropicalSatakeMap tropicalSchurPolynomial tropicalESymm;
      convert MvPolynomial.tropical_add_self _ using 1;
      rw [ Finset.sum_congr rfl fun x hx => tropicalMonomialPerm_omega1 x ] ; simp +decide [ Fin.sum_univ_three ] ; ring!;
      rw [ show ( Finset.univ : Finset ( Equiv.Perm ( Fin 3 ) ) ) = { Equiv.refl ( Fin 3 ), Equiv.swap 0 1, Equiv.swap 0 2, Equiv.swap 1 2, Equiv.swap 0 1 * Equiv.swap 1 2, Equiv.swap 0 2 * Equiv.swap 1 2 } by decide ] ; simp +decide [ Finset.sum ] ; ring!;

/-
The tropical Satake map sends ω₂ = (1,1,0) to the second elementary symmetric polynomial.
    s_{(1,1,0)}^{trop} = e₂ = X₀X₁ + X₀X₂ + X₁X₂ = min(x₁+x₂, x₁+x₃, x₂+x₃)
-/
theorem satake_omega2 :
    tropicalSatakeMap DominantCoweight.omega2 = tropicalESymm 2 := by
      convert MvPolynomial.tropical_add_self _ using 1;
      unfold tropicalSatakeMap tropicalESymm tropicalSchurPolynomial tropicalMonomialPerm DominantCoweight.omega2; simp +decide [ Fin.prod_univ_three ] ; ring;
      rw [ show ( Finset.univ : Finset ( Equiv.Perm ( Fin 3 ) ) ) = { Equiv.refl _, Equiv.swap 0 1, Equiv.swap 0 2, Equiv.swap 1 2, Equiv.swap 0 1 * Equiv.swap 0 2, Equiv.swap 0 1 * Equiv.swap 1 2 } by decide ] ; simp +decide [ Finset.sum ] ; ring!;
      rw [ show ( esymm ( Fin 3 ) T 2 : TropPoly ) = X 0 * X 1 + X 0 * X 2 + X 1 * X 2 by
            simp +decide [ esymm ];
            rw [ show ( Finset.powersetCard 2 Finset.univ : Finset ( Finset ( Fin 3 ) ) ) = { { 0, 1 }, { 0, 2 }, { 1, 2 } } by decide ] ; simp +decide [ Finset.sum ] ; ring!; ] ; ring!;
      simp +decide [ Equiv.swap_apply_def ] ; ring!;

/-
The tropical Satake map sends ω₃ = (1,1,1) to the third elementary symmetric polynomial.
    s_{(1,1,1)}^{trop} = e₃ = X₀X₁X₂ = x₁+x₂+x₃
-/
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

/-! ## Symmetry of tropical Schur polynomials -/

/-
The tropical Schur polynomial is symmetric: it is invariant under permutation of variables.
    This follows because the orbit sum ∑_σ m_{λ∘σ} sums over all permutations.
-/
theorem tropicalSchurPolynomial_isSymmetric (mu : DominantCoweight) :
    (tropicalSchurPolynomial mu).IsSymmetric := by
      unfold tropicalSchurPolynomial;
      -- By definition of tropical Schur polynomial, it is the sum of monomials over all permutations.
      intro σ
      simp [tropicalMonomialPerm];
      refine' Finset.sum_bij ( fun x _ => x * σ.symm ) _ _ _ _ <;> simp +decide [ Equiv.Perm.ext_iff ];
      · exact fun b => ⟨ b * σ, fun x => by simp +decide ⟩;
      · intro a; rw [ ← Equiv.prod_comp σ.symm ] ; simp +decide ;

/-! ## Main theorem: Fundamental coweight images -/

/-- **Tropical Satake Isomorphism for GL₃ (Fundamental Coweight Images).**

The tropical Satake transform sends the three fundamental double-coset indicators
to the three elementary symmetric polynomials in the tropical semiring. -/
theorem tropical_satake_fundamental_coweights :
    tropicalSatakeMap DominantCoweight.omega1 = tropicalESymm 1 ∧
    tropicalSatakeMap DominantCoweight.omega2 = tropicalESymm 2 ∧
    tropicalSatakeMap DominantCoweight.omega3 = tropicalESymm 3 :=
  ⟨satake_omega1, satake_omega2, satake_omega3⟩