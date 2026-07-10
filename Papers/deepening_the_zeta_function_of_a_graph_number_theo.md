# Computational Evidence — the Ihara zeta function of a regular graph

The local (Bass–Ihara) factor of a `(q+1)`-regular graph at a spectral value `λ` is
`p(λ, q, u) = 1 − λ·u + q·u²`. All claims below were checked numerically before being formalized.

## 1. The local factor and the critical circle `|u| = 1/√q`

The two zeros of `p` are `u = (λ ± √(λ² − 4q)) / (2q)`, with product `1/q`.

| q | λ      | λ² − 4q | zeros                        | \|zero\|         |
|---|--------|---------|------------------------------|------------------|
| 2 | 2      | −4      | (1 ± i)/2                    | 0.7071 = 1/√2    |
| 2 | 2.5    | 0.25    | 0.75, 0.5                    | 0.75, 0.5 (real) |
| 3 | 3      | −3      | (3 ± i√3)/6                  | 0.5774 = 1/√3    |
| 3 | 2√3    | 0       | 1/√3 (double)                | 0.5774 = 1/√3    |
| 5 | 4      | −4      | (4 ± 2i)/10                  | 0.4472 = 1/√5    |

Observation: exactly when `λ² ≤ 4q` (the Ramanujan / spectral-gap bound), both zeros have modulus
`1/√q`, i.e. they lie on the critical circle. When `λ² > 4q` the zeros are real and straddle the
circle (product `1/q`, so one inside, one outside). This is the graph-theoretic Riemann Hypothesis,
formalized as `ramanujan_abs` and `non_ramanujan_real_roots`.

## 2. The cycle graph `Cₙ`

`Cₙ` is `2`-regular (`q = 1`) with adjacency eigenvalues `2cos(2πk/n)`, `k = 0,…,n−1`. Numerically
evaluating `∏_{k<n} (1 − 2cos(2πk/n)·u + u²)` as a polynomial in `u`:

| n | ∏ (1 − 2cos(2πk/n)u + u²)        |
|---|----------------------------------|
| 1 | (1 − u)²                         |
| 2 | (1 − u²)²                        |
| 3 | (1 − u³)²                        |
| 4 | (1 − u⁴)²                        |
| 5 | (1 − u⁵)²                        |

The product collapses to `(1 − uⁿ)²` in every case, matching the known Ihara zeta
`ζ_{Cₙ}(u)⁻¹ = (1 − uⁿ)²` (the cycle has exactly two prime cycle classes of every length that is a
multiple of `n`, coming from the two orientations). Formalized as `cycle_spectral_det`.

The identity is the cyclotomic factorization `1 − uⁿ = ∏_{ω:ωⁿ=1} (1 − ω u)` applied twice
(once for `ω`, once for `ω⁻¹`, which reindexes to the same set).

## 3. Functional equation

For every table entry the substitution `u ↦ 1/(qu)` reproduces `p` up to the factor `q u²`:
`q u² · p(λ, q, 1/(qu)) = p(λ, q, u)`. Checked symbolically; formalized as `localFactor_funeq` and
lifted to the whole spectrum in `det_funeq`.

## 4. Cross-domain note

Each factor `1 − λu + qu²` has the exact shape of an elliptic-curve Euler factor `1 − aT + pT²`,
with `λ ↔ a` (trace of Frobenius) and `q ↔ p` (residue characteristic). The Ramanujan bound
`λ² ≤ 4q` is precisely the Hasse/Weil bound `a² ≤ 4p`, and the critical circle `|u| = 1/√q` is the
Riemann Hypothesis `|α| = √p` for the reciprocal roots. This dictionary motivated the file.
