import Mathlib

/-!
# Split geometry: exact coordinate calculations

We study the diagonal metric

`ds² = dx² / cosh(y)² + cosh(x)² dy²`.

The metric is positive definite everywhere.  We compute its six independent
Christoffel symbols and the Gaussian curvature obtained from the orthogonal-coordinate
(Brioschi) formula.  The resulting curvature is **not** the conjectured
`sech(x)² - sech(y)²`: in particular it is strictly negative on every nonzero point
of either coordinate axis, so the proposed diagonal phase boundary and positive
`|x| > |y|` phase do not describe this metric.
-/

namespace SplitGeometry

noncomputable section

/-- The `dx²` coefficient of the split metric. -/
def g₁₁ (y : ℝ) : ℝ := 1 / Real.cosh y ^ 2

/-- The `dy²` coefficient of the split metric. -/
def g₂₂ (x : ℝ) : ℝ := Real.cosh x ^ 2

/-- The positive square root of the determinant of the split metric. -/
def areaDensity (x y : ℝ) : ℝ := Real.cosh x / Real.cosh y

/-- The split metric evaluated on a tangent vector `(u,v)`. -/
def metricNormSq (x y u v : ℝ) : ℝ := g₁₁ y * u ^ 2 + g₂₂ x * v ^ 2

/-- The split metric is positive definite at every point.
-/
theorem metric_positive_definite (x y u v : ℝ) (huv : u ≠ 0 ∨ v ≠ 0) :
    0 < metricNormSq x y u v := by
  rcases huv with ( huv | huv ) <;> simp_all +decide [metricNormSq];
  · exact add_pos_of_pos_of_nonneg ( mul_pos ( one_div_pos.mpr ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ) ( sq_pos_of_ne_zero huv ) ) ( mul_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) );
  · exact add_pos_of_nonneg_of_pos ( mul_nonneg ( one_div_nonneg.mpr ( sq_nonneg _ ) ) ( sq_nonneg _ ) ) ( mul_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_ne_zero huv ) )

/-- The displayed area density squares to the determinant `g₁₁ g₂₂`.
-/
theorem areaDensity_sq (x y : ℝ) :
    areaDensity x y ^ 2 = g₁₁ y * g₂₂ x := by
  unfold areaDensity g₁₁ g₂₂; ring;

/-- The area density is everywhere strictly positive.
-/
theorem areaDensity_pos (x y : ℝ) : 0 < areaDensity x y := by
  exact div_pos ( Real.cosh_pos _ ) ( Real.cosh_pos _ )

/-- Coordinate derivative `∂ᵧ g₁₁`.
-/
theorem hasDerivAt_g₁₁ (y : ℝ) :
    HasDerivAt g₁₁ (-2 * Real.sinh y / Real.cosh y ^ 3) y := by
  refine' HasDerivAt.congr_of_eventuallyEq _ _;
  exact fun y => 1 / Real.cosh y ^ 2;
  · convert HasDerivAt.div ( hasDerivAt_const _ _ ) ( HasDerivAt.comp y ( hasDerivAt_pow 2 _ ) ( Real.hasDerivAt_cosh _ ) ) ( pow_ne_zero _ ( ne_of_gt ( Real.cosh_pos _ ) ) ) using 1 ; ring;
    grind;
  · rfl

/-- Coordinate derivative `∂ₓ g₂₂`.
-/
theorem hasDerivAt_g₂₂ (x : ℝ) :
    HasDerivAt g₂₂ (2 * Real.cosh x * Real.sinh x) x := by
  convert HasDerivAt.comp x ( hasDerivAt_pow 2 _ ) ( Real.hasDerivAt_cosh x ) using 1 ; ring!

/-- The coefficient `Γ¹₁₁`, which vanishes because `g₁₁` is independent of `x`. -/
def christoffel111 (_x _y : ℝ) : ℝ := 0

/-- The coefficient `Γ²₂₂`, which vanishes because `g₂₂` is independent of `y`. -/
def christoffel222 (_x _y : ℝ) : ℝ := 0

