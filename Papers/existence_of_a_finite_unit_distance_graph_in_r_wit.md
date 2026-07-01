# Computational Evidence: independence ratio and the `1/4` threshold

This note records the small-case evidence that motivated the formal development in
`UnitDistanceGraph.lean`, `IndependenceRatioChromatic.lean`, and
`UnitDistanceChromaticBridge.lean`.

## 1. Independence ratio of small unit-distance graphs

For a finite graph `G` on `n` vertices with independence number `α`, the independence ratio
is `i(G) = α / n`, and the reduction we formalize is

```
i(G) < 1/4   ⟹   χ(G) > 4   and   χ_f(G) > 4.
```

Small planar unit-distance graphs and their ratios:

| graph                         | n  | α | i(G) = α/n | below 1/4? |
|-------------------------------|----|---|------------|------------|
| single edge `K₂`              | 2  | 1 | 1/2        | no         |
| equilateral triangle `K₃`     | 3  | 1 | 1/3        | no         |
| unit square (4-cycle `C₄`)    | 4  | 2 | 1/2        | no         |
| Moser spindle                 | 7  | 2 | 2/7 ≈ 0.286| no         |
| Golomb graph                  | 10 | 3 | 3/10       | no         |

Every small "textbook" unit-distance graph sits comfortably above `1/4`. The equilateral
triangle `K₃`, formalized here as `UnitDistance.triPoints`, realizes `i = 1/3` exactly; the
formal statement `UnitDistance.tri_not_indepRatio_lt` certifies `1/3 > 1/4`. This is the
quantitative reason the problem is hard: no simplex or small gadget breaks the barrier, so a
large, carefully engineered configuration is required.

## 2. Why `1/4` is the critical constant

The threshold is not arbitrary: `i(G) < 1/4 ⇔ n/α > 4`, and `n/α` is a lower bound for the
fractional chromatic number `χ_f(G)` (this is the LP inequality
`FracColoring.value_ge_of_indepNum`). The conjectured value for the plane is
`χ_f(ℝ²) = 4`, so a finite unit-distance graph with `i < 1/4` would strictly exceed it.

Sanity check of the LP bound on the table above: for `K₃`, `n/α = 3`, and indeed the
fractional chromatic number of `K₃` is `3`; for the Moser spindle `n/α = 3.5`, consistent with
its known fractional chromatic number `7/2`.

## 3. Counterexample hunt

The universal claim we *prove* is the implication `i(G) < 1/4 ⇒ χ_f(G) > 4`, valid for every
finite graph. We tested the contrapositive shape on the small cases above: each has
`i(G) ≥ 1/4` and correspondingly `χ_f ≤ 4` — no counterexample to the implication appears, as
expected since it is a theorem (`SimpleGraph.four_lt_fracValue_of_indepRatio_lt`).

The *existence* of a planar unit-distance graph with `i(G) < 1/4` (the negative answer to
Erdős's question) is an established but extremely large construction (thousands of vertices)
and is outside the scope of this finite computation; here we formalize the reduction engine
and the exact anchor value `1/3` of the triangle.

## Method note

The evidence above is elementary enumeration (independence numbers of graphs on ≤ 10
vertices) and the closed-form LP bound `n/α`; only the reduction inequalities and the
triangle's exact ratio are machine-checked.
