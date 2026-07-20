# Computational Evidence

## Small-case calculations

The three-theorem corpus

| document | cited theorems |
|---|---|
| A | `{0,1}` |
| B | `{0,2}` |
| C | `{1,2}` |

has all three pairwise co-citation edges. Its pairwise graph is therefore the complete graph on three vertices, whose clique complex contains the triangle `{0,1,2}`. The corpus complex itself contains only the empty face, three vertices, and three edges: no document witnesses the triple. Thus pairwise projection introduces one spurious two-simplex.

For a corpus on `n` theorems, direct enumeration gives the following universal ceilings for the number of potential `k`-simplices:

| `n` | vertices | edges | triangles | tetrahedra |
|---:|---:|---:|---:|---:|
| 1 | 1 | 0 | 0 | 0 |
| 2 | 2 | 1 | 0 | 0 |
| 3 | 3 | 3 | 1 | 0 |
| 4 | 4 | 6 | 4 | 1 |
| 5 | 5 | 10 | 10 | 5 |
| 6 | 6 | 15 | 20 | 15 |

These are the binomial coefficients `n choose (k+1)`. Since homology is a quotient of a subspace of the corresponding chain space, every Betti number is bounded by the entry in the relevant column.

## Counterexample hunt

The universal claim `β_k ≈ n^(k+1)` fails without additional quantifiers and a corpus model.

* If `k ≥ n`, there are no `(k+1)`-vertex faces, so `β_k = 0`, while `n^(k+1) > 0` for every nonempty corpus.
* A corpus consisting of one document containing every theorem generates a full simplex. It has the maximal possible face count but no positive-dimensional homology, showing that simplex abundance alone does not force large Betti numbers.
* The three-theorem example above shows that replacing genuine multiway co-citation by pairwise clique completion can change higher-dimensional topology.

The accompanying results establish these obstructions symbolically for every finite theorem type; the table is illustrative rather than the basis of the conclusions.

## Sequence search

The face ceilings are the rows of Pascal's triangle. No separate sequence identification is needed: the exact formula is the standard binomial coefficient `n choose (k+1)`.

## Interpretation boundary

No calculation on an unlabeled incidence complex can by itself establish that a first-homology class is a “school of mathematics” or that a second-homology class is a “paradigm shift.” Those are hypotheses relating topology to external semantic or temporal labels and require a labeled data set and a statistical validation protocol.
