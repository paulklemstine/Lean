import Mathlib

/-! # Number-Theoretic SPB -/

noncomputable section

/-- The SPB operator -/
def spbNT (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- spb(2, 3) = -1 -/
theorem spb_int_2_3 : spbNT 2 3 = -1 := by norm_num [spbNT]

/-- spb(1, -1) = 0 -/
theorem spb_int_1_neg1 : spbNT 1 (-1) = 0 := by norm_num [spbNT]

/-- spb(n, -n) = 0 for all n -/
theorem spb_n_neg_n (n : ℝ) : spbNT n (-n) = 0 := by simp [spbNT]

/-- The SPB norm identity -/
theorem gaussian_norm (x y : ℝ) :
    (1 + x ^ 2) * (1 + y ^ 2) = (1 - x * y) ^ 2 + (x + y) ^ 2 := by ring

/-- Machin step 1: spb(1/5, 1/5) = 5/12 -/
theorem machin_step1 : spbNT (1/5) (1/5) = 5/12 := by norm_num [spbNT]

/-- Machin step 2: spb(5/12, 5/12) = 120/119 -/
theorem machin_step2 : spbNT (5/12) (5/12) = 120/119 := by norm_num [spbNT]

/-- Machin step 3: spb(120/119, -1/239) = 1 -/
theorem machin_step3 : spbNT (120/119) (-1/239) = 1 := by norm_num [spbNT]

/-- Euler's two-term formula: spb(1/2, 1/3) = 1 -/
theorem euler_two_term : spbNT (1/2) (1/3) = 1 := by norm_num [spbNT]

/-- Hutton's formula: spb(1/3, 1/3) = 3/4 -/
theorem hutton_step1 : spbNT (1/3) (1/3) = 3/4 := by norm_num [spbNT]

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
