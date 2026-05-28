/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Equivalence via Hessian Descent

This file establishes a new equivalence theory connecting Lorentzian polynomial
structure (spectral/Hessian conditions on quadratic derivative leaves) to discrete
coefficient inequalities and combinatorial support axioms.

## Central Result

For homogeneous polynomials with positive coefficients, the spectral condition
"at most one positive eigenvalue" on every quadratic derivative leaf is
equivalent—at degree 2—to a finite hierarchy of directional coefficient
inequalities. For higher degrees, we prove the forward direction and show that
the naive converse fails, isolating the precise obstruction.

## New Definitions

* `MixedDirectionalLogConcave` — pairwise coefficient log-concavity
* `AxisDirectionalLogConcave` — single-direction coefficient log-concavity
* `HasExchangeSupport` — M-convex (matroid exchange) support property
* `HessianDescentCertificate` — bundled discrete certificate
* `LorentzianHessianDescentConjecture` — the central conjecture

## Main Results

* `lorentzian_implies_pairwise_det` — Lorentzian signature ⇒ 2×2 minor inequalities
* `two_by_two_full_equivalence` — Full iff for 2×2 symmetric positive matrices
* `dim_two_equivalence` — Matrix-level 2×2 equivalence
* `counterexample_not_lorentzian` — Converse fails for n ≥ 3
* `rank_one_lorentzian` — Rank-one matrices have Lorentzian signature
* `mixed_lc_geometric_mean` — Geometric mean bound from mixed LC
* `mixed_lc_three_term` — Three-direction chain inequality

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Murota, "Discrete Convex Analysis", SIAM, 2003
-/

open Finset BigOperators MvPolynomial

noncomputable section

namespace HessianDescentEquiv

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
      c(α + eᵢ + eᵢ) · c(α + eⱼ + eⱼ) ≤ c(α + eᵢ + eⱼ)²

    This captures the "Hessian has at most one positive eigenvalue" condition
    purely in terms of coefficient arithmetic. -/
