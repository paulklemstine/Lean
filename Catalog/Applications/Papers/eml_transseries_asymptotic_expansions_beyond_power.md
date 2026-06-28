# Computational Evidence — EML Transseries cycle (residue map · dense value group · comparability)

This cycle extends the existing rigorous Hahn-series model of transseries
(`TSeries = HahnSeries (Lex (ℤ →₀ ℝ)) ℝ`) with three structural layers. The claims are
*structural* (about an uncountable value group and a field), so the role of computation is to
sanity-check the small concrete instances that the theorems generalize.

## 1. Leading-coefficient / residue map (`LeadingTerm.lean`)

The leading coefficient `lc : TSeries → ℝ` is claimed to be a **multiplicative** homomorphism
(but not additive). Small checks on one-term transseries `term h a = (level h)^a` with
coefficient `1`:

| product | leading transmonomial | lc |
| --- | --- | --- |
| `term 1 1 · term 1 1` | `mono 1 2` | `1 = 1·1` ✓ |
| `(C 3) · term 0 1` | `mono 0 1` | `3 = 3·1` ✓ |
| `term 0 1 + C 1`  (= `x + 1`) | `mono 0 0` (the constant `1` dominates `x`) | `1 ≠ lc(x)+lc(1)=2` |

The last row is the **counterexample to additivity**: `lc` is a monoid hom only. This matches
valuation theory (residue maps are multiplicative).

## 2. Dense value group (`DenseValueGroup.lean`)

Order type of `Lex (ℤ →₀ ℝ)` vs the Laurent group `ℤ`:

| group | between `0` and `1`? | minimum? | maximum? |
| --- | --- | --- | --- |
| `ℤ` (Laurent) | **none** (discrete) | none | none |
| `Lex (ℤ →₀ ℝ)` (transseries) | yes: e.g. `mono 0 (1/2)` lies strictly between `mono 0 0` and `mono 0 1` | none | none |

Interpolation witness used in the proof: given `g < g'` differing first at index `j`, the
midpoint coefficient `(f j + f' j)/2` produces a strictly intermediate transmonomial. Concrete
instance: between `x⁰ = 1` and `x¹` sits `x^{1/2}` — exactly the half-power whose *existence*
(`RealClosureIngredients.isSquare_term`) is what fails over `ℤ`-exponents. The same half-step
is impossible in `ℤ`, confirmed by `omega` (no `k` with `0 < k < 1`).

## 3. Comparability classes (`Comparability.lean`)

`a ≍ b` iff `orderTop a = orderTop b`. Small table of growth orders:

| `a` | `orderTop a` | class representative |
| --- | --- | --- |
| `x`   | `mono 0 1` | `[x]` |
| `2x`  | `mono 0 1` | `[x]`  (same — constants are scale-invariant) |
| `x²`  | `mono 0 2` | `[x²]` (different) |
| `exp x` | `mono 1 1` | `[exp x]` |

Verified facts: `x ≍ 2x` (`sameOrder_two_mul_varX`) and `¬ (x ≍ x²)`
(`not_sameOrder_varX_sq`), reduced to `mono 0 1 ≠ mono 0 2`, i.e. `1 ≠ 2` after evaluating the
finsupp at index `0`.

## OEIS / counterexample hunt

No integer sequence arises (the objects are real-exponent monomials). The universal claims
were stress-tested against the natural would-be counterexamples:

- *Additivity of `lc`*: refuted by `x + 1` (above) — so we only claim multiplicativity.
- *Scale invariance for all multipliers*: refuted by `x · a` (shifts valuation) — so the
  hypothesis "nonzero real constant" is kept and is load-bearing.
- *Density over `ℤ`*: refuted by `0,1 ∈ ℤ` — so density is specific to real exponents.

All surviving claims are formalized with `0 sorries` and depend only on
`propext, Classical.choice, Quot.sound`.
