# Computational Evidence — Transreal Arithmetic

Carrier: `TReal = ℝ ∪ {+∞, −∞, Φ}`, with `Φ` ("nullity") the value of `0/0`.
All operations are **total**: every sum, product and quotient returns a value.

## 1. Operation tables on the singular values

Addition (`Φ` absorbs; `+∞ + −∞ = Φ`):

| +      | Φ | +∞ | −∞ | r (finite) |
|--------|---|----|----|------------|
| Φ      | Φ | Φ  | Φ  | Φ          |
| +∞     | Φ | +∞ | Φ  | +∞         |
| −∞     | Φ | Φ  | −∞ | −∞         |
| s      | Φ | +∞ | −∞ | r+s        |

Multiplication (`Φ` absorbs; `0 · (±∞) = Φ`):

| ·      | Φ | +∞ | −∞ | r>0 | r=0 | r<0 |
|--------|---|----|----|-----|-----|-----|
| Φ      | Φ | Φ  | Φ  | Φ   | Φ   | Φ   |
| +∞     | Φ | +∞ | −∞ | +∞  | Φ   | −∞  |
| −∞     | Φ | −∞ | +∞ | −∞  | Φ   | +∞  |
| s>0    | Φ | +∞ | −∞ | rs  | 0   | rs  |
| s=0    | Φ | Φ  | Φ  | 0   | 0   | 0   |
| s<0    | Φ | −∞ | +∞ | rs  | 0   | rs  |

Reciprocal: `1/0 = +∞`, `1/(±∞) = 0`, `1/Φ = Φ`, `1/r = r⁻¹` for `r ≠ 0`.

## 2. Anderson's defining identity

`0 / 0 = 0 · (1/0) = 0 · (+∞) = Φ`.  Verified as `TReal.zero_div_zero`.

## 3. Counterexample hunt

**Distributivity fails.** Take `x = 2, y = −1, z = +∞`:

- `(2 + (−1)) · ∞ = 1 · ∞ = +∞`
- `2·∞ + (−1)·∞ = (+∞) + (−∞) = Φ`

so `(x+y)z = +∞ ≠ Φ = xz + yz`.  Verified as `TReal.distrib_fails`.

**Wheel distributive law fails.** The wheel axiom `(x+y)z + 0·z = xz + yz`
should tolerate infinities via the correction term `0·z`.  Take
`x = 2, y = 3, z = +∞`:

- LHS `= (5)·∞ + 0·∞ = (+∞) + Φ = Φ`   (poisoned by `0·∞ = Φ`)
- RHS `= (+∞) + (+∞) = +∞`

so LHS `= Φ ≠ +∞ =` RHS.  Verified as `TReal.wheel_distrib_fails`.

**Reciprocal is not an involution.** `1/(1/(−∞)) = 1/0 = +∞ ≠ −∞`.
Verified as `TReal.recip_involution_fails`.

**Additive inverses absent.** For every `y`, `(+∞) + y ∈ {+∞, Φ}`, never `0`.
Verified as `TReal.no_add_inverse_pinf`.

## 4. What survives

- `(TReal, +, 0)` and `(TReal, ·, 1)` are commutative monoids
  (`add_comm/add_assoc/zero_add`, `mul_comm/mul_assoc/one_mul`).
- The finite reals embed as a sub-structure preserving `+` and `·`.

## 5. Summary

The stated slogan "the ring axioms fail but a wheel structure emerges" is only
**half** correct: the ring axioms indeed fail, but the signed transreals also
fail two independent wheel axioms (modified distributivity and the reciprocal
involution).  The single-infinity projective line is a wheel; the two-sided
`±∞` transreal line is strictly weaker.
