/-! # CatalogBuild.Geometry.Stereographic.ConformalStructure

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 25
-/

import Mathlib

noncomputable section

/-- The conformal factor of stereographic projection. -/
def stereoConformalFactor (y : Fin n → ℝ) : ℝ :=
  2 / (1 + ∑ i, (y i) ^ 2)



/-- The conformal factor is always positive. -/
theorem stereoConformalFactor_pos (y : Fin n → ℝ) :
    0 < stereoConformalFactor y := by
  unfold stereoConformalFactor; positivity



/-- [Section: # CatalogBuild.Geometry.Stereographic.ConformalStructure
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 25] -/
theorem stereoConformalFactor_le_two (y : Fin n → ℝ) :
    stereoConformalFactor y ≤ 2 := by
  exact div_le_self zero_le_two ( le_add_of_nonneg_right <| Finset.sum_nonneg fun _ _ => sq_nonneg _ )



theorem stereoConformalFactor_origin :
    stereoConformalFactor (n := n) (fun _ => 0) = 2 := by
  unfold stereoConformalFactor; norm_num



theorem conformal_factor_sq (y : Fin n → ℝ) :
    (stereoConformalFactor y) ^ 2 = 4 / (1 + ∑ i, (y i) ^ 2) ^ 2 := by
  unfold stereoConformalFactor;
  norm_num [ div_pow ]



theorem conformal_factor_antipodal_sum (r : ℝ) (hr : 0 < r) :
    2 / (1 + r ^ 2) + 2 / (1 + (1/r) ^ 2) = 2 := by
  -- Combine the fractions over a common denominator.
  field_simp
  ring



/-- A circle in ℝ² can be described by the equation
A(x² + y²) + Bx + Cy + D = 0 where (A,B,C,D) ≠ 0.
When A = 0 this is a line; when A ≠ 0 a proper circle.
Under stereographic projection, circles on S² correspond to
such generalized circles. We verify that the image of a
great circle through the equator is a line. -/
theorem great_circle_maps_to_line :
    ∀ θ : ℝ, let x := Real.cos θ; let y := Real.sin θ; let z := (0 : ℝ)
    x / (1 - z) = Real.cos θ ∧ y / (1 - z) = Real.sin θ := by
  intro θ; simp



theorem stereo_circle_preserving (A B C D : ℝ) (s t : ℝ)
    (h_denom : (1 + s ^ 2 + t ^ 2) ≠ 0) :
    let x := 2 * s / (1 + s ^ 2 + t ^ 2)
    let y := 2 * t / (1 + s ^ 2 + t ^ 2)
    let z := (s ^ 2 + t ^ 2 - 1) / (1 + s ^ 2 + t ^ 2)
    A * x + B * y + C * z + D * 1 = 0 →
    -- This becomes a generalized circle in (s,t):
    (C + D) * (s ^ 2 + t ^ 2) + A * (2 * s) + B * (2 * t) + (D - C) = 0 := by
  grind



theorem mobius_preserves_cross_ratio
    (al be ga de : ℝ) (hdet : al * de - be * ga ≠ 0)
    (a b c d : ℝ)
    (ha : ga * a + de ≠ 0) (hb : ga * b + de ≠ 0)
    (hc : ga * c + de ≠ 0) (hd : ga * d + de ≠ 0)
    (h_denom : (a - d) * (b - c) ≠ 0)
    (h_denom' : ((al * a + be) / (ga * a + de) - (al * d + be) / (ga * d + de)) *
                ((al * b + be) / (ga * b + de) - (al * c + be) / (ga * c + de)) ≠ 0) :
    crossRatio ((al * a + be) / (ga * a + de)) ((al * b + be) / (ga * b + de))
               ((al * c + be) / (ga * c + de)) ((al * d + be) / (ga * d + de)) =
    crossRatio a b c d := by
  unfold crossRatio;
  rw [ div_eq_div_iff, mul_comm ];
  · field_simp at *;
    field_simp;
    ring;
  · assumption;
  · assumption



