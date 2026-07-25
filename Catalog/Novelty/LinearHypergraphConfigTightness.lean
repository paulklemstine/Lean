/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Exact tightness of the density threshold for linear `r`-uniform hypergraphs

`Catalog/Novelty/LinearHypergraphDensityThreshold.lean` proved the global packing bound
`m · C(r,2) ≤ C(n,2)` for any linear `r`-uniform hypergraph and showed that a Steiner system
*attains* it (`steiner_card_eq`).  That gives one direction of optimality: a configuration meeting
the threshold exists.  This file pins down **exactly which configurations are tight**, sharpening
the catalog's optimality statement from an existence result to a complete characterization.

## Main results
* `linear_card_eq_iff_covers` — **global tightness characterization.**  For a linear `r`-uniform
  hypergraph, the packing bound is an *equality* `m · C(r,2) = C(n,2)` **iff** the hypergraph
  covers every pair of vertices (i.e. it is a Steiner system `S(2,r,n)`).  This upgrades
  `steiner_card_eq` (Steiner ⇒ equality) to a biconditional.
* `degree_mul_le` — **local packing bound.**  Each vertex `v` lies in at most `(n-1)/(r-1)` edges:
  `deg(v) · (r-1) ≤ n-1`.  This is the per-vertex ("link") refinement of the global bound.
* `degree_eq_iff_link_covers` — **local tightness characterization.**  Equality
  `deg(v) · (r-1) = n-1` holds **iff** the edges through `v` cover every other vertex.
* `covering_is_regular` — **Corollary.**  In a covering (Steiner) linear `r`-uniform hypergraph
  every vertex has the *same* degree, with `deg(v) · (r-1) = n-1`: tightness is global *and* local
  simultaneously, so Steiner systems are exactly the configurations that are tight everywhere.

## Catalog connections
* Extends `LinearHypergraph.linear_card_le` / `steiner_card_eq` (global bound + Steiner equality).
* The `e = 2` boundary of the Brown–Erdős–Sós extremal function (cf.
  `Catalog/Novelty/Catalog.Novelty.LinearBrownErdosSos.lean`): "every pair covered exactly once".

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the packing bound `m·C(r,2) ≤ C(n,2)` is proved by injecting the
  pairwise-disjoint per-edge pair-sets into the set of all `C(n,2)` pairs.  An injection of finite
  sets is onto iff the cardinalities match, so equality should be *equivalent* to surjectivity,
  i.e. every pair is covered — a Steiner system.  The same skeleton, applied vertex-locally to the
  link `{e : v ∈ e}` (whose erased edges `e \ {v}` are pairwise disjoint subsets of `V \ {v}`),
  should give the degree bound `deg(v)·(r-1) ≤ n-1` with the analogous tightness criterion.
Experiment (Experimenter): reused the `pairs_disjoint`/`biUnion_pairs_subset` engine from the
  catalog density file.  Global: `card_biUnion` turns `m·C(r,2)` into `|⋃ pair-sets|`; the bound
  is `⊆ univ.powersetCard 2`; equality of cardinalities of a `⊆` pair forces set equality
  (`Finset.eq_of_subset_of_card_le`), which decodes as full pair coverage.  Local: map
  `e ↦ e.erase v` over the link; linearity (`e₁ ∩ e₂ ⊆ {v}`) makes these disjoint, union `⊆`
  `univ.erase v` of size `n-1`.
Analysis (Analyst): the load-bearing fact in both directions is "disjoint ⊆ family is onto iff
  cardinalities agree".  No new geometry is needed beyond linearity = pair-disjointness; the
  characterizations are pure double-counting equalities.  The Fano plane `S(2,3,7)` is the smallest
  witness: `7·3 = 21 = C(7,2)` and `deg·(r-1) = 3·2 = 6 = n-1`, simultaneously tight.
