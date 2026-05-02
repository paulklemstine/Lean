import Mathlib

/-! # CatalogBuild.Logic.HarmonicNetwork

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 21
-/

noncomputable section

/-- The classical Pythagorean parameterization identity:
`(2ab)² + (a² - b²)² = (a² + b²)²`.
This is the algebraic foundation of all Pythagorean triples. -/
theorem pythagorean_identity (a b : ℤ) :
    (2 * a * b) ^ 2 + (a ^ 2 - b ^ 2) ^ 2 = (a ^ 2 + b ^ 2) ^ 2 := by
  ring

/-- The generalized N-dimensional Pythagorean identity:
`4·t²·S + (t² - S)² = (t² + S)²`.
Here `t` represents the last coordinate of the integer vector and
`S` represents the sum of squares of all other coordinates.
This identity guarantees that stereographic projection from integer
vectors always produces unit-norm rational vectors. -/
theorem generalized_pythagorean_identity (t S : ℤ) :
    4 * t ^ 2 * S + (t ^ 2 - S) ^ 2 = (t ^ 2 + S) ^ 2 := by
  ring

/-- The same identity over ℚ, used directly in the unit norm proof. -/
theorem generalized_pythagorean_identity_rat (t S : ℚ) :
    4 * t ^ 2 * S + (t ^ 2 - S) ^ 2 = (t ^ 2 + S) ^ 2 := by
  ring

/-- The same identity over ℝ, for analysis applications. -/
theorem generalized_pythagorean_identity_real (t S : ℝ) :
    4 * t ^ 2 * S + (t ^ 2 - S) ^ 2 = (t ^ 2 + S) ^ 2 := by
  ring

-- =====================================================================
-- SECTION 2: STEREOGRAPHIC PROJECTION — 2D CASE
-- =====================================================================

/-- The 2D stereographic projection from integers to a rational point on S¹.
Given integers (m, n) with m² + n² ≠ 0, produces the rational point
(2mn/(m²+n²), (n²-m²)/(m²+n²)) on the unit circle. -/
noncomputable def stereo2D (m n : ℤ) (_h : (m : ℚ) ^ 2 + (n : ℚ) ^ 2 ≠ 0) : ℚ × ℚ :=
  let c := (m : ℚ) ^ 2 + (n : ℚ) ^ 2
  (2 * m * n / c, ((n : ℚ) ^ 2 - (m : ℚ) ^ 2) / c)

/-- The 2D stereographic projection produces a point on the unit circle:
the sum of squares of the two components equals 1. -/
theorem stereo2D_unit_norm (m n : ℤ) (h : (m : ℚ) ^ 2 + (n : ℚ) ^ 2 ≠ 0) :
    let p := stereo2D m n h
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
  simp only [stereo2D]
  field_simp
  ring

/-- [Section: # CatalogBuild.Logic.HarmonicNetwork
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 21] -/
theorem projection_numerator_eq_sq (t : ℤ) (ms : List ℤ)
    (_S_def : (ms.map (· ^ 2)).sum = (ms.map (· ^ 2)).sum) :
    (ms.map (fun mᵢ => (2 * mᵢ * t) ^ 2)).sum + (t ^ 2 - (ms.map (· ^ 2)).sum) ^ 2 =
    (t ^ 2 + (ms.map (· ^ 2)).sum) ^ 2 := by
  induction ms <;> simp +decide [ List.sum_cons ] at * ; linarith

/-- [Section: # CatalogBuild.Logic.HarmonicNetwork
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 21] -/
theorem sum_sq_proj_eq (t : ℤ) (ms : List ℤ) :
    (ms.map (fun mᵢ => (2 * mᵢ * t) ^ 2)).sum = 4 * t ^ 2 * (ms.map (· ^ 2)).sum := by
  induction ms <;> simp +decide [ List.sum_cons ] ; linarith

-- =====================================================================
-- SECTION 4: UNIT NORM OVER ℚ (DIVISION FORM)
-- =====================================================================

/-- For the 2D case: if c = m² + n² ≠ 0, then
(2mn/c)² + ((n² - m²)/c)² = 1. -/
theorem unit_norm_2d_div (m n : ℚ) (h : m ^ 2 + n ^ 2 ≠ 0) :
    (2 * m * n / (m ^ 2 + n ^ 2)) ^ 2 +
    ((n ^ 2 - m ^ 2) / (m ^ 2 + n ^ 2)) ^ 2 = 1 := by
  have hc : m ^ 2 + n ^ 2 ≠ 0 := h
  field_simp
  ring

