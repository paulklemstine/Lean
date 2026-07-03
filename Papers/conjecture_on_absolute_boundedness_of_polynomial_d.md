# Computational Evidence — Polynomial Diophantine Tuples with a `k`-th Power Condition

Configuration: a commutative ring `R`, exponent `k ≥ 2`, shift `n`, and a set
`A ⊆ R` with `a·b + n` a perfect `k`-th power for every pair of distinct
`a, b ∈ A` (property `D_k(n)`). Target ring: `F[x]`, `F` algebraically closed of
characteristic `0`.

## 1. Small-case calculations

### Constants over an algebraically closed field
Over `ℂ` every element is a `k`-th power, so `a·b + n` is *always* a `k`-th power.
Sampled `k = 2, n = 1`:

| A ⊆ ℂ                     | all pairs `ab+1` a square? |
|---------------------------|----------------------------|
| `{0,1,2,3,4}` (5 consts)  | yes (ℂ is closed)          |
| `{0,1,…,99}` (100 consts) | yes                        |
| any finite `S ⊆ ℂ`        | yes                        |

Conclusion: among **constants** the tuple size is unbounded. The `≤ 6` phenomenon
must live in the *degree* structure of `F[x]`. (Formalized:
`algClosed_constants_dioSet`, `algClosed_dioSet_arbitrarily_large`.)

### Degree bookkeeping in `F[x]`
For distinct `a, b` of common degree `d ≥ 1` with `deg n < 2d`:
`deg(a·b + n) = 2d`. If `a·b + n = c^k` then `deg = k·deg c`, so `k ∣ 2d`.

| k | d | `2d` | `k ∣ 2d`? | verdict for a same-degree pair |
|---|---|------|-----------|--------------------------------|
| 2 | 1 | 2    | yes       | possible                       |
| 2 | 3 | 6    | yes       | possible                       |
| 3 | 1 | 2    | **no**    | **impossible** (no such pair)  |
| 3 | 2 | 4    | **no**    | **impossible**                 |
| 3 | 3 | 6    | yes       | possible only if `3 ∣ d`       |
| 4 | 1 | 2    | **no**    | **impossible**                 |
| 4 | 2 | 4    | yes       | possible                       |

Conclusion: the divisibility `k ∣ 2d` is a genuine obstruction. (Formalized:
`sameDeg_dioSet_two_dvd`, `no_degree_one_cubic_dio_pair`.)

### The `0`-element and the `k`-th power exception
If `0 ∈ A` then for any nonzero `a ∈ A`, `0·a + n = n` must be a `k`-th power. So
`0` can join `A` exactly when `n` is a perfect `k`-th power — the precise
exceptional clause of the conjecture. (Formalized: `dioSet_insert_zero_iff`.)

## 2. Counterexample hunt for a discarded conjecture
Tested "a common factor `g` of distinct members `a,b` divides `n`":
take `a = x`, `b = x`, `n = 1`, `k = 2`... more sharply `a = x·u`, `b = x·v` with
`ab + n = x²uv + n = c²`. Here `g = x` divides `ab` but `n = c² − ab ≡ c² (mod x)`,
which does **not** force `x ∣ n`. Explicit: `a = 2x, b = 2x, n = 1` (over ℚ) gives
`4x² + 1`, no factor of `2x` in `1`. The heuristic is FALSE and was dropped; the
correct primitive is coprimality of a member with `n`, not divisibility.

## 3. OEIS
No integer sequence is central here; the object is a structural/degree
phenomenon rather than an enumeration, so no OEIS entry is invoked.

## 4. Summary table of formalized outcomes

| Claim                                             | status     | Lean name                              |
|---------------------------------------------------|------------|----------------------------------------|
| constants over `alg. closed F` are always `D_k(n)`| proved     | `algClosed_constants_dioSet`           |
| unbounded constant tuples exist                   | proved     | `algClosed_dioSet_arbitrarily_large`   |
| same-degree tuples force `k ∣ 2d`                 | proved     | `sameDeg_dioSet_two_dvd`               |
| no degree-1 cubic Diophantine pair over `ℚ[x]`    | proved     | `no_degree_one_cubic_dio_pair`         |
| `0`-extension ⇔ `n` a perfect `k`-th power        | proved     | `dioSet_insert_zero_iff`               |
| common-factor-divides-`n` heuristic               | false      | (discarded, §2)                        |
| full `≤ 6` bound for nonconstant tuples           | open       | (see FUTURE_DIRECTIONS.md)             |
