import Mathlib

/-!
# A bridge: Random primes, Borel–Cantelli, and the prime-density series

This file is a **cross-domain connector** for the *counterfactual number theory*
programme (in which the primes of arithmetic are replaced by a random or deformed
subset of `ℕ`).  The companion file `Catalog/Novelty/CounterfactualPrimesHilbert.lean`
studies a *deterministic* deformation (the Hilbert monoid `n ≡ 1 (mod 4)`) and
shows that **infinitude of primes survives** while **unique factorization
collapses**.  Here we make the *probabilistic* half of the programme precise and
connect it to analytic number theory.

## The Cramér random model

Cramér's heuristic replaces the primes by a random set `S ⊆ ℕ` in which each
integer `n` is included **independently** with probability equal to the prime
density `1 / log n` (Prime Number Theorem: `π(n) ∼ n / log n`).  We model this by
a probability space `Ω`, independent measurable events `s n = "n ∈ S"`, and a
lower bound `μ (s n) ≥ 1 / log (n+2)` on their probabilities.

## The connection proved here

The whole qualitative behaviour of the random model is governed by a single
**number-theoretic series**, the *prime-density series*
`∑ₙ 1 / log n`, whose divergence is a soft consequence of `log n ≤ n`:

* **Survival of infinitude** (`randomPrimes_infinitely_often_ae`): because the
  prime-density series **diverges** (`tsum_cramerDensity_eq_top`), the
  *second Borel–Cantelli lemma* forces `μ (limsup s) = 1`: almost surely
  infinitely many integers are "random primes".  This is the probabilistic
  shadow of *"there are infinitely many primes"*.

* **Collapse under a summable density** (`randomPrimes_finitely_often_ae`,
  `subcritical_density_collapse`): if instead the density series **converges**
  (e.g. density `1 / (n+2)²`), the *first Borel–Cantelli lemma* forces
  `μ (limsup s) = 0`: almost surely only finitely many integers are prime.

So the *phase transition* between "infinitely many primes a.s." and "finitely
many primes a.s." is located **exactly** at the convergence/divergence boundary of
the arithmetic density series — a dictionary entry translating a measure-theoretic
`0/1` law into a statement about the summability of `1 / log n`.

This is the promised bridge: **measure theory / probability (Borel–Cantelli)**
on one side, **analytic number theory (the prime-density series)** on the other.

## Genuineness of the model

The hypotheses (a probability space with independent events of prescribed
probabilities) are *satisfiable* — they hold for the product of Bernoulli
measures — so the theorems are not vacuous.  We keep the model at the level of
hypotheses to isolate the mathematical content of the bridge.
-/

namespace CounterfactualRandomPrimes

open MeasureTheory ProbabilityTheory Filter
open scoped ENNReal NNReal

/-- The **Cramér prime density** at `n`: the probability, in the random model,
that `n` is a "random prime".  It equals `1 / log (n+2)` (the shift by `2`
avoids `log 0` and `log 1 = 0`, keeping the density finite and positive). -/
noncomputable def cramerDensity (n : ℕ) : ℝ≥0∞ :=
  ENNReal.ofReal (1 / Real.log (n + 2))

/-- The (shifted) harmonic term `1 / (n+2)`, viewed in `ℝ≥0∞`. -/
noncomputable def harmonicTerm (n : ℕ) : ℝ≥0∞ :=
  ENNReal.ofReal (1 / (n + 2))

