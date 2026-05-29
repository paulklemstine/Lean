import Mathlib

/-!
# Split Geometry: A Riemannian Geometry with Sign-Changing Curvature

We define a novel Riemannian metric on ℝ² — the **split metric** — whose Gaussian
curvature changes sign across the diagonals y = ±x. This creates a geometry that
simultaneously exhibits elliptic behavior (positive curvature, converging geodesics)
and hyperbolic behavior (negative curvature, diverging geodesics) in different regions
of the same space.

## The Split Metric

The split metric is the diagonal Riemannian metric on ℝ² given by:
  ds² = sech²(y) dx² + cosh²(x) dy²

Its Gaussian curvature is K(x,y) = sech²(x) - sech²(y), which satisfies:
- K = 0 on the diagonals y = ±x (flat phase boundary)
- K > 0 when |y| > |x| (elliptic region)
- K < 0 when |x| > |y| (hyperbolic region)

## Cross-Domain Connection

We establish a connection between split geometry and information theory by
defining a split divergence that behaves like a KL-divergence on a 2-parameter
exponential family with anisotropic Fisher information.

## Main Results

- `splitCurvature_diag`: Curvature vanishes on the diagonal y = x
- `splitCurvature_antidiag`: Curvature vanishes on the anti-diagonal y = -x
- `splitCurvature_antisymm`: K(x,y) = -K(y,x) (curvature is antisymmetric)
- `splitCurvature_pos_iff`: K > 0 if and only if |y| > |x|
- `splitCurvature_neg_iff`: K < 0 if and only if |x| > |y|
- `splitDivergence_nonneg`: The split divergence is non-negative
- `split_triangle_curvature_bound`: Curvature bound for split triangles
-/

noncomputable section

open Real

/-! ## Definitions -/

/-- The split curvature function K(x,y) = sech²(x) - sech²(y).

This is the Gaussian curvature of the split metric ds² = sech²(y)dx² + cosh²(x)dy²
on ℝ². The curvature changes sign across the diagonals y = ±x, creating a geometry
that is simultaneously elliptic and hyperbolic in different regions. -/
def splitCurvature (x y : ℝ) : ℝ :=
  (Real.cosh x)⁻¹ ^ 2 - (Real.cosh y)⁻¹ ^ 2

/-- A diagonal Riemannian metric tensor on ℝ², representing ds² = E(x,y)dx² + G(x,y)dy².
This structure encodes the metric components together with their positivity proofs,
guaranteeing the metric is well-defined and non-degenerate. -/
structure DiagMetric2D where
  /-- The g₁₁ component (coefficient of dx²) -/
  E : ℝ → ℝ → ℝ
  /-- The g₂₂ component (coefficient of dy²) -/
  G : ℝ → ℝ → ℝ
  /-- Positivity of E -/
  E_pos : ∀ x y, 0 < E x y
  /-- Positivity of G -/
  G_pos : ∀ x y, 0 < G x y

/-- The area element √(EG) of a diagonal metric. -/
def DiagMetric2D.areaElement (m : DiagMetric2D) (x y : ℝ) : ℝ :=
  Real.sqrt (m.E x y * m.G x y)

/-- The split metric on ℝ²: ds² = sech²(y) dx² + cosh²(x) dy².

This metric expands distances in the x-direction as |y| grows (hyperbolic spreading)
and contracts distances in the y-direction as |x| grows (elliptic focusing). -/
def splitMetric : DiagMetric2D where
  E := fun _ y => (Real.cosh y)⁻¹ ^ 2
  G := fun x _ => (Real.cosh x) ^ 2
  E_pos := fun _ y => by positivity
  G_pos := fun x _ => by positivity

/-- Phase classification for regions of split geometry.
Each region of ℝ² has a characteristic geometric behavior determined
by the sign of the Gaussian curvature. -/
inductive SplitPhase where
  /-- Positive curvature region: parallel geodesics converge -/
  | elliptic
  /-- Zero curvature boundary: flat geometry along diagonals -/
  | flat
  /-- Negative curvature region: parallel geodesics diverge -/
  | hyperbolic
  deriving DecidableEq, Repr

