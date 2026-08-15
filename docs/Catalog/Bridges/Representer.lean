import Mathlib
/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Logic.GraphTheory.Defs

/-! # Tropical Representer Theorem: Main Results

## Main Results

### Theorem A: Abstract Tropical Representer Theorem
Any minimizer of a regularized empirical objective admits a representative in the
sample span, provided a retraction exists that preserves evaluations and does not
increase complexity.

### Theorem B: Kernel-Section Span Version
Specialization to tropical kernel combinations: every empirical minimizer has a
finite kernel expansion supported on the sample.

### Theorem C: Gram-Matrix Prediction Identity
Sample predictions of tropical combinations equal tropical Gram-matrix action,
reducing infinite-dimensional optimization to finite-dimensional coefficient space.

### Additional Results
* `objective_retract_le` — the objective does not increase under retraction
* `gramAction_mono` — tropical Gram action is monotone in coefficients
* `tropicalCombination_mono` — tropical combination is monotone in coefficients
* `gramMatrix_symm` — Gram matrix of symmetric kernel is symmetric
-/

noncomputable section

namespace TropicalRepresenter

/-! ## §1. Abstract Tropical Representer Theorem (Theorem A)

This is the core result. It works over any partial order and requires no algebraic
structure — the theorem is purely order-theoretic. The key insight is that
sample complexity in tropical learning is controlled by semimodule generation
(via retraction), not Hilbert orthogonality. -/

/-
**Abstract Tropical Representer Theorem (Theorem A)**.

Given:
- An abstract objective function on a hypothesis class,
- A designated sample span,
- A retraction that does not increase the objective,
- A global minimizer `f★`,

there exists `g` in the sample span with equal objective value.
-/
theorem abstract_representer
    {H S : Type*} [PartialOrder S]
    (SampleSpan : Set H)
    (objective : H → S)
    (retract : H → H)
    (h_retract_mem : ∀ f, retract f ∈ SampleSpan)
    (h_obj_retract : ∀ f, objective (retract f) ≤ objective f)
    {f_star : H}
    (hmin : ∀ f, objective f_star ≤ objective f)
    : ∃ g ∈ SampleSpan, objective g = objective f_star := by
  exact ⟨ retract f_star, h_retract_mem f_star, le_antisymm ( h_obj_retract f_star ) ( hmin _ ) ⟩

/-
**Representer theorem with strict improvement tracking**.
The representative not only equals the minimizer's objective but is itself a minimizer.
-/
theorem abstract_representer_minimizer
    {H S : Type*} [PartialOrder S]
    (SampleSpan : Set H)
    (objective : H → S)
    (retract : H → H)
    (h_retract_mem : ∀ f, retract f ∈ SampleSpan)
    (h_obj_retract : ∀ f, objective (retract f) ≤ objective f)
    {f_star : H}
    (hmin : ∀ f, objective f_star ≤ objective f)
    : ∃ g ∈ SampleSpan, (∀ f, objective g ≤ objective f) ∧
        objective g = objective f_star := by
  grind

/-! ## §2. Objective Decomposition: Loss + Regularizer -/

/-
**Objective retraction inequality**.
If loss depends only on sample evaluations (which the retraction preserves),
and the regularizer does not increase, then the composite objective does not increase.
-/
theorem objective_retract_le
    {S X : Type*} [SemilatticeSup S] [Mul S] [MulLeftMono S]
    {n : ℕ}
    (L : (Fin n → S) → (Fin n → S) → S)
    (x : Fin n → X) (y : Fin n → S)
    (Ω : (X → S) → S) (lam : S)
    (retract : (X → S) → (X → S))
    (h_eval : ∀ f i, retract f (x i) = f (x i))
    (h_Ω : ∀ f, Ω (retract f) ≤ Ω f)
    (f : X → S) :
    objective L x y Ω lam (retract f) ≤ objective L x y Ω lam f := by
  apply sup_le_sup;
  · unfold sampleEval; aesop;
  · exact mul_le_mul_right (h_Ω f) lam

/-! ## §3. Tropical Representer Theorem with Decomposed Objective -/

