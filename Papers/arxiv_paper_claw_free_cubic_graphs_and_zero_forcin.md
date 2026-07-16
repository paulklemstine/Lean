# Computational evidence

## Small cases

The complete-graph theorem in `ClawFreeCubicZeroForcing.lean` specializes to the following values:

| graph | vertices | zero forcing number |
|---|---:|---:|
| `K₂` | 2 | 1 |
| `K₃` | 3 | 2 |
| `K₄` | 4 | 3 |
| `K₅` | 5 | 4 |

These entries are consequences of the machine-checked general theorem `zeroForcingNumber_complete`, rather than an external script. The mechanism is that a force in a complete graph is possible only when precisely one vertex remains uncolored.

A second small-case sanity check concerns one forcing move: its target is `insert w S` with `w ∉ S`, so its cardinality is exactly `|S| + 1`. This is machine-checked by `card_forceStep` and lifted to monotonicity of arbitrary finite forcing sequences.

## OEIS search

The complete-graph values form `1, 2, 3, 4, …` for `K₂, K₃, K₄, K₅, …`. No OEIS identifier is recorded because this elementary shifted identity sequence does not provide useful evidence for the graph-theoretic claims.

## Counterexample hunt

No separate exhaustive graph enumeration was performed. The universal claims included in the Lean file are proved symbolically. In particular, the local structural claim was checked at the level of its hypotheses: three distinct neighbors of a vertex in a claw-free graph cannot be pairwise nonadjacent, hence some two form a triangle with the vertex.

The paper’s sharper contraction-multigraph bound and equality characterization were not tested or claimed in this phase.

## Table summary

| checked property | scope | outcome |
|---|---|---|
| one legal move adds one vertex | arbitrary finite set | proved |
| forcing reachability is monotone | arbitrary finite sequence | proved |
| forcing reachability is antisymmetric | arbitrary finite sequence | proved |
| `Z(Kₙ) = n - 1` | finite nontrivial complete graphs | proved |
| every vertex lies in a triangle | claw-free cubic graphs | proved |
| `Z(G) ≤ |V| - 1` | finite claw-free cubic graphs with a supplied vertex | proved |
