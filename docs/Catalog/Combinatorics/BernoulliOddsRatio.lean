/-
# Integrating the Russo differential inequality: odds-ratio monotonicity

The Poincaré inequality of `Catalog/Combinatorics/BernoulliPoincare.lean` says
that the Bernoulli probability `P p = bernProb p A` of an increasing event obeys

`P (1 - P) ≤ p (1 - p) P'`.

Written in logistic form this is `(log (P/(1-P)))' ≥ (log (p/(1-p)))'`, so the
*logit gap*

`logitGap A p = log P - log (1-P) - log p + log (1-p)`

is nondecreasing on `(0,1)`.  Integrating gives the clean multiplicative
statement proved here: for a nondegenerate increasing event the odds ratio of the
event dominates the odds ratio of a single site,

`P p * (1 - P q) * (q * (1-p)) ≤ P q * (1 - P p) * (p * (1-q))`  for `p ≤ q`,

that is, `(P/(1-P)) / (p/(1-p))` is nondecreasing in `p`.  Equality holds for a
one-site event, so the bound is sharp; for an event depending on many sites it
is a quantitative sharp-threshold statement, strictly stronger than the
monotonicity and strict monotonicity results of the catalog.

## Main results

* `bernProb_lt_one`: nondegenerate events have probability `< 1` in the interior.
* `hasDerivAt_logitGap`: differentiability of the logit gap.
* `deriv_logitGap_nonneg`: the Poincaré inequality in logistic form.
* `monotoneOn_logitGap`: the logit gap is nondecreasing on `(0,1)`.
* `odds_ratio_mono`: the multiplicative odds-ratio comparison.
* `crossing_odds_ratio_mono`: the instance for grid crossings.
-/

import Combinatorics.BernoulliPoincare

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Nondegeneracy -/

/-- A event whose complement is nonempty has probability `< 1` in the interior. -/
theorem bernProb_lt_one {A : Set (ι → Bool)} (hnec : (Aᶜ : Set (ι → Bool)).Nonempty)
    {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) : bernProb p A < 1 := by
  have hpos := bernProb_pos hnec hp0 hp1
  have h := bernProb_add_bernProb_compl (ι := ι) p A
  linarith

/-! ## The logit gap -/

/-- The gap between the log-odds of the event and the log-odds of a single
site. -/
noncomputable def logitGap (A : Set (ι → Bool)) (p : ℝ) : ℝ :=
  Real.log (bernProb p A) - Real.log (1 - bernProb p A) - Real.log p + Real.log (1 - p)

/-- The logit gap is differentiable in the interior, with the expected
derivative. -/
theorem hasDerivAt_logitGap {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) :
    HasDerivAt (logitGap A)
      ((∑ v : ι, bernProb p (pivotalSet A v)) / bernProb p A
        + (∑ v : ι, bernProb p (pivotalSet A v)) / (1 - bernProb p A)
        - 1 / p - 1 / (1 - p)) p := by
  set d := ∑ v : ι, bernProb p (pivotalSet A v) with hd
  have hPpos : 0 < bernProb p A := bernProb_pos hne hp0 hp1
  have hPlt : bernProb p A < 1 := bernProb_lt_one hnec hp0 hp1
  have hP : HasDerivAt (fun t : ℝ => bernProb t A) d p := hasDerivAt_bernProb hA p
  have h1 : HasDerivAt (fun t : ℝ => Real.log (bernProb t A))
      (d / bernProb p A) p := hP.log (ne_of_gt hPpos)
  have hQ : HasDerivAt (fun t : ℝ => 1 - bernProb t A) (-d) p := by
    simpa using (hasDerivAt_const p (1 : ℝ)).sub hP
  have h2 : HasDerivAt (fun t : ℝ => Real.log (1 - bernProb t A))
      (-d / (1 - bernProb p A)) p := hQ.log (by linarith)
  have h3 : HasDerivAt (fun t : ℝ => Real.log t) (1 / p) p := by
    simpa [one_div] using Real.hasDerivAt_log (ne_of_gt hp0)
  have h4 : HasDerivAt (fun t : ℝ => Real.log (1 - t)) (-1 / (1 - p)) p := by
    have hlin : HasDerivAt (fun t : ℝ => 1 - t) (-1) p := by
      simpa using (hasDerivAt_const p (1 : ℝ)).sub (hasDerivAt_id p)
    exact hlin.log (by linarith)
  have hcomb := ((h1.sub h2).sub h3).add h4
  convert hcomb using 1
  ring

