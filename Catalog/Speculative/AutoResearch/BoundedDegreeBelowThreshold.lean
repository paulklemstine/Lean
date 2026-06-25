/-
  Bounded-Degree Classes: a New Minor-Closed Family Strictly Below Density 3/2
  ===========================================================================

  `Catalog/Probability/ForestDensity.lean` exhibited the **forest** class as a
  concrete minor-closed (subgraph-specialised) class living strictly below the
  density threshold `3/2`.  This file adds a *second*, structurally different
  witness: the class of graphs of **maximum degree at most `2`** — disjoint unions
  of paths and cycles.  Unlike forests, these graphs may contain arbitrarily many
  cycles, yet they still fall below the `3/2` floor.

  We work, exactly as `ForestDensity.lean` does, in the subgraph specialisation of
  the minor order on `SimpleGraph V` (the subgraph order being a sub-relation of
  the graph-minor order), and we reuse the catalog's edge-density invariant.

  Main results (all 0-sorry):

  * `maxDegree_mono`                    : `G ≤ G' → G.maxDegree ≤ G'.maxDegree`
                                          (degree is monotone under the subgraph
                                          order; this drives minor-closure).
  * `boundedDegreeClass_minorClosed`    : `{G | G.maxDegree ≤ d}` is minor-closed.
  * `edgeFinset_card_le_of_maxDegree_two`: the handshaking edge bound `|E| ≤ |V|`
                                          for graphs of max degree `≤ 2`.
  * `maxDegree_two_edgeDensity_lt`      : every such graph has density `< 3/2`.
  * `boundedDegreeTwoClass_below_threshold`
                                        : the whole class lies below `3/2`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): forests are not the only minor-closed family below
    3/2; the density floor of 3/2 corresponds (via the handshaking identity
    `∑ deg = 2|E|`) to *average degree below 3*, so any class with a uniform degree
    cap of 2 should sit at average degree ≤ 2 < 3 and hence below 3/2 — and such a
    class is genuinely richer than forests since it contains all cycles.
  Experiment (Experimenter): defined `boundedDegreeClass V d = {G | maxDegree ≤ d}`
    (classical decidability), proved minor-closure from degree monotonicity
    (`SimpleGraph.degree_le_of_le` + `maxDegree_le_of_forall_degree_le`), and
    derived the density bound from `sum_degrees_eq_twice_card_edges`.
  Analysis (Analyst): the quantitative heart is `2|E| = ∑ deg ≤ 2|V|`, i.e.
    `|E| ≤ |V|`, giving density ≤ 1 < 3/2.  The empty-vertex corner case makes the
    density `0` and is dispatched separately.  The bound `≤ 1` (not just `< 3/2`)
    shows the class is comfortably inside the threshold, matching forests' floor of
    1 even though it contains cycles forests cannot.
  Critique (Critic): the class is **subgraph**-minor-closed; full contraction
    closure fails (contracting raises degree), so — exactly as in the catalog's
    forest file — we stay in the subgraph specialisation.  Importantly the result
    is not vacuous: cycles `C_n` have maxDegree `2` and `|E| = |V|`, so the bound
    `|E| ≤ |V|` is *tight* and the class is strictly larger than the forest class.
  Synthesis (PI): two qualitatively different minor-closed families (acyclic; and
    degree-≤-2) both live below 3/2, supporting the mission picture that the region
    below 3/2 is populated by structurally constrained, single-parameter families —
    the regime in which ⊆-minimality is expected to force a single forbidden minor.
  -- !-- Lab Notes -- !--
-/
import Mathlib

namespace MinorTheory.Novelty.BoundedDegree

open SimpleGraph

variable {V : Type*}

/-- A graph class `C` is minor-closed (in the subgraph specialisation) when it is
downward closed under the subgraph order.  (Same shape as
`MinorTheory.MinorClosed` instantiated at `SimpleGraph V`.) -/
def MinorClosed (C : Set (SimpleGraph V)) : Prop :=
  ∀ ⦃G H : SimpleGraph V⦄, G ≤ H → H ∈ C → G ∈ C

