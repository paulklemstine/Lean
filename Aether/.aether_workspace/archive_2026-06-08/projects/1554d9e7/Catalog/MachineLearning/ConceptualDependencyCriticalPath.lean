import Mathlib

/-!
# Conceptual Dependency Critical Path Theory

This file formalizes a theory of **conceptual depth** for dependency graphs
and proves that the critical path length provides a tight lower bound on
any layered discovery process.

## Main results

* `mem_discovered_imp_depth_le` — **Theorem A1**: discovery round ≥ depth.
* `exists_node_of_depth_eq_criticalPath` — **Theorem B1**: critical path is attained.
* `exists_not_mem_discovered_of_lt_criticalPath` — **Theorem B2**: shallow search fails.
* `discovered_eq_univ_at_criticalPath` — **Theorem C1**: guided search is complete.
* `critical_path_policy_finds_shallowly_inaccessible` — synthesis theorem.
-/

open Finset

/-- A dependency graph on a finite type `V`. -/
structure DepGraph (V : Type*) [Fintype V] [DecidableEq V] where
  pred : V → Finset V
  wf : WellFounded (fun u v => u ∈ pred v)

namespace DepGraph

variable {V : Type*} [Fintype V] [DecidableEq V]

def isSource (G : DepGraph V) (v : V) : Prop := G.pred v = ∅

instance (G : DepGraph V) (v : V) : Decidable (G.isSource v) :=
  inferInstanceAs (Decidable (G.pred v = ∅))

def sourceSet (G : DepGraph V) : Finset V :=
  Finset.univ.filter G.isSource

/-- Depth of a node: 0 for sources, 1 + max(depth of predecessors) otherwise. -/
noncomputable def depth (G : DepGraph V) : V → ℕ :=
  G.wf.fix fun v ih =>
    if h : G.pred v = ∅ then 0
    else (G.pred v).attach.sup (fun ⟨u, hu⟩ => ih u hu) + 1

theorem depth_eq (G : DepGraph V) (v : V) :
    G.depth v = if G.pred v = ∅ then 0
      else (G.pred v).attach.sup (fun ⟨u, _⟩ => G.depth u) + 1 := by
  convert G.wf.fix_eq _ v

theorem depth_zero_of_pred_empty (G : DepGraph V) (v : V) (h : G.pred v = ∅) :
    G.depth v = 0 := by rw [depth_eq]; simp [h]

theorem depth_zero_of_isSource (G : DepGraph V) (v : V) (h : G.isSource v) :
    G.depth v = 0 := depth_zero_of_pred_empty G v h

/-
If `u` is a predecessor of `v`, then `depth u < depth v`.
-/
theorem depth_pred_lt (G : DepGraph V) (u v : V) (h : u ∈ G.pred v) :
    G.depth u < G.depth v := by
  -- By definition of depth, if $u \in \text{pred } v$, then $\text{depth } u$ is part of the supremum in the definition of $\text{depth } v$.
  have h_depth_v : G.depth v = if G.pred v = ∅ then 0 else (G.pred v).attach.sup (fun ⟨u, _⟩ => G.depth u) + 1 := by
    grind +suggestions;
  rw [ h_depth_v ] ; simp_all +decide [ Finset.sup_le_iff ];
  grind +suggestions

-- Layer-based discovery

def nextLayer (G : DepGraph V) (A : Finset V) : Finset V :=
  Finset.univ.filter (fun v => v ∉ A ∧ ∀ u ∈ G.pred v, u ∈ A)

def discovered (G : DepGraph V) (S : Finset V) : ℕ → Finset V
  | 0 => S
  | n + 1 => G.discovered S n ∪ G.nextLayer (G.discovered S n)

theorem discovered_mono (G : DepGraph V) (S : Finset V) (n : ℕ) :
    G.discovered S n ⊆ G.discovered S (n + 1) :=
  Finset.subset_union_left

theorem discovered_mono_of_le (G : DepGraph V) (S : Finset V) {m n : ℕ} (h : m ≤ n) :
    G.discovered S m ⊆ G.discovered S n := by
  induction h with
  | refl => exact Finset.Subset.refl _
  | step _ ih => exact ih.trans (G.discovered_mono S _)