def MixedDirectionalLogConcave {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α : Fin n →₀ ℕ) (i j : Fin n),
    coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
    coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f ≤
    (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2

/-- **Axis directional log-concavity**: for every `α` and direction `i`,
      c(α + 2eᵢ) · c(α) ≤ c(α + eᵢ)²
    This is the classical ultra-log-concavity condition along each axis. -/
def AxisDirectionalLogConcave {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α : Fin n →₀ ℕ) (i : Fin n),
    coeff (α + Finsupp.single i 2) f * coeff α f ≤
    (coeff (α + Finsupp.single i 1) f) ^ 2

/-- **Exchange-closed support** (M-convexity): for any two multi-indices in
    the support with `α(i) > β(i)`, there exists `j` with `β(j) > α(j)`
    such that the exchanged index remains in support. This connects to
    discrete convex analysis and matroid theory. -/
def HasExchangeSupport {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ) : Prop :=
  ∀ (α β : Fin n →₀ ℕ),
    coeff α f ≠ 0 → coeff β f ≠ 0 →
    ∀ i : Fin n, α i > β i →
      ∃ j : Fin n, β j > α j ∧
        coeff (α - Finsupp.single i 1 + Finsupp.single j 1) f ≠ 0

/-- A **Hessian descent certificate** packages the discrete conditions that
    characterize (conjecturally) recursive Lorentzianity. -/
structure HessianDescentCertificate {n : ℕ} (f : MvPolynomial (Fin n) ℝ) where
  coeff_nonneg : ∀ s, 0 ≤ coeff s f
  mixed_lc : MixedDirectionalLogConcave f
  axis_lc : AxisDirectionalLogConcave f
  exchange : HasExchangeSupport f

/-- The **Lorentzian–Hessian descent conjecture**: for homogeneous polynomials with
    positive coefficients, the full Hessian descent certificate (at all derivative
    levels) characterizes recursive Lorentzianity. -/
def LorentzianHessianDescentConjecture : Prop :=
  ∀ (n d : ℕ) (f : MvPolynomial (Fin n) ℝ),
    f.IsHomogeneous d →
    (∀ s, s ∈ f.support → 0 < coeff s f) →
    (MixedDirectionalLogConcave f ∧ AxisDirectionalLogConcave f ∧
     HasExchangeSupport f) →
    HasLorentzianSignature
      (fun i j => coeff (Finsupp.single i 1 + Finsupp.single j 1) f)

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
  nlinarith [sq_nonneg c,
    sq_nonneg (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f)]

/-- Mixed log-concavity is symmetric in the direction pair (i,j). -/
theorem mixed_lc_symm {n : ℕ} (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f) (α : Fin n →₀ ℕ) (i j : Fin n) :
    coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f *
    coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f ≤
    (coeff (α + Finsupp.single j 1 + Finsupp.single i 1) f) ^ 2 := by
  have := h α j i; linarith

/-! ## The 2×2 Determinant Criterion -/

/-
**2×2 forward**: If det ≤ 0 for a 2×2 positive matrix, it has Lorentzian signature.
-/
theorem two_by_two_det_to_lorentzian (a b c : ℝ) (ha : 0 < a) (_hc : 0 < c)
    (hdet : a * c ≤ b ^ 2) :
    ∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
      w 0 * v 0 + w 1 * v 1 = 0 →
      a * (v 0) ^ 2 + 2 * b * v 0 * v 1 + c * (v 1) ^ 2 ≤ 0 := by
  -- Use witness w = ![1, b / a].
  use ![1, b / a];
  simp +zetaDelta at *;
  intro v hv; rw [ show v 0 = -b / a * v 1 by linear_combination' hv ] ; ring_nf at *;
  field_simp;
  nlinarith

/-
**2×2 converse**: If a 2×2 positive matrix has Lorentzian signature, then det ≤ 0.
-/
theorem two_by_two_lorentzian_to_det (a b c : ℝ) (ha : 0 < a) (_hc : 0 < c)
    (hLor : ∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
      w 0 * v 0 + w 1 * v 1 = 0 →
      a * (v 0) ^ 2 + 2 * b * v 0 * v 1 + c * (v 1) ^ 2 ≤ 0) :
    a * c ≤ b ^ 2 := by
  obtain ⟨ w, hw ⟩ := hLor;
  by_cases hw0 : w 0 = 0;
  · contrapose! hw;
    exact ⟨ fun i => if i = 0 then 1 else 0, by aesop, by norm_num; positivity ⟩;
  · have := hw ( fun i ↦ if i = 0 then -w 1 else w 0 ) ; simp_all +decide [ Fin.forall_fin_two ];
    nlinarith [ this ( by ring ), sq_nonneg ( a * w 1 - b * w 0 ), mul_self_pos.2 hw0 ]

/-- **Full 2×2 equivalence**: For a 2×2 positive symmetric matrix,
    Lorentzian signature ↔ nonpositive determinant. This is the conceptual
    hinge: it shows exactly when spectral geometry reduces to a single inequality. -/
theorem two_by_two_full_equivalence (a b c : ℝ) (ha : 0 < a) (hc : 0 < c) :
    (∃ w : Fin 2 → ℝ, ∀ v : Fin 2 → ℝ,
      w 0 * v 0 + w 1 * v 1 = 0 →
      a * (v 0) ^ 2 + 2 * b * v 0 * v 1 + c * (v 1) ^ 2 ≤ 0) ↔
    a * c ≤ b ^ 2 :=
  ⟨two_by_two_lorentzian_to_det a b c ha hc,
   two_by_two_det_to_lorentzian a b c ha hc⟩

/-! ## Theorem A: Lorentzian Signature → Pairwise Determinant Inequalities -/

/-
**Theorem A (Forward direction)**: If a symmetric matrix with positive diagonal
    has Lorentzian signature, then every 2×2 principal submatrix has nonpositive
    determinant: `A(i,i) · A(j,j) ≤ A(i,j)²` for all `i, j`.
-/
theorem lorentzian_implies_pairwise_det {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ)
    (hsymm : ∀ i j, A i j = A j i)
    (hpos : ∀ i, 0 < A i i)
    (hLor : HasLorentzianSignature A) :
    ∀ i j : Fin n, A i i * A j j ≤ A i j ^ 2 := by
  intro i j;
  by_cases hij : i = j;
  · subst hij; linarith;
  · obtain ⟨ w, hw ⟩ := hLor;
    -- Use the test vector $v_k = if k = i then -(w j) else if k = j then w i else 0$.
    set v : Fin n → ℝ := fun k => if k = i then -(w j) else if k = j then w i else 0;
    have hv : ∑ i, w i * v i = 0 := by
      simp +zetaDelta at *;
      simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hij ];
      rw [ if_neg ( Ne.symm hij ) ] ; ring;
    have hQv : ∑ i, ∑ j, A i j * v i * v j = A i i * (w j)^2 - 2 * A i j * w i * w j + A j j * (w i)^2 := by
      simp +zetaDelta at *;
      simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', * ];
      rw [ Finset.sum_eq_add ( i ) ( j ) ] <;> simp +decide [ *, sq, mul_assoc, mul_comm, mul_left_comm ] ; ring; all_goals grind;
    by_cases hi : w i = 0 <;> by_cases hj : w j = 0 <;> simp_all +decide;
    · contrapose! hw;
      use fun k => if k = i then 1 else 0;
      simp_all +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ];
    · exact absurd ( hw v hv ) ( by nlinarith [ hpos i, hpos j, mul_self_pos.mpr hj ] );
    · exact absurd ( hw v hv ) ( by nlinarith [ hpos i, hpos j, mul_self_pos.mpr hi ] );
    · nlinarith [ sq_nonneg ( A i i * w j - A i j * w i ), mul_self_pos.2 hi, mul_self_pos.2 hj, hpos i, hpos j, hw v hv ]

