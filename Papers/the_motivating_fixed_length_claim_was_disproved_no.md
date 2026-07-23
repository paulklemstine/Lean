# Computational evidence: bounded truth tables and diagonal escape

## Small-case calculations

For an alphabet of size 2, the numbers of fixed-length statements are:

| length | statements | Boolean semantics |
|---:|---:|---:|
| 0 | 1 | 2 |
| 1 | 2 | 4 |
| 2 | 4 | 16 |
| 3 | 8 | 256 |
| 4 | 16 | 65,536 |

Thus even the semantics space grows doubly exponentially in the length, but each
individual semantics still has a finite truth table.

For the three possible oracle answers, the adversarial assignment is:

| answer | adversarial truth | correct? |
|---|---|---|
| yes | false | no |
| no | true | no |
| unknown | true | no |

A sample 3-by-3 Boolean table illustrates diagonal escape:

| row | coordinates 0,1,2 | diagonal bit | complemented bit |
|---:|:---:|:---:|:---:|
| 0 | 0,1,1 | 0 | 1 |
| 1 | 1,1,0 | 1 | 0 |
| 2 | 0,0,1 | 1 | 0 |

The diagonal complement is `1,0,0`; it differs from row 0 at coordinate 0,
from row 1 at coordinate 1, and from row 2 at coordinate 2.

## OEIS search results

The bounded-language cardinalities for a binary alphabet are the powers of two,
OEIS A000079: `1, 2, 4, 8, 16, 32, ...`.  The numbers of Boolean semantics are
`2^(2^n)`, OEIS A001146: `2, 4, 16, 256, 65536, ...`.

## Counterexample hunt

The motivating impossibility claim already fails at every finite size: choosing
the oracle to be the given truth table gives 100 percent accuracy.  Exhausting
the three answer constructors confirms that the adversarial semantics defeats
each answer pointwise, including abstention.  Testing square Boolean tables of
sizes 0 through 3 reveals no exception to diagonal non-surjectivity; size 0 is
handled because the source is empty while the Boolean function space contains
the unique empty function.

## Interpretation

The calculations distinguish scale from computability.  Enormous finite tables
remain exact finite tables.  The robust impossibility statements instead arise
from changing the quantifier order (one predictor against every semantics) or
from allowing an unbounded sequence space where diagonal escape applies.
