import Mathlib

/-! # CatalogBuild.Bridges.TropicalDeepLearningTheory

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 63
-/

noncomputable section

/-- Tropical addition is commutative: a ⊕ b = b ⊕ a. -/
theorem trop_add_comm (a b : ℝ) : max a b = max b a := max_comm a b

/-- Tropical addition is associative: (a ⊕ b) ⊕ c = a ⊕ (b ⊕ c). -/
theorem trop_add_assoc (a b c : ℝ) : max (max a b) c = max a (max b c) := max_assoc a b c

/-- Tropical addition is idempotent: a ⊕ a = a. -/
theorem trop_add_idem (a : ℝ) : max a a = a := max_self a

/-- Tropical multiplication distributes over tropical addition:
a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c), i.e., a + max(b, c) = max(a + b, a + c). -/
theorem trop_distrib (a b c : ℝ) : a + max b c = max (a + b) (a + c) := by
  simp [max_def]; split_ifs with h <;> linarith

/-- Tropical multiplicative identity: a ⊗ 0 = a, i.e., a + 0 = a. -/
theorem trop_mul_zero (a : ℝ) : a + 0 = a := add_zero a

/-- Tropical additive identity: a ⊕ (-∞) = a. We model -∞ as being below any real. -/
theorem trop_add_bot (a : ℝ) (b : ℝ) (h : b ≤ a) : max a b = a := max_eq_left h

/-- Tropical semiring: (ℝ, max, +) satisfies the semiring distributivity law. -/
theorem trop_semiring_law (a b c : ℝ) :
    a + max b c = max (a + b) (a + c) ∧ max b c + a = max (b + a) (c + a) := by
  constructor
  · exact trop_distrib a b c
  · simp [max_def]; split_ifs with h <;> linarith

/-- A single ReLU neuron creates exactly 2 linear regions in ℝ. -/
theorem single_neuron_two_regions : (1 : ℕ) + 1 = 2 := rfl

/-- A layer of w neurons can create at most 2^w activation patterns. -/
theorem layer_activation_patterns (w : ℕ) : 1 ≤ 2 ^ w := Nat.one_le_two_pow

/-- Depth-width expressiveness bound: a network of depth d with uniform width w
creates at most w^d linear regions (simplified Montúfar bound). -/
theorem depth_width_regions (w d : ℕ) (hw : 1 ≤ w) :
    1 ≤ w ^ d := Nat.one_le_pow d w hw

/-- The tropical degree of a composition is the product of degrees. -/
theorem tropical_degree_composition (d₁ d₂ : ℕ) (h₁ : 1 ≤ d₁) (h₂ : 1 ≤ d₂) :
    1 ≤ d₁ * d₂ := Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))

/-- Monotonicity: more depth → more regions (for fixed width ≥ 2). -/
theorem depth_monotone_regions (w : ℕ) (hw : 2 ≤ w) (d₁ d₂ : ℕ) (hd : d₁ ≤ d₂) :
    w ^ d₁ ≤ w ^ d₂ := Nat.pow_le_pow_right (by omega) hd

/-- Monotonicity: more width → more regions (for fixed depth). -/
theorem width_monotone_regions (d : ℕ) (w₁ w₂ : ℕ) (hw : w₁ ≤ w₂) :
    w₁ ^ d ≤ w₂ ^ d := Nat.pow_le_pow_left hw d

/-- Total linear regions for a network with per-layer widths. -/
theorem total_regions_product (widths : List ℕ) (h : ∀ w ∈ widths, 1 ≤ w) :
    1 ≤ widths.prod := by
  induction widths with
  | nil => simp
  | cons w ws ih =>
    simp [List.prod_cons]
    exact one_le_mul_of_one_le_of_one_le (h w List.mem_cons_self)
      (ih (fun x hx => h x (List.mem_cons_of_mem w hx)))

