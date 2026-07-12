/-
# Property B: two-colourability of sparse `k`-uniform hypergraphs

This file develops a **second pillar of the probabilistic method** alongside the
Erdős counting lower bound for Ramsey numbers (`Novelty.RamseyProbabilisticLowerBound`):
the classical theorem of Erdős that every `k`-uniform hypergraph with fewer than
`2^{k-1}` edges is **two-colourable** (has *Property B*).

A *`k`-uniform hypergraph* on a finite vertex type `V` is a finite family
`H : Finset (Finset V)` of edges, each of cardinality `k`.  A **two-colouring**
is encoded by its *red* vertex set `R : Finset V`; a vertex is red iff it lies in
`R`, otherwise blue.  An edge `e` is *monochromatic* iff it is entirely red
(`e ⊆ R`) or entirely blue (`Disjoint e R`).  The colouring is **proper** iff no
edge is monochromatic; `H` is **two-colourable** iff a proper colouring exists.

The proof is a finite double-count (no measure theory):

* the total number of colourings (subsets `R ⊆ univ`) is `2 ^ N` where
  `N = |V|`;
* for a fixed edge `e` of size `k`, the number of colourings making `e` red is
  `2 ^ (N − k)` (`card_filter_superset`), and the number making it blue is also
  `2 ^ (N − k)` (`card_filter_disjoint`, via the complement involution
  `A ↦ univ \ A`);
* a union bound over the `|H|` edges shows that if `|H| < 2^{k-1}` then the number
  of *bad* colourings is `< 2^N`, so a proper colouring exists.

## Main results

* `PropertyB.card_filter_superset`, `PropertyB.card_filter_disjoint` — the two
  Boolean-lattice interval counts.
* `PropertyB.card_monochromatic_le` — for one edge, at most `2·2^{N−k}` colourings
  make it monochromatic.
* `PropertyB.twoColorable_of_card_lt` — **Property B**: a `k`-uniform hypergraph
  with `< 2^{k-1}` edges is two-colourable.
* `PropertyB.card_ge_of_not_twoColorable` — contrapositive: a non-two-colourable
  `k`-uniform hypergraph has at least `2^{k-1}` edges (`m(k) ≥ 2^{k-1}`).
* `PropertyB.twoColorable_of_three_uniform_card_lt_four` — a clean instance:
  every `3`-uniform hypergraph with at most `3` edges is two-colourable.
* `PropertyB.twoColorable_single_edge` — every single-edge hypergraph with a
  nonempty edge is two-colourable.
-/

import Mathlib

open scoped Classical
open Finset

namespace PropertyB

/-! ## Boolean-lattice counting lemmas (reused from the Ramsey development) -/

/-- Interval cardinality: the number of subsets of a ground set `Gr` that contain
a fixed `S ⊆ Gr` is `2 ^ (|Gr| − |S|)`. -/
lemma card_filter_superset {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => S ⊆ A)).card = 2 ^ (Gr.card - S.card) := by
  rw [show (2:ℕ)^(Gr.card - S.card) = ((Gr \ S).powerset).card by
        rw [Finset.card_powerset, Finset.card_sdiff_of_subset h]]
  apply Finset.card_bij (fun A _ => A \ S)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA
    simp only [Finset.mem_powerset]
    exact Finset.sdiff_subset_sdiff hA.1 (le_refl S)
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : (A \ S) ∪ S = (B \ S) ∪ S := by rw [heq]
    rwa [Finset.sdiff_union_of_subset hA.2, Finset.sdiff_union_of_subset hB.2] at this
  · intro B hB
    simp only [Finset.mem_powerset] at hB
    refine ⟨B ∪ S, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.union_subset (hB.trans (Finset.sdiff_subset)) h, Finset.subset_union_right⟩
    · rw [Finset.union_sdiff_right]
      apply Finset.sdiff_eq_self_of_disjoint
      exact (Finset.disjoint_left.2 (fun x hxB hxS => ((Finset.mem_sdiff.1 (hB hxB)).2) hxS))

