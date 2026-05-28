/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Leaf Witnesses: Definitions

This file introduces the core definitions for the theory of **tropical leaf witnesses**,
which connects Lorentzian polynomial theory, valued-field tropicalization, and spectral
witness detection.

## Key Idea

For a multivariate polynomial `p` over a valued field, the **derivative leaf** `L_A`
(obtained by differentiating in variables outside a subset `A`) admits a
**tropicalization** whose coefficient valuations define a finite combinatorial invariant.
This invariant — the **tropical leaf witness** — provides an upper bound on the
logarithm of the spectral witness attached to `L_A`, replacing an analytic certification
problem by a polyhedral/combinatorial computation.

## Main Definitions

* `derivativeLeaf` — iterated partial derivative over complement of a variable subset
* `tropCoeff` — tropicalization of a single coefficient via a valuation
* `coeffAbsSum` — sum of absolute values of coefficients (L¹ coefficient norm)
* `tropicalLeafWitness` — the tropical witness: coefficient L¹ norm of a derivative leaf
* `TropicalLeafData` — bundled tropical data extracted from a derivative leaf
* `derivativeFace` — exponent translation for Newton polytope monotonicity
* `tropicalMixedHessian` — tropical analogue of the mixed Hessian
* `IsSubmodularOn` — submodularity of a set function on finsets
-/

open Finset BigOperators Matrix MvPolynomial Finsupp

noncomputable section

/-! ## §1. Derivative Leaf -/

/-- The **derivative leaf** of a multivariate polynomial `p` with respect to a subset `s`
    of variable indices. Obtained by differentiating `p` once in each variable NOT in `s`:
    `L_s(x) = (∏_{i ∉ s} ∂_i) p(x)`.

    The derivative leaf captures the "marginal polynomial geometry" of subsystem `s`.
    When `p` is Lorentzian, the leaf inherits constrained spectral properties. -/
def derivativeLeaf {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) : MvPolynomial (Fin n) ℝ :=
  ((Finset.univ \ s).toList).foldr (fun i q => MvPolynomial.pderiv i q) p

/-! ## §2. Tropical Coefficient and Tropicalization -/

/-- **Tropical coefficient** via a valuation `v : K → WithTop ℝ`.
    For a polynomial `p` and exponent vector `d`, the tropical coefficient is
    the valuation of the coefficient of the monomial `x^d` in `p`.

    In tropical geometry, this transforms multiplicative coefficient data into
    additive (min-plus or max-plus) structure. -/
def tropCoeff {σ K : Type*} [CommSemiring K] [DecidableEq σ]
    (v : K → WithTop ℝ) (p : MvPolynomial σ K) (d : σ →₀ ℕ) : WithTop ℝ :=
  v (MvPolynomial.coeff d p)

/-- The **tropical support** of a polynomial under a valuation:
    the set of exponent vectors whose coefficient has finite (non-⊤) valuation.
    This is the combinatorial shadow of the Newton polytope in tropical geometry. -/
def tropSupport {σ K : Type*} [CommSemiring K] [DecidableEq σ]
    (v : K → WithTop ℝ) (p : MvPolynomial σ K) : Finset (σ →₀ ℕ) :=
  p.support.filter (fun d => tropCoeff v p d ≠ ⊤)

/-! ## §3. Coefficient Norms -/

/-- **Sum of absolute values of coefficients** (L¹ coefficient norm).
    This is the simplest effective upper bound for polynomial evaluation
    at points with coordinates bounded by 1.

    For a polynomial `p = ∑ cₐ x^α`, we have `‖p‖₁ = ∑ |cₐ|`. -/
