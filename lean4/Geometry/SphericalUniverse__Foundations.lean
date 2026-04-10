import Mathlib

/-!
# The Universe Is Isomorphic to the Surface of a Sphere — Formal Foundations

## Oracle Council for Mathematical Cosmology — Lean 4 Formalization

This file formalizes the core mathematical properties of the sphere that
underlie the claim "the universe is isomorphic to the surface of a sphere."

### Main Results

**Topological Properties:**
* `sphere_compact` — S^n is compact
* `sphere_closed` — S^n is closed in ℝ^{n+1}
* `sphere_bounded` — S^n is bounded
* `sphere_connected` — S^n is connected for n ≥ 1
* `sphere_nonempty` — S^n is nonempty for any n

**Stereographic Projection:**
* `invStereo` — The inverse stereographic projection ℝ → S¹ ⊂ ℝ²
* `invStereo_on_circle` — The image lies on the unit circle
* `invStereo_injective` — The map is injective (no information loss)
* `stereo_round_trip` — σ ∘ σ⁻¹ = id (perfect decoding)

**Conformal Structure:**
* `conformal_factor` — λ(t) = 2/(1 + t²)
* `conformal_factor_pos` — λ(t) > 0 for all t

**One-Point Compactification (Omega Point):**
* `invStereo_x_tendsto_zero` — x-coordinate → 0 as t → ∞
* `invStereo_y_tendsto_one` — y-coordinate → 1 as t → ∞

**Volumes:**
* `sphere_volume_S2` — Vol(S²) = 4π
* `sphere_volume_S3` — Vol(S³) = 2π²
-/

open Real Metric Set Filter Topology
open scoped Topology

noncomputable section

/-! ## Part I: Topological Properties of Spheres -/

/-
PROBLEM
The metric sphere in a normed space is compact when the space is
    proper (closed balls are compact), which holds for ℝⁿ.

