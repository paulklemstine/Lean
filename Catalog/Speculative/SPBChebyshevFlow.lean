/-! # CatalogBuild.Speculative.SPBChebyshevFlow

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Speculative.SPBChebyshevFlow
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
theorem spbIter_zero : spbIter 0 = fun _ => 0 := rfl



/-- [Section: # CatalogBuild.Speculative.SPBChebyshevFlow
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 10] -/
theorem spbIter_one : spbIter 1 = id := rfl




/-- spb²(x) = 2x/(1-x²) = tan(2·arctan(x)). -/
theorem spbIter_two_eq (x : ℝ) (h : 1 - x * x ≠ 0) :
    spbIter 2 x = 2 * x / (1 - x * x) := by
  simp [spbIter, spb]; field_simp; ring




theorem spbIter_three_eq (x : ℝ) (h1 : 1 - x * x ≠ 0)
    (h2 : 1 - (2 * x / (1 - x * x)) * x ≠ 0) :
    spbIter 3 x = (3 * x - x ^ 3) / (1 - 3 * x ^ 2) := by
  rw [ show spbIter 3 x = spb ( spbIter 2 x ) x from rfl, spbIter_two_eq x h1 ];
  unfold SPBFlow.spb;
  grind




theorem tan_ode (t : ℝ) (h : cos t ≠ 0) :
    HasDerivAt tan (1 + tan t ^ 2) t := by
  convert Real.hasDerivAt_tan h using 1;
  rw [ ← Real.inv_one_add_tan_sq h, one_div, inv_inv ]




theorem tan_flow_value (x₀ t : ℝ) (hc : cos t ≠ 0)
    (hpos : 0 < 1 - tan t * x₀) :
    tan (t + arctan x₀) = spb (tan t) x₀ := by
  rw [ Real.tan_add, Real.tan_arctan ];
  · rfl;
  · exact Or.inl ⟨ fun k hk => hc <| by rw [ hk ] ; exact Real.cos_eq_zero_iff.mpr ⟨ k, by ring ⟩, fun k hk => by cases k <;> ring_nf at hk <;> norm_num at hk <;> nlinarith [ Real.neg_pi_div_two_lt_arctan x₀, Real.arctan_lt_pi_div_two x₀ ] ⟩




/-- Iterated arctan: arctan(spb^n(x)) = n · arctan(x) when all
intermediate denominators are positive.
(We prove the n=2 case.) -/
theorem arctan_spbIter_two (x : ℝ) (h : 0 < 1 - x * x) :
    arctan (spbIter 2 x) = 2 * arctan x := by
  have h1 : 0 < 1 - x * x := h
  simp [spbIter]
  rw [arctan_spb x x h1]; ring




theorem cauchy_invariance_algebraic (x a : ℝ) (h : 1 - x * a ≠ 0) :
    (1 + a ^ 2) / ((1 + spb x a ^ 2) * (1 - x * a) ^ 2) =
    1 / (1 + x ^ 2) := by
  field_simp;
  unfold spb;
  grind




/-- The difference of squares identity for SPB denominators. -/
theorem denom_identity (x y : ℝ) :
    (1 - x * y) * (1 + x * y) = 1 - (x * y) ^ 2 := by ring




/-- The SPB cocycle identity. -/
theorem cocycle_identity (x y z : ℝ) (h1 : 1 - x * y ≠ 0) (h2 : 1 - y * z ≠ 0) :
    (1 - x * y) * (1 - spb x y * z) = (1 - y * z) * (1 - x * spb y z) := by
  unfold spb; field_simp; ring




end
