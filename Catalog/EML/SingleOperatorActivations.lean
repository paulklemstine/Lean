/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Single-Operator Completeness: Polynomials and Neural Activation Functions

A second research cycle on the EML single-operator program. Having shown in
`EML.SingleOperatorChurchTuring` that the single primitive
`eml(x, y) = exp(x) − log(y)` generates a class closed under the elementary
operations, we now harvest two concrete *completeness* payoffs:

* **Algebraic completeness.** Every multivariate real polynomial function is
  single-operator representable (`EMLOnlyRepresentable_mvPolynomial`), via the
  finite sum/product closure lemmas `EMLOnlyRepresentable_sum` and
  `EMLOnlyRepresentable_prod`.
* **Applications completeness.** Every standard smooth neural-network activation
  function — logistic sigmoid, softplus, `tanh`, SiLU/swish — is single-operator
  representable. A single binary primitive thus suffices to express the entire
  feed-forward activation toolkit, the concrete "Applications" face of the
  single-operator Church–Turing thesis.

## Main results

* `EMLOnlyRepresentable_sum`, `EMLOnlyRepresentable_prod`
* `EMLOnlyRepresentable_mvPolynomial`
* `EMLOnlyRepresentable_sigmoid`, `EMLOnlyRepresentable_softplus`,
  `EMLOnlyRepresentable_tanh`, `EMLOnlyRepresentable_silu`
-/
import EML.SingleOperatorChurchTuring

noncomputable section
open Real BigOperators MvPolynomial

/-
-- !-- Lab Notes -- !--
HYPOTHESIS (H2). The single-operator class contains all polynomials and all
standard neural activations. If so, the thesis has teeth in the "Applications"
domain: any function a feed-forward network computes from polynomial pre-activations
and a fixed smooth activation already lives in the single-operator class.

EXPERIMENT. (a) Lift the binary +/× closures to *finite* `Finset.sum`/`Finset.prod`
by `Finset.induction`, then evaluate an arbitrary `MvPolynomial` via
`MvPolynomial.eval_eq` (sum over support of `coeff · ∏ xᵢ^{dᵢ}`) and discharge
each factor with `EMLOnlyRepresentable_pow_nat`. (b) Express each activation as a
field-operation composite of `exp`/`log`/projection and apply the §3 closures of
`SingleOperatorChurchTuring`.

OUTCOME. Both go through cleanly.
  * Polynomial completeness reduces to: sum-closure ∘ (const × prod-closure ∘ pow).
  * sigmoid  = (1 + exp(−x))⁻¹                  [add, exp, neg, inv]
  * softplus = log(1 + exp x)                    [log, add, exp]
  * tanh     = sinh x · (cosh x)⁻¹               [mul, inv, sinh, cosh]
  * SiLU     = x · (1 + exp(−x))⁻¹               [mul, sigmoid]

INSIGHT. The activations never need the `log` half of `eml` except softplus; yet
they are *all* expressible because `exp` itself is only available *through* `eml`
(via `eml(·,1)`). So even "log-free looking" activations secretly exercise the
single primitive. This is the cleanest evidence that one binary operator is the
true generator.

FAILURE ANALYSIS. The only subtlety is that Mathlib's `Finset.induction` `insert`
case names the fresh element and the disjointness hypothesis; the membership
bookkeeping (`mem_insert_self`, `mem_insert_of_mem`) must be threaded explicitly.
`simpa [Finset.sum_insert, Finset.prod_insert]` then closes the recursion.
-/

variable {n : ℕ}

/-! ## §1. Finite sum and product closure -/

/-- Single-operator representability is closed under finite sums. -/
theorem EMLOnlyRepresentable_sum {ι : Type*} (s : Finset ι)
    (f : ι → (Fin n → ℝ) → ℝ) (h : ∀ i ∈ s, EMLOnlyRepresentable (f i)) :
    EMLOnlyRepresentable (fun x => ∑ i ∈ s, f i x) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using EMLOnlyRepresentable_const (n := n) 0
  | insert a s ha ih =>
    have := EMLOnlyRepresentable_add (h a (Finset.mem_insert_self a s))
      (ih (fun i hi => h i (Finset.mem_insert_of_mem hi)))
    simpa [Finset.sum_insert ha] using this

