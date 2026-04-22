import Mathlib

/-! # CatalogBuild.EML.SPBResearch.NumberTheory

Auto-generated from theorem catalog database.
Domain: EML/SPBResearch
Declarations: 6
-/

noncomputable section

/-- Euler's two-term formula: spb(1/2, 1/3) = 1 -/
theorem euler_two_term : spbNT (1/2) (1/3) = 1 := by norm_num [spbNT]

/-- The "integer SPB" divisibility -/
theorem spb_2_3_integer : (1 - 2 * 3 : ℤ) ∣ (2 + 3) := ⟨-1, by ring⟩

/-- SPB norm is multiplicative -/
theorem spb_norm_multiplicative (x y : ℝ) (h : 1 - x * y ≠ 0) :
    1 + spbNT x y ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) / (1 - x * y) ^ 2 := by
  unfold spbNT; field_simp; ring

/-- Two-squares identity -/
theorem two_squares_product (a b c d : ℤ) :
    ∃ e f : ℤ, (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = e ^ 2 + f ^ 2 :=
  ⟨a * c - b * d, a * d + b * c, by ring⟩

/-- Two representations of a product of sums of squares -/
theorem two_representations (a b : ℤ) :
    (1 + a ^ 2) * (1 + b ^ 2) = (1 - a * b) ^ 2 + (a + b) ^ 2 ∧
    (1 + a ^ 2) * (1 + b ^ 2) = (1 + a * b) ^ 2 + (a - b) ^ 2 := by
  constructor <;> ring

/-- spb(1, n) divisibility: (1-n) | (1+n) iff (1-n) | 2 -/
theorem spb_1_n_divisibility (n : ℤ) :
    (1 - 1 * n) ∣ (1 + n) ↔ (1 - n) ∣ 2 := by
  simp only [one_mul]
  constructor
  · rintro ⟨c, hc⟩; exact ⟨c + 1, by linarith⟩
  · rintro ⟨c, hc⟩; exact ⟨c - 1, by linarith⟩

end