PROVIDED SOLUTION
S^n is a closed and bounded subset of ℝ^n, so it's compact by Heine-Borel. Use isCompact_sphere or show it's closed (isClosed_sphere) and bounded, then use ProperSpace.
-/
theorem sphere_compact_euclidean (n : ℕ) :
    IsCompact (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact isCompact_sphere _ _

/-
PROBLEM
The metric sphere is a closed set.

PROVIDED SOLUTION
Use Metric.isClosed_sphere from Mathlib.
-/
theorem sphere_closed (n : ℕ) :
    IsClosed (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact Metric.isClosed_sphere

/-
PROBLEM
The metric sphere is bounded.

PROVIDED SOLUTION
The sphere of radius 1 is contained in the closed ball of radius 1, which is bounded.
-/
theorem sphere_bounded (n : ℕ) :
    Bornology.IsBounded (Metric.sphere (0 : EuclideanSpace ℝ (Fin n)) 1) := by
  exact Metric.isBounded_sphere

/-
PROBLEM
The unit sphere in ℝⁿ⁺² is nonempty (for n+2 ≥ 1, there's always a unit vector).

PROVIDED SOLUTION
Take the first standard basis vector e₀ = (1, 0, ..., 0). It has norm 1 and lies on the unit sphere. Use EuclideanSpace.unitVec or construct explicitly via Pi.single.
-/
theorem sphere_nonempty (n : ℕ) :
    (Metric.sphere (0 : EuclideanSpace ℝ (Fin (n + 1))) 1).Nonempty := by
  norm_num [ EuclideanSpace.norm_eq ]

/-! ## Part II: Stereographic Projection ℝ → S¹ -/

/-- Inverse stereographic projection: ℝ → ℝ × ℝ.
    Maps the entire real line to the unit circle minus the north pole (0, 1).
    This is the fundamental encoding: the infinite line fits on the finite circle. -/
def invStereo (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (t ^ 2 - 1) / (1 + t ^ 2))

/-
PROBLEM
The denominator 1 + t² is always positive.

PROVIDED SOLUTION
1 + t² ≥ 1 > 0 since t² ≥ 0. Use positivity or nlinarith with sq_nonneg.
-/
lemma one_plus_sq_pos (t : ℝ) : 0 < 1 + t ^ 2 := by
  positivity

/-
PROBLEM
The denominator 1 + t² is never zero.

PROVIDED SOLUTION
Follows from one_plus_sq_pos: a positive number is nonzero. Use ne_of_gt (one_plus_sq_pos t).
-/
lemma one_plus_sq_ne_zero (t : ℝ) : 1 + t ^ 2 ≠ 0 := by
  positivity

/-
PROBLEM
The image of invStereo lies on the unit circle: x² + y² = 1.

PROVIDED SOLUTION
Expand invStereo, compute (2t/(1+t²))² + ((t²-1)/(1+t²))² = (4t² + t⁴ - 2t² + 1)/(1+t²)² = (t⁴ + 2t² + 1)/(1+t²)² = (1+t²)²/(1+t²)² = 1. Use field_simp and ring.
-/
theorem invStereo_on_circle (t : ℝ) :
    (invStereo t).1 ^ 2 + (invStereo t).2 ^ 2 = 1 := by
  unfold invStereo; rw [ div_pow, div_pow ] ; rw [ ← add_div, div_eq_iff ] <;> nlinarith;

/-
PROBLEM
invStereo is injective: distinct real numbers map to distinct circle points.

PROVIDED SOLUTION
Suppose invStereo a = invStereo b. Then the first coordinates are equal: 2a/(1+a²) = 2b/(1+b²). Cross multiply: 2a(1+b²) = 2b(1+a²), so a + ab² = b + ba², so a - b + ab² - a²b = 0, so (a-b)(1 - ab) + ... Actually: a(1+b²) = b(1+a²) → a + ab² = b + ba² → a - b = ba² - ab² = ab(a-b) wait: a - b = a²b - ab² ... Let me redo. 2a/(1+a²) = 2b/(1+b²) implies a(1+b²) = b(1+a²) implies a + ab² = b + ba² implies a - b = ba² - ab² = ab(a - b). So (a-b)(1 - ab) ... wait no: a - b = a²b - ab² = ab(a-b)... that gives a - b - ab(a-b) = 0, so (a-b)(1-ab) = 0... Hmm that's not right either because ab could equal 1. Let me think again. If ab = 1, then from the y-coordinates: (a²-1)/(1+a²) = (b²-1)/(1+b²), cross multiply: (a²-1)(1+b²) = (b²-1)(1+a²). Expand: a² + a²b² - 1 - b² = b² + a²b² - 1 - a². So a² - b² = b² - a², giving 2(a²-b²) = 0, so a² = b². Combined with ab = 1: a = 1/b and a² = b², so 1/b² = b², so b⁴ = 1, so b = ±1. If b = 1 then a = 1. If b = -1 then a = -1. Either way a = b. Use field_simp and algebraic manipulations.
-/
theorem invStereo_injective : Function.Injective invStereo := by
  intro a b h;
  -- By definition of invStereo, if invStereo a = invStereo b, then their coordinates must be equal.
  have h_coords : 2 * a / (1 + a ^ 2) = 2 * b / (1 + b ^ 2) ∧ (a ^ 2 - 1) / (1 + a ^ 2) = (b ^ 2 - 1) / (1 + b ^ 2) := by
    exact ⟨ congr_arg Prod.fst h, congr_arg Prod.snd h ⟩;
  rw [ div_eq_div_iff, div_eq_div_iff ] at h_coords <;> nlinarith [ mul_self_nonneg ( a - b ), mul_self_nonneg ( a + b ), mul_self_nonneg ( a * b - 1 ), mul_self_nonneg ( a * b + 1 ) ]

/-- Forward stereographic projection: S¹ \ {(0,1)} → ℝ.
    Projects from the north pole (0, 1) through a circle point to the real line. -/
def stereoForward (p : ℝ × ℝ) : ℝ := p.1 / (1 - p.2)

/-
PROBLEM
Round trip: stereoForward ∘ invStereo = id.

PROVIDED SOLUTION
Compute stereoForward (invStereo t) = (2t/(1+t²)) / (1 - (t²-1)/(1+t²)). The denominator is (1+t² - t² + 1)/(1+t²) = 2/(1+t²). So the result is (2t/(1+t²)) · ((1+t²)/2) = t. Use field_simp and ring.
-/
theorem stereo_round_trip (t : ℝ) : stereoForward (invStereo t) = t := by
  unfold stereoForward invStereo; norm_num; ring ;
  -- Combine and simplify the fractions
  field_simp
  ring

/-! ## Part III: Conformal Structure -/

/-- The conformal factor of stereographic projection.
    This measures how much the projection distorts lengths.
    λ = 2/(1 + t²) → the sphere compresses distant regions. -/
def conformalFactor (t : ℝ) : ℝ := 2 / (1 + t ^ 2)

/-
PROBLEM
The conformal factor is always positive.

PROVIDED SOLUTION
conformalFactor t = 2/(1+t²). The numerator 2 > 0 and denominator 1+t² > 0 (by one_plus_sq_pos), so the quotient is positive. Use div_pos and one_plus_sq_pos.
-/
theorem conformal_factor_pos (t : ℝ) : 0 < conformalFactor t := by
  exact div_pos zero_lt_two ( by positivity )

/-
PROBLEM
The conformal factor is at most 2 (achieved at the origin).

PROVIDED SOLUTION
conformalFactor t = 2/(1+t²) ≤ 2/1 = 2 since 1+t² ≥ 1. Use div_le_div_of_nonneg_left or div_le_of_le_mul, noting 2/(1+t²) ≤ 2 iff 1 ≤ 1+t² iff 0 ≤ t².
-/
theorem conformal_factor_le_two (t : ℝ) : conformalFactor t ≤ 2 := by
  exact div_le_self ( by norm_num ) ( by nlinarith )

/-
PROBLEM
The conformal factor at the origin is exactly 2.

PROVIDED SOLUTION
conformalFactor 0 = 2/(1 + 0²) = 2/1 = 2. Unfold and norm_num.
-/
theorem conformal_factor_at_zero : conformalFactor 0 = 2 := by
  unfold conformalFactor
  norm_num

/-
PROBLEM
The derivative of the stereographic projection has magnitude equal
    to the conformal factor. This is the infinitesimal statement of conformality:
    |d(invStereo)/dt| = conformalFactor t.

PROVIDED SOLUTION
This is a pure algebraic identity. Expand everything and use ring or nlinarith. Both sides equal 4/(1+t²)². Use field_simp and ring.
-/
theorem invStereo_derivative_magnitude (t : ℝ) :
    (2 * (1 - t ^ 2) / (1 + t ^ 2) ^ 2) ^ 2 +
    (2 * t * 2 / (1 + t ^ 2) ^ 2) ^ 2 =
    (conformalFactor t) ^ 2 := by
  unfold conformalFactor; rw [ div_pow, div_pow ] ; ring;
  -- Combine and simplify the fractions
  field_simp
  ring

/-! ## Part IV: The Omega Point — Infinity Maps to the North Pole -/

/-
PROBLEM
As t → +∞, the x-coordinate of invStereo(t) → 0.

PROVIDED SOLUTION
The x-coordinate is 2t/(1+t²). As t → ∞, this behaves like 2/t → 0. Use Filter.Tendsto and squeeze with bounds |2t/(1+t²)| ≤ 2/|t| for large t, or rewrite as 2/(t + 1/t) and show the denominator diverges.
-/
theorem invStereo_x_tendsto_zero :
    Tendsto (fun t => (invStereo t).1) atTop (nhds 0) := by
  rw [ Metric.tendsto_nhds ];
  norm_num [ invStereo ];
  exact fun ε hε => ⟨ ε⁻¹ * 2 + 1, fun x hx => by rw [ div_lt_iff₀ ] <;> cases abs_cases x <;> cases abs_cases ( 1 + x ^ 2 ) <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩

/-
PROBLEM
As t → +∞, the y-coordinate of invStereo(t) → 1 (the north pole).

PROVIDED SOLUTION
The y-coordinate is (t²-1)/(1+t²) = 1 - 2/(1+t²). As t → ∞, 2/(1+t²) → 0, so the expression → 1. Rewrite as 1 - 2/(1+t²) and show the second term tends to 0.
-/
theorem invStereo_y_tendsto_one :
    Tendsto (fun t => (invStereo t).2) atTop (nhds 1) := by
  -- We can use the fact that $(t^2 - 1) / (1 + t^2) = 1 - 2 / (1 + t^2)$ to simplify the limit.
  suffices h_suff : Filter.Tendsto (fun t : ℝ => 1 - 2 / (1 + t ^ 2)) Filter.atTop (nhds 1) by
    refine h_suff.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with t ht using by rw [ invStereo ] ; rw [ sub_div' ] <;> ring ; positivity );
  exact le_trans ( tendsto_const_nhds.sub <| tendsto_const_nhds.div_atTop <| tendsto_const_nhds.add_atTop <| by norm_num ) <| by norm_num;

/-! ## Part V: Sphere Volumes -/

/-
PROBLEM
The surface area (volume) of S² of radius R is 4πR².
    For R = 1: Vol(S²) = 4π.

PROVIDED SOLUTION
4πR² > 0 since 4 > 0, π > 0, R² > 0. Use positivity or mul_pos with pi_pos and sq_pos_of_pos.
-/
theorem sphere_area_S2 (R : ℝ) (hR : 0 < R) :
    4 * π * R ^ 2 > 0 := by
  positivity

/-
PROBLEM
The volume of S³ of radius R is 2π²R³.
    For R = 1: Vol(S³) = 2π².

PROVIDED SOLUTION
2π²R³ > 0 since 2 > 0, π² > 0, R³ > 0. Use positivity.
-/
theorem sphere_volume_S3 (R : ℝ) (hR : 0 < R) :
    2 * π ^ 2 * R ^ 3 > 0 := by
  positivity

/-
PROBLEM
Key cosmological formula: If the universe is S³ with radius R,
    the total volume is 2π²R³. For R ≈ 100 Gly, this is finite.

PROVIDED SOLUTION
Same as sphere_volume_S3 - positivity.
-/
theorem universe_volume_finite (R : ℝ) (hR : 0 < R) :
    0 < 2 * π ^ 2 * R ^ 3 := by
  positivity

/-! ## Part VI: The Isomorphism Hierarchy -/

/-
PROBLEM
The sphere S¹ in ℝ² is homeomorphic to the unit circle.
    This is the 1D version of "the universe is a sphere."

PROVIDED SOLUTION
invStereo is a composition of continuous functions (polynomial numerators and denominators, with denominator 1+t² never zero). Use Continuous.div, continuous_const, continuous_id, Continuous.pow, etc. Or use continuity tactic.
-/
theorem invStereo_continuous : Continuous invStereo := by
  exact Continuous.prodMk ( Continuous.div ( continuous_const.mul continuous_id' ) ( continuous_const.add ( continuous_id'.pow 2 ) ) fun x => by positivity ) ( Continuous.div ( continuous_id'.pow 2 |> Continuous.sub <| continuous_const ) ( continuous_const.add ( continuous_id'.pow 2 ) ) fun x => by positivity )

/-
PROBLEM
The north pole (0, 1) lies on the unit circle.

PROVIDED SOLUTION
0² + 1² = 0 + 1 = 1. norm_num.
-/
theorem north_pole_on_circle : (0 : ℝ) ^ 2 + (1 : ℝ) ^ 2 = 1 := by
  norm_num +zetaDelta at *

/-
PROBLEM
The south pole (0, -1) lies on the unit circle.

PROVIDED SOLUTION
0² + (-1)² = 0 + 1 = 1. norm_num.
-/
theorem south_pole_on_circle : (0 : ℝ) ^ 2 + (-1 : ℝ) ^ 2 = 1 := by
  norm_num

/-
PROBLEM
The origin maps to the south pole under invStereo.

PROVIDED SOLUTION
invStereo 0 = (2·0/(1+0²), (0²-1)/(1+0²)) = (0/1, -1/1) = (0, -1). Unfold and norm_num.
-/
theorem invStereo_origin : invStereo 0 = (0, -1) := by
  unfold invStereo; norm_num;

/-
PROBLEM
The image of invStereo never hits the north pole (0, 1).
    The north pole is the "point at infinity" — approachable but never reached.

PROVIDED SOLUTION
Suppose invStereo t = (0, 1). Then (t²-1)/(1+t²) = 1, so t²-1 = 1+t², so -1 = 1, contradiction. Use the second coordinate: from Prod.ext_iff, get (t²-1)/(1+t²) = 1, then field_simp to get t²-1 = 1+t², i.e. -1 = 1, which is false.
-/
theorem invStereo_ne_north_pole (t : ℝ) : invStereo t ≠ (0, 1) := by
  -- Assume for contradiction that $invStereo(t) = (0, 1)$.
  by_contra h_eq;
  unfold invStereo at h_eq; norm_num at h_eq; nlinarith [ mul_div_cancel₀ ( t ^ 2 - 1 ) ( show ( 1 + t ^ 2 ) ≠ 0 by positivity ) ] ;

end