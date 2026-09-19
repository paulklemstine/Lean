# Computational evidence for the three-strata plane

All numbers below were produced by direct enumeration before the Lean proofs were
written; each block names the theorem it was used to check. The Lean files are the
authority — these tables only record what motivated the statements. (Timing-style
figures from the originating report are *not* reproduced here; only arithmetic that
can be recomputed exactly is listed.)

## 1. Stratum A: `σ₁`, `τ`, and the scan window

`p q N τ(N) σ₁(N) 1+p+q+N ⌊√N⌋ {d ∣ N : d ≤ ⌊√N⌋}`

```
3   5      15  4     24      24    3   [1, 3]
3   7      21  4     32      32    4   [1, 3]
5   7      35  4     48      48    5   [1, 5]
11  13    143  4    168     168   11   [1, 11]
13  17    221  4    252     252   14   [1, 13]
101 103 10403  4  10608   10608  101   [1, 101]
97 1009 97873  4  98980   98980  312   [1, 97]
```

* `σ₁(N) = 1 + p + q + N` holds in every row → `ThreeStrata.sigmaOne_semiprime`.
* `τ(N) = 4` in every row → `ThreeStrata.numDivisors_semiprime`.
* the scan window contains exactly `{1, p}` → `ThreeStrata.divisors_le_sqrt`.
* row `(11,13)`: `⌊√143⌋ = 11 = p`, the twin-prime case where the `⌊√N⌋` bound is
  attained → `ThreeStrata.twinPrime_scanCost_eq_sqrt`.

## 2. Measured exponent of the definition-route scan

`mean over 40 random semiprimes of log₂⌊√N⌋ / log₂ N`:

```
prime bits  8: 0.4997
prime bits 12: 0.5000
prime bits 16: 0.5000
prime bits 20: 0.5000
prime bits 24: 0.5000
```

`α = 0.500` to three decimals, matching the two-sided bound proved in
`ThreeStrata.scan_exponent_half_sandwich` and the profile exponent
`ThreeStrata.scanProfile_exponent`.

## 3. Fermat's first stop

`steps` counts trial values of `a` strictly before the stop, starting at `⌈√N⌉`:

```
p=3     q=5      N=15     steps=0     stop a=4    (p+q)/2=4
p=3     q=101    N=303    steps=34    stop a=52   (p+q)/2=52
p=3     q=1009   N=3027   steps=450   stop a=506  (p+q)/2=506
p=11    q=13     N=143    steps=0     stop a=12   (p+q)/2=12
p=101   q=103    N=10403  steps=0     stop a=102  (p+q)/2=102
p=3     q=10007  N=30021  steps=4831  stop a=5005 (p+q)/2=5005
```

The stop is always at `a = (p+q)/2` and never earlier → this is exactly
`ThreeStrata.fermat_representation_dichotomy` plus
`ThreeStrata.fermat_no_early_stop`. The twin rows (`11·13`, `101·103`) stop
immediately while trial division needs `p` steps
(`fermat_instant_on_twin_semiprime`); the `p = 3` rows show the opposite
(`fermat_slow_on_unbalanced`: `q=10007` gives `4831 ≥ q/4 = 2501`).

## 4. The price of structure-blindness (pure-model ratio `√N / N^{1/4}`)

```
N=2^16: scan=256     N^{1/4}=16     ratio=16
N=2^20: scan=1024    N^{1/4}=32     ratio=32
N=2^24: scan=4096    N^{1/4}=64     ratio=64
N=2^28: scan=16384   N^{1/4}=128    ratio=128
N=2^36: scan=262144  N^{1/4}=512    ratio=512
```

The ratio is `N^{1/4}`, strictly increasing and unbounded, i.e. the price of
structure-blindness is not a constant overhead →
`ThreeStrata.blindnessPrice_eq`, `blindnessPrice_strictMono`,
`blindnessPrice_tendsto_atTop`. (Wall-clock ratios of an implemented scan against
an implemented `ρ` are larger and machine-dependent; only the asymptotic law is
claimed here and proved in Lean.)

## 5. Pollard `ρ` extraction

200 random Brent/Floyd `ρ` runs on 9-bit × 9-bit semiprimes:

```
190/193 completed runs returned a prime factor exactly;
the remaining 3 returned N itself — the collision-mod-N failure mode,
which is exactly the case excluded by the hypothesis of
ThreeStrata.pollard_extraction.
```

So the hypothesis `¬ N ∣ (xⱼ − xᵢ)` in `pollard_extraction` is neither vacuous
nor cosmetic: it is the only way the gcd can fail to be a factor, and when it
holds the gcd is provably `p`.

## 6. OEIS

No new integer sequence is introduced. The two sequences that appear are
standard: `τ(n)` = A000005 and `σ₁(n)` = A000203; the semiprime values used above
are the specialisations proved in `StratumA.lean`.

## 7. Counterexample hunt

* Exhaustive over all semiprimes `N = pq < 20000` (`5047` values, `p < q`): every
  one of the `7638` representations `a² = N + b²` with `⌈√N⌉ ≤ a ≤ (N+1)/2`
  satisfies `2a ∈ {p+q, N+1}`; **0 violations** of
  `fermat_representation_dichotomy`.
* Exhaustive over all pairs `p < q < 200` (`1035` semiprimes): **0** divisors of
  `N` in `(1, ⌊√N⌋]` other than `p`, as `divisors_le_sqrt` asserts.
* No search was made for a complete divisor-test set missing two primes below `B`:
  `missing_primes_card_le_one` proves no such set exists, so the search space is
  empty by theorem rather than by sampling.