/-- The number of subsets of `Gr` disjoint from a fixed `S ⊆ Gr` is also
`2 ^ (|Gr| − |S|)` (complement involution `A ↦ Gr \ A`). -/
lemma card_filter_disjoint {α : Type*} [DecidableEq α] (Gr S : Finset α) (h : S ⊆ Gr) :
    (Gr.powerset.filter (fun A => Disjoint S A)).card = 2 ^ (Gr.card - S.card) := by
  rw [← card_filter_superset Gr S h]
  apply Finset.card_bij (fun A _ => Gr \ A)
  · intro A hA
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA ⊢
    refine ⟨Finset.sdiff_subset, ?_⟩
    intro x hxS
    rw [Finset.mem_sdiff]
    exact ⟨h hxS, fun hxA => (Finset.disjoint_left.1 hA.2) hxS hxA⟩
  · intro A hA B hB heq
    simp only [Finset.mem_filter, Finset.mem_powerset] at hA hB
    have : Gr \ (Gr \ A) = Gr \ (Gr \ B) := by rw [heq]
    rwa [Finset.sdiff_sdiff_eq_self hA.1, Finset.sdiff_sdiff_eq_self hB.1] at this
  · intro B hB
    simp only [Finset.mem_filter, Finset.mem_powerset] at hB
    refine ⟨Gr \ B, ?_, ?_⟩
    · simp only [Finset.mem_filter, Finset.mem_powerset]
      refine ⟨Finset.sdiff_subset, ?_⟩
      rw [Finset.disjoint_right]
      intro x hx
      rw [Finset.mem_sdiff] at hx
      exact fun hxS => hx.2 (hB.2 hxS)
    · rw [Finset.sdiff_sdiff_eq_self hB.1]

/-! ## Colourings and Property B -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A colouring `R` (the red vertex set) is **proper** for the hypergraph `H`
iff no edge of `H` is monochromatic: every edge has both a red and a blue vertex,
i.e. it is neither `⊆ R` (all red) nor disjoint from `R` (all blue). -/
def IsProperColoring (H : Finset (Finset V)) (R : Finset V) : Prop :=
  ∀ e ∈ H, ¬ e ⊆ R ∧ ¬ Disjoint e R

/-- The hypergraph `H` is **two-colourable** (has Property B) iff some colouring
is proper. -/
def TwoColorable (H : Finset (Finset V)) : Prop :=
  ∃ R : Finset V, IsProperColoring H R

/-
For a fixed edge `e` (a subset of the vertex set), the number of colourings
(subsets `R ⊆ univ`) that make `e` monochromatic — all red or all blue — is at
most `2 ^ (N − k) + 2 ^ (N − k)`, where `N = |V|` and `k = |e|`.
-/
lemma card_monochromatic_le (e : Finset V) :
    ((Finset.univ.powerset.filter (fun R => e ⊆ R ∨ Disjoint e R)).card)
      ≤ 2 ^ (Fintype.card V - e.card) + 2 ^ (Fintype.card V - e.card) := by
  rw [ Finset.filter_or ];
  refine' le_trans ( Finset.card_union_le _ _ ) ( add_le_add _ _ );
  · convert card_filter_superset Finset.univ e ( Finset.subset_univ e ) |> le_of_eq;
  · convert card_filter_disjoint Finset.univ e ( Finset.subset_univ e ) |> le_of_eq

/-! ## Property B: sparse hypergraphs are two-colourable -/

