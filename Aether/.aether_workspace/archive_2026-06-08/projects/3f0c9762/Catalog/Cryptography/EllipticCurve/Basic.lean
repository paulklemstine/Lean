import Mathlib

/-!
# Elliptic Curve Arithmetic: Basic Definitions

This file defines the core structures for elliptic curve arithmetic over fields:
- `ShortWeierstrassModel K`: a nonsingular short Weierstrass model y² = x³ + ax + b
- `ECPoint E`: points on the curve (affine points + point at infinity)
- `ecNeg`: point negation (reflection across x-axis)
- `ecAdd`: point addition via the chord-tangent law

## Mathematical Context

A short Weierstrass equation y² = x³ + ax + b over a field K defines a nonsingular
elliptic curve when its discriminant Δ = -16(4a³ + 27b²) ≠ 0. The set of K-rational
points, together with a point at infinity, forms an abelian group under the chord-tangent
law.

**Characteristic restriction:** Short Weierstrass form requires char(K) ≠ 2, 3.
We encode this via `(2 : K) ≠ 0` and `(3 : K) ≠ 0` in the model.
-/

noncomputable section

open Classical

/-- A nonsingular short Weierstrass model y² = x³ + ax + b over a field K.
    Requires char(K) ≠ 2, 3 and discriminant nonvanishing. -/
structure ShortWeierstrassModel (K : Type*) [Field K] where
  a : K
  b : K
  char_ne_two : (2 : K) ≠ 0
  char_ne_three : (3 : K) ≠ 0
  nonsingular : 4 * a ^ 3 + 27 * b ^ 2 ≠ 0

variable {K : Type*} [Field K]

/-- A point on an elliptic curve in short Weierstrass form. -/
inductive ECPoint (E : ShortWeierstrassModel K)
  | infinity : ECPoint E
  | affine (x y : K) (h : y ^ 2 = x ^ 3 + E.a * x + E.b) : ECPoint E

namespace ECPoint

/-- Extensional equality for affine points. -/
theorem affine_eq {E : ShortWeierstrassModel K} {x₁ y₁ x₂ y₂ : K}
    {h₁ : y₁ ^ 2 = x₁ ^ 3 + E.a * x₁ + E.b}
    {h₂ : y₂ ^ 2 = x₂ ^ 3 + E.a * x₂ + E.b} :
    x₁ = x₂ → y₁ = y₂ → affine x₁ y₁ h₁ = affine x₂ y₂ h₂ := by
  rintro rfl rfl; rfl

/-- Negation preserves the curve equation. -/
theorem neg_on_curve {E : ShortWeierstrassModel K} {x y : K}
    (h : y ^ 2 = x ^ 3 + E.a * x + E.b) :
    (-y) ^ 2 = x ^ 3 + E.a * x + E.b := by
  rw [neg_sq]; exact h

/-- Negation of a point: reflects across the x-axis. -/
def ecNeg (E : ShortWeierstrassModel K) : ECPoint E → ECPoint E
  | infinity => infinity
  | affine x y h => affine x (-y) (neg_on_curve h)

/-
The chord formula result lies on the curve.
-/
theorem chord_on_curve {E : ShortWeierstrassModel K} {x₁ y₁ x₂ y₂ : K}
    (h₁ : y₁ ^ 2 = x₁ ^ 3 + E.a * x₁ + E.b)
    (h₂ : y₂ ^ 2 = x₂ ^ 3 + E.a * x₂ + E.b)
    (hx : x₁ ≠ x₂) :
    let m := (y₂ - y₁) / (x₂ - x₁)
    let x₃ := m ^ 2 - x₁ - x₂
    let y₃ := m * (x₁ - x₃) - y₁
    y₃ ^ 2 = x₃ ^ 3 + E.a * x₃ + E.b := by
  by_cases h3 : x₂ - x₁ = 0;
  · exact False.elim ( hx ( sub_eq_zero.mp h3 ▸ rfl ) );
  · grind +qlia

/-
The doubling formula result lies on the curve (char ≠ 2).
-/
theorem doubling_on_curve {E : ShortWeierstrassModel K} {x₁ y₁ : K}
    (h₁ : y₁ ^ 2 = x₁ ^ 3 + E.a * x₁ + E.b)
    (hy : y₁ ≠ 0) :
    let m := (3 * x₁ ^ 2 + E.a) / (2 * y₁)
    let x₃ := m ^ 2 - 2 * x₁
    let y₃ := m * (x₁ - x₃) - y₁
    y₃ ^ 2 = x₃ ^ 3 + E.a * x₃ + E.b := by
  have h2y : (2 : K) * y₁ ≠ 0 := mul_ne_zero E.char_ne_two hy
  grind

/-- Point addition via the chord-tangent law. -/
def ecAdd (E : ShortWeierstrassModel K) : ECPoint E → ECPoint E → ECPoint E
  | infinity, Q => Q
  | P, infinity => P
  | affine x₁ y₁ h₁, affine x₂ y₂ h₂ =>
    if hx : x₁ = x₂ then
      if _hy : y₁ = y₂ then
        if hy0 : y₁ = 0 then
          infinity
        else
          let m := (3 * x₁ ^ 2 + E.a) / (2 * y₁)
          let x₃ := m ^ 2 - 2 * x₁
          let y₃ := m * (x₁ - x₃) - y₁
          affine x₃ y₃ (doubling_on_curve h₁ hy0)
      else
        infinity
    else
      let m := (y₂ - y₁) / (x₂ - x₁)
      let x₃ := m ^ 2 - x₁ - x₂
      let y₃ := m * (x₁ - x₃) - y₁
      affine x₃ y₃ (chord_on_curve h₁ h₂ hx)

/-- Generic position: all intermediate x-coordinates in addition are distinct. -/
def genericPosition (E : ShortWeierstrassModel K) :
    ECPoint E → ECPoint E → ECPoint E → Prop
  | infinity, _, _ => True
  | _, infinity, _ => True
  | _, _, infinity => True
  | affine x₁ _y₁ _h₁, affine x₂ _y₂ _h₂, affine x₃ _y₃ _h₃ =>
    x₁ ≠ x₂ ∧ x₁ ≠ x₃ ∧ x₂ ≠ x₃ ∧
    (∀ xpq ypq (hpq : ypq ^ 2 = xpq ^ 3 + E.a * xpq + E.b),
      ecAdd E (affine x₁ _y₁ _h₁) (affine x₂ _y₂ _h₂) = affine xpq ypq hpq →
      xpq ≠ x₃)

/-- Scalar multiplication by repeated addition. -/
def smulPoint (E : ShortWeierstrassModel K) : ℕ → ECPoint E → ECPoint E
  | 0, _ => infinity
  | n + 1, P => ecAdd E P (smulPoint E n P)

end ECPoint

end