# VERIFICATION NOTE — Axis K (short-interval kangaroo)

Independent re-check of `r115/interval-kangaroo/RESULT.md`, by the lead, after the worker
reported. Method: re-derive every number in the summary table from the worker's own
op counts and its own measured rate, and look for internal contradictions inside the
document.

## Verdict

**The science is verified. The wall-clock column of the extrapolation table is wrong.**

Verified as correct and internally consistent:

- **Slope `β = 0.49716 ± 0.00393`** — confirms `ops ∝ √(interval)`;
  `|β − 1/2| = 0.72` standard errors over 32 bits of interval.
- **Constant `C = 2^2.75337 = 6.74` ops per `√w`** — reproduces *every* row of the table
  to within 4% (checked independently: `C·√(2^b)` vs the tabulated op count).
- **Measured rate `63 364 ops/s`** — consistent with the worker's own `ops ÷ wall` figure.
- **Feasibility figures `b ≈ 76` (one core-year), `≈ 103` (10⁴ cores), `≈ 116` (10⁶
  cores)**: recomputed from `C` and the rate, they fall out exactly (76.2 / 102.8 / 116.1).
- **Controls**: 12/12 planted-`d` recovery at all nine sizes, 108/108 cells with identical
  `total_ops` across two runs at a fixed seed.

## The error: the years column for `b ≥ 160`

Recomputed from the table's own op counts at its own measured rate:

| `b` | claimed | **correct** | factor |
|---|---|---|---|
| 96 | 949 years | 950 years | ✓ |
| 112 | 243 millennia | 245 millennia | ✓ |
| 128 | 62 Myr | 60 Myr | ✓ |
| 160 | 4.1e14 years | **4.1e12 years** | 100× |
| 192 | 2.7e27 years | **2.7e17 years** | 1e10× |
| 224 | 1.8e32 years | **1.8e27 years** | 1e10× |
| 256 | 1.1e37 years | **1.15e27 years** | 1e10× |

Call it `1.1e37 years`; at the measured rate that implies `6.6e-6` ops/s.

**The document contradicts itself**: line 212 states the generic baseline
`≈1.5·√n = 5.1e38` ops `≈ 2.6 × 10^26 years`, and `5.1e38 / 63364 / 3.156e7 = 2.55e26`
years — i.e. line 212 is *correct* and the table rows are the wrong ones. The error
introduced nothing into the analysis; it is confined to four cells of one column.

## One additional finding, sharper than the worker's

The BSGS column is not merely slower for large `b`, it is **memory-infeasible**: the table
is `√w` entries, so `b = 90` already needs `2^45 × 32 B ≈ 1.1e15 B` (about 1 PB). So
BSGS is practical only for `b ≲ 88`, and the "4.8× fewer ops" advantage the worker
measured is not reachable in practice above that boundary. This *strengthens* the
worker's own conclusion that kangaroo (distinguished-point, bounded memory) is the right
algorithm for the regime where the attack is feasible at all — with the sharper boundary
`b ≲ 88` for the memory-bounded alternative.

## What the corrected numbers change about the deployment statement

Nothing material: the feasibility figures (`b ≈ 76 / 103 / 116`) come from the op counts,
not from the years column, and they are verified. The corrected reading is

> any ECDSA key whose scalar has under ~76 bits of entropy is within reach of one
> core-year; ~103 bits with 10⁴ cores; ~116 bits with 10⁶ cores.

with the wall-clock at those points reading 950 years (`b=96`), 245 millennia (`b=112`)
and 60 Myr (`b=128`) — all confirmed, not merely extrapolated.
