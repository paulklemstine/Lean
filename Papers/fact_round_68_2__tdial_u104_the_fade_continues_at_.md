# Computational evidence — TDIAL-U104 (exp 541, bitlen 104)

All numbers below are exact rationals (Python `fractions.Fraction`, decimal shown), and every
one of them is re-checked inside `Catalog/MachineLearning/ZeroFitDialFade104.lean` by `norm_num`
over `ℚ`, so nothing here is load-bearing on floating point.

## 1. The recorded reading

| quantity | value |
|---|---|
| seed 20261210 | 0.493 |
| seed 20261211 | 0.499 |
| seed 20261212 | 0.509 |
| pooled | 0.500, CI [0.456, 0.545] |
| seed mean | 1501/3000 = 0.500333… (pooled agrees to 1/3000) |
| T advantage over count | +0.126, so count pooled = 0.374 |
| reported 4-bit steps | −0.030 (96→100), −0.043 (100→104) |

Reconstructing the two previous readings from the reported step sizes:
`read100 = 0.500 + 0.043 = 0.543`, `read96 = 0.543 + 0.030 = 0.573`.

## 2. The hyperbolic erosion law of the previous cycle

`rhoModel b = 5/14 + 93/(5b)` (from `MachineLearning.ZeroFitDialFloor92`):

| b | 44 | 52 | 64 | 76 | 92 | 96 | 100 | 104 |
|---|---|---|---|---|---|---|---|---|
| model | 0.77987 | 0.71484 | 0.64777 | 0.60188 | 0.55932 | 0.55089 | 0.54314 | 0.53599 |
| data | 0.780 | 0.705 | 0.648 | 0.608 | 0.5595 | 0.573 | 0.543 | 0.500 |
| residual | −0.0001 | +0.0098 | +0.0002 | +0.0064 | −0.0002 | **−0.0221** | +0.0001 | **+0.0360** |

The residual **changes sign** across the last three bitlens and blows up by a factor 3.6 at
bitlen 104 relative to the previous worst residual (1/100). The model's own 100→104 step is
0.00715, i.e. six times smaller than the measured 0.043.

**Structural diagnosis.** For any law `A + C/b` with `C ≥ 0`, the second difference on a 4-bit
grid is
`(f(b) − f(b+4)) − (f(b+4) − f(b+8)) = 32C / (b(b+4)(b+8)) ≥ 0`,
so hyperbolic fades always *decelerate*. Likewise for any `A + C·q^b` with `C, q ≥ 0` the second
difference is `C·q^b·(1−q⁴)² ≥ 0`. The measured steps *increase* (0.030 then 0.043), so **no**
convex fade law of either family can pass through the three late-epoch readings. This is the
content of `no_hyperbolic_law_fits` / `no_geometric_law_fits` in the Lean file.

## 3. The local linear (secant) law

`linModel b = 1449/1000 − (73/8000)·b` passes exactly through (96, 0.573) and (104, 0.500) and
misses (100, 0.543) by 0.0065.

* constant 4-bit step 73/2000 = 0.0365 (the mean of the two measured steps);
* `linModel 49 = 1.001875 > 1` — the law **cannot** be global, a correlation exceeds 1 below
  bitlen 50; it is an intermediate-asymptotic regime only;
* floor crossing: `linModel 98 = 0.55475 ≥ 0.55 > 0.545625 = linModel 99`;
* extinction: `linModel 158 = 0.00725 ≥ 0 > −0.001875 = linModel 159`;
* the previous cycle's saturation ceiling `3/28` for the forced corruption fraction is breached
  from bitlen 120 on (`linModel 120 = 0.354 < 5/14 = 0.357143`).

## 4. Tie geometry (unchanged conclusion, tightened)

Exact dyadic ceilings `ρ² = (6/7)(1 + 1/(2^b(2^b+1)))`:

```
b = 92 : 0.857142857142857142857142857142857142857142857142857142857142857 + 8.7e-56
b = 104: same to 1e-62
gap(92,104) < 1e-50, while ρ² fell from 0.3130 to 0.2500 (drop 0.063).
```
So the tie-artefact explanation is now excluded by **48 orders of magnitude**. Capped-resolution
dials all satisfy `ρ² ≥ 3/4`; the reading is `ρ² = 0.25`.

## 5. Effective base (p-adic ledger)

`padicLimit p = 3p/(p²+p+1)`:

| p | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|
| `padicLimit p` | 0.328767 | 0.296703 | 0.270270 | 0.248120 | 0.229299 |

