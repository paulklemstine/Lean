# Computational evidence — Two-Tree Closure (Berggren / Price)

All numbers below were produced by direct enumeration before the Lean development;
each block names the theorem that now proves the corresponding statement.
The Lean files are the authoritative artifacts: everything asserted as a *law* here
is a `sorry`-free theorem in `Catalog/Bridges/TwoTreeClosure/`.

## 1. The Price two-adic law (`PriceTwoAdicLaw.lean`)

Exhaustive check over all odd `p, q < 200` (10 000 pairs), with `v₂` the two-adic
valuation of the factor sum:

| statement | verified |
|---|---|
| `v₂(p+q) = 1 ⟺ pq ≡ 1 (mod 4)` | true on all 10 000 pairs |
| `v₂(p+q) = 2 ⟺ pq ≡ 3 (mod 8)` | true on all 10 000 pairs |
| `v₂(p+q) ≥ 3 ⟺ pq ≡ 7 (mod 8)` | true on all 10 000 pairs |

Proved as `v2_one_iff_mod_four`, `v2_two_iff_mod_eight_three`,
`mod_eight_seven_iff_eight_dvd`.

**Cap / death at position 2.**  The valuation is pinned only up to `3`; past that it
is not a function of `N` at all.  Sample of the family `N = 9m`, `m ≡ 7 (mod 16)`:

| `N` | factorisation `9·m` | `v₂(9+m)` | factorisation `3·(3m)` | `v₂(3+3m)` |
|---|---|---|---|---|
| 63 | 9·7 | 4 | 3·21 | 3 |
| 207 | 9·23 | 5 | 3·69 | 3 |
| 351 | 9·39 | 4 | 3·117 | 3 |
| 495 | 9·55 | 6 | 3·165 | 3 |

Proved as `priceLetter_two_not_function_of_N` (letters 0 and 1 agree, letter 2 differs).

## 2. Residue dials are blind (`TreeCore.lean`)

For the smooth Gauss-sum modulus `M = 720720` and `n = 2M = 1441440`, the three nodes

`(n+1, n)`, `(2n+1, n)`, `(3n+1, n)`

carry the letters `A`, `B`, `C` respectively, and all three hypotenuses reduce to
`1 mod 720720`.  A residue dial therefore sees one value where the tree has all
three branches.  Proved as `letterOf_blind_of_residue`, `residue_dial_letterBlind`,
`gaussDial_letterBlind`, and (for genuine Gauss sums) `gaussProbe_letterBlind`,
`gaussBattery_letterBlind` in `GaussDial.lean`.

## 3. Magnitude mirrors are blind (`TreeCore.lean`, `FactorOracle.lean`)

Collision family `k = 10t`: the nodes `(2k−1, k+2)` and `(2k+1, k−2)`.

| t | node 1 | letter | node 2 | letter | common hypotenuse |
|---|---|---|---|---|---|
| 1 | (19, 12) | A | (21, 8) | B | 505 = 5·101 |
| 2 | (39, 22) | A | (41, 18) | B | 2005 = 5·401 |
| 3 | (59, 32) | A | (61, 28) | B | 4505 = 5·17·53 |
| 4 | (79, 42) | A | (81, 38) | B | 8005 = 5·1601 |
| 5 | (99, 52) | A | (101, 48) | B | 12505 = 5·41·61 |

All pairs are coprime and of opposite parity (checked), i.e. genuine tree nodes.
Proved as `letterOf_blind_of_magnitude`, `magnitude_probe_letterBlind`; the
semiprimality of the `t = 1` witness is `magnitude_witness_semiprime`.
The collision is exactly the Brahmagupta–Fibonacci ambiguity of the factorisation
`5 · (k² + 1)` (`factor_oracle_family`).

## 4. Ascent economics (`AscentEconomics.lean`)

Restart energy `E(h, a) = h · a^(−h)` at height `h = 30`:

| a | `E(30, a)` | within a 3000-visit budget? |
|---|---|---|
| 0.80 | ≈ 2.42 · 10⁴ | no |
| 0.85 | ≈ 3.93 · 10³ | no |
| 0.86 | ≈ 2.77 · 10³ | yes |
| 0.90 | ≈ 7.08 · 10² | yes |

Exact rational check: `100 · 17³⁰ < 20³⁰` (budget fails at 0.85) and
`100 · 43³⁰ ≥ 50³⁰` (budget met at 0.86).  Proved as `accuracy_085_over_budget`,
`accuracy_086_within_budget`, `critical_accuracy_bracket`.  The exhaustive
alternative at the same depth costs `(3³¹ − 1)/2 > 10¹⁴` visits
(`exhaustive_cost_astronomical`, together with `card_desc`/`sum_card_desc`).

## 5. Ascent words and depth (`AscentWord.lean`)

Breadth-first descent from the root `(2,1)`, first three levels:

| word | node | hypotenuse |
|---|---|---|
| (empty) | (2,1) | 5 |
| A | (3,2) | 13 |
| B | (5,2) | 29 |
| C | (4,1) | 17 |
| AA | (4,3) | 25 |
| AB | (8,3) | 73 |
| AC | (7,2) | 53 |

All `3^h` words of length `h` give distinct nodes (`card_desc`, `follow_injective`).
The `A`-spine `A^k` lands on `(k+2, k+1)` with hypotenuse `2k² + 6k + 5`
(`spine_depth_sqrt`): depth grows like the square root of the hypotenuse, while the
bracket `2 + L ≤ m ≤ 2·3^L` (`depth_bracket`) shows the other branches can be
exponentially faster.

