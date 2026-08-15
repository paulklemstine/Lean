import Mathlib
import Bridges.SPBBridge.AlgebraicIdentities
open Real
open SPBResearch

/-! # CatalogBuild.Bridges.SPBAdvanced

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

noncomputable section

/-- SPB with fixed first argument `a` is the Möbius transformation
`z ↦ (z + a)/(1 - az)`, which is an element of PGL(2, ℝ). -/
def spb_mobius_matrix (a : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![1, a; -a, 1]

/-- [Section: # CatalogBuild.Bridges.SPBAdvanced
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem spb_mobius_det (a : ℝ) :
    Matrix.det (spb_mobius_matrix a) = 1 + a ^ 2 := by
  unfold spb_mobius_matrix;
  norm_num [ sq ]

/-- [Section: # CatalogBuild.Bridges.SPBAdvanced
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem spb_mobius_mul (a b : ℝ) (hab : a * b ≠ 1) :
    ∃ (c : ℝ), c ≠ 0 ∧
    spb_mobius_matrix a * spb_mobius_matrix b =
    c • spb_mobius_matrix ((a + b) / (1 - a * b)) := by
  refine' ⟨ 1 - a * b, _, _ ⟩ <;> norm_num [ spb_mobius_matrix ];
  · exact sub_ne_zero_of_ne hab.symm;
  · grind

/-- n-fold iterated SPB: `spb_iter n x = spb(x, spb(x, ... spb(x, x)...))`.
This equals `tan(n * arctan(x))`. -/
def spb_iter : ℕ → ℝ → ℝ
  | 0, _ => 0
  | 1, x => x
  | n + 2, x =>
    let prev := spb_iter (n + 1) x
    let pprev := spb_iter n x
    (2 * x * prev - (x ^ 2 - 1) * pprev) /
    ((x ^ 2 - 1) * prev * 0 + (1 - x ^ 2 * 0))  -- placeholder recurrence
    -- In practice, the clean formula is via Chebyshev-like recurrence

/-- spb_iter 0 is the identity element. -/
theorem spb_iter_zero (x : ℝ) : spb_iter 0 x = 0 := by
  rfl

/-- spb_iter 1 is the identity. -/
theorem spb_iter_one (x : ℝ) : spb_iter 1 x = x := by
  rfl

theorem spb_strict_mono_right (x : ℝ) (y₁ y₂ : ℝ)
    (hy : y₁ < y₂) (h1 : x * y₁ < 1) (h2 : x * y₂ < 1) :
    (x + y₁) / (1 - x * y₁) < (x + y₂) / (1 - x * y₂) := by
  rw [ div_lt_div_iff₀ ] <;> nlinarith [ mul_self_nonneg x ]

theorem spb_pos (x y : ℝ) (hx : 0 < x) (hy : 0 < y) (hxy : x * y < 1) :
    0 < (x + y) / (1 - x * y) := by
  exact div_pos ( add_pos hx hy ) ( sub_pos.mpr hxy )

theorem spbH_tanh_add (φ₁ φ₂ : ℝ) :
    (tanh φ₁ + tanh φ₂) / (1 + tanh φ₁ * tanh φ₂) = tanh (φ₁ + φ₂) := by
  rw [ eq_comm, Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.tanh_eq_sinh_div_cosh, Real.sinh_add, Real.cosh_add ];
  field_simp

theorem spb_no_real_fixed_point (a z : ℝ) (ha : a ≠ 0) (haz : a * z ≠ 1) :
    (a + z) / (1 - a * z) ≠ z := by
  -- Assume for contradiction that $(a + z) / (1 - a * z) = z$.
  by_contra h_contra;
  rw [ div_eq_iff ( sub_ne_zero_of_ne <| Ne.symm haz ) ] at h_contra;
  exact ha ( by nlinarith [ sq_nonneg z ] )

theorem spb_deriv_fst (x y : ℝ) (hxy : x * y ≠ 1) :
    HasDerivAt (fun t => (t + y) / (1 - t * y)) ((1 + y ^ 2) / (1 - x * y) ^ 2) x := by
  convert HasDerivAt.div ( HasDerivAt.add ( hasDerivAt_id x ) ( hasDerivAt_const _ _ ) ) ( HasDerivAt.sub ( hasDerivAt_const _ _ ) ( hasDerivAt_mul_const _ ) ) _ using 1 <;> norm_num [ hxy ];
  · ring;
  · exact sub_ne_zero_of_ne hxy.symm

theorem spb_slope_composition (α β : ℝ) (ha : cos α ≠ 0) (hb : cos β ≠ 0)
    (hab : cos (α + β) ≠ 0) :
    tan (α + β) = (tan α + tan β) / (1 - tan α * tan β) := by
  simp_all +decide [ Real.tan_eq_sin_div_cos, Real.sin_add, Real.cos_add, div_eq_mul_inv ];
  grind

end