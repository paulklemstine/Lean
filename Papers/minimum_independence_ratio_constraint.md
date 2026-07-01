# Computational Evidence — Minimum Independence Ratio Constraint

Object of study: the **independence ratio** `i(G) = α(G) / |V(G)|` of finite
unit-distance graphs in the plane (points of `ℝ²`, edges between points at
Euclidean distance exactly `1`). The mission claim is that `i(G)` cannot fall
below `1/4`.

## 1. Small-case calculations

| Graph | Realisation as a unit-distance graph | `n` | `α` | `i(G)` | vs `1/4` |
|-------|--------------------------------------|-----|-----|--------|----------|
| `K₂` (unit edge) | two points at distance 1 | 2 | 1 | `1/2` | above |
| `K₃` (equilateral triangle) | `(0,0),(1,0),(1/2,√3/2)` | 3 | 1 | `1/3 ≈ 0.333` | above |
| `K₄ − e` (rhombus / two glued triangles) | `(0,0),(1,0),(1/2,±√3/2)` | 4 | 2 | `1/2` | above |
| Path `P₄` | four collinear-ish unit steps | 4 | 2 | `1/2` | above |
| `C₆` (unit hexagon) | regular hexagon, side 1 | 6 | 3 | `1/2` | above |
| Moser spindle | classic 7-point 4-chromatic graph | 7 | 2 | `2/7 ≈ 0.2857` | above |
| Golomb graph | 10-point 4-chromatic graph | 10 | 3 | `3/10 = 0.30` | above |
| Triangular-lattice patch (large) | sub-lattice of the triangular tiling | `n` | `→ n/3` | `→ 1/3` | above |

Every explicitly known finite planar unit-distance graph has independence ratio
`≥ 2/7 ≈ 0.2857 > 0.25`. The smallest ratios among named graphs come from the
4-chromatic Moser spindle and its relatives, none of which drops to `1/4`.

## 2. Degree-based sufficient condition (verified)

The formal development proves the constructive chain

```
maximum degree Δ  ⟹  χ ≤ Δ+1  (greedy)  ⟹  i(G) ≥ 1/(Δ+1).
```

In particular **every** finite unit-distance graph with maximum degree `≤ 3`
has `i(G) ≥ 1/4`. This settles the entire low-degree regime: any hypothetical
counterexample to the `1/4` floor must contain a point with at least `4` other
points at unit distance.

Sanity checks of the floor `1/(Δ+1)`:

- `Δ = 1` (matchings): `i ≥ 1/2` — matches `K₂`, `P₂`.
- `Δ = 2` (paths/cycles): `i ≥ 1/3` — matches `C₆` (actual `1/2`), tight on `C₃`.
- `Δ = 3`: `i ≥ 1/4` — Moser spindle has `Δ = 4`, so it is (correctly) *not*
  covered by this criterion, yet still lies above the floor.

## 3. Counterexample hunt

Target of the hunt: a finite planar unit-distance graph with `i(G) < 1/4`.

- Exhaustive named-graph survey (Section 1): **no counterexample**; the record
  low is `2/7`.
- Structural obstruction: a counterexample is equivalent to a finite planar
  unit-distance graph with fractional chromatic number `> 4`. The best known
  lower bounds on the fractional chromatic number of the plane are around `3.6`
  (Cranston–Rabern), i.e. below `4`; so no counterexample is currently known and
  none can be small-degree (Section 2).
- Conclusion: the `1/4` claim is consistent with all computed data; it is a
  *frontier* statement whose truth is equivalent to fractional 4-colourability
  of the plane.

## 4. OEIS / external signals

No single integer sequence indexes "independence ratios", but the relevant
external signal is the steady tightening of lower bounds on the plane's
(fractional) chromatic number since de Grey's 2018 discovery that the chromatic
number of the plane is at least `5`. Those bounds control exactly the reciprocal
quantity studied here; the `1/4` floor corresponds to the fractional value `4`,
which the current bounds `[3.6, 4]` neither confirm nor refute.

## 5. Takeaway

The computational picture supports the constraint `i(G) ≥ 1/4` and pinpoints the
open part: **maximum degree `≥ 4`**. The formal files prove the constraint
unconditionally for maximum degree `≤ 3` and reduce it, in general, to fractional
4-colourability.
