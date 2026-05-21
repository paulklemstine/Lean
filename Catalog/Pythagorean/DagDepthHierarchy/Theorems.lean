/-
# DAG Depth Hierarchy — Core Theorems

This file proves that DAG sharing (common subexpression elimination) cannot
reduce the EML depth required to compute iterated exponentials.

## Main Results

1. `EMLDag.eval_unfoldNode`: Unfolding preserves semantics nodewise.
2. `EMLDag.eval_unfold`: Unfolding preserves semantics at the output.
3. `EMLDag.emlDepth_unfoldNode_le`: Unfolding does not increase depth nodewise.
4. `EMLDag.emlDepth_unfold_le`: Unfolding does not increase depth at the output.
5. `EMLDag.noInv_unfoldNode`: Unfolding preserves inverse-freeness nodewise.
6. `EMLDag.noInv_unfold`: Unfolding preserves inverse-freeness at the output.
7. `dag_unfold_preserves_semantics_and_depth`: The structural bridge theorem.
8. `dag_sharing_does_not_reduce_iterExp_depth`: The main lower bound theorem.

## Proof Architecture

We use Strategy A: unfold-to-tree reduction via well-founded recursion on node
indices. Each DAG is unfolded to an EMLExpr tree. We show:
- The tree has the same semantics as the DAG (by induction on index).
- The tree's EML depth is at most the DAG's critical-path depth (by induction).
- The tree inherits inverse-freeness from the DAG.

Then we invoke the existing tree lower bound from `Algebra.TightDepthHierarchy.Theorems`
to conclude that DAG depth must be at least `n` for computing `iterExp n`.
-/
import Speculative.DagDepthHierarchy.Defs
import Algebra.TightDepthHierarchy.Theorems

noncomputable section

open Real EMLExpr EMLDag

/-! ## Unfolding Preserves Semantics -/

/-
The unfolded tree at node `k` evaluates identically to the DAG at node `k`.
    This is the semantic correctness of the unfolding operation.
-/
theorem EMLDag.eval_unfoldNode (G : EMLDag) (x : ℝ) (k : ℕ) (hk : k < G.size) :
    (G.unfoldNode k hk).eval x = G.evalNode x k hk := by
  -- We'll use induction on $k$ to prove that the evaluation of the unfolded tree at node $k$ is equal to the evaluation of the DAG at node $k$.
  induction' k using Nat.strong_induction_on with k ih;
  unfold EMLDag.evalNode EMLDag.unfoldNode;
  rcases h : G.op ⟨ k, hk ⟩ with ( _ | _ | _ | _ | _ | _ | _ ) <;> simp_all +decide;
  all_goals simp +decide [ EMLExpr.eval ];
  · have := G.wf ⟨ k, hk ⟩ ; simp_all +decide [ DagOp.children ] ;
  · have := G.wf ⟨ k, hk ⟩ ; simp_all +decide [ DagOp.children ] ;
  · have := G.wf ⟨ k, hk ⟩ ; simp_all +decide [ DagOp.children ];
  · have := G.wf ⟨ k, hk ⟩ ; simp_all +decide [ DagOp.children ] ;
  · have := G.wf ⟨ k, hk ⟩ ; simp_all +decide [ DagOp.children ] ;

/-- Unfolding the entire DAG preserves semantics at the output. -/
theorem EMLDag.eval_unfold (G : EMLDag) (x : ℝ) :
    (G.unfold).eval x = G.eval x := by
  exact G.eval_unfoldNode x G.output.val G.output.isLt

/-! ## Unfolding Does Not Increase Depth -/

/-
The EML depth of the unfolded tree at node `k` is at most the DAG depth at node `k`.
    This is the structural bridge: sharing can increase tree size but not depth.
-/
theorem EMLDag.emlDepth_unfoldNode_le (G : EMLDag) (k : ℕ) (hk : k < G.size) :
    (G.unfoldNode k hk).emlDepth ≤ G.nodeDepth k hk := by
  induction' k using Nat.strong_induction_on with k ih generalizing G;
  unfold EMLDag.unfoldNode EMLDag.nodeDepth;
  rcases h : G.op ⟨ k, hk ⟩ with ( _ | _ | _ | _ | _ | _ | _ ) <;> simp_all +decide;
  exact rfl;
  · split_ifs <;> simp_all +decide [ EMLExpr.emlDepth ];
    grind;
  · split_ifs <;> simp_all +decide [ EMLExpr.emlDepth ];
    grind;
  · split_ifs <;> simp_all +decide [ EMLExpr.emlDepth ];
  · split_ifs <;> simp_all +decide [ EMLExpr.emlDepth ];
  · split_ifs <;> simp_all +decide [ EMLExpr.emlDepth ];
    grind

/-- The EML depth of the unfolded DAG is at most the DAG's critical-path depth. -/
theorem EMLDag.emlDepth_unfold_le (G : EMLDag) :
    (G.unfold).emlDepth ≤ G.depth := by
  exact G.emlDepth_unfoldNode_le G.output.val G.output.isLt

