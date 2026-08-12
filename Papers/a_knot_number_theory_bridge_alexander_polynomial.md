# Computational Evidence — Alexander polynomial of `T(2,N)` and the divisors of `N`

All data below was produced with exact integer polynomial arithmetic (pure Python,
no CAS): cyclotomic polynomials are computed recursively from
`X^n - 1 = ∏_{d ∣ n} Φ_d`, and all comparisons are exact coefficient-vector
comparisons. Everything reported here is *also* formally proved in
`Catalog/Bridges/AlexanderKnotNumberBridge.lean` and
`Catalog/Bridges/AlexanderKnotNumberBridgeII.lean`; the table is exploratory
support, not the certificate.

## 1. `A_N = ∏_{d ∣ N, d > 1} Φ_{2d}` — exact coefficient check

`A_N(X) = 1 - X + X² - ⋯ + X^{N-1}`, `τ(N)` = number of divisors.

| N | #factors = τ(N)−1 | factor degrees {φ(d) : d∣N, d>1} | A_N = ∏Φ_{2d}? | A_N(−1) | A_N(1) |
|---|---|---|---|---|---|
| 3 | 1 | [2] | ✓ | 3 | 1 |
| 5 | 1 | [4] | ✓ | 5 | 1 |
| 7 | 1 | [6] | ✓ | 7 | 1 |
| 9 | 2 | [2, 6] | ✓ | 9 | 1 |
| 15 | 3 | [2, 4, 8] | ✓ | 15 | 1 |
| 21 | 3 | [2, 6, 12] | ✓ | 21 | 1 |
| 25 | 2 | [4, 20] | ✓ | 25 | 1 |
| 27 | 3 | [2, 6, 18] | ✓ | 27 | 1 |
| 33 | 3 | [2, 10, 20] | ✓ | 33 | 1 |
| 35 | 3 | [4, 6, 24] | ✓ | 35 | 1 |
| 45 | 5 | [2, 4, 6, 8, 24] | ✓ | 45 | 1 |
| 49 | 2 | [6, 42] | ✓ | 49 | 1 |
| 55 | 3 | [4, 10, 40] | ✓ | 55 | 1 |
| 63 | 5 | [2, 6, 6, 12, 36] | ✓ | 63 | 1 |
| 77 | 3 | [6, 10, 60] | ✓ | 77 | 1 |
| 91 | 3 | [6, 12, 72] | ✓ | 91 | 1 |
| 105 | 7 | [2, 4, 6, 8, 12, 24, 48] | ✓ | 105 | 1 |
| 143 | 3 | [10, 12, 120] | ✓ | 143 | 1 |
| 187 | 3 | [10, 16, 160] | ✓ | 187 | 1 |
| 209 | 3 | [10, 18, 180] | ✓ | 209 | 1 |
| 221 | 3 | [12, 16, 192] | ✓ | 221 | 1 |
| 247 | 3 | [12, 18, 216] | ✓ | 247 | 1 |

Observations that became theorems:

* the identity holds in every case (proved: `alexander_eq_prod_cyclotomic`);
* the number of irreducible factors is exactly `τ(N) − 1` — in particular it is `1`
  iff `N` is prime (proved: `alexander_irreducible_iff_prime`,
  `alexander_num_irreducible_factors`);
* `A_N(−1) = N` always (proved: `knot_determinant`) and `A_N(1) = 1`
  (proved: `alexander_eval_one`);
* the degrees sum to `N − 1 = deg A_N` (proved: `sum_totient_erase_one`).

**Counterexample hunt / caveat found by the data.** The degree multiset is *not*
always multiplicity-free: `N = 63 = 3²·7` gives `[2, 6, 6, 12, 36]`
(`φ(9) = φ(7) = 6`). So "the multiset of factor degrees" does not literally
biject with the divisors of `N`; only for squarefree semiprimes is the reading
`{p−1, q−1, (p−1)(q−1)}` unambiguous. This is why the semiprime theorems carry
the hypotheses `p ≠ q`, both odd primes.

## 2. Recovery of `p, q` from the degree data

`s = N + 1 − φ(N)` with `φ(N) = (p−1)(q−1)` the largest factor degree,
`p = (s − √(s²−4N))/2`, `q = (s + √(s²−4N))/2`.

| N | factor degrees | φ(N) | s | recovered | correct |
|---|---|---|---|---|---|
| 15 | [2, 4, 8] | 8 | 8 | (3,5) | ✓ |
| 21 | [2, 6, 12] | 12 | 10 | (3,7) | ✓ |
| 35 | [4, 6, 24] | 24 | 12 | (5,7) | ✓ |
| 77 | [6, 10, 60] | 60 | 18 | (7,11) | ✓ |
| 143 | [10, 12, 120] | 120 | 24 | (11,13) | ✓ |
| 221 | [12, 16, 192] | 192 | 30 | (13,17) | ✓ |
| 667 | [22, 28, 616] | 616 | 52 | (23,29) | ✓ |
| 10403 | [100, 102, 10200] | 10200 | 204 | (101,103) | ✓ |

Proved as `recover_factors_from_degrees` (with `Nat.sqrt`, i.e. exactly the
integer algorithm above).

## 3. Local determinants `Φ_{2d}(−1)`

| N | (d, Φ_{2d}(−1)) for d ∣ N, d > 1 |
|---|---|
| 9 | (3,3), (9,3) |
| 15 | (3,3), (5,5), (15,1) |
| 45 | (3,3), (5,5), (9,3), (15,1), (45,1) |
| 63 | (3,3), (7,7), (9,3), (21,1), (63,1) |
| 105 | (3,3), (5,5), (7,7), (15,1), (21,1), (35,1), (105,1) |
| 143 | (11,11), (13,13), (143,1) |

