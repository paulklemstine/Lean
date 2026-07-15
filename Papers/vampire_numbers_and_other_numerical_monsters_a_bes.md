# Computational evidence

## Small cases

The Lean theorem `first_seven_vampire_witnesses` checks the following products and exact decimal digit-multiset equalities:

| vampire | fangs | residues modulo 9 |
|---:|---:|---:|
| 1260 | 21 × 60 | (3, 6) |
| 1395 | 15 × 93 | (6, 3) |
| 1435 | 35 × 41 | (8, 5) |
| 1530 | 30 × 51 | (3, 6) |
| 1827 | 21 × 87 | (3, 6) |
| 2187 | 27 × 81 | (0, 0) |
| 6880 | 80 × 86 | (8, 5) |

All rows fall in the six residue pairs proved by `vampire_fangs_residue_sieve`.

## OEIS

The standard vampire-number sequence is OEIS A014575. Its initial terms agree with the seven values certified here: 1260, 1395, 1435, 1530, 1827, 2187, 6880.

## Counterexample hunt

For the proved modular claim, exhaustive reduction modulo 9 leaves exactly

`(0,0), (2,2), (3,6), (5,8), (6,3), (8,5)`.

This exhaustive finite step is incorporated into the Lean proof, rather than being left as an external computation. No counterexample exists under the formal `VampireWitness` hypotheses.

The asymptotic density claim and the claims about werewolf, ghost, and zombie numbers were not tested here: their informal definitions are ambiguous (especially “share exactly one digit” and the contradictory zombie description), and a reliable enumeration up to 10^8 would require fixing those conventions first.

## Residue table

The six valid pairs occupy 6 of the 81 ordered residue pairs modulo 9, so the theorem supplies a factor-pair prefilter rejecting 75 residue pairs before any decimal multiset comparison.
