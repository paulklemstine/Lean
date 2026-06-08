/-
# Target B: Polynomial Observable Space Preservation

The Apollonian generators act on polynomial observables by precomposition,
and this action preserves the finite-dimensional space of polynomials
of total degree ≤ k.
-/

import Mathlib
import Algebra.Apollonian.Defs

open Matrix Finset BigOperators MvPolynomial

/-! ## Key lemma: linear substitution preserves total degree -/

/-- The linear form for the j-th coordinate after applying generator i.
    This is `∑ₗ S_i[j,l] * X_l`, a polynomial of degree ≤ 1. -/
noncomputable def apollonianLinearForm (R : Type*) [CommRing R]
    (i j : Fin 4) : MvPolynomial (Fin 4) R :=
  ∑ l : Fin 4, MvPolynomial.C ((apollonianGen i j l : ℤ) : R) * MvPolynomial.X l

/-
Each Apollonian linear form has total degree at most 1.
-/
theorem apollonianLinearForm_degree_le_one (R : Type*) [CommRing R]
    (i j : Fin 4) : (apollonianLinearForm R i j).totalDegree ≤ 1 := by
  refine' Finset.sup_le fun m hm => _;
  simp_all +decide [ Finset.sum_apply', apollonianLinearForm ];
  contrapose! hm; simp_all +decide [ coeff_sum, MvPolynomial.coeff_C_mul, MvPolynomial.coeff_X' ] ;
  refine' Finset.sum_eq_zero fun x hx => _;
  erw [ MvPolynomial.coeff_C_mul, MvPolynomial.coeff_X' ] ; aesop

/-
Precomposition with an Apollonian generator preserves total degree.
    This shows the finite-dimensional space of degree-≤k observables is preserved.
-/
theorem apollonian_action_preserves_totalDegree
    (R : Type*) [CommRing R] (k : ℕ) (i : Fin 4)
    (p : MvPolynomial (Fin 4) R) :
    p.totalDegree ≤ k →
    (precomposeApollonian R i p).totalDegree ≤ k := by
  intro hp
  unfold precomposeApollonian;
  -- Each monomial in the expansion of `p` is replaced by a sum of monomials, each of which has degree at most the degree of the original monomial.
  have h_mono : ∀ m ∈ p.support, (MvPolynomial.totalDegree (∏ j : Fin 4, (apollonianLinearForm R i j) ^ m j)) ≤ (MvPolynomial.totalDegree (MvPolynomial.monomial m 1)) := by
    intro m hm
    have h_mono : (MvPolynomial.totalDegree (∏ j : Fin 4, (apollonianLinearForm R i j) ^ m j)) ≤ ∑ j : Fin 4, m j := by
      have h_mono : ∀ j : Fin 4, (MvPolynomial.totalDegree ((apollonianLinearForm R i j) ^ m j)) ≤ m j := by
        intro j
        have h_mono : (apollonianLinearForm R i j).totalDegree ≤ 1 := by
          exact?
        have h_mono_pow : (apollonianLinearForm R i j ^ m j).totalDegree ≤ m j := by
          induction' m j with m ih <;> simp_all +decide [ pow_succ' ];
          exact le_trans ( MvPolynomial.totalDegree_mul _ _ ) ( by linarith )
        exact h_mono_pow;
      have h_mono : ∀ (s : Finset (Fin 4)), (MvPolynomial.totalDegree (∏ j ∈ s, (apollonianLinearForm R i j) ^ m j)) ≤ ∑ j ∈ s, m j := by
        intro s;
        induction s using Finset.induction <;> simp_all +decide [ Finset.sum_insert, Finset.prod_insert ];
        exact le_trans ( MvPolynomial.totalDegree_mul _ _ ) ( add_le_add ( h_mono _ ) ‹_› );
      exact h_mono Finset.univ;
    simp_all +decide [ MvPolynomial.totalDegree_monomial ];
    convert h_mono using 1;
    simp +decide [ Finsupp.sum_fintype ];
  -- By definition of `aeval`, we can expand `p` as a sum of monomials.
  have h_expand : (aeval (fun j => ∑ l, C (apollonianGen i j l : R) * X l) p) = ∑ m ∈ p.support, p.coeff m • (∏ j : Fin 4, (apollonianLinearForm R i j) ^ m j) := by
    conv_lhs => rw [ p.as_sum ];
    simp +decide [ MvPolynomial.monomial_eq, Finset.prod_pow_eq_pow_sum ];
    simp +decide [ apollonianLinearForm, MvPolynomial.smul_eq_C_mul ];
  rw [ h_expand ];
  simp +decide [ MvPolynomial.totalDegree ] at *;
  intro b hb
  obtain ⟨m, hm⟩ : ∃ m ∈ p.support, ¬coeff m p = 0 ∧ ¬coeff b (∏ j : Fin 4, (apollonianLinearForm R i j) ^ m j) = 0 := by
    contrapose! hb;
    rw [ MvPolynomial.coeff_sum ];
    refine' Finset.sum_eq_zero fun m hm => _;
    by_cases h : coeff m p = 0 <;> simp_all +decide [ MvPolynomial.coeff_smul ];
  exact le_trans ( h_mono m hm.2.1 b hm.2.2 ) ( by simpa [ MvPolynomial.support_monomial ] using hp m hm.2.1 )

/-
Precomposition of a coordinate variable gives a degree-1 polynomial.
-/
theorem precompose_coordinate_degree_one
    (R : Type*) [CommRing R] (i j : Fin 4) :
    (precomposeApollonian R i (MvPolynomial.X j)).totalDegree ≤ 1 := by
  convert apollonianLinearForm_degree_le_one R i j using 1;
  unfold precomposeApollonian; aesop;