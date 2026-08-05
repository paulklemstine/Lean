# Computational evidence

Small-case checks performed with Lean `#eval` before formalising the theorems in
`Catalog/Geometry/CellularDevelopability.lean` and
`Catalog/Geometry/TwistedDevelopability.lean`.

All computations below are enumerations over finite coefficient groups `ZMod k`;
they are *evidence*, not proofs.  The corresponding statements are proved in Lean
(no `sorry`, only the standard axioms `propext`, `Classical.choice`, `Quot.sound`).

## 1. Triangle (three-cycle, no two-cells)

Developable fields are the gradients `ω i = h (i+1) - h i`; the conjecture predicts
they are exactly the fields with vanishing period on the single generating cycle,
i.e. `ω 0 + ω 1 + ω 2 = 0`.

| coefficients | # gradients | # fields with zero period | equal as sets |
|---|---|---|---|
| `ZMod 2` | 4 | 4 | true |
| `ZMod 3` | 9 | 9 | true |
| `ZMod 4` | 16 | 16 | true |

Counts equal `k²` (= `k³ / k`, one gradient per height field modulo the constants),
consistent with `H¹(S¹; A) ≅ A`.  Formalised as
`ImpossibleFigures.Cellular.triangle_developable_iff` (for an arbitrary additive
group), with the Penrose triangle `ω ≡ 1` over `ℝ` as an explicit impossible figure.

## 2. Theta graph (two vertices, three parallel edges); necessity of a *generating* family

Cycle space has rank 2 with generators `z₁ = e₀ - e₁`, `z₂ = e₀ - e₂`.

| coefficients | # developable | # fields with zero period on `z₁, z₂` | equal | # with zero period on `z₁` only |
|---|---|---|---|---|
| `ZMod 3` | 3 | 3 | true | 9 |
| `ZMod 5` | 5 | 5 | true | 25 |

The last column is the counterexample hunt: dropping `z₂` from the family (so that
the family no longer generates the cycle group) makes the criterion fail badly
(`k²` versus `k` fields).  Hence the spanning hypothesis in
`developable_iff_curvature_and_periods` cannot be removed.

## 3. Twisted (Möbius) complex: one vertex, one orientation-reversing edge

Twisted developability means `ω = h - (-1)·h = 2h`, so the developable set is
`2·A`:

* `A = ZMod 2`: developable set `{0}` (proper subset of `A`);
* `A = ZMod 3`: developable set `{0,1,2} = A`;
* `A = ZMod 4`: developable set `{0,2}` (proper subset of `A`);
* `A = ℤ`: developable set `2ℤ`, so `ω ≡ 1` is **not** developable.

Meanwhile the twisted cycle group is trivial (`∂ʷ (k·e) = 2k·[v₀] ≠ 0` for `k ≠ 0`),
so *all* period obstructions vanish.  This is the evidence that motivated the extra
"deck-transformation anti-invariance" clause in the twisted classification, and it
is formalised as `ImpossibleFigures.Twisted.mobius_periods_insufficient`.

## 4. Escher staircase (periodic 1-D grid) and the `2 × 2` periodic grid

Enumerations run for the theorems in `Catalog/Geometry/CycleCertificates.lean` and
`Catalog/Geometry/GridCertificates.lean`.

Staircase with `N` steps over `ZMod k`: number of gradients (developable fields)
versus number of fields whose increments sum to zero.

| `N`, `k` | # developable | # zero total ascent | sets equal |
|---|---|---|---|
| `N=4`, `k=3` | 27 | 27 | true |
| `N=5`, `k=2` | 16 | 16 | true |
| `N=3`, `k=4` | 16 | 16 | true |

Counts are `k^(N-1)`, matching `H¹(S¹; A) ≅ A`.  Proved as
`ImpossibleFigures.Cellular.cycleGraph_developable_iff`.

`2 × 2` periodic grid over `ZMod 2` (8 edges, all 256 increment fields enumerated):
developable fields = 8, flat and period-free fields = 8, and the two predicates
agree on every one of the 256 fields.  Proved (for all `m`, `n` and all coefficient
groups) as `ImpossibleFigures.Grid.grid_developable_iff`, with the cycle-space
presentation `grid_cycle_span` and the certificate bounds
`grid_certificate_of_not_developable`, `grid_noncontractible_certificate`.

## 4b. Non-abelian (rotational) increments on the three-cycle

Coefficients in the non-commutative group `G = Equiv.Perm (Fin 3)`; all `6³ = 216`
rotational increment fields on the three-cycle were enumerated in Lean.

| quantity | value |
|---|---|
| all fields `ω : Fin 3 → G` | 216 |
| developable fields (`∃ H, ω e = H (t e) * (H (s e))⁻¹`) | 36 |
| fields with trivial holonomy (`ω 2 * ω 1 * ω 0 = 1`) | 36 |
| the two predicates agree on every field | true |

(`36 = |G|²`: the frame field is determined by its value at the base point up to the
free choice of two increments.)  This motivated, and is subsumed by, the theorems
`ImpossibleFigures.NonAbelian.developable_iff_holonomy_trivial` and
`triangle_developable_iff`, proved for arbitrary groups and arbitrary connected
one-skeletons.  The concrete impossible/possible pair is
`penrose_rotational_not_developable` (three equal transpositions: holonomy is a
transposition) versus `three_cycle_developable` (three equal 3-cycles: holonomy `1`).

## 5. OEIS

The only sequences appearing are the trivial power counts `k^(#V-1)` and
`k^(#E-rank)`; no OEIS lookup is informative here.
