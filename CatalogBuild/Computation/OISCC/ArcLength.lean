/-! # CatalogBuild.Computation.OISCC.ArcLength

Auto-generated from theorem catalog database.
Domain: Computation/OISCC
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The EML Riemannian metric. -/
def g_arc (x : ℝ) : ℝ := Real.exp x + x⁻¹ ^ 2


/-- Square root of the metric. -/
def sqrtg (x : ℝ) : ℝ := Real.sqrt (g_arc x)


/-- The metric is positive for x > 0. -/
theorem g_arc_pos (x : ℝ) (hx : 0 < x) : g_arc x > 0 := by
  exact add_pos (Real.exp_pos x) (sq_pos_of_pos (inv_pos.mpr hx))


/-- g(x) ≥ exp(x). -/
theorem g_arc_ge_exp (x : ℝ) : g_arc x ≥ Real.exp x := by
  exact le_add_of_nonneg_right (sq_nonneg _)


/-- g(x) ≥ 1/x². -/
theorem g_arc_ge_inv_sq (x : ℝ) : g_arc x ≥ x⁻¹ ^ 2 := by
  exact le_add_of_nonneg_left (Real.exp_nonneg x)


/-- g(x) ≥ 1 for x > 0. -/
theorem g_arc_ge_one (x : ℝ) (hx : 0 < x) : g_arc x ≥ 1 := by
  exact le_add_of_le_of_nonneg (Real.one_le_exp hx.le) (sq_nonneg _)


/-- √g(x) ≥ 1 for x > 0. -/
theorem sqrtg_ge_one (x : ℝ) (hx : 0 < x) : sqrtg x ≥ 1 := by
  unfold sqrtg
  exact Real.le_sqrt_of_sq_le (by linarith [g_arc_ge_one x hx])


/-- √g(x) ≥ 1/x for x > 0. -/
theorem sqrtg_ge_inv (x : ℝ) (hx : 0 < x) : sqrtg x ≥ x⁻¹ := by
  unfold sqrtg
  exact Real.le_sqrt_of_sq_le (le_trans (by norm_num) (g_arc_ge_inv_sq x))


/-- g(x) · x² ≥ 1 for x > 0. -/
theorem g_arc_mul_sq_ge_one (x : ℝ) (hx : 0 < x) :
    g_arc x * x ^ 2 ≥ 1 := by
  unfold g_arc
  have : x⁻¹ ^ 2 * x ^ 2 = 1 := by
    rw [inv_pow, inv_mul_cancel₀ (pow_ne_zero 2 hx.ne')]
  nlinarith [Real.exp_pos x, sq_nonneg x]


/-- [Section: # CatalogBuild.Speculative.OISCC.ArcLength
Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 12] -/
theorem g_arc_tendsto_atTop_zero :
    Filter.Tendsto g_arc (nhdsWithin 0 (Ioi 0)) atTop := by
  -- The term $x^{-2}$ tends to infinity as $x$ approaches $0$ from the right.
  have h_inv_sq : Filter.Tendsto (fun x : ℝ => x⁻¹ ^ 2) (nhdsWithin 0 (Set.Ioi 0)) Filter.atTop := by
    exact Filter.Tendsto.comp ( Filter.tendsto_pow_atTop ( by norm_num ) ) ( tendsto_inv_nhdsGT_zero );
  exact Filter.tendsto_atTop_mono ( fun x ↦ g_arc_ge_inv_sq x ) h_inv_sq


/-- The metric grows to ∞ as x → +∞. -/
theorem g_arc_tendsto_atTop :
    Filter.Tendsto g_arc atTop atTop := by
  exact Filter.tendsto_atTop_mono (fun x => g_arc_ge_exp x) Real.tendsto_exp_atTop


/-- The manifold has infinite diameter. -/
theorem manifold_infinite_diameter :
    ∀ L : ℝ, ∃ a b : ℝ, 0 < a ∧ 0 < b ∧ a < b ∧ b - a ≥ L := by
  intro L
  exact ⟨1, max (L + 2) 2, by positivity, by positivity,
    by linarith [le_max_right (L + 2) 2], by linarith [le_max_left (L + 2) 2]⟩


end
