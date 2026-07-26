/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Helpers for the Cartesian Footprint Bound

This file contains helper lemmas for the anisotropic Alon–Füredi / footprint bound
on finite Cartesian products over a field.
-/
import Mathlib

open MvPolynomial Polynomial Finset BigOperators Classical

noncomputable section

namespace CartesianFootprint

/-! ## Univariate root counting -/

/-
A nonzero univariate polynomial over a field has at most `natDegree` roots in any finite set.
-/
theorem Polynomial.card_filter_roots_le {F : Type*} [Field F]
    (p : Polynomial F) (hp : p ≠ 0) (S : Finset F) :
    (S.filter (fun a => p.eval a = 0)).card ≤ p.natDegree := by
  -- The set of roots of p in S is a subset of p.roots.toFinset.
  have h_subset : {a ∈ S | p.eval a = 0} ⊆ p.roots.toFinset := by
    intro a ha; aesop;
  exact le_trans ( Finset.card_le_card h_subset ) ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) )

/-
The number of non-roots of a nonzero polynomial p in a finite set S
    is at least |S| - natDegree(p).
-/
theorem Polynomial.card_filter_nonroots_ge {F : Type*} [Field F]
    (p : Polynomial F) (hp : p ≠ 0) (S : Finset F) :
    S.card - p.natDegree ≤ (S.filter (fun a => p.eval a ≠ 0)).card := by
  -- Use Finset.filter_card_add_filter_neg_card_eq_card to get |filter(=0)| + |filter(≠0)| = |S|.
  have h_filter_card : (∑ a ∈ S, (if p.eval a = 0 then 1 else 0)) + (∑ a ∈ S, (if p.eval a ≠ 0 then 1 else 0)) = S.card := by
    simpa only [ ← Finset.sum_add_distrib ] using Finset.card_eq_sum_ones S ▸ Finset.sum_congr rfl fun x hx => by aesop;
  simp_all +decide [ Finset.sum_ite ];
  linarith [ Polynomial.card_filter_roots_le p hp S ]

/-! ## finSuccEquiv properties -/

/-
finSuccEquiv sends nonzero polynomials to nonzero polynomials.
-/
theorem finSuccEquiv_ne_zero {R : Type*} [CommSemiring R] {n : ℕ}
    {f : MvPolynomial (Fin (n + 1)) R} (hf : f ≠ 0) :
    (MvPolynomial.finSuccEquiv R n) f ≠ 0 := by
  exact fun h => hf ( MvPolynomial.finSuccEquiv R n |>.injective <| by simp +decide [ h ] )

/-
If all monomials of f have exponent ≤ e in variable 0,
    then the natDegree of (finSuccEquiv f) is ≤ e.
-/
theorem finSuccEquiv_natDegree_le {R : Type*} [CommSemiring R] [Nontrivial R] {n : ℕ}
    {f : MvPolynomial (Fin (n + 1)) R} {e₀ : ℕ}
    (hf : ∀ m ∈ f.support, m 0 ≤ e₀) :
    ((MvPolynomial.finSuccEquiv R n) f).natDegree ≤ e₀ := by
  refine' Polynomial.natDegree_le_of_degree_le _;
  rw [ Polynomial.degree_le_iff_coeff_zero ];
  intro m hm;
  ext m';
  rw [ MvPolynomial.finSuccEquiv_coeff_coeff ];
  simp +zetaDelta at *;
  exact Classical.not_not.1 fun h => not_lt_of_ge ( hf _ h ) ( by simpa using hm )

/-
Support of a coefficient of finSuccEquiv f is controlled by support of f.
-/
theorem finSuccEquiv_coeff_support {R : Type*} [CommSemiring R] {n : ℕ}
    {f : MvPolynomial (Fin (n + 1)) R} {k : ℕ}
    {m : Fin n →₀ ℕ} (hm : m ∈ (((MvPolynomial.finSuccEquiv R n) f).coeff k).support) :
    Finsupp.cons k m ∈ f.support := by
  exact?

/-
The leading coefficient of finSuccEquiv f inherits support bounds from f.
-/
theorem finSuccEquiv_leadingCoeff_support_bound {R : Type*} [CommSemiring R] {n : ℕ}
    {f : MvPolynomial (Fin (n + 1)) R}
    {m : Fin n →₀ ℕ}
    (hm : m ∈ ((MvPolynomial.finSuccEquiv R n) f).leadingCoeff.support)
    (j : Fin n) {b : ℕ} (hb : ∀ m' ∈ f.support, m' (Fin.succ j) ≤ b) :
    m j ≤ b := by
  -- By definition of leadingCoeff, we know that m is in the support of the coefficient at the natural degree of finSuccEquiv f.
  have h_leading_coeff : m ∈ (((MvPolynomial.finSuccEquiv R n) f).coeff (Polynomial.natDegree ((MvPolynomial.finSuccEquiv R n) f))).support := by
    convert hm using 1;
  have h_leading_coeff_support : Finsupp.cons (Polynomial.natDegree ((MvPolynomial.finSuccEquiv R n) f)) m ∈ f.support := by
    convert finSuccEquiv_coeff_support h_leading_coeff;
  specialize hb ( Finsupp.cons ( Polynomial.natDegree ( MvPolynomial.finSuccEquiv R n f ) ) m ) h_leading_coeff_support ; aesop;

/-
If map (eval a) of finSuccEquiv f is nonzero, then eval a of leadingCoeff implies
    the mapped polynomial has the same natDegree.
-/
theorem map_eval_natDegree_le {F : Type*} [Field F] {n : ℕ}
    {f : MvPolynomial (Fin (n + 1)) F} {e₀ : ℕ}
    (he : ∀ m ∈ f.support, m 0 ≤ e₀)
    (a : Fin n → F) :
    (Polynomial.map (MvPolynomial.eval a) ((MvPolynomial.finSuccEquiv F n) f)).natDegree ≤ e₀ := by
  refine' le_trans ( Polynomial.natDegree_map_le .. ) ( finSuccEquiv_natDegree_le he )

/-
If eval a (leadingCoeff P) ≠ 0, then map (eval a) P ≠ 0.
-/
theorem map_eval_ne_zero_of_leadingCoeff {R : Type*} [CommSemiring R] [Nontrivial R]
    [NoZeroDivisors R] {P : Polynomial R}
    {φ : R →+* R} (hP : φ (P.leadingCoeff) ≠ 0) :
    P.map φ ≠ 0 := by
  simp +decide [ hP, Polynomial.ext_iff ];
  exact ⟨ P.natDegree, by simpa [ Polynomial.leadingCoeff, Polynomial.natDegree ] using hP ⟩

end CartesianFootprint