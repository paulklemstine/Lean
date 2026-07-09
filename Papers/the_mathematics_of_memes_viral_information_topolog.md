# Computational Evidence — Viral Information Topology

We model a meme as a section of the **constant sheaf** `K` over a social network,
represented as a directed multigraph with vertex set `V` (people), edge set `E`
(channels), and endpoint maps `src, tgt : E → V`. The coboundary is

```
(δ f) e = f (tgt e) − f (src e),      δ : (V → K) → (E → K),
```

with cohomology `H⁰(δ) = ker δ` (global interpretations) and
`H¹(δ) = coker δ = (E → K) / range δ` (transmission barriers).

## 1. Small-case calculations (constant sheaf, connected graphs)

For a **connected** graph the theory predicts `dim H⁰ = 1` (one global
interpretation) and, by the Euler characteristic `dim H⁰ − dim H¹ = |V| − |E|`,

```
dim H¹ = |E| − |V| + 1   =   first Betti number   =   number of independent cycles.
```

| Graph                | \|V\| | \|E\| | dim H⁰ | dim H¹ = \|E\|−\|V\|+1 | interpretation                 |
|----------------------|:---:|:---:|:-----:|:---------------------:|--------------------------------|
| single edge `0–1`    |  2  |  1  |   1   |          0            | tree — universally transmissible |
| path `0–1–2`         |  3  |  2  |   1   |          0            | tree — universally transmissible |
| triangle `C₃`        |  3  |  3  |   1   |          1            | one cycle → one barrier        |
| square `C₄`          |  4  |  4  |   1   |          1            | one cycle → one barrier        |
| complete graph `K₄`  |  4  |  6  |   1   |          3            | three independent cycles       |
| `Kₙ`                 |  n  | n(n−1)/2 | 1 | (n−1)(n−2)/2         | cycle rank of `Kₙ`             |

The rows **path** (`dim H¹ = 0`) and **triangle** (`dim H¹ = 1`) are proved as
machine-checked theorems `MemeGraph.path_dimH1` and `MemeGraph.triangle_dimH1`
in `Catalog/MachineLearning/MemeGraphCohomology.lean`.

## 2. Sequence check (OEIS)

The cycle rank of the complete graph `Kₙ`, `1 + n(n−3)/2` for `n ≥ 1`
(`= (n−1)(n−2)/2`), gives `0, 0, 0, 1, 3, 6, 10, 15, …` — the triangular numbers
shifted, **OEIS A000217** (offset). Betti numbers of graphs are not a single
canonical OEIS entry because they depend on `|E|`; the point of the formula
`|E| − |V| + c` (with `c` = number of components) is that it is a purely
topological invariant, matching classical algebraic-graph-theory tables.

## 3. Counterexample hunt on the guiding conjecture

The brief conjectures "most viral ⟺ `H¹ = 0` and `dim H⁰` maximal". For the
**constant sheaf** the abstract identity forces, whenever `H¹ = 0` (δ surjective):

```
dim H⁰ = dim C⁰ − dim C¹   (theorem MemeSheaf.viral_interpretations)
```

so once transmissibility (`H¹ = 0`) holds, the number of interpretations is
*determined*, not free — and on a connected graph it collapses to `dim H⁰ = 1`.
Thus the naive reading "spread everywhere **and** many distinct meanings" is
**false for the constant sheaf**: connected transmissibility forces a *single*
global meaning. Distinct community meanings (`dim H⁰ > 1`) require either a
disconnected network or a genuinely non-constant sheaf (varying stalks /
restriction maps). This is recorded honestly:

* `MemeSheaf.dimH0_ge` — `dim H⁰ ≥ dim C⁰ − dim C¹` always.
* `MemeSheaf.dimH0_eq_floor_iff_surjective` — equality (minimum interpretations)
  is *equivalent* to transmissibility `H¹ = 0`.

No counterexample to the proved theorems was found; the exploration instead
sharpened the conjecture (see `FUTURE_DIRECTIONS.md`).

## 4. What is formally verified

Every entry above that is stated as a theorem builds with `#print axioms`
returning only `propext`, `Classical.choice`, `Quot.sound`. See
`Catalog/MachineLearning/MemeSheafCohomology.lean` (abstract core) and
`Catalog/MachineLearning/MemeGraphCohomology.lean` (graph instantiation +
concrete triangle/path computations).
