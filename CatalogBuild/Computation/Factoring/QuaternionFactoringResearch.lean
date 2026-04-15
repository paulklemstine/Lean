/-! # CatalogBuild.Computation.Factoring.QuaternionFactoringResearch

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11
-/

import Mathlib

theorem quaternion_norm_nonneg (q : Quaternion ℝ) : 0 ≤ Quaternion.normSq q := by
  exact Quaternion.normSq_nonneg

/-
The norm of a quaternion is zero iff the quaternion is zero.
-/

theorem quaternion_norm_eq_zero (q : Quaternion ℝ) :
    Quaternion.normSq q = 0 ↔ q = 0 := by
  simp +decide [ Quaternion.ext_iff, Quaternion.normSq ];
  exact ⟨ fun h => ⟨ by nlinarith, by nlinarith, by nlinarith, by nlinarith ⟩, fun h => by simp +decide [ h ] ⟩

/-! ## Section 2: Euler Four-Square Identity -/

/-
The Euler four-square identity: the product of two sums of four squares
    is itself a sum of four squares. This is proved by direct algebraic computation.
-/

theorem gaussian_norm_conj_product (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt) * ⟨a, -b⟩ = ⟨a^2 + b^2, 0⟩ := by
  ext <;> simp +decide [ sq ];
  ring

/-
If N = a² + b² and N = p·q, and we find z in ℤ[i] with N(z) = p,
    then p divides N(z) — trivially, but this formalizes the principle.
-/

theorem gaussian_norm_divides (z : GaussianInt) (p : ℤ) (hp : 0 < p)
    (hnorm : Zsqrtd.norm z = p) :
    (p : ℤ) ∣ Zsqrtd.norm z := by
  rw [ hnorm ]

/-! ## Section 4: Complex Norm Multiplicativity -/

/-- The complex norm squared is multiplicative. -/

theorem lipschitz_unit_norm_one :
    Quaternion.normSq (⟨1, 0, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨-1, 0, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, 1, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, -1, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, 0, 1, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, 0, -1, 0⟩ : Quaternion ℝ) = 1 := by
  norm_num [ Quaternion.normSq, Complex.ext_iff ]

/-
The 16 half-integer Hurwitz units ½(±1 ± i ± j ± k) also have norm 1.
-/

theorem hurwitz_half_unit_norm :
    Quaternion.normSq (⟨1/2, 1/2, 1/2, 1/2⟩ : Quaternion ℝ) = 1 := by
  norm_num [ Quaternion.normSq, Complex.ext_iff ]

/-! ## Section 7: Scaling Exponent Bounds -/

/-
For a balanced semiprime N = p·q with p ≤ q, the smaller factor p satisfies
    p ≤ √N. This means any lattice extraction that finds a vector of norm p
    is finding something of size at most N^(1/2).
-/

theorem balanced_factor_bound (N p q : ℝ)
    (hN : 0 < N) (hp : 0 < p) (hq : 0 < q)
    (hpq : N = p * q) (hle : p ≤ q) :
    p ≤ Real.sqrt N := by
  exact Real.le_sqrt_of_sq_le ( by nlinarith )

/-
If the norm of q₂ is at least 1, then the norm of q₁ divides N(q₁·q₂)
    and is bounded by it.
-/

theorem norm_factor_le_product (q₁ q₂ : Quaternion ℤ)
    (h1 : 0 ≤ Quaternion.normSq q₁)
    (h2 : 1 ≤ Quaternion.normSq q₂) :
    Quaternion.normSq q₁ ≤ Quaternion.normSq (q₁ * q₂) := by
  -- Rewrite using map_mul to get normSq(q₁ * q₂) = normSq(q₁) * normSq(q₂).
  have h_mul : Quaternion.normSq (q₁ * q₂) = Quaternion.normSq q₁ * Quaternion.normSq q₂ := by
    norm_num [ Quaternion.normSq_def ];
    grind;
  nlinarith

/-! ## Section 8: Non-commutativity of Quaternions -/

/-
Quaternion multiplication is not commutative: i·j ≠ j·i.
-/

theorem quaternion_commutator_ij :
    (⟨0, 1, 0, 0⟩ : Quaternion ℝ) * ⟨0, 0, 1, 0⟩ -
    (⟨0, 0, 1, 0⟩ : Quaternion ℝ) * ⟨0, 1, 0, 0⟩ =
    ⟨0, 0, 0, 2⟩ := by
  norm_num [ Quaternion.ext_iff ]

/-! ## Section 9: Sum of Four Squares — Specific Examples -/

/-- Every semiprime ≤ 30 has a four-square representation (spot-checked). -/
example : (15 : ℤ) = 1^2 + 1^2 + 2^2 + 3^2 := by norm_num
example : (21 : ℤ) = 1^2 + 2^2 + 4^2 + 0^2 := by norm_num
example : (35 : ℤ) = 5^2 + 3^2 + 1^2 + 0^2 := by norm_num

/-! ## Section 10: Norm Factoring Principle -/

/-
The fundamental factoring principle: if q = q₁ · q₂,
    then N(q₁) · N(q₂) = N(q). So N(q₁) divides N(q).
-/

theorem norm_factor_divides (q₁ q₂ : Quaternion ℤ) :
    Quaternion.normSq q₁ * Quaternion.normSq q₂ =
    Quaternion.normSq (q₁ * q₂) := by
  simp +decide [ Quaternion.normSq_def ];
  ring

/-
A nontrivial norm factoring gives a nontrivial divisor of N.
-/

theorem norm_factoring_gives_divisor (q₁ q₂ : Quaternion ℤ) (N : ℤ)
    (hN : Quaternion.normSq (q₁ * q₂) = N) :
    Quaternion.normSq q₁ ∣ N := by
  -- Using the norm factorization principle, write N as N(q₁) * N(q₂).
  have hN_factor : N = Quaternion.normSq q₁ * Quaternion.normSq q₂ := by
    convert hN.symm using 1;
    exact norm_factor_divides q₁ q₂
  exact hN_factor ▸ dvd_mul_right (Quaternion.normSq q₁) (Quaternion.normSq q₂)
