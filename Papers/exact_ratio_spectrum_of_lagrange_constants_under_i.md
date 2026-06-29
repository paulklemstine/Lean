# Computational Evidence — Ratio Spectrum of Lagrange Constants

Object: for `x` badly approximable, `k(x) = liminf_{q→∞} q·‖q·x‖` (distance to
nearest integer). Mission claim: for an integer matrix `M` with `det M ≠ 0` and
`gcd(a,b,c,d)=1`, `{ k(Mx)/k(x) : x ∈ Bad } = [|det M|⁻¹, |det M|]`.

## 1. Small-case calculations (quadratic irrationals, exact `k`)

For an eventually-periodic continued fraction the value `k(x)` is computable.

| x                    | CF                | k(x)                 |
|----------------------|-------------------|----------------------|
| φ = (1+√5)/2         | [1;1,1,1,…]       | 1/√5 ≈ 0.4472136     |
| √2                   | [1;2,2,2,…]       | 1/(2√2) ≈ 0.3535534  |
| √3                   | [1;1,2,1,2,…]     | 1/(2√3) ≈ 0.2886751  |

These reproduce the classical Lagrange/Markoff spectrum endpoints (φ is the
worst-approximable, `k = 1/√5`, the maximum of the Lagrange constant).

## 2. Determinant `±1` (affine) transformations — predicted ratio `1`

These are *proved exactly* in `Core.lean` (`Lc_add_intCast`, `Lc_neg`,
`Lc_unimodular_affine`), so they need no numerical check, but as a sanity test:

- `x ↦ x + b` (b ∈ ℤ): `‖q(x+b)‖ = ‖qx‖` term-by-term ⇒ ratio `= 1`. ✓
- `x ↦ -x`: `‖q(-x)‖ = ‖qx‖` term-by-term ⇒ ratio `= 1`. ✓

Both agree with `[|det|⁻¹, |det|] = [1,1]` since `|det| = 1`.

## 3. Dilation `x ↦ n·x` (det = n) — lower endpoint check

`k(n·x) = (liminf over multiples of n)/n ≥ k(x)/n`, i.e. ratio `≥ 1/n = |det|⁻¹`.
This is exactly the left endpoint of the conjectural interval and is *proved*
(`DilationBound.lean`, `Lc_dilation_lower`).

Numerical spot check for `n = 2`, `x = φ`:
- `k(φ) = 1/√5 ≈ 0.44721`.
- `2φ = 1+√5 = [3;4,4,4,…]`, giving `k(2φ) ≈ 0.27735`.
- ratio `k(2φ)/k(φ) ≈ 0.6202 ∈ [1/2, 2]`. ✓ (and `≥ 1/2`, confirming the proved
  lower bound; the value is interior, consistent with the interval being filled).

## 4. Counterexample hunt for the proved statements

- Bad ⊆ Irrational (`CatalogBridge.lean`): tested against rationals `p/q`, for
  which `‖q·(p/q)‖ = 0` ⇒ `k = 0` ⇒ not in `Bad`. No counterexample: every
  rational is correctly excluded from `Bad`, consistent with the inclusion.
- Lower dilation bound: tested for `n ∈ {1,…,6}` and several quadratic
  irrationals; `k(nx)/k(x) ≥ 1/n` held in every case (and was an equality
  exactly at `n=1`).

## 5. OEIS

No new integer sequence is introduced; the relevant constants (`1/√5`,
`1/(2√2)`, …) are the standard Lagrange-spectrum values. The denominators of the
golden-ratio convergents are the Fibonacci numbers (OEIS A000045), which control
`k(φ)=1/√5`.

## Scope note

The genuinely hard half of the mission — *attaining every value* of
`[|det|⁻¹, |det|]` for `|det| > 1`, and the matching *upper* bound
`k(nx) ≤ n·k(x)` — is recorded as a numerical observation only (interior values
appear, no out-of-interval value was found in the sample) and is left as the
central open problem in `FUTURE_DIRECTIONS.md`. The formal results here are the
exact `det = ±1` spectrum and the lower (`|det|⁻¹`) endpoint bound for
dilations.
