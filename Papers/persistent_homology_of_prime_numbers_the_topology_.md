# Computational evidence: primes up to 1,000,000

## Method

A sieve of Eratosthenes was used to enumerate the primes and their consecutive gaps. This section is exploratory evidence; the exact structural claims used in the formal result are proved in `Catalog/MachineLearning/PrimeRipsTopology.lean`.

## Small cases

The first six prime positions are

| prime | 2 | 3 | 5 | 7 | 11 | 13 |
|---:|---:|---:|---:|---:|---:|---:|
| following gap | 1 | 2 | 2 | 4 | 2 | — |

Thus the endpoints 2 and 13 first lie in one Rips-graph component at scale 4. This exact case is also machine-checked by `firstSixPrimes_endpoint_threshold`.

## Computation through 10^6

* Number of primes: 78,498.
* Number of consecutive gaps: 78,497.
* Mean gap: 12.7391.
* `log(10^6)`: 13.8155.
* Largest gap: 114, following 492,113.
* Gap quantiles (10%, 25%, 50%, 75%, 90%, 95%, 99%): 2, 6, 10, 18, 26, 32, 48.
* Most frequent gaps `(gap: count)`: 6: 13,549; 2: 8,169; 4: 8,143; 12: 8,005; 10: 7,079; 8: 5,569.

For the local window `[900000, 1000000]`, there are 7,224 primes and the mean gap is 13.8422, close to `log(950000) = 13.7642`.

## Exponential comparison and counterexample hunt

Comparing all gaps below `10^6` with an exponential CDF whose mean is the fitted mean gap gives a Kolmogorov--Smirnov distance of approximately 0.1678. The discrepancies are structural: except for the first gap, prime gaps are even, while a continuous exponential random variable is not lattice-supported; small gaps also show strong arithmetic modulation (gap 6 is much more frequent than gaps 2 or 4).

Consequently, the literal assertion that the finite `H₀` barcode *has the same distribution* as an inhomogeneous Poisson process is not supported. A suitably normalized asymptotic statistical conjecture would need a precise limiting regime and a discrete/arithmetic correction.

For ordinary Vietoris--Rips complexes, the proposed long-lived `H₁` twin-prime bar also fails at the deterministic geometric level: points lie on a line, and whenever an edge crosses an intermediate point, both shorter edges are present and the corresponding flag triangle is filled. The Lean theorem `ordered_edge_forces_triangle` certifies this obstruction.

## OEIS search

The prime-gap sequence begins `1, 2, 2, 4, 2, 4, 2, 4, 6, ...` and is OEIS A001223 (differences between consecutive primes). No OEIS identification is needed for the formal proofs.
