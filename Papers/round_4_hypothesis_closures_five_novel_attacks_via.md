# Computational Evidence — Round-4 closures, tropical reading

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0), by brute
force over the full residue system, *before* the corresponding theorems were proved.
They are exploratory data, not proofs; the proofs are in `Catalog/Tropical/`.

## 1. The 2-Sylow torsion census `T(k) = #{x ∈ (ℤ/Nℤ)ˣ : x^(2^k) = 1}`

Brute-force count over `x ∈ [0, N)` with `gcd(x,N)=1`, compared with the predicted
value `2 ^ (min(k,a) + min(k,b))`, `a = v₂(p-1)`, `b = v₂(q-1)`.

| p | q | a | b | (T(0),pred) | (T(1),pred) | (T(2),pred) | (T(3),pred) | (T(4),pred) |
|---|---|---|---|---|---|---|---|---|
| 3 | 5 | 1 | 2 | (1,1) | (4,4) | (8,8) | (8,8) | (8,8) |
| 3 | 7 | 1 | 1 | (1,1) | (4,4) | (4,4) | (4,4) | (4,4) |
| 5 | 7 | 2 | 1 | (1,1) | (4,4) | (8,8) | (8,8) | (8,8) |
| 7 | 11 | 1 | 1 | (1,1) | (4,4) | (4,4) | (4,4) | (4,4) |
| 11 | 13 | 1 | 2 | (1,1) | (4,4) | (8,8) | (8,8) | (8,8) |
| 13 | 17 | 2 | 4 | (1,1) | (4,4) | (16,16) | (32,32) | (64,64) |
| 5 | 29 | 2 | 2 | (1,1) | (4,4) | (16,16) | (16,16) | (16,16) |
| 17 | 97 | 4 | 5 | (1,1) | (4,4) | (16,16) | (64,64) | (256,256) |

Agreement in every cell. Proved as `TropicalTorsionCensus.torsionCensus_eq`.

Observations that drove the formalisation:

* `T(1) = 4` for **every** odd semiprime (the classical "four square roots of 1"):
  level 1 is information-free. Proved in general as `census_level_one_constant`
  (`T(1) = 2^r` for squarefree odd `N` with `r` prime factors).
* `T` stabilises at `2^(a+b)` once `k ≥ max(a,b)`, and the *jump points* are `a` and
  `b` — i.e. the exponent `k ↦ min(k,a)+min(k,b)` is a concave piecewise-linear
  function with slopes `2, 1, 0`. That is exactly a tropical quadratic
  `(X ⊕ a) ⊙ (X ⊕ b)` with corner locus `{a,b}` (`isCensusCorner_iff`).
* **Collision hunt (the decisive negative datum).** `(p,q) = (3,7)` and `(7,11)` give
  identical rows: `N = 21` and `N = 77` have the *same census function*. Hence no
  functional of the census can output the smallest prime factor
  (`census_cannot_locate`).

Multi-prime spot checks (squarefree, `r = 3, 4`), same brute force:

| N | fingerprint (v₂(p−1)) | (T(0..3), predicted) |
|---|---|---|
| 105 = 3·5·7 | 1, 2, 1 | (1,1), (8,8), (16,16), (16,16) |
| 1155 = 3·5·7·11 | 1, 2, 1, 1 | (1,1), (16,16), (32,32), (32,32) |

Agreement; proved as `torsionCensus_prod` (degree-`r` tropical polynomial).

## 2. The partition function `Z = τ(N)` (HOLOG-MARGIN)

`(Nat.divisors N).card` for `N = 15, 21, 35, 77, 143, 221, 145, 1649`:
`[4, 4, 4, 4, 4, 4, 4, 4]` — constant, hence zero information
(`card_divisors_semiprime`, `tau_cannot_locate`).

## 3. The witness vector on `[1, √N]` (SPARSEREC)

`(Nat.divisors N).filter (d*d ≤ N)` for the same list:
`{1,3}, {1,3}, {1,5}, {1,7}, {1,11}, {1,13}, {1,5}, {1,17}` — always exactly the
2-spike `{1, p}` with `p` the smaller factor (`divisors_below_corner`).

## 4. Ground states of `E(a,b) = (N − ab)²` (MPS-PARENT / OPO-FAC)

Exhaustive count of `(a,b) ∈ [0,N]²` with `ab = N`, for
`N = 15, 21, 35, 77, 143, 221, 145`: `[4, 4, 4, 4, 4, 4, 4]` — a four-point delta in
an `N²`-point configuration space (`energyGroundSet_eq`, `energyGroundSet_ncard`).

## 5. Root-shuffling collision: the full torsion profile of 35 versus 39

Brute force over all `d ∈ [1, 25]` of `#{x ∈ [0,N) : gcd(x,N)=1, x^d ≡ 1}` for
`N = 35 = 5·7` (valuation pair `{4,6}`) and `N = 39 = 3·13` (pair `{2,12}`):
the list of mismatching `d` is **empty**. The common profile for `d = 1..13` is

`[1, 4, 3, 8, 1, 12, 1, 8, 3, 4, 1, 24, 1]`.

This collision is not accidental: at the prime `2` the tropical roots `{2,1}` have been
swapped between the two factors, and at `3` they agree. Proved in general as
`gcd_profile_eq_of_valuations` and instantiated as `torsionProfile_35_eq_39`.

## 6. OEIS

The census exponent sequence for fixed `(a,b)` is eventually constant and is a
tropical quadratic; the underlying sequence `k ↦ min(k,a)+min(k,b)` is piecewise
linear and not an interesting OEIS entry. The fingerprint sequence `v₂(p−1)` over
primes is OEIS A007814 composed with `p−1` (A007814 = 2-adic valuation, "ruler
sequence"); no new sequence was needed.
