# Computational Evidence — Matsuno's Formula with Non-Vanishing μ

We model the sharp/flat λ-difference of the quadratic twist `E^D` by

```
lambdaDiffMu D N_E μ = lambdaDiff D N_E + μ · Σ_{ℓ ∣ D} 2^{n_ℓ},   n_ℓ = v₂((ℓ²−1)/8).
```

## 1. Small-case local depths and μ-weights

For the first few odd primes `ℓ`, the `2`-adic depth `n_ℓ = v₂((ℓ²−1)/8)` and the local
μ-weight `2^{n_ℓ}` are:

| ℓ  | (ℓ²−1)/8 | n_ℓ | μ-weight 2^{n_ℓ} |
|----|----------|-----|------------------|
| 3  | 1        | 0   | 1                |
| 5  | 3        | 0   | 1                |
| 7  | 6        | 1   | 2                |
| 17 | 36       | 2   | 4                |
| 31 | 120      | 3   | 8                |
| 97 | 1176     | 3   | 8                |

So `n = [0,0,1,2,3,3]` and `2^{n} = [1,1,2,4,8,8]`, matching the identity
`n_ℓ + 3 = v₂(ℓ−1) + v₂(ℓ+1)` (exactly one of `ℓ ± 1` is divisible by `4`).

## 2. The μ-term is proportional to μ and prime-supported

With a single prime `ℓ` and μ-invariant `μ`, the correction to the classical Matsuno term
is `μ · 2^{n_ℓ}`. For `ℓ = 7`, incrementing `μ = 0,1,2,3` gives corrections `0,2,4,6`:
strictly linear in `μ`, and positive exactly when `μ > 0`.

For `D = 7 · 17 = 119` (coprime factors), the total μ-weight is `2 + 4 = 6`, i.e. the sum
of the per-prime weights — the correction is completely additive over coprime moduli.

## 3. Non-vanishing threshold

The correction `μ · Σ_{ℓ ∣ D} 2^{n_ℓ}` is zero iff `μ = 0` or `D` has no prime divisor
(`D ∈ {0,1}`). Whenever `μ ≥ 1` and `D ≥ 2`, the μ-corrected difference is strictly larger
than the classical prediction — a non-zero μ-invariant is always detectable in the twist.

## 4. Counterexample hunt

We tested complete additivity `lambdaDiffMu(a·b) = lambdaDiffMu a + lambdaDiffMu b` on all
coprime pairs built from `{3,5,7,17,31}` and found no counterexample; the hypothesis of
coprimality is necessary (for `a = b` the shared prime support is double-counted). No
counterexample to monotonicity in the level or in `μ` was found.

## OEIS note

The depth sequence `n_ℓ = [0,0,1,2,3,3,…]` over odd primes and the μ-weights `2^{n_ℓ}` are
elementary `2`-adic valuations; no distinctive OEIS entry is claimed for the composite
`lambdaDiffMu` model, which depends on the auxiliary conductor and reduction-order data.
