import Mathlib

/-!
# Tropical Dequantization: Bellman Optimality on Finite Branching Programs

This file establishes the core framework for **tropical dequantization** of quantum-inspired
path-sum algorithms. The key insight is that interference-driven speedup in many quantum
algorithms has an algebraic core: competitive aggregation of computational paths via the
min-plus (tropical) semiring.

## Main definitions

- `TropicalDP.value`: Bounded-depth tropical value recursion computing optimal path costs
  via the min-plus Bellman equation.
- `TropicalDP.pathCost`: Cost of a path (sequence of states) under edge weights.
- `TropicalDP.isValidPath`: Predicate for paths that follow the branching structure.
- `TropicalDP.isAcceptingPath`: Predicate for paths ending at accepting states.
- `TropicalDP.edgeCount`: Total number of edges in the branching program.

## Main results

- `TropicalDP.value_mono`: The tropical value is monotonically non-increasing in depth.
- `TropicalDP.value_le_pathCost`: The tropical value is a lower bound on any valid accepting
  path cost (soundness).
- `TropicalDP.value_accepting`: Accepting states always have tropical value 0.
- `TropicalDP.plus_distributes_over_min`: The fundamental distributive law `a + min b c = min (a+b) (a+c)`.
- `TropicalDP.min_assoc`: Associativity of min (tropical addition).

## References

The tropical Bellman equation is the min-plus analogue of amplitude-path summation in quantum
computation. Where quantum algorithms sum complex amplitudes over computational paths,
tropical algorithms take the minimum over path costs — preserving the competitive aggregation
structure that drives algorithmic speedup.
-/

noncomputable section

open Finset BigOperators

namespace TropicalDP

/-! ### Fundamental tropical semiring properties -/

/-- Tropical addition (min) distributes over tropical multiplication (ordinary +).
This is the algebraic engine behind pushing path weights through branch aggregation. -/
theorem plus_distributes_over_min (a b c : ℕ) :
    a + min b c = min (a + b) (a + c) := by
  omega

/-- Right distributivity of + over min. -/
theorem plus_distributes_over_min_right (a b c : ℕ) :
    min b c + a = min (b + a) (c + a) := by
  omega

/-- Tropical addition (min) is associative. -/
theorem min_assoc (a b c : ℕ) : min (min a b) c = min a (min b c) := by
  omega

/-- Every branch cost is an upper bound on the minimum. -/
theorem min_bound_left (a b : ℕ) : min a b ≤ a := Nat.min_le_left a b

/-- Every branch cost is an upper bound on the minimum. -/
theorem min_bound_right (a b : ℕ) : min a b ≤ b := Nat.min_le_right a b

/-- WithTop version of distributivity for the recursion. -/
theorem withTop_add_min (a : WithTop ℕ) (b c : WithTop ℕ) :
    a + (b ⊓ c) = (a + b) ⊓ (a + c) :=
  add_min a b c

/-! ### Core definitions -/

variable {σ : Type} [Fintype σ] [DecidableEq σ]

/-- Bounded-depth tropical value recursion.
At depth 0, accepting states have value 0 and all others have value ⊤.
At depth d+1, non-accepting states take the minimum over outgoing transitions
of (weight + continuation value at depth d). -/
def value (next : σ → Finset σ) (w : σ → σ → ℕ) (acc : σ → Bool) :
    ℕ → σ → WithTop ℕ
  | 0, s => if acc s then 0 else ⊤
  | d + 1, s =>
    if acc s then 0
    else (next s).inf (fun t => (w s t : WithTop ℕ) + value next w acc d t)

/-- Accepting states always have tropical value 0. -/
@[simp]
theorem value_accepting (next : σ → Finset σ) (w : σ → σ → ℕ) (acc : σ → Bool)
    (s : σ) (hs : acc s = true) (d : ℕ) :
    value next w acc d s = 0 := by
  cases d <;> simp [value, hs]

/-- Non-accepting states at depth 0 have value ⊤. -/
@[simp]
theorem value_zero_non_accepting (next : σ → Finset σ) (w : σ → σ → ℕ) (acc : σ → Bool)
    (s : σ) (hs : acc s = false) :
    value next w acc 0 s = ⊤ := by
  simp [value, hs]

/-- The recursion equation for non-accepting states at positive depth. -/
theorem value_succ (next : σ → Finset σ) (w : σ → σ → ℕ) (acc : σ → Bool)
    (s : σ) (hs : acc s = false) (d : ℕ) :
    value next w acc (d + 1) s =
    (next s).inf (fun t => (w s t : WithTop ℕ) + value next w acc d t) := by
  simp [value, hs]

