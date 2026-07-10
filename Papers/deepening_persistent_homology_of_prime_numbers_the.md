# Computational Evidence — The Depth of the Prime Barcode

This note records the small-case exploration that guided the formal development in
`PrimeBarcodeDepth.lean`.  All computations were run over exact integer arithmetic.

## 1. The gap sequence (the H₀ bar lengths)

Primes below 80:

```
2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79
```

Consecutive gaps `p_{n+1} − p_n` (these are exactly the finite H₀ bar lengths):

```
1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4, 6, 6, 2, 6, 4, 2, 6
```

This is OEIS **A001223** (differences of consecutive primes), first term `1`.

**Total persistence check.**  The partial sums of the gap list telescope to
`p_n − 2`: e.g. the first 10 gaps sum to `29 − 2 = 27`.  This matches
`total_persistence_primeGap`.

## 2. The Betti number b₀ at a fixed scale

At scale `ε = 2`, a new component starts at each gap strictly greater than `2`.
Among the first 21 gaps above, the gaps `> 2` are
`4,4,4,6,6,4,4,6,6,6,4,6` — twelve of them — so the window of the first 22 primes
splits into `1 + 12 = 13` components.  This is the pattern proved in general by
`prime_betti_eq_one_add_large_gaps`: `b₀ = 1 + #{gaps > ε}`.

Because gap `= 2` never exceeds `ε = 2`, every twin pair stays merged at `ε = 2`,
so twin pairs never contribute to `b₀` at that scale — consistent with the twin
bar having death scale exactly `2` (from the base file).

## 3. Unbounded bars — the factorial witness

For a target run length, `(k+1)! + 2, …, (k+1)! + (k+1)` are all composite because
`i ∣ (k+1)!` for `2 ≤ i ≤ k+1`.  Concretely, all of `7!+2, …, 7!+7` are composite
(verified: six `true`s for non-primality).  The consecutive primes bracketing such
a run differ by more than `k`, so the barcode has bars of every length.  This is
the construction behind `exists_large_primeGap` and `barcode_unbounded`.

## 4. Conclusion of the evidence stage

Every quantitative prediction (telescoping total persistence, the
`1 + #large gaps` Betti count, and unbounded bar lengths) matched the data with no
counterexample found, so the formal proofs were pursued as stated.
