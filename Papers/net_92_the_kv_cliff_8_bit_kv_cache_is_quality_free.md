# Computational evidence — NET-92 "THE KV CLIFF"

All numbers below are derived from the four measured NET-92 arms
(Qwen2.5-7B-Instruct Q4_K_M, CPU, `threads=8`, `ctx=2048`, held-out wikitext slice ≈62K
tokens).  They motivated the theorems in `Catalog/Logic/KVCliff*.lean`; the theorems
themselves are proved in Lean and do not depend on these calculations.

## 1. The measured table, in nats

Control `K f16 / V f16`: `PPL = 7.1093`.  Excess log-perplexity of an arm is
`log(PPL_arm / PPL_control)`.

| arm | PPL | ΔPPL | excess log-PPL (nats) |
|---|---|---|---|
| K f16 / V f16 | 7.1093 | — | 0 |
| K q8_0 / V f16 | 7.0924 | −0.238 % | −0.002380 |
| K f16 / V q8_0 | 7.1160 | +0.094 % | +0.000942 |
| K q8_0 / V q8_0 | 7.1162 | +0.097 % | +0.000970 |
| **K q4_0 / V q4_0** | **2714.6042** | **+38 084 %** | **+5.944998** |

## 2. The quantity the theorems are built around

Ratio of excess log-perplexities between the two ends of the grid:

```
5.944998 / 0.000970 = 6128.3          (worst q8_0 arm as the free reference)
log2(6128.3)        = 12.581  bits
12.581 / 4 bits     = 3.145           <- implied response exponent p
```

* `p ≈ 3.15` is why the Lean statement `net92_response_exponent_ge_three` proves `p > 3` and
  not something weaker: `16^3 = 4096 < 5000 ≤ 16^p`.
* `log2(5000)/3 ≈ 4.09` is why the band-width theorem `transition_band_width_le` yields
  "at most 4 bit widths".  Five bits already give `2^15 = 32768 > 5000`.

## 3. Counterexample hunt: can a smooth model fit both arms?

Sub-homogeneous responses (`D(cx) ≤ c·D(x)` for `c ≥ 1`) include every linear
error-propagation model, at any depth `L` and any per-layer amplification `κ`, because the
solution of `e_{L+1} = κ e_L + ε` is exactly degree one in `ε`:

```
D_pred(4-bit) ≤ 16 · D(8-bit) ≤ 16 · 0.000970 = 0.01552 nats
D_meas(4-bit) = 5.944998 nats
under-prediction factor ≈ 383
```

No counterexample exists: the family is refuted for *all* parameters, which is exactly what
`net92_refutes_subhomogeneous` and `depth_model_underpredicts_the_cliff` formalise.

Exponential-in-`ε` models fare no better: `exp(2ε)`-type certificates give
`(1.000970)^16 = 1.01564`, still 380× short of the measured `381.84` ratio.

## 4. Two-position sanity check for the single-softmax construction

Log-loss of the correct token in a two-position head with gap `G` under perturbation `±ε` is
`log(1 + exp(2ε − G))`.  With `G = 12`:

| ε | 2ε − G | log-loss (nats) | perplexity factor |
|---|---|---|---|
| 0 | −12 | 6.14e-6 | 1.000006 |
| 13/16 = 0.8125 | −10.375 | 3.12e-5 | 1.000031 |
| 13 | +14 | 14.0000 | > 1.2e6 |

The 16× step ratio alone separates "free" from "annihilated": the excess at `ε/16` is below
`1/1000` nats while at `ε` it exceeds `5` nats.  This is the content of
`cliff_realizable_in_one_softmax` (proved in Lean with explicit `exp`/`log` bounds).

## 5. Crowding arithmetic (context axis)

With `n` logits inside a window of width `R`, the forced minimum consecutive gap is `R/n`.
The safety criterion `2·(A/2^b) < R/n` rearranges to `2^b > 2An/R`, so:

```
ctx 2048 -> 4096 -> 8192 ...   requires b -> b+1 -> b+2 ...
```

At the reference scale `A = 1`, `R = 32` used in the Lean file: `SafeBits 1 32 2048 8` holds
(`4096 < 8192`), `SafeBits 1 32 2048 4` fails (`4096 > 512`), and `SafeBits 1 32 32768 8`
fails (`65536 > 8192`).  Hence the falsifiable prediction: the NET-92 cliff bracket `(4, 8]`
at `ctx = 2048` should sit at `(6, 10]` at `ctx = 32768`.

## 6. Block-scaling arithmetic

A `q4_1`-style block scale shrinks the range by `ρ`; the criterion is unchanged up to
`b ↦ b + log2(1/ρ)`.  Rescuing 4 bits to 8-bit safety therefore needs `ρ < 1/16`.  Against
distinctness, no scale helps: `32` weights per block, `16` codes, so at least
`32 − 16 = 16` collisions per block by pigeonhole.

## 7. OEIS

No integer sequence arises in this cycle; the objects are real-valued response functions and
bit-width thresholds.  No OEIS lookup was applicable.
