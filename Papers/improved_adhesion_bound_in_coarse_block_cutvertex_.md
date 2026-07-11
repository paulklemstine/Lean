# Computational Evidence — chain accumulation and adhesion diameters

The formal target of this cycle is the metric core: the bounded-diameter **chain estimate**
`dist u v ≤ (n+1)·D + n` and the adhesion-diameter domination `adhesion ⊆ bag`. Both are
finite metric statements, so small-case checks are informative.

## 1. Chain accumulation on the path graph

Take the path `P_m` with vertices `0,1,…,m-1` and unit edge distances. Cover it with sliding
windows `S_i = {iΔ, iΔ+1, …, iΔ+D}` of diameter `D`, offset by `Δ ≤ D` so that consecutive
windows overlap.

| D | Δ | chain length n | true `dist(first, last)` | bound `(n+1)·D + n` |
|---|---|----------------|--------------------------|---------------------|
| 2 | 2 | 1 | 4  | 5  |
| 2 | 2 | 2 | 6  | 8  |
| 2 | 1 | 3 | 5  | 11 |
| 3 | 3 | 2 | 9  | 11 |
| 3 | 2 | 4 | 11 | 19 |

In every row the true distance is below the bound, with the gap growing as the offset `Δ`
drops below `D` (more overlap ⇒ more slack). The bound is tight in the *slope* when
`Δ = D` (maximal offset), matching Future Direction 3.

## 2. Adhesion diameter vs. bag diameter

For any two bags `B_i, B_j`, the adhesion `B_i ∩ B_j` is a subset of each, so its diameter is
at most `min(diam B_i, diam B_j)`. Sampling random pairs of intervals on `P_20` confirms the
domination `diam(adhesion) ≤ diam(bag)` with no exceptions, as the containment forces.

## 3. The `4d+2` regime

Setting bag diameter `= 2d+1`, the adhesion diameter is at most `2d+1 ≤ 4d+2` for every `d`:

| d | bag diam `2d+1` | adhesion bound `4d+2` |
|---|-----------------|-----------------------|
| 0 | 1 | 2 |
| 1 | 3 | 6 |
| 2 | 5 | 10 |
| 3 | 7 | 14 |

The conditional `4d+2` bound therefore holds with room to spare on the metric side; the open
part of the conjecture is the *existence* of decompositions realising `(d, 2d+1)`-inseparable
bags, not the adhesion estimate itself.

## 4. Counterexample hunt

We searched for a chain of overlapping diameter-`D` sets violating `(n+1)·D + n` on all paths,
cycles, and small trees up to 12 vertices for `D ≤ 4`, `n ≤ 6`: **no counterexample found**,
consistent with the proved theorem. No OEIS sequence is associated (the quantities are the
explicit linear form `(n+1)D+n`).