## 6. No OEIS hit sought

The objects here are two-parameter node families rather than a single integer
sequence, so no OEIS lookup was applicable.

## 7. Second cycle: two refutation families

### 7.1 Sophie Germain same-letter collisions (`RepresentationOrbit.lean`)

Primitive representations `N = m² + n²` (`m > n ≥ 1`, coprime, opposite parity) of
`N = u⁴ + 4` for `u = 2s + 7`, with the ascent letter of each:

| `s` | `N` | primitive representations `(m,n)` | letters |
|---|---|---|---|
| 0 | 2405 | (38,31), (46,17), (47,14), (49,2) | A, B, **C**, **C** |
| 1 | 6565 | (66,47), (74,33), (79,18), (81,2) | A, B, **C**, **C** |
| 2 | 14645 | (89,82), (98,71), (119,22), (121,2) | A, A, **C**, **C** |
| 3 | 28565 | (121,118), (134,103), (167,26), (169,2) | A, A, **C**, **C** |
| 4 | 50629 | (223,30), (225,2) | **C**, **C** |
| 5 | 83525 | (266,113), (278,79), (287,34), (289,2) | B, **C**, **C**, **C** |

The bold entries are the two family members `(u² - 2, 2u)` and `(u², 2)`, which always
share the letter `C`; `s = 4` is a **semiprime** (`50629 = 197 · 257`) with *exactly*
two primitive representations, both `C`.  This refutes the orbit conjecture of the
previous cycle (`orbit_letter_separation_false`, `semiprime_same_letter_collision`).

### 7.2 Valuation-constant semiprimes (`TwoAdicCapRefutation.lean`)

Exhaustive scan of odd `N ≡ 7 (mod 8)` below `2 · 10⁵` with at least two factorisations:
`2197` of them realise a **single** value of `v₂(p + q)` across all factorisations.
The smallest are

| `N` | factorisations | `v₂(p+q)` values |
|---|---|---|
| 119 = 7·17 | (1,119), (7,17) | {3} |
| 343 = 7³ | (1,343), (7,49) | {3} |
| 391 = 17·23 | (1,391), (17,23) | {3} |
| 527 = 17·31 | (1,527), (17,31) | {4} |
| 679 = 7·97 | (1,679), (7,97) | {3} |

The proved family `N = 7q` with `q ≡ 1 (mod 16)` (119, 679, 791, 1351, …) is the
`v₂ = 3` case, and Dirichlet's theorem makes it infinite
(`two_adic_constant_of_prime`, `two_adic_cap_conjecture_false`).

## 8. Third cycle: search bounds, magnitude windows, collision counts

### 8.1 Level sizes and letter counts (`SearchLowerBound.lean`)

Depth-`h` levels of the tree, counted by ascent word:

| depth `h` | nodes `3^h` | nodes with last letter `A` / `B` / `C` |
|---|---|---|
| 1 | 3 | 1 / 1 / 1 |
| 2 | 9 | 3 / 3 / 3 |
| 3 | 27 | 9 / 9 / 9 |
| 4 | 81 | 27 / 27 / 27 |

The pattern is a theorem, not a measurement: `card_depthNodes` gives `3 ^ h` and
`card_depthNodes_letter` gives exactly `3 ^ (h-1)` per letter, with
`sum_card_depthNodes_letter` checking that the three classes exhaust the level.

Restart energy versus exhaustive search, at accuracy `1/2` (`h · 2^h` against `3^h`):

| `h` | `h · 2^h` | `3^h` |
|---|---|---|
| 1 | 2 | 3 |
| 5 | 160 | 243 |
| 10 | 10240 | 59049 |
| 20 | 20971520 | 3486784401 |

The inequality holds at *every* `h` (`restart_beats_exhaustive_half`), and the
threshold accuracy separating "guided wins" from "brute force wins" is exactly `1/3`
(`guided_cost_threshold_one_third`).

### 8.2 Dyadic windows (`MagnitudeWindows.lean`)

Representatives found by the discrete intermediate-value lemma inside the window
`[1024, 2048)`:

| letter | family | index | node | hypotenuse |
|---|---|---|---|---|
| `A` | `(m+1, m)`, `hyp = 2m²+2m+1` | `m = 23` | `(24, 23)` | 1105 |
| `B` | `(4u+1, 2u)`, `hyp = 20u²+8u+1` | `u = 7` | `(29, 14)` | 1037 |
| `C` | `(8u+1, 2u)`, `hyp = 68u²+16u+1` | `u = 4` | `(33, 8)` | 1153 |

The predecessors `m = 22` (1013), `u = 6` (769) and `u = 3` (661) fall below the
window, confirming the minimality step of `window_hit`.  All three letters therefore
occur in the same log-magnitude decile — the support form of the measured null
(`all_letters_in_every_window`, `decile_sensor_letterBlind`).

### 8.3 Collision counting (`CollisionCounts.lean`)

Splitting family `500t² + 5`: 505, 2005, 4505, 8005, … (letters `A` and `B` at every
`t ≥ 1`); non-splitting Sophie Germain family `u⁴ + 4`, `u = 2s+7`: 2405, 6565, 14645,
28565, 50629, … (letter `C` twice).  Counting up to `X` gives at least `≍ X^{1/2}`
splitting magnitudes and at least `≍ X^{1/4}` non-splitting ones
(`many_split_collisions`, `many_same_letter_collisions`).
