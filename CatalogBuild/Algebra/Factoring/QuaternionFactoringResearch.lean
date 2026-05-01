/-! # CatalogBuild.Algebra.Factoring.QuaternionFactoringResearch

Auto-generated from theorem catalog database.
Domain: Algebra/Factoring
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionFactoringResearch
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem quaternion_norm_nonneg (q : Quaternion ℝ) : 0 ≤ Quaternion.normSq q := by
  exact Quaternion.normSq_nonneg


/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionFactoringResearch
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem quaternion_norm_eq_zero (q : Quaternion ℝ) :
    Quaternion.normSq q = 0 ↔ q = 0 := by
  simp +decide [ Quaternion.ext_iff, Quaternion.normSq ];
  exact ⟨ fun h => ⟨ by nlinarith, by nlinarith, by nlinarith, by nlinarith ⟩, fun h => by simp +decide [ h ] ⟩


/-- [Section: # CatalogBuild.Computation.Factoring.QuaternionFactoringResearch
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 11] -/
theorem gaussian_norm_conj_product (a b : ℤ) :
    (⟨a, b⟩ : GaussianInt) * ⟨a, -b⟩ = ⟨a^2 + b^2, 0⟩ := by
  ext <;> simp +decide [ sq ];
  ring


theorem gaussian_norm_divides (z : GaussianInt) (p : ℤ) (hp : 0 < p)
    (hnorm : Zsqrtd.norm z = p) :
    (p : ℤ) ∣ Zsqrtd.norm z := by
  rw [ hnorm ]


theorem lipschitz_unit_norm_one :
    Quaternion.normSq (⟨1, 0, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨-1, 0, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, 1, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, -1, 0, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, 0, 1, 0⟩ : Quaternion ℝ) = 1 ∧
    Quaternion.normSq (⟨0, 0, -1, 0⟩ : Quaternion ℝ) = 1 := by
  norm_num [ Quaternion.normSq, Complex.ext_iff ]


theorem hurwitz_half_unit_norm :
    Quaternion.normSq (⟨1/2, 1/2, 1/2, 1/2⟩ : Quaternion ℝ) = 1 := by
  norm_num [ Quaternion.normSq, Complex.ext_iff ]


theorem balanced_factor_bound (N p q : ℝ)
    (hN : 0 < N) (hp : 0 < p) (hq : 0 < q)
    (hpq : N = p * q) (hle : p ≤ q) :
    p ≤ Real.sqrt N := by
  exact Real.le_sqrt_of_sq_le ( by nlinarith )


theorem norm_factor_le_product (q₁ q₂ : Quaternion ℤ)
    (h1 : 0 ≤ Quaternion.normSq q₁)
    (h2 : 1 ≤ Quaternion.normSq q₂) :
    Quaternion.normSq q₁ ≤ Quaternion.normSq (q₁ * q₂) := by
  -- Rewrite using map_mul to get normSq(q₁ * q₂) = normSq(q₁) * normSq(q₂).
  have h_mul : Quaternion.normSq (q₁ * q₂) = Quaternion.normSq q₁ * Quaternion.normSq q₂ := by
    norm_num [ Quaternion.normSq_def ];
    grind;
  nlinarith


theorem quaternion_commutator_ij :
    (⟨0, 1, 0, 0⟩ : Quaternion ℝ) * ⟨0, 0, 1, 0⟩ -
    (⟨0, 0, 1, 0⟩ : Quaternion ℝ) * ⟨0, 1, 0, 0⟩ =
    ⟨0, 0, 0, 2⟩ := by
  norm_num [ Quaternion.ext_iff ]


/-- Every semiprime ≤ 30 has a four-square representation (spot-checked). -/
theorem norm_factor_divides (q₁ q₂ : Quaternion ℤ) :
    Quaternion.normSq q₁ * Quaternion.normSq q₂ =
    Quaternion.normSq (q₁ * q₂) := by
  simp +decide [ Quaternion.normSq_def ];
  ring


theorem norm_factoring_gives_divisor (q₁ q₂ : Quaternion ℤ) (N : ℤ)
    (hN : Quaternion.normSq (q₁ * q₂) = N) :
    Quaternion.normSq q₁ ∣ N := by
  -- Using the norm factorization principle, write N as N(q₁) * N(q₂).
  have hN_factor : N = Quaternion.normSq q₁ * Quaternion.normSq q₂ := by
    convert hN.symm using 1;
    exact norm_factor_divides q₁ q₂
  exact hN_factor ▸ dvd_mul_right (Quaternion.normSq q₁) (Quaternion.normSq q₂)


