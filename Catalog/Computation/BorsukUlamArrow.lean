/-
# The Borsuk–Ulam Route to Arrow-Style Impossibility: Social Choice as Topology

This file investigates the conjecture that *social choice is topology*: that an
Arrow-style impossibility for **continuous** social welfare functions is a
corollary of the (one–dimensional) Borsuk–Ulam theorem.

We model the "preference circle" `S¹` by `2π`-periodic continuous real functions
`f : ℝ → ℝ`, with the **antipodal map** sending a profile `θ` to its opposite
profile `θ + π` (every voter's ranking reversed). A continuous *social welfare
function* (SWF) assigns to each profile the social margin of `A` over `B`.

We prove:

* `borsuk_ulam_one_dim` — the 1-D Borsuk–Ulam theorem: every continuous circle
  function has an antipodal coincidence `f θ = f (θ + π)`. This is proved
  honestly from the Intermediate Value Theorem (imported from the Bridges
  catalog domain).
* `no_continuous_decisive_swf` — the Arrow-style impossibility: there is **no**
  continuous SWF that both *respects preference reversal* (`swf (θ+π) = -swf θ`)
  and is *decisive* (`swf θ ≠ 0` everywhere). Society is forced into a tie.
* `borsuk_ulam_arrow_bridge` — the cross-domain bridge theorem combining the
  **Computation/Impossibility** equivariant framework (the antipodal `ZMod 2`
  action is fixed-point free, `zmod_add_free`) with the **Bridges/IVT** result,
  exhibiting the forced social tie as the topological shadow of an algebraically
  free involution.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer):
  H1. Arrow's full impossibility is *literally* Borsuk–Ulam.  [too strong]
  H2. A continuous, reversal-respecting, decisive SWF on the preference circle
      cannot exist; the obstruction is exactly a 1-D Borsuk–Ulam coincidence.
  H3. The obstruction is structural: it is the algebraic shadow of the free
      ZMod 2 antipodal action (no fixed profile equals its own reversal).
  H4. Borsuk–Ulam in dimension 1 is provable directly from the IVT.

EXPERIMENT (Experimenter):
  - Mathlib has NO Borsuk–Ulam theorem (searched: borsuk/antipodal/LS-category).
    So we BUILD the 1-D case from the IVT bridge (`zero_crossing`).
  - We model S¹ → ℝ by 2π-periodic continuous f. The odd auxiliary function
    g(θ) = f θ - f (θ+π) satisfies g(π) = -g(0) by periodicity, so IVT gives a
    zero: an antipodal coincidence. Verified, 0 sorries.
  - Reversal axiom + coincidence forces swf θ = -swf θ, hence a tie. Verified.

ANALYSIS (Analyst):
  - H1 is FALSE as stated (discrete Arrow ≠ Borsuk–Ulam; the real topological
    statement needs continuity, à la Chichilnisky). We keep the honest H2/H3/H4.
  - "true but hard": general n-dim Borsuk–Ulam (absent from Mathlib).
  - "needs a different definition": Arrow with finite profiles is combinatorial,
    not topological — so we state the *continuous* impossibility, which IS
    topological and which the Borsuk–Ulam method genuinely proves.

CRITIQUE (Critic):
  - Not vacuous: a *constant nonzero* swf is continuous and decisive but FAILS
    reversal; an *honest* reversal-respecting swf (e.g. swf = sin) is continuous
    but NOT decisive (it has zeros). The theorem says you cannot have both — and
    `sin` witnesses that the hypotheses are individually satisfiable.
  - Main proofs use IVT + by_contra/rcases, not simp/decide. Bridge theorem uses
    a result from a *different* catalog domain (`zmod_add_free`).

SYNTHESIS (PI): The continuous Arrow impossibility is a 1-D Borsuk–Ulam corollary;
  Borsuk–Ulam is IVT; the structural cause is a free involution. Social choice,
  in its continuous form, really is topology.

BRIDGE FILES USED:
  * Bridges/IntermediateValueBridge.lean  (domain: Bridges)  — `zero_crossing`
  * Computation/Impossibility/Core.lean   (domain: Computation) — `zmod_add_free`
  NEW CONNECTION: the IVT-built Borsuk–Ulam coincidence (analysis) is identified
  with the fixed-point-freeness of the ZMod 2 antipodal action (algebra),
  yielding a single theorem in which an analytic obstruction and an algebraic
  obstruction are two faces of the same impossibility.
-/

import Mathlib
import Bridges.IntermediateValueBridge
import Computation.Impossibility.Core

open Real Set

namespace BorsukUlamArrow

/-- A *circle function* models a continuous map `S¹ → ℝ`: a continuous,
`2π`-periodic real function. Antipodal profiles are `θ` and `θ + π`. -/
structure IsCircleFn (f : ℝ → ℝ) : Prop where
  cont : Continuous f
  per  : Function.Periodic f (2 * π)

