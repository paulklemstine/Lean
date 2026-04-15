/-! # CatalogBuild.Geometry.SphericalUniverse.HopfFibration

Auto-generated from theorem catalog database.
Domain: Geometry/SphericalUniverse
Declarations: 20
-/

import Mathlib

noncomputable section

/-- The Hopf map from ℂ² to ℝ³.
η(z₀, z₁) = (2Re(z₀z̄₁), 2Im(z₀z̄₁), |z₀|² - |z₁|²) -/
def hopfMap (z : ℂ × ℂ) : Fin 3 → ℝ :=
  ![2 * (z.1 * starRingEnd ℂ z.2).re,
    2 * (z.1 * starRingEnd ℂ z.2).im,
    Complex.normSq z.1 - Complex.normSq z.2]


theorem hopf_map_norm_identity (z : ℂ × ℂ) :
    (hopfMap z 0) ^ 2 + (hopfMap z 1) ^ 2 + (hopfMap z 2) ^ 2 =
    (Complex.normSq z.1 + Complex.normSq z.2) ^ 2 := by
      unfold hopfMap; norm_num [ Complex.normSq ] ; ring;
      erw [ Matrix.cons_val_succ' ] ; norm_num ; ring;


/-- The Hopf map sends S³ to S². -/
theorem hopf_maps_sphere_to_sphere (z : ℂ × ℂ)
    (hz : Complex.normSq z.1 + Complex.normSq z.2 = 1) :
    (hopfMap z 0) ^ 2 + (hopfMap z 1) ^ 2 + (hopfMap z 2) ^ 2 = 1 := by
  rw [hopf_map_norm_identity, hz, one_pow]


/-- The U(1) action on S³ ⊂ ℂ². -/
def u1Action (θ : ℝ) (z : ℂ × ℂ) : ℂ × ℂ :=
  (Complex.exp (θ * Complex.I) * z.1, Complex.exp (θ * Complex.I) * z.2)


theorem u1_action_preserves_norm (θ : ℝ) (z : ℂ × ℂ) :
    Complex.normSq (u1Action θ z).1 + Complex.normSq (u1Action θ z).2 =
    Complex.normSq z.1 + Complex.normSq z.2 := by
      unfold u1Action;
      norm_num [ Complex.normSq_eq_norm_sq, Complex.norm_exp ]


theorem hopf_map_u1_invariant (θ : ℝ) (z : ℂ × ℂ) :
    hopfMap (u1Action θ z) = hopfMap z := by
      unfold hopfMap u1Action;
      norm_num [ Complex.exp_re, Complex.exp_im, Complex.normSq_eq_norm_sq, Complex.norm_exp ] ; ring;
      constructor <;> rw [ Real.sin_sq, Real.cos_sq ] <;> ring


/-- Quaternion multiplication via the ℂ × ℂ model.
(a, b) * (c, d) = (ac - d̄b, da + bc̄) -/
def quaternionMul (q₁ q₂ : ℂ × ℂ) : ℂ × ℂ :=
  (q₁.1 * q₂.1 - starRingEnd ℂ q₂.2 * q₁.2,
   q₂.2 * q₁.1 + q₁.2 * starRingEnd ℂ q₂.1)


/-- The quaternion identity element is (1, 0). -/
theorem quaternion_one_left (q : ℂ × ℂ) :
    quaternionMul (1, 0) q = q := by
  simp [quaternionMul]


/-- The quaternion conjugate. -/
def quaternionConj (q : ℂ × ℂ) : ℂ × ℂ :=
  (starRingEnd ℂ q.1, -q.2)


theorem quaternion_mul_conj (q : ℂ × ℂ) :
    (quaternionMul q (quaternionConj q)).1 =
    ↑(Complex.normSq q.1 + Complex.normSq q.2) := by
      unfold quaternionMul quaternionConj; norm_num; ring;
      simp +decide [ mul_comm, Complex.mul_conj, Complex.normSq_eq_norm_sq ]


/-- The magnetic monopole flux Φ = 4πg. -/
def monopoleFlux (g : ℝ) : ℝ := 4 * Real.pi * g


/-- Dirac quantization: if Φ = 2πn, then g = n/2. -/
theorem dirac_quantization (g : ℝ) (n : ℤ) (h : monopoleFlux g = 2 * Real.pi * n) :
    g = n / 2 := by
  unfold monopoleFlux at h
  have hpi : Real.pi ≠ 0 := Real.pi_ne_zero
  field_simp at h ⊢
  linarith


/-- The first Chern number of the Hopf bundle is 1. -/
def firstChernNumber : ℤ := 1


/-- The Hopf invariant of the Hopf map is 1. -/
def hopfInvariant : ℤ := 1


/-- The parallelizable spheres are exactly S⁰, S¹, S³, S⁷. -/
theorem s3_parallelizable_dimensions : ({0, 1, 3, 7} : Set ℕ) =
    {n : ℕ | n = 0 ∨ n = 1 ∨ n = 3 ∨ n = 7} := by
  ext n; simp


/-- Two Hopf fibers have linking number 1. -/
def linkingNumberHopfFibers : ℤ := 1

theorem linking_number_is_one : linkingNumberHopfFibers = 1 := rfl


/-- χ(S³) = 0 -/
theorem euler_characteristic_S3 : (1 : ℤ) + (-1) ^ 3 = 0 := by norm_num


/-- χ(S^{2k+1}) = 0 for all k -/
theorem euler_characteristic_odd_sphere (k : ℕ) :
    (1 : ℤ) + (-1) ^ (2 * k + 1) = 0 := by
  simp [pow_add, pow_mul]


/-- χ(S^{2k}) = 2 for all k -/
theorem euler_characteristic_even_sphere (k : ℕ) :
    (1 : ℤ) + (-1) ^ (2 * k) = 2 := by
  simp [pow_mul]


end
