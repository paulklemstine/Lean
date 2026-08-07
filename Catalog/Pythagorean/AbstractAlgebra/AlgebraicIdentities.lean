import Mathlib
import Logic.StrangeLoops.Core

/-! # CatalogBuild.Pythagorean.AlgebraicIdentities

Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 12
-/

noncomputable section

/-! The two brackets this file is about.  (The catalog module that used to hold them,
`Shared.AbstractAlgebra.Spb`, does not compile, so the definitions are repeated here in the
form forced by the statements below.) -/

/-- The split-Pythagorean bracket `spb x y = (x + y) / (1 - x y)` (tangent addition). -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic bracket `spbH x y = (x + y) / (1 + x y)` (velocity addition). -/
def spbH (x y : ℝ) : ℝ := (x + y) / (1 + x * y)

/-- (1-xy)²(1+spb(x,y)²) = (1+x²)(1+y²). -/
theorem norm_identity (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

/-- The hyperbolic bracket is symmetric. -/
theorem spbH_comm (x y : ℝ) : spbH x y = spbH y x := by
  unfold spbH; rw [add_comm x y, mul_comm x y]

/-- The hyperbolic bracket preserves the open unit interval: this is the statement that
subluminal velocities compose to a subluminal velocity. -/
theorem spbH_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) : |spbH u v| < 1 := by
  rw [abs_lt] at hu hv
  have hpos : 0 < 1 + u * v := by nlinarith [hu.1, hu.2, hv.1, hv.2]
  rw [spbH, abs_lt, div_lt_one hpos, lt_div_iff₀ hpos]
  constructor <;> nlinarith [hu.1, hu.2, hv.1, hv.2]

/-- Hyperbolic norm: (1+uv)²(1-spbH(u,v)²) = (1-u²)(1-v²). -/
theorem hyp_norm_identity (u v : ℝ) (h : 1 + u * v ≠ 0) :
    (1 + u * v) ^ 2 * (1 - spbH u v ^ 2) = (1 - u ^ 2) * (1 - v ^ 2) := by
  unfold spbH; field_simp; ring

/-- [Section: # CatalogBuild.Pythagorean.AlgebraicIdentities
Auto-generated from theorem catalog database.
Domain: Pythagorean
Declarations: 12] -/
theorem spb_cross_ratio (a b c d t : ℝ)
    (ha : 1 - a * t ≠ 0) (hb : 1 - b * t ≠ 0)
    (hc : 1 - c * t ≠ 0) (hd : 1 - d * t ≠ 0)
    (hcd : c ≠ d) (hspb : spb c t ≠ spb d t) :
    (spb a t - spb b t) / (spb c t - spb d t) =
    ((a - b) * ((1 - c * t) * (1 - d * t))) /
    ((c - d) * ((1 - a * t) * (1 - b * t))) := by
  rw [ div_eq_div_iff ];
  · unfold spb;
    grind;
  · grind;
  · grobner

/-- Sum identity: spb(x,y) + spbH(x,y) = 2(x+y)/((1-xy)(1+xy)). -/
theorem spb_spbH_sum (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spb x y + spbH x y = 2 * (x + y) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb spbH; field_simp; ring

/-- Product identity: spb(x,y) · spbH(x,y) = (x+y)² / ((1-xy)(1+xy)). -/
theorem spb_spbH_product (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spb x y * spbH x y = (x + y) ^ 2 / ((1 - x * y) * (1 + x * y)) := by
  unfold spb spbH; field_simp

/-- Difference: spb(x,y) - spbH(x,y) = 2xy(x+y)/((1-xy)(1+xy)). -/
theorem spb_spbH_diff (x y : ℝ) (hc : 1 - x * y ≠ 0) (hh : 1 + x * y ≠ 0) :
    spb x y - spbH x y = 2 * x * y * (x + y) / ((1 - x * y) * (1 + x * y)) := by
  unfold spb spbH; field_simp; ring

/-- Reciprocal law: spb(1/x, 1/y) = -spb(x, y).
Proof: spb(1/x,1/y) = (1/x+1/y)/(1-1/(xy)) = (x+y)/(xy-1) = -(x+y)/(1-xy) = -spb(x,y). -/
theorem spb_reciprocal (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (h : x * y ≠ 1) :
    spb (1/x) (1/y) = -spb x y := by
  simp only [spb]
  have h1 : 1 - x * y ≠ 0 := fun hc => h (by linarith)
  have h2 : 1 - 1/x * (1/y) ≠ 0 := by
    intro hc; apply h; have := sub_eq_zero.mp hc; field_simp at this; linarith
  rw [div_eq_iff h2]
  rw [show -((x + y) / (1 - x * y)) * (1 - 1 / x * (1 / y)) =
      -(x + y) * (1 - 1 / x * (1 / y)) / (1 - x * y) from by ring]
  rw [eq_div_iff h1]
  field_simp
  ring

/-- spb(a,b) ∈ ℤ iff (1-ab) | (a+b). -/
theorem spb_integer_criterion (a b : ℤ) (h : 1 - a * b ≠ 0) :
    (1 - a * b) ∣ (a + b) ↔ ∃ q : ℤ, a + b = q * (1 - a * b) := by
  exact dvd_iff_exists_eq_mul_left

/-- Specific computations. -/
theorem spb_2_3 : spb (2 : ℝ) 3 = -1 := by unfold spb; norm_num

theorem spb_1_2 : spb (1 : ℝ) 2 = -3 := by unfold spb; norm_num

theorem spb_1_3 : spb (1 : ℝ) 3 = -2 := by unfold spb; norm_num

/-- (1+spbH(u,v))/(1-spbH(u,v)) = ((1+u)/(1-u))·((1+v)/(1-v)). -/
theorem rapidity_product (u v : ℝ) (_hu : u ≠ 1) (_hv : v ≠ 1) 
    (huv : 1 + u * v ≠ 0) (_hs : spbH u v ≠ 1) :
    (1 + spbH u v) / (1 - spbH u v) = (1 + u) / (1 - u) * ((1 + v) / (1 - v)) := by
  unfold spbH; field_simp; ring

end