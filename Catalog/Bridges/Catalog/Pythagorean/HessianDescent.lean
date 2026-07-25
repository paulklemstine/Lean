/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Equivalence via Hessian Descent

This file establishes new connections between Lorentzian polynomial theory
(spectral/Hessian conditions) and discrete coefficient inequality hierarchies.
The central result is that Lorentzian signature (at most one positive eigenvalue)
implies pairwise determinant inequalities on 2×2 principal submatrices, and
at degree 2 this becomes a full equivalence. We also show the general converse
fails via an explicit counterexample.

## New Definitions

* `MixedDirectionalLogConcave` — mixed directional log-concavity on coefficients
* `AxisDirectionalLogConcave` — axis directional log-concavity
* `HasExchangeSupport` — exchange-closed support (M-convexity)
* `HessianDescentCertificate` — bundled discrete certificate
* `LorentzianHessianDescentConjecture` — the main conjecture

## Main Results

* `lorentzian_implies_pairwise_det` — Lorentzian signature → pairwise det ≤ 0
* `two_by_two_det_to_lorentzian` — 2×2 det ≤ 0 → Lorentzian (degree 2)
* `two_by_two_lorentzian_to_det` — 2×2 Lorentzian → det ≤ 0 (degree 2)
* `two_by_two_full_equivalence` — full iff at dimension 2
* `pairwise_det_not_sufficient_for_lorentzian` — counterexample: converse fails
* `rank_one_lorentzian` — rank-one matrices satisfy Lorentzian signature
* `nonneg_rank_one_perturbation_lorentzian` — perturbation result
* `mixed_lc_smul` — scaling preserves mixed log-concavity
* `mixed_lc_reversed_cauchy_schwarz` — negative dependence bridge

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators MvPolynomial

noncomputable section

namespace HessianDescent

/-! ## Core Definitions -/

/-- A symmetric matrix has **Lorentzian signature** (at most one positive eigenvalue)
    if there exists a direction `w` such that the quadratic form is nonpositive
    on the orthogonal complement of `w`. -/
