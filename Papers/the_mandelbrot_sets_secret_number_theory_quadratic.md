# Computational Evidence — Quadratic Recurrence `z ↦ z² + c`

This note records the small-case evidence gathered before formalizing the results in
`MandelbrotQuadraticRecurrence.lean`.

## 1. Escape dynamics: `|c| > 2 ⇒ orbit escapes`

The critical orbit is `x₀ = 0`, `x₁ = c`, `x_{n+1} = x_n² + c`. Testing the modulus of
the orbit for a few real `c` (worst case, since real slices minimize growth):

| c    | |x₁| | |x₂|  | |x₃|     | |x₄|        |
|------|------|-------|----------|-------------|
| 2.1  | 2.1  | 6.51  | 44.48    | 1980.6      |
| 2.5  | 2.5  | 8.75  | 79.06    | 6251.0      |
| 3.0  | 3.0  | 12.0  | 147.0    | 21612.0     |
| -2.5 | 2.5  | 3.75  | 11.56    | 131.16      |

In every case `|x_n|` is strictly increasing once `|c| > 2`, and the one-step bound
`|x_{n+1}| ≥ |x_n|·(|x_n| − 1)` holds. The geometric lower bound
`|x_{n+1}| ≥ |c|·(|c| − 1)ⁿ` is confirmed: e.g. for `c = 3`, `|c|·(|c|−1)² = 3·4 = 12`
against actual `|x₃| = 147 ≥ 12`. This is the content of `norm_orbit_ge_geometric` and
`orbit_unbounded_of_two_lt`.

Boundary sanity check: `c = -1` (inside `M`) gives the bounded cycle `0, -1, 0, -1, …`,
and `c = 0.25` (parabolic root of the cardioid) stays bounded — consistent with
`M ⊆ closedBall 0 2` being a containment, not an equality.

## 2. Bulb periods = additive order of `p` in `ℤ/qℤ`

For rotation number `p/q`, the period is `addOrderOf (p mod q) = q / gcd(q, p)`:

| p/q  | gcd(p,q) | period | lowest terms? |
|------|----------|--------|---------------|
| 1/2  | 1        | 2      | yes           |
| 1/3  | 1        | 3      | yes           |
| 2/3  | 1        | 3      | yes           |
| 2/4  | 2        | 2      | no (= 1/2)    |
| 3/6  | 3        | 2      | no (= 1/2)    |
| 5/12 | 1        | 12     | yes           |
| 8/12 | 4        | 3      | no (= 2/3)    |

Every `p/q` in lowest terms has period exactly `q` (`bulb_period_coprime`), and every
reducible fraction has period `< q` (`bulb_period_lt_of_not_coprime`). This is the
precise, provable form of the "period of the bulb at angle p/q is q" claim.

## 3. Fibonacci spiral: coprimality and Cassini determinant

Consecutive Fibonacci numbers `1,1,2,3,5,8,13,21,…`:

- `gcd(F_n, F_{n+1}) = 1` for all `n` (`fib_ratio_lowest_terms`), so every
  Fibonacci fraction `F_n/F_{n+1}` is already in lowest terms — the "golden" bulbs
  are always primitive.
- Cassini: `F_{n+1}² − F_n·F_{n+2} = (−1)ⁿ`. Check: `n=4`, `5² − 3·8 = 25 − 24 = 1 = (−1)⁴`;
  `n=5`, `8² − 5·13 = 64 − 65 = −1 = (−1)⁵`. Unit determinant ⇒ Farey neighbours
  (`fib_cassini`, `fib_farey_neighbours`).

## 4. Counterexample hunt on the mission's Lyapunov claim

The mission text asserts `λ(c) = log 2 · cos(π p/q)` at the centre of the `p/q` bulb.
For the period-2 centre `c = −1` the multiplier of the 2-cycle is `4c + 4 = 0`, so the
centre is *superattracting* and the finite-time Lyapunov exponent of the cycle is `−∞`,
not `log 2 · cos(π/2) = 0`. The claim is therefore not correct as stated, so it was
**not** formalized; the robust arithmetic replacement (period = additive order) was
proved instead. This is documented in the Lab Notes "Analysis" block.

## OEIS references

- Fibonacci numbers: **A000045**.
- The signed Cassini values `(−1)ⁿ` form **A033999**.
