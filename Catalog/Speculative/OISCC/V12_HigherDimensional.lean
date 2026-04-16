/-! # CatalogBuild.Speculative.OISCC.V12_HigherDimensional

Auto-generated from theorem catalog database.
Domain: Speculative/OISCC
Declarations: 12
-/

import Mathlib

noncomputable section

/-- The 3D EML map: Φ₃(x,y,z)ᵢ = exp(xᵢ) - (ln(xⱼ) + ln(xₖ))/2. -/
def Phi3 (p : Fin 3 → ℝ) : Fin 3 → ℝ := fun i =>
  Real.exp (p i) - (Finset.univ.erase i).sum (fun j => Real.log (p j)) / 2


/-- The sum coordinate for 3D. -/
def S3 (p : Fin 3 → ℝ) : ℝ := Finset.univ.sum (fun i => p i)


/-- The 3D EML potential. -/
def f3 (x : ℝ) : ℝ := Real.exp x - Real.log x - 1


/-- The 3D total potential. -/
def V3 (p : Fin 3 → ℝ) : ℝ := Finset.univ.sum (fun i => f3 (p i))


theorem f3_pos (x : ℝ) (hx : 0 < x) : f3 x > 0 := by
  unfold f3;
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]


theorem V3_pos (p : Fin 3 → ℝ) (hp : ∀ i, 0 < p i) : V3 p > 0 := by
  exact Finset.sum_pos ( fun i _ => f3_pos _ ( hp i ) ) ( by decide )


theorem Phi3_diag (x : ℝ) (hx : 0 < x) :
    Phi3 (fun _ => x) = fun _ => Real.exp x - Real.log x := by
  funext i; exact (by
  unfold Phi3; fin_cases i <;> simp +decide [ hx.ne' ])


theorem S3_const (c : ℝ) : S3 (fun _ => c) = 3 * c := by
  unfold S3; norm_num;


theorem Phi3_diag_preserves (x : ℝ) (hx : 0 < x) :
    ∃ y, Phi3 (fun _ => x) = fun _ => y := by
  unfold Phi3; aesop;


theorem diag3_gt_id (x : ℝ) (hx : 0 < x) :
    Real.exp x - Real.log x > x := by
  have := Real.log_le_sub_one_of_pos ( div_pos ( Real.exp_pos x ) hx );
  rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_exp ] at this;
  rw [ div_sub_one, le_div_iff₀ ] at this <;> nlinarith [ Real.add_one_le_exp x, Real.log_exp x, Real.log_le_sub_one_of_pos hx ]


theorem diag3_ge_two (x : ℝ) (hx : 0 < x) :
    Real.exp x - Real.log x ≥ 2 := by
  linarith [ Real.add_one_le_exp x, Real.log_le_sub_one_of_pos hx ]


theorem exp_sum_grows_diag (x : ℝ) (hx : 0 < x) :
    3 * Real.exp (Real.exp x - Real.log x) > 3 * Real.exp x := by
  gcongr;
  linarith [ diag3_gt_id x hx ]


end
