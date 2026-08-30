# Computational evidence — NET-91 CPU speculative decoding

All numbers below are exact-rational or floating-point evaluations of the *models* defined
in `Catalog/Shared/SpeculativeDecoding*.lean` against the NET-91 measurement table.  Every
claim that survives into a headline is re-proved in Lean; this file records the exploration
that selected which claims to attempt (and which to abandon).

## 0. The measurement table (input, not derived)

Target: Qwen2.5-7B-Instruct Q4_K_M, llama.cpp, i9-9900K, threads = 8, 5.79 tok/s greedy
baseline.  Relative per-token draft cost: 0.5B → 0.118, 1.5B → 0.234.

| draft | depth | prose accept | prose speedup | code accept | code speedup |
|---|---|---|---|---|---|
| 0.5B | 2 | 63.9% | 1.254x | 71.6% | 1.352x |
| 0.5B | 4 | 47.7% | 1.416x | 63.0% | 1.616x |
| 0.5B | 8 | 30.9% | 0.979x | 56.0% | 1.661x |
| 1.5B | 2 | 63.2% | 1.016x | 83.4% | 1.195x |
| 1.5B | 4 | 51.9% | 1.153x | 74.8% | 1.395x |
| 1.5B | 8 | 44.9% | 0.982x | 60.3% | 1.354x |

## 1. The i.i.d. block model `S(a,c,d) = (∑_{i≤d} a^i) / (1 + c·d)`

Evaluated at the measured acceptance of each cell:

| cell | model | model sign | measured sign | agree |
|---|---|---|---|---|
| prose 0.5B d=2 | 1.6564 | win | win | ✔ |
| prose 0.5B d=4 | 1.2669 | win | win | ✔ |
| prose 0.5B d=8 | 0.7444 | loss | loss | ✔ |
| prose 1.5B d=2 | 1.3838 | win | win | ✔ |
| prose 1.5B d=4 | 1.0334 | win | win | ✔ |
| prose 1.5B d=8 | 0.6315 | loss | loss | ✔ |
| code 0.5B d=2 | 1.8031 | win | win | ✔ |
| code 0.5B d=4 | 1.6539 | win | win | ✔ |
| code 0.5B d=8 | 1.1628 | win | win | ✔ |
| code 1.5B d=2 | 1.7231 | win | win | ✔ |
| code 1.5B d=4 | 1.5698 | win | win | ✔ |
| code 1.5B d=8 | 0.8678 | **loss** | win | ✘ |

**11 / 12 sign agreement.**  Head-to-heads (0.5B vs 1.5B at equal depth): 1.656 > 1.384,
1.267 > 1.033, 0.744 > 0.632, 1.803 > 1.723, 1.654 > 1.570, 1.163 > 0.868 — the cheap draft
wins all six inside the model (formalised as `cost_dominance_all_six`).

Depth landscape of the model at `c = 0.118` (`d = 0 … 7`):

```
a = 0.309 : 1.000 1.171 1.136 1.059 0.980 0.909 0.847 0.793   (optimum d = 1)
a = 0.477 : 1.000 1.321 1.379 1.339 1.267 1.188 1.113 1.044   (optimum d = 2)
a = 0.560 : 1.000 1.395 1.516 1.514 1.459 1.385 1.308 1.233   (optimum d = 2)
a = 0.630 : 1.000 1.458 1.640 1.682 1.654 1.594 1.520 1.443   (optimum d = 3)
a = 0.716 : 1.000 1.535 1.803 1.917 1.942 1.916 1.863 1.795   (optimum d = 4)
```

Optimal depth is visibly increasing in acceptance — this motivated the comparative-statics
theorem `depth_frontier_monotone` and the numeric split `optimal_depth_domain_split`.

## 2. Counterexample hunt: does the i.i.d. model ever rank `d = 8` above `d = 4`?

Sweeping `a` at `c = 0.118`:

```
a = 0.80 : S(4) = 2.2837, S(8) = 2.2268   → deeper loses
a = 0.83 : S(4) = 2.4192, S(8) = 2.4176   → essentially tied
a = 0.85 : S(4) = 2.5195, S(8) = 2.6351   → deeper wins
```

So the crossover sits near `a ≈ 0.83`, far above the measured code acceptance of `0.56`.
This is the counterexample that killed the i.i.d. reading of the reported percentages and
became `iid_cannot_explain_code_depth8` (quantified over all `a ≤ 0.8`) together with the
witness `iid_depth8_beats_depth4_at_085`.

## 3. Mean-yield reading `(1 + q·d) / (1 + k·d)`

With `k = c = 0.118`: code `d = 4 → 2.391`, `d = 8 → 2.819` (deeper wins, matching the
measurement); prose `d = 8 → 1.786 > 1` (a win, contradicting the measured `0.979`).  So
the mean reading needs extra cost: reproducing both depth-8 signs forces
`0.309 < k < 0.560` — `verification_overhead_bracket`.

## 4. Survival-profile reconstruction

Searching for nonincreasing `S` with prescribed partial sums (`∑_{k≤d} S k − 1 = q·d`):

```
code  : S = 1, 0.800, 0.632, 0.560, 0.528, 0.490, 0.490, 0.490, 0.490
        means: (0.800+0.632)/2 = 0.716 ✓  ; /4 = 0.630 ✓ ; /8 = 0.560 ✓
prose : S = 1, 0.700, 0.578, 0.350, 0.280, 0.141, 0.141, 0.141, 0.141
        means: 0.639 ✓ ; 0.477 ✓ ; 0.309 ✓
```

Both are monotone, so both are admissible profiles; the reconstruction is exact on all six
reported percentages.  (It is *not* unique — only three partial sums are pinned per domain,
hence the Lean statements are existence statements.)  The block means
(code `0.716, 0.544, 0.490`; prose `0.639, 0.315, 0.141`) are nonincreasing, as monotone
survival requires — a two-inequality-per-domain test the data could have failed.

## 5. Fitting a CPU cost curve

Affine cost `b + k·d` fitted on any two code cells fails the third:

```
b + 2k = 2.432/1.352 = 1.79882
b + 4k = 3.520/1.616 = 2.17822   ⟹ k = 0.18970, b = 1.41942
predicted b + 8k = 2.93722  vs required 5.480/1.661 = 3.29922   (12% off)
```

Hence the impossibility theorem `no_affine_cost_curve_fits_code_cells`.  Adding a quadratic
term and fitting the three code / 0.5B cells exactly gives

```
cost(d) = 1.5401 + (0.0992 + extra)·d + 0.0151·d²,   extra = 0.116 for the 1.5B draft
```

Out-of-sample performance on the other nine cells (relative error):

```
prose 0.5B : 1.0%  5.7%  7.5%
prose 1.5B : 9.7%  1.0% 10.6%
code  1.5B : 9.9%  8.3%  1.7%
```

Worst error 10.6%, formalised as `cpu_cost_curve_predicts_all_twelve` with an 11% band.
Residuals are systematic (1.5B over-predicted at shallow depth, prose at deep depth), which
is recorded as the next-cycle refinement in `FUTURE_DIRECTIONS.md`.

## 6. OEIS

No integer sequence arises here; the objects are rational-valued throughput ratios.  No
OEIS search was applicable.
