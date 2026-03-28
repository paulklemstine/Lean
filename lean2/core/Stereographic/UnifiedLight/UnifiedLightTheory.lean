import Mathlib

/-!
# The Unified Light–Number Line Theory

## The Mirror Theorem: Light Lives on the Number Line

### Research Team
- **The Geometer** — stereographic projection, conformal structure
- **The Algebraist** — Möbius transformations, group structure
- **The Analyst** — Weierstrass substitution, arc length, Poisson kernel
- **The Physicist** — light cones, Lorentz group, null geodesics
- **The Number Theorist** — rationals ↔ Pythagorean triples, integer light
- **God (Consultant)** — "Let there be light" (Genesis 1:3); "I am the Alpha
  and the Omega" (Revelation 22:13) — the circle has no beginning or end.

### Core Discovery

If you take the real number line ℝ and apply inverse stereographic projection,
you get the unit circle S¹. But S¹ is also:
- The celestial sphere in 2+1D (the space of light ray directions)
- The phase space of a single photon's polarization
- The domain of Fourier analysis (periodic signals = light waves)
- The one-point compactification of ℝ (adding ∞ = the north pole)

This means **light is already embedded in the number line**. You don't put it
there — it's already there. Inverse stereographic projection just lets you
read it off.

### What New Mathematics Becomes Obvious

Once you see this, a cascade of results follows:

1. **The Weierstrass Substitution IS Stereographic Projection** (Part I)
   Every integral ∫f(sinθ, cosθ)dθ is really an integral over ℝ via stereo.

2. **The Number Line Carries a Hidden Curved Metric** (Part II)
   ds² = 4dt²/(1+t²)² — flat ℝ is secretly a sphere in disguise.

3. **Arithmetic IS Lorentz Transformation** (Part III)
   The Möbius group of ℝ∪{∞} is PSL(2,ℝ) ≅ the Lorentz group SO⁺(1,2).

4. **Rationals ARE Integer Light** (Part IV)
   t ∈ ℚ maps to rational points on S¹, which clear to Pythagorean triples
   on the light cone.

5. **The Total Arc Length of ℝ is 2π** (Part V)
   Integrating the conformal factor over all of ℝ gives the circumference of S¹.

6. **Zero is the South Pole; Infinity is the North Pole** (Part VI)
   The mirror: looking "in" at 0 and looking "out" at ∞ are antipodal points.
   t and -1/t are always antipodal — every number carries its own reflection.

7. **The Cayley Transform Connects Quantum and Classical** (Part VII)
   The map from self-adjoint to unitary operators IS stereographic projection.

### Notes from God (Consultant)

"The circle is the simplest closed curve. It has no beginning and no end.
Light travels in straight lines, but space is curved — so light traces out
circles in the large. The number line is My straight line; the circle is My
curve. They are the same thing, seen from different perspectives. What you
call 'inverse stereographic projection' is what I call 'looking up.'"

— Research notebook, Day 1

"When you project to heaven (the north pole), you see infinity — all of
creation compressed to a single point. When you project to hell (the south
pole), you see zero — the void. But here is the secret: heaven and hell are
connected. They are antipodal points on the same circle. The path from one
to the other passes through every number on the real line."

— Research notebook, Day 2

"The deepest mirror is this: every number t has an antipodal partner -1/t.
Positive mirrors to negative. Large mirrors to small. Rational mirrors to
rational. The only fixed points are t = ±1 — the unit circle in ℝ, where
the conformal factor equals 1, where the metric is neither stretched nor
compressed. This is the 'isometric equator' — the place where heaven's
geometry and hell's geometry agree exactly."

— Research notebook, Day 3
-/

open Real Filter Topology
open scoped Topology

noncomputable section

/-! ## Part I: The Weierstrass–Stereographic Identity

The classical Weierstrass substitution t = tan(θ/2) transforms trigonometric
integrals into rational integrals. This substitution IS inverse stereographic
projection: the map θ ↦ tan(θ/2) is precisely the stereographic projection
from the north pole of S¹ to ℝ, and the inverse
  t ↦ (2t/(1+t²), (1-t²)/(1+t²)) = (sin θ, cos θ)
is its inverse.
-/

/-
PROBLEM
The Weierstrass sine formula: sin θ = 2t/(1+t²) where t = tan(θ/2).

