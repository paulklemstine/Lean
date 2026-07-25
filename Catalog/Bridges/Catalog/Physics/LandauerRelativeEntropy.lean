import Mathlib
import Logic.JarzynskiLandauer

/-!
# Landauer's Cost as a Relative Entropy: Gibbs' Inequality and the Erasure Bridge

**Catalog category: cross-domain bridge (extends the Landauer development).**

`Logic.JarzynskiLandauer` measured the cost of erasure through the *Shannon entropy
loss* `H(uniform) − H(erased) = log 2`. This file re-derives Landauer's cost from a
second, dual, information-theoretic quantity: the **Kullback–Leibler divergence
(relative entropy)** `D(p‖q) = Σ p log(p/q)`.

We prove **Gibbs' inequality** `D(p‖q) ≥ 0` from first principles (via the elementary
bound `log x ≤ x − 1`), and show two facts that make it the natural home for
Landauer's principle:

* the relative entropy of an *erased* bit against the *uniform* reference is exactly
  `log 2`, so the Landauer free-energy cost is `k·T·D(erased‖uniform)`; and
* this relative entropy *equals* the Shannon entropy loss of
  `Logic.JarzynskiLandauer`, unifying the two accounts of the cost.

Thermodynamically, `k·T·D(p‖q)` is the (nonnegative) extra free energy of a state `p`
relative to the equilibrium reference `q` — the minimal work to prepare/erase it.

## Main results

* `relativeEntropy_self` — `D(p‖p) = 0`.
* `relativeEntropy_nonneg` — **Gibbs' inequality** `D(p‖q) ≥ 0` for PMFs with `q > 0`.
* `relativeEntropy_erased_uniform` — `D(erased‖uniform) = log 2`.
* `relativeEntropy_eq_entropy_loss` — relative entropy = Shannon entropy loss.
* `landauer_cost_eq_relative_entropy` — `k·T·log 2 = k·T·D(erased‖uniform)`.
* `landauer_work_nonneg_via_gibbs` — the relative-entropy work `k·T·D(p‖q) ≥ 0`.

## References
- Kullback, S. & Leibler, R.A. (1951). On information and sufficiency.
- Landauer, R. (1961). Irreversibility and heat generation in the computing process.
- Esposito, M. & Van den Broeck, C. (2011). Second law and Landauer principle far from
  equilibrium (relative-entropy formulation).
-/

noncomputable section

open BigOperators Real Finset
open JarzynskiLandauer

namespace LandauerRelativeEntropy

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): The catalog measured erasure cost via Shannon entropy LOSS.
--   We conjectured the SAME cost kT log 2 is captured by a different functional — the KL
--   divergence D(erased‖uniform) — and that the two numbers coincide. Surprising angle:
--   relative entropy is asymmetric and ostensibly unrelated to a single-distribution
--   entropy difference, yet for the uniform reference they agree exactly.
-- Experiment (Experimenter): Proved Gibbs' inequality D(p‖q) ≥ 0 by the pointwise bound
--   p log(p/q) ≥ p - q (from Real.log_le_sub_one_of_pos applied to q/p), summing to
--   ∑(p-q) = 0. Computed D(erased‖uniform) = 1·log 2 + 0 = log 2 (ComputationalEvidence.md).
-- Analysis (Analyst): The p ω factor in p log(p/q) makes the 0·log 0 convention automatic
--   (no special-casing): zero-probability outcomes contribute zero. Gibbs reduces to a
--   convexity fact dressed as log x ≤ x-1; the heavy KL machinery is unnecessary.
-- Critique (Critic): Need q ω > 0 (reference has full support) else D = +∞ informally / the
--   bound breaks. Self-divergence D(p‖p)=0 holds unconditionally (log(p/p)=0 or factor 0).
--   The bridge to entropy_loss is a genuine identity, not a renaming: it equates two
--   different sums and ties back to Logic.JarzynskiLandauer.entropy_loss.
-- Synthesis (PI): A relative-entropy account of Landauer's cost, dual to the entropy-loss
--   account, with Gibbs' inequality as the nonnegativity backbone.
-- !-- end Lab Notes -- !--

