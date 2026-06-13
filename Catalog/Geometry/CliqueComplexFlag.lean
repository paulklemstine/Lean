/-
# Clique Complexes, Flag Complexes, and the Vietoris–Rips Filtration

This file develops, from scratch, a lightweight theory of abstract simplicial
complexes (`ASC`) and the clique-complex construction on simple graphs, together
with the flag-complex characterization, the Vietoris–Rips filtration, and a
Turán-style bound on the `f`-vector.

## Main results

* `isClique_pair`            — a two-element set is a clique iff its endpoints are adjacent.
* `cliqueComplex_isFlag`     — every clique complex is a flag complex.
* `oneSkeleton_cliqueComplex`— the one-skeleton of `Δ(G)` is exactly `G`.
* `flag_eq_cliqueComplex`    — every flag complex *with all singletons* is the clique
                               complex of its own one-skeleton (the converse direction).
* `vietorisRips_mono`        — the Vietoris–Rips complex is monotone in the scale `ε`.
* `cliqueComplex_fVector_le_choose` — `f_k(Δ(G)) ≤ C(n, k+1)` (Turán-style upper bound).
* `flag_not_cliqueComplex_without_singletons` — the singleton hypothesis in
                               `flag_eq_cliqueComplex` cannot be dropped (counterexample).

-- !-- Lab Notebook -- !--
Hypothesis: the clique-complex and one-skeleton constructions form an
  adjunction-like pair on simple graphs, with flag complexes the image of `Δ`.
Result: proved both directions, with the precise side condition (all singletons
  present) isolated by an explicit counterexample on `Bool`.
Insight: the entire theory pivots on the single fact `isClique_pair`
  ("a 2-clique is an edge"); the forward direction is downward closure and the
  converse rebuilds a face from its edges via the flag axiom.
Failure analysis: the naive converse (drop the singleton hypothesis) is FALSE —
  clique complexes always contain every singleton, but a flag complex need not,
  witnessed by the trivial complex `{∅}` whose one-skeleton is the empty graph.
-- !-- Lab Notebook -- !--
-/
import Mathlib

namespace CliqueComplexFlag

open scoped Classical

universe u
variable {V : Type u}

/-- An **abstract simplicial complex** on a vertex type `V`: a set of finite faces
that is closed under taking subsets. -/
structure ASC (V : Type u) where
  /-- The set of faces of the complex. -/
  faces : Set (Finset V)
  /-- Downward closure: any subset of a face is a face. -/
  down_closed : ∀ ⦃s t : Finset V⦄, s ⊆ t → t ∈ faces → s ∈ faces

namespace ASC

/-- Two complexes are equal once their face sets agree. -/
@[ext] theorem ext {K L : ASC V} (h : K.faces = L.faces) : K = L := by
  cases K; cases L; simp_all

end ASC

/-! ## The clique complex of a simple graph -/

/-- The **clique complex** `Δ(G)`: faces are the finite cliques of `G`. -/
def cliqueComplex (G : SimpleGraph V) : ASC V where
  faces := {s : Finset V | G.IsClique (↑s : Set V)}
  down_closed := by
    intro s t hst ht
    exact ht.subset (by exact_mod_cast hst)

@[simp] theorem mem_cliqueComplex {G : SimpleGraph V} {s : Finset V} :
    s ∈ (cliqueComplex G).faces ↔ G.IsClique (↑s : Set V) := Iff.rfl

/-- **A two-element set is a clique iff its endpoints are adjacent.**
This is the structural pivot of the whole development. -/
theorem isClique_pair {G : SimpleGraph V} {u v : V} (h : u ≠ v) :
    G.IsClique (↑({u, v} : Finset V) : Set V) ↔ G.Adj u v := by
  -- !-- a 2-clique is exactly an edge: unfold pairwise adjacency on `{u,v}`. -- !--
  constructor
  · intro hc
    have : ({u, v} : Set V).Pairwise G.Adj := by
      simpa using hc
    exact this (by simp) (by simp) h
  · intro hadj
    rw [SimpleGraph.isClique_iff]
    simp only [Finset.coe_insert, Finset.coe_singleton]
    rw [Set.pairwise_pair_of_symmetric G.symm]
    intro _; exact hadj

/-! ## The one-skeleton of a complex -/

