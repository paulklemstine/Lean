import Mathlib
import Probability.PositionalRateLinkRidge

/-!
# Escape rate of the ridge estimator on a separated design

`PositionalRateLinkInference.lean` proves that a (quasi-)separated design — the
configuration the round-80 ledger flagged on dense size-matched controls — has
**no** logistic maximum-likelihood estimate (`logistic_no_maximizer`), and
`PositionalRateLinkRidge.lean` proves that the ridge-penalised objective has
exactly one maximiser for every design and every `λ > 0`
(`exists_unique_penalized_max`).

This file closes the quantitative follow-up: *how fast does that unique ridge
estimate run away as the penalty is removed?*  Both sides of the sandwich are
proved, with no asymptotic machinery beyond elementary inequalities.

* `penalized_max_sqNorm_le` — **upper bound**: every ridge maximiser satisfies
  `λ ‖β‖² ≤ n log 2`, i.e. `‖β‖ = O(λ^{-1/2})`.
* `log_deficiency_lower_bound` — **the logarithmic lower bound mechanism**: for
  *any* coefficient vector, writing `δ = −ℓ(β) > 0` for its likelihood
  deficiency, every observation forces
  `log(1/δ) − δ ≤ ‖β‖ ‖xᵢ‖`.  A near-perfect fit costs norm at least
  logarithmically in the deficiency.
* `penalized_deficiency_le` and `penalized_deficiency_small` — the deficiency of
  the ridge estimate on a separated design is `≤ λ t² ‖w‖² − ℓ(t·w)` for every
  `t`, hence tends to `0` as `λ ↓ 0`.
* `ridge_escape` and `ridge_sqNorm_tendsto_atTop` — **the escape theorem**:
  combining the two, the unique ridge estimator on a separated design leaves
  every bounded set as `λ ↓ 0`, at a rate no faster than `λ^{-1/2}` and no
  slower than `log(1/δ_λ)/‖xᵢ‖`.
* `ridge_escape_sandwich` — the two bounds stated together.

Interpretation for the experiment: a "significant" odds ratio from a separated
control arm is not merely unstable, it diverges — and the ridge repair converts
that divergence into a bounded, uniquely determined estimate whose size is an
explicit function of the penalty.
-/

open Finset Filter Topology

namespace PositionalRateLink

variable {n d : ℕ}

/-! ### Cauchy–Schwarz for linear scores -/

/-- Cauchy–Schwarz: a linear score is controlled by the two squared norms. -/
lemma score_sq_le (β v : Fin d → ℝ) : (∑ j, β j * v j) ^ 2 ≤ sqNorm β * sqNorm v :=
  Finset.sum_mul_sq_le_sq_mul_sq Finset.univ β v

/-- Cauchy–Schwarz in absolute-value form. -/
lemma abs_score_le (β v : Fin d → ℝ) :
    |∑ j, β j * v j| ≤ Real.sqrt (sqNorm β) * Real.sqrt (sqNorm v) := by
  have h := Real.sqrt_le_sqrt (score_sq_le β v)
  rwa [Real.sqrt_sq_eq_abs, Real.sqrt_mul (sqNorm_nonneg β)] at h

/-- A vector with a nonzero linear score has positive squared norm. -/
lemma sqNorm_pos_of_score_ne (v w : Fin d → ℝ) (h : (∑ j, w j * v j) ≠ 0) : 0 < sqNorm v := by
  rcases (sqNorm_nonneg v).lt_or_eq with hpos | hzero
  · exact hpos
  · exfalso
    have hall : ∀ j ∈ (Finset.univ : Finset (Fin d)), (v j) ^ 2 = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg fun j _ => sq_nonneg _).1 ?_
      simpa [sqNorm] using hzero.symm
    exact h (Finset.sum_eq_zero fun j hj => by
      have : v j = 0 := by have := hall j hj; nlinarith [this]
      simp [this])

/-! ### Each observation sees the whole deficiency -/

/-- Every single log-likelihood contribution is at least the total
log-likelihood, because all contributions are nonpositive. -/
lemma logLik_le_logisticTerm (x : Fin n → Fin d → ℝ) (y : Fin n → Bool) (β : Fin d → ℝ)
    (i : Fin n) : logLik x y β ≤ logisticTerm (y i) (∑ j, β j * x i j) := by
  classical
  have hsub : ({i} : Finset (Fin n)) ⊆ Finset.univ := Finset.subset_univ _
  have := Finset.sum_le_sum_of_subset_of_nonpos (f := fun k => logisticTerm (y k) (∑ j, β j * x k j))
    hsub (fun k _ _ => (logisticTerm_neg _ _).le)
  simpa [logLik] using this

