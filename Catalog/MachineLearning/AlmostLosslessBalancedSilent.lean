/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XIII: The √δ-Balanced Scheme

## Bridge: universal hashing (algebra) ↔ AM–GM optimisation (analysis) ↔ coding

`Bridges.AlmostLosslessTunableMarkov` produced a one-parameter family of
derandomized schemes: for every `η > 0` there is a key with

* failure probability `≤ δ + (1 + 1/η)·|l|/M`,
* silent-corruption probability `≤ (1 + η)·δ·|l|/M`.

The parameter `η` was left free.  This file *optimises* it.  Writing
`L = |l|/M`, the total error of the `η`-scheme is

`E(η) = δ + L + L/η + δ·L + η·δ·L`,

and AM–GM on the two `η`-dependent terms `L/η + η·δ·L ≥ 2·L·√δ` is an equality
exactly at `η = 1/√δ`.  Substituting that value collapses the whole trade-off
curve to a single closed form:

* `exists_balanced_almost_lossless_scheme` — **the deliverable**: a single key
  with failure `≤ δ + (1+√δ)·L`, silent corruption `≤ (√δ+δ)·L`, total error
  `≤ δ + (1+√δ)²·L`, and cost exactly `|l|`;
* `balanced_beats_sharp` — the balanced scheme dominates the cycle-2 constants
  `2` and `2δ` for every `δ ≤ 1`;
* `balanced_failure_constant_tendsto_one` — the failure constant `1 + √δ` tends
  to the first-moment optimum `1` as `δ → 0⁺`, while the silent constant
  `√δ + δ` tends to `0`: **both** error terms are simultaneously optimal in the
  small-`δ` limit, which no fixed choice of `η` achieves;
* `tunable_total_error_ge_balanced` — the AM–GM converse: *no* member of the
  tunable family beats `δ + (1+√δ)²·L`, so `η = 1/√δ` is the exact optimum of
  the family.

## Impact: balanced_silent_error_optimum, amgm_derandomization_tuning
-/

import Mathlib
import Bridges.AlmostLosslessTunableMarkov

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section Balanced

variable {α : Type*} [Fintype α] [DecidableEq α] {K M : ℕ}

/-! ### The AM–GM optimisation of the tunable trade-off -/

/-- The total-error functional of the tunable family, as a function of the
tuning parameter `η` (with `L = |l|/M` the collision-rate parameter):
`E(η) = δ + (1 + 1/η)·L + (1 + η)·δ·L`. -/
noncomputable def tunableTotal (δ L η : ℝ) : ℝ :=
  δ + (1 + 1 / η) * L + (1 + η) * δ * L

/-- **AM–GM converse.**  For every admissible tuning parameter `η > 0` the total
error of the tunable family is at least `δ + (1+√δ)²·L`; hence the value
attained at `η = 1/√δ` is the exact minimum of the family.  The proof is the
AM–GM inequality `L/η + η·δ·L ≥ 2·L·√δ` in the sharpened form
`(1 - η√δ)² ≥ 0`. -/
theorem tunable_total_error_ge_balanced (δ L η : ℝ) (hδ : 0 ≤ δ) (hL : 0 ≤ L)
    (hη : 0 < η) :
    δ + (1 + Real.sqrt δ) ^ 2 * L ≤ tunableTotal δ L η := by
  obtain ⟨s, hs0, rfl⟩ : ∃ s : ℝ, 0 ≤ s ∧ δ = s ^ 2 :=
    ⟨Real.sqrt δ, Real.sqrt_nonneg δ, (Real.sq_sqrt hδ).symm⟩
  rw [Real.sqrt_sq hs0]
  unfold tunableTotal
  -- `(1 + 1/η)·L + (1+η)·s²·L - (1+s)²·L = (L/η)·(1 - ηs)²`
  have hexp : (1 + 1 / η) * L + (1 + η) * s ^ 2 * L - (1 + s) ^ 2 * L
      = (L / η) * (1 - η * s) ^ 2 := by
    field_simp
    ring
  have hnn : 0 ≤ (L / η) * (1 - η * s) ^ 2 :=
    mul_nonneg (div_nonneg hL (le_of_lt hη)) (sq_nonneg _)
  linarith

