import Mathlib

/-! # CatalogBuild.Pythagorean.Berggren.BerggrenDeficitClassification

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 30
-/

/-- [Section: ## Section 1: Basic PPT Properties] -/
def IsPPT (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The deficit: d = c - b -/
def deficit (b c : ℤ) : ℤ := c - b

/-- The excess: e = c - a -/
def excess (a c : ℤ) : ℤ := c - a

/-- Key identity: a² = (c-b)(c+b) for PPTs -/
theorem deficit_times_sum (a b c : ℤ) (h : IsPPT a b c) :
    deficit b c * (c + b) = a ^ 2 := by
  simp [deficit, IsPPT] at *; nlinarith

/-- Key identity: b² = (c-a)(c+a) for PPTs -/
theorem excess_times_sum (a b c : ℤ) (h : IsPPT a b c) :
    excess a c * (c + a) = b ^ 2 := by
  simp [excess, IsPPT] at *; nlinarith

/-- Step A preserves deficit: (c' - b') = (c - b) -/
theorem stepA_preserves_deficit (a b c : ℤ) :
    deficit (2*a - b + 2*c) (2*a - 2*b + 3*c) = deficit b c := by
  simp [deficit]; ring

/-- Step B transforms deficit: d' = c + b -/
theorem stepB_transforms_deficit (a b c : ℤ) :
    deficit (2*a + b + 2*c) (2*a + 2*b + 3*c) = c + b := by
  simp [deficit]; ring

/-- Step C transforms deficit: d' = c + b -/
theorem stepC_transforms_deficit (a b c : ℤ) :
    deficit (-2*a + b + 2*c) (-2*a + 2*b + 3*c) = c + b := by
  simp [deficit]; ring

/-- Root has deficit 1 -/
theorem root_deficit_one : deficit 4 5 = 1 := by norm_num [deficit]

/-- All A-branch descendants preserve deficit -/
theorem A_branch_deficit_chain (a b c : ℤ) (hd : deficit b c = 1) :
    deficit (2*a - b + 2*c) (2*a - 2*b + 3*c) = 1 := by
  rw [stepA_preserves_deficit]; exact hd

/-- Euclid parametrization: (m²-n², 2mn, m²+n²) is a PPT -/
theorem euclid_is_ppt (m n : ℤ) :
    IsPPT (m^2 - n^2) (2*m*n) (m^2 + n^2) := by
  simp [IsPPT]; ring

/-- Deficit of Euclid PPT: c - b = (m-n)² -/
theorem euclid_deficit (m n : ℤ) :
    deficit (2*m*n) (m^2 + n^2) = (m - n)^2 := by
  simp [deficit]; ring

/-- Excess of Euclid PPT: c - a = 2n² -/
theorem euclid_excess (m n : ℤ) :
    excess (m^2 - n^2) (m^2 + n^2) = 2 * n^2 := by
  simp [excess]; ring

/-- **Deficit is a perfect square** for Euclid-parametrized PPTs -/
theorem euclid_deficit_is_square (m n : ℤ) :
    ∃ k : ℤ, deficit (2*m*n) (m^2 + n^2) = k ^ 2 := by
  exact ⟨m - n, euclid_deficit m n⟩

/-- The family (2n+1, 2n²+2n, 2n²+2n+1) has deficit 1 -/
theorem near_isosceles_deficit (n : ℤ) :
    deficit (2*n^2 + 2*n) (2*n^2 + 2*n + 1) = 1 := by
  simp [deficit]

/-- The near-isosceles family satisfies the PPT equation -/
theorem near_isosceles_is_ppt (n : ℤ) :
    IsPPT (2*n + 1) (2*n^2 + 2*n) (2*n^2 + 2*n + 1) := by
  simp [IsPPT]; ring

/-- Verify: n=1 gives (3,4,5) -/
theorem near_isosceles_1 :
    (2*(1:ℤ) + 1, 2*1^2 + 2*1, 2*1^2 + 2*1 + 1) = (3, 4, 5) := by norm_num

/-- Verify: n=2 gives (5,12,13) -/
theorem near_isosceles_2 :
    (2*(2:ℤ) + 1, 2*2^2 + 2*2, 2*2^2 + 2*2 + 1) = (5, 12, 13) := by norm_num

/-- Verify: n=3 gives (7,24,25) -/
theorem near_isosceles_3 :
    (2*(3:ℤ) + 1, 2*3^2 + 2*3, 2*3^2 + 2*3 + 1) = (7, 24, 25) := by norm_num

/-- Verify: n=4 gives (9,40,41) -/
theorem near_isosceles_4 :
    (2*(4:ℤ) + 1, 2*4^2 + 2*4, 2*4^2 + 2*4 + 1) = (9, 40, 41) := by norm_num

/-- B-step makes deficit grow: if b > 0, the new deficit is c + b > c - b -/
theorem stepB_deficit_grows (a b c : ℤ) (hb : 0 < b) :
    deficit b c < deficit (2*a + b + 2*c) (2*a + 2*b + 3*c) := by
  rw [stepB_transforms_deficit]; simp [deficit]; linarith

/-- deficit + excess = 2c - a - b -/
theorem deficit_plus_excess (a b c : ℤ) :
    deficit b c + excess a c = 2 * c - a - b := by
  simp [deficit, excess]; ring

/-- For a PPT: deficit · (c+b) + excess · (c+a) = c² -/
theorem deficit_excess_sum_sq (a b c : ℤ) (h : IsPPT a b c) :
    deficit b c * (c + b) + excess a c * (c + a) = c ^ 2 := by
  have h1 := deficit_times_sum a b c h
  have h2 := excess_times_sum a b c h
  simp [IsPPT] at h; nlinarith

/-- [Section: ## Section 9: Deficit and Perimeter] -/
def perim (a b c : ℤ) : ℤ := a + b + c

/-- Perimeter via deficit: P = a + 2c - d -/
theorem perimeter_via_deficit (a b c : ℤ) :
    perim a b c = a + 2 * c - deficit b c := by
  simp [perim, deficit]; ring

/-- For deficit-1 triples: P = 4n²+6n+2 -/
theorem near_isosceles_perimeter (n : ℤ) :
    perim (2*n + 1) (2*n^2 + 2*n) (2*n^2 + 2*n + 1) = 4*n^2 + 6*n + 2 := by
  simp [perim]; ring

/-- Area of near-isosceles PPT: 2·area = (2n+1)·2n(n+1) -/
theorem near_isosceles_double_area (n : ℤ) :
    (2*n + 1) * (2*n^2 + 2*n) = 2 * (2*n + 1) * n * (n + 1) := by ring

/-- The deficit divides a² for any PPT -/
theorem deficit_divides_a_sq (a b c : ℤ) (h : IsPPT a b c) :
    deficit b c ∣ a ^ 2 := by
  exact ⟨c + b, by linarith [deficit_times_sum a b c h]⟩

/-- For deficit d: a + b - c = a - d -/
theorem inradius_via_deficit (a b c : ℤ) :
    a + b - c = a - deficit b c := by
  simp [deficit]; ring

/-- Near-isosceles inradius: a + b - c = 2n -/
theorem near_isosceles_inradius (n : ℤ) :
    (2*n + 1) + (2*n^2 + 2*n) - (2*n^2 + 2*n + 1) = 2 * n := by ring