Squares of the readings: 0.493² = 0.243049, 0.499² = 0.249001, 0.509² = 0.259081,
0.500² = 0.250000. Hence effective base **10** for the pooled reading and for seeds B, C, and
**11** for seed A. At bitlen 92 the effective base was 8. Drift rate: 2 units / 12 bits =
0.1667 per bit against 1 unit / 16 bits = 0.0625 previously — the base drift accelerates in step
with the fade.

General bracket (proved in Lean): an effective base `p` for a reading `ρ > 0` always satisfies
`1/ρ² − 1 < p ≤ 3/ρ²`. At `ρ = 0.5` this gives `3 < p ≤ 12`, and 10 sits inside.

## 6. Corruption ledger

`reqFrac ρ = (1−ρ)/6`. `reqFrac 0.500 = 1/12 = 0.08333`, against `reqFrac(mean92) = 0.07342` and
the floor budget `3/40 = 0.075`. The floor budget is now **exhausted**: any rank-level mechanism
reproducing the bitlen-104 reading must displace more than 7.5 % of the sample. It is still below
the hyperbolic saturation value 3/28 = 0.10714, which the linear law breaches at bitlen 120.

## 7. Counterexample hunt

* Searched for a convex fade law (hyperbolic or geometric, any parameters) fitting the three
  late-epoch readings: **none exists** — proved, not merely searched.
* Searched integers `p ≤ 200` for an effective base of the pooled reading other than 10: none
  (the effective base is unique, proved in Lean via strict antitonicity of `padicLimit`).
* No OEIS sequence is involved: the objects here are rational tie profiles and measured
  correlations, not integer sequences.

---

# Cycle 2 evidence — extinction versus floor

Formalised in `Catalog/MachineLearning/ZeroFitDialFadeDichotomy.lean`.

## 8. Harmonic fade with the recorded parameters

Start `ρ₀ = 0.5739` (bitlen 96), decrements `c/(k+1)` with `c = 0.0303` (the recorded first step).

| four-bit step `n` | 1 | 8 | 32 | 128 | 2³⁶ |
|---|---|---|---|---|---|
| `H_n` | 1 | 2.71786 | 4.05850 | 5.43315 | ≥ 19 (Oresme) |
| `ρ(n)` | 0.5436 | 0.49155 | 0.45093 | 0.40928 | ≤ 0 |

Dyadic bounds used in Lean: `1 + m/2 ≤ H_{2^m} ≤ 1 + m` (lower bound reused from the catalog's
`KnownUnresolvedCards.harmonic_two_pow_ge`, upper bound `harmonic_two_pow_le` proved here). They
give death by step `2³⁶` and `ρ > 0.33` for every `n ≤ 128`, i.e. every bitlen up to 512.

## 9. The two continuations of the recorded ladder

`recRung = (0.5739, 0.5436, 0.5005, 0.4880, 0.4621, 0.4847, 0.43636)` at bitlens 96…120.

| step past the last rung | 0 | 4 | 9 | 10 |
|---|---|---|---|---|
| floor continuation `contFloor` | 0.43636 | 0.23181 | 0.21861 | 0.21839 |
| death continuation `contDeath` | 0.43636 | 0.26182 | 0.04364 | 0.00000 |

Both agree with all seven recorded rungs, both are antitone. They separate by more than `0.17` at
step 9, i.e. bitlen 156 — the discriminating measurement.

## 10. Counterexample hunt, cycle 2

* Searched for a uniform contraction factor `q < 1` bounding all six recorded step ratios: none —
  `|0.0431/0.0303| = 1.42`, `|0.0259/0.0125| = 2.07`, `|0.0483/0.0226| = 2.14`. (Recorded here as
  an arithmetic observation; it is the first next-cycle sub-conjecture, not yet formalised.)
* Effective bases of the recorded rungs, from `padicLimit p = 3p/(p²+p+1)`: bitlen 76 → 6,
  92 → 8, 104 → 10, 120 → 14. Increments 2, 2, 4.

## 11. Cycle 3 — the contraction test, now formalised

The arithmetic observation logged in §10 has been turned into a theorem
(`ZeroFitDialContraction.contraction_factor_ge_two`). The six recorded four-bit decrements from
bitlen 96 are

| `k` | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| `recStep k` | 0.0303 | 0.0431 | 0.0125 | 0.0259 | −0.0226 | 0.04834 |

and the consecutive ratios `|d_{k+1}|/|d_k|` are

