# Computational Evidence — Matsuno-type μ-contribution to the λ-invariant

All numbers below are **machine-checked** inside
`MatsunoIwasawaBridge.lean`: because `Polynomial ℤ`, `Polynomial.primPart`
and `padicValInt` are `noncomputable`, the invariants cannot be `#eval`-ed,
so instead each concrete instance is discharged as a Lean `example` from the
general theorems.

## Model of the invariants

For `f = Σ aᵢ Xⁱ ∈ ℤ[X]` and a prime `p`:

* `μ_p(f) = padicValInt p (f.content) = minᵢ v_p(aᵢ)`
* `λ_p(f) = natTrailingDegree (reduce_p (f.primPart)) = min { i : v_p(aᵢ) = μ_p(f) }`

These are the polynomial shadows of the Iwasawa invariants of a
characteristic element in `Λ = ℤ_p[[T]]`.

## The twist factor `twistFactor p c k = C(pᵏ) · X^{c·k}`

| p | c | k | twist factor | μ  | λ  | λ / μ |
|---|---|---|---------------|----|----|-------|
| 2 | 1 | 1 | `2·X`         | 1  | 1  | 1     |
| 2 | 2 | 3 | `8·X⁶`        | 3  | 6  | 2     |
| 2 | 3 | 2 | `4·X⁶`        | 2  | 6  | 3     |
| 3 | 2 | 2 | `9·X⁴`        | 2  | 4  | 2     |
| 5 | 4 | 1 | `5·X⁴`        | 1  | 4  | 4     |

In every row `λ = c · μ`, i.e. the λ-invariant carries a term exactly
proportional to the μ-invariant. This is `lambdaInv_twistFactor_eq_const_mul_muInv`.

The `p = 2, c = 2, k = 3` row is verified verbatim in the Lean file:

```lean
example : lambdaInv 2 (twistFactor 2 2 3) = 6 := by rw [lambdaInv_twistFactor]
example : muInv 2 (twistFactor 2 2 3) = 3 := by rw [muInv_twistFactor]
example : lambdaInv 2 (twistFactor 2 2 3) = 2 * muInv 2 (twistFactor 2 2 3) :=
  lambdaInv_twistFactor_eq_const_mul_muInv 2 2 3
```

## Twisting a base characteristic element

Take `f = X² + 2X + 4` at `p = 2`. Then `μ_2(f) = 0` (content `= gcd(4,2,1) = 1`,
so the coefficient `1` of `X²` is already a 2-adic unit) and `λ_2(f) = 2` (the
reduction mod 2 is `X² + 0·X + 0 = X²`, whose trailing degree is `2`). Multiplying
by `twistFactor 2 2 3 = 8·X⁶` gives, by additivity:

* `μ_2(f · twist) = μ_2(f) + 3 = 3`
* `λ_2(f · twist) = λ_2(f) + 6 = 8`

so the λ-invariant jumps by `6 = 2·μ(twist)`, a **non-vanishing** correction
driven entirely by the non-zero μ-invariant of the twist. The general form is
`matsuno_twist_formula` / `matsuno_nonvanishing_mu`, and the concrete jump of
`6` is checked as an `example` in the file.

## Counterexample hunt (the μ = 0 boundary)

The claim is that the μ-proportional term appears **only when μ ≠ 0**. Setting
`k = 0` gives `twistFactor p c 0 = C 1 · X⁰ = 1`, with `μ = 0` and `λ = 0`, so
`λ(f · 1) − λ(f) = 0`: the correction term vanishes exactly at `μ = 0`, with no
counterexample. This is consistent with `matsuno_twist_formula` (the term
`c · μ` is `0` when `μ = 0`).

## OEIS

No integer sequence beyond the trivial arithmetic progressions `λ = c·k`
arises here, so no OEIS lookup is relevant.
