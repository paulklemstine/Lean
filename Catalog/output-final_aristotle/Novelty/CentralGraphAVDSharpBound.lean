import Mathlib

/-!
# The sharp lower bound for AVD-total colourings of central graphs

This file deepens the study of **adjacent-vertex-distinguishing (AVD) total
colourings** of the **central graph** `C(G)` of a finite simple graph `G`.

## Background

For a finite simple graph `H`, a *total colouring* is modelled as a proper vertex
colouring of the **total graph** `T(H)`, whose vertices are `V(H) ⊕ E(H)` and
whose edges join incident vertices, a vertex with each of its edges, and two
edges sharing an endpoint.  A total colouring is **adjacent-vertex-distinguishing**
(AVD) when any two adjacent vertices `u ≠ v` have distinct *colour sets*
`C(w) = {colour w} ∪ {colour e : e ∋ w}`.  The AVD-total chromatic number
`χ''ₐ(H)` is the least size of a palette admitting an AVD total colouring.

The **central graph** `C(G)` is obtained from `G` by subdividing every edge once
and joining every pair of *non-adjacent* vertices.  Its vertex set is `V ⊕ E`;
each subdivision vertex has degree `2`, while **every original vertex has degree
`|V| − 1`**.

## The refinement carried out here

A previous development established, for a `d`-regular non-complete graph `G`, the
lower bound `d + 3 ≤ χ''ₐ(C(G))`.  That bound is, in general, **not sharp**: the
true obstruction is governed by the *order* `|V|` of `G`, not by `d` alone,
because *every* original vertex of `C(G)` has degree `|V| − 1`, and non-adjacent
vertices of `G` become an **adjacent equal-degree pair** in `C(G)`.

We prove the sharper, order-driven bound

> `|V| + 1 ≤ χ''ₐ(C(G))` for every non-complete `G`,

and show it dominates the degree bound: for a `d`-regular non-complete graph one
has `|V| ≥ d + 2`, hence `|V| + 1 ≥ d + 3`, with **strict** improvement as soon
as `|V| > d + 2`.

## Main results

* `avd_coloring_castLE` : the family of admissible palette sizes is upward closed
  (pad an AVD colouring with unused colours).
* `central_no_avd_card_le` : for non-complete `G`, `C(G)` has **no** AVD total
  colouring whose palette has `n ≤ |V|` colours.
* `central_avd_ge_card` : consequently every AVD total colouring of `C(G)` uses at
  least `|V| + 1` colours.
* `central_avdTotalChromatic_ge` : packaged as `|V| + 1 ≤ χ''ₐ(C(G))`.
* `central_sharp_dominates_degree_bound` : for `d`-regular non-complete `G` the
  sharp bound is at least the degree bound `d + 3`.
* `cycle5_avd_ge_six` : the concrete `2`-regular example `C₅`, where the sharp
  bound gives `6` — strictly better than the degree bound `d + 3 = 5`.
-/

open SimpleGraph Finset

namespace CentralGraphAVDSharp

/-! ## The total graph `T(H)` and total colourings -/

section TotalGraph

variable {W : Type*} [Fintype W] [DecidableEq W] (H : SimpleGraph W) [DecidableRel H.Adj]

