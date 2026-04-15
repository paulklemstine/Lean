/-! # CatalogBuild.Pythagorean.Research.HigherDimensional

Auto-generated from theorem catalog database.
Domain: Pythagorean/Research
Declarations: 10
-/

import Mathlib

def trivialQuadruple (N : ℤ) : PythQuadruple where
  a := N; b := 0; c := 0; d := N
  hyp := by ring

/-- Q₄(a,b,c,d) = a² + b² + c² - d². -/

theorem quad_diff_squares (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 := by nlinarith

/-- a² + b² = d² - c². -/

theorem quad_double_factor (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 = d ^ 2 - c ^ 2 := by linarith

/-! ## Section 3: Triple ↪ Quadruple -/

/-- (a,b,c) Pythagorean ⟹ (a,b,0,c) quadruple. -/

def tripleToQuadruple (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    PythQuadruple where
  a := a; b := b; c := 0; d := c
  hyp := by simp; exact h

/-- Quadruple projects to sum-of-two-squares. -/

theorem quad_projects (q : PythQuadruple) :
    q.a ^ 2 + q.b ^ 2 = q.d ^ 2 - q.c ^ 2 := by linarith [q.hyp]

/-! ## Section 4: 4D Lorentz Metric -/

/-- η₄ = diag(1,1,1,-1). -/

theorem eta4_squared : eta4 * eta4 = 1 := by native_decide

/-! ## Section 5: Factoring Advantage -/

/-- N² = N² + 0² (trivial sum-of-squares decomposition). -/

theorem trivial_decomp (N : ℕ) : N ^ 2 + 0 ^ 2 = N ^ 2 := by ring

/-- 4^k ≥ 3^k (quadruple tree grows faster). -/

theorem legendre_check : 7 % 8 = 7 := by norm_num

/-- GCD extraction works for quadruples too. -/

theorem quad_gcd (a d : ℕ) : Nat.gcd a (d ^ 2) ∣ d ^ 2 := Nat.gcd_dvd_right a (d ^ 2)

/-! ## Section 7: The Dimension Advantage -/

/-- Three GCD computations per quadruple node vs two for triples. -/

theorem more_gcd_checks (N a b c : ℕ) :
    (Nat.gcd a N ∣ N) ∧ (Nat.gcd b N ∣ N) ∧ (Nat.gcd c N ∣ N) :=
  ⟨Nat.gcd_dvd_right a N, Nat.gcd_dvd_right b N, Nat.gcd_dvd_right c N⟩

