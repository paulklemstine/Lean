# Computational evidence

The formalized claims are structural bijection and cardinality theorems rather than a new numerical conjecture. Small cases nevertheless give useful sanity checks.

| `m` | `n` | grid points `m*n` | positions on each weft line | positions on each warp line |
|---:|---:|---:|---:|---:|
| 1 | 1 | 1 | 1 | 1 |
| 2 | 2 | 4 | 2 | 2 |
| 2 | 3 | 6 | 3 | 2 |
| 3 | 4 | 12 | 4 | 3 |
| 4 | 5 | 20 | 5 | 4 |

For every listed size, the coordinate matrices `horizontal(i,j)=i` and `vertical(i,j)=j` pair each grid position with itself. Thus their joint map is bijective; each fixed column contains every horizontal symbol once, and each fixed row contains every vertical symbol once. `coordinateCooperativePair` proves this uniformly in Lean, not merely for the table.

A counterexample hunt focused on omitted hypotheses. Orthogonality alone forces every pair `(q,r)` to occur exactly once. If orthogonality is dropped, constant matrices on a grid of size greater than one fail both uniqueness and the `m*n` representation property. If one index type is empty, no cross-coordinate bijection is available; accordingly, the cardinality theorems require chosen family indices `u` and `v`.

No OEIS search is relevant: the only sequence exposed by this layer is the elementary rectangular grid cardinality `m*n`, not a one-variable enumeration sequence. Enumeration of isomorphism classes of reticulations would become appropriate only after formalizing repetition-freeness and isotopy.
