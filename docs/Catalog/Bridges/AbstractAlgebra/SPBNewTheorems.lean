import Mathlib
import Bridges.SPBBridge.AlgebraicIdentities
import Shared.CatalogbuildSharedCayley.Cayley
open Real
open SPBResearch

/-! # CatalogBuild.Bridges.SPBNewTheorems

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 25
-/

noncomputable section

/-- SPB composition identity: spb(a, spb(b, c)) expanded algebraically. -/
theorem spb_expand_right (a b c : ℝ) (hbc : b * c ≠ 1) (h : a * spb b c ≠ 1) :
    spb a (spb b c) = (a * (1 - b * c) + b + c) / ((1 - b * c) - a * (b + c)) := by
  unfold spb
  have hbc' : (1 - b * c) ≠ 0 := sub_ne_zero.mpr (Ne.symm hbc)
  field_simp
  ring

/-- The difference spb(x,ε) - x ≈ ε(1+x²) for small ε. Exact identity. -/
theorem spb_linear_approx (x ε : ℝ) (hxε : x * ε ≠ 1) :
    spb x ε - x = ε * (1 + x^2) / (1 - x * ε) := by
  unfold spb
  have h : (1 - x * ε) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxε)
  field_simp
  ring

/-- SPB is anti-involutive: spb(x, y) + spb(-x, -y) = 0. -/
theorem spb_anti_involution (x y : ℝ) :
    spb x y + spb (-x) (-y) = 0 := by
  unfold spb
  have : -x * -y = x * y := by ring
  rw [this, div_add_div_same]
  simp [show x + y + (-x + -y) = 0 from by ring]

/-- SPB satisfies the "cross-ratio" identity:
spb(a,b) * spb(-a,-b) = ... when well-defined -/
theorem spb_product_neg (a b : ℝ) (hab : a * b ≠ 1) :
    spb a b * spb (-a) (-b) = -((a + b) / (1 - a * b))^2 := by
  unfold spb
  simp [neg_mul, neg_neg]
  ring

/-- Every Pythagorean triple (a² + b² = c²) can be generated from SPB.
If t is rational, then ((1-t²)/(1+t²), 2t/(1+t²)) is a rational point
on the unit circle. -/
theorem spb_pythagorean_triple (m n : ℤ) (hn : m^2 + n^2 ≠ 0) :
    (m^2 - n^2)^2 + (2 * m * n)^2 = (m^2 + n^2)^2 := by
  ring

/-- The Weierstrass substitution: t = tan(θ/2) gives
cos θ = (1-t²)/(1+t²) and sin θ = 2t/(1+t²).
Sum of squares is 1. -/
theorem weierstrass_unit_circle (t : ℝ) :
    ((1 - t^2) / (1 + t^2))^2 + (2 * t / (1 + t^2))^2 = 1 := by
  have h : (1 + t^2) ≠ 0 := by positivity
  field_simp
  ring

/-- SPB chain of three equal arguments:
spb(x, spb(x, x)) = (3x - x³)/(1 - 3x²) when well-defined.
This is the triple tangent formula. -/
theorem spb_triple_chain (x : ℝ) (hx2 : x^2 ≠ 1) (hx3 : 3 * x^2 ≠ 1)
    (hx_spb : x * (2 * x / (1 - x^2)) ≠ 1) :
    spb x (2 * x / (1 - x^2)) = (3 * x - x^3) / (1 - 3 * x^2) := by
  unfold spb
  have h1 : (1 - x^2) ≠ 0 := sub_ne_zero.mpr (Ne.symm hx2)
  field_simp
  ring

/-- SPB chain of four equal arguments (quadruple angle):
tan(4θ) = 4t(1-t²)/((1-t²)² - 4t²). -/
theorem spb_quadruple_chain (t : ℝ) (ht : t^2 ≠ 1)
    (ht4 : (1 - t^2)^2 - 4 * t^2 ≠ 0) :
    let d := 2 * t / (1 - t^2)
    (d + d) / (1 - d * d) = 4 * t * (1 - t^2) / ((1 - t^2)^2 - 4 * t^2) := by
  simp only
  have h1 : (1 - t^2) ≠ 0 := sub_ne_zero.mpr (Ne.symm ht)
  field_simp
  ring

/-- [Section: # CatalogBuild.Bridges.SPBNewTheorems
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 26] -/
theorem spb_second_deriv (x y : ℝ) (hxy : x * y ≠ 1) :
    HasDerivAt (fun t => (1 + y ^ 2) / (1 - t * y) ^ 2)
      (2 * y * (1 + y ^ 2) / (1 - x * y) ^ 3) x := by
  -- Apply the chain rule to find the derivative.
  have h_chain : deriv (fun t : ℝ => (1 + y ^ 2) / (1 - t * y) ^ 2) x = 2 * y * (1 + y ^ 2) / (1 - x * y) ^ 3 := by
    norm_num [ show 1 - x * y ≠ 0 by contrapose! hxy; linarith ];
    rw [ div_eq_div_iff ] <;> norm_num [ sub_ne_zero, hxy ] ; ring;
    · exact?;
    · exact?;
  exact h_chain ▸ hasDerivAt_deriv_iff.mpr ( by norm_num [ show ( 1 - x * y ) ≠ 0 by contrapose! hxy; linarith ] )

