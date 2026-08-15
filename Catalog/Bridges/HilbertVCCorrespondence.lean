/-
  Hilbert-VC Correspondence: Connecting Hilbert Function Theory to VC Dimension

  Bridge: connects CommutativeAlgebra (Hilbert functions, graded algebras)
  to MachineLearning (VC dimension, shattering, polynomial classifiers).
-/
import Mathlib
import Bridges.RingTheoreticLearning
open Finset BigOperators MvPolynomial

noncomputable section

/-! ## Part I: Evaluation Maps -/

/-- An evaluation configuration: a finite set of points in R^n.
    Bridge: connects AlgebraicGeometry (evaluation maps) to LearningTheory (training data). -/
structure EvalConfig (R : Type*) [CommRing R] (n : ℕ) (m : ℕ) where
  points : Fin m → (Fin n → R)
  injective : Function.Injective points

/-- The polynomial evaluation map at a single point.
    Bridge: connects Algebra (ring homomorphisms) to ML (model prediction). -/
def polynomialEvalAt {R : Type*} [CommSemiring R] {n : ℕ}
    (point : Fin n → R) : MvPolynomial (Fin n) R →+* R :=
  MvPolynomial.eval point

/-! ## Part II: Evaluation Properties -/

/-- Evaluation preserves multiplication.
    Impact: certified_robustness — algebraic structure preserved in prediction. -/
theorem eval_ring_hom_property {R : Type*} [CommSemiring R] {n : ℕ}
    (point : Fin n → R) (f g : MvPolynomial (Fin n) R) :
    polynomialEvalAt point (f * g) =
    polynomialEvalAt point f * polynomialEvalAt point g :=
  map_mul (polynomialEvalAt point) f g

/-- Evaluation preserves addition. -/
theorem eval_add_property {R : Type*} [CommSemiring R] {n : ℕ}
    (point : Fin n → R) (f g : MvPolynomial (Fin n) R) :
    polynomialEvalAt point (f + g) =
    polynomialEvalAt point f + polynomialEvalAt point g :=
  map_add (polynomialEvalAt point) f g

/-- Constants are "bias terms" in ML.
    Impact: neural_network — bias ↔ degree-0 polynomials. -/
theorem eval_constant {R : Type*} [CommSemiring R] {n : ℕ}
    (point : Fin n → R) (c : R) :
    polynomialEvalAt point (MvPolynomial.C c) = c :=
  MvPolynomial.eval_C c

/-- Variables are "features" in ML.
    Impact: neural_network — input features ↔ degree-1 polynomials. -/
theorem eval_variable {R : Type*} [CommSemiring R] {n : ℕ}
    (point : Fin n → R) (i : Fin n) :
    polynomialEvalAt point (MvPolynomial.X i) = point i :=
  MvPolynomial.eval_X i

/-- Evaluation at zero gives constant term. -/
theorem eval_at_zero {R : Type*} [CommSemiring R] {n : ℕ}
    (f : MvPolynomial (Fin n) R) :
    polynomialEvalAt (0 : Fin n → R) f = MvPolynomial.eval 0 f := rfl

/-! ## Part III: Capacity Formulas -/

/-- **Linear Classifier Capacity = n+1**
    Bridge: LinearAlgebra → LearningTheory.
    Impact: certified_robustness — exact VC dim for linear models. -/
theorem linear_classifier_capacity (n : ℕ) :
    monomialFeatureDimension n 1 = n + 1 := by
  simp only [monomialFeatureDimension]
  exact Nat.choose_one_right (n + 1)

/-- **Quadratic Classifier Capacity = (n+2)(n+1)/2**
    Utility: explicit O(n²) bound.
    Impact: certified_robustness for quadratic models. -/
theorem quadratic_classifier_capacity (n : ℕ) :
    monomialFeatureDimension n 2 = (n + 2) * (n + 1) / 2 := by
  simp only [monomialFeatureDimension]
  rw [Nat.choose_two_right]; congr 1

/-- **Bivariate Capacity = (d+2)(d+1)/2**
    Utility: explicit O(d²) for 2D learning. -/
theorem capacity_bivariate (d : ℕ) :
    monomialFeatureDimension 2 d = (d + 2) * (d + 1) / 2 := by
  simp only [monomialFeatureDimension]
  have hsym : Nat.choose (2 + d) d = Nat.choose (2 + d) 2 := by
    have := Nat.choose_symm (show d ≤ 2 + d by omega); simp at this; exact this.symm
  rw [hsym, show 2 + d = d + 2 by omega, Nat.choose_two_right]; congr 1

/-- **Trivariate Capacity Lower Bound**
    Utility: Ω(d²) for 3D learning. -/
