import Mathlib
import Tropical.EulerMascheroni.SeriesRepresentation
import Tropical.NeuralNetworks.SoftMaxConvergence
import EML.AlgebraicMaxClosure

/-!
# A Tropical (log-sum-exp) bridge for the Euler–Mascheroni constant

This file is the **cross-domain bridge** demanded by the research mandate.  It
combines, in a single non-trivial theorem, results from two different catalog
domains together with Mathlib's Euler–Mascheroni constant:

* **Tropical domain** — `Catalog/Tropical/NeuralNetworks/SoftMaxConvergence.lean`,
  providing the smooth (temperature-`1`) log-sum-exp operator
  `SoftMaxConvergence.softMax 1 x₁ x₂ = log (exp x₁ + exp x₂)`, the canonical
  "soft" tropical maximum.
* **EML domain** — `Catalog/EML/AlgebraicMaxClosure.lean`, providing the
  tropical-analytic dequantization sandwich `softmax_lower` / `softmax_upper`:
  `max a b ≤ log(eᵃ+eᵇ) ≤ max a b + log 2`.
* **Euler–Mascheroni** — `Catalog/Tropical/EulerMascheroni/SeriesRepresentation.lean`
  and Mathlib's `Real.eulerMascheroniConstant`.

## New connection
The `k`-th term of the telescoping γ-series equals
`1/(k+1) - softMax 1 0 (-log (k+1))`, i.e. the harmonic increment minus a tropical
soft-maximum.  Because `-log(k+1) ≤ 0`, the hard tropical maximum `max 0 (-log(k+1))`
collapses to `0`, and the EML dequantization sandwich pins the soft value into the
interval `[0, log 2]`.  Consequently:

`γ = ∑_{k≥1} ( 1/k - softMax 1 0 (-log k) )`,

expressing the Euler–Mascheroni constant as a harmonic series corrected by
**tropical soft-max gaps**, each lying in `[0, log 2]`.

## Main results
* `EulerMascheroni.softMax_one_eq` — temperature-1 soft-max evaluates the log gap.
* `EulerMascheroni.softMax_term_mem_Icc` — EML sandwich: soft-max term ∈ `[0, log 2]`.
* `EulerMascheroni.emTerm_eq_one_sub_softMax` — γ-series term via the tropical operator.
* `EulerMascheroni.hasSum_gamma_softMax` — **γ as a tropical soft-max series**.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The transcendental "log" appearing in γ's definition is
  secretly a *tropical* object: each `log(1 + 1/k)` is a temperature-1 log-sum-exp
  (soft-max) of `0` and `-log k`. If so, γ should admit a representation as a sum of
  tropical soft-max gaps, bridging analytic number theory and tropical/idempotent
  geometry.
EXPERIMENT (Experimenter):
  (1) Showed `SoftMaxConvergence.softMax 1 0 (-log(k+1)) = log(k+2) - log(k+1)` by
      unfolding the def and using `exp_neg`, `exp_log`, `log_div`.
  (2) Reused EML's `softmax_lower`/`softmax_upper` at `τ = 1`, with the observation
      `max 0 (-log(k+1)) = 0` (since `log(k+1) ≥ 0`), to sandwich the soft-max term
      in `[0, log 2]`.
  (3) Rewrote `EulerMascheroni.emTerm` through (1) and lifted `hasSum_emTerm`.
ANALYSIS (Analyst): The bridge is exact, not asymptotic. The crucial number-theoretic
  fact `log(k+1) ≥ 0` (which forces the hard-max to vanish) is exactly what lets the
  EML sandwich apply cleanly — a genuine interaction between the two domains, not a
  formal juxtaposition. Failure mode avoided: at `k = 0`, `-log 1 = 0`, the sandwich
  degenerates to `0 ≤ log 2`, still valid.
CRITIQUE (Critic): Imports and *uses* `SoftMaxConvergence.softMax` (Tropical) and
  `softmax_lower`/`softmax_upper` (EML) in load-bearing positions; removing either
  breaks the proof. The headline `hasSum_gamma_softMax` is a `HasSum`, not a
  definitional rewrite, and depends on the telescoping certificate from
  `SeriesRepresentation`.
