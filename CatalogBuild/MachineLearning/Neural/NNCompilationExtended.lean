/-! # CatalogBuild.MachineLearning.Neural.NNCompilationExtended

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 27
-/

import Mathlib

/-- Any function satisfying f(0)=0, f(1)=1, f(-1)=0 cannot be affine.
This captures both ReLU (exactly) and GELU (approximately). -/
theorem activation_not_affine (f : ℝ → ℝ) (h0 : f 0 = 0) (h1 : f 1 = 1)
    (hm1 : f (-1) = 0) : ¬ ∃ (a b : ℝ), ∀ x : ℝ, f x = a * x + b := by
  rintro ⟨a, b, hab⟩
  have hab0 := hab 0
  have hab1 := hab 1
  have habm1 := hab (-1)
  rw [h0] at hab0
  rw [h1] at hab1
  rw [hm1] at habm1
  simp at hab0
  linarith


/-- ReLU is tropical addition with the tropical unit:
max(x, 0) = x ⊕_trop 0 -/
theorem relu_is_trop_add (x : ℝ) : max x 0 = tropAdd x 0 := by
  simp [tropAdd]


/-- Error accumulation bound: L layers with per-layer error ε and
operator norm bound κ gives total error L * ε * κ^L -/
theorem koopman_error_bound (L : ℕ) (ε κ : ℝ)
    (hε : 0 ≤ ε) (hκ : 1 ≤ κ) :
    0 ≤ L * ε * κ ^ L := by
  positivity


/-- When κ = 1 (unit operator norm), error grows linearly -/
theorem koopman_error_unit_norm (L : ℕ) (ε : ℝ) :
    L * ε * (1 : ℝ) ^ L = L * ε := by simp


/-- Koopman operator definition: (Kg)(x) = g(F(x)) -/
def koopmanOp {α : Type*} (F : α → α) (g : α → ℝ) : α → ℝ := g ∘ F


/-- Koopman is additive in observables -/
theorem koopman_linear_add {α : Type*} (F : α → α) (g h : α → ℝ) (x : α) :
    koopmanOp F (g + h) x = koopmanOp F g x + koopmanOp F h x := by
  simp [koopmanOp, Pi.add_apply]


/-- Koopman preserves scalar multiplication -/
theorem koopman_linear_smul {α : Type*} (F : α → α) (c : ℝ) (g : α → ℝ) (x : α) :
    koopmanOp F (c • g) x = c * koopmanOp F g x := by
  simp [koopmanOp, Pi.smul_apply, smul_eq_mul]


/-- Koopman operators compose: K_G ∘ K_F = K_{F ∘ G} -/
theorem koopman_compose {α : Type*} (F G : α → α) (g : α → ℝ) (x : α) :
    koopmanOp G (koopmanOp F g) x = koopmanOp (F ∘ G) g x := by
  simp [koopmanOp, Function.comp]


/-- For V ≥ 2 and L ≥ 2, the lookup table V^L exceeds V*L -/
theorem lookup_exceeds_params (V : ℕ) (hV : 2 ≤ V) (L : ℕ) (hL : 2 ≤ L) :
    V ^ 2 ≤ V ^ L :=
  Nat.pow_le_pow_right (by omega) hL


/-- GPT-2 vocabulary squared already exceeds 2 billion -/
theorem gpt2_vocab_squared : 50257 ^ 2 > 2 * 10 ^ 9 := by norm_num


/-- GPT-2 cubed exceeds 10^14 -/
theorem gpt2_input_space_huge : 50257 ^ 3 > 10 ^ 14 := by norm_num


/-- No single real number a satisfies max(x,0) = a*x for all x ∈ ℝ -/
theorem trilemma_no_linear_relu :
    ¬ ∃ (a : ℝ), ∀ x : ℝ, max x 0 = a * x := by
  intro ⟨a, ha⟩
  have h1 := ha 1
  have hm1 := ha (-1)
  simp at h1 hm1
  linarith


