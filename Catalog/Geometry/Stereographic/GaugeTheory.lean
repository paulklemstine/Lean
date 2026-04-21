/-! # CatalogBuild.Geometry.Stereographic.GaugeTheory

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 20
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Geometry.Stereographic.GaugeTheory
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 20] -/
def gaugeField (n : ℕ) (x : Fin n → ℝ) : ℝ :=
  2 / (1 + ∑ i, (x i) ^ 2)




/-- [Section: # CatalogBuild.Geometry.Stereographic.GaugeTheory
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 20] -/
theorem gaugeField_positive (n : ℕ) (x : Fin n → ℝ) :
    0 < gaugeField n x := by
  unfold gaugeField; positivity




theorem gaugeField_le_two (n : ℕ) (x : Fin n → ℝ) :
    gaugeField n x ≤ 2 := by
  unfold gaugeField
  exact div_le_self (by positivity)
    (le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _))




theorem gaugeField_sq (n : ℕ) (x : Fin n → ℝ) :
    gaugeField n x ^ 2 = 4 / (1 + ∑ i, (x i) ^ 2) ^ 2 := by
  unfold gaugeField; field_simp; ring




def gaugeInvariantKernel (n : ℕ) (x y : Fin n → ℝ) : ℝ :=
  gaugeField n x * gaugeField n y *
    (4 * ∑ i, x i * y i + (∑ i, (x i) ^ 2 - 1) * (∑ i, (y i) ^ 2 - 1))




theorem gaugeInvariantKernel_symm (n : ℕ) (x y : Fin n → ℝ) :
    gaugeInvariantKernel n x y = gaugeInvariantKernel n y x := by
  unfold gaugeInvariantKernel gaugeField
  have h1 : (∑ i, x i * y i) = (∑ i, y i * x i) :=
    Finset.sum_congr rfl fun i _ => mul_comm (x i) (y i)
  rw [h1]; ring




def gaugeConnection (n : ℕ) (x : Fin n → ℝ) (i : Fin n) : ℝ :=
  -2 * x i / (1 + ∑ j, (x j) ^ 2)




theorem gaugeConnection_parity (n : ℕ) (x : Fin n → ℝ) (i : Fin n) :
    gaugeConnection n (fun j => -x j) i = -gaugeConnection n x i := by
  unfold gaugeConnection; simp [neg_sq]; ring




theorem gaugeConnection_zero (n : ℕ) (i : Fin n) :
    gaugeConnection n (fun _ => 0) i = 0 := by
  unfold gaugeConnection; simp




def gaugeCurvatureComponent (n : ℕ) (x : Fin n → ℝ) (i j : Fin n) : ℝ :=
  let D := 1 + ∑ k, (x k) ^ 2
  (if i = j then -2 * D + 4 * (x i) ^ 2 else 4 * x i * x j) / D ^ 2




theorem gaugeCurvature_antisymm (n : ℕ) (x : Fin n → ℝ) (i j : Fin n)
    (hij : i ≠ j) :
    gaugeCurvatureComponent n x i j = gaugeCurvatureComponent n x j i := by
  unfold gaugeCurvatureComponent
  simp [hij, Ne.symm hij]
  ring




theorem gaugeCurvature_zero_origin (n : ℕ) (i j : Fin n) (hij : i ≠ j) :
    gaugeCurvatureComponent n (fun _ => 0) i j = 0 := by
  unfold gaugeCurvatureComponent; simp [hij]




def gaugeCovariantGrad (n : ℕ) (x : Fin n → ℝ)
    (grad : Fin n → ℝ) (fval : ℝ) : Fin n → ℝ :=
  fun i => grad i + gaugeConnection n x i * fval




theorem gaugeCovariantGrad_bounded (n : ℕ) (x : Fin n → ℝ)
    (grad : Fin n → ℝ) (fval : ℝ) (i : Fin n)
    (G F C : ℝ)
    (hgrad : |grad i| ≤ G) (hfval : |fval| ≤ F)
    (hconn : |gaugeConnection n x i| ≤ C)
    (hC : 0 ≤ C) (hF : 0 ≤ F) :
    |gaugeCovariantGrad n x grad fval i| ≤ G + C * F := by
  unfold gaugeCovariantGrad
  calc |grad i + gaugeConnection n x i * fval|
      ≤ |grad i| + |gaugeConnection n x i * fval| := abs_add_le _ _
    _ = |grad i| + |gaugeConnection n x i| * |fval| := by rw [abs_mul]
    _ ≤ G + C * F := by
        apply add_le_add hgrad
        exact mul_le_mul hconn hfval (abs_nonneg _) hC




def gaugeAction (seqLen n : ℕ) (X : Fin seqLen → Fin n → ℝ) : ℝ :=
  ∑ i : Fin seqLen, ∑ j : Fin seqLen,
    (gaugeField n (X i) * gaugeField n (X j)) ^ 2




theorem gaugeAction_nonneg (seqLen n : ℕ) (X : Fin seqLen → Fin n → ℝ) :
    0 ≤ gaugeAction seqLen n X := by
  unfold gaugeAction
  exact Finset.sum_nonneg fun _ _ =>
    Finset.sum_nonneg fun _ _ => by positivity




def effectiveMass (n : ℕ) (x : Fin n → ℝ) : ℝ :=
  1 / gaugeField n x




theorem effectiveMass_formula (n : ℕ) (x : Fin n → ℝ) :
    effectiveMass n x = (1 + ∑ i, (x i) ^ 2) / 2 := by
  unfold effectiveMass gaugeField
  rw [one_div, inv_div]




theorem effectiveMass_at_origin (n : ℕ) :
    effectiveMass n (fun _ => 0) = 1 / 2 := by
  unfold effectiveMass gaugeField; simp




theorem effectiveMass_pos (n : ℕ) (x : Fin n → ℝ) :
    0 < effectiveMass n x := by
  unfold effectiveMass
  exact div_pos one_pos (gaugeField_positive n x)




end