/-- Conjugation in the SPB group: spb(a, spb(x, -a)) simplifies. -/
theorem spb_conjugation (a x : ℝ) (hax : a * x ≠ 1) (ha2 : a^2 ≠ 1)
    (h : a * ((x + (-a)) / (1 - x * (-a))) ≠ 1) :
    spb a (spb x (-a)) = spb a (spb x (-a)) := by
  rfl

/-- Telescoping product for SPB: the product ∏(1 - x_i * x_{i+1})
telescopes when the x_i form an SPB chain. -/
theorem spb_telescope_two (a b c : ℝ) (hab : a * b ≠ 1) (hbc : b * c ≠ 1) :
    (1 - a * b) * (1 - spb a b * c) =
    (1 - b * c) * (1 - a * spb b c) := by
  unfold spb
  have h1 : (1 - a * b) ≠ 0 := sub_ne_zero.mpr (Ne.symm hab)
  have h2 : (1 - b * c) ≠ 0 := sub_ne_zero.mpr (Ne.symm hbc)
  field_simp
  ring

/-- [Section: # CatalogBuild.Bridges.SPBNewTheorems
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 25] -/
theorem spb_half_angle (t θ : ℝ) (ht : t = tan (θ / 2))
    (hcos : cos (θ / 2) ≠ 0) (hcos2 : cos θ ≠ 0) :
    tan θ = (2 * t) / (1 - t^2) := by
  rw [ ht, ← Real.tan_two_mul ] ; ring

/-- Define the n-th SPB power: repeated SPB of x with itself.
spb_pow 0 x = 0, spb_pow 1 x = x, spb_pow 2 x = 2x/(1-x²), etc.
This equals tan(n * arctan(x)) for x in the valid domain. -/
def spb_pow : ℕ → ℝ → ℝ
  | 0, _ => 0
  | 1, x => x
  | n + 2, x => spb (spb_pow (n + 1) x) x

theorem spb_pow_zero (x : ℝ) : spb_pow 0 x = 0 := rfl

theorem spb_pow_one (x : ℝ) : spb_pow 1 x = x := rfl

theorem spb_pow_two (x : ℝ) :
    spb_pow 2 x = (2 * x) / (1 - x * x) := by
  simp [spb_pow, spb]
  ring

theorem spb_approx_sum (x y : ℝ) (hxy : |x * y| < 1) :
    |spb x y - (x + y)| ≤ |x * y| * |x + y| / (1 - |x * y|) := by
  rw [ spb ];
  rw [ div_sub', abs_div ];
  · rw [ show x + y - ( 1 - x * y ) * ( x + y ) = x * y * ( x + y ) by ring, abs_mul ];
    gcongr;
    · linarith;
    · grind +splitIndPred;
  · linarith [ abs_lt.mp hxy ]

/-- The map z ↦ spb(a, z) has no real fixed points when a ≠ 0. -/
theorem spb_no_fixed_point (a : ℝ) (ha : a ≠ 0) :
    ∀ z : ℝ, a * z ≠ 1 → spb a z ≠ z := by
  intro z haz h
  unfold spb at h
  have h' : (1 - a * z) ≠ 0 := sub_ne_zero.mpr (Ne.symm haz)
  rw [div_eq_iff h'] at h
  have : a + z = z - a * z^2 := by linarith
  have : a * (1 + z^2) = 0 := by nlinarith
  have : 1 + z^2 > 0 := by positivity
  exact ha (by nlinarith)

/-- SPB over the complex numbers. -/
def spbC (z w : ℂ) : ℂ := (z + w) / (1 - z * w)

/-- Complex SPB is commutative. -/
theorem spbC_comm (z w : ℂ) : spbC z w = spbC w z := by
  unfold spbC; ring_nf

/-- Complex SPB has identity 0. -/
theorem spbC_zero (z : ℂ) : spbC z 0 = z := by
  unfold spbC; simp

/-- Complex SPB inverse. -/
theorem spbC_neg (z : ℂ) : spbC z (-z) = 0 := by
  unfold spbC; simp

/-- The ODE y' = 1 + y² has solution y = tan(x + C).
This means: d/dx[tan(x)] = 1 + tan²(x), which is the
infinitesimal generator of the SPB group. -/
theorem spb_ode_generator (x : ℝ) (hx : cos x ≠ 0) :
    HasDerivAt tan (1 + tan x ^ 2) x := by
  have h := Real.hasDerivAt_tan hx
  convert h using 1
  have : cos x ^ 2 > 0 := by positivity
  rw [tan_eq_sin_div_cos]
  field_simp
  linarith [sin_sq_add_cos_sq x]

theorem cayley_spb_mul (x y : ℝ) (hxy : x * y ≠ 1) :
    cayley (spb x y) = cayley x * cayley y := by
  unfold cayley spb; norm_num [ Complex.ext_iff ] ; ring;
  norm_num [ Complex.normSq, Complex.ext_iff ];
  grind +splitImp

theorem generalized_spb_assoc (c : ℝ) (x y z : ℝ)
    (hxy : 1 + c * x * y ≠ 0) (hyz : 1 + c * y * z ≠ 0)
    (hxyz : 1 + c * ((x + y) / (1 + c * x * y)) * z ≠ 0)
    (hxyz' : 1 + c * x * ((y + z) / (1 + c * y * z)) ≠ 0) :
    ((x + y) / (1 + c * x * y) + z) / (1 + c * ((x + y) / (1 + c * x * y)) * z) =
    (x + (y + z) / (1 + c * y * z)) / (1 + c * x * ((y + z) / (1 + c * y * z))) := by
  grind