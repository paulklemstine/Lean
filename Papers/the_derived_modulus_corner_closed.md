# Computational Evidence — Derived-Modulus Corner

All numbers below were produced with `#eval` inside the project's Lean 4 /
Mathlib environment (kernel-level evaluation, no external scripts).  Each block
is labelled with the theorem it motivated; the theorem itself is proved in the
`Catalog/Physics/DerivedModulus*.lean` files and does **not** rely on these
computations.

## 1. gcd(N, M) = 1 for every derived modulus (→ `family_coprime`)

`N = (2k+3)(2k+5)`, `k = 0..9`, columns
`gcd(N,N-1), gcd(N,N+1), gcd(N,N²+1), gcd(N,N²+N+1), gcd(N,2N+1)`:

```
N   :  15  35  63  99 143 195 255 323 399 483
gcds:   1   1   1   1   1   1   1   1   1   1   (all five columns)
```

Uniformly 1, matching the proved identity `gcd(N, f(N)) = gcd(N, f(0))`.

## 2. lpf degeneracy (→ `lpf_linear_moduli_constant`, `minFac_sqSucc_eq_two`)

For the same ten odd semiprimes, `(minFac (N+1), minFac (N-1)) = (2,2)` in
every case.  Extending the check to the quadratic modulus:

```
N        :   143    483    1023    1763    2703     3843
minFac(N²+1):  2      2       2       2       2        2
minFac(N²+N+1): 20593  157     13     673  7308913  14772493
```

The `N²+1` column is constant `2` (proved: `N² + 1 ≡ 2 (mod 8)` for odd `N`),
while `Φ₃(N)` requires a genuinely fresh factorisation — motivating barrier 4.

## 3. Pairwise resultant bounds (→ `family_pairwise_gcd_le_seven`)

`gcd(N²+1, 2N+1)` for `N = 0..11`:

```
1, 1, 5, 1, 1, 1, 1, 5, 1, 1, 1, 1
```

`gcd(N²+N+1, 2N-1)` for `N = 0..11`:

```
1, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 7
```

Values are always divisors of the resultants (5 and 7 respectively), and the
bounds are attained (at `N = 2, 7` and `N = 4, 11`); this is the content of the
proved bounds plus `pairwise_bounds_sharp`.

## 4. Useful-hint counting (→ `useful_hint_count`)

Number of `h ∈ [0, N)` with `gcd(N,h) ≠ 1`:

```
N = 35  = 5·7   :  11  =  5 + 7  - 1
N = 143 = 11·13 :  23  = 11 + 13 - 1
```

Exactly the proved formula `p + q - 1`.

## 5. Prime spectra of the quadratic moduli (→ `*_spectrum_N_independent`)

Primes below 80 dividing some `N² + 1` (`N < 200`):

```
2, 5, 13, 17, 29, 37, 41, 53, 61, 73
```

Primes below 80 that are `2` or `≡ 1 (mod 4)`:

```
2, 5, 13, 17, 29, 37, 41, 53, 61, 73     (identical)
```

Primes below 80 dividing some `N² + N + 1`:

```
3, 7, 13, 19, 31, 37, 43, 61, 67, 73, 79
```

Primes below 80 that are `3` or `≡ 1 (mod 3)`:

```
3, 7, 13, 19, 31, 37, 43, 61, 67, 73, 79 (identical)
```

The two spectra coincide with the split primes of `ℚ(i)` and `ℚ(ζ₃)` — the
computational shadow of the proved equalities of sets.  (OEIS: the first list
is A002313 restricted to primes; the second is A002476 together with 3.)

## 6. Counterexample hunt

* Exhaustive scan of all `2 ≤ N ≤ 5000` and all six derived moduli looking for
  `gcd(N, M) > 1`: **0 hits**.
* Exhaustive scan of all primes `p < 200` for a mismatch between "`p` divides
  some `N²+1` (`N < 400`)" and "`p = 2` or `p ≡ 1 mod 4`": **0 hits**; same
  scan for `Φ₃` against "`p = 3` or `p ≡ 1 mod 3`": **0 hits**.

No counterexamples; every universal claim later formalised survived the search.

## 7. Sharpness: the exponential modulus does leak (→ `polynomial_hypothesis_necessary`)

`N ≤ 40` with `gcd(N, 2^N - 1) > 1`:

```
6, 12, 18, 20, 21, 24, 30, 36
```

and the semiprime case

```
gcd(253, 2^253 - 1) = 23,   253 = 11 · 23
```

(`ord₂₃(2) = 11 ∣ 253` but `ord₁₁(2) = 10 ∤ 253`).  This is the boundary of the
no-go: nothing similar can happen for a polynomial modulus, where the shared
primes are confined to the divisors of `f(0)`.
