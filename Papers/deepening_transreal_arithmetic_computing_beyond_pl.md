# Computational Evidence — Transreal Arithmetic (Deepening)

All claims below are finite case checks on the transreal carrier
`TReal = ℝ ⊎ {+∞, -∞, Φ}` with Anderson's total operations. Because every
"interesting" behaviour happens at the three singular values `±∞, Φ` (the real
part is just ordinary ℝ), a handful of hand evaluations settle each universal
statement; these are exactly what the Lean proofs formalize by case analysis.

## 1. Reciprocal involution: where does `recip ∘ recip = id` fail?

`recip`: `1/0 = +∞`, `1/(±∞) = 0`, `1/Φ = Φ`, `1/a = a⁻¹` for a real `a ≠ 0`.

| x    | recip x | recip (recip x) | = x ? |
|------|---------|-----------------|-------|
| Φ    | Φ       | Φ               | yes   |
| +∞   | 0       | +∞              | yes   |
| −∞   | 0       | +∞              | **NO** (+∞ ≠ −∞) |
| 0    | +∞      | 0               | yes   |
| a>0  | a⁻¹     | a               | yes   |
| a<0  | a⁻¹     | a               | yes   |

**Conclusion:** the involution holds everywhere except at `−∞`. This is the
single point of failure, sharpening the earlier blanket "not an involution".
Formalized as `recip_recip_eq_iff : recip (recip x) = x ↔ x ≠ ninf`.

## 2. Reciprocal versus negation: `recip (-x) = -(recip x)`?

| x    | -x   | recip(-x) | recip x | -(recip x) | equal ? |
|------|------|-----------|---------|------------|---------|
| Φ    | Φ    | Φ         | Φ       | Φ          | yes     |
| +∞   | −∞   | 0         | 0       | 0          | yes     |
| −∞   | +∞   | 0         | 0       | 0          | yes     |
| a≠0  | −a   | (−a)⁻¹    | a⁻¹     | −(a⁻¹)     | yes (since (−a)⁻¹ = −a⁻¹) |
| 0    | 0    | +∞        | +∞      | **−∞**     | **NO** (+∞ ≠ −∞) |

**Conclusion:** the identity holds off `0` and fails exactly at `0`, because
`−0 = 0` collapses the sign that `recip` would otherwise carry through.
Formalized as `recip_neg_of_ne_zero` and `recip_neg_zero_fails`.

## 3. The order is a partial order but not linear

Order: `−∞ < (every real) < +∞`, reals ordered as in ℝ, and `Φ` incomparable to
everything except itself.

* Reflexive / antisymmetric / transitive: checked over the 4×4 (and 4×4×4)
  constructor combinations; every off-diagonal singular pair is `False` in one
  direction, so transitivity/antisymmetry are vacuous there.
* Not total: `Φ ≤ +∞` is `False` and `+∞ ≤ Φ` is `False`, so the pair `(Φ, +∞)`
  is incomparable (`not_total`).
* No greatest element: any `g` with `∀x, x ≤ g` would need both `Φ ≤ g` (forces
  `g = Φ`) and `+∞ ≤ g` (forces `g = +∞`), impossible (`no_greatest`). Dually
  for least (`no_least`). Contrast: the extended reals `[−∞,+∞]` *do* have a top
  and bottom; adding `Φ` destroys both.

## 4. Surviving algebra (spot checks)

* `(TReal, +, 0)` and `(TReal, ·, 1)` commutative monoids: e.g.
  `(+∞ + −∞) + 5 = Φ + 5 = Φ = +∞ + (−∞ + 5) = +∞ + (−∞) = Φ`. ✓
* Negation is additive: `−(+∞ + −∞) = −Φ = Φ` and `(−(+∞)) + (−(−∞)) =
  −∞ + +∞ = Φ`. ✓
* Negation through products: `−(2 · +∞) = −(+∞) = −∞ = (−2) · +∞`. ✓

No counterexamples to the *surviving* laws were found; the *collapsing* laws
(reciprocal involution at `−∞`, reciprocal/negation at `0`, totality of the
order, existence of extrema) each have the explicit witnesses tabulated above.