/-- A logistic contribution bounded below by `−δ` forces the score to have
absolute value at least `−log(e^δ − 1)`: near-perfect classification of a single
observation needs a large score. -/
lemma abs_score_ge_of_logisticTerm_ge {b : Bool} {z delta : ℝ} (hdelta : 0 < delta)
    (h : -delta ≤ logisticTerm b z) : -Real.log (Real.exp delta - 1) ≤ |z| := by
  have hpos : 0 < Real.exp delta - 1 := by
    have := Real.add_one_le_exp delta
    linarith
  -- `sigma` is the score with the sign that the label penalises
  set sigma : ℝ := if b then -z else z with hsigma
  have hterm : logisticTerm b z = -Real.log (1 + Real.exp sigma) := by
    cases b <;> simp [logisticTerm, hsigma]
  have hlog : Real.log (1 + Real.exp sigma) ≤ delta := by
    rw [hterm] at h; linarith
  have h1 : (0:ℝ) < 1 + Real.exp sigma := by have := Real.exp_pos sigma; linarith
  have hle : 1 + Real.exp sigma ≤ Real.exp delta := by
    have := Real.exp_le_exp.2 hlog
    rwa [Real.exp_log h1] at this
  have hexp : Real.exp sigma ≤ Real.exp delta - 1 := by linarith
  have hsig : sigma ≤ Real.log (Real.exp delta - 1) := by
    have := Real.log_le_log (Real.exp_pos sigma) hexp
    rwa [Real.log_exp] at this
  have habs : -sigma ≤ |z| := by
    cases b
    · simp only [hsigma, Bool.false_eq_true, if_false]
      exact (neg_le_abs z)
    · simp only [hsigma, if_true, neg_neg]
      exact le_abs_self z
  linarith

/-- Elementary comparison: `log(e^δ − 1) ≤ log δ + δ`, i.e. `−log(e^δ − 1)` is at
least `log(1/δ) − δ`. -/
lemma neg_log_exp_sub_one_ge {delta : ℝ} (hdelta : 0 < delta) :
    -Real.log delta - delta ≤ -Real.log (Real.exp delta - 1) := by
  have hpos : 0 < Real.exp delta - 1 := by
    have := Real.add_one_le_exp delta
    linarith
  have hkey : Real.exp delta - 1 ≤ delta * Real.exp delta := by
    have h := Real.add_one_le_exp (-delta)
    have hexp : Real.exp (-delta) * Real.exp delta = 1 := by
      rw [← Real.exp_add]; simp
    nlinarith [Real.exp_pos delta, Real.exp_pos (-delta)]
  have hlog := Real.log_le_log hpos hkey
  rw [Real.log_mul (ne_of_gt hdelta) (Real.exp_ne_zero delta), Real.log_exp] at hlog
  linarith

/-- **Logarithmic cost of a near-perfect fit.**  For any coefficient vector `β`
with likelihood deficiency `δ = −ℓ(β) > 0` and any observation `i`, the norm of
`β` is at least `(log(1/δ) − δ)/‖xᵢ‖`.  Driving the deficiency to zero therefore
costs norm growing like `log(1/δ)`. -/
theorem log_deficiency_lower_bound (x : Fin n → Fin d → ℝ) (y : Fin n → Bool)
    (β : Fin d → ℝ) (i : Fin n) (hdelta : 0 < -logLik x y β) :
    -Real.log (-logLik x y β) - (-logLik x y β)
      ≤ Real.sqrt (sqNorm β) * Real.sqrt (sqNorm (x i)) := by
  set delta : ℝ := -logLik x y β with hdef
  have hterm : -delta ≤ logisticTerm (y i) (∑ j, β j * x i j) := by
    have := logLik_le_logisticTerm x y β i
    simpa [hdef] using this
  have h1 := abs_score_ge_of_logisticTerm_ge hdelta hterm
  have h2 := neg_log_exp_sub_one_ge hdelta
  have h3 := abs_score_le β (x i)
  linarith

/-! ### The ridge estimate: upper bound and vanishing deficiency -/

/-- **Upper bound on the ridge estimator.**  Every maximiser of the penalised
objective satisfies `λ ‖β‖² ≤ n log 2`. -/
theorem penalized_max_sqNorm_le {x : Fin n → Fin d → ℝ} {y : Fin n → Bool} {lam : ℝ}
    {β : Fin d → ℝ}
    (hmax : ∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) :
    lam * sqNorm β ≤ (n : ℝ) * Real.log 2 := by
  have h0 := hmax (fun _ => 0)
  rw [penLogLik_zero] at h0
  have hle : logLik x y β ≤ 0 := logLik_nonpos x y β
  simp only [penLogLik] at h0
  linarith

