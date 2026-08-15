# Computational Evidence — Power-Sum GCD Factoring

All numbers below were computed inside Lean (`#eval`) on the exact definition
`F N k = powerSum N k = ∑_{a=1}^{N} a^k`. The starred rows were subsequently
**re-proved by kernel computation** (`decide`) in `Catalog/Geometry/PowerSumLabNotes.lean`,
so they are machine-verified, not merely evaluated.

## 1. Reveal at `k = p-1` and at `k = q-1` for the eight test semiprimes

| p, q | N = pq | gcd(F(p−1), N) | gcd(F(q−1), N) | λ(N) = lcm(p−1,q−1) |
|---|---|---|---|---|
| 3, 5   | 15   | 5  | 1  | 4    |
| 5, 7 * | 35   | 7  | 5  | 12   |
| 7, 11 *| 77   | 11 | 7  | 30   |
| 11, 13 *| 143 | 13 | 11 | 60   |
| 13, 17 | 221  | 17 | 13 | 48   |
| 17, 19 | 323  | 19 | 17 | 144  |
| 23, 29 | 667  | 29 | 23 | 308  |
| 89, 97 | 8633 | 97 | 89 | 1056 |

Observations.

* `gcd(F(p−1), N) = q` in **every** row, with no exception — consistent with
  `powerSum_factor_reveal` and, since `p < q` throughout, with the *unconditional*
  strengthening `powerSum_factor_reveal_of_lt`.
* Row 1 shows the necessity of the side condition in the dual direction:
  `gcd(F(q−1), 15) = 1` because `(p−1) = 2` divides `(q−1) = 4`. The master formula
  predicts exactly this.

## 2. The gcd sequence over a full Carmichael period

`N = 35 = 5·7`, λ = lcm(4,6) = 12 (verified by `decide` as `lab_period_table_35`):

```
k          :  1   2   3   4   5   6   7   8   9  10  11  12  | 13 ... 24
gcd(F k,35): 35  35  35   7  35   5  35   7  35  35  35   1  | repeats identically
```

`N = 15 = 3·5`, λ = lcm(2,4) = 4 (verified as `lab_period_table_15`):

```
k          :  1   2   3   4   5   6   7   8   9  10  11  12
gcd(F k,15): 15   5  15   1  15   5  15   1  15   5  15   1
```

Both tables confirm: the value `1` occurs **exactly** at the multiples of λ, the
sequence is λ-periodic, and no smaller period occurs. This is the content of
`gcd_powerSum_eq_one_iff`, `gcd_powerSum_periodic` and `gcd_powerSum_least_period`.

Counting revealing exponents (value ∉ {1, N}) in one period of `N = 35`: exactly
`k = 4, 6, 8`, i.e. 3 of 12 exponents — matching `λ/(p−1) + λ/(q−1) − 2 = 3 + 2 − 2 = 3`
(`card_revealing_exponents`, cross-checked computationally by `lab_density_35_computed`).

## 3. Counterexample hunt

* **Naive factor recovery `p + q = N − λ(N) + 1` is FALSE.** Smallest counterexamples
  found by search over semiprimes: `(p,q) = (5,13)`: `N = 65`, `λ = lcm(4,12) = 12`,
  `N − λ + 1 = 54 ≠ 18 = p+q`. Also `(3,7)`, `(5,17)`, `(7,13)`, … — every pair with
  `gcd(p−1,q−1) > 1`. The corrected identity `gcd(p−1,q−1)·λ + (p+q) = N + 1` holds in
  all tested cases and is proved (`carmichael_totient_recovery`); the counterexample is
  formalised as `lambda_recovery_counterexample`.
* **Bad Pollard bases.** For `N = 35`, `M = 4`, base `a = 6 = N−1`:
  `gcd(6^4 − 1, 35) = gcd(1295, 35) = 35` — total failure, while the power sum at the
  same exponent returns `7`. More generally `a = N−1` fails for *every* exponent
  (`pollard_universally_bad_base`), returning `N` for even `M` and `1` for odd `M`.
  No analogous "bad base" exists for the power sum, which has no base parameter.
* **Carmichael blind spot.** `N = 561 = 3·11·17`, `λ = lcm(2,10,16) = 80 ∣ 560`:
  `gcd(F(560), 561) = 1`. Searching squarefree composites `N ≤ 2000` for
  `gcd(F(N−1), N) = 1` returns exactly the Carmichael numbers `561, 1105, 1729`,
  in agreement with the proved equivalence `korselt_iff_coprime_powerSum`.

## 4. Non-squarefree moduli (cycle 3)

Values of `gcd(F k, N)` for prime-power moduli, computed with `#eval`:

```
N = 9  : k odd → 9,  k even → 3      (condition: (p−1)=2 divides k)
N = 25 : 4 ∣ k → 5,  else 25         (condition: (p−1)=4 divides k)
N = 45 : k ≡ 0 mod 4 → 3, k even → 15, k odd → 45
N = 8  : k odd → 8,  k even → 4      (p = 2 behaves differently)
```

Reducing `∑_{a<p^e} a^k` mod `p^e` for `p^e ∈ {9, 27, 25, 49, 125}` and `k ≤ 16` matches
`−p^{e−1}` when `(p−1) ∣ k` and `0` otherwise, in every case — the statement now proved as
`sum_range_pow_prime_pow`. Note the condition is `(p−1) ∣ k`, **not** `λ(p^e) ∣ k`:
for `p^e = 9` the value `−3` already occurs at `k = 2`, while `λ(9) = 6`. The prime `2` is
a genuine exception (see `N = 8` above) and is excluded from the theorem.

## 5. Sequence notes

The value sequence for a fixed semiprime is eventually periodic and takes only the
four values `{1, p, q, N}`; it is determined by the pair of Booleans
`((p−1) ∣ k, (q−1) ∣ k)`, so it is the "characteristic function" of a two-generator
divisibility pattern rather than a new arithmetic sequence; no OEIS entry is claimed.
The associated positions of `1` form the arithmetic progression `λ·ℕ`.

## 6. Cost

The first hit is at `k* = min(p−1, q−1)` (`first_hit_isLeast`), and
`(k*+1)^2 ≤ N` (`first_hit_sq_le`), so `k* < √N`. Each `F(k)` costs `Θ(N)`
modular operations, hence `Θ(N^{3/2})` overall for the scan — asymptotically worse
than trial division `Θ(√N)`. The method is therefore of structural, not algorithmic,
interest: it exhibits the same period-finding structure that Shor's algorithm
exploits quantumly.
