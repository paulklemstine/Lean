# Computational Evidence — CRT-Split No-Go

All numbers below were produced by direct enumeration before formalisation, and every claim
that survived into the Lean files is *also* verified inside Lean (kernel evaluation or proof);
the tables here are exploratory context, not the verification itself.

## 1. Experiment CTST: reveal time versus √p

Pollard-rho map `x ↦ x² + 1 (mod N)`, seed `x₀ = 2`, `N = p·q` with random primes of the
stated bit size.  `(s,t)` is the *first* pair with `1 < gcd(x_t − x_s, N) < N`;
`r = t / √(min p q)`.

| bits | p | q | (s,t) | revealed factor | r | log₂ t |
|---|---|---|---|---|---|---|
| 9 | 509 | 257 | (0,9) | 509 | 0.56 | 3.17 |
| 10 | 1013 | 827 | (14,31) | 1013 | 1.08 | 4.95 |
| 11 | 1951 | 1627 | (33,40) | 1627 | 0.99 | 5.32 |
| 12 | 3923 | 3259 | (37,63) | 3923 | 1.10 | 5.98 |
| 13 | 7789 | 6073 | (21,81) | 6073 | 1.04 | 6.34 |
| 14 | 12437 | 15373 | (84,113) | 12437 | 1.01 | 6.82 |
| 15 | 30367 | 24517 | (15,146) | 30367 | 0.93 | 7.19 |
| 16 | 58943 | 62219 | (173,218) | 58943 | 0.90 | 7.77 |
| 17 | 97547 | 115067 | (303,422) | 97547 | 1.35 | 8.72 |
| 18 | 147011 | 177623 | (223,364) | 147011 | 0.95 | 8.51 |
| 19 | 325081 | 347587 | (423,523) | 325081 | 0.92 | 9.03 |

Mean of `r` per bit size over 4 samples: 0.64, 1.59, 1.12, 0.74, 0.98, 0.80, 1.24, 0.82, 1.08,
0.66, 0.71.  The ratio stays `O(1)` while `log₂ t` grows linearly in the bit size: the reveal
time tracks `√p = N^{1/4}`, i.e. it is *exponential* in `log N`.  In every single run the
revealed factor was exactly the prime whose reduced orbit closed first — the mechanism proved
in `reveal_iff_xor_closure`.

## 2. The demo modulus N = 341371 = 631 · 541

* First revealing pair: `(s,t) = (23,36)`, `gcd(x₃₆ − x₂₃, N) = 631`.
* First mod-631 closure: `(23,36)`.  First mod-541 closure: `(24,41)`.
* So the reveal is *exactly* the earlier (mod-631) closure, and `√631 ≈ 25.1`, `t = 36 ≈ 1.43√p`,
  while `log₂ N ≈ 18.4`.

Formalised: `crt_demo_gcd`, `crt_demo_xor`, `crt_demo_closure`, `crt_demo_first_reveal`
(the last one proves that *no* pair with `t ≤ 35` reveals anything).

## 3. Counterexample hunt: is the barrier universal?

No.  On the same modulus, `ord_631(2) = 45` and `ord_541(2) = 540`, and `45 ∣ 45` while
`540 ∤ 45`, so `gcd(2⁴⁵ − 1, 341371) = 631`: an `N`-independent Pollard `p−1` step reaches the
exponent 45 in 6 squarings.  Both `630 = 2·3²·5·7` and `540 = 2²·3³·5` are smooth.  This is
regime (b) and it is *fast*; the honest conclusion is that the no-go is regime-dependent, which
is why the Lean lower bounds are stated per regime (`successor_reveal_superpolynomial`,
`pollard_pm1_lower_bound`, `multiplicative_reveal_lower_bound`) and never as a universal
statement.  Formalised as `pollard_pm1_fast_demo`.

## 4. The birthday counting law

Number of maps `f : [n] → [n]` whose orbit prefix `x₀, …, x_T` from a fixed seed is
collision-free, by exhaustive enumeration:

| n | T | count | `(n−1)·…·(n−T) · n^(n−T)` |
|---|---|---|---|
| 3 | 1 | 18 | 18 |
| 3 | 2 | 6 | 6 |
| 4 | 1 | 192 | 192 |
| 4 | 2 | 96 | 96 |
| 4 | 3 | 24 | 24 |
| 5 | 1 | 2500 | 2500 |
| 5 | 2 | 1500 | 1500 |
| 5 | 3 | 600 | 600 |
| 5 | 4 | 120 | 120 |

