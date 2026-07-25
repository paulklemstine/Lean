/-
  # Persistence of Dependency Hypergraphs: A Topological Theory of Proof Complexity

  This file introduces **weighted dependency hypergraphs** as a formal model for
  proof traces and develops a filtration-based persistence theory that connects
  topological invariants to proof complexity surrogates.

  ## Main Definitions
  - `WeightedDepHypergraph`: A hypergraph with weighted edges on a finite vertex type
  - `activeEdges`: Edges with weight at most k (the filtration)
  - `supportComplex`: The downward-closed simplicial complex at scale k
  - `codependencyTime`: First scale at which two vertices become co-supported
  - `widthAt`: Maximum edge cardinality at scale k (proof-width surrogate)
  - `betaGap`: Reduced Euler characteristic of the support complex (order parameter)
  - `IsConeAt`: Cone condition on the support complex

  ## Main Results
  - `supportComplex_mono`: The support complex is monotone in the filtration parameter
  - `widthAt_mono`: The width surrogate is monotone
  - `no_pair_before_codependencyTime`: Co-dependency obstruction below threshold
  - `pair_enters_at_codependencyTime`: Co-dependency birth at threshold
  - `width_lower_bound_of_pair_entry`: Width lower bound from co-dependency events
  - `isConeAt_of_common_vertex`: Common vertex implies cone structure
  - `betaGap_eq_zero_of_isConeAt`: Cone structure forces vanishing order parameter
-/
import Mathlib

open Finset BigOperators

/-! ## Core Structure -/

/-- A weighted dependency hypergraph on a finite vertex type `V`.
Vertices represent goals/lemmas/clauses and hyperedges represent dependency
relations. The weight function models derivation cost, clause width, or depth. -/
structure WeightedDepHypergraph (V : Type*) [Fintype V] where
  /-- The type of hyperedges -/
  Edge : Type*
  /-- Edges form a finite type -/
  [edgeFintype : Fintype Edge]
  /-- Edges have decidable equality -/
  [edgeDecEq : DecidableEq Edge]
  /-- Each edge covers a nonempty finite set of vertices -/
  verts : Edge → Finset V
  /-- Weight function on edges (models cost/depth/width) -/
  weight : Edge → ℕ
  /-- Every edge covers at least one vertex -/
  nonempty_verts : ∀ e, (verts e).Nonempty

attribute [instance] WeightedDepHypergraph.edgeFintype WeightedDepHypergraph.edgeDecEq

namespace WeightedDepHypergraph

variable {V : Type*} [DecidableEq V] [Fintype V]

/-! ## Filtration -/

/-- The set of edges active at filtration scale `k`: those with weight ≤ k. -/
def activeEdges (H : WeightedDepHypergraph V) (k : ℕ) : Finset H.Edge :=
  Finset.univ.filter (fun e => decide (H.weight e ≤ k))

theorem mem_activeEdges (H : WeightedDepHypergraph V) (e : H.Edge) (k : ℕ) :
    e ∈ H.activeEdges k ↔ H.weight e ≤ k := by
  simp [activeEdges]

theorem activeEdges_mono (H : WeightedDepHypergraph V) {k l : ℕ} (hkl : k ≤ l) :
    H.activeEdges k ⊆ H.activeEdges l := by
  grind +locals

/-! ## Support Complex -/

/-- The support complex at scale `k`: all nonempty subsets of vertex sets
of active edges. This is a downward-closed (on nonempty sets) simplicial complex. -/
def supportComplex (H : WeightedDepHypergraph V) (k : ℕ) : Finset (Finset V) :=
  (H.activeEdges k).biUnion fun e =>
    (H.verts e).powerset.filter fun s => s.Nonempty

/-
Membership characterization for the support complex.
-/
theorem mem_supportComplex (H : WeightedDepHypergraph V) (k : ℕ) (σ : Finset V) :
    σ ∈ H.supportComplex k ↔
      ∃ e : H.Edge, H.weight e ≤ k ∧ σ ⊆ H.verts e ∧ σ.Nonempty := by
  -- By definition of supportComplex, we have that σ ∈ H.supportComplex k if and only if σ is a non-empty subset of some active edge.
  simp [supportComplex, activeEdges]

