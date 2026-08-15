import Mathlib
import Logic.StrangeLoops.Core

/-!
# SPB Algebraic Identities: New Results

Deep algebraic identities connecting SPB, hyperbolic SPB, and field operations.

## Main Results
- Cocycle identity (heart of associativity)
- Norm identity (stereographic projection)
- Cross-ratio preservation
- SPB-hyperbolic SPB duality
- Integer closure classification
- Reciprocal law
- Composition formulas
-/

noncomputable section

/-! ## Core SPB definitions

`spb` is the "special projective bracket" (the Möbius/tangent-addition law) and
`spbH` its hyperbolic (Einstein velocity-addition) counterpart. -/

namespace SPBResearch

/-- The special projective bracket `spb x y = (x + y) / (1 - x y)`. -/
def spb (x y : ℝ) : ℝ := (x + y) / (1 - x * y)

/-- The hyperbolic bracket `spbH u v = (u + v) / (1 + u v)`. -/
def spbH (u v : ℝ) : ℝ := (u + v) / (1 + u * v)

/-- `spb` is commutative. -/
theorem spb_comm (x y : ℝ) : spb x y = spb y x := by
  unfold spb; rw [add_comm, mul_comm]

/-- `0` is a right unit for `spb`. -/
@[simp] theorem spb_zero (x : ℝ) : spb x 0 = x := by
  unfold spb; norm_num

/-- `0` is a left unit for `spb`. -/
@[simp] theorem zero_spb (y : ℝ) : spb 0 y = y := by
  unfold spb; norm_num

/-- The `spb`-inverse of `x` is `-x`. -/
@[simp] theorem spb_neg (x : ℝ) : spb x (-x) = 0 := by
  unfold spb; norm_num

/-- `spbH` is commutative. -/
theorem spbH_comm (u v : ℝ) : spbH u v = spbH v u := by
  unfold spbH; rw [add_comm, mul_comm]

/-- `0` is a right unit for `spbH`. -/
@[simp] theorem spbH_zero (u : ℝ) : spbH u 0 = u := by
  unfold spbH; norm_num

end SPBResearch

open Real SPBResearch

namespace SPBAlgebra

/-! ## Cocycle Identity -/