/-- **The Poincaré inequality in logistic form.**  The derivative of the logit
gap of an increasing event is nonnegative. -/
theorem deriv_logitGap_nonneg {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) : 0 ≤ deriv (logitGap A) p := by
  set d := ∑ v : ι, bernProb p (pivotalSet A v) with hd
  have hPpos : 0 < bernProb p A := bernProb_pos hne hp0 hp1
  have hPlt : bernProb p A < 1 := bernProb_lt_one hnec hp0 hp1
  rw [(hasDerivAt_logitGap hA hne hnec hp0 hp1).deriv]
  have hvar : bernProb p A * (1 - bernProb p A) ≤ p * (1 - p) * d :=
    bernProb_poincare hp0.le hp1.le hA
  have hPQ : 0 < bernProb p A * (1 - bernProb p A) := mul_pos hPpos (by linarith)
  have hpq : 0 < p * (1 - p) := mul_pos hp0 (by linarith)
  have hP0 : bernProb p A ≠ 0 := ne_of_gt hPpos
  have hP1 : (1 : ℝ) - bernProb p A ≠ 0 := ne_of_gt (by linarith)
  have hp0' : p ≠ 0 := ne_of_gt hp0
  have hp1' : (1 : ℝ) - p ≠ 0 := ne_of_gt (by linarith)
  have hsum1 : d / bernProb p A + d / (1 - bernProb p A)
      = d / (bernProb p A * (1 - bernProb p A)) := by
    field_simp
    ring
  have hsum2 : 1 / p + 1 / (1 - p) = 1 / (p * (1 - p)) := by
    field_simp
    ring
  have hkey : 1 / (p * (1 - p)) ≤ d / (bernProb p A * (1 - bernProb p A)) := by
    rw [div_le_div_iff₀ hpq hPQ, one_mul]
    linarith
  linarith [hsum1, hsum2, hkey]

/-- The logit gap of a nondegenerate increasing event is nondecreasing on the
open unit interval. -/
theorem monotoneOn_logitGap {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) :
    MonotoneOn (logitGap A) (Set.Ioo (0 : ℝ) 1) := by
  have hdiff : ∀ p ∈ Set.Ioo (0 : ℝ) 1, DifferentiableAt ℝ (logitGap A) p := by
    intro p hp
    exact (hasDerivAt_logitGap hA hne hnec hp.1 hp.2).differentiableAt
  refine monotoneOn_of_deriv_nonneg (convex_Ioo 0 1) ?_ ?_ ?_
  · exact fun p hp => (hdiff p hp).continuousAt.continuousWithinAt
  · rw [interior_Ioo]
    exact fun p hp => (hdiff p hp).differentiableWithinAt
  · rw [interior_Ioo]
    exact fun p hp => deriv_logitGap_nonneg hA hne hnec hp.1 hp.2

/-! ## The odds-ratio comparison -/

