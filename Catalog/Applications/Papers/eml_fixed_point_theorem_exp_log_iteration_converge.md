# Computational Evidence — EML Fixed-Point Sensitivity & Neural Contraction Bridge

This note records the small-case numerical evidence gathered before formalizing
the two Lean files of this cycle:

* `EML/FixedPointSensitivity.lean`
* `Bridges/EMLNeuralContractionBridge.lean`

The EML single operator is `f(x) = exp(a)·log(b·x + c)`; throughout we take
`b = 1`.

## 1. First-order sensitivity `dx*/da`

Claim (formalized as `EMLIterOp.fixedPointBranch_deriv_eq`):
the fixed point `x*(a)` satisfies

```
dx*/da = x* / (1 − ρ) = x*·(x*+c) / (x*+c − exp a),   ρ = exp a /(x*+c) = f'(x*).
```

Test (`#eval`, c = 2, a = 0.5; `x*` obtained by 200 iterations):

| quantity                               | value     |
|----------------------------------------|-----------|
| `x*`                                   | 2.468061  |
| `ρ = exp a /(x*+c)`                    | 0.369002  |
| formula slope `x*/(1−ρ)`               | 3.911358  |
| finite difference `(x*(a+h)−x*(a−h))/2h`| 3.911358  |
| closed form `x*(x*+c)/(x*+c−exp a)`    | 3.911358  |

The analytic formula and the central finite difference agree to all printed
digits, confirming the implicit-differentiation derivation. The slope is positive
(equilibrium increases with `a`), refining the catalog's qualitative
`fixedPoint_lt_of_a_lt` into an exact rate.

## 2. Non-degeneracy condition

The formula's denominator `x*+c − exp a` is exactly the implicit-function
non-degeneracy quantity. It vanishes precisely on the neutral threshold
`c = exp(a)(1−a)` analysed in `EML/FixedPointThreshold.lean`, where `ρ = 1` and
the slope blows up — the fold bifurcation where the attracting and repelling
branches (see `EML/FixedPointStability.lean`) collide. This is consistent across
the catalog's existing existence dichotomy and the new sensitivity result.

## 3. Neural-contraction bridge ratio

For the concrete instance `f(x) = exp(1)·log(x + 100)` on `[0,20]`
(`EML/FixedPointConcreteInstance.lean`), the contraction ratio is `ρ = 1/30`.
The bridge file certifies the clamped EML residual block is `(1+ρ) = 31/30`
-Lipschitz and that a depth-`K` stack obeys `(1+1/30)^K ≥ 1 + K/30`
(Bernoulli floor). Sanity values:

| K  | `1 + K/30` (floor) | `(1+1/30)^K` |
|----|--------------------|--------------|
| 1  | 1.0333             | 1.0333       |
| 5  | 1.1667             | 1.1779       |
| 20 | 1.6667             | 1.9509       |

The Bernoulli lower bound holds with increasing slack, as expected for a
genuinely convex `(1+ρ)^K`.

## Counterexample hunt (literal conjecture)

The conjecture's literal universal test case (`a ∈ (0,1)`, `b = 1`, `c ∈ (0,1)`)
is already known to be **false** in part of the box (no fixed point when
`c < exp(a)(1−a)`; e.g. `a = c = 1/2`), recorded in
`EML/FixedPointThreshold.lean` / `EML/FixedPointExistenceDichotomy.lean`. This
cycle therefore targets the *quantitative* structure on the admissible region
rather than re-testing the falsified universal claim.
