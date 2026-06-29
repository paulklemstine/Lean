# Computational Evidence — Topological Generalization Bounds

We study the McAllester-style penalty with a **topological complexity** term
`topoComplexity(b₁) = log(1 + b₁)`:

```
term(b₁, n, δ) = sqrt( (log(1+b₁) + log(2·√n / δ)) / (2·(n-1)) )
```

## 1. Monotonicity in the first Betti number `b₁` (fixed n = 1000, δ = 0.05)

| b₁  | term       |
|-----|------------|
| 0   | 0.059791   |
| 1   | 0.062625   |
| 5   | 0.066871   |
| 50  | 0.074450   |

The penalty is strictly increasing in `b₁`: more independent cycles in weight
space ⇒ a looser bound. (Formalized as `topoGenBound_mono_betti`.)

## 2. Consistency as the sample size grows (fixed b₁ = 10, δ = 0.05)

| n         | term       |
|-----------|------------|
| 10        | 0.634125   |
| 100       | 0.205841   |
| 1000      | 0.069102   |
| 100000    | 0.007695   |
| 10000000  | 0.000841   |

The penalty → 0 as n → ∞ at the expected `Θ(√((log n)/n))` rate: the constant
topological term is dominated by the linearly-growing denominator. (Formalized as
`topoGenBound_tendsto_empRisk`.)

## 3. Acyclic case (`b₁ = 0`)

`topoComplexity(0) = log 1 = 0`, so the bound collapses to the pure data term
`empRisk + sqrt(log(2√n/δ)/(2(n-1)))`. This is the learning-theoretic shadow of
`H¹ = 0` on the total space, proved in `CohomologyCapacity.lean` via the catalog
theorem `cocycle_eq_coboundary_on_total`.

## Counterexample hunt

No counterexample to monotonicity or consistency was found in the sampled range.
The only boundary failure is at `n = 1` (denominator `2(n-1) = 0`); both the
monotonicity and the limit statements are guarded so this degenerate point is
excluded.

## OEIS

No integer sequence is central here (the objects are real-valued bounds); no OEIS
lookup applies.