| pair | 0→1 | 1→2 | 2→3 | 3→4 | 4→5 |
|---|---|---|---|---|---|
| ratio | 1.4224 | 0.2900 | 2.0720 | 0.8726 | 2.1389 |

The binding pair is `4→5`: `4834/100000 ÷ 226/10000 = 4834/2260 ≈ 2.1389`, so the minimal
admissible uniform factor is `q ≥ 4834/2260 > 2`. No `q < 1` exists, so the geometric-contraction
premise (`r ≤ 1/2`) under which a plateau can be localised is not met by this ladder. The very
first pair already fails (`1.42 > 1`), so the failure is not an artefact of the bitlen-116 rebound
alone.

Conversely, `contractive_tail_bound` shows what contraction would buy: for `q < 1` the entire
remaining fade after rung `n` is at most `|d_n|/(1−q)`. At the recorded bitlen-120 step
`0.04834`, a hypothetical `q = 1/2` would cap all future fade at `0.0967`, leaving a floor
`0.43636 − 0.0967 = 0.3397 > 0`. The floor reading is thus exactly as strong as the contraction
assumption, and no stronger.

## 12. Cycle 4 — pricing the smooth reading in units of measurement error

Ask for a latent ladder `tau` with `|recRung k − tau k| ≤ eps` for all seven rungs.

| hypothesis on `tau` | binding constraint | minimal `eps` |
|---|---|---|
| non-increasing | `tau 4 ≥ tau 5` against `0.4621` vs `0.4847` | `0.0113` (exactly; witness below) |
| decrements halve (`q = 1/2`) | total fade `0.13754` vs `(63/32)·(0.0303 + 2eps) + 2eps` | `≥ 0.012823` |

Sharp monotone witness (`flatWitness`): `0.5739, 0.5436, 0.5005, 0.4880, 0.4734, 0.4734, 0.43636`.
Its largest deviation is `|0.4847 − 0.4734| = |0.4621 − 0.4734| = 0.0113`.

Comparison against the two recorded dispersion scales at bitlen 104:

| scale | value | vs monotone price `0.0113` | vs plateau price `0.012823` |
|---|---|---|---|
| per-seed half-spread `(0.509 − 0.493)/2` | `0.0080` | below | below |
| pooled CI half-width `(0.545 − 0.456)/2` | `0.0445` | above (3.9×) | above (3.5×) |

So the smooth reading is affordable at the pooled-interval scale and unaffordable at the
seed-dispersion scale. The `flatWitness` ladder is monotone but *not* contractive for any `q`
(its rung-4 decrement is `0` and its rung-5 decrement is `0.03704`), so monotonicity is strictly
cheaper than a plateau both numerically and structurally.

## 13. Cycle 5 — the monotone price is global, not local

Counterexample hunt against the cycle-4 sub-conjecture ("price = half the largest *consecutive*
increase"). Take `r = (0, 0.01, 0.02)`.

| pair `(k,l)` | `r l − r k` |
|---|---|
| `(0,1)` | `0.01` |
| `(1,2)` | `0.01` |
| `(0,2)` | `0.02` |

Local rule predicts `0.005`; the true price is `0.01` (constant `tau ≡ 0.01` realises it, and
`(0,2)` forbids anything smaller). The sub-conjecture is therefore **false**, and the corrected
statement — price `= (1/2)·max_{k ≤ l} (r l − r k)` — is proved as `ladder_mono_price`, with
sufficiency realised by the suffix-maximum flattening `tau k = max_{k ≤ j ≤ n} r j − eps`.

For the recorded T-dial ladder all 28 pairwise excursions are checked: the maximum is the single
consecutive rebound `0.4847 − 0.4621 = 0.0226`, so the local and global formulas coincide *there*
and the cycle-4 figure `0.0113` survives as an instance of the general theorem.

## 14. Cycle 6 — the recorded curvature word

Grid second differences `r(b+8) − 2 r(b+4) + r(b)` of the recorded ladder, on the 4-bit grid:

| base bitlen | 96 | 100 | 104 | 108 | 112 |
|---|---|---|---|---|---|
| second difference | `−0.0128` | `+0.0306` | `−0.0134` | `+0.0485` | `−0.07094` |

Curvature word: `− + − + −`. Both signs occur strictly, so the ladder is outside the reach of any
signed-curvature law: a convex `h` would force all five to be `≥ 0` (contradicted at 96), a
concave `h` would force all five to be `≤ 0` (contradicted at 108). This is proved in
`ZeroFitDialConvexSpectroscopy.no_signed_curvature_law` from the midpoint convexity inequality
alone — no parameters, no fitting.