The law is exact in every case.  It is now a theorem (`card_injPrefix`), proved by a fibration
argument, and the case `n = 4, T = 2` is additionally re-verified inside the Lean kernel by
enumerating all `4⁴ = 256` maps (`card_injPrefix_fin4_two`).

## 5. OEIS

The sequence of counts for `T = n − 1` (maps whose whole orbit is a simple path from the seed)
is `(n−1)!`: `1, 2, 6, 24, …` (A000142 shifted).  The two-parameter table above is the falling
factorial times a power, `A008279`-flavoured; no separate OEIS entry was needed for the proof.

## 6. Cycle 2: the birthday tail and the exact Pollard reveal time

**Tail bound, numerically.**  The exact collision-free fraction `∏_{i=1}^{T}(1 − i/n)` versus
the proved bound `exp(−T(T+1)/(2n))` of `card_injPrefix_le_exp` (numerical illustration,
computed outside Lean; the inequality itself is a theorem):

| n | T | exact product | exp(−T(T+1)/(2n)) |
|---|---|---|---|
| 101 | 10 | 0.5687 | 0.5801 |
| 101 | 20 | 0.1069 | 0.1250 |
| 631 | 25 | 0.5933 | 0.5975 |
| 631 | 50 | 0.1253 | 0.1326 |
| 1009 | 31 | 0.6085 | 0.6117 |
| 1009 | 62 | 0.1385 | 0.1443 |

The fraction crosses `1/2` just above `T = √n` and is below `1/4` by `T = 2√n`, which is
exactly the window proved in `birthday_window_zmod`.

**Pollard reveal time on the CTST modulus.**  `ord_631(2) = 45` and `ord_541(2) = 540`, so the
predicted reveal time for `N = 341371 = 631·541` with base `2` is `min(45, 540) = 45`.  This is
verified inside the Lean kernel (`pm1RevealTime_demo`, which uses the two order computations
`orderOf ((2 : ℤ) : ZMod 631) = 45` and `orderOf ((2 : ℤ) : ZMod 541) = 540`, both discharged
by kernel evaluation), not merely computed here.

## 7. Cycle 3: the average closure time, bracketed

The layer-cake identity `sum_closureTime_eq_sum_card` (Part IX) says that the average first
closure time equals `∑_{T<n} ∏_{i=1}^{T}(1 − i/n)` exactly.  The table below evaluates that
expression and compares it with the two proved bounds — `⌊√n⌋/2` from Part VIII and
`3(⌊√n⌋+1)` from Part IX — and with the classical Ramanujan `Q`-function asymptotic
`√(πn/2)` (the last column is an illustration, computed outside Lean; only the two bounds and
the identity are theorems).

| n | proved lower `⌊√n⌋/2` | exact average | proved upper `3(⌊√n⌋+1)` | `√(πn/2)` |
|---|---|---|---|---|
| 4 | 1.00 | 2.2188 | 9 | 2.5066 |
| 10 | 1.58 | 3.6602 | 12 | 3.9633 |
| 101 | 5.02 | 12.2724 | 33 | 12.5957 |
| 631 | 12.56 | 31.1537 | 78 | 31.4829 |
| 1009 | 15.88 | 39.4811 | 96 | 39.8112 |

Both bounds hold with room to spare in every row, and the exact average tracks `√n` — the
bracket `[√n/2, 3(√n+1)]` is what Part IX proves, and the residual gap in the constant is
recorded as Conjecture G in `FUTURE_DIRECTIONS.md`.  On the CTST modulus (`p = 631`) the exact
average first closure time is `31.15`, against the observed first mod-631 closure of the CTST
trajectory at `t = 36` — the same order of magnitude, as the theory predicts.

**Straight-line dichotomy, sanity checks (Part X).**  On `N = 341371 = 631·541`: `2` is a unit
(`gcd(2, N) = 1`), so an inversion node applied to it stays inside the polynomial world; `631`
is a non-unit and `gcd(631, N) = 631`, a nontrivial factor — this instance is verified in the
kernel as `nonunit_reveals_demo`.  The orbit of the CTST program `x ↦ x·x + 1` from seed `2` is
`2, 5, 26, 677, …`, verified in the kernel as `sleSq_orbit_demo` both as a straight-line
iteration and as the iteration of the polynomial it compiles to.
