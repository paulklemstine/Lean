# Computational Evidence — EML Differential Equations / Airy obstruction

Target claims (now formalized in `EMLAiryNoExpPoly.lean` and `EMLWronskianAbel.lean`):

1. No `exp(p(x))` with `p` a polynomial solves Airy `y'' = x·y`.
2. More generally, no nowhere-zero `C²` solution of Airy has a polynomial
   logarithmic derivative `y'/y`.
3. The Wronskian of two solutions of `y'' = q(x)·y` is constant (Abel's identity).

## 1. The Riccati reduction (small-case hand computation)

If `y = exp(p)` then `y' = p'·exp(p)`, `y'' = (p'' + (p')²)·exp(p)`. Airy `y'' = x·y`
forces, after dividing by `exp(p) > 0`,

    p''(x) + (p'(x))² = x      (the Riccati equation with v = p').

We test whether any polynomial `p` can satisfy this.

| deg p (d) | p'' deg | (p')² deg | dominant deg of LHS | must equal deg(X)=1? |
|-----------|---------|-----------|----------------------|----------------------|
| 0         | —       | —         | 0 (LHS = 0)          | 0 ≠ 1  ✗            |
| 1         | —       | 0         | 0 (constant c²)      | 0 ≠ 1  ✗            |
| 2         | 0       | 2         | 2                    | 2 ≠ 1  ✗            |
| 3         | 1       | 4         | 4                    | 4 ≠ 1  ✗            |
| d ≥ 2     | d−2     | 2(d−1)    | 2(d−1) (even)        | 2(d−1)=1 impossible  |

The dominant degree of `p'' + (p')²` for `d ≥ 2` is `2(d−1)`, always **even**, while
`deg(X) = 1` is **odd**. For `d ≤ 1` the LHS is constant. No degree works — this is
exactly the parity/degree obstruction proved in `no_poly_riccati_airy`.

## 2. Counterexample hunt (none found, as predicted)

We searched `p = a₀ + a₁x + a₂x² + a₃x³` symbolically for `p'' + (p')² = x`:
matching coefficients gives `2a₂ + a₁² = 0` (const), `2a₁a₂·2 = 1`?  The `x¹`
coefficient of `(p')²` requires `2·a₁·(2a₂) = 1` while the `x¹` coefficient of `p''`
is `6a₃`, so `6a₃ + 4a₁a₂ = 1`, but the top coefficient `(2a₂... )` forces the
degree-4 term `(3a₃)²·x⁴ = 0 ⇒ a₃ = 0`, collapsing to the degree-2 analysis, which
fails at the `x²` coefficient `(2a₂)² = 0 ⇒ a₂ = 0`, then `a₁² = 0`, then `0 = x`.
No assignment solves it — consistent with the theorem.

## 3. Wronskian / Abel constancy

For `y'' = q·y`, `W = f·g' − g·f'` gives
`W' = f'g' + f·g'' − g'f' − g·f'' = f·(q g) − g·(q f) = 0`.
Hence `W` is constant. This is verified for arbitrary coefficient `q` (Airy is the
case `q(x) = x`) in `wronskian_const` / `airy_wronskian_const`.

## OEIS

No integer sequence is central to these claims; the content is a degree/parity
obstruction plus an exact derivative identity, so no OEIS lookup applies.

All three claims are now machine-checked in Lean 4 with only the standard axioms
`propext, Classical.choice, Quot.sound`.
