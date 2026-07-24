# Computational Evidence: Strictly Convex Radiator Laws

We collect small-case evidence for the two claims formalized in
`DysonConvexRadiator.lean`:

1. **Equal-area optimality.** For a strictly convex cost `f` and fixed total area
   `A` shared among `n` collectors, the total cost `∑ f(aᵢ)` is minimized uniquely
   by `aᵢ = A/n`.
2. **Splitting law.** If `f(0) ≤ 0` and `f` is strictly convex, then
   `f(a₁) + f(a₂) < f(a₁ + a₂)` for `a₁, a₂ > 0`.

## 1. Equal-area optimality — small cases

Quadratic law `f(x) = x²`, total area `A = 6`.

| allocation (n=3)   | cost ∑ aᵢ² | uniform cost A²/n = 12 |
|--------------------|-----------|------------------------|
| (2, 2, 2)          | 12        | 12  (attained)         |
| (1, 2, 3)          | 14        | 12                     |
| (0, 3, 3)          | 18        | 12                     |
| (1, 1, 4)          | 18        | 12                     |

Exponential law `f(x) = eˣ` (strictly convex), `A = 3`, `n = 3`:

| allocation | cost ∑ e^{aᵢ}        | uniform 3·e¹ ≈ 8.1548 |
|------------|----------------------|------------------------|
| (1,1,1)    | 3e ≈ 8.1548          | attained               |
| (0,1,2)    | 1+e+e² ≈ 11.107      | larger                 |
| (0.5,1,1.5)| e^.5+e+e^1.5 ≈ 8.638 | larger                 |

Entropic law `f(x) = x·log x` on `x>0` (strictly convex), `A = 3`, `n = 3`:
`(1,1,1)` gives `0`; `(0.5,1,1.5)` gives `≈ -0.3466 + 0 + 0.6082 = 0.2616 > 0`.

In every sampled non-uniform allocation the cost strictly exceeds the uniform
value, consistent with the theorem; no counterexample was found.

## 2. Splitting law — small cases

Quadratic `f = x²`, `f(0) = 0`:
`1² + 1² = 2 < 4 = 2²`; `2² + 3² = 13 < 25 = 5²`. Holds.

Exponential `f = eˣ`, but `f(0) = 1 > 0`, so the hypothesis `f(0) ≤ 0` FAILS and
the law need not hold: `e¹ + e¹ = 5.44 > e² = 7.39`? Actually `5.44 < 7.39`, so it
happens to hold here, but with tiny areas it fails: `e^{0.1}+e^{0.1} = 2.21 >
e^{0.2} = 1.22`. This confirms the necessity of the `f(0) ≤ 0` hypothesis: an
overhead cost `f(0) > 0` penalizes additional panels and can reverse the law.

Shifted law `g(x) = x² − 1`, `g(0) = −1 ≤ 0`: `g(1)+g(1) = 0 < g(2) = 3`. Holds,
and the strict margin grows, matching the proof that the gap is at least `−f(0)`.

## Conclusion

The universal claims survive all sampled cases. The splitting counterexample hunt
pins down `f(0) ≤ 0` as the exact structural hypothesis, which is reflected in the
formal statement of `split_strict`.
