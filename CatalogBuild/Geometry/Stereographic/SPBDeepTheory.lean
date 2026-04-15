/-! # CatalogBuild.Geometry.Stereographic.SPBDeepTheory

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 12
-/

import Mathlib

noncomputable section

theorem spb_reciprocal_neg (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0)
    (hxy : x * y ≠ 1) :
    spb (1/x) (1/y) = -spb x y := by
  unfold SPBDeep.spb;
  grind

/-! ## Section 2: Cocycle Properties -/

/-- The cocycle is symmetric: c(x,y) = c(y,x). -/

theorem cocycle_symm (x y : ℝ) : cocycle x y = cocycle y x := by
  unfold cocycle; ring_nf

/-- The fundamental cocycle identity:
    N(spb(x,y)) · (1-xy)² = N(x) · N(y). -/

theorem cocycle_norm_identity (x y : ℝ) (hxy : x * y ≠ 1) :
    normSPB (spb x y) * (1 - x * y) ^ 2 = normSPB x * normSPB y := by
  unfold normSPB spb
  have h : (1 - x * y) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  field_simp
  ring

/-- The cocycle satisfies:
    c(x,y)² · N(spb(x,y)) = N(x) · N(y) · c(x,y)⁴ · (1-xy)².
    Simplified: this is just a restatement of norm multiplicativity. -/

theorem cocycle_coboundary_simplified (x y : ℝ) (hxy : x * y ≠ 1) :
    (1 + spb x y ^ 2) * (1 - x * y) ^ 2 = (1 + x ^ 2) * (1 + y ^ 2) := by
  unfold spb
  have h : (1 - x * y) ≠ 0 := sub_ne_zero.mpr (Ne.symm hxy)
  field_simp
  ring

/-! ## Section 3: Sum and Product Identities -/

/-
Sum identity: spb(x,y) + spb(x,-y) = 2x(1+y²)/((1-xy)(1+xy)).
-/

theorem spb_sum_conjugate (x y : ℝ) (hxy : x * y ≠ 1) (hxy' : x * y ≠ -1) :
    spb x y + spb x (-y) = 2 * x * (1 + y^2) / ((1 - x*y) * (1 + x*y)) := by
  unfold spb;
  grind

/-
Product identity: spb(x,y) · spb(x,-y) = (x²-y²)/((1-xy)(1+xy)).
-/

theorem spb_prod_conjugate (x y : ℝ) (hxy : x * y ≠ 1) (hxy' : x * y ≠ -1) :
    spb x y * spb x (-y) = (x^2 - y^2) / ((1 - x*y) * (1 + x*y)) := by
  unfold spb; rw [ div_mul_div_comm ] ; ring;

/-! ## Section 4: SPB Half-Angle -/

/-
The half-angle identity: spb(t,t) = 2t/(1-t²).
-/

theorem spbH_internal (u v : ℝ) (hu : |u| < 1) (hv : |v| < 1) :
    |spbH u v| < 1 := by
  exact abs_lt.mpr ⟨ by rw [ spbH ] ; rw [ lt_div_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ], by rw [ spbH ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ abs_lt.mp hu, abs_lt.mp hv ] ⟩

/-! ## Section 6: Negation Symmetry -/

/-- SPB distributes over negation: spb(-x, -y) = -spb(x, y). -/

theorem spb_of_spb_expanded (a b c d : ℝ) (hab : a * b ≠ 1) (hcd : c * d ≠ 1)
    (_h : spb a b * spb c d ≠ 1) :
    spb (spb a b) (spb c d) =
    ((a + b) * (1 - c*d) + (c + d) * (1 - a*b)) /
    ((1 - a*b) * (1 - c*d) - (a + b) * (c + d)) := by
  unfold spb at *;
  rw [ div_mul_div_comm, div_add_div, div_div ] <;> ring;
  · grind;
  · exact sub_ne_zero_of_ne <| Ne.symm hab;
  · grind

/-
SPB right cancellation: spb(spb(x,y), -y) = x.
-/

theorem spb_gregory_leibniz : spb (1/2 : ℝ) (1/3) = 1 := by
  unfold spb; norm_num

/-- Machin-type identity: spb(1/5, 1/5) = 5/12. -/

theorem spb_double_fifth : spb (1/5 : ℝ) (1/5) = 5/12 := by
  unfold spb; norm_num

/-- Another identity: spb(1/2, 1/5) = 7/9. -/

theorem spb_auto_neg (x y : ℝ) : spb (-x) (-y) = -(spb x y) :=
  spb_neg_neg x y

/-- The inversion map is an SPB anti-automorphism on nonzero elements:
    spb(1/x, 1/y) = -spb(x, y). -/

theorem spb_auto_inv (x y : ℝ) (hx : x ≠ 0) (hy : y ≠ 0)
    (hxy : x * y ≠ 1) :
    spb (1/x) (1/y) = -spb x y :=
  spb_reciprocal_neg x y hx hy hxy


end