/-
**Theorem A1**: If `v` is discovered by round `n`, then `depth v ≤ n`.
-/
theorem mem_discovered_imp_depth_le (G : DepGraph V) (S : Finset V)
    (hS : ∀ v ∈ S, G.isSource v) :
    ∀ {n v}, v ∈ G.discovered S n → G.depth v ≤ n := by
  intro n v hv
  induction' n with n ih generalizing v;
  · exact G.depth_zero_of_isSource v ( hS v hv ) ▸ le_rfl;
  · simp_all +decide [ DepGraph.discovered, DepGraph.nextLayer ];
    rcases hv with ( hv | ⟨ hv₁, hv₂ ⟩ );
    · exact Nat.le_succ_of_le ( ih hv );
    · rw [ G.depth_eq ];
      split_ifs <;> simp_all +decide [ Finset.sup_le_iff ]

noncomputable def criticalPathLength (G : DepGraph V) : ℕ :=
  Finset.univ.sup G.depth

/-
**Theorem B1**: some node attains the critical path length.
-/
theorem exists_node_of_depth_eq_criticalPath (G : DepGraph V) [Nonempty V] :
    ∃ v : V, G.depth v = G.criticalPathLength := by
  convert Finset.exists_max_image Finset.univ G.depth ( Finset.univ_nonempty );
  exact ⟨ fun h => ⟨ Finset.mem_univ _, fun x' _ => h ▸ Finset.le_sup ( f := G.depth ) ( Finset.mem_univ x' ) ⟩, fun h => le_antisymm ( Finset.le_sup ( f := G.depth ) ( Finset.mem_univ _ ) ) ( Finset.sup_le fun x' _ => h.2 x' ‹_› ) ⟩

