import Mathlib

/-!
# A sharp `|V| + 1` lower bound for AVD‑total colourings of central graphs

This file **deepens** the companion development on adjacent‑vertex‑distinguishing
(AVD) total colourings of central graphs.  There the sharp lower bound
`χ''ₐ(C(G)) ≥ d + 3` was established for `d`‑regular graphs that are not complete.

The present file isolates the *true* combinatorial mechanism behind that bound and
shows it needs **no regularity hypothesis at all**.  The decisive feature of the
central graph `C(G)` is that **every original vertex has degree `|V| − 1`**, so any
two original vertices that are non‑adjacent in `G` (hence *adjacent* in `C(G)`)
form an adjacent pair of *equal degree*.  Feeding this pair into the
equal‑degree obstruction yields:

> For every finite simple graph `G` possessing a non‑adjacent pair of distinct
> vertices, every AVD total colouring of `C(G)` uses at least `|V| + 1` colours;
> i.e. `χ''ₐ(C(G)) ≥ |V| + 1`.

Because a `d`‑regular non‑complete graph satisfies `|V| ≥ d + 2`, this recovers and
**strictly strengthens** the previous `d + 3` bound: in fact `d + 3 = (d+2)+1 ≤
|V| + 1`.  For the concrete `5`‑cycle it improves the recorded bound from `≥ 5`
to the exact‑order estimate `≥ 6`, since `|V(C₅)| = 5`.

## Main results

* `central_total_ge_card` : any proper total colouring of `C(G)` needs `≥ |V|`
  colours (the star clique at an original vertex).
* `central_no_avd_card` : `C(G)` has **no** AVD total colouring with exactly `|V|`
  colours, whenever `G` has a non‑adjacent distinct pair.
* `avd_total_ge_card_succ` : consequently every AVD total colouring of `C(G)` uses
  `≥ |V| + 1` colours.
* `avdTotalChromatic_ge_card_succ` : packaged as `|V| + 1 ≤ χ''ₐ(C(G))`.
* `avd_total_ge_regular_sharp` : the regular corollary `d + 3 ≤ n`, now derived
  from the general `|V| + 1` bound.
* `cycle5_avd_ge_six` : the sharpened concrete estimate `χ''ₐ(C(C₅)) ≥ 6`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `d + 3` regular bound is a shadow of a
regularity‑free `|V| + 1` bound, because the AVD obstruction only used that two
adjacent vertices of `C(G)` have equal degree, and *all* original vertices of
`C(G)` share the degree `|V| − 1`.
Experiment (Experimenter): re‑ran the equal‑degree obstruction on the pair
`(inl a, inl b)` for a non‑adjacent pair `a, b` of `G`, with palette `Fin |V|`.
Both colour sets are forced to be the full palette, contradicting AVD.  Padding
closes the palette downward, giving `|V| + 1 ≤ n`.
Analysis (Analyst): the regular hypothesis is *not* load‑bearing for the AVD
step; it only enters to compare `|V|` with `d` via `|V| ≥ d + 2`.  Hence the
bound factors as (structural: `|V| + 1`) ∘ (numeric: `|V| ≥ d + 2`).
Critique (Critic): the bound is vacuous when `G` is complete (no non‑adjacent
pair); we therefore guard every statement by an explicit witness pair
`a ≠ b`, `¬ G.Adj a b`.  The concrete `C₅` estimate is checked to be `≥ 6`,
strictly above the previously recorded `≥ 5`, confirming non‑triviality.
Synthesis (PI): the sharp bound subsumes the regular one and pins the correct
order of growth as `|V|`, not `d`.
-- !-- End Lab Notes -- !--
-/

open SimpleGraph Finset

namespace CentralGraphAVDSharp

/-! ## The total graph `T(H)` and total colourings (self‑contained model) -/

section TotalGraph

variable {W : Type*} [Fintype W] [DecidableEq W] (H : SimpleGraph W) [DecidableRel H.Adj]

