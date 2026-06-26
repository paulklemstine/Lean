/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Brooks' theorem: the greedy bound and its tight exceptions

Brooks' theorem states that for a connected graph `G` that is neither a complete
graph nor an odd cycle, `χ(G) ≤ Δ(G)`.  The "background" bound that holds for *every*
finite graph is the **greedy / degeneracy bound** `χ(G) ≤ Δ(G) + 1`, and Brooks'
theorem identifies exactly when this slack of `+1` is unavoidable.

This file proves:

* `ChromaticBrooks.colorable_maxDegree_add_one` : the greedy bound — every finite
  graph is `(Δ(G) + 1)`-colorable.  Proved by induction on `|V|` (delete a vertex,
  color the rest, then choose a free color for the deleted vertex, which is possible
  because it has at most `Δ` neighbors).
* `ChromaticBrooks.chromaticNumber_le_maxDegree_add_one` : the same bound phrased for
  the chromatic number.
* `ChromaticBrooks.completeGraph_chromatic_eq_maxDegree_add_one` : the complete graph
  `K_{n+1}` satisfies `χ = Δ + 1`, so it is a genuine Brooks exception.
* `ChromaticBrooks.oddCycle_chromatic_eq_maxDegree_add_one` : an odd cycle satisfies
  `χ = 3 = Δ + 1`, the second Brooks exception.

Together these show the greedy bound is sharp exactly on the Brooks exceptions.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `+1` in the greedy bound is necessary precisely on
complete graphs and odd cycles; everywhere else it can be removed (Brooks).

Experiment (Experimenter): we proved the universal bound `χ ≤ Δ+1` by vertex-deletion
induction, and exhibited the two exception families realizing equality.  The full
"only these two" direction (Brooks proper) is left to FUTURE_DIRECTIONS.

Analysis (Analyst): the greedy bound's proof is purely local — each vertex sees at
most `Δ` already-colored neighbors — which is why `Δ+1` colors always suffice.  The
exceptions are global obstructions (a `K_{n+1}` clique; an odd closed walk).

Critique (Critic): the exception theorems are not vacuous — `chromaticNumber_top` and
`chromaticNumber_cycleGraph_of_odd` give concrete chromatic numbers, and the maximum
degrees are computed, not assumed.
-/

open Finset SimpleGraph

namespace ChromaticBrooks

