# Computational Evidence: Tropical / F₁ Euler Correspondence

We test the conjecture that, for a toric variety built from projective spaces
`ℙ^d` (dual to the standard `d`-simplex) under Cartesian products, the Euler
characteristic of the variety equals the number of vertices of the associated
polytope (its "F₁-points").

## Model

A variety in this class is encoded as a term of `ToricPoly`:
`simplex d` denotes `ℙ^d`; `prod P Q` denotes the product `X_P × X_Q`, whose
polytope is the product polytope.

- **Vertices** (F₁-points): `Δ_d` has `d+1` vertices; a product polytope's
  vertex count is the product of the factors' vertex counts.
- **Betti numbers**: for `ℙ^d`, the cohomology is `ℤ` in each even degree
  `0, 2, …, 2d` and `0` otherwise; products obey the Künneth (antidiagonal
  convolution) formula.
- **Euler characteristic**: the honest alternating sum
  `χ = Σ_k (-1)^k b_k` over degrees `0 … 2·dim`.

## Small-case calculations

| Variety            | Polytope            | vertices | Betti (nonzero degrees)      | χ  |
|--------------------|---------------------|----------|------------------------------|----|
| `ℙ^0` (point)      | `Δ_0`               | 1        | b₀=1                         | 1  |
| `ℙ^1`              | segment `Δ_1`       | 2        | b₀=b₂=1                      | 2  |
| `ℙ^5`              | `Δ_5`               | 6        | b₀=…=b₁₀=1                   | 6  |
| `ℙ^2 × ℙ^3`        | `Δ_2 × Δ_3`         | 12       | Künneth of the two spectra   | 12 |
| `(ℙ^1)^3` (cube)   | `[0,1]^3`           | 8        | binomial `2^3` distribution  | 8  |

Each computed `χ` matches the vertex count exactly. These values are reproduced
directly by evaluation of the `eulerChar` and `vertices` functions in the
accompanying development.

## Counterexample hunt

We evaluated `eulerChar P = vertices P` on all products of simplices with total
dimension up to 6 (simplices `Δ_0 … Δ_6` and their pairwise/triple products).
No counterexample was found; the general statement is then proved
(`eulerChar_eq_vertices`).

## Structural observation

Two ingredients make the identity hold:
1. **No odd cohomology** — all odd Betti numbers vanish, so the signs in `χ`
   never produce cancellation and `χ` collapses to the *total* Betti number.
2. **Multiplicativity** — the total Betti number is multiplicative under products
   (a truncated Cauchy product of finitely supported sequences), matching the
   multiplicativity of vertex counts of product polytopes.

Together these force `χ = Σ b_k = #vertices`.
