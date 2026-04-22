import Mathlib

/-! # CatalogBuild.Pythagorean.QDF.QDF_NewDirections

Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 27
-/

/-- The difference-of-squares factoring identity for quadruples. -/
theorem radical_bound_basic (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (d - c) * (d + c) = a ^ 2 + b ^ 2 ∧
    d ^ 2 - c ^ 2 = a ^ 2 + b ^ 2 := by
  constructor <;> nlinarith

/-- When d - c = 1, the quadruple connects to Pell equations. -/
theorem thin_quadruple_pell (a b d : ℤ)
    (h : a ^ 2 + b ^ 2 + (d - 1) ^ 2 = d ^ 2) :
    a ^ 2 + b ^ 2 = 2 * d - 1 := by
  nlinarith

/-- abc quality bound: positivity of factor components. -/
theorem abc_quality_bound (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hd : d > 0) (hc : c ≥ 0) (hdc : d > c) :
    d - c > 0 ∧ d + c > 0 ∧ (d - c) * (d + c) = a ^ 2 + b ^ 2 := by
  refine ⟨by omega, by omega, by nlinarith⟩

/-- [Section: # CatalogBuild.Pythagorean.QDF.QDF_NewDirections
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 27] -/
theorem parity_propagation (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hd : 2 ∣ d) (ha : ¬ 2 ∣ a) (hb : ¬ 2 ∣ b) :
    2 ∣ c := by
  exact even_iff_two_dvd.mp ( by replace h := congr_arg ( · % 4 ) h ; rcases hd with ⟨ k, rfl ⟩ ; rcases Int.even_or_odd' a with ⟨ k₂, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ k₃, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ k₄, rfl | rfl ⟩ <;> ring_nf at * <;> norm_num [ Int.add_emod, Int.mul_emod ] at * )

/-- [Section: # CatalogBuild.Pythagorean.QDF.QDF_NewDirections
Auto-generated from theorem catalog database.
Domain: Pythagorean/QDF
Declarations: 27] -/
theorem three_odd_forces_odd_d (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (ha : ¬ 2 ∣ a) (hb : ¬ 2 ∣ b) (hc : ¬ 2 ∣ c) :
    ¬ 2 ∣ d := by
  by_contra hd_even
  have hd_odd : Odd d := by
    exact absurd ( congr_arg ( · % 4 ) h ) ( by rcases hd_even with ⟨ d, rfl ⟩ ; rcases Int.even_or_odd' a with ⟨ a, rfl | rfl ⟩ <;> rcases Int.even_or_odd' b with ⟨ b, rfl | rfl ⟩ <;> rcases Int.even_or_odd' c with ⟨ c, rfl | rfl ⟩ <;> ring_nf <;> norm_num [ Int.add_emod, Int.mul_emod ] at * )
  obtain ⟨k, hk⟩ := hd_odd
  simp_all +contextual [ Int.add_emod, Int.mul_emod, sq ]

/-- At most two components can be odd when d is even. -/
theorem even_d_parity_constraint (a b c d : ℤ)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (hd : 2 ∣ d) :
    2 ∣ a ∨ 2 ∣ b ∨ 2 ∣ c := by
  by_contra h_all
  push_neg at h_all
  exact three_odd_forces_odd_d a b c d h h_all.1 h_all.2.1 h_all.2.2 hd

/-- Double lift: triple → quadruple → quintuple. -/
theorem double_lift_chain (a b c k₁ d₁ k₂ d₂ : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2)
    (h2 : c ^ 2 + k₁ ^ 2 = d₁ ^ 2)
    (h3 : d₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2) :
    a ^ 2 + b ^ 2 + k₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2 := by
  linarith

/-- Two independent factor pairs from a double-lift. -/
theorem double_lift_factor_pairs (a b c k₁ d₁ k₂ d₂ : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2)
    (h2 : c ^ 2 + k₁ ^ 2 = d₁ ^ 2)
    (h3 : d₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2) :
    (d₁ - k₁) * (d₁ + k₁) = a ^ 2 + b ^ 2 ∧
    (d₂ - k₂) * (d₂ + k₂) = a ^ 2 + b ^ 2 + k₁ ^ 2 := by
  constructor <;> nlinarith

/-- Difference of factor identities from a double-lift. -/
theorem nested_factor_cascade (a b k₁ d₁ k₂ d₂ : ℤ)
    (h_quad : a ^ 2 + b ^ 2 + k₁ ^ 2 = d₁ ^ 2)
    (h_quint : d₁ ^ 2 + k₂ ^ 2 = d₂ ^ 2) :
    (d₂ - k₂) * (d₂ + k₂) - (d₁ - k₁) * (d₁ + k₁) = k₁ ^ 2 := by
  nlinarith

/-- The quaternion parametric form always produces valid quadruples. -/
theorem quaternion_parametric_valid (m n p q : ℤ) :
    (m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2) ^ 2 +
    (2 * (m * q + n * p)) ^ 2 +
    (2 * (n * q - m * p)) ^ 2 =
    (m ^ 2 + n ^ 2 + p ^ 2 + q ^ 2) ^ 2 := by
  ring

/-- Division descent: d/g < d when g > 1. -/
theorem division_descent (d g : ℕ) (hg : g > 1) (hd : d > 0) (hdvd : g ∣ d) :
    d / g < d := Nat.div_lt_self hd hg

/-- Iterated descent preserves positivity. -/
theorem descent_termination (d g : ℕ) (hd : d > 0) (hg : g > 1) (hdvd : g ∣ d) :
    d / g > 0 := Nat.div_pos (Nat.le_of_dvd hd hdvd) (by omega)

/-- Berggren M₁ preserves the Pythagorean property. -/
theorem berggren_M1_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a - 2*b + 2*c) ^ 2 + (2*a - b + 2*c) ^ 2 = (2*a - 2*b + 3*c) ^ 2 := by
  nlinarith

/-- Berggren M₂ preserves the Pythagorean property. -/
theorem berggren_M2_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (a + 2*b + 2*c) ^ 2 + (2*a + b + 2*c) ^ 2 = (2*a + 2*b + 3*c) ^ 2 := by
  nlinarith

/-- Berggren M₃ preserves the Pythagorean property.
M₃ = [[-1,2,2],[-2,1,2],[-2,2,3]], mapping (a,b,c) to (-a+2b+2c, -2a+b+2c, -2a+2b+3c). -/
theorem berggren_M3_preserves (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    (-a + 2*b + 2*c) ^ 2 + (-2*a + b + 2*c) ^ 2 = (-2*a + 2*b + 3*c) ^ 2 := by
  nlinarith

/-- Bridge adjacency: lifting and projecting creates new triples. -/
theorem bridge_adjacency (a b c k d : ℤ)
    (h1 : a ^ 2 + b ^ 2 = c ^ 2)
    (h2 : a ^ 2 + b ^ 2 + k ^ 2 = d ^ 2) :
    c ^ 2 + k ^ 2 = d ^ 2 := by linarith

/-- The (1, 2, 2, 3) family. -/
theorem family_1_2_2_3 (k : ℤ) :
    k ^ 2 + (2 * k) ^ 2 + (2 * k) ^ 2 = (3 * k) ^ 2 := by ring

/-- The (2, 3, 6, 7) family. -/
theorem family_2_3_6_7 (k : ℤ) :
    (2*k) ^ 2 + (3*k) ^ 2 + (6*k) ^ 2 = (7*k) ^ 2 := by ring

/-- The (1, 4, 8, 9) family. -/
theorem family_1_4_8_9 (k : ℤ) :
    k ^ 2 + (4*k) ^ 2 + (8*k) ^ 2 = (9*k) ^ 2 := by ring

/-- Existence of nontrivial quadruples for any N. -/
theorem quadruple_existence (N : ℤ) (hN : N > 2) :
    ∃ b c d : ℤ, N ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 ∧ b > 0 := by
  exact ⟨2 * N, 2 * N, 3 * N, by ring, by omega⟩

/-- Factor recovery via GCD criterion. -/
theorem factor_recovery_criterion (c d N : ℤ) (hN : N > 1)
    (h_dc : Int.gcd (d - c) N > 1 ∨ Int.gcd (d + c) N > 1) :
    ∃ g : ℕ, g > 1 ∧ (g : ℤ) ∣ N := by
  cases h_dc with
  | inl h => exact ⟨Int.gcd (d - c) N, h, Int.gcd_dvd_right (d - c) N⟩
  | inr h => exact ⟨Int.gcd (d + c) N, h, Int.gcd_dvd_right (d + c) N⟩

/-- For any p > 0, the Grover oracle has marked items. -/
theorem grover_oracle_exists (p : ℤ) (hp : p > 0) (d : ℤ) :
    ∃ c : ℤ, p ∣ (d - c) := ⟨d, by simp⟩

/-- Parametric deformation bound. -/
theorem param_deformation (m n p q : ℤ) :
    let a := m ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
    let a' := (m + 1) ^ 2 + n ^ 2 - p ^ 2 - q ^ 2
    a' - a = 2 * m + 1 := by simp only; ring

/-- Berggren hypotenuse growth. -/
theorem berggren_hypotenuse_growth (a b c : ℤ)
    (h : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a > 0) (hb : b > 0) (hc : c > 0) :
    2 * a - 2 * b + 3 * c > c := by
  nlinarith [sq_nonneg (a - b), sq_nonneg a, sq_nonneg b]

/-- Quadruple components form a rational point on S². -/
theorem quantum_normalization (a b c d : ℤ) (hd : d ≠ 0)
    (h : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2) :
    (a : ℚ) ^ 2 / d ^ 2 + (b : ℚ) ^ 2 / d ^ 2 + (c : ℚ) ^ 2 / d ^ 2 = 1 := by
  have hd' : (d : ℚ) ≠ 0 := Int.cast_ne_zero.mpr hd
  field_simp
  exact_mod_cast h

/-- Factor p divides (d-c)(d+c) iff p | d²-c². -/
theorem navigation_target (c d p : ℤ) (h : p ∣ (d ^ 2 - c ^ 2)) :
    p ∣ (d - c) * (d + c) := by
  rwa [show (d - c) * (d + c) = d ^ 2 - c ^ 2 from by ring]

/-- Shared-component relation. -/
theorem shared_component_relation (a₁ b₁ c₁ a₂ b₂ c₂ d : ℤ)
    (h1 : a₁ ^ 2 + b₁ ^ 2 + c₁ ^ 2 = d ^ 2)
    (h2 : a₂ ^ 2 + b₂ ^ 2 + c₂ ^ 2 = d ^ 2) :
    a₁ ^ 2 + b₁ ^ 2 - (a₂ ^ 2 + b₂ ^ 2) = c₂ ^ 2 - c₁ ^ 2 := by
  linarith

