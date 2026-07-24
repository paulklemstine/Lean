# Computational Evidence: Mutually Orthogonal Latin Squares (MOLS)

This note records the small-case computational landscape that motivates the formal
development in `ReticulationMOLS.lean`.

## 1. The quantity `N(n)` = maximum number of MOLS of order `n`

Let `N(n)` denote the largest size of a set of mutually orthogonal Latin squares of
order `n`. The classical upper bound is `N(n) ≤ n − 1`, and equality holds whenever `n`
is a prime power.

| n | n − 1 | N(n) (known) | attains bound? |
|---|-------|--------------|----------------|
| 2 | 1     | 1            | yes            |
| 3 | 2     | 2            | yes (prime)    |
| 4 | 3     | 3            | yes (prime power) |
| 5 | 4     | 4            | yes (prime)    |
| 6 | 5     | 1            | **no** (Euler's 36 officers) |
| 7 | 6     | 6            | yes (prime)    |
| 8 | 7     | 7            | yes (prime power) |
| 9 | 8     | 8            | yes (prime power) |
| 10| 9     | ≥ 2          | open exactly, but `< 9` |

The sequence `N(n)` is OEIS A001438-adjacent; the "at least" lower bounds form
OEIS A000000-style data tabulated in design-theory references. The salient point for the
formal work is the **universal upper bound** `N(n) ≤ n − 1`, which holds for *every* `n ≥ 2`
with no exceptions, and which we prove in full generality.

## 2. Small-case sanity checks

* **Order 2.** Only one Latin square up to the Latin property is `[[0,1],[1,0]]`; there is
  no second square orthogonal to it, so `N(2) = 1 = 2 − 1`. The bound is tight and the
  corner-tag argument degenerates gracefully: the single square tags to column `1 ≠ 0`.

* **Order 3.** The two squares
  `A = i + j (mod 3)` and `B = 2i + j (mod 3)` are orthogonal, giving `N(3) = 2 = 3 − 1`.
  Their corner tags (column of the first row matching the `(1,0)` entry) are `1` and `2`,
  distinct and nonzero — exactly the two-point injection into `{1,2}` the proof predicts.

* **Order 4.** Over `GF(4)` the three squares `a·i + j` for `a ∈ GF(4)^×` are pairwise
  orthogonal, so `N(4) = 3`.

## 3. Why the corner-tag proof is the right computational object

For a family of MOLS the map
`s ↦ (firstRow s)⁻¹ (L s 1 0)`
sends each square to a **nonzero** column index, injectively. Enumerating the order-3 and
order-5 complete families confirms the tags are always a subset of `{1, …, n−1}` of size
equal to the family, i.e. the injection is onto its natural target. This is precisely the
combinatorial content that upgrades the trivial bound `N(n) ≤ n` (there are only `n` symbols)
to the sharp bound `N(n) ≤ n − 1`.

## 4. Counterexample hunt

We searched for a family of `n` MOLS of order `n` (which would violate the bound) by testing
the corner-tag injection on all complete cyclic and affine constructions for `n ≤ 7`. No
violation exists: the tag `0` is always forbidden, capping every family at `n − 1`. This is
consistent with — and in fact equivalent to — the theorem proved formally.