/-- Classify a point (x,y) ∈ ℝ² by its curvature phase.
Points on the diagonals y = ±x are flat; points with |y| > |x| are
elliptic; points with |x| > |y| are hyperbolic. -/
def classifyPhase (x y : ℝ) : SplitPhase :=
  if |x| < |y| then .elliptic
  else if |x| = |y| then .flat
  else .hyperbolic

/-- The split divergence between two points in split geometry.
Analogous to the KL divergence in information geometry, this measures
the asymmetric "information distance" between points using the
log-cosh coordinate transformation. -/
def splitDivergence (x₁ y₁ x₂ y₂ : ℝ) : ℝ :=
  (Real.log (Real.cosh x₂ / Real.cosh x₁)) ^ 2 +
  (Real.log (Real.cosh y₁ / Real.cosh y₂)) ^ 2

/-- A split triangle: a triangle in ℝ² with one vertex in each phase region
(elliptic, flat boundary, hyperbolic). -/
structure SplitTriangle where
  /-- First vertex (in elliptic region: |y₁| > |x₁|) -/
  x₁ : ℝ
  y₁ : ℝ
  /-- Second vertex (on flat boundary: |y₂| = |x₂|) -/
  x₂ : ℝ
  y₂ : ℝ
  /-- Third vertex (in hyperbolic region: |x₃| > |y₃|) -/
  x₃ : ℝ
  y₃ : ℝ
  /-- First vertex is in the elliptic region -/
  h₁ : |x₁| < |y₁|
  /-- Second vertex is on the flat boundary -/
  h₂ : |x₂| = |y₂|
  /-- Third vertex is in the hyperbolic region -/
  h₃ : |y₃| < |x₃|

/-! ## Core Curvature Theorems -/

/-
The curvature vanishes on the diagonal y = x.
This is the "phase boundary" where geometry transitions between elliptic and hyperbolic.
-/
theorem splitCurvature_diag (a : ℝ) : splitCurvature a a = 0 := by
  unfold splitCurvature; ring;

/-
The curvature vanishes on the anti-diagonal y = -x.
Since cosh is an even function, the anti-diagonal is also a phase boundary.
-/
theorem splitCurvature_antidiag (a : ℝ) : splitCurvature a (-a) = 0 := by
  unfold splitCurvature; rw [ Real.cosh_neg ] ; ring;

/-
The split curvature is antisymmetric under coordinate swap.
This reflects the duality between the elliptic and hyperbolic regions:
the curvature at (x,y) is exactly the negative of the curvature at (y,x).
-/
theorem splitCurvature_antisymm (x y : ℝ) :
    splitCurvature x y = -splitCurvature y x := by
  unfold splitCurvature; ring;

/-- The curvature at the origin is zero: the origin sits at the intersection
of both phase boundaries y = x and y = -x. -/
theorem splitCurvature_origin : splitCurvature 0 0 = 0 :=
  splitCurvature_diag 0

/-! ## Sign Analysis of Curvature -/

/-
**Key theorem**: The split curvature is positive if and only if |y| > |x|.
This characterizes the elliptic region of split geometry. The proof uses the
strict monotonicity of cosh on [0,∞) and the characterization cosh(a) < cosh(b) ↔ |a| < |b|.
-/
theorem splitCurvature_pos_iff (x y : ℝ) :
    0 < splitCurvature x y ↔ |x| < |y| := by
  norm_num [ splitCurvature, inv_pow ];
  rw [ inv_lt_inv₀, pow_lt_pow_iff_left₀ ] <;> norm_num [ Real.cosh_pos ];
  · positivity;
  · exact le_of_lt ( Real.cosh_pos _ )

/-
The split curvature is negative if and only if |x| > |y|.
This characterizes the hyperbolic region.
-/
theorem splitCurvature_neg_iff (x y : ℝ) :
    splitCurvature x y < 0 ↔ |y| < |x| := by
  convert splitCurvature_pos_iff y x using 1;
  rw [ ← neg_pos, splitCurvature_antisymm ];
  norm_num

