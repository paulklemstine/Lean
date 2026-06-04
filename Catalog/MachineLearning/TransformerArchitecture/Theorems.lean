/-
Copyright (c) 2025 Transformer Architecture Formalization. All rights reserved.
Released under Apache 2.0 license.

# Core Theorems of the Transformer Architecture

This file proves fundamental mathematical properties of the transformer
architecture components defined in `Defs.lean`.

## Main Results

1. **Softmax shift invariance** (`softmaxVec_shift_invariant`):
   softmax(x + c·1) = softmax(x). This is the fundamental gauge symmetry
   of the attention mechanism.

2. **Softmax probability distribution** (`softmaxVec_sum_eq_one`):
   The softmax output sums to 1, establishing it as a map to the simplex.

3. **Attention score bilinearity** (`attentionScore_bilinear_left`,
   `attentionScore_bilinear_right`): Pre-softmax scores are bilinear,
   justifying the "bilinear form" interpretation.

4. **Centered vector mean** (`vecCenter_mean_eq_zero`):
   Layer normalization centers data to zero mean.

5. **Layer depth composition** (`iterateLayer_add`):
   Transformer depth composes associatively.

6. **Attention score Gram factorization** (`attentionScore_eq_gram`):
   score(xᵢ, xⱼ) = xᵢᵀ · (WqᵀWk) · xⱼ.
-/

import Mathlib
import MachineLearning.TransformerArchitecture.Defs

noncomputable section

open Finset BigOperators Real Function

/-! ## §1. Softmax Shift Invariance

The softmax function is invariant under translation by a constant vector.
This is the mathematical expression of the fact that attention scores
are determined by *relative* magnitudes, not absolute values.

Proof: exp(xᵢ + c) / ∑ⱼ exp(xⱼ + c) = exp(c)·exp(xᵢ) / (exp(c)·∑ⱼ exp(xⱼ))
     = exp(xᵢ) / ∑ⱼ exp(xⱼ)
-/

/-
**Theorem 1 (Softmax Shift Invariance).**
For any vector x ∈ ℝⁿ and constant c ∈ ℝ,
  softmax(x + c·1) = softmax(x).
This is the gauge invariance of the attention mechanism.
-/
theorem softmaxVec_shift_invariant {n : ℕ} [NeZero n]
    (x : Fin n → ℝ) (c : ℝ) :
    softmaxVec (fun i => x i + c) = softmaxVec x := by
  unfold softmaxVec;
  norm_num [ Real.exp_add, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  exact funext fun i => mul_div_mul_right _ _ <| ne_of_gt <| Real.exp_pos _

/-! ## §2. Softmax as Probability Distribution -/

/-
**Theorem 2 (Softmax Probability Distribution).**
The outputs of softmax sum to 1: ∑ᵢ softmax(x)ᵢ = 1.
Combined with positivity, this establishes softmax as a map to the simplex.
-/
theorem softmaxVec_sum_eq_one {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    ∑ i : Fin n, softmaxVec x i = 1 := by
  unfold softmaxVec; rw [ ← Finset.sum_div ] ; rw [ div_self <| by exact ne_of_gt <| by exact Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) Finset.univ_nonempty ] ;

/-! ## §3. Attention Score Bilinearity

Pre-softmax attention scores form a bilinear map in the query and key
vectors. This is the mathematical justification for interpreting attention
as an inner product in a learned metric space.
-/

/-
**Theorem 3a (Left Linearity).** The attention score is linear in the
first (query) argument.
-/
theorem attentionScore_linear_left {d dₖ dᵥ : ℕ}
    (head : AttentionHead d dₖ dᵥ) (a b : ℝ) (x y z : Fin d → ℝ) :
    attentionScore head (fun i => a * x i + b * y i) z =
    a * attentionScore head x z + b * attentionScore head y z := by
  unfold attentionScore;
  norm_num [ Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_left_comm, Matrix.mulVec, dotProduct ];
  simp +decide only [sum_mul, mul_assoc, mul_left_comm, mul_sum]

/-
**Theorem 3b (Right Linearity).** The attention score is linear in the
second (key) argument.
-/
theorem attentionScore_linear_right {d dₖ dᵥ : ℕ}
    (head : AttentionHead d dₖ dᵥ) (a b : ℝ) (x y z : Fin d → ℝ) :
    attentionScore head z (fun i => a * x i + b * y i) =
    a * attentionScore head z x + b * attentionScore head z y := by
  unfold attentionScore;
  simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_left_comm, Finset.sum_mul ]

/-! ## §4. Layer Normalization: Zero Mean Property -/

