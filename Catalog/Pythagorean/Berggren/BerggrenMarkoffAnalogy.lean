import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenMarkoffAnalogy

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 34
-/

/-- [Section: ## Section 1: Markoff Equation] -/
def IsMarkoff (x y z : ℤ) : Prop := x ^ 2 + y ^ 2 + z ^ 2 = 3 * x * y * z

theorem markoff_root : IsMarkoff 1 1 1 := by simp [IsMarkoff]

theorem markoff_112 : IsMarkoff 1 1 2 := by simp [IsMarkoff]

theorem markoff_125 : IsMarkoff 1 2 5 := by simp [IsMarkoff]

theorem markoff_1_5_13 : IsMarkoff 1 5 13 := by simp [IsMarkoff]

theorem markoff_2_5_29 : IsMarkoff 2 5 29 := by norm_num [IsMarkoff]

/-- [Section: ## Section 2: Vieta Involutions] -/
def markoffV1 (x y z : ℤ) : ℤ × ℤ × ℤ := (3 * y * z - x, y, z)

def markoffV2 (x y z : ℤ) : ℤ × ℤ × ℤ := (x, 3 * x * z - y, z)

def markoffV3 (x y z : ℤ) : ℤ × ℤ × ℤ := (x, y, 3 * x * y - z)

theorem markoffV1_preserves (x y z : ℤ) (h : IsMarkoff x y z) :
    IsMarkoff (markoffV1 x y z).1 (markoffV1 x y z).2.1 (markoffV1 x y z).2.2 := by
  simp only [markoffV1, IsMarkoff] at *; nlinarith

theorem markoffV2_preserves (x y z : ℤ) (h : IsMarkoff x y z) :
    IsMarkoff (markoffV2 x y z).1 (markoffV2 x y z).2.1 (markoffV2 x y z).2.2 := by
  simp only [markoffV2, IsMarkoff] at *; nlinarith

theorem markoffV3_preserves (x y z : ℤ) (h : IsMarkoff x y z) :
    IsMarkoff (markoffV3 x y z).1 (markoffV3 x y z).2.1 (markoffV3 x y z).2.2 := by
  simp only [markoffV3, IsMarkoff] at *; nlinarith

/-- [Section: ## Section 3: Involutions are Self-Inverse] -/
theorem markoffV1_involution (x y z : ℤ) (h : IsMarkoff x y z) :
    markoffV1 (markoffV1 x y z).1 (markoffV1 x y z).2.1 (markoffV1 x y z).2.2 = (x, y, z) := by
  simp only [markoffV1, IsMarkoff] at *; ext <;> simp <;> linarith

theorem markoffV2_involution (x y z : ℤ) (h : IsMarkoff x y z) :
    markoffV2 (markoffV2 x y z).1 (markoffV2 x y z).2.1 (markoffV2 x y z).2.2 = (x, y, z) := by
  simp only [markoffV2, IsMarkoff] at *; ext <;> simp <;> linarith

theorem markoffV3_involution (x y z : ℤ) (h : IsMarkoff x y z) :
    markoffV3 (markoffV3 x y z).1 (markoffV3 x y z).2.1 (markoffV3 x y z).2.2 = (x, y, z) := by
  simp only [markoffV3, IsMarkoff] at *; ext <;> simp <;> linarith

/-- [Section: ## Section 4: Symmetry] -/
theorem markoff_sym12 (x y z : ℤ) (h : IsMarkoff x y z) : IsMarkoff y x z := by
  simp only [IsMarkoff] at *; linarith

theorem markoff_sym13 (x y z : ℤ) (h : IsMarkoff x y z) : IsMarkoff z y x := by
  simp only [IsMarkoff] at *; linarith

theorem markoff_sym23 (x y z : ℤ) (h : IsMarkoff x y z) : IsMarkoff x z y := by
  simp only [IsMarkoff] at *; linarith

/-- [Section: ## Section 5: Tree Computation] -/
theorem markoff_from_112_V1 : markoffV1 1 1 2 = (5, 1, 2) := by simp [markoffV1]

theorem markoff_from_125_V1 : markoffV1 1 2 5 = (29, 2, 5) := by simp [markoffV1]

theorem markoff_from_125_V2 : markoffV2 1 2 5 = (1, 13, 5) := by simp [markoffV2]

theorem markoff_29_2_5 : IsMarkoff 29 2 5 := by norm_num [IsMarkoff]

/-- [Section: ## Section 6: Growth] -/
theorem markoff_largest_bound (x y z : ℤ) (h : IsMarkoff x y z)
    (hx : 1 ≤ x) (hz : 1 ≤ z) :
    z ≤ 3 * x * y := by
  simp only [IsMarkoff] at h; nlinarith [sq_nonneg x, sq_nonneg y, sq_nonneg z]

/-- [Section: ## Section 7: Vieta Discriminant] -/
def markoff_disc (x y : ℤ) : ℤ := 9 * x ^ 2 * y ^ 2 - 4 * x ^ 2 - 4 * y ^ 2

theorem markoff_disc_11 : markoff_disc 1 1 = 1 := by simp [markoff_disc]

theorem markoff_disc_12 : markoff_disc 1 2 = 16 := by simp [markoff_disc]

theorem markoff_disc_25 : markoff_disc 2 5 = 784 := by simp [markoff_disc]

theorem markoff_disc_is_square (x y z : ℤ) (h : IsMarkoff x y z) :
    ∃ d : ℤ, markoff_disc x y = d ^ 2 := by
  use 3 * x * y - 2 * z
  simp only [markoff_disc, IsMarkoff] at *; nlinarith

/-- [Section: ## Section 8: Markoff Uniqueness Conjecture (Statement)] -/
def MarkoffUnicityConjecture : Prop :=
  ∀ x₁ y₁ x₂ y₂ z : ℤ,
    IsMarkoff x₁ y₁ z → IsMarkoff x₂ y₂ z →
    1 ≤ x₁ → x₁ ≤ y₁ → y₁ ≤ z →
    1 ≤ x₂ → x₂ ≤ y₂ → y₂ ≤ z →
    x₁ = x₂ ∧ y₁ = y₂

/-- [Section: ## Section 9: More Markoff Numbers] -/
theorem markoff_num_34 : IsMarkoff 1 13 34 := by norm_num [IsMarkoff]

theorem markoff_num_89 : IsMarkoff 1 34 89 := by norm_num [IsMarkoff]

theorem markoff_num_169 : IsMarkoff 2 29 169 := by norm_num [IsMarkoff]

theorem markoff_num_194 : IsMarkoff 5 13 194 := by norm_num [IsMarkoff]

theorem markoff_growth :
    (1 : ℤ) < 2 ∧ 2 < 5 ∧ 5 < 13 ∧ 13 < 29 ∧ 29 < 34 ∧ 34 < 89 ∧ 89 < 169 ∧ 169 < 194 := by
  omega