# Computational Evidence — EML Sharp Convergence Rate

Target claim: for the EML operator `f(x) = exp(a)·log(b·x + c)`, the Picard
iteration `xₙ₊₁ = f(xₙ)` converges Q-linearly with asymptotic ratio **exactly**
the local derivative magnitude `ρ = |f'(x*)| = |exp(a)·b/(b·x* + c)|`, which is
generically strictly below the interval-wide contraction constant used in the
existing catalog a-priori rate.

## Concrete instance (matches `EML.FixedPointConcreteInstance`)

`f(x) = exp(1)·log(x + 100)` on `[0, 20]`, interval bound `ρ_interval = 1/30 ≈ 0.033333`.

Iteration from `x₀ = 0` (Float, `iter n 0`):

```
n :  0        1         2         3         4         5      ... 11
x :  0.000  12.5182  12.8388  12.8465  12.84668  12.846682 ... 12.846682
```

Fixed point (60 iterations): `x* ≈ 12.846682`, residual `f(x*) − x* ≈ 0.0`.

Local rate vs interval bound:

```
|f'(x*)| = exp(1)/(x*+100) ≈ 0.024088
ρ_interval = 1/30           ≈ 0.033333
```

So the local rate is strictly below the catalog's interval bound, as predicted.

## Consecutive-error ratios converge to the local rate

`|x_{n+1} − x*| / |x_n − x*|` for `n = 0..7`:

```
0.025573, 0.024123, 0.024089, 0.024088, 0.024088, 0.024088, 0.024089, 0.024070
```

These converge to `≈ 0.024088 = |f'(x*)|`, the exact limit asserted by
`EMLIterOp.iterSeq_sharp_rate` and `EMLIterOp.concreteEML_sharp_rate`. (The tiny
wobble at `n = 7` is Float round-off near machine fixed point, where both
numerator and denominator are at noise level.)

## Counterexample hunt for non-degeneracy

The ratio limit is `|f'(x*)|`, *not* `0`. The only failure mode of the statement
is a degenerate start `x₀ = x*`, where the sequence is constant and the ratio is
`0/0 = 0 ≠ |f'(x*)|`. This is exactly why the formal theorem carries the
hypothesis `x₀ ≠ x*`; for the concrete instance `x* ≈ 12.85 > 0`, so `x₀ = 0` is
non-degenerate (formalized as `concreteEML_fixedPoint_pos`).

## Conclusion

The evidence supports the sharp-rate claim and, in particular, that the local
rate `|f'(x*)|` is strictly smaller than the interval-wide constant `1/30` for
the catalog's concrete operator — the precise gap the formal theorems close.