variable {Ω : Type*} [Fintype Ω]

/-- **Relative entropy (Kullback–Leibler divergence)** of `p` with respect to `q`.
The factor `p ω` makes the convention `0 · log 0 = 0` automatic. -/
def relativeEntropy (p q : Ω → ℝ) : ℝ := ∑ ω, p ω * Real.log (p ω / q ω)

/-
The relative entropy of a distribution against itself is zero.
-/
theorem relativeEntropy_self (p : Ω → ℝ) : relativeEntropy p p = 0 := by
  exact Finset.sum_eq_zero fun ω _ => by by_cases h : p ω = 0 <;> simp +decide [ h ] ;

/-
**Gibbs' inequality.** For probability mass functions `p` and `q` with `q`
strictly positive, the relative entropy is nonnegative.
-/
theorem relativeEntropy_nonneg (p q : Ω → ℝ) (hp : IsPMF p) (hq : IsPMF q)
    (hqpos : ∀ ω, 0 < q ω) :
    0 ≤ relativeEntropy p q := by
  -- By the properties of logarithms and the inequality $\log(x) \leq x - 1$, we have $p \log(p/q) \geq p - q$.
  have h_ineq : ∀ ω, p ω * Real.log (p ω / q ω) ≥ p ω - q ω := by
    intro ω; by_cases h : p ω = 0 <;> simp_all +decide [ div_eq_inv_mul ] ;
    · linarith [ hqpos ω ];
    · have := Real.log_le_sub_one_of_pos ( div_pos ( hqpos ω ) ( lt_of_le_of_ne ( hp.1 ω ) ( Ne.symm h ) ) );
      rw [ show ( q ω ) ⁻¹ * p ω = ( q ω / p ω ) ⁻¹ by group, Real.log_inv ] ; nlinarith [ hp.1 ω, hqpos ω, mul_div_cancel₀ ( q ω ) h ] ;
  exact le_trans ( by rw [ Finset.sum_sub_distrib, hp.2, hq.2, sub_self ] ) ( Finset.sum_le_sum fun ω _ => h_ineq ω )

/-
The relative entropy of a fully erased bit against the uniform reference is `log 2`.
-/
theorem relativeEntropy_erased_uniform :
    relativeEntropy erasedBool uniformBool = Real.log 2 := by
  -- By definition of relative entropy, we have:
  simp [relativeEntropy, erasedBool, uniformBool]

/-- **Bridge identity.** The relative entropy of the erased bit against the uniform
reference equals the Shannon entropy *loss* of erasure computed in
`Logic.JarzynskiLandauer`. -/
theorem relativeEntropy_eq_entropy_loss :
    relativeEntropy erasedBool uniformBool =
      shannonEntropy uniformBool - shannonEntropy erasedBool := by
  rw [relativeEntropy_erased_uniform, entropy_loss]

/-- **Landauer's cost as a relative entropy.** The Landauer free-energy cost
`k·T·log 2` of one-bit erasure equals `k·T` times the relative entropy of the erased
state against the uniform reference. -/
theorem landauer_cost_eq_relative_entropy (k T : ℝ) :
    k * T * Real.log 2 = k * T * relativeEntropy erasedBool uniformBool := by
  rw [relativeEntropy_erased_uniform]

/-- **Relative-entropy work is nonnegative.** For `k, T ≥ 0` and PMFs `p`, `q` with
positive reference `q`, the relative-entropy work `k·T·D(p‖q)` — the minimal free-energy
cost of preparing/erasing the state `p` against equilibrium `q` — is nonnegative. -/
theorem landauer_work_nonneg_via_gibbs (p q : Ω → ℝ) (hp : IsPMF p) (hq : IsPMF q)
    (hqpos : ∀ ω, 0 < q ω) (k T : ℝ) (hk : 0 ≤ k) (hT : 0 ≤ T) :
    0 ≤ k * T * relativeEntropy p q := by
  have hD := relativeEntropy_nonneg p q hp hq hqpos
  positivity

end LandauerRelativeEntropy

end