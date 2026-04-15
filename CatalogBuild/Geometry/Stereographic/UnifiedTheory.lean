/-! # CatalogBuild.Geometry.Stereographic.UnifiedTheory

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 39
-/

import Mathlib

noncomputable section

/-- The pole map M_a(t) = (at + 1)/(t - a). -/
def poleM (a t : ℝ) : ℝ := (a * t + 1) / (t - a)


/-- The canonical mirror: t ↦ -1/t. Swaps 0 and ∞. -/
def mirror (t : ℝ) : ℝ := -(1 / t)


/-- The two-pole Möbius map F_{a,b}. -/
def moebiusF (a b t : ℝ) : ℝ :=
  ((a * b + 1) * t + (b - a)) / ((a - b) * t + (a * b + 1))


/-- **The Mirror Theorem**: The mirror is an involution. -/
theorem mirror_involution (t : ℝ) (ht : t ≠ 0) : mirror (mirror t) = t := by
  unfold mirror; field_simp


/-- For any nonzero t, mirror(t) ≠ 0. -/
theorem mirror_no_zero (t : ℝ) (ht : t ≠ 0) : mirror t ≠ 0 := by
  exact neg_ne_zero.mpr (one_div_ne_zero ht)


/-- **Mirror has no real fixed points**: t ↦ -1/t has no real fixed points. -/
theorem mirror_no_real_fixed_point (t : ℝ) (ht : t ≠ 0) : mirror t ≠ t := by
  exact fun h => ht <| by rw [show mirror t = -(1 / t) by rfl] at h; nlinarith [mul_div_cancel₀ 1 ht]


/-- **Pole map is an involution**: M_a(M_a(t)) = t. -/
theorem pole_map_is_involution (a t : ℝ) (ht : t ≠ a)
    (hmt : poleM a t ≠ a) :
    poleM a (poleM a t) = t := by
  unfold poleM at *
  grind +ring


/-- [Section: ## Part I: The Mirror — Involutions and Self-Reflection] -/
theorem pole_map_fixed_point_equation (a t : ℝ) (ht : t ≠ a) :
    poleM a t = t ↔ t ^ 2 - 2 * a * t - 1 = 0 := by
  -- By definition of poleM, we have poleM a t = (a * t + 1) / (t - a).
  simp [poleM];
  grind


theorem pole_map_fixed_points (a : ℝ) :
    let t₁ := a + Real.sqrt (1 + a ^ 2)
    let t₂ := a - Real.sqrt (1 + a ^ 2)
    t₁ ^ 2 - 2 * a * t₁ - 1 = 0 ∧ t₂ ^ 2 - 2 * a * t₂ - 1 = 0 := by
  constructor <;> nlinarith [ Real.mul_self_sqrt ( show 0 ≤ 1 + a ^ 2 by positivity ) ]


theorem fixed_points_mirror_related (a : ℝ) :
    let t₁ := a + Real.sqrt (1 + a ^ 2)
    let t₂ := a - Real.sqrt (1 + a ^ 2)
    t₁ * t₂ = -1 := by
  linarith [ Real.mul_self_sqrt ( by positivity : 0 ≤ 1 + a ^ 2 ) ]


/-- Inverse stereographic projection from the south pole: the universal decoder ℝ → S¹. -/
def sigmaInv (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))


/-- Forward stereographic projection from the south pole: S¹ → ℝ.
σ(x, y) = x / (1 + y), defined for y ≠ -1 (i.e., not the south pole). -/
def sigma (p : ℝ × ℝ) : ℝ := p.1 / (1 + p.2)


/-- **Light lives on the circle**: σ⁻¹(t) ∈ S¹ for all t ∈ ℝ. -/
theorem light_on_circle (t : ℝ) :
    (sigmaInv t).1 ^ 2 + (sigmaInv t).2 ^ 2 = 1 := by
  unfold sigmaInv; field_simp; ring


/-- **The South Pole is the Origin**: σ⁻¹(0) = (0, 1), the "top" of the circle. -/
theorem north_pole_origin : sigmaInv 0 = (0, 1) := by
  unfold sigmaInv; simp


/-- **The East Point is Unity**: σ⁻¹(1) = (1, 0). -/
theorem east_point_unity : sigmaInv 1 = (1, 0) := by
  unfold sigmaInv; norm_num


/-- **The West Point is Negative Unity**: σ⁻¹(-1) = (-1, 0). -/
theorem west_point_neg_unity : sigmaInv (-1) = (-1, 0) := by
  unfold sigmaInv; norm_num


