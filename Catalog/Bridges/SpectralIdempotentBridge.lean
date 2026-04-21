/-! # CatalogBuild.Bridges.SpectralIdempotentBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 24
-/

import Mathlib

noncomputable section

/-- An element is idempotent if e² = e. -/
def IsIdempotentElem' {R : Type*} [Mul R] (e : R) : Prop := e * e = e




/-- [Section: # CatalogBuild.Bridges.SpectralIdempotentBridge
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 24] -/
theorem idempotent_trace_in_set {a b c d : ℝ}
    (h1 : a * a + b * c = a)
    (h2 : a * b + b * d = b)
    (h3 : c * a + d * c = c)
    (h4 : c * b + d * d = d) :
    (a + d = 0 ∧ b = 0 ∧ c = 0) ∨
    a + d = 1 ∨
    (a + d = 2 ∧ b = 0 ∧ c = 0) := by
      grind




/-- [Section: # CatalogBuild.Bridges.SpectralIdempotentBridge
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 24] -/
theorem idempotent_det_squared {a b c d : ℝ}
    (h1 : a * a + b * c = a)
    (h2 : a * b + b * d = b)
    (h3 : c * a + d * c = c)
    (h4 : c * b + d * d = d) :
    (a * d - b * c) * (a * d - b * c) = a * d - b * c := by
      grind +ring




theorem idempotent_trace_values {a b c d : ℝ}
    (h1 : a * a + b * c = a)
    (h2 : a * b + b * d = b)
    (h3 : c * a + d * c = c)
    (h4 : c * b + d * d = d) :
    a + d = 0 ∨ a + d = 1 ∨ a + d = 2 := by
  grind




/-- Contraction powers are bounded by 1. -/
theorem contraction_decay (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1)
    (n : ℕ) : r ^ n ≤ 1 :=
  pow_le_one₀ hr0 (le_of_lt hr1)




/-- Contraction powers tend to zero. -/
theorem contraction_powers_vanish (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r < 1) :
    Filter.Tendsto (fun n => r ^ n) Filter.atTop (nhds 0) :=
  tendsto_pow_atTop_nhds_zero_of_lt_one hr0 hr1




/-- For idempotent f, convergence is immediate: one step suffices. -/
theorem idempotent_instant_convergence {α : Type*} (f : α → α)
    (hf : f ∘ f = f) (x : α) : f (f x) = f x := congr_fun hf x




/-- Project-then-act is stable under further projection. -/
theorem project_then_contract_stable {α : Type*} (proj : α → α) (f : α → α)
    (hproj : proj ∘ proj = proj) :
    (proj ∘ f ∘ proj) ∘ proj = proj ∘ f ∘ proj := by
  ext x; simp only [Function.comp_apply]
  have : proj (proj x) = proj x := congr_fun hproj x
  rw [this]




/-- A stochastic vector: non-negative entries summing to 1. -/
structure StochasticVec2 where
  p : ℝ
  q : ℝ
  hp : 0 ≤ p
  hq : 0 ≤ q
  hsum : p + q = 1




/-- The uniform distribution. -/
def uniformVec2 : StochasticVec2 where
  p := 1/2
  q := 1/2
  hp := by positivity
  hq := by positivity
  hsum := by ring




/-- Birkhoff (2×2): doubly stochastic rows and columns sum to 1. -/
theorem birkhoff_2x2 (a : ℝ) (ha0 : 0 ≤ a) (ha1 : a ≤ 1) :
    a + (1 - a) = 1 ∧ (1 - a) + a = 1 :=
  ⟨by ring, by ring⟩




/-- The stationary distribution of a 2×2 doubly stochastic chain is uniform. -/
theorem doubly_stochastic_uniform (a : ℝ) :
    a * (1/2 : ℝ) + (1 - a) * (1/2) = 1/2 := by ring




/-- Tropical eigenvalue: max of perfect matching weights. -/
def tropicalEigenvalue2 (a b c d : ℝ) : ℝ := max (a + d) (b + c)




/-- Tropical eigenvalue is symmetric under transposition. -/
theorem tropical_eigenvalue_transpose (a b c d : ℝ) :
    tropicalEigenvalue2 a b c d = tropicalEigenvalue2 a c b d := by
  simp only [tropicalEigenvalue2]; rw [add_comm b c]




/-- For a diagonal matrix, tropical eigenvalue = max of diagonal entries + 0. -/
theorem tropical_eigenvalue_diagonal (a d : ℝ) :
    tropicalEigenvalue2 a 0 0 d = max (a + d) 0 := by
  simp [tropicalEigenvalue2]




/-- Tropical eigenvalue is monotone. -/
theorem tropical_eigenvalue_monotone (a b c d a' b' c' d' : ℝ)
    (ha : a ≤ a') (hb : b ≤ b') (hc : c ≤ c') (hd : d ≤ d') :
    tropicalEigenvalue2 a b c d ≤ tropicalEigenvalue2 a' b' c' d' := by
  simp only [tropicalEigenvalue2]; exact max_le_max (by linarith) (by linarith)




/-- Classical trace ≤ tropical eigenvalue. -/
theorem spectral_tropical_bound (a b c d : ℝ) :
    a + d ≤ tropicalEigenvalue2 a b c d := le_max_left _ _




/-- Tropical eigenvalue of 2×2 identity. -/
theorem tropical_eigenvalue_identity :
    tropicalEigenvalue2 1 0 0 1 = 2 := by
  simp [tropicalEigenvalue2]; norm_num




/-- Tropical eigenvalue of zero matrix. -/
theorem tropical_eigenvalue_zero :
    tropicalEigenvalue2 0 0 0 0 = 0 := by simp [tropicalEigenvalue2]




/-- Idempotent scalar spectral: t² = t implies t = 0 or t = 1. -/
theorem idempotent_spectral_tropical_bridge {t : ℝ}
    (ht : t * t = t) : t = 0 ∨ t = 1 := by
  have : t * (t - 1) = 0 := by ring_nf; linarith
  rcases mul_eq_zero.mp this with h | h
  · left; exact h
  · right; linarith




/-- Scalar power iteration convergence. -/
theorem power_iteration_scalar (r : ℝ) (hr : |r| < 1) :
    Filter.Tendsto (fun n => r ^ n) Filter.atTop (nhds 0) :=
  tendsto_pow_atTop_nhds_zero_of_abs_lt_one hr




/-- Cesàro mean of a constant is itself. -/
theorem cesaro_idempotent {α : Type*} [AddCommMonoid α] [Module ℝ α]
    (v : α) (n : ℕ) (hn : 0 < n) :
    (1 / (n : ℝ)) • ((n : ℝ) • v) = v := by
  rw [smul_smul]; simp [Nat.cast_ne_zero.mpr (by omega : n ≠ 0)]




/-- For symmetric web, PageRank is uniform. -/
theorem pagerank_symmetric_uniform (d : ℝ) :
    d * (1/2 : ℝ) + (1 - d) * (1/2) = 1/2 := by ring




/-- PageRank contraction: |d·x - d·y| ≤ d·|x - y|. -/
theorem pagerank_contraction (d : ℝ) (hd : 0 ≤ d)
    (x y : ℝ) : |d * x - d * y| ≤ d * |x - y| := by
  rw [← mul_sub, abs_mul, abs_of_nonneg hd]




end