/-- Consequently the ridge estimator is `O(λ^{-1/2})`. -/
theorem penalized_max_sqNorm_le_div {x : Fin n → Fin d → ℝ} {y : Fin n → Bool} {lam : ℝ}
    (hlam : 0 < lam) {β : Fin d → ℝ}
    (hmax : ∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) :
    sqNorm β ≤ (n : ℝ) * Real.log 2 / lam := by
  rw [le_div_iff₀ hlam, mul_comm]
  exact penalized_max_sqNorm_le hmax

lemma sqNorm_smul (t : ℝ) (w : Fin d → ℝ) : sqNorm (fun j => t * w j) = t ^ 2 * sqNorm w := by
  simp only [sqNorm, Finset.mul_sum]
  exact Finset.sum_congr rfl fun j _ => by ring

/-- The deficiency of the ridge estimate is controlled by any competitor along
the separating ray. -/
theorem penalized_deficiency_le {x : Fin n → Fin d → ℝ} {y : Fin n → Bool} {lam : ℝ}
    {β w : Fin d → ℝ} (hlam : 0 < lam)
    (hmax : ∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) (t : ℝ) :
    -logLik x y β ≤ -logLik x y (fun j => t * w j) + lam * (t ^ 2 * sqNorm w) := by
  have h := hmax (fun j => t * w j)
  simp only [penLogLik, sqNorm_smul] at h
  have hpen : 0 ≤ lam * sqNorm β := mul_nonneg hlam.le (sqNorm_nonneg β)
  linarith

/-- **The deficiency of the ridge estimate vanishes with the penalty.**  On a
separated design, for every `ε > 0` there is a `λ₀ > 0` such that every ridge
maximiser with `0 < λ < λ₀` fits the data to within `ε` in log-likelihood. -/
theorem penalized_deficiency_small {x : Fin n → Fin d → ℝ} {y : Fin n → Bool}
    {w : Fin d → ℝ} (hsep : Separates x y w) {eps : ℝ} (heps : 0 < eps) :
    ∃ lam0 : ℝ, 0 < lam0 ∧ ∀ lam : ℝ, 0 < lam → lam < lam0 →
      ∀ β : Fin d → ℝ, (∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) →
        -logLik x y β < eps := by
  have hlim := logLik_ray_tendsto hsep
  have hev := hlim.eventually (eventually_gt_nhds (by linarith : -(eps / 2) < (0:ℝ)))
  obtain ⟨t, ht⟩ := hev.exists
  set C : ℝ := t ^ 2 * sqNorm w with hC
  have hCnn : 0 ≤ C := by
    rw [hC]; exact mul_nonneg (sq_nonneg t) (sqNorm_nonneg w)
  refine ⟨(eps / 2) / (C + 1), by positivity, fun lam hlam hlt β hmax => ?_⟩
  have h1 := penalized_deficiency_le (w := w) hlam hmax t
  have h2 : lam * C < eps / 2 := by
    have hpos : (0:ℝ) < C + 1 := by linarith
    have : lam * (C + 1) < eps / 2 := by
      calc lam * (C + 1) < ((eps / 2) / (C + 1)) * (C + 1) := by
            exact mul_lt_mul_of_pos_right hlt hpos
        _ = eps / 2 := by field_simp
    nlinarith
  linarith [ht]

/-! ### The escape theorem -/

