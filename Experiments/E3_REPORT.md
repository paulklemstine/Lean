# Experiment E-3: Scale Validation — Calibration Finding

**Result**: all arms solved all sizes (48/56/64-bit factors) near-instantly.
Root cause of uniformity: GMP-ECM's B1 tables are calibrated in DECIMAL DIGITS.
A 48-bit factor ≈ 15 digits sits far below even B1=11k's difficulty target
(~25-30 digits). Validated directly: 5 curves at B1=11k factored a 95-bit
semiprime with a 48-bit prime factor in 0.03s.

## Calibration law extracted
| factor size | ECM difficulty |
|---|---|
| ≤ 64 bits (≤20 digits) | trivial at any schedule |
| 80-100 bits (25-30 digits) | B1=11k-50k regime (E-2's sweet spot) |
| 150+ bits (45+ digits) | minutes-hours; schedule choice matters |

## Implication for the FACT program
All FACT-program experiment semiprimes to date live entirely below the ECM
difficulty floor — factorization cost was never the experimental bottleneck;
the measured barriers are about method design, not compute. Differentiating
adaptive vs static scheduling requires ≥200-bit moduli (60+ digit factors),
which is where E-3 must next run (hours-per-instance budget).

E-1/E-2 conclusions unchanged; E-2's adaptive advantage applies in the
80-150-bit-factor band, not the trivial band tested here by mistake.