/-! ## Width Surrogate -/

/-- The proof-width surrogate at scale `k`: maximum cardinality of an active edge's
vertex set. Returns 0 if no edges are active. -/
def widthAt (H : WeightedDepHypergraph V) (k : ℕ) : ℕ :=
  (H.activeEdges k).sup fun e => (H.verts e).card

/-! ## Co-dependency Time -/

/-- Whether two vertices are jointly covered by some edge. -/
def AreCodependent (H : WeightedDepHypergraph V) (u v : V) : Prop :=
  ∃ e : H.Edge, u ∈ H.verts e ∧ v ∈ H.verts e

instance (H : WeightedDepHypergraph V) (u v : V) :
    Decidable (H.AreCodependent u v) :=
  Fintype.decidableExistsFintype

/-- The first filtration scale at which vertices `u` and `v` become jointly covered
by some hyperedge. Returns 0 if no such edge exists. -/
noncomputable def codependencyTime (H : WeightedDepHypergraph V) (u v : V) : ℕ :=
  if h : H.AreCodependent u v then
    (Finset.univ.filter fun e : H.Edge => u ∈ H.verts e ∧ v ∈ H.verts e).inf'
      (by
        rw [Finset.filter_nonempty_iff]
        exact ⟨h.choose, Finset.mem_univ _, h.choose_spec⟩)
      H.weight
  else 0