def coeffAbsSum {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : ℝ :=
  ∑ d ∈ p.support, |MvPolynomial.coeff d p|

/-- **Maximum absolute coefficient** (L∞ coefficient norm).
    The tropical analogue: the "widest" coefficient valuation. -/
def coeffSupNorm {σ : Type*} [DecidableEq σ]
    (p : MvPolynomial σ ℝ) : ℝ :=
  if h : p.support.Nonempty
  then p.support.sup' h (fun d => |MvPolynomial.coeff d p|)
  else 0

/-! ## §4. Tropical Leaf Witness -/

/-- The **tropical leaf witness** for a polynomial `p` and subsystem `A`.
    Defined as the sum of tropical mixed Hessian diagonal entries of the
    derivative leaf, i.e., `∑_{a ∈ A} ‖∂²L_A/∂x_a²‖₁`.

    The tropical leaf witness is a finite, computable invariant that provides
    an upper bound on the spectral witness of the derivative leaf. It replaces
    an analytic/spectral certification problem by a combinatorial computation.

    **Key property**: `leafWitness(p, A) ≤ tropicalLeafWitness(p, A)`. -/
def tropicalLeafWitness {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) : ℝ :=
  ∑ a : A, coeffAbsSum
    (MvPolynomial.pderiv (↑a) (MvPolynomial.pderiv (↑a) (derivativeLeaf p A)))

/-- Bundled **tropical leaf data** for a derivative leaf.
    Contains the tropical support, coefficient norm, and support cardinality. -/
structure TropicalLeafData (σ : Type*) [DecidableEq σ] where
  /-- The support of the tropicalized derivative leaf -/
  support : Finset (σ →₀ ℕ)
  /-- The L¹ coefficient norm (tropical witness value) -/
  witnessValue : ℝ
  /-- The L∞ coefficient norm (max coefficient magnitude) -/
  maxCoeff : ℝ
  /-- The support cardinality -/
  supportCard : ℕ
  /-- witnessValue is nonneg -/
  witnessValue_nonneg : 0 ≤ witnessValue

/-- Extract tropical leaf data from a polynomial and subsystem. -/
def tropicalDerivativeLeafData {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) : TropicalLeafData (Fin n) where
  support := (derivativeLeaf p A).support
  witnessValue := tropicalLeafWitness p A
  maxCoeff := coeffSupNorm (derivativeLeaf p A)
  supportCard := (derivativeLeaf p A).support.card
  witnessValue_nonneg := by
    unfold tropicalLeafWitness coeffAbsSum
    apply Finset.sum_nonneg
    intro a _
    apply Finset.sum_nonneg
    intros; exact abs_nonneg _

/-! ## §5. Derivative Face and Newton Polytope Monotonicity -/

/-- **Derivative face**: the exponent translation that Newton polytopes undergo
    when passing from `L_A` to `L_B` for `A ⊆ B`.

    When differentiating additionally in variables `B \ A`, each differentiation
    reduces the exponent in that variable by 1. The Newton support of `L_B` is
    contained in the support of `L_A` translated by `-χ_{B\A}`. -/
def derivativeFace {σ : Type*} [DecidableEq σ]
    (A B : Finset σ) (S : Finset (σ →₀ ℕ)) : Finset (σ →₀ ℕ) :=
  S.image (fun d => d - (B \ A).sum (fun i => Finsupp.single i 1))

/-! ## §6. Tropical Mixed Hessian -/

/-- The **tropical mixed Hessian** of a polynomial `p` at subsystem indices `i, j`.
    This is the tropical (additive) analogue of the classical mixed Hessian:
    instead of evaluating `∂²p/∂xᵢ∂xⱼ` at a point, we take the sum of absolute
    values of coefficients of the second partial derivative.

    The tropical mixed Hessian captures curvature information in a
    combinatorially accessible form. -/
def tropicalMixedHessian {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) : ℝ :=
  coeffAbsSum (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))

/-- The **tropical Hessian matrix** of a polynomial, as a matrix indexed by `Fin n`.
    Entry `(i,j)` is the tropical mixed Hessian `‖∂²p/∂xᵢ∂xⱼ‖₁`. -/
def tropicalHessianMatrix {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => tropicalMixedHessian p i j

/-! ## §7. Spectral Witness Proxy -/

/-- The **mixed Hessian at ones** for a polynomial `p` restricted to a subsystem `s`.
    Entry `(i,j)` is `eval_1(∂²p/∂xᵢ∂xⱼ)`: the second mixed partial
    derivative evaluated at the all-ones point. -/
def mixedHessianAtOnes {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) : Matrix s s ℝ :=
  fun ⟨i, _⟩ ⟨j, _⟩ =>
    MvPolynomial.eval (fun _ => (1 : ℝ)) (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))

/-- The **positive spectral witness proxy** via trace.
    For a symmetric matrix with at most one positive eigenvalue (Lorentzian),
    `max(tr(M), 0)` is a coarse but computable measure of positive spectral content. -/
def positiveSpectralWitnessProxy {ι : Type*} [Fintype ι]
    (M : Matrix ι ι ℝ) : ℝ :=
  max M.trace 0

/-- The **leaf witness** for multipartite correlation detection.
    Combines derivative leaf and mixed Hessian to produce a single real number
    measuring the spectral content of the subsystem. -/
def leafWitness {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) : ℝ :=
  positiveSpectralWitnessProxy
    (mixedHessianAtOnes (derivativeLeaf p A) A)

/-! ## §8. Submodularity -/

/-- A set function `f : Finset α → ℝ` is **submodular** if it satisfies the
    diminishing returns inequality:
    `f(A) + f(B) ≥ f(A ∩ B) + f(A ∪ B)` for all finite sets `A, B`. -/
def IsSubmodularOn {α : Type*} [DecidableEq α]
    (f : Finset α → ℝ) : Prop :=
  ∀ A B : Finset α, f A + f B ≥ f (A ∩ B) + f (A ∪ B)

/-! ## §9. DPP Tropical Leaf Witness -/

/-- For a DPP kernel matrix `K`, the **DPP generating polynomial**
    `det(I + diag(x)·K)` has coefficients that are principal minors.
    The tropical leaf witness therefore captures valuation data of minors. -/
def dppTropicalLeafWitness {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (A : Finset (Fin n)) : ℝ :=
  tropicalLeafWitness
    (Matrix.det (1 + Matrix.diagonal (fun i => (MvPolynomial.X i : MvPolynomial (Fin n) ℝ)) *
      K.map MvPolynomial.C)) A

/-! ## §10. Valuative Leaf Upper Bound -/

/-- **Valuative leaf upper bound**: the proposition that the tropical leaf witness
    bounds the spectral witness from above.
    This is the central inequality of the tropical-spectral bridge. -/
def ValuativeLeafUpperBound {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)) : Prop :=
  leafWitness p A ≤ tropicalLeafWitness p A

end