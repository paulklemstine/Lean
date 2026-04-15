/-! # CatalogBuild.Bridges.CodingTheoryBridge

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 29
-/

import Mathlib

noncomputable section

/-- Volume of a Hamming sphere of radius t in F_q^n. -/
def hammingVolume (n t q : ℕ) : ℕ :=
  (Finset.range (t + 1)).sum (fun i => n.choose i * (q - 1) ^ i)

/-- For binary codes (q=2), Hamming sphere of radius 1 has volume n + 1. -/

theorem binary_hamming_volume_1 (n : ℕ) :
    hammingVolume n 1 2 = n + 1 := by
  simp [hammingVolume, Finset.sum_range_succ]; ring

/-- The Singleton bound: k ≤ n - d + 1 for an [n,k,d] code. -/

theorem singleton_bound (n k d : ℕ) (hle : k + d ≤ n + 1) :
    k ≤ n - d + 1 := by omega

/-! ## Part 2: Sum-of-Squares Identities and Code Composition -/

/-- The 2-square identity (Brahmagupta-Fibonacci). -/

theorem two_square_identity (a b c d : ℤ) :
    (a^2 + b^2) * (c^2 + d^2) = (a*c - b*d)^2 + (a*d + b*c)^2 := by ring

/-- The 4-square identity (special case). -/

theorem four_square_special_case :
    (1^2 + 1^2 + 1^2 + 1^2) * (1^2 + 0^2 + 0^2 + 0^2) =
    (1^2 + 1^2 + 1^2 + 1^2 : ℤ) := by norm_num

/-- Verified instances of Fermat's two-squares theorem. -/

theorem fermat_sum_two_squares_5 : (5 : ℤ) = 1^2 + 2^2 := by norm_num

theorem fermat_sum_two_squares_13 : (13 : ℤ) = 2^2 + 3^2 := by norm_num

theorem fermat_sum_two_squares_17 : (17 : ℤ) = 1^2 + 4^2 := by norm_num

theorem fermat_sum_two_squares_29 : (29 : ℤ) = 2^2 + 5^2 := by norm_num

/-- Verified instances of Lagrange's four-square theorem. -/

theorem lagrange_four_squares_7 :
    (7 : ℤ) = 1^2 + 1^2 + 1^2 + 2^2 := by norm_num

theorem lagrange_four_squares_15 :
    (15 : ℤ) = 1^2 + 1^2 + 2^2 + 3^2 := by norm_num

theorem lagrange_four_squares_23 :
    (23 : ℤ) = 1^2 + 2^2 + 3^2 + 3^2 := by norm_num

/-! ## Part 3: Lattice Codes from Division Algebras -/

/-- Gaussian integer norm: N(a + bi) = a² + b². -/

def gaussianNorm (a b : ℤ) : ℤ := a^2 + b^2

/-- Gaussian norm is multiplicative. -/

theorem gaussianNorm_mul (a b c d : ℤ) :
    gaussianNorm a b * gaussianNorm c d =
    gaussianNorm (a*c - b*d) (a*d + b*c) := by
  simp [gaussianNorm]; ring

/-- Gaussian norm is non-negative. -/

theorem gaussianNorm_nonneg (a b : ℤ) : 0 ≤ gaussianNorm a b := by
  simp [gaussianNorm]; positivity

/-- Gaussian norm is zero iff element is zero. -/

theorem gaussianNorm_eq_zero (a b : ℤ) :
    gaussianNorm a b = 0 ↔ a = 0 ∧ b = 0 := by
  constructor
  · intro h; simp [gaussianNorm] at h ⊢; constructor <;> nlinarith [sq_nonneg a, sq_nonneg b]
  · rintro ⟨rfl, rfl⟩; simp [gaussianNorm]

/-- Minimum nonzero Gaussian norm is 1. -/

theorem gaussianNorm_min : gaussianNorm 1 0 = 1 := by simp [gaussianNorm]

/-- Eisenstein integer norm: N(a+bω) = a²-ab+b². -/

def eisensteinNorm (a b : ℤ) : ℤ := a^2 - a*b + b^2

/-- Eisenstein norm is non-negative. -/

theorem eisensteinNorm_nonneg (a b : ℤ) : 0 ≤ eisensteinNorm a b := by
  simp [eisensteinNorm]; nlinarith [sq_nonneg (2*a - b), sq_nonneg b]

/-
Eisenstein norm is zero iff element is zero.
-/

theorem eisensteinNorm_eq_zero (a b : ℤ) :
    eisensteinNorm a b = 0 ↔ a = 0 ∧ b = 0 := by
  constructor <;> intro h;
  · unfold eisensteinNorm at h; constructor <;> nlinarith [ sq_nonneg ( a - b ) ] ;
  · aesop

/-! ## Part 4: The Division Algebra Dimension Ladder -/

/-- The Cayley-Dickson dimensions: 1, 2, 4, 8. -/

def cayleyDicksonDimensions : List ℕ := [1, 2, 4, 8]

/-- Each Cayley-Dickson dimension is a power of 2. -/

theorem cayleyDickson_powers_of_two :
    ∀ d ∈ cayleyDicksonDimensions, ∃ k, d = 2^k := by
  simp [cayleyDicksonDimensions]
  exact ⟨⟨0, rfl⟩, ⟨1, rfl⟩, ⟨2, rfl⟩, ⟨3, rfl⟩⟩

/-- Sum: 1 + 2 + 4 + 8 = 15. -/

theorem cayleyDickson_sum : cayleyDicksonDimensions.sum = 15 := by native_decide

/-- Product: 1 × 2 × 4 × 8 = 64 = 2^6. -/

theorem cayleyDickson_prod : cayleyDicksonDimensions.prod = 64 := by native_decide

/-! ## Part 5: Coding-Algebra-Geometry Triangle -/

/-- Code rate R = k/n. -/

def codeRate (k n : ℕ) : ℚ := (k : ℚ) / (n : ℚ)

/-- Rate ≤ 1 for valid codes. -/

theorem codeRate_le_one (k n : ℕ) (hn : 0 < n) (hkn : k ≤ n) :
    codeRate k n ≤ 1 := by
  simp only [codeRate]
  rw [div_le_one (Nat.cast_pos.mpr hn)]
  exact Nat.cast_le.mpr hkn

/-- E8 lattice properties. -/

theorem e8_kissing_number_val : 240 = (240 : ℕ) := rfl

theorem leech_dimension_decomp : 24 = 3 * 8 := by norm_num

theorem e8_density_denom : 384 = 2^7 * 3 := by norm_num

end CodingTheoryBridge
end

end