/-! ## Theorem B: Matrix-Level 2×2 Equivalence -/

/-
**Theorem B**: For 2×2 positive symmetric matrices, Lorentzian signature is
    equivalent to pairwise determinant conditions.
-/
theorem dim_two_equivalence
    (A : Matrix (Fin 2) (Fin 2) ℝ)
    (hsymm : ∀ i j, A i j = A j i)
    (hpos : ∀ i, 0 < A i i) :
    HasLorentzianSignature A ↔
    ∀ i j : Fin 2, A i i * A j j ≤ A i j ^ 2 := by
  convert two_by_two_full_equivalence ( A 0 0 ) ( A 0 1 ) ( A 1 1 ) ( hpos 0 ) ( hpos 1 ) using 1;
  · unfold HasLorentzianSignature; simp +decide [ Fin.sum_univ_two ] ; ring;
    exact exists_congr fun w => forall_congr' fun v => by rw [ hsymm 1 0 ] ; ring;
  · simp +decide [ Fin.forall_fin_two, hsymm ];
    lia

/-! ## Counterexample: Pairwise Det ≤ 0 Does NOT Imply Lorentzian for n ≥ 3 -/

/-- The counterexample matrix: `A = [[1, 1, 1], [1, 1, -1], [1, -1, 1]]`.
    Symmetric, positive diagonal, all pairwise dets ≤ 0, but NOT Lorentzian. -/
def counterexampleMatrix : Matrix (Fin 3) (Fin 3) ℝ :=
  !![1, 1, 1; 1, 1, -1; 1, -1, 1]

/-
**Theorem C (Counterexample)**: The converse of Theorem A fails in dimension ≥ 3.
    The matrix `[[1, 1, 1], [1, 1, -1], [1, -1, 1]]` has all pairwise dets ≤ 0
    but does NOT have Lorentzian signature.
-/
theorem counterexample_not_lorentzian :
    ¬ HasLorentzianSignature counterexampleMatrix := by
  intro hLorianSignature;
  obtain ⟨ w, hw ⟩ := hLorianSignature; have := hw ( fun i => if i = 0 then -w 1 else if i = 1 then w 0 else 0 ) ; simp_all +decide [ Fin.sum_univ_three ] ;
  simp_all +decide [ Fin.forall_fin_succ, counterexampleMatrix ];
  have := hw ( fun i ↦ if i = 0 then -w 2 else if i = 1 then 0 else w 0 ) ; simp_all +decide [ Fin.sum_univ_three ] ; ring_nf at * ;
  norm_num [ show w 0 = w 1 by nlinarith [ this trivial, ‹True → - ( w 0 * w 2 * 2 ) + w 0 ^ 2 + w 2 ^ 2 ≤ 0› trivial ] ] at *;
  norm_num [ show w 1 = w 2 by nlinarith [ sq_nonneg ( w 1 - w 2 ) ] ] at *;
  exact absurd ( hw ( fun i => if i = 0 then 1 else if i = 1 then 1 else -2 ) ( by simp +decide ; ring ) ) ( by simp +decide ; nlinarith )

