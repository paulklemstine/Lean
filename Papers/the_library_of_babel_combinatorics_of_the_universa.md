# Computational Evidence

## Small-case calculations

For an alphabet of size `q` and fixed volume length `n`, direct enumeration gives `q^n` volumes. Representative cases are:

| `q` | `n` | volumes `q^n` | address bits `ceil(log₂(q^n))` |
|---:|---:|---:|---:|
| 2 | 3 | 8 | 3 |
| 3 | 2 | 9 | 4 |
| 4 | 4 | 256 | 8 |
| 4 | 16 | 4,294,967,296 | 32 |

The mini-library therefore has exactly `2^32` volumes. A single exact target has probability `1/2^32` under uniform sampling.

For a library with `m` volumes, the space of complete address tables has `m^m` members. Distributed storage in `N` volumes has `m^N` states. For `m ≥ 2`, exhaustive comparison in the small cases confirms that `m^N < m^m` exactly when `N < m`, matching the proved threshold.

## OEIS search results

No OEIS lookup is needed for the principal sequence: for fixed alphabet size `q`, the volume counts are the elementary geometric sequence `q^n`. The cyclic de Bruijn edge count is likewise `q^n`; no sequence identification is used in the results.

## Counterexample hunt

The proposed heuristic that proof probability is determined by theorem length and a complexity exponent cannot be tested without fixing an encoding, parser, kernel, environmental declarations, and an acceptance predicate. Two checkers over the same volume space may accept different numbers of texts, including zero, one, or many. This motivates the exact checker theorem, which exposes the accepted-set cardinality explicitly.

The claim that one volume contains a complete arbitrary address table fails by cardinality as soon as the library has at least two volumes. The boundary cases are necessary: a zero- or one-volume library does not satisfy the strict growth argument.

## Table interpretation

The numerical mini-library catalog is a lossless bijective index into 32-bit addresses. It does not by itself assert cyclic overlap, constant-time inverse lookup, or a polynomial-time de Bruijn construction; those stronger algorithmic requirements are separated as future conjectures.
