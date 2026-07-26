/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Stack-sorting depth of permutations

This file develops West's **stack-sorting map** `stackSort` on lists of natural
numbers, together with the associated notion of **stack-sorting depth**: the
minimal number of times the map must be iterated to reach the sorted list.

## Main definitions

* `stackSort`     — one pass of West's stack-sorting operator, implemented by a
  left-to-right stack simulation (`sortPass` / `popLess`).
* `depth`         — the least `t` with `stackSort^[t] l` equal to the sorted
  list (computed by a bounded search `depthAux`; the bound `l.length` is always
  large enough).
* `permsN n`      — all permutations of `[1, 2, …, n]`.
* `depthDist n`   — the depth distribution: for each value `t`, the number of
  permutations of `[1, …, n]` of stack-sorting depth `t`.

## Main results

* `stackSort_perm`            — `stackSort l` is a permutation of `l`.
* `stackSort_length`          — `stackSort` preserves length.
* `stackSort_strictSorted_eq` — a strictly increasing list is a fixed point of
  `stackSort`.
* `depth_sorted`              — an (ascending-)sorted list has depth `0`.
* `permsN_complete`           — `permsN n` lists exactly the permutations of
  `[1, …, n]`.
* `depthLe1_card_eq_catalan_*`— the number of permutations of `[1, …, n]` of
  depth at most `1` (the one-pass stack-sortable permutations) equals the
  Catalan number `Cₙ`, verified for `n ≤ 6`.

These four core lemmas are independent: `stackSort_length` is derived from
`stackSort_perm`, but neither `stackSort_strictSorted_eq` nor `depth_sorted`
depends on the permutation lemmas, so there is no circular dependency.
-/

import Mathlib

namespace StackSortingDepth

/-! ## West's stack-sorting map -/

/-- `popLess x stack` pops off the top of `stack` (whose head is the top) every
element that is strictly smaller than `x`, returning the popped elements (in pop
order) together with the remaining stack. -/
def popLess (x : ℕ) : List ℕ → List ℕ × List ℕ
  | [] => ([], [])
  | (t :: ts) =>
      if t < x then
        (fun p => (t :: p.1, p.2)) (popLess x ts)
      else
        ([], t :: ts)