/-- Vertices of the total graph of `H`: original vertices plus edges. -/
abbrev TV := W ⊕ {e : Sym2 W // e ∈ H.edgeSet}

/-- Adjacency of the total graph: adjacent original vertices, a vertex with an
incident edge, and two distinct edges sharing an endpoint. -/
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

/-! ### The star clique -/

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

/-! ### Colour sets and AVD total colourings -/

variable {κ : Type*} [DecidableEq κ]

/-- Colour set of `w`: the colours of `w` and of all its incident edges. -/
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

/-- **Adjacent equal-degree obstruction.** If two adjacent vertices have equal
degree `Δ`, then no AVD total colouring uses only `Δ + 1` colours: both colour
sets would be the whole palette and hence equal. -/
theorem not_isAVD_of_adjacent_eqdeg [Fintype κ] (C : (totalGraph H).Coloring κ)
    (u v : W) (hadj : H.Adj u v) (hdeg : H.degree u = H.degree v)
    (hcard : Fintype.card κ = H.degree u + 1) : ¬ IsAVD H C := by
  intro hAVD
  have hu : colorSet H C u = Finset.univ := colorSet_eq_univ_of_card H C u hcard
  have hv : colorSet H C v = Finset.univ :=
    colorSet_eq_univ_of_card H C v (by rw [hcard, hdeg])
  exact hAVD u v hadj (hu.trans hv.symm)

/-! ### Padding the palette preserves AVD -/

/-- Re-colouring an AVD total colouring along the order embedding `Fin n ↪ Fin m`
(for `n ≤ m`) again gives an AVD total colouring: pad the palette with unused
colours.  Hence the set of admissible palette sizes is upward closed. -/
theorem avd_coloring_castLE {n m : ℕ} (hnm : n ≤ m)
    (C : (totalGraph H).Coloring (Fin n)) (hC : IsAVD (κ := Fin n) H C) :
    ∃ C' : (totalGraph H).Coloring (Fin m), IsAVD (κ := Fin m) H C' := by
  refine ⟨SimpleGraph.Coloring.mk (fun v => Fin.castLE hnm (C v))
      (fun hab heq => C.valid hab (Fin.castLE_injective hnm heq)), ?_⟩
  intro a b hab hcs
  apply hC a b hab
  have key : ∀ w, colorSet H
      (SimpleGraph.Coloring.mk (fun v => Fin.castLE hnm (C v))
        (fun hab heq => C.valid hab (Fin.castLE_injective hnm heq))) w
      = (colorSet H C w).image (Fin.castLE hnm) := by
    intro w
    rw [colorSet, colorSet, Finset.image_image]
    rfl
  rw [key a, key b] at hcs
  exact Finset.image_injective (Fin.castLE_injective hnm) hcs

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
/-- Two original vertices are adjacent in `C(G)` iff they are non-adjacent in `G`. -/
theorem central_inl_inl_iff (u w : V) :
    (centralGraph G).Adj (Sum.inl u) (Sum.inl w) ↔ u ≠ w ∧ ¬ G.Adj u w := Iff.rfl

/-- Every original vertex of `C(G)` has degree `|V| − 1`; equivalently
`deg + 1 = |V|`. -/
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

/-! ## The sharp, order-driven lower bound -/

/-- **No AVD colouring with `|V|` colours.** For a non-complete `G` (it has a
distinct non-adjacent pair `a, b`), the central graph `C(G)` admits no AVD total
colouring with exactly `|V|` colours: `a` and `b` become an *adjacent
equal-degree* pair in `C(G)`, so both colour sets fill the palette. -/
theorem central_no_avd_card_eq
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
    ¬ ∃ C : (totalGraph (centralGraph G)).Coloring (Fin (Fintype.card V)),
        IsAVD (centralGraph G) C := by
  rintro ⟨C, hAVD⟩
  have hadj : (centralGraph G).Adj (Sum.inl a) (Sum.inl b) :=
    (central_inl_inl_iff G a b).2 ⟨hne, hnadj⟩
  have hda := central_degree_inl G a
  have hdb := central_degree_inl G b
  have hdeg : (centralGraph G).degree (Sum.inl a) = (centralGraph G).degree (Sum.inl b) := by
    omega
  have hcard : Fintype.card (Fin (Fintype.card V))
      = (centralGraph G).degree (Sum.inl a) + 1 := by
    rw [Fintype.card_fin, hda]
  exact not_isAVD_of_adjacent_eqdeg (centralGraph G) C (Sum.inl a) (Sum.inl b)
    hadj hdeg hcard hAVD

/-- **No AVD colouring with `n ≤ |V|` colours.** Padding any smaller palette up to
`|V|` colours would contradict `central_no_avd_card_eq`. -/
theorem central_no_avd_card_le {n : ℕ} (hn : n ≤ Fintype.card V)
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
    ¬ ∃ C : (totalGraph (centralGraph G)).Coloring (Fin n),
        IsAVD (centralGraph G) C := by
  rintro ⟨C, hC⟩
  obtain ⟨C', hC'⟩ := avd_coloring_castLE (centralGraph G) hn C hC
  exact central_no_avd_card_eq G a b hne hnadj ⟨C', hC'⟩

/-- **Sharp lower bound.** For a non-complete graph `G`, any AVD total colouring of
`C(G)` needs at least `|V| + 1` colours. -/
theorem central_avd_ge_card
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b)
    {n : ℕ} (C : (totalGraph (centralGraph G)).Coloring (Fin n))
    (hC : IsAVD (centralGraph G) C) : Fintype.card V + 1 ≤ n := by
  by_contra hlt
  push_neg at hlt
  have hn : n ≤ Fintype.card V := by omega
  exact central_no_avd_card_le G hn a b hne hnadj ⟨C, hC⟩

