/-! # CatalogBuild.Geometry.Stereographic.GaugeInvariantLoss

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 16
-/

import Mathlib

noncomputable section

/-- The squared geodesic distance loss: sum of squared geodesic distances
between predictions and targets on the sphere. -/
def geodesicLoss (seqLen : ℕ)
    (pred target : Fin seqLen → ℝ) : ℝ :=
  ∑ i, (pred i - target i) ^ 2





/-- [Section: # CatalogBuild.Geometry.Stereographic.GaugeInvariantLoss
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 16] -/
theorem geodesicLoss_nonneg (seqLen : ℕ) (pred target : Fin seqLen → ℝ) :
    0 ≤ geodesicLoss seqLen pred target := by
  unfold geodesicLoss
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _





/-- [Section: # CatalogBuild.Geometry.Stereographic.GaugeInvariantLoss
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 16] -/
theorem geodesicLoss_symmetric (seqLen : ℕ) (pred target : Fin seqLen → ℝ) :
    geodesicLoss seqLen pred target = geodesicLoss seqLen target pred := by
  unfold geodesicLoss
  congr 1; ext i; ring





/-- [Section: # CatalogBuild.Geometry.Stereographic.GaugeInvariantLoss
Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 16] -/
theorem geodesicLoss_zero_self (seqLen : ℕ) (x : Fin seqLen → ℝ) :
    geodesicLoss seqLen x x = 0 := by
  unfold geodesicLoss; simp





/-- Conformal factor at a point. -/
def confFactor (d : ℕ) (x : Fin d → ℝ) : ℝ :=
  2 / (1 + ∑ i, (x i) ^ 2)





/-- Conformal-weighted loss: each token's contribution is weighted by its
conformal factor, giving points near the projection pole higher weight. -/
def conformalWeightedLoss (seqLen d : ℕ)
    (X : Fin seqLen → Fin d → ℝ)
    (losses : Fin seqLen → ℝ)
    (hlosses : ∀ i, 0 ≤ losses i) : ℝ :=
  ∑ i, confFactor d (X i) * losses i





theorem confFactor_pos (d : ℕ) (x : Fin d → ℝ) :
    0 < confFactor d x := by
  unfold confFactor; positivity





theorem conformalWeightedLoss_nonneg (seqLen d : ℕ)
    (X : Fin seqLen → Fin d → ℝ)
    (losses : Fin seqLen → ℝ)
    (hlosses : ∀ i, 0 ≤ losses i) :
    0 ≤ conformalWeightedLoss seqLen d X losses hlosses := by
  unfold conformalWeightedLoss
  exact Finset.sum_nonneg fun i _ =>
    mul_nonneg (le_of_lt (confFactor_pos d (X i))) (hlosses i)





/-- Gauge-invariant cross-entropy: the standard cross-entropy loss computed
in spherical coordinates. Since the log-softmax values are computed from
inner products on the sphere, and inner products on the sphere are invariant
under rotations (a subgroup of Möbius), this loss has partial gauge invariance. -/
def gaugeInvariantCE (seqLen : ℕ) (logits : Fin seqLen → ℝ)
    (target : Fin seqLen) : ℝ :=
  let maxLogit := Finset.sup' Finset.univ ⟨target, Finset.mem_univ _⟩ logits
  let shifted : Fin seqLen → ℝ := fun i => logits i - maxLogit
  Real.log (∑ i, Real.exp (shifted i)) - shifted target





theorem gaugeInvariantCE_nonneg (seqLen : ℕ) (logits : Fin seqLen → ℝ)
    (target : Fin seqLen) (hseq : 0 < seqLen) :
    0 ≤ gaugeInvariantCE seqLen logits target := by
  exact sub_nonneg_of_le ( Real.le_log_iff_exp_le ( Finset.sum_pos ( fun _ _ => Real.exp_pos _ ) ⟨ target, Finset.mem_univ _ ⟩ ) |>.2 <| by nth_rw 1 [ Finset.sum_eq_add_sum_diff_singleton <| Finset.mem_univ target ] ; exact le_add_of_le_of_nonneg ( by simp +decide [ Real.exp_sub ] ) <| Finset.sum_nonneg fun _ _ => by positivity )





/-- Spherical variance: measures how spread out a set of points is on the
sphere. Equal to 1 - ‖mean‖ where mean is the centroid on the sphere. -/
def sphericalVariance (seqLen d : ℕ) (X : Fin seqLen → Fin d → ℝ) : ℝ :=
  let mean := fun j : Fin d => (∑ i : Fin seqLen, X i j) / seqLen
  1 - ∑ j, (mean j) ^ 2





/-- The spherical mean squared norm is non-negative. -/
theorem sphericalMeanSqNorm_nonneg (seqLen d : ℕ) (X : Fin seqLen → Fin d → ℝ) :
    0 ≤ ∑ j : Fin d, ((∑ i : Fin seqLen, X i j) / seqLen) ^ 2 :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _





/-- A distance function on ℝⁿ that transforms covariantly under the conformal
factor: d_conf(x,y) = cf(x) · cf(y) · ‖x - y‖². -/
def conformalDistance (d : ℕ) (x y : Fin d → ℝ) : ℝ :=
  confFactor d x * confFactor d y * ∑ i, (x i - y i) ^ 2





theorem conformalDistance_nonneg (d : ℕ) (x y : Fin d → ℝ) :
    0 ≤ conformalDistance d x y := by
  unfold conformalDistance
  apply mul_nonneg
  · exact mul_nonneg (le_of_lt (confFactor_pos d x)) (le_of_lt (confFactor_pos d y))
  · exact Finset.sum_nonneg fun _ _ => sq_nonneg _





theorem conformalDistance_symmetric (d : ℕ) (x y : Fin d → ℝ) :
    conformalDistance d x y = conformalDistance d y x := by
  unfold conformalDistance
  congr 1
  · ring
  · congr 1; ext i; ring





theorem conformalDistance_zero_self (d : ℕ) (x : Fin d → ℝ) :
    conformalDistance d x x = 0 := by
  unfold conformalDistance; simp





end
