/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression XIII: A Decision-Tree Converse for Decoding Cost

## Bridge: information-theoretic counting (combinatorics) ↔ algorithm complexity

`AlmostLosslessBinarySearch` and `AlmostLosslessSublinear` produce a decoder
whose *proved* cost is `log₂ n + 3` key evaluations on a codebook of `n`
symbols.  Conjecture A of the previous cycle asked whether this is optimal.
This file proves the information-theoretic half (sub-conjecture A1) in full, and
in the sharp "worst-case cost", not merely "depth", form.

The cost model is an explicit adaptive decision tree: each internal node asks a
Boolean query (one key evaluation) and branches on the answer, each leaf outputs
a symbol.  An input is an oracle `Q → Bool` (the answers the key gives on that
input).

* `DTree.runCost` — the number of queries actually asked on a given input;
* `DTree.outputsUpTo t c` — the symbols the tree can output using at most `c`
  queries, with `card_outputsUpTo_le : |outputsUpTo t c| ≤ 2 ^ c`;
* `card_le_two_pow_of_runCost_le` — **the converse**: a tree that decodes `n`
  distinct symbols correctly and never asks more than `c` queries satisfies
  `n ≤ 2 ^ c`;
* `exists_runCost_ge_log` — hence some input costs at least `log₂ n` queries:
  no correct decoder is sub-logarithmic;
* `block_cost_ge_of_coordinatewise` — the converse half of Conjecture D: `b`
  independent coordinatewise decoders cost `≥ b·log₂ n` in total;
* `bsDecode_optimal_within_three` — combined with `bsDecode_cost_le`, the
  verified binary-search decoder is optimal **up to an additive 3**.

Nothing here assumes the queries are comparisons or that the tree comes from a
hash family: the bound holds for *every* adaptive Boolean-query algorithm, which
is what makes it a converse rather than a lower bound for one algorithm.

## Impact: decoder_cost_converse, log_optimality_of_binary_search
-/

import Mathlib
import Bridges.AlmostLosslessBinarySearch

open Finset BigOperators

namespace AlmostLossless

section DecisionTree

/-- An adaptive Boolean decision tree: internal nodes ask a query `q : Q`
(costing one key evaluation) and branch on the answer, leaves output a value. -/
inductive DTree (Q β : Type*) where
  | leaf (b : β) : DTree Q β
  | node (q : Q) (yes no : DTree Q β) : DTree Q β
  deriving Inhabited

namespace DTree

variable {Q β : Type*}

/-- The output of the tree on the input whose query answers are `ω`. -/
def run : DTree Q β → (Q → Bool) → β
  | leaf b, _ => b
  | node q y n, ω => if ω q then y.run ω else n.run ω

/-- The number of queries the tree actually asks on the input `ω`. -/
def runCost : DTree Q β → (Q → Bool) → ℕ
  | leaf _, _ => 0
  | node q y n, ω => (if ω q then y.runCost ω else n.runCost ω) + 1

/-- The set of values the tree can output while asking at most `c` queries. -/
def outputsUpTo [DecidableEq β] : DTree Q β → ℕ → Finset β
  | leaf b, _ => {b}
  | node _ _ _, 0 => ∅
  | node _ y n, (c + 1) => y.outputsUpTo c ∪ n.outputsUpTo c

variable [DecidableEq β]

/-- **The counting bound**: at most `2 ^ c` different values are reachable with
`c` queries — a binary tree of depth `c` has at most `2 ^ c` leaves. -/
theorem card_outputsUpTo_le (t : DTree Q β) (c : ℕ) :
    (t.outputsUpTo c).card ≤ 2 ^ c := by
  induction t generalizing c with
  | leaf b =>
    have : (1 : ℕ) ≤ 2 ^ c := Nat.one_le_two_pow
    simpa [outputsUpTo] using this
  | node q y n ihy ihn =>
    cases c with
    | zero => simp [outputsUpTo]
    | succ c =>
      calc ((y.outputsUpTo c) ∪ (n.outputsUpTo c)).card
          ≤ (y.outputsUpTo c).card + (n.outputsUpTo c).card := Finset.card_union_le _ _
        _ ≤ 2 ^ c + 2 ^ c := Nat.add_le_add (ihy c) (ihn c)
        _ = 2 ^ (c + 1) := by ring