Critique (Critic): none of the statements is vacuous.  `linear_card_eq_iff_covers` has content in
  both directions (⇐ is the catalog's `steiner_card_eq`; ⇒ is new).  `degree_mul_le` holds for
  every vertex including isolated ones (`deg = 0`).  `covering_is_regular` is a genuine equality,
  not an inequality, and is non-trivially satisfiable (Steiner systems exist, e.g. Fano).
Synthesis (PI): the density threshold for linear hypergraphs is tight *exactly* on Steiner systems,
  globally and locally.  This turns the catalog's one-sided optimality into an if-and-only-if and
  exhibits the extremal family explicitly, isolating the `e=2` Brown–Erdős–Sós boundary completely.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Finset

namespace LinearHypergraphTight

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- A finite family of edges is **`r`-uniform** if every edge has exactly `r` vertices. -/
def IsUniform (edges : Finset (Finset V)) (r : ℕ) : Prop :=
  ∀ e ∈ edges, e.card = r

/-- A finite family of edges is **linear** if any two distinct edges meet in at most one vertex. -/
def IsLinear (edges : Finset (Finset V)) : Prop :=
  ∀ e₁ ∈ edges, ∀ e₂ ∈ edges, e₁ ≠ e₂ → (e₁ ∩ e₂).card ≤ 1

/-- A family **covers** all pairs if every 2-element subset of the vertex set lies in some edge.
For a linear family this is exactly the Steiner system condition `S(2,r,n)`. -/
def Covers (edges : Finset (Finset V)) : Prop :=
  ∀ p ∈ (univ : Finset V).powersetCard 2, ∃ e ∈ edges, p ⊆ e

/-- The **degree** of a vertex: the number of edges through it. -/
def degree (edges : Finset (Finset V)) (v : V) : ℕ :=
  (edges.filter (fun e => v ∈ e)).card

/-! ### The pair-disjointness engine (global) -/

omit [Fintype V] in
/-- For a linear family, the per-edge pair-sets `powersetCard 2 e` are pairwise disjoint. -/
theorem pairs_disjoint {edges : Finset (Finset V)} (hlin : IsLinear edges) :
    (edges : Set (Finset V)).PairwiseDisjoint (fun e => powersetCard 2 e) := by
  intro e he f hf hne
  by_contra h_inter
  have h_card : (e ∩ f).card ≥ 2 := by
    obtain ⟨p, hp₁, hp₂⟩ := Finset.not_disjoint_iff.mp h_inter
    exact Finset.card_le_card (Finset.subset_inter (Finset.mem_powersetCard.mp hp₁ |>.1)
      (Finset.mem_powersetCard.mp hp₂ |>.1)) |> le_trans (Finset.mem_powersetCard.mp hp₁ |>.2.ge)
  linarith [hlin e he f hf hne]

/-- The disjoint union of the per-edge pair-sets is contained in the set of all vertex pairs. -/
theorem biUnion_pairs_subset (edges : Finset (Finset V)) :
    edges.biUnion (fun e => powersetCard 2 e) ⊆ (univ : Finset V).powersetCard 2 := by
  intro p hp
  simp only [Finset.mem_biUnion, Finset.mem_powersetCard] at hp ⊢
  obtain ⟨e, _, hpe, hpc⟩ := hp
  exact ⟨Finset.subset_univ p, hpc⟩

/-
The disjoint union of per-edge pair-sets has exactly `m · C(r,2)` elements.
-/
omit [Fintype V] in
theorem card_biUnion_pairs {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) :
    (edges.biUnion (fun e => powersetCard 2 e)).card = edges.card * r.choose 2 := by
  rw [ Finset.card_biUnion ];
  · rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.card_powersetCard, huni x hx ] ] ; simp +decide;
  · convert pairs_disjoint hlin

/-! ### Global tightness characterization -/

/-
**Global tightness.** For a linear `r`-uniform hypergraph the packing bound is an equality
`m · C(r,2) = C(n,2)` if and only if every pair of vertices is covered (i.e. it is a Steiner
system).  The `⇐` direction recovers the catalog's `steiner_card_eq`; the `⇒` direction is the new
content, showing Steiner systems are the *only* tight configurations.
-/
theorem linear_card_eq_iff_covers {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) :
    edges.card * r.choose 2 = (Fintype.card V).choose 2 ↔ Covers edges := by
  have h_card : (edges.biUnion (fun e => powersetCard 2 e)).card = edges.card * r.choose 2 := by
    convert card_biUnion_pairs huni hlin
  have h_subset : edges.biUnion (fun e => powersetCard 2 e) ⊆ (Finset.powersetCard 2 (Finset.univ : Finset V)) := by
    grind +qlia
  have h_card_eq : (Finset.powersetCard 2 (Finset.univ : Finset V)).card = (Fintype.card V).choose 2 := by
    rw [ Finset.card_powersetCard, Finset.card_univ ]
  have h_iff_card : edges.card * r.choose 2 = (Fintype.card V).choose 2 ↔ (edges.biUnion (fun e => powersetCard 2 e)) = (Finset.powersetCard 2 (Finset.univ : Finset V)) := by
    exact ⟨ fun h => Finset.eq_of_subset_of_card_le h_subset ( by aesop ), fun h => by rw [ ← h_card, h, h_card_eq ] ⟩
  have h_iff_covers : (edges.biUnion (fun e => powersetCard 2 e)) = (Finset.powersetCard 2 (Finset.univ : Finset V)) ↔ Covers edges := by
    simp +decide [ Finset.ext_iff, Covers ];
    grind
  exact Iff.trans h_iff_card h_iff_covers

