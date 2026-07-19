# Computational Evidence

The final result is an exact linear-algebra identity rather than an unproved numerical conjecture. Small cases nevertheless clarify its content. Write `c = dim C₁`, `a = rank d₁`, `b = rank d₂`, and `β = dim H`. The chain condition forces `a + b ≤ c`, and the proved formula gives `β = c - a - b`.

| `c` | `a` | `b` | `β` |
|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 1 | 0 | 0 |
| 2 | 0 | 0 | 2 |
| 2 | 1 | 0 | 1 |
| 2 | 0 | 1 | 1 |
| 2 | 1 | 1 | 0 |
| 3 | 1 | 1 | 1 |
| 4 | 2 | 1 | 1 |
| 4 | 2 | 2 | 0 |

These are exhaustive at the level of feasible rank triples for `c ≤ 2`. No counterexample exists: `NeuralHodge.betti_rank_formula` proves the formula for every finite-dimensional middle chain group over every field, while `homology_nonzero_iff_rank_sum_lt` and `homology_zero_iff_rank_sum_eq` prove the corresponding strict and equality tests.

There is no associated integer sequence requiring an OEIS search. The values are determined by the three independent rank parameters rather than by one natural-number index.

A computational sweep would add little assurance beyond kernel checking here: once the chain condition is supplied, the proof reduces the claim to quotient dimension and rank-nullity. The table is therefore illustrative rather than the source of verification.
