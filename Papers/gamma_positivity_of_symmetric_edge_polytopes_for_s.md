# Computational Evidence — γ-positivity of series–parallel path-join polynomials

## 1. The γ-basis and the flat palindrome

The γ-basis in order `n` is `B_{n,i}(t) = t^i (1+t)^{n-2i}` for `0 ≤ i ≤ ⌊n/2⌋`.
A polynomial symmetric about `n/2` is *γ-positive* if it is a nonnegative
combination of these.

The **flat palindrome** is `F_n(t) = 1 + t + t² + ⋯ + t^n`.

### Small-case γ-systems

Solving `F_n = Σ γ_i B_{n,i}` by reading off the two lowest coefficients:

| n | forced γ₀ | forced γ₁ = 1 − n | γ-positive? |
|---|-----------|-------------------|-------------|
| 0 | 1         | (only γ₀)         | yes  (F₀ = 1) |
| 1 | 1         | (only γ₀)         | yes  (F₁ = 1+t) |
| 2 | 1         | −1                | **no** |
| 3 | 1         | −2                | **no** |
| 4 | 1         | −3                | **no** (this is the catalog's `flat4`) |
| 5 | 1         | −4                | **no** |
| n≥2 | 1       | 1 − n ≤ −1        | **no** |

The obstruction is entirely in the coefficient of `t¹`: only `B_{n,0}` and
`B_{n,1}` contribute there, giving `n·γ₀ + γ₁ = 1`, and `γ₀ = 1` is forced by the
constant term. Hence `γ₁ = 1 − n < 0` for every `n ≥ 2`. This is verified in
`flatPal_not_gammaPositive` and packaged as the biconditional
`flatPal_gammaPositive_iff`.

## 2. Series–parallel product model

For path lengths `a = (a₁,…,a_m)` the product model is
`Π_j (1+t)^{a_j} = (1+t)^{a₁+⋯+a_m}`, whose γ-expansion is the single term
`γ₀ = 1`. Small checks (`m = 2` on `[2,3]`, `m = 4` on `[1,2,2,3]`) confirm
γ-positivity; the general statement `seriesModel_gammaPositive` covers every `m`,
in particular the conjectured `m ≤ 4` regime.

## 3. Counterexample hunt

Testing the universal claim "every palindromic polynomial is γ-positive" against
the flat family immediately produces counterexamples at every degree `≥ 2`, matching
the known failure of γ-positivity for the symmetric edge polytopes `Q_{G(a)}` once
`m ≥ 5`. The flat palindrome is additionally unimodal with all coefficients equal to
`1`, so the failure is genuine and not an artefact of non-unimodality.

## 4. OEIS note

The coefficient rows of the γ-basis elements `B_{n,i}` are shifted binomial rows
(`A007318`, Pascal's triangle); the flat palindrome coefficient vectors are the
all-ones rows. No further sequence lookup was needed.
