import Cryptography.UniversalPosets.Bounds

/-!
# Comparability graphs: a bridge from universal posets to universal graphs

The motivating paper transports poset problems to graph problems (and uses the
Szemerédi Regularity Lemma on the resulting graphs).  This file formalises the
transport.

* `comparabilityGraph r` is the comparability graph of an order relation `r`.
* `comparabilityGraph_bipRel` identifies the comparability graph of a height-`≤ 2`
  ("bipartite") poset with the corresponding bipartite graph -- an exact
  equality of graphs, not merely an embedding.
* `IsBipartiteUniversalGraph` is the graph analogue of `IsBipartiteUniversal`
  and satisfies the same counting bound `2 ^ (k*l) ≤ N ^ (k+l)`.
* `isBipartiteUniversalGraph_of_isBipartiteUniversal` says the comparability
  graph of a universal *poset* host is a universal *graph* host; hence the
  poset lower bound of `Bounds.lean` is *re-derived* from the graph one
  (`two_pow_mul_le_card_pow_via_graphs`), a genuinely different proof route.
* `comparability_regularity` instantiates Mathlib's Szemerédi Regularity Lemma
  for comparability graphs of finite posets, which is the form in which the
  regularity method enters the study of universal posets.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  (1) Comparability is a *functor* on induced
embeddings; (2) the height-2 family is mapped onto the whole family of
bipartite graphs, bijectively on relations; (3) therefore the poset counting
bound and the graph counting bound are the same theorem viewed twice; (4)
regularity applies verbatim to comparability graphs.

Experiment (Experimenter).  (1)-(4) proved.  The subtle point in (1) is that a
merely order-preserving map does *not* induce an induced subgraph: reflection of
the order is needed, and injectivity is needed to keep non-adjacent pairs
distinct; both are supplied by `injective_of_universal_witness`.

Analysis (Analyst).  The graph route loses nothing for the bipartite class,
which explains why regularity-based graph technology (as in the paper) is the
right tool: no information is destroyed when passing from a height-2 poset to
its comparability graph.  For general posets the functor *does* lose
information (the comparability graph forgets orientation), which is exactly the
reason the paper must re-orient after applying graph tools.

Critique (Critic).  `comparability_regularity` is an instantiation of Mathlib's
regularity lemma, and is presented as such; the mathematical content of this
file is in the functor and the counting bound, both proved from scratch.
-/

open Finset Fintype

namespace UniversalPosets

variable {k l : ℕ}

/-! ## The comparability graph -/

/-- The comparability graph of a relation: distinct points joined when comparable. -/
def comparabilityGraph {α : Type*} (r : α → α → Prop) : SimpleGraph α where
  Adj x y := x ≠ y ∧ (r x y ∨ r y x)
  symm := by
    rintro x y ⟨h1, h2⟩
    exact ⟨h1.symm, h2.symm⟩
  loopless := ⟨fun _ h => h.1 rfl⟩

@[simp] theorem comparabilityGraph_adj {α : Type*} (r : α → α → Prop) (x y : α) :
    (comparabilityGraph r).Adj x y ↔ x ≠ y ∧ (r x y ∨ r y x) := Iff.rfl

instance comparabilityGraph_decidableAdj {α : Type*} [DecidableEq α] (r : α → α → Prop)
    [DecidableRel r] : DecidableRel (comparabilityGraph r).Adj :=
  fun x y => inferInstanceAs (Decidable (x ≠ y ∧ (r x y ∨ r y x)))

/-- The bipartite graph of a bipartite relation. -/
def bipGraph (R : Fin k → Fin l → Bool) : SimpleGraph (Fin k ⊕ Fin l) where
  Adj x y :=
    match x, y with
    | Sum.inl a, Sum.inr b => R a b
    | Sum.inr b, Sum.inl a => R a b
    | _, _ => False
  symm := by rintro (a | a) (b | b) h <;> simp_all
  loopless := ⟨by rintro (a | a) h <;> simp at h⟩

instance bipGraph_decidableAdj (R : Fin k → Fin l → Bool) : DecidableRel (bipGraph R).Adj :=
  fun x y =>
    match x, y with
    | Sum.inl _, Sum.inl _ => inferInstanceAs (Decidable False)
    | Sum.inl a, Sum.inr b => inferInstanceAs (Decidable (R a b = true))
    | Sum.inr b, Sum.inl a => inferInstanceAs (Decidable (R a b = true))
    | Sum.inr _, Sum.inr _ => inferInstanceAs (Decidable False)

/--
The comparability graph of a height-`≤ 2` poset **is** the corresponding
bipartite graph.
-/
theorem comparabilityGraph_bipRel (R : Fin k → Fin l → Bool) :
    comparabilityGraph (bipRel (fun a b => R a b = true)) = bipGraph R := by
  ext x y
  rcases x with a | a <;> rcases y with b | b <;>
    simp only [comparabilityGraph_adj, bipGraph, bipRel, ne_eq, Sum.inl.injEq, Sum.inr.injEq,
      reduceCtorEq] <;> aesop

/-! ## Universal graphs for the bipartite class -/

