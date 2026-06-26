# Computational Evidence — Mutually Orthogonal Italian (Latin) Squares

We write `N(n)` for the maximum number of pairwise orthogonal Italian squares of
order `n` (Italian square = Latin square; the classical MOLS quantity).

## 1. Small-case calculations of `N(n)`

| n  | prime power? | upper bound n−1 | actual N(n) | bound attained? |
|----|--------------|-----------------|-------------|-----------------|
| 2  | yes (2)      | 1               | 1           | yes             |
| 3  | yes (3)      | 2               | 2           | yes             |
| 4  | yes (2²)     | 3               | 3           | yes             |
| 5  | yes (5)      | 4               | 4           | yes             |
| 6  | **no**       | 5               | **1**       | **no** (Euler/Tarry "36 officers") |
| 7  | yes (7)      | 6               | 6           | yes             |
| 8  | yes (2³)     | 7               | 7           | yes             |
| 9  | yes (3²)     | 8               | 8           | yes             |
| 10 | **no**       | 9               | ≥ 2 (and < 9; exact value still open, ≤ 6) | **no** |
| 11 | yes (11)     | 10              | 10          | yes             |
| 12 | no           | 11              | ≥ 5 (open)  | unknown         |

Observations consistent with the formalized theorems:
- The upper bound `N(n) ≤ n − 1` (`ItalianSquares.card_le_card_sub_one`) holds in
  every row.
- For every prime power `n` the bound is attained
  (`ItalianSquares.exists_mols_prime_power`), via the affine squares
  `S_a(i,j) = a·i + j`.
- `n = 6` is the smallest order where the bound is *not* attained: there do not even
  exist two orthogonal squares (Euler's conjecture, proved by Tarry 1900). This is
  precisely the subtlety that makes the *converse* ("attained ⟹ prime power") false
  as a naive equivalence and genuinely hard in general.

## 2. Explicit affine construction over `GF(3)` (order 3, two MOLS)

Symbols `{0,1,2} = ℤ/3`. Squares `S_a(i,j) = a·i + j`.

`S₁` (a = 1):
```
0 1 2
1 2 0
2 0 1
```
`S₂` (a = 2):
```
0 1 2
2 0 1
1 2 0
```
Superposition `(S₁, S₂)` cell-by-cell:
```
(0,0) (1,1) (2,2)
(1,2) (2,0) (0,1)
(2,1) (0,2) (1,0)
```
All nine ordered pairs appear exactly once ⇒ `S₁ ⊥ S₂`. So `N(3) = 2 = 3 − 1`,
matching `exists_mols_prime_power 3 1`.

## 3. Counterexample hunt for the (false) naive converse

Claim tested: "if `N(n) = n − 1` then `n` is a prime power." This is the OPEN
direction. No counterexample is known (it would be a projective plane of
non-prime-power order), but nonexistence is also unproven. Known *negative* data
points (`n = 6, 10`) show the bound fails for some non-prime-powers, which is
necessary—but not sufficient—for the converse. We therefore do **not** assert the
converse in Lean; see `FUTURE_DIRECTIONS.md`.

## 4. OEIS

The sequence `N(n)` for `n = 1,2,3,…` is OEIS [A001438]-related; the maximal-MOLS
sequence is A287695 / A000000-style entries (values `0,1,2,3,4,1,6,7,8,2,10,…`).
The prime-power upper-bound attainment matches A000961 (prime powers).

## 5. Method note

These are classical tabulated values (Van Lint & Wilson, *A Course in
Combinatorics*, Ch. 22; Brualdi & Dahl 2018). The order-6 nonexistence is a finite
fact; the order-10 and order-12 entries are research-level. Only the upper bound and
the prime-power construction are claimed as *formally verified* here.
