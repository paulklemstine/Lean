# Computational Evidence: Cyclic Digit-Melody Statistics

## Small-case calculations

The finite signal `s = [3,1,4,1,5]` has square energy

| statistic | value |
|---|---:|
| `∑ sᵢ²` | 52 |
| cyclic autocorrelation at lag 1 | 35 |
| squared interval energy at lag 1 | 34 |

These values satisfy `2·35 = 2·52 − 34`. The example illustrates the exact identity proved for every finite signal: high autocorrelation and low squared interval cost are equivalent descriptions of the same observation.

For the constant signal `[4,4,4,4]`, every lag has autocorrelation 64 and interval energy 0. For the alternating signal `[0,9,0,9]`, lag 2 also has autocorrelation 162 and interval energy 0. Thus maximal lag correlation detects cyclic repetition, not a privileged harmonic interval.

## Representative counterexample hunt

The proposed inference “irrationality implies positive autocorrelation at lag 12” fails at the level of logic: irrationality excludes eventual periodicity but imposes no known sign constraint on a finite-prefix statistic. Finite prefixes can be prescribed arbitrarily while retaining irrationality in the tail. Therefore no theorem about the sign or statistical significance of a fixed finite autocorrelation follows from irrationality alone.

The musical interpretation also mixes two different variables. A temporal lag of 12 compares digits twelve positions apart. An octave compares pitch values differing by twelve semitones. Since decimal digits range only from 0 through 9 under the stated map, no pair of mapped digits is separated by a full octave. Consequently, “autocorrelation at lag 12” does not count octave-separated notes.

## Sequence-database search

No sequence identification is needed for the deterministic polarization identity: it applies to every finite real signal rather than to one integer sequence. Claims specific to decimal digits of π, e, and √2 require an explicitly fixed prefix length, centering convention, null model, multiple-testing correction, and independently reproducible digit source before a sequence-database comparison is informative.

## Conclusions from the evidence

1. Cyclic autocorrelation is exactly total energy minus one half of squared interval energy.
2. Its maximum occurs precisely when the finite melody is invariant under the selected cyclic shift.
3. Irrationality alone does not predict finite autocorrelation signs.
4. Temporal displacement and musical pitch interval must be represented by separate statistics.
5. Any significance claim must specify sample size and test design; without them, the original numerical conjectures are not falsifiable.
