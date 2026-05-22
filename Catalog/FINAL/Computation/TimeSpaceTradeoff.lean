import Mathlib

/-!
# Tropical Time-Space Tradeoff Lower Bounds

We develop a theory of lower bounds for path costs in finite-state weighted
transition systems, formalized over the min-plus (tropical) semiring.

## Overview

A weighted transition system on `n` states is a function `W : Fin n → Fin n → ℕ`
assigning costs to transitions. A path of length `T` is a function
`p : Fin (T+1) → Fin n`. The path cost is the sum of edge costs along the path.

The fundamental observation: any path through `n` states of length ≥ `n` must
revisit some state (pigeonhole), creating a cycle. If every cycle has cost at
least `g > 0`, then long paths accumulate cost at rate ≥ `g/n` per step.

## Main Results

- `block_has_cycle_cost`: A path of `n` steps through `Fin n` costs ≥ `g`.
- `pathCost_cycle_gap_lb`: A path of `T` steps costs ≥ `g * (T / n)`.
- `no_subgap_compression`: Positive cycle gap prevents sublinear cost growth.

## Keywords

tropical complexity, min-plus algebra, time-space tradeoff, weighted automata,
finite-state lower bounds, cycle mean, semiring computation, dynamic programming,
complexity barriers, asymptotic cost growth, idempotent linear algebra
-/

namespace TropicalTimeSpace

open Finset

/-! ## Core Definitions -/

/-- Cost of traversing path `p : Fin (T+1) → Fin n` under edge-weight function `W`.
    This is the sum of all edge costs along the path. -/
def pathCost {n T : ℕ} (W : Fin n → Fin n → ℕ) (p : Fin (T + 1) → Fin n) : ℕ :=
  ∑ i : Fin T, W (p i.castSucc) (p i.succ)

/-- **Minimum cycle cost property**: every cycle (closed walk) of positive length
    has total cost at least `g`.

    A cycle of length `k > 0` is a path `c : Fin (k+1) → Fin n` with `c(0) = c(k)`.
    This is the combinatorial analogue of a positive tropical spectral gap. -/
def MinCycleCost (n : ℕ) (W : Fin n → Fin n → ℕ) (g : ℕ) : Prop :=
  ∀ (k : ℕ) (c : Fin (k + 1) → Fin n),
    0 < k → c 0 = c ⟨k, lt_add_one k⟩ →
    g ≤ pathCost W c

/-- Restriction of a path to a sub-interval `[a, b]`, giving a path of length `b - a`. -/
def subPath {n T : ℕ} (p : Fin (T + 1) → Fin n) (a b : ℕ)
    (hab : a ≤ b) (hb : b ≤ T) : Fin (b - a + 1) → Fin n :=
  fun i => p ⟨a + i.val, by omega⟩

/-- Suffix of a path starting at position `b`. -/
def suffPath {n T : ℕ} (p : Fin (T + 1) → Fin n) (b : ℕ) (hb : b ≤ T) :
    Fin (T - b + 1) → Fin n :=
  fun i => p ⟨b + i.val, by omega⟩

/-! ## Sub-path Cost Lemma -/

/-
The cost of a sub-path `[a, b]` is at most the cost of the full path.
    This uses the fact that all edge costs are non-negative (they are `ℕ`).
-/
theorem subPath_cost_le {n T : ℕ} (W : Fin n → Fin n → ℕ) (p : Fin (T + 1) → Fin n)
    (a b : ℕ) (hab : a ≤ b) (hb : b ≤ T) :
    pathCost W (subPath p a b hab hb) ≤ pathCost W p := by
  convert Finset.sum_le_sum_of_subset ( Finset.subset_univ ( Finset.image ( fun i : Fin ( b - a ) => ⟨ a + i.val, by omega ⟩ : Fin ( b - a ) → Fin T ) Finset.univ ) ) using 1;
  · rw [ Finset.sum_image ];
    · congr! 2;
    · exact fun i _ j _ hij => by simpa [ Fin.ext_iff ] using hij;
  · infer_instance

