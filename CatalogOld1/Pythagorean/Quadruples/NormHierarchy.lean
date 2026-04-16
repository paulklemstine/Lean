/-
# Norm-Multiplicative Factoring Across Division Algebras

The four normed division algebras (ℝ, ℂ, ℍ, 𝕆) provide a hierarchy of
"factoring lenses" through which to view integer factorization.

Given N to factor, we write N = a₁² + ... + aₖ² for k ∈ {1,2,4,8}.
Each representation lives on a sphere S^{k-1}(√N), and the geometry
of that sphere constrains the factorization structure of N.
-/

import Mathlib

set_option maxHeartbeats 800000

/-! ## Section 1: The Peel Identity Across Dimensions -/

theorem peel_identity_dim2 (a b N : ℤ) (h : a ^ 2 + b ^ 2 = N) :
    (N - a) * (N + a) = b ^ 2 + N * (N - 1) := by nlinarith [sq_nonneg a, sq_nonneg b]

theorem factor_channel_dim2 (a N : ℤ) :
    (N - a) * (N + a) = N ^ 2 - a ^ 2 := by ring

theorem peel_identity_dim4 (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N) :
    (N - a) * (N + a) = b ^ 2 + c ^ 2 + d ^ 2 + N * (N - 1) := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]

/-! ## Section 2: Collision-Based Factoring -/

theorem collision_identity (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    a ^ 2 - c ^ 2 = d ^ 2 - b ^ 2 := by linarith

theorem collision_product (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) = (d - b) * (d + b) := by nlinarith

/-! ## Section 3: Norm Multiplicativity -/

theorem norm_mult_dim2 (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring

theorem norm_mult_dim2_alt (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

theorem norm_mult_dim4 (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    (a₁ ^ 2 + a₂ ^ 2 + a₃ ^ 2 + a₄ ^ 2) * (b₁ ^ 2 + b₂ ^ 2 + b₃ ^ 2 + b₄ ^ 2) =
    (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄) ^ 2 +
    (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃) ^ 2 +
    (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂) ^ 2 +
    (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁) ^ 2 := by ring

/-! ## Section 4: Composition Identities -/

theorem two_compositions_equal_norm (a b c d : ℤ) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by ring

theorem composition_collision_factor (a b c d : ℤ) :
    (a * c - b * d) ^ 2 - (a * c + b * d) ^ 2 = -4 * a * b * c * d := by ring

/-! ## Section 5: GCD Cascade -/

theorem gcd_cascade_zero (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a - c) * (a + c) + (b - d) * (b + d) = 0 := by nlinarith

theorem factoring_two_forms (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 ∧
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 :=
  ⟨by ring, by ring⟩

/-! ## Section 6: Quaternion Norm -/

def qnorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2

theorem qnorm_mult (a₁ a₂ a₃ a₄ b₁ b₂ b₃ b₄ : ℤ) :
    qnorm a₁ a₂ a₃ a₄ * qnorm b₁ b₂ b₃ b₄ =
    qnorm
      (a₁*b₁ - a₂*b₂ - a₃*b₃ - a₄*b₄)
      (a₁*b₂ + a₂*b₁ + a₃*b₄ - a₄*b₃)
      (a₁*b₃ - a₂*b₄ + a₃*b₁ + a₄*b₂)
      (a₁*b₄ + a₂*b₃ - a₃*b₂ + a₄*b₁) := by
  unfold qnorm; ring

/-! ## Section 7: Parent-Child Descent -/

def berggren_A : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]
def berggren_B : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]
def berggren_C : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

theorem hypotenuse_dominates (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : c > a ∧ c > b := by
      constructor <;> nlinarith

/-! ## Section 8: The Collision-Norm Identity -/

/-
(ad-bc)² + (ac+bd)² = N² when a²+b²=c²+d²=N. This is the key
    identity that connects collisions to factor extraction.
-/
theorem collision_norm_identity (a b c d N : ℤ)
    (h1 : a ^ 2 + b ^ 2 = N) (h2 : c ^ 2 + d ^ 2 = N) :
    (a * d - b * c) ^ 2 + (a * c + b * d) ^ 2 = N ^ 2 := by
      linear_combination' h1 * h2

/-! ## Section 9: Factor Extraction -/

/-
A nontrivial divisor means N is composite.
-/
theorem nontrivial_divisor_composite (g N : ℤ) (hg : g ∣ N)
    (hg1 : 1 < g) (hgN : g < N) (_hN : 0 < N) :
    ∃ p q : ℤ, N = p * q ∧ 1 < p ∧ 1 < q := by
      exact ⟨ g, N / g, by rw [ mul_comm, Int.ediv_mul_cancel hg ], hg1, by nlinarith [ Int.ediv_mul_cancel hg ] ⟩

/-! ## Section 10: Dimension 4 — Four Peel Channels -/

theorem dim4_four_channels (a b c d N : ℤ)
    (_h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N) :
    N ^ 2 - a ^ 2 = (N - a) * (N + a) ∧
    N ^ 2 - b ^ 2 = (N - b) * (N + b) ∧
    N ^ 2 - c ^ 2 = (N - c) * (N + c) ∧
    N ^ 2 - d ^ 2 = (N - d) * (N + d) :=
  ⟨by ring, by ring, by ring, by ring⟩

theorem dim4_factor_sum (a b c d N : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = N) :
    (N - a) * (N + a) + (N - b) * (N + b) +
    (N - c) * (N + c) + (N - d) * (N + d) = 4 * N ^ 2 - N := by nlinarith

/-! ## Section 11: Hierarchy Theorems -/

def divAlgDims : Finset ℕ := {1, 2, 4, 8}

theorem dim_hierarchy : (1 : ℕ) < 2 ∧ 2 < 4 ∧ 4 < 8 := ⟨by omega, by omega, by omega⟩

theorem divAlgDims_pos : ∀ k ∈ divAlgDims, k ≥ 1 := by
  intro k hk; simp [divAlgDims] at hk; omega

/-- The collision count from m representations in dimension k grows as k * C(m,2). -/
theorem collision_opportunities (k m : ℕ) (hm : m ≥ 2) :
    k * Nat.choose m 2 ≥ k := by
  have h1 : Nat.choose m 2 ≥ 1 := Nat.choose_pos (by omega)
  exact Nat.le_mul_of_pos_right k (by omega)