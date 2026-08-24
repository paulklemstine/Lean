# Computational Evidence — TDIAL-BITLEN (round-56 #1, exp 526)

All numbers below are exact rational computations (Python `fractions`), reproduced
symbolically inside the two Lean files
`Catalog/Pythagorean/ZeroFitDialRelationRate48.lean` and
`Catalog/Pythagorean/ZeroFitDialResolutionLadder48.lean`.

## 1. The recorded cell

| quantity | value |
|---|---|
| Spearman(T, rate), seed 20261110 | 0.7192 |
| Spearman(T, rate), seed 20261111 | 0.7202 |
| Spearman(T, rate), seed 20261112 | 0.7198 |
| seed spread | 0.0010 |
| advantage of T over popcount | +0.098 … +0.145 |
| mean relation rate | 0.125 = 1/8 |
| draw law | uniform, exact bitlen 48 (so `n = 2^47` values of the free suffix) |

Squared values (what the sum-of-squares algebra actually constrains):
ρ²(A) = 0.51724864, ρ²(B) = 0.51868804, ρ²(C) = 0.51811204.

## 2. Small-case calculation: the dyadic tie profile

The T-dial at exact bitlen `b+1` partitions the `n = 2^b` suffixes into dyadic tie
blocks of sizes `1, 1, 2, 4, …, 2^{b-1}` (the 2-adic valuation classes).
The total centred rank sum of squares of that profile is

```
ssR(dyadicBlocks b) = (n³ − 1)/14 ,   n = 2^b .
```

Checked for `b = 1..8` by direct summation, and proved in Lean as `ssR_dyadic`.

| b | n | ssR (exact) |
|---|---|---|
| 2 | 4 | 63/14 = 9/2 |
| 3 | 8 | 511/14 = 73/2 |
| 4 | 16 | 4095/14 |
| 5 | 32 | 32767/14 |

## 3. Counterexample hunt: can a binary (relation / no-relation) response reproduce 0.7192?

For a two-valued response with `K` of the `n` items marked, the *exact* ceiling is

```
ρ² ≤ n·K·(n−K) / (4 · ssR) ,
```

and on the dyadic profile this collapses to the **rate parabola**

```
ρ²_max(p) = (7/2)·p·(1−p) · n³/(n³ − 1) ,   p = K/n .
```

| relation rate p | ρ²_max (limit) | ρ_max |
|---|---|---|
| 1/2 | 0.875 | 0.9354 |
| 1/4 | 0.65625 | 0.8101 |
| **1/8 (recorded)** | **0.3828125** | **0.61872** |
| 1/16 | 0.20508 | 0.45286 |

At the recorded rate 12.5 % a binary response cannot exceed **ρ ≈ 0.6187**, while all
three seeds report ρ ≈ 0.7195. The hunt therefore returns **no counterexample**: no
two-valued response at rate 1/8 reproduces the measurement — a genuine obstruction,
formalised as `relation_response_not_binary` and `exact_bitlen48_rate_eighth_ceiling`.
Solving `(7/2)p(1−p) ≥ 0.7192²` shows a binary model would need a rate of at least
about 0.1803; among *dyadic* rates the first admissible one is 1/4, i.e. **double the
recorded rate** (`binary_model_needs_double_rate`).

## 4. The resolution ladder: how much of the T-scale must the response see?

A response blind below the dyadic boundary `1 − 2^{-t}` (i.e. merging the bottom
`1 − 2^{-t}` of the mass into one tie) and perfectly resolving above it attains exactly

```
ρ² = ( (7/2)(2^t − 1)2^t·8^{b−t} + 8^{b−t} − 1 ) / (8^b − 1) .
```

At `b = 47` (exact bitlen 48):

| t | blind fraction | ρ² | ρ | limit value |
|---|---|---|---|---|
| 1 | 50 % | 1.000000 | 1.0000 | 7/8 |
| 2 | 75 % | 0.671875 | 0.8197 | 43/64 |
| **3** | **87.5 %** | **0.384766** | **0.6203** | 197/512 |
| 4 | 93.75 % | 0.205322 | 0.4531 | 841/4096 |
| 5 | 96.875 % | 0.105988 | 0.3256 | 3473/32768 |