/-! ## Path Cost Splitting -/

/-
Path cost splits as: cost of first `b` steps + cost of remaining `T - b` steps.
-/
theorem pathCost_split {n T : ℕ} (W : Fin n → Fin n → ℕ)
    (p : Fin (T + 1) → Fin n) (b : ℕ) (hb : b ≤ T) :
    pathCost W p = pathCost W (subPath p 0 b (Nat.zero_le b) hb) +
                   pathCost W (suffPath p b hb) := by
  unfold subPath suffPath pathCost
  generalize_proofs at *;
  rw [ show ( Finset.univ : Finset ( Fin ( T ) ) ) = Finset.image ( fun i : Fin b => ⟨ i, by linarith [ Fin.is_lt i ] ⟩ ) Finset.univ ∪ Finset.image ( fun i : Fin ( T - b ) => ⟨ b + i, by linarith [ Fin.is_lt i, Nat.sub_add_cancel hb ] ⟩ ) Finset.univ from ?_, Finset.sum_union ];
  · rw [ Finset.sum_image, Finset.sum_image ] <;> simp +decide [ Fin.ext_iff ];
    · ac_rfl;
    · exact fun i j h => by simpa [ Fin.ext_iff ] using h;
    · exact fun i j h => by simpa [ Fin.ext_iff ] using h;
  · norm_num [ Fin.ext_iff, Finset.disjoint_left ];
    lia;
  · ext ⟨ i, hi ⟩ ; simp +decide [ Fin.ext_iff ];
    exact if h : i < b then Or.inl ⟨ ⟨ i, by linarith ⟩, rfl ⟩ else Or.inr ⟨ ⟨ i - b, by omega ⟩, by rw [ add_tsub_cancel_of_le ( by linarith ) ] ⟩

/-! ## Block Cost Lemma (Pigeonhole + Cycle Gap) -/

/-
**Block cost lemma**: Any path of `n` steps through `Fin n` must contain
    a cycle (by pigeonhole), so its cost is at least the minimum cycle cost `g`.

    This is the fundamental combinatorial engine: finiteness of the state space
    forces cycles, and cycles force cost accumulation.
-/
theorem block_has_cycle_cost {n : ℕ} (hn : 0 < n)
    (W : Fin n → Fin n → ℕ) (g : ℕ)
    (hcyc : MinCycleCost n W g)
    (p : Fin (n + 1) → Fin n) :
    g ≤ pathCost W p := by
  -- By the pigeonhole principle, there exist indices $i < j$ such that $p(i) = p(j)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : Fin (n + 1), i < j ∧ p i = p j := by
    contrapose! hn;
    exact absurd ( Fintype.card_le_of_injective p fun i j hij => le_antisymm ( le_of_not_gt fun hi => hn _ _ hi hij.symm ) ( le_of_not_gt fun hj => hn _ _ hj hij ) ) ( by simp +arith +decide );
  refine le_trans ( hcyc ( j - i ) ( fun k ↦ p ⟨ i + k, by
    linarith [ Fin.is_lt i, Fin.is_lt j, Fin.is_lt k, Nat.sub_add_cancel ( show ( i : ℕ ) ≤ j from le_of_lt hij ) ] ⟩ ) ?_ ?_ ) ?_
  all_goals generalize_proofs at *;
  · exact Nat.sub_pos_of_lt hij;
  · grind;
  · convert subPath_cost_le W p i j hij.le ( Nat.le_of_lt_succ ( Fin.is_lt j ) ) using 1

/-! ## Main Theorems -/

/-
**Cycle-Gap Lower Bound (Theorem A)**.

    Any path of length `T` through `n` states costs at least `g * (T / n)`,
    where `g` is the minimum cycle cost.

    This is the core tropical time-space tradeoff theorem:
    - Space-boundedness (finite state space of size `n`) plus
    - Positive cycle gap (minimum cycle cost `g`) forces
    - Linear cost accumulation (total cost ≥ `g * (T / n)`).

    The bound is tight: equality is achieved when every block of `n` steps
    contains exactly one cycle of cost exactly `g`.
