# Computational evidence

## Small-case calculations

`ComputationalEvidence.lean` defines an independent exhaustive enumerator for cardinal-step words and checks self-avoidance by testing that the visited vertices are pairwise distinct. Lean verifies:

| length `n` | `c_n` | `c_n^(1/n)` (decimal guide only) |
|---:|---:|---:|
| 0 | 1 | — |
| 1 | 4 | 4.000 |
| 2 | 12 | 3.464 |
| 3 | 36 | 3.302 |
| 4 | 100 | 3.162 |
| 5 | 284 | 3.095 |
| 6 | 780 | 3.034 |

The integer counts in this table are machine-checked in Lean. The decimal column is only a numerical guide and is not used in any proof.

## Sequence identification

The square-lattice self-avoiding-walk counts beginning
`1, 4, 12, 36, 100, 284, 780, 2172, 5916, ...`
are catalogued as OEIS A001411. The Lean artifact checks the prefix through `780`; the later displayed terms are included only to identify the sequence.

## Counterexample hunt

The proposed equality `μ = (2 + √2) / 2` is not merely unsupported by the samples: `Research.lean` proves it false. It proves `(2 + √2) / 2 < 2` and reuses the formal north/east-walk injection bound `2 ≤ μ`, yielding a strict inequality between the candidate and the square-lattice connective constant.

The nearby expression `√(2 + √2)` is the Nienhuis value for the hexagonal lattice, a different graph. `Research.lean` proves its principal algebraic identities and distinguishes it from the proposed expression.

## Interpretation

The finite-root estimates decrease toward the known numerical regime for the square lattice, but finite data do not determine the exact limit. The rigorous result of this project is the interval obstruction, not a numerical extrapolation.
