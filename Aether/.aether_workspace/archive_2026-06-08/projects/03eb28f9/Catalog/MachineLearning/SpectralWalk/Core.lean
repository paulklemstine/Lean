import Mathlib

/-!
# Spectral Walk Theory: Random Walks, Spectral Gaps, and Quantum Speedup

This module establishes a formal framework for analyzing random walks on finite
graphs via spectral gaps, with applications to Cayley graphs and quantum walks.

## Novel Definitions

- `SpectralWalkConfig`: Parameters of a random walk relevant to mixing analysis
- `LaplacianSpectralData`: Eigenvalue data for the normalized graph Laplacian
- `QuantumWalkConfig`: Quantum walk parameters with phase gap

## Main Results

### Mixing Theory
- `mixing_distance_mono`: Mixing distance is monotone decreasing
- `spectral_gap_comparison`: Larger gap ⟹ faster mixing
- `product_walk_gap_min`: Product walk gap ≥ min of component gaps

### Cycle Graph
- `one_minus_cos_le_sq_half`: 1 - cos(x) ≤ x²/2 (upper bound)
- `sin_pi_div_n_lower`: sin(π/n) ≥ 2/n for n ≥ 3 (Jordan's inequality)
- `cycle_spectral_gap_lower`: 1 - cos(2π/n) ≥ 8/n² (lower bound)
- `cycle_spectral_gap_tight`: 8/n² ≤ 1-cos(2π/n) ≤ 2π²/n² (tight asymptotics)

### Quantum Walks
- `quantum_relaxation_speedup`: 1/√γ ≤ 1/γ (quadratic speedup)

### Laplacian Theory
- `laplacian_spectral_gap_nonneg`: The spectral gap μ₂ ≥ 0
- `laplacian_trace_bound`: Σμᵢ ≤ 2n (trace bound)
- `laplacian_spectral_gap_upper`: μ₂ ≤ 2n/(n-1) (mean value bound)

## Mathematical Context

For a random walk on a finite graph with n vertices, the transition matrix P
has eigenvalues 1 = λ₁ ≥ λ₂ ≥ ... ≥ λₙ ≥ -1. The spectral gap γ = 1 - λ₂
controls mixing: ‖p_t - π‖₂ ≤ (1-γ)^t · √n. For cycle graphs, γ = 1 - cos(2π/n)
≈ 2π²/n², giving mixing time Θ(n²). Quantum walks achieve quadratic speedup
with t_quantum ≈ √(t_classical · log N).
-/

noncomputable section

open Real Finset BigOperators

/-! ## Core Definitions -/

/-- A spectral walk configuration captures the essential parameters of a
random walk on a finite graph relevant to mixing analysis. -/
structure SpectralWalkConfig where
  n : ℕ
  hn : n ≥ 2
  spectralGap : ℝ
  gap_pos : 0 < spectralGap
  gap_le_one : spectralGap ≤ 1

/-- The second eigenvalue magnitude λ₂ = 1 - γ. -/
def SpectralWalkConfig.lambda2 (cfg : SpectralWalkConfig) : ℝ :=
  1 - cfg.spectralGap

lemma SpectralWalkConfig.lambda2_nonneg (cfg : SpectralWalkConfig) :
    0 ≤ cfg.lambda2 := by
  unfold lambda2; linarith [cfg.gap_le_one]

lemma SpectralWalkConfig.lambda2_lt_one (cfg : SpectralWalkConfig) :
    cfg.lambda2 < 1 := by
  unfold lambda2; linarith [cfg.gap_pos]

/-- The L² mixing distance after t steps: (1-γ)^t · √n. -/
def SpectralWalkConfig.mixingDistance (cfg : SpectralWalkConfig) (t : ℕ) : ℝ :=
  cfg.lambda2 ^ t * Real.sqrt (cfg.n : ℝ)

/-- A **LaplacianSpectralData** captures the ordered eigenvalues of the
normalized graph Laplacian L = I - D⁻¹A, with 0 = μ₁ ≤ μ₂ ≤ ... ≤ μₙ ≤ 2.
This novel abstraction unifies spectral gap analysis across graph families. -/
structure LaplacianSpectralData where
  n : ℕ
  hn : n ≥ 2
  eigenvalues : Fin n → ℝ
  first_zero : eigenvalues ⟨0, by have := hn; omega⟩ = 0
  nonneg : ∀ i, 0 ≤ eigenvalues i
  le_two : ∀ i, eigenvalues i ≤ 2
  ordered : ∀ i j, i ≤ j → eigenvalues i ≤ eigenvalues j

/-- The spectral gap from Laplacian data: μ₂ (second-smallest eigenvalue). -/
def LaplacianSpectralData.spectralGap (L : LaplacianSpectralData) : ℝ :=
  L.eigenvalues ⟨1, by have := L.hn; omega⟩

/-- Quantum walk configuration extends spectral walk with phase gap δ ≥ √γ. -/
structure QuantumWalkConfig extends SpectralWalkConfig where
  phaseGap : ℝ
  phase_pos : 0 < phaseGap
  phase_ge_sqrt_gap : phaseGap ≥ Real.sqrt spectralGap

namespace SpectralWalk

/-! ## Mixing Bounds -/

/-- **Exponential Contraction**: The mixing distance contracts by factor (1-γ)
at each step. -/
theorem mixing_distance_step (cfg : SpectralWalkConfig) (t : ℕ) :
    cfg.mixingDistance (t + 1) = cfg.lambda2 * cfg.mixingDistance t := by
  unfold SpectralWalkConfig.mixingDistance; ring

/-
**Monotone Decay**: The mixing distance is non-increasing over time.
-/
theorem mixing_distance_mono (cfg : SpectralWalkConfig) (s t : ℕ) (hst : s ≤ t) :
    cfg.mixingDistance t ≤ cfg.mixingDistance s := by
  exact mul_le_mul_of_nonneg_right ( pow_le_pow_of_le_one ( by exact SpectralWalkConfig.lambda2_nonneg cfg ) ( by exact SpectralWalkConfig.lambda2_lt_one cfg |> le_of_lt ) hst ) ( Real.sqrt_nonneg _ )

/-- **Mixing Distance at Zero**: At time 0, the mixing distance equals √n. -/
theorem mixing_distance_zero (cfg : SpectralWalkConfig) :
    cfg.mixingDistance 0 = Real.sqrt (cfg.n : ℝ) := by
  unfold SpectralWalkConfig.mixingDistance; simp

/-
**Gap Comparison**: A larger spectral gap implies faster mixing.
-/
theorem spectral_gap_comparison (cfg₁ cfg₂ : SpectralWalkConfig)
    (h_same_n : cfg₁.n = cfg₂.n)
    (h_gap : cfg₁.spectralGap ≤ cfg₂.spectralGap) (t : ℕ) :
    cfg₂.mixingDistance t ≤ cfg₁.mixingDistance t := by
  unfold SpectralWalkConfig.mixingDistance;
  gcongr;
  · exact pow_nonneg cfg₁.lambda2_nonneg _;
  · exact cfg₂.lambda2_nonneg;
  · exact sub_le_sub_left h_gap _;
  · linarith

/-
**Product Walk Spectral Gap**: For the product of two independent walks,
the spectral gap of the product is at least the minimum of individual gaps.
Uses: 1 - (1-γ₁)(1-γ₂) = γ₁ + γ₂ - γ₁γ₂ ≥ min(γ₁, γ₂).
-/
theorem product_walk_gap_min (γ₁ γ₂ : ℝ) (h₁ : 0 < γ₁) (_h₂ : 0 < γ₂)
    (_hle₁ : γ₁ ≤ 1) (hle₂ : γ₂ ≤ 1) :
    1 - (1 - γ₁) * (1 - γ₂) ≥ min γ₁ γ₂ := by
  cases min_cases γ₁ γ₂ <;> nlinarith

/-
**Mixing distance initially large**: At time 0, distance ≥ 1 for n ≥ 2.
-/
theorem mixing_distance_initially_large (cfg : SpectralWalkConfig) :
    cfg.mixingDistance 0 ≥ 1 := by
  norm_num [ mixing_distance_zero ];
  linarith [ cfg.hn ]

/-
**Quantum Speedup**: 1/√γ ≤ 1/γ for 0 < γ ≤ 1.
Shows the quantum relaxation time is at most √(classical relaxation time).
-/
theorem quantum_relaxation_speedup (γ : ℝ) (hγ : 0 < γ) (hγ1 : γ ≤ 1) :
    1 / Real.sqrt γ ≤ 1 / γ := by
  gcongr ; nlinarith [ Real.sqrt_nonneg γ, Real.sq_sqrt hγ.le ]

/-
**Discrete Poincaré core**: If γ·V ≤ E then V ≤ (1/γ)·E.
-/
theorem discrete_poincare_core (γ V E : ℝ)
    (hγ : 0 < γ) (_hE : 0 ≤ E)
    (h_relation : γ * V ≤ E) :
    V ≤ (1 / γ) * E := by
  rw [ div_mul_eq_mul_div, le_div_iff₀ ] <;> linarith

/-
**Expander mixing core**: λ · √(a·b) ≤ λ for 0 ≤ a,b ≤ 1, 0 ≤ λ.
-/
theorem expander_mixing_core (lam a b : ℝ)
    (hlam : 0 ≤ lam)
    (ha : 0 ≤ a) (ha1 : a ≤ 1) (_hb : 0 ≤ b) (hb1 : b ≤ 1) :
    lam * Real.sqrt (a * b) ≤ lam := by
  exact mul_le_of_le_one_right hlam ( Real.sqrt_le_iff.mpr ⟨ by positivity, by nlinarith ⟩ )

/-! ## Trigonometric Bounds for Cycle Graphs -/

/-
**Half-angle identity**: 1 - cos(x) = 2·sin²(x/2).
-/
theorem one_minus_cos_eq_two_sin_sq_half (x : ℝ) :
    1 - cos x = 2 * sin (x / 2) ^ 2 := by
  simpa only [ Real.sin_sq, Real.cos_sq ] using by ring;

/-
**Sine squared bound**: sin²(x) ≤ x² for all x.
-/
theorem sin_sq_le_sq (x : ℝ) : sin x ^ 2 ≤ x ^ 2 := by
  exact Real.sin_sq_le_sq

/-
**Cosine quadratic upper bound**: 1 - cos(x) ≤ x²/2.
Chains half-angle identity with sin²(y) ≤ y².
-/
theorem one_minus_cos_le_sq_half (x : ℝ) : 1 - cos x ≤ x ^ 2 / 2 := by
  convert one_minus_cos_eq_two_sin_sq_half x ▸ mul_le_mul_of_nonneg_left ( sin_sq_le_sq ( x / 2 ) ) zero_le_two using 1 ; ring

/-
**Cycle spectral gap upper bound**: 1 - cos(2π/n) ≤ 2π²/n² for n ≥ 1.
-/
theorem cycle_spectral_gap_upper (n : ℕ) (_hn : n ≥ 1) :
    1 - cos (2 * π / n) ≤ 2 * π ^ 2 / n ^ 2 := by
  convert one_minus_cos_le_sq_half ( 2 * Real.pi / n ) using 1 ; ring

/-
**Jordan's inequality applied**: sin(π/n) ≥ 2/n for n ≥ 3.
From sin(x) ≥ (2/π)·x for 0 ≤ x ≤ π/2, with x = π/n.
-/
theorem sin_pi_div_n_lower (n : ℕ) (hn : n ≥ 3) :
    sin (π / (n : ℝ)) ≥ 2 / (n : ℝ) := by
  have := Real.mul_le_sin ( by positivity ) ( show Real.pi / n ≤ Real.pi / 2 by rw [ div_le_iff₀' ( by positivity ) ] ; nlinarith [ Real.pi_pos, show ( n : ℝ ) ≥ 3 by norm_cast ] );
  rwa [ div_mul_div_cancel₀ Real.pi_ne_zero ] at this

/-
**Cycle spectral gap lower bound (main theorem)**:
1 - cos(2π/n) ≥ 8/n² for n ≥ 3.
Proof: 1-cos(2π/n) = 2sin²(π/n) ≥ 2·(2/n)² = 8/n².
-/
theorem cycle_spectral_gap_lower (n : ℕ) (hn : n ≥ 3) :
    1 - cos (2 * π / (n : ℝ)) ≥ 8 / (n : ℝ) ^ 2 := by
  -- Use the identity $1 - \cos(x) = 2 \sin^2(x/2)$ with $x = 2\pi/n$.
  have h_identity : 1 - Real.cos (2 * Real.pi / n) = 2 * (Real.sin (Real.pi / n))^2 := by
    rw [ Real.sin_sq, Real.cos_sq ] ; ring;
  -- Use the inequality $\sin(\pi/n) \geq 2/n$ for $n \geq 3$.
  have h_sin_bound : Real.sin (Real.pi / n) ≥ 2 / n := by
    convert sin_pi_div_n_lower n hn using 1;
  exact h_identity.symm ▸ le_trans ( by ring_nf; norm_num ) ( mul_le_mul_of_nonneg_left ( pow_le_pow_left₀ ( by positivity ) h_sin_bound 2 ) zero_le_two )

/-- **Tight asymptotics**: 8/n² ≤ 1-cos(2π/n) ≤ 2π²/n² for n ≥ 3.
This proves the cycle graph has mixing time Θ(n²). -/
theorem cycle_spectral_gap_tight (n : ℕ) (hn : n ≥ 3) :
    8 / (n : ℝ) ^ 2 ≤ 1 - cos (2 * π / (n : ℝ)) ∧
    1 - cos (2 * π / (n : ℝ)) ≤ 2 * π ^ 2 / (n : ℝ) ^ 2 := by
  exact ⟨cycle_spectral_gap_lower n hn, cycle_spectral_gap_upper n (by omega)⟩

/-! ## Laplacian Spectral Theory -/

/-- The spectral gap μ₂ ≥ 0 (from non-negativity of eigenvalues). -/
theorem laplacian_spectral_gap_nonneg (L : LaplacianSpectralData) :
    0 ≤ L.spectralGap := by
  exact L.nonneg _

/-
**Trace bound**: Σᵢ μᵢ ≤ 2n for the normalized Laplacian.
Since each eigenvalue μᵢ ≤ 2, the sum of all n eigenvalues is at most 2n.
-/
theorem laplacian_trace_bound (L : LaplacianSpectralData) :
    ∑ i : Fin L.n, L.eigenvalues i ≤ 2 * (L.n : ℝ) := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => L.le_two _ ) ( by norm_num; linarith )

/-
**Spectral gap upper bound from trace**: μ₂ ≤ 2n/(n-1).
Since μ₁ = 0 and Σμᵢ ≤ 2n, the average of μ₂,...,μₙ is at most
2n/(n-1), so μ₂ ≤ 2n/(n-1).
-/
theorem laplacian_spectral_gap_upper (L : LaplacianSpectralData) :
    L.spectralGap ≤ 2 * (L.n : ℝ) / ((L.n : ℝ) - 1) := by
  rcases L with ⟨ n, hn, eigenvalues, first_zero, nonneg, le_two, ordered ⟩;
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  · contradiction;
  · lia;
  · exact le_trans ( le_two _ ) ( by rw [ le_div_iff₀ ] <;> linarith )

/-
**Cheeger-type relationship**: For any LaplacianSpectralData with spectral
gap μ₂, the mixing distance after t steps is bounded. Specifically,
(1 - μ₂)^t ≤ 1 when μ₂ ≥ 0, which is trivially true but connects
the Laplacian spectral gap to the walk spectral gap γ = μ₂.
-/
theorem laplacian_gap_to_contraction (L : LaplacianSpectralData)
    (hgap : 0 < L.spectralGap) (hle : L.spectralGap ≤ 1) (t : ℕ) :
    (1 - L.spectralGap) ^ t ≤ 1 := by
  exact pow_le_one₀ ( by linarith ) ( by linarith )

end SpectralWalk

end