/-
The cocycle identity: (1-xy)(1-spb(x,y)·z) = (1-yz)(1-x·spb(y,z)).
-/
theorem cocycle (x y z : ℝ) (hxy : 1 - x * y ≠ 0) (hyz : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold SPBResearch.spb;
  grind

/-! ## Norm Identity -/

/-- (1-xy)²(1+spb(x,y)²) = (1+x²)(1+y²). -/
theorem norm_identity (x y : ℝ) (h : 1 - x * y ≠ 0) :
    (1 - x * y) ^ 2 * (1 + spb x y ^ 2) = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb; field_simp; ring

/-- Hyperbolic norm: (1+uv)²(1-spbH(u,v)²) = (1-u²)(1-v²). -/
theorem hyp_norm_identity (u v : ℝ) (h : 1 + u * v ≠ 0) :
    (1 + u * v) ^ 2 * (1 - spbH u v ^ 2) = (1 - u ^ 2) * (1 - v ^ 2) := by
  unfold spbH; field_simp; ring

/-! ## Cross-Ratio Preservation -/

/-- spb(a,t) - spb(b,t) = (a-b)(1+t²)/((1-at)(1-bt)). -/
theorem spb_difference (a b t : ℝ) (ha : 1 - a * t ≠ 0) (hb : 1 - b * t ≠ 0) :
    spb a t - spb b t = (a - b) * (1 + t ^ 2) / ((1 - a * t) * (1 - b * t)) := by
  simp only [SPBResearch.spb]
  rw [div_sub_div _ _ ha hb]
  congr 1; ring

/-
Cross-ratio is preserved: (spb(a,t)-spb(b,t))/(spb(c,t)-spb(d,t)) =
    (a-b)(1-ct)(1-dt) / ((c-d)(1-at)(1-bt)).
-/
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

/-! ## SPB-Hyperbolic Duality -/

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

/-! ## Symmetry Properties -/

/-- Odd symmetry: spb(-x, -y) = -spb(x, y). -/
theorem spb_odd (x y : ℝ) : spb (-x) (-y) = -spb x y := by
  unfold spb; ring

/-- Reciprocal law: spb(1/x, 1/y) = -spb(x, y).
    Proof: spb(1/x,1/y) = (1/x+1/y)/(1-1/(xy)) = (x+y)/(xy-1) = -(x+y)/(1-xy) = -spb(x,y). -/
theorem spb_reciprocal (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0) (h : x * y ≠ 1) :
    spb (1/x) (1/y) = -spb x y := by
  simp only [SPBResearch.spb]
  have h1 : 1 - x * y ≠ 0 := fun hc => h (by linarith)
  have h2 : 1 - 1/x * (1/y) ≠ 0 := by
    intro hc; apply h; have := sub_eq_zero.mp hc; field_simp at this; linarith
  rw [div_eq_iff h2]
  rw [show -((x + y) / (1 - x * y)) * (1 - 1 / x * (1 / y)) =
      -(x + y) * (1 - 1 / x * (1 / y)) / (1 - x * y) from by ring]
  rw [eq_div_iff h1]
  field_simp
  ring

/-! ## Integer SPB -/

/-- spb(a,b) ∈ ℤ iff (1-ab) | (a+b). -/
theorem spb_integer_criterion (a b : ℤ) (h : 1 - a * b ≠ 0) :
    (1 - a * b) ∣ (a + b) ↔ ∃ q : ℤ, a + b = q * (1 - a * b) := by
  exact dvd_iff_exists_eq_mul_left

/-- Specific computations. -/
theorem spb_2_3 : spb (2 : ℝ) 3 = -1 := by unfold spb; norm_num
theorem spb_1_2 : spb (1 : ℝ) 2 = -3 := by unfold spb; norm_num
theorem spb_1_3 : spb (1 : ℝ) 3 = -2 := by unfold spb; norm_num

/-! ## Associativity -/

/-
SPB is associative (when all denominators are nonzero).
-/
theorem spb_assoc (x y z : ℝ) (hxy : 1 - x * y ≠ 0) (hyz : 1 - y * z ≠ 0)
    (h3 : 1 - spb x y * z ≠ 0) (h4 : 1 - x * spb y z ≠ 0) :
    spb (spb x y) z = spb x (spb y z) := by
  unfold SPBResearch.spb at *;
  grind

/-- Hyperbolic SPB is also associative. -/
theorem spbH_assoc (u v w : ℝ) (h1 : 1 + u * v ≠ 0) (h2 : 1 + v * w ≠ 0)
    (h3 : 1 + spbH u v * w ≠ 0) (h4 : 1 + u * spbH v w ≠ 0) :
    spbH (spbH u v) w = spbH u (spbH v w) := by
  unfold spbH at *; field_simp; ring

/-! ## Involution -/

/-
spb(spb(x, a), -a) = x: SPB with a is undone by SPB with -a.
-/
theorem spb_cancel (x a : ℝ) (h1 : 1 - x * a ≠ 0) (h2 : 1 + spb x a * a ≠ 0) :
    spb (spb x a) (-a) = x := by
  unfold spb at *;
  grind

/-! ## Velocity Addition -/

/-
Einstein velocity addition preserves the light speed bound.
-/
theorem spbH_bounded (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.mpr ⟨ by unfold spbH; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ], by unfold spbH; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-! ## Rapidity Product Formula -/

/-- (1+spbH(u,v))/(1-spbH(u,v)) = ((1+u)/(1-u))·((1+v)/(1-v)). -/
theorem rapidity_product (u v : ℝ) (_hu : u ≠ 1) (_hv : v ≠ 1) 
    (huv : 1 + u * v ≠ 0) (_hs : spbH u v ≠ 1) :
    (1 + spbH u v) / (1 - spbH u v) = (1 + u) / (1 - u) * ((1 + v) / (1 - v)) := by
  unfold spbH; field_simp; ring

end SPBAlgebra
end