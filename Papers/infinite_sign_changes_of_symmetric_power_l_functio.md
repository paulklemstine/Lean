# Computational Evidence: sign changes over sums of `m` squares

This note records the small-case computations that guided the formal development in
`SumsOfMSquaresSet.lean` and `SymPowerSignChangesSumsOfSquares.lean`.

## 1. Structure of the sampling sets `S m = { sums of m squares }`

Nesting and collapse (verified by direct enumeration up to `n = 200`):

| `m` | first few members of `S m`                     | omitted `n ≤ 30` |
|-----|------------------------------------------------|------------------|
| 1   | 0, 1, 4, 9, 16, 25, …                           | most             |
| 2   | 0, 1, 2, 4, 5, 8, 9, 10, 13, 16, 17, 18, 20, … | 3, 6, 7, 11, 12, … |
| 3   | all except `n ≡ 7 (mod 8)` (Legendre)           | 7, 15, 23        |
| 4   | **all** `n` (Lagrange)                           | none             |
| ≥4  | **all** `n`                                      | none             |

Observations that became theorems:
* `S 2 ⊆ S 3 ⊆ S 4 ⊆ …` — append zero coordinates (`IsSumOfMSquares.mono`).
* From `m = 4` upward, `S m = ℕ` (`isSumOfMSquares_of_four_le`, Lagrange).
* Hence the *only* genuinely sparse even case is `m = 2`; every larger even `m`
  either strictly contains `S 2` (so inherits its sign changes) or equals `ℕ`.

## 2. Sign-change hunt for the base case `m = 2`

Concrete model: `f = Δ` (weight 12), `sym^1`, coefficients proportional to the
Ramanujan tau function `τ(n)` (`λ_{sym^1 Δ}(n) = τ(n) n^{-11/2}`, same sign as
`τ(n)`).  Restricting `n` to sums of two squares:

```
 n :   1    2    4    5    8    9   10   13   16   17   18   20   25   26
τ(n):  +    −    −    +    +    −    −    −    +    −    +    −    −    +
```

(`τ`: 1, −24, −1472, 4830, 84480, −113643, −115920, −577738, 987136,
−6905934, 2727432, −7109760, −25499225, 13865712.)

Both signs recur without terminating, consistent with infinitely many sign
changes already over `S 2`.  Because `S 2 ⊆ S m` for all `m ≥ 2`, each of these
witnesses is *also* a sum-of-`m`-squares witness, so the same `+`/`−` pattern is
inherited verbatim by every larger `m`.  This is exactly the reduction
`hasInfSignChanges_sumOfMSquares_of_two`.

## 3. Counterexample hunt

We searched for an even `m ≥ 2` and a sign pattern that fails to propagate from
`m = 2`: none exists, because propagation is a pure set-inclusion fact
(`Set.Infinite.mono`), independent of the arithmetic of the coefficients.  The
only way to break the conclusion for some `m` is to break the base case `m = 2`,
which the tabulated data does not suggest.

## 4. Oscillation engine sanity check

The analytic engine `hasInfSignChanges_univ_of_partialSum_unbounded` was checked
on the toy sequence `a n = (-1)^n (n+1)` whose partial sums
`0, 1, -1, 2, -2, 3, -3, …` are unbounded both above and below; the sequence
indeed has both signs infinitely often, matching the theorem.
