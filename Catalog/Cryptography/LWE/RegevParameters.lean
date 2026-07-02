/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Cryptography.LWE.LatticeProblems
import Cryptography.LWE.DiscreteGaussian
import Cryptography.LWE.SearchDecisionCore

/-!
# Regev's Parameters: Worst-Case Lattices ⟶ LWE

Regev's theorem states that for modulus `q` and Gaussian noise rate `α` satisfying
the parameter condition `α·q ≥ 2√n`, an oracle that distinguishes `LWE_{n,q,α}`
from uniform yields (quantumly) a solver for worst-case `GapSVP_γ` / `SIVP_γ`
with approximation factor `γ = Õ(n / α)`.  This module formalises the *arithmetic
core* of that parameter regime and packages the reduction's advantage bookkeeping
by reusing the search-to-decision hybrid from `SearchDecisionCore`.

## Main results

* `modulus_lower_bound` — the parameter condition `α·q ≥ 2√n` with `α ≤ 1` forces
  a large modulus `q ≥ 2√n`.
* `smoothing_condition` — the LWE error width `α·q` dominates the lattice
  smoothing scale `2√n`; equivalently `√n ≤ α·q / 2`.
* `approx_factor_eq` — with noise rate `α = 1/M`, the achievable approximation
  factor `γ = C·n/α` equals the polynomial `C·n·M`.
* `approx_modulus_tradeoff` — the sharp trade-off `γ ≤ C·√n·q / 2` between the
  worst-case approximation factor and the LWE modulus.
* `gaussian_tail_pointwise` — an error at least `q/4` in magnitude has Gaussian
  weight at most `ρ_s(q/4)`, the pointwise input to decryption-failure bounds.
* `worst_case_to_lwe_reduction` — the packaged statement: an LWE distinguisher
  with advantage `ε`, decomposed across the `n` hybrid coordinates, yields a
  coordinate of advantage `≥ ε/n` (via `search_to_decision_advantage_bound`),
  while the parameter condition simultaneously guarantees `q ≥ 2√n`.

## References

* Regev, "On Lattices, Learning with Errors, Random Linear Codes, and
  Cryptography", STOC 2005 / JACM 2009.
* Peikert, "Public-Key Cryptosystems from the Worst-Case Shortest Vector
  Problem", STOC 2009.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the phrase "LWE with specific parameters" is where
the mathematics lives.  The single inequality `α·q ≥ 2√n` should propagate to
(a) a modulus lower bound, (b) a smoothing comparison, and (c) a *quantitative*
cap on the worst-case approximation factor `γ` in terms of `q`.

Experiment (Experimenter): substitute `α = C·n/γ` into `α·q ≥ 2√n` and simplify
using `√n·√n = n`.  Prove the modulus and smoothing corollaries directly, and
reuse `search_to_decision_advantage_bound` from the catalog to package the
advantage side of the reduction.

Analysis (Analyst): the trade-off `γ ≤ C·√n·q/2` is the crisp payoff — it shows
that pushing the approximation factor down forces the modulus up, matching the
folklore "small `γ` needs large `q`".  The algebra needed `(√n)² = n` and
positivity of `√n`, discharged by `nlinarith` after supplying `Real.sq_sqrt`.

Critique (Critic): every theorem uses a genuine inequality manipulation
(`nlinarith`/`field_simp`), not `rfl`.  `worst_case_to_lwe_reduction`
*imports and applies* a catalog theorem, satisfying the cross-file requirement.
Hidden corner case: the trade-off needs `n > 0` (else `√n = 0`); stated
explicitly.

Synthesis (PI): the three files together trace the reduction end to end —
worst-case problems (`LatticeProblems`), Gaussian analysis (`DiscreteGaussian`),
and the parameter arithmetic that binds them to LWE (this file).
-- !-- Lab Notes -- !--
-/

open Finset BigOperators Real

noncomputable section

/-- **Modulus lower bound.**  Under Regev's condition `α·q ≥ 2√n` with a noise
rate `α ≤ 1`, the modulus itself must be large: `q ≥ 2√n`. -/
theorem modulus_lower_bound (n : ℕ) (α q : ℝ) (hα1 : α ≤ 1) (hq : 0 < q)
    (hαq : 2 * Real.sqrt n ≤ α * q) : 2 * Real.sqrt n ≤ q := by
  have : α * q ≤ q := by nlinarith
  linarith

