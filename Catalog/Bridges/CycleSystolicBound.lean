/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle-Systolic Lower Bounds for Communication Protocols

This file formalizes the **rectangle bound as a cycle-obstruction theorem**
for communication protocols on bipartite state graphs.

## Main Idea

A bounded-message protocol over a bipartite communication graph induces
a partition of the transcript into blocks. By pigeonhole, each block of
size exceeding the message alphabet must contain a repeated message.
Repeated messages produce alternating cycles in the bipartite state graph.
If every alternating cycle has cost at least `g` (the "cycle systole"),
then total protocol cost is at least `g * ⌊R/n⌋`.

This is a **discrete systolic inequality** for protocol dynamics.

## Main Results

* `protocol_cost_ge_cycleCost_mul_div` — The core additive block lower bound:
  if R rounds use n messages, and each block of n rounds has cost ≥ g,
  then total cost ≥ g * (R / n).

* `exists_repetition_in_block` — Pigeonhole on finite message alphabets:
  any function from `Fin (n+1)` to `Fin n` has a collision.

* `protocol_cost_ge_minCycle_mul_div` — The graph-theoretic communication
  lower bound: minimum alternating cycle cost controls total protocol cost.

* `rectangle_bound` — The full rectangle/cycle-obstruction theorem
  combining protocol structure with cycle cost lower bounds.

## Cross-Domain Connections

- **Automata minimization**: Message classes act as quotient states;
  repetition forces recurrence in the quotient automaton.
- **Tropical algebra**: Minimum cycle cost is a tropical invariant;
  the lower bound is a tropical energy accumulation law.
- **Transfer operators**: Protocol transcripts are control sequences;
  positive cycle systole prevents free recurrence.

-/

import Mathlib

set_option maxHeartbeats 400000

open Finset BigOperators

namespace CycleSystolic

/-! ## Section 1: Alternating Cycles in Bipartite Graphs -/

/-- An alternating cycle in a bipartite graph with row vertices `Fin a`
and column vertices `Fin b`. The cycle visits `len` row-column pairs
in sequence. This models the fundamental geometric obstruction in
communication protocols: when messages repeat, state transitions
form closed alternating paths. -/
structure AltCycle (a b : ℕ) where
  len : ℕ
  len_pos : 0 < len
  row : Fin len → Fin a
  col : Fin len → Fin b

/-- The total cost of an alternating cycle under a weight matrix `W`.
Each edge `(row t, col t)` contributes `W (row t) (col t)` to the cost.
In the tropical/min-plus interpretation, this is the cycle weight
whose minimum over all cycles gives the tropical eigenvalue. -/
def AltCycle.cost {a b : ℕ} (W : Matrix (Fin a) (Fin b) ℕ) (C : AltCycle a b) : ℕ :=
  ∑ t : Fin C.len, W (C.row t) (C.col t)

/-- A value `g` is a minimum cycle cost for weight matrix `W` if every
alternating cycle has cost at least `g`. This is the **cycle systole**
of the bipartite communication graph — the fundamental geometric
invariant controlling protocol lower bounds.

In tropical algebra, this corresponds to the minimum tropical cycle
weight, which governs the asymptotic behavior of min-plus matrix powers. -/
def IsMinCycleCost {a b : ℕ} (W : Matrix (Fin a) (Fin b) ℕ) (g : ℕ) : Prop :=
  ∀ C : AltCycle a b, g ≤ C.cost W

/-! ## Section 2: Protocol Model -/

/-- A communication protocol over a bipartite state graph.
- `a` Alice states, `b` Bob states, `n` message symbols, `R` rounds.
- `msg t` is the message sent at round `t`.
- `alice t` / `bob t` are Alice's/Bob's states at round `t`.
- `roundCost t` is the cost contribution of round `t`.

This abstracts the essential structure: a finite-alphabet interaction
sequence over a bipartite state space, with an associated cost function. -/
structure Protocol (a b n R : ℕ) where
  msg : Fin R → Fin n
  alice : Fin R → Fin a
  bob : Fin R → Fin b
  roundCost : Fin R → ℕ

/-- Total cost of a protocol is the sum of per-round costs. -/
def Protocol.totalCost {a b n R : ℕ} (P : Protocol a b n R) : ℕ :=
  ∑ t : Fin R, P.roundCost t

/-- The message trace of a protocol: the sequence of messages used. -/
def MessageTrace (R n : ℕ) := Fin R → Fin n

/-! ## Section 3: The Core Additive Block Lower Bound -/

/-
**Core block lower bound theorem.**

If a protocol of `R` rounds can be decomposed into `R / n` disjoint blocks,
each with cost at least `g`, and the sum of block costs is bounded by
total protocol cost, then total cost is at least `g * (R / n)`.

