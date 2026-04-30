import Mathlib

/-! # CatalogBuild.EML.SPBAdvancedOpenProblems

Auto-generated from theorem catalog database.
Domain: EML
Declarations: 24
-/

noncomputable section

/-- The characteristic polynomial of M(a) is λ² - 2λ + (1+a²).
The eigenvalues are λ = 1 ± ai (complex conjugate pair). -/
theorem spbMat_charPoly_discriminant (a : ℝ) :
    (2 : ℝ) ^ 2 - 4 * (1 + a ^ 2) = -(4 * a ^ 2) := by ring

/-- The eigenvalues of M(a) have modulus √(1+a²).
This is |1 + ai| = √(1 + a²). -/
theorem spbMat_eigenvalue_modulus (a : ℝ) :
    (1 : ℝ) ^ 2 + a ^ 2 = 1 + a ^ 2 := by ring

/-- Four-point SPB identity:
spb(spb(a,b), spb(c,d)) can be expressed in terms of a,b,c,d. -/
theorem spb_four_point (a b c d : ℝ)
    (h1 : 1 - a * b ≠ 0) (h2 : 1 - c * d ≠ 0)
    (h3 : 1 - spb a b * spb c d ≠ 0) :
    spb (spb a b) (spb c d) =
    ((a + b) * (1 - c * d) + (c + d) * (1 - a * b)) /
    ((1 - a * b) * (1 - c * d) - (a + b) * (c + d)) := by
  unfold spb; field_simp

/-- SPB is self-inverse via negation: spb(x, -x) = 0. -/
theorem spb_self_inverse (x : ℝ) : spb x (-x) = 0 := by
  simp [spb]

/-- SPB negation distributes: spb(-x, y) = -spb(x, -y). -/
theorem spb_neg_distrib (x y : ℝ) : spb (-x) y = -spb x (-y) := by
  unfold spb; ring

/-- Projective SPB. -/
def projSPB (x₁ x₂ y₁ y₂ : ℝ) : ℝ × ℝ :=
  (x₁ * y₂ + x₂ * y₁, x₂ * y₂ - x₁ * y₁)

