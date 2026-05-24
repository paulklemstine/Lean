/-
Copyright (c) 2025. All rights reserved.

# Clause Interaction Pathwidth: Main Theorems

## Main Results

1. **Separator Theorem** (`path_bag_separates`): Every cut bag acts as a separator.
2. **Active Frontier Bound** (`activeFrontier_subset_bag`, `activeFrontier_card_le_width_succ`):
   The active frontier is contained in the cut bag, giving a uniform memory bound.
3. **Local Edge Preservation** (`retainAtCut_preserves_frontier_edges`):
   Path-respecting forgetting preserves all edges within the active frontier.
4. **Bag Locality** (`bag_locality_of_clause_evaluation`):
   Clause evaluation depends only on bag-local variable assignments.
5. **Cut Locality** (`cut_locality`): Retained clauses evaluate identically
   under assignments agreeing on the cut bag's variables.
-/
import Pythagorean.ClauseInteractionPathwidth.Defs

open Finset List

variable {α : Type*} [DecidableEq α]

/-! ## Key Lemma: Interval of occurrence -/

/-- If a vertex appears in bags at positions `i` and `k` with `i ≤ k`, it appears
in every bag between them. -/
theorem mem_bag_between
    {V : Type*} [DecidableEq V] {G : SimpleGraph V}
    (P : PathDecomp G)
    (v : V) (i j k : ℕ)
    (hij : i ≤ j) (hjk : j ≤ k)
    (hi : i < P.bags.length)
    (hj : j < P.bags.length)
    (hk : k < P.bags.length)
    (hvi : v ∈ P.bags.get ⟨i, hi⟩)
    (hvk : v ∈ P.bags.get ⟨k, hk⟩) :
    v ∈ P.bags.get ⟨j, hj⟩ :=
  P.running_intersection v i k (le_trans hij hjk) hi hk hvi hvk j hij hjk hj

/-! ## Theorem 1: Separator Theorem for Path Decompositions -/

/-- **Separator Theorem**: For any path decomposition of the clause interaction graph,
every cut bag acts as a separator. If clause `C` appears in some bag before cut `i` and
clause `D` appears in some bag after cut `i`, and `C` and `D` are adjacent in the
interaction graph, then at least one of them must also appear in the cut bag `i`.

This is the structural fact justifying bounded-memory clause retention:
information flow between "past" and "future" must pass through the separator. -/
theorem path_bag_separates
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) :
    ∀ {C D : Clause α},
      C ∈ F →
      D ∈ F →
      (∃ j, ∃ (_ : j < P.bags.length), j < i ∧ C ∈ P.bags.get ⟨j, ‹_›⟩) →
      (∃ k, ∃ (_ : k < P.bags.length), i < k ∧ D ∈ P.bags.get ⟨k, ‹_›⟩) →
      clausesAdjacent C D →
      C ∈ P.bags.get ⟨i, hi⟩ ∨ D ∈ P.bags.get ⟨i, hi⟩ := by
  intro C D hC hD hC' hD' h
  have := @P.edge_covered
  contrapose! this; simp_all +decide [confGraph]
  obtain ⟨j, hj₁, hj₂, hj₃⟩ := hC'
  obtain ⟨k, hk₁, hk₂, hk₃⟩ := hD'
  refine ⟨C, D, ⟨hC, hD, ?_, h⟩, ?_⟩
  · rintro rfl; simp_all +decide [clausesAdjacent]
    exact this (mem_bag_between P C j i k (by linarith) (by linarith) hj₂ hi hk₂ hj₃ hk₃)
  · intro m hm₁ hm₂ hm₃
    by_cases hm₄ : m ≤ i
    · exact this.2 (mem_bag_between P _ _ _ _ hm₄ (by linarith) hm₁ (by linarith) (by linarith) hm₃ hk₃)
    · exact this.1 (mem_bag_between P C j i m (by linarith) (by linarith) hj₂ hi (by linarith) hj₃ hm₂)

/-! ## Theorem 2: Active Frontier Bound -/

/-- The active frontier at any position `i` is a subset of the bag at position `i`.
This is because any clause appearing both before/at `i` and at/after `i` must
(by the interval property) appear in bag `i` itself. -/
theorem activeFrontier_subset_bag
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) :
    activeFrontier F P i ⊆ P.bags.get ⟨i, hi⟩ := by
  intro CC
  simp [activeFrontier]
  exact fun h x hx hx' hx'' y hy hy' hy'' =>
    mem_bag_between P CC x i y hx hy hx' hi hy' hx'' hy''

/-- **Memory Bound**: The cardinality of the active frontier is bounded by the bag size. -/
theorem activeFrontier_card_le_bag_card
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) :
    (activeFrontier F P i).card ≤ (P.bags.get ⟨i, hi⟩).card :=
  Finset.card_le_card (activeFrontier_subset_bag F P i hi)

