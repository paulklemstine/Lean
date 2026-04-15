/-! # CatalogBuild.Pythagorean.Core.HigherDimDescent

Auto-generated from theorem catalog database.
Domain: Pythagorean/Core
Declarations: 30
-/

import Mathlib

/-- For a Pythagorean quadruple, (a+b+c-d) is even -/
theorem quad_parity_sum (a b c d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    2 ∣ (a + b + c - d) := by
  obtain ⟨ra, hra⟩ := sq_sub_self_even a
  obtain ⟨rb, hrb⟩ := sq_sub_self_even b
  obtain ⟨rc, hrc⟩ := sq_sub_self_even c
  obtain ⟨rd, hrd⟩ := sq_sub_self_even d
  exact ⟨rd - ra - rb - rc, by linarith⟩

/-- For a Pythagorean quintuple, (a+b+c+e-d) is even -/

theorem quint_parity_sum (a b c e d : ℤ) (h : a ^ 2 + b ^ 2 + c ^ 2 + e ^ 2 = d ^ 2) :
    2 ∣ (a + b + c + e - d) := by
  obtain ⟨ra, hra⟩ := sq_sub_self_even a
  obtain ⟨rb, hrb⟩ := sq_sub_self_even b
  obtain ⟨rc, hrc⟩ := sq_sub_self_even c
  obtain ⟨re, hre⟩ := sq_sub_self_even e
  obtain ⟨rd, hrd⟩ := sq_sub_self_even d
  exact ⟨rd - ra - rb - rc - re, by linarith⟩

/-- For a Pythagorean sextuple, (a₁+a₂+a₃+a₄+a₅-a₆) is even -/

theorem sext_parity_sum (a₁ a₂ a₃ a₄ a₅ a₆ : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = a₆^2) :
    2 ∣ (a₁ + a₂ + a₃ + a₄ + a₅ - a₆) := by
  obtain ⟨r₁, hr₁⟩ := sq_sub_self_even a₁
  obtain ⟨r₂, hr₂⟩ := sq_sub_self_even a₂
  obtain ⟨r₃, hr₃⟩ := sq_sub_self_even a₃
  obtain ⟨r₄, hr₄⟩ := sq_sub_self_even a₄
  obtain ⟨r₅, hr₅⟩ := sq_sub_self_even a₅
  obtain ⟨r₆, hr₆⟩ := sq_sub_self_even a₆
  exact ⟨r₆ - r₁ - r₂ - r₃ - r₄ - r₅, by linarith⟩

/-! ## Section 2: The k = 5 Counterexample -/

/-- Q₅(v) = v₀² + v₁² + v₂² + v₃² - v₄² -/

def Q5 (v : Fin 5 → ℤ) : ℤ :=
  v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 - v 4 ^ 2

/-- The quintuple (1,1,1,1,2) satisfies 1² + 1² + 1² + 1² = 2² -/

theorem quintuple_1_1_1_1_2 : (1 : ℤ) ^ 2 + 1 ^ 2 + 1 ^ 2 + 1 ^ 2 = 2 ^ 2 := by norm_num

/-- (1,1,1,1,2) is a null vector for Q₅ -/

theorem quintuple_null : Q5 ![1, 1, 1, 1, 2] = 0 := by
  unfold Q5; native_decide

/-- The Minkowski inner product η(s,v) for s = (1,1,1,1,1) in signature (4,1) -/

def minkowski_inner_5 (v : Fin 5 → ℤ) : ℤ :=
  v 0 + v 1 + v 2 + v 3 - v 4

/-- η(s,s) = 3 for s = (1,1,1,1,1) in signature (4,1) -/

theorem eta_ss_5 : minkowski_inner_5 ![1, 1, 1, 1, 1] = 3 := by
  unfold minkowski_inner_5; native_decide

/-- For v = (1,1,1,1,2), η(s,v) = 2 -/

theorem eta_sv_counterexample : minkowski_inner_5 ![1, 1, 1, 1, 2] = 2 := by
  unfold minkowski_inner_5; native_decide

/-- The integrality condition 3 | 2·η(s,v) fails for (1,1,1,1,2) -/

theorem integrality_fails_k5 : ¬ (3 ∣ (2 * minkowski_inner_5 ![1, 1, 1, 1, 2])) := by
  unfold minkowski_inner_5; native_decide

/-- There is no integer q with 3q = 4, confirming R(v) ∉ ℤ⁵ -/

theorem reflection_coeff_not_integer :
    ¬ (∃ q : ℤ, 3 * q = 2 * minkowski_inner_5 ![1, 1, 1, 1, 2]) := by
  unfold minkowski_inner_5; simp +decide; omega

/-- Main k=5 theorem: ∃ null vector where the reflection is NOT integer-valued -/

theorem allones_not_integral_k5 :
    ∃ v : Fin 5 → ℤ,
      v 0 ^ 2 + v 1 ^ 2 + v 2 ^ 2 + v 3 ^ 2 = v 4 ^ 2 ∧
      ¬ ((3 : ℤ) ∣ (2 * (v 0 + v 1 + v 2 + v 3 - v 4))) := by
  refine ⟨![1, 1, 1, 1, 2], ?_, ?_⟩ <;> native_decide

/-! ## Section 3: Why k = 3 and k = 4 Always Work -/

/-- For k = 3: η(s,s) = 1, so 1 | anything. -/

theorem allones_integral_k3 (v : Fin 3 → ℤ) :
    (1 : ℤ) ∣ (2 * (v 0 + v 1 - v 2)) := one_dvd _

/-- For k = 4: η(s,s) = 2, and 2 | 2n always. -/

theorem allones_integral_k4 (v : Fin 4 → ℤ) :
    (2 : ℤ) ∣ (2 * (v 0 + v 1 + v 2 - v 3)) := dvd_mul_right 2 _

/-! ## Section 4: k = 6 Works on the Null Cone!

For k = 6, η(s,s) = 4. We need 4 | 2·η(s,v) for all null vectors v.
Since η(s,v) is always even for null vectors (by parity), 2·η(s,v) ≡ 0 (mod 4). -/

/-- For k = 6 null vectors, 4 | 2·η(s,v) because η is always even -/

theorem allones_integral_k6_null (a₁ a₂ a₃ a₄ a₅ a₆ : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = a₆^2) :
    (4 : ℤ) ∣ (2 * (a₁ + a₂ + a₃ + a₄ + a₅ - a₆)) := by
  have hpar := sext_parity_sum a₁ a₂ a₃ a₄ a₅ a₆ h
  obtain ⟨k, hk⟩ := hpar
  exact ⟨k, by linarith⟩

/-- The root for k=6: (0,0,0,0,1,1) is a valid null vector -/

theorem root_k6 : (0:ℤ)^2 + 0^2 + 0^2 + 0^2 + 1^2 = 1^2 := by norm_num

/-! ## Section 5: k = 5 and k ≥ 7 Fail -/

/-- The k=5 analysis: η is even but 3 ∤ η for (1,1,1,1,2) -/

theorem k5_fails :
    ∃ a b c e d : ℤ,
      a^2 + b^2 + c^2 + e^2 = d^2 ∧
      ¬ (3 ∣ (2 * (a + b + c + e - d))) := by
  exact ⟨1, 1, 1, 1, 2, by norm_num, by omega⟩

/-- k = 7 counterexample: (1,1,1,1,1,1,√6) — wait, we need (1,1,1,1,0,0,2).
    1²+1²+1²+1²+0²+0² = 4 = 2². η = 1+1+1+1+0+0-2 = 2. Need 5|4. 5∤4. ✗ -/

theorem k7_fails :
    ∃ a₁ a₂ a₃ a₄ a₅ a₆ d : ℤ,
      a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 + a₆^2 = d^2 ∧
      ¬ (5 ∣ (2 * (a₁ + a₂ + a₃ + a₄ + a₅ + a₆ - d))) := by
  exact ⟨1, 1, 1, 1, 0, 0, 2, by norm_num, by omega⟩

/-! ## Section 6: General Integrality Criterion -/

/-- 3 does not divide 4 — obstruction for k = 5 -/

theorem three_not_dvd_four : ¬ ((3 : ℤ) ∣ 4) := by omega

/-- Universal integrality on ALL of ℤ^k: (k-2) | 2 iff k ∈ {3,4} -/

theorem universal_integrality_iff_dvd_2 (k : ℕ) (hk : 3 ≤ k) (hk' : k ≤ 100) :
    (k - 2 : ℤ) ∣ 2 ↔ k = 3 ∨ k = 4 := by
  constructor
  · intro h; interval_cases k <;> omega
  · intro h; rcases h with rfl | rfl <;> norm_num

/-- Null-cone integrality: (k-2) | 4 iff k ∈ {3,4,6} -/

theorem nullcone_integrality_iff_dvd_4 (k : ℕ) (hk : 3 ≤ k) (hk' : k ≤ 100) :
    (k - 2 : ℤ) ∣ 4 ↔ k = 3 ∨ k = 4 ∨ k = 6 := by
  constructor
  · intro h; interval_cases k <;> omega
  · intro h; rcases h with rfl | rfl | rfl <;> norm_num

/-! ## Section 7: The Descent Identity for k = 4 -/

/-- (d-b-c)² + (d-a-c)² + (d-a-b)² = (2d-a-b-c)² when a²+b²+c² = d² -/

theorem descent_identity_k4 (a b c d : ℤ) (h : a^2 + b^2 + c^2 = d^2) :
    (d-b-c)^2 + (d-a-c)^2 + (d-a-b)^2 = (2*d-a-b-c)^2 := by nlinarith

/-! ## Section 8: Descent Bounds for k = 6 -/

/-- Sum exceeds hypotenuse for k=6 -/

theorem sum_gt_hyp_k6 (a₁ a₂ a₃ a₄ a₅ d : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = d^2)
    (h1 : 0 ≤ a₁) (h2 : 0 ≤ a₂) (h3 : 0 ≤ a₃) (h4 : 0 < a₄) (h5 : 0 < a₅) (hd : 0 < d) :
    a₁ + a₂ + a₃ + a₄ + a₅ > d := by
  nlinarith [mul_pos h4 h5]

/-- Sum bounded by √5·d < 3d for k=6 -/

theorem sum_lt_3d_k6 (a₁ a₂ a₃ a₄ a₅ d : ℤ)
    (h : a₁^2 + a₂^2 + a₃^2 + a₄^2 + a₅^2 = d^2)
    (h1 : 0 ≤ a₁) (h2 : 0 ≤ a₂) (h3 : 0 ≤ a₃) (h4 : 0 ≤ a₄) (h5 : 0 ≤ a₅) (hd : 0 < d) :
    a₁ + a₂ + a₃ + a₄ + a₅ < 3 * d := by
  nlinarith [sq_nonneg (a₁ - a₂), sq_nonneg (a₁ - a₃), sq_nonneg (a₁ - a₄),
             sq_nonneg (a₁ - a₅), sq_nonneg (a₂ - a₃), sq_nonneg (a₂ - a₄),
             sq_nonneg (a₂ - a₅), sq_nonneg (a₃ - a₄), sq_nonneg (a₃ - a₅),
             sq_nonneg (a₄ - a₅)]

/-! ## Section 9: The k=5 Reflection Over ℚ -/

/-- The reflected vector for (1,1,1,1,2) is not in ℤ⁵ -/

theorem k5_reflection_not_integral :
    ¬ (∃ r : ℤ, 3 * r = 2 * ((1:ℤ) + 1 + 1 + 1 - 2)) := by omega

/-! ## Section 10: Alternative Approaches for k = 5 -/

/-- Alternative reflection for k = 5 with η(s,s) = 1, always integral -/

def alt_reflect_5 : Matrix (Fin 5) (Fin 5) ℤ :=
  !![-1, -2, 0, 0, 2;
     -2, -1, 0, 0, 2;
      0,  0, 1, 0, 0;
      0,  0, 0, 1, 0;
     -2, -2, 0, 0, 3]


theorem alt_reflect_5_involution : alt_reflect_5 * alt_reflect_5 = 1 := by
  unfold alt_reflect_5; native_decide


def eta5 : Matrix (Fin 5) (Fin 5) ℤ :=
  !![1, 0, 0, 0, 0; 0, 1, 0, 0, 0; 0, 0, 1, 0, 0; 0, 0, 0, 1, 0; 0, 0, 0, 0, -1]


theorem alt_reflect_5_isLorentz :
    alt_reflect_5.transpose * eta5 * alt_reflect_5 = eta5 := by
  unfold alt_reflect_5 eta5; native_decide

/-! ## Section 11: Computational Exploration -/


def listPrimQuints (N : ℕ) : List (ℕ × ℕ × ℕ × ℕ × ℕ) := do
  let d ← List.range (N + 1)
  let e ← List.range (d + 1)
  let c ← List.range (e + 1)
  let b ← List.range (c + 1)
  let a ← List.range (b + 1)
  if b > 0 && d > 0 &&
     a * a + b * b + c * c + e * e == d * d &&
     Nat.gcd (Nat.gcd (Nat.gcd a b) (Nat.gcd c e)) d == 1
  then return (a, b, c, e, d)
  else .nil

#eval listPrimQuints 5
#eval (listPrimQuints 10).length

/-! ## Section 12: Summary

### The Complete Picture

| k | k-2 | (k-2)\|2? | (k-2)\|4? | All-ones descent |
|---|-----|-----------|-----------|------------------|
| 3 | 1   | Yes       | Yes       | ✓ Berggren tree  |
| 4 | 2   | Yes       | Yes       | ✓ Quadruple tree |
| 5 | 3   | No        | No        | ✗ Fails          |
| 6 | 4   | No        | Yes       | ✓ Sextuple tree! |
| 7 | 5   | No        | No        | ✗ Fails          |
| k≥7 | ≥5 | No       | No        | ✗ Fails          |

**k ∈ {3, 4, 6}** are the only dimensions where the all-ones reflection provides
universal descent on the null cone.
-/

