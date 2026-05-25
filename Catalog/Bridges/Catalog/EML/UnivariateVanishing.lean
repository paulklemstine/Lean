/-
# Univariate Polynomial Vanishing over Finite Fields

The foundational lemma: a polynomial of degree less than |K| that vanishes at every
element of K must be the zero polynomial.
-/
import Mathlib

open Polynomial Finset

/-
A univariate polynomial over a finite field that vanishes at every element
and has degree less than the field cardinality must be zero.
-/
theorem polynomial_eq_zero_of_eval_eq_zero_all
    {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    (p : Polynomial K)
    (hdeg : p.natDegree < Fintype.card K)
    (hzero : ∀ a : K, Polynomial.eval a p = 0) :
    p = 0 := by
  exact Polynomial.eq_zero_of_degree_lt_of_eval_finset_eq_zero Finset.univ ( lt_of_le_of_lt Polynomial.degree_le_natDegree ( WithBot.coe_lt_coe.mpr hdeg ) ) ( fun x hx => hzero x )