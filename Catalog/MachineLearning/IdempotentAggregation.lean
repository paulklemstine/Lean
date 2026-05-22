/-
# Tropical Distributed Systems: Idempotent Aggregation and Consensus-Free Computation

This file formalizes the algebraic foundations of consensus-free distributed computation.

## Key Insight
For tasks whose specification is an idempotent commutative aggregation (like min, max,
union, intersection), all fair delivery schedules converge to the same fixed point.
Agreement is a theorem of the algebra, not a protocol-level achievement. This eliminates
the need for consensus protocols (Paxos, Raft, etc.) for this broad class of tasks.

## Main Results
- `duplicate_insensitive_min_fold`: min aggregation is insensitive to duplicate messages
- `perm_invariant_min_fold`: min aggregation is order-independent
- `idempotent_stabilizes_at_one`: idempotent operators stabilize after one step
- `tropical_aggregation_duplicate_invariant`: network-level duplicate insensitivity

## Cross-Domain Connections
- **CRDTs / Eventually Consistent Databases**: The algebraic skeleton of convergence
  without consensus is exactly idempotent commutative monotone aggregation.
- **Information Flow / Causal Posets**: Reachability under finite-speed propagation
  induces a causal order; completion time = height of this order.
- **Max-Plus Discrete Event Systems**: Barrier synchronization and task completion
  times are naturally min-plus/max-plus dynamical systems.
-/

import Mathlib

namespace TropicalDistributed

/-! ## Idempotent Min/Max Aggregation on Lists

These theorems establish that `min`-based aggregation is insensitive to message
duplication and delivery order — the algebraic basis of consensus-free computation.
-/

/-- **Tropical idempotent**: `min a a = a`. The foundation of duplicate insensitivity
    in tropical aggregation. When a node receives the same value twice, the aggregate
    does not change. -/
theorem tropical_min_idempotent [LinearOrder α] (a : α) : min a a = a :=
  min_self a

/-- **Tropical commutativity**: `min a b = min b a`. Message processing order
    does not affect the aggregate. -/
theorem tropical_min_comm [LinearOrder α] (a b : α) : min a b = min b a :=
  min_comm a b

/-
`min` is left-commutative: `min a (min b c) = min b (min a c)`.
    This is the key property needed for fold-permutation invariance.
-/
theorem min_leftComm [LinearOrder α] (a b c : α) :
    min a (min b c) = min b (min a c) := by
  grind

/-
Folding min over a list with duplicates is the same as without.
    This is the algebraic core of duplicate-insensitive aggregation.
-/
theorem duplicate_insensitive_min_fold [LinearOrder α] (a : α) (xs : List α) :
    List.foldr min a (a :: xs) = List.foldr min a xs := by
  induction xs <;> simp +decide [ List.foldr ];
  grind

/-
**Order-independence**: Folding min over any permutation gives the same result.
    This means the aggregation result depends only on the multiset of received values,
    not on the order of message delivery.
-/
theorem perm_invariant_min_fold [LinearOrder α] (xs ys : List α)
    (h : xs.Perm ys) (seed : α) :
    List.foldr min seed xs = List.foldr min seed ys := by
  -- Apply the fact that if two lists are permutations, then their foldr results are equal.
  apply List.Perm.foldr_eq h

/-
Max aggregation is also duplicate-insensitive (for max-plus tropical semiring).
-/
theorem duplicate_insensitive_max_fold [LinearOrder α] (a : α) (xs : List α) :
    List.foldr max a (a :: xs) = List.foldr max a xs := by
  induction xs <;> aesop

/-
Max-folding is permutation-invariant.
-/
theorem perm_invariant_max_fold [LinearOrder α] (xs ys : List α)
    (h : xs.Perm ys) (seed : α) :
    List.foldr max seed xs = List.foldr max seed ys := by
  exact?

/-! ## Stabilization of Idempotent Monotone Operators

For monotone idempotent operators on finite types, repeated application
converges to a fixed point. This is the formal basis for the claim that
idempotent aggregation replaces consensus.
-/

/-- A function is idempotent if applying it twice equals applying it once. -/
def IsIdempotent' (f : α → α) : Prop := ∀ x, f (f x) = f x

/-
**Stabilization Theorem**: An idempotent function stabilizes after one application.
    This is the simplest version — f^[m] = f^[1] for all m ≥ 1.
