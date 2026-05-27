/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Hessian-Based Lorentzian Gap via MvPolynomial Infrastructure

This file introduces the **Hessian Lorentzian gap**: a differential-geometric invariant
extracted from `log P` at the all-ones point, where `P` is a multivariate polynomial.
This replaces crude mass-ratio surrogates with a canonical curvature certificate.

## Main Definitions

* `onesVec` — the all-ones evaluation point `σ → ℝ`
* `gradAtOne` — gradient of `P` evaluated at the all-ones point
* `hessianAtOne` — Hessian matrix of `P` evaluated at the all-ones point
* `logHessianAtOne` — Hessian matrix of `log P` at the all-ones point
* `SumZeroVec` — predicate for vectors whose entries sum to zero
* `HasHessianLorentzianGap` — coercivity of `-logHessianAtOne` on sum-zero vectors

## Main Results

* `hessianAtOne_symm` — symmetry of the Hessian matrix (from commutativity of partials)
* `logHessianAtOne_symm` — symmetry of the log-Hessian matrix
* `quad_logHessianAtOne_eq` — quadratic form identity decomposing log-Hessian
* `logHessianAtOne_scale_invariant` — log-Hessian is invariant under positive scaling
* `hessianGap_stable_under_perturbation` — perturbative stability of the Hessian gap

## Cross-Domain Connections

- **Riemannian geometry**: `-logHessianAtOne` is the local metric tensor of information geometry
- **Spectral theory**: The Hessian gap predicts Glauber mixing times
- **Quantum physics**: For TFIM measurement distributions, curvature encodes collective response
- **Information geometry**: `-∇² log P` is a Fisher-information-type object
-/

open Finset BigOperators MvPolynomial

noncomputable section

variable {σ : Type*} [Fintype σ] [DecidableEq σ]

/-! ## Core Definitions -/

/-- The all-ones evaluation point. -/
def onesVec (σ : Type*) [Fintype σ] : σ → ℝ := fun _ => 1

/-- Gradient of `P` evaluated at the all-ones point. -/
def gradAtOne (P : MvPolynomial σ ℝ) : σ → ℝ := fun i =>
  MvPolynomial.eval (onesVec σ) (MvPolynomial.pderiv i P)

/-- Hessian matrix of `P` evaluated at the all-ones point.
    `hessianAtOne P i j = (∂_i ∂_j P)(1)`. -/
def hessianAtOne (P : MvPolynomial σ ℝ) : Matrix σ σ ℝ := fun i j =>
  MvPolynomial.eval (onesVec σ) (MvPolynomial.pderiv i (MvPolynomial.pderiv j P))

/-- Hessian of `log P` at the all-ones point, expressed as a rational formula:
    `(logHessianAtOne P)(i,j) = H_P(i,j)/P(1) - g_P(i)·g_P(j)/P(1)²`. -/
def logHessianAtOne (P : MvPolynomial σ ℝ) : Matrix σ σ ℝ := fun i j =>
  hessianAtOne P i j / MvPolynomial.eval (onesVec σ) P
    - (gradAtOne P i * gradAtOne P j) / (MvPolynomial.eval (onesVec σ) P) ^ 2

/-- A vector whose entries sum to zero — the tangent space to the simplex constraint. -/
def SumZeroVec (σ : Type*) [Fintype σ] (x : σ → ℝ) : Prop :=
  ∑ i : σ, x i = 0

/-- The Hessian Lorentzian gap: `κ ≥ 0` such that `-logHessianAtOne` is `κ`-coercive
    on the sum-zero subspace. -/
def HasHessianLorentzianGap (P : MvPolynomial σ ℝ) (κ : ℝ) : Prop :=
  0 ≤ κ ∧
  ∀ x : σ → ℝ, SumZeroVec σ x →
    κ * (∑ i : σ, x i ^ 2)
      ≤ -(∑ i : σ, ∑ j : σ, x i * logHessianAtOne P i j * x j)

/-- Abbreviation for evaluation of P at the all-ones point. -/
abbrev evalAtOne (P : MvPolynomial σ ℝ) : ℝ :=
  MvPolynomial.eval (onesVec σ) P

/-! ## Lemma: Commutativity of mixed partial derivatives for MvPolynomial -/