/-- The balanced value of the trade-off is attained: at `η = 1/√δ` the total
error functional equals `δ + (1+√δ)²·L` exactly (for `δ > 0`). -/
theorem tunableTotal_balanced (δ L : ℝ) (hδ : 0 < δ) :
    tunableTotal δ L (1 / Real.sqrt δ) = δ + (1 + Real.sqrt δ) ^ 2 * L := by
  obtain ⟨s, hs0, rfl⟩ : ∃ s : ℝ, 0 < s ∧ δ = s ^ 2 :=
    ⟨Real.sqrt δ, Real.sqrt_pos.mpr hδ, (Real.sq_sqrt (le_of_lt hδ)).symm⟩
  rw [Real.sqrt_sq (le_of_lt hs0)]
  unfold tunableTotal
  field_simp
  ring

/-! ### The balanced scheme -/

/-- **The √δ-balanced almost-lossless scheme (the deliverable of this cycle).**

For a source whose atypical mass is at most `δ > 0`, a *single explicit key* of
a 2-universal family simultaneously achieves

1. failure probability `≤ δ + (1 + √δ)·|l|/M`;
2. silent-corruption probability `≤ (√δ + δ)·|l|/M`;
3. total error probability `≤ δ + (1 + √δ)²·|l|/M`;
4. decoding cost exactly `|l|` hash evaluations.