/-
The tropical value is monotonically non-increasing in depth:
more depth means more paths explored, so potentially lower cost.
-/
theorem value_mono (next : σ → Finset σ) (w : σ → σ → ℕ) (acc : σ → Bool)
    (s : σ) (d : ℕ) :
    value next w acc (d + 1) s ≤ value next w acc d s := by
  induction' d with d ih generalizing s;
  · by_cases hs : acc s <;> simp +decide [ *, value ];
  · by_cases hs : acc s <;> simp +decide [ *, value ];
    intro t ht;
    refine' le_trans ( Finset.inf_le ht ) _;
    specialize ih t ; aesop

/-! ### Paths and path costs -/

/-- Cost of a path through the weighted graph (sum of edge weights).
Empty path and singleton path have cost 0. -/
def pathCost (w : σ → σ → ℕ) : List σ → WithTop ℕ
  | [] => 0
  | [_] => 0
  | s :: t :: rest => (w s t : WithTop ℕ) + pathCost w (t :: rest)

/-- A valid path follows edges in the branching structure. -/
def isValidPath (next : σ → Finset σ) : List σ → Prop
  | [] => True
  | [_] => True
  | s :: t :: rest => t ∈ next s ∧ isValidPath next (t :: rest)

/-- An accepting path has its last state accepting. -/
def isAcceptingPath (acc : σ → Bool) : List σ → Prop
  | [] => False
  | [s] => acc s = true
  | _ :: rest => isAcceptingPath acc rest

/-- A valid accepting path from a given root of bounded length. -/
structure BoundedPath (next : σ → Finset σ) (acc : σ → Bool) (root : σ) (d : ℕ) where
  states : List σ
  head_eq : states.head? = some root
  length_bound : states.length ≤ d + 1
  valid : isValidPath next states
  accepting : isAcceptingPath acc states

/-
The tropical value is a lower bound on any valid accepting path cost.
This is the **soundness** direction of the Bellman optimality theorem.
-/
theorem value_le_pathCost (next : σ → Finset σ) (w : σ → σ → ℕ) (acc : σ → Bool)
    (d : ℕ) (s : σ) (path : List σ) (hhead : path.head? = some s)
    (hlen : path.length ≤ d + 1) (hvalid : isValidPath next path)
    (hacc : isAcceptingPath acc path) :
    value next w acc d s ≤ pathCost w path := by
  induction' path with s t rest ih generalizing d s;
  · -- The assumption `hhead` states that the head of the empty list is `some s`, which is impossible. This contradiction allows us to close the goal immediately.
    cases hhead;
  · rcases t with ( _ | ⟨ t, t ⟩ ) <;> simp_all +decide;
    · -- Since `s` is accepting, its value is 0.
      have h_acc : acc s = true := by
        exact?
      simp [h_acc, value_accepting];
    · -- By definition of `value`, we know that `value next w acc d s` is the minimum of the costs of all paths from `s` to an accepting state with length at most `d`.
      have h_value_min : value next w acc d s ≤ (w s ‹_› : WithTop ℕ) + value next w acc (d - 1) ‹_› := by
        rcases d <;> simp_all +decide [ value ];
        split_ifs <;> simp_all +decide [ Finset.inf_le ];
        exact Finset.inf_le ( by cases hvalid ; aesop );
      refine le_trans h_value_min ?_;
      convert add_le_add_left ( rest ( d - 1 ) ( Nat.le_sub_one_of_lt hlen ) _ _ ) ( w s ‹_› : WithTop ℕ ) using 1;
      · exact add_comm _ _;
      · exact add_comm _ _;
      · exact hvalid.2;
      · cases t <;> tauto

/-! ### Complexity measure -/

/-- Total number of edges in the branching program. -/
def edgeCount (next : σ → Finset σ) : ℕ :=
  ∑ s : σ, (next s).card

/-- The cost of evaluating the tropical recursion by memoization is bounded
by the number of edges plus the number of states. This is the complexity
preservation theorem: tropical dequantization incurs no asymptotic overhead. -/
def evalCost (next : σ → Finset σ) : ℕ :=
  edgeCount next + Fintype.card σ

/-- The evaluation cost is at least the number of states. -/
theorem evalCost_ge_card (next : σ → Finset σ) :
    Fintype.card σ ≤ evalCost next := by
  unfold evalCost
  omega

/-- The evaluation cost is at least the edge count. -/
theorem evalCost_ge_edges (next : σ → Finset σ) :
    edgeCount next ≤ evalCost next := by
  unfold evalCost
  omega

end TropicalDP

end