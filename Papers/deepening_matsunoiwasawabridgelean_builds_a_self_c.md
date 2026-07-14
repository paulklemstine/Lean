# Computational Evidence

The main results are *structural identities* (a monoid homomorphism, additivity,
and an equality of two invariants), so the relevant "evidence" is a set of small
worked instances that the Lean file discharges by `rfl`/rewriting. All values below
are machine-checked inside `Catalog/Bridges/MatsunoIwasawaMonoidHom.lean`.

## 1. Small-case values of `(μ, λ)`

Working with `p = 2` throughout, `μ_p(f) = padicValInt p (content f)` and
`λ_p(f) = natTrailingDegree (reduce_p (primPart f))`.

| `f`                    | `content` | `μ₂(f)` | `primPart` | `λ₂(f)` |
|------------------------|-----------|---------|------------|---------|
| `1`                    | `1`       | `0`     | `1`        | `0`     |
| `X`                    | `1`       | `0`     | `X`        | `1`     |
| `X^n`                  | `1`       | `0`     | `X^n`      | `n`     |
| `C (2^k)`              | `2^k`     | `k`     | `1`        | `0`     |
| `twistFactor 2 c k`    | `2^k`     | `k`     | `X^(c·k)`  | `c·k`   |

For the highlighted instance `twistFactor 2 2 3 = C 8 · X⁶`:
`μ₂ = 3`, `λ₂ = 6 = 2·μ₂`. (Verified: `example : lambdaInv 2 (twistFactor 2 2 3) = 6`.)

## 2. Homomorphism / additivity checks

`iwasawaHom 2` sends `X ↦ ofAdd (0,1)` (verified as an `example`). Additivity was
sampled on products such as `C 4 · X^2 · (C 2 · X^5)`:

* `μ₂ = 2 + 1 = 3`, `λ₂ = 2 + 5 = 7`,

matching `μ₂(fg) = μ₂ f + μ₂ g` and `λ₂(fg) = λ₂ f + λ₂ g`. These are exactly the
`map_mul'` obligations proved for `iwasawaHom`.

## 3. Counterexample hunt (hypothesis necessity)

* **Nonzero hypotheses are load-bearing.** Additivity fails without `f ≠ 0`: taking
  `f = 0` makes `content 0 = 0`, `padicValInt p 0 = 0`, and `primPart 0 = 0`, so both
  invariants collapse and `μ(0·g) = 0 ≠ μ(0) + μ(g)` in general. This is why the
  homomorphism is stated on `ℤ[X]⁰ = nonZeroDivisors ℤ[X]`.
* **Divisibility monotonicity** was tested on `X ∣ X^3`: `λ₂(X) = 1 ≤ 3 = λ₂(X^3)`
  and `μ₂(X) = 0 ≤ 0 = μ₂(X^3)`; no counterexample found among the sampled divisor
  pairs, consistent with the proved `*_le_of_dvd` lemmas.

## 4. Order-of-vanishing bridge

`lambdaInv_eq_rootMultiplicity` was cross-checked against
`rootMultiplicity_eq_natTrailingDegree'`: for `reduce_2 (primPart (X^n)) = X^n`,
`rootMultiplicity 0 (X^n) = n = natTrailingDegree (X^n)`, matching `λ₂(X^n) = n`.

No counterexamples were found. The evidence is fully consistent with — and, in the
Lean file, upgraded to proofs of — the stated theorems.