So the knot determinant `N = A_N(−1)` factors as `∏_{d ∣ N, d>1} Φ_{2d}(−1)`, where
the prime-power divisors contribute their prime and all other divisors contribute `1`.
The two special cases needed for the semiprime bridge are proved *from the knot side*:
`cyclotomic_two_mul_prime_eval_neg_one` (`Φ_{2p}(−1) = p`) and
`cyclotomic_two_mul_semiprime_eval_neg_one` (`Φ_{2pq}(−1) = 1`).

## 4. OEIS

The degree sequence of `A_N` is `N − 1` (trivial). The interesting sequence is the
number of irreducible factors of `A_N` for odd `N`, i.e. `τ(N) − 1`
(number of divisors minus one, A000005 shifted); the multiset of factor degrees is
`{φ(d) : d ∣ N, d > 1}` with `∑ = N − 1`, the classical Gauss identity A000010/A000005.
No new sequence appears to be involved.

## 5. Second-round evidence (cycles VI–IX)

### 5.1 Degree-multiset collisions (input to `C3`)

Exhaustive sieve over all **odd `3 ≤ N < 60000`** of the multiset
`D_N = {φ(d) : d ∣ N, d > 1}`:

| range searched | distinct multisets | collisions found |
|---|---|---|
| odd `N < 60000` | 29999 | **0** |

The absence of collisions is not an accident of the range: `∑_{d ∣ N} φ(d) = N` forces
`sum(D_N) = N − 1`, so `N = sum(D_N) + 1` is recovered by one addition. This turned the
conjectured "not injective in general" half of `C3` into a *refuted* prediction and is now
the theorem `degree_multiset_injective` (`…BridgeIX.lean`), valid for every `N > 0`.

### 5.2 gcd / lcm data (input to `C4`)

| M | N | deg A_M | deg A_N | deg gcd(A_M,A_N) | deg A_{gcd(M,N)} | deg lcm(A_M,A_N) | deg A_{lcm(M,N)} |
|---|---|---|---|---|---|---|---|
| 3 | 5 | 2 | 4 | 0 | 0 | 6 | 14 |
| 3 | 9 | 2 | 8 | 2 | 2 | 8 | 8 |
| 9 | 15 | 8 | 14 | 2 | 2 | 20 | 44 |
| 15 | 21 | 14 | 20 | 2 | 2 | 32 | 104 |

The gcd column matches `A_{gcd}` in every row (proved: `alexander_gcd`), while the lcm
column disagrees as soon as `lcm(M,N)` has a divisor dividing neither `M` nor `N`
(proved for `M=3, N=5`: `alexander_lcm_not_associated`).

### 5.3 Local determinants beyond prime powers (input to `C2`)

`Φ_{2d}(−1)` for `d = 27, 81` gives `3, 3`; for `d = 45, 63, 105` gives `1, 1, 1`; matching
the now-proved dichotomy `Φ_{2d}(−1) = p` for `d = p^k` and `= 1` otherwise
(`cyclotomic_two_mul_prime_pow_eval_neg_one`,
`cyclotomic_two_mul_eval_neg_one_of_not_isPrimePow`), which in turn follows from the
identity `Φ_{2n}(−1) = Φ_n(1)` for odd `n` (`cyclotomic_two_mul_eval_neg_one`).


## 6. Third-round data (cycles XI–XIII)

### 6.1 Join defect degrees (input to `D1`, now proved)

Computed exactly in Lean (`Nat.totient` sums over `Finset` divisor sets), for
`joinDeg(M,N) = ∑_{d ∈ (div M ∪ div N)\{1}} φ(d)` and
`defect(M,N) = ∑_{d ∈ div lcm(M,N)\{1}, d ∤ M, d ∤ N} φ(d)`:

| M | N | deg lcm(A_M,A_N) | defect | deg A_{lcm(M,N)} = lcm−1 |
|---|---|---|---|---|
| 3 | 5 | 6 | 8 | 14 |
| 3 | 9 | 8 | 0 | 8 |
| 9 | 15 | 20 | 24 | 44 |
| 15 | 21 | 32 | 72 | 104 |
| 5 | 7 | 10 | 24 | 34 |
| 7 | 11 | 16 | 60 | 76 |
| 9 | 25 | 32 | 192 | 224 |

Every row satisfies `joinDeg + defect = lcm(M,N) − 1`, and the defect vanishes exactly on the
comparable pair `(3,9)` — the data that became
`alexander_lcm_natDegree_add_defect` and `joinDefect_isUnit_iff` (`…BridgeXI.lean`).

### 6.2 `T(r,N)` degrees (input to `D4`, now proved)

`tdeg(r,N) = ∑_{d ∣ rN, d ∤ r, d ∤ N} φ(d)` against the genus prediction `(r−1)(N−1)`:

| (r,N) | (2,3) | (2,9) | (3,5) | (3,7) | (5,7) | (4,9) | (2,15) |
|---|---|---|---|---|---|---|---|
| tdeg | 2 | 8 | 8 | 12 | 24 | 24 | 14 |
| (r−1)(N−1) | 2 | 8 | 8 | 12 | 24 | 24 | 14 |

Agreement in every case; now the theorem `torusAlexander_natDegree` (`…BridgeXII.lean`).
