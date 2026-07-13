import Mathlib

/-!
# The AllDifferent satisfiability threshold: an enumerative–order-theoretic–chromatic chain

This file develops, as a self-contained chain of results, the sharp satisfiability
threshold of the atomic `AllDifferent` constraint.  An `AllDifferent` block asks for
`m` *demands* (variables) to be assigned pairwise-distinct values drawn from a pool of
`k` *resources* (symbols).  The chain establishes that this constraint sits at a sharp
boundary located exactly at the *balance point* `m = k` ("demands = resources"), and
that the boundary is simultaneously:

* **enumerative**: the proper-assignment count is the falling factorial
  `partitionFn k m = k.descFactorial m` (`partitionFn_eq_card_embedding`);
* **order-theoretic**: satisfiability is a down-closed (monotone) event in the number
  of demands (`satisfiable_downClosed`), with the exact boundary `m ≤ k`
  (`allDifferent_satisfiable_iff`);
* **chromatic**: the constraint is a proper colouring of a complete graph, colourable
  with `k` colours iff `m ≤ k` (`completeGraph_colorable_iff`).

The chain culminates in Sudoku facts: an `n² × n²` grid line sits *exactly* at the
balance point (`sudoku_line_at_balance`), and the closed-form cyclic Latin square
`L(i,j) = i + j` solves the row/column constraints (`cyclic_row_injective`,
`cyclic_col_injective`) yet provably violates a box constraint already at order `n = 2`
(`cyclic_box_not_allDifferent`), showing the box demands are genuinely new constraints.

Each result builds on the previous one, following the falling-factorial partition
function as the analytic order parameter of the transition.
-/

namespace AllDifferentThreshold

open Nat SimpleGraph

/-- The **partition function** of an atomic `AllDifferent` constraint with `m` demands
drawing from `k` resources: the number of proper (injective) assignments, which equals
the falling factorial `k.descFactorial m`. -/
def partitionFn (k m : ℕ) : ℕ := Nat.descFactorial k m

/-- **Enumerative identity.**  The partition function counts injective assignments,
i.e. embeddings `Fin m ↪ Fin k`. -/
theorem partitionFn_eq_card_embedding (k m : ℕ) :
    Fintype.card (Fin m ↪ Fin k) = partitionFn k m := by
  simp [partitionFn, Fintype.card_embedding_eq]

/-- **Positivity of the order parameter.**  The partition function is strictly positive
exactly below (and at) the balance point `m = k`. -/
theorem partitionFn_pos_iff (k m : ℕ) : 0 < partitionFn k m ↔ m ≤ k := by
  simp [partitionFn, Nat.descFactorial_pos]

/-- **Vanishing beyond criticality.**  The order parameter is identically zero once the
demands strictly exceed the resources. -/
theorem partitionFn_eq_zero_iff (k m : ℕ) : partitionFn k m = 0 ↔ k < m := by
  simp [partitionFn, Nat.descFactorial_eq_zero_iff_lt]

/-- **The sharp satisfiability threshold.**  An `AllDifferent` block on `m` demands over
`k` resources is satisfiable (admits pairwise-distinct assignments) iff `m ≤ k`. -/
theorem allDifferent_satisfiable_iff (k m : ℕ) :
    (∃ f : Fin m → Fin k, Function.Injective f) ↔ m ≤ k := by
  rw [← partitionFn_pos_iff, ← partitionFn_eq_card_embedding, Fintype.card_pos_iff]
  constructor
  · rintro ⟨f, hf⟩; exact ⟨⟨f, hf⟩⟩
  · rintro ⟨e⟩; exact ⟨e, e.injective⟩

/-- **Order-theoretic skeleton (down-closure / monotonicity).**  Satisfiability is a
down-closed event in the number of demands: reducing demands preserves satisfiability.
This is the up-set boundary underlying the threshold. -/
theorem satisfiable_downClosed {k m m' : ℕ} (h : m' ≤ m)
    (hm : ∃ f : Fin m → Fin k, Function.Injective f) :
    ∃ f : Fin m' → Fin k, Function.Injective f := by
  rw [allDifferent_satisfiable_iff] at *
  omega