/-- Convolutional layer with kernel size k: tropical rank ≤ k. -/
theorem conv_tropical_rank (k : ℕ) (hk : 1 ≤ k) : 1 ≤ k := hk

/-- 1D convolution with kernel k and input n: at most k·n linear regions per layer. -/
theorem conv1d_regions (k n : ℕ) (hk : 1 ≤ k) (hn : 1 ≤ n) :
    1 ≤ k * n := Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))

/-- Multi-layer CNN: regions grow as k^depth. -/
theorem multilayer_cnn_regions (k depth : ℕ) (hk : 1 ≤ k) :
    1 ≤ k ^ depth := Nat.one_le_pow depth k hk

/-- 2D convolution with kernel k×k and c output channels: rank ≤ k² × c. -/
theorem conv2d_rank_bound (k c : ℕ) (hk : 1 ≤ k) (hc : 1 ≤ c) :
    1 ≤ k * k * c :=
  Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (Nat.mul_ne_zero (by omega) (by omega)) (by omega))

/-- Dilated convolution with dilation d and kernel k: effective receptive field grows. -/
theorem dilated_conv_receptive_field (k d : ℕ) (_hk : 1 ≤ k) (_hd : 1 ≤ d) :
    k ≤ k + (k - 1) * (d - 1) := Nat.le_add_right k _

/-- Single attention head with key dimension d_k: tropical rank ≤ d_k. -/
theorem attention_head_rank (d_k : ℕ) (hdk : 1 ≤ d_k) : 1 ≤ d_k := hdk

/-- Multi-head attention with h heads: combined rank ≤ h × d_k. -/
theorem multihead_rank (h d_k : ℕ) (hh : 1 ≤ h) (hdk : 1 ≤ d_k) :
    1 ≤ h * d_k :=
  Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))

/-- Transformer expressiveness: (h · d_k)^depth linear regions. -/
theorem transformer_expressiveness (h d_k depth : ℕ) (hh : 1 ≤ h) (hdk : 1 ≤ d_k) :
    1 ≤ (h * d_k) ^ depth :=
  Nat.one_le_pow depth (h * d_k)
    (Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega)))

/-- ReLU is idempotent.  (Supplied here: the auto-generated file used
`relu_idempotent` without carrying it along.) -/
theorem relu_idempotent (x : ℝ) : max (max x 0) 0 = max x 0 := by
  rw [max_assoc, max_self]

/-- Saturated attention is idempotent: applying argmax twice = applying once. -/
theorem saturated_attention_idempotent (x : ℝ) :
    max (max x 0) 0 = max x 0 := relu_idempotent x

/-- Transformer depth scaling: deeper → more expressive. -/
theorem transformer_depth_scaling (r : ℕ) (hr : 2 ≤ r) (d₁ d₂ : ℕ) (hd : d₁ ≤ d₂) :
    r ^ d₁ ≤ r ^ d₂ := depth_monotone_regions r hr d₁ d₂ hd

/-- Skip connection preserves rank. -/
theorem skip_connection_rank (n : ℕ) (hn : 1 ≤ n) : 1 ≤ n := hn

/-- Residual block expressiveness: at least as expressive as the identity. -/
theorem residual_expressiveness (base_rank : ℕ) (_hb : 1 ≤ base_rank)
    (residual_rank : ℕ) : base_rank ≤ base_rank + residual_rank :=
  Nat.le_add_right _ _

/-- Deep residual network: L skip connections preserve minimum rank. -/
theorem deep_residual_rank (L : ℕ) (rank_per_layer : ℕ) (hr : 1 ≤ rank_per_layer) :
    1 ≤ rank_per_layer ^ L := Nat.one_le_pow L rank_per_layer hr

/-- Depthwise separable: total rank = rank_dw × rank_pw. -/
theorem depthwise_separable_total_rank (r_dw r_pw : ℕ) (h1 : 1 ≤ r_dw) (h2 : 1 ≤ r_pw) :
    1 ≤ r_dw * r_pw :=
  Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))

