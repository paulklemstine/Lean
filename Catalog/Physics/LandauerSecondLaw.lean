import Mathlib
import Logic.JarzynskiLandauer

/-!
# Landauer's `kT log 2` Bound as a Second-Law Inequality from the Jarzynski Equality

**Catalog category (v19a menu): cross-domain bridge.**
This file bridges the *information-theoretic / logical* development in
`Logic.JarzynskiLandauer` (Shannon entropy of a bit, logical irreversibility of
erasure, the finite Jarzynski *identity*) with the *thermodynamic* statement of
Landauer's principle as a genuine lower bound on dissipated work.

The catalog file `Logic.JarzynskiLandauer` proves the finite-size Landauer
*identity* `E[W] = ΔF + α⁻¹ · log E[exp(-α (W - E[W]))]`: it pins the mean work to
the free-energy difference *plus* an exact fluctuation correction, but says nothing
about the **sign** of that correction. The physical content of the second law — and
of Landauer's principle — is precisely that this correction is *nonnegative*, so that

> the mean dissipated work to erase a bit is at least `ΔF = k·T·log 2`,

with equality only in the quasi-static limit (vanishing fluctuations).

We prove the sign via the elementary inequality `1 + x ≤ exp x` (no convexity API,
no Jensen machinery): the centred work fluctuation has mean zero, so
`E[exp(-α (W - E[W]))] ≥ 1`, hence its logarithm is `≥ 0`.

## Main results

* `expect_add_one_le_expect_exp` — finite Jensen-type bound `1 + E[g] ≤ E[exp g]`.
* `expect_centered_zero` — the centred work `-α (W - E[W])` has expectation `0`.
* `work_fluctuation_ge_one` — `E[exp(-α (W - E[W]))] ≥ 1` (the Jarzynski correction).
* `work_correction_nonneg` — the fluctuation correction `log E[...] ≥ 0`.
* `jarzynski_second_law` — **second law**: `ΔF ≤ E[W]` for `α > 0`.
* `landauer_kT_bound` — **Landauer's principle**: `k·T·log 2 ≤ E[W]` for one-bit erasure.
* `landauer_cost_eq_entropy_loss` — the cost `k·T·log 2` equals `k·T` times the
  information-theoretic entropy loss `H(uniform) − H(erased)` (the bridge identity).
* `logical_to_thermodynamic_irreversibility` — logical irreversibility (the erasure
  map is non-injective) forces thermodynamic irreversibility (`0 < E[W]`).

## References
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Jarzynski, C. (1997). Nonequilibrium equality for free energy differences.
- Bennett, C.H. (1982). The thermodynamics of computation — a review.
-/

noncomputable section

open BigOperators Real
open JarzynskiLandauer

namespace LandauerSecondLaw

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The catalog already had the finite Landauer *identity*
--   E[W] = ΔF + α⁻¹ log E[exp(-α(W-E[W]))], but not the *inequality* E[W] ≥ ΔF. We
--   conjectured that the Jarzynski correction term is always nonnegative for α > 0,
--   upgrading the identity to Landauer's principle E[W] ≥ kT log 2, with equality iff
--   the work has zero fluctuations (quasi-static limit).
-- Experiment (Experimenter): Two routes to E[exp Y] ≥ 1 for a mean-zero Y. Route 1:
--   convexity of exp + Jensen (ConvexOn.map_sum_le). Route 2: the pointwise bound
--   1 + x ≤ exp x. Route 2 won — it needs only Finset.sum_le_sum and Real.add_one_le_exp,
--   avoiding the convexity-API friction that sank Route 1 in `LandauerLowerBound`.
-- Analysis (Analyst): The whole second law collapses to: a mean-zero perturbation can
--   only *raise* an expectation of a convex observable. The "Jarzynski correction" of the
--   catalog identity is exactly that nonnegative gap; it is the thermodynamic-irreversibility
--   surcharge on top of the reversible free-energy cost ΔF.
-- Critique (Critic): Need α > 0 strictly (β = 1/kT > 0); with α = 0 the bound is vacuous.
--   Need k,T > 0 for the strict version. The bound is an *inequality*, not the trivial
--   identity — it genuinely uses add_one_le_exp (an insight-bearing analytic fact), not
--   simp/decide. The bridge identity ties kT log 2 back to the Shannon entropy loss proved
--   in `Logic.JarzynskiLandauer`, so this extends (does not re-prove) the catalog.
-- Synthesis (PI): A self-contained second-law layer over the existing Jarzynski identity,
--   culminating in logical ⇒ thermodynamic irreversibility for one-bit erasure.
-- !-- end Lab Notes -- !--

variable {Ω : Type*} [Fintype Ω]

