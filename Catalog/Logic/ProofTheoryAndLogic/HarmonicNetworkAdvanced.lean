import Mathlib

/-! # CatalogBuild.Logic.HarmonicNetworkAdvanced

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 23
-/

/-- ReLU applied to a rational number yields a rational number. -/
theorem relu_rational (q : ℚ) : ∃ r : ℚ, r = max 0 q := ⟨max 0 q, rfl⟩

/-- [Section: # CatalogBuild.Logic.HarmonicNetworkAdvanced
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 23] -/
theorem stereo_first_component_bounded (m n : ℝ) (h : m ^ 2 + n ^ 2 ≠ 0) :
    |2 * m * n / (m ^ 2 + n ^ 2)| ≤ 1 := by
  exact abs_le.mpr ⟨ by rw [ le_div_iff₀ ( by positivity ) ] ; nlinarith [ sq_nonneg ( m - n ), sq_nonneg ( m + n ) ], by rw [ div_le_iff₀ ( by positivity ) ] ; nlinarith [ sq_nonneg ( m - n ), sq_nonneg ( m + n ) ] ⟩

/-- [Section: # CatalogBuild.Logic.HarmonicNetworkAdvanced
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 23] -/
theorem stereo_second_component_bounded (m n : ℝ) (h : m ^ 2 + n ^ 2 ≠ 0) :
    |(n ^ 2 - m ^ 2) / (m ^ 2 + n ^ 2)| ≤ 1 := by
  exact abs_le.mpr ⟨ by rw [ le_div_iff₀ <| by positivity ] ; nlinarith, by rw [ div_le_iff₀ <| by positivity ] ; nlinarith ⟩

-- =====================================================================
-- SECTION 3: NEGATION SYMMETRY
-- =====================================================================

/-- Negating both parameters preserves the first component. -/
theorem stereo_neg_both (m n : ℚ) :
    2 * (-m) * (-n) / ((-m) ^ 2 + (-n) ^ 2) = 2 * m * n / (m ^ 2 + n ^ 2) := by
  ring

/-- Negating only the first parameter negates the first component. -/
theorem stereo_neg_first (m n : ℚ) :
    2 * (-m) * n / ((-m) ^ 2 + n ^ 2) = -(2 * m * n / (m ^ 2 + n ^ 2)) := by
  ring

/-- Swapping parameters swaps the sign of the second component. -/
theorem stereo_swap_second (m n : ℚ) :
    (m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2) = -((n ^ 2 - m ^ 2) / (m ^ 2 + n ^ 2)) := by
  ring

-- =====================================================================
-- SECTION 4: SUM OF SQUARES PROPERTIES
-- =====================================================================

/-- Sum of squares of a list of integers is nonnegative. -/
theorem sum_sq_nonneg_list (ms : List ℤ) : 0 ≤ (ms.map (· ^ 2)).sum := by
  apply List.sum_nonneg
  intro x hx
  simp only [List.mem_map] at hx
  obtain ⟨a, _, rfl⟩ := hx
  positivity

theorem sum_sq_eq_zero_iff (ms : List ℤ) :
    (ms.map (· ^ 2)).sum = 0 ↔ ∀ m ∈ ms, m = 0 := by
  induction ms <;> simp +contextual [ *, List.sum_cons ];
  constructor <;> intro h;
  · rename_i k l ih;
    exact ⟨ by nlinarith [ List.sum_nonneg ( show ∀ x ∈ List.map ( fun x => x ^ 2 ) l, 0 ≤ x from by intros x hx; rw [ List.mem_map ] at hx; rcases hx with ⟨ y, hy, rfl ⟩ ; positivity ) ], ih.mp <| by nlinarith [ List.sum_nonneg ( show ∀ x ∈ List.map ( fun x => x ^ 2 ) l, 0 ≤ x from by intros x hx; rw [ List.mem_map ] at hx; rcases hx with ⟨ y, hy, rfl ⟩ ; positivity ) ] ⟩;
  · aesop

-- =====================================================================
-- SECTION 5: RATIONAL DOT PRODUCT
-- =====================================================================

/-- The dot product of two rational vectors is rational (closure of ℚ). -/
theorem rational_dot_product (v w : Fin n → ℚ) :
    ∃ r : ℚ, r = ∑ i, v i * w i := ⟨∑ i, v i * w i, rfl⟩

/-- ReLU applied pointwise to a rational vector yields a rational vector. -/
theorem relu_pointwise_rational (v : Fin n → ℚ) :
    ∃ w : Fin n → ℚ, ∀ i, w i = max 0 (v i) :=
  ⟨fun i => max 0 (v i), fun _ => rfl⟩

