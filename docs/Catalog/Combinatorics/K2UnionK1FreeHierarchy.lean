import Combinatorics.K2UnionK1FreeInvariants

/-!
# The `(K₂ ∪ kK₁)`-free hierarchy is strict, plus small-graph regression tests

Building on `Combinatorics.K2UnionK1FreeInvariants`, this file records:

* a dominating-edge characterization of `(K₂ ∪ K₁)`-freeness;
* the fact that the forbidden graph `K₂ ∪ kK₁` is itself `(K₂ ∪ (k+1)K₁)`-free but not
  `(K₂ ∪ kK₁)`-free, so the increasing hierarchy of graph classes
  `k ↦ {G : G is (K₂ ∪ kK₁)-free}` is **strictly** increasing;
* regression tests on the five-cycle, which is `(K₂ ∪ 2K₁)`-free but not
  `(K₂ ∪ K₁)`-free, and whose toughness is not greater than one.
-/

open Finset SimpleGraph K2UnionIndependentFree K2UnionK1FreeInvariants

namespace K2UnionK1FreeHierarchy

variable {V : Type*}

/-! ## `(K₂ ∪ K₁)`-freeness means every edge dominates the whole graph -/

/-- A graph is `(K₂ ∪ K₁)`-free precisely when every edge is dominating: every vertex has
a neighbour among the two ends of any given edge. -/
theorem free_one_iff_edge_dominating (G : SimpleGraph V) :
    IsK2UnionK1Free G 1 ↔ ∀ ⦃u v : V⦄, G.Adj u v → ∀ x, G.Adj u x ∨ G.Adj v x := by
  classical
  constructor
  · intro hfree u v huv x
    by_contra hc
    push_neg at hc
    refine hfree huv {x} rfl ?_ ?_
    · intro a ha b hb hab
      simp only [Finset.coe_singleton, Set.mem_singleton_iff] at ha hb
      exact absurd (ha.trans hb.symm) hab
    · intro y hy
      rw [Finset.mem_singleton] at hy
      subst hy
      exact ⟨hc.1, hc.2⟩
  · intro hdom u v huv I hcard _ hanti
    obtain ⟨x, rfl⟩ := Finset.card_eq_one.mp hcard
    have hx : x ∈ ({x} : Finset V) := Finset.mem_singleton_self x
    rcases hdom huv x with hadj | hadj
    · exact (hanti x hx).1 hadj
    · exact (hanti x hx).2 hadj

/-! ## Strictness of the hierarchy -/

/-- The forbidden graph `K₂ ∪ kK₁` is not `(K₂ ∪ kK₁)`-free: it contains itself as an
induced subgraph. -/
theorem k2UnionK1_not_free_self (k : ℕ) : ¬ IsK2UnionK1Free (k2UnionK1 k) k := by
  rw [not_free_iff_nonempty_embedding]
  exact ⟨SimpleGraph.Embedding.refl⟩

/-- In `K₂ ∪ kK₁`, every vertex that is anticomplete to the unique edge lies in the
independent part. -/
theorem mem_range_inr_of_anticomplete {k : ℕ} {u v x : Fin 2 ⊕ Fin k}
    (huv : (k2UnionK1 k).Adj u v) (hu : ¬ (k2UnionK1 k).Adj u x)
    (hv : ¬ (k2UnionK1 k).Adj v x) : ∃ j : Fin k, x = Sum.inr j := by
  cases x with
  | inr j => exact ⟨j, rfl⟩
  | inl i =>
      exfalso
      cases u with
      | inr a => cases v with
          | inr b => simp [k2UnionK1] at huv
          | inl b => simp [k2UnionK1] at huv
      | inl a =>
          cases v with
          | inr b => simp [k2UnionK1] at huv
          | inl b =>
              rw [k2UnionK1_adj_inl_inl] at huv
              by_cases hai : a = i
              · subst hai
                exact hv ((k2UnionK1_adj_inl_inl k b a).mpr (Ne.symm huv))
              · exact hu ((k2UnionK1_adj_inl_inl k a i).mpr hai)

