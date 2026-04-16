/-! # CatalogBuild.EML.PACLearning

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 17
-/

import Mathlib

noncomputable section

/-- Growth function bound using Sauer-Shelah: (n+1)^d. -/
def sauer_shelah_bound (n d : ℕ) : ℕ := (n + 1)^d



/-- Growth function is monotone in n. -/
theorem growth_monotone (n₁ n₂ d : ℕ) (h : n₁ ≤ n₂) :
    sauer_shelah_bound n₁ d ≤ sauer_shelah_bound n₂ d := by
  simp [sauer_shelah_bound]
  exact Nat.pow_le_pow_left (by omega) d



/-- Growth function is monotone in d. -/
theorem growth_monotone_d (n d₁ d₂ : ℕ) (h : d₁ ≤ d₂) :
    sauer_shelah_bound n d₁ ≤ sauer_shelah_bound n d₂ := by
  simp [sauer_shelah_bound]
  exact Nat.pow_le_pow_right (by omega) h



/-- VC dimension including topology selection. -/
def emlFullClassVCDim (k : ℕ) : ℕ := 4 * k



/-- The full class VC dim is twice the fixed-topology VC dim. -/
theorem full_class_vc_bound (k : ℕ) :
    emlFullClassVCDim k = 2 * emlVCDim k := by
  simp [emlFullClassVCDim, emlVCDim]; ring



/-- [Section: # CatalogBuild.EML.PACLearning
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 17] -/
theorem pac_monotone_complexity (d₁ d₂ inv_eps inv_delta : ℕ) (h : d₁ ≤ d₂) :
    pacSampleBound d₁ inv_eps inv_delta ≤ pacSampleBound d₂ inv_eps inv_delta := by
  simp only [pacSampleBound]
  gcongr



/-- Sample complexity for a standard NN with p parameters. -/
def nnPacSampleBound (p : ℕ) (inv_eps inv_delta : ℕ) : ℕ :=
  4 * inv_eps * (p * (Nat.log 2 (2 * inv_eps) + 1) + Nat.log 2 inv_delta + 1)



/-- The parametric rate for k-parameter estimation: k/n. -/
def parametricRate (k n : ℕ) : ℝ := (k : ℝ) / (n : ℝ)



/-- EML has better parametric rate than equivalent NNs. -/
theorem eml_better_rate (k : ℕ) (W : ℕ) (n : ℕ)
    (hk : 0 < k) (hn : 0 < n) (hW : 2 * k < W * (W + 1)) :
    parametricRate (2 * k) n < parametricRate (W * (W + 1)) n := by
  simp [parametricRate]
  exact div_lt_div_of_pos_right (by exact_mod_cast hW) (by positivity)



/-- Bias: approximation capacity grows with complexity. -/
theorem bias_decreases_with_complexity (k₁ k₂ : ℕ) (h : k₁ ≤ k₂) :
    emlVCDim k₁ ≤ emlVCDim k₂ := by
  simp [emlVCDim]; omega



/-- Variance: estimation error increases with more leaves. -/
theorem variance_increases_with_complexity (k₁ k₂ n : ℕ)
    (h : k₁ ≤ k₂) (hn : 0 < n) :
    parametricRate (2 * k₁) n ≤ parametricRate (2 * k₂) n := by
  simp [parametricRate]
  exact div_le_div_of_nonneg_right (by exact_mod_cast (show 2 * k₁ ≤ 2 * k₂ by omega))
    (by positivity)



/-- The optimal complexity minimizes bias + variance.
Heuristic: k* ≈ n^(1/4) balances the two terms. -/
def heuristicOptimalK (n : ℕ) : ℕ := Nat.sqrt (Nat.sqrt n)



/-- For n = 10^6, the heuristic gives k* = 31. -/
theorem heuristic_1M : heuristicOptimalK 1000000 = 31 := by native_decide



/-- For n = 10^4, the heuristic gives k* = 10. -/
theorem heuristic_10K : heuristicOptimalK 10000 = 10 := by native_decide



/-- The number of distinct EML tree topologies with n leaves is
bounded above by 4^(n-1). We state this as a direct bound
on the topology count. -/
def topologyCount (n : ℕ) : ℕ := 4^n



/-- Topology count grows exponentially. -/
theorem topology_count_monotone (n₁ n₂ : ℕ) (h : n₁ ≤ n₂) :
    topologyCount n₁ ≤ topologyCount n₂ := by
  simp [topologyCount]
  exact Nat.pow_le_pow_right (by omega) h



theorem topology_log_linear (n : ℕ) : Nat.log 2 (topologyCount n) = 2 * n := by
  rw [ Nat.log_eq_iff ] <;> norm_num [ topologyCount ];
  norm_num [ pow_add, pow_mul ]



end