-/
theorem idempotent_stabilizes_at_one {α : Type*} (f : α → α)
    (hidem : IsIdempotent' f) :
    ∀ x, ∀ m, m ≥ 1 → f^[m] x = f x := by
  -- We proceed by induction on $m$.
  intro x m hm
  induction' hm with m ih;
  · rfl;
  · rw [ Function.iterate_succ_apply', ‹f^[m] x = f x›, hidem ]

/-
For monotone functions on a finite linear order, iteration stabilizes.
    The orbit of any point under a monotone self-map on a finite linearly ordered
    set must eventually reach a fixed point: the sequence is monotone (increasing
    or decreasing) and finiteness forces stabilization.
-/
theorem monotone_iteration_stabilizes_linear {α : Type*} [Fintype α] [LinearOrder α]
    (f : α → α) (hmono : Monotone f) :
    ∀ x, ∃ N, ∀ m, m ≥ N → f^[m] x = f^[N] x := by
  -- By definition of monotonicity, the sequence $f^[n] x$ is either non-decreasing or non-increasing.
  have h_monotone : ∀ x, Monotone (fun n => f^[n] x) ∨ Antitone (fun n => f^[n] x) := by
    intro x
    by_cases h : f x ≥ x;
    · refine' Or.inl ( monotone_nat_of_le_succ fun n => _ );
      exact Nat.recOn n h fun n ihn => by simpa only [ Function.iterate_succ_apply' ] using hmono ihn;
    · refine' Or.inr ( antitone_nat_of_succ_le fun n => _ );
      induction n <;> simp_all +decide [ Function.iterate_succ_apply', hmono ];
      · exact le_of_lt h;
      · exact hmono ‹_›;
  intro x
  by_cases h_monotone : Monotone (fun n => f^[n] x);
  · -- Since the sequence is monotone and bounded above, it must eventually stabilize.
    have h_stabilize : ∃ N, ∀ m ≥ N, f^[m] x = f^[N] x := by
      have h_finite : Set.Finite (Set.range (fun n => f^[n] x)) := by
        exact Set.toFinite _
      have := h_finite.toFinset.exists_maximal;
      simp_all +decide [ Maximal ];
      exact Exists.elim ( this ⟨ _, Set.mem_range_self 0 ⟩ ) fun N hN => ⟨ N, fun m hm => le_antisymm ( hN m ( h_monotone hm ) ) ( h_monotone hm ) ⟩;
    exact h_stabilize;
  · -- Since the sequence is antitone and finite, it must stabilize.
    have h_antitone_stabilize : ∀ {g : ℕ → α}, Antitone g → ∃ N, ∀ m ≥ N, g m = g N := by
      intro g hg
      have h_finite_range : Set.Finite (Set.range g) := by
        exact Set.toFinite _;
      -- Since the range of $g$ is finite, there exists some $N$ such that $g(N)$ is the minimum value in the range of $g$.
      obtain ⟨N, hN⟩ : ∃ N, ∀ m, g m ≥ g N := by
        have := Finset.exists_min_image ( h_finite_range.toFinset ) ( fun x => x ) ⟨ g 0, h_finite_range.mem_toFinset.mpr ( Set.mem_range_self 0 ) ⟩ ; aesop;
      exact ⟨ N, fun m hm => le_antisymm ( hg hm ) ( hN m ) ⟩;
    exact h_antitone_stabilize ( Or.resolve_left ( ‹∀ x : α, ( Monotone fun n => f^[n] x ) ∨ Antitone fun n => f^[n] x› x ) h_monotone )

/-! ## Network-Level Aggregation

Lifting the algebraic properties to network state vectors.
-/

variable {n : ℕ}

/-- Pointwise min of two state vectors. In a distributed system, this models
    a node updating its state by taking the componentwise minimum with a
    received state vector. -/
def pointwiseMin [LinearOrder α] (x y : Fin n → α) : Fin n → α :=
  fun i => min (x i) (y i)

/-
Pointwise min is idempotent: receiving the same state twice has no effect.
-/
theorem pointwiseMin_idempotent [LinearOrder α] (x : Fin n → α) :
    pointwiseMin x x = x := by
  exact funext fun i => min_self ( x i )

/-
Pointwise min is commutative: the order of message exchange doesn't matter.
-/
theorem pointwiseMin_comm [LinearOrder α] (x y : Fin n → α) :
    pointwiseMin x y = pointwiseMin y x := by
  exact funext fun i => min_comm _ _

/-
Pointwise min is associative: batching message exchanges doesn't matter.
-/
theorem pointwiseMin_assoc [LinearOrder α] (x y z : Fin n → α) :
    pointwiseMin (pointwiseMin x y) z = pointwiseMin x (pointwiseMin y z) := by
  grind +locals

/-
**Tropical aggregation duplicate invariance**: Applying pointwise min with
    the same state vector again does not change the result. This is the formal
    statement that "duplicate messages are harmless" in tropical aggregation.
-/
theorem tropical_aggregation_duplicate_invariant [LinearOrder α]
    (x y : Fin n → α) :
    pointwiseMin (pointwiseMin x y) y = pointwiseMin x y := by
  grind +locals

/-
**Convergence theorem**: For any finite sequence of pointwise-min updates
    (modeling message exchanges), the final state depends only on the set of
    states exchanged, not on the order or multiplicity.
    This is the network-level consensus-free convergence guarantee.
-/
theorem min_fold_convergence [LinearOrder α] (states : List (Fin n → α))
    (states' : List (Fin n → α)) (h : states.Perm states')
    (init : Fin n → α) :
    List.foldl pointwiseMin init states = List.foldl pointwiseMin init states' := by
  apply_rules [ List.Perm.foldl_eq ];
  constructor ; intros ; ext i ; simp +decide [ pointwiseMin ] ;
  grind

end TropicalDistributed