# Computational Evidence

## Small-case calculations

For the logistic recurrence

\[
x_{t+1}=3.83x_t(1-x_t),
\]

50-digit decimal arithmetic was used for 1,003 iterations. The last eight displayed values were:

| Initial state | Late iterates |
|---|---|
| 0.1 | 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598 |
| 0.2 | 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598 |
| 0.5 | 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598 |
| 0.7 | 0.156149316, 0.504666487, 0.957416598, 0.156149316, 0.504666487, 0.957416598, 0.156149316, 0.504666487 |

This is numerical evidence for attraction to a period-three cycle at this parameter, not an exact proof of the displayed decimals or a measurement of the set of all periodic points.

## Counterexample hunt

The proposed universal statement “a continuous self-map of an interval has dense periodic points” fails for the contraction `f(x)=x/2` on `[0,1]`. Its `n`-th iterate is `x/2^n`; for every positive `n`, equality with `x` forces `x=0`. Thus its periodic-point set is the singleton `{0}`, which is not dense. This counterexample and its non-density are proved exactly in `Catalog/Tropical/DejaVuDynamics/PeriodicPoints.lean`.

The numerical period-three attraction also exposes a definitional problem in comparing periodic-point “density” with 70% lifetime incidence. A countable periodic-point set has Lebesgue measure zero even when it is topologically dense. Incidence among people is a probability over persons and observation histories, not a natural density of points in an uncountable interval.

## Sequence and database search

No integer sequence naturally arises from the central statements, so an OEIS search would not supply relevant evidence. The investigation concerns real iterates, topology, and invariant measures rather than an integer sequence. LMFDB data are likewise not germane.

## Interpretation

The calculations support studying the local period-three window near `r=3.83`, but they do not support calibrating `r` directly from a 70% incidence statistic. Such calibration requires a probability measure on initial states, a distribution of parameters across subjects, a finite observation horizon, and a detection rule for approximate recurrence.
