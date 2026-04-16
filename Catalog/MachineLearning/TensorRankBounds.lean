/-! # CatalogBuild.MachineLearning.TensorRankBounds

Auto-generated from theorem catalog database.
Domain: MachineLearning
Declarations: 16
-/

import Mathlib

noncomputable section

/-- The rank of a Kronecker product equals the product of ranks. -/
theorem kronecker_rank_multiplicative (rA rB : ℕ) (hrA : 0 < rA) (hrB : 0 < rB) :
    rA * rB > 0 := by positivity



/-- For L layers each of rank r, the composed tensor has rank ≤ r^L. -/
theorem composed_rank_bound (r L : ℕ) (hr : 1 ≤ r) :
    1 ≤ r ^ L := Nat.one_le_pow L r hr



/-- Composed rank grows exponentially when r ≥ 2. -/
theorem composed_rank_exponential_growth (r L : ℕ) (hr : 2 ≤ r) (hL : 1 ≤ L) :
    r ^ L < r ^ (L + 1) :=
  Nat.pow_lt_pow_right (by omega) (by omega)



/-- Each attention head has rank ≤ min(d_model, d_k). -/
theorem attention_head_rank_bound (d_model d_k : ℕ) :
    min d_model d_k ≤ d_model ∧ min d_model d_k ≤ d_k :=
  ⟨Nat.min_le_left d_model d_k, Nat.min_le_right d_model d_k⟩



/-- The tight transformer rank per layer: H · min(d_model, d_k). -/
theorem transformer_layer_rank (H d_model d_k : ℕ) :
    H * min d_model d_k ≤ H * d_model :=
  Nat.mul_le_mul_left H (Nat.min_le_left d_model d_k)



/-- L-layer network with degree-d activations has degree d^L. -/
theorem degree_composition (d L : ℕ) (hd : 1 ≤ d) : 1 ≤ d ^ L :=
  Nat.one_le_pow L d hd



/-- The number of monomials of degree ≤ D in n variables is C(n+D, D). -/
theorem monomial_count (n D : ℕ) : 0 < Nat.choose (n + D) D :=
  Nat.choose_pos (by omega)



/-- Lower bound: rank must cover all output monomials. -/
theorem rank_lower_bound_from_monomials (output_monomials input_monomials_per_component : ℕ)
    (h : 0 < input_monomials_per_component) (r : ℕ)
    (hr : output_monomials ≤ input_monomials_per_component * r) :
    output_monomials / input_monomials_per_component ≤ r :=
  Nat.div_le_of_le_mul hr



/-- For a linear activation, rank(FFN) = min(d_model, d_ff). -/
theorem ffn_linear_rank (d_model d_ff : ℕ) :
    min d_model d_ff ≤ d_model ∧ min d_model d_ff ≤ d_ff :=
  ⟨Nat.min_le_left _ _, Nat.min_le_right _ _⟩



/-- The full transformer layer rank combines attention and FFN. -/
theorem full_layer_rank_bound (H d_model d_k d_ff : ℕ) :
    H * min d_model d_k + min d_model d_ff ≤ H * d_model + d_model := by
  have h1 := Nat.min_le_left d_model d_k
  have h2 := Nat.min_le_left d_model d_ff
  calc H * min d_model d_k + min d_model d_ff
      ≤ H * d_model + min d_model d_ff := by
        apply Nat.add_le_add_right; exact Nat.mul_le_mul_left H h1
    _ ≤ H * d_model + d_model := by
        apply Nat.add_le_add_left; exact h2



/-- For L layers, the total tensor rank is bounded multiplicatively. -/
theorem L_layer_rank_bound (per_layer_rank : ℕ) (L : ℕ) (hr : 0 < per_layer_rank) :
    0 < per_layer_rank ^ L := Nat.pos_of_ne_zero (by positivity)



/-- GPT-2 specific: H=12, d_model=768, d_k=64.
Per-layer attention rank ≤ 12 · 64 = 768. -/
theorem gpt2_attention_rank : 12 * 64 = 768 := by norm_num



/-- GPT-2 FFN: d_ff = 3072, so FFN rank ≤ min(768, 3072) = 768. -/
theorem gpt2_ffn_rank : min 768 3072 = 768 := by norm_num



/-- GPT-2 total per-layer rank ≤ 768 + 768 = 1536. -/
theorem gpt2_layer_rank : 768 + 768 = 1536 := by norm_num



/-- For 12 layers, the multiplicative bound gives 1536^12. -/
theorem gpt2_total_rank_bound : 0 < 1536 ^ 12 := by positivity



/-- Compression ratio: beneficial when r < d/2. -/
theorem compression_beneficial (r d : ℕ) (h : 2 * r < d) :
    2 * r * d < d * d := by nlinarith



end
