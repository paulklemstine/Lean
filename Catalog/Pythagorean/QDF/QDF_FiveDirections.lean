/-! # CatalogBuild.Pythagorean.QDF.QDF_FiveDirections

Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 46
-/

import Mathlib

/-- QDF quadruples are closed under scaling: the solution set forms a cone. -/
theorem qdf_lattice_scaling (a b c d k : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2 = (k * d) ^ 2 := by
  nlinarith [sq_nonneg k]




/-- Lattice point count bound: each component is bounded by the hypotenuse. -/
theorem lattice_component_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 ≤ d ^ 2 ∧ b ^ 2 ≤ d ^ 2 ∧ c ^ 2 ≤ d ^ 2 := by
  exact ⟨by nlinarith [sq_nonneg b, sq_nonneg c],
         by nlinarith [sq_nonneg a, sq_nonneg c],
         by nlinarith [sq_nonneg a, sq_nonneg b]⟩




/-- Gap identity: the QDF constraint means d²-(a²+b²+c²) = 0 exactly. -/
theorem lattice_shortest_vector_gap (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    d ^ 2 - (a ^ 2 + b ^ 2 + c ^ 2) = 0 := by omega




/-- Gram matrix diagonal: the ℤ⁴-norm of (a,b,c,d) is 2d². -/
theorem qdf_gram_diagonal (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 2 * d ^ 2 := by linarith




/-- Inner product bound (Cauchy–Schwarz for QDF vectors). -/
theorem qdf_lattice_inner_bound (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 ≤ d₁ ^ 2 * d₂ ^ 2 := by
  nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
             sq_nonneg (a₁ * c₂ - c₁ * a₂),
             sq_nonneg (b₁ * c₂ - c₁ * b₂)]




/-- Lattice reduction: difference of two QDF vectors. -/
theorem qdf_lattice_reduction (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 =
    d₁ ^ 2 + d₂ ^ 2 - 2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) := by nlinarith




/-- GCD reduction: a common factor can be divided out. -/
theorem qdf_primitive_reduction (a b c d g : ℤ) (hg : g ≠ 0)
    (ha : g ∣ a) (hb : g ∣ b) (hc : g ∣ c) (hd : g ∣ d)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a / g) ^ 2 + (b / g) ^ 2 + (c / g) ^ 2 = (d / g) ^ 2 := by
  obtain ⟨ka, rfl⟩ := ha
  obtain ⟨kb, rfl⟩ := hb
  obtain ⟨kc, rfl⟩ := hc
  obtain ⟨kd, rfl⟩ := hd
  simp [Int.mul_ediv_cancel_left _ hg]
  have hg2 : g ^ 2 ≠ 0 := pow_ne_zero _ hg
  have : (g * ka) ^ 2 + (g * kb) ^ 2 + (g * kc) ^ 2 = (g * kd) ^ 2 := h
  have : g ^ 2 * (ka ^ 2 + kb ^ 2 + kc ^ 2) = g ^ 2 * kd ^ 2 := by nlinarith
  exact mul_left_cancel₀ hg2 this




/-- Quadratic family gap: consecutive hypotenuses differ by 2n+2. -/
theorem qdf_family_gap (n : ℤ) :
    (n + 1) ^ 2 + (n + 1) + 1 - (n ^ 2 + n + 1) = 2 * n + 2 := by ring




/-- Quadratic family: n² + (n+1)² + (n(n+1))² = (n²+n+1)². -/
theorem qdf_family_density (n : ℤ) :
    n ^ 2 + (n + 1) ^ 2 + (n * (n + 1)) ^ 2 = (n ^ 2 + n + 1) ^ 2 := by ring




/-- QDF identity holds modulo any m. -/
theorem qdf_mod_preservation (a b c d m : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a ^ 2 + b ^ 2 + c ^ 2) % m = d ^ 2 % m := by
  congr 1




/-- Modular radical decomposition is preserved. -/
theorem qdf_mod_radical (a b c d m : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ((d - c) * (d + c)) % m = (a ^ 2 + b ^ 2) % m := by
  congr 1; nlinarith




/-- p-cascade: shared factors amplify quadratically. -/
theorem qdf_factoring_channel_mod (a b c d p : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hp : p ∣ d) (hpc : p ∣ c) :
    p ^ 2 ∣ (a ^ 2 + b ^ 2) := by
  obtain ⟨kd, rfl⟩ := hp
  obtain ⟨kc, rfl⟩ := hpc
  exact ⟨kd ^ 2 - kc ^ 2, by linarith⟩




/-- Homomorphic scaling modulo m. -/
theorem qdf_homomorphic_scaling (a b c d k m : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    ((k * a) ^ 2 + (k * b) ^ 2 + (k * c) ^ 2) % m = ((k * d) ^ 2) % m := by
  congr 1; nlinarith [sq_nonneg k]




/-- Additive cross-term: the error when adding two quadruples component-wise. -/
theorem qdf_additive_cross_term (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 - (d₁ + d₂) ^ 2 =
    2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂ - d₁ * d₂) := by nlinarith




/-- Exact homomorphism: when inner product equals hypotenuse product,
component-wise addition is closed. -/
theorem qdf_exact_homomorphism (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2)
    (hip : a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = d₁ * d₂) :
    (a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 = (d₁ + d₂) ^ 2 := by nlinarith




/-- CRT compatibility. -/
theorem qdf_crt_compatible (a b c d m₁ m₂ : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a ^ 2 + b ^ 2 + c ^ 2) % (m₁ * m₂) = d ^ 2 % (m₁ * m₂) := by
  congr 1




/-- Rational Bloch sphere point from a Pythagorean quadruple. -/
theorem qdf_bloch_sphere (a b c d : ℤ) (hd : d ≠ 0)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a : ℚ) ^ 2 / d ^ 2 + (b : ℚ) ^ 2 / d ^ 2 + (c : ℚ) ^ 2 / d ^ 2 = 1 := by
  have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
  field_simp; exact_mod_cast h




/-- Orthogonal states on the rational Bloch sphere. -/
theorem qdf_orthogonal_states (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2)
    (hd1 : d₁ ≠ 0) (hd2 : d₂ ≠ 0)
    (horth : a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = 0) :
    ((a₁ : ℚ) * a₂ + b₁ * b₂ + c₁ * c₂) / (d₁ * d₂) = 0 := by
  simp [show (a₁ : ℚ) * a₂ + b₁ * b₂ + c₁ * c₂ = 0 from by exact_mod_cast horth]




/-- Syndrome parity: QDF preserves mod-2 structure. -/
theorem qdf_syndrome_parity (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a ^ 2 + b ^ 2 + c ^ 2) % 2 = d ^ 2 % 2 := by omega




/-- Error detection: a single-component error reveals its magnitude. -/
theorem qdf_error_detection (a b c d e : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + e) ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = 2 * a * e + e ^ 2 := by nlinarith




/-- Error syndrome: the residual factors as e(2a+e). -/
theorem qdf_error_syndrome (a b c d e : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a + e) ^ 2 + b ^ 2 + c ^ 2 - d ^ 2 = e * (2 * a + e) := by nlinarith




/-- Stabilizer triple: three mutually orthogonal quadruples have zero pairwise products. -/
theorem qdf_stabilizer_triple (a₁ b₁ c₁ a₂ b₂ c₂ a₃ b₃ c₃ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2)
    (h3 : a₃ ^ 2 + b₃ ^ 2 + c₃ ^ 2 = d ^ 2)
    (h12 : a₁ * a₂ + b₁ * b₂ + c₁ * c₂ = 0)
    (h13 : a₁ * a₃ + b₁ * b₃ + c₁ * c₃ = 0)
    (h23 : a₂ * a₃ + b₂ * b₃ + c₂ * c₃ = 0) :
    (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 +
    (a₁ * a₃ + b₁ * b₃ + c₁ * c₃) ^ 2 +
    (a₂ * a₃ + b₂ * b₃ + c₂ * c₃) ^ 2 = 0 := by
  rw [h12, h13, h23]; ring




/-- Dual code distance: for same-hypotenuse quadruples. -/
theorem qdf_dual_code_distance (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 =
    2 * (d ^ 2 - (a₁ * a₂ + b₁ * b₂ + c₁ * c₂)) := by nlinarith




/-- Distance squared between two quadruples on the same sphere. -/
theorem qdf_distance_sq (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 =
    2 * d ^ 2 - 2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) := by nlinarith




/-- Maximum distance: dist² ≤ 4d². -/
theorem qdf_max_distance (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 ≤ 4 * d ^ 2 := by
  nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
             sq_nonneg (a₁ * c₂ - c₁ * a₂),
             sq_nonneg (b₁ * c₂ - c₁ * b₂)]




/-- Filtration bound: hypotenuse ≥ 1 for n ≥ 0 in the quadratic family. -/
theorem qdf_filtration_bound (n : ℤ) (hn : n ≥ 0) :
    n ^ 2 + n + 1 ≥ 1 := by nlinarith [sq_nonneg n]




/-- Antipodal symmetry preserves the quadruple identity. -/
theorem qdf_antipodal (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (-a) ^ 2 + (-b) ^ 2 + (-c) ^ 2 = d ^ 2 := by linarith




/-- Sign symmetry: each component can be independently negated. -/
theorem qdf_sign_symmetry (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (-a) ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ∧
    a ^ 2 + (-b) ^ 2 + c ^ 2 = d ^ 2 ∧
    a ^ 2 + b ^ 2 + (-c) ^ 2 = d ^ 2 := by
  exact ⟨by nlinarith, by nlinarith, by nlinarith⟩




/-- Permutation symmetry. -/
theorem qdf_perm_symmetry (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    b ^ 2 + a ^ 2 + c ^ 2 = d ^ 2 ∧
    a ^ 2 + c ^ 2 + b ^ 2 = d ^ 2 ∧
    c ^ 2 + b ^ 2 + a ^ 2 = d ^ 2 := by
  exact ⟨by linarith, by linarith, by linarith⟩




/-- Birth time monotonicity: larger n gives larger hypotenuse. -/
theorem qdf_birth_time_monotone (n : ℤ) (hn : n ≥ 0) :
    (n + 1) ^ 2 + (n + 1) + 1 > n ^ 2 + n + 1 := by nlinarith




/-- Neighborhood: distance formula for consecutive family members. -/
theorem qdf_neighbor_bound (n : ℤ) :
    ((n + 1) ^ 2 + (n + 1) + 1) - (n ^ 2 + n + 1) = 2 * n + 2 := by ring




/-- Classical Pythagorean triple embedded as a quadruple. -/
theorem qdf_classical_embed (m n : ℤ) :
    (2 * m * n) ^ 2 + (m ^ 2 - n ^ 2) ^ 2 + 0 ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring




/-- Extended Pythagorean identity. -/
theorem qdf_extended_pyth (m n : ℤ) :
    (2 * m * n) ^ 2 + (m ^ 2 - n ^ 2) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by ring




/-- Sum of cubes factoring. -/
theorem sum_cubes_factor (a b : ℤ) :
    a ^ 3 + b ^ 3 = (a + b) * (a ^ 2 - a * b + b ^ 2) := by ring




/-- Negative parameter: the quadratic family works for negative n. -/
theorem qdf_negative_family (n : ℤ) :
    (-n) ^ 2 + (-n - 1) ^ 2 + ((-n) * (-n - 1)) ^ 2 = (n ^ 2 + n + 1) ^ 2 := by ring




/-- Triple composition: applying the quadratic family to its own output. -/
theorem qdf_triple_compose (n : ℤ) :
    let d₁ := n ^ 2 + n + 1
    let d₂ := d₁ ^ 2 + d₁ + 1
    d₁ ^ 2 + (d₁ + 1) ^ 2 + (d₁ * (d₁ + 1)) ^ 2 = d₂ ^ 2 := by ring




/-- Difference of two quadratic family hypotenuses. -/
theorem qdf_difference_identity (m n : ℤ) :
    (m ^ 2 + m + 1) ^ 2 - (n ^ 2 + n + 1) ^ 2 =
    (m - n) * (m + n + 1) * (m ^ 2 + m + n ^ 2 + n + 2) := by ring




/-- Residue class: n²+n+1 ≡ 1 (mod n). -/
theorem qdf_residue_class (n : ℤ) :
    n ∣ (n ^ 2 + n + 1 - 1) := ⟨n + 1, by ring⟩




/-- Quartic family: substituting n² into the quadratic family. -/
theorem qdf_quartic_family (n : ℤ) :
    (n ^ 2) ^ 2 + (n ^ 2 + 1) ^ 2 + (n ^ 2 * (n ^ 2 + 1)) ^ 2 =
    (n ^ 4 + n ^ 2 + 1) ^ 2 := by ring




/-- Consecutive hypotenuse sum. -/
theorem qdf_consecutive_sum (n : ℤ) :
    (n ^ 2 + n + 1) + ((n + 1) ^ 2 + (n + 1) + 1) = 2 * n ^ 2 + 4 * n + 4 := by ring




/-- Scaling composition: scale one quadruple by another's hypotenuse. -/
theorem qdf_compose_by_scaling (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2) :
    (d₂ * a₁) ^ 2 + (d₂ * b₁) ^ 2 + (d₂ * c₁) ^ 2 = (d₁ * d₂) ^ 2 := by
  nlinarith [sq_nonneg d₂]




/-- Involution: negating all legs preserves the identity. -/
theorem qdf_involution (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (-a) ^ 2 + (-b) ^ 2 + (-c) ^ 2 = d ^ 2 := by linarith




/-- Reflection: d → -d is also valid. -/
theorem qdf_reflection (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 + c ^ 2 = (-d) ^ 2 := by nlinarith




/-- Lattice ↔ QEC bridge: Cauchy-Schwarz as fidelity bound. -/
theorem qdf_lattice_qec_bridge (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d₁ ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d₂ ^ 2)
    (hd1 : d₁ ≠ 0) (hd2 : d₂ ≠ 0) :
    ((a₁ * a₂ + b₁ * b₂ + c₁ * c₂ : ℤ) : ℚ) ^ 2 / ((d₁ : ℚ) ^ 2 * d₂ ^ 2) ≤ 1 := by
  have hd1' : (d₁ : ℚ) ^ 2 > 0 := by positivity
  have hd2' : (d₂ : ℚ) ^ 2 > 0 := by positivity
  rw [div_le_one (mul_pos hd1' hd2')]
  have key : (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) ^ 2 ≤ d₁ ^ 2 * d₂ ^ 2 := by
    nlinarith [sq_nonneg (a₁ * b₂ - b₁ * a₂),
               sq_nonneg (a₁ * c₂ - c₁ * a₂),
               sq_nonneg (b₁ * c₂ - c₁ * b₂)]
  exact_mod_cast key




/-- HE ↔ TDA bridge: additive cross-term equals distance formula. -/
theorem qdf_he_tda_bridge (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ - a₂) ^ 2 + (b₁ - b₂) ^ 2 + (c₁ - c₂) ^ 2 +
    2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) = 2 * d ^ 2 := by nlinarith




/-- Midpoint identity for same-sphere quadruples. -/
theorem qdf_midpoint_identity (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    (a₁ + a₂) ^ 2 + (b₁ + b₂) ^ 2 + (c₁ + c₂) ^ 2 =
    2 * d ^ 2 + 2 * (a₁ * a₂ + b₁ * b₂ + c₁ * c₂) := by nlinarith