Since ρ²(seed) ≈ 0.5172 lies strictly between the `t = 3` and `t = 2` rows, the recorded
dial **excludes every response blind at depth `t ≥ 3`** and is **compatible with `t = 2`**.
That two-sided statement is `resolution_threshold_at_bitlen48`; its extension to
arbitrarily fine resolution above the boundary is `bulk_blind_response_excluded`.

## 5. An inversion that is *not* monotone in refinement

Comparing the coarse binary ceiling at rate 1/2 (7/8 = 0.875) with the fully refining
dyadic ceiling normalisation (6/7 ≈ 0.857) gives `coarse_beats_refining_at_half`:
a *coarser* response can outrank a strictly finer one. The exact crossing is recorded in
`binary_ceiling_inversion_reversal`.

## 5b. The tip is cheap, the bulk is not

Merging the *top* `2^{-t}` fraction of the T-scale into one tie costs exactly that part's own
sum of squares (the parallel-axis cross terms cancel), giving
`ρ² = (8^b − 8^{b−t})/(8^b − 1)`:

| merged part | mass merged | ρ² at b = 47 |
|---|---|---|
| top, t = 1 | 50 % | 0.875000 |
| top, t = 2 | 25 % | 0.984375 |
| top, t = 3 | 12.5 % | 0.998047 |
| bottom, t = 2 | 75 % | 0.671875 |
| bottom, t = 3 | 87.5 % | 0.384766 |

So blindness on the top half of the scale is harmless for the recorded value while blindness
on the bottom `87.5 %` is fatal (`bulk_tip_resolution_asymmetry`).

## 5c. The constant `7/2` is a shape constant, not an arithmetic one

For the ratio-`1/q` geometric tie spectrum (block sizes `(q−1)q^{b−1}, …, (q−1), 1`), exact
summation gives `ssR = (n³ − 1)/c(q)` with `c(q) = 4(q²+q+1)/q`, hence the ceiling constant
`C(q) = c(q)/4 = (q²+q+1)/q = q + 1 + 1/q`:

| q | c(q) = (n³−1)/ssR | C(q) |
|---|---|---|
| 2 | 14 | 7/2 = 3.5 |
| 3 | 52/3 | 13/3 ≈ 4.333 |
| 4 | 21 | 21/4 = 5.25 |
| 5 | 124/5 | 31/5 = 6.2 |

Checked by exact summation for `q ≤ 5`, `b ≤ 5`, and then proved for all `q, b`
(`ssR_geom`, `geom_binary_ceiling`). Since `C` is strictly increasing, the dyadic regime of
the recorded experiment is the *hardest* member of the family
(`dyadic_is_hardest_regime`).

## 6. OEIS

The tie profile `1, 1, 2, 4, 8, 16, …` is A011782 (`a(0)=1`, `a(n)=2^{n-1}`);
the between-group sums of squares `(8^b − 1)/14` for `b ≥ 1` give
`0, 4.5, 36.5, 292.5, …` i.e. `(8^b−1)/14`, the partial sums of `8^k/2`, which is not a
distinguished OEIS entry in its own right — the relevant integer sequence is the
numerator family `8^b − 1` (A024088 shifted). No new sequence is claimed.

## 7. What the evidence does and does not support

* **Supported and proved:** the recorded ρ ≈ 0.7195 at rate 12.5 % is *incompatible*
  with a binary response and with any bulk-blind response of depth ≥ 3; it is
  *compatible* with a response resolving the 2-adic classes `v₂ ≤ 2`, and also with a
  response that is totally blind on the top `2^{-t}` of the scale for any `t ≥ 1`.
* **Also proved:** the ceiling family is bitlen-invariant to within `2·8^{-b}`, and its
  constant `7/2` generalises to `(q²+q+1)/q` for a ratio-`1/q` tie spectrum.
* **Not claimed:** nothing here validates the sampling code itself; the Lean results are
  statements about the exact rank algebra of the dyadic tie profile at `b = 47`,
  which is the structure the experiment measures against.
