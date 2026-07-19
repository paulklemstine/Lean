# Computational Evidence

## Small-case calculations

For binary strings of length two, the Hamming-ball volume formula
\[
|B_D|=\sum_{i=0}^{D}\binom{2}{i}(2-1)^i
\]
gives the following table.

| Distortion radius \(D\) | Ball volume | Covering inequality |
|---:|---:|---:|
| 0 | 1 | \(4 \le R\) |
| 1 | 3 | \(4 \le 3R\) |
| 2 | 4 | \(4 \le 4R\) |

Thus a radius-one decoder needs at least two distinct records, while radius two permits a single record. The radius-one inequality is included as the proved concrete theorem `binary_pair_radius_one_rate_bound`.

For a directed network with two nodes observed at three times, there are
\(2^{3\cdot 2^2}=2^{12}=4096\) possible histories. Exact reconstruction therefore requires an observation alphabet of at least 4096 records, or at least 12 binary digits.

## Sequence identification

For binary length \(N\), the radius-\(D\) volume is the partial binomial sum
\(\sum_{i=0}^{D}\binom Ni\). No external sequence identification is needed: the closed formula is already the relevant invariant and is established by the imported Hamming-ball theorem.

## Counterexample hunt

The unguarded claim that perfect privacy always forbids bounded-error reconstruction is false. At distortion radius equal to the diameter, a constant observation and constant decoder reconstruct every state within budget. The surviving theorem therefore states the precise necessary condition: under perfect privacy, one distortion ball must cover the entire source space.

The claim that dynamic exact-reconstruction cost is always positive also fails at horizon zero or for a network with zero nodes. The exclusivity theorem consequently assumes at least one time and at least one node.

## Interpretation

These cases distinguish three regimes: exact reconstruction forces one record per source state; intermediate distortion produces a genuine covering constraint; and distortion at least the diameter makes perfect privacy compatible with reconstruction. The calculations are instances of the proved general volume and covering formulas rather than standalone numerical experiments.