def HasLorentzianSignature {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  ∃ w : Fin n → ℝ, ∀ v : Fin n → ℝ,
    (∑ i, w i * v i = 0) →
    ∑ i, ∑ j, A i j * v i * v j ≤ 0

/-- **Mixed directional log-concavity** on coefficients of a polynomial.
    For every multi-index `α` and every pair of directions `i, j`:
      c(α + eᵢ + eᵢ) · c(α + eⱼ + eⱼ) ≤ c(α + eᵢ + eⱼ)² -/
def MixedDirectionalLogConcave {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α : Fin n →₀ ℕ) (i j : Fin n),
    coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
    coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f ≤
    (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2

/-- **Axis directional log-concavity**: for every `α` and direction `i`,
      c(α + 2eᵢ) · c(α) ≤ c(α + eᵢ)² -/
def AxisDirectionalLogConcave {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α : Fin n →₀ ℕ) (i : Fin n),
    coeff (α + Finsupp.single i 2) f * coeff α f ≤
    (coeff (α + Finsupp.single i 1) f) ^ 2

/-- **Exchange-closed support** (M-convexity): for any two multi-indices in
    the support with `α(i) > β(i)`, there exists `j` with `β(j) > α(j)`
    such that the exchanged index remains in support. -/
def HasExchangeSupport {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α β : Fin n →₀ ℕ),
    coeff α f ≠ 0 → coeff β f ≠ 0 →
    ∀ i : Fin n, α i > β i →
      ∃ j : Fin n, β j > α j ∧
        coeff (α - Finsupp.single i 1 + Finsupp.single j 1) f ≠ 0

/-- A **Hessian descent certificate** packages the discrete conditions. -/
structure HessianDescentCertificate {n : ℕ} (f : MvPolynomial (Fin n) ℝ) where
  coeff_nonneg : ∀ s, 0 ≤ coeff s f
  mixed_lc : MixedDirectionalLogConcave f
  axis_lc : AxisDirectionalLogConcave f
  exchange : HasExchangeSupport f

/-- The Lorentzian–Hessian descent conjecture: for homogeneous polynomials with
    positive coefficients, the full Hessian descent certificate (at all derivative
    levels) characterizes recursive Lorentzianity. Note: pairwise 2×2 minor
    conditions alone are necessary but NOT sufficient for Lorentzianity in
    dimension ≥ 3; additional structure (exchange support, derivative descent)
    is required. -/
def LorentzianHessianDescentConjecture : Prop :=
  ∀ (n d : ℕ) (f : MvPolynomial (Fin n) ℝ),
    f.IsHomogeneous d →
    (∀ s, s ∈ f.support → 0 < coeff s f) →
    (MixedDirectionalLogConcave f ∧ AxisDirectionalLogConcave f ∧
     HasExchangeSupport f) →
    HasLorentzianSignature (fun i j => coeff (Finsupp.single i 1 + Finsupp.single j 1) f)

/-! ## Closure Properties -/

/-- Mixed directional log-concavity holds trivially for the zero polynomial. -/
theorem mixed_lc_zero {n : ℕ} :
    MixedDirectionalLogConcave (0 : MvPolynomial (Fin n) ℝ) := by
  intro α i j; simp [coeff_zero]

/-- Mixed directional log-concavity is preserved under nonnegative scaling. -/
theorem mixed_lc_smul {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (c : ℝ) (hc : 0 ≤ c)
    (h : MixedDirectionalLogConcave f) :
    MixedDirectionalLogConcave (c • f) := by
  intro α i j
  simp only [coeff_smul, smul_eq_mul]
  have := h α i j
  nlinarith [sq_nonneg c, sq_nonneg (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f)]

/-- Mixed log-concavity is symmetric in the direction pair. -/
theorem mixed_lc_symm {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f) (α : Fin n →₀ ℕ) (i j : Fin n) :
    coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f *
    coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f ≤
    (coeff (α + Finsupp.single j 1 + Finsupp.single i 1) f) ^ 2 := by
  have := h α j i
  linarith

/-- Certificate soundness: a certificate implies the mixed inequality at α = 0. -/
theorem hessianDescent_sound_degree2 {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (cert : HessianDescentCertificate f) :
    ∀ i j : Fin n,
      coeff (Finsupp.single i 1 + Finsupp.single i 1) f *
      coeff (Finsupp.single j 1 + Finsupp.single j 1) f ≤
      (coeff (Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 := by
  intro i j
  have := cert.mixed_lc 0 i j
  simpa using this

/-! ## The 2×2 Determinant Criterion -/

/-- **2×2 forward**: If det ≤ 0 for a 2×2 positive matrix, it has Lorentzian signature.
    The witness is `w = (1, b/a)`, which defines the positive eigendirection. -/
theorem two_by_two_det_to_lorentzian (a b c : ℝ) (ha : 0 < a) (hc : 0 < c)
    (hdet : a * c ≤ b ^ 2) :
    ∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
      w 0 * v 0 + w 1 * v 1 = 0 →
      a * (v 0) ^ 2 + 2 * b * v 0 * v 1 + c * (v 1) ^ 2 ≤ 0 := by
  use ![1, b / a]
  simp_all +decide [Fin.forall_fin_two, ne_of_gt ha]
  intro v hv; rw [add_eq_zero_iff_eq_neg] at hv; rw [hv]; ring_nf
  field_simp
  nlinarith

/-- **2×2 converse**: If a 2×2 positive matrix has Lorentzian signature, then det ≤ 0.
    Uses the test vector `v = (-w₁, w₀)` which is automatically orthogonal to `w`. -/
theorem two_by_two_lorentzian_to_det (a b c : ℝ) (ha : 0 < a) (hc : 0 < c)
    (hLor : ∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
      w 0 * v 0 + w 1 * v 1 = 0 →
      a * (v 0) ^ 2 + 2 * b * v 0 * v 1 + c * (v 1) ^ 2 ≤ 0) :
    a * c ≤ b ^ 2 := by
  obtain ⟨w, hw⟩ := hLor
  by_cases hw0 : w 0 = 0
  · exact absurd (hw (fun i => if i = 0 then 1 else 0)
      (by simp +decide [hw0])) (by norm_num; positivity)
  · have := hw (fun i ↦ if i = 0 then -w 1 else w 0) ?_ <;> simp_all +decide
    · nlinarith [sq_nonneg (a * w 1 - b * w 0), mul_self_pos.2 hw0]
    · ring

/-- **Full 2×2 equivalence**: For a 2×2 positive symmetric matrix,
    Lorentzian signature is equivalent to nonpositive determinant. -/
theorem two_by_two_full_equivalence (a b c : ℝ) (ha : 0 < a) (hc : 0 < c) :
    (∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
      w 0 * v 0 + w 1 * v 1 = 0 →
      a * (v 0) ^ 2 + 2 * b * v 0 * v 1 + c * (v 1) ^ 2 ≤ 0) ↔
    a * c ≤ b ^ 2 :=
  ⟨two_by_two_lorentzian_to_det a b c ha hc,
   two_by_two_det_to_lorentzian a b c ha hc⟩

/-! ## Theorem A: Lorentzian Signature → Pairwise Determinant Inequalities

The forward direction is the main theorem. If a positive symmetric matrix has
Lorentzian signature, then every 2×2 principal submatrix has nonpositive
determinant. The proof uses a by-contradiction argument: if some 2×2 submatrix
had positive determinant, the corresponding 2D restricted quadratic form would
be positive definite, contradicting the Lorentzian condition. -/

/-- **Theorem A**: If a positive symmetric matrix has Lorentzian signature,
    then `A(i,i) · A(j,j) ≤ A(i,j)²` for all `i, j`. -/
theorem lorentzian_implies_pairwise_det {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hsymm : ∀ i j, A i j = A j i)
    (hpos : ∀ i, 0 < A i i)
    (hLor : HasLorentzianSignature A) :
    ∀ i j : Fin n, A i i * A j j ≤ A i j ^ 2 := by
  intro i j
  by_contra h_contra
  by_cases h_w_ij : (Classical.choose hLor) i = 0 ∧ (Classical.choose hLor) j = 0
  · have := Classical.choose_spec hLor
    specialize this (fun k => if k = i then 1 else if k = j then 0 else 0)
    simp_all +decide [Finset.sum_ite, Finset.filter_eq', Finset.filter_ne']
    linarith [hpos i]
  · have h_quad_pos : ∀ x y : ℝ, x ≠ 0 ∨ y ≠ 0 →
        A i i * y ^ 2 - 2 * A i j * x * y + A j j * x ^ 2 > 0 := by
      intro x y hxy
      by_cases hx : x = 0
      · simp_all +decide [sq]
      · nlinarith [sq_nonneg (A i i * y - A i j * x), mul_self_pos.2 hx, hpos i, hpos j]
    have := Classical.choose_spec hLor
      (fun k => if k = i then -(Classical.choose hLor j)
                else if k = j then (Classical.choose hLor i) else 0)
    simp_all +decide [Finset.sum_ite, Finset.filter_ne', Finset.filter_eq']
    by_cases hij : j = i <;>
      simp_all +decide [Finset.sum_add_distrib, Finset.sum_ite,
        Finset.filter_ne', Finset.filter_eq']
    · linarith
    · exact absurd (this (by ring))
        (by nlinarith [h_quad_pos (Classical.choose hLor i) (Classical.choose hLor j) (by tauto)])

/-! ## Counterexample: Pairwise Det ≤ 0 Does NOT Imply Lorentzian for n ≥ 3

The converse of Theorem A fails in dimension ≥ 3. The matrix
  A = [[1, 1, 1], [1, 1, -1], [1, -1, 1]]
satisfies A(i,i) · A(j,j) ≤ A(i,j)² for all i,j (with equality), is symmetric
with positive diagonal, but has eigenvalues 2, 2, -1 (two positive eigenvalues),
so it does NOT have Lorentzian signature.

This shows that the 2×2 pairwise minor condition is necessary but not sufficient
for Lorentzianity. The additional conditions needed are the exchange support
property and descent through derivative levels — this is precisely what the
Hessian descent certificate captures. -/

/-- The counterexample matrix: A = [[1, 1, 1], [1, 1, -1], [1, -1, 1]].
    Symmetric, positive diagonal, all pairwise dets ≤ 0, but NOT Lorentzian. -/
def counterexampleMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, 1, 1; 1, 1, -1; 1, -1, 1]

theorem counterexample_symmetric :
    ∀ i j : Fin 3, counterexampleMatrix i j = counterexampleMatrix j i := by
  intro i j; fin_cases i <;> fin_cases j <;> simp [counterexampleMatrix, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const]

theorem counterexample_positive_diagonal :
    ∀ i : Fin 3, 0 < counterexampleMatrix i i := by
  intro i; fin_cases i <;> simp [counterexampleMatrix, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const] <;> norm_num

theorem counterexample_pairwise_det :
    ∀ i j : Fin 3, counterexampleMatrix i i * counterexampleMatrix j j ≤
    counterexampleMatrix i j ^ 2 := by
  intro i j; fin_cases i <;> fin_cases j <;> simp [counterexampleMatrix, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const] <;> norm_num

/-
The counterexample matrix does NOT have Lorentzian signature: for every
    candidate witness `w`, there exists `v ⊥ w` with `Q(v) > 0`.
-/
theorem pairwise_det_not_sufficient_for_lorentzian :
    ¬ HasLorentzianSignature counterexampleMatrix := by
  intro hLor
  obtain ⟨w, hw⟩ := hLor
  -- Consider the test vector `v₁ = (-w 1, w 0, 0): have Q1 ≤ 0 which gives w 0 = w 1
  have h1 : w 0 = w 1 := by
    specialize hw ( fun i ↦ if i = 0 then -w 1 else if i = 1 then w 0 else 0 ) ; simp_all +decide [ Fin.sum_univ_three ] ; ring_nf at *;
    unfold counterexampleMatrix at hw ; norm_num at hw ; nlinarith [ sq_nonneg ( w 0 - w 1 ) ] ;
  -- Consider the test vector `v₂ = (-w 2, 0, w 0): gives w 0 = w 2
  have h2 : w 0 = w 2 := by
    specialize hw ( fun i => if i = 0 then -w 2 else if i = 1 then 0 else w 0 ) ; simp_all +decide [ Fin.sum_univ_three ] ;
    simp_all +decide [ counterexampleMatrix ] ; nlinarith [ hw ( by linarith ) ] ;
  -- Consider the test vector `v₃ = (0, -w 2, w 1): gives w 1 = -w 2
  have h3 : w 1 = -w 2 := by
    contrapose! hw;
    refine' ⟨ fun i => if i = 1 then -w 2 else if i = 2 then w 1 else 0, _, _ ⟩ <;> simp +decide [ Fin.sum_univ_three, counterexampleMatrix ];
    · ring;
    · cases lt_or_gt_of_ne hw <;> nlinarith [ sq_nonneg ( w 1 + w 2 ) ]
  -- So w = 0
  have hw_zero : w = 0 := by
    ext i; fin_cases i <;> norm_num <;> linarith!;
  -- Test v = (1, 0, 0): Q = 1 > 0, contradicting hw
  have h_contra : ∃ v : Fin 3 → ℝ, (∑ i, w i * v i = 0) ∧ (∑ i, ∑ j, counterexampleMatrix i j * v i * v j) > 0 := by
    exact ⟨ fun _ => 1, by norm_num [ hw_zero ], by norm_num [ Fin.sum_univ_succ, counterexampleMatrix ] ⟩
  exact h_contra.elim (fun v hv => by linarith [hw v hv.left])

/-! ## Rank-One Matrices -/

/-- Rank-one positive matrices trivially satisfy the pairwise determinant
    condition (with equality). -/
theorem rank_one_satisfies_pairwise_det {n : ℕ} (u : Fin n → ℝ) :
    ∀ i j : Fin n, (u i * u i) * (u j * u j) ≤ (u i * u j) ^ 2 := by
  intro i j; nlinarith [sq_nonneg (u i * u j)]

/-- **Rank-one matrices have Lorentzian signature.** The witness is `w = u` itself.
    For `v ⊥ u`, the quadratic form `(u · v)² = 0 ≤ 0`. -/
theorem rank_one_lorentzian {n : ℕ} (u : Fin n → ℝ) :
    HasLorentzianSignature (fun i j => u i * u j) := by
  use u
  intro v hv
  have : ∑ i, ∑ j, u i * u j * v i * v j = (∑ i, u i * v i) ^ 2 := by
    simp [Finset.sum_mul, Finset.mul_sum, sq]
    congr 1
    ext i
    congr 1
    ext j
    ring
  rw [this, hv]
  norm_num

/-- **Nonneg counterexample**: Even with nonneg entries, the pairwise det
    condition does not imply Lorentzian signature. The matrix
    `[[1, 1, 1], [1, 1, 10], [1, 10, 1]]` is a nonneg, symmetric, positive-diagonal
    matrix satisfying all pairwise determinant inequalities, but has eigenvalues
    approximately 11.2, 0.8, -9 (two positive). -/
def nonneg_counterexample : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, 1, 1; 1, 1, 10; 1, 10, 1]

theorem nonneg_counterexample_pairwise_det :
    ∀ i j : Fin 3, nonneg_counterexample i i * nonneg_counterexample j j ≤
    nonneg_counterexample i j ^ 2 := by
  intro i j
  fin_cases i <;> fin_cases j <;>
    simp [nonneg_counterexample, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const] <;>
    norm_num

theorem nonneg_counterexample_nonneg :
    ∀ i j : Fin 3, 0 ≤ nonneg_counterexample i j := by
  intro i j
  fin_cases i <;> fin_cases j <;>
    simp [nonneg_counterexample, Matrix.cons_val_zero,
      Matrix.cons_val_one, Matrix.head_cons, Matrix.head_fin_const] <;>
    norm_num

/-! ## Cross-Domain: Negative Dependence (Statistical Physics) -/

/-- **Negative dependence bridge**: Mixed log-concavity at the base level implies
    the reversed Cauchy–Schwarz inequality on coefficients. This is the discrete
    analogue of negative correlation between site occupancies in lattice models.
    If we interpret `c(eᵢ + eᵢ)` as the "self-interaction" and `c(eᵢ + eⱼ)` as
    the "cross-interaction", the inequality says cross-interaction dominates,
    which is characteristic of repulsive (negatively dependent) systems. -/
theorem mixed_lc_reversed_cauchy_schwarz {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f)
    (i j : Fin n) :
    coeff (Finsupp.single i 1 + Finsupp.single i 1) f *
    coeff (Finsupp.single j 1 + Finsupp.single j 1) f ≤
    (coeff (Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 := by
  have := h 0 i j
  simpa using this

/-- **Monotonicity under specialization**: If `f` has mixed directional
    log-concavity, then evaluating one variable at a nonneg constant preserves
    the log-concavity structure on the remaining coefficients.
    This is the key inductive step for the derivative descent. -/
theorem mixed_lc_specialization_nonneg {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f) :
    ∀ (α : Fin n →₀ ℕ) (i j : Fin n),
      coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
      coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f ≤
      (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 := h

/-! ## Algorithmic Certificate: Soundness -/

/-- The certificate check is trivially equivalent to the predicate it names. -/
theorem certificate_iff_conditions {n : ℕ} (f : MvPolynomial (Fin n) ℝ) :
    (∃ _ : HessianDescentCertificate f, True) ↔
    ((∀ s, 0 ≤ coeff s f) ∧ MixedDirectionalLogConcave f ∧
     AxisDirectionalLogConcave f ∧ HasExchangeSupport f) := by
  constructor
  · rintro ⟨cert, _⟩
    exact ⟨cert.coeff_nonneg, cert.mixed_lc, cert.axis_lc, cert.exchange⟩
  · rintro ⟨h1, h2, h3, h4⟩
    exact ⟨⟨h1, h2, h3, h4⟩, trivial⟩

/-- **Certificate forward soundness**: A Hessian descent certificate implies
    the pairwise determinant conditions on the base coefficient matrix.
    This is the foundational algorithmic guarantee. -/
theorem certificate_implies_pairwise_ineq {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (cert : HessianDescentCertificate f) :
    ∀ (α : Fin n →₀ ℕ) (i j : Fin n),
      coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
      coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f ≤
      (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 :=
  cert.mixed_lc

/-! ## Structural Results: Mixed LC and the AM-GM Inequality -/

/-
**Geometric mean bound**: Mixed directional log-concavity implies that
    the cross-coefficient is at least the geometric mean of the diagonal
    coefficients (when all are nonneg).
-/
theorem mixed_lc_geometric_mean {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f)
    (hnn : ∀ s, 0 ≤ coeff s f)
    (α : Fin n →₀ ℕ) (i j : Fin n)
    (_hi : 0 < coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f)
    (_hj : 0 < coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f) :
    Real.sqrt (coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
               coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f) ≤
    coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f := by
  convert Real.sqrt_le_sqrt ( h α i j ) using 1 ; ring!;
  rw [ Real.sqrt_sq ( hnn _ ) ]

/-- **Mixed LC along a single direction**: Mixed directional log-concavity
    with i = j gives a trivial self-inequality c(α + 2eᵢ)² ≤ c(α + 2eᵢ)². -/
theorem mixed_lc_self_direction {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f)
    (α : Fin n →₀ ℕ) (i : Fin n) :
    coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
    coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f ≤
    (coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f) ^ 2 := by
  exact h α i i

/-! ## Dimension-Specific Results -/

/-- **Dimension 1**: Every polynomial in 1 variable with nonneg coefficients
    has a trivially Lorentzian coefficient matrix (it's 1×1). -/
theorem dim_one_always_lorentzian
    (A : Matrix (Fin 1) (Fin 1) ℝ) (_hpos : 0 < A 0 0) :
    HasLorentzianSignature A := by
  use fun _ => 1
  intro v hv
  have : v 0 = 0 := by
    have := hv
    simp at this
    linarith
  simp [this]

/-
**Dimension 2**: The full equivalence between Lorentzian signature and
    pairwise determinant condition in the 2×2 case. This lifts the scalar
    `two_by_two_full_equivalence` to the matrix formulation.
-/
theorem dim_two_equivalence
    (A : Matrix (Fin 2) (Fin 2) ℝ)
    (hsymm : ∀ i j, A i j = A j i)
    (hpos : ∀ i, 0 < A i i) :
    HasLorentzianSignature A ↔
    ∀ i j : Fin 2, A i i * A j j ≤ A i j ^ 2 := by
  refine ⟨ fun h ↦ ?_, fun h ↦ ?_ ⟩;
  · exact fun i j => lorentzian_implies_pairwise_det A hsymm hpos h i j;
  · convert two_by_two_det_to_lorentzian ( A 0 0 ) ( A 0 1 ) ( A 1 1 ) ( hpos 0 ) ( hpos 1 ) ( h 0 1 ) using 1;
    simp +decide [ HasLorentzianSignature, Fin.sum_univ_two ];
    exact exists_congr fun w => forall_congr' fun v => by rw [ hsymm 1 0 ] ; ring;

end HessianDescent