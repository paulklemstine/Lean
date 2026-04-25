/-! # CatalogBuild.Tropical.Core.TropicalAgentBeta

Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Tropical.Core.TropicalAgentBeta
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16] -/
noncomputable def softAttention {n d : ℕ} (β : ℝ) (scores : Fin (n+1) → ℝ)
    (V : Fin (n+1) → Fin d → ℝ) : Fin d → ℝ :=
  fun k => (∑ i, exp (β * scores i) * V i k) / (∑ i, exp (β * scores i))


/-- [Section: # CatalogBuild.Tropical.Core.TropicalAgentBeta
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16] -/
theorem softAttention_zero {n d : ℕ} (scores : Fin (n+1) → ℝ)
    (V : Fin (n+1) → Fin d → ℝ) (k : Fin d) :
    softAttention 0 scores V k = (∑ i, V i k) / (↑(n + 1) : ℝ) := by
      unfold softAttention; aesop;


/-- [Section: # CatalogBuild.Tropical.Core.TropicalAgentBeta
Auto-generated from theorem catalog database.
Domain: Tropical/Core
Declarations: 16] -/
noncomputable def layerMean {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  (∑ i, x i) / n


theorem centered_mean_zero {n : ℕ} [NeZero n] (x : Fin n → ℝ) :
    layerMean (fun i => x i - layerMean x) = 0 := by
      unfold layerMean; ring;
      norm_num [ mul_comm, ← Finset.sum_mul _ _ _, NeZero.ne ]


noncomputable def layerVar {n : ℕ} [NeZero n] (x : Fin n → ℝ) : ℝ :=
  (∑ i, (x i - layerMean x) ^ 2) / n


theorem layerVar_nonneg {n : ℕ} [NeZero n] (x : Fin n → ℝ) : 0 ≤ layerVar x := by
  apply div_nonneg (Finset.sum_nonneg (fun _ _ => sq_nonneg _))
  exact Nat.cast_nonneg (α := ℝ) n


theorem residual_recovers {n : ℕ} (x fx : Fin n → ℝ) (i : Fin n) :
    (x i + fx i) - x i = fx i := by ring


theorem multihead_split (d_model n_heads : ℕ) (h : n_heads ∣ d_model) :
    n_heads * (d_model / n_heads) = d_model :=
  Nat.mul_div_cancel' h


theorem trop_dominant_term {n : ℕ} (v : Fin (n+1) → ℝ) (k : Fin (n+1))
    (hk : ∀ j, v j ≤ v k) :
    Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ v = v k :=
  le_antisymm (Finset.sup'_le _ _ (fun j _ => hk j)) (Finset.le_sup' _ (Finset.mem_univ k))


noncomputable def perplexity {n : ℕ} (logprobs : Fin (n+1) → ℝ) : ℝ :=
  exp (-(∑ i, logprobs i) / (n + 1))


theorem perplexity_mono {n : ℕ} (p q : Fin (n+1) → ℝ)
    (h : (∑ i, p i) ≤ (∑ i, q i)) :
    perplexity q ≤ perplexity p := by
      exact Real.exp_le_exp.mpr ( by rw [ div_le_div_iff_of_pos_right ( by positivity ) ] ; linarith )


theorem relu_subgrad_pos (x : ℝ) (hx : 0 < x) :
    max x 0 = 1 * x + 0 := by rw [max_eq_left (le_of_lt hx)]; ring


theorem relu_subgrad_neg (x : ℝ) (hx : x < 0) :
    max x 0 = 0 * x + 0 := by rw [max_eq_right (le_of_lt hx)]; ring


noncomputable def gradStep (θ grad η : ℝ) : ℝ := θ - η * grad


theorem grad_descent_reduces (θ grad η : ℝ) (hη : 0 < η) (hg : 0 < grad) :
    gradStep θ grad η < θ := by unfold gradStep; linarith [mul_pos hη hg]


theorem grad_fixed_point (θ η : ℝ) : gradStep θ 0 η = θ := by
  unfold gradStep; ring


end
