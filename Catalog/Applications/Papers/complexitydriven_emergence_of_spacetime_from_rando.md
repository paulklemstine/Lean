# Computational Evidence — Complexity-Driven Emergence of Spacetime from Random Tensor Networks

We model the holographic entanglement entropy of a random tensor network by the
Ryu–Takayanagi (min-cut) prescription: for a boundary region the entanglement
entropy equals `log D` times the minimal cut ("area") separating the region from
its complement, where `D` is the bond dimension. We test two phenomena:

1. **RT phase transition (surface exchange).** As a region-size parameter `x`
   grows, two candidate minimal surfaces with areas `a₁(x) = c₁ + s₁ x` and
   `a₂(x) = c₂ + s₂ x` compete; the dominant (minimal) one switches at a sharp
   point `x_c`. The entropy `S(x) = logD · min(a₁ x, a₂ x)` develops a *kink*
   (non-differentiable corner) there. This is precisely a tropical (min-plus)
   linear form, so the transition locus is a tropical hypersurface.

2. **Critical bond dimension `D_c(N)`.** The accessible entanglement capacity of
   a cut of `area` bonds is `area · log D`. A smooth (d+1)-geometry needs an
   entropy budget `β(N)`. The geometry is "smooth" iff `area · log D ≥ β`, which
   is upward-closed in `D`; hence a sharp threshold `D_c` exists with smoothness
   ⟺ `D ≥ D_c`.

## Small-case calculations (RT kink)

Take `logD = log 2`, `a₁ x = 10 + 1·x` (slow surface), `a₂ x = 4 + 3·x` (fast).
Crossing: `10 + x = 4 + 3x ⇒ x_c = 3`, common area `13`.

| x  | a₁=10+x | a₂=4+3x | min | dominant |
|----|---------|---------|-----|----------|
| 0  | 10      | 4       | 4   | a₂       |
| 2  | 12      | 10      | 10  | a₂       |
| 3  | 13      | 13      | 13  | tie (x_c)|
| 4  | 14      | 16      | 14  | a₁       |
| 6  | 16      | 22      | 16  | a₁       |

Symmetric kink check at `x_c=3`, `t=1`:
`S(3) − (S(2)+S(4))/2 = logD·(13 − (10+14)/2) = logD·(13−12) = logD·1`.
Predicted `logD·(s₂−s₁)·t/2 = logD·(3−1)·1/2 = logD·1`. ✓ Strictly positive ⇒ a
genuine concave corner (sharp phase transition), not a smooth crossover.

## Critical bond dimension

Budget `β = 30`, `area = 10`. Need `10·ln D ≥ 30 ⇒ ln D ≥ 3 ⇒ D ≥ e³ ≈ 20.09`.
So `D_c = 21` (integer). For `D = 20`: `10·ln20 ≈ 29.96 < 30` (fractal/fails).
For `D = 21`: `10·ln21 ≈ 30.45 ≥ 30` (smooth). Threshold is sharp at `D_c = 21`.

## Counterexample hunt

- *Is the transition always sharp?* If `s₁ = s₂` the two surfaces never cross
  transversally; `min` is then globally affine (no kink). Our kink theorem
  therefore requires `s₁ ≠ s₂`; this is the precise boundary case (documented).
- *Is the threshold always two-sided sharp?* If the budget is met already at the
  minimal allowed bond dimension, there is no "fractal" phase below. The
  below-threshold (fractal) statement is therefore guarded by `D_c` being above
  the minimal dimension. Captured in the Lab Notes.

These finite checks match the formal theorems proved in
`RTPhaseTransition.lean`, `BondDimensionThreshold.lean`, and
`MultiSurfaceStability.lean`.