/-- **Finite Jensen-type bound for the exponential.** For any probability mass
function `p` and observable `g`, `1 + E[g] ≤ E[exp g]`. This is the discrete content
of convexity of `exp`, proved here pointwise from `1 + x ≤ exp x`. -/
theorem expect_add_one_le_expect_exp (p : Ω → ℝ) (hp : IsPMF p) (g : Ω → ℝ) :
    1 + expect p g ≤ expect p (fun ω => Real.exp (g ω)) := by
  have hrw : 1 + expect p g = ∑ ω, p ω * (1 + g ω) := by
    simp only [expect, mul_add, mul_one, Finset.sum_add_distrib, hp.2]
  rw [hrw]
  apply Finset.sum_le_sum
  intro ω _
  apply mul_le_mul_of_nonneg_left _ (hp.1 ω)
  linarith [Real.add_one_le_exp (g ω)]

/-- The centred work fluctuation `-α (W - E[W])` has expectation `0`. -/
theorem expect_centered_zero (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (α : ℝ) :
    expect p (fun ω => -α * (W ω - expect p W)) = 0 := by
  simp only [expect, mul_sub]
  rw [Finset.sum_sub_distrib]
  have h1 : ∑ ω, p ω * (-α * W ω) = -α * ∑ ω, p ω * W ω := by
    rw [Finset.mul_sum]; exact Finset.sum_congr rfl (fun ω _ => by ring)
  have h2 : ∑ ω, p ω * (-α * ∑ ω, p ω * W ω) = -α * ∑ ω, p ω * W ω := by
    rw [← Finset.sum_mul, hp.2]; ring
  rw [h1, h2]; ring

/-- **The Jarzynski work-fluctuation factor is at least one.** -/
theorem work_fluctuation_ge_one (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (α : ℝ) :
    1 ≤ expect p (fun ω => Real.exp (-α * (W ω - expect p W))) := by
  have h := expect_add_one_le_expect_exp p hp (fun ω => -α * (W ω - expect p W))
  rw [expect_centered_zero p hp W α] at h
  linarith

/-- **The Jarzynski fluctuation correction is nonnegative.** -/
theorem work_correction_nonneg (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (α : ℝ) :
    0 ≤ Real.log (expect p (fun ω => Real.exp (-α * (W ω - expect p W)))) :=
  Real.log_nonneg (work_fluctuation_ge_one p hp W α)

/-- **Second law from the Jarzynski equality.** For inverse temperature `α > 0`, the
mean work is at least the free-energy difference: `ΔF ≤ E[W]`. The gap is the
nonnegative Jarzynski fluctuation correction; it vanishes exactly in the quasi-static
(zero-fluctuation) limit. -/
theorem jarzynski_second_law (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (α ΔF : ℝ)
    (hα : 0 < α) (hJ : JarzynskiCondition p W α ΔF) :
    ΔF ≤ expect p W := by
  rw [jarzynski_correction p W α ΔF (ne_of_gt hα) hJ]
  have hlog := work_correction_nonneg p hp W α
  have hinv : 0 ≤ α⁻¹ := le_of_lt (inv_pos.2 hα)
  nlinarith [mul_nonneg hinv hlog]

/-- **Landauer's principle as a `kT log 2` lower bound.** For a one-bit memory at
positive temperature `T` and Boltzmann constant `k`, with inverse temperature
`α = (kT)⁻¹` and free-energy cost `ΔF = k·T·log 2`, the mean dissipated work to erase
the bit is at least `k·T·log 2`. -/
theorem landauer_kT_bound (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ) (k T : ℝ)
    (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) :
    k * T * Real.log 2 ≤ expect p W :=
  jarzynski_second_law p hp W (k * T)⁻¹ (k * T * Real.log 2)
    (inv_pos.2 (mul_pos hk hT)) hJ

/-- **Bridge identity.** The Landauer free-energy cost `k·T·log 2` is exactly `k·T`
times the information-theoretic entropy loss `H(uniform) − H(erased)` computed in
`Logic.JarzynskiLandauer`. This is what ties the thermodynamic bound above to the
logical act of erasure. -/
theorem landauer_cost_eq_entropy_loss (k T : ℝ) :
    k * T * Real.log 2 =
      k * T * (shannonEntropy uniformBool - shannonEntropy erasedBool) := by
  rw [entropy_loss]

/-- **Logical irreversibility forces thermodynamic irreversibility.** The erasure map
`Bool → Bool` is not injective (logical irreversibility), and consequently any physical
process realising one-bit erasure subject to the Jarzynski equality dissipates a
*strictly positive* mean work (thermodynamic irreversibility). -/
theorem logical_to_thermodynamic_irreversibility (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) :
    ¬ Function.Injective erasure ∧ 0 < expect p W := by
  refine ⟨erasure_not_injective, ?_⟩
  have hbound := landauer_kT_bound p hp W k T hk hT hJ
  have hpos : 0 < k * T * Real.log 2 := by
    have h2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
    positivity
  linarith

end LandauerSecondLaw

end