/-- The two vanishing Christoffel symbols. -/
theorem christoffel_diagonal_zero (x y : ℝ) :
    christoffel111 x y = 0 ∧ christoffel222 x y = 0 := by
  simp [christoffel111, christoffel222]

/-- Raw Levi-Civita formula for `Γ¹₁₂ = Γ¹₂₁`. -/
def christoffel112 (y : ℝ) : ℝ :=
  (1 / 2 : ℝ) * Real.cosh y ^ 2 * (-2 * Real.sinh y / Real.cosh y ^ 3)

/-- Raw Levi-Civita formula for `Γ¹₂₂`. -/
def christoffel122 (x y : ℝ) : ℝ :=
  -(1 / 2 : ℝ) * Real.cosh y ^ 2 * (2 * Real.cosh x * Real.sinh x)

/-- Raw Levi-Civita formula for `Γ²₁₁`. -/
def christoffel211 (x y : ℝ) : ℝ :=
  -(1 / 2 : ℝ) * (1 / Real.cosh x ^ 2) *
    (-2 * Real.sinh y / Real.cosh y ^ 3)

/-- Raw Levi-Civita formula for `Γ²₁₂ = Γ²₂₁`. -/
def christoffel212 (x : ℝ) : ℝ :=
  (1 / 2 : ℝ) * (1 / Real.cosh x ^ 2) *
    (2 * Real.cosh x * Real.sinh x)

/-- Closed form for `Γ¹₁₂ = Γ¹₂₁`.
-/
theorem christoffel112_eq (y : ℝ) :
    christoffel112 y = -Real.sinh y / Real.cosh y := by
  by_cases hy : Real.cosh y = 0 <;> simp_all +decide [div_eq_mul_inv, mul_comm];
  · exact absurd hy <| ne_of_gt <| Real.cosh_pos _;
  · unfold christoffel112; ring_nf; simp +decide [pow_three, sq, mul_assoc] ; ring;
    grind

/-- Closed form for `Γ¹₂₂`.
-/
theorem christoffel122_eq (x y : ℝ) :
    christoffel122 x y =
      -(Real.cosh y ^ 2 * Real.cosh x * Real.sinh x) := by
  unfold christoffel122; ring;

/-- Closed form for `Γ²₁₁`.
-/
theorem christoffel211_eq (x y : ℝ) :
    christoffel211 x y =
      Real.sinh y / (Real.cosh y ^ 3 * Real.cosh x ^ 2) := by
  unfold christoffel211; ring

/-- Closed form for `Γ²₁₂ = Γ²₂₁`.
-/
theorem christoffel212_eq (x : ℝ) :
    christoffel212 x = Real.sinh x / Real.cosh x := by
  unfold christoffel212;
  grind

/-- The `x` derivative appearing in Brioschi's formula. -/
def brioschiX (x y : ℝ) : ℝ := 2 * Real.cosh x * Real.cosh y

/-- The `y` derivative appearing in Brioschi's formula. -/
def brioschiY (x y : ℝ) : ℝ :=
  -2 * (1 - Real.sinh y ^ 2) / (Real.cosh x * Real.cosh y ^ 3)

/-- Gaussian curvature obtained from the orthogonal-coordinate Brioschi formula. -/
def gaussianCurvature (x y : ℝ) : ℝ :=
  -(1 / (2 * areaDensity x y)) * (brioschiX x y + brioschiY x y)

/-- Exact closed form of the Gaussian curvature of the split metric.
-/
theorem gaussianCurvature_eq (x y : ℝ) :
    gaussianCurvature x y =
      -Real.cosh y ^ 2 +
        (1 - Real.sinh y ^ 2) / (Real.cosh x ^ 2 * Real.cosh y ^ 2) := by
  rw [ gaussianCurvature, areaDensity, brioschiX, brioschiY ];
  field_simp
  ring

/-- The curvature vanishes at the origin.
-/
theorem gaussianCurvature_origin : gaussianCurvature 0 0 = 0 := by
  norm_num [ gaussianCurvature_eq ]

