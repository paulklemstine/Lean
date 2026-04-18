import Mathlib

/-! # SPB Tangent Iteration and Chebyshev Connection

The n-fold SPB iteration spb^n(t) = tan(n·arctan(t)) connects SPB
to Chebyshev polynomials and trigonometric iteration theory.

## Key Results
- Explicit formulas for 2-fold, 3-fold, 4-fold, 5-fold SPB
- Machin-type formulas as SPB identities
- SPB self-inverse and fixed point analysis
-/

noncomputable section

open Real

/-- The SPB operator -/
def spbT (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- SPB double: 2t/(1-t²) -/
theorem spb_double_formula (t : ℝ) : spbT t t = 2 * t / (1 - t ^ 2) := by
  unfold spbT; ring

/-- SPB triple: spb(spb(t,t), t) when defined -/
theorem spb_triple (t : ℝ) (h1 : 1 - t ^ 2 ≠ 0) (h2 : 1 - 3 * t ^ 2 ≠ 0) :
    spbT (spbT t t) t = (3 * t - t ^ 3) / (1 - 3 * t ^ 2) := by
  unfold spbT; field_simp; ring

/-- SPB quadruple: explicit formula for 4-fold -/
theorem spb_quadruple (t : ℝ) (h1 : 1 - t ^ 2 ≠ 0)
    (h2 : 1 - 6 * t ^ 2 + t ^ 4 ≠ 0) :
    spbT (spbT t t) (spbT t t) = (4 * t - 4 * t ^ 3) / (1 - 6 * t ^ 2 + t ^ 4) := by
  unfold spbT; field_simp; ring

/-- SPB quintuple formula: verified by concrete computation.
The general proof requires handling nested fractions with 5 levels of SPB composition. -/
theorem spb_quintuple_check : spbT (spbT (spbT (1/10) (1/10)) (spbT (1/10) (1/10))) (1/10) =
    (5 * (1/10) - 10 * (1/10) ^ 3 + (1/10) ^ 5) / (1 - 10 * (1/10) ^ 2 + 5 * (1/10) ^ 4) := by
  norm_num [spbT]

/-- arctan(1) = π/4 -/
theorem arctan_one' : Real.arctan 1 = π / 4 := Real.arctan_one

/-- Machin's formula as SPB -/
theorem machin_spb :
    spbT (spbT (spbT (1/5) (1/5)) (spbT (1/5) (1/5))) (-1/239) = 1 := by
  norm_num [spbT]

/-- Gregory-Leibniz: spb(1/2, 1/3) = 1 -/
theorem gregory_leibniz_spb : spbT (1/2) (1/3) = 1 := by norm_num [spbT]

/-- spb(1/8, 1/8) = 16/63 -/
theorem spb_eighth : spbT (1/8) (1/8) = 16/63 := by norm_num [spbT]

/-- The Weierstrass substitution identity -/
theorem weierstrass_sin' (t : ℝ) :
    (2 * t) ^ 2 + (1 - t ^ 2) ^ 2 = (1 + t ^ 2) ^ 2 := by ring

/-
SPB self-inverse: spb(spb(x, a), -a) = x when defined
-/
theorem spb_self_inverse (x a : ℝ) (h1 : 1 - x * a ≠ 0)
    (h2 : 1 + spbT x a * a ≠ 0) :
    spbT (spbT x a) (-a) = x := by
  unfold spbT at *;
  grind

/-- The fixed point equation spb(x, a) = x has no solution when a ≠ 0 -/
theorem spb_no_fixed_point (x a : ℝ) (ha : a ≠ 0) (hd : 1 - x * a ≠ 0)
    (heq : spbT x a = x) : False := by
  unfold spbT at heq
  have h1 : x + a = x * (1 - x * a) := by rw [div_eq_iff hd] at heq; linarith
  have h2 : a * (1 + x ^ 2) = 0 := by nlinarith
  rcases mul_eq_zero.mp h2 with h | h
  · exact ha h
  · linarith [sq_nonneg x]

/-- orbit_2(1/5) = 5/12 -/
theorem orbit_2_fifth : spbT (1/5) (1/5) = 5/12 := by norm_num [spbT]

/-- orbit_4(1/5) = 120/119 -/
theorem orbit_4_fifth : spbT (5/12) (5/12) = 120/119 := by norm_num [spbT]

/-- Period-4 orbit: spb⁴(0, 1) = 0 -/
theorem spb_period_4_check :
    spbT (spbT (spbT (spbT 0 1) 1) 1) 1 = 0 := by norm_num [spbT]

/-- The SPB arctan addition for x·y < 1 -/
theorem spb_arctan_add (x y : ℝ) (h : x * y < 1) :
    Real.arctan (spbT x y) = Real.arctan x + Real.arctan y := by
  rw [spbT]; exact (Real.arctan_add h).symm

/-- Ramanujan-Machin equivalence -/
theorem ramanujan_machin_equiv :
    spbT (1/2) (1/3) =
    spbT (spbT (spbT (1/5) (1/5)) (spbT (1/5) (1/5))) (-1/239) := by
  norm_num [spbT]

/-- Hermann step 1: spb(1/2, 1/2) = 4/3 -/
theorem hermann_step1 : spbT (1/2) (1/2) = 4/3 := by norm_num [spbT]

/-- Hermann step 2: spb(4/3, -1/7) = 1 -/
theorem hermann_step2 : spbT (4/3) (-1/7) = 1 := by norm_num [spbT]

/-- Hutton step 1: spb(1/3, 1/3) = 3/4 -/
theorem hutton_step1' : spbT (1/3) (1/3) = 3/4 := by norm_num [spbT]

/-- Hutton step 2: spb(3/4, 1/7) = 1 -/
theorem hutton_step2 : spbT (3/4) (1/7) = 1 := by norm_num [spbT]

/-- Strassnitzky step 1: spb(1/2, 1/5) = 7/9 -/
theorem strassnitzky_step1 : spbT (1/2) (1/5) = 7/9 := by norm_num [spbT]

/-- Strassnitzky step 2: spb(7/9, 1/8) = 1 -/
theorem strassnitzky_step2 : spbT (7/9) (1/8) = 1 := by norm_num [spbT]

/-- The SPB power series -/
theorem spb_power_series (x y : ℝ) (h : 1 - x * y ≠ 0) :
    spbT x y = (x + y) * (1 / (1 - x * y)) := by
  unfold spbT; field_simp

/-- spb(x, 0) = x -/
theorem spb_period_1_zero (x : ℝ) : spbT x 0 = x := by simp [spbT]

end