# Computational evidence: denominators of `x(nP)` on Mordell curves `E_N : y² = x³ + N`

**Status of the numbers below.** Everything in §1 and §2 is *machine-verified in Lean* in
`Catalog/Bridges/MordellDenominatorBadPrimes.lean`. The survey in §3 is *exploratory* (exact
rational arithmetic, but factorisation by trial division up to `10⁵`, so very large prime factors
of the `n = 3` denominators are only partially resolved). Exploratory numbers are labelled as such
and are **not** claimed as verified.

## 1. The `N = 55` counterexample (Lean-verified)

`N = 55 = 5 · 11`, `P = (9, 28)`, `28² = 784 = 729 + 55 = 9³ + 55`.

```
x(2P) = (9⁴ - 8·55·9) / (4·(9³ + 55)) = (6561 - 3960) / 3136 = 2601 / 3136
2601 = 3² · 17²      3136 = 2⁶ · 7²
```

* `7 ∣ 3136` — the prime `7` occurs in the denominator.
* `Δ(E₅₅) = -432 · 55² = -1306800` and `7 ∤ Δ`, so `7` is a prime of **good** reduction.
* `7 ∉ {2, 3, 5, 11}`.

Lean: `den_dblX_55`, `good_prime_seven_divides_den`, `onlyBadPrimes_false`.

## 2. A second semiprime counterexample, from twin primes (Lean-verified)

`25m² - 1 = (5m - 1)(5m + 1)` is a semiprime exactly when `5m ∓ 1` is a twin prime pair.
For `m = 6`: `N = 899 = 29 · 31`, `P = (1, 30)`, `30² = 900 = 1³ + 899`.

```
x(2P) = (1 - 8·899) / (4·900) = -7191/3600 = -799/400,   400 = 2⁴ · 5²
```

`5 ∣ 400`, `5 ∤ 6·899`, `5 ∉ {2, 3, 29, 31}`.  Lean: `counterexample_899`.

The same construction with `m = 12` gives `N = 3599 = 59 · 61`, `P = (1, 60)`; and in general
`x = 1`, `y = ℓm`, `N = ℓ²m² - 1` gives a failure at *any* prime `ℓ ≥ 5`
(Lean: `every_prime_ge_five_is_extraneous`, `family_mem_badSet`, `badSet_infinite`).

## 2b. The same curve at `n = 3` (Lean-verified)

Still `N = 55`, `P = (9, 28)`.  The triplication formula `x(3P) = x - ψ₂ψ₄/ψ₃²` with
`ψ₃ = 3x⁴ + 12Nx` and `ψ₂ψ₄ = 8y²(x⁶ + 20Nx³ - 8N²)` gives

```
ψ₃(P) = 3·9⁴ + 12·55·9 = 19683 + 5940 = 25623 = 3³ · 13 · 73
x(3P)  = -2302089191 / 656538129,   656538129 = 25623² = 3⁶ · 13² · 73²
```

* `13 ∣ den x(3P)` and `73 ∣ den x(3P)`, while `13, 73 ∤ Δ = -432·55²`: both are primes of **good**
  reduction, and neither lies in `{2,3,5,11}`.
* `7 ∤ den x(3P)` and `13, 73 ∤ den x(2P)`: the extraneous primes at level `2` and level `3` are
  *disjoint* for this point.

The value `-2302089191/656538129` was independently reproduced by iterating the affine group law
(`2P = (2601/3136, 1309141/175616)`, then the secant through `P` and `2P`), and the agreement of
the two computations is itself a theorem here (`triX_eq_chord_addX`, `xCoord_add_add_self`).

Lean: `den_triX_55`, `tri_counterexample_55`, `extraneous_primes_shift_55`,
`onlyBadPrimesTri_false`.

## 2c. The doubling tower for the same point (Lean-verified)

Still `N = 55`, `P = (9, 28)`.  Iterating the duplication formula (`dblIter`):

```
x(2P) = 2601/3136,                                3136                = 2⁶ · 7²
x(4P) = -35249882584054239/21498536380459264,     21498536380459264   = 2⁸ · 7² · 827² · 1583²
```

* The extraneous good-reduction prime `7` of level `2` is still there at level `4`, and with the
  **same exponent** `2` — an instance of the proved persistence theorem `padicValRat_dblX`
  (`v_ℓ(x(2Q)) = v_ℓ(x(Q))` for every odd prime `ℓ` with `v_ℓ(x(Q)) < 0`).
* The bad prime `2` behaves oppositely: its exponent goes `6 → 8`, i.e. `+2` per doubling, which is
  exactly the proved growth law `padicValNat_den_dblIter_two`.
* Two new good-reduction primes `827` and `1583` appear (both prime, both `∤ 6·55`), refuting the
  tower form of the conjecture at level `k = 2`.
* The exponent `2` of `7` is exactly `2 v_7(y) = 2 · v_7(28) = 2`, matching the proved formula
  `padicValNat_den_dblX` / `padicValNat_den_dblIter_eq`.

Lean: `dblIter_two_55`, `den_dblIter_two_55`, `level_four_55`, `seven_exponent_stable_55`,
`dichotomy_55`, `padicValNat_den_dblIter_eq`, `onlyBadPrimesTower_false`.

