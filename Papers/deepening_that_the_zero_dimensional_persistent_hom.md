# Computational Evidence — Unbounded prime gaps and the growth of the prime Betti curve

We study the zero-dimensional Vietoris–Rips barcode of the prime point cloud
`P n = p_n = nth Nat.Prime n` on the real line, continuing
`Shared/PrimeBarcodeInvariants.lean`.  The relevant invariant is the Betti number

```
b₀(ε, n) = bettiZero P ε n = 1 + #{ i < n : ε < p_{i+1} − p_i }.
```

The new results concern what happens as `n → ∞` for a *fixed* resolution `ε`.

## 1. Prime gap sequence

`primeGap n = p_{n+1} − p_n`, `n = 0, 1, 2, …`:

```
p_n   : 2  3  5  7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97 101 103 ...
gap_n :  1  2  2  4  2  4  2  4  6  2  6  4  2  4  6  6  2  6  4  2  6  4  6  8  4  ...
```

This is OEIS **A001223** (differences of consecutive primes): `1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, ...`.

## 2. The gaps are unbounded

Standard elementary fact (Euclid-style): for every `N ≥ 2` the `N−1` consecutive
integers `N! + 2, N! + 3, …, N! + N` are all composite, because `j ∣ N!` for
`2 ≤ j ≤ N`, hence `j ∣ (N! + j)` with `1 < j < N! + j`.  Therefore there is a run
of at least `N − 1` composites, and the consecutive prime gap straddling that run is
`≥ N`.  Concretely, the first record gaps are

```
record gaps: gap grows without bound; e.g. first gap ≥ 8 at (89, 97),
             ≥ 14 at (113, 127), ≥ 34 at (1327, 1361), etc.
```

Because such runs occur arbitrarily far out (choose `N` as large as we like), the set
`{ n : c < gap_n }` is **infinite** for every constant `c`.

## 3. The Betti curve grows without bound

Betti number at resolution `ε = 4` (`b₀ = 1 + #{i<n : gap_i > 4}`), tabulated over `n`:

```
n     : 0  5 10 15 20 24 ...
gaps>4 among first n:      the gaps exceeding 4 are 6,6,6,6,8,...
b₀(4,n): 1  1  2  4  5  6 ...   (increases by 1 each time a gap > 4 is passed)
```

Since infinitely many gaps exceed any fixed `ε`, the count `#{i<n : ε < gap_i}` — and
hence `b₀(ε, n)` — is a nondecreasing sequence in `n` that is **unbounded**.  Thus:

* For every fixed resolution `ε ≥ 0`, `b₀(ε, n) → ∞` as `n → ∞`.
* In particular, for every `ε` there is an `n` with `b₀(ε, n) > 1`: **the prime cloud
  cannot be held connected at any fixed resolution** as more primes are added — there
  is no global merge scale valid for the whole infinite cloud.

## 4. Total persistence diverges

`totalPersistence P n = p_n − 2 → ∞`, since `p_n → ∞` (`nth Nat.Prime` is strictly
increasing on `ℕ`).  So the aggregate persistence of the barcode also diverges.

## Summary of what is formalized

The Lean file `Shared/PrimeBarcodeUnbounded.lean` proves, with no `sorry`:

1. `factorial_add_not_prime` — the composite-run lemma.
2. `exists_large_primeGap` — arbitrarily large prime gaps arbitrarily far out.
3. `setOf_primeGap_gt_infinite` — `{n : c < primeGap n}` is infinite.
4. `prime_bettiZero_unbounded`, `prime_bettiZero_tendsto_atTop` — the prime Betti
   curve is unbounded / tends to `∞` at every fixed resolution.
5. `prime_eventually_disconnected` — no fixed resolution keeps the cloud connected.
6. `prime_totalPersistence_tendsto_atTop` — total persistence diverges.