/-! ## Unfolding Preserves Inverse-Freeness -/

/-
If the DAG is inverse-free, so is the unfolded tree at every node.
-/
theorem EMLDag.noInv_unfoldNode (G : EMLDag) (hInv : G.InverseFree)
    (k : ℕ) (hk : k < G.size) :
    (G.unfoldNode k hk).noInv := by
  induction' k using Nat.strong_induction_on with k ih;
  have := hInv ⟨ k, hk ⟩;
  unfold EMLDag.unfoldNode;
  rcases h : G.op ⟨ k, hk ⟩ with ( _ | _ | _ | _ | _ | _ | _ ) <;> simp_all +decide [ EMLDag.InverseFree ];
  all_goals simp_all +decide [ EMLExpr.noInv ];
  · split_ifs <;> simp_all +decide [ EMLExpr.noInv ];
  · exact ⟨ by split_ifs <;> [ exact ih _ ‹_› _; exact trivial ], by split_ifs <;> [ exact ih _ ‹_› _; exact trivial ] ⟩;
  · split_ifs <;> [ exact ih _ ‹_› _; exact trivial ];
  · cases this;
  · split_ifs <;> simp_all +decide [ EMLExpr.noInv ]

/-- If the DAG is inverse-free, so is its unfolded tree. -/
theorem EMLDag.noInv_unfold (G : EMLDag) (hInv : G.InverseFree) :
    (G.unfold).noInv :=
  G.noInv_unfoldNode hInv G.output.val G.output.isLt

/-! ## The Structural Bridge Theorem -/

/-- **Bridge theorem**: Every inverse-free DAG unfolds to an inverse-free tree
    with the same semantics and depth at most the DAG's depth. -/
theorem dag_unfold_preserves_semantics_and_depth
    (G : EMLDag) (hInv : G.InverseFree) :
    ∃ t : EMLExpr,
      t.noInv ∧
      (∀ x, t.eval x = G.eval x) ∧
      t.emlDepth ≤ G.depth := by
  exact ⟨G.unfold, G.noInv_unfold hInv, fun x => G.eval_unfold x, G.emlDepth_unfold_le⟩

/-! ## The Main Lower Bound Theorem -/

/-- **Main theorem: DAG sharing does not reduce iterExp depth.**

    For every inverse-free DAG `G` that computes `iterExp n` on positive reals,
    the DAG's critical-path depth is at least `n`. -/
theorem dag_sharing_does_not_reduce_iterExp_depth
    (n : ℕ) (G : EMLDag) (hInv : G.InverseFree)
    (hSem : ∀ x : ℝ, 0 < x → G.eval x = iterExp n x) :
    n ≤ G.depth := by
  obtain ⟨t, ht_inv, ht_sem, ht_depth⟩ := dag_unfold_preserves_semantics_and_depth G hInv
  have ht_rep : RepresentsOnPos t (iterExp n) := by
    intro x hx
    rw [ht_sem x, hSem x hx]
  by_contra h
  push_neg at h
  have hlt : t.emlDepth < n := Nat.lt_of_le_of_lt ht_depth h
  exact no_invFree_lowDepth_represents_iterExp (t.emlDepth) n
    hlt ⟨t, ht_inv, le_refl _, ht_rep⟩

/-- Equivalent formulation: the DAG depth is at least `n`. -/
theorem dag_depth_lower_bound_for_iterExp
    (n : ℕ) (G : EMLDag) (hInv : G.InverseFree)
    (hSem : ∀ x : ℝ, 0 < x → G.eval x = iterExp n x) :
    n ≤ G.depth :=
  dag_sharing_does_not_reduce_iterExp_depth n G hInv hSem

/-! ## Cross-Domain Corollaries -/

/-- The sequential depth (parallel time) of any inverse-free DAG computing
    `iterExp n` is at least `n`. -/
theorem sequentialDepth_lower_bound_iterExp
    (n : ℕ) (G : EMLDag) (hInv : G.InverseFree)
    (hSem : ∀ x : ℝ, 0 < x → G.eval x = iterExp n x) :
    n ≤ G.SequentialDepth :=
  dag_sharing_does_not_reduce_iterExp_depth n G hInv hSem

/-- The canonical EMLExpr tree for `iterExp n` achieves depth exactly `n`,
    matching the lower bound. The optimal tree is also optimal among all DAGs. -/
theorem canonical_iterExp_is_dag_optimal (n : ℕ) :
    ¬ ∃ G : EMLDag,
        G.InverseFree ∧ G.depth < n ∧
        (∀ x : ℝ, 0 < x → G.eval x = iterExp n x) := by
  intro ⟨G, hInv, hDepth, hSem⟩
  have := dag_sharing_does_not_reduce_iterExp_depth n G hInv hSem
  omega

end