theorem stereo_second_lipschitz (t₁ t₂ : ℝ) (ht₁ : |t₁| ≤ 1) (ht₂ : |t₂| ≤ 1) :
    |(1 - t₁ ^ 2) / (1 + t₁ ^ 2) - (1 - t₂ ^ 2) / (1 + t₂ ^ 2)| ≤ 2 * |t₁ - t₂| := by
  field_simp;
  -- We'll use the fact that |t₁ + t₂| ≤ 2 and (1 + t₁^2)(1 + t₂^2) ≥ 1 to bound the expression.
  have h_bound : |(t₂ - t₁) * (t₂ + t₁)| ≤ 2 * |t₁ - t₂| * ((1 + t₁^2) * (1 + t₂^2)) / 2 := by
    rw [ abs_mul, abs_sub_comm ] ; ring_nf ; (
    -- We can divide both sides by $|t₁ - t₂|$ (which is positive since $t₁ \neq t₂$).
    suffices h_div : |t₁ + t₂| ≤ t₁ ^ 2 * t₂ ^ 2 + t₁ ^ 2 + t₂ ^ 2 + 1 by
      nlinarith [ abs_nonneg ( t₁ - t₂ ) ];
    exact abs_le.mpr ⟨ by nlinarith only [ sq_nonneg ( t₁ - t₂ ), sq_nonneg ( t₁ + t₂ ), abs_le.mp ht₁, abs_le.mp ht₂ ], by nlinarith only [ sq_nonneg ( t₁ - t₂ ), sq_nonneg ( t₁ + t₂ ), abs_le.mp ht₁, abs_le.mp ht₂ ] ⟩);
  rw [ abs_le ] at *;
  exact ⟨ by rw [ le_div_iff₀ <| by positivity ] ; nlinarith, by rw [ div_le_iff₀ <| by positivity ] ; nlinarith ⟩

theorem rational_approx_error (t₀ : ℚ) (N : ℕ) (hN : 0 < N) :
    ∃ p : ℤ, |p / (N : ℚ) - t₀| ≤ 1 / (2 * N) := by
  refine' ⟨ ⌊t₀ * N + 1 / 2⌋, _ ⟩ ; rw [ abs_le ] ; constructor <;> norm_num [ mul_assoc, mul_comm, mul_left_comm ] at * <;> ring_nf at * <;> norm_num [ hN.ne' ] at *;
  · field_simp;
    linarith [ Int.lt_floor_add_one ( ( 1 + t₀ * 2 * N ) / 2 ) ];
  · field_simp;
    linarith [ Int.floor_le ( ( 1 + 2 * t₀ * N ) / 2 ) ]

-- =====================================================================
-- SECTION 8: SCALE INVARIANCE
-- =====================================================================

/-- Scaling the integer vector by a nonzero constant does not change the
projected rational point. The projection is scale-invariant. -/
theorem stereo_scale_invariant (m n k : ℚ) (hk : k ≠ 0) (_h : m ^ 2 + n ^ 2 ≠ 0) :
    2 * (k * m) * (k * n) / ((k * m) ^ 2 + (k * n) ^ 2) =
    2 * m * n / (m ^ 2 + n ^ 2) := by
  have hk2 : k ^ 2 ≠ 0 := pow_ne_zero 2 hk
  have hc : (k * m) ^ 2 + (k * n) ^ 2 = k ^ 2 * (m ^ 2 + n ^ 2) := by ring
  rw [hc, show 2 * (k * m) * (k * n) = k ^ 2 * (2 * m * n) from by ring]
  exact mul_div_mul_left _ (m ^ 2 + n ^ 2) hk2

/-- The second component is also scale-invariant. -/
theorem stereo_scale_invariant_second (m n k : ℚ) (hk : k ≠ 0) (_h : m ^ 2 + n ^ 2 ≠ 0) :
    ((k * n) ^ 2 - (k * m) ^ 2) / ((k * m) ^ 2 + (k * n) ^ 2) =
    (n ^ 2 - m ^ 2) / (m ^ 2 + n ^ 2) := by
  have hk2 : k ^ 2 ≠ 0 := pow_ne_zero 2 hk
  have hc : (k * m) ^ 2 + (k * n) ^ 2 = k ^ 2 * (m ^ 2 + n ^ 2) := by ring
  rw [hc, show (k * n) ^ 2 - (k * m) ^ 2 = k ^ 2 * (n ^ 2 - m ^ 2) from by ring]
  exact mul_div_mul_left _ (m ^ 2 + n ^ 2) hk2

-- =====================================================================
-- SECTION 9: EULER'S FOUR-SQUARE IDENTITY
-- =====================================================================