-/
theorem pathCost_cycle_gap_lb {n : ℕ} (hn : 0 < n)
    (W : Fin n → Fin n → ℕ) (g : ℕ)
    (hcyc : MinCycleCost n W g) :
    ∀ T (p : Fin (T + 1) → Fin n), g * (T / n) ≤ pathCost W p := by
  intro T;
  induction' T using Nat.strong_induction_on with T ih;
  intros p
  by_cases hT : T < n;
  · simp +decide [ Nat.div_eq_of_lt hT ];
  · have h_split : pathCost W p = pathCost W (subPath p 0 n (Nat.zero_le n) (by linarith)) + pathCost W (suffPath p n (by linarith)) := by
      exact pathCost_split _ _ _ ( by linarith );
    have h_subpath : g ≤ pathCost W (subPath p 0 n (Nat.zero_le n) (by linarith)) := by
      convert block_has_cycle_cost hn W g hcyc ( subPath p 0 n ( Nat.zero_le n ) ( by linarith ) ) using 1;
    rw [ show T / n = ( T - n ) / n + 1 from ?_ ];
    · grind +splitIndPred;
    · rw [ ← Nat.sub_add_cancel ( le_of_not_gt hT ), Nat.add_div ] <;> norm_num [ hn ];
      exact Nat.mod_lt _ hn

/-
**No Subgap Compression (Theorem C)**.

    If every cycle costs at least `g` and `c * n < g`, then no uniform cost
    rate of `c` per step is achievable for all path lengths.

    This is the formal kernel of the tropical obstruction to efficient simulation:
    positive cycle gap prevents compression below the gap rate `g / n`.
    In complexity-theoretic terms: a bounded-space machine with positive
    tropical cycle gap cannot be simulated at subgap cost per step.
-/
theorem no_subgap_compression {n : ℕ} (hn : 0 < n)
    (W : Fin n → Fin n → ℕ) (g c : ℕ)
    (hcyc : MinCycleCost n W g)
    (hcg : c * n < g) :
    ¬ ∀ (T : ℕ) (p : Fin (T + 1) → Fin n), pathCost W p ≤ c * T := by
  intro h;
  -- Apply the block_has_cycle_cost theorem with T = n and any p : Fin (n+1) → Fin n.
  have h_block : ∀ p : Fin (n + 1) → Fin n, g ≤ pathCost W p := by
    exact fun p => block_has_cycle_cost hn W g hcyc p;
  exact not_lt_of_ge ( h_block ( fun _ => ⟨ 0, hn ⟩ ) ) ( lt_of_le_of_lt ( h _ _ ) hcg )

/-! ## Min-Plus Matrix Operations -/

/-- Min-plus (tropical) matrix multiplication.
    `(tropMul A B) i k = min_j (A i j + B j k)`. -/
noncomputable def tropMul {m : ℕ} (A B : Matrix (Fin m) (Fin m) (WithTop ℕ)) :
    Matrix (Fin m) (Fin m) (WithTop ℕ) :=
  fun i k => ⨅ j : Fin m, (A i j + B j k)

/-- The tropical identity matrix: `0` on diagonal, `⊤` off diagonal. -/
noncomputable def tropId (m : ℕ) : Matrix (Fin m) (Fin m) (WithTop ℕ) :=
  fun i j => if i = j then 0 else ⊤

/-- Iterated min-plus matrix power. `tropPow W k` gives the minimum cost of
    length-`k` walks between pairs of vertices. -/
noncomputable def tropPow {m : ℕ} (W : Matrix (Fin m) (Fin m) (WithTop ℕ)) :
    ℕ → Matrix (Fin m) (Fin m) (WithTop ℕ)
  | 0 => tropId m
  | k + 1 => tropMul (tropPow W k) W

