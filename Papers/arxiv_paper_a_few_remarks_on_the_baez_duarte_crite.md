# Computational evidence for the finite Báez–Duarte transform

For the number-theoretic Möbius coefficients, define the cutoff quantity

\[
C_k(N)=\sum_{n=1}^N \frac{\mu(n)}{n^2}\left(1-\frac1{n^2}\right)^k.
\]

## Small-case calculations

Using `μ(1)=1`, `μ(2)=-1`, `μ(3)=-1`, and `μ(4)=0`, exact arithmetic at cutoff
`N=4` gives

| `k` | `C_k(4)` |
|---:|---:|
| 0 | `23/36` |
| 1 | `-371/1296` |
| 2 | `-10657/46656` |

For example, `C_0(4)=1-1/4-1/9=23/36`.  For positive `k`, the `n=1` geometric
mode vanishes, and
`C_1(4)=-(1/4)(3/4)-(1/9)(8/9)=-371/1296`.

## Counterexample hunt and boundary checks

The finite transform identity was checked symbolically: expanding
`(1-n⁻²)^k` by the binomial theorem reproduces the alternating moment sum term
by term.  Its edge cases behave correctly:

* `N=0`: both sides are empty sums.
* `k=0`: both sides are the cutoff reciprocal-square sum.
* `n=1`: the geometric mode is zero for positive `k`, while its binomial
  expansion is the alternating sum of a row of Pascal's triangle.

The positivity and antitonicity claims require pointwise nonnegative coefficient
functions.  They are deliberately not claimed for the signed Möbius function;
the negative values above demonstrate this boundary.

## OEIS search

No OEIS identification is asserted.  The values depend on the cutoff and are
approximants to an analytic sequence rather than a single integer sequence.

## Plots or further tables

No floating-point plot was used because the target results are exact finite
identities.  A useful future experiment would combine larger cutoffs with
rigorous truncation bounds before drawing conclusions about asymptotic decay.
