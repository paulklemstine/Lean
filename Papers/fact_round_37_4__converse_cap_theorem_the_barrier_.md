# Computational Evidence — residue-dial speedup law and the universal cap 4/3

All numbers below were produced with exact rational arithmetic (Python
`fractions.Fraction`), so the reported maxima are exact, not floating-point
approximations. The Lean files in `Catalog/Cryptography/ResidueDial/` prove the
corresponding statements; this note only records the exploration that preceded
them.

## 1. The model being measured

Class space: the `n = φ(m)` invertible residue classes mod `m`.
Dial: a subset `K` of those classes, `k = |K|`, density `θ = k/n`.
Target class uniform. Dial-aware scan: try the `k` kept classes; if the target
is not among them, fall back to the full scan of `n`. So

    E[cost] = (k/n)·k + (1 − k/n)·n,     ratio = E[cost]/n = 1 − θ + θ².

Speedup = `1/(1 − θ + θ²)`.

**Scope.** This is a *single-pass* scan: the dial reorders the classes but a
class once scheduled is paid for. If the dial instead lets the algorithm skip
the rejected classes, the cost is `Σ θᵢ²` and no universal cap holds (a balanced
`r`-symbol full reveal buys exactly `r`; proved as
`ResidueDial.revealSpeedup_uniform`). All the numbers below are for the
single-pass model.

## 2. Exhaustive small-modulus enumeration

For each modulus we enumerated every admissible dial size `k = 0 … φ(m)`
(equivalently, by structure-blindness, every subset — see §3) and took the exact
maximum of the speedup.

| m  | φ(m) | max speedup | argmax k | k/φ(m) |
|----|------|-------------|----------|--------|
| 3  | 2    | 4/3         | 1        | 1/2    |
| 4  | 2    | 4/3         | 1        | 1/2    |
| 5  | 4    | 4/3         | 2        | 1/2    |
| 7  | 6    | 4/3         | 3        | 1/2    |
| 8  | 4    | 4/3         | 2        | 1/2    |
| 11 | 10   | 4/3         | 5        | 1/2    |
| 12 | 4    | 4/3         | 2        | 1/2    |
| 15 | 8    | 4/3         | 4        | 1/2    |
| 21 | 12   | 4/3         | 6        | 1/2    |
| 33 | 20   | 4/3         | 10       | 1/2    |

Every maximum is exactly `4/3 = 1.3333333333…`, attained exactly at half
density. No modulus (prime, prime power, or composite with several prime
factors) does better.

## 3. Structure blindness (Lemma B2 check)

For `m = 11` we enumerated **all** `2^10` subsets of the units and recorded the
pair `(|S|, speedup)`. The number of distinct pairs is `11 = φ(11) + 1`, i.e.
the speedup is a function of `|S|` alone; two dials of the same size — one a
coset of the squares, one a random scatter — give literally the same value. So
mixing character fibres cannot beat a plain half-density set.

Formalised as `speedup_blind_to_structure` / `dial_speedup_eq_of_card_eq` in
`Converse.lean`.

## 4. Batteries (CRT composition)

Composing independent dials on pairwise coprime moduli multiplies densities,
`θ = ∏ θᵢ` (`crt_density_mul` in `Battery.lean`). Enumerating all
`(k₃,k₄,k₇,k₁₁)` for the battery `M = 3·4·7·11 = 924` gives maximum speedup
exactly `4/3` again: composition buys nothing beyond a single dial.

Numerically: `log₂(4/3) = 0.41503749927884376`. So even a battery advertising
`12.7235` "capacity bits" can convert them into at most `0.41504` work-bits —
capacity bits and work bits are different currencies
(`workBits_le_cap`, `capacity_bits_unbounded_work_bits_capped`).

## 5. Multi-symbol dials

For an `r`-block single-pass dial with densities `θ₁,…,θ_r` summing to `1`, the
cost is `Σ_i θ_i (θ_1 + … + θ_i)`. Exhaustive exact-rational search over the
density grid with denominator `12` gave maxima

| r | grid maximum | attained at | predicted `2r/(r+1)` |
|---|--------------|-------------|----------------------|
| 2 | 4/3          | (1/2,1/2)   | 4/3                  |
| 3 | 3/2          | (1/3,1/3,1/3) | 3/2                |
| 4 | 8/5          | (1/4,…)     | 8/5                  |
| 5 | 48/29 ≈ 1.655 | (1/6,1/6,1/6,1/4,1/4) | 5/3 ≈ 1.667 |

The `r = 5` row is below the prediction only because the uniform point `1/5` is
not on a denominator-`12` grid — exactly the behaviour a cap attained solely at
uniform densities must show. All values are `< 2`. This is now the theorem
`ResidueDial.multiSpeedup_le_cap` with attainment `multiSpeedup_uniform`, and
the cost was found (and proved) to be independent of the block order
(`prefixCost_comp_perm`).

## 6. Counterexample hunt

Beat-the-cap attempts: over all subset sizes for the moduli in §2, all `2^10`
subsets for `m = 11`, and all product dials for the four-factor battery, no
configuration exceeded `4/3`, and none came anywhere near `2`. The obstruction
is the elementary identity `1 − θ + θ² = (θ − 1/2)² + 3/4 ≥ 3/4`, proved in
`Core.lean` (`dialCost_ge_three_quarters`), which shows no counterexample can
exist for any density whatsoever, including irrational ones outside `[0,1]`.