/-- Edge density `|E| / |V|` as a rational (mirrors
`MinorTheory.ForestDensity.edgeDensity`).  Evaluates to `0` when `V` is empty. -/
noncomputable def edgeDensity (G : SimpleGraph V) : ℚ :=
  (Nat.card G.edgeSet : ℚ) / (Nat.card V : ℚ)

/-- The class of graphs on `V` of maximum degree at most `d`. -/
def boundedDegreeClass (V : Type*) [Fintype V] (d : ℕ) : Set (SimpleGraph V) :=
  open scoped Classical in {G | G.maxDegree ≤ d}

/-- **Degree monotonicity.** The maximum degree is monotone under the subgraph
order: enlarging the edge set can only raise degrees. -/
theorem maxDegree_mono [Fintype V] {G G' : SimpleGraph V}
    [DecidableRel G.Adj] [DecidableRel G'.Adj] (h : G ≤ G') :
    G.maxDegree ≤ G'.maxDegree := by
  refine SimpleGraph.maxDegree_le_of_forall_degree_le _ _ ?_
  intro v
  exact le_trans (degree_le_of_le h) (G'.degree_le_maxDegree v)

/-- **Bounded-degree classes are minor-closed** (subgraph specialisation). -/
theorem boundedDegreeClass_minorClosed [Fintype V] (d : ℕ) :
    MinorClosed (boundedDegreeClass V d) := by
  classical
  intro G H hGH hH
  simp only [boundedDegreeClass, Set.mem_setOf_eq] at hH ⊢
  exact le_trans (maxDegree_mono hGH) hH

/-- **Handshaking edge bound.** A finite graph of maximum degree `≤ 2` has at most
`|V|` edges. -/
theorem edgeFinset_card_le_of_maxDegree_two [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (h : G.maxDegree ≤ 2) :
    G.edgeFinset.card ≤ Fintype.card V := by
  have hsum : ∑ v, G.degree v = 2 * G.edgeFinset.card :=
    G.sum_degrees_eq_twice_card_edges
  have hb : ∑ v, G.degree v ≤ ∑ _v : V, 2 := by
    apply Finset.sum_le_sum
    intro v _
    exact le_trans (G.degree_le_maxDegree v) h
  simp only [Finset.sum_const, Finset.card_univ, smul_eq_mul] at hb
  omega

/-- **Below the threshold.** Every finite graph of maximum degree `≤ 2` has edge
density strictly below `3/2` (in fact at most `1`). -/
theorem maxDegree_two_edgeDensity_lt [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (h : G.maxDegree ≤ 2) :
    edgeDensity G < 3 / 2 := by
  have hcard : G.edgeFinset.card ≤ Fintype.card V :=
    edgeFinset_card_le_of_maxDegree_two G h
  have hE : Nat.card G.edgeSet = G.edgeFinset.card := by
    simp [SimpleGraph.edgeFinset]
  have hV : Nat.card V = Fintype.card V := Nat.card_eq_fintype_card
  unfold edgeDensity
  rw [hE, hV]
  rcases Nat.eq_zero_or_pos (Fintype.card V) with h0 | hpos
  · simp [h0]
  · rw [div_lt_div_iff₀ (by positivity) (by norm_num)]
    have hc : (G.edgeFinset.card : ℚ) ≤ (Fintype.card V : ℚ) := by exact_mod_cast hcard
    have hp : (1 : ℚ) ≤ (Fintype.card V : ℚ) := by exact_mod_cast hpos
    nlinarith [hc, hp]

/-- The minor-closed class of maximum-degree-`≤ 2` graphs lies strictly below the
`3/2` density threshold — a second concrete witness to the research mission,
complementing the forest class of `ForestDensity.lean`. -/
theorem boundedDegreeTwoClass_below_threshold [Fintype V] [DecidableEq V] :
    ∀ G : SimpleGraph V, ∀ _ : DecidableRel G.Adj, G.maxDegree ≤ 2 →
      edgeDensity G < 3 / 2 := by
  intro G _ h
  exact maxDegree_two_edgeDensity_lt G h

end MinorTheory.Novelty.BoundedDegree