/-
# Multivariate Polynomial Vanishing over Finite Fields

If a multivariate polynomial over a finite field has total degree less than |K|
and vanishes at every point of K^n, then it is the zero polynomial.

This is proved by induction on n using `MvPolynomial.finSuccEquiv` to decompose
n-variate polynomials into univariate polynomials over (n-1)-variate coefficients.
-/
import Mathlib

open MvPolynomial Polynomial Finset

noncomputable section

/-
The total degree of each coefficient of `finSuccEquiv R n f` is at most
the total degree of `f`.
-/
theorem MvPolynomial.totalDegree_coeff_finSuccEquiv_le
    {R : Type*} [CommSemiring R] {n : ℕ}
    (f : MvPolynomial (Fin (n + 1)) R) (i : ℕ) :
    (((MvPolynomial.finSuccEquiv R n) f).coeff i).totalDegree ≤ f.totalDegree := by
  unfold MvPolynomial.totalDegree;
  simp_all +decide [ MvPolynomial.finSuccEquiv_coeff_coeff ];
  intro b hb; refine' le_trans _ ( Finset.le_sup <| MvPolynomial.mem_support_iff.mpr hb ) ; simp +decide [ Finsupp.sum_cons' ] ;
  exact le_add_of_nonneg_of_le ( Nat.zero_le _ ) ( by rfl )

/-
A multivariate polynomial over a finite field that vanishes at every point
and has total degree less than the field cardinality must be zero.
Proof by induction on the number of variables.
-/
theorem mvpolynomial_eq_zero_of_eval_eq_zero
    {K : Type*} [Field K] [Fintype K] [DecidableEq K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (hdeg : f.totalDegree < Fintype.card K)
    (hzero : ∀ x : Fin n → K, MvPolynomial.eval x f = 0) :
    f = 0 := by
  induction' n with n ih;
  · rw [ MvPolynomial.eq_C_of_isEmpty f ] at hzero ⊢; aesop;
  · -- By definition of polynomial evaluation, we know that if $f$ vanishes at every point in $K^{n+1}$, then for every $a \in K^n$, the polynomial $f(a, Y)$ vanishes at every point in $K$.
    have h_eval : ∀ a : Fin n → K, ∀ y : K, (MvPolynomial.eval (Fin.cons y a)) f = 0 := by
      exact fun a y => hzero _;
    -- By definition of polynomial evaluation, we know that if $f$ vanishes at every point in $K^{n+1}$, then for every $a \in K^n$, the polynomial $f(a, Y)$ is the zero polynomial.
    have h_poly_zero : ∀ a : Fin n → K, Polynomial.map (MvPolynomial.eval a) (MvPolynomial.finSuccEquiv K n f) = 0 := by
      intro a
      have h_poly_zero : ∀ y : K, Polynomial.eval y (Polynomial.map (MvPolynomial.eval a) (MvPolynomial.finSuccEquiv K n f)) = 0 := by
        intro y
        have := h_eval a y
        simp [MvPolynomial.eval_eq_eval_mv_eval'] at this;
        exact this;
      refine' Polynomial.eq_of_degree_sub_lt_of_eval_finset_eq _ _ _;
      exact?;
      · have h_deg : Polynomial.degree (MvPolynomial.finSuccEquiv K n f) < Fintype.card K := by
          by_cases hf : f = 0 <;> simp_all +decide [ MvPolynomial.degree_finSuccEquiv ];
          exact lt_of_le_of_lt ( MvPolynomial.degreeOf_le_totalDegree _ _ ) hdeg;
        simp +zetaDelta at *;
        exact Polynomial.eq_zero_of_degree_lt_of_eval_finset_eq_zero ( Finset.univ : Finset K ) ( lt_of_le_of_lt ( Polynomial.degree_map_le ) h_deg ) fun x hx => h_poly_zero x;
      · exact fun x hx => False.elim <| Finset.notMem_empty x hx;
    -- By definition of polynomial evaluation, we know that if $f(a, Y)$ is the zero polynomial for every $a \in K^n$, then each coefficient of $f(a, Y)$ must be zero.
    have h_coeff_zero : ∀ i : ℕ, ∀ a : Fin n → K, (MvPolynomial.eval a) (((MvPolynomial.finSuccEquiv K n) f).coeff i) = 0 := by
      intro i a; specialize h_poly_zero a; replace h_poly_zero := congr_arg ( fun p => Polynomial.coeff p i ) h_poly_zero; aesop;
    -- By the induction hypothesis, each coefficient of $f(a, Y)$ must be zero.
    have h_coeff_zero_ind : ∀ i : ℕ, (((MvPolynomial.finSuccEquiv K n) f).coeff i) = 0 := by
      exact fun i => ih _ ( lt_of_le_of_lt ( MvPolynomial.totalDegree_coeff_finSuccEquiv_le _ _ ) hdeg ) fun a => h_coeff_zero i a;
    exact MvPolynomial.finSuccEquiv K n |>.injective ( Polynomial.ext fun i => by simpa using h_coeff_zero_ind i )

end