import Mathlib

/-!
# A finite mathematical model of transformer architecture

This file develops three elementary components of a transformer and culminates in an
exact finite universality theorem.  The attention model is *linear attention* (no
softmax): its score is a bilinear form and its heads are summed.  The universality
statement concerns functions on a finite set of fixed-length discrete sequences.  It
is therefore an exact lookup-table theorem, not a claim about standard softmax
transformers on arbitrary Euclidean compacta.
-/

open scoped BigOperators

namespace TransformerArchitecture

section BilinearAttention

variable {ι : Type*} [Fintype ι]

/-- A matrix-parametrized attention score, bilinear in its query and key. -/
def bilinearScore (W : Matrix ι ι ℝ) (q k : ι → ℝ) : ℝ :=
  ∑ i, q i * (W.mulVec k) i

/-- Matrix attention is additive in its query argument. -/
theorem bilinearScore_add_query (W : Matrix ι ι ℝ) (q₁ q₂ k : ι → ℝ) :
    bilinearScore W (q₁ + q₂) k =
      bilinearScore W q₁ k + bilinearScore W q₂ k := by
  simp [bilinearScore, add_mul, Finset.sum_add_distrib]

/-- Matrix attention is homogeneous in its query argument. -/
theorem bilinearScore_smul_query (W : Matrix ι ι ℝ) (c : ℝ) (q k : ι → ℝ) :
    bilinearScore W (c • q) k = c * bilinearScore W q k := by
  simp [bilinearScore, Finset.mul_sum, mul_assoc]

/-- Matrix attention is additive in its key argument. -/
theorem bilinearScore_add_key (W : Matrix ι ι ℝ) (q k₁ k₂ : ι → ℝ) :
    bilinearScore W q (k₁ + k₂) =
      bilinearScore W q k₁ + bilinearScore W q k₂ := by
  simp [bilinearScore, Matrix.mulVec, mul_add, Finset.sum_add_distrib]

/-- Matrix attention is homogeneous in its key argument. -/
theorem bilinearScore_smul_key (W : Matrix ι ι ℝ) (c : ℝ) (q k : ι → ℝ) :
    bilinearScore W q (c • k) = c * bilinearScore W q k := by
  simp [bilinearScore, Matrix.mulVec, Finset.mul_sum, mul_left_comm]

/-- The preceding four laws package the score as a bilinear form. -/
theorem bilinearScore_linear_combination
    (W : Matrix ι ι ℝ) (a b : ℝ) (q₁ q₂ k₁ k₂ : ι → ℝ) :
    bilinearScore W (a • q₁ + b • q₂) (k₁ + k₂) =
      a * (bilinearScore W q₁ k₁ + bilinearScore W q₁ k₂) +
      b * (bilinearScore W q₂ k₁ + bilinearScore W q₂ k₂) := by
  rw [bilinearScore_add_key, bilinearScore_add_query, bilinearScore_add_query,
    bilinearScore_smul_query, bilinearScore_smul_query,
    bilinearScore_smul_query, bilinearScore_smul_query]
  ring

end BilinearAttention

section PositionalAndNormalization

variable {ι : Type*}

/-- Additive positional encoding. -/
def positionalEncoding (position content : ι → ℝ) : ι → ℝ :=
  content + position

/-- Successive positional encodings compose by adding their position vectors. -/
theorem positionalEncoding_comp (p₁ p₂ x : ι → ℝ) :
    positionalEncoding p₂ (positionalEncoding p₁ x) =
      positionalEncoding (p₁ + p₂) x := by
  funext i
  simp [positionalEncoding, add_assoc, add_left_comm]

/-- The affine part of layer normalization, with coordinatewise scale and bias.

The data-dependent centering and variance normalization of standard layer
normalization is deliberately not called affine; this definition isolates its learned
affine post-transformation. -/
def affineNorm (scale bias x : ι → ℝ) : ι → ℝ :=
  fun i => scale i * x i + bias i

/-- Two learned affine normalization stages collapse to one affine stage. -/
theorem affineNorm_comp (s₁ b₁ s₂ b₂ x : ι → ℝ) :
    affineNorm s₂ b₂ (affineNorm s₁ b₁ x) =
      affineNorm (s₂ * s₁) (s₂ * b₁ + b₂) x := by
  funext i
  simp [affineNorm]
  ring

