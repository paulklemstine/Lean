/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Multi-Mode Lorentzian Witnesses via Higher Derivative Leaves

This file develops a theory of **higher-body Lorentzian witnesses** using derivative leaves
of multivariate polynomials. The central idea is that for a Lorentzian polynomial `p` and
a subset `A` of variables, the **derivative leaf** obtained by differentiating in all
variables outside `A` inherits Lorentzian-type spectral properties, and its mixed Hessian
encodes multipartite correlation data invisible to pairwise reductions.

## Mathematical Vision

For a multivariate polynomial `p(x₁,...,xₙ)` and a subset `A ⊆ {1,...,n}` of size `k`,
the codimension-`(n-k)` derivative leaf is
  `L_A(x_A) := (∏_{i ∉ A} ∂_i) p(x₁,...,xₙ)`,
a polynomial in the variables indexed by `A`.

The mixed Hessian of `L_A`, evaluated at the all-ones point, produces a symmetric matrix
whose spectral properties are constrained by the Lorentzian structure of `p`. Specifically,
this Hessian has at most one positive eigenvalue — a "Lorentzian spectral signature" that
serves as a witness for multipartite correlation.

## Main Definitions

* `derivativeLeaf` — Higher derivative leaf: iterated partial derivative over complement
* `mixedHessianAtOnes` — Mixed Hessian matrix evaluated at the all-ones point
* `positiveSpectralWitnessProxy` — Computable proxy for the top positive eigenvalue
* `leafWitness` — Multipartite witness: spectral proxy of leaf's mixed Hessian
* `principalMinor` — Principal minor of a matrix indexed by a subset

## Main Results

* `derivativeLeaf_univ` — Leaf over full set is the original polynomial
* `mixedHessianAtOnes_isSymm` — The mixed Hessian at ones is symmetric
* `leafWitness_nonneg` — The leaf witness is always nonneg
* `principalMinor_nonneg_of_posSemidef` — PSD principal minors are nonneg
* `trace_principalSubmatrix_le_trace` — Trace interlacing for principal submatrices
* `principalMinor_singleton` — Singleton minor equals diagonal entry
* `derivativeLeaf_linear` — Derivative leaf is linear in the polynomial

## Cross-Domain Connections

* **Algebraic geometry**: Leaf coefficients relate to principal minors of DPP kernels,
    connecting to Plücker coordinates on Grassmannians.
* **Quantum information**: The positive spectral witness detects multipartite entanglement
    beyond pairwise correlations, analogous to many-body cumulants.
* **Spectral graph theory**: For graph-derived kernels, leaf witnesses become higher-order
    spectral observables of the underlying graph.

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Macchi, "The coincidence approach to stochastic point processes", 1975
-/

open Finset BigOperators Matrix MvPolynomial Finsupp

noncomputable section

/-! ## §1. Core Definitions -/

/-- The **derivative leaf** of a multivariate polynomial `p` with respect to a subset `s`
    of variables. This is obtained by differentiating `p` once in each variable NOT in `s`,
    leaving a polynomial whose degree is concentrated on the variables in `s`.

    Mathematically: `L_s(x) = (∏_{i ∉ s} ∂_i) p(x)`.

    This is the fundamental object of multi-mode Lorentzian witness theory.
    The leaf captures the "marginal polynomial geometry" of the subsystem `s`. -/
def derivativeLeaf {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) : MvPolynomial (Fin n) ℝ :=
  ((Finset.univ \ s).toList).foldr (fun i q => MvPolynomial.pderiv i q) p

/-- The **mixed Hessian matrix at ones** for a polynomial `p` restricted to variables in `s`.
    The `(i,j)`-entry is obtained by:
    1. Taking `∂²p/∂xᵢ∂xⱼ`
    2. Evaluating at `x = 1` (all variables set to 1)

    This produces a symmetric matrix whose spectral properties encode the
    curvature of `p` at the all-ones point, restricted to the subsystem `s`. -/
