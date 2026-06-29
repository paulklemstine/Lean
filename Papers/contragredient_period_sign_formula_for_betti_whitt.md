# Computational Evidence — contragredient sign `(-1)^{b(F,n)}`

Bottom degree `b(F,n) = r₁·⌊n²/4⌋ + r₂·n(n-1)/2`, sign `s(F,n) = (-1)^{b(F,n)}`.

## 1. Small-case tables (the two contributions, mod 2)

```
n        : 0 1 2 3 4 5 6 7 8 9 10 11
⌊n²/4⌋   : 0 0 1 2 4 6 9 12 16 20 25 30
  mod 2  : 0 0 1 0 0 0 1 0  0  0  1  0     (odd  ⟺  n ≡ 2 mod 4)
n(n-1)/2 : 0 0 1 3 6 10 15 21 28 36 45 55
  mod 2  : 0 0 1 1 0 0  1  1  0  0  1  1    (odd  ⟺  n ≡ 2 or 3 mod 4)
```

Both contributions are exactly period-4 in `n`. This is the empirical seed for
`floorSq_odd_iff` and `triangular_odd_iff` in `BottomDegreeParity.lean`.

## 2. The resulting sign trichotomy (`n mod 4`)

| n mod 4 | ⌊n²/4⌋ parity | n(n-1)/2 parity | b(F,n) mod 2 | sign s(F,n)      |
|---------|---------------|-----------------|--------------|------------------|
| 0       | even          | even            | 0            | +1 (all fields)  |
| 1       | even          | even            | 0            | +1 (all fields)  |
| 2       | odd           | odd             | r₁ + r₂      | (-1)^{r₁+r₂}     |
| 3       | even          | odd             | r₂           | (-1)^{r₂}        |

Striking point: for `n ≡ 3 (mod 4)` the real-place count `r₁` does not affect the sign.

## 3. Counterexample hunt

Brute-force check of the closed-form characterization against the direct definition
`(-1)^{r₁·⌊n²/4⌋ + r₂·n(n-1)/2}` over the box `0 ≤ n ≤ 40`, `0 ≤ r₁,r₂ ≤ 6`
(≈ 41·7·7 = 2009 triples): **no counterexample**. The trichotomy above matched the
direct computation in every case. The robustness explanation: `(-1)^k` depends only on
`k mod 2`, and both contributions are period-4 in `n`, so the whole sign is a function of
`(n mod 4, r₁ mod 2, r₂ mod 2)` — a finite table, fully covered by the proofs.

## 4. Self-dual obstruction (sanity check)

`PeriodAlgebra.lean` predicts: a nonzero bottom Betti–Whittaker period can be self-dual
(`p∨ = p`) only when `b(F,n)` is even. Equivalently, self-duality is *obstructed* exactly when
the sign is `-1`:

* `n ≡ 2 (mod 4)`, `r₁ + r₂` odd  ⟹  no self-dual generic cohomological `π`;
* `n ≡ 3 (mod 4)`, `r₂` odd       ⟹  no self-dual generic cohomological `π`.

Example: over an imaginary quadratic field (`r₁ = 0, r₂ = 1`) and `n ≡ 3 (mod 4)`, the sign is
`-1`, so self-duality of the bottom period is impossible — consistent with the table.

All claims here are discharged formally (0 sorries) in the two Lean files.
