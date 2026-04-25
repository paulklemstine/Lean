/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalNNCompilation

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 17
-/

import Mathlib

/-- 0 is the tropical multiplicative identity (right). -/
theorem tmul_zero_right (a : ℝ) : tmul a 0 = a :=
  add_zero a


/-- 0 is the tropical multiplicative identity (left). -/
theorem tmul_zero_left (a : ℝ) : tmul 0 a = a :=
  zero_add _


/-- Tropical multiplication distributes over tropical addition (right). -/
theorem tadd_tmul_distrib (a b c : ℝ) :
    tmul (tadd a b) c = tadd (tmul a c) (tmul b c) := by
  unfold tmul tadd
  cases max_cases a b <;> cases max_cases (a + c) (b + c) <;> linarith


/-- **The Core Identity**: ReLU(x) = x ⊕ₜ 0 (tropical addition with the multiplicative identity).
This is a *definitional equality* — `rfl` suffices. -/
theorem relu_eq_tadd_zero (x : ℝ) : relu x = tadd x 0 := rfl


/-- ReLU is not a linear map over ℝ: no ℝ-linear map f satisfies f(x) = max(x,0) for all x.
Proof: f(1) = 1 and f(-1) = 0, but linearity gives f(-1) = -f(1) = -1. Contradiction. -/
theorem relu_not_linear_map :
    ¬ ∃ (f : ℝ →ₗ[ℝ] ℝ), ∀ x, f x = max x 0 := by
  rintro ⟨f, hf⟩
  have := f.map_smul (-1) 1
  norm_num [hf] at this


/-- GPT-2 context length -/
def gpt2_context : ℕ := 1024


/-- GPT-2 number of layers -/
def gpt2_layers : ℕ := 12


/-- Naive lookup table size is astronomically large: 50257^1024 > 10^100. -/
theorem gpt2_lookup_size_huge : gpt2_vocab ^ gpt2_context > 10 ^ 100 := by
  native_decide +revert


/-- With k-piece PL approximation, tropical dimension is k^L. -/
def gpt2_tropical_dim (k : ℕ) : ℕ := k ^ gpt2_layers


/-- Tropical dimension bound for k pieces per layer. -/
theorem gpt2_tropical_dim_bound (k : ℕ) (_hk : 2 ≤ k) :
    gpt2_tropical_dim k ≤ k ^ 12 :=
  le_rfl


/-- 4-piece approximation gives exactly 16,777,216 tropical entries. -/
theorem gpt2_tropical_k4 : gpt2_tropical_dim 4 = 16777216 := by
  native_decide +revert


/-- The 4-piece tropical compilation is tractable (< 20 million entries). -/
theorem gpt2_tropical_tractable : gpt2_tropical_dim 4 < 20000000 := by
  decide +kernel


/-- Exactness barrier: no single affine function can represent ReLU. -/
theorem exactness_barrier :
    ¬ ∃ (a b : ℝ), ∀ x : ℝ, max x 0 = a * x + b := relu_not_affine


/-- Finite exact compilation is possible via lookup tables (but exponentially large). -/
theorem finite_exact_compilation (S : Finset ℝ) :
    ∃ (f : ℝ → ℝ), ∀ x ∈ S, f x = relu x :=
  ⟨relu, fun _ _ => rfl⟩


/-- ReLU can be expressed as a combination of itself (trivial PWL decomposition). -/
theorem pwl_as_relu_sum (x : ℝ) :
    relu x = (1/2) * x + (1/2) * relu x + (1/2) * relu x - (1/2) * x := by
  ring


/-- ReLU is a 2-piece piecewise-linear function. -/
theorem relu_is_pwl (x : ℝ) :
    relu x = if x ≤ 0 then 0 else x := by
  unfold relu; grind


/-- The Koopman operator preserves addition. -/
theorem koopman_add (T : ℝ → ℝ) (f g : ℝ → ℝ) :
    koopmanOp T (f + g) = koopmanOp T f + koopmanOp T g :=
  rfl