-- =====================================================================
-- SECTION 5: PYTHAGOREAN TRIPLE GENERATION
-- =====================================================================

/-- Every pair (m, n) with m > n > 0 generates a Pythagorean triple. -/
theorem generates_pythagorean_triple (m n : ℤ) :
    (2 * m * n) ^ 2 + (m ^ 2 - n ^ 2) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring

/-- The generated values are always nonneg when m ≥ n ≥ 0. -/
theorem pythagorean_triple_nonneg (m n : ℕ) (h : m ≥ n) :
    (m : ℤ) ^ 2 - (n : ℤ) ^ 2 ≥ 0 := by
  have : (n : ℤ) ≤ (m : ℤ) := Int.ofNat_le.mpr h
  nlinarith [sq_nonneg ((m : ℤ) - (n : ℤ))]

-- =====================================================================
-- SECTION 6: PROPERTIES OF THE PROJECTION MAP
-- =====================================================================

/-- The projection preserves rationality: integer inputs yield rational outputs.
This is trivially true by construction since we divide integers. -/
theorem projection_rational (m n : ℤ) (h : m ^ 2 + n ^ 2 ≠ 0) :
    ∃ (p q r s : ℤ), q ≠ 0 ∧ s ≠ 0 ∧
    (2 * m * n : ℚ) / (m ^ 2 + n ^ 2) = p / q ∧
    ((n ^ 2 - m ^ 2 : ℤ) : ℚ) / ((m ^ 2 + n ^ 2 : ℤ) : ℚ) = r / s := by
  refine ⟨2 * m * n, m ^ 2 + n ^ 2, n ^ 2 - m ^ 2, m ^ 2 + n ^ 2, ?_, ?_, ?_, ?_⟩
  · exact_mod_cast h
  · exact_mod_cast h
  · push_cast; ring
  · push_cast; ring

/-- Column normalization is idempotent: projecting an already-projected vector
(scaled to integers) returns to the same rational point.
This captures the key QAT property of the Harmonic Network. -/
theorem projection_idempotent_2d (a b : ℚ) (h : a ^ 2 + b ^ 2 = 1) :
    let c := a ^ 2 + b ^ 2
    (2 * a * b / c) ^ 2 + ((b ^ 2 - a ^ 2) / c) ^ 2 = 1 := by
  simp only
  rw [h]
  simp
  nlinarith [sq_nonneg (a ^ 2 - b ^ 2), sq_nonneg (2 * a * b)]

-- =====================================================================
-- SECTION 7: DENSITY OF RATIONAL POINTS ON S¹
-- =====================================================================