/-! ### Local (degree) packing bound and its tightness -/

/-
The erased edges `e \ {v}` of the edges through `v` are pairwise disjoint (linearity).
-/
omit [Fintype V] in
theorem link_erase_disjoint {edges : Finset (Finset V)} (hlin : IsLinear edges) (v : V) :
    ((edges.filter (fun e => v ∈ e)) : Set (Finset V)).PairwiseDisjoint
      (fun e => e.erase v) := by
  intro e he f hf hne; simp_all +decide [ Finset.disjoint_left ] ;
  intro w hw hw' hw''; have := hlin e he.1 f hf.1 hne; simp_all +decide [ Finset.card_le_one ] ;
  exact hw ( this _ hw' hw'' _ he.2 hf.2 )

/-
**Local packing bound.** Each vertex lies in at most `(n-1)/(r-1)` edges:
`deg(v) · (r-1) ≤ n - 1`.
-/
theorem degree_mul_le {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) (v : V) :
    degree edges v * (r - 1) ≤ Fintype.card V - 1 := by
  have h_pairwise_disjoint : ((edges.filter (fun e => v ∈ e)) : Set (Finset V)).PairwiseDisjoint (fun e => e.erase v) := by
    convert link_erase_disjoint hlin v using 1;
  have h_card_union : Finset.card (Finset.biUnion (edges.filter (fun e => v ∈ e)) (fun e => e.erase v)) = (edges.filter (fun e => v ∈ e)).card * (r - 1) := by
    rw [ Finset.card_biUnion h_pairwise_disjoint ];
    rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.card_erase_of_mem ( Finset.mem_filter.mp hx |>.2 ), huni x ( Finset.mem_filter.mp hx |>.1 ) ] ] ; simp +decide;
  exact h_card_union ▸ Finset.card_le_card ( Finset.biUnion_subset.mpr fun e he => Finset.erase_subset_erase _ ( Finset.subset_univ _ ) ) |> le_trans <| by simp +decide [ Finset.card_erase_of_mem ( Finset.mem_univ v ) ] ;

/-
**Local tightness.** Equality in the degree bound, `deg(v) · (r-1) = n - 1`, holds iff the
edges through `v` cover every other vertex `w ≠ v`.
-/
theorem degree_eq_iff_link_covers {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) (v : V) :
    degree edges v * (r - 1) = Fintype.card V - 1 ↔
      ∀ w : V, w ≠ v → ∃ e ∈ edges, v ∈ e ∧ w ∈ e := by
  constructor <;> intro h;
  · intro w hw_ne_v
    set L := edges.filter (fun e => v ∈ e) with hL
    set B := L.biUnion (fun e => e.erase v) with hB
    have hB_card : B.card = degree edges v * (r - 1) := by
      rw [ Finset.card_biUnion ];
      · rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.card_erase_of_mem ( Finset.mem_filter.mp hx |>.2 ), huni x ( Finset.mem_filter.mp hx |>.1 ) ] ] ; aesop;
      · exact link_erase_disjoint hlin v
    have hB_subset : B ⊆ Finset.univ.erase v := by
      grind
    have hB_eq : B = Finset.univ.erase v := by
      exact Finset.eq_of_subset_of_card_le hB_subset ( by rw [ hB_card, h, Finset.card_erase_of_mem ( Finset.mem_univ v ), Finset.card_univ ] );
    replace hB_eq := Finset.ext_iff.mp hB_eq w; aesop;
  · refine' le_antisymm _ _;
    · convert degree_mul_le huni hlin v using 1;
    · -- Let $L = \{e \in edges \mid v \in e\}$ be the set of edges containing $v$.
      set L := edges.filter (fun e => v ∈ e) with hL_def;
      -- By definition of $L$, we know that every vertex $w \neq v$ is contained in some edge in $L$.
      have hL_cover : (Finset.univ.erase v) ⊆ Finset.biUnion L (fun e => e.erase v) := by
        intro w hw; specialize h w; aesop;
      have := Finset.card_mono hL_cover;
      rw [ Finset.card_biUnion ] at this;
      · simp_all +decide [ Finset.card_erase_of_mem ];
        convert this using 2;
        rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.card_erase_of_mem ( Finset.mem_filter.mp hx |>.2 ), huni x ( Finset.mem_filter.mp hx |>.1 ) ] ] ; simp +decide [ degree ];
      · exact link_erase_disjoint hlin v

