# Computational Evidence — Torus-Knot OAM Spectra

Before formalizing, we surveyed the `T(2, n)` Alexander-polynomial family
`A_n(X) = 1 − X + X² − ⋯ + X^{n−1}` computationally.

## 1. Small-case Alexander polynomials and their cyclotomic identity

| knot        | n | `A_n(X)`                     | `Φ_{2n}(X)`                  | equal? | deg | det = A_n(−1) |
|-------------|---|------------------------------|------------------------------|--------|-----|---------------|
| trefoil 3₁  | 3 | `X² − X + 1`                 | `Φ₆ = X² − X + 1`            | yes    | 2   | 3             |
| cinquefoil 5₁| 5| `X⁴ − X³ + X² − X + 1`        | `Φ₁₀ = X⁴ − X³ + X² − X + 1` | yes    | 4   | 5             |
| 7₁ = T(2,7) | 7 | `X⁶ − X⁵ + ⋯ + 1`            | `Φ₁₄`                        | yes    | 6   | 7             |
| 9₁ = T(2,9) | 9 | `X⁸ − X⁷ + ⋯ + 1` (n=9 not prime) | `Φ₁₈ · Φ₆`? see note    | —      | 8   | 9             |

Note: for **prime** `n = p`, `A_p = Φ_{2p}` exactly. For composite odd `n`
(e.g. `n = 9`), `A_n` factors further (`A_9 = Φ_18 · Φ_6`), because
`(X+1)·A_n = X^n + 1` and `X^n + 1 = ∏_{d | 2n, d ∤ n} Φ_d`. This is precisely why
the clean "single cyclotomic" statement is stated for prime `p`; the composite case
is flagged as a future direction.

## 2. Degree / OAM channel count

`deg A_p = φ(2p) = φ(p) = p − 1` for odd prime `p`:
`3 → 2`, `5 → 4`, `7 → 6`, `11 → 10`. The identity `φ(2p) = φ(p)` was checked for
all odd `n ≤ 99` and holds (it is exactly Euler's `φ(2n) = φ(n)` for odd `n`).

## 3. Roots on the unit circle (crystalline vs metallic)

For `T(2,p)` all roots are primitive `2p`-th roots of unity — modulus exactly `1`.
Contrast the figure-eight `4₁` (not a torus knot): `Δ = X² − 3X + 1` has real roots
`φ^{±2} = (3 ± √5)/2 ≈ 2.618, 0.382`, off the unit circle. Discriminant test
`b² − 4` for `X² − bX + 1`: `b ∈ {−1,0,1}` ⇒ on circle; `|b| ≥ 2` ⇒ real. The
trefoil (`b = 1`) is crystalline; the figure-eight (`b = 3`) is metallic. This is the
smallest crystalline/metallic dichotomy and motivates future direction §5.

## 4. Determinant and 3-colorability

`det T(2,p) = |A_p(−1)| = p`. Since `p` is prime, `3 | det ⇔ p = 3`: only the trefoil
among `T(2,p)` is 3-colorable. Checked: `3,5,7,11 → det 3,5,7,11`; only `3` divisible
by `3`.

## Conclusion

The computational landscape confirms every claim we then proved formally, and it
sharpened the statements: cyclotomic identification is exact **only for prime** `p`,
which is the hypothesis used in the proofs.