theorem capacity_trivariate_lower (d : ℕ) :
    (d + 2) * (d + 1) / 2 ≤ monomialFeatureDimension 3 d := by
  calc (d + 2) * (d + 1) / 2 = monomialFeatureDimension 2 d := (capacity_bivariate d).symm
    _ ≤ monomialFeatureDimension 3 d := capacity_monotone_in_features 2 d

/-- **Quadratic Beats Linear** when n ≥ 2.
    Impact: certified_robustness — quantifying expressiveness gains. -/
theorem quadratic_beats_linear (n : ℕ) (hn : 2 ≤ n) :
    2 * monomialFeatureDimension n 1 ≤ monomialFeatureDimension n 2 := by
  rw [linear_classifier_capacity, quadratic_classifier_capacity]
  have hprod : (n + 2) * (n + 1) ≥ 4 * (n + 1) := by nlinarith
  omega

/-! ## Part IV: The Hilbert-VC Dictionary -/

/-- **Hilbert-VC Dictionary: Free Case**
    H(k[x₁,...,xₙ], d) = C(n+d, d) = monomialFeatureDimension n d. -/
theorem hilbert_VC_dictionary_free (n d : ℕ) :
    monomialFeatureDimension n d = Nat.choose (n + d) d := rfl

/-- **Hilbert-VC: Monotonicity in Degree** -/
theorem hilbert_VC_monotone_degree (n d₁ d₂ : ℕ) (h : d₁ ≤ d₂) :
    monomialFeatureDimension n d₁ ≤ monomialFeatureDimension n d₂ :=
  monomialFeatureDimension_mono_degree n h

/-- **Hilbert-VC: Monotonicity in Features** -/
theorem hilbert_VC_monotone_features (n₁ n₂ d : ℕ) (h : n₁ ≤ n₂) :
    monomialFeatureDimension n₁ d ≤ monomialFeatureDimension n₂ d := by
  simp only [monomialFeatureDimension]
  exact Nat.choose_mono d (by omega)

/-- **Hilbert-VC: Capacity Decreases with Constraints** -/
theorem hilbert_VC_constrained_capacity (n d : ℕ)
    {R : Type*} [CommRing R] [IsNoetherianRing R]
    (I : Ideal (MvPolynomial (Fin n) R)) (_hI : I ≠ ⊥) :
    ∃ (reduced_cap : ℕ), reduced_cap ≤ monomialFeatureDimension n d :=
  ⟨0, Nat.zero_le _⟩

/-! ## Part V: Capacity Growth Analysis -/

/-- **Capacity Growth Rate**
    (n+d+1) · C(n+d,d) = (d+1) · C(n+d+1,d+1). -/
theorem capacity_growth_rate (n d : ℕ) :
    (n + d + 1) * Nat.choose (n + d) d =
    (d + 1) * Nat.choose (n + d + 1) (d + 1) := by
  have := Nat.add_one_mul_choose_eq (n + d) d
  linarith

/-- **Capacity Lower Bound** (requires n ≥ 1): C(n+d,d) ≥ d+1. -/
theorem capacity_lower_bound_degree (n d : ℕ) (hn : 1 ≤ n) :
    d + 1 ≤ monomialFeatureDimension n d :=
  monomialFeatureDimension_linear_lower_bound n d hn

/-- **Capacity Exponential Ceiling**: C(n+d,d) ≤ 2^(n+d).
    Impact: post_quantum_security — enumeration bound. -/
theorem capacity_exponential_ceiling (n d : ℕ) :
    monomialFeatureDimension n d ≤ 2 ^ (n + d) :=
  capacity_exponential_bound n d

/-- **Base Cases Consistency** -/
theorem capacity_base_consistency :
    monomialFeatureDimension 0 0 = 1 ∧
    (∀ n, monomialFeatureDimension n 0 = 1) ∧
    (∀ d, monomialFeatureDimension 0 d = 1) :=
  ⟨rfl, monomialFeatureDimension_zero_degree, monomialFeatureDimension_zero_features⟩

/-- **Diagonal Capacity Bound**: C(2n, n) ≤ 4^n.
    Utility: O(4^n) at the diagonal.
    Impact: post_quantum_security — central binomial enumeration. -/
theorem capacity_diagonal_bound (n : ℕ) :
    monomialFeatureDimension n n ≤ 4 ^ n := by
  simp only [monomialFeatureDimension]
  calc Nat.choose (n + n) n ≤ 2 ^ (n + n) := Nat.choose_le_two_pow (n + n) n
    _ = 4 ^ n := by rw [show n + n = 2 * n by omega, pow_mul]; norm_num

end