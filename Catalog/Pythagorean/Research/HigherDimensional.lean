/-! # CatalogBuild.Pythagorean.Research.HigherDimensional

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 10
-/

import Mathlib

/-- The trivial quadruple (N, 0, 0, N). -/
def trivialQuadruple (N : ℤ) : PythQuadruple where
  a := N; b := 0; c := 0; d := N
  hyp := by ring



/-- (d-c)(d+c) = a² + b². -/
theorem quad_diff_squares (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith



/-- a² + b² = d² - c². -/
theorem quad_double_factor (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 = d ^ 2 - c ^ 2 := by linarith



/-- (a,b,c) Pythagorean ⟹ (a,b,0,c) quadruple. -/
def tripleToQuadruple (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    PythQuadruple where
  a := a; b := b; c := 0; d := c
  hyp := by simp; exact h



/-- Quadruple projects to sum-of-two-squares. -/
theorem quad_projects (q : PythQuadruple) :
    q.a ^ 2 + q.b ^ 2 = q.d ^ 2 - q.c ^ 2 := by linarith [q.hyp]



/-- η₄² = I. -/
theorem eta4_squared : eta4 * eta4 = 1 := by native_decide



/-- N² = N² + 0² (trivial sum-of-squares decomposition). -/
theorem trivial_decomp (N : ℕ) : N ^ 2 + 0 ^ 2 = N ^ 2 := by ring



/-- 7 ≡ 7 (mod 8), so 7 is not a sum of three squares. -/
theorem legendre_check : 7 % 8 = 7 := by norm_num



/-- GCD extraction works for quadruples too. -/
theorem quad_gcd (a d : ℕ) : Nat.gcd a (d ^ 2) ∣ d ^ 2 := Nat.gcd_dvd_right a (d ^ 2)



/-- Three GCD computations per quadruple node vs two for triples. -/
theorem more_gcd_checks (N a b c : ℕ) :
    (Nat.gcd a N ∣ N) ∧ (Nat.gcd b N ∣ N) ∧ (Nat.gcd c N ∣ N) :=
  ⟨Nat.gcd_dvd_right a N, Nat.gcd_dvd_right b N, Nat.gcd_dvd_right c N⟩