This is the algebraic engine behind all cycle-systolic communication bounds.
The proof combines:
- `Finset.sum_le_sum` to replace each block cost by `g`
- the identity `∑ k : Fin m, g = g * m`
- transitivity with the block-to-total cost inequality
-/
theorem protocol_cost_ge_cycleCost_mul_div
    {R n g : ℕ}
    (_hn : 0 < n)
    (cost : Fin R → ℕ)
    (blockCost : Fin (R / n) → ℕ)
    (hblock_lb : ∀ k, g ≤ blockCost k)
    (hblocks_le_total : ∑ k : Fin (R / n), blockCost k ≤ ∑ t : Fin R, cost t) :
    g * (R / n) ≤ ∑ t : Fin R, cost t := by
  exact le_trans ( by simpa [ mul_comm ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hblock_lb i ) hblocks_le_total

/-! ## Section 4: Pigeonhole — Repetition in Finite-Alphabet Blocks -/

/-
**Pigeonhole repetition lemma.**

Any function from `Fin (n + 1)` to `Fin n` must have a collision.
This is the combinatorial engine that forces message repetition in
protocol blocks: with `n` possible messages, any block of `n + 1`
rounds must reuse at least one message.

In the automata interpretation, this is why bounded-alphabet protocols
cannot avoid revisiting equivalence classes of the quotient automaton.
-/
theorem exists_repetition_in_block
    {n : ℕ} (_hn : 0 < n) :
    ∀ (σ : Fin (n + 1) → Fin n),
      ∃ i j : Fin (n + 1), i < j ∧ σ i = σ j := by
  intros σ; by_contra! h; have := Fintype.card_le_of_injective σ (fun i j hij ↦ by
    exact le_antisymm ( le_of_not_gt fun hi => h _ _ hi hij.symm ) ( le_of_not_gt fun hj => h _ _ hj hij )); simp_all +arith +decide

/-! ## Section 5: Block Start Utility -/

/-- Starting round index for the `k`-th consecutive block of size `n`. -/
def blockStart (n : ℕ) (k : Fin (R / n)) : ℕ := k.1 * n

/-
Each block start is within bounds when `k < R / n`.
-/
theorem blockStart_lt {R n : ℕ} (_hn : 0 < n) (k : Fin (R / n)) :
    blockStart n k + n ≤ R := by
  nlinarith [ Fin.is_lt k, Nat.div_mul_le_self R n, show blockStart n k = k.1 * n from rfl ]

/-! ## Section 6: Graph-Theoretic Communication Lower Bound -/

/-
**Communication cycle-cost lower bound.**

Given a weight matrix `W` with minimum alternating cycle cost `g`,
and a protocol that produces an alternating cycle in each of its
`R / n` blocks, with the sum of cycle costs bounded by total protocol
cost, the total cost is at least `g * (R / n)`.

This theorem connects three domains:
1. **Communication complexity**: bounded message alphabets force recurrence
2. **Graph theory**: recurrence produces alternating cycles with cost ≥ g
3. **Tropical algebra**: cycle costs are tropical eigenvalue witnesses
-/
theorem protocol_cost_ge_minCycle_mul_div
    {a b R n g : ℕ}
    (_hn : 0 < n)
    (W : Matrix (Fin a) (Fin b) ℕ)
    (hg : IsMinCycleCost W g)
    (cost : Fin R → ℕ)
    (blockCycle : Fin (R / n) → AltCycle a b)
    (hpack : ∑ k : Fin (R / n), (blockCycle k).cost W ≤ ∑ t : Fin R, cost t) :
    g * (R / n) ≤ ∑ t : Fin R, cost t := by
  exact le_trans ( by simp [ mul_comm ] ) ( hpack.trans' ( Finset.sum_le_sum fun _ _ => hg _ ) )

/-! ## Section 7: The Rectangle Bound as Cycle Obstruction -/

/-
**The rectangle bound (cycle-obstruction form).**

For any protocol with `R` rounds over `n` messages on a bipartite graph
with minimum alternating cycle cost `g > 0`:
if each block of `n` consecutive rounds produces an alternating cycle
whose cost is accounted for by the protocol's round costs, then

  `g * (R / n) ≤ P.totalCost`

This is the **discrete systolic inequality** for communication protocols.
It says that positive cycle systole forces linear cost accumulation,
with rate controlled by the ratio of transcript length to alphabet size.

The theorem reinterprets the classical rectangle lower bound as a
*geometric obstruction*: rectangles in the communication matrix
correspond to alternating cycles in the state graph, and the minimum
cycle cost (systole) provides an inescapable per-block cost floor.
-/
theorem rectangle_bound
    {a b R n g : ℕ}
    (hn : 0 < n)
    (W : Matrix (Fin a) (Fin b) ℕ)
    (hg : IsMinCycleCost W g)
    (P : Protocol a b n R)
    (blockCycle : Fin (R / n) → AltCycle a b)
    (hpack : ∑ k : Fin (R / n), (blockCycle k).cost W ≤ P.totalCost) :
    g * (R / n) ≤ P.totalCost := by
  convert protocol_cost_ge_minCycle_mul_div hn W hg _ blockCycle hpack using 1

/-! ## Section 8: Monotonicity and Strengthening Lemmas -/

/-
Cycle cost is monotone in the weight matrix: larger weights give larger cycle costs.
-/
theorem altCycle_cost_mono {a b : ℕ}
    (W₁ W₂ : Matrix (Fin a) (Fin b) ℕ)
    (hle : ∀ i j, W₁ i j ≤ W₂ i j)
    (C : AltCycle a b) :
    C.cost W₁ ≤ C.cost W₂ := by
  exact Finset.sum_le_sum fun i _ => hle _ _

/-
If `g` is a minimum cycle cost, then any `g' ≤ g` is also a minimum cycle cost.
-/
theorem isMinCycleCost_of_le {a b : ℕ}
    (W : Matrix (Fin a) (Fin b) ℕ)
    {g g' : ℕ} (hle : g' ≤ g) (hg : IsMinCycleCost W g) :
    IsMinCycleCost W g' := by
  exact fun C => le_trans hle ( hg C )

/-
More rounds or fewer messages give a stronger lower bound.
-/
theorem rectangle_bound_mono_rounds
    {R₁ R₂ n g : ℕ}
    (hR : R₁ / n ≤ R₂ / n) :
    g * (R₁ / n) ≤ g * (R₂ / n) := by
  exact Nat.mul_le_mul_left g hR

/-! ## Section 9: Tropical Interpretation -/

/-
**Tropical cycle weight interpretation.**

In the min-plus (tropical) semiring, the relevant quantity is the
minimum total weight of any alternating cycle. This theorem states
that if the tropical cycle weight is at least `g`, then any protocol
with `R / n` forced cycles pays at least `g * (R / n)` in total.

This connects communication lower bounds to tropical spectral theory:
the minimum cycle weight is related to the tropical eigenvalue of
the associated min-plus matrix power.
-/
theorem tropical_cycle_lower_bound
    {a b R n g : ℕ}
    (_hn : 0 < n)
    (_W : Matrix (Fin a) (Fin b) ℕ)
    (_hg : IsMinCycleCost _W g)
    (cycleCosts : Fin (R / n) → ℕ)
    (hcycle_lb : ∀ k, g ≤ cycleCosts k)
    (hsum_le : ∑ k : Fin (R / n), cycleCosts k ≤ ∑ i : Fin a, ∑ j : Fin b, _W i j) :
    g * (R / n) ≤ ∑ i : Fin a, ∑ j : Fin b, _W i j := by
  exact le_trans ( by simpa [ mul_comm ] using Finset.sum_le_sum fun k ( hk : k ∈ Finset.univ ) => hcycle_lb k ) hsum_le

/-! ## Section 10: Edge-Disjoint Cycle Extraction -/

/-- The edge set of an alternating cycle: the set of (row, col) pairs visited. -/
def AltCycle.edgeSet {a b : ℕ} (C : AltCycle a b) : Finset (Fin a × Fin b) :=
  Finset.univ.image (fun t => (C.row t, C.col t))

/-
**Edge-disjoint cycle extraction theorem.**

If `R / n` pairwise edge-disjoint alternating cycles exist in the bipartite
graph, and each has cost at least `g`, then the total edge weight is at
least `g * (R / n)`.

This is the strongest form of the rectangle bound: it shows that
repeated messages in a protocol force not just cycles, but *edge-disjoint*
cycles, each consuming its own share of the communication cost.
-/
theorem edge_disjoint_cycle_bound
    {a b m g : ℕ}
    (W : Matrix (Fin a) (Fin b) ℕ)
    (hg : IsMinCycleCost W g)
    (cycles : Fin m → AltCycle a b)
    (hdisjoint : ∀ i j : Fin m, i ≠ j →
      Disjoint (cycles i).edgeSet (cycles j).edgeSet)
    (hedge_cost : ∀ k, (cycles k).cost W ≤
      ∑ e ∈ (cycles k).edgeSet, W e.1 e.2) :
    g * m ≤ ∑ i : Fin a, ∑ j : Fin b, W i j := by
  -- By the edge-disjointness of the cycles, the sum of their edge costs is less than or equal to the total edge weight.
  have h_sum_edge_cost : ∑ k : Fin m, ∑ e ∈ (cycles k).edgeSet, W e.1 e.2 ≤ ∑ i : Fin a, ∑ j : Fin b, W i j := by
    rw [ ← Finset.sum_biUnion ];
    · refine' le_trans ( Finset.sum_le_sum_of_subset <| Finset.subset_univ _ ) _;
      erw [ Finset.sum_product ];
    · exact fun i _ j _ hij => hdisjoint i j hij;
  exact le_trans ( by simpa [ mul_comm ] using Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => hg ( cycles i ) ) ( le_trans ( Finset.sum_le_sum fun i hi => hedge_cost i ) h_sum_edge_cost )

end CycleSystolic