/-- Reachability is monotone in the query budget. -/
theorem outputsUpTo_mono (t : DTree Q β) {c d : ℕ} (h : c ≤ d) :
    t.outputsUpTo c ⊆ t.outputsUpTo d := by
  induction t generalizing c d with
  | leaf b => simp [outputsUpTo]
  | node q y n ihy ihn =>
    cases c with
    | zero => simp [outputsUpTo]
    | succ c =>
      obtain ⟨d, rfl⟩ : ∃ d', d = d' + 1 := ⟨d - 1, by omega⟩
      have hcd : c ≤ d := by omega
      intro b hb
      simp only [outputsUpTo, Finset.mem_union] at hb ⊢
      rcases hb with hb | hb
      · exact Or.inl (ihy hcd hb)
      · exact Or.inr (ihn hcd hb)

/-- The value actually produced on an input is reachable within the number of
queries actually asked on that input. -/
theorem run_mem_outputsUpTo (t : DTree Q β) (ω : Q → Bool) :
    t.run ω ∈ t.outputsUpTo (t.runCost ω) := by
  induction t with
  | leaf b => simp [run, outputsUpTo]
  | node q y n ihy ihn =>
    by_cases hq : ω q
    · simp only [run, runCost, hq, if_true, outputsUpTo, Finset.mem_union]
      exact Or.inl ihy
    · simp only [run, runCost, hq, outputsUpTo, Finset.mem_union]
      exact Or.inr ihn

end DTree

/-- **The decoding-cost converse.**  If a decision tree decodes every symbol of
a set `S` correctly (`run` returns the symbol itself on that symbol's query
answers) and never uses more than `c` queries on those inputs, then
`|S| ≤ 2 ^ c`.  This is the pigeonhole bound one level down: it counts *decoder
runs* rather than codewords. -/
theorem card_le_two_pow_of_runCost_le {Q ι : Type*} [DecidableEq ι]
    (t : DTree Q ι) (S : Finset ι) (input : ι → Q → Bool) (c : ℕ)
    (hcorrect : ∀ i ∈ S, t.run (input i) = i)
    (hcost : ∀ i ∈ S, t.runCost (input i) ≤ c) :
    S.card ≤ 2 ^ c := by
  have hsub : S ⊆ t.outputsUpTo c := by
    intro i hi
    have h1 : t.run (input i) ∈ t.outputsUpTo (t.runCost (input i)) :=
      DTree.run_mem_outputsUpTo t (input i)
    have h2 : t.outputsUpTo (t.runCost (input i)) ⊆ t.outputsUpTo c :=
      DTree.outputsUpTo_mono t (hcost i hi)
    have := h2 h1
    rwa [hcorrect i hi] at this
  calc S.card ≤ (t.outputsUpTo c).card := Finset.card_le_card hsub
    _ ≤ 2 ^ c := DTree.card_outputsUpTo_le t c