/-- **At the balance point.**  Exactly at criticality `m = k` the partition function
equals `k!`, the number of permutations of the `k` resources. -/
theorem partitionFn_balance (k : ℕ) : partitionFn k k = k ! :=
  Nat.descFactorial_self k

/-- **Just above criticality.**  One demand beyond the balance point already forces the
partition function to vanish. -/
theorem partitionFn_above_threshold (k : ℕ) : partitionFn k (k + 1) = 0 := by
  rw [partitionFn_eq_zero_iff]; omega

/-- **Chromatic bridge.**  An `AllDifferent` block on `m` demands is a proper colouring
of the complete graph on `m` vertices; it is colourable with `k` colours iff `m ≤ k`.
This ties the threshold to the chromatic number of `Kₘ`. -/
theorem completeGraph_colorable_iff (m k : ℕ) :
    (SimpleGraph.completeGraph (Fin m)).Colorable k ↔ m ≤ k := by
  rw [← allDifferent_satisfiable_iff]
  constructor
  · rintro ⟨c⟩
    exact ⟨c, fun a b hab => by
      by_contra hne
      exact (c.valid (by simpa [completeGraph, top_adj] using hne) hab)⟩
  · rintro ⟨f, hf⟩
    exact ⟨SimpleGraph.Coloring.mk f (fun {a b} hab => by
      simp only [completeGraph, top_adj] at hab
      exact fun h => hab (hf h))⟩

/-! ## Sudoku: sitting exactly on the threshold -/

/-- **A Sudoku line sits exactly at the balance point.**  Each line (row/column/box) of
an `n² × n²` Sudoku grid has `n²` cells and `n²` symbols, so `m = k = n²`: its partition
function is positive and equals `(n²)!`, while adding one more demand (`n² + 1`) makes it
vanish, so `n²` is the largest demand count for which the partition function is positive. -/
theorem sudoku_line_at_balance (n : ℕ) :
    partitionFn (n ^ 2) (n ^ 2) = (n ^ 2)! ∧
      0 < partitionFn (n ^ 2) (n ^ 2) ∧
      partitionFn (n ^ 2) (n ^ 2 + 1) = 0 := by
  refine ⟨partitionFn_balance _, ?_, ?_⟩
  · rw [partitionFn_pos_iff]
  · rw [partitionFn_eq_zero_iff]; omega

/-! ## The cyclic Latin square witness and box failure -/

/-- The closed-form **cyclic** assignment `L(i,j) = i + j` on the additive group
`ZMod N`. -/
def cyclic (N : ℕ) (i j : ZMod N) : ZMod N := i + j

/-- **Rows of the cyclic square are all-different.**  For each fixed row `i`, the map
`j ↦ i + j` is injective, so the row satisfies its `AllDifferent` constraint. -/
theorem cyclic_row_injective (N : ℕ) (i : ZMod N) :
    Function.Injective (cyclic N i) :=
  add_right_injective i

/-- **Columns of the cyclic square are all-different.**  For each fixed column `j`, the
map `i ↦ i + j` is injective, so the column satisfies its `AllDifferent` constraint. -/
theorem cyclic_col_injective (N : ℕ) (j : ZMod N) :
    Function.Injective (fun i => cyclic N i j) := by
  intro a b h; simpa [cyclic] using h

/-- **Boxes strictly add constraints.**  Already at order `n = 2` (the `4 × 4` grid), the
row/column-satisfying cyclic witness `L(i,j) = i + j` repeats a value inside the top-left
`2 × 2` box: the two distinct cells `(0,1)` and `(1,0)` receive the same symbol.  Hence the
box demand is *not* implied by the line demands. -/
theorem cyclic_box_not_allDifferent :
    cyclic 4 0 1 = cyclic 4 1 0 ∧
      ((0 : ZMod 4), (1 : ZMod 4)) ≠ ((1 : ZMod 4), (0 : ZMod 4)) := by
  refine ⟨by decide, by decide⟩

end AllDifferentThreshold