import Mathlib

/-! # CatalogBuild.MachineLearning.Neural.TransformerApproximation

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 18
-/


noncomputable section

/-- [Section: ## Section 1: Sub-Quadratic Attention Complexity] -/
theorem block_sparse_subquadratic (N B : ℕ) (hN : 0 < N) (hB : 2 ≤ B)
    (hdiv : B ∣ N) :
    N * (N / B) < N * N := by
  gcongr ; nlinarith [ Nat.div_mul_le_self N B ]


theorem block_sparse_at_most_half (N B : ℕ) (hN : 0 < N) (hB : 2 ≤ B)
    (hdiv : B ∣ N) :
    N * (N / B) ≤ N * N / 2 := by
  exact Nat.le_div_iff_mul_le ( by decide ) |>.2 ( by nlinarith [ Nat.div_mul_le_self N B ] )


theorem linear_attention_cost (N : ℕ) (hN : 0 < N) :
    N * (N / N) = N := by
  rw [ Nat.div_self hN, mul_one ]


/-- [Section: ## Section 2: Quantization Error Bounds] -/
theorem uniform_quantization_elementwise_bound (x Δ : ℝ) (hΔ : 0 < Δ) :
    ∃ q : ℤ, |x - ↑q * Δ| ≤ Δ / 2 := by
  exact ⟨ ⌊x / Δ + 1 / 2⌋, by rw [ abs_le ] ; constructor <;> nlinarith [ Int.floor_le ( x / Δ + 1 / 2 ), Int.lt_floor_add_one ( x / Δ + 1 / 2 ), mul_div_cancel₀ x hΔ.ne.symm ] ⟩


theorem quantization_frobenius_bound (n : ℕ) (δ : ℝ) (hδ : 0 ≤ δ)
    (errors : Fin n → ℝ) (hbound : ∀ i, |errors i| ≤ δ) :
    ∑ i : Fin n, (errors i) ^ 2 ≤ ↑n * δ ^ 2 := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show errors i ^ 2 ≤ δ ^ 2 by nlinarith only [ abs_le.mp ( hbound i ) ] ) ( by norm_num )


theorem kv_cache_quantization_bound (n d : ℕ) (δ : ℝ) (hδ : 0 ≤ δ)
    (errorsK errorsV : Fin n → Fin d → ℝ)
    (hK : ∀ i j, |errorsK i j| ≤ δ)
    (hV : ∀ i j, |errorsV i j| ≤ δ) :
    (∑ i : Fin n, ∑ j : Fin d, (errorsK i j) ^ 2) +
    (∑ i : Fin n, ∑ j : Fin d, (errorsV i j) ^ 2) ≤
    2 * ↑n * ↑d * δ ^ 2 := by
  exact le_trans ( add_le_add ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => show errorsK i j ^ 2 ≤ δ ^ 2 by nlinarith only [ abs_le.mp ( hK i j ) ] ) ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => show errorsV i j ^ 2 ≤ δ ^ 2 by nlinarith only [ abs_le.mp ( hV i j ) ] ) ) ( by norm_num; linarith )


