# Computational Evidence — γ-positivity of symmetric polynomials

## 1. The γ-basis and small-case coefficient tables

For an order `n`, the γ-basis is `B_{n,i}(t) = t^i (1+t)^{n-2i}`, `0 ≤ i ≤ ⌊n/2⌋`.
Each `B_{n,i}` is a shifted binomial row, symmetric about `n/2`.

Order `n = 2`:
- `B_{2,0} = (1+t)^2 = 1 + 2t + t^2`  → coeffs `[1,2,1]`
- `B_{2,1} = t`                       → coeffs `[0,1,0]`

Order `n = 4`:
- `B_{4,0} = (1+t)^4 = 1 + 4t + 6t^2 + 4t^3 + t^4`  → `[1,4,6,4,1]`
- `B_{4,1} = t(1+t)^2 = t + 2t^2 + t^3`             → `[0,1,2,1,0]`
- `B_{4,2} = t^2`                                    → `[0,0,1,0,0]`

## 2. Solving the γ-systems (counterexample hunt)

We test the universal claim "palindromic ⇒ γ-positive" on small palindromic targets.

**Target `1 + t^2` (order 2).** Writing `1 + t^2 = γ₀ B_{2,0} + γ₁ B_{2,1}`:
- coeff `t^0`: `γ₀ = 1`
- coeff `t^1`: `2γ₀ + γ₁ = 0 ⟹ γ₁ = -2 < 0`.

So `1 + t^2` is palindromic but **not** γ-positive (indeed not unimodal).

**Target `1 + t + t^2 + t^3 + t^4` (order 4).** Writing it as `Σ γ_i B_{4,i}`:
- coeff `t^0`: `γ₀ = 1`
- coeff `t^1`: `4γ₀ + γ₁ = 1 ⟹ γ₁ = -3 < 0`.

So this **unimodal**, palindromic, nonnegative polynomial is still **not** γ-positive.
This is the degree-4 shadow of the "minimal dimension 36" phenomenon: every *necessary*
consequence of γ-positivity (nonnegativity, symmetry, unimodality) can hold while
γ-positivity fails.

**Positive control `(1+t)^n`.** `γ₀ = 1`, all other `γ_i = 0` — γ-positive for all `n`.

## 3. Closure experiments

- `B_{m,i} · B_{n,j} = t^{i+j}(1+t)^{(m-2i)+(n-2j)} = t^{i+j}(1+t)^{(m+n)-2(i+j)} = B_{m+n, i+j}`
  whenever `2i ≤ m`, `2j ≤ n`. The γ-basis is closed under multiplication with
  additive indices, so products of γ-positive polynomials are γ-positive (across orders),
  with `γ_l = Σ_{i+j=l} a_i b_j ≥ 0`. Verified formally.
- Sums of order-`n` γ-positive polynomials are γ-positive (add γ-vectors). Verified.

## 4. OEIS notes

The γ-basis rows are binomial coefficients (OEIS A007318, Pascal's triangle).
The minimal-dimension value `36` for non-γ-positive symmetric edge polytopes is the
research target of the referenced literature and is *not* claimed here; we formalize the
polynomial-level backbone (necessity of palindromicity/nonnegativity/unimodality and the
cone structure) rather than the full graph-theoretic classification.

## Scope note

All numerics above are reproduced as machine-checked Lean theorems in
`GammaPositivity.lean`, `GammaPositivityCounterexample.lean`, and
`GammaPositivityProduct.lean`; the tables here are the informal derivations behind them.
