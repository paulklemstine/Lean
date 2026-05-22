import Mathlib

/-! # CatalogBuild.Tropical.NeuralNetworks.TropicalLLMConversion

Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 54
-/

noncomputable section

/-- [Section: # CatalogBuild.Tropical.NeuralNetworks.TropicalLLMConversion
Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 54] -/
theorem tAdd_comm (a b : ℝ) : tAdd a b = tAdd b a := max_comm a b

/-- [Section: # CatalogBuild.Tropical.NeuralNetworks.TropicalLLMConversion
Auto-generated from theorem catalog database.
Domain: Tropical/NeuralNetworks
Declarations: 54] -/
theorem tAdd_assoc (a b c : ℝ) : tAdd (tAdd a b) c = tAdd a (tAdd b c) := max_assoc _ _ _

theorem tAdd_idem (a : ℝ) : tAdd a a = a := max_self a

theorem tMul_comm (a b : ℝ) : tMul a b = tMul b a := add_comm a b

theorem tMul_assoc (a b c : ℝ) : tMul (tMul a b) c = tMul a (tMul b c) := by
  unfold tMul; ring

theorem tMul_zero_right (a : ℝ) : tMul a 0 = a := add_zero a

theorem tMul_zero_left (a : ℝ) : tMul 0 a = a := zero_add a

/-- Left distributivity of tropical multiplication over tropical addition -/
theorem tMul_tAdd_left (a b c : ℝ) :
    tMul a (tAdd b c) = tAdd (tMul a b) (tMul a c) := by
  simp only [tMul, tAdd]; exact (max_add_add_left a b c).symm

/-- Right distributivity -/
theorem tMul_tAdd_right (a b c : ℝ) :
    tMul (tAdd a b) c = tAdd (tMul a c) (tMul b c) := by
  simp only [tMul, tAdd]; exact max_add a b c

/-- ReLU is a piecewise linear function -/
theorem relu_piecewise (x : ℝ) : relu x = if x ≤ 0 then 0 else x := by
  unfold relu; split_ifs with h
  · exact max_eq_right h
  · exact max_eq_left (le_of_lt (not_le.mp h))

/-- exp preserves tropical multiplication (becomes ordinary multiplication) -/
theorem exp_tMul (a b : ℝ) : exp (tMul a b) = exp a * exp b :=
  exp_add a b

/-- exp maps tropical multiplicative identity to 1 -/
theorem exp_tropical_one : exp (0 : ℝ) = 1 := exp_zero

/-- exp is order-preserving (connects tropical ordering to standard ordering) -/
theorem exp_mono_iff (a b : ℝ) : a ≤ b ↔ exp a ≤ exp b := exp_le_exp.symm

/-- exp is strictly order-preserving -/
theorem exp_strict_mono_iff' (a b : ℝ) : a < b ↔ exp a < exp b := Real.exp_lt_exp.symm

/-- Log recovers tropical multiplication from classical multiplication -/
theorem log_recovers_tMul (a b : ℝ) (ha : 0 < a) (hb : 0 < b) :
    Real.log (a * b) = tMul (Real.log a) (Real.log b) :=
  Real.log_mul (ne_of_gt ha) (ne_of_gt hb)

/-- Sum of exp is positive for nonempty types -/
theorem sum_exp_pos' {n : ℕ} [NeZero n] (v : Fin n → ℝ) :
    0 < ∑ j, exp (v j) :=
  Finset.sum_pos (fun _ _ => exp_pos _) Finset.univ_nonempty

/-- Softmax is invariant under constant shifts -/
theorem softmax_shift {n : ℕ} (v : Fin n → ℝ) (c : ℝ) (i : Fin n) :
    softmax (fun j => v j + c) i = softmax v i := by
  simp only [softmax, exp_add]
  rw [← Finset.sum_mul]
  exact mul_div_mul_right _ _ (ne_of_gt (exp_pos c))

