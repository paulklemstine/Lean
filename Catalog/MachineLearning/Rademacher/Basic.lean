/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Rademacher Complexity of Hypothesis Classes — Foundations

This file formalizes the *empirical Rademacher complexity* of a finite family of
value-vectors (a hypothesis class evaluated on a fixed sample of size `n`) and
proves its core structural properties:

* `empRad_singleton`   — a single hypothesis has zero complexity (the Rademacher
  signs average to zero, `E_σ[σ] = 0`);
* `empRad_mono`        — complexity is monotone under class inclusion;
* `empRad_nonneg`      — every nonempty class has nonnegative complexity;
* `empRad_smul`        — positive homogeneity: scaling every hypothesis by `c ≥ 0`
  scales the complexity by `c`.

These are the analytic building blocks for the neural-network depth and weight
normalization results in `Rademacher/NeuralNet.lean`.

## Lab Notes

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The empirical Rademacher complexity, defined as an
average over the `2^n` sign patterns of the best in-class correlation, is a
genuine seminorm-like functional: monotone, positively homogeneous, and zero on
singletons because Rademacher signs are mean-zero.
Experiment (Experimenter): Defined `empRad` via `Finset.sup'` over the class and
a full average over `Fin n → Bool`. The decisive lemma is
`sum_sgn_coord_eq_zero`, proved by the coordinate-flip involution.
Analysis (Analyst): Singleton-zero is the algebraic shadow of `E[σ] = 0`;
monotonicity follows from `Finset.sup'_mono`; homogeneity from `Finset.sup'_image`
plus `Finset.mul_sup'`. The `c = 0` corner of homogeneity collapses the image to
the zero vector and is handled by singleton-zero.
Critique (Critic): All statements are non-vacuous (classes are nonempty); none is
`True`/`rfl`; each proof uses real combinatorial/order content.
Synthesis (PI): These four laws are exactly the interface the depth and
weight-normalization theorems consume downstream.
-- !-- Lab Notes -- !--
-/
import Mathlib

open scoped BigOperators

namespace Catalog.MachineLearning.Rademacher

/-- The real-valued Rademacher sign of a boolean: `true ↦ +1`, `false ↦ -1`. -/
noncomputable def sgn (b : Bool) : ℝ := if b then 1 else -1

@[simp] lemma sgn_true : sgn true = 1 := rfl
@[simp] lemma sgn_false : sgn false = -1 := rfl

lemma sgn_sq (b : Bool) : sgn b * sgn b = 1 := by cases b <;> norm_num [sgn]

/-- Empirical Rademacher complexity of a finite nonempty family `A` of
value-vectors `Fin n → ℝ` (the values of each hypothesis on the `n` sample
points): the average over all `2^n` sign patterns of the best correlation in the
class. -/
noncomputable def empRad (n : ℕ) (A : Finset (Fin n → ℝ)) (hA : A.Nonempty) : ℝ :=
  (1 / (2:ℝ)^n) * ∑ b : Fin n → Bool,
    A.sup' hA (fun a => (1 / (n:ℝ)) * ∑ i, sgn (b i) * a i)

/-
The Rademacher signs are mean-zero: summing `sgn (b i)` over all sign
patterns `b` cancels. This is the discrete `E_σ[σ_i] = 0`.
-/
lemma sum_sgn_coord_eq_zero (n : ℕ) (i : Fin n) :
    ∑ b : Fin n → Bool, sgn (b i) = 0 := by
  -- Let's pair each $b$ with $b'$, where $b'$ is obtained by flipping the $i$-th bit of $b$.
  have h_pair : ∑ b : Fin n → Bool, sgn (b i) = ∑ b : Fin n → Bool, sgn (!b i) := by
    apply Finset.sum_bij (fun b _ => Function.update b i (!b i));
    · grind;
    · intro a₁ _ a₂ _ h; ext j; by_cases hj : j = i <;> replace h := congr_fun h j <;> aesop;
    · exact fun b _ => ⟨ Function.update b i ( !b i ), Finset.mem_univ _, by aesop ⟩;
    · aesop;
  simp_all +decide [ sgn ];
  norm_num [ Finset.sum_ite ] at *;
  linarith

/-
**A single hypothesis has zero Rademacher complexity.** This is the algebraic
shadow of `E_σ[σ] = 0`: there is no class to correlate against, so the average
correlation vanishes.
-/
theorem empRad_singleton (n : ℕ) (a : Fin n → ℝ) :
    empRad n {a} (Finset.singleton_nonempty a) = 0 := by
  unfold empRad; simp +decide ;
  by_cases hn : n = 0 <;> simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  rw [ Finset.sum_comm ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sum_sgn_coord_eq_zero ]

/-- **Rademacher complexity is monotone under class inclusion**: a richer
hypothesis class can only have larger complexity. -/
theorem empRad_mono (n : ℕ) (A B : Finset (Fin n → ℝ)) (hA : A.Nonempty)
    (hAB : A ⊆ B) : empRad n A hA ≤ empRad n B (hA.mono hAB) := by
  unfold empRad
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply Finset.sum_le_sum
  intro b _
  exact Finset.sup'_mono _ hAB hA

/-- **Every nonempty class has nonnegative Rademacher complexity.** For a fixed
element `a₀` of the class, each per-pattern supremum dominates the correlation of
`a₀`, and these correlations average to zero (the signs are mean-zero), so the
average of the suprema is `≥ 0`. (No negation-closure assumption is needed.) -/
theorem empRad_nonneg (n : ℕ) (A : Finset (Fin n → ℝ)) (hA : A.Nonempty) :
    0 ≤ empRad n A hA := by
  refine' mul_nonneg _ _;
  · positivity;
  · refine' le_trans _ ( Finset.sum_le_sum fun b _ => Finset.le_sup' ( fun a => 1 / ( n : ℝ ) * ∑ i, sgn ( b i ) * a i ) ( hA.choose_spec ) );
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sum_sgn_coord_eq_zero ];
    rw [ Finset.sum_comm ];
    simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sum_sgn_coord_eq_zero ]

/-
**Positive homogeneity.** Scaling every hypothesis by a constant `c ≥ 0`
scales the Rademacher complexity by exactly `c`. This is the engine behind the
depth and weight-normalization results: a spectral-norm factor `c` on a layer
multiplies the complexity by `c`.
-/
theorem empRad_smul (n : ℕ) (A : Finset (Fin n → ℝ)) (hA : A.Nonempty)
    (c : ℝ) (hc : 0 ≤ c) :
    empRad n (A.image (fun a => fun i => c * a i)) (hA.image _)
      = c * empRad n A hA := by
  unfold empRad; simp +decide [ Finset.mul_sum _ _ _, mul_left_comm, * ] ;
  refine' Finset.sum_congr rfl fun i hi => _;
  simp +decide only [← Finset.mul_sum];
  grind +suggestions

end Catalog.MachineLearning.Rademacher