import Mathlib
import Pythagorean.Counting

/-! # The order parameter of a proof space

Two observables accompany the raw count `S k n` of a syntactic proof space:

* the **order parameter** `orderParameter prov k n = prov n / S k n`, the fraction of the
  space occupied by a distinguished (derivable) subfamily counted by `prov`.  Exponential
  sparsity of the subfamily at a rate below the alphabet size drives the order parameter
  to zero — the "disordered phase" of the proof space;
* the **top-layer fraction** `topLayerFraction k n = kⁿ / S k n`, which by contrast stays
  bounded below by `1/k`: the ambient space is always dominated by its longest words;
* the **geometric length model** `lengthDist k n = (k − 1)/k^(n+1)`, whose successive
  ratio is the constant `exp (−log k)` rather than a power law.
-/

namespace ProofSpace

open Filter Topology

/-- The fraction of the proof space occupied by a counted subfamily. -/
noncomputable def orderParameter (prov : ℕ → ℕ) (k n : ℕ) : ℝ := (prov n : ℝ) / (S k n : ℝ)

/-- The fraction of the proof space occupied by the words of maximal length. -/
noncomputable def topLayerFraction (k n : ℕ) : ℝ := (k : ℝ) ^ n / (S k n : ℝ)

/-- The geometric length model with entropy `log k`. -/
noncomputable def lengthDist (k : ℝ) (n : ℕ) : ℝ := (k - 1) / k ^ (n + 1)

theorem topLayerFraction_le_one (k n : ℕ) : topLayerFraction k n ≤ 1 := by
  rw [topLayerFraction, div_le_one (by exact_mod_cast S_pos k n)]
  exact_mod_cast pow_le_S k n

theorem topLayerFraction_nonneg (k n : ℕ) : 0 ≤ topLayerFraction k n :=
  div_nonneg (by positivity) (by positivity)

/-- For an alphabet with at least two letters the longest layer occupies at least the
fraction `1/k` of the space: this observable does **not** vanish asymptotically. -/
theorem inv_le_topLayerFraction (k n : ℕ) (hk : 2 ≤ k) :
    1 / (k : ℝ) ≤ topLayerFraction k n := by
  have hk0 : (0 : ℝ) < k := by
    have : (2 : ℝ) ≤ k := by exact_mod_cast hk
    linarith
  have hS : (0 : ℝ) < S k n := by exact_mod_cast S_pos k n
  rw [topLayerFraction, div_le_div_iff₀ hk0 hS]
  have h := S_le_pow k n hk
  have h' : (S k n : ℝ) ≤ (k : ℝ) ^ (n + 1) := by exact_mod_cast h
  calc (1 : ℝ) * S k n = (S k n : ℝ) := one_mul _
    _ ≤ (k : ℝ) ^ (n + 1) := h'
    _ = (k : ℝ) ^ n * k := by rw [pow_succ]

theorem orderParameter_nonneg (prov : ℕ → ℕ) (k n : ℕ) : 0 ≤ orderParameter prov k n :=
  div_nonneg (by positivity) (by positivity)

/-- **The order parameter vanishes in the sparse phase.**  If the counted subfamily grows
at an exponential rate `a` strictly below the alphabet size `k`, its density in the proof
space tends to zero. -/
theorem orderParameter_tendsto_zero (prov : ℕ → ℕ) (k : ℕ) (a C : ℝ)
    (hk : 2 ≤ k) (ha0 : 0 ≤ a) (hak : a < k) (hC : 0 ≤ C)
    (hsparse : ∀ n, (prov n : ℝ) ≤ C * a ^ n) :
    Tendsto (orderParameter prov k) atTop (𝓝 0) := by
  have hk0 : (0 : ℝ) < k := by
    have : (2 : ℝ) ≤ k := by exact_mod_cast hk
    linarith
  have hbound : ∀ n, orderParameter prov k n ≤ C * (a / k) ^ n := by
    intro n
    have hS : (0 : ℝ) < (k : ℝ) ^ n := by positivity
    have hSk : ((k : ℝ) ^ n) ≤ (S k n : ℝ) := by exact_mod_cast pow_le_S k n
    have hSpos : (0 : ℝ) < (S k n : ℝ) := by exact_mod_cast S_pos k n
    calc orderParameter prov k n ≤ (C * a ^ n) / ((k : ℝ) ^ n) := by
          rw [orderParameter, div_le_div_iff₀ hSpos hS]
          have h1 := hsparse n
          have h2 : (0 : ℝ) ≤ (prov n : ℝ) := by positivity
          have h3 : (0 : ℝ) ≤ C * a ^ n := by positivity
          nlinarith [hSk, hS.le]
      _ = C * (a / k) ^ n := by rw [div_pow]; ring
  refine squeeze_zero (fun n => orderParameter_nonneg prov k n) hbound ?_
  have hlt : a / k < 1 := (div_lt_one hk0).2 hak
  have := tendsto_pow_atTop_nhds_zero_of_lt_one (by positivity) hlt
  simpa using (tendsto_const_nhds (x := C)).mul this

/-- **Successive ratio of the geometric length model.**  The model has constant ratio
`exp (−log k)`, so it is geometric and not a power law. -/
theorem lengthDist_ratio (k : ℝ) (hk : 1 < k) (n : ℕ) :
    lengthDist k (n + 1) / lengthDist k n = Real.exp (-Real.log k) := by
  have hk0 : (0 : ℝ) < k := lt_trans zero_lt_one hk
  have hk1 : k - 1 ≠ 0 := by linarith
  rw [lengthDist, lengthDist, Real.exp_neg, Real.exp_log hk0]
  field_simp
  ring

/-- The geometric length model is positive. -/
theorem lengthDist_pos (k : ℝ) (hk : 1 < k) (n : ℕ) : 0 < lengthDist k n := by
  have hk0 : (0 : ℝ) < k := lt_trans zero_lt_one hk
  rw [lengthDist]
  exact div_pos (by linarith) (by positivity)

end ProofSpace