/-
**Tropical Representer Theorem with decomposed objective (Theorem A')**.

Full version with loss, regularizer, and retraction hypotheses explicitly stated.
-/
theorem tropical_representer_decomposed
    {S X : Type*} [SemilatticeSup S] [Mul S] [MulLeftMono S]
    {n : ℕ}
    (SampleSpan : Set (X → S))
    (L : (Fin n → S) → (Fin n → S) → S)
    (x : Fin n → X) (y : Fin n → S)
    (Ω : (X → S) → S) (lam : S)
    (retract : (X → S) → (X → S))
    (h_retract_mem : ∀ f, retract f ∈ SampleSpan)
    (h_eval : ∀ f i, retract f (x i) = f (x i))
    (h_Ω : ∀ f, Ω (retract f) ≤ Ω f)
    {f_star : X → S}
    (hmin : ∀ f, objective L x y Ω lam f_star ≤ objective L x y Ω lam f) :
    ∃ g ∈ SampleSpan,
      objective L x y Ω lam g = objective L x y Ω lam f_star := by
  -- Apply the abstract_representer theorem with the retraction that doesn't increase the objective and lands in the SampleSpan.
  apply abstract_representer SampleSpan (objective L x y Ω lam) retract h_retract_mem (objective_retract_le L x y Ω lam retract h_eval h_Ω) hmin

/-! ## §4. Gram-Matrix Prediction Identity (Theorem C) -/

/-
**Sample evaluation of tropical combination**:
    `(⨆ j, c j * K(x j, x i)) = ⨆ j, c j * G j i`.
-/
theorem sampleEval_tropicalCombination
    {S X : Type*} [CompleteLattice S] [Mul S]
    {n : ℕ}
    (K : X → X → S) (x : Fin n → X) (c : Fin n → S) (i : Fin n) :
    sampleEval x (tropicalCombination K x c) i =
      ⨆ j, c j * gramMatrix K x j i := by
  rfl

/-
**Gram-matrix prediction identity (Theorem C)**.

For any tropical combination with coefficients `c`, the sample predictions equal
the tropical Gram-matrix action.
-/
theorem prediction_eq_gram_action
    {S X : Type*} [CompleteLattice S] [Mul S]
    {n : ℕ}
    (K : X → X → S) (x : Fin n → X) (c : Fin n → S) :
    sampleEval x (tropicalCombination K x c) = predictFromCoeff (gramMatrix K x) c := by
  exact funext fun i => sampleEval_tropicalCombination K x c i

/-! ## §5. Kernel-Section Span Version (Theorem B) -/

/-
**Kernel-section span representer theorem (Theorem B)**.

Every empirical minimizer has a finite kernel expansion supported on the sample.
-/
theorem kernel_representer
    {S X : Type*} [CompleteLattice S] [Mul S] [MulLeftMono S]
    {n : ℕ}
    (K : X → X → S)
    (L : (Fin n → S) → (Fin n → S) → S)
    (x : Fin n → X) (y : Fin n → S)
    (Ω : (X → S) → S) (lam : S)
    (retract : (X → S) → (X → S))
    (h_retract_span : ∀ f, ∃ c : Fin n → S, retract f = tropicalCombination K x c)
    (h_eval : ∀ f i, retract f (x i) = f (x i))
    (h_Ω : ∀ f, Ω (retract f) ≤ Ω f)
    {f_star : X → S}
    (hmin : ∀ f, objective L x y Ω lam f_star ≤ objective L x y Ω lam f) :
    ∃ c : Fin n → S,
      objective L x y Ω lam (tropicalCombination K x c) =
        objective L x y Ω lam f_star := by
  -- Apply the retraction inequality to $f_star$.
  have h_retract_f_star : objective L x y Ω lam (retract f_star) ≤ objective L x y Ω lam f_star := by
    apply objective_retract_le L x y Ω lam retract h_eval h_Ω f_star;
  exact Exists.elim ( h_retract_span f_star ) fun c hc => ⟨ c, hc ▸ le_antisymm h_retract_f_star ( hmin _ ) ⟩

/-! ## §6. Monotonicity -/

/-
**Monotonicity of tropical Gram action**.
If coefficients are pointwise dominated, predictions are pointwise dominated.
Bridge: connects tropical order theory to certified ML robustness.
-/
theorem gramAction_mono
    {S : Type*} [CompleteLattice S] [Mul S] [MulRightMono S]
    {n : ℕ}
    (G : Matrix (Fin n) (Fin n) S) (c c' : Fin n → S)
    (hle : ∀ j, c j ≤ c' j) :
    ∀ i, predictFromCoeff G c i ≤ predictFromCoeff G c' i := by
  exact fun i => iSup_mono fun j => mul_le_mul_left ( hle j ) _

/-
**Monotonicity of tropical combination** in coefficients.
-/
theorem tropicalCombination_mono
    {S X : Type*} [CompleteLattice S] [Mul S] [MulRightMono S]
    {n : ℕ}
    (K : X → X → S) (x : Fin n → X) (c c' : Fin n → S)
    (hle : ∀ j, c j ≤ c' j) :
    ∀ z, tropicalCombination K x c z ≤ tropicalCombination K x c' z := by
  intro z
  unfold tropicalCombination;
  apply_rules [ iSup_mono ];
  exact fun i => mul_le_mul_left (hle i) (K (x i) z)

/-
**Gram matrix of a symmetric kernel is symmetric**.
-/
theorem gramMatrix_symm
    {S X : Type*} {n : ℕ}
    (K : X → X → S)
    (hK : ∀ x y, K x y = K y x)
    (x : Fin n → X) :
    ∀ i j, gramMatrix K x i j = gramMatrix K x j i := by
  exact fun i j => hK _ _

/-! ## §7. Finite-Dimensional Reduction -/

/-
**Finite-dimensional reduction**.
The representer theorem combined with the Gram identity shows that
optimization over `H_K` can be performed entirely in coefficient space.
-/
theorem finite_dimensional_reduction
    {S X : Type*} [CompleteLattice S] [Mul S] [MulLeftMono S]
    {n : ℕ}
    (K : X → X → S)
    (L : (Fin n → S) → (Fin n → S) → S)
    (x : Fin n → X) (y : Fin n → S)
    (Ω : (X → S) → S) (lam : S)
    (retract : (X → S) → (X → S))
    (h_retract_span : ∀ f, ∃ c : Fin n → S, retract f = tropicalCombination K x c)
    (h_eval : ∀ f i, retract f (x i) = f (x i))
    (h_Ω : ∀ f, Ω (retract f) ≤ Ω f)
    {f_star : X → S}
    (hmin : ∀ f, objective L x y Ω lam f_star ≤ objective L x y Ω lam f) :
    ∃ c : Fin n → S,
      L (predictFromCoeff (gramMatrix K x) c) y ⊔ (lam * Ω (tropicalCombination K x c)) =
        objective L x y Ω lam f_star := by
  convert TropicalRepresenter.kernel_representer K L x y Ω lam retract h_retract_span h_eval h_Ω hmin

end TropicalRepresenter

end