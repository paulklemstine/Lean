import Mathlib

/-!
# Proof Space IV: The dimension of proof space and the length distribution

The exponential growth rate of proof space,

  `dim = lim_{n→∞} log (tot n) / n`,

plays the role of a Hausdorff / box-counting dimension: it measures how the
"volume" of proof space scales with resolution `n`.  For an alphabet of size `k`
this dimension equals `log k`, the topological entropy of the full shift.

We also introduce the induced *length distribution* on statements: weighting each
length `n` by the geometric factor `(k-1)/k^{n+1}` gives a genuine probability
distribution (`lengthDist_tsum`).  Its geometric tail `∝ k^{-n}` is, in the
length variable, exactly the power law predicted for the distribution of theorem
lengths, with rate controlled by the dimension `log k`.
-/

namespace ProofSpace

open Filter Topology Real

/--
**Dimension of proof space.**  If the number of statements of length `≤ n`
is squeezed between `k ^ n` and `k ^ (n+1)` (as it is for a `k`-symbol alphabet,
`k > 1`), then the growth rate `log (tot n) / n` converges to `log k`.  This is
the box-counting dimension / topological entropy of proof space.
-/
theorem dimension_eq_log (tot : ℕ → ℝ) (k : ℝ) (hk : 1 < k)
    (hlb : ∀ n, (k : ℝ) ^ n ≤ tot n)
    (hub : ∀ n, tot n ≤ (k : ℝ) ^ (n + 1)) :
    Tendsto (fun n : ℕ => Real.log (tot n) / n) atTop (𝓝 (Real.log k)) := by
  -- From the bounds, we have $n \log k \leq \log (tot n) \leq (n+1) \log k$.
  have h_bounds : ∀ n : ℕ, n * Real.log k ≤ Real.log (tot n) ∧ Real.log (tot n) ≤ (n + 1) * Real.log k := by
    exact fun n => ⟨ by simpa using Real.log_le_log ( by positivity ) ( hlb n ), by simpa using Real.log_le_log ( by linarith [ show 0 < tot n from lt_of_lt_of_le ( by positivity ) ( hlb n ) ] ) ( hub n ) ⟩;
  refine' Metric.tendsto_atTop.mpr _;
  intro ε hε; use ⌈ε⁻¹ * ( Real.log k + 1 ) ⌉₊ + 1; intro n hn; erw [ Real.dist_eq ] ; rw [ abs_lt ] ; constructor <;> nlinarith [ Nat.le_ceil ( ε⁻¹ * ( Real.log k + 1 ) ), mul_inv_cancel₀ ( ne_of_gt hε ), h_bounds n, show ( n:ℝ ) ≥ ⌈ε⁻¹ * ( Real.log k + 1 ) ⌉₊ + 1 by exact_mod_cast hn, mul_div_cancel₀ ( Real.log ( tot n ) ) ( show ( n:ℝ ) ≠ 0 by norm_cast; linarith ) ] ;

/--
The pointwise growth rate of the length-`= n` counts is exactly the
dimension: `log (k ^ n) / n = log k` for `n ≥ 1`.
-/
theorem dimension_exact (k : ℝ) (n : ℕ) (hn : 1 ≤ n) :
    Real.log (k ^ n) / n = Real.log k := by
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  rw [Real.log_pow]; field_simp

/-- The length distribution: length `n` gets weight `(k-1)/k^{n+1}`. -/
noncomputable def lengthDist (k : ℝ) (n : ℕ) : ℝ := (k - 1) / k ^ (n + 1)

/--
Each length has nonnegative weight (for `k ≥ 1`).
-/
theorem lengthDist_nonneg (k : ℝ) (hk : 1 ≤ k) (n : ℕ) : 0 ≤ lengthDist k n := by
  exact div_nonneg ( sub_nonneg.2 hk ) ( pow_nonneg ( by linarith ) _ )

/--
**The length distribution is a probability distribution.**  The geometric
weights `(k-1)/k^{n+1}` sum to `1` over all lengths.  Its `k^{-n}` tail is the
power law for theorem lengths, with exponent set by the dimension `log k`.
-/
theorem lengthDist_tsum (k : ℝ) (hk : 1 < k) :
    ∑' n : ℕ, lengthDist k n = 1 := by
  -- We simplify the expression $\frac{k-1}{k^{n+1}}$ to $\frac{k-1}{k} \cdot \frac{1}{k^n}$.
  have h_simp : ∑' n, lengthDist k n = (k - 1) / k * ∑' n, (1 / k : ℝ)^n := by
    rw [ ← tsum_mul_left ] ; congr ; ext n ; unfold lengthDist ; ring;
  rw [ h_simp, tsum_geometric_of_lt_one ( by positivity ) ( by rw [ div_lt_one ( by positivity ) ] ; linarith ) ];
  grind

end ProofSpace