/-- **Escape.**  On a separated design the ridge estimator leaves every bounded
set as the penalty is removed: for every `M` there is a `λ₀ > 0` such that every
ridge maximiser with `0 < λ < λ₀` has `‖β‖² > M`. -/
theorem ridge_escape (hn : 0 < n) {x : Fin n → Fin d → ℝ} {y : Fin n → Bool}
    {w : Fin d → ℝ} (hsep : Separates x y w) (M : ℝ) :
    ∃ lam0 : ℝ, 0 < lam0 ∧ ∀ lam : ℝ, 0 < lam → lam < lam0 →
      ∀ β : Fin d → ℝ, (∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) →
        M < sqNorm β := by
  rcases lt_or_ge M 0 with hM | hM
  · exact ⟨1, one_pos, fun lam _ _ β _ => lt_of_lt_of_le hM (sqNorm_nonneg β)⟩
  -- the first observation has a nonzero row, because it is separated
  set i0 : Fin n := ⟨0, hn⟩ with hi0
  have hrow : 0 < sqNorm (x i0) := by
    refine sqNorm_pos_of_score_ne (x i0) w ?_
    have hs := hsep i0
    cases hy : y i0
    · exact ne_of_lt (hs.2 hy)
    · exact ne_of_gt (hs.1 hy)
  set K : ℝ := Real.sqrt (sqNorm (x i0)) with hK
  have hKpos : 0 < K := Real.sqrt_pos.2 hrow
  set eps : ℝ := min 1 (Real.exp (-(K * Real.sqrt M + 1))) with heps
  have hepspos : 0 < eps := lt_min one_pos (Real.exp_pos _)
  obtain ⟨lam0, hlam0, hsmall⟩ := penalized_deficiency_small hsep hepspos
  refine ⟨lam0, hlam0, fun lam hlam hlt β hmax => ?_⟩
  have hdef : -logLik x y β < eps := hsmall lam hlam hlt β hmax
  have hdpos : 0 < -logLik x y β := by
    have := logLik_lt_zero hn x y β
    linarith
  set delta : ℝ := -logLik x y β with hdelta
  -- the deficiency is small, hence its logarithm is very negative
  have hlogd : Real.log delta < -(K * Real.sqrt M + 1) := by
    have h1 : delta < Real.exp (-(K * Real.sqrt M + 1)) :=
      lt_of_lt_of_le hdef (min_le_right _ _)
    have := Real.log_lt_log hdpos h1
    rwa [Real.log_exp] at this
  have hd1 : delta < 1 := lt_of_lt_of_le hdef (min_le_left _ _)
  have hlow := log_deficiency_lower_bound x y β i0 hdpos
  have hchain : K * Real.sqrt M < Real.sqrt (sqNorm β) * K := by
    have : -Real.log delta - delta ≤ Real.sqrt (sqNorm β) * K := by
      simpa [hdelta, hK] using hlow
    linarith
  have hsqrtlt : Real.sqrt M < Real.sqrt (sqNorm β) := by
    have hcomm : Real.sqrt M * K < Real.sqrt (sqNorm β) * K := by
      rw [mul_comm (Real.sqrt M) K]; exact hchain
    exact lt_of_mul_lt_mul_right hcomm hKpos.le
  have hMsq : M < sqNorm β := by
    by_contra hcon
    push_neg at hcon
    exact absurd (Real.sqrt_le_sqrt hcon) (not_le.2 hsqrtlt)
  exact hMsq

/-- **Escape, filter form.**  Any selection of ridge maximisers on a separated
design has squared norm tending to infinity as `λ ↓ 0`. -/
theorem ridge_sqNorm_tendsto_atTop (hn : 0 < n) {x : Fin n → Fin d → ℝ} {y : Fin n → Bool}
    {w : Fin d → ℝ} (hsep : Separates x y w) (bhat : ℝ → Fin d → ℝ)
    (hmax : ∀ lam : ℝ, 0 < lam → ∀ γ : Fin d → ℝ,
      penLogLik x y lam γ ≤ penLogLik x y lam (bhat lam)) :
    Filter.Tendsto (fun lam => sqNorm (bhat lam)) (nhdsWithin 0 (Set.Ioi (0:ℝ)))
      Filter.atTop := by
  refine Filter.tendsto_atTop.2 fun M => ?_
  obtain ⟨lam0, hlam0, hesc⟩ := ridge_escape hn hsep M
  have hmem : Set.Ioo (0:ℝ) lam0 ∈ nhdsWithin (0:ℝ) (Set.Ioi (0:ℝ)) :=
    Ioo_mem_nhdsGT hlam0
  refine Filter.mem_of_superset hmem ?_
  rintro lam ⟨hpos, hlt⟩
  exact (hesc lam hpos hlt (bhat lam) (hmax lam hpos)).le

/-- **The sandwich.**  On a separated design the unique ridge estimator is
bounded above by `√(n log 2 / λ)` in squared norm, yet exceeds every fixed bound
once the penalty is small enough: the estimate diverges, but at a controlled
rate, and for each fixed `λ > 0` it is a genuine, uniquely determined estimator —
unlike the unpenalised fit, which does not exist at all. -/
theorem ridge_escape_sandwich (hn : 0 < n) {x : Fin n → Fin d → ℝ} {y : Fin n → Bool}
    {w : Fin d → ℝ} (hsep : Separates x y w) (M : ℝ) :
    (¬ ∃ β : Fin d → ℝ, ∀ γ : Fin d → ℝ, logLik x y γ ≤ logLik x y β) ∧
      (∀ lam : ℝ, 0 < lam → ∀ β : Fin d → ℝ,
        (∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) →
          sqNorm β ≤ (n : ℝ) * Real.log 2 / lam) ∧
      (∃ lam0 : ℝ, 0 < lam0 ∧ ∀ lam : ℝ, 0 < lam → lam < lam0 →
        ∀ β : Fin d → ℝ, (∀ γ : Fin d → ℝ, penLogLik x y lam γ ≤ penLogLik x y lam β) →
          M < sqNorm β) :=
  ⟨logistic_no_maximizer hn hsep,
    fun _ hlam _ hmax => penalized_max_sqNorm_le_div hlam hmax,
    ridge_escape hn hsep M⟩

end PositionalRateLink