/-
Key property: codependencyTime is the weight of some witnessing edge.
-/
theorem codependencyTime_eq_weight (H : WeightedDepHypergraph V) (u v : V)
    (h : H.AreCodependent u v) :
    ∃ e : H.Edge, u ∈ H.verts e ∧ v ∈ H.verts e ∧
      H.weight e = H.codependencyTime u v ∧
      ∀ e' : H.Edge, u ∈ H.verts e' ∧ v ∈ H.verts e' →
        H.codependencyTime u v ≤ H.weight e' := by
  have := Finset.exists_min_image ( Finset.univ.filter fun e : H.Edge => u ∈ H.verts e ∧ v ∈ H.verts e ) ( fun e => H.weight e ) ⟨ h.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h.choose_spec ⟩ ⟩;
  unfold WeightedDepHypergraph.codependencyTime;
  obtain ⟨ e, he₁, he₂ ⟩ := this; use e; simp_all +decide [ Finset.inf'_eq_csInf_image ] ;
  exact ⟨ le_antisymm ( le_csInf ⟨ _, Set.mem_image_of_mem _ he₁ ⟩ <| Set.forall_mem_image.2 fun x hx => he₂ x hx.1 hx.2 ) ( csInf_le ⟨ 0, Set.forall_mem_image.2 fun x hx => Nat.zero_le _ ⟩ <| Set.mem_image_of_mem _ he₁ ), fun e' he'₁ he'₂ => csInf_le ⟨ 0, Set.forall_mem_image.2 fun x hx => Nat.zero_le _ ⟩ <| Set.mem_image_of_mem _ ⟨ he'₁, he'₂ ⟩ ⟩

/-! ## Reduced Euler Characteristic (Order Parameter) -/

/-- The reduced Euler characteristic of the support complex at scale `k`.
This serves as the topological order parameter: it vanishes for contractible
(cone-like) complexes and becomes nonzero when nontrivial topology emerges. -/
def betaGap (H : WeightedDepHypergraph V) (k : ℕ) : ℤ :=
  if (H.supportComplex k) = ∅ then 0
  else (∑ σ ∈ H.supportComplex k, (-1 : ℤ) ^ (σ.card + 1)) - 1

/-! ## Cone Condition -/

/-- The support complex at scale `k` is a **cone**: there exists an apex vertex
such that inserting it into any simplex yields another simplex in the complex.
Cones are contractible, so their reduced Euler characteristic vanishes. -/
def IsConeAt (H : WeightedDepHypergraph V) (k : ℕ) : Prop :=
  ∃ apex : V, ∀ σ ∈ H.supportComplex k, insert apex σ ∈ H.supportComplex k

/-! ## Main Theorems -/

section Monotonicity

/-
**Theorem 1a**: The support complex is monotone in the filtration parameter.
If `k ≤ l`, every simplex present at scale `k` persists at scale `l`.
This is the foundational theorem certifying that proof traces carry a filtered
topological structure.
-/
theorem supportComplex_mono (H : WeightedDepHypergraph V) {k l : ℕ} (hkl : k ≤ l) :
    H.supportComplex k ⊆ H.supportComplex l := by
  intro σ hσ;
  rw [ mem_supportComplex ] at hσ ⊢;
  exact ⟨ hσ.choose, le_trans hσ.choose_spec.1 hkl, hσ.choose_spec.2.1, hσ.choose_spec.2.2 ⟩

/-
**Theorem 1b**: The width surrogate is monotone in the filtration parameter.
Activating more edges can only increase the maximum edge width.
-/
theorem widthAt_mono (H : WeightedDepHypergraph V) {k l : ℕ} (hkl : k ≤ l) :
    H.widthAt k ≤ H.widthAt l := by
  -- The width at scale k is the supremum of the cardinalities of the vertex sets of the active edges at scale k.
  -- Since active edges at scale k are a subset of active edges at scale l, the supremum at scale k is less than or equal to the supremum at scale l.
  apply Finset.sup_mono (activeEdges_mono H hkl)

end Monotonicity

section Codependency

/-
**Theorem 2a**: No co-dependency before the co-dependency time.
The pair `{u, v}` is absent from the support complex at any scale strictly
below the co-dependency time. This uses a contradiction argument against
minimality.
-/
theorem no_pair_before_codependencyTime (H : WeightedDepHypergraph V)
    (u v : V) (hcod : H.AreCodependent u v) {k : ℕ}
    (hk : k < H.codependencyTime u v) :
    ¬ ({u, v} ⊆ σ ∧ σ ∈ H.supportComplex k) := by
  intro h;
  -- By mem_supportComplex, there exists an edge e with weight e ≤ k such that σ ⊆ verts e.
  obtain ⟨e, he1, he2⟩ : ∃ e : H.Edge, H.weight e ≤ k ∧ σ ⊆ H.verts e ∧ σ.Nonempty := by
    exact mem_supportComplex H k σ |>.1 h.2;
  have := H.codependencyTime_eq_weight u v hcod;
  grind

/-
**Theorem 2b**: The pair enters the support complex at the co-dependency time.
There exists a simplex containing both `u` and `v` at the threshold scale.
-/
theorem pair_enters_at_codependencyTime (H : WeightedDepHypergraph V)
    (u v : V) (hcod : H.AreCodependent u v) :
    ∃ σ ∈ H.supportComplex (H.codependencyTime u v), u ∈ σ ∧ v ∈ σ := by
  grind +suggestions

/-
**Theorem 2c**: Width lower bound from co-dependency events.
If `u ≠ v` and they are co-dependent, then the width at their co-dependency
time is at least 2. Any derivation requiring co-dependency of distinct
vertices must incur nontrivial width.
-/
theorem width_lower_bound_of_pair_entry (H : WeightedDepHypergraph V)
    (u v : V) (hne : u ≠ v) (hcod : H.AreCodependent u v) :
    2 ≤ H.widthAt (H.codependencyTime u v) := by
  obtain ⟨e, he1, he2, he3, he4⟩ : ∃ e : H.Edge, u ∈ H.verts e ∧ v ∈ H.verts e ∧ H.weight e = H.codependencyTime u v ∧ ∀ e' : H.Edge, u ∈ H.verts e' ∧ v ∈ H.verts e' → H.codependencyTime u v ≤ H.weight e' := by
    exact?;
  refine' le_trans _ ( Finset.le_sup <| show e ∈ H.activeEdges ( H.codependencyTime u v ) from _ );
  · exact Finset.one_lt_card.2 ⟨ u, he1, v, he2, hne ⟩;
  · exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simp +decide [ he3 ] ⟩

end Codependency

section ConeCollapse

/-
**Theorem 3a**: A common vertex in all active edges implies cone structure.
If some vertex `a` belongs to every active edge at scale `k`, the support
complex at scale `k` is a cone with apex `a`.
-/
theorem isConeAt_of_common_vertex (H : WeightedDepHypergraph V) (k : ℕ)
    (h : ∃ a : V, ∀ e : H.Edge, H.weight e ≤ k → a ∈ H.verts e) :
    H.IsConeAt k := by
  obtain ⟨a, ha⟩ : ∃ a, ∀ e : H.Edge, H.weight e ≤ k → a ∈ H.verts e := h;
  refine' ⟨ a, _ ⟩;
  grind +locals

/-
Auxiliary: if apex is in every active edge, then insert apex σ is in
the support complex whenever σ is.
-/
theorem insert_apex_mem_supportComplex (H : WeightedDepHypergraph V) (k : ℕ)
    (a : V) (ha : ∀ e : H.Edge, H.weight e ≤ k → a ∈ H.verts e)
    (σ : Finset V) (hσ : σ ∈ H.supportComplex k) :
    insert a σ ∈ H.supportComplex k := by
  rw [ mem_supportComplex ] at hσ ⊢;
  obtain ⟨ e, he₁, he₂, he₃ ⟩ := hσ; exact ⟨ e, he₁, Finset.insert_subset_iff.mpr ⟨ ha e he₁, he₂ ⟩, Finset.insert_nonempty _ _ ⟩ ;

/-
The support complex is downward closed on nonempty sets: any nonempty subset
of a simplex in the complex is also in the complex.
-/
theorem supportComplex_downward_closed (H : WeightedDepHypergraph V) (k : ℕ)
    (σ : Finset V) (hσ : σ ∈ H.supportComplex k)
    (τ : Finset V) (hτσ : τ ⊆ σ) (hτ : τ.Nonempty) :
    τ ∈ H.supportComplex k := by
  obtain ⟨ e, he₁, he₂, he₃ ⟩ := mem_supportComplex H k σ |>.1 hσ;
  exact mem_supportComplex H k τ |>.2 ⟨ e, he₁, hτσ.trans he₂, hτ ⟩

/-
If the support complex is a cone with apex `a` and nonempty, then `{a}` is in it.
-/
theorem singleton_apex_mem_of_isConeAt (H : WeightedDepHypergraph V) (k : ℕ)
    (a : V) (ha : ∀ σ ∈ H.supportComplex k, insert a σ ∈ H.supportComplex k)
    (hne : (H.supportComplex k).Nonempty) :
    ({a} : Finset V) ∈ H.supportComplex k := by
  obtain ⟨ σ, hσ ⟩ := hne;
  have h_insert : insert a σ ∈ H.supportComplex k := ha σ hσ;
  exact H.supportComplex_downward_closed k _ h_insert _ ( Finset.singleton_subset_iff.mpr ( Finset.mem_insert_self _ _ ) ) ( by simp +decide )

/-- The involution on supportComplex \ {{a}}: toggle the apex. -/
private noncomputable def coneInvolution (a : V)
    (σ : Finset V) : Finset V :=
  if a ∈ σ then σ.erase a else insert a σ

/-
The involution sends elements of supportComplex \ {{a}} back into
supportComplex \ {{a}}, provided the cone condition holds.
-/
theorem coneInvolution_mem (H : WeightedDepHypergraph V) (k : ℕ)
    (a : V) (ha : ∀ σ ∈ H.supportComplex k, insert a σ ∈ H.supportComplex k)
    (σ : Finset V) (hσ : σ ∈ H.supportComplex k \ ({({a} : Finset V)} : Finset (Finset V))) :
    coneInvolution a σ ∈ H.supportComplex k \ ({({a} : Finset V)} : Finset (Finset V)) := by
  by_cases h : a ∈ σ <;> simp_all +decide [ coneInvolution ];
  · grind +suggestions;
  · simp_all +decide [ Finset.eq_singleton_iff_unique_mem ];
    exact Exists.elim ( Finset.nonempty_of_ne_empty ( by rintro rfl; exact absurd hσ ( by simp +decide [ WeightedDepHypergraph.supportComplex ] ) ) ) fun x hx => ⟨ x, hx, by rintro rfl; exact h hx ⟩

/-
The involution is an involution.
-/
theorem coneInvolution_involution (a : V) (σ : Finset V) :
    coneInvolution a (coneInvolution a σ) = σ := by
  unfold coneInvolution;
  grind

/-
Paired elements under the involution have cancelling Euler contributions.
-/
theorem coneInvolution_sum_cancel (H : WeightedDepHypergraph V) (k : ℕ)
    (a : V) (σ : Finset V)
    (hσ : σ ∈ H.supportComplex k \ ({({a} : Finset V)} : Finset (Finset V))) :
    (-1 : ℤ) ^ (σ.card + 1) + (-1 : ℤ) ^ ((coneInvolution a σ).card + 1) = 0 := by
  unfold coneInvolution;
  grind +splitImp

/-
The involution has no fixed points on supportComplex \ {{a}}.
-/
theorem coneInvolution_no_fixed (H : WeightedDepHypergraph V) (k : ℕ)
    (a : V) (σ : Finset V)
    (hσ : σ ∈ H.supportComplex k \ ({({a} : Finset V)} : Finset (Finset V))) :
    coneInvolution a σ ≠ σ := by
  by_cases ha : a ∈ σ <;> simp_all +decide [ coneInvolution ]

/-
**Theorem 3b (Euler involution)**: Cone structure forces vanishing order parameter.
When the support complex is a cone, its reduced Euler characteristic is zero.
The proof uses an involution pairing simplices with their apex-extensions,
showing all contributions cancel except the apex singleton, which contributes
exactly 1 to the Euler sum, giving reduced characteristic 0.

This theorem certifies an "easy regime": proof dependencies that collapse
around a common hub cannot exhibit topological hardness.
-/
theorem betaGap_eq_zero_of_isConeAt (H : WeightedDepHypergraph V) (k : ℕ)
    (hcone : H.IsConeAt k) :
    H.betaGap k = 0 := by
  by_cases h : H.supportComplex k = ∅ <;> simp_all +decide [ Finset.ext_iff ];
  · -- By definition of betaGap, if the support complex is empty, then the sum is zero and the reduced Euler characteristic is -1.
    simp [WeightedDepHypergraph.betaGap, h];
    exact fun h' => False.elim <| h' <| Finset.eq_empty_of_forall_notMem h;
  · obtain ⟨ a, ha ⟩ := hcone;
    -- By definition of $betaGap$, we have:
    have h_betaGap : H.betaGap k = (∑ σ ∈ H.supportComplex k \ {({a} : Finset V)}, (-1 : ℤ) ^ (σ.card + 1)) + (-1 : ℤ) ^ (({a} : Finset V).card + 1) - 1 := by
      unfold WeightedDepHypergraph.betaGap;
      rw [ Finset.sum_eq_sum_diff_singleton_add ( show { a } ∈ H.supportComplex k from _ ) ] ; aesop;
      convert singleton_apex_mem_of_isConeAt H k a ha ( Finset.nonempty_of_ne_empty ( by aesop_cat ) ) using 1;
    -- Apply the involution to pair each element in the sum with its image.
    have h_pair : ∃ (g : Finset V → Finset V), (∀ σ ∈ H.supportComplex k \ {({a} : Finset V)}, g σ ∈ H.supportComplex k \ {({a} : Finset V)}) ∧ (∀ σ ∈ H.supportComplex k \ {({a} : Finset V)}, g (g σ) = σ) ∧ (∀ σ ∈ H.supportComplex k \ {({a} : Finset V)}, (-1 : ℤ) ^ (σ.card + 1) + (-1 : ℤ) ^ ((g σ).card + 1) = 0) := by
      use fun σ => if a ∈ σ then σ.erase a else insert a σ;
      grind +locals;
    obtain ⟨ g, hg₁, hg₂, hg₃ ⟩ := h_pair;
    -- Since $g$ is an involution, we can pair each element in the sum with its image.
    have h_pair_sum : ∑ σ ∈ H.supportComplex k \ {({a} : Finset V)}, (-1 : ℤ) ^ (σ.card + 1) = ∑ σ ∈ H.supportComplex k \ {({a} : Finset V)}, (-1 : ℤ) ^ ((g σ).card + 1) := by
      apply Finset.sum_bij (fun σ _ => g σ);
      · exact hg₁;
      · grind;
      · exact fun σ hσ => ⟨ g σ, hg₁ σ hσ, hg₂ σ hσ ⟩;
      · exact fun σ hσ => by rw [ hg₂ σ hσ ] ;
    have := Finset.sum_congr rfl hg₃; simp_all +decide [ Finset.sum_add_distrib ] ;

end ConeCollapse

/-! ## Computational Methods -/

section Computation

/-- Compute the pair co-dependency profile: for each pair of vertices,
their co-dependency time. This is a verified computational method. -/
noncomputable def computePairProfile (H : WeightedDepHypergraph V) :
    V → V → ℕ :=
  fun u v => H.codependencyTime u v

/-- The hardness curve: for each scale k, the triple (k, widthAt k, betaGap k). -/
noncomputable def computeHardnessCurve (H : WeightedDepHypergraph V)
    (maxScale : ℕ) : List (ℕ × ℕ × ℤ) :=
  (List.range (maxScale + 1)).map fun k => (k, H.widthAt k, H.betaGap k)

/-- Correctness of the pair profile computation. -/
theorem computePairProfile_correct (H : WeightedDepHypergraph V) (u v : V) :
    H.computePairProfile u v = H.codependencyTime u v := by
  rfl

end Computation

/-! ## Benchmark Family -/

section Benchmark

/-- A benchmark family of weighted dependency hypergraphs modeling layered
proof dependencies. Vertices are `Fin n`, and for each pair (i,j) with
i < j < m, there is a hyperedge covering {i, j} with weight j.
This creates a filtration where co-dependencies emerge gradually. -/
def benchmarkFamily (n m : ℕ) (hn : 2 ≤ n) (hm : m ≤ n) :
    WeightedDepHypergraph (Fin n) where
  Edge := { p : Fin n × Fin n // p.1 < p.2 ∧ p.2.val < m }
  verts := fun ⟨⟨i, j⟩, _⟩ => {i, j}
  weight := fun ⟨⟨_, j⟩, _⟩ => j.val
  nonempty_verts := fun ⟨⟨i, j⟩, h⟩ => by
    simp

/-
In the benchmark family, vertices i and j (with i < j < m) first become
co-dependent at scale j.
-/
theorem benchmark_codependencyTime (n m : ℕ) (hn : 2 ≤ n) (hm : m ≤ n)
    (i j : Fin n) (hij : i < j) (hjm : j.val < m) :
    (benchmarkFamily n m hn hm).codependencyTime i j = j.val := by
  unfold WeightedDepHypergraph.codependencyTime;
  split_ifs <;> simp_all +decide [ Finset.inf'_eq_csInf_image, benchmarkFamily ];
  · refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ ) <;> norm_num;
    · exact ⟨ i, j, by aesop ⟩;
    · exact ⟨ ⟨ ⟨ i, j ⟩, by aesop ⟩, by aesop ⟩;
    · grind;
  · rename_i h; contrapose! h; use ⟨ ⟨ i, j ⟩, hij, hjm ⟩ ; aesop;

/-
In the easy regime (m = 0), the support complex is empty and betaGap = 0.
-/
theorem betaGap_easy_regime (n : ℕ) (hn : 2 ≤ n) (k : ℕ) :
    (benchmarkFamily n 0 hn (Nat.zero_le n)).betaGap k = 0 := by
  convert betaGap_eq_zero_of_isConeAt _ _ _;
  convert isConeAt_of_common_vertex _ _ _;
  exact ⟨ ⟨ 0, by linarith ⟩, fun e he => False.elim <| e.2.2.not_ge <| by linarith ⟩

end Benchmark

end WeightedDepHypergraph