/-- One left-to-right pass of West's stack-sorting algorithm.  `sortPass xs
stack` processes the remaining input `xs` against the current `stack`: for each
new symbol it first flushes every smaller stack element to the output, then
pushes the symbol; when the input is exhausted the whole stack is flushed. -/
def sortPass : List ℕ → List ℕ → List ℕ
  | [], stack => stack
  | (x :: xs), stack =>
      let p := popLess x stack
      p.1 ++ sortPass xs (x :: p.2)

/-- West's stack-sorting map: one full pass starting from an empty stack. -/
def stackSort (l : List ℕ) : List ℕ := sortPass l []

/-! ## Permutation and length invariants -/

/-- `popLess` rearranges the stack: the popped elements together with the
remaining stack form a permutation of the original stack. -/
lemma popLess_perm (x : ℕ) (s : List ℕ) :
    ((popLess x s).1 ++ (popLess x s).2).Perm s := by
  induction' s with hd tl ih;
  · rfl;
  · by_cases h : hd < x <;> simp_all +decide [ popLess ];
    grind

/-- A full pass is a permutation of the input concatenated with the stack. -/
lemma sortPass_perm (xs stack : List ℕ) :
    (sortPass xs stack).Perm (xs ++ stack) := by
  induction' xs with x xs ih generalizing stack;
  · aesop;
  · convert List.Perm.trans ( List.Perm.append ( List.Perm.refl _ ) ( ih _ ) ) _ using 1;
    have h_perm : ((popLess x stack).1 ++ (popLess x stack).2).Perm stack :=
      popLess_perm x stack
    grind

/-- `stackSort l` is a permutation of `l`. -/
lemma stackSort_perm (l : List ℕ) : (stackSort l).Perm l := by
  simpa using sortPass_perm l []

/-- `stackSort` preserves the length of its argument. -/
lemma stackSort_length (l : List ℕ) : (stackSort l).length = l.length := by
  exact List.Perm.length_eq ( stackSort_perm l )

/-! ## Strictly sorted lists are fixed points -/

/-- If `xs` is strictly increasing and `m` is below every element of `xs`, then
processing `xs` against the single-element stack `[m]` outputs `m :: xs`. -/
lemma sortPass_lt_singleton {m : ℕ} {xs : List ℕ}
    (hs : List.Pairwise (· < ·) xs) (hm : ∀ y ∈ xs, m < y) :
    sortPass xs [m] = m :: xs := by
  induction' xs with x xs ih generalizing m;
  · rfl;
  · simp_all +decide [ sortPass, popLess ]

/-- A strictly increasing list is a fixed point of `stackSort`. -/
lemma stackSort_strictSorted_eq {l : List ℕ} (hl : List.Pairwise (· < ·) l) :
    stackSort l = l := by
  induction l <;> simp_all +decide [ List.pairwise_cons ];
  have := sortPass_lt_singleton hl.2 hl.1; aesop;

/-! ## Stack-sorting depth -/

/-- Bounded search underlying `depth`: starting from `cur`, count how many
applications of `stackSort` are needed to reach `target`, giving up after `fuel`
steps. -/
def depthAux (target : List ℕ) : List ℕ → ℕ → ℕ
  | _, 0 => 0
  | cur, (f + 1) => if cur = target then 0 else 1 + depthAux target (stackSort cur) f

/-- The stack-sorting depth of `l`: the least `t` such that iterating `stackSort`
`t` times turns `l` into its ascending sort.  The search bound `l.length` always
suffices. -/
def depth (l : List ℕ) : ℕ := depthAux (l.mergeSort (· ≤ ·)) l l.length

/-- An ascending-sorted list already equals its sort, hence has depth `0`. -/
lemma depth_sorted {l : List ℕ} (hl : List.Pairwise (· ≤ ·) l) : depth l = 0 := by
  -- Since `l` is already sorted, `l.mergeSort (· ≤ ·)` equals `l`.
  have h_sorted : l.mergeSort (· ≤ ·) = l := by
    -- Apply the theorem that states if a list is already sorted, then its merge sort is the list itself.
    apply List.mergeSort_eq_self; assumption;
  -- Unfold `depth` and simplify using `h_sorted`.
  unfold depth
  simp [h_sorted];
  unfold depthAux; aesop;

/-! ## Enumerating permutations -/

/-- All permutations of `[1, 2, …, n]`. -/
def permsN (n : ℕ) : List (List ℕ) := (List.range' 1 n).permutations

/-- `permsN n` lists exactly the permutations of `[1, …, n]`. -/
lemma permsN_complete (n : ℕ) (p : List ℕ) :
    p ∈ permsN n ↔ p.Perm (List.range' 1 n) := by
  unfold permsN; aesop;

/-! ## Depth distribution and the Catalan law

The number of permutations of `[1, …, n]` of stack-sorting depth `0` or `1`
(i.e. sortable in a single pass) is the Catalan number `Cₙ`.  We record this
"Catalan law" for `n ≤ 6` together with the full depth distribution. -/

/-- The depth distribution for permutations of `[1, …, n]`: a list of pairs
`(t, k)` meaning that `k` permutations have stack-sorting depth `t`. -/
def depthDist (n : ℕ) : List (ℕ × ℕ) :=
  let ds := (permsN n).map depth
  let m := ds.foldl max 0
  (List.range (m + 1)).map (fun t => (t, (ds.filter (· = t)).length))

-- Depth distributions for small `n` (matching OEIS data):
--   n=1: [(0,1)]
--   n=2: [(0,1),(1,1)]
--   n=3: [(0,1),(1,4),(2,1)]
--   n=4: [(0,1),(1,13),(2,8),(3,2)]
--   n=5: [(0,1),(1,41),(2,49),(3,23),(4,6)]
--   n=6: [(0,1),(1,131),(2,276),(3,198),(4,90),(5,24)]
#eval depthDist 1
#eval depthDist 2
#eval depthDist 3
#eval depthDist 4
#eval depthDist 5
#eval depthDist 6

/-- Number of one-pass stack-sortable permutations of `[1, …, n]`. -/
def stackSortableCount (n : ℕ) : ℕ := ((permsN n).filter (fun p => depth p ≤ 1)).length

/-- The Catalan law for `n = 4`: one-pass stack-sortable permutations are
counted by the Catalan number `C₄ = 14`. -/
theorem depthLe1_card_eq_catalan_four : stackSortableCount 4 = catalan 4 := by
  native_decide

/-- The Catalan law for `n = 5`: `C₅ = 42`. -/
theorem depthLe1_card_eq_catalan_five : stackSortableCount 5 = catalan 5 := by
  native_decide

/-- The Catalan law for `n = 6`: `C₆ = 132`. -/
theorem depthLe1_card_eq_catalan_six : stackSortableCount 6 = catalan 6 := by
  native_decide

end StackSortingDepth