/-- **Width Bound**: The active frontier size is bounded by `width + 1`.
This is the mathematically rigorous expression of the principle:
*bounded pathwidth implies bounded live clause memory*. -/
theorem activeFrontier_card_le_width_succ
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) :
    (activeFrontier F P i).card ≤ P.width + 1 := by
  calc (activeFrontier F P i).card
      ≤ (P.bags.get ⟨i, hi⟩).card := activeFrontier_card_le_bag_card F P i hi
    _ ≤ P.maxBagSize := P.card_bag_le_maxBagSize i hi
    _ ≤ P.width + 1 := by simp [PathDecomp.width_eq]; omega

/-! ## Theorem 3: Local Edge Preservation -/

/-
Every clause in the active frontier that belongs to F is in `retainAtCut`.
-/
theorem activeFrontier_subset_retainAtCut
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) :
    activeFrontier F P i ⊆ retainAtCut F P i hi := by
  exact fun x hx => Finset.mem_union_right _ hx

/-
**Soundness of path-respecting forgetting**: For any edge in the clause interaction
graph where both endpoints are in the active frontier, both endpoints are retained.
This means path-respecting forgetting preserves all interactions between
clauses that span the current cut.
-/
theorem retainAtCut_preserves_frontier_edges
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length) :
    ∀ ⦃C D : Clause α⦄,
      (confGraph F).Adj C D →
      C ∈ activeFrontier F P i →
      D ∈ activeFrontier F P i →
      C ∈ retainAtCut F P i hi ∧ D ∈ retainAtCut F P i hi := by
  exact fun C D hCD hC hD => ⟨ activeFrontier_subset_retainAtCut F P i hi hC, activeFrontier_subset_retainAtCut F P i hi hD ⟩

/-
Every clause in the bag that belongs to F is retained.
-/
theorem bag_mem_subset_retainAtCut
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length)
    (C : Clause α)
    (hCF : C ∈ F)
    (hCbag : C ∈ P.bags.get ⟨i, hi⟩) :
    C ∈ retainAtCut F P i hi := by
  exact Finset.mem_union_left _ ( Finset.mem_inter.mpr ⟨ hCbag, hCF ⟩ )

/-! ## Theorem 4: Bag Locality of Clause Evaluation -/

/-- **Bag locality**: Clause evaluation depends only on the clause's variables.
If two assignments agree on those variables, they produce the same evaluation.

This is the SAT analogue of the dynamic-programming locality principle. -/
theorem bag_locality_of_clause_evaluation
    (C : Clause α)
    (σ τ : LocalAssignment α)
    (hagree : agreesOn σ τ (clauseVars C)) :
    clauseEval σ C = clauseEval τ C := by
  unfold clauseEval
  congr! 2
  · unfold litEval
    ext l
    by_cases h : l.1 ∈ clauseVars C <;> simp_all +decide [agreesOn]
    exact fun hl => False.elim <| h <| Finset.mem_image_of_mem _ hl
  · constructor <;> intro h l hl <;> specialize h l hl <;> simp_all +decide [litEval]
    · have := hagree l.1 (by exact Finset.mem_image_of_mem _ hl)
      rw [← this, h]
    · convert h using 1
      rw [hagree _ (Finset.mem_image_of_mem _ hl)]

/-- **Cut locality**: Retained clauses with variables in the cut bag evaluate
identically under assignments agreeing on the cut bag's variables.

This connects SAT solving to automata theory and dynamic programming:
bounded pathwidth limits the information content that must be propagated
across cuts, exactly as in transfer-matrix methods. -/
theorem cut_locality
    (F : CNF α)
    (P : PathDecomp (confGraph F))
    (i : ℕ)
    (hi : i < P.bags.length)
    (σ τ : LocalAssignment α)
    (hagree : agreesOn σ τ (bagVars (P.bags.get ⟨i, hi⟩)))
    (C : Clause α)
    (_hC : C ∈ activeFrontier F P i)
    (hCvars : clauseVars C ⊆ bagVars (P.bags.get ⟨i, hi⟩)) :
    clauseEval σ C = clauseEval τ C :=
  bag_locality_of_clause_evaluation C σ τ (fun x hx => hagree x (hCvars hx))

/-! ## Maximum Frontier Size Bound -/

/-
The maximum frontier size across all cuts is bounded by `width + 1`.
-/
theorem maxFrontierSize_le_width_succ
    (F : CNF α)
    (P : PathDecomp (confGraph F)) :
    maxFrontierSize F P ≤ P.width + 1 := by
  have h_max_le : ∀ i < P.bags.length, (activeFrontier F P i).card ≤ P.width + 1 := by
    exact fun i a => activeFrontier_card_le_width_succ F P i a
  have h_foldr_le : ∀ (l : List ℕ), (∀ x ∈ l, x ≤ P.width + 1) → l.foldr max 0 ≤ P.width + 1 := by
    intro l hl; induction l <;> aesop;
  convert h_foldr_le _ _;
  grind