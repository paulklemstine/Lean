# Computational Evidence — Parabola-Circumscribed Quadrilaterals & Irrational Tiling Densities

This note records the small-case checks that motivated the two formalized theorem
families before the Lean proofs were written. All claims below are *now* backed by
the `sorry`-free Lean files in this directory; the evidence is retained for the
record.

## 1. Concyclicity on the parabola `y = x²`

**Claim.** Four distinct points `(t, t²)` are concyclic ⟺ their abscissae sum to 0.

Substituting `y = t²` into a circle `x² + y² + g x + h y + k = 0` gives the quartic
`t⁴ + (1+h) t² + g t + k = 0`. The cubic coefficient is `0`, so Vieta forces
`a + b + c + d = 0`.

Small cases:

| abscissae `(a,b,c,d)` | sum | concyclic? |
|---|---|---|
| `(-3,-1,1,3)`  | 0 | yes |
| `(-2,-1,1,2)`  | 0 | yes |
| `(-1,0,?,?)` with `c+d=1` e.g. `(-1,0,2,-1)` invalid (dup); `(-1,0,3,-2)` | 0 | yes |
| `(0,1,2,3)`    | 6 | no |
| `(1,2,3,4)`    | 10 | no |

Sanity check for `(-3,-1,1,3)`: the symmetric circle through them has center on the
`y`-axis, consistent with the symmetric layout, confirming concyclicity.
Sanity check for `(0,1,2,3)`: the unique conic through these four parabola points
has a nonzero `t³` coefficient, so no genuine circle fits — confirmed non-concyclic.

No counterexample to the `⟺` was found in a sweep of small integer tuples
(`|a|,|b|,|c|,|d| ≤ 6`, pairwise distinct): concyclicity coincided exactly with
zero abscissa-sum.

## 2. Beatty / Sturmian tiling densities

**Claim.** For slope `α`, the cumulative tile count
`C_N = ∑_{n<N} (⌊(n+1)α⌋ - ⌊nα⌋)` telescopes to `⌊Nα⌋`, and `C_N / N → α`.

The telescoping is exact and dimension-free; the density limit is a floor squeeze.

Golden slope `α = (√5-1)/2 ≈ 0.6180339887…` (the Fibonacci quasicrystal):

| N | ⌊Nα⌋ | ⌊Nα⌋/N |
|---|---|---|
| 10   | 6     | 0.6000 |
| 100  | 61    | 0.6100 |
| 1000 | 618   | 0.6180 |
| 10⁴  | 6180  | 0.61800 |
| 10⁵  | 61803 | 0.618030 |

The ratio approaches `α` as predicted; the limiting density is irrational
(`goldenSlope_irrational`), so the tiling is aperiodic.

OEIS: the lower Wythoff / golden Beatty sequence `⌊nφ⌋` (with `φ = (1+√5)/2`) and the
complementary `⌊n(φ-1)⌋ = ⌊n·goldenSlope⌋` correspond to A000201 / A001950 (Wythoff
sequences); the `0/1` step word is the Fibonacci/Sturmian word A003849.

## Why this evidence suffices

Both families reduce to exact algebraic identities (Vieta / telescoping) plus a
single elementary limit, so a finite sweep is decisive for falsification and the
Lean proofs supply the universal guarantee.
