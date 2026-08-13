# Computational Evidence — Free-Witness Modular Threshold

All computations below were run inside Lean 4 (`#eval`, kernel-evaluated `Nat`
arithmetic).  They guided, and are now superseded by, the fully formal theorems
in `Catalog/Algebra/FreeWitnessTraceThreshold.lean`.  Nothing in the Lean file
depends on these numbers; they are exploratory.

## 1. The full witness factors `N` (sanity check)

For `N = 187 = 11 · 17`:

| quantity | value |
|---|---|
| `σ₂(187)` | `35380` |
| `(1+11²)(1+17²)` | `35380` |
| `√(σ₂ + 2N − N² − 1)` | `28 = 11 + 17` (the trace) |
| `√(28² − 4·187)` | `6 = 17 − 11` |

Formalised as `sigma_semiprime`, `trace_sq_identity`, `traceOf_eq`,
`recover_factors`.

## 2. The minimal working modulus `m*`

Definition used in the search: `m*(p,q) = least m ≥ 1 with m ∤ (p²−1)(q²−1)`
(by the formal theorem `determines_iff_not_dvd_gap`, this *is* the least modulus
for which `σ₂(N) mod m` pins down the factorisation).

Sample (`p, q, m*, 5(p+q)`):

```
(5,7,5,60)     (5,11,7,80)    (5,13,5,90)    (5,17,5,110)   (5,19,7,120)
(7,11,7,90)    (7,13,5,100)   (7,29,11,180)  (11,13,11,120) (11,17,7,140)
(11,43,13,270) (13,19,11,160) (13,29,11,210) (17,19,7,180)
```

Bulk statistics over **21 100 semiprimes** `p·q` with `p` among the first 40
primes `> 3` and `q` prime `< 4000`:

| statistic | value |
|---|---|
| max `m*` | **23** (at `p = 37`, `q = 1429`) |
| mean `m*` | ≈ 8.34 |
| histogram | `5 : 5885`, `7 : 7172`, `11 : 5658`, `13 : 1705`, `17 : 540`, `19 : 128`, `23 : 12` |
| `m* ≥ 5` | always (100 %) |
| `m*` vs `5(p+q)` | ratio `m*/(p+q) ≤ 0.31`, and `→ 0` as `q → ∞` |

**Counterexample hunt.**  The reported law `m* = 5 (p+q)` fails on *every* one of
the 21 100 samples; e.g. `p, q = 11, 17` gives `m* = 7` while `5(p+q) = 140`.
No sample had `m* > 23`, and `m*` shows no growth trend in `p + q`.
The observed values are exactly the primes `5, 7, 11, 13, 17, 19, 23` — never a
composite, which is explained by the formal fact that the failure set
`{m : m ∣ (p²−1)(q²−1)}` is downward closed under divisibility.

## 3. Order-1 witness (sum of divisors)

`m*₁(p,q) = least m with m ∤ (p−1)(q−1) = φ(N)`.  Over all prime pairs
`5 ≤ p < q < 200` the maximum of `m*₁` is **11**.  Formalised as
`gap_one_eq_totient` and `determines_one_iff_not_dvd_totient`: the order-1
obstruction is exactly Euler's totient — the RSA trapdoor.

## 4. What the data suggested, and what was proved

* `m*` is tiny and prime-valued → the failure set is `{m : m ∣ gap}`
  (`determines_iff_not_dvd_gap`, sharp iff).
* `m* ≥ 5` always for `p, q > 3` → `24 ∣ p² − 1` (`not_determines_of_lt_five`).
* `m* = 5` occurs for ~28 % of pairs → exactly when `p, q ≢ ±1 (mod 5)`
  (`five_determines_iff`, `least_modulus_eq_five`).
* `m*` stays bounded as `p, q → ∞` → proved unconditionally with Dirichlet
  (`constant_modulus_suffices_infinitely_often`: `m = 7` works for infinitely
  many semiprimes with arbitrarily large factors).
* `m*` is at most logarithmic in the gap → `exists_prime_determines`,
  `exists_small_prime_determines` (a counting bound via `∏_{r∈S} r ∣ gap`).

No OEIS entry was matched for the `m*` sequence; it is a two-parameter family
determined by the divisibility structure of `(p²−1)(q²−1)` rather than a single
integer sequence.
