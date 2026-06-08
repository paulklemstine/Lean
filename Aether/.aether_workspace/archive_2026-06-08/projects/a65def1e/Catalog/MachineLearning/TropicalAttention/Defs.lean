import Mathlib

/-!
# Tropical Attention: Definitions

Core definitions for the tropical semantics of transformer attention.
These definitions formalize the bridge between softmax attention at temperature τ
and max-plus (tropical) matrix algebra.

## Main Definitions

* `tropMul` — Max-plus tropical matrix product
* `lseMul` — Temperature-scaled log-sum-exp matrix product
* `scoreMatrix` — Query-key dot product score matrix
* `softmaxWeight` — Softmax attention weight at temperature τ
* `softmaxAttnOutput` — Full softmax attention output
* `tropLin` — Tropical (max-plus) linear operator
* `tropLinIter` — Iterated tropical linear operator
* `maxEntry` — Maximum entry of a matrix
* `IsDominantColumn` — Strict dominance predicate for attention sinks
-/

noncomputable section

open Finset BigOperators Real Matrix

/-! ## Tropical and Log-Sum-Exp Matrix Products -/

/-- Max-plus tropical matrix product: `(tropMul X Y)_{ij} = max_k (X_{ik} + Y_{kj})`.
    This is the fundamental operation in max-plus (tropical) algebra applied to matrices. -/
def tropMul {m n p : ℕ} [Nonempty (Fin n)]
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ :=
  fun i j => Finset.univ.sup' Finset.univ_nonempty (fun k => X i k + Y k j)

/-- Temperature-scaled log-sum-exp matrix product:
    `(lseMul τ X Y)_{ij} = τ * log(∑_k exp((X_{ik} + Y_{kj}) / τ))`.
    As τ → 0⁺, this converges to `tropMul X Y`. -/
def lseMul {m n p : ℕ}
    (τ : ℝ)
    (X : Matrix (Fin m) (Fin n) ℝ)
    (Y : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ :=
  fun i j => τ * Real.log (∑ k : Fin n, Real.exp ((X i k + Y k j) / τ))

/-! ## Score Matrix and Attention -/

/-- Score matrix from query and key matrices: `S_{ij} = Q_i · K_j`. -/
def scoreMatrix {n d : ℕ}
    (Q K : Matrix (Fin n) (Fin d) ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  fun i j => ∑ k, Q i k * K j k

/-- Softmax weight for row `i`, column `j` at temperature `τ`:
    `W^τ_{ij} = exp(S_{ij}/τ) / ∑_k exp(S_{ik}/τ)`. -/
def softmaxWeight {n : ℕ}
    (S : Matrix (Fin n) (Fin n) ℝ) (τ : ℝ) (i j : Fin n) : ℝ :=
  Real.exp (S i j / τ) / ∑ k : Fin n, Real.exp (S i k / τ)

/-- Softmax attention output: `(W^τ V)_{ik} = ∑_j softmaxWeight(S,τ,i,j) * V_{jk}`. -/
def softmaxAttnOutput {n d : ℕ}
    (S : Matrix (Fin n) (Fin n) ℝ) (V : Matrix (Fin n) (Fin d) ℝ)
    (τ : ℝ) (i : Fin n) (k : Fin d) : ℝ :=
  ∑ j : Fin n, softmaxWeight S τ i j * V j k

/-! ## Tropical Linear Operator and Iterates -/

/-- Tropical (max-plus) linear action: `(tropLin A x)_i = max_j (A_{ij} + x_j)`. -/
def tropLin {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j + x j)

/-- Iterated tropical linear action. -/
def tropLinIter {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → (Fin n → ℝ) → (Fin n → ℝ)
  | 0 => id
  | t + 1 => tropLin A ∘ tropLinIter A t

/-- Maximum entry of a matrix. -/
def maxEntry {n : ℕ} [Nonempty (Fin n)]
    (A : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty
    (fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => A i j))

/-! ## Tropical Attention from Scores -/

/-- Predicate: `j` achieves the maximum score in row `i`. -/
def IsRowArgmax {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) : Prop :=
  ∀ k : Fin n, A i k ≤ A i j

/-- Predicate: `j` is the *unique* maximizer in row `i` with gap `δ > 0`. -/
def IsStrictRowArgmax {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) (δ : ℝ) : Prop :=
  ∀ k : Fin n, k ≠ j → A i j ≥ A i k + δ

/-! ## Dominance and Sink Predicates -/

/-- Predicate: column `jStar` is strictly dominant in every row by gap `δ`.
    This formalizes the "attention sink" phenomenon where one token absorbs
    all attention mass in the tropical limit. -/
def IsDominantColumn {n : ℕ}
    (A : Matrix (Fin n) (Fin n) ℝ) (jStar : Fin n) (δ : ℝ) : Prop :=
  ∀ i j, j ≠ jStar → A i jStar ≥ A i j + δ

/-! ## Multi-Head Attention -/

/-- Single-head tropical attention output: selects row of V by row argmax of scores.
    When each row of A has a unique argmax `j_i`, the output is `V_{j_i}`. -/
def tropAttnWithSelector {n d : ℕ}
    (V : Matrix (Fin n) (Fin d) ℝ)
    (selector : Fin n → Fin n) :
    Matrix (Fin n) (Fin d) ℝ :=
  fun i k => V (selector i) k

/-- Multi-head tropical attention: applies tropical attention independently per head.
    This computes in the product semiring `∏_{r<h} (ℝ, max, +)`. -/
def tropMultiHead {h n d : ℕ}
    (V : Fin h → Matrix (Fin n) (Fin d) ℝ)
    (selectors : Fin h → Fin n → Fin n) :
    Fin h → Matrix (Fin n) (Fin d) ℝ :=
  fun r => tropAttnWithSelector (V r) (selectors r)

end