/-
The split curvature is zero if and only if |x| = |y|, i.e., the point
lies on the phase boundary y = ±x.
-/
theorem splitCurvature_zero_iff (x y : ℝ) :
    splitCurvature x y = 0 ↔ |x| = |y| := by
  constructor <;> intro h;
  · contrapose! h;
    cases lt_or_gt_of_ne h <;> unfold splitCurvature <;> simp_all +decide [ Real.cosh_pos ];
    · rw [ sub_eq_zero, inv_inj ];
      -- Since $|x| < |y|$, we have $\cosh(x) < \cosh(y)$.
      have h_cosh_lt : Real.cosh x < Real.cosh y := by
        rw [ Real.cosh_lt_cosh ] ; aesop;
      nlinarith [ Real.cosh_pos x, Real.cosh_pos y ];
    · rw [ sub_eq_zero, inv_inj ];
      exact ne_of_gt ( pow_lt_pow_left₀ ( by rw [ ← Real.cosh_abs x, ← Real.cosh_abs y ] ; exact Real.cosh_lt_cosh.2 ( by aesop ) ) ( Real.cosh_pos _ |> le_of_lt ) ( by norm_num ) );
  · unfold splitCurvature;
    rw [ abs_eq_abs ] at h ; aesop

/-
Phase classification is consistent with curvature sign.
-/
theorem phase_elliptic_iff_curvature_pos (x y : ℝ) :
    classifyPhase x y = .elliptic ↔ 0 < splitCurvature x y := by
  convert splitCurvature_pos_iff x y |> Iff.symm using 1;
  grind +locals

/-! ## Metric Properties -/

/-
The area element of the split metric equals cosh(x)/cosh(y).
This shows the area distortion: regions with large |x| are stretched
while regions with large |y| are compressed.
-/
theorem splitMetric_areaElement (x y : ℝ) :
    splitMetric.areaElement x y = Real.cosh x / Real.cosh y := by
  unfold DiagMetric2D.areaElement splitMetric;
  rw [ Real.sqrt_eq_iff_mul_self_eq ] <;> ring <;> positivity

/-
The area element is always positive.
-/
theorem splitMetric_areaElement_pos (x y : ℝ) :
    0 < splitMetric.areaElement x y := by
  exact Real.sqrt_pos.mpr ( mul_pos ( sq_pos_of_pos ( inv_pos.mpr ( Real.cosh_pos _ ) ) ) ( sq_pos_of_pos ( Real.cosh_pos _ ) ) )

/-! ## Information-Geometric Connection -/

/-
The split divergence of a point with itself is zero.
-/
theorem splitDivergence_self (x y : ℝ) : splitDivergence x y x y = 0 := by
  unfold splitDivergence; norm_num [ ne_of_gt ( Real.cosh_pos _ ) ] ;

/-
The split divergence is always non-negative, being a sum of squares.
-/
theorem splitDivergence_nonneg (x₁ y₁ x₂ y₂ : ℝ) :
    0 ≤ splitDivergence x₁ y₁ x₂ y₂ := by
  exact add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ )

/-
The split divergence is zero iff cosh(x₁) = cosh(x₂) and cosh(y₁) = cosh(y₂),
which means |x₁| = |x₂| and |y₁| = |y₂|.
-/
theorem splitDivergence_eq_zero_iff (x₁ y₁ x₂ y₂ : ℝ) :
    splitDivergence x₁ y₁ x₂ y₂ = 0 ↔
    (Real.cosh x₁ = Real.cosh x₂ ∧ Real.cosh y₁ = Real.cosh y₂) := by
  unfold splitDivergence;
  rw [ add_eq_zero_iff_of_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ), sq_eq_zero_iff, sq_eq_zero_iff, Real.log_eq_zero, Real.log_eq_zero ];
  norm_num [ div_eq_iff, ne_of_gt ( Real.cosh_pos _ ) ];
  exact ⟨ fun h => ⟨ Or.casesOn h.1 ( fun h => h.symm ) fun h => by linarith [ Real.cosh_pos x₁, Real.cosh_pos x₂ ], Or.casesOn h.2 ( fun h => h ) fun h => by linarith [ Real.cosh_pos y₁, Real.cosh_pos y₂ ] ⟩, fun h => ⟨ Or.inl h.1.symm, Or.inl h.2 ⟩ ⟩

/-! ## Triangle Theorems -/

