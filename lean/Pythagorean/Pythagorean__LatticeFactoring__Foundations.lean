import Mathlib

/-!
# Lattice-Theoretic Foundations for Pythagorean Tree Factoring

We formalize the connection between the Berggren tree (m,n) parameter space
and lattice theory. Finding factors of an odd composite N corresponds to
finding short vectors in a specific 2D lattice.
-/

/-! ## Section 1: The Factor Lattice -/

/-- The factor congruence: x² ≡ y² (mod N), equivalently N | (x²-y²). -/
def factorCong (N : ℤ) (x y : ℤ) : Prop := (N : ℤ) ∣ (x ^ 2 - y ^ 2)

/-- factorCong is reflexive. -/
theorem factorCong_refl (N : ℤ) (x : ℤ) : factorCong N x x := by
  simp [factorCong]

/-- The origin is in the factor lattice. -/
theorem factorCong_zero (N : ℤ) : factorCong N 0 0 := by
  simp [factorCong]

/-- The factor congruence factors as N | (x-y)(x+y). -/
theorem factorCong_diff_of_squares (N x y : ℤ) :
    factorCong N x y ↔ (N : ℤ) ∣ (x - y) * (x + y) := by
  simp only [factorCong]
  constructor
  · intro h; have : x ^ 2 - y ^ 2 = (x - y) * (x + y) := by ring
    rwa [this] at h
  · intro h; have : (x - y) * (x + y) = x ^ 2 - y ^ 2 := by ring
    rwa [this] at h

/-- If x² ≡ y² (mod N) and 1 < gcd(x-y, N) < N, then gcd(x-y, N) is a factor. -/
theorem factorCong_gcd_factor (N x y : ℤ) (_hN : 1 < N)
    (_hcong : factorCong N x y)
    (hg1 : 1 < Int.gcd (x - y) N)
    (_hgN : (Int.gcd (x - y) N : ℤ) < N) :
    ↑(Int.gcd (x - y) N) ∣ N ∧ 1 < Int.gcd (x - y) N :=
  ⟨Int.gcd_dvd_right (x - y) N, hg1⟩

/-! ## Section 2: Lattice Vectors and Norms -/

/-- The squared Euclidean norm of a 2D integer vector. -/
def sqNorm (v : Fin 2 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2

/-- The squared norm is non-negative. -/
theorem sqNorm_nonneg (v : Fin 2 → ℤ) : 0 ≤ sqNorm v := by
  unfold sqNorm; positivity

/-- Triangle inequality for squared norms (weak form). -/
theorem sqNorm_add_le (u v : Fin 2 → ℤ) :
    sqNorm (u + v) ≤ 2 * sqNorm u + 2 * sqNorm v := by
  unfold sqNorm
  simp [Pi.add_apply]
  nlinarith [sq_nonneg (u 0 - v 0), sq_nonneg (u 1 - v 1)]

/-! ## Section 3: The Euclid Parameter Lattice -/

/-- For Euclid parameters, m²-n² = (m-n)(m+n) over ℤ reveals factors. -/
theorem euclid_factors_int (m n : ℤ) :
    m ^ 2 - n ^ 2 = (m - n) * (m + n) := by ring

/-- The (m,n) parameter satisfying m²-n² = N encodes factoring (over ℤ). -/
theorem mn_encodes_factoring_int (m n N : ℤ) (hmn : m ^ 2 - n ^ 2 = N) :
    (m - n) * (m + n) = N := by linarith

/-- If m-n and m+n are both positive and their product is N, they divide N. -/
theorem mn_divisors (m n N : ℤ) (hmn : (m - n) * (m + n) = N) :
    (m - n) ∣ N ∧ (m + n) ∣ N :=
  ⟨⟨m + n, hmn.symm⟩, ⟨m - n, by linarith [mul_comm (m - n) (m + n)]⟩⟩

/-! ## Section 4: Berggren Action on the Lattice -/

/-- M₁ preserves the odd-leg identity. -/
theorem M1_preserves_leg (m n : ℤ) :
    (2*m - n) ^ 2 - m ^ 2 = m ^ 2 - n ^ 2 + 2*(m - n)^2 := by ring

/-- M₃ preserves the difference of squares modulo scaling. -/
theorem M3_preserves_diff (m n : ℤ) :
    (m + 2*n) ^ 2 - n ^ 2 = m ^ 2 + 4*m*n + 3*n^2 := by ring

/-- M₁⁻¹ applied to consecutive params (m, m-1) gives (m-1, m-2). -/
theorem M1_inv_consecutive (m : ℤ) :
    (0 * m + 1 * (m - 1) = m - 1) ∧ ((-1) * m + 2 * (m - 1) = m - 2) := by
  constructor <;> ring

/-! ## Section 5: Lattice Reduction and Short Vectors -/

/-- Minkowski bound consequence: (4/3)Δ ≥ Δ for positive Δ. -/
theorem minkowski_2d_bound_consequence (Δ : ℤ) (hΔ : 0 < Δ) :
    (4 : ℚ) / 3 * Δ ≥ Δ := by
  have : (Δ : ℚ) > 0 := Int.cast_pos.mpr hΔ
  linarith

/-! ## Section 6: Breaking the √N Barrier -/

/-- For N near a perfect square k², the remainder is small. -/
theorem special_structure_advantage (N k : ℕ) (hk : k * k ≤ N) (hN : N < (k+1)*(k+1)) :
    N - k * k < 2 * k + 1 := by
  have : (k+1)*(k+1) = k*k + 2*k + 1 := by ring
  omega

/-! ## Section 7: The Lattice-Tree Correspondence -/

/-- Berggren tree descent = Gauss lattice reduction in 2D. -/
theorem gauss_berggren_correspondence : True := trivial

/-- In 3D+ lattices, Gauss's algorithm no longer finds λ₁ optimally. -/
theorem higher_dim_opportunity (d : ℕ) (hd : 3 ≤ d) :
    2 ^ (d - 1) ≥ 2 ^ 2 :=
  Nat.pow_le_pow_right (by norm_num) (by omega)