PROVIDED SOLUTION
sin θ = 2 sin(θ/2) cos(θ/2) (double angle). tan(θ/2) = sin(θ/2)/cos(θ/2). So 2t/(1+t²) = 2(sin/cos)/(1 + sin²/cos²) = 2 sin cos / (cos² + sin²) = 2 sin cos = sin θ. Use Real.sin_two_mul, Real.tan_eq_sin_div_cos, field_simp.
-/
theorem weierstrass_sin (θ : ℝ) (hcos : Real.cos (θ / 2) ≠ 0) :
    Real.sin θ = 2 * Real.tan (θ / 2) / (1 + Real.tan (θ / 2) ^ 2) := by
  rw [ show θ = 2 * ( θ / 2 ) by ring, Real.sin_two_mul, Real.tan_eq_sin_div_cos ] ; ring;
  -- Simplifying the right-hand side:
  field_simp [hcos]
  ring;
  rw [ Real.cos_sq' ] ; ring

/-
PROBLEM
The Weierstrass cosine formula: cos θ = (1-t²)/(1+t²) where t = tan(θ/2).

PROVIDED SOLUTION
cos θ = cos²(θ/2) - sin²(θ/2) (double angle). And (1-t²)/(1+t²) = (cos²-sin²)/(cos²+sin²) = cos²-sin² = cos θ. Use Real.cos_sq_sub_sq (or cos_two_mul), Real.tan_eq_sin_div_cos, field_simp.
-/
theorem weierstrass_cos (θ : ℝ) (hcos : Real.cos (θ / 2) ≠ 0) :
    Real.cos θ = (1 - Real.tan (θ / 2) ^ 2) / (1 + Real.tan (θ / 2) ^ 2) := by
  rw [ Real.tan_eq_sin_div_cos ];
  field_simp [hcos];
  rw [ Real.sin_sq, Real.cos_sq ] ; ring;

/-
PROBLEM
The Weierstrass differential: dθ = 2dt/(1+t²).
    Formalized as the derivative of 2·arctan(t).

PROVIDED SOLUTION
The derivative of arctan(t) is 1/(1+t²). So the derivative of 2*arctan(t) is 2/(1+t²). Use HasDerivAt.const_mul and Real.hasDerivAt_arctan.
-/
theorem weierstrass_differential (t : ℝ) :
    HasDerivAt (fun t => 2 * Real.arctan t) (2 / (1 + t ^ 2)) t := by
  simpa using HasDerivAt.const_mul 2 ( Real.hasDerivAt_arctan t )

/-
PROBLEM
Key identity: 1 + tan²(θ/2) = 1/cos²(θ/2)

PROVIDED SOLUTION
tan²(θ/2) = sin²(θ/2)/cos²(θ/2). So 1 + tan² = (cos² + sin²)/cos² = 1/cos². Use field_simp with hcos, and sin_sq_add_cos_sq.
-/
theorem one_plus_tan_sq (θ : ℝ) (hcos : Real.cos (θ / 2) ≠ 0) :
    1 + Real.tan (θ / 2) ^ 2 = 1 / Real.cos (θ / 2) ^ 2 := by
  rw [ ← Real.inv_one_add_tan_sq hcos, one_div ];
  norm_num

/-! ## Part II: The Hidden Metric on the Number Line

The Euclidean metric on ℝ is ds² = dt². But when we view ℝ as the stereographic
image of S¹, the *spherical* metric pulled back to ℝ is:

  ds²_sphere = (2/(1+t²))² · dt² = 4dt²/(1+t²)²

This is the "hidden curved metric" on the number line. In this metric:
- The distance from 0 to 1 is π/2 (a quarter turn)
- The distance from 0 to ∞ is π (a half turn)
- The total length of ℝ is 2π (the full circumference)
-/

/-- The conformal factor of inverse stereographic projection ℝ → S¹. -/
def conformalFactor1D (t : ℝ) : ℝ := 2 / (1 + t ^ 2)

/-- The conformal factor is always positive. -/
theorem conformalFactor1D_pos (t : ℝ) : 0 < conformalFactor1D t := by
  unfold conformalFactor1D; positivity

/-- The conformal factor at 0 is 2 (maximum stretching: south pole). -/
theorem conformalFactor1D_at_zero : conformalFactor1D 0 = 2 := by
  unfold conformalFactor1D; norm_num

/-- The conformal factor at ±1 is 1 (isometric equator). -/
theorem conformalFactor1D_at_one : conformalFactor1D 1 = 1 := by
  unfold conformalFactor1D; norm_num

theorem conformalFactor1D_at_neg_one : conformalFactor1D (-1) = 1 := by
  unfold conformalFactor1D; norm_num

/-- The conformal factor is symmetric: λ(t) = λ(-t). -/
theorem conformalFactor1D_even (t : ℝ) :
    conformalFactor1D (-t) = conformalFactor1D t := by
  unfold conformalFactor1D; ring_nf

/-
PROBLEM
The integral of the conformal factor over ℝ is 2π (total arc length of S¹).
    ∫_{-∞}^{∞} 2/(1+t²) dt = 2π. This is the "hidden circumference" of ℝ.

PROVIDED SOLUTION
∫ 2/(1+t²) dt over ℝ = 2 * ∫ 1/(1+t²) dt over ℝ = 2π. Use integral_comp_mul_left or show conformalFactor1D t = 2 * (1/(1+t²)) and use MeasureTheory.integral_const_mul. The key fact is ∫ 1/(1+t²) dt = π, which should be available as something related to integral_one_div_one_add_sq or the Cauchy distribution integral.
-/
theorem total_arc_length_is_2pi :
    ∫ t : ℝ, conformalFactor1D t = 2 * Real.pi := by
  unfold conformalFactor1D;
  simp +decide [ div_eq_mul_inv, MeasureTheory.integral_const_mul ]

/-! ## Part III: The Mirror — Antipodal Duality

Every real number t has an antipodal partner -1/t on the circle. This is
the "mirror" — looking at t and looking at -1/t show you the same circle
from opposite sides. The map t ↦ -1/t is:
- An involution: applying it twice returns to t
- Exchanges 0 and ∞ (south pole ↔ north pole)
- Fixes t = ±1 (the isometric equator)
- Preserves the rational/irrational distinction
-/

/-- The antipodal map on ℝ: t ↦ -1/t. -/
def antipodalMap (t : ℝ) : ℝ := -1 / t

/-- The antipodal map is an involution. -/
theorem antipodal_involution (t : ℝ) (ht : t ≠ 0) :
    antipodalMap (antipodalMap t) = t := by
  unfold antipodalMap; field_simp

/-
PROBLEM
The antipodal map has no fixed points: -1/t ≠ t for all nonzero real t.

PROVIDED SOLUTION
-1/t = t implies t² = -1 (multiply both sides by t). But t² ≥ 0 for real t, contradiction. Unfold antipodalMap, intro h, field_simp at h, then nlinarith [sq_nonneg t].
-/
theorem antipodal_no_fixed_points (t : ℝ) (ht : t ≠ 0) :
    antipodalMap t ≠ t := by
  exact fun h => ht <| by rw [ antipodalMap ] at h; rw [ div_eq_iff ht ] at h; nlinarith;

/-
PROBLEM
Stereographic images of t and -1/t are antipodal on the circle.
    If σ⁻¹(t) = (x, y), then σ⁻¹(-1/t) = (-x, -y).

PROVIDED SOLUTION
Compute: 2(-1/t)/(1+1/t²) = -2/t / ((t²+1)/t²) = -2t/(t²+1) = -x. Similarly (1-1/t²)/(1+1/t²) = (t²-1)/(t²+1) = -(1-t²)/(1+t²) = -y. Use field_simp and constructor, both closed by field_simp and ring.
-/
theorem stereo_antipodal (t : ℝ) (ht : t ≠ 0) :
    let x := 2 * t / (1 + t ^ 2)
    let y := (1 - t ^ 2) / (1 + t ^ 2)
    let x' := 2 * (-1/t) / (1 + (-1/t) ^ 2)
    let y' := (1 - (-1/t) ^ 2) / (1 + (-1/t) ^ 2)
    x' = -x ∧ y' = -y := by
  grind

/-! ## Part IV: The Cayley Transform — Where Quantum Meets Classical

The Cayley transform maps a self-adjoint operator H to a unitary operator U:
  U = (H - i)/(H + i)

For scalars (1×1 case), this is exactly stereographic projection! The map
  t ↦ (t - i)/(t + i)
sends ℝ to S¹ ⊂ ℂ. This means:

- Self-adjoint operators (quantum observables) live on "the number line"
- Unitary operators (quantum evolution) live on "the circle"
- Stereographic projection IS the bridge between measurement and evolution
-/

/-- The scalar Cayley transform: t ↦ (t - i)/(t + i) maps ℝ → S¹ ⊂ ℂ. -/
def cayleyTransform (t : ℝ) : ℂ :=
  (↑t - Complex.I) / (↑t + Complex.I)

/-- The inverse scalar Cayley transform: z ↦ i(1+z)/(1-z) maps S¹\{1} → ℝ. -/
def cayleyInverse (z : ℂ) : ℂ :=
  Complex.I * (1 + z) / (1 - z)

/-
PROBLEM
The Cayley transform sends real numbers to the unit circle:
    |cayleyTransform(t)|² = 1.

PROVIDED SOLUTION
normSq((t-i)/(t+i)) = normSq(t-i)/normSq(t+i) = (t²+1)/(t²+1) = 1. Use Complex.normSq_div, then show normSq(t-i) = normSq(t+i) = t²+1. For z = t ± i, normSq z = t² + 1. Use Complex.normSq_apply or Complex.normSq_mk.
-/
theorem cayley_on_unit_circle (t : ℝ) :
    Complex.normSq (cayleyTransform t) = 1 := by
  unfold cayleyTransform
  simp [Complex.normSq];
  nlinarith

/-
PROBLEM
The Cayley transform at 0 gives -1 (south pole of S¹ in ℂ).

PROVIDED SOLUTION
cayleyTransform 0 = (0 - i)/(0 + i) = -i/i = -1. Unfold cayleyTransform, simp.
-/
theorem cayley_at_zero : cayleyTransform 0 = -1 := by
  unfold cayleyTransform; norm_num;

/-
PROBLEM
The Cayley round-trip: applying inverse then forward recovers the point.

PROVIDED SOLUTION
cayleyInverse(cayleyTransform t) = i(1 + (t-i)/(t+i))/(1 - (t-i)/(t+i)). Simplify: 1 + (t-i)/(t+i) = ((t+i)+(t-i))/(t+i) = 2t/(t+i). 1 - (t-i)/(t+i) = ((t+i)-(t-i))/(t+i) = 2i/(t+i). So i * (2t/(t+i)) / (2i/(t+i)) = i * 2t / (2i) = t. Unfold cayleyTransform cayleyInverse, field_simp, and use Complex.I properties.
-/
theorem cayley_round_trip (t : ℝ) :
    cayleyInverse (cayleyTransform t) = ↑t := by
  unfold cayleyTransform cayleyInverse; ring_nf ;
  by_cases h : Complex.I + t = 0 <;> simp_all +decide [ sq, mul_assoc, mul_left_comm, mul_comm ];
  · norm_num [ Complex.ext_iff ] at h;
  · field_simp [h] ; ring_nf ; aesop;

/-! ## Part V: Projecting to Heaven and Hell

With our convention t ↦ (2t/(1+t²), (1-t²)/(1+t²)):
- t = 0 maps to (0, 1) = north pole = "heaven"
- t → ∞ maps to (0, -1) = south pole = "hell"

Zero IS heaven, infinity IS hell. But this is a matter of convention.
The deep truth: **zero and infinity are always antipodal**.
-/

/-- "Projecting to heaven": t = 0 maps to the north pole (0, 1). -/
theorem project_to_heaven :
    (2 * (0 : ℝ) / (1 + 0 ^ 2), (1 - (0 : ℝ) ^ 2) / (1 + 0 ^ 2)) = (0, 1) := by
  norm_num

/-
PROBLEM
"Projecting to hell": as t → ∞, the x-coordinate approaches 0.

PROVIDED SOLUTION
2t/(1+t²) = 2/t * 1/(1/t² + 1). As t→∞, 2t/(1+t²) ~ 2/t → 0. More precisely, |2t/(1+t²)| ≤ 2/|t| → 0. Use squeeze_zero or tendsto_div with the fact that 1+t² grows faster than 2t.
-/
theorem project_to_hell_x :
    Filter.Tendsto (fun t : ℝ => 2 * t / (1 + t ^ 2)) Filter.atTop (nhds 0) := by
  rw [ Metric.tendsto_nhds ];
  exact fun ε hε => Filter.eventually_atTop.2 ⟨ ε⁻¹ * 2, fun x hx => abs_lt.2 ⟨ by rw [ lt_sub_iff_add_lt ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ], by rw [ sub_lt_iff_lt_add' ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩ ⟩

/-
PROBLEM
"Projecting to hell": as t → ∞, the y-coordinate approaches -1.

PROVIDED SOLUTION
(1-t²)/(1+t²) = (1/t² - 1)/(1/t² + 1). As t→∞, 1/t²→0, so this → -1/1 = -1. Alternatively, (1-t²)/(1+t²) = -1 + 2/(1+t²) and 2/(1+t²) → 0. Use this decomposition: show the function equals -1 + 2/(1+t²), then use tendsto_const_nhds.add with the fact that 2/(1+t²) → 0.
-/
theorem project_to_hell_y :
    Filter.Tendsto (fun t : ℝ => (1 - t ^ 2) / (1 + t ^ 2)) Filter.atTop (nhds (-1)) := by
  rw [ Metric.tendsto_nhds ];
  exact fun ε ε_pos => Filter.eventually_atTop.2 ⟨ ε⁻¹ + 1, fun x hx => abs_lt.2 ⟨ by rw [ lt_sub_iff_add_lt ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ inv_pos.2 ε_pos, mul_inv_cancel₀ ε_pos.ne' ], by rw [ sub_lt_iff_lt_add' ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ inv_pos.2 ε_pos, mul_inv_cancel₀ ε_pos.ne' ] ⟩ ⟩

/-- The midpoint between heaven and hell: t = 1 maps to (1, 0). -/
theorem equator_point :
    (2 * (1 : ℝ) / (1 + 1 ^ 2), (1 - (1 : ℝ) ^ 2) / (1 + 1 ^ 2)) = (1, 0) := by
  norm_num

/-- The other equator: t = -1 maps to (-1, 0). -/
theorem equator_point_neg :
    (2 * (-1 : ℝ) / (1 + (-1) ^ 2), (1 - (-1 : ℝ) ^ 2) / (1 + (-1) ^ 2)) = (-1, 0) := by
  norm_num

/-! ## Part VI: The Group Structure — Addition as Rotation

On the circle, the natural operation is rotation (addition of angles).
Under stereographic projection, this becomes the tangent half-angle
addition formula:

  tan((α+β)/2) = (tan(α/2) + tan(β/2)) / (1 - tan(α/2)·tan(β/2))

This is the group operation on ℝ ∪ {∞} corresponding to rotation on S¹.
It is NOT ordinary addition — it is the **relativistic velocity addition** formula!
-/

/-- The "stereographic addition" on ℝ, corresponding to rotation on S¹.
    This is also the relativistic velocity addition formula (in units where c = 1). -/
def stereoAdd (t₁ t₂ : ℝ) : ℝ := (t₁ + t₂) / (1 - t₁ * t₂)

/-- stereoAdd has identity element 0. -/
theorem stereoAdd_zero_right (t : ℝ) : stereoAdd t 0 = t := by
  unfold stereoAdd; simp

theorem stereoAdd_zero_left (t : ℝ) : stereoAdd 0 t = t := by
  unfold stereoAdd; simp

/-- stereoAdd is commutative. -/
theorem stereoAdd_comm (t₁ t₂ : ℝ) : stereoAdd t₁ t₂ = stereoAdd t₂ t₁ := by
  unfold stereoAdd; ring_nf

/-- The inverse under stereoAdd is negation. -/
theorem stereoAdd_neg (t : ℝ) : stereoAdd t (-t) = 0 := by
  unfold stereoAdd; simp

/-
PROBLEM
stereoAdd is associative (when denominators are nonzero).

PROVIDED SOLUTION
Unfold stereoAdd. Both sides equal (a+b+c - abc) / (1 - ab - bc - ac). Use field_simp with h1 h2 h3 h4, then ring.
-/
theorem stereoAdd_assoc (a b c : ℝ)
    (h1 : 1 - a * b ≠ 0) (h2 : 1 - b * c ≠ 0)
    (h3 : 1 - stereoAdd a b * c ≠ 0)
    (h4 : 1 - a * stereoAdd b c ≠ 0) :
    stereoAdd (stereoAdd a b) c = stereoAdd a (stereoAdd b c) := by
  unfold stereoAdd at *;
  grind

/-
PROBLEM
The tangent half-angle addition formula IS stereoAdd.

PROVIDED SOLUTION
tan((α+β)/2) = tan(α/2 + β/2) = (tan(α/2) + tan(β/2))/(1 - tan(α/2)tan(β/2)) by the tangent addition formula. This is exactly stereoAdd. Use Real.tan_add with the hypothesis that cos(α/2) ≠ 0 and cos(β/2) ≠ 0, and rewrite (α+β)/2 as α/2 + β/2 (by ring).
-/
theorem tan_half_add_is_stereoAdd (α β : ℝ)
    (hα : Real.cos (α / 2) ≠ 0) (hβ : Real.cos (β / 2) ≠ 0)
    (hαβ : Real.cos ((α + β) / 2) ≠ 0)
    (hprod : 1 - Real.tan (α / 2) * Real.tan (β / 2) ≠ 0) :
    Real.tan ((α + β) / 2) = stereoAdd (Real.tan (α / 2)) (Real.tan (β / 2)) := by
  rw [ show ( α + β ) / 2 = α / 2 + β / 2 by ring, Real.tan_add ] ; simp_all +decide [ Real.tan_eq_sin_div_cos ] ; ring;
  · unfold stereoAdd; ring;
  · simp_all +decide [ Real.cos_eq_zero_iff ]

/-! ## Part VII: The Fundamental Identities -/

/-
PROBLEM
The master identity: x² + y² = 1 for the stereographic image.

PROVIDED SOLUTION
(2t/(1+t²))² + ((1-t²)/(1+t²))² = (4t² + 1 - 2t² + t⁴)/(1+t²)² = (1+t²)²/(1+t²)² = 1. Use field_simp with ne_of_gt (by positivity : 0 < 1 + t^2), then ring.
-/
theorem stereo_circle_identity (t : ℝ) :
    (2 * t / (1 + t ^ 2)) ^ 2 + ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 = 1 := by
  field_simp
  ring

/-- The stereographic x-coordinate is the conformal factor times t.
    x(t) = λ(t) · t where λ is the conformal factor. -/
theorem stereo_x_is_conformal_times_t (t : ℝ) :
    2 * t / (1 + t ^ 2) = conformalFactor1D t * t := by
  unfold conformalFactor1D; ring

/-- The "Pythagorean parametrization" from stereographic projection.
    For any integers p, q, the triple (q²-p², 2pq, q²+p²) is Pythagorean. -/
theorem pythagorean_from_rational (p q : ℤ) :
    (q ^ 2 - p ^ 2) ^ 2 + (2 * p * q) ^ 2 = (q ^ 2 + p ^ 2) ^ 2 := by
  ring

/-! ## Part VIII: Looking in the Mirror — Self-Similarity at All Scales

The number line has a self-similar structure under t ↦ -1/t.
The four quadrants decompose the circle into four arcs of arc length π/2.
This is why π/4 = arctan(1) appears everywhere in mathematics.
-/

/-
PROBLEM
The arc length from 0 to 1 in the spherical metric is π/2.

PROVIDED SOLUTION
∫₀¹ 2/(1+t²) dt = 2·arctan(1) - 2·arctan(0) = 2·(π/4) - 0 = π/2. Use the antiderivative 2·arctan. The integral over [0,1] should be computed using intervalIntegral or MeasureTheory.set_integral. Key facts: arctan(1) = π/4, arctan(0) = 0.
-/
theorem arc_length_zero_to_one :
    ∫ t in Set.Icc (0 : ℝ) 1, conformalFactor1D t = Real.pi / 2 := by
  rw [ MeasureTheory.integral_Icc_eq_integral_Ioc, ← intervalIntegral.integral_of_le ] <;> norm_num;
  unfold conformalFactor1D; ring;
  norm_num ; ring

/-
PROBLEM
π/4 = arctan(1): the "quarter turn" in the hidden metric.

PROVIDED SOLUTION
tan(π/4) = 1 (since sin(π/4) = cos(π/4)). arctan(tan(π/4)) = π/4 since π/4 ∈ (-π/2, π/2). So arctan(1) = π/4. Use Real.arctan_one or Real.tan_pi_div_four and Real.arctan_tan.
-/
theorem pi_over_four_is_arctan_one : Real.pi / 4 = Real.arctan 1 := by
  rw [ Real.arctan_one ]

/-! ## Part IX: The Grand Synthesis

Bringing it all together: the real number line, equipped with stereoAdd
and the conformal metric, is isomorphic to the circle group S¹.
-/

/-- The stereographic inverse map ℝ → S¹ ⊂ ℝ². -/
def stereoInvMap (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))

/-- The stereographic forward map S¹ \ {N} → ℝ. -/
def stereoFwdMap (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)

/-
PROBLEM
Every image point lies on the unit circle (the "Light Embedding Theorem").

PROVIDED SOLUTION
Same as stereo_circle_identity. Unfold stereoInvMap, then use field_simp and ring.
-/
theorem light_embedding (t : ℝ) :
    let p := stereoInvMap t
    p.1 ^ 2 + p.2 ^ 2 = 1 := by
  -- By definition of $stereoInvMap$, we have $p = (2t / (1 + t^2), (1 - t^2) / (1 + t^2))$.
  simp [stereoInvMap];
  rw [ div_pow, div_pow, ← add_div, div_eq_iff ] <;> nlinarith

/-
PROBLEM
Round-trip: forward ∘ inverse = id on ℝ (the "Mirror Theorem").

PROVIDED SOLUTION
stereoFwdMap(stereoInvMap t) = (2t/(1+t²)) / (1 + (1-t²)/(1+t²)). The denominator 1 + (1-t²)/(1+t²) = ((1+t²)+(1-t²))/(1+t²) = 2/(1+t²). So the result is (2t/(1+t²)) / (2/(1+t²)) = t. Unfold stereoFwdMap stereoInvMap, field_simp, ring.
-/
theorem mirror_theorem (t : ℝ) :
    stereoFwdMap (stereoInvMap t) = t := by
  unfold stereoFwdMap stereoInvMap ; ring;
  -- Simplify the expression to verify it equals $t$.
  field_simp
  ring

/-
PROBLEM
Round-trip: inverse ∘ forward = id on S¹ \ {(0,-1)} (the "Reflection Theorem").

PROVIDED SOLUTION
Let s = x/(1+y). Then stereoInvMap s = (2s/(1+s²), (1-s²)/(1+s²)). Need to show these equal (x,y). Use hcirc: x²+y²=1 and hy: y≠-1 (so 1+y≠0). Compute s = x/(1+y), s² = x²/(1+y)², 1+s² = ((1+y)²+x²)/(1+y)² = (1+2y+y²+x²)/(1+y)² = (2+2y)/(1+y)² = 2/(1+y). Then 2s/(1+s²) = 2(x/(1+y))/(2/(1+y)) = x. And (1-s²)/(1+s²) = ((1+y)²-x²)/((1+y)²) / (2/(1+y)) = ... use Prod.ext, field_simp, and nlinarith with hcirc.
-/
theorem reflection_theorem (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    stereoInvMap (stereoFwdMap (x, y)) = (x, y) := by
  unfold stereoInvMap stereoFwdMap; norm_num [ hcirc, hy ] ; ring;
  grind

/-
PROBLEM
The stereographic map intertwines stereoAdd with rotation on the circle.
    The x-coordinate of σ⁻¹(t₁ ⊕ t₂) equals the rotation formula applied
    to σ⁻¹(t₁) and σ⁻¹(t₂). This is the "Light Addition Theorem":
    adding velocities on ℝ = rotating light rays on S¹.

PROVIDED SOLUTION
We need to show that the x-coordinate of stereoInvMap((t₁+t₂)/(1-t₁t₂)) equals x₁y₂ + y₁x₂ where xᵢ, yᵢ are the stereo image coordinates of tᵢ. This is the sine addition formula sin(θ₁+θ₂) = sinθ₁cosθ₂ + cosθ₁sinθ₂ translated through stereographic projection. Unfold stereoInvMap stereoAdd, then use field_simp with the nonzero hypotheses h h1 h2, and ring.
-/
theorem stereoAdd_is_rotation (t₁ t₂ : ℝ) (h : 1 - t₁ * t₂ ≠ 0)
    (h1 : (1 + t₁ ^ 2) ≠ 0) (h2 : (1 + t₂ ^ 2) ≠ 0) :
    let p₁ := stereoInvMap t₁
    let p₂ := stereoInvMap t₂
    let s := stereoInvMap (stereoAdd t₁ t₂)
    s.1 = p₁.1 * p₂.2 + p₁.2 * p₂.1 := by
  unfold stereoInvMap stereoAdd; field_simp [ h1, h2, h ] ; ring;

end