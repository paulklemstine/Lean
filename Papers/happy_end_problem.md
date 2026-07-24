# Computational Evidence — Erdős–Szekeres Cup–Cap Theorem

This note records the small-case data underpinning `Geometry/ErdosSzekeresCupCap.lean`.
All numbers below are reproduced inside Lean (see `#eval`s used during development);
the theorems themselves are proved for **all** `n`, so the tables are illustrative,
not a substitute for proof.

## 1. The cup–cap function

For a `k`-cup / `l`-cap the theorem proves the sharp threshold

```
f(k, l) = C(k + l - 4, k - 2) + 1
```

points (in general position, distinct `x`-coordinates) force a `k`-cup or an
`l`-cap.  Reparametrising `k = a+2`, `l = b+2` gives the clean Pascal form
`f = C(a+b, a) + 1`, which is how the file states and proves it (avoiding
truncated ℕ-subtraction).

Small table of `f(k, l) = C((k-2)+(l-2), k-2) + 1`:

| k \ l | 2 | 3 | 4  | 5  |
|-------|---|---|----|----|
| 2     | 2 | 2 | 2  | 2  |
| 3     | 2 | 3 | 4  | 5  |
| 4     | 2 | 4 | 7  | 11 |
| 5     | 2 | 5 | 11 | 21 |

The base row/column `f(2, l) = f(k, 2) = 2` and the Pascal recurrence
`f(k, l) = f(k-1, l) + f(k, l-1) - 1` are exactly the structure of the proof
(`erdos_szekeres_cupcap`, base cases + the `cupEndpoints` split + `Nat.choose_succ_succ`).

## 2. Diagonal values (Happy-End upper bound)

`erdos_szekeres_diagonal` / `happy_end` use `k = l = n`, giving the classical
Erdős–Szekeres upper bound `ES(n) ≤ C(2n-4, n-2) + 1`:

| n | C(2n-4, n-2) + 1 |
|---|------------------|
| 3 | 3   |
| 4 | 7   |
| 5 | 21  |
| 6 | 71  |
| 7 | 253 |

These match the catalog's independently-checked `CupCapNumber` values
(`cupCapNumber_3_3 = 3`, `cupCapNumber_4_4 = 7`, `cupCapNumber_5_5 = 21`).

## 3. Relationship to the true Happy-End numbers

The *exact* minimum `ES(n)` (Erdős–Szekeres / "Happy End") numbers are
`3, 5, 9, 17, 33, …`, conjectured to equal `2^{n-2} + 1` (OEIS A052548 gives
`2^{n-2}+1`: 2, 3, 5, 9, 17, 33, …; the ES numbers are the `n ≥ 3` tail).
The cup–cap number `C(2n-4,n-2)+1` proved here is the classical **upper** bound
(`3, 7, 21, 71, 253, …`) and is sharp for the cup–cap problem itself.  Closing
the gap to `2^{n-2}+1` is the famous open problem; the sharpest known upper bound
(Suk 2017 and refinements) is `2^{n + o(n)}`, still far from formalized.

## 4. Sanity checks performed

* Verified `C(k+l-4,k-2)+1` satisfies `f(2,l)=f(k,2)=2` and the Pascal recurrence
  on the `2..5` grid.
* Verified the diagonal values `3,7,21,71,253` for `n = 3..7`.
* The base cases of the existence proof (`hasCupIn_two`, `hasCapIn_two`) and the
  trichotomy (`cup_or_cap_triple`) were checked to be genuinely used, so the
  bound is not vacuous.
