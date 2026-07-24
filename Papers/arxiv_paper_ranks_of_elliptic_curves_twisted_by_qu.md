# Computational Evidence

## 1. Fibration parameters are sums of two squares

For `d = 1 + t²`:

| t | d = 1 + t² | representation u² + v² |
|---|-----------|-----------------------|
| 0 | 1  | 1² + 0²  (also 1 = 1² + 0²) |
| 1 | 2  | 1² + 1² |
| 2 | 5  | 1² + 2² |
| 3 | 10 | 1² + 3² |
| 4 | 17 | 1² + 4² |
| 5 | 26 | 1² + 5² |
| 6 | 37 | 1² + 6² |

Each is manifestly `1² + t²`, confirming `fibration_param_sum_two_squares`.

## 2. Multiplicative closure (Brahmagupta–Fibonacci)

`(1² + 1²)(1² + 2²) = 2 · 5 = 10 = (1·1 − 1·2)² + (1·2 + 1·1)² = (−1)² + 3² = 1 + 9 = 10.`
`(1² + 2²)(1² + 3²) = 5 · 10 = 50 = (1 − 6)² + (3 + 2)² = 25 + 25 = 50.`

Confirms `sum_two_squares_mul`.

## 3. Discriminant scaling under twist

Base `y² = x³ + a x + b`, `Δ = -16(4a³ + 27b²)`. Twist coefficients `(a d², b d³)`:

`Δ' = -16(4 a³ d⁶ + 27 b² d⁶) = d⁶ · (-16(4a³ + 27b²)) = d⁶ Δ.`

Spot check `a = -1, b = 0, d = 2`: `Δ = -16·(-4) = 64`; twist `a' = -4, b' = 0`,
`Δ' = -16·(4·(-64)) = 4096 = 2⁶ · 64 = 64 · 64`. Confirms `twist_disc`.

## 4. Twist ↔ standard-model isomorphism

Curve `y² = x³ - x` (`a = -1, b = 0`), twist parameter `d = 2`:
twist equation `2 y² = x³ - x` has the point `(x, y) = (-1, 0)`.
Under `(x, y) ↦ (2x, 4y) = (-2, 0)` this lands on
`Y² = X³ - 4X`: `0 = -8 + 8 = 0`. Confirms `twist_to_std` and `twistEquiv`.

## 5. Infinitude sanity

`t ↦ 1 + t²` on ℕ is strictly increasing (`0 < t < s ⇒ 1+t² < 1+s²`), hence injective,
so `{n : ℤ | n is a sum of two squares}` is infinite. Confirms
`infinite_sum_two_squares`. (Sequence `1, 2, 5, 10, 17, 26, 37, …` is OEIS A002522,
`n² + 1`, a subsequence of the sums of two squares A001481.)

All computational checks are consistent with the formalized theorems; no
counterexamples were found.