/-- The complex product of two stereographically-projected points
remains on the unit circle. -/
theorem stereo_closure_under_multiplication (m₁ n₁ m₂ n₂ : ℤ)
    (h1 : (m₁ : ℚ) ^ 2 + (n₁ : ℚ) ^ 2 ≠ 0)
    (h2 : (m₂ : ℚ) ^ 2 + (n₂ : ℚ) ^ 2 ≠ 0) :
    let x₁ := 2 * (m₁ : ℚ) * n₁ / ((m₁ : ℚ) ^ 2 + (n₁ : ℚ) ^ 2)
    let y₁ := ((n₁ : ℚ) ^ 2 - (m₁ : ℚ) ^ 2) / ((m₁ : ℚ) ^ 2 + (n₁ : ℚ) ^ 2)
    let x₂ := 2 * (m₂ : ℚ) * n₂ / ((m₂ : ℚ) ^ 2 + (n₂ : ℚ) ^ 2)
    let y₂ := ((n₂ : ℚ) ^ 2 - (m₂ : ℚ) ^ 2) / ((m₂ : ℚ) ^ 2 + (n₂ : ℚ) ^ 2)
    (x₁ * x₂ - y₁ * y₂) ^ 2 + (x₁ * y₂ + y₁ * x₂) ^ 2 = 1 := by
  simp only
  field_simp
  ring

-- =====================================================================
-- SECTION 11: CALIBRATION POINTS
-- =====================================================================

/-- The stereographic map t ↦ 2t/(1+t²) maps 0 to 0. -/
theorem stereo_calibration_zero : (2 : ℚ) * 0 / (1 + 0 ^ 2) = 0 := by norm_num

/-- The stereographic map t ↦ 2t/(1+t²) maps 1 to 1. -/
theorem stereo_calibration_one : (2 : ℚ) * 1 / (1 + 1 ^ 2) = 1 := by norm_num

/-- The first component is an odd function. -/
theorem stereo_first_odd (t : ℚ) :
    2 * (-t) / (1 + (-t) ^ 2) = -(2 * t / (1 + t ^ 2)) := by ring

/-- The second component is an even function. -/
theorem stereo_second_even (t : ℚ) :
    (1 - (-t) ^ 2) / (1 + (-t) ^ 2) = (1 - t ^ 2) / (1 + t ^ 2) := by ring

-- =====================================================================
-- SECTION 12: ALTERNATIVE NORM PRODUCT
-- =====================================================================

/-- The product of norms equals the norm of the product (Gaussian integer view):
|z₁|²·|z₂|² = |z₁·z₂|² where z = a + bi. -/
theorem cayley_dickson_norm (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) =
    (a * c + b * d) ^ 2 + (a * d - b * c) ^ 2 := by
  ring

-- =====================================================================
-- SECTION 13: NETWORK DEPTH — UNIT NORM CHAIN
-- =====================================================================

/-- Composing two unit vectors via complex multiplication preserves unit norm.
This is the key lemma for network depth composition. -/
theorem unit_complex_mul_norm (a b c d : ℚ)
    (h1 : a ^ 2 + b ^ 2 = 1) (h2 : c ^ 2 + d ^ 2 = 1) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 = 1 := by
  nlinarith [sq_nonneg (a * c - b * d), sq_nonneg (a * d + b * c),
             sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]

-- =====================================================================
-- SECTION 14: PROJECTION CROSS-RATIO
-- =====================================================================

/-- If two parameter pairs produce the same first projected component,
the cross-ratio condition holds. -/
theorem stereo_cross_ratio (m₁ n₁ m₂ n₂ : ℚ)
    (h1 : m₁ ^ 2 + n₁ ^ 2 ≠ 0) (h2 : m₂ ^ 2 + n₂ ^ 2 ≠ 0)
    (hx : 2 * m₁ * n₁ / (m₁ ^ 2 + n₁ ^ 2) = 2 * m₂ * n₂ / (m₂ ^ 2 + n₂ ^ 2)) :
    m₁ * n₁ * (m₂ ^ 2 + n₂ ^ 2) = m₂ * n₂ * (m₁ ^ 2 + n₁ ^ 2) := by
  field_simp at hx
  linarith

-- =====================================================================
-- SECTION 15: FINSET SUM NUMERATOR IDENTITY
-- =====================================================================

/-- The N-dimensional projection numerator identity using Finset.sum.
This is the type-safe version of `projection_numerator_eq_sq`. -/
theorem projection_numerator_fin (n : ℕ) (t : ℤ) (m : Fin n → ℤ) :
    (∑ i : Fin n, (2 * m i * t) ^ 2) + (t ^ 2 - ∑ i : Fin n, (m i) ^ 2) ^ 2 =
    (t ^ 2 + ∑ i : Fin n, (m i) ^ 2) ^ 2 := by
  have key : ∑ i : Fin n, (2 * m i * t) ^ 2 =
      4 * t ^ 2 * ∑ i : Fin n, (m i) ^ 2 := by
    simp only [mul_pow]
    rw [Finset.mul_sum]
    congr 1; ext i; ring
  linarith [generalized_pythagorean_identity t (∑ i : Fin n, (m i) ^ 2)]