/-- The **one-skeleton** graph of a complex: `u` and `v` are adjacent iff they are
distinct and `{u, v}` is a face. -/
def oneSkeleton (K : ASC V) : SimpleGraph V where
  Adj u v := u ≠ v ∧ ({u, v} : Finset V) ∈ K.faces
  symm := by
    intro u v h
    refine ⟨h.1.symm, ?_⟩
    have : ({v, u} : Finset V) = ({u, v} : Finset V) := by
      ext x; simp [or_comm]
    rw [this]; exact h.2
  loopless := ⟨fun u h => h.1 rfl⟩

@[simp] theorem oneSkeleton_adj {K : ASC V} {u v : V} :
    (oneSkeleton K).Adj u v ↔ u ≠ v ∧ ({u, v} : Finset V) ∈ K.faces := Iff.rfl

/-- **The one-skeleton of a clique complex recovers the graph.**
Hence `Δ` is injective on graphs. -/
theorem oneSkeleton_cliqueComplex (G : SimpleGraph V) :
    oneSkeleton (cliqueComplex G) = G := by
  -- !-- by `isClique_pair`: `{u,v}` is a face iff `u ~ v`, and adjacency forces `u ≠ v`. -- !--
  ext u v
  simp only [oneSkeleton_adj, mem_cliqueComplex]
  constructor
  · rintro ⟨hne, hc⟩
    exact (isClique_pair hne).1 hc
  · intro hadj
    exact ⟨G.ne_of_adj hadj, (isClique_pair (G.ne_of_adj hadj)).2 hadj⟩

/-! ## Flag complexes -/

/-- A complex `K` is a **flag complex** if every finite vertex set, all of whose
singletons are faces and all of whose pairs are faces, is itself a face. -/
def IsFlag (K : ASC V) : Prop :=
  ∀ s : Finset V,
    (∀ u ∈ s, ({u} : Finset V) ∈ K.faces) →
    (∀ u ∈ s, ∀ v ∈ s, u ≠ v → ({u, v} : Finset V) ∈ K.faces) →
    s ∈ K.faces

/-- **Every clique complex is a flag complex.** -/
theorem cliqueComplex_isFlag (G : SimpleGraph V) : IsFlag (cliqueComplex G) := by
  -- !-- a set all of whose pairs are edges is pairwise-adjacent, i.e. a clique. -- !--
  intro s _ hpairs
  rw [mem_cliqueComplex, SimpleGraph.isClique_iff]
  intro u hu v hv huv
  have : ({u, v} : Finset V) ∈ (cliqueComplex G).faces :=
    hpairs u (by exact_mod_cast hu) v (by exact_mod_cast hv) huv
  rw [mem_cliqueComplex] at this
  exact (isClique_pair huv).1 this

/-- **The converse: a flag complex containing all singletons is the clique complex
of its one-skeleton.** This is the headline new result. -/
theorem flag_eq_cliqueComplex {K : ASC V} (hflag : IsFlag K)
    (hsing : ∀ v : V, ({v} : Finset V) ∈ K.faces) :
    K = cliqueComplex (oneSkeleton K) := by
  -- !-- ⊆ is downward closure (each pair of a face is a face);
  --     ⊇ rebuilds a face from its edges + singletons via the flag axiom. -- !--
  apply ASC.ext
  ext s
  simp only [mem_cliqueComplex, SimpleGraph.isClique_iff]
  constructor
  · -- a face is a clique in its own one-skeleton
    intro hs u hu v hv huv
    refine ⟨huv, ?_⟩
    refine K.down_closed ?_ hs
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl
    · exact_mod_cast hu
    · exact_mod_cast hv
  · -- a clique in the one-skeleton is a face, by the flag axiom
    intro hclique
    refine hflag s (fun u _ => hsing u) ?_
    intro u hu v hv huv
    exact (hclique (by exact_mod_cast hu) (by exact_mod_cast hv) huv).2

/-! ## The Vietoris–Rips complex -/

/-- The **Vietoris–Rips graph** of a dissimilarity `d` at scale `ε`: distinct
vertices are adjacent when both directed dissimilarities are `≤ ε` (this symmetric
form needs no symmetry hypothesis on `d`). -/
def vietorisRipsGraph (d : V → V → ℝ) (ε : ℝ) : SimpleGraph V where
  Adj u v := u ≠ v ∧ d u v ≤ ε ∧ d v u ≤ ε
  symm := by intro u v h; exact ⟨h.1.symm, h.2.2, h.2.1⟩
  loopless := ⟨fun u h => h.1 rfl⟩

