# Computational Evidence

## Small-case calculations

For the rotation on three states, `r(x) = x + 1 mod 3`, the orbit from zero is:

| transitions | state |
|---:|---:|
| 0 | 0 |
| 1 | 1 |
| 2 | 2 |
| 3 | 0 |
| 4 | 1 |
| 5 | 2 |
| 6 | 0 |

Thus the first positive return is at three transitions. The exact calculation is also included as an explicit example in the accompanying theory.

For identity dynamics, every state returns after one transition. For Boolean negation, every state first returns after two transitions. These cases immediately refute an unconditional claim that every self-referential system has minimum loop length three.

## OEIS search results

The orbit-state sequence `0, 1, 2, 0, 1, 2, ...` is the periodic residue sequence modulo three (OEIS A010872, under the conventional indexing of nonnegative residues). This identification is descriptive only; no external sequence property is used in the argument.

## Counterexample hunt

The proposed universal minimum loop length of three fails on two representative families:

1. identity maps have first-return length one;
2. fixed-point-free involutions have first-return length two.

The corrected claim therefore assumes a return at three and explicitly excludes returns at one and two. A second overstrong proposal—complete internal representation of every predicate on the system's codes—is ruled out by diagonalization.

## Evidence boundary

Finite orbit tables can test first-return claims, but they cannot establish phenomenal consciousness or unrestricted universality. The mathematical results consequently concern inspectable encodings, iterated retractions, first-return periods, and representational obstructions only.