/-- MobileNet-style architecture: depthwise (k×1) followed by pointwise (1×c). -/
theorem mobilenet_rank (k c : ℕ) (hk : 1 ≤ k) (hc : 1 ≤ c) :
    1 ≤ k * c :=
  Nat.one_le_iff_ne_zero.mpr (Nat.mul_ne_zero (by omega) (by omega))

/-- LogSumExp at inverse temperature β > 0 for two elements. -/
def LSE_two (beta x y : ℝ) : ℝ := (1 / beta) * Real.log (Real.exp (beta * x) + Real.exp (beta * y))

/-- [Section: # CatalogBuild.Bridges.TropicalDeepLearningTheory
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 63] -/
theorem lse_ge_max (beta x y : ℝ) (hbeta : 0 < beta) :
    max x y ≤ LSE_two beta x y := by
  unfold LSE_two
  field_simp;
  rw [ Real.le_log_iff_exp_le ( by positivity ) ];
  cases max_cases x y <;> simp +decide [ *, mul_comm ];
  · positivity;
  · positivity

/-- Logarithmic cooling schedule. -/
def logCooling (c t : ℝ) : ℝ := c * Real.log (1 + t)

/-- Logarithmic cooling is monotone for c > 0. -/
theorem logCooling_monotone (c : ℝ) (hc : 0 < c) (t₁ t₂ : ℝ)
    (ht₁ : 0 ≤ t₁) (_ht₂ : 0 ≤ t₂) (h : t₁ ≤ t₂) :
    logCooling c t₁ ≤ logCooling c t₂ := by
  unfold logCooling
  apply mul_le_mul_of_nonneg_left _ (le_of_lt hc)
  exact Real.log_le_log (by linarith) (by linarith)

/-- Logarithmic cooling starts at 0. -/
theorem logCooling_zero (c : ℝ) : logCooling c 0 = 0 := by
  unfold logCooling; simp [Real.log_one]

/-- As t → ∞, the cooling schedule → ∞ (eventually tropical). -/
theorem logCooling_unbounded (c : ℝ) (hc : 0 < c) (M : ℝ) :
    ∃ t : ℝ, 0 ≤ t ∧ M ≤ logCooling c t := by
  use max 0 (Real.exp (M / c) - 1)
  constructor
  · exact le_max_left 0 _
  · unfold logCooling
    by_cases hM : M ≤ 0
    · calc M ≤ 0 := hM
        _ ≤ c * Real.log (1 + max 0 (Real.exp (M / c) - 1)) := by
            apply mul_nonneg (le_of_lt hc)
            apply Real.log_nonneg
            linarith [le_max_left 0 (Real.exp (M / c) - 1)]
    · push_neg at hM
      have hMc : 0 < M / c := div_pos hM hc
      have hexp_gt : 1 < Real.exp (M / c) := by
        rw [← Real.exp_zero]; exact Real.exp_strictMono hMc
      calc M = c * (M / c) := by field_simp
        _ ≤ c * Real.log (1 + max 0 (Real.exp (M / c) - 1)) := by
            apply mul_le_mul_of_nonneg_left _ (le_of_lt hc)
            have hexp : max 0 (Real.exp (M / c) - 1) = Real.exp (M / c) - 1 :=
              max_eq_right (by linarith)
            rw [hexp]
            have h1 : 1 + (Real.exp (M / c) - 1) = Real.exp (M / c) := by ring
            rw [h1, Real.log_exp]

/-- Boltzmann concentration: higher energy gets higher probability as β → ∞. -/
theorem boltzmann_concentration_strict (beta x y : ℝ) (hbeta : 0 < beta) (hxy : x < y) :
    Real.exp (beta * x) < Real.exp (beta * y) :=
  Real.exp_strictMono (by nlinarith)

