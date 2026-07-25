/-
# Affine Line Restriction of Multivariate Polynomials

Given a multivariate polynomial f and an affine line x + t*v in K^n,
we define the restriction of f to this line as a univariate polynomial in t,
and prove that its degree is bounded by the total degree of f.
-/
import Mathlib

open MvPolynomial Polynomial

noncomputable section

/-- Restrict a multivariate polynomial to an affine line `x + t • v`,
producing a univariate polynomial in t. Defined by substituting
`X_i ↦ x_i + v_i * T` into f. -/
def restrictAffineLine
    {K : Type*} [CommRing K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (x v : Fin n → K) : Polynomial K :=
  MvPolynomial.aeval (fun i => Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) f

/-- Evaluating the restriction at t gives the same result as evaluating
the original polynomial at the point `fun i => x i + v i * t`. -/
theorem eval_restrictAffineLine
    {K : Type*} [CommRing K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (x v : Fin n → K)
    (t : K) :
    Polynomial.eval t (restrictAffineLine f x v)
      = MvPolynomial.eval (fun i => x i + v i * t) f := by
  unfold restrictAffineLine
  simp only [MvPolynomial.aeval_def]
  change (Polynomial.evalRingHom t) (MvPolynomial.eval₂ (algebraMap K K[X])
    (fun i => Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) f) = _
  rw [MvPolynomial.eval₂_comp_left (Polynomial.evalRingHom t)]
  have h1 : (evalRingHom t).comp (algebraMap K K[X]) = RingHom.id K := by
    ext a; simp
  rw [h1]
  congr 1
  ext i
  simp [Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C, Polynomial.eval_X,
    Function.comp]

/-- Evaluating the restriction at t gives the same result as evaluating
the original polynomial at `x + t • v`. -/
theorem eval_restrictAffineLine'
    {K : Type*} [CommRing K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (x v : Fin n → K)
    (t : K) :
    Polynomial.eval t (restrictAffineLine f x v)
      = MvPolynomial.eval (x + t • v) f := by
  have h : (fun i : Fin n => x i + v i * t) = (x + t • v) := by
    ext i; simp [Pi.add_apply, Pi.smul_apply, smul_eq_mul]; ring
  unfold restrictAffineLine
  simp only [MvPolynomial.aeval_def]
  change (Polynomial.evalRingHom t) (MvPolynomial.eval₂ (algebraMap K K[X])
    (fun i => Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) f) = _
  rw [MvPolynomial.eval₂_comp_left (Polynomial.evalRingHom t)]
  have h1 : (evalRingHom t).comp (algebraMap K K[X]) = RingHom.id K := by
    ext a; simp
  rw [h1, MvPolynomial.eval₂_id]
  show (MvPolynomial.eval (Polynomial.eval t ∘ (fun i => Polynomial.C (x i) +
    Polynomial.C (v i) * Polynomial.X))) f = _
  have h2 : (Polynomial.eval t ∘ (fun i : Fin n => Polynomial.C (x i) +
    Polynomial.C (v i) * Polynomial.X)) = (fun i => x i + v i * t) := by
    ext i; simp [Polynomial.eval_add, Polynomial.eval_mul, Polynomial.eval_C, Polynomial.eval_X]
  rw [h2, h]

/-- The degree of the affine line restriction does not exceed the total degree. -/
theorem natDegree_restrictAffineLine_le_totalDegree
    {K : Type*} [CommRing K]
    {n : ℕ}
    (f : MvPolynomial (Fin n) K)
    (x v : Fin n → K) :
    (restrictAffineLine f x v).natDegree ≤ f.totalDegree := by
  have h_monomial_bound : ∀ m ∈ f.support, Polynomial.natDegree (Polynomial.C (f.coeff m) *
    ∏ i, (Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) ^ m i) ≤ f.totalDegree := by
    intro m hm
    refine le_trans (Polynomial.natDegree_C_mul_le _ _)
      (le_trans (Polynomial.natDegree_prod_le _ _) ?_)
    refine le_trans ?_ (Finset.le_sup hm)
    refine le_trans (Finset.sum_le_sum fun i _ => Polynomial.natDegree_pow_le) ?_
    simp +decide [Finsupp.sum_fintype]
    exact Finset.sum_le_sum fun i _ =>
      mul_le_of_le_one_right (Nat.zero_le _)
        (by by_cases hi : v i = 0 <;> simp +decide [hi])
  have h_restrict : restrictAffineLine f x v = ∑ m ∈ f.support, Polynomial.C (f.coeff m) *
    ∏ i, (Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) ^ m i := by
    convert MvPolynomial.aeval_eq_eval₂Hom _ _
    conv_rhs => rw [MvPolynomial.as_sum f]
    simp +decide [MvPolynomial.monomial_eq, Polynomial.eval₂_finset_sum]
  exact h_restrict ▸ le_trans (Polynomial.natDegree_sum_le _ _) (Finset.sup_le h_monomial_bound)

end