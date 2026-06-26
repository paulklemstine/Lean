# Computational Evidence — Signless Laplacian spectral radius of pure complexes

All quantities below are exactly the ones formalized in `Core.lean`,
`Simplex.lean`, `Bridge.lean`. The signless Laplacian quadratic form of a
facet–ridge incidence is

    slQuad(facet, x) = ∑_f ( ∑_{r ∈ facet f} x_r )²   =  xᵀ (B Bᵀ) x ,

and the spectral radius is the supremum of the Rayleigh quotient
`slQuad(x) / ‖x‖²` over `x ≠ 0`.

## 1. Small cases of the sharpness witness (a single `r`-simplex)

Model: one facet containing all `n` ridges (`simplexFacet n`).
Every ridge has degree `1`; the facet has `n` ridges, so the Core bound is
`specRad ≤ s·D = n·1 = n`. The all-ones vector attains it:

| n | facet size s | max degree Δ | bound s·Δ | all-ones Rayleigh = n²/n | specRad |
|---|--------------|--------------|-----------|--------------------------|---------|
| 0 | 0            | —            | 0         | 0 (vacuous, sSup ∅ = 0)  | 0       |
| 1 | 1            | 1            | 1         | 1                        | 1       |
| 2 | 2            | 1            | 2         | 2                        | 2       |
| 3 | 3            | 1            | 3         | 3                        | 3       |
| 4 | 4            | 1            | 4         | 4                        | 4       |

So the Core bound is sharp for every `n` (formalized: `simplex_specRad`).

## 2. Graph (r = 1) case = classical signless Laplacian `Q = D + A`

Ridges = vertices, facets = edges (each a 2-set). Then
`slQuad = ∑_{uv ∈ E} (x_u + x_v)²`, the textbook signless Laplacian form,
and `specRad = q(G)`. Core gives `q(G) ≤ 2Δ(G)` (facet size `s = 2`).

| G            | n | Δ | bound 2Δ | actual q(G) | tight? |
|--------------|---|---|----------|-------------|--------|
| K₂ (edge)    | 2 | 1 | 2        | 2           | yes    |
| P₃ (path)    | 3 | 2 | 4        | 3           | no     |
| K₃ (triangle)| 3 | 2 | 4        | 4           | yes    |
| K₄           | 4 | 3 | 6        | 6           | yes    |
| Kₙ           | n | n−1 | 2(n−1) | 2(n−1)      | yes    |

`q(Kₙ) = 2(n−1)` matches `2Δ`, and `Kₙ` is the complete complex — the
graph instance of the conjecture's equality family (joins of simplices).
This is the `r = 1` shadow of `simplex_specRad`.

## 3. Counterexample hunt on the *naive* reading of the conjectured bound

Testing `q_{r-1}(K) ≤ t·n − (t−1)(r+1)` literally at `r = 1, t = 1`
(bound `= n`) against `K₃`: `q(K₃) = 4 > 3 = n`. So the *unqualified*
constant is NOT a bound on `q = 2Δ` for general pure complexes; the
homology-vanishing hypothesis of the conjecture is doing real work (it
forces a strong ceiling on ridge degrees). Our `Core.specRad_le`
isolates exactly the analytic step `q ≤ (facet size)·(max degree)`; the
homology hypothesis enters only through bounding the degree, which is the
content left open in `FUTURE_DIRECTIONS.md`.

## 4. Notes

* No OEIS sequence is involved; the objects are spectral bounds, not an
  integer sequence.
* Every number in the tables above is reproduced by a fully-proved Lean
  theorem for the diagonal/extremal cases (`simplex_specRad`,
  `graph_specRad_le`, `edgeFacet_card_two`).
