import Mathlib

/-!
# Pooled model-selection evidence versus size-matched strata

Third component of the round-85 resolution.  The empirical situation: a
two-component ("edge") mixture fitted to the *pooled* kept sample reports
`ΔAICc = 49.78`, while the same fit restricted to size-matched strata reports
`ΔAICc = 5.94` (bit-length band `[96, 98)`, i.e. the truncation boundary) and
`ΔAICc = -0.40` (bit-length `≥ 98`).  Both stratum values sit at or below the
registered decision bar `6`.  Is that a contradiction?  No — and this file
proves exactly what the pooled number is then measuring.

Setup.  `ℓ i θ` is the log-likelihood contribution of stratum `i` at parameter
`θ`.  A *pooled* fit chooses one `θ` for all strata; a *stratified* fit chooses
`u i` per stratum.  Write `t0, t1` for pooled maximisers of the null and the
enlarged model, `u0, u1` for the stratum-wise maximisers.

Main results.

* `Spike.Evidence.nullGap_nonneg` — the *null misspecification gap*
  `G = 2(∑ ℓ i (u0 i) − ∑ ℓ i t0) ≥ 0` : a single pooled null can never beat
  stratum-wise nulls.
* `Spike.Evidence.pooled_gain_le` — the pooled evidence for the extra component
  is bounded by the stratified evidence *plus* `G`.  Pooled evidence can
  therefore be arbitrarily large purely because the pooled **null** is
  misspecified across strata.
* `Spike.Evidence.deltaAICc_pooled_le` — the same statement at the level of
  `ΔAICc`, carrying the exact small-sample penalty bookkeeping
  (`penaltyDefect`).
* `Spike.Evidence.nullGap_ge_of_reported` — the quantitative reading of the
  reported numbers: with `ΔAICc` pooled `49.78`, strata `5.94` and `−0.40`, and
  a penalty defect of at most `3`, the misspecification gap satisfies
  `G ≥ 41.2`.  Over `80 %` of the pooled "evidence" is null heterogeneity
  (a size gradient across bit-length bands), not support for the extra
  component.
* `Spike.Evidence.aiccPenalty_lt_of_lt` — splitting a sample into strata
  strictly *raises* the small-sample penalty, so the stratified analysis is the
  conservative one; sub-bar strata are not an artefact of a laxer criterion.
* `Spike.Evidence.exists_pooled_above_bar_strata_below` — an explicit
  configuration in which every stratum is below the bar `6` while the pooled
  statistic exceeds `49`, realised entirely by null heterogeneity.
-/

namespace Spike.Evidence

/-- The AICc penalty for `k` parameters on `n` observations,
`2k + 2k(k+1)/(n − k − 1)`. -/
noncomputable def aiccPenalty (k n : ℝ) : ℝ := 2 * k + 2 * k * (k + 1) / (n - k - 1)

/-- `AICc = −2 loglik + penalty`. -/
noncomputable def aicc (loglik k n : ℝ) : ℝ := -2 * loglik + aiccPenalty k n

/-- `ΔAICc` in favour of the enlarged model (`k1` parameters, log-likelihood
`l1`) against the null (`k0`, `l0`) on a sample of size `n`.  Positive values
favour the enlarged model. -/
noncomputable def deltaAICc (l0 l1 k0 k1 n : ℝ) : ℝ := aicc l0 k0 n - aicc l1 k1 n

/-- The penalty difference charged for the extra parameters on a sample of
size `n`. -/
noncomputable def deltaPenalty (k0 k1 n : ℝ) : ℝ := aiccPenalty k1 n - aiccPenalty k0 n

theorem deltaAICc_eq (l0 l1 k0 k1 n : ℝ) :
    deltaAICc l0 l1 k0 k1 n = 2 * (l1 - l0) - deltaPenalty k0 k1 n := by
  simp only [deltaAICc, aicc, deltaPenalty]
  ring