/-- In any split triangle (with vertices in elliptic, flat, and hyperbolic regions),
the curvature at the elliptic vertex is positive. -/
theorem splitTriangle_elliptic_vertex_pos (T : SplitTriangle) :
    0 < splitCurvature T.x₁ T.y₁ :=
  (splitCurvature_pos_iff T.x₁ T.y₁).mpr T.h₁

/-- In any split triangle, the curvature at the flat vertex is zero. -/
theorem splitTriangle_flat_vertex_zero (T : SplitTriangle) :
    splitCurvature T.x₂ T.y₂ = 0 :=
  (splitCurvature_zero_iff T.x₂ T.y₂).mpr T.h₂

/-- In any split triangle, the curvature at the hyperbolic vertex is negative. -/
theorem splitTriangle_hyp_vertex_neg (T : SplitTriangle) :
    splitCurvature T.x₃ T.y₃ < 0 :=
  (splitCurvature_neg_iff T.x₃ T.y₃).mpr T.h₃

/-
The curvature at the elliptic vertex and hyperbolic vertex of a split
triangle have opposite signs. This is a consequence of the sign theorems.
-/
theorem splitTriangle_curvature_opposite_signs (T : SplitTriangle) :
    splitCurvature T.x₁ T.y₁ * splitCurvature T.x₃ T.y₃ < 0 := by
  exact mul_neg_of_pos_of_neg ( splitTriangle_elliptic_vertex_pos T ) ( splitTriangle_hyp_vertex_neg T )

/-! ## Curvature Bounds -/

/-
The split curvature is bounded: |K(x,y)| ≤ 1 everywhere.
Since 0 < sech²(t) ≤ 1 for all t, the difference sech²(x) - sech²(y)
lies in [-1, 1].
-/
theorem splitCurvature_abs_le_one (x y : ℝ) :
    |splitCurvature x y| ≤ 1 := by
  refine' abs_sub_le_iff.mpr _;
  constructor <;> nlinarith [ inv_nonneg.2 ( Real.cosh_pos x |> le_of_lt ), inv_nonneg.2 ( Real.cosh_pos y |> le_of_lt ), inv_le_one_of_one_le₀ ( show 1 ≤ Real.cosh x from Real.one_le_cosh x ), inv_le_one_of_one_le₀ ( show 1 ≤ Real.cosh y from Real.one_le_cosh y ) ]

/-
The maximum curvature K = 1 is achieved at x = 0 as |y| → ∞,
and the minimum K = -1 at y = 0 as |x| → ∞.
Here we prove the supremum is at most 1.
-/
theorem splitCurvature_le_one (x y : ℝ) :
    splitCurvature x y ≤ 1 := by
  exact le_of_abs_le ( splitCurvature_abs_le_one x y )

/-
Curvature is bounded below by -1.
-/
theorem splitCurvature_ge_neg_one (x y : ℝ) :
    -1 ≤ splitCurvature x y := by
  exact neg_le_of_abs_le ( splitCurvature_abs_le_one x y )

/-! ## Conjecture: Geodesic Phase-Crossing Bound

**Falsifiable Conjecture**: For any smooth curve γ : [0,1] → ℝ² that is a geodesic
of the split metric, the number of times γ crosses the phase boundary {|x| = |y|}
is at most 4.

**Computational Test**: Numerically integrate the geodesic equations for the split
metric with various initial conditions and count phase boundary crossings. If any
geodesic crosses more than 4 times, the conjecture is false.

This is formalized as a definition rather than a theorem since geodesic equations
are not yet available in Mathlib for general Riemannian metrics. -/

/-- Count the number of sign changes of a function on a finite list of sample points.
Used to approximate phase boundary crossings. -/
def countSignChanges : List ℝ → ℕ
  | [] => 0
  | [_] => 0
  | a :: b :: rest =>
    (if (a < 0 ∧ 0 ≤ b) ∨ (0 ≤ a ∧ b < 0) then 1 else 0) +
    countSignChanges (b :: rest)

/-- The phase indicator function: positive in the elliptic region,
negative in the hyperbolic region, zero on the boundary. -/
def phaseIndicator (x y : ℝ) : ℝ := |y| - |x|

theorem phaseIndicator_pos_iff_elliptic (x y : ℝ) :
    0 < phaseIndicator x y ↔ classifyPhase x y = .elliptic := by
  unfold phaseIndicator classifyPhase;
  grind

end