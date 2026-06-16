/-
# Continuity Is Essential: The Topological Arrow Dichotomy

Companion to `Computation.BorsukUlamArrow`. Where that file proves the
*impossibility* (no continuous, reversal-respecting, decisive social welfare
function), this file pins down **why** topology is the operative ingredient:

* `decisive_reversal_swf_exists` — if we *drop* continuity, a decisive
  reversal-respecting social welfare function DOES exist (the explicit
  square-wave `socialWave θ = (-1)^⌊θ/π⌋`). So the obstruction is purely
  topological, not combinatorial.
* `socialWave_not_continuous` — that very witness is provably discontinuous, and
  the proof DERIVES the discontinuity from the impossibility theorem of the
  companion file. This is the conjecture's "either discontinuous or [tied]" made
  formal: a decisive periodic reversal-respecting rule must be discontinuous.
* `swf_dichotomy` — the headline dichotomy: every reversal-respecting rule is
  either *not* a continuous circle function or is forced into a social tie.
* `tie_set_antipodal` — the tie set is antipode-stable.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer):
  H5. The Borsuk–Ulam obstruction is *exactly* topological: removing continuity
      makes a decisive reversal-respecting rule possible.  [surprising: the
      impossibility is not about voting combinatorics at all]
  H6. The standard "majority"-style antipodal rule is the square wave
      (-1)^⌊θ/π⌋, and the impossibility theorem certifies its discontinuity
      WITHOUT any ε–δ argument.

EXPERIMENT (Experimenter):
  - Built `socialWave θ = (-1 : ℝ)^⌊θ/π⌋`. Verified it is 2π-periodic
    (`Int.floor_add_ofNat`), reversal-respecting (`Int.floor_add_one`,
    `zpow_add₀`), and nowhere zero (`zpow_ne_zero`).
  - Discontinuity: instead of an ε–δ proof, observe `socialWave` is a periodic,
    reversal-respecting, decisive function; were it continuous it would be an
    `IsCircleFn`, contradicting `no_continuous_decisive_swf`. So the companion
    impossibility theorem yields `¬ Continuous socialWave` for free.

ANALYSIS (Analyst):
  - H5 SURVIVES: the obstruction lives in `Continuous`, confirming "social
    choice is topology": the same data is consistent if and only if we relax the
    topological axiom. The combinatorial content (reversal + decisiveness) is
    individually harmless.
  - H6 SURVIVES and is methodologically pleasing: a *logical* discontinuity
    proof via an impossibility theorem.

CRITIQUE (Critic):
  - Non-vacuous: `decisive_reversal_swf_exists` exhibits an actual function, and
    `socialWave_not_continuous` is a strict negation, not `True`.
  - Uses real content: `by_contra`, `zpow_add₀`, floor lemmas, and reuse of the
    companion theorem — not `simp`/`decide` alone.

SYNTHESIS (PI): Continuity is the load-bearing axiom. The square wave is the
  canonical "antipodal majority"; its discontinuity is a theorem, not an
  assumption. Hence: any decisive, reversal-respecting, periodic social rule is
  discontinuous — the topological form of Arrow's impossibility.

BRIDGE FILES USED:
  * Computation/BorsukUlamArrow.lean (Computation domain) — `IsCircleFn`,
    `no_continuous_decisive_swf`, `borsuk_ulam_one_dim`.
  Transitively this depends on Bridges/IntermediateValueBridge.lean (Bridges
  domain) and Computation/Impossibility/Core.lean, so the two-domain bridge of
  the companion file is inherited here.
-/

import Mathlib
import Computation.BorsukUlamArrow

open Real

namespace BorsukUlamArrow

/-- The canonical "antipodal majority" social rule: a square wave whose value on
the profile `θ` is `+1` or `-1` according to the parity of `⌊θ/π⌋`. It models a
decisive rule that flips under preference reversal. -/
noncomputable def socialWave : ℝ → ℝ := fun θ => (-1 : ℝ) ^ (⌊θ / π⌋)

/-- `socialWave` is `2π`-periodic: it is a genuine function on the preference
circle. -/
theorem socialWave_periodic : Function.Periodic socialWave (2 * π) := by
  intro x
  unfold socialWave
  have hπ : π ≠ 0 := Real.pi_ne_zero
  have h1 : (x + 2 * π) / π = x / π + 2 := by field_simp
  rw [h1, Int.floor_add_ofNat, zpow_add₀ (by norm_num : (-1 : ℝ) ≠ 0)]
  norm_num

/-- `socialWave` flips under preference reversal `θ ↦ θ + π`. -/
theorem socialWave_reversal : ∀ θ, socialWave (θ + π) = - socialWave θ := by
  intro θ
  unfold socialWave
  have hπ : π ≠ 0 := Real.pi_ne_zero
  have h1 : (θ + π) / π = θ / π + 1 := by field_simp
  rw [h1, Int.floor_add_one, zpow_add₀ (by norm_num : (-1 : ℝ) ≠ 0)]
  ring

/-- `socialWave` is decisive: it never produces a tie. -/
theorem socialWave_decisive : ∀ θ, socialWave θ ≠ 0 := by
  intro θ; unfold socialWave; exact zpow_ne_zero _ (by norm_num)

/-- **Dropping continuity restores possibility.** A decisive,
reversal-respecting social welfare function *does* exist — so the impossibility
of the companion file is purely topological, not combinatorial. -/
theorem decisive_reversal_swf_exists :
    ∃ swf : ℝ → ℝ, (∀ θ, swf (θ + π) = - swf θ) ∧ (∀ θ, swf θ ≠ 0) :=
  ⟨socialWave, socialWave_reversal, socialWave_decisive⟩

/-- **The discontinuity of the antipodal majority is a theorem.** Because
`socialWave` is periodic, reversal-respecting and decisive, the impossibility
theorem `no_continuous_decisive_swf` forces it to be discontinuous — no ε–δ
argument required. This is the conjecture's "discontinuous or tied" alternative,
realized concretely. -/
theorem socialWave_not_continuous : ¬ Continuous socialWave := by
  intro hcont
  exact no_continuous_decisive_swf
    ⟨socialWave, ⟨hcont, socialWave_periodic⟩, socialWave_reversal, socialWave_decisive⟩

/-- **The topological Arrow dichotomy.** Every reversal-respecting social welfare
function is *either* not a continuous circle function (it must break topology)
*or* it is forced into a social tie somewhere. -/
theorem swf_dichotomy (swf : ℝ → ℝ) (hrev : ∀ θ, swf (θ + π) = - swf θ) :
    ¬ IsCircleFn swf ∨ ∃ θ, swf θ = 0 := by
  by_cases hc : IsCircleFn swf
  · right
    obtain ⟨θ, hθ⟩ := borsuk_ulam_one_dim hc
    rw [hrev θ] at hθ
    exact ⟨θ, by linarith⟩
  · left; exact hc

/-- The social tie set is antipode-stable: if profile `θ` is a tie, so is its
reversal `θ + π`. -/
theorem tie_set_antipodal {swf : ℝ → ℝ} (hrev : ∀ θ, swf (θ + π) = - swf θ)
    {θ : ℝ} (hθ : swf θ = 0) : swf (θ + π) = 0 := by
  rw [hrev θ, hθ, neg_zero]

end BorsukUlamArrow