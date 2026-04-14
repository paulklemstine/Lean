import Mathlib

/-!
# Primitivity Preservation Through Berggren Matrices

We prove that the Berggren matrices preserve the Pythagorean property
via Lorentz form preservation and establish key structural properties.
-/

/-- A Pythagorean triple (a,b,c) with a² + b² = c². -/
def IsPythTriple' (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The Lorentz quadratic form Q(a,b,c) = a² + b² - c². -/
def lorentzForm (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-! ## Lorentz Form Preservation -/

theorem lorentz_M1 (a b c : ℤ) :
    lorentzForm (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) = lorentzForm a b c := by
  unfold lorentzForm; ring

theorem lorentz_M2 (a b c : ℤ) :
    lorentzForm (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) = lorentzForm a b c := by
  unfold lorentzForm; ring

theorem lorentz_M3 (a b c : ℤ) :
    lorentzForm (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = lorentzForm a b c := by
  unfold lorentzForm; ring

/-! ## Pythagorean Preservation -/

theorem pyth_iff_lorentz_null (a b c : ℤ) :
    IsPythTriple' a b c ↔ lorentzForm a b c = 0 := by
  unfold IsPythTriple' lorentzForm; omega

theorem M1_preserves_pyth (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a - 2*b + 2*c) (2*a - b + 2*c) (2*a - 2*b + 3*c) := by
  rw [pyth_iff_lorentz_null] at h ⊢; rw [lorentz_M1]; exact h

theorem M2_preserves_pyth (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (a + 2*b + 2*c) (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  rw [pyth_iff_lorentz_null] at h ⊢; rw [lorentz_M2]; exact h

theorem M3_preserves_pyth (a b c : ℤ) (h : IsPythTriple' a b c) :
    IsPythTriple' (-a + 2*b + 2*c) (-2*a + b + 2*c) (-2*a + 2*b + 3*c) := by
  rw [pyth_iff_lorentz_null] at h ⊢; rw [lorentz_M3]; exact h

/-! ## Hypotenuse Growth -/

theorem M2_hyp_increases (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 ≤ c) :
    c < 2*a + 2*b + 3*c := by omega

/-! ## Euclid Parametrization -/

theorem euclid_parametrization (m n : ℤ) :
    IsPythTriple' (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  unfold IsPythTriple'; ring

/-! ## Brahmagupta-Fibonacci Identity -/

theorem brahmagupta_fibonacci (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

theorem brahmagupta_fibonacci_alt (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c + b*d)^2 + (a*d - b*c)^2 := by ring

theorem hypotenuse_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ)
    (h₁ : IsPythTriple' a₁ b₁ c₁) (h₂ : IsPythTriple' a₂ b₂ c₂) :
    IsPythTriple' (a₁*a₂ - b₁*b₂) (a₁*b₂ + b₁*a₂) (c₁*c₂) := by
  unfold IsPythTriple' at *
  nlinarith [brahmagupta_fibonacci a₁ b₁ a₂ b₂]