/-- The actual Gaussian curvature is nonpositive everywhere. -/
theorem gaussianCurvature_nonpos (x y : ℝ) :
    gaussianCurvature x y ≤ 0 := by
  rw [ gaussianCurvature_eq ];
  rw [ add_div', div_le_iff₀ ] <;> try positivity;
  nlinarith [ sq_nonneg ( Real.cosh x ^ 2 * Real.cosh y ^ 2 - 1 ), Real.cosh_sq' x, Real.cosh_sq' y ]

/-- The origin is the unique point at which the actual Gaussian curvature vanishes. -/
theorem gaussianCurvature_eq_zero_iff (x y : ℝ) :
    gaussianCurvature x y = 0 ↔ x = 0 ∧ y = 0 := by
  rw [ gaussianCurvature_eq ];
  by_cases hx : x = 0 <;> by_cases hy : y = 0 <;> simp_all +decide [ Real.cosh_sq' ];
  · rw [ add_div', div_eq_iff ] <;> nlinarith [ mul_self_pos.2 ( show Real.sinh y ≠ 0 from fun h => hy <| by simpa using h ) ];
  · nlinarith [ Real.sinh_sq x, mul_inv_cancel₀ ( by nlinarith [ Real.sinh_sq x ] : ( 1 + Real.sinh x ^ 2 ) ≠ 0 ), mul_self_pos.2 ( show Real.sinh x ≠ 0 from fun h => hx <| by simpa using h ) ];
  · field_simp;
    nlinarith [ sq_nonneg ( Real.sinh x * Real.sinh y ), mul_self_pos.2 ( show Real.sinh x ≠ 0 from by simpa using hx ), mul_self_pos.2 ( show Real.sinh y ≠ 0 from by simpa using hy ) ]

/-- Away from the origin, the actual Gaussian curvature is strictly negative. -/
theorem gaussianCurvature_strictly_neg {x y : ℝ} (hxy : x ≠ 0 ∨ y ≠ 0) :
    gaussianCurvature x y < 0 := by
  convert gaussianCurvature_nonpos x y |> lt_of_le_of_ne <| ?_;
  exact fun h => hxy.elim ( fun hx => hx <| ( gaussianCurvature_eq_zero_iff x y |> Iff.mp ) h |>.1 ) fun hy => hy <| ( gaussianCurvature_eq_zero_iff x y |> Iff.mp ) h |>.2

/-- On the horizontal axis the curvature is `-1 + sech(x)²`.
-/
theorem gaussianCurvature_horizontal (x : ℝ) :
    gaussianCurvature x 0 = -1 + 1 / Real.cosh x ^ 2 := by
  convert gaussianCurvature_eq x 0 using 1 ; norm_num [ Real.cosh_zero ]

/-- Every non-origin point of the horizontal axis has negative curvature.
-/
theorem gaussianCurvature_horizontal_neg {x : ℝ} (hx : x ≠ 0) :
    gaussianCurvature x 0 < 0 := by
  rw [ gaussianCurvature_horizontal, add_comm ];
  norm_num [ hx ];
  exact inv_lt_one_of_one_lt₀ ( one_lt_pow₀ ( by norm_num; positivity ) two_ne_zero )

/-- Every non-origin point of the vertical axis has negative curvature.
-/
theorem gaussianCurvature_vertical_neg {y : ℝ} (hy : y ≠ 0) :
    gaussianCurvature 0 y < 0 := by
  rw [ gaussianCurvature_eq ] ; ring_nf;
  norm_num [ Real.cosh_sq' ];
  nlinarith [ inv_mul_cancel₀ ( by positivity : ( 1 + Real.sinh y ^ 2 ) ≠ 0 ), Real.sinh_sq y, mul_self_pos.mpr ( show Real.sinh y ≠ 0 from by aesop ) ]

/-- Every non-origin point of the proposed diagonal phase boundary has strictly
negative, rather than zero, curvature.
-/
theorem gaussianCurvature_diagonal_neg {t : ℝ} (ht : t ≠ 0) :
    gaussianCurvature t t < 0 := by
  convert gaussianCurvature_eq t t |> fun h => h.trans_lt ?_ using 1;
  rw [ add_div', div_lt_iff₀ ] <;> nlinarith [ mul_self_pos.2 ( show Real.sinh t ^ 2 ≠ 0 by exact pow_ne_zero _ <| by aesop ), Real.cosh_sq' t, pow_pos ( Real.cosh_pos t ) 3, pow_pos ( Real.cosh_pos t ) 4 ]

/-- The fully covariant component `R₁₂₁₂ = K det(g)` of the curvature tensor. -/
def riemann1212 (x y : ℝ) : ℝ :=
  gaussianCurvature x y * (g₁₁ y * g₂₂ x)

/-- Exact closed form of the independent fully covariant curvature component.
-/
theorem riemann1212_eq (x y : ℝ) :
    riemann1212 x y =
      -Real.cosh x ^ 2 + (1 - Real.sinh y ^ 2) / Real.cosh y ^ 4 := by
  unfold riemann1212;
  rw [ gaussianCurvature_eq, g₁₁, g₂₂ ];
  field_simp

/-- In dimension two, the scalar curvature is twice the Gaussian curvature. -/
def scalarCurvature (x y : ℝ) : ℝ := 2 * gaussianCurvature x y

/-- Exact scalar curvature of the split metric.
-/
theorem scalarCurvature_eq (x y : ℝ) :
    scalarCurvature x y =
      -2 * Real.cosh y ^ 2 +
        2 * (1 - Real.sinh y ^ 2) / (Real.cosh x ^ 2 * Real.cosh y ^ 2) := by
  convert congr_arg ( fun z => 2 * z ) ( gaussianCurvature_eq x y ) using 1 ; ring!

/-- The advertised curvature expression from the conjecture. -/
def conjecturedCurvature (x y : ℝ) : ℝ :=
  1 / Real.cosh x ^ 2 - 1 / Real.cosh y ^ 2

/-- The conjectured profile does have the claimed sign in `|x| < |y|`.
-/
theorem conjecturedCurvature_pos_iff (x y : ℝ) :
    0 < conjecturedCurvature x y ↔ |x| < |y| := by
  unfold conjecturedCurvature;
  rw [ div_sub_div, lt_div_iff₀ ];
  · convert Real.cosh_lt_cosh using 1 ; norm_num;
    rw [ sq_lt_sq, abs_of_nonneg ( Real.cosh_pos _ |> le_of_lt ), abs_of_nonneg ( Real.cosh_pos _ |> le_of_lt ) ] ; aesop;
  · exact mul_pos ( sq_pos_of_pos ( Real.cosh_pos _ ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) );
  · exact ne_of_gt ( sq_pos_of_pos ( Real.cosh_pos _ ) );
  · exact ne_of_gt ( sq_pos_of_pos ( Real.cosh_pos _ ) )

/-- The conjectured profile vanishes exactly on the two diagonals.
-/
theorem conjecturedCurvature_eq_zero_iff (x y : ℝ) :
    conjecturedCurvature x y = 0 ↔ y = x ∨ y = -x := by
  have h_eq : conjecturedCurvature x y = 0 ↔ 1 / Real.cosh x ^ 2 = 1 / Real.cosh y ^ 2 := by
    exact sub_eq_zero;
  simp_all +decide [ Real.cosh_sq' ];
  rw [ sq_eq_sq_iff_eq_or_eq_neg ];
  exact ⟨ fun h => by cases' h with h h <;> [ left; right ] <;> exact Real.sinh_injective <| by aesop, fun h => by cases' h with h h <;> [ left; right ] <;> aesop ⟩

/-- The actual and conjectured curvatures disagree on every nonzero point
of the vertical axis: the actual curvature is negative there, whereas the conjectured
profile is positive.
-/
theorem curvature_conjecture_false_on_vertical {y : ℝ} (hy : y ≠ 0) :
    gaussianCurvature 0 y ≠ conjecturedCurvature 0 y := by
  have h_neg : gaussianCurvature 0 y < 0 := by
    exact gaussianCurvature_vertical_neg hy
  have h_pos : 0 < conjecturedCurvature 0 y := by
    convert conjecturedCurvature_pos_iff 0 y |>.2 _ using 1 ; aesop
  linarith

end

end SplitGeometry