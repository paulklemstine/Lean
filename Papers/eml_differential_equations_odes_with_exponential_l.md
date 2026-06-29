# Computational Evidence — Airy's Equation Has No EML Solutions

This note collects the small-case evidence that motivated the formal theorems in
`AiryNoEMLSolution.lean` and `RiccatiBoundary.lean`.

## 1. Polynomial solutions of `y'' = x·y`

Write `p = Σ aₙ xⁿ`. Then `p''` has degree `deg p − 2`, while `x·p` has degree
`deg p + 1`. Matching the top coefficient is impossible for any `p ≠ 0`:

| `deg p` | `deg p''` | `deg (x·p)` | match? |
|--------:|----------:|------------:|:------:|
| 0       | (−∞)      | 1           | no     |
| 1       | (−∞)      | 2           | no     |
| 2       | 0         | 3           | no     |
| `n`     | `n−2`     | `n+1`       | no     |

The gap `( n+1 ) − ( n−2 ) = 3` never closes, so the only polynomial solution is `p = 0`.
(Formalized as `airy_no_polynomial_solution`.)

## 2. Exp-of-polynomial solutions `y = exp(p)`

Substituting `y = exp(p)` into `y'' = x·y` and dividing by `exp(p) > 0` gives the Riccati
relation
```
(p')² + p'' = x.
```
Let `q = p'` with `deg q = d`.

| case        | `deg (q²)` | `deg q'` | `deg` of LHS | target `deg x` = 1 |
|-------------|-----------:|---------:|-------------:|:------------------:|
| `q = 0`     | (−∞)       | (−∞)     | `−∞` (LHS=0) | no (0 ≠ x)         |
| `d = 0`     | 0          | (−∞)     | 0            | no                 |
| `d ≥ 1`     | `2d`       | `≤ d−1`  | `2d` (even)  | no (`2d ≠ 1`)      |

The left-hand side always has **even** degree (or is constant), never degree 1.
(Formalized as `airy_riccati_no_polynomial_solution`.)

### Explicit small checks
* `p = a + b·x`  ⇒ `(p')² + p'' = b²` (constant) ≠ `x`.
* `p = c·x²`     ⇒ `p' = 2c·x`, `(p')² = 4c²x²`, `p'' = 2c`, sum `= 4c²x² + 2c` ≠ `x`.
* `p = c·x²/2`   ⇒ same shape, leading term `c²x²` cannot be `x`.

No truncation up to degree 6 yields a solution; the parity obstruction rules out all degrees.

## 3. The degree-parity generalization

The same count shows `(p')² + p'' = r` is unsolvable whenever `deg r` is **odd**:
the LHS is always even-degree or constant. Airy is the smallest instance (`r = x`,
`deg = 1`). Predictions: `y'' = x³ y`, `y'' = (x⁵+1) y`, … all lack exp-of-polynomial
solutions. (Formalized as `riccati_no_solution_of_odd_natDegree`.)

## 4. The contrasting solvable case (boundary)

For a **constant** coefficient `k ≥ 0`, the Riccati relation becomes `(p')² + p'' = k`,
solved by `p = √k·x` (then `(p')² = (√k)² = k`, `p'' = 0`). The corresponding ODE
`y'' = k·y` has the genuine EML solution `y = exp(√k·x)`:
```
y'  = √k · exp(√k·x),     y'' = (√k)² · exp(√k·x) = k · exp(√k·x) = k·y.
```
(Formalized as `riccati_const_has_poly_solution` and `exp_solution_const_coeff`.)

## Summary

The decisive invariant is the **parity of the degree of the coefficient function**. Airy's
`x` has odd degree 1, which can never equal the even-degree square `(p')²`; constant
coefficients have even degree 0 and are solvable. This is precisely the obstruction that the
Kovacic algorithm detects in its exponential (Case 1) branch.
