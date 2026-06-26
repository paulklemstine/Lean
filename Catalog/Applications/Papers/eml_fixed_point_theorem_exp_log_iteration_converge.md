# Computational Evidence — EML Fixed-Point Quantitative Convergence

Operator under test: `f(x) = exp(a)·log(b·x + c)` with `a = 0, b = 1, c = 2`,
i.e. `f(x) = log(x + 2)`, iterated from `x₀ = 1`. All numbers below are `Float`
computations (Lean `#eval`).

## 1. Orbit and fixed point

`xₙ = iter n 1.0` for `n = 0..11`:

```
1.000000, 1.098612, 1.130954, 1.141338, 1.144649, 1.145702,
1.146037, 1.146144, 1.146177, 1.146188, 1.146192, 1.146193
```

The orbit converges to `x* ≈ 1.146193`, the unique solution of `x = log(x + 2)`.
The contraction factor at the fixed point is `f'(x*) = 1/(x*+2) ≈ 0.317844 < 1`,
so the interval contraction hypotheses of `EMLContractionData` are satisfiable
(e.g. on `[1, 1.2]` one may take `ρ = 0.34`).

## 2. Geometric decay of consecutive steps (`iterSeq_geometric_decay`)

`|xₙ₊₁ − xₙ|` for `n = 0..7`:

```
0.098612, 0.032342, 0.010384, 0.003311, 0.001053, 0.000335, 0.000106, 0.000034
```

Successive ratios ≈ `0.328, 0.321, 0.319, 0.318, …` → `f'(x*) ≈ 0.318`, exactly the
geometric rate predicted by the theory.

## 3. A priori bound (`iterSeq_apriori_bound`), `ρ = 0.34`

Pairs `(actual error |xₙ − x*|,  bound |x₁−x₀|·ρⁿ/(1−ρ))`:

```
(0.146193, 0.149413)
(0.047581, 0.050800)
(0.015239, 0.017272)
(0.004855, 0.005873)
(0.001544, 0.001997)
(0.000491, 0.000679)
(0.000156, 0.000231)
```

The bound dominates the actual error in every row. ✓

## 4. A posteriori bound (`iterSeq_aposteriori_bound`), `ρ = 0.34`

Pairs `(actual error |xₙ₊₁ − x*|,  bound (ρ/(1−ρ))·|xₙ₊₁−xₙ|)`:

```
(0.047581, 0.050800)
(0.015239, 0.016661)
(0.004855, 0.005349)
(0.001544, 0.001706)
(0.000491, 0.000543)
(0.000156, 0.000173)
```

The a posteriori bound is tighter than the a priori bound and still dominates the
actual error in every row. ✓

## 5. Counterexample hunt

No counterexample to either inequality was found across the sampled iterates with
`ρ = 0.34`. The bounds degenerate (denominator `1 − ρ → 0`) only as `ρ → 1`, exactly
the boundary excluded by `D.rho_lt_one`; this is consistent with the formal statements.

## OEIS

The orbit is a transcendental real sequence (decimal expansions), not an integer
sequence, so no OEIS entry applies.