/-- **Odds-ratio monotonicity.**  For a nondegenerate increasing event the
quantity `(P/(1-P)) / (p/(1-p))` is nondecreasing in the density: the odds of the
event grow at least as fast as the odds of a single site.  Equality holds for a
one-site event. -/
theorem odds_ratio_mono {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p ≤ q) (hq1 : q < 1) :
    bernProb p A * (1 - bernProb q A) * (q * (1 - p)) ≤
      bernProb q A * (1 - bernProb p A) * (p * (1 - q)) := by
  have hp1 : p < 1 := lt_of_le_of_lt hpq hq1
  have hq0 : 0 < q := lt_of_lt_of_le hp0 hpq
  have hPp : 0 < bernProb p A := bernProb_pos hne hp0 hp1
  have hPq : 0 < bernProb q A := bernProb_pos hne hq0 hq1
  have hPp1 : bernProb p A < 1 := bernProb_lt_one hnec hp0 hp1
  have hPq1 : bernProb q A < 1 := bernProb_lt_one hnec hq0 hq1
  have hmono := monotoneOn_logitGap hA hne hnec ⟨hp0, hp1⟩ ⟨hq0, hq1⟩ hpq
  unfold logitGap at hmono
  have hPpne : bernProb p A ≠ 0 := ne_of_gt hPp
  have hPqne : bernProb q A ≠ 0 := ne_of_gt hPq
  have hPp1ne : (1 : ℝ) - bernProb p A ≠ 0 := ne_of_gt (by linarith)
  have hPq1ne : (1 : ℝ) - bernProb q A ≠ 0 := ne_of_gt (by linarith)
  have hpne : p ≠ 0 := ne_of_gt hp0
  have hqne : q ≠ 0 := ne_of_gt hq0
  have hp1ne : (1 : ℝ) - p ≠ 0 := ne_of_gt (by linarith)
  have hq1ne : (1 : ℝ) - q ≠ 0 := ne_of_gt (by linarith)
  have hlog : Real.log (bernProb p A * (1 - bernProb q A) * (q * (1 - p)))
      ≤ Real.log (bernProb q A * (1 - bernProb p A) * (p * (1 - q))) := by
    rw [Real.log_mul (mul_ne_zero hPpne hPq1ne) (mul_ne_zero hqne hp1ne),
      Real.log_mul hPpne hPq1ne, Real.log_mul hqne hp1ne,
      Real.log_mul (mul_ne_zero hPqne hPp1ne) (mul_ne_zero hpne hq1ne),
      Real.log_mul hPqne hPp1ne, Real.log_mul hpne hq1ne]
    linarith
  have hpos1 : 0 < bernProb p A * (1 - bernProb q A) * (q * (1 - p)) := by
    apply mul_pos (mul_pos hPp (by linarith)) (mul_pos hq0 (by linarith))
  have hpos2 : 0 < bernProb q A * (1 - bernProb p A) * (p * (1 - q)) := by
    apply mul_pos (mul_pos hPq (by linarith)) (mul_pos hp0 (by linarith))
  exact (Real.log_le_log_iff hpos1 hpos2).mp hlog


/-! ## Explicit threshold bounds from the odds-ratio comparison -/

/-- **Explicit sharp-threshold bound.**  If an increasing event has probability
`1/2` at density `p`, then at any larger density `q < 1` its probability is at
least `q(1-p) / (q(1-p) + p(1-q))`, the corresponding probability for a single
site.  For instance `q = 2p ≤ 1/2` already forces probability at least `2/3`. -/
theorem bernProb_ge_of_half {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p ≤ q) (hq1 : q < 1) (hhalf : bernProb p A = 1 / 2) :
    q * (1 - p) / (q * (1 - p) + p * (1 - q)) ≤ bernProb q A := by
  have hp1 : p < 1 := lt_of_le_of_lt hpq hq1
  have hq0 : 0 < q := lt_of_lt_of_le hp0 hpq
  have hden : 0 < q * (1 - p) + p * (1 - q) := by nlinarith
  have h := odds_ratio_mono hA hne hnec hp0 hpq hq1
  rw [hhalf] at h
  rw [div_le_iff₀ hden]
  nlinarith

/-- **Explicit sharp-threshold bound, lower side.**  Symmetrically, below the
half-probability density the probability is at most the single-site value. -/
theorem bernProb_le_of_half {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hnec : (Aᶜ : Set (ι → Bool)).Nonempty) {p q : ℝ}
    (hq0 : 0 < q) (hqp : q ≤ p) (hp1 : p < 1) (hhalf : bernProb p A = 1 / 2) :
    bernProb q A ≤ q * (1 - p) / (q * (1 - p) + p * (1 - q)) := by
  have hp0 : 0 < p := lt_of_lt_of_le hq0 hqp
  have hq1 : q < 1 := lt_of_le_of_lt hqp hp1
  have hden : 0 < q * (1 - p) + p * (1 - q) := by nlinarith
  have h := odds_ratio_mono hA hne hnec hq0 hqp hp1
  rw [hhalf] at h
  rw [le_div_iff₀ hden]
  nlinarith

/-- **The grid instance.**  The odds of a horizontal crossing of the `n × n` grid
grow at least as fast as the odds of a single open site. -/
theorem crossing_odds_ratio_mono (n : ℕ) (hn : 0 < n) {p q : ℝ} (hp0 : 0 < p)
    (hpq : p ≤ q) (hq1 : q < 1) :
    bernProb p (crossingEvent n hn) * (1 - bernProb q (crossingEvent n hn)) *
        (q * (1 - p)) ≤
      bernProb q (crossingEvent n hn) * (1 - bernProb p (crossingEvent n hn)) *
        (p * (1 - q)) := by
  refine odds_ratio_mono (crossingEvent_isIncreasing n hn)
    (crossingEvent_nonempty n hn) ⟨fun _ => false, ?_⟩ hp0 hpq hq1
  exact crossingEvent_false_notMem n hn

end BernoulliThresholdCoupling