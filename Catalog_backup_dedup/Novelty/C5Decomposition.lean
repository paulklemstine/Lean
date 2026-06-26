/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Necessary divisibility conditions for C5-decompositions

This file formalizes the *necessity* half of the C5-decomposition problem, the elementary
but structurally essential direction underlying the asymptotic threshold conjecture
`δ_{C_5} = 5/8`:

> If a finite simple graph `G` admits an edge-decomposition into 5-cycles, then `G` is
> *C5-divisible*: every vertex has even degree and `5` divides the number of edges.

These two divisibility conditions are exactly the obstructions that the asymptotic
existence theorem (every `G` on `n ≥ N` vertices with `δ(G) ≥ (5/8 + ε)n` that is
C5-divisible has a C5-decomposition) must overcome.  The forward existence direction is a
deep open/grand-challenge result (see `FUTURE_DIRECTIONS.md`); here we pin down, with a fully
formal proof, the matching *necessary* conditions and a concrete non-vacuity witness.

## Catalog connections
* `Nash-Williams triangle decomposition conjecture` / `Glock--Kühn--Osthus decomposition
  threshold problem`: the C5 case is the `ℓ = 5` instance of the generalized Nash-Williams
  threshold `δ_{C_ℓ} = ℓ/(2ℓ-2)`, computed in `Catalog/Novelty/C5Threshold.lean`.
* `Wilson's theorem on graph decompositions`: divisibility conditions are necessary for
  *any* `H`-decomposition; `c5_decomposition_divisible` is the `H = C_5` instance.
* `mathlib: Mathlib.Combinatorics.SimpleGraph.Basic` / `Mathlib.Data.Fintype.Card`: we build
  directly on `SimpleGraph`, `degree`, `edgeFinset` and finite cardinalities.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A C5-decomposition forces both global divisibility (`5 ∣ |E|`,
  since every 5-cycle has exactly 5 edges) and local parity (`Even (deg v)`, since each
  5-cycle meets a vertex in 0 or 2 of its edges).  These are the *necessary* conditions whose
  asymptotic sufficiency at min-degree `(5/8 + ε)n` is the headline conjecture.
Experiment (Experimenter): Modelled a 5-cycle by an injective `v : Fin 5 → V` with edge set
  `c5edges v = {s(v 0,v 1), …, s(v 4,v 0)}` (image of the wrap-around `i ↦ s(v i, v (i+1))`).
  Modelled a decomposition as a `Finset` of pairwise-disjoint 5-cycle edge sets whose union is
  `G.edgeFinset`.  Proved `|E| = 5 · #parts` via `Finset.card_biUnion`, and `Even (deg v)` by
  rewriting `deg v` as the filtered incidence count and distributing the filter over the
  (disjoint) union.
Analysis (Analyst): The two helper facts `c5edges_card = 5` and `c5edges_even_incidence`
  carry all the combinatorial content.  The cardinality fact needs injectivity of the
  edge map `i ↦ s(v i, v (i+1))` on `Fin 5` (the second "swap" case `i = j+1 ∧ i+1 = j`
  is killed by `2 ≠ 0` in `Fin 5`).  The parity fact uses that the index sets `{i | v i = w}`
  and `{i | v (i+1) = w}` are disjoint and equinumerous, so the incidence count is `2·a`.
Critique (Critic): The result is non-vacuous — `cycleGraph 5` itself decomposes into a single
  5-cycle (`cycleGraph5_decomposition`), so the divisibility conclusion is realized, not merely
  implied by an empty hypothesis.  The odd cycle length `5` is essential: the swap case and the
  `2 ≠ 0` step are exactly where evenness of the cycle would break the count.
-/
import Mathlib

open SimpleGraph Finset

namespace C5Decomp

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Edge set of the (closed) 5-cycle through `v 0, v 1, v 2, v 3, v 4`.  The index addition
`i + 1` is taken in `Fin 5`, so the term `i = 4` contributes the closing edge `s(v 4, v 0)`. -/
def c5edges (v : Fin 5 → V) : Finset (Sym2 V) :=
  Finset.univ.image (fun i => s(v i, v (i + 1)))

/-- `s` is the edge set of a 5-cycle: it arises from five distinct vertices arranged cyclically. -/
def IsFiveCycle (s : Finset (Sym2 V)) : Prop :=
  ∃ v : Fin 5 → V, Function.Injective v ∧ s = c5edges v

/-- The edge map `i ↦ s(v i, v (i+1))` is injective on `Fin 5` when `v` is injective: hence a
5-cycle has exactly `5` edges. -/
omit [Fintype V] in
lemma c5edges_card {v : Fin 5 → V} (hv : Function.Injective v) :
    (c5edges v).card = 5 := by
  rw [c5edges, Finset.card_image_of_injective]
  · rfl
  · simp +decide [Function.Injective, hv.eq_iff]

/-- Each vertex lies on an even number (in fact `0` or `2`) of the edges of a 5-cycle. -/
omit [Fintype V] in
lemma c5edges_even_incidence {v : Fin 5 → V} (hv : Function.Injective v) (w : V) :
    Even ((c5edges v).filter (fun e => w ∈ e)).card := by
  by_cases hw : ∃ i : Fin 5, v i = w <;> simp_all +decide [c5edges]
  · obtain ⟨i, hi⟩ := hw
    simp +decide [Finset.filter_image]
    rw [Finset.card_image_of_injective _ fun a b h => _]
    · fin_cases i <;> simp +decide [← hi, hv.eq_iff]
    · simp +decide [hv.eq_iff]
  · rw [Finset.filter_eq_empty_iff.mpr] <;> simp_all +decide [Sym2.mem_iff]
    exact fun a => ⟨Ne.symm (hw a), Ne.symm (hw (a + 1))⟩

