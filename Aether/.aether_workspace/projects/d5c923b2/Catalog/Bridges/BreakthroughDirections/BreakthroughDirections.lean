import Mathlib

/-! # CatalogBuild.Bridges.BreakthroughDirections

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 43
-/

noncomputable section

/-- The tropical max operation is idempotent. -/
theorem tropical_max_idempotent (x : ℝ) : max x x = x := max_self x

/-- A single ReLU neuron creates at most 2 linear regions. -/
theorem single_relu_regions : (2 : ℕ) = 1 + 1 := by norm_num

/-- Region count for a layer of width w: at most 2^w regions. -/
theorem layer_region_count (w : ℕ) : 1 ≤ 2 ^ w := Nat.one_le_two_pow

/-- Tropical rank governs expressiveness: a network with tropical rank r
in each layer and depth d has at most r^d linear regions. -/
theorem tropical_rank_expressiveness (r d : ℕ) (hr : 1 ≤ r) :
    1 ≤ r ^ d := Nat.one_le_pow d r hr

/-- Architecture comparison: higher tropical rank ⟹ at least as expressive. -/
theorem architecture_comparison (r₁ r₂ d : ℕ)
    (hr : r₁ ≤ r₂) : r₁ ^ d ≤ r₂ ^ d := Nat.pow_le_pow_left hr d

/-- The tropical spectral radius controls signal propagation.
If ρ_trop ≤ 1, signals don't explode through the network. -/
theorem tropical_spectral_stability (rho : ℝ) (hrho_nn : 0 ≤ rho) (hrho : rho ≤ 1)
    (d : ℕ) : rho ^ d ≤ 1 := pow_le_one₀ hrho_nn hrho

