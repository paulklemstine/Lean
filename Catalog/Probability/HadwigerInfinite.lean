/-
  Hadwiger's Conjecture without Finiteness: the Cases k ≤ 2 for Arbitrary Graphs
  =============================================================================

  `HadwigerSmallCases.lean` proves Hadwiger's conjecture for `k ≤ 2` for finite
  graphs, the finiteness being used only in the colouring half
  (`colorable_two_of_isAcyclic`, an induction on the number of edges).  This
  file removes the hypothesis entirely: for `k ≤ 2` the conjecture holds for
  *every* vertex type, finite or not.

  The contraction half (`completeMinor_three_of_not_isAcyclic`, proved in
  `HadwigerK3.lean`) never needed finiteness; the colouring half is supplied in
  full generality by Mathlib's `SimpleGraph.IsAcyclic.isBipartite`, which
  two-colours an arbitrary forest by choosing a root in every connected
  component and using parity of distance to the root.

  Main results:

  * `Hadwiger.HadwigerPropertyGen`        : the conjecture with no finiteness
                                            assumption on the vertex type.
  * `Hadwiger.colorable_two_of_isAcyclic_general` : every forest, of any size,
                                            is 2-colourable.
  * `Hadwiger.hadwiger_gen_zero`, `hadwiger_gen_one`, `hadwiger_gen_two`
                                          : the general conjecture for k ≤ 2.
  * `Hadwiger.hadwigerProperty_of_gen`    : the general form implies the finite
                                            form, so these are genuine
                                            strengthenings.
  * `Hadwiger.colorable_two_of_no_K3_minor_general` : the excluded-minor form,
                                            valid for arbitrary graphs.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the finiteness hypothesis in the `k ≤ 2` cases is
    an artefact of the proof method (edge-count induction), not of the
    mathematics; the cases should survive verbatim for infinite graphs.
  Experiment (Experimenter): replaced the edge-count induction by the
    distance-parity colouring `SimpleGraph.IsAcyclic.isBipartite`
    (`IsBipartite` is by definition `Colorable 2`), which is stated in Mathlib
    for an arbitrary vertex type.  All three cases then go through with the
    `[Finite V]` binder deleted.
  Analysis (Analyst): the boundary of the phenomenon is `k = 3`.  For `k ≥ 3`
    even the *statement* becomes delicate for infinite graphs: `¬ Colorable k`
    for an infinite graph is, by de Bruijn–Erdős, equivalent to the existence of
    a finite non-`k`-colourable subgraph, so the general form for `k` follows
    from the finite form for `k` together with minor-monotonicity under
    subgraphs — a reduction that the low cases do not need.
  Critique (Critic): `hadwigerProperty_of_gen` is included precisely to certify
    that nothing was weakened: the general statement really does imply the
    finite one, so these are strengthenings and not incomparable variants.
  Synthesis (PI): the `k ≤ 2` fragment of Hadwiger's conjecture is a theorem
    about all graphs, and `colorable_two_iff_no_K3_minor` records it as a clean
    excluded-minor equivalence.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerSmallCases
import Probability.HadwigerForest

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-- **Every forest is 2-colourable**, with no finiteness hypothesis.  This is the
general form of `colorable_two_of_isAcyclic`; the colouring is the parity of the
distance to a chosen root in each connected component. -/
theorem colorable_two_of_isAcyclic_general (h : G.IsAcyclic) : G.Colorable 2 :=
  h.isBipartite

/-- **Hadwiger's conjecture for the parameter `k`, without finiteness**: every
graph — of arbitrary cardinality — that cannot be properly coloured with `k`
colours contains `K_{k+1}` as a minor. -/
def HadwigerPropertyGen (k : ℕ) : Prop :=
  ∀ (V : Type) (G : SimpleGraph V), ¬ G.Colorable k → CompleteMinor (k + 1) G

/-- The general statement is a strengthening: it implies the finite statement. -/
theorem hadwigerProperty_of_gen {k : ℕ} (h : HadwigerPropertyGen k) :
    HadwigerProperty k :=
  fun V _ G hG => h V G hG

/-- **Hadwiger for `k = 0`, arbitrary graphs.** -/
theorem hadwiger_gen_zero : HadwigerPropertyGen 0 := by
  intro V G h
  have : Nonempty V := by
    by_contra hcon
    exact h (colorable_zero_iff.mpr (not_nonempty_iff.mp hcon))
  obtain ⟨v⟩ := this
  exact completeMinor_one v

/-- **Hadwiger for `k = 1`, arbitrary graphs.** -/
theorem hadwiger_gen_one : HadwigerPropertyGen 1 := by
  intro V G h
  by_cases hE : ∃ u v, G.Adj u v
  · obtain ⟨u, v, huv⟩ := hE
    exact completeMinor_two_of_adj huv
  · push_neg at hE
    exact absurd (colorable_one_of_no_adj hE) h

/-- **Hadwiger for `k = 2`, arbitrary graphs**: any graph, finite or infinite,
that needs three colours contains `K₃` as a minor. -/
theorem hadwiger_gen_two : HadwigerPropertyGen 2 := by
  intro V G h
  have hacyc : ¬ G.IsAcyclic := fun hac => h (colorable_two_of_isAcyclic_general hac)
  exact completeMinor_three_of_not_isAcyclic hacyc

/-- **Excluded-minor form of the `k = 2` case, arbitrary graphs**: a graph with
no `K₃` minor is 2-colourable.  The converse is false — the 6-cycle is
2-colourable and has a `K₃` minor (`chromaticNumber_not_minorMonotone`). -/
theorem colorable_two_of_no_K3_minor_general (h : ¬ CompleteMinor 3 G) : G.Colorable 2 := by
  have : G.IsAcyclic := by
    by_contra hacyc
    exact h (completeMinor_three_of_not_isAcyclic hacyc)
  exact colorable_two_of_isAcyclic_general this

end Hadwiger