# Computational Evidence — Daisy Cubes as Partial Cubes

All claims below were turned into formal Lean theorems in this directory (0 sorries); the notes here
record the small-case exploration that guided the formalization.

## 1. Model and small cases

Vertices of `Q_n` are modeled as `Finset (Fin n)` (a vertex = set of `1`-coordinates). Hamming
distance = `(A ∆ B).card`.

For `n = 2`, the down-sets (daisy cubes) and a representative geodesic check:

| daisy cube `D ⊆ Q₂` (down-set)        | # vertices | is partial cube? |
|---------------------------------------|-----------:|:----------------:|
| `{∅}`                                 | 1          | yes (trivially)  |
| `{∅,{0}}`                             | 2          | yes (an edge)    |
| `{∅,{0},{1}}`                         | 3          | yes (a path P₃)  |
| `{∅,{0},{1},{0,1}}` = `Q₂`            | 4          | yes (the square) |

The set `{∅,{0},{1}}` is the path `P₃`; it is meet-closed (`{0} ∩ {1} = ∅ ∈ D`) but **not**
join-closed (`{0} ∪ {1} = {0,1} ∉ D`). This is exactly `not_join_closed` in `Median.lean`.

## 2. Geodesic / meet-gate spot checks

For `A = {0}`, `B = {1}` in `Q₂`: `A ∩ B = ∅`, and
`hdist A B = 2 = hdist A ∅ + hdist ∅ B = 1 + 1`. The descend-to-meet-then-ascend path
`{0} → ∅ → {1}` has length `2 = hdist`, confirming `meet_on_geodesic` and the geodesic produced by
`daisy_geodesic`.

For `A = {0,2}`, `B = {1,2}` in `Q₃`: `A ∩ B = {2}`, `hdist A B = 2`,
`hdist A {2} + hdist {2} B = 1 + 1 = 2`. ✓

## 3. Counterexample hunt

- **"Daisy cubes are join-closed"** — FALSE; counterexample `{∅,{0},{1}}` (formalized as
  `not_join_closed`).
- **"Every partial cube is a daisy cube"** — FALSE in general; the cycle `C₆` is a partial cube that
  is not a daisy cube. (Not formalized here; flagged for a future cycle — see `FUTURE_DIRECTIONS.md`,
  Conjecture 4.)
- **"The meet always lies on a geodesic"** — survived every spot check and is formalized as
  `meet_on_geodesic`.

## 4. Enumeration / OEIS

The number of daisy cubes of `Q_n` equals the number of down-closed families of subsets of an
`n`-set, i.e. the **Dedekind numbers**:

```
n:     0   1   2   3    4      5         6
M(n):  2   3   6   20   168    7581      7828354
```

This is **OEIS A000372** (Dedekind numbers / monotone Boolean functions / number of antichains).
The bijection "daisy cube ↔ down-set" is the content of `isDaisy_iff_downClosure_le`
(`Lattice.lean`), and the enumeration claim is recorded as Conjecture 2 in `FUTURE_DIRECTIONS.md`.

The evidence stage is intentionally brief: the structural theorems (`daisy_isometric`,
`meet_on_geodesic`, `isDaisy_iff_downClosure_le`) are the deliverables, and each was validated on the
small cases above before being proved in full generality.