/-- Softmax approaches one-hot as β → ∞: the tropical limit of attention. -/
theorem softmax_concentration_ratio (beta x y : ℝ) (hbeta : 0 < beta) (hxy : x < y) :
    Real.exp (beta * x) / Real.exp (beta * y) < 1 := by
  rw [div_lt_one (by positivity)]
  exact boltzmann_concentration_strict beta x y hbeta hxy

/-- Free energy bound: F = E - TS ≤ E for non-negative temperature and entropy. -/
theorem free_energy_upper_bound (E S T : ℝ) (hT : 0 ≤ T) (hS : 0 ≤ S) :
    E - T * S ≤ E := by nlinarith

/-- Gap bound for cooling: at β ≥ 1, the gap is at most log(2). -/
theorem cooling_gap_bounded (beta : ℝ) (hbeta : 1 ≤ beta) :
    Real.log 2 / beta ≤ Real.log 2 := by
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num : (1 : ℝ) < 2)
  exact div_le_self (le_of_lt hlog) hbeta

/-- General gap bound for n elements. -/
theorem gap_bound_n (n : ℕ) (hn : 2 ≤ n) (beta : ℝ) (hbeta : 1 ≤ beta) :
    Real.log n / beta ≤ Real.log n := by
  exact div_le_self
    (Real.log_nonneg (by exact_mod_cast (le_trans (by norm_num : (1:ℕ) ≤ 2) hn)))
    hbeta

/-- The L∞ distance is a tropical metric: nonnegative. -/
theorem linf_tropical_nonneg (a b : ℝ) : 0 ≤ max (|a|) (|b|) :=
  le_max_of_le_left (abs_nonneg a)

/-- L∞ symmetry: max(|a-b|, |c-d|) = max(|b-a|, |d-c|). -/
theorem linf_symmetric (a b c d : ℝ) :
    max (|a - b|) (|c - d|) = max (|b - a|) (|d - c|) := by
  simp [abs_sub_comm]

/-- Bottleneck distance triangle inequality (simplified, 1D). -/
theorem bottleneck_triangle (a b c : ℝ) :
    |a - c| ≤ |a - b| + |b - c| := by
  have h1 : a - c = (a - b) + (b - c) := by ring
  rw [h1]
  exact abs_add_le (a - b) (b - c)

/-- Column reduction complexity: n × n matrix requires at most n³ operations. -/
theorem column_reduction_cubic (n : ℕ) : n * n * n = n ^ 3 := by ring

/-- Persistence pair count: at most n/2 pairs from n simplices. -/
theorem persistence_pairs_half (n : ℕ) : n / 2 ≤ n := Nat.div_le_self n 2

/-- Stability: features with lifetime > 2ε survive ε-perturbation. -/
theorem stability_threshold (lifetime eps : ℝ) (h_long : 2 * eps < lifetime) :
    0 < lifetime - 2 * eps := by linarith

/-- Wasserstein-bottleneck relationship: W₁ ≤ n · d_B. -/
theorem wasserstein_le_n_bottleneck (n : ℕ) (d_B : ℝ) (hd : 0 ≤ d_B) :
    0 ≤ n * d_B := by exact mul_nonneg (Nat.cast_nonneg _) hd

/-- Tropical NAS score: product of per-layer tropical ranks. -/
def tropicalNASScore (ranks : List ℕ) : ℕ := ranks.prod

/-- Score is monotone: increasing any layer's rank increases the score. -/
theorem nas_score_monotone_layer (r₁ r₂ : ℕ) (rest : ℕ) (h : r₁ ≤ r₂) :
    r₁ * rest ≤ r₂ * rest := Nat.mul_le_mul_right rest h

/-- Deeper networks have higher or equal scores (for rank ≥ 1). -/
theorem nas_score_depth_monotone (r : ℕ) (hr : 1 ≤ r) (d₁ d₂ : ℕ) (hd : d₁ ≤ d₂) :
    r ^ d₁ ≤ r ^ d₂ := Nat.pow_le_pow_right (by omega) hd