/-- The forbidden graph `K₂ ∪ kK₁` *is* `(K₂ ∪ (k+1)K₁)`-free: there is no room for an
extra isolated vertex. -/
theorem k2UnionK1_free_succ (k : ℕ) : IsK2UnionK1Free (k2UnionK1 k) (k + 1) := by
  classical
  intro u v huv I hcard _ hanti
  have hsub : I ⊆ Finset.univ.image (Sum.inr : Fin k → Fin 2 ⊕ Fin k) := by
    intro x hx
    obtain ⟨j, rfl⟩ := mem_range_inr_of_anticomplete huv (hanti x hx).1 (hanti x hx).2
    simp
  have hle := Finset.card_le_card hsub
  rw [hcard] at hle
  have : (Finset.univ.image (Sum.inr : Fin k → Fin 2 ⊕ Fin k)).card ≤ k := by
    simpa using Finset.card_image_le (s := (Finset.univ : Finset (Fin k)))
      (f := (Sum.inr : Fin k → Fin 2 ⊕ Fin k))
  omega

/-- **The hierarchy of `(K₂ ∪ kK₁)`-free classes is strictly increasing.** For every `k`
there is a graph which is `(K₂ ∪ (k+1)K₁)`-free but not `(K₂ ∪ kK₁)`-free, while every
`(K₂ ∪ kK₁)`-free graph is `(K₂ ∪ (k+1)K₁)`-free. -/
theorem hierarchy_strict (k : ℕ) :
    (∀ (W : Type) (G : SimpleGraph W), IsK2UnionK1Free G k → IsK2UnionK1Free G (k + 1)) ∧
      ∃ (W : Type) (G : SimpleGraph W),
        IsK2UnionK1Free G (k + 1) ∧ ¬ IsK2UnionK1Free G k :=
  ⟨fun _ _ hfree => mono_parameter hfree (Nat.le_succ k),
    ⟨Fin 2 ⊕ Fin k, k2UnionK1 k, k2UnionK1_free_succ k, k2UnionK1_not_free_self k⟩⟩

/-! ## Regression tests on the five-cycle -/

/-- The five-cycle is not `(K₂ ∪ K₁)`-free: the edge `0-1` misses the vertex `3`. -/
theorem cycleGraph_five_not_free_one : ¬ IsK2UnionK1Free (cycleGraph 5) 1 := by
  rw [free_one_iff_edge_dominating]
  intro hdom
  have h01 : (cycleGraph 5).Adj 0 1 := by decide
  rcases hdom h01 3 with h | h <;> revert h <;> decide

/-- The five-cycle is `(K₂ ∪ 2K₁)`-free: each edge misses exactly one vertex. -/
theorem cycleGraph_five_free_two : IsK2UnionK1Free (cycleGraph 5) 2 := by
  intro u v huv I hcard _ hanti
  obtain ⟨x, y, hxy, rfl⟩ := Finset.card_eq_two.mp hcard
  have hx : x ∈ ({x, y} : Finset (Fin 5)) := by simp
  have hy : y ∈ ({x, y} : Finset (Fin 5)) := by simp
  revert huv
  have key : ∀ u v : Fin 5, (cycleGraph 5).Adj u v → ∀ x y : Fin 5, x ≠ y →
      (¬(cycleGraph 5).Adj u x ∧ ¬(cycleGraph 5).Adj v x) →
      (¬(cycleGraph 5).Adj u y ∧ ¬(cycleGraph 5).Adj v y) → False := by decide
  exact fun huv => key u v huv x y hxy (hanti x hx) (hanti y hy)

/-- Deleting the two neighbours of a vertex of the five-cycle disconnects it, so the
five-cycle does not have toughness greater than one. -/
theorem cycleGraph_five_not_toughGreaterThan_one :
    ¬ ToughGreaterThan (cycleGraph 5) 1 := by
  intro h
  have hiso : ∀ z : Fin 5, z ∉ ({0, 2} : Set (Fin 5)) → ¬ (cycleGraph 5).Adj 1 z := by
    intro z hz hadj
    simp only [Set.mem_insert_iff, Set.mem_singleton_iff, not_or] at hz
    revert hz hadj
    revert z
    decide
  have h2 : 2 ≤ compCount (cycleGraph 5) ({0, 2} : Set (Fin 5)) := by
    refine two_le_compCount_of_isolated (x := 1) (y := 3) ?_ ?_ (by decide) hiso
    · simp only [Set.mem_insert_iff, Set.mem_singleton_iff, not_or]
      exact ⟨by decide, by decide⟩
    · simp only [Set.mem_insert_iff, Set.mem_singleton_iff, not_or]
      exact ⟨by decide, by decide⟩
  have hcard : ({0, 2} : Set (Fin 5)).ncard = 2 := by
    rw [Set.ncard_pair (by decide)]
  have := succ_compCount_le_ncard_of_toughGreaterThan_one h h2
  omega

end K2UnionK1FreeHierarchy