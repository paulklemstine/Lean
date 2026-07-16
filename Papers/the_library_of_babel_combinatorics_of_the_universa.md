# Computational evidence

## Small cases

For alphabet size `q` and book length `n`, direct enumeration predicts `q^n` books.

| `q` | `n` | number of books |
|---:|---:|---:|
| 2 | 1 | 2 |
| 2 | 2 | 4 |
| 2 | 3 | 8 |
| 3 | 2 | 9 |
| 4 | 4 | 256 |
| 4 | 16 | 4,294,967,296 |

A specified full book is represented once, so its uniform probability is the reciprocal of the table entry. For the mini-library this is `1 / 4,294,967,296`.

For a library of size `L`, the number of functions from books to books is `L^L`. Small cases show the cardinality gap used by the formal obstruction:

| `L` | catalog tables `L^L` |
|---:|---:|
| 2 | 4 |
| 3 | 27 |
| 4 | 256 |
| 5 | 3,125 |

## OEIS search

The fixed-alphabet counts as book length varies are geometric sequences `q^n`; no specialized OEIS identification is needed for the proof. For `q = 4`, the initial terms are `1, 4, 16, 64, 256, 1024, ...`.

## Counterexample hunt and specification checks

The informal claim that no single volume can encode “the catalog” is too strong if “the catalog” means one particular computable enumeration: the base-`q` decoder is a short description of a bijection between addresses and books. The sound counting statement is instead that no book-valued injective encoding can represent **all possible catalog tables**, because there are `L^L > L` such tables for `L ≥ 2`.

Likewise, an exact numerical probability of a “valid Lean 4 proof” cannot be computed from theorem name and alphabet size alone. It depends on a fixed encoding and a fixed decidable acceptance predicate. The formalization exposes that predicate and proves the exact ratio `accepted_count / q^n`.

No counterexample was found to the finite cardinality formulas. Boundary cases were checked conceptually: when `q^n` is 0 or 1, the strict catalog-table gap fails, which is why the theorem assumes `2 ≤ q^n`.

## De Bruijn comparison

A cyclic de Bruijn sequence of order 16 on four symbols has cyclic length `4^16 = 4,294,967,296`, one starting position for each length-16 word. The formal artifact currently verifies a base-four bijective catalog of exactly that many words; it does not claim to have formalized the cyclic overlap construction.