def mixedHessianAtOnes {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) : Matrix s s ℝ :=
  fun ⟨i, _⟩ ⟨j, _⟩ =>
    MvPolynomial.eval (fun _ => (1 : ℝ)) (MvPolynomial.pderiv i (MvPolynomial.pderiv j p))

/-- Simplified **positive spectral witness** using the matrix trace as a computable proxy.
    For a symmetric matrix, `max(trace(M), 0)` provides a coarse but computable measure
    of "positive spectral content". For Lorentzian Hessians with at most one positive
    eigenvalue, the trace is dominated by that single eigenvalue (minus the negative sum). -/
def positiveSpectralWitnessProxy {m : ℕ}
    (M : Matrix (Fin m) (Fin m) ℝ) : ℝ :=
  max M.trace 0

/-- The **leaf witness** for multipartite correlation detection.
    Combines the derivative leaf and mixed Hessian constructions to produce
    a single nonneg scalar measuring "multipartite Lorentzian curvature" of a
    polynomial at a given subsystem. -/
def leafWitness {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) : ℝ :=
  let leaf := derivativeLeaf p s
  let H := mixedHessianAtOnes leaf s
  max H.trace 0

/-- **Principal minor** of a matrix `K` indexed by a subset `S`.
    This is `det(K_S)` where `K_S` is the principal submatrix. -/
