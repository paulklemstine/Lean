import Mathlib

/-!
# The composition-identity ladder and its odd-dimensional obstruction

This file addresses **Conjecture 4** of the "Composition-Algebra Playground"
research direction: the ladder of bilinear "sum-of-squares" composition
identities has rungs at dimension `1, 2, 4, 8` and nowhere else.  We formalise
two complementary halves of the picture that are fully within reach:

* the *positive* rungs `d = 2` and `d = 4` — the Brahmagupta–Fibonacci
  two-square identity and Euler's four-square identity — as genuine polynomial
  identities (`two_square_identity`, `four_square_identity`);
* the *obstruction* that kills every odd dimension `> 1` (in particular
  `d = 3, 5, 7`): a real `n × n` matrix with `n` odd can never square to `-1`
  (`no_odd_dim_sqrt_neg_one`, `no_three_dim_sqrt_neg_one`).

## Why the obstruction is the reason odd dimensions fail

A norm-multiplicative bilinear product on `ℝ^d` makes `ℝ^d` a real composition
algebra.  Left-multiplication `L_u` by an imaginary unit `u` (`u² = -1`) is then a
real-linear map with `L_u² = -1`, i.e. a linear complex structure `J` on `ℝ^d`.
For odd `d` no such `J` exists, because taking determinants of `J² = -1` gives
`(det J)² = det(-1) = (-1)^d = -1 < 0`, an impossibility over `ℝ`.  Hence there is
no composition algebra — and so no bilinear sum-of-squares identity — in any odd
dimension `> 1`.  The single even dimension `6` that Conjecture 4 also excludes
needs the deeper Hurwitz–Radon count and is left as the outstanding step; see
`FUTURE_DIRECTIONS.md`.

The determinant obstruction proved here is the exact analogue, one dimension up,
of the scalar fact `Complex.I - 1 ≠ 0` used for Conjecture 3: it is the concrete
algebraic reason that "rotation through an extra dimension" is unavailable when
the dimension is odd.
-/

namespace SquareIdentityLadder

open Matrix

/-- **The two-square (Brahmagupta–Fibonacci) identity.**  A product of two sums
of two squares is a sum of two squares — the `d = 2` rung of the ladder, i.e. the
norm-multiplicativity of the complex numbers. -/
theorem two_square_identity (a₁ a₂ b₁ b₂ : ℝ) :
    (a₁ ^ 2 + a₂ ^ 2) * (b₁ ^ 2 + b₂ ^ 2)
      = (a₁ * b₁ - a₂ * b₂) ^ 2 + (a₁ * b₂ + a₂ * b₁) ^ 2 := by
  ring

/-- **Euler's four-square identity.**  A product of two sums of four squares is a
sum of four squares — the `d = 4` rung of the ladder, i.e. the
norm-multiplicativity of the quaternions. -/
theorem four_square_identity (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℝ) :
    (a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2) * (b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2)
      = (a₁ * b₁ - a₂ * b₂ - a₃ * b₃ - a₄ * b₄) ^ 2
      + (a₁ * b₂ + a₂ * b₁ + a₃ * b₄ - a₄ * b₃) ^ 2
      + (a₁ * b₃ - a₂ * b₄ + a₃ * b₁ + a₄ * b₂) ^ 2
      + (a₁ * b₄ + a₂ * b₃ - a₃ * b₂ + a₄ * b₁) ^ 2 := by
  ring

/-- **The odd-dimensional obstruction.**  No real `n × n` matrix with `n` odd is
a square root of `-1`: `J * J = -1` is impossible.  Taking determinants gives
`(det J)² = (-1)^n = -1`, which no real number satisfies.

This is exactly the linear complex structure that a composition algebra would
provide, so its non-existence rules out composition — and hence any bilinear
sum-of-squares identity — in every odd dimension `> 1`. -/
theorem no_odd_dim_sqrt_neg_one {n : ℕ} (hn : Odd n)
    (J : Matrix (Fin n) (Fin n) ℝ) : J * J ≠ -1 := by
  intro h
  have hd := congrArg Matrix.det h
  rw [Matrix.det_mul, Matrix.det_neg, Matrix.det_one, mul_one, Fintype.card_fin,
      hn.neg_one_pow] at hd
  nlinarith [sq_nonneg J.det, hd]

/-- **The three-dimensional case of Conjecture 4.**  There is no linear complex
structure on `ℝ³`; equivalently no real `3 × 3` matrix squares to `-1`.  This is
the algebraic obstruction to a three-square composition identity. -/
theorem no_three_dim_sqrt_neg_one (J : Matrix (Fin 3) (Fin 3) ℝ) : J * J ≠ -1 :=
  no_odd_dim_sqrt_neg_one (by decide) J

end SquareIdentityLadder