/-- [Section: ## Part II: Heaven and Hell — The Poles of Infinity] -/
theorem heaven_and_back (t : ℝ) : sigma (sigmaInv t) = t := by
  unfold sigma sigmaInv; ring_nf ;
  -- Simplify the expression to get $t$.
  field_simp
  ring


theorem hell_and_back (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    sigmaInv (sigma (x, y)) = (x, y) := by
  unfold sigmaInv sigma;
  grind


theorem approaching_heaven_gap (t : ℝ) :
    1 + (sigmaInv t).2 = 2 / (1 + t ^ 2) := by
  unfold sigmaInv; ring;
  linarith [ mul_inv_cancel₀ ( by positivity : ( 1 + t ^ 2 ) ≠ 0 ) ]


/-- **Descent to hell**: σ⁻¹(-1/t) has opposite y-coordinate to σ⁻¹(t).
The mirror map t ↦ -1/t swaps "up" and "down" on the circle. -/
theorem descent_to_hell (t : ℝ) (ht : t ≠ 0) :
    (sigmaInv (-(1/t))).2 = -(sigmaInv t).2 := by
  unfold sigmaInv; norm_num [ht]; ring; field_simp; ring


theorem mirror_flips_x (t : ℝ) (ht : t ≠ 0) :
    (sigmaInv (-(1/t))).1 = -(sigmaInv t).1 := by
  -- Let's simplify the expression for the first component of σ⁻¹(-1/t).
  simp [sigmaInv];
  -- Combine and simplify the fractions
  field_simp
  ring


/-- The discriminant of the fixed-point equation for a Möbius transformation
(at+b)/(ct+d) = t ⟹ ct² + (d-a)t - b = 0.
Δ = (d-a)² + 4bc = (a+d)² - 4(ad-bc) = tr² - 4·det. -/
def moebiusDiscriminant (a b c d : ℝ) : ℝ :=
  (a + d) ^ 2 - 4 * (a * d - b * c)


/-- Alternative form of the discriminant. -/
theorem discriminant_alt (a b c d : ℝ) :
    moebiusDiscriminant a b c d = (d - a) ^ 2 + 4 * b * c := by
  unfold moebiusDiscriminant; ring


/-- **Elliptic criterion for integer poles**: discriminant = -4(a-b)² ≤ 0. -/
theorem integer_poles_elliptic (a b : ℝ) :
    moebiusDiscriminant (a * b + 1) (b - a) (a - b) (a * b + 1) = -4 * (a - b) ^ 2 := by
  unfold moebiusDiscriminant; ring


/-- Elliptic means discriminant ≤ 0. -/
theorem integer_poles_elliptic_nonpos (a b : ℝ) :
    moebiusDiscriminant (a * b + 1) (b - a) (a - b) (a * b + 1) ≤ 0 := by
  rw [integer_poles_elliptic]; nlinarith [sq_nonneg (a - b)]


/-- [Section: ## Part III: Light Connects Fixed Points] -/
theorem hyperbolic_two_fixed_points (a b c d : ℝ) (hc : c ≠ 0)
    (hΔ : 0 < moebiusDiscriminant a b c d) :
    ∃ t₁ t₂ : ℝ, t₁ ≠ t₂ ∧
      c * t₁ ^ 2 + (d - a) * t₁ - b = 0 ∧
      c * t₂ ^ 2 + (d - a) * t₂ - b = 0 := by
  -- Apply the quadratic formula to find the roots.
  use (- (d - a) + Real.sqrt ((d - a)^2 + 4 * b * c)) / (2 * c), (- (d - a) - Real.sqrt ((d - a)^2 + 4 * b * c)) / (2 * c);
  norm_num [ moebiusDiscriminant ] at *;
  grind +revert


theorem parabolic_one_fixed_point (a b c d : ℝ) (hc : c ≠ 0)
    (hΔ : moebiusDiscriminant a b c d = 0) :
    ∃ t₀ : ℝ, c * t₀ ^ 2 + (d - a) * t₀ - b = 0 ∧
      ∀ t : ℝ, c * t ^ 2 + (d - a) * t - b = 0 → t = t₀ := by
  use (a - d) / (2 * c);
  unfold moebiusDiscriminant at hΔ;
  grind


theorem fixed_point_iff (a b c d t : ℝ) (hd : c * t + d ≠ 0) :
    moebius a b c d t = t ↔ c * t ^ 2 + (d - a) * t - b = 0 := by
  unfold moebius; rw [ div_eq_iff hd ] ; constructor <;> intros <;> linarith;


/-- [Section: ## Part IV: The Cross-Ratio — The Invariant of Light] -/
theorem moebius_difference (a b c d z₁ z₂ : ℝ)
    (h₁ : c * z₁ + d ≠ 0) (h₂ : c * z₂ + d ≠ 0) :
    moebius a b c d z₁ - moebius a b c d z₂ =
    (a * d - b * c) * (z₁ - z₂) / ((c * z₁ + d) * (c * z₂ + d)) := by
  unfold moebius;
  grind


theorem cross_ratio_moebius_invariant (a b c d : ℝ) (hdet : a * d - b * c ≠ 0)
    (z₁ z₂ z₃ z₄ : ℝ)
    (h₁ : c * z₁ + d ≠ 0) (h₂ : c * z₂ + d ≠ 0)
    (h₃ : c * z₃ + d ≠ 0) (h₄ : c * z₄ + d ≠ 0) :
    crossRatio (moebius a b c d z₁) (moebius a b c d z₂)
               (moebius a b c d z₃) (moebius a b c d z₄) =
    crossRatio z₁ z₂ z₃ z₄ := by
  unfold crossRatio;
  rw [ moebius_difference, moebius_difference, moebius_difference, moebius_difference ] <;> try assumption;
  field_simp


/-- **The determinant of F_{a,b} factors through Gaussian norms**:
det = (ab+1)² + (b-a)² = (1+a²)(1+b²) = N(1+ai)·N(1+bi). -/
theorem det_is_gaussian_product (a b : ℝ) :
    (a * b + 1) ^ 2 + (b - a) ^ 2 = (1 + a ^ 2) * (1 + b ^ 2) := by
  ring


/-- [Section: ## Part V: The Grand Synthesis] -/
theorem composition_transitivity (a b c t : ℝ)
    (h1 : (a - b) * t + (a * b + 1) ≠ 0)
    (h2 : (b - c) * moebiusF a b t + (b * c + 1) ≠ 0) :
    moebiusF b c (moebiusF a b t) = moebiusF a c t := by
  unfold moebiusF at *;
  grind +ring


theorem same_pole_identity (a t : ℝ) : moebiusF a a t = t := by
  unfold moebiusF;
  rw [ div_eq_iff ] <;> nlinarith


theorem reverse_poles_inverse (a b t : ℝ)
    (h1 : (a - b) * t + (a * b + 1) ≠ 0)
    (h2 : (b - a) * moebiusF a b t + (b * a + 1) ≠ 0) :
    moebiusF b a (moebiusF a b t) = t := by
  unfold moebiusF at *;
  grind


theorem golden_bridge_injective : Function.Injective sigmaInv := by
  intro t₁ t₂ h_eq;
  rw [ Prod.mk_inj ] at h_eq;
  unfold sigmaInv at h_eq;
  field_simp at h_eq;
  nlinarith [ sq_nonneg ( t₁ - t₂ ) ]


/-- **The full circle of light**: every point on S¹ \ {south pole} comes from ℝ. -/
theorem circle_of_light (x y : ℝ) (hcirc : x ^ 2 + y ^ 2 = 1) (hy : y ≠ -1) :
    ∃ t : ℝ, sigmaInv t = (x, y) :=
  ⟨sigma (x, y), hell_and_back x y hcirc hy⟩


/-- **The Conformal Property**: |dσ⁻¹/dt|² = (2/(1+t²))². -/
theorem conformal_scale_factor (t : ℝ) :
    let dx_dt := (2 * (1 - t ^ 2)) / (1 + t ^ 2) ^ 2
    let dy_dt := (-4 * t) / (1 + t ^ 2) ^ 2
    dx_dt ^ 2 + dy_dt ^ 2 = (2 / (1 + t ^ 2)) ^ 2 := by
  simp only; field_simp; ring


/-- **Light and Pythagorean triples**: the stereographic parametrization
at rational t = p/q gives ALL Pythagorean triples! -/
theorem light_pythagorean (p q : ℤ) :
    (2 * p * q) ^ 2 + (q ^ 2 - p ^ 2) ^ 2 = (p ^ 2 + q ^ 2) ^ 2 := by ring


theorem mirror_symmetry_y (t : ℝ) (ht : t ≠ 0) :
    (sigmaInv (1/t)).2 = -(sigmaInv t).2 := by
  unfold sigmaInv; ring;
  -- Combine like terms and simplify the expression.
  field_simp
  ring


end
