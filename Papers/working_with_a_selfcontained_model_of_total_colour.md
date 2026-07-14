# Computational evidence: the extremal regime `|V| = d + 2`

All computations below were carried out by exhaustive evaluation on the concrete
graphs and are reflected verbatim in the accompanying formal development
(`decide`/`fin_cases` on the cycle graphs).

## Regular cycles: extremality table

For the `n`-cycle `C_n` (which is `2`-regular for `n ≥ 3`), extremality means
`n = d + 2 = 4`. The complement degree is `n − 1 − d = n − 3`.

| `n` | `d` | `|V| = n` | `d + 2` | extremal? | complement degree `n−3` | complement `1`-regular? |
|-----|-----|-----------|---------|-----------|-------------------------|-------------------------|
| 4   | 2   | 4         | 4       | **yes**   | 1                       | **yes** (`= 2K₂`)       |
| 5   | 2   | 5         | 4       | no        | 2                       | no                      |
| 6   | 2   | 6         | 4       | no        | 3                       | no                      |

The table confirms the characterisation `|V| = d + 2 ⇔` complement is `1`-regular:
the unique extremal cycle is `C₄`, whose complement is a perfect matching (`2K₂`),
matching `cycleGraph_four_compl_one_regular`.

## Lower-bound comparison on cycles

For `C_n` the two lower bounds on `χ''ₐ(C(C_n))` are the `d`-bound `d + 3 = 5` and
the `|V|`-bound `n + 1`.

| `n` | `d`-bound `d+3` | `|V|`-bound `n+1` | dominating bound |
|-----|-----------------|-------------------|------------------|
| 4   | 5               | 5                 | equal (extremal) |
| 5   | 5               | 6                 | `|V|`-bound      |
| 6   | 5               | 7                 | `|V|`-bound      |

This is exactly `dbound_le_cardbound` (`d + 3 ≤ |V| + 1`) with equality iff
extremal (`bounds_agree_iff_extremal`), and the strict case `5 < 6` for `C₅` is
recorded as `cycle5_dbound_lt_cardbound`.

## Counterexample hunt

We tested the naive equality `χ''ₐ(C(G)) = d + 3` off the extremal family. `C₅`
(`d = 2`) has `|V| = 5 > 4`, forcing `χ''ₐ(C(C₅)) ≥ 6 > 5 = d + 3`; hence the naive
equality fails, and equality can hold at most on the extremal family — precisely
the boundary this cycle characterises. No counterexample to the characterisation
`|V| = d + 2 ⇔` complement `1`-regular was found; it is proved in general.

## OEIS

The cocktail-party graphs `K_{d+2}` minus a perfect matching form the family
`K_{n×2}` (complete multipartite with parts of size 2); their vertex counts
`2, 4, 6, 8, …` (the even numbers, OEIS A005843) index the extremal graphs by
`|V| = d + 2`.
