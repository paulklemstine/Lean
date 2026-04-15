/-! # CatalogBuild.EML.AIResearch.ScalingLaws

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 21
-/

import Mathlib

noncomputable section

def scalingLaw (A alpha L_inf : ℝ) (N : ℕ) : ℝ := A * (↑N : ℝ) ^ (-alpha) + L_inf


theorem loss_bounded_below (A alpha L_inf : ℝ) (N : ℕ) (hA : 0 ≤ A) (hN : 0 < N)
    (halpha : 0 ≤ alpha) :
    L_inf ≤ scalingLaw A alpha L_inf N := by
  unfold scalingLaw
  linarith [mul_nonneg hA (rpow_nonneg (by positivity : (0 : ℝ) ≤ ↑N) (-alpha))]

/-! ## §2. Compute-Optimal Training -/


def totalCompute (N D : ℕ) : ℕ := 6 * N * D

def chinchillaData (N : ℕ) : ℕ := 20 * N

def emlOptimalData (N : ℕ) : ℕ := 10 * N


theorem eml_less_data (N : ℕ) : emlOptimalData N ≤ chinchillaData N := by
  unfold emlOptimalData chinchillaData; omega


theorem eml_compute_savings (N : ℕ) :
    totalCompute N (emlOptimalData N) ≤ totalCompute N (chinchillaData N) := by
  unfold totalCompute emlOptimalData chinchillaData; nlinarith


theorem compute_linear_N (N1 N2 D : ℕ) (h : N1 ≤ N2) :
    totalCompute N1 D ≤ totalCompute N2 D := by
  unfold totalCompute; nlinarith

/-! ## §3. Emergent Capabilities -/


def capabilityThreshold (taskComplexity : ℕ) : ℕ := 2 ^ taskComplexity


theorem harder_tasks_bigger_models (c1 c2 : ℕ) (h : c1 ≤ c2) :
    capabilityThreshold c1 ≤ capabilityThreshold c2 := by
  unfold capabilityThreshold; exact Nat.pow_le_pow_right (by omega) h


def emlEffectiveCapacity (d w : ℕ) : ℕ := 3 ^ d * w

def mlpEffectiveCapacity (d w : ℕ) : ℕ := d * w


theorem eml_capacity_advantage (d w : ℕ) (hd : 2 ≤ d) (hw : 1 ≤ w) :
    mlpEffectiveCapacity d w ≤ emlEffectiveCapacity d w := by
  exact Nat.mul_le_mul_right _ ( Nat.le_of_lt ( Nat.recOn d ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ ] at * ; nlinarith ) )

/-! ## §4. Efficiency Frontiers -/


def dominates (accA accB : ℝ) (paramsA paramsB : ℕ) : Prop :=
  accB ≤ accA ∧ paramsA ≤ paramsB


theorem dominates_trans (a1 a2 a3 : ℝ) (p1 p2 p3 : ℕ)
    (h12 : dominates a1 a2 p1 p2) (h23 : dominates a2 a3 p2 p3) :
    dominates a1 a3 p1 p3 := by
  exact ⟨le_trans h23.1 h12.1, le_trans h12.2 h23.2⟩


def emlFlops (d w : ℕ) : ℕ := 4 * d * w + 2 * d

def mlpFlops (d w : ℕ) : ℕ := d * w * w


theorem eml_flop_efficiency (d w : ℕ) (hw : 5 ≤ w) (hd : 0 < d) :
    emlFlops d w ≤ mlpFlops d w := by
  exact Nat.le_of_not_lt fun h => by unfold emlFlops mlpFlops at h; nlinarith [ mul_le_mul_left' hw d ] ;

/-! ## §5. Data Efficiency -/


def standardSamples (params : ℕ) (targetAcc : ℝ) : ℝ := ↑params / targetAcc


def emlSamples (params : ℕ) (targetAcc efficiencyFactor : ℝ) : ℝ :=
  ↑params / (targetAcc * efficiencyFactor)


theorem eml_data_efficiency (p : ℕ) (a eff : ℝ) (ha : 0 < a) (heff : 1 ≤ eff) :
    emlSamples p a eff ≤ standardSamples p a := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by nlinarith )


end