/-- The **Vietoris–Rips complex** is the clique complex of the Vietoris–Rips graph. -/
def vietorisRips (d : V → V → ℝ) (ε : ℝ) : ASC V :=
  cliqueComplex (vietorisRipsGraph d ε)

/-- **The Vietoris–Rips complex is monotone in the scale**, giving a filtration. -/
theorem vietorisRips_mono (d : V → V → ℝ) {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    (vietorisRips d ε₁).faces ⊆ (vietorisRips d ε₂).faces := by
  -- !-- a smaller scale gives a subgraph, and `IsClique` is monotone in the graph. -- !--
  intro s hs
  rw [vietorisRips, mem_cliqueComplex, SimpleGraph.isClique_iff] at hs ⊢
  intro u hu v hv huv
  obtain ⟨hne, h1, h2⟩ := hs hu hv huv
  exact ⟨hne, h1.trans h, h2.trans h⟩

/-! ## The f-vector and a Turán-style bound -/

/-- The **`f`-vector** of a complex on a finite vertex type: `fVector K k` counts the
faces of cardinality `k + 1` (the `k`-dimensional faces). -/
noncomputable def fVector [Fintype V] (K : ASC V) (k : ℕ) : ℕ :=
  ((Finset.univ.powersetCard (k + 1)).filter (fun s => s ∈ K.faces)).card

/-- **Turán-style upper bound on the `f`-vector**: `f_k(Δ(G)) ≤ C(n, k+1)`, with
equality for the complete graph. -/
theorem cliqueComplex_fVector_le_choose [Fintype V] (G : SimpleGraph V) (k : ℕ) :
    fVector (cliqueComplex G) k ≤ (Fintype.card V).choose (k + 1) := by
  -- !-- faces of size `k+1` form a subset of all size-`k+1` sets, counted by a binomial. -- !--
  rw [fVector]
  refine (Finset.card_filter_le _ _).trans ?_
  rw [Finset.card_powersetCard, Finset.card_univ]

/-! ## The singleton hypothesis is necessary -/

/-- The trivial complex on `Bool` whose only face is the empty set. -/
def trivialComplex : ASC Bool where
  faces := {∅}
  down_closed := by
    intro s t hst ht
    simp only [Set.mem_singleton_iff] at ht ⊢
    subst ht
    exact Finset.subset_empty.1 hst

/-- **The singleton hypothesis in `flag_eq_cliqueComplex` cannot be dropped.**
The trivial complex `{∅}` on `Bool` is flag, yet it is *not* the clique complex of
its one-skeleton, because clique complexes always contain every singleton while a
flag complex need not. -/
theorem flag_not_cliqueComplex_without_singletons :
    IsFlag trivialComplex ∧
      trivialComplex ≠ cliqueComplex (oneSkeleton trivialComplex) := by
  -- !-- `{∅}` is vacuously flag; its one-skeleton is the empty graph, whose clique
  --     complex contains `{true}`, a non-face of `{∅}`. -- !--
  constructor
  · -- flagness: only the empty set can satisfy "all singletons are faces"
    intro s hsing _
    rcases Finset.eq_empty_or_nonempty s with h | h
    · subst h; simp [trivialComplex]
    · obtain ⟨u, hu⟩ := h
      have hu' := hsing u hu
      simp only [trivialComplex, Set.mem_singleton_iff] at hu'
      exact absurd hu' (Finset.singleton_ne_empty u)
  · intro hcontra
    have h1 : ({true} : Finset Bool) ∈ (cliqueComplex (oneSkeleton trivialComplex)).faces := by
      rw [mem_cliqueComplex]
      rw [SimpleGraph.isClique_iff]
      intro x hx y hy hxy
      simp only [Finset.coe_singleton, Set.mem_singleton_iff] at hx hy
      exact absurd (hx.trans hy.symm) hxy
    rw [← hcontra] at h1
    simp only [trivialComplex, Set.mem_singleton_iff] at h1
    exact absurd h1 (by simp)

end CliqueComplexFlag