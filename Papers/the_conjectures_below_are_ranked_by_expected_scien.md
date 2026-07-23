# Computational Evidence: Arithmetic Coherence Deformations

## Small-case calculations

For prime conductor `p`, the cyclotomic character count is `φ(p)=p-1`.  Near the proposed
edge threshold `c=10000`, the resulting excess `max(φ(p)-c,0)` is:

| prime conductor `p` | character count `φ(p)` | excess above `10000` |
|---:|---:|---:|
| 9973 | 9972 | 0 |
| 10007 | 10006 | 6 |
| 10009 | 10008 | 8 |
| 10037 | 10036 | 36 |
| 10039 | 10038 | 38 |

Thus the tested prime instances agree with the exact cutoff `10001 < p`.  For power
responses, the first active excesses illustrate deformation without boundary motion: an
excess of `6` produces responses `6`, `√6`, and `36` for exponents `1`, `1/2`, and `2`,
respectively.

## OEIS search results

The prime-conductor count sequence is the shifted-prime sequence `p_n-1`; no OEIS lookup is
needed for the theorem because the argument uses the exact identity `φ(p)=p-1`, not sequence
recognition.  The unrestricted conductor sequence is Euler's totient function, OEIS A000010,
whose initial terms for `n=1,2,…` are
`1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, 12, 6, 8, 8`.

## Counterexample hunt

The abstract boundary claim fails if zero reflection is dropped: the continuous monotone
response `F(y)=0` vanishes at every positive excess, so activation cannot be recovered from
its zero set.  It also fails for `F(y)=max(y-1,0)`, which introduces a second dead zone.  These
examples confirm that the hypothesis `F(y)=0 ↔ y=0` on nonnegative inputs is load-bearing.

No counterexample can occur under the stated zero-reflection hypothesis: the accompanying
results reduce the response's zero set to the zero set of threshold excess and prove the
latter is exactly `x≤c`.

## Table interpretation

The table is illustrative rather than the proof of a finite range.  The general result is
symbolic: every prime conductor, every cyclotomic realization, and every zero-reflecting
response function share the same boundary.  The power-law rescaling result then changes the
response exponent while leaving that boundary fixed.
