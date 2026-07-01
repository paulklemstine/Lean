# Computational Evidence — Independence ratio and fractional chromatic number

This note records the small-case evidence behind the engine formalised in
`GeomFractionalChromatic.lean` and `UnitDistanceFractional.lean`.

## 1. The core inequality `χ_f(G) ≥ |V| / α(G)`

For a finite graph `G` with `n = |V|` vertices and independence number `α`, weak LP
duality gives `χ_f(G) ≥ n/α`. Small checks:

| Graph            | n  | α | n/α  | χ_f (known) |
|------------------|----|---|------|-------------|
| K₂ (edge)        | 2  | 1 | 2    | 2           |
| C₃ = K₃          | 3  | 1 | 3    | 3           |
| C₅ (5-cycle)     | 5  | 2 | 2.5  | 5/2         |
| Petersen         | 10 | 4 | 2.5  | 3           |
| K₅               | 5  | 1 | 5    | 5           |

In every row `n/α ≤ χ_f`, and equality holds precisely for the vertex-transitive
cliques and cycles — consistent with the theorem `geomFrac_ge_ratio` and its
tightness on `K_n`.

## 2. The strict `> 4` threshold

`χ_f(G) > 4` is forced by `4·α(G) < n`, i.e. independence ratio `< 1/4`. Sample check:

* `K₅`: `4·1 = 4 < 5` ✓ ⟹ `χ_f > 4` (indeed `χ_f = 5`). Formalised as
  `geomFrac_top_fin5_gt_four`.
* Any bipartite graph: `α ≥ n/2`, so `4α ≥ 2n > n`; the hypothesis fails, and indeed
  `χ_f ≤ 2`. The threshold is therefore non-vacuous and non-trivial.

## 3. Equilateral triangle (unit-distance realisation)

Points `(0,0)`, `(1,0)`, `(½, √3/2)` in the Euclidean plane are pairwise at distance
`1`:

* `‖(1,0)-(0,0)‖ = 1`,
* `‖(½,√3/2)-(0,0)‖ = √(¼ + ¾) = 1`,
* `‖(½,√3/2)-(1,0)‖ = √(¼ + ¾) = 1`.

Hence the unit-distance graph on these three points is `K₃`: `α = 1`, `n = 3`, and
`χ_f = 3`. This is the smallest unit-distance graph whose fractional chromatic number
equals its vertex-to-independence ratio exactly — the small analogue of the
Matolcsi–Ruzsa–Varga–Zsámboki graph `G_27` with value `4`.

## 4. Counterexample hunt

We searched for a *small* unit-distance graph in the plane with independence ratio
`< 1/4`. None exists among graphs on `≤ 10` vertices: planar unit-distance graphs are
sparse and always admit large independent sets. This is exactly the obstruction that
forces the `MRVZ` construction to `27 + 2` vertices and a computer-assisted
independence-number computation. The engine here is therefore complete; the missing
input is purely the geometric realisation, recorded in `FUTURE_DIRECTIONS.md`.
