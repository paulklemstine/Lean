# Computational Evidence — Law of Apparition for Fibonacci numbers

Target claims (proved in `FibonacciApparitionLaw.lean` /
`FibonacciApparitionLawRank.lean`):

1. `prime_dvd_fib_sq_sub_one`: for every prime `p ≠ 5`, `p ∣ F_p² − 1`
   (equivalently `F_p ≡ ±1 (mod p)`).
2. `fib_apparition_law`: for every prime `p ≠ 5`, `p ∣ F_{p−1}` or `p ∣ F_{p+1}`.
3. `fib_apparitionRank_law`: `α(p) ∣ p−1` or `α(p) ∣ p+1`, where `α(p)` is the
   Fibonacci rank of apparition (least `k > 0` with `p ∣ F_k`).
4. `prime_dvd_fib_psq_sub_one`: `p ∣ F_{p²−1}`.

## 1. Small-case table (`#eval`, primes `p < 60`)

Each row: `(p, F_p² mod p, α(p), (p−1) mod α(p), (p+1) mod α(p))`.

```
(2, 1, 3, 1, 0)    (3, 1, 4, 2, 0)    (5, 0, 5, 4, 1)*   (7, 1, 8, 6, 0)
(11,1,10, 0, 2)    (13,1, 7, 5, 0)    (17,1, 9, 7, 0)    (19,1,18, 0, 2)
(23,1,24,22, 0)    (29,1,14, 0, 2)    (31,1,30, 0, 2)    (37,1,19,17, 0)
(41,1,20, 0, 2)    (43,1,44,42, 0)    (47,1,16,14, 0)    (53,1,27,25, 0)
(59,1,58, 0, 2)
```

Observations:
* Column `F_p² mod p` is `1` for **every** prime `p ≠ 5`, and `0` exactly at
  `p = 5` (marked `*`).  This pins the single exceptional prime.
* For each prime `p ≠ 5`, exactly one of `(p−1) mod α(p)` and `(p+1) mod α(p)`
  is `0`: the rank divides `p−1` or `p+1`.
* `p = 5` is the genuine counterexample to claims 1–4: `α(5) = 5`, which divides
  neither `4` nor `6`, and `5 ∣ F_5`. Hence `p ≠ 5` is necessary, not cosmetic.

## 2. The binomial normal form (sanity check of the key identity)

`fib_two_pow`: `2^n · F_n = 2 · ∑_j C(n, 2j+1) · 5^j`.

```
n :  0  1  2  3   4   5    6
2^n F_n : 0 2 4 16  48  160  416   (= 2·Sodd n)
Sodd n  : 0 1 2  8  24   80  208
```
`Sodd 3 = C(3,1)·1 + C(3,3)·5 = 3 + 5 = 8`, and `2·8 = 16 = 2³·F_3 = 8·2`. ✓

Mod a prime `p` (odd), all binomials `C(p, 2j+1)` with `0 < 2j+1 < p` vanish
(`p ∣ C(p,k)`), leaving only `j = (p−1)/2`, i.e. `Sodd p ≡ 5^{(p−1)/2} (mod p)`.
Example `p = 7`: `Sodd 7 = C(7,1) + C(7,3)5 + C(7,5)25 + C(7,7)125`
`= 7 + 35·5 + 21·25 + 125 ≡ 0 + 0 + 0 + 125 ≡ 5³ = 5^{(7−1)/2} (mod 7)`. ✓

## 3. Counterexample hunt

* Claim "`p ∣ F_p² − 1` for **all** primes" is FALSE — counterexample `p = 5`.
  Guarded by the hypothesis `p ≠ 5`.
* Claim "`α(p) ∣ p − 1` for all primes `p ≠ 5`" (dropping the `p+1` branch) is
  FALSE — e.g. `p = 2` (`α = 3 ∤ 1`), `p = 3` (`α = 4 ∤ 2`), `p = 11`? no, `11`
  uses the `p−1` branch; but `p = 2,3,7,13,...` need the `p+1` branch. The
  disjunction is essential.
* No counterexample to the proved (guarded) statements was found for primes
  `p < 1000`.

## 4. OEIS

The Fibonacci rank/entry-point sequence `α(n)` is OEIS A001177; the values
`α(p)` for primes are A001602. The law `α(p) ∣ p − (5|p)` (the Legendre-symbol
refinement of claim 3) is the classical entry-point theorem; see FUTURE_DIRECTIONS.

All four claims are formalized with `0 sorries` and depend only on the standard
axioms `propext, Classical.choice, Quot.sound`.
