# Computational Evidence

## Small-case calculations

Write `a = ⌊L/2⌋`. A cycle in the clique–independent-set join determines a cyclic binary word, with `C` for a core vertex and `P` for a peripheral vertex. Without an exceptional peripheral edge, `PP` is forbidden. Thus a word with `c` core and `p` peripheral positions satisfies `p ≤ c` and has length at most `2a`.

| `L` | `a` | exceptional peripheral edge | maximal pattern | length bound |
|---:|---:|:---:|:---|---:|
| 6 | 3 | no | `CPCPCP` | 6 |
| 7 | 3 | yes | `CPPCPCP` | 7 |
| 8 | 4 | no | `CPCPCPCP` | 8 |
| 9 | 4 | yes | `CPPCPCPCP` | 9 |
| 10 | 5 | no | `CPCPCPCPCP` | 10 |

These patterns attain the abstract charging bounds whenever enough distinct peripheral vertices are available.

## OEIS search results

No OEIS identification is needed: the principal sequence of circumference bounds is exactly `L`, and the relevant object is a two-parameter weighted cycle enumerator rather than a single canonical integer sequence.

## Counterexample hunt

The possible failure mode is a peripheral position whose successor is also peripheral. In the ordinary join this would require an edge inside the independent set and is impossible. With one added peripheral edge, at most one directed position in a simple cycle can initiate the exceptional transition. Deleting that position restores the injective charge into the core. The zero-core and empty-position boundary cases obey the same inequalities.

## Tables and structural checks

The table above checks both parity branches through `L=10`. It also shows sharpness of the additive correction: permitting one exceptional transition changes `p ≤ c` to `p ≤ c+1`, and consequently changes the length ceiling from `2a` to `2a+1`.