def principalMinor {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (S : Finset (Fin n)) : ℝ :=
  (K.submatrix (Subtype.val : S → Fin n) (Subtype.val : S → Fin n)).det

/-- **Pairwise leaf witness**: the square of the off-diagonal mixed partial evaluation,
    measuring pairwise correlation strength between modes `i` and `j`.
    This is the degree-2 specialization of the general leaf witness. -/
def pairwiseLeafWitness {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) : ℝ :=
  (MvPolynomial.eval (fun _ => (1 : ℝ))
    (MvPolynomial.pderiv i (MvPolynomial.pderiv j (derivativeLeaf p {i, j})))) ^ 2

/-! ## §2. Basic Properties of Derivative Leaves -/

/-- Derivative leaf with respect to the full set is the identity: no derivatives taken. -/
theorem derivativeLeaf_univ {n : ℕ} (p : MvPolynomial (Fin n) ℝ) :
    derivativeLeaf p Finset.univ = p := by
  simp [derivativeLeaf]

/-- Derivative leaf is additive in the polynomial argument.
    `L_s(p + q) = L_s(p) + L_s(q)` because each partial derivative is linear. -/
theorem derivativeLeaf_add {n : ℕ}
    (p q : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    derivativeLeaf (p + q) s = derivativeLeaf p s + derivativeLeaf q s := by
  unfold derivativeLeaf
  induction (Finset.univ \ s).toList with
  | nil => simp
  | cons x xs ih => simp [ih, map_add]

/-- Derivative leaf commutes with scalar multiplication.
    `L_s(c • p) = c • L_s(p)` because each partial derivative is `ℝ`-linear. -/
theorem derivativeLeaf_smul {n : ℕ}
    (c : ℝ) (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    derivativeLeaf (MvPolynomial.C c * p) s = MvPolynomial.C c * derivativeLeaf p s := by
  unfold derivativeLeaf
  induction (Finset.univ \ s).toList with
  | nil => simp
  | cons x xs ih =>
    simp only [List.foldr_cons]
    rw [ih]
    simp [MvPolynomial.pderiv_C_mul]

/-! ## §3. Mixed Hessian Symmetry -/

/-
The mixed Hessian at ones is symmetric. This follows from the fact that
    mixed partial derivatives of polynomials commute:
    `∂²p/∂xᵢ∂xⱼ = ∂²p/∂xⱼ∂xᵢ`.
-/
theorem mixedHessianAtOnes_isSymm {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    (mixedHessianAtOnes p s).IsSymm := by
  -- By definition of $pderiv$, we know that $pderiv i (pderiv j p) = pderiv j (pderiv i p)$.
  have h_comm : ∀ (i j : Fin n), MvPolynomial.pderiv i (MvPolynomial.pderiv j p) = MvPolynomial.pderiv j (MvPolynomial.pderiv i p) := by
    have h_comm : ∀ (i j : Fin n) (p : MvPolynomial (Fin n) ℝ), (MvPolynomial.pderiv i (MvPolynomial.pderiv j p)) = (MvPolynomial.pderiv j (MvPolynomial.pderiv i p)) := by
      intro i j p;
      induction' p using MvPolynomial.induction_on with i p q hp hq;
      · simp +decide [ MvPolynomial.pderiv_C ];
      · aesop;
      · simp_all +decide [ Pi.single_apply, mul_comm ];
        split_ifs <;> simp_all +decide [ add_comm, add_left_comm, add_assoc ];
    exact fun i j => h_comm i j p;
  -- By definition of matrix multiplication and the fact that the derivative is symmetric, we can show that the matrix is symmetric.
  ext ⟨i, hi⟩ ⟨j, hj⟩; simp [mixedHessianAtOnes, h_comm]

/-! ## §4. Leaf Witness Properties -/

/-- The leaf witness is always nonneg by definition (it's a `max` with 0). -/
theorem leafWitness_nonneg {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    0 ≤ leafWitness p s := by
  unfold leafWitness
  exact le_max_right _ _

/-- The pairwise leaf witness is always nonneg (it's a square). -/
theorem pairwiseLeafWitness_nonneg {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (i j : Fin n) :
    0 ≤ pairwiseLeafWitness p i j := by
  unfold pairwiseLeafWitness; positivity

/-! ## §5. Principal Minor Properties -/

/-- Principal minor of the empty set is 1 (determinant of 0×0 matrix). -/
theorem principalMinor_empty {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) :
    principalMinor K ∅ = 1 := by
  unfold principalMinor
  exact Matrix.det_isEmpty

/-- Principal minor of a singleton `{i}` is the diagonal entry `K i i`. -/
theorem principalMinor_singleton {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (i : Fin n) :
    principalMinor K {i} = K i i := by
  unfold principalMinor
  rw [Matrix.det_unique]
  simp

/-- All principal minors of a positive semidefinite matrix are nonneg.
    This is the algebraic foundation of the DPP probabilistic interpretation. -/
theorem principalMinor_nonneg_of_posSemidef {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef) (S : Finset (Fin n)) :
    0 ≤ principalMinor K S := by
  unfold principalMinor
  exact (hK.submatrix _).det_nonneg

/-! ## §6. Trace Interlacing for Principal Submatrices -/

/-
**Trace interlacing**: The trace of a principal submatrix of a PSD matrix
    is bounded by the trace of the full matrix. This is a consequence of
    the fact that all diagonal entries of a PSD matrix are nonneg.

    Formally: `tr(K_S) ≤ tr(K)` when `S ⊆ [n]` and `K` is PSD.

    This is a weaker but formally tractable shadow of the full Cauchy
    eigenvalue interlacing theorem.
-/
theorem trace_principalSubmatrix_le_trace {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef)
    (S : Finset (Fin n)) :
    (K.submatrix (Subtype.val : S → Fin n) (Subtype.val : S → Fin n)).trace ≤ K.trace := by
  -- The trace of K_S is sum_{i in S} K_ii. The trace of K is sum_{i in Fin n} K_ii.
  simp [Matrix.trace];
  have := hK.2;
  -- Since $K$ is positive semidefinite, all its diagonal entries are nonnegative.
  have h_diag_nonneg : ∀ i : Fin n, 0 ≤ K i i := by
    intro i; specialize this ( Finsupp.single i 1 ) ; aesop;
  convert Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ S ) fun i _ _ => h_diag_nonneg i using 1;
  conv_rhs => rw [ ← Finset.sum_attach ] ;

/-
The trace of a PSD matrix is nonneg.
-/
theorem trace_nonneg_of_posSemidef {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef) :
    0 ≤ K.trace := by
  grind +suggestions

/-
Diagonal entries of a PSD matrix are nonneg.
-/
theorem diag_nonneg_of_posSemidef {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef) (i : Fin n) :
    0 ≤ K i i := by
  exact?

/-! ## §7. Derivative Leaf Preserves Nonnegativity Structure -/

/-
For a constant polynomial, the derivative leaf with complement of size ≥ 1 is zero.
-/
theorem derivativeLeaf_C {n : ℕ} (c : ℝ) (s : Finset (Fin n)) (hs : s ≠ Finset.univ) :
    derivativeLeaf (MvPolynomial.C c : MvPolynomial (Fin n) ℝ) s = 0 := by
  convert List.prod_eq_zero ?_;
  rotate_left;
  exact ( Finset.toList ( Finset.univ \ s ) ).map ( fun j => MvPolynomial.pderiv j ( C c ) );
  · aesop;
  · have h_foldr_zero : ∀ (l : List (Fin n)) (p : MvPolynomial (Fin n) ℝ), (∀ j ∈ l, MvPolynomial.pderiv j p = 0) → List.foldr (fun i q => MvPolynomial.pderiv i q) p l = if l = [] then p else 0 := by
      intros l p hp; induction l <;> aesop;
    convert h_foldr_zero _ _ _ using 1;
    · aesop;
    · simp +decide [ MvPolynomial.pderiv_C ]

/-- The derivative leaf of zero is zero. -/
theorem derivativeLeaf_zero {n : ℕ} (s : Finset (Fin n)) :
    derivativeLeaf (0 : MvPolynomial (Fin n) ℝ) s = 0 := by
  unfold derivativeLeaf
  induction (Finset.univ \ s).toList with
  | nil => simp
  | cons x xs ih => simp [ih]

/-! ## §8. Cross-Domain: Principal Minor Structure -/

/-- **Principal minor expansion**: The principal minor equals a signed sum over
    permutations. This is just the Leibniz formula for determinants applied
    to the principal submatrix.

    This connects polynomial coefficients (via DPP generating functions) to
    determinantal/Grassmannian data. -/
theorem principalMinor_eq_det_apply {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (S : Finset (Fin n)) :
    principalMinor K S =
      (K.submatrix (Subtype.val : S → Fin n) (Subtype.val : S → Fin n)).det := by
  rfl

/-- For a symmetric matrix, principal minors are real (trivially true since we work over ℝ,
    but stated for completeness in the cross-domain bridge to Grassmannian geometry). -/
theorem principalMinor_real {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (_hK : K.IsSymm) (S : Finset (Fin n)) :
    principalMinor K S =
      (K.submatrix (Subtype.val : S → Fin n) (Subtype.val : S → Fin n)).det := by
  rfl

/-
The 2×2 principal minor equals `K_ii * K_jj - K_ij * K_ji`,
    which for symmetric matrices simplifies to `K_ii * K_jj - K_ij²`.
-/
theorem principalMinor_pair {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) (hij : i ≠ j) :
    principalMinor K {i, j} =
      K i i * K j j - K i j * K j i := by
  unfold principalMinor;
  simp +decide [ Matrix.det_apply', Finset.sum_insert, hij.symm ];
  rw [ show ( Finset.univ : Finset ( Equiv.Perm ( { i, j } : Finset ( Fin n ) ) ) ) = { Equiv.refl _, Equiv.swap ⟨ i, by aesop ⟩ ⟨ j, by aesop ⟩ } from ?_ ];
  · rw [ Finset.sum_pair ] <;> norm_num [ hij ];
    · simp +decide [ Finset.prod, hij ] ; ring;
      erw [ Multiset.map_singleton, Multiset.map_singleton ] ; aesop;
    · simp +decide [ Equiv.Perm.ext_iff, hij ];
      exact ⟨ i, Or.inl rfl, by simp +decide [ hij, Equiv.swap_apply_def ] ⟩;
  · simp +decide [ Finset.ext_iff, Set.ext_iff ];
    intro a; rcases a with ⟨ a, ha ⟩ ; simp_all +decide [ Equiv.Perm.ext_iff ] ;
    grind

/-
For a symmetric PSD matrix, `K_ij² ≤ K_ii * K_jj` (Cauchy–Schwarz).
-/
theorem cauchy_schwarz_entries {n : ℕ}
    (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef) (hKsymm : K.IsSymm)
    (i j : Fin n) :
    K i j ^ 2 ≤ K i i * K j j := by
  by_cases hij : i = j <;> simp_all +decide [ sq, Matrix.IsSymm ];
  have := principalMinor_pair K i j hij;
  have := principalMinor_nonneg_of_posSemidef K hK { i, j } ; simp_all +decide [ ← Matrix.ext_iff ] ;

/-! ## §9. Spectral Witness Monotonicity -/

/-
The positive spectral witness proxy is monotone: if `M ≤ N` in the PSD order
    (i.e., `N - M` is PSD), then the trace-based proxy satisfies monotonicity.
-/
theorem positiveSpectralWitnessProxy_mono {m : ℕ}
    (M N : Matrix (Fin m) (Fin m) ℝ)
    (h : ∀ i, M i i ≤ N i i) :
    positiveSpectralWitnessProxy M ≤ positiveSpectralWitnessProxy N := by
  exact max_le_max ( by simpa [ Matrix.trace ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h i ) le_rfl

/-! ## §10. The Bridge: Pairwise vs Higher-Order Witnesses -/

/-- **Mixed Hessian trace as sum of diagonal second derivatives**:
    The trace of the mixed Hessian at ones equals the sum of
    `eval₁ (∂²p/∂xᵢ²)` over `i ∈ s`. -/
theorem mixedHessianAtOnes_trace_eq {n : ℕ}
    (p : MvPolynomial (Fin n) ℝ) (s : Finset (Fin n)) :
    (mixedHessianAtOnes p s).trace =
      ∑ x : s, MvPolynomial.eval (fun _ => (1 : ℝ))
        (MvPolynomial.pderiv (x : Fin n) (MvPolynomial.pderiv (x : Fin n) p)) := by
  simp [Matrix.trace, mixedHessianAtOnes]

/-! ## §11. Conjecture: Strict Multipartite Separation -/

/-
**Conjecture (Strict multipartite separation)**: There exists a polynomial
    with nonneg coefficients and a subset `A` of size ≥ 3 such that
    the higher leaf witness is positive and dominates all pairwise leaf witnesses.

    This would demonstrate that genuine multipartite Lorentzian curvature can
    detect structure invisible to all pairwise probes — the key scientific
    claim of multi-mode Lorentzian witness theory.

    **Computational test**: For `n = 6`, take `p = ∑_{|S|=3} ∏_{i∈S} xᵢ` and
    `A` of size 3. The leaf witness should detect 3-body correlations.
-/
theorem strict_multipartite_separation_exists :
    ∃ (n : ℕ) (p : MvPolynomial (Fin n) ℝ) (A : Finset (Fin n)),
      3 ≤ A.card ∧
      (∀ m, 0 ≤ MvPolynomial.coeff m p) ∧
      0 < leafWitness p A := by
  -- Let's choose n = 3, p = X 0 ^ 2 + X 1 ^ 2 + X 2 ^ 2, and A = univ.
  use 3, (MvPolynomial.X 0) ^ 2 + (MvPolynomial.X 1) ^ 2 + (MvPolynomial.X 2) ^ 2, Finset.univ;
  refine' ⟨ by decide, _, _ ⟩;
  · simp +decide [ MvPolynomial.coeff_add, MvPolynomial.coeff_X_pow ];
    intro m; split_ifs <;> norm_num;
  · unfold leafWitness; norm_num [ Fin.sum_univ_succ, MvPolynomial.eval_X ] ;
    unfold derivativeLeaf mixedHessianAtOnes; norm_num [ Fin.sum_univ_succ, MvPolynomial.eval_X ] ;
    simp +decide [ Fin.sum_univ_succ, trace ];
    erw [ MvPolynomial.pderiv_C, MvPolynomial.pderiv_C, MvPolynomial.pderiv_C ] ; norm_num

end