# Computational Evidence

## Small-case calculations

An exhaustive subset search implemented the color-change rule directly: at each round, every
colored vertex with exactly one uncolored neighbor contributes that neighbor, and the process
stops at its fixed point. The search also exhaustively computed the independence number.

| Graph | vertices | edges | zero forcing number | independence number |
|---|---:|---:|---:|---:|
| Path P2 | 2 | 1 | 1 | 1 |
| Path P3 | 3 | 2 | 1 | 2 |
| Path P4 | 4 | 3 | 1 | 2 |
| Path P5 | 5 | 4 | 1 | 3 |
| Path P6 | 6 | 5 | 1 | 3 |
| Path P7 | 7 | 6 | 1 | 4 |
| Path P8 | 8 | 7 | 1 | 4 |
| Cycle C3 | 3 | 3 | 2 | 1 |
| Cycle C4 | 4 | 4 | 2 | 2 |
| Cycle C5 | 5 | 5 | 2 | 2 |
| Cycle C6 | 6 | 6 | 2 | 3 |
| Cycle C7 | 7 | 7 | 2 | 3 |
| Cycle C8 | 8 | 8 | 2 | 4 |
| Complete K4 | 4 | 6 | 3 | 1 |
| Complete K5 | 5 | 10 | 4 | 1 |
| Triangular prism | 6 | 9 | 3 | 2 |

The triangular prism is connected, claw-free, cubic, and satisfies `Z = α + 1`, matching the
exceptional graph `C3 □ K2` identified in the paper.

## Counterexample hunt

The universal inequality `Z(G) ≤ α(G)` fails on small claw-free cubic graphs: `K4` has
`Z(K4)=3` and `α(K4)=1`, while the triangular prism has `Z=3` and `α=2`. This confirms that
size thresholds and exceptional-family hypotheses cannot be omitted. Complete graphs also
show that no unrestricted comparison between zero forcing and independence is plausible.

The local growth conjecture survived all enumerated forcing processes: every legal force adds
one previously uncolored vertex. The weighted-harmonic propagation claim was tested on the
same graph families by solving the local neighbor-sum equations over small rational examples;
no violation occurred when every edge coefficient was nonzero. Allowing a zero coefficient on
the forced edge immediately invalidates the inference, supporting the theorem's nonzero-weight
boundary.

## Sequence search

The path values `1,1,1,1,1,1,1` and cycle values `2,2,2,2,2,2` over the displayed ranges are
standard constant families rather than a distinctive sequence requiring an OEIS identification.
The complete-graph values `n-1` are likewise elementary. No OEIS or LMFDB identifier is used.

## Tables and interpretation

The table exposes two complementary mechanisms. Sparse chains permit propagation from one or
two seeds, whereas dense graphs suppress legal moves until almost every vertex is colored.
Claw-free cubic graphs lie between these extremes; their triangle and diamond units provide the
local propagation channels formalized in the accompanying development.
