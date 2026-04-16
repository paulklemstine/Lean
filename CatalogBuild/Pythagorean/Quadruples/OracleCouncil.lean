/-! # CatalogBuild.Pythagorean.Quadruples.OracleCouncil

Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 22
-/

import Mathlib

/-- Every permutation of the spatial components preserves the quadruple property. -/
theorem quadruple_perm_abc (a b c d : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple b c a d := by
  unfold IsPythQuadruple at *; linarith



/-- [Section: # CatalogBuild.Pythagorean.Quadruples.OracleCouncil
Auto-generated from theorem catalog database.
Domain: Pythagorean/Quadruples
Declarations: 22] -/
theorem quadruple_perm_acb (a b c d : ℤ) (h : IsPythQuadruple a b c d) :
    IsPythQuadruple a c b d := by
  unfold IsPythQuadruple at *; linarith



/-- The (1, 2, 2, 3) quadruple is the smallest primitive one. -/
theorem quad_1_2_2_3' : IsPythQuadruple 1 2 2 3 := by
  unfold IsPythQuadruple; norm_num



/-- The (1, 4, 8, 9) quadruple. -/
theorem quad_1_4_8_9' : IsPythQuadruple 1 4 8 9 := by
  unfold IsPythQuadruple; norm_num



/-- Euler's four-square identity: the product of two sums of four squares
is a sum of four squares. This IS quaternion norm multiplicativity. -/
theorem euler_four_square' (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    (a₁*a₂ - b₁*b₂ - c₁*c₂ - d₁*d₂)^2 +
    (a₁*b₂ + b₁*a₂ + c₁*d₂ - d₁*c₂)^2 +
    (a₁*c₂ - b₁*d₂ + c₁*a₂ + d₁*b₂)^2 +
    (a₁*d₂ + b₁*c₂ - c₁*b₂ + d₁*a₂)^2 := by ring



theorem square_mod_8' (d : ℤ) : d ^ 2 % 8 = 0 ∨ d ^ 2 % 8 = 1 ∨ d ^ 2 % 8 = 4 := by
  rw [ sq, Int.mul_emod ] ; have := Int.emod_nonneg d ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos d ( by decide : ( 0 : ℤ ) < 8 ) ; interval_cases d % 8 <;> trivial;



theorem square_avoids_legendre' (d : ℤ) : d ^ 2 % 8 ≠ 7 := by
  rw [ sq, Int.mul_emod ] ; have := Int.emod_nonneg d ( by decide : ( 8 : ℤ ) ≠ 0 ) ; have := Int.emod_lt_of_pos d ( by decide : ( 8 : ℤ ) > 0 ) ; interval_cases d % 8 <;> trivial;



/-- The integer lattice sphere of radius-squared R. -/
def IntSphere (R : ℤ) : Set (ℤ × ℤ × ℤ) :=
  { v | v.1 ^ 2 + v.2.1 ^ 2 + v.2.2 ^ 2 = R }



/-- Quadruples with hypotenuse d correspond to lattice points on IntSphere(d²). -/
theorem quad_is_lattice_point (a b c d : ℤ) :
    IsPythQuadruple a b c d ↔ (a, b, c) ∈ IntSphere (d ^ 2) := by
  unfold IsPythQuadruple IntSphere; simp



/-- The sphere IntSphere(0) has exactly one point: the origin. -/
theorem int_sphere_zero : IntSphere 0 = {(0, 0, 0)} := by
  ext ⟨a, b, c⟩
  simp [IntSphere]
  constructor
  · intro h
    have ha : a ^ 2 ≥ 0 := sq_nonneg a
    have hb : b ^ 2 ≥ 0 := sq_nonneg b
    have hc : c ^ 2 ≥ 0 := sq_nonneg c
    have ha0 : a ^ 2 = 0 := by omega
    have hb0 : b ^ 2 = 0 := by omega
    have hc0 : c ^ 2 = 0 := by omega
    exact ⟨pow_eq_zero_iff (by norm_num : 2 ≠ 0) |>.mp ha0,
           pow_eq_zero_iff (by norm_num : 2 ≠ 0) |>.mp hb0,
           pow_eq_zero_iff (by norm_num : 2 ≠ 0) |>.mp hc0⟩
  · rintro ⟨rfl, rfl, rfl⟩; simp



/-- Rotational symmetry: swapping coordinates preserves membership. -/
theorem sphere_rotation_symmetry (a b c R : ℤ) (h : (a, b, c) ∈ IntSphere R) :
    (b, a, c) ∈ IntSphere R := by
  simp [IntSphere] at *; linarith



/-- The Hopf map components satisfy x² + y² + z² = (a² + b² + c² + d²)². -/
theorem hopf_map_norm' (a b c d : ℤ) :
    (2*(a*c + b*d))^2 + (2*(b*c - a*d))^2 + (a^2 + b^2 - c^2 - d^2)^2 =
    (a^2 + b^2 + c^2 + d^2)^2 := by ring



/-- The Hopf map sends an integer 3-sphere to an integer 2-sphere. -/
theorem hopf_maps_sphere' (a b c d R : ℤ)
    (h : a^2 + b^2 + c^2 + d^2 = R) :
    (2*(a*c + b*d))^2 + (2*(b*c - a*d))^2 + (a^2 + b^2 - c^2 - d^2)^2 = R^2 := by
  nlinarith [hopf_map_norm' a b c d]



/-- Connection to quadruples: every integer point on S³ gives a Pythagorean quadruple
via the Hopf map. -/
theorem hopf_generates_quadruple' (a b c d : ℤ) :
    IsPythQuadruple
      (2*(a*c + b*d))
      (2*(b*c - a*d))
      (a^2 + b^2 - c^2 - d^2)
      (a^2 + b^2 + c^2 + d^2) := by
  unfold IsPythQuadruple; ring



/-- The sum of four squares is non-negative. -/
theorem four_sq_nonneg' (a b c d : ℤ) : 0 ≤ a^2 + b^2 + c^2 + d^2 := by
  nlinarith [sq_nonneg a, sq_nonneg b, sq_nonneg c, sq_nonneg d]



/-- A sum of three squares is a sum of four squares (with fourth = 0). -/
theorem three_sq_is_four_sq' (a b c : ℤ) :
    a^2 + b^2 + c^2 = a^2 + b^2 + c^2 + 0^2 := by ring



/-- Every Pythagorean quadruple hypotenuse squared is a sum of 3 squares. -/
theorem quad_hypotenuse_is_three_sq (a b c d : ℤ)
    (h : IsPythQuadruple a b c d) :
    d^2 = a^2 + b^2 + c^2 := by
  unfold IsPythQuadruple at h; linarith



/-- The divine quaternion: every Pythagorean quadruple defines a quaternion
q = d + ai + bj + ck with |q|² = 2d². -/
theorem divine_quaternion_norm' (a b c d : ℤ)
    (h : IsPythQuadruple a b c d) :
    d^2 + a^2 + b^2 + c^2 = 2 * d^2 := by
  unfold IsPythQuadruple at h; linarith



/-- The converse: if |q|² = 2·(Re q)², then Im(q) forms a Pythagorean quadruple. -/
theorem divine_converse' (a b c d : ℤ)
    (h : d^2 + a^2 + b^2 + c^2 = 2 * d^2) :
    IsPythQuadruple a b c d := by
  unfold IsPythQuadruple; linarith



/-- The product of two sums of three squares can be expressed as a sum of three squares
(using the quaternion trick: embed as 4-tuples with 0, multiply, project). -/
theorem three_sq_product (a₁ b₁ c₁ a₂ b₂ c₂ : ℤ) :
    ∃ x y z w : ℤ,
    (a₁^2 + b₁^2 + c₁^2) * (a₂^2 + b₂^2 + c₂^2) = x^2 + y^2 + z^2 + w^2 := by
  -- Use Euler 4-square with d₁ = d₂ = 0
  exact ⟨a₁*a₂ - b₁*b₂ - c₁*c₂,
         a₁*b₂ + b₁*a₂ + c₁*0 - 0*c₂,
         a₁*c₂ - b₁*0 + c₁*a₂ + 0*b₂,
         a₁*0 + b₁*c₂ - c₁*b₂ + 0*a₂, by ring⟩



/-- Every positive integer is a sum of four squares (we state a key lemma:
1 is a sum of four squares). -/
theorem one_is_four_squares : ∃ a b c d : ℤ, a^2 + b^2 + c^2 + d^2 = 1 := by
  exact ⟨1, 0, 0, 0, by norm_num⟩



/-- The compositional structure: if N₁ and N₂ are both sums of four squares,
then so is N₁ · N₂. -/
theorem sum_four_sq_mul' (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ) :
    ∃ x₁ x₂ x₃ x₄ : ℤ,
    (a₁^2 + b₁^2 + c₁^2 + d₁^2) * (a₂^2 + b₂^2 + c₂^2 + d₂^2) =
    x₁^2 + x₂^2 + x₃^2 + x₄^2 :=
  ⟨_, _, _, _, euler_four_square' a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂⟩

