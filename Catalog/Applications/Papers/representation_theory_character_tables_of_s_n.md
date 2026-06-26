# Computational Evidence — Character tables of `Sₙ`

This note records the small-case computations that guided the formal proofs in
`ConjClassCount.lean` and `LinearCharacters.lean`.

## 1. Number of rows of the character table = number of conjugacy classes = `p(n)`

For `Sₙ` the conjugacy classes are indexed by cycle type, i.e. by partitions of `n`.
So the character table is a `p(n) × p(n)` square. Partition numbers (OEIS **A000041**):

| `n`  | 0 | 1 | 2 | 3 | 4 | 5 | 6  | 7  |
|------|---|---|---|---|---|---|----|----|
| `p(n)` | 1 | 1 | 2 | 3 | 5 | 7 | 11 | 15 |

Verified in Lean (`native_decide` on `Fintype.card (Nat.Partition n)`):

* `Fintype.card (Nat.Partition 3) = 3`
* `Fintype.card (Nat.Partition 4) = 5`
* `Fintype.card (Nat.Partition 5) = 7`

Transported through the explicit bijection `partitionEquivConjClasses` to give the
number of conjugacy classes of `S₃, S₄, S₅` as `3, 5, 7`.

The three small character tables (for orientation; only the two linear rows are
formally verified here):

```
S₃ (classes: e, (ab), (abc); sizes 1,3,2)
        e   (ab)  (abc)
triv    1    1     1
sign    1   -1     1
std     2    0    -1

S₄ has 5 classes / 5 irreducibles of dims 1,1,2,3,3  (1+1+4+9+9 = 24 = 4!)
S₅ has 7 classes / 7 irreducibles of dims 1,1,4,4,5,5,6 (1+1+16+16+25+25+36 = 120 = 5!)
```

The sum-of-squares-of-dimensions checks (`= n!`) were verified by hand arithmetic and
are consistent with the row counts above.

## 2. Sum of signs over `Sₙ`

Tested computationally that `∑_{σ ∈ Sₙ} sgn σ = 0` for `n ≥ 2` and `= 1` for `n ≤ 1`:

| `n` | #even | #odd | `∑ sgn` |
|-----|-------|------|---------|
| 0   | 1     | 0    | 1       |
| 1   | 1     | 0    | 1       |
| 2   | 1     | 1    | 0       |
| 3   | 3     | 3    | 0       |
| 4   | 12    | 12   | 0       |
| 5   | 60    | 60   | 0       |

This confirms the `2 ≤ n` hypothesis is exactly the threshold: below it the trivial and
sign characters coincide. Formalized as `sum_sign_eq_zero`.

## 3. Orthonormality of the two linear rows

For `n ≥ 2`, with `⟨f,g⟩ = (1/n!) ∑_σ f σ · g σ`:

* `⟨triv, triv⟩ = (1/n!)·n! = 1`
* `⟨sign, sign⟩ = (1/n!)·∑ (±1)² = (1/n!)·n! = 1`
* `⟨triv, sign⟩ = (1/n!)·∑ sgn σ = 0`

All three confirmed both numerically (above table) and formally
(`charInner_triv_triv`, `charInner_sign_sign`, `charInner_triv_sign`).