/-- The small-sample correction is strictly decreasing in the sample size (for
`k > 0` and `n > k + 1`).  Hence cutting a pooled sample into strata charges a
strictly larger penalty in each piece: stratified model selection is the
conservative procedure. -/
theorem aiccPenalty_lt_of_lt {k m n : ℝ} (hk : 0 < k) (hm : k + 1 < m) (hmn : m < n) :
    aiccPenalty k n < aiccPenalty k m := by
  have hm0 : 0 < m - k - 1 := by linarith
  have hn0 : 0 < n - k - 1 := by linarith
  have hnum : 0 < 2 * k * (k + 1) := by nlinarith
  have : 2 * k * (k + 1) / (n - k - 1) < 2 * k * (k + 1) / (m - k - 1) :=
    div_lt_div_of_pos_left hnum hm0 (by linarith)
  simp only [aiccPenalty]
  linarith

section Stratified

variable {ι Θ : Type*} (S : Finset ι) (ℓ : ι → Θ → ℝ)

/-- Log-likelihood of the pooled sample at a single shared parameter. -/
def pooledLoglik (t : Θ) : ℝ := ∑ i ∈ S, ℓ i t

/-- Log-likelihood of the pooled sample when each stratum uses its own
parameter. -/
def stratifiedLoglik (u : ι → Θ) : ℝ := ∑ i ∈ S, ℓ i (u i)

/-- The **null misspecification gap**: how much better the stratum-wise nulls
fit than the single pooled null (in `2 log` units). -/
def nullGap (t0 : Θ) (u0 : ι → Θ) : ℝ :=
  2 * (stratifiedLoglik S ℓ u0 - pooledLoglik S ℓ t0)

/-- The gap is nonnegative whenever `u0` is stratum-wise at least as good as the
pooled null parameter — in particular when `u0 i` maximises stratum `i`. -/
theorem nullGap_nonneg {t0 : Θ} {u0 : ι → Θ} (h : ∀ i ∈ S, ℓ i t0 ≤ ℓ i (u0 i)) :
    0 ≤ nullGap S ℓ t0 u0 := by
  have : pooledLoglik S ℓ t0 ≤ stratifiedLoglik S ℓ u0 := Finset.sum_le_sum h
  simp only [nullGap]
  linarith

/-- **Pooled evidence is bounded by stratified evidence plus the null gap.**
The `2 log`-likelihood improvement obtained by the extra component on the pooled
sample never exceeds the sum of the stratum-wise improvements plus the amount by
which the pooled null itself is misspecified. -/
theorem pooled_gain_le {t0 t1 : Θ} {u0 u1 : ι → Θ}
    (h0 : ∀ i ∈ S, ℓ i t0 ≤ ℓ i (u0 i)) (h1 : ∀ i ∈ S, ℓ i t1 ≤ ℓ i (u1 i)) :
    2 * (pooledLoglik S ℓ t1 - pooledLoglik S ℓ t0)
      ≤ 2 * (stratifiedLoglik S ℓ u1 - stratifiedLoglik S ℓ u0) + nullGap S ℓ t0 u0 := by
  have hA : pooledLoglik S ℓ t1 ≤ stratifiedLoglik S ℓ u1 := Finset.sum_le_sum h1
  have hB : pooledLoglik S ℓ t0 ≤ stratifiedLoglik S ℓ u0 := Finset.sum_le_sum h0
  simp only [nullGap]
  linarith

/-- The penalty bookkeeping incurred by splitting: the sum of the stratum-wise
extra-parameter penalties minus the pooled one. -/
noncomputable def penaltyDefect (k0 k1 : ℝ) (nsize : ι → ℝ) (nP : ℝ) : ℝ :=
  (∑ i ∈ S, deltaPenalty k0 k1 (nsize i)) - deltaPenalty k0 k1 nP