/-
**Greedy / degeneracy bound.**  Every finite simple graph is colorable with
`maxDegree + 1` colors.
-/
theorem colorable_maxDegree_add_one {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    G.Colorable (G.maxDegree + 1) := by
  obtain ⟨c, hc⟩ : ∃ c : V → Fin (G.maxDegree + 1), ∀ v ∈ Finset.univ, ∀ w ∈ Finset.univ, G.Adj v w → c v ≠ c w := by
    -- We can construct such a coloring using a greedy algorithm.
    have h_greedy : ∀ (s : Finset V), ∃ c : V → Fin (G.maxDegree + 1), ∀ v ∈ s, ∀ w ∈ s, G.Adj v w → c v ≠ c w := by
      intro s;
      induction' s using Finset.induction with v s ih;
      · exact ⟨ fun _ => 0, by simp +decide ⟩;
      · obtain ⟨ c, hc ⟩ := ‹_›;
        -- Let's choose a color for $v$ that is different from the colors of its neighbors in $s$.
        obtain ⟨color_v, hcolor_v⟩ : ∃ color_v : Fin (G.maxDegree + 1), ∀ w ∈ s, G.Adj v w → color_v ≠ c w := by
          have h_card : Finset.card (Finset.image c (Finset.filter (fun w => G.Adj v w) s)) ≤ G.maxDegree := by
            refine' le_trans ( Finset.card_image_le ) _;
            exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun w => G.Adj v w ) s ⊆ G.neighborFinset v from fun x hx => by aesop ) ) ( by simpa using G.degree_le_maxDegree v );
          contrapose! h_card;
          rw [ show Finset.image c ( Finset.filter ( fun w => G.Adj v w ) s ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ w, hw₁, hw₂, rfl ⟩ := h_card x; exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ hw₁, hw₂ ⟩ ) ] ; simp +decide [ Finset.card_univ ];
        use fun w => if w = v then color_v else c w;
        simp_all +decide [ SimpleGraph.adj_comm ];
        exact ⟨ fun w hw hw' => by rintro rfl; exact ih hw, fun w hw => ⟨ fun hw' => ⟨ by rintro rfl; exact ih hw, Ne.symm ( hcolor_v w hw hw' ) ⟩, fun x hx hx' => by rw [ if_neg ( by rintro rfl; exact ih hw ), if_neg ( by rintro rfl; exact ih hx ) ] ; exact hc _ hw _ hx hx' ⟩ ⟩;
    exact h_greedy Finset.univ;
  exact ⟨ c, by aesop ⟩

/-
The greedy bound, phrased for the chromatic number.
-/
theorem chromaticNumber_le_maxDegree_add_one {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] :
    G.chromaticNumber ≤ (G.maxDegree + 1 : ℕ) := by
  exact SimpleGraph.chromaticNumber_le_iff_colorable.mpr ( colorable_maxDegree_add_one G )

/-
The complete graph `K_{n+1}` has maximum degree `n`.
-/
theorem maxDegree_completeGraph (n : ℕ) :
    (⊤ : SimpleGraph (Fin (n + 1))).maxDegree = n := by
  refine' le_antisymm _ _ <;> simp_all +decide [ SimpleGraph.maxDegree ];
  · induction' ( Finset.univ : Finset ( Fin ( n + 1 ) ) ) using Finset.induction <;> aesop;
  · rw [ show ( image ( fun v : Fin ( n + 1 ) => n ) univ : Finset ℕ ) = { n } by ext; aesop ] ; aesop

/-
**First Brooks exception.**  The complete graph `K_{n+1}` realizes the greedy
bound with equality: `χ = Δ + 1`.
-/
theorem completeGraph_chromatic_eq_maxDegree_add_one (n : ℕ) :
    (⊤ : SimpleGraph (Fin (n + 1))).chromaticNumber
      = ((⊤ : SimpleGraph (Fin (n + 1))).maxDegree + 1 : ℕ) := by
  rw [ maxDegree_completeGraph ];
  norm_num

/-
An odd cycle `C_{2m+3}` has maximum degree `2`.
-/
theorem maxDegree_cycleGraph (m : ℕ) :
    (cycleGraph (2 * m + 3)).maxDegree = 2 := by
  -- By definition of `cycleGraph`, every vertex has degree 2.
  have h_degree : ∀ v : Fin (2 * m + 3), (cycleGraph (2 * m + 3)).degree v = 2 := by
    intro v; rw [ SimpleGraph.degree ] ; simp +decide [ SimpleGraph.neighborFinset ] ;
    erw [ Finset.card_eq_two ] ; use v - 1, v + 1 ; simp +decide [ sub_eq_add_neg ] ;
    constructor;
    · simp +decide [ Fin.ext_iff ];
    · ext x; simp [cycleGraph];
      constructor <;> intro h <;> simp_all +decide [ sub_eq_iff_eq_add ];
      · grind;
      · rcases h with ( rfl | rfl ) <;> simp +decide [ add_comm, Fin.ext_iff ];
  simp_all +decide [ SimpleGraph.maxDegree ];
  erw [ Finset.image_const ] <;> norm_num;
  rfl

/-
**Second Brooks exception.**  An odd cycle realizes the greedy bound with
equality: `χ = 3 = Δ + 1`.
-/
theorem oddCycle_chromatic_eq_maxDegree_add_one (m : ℕ) :
    (cycleGraph (2 * m + 3)).chromaticNumber
      = ((cycleGraph (2 * m + 3)).maxDegree + 1 : ℕ) := by
  rw [ maxDegree_cycleGraph, chromaticNumber_cycleGraph_of_odd ] <;> norm_num;
  grind

end ChromaticBrooks