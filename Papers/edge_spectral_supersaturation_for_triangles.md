# Computational Evidence: Edge-Spectral Supersaturation for Triangles

We record small-case checks of the power-trace method behind the constant-`1/3`
spectral supersaturation bound `t ≥ (λ·q)/3`, where `λ` is the adjacency spectral
radius, `m` the edge count, `q = λ² − m` the spectral excess, and `t` the number
of triangles.

## 1. Small-case calculations

For each graph we list the adjacency spectrum, then `m = (∑μ²)/2`, `t = (∑μ³)/6`,
`λ`, `q = λ² − m`, and the proven lower bound `(λq)/3`.

| Graph      | spectrum                | m  | t  | λ    | q    | (λq)/3 | t/(λq) |
|------------|-------------------------|----|----|------|------|--------|--------|
| K₃         | 2, −1, −1               | 3  | 1  | 2    | 1    | 0.667  | 0.500  |
| K₄         | 3, −1, −1, −1           | 6  | 4  | 3    | 3    | 3.000  | 0.444  |
| K₅         | 4, −1,−1,−1,−1          | 10 | 10 | 4    | 6    | 8.000  | 0.417  |
| C₄         | 2, 0, 0, −2             | 4  | 0  | 2    | 0    | 0.000  |  —     |

In every case the proven bound `(λq)/3 ≤ t` holds (equivalently `λq ≤ 3t`).

## 2. Asymptotic sharpness on complete graphs

For `Kₙ`: `λ = n−1`, `m = C(n,2) = n(n−1)/2`, so
`q = (n−1)² − n(n−1)/2 = (n−1)(n−2)/2`, and `t = C(n,3) = n(n−1)(n−2)/6`. Hence

  `t / (λ q) = [n(n−1)(n−2)/6] / [(n−1)·(n−1)(n−2)/2] = n / (3(n−1))`,

which decreases monotonically to `1/3` as `n → ∞`. So the ratio `t/(λq)` is always
`> 1/3` (the inequality `λq ≤ 3t` never fails) but approaches `1/3` arbitrarily
closely: **the constant `1/3` cannot be improved for the unconditional `λq`-form
of the bound.** The triangle counts `1, 4, 10, 20, …` here are the tetrahedral
numbers (OEIS A000292).

## 3. Endpoint (Nosal) check

The 4-cycle `C₄` has spectrum `2, 0, 0, −2`, so `∑μ³ = 8 + 0 + 0 − 8 = 0`
(triangle-free), `m = 4`, `λ = 2`, and indeed `λ² = 4 = m`, saturating the
endpoint inequality `λ² ≤ m`. Thus `C₄` certifies that Nosal's bound is tight.

## 4. Relation to the conjectured sharp constant

The open conjecture concerns the *small-excess* regime `0 < q ≤ δ√m`, where
`λ = √(m + q) ≈ √m`, and predicts `t ≥ (1 − ε) q√m` — constant `B = 1`. Our bound
gives `t ≥ (λq)/3 ≈ (q√m)/3` in this regime — constant `1/3`, exactly three times
weaker. The gap is not from generic slack: the estimate
`∑_{i≥2} μᵢ³ ≥ −λ ∑_{i≥2} μᵢ²` is tight only when the negative spectrum
concentrates near `−λ` (a near-bipartite configuration), which is precisely the
structure that suppresses triangles. Closing the factor of `3` therefore requires
ruling out such spectra in the small-excess regime — the content of the conjecture.

## 5. Counterexample hunt

No violation of `λq ≤ 3t` was found among the tested graphs or in the symbolic
complete-graph family, where the ratio `t/(λq) = n/(3(n−1))` stays above `1/3`.
This is consistent with the theorem and pins the unconditional constant at `1/3`.


# Future Directions: Edge-Spectral Supersaturation for Triangles

The power-trace method yields an unconditional triangle count `t ≥ (λq)/3` in terms
of the spectral excess `q = λ² − m`, with the endpoint `q = 0` recovering Nosal's
inequality `λ² ≤ m`. The following conjectures aim to close the gap between this
constant `1/3` and the conjectured sharp constant `1`, and to extend the method.

## Conjecture A — Sharp constant for triangles

For every `ε > 0` there exist `δ > 0` and `M` such that for all `m ≥ M` and
`0 < q ≤ δ√m`, every graph with `m` edges and `λ² ≥ m + q` contains at least
`(1 − ε) q√m` triangles.

The key insight is that the only spectra saturating the power-trace estimate place
their entire negative mass near `−λ`, forcing a near-complete-bipartite structure
that is quantitatively incompatible with a large second eigenvalue; controlling the
*second* eigenvalue in the small-excess regime should recover the missing factor of
three. Why now? The corresponding statement for color-critical `F` with `χ(F) ≥ 4`
is settled with sharp constant `B_F`, and the triangle case is the sole remaining
`χ = 3` endpoint, so a targeted second-eigenvalue argument is the natural next step.

## Conjecture B — Second-eigenvalue refinement

Let `λ = μ₁ ≥ μ₂ ≥ … ≥ μₙ` be the adjacency spectrum. Then
`6t ≥ 2λ³ − λ∑μᵢ² + (λ + μ₂)·∑_{i≥2} μᵢ²`, and consequently
`t ≥ (λq)/3 + (λ + μ₂)(2m − λ²)/6`.

The key insight is that the crude bound `μᵢ³ ≥ −λμᵢ²` discards the improvement
`μᵢ³ ≥ μ₂ μᵢ²` available whenever `μᵢ ≥ μ₂`, and reinstating this term converts the
spectral gap `λ − |μ₂|` directly into extra triangles. Why now? Modern interlacing
and spectral-gap tools make `μ₂` tractable exactly in the dense supersaturation
regime where the conjecture lives, so the refined inequality is within reach.

## Conjecture C — Weighted / general power-trace endpoints

For every fixed odd `k ≥ 3`, a graph with `∑ μᵢ^k = 0` satisfies `λ² ≤ m`, and more
generally the excess `q` forces `∑ μᵢ^k ≥ c_k · q · λ^{k−2}` for an explicit
constant `c_k > 0`.

The key insight is that the argument driving the `k = 3` case — isolating the top
eigenvalue and dominating the rest by `−λ` — is indifferent to the exponent, so the
entire family of odd power-trace identities should yield supersaturation for the
associated closed-walk counts. Why now? Closed-walk counts of every length are
linear in the power traces, so a single uniform lemma would simultaneously bound
triangles, and higher closed walks, unifying several extremal counts at once.

## Conjecture D — Stability form

If a graph with `m` edges satisfies `λ² ≥ m + q` with `0 < q = o(√m)` yet has fewer
than `(1 − ε) q√m` triangles, then it is `o(m)`-close in edit distance to a complete
bipartite graph plus a sparse remainder.

The key insight is that near-extremal spectra for the power-trace bound are exactly
the near-bipartite ones, so a triangle deficit should be a robust certificate of
approximate bipartiteness. Why now? Spectral stability results have matured for the
`χ ≥ 4` cases, and transporting them to the triangle endpoint would both prove
Conjecture A and describe its extremal graphs.
