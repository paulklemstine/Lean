/-! # CatalogBuild.Algebra.EigenvalueRepulsion

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 9
-/

import Mathlib

/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 9] -/
theorem vandermonde_det_eq_prod_diff {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det = ∏ i : Fin n, ∏ j ∈ Ioi i, (v j - v i) :=
  Matrix.det_vandermonde v





/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 9] -/
theorem vandermonde_det_zero_iff {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det = 0 ↔ ∃ i j : Fin n, i ≠ j ∧ v i = v j := by
  -- By definition of Vandermonde determinant, if two eigenvalues are equal, say $v^i = v^j$ for some $i < j$, then the determinant is zero due to repeated columns.
  suffices h_suff : ∏ i : Fin n, ∏ j ∈ Finset.Ioi i, (v j - v i) = 0 ↔ ∃ i j, i < j ∧ v i = v j by
    rw [ vandermonde_det_eq_prod_diff, h_suff ];
    exact ⟨ fun ⟨ i, j, hij, h ⟩ => ⟨ i, j, ne_of_lt hij, h ⟩, fun ⟨ i, j, hij, h ⟩ => if hij' : i < j then ⟨ i, j, hij', h ⟩ else ⟨ j, i, lt_of_le_of_ne ( le_of_not_gt hij' ) ( Ne.symm hij ), h.symm ⟩ ⟩;
  norm_num [ Finset.prod_eq_zero_iff, sub_eq_zero ] ; aesop;





/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 9] -/
theorem vandermonde_det_sq {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det ^ 2 = ∏ i : Fin n, ∏ j ∈ Ioi i, (v j - v i) ^ 2 := by
  simp +decide only [vandermonde_det_eq_prod_diff, prod_pow]

-- Non-negative Boltzmann weight.




theorem vandermonde_det_sq_nonneg {n : ℕ} (v : Fin n → ℝ) :
    0 ≤ (vandermonde v).det ^ 2 := sq_nonneg _





theorem vandermonde_det_pos_of_strictMono {n : ℕ} (v : Fin n → ℝ)
    (hv : StrictMono v) : 0 < (vandermonde v).det := by
  rw [ vandermonde_det_eq_prod_diff v ] ; exact Finset.prod_pos fun i hi => Finset.prod_pos fun j hj => sub_pos.2 <| hv <| Finset.mem_Ioi.1 hj;





theorem log_abs_vandermonde_eq_sum {n : ℕ} (v : Fin n → ℝ)
    (hv : StrictMono v) :
    Real.log |(vandermonde v).det| =
      ∑ i : Fin n, ∑ j ∈ Ioi i, Real.log (v j - v i) := by
  rw [ Matrix.det_vandermonde ];
  rw [ Finset.abs_prod, Real.log_prod ];
  · rw [ Finset.sum_congr rfl ] ; intros ; rw [ Finset.abs_prod ] ; rw [ Real.log_prod ] ; aesop;
    exact fun i hi => ne_of_gt <| abs_pos.mpr <| sub_ne_zero.mpr <| hv.injective.ne <| ne_of_gt <| Finset.mem_Ioi.mp hi;
  · exact fun i _ => ne_of_gt <| abs_pos.mpr <| Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero.mpr <| hv.injective.ne <| ne_of_gt <| Finset.mem_Ioi.mp hj





theorem repulsion_stronger_at_higher_beta {x : ℝ} (hx0 : 0 < x) (hx1 : x < 1)
    {β₁ β₂ : ℝ} (hβ : β₁ < β₂) (hβ₁ : 0 < β₁) :
    x ^ β₂ < x ^ β₁ := by
  exact Real.rpow_lt_rpow_of_exponent_gt hx0 hx1 hβ





theorem vandermonde_two (a b : ℝ) :
    (vandermonde ![a, b]).det = b - a := by
  norm_num [ vandermonde, Matrix.det_fin_two ]

-- Symmetry of the squared gap under eigenvalue exchange.




theorem eigenvalue_gap_sq_symm (a b : ℝ) :
    (a - b) ^ 2 = (b - a) ^ 2 := by ring