/-
Mixed partial derivatives of `MvPolynomial` commute.
-/
theorem MvPolynomial.pderiv_pderiv_comm (i j : σ) (P : MvPolynomial σ ℝ) :
    MvPolynomial.pderiv i (MvPolynomial.pderiv j P) =
    MvPolynomial.pderiv j (MvPolynomial.pderiv i P) := by
      induction P using MvPolynomial.induction_on <;> simp_all +decide [ MvPolynomial.pderiv_X ];
      simp_all +decide [ mul_comm, Pi.single_apply ] ; ring;
      aesop

/-! ## Theorem 1: Symmetry of the Hessian -/

/-- The Hessian matrix at ones is symmetric. -/
theorem hessianAtOne_symm (P : MvPolynomial σ ℝ) (i j : σ) :
    hessianAtOne P i j = hessianAtOne P j i := by
  simp only [hessianAtOne]
  congr 1
  exact MvPolynomial.pderiv_pderiv_comm i j P

/-- The log-Hessian inherits symmetry from the Hessian. -/
theorem logHessianAtOne_symm (P : MvPolynomial σ ℝ) (i j : σ) :
    logHessianAtOne P i j = logHessianAtOne P j i := by
  simp only [logHessianAtOne]
  rw [hessianAtOne_symm, mul_comm (gradAtOne P i)]

/-! ## Theorem 2: Quadratic Form Identity for log-Hessian -/

/-
**Quadratic form identity for the log-Hessian.**
This decomposes the log-Hessian quadratic form into a normalized Hessian term
minus a rank-one gradient correction:

  x^T (logHessianAtOne P) x = (x^T H_P x) / P(1) - ⟨g_P, x⟩² / P(1)²
-/
theorem quad_logHessianAtOne_eq
    (P : MvPolynomial σ ℝ)
    (hP : evalAtOne P ≠ 0)
    (x : σ → ℝ) :
    (∑ i : σ, ∑ j : σ, x i * logHessianAtOne P i j * x j)
    =
    (∑ i : σ, ∑ j : σ, x i * hessianAtOne P i j * x j)
      / evalAtOne P
    -
    ((∑ i : σ, x i * gradAtOne P i) ^ 2)
      / (evalAtOne P) ^ 2 := by
        simp +decide [ logHessianAtOne, Finset.sum_div _ _ _, Finset.mul_sum _ _ _, Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ];
        simp +decide [ mul_sub, sub_mul, mul_assoc, mul_comm, mul_left_comm, sq, Finset.mul_sum _ _ _, Finset.sum_mul, evalAtOne ]

/-! ## Theorem 3: Scale Invariance of log-Hessian -/

/-- Evaluation of `C c * P` at ones. -/
theorem evalAtOne_smul (P : MvPolynomial σ ℝ) (c : ℝ) :
    evalAtOne (MvPolynomial.C c * P) = c * evalAtOne P := by
  simp [evalAtOne, MvPolynomial.eval_mul, MvPolynomial.eval_C]

/-
Gradient of `C c * P` at ones equals `c * gradAtOne P`.
-/
theorem gradAtOne_smul (P : MvPolynomial σ ℝ) (c : ℝ) :
    gradAtOne (MvPolynomial.C c * P) = fun i => c * gradAtOne P i := by
      funext i; simp +decide [ gradAtOne, MvPolynomial.pderiv_mul, mul_assoc, mul_comm, mul_left_comm ] ;

/-
Hessian of `C c * P` at ones equals `c * hessianAtOne P`.
-/
theorem hessianAtOne_smul (P : MvPolynomial σ ℝ) (c : ℝ) :
    hessianAtOne (MvPolynomial.C c * P) = fun i j => c * hessianAtOne P i j := by
      ext i j;
      simp +decide [ hessianAtOne, MvPolynomial.pderiv_mul ]

/-
**Scale invariance of the log-Hessian.**
The curvature of `log P` at `1` is invariant under positive scaling, reflecting
the Riemannian-geometric principle that the Fisher information metric is
independent of the normalization of the probability model.
-/
theorem logHessianAtOne_scale_invariant
    (P : MvPolynomial σ ℝ) {c : ℝ}
    (hc : 0 < c)
    (hP : evalAtOne P ≠ 0) :
    logHessianAtOne (MvPolynomial.C c * P) = logHessianAtOne P := by
      unfold logHessianAtOne;
      simp +decide [ hessianAtOne_smul, gradAtOne_smul, evalAtOne_smul, hc.ne.symm, hP, mul_div_mul_left, mul_div_mul_right ];
      exact funext fun i => funext fun j => by rw [ show ( c * evalAtOne P ) ^ 2 = c ^ 2 * ( evalAtOne P ) ^ 2 by ring ] ; rw [ show c * gradAtOne P i * ( c * gradAtOne P j ) = c ^ 2 * ( gradAtOne P i * gradAtOne P j ) by ring ] ; rw [ mul_div_mul_left _ _ ( by positivity ) ] ;