/-
**Theorem 4 (Layer Norm Centering).**
The centered vector has zero mean: mean(x - mean(x)) = 0.
This is the fundamental algebraic property that layer normalization
projects onto the centered hyperplane {x : ∑ xᵢ = 0}.
-/
theorem vecCenter_sum_eq_zero {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    ∑ i : Fin n, vecCenter x i = 0 := by
  unfold vecCenter; norm_num [ Finset.sum_sub_distrib, vecMean ] ; ring;
  norm_num [ NeZero.ne ]

/-
Corollary: The centered vector has zero mean.
-/
theorem vecCenter_mean_eq_zero {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    vecMean (vecCenter x) = 0 := by
  convert div_eq_zero_iff.mpr ( Or.inl <| vecCenter_sum_eq_zero x ) using 1

/-! ## §5. Depth Composition -/

/-
**Theorem 5 (Depth Composition).**
Iterating a transformer layer L₁ + L₂ times is the same as iterating
L₁ times then L₂ times. This is the associativity of depth composition.
-/
theorem iterateLayer_add {α : Type*} (f : α → α) (m n : ℕ) (x : α) :
    iterateLayer f (m + n) x = iterateLayer f m (iterateLayer f n x) := by
  induction' m with m ih generalizing x <;> simp_all +decide [ Nat.succ_add, iterateLayer ]

/-! ## §6. Attention Score as Gram Matrix Product -/

/-
Auxiliary: matrix-vector multiplication is linear.
-/
lemma mulVec_linear_combo {m k : ℕ} (M : Matrix (Fin m) (Fin k) ℝ)
    (a b : ℝ) (x y : Fin k → ℝ) :
    M.mulVec (fun i => a * x i + b * y i) =
    fun j => a * (M.mulVec x) j + b * (M.mulVec y) j := by
  ext j; simp +decide [ Matrix.mulVec, dotProduct, Finset.mul_sum _ _ _, Finset.sum_add_distrib, mul_add, add_mul, mul_assoc, mul_left_comm, Finset.sum_mul ] ;

/-
**Theorem 6 (Gram Factorization).**
The attention score equals the bilinear form defined by the Gram matrix:
  score(xᵢ, xⱼ) = xᵢᵀ · (WqᵀWk) · xⱼ
This shows attention scores live in the spectral theory of WqᵀWk.
-/
theorem attentionScore_eq_gram {d dₖ dᵥ : ℕ}
    (head : AttentionHead d dₖ dᵥ) (xi xj : Fin d → ℝ) :
    attentionScore head xi xj =
    ∑ a : Fin d, xi a * ((attentionGramMatrix head).mulVec xj) a := by
  unfold attentionScore attentionGramMatrix; ring;
  simp +decide [ Matrix.mulVec, dotProduct ];
  simp +decide only [mul_comm, sum_mul, mul_assoc, Matrix.mul_apply, Matrix.transpose_apply];
  simp +decide only [Finset.mul_sum _ _ _, mul_left_comm];
  exact Eq.symm sum_comm_cycle

/-! ## §7. Residual Connection Properties -/

/-
**Theorem 7 (Residual Preserves Identity).**
When the learned function is zero, the residual connection is the identity.
This formalizes the intuition that residual connections enable the network
to "learn the identity" easily.
-/
theorem residualConnect_zero_is_id {n : ℕ} (x : Fin n → ℝ) :
    residualConnect (fun _ : Fin n → ℝ => (0 : Fin n → ℝ)) x = x := by
  unfold residualConnect; aesop;

/-
The composition of residual connections accumulates corrections:
    res(g, res(f, x)) = g(f(x) + x) + f(x) + x.
    Each layer adds a correction to the "residual stream".
-/
theorem residual_stream_decomposition {n : ℕ}
    (f g : (Fin n → ℝ) → (Fin n → ℝ)) (x : Fin n → ℝ) :
    residualConnect g (residualConnect f x) =
    g (f x + x) + (f x + x) := by
  rfl

/-! ## §8. Softmax Monotonicity -/

/-
**Theorem 8 (Softmax Preserves Order).**
If xᵢ ≤ xⱼ, then softmax(x)ᵢ ≤ softmax(x)ⱼ.
The attention mechanism assigns higher weight to keys with larger scores.
-/
theorem softmaxVec_monotone {n : ℕ} [NeZero n]
    (x : Fin n → ℝ) (i j : Fin n) (h : x i ≤ x j) :
    softmaxVec x i ≤ softmaxVec x j := by
  exact div_le_div_of_nonneg_right ( Real.exp_le_exp.mpr h ) ( Finset.sum_nonneg fun _ _ => Real.exp_nonneg _ )

end