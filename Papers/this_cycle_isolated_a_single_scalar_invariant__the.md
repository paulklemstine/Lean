# Computational Evidence

Small-case checks supporting the formalized results in
`MobiusDiscriminantQuantitative.lean`.

## Conjecture A — exact discriminant identity

General identity: `(α n + β)(α(n+1)+β)·D(n) = Δ·a(n)·a(n+1)` with
`D(n) = a(n)a(n+2) − a(n+1)²`, `Δ = γβ − αδ`.

### Catalan (`α,β,γ,δ = 1,2,4,2`, `Δ = 6`), `Cₙ = 1,1,2,5,14,42,132,…`

| n | Cₙ | Cₙ₊₁ | Cₙ₊₂ | D(n)=CₙCₙ₊₂−Cₙ₊₁² | (n+2)(n+3)·D(n) | 6·Cₙ·Cₙ₊₁ |
|---|----|----|----|----|----|----|
| 0 | 1  | 1  | 2  | 2−1 = 1   | 6·1 = 6     | 6·1·1 = 6   |
| 1 | 1  | 2  | 5  | 5−4 = 1   | 12·1 = 12   | 6·1·2 = 12  |
| 2 | 2  | 5  | 14 | 28−25 = 3 | 20·3 = 60   | 6·2·5 = 60  |
| 3 | 5  | 14 | 42 | 210−196=14| 30·14 = 420 | 6·5·14 = 420|

All rows match — consistent with `catalan_discriminant_exact`. Note `D(n) > 0`
for all `n` (strict log-convexity, `Δ = 6 > 0`).

### Factorials (`α,β,γ,δ = 0,1,1,1`, `Δ = 1`), `n! = 1,1,2,6,24,…`

`D(n) = n!(n+2)! − ((n+1)!)² = n!(n+1)!·((n+2)−(n+1)) = n!(n+1)!`, and the
identity `1·1·D(n) = 1·n!·(n+1)!` holds trivially. `Δ = 1 > 0`: log-convex.

## Conjecture D — curvature ratio

`a(n)a(n+2)/a(n+1)² = 1 + Δ/((γn+δ)(α(n+1)+β))`.

Catalan, `n = 2`: LHS `= 2·14/5² = 28/25 = 1.12`.
RHS `= 1 + 6/((4·2+2)(1·3+2)) = 1 + 6/(10·5) = 1 + 6/50 = 1.12`. ✔

As `n → ∞` the correction `6/((4n+2)(n+3)) → 0`, so the curvature ratio → 1 and
`Δ²(log C) → 0` (asymptotic affineness of the valuation).

## Conjecture B counterexample — Fibonacci / Cassini

`fib = 0,1,1,2,3,5,8,13,21,…`, discriminant `D(n) = fib(n)fib(n+2) − fib(n+1)²`.

| n | D(n) | expected `(−1)^{n+1}` |
|---|------|----|
| 0 | 0·1 − 1² = −1 | −1 |
| 1 | 1·2 − 1² = +1 | +1 |
| 2 | 1·3 − 2² = −1 | −1 |
| 3 | 2·5 − 3² = +1 | +1 |
| 4 | 3·8 − 5² = −1 | −1 |
| 5 | 5·13 − 8² = +1| +1 |

The discriminant alternates `−1, +1, −1, +1, …` forever (Cassini's identity),
taking both signs infinitely often. Since Fibonacci's recurrence
`a(n+2) = a(n+1) + a(n)` has *constant* coefficients `p = q = r = 1`, no
discriminant built from the coefficients alone can be simultaneously `+1` and
`−1` — refuting the coefficient-only second-order conjecture (Conjecture B).

## OEIS references

- Catalan numbers `Cₙ`: OEIS A000108 (`1, 1, 2, 5, 14, 42, 132, …`).
- Central binomial coefficients `C(2n,n)`: OEIS A000984.
- Fibonacci numbers: OEIS A000045.
- Cassini's identity `fib(n−1)fib(n+1) − fib(n)² = (−1)^n`: standard.
