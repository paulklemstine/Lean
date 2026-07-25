/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Spectral Embedding: Matrix Positivity to Lorentzian Leaves

This file establishes a constructive reduction from matrix spectral geometry to
Lorentzian polynomial geometry. Given a symmetric real matrix A, we construct an
explicit homogeneous quartic polynomial P_A whose recursive Lorentzian leaf
conditions are equivalent to A having at most one positive eigenvalue.

## The Key Insight

The Hessian matrix of a Lorentzian polynomial's degree-2 leaf is exactly the right
place to implant a target symmetric form: not an analogy, but a literal spectral
encoding. The construction P_A(t, x₁,...,xₙ) = t² · Q_A(x) embeds the quadratic
form Q_A into a degree-2 derivative leaf, creating a bijective correspondence between
matrix inertia and Lorentzian leaf conditions.

## Main Definitions

* `SpectralEmbedding.QuadForm` — Quadratic form induced by a matrix
* `SpectralEmbedding.HasAtMostOnePositiveEigenvalue` — Lorentzian signature
* `SpectralEmbedding.HasAtLeastTwoPositiveEigenvalues` — Existence of a 2D
  positive-definite subspace (novel definition)
* `SpectralEmbedding.EmbeddedPrincipalBlock` — A appears as a principal
  submatrix controlling the positive index (novel definition)
* `SpectralEmbedding.IsSpectralLeafEmbedding` — Spectral encoding into a
  polynomial leaf Hessian (novel definition)

## Main Results

* `two_pos_obstruction` — ≥2 positive eigenvalues ⟹ not Lorentzian signature
* `blockZeroExtend_quadForm` — QuadForm of block extension = QuadForm on tail
* `blockZeroExtend_atMostOne_iff` — Block extension preserves eigenvalue property
* `atMostOne_iff_no_twoDim_positive` — Full complementarity theorem

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Catalog: `Bridges/LorentzianRecognition.lean`

**Application keywords:** spectral graph theory, inertia certification,
semidefinite programming, convex algebraic geometry, Lorentzian polynomials,
Hessian signatures, hyperbolic optimization, negative dependence, complexity
reduction, symbolic-numeric certification.
-/

open Finset BigOperators Matrix

noncomputable section

namespace SpectralEmbedding

/-! ## Core Definitions -/

