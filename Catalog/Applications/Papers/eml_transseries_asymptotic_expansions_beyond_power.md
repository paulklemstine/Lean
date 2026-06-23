# Computational Evidence — EML Transseries

This note records the small-case evidence gathered before formalizing the theorems in
`Field.lean`, `AsymptoticComparison.lean`, and `CatalogBridge.lean`.

## 1. The model: transmonomials as `Lex (ℤ →₀ ℝ)`

A transmonomial is a finite product `∏ (level h)^{a_h}` with `a_h ∈ ℝ` and tower height
`h ∈ ℤ` (`h = 1` ↔ `exp x`, `h = 0` ↔ `x`, `h = -1` ↔ `log x`, `h = 2` ↔ `exp(exp x)`).
We represent it by the finitely supported exponent vector `(a_h)_{h∈ℤ}`, ordered
lexicographically with the **highest tower height most significant** (encoded as the
*smallest* `Finsupp` index `-h`, matching Mathlib's `Finsupp.Lex` convention of comparing at
the smallest differing index).

Verified instance facts (Lean `#check inferInstance`):
- `LinearOrder (Lex (ℤ →₀ ℝ))` ✓
- `AddCommGroup (Lex (ℤ →₀ ℝ))` ✓
- `IsOrderedCancelAddMonoid (Lex (ℤ →₀ ℝ))` ✓
- `Field (HahnSeries (Lex (ℤ →₀ ℝ)) ℝ)` ✓  (Mathlib Hahn-series field instance)

So the transseries object is, with no extra axioms, a genuine field.

## 2. Dominance small cases (formal order vs. real growth)

| monomial A      | monomial B        | formal claim (in TransMono) | real asymptotics at +∞                |
|-----------------|-------------------|-----------------------------|----------------------------------------|
| `x^a`           | `exp x`           | `mono 0 a < mono 1 1`       | `x^a = o(exp x)` for every real `a`    |
| `x^3`           | `x^5`             | `mono 0 3 < mono 0 5`       | `x^3 = o(x^5)`                         |
| `(exp x)^n`     | `exp(exp x)`      | `mono 1 n < mono 2 1`       | `(exp x)^n = o(exp(exp x))`            |
| `(log x)^7`     | `x^{0.001}`       | `mono (-1) 7 < mono 0 0.001`| `(log x)^7 = o(x^{0.001})`             |

The decisive non-power-series feature is **row 1**: `exp x` dominates `x^a` for *every* real
`a`, even `a = 10^{100}`.  No Laurent/Puiseux valuation can express this; transseries can.
The analytic side of rows 1 and 3 is discharged in Lean via `Real.isLittleO_pow_exp_atTop`
(and its composition with `Real.tendsto_exp_atTop`).

## 3. Asymptotic comparison theorem — counterexample hunt

Claim: `(∀ g, (g : WithTop TransMono) < (a - b).orderTop) ↔ a = b`.

- If `a = b`, then `a - b = 0`, `orderTop 0 = ⊤`, and every `g` satisfies `↑g < ⊤`. ✓
- If `a ≠ b`, then `a - b ≠ 0`, so `orderTop (a - b) = ↑c` for some transmonomial `c`
  (the leading monomial of the difference).  Instantiating the universal at `g = c` would
  require `↑c < ↑c`, which is false.  So the left side fails. ✓

No counterexample exists; the equivalence is exactly `orderTop_eq_top : orderTop x = ⊤ ↔ x = 0`
wrapped as a quantified asymptotic statement.

## 4. Catalog-bridge sanity checks (positivity is load-bearing)

`Applications/TransseriesDefs.lean` defines `domRel m₁ m₂ := level₁ < level₂ ∨ (level₁ =
level₂ ∧ exp₁ < exp₂)`.  Embedding `m ↦ mono m.level m.exponent`:

- Positive exponents: `domRel ↔ (embed m₁ < embed m₂)`. Checked on
  `(level 0, exp 2)` vs `(level 1, exp 0.5)`: `domRel` true (level 0 < 1) and
  `mono 0 2 < mono 1 0.5` true.  ✓
- **Negative exponent breaks it**: `(level 0, exp 1)` vs `(level 1, exp (-1))`.
  `domRel` says the second dominates (level 1 > 0), but `(exp x)^{-1} → 0` while `x → ∞`,
  so the genuine growth order is *reversed*.  Hence `embed_domRel_iff` requires
  `0 < exponent` on both monomials — the hypothesis is mathematically necessary, not
  cosmetic.

## 5. OEIS

No integer sequence is central to these results (the objects are real-exponent formal
series), so no OEIS lookup applies.