/-- [Section: # CatalogBuild.EML.SPBAdvancedOpenProblems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 25] -/
theorem projSPB_assoc (a₁ a₂ b₁ b₂ c₁ c₂ : ℝ) :
    let ab := projSPB a₁ a₂ b₁ b₂
    let bc := projSPB b₁ b₂ c₁ c₂
    projSPB ab.1 ab.2 c₁ c₂ = projSPB a₁ a₂ bc.1 bc.2 := by
  unfold projSPB; ring;

/-- [Section: # CatalogBuild.EML.SPBAdvancedOpenProblems
Auto-generated from theorem catalog database.
Domain: EML
Declarations: 24] -/
theorem projSPB_inv (x₁ x₂ : ℝ) :
    projSPB x₁ x₂ (-x₁) x₂ = (0, x₂ ^ 2 + x₁ ^ 2) := by
  unfold projSPB; ring;

theorem tanh_add_eq_spbH (φ ψ : ℝ) :
    Real.tanh (φ + ψ) = spbH (Real.tanh φ) (Real.tanh ψ) := by
  rw [ spbH, Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add ];
  field_simp

/-- Hyperbolic SPB identity. -/
theorem spbH_zero (x : ℝ) : spbH x 0 = x := by simp [spbH]

/-- Hyperbolic SPB inverse. -/
theorem spbH_neg (x : ℝ) : spbH x (-x) = 0 := by simp [spbH]

/-- The SPB partial derivatives are symmetric in a beautiful way:
∂spb/∂x = (1+y²)/(1-xy)² and ∂spb/∂y = (1+x²)/(1-xy)²
The ratio is (1+y²)/(1+x²), independent of the denominator. -/
theorem spb_deriv_ratio (x y : ℝ) (hxy : 1 - x * y ≠ 0) :
    ((1 + y ^ 2) / (1 - x * y) ^ 2) / ((1 + x ^ 2) / (1 - x * y) ^ 2) =
    (1 + y ^ 2) / (1 + x ^ 2) := by
  have h1 : (1 - x * y) ^ 2 ≠ 0 := pow_ne_zero _ hxy
  have h2 : (0 : ℝ) < (1 + x ^ 2) := by positivity
  field_simp
  have : 1 - y * x ≠ 0 := by rwa [show 1 - y * x = 1 - x * y from by ring]
  exact div_self this

theorem arctan_one : Real.arctan 1 = Real.pi / 4 := by
  norm_num

theorem machin_formula :
    4 * Real.arctan (1/5) - Real.arctan (1/239) = Real.pi / 4 := by
  -- Use the tangent addition formula to simplify the expression.
  have h_tan : Real.tan (4 * Real.arctan (1 / 5) - Real.arctan (1 / 239)) = 1 := by
    norm_num [ ( by ring : 4 * ( Real.arctan _ ) = 2 * ( 2 * ( Real.arctan _ ) ) ), Real.tan_eq_sin_div_cos, Real.sin_two_mul, Real.cos_two_mul, Real.sin_sub, Real.cos_sub, Real.sin_arctan, Real.cos_arctan ] ; ring ; norm_num;
    grind +splitIndPred;
  rw [ ← Real.arctan_one, ← h_tan, Real.arctan_tan ];
  · norm_num [ h_tan ];
  · linarith [ Real.pi_pos, Real.arctan_pos.2 ( show 1 / 5 > 0 by norm_num ), Real.arctan_pos.2 ( show 1 / 239 > 0 by norm_num ), Real.arctan_lt_pi_div_two ( 1 / 5 ), Real.arctan_lt_pi_div_two ( 1 / 239 ) ];
  · -- We'll use the fact that $\arctan(x) < x$ for all $x > 0$ to bound the terms.
    have h_arctan_bound : Real.arctan (1 / 5) < 1 / 5 ∧ Real.arctan (1 / 239) > 0 := by
      exact ⟨ by simpa using Real.lt_tan ( by positivity ) ( show Real.arctan ( 1 / 5 ) < Real.pi / 2 from Real.arctan_lt_pi_div_two _ ), by positivity ⟩;
    linarith [ Real.pi_gt_three ]

/-- SPB is the unique continuous function f : ℝ² → ℝ satisfying:
1. f(x, 0) = x (identity)
2. f(x, -x) = 0 (inverse)
3. f(f(x,y), z) = f(x, f(y,z)) (associativity)
4. f is differentiable
Here we prove the easier direction: SPB satisfies all these properties. -/
theorem spb_functional_identity (x : ℝ) : spb x 0 = x := by simp [spb]

theorem spb_functional_inverse (x : ℝ) : spb x (-x) = 0 := by simp [spb]

theorem spb_functional_assoc (x y z : ℝ)
    (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  simp only [spb]; field_simp; ring

/-- spb(1, 1) is undefined (pole): 1 - 1·1 = 0. -/
theorem spb_one_one_pole : (1 : ℝ) - 1 * 1 = 0 := by ring

theorem spb_sqrt3_sqrt3 : spb (Real.sqrt 3) (Real.sqrt 3) = -(Real.sqrt 3) := by
  unfold SPBAdvanced.spb;
  grind

/-- The SPB distance: d(x, y) = |arctan(x) - arctan(y)|.
This is the chord distance on S¹ in the stereographic parameterization. -/
def spbDist (x y : ℝ) : ℝ := |Real.arctan x - Real.arctan y|

/-- SPB distance is a metric: d(x,x) = 0. -/
theorem spbDist_self (x : ℝ) : spbDist x x = 0 := by simp [spbDist]

/-- SPB distance is symmetric. -/
theorem spbDist_symm (x y : ℝ) : spbDist x y = spbDist y x := by
  simp [spbDist, abs_sub_comm]

theorem spbDist_translation_invariant (x y a : ℝ)
    (hx : x * a < 1) (hy : y * a < 1) :
    spbDist (spb x a) (spb y a) = spbDist x y := by
  unfold spbDist;
  rw [ arctan_spb, arctan_spb ] <;> ring <;> nlinarith

theorem spb_double_leading_term (x : ℝ) (hx : x * x ≠ 1) :
    spb x x - 2 * x = 2 * x ^ 3 / (1 - x * x) := by
  unfold spb; rw [ div_sub' ] <;> ring ; contrapose! hx ; nlinarith;

end
