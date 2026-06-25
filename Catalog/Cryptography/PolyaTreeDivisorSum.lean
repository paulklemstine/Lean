/-
# Pólya Tree Coefficients and the Divisor-Sum (Euler-Transform) Recurrence

The number `a(n)` of unlabelled rooted trees on `n` nodes (Pólya trees, OEIS A000081)
satisfies Pólya's classical divisor-sum recurrence.  Writing the Euler-transform
coefficient
```
c(k) = ∑_{d | k} d · a(d),
```
the counts obey
```
n · a(n+1) = ∑_{k=1}^{n} c(k) · a(n+1−k),     a(1) = 1.
```

This file *defines* the sequence directly by this recurrence (via a structurally
recursive prefix list, using `Nat` division), and proves:

* `treeCount_table` — the first 16 values agree with A000081.
* `polya_divisor_sum_recurrence` — a fully **general** theorem (all `n ≥ 1`): the
  defined sequence satisfies the divisor-sum recurrence with `Nat` division.
* `polya_divisor_sum_exact` — on the verified range `1 ≤ n ≤ 13` the division is
  exact, i.e. the integer identity `n · a(n+1) = ∑ c(k) · a(n+1−k)` holds.
* `treeCount_pos` — positivity of the counts on `1 ≤ n ≤ 15`.

## Catalog / domain context
Pólya-tree enumeration underlies the combinatorics of hash-tree / Merkle-style
structures and tree-indexed key derivation; this entry sits alongside the
Cryptography catalog's combinatorial hash material (`MerkleDamgard`, `KMerAvoidance`).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The divisor-sum recurrence, taken as a *definition*
over ℕ with truncating division, reproduces A000081 exactly; equivalently the
sum is divisible by `n` at each step (integrality of the Euler transform).

EXPERIMENT (Experimenter): Defined `a` via `treeList`, a structurally recursive
prefix list, avoiding well-founded-recursion bound proofs. Evaluated `a(0..15)`:
matched A000081. Checked the multiplied-out identity (no division) for n = 1..13:
all true → divisibility holds on the range.

INSIGHT (Analyst): The general recurrence holds *definitionally* once one proves
the prefix-stability lemma `treeList_getD` (a value at index `j ≤ m` is independent
of `m`). Stability + the `length` lemma collapse `Sdiv`/`getD` into `c`/`a`.

FAILURE ANALYSIS: A first attempt to define `a` by `Nat.strongRecOn` drowned in
`d < n` side-conditions inside `Finset.divisors`/`Icc` sums. The list/prefix
encoding is structurally recursive and `native_decide`-friendly, sidestepping this.
The *general* integrality (exactness for all `n`, not just the tested range) was
left open — see FUTURE_DIRECTIONS.md.
-/
import Mathlib

open Finset

namespace PolyaTree

/-- Euler-transform coefficient evaluated on a prefix list:
`Sdiv L k = ∑_{d | k} d · L[d]`. -/
def Sdiv (L : List ℕ) (k : ℕ) : ℕ := ∑ d ∈ k.divisors, d * L.getD d 0

/-- One recurrence step: from the prefix `L = [a(0), …, a(m)]` compute `a(m+1)`
via `a(m+1) = (∑_{k=1}^{m} Sdiv L k · L[m+1−k]) / m`. -/
def nextVal (L : List ℕ) : ℕ :=
  let n := L.length - 1
  (∑ k ∈ Finset.Icc 1 n, Sdiv L k * L.getD (n + 1 - k) 0) / n

/-- `treeList n = [a(0), a(1), …, a(n)]`, built by repeated `nextVal`. -/
def treeList : ℕ → List ℕ
  | 0 => [0]
  | 1 => [0, 1]
  | (n + 2) => let L := treeList (n + 1); L ++ [nextVal L]

/-- `a n` = number of unlabelled rooted trees on `n` nodes (A000081), with `a 0 = 0`. -/
def a (n : ℕ) : ℕ := (treeList n).getD n 0

/-- Euler-transform coefficient `c(n) = ∑_{d | n} d · a(d)`. -/
def coef (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d * a d

/-! ### Structural lemmas about the prefix list -/

/-
`treeList n` has length `n + 1`.
-/
theorem treeList_length (n : ℕ) : (treeList n).length = n + 1 := by
  induction' n with n ih;
  · rfl;
  · rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ treeList ]

/-
Prefix stability: the value stored at index `j ≤ m` does not depend on `m`.
-/
theorem treeList_getD (m j : ℕ) (h : j ≤ m) :
    (treeList m).getD j 0 = a j := by
      induction' m with m ih generalizing j;
      · aesop;
      · rcases m with ( _ | m ) <;> simp_all +decide [ treeList ];
        · native_decide +revert;
        · by_cases hj : j ≤ m + 1 <;> simp_all +decide [ List.getElem?_append ];
          · rw [ if_pos ] <;> simp_all +decide [ treeList_length ];
          · norm_num [ show j = m + 2 by linarith, treeList_length ];
            unfold a;
            rw [ show treeList ( m + 2 ) = treeList ( m + 1 ) ++ [ nextVal ( treeList ( m + 1 ) ) ] from rfl ] ; simp +decide [ treeList_length ]

/-! ### Main results -/

/-- The first sixteen Pólya-tree counts agree with OEIS A000081. -/
theorem treeCount_table :
    (List.range 16).map a =
      [0, 1, 1, 2, 4, 9, 20, 48, 115, 286, 719, 1842, 4766, 12486, 32973, 87811] := by
  native_decide

/-
**General divisor-sum recurrence.** For every `n ≥ 1` the defined sequence
satisfies the Euler-transform recurrence with `Nat` division.
-/
theorem polya_divisor_sum_recurrence (n : ℕ) (hn : 1 ≤ n) :
    a (n + 1) = (∑ k ∈ Finset.Icc 1 n, coef k * a (n + 1 - k)) / n := by
      -- By definition of `nextVal`, we know that
      have h_nextVal : a (n + 1) = (∑ k ∈ Finset.Icc 1 n, (Sdiv (treeList n) k) * (treeList n).getD (n + 1 - k) 0) / n := by
        unfold a;
        rcases n with ( _ | _ | n ) <;> simp_all +decide [ treeList ];
        unfold nextVal; simp +arith +decide [ treeList_length ] ;
      convert h_nextVal using 3;
      congr! 1;
      · refine' Finset.sum_congr rfl fun x hx => _;
        rw [ treeList_getD ];
        exact le_trans ( Nat.le_of_dvd ( by linarith [ Finset.mem_Icc.mp ‹_› ] ) ( Nat.dvd_of_mem_divisors hx ) ) ( by linarith [ Finset.mem_Icc.mp ‹_› ] );
      · exact Eq.symm ( treeList_getD _ _ ( Nat.sub_le_of_le_add <| by linarith [ Finset.mem_Icc.mp ‹_› ] ) )

/-- **Exactness / integrality on the verified range.** For `1 ≤ n ≤ 13` the
divisor sum is divisible by `n`, giving the clean integer identity. -/
theorem polya_divisor_sum_exact :
    ∀ n ∈ Finset.Icc 1 13,
      n * a (n + 1) = ∑ k ∈ Finset.Icc 1 n, coef k * a (n + 1 - k) := by
  native_decide

/-- Positivity of the counts on `1 ≤ n ≤ 15`. -/
theorem treeCount_pos : ∀ n ∈ Finset.Icc 1 15, 1 ≤ a n := by
  native_decide

end PolyaTree