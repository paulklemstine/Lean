# Computational Evidence — Mutually Orthogonal Italian Squares

This note records the small-case evidence that motivated the formal development in
`Basic.lean`, `UpperBound.lean`, and `PrimePower.lean`.  An *Italian square* of
order `n` is the combinatorial object classically called a Latin square (every row
and every column a permutation); two are *orthogonal* if superimposing them lists
every ordered pair of symbols exactly once.  Write `N(n)` for the maximum size of
a mutually orthogonal family of order `n`.

The two facts we formalize are:

* **Upper bound (all `n ≥ 2`):** `N(n) ≤ n − 1`.   (`MutuallyOrthogonal.card_le`)
* **Attainment for prime powers:** `N(q) = q − 1` whenever `q` is a prime power.
  (`affine_isGreatest`, `galoisField_isGreatest`)

## 1. Small-case values of `N(n)`

| n  | prime power? | n − 1 | known `N(n)` | bound attained? |
|----|--------------|-------|--------------|-----------------|
| 2  | yes (2)      | 1     | 1            | yes             |
| 3  | yes (3)      | 2     | 2            | yes             |
| 4  | yes (2²)     | 3     | 3            | yes             |
| 5  | yes (5)      | 4     | 4            | yes             |
| 6  | no           | 5     | 1            | **no**          |
| 7  | yes (7)      | 6     | 6            | yes             |
| 8  | yes (2³)     | 7     | 7            | yes             |
| 9  | yes (3²)     | 8     | 8            | yes             |
| 10 | no           | 9     | ≥2, ≠9       | **no**          |
| 11 | yes (11)     | 10    | 10           | yes             |
| 12 | no           | 11    | open (≥5)    | unknown         |

Two classical landmarks appear in this table and corroborate the "prime power"
threshold:

* `n = 6` is Euler's *36 officers* problem: no two orthogonal squares of order 6
  exist, so `N(6) = 1`, far below the bound `5`.  `6` is not a prime power.
* `n = 10` has no projective plane (Lam–Thiel–Swiercz, 1989), so `N(10) ≠ 9`,
  again below the bound.  `10` is not a prime power.

## 2. The field construction (the content of `PrimePower.lean`)

For a finite field `K` of order `q`, the `q − 1` squares
`L_a(i, j) = a·i + j`  (`a ∈ K \ {0}`)
are mutually orthogonal Italian squares.  Verified by hand for `q = 3`
(`K = ZMod 3`, slopes `a ∈ {1, 2}`):

```
L_1:            L_2:
0 1 2           0 1 2
1 2 0           2 0 1
2 0 1           1 2 0
superimposed (L_1,L_2) entries (row i, col j) = (i+j, 2i+j):
(0,0)(1,1)(2,2)
(1,2)(2,0)(0,1)
(2,1)(0,2)(1,0)
```
all nine ordered pairs occur exactly once, so `L_1 ⟂ L_2` and `N(3) = 2 = 3 − 1`.

## 3. Counterexample hunt for the *upper bound*

The bound `N(n) ≤ n − 1` is universal; we searched the literature values above for
any `n` with `N(n) > n − 1` and found none (consistent with the theorem, since a
`(n)`-net would force a projective plane of order `n`, impossible by a counting
argument — exactly the `g`-injectivity argument formalized in `UpperBound.lean`).

## 4. Sequence note

The values `N(2), N(3), … = 1, 2, 3, 4, 1, 6, 7, 8, …` match the maximal-MOLS
sequence tabulated in the design-theory literature (Van Lint & Wilson 1992,
Ch. 22).  The dip at `n = 6` is the signature of the prime-power phenomenon.

## Status of the full conjecture

The mission's conjecture states the bound is attained *exactly when* `n` is a prime
power.  We formally prove the **upper bound for all `n`** and the **prime-power ⇒
attainment** direction.  The reverse implication (attainment ⇒ prime power) is the
long-standing *prime power conjecture for projective planes* and is open
(e.g. order 12 is undecided); it is recorded as a future direction rather than a
theorem.
