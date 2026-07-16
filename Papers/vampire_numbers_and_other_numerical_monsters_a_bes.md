# Computational Evidence

## Small cases

The existing exact digit witnesses establish the following first seven decimal vampire factorizations:

| Product | Fangs | Fang residues modulo 9 |
|---:|---:|---:|
| 1260 | 21 × 60 | (3, 6) |
| 1395 | 15 × 93 | (6, 3) |
| 1435 | 35 × 41 | (8, 5) |
| 1530 | 30 × 51 | (3, 6) |
| 1827 | 21 × 87 | (3, 6) |
| 2187 | 27 × 81 | (0, 0) |
| 6880 | 80 × 86 | (8, 5) |

Every pair belongs to the six-point unrestricted residue sieve
`(0,0), (2,2), (3,6), (5,8), (6,3), (8,5)`. None of these seven examples has two prime fangs.

The classical smallest witness is exact at the digit-multiset level:
`digits(21) + digits(60)` is a permutation of `digits(1260)`.

## Counterexample hunt and definitional audit

The proposed “zombie” description is inconsistent: it says both fangs are prime, but the supplied factorizations of `125460` use `204 × 615` and `246 × 510`, in each case two composite factors. The prime-fang interpretation was retained because it is the literal definition and leads to a falsifiable arithmetic class.

The claim that density “approaches `1/√n`” should be read as an asymptotic scale, since `1/√n` itself approaches zero. A precise conjecture needs a counting function, denominator, and leading constant.

No exhaustive enumeration up to `10^8` is reported here. Such a table would depend sensitively on resolving the ambiguous werewolf and zombie definitions, and an unchecked external computation would not support the universal theorems proved in this cycle.

## OEIS search

No OEIS identifier is asserted. The standard vampire-number sequence is widely tabulated, but no external sequence lookup was performed during this cycle, so assigning an identifier would risk an unsupported citation.

## Structural table for prime fangs

Intersecting the exact unrestricted residue sieve with primality leaves:

| `x mod 9` | `y mod 9` | `(x·y) mod 9` |
|---:|---:|---:|
| 2 | 2 | 4 |
| 5 | 8 | 4 |
| 8 | 5 | 4 |

Thus every decimal digit-permutation product with two prime fangs lies in the single residue class `4 mod 9`. This table is proved for all natural-number witnesses in `Catalog/Algebra/VampirePrimeFangSieve.lean`; it is not merely a bounded search observation.