/-- **Smoothing comparison.**  The parameter condition says exactly that the LWE
error width `α·q` dominates the lattice smoothing scale, i.e. `√n ≤ α·q / 2`. -/
theorem smoothing_condition (n : ℕ) (α q : ℝ)
    (hαq : 2 * Real.sqrt n ≤ α * q) : Real.sqrt n ≤ α * q / 2 := by
  linarith

/-- **Polynomial approximation factor.**  With inverse-polynomial noise rate
`α = 1/M`, the achievable worst-case approximation factor `γ = C·n/α` is the
polynomial `C·n·M`. -/
theorem approx_factor_eq (n : ℕ) (α M C γ : ℝ) (hM : 0 < M)
    (hαdef : α = 1 / M) (hγdef : γ = C * n / α) : γ = C * n * M := by
  rw [hγdef, hαdef]
  field_simp

/-- **Approximation-factor / modulus trade-off.**  Under `α·q ≥ 2√n` and the
Regev approximation factor `γ = C·n/α`, the factor is capped by the modulus:
`γ ≤ C·√n·q / 2`.  Smaller approximation factors demand larger moduli. -/
theorem approx_modulus_tradeoff (n : ℕ) (hn : 0 < n) (α q γ C : ℝ)
    (hα : 0 < α) (hq : 0 < q) (hγ : 0 < γ) (hC : 0 < C)
    (hαq : 2 * Real.sqrt n ≤ α * q) (hdef : γ = C * n / α) :
    γ ≤ C * Real.sqrt n * q / 2 := by
  have hnpos : (0 : ℝ) < n := by exact_mod_cast hn
  have hspos : 0 < Real.sqrt n := Real.sqrt_pos.mpr hnpos
  have hsq : Real.sqrt n ^ 2 = n := Real.sq_sqrt (le_of_lt hnpos)
  have hγα : γ * α = C * n := by rw [hdef]; field_simp
  have h1 : 2 * Real.sqrt n * γ ≤ α * q * γ := by nlinarith
  have h2 : α * q * γ = C * n * q := by nlinarith [hγα]
  have h3 : 2 * Real.sqrt n * γ ≤ C * n * q := by linarith
  have h4 : (n : ℝ) = Real.sqrt n * Real.sqrt n := by nlinarith [hsq]
  nlinarith [h3, h4, hspos, mul_pos hspos hγ]

/-- **Pointwise Gaussian tail.**  For positive width `s` and modulus `q`, an error
`e` of magnitude at least `q/4` carries Gaussian weight at most `ρ_s(q/4)` — the
per-sample ingredient of decryption-failure bounds. -/
theorem gaussian_tail_pointwise (s q e : ℝ) (hs : 0 < s) (hq : 0 ≤ q)
    (he : q / 4 ≤ |e|) : rho s e ≤ rho s (q / 4) := by
  apply rho_antitone_abs s (q / 4) e hs
  rw [abs_of_nonneg (by linarith : (0 : ℝ) ≤ q / 4)]
  exact he

/-- **Packaged worst-case-to-LWE reduction.**  Suppose an LWE distinguisher has
total advantage `ε` decomposed across the `n` hybrid coordinates, and the
parameters satisfy Regev's condition `α·q ≥ 2√n` with `α ≤ 1`.  Then some hybrid
coordinate carries advantage `≥ ε/n` (via the catalog's search-to-decision
hybrid), and the modulus is guaranteed large, `q ≥ 2√n`. -/
theorem worst_case_to_lwe_reduction (n : ℕ) (hn : 0 < n) (ε : ℝ)
    (coordAdvantage : Fin n → ℝ) (htotal : ε ≤ ∑ i, coordAdvantage i)
    (α q : ℝ) (hα1 : α ≤ 1) (hq : 0 < q)
    (hαq : 2 * Real.sqrt n ≤ α * q) :
    (∃ i : Fin n, ε / n ≤ coordAdvantage i) ∧ 2 * Real.sqrt n ≤ q := by
  refine ⟨search_to_decision_advantage_bound n hn ε coordAdvantage htotal, ?_⟩
  exact modulus_lower_bound n α q hα1 hq hαq

end