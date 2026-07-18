# Computational evidence

## Small-case calculations

The proposal maps digit `d` to pitch offset `d` semitones, for `d ∈ {0,…,9}`. The complete possible pitch-offset range is therefore:

| digit | offset (semitones) |
|---:|---:|
| 0 | 0 |
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 4 |
| 5 | 5 |
| 6 | 6 |
| 7 | 7 |
| 8 | 8 |
| 9 | 9 |

The largest possible pairwise distance is `|9 - 0| = 9`, below an octave's 12 semitones. Exhausting all 100 ordered digit pairs therefore yields zero octave-separated pairs. This finite structural calculation is proved generally in the accompanying Lean file rather than accepted as an unchecked computation.

For the displayed start of π, `3,1,4,1,5,9,2,6,5,…`, adjacent absolute pitch intervals begin `2,3,3,4,4,7,4,1,…`. These illustrate pitch intervals; they are distinct from temporal autocorrelation lags.

## OEIS search results

No OEIS search is pertinent to the proved theorem: it concerns the fixed finite image `{0,…,9}` of the digit-to-pitch map, not a newly identified integer sequence. No OEIS identification is claimed.

## Counterexample hunt

The interpretation “a digit match at temporal lag 12 is an octave relation” has immediate counterexamples. The constant-zero stream matches at every temporal lag, including 12, but both compared notes have pitch offset 0 and hence form a unison. This counterexample is formalized as `temporal_lag_twelve_does_not_mean_octave`.

More strongly, no decimal-digit stream can ever produce an exact octave-separated pair under the stated mapping, because all pitch distances are at most 9. Thus the issue is not special to π or to a chosen sample size.

## Tables and statistical scope

A chi-squared or autocorrelation table for π, e, and √2 cannot be reproduced from the mission statement alone: it does not specify the number of digits, the exact autocorrelation estimator, centering/normalization, or a multiple-testing protocol. Supplying arbitrary choices would test a new hypothesis rather than the stated one. The formal work therefore first resolves the model-level mismatch that is independent of data.