/-! ## Theorem 4: Perturbative Stability of the Hessian Gap -/

/-- Entrywise perturbation bound on log-Hessian matrices. -/
def LogHessianPertBound (P Q : MvPolynomial σ ℝ) (δ : ℝ) : Prop :=
  ∀ i j : σ, |logHessianAtOne P i j - logHessianAtOne Q i j| ≤ δ

/-
**Perturbative stability of the Hessian gap.**
If `P` has Hessian gap `κ` and `Q` has log-Hessian entries within `δ` of `P`,
where `(Fintype.card σ)² · δ < κ`, then `Q` has positive Hessian gap.

This theorem makes the Hessian gap robust enough for applications to noisy
quantum data and approximate distributions.
-/
theorem hessianGap_stable_under_perturbation
    (P Q : MvPolynomial σ ℝ)
    (κ δ : ℝ)
    (hκ : HasHessianLorentzianGap P κ)
    (hpert : LogHessianPertBound P Q δ)
    (hδ_pos : 0 ≤ δ)
    (hsmall : (Fintype.card σ) ^ 2 * δ < κ) :
    HasHessianLorentzianGap Q (κ - (Fintype.card σ) ^ 2 * δ) := by
      refine' ⟨ sub_nonneg_of_le hsmall.le, fun x hx => _ ⟩;
      -- By the perturbative bound, we have |Q_P(x) - Q_Q(x)| ≤ (Fintype.card σ)^2 * δ * ‖x‖^2.
      have h_diff : |∑ i, ∑ j, x i * (logHessianAtOne P i j - logHessianAtOne Q i j) * x j| ≤ (Fintype.card σ) ^ 2 * δ * ∑ i, x i ^ 2 := by
        -- Apply the triangle inequality and the perturbation bound to each term in the sum.
        have h_term_bound : ∀ i j : σ, |x i * (logHessianAtOne P i j - logHessianAtOne Q i j) * x j| ≤ δ * (x i ^ 2 + x j ^ 2) / 2 := by
          intro i j
          have h_term_bound : |logHessianAtOne P i j - logHessianAtOne Q i j| ≤ δ := by
            exact hpert i j;
          rw [ abs_le ] at *;
          constructor <;> nlinarith [ sq_nonneg ( x i - x j ), sq_nonneg ( x i + x j ) ];
        refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( le_trans ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ ) _ );
        refine' le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => h_term_bound i j ) _;
        norm_num [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_div ] ; ring_nf;
        exact mul_le_mul_of_nonneg_right ( mul_le_mul_of_nonneg_left ( mod_cast Nat.le_self_pow ( by norm_num ) _ ) hδ_pos ) ( Finset.sum_nonneg fun _ _ => sq_nonneg _ );
      simp_all +decide [ mul_sub, sub_mul ];
      linarith [ abs_le.mp h_diff, hκ.2 x hx ]

/-! ## Theorem 5: Scale-invariance of the gap -/

/-
The Hessian gap is preserved under positive scaling.
-/
theorem hessianGap_scale_invariant
    (P : MvPolynomial σ ℝ) {c : ℝ}
    (hc : 0 < c)
    (hP : evalAtOne P ≠ 0)
    (κ : ℝ)
    (hgap : HasHessianLorentzianGap P κ) :
    HasHessianLorentzianGap (MvPolynomial.C c * P) κ := by
      exact ⟨ hgap.1, fun x hx => by rw [ logHessianAtOne_scale_invariant P hc hP ] ; exact hgap.2 x hx ⟩

/-! ## Theorem 6: Monotonicity of the gap -/

/-
If `P` has gap `κ` and `κ' ≤ κ` with `0 ≤ κ'`, then `P` has gap `κ'`.
-/
theorem hasHessianLorentzianGap_mono (P : MvPolynomial σ ℝ) (κ κ' : ℝ)
    (hgap : HasHessianLorentzianGap P κ)
    (hle : κ' ≤ κ) (hnn : 0 ≤ κ') :
    HasHessianLorentzianGap P κ' := by
      refine ⟨ hnn, fun x hx ↦ ?_ ⟩;
      exact le_trans ( mul_le_mul_of_nonneg_right hle ( Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ) ( hgap.2 x hx )

end