/--
`IsBipartiteUniversalGraph H k l` : the graph `H` contains every `(k,l)`-bipartite
graph as an induced subgraph.
-/
def IsBipartiteUniversalGraph {V : Type*} (H : SimpleGraph V) (k l : ℕ) : Prop :=
  ∀ R : Fin k → Fin l → Bool, ∃ f : (Fin k ⊕ Fin l) → V,
    ∀ x y, H.Adj (f x) (f y) ↔ (bipGraph R).Adj x y

/--
**Counting lower bound for induced-universal graphs.**  A host graph on `N`
vertices containing all `(k,l)`-bipartite graphs as induced subgraphs satisfies
`2 ^ (k*l) ≤ N ^ (k+l)`.
-/
theorem two_pow_mul_le_card_pow_graph {V : Type*} [Fintype V] {H : SimpleGraph V}
    (h : IsBipartiteUniversalGraph H k l) :
    2 ^ (k * l) ≤ (Fintype.card V) ^ (k + l) := by
  classical
  choose F hF using h
  have hinj : Function.Injective F := by
    intro R S hRS
    funext a b
    have h1 := hF R (Sum.inl a) (Sum.inr b)
    have h2 := hF S (Sum.inl a) (Sum.inr b)
    rw [hRS] at h1
    have : (R a b = true) ↔ (S a b = true) := by
      simpa [bipGraph] using h1.symm.trans h2
    revert this
    cases R a b <;> cases S a b <;> simp
  have hcard := Fintype.card_le_of_injective F hinj
  have e1 : Fintype.card (Fin k → Fin l → Bool) = 2 ^ (k * l) := by
    simp only [Fintype.card_fun, Fintype.card_bool, Fintype.card_fin]
    rw [← pow_mul, mul_comm]
  have e2 : Fintype.card ((Fin k ⊕ Fin l) → V) = (Fintype.card V) ^ (k + l) := by simp
  rw [e1, e2] at hcard
  exact hcard

/-! ## The comparability functor -/

/--
The comparability graph of a universal poset host is a universal graph host for
the bipartite class: induced poset embeddings become induced subgraphs.
-/
theorem isBipartiteUniversalGraph_of_isBipartiteUniversal {U : Type*} [PartialOrder U]
    (h : IsBipartiteUniversal U k l) :
    IsBipartiteUniversalGraph (comparabilityGraph ((· ≤ ·) : U → U → Prop)) k l := by
  intro R
  obtain ⟨f, hf⟩ := h (fun a b => R a b = true)
  haveI := bipRel_isPartialOrder (fun a b => R a b = true)
  have hinjf : Function.Injective f := injective_of_universal_witness hf
  refine ⟨f, fun x y => ?_⟩
  have hne : (f x ≠ f y) ↔ (x ≠ y) := ⟨fun hh e => hh (by rw [e]), fun hh e => hh (hinjf e)⟩
  simp only [comparabilityGraph_adj, hne, hf]
  rcases x with a | a <;> rcases y with b | b <;>
    simp only [bipGraph, bipRel, ne_eq, Sum.inl.injEq, Sum.inr.injEq, reduceCtorEq] <;> aesop

/--
**The poset counting bound, re-derived through graphs.**  Same conclusion as
`two_pow_mul_le_card_pow`, obtained by pushing the problem through the
comparability functor and counting bipartite *graphs*.
-/
theorem two_pow_mul_le_card_pow_via_graphs {U : Type*} [PartialOrder U] [Fintype U]
    (h : IsBipartiteUniversal U k l) :
    2 ^ (k * l) ≤ (Fintype.card U) ^ (k + l) :=
  two_pow_mul_le_card_pow_graph (isBipartiteUniversalGraph_of_isBipartiteUniversal h)

/-! ## Regularity for comparability graphs -/

/--
**Szemerédi Regularity for posets.**  Every sufficiently large finite poset has
an `ε`-uniform equipartition of its comparability graph into a bounded number of
parts, the bound being independent of the poset.  This is the form in which the
regularity method is applied to universal posets.
-/
theorem comparability_regularity {U : Type*} [Fintype U] [DecidableEq U] [PartialOrder U]
    [DecidableRel ((· ≤ ·) : U → U → Prop)] {ε : ℝ} {m : ℕ}
    (hε : 0 < ε) (hm : m ≤ Fintype.card U) :
    ∃ P : Finpartition (univ : Finset U),
      P.IsEquipartition ∧ m ≤ #P.parts ∧ #P.parts ≤ SzemerediRegularity.bound ε m ∧
        P.IsUniform (comparabilityGraph ((· ≤ ·) : U → U → Prop)) ε :=
  szemeredi_regularity _ hε hm

/--
Specialisation to height-`≤ 2` posets: the bipartite graph of any bipartite
relation admits an `ε`-uniform equipartition of bounded size.
-/
theorem bipGraph_regularity (R : Fin k → Fin l → Bool) {ε : ℝ} {m : ℕ}
    (hε : 0 < ε) (hm : m ≤ k + l) :
    ∃ P : Finpartition (univ : Finset (Fin k ⊕ Fin l)),
      P.IsEquipartition ∧ m ≤ #P.parts ∧ #P.parts ≤ SzemerediRegularity.bound ε m ∧
        P.IsUniform (bipGraph R) ε := by
  classical
  have hcard : m ≤ Fintype.card (Fin k ⊕ Fin l) := by simpa using hm
  exact szemeredi_regularity _ hε hcard

end UniversalPosets