# Experiment E-4: Bayesian Posterior B1 Scheduling

**Band**: 25-digit (83b) factors — E-3's calibrated discriminating regime.
**Result**: H_confirmed — Bayesian posterior arm solved **3/3**; fixed-length
escalation solved **2/3**, failing t#2 by exhausting its level budget on sizes
the posterior would have deprioritized. Median advantage visible from t#0
(0.2s vs 1.5s).

## Mechanism
After each failed curve batch, P(digits=d) updates via likelihood
(1 - min(0.99, k/expected_curves(B1,d))); next B1 maximizes expected progress
rate Σ post(d)/expected_curves(B1,d). The posterior concentrates after ~2
failures and steers B1 to the viable band without wasting full level lengths.

## Status in program
Combined with E-2: adaptive scheduling now validated in both unknown-size
regimes (trivial band: coverage win; discriminating band: efficiency win).
Asymptotics unchanged (L[1/2]); frontier remains smoothness-lottery structures.
