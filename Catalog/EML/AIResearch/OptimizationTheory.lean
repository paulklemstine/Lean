/-! # CatalogBuild.EML.AIResearch.OptimizationTheory

Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.EML.AIResearch.OptimizationTheory
Auto-generated from theorem catalog database.
Domain: EML/AIResearch
Declarations: 18] -/
def constLR (eta : ℝ) (_ : ℕ) : ℝ := eta



def expDecayLR (eta gamma : ℝ) (t : ℕ) : ℝ := eta * gamma ^ t



theorem exp_decay_pos (eta gamma : ℝ) (t : ℕ) (heta : 0 < eta) (hgamma : 0 < gamma) :
    0 < expDecayLR eta gamma t := by
  unfold expDecayLR; positivity



theorem exp_decay_mono (eta gamma : ℝ) (t1 t2 : ℕ) (heta : 0 < eta)
    (hgamma0 : 0 ≤ gamma) (hgamma1 : gamma ≤ 1) (ht : t1 ≤ t2) :
    expDecayLR eta gamma t2 ≤ expDecayLR eta gamma t1 := by
  unfold expDecayLR
  exact mul_le_mul_of_nonneg_left (pow_le_pow_of_le_one hgamma0 hgamma1 ht) (le_of_lt heta)



def warmupLR (eta : ℝ) (W t : ℕ) : ℝ :=
  if t ≤ W then eta * ↑t / ↑W else eta



theorem warmup_reaches_target (eta : ℝ) (W : ℕ) (hW : 0 < W) :
    warmupLR eta W W = eta := by
  simp [warmupLR, le_refl]; field_simp



def momentumUpdate (beta v g : ℝ) : ℝ := beta * v + g



theorem higher_momentum_more_velocity (beta1 beta2 v g : ℝ) (hv : 0 ≤ v) (hg : 0 ≤ g)
    (hbeta : beta1 ≤ beta2) :
    momentumUpdate beta1 v g ≤ momentumUpdate beta2 v g := by
  unfold momentumUpdate; nlinarith



def clipGrad (g tau : ℝ) : ℝ := min (|g|) tau



theorem clip_bounded (g tau : ℝ) :
    clipGrad g tau ≤ tau := by
  unfold clipGrad; exact min_le_right _ _



theorem clip_preserves_small (g tau : ℝ) (h : |g| ≤ tau) :
    clipGrad g tau = |g| := by
  unfold clipGrad; exact min_eq_left h



theorem clip_reduces_large (g tau : ℝ) (h : tau ≤ |g|) :
    clipGrad g tau = tau := by
  unfold clipGrad; exact min_eq_right h



def optimalStepSize (L : ℝ) : ℝ := 1 / L



theorem optimal_step_pos (L : ℝ) (hL : 0 < L) : 0 < optimalStepSize L := by
  unfold optimalStepSize; positivity



def emlCurvatureBound (maxWeight : ℝ) : ℝ := maxWeight ^ 2



theorem eml_curvature_scales (w1 w2 : ℝ) (hw : |w1| ≤ |w2|) :
    emlCurvatureBound w1 ≤ emlCurvatureBound w2 := by
  unfold emlCurvatureBound;
  simpa [ sq_le_sq ] using hw



def emlConvergenceRate (L : ℝ) (d : ℕ) (t : ℕ) (R : ℝ) : ℝ :=
  L * R ^ 2 / (2 * ↑t * ↑d)



theorem eml_depth_helps_convergence (L R : ℝ) (d1 d2 t : ℕ) (hL : 0 < L) (hR : 0 ≤ R)
    (ht : 0 < t) (hd1 : 0 < d1) (hd : d1 ≤ d2) :
    emlConvergenceRate L d2 t R ≤ emlConvergenceRate L d1 t R := by
  exact div_le_div_of_nonneg_left ( by positivity ) ( by positivity ) ( by gcongr )



end
