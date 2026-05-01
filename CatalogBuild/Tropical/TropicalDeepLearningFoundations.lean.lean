/-! # CatalogBuild.Tropical.TropicalDeepLearningFoundations.lean

Auto-generated from theorem catalog database.
Domain: Tropical
Declarations: 26
-/

import Mathlib

noncomputable section

/-- ReLU function: max(x, 0) -/
def relu₀ (x : ℝ) : ℝ := max x 0





/-- Left distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c) -/
theorem tropMul_tropAdd_distrib (a b c : ℝ) :
    tropMul a (tropAdd b c) = tropAdd (tropMul a b) (tropMul a c) := by
  simp [tropMul, tropAdd, max_add_add_left]





/-- [Section: # CatalogBuild.MachineLearning.Neural.TropicalDeepLearningFoundations
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 26] -/
theorem tropAdd_tropMul_distrib (a b c : ℝ) :
    tropMul (tropAdd a b) c = tropAdd (tropMul a c) (tropMul b c) := by
  unfold tropMul tropAdd;
  rw [ max_add_add_right ]





/-- ReLU is tropical addition with the multiplicative identity -/
theorem relu_eq_tropAdd_zero (x : ℝ) : relu₀ x = tropAdd x 0 := by
  rfl





/-- ReLU is non-negative -/
theorem relu_nonneg' (x : ℝ) : 0 ≤ relu₀ x := le_max_right x 0





/-- [Section: # CatalogBuild.MachineLearning.Neural.TropicalDeepLearningFoundations
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 26] -/
theorem relu_not_affine' :
    ¬ ∃ (a b : ℝ), ∀ x : ℝ, relu₀ x = a * x + b := by
  exact fun ⟨ a, b, h ⟩ ↦ by have h₀ := h ( -1 ) ; have h₁ := h 0 ; have h₂ := h 1; norm_num [ relu₀ ] at h₀ h₁ h₂; linarith;





/-- The composition of two ReLU applications preserves tropical structure -/
theorem relu_composition_tropical (x y : ℝ) :
    relu₀ (tropMul x (relu₀ y)) = relu₀ (tropMul x (tropAdd y 0)) := by
  simp [relu₀, tropMul, tropAdd]





/-- For a single layer with n neurons in 1D, Zaslavsky's theorem gives
at most n + 1 regions. -/
def zaslavsky_1d (n : ℕ) : ℕ := n + 1





/-- Depth L with width w in 1D gives at most (w+1)^L regions -/
def max_regions_1d (width depth : ℕ) : ℕ := (width + 1) ^ depth





/-- Width w in a single layer gives at most w+1 regions (linear in w) -/
theorem width_linear (w : ℕ) : max_regions_1d w 1 = w + 1 := by
  simp [max_regions_1d]





/-- Depth L with constant width gives (w+1)^L regions (exponential in L) -/
theorem depth_exponential (w L : ℕ) : max_regions_1d w L = (w + 1) ^ L := by
  simp [max_regions_1d]





/-- Doubling depth squares the region count -/
theorem depth_double_squares (w L : ℕ) :
    max_regions_1d w (2 * L) = (max_regions_1d w L) ^ 2 := by
  simp [max_regions_1d]
  ring





/-- The lookup table size for exact single-operation inference -/
def lookup_table_size (n_regions dim : ℕ) : ℕ := n_regions * (dim + 1)





/-- A ReLU network with depth L and width w can have up to (w+1)^L regions -/
def network_max_regions (width depth : ℕ) : ℕ := (width + 1) ^ depth





/-- The lookup table for exact single-operation inference is exponential -/
theorem lookup_exponential (w L d : ℕ) :
    lookup_table_size (network_max_regions w L) d = (w + 1) ^ L * (d + 1) := by
  simp [lookup_table_size, network_max_regions]





/-- The original network has polynomial size -/
def network_param_count (width depth input_dim : ℕ) : ℕ :=
  depth * width * (width + input_dim + 1)





/-- The exponential function is strictly positive -/
theorem exp_pos' (x : ℝ) : 0 < Real.exp x := Real.exp_pos x





/-- Tropical multiplication (standard +) is the logarithm of standard multiplication:
a + b = log(exp(a) · exp(b))
This is the "Maslov dequantization" homomorphism. -/
theorem maslov_homomorphism (a b : ℝ) :
    a + b = Real.log (Real.exp a * Real.exp b) := by
  rw [← Real.exp_add]
  exact (Real.log_exp (a + b)).symm





/-- [Section: # CatalogBuild.MachineLearning.Neural.TropicalDeepLearningFoundations
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 26] -/
theorem max_le_logsumexp (a b : ℝ) :
    max a b ≤ Real.log (Real.exp a + Real.exp b) := by
  rw [ le_log_iff_exp_le ];
  · cases max_cases a b <;> simp +decide [ * ] <;> linarith [ Real.exp_pos a, Real.exp_pos b ];
  · positivity





theorem activation_barrier (f : ℝ → ℝ) (h0 : f 0 = 0) (h1 : f 1 = 1) (hm1 : f (-1) = 0) :
    ¬ ∃ (a b : ℝ), ∀ x, f x = a * x + b := by
  exact fun ⟨ a, b, h ⟩ => by linarith [ h 0, h 1, h ( -1 ) ] ;





/-- ReLU satisfies the activation barrier conditions -/
theorem relu_satisfies_barrier : relu₀ 0 = 0 ∧ relu₀ 1 = 1 ∧ relu₀ (-1) = 0 := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [relu₀]





/-- A tropical polynomial with 3 terms -/
def tropPoly3 (a₁ b₁ a₂ b₂ a₃ b₃ x : ℝ) : ℝ :=
  max (max (a₁ * x + b₁) (a₂ * x + b₂)) (a₃ * x + b₃)





/-- ReLU(wx + b) is a 2-term tropical polynomial -/
theorem relu_is_tropical_poly (w b x : ℝ) :
    relu₀ (w * x + b) = max (w * x + b) 0 := by
  simp [relu₀]





/-- A tropical polynomial is piecewise linear: it is continuous -/
theorem tropPoly3_continuous (a₁ b₁ a₂ b₂ a₃ b₃ : ℝ) :
    Continuous (tropPoly3 a₁ b₁ a₂ b₂ a₃ b₃) := by
  unfold tropPoly3
  fun_prop





/-- The crystallization conjecture: there exists a critical time t* such that
the monomial count is non-decreasing before t* and non-increasing after t*. -/
def crystallization_conjecture (M : monomial_count) : Prop :=
  ∃ t_star : ℕ,
    (∀ t₁ t₂, t₁ ≤ t₂ → t₂ ≤ t_star → M t₁ ≤ M t₂) ∧
    (∀ t₁ t₂, t_star ≤ t₁ → t₁ ≤ t₂ → M t₂ ≤ M t₁)





/-- A trivially crystallized network (constant monomial count) satisfies the conjecture -/
theorem constant_crystallizes (c : ℕ) :
    crystallization_conjecture (fun _ => c) :=
  ⟨0, fun _ _ _ _ => le_refl c, fun _ _ _ _ => le_refl c⟩





end
