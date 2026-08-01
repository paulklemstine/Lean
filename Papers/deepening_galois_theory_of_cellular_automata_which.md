# Computational evidence: reversible elementary cellular automata

## Small cases

The exhaustive finite statement formalized in
`Catalog/Novelty/ReversibleElementary.lean` checks all 256 Wolfram rules on cyclic
configuration spaces of lengths 1, 2, 3, and 4. The rules surviving all four
bijectivity tests are exactly:

| cycle lengths tested | surviving Wolfram rules |
|---|---|
| 1, 2, 3, 4 | 15, 51, 85, 170, 204, 240 |

This calculation is kernel-checked by `reversible_small_cycles_iff`; it enumerates
all `Fin 256` rules and decides bijectivity on each finite configuration space.
The structural theorem `six_rules_universally_reversible` then proves that every
survivor is reversible on every nonempty finite cycle.

## OEIS search

No OEIS search is applicable: the central output is a finite classification of
256 Boolean local rules, not a naturally indexed integer sequence.

## Counterexample hunt

The exhaustive search supplies a counterexample to universal reversibility for
every rule outside the six-element list. The theorem `short_period_obstruction`
certifies that each excluded rule fails reversibility on at least one cycle of
length at most four. Thus no sampled or unverified counterexample is used.

## Generalization tested formally

The new alphabet-independent theorem does not require finite computation. It
constructs an explicit inverse whenever a radius-one rule reads one coordinate
and applies an alphabet permutation. The three inverse forms are:

| coordinate read | inverse site movement | alphabet operation |
|---|---|---|
| left | right shift | inverse permutation |
| center | none | inverse permutation |
| right | left shift | inverse permutation |
