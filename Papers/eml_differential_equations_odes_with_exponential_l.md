# Computational Evidence

All searches below were run in Lean 4 with `#eval` on exact rational (`ℚ`)
arithmetic, using polynomials represented as coefficient lists.  They test the
two universal claims that are formalized in
`Catalog/Applications/EML/EMLDifferentialEquations.lean` and
`Catalog/Applications/EML/AiryRationalObstruction.lean`.

## 1. The claims being tested

For a polynomial coefficient `r`, a candidate rational function `u = P/Q`
(`Q ≠ 0`) solves the **Riccati equation** `u' + u² = r` exactly when

```
P'·Q − P·Q' + P²  =  r·Q²                                    (R)
```

and a candidate rational function `y = P/Q` (`P ≠ 0`, `Q ≠ 0`) solves the
**linear equation** `y'' = r·y` exactly when

```
W'·Q − 2·W·Q'  =  r·P·Q²,      W = P'·Q − P·Q'               (L)
```

Formalized claims: (R) has no solution when `deg r` is **odd**
(`riccati_no_rational_solution`); (L) has no solution when `r ≠ 0`
(`secondOrder_no_rational_solution`).

## 2. Exhaustive search

`P`, `Q` range over all polynomials of degree `< 3` with coefficients in
`{−2, −1, 0, 1, 2}` (5³ · 5³ = 15625 pairs per coefficient `r`).  The table
gives the number of pairs satisfying (R) and (L).

| `r`       | `deg r` | # solutions of (R) | # solutions of (L) |
|-----------|---------|--------------------|--------------------|
| `0`       | –       | 208                | 656                |
| `1`       | 0       | 248                | 0                  |
| `x`       | 1 (odd) | **0**              | **0**              |
| `x + 1`   | 1 (odd) | **0**              | **0**              |
| `2x`      | 1 (odd) | **0**              | **0**              |
| `x²`      | 2       | 0                  | 0                  |
| `x² + 1`  | 2       | 24                 | 0                  |
| `x³`      | 3 (odd) | **0**              | **0**              |
| `x³ + x`  | 3 (odd) | **0**              | **0**              |

**Counterexample hunt.**  No pair `(P, Q)` was found violating either claim:
every odd-degree `r` gave `0` solutions of (R), and every nonzero `r` gave `0`
solutions of (L).  The only nonzero count in the (L) column is at `r = 0`, which
is exactly the excluded case (`y'' = 0` has the rational solutions `y = ax + b`).

**Positive instances (sharpness).**  For `r = x² + 1` the search returns e.g.
`P = −2x − 2x²`, `Q = −2 − 2x`, i.e. `u = P/Q = x`, matching the formalized
witness `riccati_odd_degree_sharp` and the analytic solution
`y = exp(x²/2)` of `y'' = (x² + 1) y` (`exp_half_sq_solves`).  For `r = 1` the
search returns `u = ±1`, i.e. `y = e^{±x}`.  This confirms that the parity
hypothesis in `riccati_no_rational_solution` cannot be dropped.

## 3. Airy specifically

For `r = x` (Airy's equation `y'' = x·y`) both searches return `0`, in agreement
with `airy_riccati_no_rational_solution`, `airy_no_rational_solution` and
`airy_no_polynomial_solution`.

## 4. Sequences

No integer sequence arises; the invariants involved are degrees and parities, so
no OEIS lookup is relevant.
