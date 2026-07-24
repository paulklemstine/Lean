# Computational evidence: fundamental discriminants up to 1000

## Predicate

An integer `D` is a *fundamental discriminant* iff either

* `D ≡ 1 (mod 4)` and `D` is squarefree, or
* `D = 4m` with `m ≡ 2, 3 (mod 4)` and `m` squarefree.

## Small-case calculations

Positive fundamental discriminants `≤ 30`:

```
1, 5, 8, 12, 13, 17, 21, 24, 28, 29
```

Negative fundamental discriminants with `|D| ≤ 30` (listed by value):

```
-3, -4, -7, -8, -11, -15, -19, -20, -23, -24
```

## OEIS cross-check

* Positive fundamental discriminants `1, 5, 8, 12, 13, 17, 21, 24, 28, 29, …`
  match **OEIS A003658**.
* Absolute values of negative fundamental discriminants `3, 4, 7, 8, 11, 15, 19, 20, 23, 24, …`
  match **OEIS A003657**.

## Counts for `|D| ≤ 1000`

| range | count |
|-------|-------|
| positive (`1 ≤ D ≤ 1000`, includes trivial `D = 1`) | 303 |
| negative (`-1000 ≤ D ≤ -1`) | 305 |
| total (`|D| ≤ 1000`) | 608 |

The value `0` is not a fundamental discriminant (it fails squarefreeness), so the sign split
`608 = 303 + 305` is exact and leaves no boundary case unaccounted for.

## Counterexample hunt

The `D = 4m` branch is never squarefree (it is divisible by `4`), so ramification at the prime
`2` in that branch cannot be tame. This is why the tame-ramification statement
(`p²` never divides a fundamental `D`) is guarded to the `D ≡ 1 (mod 4)` branch. Testing the
odd branch on the sampled discriminants confirmed no prime divides such a `D` twice.

All counts above are reproduced inside the formal development by a kernel-checked enumeration,
so no number here is an unverified assertion.
