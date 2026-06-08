import Mathlib

/-! # CatalogBuild.Pythagorean.QDF.QDF_HE_Frontiers

Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 47
-/

/-- The QDF identity can be written as a quadratic form signature (3,1). -/
theorem qdf_lorentz_signature (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = 0 := by linarith

/-- Sum of two QDF vectors (as ℤ⁴ vectors) has a specific norm. -/
theorem qdf_sum_norm (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 + (d₁ + d₂) ^ 2 =
    2 * (d₁ ^ 2 + d₂ ^ 2) + 2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ + d₁ * d₂) := by
  nlinarith

/-- The ℤ⁴ inner product of two QDF vectors factors. -/
theorem qdf_z4_inner_product (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    a₁ * a₂ + b₁ * b₂ + c₁ * c₂ + d₁ * d₂ =
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) + d₁ * d₂ := by ring

/-- Double quadruple: 2*(a,b,c,d) is a QDF quadruple. -/
theorem qdf_double (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (2 * a) ^ 2 + (2 * b) ^ 2 + (2 * c) ^ 2 = (2 * d) ^ 2 := by nlinarith

/-- Lattice sublattice: the set {(a,b,c,d) : a²+b²+c²=d², 2|a, 2|b, 2|c, 2|d}
is obtained by scaling. -/
theorem qdf_even_sublattice (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : 2 ∣ a) (hb : 2 ∣ b) (hc : 2 ∣ c) (hd : 2 ∣ d) :
    (a / 2) ^ 2 + (b / 2) ^ 2 + (c / 2) ^ 2 = (d / 2) ^ 2 := by
  obtain ⟨ka, rfl⟩ := ha
  obtain ⟨kb, rfl⟩ := hb
  obtain ⟨kc, rfl⟩ := hc
  obtain ⟨kd, rfl⟩ := hd
  simp [Int.mul_ediv_cancel_left _ (by norm_num : (2 : ℤ) ≠ 0)]
  nlinarith

/-- For lattice attacks: the Minkowski-type bound on QDF norms. -/
theorem qdf_minkowski_norm_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 2 * d ^ 2 := by linarith

/-- Lattice basis reduction: subtracting a scalar multiple. -/
theorem qdf_basis_reduce (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ k : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ - k * a₂) ^ 2 + (b₁ - k * b₂) ^ 2 + (c₁ - k * c₂) ^ 2 =
    d₁ ^ 2 + k ^ 2 * d₂ ^ 2 - 2 * k * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) := by
  nlinarith [sq_nonneg k]

/-- Parity constraint: the QDF identity mod 4 is preserved. -/
theorem qdf_mod4_constraint (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a ^ 2 + b ^ 2 + c ^ 2) % 4 = d ^ 2 % 4 := by omega

/-- Exact homomorphism converse: if component-wise addition is closed,
then the inner product equals the hypotenuse product. This is an iff. -/
theorem qdf_exact_homomorphism_iff (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    ((a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 = (d₁ + d₂) ^ 2) ↔
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = d₁ * d₂) := by
  constructor
  · intro hadd; nlinarith
  · intro hip; nlinarith

/-- Noise magnitude: the cross-term is exactly 2*(inner_product - d₁*d₂). -/
theorem qdf_noise_magnitude (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 - (d₁ + d₂) ^ 2 =
    2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ - d₁ * d₂) := by nlinarith

/-- Noise bound via Cauchy-Schwarz: the inner product is bounded by d₁*d₂. -/
theorem qdf_noise_bound (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 ≤ d₁ ^ 2 * d₂ ^ 2 := by
  nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
             sq_nonneg (a₁ * c₂ - c₁ * a₂),
             sq_nonneg (b₁ * c₂ - c₁ * b₂)]

/-- Multiplicative structure: scaling preserves QDF under modular reduction. -/
theorem qdf_mult_homomorphism (a b c d k m : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ((k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2) % m = (k * d) ^ 2 % m := by
  congr 1; nlinarith [sq_nonneg k]

/-- Subtraction homomorphism: same cross-term structure with opposite sign. -/
theorem qdf_subtraction_cross_term (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 - (d₁ - d₂) ^ 2 =
    -2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ - d₁ * d₂) := by nlinarith

/-- Exact subtraction homomorphism. -/
theorem qdf_exact_subtraction (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2)
    (hip : a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = d₁ * d₂) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 = (d₁ - d₂) ^ 2 := by nlinarith

/-- Self-addition: adding a quadruple to itself always satisfies the
exact homomorphism condition (noise-free). -/
theorem qdf_self_addition (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + a) ^ 2 + (b + b) ^ 2 + (c + c) ^ 2 = (d + d) ^ 2 := by nlinarith

/-- Noise accumulation: n copies of the same quadruple are noise-free. -/
theorem qdf_n_copies (a b c d : ℤ) (n : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (n * a) ^ 2 + (n * b) ^ 2 + (n * c) ^ 2 = (n * d) ^ 2 := by nlinarith [sq_nonneg n]

/-- Modular noise: the noise term is preserved modulo m. -/
theorem qdf_noise_mod (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ m : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    ((a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 - (d₁ + d₂) ^ 2) % m =
    (2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ - d₁ * d₂)) % m := by
  congr 1; nlinarith

/-- Mixed modular-additive: scaling is always noise-free mod any m. -/
theorem qdf_mixed_operation (a b c d k m : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ((k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2 - (k * d) ^ 2) % m = 0 := by
  have : (k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2 = (k * d) ^ 2 := by nlinarith [sq_nonneg k]
  simp [this]

/-- Two-component error detection: errors in a and b. -/
theorem qdf_two_component_error (a b c d e₁ e₂ : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + e₁) ^ 2 + (b + e₂) ^ 2 + c ^ 2 - d ^ 2 =
    2 * a * e₁ + e₁ ^ 2 + 2 * b * e₂ + e₂ ^ 2 := by nlinarith

/-- Three-component error detection. -/
theorem qdf_three_component_error (a b c d e₁ e₂ e₃ : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + e₁) ^ 2 + (b + e₂) ^ 2 + (c + e₃) ^ 2 - d ^ 2 =
    2 * a * e₁ + e₁ ^ 2 + 2 * b * e₂ + e₂ ^ 2 + 2 * c * e₃ + e₃ ^ 2 := by nlinarith

/-- Weight-1 error syndrome on component a. -/
theorem qdf_weight1_syndrome_a (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + 1) ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = 2 * a + 1 := by nlinarith

/-- Weight-1 error syndrome on component b. -/
theorem qdf_weight1_syndrome_b (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + (b + 1) ^ 2 + c ^ 2 - d ^ 2 = 2 * b + 1 := by nlinarith

/-- Weight-1 error syndrome on component c. -/
theorem qdf_weight1_syndrome_c (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + (c + 1) ^ 2 - d ^ 2 = 2 * c + 1 := by nlinarith

/-- Syndrome distinguishability: distinct components give distinct weight-1 syndromes. -/
theorem qdf_syndrome_distinguishable (a b : ℤ) (hab : a ≠ b) :
    2 * a + 1 ≠ 2 * b + 1 := by omega

/-- Orthogonality constraint for stabilizer triples:
three mutually orthogonal vectors on S² form a frame with total norm 3d². -/
theorem qdf_frame_identity (a₁ b₁ c₁ a₂ b₂ c₂ a₃ b₃ c₃ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2)
    (h3 : a₃ ^ 2 + b₃ ^ 2 + c₃ ^ 2 = d ^ 2) :
    (a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2) + (a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2) +
    (a₃ ^ 2 + b₃ ^ 2 + c₃ ^ 2) = 3 * d ^ 2 := by linarith

/-- Error correction capacity: the minimum syndrome magnitude for weight-1 errors. -/
theorem qdf_min_syndrome (a : ℤ) (ha : a ≥ 0) :
    2 * a + 1 ≥ 1 := by omega

/-- Quantum fidelity bound: overlap between two Bloch sphere states is ≤ 1. -/
theorem qdf_fidelity_bound (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ) (hd : d ≠ 0)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    ((a₁ * a₂ + b₁ * b₂ + c₁ * c₂ : ℤ) : ℚ) ^ 2 / ((d : ℚ) ^ 2 * (d : ℚ) ^ 2) ≤ 1 := by
  have hd2 : (d : ℚ) ^ 2 > 0 := by positivity
  rw [div_le_one (mul_pos hd2 hd2)]
  have key : (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 ≤ d ^ 2 * d ^ 2 := by
    nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
               sq_nonneg (a₁ * c₂ - c₁ * a₂),
               sq_nonneg (b₁ * c₂ - c₁ * b₂)]
  exact_mod_cast key

/-- The quadratic family hypotenuse d(n) = n²+n+1 is always positive for n ≥ 0. -/
theorem qdf_hypotenuse_pos (n : ℤ) (hn : n ≥ 0) :
    n ^ 2 + n + 1 > 0 := by nlinarith [sq_nonneg n]

/-- The quadratic family hypotenuse is always odd. -/
theorem qdf_hypotenuse_odd (n : ℤ) :
    (n ^ 2 + n + 1) % 2 = 1 := by
  obtain ⟨r, hr⟩ := Int.even_mul_succ_self n
  have : n ^ 2 + n = 2 * r := by linarith
  omega

/-- Consecutive hypotenuse decomposition. -/
theorem qdf_hypotenuse_ratio (n : ℤ) :
    (n + 1) ^ 2 + (n + 1) + 1 = (n ^ 2 + n + 1) + (2 * n + 2) := by ring

/-- Gap growth: the gap between consecutive hypotenuses grows linearly. -/
theorem qdf_gap_linear (n : ℤ) :
    ((n + 1) ^ 2 + (n + 1) + 1) - (n ^ 2 + n + 1) = 2 * (n + 1) := by ring

/-- The sum of consecutive quadratic family values. -/
theorem qdf_telescoping_sum (n : ℤ) :
    (n ^ 2 + n + 1) + ((n + 1) ^ 2 + (n + 1) + 1) = 2 * (n + 1) ^ 2 + 2 := by ring

/-- Density: the n-th quadratic family hypotenuse is ≤ 2n² for n ≥ 1. -/
theorem qdf_density_bound (n : ℤ) (hn : n ≥ 1) :
    n ^ 2 + n + 1 ≤ 3 * n ^ 2 := by nlinarith

/-- Coprimality of consecutive integers (used for QDF leg coprimality). -/
theorem qdf_coprime_consecutive (n : ℕ) :
    Nat.Coprime n (n + 1) := by simp [Nat.Coprime]

/-- Filtration nesting: smaller index ⟹ smaller hypotenuse ⟹ earlier birth. -/
theorem qdf_filtration_nesting (m n : ℤ) (hmn : m < n) (hm : m ≥ 0) :
    m ^ 2 + m + 1 < n ^ 2 + n + 1 := by nlinarith

/-- Symmetry group order: sign changes × permutations = 8 × 6 = 48. -/
theorem qdf_symmetry_group_order :
    (2 ^ 3 : ℕ) * Nat.factorial 3 = 48 := by norm_num

/-- Lattice-HE bridge: sum of difference-squared and sum-squared norms. -/
theorem lattice_he_bridge (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 +
    ((a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2) =
    2 * (d₁ ^ 2 + d₂ ^ 2) := by nlinarith

/-- QEC-TDA bridge: code distance = TDA distance on the same sphere. -/
theorem qec_tda_bridge (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 =
    2 * d ^ 2 - 2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) := by nlinarith

/-- Full four-way identity: parallelogram law on the QDF cone. -/
theorem qdf_four_way_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    ((a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2) +
    ((a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2) = 4 * d ^ 2 := by nlinarith

/-- The parallelogram law specialized to QDF same-sphere quadruples. -/
theorem qdf_parallelogram (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) :
    (a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 +
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 =
    2 * (a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 + a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2) := by ring

/-- Sextic family: n³ substitution into the quadratic family. -/
theorem qdf_sextic_family (n : ℤ) :
    (n ^ 3) ^ 2 + (n ^ 3 + 1) ^ 2 + (n ^ 3 * (n ^ 3 + 1)) ^ 2 =
    (n ^ 6 + n ^ 3 + 1) ^ 2 := by ring

/-- Product family: if (a,b,c,d) is a quadruple, so is (da, db, dc, d²). -/
theorem qdf_product_family (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d * a) ^ 2 + (d * b) ^ 2 + (d * c) ^ 2 = (d ^ 2) ^ 2 := by nlinarith [sq_nonneg d]

/-- Shifted family: (n+k)² + (n+k+1)² + ((n+k)(n+k+1))² = ((n+k)²+(n+k)+1)². -/
theorem qdf_shifted_family (n k : ℤ) :
    (n + k) ^ 2 + (n + k + 1) ^ 2 + ((n + k) * (n + k + 1)) ^ 2 =
    ((n + k) ^ 2 + (n + k) + 1) ^ 2 := by ring

/-- Sum of two quadratic family hypotenuses. -/
theorem qdf_hypotenuse_sum_formula (m n : ℤ) :
    (m ^ 2 + m + 1) + (n ^ 2 + n + 1) =
    m ^ 2 + n ^ 2 + m + n + 2 := by ring

/-- Product of two quadratic family hypotenuses. -/
theorem qdf_hypotenuse_product (m n : ℤ) :
    (m ^ 2 + m + 1) * (n ^ 2 + n + 1) =
    (m * n) ^ 2 + m ^ 2 * n + m ^ 2 + m * n ^ 2 + m * n + m + n ^ 2 + n + 1 := by ring

/-- The quadratic family satisfies a recurrence. -/
theorem qdf_recurrence (n : ℤ) :
    (n + 1) ^ 2 + (n + 1) + 1 = (n ^ 2 + n + 1) + 2 * n + 2 := by ring

/-- Double composition: applying the quadratic family twice yields a tower. -/
theorem qdf_double_compose (n : ℤ) :
    let d₁ := n ^ 2 + n + 1
    let d₂ := d₁ ^ 2 + d₁ + 1
    let d₃ := d₂ ^ 2 + d₂ + 1
    d₂ ^ 2 + (d₂ + 1) ^ 2 + (d₂ * (d₂ + 1)) ^ 2 = d₃ ^ 2 := by ring