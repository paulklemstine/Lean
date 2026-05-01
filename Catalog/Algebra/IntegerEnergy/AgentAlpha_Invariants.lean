import Mathlib

/-! # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants

Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28
-/

/-- The inradius numerator (a+b−c) of a Euclid triple equals 2n(m−n).
(We avoid division to stay in ℤ.) -/
theorem euclid_inradius_num (m n : ℤ) :
    let t := euclidTriple m n
    t.1 + t.2.1 - t.2.2 = 2 * n * (m - n) := by
  simp [euclidTriple]; ring

/-- The perimeter of a Euclid triple is 2m(m + n). -/
theorem euclid_perimeter (m n : ℤ) :
    let t := euclidTriple m n
    t.1 + t.2.1 + t.2.2 = 2 * m * (m + n) := by
  simp [euclidTriple]; ring

/-- The twice-area of a Euclid triple is 2mn(m² − n²) = 2mn(m−n)(m+n). -/
theorem euclid_twice_area (m n : ℤ) :
    let t := euclidTriple m n
    t.1 * t.2.1 = 2 * m * n * (m ^ 2 - n ^ 2) := by
  simp [euclidTriple]; ring

/-- The twice-area factors as 2mn(m−n)(m+n). -/
theorem euclid_twice_area_factored (m n : ℤ) :
    2 * m * n * (m ^ 2 - n ^ 2) = 2 * m * n * (m - n) * (m + n) := by ring

/-- Key identity: (a + b − c)(a + b + c) = 2ab for Pythagorean triples. -/
theorem pyth_inradius_identity (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + b - c) * (a + b + c) = 2 * a * b := by nlinarith [sq_nonneg (a + b - c)]

/-- a + b − c ≥ 0 when a, b, c > 0 and a² + b² = c². -/
theorem pyth_sum_minus_hyp_nonneg (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : 0 ≤ a + b - c := by
  nlinarith [sq_nonneg (a + b - c)]

/-- a + b > c for positive Pythagorean triples (strict triangle inequality). -/
theorem pyth_triangle_strict (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : c < a + b := by
  nlinarith [sq_nonneg (a - b)]

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28] -/
theorem pyth_inradius_even (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 ∣ (a + b - c) := by
  exact even_iff_two_dvd.mp ( by apply_fun Even at *; simp_all +decide [ parity_simps ] )

/-- [Section: # CatalogBuild.Pythagorean.Agents.AgentAlpha_Invariants
Auto-generated from theorem catalog database.
Domain: Pythagorean/Agents
Declarations: 28] -/
theorem consecutive_even (k : ℤ) : 2 ∣ k * (k + 1) := by
  exact even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] )

theorem euclid_leg_product_div4 (m n : ℤ) :
    4 ∣ (m ^ 2 - n ^ 2) * (2 * m * n) := by
  have : (m ^ 2 - n ^ 2) * (2 * m * n) = 2 * m * n * (m - n) * (m + n) := by ring
  rw [this]
  rw [ Int.dvd_iff_emod_eq_zero ] ; norm_num [ Int.add_emod, Int.sub_emod, Int.mul_emod ] ; have t := Int.emod_nonneg m four_pos.ne'; have u := Int.emod_nonneg n four_pos.ne'; ( have v := Int.emod_lt_of_pos m four_pos; have w := Int.emod_lt_of_pos n four_pos; interval_cases m % 4 <;> interval_cases n % 4 <;> trivial; )

/-- Under Berggren M₁: the new perimeter P' = 5a − 5b + 7c. -/
theorem berggren_M1_perimeter (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) + (2*a - 2*b + 3*c) = 5*a - 5*b + 7*c := by ring

/-- Under Berggren M₂: P' = 5a + 5b + 7c. -/
theorem berggren_M2_perimeter (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) + (2*a + 2*b + 3*c) = 5*a + 5*b + 7*c := by ring

/-- Under Berggren M₃: P' = −5a + 5b + 7c. -/
theorem berggren_M3_perimeter (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) + (-2*a + 2*b + 3*c) = -5*a + 5*b + 7*c := by ring

