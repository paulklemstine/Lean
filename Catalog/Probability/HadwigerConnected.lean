/-
  Reduction of Hadwiger's Conjecture to Connected Graphs
  =====================================================

  A structural reduction: to prove Hadwiger's conjecture for a parameter `k` it
  suffices to prove it for *connected* graphs.  The two ingredients are

  * a colouring-gluing lemma — a graph is `k`-colourable as soon as each of its
    connected components is (the components are pairwise non-adjacent, so
    independently chosen colourings can be assembled), and
  * minor transfer along induced subgraphs (`isMinor_of_isMinor_induce` from
    `HadwigerCore.lean`) — a `K_{k+1}` minor of a component is a `K_{k+1}` minor
    of the whole graph.

  Main results:

  * `Hadwiger.colorable_of_forall_component_colorable`
  * `Hadwiger.exists_component_not_colorable`
  * `Hadwiger.hadwigerProperty_of_connected` : the reduction.
  * `Hadwiger.hadwigerPropertyGen_of_connected` : the same reduction for the
    finiteness-free form of the conjecture.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): Hadwiger's conjecture should have a "minimal
    counterexample is connected" normalisation, since neither the chromatic
    number nor the minor relation sees the component decomposition.
  Experiment (Experimenter): the gluing lemma is the only delicate point — the
    chosen colouring of a component lives on the subtype `↥c.supp`, so the
    assembled colouring `fun v => F (G.connectedComponentMk v) ⟨v, rfl⟩` is
    dependently typed.  The helper `colorGlue_apply` (proved by `subst`) makes
    the dependency disappear, after which validity is immediate from
    `ConnectedComponent.connectedComponentMk_eq_of_adj`.
  Analysis (Analyst): the reduction needs no finiteness, and it holds verbatim
    for both forms of the conjecture; nothing about `k` is used.  This makes it
    a legitimate preprocessing step for the still-open cases `k ≥ 5`.
  Critique (Critic): the reduction is *not* vacuous — the hypothesis quantifies
    only over connected graphs, a strictly smaller class, and the conclusion is
    the full statement.  Applying it to `k ≤ 2` recovers the theorems already
    proved, which is the sanity check `hadwiger_two_via_connected`.
  Synthesis (PI): combined with `hadwiger_monotone`, Hadwiger's conjecture is
    now known in this development to be antitone in `k` and reducible to
    connected graphs.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerInfinite

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V} {k : ℕ}

section Gluing

/-- The colouring assembled from a choice of colouring on each component. -/
private noncomputable def glueColor
    (hcol : ∀ c : G.ConnectedComponent, (G.induce c.supp).Colorable k) (v : V) : Fin k :=
  (hcol (G.connectedComponentMk v)).some ⟨v, rfl⟩

private theorem glueColor_apply
    (hcol : ∀ c : G.ConnectedComponent, (G.induce c.supp).Colorable k)
    {c : G.ConnectedComponent} {v : V}
    (hv : G.connectedComponentMk v = c) :
    glueColor hcol v = (hcol c).some ⟨v, hv⟩ := by
  subst hv; rfl

/-- **Gluing lemma.** A graph all of whose connected components are
`k`-colourable is itself `k`-colourable. -/
theorem colorable_of_forall_component_colorable
    (hcol : ∀ c : G.ConnectedComponent, (G.induce c.supp).Colorable k) : G.Colorable k := by
  classical
  refine ⟨Coloring.mk (glueColor hcol) ?_⟩
  intro u v huv
  have hc : G.connectedComponentMk v = G.connectedComponentMk u :=
    (ConnectedComponent.connectedComponentMk_eq_of_adj huv.symm)
  rw [glueColor_apply hcol (c := G.connectedComponentMk u) rfl,
    glueColor_apply hcol (c := G.connectedComponentMk u) hc]
  exact (hcol (G.connectedComponentMk u)).some.valid (by exact huv)

end Gluing

/-- If a graph is not `k`-colourable, then one of its connected components is
not `k`-colourable. -/
theorem exists_component_not_colorable (h : ¬ G.Colorable k) :
    ∃ c : G.ConnectedComponent, ¬ (G.induce c.supp).Colorable k := by
  by_contra hcon
  push_neg at hcon
  exact h (colorable_of_forall_component_colorable hcon)

/-- **Reduction to connected graphs.**  Hadwiger's conjecture for `k` follows
from its restriction to connected graphs. -/
theorem hadwigerProperty_of_connected
    (h : ∀ (V : Type) [Finite V] (G : SimpleGraph V), G.Connected →
      ¬ G.Colorable k → CompleteMinor (k + 1) G) :
    HadwigerProperty k := by
  intro V _ G hG
  obtain ⟨c, hc⟩ := exists_component_not_colorable hG
  have hconn : (G.induce c.supp).Connected :=
    (ConnectedComponent.maximal_connected_induce_supp c).prop
  exact isMinor_of_isMinor_induce (h _ (G.induce c.supp) hconn hc)

/-- The same reduction for the finiteness-free form of the conjecture. -/
theorem hadwigerPropertyGen_of_connected
    (h : ∀ (V : Type) (G : SimpleGraph V), G.Connected →
      ¬ G.Colorable k → CompleteMinor (k + 1) G) :
    HadwigerPropertyGen k := by
  intro V G hG
  obtain ⟨c, hc⟩ := exists_component_not_colorable hG
  have hconn : (G.induce c.supp).Connected :=
    (ConnectedComponent.maximal_connected_induce_supp c).prop
  exact isMinor_of_isMinor_induce (h _ (G.induce c.supp) hconn hc)

/-- Sanity check that the reduction is usable: it re-derives the `k = 2` case
from the connected case alone. -/
theorem hadwiger_two_via_connected : HadwigerProperty 2 :=
  hadwigerProperty_of_connected fun _ _ _ _ hG =>
    completeMinor_three_of_not_isAcyclic
      (fun hac => hG (colorable_two_of_isAcyclic_general hac))

end Hadwiger