# Computational Evidence

## Small cases

For an alphabet of size `A` and length `L`, direct enumeration predicts `A^L` books:

| `A` | `L` | number of books |
|---:|---:|---:|
| 2 | 1 | 2 |
| 2 | 2 | 4 |
| 2 | 3 | 8 |
| 3 | 2 | 9 |
| 4 | 3 | 64 |

For binary length `L = 4`, a decoder with only `2^(4-2) = 4` descriptions can name at most 4 of the 16 books, leaving at least 12 incompressible. The proved factorization gives `12 = (2^2 - 1) * 2^(4-2)`.

For binary length `L = 8`, the guaranteed numbers missed by decoders with deficiency `c` are:

| `c` | descriptions `2^(L-c)` | all books | guaranteed missed |
|---:|---:|---:|---:|
| 1 | 128 | 256 | 128 |
| 2 | 64 | 256 | 192 |
| 3 | 32 | 256 | 224 |
| 4 | 16 | 256 | 240 |

## OEIS

For fixed alphabet size `A`, the library sizes as `L` varies are the geometric sequence `A^L`. For `A = 2` these are the powers of two (OEIS A000079): `1, 2, 4, 8, 16, 32, ...`.

## Counterexample hunt

The universal connectedness claim fails already at `A = 2`, `L = 1`: the books `0` and `1` are distinct isolated points. More generally, whenever `2 ≤ A` and `0 < L`, the all-zero and all-one books are explicit distinct isolated points. This counterexample pattern is formalized for all such `A` and `L` in `BorgesLibrary.hamming_not_connected`.

The apparent contradiction comes from confusing two structures. The Hamming *graph* can be path-connected by single-character edits, but the finite metric topology is discrete and therefore not topologically connected when it has more than one point.