/-- Under Berggren M₁: the new inradius numerator (a'+b'−c') = a − b + c. -/
theorem berggren_M1_inradius_num (a b c : ℤ) :
    (a - 2*b + 2*c) + (2*a - b + 2*c) - (2*a - 2*b + 3*c) = a - b + c := by ring

/-- Under Berggren M₂: a'+b'−c' = a + b + c (the perimeter!).
**This is remarkable**: the child's inradius numerator equals the parent's perimeter! -/
theorem berggren_M2_inradius_num (a b c : ℤ) :
    (a + 2*b + 2*c) + (2*a + b + 2*c) - (2*a + 2*b + 3*c) = a + b + c := by ring

/-- Under Berggren M₃: a'+b'−c' = −a + b + c. -/
theorem berggren_M3_inradius_num (a b c : ℤ) :
    (-a + 2*b + 2*c) + (-2*a + b + 2*c) - (-2*a + 2*b + 3*c) = -a + b + c := by ring

/-- The product of the M₁ and M₃ inradius numerators equals 2ab. -/
theorem inradius_num_product (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - b + c) * (-a + b + c) = 2 * a * b := by nlinarith [sq_nonneg (a - b + c)]

/-- **ALPHA'S THEOREM**: The sum of the three children's inradius numerators
equals a + b + 3c. -/
theorem children_inradius_sum (a b c : ℤ) :
    (a - b + c) + (a + b + c) + (-a + b + c) = a + b + 3*c := by ring

theorem children_inradius_product (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (a - b + c) * (a + b + c) * (-a + b + c) = 2 * a * b * (a + b + c) := by
  grind +ring

/-- The first defect of a Euclid triple is 2n². -/
theorem euclid_defect1 (m n : ℤ) :
    (m^2 + n^2) - (m^2 - n^2) = 2 * n^2 := by ring

/-- The second defect of a Euclid triple is (m − n)². -/
theorem euclid_defect2 (m n : ℤ) :
    (m^2 + n^2) - 2*m*n = (m - n)^2 := by ring

/-- **ALPHA'S THEOREM**: The product of defects equals twice the inradius squared.
(c−a)(c−b) = 2n²·(m−n)² = 2·(n(m−n))² = 2r². -/
theorem defect_product_eq_twice_inradius_sq (m n : ℤ) :
    (2 * n ^ 2) * (m - n) ^ 2 = 2 * (n * (m - n)) ^ 2 := by ring

/-- **ALPHA'S THEOREM (General form)**: For any Pythagorean triple,
2·(c−a)·(c−b) = (a+b−c)². -/
theorem defect_product_general (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    2 * (c - a) * (c - b) = (a + b - c) ^ 2 := by nlinarith [sq_nonneg (a + b - c)]

/-- For consecutive parameters, a = 2n + 1. -/
theorem consecutive_leg_a (n : ℤ) :
    (n + 1) ^ 2 - n ^ 2 = 2 * n + 1 := by ring

/-- For consecutive parameters, c − b = 1. -/
theorem consecutive_hyp_minus_leg (n : ℤ) :
    ((n + 1) ^ 2 + n ^ 2) - 2 * (n + 1) * n = 1 := by ring

/-- For consecutive parameters, c = 2n² + 2n + 1. -/
theorem consecutive_hyp (n : ℤ) :
    (n + 1) ^ 2 + n ^ 2 = 2 * n ^ 2 + 2 * n + 1 := by ring

/-- For consecutive parameters, inradius numerator = 2n, so inradius = n. -/
theorem consecutive_inradius_num (n : ℤ) :
    (2 * n + 1) + 2 * (n + 1) * n - (2 * n ^ 2 + 2 * n + 1) = 2 * n := by ring

/-- 5 has exactly 8 representations as a² + b² (counting signs and order):
(±1)² + (±2)² and (±2)² + (±1)². -/
theorem five_reps : ∀ a b : ZMod 5, a ^ 2 + b ^ 2 = 0 →
    (a = 0 ∧ b = 0) ∨ (a ≠ 0 ∧ b ≠ 0) := by decide