/-- An affine normalization after positional encoding expands coordinatewise as expected. -/
theorem affineNorm_positionalEncoding (s b p x : ι → ℝ) :
    affineNorm s b (positionalEncoding p x) =
      (fun i => s i * x i + (s i * p i + b i)) := by
  funext i
  simp [affineNorm, positionalEncoding]
  ring

end PositionalAndNormalization

section FiniteUniversality

variable {X Y : Type*} [Fintype X] [DecidableEq X]

/-- One-hot embedding of a finite token or an entire finite sequence. -/
def oneHot (x : X) : X → ℝ :=
  fun y => if y = x then 1 else 0

omit [Fintype X] in
/-- The one-hot coordinate at its represented input is one. -/
theorem oneHot_self (x : X) : oneHot x x = 1 := by
  simp [oneHot]

omit [Fintype X] in
/-- Distinct one-hot coordinates vanish. -/
theorem oneHot_ne {x y : X} (h : y ≠ x) : oneHot x y = 0 := by
  simp [oneHot, h]

/-- Dot-product attention between one-hot vectors is exact equality testing. -/
theorem oneHot_attention_score (x a : X) :
    (∑ i, oneHot x i * oneHot a i) = if x = a then 1 else 0 := by
  by_cases h : x = a
  · subst a
    simp [oneHot]
  · simp [oneHot, h, Ne.symm h]

/-- A head has a fixed key `a` and emits its value weighted by bilinear attention. -/
def lookupHead (f : X → Y → ℝ) (a x : X) : Y → ℝ :=
  fun y => (∑ i, oneHot x i * oneHot a i) * f a y

/-- A lookup head fires exactly on the input matching its key. -/
theorem lookupHead_eq (f : X → Y → ℝ) (a x : X) :
    lookupHead f a x = if x = a then f a else 0 := by
  funext y
  rw [show lookupHead f a x y =
    (∑ i, oneHot x i * oneHot a i) * f a y by rfl,
    oneHot_attention_score]
  by_cases h : x = a <;> simp [h]

/-- Multi-head attention uses one lookup head for every possible input. -/
def multiHeadLookup (f : X → Y → ℝ) (x : X) : Y → ℝ :=
  ∑ a, lookupHead f a x

/-- Summing all lookup heads exactly recovers the desired output. -/
theorem multiHeadLookup_exact (f : X → Y → ℝ) (x : X) :
    multiHeadLookup f x = f x := by
  classical
  simp [multiHeadLookup, lookupHead_eq]

/-- Every function between a finite input type and a finite real output vector is
represented exactly by a finite family of bilinear-attention lookup heads. -/
theorem finite_bilinear_attention_universal (f : X → Y → ℝ) :
    ∃ model : X → Y → ℝ, (∀ x, model x = multiHeadLookup f x) ∧ model = f := by
  refine ⟨multiHeadLookup f, ?_, ?_⟩
  · intro x
    exact rfl
  · funext x
    exact multiHeadLookup_exact f x

/-- Exact sequence-to-sequence universality for fixed-length sequences over finite
alphabets, with real output features.  A whole input sequence is treated as one
finite token, so the number of heads is the number of possible input sequences. -/
theorem finite_sequence_transformer_universal
    (InputToken : Type*) [Fintype InputToken] [DecidableEq InputToken]
    (inputLength outputLength outputWidth : ℕ)
    (f : (Fin inputLength → InputToken) → Fin outputLength → Fin outputWidth → ℝ)
    (x : Fin inputLength → InputToken) (i : Fin outputLength) (j : Fin outputWidth) :
    multiHeadLookup (fun sequence outputIndex =>
      f sequence outputIndex.1 outputIndex.2) x (i, j) = f x i j := by
  have h := multiHeadLookup_exact
    (X := Fin inputLength → InputToken)
    (Y := Fin outputLength × Fin outputWidth)
    (fun sequence outputIndex => f sequence outputIndex.1 outputIndex.2) x
  exact congrFun h (i, j)

end FiniteUniversality

end TransformerArchitecture