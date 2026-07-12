import Mathlib

/-!
# Adjacent-vertex-distinguishing total colourings of central graphs of regular graphs

This file develops, from scratch and self-contained on top of Mathlib, a small
theory of **total colourings** and **adjacent-vertex-distinguishing (AVD) total
colourings**, and applies it to the **central graph** `C(G)` of a graph `G`.

## Background

For a finite simple graph `H`:

* A **total colouring** assigns colours to *both* vertices and edges so that
  incident/adjacent objects receive distinct colours.  We model it as an ordinary
  proper vertex colouring of the **total graph** `T(H)` whose vertex set is
  `V(H) ⊕ E(H)`.
* The **total chromatic number** `χ''(H)` is `chromaticNumber (T H)`.
* A total colouring is **adjacent-vertex-distinguishing** (AVD) when any two
  adjacent vertices `u ≠ v` have distinct *colour sets*
  `C(w) = {colour w} ∪ {colour e : e ∋ w}`.  The least number of colours in an AVD
  total colouring is `χ''ₐ(H)`.

The **central graph** `C(G)` is obtained from `G` by subdividing every edge once
and joining every pair of *non-adjacent* vertices of `G`.  Its vertex set is
`V(G) ⊕ E(G)`; the subdivision vertices have degree `2`, while **every original
vertex has degree `|V(G)| - 1`** (it reaches every other vertex either directly —
through a new complement edge — or via the subdivision vertex of a real edge).

## Main results

* `degree_add_one_le_chromatic` : `deg_H(w) + 1 ≤ χ''(H)` for every vertex `w`
  (the star at `w` is a clique of size `deg w + 1` in the total graph).
* `colorSet_eq_univ_of_card` : a proper total colouring with exactly `deg w + 1`
  colours uses *all* of them at `w`.
* `not_isAVD_of_adjacent_eqdeg` : if two adjacent vertices have equal degree `Δ`
  then no AVD total colouring uses only `Δ + 1` colours; hence `χ''ₐ ≥ Δ + 2`.
* `central_degree_inr` (`= 2`) and `central_degree_inl` (`+ 1 = |V|`) : the degree
  structure of `C(G)`.
* `central_no_avd_of_not_complete` : if `G` is **not** complete, then `C(G)` has no
  AVD total colouring with `|V(G)|` colours, i.e. `χ''ₐ(C(G)) ≥ |V(G)| + 1`.
* `central_complete_inl_indep` : in `C(Kₙ)` the (maximum-degree) original vertices
  form an independent set — the structural reason the complete case is different.

## Remark on the guiding conjecture

The mission conjecture states `χ''ₐ(C(G)) = d + 3` for every `d`-regular
non-complete `G`.  Since every original vertex of `C(G)` has degree `|V(G)| - 1`,
`not_isAVD_of_adjacent_eqdeg` gives the unconditional lower bound
`χ''ₐ(C(G)) ≥ |V(G)| + 1`, which already **exceeds** `d + 3` as soon as
`|V(G)| > d + 2` (e.g. the 2-regular cycle `C₅`, where the bound gives `6 > 5`).
So the exact value is governed by `|V(G)|`, not by `d` alone; see
`FUTURE_DIRECTIONS.md`.
-/

open SimpleGraph Finset

namespace CentralGraphAVD

/-! ## The total graph `T(H)` and total colourings -/

section TotalGraph

variable {W : Type*} [Fintype W] [DecidableEq W] (H : SimpleGraph W) [DecidableRel H.Adj]

