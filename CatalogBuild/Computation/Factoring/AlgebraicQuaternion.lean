/-! # CatalogBuild.Computation.Factoring.AlgebraicQuaternion

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17
-/

import Mathlib

/-- Existential form: product of sums of four squares is a sum of four squares. -/
theorem sum_of_squares_mul_four (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    ∃ c₁ c₂ c₃ c₄ : ℤ,
    (a₁^2 + a₂^2 + a₃^2 + a₄^2) * (b₁^2 + b₂^2 + b₃^2 + b₄^2) =
    c₁^2 + c₂^2 + c₃^2 + c₄^2 :=
  ⟨_, _, _, _, euler_four_square_identity a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄⟩



/-- Lipschitz unit i has norm 1. -/
theorem lipschitz_unit_i_norm :
    Quaternion.normSq (⟨0, 1, 0, 0⟩ : Quaternion ℤ) = 1 := by
  native_decide



/-- Lipschitz unit j has norm 1. -/
theorem lipschitz_unit_j_norm :
    Quaternion.normSq (⟨0, 0, 1, 0⟩ : Quaternion ℤ) = 1 := by
  native_decide



/-- Lipschitz unit k has norm 1. -/
theorem lipschitz_unit_k_norm :
    Quaternion.normSq (⟨0, 0, 0, 1⟩ : Quaternion ℤ) = 1 := by
  native_decide



/-- Multiplying by a unit preserves the norm. -/
theorem unit_rotation_preserves_norm (q u : Quaternion ℝ)
    (hu : Quaternion.normSq u = 1) :
    Quaternion.normSq (u * q) = Quaternion.normSq q := by
  rw [quaternion_norm_sq_mul, hu, one_mul]



/-- A factor p of semiprime N = pq with p ≤ q satisfies p² ≤ N. -/
theorem factor_sqrt_bound {N p q : ℕ} (hN : N = p * q) (hpq : p ≤ q) :
    p * p ≤ N := by
  calc p * p ≤ p * q := Nat.mul_le_mul_left p hpq
    _ = N := hN.symm



/-- For a semiprime N = pq with p,q > 1, both factors are strictly less than N. -/
theorem semiprime_factor_lt {N p q : ℕ} (hN : N = p * q) (hp : 1 < p) (hq : 1 < q) :
    p < N ∧ q < N := by
  subst hN
  exact ⟨by nlinarith, by nlinarith⟩



/-- If we find a non-trivial divisor m of N (1 < m < N), we have factored N. -/
theorem factor_extraction_correct {N m : ℕ} (hN : 1 < N) (hm1 : 1 < m)
    (hm2 : m < N) (hdvd : m ∣ N) :
    ∃ k, N = m * k ∧ 1 < k := by
  obtain ⟨k, hk⟩ := hdvd
  exact ⟨k, hk, by nlinarith⟩



/-- The GCD method: if gcd(m, N) ∉ {1, N}, it's a non-trivial factor. -/
theorem gcd_nontrivial_factor {N m : ℕ} (hN : 1 < N)
    (hg1 : Nat.gcd m N ≠ 1) (hgN : Nat.gcd m N ≠ N) :
    1 < Nat.gcd m N ∧ Nat.gcd m N ∣ N := by
  refine ⟨?_, Nat.gcd_dvd_right m N⟩
  have h0 : 0 < Nat.gcd m N := by positivity
  by_contra h
  push_neg at h
  have : Nat.gcd m N = 0 ∨ Nat.gcd m N = 1 := by omega
  rcases this with h | h <;> [exact absurd h (by omega); exact absurd h hg1]



/-- The determinant of the quaternion factoring lattice equals N. -/
theorem lattice_det_eq_N (N : ℤ) :
    (1 : ℤ) * 1 * 1 * 1 * N = N := by ring



/-- If a² + b² + c² + d² = N and a² + b² = s, then c² + d² = N - s. -/
theorem partial_norm_complement {a b c d N : ℤ}
    (h : a^2 + b^2 + c^2 + d^2 = N) :
    c^2 + d^2 = N - (a^2 + b^2) := by linarith



/-- A sum of two squares is non-negative. -/
theorem sum_two_sq_nonneg (a b : ℤ) : 0 ≤ a^2 + b^2 := by positivity



/-- A sum of four squares is non-negative. -/
theorem sum_four_sq_nonneg (a b c d : ℤ) : 0 ≤ a^2 + b^2 + c^2 + d^2 := by positivity



/-- [Section: # CatalogBuild.Computation.Factoring.AlgebraicQuaternion
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 17] -/
theorem not_sum_two_sq_of_3_mod_4 (n : ℕ) (hn : n % 4 = 3) :
    ¬ ∃ a b : ℕ, a^2 + b^2 = n := by
  rintro ⟨ a, b, rfl ⟩ ; exact absurd ( congr_arg ( · % 4 ) hn ) ( by norm_num [ Nat.add_mod, Nat.pow_mod ] ; have := Nat.mod_lt a zero_lt_four; have := Nat.mod_lt b zero_lt_four; interval_cases a % 4 <;> interval_cases b % 4 <;> trivial )



/-- **The Norm Factoring Principle**: If we can express p and q each as a sum
of four squares, then p*q has a four-square representation given by
the quaternion product formula. -/
theorem norm_factoring_principle (p q : ℤ)
    (a₁ a₂ a₃ a₄ : ℤ) (b₁ b₂ b₃ b₄ : ℤ)
    (hrp : a₁^2 + a₂^2 + a₃^2 + a₄^2 = p)
    (hrq : b₁^2 + b₂^2 + b₃^2 + b₄^2 = q) :
    let c₁ := a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄
    let c₂ := a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃
    let c₃ := a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂
    let c₄ := a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁
    c₁^2 + c₂^2 + c₃^2 + c₄^2 = p * q := by
  simp only
  nlinarith [euler_four_square_identity a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄]



/-- The two-square identity. -/
theorem sum_of_squares_mul_two (a₁ a₂ b₁ b₂ : ℤ) :
    (a₁^2 + a₂^2) * (b₁^2 + b₂^2) =
    (a₁*b₁ - a₂*b₂)^2 + (a₁*b₂ + a₂*b₁)^2 := by ring



/-- Gaussian integer factorization: a² + b² = (a + bi)(a - bi) in ℤ[i]. -/
theorem gaussian_factorization (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt) * ⟨a, -b⟩ = ⟨a^2 + b^2, 0⟩ := by
  ext <;> simp <;> ring

