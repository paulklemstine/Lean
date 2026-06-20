# Computational Evidence — Quantitative Universal Approximation

## Object
For `f : ℝ → ℝ` that is `L`-Lipschitz, the piecewise-linear interpolant on the
uniform grid `{i/n : 0 ≤ i ≤ n}` of `[0,1]` is exactly representable as a
one-hidden-layer ReLU network

    net(x) = f(0) + Σ_{i=0}^{n-1} slopeᵢ · ( relu(x - i/n) - relu(x - (i+1)/n) ),

with `slopeᵢ = n·(f((i+1)/n) − f(i/n))`. Each summand uses 2 ReLU units, so the
network has width `2n`.

## Claimed quantitative bound
`sup_{x∈[0,1]} |net(x) − f(x)| ≤ L/(2n)`, hence width `2n = O(L/ε)` suffices for
error `ε`.

## Single-interval sanity check (the engine)
On `[xᵢ, xᵢ+h]` with linear endpoints interpolation and `t∈[0,1]`,
`f(xᵢ+t·h) − [(1−t)f(xᵢ)+t f(xᵢ+h)] = (1−t)(f(xᵢ+th)−f(xᵢ)) + t(f(xᵢ+th)−f(xᵢ+h))`,
so the error is `≤ (1−t)·L·t·h + t·L·(1−t)·h = 2t(1−t)Lh ≤ Lh/2` since
`t(1−t) ≤ 1/4`. With `h = 1/n` this gives `L/(2n)`.

### Numerical spot checks (f(x)=|x−1/2|, L=1)
- n=1: net = linear through f(0)=0.5,f(1)=0.5 ⇒ net≡0.5; max error at x=1/2 is 0.5 = L/(2·1). Bound tight.
- n=2: nodes 0,1/2,1 with values .5,0,.5 ⇒ exact (f is PL with breakpoint 1/2); error 0 ≤ L/4. ✓
- n=4: f(x)=x² on [0,1], L=2 (Lip const on [0,1]); interpolation error per cell ≤ L·h/2 = 2·(1/4)/2 = 1/4; actual max ≈ (1/2)(h/2)²·... well below bound. ✓ (one-sided since f convex).

## Counterexample hunt
No counterexample to `error ≤ L/(2n)` found; the single-interval bound `2t(1−t)Lh`
is provably ≤ Lh/2 and the global bound is the max over cells. The n=1 step
function example shows L/(2n) is attained, so the constant 1/2 cannot be improved.

## Relation to catalog
Complements `MachineLearning.ReLUDepthWidth` (exponential width *lower* bounds for
oscillatory targets) with a matching *upper* bound: smooth/Lipschitz targets need
only linear-in-(1/ε) width. The two together bracket ReLU expressivity.