omit [Fintype V] in
lemma IsFiveCycle.card_eq_five {s : Finset (Sym2 V)} (hs : IsFiveCycle s) :
    s.card = 5 := by
  obtain ⟨v, hv, rfl⟩ := hs; exact c5edges_card hv

omit [Fintype V] in
lemma IsFiveCycle.even_incidence {s : Finset (Sym2 V)} (hs : IsFiveCycle s) (w : V) :
    Even (s.filter (fun e => w ∈ e)).card := by
  obtain ⟨v, hv, rfl⟩ := hs; exact c5edges_even_incidence hv w

variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- An edge-decomposition of `G` into 5-cycles: a finite family of pairwise edge-disjoint
5-cycle edge sets whose union is exactly the edge set of `G`. -/
structure C5Decomposition where
  /-- The 5-cycles of the decomposition, recorded by their edge sets. -/
  parts : Finset (Finset (Sym2 V))
  /-- Every part is the edge set of a 5-cycle. -/
  isCycle : ∀ p ∈ parts, IsFiveCycle p
  /-- The parts are pairwise edge-disjoint. -/
  disj : (parts : Set (Finset (Sym2 V))).PairwiseDisjoint id
  /-- The parts cover exactly the edges of `G`. -/
  cover : parts.biUnion id = G.edgeFinset

/-- **Edge count.** A graph with a C5-decomposition has exactly `5 · (#cycles)` edges. -/
theorem card_edgeFinset_eq (D : C5Decomposition G) :
    G.edgeFinset.card = 5 * D.parts.card := by
  rw [← D.cover, Finset.card_biUnion D.disj]
  have h5 : ∀ p ∈ D.parts, (id p).card = 5 := by
    intro p hp
    obtain ⟨v, hv, rfl⟩ := D.isCycle p hp
    exact c5edges_card hv
  rw [Finset.sum_congr rfl h5]
  simp [mul_comm]

/-- **Global divisibility.** A graph with a C5-decomposition has a number of edges divisible
by `5`. -/
theorem five_dvd_card_edgeFinset (D : C5Decomposition G) :
    5 ∣ G.edgeFinset.card :=
  ⟨D.parts.card, card_edgeFinset_eq G D⟩

/-- **Local parity.** Every vertex of a graph with a C5-decomposition has even degree. -/
theorem even_degree (D : C5Decomposition G) (w : V) : Even (G.degree w) := by
  rw [← SimpleGraph.card_incidenceFinset_eq_degree, SimpleGraph.incidenceFinset_eq_filter,
      ← D.cover, Finset.filter_biUnion, Finset.card_biUnion]
  · apply Finset.even_sum
    intro p hp
    obtain ⟨v, hv, rfl⟩ := D.isCycle p hp
    exact c5edges_even_incidence hv w
  · intro a ha b hb hab
    exact (D.disj ha hb hab).mono (Finset.filter_subset _ _) (Finset.filter_subset _ _)

/-- A finite simple graph is **C5-divisible** if every vertex has even degree and `5` divides
the number of edges.  These are precisely the necessary congruence conditions for the existence
of a C5-decomposition. -/
def IsC5Divisible : Prop :=
  (∀ w : V, Even (G.degree w)) ∧ 5 ∣ G.edgeFinset.card

/-- **Necessity of divisibility.** Every graph admitting an edge-decomposition into 5-cycles is
C5-divisible.  (This is the `H = C_5` instance of the classical necessary divisibility
conditions for `H`-decompositions.) -/
theorem c5_decomposition_divisible (D : C5Decomposition G) : IsC5Divisible G :=
  ⟨even_degree G D, five_dvd_card_edgeFinset G D⟩

/-- **Contrapositive obstruction.** A graph with a vertex of odd degree (or with `¬ 5 ∣ |E|`)
admits no C5-decomposition. -/
theorem no_decomposition_of_not_divisible (h : ¬ IsC5Divisible G) :
    IsEmpty (C5Decomposition G) :=
  ⟨fun D => h (c5_decomposition_divisible G D)⟩

/-- **Non-vacuity witness.** The pentagon `cycleGraph 5` decomposes into the single 5-cycle
`0-1-2-3-4-0`, so the hypothesis `C5Decomposition G` is satisfiable and the divisibility
conclusions above are genuinely realized rather than vacuous. -/
def cycleGraph5_decomposition : C5Decomposition (cycleGraph 5) where
  parts := {c5edges id}
  isCycle := by
    intro p hp
    rw [Finset.mem_singleton] at hp
    subst hp
    exact ⟨id, Function.injective_id, rfl⟩
  disj := by rw [Finset.coe_singleton]; exact Set.pairwiseDisjoint_singleton _ _
  cover := by decide

/-- The pentagon admits a C5-decomposition. -/
theorem cycleGraph5_hasDecomposition : Nonempty (C5Decomposition (cycleGraph 5)) :=
  ⟨cycleGraph5_decomposition⟩

/-- Consequently the pentagon is C5-divisible (every degree is `2`, and it has `5` edges). -/
theorem cycleGraph5_isC5Divisible : IsC5Divisible (cycleGraph 5) :=
  c5_decomposition_divisible _ cycleGraph5_decomposition

end C5Decomp