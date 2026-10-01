# Computational evidence — D5-HINT-VALUE (`x⁵ + 20x + 32` at `m* = 320`)

These are exploratory computations (plain Python, exact integer arithmetic for root counts
and exact rational distributions for the model). The finite facts that the Lean file relies on
are re-checked inside Lean (`rootCount_eq_one_iff_chi20`, `product_view_merges_semiprimes`, and
the fibre-count lemmas); the plug-in readings below are **not** formally verified.

## 1. Root counts of `f = x⁵ + 20x + 32` mod `p`

Primes `7 ≤ p < 3000` (427 primes):

| roots mod p | count | D₅ class            | Chebotarev density |
|-------------|-------|---------------------|--------------------|
| 0           | 174   | rotation, type [5]  | 4/10               |
| 1           | 221   | reflection, [1,2,2] | 5/10               |
| 5           | 32    | identity, [1⁵]      | 1/10               |

No other root count ever occurs (consistent with `D₅`; `[1,1,1,2]`, `[1,4]`, `[2,3]` are absent).
Observed frequencies 0.407 / 0.518 / 0.075 vs 0.4 / 0.5 / 0.1.

## 2. Identifying the dial

For each quadratic field ramified only at 2 and 5 we tested "1 root ⟺ p inert":

| d   | matches all 427 primes? |
|-----|-------------------------|
| -1  | no  |
| 2   | no  |
| -2  | no  |
| 5   | no  |
| **-5** | **yes** |
| 10  | no  |
| -10 | no  |

By residue mod 20: classes 11, 13, 17, 19 always give 1 root; classes 1, 3, 7, 9 always give 0 or
5 roots. So the dial is `χ₂₀ = (-5/·)`, the character of `ℚ(√-5)`. (Lean: proved to agree with the
Legendre symbol by reciprocity; the root-count match is checked in Lean for all primes below 100.)

## 3. Exact Chebotarev-limit hint values (model, exact rationals)

| group | H(T_unord) | I(T_u; pair) | I(T_u; prod) | hint (unordered) | hint (ordered) |
|-------|-----------:|-------------:|-------------:|-----------------:|---------------:|
| D₃    | 2.3072 | 1.5 | 1.0 | **0.5** | **1.0** |
| D₅    | 2.1419 | 1.5 | 1.0 | **0.5** | **1.0** |
| D₇    | 2.0304 | 1.5 | 1.0 | 0.5 | 1.0 |
| D₉    | 2.6009 | 1.5 | 1.0 | 0.5 | 1.0 |
| F₂₀ (x⁵−2, C₄ dial) | 2.7160 | 2.375 | 1.25 | 1.125 | 1.75 |

D₃ and D₅ rows are proved in Lean. The F₂₀ product value 1.25 agrees with the catalog's
existing `quintic_pair_law` (5/4).

## 4. Plug-in readings on real semiprimes at m = 320

Labels: unordered pair of root counts; all pairs `p < q` of primes with `7 ≤ p, q < B`.

| B    | pairs   | I(T; N mod 320) | I(T; (s,d) mod 320) | hint   | I(T; χ(p),χ(q)) |
|------|---------|-----------------|---------------------|--------|-----------------|
| 500  | 4 186   | 1.0228          | 1.8785              | 0.8557 | 1.4873 |
| 1500 | 27 730  | 1.0035          | 1.7398              | 0.7363 | 1.4979 |
| 4000 | 149 331 | 1.0006          | 1.6142              | 0.6135 | 1.4987 |

The round-35 value **+0.6940** falls inside the range of these readings, and they decrease toward
the exact limit 1/2 as the sample grows. The product view (320 cells) is already at its limit 1;
the joint view (up to 320² cells) carries the plug-in bias.

## 5. Counterexample hunt

* "N mod 320 determines χ(p), χ(q)": **false**, witness `11·13 ≡ 7·569 ≡ 143 (mod 320)` with
  `χ₂₀ = (−1,−1)` vs `(+1,+1)` (Lean: `product_view_merges_semiprimes`).
* "The hint value 0.6940 is the ordered law": false; the ordered limit is 1 (Lean: `d5_verdict`).
* No prime below 3000 violates "root count ∈ {0,1,5}" or the `ℚ(√-5)` criterion.