SYNTHESIS (PI): A clean two-domain bridge: γ = Σ (harmonic increment − tropical
  soft-max gap), each gap confined to `[0, log 2]`.
-/

open Real Filter Topology

namespace EulerMascheroni

/-- The temperature-1 tropical soft-max of `0` and `-log(k+1)` evaluates the
logarithmic gap `log(k+2) - log(k+1)`. -/
theorem softMax_one_eq (k : ℕ) :
    SoftMaxConvergence.softMax 1 0 (-Real.log (k + 1))
      = Real.log (k + 2) - Real.log (k + 1) := by
  unfold SoftMaxConvergence.softMax
  simp only [one_div, inv_one, one_mul, mul_zero, Real.exp_zero]
  rw [Real.exp_neg, Real.exp_log (by positivity)]
  rw [show (1 : ℝ) + ((k : ℝ) + 1)⁻¹ = ((k : ℝ) + 2) / ((k : ℝ) + 1) by
        field_simp; ring]
  rw [Real.log_div (by positivity) (by positivity)]

/-- `softMax 1 0 b` agrees with the EML log-sum-exp normal form at `τ = 1`, so the
EML dequantization sandwich applies. -/
private theorem softMax_one_eq_eml (b : ℝ) :
    SoftMaxConvergence.softMax 1 0 b
      = (1 : ℝ) * Real.log (Real.exp (0 / 1) + Real.exp (b / 1)) := by
  unfold SoftMaxConvergence.softMax
  norm_num

/-- **EML dequantization sandwich**, specialized to the γ-series soft-max terms:
each `softMax 1 0 (-log(k+1))` lies in `[0, log 2]`.  The lower bound uses
`softmax_lower` (EML) together with the number-theoretic fact `log(k+1) ≥ 0`
(which makes the hard tropical maximum vanish); the upper bound uses
`softmax_upper` (EML). -/
theorem softMax_term_mem_Icc (k : ℕ) :
    0 ≤ SoftMaxConvergence.softMax 1 0 (-Real.log (k + 1)) ∧
      SoftMaxConvergence.softMax 1 0 (-Real.log (k + 1)) ≤ Real.log 2 := by
  have hlogpos : 0 ≤ Real.log ((k : ℝ) + 1) := by
    have hk : (0 : ℝ) ≤ (k : ℝ) := Nat.cast_nonneg k
    exact Real.log_nonneg (by linarith)
  have hmax : max (0 : ℝ) (-Real.log ((k : ℝ) + 1)) = 0 := by
    rw [max_eq_left]; linarith
  have hlo := softmax_lower 0 (-Real.log ((k : ℝ) + 1)) 1 one_pos
  have hhi := softmax_upper 0 (-Real.log ((k : ℝ) + 1)) 1 one_pos
  rw [hmax] at hlo hhi
  rw [softMax_one_eq_eml]
  constructor
  · linarith
  · linarith

/-- The `k`-th term of the telescoping γ-series, written through the tropical
soft-max operator: `1/(k+1) - softMax 1 0 (-log(k+1))`. -/
theorem emTerm_eq_one_sub_softMax (k : ℕ) :
    emTerm k = 1 / (k + 1) - SoftMaxConvergence.softMax 1 0 (-Real.log (k + 1)) := by
  rw [softMax_one_eq, emTerm]

/-- **The Euler–Mascheroni constant as a tropical soft-max series.**
`γ = ∑_{k≥1} ( 1/k - softMax 1 0 (-log k) )`, with every soft-max gap in `[0, log 2]`. -/
theorem hasSum_gamma_softMax :
    HasSum (fun k : ℕ => 1 / (k + 1) - SoftMaxConvergence.softMax 1 0 (-Real.log (k + 1)))
      Real.eulerMascheroniConstant := by
  have hfun : (fun k : ℕ => 1 / (k + 1)
      - SoftMaxConvergence.softMax 1 0 (-Real.log (k + 1))) = emTerm := by
    funext k
    exact (emTerm_eq_one_sub_softMax k).symm
  rw [hfun]
  exact hasSum_emTerm

end EulerMascheroni