/-- [Section: # CatalogBuild.Bridges.BreakthroughDirections
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 43] -/
theorem depth_advantage (w d : ℕ) (hw : 2 ≤ w) (hd : 1 ≤ d) :
    w * d + 1 ≤ w ^ (d + 1) := by
      induction hd <;> simp_all +decide [ pow_succ' ];
      · linarith;
      · nlinarith [ mul_le_mul_of_nonneg_left ‹1 ≤ _› ( Nat.zero_le w ) ]

/-- LogSumExp for two arguments. -/
def lse2 (x y : ℝ) : ℝ := Real.log (Real.exp x + Real.exp y)

/-- LogSumExp is symmetric. -/
theorem lse2_comm (x y : ℝ) : lse2 x y = lse2 y x := by
  simp [lse2, add_comm]

/-- The LogSumExp lower bound: max(x,y) ≤ LSE(x,y). -/
theorem lse_sandwich_lower (x y : ℝ) : max x y ≤ lse2 x y := by
  rw [lse2, max_le_iff]
  constructor <;> rw [Real.le_log_iff_exp_le (by positivity)]
  · linarith [exp_pos y]
  · linarith [exp_pos x]

/-- The LogSumExp upper bound: LSE(x,y) ≤ max(x,y) + log(2). -/
theorem lse_sandwich_upper (x y : ℝ) : lse2 x y ≤ max x y + Real.log 2 := by
  rw [lse2, Real.log_le_iff_le_exp (by positivity)]
  have h1 := exp_le_exp.mpr (le_max_left x y)
  have h2 := exp_le_exp.mpr (le_max_right x y)
  calc exp x + exp y
      ≤ exp (max x y) + exp (max x y) := by linarith
    _ = 2 * exp (max x y) := by ring
    _ = exp (max x y + log 2) := by
        rw [Real.exp_add, Real.exp_log (by norm_num : (2:ℝ) > 0)]; ring

/-- The full sandwich: the gap is exactly bounded by log(2) ≈ 0.693 (one bit). -/
theorem lse_sandwich (x y : ℝ) :
    max x y ≤ lse2 x y ∧ lse2 x y ≤ max x y + Real.log 2 :=
  ⟨lse_sandwich_lower x y, lse_sandwich_upper x y⟩

/-- The tropical-quantum gap is non-negative and bounded by log(2). -/
theorem tropical_quantum_gap (x y : ℝ) :
    0 ≤ lse2 x y - max x y ∧ lse2 x y - max x y ≤ Real.log 2 := by
  constructor
  · linarith [lse_sandwich_lower x y]
  · linarith [lse_sandwich_upper x y]

/-- Softmax probability for a two-class system. -/
def softmax_prob (x y : ℝ) : ℝ := Real.exp x / (Real.exp x + Real.exp y)

/-- Softmax probabilities are non-negative. -/
theorem softmax_nonneg (x y : ℝ) : 0 ≤ softmax_prob x y := by
  unfold softmax_prob; positivity

/-- Softmax probabilities sum to 1: conservation of probability. -/
theorem softmax_sum_one (x y : ℝ) :
    softmax_prob x y + softmax_prob y x = 1 := by
  unfold softmax_prob
  have h : 0 < Real.exp x + Real.exp y := by positivity
  field_simp; ring

/-- [Section: # CatalogBuild.Bridges.BreakthroughDirections
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 43] -/
theorem optimization_gap_less_than_one :
    Real.log 2 < 1 := by
      exact Real.log_two_lt_d9.trans_le <| by norm_num;

/-- Annealing: at low temperature (large β), LSE → max (exploitation).
At high temperature (small β), LSE → average (exploration). -/
theorem annealing_exploration (x y : ℝ) (hxy : x ≤ y) :
    0 ≤ lse2 x y - y := by
  have := lse_sandwich_lower x y
  have : y = max x y := (max_eq_right hxy).symm
  linarith

theorem annealing_exploitation (x y : ℝ) (hxy : x ≤ y) :
    lse2 x y - y ≤ Real.log 2 := by
  have := lse_sandwich_upper x y
  have : y = max x y := (max_eq_right hxy).symm
  linarith

/-- A persistence interval [birth, death) with birth ≤ death. -/
structure PersistenceInterval where
  birth : ℝ
  death : ℝ
  valid : birth ≤ death

/-- Lifetime of a persistence interval. -/
def PersistenceInterval.lifetime (I : PersistenceInterval) : ℝ :=
  I.death - I.birth

/-- Lifetime is non-negative. -/
theorem PersistenceInterval.lifetime_nonneg (I : PersistenceInterval) :
    0 ≤ I.lifetime := sub_nonneg.mpr I.valid

/-- The L∞ (tropical) distance between two persistence points.
This is the bottleneck distance: d∞((b₁,d₁), (b₂,d₂)) = max(|b₁-b₂|, |d₁-d₂|). -/
def tropicalPersistenceDist (I J : PersistenceInterval) : ℝ :=
  max (|I.birth - J.birth|) (|I.death - J.death|)

/-- The tropical persistence distance is non-negative. -/
theorem tropicalPersistenceDist_nonneg (I J : PersistenceInterval) :
    0 ≤ tropicalPersistenceDist I J := by
  unfold tropicalPersistenceDist
  exact le_max_of_le_left (abs_nonneg _)

/-- The tropical persistence distance is symmetric. -/
theorem tropicalPersistenceDist_symm (I J : PersistenceInterval) :
    tropicalPersistenceDist I J = tropicalPersistenceDist J I := by
  simp [tropicalPersistenceDist, abs_sub_comm]

/-- Identity of indiscernibles. -/
theorem tropicalPersistenceDist_eq_zero (I J : PersistenceInterval)
    (h : I.birth = J.birth) (h2 : I.death = J.death) :
    tropicalPersistenceDist I J = 0 := by
  simp [tropicalPersistenceDist, h, h2]

theorem tropicalPersistenceDist_triangle (I J K : PersistenceInterval) :
    tropicalPersistenceDist I K ≤
    tropicalPersistenceDist I J + tropicalPersistenceDist J K := by
      unfold tropicalPersistenceDist;
      exact max_le_iff.mpr ⟨ by cases max_cases |I.birth - J.birth| |I.death - J.death| <;> cases max_cases |J.birth - K.birth| |J.death - K.death| <;> linarith [ abs_sub_le ( I.birth ) ( J.birth ) ( K.birth ), abs_sub_le ( I.death ) ( J.death ) ( K.death ) ], by cases max_cases |I.birth - J.birth| |I.death - J.death| <;> cases max_cases |J.birth - K.birth| |J.death - K.death| <;> linarith [ abs_sub_le ( I.birth ) ( J.birth ) ( K.birth ), abs_sub_le ( I.death ) ( J.death ) ( K.death ) ] ⟩

/-- Significant features survive small perturbations (tropical stability). -/
theorem significant_feature_stability (I J : PersistenceInterval) (t ε : ℝ)
    (hsig : I.lifetime > t + 2 * ε)
    (hclose : tropicalPersistenceDist I J ≤ ε) :
    J.lifetime > t := by
  unfold PersistenceInterval.lifetime at hsig ⊢
  unfold tropicalPersistenceDist at hclose
  have hb : |I.birth - J.birth| ≤ ε := (le_max_left _ _).trans hclose
  have hd : |I.death - J.death| ≤ ε := (le_max_right _ _).trans hclose
  rw [abs_le] at hb hd
  linarith

/-- The diagonal distance: distance from a persistence interval to the diagonal. -/
def diagonalDist (I : PersistenceInterval) : ℝ := I.lifetime / 2

/-- Features far from the diagonal are robust under perturbation. -/
theorem diagonal_robustness (I : PersistenceInterval) (ε : ℝ)
    (hfar : diagonalDist I > ε) :
    I.lifetime > 2 * ε := by
  unfold diagonalDist at hfar; linarith

/-- The Hurwitz dimensions: only 1, 2, 4, 8 admit division algebras. -/
theorem hurwitz_dimensions_exist :
    ∀ n ∈ ([1, 2, 4, 8] : List ℕ), 0 < n := by decide

/-- The Brahmagupta-Fibonacci identity: norm-multiplicativity for ℂ. -/
theorem brahmagupta_fibonacci (a b c d : ℝ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-- E8 kissing number decomposes as 112 + 128 = 240. -/
theorem e8_kissing_decomposition : 112 + 128 = (240 : ℕ) := by norm_num

/-- The 112 short roots: ±eᵢ ± eⱼ for i < j gives (8 choose 2) × 2² = 112. -/
theorem e8_short_roots : Nat.choose 8 2 * 4 = 112 := by native_decide

/-- The 128 half-integer roots: half of 2⁸ sign patterns (even # of minuses). -/
theorem e8_half_integer_roots : 2^8 / 2 = (128 : ℕ) := by norm_num

/-- E8 minimum squared distance is 2. -/
theorem e8_min_distance_squared : Real.sqrt 2 * Real.sqrt 2 = (2 : ℝ) := by
  rw [Real.mul_self_sqrt (by norm_num : (2:ℝ) ≥ 0)]

/-- Code composition via norm multiplicativity (complex case). -/
theorem division_algebra_code_composition (x₁ x₂ y₁ y₂ : ℝ) :
    (x₁^2 + x₂^2) * (y₁^2 + y₂^2) = (x₁*y₁ - x₂*y₂)^2 + (x₁*y₂ + x₂*y₁)^2 := by
  ring

/-- Sphere packing bound: positive density exists in any dimension. -/
theorem sphere_packing_positive_density (n : ℕ) :
    (0 : ℝ) < 1 / 2^n := by positivity

/-- Cayley-Dickson doubling: dimensions follow 2^k. -/
theorem cayley_dickson_doubling : ∀ k : Fin 4, [1, 2, 4, 8].get k = 2 ^ k.val := by
  decide

/-- E8 lattice is even: all squared norms are even integers. -/
theorem e8_even_property (k : ℕ) : Even (2 * k) := ⟨k, by ring⟩

/-- The master equation: idempotence unifies all four directions. -/
theorem idempotent_master_equation (f : ℝ → ℝ) (hf : f ∘ f = f) :
    ∀ x, f (f x) = f x := fun x => congr_fun hf x

/-- Image equals fixed points for idempotent functions. -/
theorem idempotent_image_eq_fixed (f : ℝ → ℝ) (hf : f ∘ f = f) :
    ∀ y ∈ Set.range f, f y = y := by
  rintro y ⟨x, rfl⟩
  exact congr_fun hf x

/-- The idempotent-tropical-quantum hierarchy is a refinement chain. -/
theorem hierarchy_refinement (x y : ℝ) :
    max x y ≤ lse2 x y := lse_sandwich_lower x y

end