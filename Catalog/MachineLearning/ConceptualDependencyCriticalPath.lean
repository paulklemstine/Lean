import Mathlib

/-!
# Conceptual Dependency Graphs and Critical Path Analysis

This file formalizes a theory of **conceptual depth** extracted from dependency
structures in mathematics. We model mathematical knowledge as a finite directed
acyclic graph (DAG) where nodes represent theorems/concepts and edges represent
logical dependencies.

## Main definitions

* `DepGraph V` — a finite DAG given by a predecessor map with a well-founded
  predecessor relation.
* `DepGraph.depth` — the conceptual depth of a node: the length of the longest
  directed path ending at that node.
* `DepGraph.discovered` — the set of nodes discoverable from a seed set in at
  most `n` rounds of layered exploration.
* `DepGraph.criticalPathLength` — the maximum depth over all nodes.

## Main results

* **Theorem A1** (`mem_discovered_imp_depth_le`): Any node discovered in `n`
  rounds from sources has depth at most `n`. This is the central lower bound
  theorem — it certifies that deep results cannot be reached by shallow search.

* **Theorem B1** (`exists_node_of_depth_eq_criticalPath`): In every finite
  nonempty DAG, there exists a node attaining the critical path length.

* **Theorem B2** (`exists_not_mem_discovered_of_lt_criticalPath`): If the
  search budget `k` is strictly less than the critical path length, there exist
  nodes that remain undiscovered.

* **Theorem C1** (`discovered_eq_univ_at_criticalPath`): Critical-path-guided
  exploration discovers all nodes in exactly `criticalPathLength` rounds.

* **Policy theorem** (`critical_path_policy_finds_inaccessible`): Combining B1
  and B2, there exist maximum-depth nodes that are provably inaccessible to any
  bounded-depth exploration below the critical path.

## Significance

These theorems turn "deep theorem" from informal rhetoric into a certifiable
graph invariant. They establish that some mathematical results are intrinsically
inaccessible to shallow search — not merely harder in practice, but unavoidable
in principle because their dependency geometry forces conceptual depth.
-/

namespace ConceptualDependency

/-- A finite directed acyclic graph represented by a predecessor map.
    `pred v` gives the set of immediate predecessors (dependencies) of node `v`.
    The well-foundedness condition `wf` ensures acyclicity. -/