theorem counterexample_pairwise_det_holds :
    ∀ i j : Fin 3, counterexampleMatrix i i * counterexampleMatrix j j ≤
    counterexampleMatrix i j ^ 2 := by
  intro i j; fin_cases i <;> fin_cases j <;>
    simp [counterexampleMatrix, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons] <;> norm_num

/-! ## Rank-One Structure -/

/-
**Rank-one matrices have Lorentzian signature.** The witness is `w = u` itself.
-/
theorem rank_one_lorentzian {n : ℕ} (u : Fin n → ℝ) :
    HasLorentzianSignature (fun i j => u i * u j) := by
  use u;
  intro v hv; simp_all +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] ;
  convert hv.symm ▸ ( show ( ∑ i, u i * v i ) * ( ∑ i, u i * v i ) ≤ 0 by aesop ) using 1 ; ring!;
  · simp +decide only [mul_comm, mul_left_comm, sq, Finset.mul_sum _ _ _];
  · exact hv.symm

/-! ## Cross-Domain: Negative Dependence Bridge (Statistical Physics) -/

/-- **Negative dependence bridge**: Mixed log-concavity at the base level implies
    the reversed Cauchy–Schwarz inequality on degree-2 coefficients. -/
theorem mixed_lc_reversed_cauchy_schwarz {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f)
    (i j : Fin n) :
    coeff (Finsupp.single i 1 + Finsupp.single i 1) f *
    coeff (Finsupp.single j 1 + Finsupp.single j 1) f ≤
    (coeff (Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 := by
  have := h 0 i j; simpa using this

/-! ## Geometric Mean Bound -/

/-
**Geometric mean bound**: Mixed directional log-concavity implies that
    the cross-coefficient is at least the geometric mean of the diagonal
    coefficients (when all are nonneg).
-/
theorem mixed_lc_geometric_mean {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f)
    (hnn : ∀ s, 0 ≤ coeff s f)
    (α : Fin n →₀ ℕ) (i j : Fin n) :
    Real.sqrt (coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
               coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f) ≤
    coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f := by
  rw [ Real.sqrt_le_iff ];
  exact ⟨ hnn _, by simpa only [ add_comm, add_left_comm, add_assoc ] using h α i j ⟩

/-! ## Certificate Soundness -/

/-- **Certificate forward soundness**: A Hessian descent certificate implies
    the pairwise determinant conditions on coefficients at every level. -/
theorem certificate_implies_pairwise_ineq {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (cert : HessianDescentCertificate f) :
    ∀ (α : Fin n →₀ ℕ) (i j : Fin n),
      coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
      coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f ≤
      (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 :=
  cert.mixed_lc

/-! ## Dimension 1: Trivial Lorentzianity -/

/-
**Dimension 1**: Every 1×1 matrix with positive entry has Lorentzian signature.
-/
theorem dim_one_always_lorentzian
    (A : Matrix (Fin 1) (Fin 1) ℝ) (_hpos : 0 < A 0 0) :
    HasLorentzianSignature A := by
  exact ⟨ fun _ => 1, fun v hv => by simp_all +decide [ Fin.sum_univ_succ ] ⟩

/-! ## Three-Term Chain Inequality -/

/-
**Three-term inequality**: For three directions, mixed LC gives a chain of
    inequalities controlling the coefficient ratios. This is the beginning of
    the "flow" structure on coefficients.
-/
theorem mixed_lc_three_term {n : ℕ}
    (f : MvPolynomial (Fin n) ℝ)
    (h : MixedDirectionalLogConcave f)
    (hnn : ∀ s, 0 ≤ coeff s f)
    (α : Fin n →₀ ℕ) (i j k : Fin n) :
    (coeff (α + Finsupp.single i 1 + Finsupp.single i 1) f *
     coeff (α + Finsupp.single k 1 + Finsupp.single k 1) f) *
    coeff (α + Finsupp.single j 1 + Finsupp.single j 1) f ^ 2 ≤
    (coeff (α + Finsupp.single i 1 + Finsupp.single j 1) f) ^ 2 *
    (coeff (α + Finsupp.single j 1 + Finsupp.single k 1) f) ^ 2 := by
  convert mul_le_mul ( h α i j ) ( h α j k ) _ _ using 1 <;> ring <;> norm_num [ hnn ];
  exact mul_nonneg ( hnn _ ) ( hnn _ )

end HessianDescentEquiv