/-- Softmax is bounded above by 1 -/
theorem softmax_le_one {n : ℕ} [NeZero n] (v : Fin n → ℝ) (i : Fin n) :
    softmax v i ≤ 1 :=
  (div_le_one₀ (sum_exp_pos' v)).mpr
    (Finset.single_le_sum (fun _ _ => exp_nonneg _) (Finset.mem_univ i))

/-- At β = 1, scaled softmax equals standard softmax -/
theorem scaledSoftmax_one {n : ℕ} (v : Fin n → ℝ) (i : Fin n) :
    scaledSoftmax 1 v i = softmax v i := by simp [scaledSoftmax, softmax]

/-- Sum of exp is positive -/
theorem sum_exp_pos {n : ℕ} (v : Fin (n + 1) → ℝ) :
    0 < ∑ i, exp (v i) :=
  Finset.sum_pos (fun _ _ => exp_pos _) Finset.univ_nonempty

theorem logSumExp_le {n : ℕ} (v : Fin (n + 1) → ℝ) :
    logSumExp v ≤
    Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ v + Real.log (↑(n + 1)) := by
  -- Use exp monotonicity: each exp(v i) ≤ exp(max v), so the sum ≤ (n+1) * exp(max v).
  have h_exp_monotone : ∑ i : Fin (n + 1), Real.exp (v i) ≤ (n + 1) * Real.exp (Finset.sup' Finset.univ Finset.univ_nonempty v) := by
    have h_exp_monotone : ∀ i, Real.exp (v i) ≤ Real.exp (Finset.sup' Finset.univ Finset.univ_nonempty v) := by
      exact fun i => Real.exp_le_exp.mpr ( Finset.le_sup' v ( Finset.mem_univ i ) );
    exact le_trans ( Finset.sum_le_sum fun _ _ => h_exp_monotone _ ) ( by norm_num );
  rw [ add_comm, logSumExp ];
  simpa [ Real.log_mul, show ( n :ℝ ) + 1 ≠ 0 by positivity ] using Real.log_le_log ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ( Finset.univ_nonempty ) ) h_exp_monotone

/-- Attention score scales linearly in q -/
theorem attentionScore_scale {d : ℕ} (c : ℝ) (q k : Fin d → ℝ) :
    attentionScore (fun i => c * q i) k = c * attentionScore q k := by
  simp only [attentionScore]; simp_rw [mul_assoc]; rw [← Finset.mul_sum]; ring

/-- Transplantation preserves the linear map exactly -/
theorem transplant_exact {m n : ℕ} (W : Fin m → Fin n → ℝ) (b : Fin m → ℝ)
    (x : Fin n → ℝ) :
    linearLayer W b x = fun i => (∑ j, W i j * x j) + b i := rfl

/-- Composition of linear layers -/
theorem compose_linear {l m n : ℕ}
    (W₁ : Fin m → Fin n → ℝ) (b₁ : Fin m → ℝ)
    (W₂ : Fin l → Fin m → ℝ) (b₂ : Fin l → ℝ) (x : Fin n → ℝ) :
    linearLayer W₂ b₂ (linearLayer W₁ b₁ x) =
    fun i => (∑ j, W₂ i j * ((∑ k, W₁ j k * x k) + b₁ j)) + b₂ i := rfl

/-- Residual connection: out = x + f(x) -/
def residualConn {n : ℕ} (x fx : Fin n → ℝ) : Fin n → ℝ := fun i => x i + fx i

/-- Residual connection recovers the layer output -/
theorem residual_sub {n : ℕ} (x fx : Fin n → ℝ) (i : Fin n) :
    residualConn x fx i - x i = fx i := by simp [residualConn]

/-- Layer norm mean -/
noncomputable def layerNormMean {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  (∑ i, x i) / n

theorem layerNormMean_const {n : ℕ} [NeZero n] (c : ℝ) :
    layerNormMean (fun _ : Fin n => c) = c := by
  simp [layerNormMean, Finset.sum_const]
  exact mul_div_cancel_left₀ c (Nat.cast_ne_zero.mpr (NeZero.ne n))

/-- Causal mask: position i can attend to position j iff j ≤ i -/
def causalMask (i j : ℕ) : Prop := j ≤ i

theorem causalMask_refl (i : ℕ) : causalMask i i := le_refl i

theorem causalMask_trans {i j k : ℕ} (hkj : causalMask k j) (hji : causalMask j i) :
    causalMask k i := by unfold causalMask at *; omega

/-- Number of valid positions for causal attention at position i -/
theorem causal_attention_count (i : ℕ) :
    (Finset.filter (fun j => j ≤ i) (Finset.range (i + 1))).card = i + 1 := by
  simp [Finset.filter_true_of_mem]

def gpt2_n_layer : ℕ := 12

def gpt2_n_head : ℕ := 12

def gpt2_n_embd : ℕ := 768

def gpt2_head_dim : ℕ := gpt2_n_embd / gpt2_n_head

theorem gpt2_head_dim_val : gpt2_head_dim = 64 := by native_decide

theorem gpt2_heads_divide : gpt2_n_head ∣ gpt2_n_embd := by native_decide

theorem gpt2_each_head : gpt2_n_embd / gpt2_n_head = 64 := by native_decide

theorem gpt2_attn_params :
    3 * gpt2_n_embd ^ 2 + gpt2_n_embd ^ 2 = 4 * gpt2_n_embd ^ 2 := by ring

theorem gpt2_mlp_params :
    4 * gpt2_n_embd ^ 2 + 4 * gpt2_n_embd ^ 2 = 8 * gpt2_n_embd ^ 2 := by ring

theorem gpt2_layer_params :
    4 * gpt2_n_embd ^ 2 + 8 * gpt2_n_embd ^ 2 = 12 * gpt2_n_embd ^ 2 := by ring

/-- Multi-head splits preserve dimension -/
theorem multihead_dim_split (n_embd n_head : ℕ) (h : n_head ∣ n_embd) :
    n_head * (n_embd / n_head) = n_embd :=
  Nat.mul_div_cancel' h

/-- GELU approximation via sigmoid: x · σ(1.702x) -/
noncomputable def geluApprox (x : ℝ) : ℝ :=
  x * (1 / (1 + exp (-(1.702 * x))))

theorem geluApprox_zero : geluApprox 0 = 0 := by simp [geluApprox]

theorem sigmoid_pos (x : ℝ) : 0 < 1 / (1 + exp (-x)) := by
  apply div_pos one_pos; linarith [exp_pos (-x)]

theorem geluApprox_pos {x : ℝ} (hx : 0 < x) : 0 < geluApprox x :=
  mul_pos hx (sigmoid_pos (1.702 * x))

/-- One-hot distribution has zero entropy -/
theorem one_hot_zero_entropy {n : ℕ} [NeZero n] (k : Fin n) :
    shannonEntropy (fun i : Fin n => if i = k then (1 : ℝ) else 0) = 0 := by
  simp [shannonEntropy, Finset.sum_ite_eq', Finset.mem_univ, Real.log_one]

/-- Addition distributes over max (tropical perspective) -/
theorem add_max_distrib (a b c : ℝ) : a + max b c = max (a + b) (a + c) :=
  (max_add_add_left a b c).symm

/-- Max distributes over multiplication by nonneg scalars -/
theorem max_mul_nonneg (a b c : ℝ) (hc : 0 ≤ c) :
    max a b * c = max (a * c) (b * c) := by
  rcases le_total a b with h | h
  · rw [max_eq_right h, max_eq_right (mul_le_mul_of_nonneg_right h hc)]
  · rw [max_eq_left h, max_eq_left (mul_le_mul_of_nonneg_right h hc)]

/-- GPT-2 vocabulary size -/
def gpt2_vocab : ℕ := 50257

/-- Naive lookup table is astronomically large -/
theorem gpt2_lookup_huge : gpt2_vocab ^ 1024 > 10 ^ 100 := by native_decide

/-- ReLU can be decomposed as max of two linear pieces -/
theorem relu_two_pieces (x : ℝ) : relu x = max (1 * x + 0) (0 * x + 0) := by
  simp [relu]

/-- Composition of ReLU layers creates more linear regions -/
theorem relu_compose_pieces (x : ℝ) :
    relu (relu x - 1) = max (max x 0 - 1) 0 := by
  simp [relu]

end