/-- Vertices of the total graph of `H`: original vertices plus edges. -/
abbrev TV := W ⊕ {e : Sym2 W // e ∈ H.edgeSet}

/-- Adjacency of the total graph: adjacent original vertices, a vertex with an
incident edge, and two edges sharing an endpoint. -/
def totalAdj : TV H → TV H → Prop
  | Sum.inl a, Sum.inl b => H.Adj a b
  | Sum.inl a, Sum.inr e => a ∈ (e : Sym2 W)
  | Sum.inr e, Sum.inl a => a ∈ (e : Sym2 W)
  | Sum.inr e, Sum.inr f => e ≠ f ∧ ∃ x, x ∈ (e : Sym2 W) ∧ x ∈ (f : Sym2 W)

/-- The **total graph** `T(H)`. -/
def totalGraph : SimpleGraph (TV H) where
  Adj := totalAdj H
  symm := by
    rintro (a|e) (b|f) h <;> simp only [totalAdj] at h ⊢
    · exact h.symm
    · exact h
    · exact h
    · exact ⟨h.1.symm, by obtain ⟨x, hx1, hx2⟩ := h.2; exact ⟨x, hx2, hx1⟩⟩
  loopless := ⟨fun x => by
    cases x with
    | inl a => simp [totalAdj]
    | inr e => simp [totalAdj]⟩

instance : DecidableRel (totalGraph H).Adj := by
  rintro (a|e) (b|f) <;> unfold totalGraph totalAdj <;> infer_instance

/-! ### The star clique and the `Δ + 1` lower bound -/

/-- Index type of the star at `w`: `w` itself (`none`) together with each edge
incident to `w` (`some e`). -/
abbrev starIdx (w : W) := Option {e : Sym2 W // e ∈ H.incidenceFinset w}

/-- The star at `w` as a family of total-graph vertices. -/
def starMap (w : W) : starIdx H w → TV H
  | none => Sum.inl w
  | some e => Sum.inr ⟨e.1, ((mem_incidenceFinset H w e.1).1 e.2).1⟩

/-- The star at `w` is a clique of the total graph. -/
theorem star_pairwise (w : W) :
    Pairwise fun i j => (totalGraph H).Adj (starMap H w i) (starMap H w j) := by
  rintro (_|⟨e,he⟩) (_|⟨f,hf⟩) hij <;> simp only [starMap, totalGraph, totalAdj]
  · exact absurd rfl hij
  · exact ((mem_incidenceFinset H w f).1 hf).2
  · exact ((mem_incidenceFinset H w e).1 he).2
  · refine ⟨?_, w, ((mem_incidenceFinset H w e).1 he).2, ((mem_incidenceFinset H w f).1 hf).2⟩
    intro h; apply hij; have hef : e = f := congrArg Subtype.val h; subst hef; rfl

/-- The star at `w` has `deg w + 1` elements. -/
theorem card_starIdx (w : W) : Nat.card (starIdx H w) = H.degree w + 1 := by
  rw [starIdx, Nat.card_eq_fintype_card, Fintype.card_option, Fintype.card_coe,
    card_incidenceFinset_eq_degree]

/-- **Lower bound for the total chromatic number**: `deg w + 1 ≤ χ''(H)`. -/
theorem degree_add_one_le_chromatic (w : W) :
    (H.degree w + 1 : ℕ∞) ≤ (totalGraph H).chromaticNumber := by
  have := le_chromaticNumber_of_pairwise_adj (G := totalGraph H)
    (n := H.degree w + 1) (ι := starIdx H w) (f := starMap H w)
    (by rw [card_starIdx]) (star_pairwise H w)
  exact_mod_cast this

/-! ### Colour sets and AVD total colourings -/

variable {κ : Type*} [DecidableEq κ]

/-- Colour set of `w` in a total colouring: the colours of `w` and of all its
incident edges. -/
def colorSet (C : (totalGraph H).Coloring κ) (w : W) : Finset κ :=
  Finset.image (fun i => C (starMap H w i)) Finset.univ

/-- A total colouring is **adjacent-vertex-distinguishing** if adjacent vertices
have distinct colour sets. -/
def IsAVD (C : (totalGraph H).Coloring κ) : Prop :=
  ∀ a b, H.Adj a b → colorSet H C a ≠ colorSet H C b

omit [DecidableEq κ] in
/-- On the star at `w` the colours are pairwise distinct. -/
theorem star_comp_injective (C : (totalGraph H).Coloring κ) (w : W) :
    Function.Injective (fun i => C (starMap H w i)) := by
  intro i j hij
  by_contra hne
  exact (C.valid (star_pairwise H w hne)) hij

/-- With exactly `deg w + 1` colours, a proper total colouring uses **all** of
them at `w`. -/
theorem colorSet_eq_univ_of_card [Fintype κ] (C : (totalGraph H).Coloring κ)
    (w : W) (hcard : Fintype.card κ = H.degree w + 1) :
    colorSet H C w = Finset.univ := by
  apply Finset.eq_univ_of_card
  rw [colorSet, Finset.card_image_of_injective _ (star_comp_injective H C w),
    Finset.card_univ, hcard, ← Nat.card_eq_fintype_card]
  exact card_starIdx H w

/-- **Adjacent equal-degree obstruction.**  If two adjacent vertices have equal
degree `Δ`, then no AVD total colouring uses only `Δ + 1` colours: both colour
sets would be the whole palette and hence equal.  Equivalently `χ''ₐ ≥ Δ + 2`. -/
theorem not_isAVD_of_adjacent_eqdeg [Fintype κ] (C : (totalGraph H).Coloring κ)
    (u v : W) (hadj : H.Adj u v) (hdeg : H.degree u = H.degree v)
    (hcard : Fintype.card κ = H.degree u + 1) : ¬ IsAVD H C := by
  intro hAVD
  have hu : colorSet H C u = Finset.univ := colorSet_eq_univ_of_card H C u hcard
  have hv : colorSet H C v = Finset.univ :=
    colorSet_eq_univ_of_card H C v (by rw [hcard, hdeg])
  exact hAVD u v hadj (hu.trans hv.symm)

end TotalGraph

/-! ## The central graph `C(G)` -/

section CentralGraph

variable {V : Type*} [Fintype V] [DecidableEq V] (G : SimpleGraph V) [DecidableRel G.Adj]

/-- Vertices of the central graph: original vertices plus edges (subdivision
vertices). -/
abbrev CV := V ⊕ {e : Sym2 V // e ∈ G.edgeSet}

/-- Adjacency of the central graph: original vertices are joined iff they are
*non-adjacent* in `G`; a subdivision vertex is joined to the two endpoints of its
edge; subdivision vertices are pairwise non-adjacent. -/
def centralAdj : CV G → CV G → Prop
  | Sum.inl u, Sum.inl w => u ≠ w ∧ ¬ G.Adj u w
  | Sum.inl u, Sum.inr e => u ∈ (e : Sym2 V)
  | Sum.inr e, Sum.inl u => u ∈ (e : Sym2 V)
  | Sum.inr _, Sum.inr _ => False

/-- The **central graph** `C(G)`. -/
def centralGraph : SimpleGraph (CV G) where
  Adj := centralAdj G
  symm := by
    rintro (a|e) (b|f) h <;> simp only [centralAdj] at h ⊢
    · exact ⟨(Ne.symm h.1), fun hh => h.2 hh.symm⟩
    · exact h
    · exact h
  loopless := ⟨fun x => by
    cases x with
    | inl a => simp [centralAdj]
    | inr e => simp [centralAdj]⟩

instance : DecidableRel (centralGraph G).Adj := by
  rintro (a|e) (b|f) <;> unfold centralGraph centralAdj <;> infer_instance

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Subdivision vertices are pairwise non-adjacent in `C(G)`. -/
theorem central_inr_inr (e f : {e : Sym2 V // e ∈ G.edgeSet}) :
    ¬ (centralGraph G).Adj (Sum.inr e) (Sum.inr f) := by
  simp [centralGraph, centralAdj]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Two original vertices are adjacent in `C(G)` iff they are non-adjacent in `G`. -/
theorem central_inl_inl_iff (u w : V) :
    (centralGraph G).Adj (Sum.inl u) (Sum.inl w) ↔ u ≠ w ∧ ¬ G.Adj u w := Iff.rfl

/-- Every subdivision vertex of `C(G)` has degree exactly `2`. -/
theorem central_degree_inr (e : {e : Sym2 V // e ∈ G.edgeSet}) :
    (centralGraph G).degree (Sum.inr e) = 2 := by
  obtain ⟨e, he⟩ := e
  induction e using Sym2.ind with
  | _ a b =>
    rw [mem_edgeSet] at he
    have hab : a ≠ b := he.ne
    have hnf : (centralGraph G).neighborFinset (Sum.inr ⟨s(a,b), by rwa [mem_edgeSet]⟩)
        = {Sum.inl a, Sum.inl b} := by
      ext x
      simp only [mem_neighborFinset, mem_insert, mem_singleton]
      cases x with
      | inl u => simp only [centralGraph, centralAdj, Sym2.mem_iff, Sum.inl.injEq]
      | inr f =>
        simp only [centralGraph, centralAdj]
        constructor
        · intro h; exact h.elim
        · rintro (h|h) <;> exact absurd h (by simp)
    rw [SimpleGraph.degree, hnf, card_insert_of_notMem (by simp [hab]), card_singleton]

/-
Every original vertex of `C(G)` has degree `|V(G)| - 1`; equivalently
`deg + 1 = |V(G)|`.  Each original vertex reaches every other vertex either via a
new complement edge (if non-adjacent in `G`) or via the subdivision vertex of a
real edge (if adjacent in `G`).
-/
theorem central_degree_inl (v : V) :
    (centralGraph G).degree (Sum.inl v) + 1 = Fintype.card V := by
  rw [ SimpleGraph.degree ];
  rw [ Finset.card_eq_sum_ones, Fintype.card_eq_sum_ones ];
  rw [ show ( centralGraph G ).neighborFinset ( Sum.inl v ) = Finset.image ( fun w => Sum.inl w ) ( Finset.filter ( fun w => ¬G.Adj v w ) ( Finset.univ.erase v ) ) ∪ Finset.image ( fun e => Sum.inr e ) ( Finset.filter ( fun e => v ∈ e.val ) ( Finset.univ : Finset { e : Sym2 V // e ∈ G.edgeSet } ) ) from ?_, Finset.sum_union ];
  · rw [ Finset.sum_image, Finset.sum_image ] <;> simp +decide [ Finset.filter_erase ];
    rw [ show ( Finset.filter ( fun w => ¬G.Adj v w ) Finset.univ : Finset V ) = Finset.univ \ G.neighborFinset v by ext; simp +decide [ SimpleGraph.neighborFinset ] ] ; simp +decide [ Finset.card_sdiff, SimpleGraph.card_neighborFinset_eq_degree ];
    rw [ show ( Finset.filter ( fun e : { e : Sym2 V // e ∈ G.edgeSet } => v ∈ ( e : Sym2 V ) ) Finset.univ ).card = G.degree v from ?_ ];
    · linarith [ Nat.sub_add_cancel ( show G.degree v ≤ Fintype.card V from G.degree_lt_card_verts v |> Nat.le_of_lt ), Nat.sub_add_cancel ( show 1 ≤ Fintype.card V - G.degree v from Nat.sub_pos_of_lt ( G.degree_lt_card_verts v ) ) ];
    · convert SimpleGraph.card_incidenceFinset_eq_degree G v using 1;
      refine' Finset.card_bij ( fun e _ => e ) _ _ _ <;> simp +decide [ SimpleGraph.incidenceSet ];
      exact fun b hb hv => ⟨ hv, hb ⟩;
  · simp +decide [ Finset.disjoint_left ];
  · ext ⟨ w ⟩ <;> simp +decide [ centralGraph, centralAdj ];
    exact fun _ => by rw [ eq_comm ] ;

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- In the central graph of the complete graph `Kₙ`, the (maximum-degree) original
vertices form an independent set. -/
theorem central_complete_inl_indep (u w : V) :
    ¬ (centralGraph (⊤ : SimpleGraph V)).Adj (Sum.inl u) (Sum.inl w) := by
  rw [central_inl_inl_iff]
  rintro ⟨hne, hnadj⟩
  exact hnadj hne

/-! ## Consequences for `C(G)` -/

/-- **Total chromatic lower bound for central graphs**: `χ''(C(G)) ≥ |V(G)|`. -/
theorem central_chromatic_ge [Nonempty V] :
    (Fintype.card V : ℕ∞) ≤ (totalGraph (centralGraph G)).chromaticNumber := by
  obtain ⟨v⟩ := ‹Nonempty V›
  have h := degree_add_one_le_chromatic (centralGraph G) (Sum.inl v)
  have h2 : (((centralGraph G).degree (Sum.inl v) + 1 : ℕ) : ℕ∞)
      ≤ (totalGraph (centralGraph G)).chromaticNumber := by exact_mod_cast h
  rwa [central_degree_inl G v] at h2

/-- **Main AVD lower bound.**  If `G` is not complete (it has a non-adjacent pair),
then `C(G)` admits no AVD total colouring with `|V(G)|` colours; equivalently
`χ''ₐ(C(G)) ≥ |V(G)| + 1`.  In particular the mission value `d + 3` is exceeded
whenever `|V(G)| > d + 2`. -/
theorem central_no_avd_of_not_complete
    (h : ∃ a b : V, a ≠ b ∧ ¬ G.Adj a b) :
    ¬ ∃ C : (totalGraph (centralGraph G)).Coloring (Fin (Fintype.card V)),
        IsAVD (centralGraph G) C := by
  obtain ⟨a, b, hne, hnadj⟩ := h
  rintro ⟨C, hAVD⟩
  have hadj : (centralGraph G).Adj (Sum.inl a) (Sum.inl b) :=
    (central_inl_inl_iff G a b).2 ⟨hne, hnadj⟩
  have hda : (centralGraph G).degree (Sum.inl a) + 1 = Fintype.card V := central_degree_inl G a
  have hdb : (centralGraph G).degree (Sum.inl b) + 1 = Fintype.card V := central_degree_inl G b
  have hdeg : (centralGraph G).degree (Sum.inl a) = (centralGraph G).degree (Sum.inl b) := by
    omega
  have hcard : Fintype.card (Fin (Fintype.card V))
      = (centralGraph G).degree (Sum.inl a) + 1 := by
    rw [Fintype.card_fin, hda]
  exact not_isAVD_of_adjacent_eqdeg (centralGraph G) C (Sum.inl a) (Sum.inl b)
    hadj hdeg hcard hAVD

/-- **Concrete counterexample to the mission conjecture.**  The 5-cycle `C₅` is
`2`-regular and not complete, so the conjecture predicts
`χ''ₐ(C(C₅)) = d + 3 = 5`.  But `C(C₅)` has **no** AVD total colouring with `5`
colours, hence in fact `χ''ₐ(C(C₅)) ≥ 6 > 5`. -/
theorem cycle5_no_avd_five_colors :
    ¬ ∃ C : (totalGraph (centralGraph (cycleGraph 5))).Coloring
          (Fin (Fintype.card (Fin 5))),
        IsAVD (centralGraph (cycleGraph 5)) C := by
  apply central_no_avd_of_not_complete
  exact ⟨0, 2, by decide, by decide⟩

end CentralGraph

end CentralGraphAVD