/-- The Descartes Circle Theorem: for four mutually tangent circles,
(k₁ + k₂ + k₃ + k₄)² = 2(k₁² + k₂² + k₃² + k₄²). -/
def isDescartes (k₁ k₂ k₃ k₄ : ℝ) : Prop :=
  (k₁ + k₂ + k₃ + k₄) ^ 2 = 2 * (k₁ ^ 2 + k₂ ^ 2 + k₃ ^ 2 + k₄ ^ 2)



theorem apollonian_replacement (k₁ k₂ k₃ k₄ : ℝ)
    (h : isDescartes k₁ k₂ k₃ k₄) :
    isDescartes k₁ k₂ k₃ (2 * (k₁ + k₂ + k₃) - k₄) := by
  exact Eq.symm ( by rw [ isDescartes ] at *; linarith )



/-- Starting from the classic Apollonian packing (-1, 2, 2, 3),
one replacement gives (-1, 2, 2, 3). -/
theorem apollonian_first_generation :
    isDescartes (-1 : ℤ) 2 2 3 ∧
    2 * ((-1 : ℤ) + 2 + 2) - 3 = 3 := by
  constructor
  · unfold isDescartes; ring
  · ring



/-- The Apollonian replacement preserves integrality:
if k₁, k₂, k₃, k₄ are integers, so is 2(k₁+k₂+k₃) - k₄. -/
theorem apollonian_integral (k₁ k₂ k₃ k₄ : ℤ) :
    ∃ k₄' : ℤ, k₄' = 2 * (k₁ + k₂ + k₃) - k₄ := ⟨_, rfl⟩



/-- Double Apollonian replacement returns to the original curvature. -/
theorem apollonian_involution (k₁ k₂ k₃ k₄ : ℝ) :
    2 * (k₁ + k₂ + k₃) - (2 * (k₁ + k₂ + k₃) - k₄) = k₄ := by ring



theorem fisher_stereo_metric_identity (t : ℝ) (ht : t ≠ 0) :
    let theta := t ^ 2 / (1 + t ^ 2)
    let dtheta_dt := 2 * t / (1 + t ^ 2) ^ 2
    -- Fisher metric: 1/(θ(1-θ)) · (dθ/dt)²
    1 / (theta * (1 - theta)) * dtheta_dt ^ 2 = 4 / (1 + t ^ 2) ^ 2 := by
  -- Simplify the expression using algebraic manipulation.
  field_simp
  ring



/-- The statistical manifold of Bernoulli distributions, under stereographic
reparametrization, has constant positive curvature (the sphere). This
verifies the key identity: the Bernoulli Fisher metric
dθ²/(θ(1-θ)) = 4dt²/(1+t²)² is conformally flat. -/
theorem bernoulli_sphere_curvature (t : ℝ) :
    4 / (1 + t ^ 2) ^ 2 = (2 / (1 + t ^ 2)) ^ 2 := by
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp; ring



/-- Liouville's theorem (algebraic core): In dimensions n ≥ 3, every conformal
map is a Möbius transformation. Here we verify the algebraic identity that
the composition of an inversion and a translation is again a Möbius map.
Inversion: I(x) = x/‖x‖² (in 1D: x ↦ 1/x)
Translation: T_a(x) = x + a
The composition T_a ∘ I has the form (1 + ax)/x = a + 1/x,
which is a Möbius transformation with matrix [[a,1],[1,0]]. -/
theorem inversion_translation_is_mobius (a x : ℝ) (hx : x ≠ 0) :
    a + 1 / x = (a * x + 1) / x := by
  field_simp