/-
Every node is discovered from sources by its depth round.
-/
theorem mem_discovered_of_le_depth (G : DepGraph V) (v : V) :
    v ∈ G.discovered G.sourceSet (G.depth v) := by
  -- By induction on the depth of $v$, we can show that $v$ is discovered at depth $d$.
  induction' h : G.depth v with d hd generalizing v;
  · -- If the depth of $v$ is 0, then $v$ is a source.
    have h_source : G.isSource v := by
      rw [ DepGraph.depth_eq ] at h ; aesop;
    exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, h_source ⟩;
  · -- By definition of depth, if $G.depth v = d + 1$, then all predecessors of $v$ have depth at most $d$.
    have h_predecessors : ∀ u ∈ G.pred v, G.depth u ≤ d := by
      exact fun u hu => Nat.le_of_lt_succ ( by linarith [ G.depth_pred_lt u v hu ] );
    -- By definition of `nextLayer`, since all predecessors of `v` are in `discovered G.sourceSet d`, `v` must be in `nextLayer (discovered G.sourceSet d)`.
    have h_nextLayer : v ∈ G.nextLayer (G.discovered G.sourceSet d) := by
      refine' Finset.mem_filter.mpr ⟨ Finset.mem_univ _, _, _ ⟩;
      · exact fun hv => by linarith [ G.mem_discovered_imp_depth_le G.sourceSet ( fun v hv => Finset.mem_filter.mp hv |>.2 ) hv ] ;
      · intro u hu;
        have h_discovered : ∀ n, ∀ u, G.depth u ≤ n → u ∈ G.discovered G.sourceSet n := by
          intro n u hu;
          induction' n with n ih generalizing u;
          · rw [ depth_eq ] at hu;
            split_ifs at hu ; simp_all +singlePass;
            · exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simpa [ DepGraph.isSource ] using ‹G.pred u = ∅› ⟩;
            · contradiction;
          · by_cases hu' : G.depth u ≤ n;
            · exact Finset.mem_union_left _ ( ih u hu' );
            · have h_discovered : ∀ u, G.depth u = n + 1 → u ∈ G.nextLayer (G.discovered G.sourceSet n) := by
                intro u hu
                have h_predecessors : ∀ u, G.depth u = n + 1 → ∀ v ∈ G.pred u, G.depth v ≤ n := by
                  exact fun u hu v hv => Nat.le_of_lt_succ ( by linarith [ G.depth_pred_lt v u hv ] );
                refine' Finset.mem_filter.mpr ⟨ Finset.mem_univ _, _, _ ⟩;
                · intro h;
                  have := mem_discovered_imp_depth_le G G.sourceSet ( fun v hv => by
                    exact Finset.mem_filter.mp hv |>.2 ) h;
                  linarith;
                · exact fun v hv => ih v ( h_predecessors u hu v hv );
              exact Finset.mem_union_right _ ( h_discovered u ( by linarith ) );
        exact h_discovered d u ( h_predecessors u hu );
    exact Finset.mem_union_right _ h_nextLayer

/-- **Theorem C1**: after `criticalPathLength` rounds, all nodes are discovered. -/
theorem discovered_eq_univ_at_criticalPath (G : DepGraph V) :
    G.discovered G.sourceSet G.criticalPathLength = Finset.univ := by
  ext v; simp only [Finset.mem_univ, iff_true]
  exact G.discovered_mono_of_le G.sourceSet
    (Finset.le_sup (f := G.depth) (Finset.mem_univ v))
    (G.mem_discovered_of_le_depth v)

/-- **Theorem B2**: shallow exploration misses deep targets. -/
theorem exists_not_mem_discovered_of_lt_criticalPath (G : DepGraph V) [Nonempty V]
    (S : Finset V) (hS : ∀ v ∈ S, G.isSource v)
    {k : ℕ} (hk : k < G.criticalPathLength) :
    ∃ v : V, v ∉ G.discovered S k := by
  by_contra hall; push_neg at hall
  have hle : G.criticalPathLength ≤ k :=
    Finset.sup_le fun v _ => G.mem_discovered_imp_depth_le S hS (hall v)
  omega

/-- **Synthesis theorem** -/
theorem critical_path_policy_finds_shallowly_inaccessible (G : DepGraph V) [Nonempty V]
    {k : ℕ} (hk : k < G.criticalPathLength) :
    ∃ v : V, G.depth v = G.criticalPathLength ∧
      v ∉ G.discovered G.sourceSet k := by
  obtain ⟨v, hv⟩ := G.exists_node_of_depth_eq_criticalPath
  exact ⟨v, hv, fun hmem => by
    have := G.mem_discovered_imp_depth_le G.sourceSet
      (fun w hw => by
        simp only [sourceSet, Finset.mem_filter, Finset.mem_univ, true_and] at hw
        exact hw) hmem
    omega⟩

/-
Depth is bounded by `|V| - 1`.
-/
theorem depth_le_card_sub_one (G : DepGraph V) (v : V) :
    G.depth v ≤ Fintype.card V - 1 := by
  -- By induction on the depth of $v$, we can show that the depth of $v$ is at most the cardinality of the set of all nodes minus one.
  have h_ind : ∀ v : V, G.depth v ≤ (Finset.univ : Finset V).card - 1 := by
    intro v
    have h_card : (Finset.univ : Finset V).card ≥ G.depth v + 1 := by
      -- By induction on the depth of $v$, we can show that the number of nodes reachable from $v$ (including $v$ itself) is at least $depth v + 1$.
      have h_reachable : ∀ v : V, (Finset.filter (fun u => G.depth u ≤ G.depth v) (Finset.univ : Finset V)).card ≥ G.depth v + 1 := by
        intro v
        induction' h : G.depth v with d hd generalizing v;
        · exact Finset.card_pos.mpr ⟨ v, by simpa [ h ] ⟩;
        · -- Since $G.depth v = d + 1$, there exists a predecessor $u$ of $v$ such that $G.depth u = d$.
          obtain ⟨u, hu⟩ : ∃ u ∈ G.pred v, G.depth u = d := by
            have h_pred : ∃ u ∈ G.pred v, ∀ w ∈ G.pred v, G.depth w ≤ G.depth u := by
              apply_rules [ Finset.exists_max_image ];
              contrapose! h; simp_all +singlePass [ DepGraph.depth ] ;
              rw [ WellFounded.fix_eq ] ; aesop;
            obtain ⟨ u, hu₁, hu₂ ⟩ := h_pred;
            have h_depth_u : G.depth v = G.depth u + 1 := by
              rw [ G.depth_eq ];
              rw [ if_neg ( Finset.Nonempty.ne_empty ⟨ u, hu₁ ⟩ ) ];
              refine' le_antisymm _ _ <;> norm_num;
              · exact hu₂;
              · exact Finset.le_sup ( f := G.depth ) hu₁;
            grind +qlia;
          have h_reachable : (Finset.filter (fun u => G.depth u ≤ d + 1) (Finset.univ : Finset V)) ⊇ (Finset.filter (fun u => G.depth u ≤ d) (Finset.univ : Finset V)) ∪ {v} := by
            grind;
          refine' le_trans _ ( Finset.card_mono h_reachable );
          grind;
      exact le_trans ( h_reachable v ) ( Finset.card_le_univ _ );
    exact Nat.le_sub_one_of_lt h_card;
  exact h_ind v

end DepGraph