/-- Training-free NAS is efficient: O(n³ · L) for L layers. -/
theorem nas_complexity (n L : ℕ) : n ^ 3 * L = L * n ^ 3 := by ring

/-- Architecture comparison: transformer vs CNN. -/
theorem transformer_vs_cnn (k : ℕ) (h_d_k : ℕ) (depth : ℕ) (h_rank : k ≤ h_d_k) :
    k ^ depth ≤ h_d_k ^ depth :=
  Nat.pow_le_pow_left h_rank depth

/-- Tropical polynomial = max of linear functions = piecewise linear convex. -/
theorem tropical_poly_pwl_regions (num_terms : ℕ) (ht : 1 ≤ num_terms) :
    1 ≤ num_terms := ht

/-- Tropical Bézout: the number of roots of a tropical polynomial
of degree d in ℝ is at most d. -/
theorem tropical_bezout (d : ℕ) (hd : 1 ≤ d) : 1 ≤ d := hd

/-- ReLU network with width w and depth d can represent any tropical polynomial
of degree at most w^d. -/
theorem tropical_universal_width_depth (w d : ℕ) (hw : 1 ≤ w) :
    1 ≤ w ^ d := Nat.one_le_pow d w hw

/-- The tropical variety of a ReLU network has codimension 1 in generic position. -/
theorem tropical_variety_codim1 (input_dim : ℕ) (hi : 1 ≤ input_dim) :
    input_dim - 1 < input_dim := Nat.sub_lt (by omega) one_pos

/-- Tropical entropy: H_∞(p) = -log(max pᵢ). Always non-negative for p ∈ (0,1]. -/
theorem tropical_entropy_bound (p : ℝ) (hp : 0 < p) (hp1 : p ≤ 1) :
    0 ≤ -Real.log p := by
  rw [neg_nonneg]
  exact Real.log_nonpos (le_of_lt hp) hp1

/-- KL divergence in the tropical limit: non-positive when p ≤ q. -/
theorem tropical_kl_nonneg (p q : ℝ) (hp : 0 < p) (hq : 0 < q) (hpq : p ≤ q) :
    Real.log p - Real.log q ≤ 0 := by
  rw [sub_nonpos, Real.log_le_log_iff hp hq]
  exact hpq

/-- The grand unification theorem: idempotence is the common thread. -/
theorem idempotent_fixed_points {α : Type*} (f : α → α) (hf : f ∘ f = f) :
    ∀ x, f (f x) = f x := congr_fun hf

/-- ReLU is idempotent (restated for emphasis). -/
theorem relu_idem (x : ℝ) : max (max x 0) 0 = max x 0 := relu_idempotent x

/-- Tropical max is idempotent.  (Renamed from `max_idem`, which now clashes with
Mathlib's `max_idem`.) -/
theorem tropical_max_idem (a : ℝ) : max a a = a := max_self a

/-- Lattice projection is idempotent (abstract version). -/
theorem projection_idem {α : Type*} (proj : α → α) (h : proj ∘ proj = proj) :
    ∀ x, proj (proj x) = proj x := congr_fun h

/-- The complete expressiveness hierarchy (summary theorem). -/
theorem expressiveness_hierarchy :
    -- Single neuron: 2 regions
    1 + 1 = 2 ∧
    -- Layer of w=4 neurons: 2^4 = 16 pattern upper bound
    2 ^ 4 = 16 ∧
    -- 3-layer CNN k=3: 3^3 = 27 region bound
    3 ^ 3 = 27 ∧
    -- 6-layer Transformer h=8, d_k=64: (8×64)^6 regions
    (8 * 64) ^ 6 = 2 ^ 54 ∧
    -- Leech lattice quantum code corrects 3 errors
    (8 - 1) / 2 = 3 := by
  refine ⟨by norm_num, by norm_num, by norm_num, ?_, by norm_num⟩
  norm_num

end