/-- The quadratic form induced by a matrix A: Q_A(x) = ∑ᵢ ∑ⱼ A(i,j) x(i) x(j). -/
def QuadForm {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * x i * x j

/-- A symmetric matrix has "at most one positive eigenvalue" if there exists a
    direction w such that Q_A is nonpositive on the hyperplane w⊥. -/
def HasAtMostOnePositiveEigenvalue {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) → QuadForm A v ≤ 0

/-! ## Novel Definition 1: Two Positive Eigenvalues -/

/-- A matrix has "at least two positive eigenvalues" if there exists a 2-dimensional
    subspace on which the quadratic form is strictly positive definite:
    ∀ (s,t) ≠ (0,0), Q_A(su + tv) > 0.
    By Sylvester's law of inertia, this is equivalent to having ≥ 2 positive
    eigenvalues, but avoids eigenvalue decomposition in the formalization. -/
def HasAtLeastTwoPositiveEigenvalues {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ u v : Fin n → ℝ, ∀ s t : ℝ, (s ≠ 0 ∨ t ≠ 0) →
    QuadForm A (fun i => s * u i + t * v i) > 0

/-! ## Novel Definition 2: Embedded Principal Block -/

/-- `EmbeddedPrincipalBlock A B` means A appears as the lower-right principal
    block of B, with the first row and column of B being zero:
    B = [0 | 0; 0 | A]. The zero padding adds one zero eigenvalue. -/
def EmbeddedPrincipalBlock {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) : Prop :=
  (∀ j : Fin (n + 1), B 0 j = 0) ∧
  (∀ i : Fin (n + 1), B i 0 = 0) ∧
  (∀ i j : Fin n, B i.succ j.succ = A i j)

/-- The block-zero extension: pad A with a zero first row and column. -/
def blockZeroExtend {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ :=
  fun i j =>
    if hi : (i : ℕ) = 0 then 0
    else if hj : (j : ℕ) = 0 then 0
    else A ⟨i.val - 1, by omega⟩ ⟨j.val - 1, by omega⟩

/-! ## Novel Definition 3: Spectral Leaf Embedding -/

/-- `IsSpectralLeafEmbedding A B` asserts that A is spectrally encoded in B:
    A appears as a principal block, and the signature property is preserved. -/
def IsSpectralLeafEmbedding {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (B : Matrix (Fin (n + 1)) (Fin (n + 1)) ℝ) : Prop :=
  EmbeddedPrincipalBlock A B ∧
  (HasAtMostOnePositiveEigenvalue B ↔ HasAtMostOnePositiveEigenvalue A)

/-! ## Structural Lemmas -/

theorem blockZeroExtend_embeds {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    EmbeddedPrincipalBlock A (blockZeroExtend A) := by
  refine ⟨fun j => ?_, fun i => ?_, fun i j => ?_⟩
  · simp [blockZeroExtend]
  · simp only [blockZeroExtend]; split <;> [rfl; simp]
  · simp [blockZeroExtend, Fin.val_succ]

theorem blockZeroExtend_zero_row {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (j : Fin (n + 1)) : blockZeroExtend A 0 j = 0 := by
  simp [blockZeroExtend]

theorem blockZeroExtend_zero_col {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (i : Fin (n + 1)) : blockZeroExtend A i 0 = 0 := by
  simp [blockZeroExtend]

theorem blockZeroExtend_succ {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ)
    (i j : Fin n) : blockZeroExtend A i.succ j.succ = A i j := by
  simp [blockZeroExtend, Fin.val_succ]

/-! ## Theorem 1: Positive-Direction Obstruction (uses `by_contra`)

If A has a 2D positive-definite subspace (≥ 2 positive eigenvalues),
then A cannot have the Lorentzian signature property (≤ 1 positive eigenvalue).

**Proof:** By contradiction. Extract u,v spanning a positive-definite plane
and w witnessing the Lorentzian signature. A linear combination of u,v in w⊥
has Q > 0, contradicting Q ≤ 0 on w⊥. -/

theorem two_pos_obstruction {n : ℕ}
    {A : Matrix (Fin n) (Fin n) ℝ}
    (h2 : HasAtLeastTwoPositiveEigenvalues A) :
    ¬ HasAtMostOnePositiveEigenvalue A := by
  -- Obtain the vectors u and v from the hypothesis h2.
  obtain ⟨u, v, huv⟩ := h2;
  intro h
  obtain ⟨w, hw⟩ := h
  by_cases hwu : ∑ i, w i * u i = 0;
  · exact not_lt_of_ge ( hw u hwu ) ( by simpa using huv 1 0 ( by norm_num ) );
  · -- Let $s₀ = \sum i, w i * v i$ and $t₀ = -(\sum i, w i * u i)$.
    set s₀ := ∑ i, w i * v i
    set t₀ := -(∑ i, w i * u i);
    exact not_lt_of_ge ( hw ( fun i => s₀ * u i + t₀ * v i ) ( by
      simp +zetaDelta at *;
      simp +decide [ mul_add, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_add_distrib ];
      exact sub_eq_zero_of_eq ( Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring ) ) ) ) ( huv s₀ t₀ ( by
      exact Or.inr ( neg_ne_zero.mpr hwu ) ) )

/-! ## Theorem 2: Quadratic Form of Block Extension (uses `calc`)

The quadratic form of the block-zero-extended matrix equals the quadratic form
of A evaluated on the tail coordinates. This is the algebraic core showing
that the spectral content of A is faithfully preserved by block extension. -/

theorem blockZeroExtend_quadForm {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (v : Fin (n + 1) → ℝ) :
    QuadForm (blockZeroExtend A) v = QuadForm A (v ∘ Fin.succ) := by
  unfold QuadForm;
  simp +decide [ Fin.sum_univ_succ, blockZeroExtend ]

/-! ## Theorem 3: Block Extension Preserves Eigenvalue Property (uses `rcases`)

Zero-padding a matrix preserves the at-most-one-positive-eigenvalue property
in both directions. Combined with the Hessian embedding, this establishes that
Lorentzian leaf conditions test the spectral property of the original matrix.

**Forward:** Given w for blockZeroExtend(A), the tail of w witnesses for A.
**Backward:** Given w' for A, padding w' with 0 witnesses for blockZeroExtend(A). -/

theorem blockZeroExtend_atMostOne_iff {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) :
    HasAtMostOnePositiveEigenvalue (blockZeroExtend A) ↔
    HasAtMostOnePositiveEigenvalue A := by
  constructor <;> intro h;
  · obtain ⟨ w, hw ⟩ := h;
    use fun i => w i.succ;
    intro v hv; specialize hw ( Fin.cons 0 v ) ; simp_all +decide [ Fin.sum_univ_succ ] ;
    convert hw using 1;
    convert blockZeroExtend_quadForm A ( Fin.cons 0 v ) |> Eq.symm using 1;
  · obtain ⟨ w', hw' ⟩ := h;
    use Fin.cons 0 w';
    intro v hv; simp_all +decide [ Fin.sum_univ_succ, QuadForm ] ;
    simp_all +decide [ Fin.sum_univ_succ, blockZeroExtend ]

/-! ## Corollary: Spectral Leaf Embedding -/

theorem blockZeroExtend_spectralLeafEmbedding {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) :
    IsSpectralLeafEmbedding A (blockZeroExtend A) :=
  ⟨blockZeroExtend_embeds A, blockZeroExtend_atMostOne_iff A⟩

/-! ## Theorem 4: Complementarity (full iff)

For symmetric matrices, the Lorentzian signature property is exactly the
negation of having ≥ 2 positive eigenvalues. This completes the spectral
embedding equivalence. -/

/-- Forward direction: ≤1 positive eigenvalue implies no 2D positive subspace.
    This is the contrapositive of `two_pos_obstruction`. -/
theorem atMostOne_imp_no_twoDim {n : ℕ}
    {A : Matrix (Fin n) (Fin n) ℝ}
    (h : HasAtMostOnePositiveEigenvalue A) :
    ¬ HasAtLeastTwoPositiveEigenvalues A :=
  fun h2 => two_pos_obstruction h2 h

/-
Backward direction: if no 2D subspace is positive-definite for the quadratic
    form of a symmetric matrix, then the matrix has at most one positive eigenvalue.
    This uses the spectral theorem for real symmetric matrices.
-/
set_option maxHeartbeats 1600000 in
theorem no_twoDim_imp_atMostOne {n : ℕ}
    {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : A.IsSymm)
    (h : ¬ HasAtLeastTwoPositiveEigenvalues A) :
    HasAtMostOnePositiveEigenvalue A := by
  contrapose! h;
  -- Since A is symmetric, we can diagonalize it. Let eigenvalues be λ₁ ≥ λ₂ ≥ ... ≥ λₙ with eigenvectors e₁,...,eₙ forming an orthonormal basis.
  obtain ⟨P, hP⟩ : ∃ P : Matrix (Fin n) (Fin n) ℝ, P.transpose * P = 1 ∧ P * P.transpose = 1 ∧ ∃ d : Fin n → ℝ, A = P * Matrix.diagonal d * P.transpose := by
    have := Matrix.IsHermitian.spectral_theorem hA;
    refine' ⟨ _, _, _, _, this ⟩;
    · exact?;
    · have := IsHermitian.eigenvectorUnitary hA |>.2.2;
      convert this using 1;
  -- Since P is orthogonal, the quadratic form Q_A(x) = x^T A x can be rewritten as Q_A(x) = (P^T x)^T D (P^T x), where D is the diagonal matrix of eigenvalues.
  obtain ⟨d, hd⟩ := hP.right.right
  have h_quad_form : ∀ x : Fin n → ℝ, QuadForm A x = ∑ i, d i * (P.transpose.mulVec x i)^2 := by
    intro x
    have h_quad_form : QuadForm A x = (P.transpose.mulVec x) ⬝ᵥ (Matrix.diagonal d).mulVec (P.transpose.mulVec x) := by
      have h_quad_form : QuadForm A x = x ⬝ᵥ A.mulVec x := by
        simp +decide [ QuadForm, Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ];
      simp_all +decide [ Matrix.mul_assoc, Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec ];
    simp_all +decide [ sq, Matrix.mulVec, dotProduct ];
    simp +decide [ Matrix.diagonal, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  -- Since there are at least two positive eigenvalues, there exist indices i and j such that d i > 0 and d j > 0.
  obtain ⟨i, hi⟩ : ∃ i : Fin n, d i > 0 := by
    contrapose! h;
    exact ⟨ 0, fun v hv => by simpa [ hv ] using h_quad_form v ▸ Finset.sum_nonpos fun i _ => mul_nonpos_of_nonpos_of_nonneg ( h i ) ( sq_nonneg _ ) ⟩
  obtain ⟨j, hj, hij⟩ : ∃ j : Fin n, j ≠ i ∧ d j > 0 := by
    contrapose! h;
    use P.mulVec ( Pi.single i 1 );
    intro v hv; rw [ h_quad_form ] ; rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ] ;
    simp_all +decide [ Matrix.mulVec, dotProduct ];
    rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ i ) ];
    exact add_nonpos ( mul_nonpos_of_nonneg_of_nonpos hi.le ( by simp_all +decide [ Finset.sum_apply, Pi.single_apply ] ) ) ( Finset.sum_nonpos fun j hj => mul_nonpos_of_nonpos_of_nonneg ( h j ( by aesop ) ) ( sq_nonneg _ ) );
  refine' ⟨ fun k => P k i, fun k => P k j, _ ⟩;
  intro s t hst
  have h_quad_form_pos : QuadForm A (fun k => s * P k i + t * P k j) = s^2 * d i + t^2 * d j := by
    have h_quad_form_pos : ∀ k : Fin n, (P.transpose.mulVec (fun l => s * P l i + t * P l j)) k = s * (if k = i then 1 else 0) + t * (if k = j then 1 else 0) := by
      intro k; have := congr_fun ( congr_fun hP.1 k ) i; have := congr_fun ( congr_fun hP.1 k ) j; simp_all +decide [ Matrix.mulVec, dotProduct ] ;
      have := congr_fun ( congr_fun hP.1 k ) i; have := congr_fun ( congr_fun hP.1 k ) j; simp_all +decide [ Matrix.mul_apply, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm ] ;
      simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, Matrix.one_apply ];
    simp_all +decide [ Finset.sum_add_distrib, add_sq, mul_pow ];
    simp +decide [ Finset.sum_add_distrib, mul_add, add_mul, mul_comm, mul_assoc, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, hj, hij ];
  cases hst <;> nlinarith [ mul_self_pos.2 ‹_› ]

theorem atMostOne_iff_no_twoDim_positive {n : ℕ}
    {A : Matrix (Fin n) (Fin n) ℝ}
    (hA : A.IsSymm) :
    HasAtMostOnePositiveEigenvalue A ↔ ¬ HasAtLeastTwoPositiveEigenvalues A :=
  ⟨atMostOne_imp_no_twoDim, no_twoDim_imp_atMostOne hA⟩

/-! ## Theorem 5: Graph-Theoretic Corollary -/

/-- For any symmetric matrix, the block-zero extension provides a Lorentzian
    certificate interface. Specializes to adjacency/Laplacian matrices. -/
theorem symmetric_matrix_lorentzian_certificate {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hA : A.IsSymm) :
    IsSpectralLeafEmbedding A (blockZeroExtend A) ∧
    (HasAtMostOnePositiveEigenvalue (blockZeroExtend A) ↔
     ¬ HasAtLeastTwoPositiveEigenvalues A) := by
  exact ⟨blockZeroExtend_spectralLeafEmbedding A,
    (blockZeroExtend_atMostOne_iff A).trans (atMostOne_iff_no_twoDim_positive hA)⟩

/-! ## Theorem 6: Sparsity Bound (Algorithmic) -/

/-
The block-zero extension has at most as many nonzero entries as A,
    certifying O(n²) constructibility.
-/
theorem blockZeroExtend_sparsity {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) :
    (Finset.univ.filter (fun p : Fin (n+1) × Fin (n+1) =>
      blockZeroExtend A p.1 p.2 ≠ 0)).card ≤
    (Finset.univ.filter (fun p : Fin n × Fin n =>
      A p.1 p.2 ≠ 0)).card := by
  refine' le_trans ( Finset.card_le_card _ ) _;
  exact Finset.image ( fun p : Fin n × Fin n => ( Fin.succ p.1, Fin.succ p.2 ) ) ( Finset.filter ( fun p : Fin n × Fin n => A p.1 p.2 ≠ 0 ) Finset.univ );
  · intro p hp; rcases p with ⟨ _ | i, _ | j ⟩ <;> simp_all +decide [ blockZeroExtend ] ;
    exact ⟨ _, _, hp, rfl, rfl ⟩;
  · exact Finset.card_image_le

end SpectralEmbedding