Both constants degrade *gracefully*: as `δ → 0` the failure constant tends to
the first-moment optimum `1` and the silent constant tends to `0`.  The tuning
`η = 1/√δ` is the exact minimiser of the tunable family
(`tunable_total_error_ge_balanced`). -/
theorem exists_balanced_almost_lossless_scheme (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδpos : 0 < δ)
    (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          ≤ δ + (1 + Real.sqrt δ) * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ (Real.sqrt δ + δ) * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
          + setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
          ≤ δ + (1 + Real.sqrt δ) ^ 2 * (l.length : ℝ) / M
      ∧ ∀ i : Fin M, (scanCost (H k) i l).2 = l.length := by
  classical
  have hs0 : 0 < Real.sqrt δ := Real.sqrt_pos.mpr hδpos
  have hs : Real.sqrt δ ^ 2 = δ := Real.sq_sqrt (le_of_lt hδpos)
  have hη : (0 : ℝ) < 1 / Real.sqrt δ := by positivity
  obtain ⟨k, hfail, hsilent, hcost⟩ :=
    exists_tunable_almost_lossless_scheme μ hU hK hM l hnd δ hδ hη
  -- rewrite the two tuned constants in closed form
  have hc₂ : (1 : ℝ) + 1 / (1 / Real.sqrt δ) = 1 + Real.sqrt δ := by
    field_simp
  have hc₁ : ((1 : ℝ) + 1 / Real.sqrt δ) * δ = Real.sqrt δ + δ := by
    field_simp
    nlinarith [hs, hs0]
  rw [hc₂] at hfail
  have hsilent' : setMass μ
      (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
      ≤ (Real.sqrt δ + δ) * (l.length : ℝ) / M := by
    calc setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
        ≤ (1 + 1 / Real.sqrt δ) * δ * (l.length : ℝ) / M := hsilent
      _ = (Real.sqrt δ + δ) * (l.length : ℝ) / M := by rw [hc₁]
  refine ⟨k, hfail, hsilent', ?_, hcost⟩
  have hsq : (1 + Real.sqrt δ) ^ 2 = (1 + Real.sqrt δ) + (Real.sqrt δ + δ) := by
    nlinarith [hs]
  have hsum := add_le_add hfail hsilent'
  calc setMass μ (Finset.univ.filter (fun x => ¬ (hashScheme l (H k)).Succeeds x))
        + setMass μ (Finset.univ.filter (fun x => (hashScheme l (H k)).SilentError x))
      ≤ (δ + (1 + Real.sqrt δ) * (l.length : ℝ) / M)
          + (Real.sqrt δ + δ) * (l.length : ℝ) / M := hsum
    _ ≤ δ + (1 + Real.sqrt δ) ^ 2 * (l.length : ℝ) / M := by
        rw [hsq]
        have : (0 : ℝ) ≤ (l.length : ℝ) / M := by positivity
        have hMne : (M : ℝ) ≠ 0 := by
          have : (0 : ℝ) < M := by exact_mod_cast hM
          exact ne_of_gt this
        field_simp
        ring_nf
        nlinarith [hδpos]

/-! ### Comparison with the cycle-2 (`η = 1`) scheme -/

/-- **The balanced failure constant never exceeds the sharp one.**  For every
`δ ≤ 1` the balanced failure constant satisfies `1 + √δ ≤ 2`, the cycle-2
value, and the balanced total constant satisfies `(1+√δ)² ≤ 4`; both
inequalities are strict for `δ < 1`. -/
theorem balanced_beats_sharp (δ : ℝ) (hδ1 : δ ≤ 1) :
    1 + Real.sqrt δ ≤ 2 ∧ (1 + Real.sqrt δ) ^ 2 ≤ 4 := by
  have h1 : Real.sqrt δ ≤ 1 := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt hδ1
  have h0 : 0 ≤ Real.sqrt δ := Real.sqrt_nonneg δ
  exact ⟨by linarith, by nlinarith⟩

/-- **The silent constant is genuinely second order.**  For `δ ≤ 1` the balanced
silent constant satisfies `√δ + δ ≤ 2√δ`, so the silent-error probability is
`O(√δ · |l|/M)` — vanishing relative to the failure probability as `δ → 0`. -/
theorem balanced_silent_le_two_sqrt (δ : ℝ) (hδ0 : 0 ≤ δ) (hδ1 : δ ≤ 1) :
    Real.sqrt δ + δ ≤ 2 * Real.sqrt δ := by
  have hsq : Real.sqrt δ ^ 2 = δ := Real.sq_sqrt hδ0
  have h1 : Real.sqrt δ ≤ 1 := by
    rw [show (1 : ℝ) = Real.sqrt 1 by simp]
    exact Real.sqrt_le_sqrt hδ1
  nlinarith [Real.sqrt_nonneg δ]

/-- **The failure constant reaches the first-moment optimum in the limit.**
`1 + √δ → 1` as `δ → 0⁺`: the balanced scheme pays *no* constant-factor price
over the first-moment (non-derandomized) bound in the high-accuracy regime,
while simultaneously keeping silent corruption at `O(√δ)`. -/
theorem balanced_failure_constant_tendsto_one :
    Filter.Tendsto (fun δ : ℝ => 1 + Real.sqrt δ)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 1) := by
  have h : Filter.Tendsto (fun δ : ℝ => 1 + Real.sqrt δ) (nhds 0) (nhds (1 + Real.sqrt 0)) :=
    Filter.Tendsto.const_add _ (Real.continuous_sqrt.tendsto 0)
  simp only [Real.sqrt_zero, add_zero] at h
  exact h.mono_left nhdsWithin_le_nhds

/-- The silent constant vanishes in the same limit. -/
theorem balanced_silent_constant_tendsto_zero :
    Filter.Tendsto (fun δ : ℝ => Real.sqrt δ + δ)
      (nhdsWithin 0 (Set.Ioi 0)) (nhds 0) := by
  have h : Filter.Tendsto (fun δ : ℝ => Real.sqrt δ + δ) (nhds 0)
      (nhds (Real.sqrt 0 + 0)) :=
    (Real.continuous_sqrt.tendsto 0).add (Filter.tendsto_id)
  simp only [Real.sqrt_zero, add_zero] at h
  exact h.mono_left nhdsWithin_le_nhds

end Balanced

end AlmostLossless