/-
**Erdős' Property B theorem.** If `H` is a `k`-uniform hypergraph on the finite
vertex type `V` with fewer than `2^{k-1}` edges, then `H` is two-colourable: there
is a red/blue colouring of the vertices with no monochromatic edge.
-/
theorem twoColorable_of_card_lt (k : ℕ) (H : Finset (Finset V))
    (huniform : ∀ e ∈ H, e.card = k) (hlt : H.card < 2 ^ (k - 1)) :
    TwoColorable H := by
  by_contra h;
  obtain ⟨R, hR⟩ : ∃ R : Finset V, R ∈ Finset.powerset (Finset.univ : Finset V) ∧ ∀ e ∈ H, ¬ e ⊆ R ∧ ¬ Disjoint e R := by
    -- Let $Gr = \text{univ}$.
    set Gr : Finset V := Finset.univ with hGr_def;
    have hGr_card : Gr.card = Fintype.card V := by
      rfl;
    have h_sum_lt : ∑ e ∈ H, (Gr.powerset.filter (fun R => e ⊆ R ∨ Disjoint e R)).card < 2 ^ Gr.card := by
      refine' lt_of_le_of_lt ( Finset.sum_le_sum fun e he => card_monochromatic_le e ) _;
      rcases k with ( _ | k ) <;> simp_all +decide;
      rw [ show Fintype.card V = ( Fintype.card V - ( k + 1 ) ) + ( k + 1 ) by rw [ Nat.sub_add_cancel ( show k + 1 ≤ Fintype.card V from by
                                                                                                          obtain ⟨ e, he ⟩ := Finset.nonempty_of_ne_empty ( show H ≠ ∅ from fun h' => h ⟨ ∅, by simp +decide [ h', IsProperColoring ] ⟩ ) ; exact huniform e he ▸ Finset.card_le_univ _; ) ] ] ; ring_nf;
      simp +decide [ add_tsub_cancel_left ] ; gcongr;
    contrapose! h_sum_lt;
    have h_sum_lt : Gr.powerset ⊆ Finset.biUnion H (fun e => Gr.powerset.filter (fun R => e ⊆ R ∨ Disjoint e R)) := by
      grind;
    have := Finset.card_mono h_sum_lt;
    exact le_trans ( by rw [ Finset.card_powerset ] ) ( this.trans ( Finset.card_biUnion_le ) );
  exact h ⟨ R, hR.2 ⟩

/-- **`m(k) ≥ 2^{k-1}` (contrapositive form).** Any `k`-uniform hypergraph that is
*not* two-colourable must have at least `2^{k-1}` edges. Equivalently, the minimum
number `m(k)` of edges in a non-two-colourable `k`-uniform hypergraph satisfies
`m(k) ≥ 2^{k-1}`. -/
theorem card_ge_of_not_twoColorable (k : ℕ) (H : Finset (Finset V))
    (huniform : ∀ e ∈ H, e.card = k) (hbad : ¬ TwoColorable H) :
    2 ^ (k - 1) ≤ H.card := by
  by_contra hlt
  exact hbad (twoColorable_of_card_lt k H huniform (not_le.mp hlt))

/-! ## Concrete instances -/

omit [Fintype V] [DecidableEq V] in
/-- A single-edge hypergraph whose edge has at least two vertices is two-colourable:
colour one vertex of the edge red and everything else blue. (At least two vertices
is necessary: a size-`1` edge is always monochromatic.) -/
theorem twoColorable_single_edge (e : Finset V) (he : 2 ≤ e.card) :
    TwoColorable ({e} : Finset (Finset V)) := by
  -- Since `2 ≤ e.card`, `e` has at least two distinct vertices; in particular `e` is nonempty, so pick `v ∈ e`.
  obtain ⟨v, hv⟩ : ∃ v, v ∈ e := by
    exact Finset.card_pos.mp ( pos_of_gt he );
  obtain ⟨ w, hw, h ⟩ := Finset.exists_mem_ne he v; use { w } ; simp_all +decide;
  intro e' he'; aesop;

/-- **`m(3) ≥ 4`.** Every `3`-uniform hypergraph with at most `3` edges is
two-colourable. (The Fano plane, with `7` edges, is the minimal non-two-colourable
`3`-uniform hypergraph, so this bound `m(3) ≥ 4` is not tight; the true value is
`m(3) = 7`. It is the clean exponential consequence of the general bound.) -/
theorem twoColorable_of_three_uniform_card_lt_four (H : Finset (Finset V))
    (huniform : ∀ e ∈ H, e.card = 3) (hcard : H.card ≤ 3) :
    TwoColorable H := by
  apply twoColorable_of_card_lt 3 H huniform
  norm_num
  omega

end PropertyB