/-- **No correct decoder is sub-logarithmic (settles sub-conjecture A1).**  Any
decision tree that decodes `n = |S|` distinct symbols correctly asks at least
`log₂ n` queries on some input.  The `log₂ n + 3` cost of `bsDecode` is
therefore within an additive constant of optimal. -/
theorem exists_runCost_ge_log {Q ι : Type*} [DecidableEq ι]
    (t : DTree Q ι) (S : Finset ι) (hS : S.Nonempty) (input : ι → Q → Bool)
    (hcorrect : ∀ i ∈ S, t.run (input i) = i) :
    ∃ i ∈ S, Nat.log 2 S.card ≤ t.runCost (input i) := by
  classical
  rcases Nat.eq_zero_or_pos (Nat.log 2 S.card) with hlog | hlog
  · obtain ⟨i, hi⟩ := hS
    exact ⟨i, hi, by simp [hlog]⟩
  · by_contra hcon
    push_neg at hcon
    set L := Nat.log 2 S.card with hL
    have hcost : ∀ i ∈ S, t.runCost (input i) ≤ L - 1 := by
      intro i hi
      have := hcon i hi
      omega
    have hcard : S.card ≤ 2 ^ (L - 1) :=
      card_le_two_pow_of_runCost_le t S input (L - 1) hcorrect hcost
    have hpos : 0 < S.card := Finset.card_pos.mpr hS
    have hlow : 2 ^ L ≤ S.card := Nat.pow_log_le_self 2 (by omega)
    have hmono : (2 : ℕ) ^ (L - 1) < 2 ^ L :=
      Nat.pow_lt_pow_right (by norm_num) (by omega)
    omega

/-- **Coordinatewise block decoding costs `b·log₂ n` (Conjecture D, converse
half).**  If each of the `b` coordinates of a product source is decoded by its
own decision tree, correctly on an `n`-symbol codebook, then some product input
forces total cost at least `b·log₂ n`.  Since the sorted block decoder of
`AlmostLosslessSublinear` costs `b·(log₂ n + 3)`, coordinatewise decoding is
optimal up to the additive constant `3` per block. -/
theorem block_cost_ge_of_coordinatewise {Q ι : Type*} [DecidableEq ι] (b : ℕ)
    (t : Fin b → DTree Q ι) (S : Finset ι) (hS : S.Nonempty) (input : ι → Q → Bool)
    (hcorrect : ∀ j, ∀ i ∈ S, (t j).run (input i) = i) :
    ∃ x : Fin b → ι, (∀ j, x j ∈ S) ∧
      b * Nat.log 2 S.card ≤ ∑ j, (t j).runCost (input (x j)) := by
  choose x hxS hxcost using fun j : Fin b =>
    exists_runCost_ge_log (t j) S hS input (hcorrect j)
  refine ⟨x, hxS, ?_⟩
  calc b * Nat.log 2 S.card = ∑ _j : Fin b, Nat.log 2 S.card := by
        simp [Finset.sum_const, Finset.card_univ]
    _ ≤ ∑ j, (t j).runCost (input (x j)) :=
        Finset.sum_le_sum fun j _ => hxcost j

/-- **Optimality of the verified binary-search decoder, up to `+3`.**  For every
decision-tree decoder of an `n`-symbol codebook there is an input on which the
tree's cost is at least the *total* cost of `bsDecode` minus `3`.  Combining the
converse `exists_runCost_ge_log` with the achievability `bsDecode_cost_le`, the
verified decoder is optimal within an additive constant, for every key function,
every codebook indexing and every received codeword. -/
theorem bsDecode_optimal_within_three {α : Type*} {Q : Type*} [DecidableEq α]
    (key : ℕ → ℕ) (a : ℕ → α) (tgt : ℕ)
    (t : DTree Q α) (S : Finset α) (hS : S.Nonempty) (input : α → Q → Bool)
    (hcorrect : ∀ x ∈ S, t.run (input x) = x) :
    ∃ x ∈ S, (bsDecode key a S.card tgt).2 ≤ t.runCost (input x) + 3 := by
  obtain ⟨x, hx, hlog⟩ := exists_runCost_ge_log t S hS input hcorrect
  refine ⟨x, hx, ?_⟩
  have hach : (bsDecode key a S.card tgt).2 ≤ Nat.log 2 S.card + 3 :=
    bsDecode_cost_le key a S.card tgt
  omega

end DecisionTree

end AlmostLossless