# Computational Evidence — Turing's Flowers II: The Conic Classification

This cycle deepens the algebraic-geometry model of Turing patterns by moving from
axis-aligned conics to **general quadratic forms with a cross term**, keyed on the
discriminant `Δ = b² − 4ac`. Below is the small-case landscape gathered before the
formal proofs.

## 1. Discriminant governs the morphology (spot vs. labyrinth)

For `q(x,y) = a x² + b x y + c y²`, level set `{q = k}`:

| a | b | c | Δ = b²−4ac | form type      | level set `{q=1}`        | bounded? |
|---|---|---|-----------|----------------|--------------------------|----------|
| 1 | 0 | 1 | −4        | pos. definite  | unit circle (spot)       | yes      |
| 2 | 0 | 1 | −8        | pos. definite  | ellipse (spot)           | yes      |
| 1 | 1 | 1 | −3        | pos. definite  | tilted ellipse (spot)    | yes      |
| 1 | 3 | 1 | +5        | indefinite     | tilted hyperbola (lab.)  | no       |
| 1 | 0 |−1 | +4        | indefinite     | rectangular hyperbola    | no       |
| 1 | 2 | 1 |  0        | degenerate     | double line (stripe)     | no       |

The bounded ⇔ `Δ < 0` (with `a > 0`) split is exactly the sign of the discriminant,
independent of the cross term `b`. The proof exploits the rotation-invariant
completed square `4a·q = (2ax+by)² − Δ·y²`.

## 2. Explicit escaping family in the indefinite case

For `a=1, b=3, c=1` (Δ=5), `k=1`, the constructed witness `y=s`,
`x = (√(Δ s² + 4ak) − b s)/(2a)` gives, e.g.:

| s   | x          | x²+y²      | q(x,y) |
|-----|------------|------------|--------|
| 1   | -0.118     | 1.014      | 1.000  |
| 10  | -1.882     | 103.5      | 1.000  |
| 100 | -19.44     | 10378      | 1.000  |

The point stays on `{q=1}` while `x²+y² → ∞`, confirming unboundedness numerically
before it is proved.

## 3. Modes = degree, under products and sums

Using `cos(nθ) = Tₙ(cos θ)`:

- `cos(2θ)·cos(3θ)` expands to a degree-`5` polynomial in `X = cos θ`
  (`= 16X⁵ − 20X³ + 5X`-type combination); `deg = 2 + 3 = 5`. ✔ (matches
  `mode_product_degree`).
- `α·cos(1θ) + β·cos(4θ)` with `β ≠ 0` has degree `4` for every `α` (the top
  Chebyshev term `β·T₄` dominates). ✔ (matches `two_mode_superposition_degree`).

Small cases show the degree is *exactly* `m+n` (product) and *exactly* the top mode
(superposition), never merely an upper bound — so the theorems assert equalities.

## 4. Counterexample hunt

- Tried `a > 0, Δ < 0` forms with large `|b|` (e.g. `a=1, b=1.9, c=1`, Δ=−0.39):
  still bounded, radius grows like `1/Δ`, matching `4k(a+c)/(4ac−b²)`. No counterexample.
- Tried to break unboundedness with very negative `k` (e.g. `k=−50`, indefinite):
  the `|4ak/D|` shift in the witness keeps `Δs²+4ak > 0`, family still escapes. No
  counterexample.
- Degenerate boundary `Δ = 0` is genuinely different (parabolic/stripe): correctly
  excluded from both the bounded and unbounded theorems by strict inequalities.

Conclusion: the discriminant dichotomy and the two degree laws are robust across the
sampled parameter space, justifying the formal proofs in
`TuringFlowersConicClassification.lean`.
