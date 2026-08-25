import Mathlib
import Probability.PositionalRateLinkInference
import Probability.NeuralCoding.SoftplusTheory

/-!
# Ridge-penalised occupancy regression: existence and uniqueness under separation

`PositionalRateLinkInference.lean` proves the negative half of the round-80
ledger flag: when a design is (quasi-)separated — which is what dense
size-matched control arms produce — the logistic log-likelihood has **no**
maximiser (`logistic_no_maximizer`), so the reported odds ratios are artefacts of
the optimiser's clipping bound.

This file proves the positive half, i.e. the repair proposed as follow-up
direction 3: adding a ridge penalty makes the estimator exist and be unique for
*every* design, separated or not.

* `PositionalRateLink.penLogLik` — the ridge-penalised logistic log-likelihood
  `ℓ(β) − λ‖β‖²`.
* `PositionalRateLink.penLogLik_midpoint_strict` — strict concavity in midpoint
  form: the likelihood part is concave (convexity of softplus composed with a
  linear score) and the penalty is strictly concave by the parallelogram law.
* `PositionalRateLink.exists_penalized_max` — existence: the objective is
  coercive, so a maximiser exists on a compact ball and is global.
* `PositionalRateLink.exists_unique_penalized_max` — existence **and**
  uniqueness of the ridge estimator.
* `PositionalRateLink.separated_penalized_max_exists` — the contrast with the
  unpenalised fit: on a separated design the maximum-likelihood estimate does not
  exist while the ridge estimate does.  Design B is usable for control arms once
  it is penalised.
-/

open Finset Set

namespace PositionalRateLink

variable {n d : ℕ}

/-! ### The objective -/

/-- Squared Euclidean norm of a coefficient vector. -/
def sqNorm (β : Fin d → ℝ) : ℝ := ∑ j, (β j) ^ 2

lemma sqNorm_nonneg (β : Fin d → ℝ) : 0 ≤ sqNorm β :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- The ridge-penalised logistic log-likelihood. -/
noncomputable def penLogLik (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) (lam : ℝ)
    (β : Fin d → ℝ) : ℝ := logLik x y β - lam * sqNorm β

/-! ### The likelihood part is concave -/

/-- The per-observation log-likelihood in softplus form: a linear term minus a
convex function of the score. -/
lemma logisticTerm_eq_sub_softplus (b : Bool) (z : ℝ) :
    logisticTerm b z = (if b then z else 0) - softplus z := by
  cases b
  · simp [logisticTerm, softplus]
  · have h := softplus_reflection z
    have hz : logisticTerm true z = -softplus (-z) := by
      simp [logisticTerm, softplus]
    rw [hz]
    simp only [if_true]
    linarith

/-- Midpoint concavity of a single log-likelihood contribution. -/
lemma logisticTerm_midpoint_concave (b : Bool) (z w : ℝ) :
    (logisticTerm b z + logisticTerm b w) / 2 ≤ logisticTerm b ((z + w) / 2) := by
  have hsp : softplus ((z + w) / 2) ≤ (softplus z + softplus w) / 2 := by
    have h := softplus_convex.2 (Set.mem_univ z) (Set.mem_univ w)
      (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num : (0:ℝ) ≤ 1 / 2) (by norm_num)
    simp only [smul_eq_mul] at h
    have h1 : (1:ℝ) / 2 * z + 1 / 2 * w = (z + w) / 2 := by ring
    rw [h1] at h
    linarith
  rw [logisticTerm_eq_sub_softplus, logisticTerm_eq_sub_softplus,
    logisticTerm_eq_sub_softplus]
  cases b <;> simp <;> linarith

/-- Scores are linear in the coefficient vector, so midpoints of coefficients
give midpoints of scores. -/
lemma score_midpoint (x : Fin n → Fin d → ℝ) (β γ : Fin d → ℝ) (i : Fin n) :
    (∑ j, ((β j + γ j) / 2) * x i j)
      = ((∑ j, β j * x i j) + (∑ j, γ j * x i j)) / 2 := by
  rw [← Finset.sum_add_distrib, Finset.sum_div]
  exact Finset.sum_congr rfl fun j _ => by ring

/-- **Concavity of the logistic log-likelihood** (midpoint form). -/
lemma logLik_midpoint_concave (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) (β γ : Fin d → ℝ) :
    (logLik x y β + logLik x y γ) / 2 ≤ logLik x y (fun j => (β j + γ j) / 2) := by
  rw [logLik, logLik, logLik, ← Finset.sum_add_distrib, Finset.sum_div]
  refine Finset.sum_le_sum fun i _ => ?_
  rw [score_midpoint x β γ i]
  exact logisticTerm_midpoint_concave _ _ _

