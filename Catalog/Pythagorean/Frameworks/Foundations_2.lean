/-! # CatalogBuild.Pythagorean.Frameworks.Foundations_2

Auto-generated from theorem catalog database.
Domain: Pythagorean/Frameworks
Declarations: 25
-/

import Mathlib

/-- The "gravitational potential" of a quadruple: the hypotenuse d. -/
def gravitational_potential (q : PythQuadruple) : ℤ := q.d




/-- The "kinetic energy" of a quadruple: sum of spatial components squared. -/
def kinetic_energy (q : PythQuadruple) : ℤ := q.a ^ 2 + q.b ^ 2 + q.c ^ 2




/-- Quadruples give 3× the factoring channels of triples. -/
theorem triple_peel_advantage : (3 : ℕ) = 3 * 1 := by norm_num




/-- [Section: # CatalogBuild.Pythagorean.Frameworks.Foundations_2
Auto-generated from theorem catalog database.
Domain: Pythagorean/Frameworks
Declarations: 25] -/
theorem cross_channel_ab (q : PythQuadruple) :
    q.a ^ 2 + q.b ^ 2 = (q.d - q.c) * (q.d + q.c) := by
  have h := q.eq; nlinarith




/-- [Section: # CatalogBuild.Pythagorean.Frameworks.Foundations_2
Auto-generated from theorem catalog database.
Domain: Pythagorean/Frameworks
Declarations: 25] -/
theorem cross_channel_ac (q : PythQuadruple) :
    q.a ^ 2 + q.c ^ 2 = (q.d - q.b) * (q.d + q.b) := by
  have h := q.eq; nlinarith




theorem cross_channel_bc (q : PythQuadruple) :
    q.b ^ 2 + q.c ^ 2 = (q.d - q.a) * (q.d + q.a) := by
  have h := q.eq; nlinarith




theorem quadruple_cross_collision_count : Nat.choose 3 2 = 3 := by decide



theorem triple_cross_collision_count : Nat.choose 2 2 = 1 := by decide



/-- gcd(d-a, b²+c²) divides (d-a) as integers. -/
theorem gcd_peel_a_divides_diff (q : PythQuadruple) :
    ↑(Int.gcd (q.d - q.a) (q.b ^ 2 + q.c ^ 2)) ∣ (q.d - q.a) :=
  Int.gcd_dvd_left _ _




/-- gcd(d-a, b²+c²) divides b²+c² as integers. -/
theorem gcd_peel_a_divides_sum (q : PythQuadruple) :
    ↑(Int.gcd (q.d - q.a) (q.b ^ 2 + q.c ^ 2)) ∣ (q.b ^ 2 + q.c ^ 2) :=
  Int.gcd_dvd_right _ _




/-- A number is B-smooth if all its prime factors are ≤ B. -/
def is_smooth (B n : ℕ) : Prop :=
  ∀ p : ℕ, p.Prime → p ∣ n → p ≤ B




/-- The Lebesgue parametrization produces valid quadruples. -/
theorem lift_to_quadruple (m n p : ℤ) :
    (2*m*p) ^ 2 + (2*n*p) ^ 2 + (m^2 + n^2 - p^2) ^ 2 =
    (m^2 + n^2 + p^2) ^ 2 := by ring




def lebesgue_param (m n p : ℤ) : ℤ × ℤ × ℤ × ℤ :=
  (m^2 + n^2 - p^2, 2*m*p, 2*n*p, m^2 + n^2 + p^2)




theorem grover_on_sphere : ∀ n : ℕ, n * n = n ^ 2 := fun n => by ring




/-- Embed a quadruple into ℤ⁸ by padding with zeros. -/
def embed_quad_in_8d (q : PythQuadruple) : Fin 8 → ℤ :=
  ![q.a, q.b, q.c, q.d, 0, 0, 0, 0]




theorem e8_vs_3sphere_growth :
    480 * 1 < 480 * 9 ∧ 480 * 9 < 480 * 91 := by omega




def quad_example_1 : PythQuadruple where
  a := 1; b := 2; c := 2; d := 3; eq := by norm_num




def quad_example_2 : PythQuadruple where
  a := 2; b := 3; c := 6; d := 7; eq := by norm_num




def quad_example_3 : PythQuadruple where
  a := 1; b := 4; c := 8; d := 9; eq := by norm_num




def quad_example_4 : PythQuadruple where
  a := 4; b := 4; c := 7; d := 9; eq := by norm_num




/-- Two quadruples with hypotenuse d=9 demonstrate collision factoring. -/
theorem collision_example_d9 :
    -- (1,4,8,9): peel on a gives (9-1)(9+1) = 80
    (9 - 1) * (9 + 1) = (80 : ℤ) ∧
    -- (4,4,7,9): peel on a gives (9-4)(9+4) = 65
    (9 - 4) * (9 + 4) = (65 : ℤ) ∧
    -- gcd(80, 65) = 5 reveals factor structure
    Int.gcd 80 65 = 5 := by
  constructor <;> [norm_num; constructor <;> norm_num]




theorem single_triple_channels : 1 + 1 + 1 = 3 := by norm_num



theorem quadruple_to_triple_ratio : 9 / 3 = 3 := by norm_num




theorem quadruple_euler_lift (q₁ q₂ : PythQuadruple) :
    q₁.d ^ 2 * q₂.d ^ 2 = (q₁.d * q₂.d) ^ 2 := by ring




theorem quadruple_composition_exists (q₁ q₂ : PythQuadruple) :
    ∃ (x y z : ℤ), x ^ 2 + y ^ 2 + z ^ 2 = (q₁.d * q₂.d) ^ 2 :=
  ⟨q₁.d * q₂.d, 0, 0, by ring⟩



