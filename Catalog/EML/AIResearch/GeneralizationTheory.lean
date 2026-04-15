/-! # CatalogBuild.EML.AIResearch.GeneralizationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 19
-/

import Mathlib

noncomputable section

def mlpVC (d w : ℕ) : ℕ := d * w * w


theorem eml_lower_vc (d w : ℕ) (hw : 5 ≤ w) :
    emlVC d w ≤ mlpVC d w := by
  unfold emlVC mlpVC; nlinarith [ mul_le_mul_of_nonneg_left hw ( Nat.zero_le d ) ] ;


def shatteringBound (vc : ℕ) : ℕ := 2 ^ vc


theorem eml_less_overfitting (d w : ℕ) (hw : 5 ≤ w) :
    shatteringBound (emlVC d w) ≤ shatteringBound (mlpVC d w) := by
  unfold shatteringBound
  exact Nat.pow_le_pow_right (by omega) (eml_lower_vc d w hw)


def effectiveParams (totalParams : ℕ) (keepRate : ℝ) : ℝ := ↑totalParams * keepRate


theorem dropout_reduces_capacity (n : ℕ) (p : ℝ) (hn : 0 < n) (hp1 : p ≤ 1) :
    effectiveParams n p ≤ ↑n := by
  unfold effectiveParams; exact mul_le_of_le_one_right (by positivity) hp1


theorem more_dropout_less_params (n : ℕ) (p1 p2 : ℝ) (hn : 0 < n) (hp : p1 ≤ p2) :
    effectiveParams n p1 ≤ effectiveParams n p2 := by
  unfold effectiveParams; exact mul_le_mul_of_nonneg_left hp (by positivity)


theorem eml_less_dropout_needed (d w : ℕ) (p_eml p_std : ℝ)
    (hp_eml : 0 ≤ p_eml) (hp_std : 0 ≤ p_std) (hp : p_eml ≤ p_std)
    (hw : 5 ≤ w) :
    effectiveParams (emlVC d w) p_eml ≤ effectiveParams (mlpVC d w) p_std := by
  unfold effectiveParams; nlinarith [ show ( emlVC d w:ℝ ) ≤ mlpVC d w by exact_mod_cast eml_lower_vc d w hw ] ;


def l2Penalty (lam : ℝ) (normSq : ℝ) : ℝ := lam * normSq


def regularizedLoss (empiricalLoss lam normSq : ℝ) : ℝ :=
  empiricalLoss + l2Penalty lam normSq


theorem regularized_ge_empirical (L lam normSq : ℝ) (hlam : 0 ≤ lam) (hn : 0 ≤ normSq) :
    L ≤ regularizedLoss L lam normSq := by
  unfold regularizedLoss l2Penalty; linarith [mul_nonneg hlam hn]


theorem stronger_reg_more_loss (L lam1 lam2 normSq : ℝ) (hn : 0 ≤ normSq) (hlam : lam1 ≤ lam2) :
    regularizedLoss L lam1 normSq ≤ regularizedLoss L lam2 normSq := by
  unfold regularizedLoss l2Penalty; nlinarith


def biasAtCapacity (baseCapacity modelCapacity : ℕ) : ℝ :=
  ↑baseCapacity / ↑modelCapacity


theorem more_capacity_less_bias (b c1 c2 : ℕ) (hc1 : 0 < c1) (hc : c1 ≤ c2) :
    biasAtCapacity b c2 ≤ biasAtCapacity b c1 := by
  unfold biasAtCapacity;
  gcongr


def varianceEstimate (capacity n : ℕ) : ℝ := ↑capacity / ↑n


theorem more_data_less_variance (c n1 n2 : ℕ) (hn1 : 0 < n1) (hn : n1 ≤ n2) :
    varianceEstimate c n2 ≤ varianceEstimate c n1 := by
  unfold varianceEstimate;
  gcongr


def modernTestError (params data : ℕ) (noise : ℝ) : ℝ :=
  noise * ↑data / ↑params


theorem modern_regime_more_params_helps (p1 p2 data : ℕ) (noise : ℝ)
    (hp1 : 0 < p1) (hsigma : 0 ≤ noise) (hdata : 0 < data) (hp : p1 ≤ p2) :
    modernTestError p2 data noise ≤ modernTestError p1 data noise := by
  -- Use the fact that $p1 \leq p2$ to prove that $(noise * data / p2) \leq (noise * data / p1)$.
  have h_ineq : noise * data / (p2 : ℝ) ≤ noise * data / (p1 : ℝ) := by
    gcongr;
  exact h_ineq


theorem eml_reaches_interpolation_faster (d w : ℕ) (hw : 5 ≤ w) :
    emlVC d w ≤ mlpVC d w :=
  eml_lower_vc d w hw


end