## 3. Survey over 30 semiprimes (exploratory)

For each semiprime `N = p·q` with `p, q ≤ 47` we took the integral point `(x, y)` with the
smallest `x ≥ -20`, and collected the primes occurring in the denominators of `x(2P)` and `x(3P)`
(trial division up to `10⁵`; a large unresolved cofactor is simply omitted, which can only *lower*
the extraneous-prime counts).

| `N` | `P` | `den x(2P)` | primes found in `den x(2P)`, `den x(3P)` | extraneous (∉ {2,3,p,q}) |
|---|---|---|---|---|
| 15 = 3·5 | (1,4) | 64 | [2, 3, 61] | [61] |
| 33 = 3·11 | (-2,5) | 25 | [3, 5, 31] | [5, 31] |
| 57 = 3·19 | (-2,7) | 49 | [3, 5, 7, 11] | [5, 7, 11] |
| 129 = 3·43 | (-5,2) | 16 | [2, 3, 5, 17, 23] | [5, 17, 23] |
| 141 = 3·47 | (-5,4) | 64 | [2, 3, 5, 439] | [5, 439] |
| 35 = 5·7 | (1,6) | 16 | [2, 47] | [47] |
| 55 = 5·11 | (9,28) | 3136 | [2, 3, 7, 13, 73] | [7, 13, 73] |
| 65 = 5·13 | (-4,1) | 1 | [2, 3, 7] | [7] |
| 145 = 5·29 | (-4,9) | 9 | [2, 3, 43] | [43] |
| 185 = 5·37 | (-4,11) | 121 | [2, 3, 11, 13] | [11, 13] |
| 91 = 7·13 | (-3,8) | 256 | [2, 3, 337] | [337] |
| 119 = 7·17 | (53,386) | 595984 | [2, 3, 53, 193, 233, 641] | [53, 193, 233, 641] |
| 161 = 7·23 | (-5,6) | 16 | [2, 5, 173] | [5, 173] |
| 217 = 7·31 | (-6,1) | 1 | [3, 163] | [163] |
| 329 = 7·47 | (8,29) | 841 | [2, 3, 29, 457] | [29, 457] |
| 143 = 11·13 | (1,12) | 64 | [2, 191] | [191] |
| 407 = 11·37 | (-7,8) | 256 | [2, 3, 5, 7, 257] | [5, 7, 257] |
| 451 = 11·41 | (5,24) | 256 | [2, 5, 643] | [5, 643] |
| 377 = 13·29 | (4,21) | 49 | [2, 7, 131] | [7, 131] |
| 481 = 13·37 | (12,47) | 2209 | [2, 3, 11, 47, 83] | [11, 47, 83] |
| 323 = 17·19 | (1,18) | 144 | [2, 3, 431] | [431] |
| 551 = 19·29 | (5,26) | 2704 | [2, 3, 5, 13, 17, 137] | [5, 13, 17, 137] |
| 703 = 19·37 | (-3,26) | 2704 | [2, 3, 5, 13, 557] | [5, 13, 557] |
| 817 = 19·43 | (24,121) | 14641 | [2, 3, 11, 4273] | [11, 4273] |
| 667 = 23·29 | (-7,18) | 144 | [2, 3, 5, 7, 31] | [5, 7, 31] |
| 713 = 23·31 | (8,35) | 1225 | [2, 3, 5, 7, 29] | [5, 7, 29] |
| 1081 = 23·47 | (-10,9) | 9 | [3, 5, 277] | [5, 277] |
| 899 = 29·31 | (1,30) | 400 | [2, 5, 11, 109] | [5, 11, 109] |
| 1457 = 31·47 | (4,39) | 169 | [2, 13, 491] | [13, 491] |
| 1763 = 41·43 | (1,42) | 784 | [2, 7, 2351] | [7, 2351] |

Aggregate (exploratory, 30 semiprimes, `n ≤ 3`):

* `p` appears in some denominator: **5/30 = 16.7 %**
* `q` appears in some denominator: **0/30 = 0.0 %**
* only `{2, 3, p, q}` appear: **0/30 = 0.0 %**

So the "only bad primes" pattern holds in **no** sampled case, and in every sampled case at least
one good-reduction prime appears. (The mission brief quotes 54.5 % / 0 % / 0 % over a different
sample of 11 semiprimes; the qualitative conclusions — `q` never appears, the conjecture never
holds — agree, the `p`-frequency is sample-dependent and carries no verified status.)

## 4. What the data says structurally

The extraneous primes are exactly the primes `ℓ ∤ 6N` dividing `y` (for `n = 2`); e.g.
`55: y = 28 = 2²·7 → 7`; `899: y = 30 = 2·3·5 → 5`; `377: y = 21 = 3·7 → 7`;
`1763: y = 42 = 2·3·7 → 7`. This is the content of the mechanism theorem
`prime_dvd_den_dblX_iff`, proved in Lean: for `ℓ ∤ 6N`,

```
ℓ ∣ den x(2P)  ⟺  ℓ ∣ y  ⟺  P̄ + P̄ = O in E_N(𝔽_ℓ).
```

No OEIS sequence is attached: the objects here (denominators of `x(2P)` as `N` varies over
semiprimes with a chosen point) depend on the choice of point and do not form a canonical
sequence.
