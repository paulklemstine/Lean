import Mathlib
import Logic.JarzynskiLandauer
import Physics.LandauerSecondLaw

/-!
# Finite-Size Fluctuation Theorem: Second-Law Violations are Exponentially Rare

**Catalog category (v19a menu): cross-domain bridge.**
This file bridges *finite probability theory* (a Markov/Chernoff tail bound) with the
*thermodynamic* Landauer / second-law development built in `Logic.JarzynskiLandauer`
and `Physics.LandauerSecondLaw`.

`Physics.LandauerSecondLaw` proved the **average** statement of the second law,
`ΔF ≤ E[W]`, and `Physics.LandauerSaturation` characterised its equality case. Neither
controls the *fluctuations*: a genuinely stochastic erasure has individual realisations
whose work `W ω` dips *below* the free-energy bound `ΔF`. The physically sharp
finite-size statement — the integral fluctuation theorem in its Markov-inequality form —
is that such "second-law violations" are **exponentially suppressed**:

> the total probability that the dissipated work is below `ΔF` by a margin `ξ`
> is at most `exp(-α ξ)`,

where `α = (kT)⁻¹` is the inverse temperature. This is a strict refinement of the
average bound: it recovers `ΔF ≤ E[W]` on average yet quantifies the rare events that
locally beat Landauer's limit.

## Main results

* `second_law_violation_bound` — `P(W < ΔF - ξ) ≤ exp(-α ξ)` from the Jarzynski equality.
* `second_law_no_violation_below` — for `ξ ≥ 0` the violation probability is `< 1`
  whenever some outcome lies on/above the bound (the bound cannot be violated with
  certainty).
* `landauer_violation_bound` — specialisation to one-bit erasure: the probability that
  the erasure work falls `ξ` below `k·T·log 2` is at most `exp(-ξ / (kT))`.
* `landauer_violation_decays` — monotone exponential decay of the Landauer violation
  probability bound as the margin `ξ` grows.

## References
- Jarzynski, C. (1997). Nonequilibrium equality for free energy differences.
- Jarzynski, C. (2011). Equalities and inequalities: irreversibility and the second law
  of thermodynamics at the nanoscale.
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
-/

noncomputable section

open BigOperators Real Finset
open JarzynskiLandauer

namespace LandauerFluctuationBound

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The catalog had only the *average* second law ΔF ≤ E[W] and
--   its equality case. We conjectured a far stronger finite-size statement: the Jarzynski
--   equality forces the *distribution* of work to concentrate above ΔF, so that the
--   probability of a second-law violation of size ξ decays like exp(-αξ). Bold corollary:
--   no genuine erasure can beat Landauer's bound with certainty; violations are exponentially
--   rare in units of kT.
-- Experiment (Experimenter): The key realisation is that E[exp(-αW)] = exp(-αΔF) is exactly
--   a moment generating function identity, so a one-line finite Markov inequality applies.
--   On the violation set S = {W < ΔF - ξ} we have exp(-αW) > exp(-αΔF)·exp(αξ) pointwise;
--   summing p·exp(-αW) over S, bounding below by the constant, and comparing to the full
--   sum exp(-αΔF) (Finset.sum_le_sum_of_subset_of_nonneg) gives the bound after dividing by
--   the positive constant exp(-αΔF). No measure theory needed — pure finite sums.
-- Analysis (Analyst): This is the integral fluctuation theorem ⟨exp(-α(W-ΔF))⟩ = 1 read as
--   a Chernoff tail bound. The average law ΔF ≤ E[W] is the ξ→ first-moment shadow of this
--   distributional statement; the new content is the exponential SUPPRESSION, the genuinely
--   finite-size / nanoscale correction the mission asks for.
-- Critique (Critic): Need α > 0 (β = 1/kT > 0) to divide by exp(-αΔF) > 0 with the right
--   inequality direction. The filter set needs classical decidability (open Classical). The
--   "< 1" corollary needs a witness outcome at/above the bound with positive probability, else
--   it could be vacuously 1. The proof genuinely uses exp monotonicity + a subset sum bound,
--   not simp/decide.
-- Synthesis (PI): A distributional fluctuation-theorem layer above the average second law,
--   quantifying nanoscale violations of Landauer's bound.
-- !-- end Lab Notes -- !--

open Classical

variable {Ω : Type*} [Fintype Ω]

