import Mathlib

/-!
# Dimension-safe multi-head plumbing: projections, concatenation, residuals, feed-forward

The catalog transformer file works with a single bilinear score and one head per input.  This
file adds the standard architectural plumbing with dimension-safe matrix types and proves the
structural facts that make it meaningful:

* `qkScore_eq_bilinear` — separate query/key projections are *exactly* the bilinear score of
  the catalog file, with matrix `WQᵀ * WK`;
* `rank_qk_le_headDim` and `qk_ne_one_of_headDim_lt` — the **low-rank bottleneck**: a head of
  width `dk` can only realize score matrices of rank at most `dk`, so for `dk < d` no head can
  implement the identity score pattern.  This is an architectural lower bound;
* `outputProj_concat` — the standard identity that an output projection applied to the
  concatenation of heads is the sum of per-head projections, i.e. multi-head attention is a
  sum of independent head contributions;
* `residual_injective_of_lipschitz` — residual connections with a contractive block are
  injective (information preserving);
* `ffn_pos_homogeneous` — an unbiased ReLU feed-forward block is positively homogeneous.
-/

open scoped BigOperators
open Matrix

namespace MultiHeadPlumbing

section Projections

variable {d dk : ℕ}

/-- Scaled dot-product score computed through explicit query and key projections. -/
def qkScore (WQ WK : Matrix (Fin dk) (Fin d) ℝ) (q k : Fin d → ℝ) : ℝ :=
  (WQ *ᵥ q) ⬝ᵥ (WK *ᵥ k)

/-- **Query/key projections are exactly a bilinear form.**  The learned score matrix is
`WQᵀ * WK`. -/
theorem qkScore_eq_bilinear (WQ WK : Matrix (Fin dk) (Fin d) ℝ) (q k : Fin d → ℝ) :
    qkScore WQ WK q k = q ⬝ᵥ ((WQᵀ * WK) *ᵥ k) := by
  simp only [qkScore]
  symm
  rw [Matrix.dotProduct_mulVec, ← Matrix.vecMul_vecMul, Matrix.vecMul_transpose,
    ← Matrix.dotProduct_mulVec]

/-- **Low-rank bottleneck.**  The score matrix of a head of width `dk` has rank at most `dk`. -/
theorem rank_qk_le_headDim (WQ WK : Matrix (Fin dk) (Fin d) ℝ) :
    (WQᵀ * WK).rank ≤ dk := by
  refine le_trans (Matrix.rank_mul_le_left _ _) ?_
  exact Matrix.rank_le_width WQᵀ

/-- **An architectural obstruction.**  If the head width is smaller than the model width, no
query/key pair realizes the identity score pattern (exact self-matching). -/
theorem qk_ne_one_of_headDim_lt (h : dk < d) (WQ WK : Matrix (Fin dk) (Fin d) ℝ) :
    WQᵀ * WK ≠ (1 : Matrix (Fin d) (Fin d) ℝ) := by
  intro hcontra
  have h1 : (WQᵀ * WK).rank = d := by
    rw [hcontra]
    simp [Matrix.rank_one]
  have h2 := rank_qk_le_headDim WQ WK
  omega

end Projections

section Concatenation

variable {H dv d : ℕ}

/-- Concatenate the outputs of `H` heads, each of width `dv`, into one vector. -/
def concatHeads (v : Fin H → Fin dv → ℝ) : Fin H × Fin dv → ℝ := fun p => v p.1 p.2

/-- The block of the output projection acting on head `h`. -/
def outputBlock (WO : Matrix (Fin d) (Fin H × Fin dv) ℝ) (h : Fin H) :
    Matrix (Fin d) (Fin dv) ℝ := fun i b => WO i (h, b)

/-- **Multi-head attention is a sum of independent head contributions.**  Applying the output
projection to the concatenation of the heads equals summing the per-head block projections. -/
theorem outputProj_concat (WO : Matrix (Fin d) (Fin H × Fin dv) ℝ)
    (v : Fin H → Fin dv → ℝ) :
    WO *ᵥ concatHeads v = ∑ h, (outputBlock WO h) *ᵥ (v h) := by
  funext i
  simp only [Matrix.mulVec, dotProduct, concatHeads, outputBlock, Finset.sum_apply,
    Fintype.sum_prod_type]

end Concatenation

section Residual

variable {E : Type*} [NormedAddCommGroup E]

/-- A residual block. -/
def residual (f : E → E) (x : E) : E := x + f x

/-- Residual connections with a contractive block are injective: no information is lost. -/
theorem residual_injective_of_lipschitz (f : E → E) (L : ℝ) (hL : L < 1)
    (hf : ∀ x y, ‖f x - f y‖ ≤ L * ‖x - y‖) :
    Function.Injective (residual f) := by
  intro x y hxy
  have h : x + f x = y + f y := hxy
  have hkey : ‖x - y‖ ≤ L * ‖x - y‖ := by
    have hz : (x - y) + (f x - f y) = 0 := by
      have hab : (x - y) + (f x - f y) = (x + f x) - (y + f y) := by abel
      rw [hab, h, sub_self]
    have h2 : x - y = -(f x - f y) := eq_neg_of_add_eq_zero_left hz
    calc ‖x - y‖ = ‖f x - f y‖ := by rw [h2, norm_neg]
      _ ≤ L * ‖x - y‖ := hf x y
  have hnn : 0 ≤ ‖x - y‖ := norm_nonneg _
  have : ‖x - y‖ = 0 := by nlinarith
  have := norm_eq_zero.mp this
  exact sub_eq_zero.mp this

/-- Stacking a residual block on top of another. -/
theorem residual_comp (f g : E → E) (x : E) :
    residual f (residual g x) = x + g x + f (x + g x) := rfl

end Residual

section FeedForward

variable {d dff : ℕ}

/-- Rectified linear unit. -/
def relu (t : ℝ) : ℝ := max t 0

/-- An unbiased two-layer ReLU feed-forward block. -/
def ffn (W₁ : Matrix (Fin dff) (Fin d) ℝ) (W₂ : Matrix (Fin d) (Fin dff) ℝ)
    (x : Fin d → ℝ) : Fin d → ℝ :=
  W₂ *ᵥ (fun j => relu ((W₁ *ᵥ x) j))

theorem relu_smul {c t : ℝ} (hc : 0 ≤ c) : relu (c * t) = c * relu t := by
  simp only [relu]
  by_cases ht : 0 ≤ t
  · rw [max_eq_left (by positivity), max_eq_left ht]
  · push_neg at ht
    rw [max_eq_right (by nlinarith), max_eq_right (le_of_lt ht), mul_zero]

/-- **Positive homogeneity of the unbiased feed-forward block.** -/
theorem ffn_pos_homogeneous (W₁ : Matrix (Fin dff) (Fin d) ℝ) (W₂ : Matrix (Fin d) (Fin dff) ℝ)
    (c : ℝ) (hc : 0 ≤ c) (x : Fin d → ℝ) :
    ffn W₁ W₂ (fun i => c * x i) = fun i => c * ffn W₁ W₂ x i := by
  funext i
  simp only [ffn, Matrix.mulVec, dotProduct]
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun j _ => ?_
  have hinner : ∑ a, W₁ j a * (c * x a) = c * ∑ a, W₁ j a * x a := by
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun a _ => by ring
  rw [hinner, relu_smul hc]
  ring

end FeedForward

end MultiHeadPlumbing