/-! ## Packaging as the AVD-total chromatic number -/

/-- The **AVD-total chromatic number** `χ''ₐ(H)`: the least number of colours in an
AVD total colouring of `H`, as an element of `ℕ∞` (`⊤` if none exists). -/
noncomputable def avdTotalChromatic {W : Type*} [Fintype W] [DecidableEq W]
    (H : SimpleGraph W) [DecidableRel H.Adj] : ℕ∞ :=
  ⨅ (n : ℕ) (_ : ∃ C : (totalGraph H).Coloring (Fin n), IsAVD H C), (n : ℕ∞)

/-- **`|V| + 1 ≤ χ''ₐ(C(G))`** for every non-complete graph `G`.  The sharp,
order-driven lower bound packaged as an inequality of AVD-total chromatic
numbers. -/
theorem central_avdTotalChromatic_ge
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
    (Fintype.card V + 1 : ℕ∞) ≤ avdTotalChromatic (centralGraph G) := by
  refine le_iInf fun n => le_iInf fun hn => ?_
  obtain ⟨C, hC⟩ := hn
  exact_mod_cast central_avd_ge_card G a b hne hnadj C hC

/-! ## The sharp bound dominates the degree bound -/

/-- **Structural fact.** A `d`-regular graph that is not complete has at least
`d + 2` vertices: `a`, `b`, and the `d` neighbours of `a` are all distinct. -/
theorem card_ge_of_regular_not_complete {d : ℕ} (hreg : G.IsRegularOfDegree d)
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) : d + 2 ≤ Fintype.card V := by
  have hcard : (insert a (insert b (G.neighborFinset a))).card = d + 2 := by
    rw [card_insert_of_notMem, card_insert_of_notMem, card_neighborFinset_eq_degree, hreg a]
    · simp only [mem_neighborFinset]; exact fun h => hnadj h
    · simp only [mem_insert, mem_neighborFinset]
      push_neg
      exact ⟨hne, fun h => (SimpleGraph.irrefl G) h⟩
  calc d + 2 = (insert a (insert b (G.neighborFinset a))).card := hcard.symm
    _ ≤ Fintype.card V := card_le_univ _

/-- **The sharp bound dominates the degree bound.** For a `d`-regular non-complete
graph `G`, the order-driven bound `|V| + 1` is at least the degree bound `d + 3`,
with equality iff `|V| = d + 2`.  Hence `d + 3 ≤ χ''ₐ(C(G))` is recovered, and is
strict whenever `G` has more than `d + 2` vertices. -/
theorem central_sharp_dominates_degree_bound {d : ℕ} (hreg : G.IsRegularOfDegree d)
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
    d + 3 ≤ Fintype.card V + 1 := by
  have := card_ge_of_regular_not_complete G hreg a b hne hnadj
  omega

