/-
# Cycle 4: depth composition amplifies the prefactor, not the exponent

Cycle 2 (`Algebra.KVCacheResponseExponent`) showed that reproducing the NET-94 pair
`(+0.142 % at 8 bits, +867.694 % at 5 bits)` forces a per-bit shrink base above `18`,
equivalently a power-law response exponent `γ ≥ 5`, whereas a uniform quantiser only
offers base `2`.  The obvious escape route is **depth**: a served model stacks `L`
attention layers, each amplifying the perturbation it receives, so perhaps the end-to-end
response is much steeper than the single-layer response.

This file tests that conjecture, and **refutes it**.  Model a stack by the standard
error recursion `δ_{L+1} ≤ λ δ_L + e` (per-layer Lipschitz gain `λ`, per-layer injected
quantisation error `e`):

* `error_propagation_le` — the recursion really does bound the end-to-end deviation of
  two trajectories that start together (induction on depth).
* `errAfter_eq_geom` — its closed form is the geometric factor `e · Σ_{i<L} λ^i`.
* `depth_preserves_response_exponent` — therefore composing a power-law response with
  exponent `γ` over `L` layers returns a power-law response with **the same exponent `γ`**
  and prefactor multiplied by `Σ_{i<L} λ^i`.  Depth is a constant, not a slope.
* `depth_cannot_rescue_low_exponent` — consequently the cycle-2 bound survives depth
  composition verbatim: any depth, any gain, still `γ ≥ 5`.

Conclusion for the research thread: depth is eliminated as an explanation of the NET-94
key cliff, which sharpens the remaining hypothesis (outlier-scaled block quantisation)
by removing its main competitor.
-/
import Mathlib
import Algebra.KVCacheResponseExponent

namespace Catalog.Algebra.KVCache

/-- Worst-case deviation after `L` layers of the recursion `δ ↦ λ δ + e`: each layer
amplifies the incoming deviation by the Lipschitz gain `λ` and injects its own
quantisation error `e`. -/
noncomputable def errAfter (lam e : ℝ) : ℕ → ℝ
  | 0 => 0
  | L + 1 => lam * errAfter lam e L + e

@[simp] lemma errAfter_zero (lam e : ℝ) : errAfter lam e 0 = 0 := rfl

@[simp] lemma errAfter_succ (lam e : ℝ) (L : ℕ) :
    errAfter lam e (L + 1) = lam * errAfter lam e L + e := rfl

/-- **The recursion is a genuine bound.**  If two trajectories start at the same state and
each layer is `λ`-Lipschitz up to an injected error `e`, their deviation after `L` layers
is at most `errAfter lam e L`. -/
theorem error_propagation_le {lam e : ℝ} (hlam : 0 ≤ lam) {x y : ℕ → ℝ}
    (h0 : x 0 = y 0) (hstep : ∀ L, |x (L + 1) - y (L + 1)| ≤ lam * |x L - y L| + e) (L : ℕ) :
    |x L - y L| ≤ errAfter lam e L := by
  induction L with
  | zero => simp [h0]
  | succ L ih =>
      calc |x (L + 1) - y (L + 1)| ≤ lam * |x L - y L| + e := hstep L
        _ ≤ lam * errAfter lam e L + e := by
            have := mul_le_mul_of_nonneg_left ih hlam
            linarith
        _ = errAfter lam e (L + 1) := rfl

/-- **Closed form.**  Depth contributes exactly the geometric factor `Σ_{i<L} λ^i`. -/
theorem errAfter_eq_geom (lam e : ℝ) (L : ℕ) :
    errAfter lam e L = e * ∑ i ∈ Finset.range L, lam ^ i := by
  induction L with
  | zero => simp
  | succ L ih =>
      rw [errAfter_succ, ih, geom_sum_succ]
      ring

/-- **Depth preserves the response exponent.**  Composing a power-law response of exponent
`γ` over `L` layers of gain `λ` yields a power-law response of *the same* exponent `γ`,
whose prefactor is multiplied by the geometric depth factor.  Depth moves the constant,
never the slope — so it cannot sharpen a cliff. -/
theorem depth_preserves_response_exponent (lam c R : ℝ) (γ b L : ℕ) :
    errAfter lam (powerDist c γ R b) L
      = powerDist (c * ∑ i ∈ Finset.range L, lam ^ i) γ R b := by
  rw [errAfter_eq_geom]
  unfold powerDist
  ring

/-- **Depth cannot rescue a low response exponent.**  Whatever the depth `L` and the
per-layer gain `λ`, a depth-composed power-law key response that fits both NET-94 arms
still has exponent `γ ≥ 5`.  The conjecture that stacking layers explains the cliff is
therefore false: the cycle-2 bound is depth invariant. -/
theorem depth_cannot_rescue_low_exponent {lam c R : ℝ} {γ L : ℕ}
    (h8 : errAfter lam (powerDist c γ R 8) L ≤ 0.00142)
    (h5 : 8.67694 ≤ errAfter lam (powerDist c γ R 5) L) : 5 ≤ γ := by
  rw [depth_preserves_response_exponent] at h8 h5
  exact net94_forces_quintic_key_response h8 h5

/-- The value side is depth stable in the same way, and remains exponent `1`: a stack of
`1`-Lipschitz value paths accumulates at most `L` copies of the per-layer budget, which is
linear in depth and linear in the quantiser step — never a cliff. -/
theorem value_depth_is_linear (e : ℝ) (L : ℕ) : errAfter 1 e L = L * e := by
  rw [errAfter_eq_geom]
  simp [mul_comm]

end Catalog.Algebra.KVCache