/-- Single-operator representability is closed under finite products. -/
theorem EMLOnlyRepresentable_prod {ι : Type*} (s : Finset ι)
    (f : ι → (Fin n → ℝ) → ℝ) (h : ∀ i ∈ s, EMLOnlyRepresentable (f i)) :
    EMLOnlyRepresentable (fun x => ∏ i ∈ s, f i x) := by
  classical
  induction s using Finset.induction with
  | empty => simpa using EMLOnlyRepresentable_const (n := n) 1
  | insert a s ha ih =>
    have := EMLOnlyRepresentable_mul (h a (Finset.mem_insert_self a s))
      (ih (fun i hi => h i (Finset.mem_insert_of_mem hi)))
    simpa [Finset.prod_insert ha] using this

/-! ## §2. Algebraic completeness: all polynomials are representable -/

/-- **Polynomial completeness.** Every multivariate real polynomial function is
    single-operator representable. The single primitive `eml` therefore captures
    the entire polynomial algebra `ℝ[x₁, …, xₙ]` as evaluated functions. -/
theorem EMLOnlyRepresentable_mvPolynomial (p : MvPolynomial (Fin n) ℝ) :
    EMLOnlyRepresentable (fun x : Fin n → ℝ => eval x p) := by
  have key : (fun x : Fin n → ℝ => eval x p)
      = (fun x => ∑ d ∈ p.support, p.coeff d * ∏ i ∈ d.support, x i ^ d i) := by
    funext x; rw [MvPolynomial.eval_eq]
  rw [key]
  refine EMLOnlyRepresentable_sum _ _ (fun d _ => ?_)
  exact EMLOnlyRepresentable_mul (EMLOnlyRepresentable_const _)
    (EMLOnlyRepresentable_prod _ _ (fun i _ => EMLOnlyRepresentable_pow_nat i (d i)))

/-! ## §3. Applications completeness: neural activation functions -/

/-- The logistic **sigmoid** `σ(x) = (1 + e^{−x})⁻¹` is single-operator
    representable. -/
theorem EMLOnlyRepresentable_sigmoid :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => (1 + Real.exp (-(x 0)))⁻¹) :=
  EMLOnlyRepresentable_inv
    (EMLOnlyRepresentable_add (EMLOnlyRepresentable_const (n := 1) 1)
      (EMLOnlyRepresentable_exp
        (EMLOnlyRepresentable_neg (EMLOnlyRepresentable_proj (0 : Fin 1)))))

/-- **softplus** `ζ(x) = log(1 + e^{x})` is single-operator representable. -/
theorem EMLOnlyRepresentable_softplus :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => Real.log (1 + Real.exp (x 0))) :=
  EMLOnlyRepresentable_log
    (EMLOnlyRepresentable_add (EMLOnlyRepresentable_const (n := 1) 1)
      (EMLOnlyRepresentable_exp (EMLOnlyRepresentable_proj (0 : Fin 1))))

/-- **tanh** is single-operator representable. -/
theorem EMLOnlyRepresentable_tanh :
    EMLOnlyRepresentable (fun x : Fin 1 → ℝ => Real.tanh (x 0)) := by
  have h := EMLOnlyRepresentable_mul EMLOnlyRepresentable_sinh
    (EMLOnlyRepresentable_inv EMLOnlyRepresentable_cosh)
  have e : (fun x : Fin 1 → ℝ => Real.sinh (x 0) * (Real.cosh (x 0))⁻¹)
      = (fun x : Fin 1 → ℝ => Real.tanh (x 0)) := by
    funext x; rw [Real.tanh_eq_sinh_div_cosh, div_eq_mul_inv]
  rwa [e] at h

/-- **SiLU / swish** `x ↦ x · σ(x)` is single-operator representable. -/
theorem EMLOnlyRepresentable_silu :
    EMLOnlyRepresentable
      (fun x : Fin 1 → ℝ => x 0 * (1 + Real.exp (-(x 0)))⁻¹) :=
  EMLOnlyRepresentable_mul (EMLOnlyRepresentable_proj (0 : Fin 1))
    EMLOnlyRepresentable_sigmoid

end