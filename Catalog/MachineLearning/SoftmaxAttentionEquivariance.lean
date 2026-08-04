import Mathlib

/-!
# Permutation equivariance of scaled dot-product attention

This file formalizes standard row-wise softmax attention
`A(Q,K,V) = softmax(QKᵀ / √d) V` on finite token and feature types.
Its main theorem proves exact equivariance under an arbitrary simultaneous permutation
of the query, key, and value token axes.  Further results establish positivity,
row-stochasticity, preservation of constant values, and closure under stacking.
-/

open scoped BigOperators

namespace SoftmaxAttention

variable {ι κ ν : Type*} [Fintype ι] [Fintype κ]

/-- Scaled dot-product score.  The positive parameter `scale` represents `√d`. -/
noncomputable def scaledScore (scale : ℝ) (q k : κ → ℝ) : ℝ :=
  (∑ a, q a * k a) / scale

/-- The normalizing denominator in one row of softmax attention. -/
noncomputable def softmaxDenom (scale : ℝ) (q : ι → κ → ℝ) (k : ι → κ → ℝ) (i : ι) : ℝ :=
  ∑ j, Real.exp (scaledScore scale (q i) (k j))

/-- A row-wise softmax attention weight. -/
noncomputable def softmaxWeight (scale : ℝ) (q : ι → κ → ℝ) (k : ι → κ → ℝ)
    (i j : ι) : ℝ :=
  Real.exp (scaledScore scale (q i) (k j)) / softmaxDenom scale q k i

/-- Standard scaled dot-product attention applied to a value tensor. -/
noncomputable def attention (scale : ℝ) (q : ι → κ → ℝ) (k : ι → κ → ℝ)
    (v : ι → ν → ℝ) (i : ι) (b : ν) : ℝ :=
  ∑ j, softmaxWeight scale q k i j * v j b

/-- Reindex a token-indexed tensor by a permutation. -/
def permute (σ : Equiv.Perm ι) (x : ι → κ → ℝ) : ι → κ → ℝ :=
  fun i => x (σ.symm i)

/-- Every softmax denominator is strictly positive on a nonempty token type. -/
theorem softmaxDenom_pos [Nonempty ι] (scale : ℝ) (q k : ι → κ → ℝ) (i : ι) :
    0 < softmaxDenom scale q k i := by
  simp [softmaxDenom]
  exact Finset.sum_pos (fun j _ => Real.exp_pos _) ⟨i, Finset.mem_univ i⟩

/-- Every softmax attention weight is strictly positive. -/
theorem softmaxWeight_pos [Nonempty ι] (scale : ℝ) (q k : ι → κ → ℝ) (i j : ι) :
    0 < softmaxWeight scale q k i j := by
  apply div_pos (Real.exp_pos _) (softmaxDenom_pos scale q k i)

/-- Each row of the softmax attention matrix sums exactly to one. -/
theorem sum_softmaxWeight [Nonempty ι] (scale : ℝ) (q k : ι → κ → ℝ) (i : ι) :
    ∑ j, softmaxWeight scale q k i j = 1 := by
  simp_rw [softmaxWeight, softmaxDenom]
  rw [← Finset.sum_div, div_self]
  exact ne_of_gt (Finset.sum_pos' (fun _ _ => le_of_lt (Real.exp_pos _)) ⟨i, Finset.mem_univ i, Real.exp_pos _⟩)

/-- Simultaneous token permutation transports each attention weight by the same permutation. -/
theorem softmaxWeight_permute (σ : Equiv.Perm ι) (scale : ℝ)
    (q k : ι → κ → ℝ) (i j : ι) :
    softmaxWeight scale (permute σ q) (permute σ k) (σ i) (σ j) =
      softmaxWeight scale q k i j := by
  simp [softmaxWeight, softmaxDenom, permute]
  congr 1
  rw [Equiv.sum_comp (σ.symm) (fun x => Real.exp (scaledScore scale (q i) (k x)))]

/-- **Permutation equivariance of scaled dot-product softmax attention.**
Simultaneously permuting queries, keys, and values permutes the output token axis and
changes no feature value. -/
theorem attention_permutation_equivariant (σ : Equiv.Perm ι) (scale : ℝ)
    (q k : ι → κ → ℝ) (v : ι → ν → ℝ) (i : ι) (b : ν) :
    attention scale (permute σ q) (permute σ k) (permute σ v) (σ i) b =
      attention scale q k v i b := by
  simp_rw [attention, permute]
  conv_lhs => rw [← Equiv.sum_comp σ]
  simp [softmaxWeight_permute]

/-- Attention preserves a value tensor that is constant across token positions. -/
theorem attention_constant [Nonempty ι] (scale : ℝ) (q k : ι → κ → ℝ)
    (c : ν → ℝ) (i : ι) (b : ν) :
    attention scale q k (fun _ => c) i b = c b := by
  simp [attention, ← Finset.sum_mul, sum_softmaxWeight]

omit [Fintype ι] [Fintype κ] in
/-- Pointwise composition of permutation-equivariant token maps remains equivariant.
This is the formal closure principle used when stacking equivariant attention layers. -/
theorem equivariant_comp
    (σ : Equiv.Perm ι) (f g : (ι → κ → ℝ) → (ι → κ → ℝ))
    (hf : ∀ x i b, f (permute σ x) (σ i) b = f x i b)
    (hg : ∀ x i b, g (permute σ x) (σ i) b = g x i b) :
    ∀ x i b, (f ∘ g) (permute σ x) (σ i) b = (f ∘ g) x i b := by
  intro x i b
  simp only [Function.comp_apply]
  have hg' : g (permute σ x) = permute σ (g x) := by
    funext i'
    funext b'
    have := hg x (σ.symm i') b'
    rwa [Equiv.apply_symm_apply] at this
  rw [hg', hf]

end SoftmaxAttention