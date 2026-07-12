# Computational Evidence — Diagonal Correlation Stability

Small-case computation on the Boolean cube supporting the formalised results.

## 1. Diagonal correlation values (variance)

For a `{0,1}`-valued function `f` with mean `e = E[f]`, direct enumeration
confirms `Cov(f,f) = e(1-e)`:

| function on 2 bits | mean `e` | `Cov(f,f)` | `e(1-e)` |
|--------------------|----------|-----------|----------|
| dictator `x`       | 1/2      | 1/4       | 1/4      |
| AND `x∧y`          | 1/4      | 3/16      | 3/16     |
| OR `x∨y`           | 3/4      | 3/16      | 3/16     |
| dictator `y`       | 1/2      | 1/4       | 1/4      |

The maximum `1/4` is attained exactly by the balanced functions (`e = 1/2`),
matching `var_eq_quarter_iff`.

## 2. Off-diagonal AND/OR correlation

Enumerating the four points `(x,y) ∈ {0,1}²`:

- `E[AND] = 1/4`, `E[OR] = 3/4`.
- `AND·OR = AND` pointwise (since `AND ≤ OR`), so `E[AND·OR] = 1/4`.
- `Cov(AND,OR) = 1/4 − (1/4)(3/4) = 1/16`.

This is strictly below the diagonal maximum `1/4`, consistent with the AND/OR
pair being the *off-diagonal* extremiser (`cov_andf_orf`).

## 3. Stability bound sanity check

Testing `(e - 1/2)² ≤ ε` under `Cov(f,f) ≥ 1/4 − ε`, using
`(e-1/2)² = 1/4 − e(1-e)`:

| `e`   | `Cov=e(1-e)` | `ε = 1/4 − Cov` | `(e-1/2)²` |
|-------|--------------|-----------------|------------|
| 0.5   | 0.25         | 0.00            | 0.00       |
| 0.4   | 0.24         | 0.01            | 0.01       |
| 0.3   | 0.21         | 0.04            | 0.04       |
| 0.1   | 0.09         | 0.16            | 0.16       |

Equality `(e-1/2)² = ε` holds in every row, confirming the stability constant is
exactly `1` (best possible), as proved in `var_stability`.

## 4. Correlation positivity (Harris)

Random sampling of increasing `{0,1}`-functions on up to 4 bits produced no
negative covariance, consistent with `harris_cov_nonneg`. No counterexample to
any formalised claim was found.
