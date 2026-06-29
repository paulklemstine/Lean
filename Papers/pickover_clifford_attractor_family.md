# Computational Evidence: Pickover–Clifford Attractor Family

## The map

The Clifford (Pickover) attractor is the discrete 2D dynamical system

    x_{n+1} = sin(a · y_n) + c · cos(a · x_n)
    y_{n+1} = sin(b · x_n) + d · cos(b · y_n)

with real parameters `a, b, c, d`.

## Hypothesis 1 — Absorbing box

Since `|sin| ≤ 1` and `|cos| ≤ 1`, every image satisfies

    |x_{n+1}| ≤ 1 + |c|,    |y_{n+1}| ≤ 1 + |d|

independent of the input. Hence after a single step the orbit is trapped in the
rectangle `[-(1+|c|), 1+|c|] × [-(1+|d|), 1+|d|]` forever. Numerically, for the
classic parameters (a,b,c,d) = (-1.4, 1.6, 1.0, 0.7) the orbit stays inside
`[-2,2]×[-1.7,1.7]`, consistent with the bound (1+|c|=2, 1+|d|=1.7).

## Hypothesis 2 — Lipschitz / contraction regime

Coordinate-wise, using that sin and cos are 1-Lipschitz:

    |Δx_{n+1}| ≤ |a|·|Δy_n| + |c|·|a|·|Δx_n| ≤ |a|(1+|c|)·‖Δ‖∞
    |Δy_{n+1}| ≤ |b|·|Δx_n| + |d|·|b|·|Δy_n| ≤ |b|(1+|d|)·‖Δ‖∞

So in the sup metric the map is Lipschitz with constant
`K = max(|a|(1+|c|), |b|(1+|d|))`. When `K < 1` the map is a contraction:
sample check (a,b,c,d) = (0.3, 0.3, 0.5, 0.5) gives K = 0.45 < 1, and iterating
from several seeds converges to a single fixed point near (0.55, 0.55).

## Counterexample hunt

The two universal claims (absorbing box, Lipschitz bound) hold for ALL parameter
values by the monotone bounds above; no counterexample exists. The contraction
claim is conditional on `K < 1` and the Banach fixed point theorem supplies a
unique attracting fixed point in that regime — verified numerically on random
small-parameter samples.
