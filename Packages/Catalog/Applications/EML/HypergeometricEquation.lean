import Mathlib

/-!
# Gauss's hypergeometric differential equation

This file formalizes the coefficient sequence of the Gauss hypergeometric series
`₂F₁(a,b;c;z)` and proves, purely formally, that it is annihilated coefficient by
coefficient by Gauss's differential operator

`z(1-z)y'' + (c-(a+b+1)z)y' - ab y`.

Working with coefficient sequences makes the result independent of analytic
convergence questions and captures the algebraic core of the differential equation.
-/

namespace EMLSpecialFunctions

/-- Coefficients of the formal Gauss hypergeometric series.  The recurrence is
`u₀ = 1` and
`uₙ₊₁ = ((a+n)(b+n))/((c+n)(n+1)) uₙ`.
When `c` is not a nonpositive integer, these are the usual coefficients
`(a)ₙ(b)ₙ / ((c)ₙ n!)`. -/
noncomputable def hypergeometricCoeff (a b c : ℂ) : ℕ → ℂ
  | 0 => 1
  | n + 1 => ((a + n) * (b + n) / ((c + n) * (n + 1))) *
      hypergeometricCoeff a b c n

/-- The coefficient of `zⁿ` in Gauss's differential operator applied to a
formal series with coefficient sequence `u`. -/
def gaussOperatorCoeff (a b c : ℂ) (u : ℕ → ℂ) (n : ℕ) : ℂ :=
  (n + 1) * (c + n) * u (n + 1) - (a + n) * (b + n) * u n

/-- The defining hypergeometric recurrence, in denominator-free form. -/
theorem hypergeometricCoeff_recurrence (a b c : ℂ) (n : ℕ)
    (hc : c + n ≠ 0) :
    (n + 1) * (c + n) * hypergeometricCoeff a b c (n + 1) =
      (a + n) * (b + n) * hypergeometricCoeff a b c n := by
  simp [hypergeometricCoeff]
  field_simp [hc]

/-- **Gauss hypergeometric equation.** The formal series `₂F₁(a,b;c;z)` is
annihilated coefficientwise by
`z(1-z)y'' + (c-(a+b+1)z)y' - ab y`.

The displayed coefficient is the simplified coefficient of `zⁿ` in that ODE:
`(n+1)(c+n)uₙ₊₁ - (a+n)(b+n)uₙ`. -/
theorem hypergeometric_satisfies_gauss_equation (a b c : ℂ)
    (hc : ∀ n : ℕ, c + n ≠ 0) :
    ∀ n : ℕ, gaussOperatorCoeff a b c (hypergeometricCoeff a b c) n = 0 := by
  intro n
  simp [gaussOperatorCoeff]
  have h := hypergeometricCoeff_recurrence a b c n (hc n)
  rw [h]
  ring

/-- The hypergeometric coefficient sequence is symmetric in its two numerator
parameters. -/
theorem hypergeometricCoeff_swap (a b c : ℂ) :
    hypergeometricCoeff a b c = hypergeometricCoeff b a c := by
  funext n
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [hypergeometricCoeff, hypergeometricCoeff, ih]
    ring

/-- A normalized coefficient sequence satisfying Gauss's recurrence is unique.
Thus the formal solution of Gauss's equation with constant coefficient `1` is
precisely the hypergeometric series. -/
theorem hypergeometricCoeff_unique (a b c : ℂ) (u : ℕ → ℂ)
    (u0 : u 0 = 1)
    (hu : ∀ n : ℕ, (n + 1) * (c + n) * u (n + 1) =
      (a + n) * (b + n) * u n)
    (hc : ∀ n : ℕ, c + n ≠ 0) :
    u = hypergeometricCoeff a b c := by
  funext n
  induction n with
  | zero => exact u0
  | succ n ih =>
    have h1 := hu n
    have h2 := hypergeometricCoeff_recurrence a b c n (hc n)
    rw [ih] at h1
    have hfactor : (n + 1) * (c + n) ≠ 0 := by
      apply mul_ne_zero
      · exact Nat.cast_add_one_ne_zero n
      · exact hc n
    exact mul_right_injective₀ hfactor (h1.trans h2.symm)

/-- If a numerator parameter is a nonpositive integer `-m`, then all
coefficients after degree `m` vanish.  This is the formal reason that the
hypergeometric series terminates to a polynomial in this case. -/
theorem hypergeometricCoeff_terminates (m k : ℕ) (b c : ℂ) :
    hypergeometricCoeff (-(m : ℂ)) b c (m + 1 + k) = 0 := by
  induction k with
  | zero =>
    simp [hypergeometricCoeff]
  | succ k ih =>
    simp [hypergeometricCoeff, ih]

end EMLSpecialFunctions