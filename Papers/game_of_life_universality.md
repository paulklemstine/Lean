# Computational evidence

## Small cases

The following are exploratory hand-calculation sanity checks, not formally verified numerical claims. Using the finite candidate-set algorithm defined in `FiniteSimulation.lean`, the expected first-generation population counts are:

| initial pattern | initial population | generation 1 | generation 2 |
|---|---:|---:|---:|
| empty | 0 | 0 | 0 |
| isolated live cell | 1 | 0 | 0 |
| 2×2 block | 4 | 4 | 4 |
| three-cell blinker | 3 | 3 | 3 |

These standard examples were used only as informal sanity checks for the B3/S23 definition. The formal result does not rely on them: `finite_simulation_correct_and_bounded` proves the generic finite-support simulation statement.

## OEIS search

No OEIS search is relevant. The formal object is a state transition system rather than a single canonical integer sequence.

## Counterexample hunt

The vulnerable point in a finite-support implementation is omission of births outside the current live set. The candidate region therefore includes every live cell and all eight of its neighbors. The proof `globalNext_mem_expansion` rules out such omitted births in general, rather than by bounded testing.

No counterexample was found among the small patterns above. This sentence records exploratory evidence only; the Lean theorem is the verification.

## Bounds table

The theorem proves the deliberately coarse population bound `|S_t| ≤ 9^t |S_0|`:

| t | multiplier `9^t` |
|---:|---:|
| 0 | 1 |
| 1 | 9 |
| 2 | 81 |
| 3 | 729 |
| 4 | 6561 |

The bound counts a cell and its eight candidate neighbors at every generation; overlaps and B3/S23 filtering can only reduce the actual population.
