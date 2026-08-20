# Computational Evidence

Model (from `Catalog/Shared/TheoremNetworkTopology.lean`): a *corpus* `C` on a finite set
`V` of `n` theorems is a finite family of documents `W ⊆ V`; its *co-citation complex* is
the downward closure of `C`; `facesOfCard C q` are the faces with exactly `q` vertices.

New parameter introduced in this cycle: the **document-size bound** `d`
(`BoundedCorpus C d : ∀ W ∈ C, W.card ≤ d`), and the **design corpus**
`skeletonCorpus V d = powersetCard d univ` (every `d`-set of theorems is a document),
whose complex is the `(d-1)`-skeleton of the simplex on `V`.

All numbers below were produced inside Lean (`#eval`) against the actual definitions in
`Catalog/Geometry/CorpusBettiExtremal.lean`.

## 1. Euler characteristics of the design complexes

`χ(n, d) = ∑_{q < d} (-1)^q · C(n, q+1)` — the alternating face count of the `(d-1)`-skeleton
of the simplex on `n` theorems (this is exactly `eulerChar (skeletonCorpus V d)`).

| n \ d | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| 0 | 0 | | | | | | |
| 1 | 0 | 1 | | | | | |
| 2 | 0 | 2 | 1 | | | | |
| 3 | 0 | 3 | 0 | 1 | | | |
| 4 | 0 | 4 | -2 | 2 | 1 | | |
| 5 | 0 | 5 | -5 | 5 | 0 | 1 | |
| 6 | 0 | 6 | -9 | 11 | -4 | 2 | 1 |

Every entry matches the closed form `χ(n, d) = 1 - (-1)^d · C(n-1, d)`, which is proved as
`CorpusBettiExtremal.eulerChar_skeletonCorpus`.  Sanity checks:

* `d = n` gives `χ = 1` (the full simplex is contractible), agreeing with the earlier
  catalogue result `euler_char_top`.
* `d = 1` gives `χ = n` (`n` isolated theorems).
* `d = 2, n = 3` gives `χ = 0` (a circle), the three-theorem boundary corpus.

## 2. The predicted top Betti number

The classical value for the `(d-1)`-skeleton is `β_{d-1} = C(n-1, d)`.  For `d = 3`:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| `C(n-1, 3)` | 0 | 0 | 0 | 0 | 1 | 4 | 10 | 20 |

These are the tetrahedral numbers `C(n-1,3)` (OEIS A000292 shifted), i.e. growth of order
`n^3 = n^{(k+1)}` with `k = d - 1 = 2`.  This is the growth rate that the file proves must
occur, via the Euler characteristic, for *some* dimension `< d`.

## 3. Counterexample hunt: is the three-theorem corpus the only obstruction?

The programme statement suggested that "pairwise compatibility without a global witness" is
*one* exact obstruction.  We searched the design family `skeletonCorpus (Fin (m+1)) m` for
`m = 2, 3, 4`:

| m | n = m+1 | two-section | cliques of size ≤ m with a witness | cliques of size m+1 with a witness |
|---|---|---|---|---|
| 2 | 3 | complete `K₃` | all | none (1 such clique) |
| 3 | 4 | complete `K₄` | all | none (1 such clique) |
| 4 | 5 | complete `K₅` | all | none (1 such clique) |

So a counterexample to the "single obstruction" reading exists at *every* level: local
conformality up to level `m` never implies conformality.  This is formalised as
`CorpusConformalityHierarchy.strict_hierarchy_of_local_conformality`, and the identification
of the `m = 2` case with the catalogued corpus `triangleBoundaryCorpus` is checked by
kernel evaluation in `skeletonCorpus_two_eq_triangleBoundary`.

## 4. Symmetry of the design corpus (label identifiability)

Applying an arbitrary permutation of the `n` theorems to every document of
`skeletonCorpus V d` permutes the family of all `d`-sets onto itself, so the corpus is fixed
by the whole symmetric group.  For `d = 2` and `n = 3, 4, 5` the realised first Betti number
is `C(n-1, 2) = 1, 3, 6`: the witness used for the non-identifiability theorem carries
nontrivial first homology at every one of these sizes, so the failure of label recovery is
not an artefact of a topologically trivial example.

## 5. Document budget versus binomial ceiling

For a `d`-bounded corpus with `M` documents the face count in size `q` is at most
`M · C(d, q)`, against the ambient ceiling `C(n, q)`.  For `d = q = 2` the budget is just `M`:

| n | ceiling `C(n,2)` | budget with `M = n` |
|---|---|---|
| 4 | 6 | 4 |
| 5 | 10 | 5 |
| 6 | 15 | 6 |
| 10 | 45 | 10 |
| 20 | 190 | 20 |

The budget is below the ceiling from `n = 4` onwards, which is exactly the hypothesis range
of `sparse_betti_one_lt_ceiling`; for `n = 3` the two coincide (`3 = 3`), so `n ≥ 4` is sharp.

## 6. Extremal face counts

For `q ≤ d ≤ n`, `#facesOfCard (skeletonCorpus V d) q = C(n, q)`, i.e. the design attains the
universal binomial ceiling from the previous cycle in every dimension it supports, and has
no faces at all above dimension `d - 1`.  For `n = 6, d = 3` the `f`-vector is
`(1, 6, 15, 20, 0, 0, 0)`, whose alternating sum `-1 + 6 - 15 + 20 = 10` reproduces the
reduced Euler characteristic `(-1)^{d-1} C(n-1,d) = C(5,3) = 10`.
