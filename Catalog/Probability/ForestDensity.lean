/-
  Forests: a Minor-Closed Class Strictly Below Density 3/2
  =======================================================

  This file instantiates the abstract framework of `OrderFramework.lean` with the
  concrete order on `SimpleGraph V` (the subgraph order, a sub-relation of the
  graph-minor order) and studies the class of **forests** (acyclic graphs).

  The mission concerns ⊆-minimal minor-closed classes whose limiting density is
  below `3/2`.  The class of forests is the prototypical such class: its limiting
  density is exactly `1 < 3/2`.  Here we prove, with full rigour:

  * `acyclicClass_minorClosed`        : forests form a minor-closed class
                                        (instance of `MinorTheory.MinorClosed`).
  * `IsAcyclic.card_edgeSet_add_one_le`: the forest edge bound `|E| + 1 ≤ |V|`.
  * `IsTree.edgeDensity_lt_one`        : every tree has edge density `< 1`.
  * `acyclic_edgeDensity_lt_threshold` : every forest has edge density `< 3/2`.
  * `acyclicClass_below_threshold`     : the whole forest class lies strictly
                                         below the `3/2` density threshold.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the forest class is a genuine, non-trivial instance
    of a minor-closed class living strictly below the 3/2 density threshold.
  Experiment (Experimenter): instantiated `MinorTheory.MinorClosed` at
    `SimpleGraph V` with `≤ = subgraph`; the closure law is exactly
    `SimpleGraph.IsAcyclic.anti`.  The density bound reduces to the forest edge
    inequality, obtained by extending any forest to a spanning tree of the
    complete graph (`Connected.exists_isTree_le_of_le_of_isAcyclic`).
  Analysis (Analyst): the edge bound `|E| ≤ |V| - 1` is what forces density `< 1`;
    `1 < 3/2` then gives the threshold.  The empty-graph corner case is handled by
    `Nat.card V = 0` making the density `0`.
  Critique (Critic): we use the *subgraph* specialisation of the minor order, for
    which the class is provably minor-closed via `IsAcyclic.anti`.  The full
    contraction-closed statement (forests `= excl {K₃}` as minors) is recorded in
    FUTURE_DIRECTIONS.md as the natural next target.
  Synthesis (PI): forests realise the framework — a minor-closed class strictly
    below 3/2 — and the density gap `1 < 3/2` is the quantitative heart.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.MinorClosed.OrderFramework

namespace MinorTheory.ForestDensity

open SimpleGraph

variable {V : Type*}

/-- The class of acyclic graphs (forests) on a fixed vertex set `V`. -/
def acyclicClass (V : Type*) : Set (SimpleGraph V) := {G | G.IsAcyclic}

/-- The class of forests is minor-closed (in the subgraph specialisation of the
minor order): any subgraph of an acyclic graph is acyclic. -/
theorem acyclicClass_minorClosed :
    MinorTheory.MinorClosed (acyclicClass V) := by
  intro G H hGH hH
  exact hH.anti hGH

/-- Edge density of a finite graph: `|E| / |V|` as a rational number.  When
`V` is empty this evaluates to `0`. -/
noncomputable def edgeDensity (G : SimpleGraph V) : ℚ :=
  (Nat.card G.edgeSet : ℚ) / (Nat.card V : ℚ)

/-
**Forest edge bound.** A non-empty finite forest on `V` has at most
`|V| - 1` edges, i.e. `|E| + 1 ≤ |V|`.
-/
theorem IsAcyclic.card_edgeSet_add_one_le [Finite V] [Nonempty V]
    {G : SimpleGraph V} (h : G.IsAcyclic) :
    Nat.card G.edgeSet + 1 ≤ Nat.card V := by
  have hG_finite : Fintype V := Fintype.ofFinite V;
  -- By `SimpleGraph.Connected.exists_isTree_le_of_le_of_isAcyclic connected_top le_top h` we obtain a graph F with G ≤ F, F ≤ ⊤, and F.IsTree.
  obtain ⟨F, hG_le_F, hF_le_top, hF_isTree⟩ : ∃ F : SimpleGraph V, G ≤ F ∧ F ≤ ⊤ ∧ F.IsTree := by
    exact ⟨ Classical.choose ( SimpleGraph.Connected.exists_isTree_le_of_le_of_isAcyclic ( SimpleGraph.connected_top ) le_top h ), Classical.choose_spec ( SimpleGraph.Connected.exists_isTree_le_of_le_of_isAcyclic ( SimpleGraph.connected_top ) le_top h ) |>.1, Classical.choose_spec ( SimpleGraph.Connected.exists_isTree_le_of_le_of_isAcyclic ( SimpleGraph.connected_top ) le_top h ) |>.2.1, Classical.choose_spec ( SimpleGraph.Connected.exists_isTree_le_of_le_of_isAcyclic ( SimpleGraph.connected_top ) le_top h ) |>.2.2 ⟩;
  have := hF_isTree.card_edgeFinset;
  simp +zetaDelta at *;
  exact lt_of_le_of_lt ( Finset.card_mono <| by aesop ) ( Nat.lt_of_succ_le this.le )

/-
Every finite tree has edge density strictly below `1`.
-/
theorem IsTree.edgeDensity_lt_one [Finite V] {G : SimpleGraph V}
    (hG : G.IsTree) : edgeDensity G < 1 := by
  obtain ⟨ v, hv ⟩ := hG;
  have h_card : Nat.card G.edgeSet + 1 = Nat.card V := by
    have := SimpleGraph.isTree_iff_connected_and_card.mp ⟨ v, hv ⟩;
    exact this.2;
  unfold edgeDensity;
  rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith

/-
**Forests are below the 3/2 threshold.** Every finite forest has edge density
strictly below `3/2`.
-/
theorem acyclic_edgeDensity_lt_threshold [Finite V] {G : SimpleGraph V}
    (h : G.IsAcyclic) : edgeDensity G < 3 / 2 := by
  by_cases hV : Nonempty V <;> simp_all +decide [ edgeDensity ];
  rw [ div_lt_div_iff₀ ] <;> norm_cast;
  · have := IsAcyclic.card_edgeSet_add_one_le h; simp_all +decide [ mul_comm ] ; linarith;
  · exact Nat.card_pos

/-- The minor-closed class of forests lies strictly below the `3/2` density
threshold — the concrete setting of the research mission. -/
theorem acyclicClass_below_threshold [Finite V] :
    ∀ G ∈ acyclicClass V, edgeDensity G < 3 / 2 := by
  intro G hG
  exact acyclic_edgeDensity_lt_threshold hG

end MinorTheory.ForestDensity