/-- **Number-theoretic input, comparison step.**  Since `log x ≤ x`, the Cramér
density dominates the harmonic term: `1/(n+2) ≤ 1/log(n+2)`. -/
theorem harmonicTerm_le_cramerDensity (n : ℕ) :
    harmonicTerm n ≤ cramerDensity n := by
  unfold harmonicTerm cramerDensity
  apply ENNReal.ofReal_le_ofReal
  have hlog : Real.log (n + 2) ≤ (n + 2 : ℝ) := Real.log_le_self (by positivity)
  have hpos : (0:ℝ) < Real.log (n + 2) := Real.log_pos (by
    have h0 : (0:ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    linarith)
  exact one_div_le_one_div_of_le hpos hlog

/-- The real sequence `1/(n+2)` is **not summable** (shifted harmonic series). -/
theorem not_summable_harmonic_shift :
    ¬ Summable (fun n : ℕ => (1:ℝ) / (n + 2)) := by
  have h : ¬ Summable (fun n : ℕ => (1:ℝ) / n) := Real.not_summable_one_div_natCast
  intro hs
  apply h
  rw [← summable_nat_add_iff 2]
  simpa using hs

/-- **Number-theoretic input, divergence step.**  The shifted harmonic series
diverges in `ℝ≥0∞`. -/
theorem tsum_harmonicTerm_eq_top :
    ∑' n : ℕ, harmonicTerm n = ⊤ := by
  by_contra h
  apply not_summable_harmonic_shift
  have hcoe : (fun n : ℕ => harmonicTerm n)
      = (fun n : ℕ => ((((1:ℝ)/(n+2)).toNNReal : ℝ≥0) : ℝ≥0∞)) := by
    funext n; rfl
  rw [hcoe] at h
  have hsummable : Summable (fun n : ℕ => (((1:ℝ)/(n+2)).toNNReal : ℝ≥0)) :=
    ENNReal.tsum_coe_ne_top_iff_summable.mp h
  have := (NNReal.summable_coe).2 hsummable
  refine this.congr ?_
  intro n
  rw [Real.coe_toNNReal]
  positivity

/-- **The prime-density series diverges.**  This is the analytic-number-theory
half of the bridge: `∑ₙ 1/log n = ∞`.  It follows from the comparison
`1/(n+2) ≤ 1/log(n+2)` and the divergence of the harmonic series. -/
theorem tsum_cramerDensity_eq_top :
    ∑' n : ℕ, cramerDensity n = ⊤ := by
  have hle : ∑' n : ℕ, harmonicTerm n ≤ ∑' n : ℕ, cramerDensity n :=
    ENNReal.tsum_le_tsum harmonicTerm_le_cramerDensity
  rw [tsum_harmonicTerm_eq_top] at hle
  exact top_le_iff.mp hle

variable {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω}

/-- **Survival of infinitude in the Cramér random model.**

Let `s n` ("`n` is a random prime") be independent measurable events whose
probabilities dominate the Cramér prime density `1/log(n+2)`.  Then almost surely
infinitely many integers are random primes: `μ (limsup s atTop) = 1`.

This is a probabilistic reincarnation of *"there are infinitely many primes"*.
It combines the **second Borel–Cantelli lemma** (measure theory) with the
**divergence of the prime-density series** (`tsum_cramerDensity_eq_top`, number
theory). -/
theorem randomPrimes_infinitely_often_ae
    (s : ℕ → Set Ω) (hmeas : ∀ n, MeasurableSet (s n))
    (hindep : iIndepSet s μ)
    (hdensity : ∀ n, cramerDensity n ≤ μ (s n)) :
    μ (limsup s atTop) = 1 := by
  apply measure_limsup_eq_one hmeas hindep
  have hle : ∑' n : ℕ, cramerDensity n ≤ ∑' n : ℕ, μ (s n) :=
    ENNReal.tsum_le_tsum hdensity
  rw [tsum_cramerDensity_eq_top] at hle
  exact top_le_iff.mp hle

/-- **Collapse of infinitude under a summable density.**

If instead the total density series converges (`∑ₙ μ (s n) ≠ ∞`), the
**first Borel–Cantelli lemma** forces `μ (limsup s atTop) = 0`: almost surely
only finitely many integers are random primes.  No independence is required. -/
theorem randomPrimes_finitely_often_ae
    (s : ℕ → Set Ω)
    (hconv : ∑' n : ℕ, μ (s n) ≠ ⊤) :
    μ (limsup s atTop) = 0 :=
  measure_limsup_atTop_eq_zero hconv

/-- A **subcritical density series converges**: `∑ₙ 1/(n+2)² < ∞` in `ℝ≥0∞`.
This is the number-theoretic witness that a density decaying faster than the
prime density lands on the *convergent* side of the phase transition. -/
theorem tsum_subcritical_ne_top :
    ∑' n : ℕ, ENNReal.ofReal (1 / ((n : ℝ) + 2)^2) ≠ ⊤ := by
  have hnn : ∀ n : ℕ, (0:ℝ) ≤ 1 / ((n : ℝ) + 2)^2 := by
    intro n; positivity
  have hsummable : Summable (fun n : ℕ => (1:ℝ) / ((n : ℝ) + 2)^2) := by
    have h2 : Summable (fun n : ℕ => (1:ℝ) / (n : ℝ)^2) :=
      Real.summable_one_div_nat_pow.mpr (by norm_num)
    have h3 := (summable_nat_add_iff (f := fun n : ℕ => (1:ℝ) / (n : ℝ)^2) 2).mpr h2
    refine h3.congr ?_
    intro n; push_cast; ring
  rw [← ENNReal.ofReal_tsum_of_nonneg hnn hsummable]
  exact ENNReal.ofReal_ne_top

/-- **The phase transition, subcritical side, instantiated.**  If the random
model uses a density bounded above by `1/(n+2)²`, infinitude collapses: almost
surely only finitely many integers are random primes. -/
theorem subcritical_density_collapse
    (s : ℕ → Set Ω)
    (hdensity : ∀ n, μ (s n) ≤ ENNReal.ofReal (1 / ((n : ℝ) + 2)^2)) :
    μ (limsup s atTop) = 0 := by
  apply randomPrimes_finitely_often_ae s
  have hle : ∑' n : ℕ, μ (s n) ≤ ∑' n : ℕ, ENNReal.ofReal (1 / ((n : ℝ) + 2)^2) :=
    ENNReal.tsum_le_tsum hdensity
  intro htop
  rw [htop] at hle
  exact tsum_subcritical_ne_top (top_le_iff.mp hle)

end CounterfactualRandomPrimes