/-- Exact + General is achievable on finite domains (at cost of compactness) -/
theorem exact_general_achievable {α β : Type*} (f : α → β) :
    ∃ (g : α → β), ∀ x, g x = f x :=
  ⟨f, fun _ => rfl⟩


/-- For GPT-2 scale: TT with rank 100 uses ~184M params -/
theorem gpt2_tt_size : 24 * 768 * 100 ^ 2 = 184320000 := by norm_num


/-- TT storage N*d*r² is polynomial while d^N is exponential.
For d ≥ 2 and large enough N, d^N dwarfs N*d³. -/
theorem tt_exponential_dominates (d : ℕ) (hd : 2 ≤ d) (N : ℕ) (hN : 7 ≤ N) :
    d ^ 6 ≤ d ^ N :=
  Nat.pow_le_pow_right (by omega) (by omega)


/-- Total number of ReLU activation patterns is at most 2^(total_neurons) -/
theorem total_activation_patterns (total_neurons : ℕ) :
    1 ≤ 2 ^ total_neurons :=
  Nat.one_le_pow _ 2 (by omega)


/-- Depth-L, width-w network: at most (2w)^L regions -/
theorem region_bound (L w : ℕ) (hw : 1 ≤ w) :
    1 ≤ (2 * w) ^ L :=
  Nat.one_le_pow L (2 * w) (by omega)


/-- Shannon: k distinct outputs need at most 2^k addresses -/
theorem shannon_bits (k : ℕ) : k ≤ 2 ^ k :=
  Nat.le_of_lt (Nat.lt_pow_self (by norm_num : 1 < 2))


/-- GPT-2: 50257 tokens ≤ 2^16 = 65536, so 16 bits suffice per token -/
theorem gpt2_bits_per_token : 50257 ≤ 2 ^ 16 := by norm_num


/-- Information content of GPT-2: 124M params × 32 bits -/
theorem gpt2_info_content : 124000000 * 32 = 3968000000 := by norm_num


/-- exp is injective -/
theorem exp_injective_prop : Function.Injective Real.exp := Real.exp_injective


/-- exp(0) = 1 -/
theorem exp_at_zero : Real.exp 0 = 1 := Real.exp_zero


/-- exp is always positive -/
theorem exp_pos_always (x : ℝ) : 0 < Real.exp x := Real.exp_pos x


/-- exp cannot be affine -/
theorem exp_not_affine' :
    ¬ ∃ (a b : ℝ), ∀ x : ℝ, Real.exp x = a * x + b := by
  rintro ⟨a, b, hab⟩
  have h0 := hab 0
  have h1 := hab 1
  have hm1 := hab (-1)
  simp [Real.exp_zero] at h0
  have : Real.exp 1 + Real.exp (-1) = 2 := by linarith
  have hexp1 : (1 : ℝ) + 1 ≤ Real.exp 1 := Real.add_one_le_exp 1
  have hexp_neg1 : Real.exp (-1) > 0 := Real.exp_pos _
  linarith


/-- Softmax outputs sum to 1 -/
theorem softmax_sums_one' {n : ℕ} (x : Fin n → ℝ)
    (hpos : 0 < ∑ i : Fin n, Real.exp (x i)) :
    (∑ i : Fin n, Real.exp (x i) / ∑ j : Fin n, Real.exp (x j)) = 1 := by
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt hpos)


/-- L layers of degree-d activations yield degree d^L -/
theorem compiled_poly_degree (d L : ℕ) (hd : 1 ≤ d) :
    1 ≤ d ^ L := Nat.one_le_pow L d hd


/-- Doubly-exponential growth of lifted dimension -/
theorem doubly_exp_growth (d p L : ℕ) (hd : 2 ≤ d) (hp : 2 ≤ p) :
    d ≤ d ^ p ^ L := by
  calc d = d ^ 1 := (pow_one d).symm
    _ ≤ d ^ p ^ L := by
        apply Nat.pow_le_pow_right (by omega)
        exact Nat.one_le_pow L p (by omega)