/-- Vertices of the total graph of `H`: original vertices plus edges. -/
abbrev TV := W ⊕ {e : Sym2 W // e ∈ H.edgeSet}

/-- Adjacency of the total graph. -/
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

/-- Index type of the star at `w`. -/
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
degree `Δ`, no AVD total colouring uses only `Δ + 1` colours. -/
theorem not_isAVD_of_adjacent_eqdeg [Fintype κ] (C : (totalGraph H).Coloring κ)
    (u v : W) (hadj : H.Adj u v) (hdeg : H.degree u = H.degree v)
    (hcard : Fintype.card κ = H.degree u + 1) : ¬ IsAVD H C := by
  intro hAVD
  have hu : colorSet H C u = Finset.univ := colorSet_eq_univ_of_card H C u hcard
  have hv : colorSet H C v = Finset.univ :=
    colorSet_eq_univ_of_card H C v (by rw [hcard, hdeg])
  exact hAVD u v hadj (hu.trans hv.symm)

/-! ### Padding the palette preserves AVD -/

/-- Re-colouring an AVD total colouring along the order embedding
`Fin n ↪ Fin m` (for `n ≤ m`) again gives an AVD total colouring: pad the
palette with unused colours. -/
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

/-- Vertices of the central graph. -/
abbrev CV := V ⊕ {e : Sym2 V // e ∈ G.edgeSet}

/-- Adjacency of the central graph. -/
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

/-- Every original vertex of `C(G)` has degree `|V| − 1`. -/
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

/-! ## Regularity‑free lower bounds -/

/-- **Total (proper) lower bound.** Any proper total colouring of `C(G)` needs at
least `|V|` colours: the star clique at any original vertex `a` has `|V|` elements
(its degree in `C(G)` is `|V| − 1`) and injects into the palette. -/
theorem central_total_ge_card (a : V) {n : ℕ}
    (C : (totalGraph (centralGraph G)).Coloring (Fin n)) : Fintype.card V ≤ n := by
  have hinj := star_comp_injective (centralGraph G) C (Sum.inl a)
  have hle : Fintype.card (starIdx (centralGraph G) (Sum.inl a))
      ≤ Fintype.card (Fin n) := Fintype.card_le_of_injective _ hinj
  have hstar : Fintype.card (starIdx (centralGraph G) (Sum.inl a))
      = Fintype.card V := by
    rw [← Nat.card_eq_fintype_card, card_starIdx, central_degree_inl]
  rw [hstar, Fintype.card_fin] at hle
  exact hle

/-- **No AVD colouring with exactly `|V|` colours.** If `G` has a non-adjacent
distinct pair `a, b`, then in `C(G)` the vertices `inl a`, `inl b` are adjacent and
of equal degree `|V| − 1`; the equal-degree obstruction forbids an AVD total
colouring with exactly `|V|` colours. -/
theorem central_no_avd_card (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
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
    rw [Fintype.card_fin]; omega
  exact not_isAVD_of_adjacent_eqdeg (centralGraph G) C (Sum.inl a) (Sum.inl b)
    hadj hdeg hcard hAVD

/-- **Sharp lower bound (`|V| + 1`).** For any finite simple graph `G` with a
non-adjacent distinct pair, every AVD total colouring of `C(G)` uses at least
`|V| + 1` colours.  No regularity is required. -/
theorem avd_total_ge_card_succ (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b)
    {n : ℕ} (C : (totalGraph (centralGraph G)).Coloring (Fin n))
    (hC : IsAVD (centralGraph G) C) : Fintype.card V + 1 ≤ n := by
  by_contra hlt
  push_neg at hlt
  have hnm : n ≤ Fintype.card V := by omega
  obtain ⟨C', hC'⟩ := avd_coloring_castLE (centralGraph G) hnm C hC
  exact central_no_avd_card G a b hne hnadj ⟨C', hC'⟩

/-! ## Packaging as the AVD‑total chromatic number -/

/-- The **AVD‑total chromatic number** `χ''ₐ(H)`: the least number of colours in an
AVD total colouring of `H`, as an element of `ℕ∞` (`⊤` if none exists). -/
noncomputable def avdTotalChromatic {W : Type*} [Fintype W] [DecidableEq W]
    (H : SimpleGraph W) [DecidableRel H.Adj] : ℕ∞ :=
  ⨅ (n : ℕ) (_ : ∃ C : (totalGraph H).Coloring (Fin n), IsAVD H C), (n : ℕ∞)

/-- **`|V| + 1 ≤ χ''ₐ(C(G))`** for every graph `G` with a non-adjacent distinct
pair.  This packages `avd_total_ge_card_succ` as an inequality of AVD‑total
chromatic numbers. -/
theorem avdTotalChromatic_ge_card_succ (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b) :
    (Fintype.card V + 1 : ℕ∞) ≤ avdTotalChromatic (centralGraph G) := by
  refine le_iInf fun n => le_iInf fun hn => ?_
  obtain ⟨C, hC⟩ := hn
  exact_mod_cast avd_total_ge_card_succ G a b hne hnadj C hC

/-- **Regular corollary, derived from the sharp bound.** For a `d`-regular
non-complete graph `G`, every AVD total colouring of `C(G)` uses at least `d + 3`
colours.  Here the number `d + 3` arises as `(d + 2) + 1 ≤ |V| + 1`, exhibiting the
previous regular bound as a numerical consequence of the structural `|V| + 1`
bound. -/
theorem avd_total_ge_regular_sharp {d : ℕ} (hreg : G.IsRegularOfDegree d)
    (a b : V) (hne : a ≠ b) (hnadj : ¬ G.Adj a b)
    {n : ℕ} (C : (totalGraph (centralGraph G)).Coloring (Fin n))
    (hC : IsAVD (centralGraph G) C) : d + 3 ≤ n := by
  have hsharp := avd_total_ge_card_succ G a b hne hnadj C hC
  -- structural fact: a `d`-regular non-complete graph has at least `d + 2` vertices
  have hcard : (insert a (insert b (G.neighborFinset a))).card = d + 2 := by
    rw [card_insert_of_notMem, card_insert_of_notMem, card_neighborFinset_eq_degree, hreg a]
    · simp only [mem_neighborFinset]; exact fun h => hnadj h
    · simp only [mem_insert, mem_neighborFinset]
      push_neg
      exact ⟨hne, fun h => (SimpleGraph.irrefl G) h⟩
  have hge : d + 2 ≤ Fintype.card V :=
    calc d + 2 = (insert a (insert b (G.neighborFinset a))).card := hcard.symm
      _ ≤ Fintype.card V := card_le_univ _
  omega

end CentralGraph

/-! ## A concrete instance: the 5‑cycle, sharpened to `≥ 6` -/

/-- **`C(C₅)` needs at least `6` colours for any AVD total colouring.**  Since
`|V(C₅)| = 5`, the general bound `avd_total_ge_card_succ` yields `|V| + 1 = 6`,
strictly improving the naïve `d + 3 = 5` estimate. -/
theorem cycle5_avd_ge_six {n : ℕ}
    (C : (totalGraph (centralGraph (cycleGraph 5))).Coloring (Fin n))
    (hC : IsAVD (centralGraph (cycleGraph 5)) C) : 6 ≤ n := by
  have h := avd_total_ge_card_succ (cycleGraph 5) (0 : Fin 5) (2 : Fin 5)
    (by decide) (by decide) C hC
  simpa using h

end CentralGraphAVDSharp