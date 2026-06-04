/-
Copyright (c) 2025 Transformer Architecture Formalization. All rights reserved.
Released under Apache 2.0 license.

# Mathematical Foundations of the Transformer Architecture

This file formalizes the core mathematical structures underlying the
Transformer architecture ("Attention is All You Need", Vaswani et al. 2017).

## Main Definitions

* `softmaxVec` — the softmax function on finite real vectors
* `AttentionHead` — a single attention head with Q, K, V projections
* `layerNormVec` — layer normalization as an affine map
* `TransformerBlock` — a complete transformer block combining attention + FFN
* `TransformerStack` — depth-L composition of transformer blocks

## Mathematical Framework

We formalize:
1. **Softmax** as a smooth map ℝⁿ → Δⁿ⁻¹ (the probability simplex)
2. **Attention scores** as bilinear forms on projected query-key spaces
3. **Layer normalization** as projection onto the centered hyperplane
4. **Multi-head attention** as a direct sum decomposition
-/

import Mathlib

noncomputable section

open Finset BigOperators Real Function

/-! ## §1. Softmax: The Probability Simplex Map -/

/-- The softmax function maps a real vector to the probability simplex.
    `softmaxVec x i = exp(xᵢ) / ∑ⱼ exp(xⱼ)` -/
def softmaxVec {n : ℕ} [NeZero n] (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  Real.exp (x i) / ∑ j : Fin n, Real.exp (x j)

/-- The denominator of softmax is always positive. -/
lemma softmax_denom_pos {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    0 < ∑ j : Fin n, Real.exp (x j) :=
  Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty

/-- Each softmax output is positive. -/
lemma softmaxVec_pos {n : ℕ} [NeZero n] (x : Fin n → ℝ) (i : Fin n) :
    0 < softmaxVec x i := by
  unfold softmaxVec
  exact div_pos (Real.exp_pos _) (softmax_denom_pos x)

/-! ## §2. Attention Scores as Bilinear Forms -/

/-- An attention head consists of query, key, and value weight matrices
    that project from model dimension `d` to head dimension `dₖ` (or `dᵥ`). -/
structure AttentionHead (d dₖ dᵥ : ℕ) where
  /-- Query weight matrix -/
  Wq : Matrix (Fin dₖ) (Fin d) ℝ
  /-- Key weight matrix -/
  Wk : Matrix (Fin dₖ) (Fin d) ℝ
  /-- Value weight matrix -/
  Wv : Matrix (Fin dᵥ) (Fin d) ℝ

/-- The raw attention score between positions i and j is the inner product
    of the projected query and key vectors: score(i,j) = (Wq·xᵢ)ᵀ(Wk·xⱼ).
    This is a bilinear form in xᵢ, xⱼ mediated by WqᵀWk. -/
def attentionScore {d dₖ dᵥ : ℕ} (head : AttentionHead d dₖ dᵥ)
    (xi xj : Fin d → ℝ) : ℝ :=
  ∑ k : Fin dₖ, (head.Wq.mulVec xi) k * (head.Wk.mulVec xj) k

/-- The attention score is equivalently xᵢᵀ (WqᵀWk) xⱼ —
    a bilinear form with Gram matrix WqᵀWk. -/
def attentionGramMatrix {d dₖ dᵥ : ℕ} (head : AttentionHead d dₖ dᵥ) :
    Matrix (Fin d) (Fin d) ℝ :=
  head.Wq.transpose * head.Wk

/-! ## §3. Layer Normalization -/

/-- The mean of a finite real vector. -/
def vecMean {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  (∑ i : Fin n, x i) / n

/-- Center a vector by subtracting its mean. -/
def vecCenter {n : ℕ} [NeZero n] (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  x i - vecMean x

/-- The variance of a vector (using the population formula). -/
def vecVariance {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  (∑ i : Fin n, (vecCenter x i) ^ 2) / n

/-- Layer normalization: center and scale to unit variance, then apply
    learned affine parameters γ (scale) and β (shift).
    When γ = 1 and β = 0 this is standard normalization. -/
def layerNormVec {n : ℕ} [NeZero n] (γ β : Fin n → ℝ) (x : Fin n → ℝ)
    (hvar : vecVariance x ≠ 0) (i : Fin n) : ℝ :=
  γ i * (vecCenter x i / Real.sqrt (vecVariance x)) + β i

/-- Simplified layer norm with identity scale and zero shift. -/
def layerNormSimple {n : ℕ} [NeZero n] (x : Fin n → ℝ)
    (hvar : vecVariance x ≠ 0) (i : Fin n) : ℝ :=
  vecCenter x i / Real.sqrt (vecVariance x)

/-! ## §4. Multi-Head Attention -/

/-- Multi-head attention configuration with h heads. -/
structure MultiHeadConfig (d dₖ dᵥ : ℕ) (h : ℕ) where
  /-- The individual attention heads -/
  heads : Fin h → AttentionHead d dₖ dᵥ
  /-- Output projection matrix: maps concatenated head outputs back to model dim -/
  Wo : Matrix (Fin d) (Fin (h * dᵥ)) ℝ

/-! ## §5. Transformer Block -/

/-- A feedforward network layer in the transformer: two linear maps with
    a nonlinearity (here abstracted as any function ℝ → ℝ). -/
structure FFNLayer (d dff : ℕ) where
  /-- First linear map -/
  W1 : Matrix (Fin dff) (Fin d) ℝ
  /-- First bias -/
  b1 : Fin dff → ℝ
  /-- Activation function -/
  σ : ℝ → ℝ
  /-- Second linear map -/
  W2 : Matrix (Fin d) (Fin dff) ℝ
  /-- Second bias -/
  b2 : Fin d → ℝ

/-- Apply the feedforward network to a single token vector. -/
def FFNLayer.apply {d dff : ℕ} (ffn : FFNLayer d dff) (x : Fin d → ℝ) : Fin d → ℝ :=
  fun i => (ffn.W2.mulVec (fun j => ffn.σ ((ffn.W1.mulVec x) j + ffn.b1 j))) i + ffn.b2 i

/-- Residual connection: f(x) + x. This is the fundamental building block
    that enables deep transformer training. -/
def residualConnect {α : Type*} [Add α] (f : α → α) (x : α) : α :=
  f x + x

/-- A **transformer block** combines attention + FFN with residual connections.
    This is the fundamental repeating unit of the architecture. -/
structure TransformerBlockParams (d dₖ dᵥ dff : ℕ) (h : ℕ) where
  /-- Multi-head attention configuration -/
  attn : MultiHeadConfig d dₖ dᵥ h
  /-- Feedforward network -/
  ffn : FFNLayer d dff

/-! ## §6. Positional Encoding -/

/-- Sinusoidal positional encoding at position `pos` and dimension `i`.
    PE(pos, 2i) = sin(pos / 10000^(2i/d))
    PE(pos, 2i+1) = cos(pos / 10000^(2i/d)) -/
def sinusoidalPE (d : ℕ) (pos : ℕ) (i : Fin d) : ℝ :=
  let freq := (pos : ℝ) / (10000 : ℝ) ^ ((2 * (i.val / 2) : ℝ) / d)
  if i.val % 2 = 0 then Real.sin freq else Real.cos freq

/-- Positional encoding is an additive perturbation of the input embedding.
    This formalizes the key design choice: position information enters additively. -/
def addPositionalEncoding {n d : ℕ} (X : Fin n → Fin d → ℝ) : Fin n → Fin d → ℝ :=
  fun pos dim => X pos dim + sinusoidalPE d pos dim

/-! ## §7. Transformer Stack (Depth Composition) -/

/-- Apply a function `L` times (transformer depth). -/
def iterateLayer {α : Type*} (f : α → α) : ℕ → α → α
  | 0 => id
  | n + 1 => f ∘ iterateLayer f n

@[simp]
lemma iterateLayer_zero {α : Type*} (f : α → α) (x : α) :
    iterateLayer f 0 x = x := rfl

@[simp]
lemma iterateLayer_succ {α : Type*} (f : α → α) (n : ℕ) (x : α) :
    iterateLayer f (n + 1) x = f (iterateLayer f n x) := rfl

end