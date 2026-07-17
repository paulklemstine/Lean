# Computational evidence

## Small cases

The Lean theorem `first_seven_vampire_factorizations` checks the exact digit-multiset identities for these standard witnesses:

| product | fangs |
|---:|---:|
| 1260 | 21 × 60 |
| 1395 | 15 × 93 |
| 1435 | 35 × 41 |
| 1530 | 30 × 51 |
| 1827 | 21 × 87 |
| 2187 | 27 × 81 |
| 6880 | 80 × 86 |

These are kernel-checked finite certificates, not an exhaustive classification under a numerical bound.

## Sequence identification

The usual decimal vampire-number sequence is OEIS A014575. The initial terms above agree with its beginning. This note does not use the OEIS entry as a proof.

## Counterexample hunt

Rather than testing a finite sample for the main universal claim, the Lean development proves it for all bases and all fang pairs satisfying the exact digit permutation. The resulting decimal residue list is exhaustive: `(0,0)`, `(2,2)`, `(3,6)`, `(5,8)`, `(6,3)`, `(8,5)` modulo nine. Therefore any purported witness outside this table is a counterexample to its claimed digit-factorization certificate, not to the theorem.

The asymptotic density, ghost-density, and interval-existence claims were not computationally tested and are not asserted as established.
