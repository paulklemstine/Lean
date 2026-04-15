/-! # CatalogBuild.Geometry.Stereographic.MultiHeadStereographic

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 16
-/

import Mathlib

noncomputable section

def generalStereoDenom (n : ℕ) (y : Fin n → ℝ) : ℝ :=
  1 + ∑ i, (y i) ^ 2


def generalInvStereo (n : ℕ) (y : Fin n → ℝ) : Fin (n + 1) → ℝ := fun i =>
  let D := generalStereoDenom n y
  if h : i.val < n then
    2 * y ⟨i.val, h⟩ / D
  else
    (∑ j, (y j) ^ 2 - 1) / D


theorem generalStereoDenom_pos (n : ℕ) (y : Fin n → ℝ) :
    0 < generalStereoDenom n y := by
  unfold generalStereoDenom; positivity

/-
Inverse stereographic projection maps to the unit sphere.
-/

theorem generalInvStereo_on_sphere (n : ℕ) (y : Fin n → ℝ) :
    ∑ i, (generalInvStereo n y i) ^ 2 = 1 := by
      unfold generalInvStereo generalStereoDenom;
      norm_num [ Fin.sum_univ_castSucc, Fin.sum_univ_succ ];
      field_simp;
      rw [ ← Finset.sum_div _ _ _, mul_div_cancel₀ _ ( by positivity ) ] ; ring;
      simpa only [ ← Finset.sum_mul _ _ _ ] using by ring;

/-! ## Part 2: Multi-Head Stereographic Kernel -/


def headKernel (n : ℕ) (x y : Fin n → ℝ) : ℝ :=
  ∑ i, generalInvStereo n x i * generalInvStereo n y i


def rotatedInput (n : ℕ) (R : Fin n → Fin n → ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  fun i => ∑ j, R i j * x j


def multiHeadKernel (numHeads n : ℕ)
    (rotations : Fin numHeads → Fin n → Fin n → ℝ)
    (x y : Fin n → ℝ) : Fin numHeads → ℝ :=
  fun h => headKernel n (rotatedInput n (rotations h) x) (rotatedInput n (rotations h) y)


theorem headKernel_symmetric (n : ℕ) (x y : Fin n → ℝ) :
    headKernel n x y = headKernel n y x := by
  unfold headKernel
  exact Finset.sum_congr rfl fun i _ => mul_comm _ _


theorem multiHeadKernel_symmetric (numHeads n : ℕ)
    (rotations : Fin numHeads → Fin n → Fin n → ℝ)
    (x y : Fin n → ℝ) (h : Fin numHeads) :
    multiHeadKernel numHeads n rotations x y h =
    multiHeadKernel numHeads n rotations y x h := by
  unfold multiHeadKernel
  exact headKernel_symmetric n _ _

/-! ## Part 3: Multi-Head Attention Mechanism -/


def headSoftmaxWeight (n : ℕ) (T : ℝ)
    (R : Fin n → Fin n → ℝ) (q k : Fin n → ℝ) : ℝ :=
  Real.exp (headKernel n (rotatedInput n R q) (rotatedInput n R k) / T)


theorem headSoftmaxWeight_pos (n : ℕ) (T : ℝ)
    (R : Fin n → Fin n → ℝ) (q k : Fin n → ℝ) :
    0 < headSoftmaxWeight n T R q k := by
  unfold headSoftmaxWeight; exact exp_pos _


def multiHeadStereoAttention (numHeads seqLen d : ℕ) (T : ℝ)
    (rotations : Fin numHeads → Fin d → Fin d → ℝ)
    (Wo : Fin numHeads → Fin d → Fin d → ℝ)
    (Q K V : Fin seqLen → Fin d → ℝ) : Fin seqLen → Fin d → ℝ :=
  fun i j =>
    ∑ h : Fin numHeads,
      let weights := fun k => headSoftmaxWeight d T (rotations h) (Q i) (K k)
      let totalWeight := ∑ k : Fin seqLen, weights k
      ∑ k : Fin seqLen,
        (weights k / totalWeight) * (∑ l, Wo h j l * V k l)


theorem multihead_weight_sum_pos (seqLen d : ℕ) (T : ℝ)
    (R : Fin d → Fin d → ℝ)
    (Q K : Fin seqLen → Fin d → ℝ) (i : Fin seqLen) :
    0 < ∑ k : Fin seqLen, headSoftmaxWeight d T R (Q i) (K k) := by
  exact Finset.sum_pos (fun k _ => headSoftmaxWeight_pos d T R (Q i) (K k))
    ⟨i, Finset.mem_univ _⟩

/-! ## Part 4: Theoretical Properties -/


def headConformalFactor (n : ℕ) (y : Fin n → ℝ) : ℝ :=
  2 / generalStereoDenom n y


theorem headConformalFactor_bounded (n : ℕ) (y : Fin n → ℝ) :
    0 < headConformalFactor n y ∧ headConformalFactor n y ≤ 2 := by
  refine ⟨by unfold headConformalFactor generalStereoDenom; positivity,
          by unfold headConformalFactor generalStereoDenom
             exact div_le_self (by positivity)
               (le_add_of_nonneg_right (Finset.sum_nonneg fun _ _ => sq_nonneg _))⟩


theorem multihead_gradient_bounded (numHeads : ℕ) (headGrads : Fin numHeads → ℝ)
    (hbound : ∀ h, |headGrads h| ≤ 2) :
    |∑ h, headGrads h| ≤ 2 * numHeads := by
  calc |∑ h, headGrads h|
      ≤ ∑ h, |headGrads h| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ _ : Fin numHeads, (2 : ℝ) := Finset.sum_le_sum fun h _ => hbound h
    _ = 2 * numHeads := by simp [Finset.sum_const, nsmul_eq_mul]; ring


end