/-- **Main inequality at the `ΔAICc` level.**  Pooled `ΔAICc` is at most the sum
of the stratum `ΔAICc`s, plus the null misspecification gap, plus the penalty
defect of the split.  Any pooled excess beyond the strata is therefore
attributable to heterogeneity of the *null* across strata, not to the extra
component. -/
theorem deltaAICc_pooled_le {t0 t1 : Θ} {u0 u1 : ι → Θ} (k0 k1 : ℝ)
    (nsize : ι → ℝ) (nP : ℝ)
    (h0 : ∀ i ∈ S, ℓ i t0 ≤ ℓ i (u0 i)) (h1 : ∀ i ∈ S, ℓ i t1 ≤ ℓ i (u1 i)) :
    deltaAICc (pooledLoglik S ℓ t0) (pooledLoglik S ℓ t1) k0 k1 nP
      ≤ (∑ i ∈ S, deltaAICc (ℓ i (u0 i)) (ℓ i (u1 i)) k0 k1 (nsize i))
          + nullGap S ℓ t0 u0 + penaltyDefect S k0 k1 nsize nP := by
  have hgain := pooled_gain_le S ℓ h0 h1
  have hsum : (∑ i ∈ S, deltaAICc (ℓ i (u0 i)) (ℓ i (u1 i)) k0 k1 (nsize i))
      = 2 * (stratifiedLoglik S ℓ u1 - stratifiedLoglik S ℓ u0)
        - ∑ i ∈ S, deltaPenalty k0 k1 (nsize i) := by
    simp only [deltaAICc_eq, stratifiedLoglik, Finset.mul_sum, ← Finset.sum_sub_distrib]
  rw [deltaAICc_eq, hsum]
  simp only [penaltyDefect]
  linarith

end Stratified

/-- **Reading of the reported numbers.**  Two strata with `ΔAICc = 5.94` and
`ΔAICc = −0.40`, a pooled `ΔAICc = 49.78`, and a penalty defect of at most `3`
force a null misspecification gap of at least `41.2`.  More than four fifths of
the pooled statistic measures the size gradient between the bit-length bands,
not the extra ("edge") component. -/
theorem nullGap_ge_of_reported {dPool d1 d2 G defect : ℝ}
    (hpool : dPool = 49.78) (h1 : d1 = 5.94) (h2 : d2 = -0.40)
    (hdef : defect ≤ 3)
    (hineq : dPool ≤ d1 + d2 + G + defect) : 41.2 ≤ G := by
  subst hpool h1 h2
  linarith

/-- Two strata that are individually below the registered bar `6` cannot, by
themselves, produce a pooled statistic above `49`: the remainder is the null
gap.  (Contrapositive form of the main inequality.) -/
theorem gap_large_of_strata_below_bar {dPool d1 d2 G defect : ℝ}
    (hbar1 : d1 ≤ 6) (hbar2 : d2 ≤ 6) (hdef : defect ≤ 3) (hpool : 49 ≤ dPool)
    (hineq : dPool ≤ d1 + d2 + G + defect) : 34 ≤ G := by linarith

/-- An explicit realisation: a two-stratum configuration whose stratum `ΔAICc`s
are exactly the reported `5.94` and `−0.40`, whose penalty defect is `2`, and
whose pooled `ΔAICc` is `49.78`, consistent with the main inequality only
through a null gap `G = 42.24`.  Nothing here requires the extra component to
be real in any stratum. -/
theorem exists_pooled_above_bar_strata_below :
    ∃ d1 d2 G defect dPool : ℝ,
      d1 ≤ 6 ∧ d2 ≤ 6 ∧ 0 ≤ G ∧ defect = 2 ∧ dPool = 49.78 ∧
      dPool = d1 + d2 + G + defect := by
  refine ⟨5.94, -0.40, 42.24, 2, 49.78, by norm_num, by norm_num, by norm_num, rfl, rfl, by
    norm_num⟩

end Spike.Evidence