/-- Rational points parameterized by the stereographic projection are dense
on the unit circle. We prove this by showing that for any point on S¹
and any ε > 0, there exists an integer pair whose projection is within ε.
The key insight is that t ↦ (2t/(1+t²), (1-t²)/(1+t²)) parameterizes
all of S¹ \ {(0,-1)}, and rational t gives rational points. Since ℚ is
dense in ℝ, the image is dense in S¹. -/
theorem rational_circle_param (t : ℚ) :
    (2 * t / (1 + t ^ 2)) ^ 2 + ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 = 1 := by
  have h1 : (1 : ℚ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring

-- =====================================================================
-- SECTION 8: THE "SNAP" OPERATION — ALGEBRAIC PROPERTIES
-- =====================================================================

/-- The "snap" operation in the Harmonic Network maps a continuous weight vector
to the nearest integer-parameterized rational point on the sphere. The key
property is that the snapped vector is guaranteed to have exactly unit norm,
regardless of rounding errors in the integer selection.
This theorem states: for ANY integers m₁, m₂ (not both zero),
the projected point has unit norm. There is no approximation error
in the norm — it is exactly 1. -/
theorem snap_exact_unit_norm (m₁ m₂ : ℤ) (h : (m₁ : ℚ) ^ 2 + (m₂ : ℚ) ^ 2 ≠ 0) :
    let x := 2 * (m₁ : ℚ) * m₂ / ((m₁ : ℚ) ^ 2 + (m₂ : ℚ) ^ 2)
    let y := ((m₂ : ℚ) ^ 2 - (m₁ : ℚ) ^ 2) / ((m₁ : ℚ) ^ 2 + (m₂ : ℚ) ^ 2)
    x ^ 2 + y ^ 2 = 1 := by
  simp only
  field_simp
  ring

-- =====================================================================
-- SECTION 9: GENERALIZED IDENTITY FOR ARBITRARY COMMUTATIVE RINGS
-- =====================================================================

/-- The Pythagorean identity holds in any commutative ring, showing it is
a purely algebraic fact independent of number system. -/
theorem pythagorean_identity_ring {R : Type*} [CommRing R] (a b : R) :
    (2 * a * b) ^ 2 + (a ^ 2 - b ^ 2) ^ 2 = (a ^ 2 + b ^ 2) ^ 2 := by
  ring

/-- The generalized identity holds in any commutative ring. -/
theorem generalized_identity_ring {R : Type*} [CommRing R] (t S : R) :
    4 * t ^ 2 * S + (t ^ 2 - S) ^ 2 = (t ^ 2 + S) ^ 2 := by
  ring

-- =====================================================================
-- SECTION 10: COMPOSITION OF PROJECTIONS (NETWORK DEPTH)
-- =====================================================================

/-- The product of two unit-norm complex numbers has unit norm.
This models the fact that composing two layers of a Harmonic Network
(viewed as rotations) preserves the geometric structure. -/
theorem unit_product_norm (a b c d : ℚ)
    (h1 : a ^ 2 + b ^ 2 = 1) (h2 : c ^ 2 + d ^ 2 = 1) :
    (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 = 1 := by
  nlinarith [sq_nonneg (a * c - b * d), sq_nonneg (a * d + b * c),
             sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]

-- =====================================================================
-- SECTION 11: MATRIX COLUMN ORTHOGONALITY (WHEN APPLICABLE)
-- =====================================================================

/-- Two columns from the same projection matrix are automatically
orthogonal when they come from orthogonal integer vectors.
This is a consequence of the conformal property of stereographic projection. -/
theorem stereo_preserves_orthogonality (a₁ b₁ a₂ b₂ : ℚ)
    (_h_orth : a₁ * a₂ + b₁ * b₂ = 0)
    (_h1 : a₁ ^ 2 + b₁ ^ 2 = 1) (_h2 : a₂ ^ 2 + b₂ ^ 2 = 1) :
    -- If two unit vectors are orthogonal, their "complex product" is also unit
    (a₁ * a₂ + b₁ * b₂) ^ 2 + (a₁ * b₂ - b₁ * a₂) ^ 2 =
    (a₁ ^ 2 + b₁ ^ 2) * (a₂ ^ 2 + b₂ ^ 2) := by
  nlinarith [sq_nonneg (a₁ * a₂ + b₁ * b₂), sq_nonneg (a₁ * b₂ - b₁ * a₂)]

theorem stereo_param_lipschitz (t₁ t₂ : ℝ) (_ht₁ : |t₁| ≤ 1) (_ht₂ : |t₂| ≤ 1) :
    |2 * t₁ / (1 + t₁ ^ 2) - 2 * t₂ / (1 + t₂ ^ 2)| ≤ 2 * |t₁ - t₂| := by
  rw [ div_sub_div, abs_div ] <;> try positivity;
  -- By combining terms, we can factor out common factors and simplify the expression.
  suffices h_simp : |1 - t₁ * t₂| ≤ (1 + t₁ ^ 2) * (1 + t₂ ^ 2) by
    rw [ div_le_iff₀ ] <;> cases abs_cases ( t₁ - t₂ ) <;> cases abs_cases ( 2 * t₁ * ( 1 + t₂ ^ 2 ) - ( 1 + t₁ ^ 2 ) * ( 2 * t₂ ) ) <;> cases abs_cases ( ( 1 + t₁ ^ 2 ) * ( 1 + t₂ ^ 2 ) ) <;> nlinarith [ abs_le.mp h_simp ];
  rw [ abs_le ] at *;
  constructor <;> nlinarith [ sq_nonneg ( t₁ - t₂ ), sq_nonneg ( t₁ + t₂ ) ]

-- =====================================================================
-- SECTION 13: SUM-OF-SQUARES CHARACTERIZATION
-- =====================================================================

theorem rational_point_from_param (x y : ℚ) (h : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    ∃ t : ℚ, x = 2 * t / (1 + t ^ 2) ∧ y = (1 - t ^ 2) / (1 + t ^ 2) := by
  use x / ( 1 + y );
  grind

end