/-
**Exponential bound on second-law violations (finite Jarzynski / Chernoff).**
Under the finite Jarzynski equality at inverse temperature `α > 0`, the total
probability that the dissipated work `W` falls below the free-energy difference `ΔF`
by a margin `ξ` is at most `exp(-α ξ)`.
-/
theorem second_law_violation_bound (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (α ΔF : ℝ) (hα : 0 < α) (hJ : JarzynskiCondition p W α ΔF) (ξ : ℝ) :
    ∑ ω ∈ univ.filter (fun ω => W ω < ΔF - ξ), p ω ≤ Real.exp (-α * ξ) := by
  -- Applying the Jarzynski condition to the set `S = univ.filter (fun ω => W ω < ΔF - ξ)`.
  have h_jarzynski_S : ∑ ω ∈ Finset.univ.filter (fun ω => W ω < ΔF - ξ), p ω * Real.exp (-α * W ω) ≤ Real.exp (-α * ΔF) := by
    exact hJ.le.trans' ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.filter_subset _ _ ) fun x _ _ => mul_nonneg ( hp.1 _ ) ( Real.exp_nonneg _ ) );
  -- Applying the inequality $p ω * \exp(-α * W ω) ≥ p ω * \exp(-α * (ΔF - ξ))$ for each $ω$ in the set $S$.
  have h_ineq : ∀ ω ∈ Finset.univ.filter (fun ω => W ω < ΔF - ξ), p ω * Real.exp (-α * W ω) ≥ p ω * Real.exp (-α * (ΔF - ξ)) := by
    exact fun ω hω => mul_le_mul_of_nonneg_left ( Real.exp_le_exp.mpr ( by nlinarith [ Finset.mem_filter.mp hω ] ) ) ( hp.1 ω );
  -- Combining the inequalities from h_jarzynski_S and h_ineq, we get:
  have h_combined : (∑ ω ∈ Finset.univ.filter (fun ω => W ω < ΔF - ξ), p ω) * Real.exp (-α * (ΔF - ξ)) ≤ Real.exp (-α * ΔF) := by
    simpa only [ Finset.sum_mul _ _ _ ] using le_trans ( Finset.sum_le_sum h_ineq ) h_jarzynski_S;
  convert le_div_iff₀ ( Real.exp_pos _ ) |>.2 h_combined using 1
  rw [← Real.exp_sub]
  congr 1
  ring

/-
**No certain violation.** If `ξ ≥ 0` and some outcome `ω₀` has positive probability
and work at least `ΔF` (so it is *not* a violation), then the total violation
probability is strictly below `1`: Landauer's bound can never be violated with
certainty.
-/
theorem second_law_no_violation_below (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (ΔF : ℝ) {ξ : ℝ} (hξ : 0 ≤ ξ) {ω₀ : Ω} (hpω₀ : 0 < p ω₀) (hWω₀ : ΔF ≤ W ω₀) :
    ∑ ω ∈ univ.filter (fun ω => W ω < ΔF - ξ), p ω < 1 := by
  refine' lt_of_le_of_lt ( Finset.sum_le_sum_of_subset_of_nonneg ( show ( Finset.univ.filter fun ω => W ω < ΔF - ξ ) ⊆ Finset.univ.erase ω₀ from fun ω hω => _ ) fun _ _ _ => hp.1 _ ) _;
  · grind;
  · rw [ ← hp.2, ← Finset.sum_erase_add _ _ ( Finset.mem_univ ω₀ ), add_comm ] ; linarith

/-- **Landauer second-law violation bound.** For one-bit erasure at temperature `T`
and Boltzmann constant `k`, with inverse temperature `α = (kT)⁻¹` and free-energy cost
`ΔF = k·T·log 2`, the probability that the erasure work falls below `k·T·log 2` by a
margin `ξ` is at most `exp(-ξ / (kT))`. -/
theorem landauer_violation_bound (p : Ω → ℝ) (hp : IsPMF p) (W : Ω → ℝ)
    (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    (hJ : JarzynskiCondition p W (k * T)⁻¹ (k * T * Real.log 2)) (ξ : ℝ) :
    ∑ ω ∈ univ.filter (fun ω => W ω < k * T * Real.log 2 - ξ), p ω
      ≤ Real.exp (-(k * T)⁻¹ * ξ) :=
  second_law_violation_bound p hp W (k * T)⁻¹ (k * T * Real.log 2)
    (inv_pos.2 (mul_pos hk hT)) hJ ξ

/-
**Monotone exponential decay of the violation bound.** As the violation margin `ξ`
increases, the Landauer violation-probability bound `exp(-ξ/(kT))` strictly decreases:
larger violations of Landauer's bound are exponentially rarer.
-/
theorem landauer_violation_decays (k T : ℝ) (hk : 0 < k) (hT : 0 < T)
    {ξ₁ ξ₂ : ℝ} (h : ξ₁ < ξ₂) :
    Real.exp (-(k * T)⁻¹ * ξ₂) < Real.exp (-(k * T)⁻¹ * ξ₁) := by
  exact Real.exp_lt_exp.mpr ( by nlinarith [ inv_pos.mpr ( mul_pos hk hT ) ] )

end LandauerFluctuationBound

end