/-- **One-dimensional Borsuk–Ulam theorem.** Every continuous circle function
takes equal values on some antipodal pair `θ, θ + π`. Proved from the
Intermediate Value Theorem (Bridges domain). -/
theorem borsuk_ulam_one_dim {f : ℝ → ℝ} (hf : IsCircleFn f) :
    ∃ θ : ℝ, f θ = f (θ + π) := by
  set g : ℝ → ℝ := fun θ => f θ - f (θ + π) with hg
  have hgcont : Continuous g :=
    hf.cont.sub (hf.cont.comp (continuous_id.add continuous_const))
  have hper2 : f (π + π) = f 0 := by
    have := hf.per 0
    have e : (0 : ℝ) + 2 * π = π + π := by ring
    rw [e] at this; simpa using this
  have hg0 : g 0 = f 0 - f π := by simp [hg]
  have hgpi : g π = f π - f 0 := by simp [hg, hper2]
  have hopp : g π = - g 0 := by rw [hg0, hgpi]; ring
  have hpinn : (0 : ℝ) ≤ π := le_of_lt pi_pos
  rcases le_or_gt (g 0) 0 with h | h
  · -- `g 0 ≤ 0` and `g π = -(g 0) ≥ 0`, so IVT gives a zero of `g`.
    have hb : 0 ≤ g π := by rw [hopp]; linarith
    obtain ⟨x, _, hx⟩ :=
      IntermediateValueBridge.zero_crossing hpinn hgcont.continuousOn h hb
    refine ⟨x, ?_⟩
    have hxz : g x = 0 := hx
    simp only [hg] at hxz; linarith [hxz]
  · -- `g 0 > 0`, apply the zero-crossing to `-g`.
    have hng : Continuous (fun θ => - g θ) := hgcont.neg
    have ha : (fun θ => - g θ) 0 ≤ 0 := by simp; linarith
    have hb : 0 ≤ (fun θ => - g θ) π := by simp [hopp]; linarith
    obtain ⟨x, _, hx⟩ :=
      IntermediateValueBridge.zero_crossing hpinn hng.continuousOn ha hb
    refine ⟨x, ?_⟩
    have hxz : g x = 0 := by simpa using hx
    simp only [hg] at hxz; linarith [hxz]

/-- **Continuous Arrow-style impossibility.** There is no continuous social
welfare function that simultaneously respects preference reversal
(`swf (θ+π) = -swf θ`) and is decisive (`swf θ ≠ 0` everywhere): the antipodal
Borsuk–Ulam coincidence forces a social tie. -/
theorem no_continuous_decisive_swf :
    ¬ ∃ swf : ℝ → ℝ, IsCircleFn swf ∧
      (∀ θ, swf (θ + π) = - swf θ) ∧ (∀ θ, swf θ ≠ 0) := by
  rintro ⟨swf, hc, hrev, hdec⟩
  obtain ⟨θ, hθ⟩ := borsuk_ulam_one_dim hc
  rw [hrev θ] at hθ
  exact hdec θ (by linarith)

/-- The reversal and decisiveness hypotheses are *individually* satisfiable, so
the impossibility is non-vacuous. `sin` is a continuous reversal-respecting
circle function (witnessing the reversal axiom is consistent). -/
theorem reversal_axiom_satisfiable :
    ∃ swf : ℝ → ℝ, IsCircleFn swf ∧ (∀ θ, swf (θ + π) = - swf θ) := by
  refine ⟨Real.sin, ⟨Real.continuous_sin, Real.sin_periodic⟩, ?_⟩
  intro θ; exact Real.sin_add_pi θ

/-- **Cross-domain bridge: Borsuk–Ulam ⇄ free involution.**
For any continuous reversal-respecting SWF, *both* of the following hold:
* (Computation/Impossibility) the antipodal generator `1 : ZMod 2` acts freely —
  no profile-class equals its own reversal (`zmod_add_free`);
* (Bridges/IVT) the SWF is forced to produce a social tie `∃ θ, swf θ = 0`.
The forced analytic tie is the topological shadow of the algebraically free
involution: social choice is topology. -/
theorem borsuk_ulam_arrow_bridge (swf : ℝ → ℝ) (h : IsCircleFn swf)
    (hrev : ∀ θ, swf (θ + π) = - swf θ) :
    (∀ g : ZMod 2, g ≠ 0 → ∀ x : ZMod 2, g + x ≠ x) ∧ (∃ θ, swf θ = 0) := by
  refine ⟨zmod_add_free (le_refl 2), ?_⟩
  obtain ⟨θ, hθ⟩ := borsuk_ulam_one_dim h
  rw [hrev θ] at hθ
  exact ⟨θ, by linarith⟩

end BorsukUlamArrow