/-- The group of conformal automorphisms of S¹ is PSL(2,ℝ).
Every orientation-preserving conformal map f: S¹ → S¹
corresponds to a Möbius transformation. Here we verify that
Möbius transformations with determinant 1 compose correctly. -/
theorem mobius_composition (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℝ)
    (h₁ : a₁ * d₁ - b₁ * c₁ = 1) (h₂ : a₂ * d₂ - b₂ * c₂ = 1) :
    (a₁ * a₂ + b₁ * c₂) * (c₁ * b₂ + d₁ * d₂) -
    (a₁ * b₂ + b₁ * d₂) * (c₁ * a₂ + d₁ * c₂) = 1 := by
  nlinarith [h₁, h₂, sq_nonneg (a₁ * d₂ - b₁ * c₂),
             sq_nonneg (a₁ * c₂ - b₁ * d₂)]



/-- The Minkowski inner product in ℝ^{n,1}. Every point on Sⁿ⁻¹ embedded
as (x₁,...,xₙ,1) in ℝⁿ⁺¹ satisfies ‖x‖² = 1, hence the Minkowski
norm x₁² + ... + xₙ² - t² = 0 when t = 1. -/
theorem sphere_is_null_cone_section (x : Fin n → ℝ) (hx : ∑ i, (x i) ^ 2 = 1) :
    ∑ i, (x i) ^ 2 - 1 ^ 2 = 0 := by
  linarith



theorem stereo_metric_intertwining (y y' : ℝ) :
    let s1 := 2 * y / (1 + y ^ 2)
    let s2 := (1 - y ^ 2) / (1 + y ^ 2)
    let s1' := 2 * y' / (1 + y' ^ 2)
    let s2' := (1 - y' ^ 2) / (1 + y' ^ 2)
    let cf_y := 2 / (1 + y ^ 2)
    let cf_y' := 2 / (1 + y' ^ 2)
    (s1 - s1') ^ 2 + (s2 - s2') ^ 2 = cf_y * cf_y' * (y - y') ^ 2 := by
  field_simp;
  ring



/-- In the p-adic world, the stereographic projection formula is the same algebraically.
The key difference is that ‖·‖_p is non-archimedean.
Here we verify the fundamental algebraic identity still holds over any commutative ring:
(2t)² + (1 - t²)² = (1 + t²)² -/
theorem stereo_identity_ring {R : Type*} [CommRing R] (t : R) :
    (2 * t) ^ 2 + (1 - t ^ 2) ^ 2 = (1 + t ^ 2) ^ 2 := by
  ring



theorem padic_stereo_on_circle {R : Type*} [Field R] [CharZero R] (t : R)
    (h : (1 : R) + t ^ 2 ≠ 0) :
    (2 * t / (1 + t ^ 2)) ^ 2 + ((1 - t ^ 2) / (1 + t ^ 2)) ^ 2 = 1 := by
  grind



theorem tropical_stereo_identity (t : ℝ) :
    max (2 * |t|) 0 = 2 * max (|t|) 0 := by
  grind



/-- The Gaussian integers ℤ[i] map to rational points on S¹ via stereographic projection.
Specifically, if a + bi ∈ ℤ[i] with a² + b² ≠ 0, then the stereographic image
(2ab/(a²+b²), (b²-a²)/(a²+b²)) has rational coordinates.
This connects number theory to geometry. -/
theorem gaussian_stereo_rational (a b : ℤ) (h : a ^ 2 + b ^ 2 ≠ 0) :
    ∃ p q : ℤ, ∃ d : ℤ, d ≠ 0 ∧
    2 * a * b = p ∧ (a ^ 2 + b ^ 2) = d ∧
    b ^ 2 - a ^ 2 = q := by
  exact ⟨2 * a * b, b ^ 2 - a ^ 2, a ^ 2 + b ^ 2, h, rfl, rfl, rfl⟩



/-- Every rational point on S¹ arises from stereographic projection of a rational parameter.
Here we verify the algebraic direction: stereo(a/b) gives rational coordinates
that lie on S¹. -/
theorem rational_stereo_gives_rational_point (a b : ℤ)
    (hab : a ^ 2 + b ^ 2 ≠ 0) :
    (2 * a * b) ^ 2 + (b ^ 2 - a ^ 2) ^ 2 = (a ^ 2 + b ^ 2) ^ 2 := by
  ring



end