structure DepGraph (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The predecessor (dependency) map: `pred v` is the set of nodes that `v`
      directly depends on. -/
  pred : V → Finset V
  /-- The predecessor relation is well-founded, ensuring the graph is acyclic. -/
  wf : WellFounded (fun u v => u ∈ pred v)

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ### Source nodes -/

/-- A node is a **source** if it has no predecessors (no dependencies). -/
def DepGraph.isSource (G : DepGraph V) (v : V) : Prop := G.pred v = ∅

instance (G : DepGraph V) (v : V) : Decidable (G.isSource v) :=
  inferInstanceAs (Decidable (G.pred v = ∅))

/-- The set of all source nodes in the graph. -/
def DepGraph.sourceSet (G : DepGraph V) : Finset V :=
  Finset.univ.filter (fun v => G.pred v = ∅)

/-! ### Conceptual depth -/

/-- The **conceptual depth** of a node: the length of the longest directed path
    ending at that node. Sources have depth 0. For non-sources, the depth is
    one plus the maximum depth among predecessors.

    Defined by well-founded recursion on the predecessor relation. -/
noncomputable def DepGraph.depth (G : DepGraph V) : V → ℕ :=
  G.wf.fix (fun v ih => (G.pred v).attach.sup (fun ⟨u, hu⟩ => ih u hu + 1))

/-
Unfolding lemma for depth: `depth v = max over predecessors u of (depth u + 1)`.
-/
lemma DepGraph.depth_eq (G : DepGraph V) (v : V) :
    G.depth v = (G.pred v).attach.sup (fun ⟨u, hu⟩ => G.depth u + 1) := by
  convert WellFounded.fix_eq G.wf _ v

/-
Sources have depth 0.
-/
lemma DepGraph.depth_eq_zero_of_isSource (G : DepGraph V) {v : V} (h : G.isSource v) :
    G.depth v = 0 := by
  unfold DepGraph.depth;
  rw [ WellFounded.fix_eq ];
  -- Since the predecessor set of v is empty, the attach of the predecessor set is also empty.
  have h_attach_empty : (G.pred v).attach = ∅ := by
    aesop;
  exact h_attach_empty.symm ▸ rfl

/-
The depth of a predecessor is strictly less than the depth of the node.
-/
lemma DepGraph.depth_pred_lt (G : DepGraph V) {u v : V} (h : u ∈ G.pred v) :
    G.depth u < G.depth v := by
  -- By definition of `depth`, we know that `depth v` is the length of the longest path ending at `v`.
  have h_depth_v : G.depth v = (G.pred v).attach.sup (fun ⟨u, hu⟩ => G.depth u + 1) := by
    exact G.depth_eq v;
  exact h_depth_v.symm ▸ lt_of_lt_of_le ( Nat.lt_succ_self _ ) ( Finset.le_sup ( f := fun ⟨ u, hu ⟩ => G.depth u + 1 ) ( Finset.mem_attach _ ⟨ u, h ⟩ ) )

/-
The depth of any node is bounded by `Fintype.card V - 1`.
-/
lemma DepGraph.depth_le_card_sub_one (G : DepGraph V) (v : V) :
    G.depth v ≤ Fintype.card V - 1 := by
  have h_ind : ∀ (v : V), G.depth v ≤ Fintype.card V - 1 := by
    intro v
    by_contra h_contra
    have h_card : Fintype.card V < G.depth v + 1 := by
      omega;
    -- We construct an injective function from `Fin (G.depth v + 1)` to `V` by following a chain of predecessors.
    have h_chain : ∃ (f : Fin (G.depth v + 1) → V), Function.Injective f ∧ ∀ i : Fin (G.depth v + 1), G.depth (f i) = G.depth v - i.val := by
      have h_chain : ∀ (v : V) (k : ℕ), k ≤ G.depth v → ∃ (f : Fin (k + 1) → V), Function.Injective f ∧ ∀ i : Fin (k + 1), G.depth (f i) = G.depth v - i.val := by
        intro v k hk
        induction' k with k ih generalizing v;
        · exact ⟨ fun _ => v, by simp +decide [ Function.Injective ], by simp +decide ⟩;
        · -- By definition of depth, there exists a predecessor $u$ of $v$ such that $G.depth u = G.depth v - 1$.
          obtain ⟨u, hu⟩ : ∃ u ∈ G.pred v, G.depth u = G.depth v - 1 := by
            have h_depth_eq : G.depth v = (G.pred v).attach.sup (fun ⟨u, hu⟩ => G.depth u + 1) := by
              grind +suggestions;
            have := Finset.exists_max_image ( Finset.attach ( G.pred v ) ) ( fun x => G.depth x + 1 ) ⟨ ⟨ Classical.choose ( show ∃ u, u ∈ G.pred v from by
                                                                                                                              by_cases h_empty : G.pred v = ∅;
                                                                                                                              · simp_all +singlePass [ DepGraph.depth_eq_zero_of_isSource ];
                                                                                                                              · exact Finset.nonempty_of_ne_empty h_empty ), Classical.choose_spec ( show ∃ u, u ∈ G.pred v from by
                                                                                                                                                                                              by_cases h_empty : G.pred v = ∅;
                                                                                                                                                                                              · simp_all +singlePass [ DepGraph.depth_eq_zero_of_isSource ];
                                                                                                                                                                                              · exact Finset.nonempty_of_ne_empty h_empty ) ⟩, Finset.mem_attach _ _ ⟩
            generalize_proofs at *;
            obtain ⟨ x, hx₁, hx₂ ⟩ := this;
            use x.val;
            exact ⟨ x.2, eq_tsub_of_add_eq <| le_antisymm ( h_depth_eq.symm ▸ Finset.le_sup ( f := fun x : { x // x ∈ G.pred v } => G.depth x + 1 ) hx₁ ) ( h_depth_eq.symm ▸ Finset.sup_le fun y hy => hx₂ y hy ) ⟩;
          obtain ⟨ f, hf₁, hf₂ ⟩ := ih u ( by omega );
          refine' ⟨ Fin.cons v f, _, _ ⟩ <;> simp_all +decide [ Function.Injective ];
          · simp +decide [ Fin.forall_fin_succ, hf₁ ];
            grind;
          · intro i; induction i using Fin.inductionOn <;> simp_all +decide [ Nat.sub_sub ] ;
            lia;
      exact h_chain v _ le_rfl;
    obtain ⟨ f, hf_inj, hf_depth ⟩ := h_chain; have := Fintype.card_le_of_injective f hf_inj; simp_all +decide ;
    grind +locals;
  exact h_ind v

/-! ### Layered discovery process -/

/-- The **next layer**: nodes not yet discovered whose predecessors are all discovered. -/
def DepGraph.nextLayer (G : DepGraph V) (A : Finset V) : Finset V :=
  Finset.univ.filter (fun v => v ∉ A ∧ ∀ u ∈ G.pred v, u ∈ A)

/-- The set of nodes **discovered** from seed set `S` in at most `n` rounds. -/
def DepGraph.discovered (G : DepGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | n + 1 => G.discovered S n ∪ G.nextLayer (G.discovered S n)

/-
Discovery is monotone: the discovered set grows with each round.
-/
lemma DepGraph.discovered_subset_succ (G : DepGraph V) (S : Finset V) (n : ℕ) :
    G.discovered S n ⊆ G.discovered S (n + 1) := by
  exact Finset.subset_union_left

/-
Discovery is monotone across arbitrary steps.
-/
lemma DepGraph.discovered_mono (G : DepGraph V) (S : Finset V) {m n : ℕ} (h : m ≤ n) :
    G.discovered S m ⊆ G.discovered S n := by
  exact Nat.le_induction ( by tauto ) ( fun k hk ih => by exact Finset.Subset.trans ih ( G.discovered_subset_succ S k ) ) n h

/-
Membership in the next layer implies all predecessors were already discovered.
-/
lemma DepGraph.pred_mem_of_mem_nextLayer (G : DepGraph V) {A : Finset V} {v : V}
    (hv : v ∈ G.nextLayer A) : ∀ u ∈ G.pred v, u ∈ A := by
  exact fun u hu => Finset.mem_filter.mp hv |>.2.2 u hu

/-! ### Critical path length -/

/-- The **critical path length** of a DAG: the maximum depth over all nodes. -/
noncomputable def DepGraph.criticalPathLength (G : DepGraph V) : ℕ :=
  Finset.univ.sup G.depth

/-! ## Main theorems -/

/-
**Theorem A1 (Depth Lower Bound).**
    Any node discovered from sources in `n` rounds has depth at most `n`.
    This is the central theorem: it certifies that the critical path length
    is an intrinsic lower bound on the number of discovery rounds needed.
-/
theorem DepGraph.mem_discovered_imp_depth_le (G : DepGraph V) (S : Finset V)
    (hsources : ∀ v ∈ S, G.isSource v)
    {n : ℕ} {v : V} (hv : v ∈ G.discovered S n) : G.depth v ≤ n := by
  induction' n with n ih generalizing v <;> simp_all +decide [ DepGraph.discovered ];
  · exact G.depth_eq_zero_of_isSource ( hsources v hv );
  · rcases hv with ( hv | hv );
    · exact Nat.le_succ_of_le ( ih hv );
    · have h_pred_depth : ∀ u ∈ G.pred v, G.depth u ≤ n := by
        exact fun u hu => ih ( G.pred_mem_of_mem_nextLayer hv u hu );
      rw [ DepGraph.depth_eq ];
      exact Finset.sup_le fun x hx => Nat.succ_le_succ ( h_pred_depth _ x.2 )

/-
**Theorem B1 (Critical Path Attainment).**
    In every finite nonempty DAG, there exists a node whose depth equals
    the critical path length.
-/
theorem DepGraph.exists_node_of_depth_eq_criticalPath (G : DepGraph V) [Nonempty V] :
    ∃ v : V, G.depth v = G.criticalPathLength := by
  -- Since `V` is nonempty, there must exist a node `v` such that `G.depth v = Finset.univ.sup G.depth`.
  have h_exists_max : ∃ v : V, ∀ u : V, G.depth u ≤ G.depth v := by
    simpa using Finset.exists_max_image Finset.univ G.depth ⟨ Classical.arbitrary V, Finset.mem_univ _ ⟩;
  exact ⟨ h_exists_max.choose, le_antisymm ( Finset.le_sup ( f := G.depth ) ( Finset.mem_univ _ ) ) ( Finset.sup_le fun u _ => h_exists_max.choose_spec u ) ⟩

/-
**Theorem B2 (Shallow Search Misses Deep Targets).**
    If the search budget `k` is strictly below the critical path length,
    some node remains undiscovered.
-/
theorem DepGraph.exists_not_mem_discovered_of_lt_criticalPath (G : DepGraph V)
    (S : Finset V) (hsources : ∀ v ∈ S, G.isSource v)
    [Nonempty V] {k : ℕ} (hk : k < G.criticalPathLength) :
    ∃ v : V, v ∉ G.discovered S k := by
  -- By Theorem B1, there exists a node v with depth equal to the critical path length.
  obtain ⟨v, hv⟩ : ∃ v : V, G.depth v = G.criticalPathLength := by
    exact G.exists_node_of_depth_eq_criticalPath;
  exact ⟨ v, fun h => by linarith [ DepGraph.mem_discovered_imp_depth_le G S hsources h ] ⟩

/-
Helper: every node is discovered from the source set by its own depth.
-/
lemma DepGraph.mem_discovered_sourceSet_depth (G : DepGraph V)
    (S : Finset V) (hsources : ∀ v, G.isSource v → v ∈ S) (v : V) :
    v ∈ G.discovered S (G.depth v) := by
  -- By well-founded induction, we can show that for any node $v$, $v$ is in the discovered set at step $G.depth v$.
  induction' h : G.depth v using Nat.strong_induction_on with k ih generalizing v;
  by_cases h_source : G.isSource v;
  · rw [ DepGraph.depth_eq_zero_of_isSource ] at h <;> aesop;
  · -- Since $v$ is not a source, there exists some $u \in G.pred v$ such that $G.depth u < k$.
    obtain ⟨u, hu⟩ : ∃ u ∈ G.pred v, G.depth u < k := by
      have h_depth_lt : ∃ u ∈ G.pred v, G.depth u < G.depth v := by
        exact Exists.elim ( Finset.nonempty_of_ne_empty ( show G.pred v ≠ ∅ from fun h => h_source <| by simp +decide [ h, DepGraph.isSource ] ) ) fun u hu => ⟨ u, hu, G.depth_pred_lt hu ⟩ ;
      aesop;
    rcases k with ( _ | k ) <;> simp_all +decide [ DepGraph.discovered ];
    refine' Classical.or_iff_not_imp_left.2 fun h => Finset.mem_filter.2 ⟨ Finset.mem_univ _, h, _ ⟩;
    intro w hw;
    have hw_depth : G.depth w ≤ k := by
      have := G.depth_pred_lt hw; linarith;
    exact G.discovered_mono S hw_depth ( ih _ hw_depth _ rfl )

/-
**Theorem C1 (Guided Completeness).**
    Critical-path-guided exploration from all sources discovers every node
    in exactly `criticalPathLength` rounds. This is the constructive upper bound.
-/
theorem DepGraph.discovered_eq_univ_at_criticalPath (G : DepGraph V)
    (S : Finset V) (hsources : ∀ v, G.isSource v → v ∈ S) :
    G.discovered S G.criticalPathLength = Finset.univ := by
  have h_univ_subset : ∀ v, v ∈ G.discovered S (G.depth v) := by
    exact fun v => G.mem_discovered_sourceSet_depth S hsources v;
  exact Finset.eq_univ_of_forall fun v => by exact G.discovered_mono S ( show G.depth v ≤ G.criticalPathLength from Finset.le_sup ( f := G.depth ) ( Finset.mem_univ v ) ) ( h_univ_subset v ) ;

/-
**Policy Theorem (Critical-Path Guidance Finds Inaccessible Targets).**
    There exist maximum-depth nodes that are provably inaccessible to any
    exploration capped below the critical path length.
-/
theorem DepGraph.critical_path_policy_finds_inaccessible (G : DepGraph V)
    [Nonempty V] (S : Finset V)
    (hsources_sub : ∀ v ∈ S, G.isSource v)
    (_hsources_sup : ∀ v, G.isSource v → v ∈ S)
    {k : ℕ} (hk : k < G.criticalPathLength) :
    ∃ v : V, G.depth v = G.criticalPathLength ∧ v ∉ G.discovered S k := by
  -- By Theorem B1, there exists a node v with depth equal to the critical path length.
  obtain ⟨v, hv⟩ : ∃ v : V, G.depth v = G.criticalPathLength := by
    exact DepGraph.exists_node_of_depth_eq_criticalPath G;
  exact ⟨ v, hv, fun h => hk.not_ge ( hv ▸ G.mem_discovered_imp_depth_le S hsources_sub h ) ⟩

/-! ## Weighted conceptual depth (extension) -/

/-- A weighted dependency graph adds a novelty weight to each node. -/
structure WDepGraph (V : Type*) [Fintype V] [DecidableEq V] extends DepGraph V where
  /-- Weight (conceptual novelty cost) of each node. -/
  weight : V → ℕ
  /-- Every node has positive weight. -/
  weight_pos : ∀ v, 0 < weight v

/-- **Weighted depth**: the maximum sum of weights along a directed path to `v`. -/
noncomputable def WDepGraph.wdepth (G : WDepGraph V) : V → ℕ :=
  G.toDepGraph.wf.fix (fun v ih =>
    if h : (G.pred v).Nonempty then
      (G.pred v).attach.sup' (Finset.Nonempty.attach h) (fun ⟨u, hu⟩ => ih u hu) + G.weight v
    else G.weight v)

/-- The weighted critical path length. -/
noncomputable def WDepGraph.wcriticalPathLength (G : WDepGraph V) : ℕ :=
  Finset.univ.sup G.wdepth

end ConceptualDependency