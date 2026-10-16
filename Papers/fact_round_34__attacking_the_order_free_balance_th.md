# Computational Evidence — Round 34

## 1. General-exponent reveal identity (machine-run, Lean `#eval`, brute force)

For each semiprime `N = pq` and exponent `E` we counted, by brute force over all
`a ∈ [0, N)` coprime to `N`, the bases with `[a^E ≡ 1 mod p] XOR [a^E ≡ 1 mod q]`,
and compared with `R(E) = d_p(q-1) + d_q(p-1) - 2 d_p d_q`, `d_p = gcd(E,p-1)`.

| (p,q) | E = 1 | 2 | 3 | 4 | 6 | 12 | 30 | N-1 |
|---|---|---|---|---|---|---|---|---|
| (5,7)   | 8  | 12 | 12  | 16  | 12  | 0   | 12  | 12  |
| (7,13)  | 16 | 28 | 36  | 32  | 36  | 0   | 36  | 36  |
| (11,23) | 30 | 56 | 30  | 56  | 56  | 56  | 200 | 56  |
| (13,37) | 46 | 88 | 126 | 160 | 216 | 288 | 216 | 288 |
| (3,11)  | 10 | 16 | 10  | 16  | 16  | 16  | 0   | 16  |
| (5,17)  | 18 | 32 | 18  | 48  | 32  | 48  | 32  | 48  |

**48/48 brute-force counts equal the formula.** No counterexample.  (Now proved for all
`p, q, E`: `AsymmetricExponent.card_revealing_exp`.)  Note `(13,37)`: `p-1 = 12 ∣ 36 = q-1`,
the maximal-gap extreme; `R(N-1) = 288 = (p-1)(q-p) = 12·24`, matching `max_reveal_extreme`.

## 2. Square discriminant of the solvable extreme

`q = k(p-1) - 1`: `(p,k) = (5,2) → q = 7, N = 35, D = 9 + 280 = 289 = 17²`, `p = (17+3)/4 = 5`;
`(7,3) → q = 17, N = 119, D = 16 + 1428 = 1444 = 38²`, `p = (38+4)/6 = 7`.
Proved in general: `extreme_factor_by_sqrt_neg`, `extreme_factor_by_sqrt`.

## 3. Delete-a-term LP (exact, proved rather than sampled)

| cost | value | status |
|---|---|---|
| `max(a, b, 1/2-a/2-b)` (Harvey) | 1/5 | `costExp_value` |
| + M-leg `(1-a)/4` | 1/5 | `mleg_actual_value` |
| + free M-leg (`θ=0`) | 1/5 | `mleg_free_value` |
| + leg `θ(1-a)`, `θ ≥ 1/4` | `θ/(1+θ)` | `mleg_value_of_ge` |
| delete interior / r / m (box) | 0 / 0 / 0 | `load_bearing_classification` |
| no split (`b = 0`) | 1/3 | `no_split_is_lehman` |
| collapse model `max(a, 1/4+a/4)` | 1/4 | `collapse_value`, penalty 1/20 |
| m-discount `m^{1-ε}` | `(1-ε)/(5-3ε)` | `babyDiscount_value` |
| interior gain `N^{-δ}` | `(1-2δ)/5` | `interiorGain_value` |

The breakpoint table `V(θ) = max(1/5, θ/(1+θ))`: `θ = 0, 1/8, 1/4 → 1/5`; `θ = 1/3 → 1/4`;
`θ = 1/2 → 1/3`.

## 4. Reported (not re-run here)

The round-34 NTT/remainder-tree pipeline's fitted penalty slope `0.046–0.052` (vs `1/20`)
is **reported data from the round summary and was not re-run or machine-checked in this
cycle.**  The Lean file proves only the model statement (`collapse_penalty`: `1/4 - 1/5 = 1/20`).

OEIS: no sequence lookup was relevant (the objects are parametric LP values and
two-prime counts, not integer sequences).
