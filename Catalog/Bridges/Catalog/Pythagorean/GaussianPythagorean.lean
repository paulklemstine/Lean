import Mathlib

/-!
# Pythagorean triples over the Gaussian integers

This file establishes the classical algebraic parametrization of Pythagorean triples
`(m² - n², 2mn, m² + n²)` over the Gaussian integers `GaussianInt = ℤ[i]`, together with
an explicit infinite family of triples whose entries have nonzero imaginary part.
-/

namespace GaussianPythagorean

open GaussianInt

/-- The algebraic parametrization identity: for any commutative ring elements `m, n`,
`(m² - n²)² + (2mn)² = (m² + n²)²`. -/
theorem parametrization_identity (m n : GaussianInt) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring

/-- A concrete example: with `m = ⟨1, 1⟩` and `n = ⟨1, 0⟩`. -/
example :
    (⟨1, 1⟩ ^ 2 - ⟨1, 0⟩ ^ 2 : GaussianInt) ^ 2 + (2 * ⟨1, 1⟩ * ⟨1, 0⟩) ^ 2
      = (⟨1, 1⟩ ^ 2 + ⟨1, 0⟩ ^ 2 : GaussianInt) ^ 2 :=
  parametrization_identity _ _

/-- The parameter `m = ⟨1, k⟩`. -/
def mParam (k : ℤ) : GaussianInt := ⟨1, k⟩

/-- The parameter `n = ⟨1, 0⟩`. -/
def nParam : GaussianInt := ⟨1, 0⟩

/-- First entry of the family: `m² - n²`. -/
def famA (k : ℤ) : GaussianInt := mParam k ^ 2 - nParam ^ 2

/-- Second entry of the family: `2mn`. -/
def famB (k : ℤ) : GaussianInt := 2 * mParam k * nParam

/-- Third entry of the family: `m² + n²`. -/
def famC (k : ℤ) : GaussianInt := mParam k ^ 2 + nParam ^ 2

/-- The family satisfies the Pythagorean identity. -/
theorem fam_identity (k : ℤ) : famA k ^ 2 + famB k ^ 2 = famC k ^ 2 := by
  unfold famA famB famC
  exact parametrization_identity _ _

/-- The imaginary part of `famA k` is `2 * k`. -/
theorem famA_im (k : ℤ) : (famA k).im = 2 * k := by
  simp [famA, mParam, nParam, pow_two]
  ring

/-- The imaginary part of `famB k` is `2 * k`. -/
theorem famB_im (k : ℤ) : (famB k).im = 2 * k := by
  simp [famB, mParam, nParam]

/-- The imaginary part of `famC k` is `2 * k`. -/
theorem famC_im (k : ℤ) : (famC k).im = 2 * k := by
  simp [famC, mParam, nParam, pow_two]
  ring

/-- The real part of `famA k` is `-k²`. -/
theorem famA_re (k : ℤ) : (famA k).re = -k ^ 2 := by
  simp [famA, mParam, nParam, pow_two]

theorem famA_im_ne_zero : ∀ k : ℤ, k ≠ 0 → (famA k).im ≠ 0 := by
  intro k hk
  rw [famA_im]
  omega

theorem famB_im_ne_zero : ∀ k : ℤ, k ≠ 0 → (famB k).im ≠ 0 := by
  intro k hk
  rw [famB_im]
  omega

theorem famC_im_ne_zero : ∀ k : ℤ, k ≠ 0 → (famC k).im ≠ 0 := by
  intro k hk
  rw [famC_im]
  omega

theorem fam_distinct : ∀ k₁ k₂ : ℤ, k₁ ≠ k₂ →
    famA k₁ ≠ famA k₂ ∨ famB k₁ ≠ famB k₂ ∨ famC k₁ ≠ famC k₂ := by
  intro k₁ k₂ hk
  right; left
  intro h
  apply hk
  have := congrArg Zsqrtd.im h
  rw [famB_im, famB_im] at this
  omega

theorem infinite_family : ∀ N : ℤ, ∃ k : ℤ,
    k > N ∧ k ≠ 0 ∧ famA k ^ 2 + famB k ^ 2 = famC k ^ 2 ∧ (famA k).im ≠ 0 := by
  intro N
  refine ⟨max N 0 + 1, by omega, by omega, fam_identity _, ?_⟩
  exact famA_im_ne_zero _ (by omega)

end GaussianPythagorean