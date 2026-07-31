# Computational evidence

## Target identity

For a finite simple graph with adjacency matrix `A`, degree diagonal `D`, and
all-ones vector `1`, the formal target is

`1ᵀ A D A 1 = Σ_v deg(v)^3`,

and `Σ_v deg(v)^3` counts ordered choices of a center vertex and three of its
neighbors (equivalently, homomorphisms from the three-leaf star).

## Small cases

| Graph | degree multiset | `Σ deg³` | ordered star choices |
|---|---:|---:|---:|
| one isolated vertex | `[0]` | 0 | 0 |
| one edge `K₂` | `[1,1]` | 2 | 2 |
| path `P₃` | `[1,2,1]` | 10 | 10 |
| triangle `K₃` | `[2,2,2]` | 24 | 24 |
| star `K₁,₃` | `[3,1,1,1]` | 30 | 30 |
| cycle `C₄` | `[2,2,2,2]` | 32 | 32 |

The equality is structural rather than an observed numerical coincidence: after
`A 1 = d`, diagonal multiplication gives `D d = d²`; symmetry gives
`1ᵀ A = dᵀ`; hence the scalar is `dᵀd² = Σ d³`.

## Counterexample hunt

The matrix identity requires symmetry. A non-symmetric directed matrix need not
satisfy it, because column sums replace row sums on the left. For undirected
simple graphs the adjacency matrix is symmetric, so no counterexample is
expected. The Lean proof establishes the universal finite symmetric-matrix
statement, which subsumes every finite simple graph.

## OEIS search

No single sequence is intrinsic here: the value depends on the selected family
of graphs. For complete graphs `K_n`, the values are `n(n-1)^3`; for cycles
`C_n`, they are `8n`. An OEIS identification is therefore unnecessary for the
universal identity and no ID is asserted.