/-- [Section: ## Section 3: Lipschitz Continuity of Composed Layers] -/
theorem lipschitz_comp_real (f g : ℝ → ℝ) (Lf Lg : ℝ) (hLf : 0 ≤ Lf) (hLg : 0 ≤ Lg)
    (hf : ∀ x y, |f x - f y| ≤ Lf * |x - y|)
    (hg : ∀ x y, |g x - g y| ≤ Lg * |x - y|) :
    ∀ x y, |g (f x) - g (f y)| ≤ (Lg * Lf) * |x - y| := by
  exact fun x y => by simpa only [ mul_assoc ] using le_trans ( hg _ _ ) ( mul_le_mul_of_nonneg_left ( hf _ _ ) hLg )


theorem lipschitz_tower_induction (L : ℕ) (K : ℝ) (hK : 0 ≤ K)
    (layers : Fin L → ℝ → ℝ)
    (hlip : ∀ l : Fin L, ∀ x y : ℝ, |layers l x - layers l y| ≤ K * |x - y|) :
    ∀ x y : ℝ,
      |((List.ofFn layers).foldl (fun acc f => f acc) x) -
       ((List.ofFn layers).foldl (fun acc f => f acc) y)| ≤ K ^ L * |x - y| := by
  induction' L with L ih generalizing K;
  · aesop;
  · intro x y;
    rw [ List.ofFn_succ' ];
    simpa [ pow_succ', mul_assoc, mul_left_comm ] using le_trans ( hlip ( Fin.last L ) _ _ ) ( mul_le_mul_of_nonneg_left ( ih K hK _ ( fun i => hlip i.castSucc ) _ _ ) hK )


/-- [Section: ## Section 4: ε-Bounded Output Divergence] -/
theorem layer_perturbation_geom_bound (L : ℕ) (K : ℝ) (hK : 1 ≤ K) :
    (∑ i ∈ Finset.range L, K ^ i) ≤ K ^ L * ↑L := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => pow_le_pow_right₀ hK ( Finset.mem_range_le ‹_› ) ) ( by norm_num; nlinarith )


theorem geometric_perturbation_bound (L : ℕ) (K : ℝ) (hK : 1 < K) :
    (∑ i ∈ Finset.range L, K ^ i) = (K ^ L - 1) / (K - 1) := by
  rw [ geom_sum_eq hK.ne' ]


/-- [Section: ## Section 5: Grouped-Query Attention (GQA) Rank Bounds] -/
theorem gqa_rank_bound (G R d_k : ℕ) (hG : 0 < G) (hR : 1 ≤ R) :
    G * d_k ≤ G * R * d_k := by
  gcongr ; nlinarith


theorem gqa_memory_reduction (n d_k H G : ℕ) (hGH : G ≤ H) :
    G * n * d_k ≤ H * n * d_k := by
  gcongr


/-- [Section: ## Section 6: SwiGLU Activation Properties] -/
theorem sigmoid_bounded (x : ℝ) :
    0 < 1 / (1 + Real.exp (-x)) ∧ 1 / (1 + Real.exp (-x)) ≤ 1 := by
  exact ⟨ by positivity, by rw [ div_le_iff₀ ] <;> linarith [ Real.exp_pos ( -x ) ] ⟩


theorem silu_abs_bound (x : ℝ) :
    |x * (1 / (1 + Real.exp (-x)))| ≤ |x| := by
  exact abs_mul x _ ▸ mul_le_of_le_one_right ( abs_nonneg _ ) ( abs_le.mpr ⟨ by rw [ le_div_iff₀ ( by positivity ) ] ; nlinarith [ Real.exp_pos ( -x ) ], by rw [ div_le_one₀ ( by positivity ) ] ; nlinarith [ Real.exp_pos ( -x ) ] ⟩ )


theorem swiglu_growth_bound (x : ℝ) :
    |x / (1 + Real.exp (-x))| ≤ |x| := by
  rw [ abs_div ];
  exact div_le_self ( abs_nonneg _ ) ( by rw [ abs_of_nonneg ] <;> linarith [ Real.exp_pos ( -x ) ] )


/-- [Section: ## Section 7: RoPE Frequency Scaling] -/
theorem rope_norm_preservation (θ : ℝ) (v₁ v₂ : ℝ) :
    (v₁ * Real.cos θ - v₂ * Real.sin θ) ^ 2 +
    (v₁ * Real.sin θ + v₂ * Real.cos θ) ^ 2 = v₁ ^ 2 + v₂ ^ 2 := by
  nlinarith [ Real.sin_sq_add_cos_sq θ ]


theorem scaled_rope_norm_preservation (θ s : ℝ) (hs : s ≠ 0) (v₁ v₂ : ℝ) :
    (v₁ * Real.cos (θ / s) - v₂ * Real.sin (θ / s)) ^ 2 +
    (v₁ * Real.sin (θ / s) + v₂ * Real.cos (θ / s)) ^ 2 = v₁ ^ 2 + v₂ ^ 2 := by
  ring_nf; rw [ Real.sin_sq, Real.cos_sq ] ; ring;


/-- [Section: ## Section 8: All-Reduce Commutativity for Distributed Training] -/
theorem allreduce_sum_comm (n : ℕ) (f : Fin n → ℝ) (σ : Equiv.Perm (Fin n)) :
    ∑ i, f (σ i) = ∑ i, f i := by
  exact Equiv.sum_comp σ f


end