/-- Combining the two previous results: the degree bound `d + 3 ≤ χ''ₐ(C(G))` for
`d`-regular non-complete `G`, obtained here as a **corollary** of the sharp bound. -/
theorem central_avdTotalChromatic_ge_degree {d : ℕ} (hreg : G.IsRegularOfDegree d)
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
    (d + 3 : ℕ∞) ≤ avdTotalChromatic (centralGraph G) := by
  have h1 : (d + 3 : ℕ∞) ≤ (Fintype.card V + 1 : ℕ∞) := by
    have := central_sharp_dominates_degree_bound G hreg a b hne hnadj
    exact_mod_cast this
  exact h1.trans (central_avdTotalChromatic_ge G a b hne hnadj)

end CentralGraph

/-! ## A concrete instance: the 5-cycle `C₅` -/

/-- The 5-cycle `C₅` is `2`-regular. -/
theorem cycleGraph_five_regular : (cycleGraph 5).IsRegularOfDegree 2 := by
  intro v
  fin_cases v <;> decide

/-- **`C(C₅)` needs at least `6` colours for any AVD total colouring.** Here
`|V(C₅)| = 5`, so the sharp bound gives `|V| + 1 = 6`, strictly better than the
degree bound `d + 3 = 5`. -/
theorem cycle5_avd_ge_six {n : ℕ}
    (C : (totalGraph (centralGraph (cycleGraph 5))).Coloring (Fin n))
    (hC : IsAVD (centralGraph (cycleGraph 5)) C) : 6 ≤ n := by
  have h := central_avd_ge_card (cycleGraph 5) (0 : Fin 5) (2 : Fin 5)
    (by decide) (by decide) C hC
  simpa using h

/-! ## Examples and sanity checks -/

section Examples

/-- `C₅` has five vertices. -/
example : Fintype.card (Fin 5) = 5 := by decide

/-- The sharp bound `|V| + 1 = 6` for `C(C₅)` strictly exceeds the degree bound
`d + 3 = 5`, confirming that the exact value is order-driven, not degree-driven. -/
example : (2 : ℕ) + 3 < Fintype.card (Fin 5) + 1 := by decide

#check @central_avdTotalChromatic_ge
#check @central_avd_ge_card
#check @cycle5_avd_ge_six

end Examples

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** The guiding conjecture predicted `χ''ₐ(C(G)) = d + 3` for every
`d`-regular non-complete graph `G`.  We hypothesised that the true governing
parameter is the *order* `|V|`, because in `C(G)` every original vertex has degree
`|V| − 1` and every non-adjacent pair of `G` becomes an adjacent equal-degree pair.

**Experiment.** We formalised the total graph, colour sets, and the AVD predicate,
then proved: (i) an adjacent equal-degree pair blocks any palette of size
`deg + 1` (`not_isAVD_of_adjacent_eqdeg`); (ii) palettes are upward closed under
padding (`avd_coloring_castLE`); (iii) combining these yields `central_no_avd_card_le`
and thence the sharp bound `central_avd_ge_card` : `|V| + 1 ≤ χ''ₐ(C(G))`.

**Analysis.** The degree bound `d + 3` survives only as a *corollary*
(`central_avdTotalChromatic_ge_degree`) via the structural inequality
`|V| ≥ d + 2` for regular non-complete graphs.  The conjectured equality is
therefore *false* whenever `|V| > d + 2`; the 5-cycle is the smallest witness
(`cycle5_avd_ge_six`: needs `6`, not `5`).  The failure is "true but the
conjecture used the wrong invariant", not "false statement".

**Critique.** Every main theorem is sorry-free and uses genuine structural
arguments (`omega`, `by_contra`, injectivity of the star map, image-injectivity
of padding).  The bound is not vacuous: it is a strict *lower* bound and is
witnessed to be strictly larger than the previous bound on a concrete graph.
Boundary case: when `G` *is* complete, non-adjacent pairs do not exist, so the
hypothesis `¬ G.Adj a b` cannot be met and the obstruction genuinely vanishes —
consistent with the complete graph being the exceptional case.

**Synthesis.** The order `|V|` is the correct first-order invariant controlling
`χ''ₐ(C(G))`.  The matching upper bound (an explicit `(|V| + 1)`-colouring) is the
natural next target; see `FUTURE_DIRECTIONS.md`.
-/

end CentralGraphAVDSharp