/-! ### The penalty is strictly concave -/

/-- Parallelogram law: the squared norm is strictly convex, hence its negative is
strictly concave. -/
lemma sqNorm_midpoint_lt {β γ : Fin d → ℝ} (h : β ≠ γ) :
    sqNorm (fun j => (β j + γ j) / 2) < (sqNorm β + sqNorm γ) / 2 := by
  have hdiff : 0 < ∑ j, (β j - γ j) ^ 2 := by
    obtain ⟨j0, hj0⟩ := Function.ne_iff.1 h
    refine Finset.sum_pos' (fun j _ => sq_nonneg _) ⟨j0, Finset.mem_univ _, ?_⟩
    exact pow_pos (abs_pos.2 (sub_ne_zero.2 hj0)) 2 |>.trans_le (le_of_eq (sq_abs _))
  have hkey : sqNorm (fun j => (β j + γ j) / 2)
      = (sqNorm β + sqNorm γ) / 2 - (∑ j, (β j - γ j) ^ 2) / 4 := by
    simp only [sqNorm]
    rw [← Finset.sum_add_distrib, Finset.sum_div, Finset.sum_div, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [hkey]
  linarith

/-- **Strict concavity of the penalised objective** (midpoint form). -/
theorem penLogLik_midpoint_strict {x : Fin n → Fin d → ℝ} {y : Fin n → Bool} {lam : ℝ}
    (hlam : 0 < lam) {β γ : Fin d → ℝ} (h : β ≠ γ) :
    (penLogLik x y lam β + penLogLik x y lam γ) / 2
      < penLogLik x y lam (fun j => (β j + γ j) / 2) := by
  have h1 := logLik_midpoint_concave x y β γ
  have h2 := sqNorm_midpoint_lt h
  have h3 : lam * sqNorm (fun j => (β j + γ j) / 2) < lam * ((sqNorm β + sqNorm γ) / 2) :=
    mul_lt_mul_of_pos_left h2 hlam
  simp only [penLogLik]
  linarith

/-! ### Existence -/

lemma logisticTerm_continuous (b : Bool) : Continuous (fun z : ℝ => logisticTerm b z) := by
  have hcont : ∀ s : ℝ → ℝ, Continuous s →
      Continuous (fun z : ℝ => -Real.log (1 + Real.exp (s z))) := by
    intro s hs
    refine Continuous.neg (Continuous.log (continuous_const.add (Real.continuous_exp.comp hs)) ?_)
    intro z
    have := Real.exp_pos (s z)
    linarith
  cases b
  · simpa [logisticTerm] using hcont id continuous_id
  · simpa [logisticTerm] using hcont (fun z => -z) continuous_neg

lemma logLik_continuous (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) :
    Continuous (fun β : Fin d → ℝ => logLik x y β) := by
  refine continuous_finset_sum _ fun i _ => ?_
  refine (logisticTerm_continuous (y i)).comp ?_
  exact continuous_finset_sum _ fun j _ => (continuous_apply j).mul continuous_const

lemma sqNorm_continuous : Continuous (fun β : Fin d → ℝ => sqNorm β) :=
  continuous_finset_sum _ fun j _ => (continuous_apply j).pow 2

lemma penLogLik_continuous (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) (lam : ℝ) :
    Continuous (fun β : Fin d → ℝ => penLogLik x y lam β) :=
  (logLik_continuous x y).sub (continuous_const.mul sqNorm_continuous)

lemma logLik_nonpos (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) (β : Fin d → ℝ) :
    logLik x y β ≤ 0 :=
  Finset.sum_nonpos fun _ _ => (logisticTerm_neg _ _).le

lemma logisticTerm_zero (b : Bool) : logisticTerm b 0 = -Real.log 2 := by
  cases b <;> norm_num [logisticTerm]

lemma penLogLik_zero (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) (lam : ℝ) :
    penLogLik x y lam (fun _ => 0) = -(n : ℝ) * Real.log 2 := by
  have hz : ∀ i : Fin n, (∑ j, (0 : ℝ) * x i j) = 0 := by
    intro i; simp
  simp only [penLogLik, logLik, sqNorm, hz, logisticTerm_zero]
  simp

/-- Sublevel sets of the squared norm are compact. -/
lemma isCompact_sqNorm_le (R : ℝ) : IsCompact {β : Fin d → ℝ | sqNorm β ≤ R} := by
  refine Metric.isCompact_of_isClosed_isBounded (isClosed_le sqNorm_continuous continuous_const) ?_
  refine Bornology.IsBounded.subset (Metric.isBounded_closedBall (x := (0 : Fin d → ℝ))
    (r := Real.sqrt R)) ?_
  intro β hβ
  have hR : 0 ≤ R := le_trans (sqNorm_nonneg β) hβ
  simp only [Metric.mem_closedBall, dist_zero_right]
  rw [pi_norm_le_iff_of_nonneg (Real.sqrt_nonneg R)]
  intro j
  have hj : (β j) ^ 2 ≤ R :=
    le_trans (Finset.single_le_sum (f := fun j => (β j) ^ 2)
      (fun k _ => sq_nonneg _) (Finset.mem_univ j)) hβ
  have : |β j| ≤ Real.sqrt R := by
    have := Real.sqrt_le_sqrt hj
    rwa [Real.sqrt_sq_eq_abs] at this
  simpa [Real.norm_eq_abs] using this

/-- **Existence of the ridge estimator.**  For every design and every `λ > 0` the
penalised log-likelihood attains a global maximum. -/
theorem exists_penalized_max (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) {lam : ℝ}
    (hlam : 0 < lam) : ∃ β : Fin d → ℝ, ∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β := by
  classical
  set R : ℝ := (n : ℝ) * Real.log 2 / lam with hR
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hR0 : 0 ≤ R := by
    rw [hR]; positivity
  set K : Set (Fin d → ℝ) := {β | sqNorm β ≤ R} with hK
  have hKne : K.Nonempty := ⟨fun _ => 0, by simp [hK, sqNorm, hR0]⟩
  obtain ⟨β, hβK, hβmax⟩ := (isCompact_sqNorm_le (d := d) R).exists_isMaxOn hKne
    (penLogLik_continuous x y lam).continuousOn
  refine ⟨β, fun γ => ?_⟩
  by_cases hγ : γ ∈ K
  · exact hβmax hγ
  · -- outside the ball the objective is below its value at the origin
    have hγR : R < sqNorm γ := by
      simpa [hK, not_le] using hγ
    have h0K : (fun _ => (0 : ℝ)) ∈ K := by simp [hK, sqNorm, hR0]
    have hzero := penLogLik_zero x y lam
    have hbound : penLogLik x y lam γ < -(n : ℝ) * Real.log 2 := by
      have h1 : penLogLik x y lam γ ≤ -(lam * sqNorm γ) := by
        have := logLik_nonpos x y γ
        simp only [penLogLik]
        linarith
      have h2 : lam * R < lam * sqNorm γ := mul_lt_mul_of_pos_left hγR hlam
      have h3 : lam * R = (n : ℝ) * Real.log 2 := by
        rw [hR]; field_simp
      linarith
    have h4 : penLogLik x y lam (fun _ => 0) ≤ penLogLik x y lam β := hβmax h0K
    rw [hzero] at h4
    linarith

/-- **Existence and uniqueness of the ridge estimator.**  The penalised logistic
log-likelihood has exactly one maximiser, for every design matrix and every
`λ > 0`.  Coercivity gives existence, strict concavity gives uniqueness. -/
theorem exists_unique_penalized_max (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) {lam : ℝ}
    (hlam : 0 < lam) :
    ∃! β : Fin d → ℝ, ∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β := by
  obtain ⟨β, hβ⟩ := exists_penalized_max x y hlam
  refine ⟨β, hβ, fun γ hγ => ?_⟩
  by_contra hne
  have hne' : γ ≠ β := hne
  have hstrict := penLogLik_midpoint_strict (x := x) (y := y) hlam hne'
  have h1 : penLogLik x y lam β ≤ penLogLik x y lam γ := hγ β
  have h2 : penLogLik x y lam γ ≤ penLogLik x y lam β := hβ γ
  have h3 : penLogLik x y lam (fun j => (γ j + β j) / 2) ≤ penLogLik x y lam β := hβ _
  linarith

/-- **The repair, stated against the failure.**  On a separated design the
unpenalised maximum-likelihood estimate does not exist, while the ridge-penalised
estimate exists and is unique.  This is exactly the fix for the flagged
control-arm family-B fit. -/
theorem separated_penalized_max_exists (hn : 0 < n) {x : Fin n → Fin d → ℝ} {y : Fin n → Bool}
    {w : Fin d → ℝ} (hsep : Separates x y w) {lam : ℝ} (hlam : 0 < lam) :
    (¬ ∃ β : Fin d → ℝ, ∀ γ : Fin d → ℝ, logLik x y γ ≤ logLik x y β) ∧
      (∃! β : Fin d → ℝ, ∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) :=
  ⟨logistic_no_maximizer hn hsep, exists_unique_penalized_max x y hlam⟩

end PositionalRateLink