/-
**Corollary: covering linear hypergraphs are regular.**  In a Steiner system every vertex has
the same degree, namely the one saturating the local bound `deg(v) · (r-1) = n - 1`.  Tightness is
therefore simultaneously global (`linear_card_eq_iff_covers`) and local at every vertex.
-/
theorem covering_is_regular {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) (hcov : Covers edges) (v : V) :
    degree edges v * (r - 1) = Fintype.card V - 1 := by
  convert ( degree_eq_iff_link_covers huni hlin v ).mpr _;
  intro w hw; have := hcov { v, w } ; simp_all +decide [ Finset.mem_powersetCard ] ;
  grind

/-! ### Cycle 2 — the handshake identity and a degree-theoretic edge count -/

/-
-- !-- Lab Notes -- !--
Hypothesis (Cycle 2): the global edge count of a Steiner system should be *re-derivable* purely
  from local regularity by double counting incidences.  The handshake identity
  `∑_v deg(v) = ∑_{e} |e|` (independent of linearity) specialises, for a uniform family, to
  `∑_v deg(v) = m·r`.  Summing the local regularity equality `deg(v)·(r-1) = n-1` over all `n`
  vertices then gives `m·r·(r-1) = n·(n-1)`, an alternative to the pair-count derivation of
  `steiner_card_eq` that flows through degrees rather than pairs.
Experiment/Analysis: `sum_degree_eq` is a pure Fubini swap of the incidence bipartite relation
  (`∑_v |{e : v∈e}| = ∑_e |{v : v∈e}| = ∑_e |e|`) with no structural hypotheses.
  `covering_edge_count` combines `sum_degree_eq` (uniform form `= m·r`) with `covering_is_regular`
  summed over `univ`.
Critique: `covering_edge_count` is the integer form `m·r·(r-1) = n·(n-1)`; for `r ≥ 2` it divides
  to the familiar `m = n(n-1)/(r(r-1))`.  It is not vacuous (Fano: `7·3·2 = 42 = 7·6`).
-- !-- Lab Notes -- !--

**Handshake identity.** The sum of vertex degrees equals the sum of edge sizes (incidence
double count); no linearity or uniformity needed.
-/
theorem sum_degree_eq (edges : Finset (Finset V)) :
    ∑ v, degree edges v = ∑ e ∈ edges, e.card := by
  simp +decide [ degree ];
  simp +decide only [card_filter];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/-
For a `r`-uniform family the degree sum is exactly `m · r`.
-/
theorem sum_degree_uniform {edges : Finset (Finset V)} {r : ℕ} (huni : IsUniform edges r) :
    ∑ v, degree edges v = edges.card * r := by
  rw [ sum_degree_eq, Finset.sum_congr rfl fun e he ↦ huni e he ] ; simp +decide

/-
**Degree-theoretic edge count.** A covering (Steiner) linear `r`-uniform hypergraph satisfies
`m · r · (r-1) = n · (n-1)`.  Derived by summing the local regularity identity
`covering_is_regular` over all vertices and using the handshake identity — a degrees-first route to
the Steiner edge count, complementing the pairs-first `linear_card_eq_iff_covers`.
-/
theorem covering_edge_count {edges : Finset (Finset V)} {r : ℕ}
    (huni : IsUniform edges r) (hlin : IsLinear edges) (hcov : Covers edges) :
    edges.card * (r * (r - 1)) = Fintype.card V * (Fintype.card V - 1) := by
  -- By combining the results from the local and global tightness conditions, we can conclude the proof.
  have h_sum : ∑ v : V, degree edges v * (r - 1) = Fintype.card V * (Fintype.card V - 1) := by
    rw [ Finset.sum_congr rfl fun v _ => covering_is_regular huni hlin hcov v ] ; simp +decide;
  rw [ ← h_sum, ← Finset.sum_mul _ _ _ ] ; rw [ sum_degree_uniform huni ] ; ring;

end LinearHypergraphTight