/-
**Tropical Power Diagonal Bound (Theorem B)**.

    If all edges in `W` have cost at least `g` (i.e., every edge weight is
    either `⊤` or at least `g`), then every `k`-step walk has cost at least
    `g * k`, hence diagonal entries of `tropPow W k` are either `⊤` or ≥ `g * k`.

    This is the min-plus analogue of a spectral expansion bound:
    positive edge weights prevent cost compression in iterated matrix powers.
-/
theorem tropPow_edge_lb {m : ℕ}
    (W : Matrix (Fin m) (Fin m) (WithTop ℕ)) (g : ℕ)
    (hedge : ∀ i j : Fin m, W i j = ⊤ ∨ ∃ c : ℕ, W i j = (c : WithTop ℕ) ∧ g ≤ c) :
    ∀ (k : ℕ) (i j : Fin m),
      (tropPow W k) i j = ⊤ ∨
      ∃ c : ℕ, (tropPow W k) i j = (c : WithTop ℕ) ∧ g * k ≤ c := by
  -- We proceed by induction on $k$.
  intro k
  induction' k with k ih;
  · intro i j; by_cases hij : i = j <;> simp +decide [ *, tropPow ] ;
    · exact Or.inr ⟨ 0, by simp +decide [ tropId ] ⟩;
    · exact Or.inl ( if_neg hij );
  · intro i j;
    -- By definition of tropPow, we have tropPow W (k + 1) i j = ⨅ l, (tropPow W k) i l + W l j.
    have h_tropPow_succ : tropPow W (k + 1) i j = ⨅ l, (tropPow W k) i l + W l j := by
      rfl;
    by_cases h : ∃ l, tropPow W k i l + W l j ≠ ⊤ <;> simp_all +decide [ mul_add ];
    · -- Let $l$ be such that $tropPow W k i l + W l j \neq \top$.
      obtain ⟨l, hl⟩ : ∃ l, tropPow W k i l + W l j ≠ ⊤ ∧ ∀ l', tropPow W k i l' + W l' j ≠ ⊤ → tropPow W k i l + W l j ≤ tropPow W k i l' + W l' j := by
        have h_finite : Set.Finite {x : WithTop ℕ | ∃ l, x = tropPow W k i l + W l j ∧ x ≠ ⊤} := by
          exact Set.Finite.subset ( Set.toFinite ( Finset.image ( fun l => tropPow W k i l + W l j ) Finset.univ ) ) fun x hx => by aesop;
        have := h_finite.toFinset.exists_min_image ( fun x => x ) ⟨ _, h_finite.mem_toFinset.mpr ⟨ h.choose, rfl, by simpa using h.choose_spec ⟩ ⟩ ; aesop;
      -- Since $tropPow W k i l + W l j \neq \top$, we have $tropPow W k i l = c$ and $W l j = d$ for some $c, d \in \mathbb{N}$.
      obtain ⟨c, hc⟩ : ∃ c : ℕ, tropPow W k i l = c ∧ g * k ≤ c := by
        cases ih i l <;> aesop
      obtain ⟨d, hd⟩ : ∃ d : ℕ, W l j = d ∧ g ≤ d := by
        cases hedge l j <;> aesop;
      refine Or.inr ⟨ c + d, ?_, ?_ ⟩ <;> simp_all +decide [ mul_add ];
      · refine' le_antisymm _ _;
        · exact ciInf_le ( Finite.bddBelow_range _ ) l |> le_trans <| by aesop;
        · refine' le_csInf _ _ <;> norm_num;
          · exact ⟨ _, ⟨ l, rfl ⟩ ⟩;
          · intro a; specialize hl a; by_cases ha : tropPow W k i a = ⊤ <;> by_cases ha' : W a j = ⊤ <;> aesop;
      · lia;
    · exact Or.inl fun l => Classical.or_iff_not_imp_left.2 fun hl => h l hl

end TropicalTimeSpace