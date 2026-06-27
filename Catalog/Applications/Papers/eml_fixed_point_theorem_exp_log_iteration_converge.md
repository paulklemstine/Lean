# Computational Evidence — EML Fixed-Point Existence Threshold & Monotone Bracket

All computations use the EML single operator `f(x) = exp(a)·log(b·x + c)` with
`b = 1`, i.e. `f(x) = exp(a)·log(x + c)`, evaluated on its natural domain
`x + c > 0` (where `Real.log` is the genuine logarithm).

## 1. The residual and its maximum

Let `g(x) = f(x) − x = exp(a)·log(x + c) − x`. Substituting `u = x + c > 0`,
`g = exp(a)·log u − u + c`. The map `u ↦ exp(a)·log u − u` is maximized at
`u = exp(a)`, with maximum `exp(a)·(a − 1)`. Hence

```
max_x g(x) = exp(a)·(a − 1) + c        (attained at x = exp(a) − c).
```

A fixed point in the domain exists **iff** `max_x g(x) ≥ 0`, i.e.

```
c ≥ exp(a)·(1 − a)   =: c_crit(a).
```

This is the sharp existence threshold proved in `FixedPointThreshold.lean`
(necessary direction: `fixedPoint_imp_c_ge_threshold`).

## 2. Threshold table c_crit(a) = exp(a)·(1 − a), a ∈ (0,1)

| a    | c_crit(a) = e^a (1−a) |
|------|-----------------------|
| 0.1  | 0.99465               |
| 0.2  | 0.97712               |
| 0.3  | 0.94490               |
| 0.4  | 0.89510               |
| 0.5  | 0.82436               |
| 0.6  | 0.72885               |
| 0.7  | 0.60413               |
| 0.8  | 0.44511               |
| 0.9  | 0.24596               |
| 1.0  | 0.00000               |

**Reading.** The conjecture's advertised test box is `a ∈ (0,1)`, `c ∈ (0,1)`.
For `a` near `0`, `c_crit → 1`, so essentially the entire strip `c ∈ (0,1)` is
**below threshold** and has *no fixed point*. Only a thin sliver near `a ≈ 1`
admits one. The literal test case is therefore false for most of the box.

## 3. Counterexample hunt for the literal test case (a = c = 1/2)

`c_crit(0.5) = 0.82436 > 0.5 = c`, so no fixed point is predicted. Direct scan of
`g(x)` over the domain `x > −0.5`:

- `max g = exp(0.5)·(0.5 − 1) + 0.5 = (1 − e^{0.5})/2 ≈ −0.32436 < 0`.
- A dense scan of `g` on `x ∈ (−0.4, 5.6)` returned **no** point with `g(x) > 0`.

Hence `f(x) ≠ x` for all `x` in the domain. This is the concrete falsification
`no_fixedPoint_half_half` in `FixedPointThreshold.lean`.

(Note: on the *full real line* `Real.log(x+c) = log|x+c|` introduces an unphysical
crossing near `x ≈ −1.05`. This is a junk-value artifact, not a fixed point of the
intended operator, which is exactly why the theorems restrict to `x + c > 0`.)

## 4. Boundary behaviour (a on the threshold)

At `c = c_crit(a) = exp(a)·(1 − a)` the unique candidate fixed point is
`x* = exp(a) − c = exp(a)·a`, where `x* + c = exp(a)`, so

```
f'(x*) = exp(a)/(x* + c) = exp(a)/exp(a) = 1.
```

The boundary fixed point is **neutral**, never a contraction. Proved as
`threshold_fixedPoint_neutral`.

## 5. Monotone bracket (above threshold, b > 0)

For an operator that *does* contract (e.g. the catalog instance
`f(x) = exp(1)·log(x + 100)` on `[0, 20]`, well above threshold since
`c_crit(1) = 0`), the operator is monotone increasing, so:

- the orbit from `lo = 0` increases toward `x*`;
- the orbit from `hi = 20` decreases toward `x*`;
- they bracket `x*` at every step with width `→ 0`.

Numerical orbit for `f(x) = e·log(x + 100)` (e ≈ 2.71828):

| n | fⁿ(0)     | fⁿ(20)    | width     |
|---|-----------|-----------|-----------|
| 0 | 0.000000  | 20.000000 | 20.000000 |
| 1 | 12.518150 | 13.013752 | 0.495601  |
| 2 | 12.838756 | 12.850703 | 0.011947  |
| 3 | 12.846491 | 12.846779 | 0.000288  |
| 4 | 12.846677 | 12.846684 | 0.000007  |

The fixed point is `x* ≈ 12.84668`, sandwiched at every step. This is the content
of `certified_enclosure` / `concreteEML_enclosure`.

## Summary

The existence threshold `c ≥ exp(a)·(1 − a)` is sharp; the conjecture's literal
`c ∈ (0,1)` test case is false for most of the parameter box; and where a fixed
point *does* exist with `b > 0`, the iteration self-validates via a monotone
nested bracket. These are exactly the statements formalized (0 sorries) in
`FixedPointThreshold.lean`, `FixedPointBracket.lean`, and
`FixedPointBracketInstance.lean`.
