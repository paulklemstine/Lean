import Mathlib
import Algebra.ZeroFitDialU120Kantorovich

/-!
# Rigidity of the sharp seed-imbalance law: who the extremal seed profiles are

## Research context (FACT round-72 #4, exp 554, fifth cycle)

Cycle 2 (`Algebra.ZeroFitDialU120Kantorovich`) proved the sharp seed-imbalance law
`4αβ (∑w)(∑wλ²) ≤ (α+β)² (∑wλ)²` and exhibited *one* family attaining it.  The thread
then left open (direction D3 of `FUTURE_DIRECTIONS.md`) the question that actually decides
how the recorded fade may be read:

> **D3 (extremiser rigidity).**  The worst-case attenuation constant `2√(αβ)/(α+β)` is
> attained by an explicit two-block family.  Is that family *the only* extremiser?  If so,
> a measured attenuation strictly below the worst case is not merely a bound but a
> *structural* statement about the seed profile.

This cycle answers D3 completely, and turns the answer into a falsification of the
"the step was imbalance, not signal" reading of exp 554.

## Main results

* `kantorovich_equality_rigidity` — **the rigidity theorem**.  If a normalised weight
  profile with ratios in `[α, β]`, `0 < α`, attains equality in the Kantorovich bound then
  * every seed is *at an endpoint of the window* (`wₖ · (λₖ-α)(β-λₖ) = 0` for all `k`), and
  * the mean is forced to the **harmonic** mean of the window, `(α+β)M = 2αβ`.

  The proof is the exact-remainder identity
  `((α+β)M - 2αβ)² + 4αβ·∑wₖ(λₖ-α)(β-λₖ) = 0`,
  in which the two summands are separately nonnegative, so both vanish.
* `kantorovich_equality_mass` — for a nondegenerate window `α < β` the two endpoint masses
  are then *uniquely determined*: the mass at `α` is exactly `β/(α+β)` (and hence the mass
  at `β` is `α/(α+β)`).  Together with `kantorovich_equality_rigidity` this says the
  extremiser is unique as a distribution.
* `kantorovich_extremiser_witness` — the converse: that distribution really does attain
  equality, for every window.  So the characterisation is an exact one.
* `kantorovich_strict_of_interior` — the operational face of rigidity: **one** seed with
  positive weight whose ratio lies strictly inside the window already forces *strict*
  inequality.  A seed profile that is not perfectly polarised at the window endpoints can
  never suffer the worst-case attenuation.
* `u120_step_not_imbalance_artefact` — the data-tied consequence.  Inside the recorded
  `±10%` seed window `λₖ ∈ [1, 1.21]`, even the *worst-case* attenuation is a factor
  `2·1.1/2.21 > 0.9954`.  Hence if every seed had held at the previous rung `0.4847`, the
  pooled reading could not have fallen below `0.4824`, let alone to `0.43636`.  The
  `−0.0483` step is therefore not a pooling artefact of widening seed imbalance.
* `u120_extremal_window_needed` — quantifying how wide the window would have to be: to
  explain a fall from `0.4847` to `0.43636` by imbalance alone one needs
  `2√(αβ)/(α+β) ≤ 0.9003`, i.e. a ratio window with `β/α ≥ 1.9`, far outside the recorded
  spread.

## Lab notes (exp 554)

Random search over normalised profiles on the window `[1, 4]` minimised the Kantorovich
slack `g = (α+β)²M² - 4αβQ` at `g ≈ 0.00244` on the support `{1, 4}` with weights
`≈ (0.797, 0.203)`, versus exactly `g = 0` at weights `(4/5, 1/5) = (β/(α+β), α/(α+β))`.
`kantorovich_equality_mass` explains the numerics: the minimiser is unique and the search
was converging to it.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU120Rigidity

open Catalog.Algebra.ZeroFitDialU72Parity
open Catalog.Algebra.ZeroFitDialU120Floor
open Catalog.Algebra.ZeroFitDialU120Kantorovich

variable {m n : ℕ}

/-! ### 1. The exact remainder identity -/

/-- The Kantorovich slack has an exact two-term decomposition: the square of the
distance of `(α+β)M` from the harmonic-mean value `2αβ`, plus `4αβ` times the total
endpoint defect `∑ wₖ(λₖ-α)(β-λₖ)`. -/
theorem kantorovich_slack_identity {r : ℕ} {w lam : Fin r → ℝ} {alpha beta : ℝ}
    (hsum : ∑ k, w k = 1) :
    (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2
        - 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
      = ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) ^ 2
        + 4 * (alpha * beta) * (∑ k, w k * ((lam k - alpha) * (beta - lam k))) := by
  have hexp : ∑ k, w k * ((lam k - alpha) * (beta - lam k))
      = (alpha + beta) * (∑ k, w k * lam k) - alpha * beta * (∑ k, w k)
        - ∑ k, w k * lam k ^ 2 := by
    have hpt : ∀ k : Fin r, w k * ((lam k - alpha) * (beta - lam k))
        = (alpha + beta) * (w k * lam k) - alpha * beta * w k - w k * lam k ^ 2 := by
      intro k; ring
    simp_rw [hpt]
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, ← Finset.mul_sum]
  rw [hexp, hsum]
  ring

/-! ### 2. Rigidity -/

/-- **Rigidity of the sharp seed-imbalance law.**  Equality in the Kantorovich bound forces
every seed onto an endpoint of the ratio window *and* pins the mean ratio at the harmonic
mean `2αβ/(α+β)` of the window. -/
theorem kantorovich_equality_rigidity {r : ℕ} {w lam : Fin r → ℝ} {alpha beta : ℝ}
    (halpha : 0 < alpha) (hab : alpha ≤ beta) (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (heq : 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
      = (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2) :
    (∀ k, w k * ((lam k - alpha) * (beta - lam k)) = 0)
      ∧ (alpha + beta) * (∑ k, w k * lam k) = 2 * (alpha * beta) := by
  have hbeta : 0 < beta := lt_of_lt_of_le halpha hab
  have hab' : 0 < alpha * beta := mul_pos halpha hbeta
  have hterm : ∀ k ∈ (Finset.univ : Finset (Fin r)),
      0 ≤ w k * ((lam k - alpha) * (beta - lam k)) := by
    intro k _
    exact mul_nonneg (hw k)
      (mul_nonneg (sub_nonneg.mpr (hlo k)) (sub_nonneg.mpr (hhi k)))
  have hD : 0 ≤ ∑ k, w k * ((lam k - alpha) * (beta - lam k)) :=
    Finset.sum_nonneg hterm
  have hid := kantorovich_slack_identity (w := w) (lam := lam)
    (alpha := alpha) (beta := beta) hsum
  have hzero : ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) ^ 2
      + 4 * (alpha * beta) * (∑ k, w k * ((lam k - alpha) * (beta - lam k))) = 0 := by
    rw [← hid, heq]; ring
  have hsq : 0 ≤ ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) ^ 2 :=
    sq_nonneg _
  have hDzero : ∑ k, w k * ((lam k - alpha) * (beta - lam k)) = 0 := by
    nlinarith [hab', hD, hsq]
  refine ⟨?_, ?_⟩
  · intro k
    exact (Finset.sum_eq_zero_iff_of_nonneg hterm).mp hDzero k (Finset.mem_univ k)
  · have : ((alpha + beta) * (∑ k, w k * lam k) - 2 * (alpha * beta)) ^ 2 = 0 := by
      nlinarith [hab', hDzero]
    linarith [sub_eq_zero.mp (sq_eq_zero_iff.mp this)]

/-- **Uniqueness of the extremal seed profile.**  On a nondegenerate window `α < β`,
equality forces the mass sitting at the lower endpoint to be exactly `β/(α+β)` (so the
mass at the upper endpoint is `α/(α+β)`).  Combined with `kantorovich_equality_rigidity`
this determines the extremiser as a distribution. -/
theorem kantorovich_equality_mass {r : ℕ} {w lam : Fin r → ℝ} {alpha beta : ℝ}
    (halpha : 0 < alpha) (hab : alpha < beta) (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    (heq : 4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
      = (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2) :
    ∑ k ∈ Finset.univ.filter (fun k => lam k = alpha), w k = beta / (alpha + beta) := by
  obtain ⟨hsupp, hmean⟩ :=
    kantorovich_equality_rigidity halpha hab.le hw hsum hlo hhi heq
  have hbeta : 0 < beta := lt_trans halpha hab
  have hpos : 0 < alpha + beta := by linarith
  set A := ∑ k ∈ Finset.univ.filter (fun k => lam k = alpha), w k with hA
  have hcompl : ∑ k ∈ Finset.univ.filter (fun k => ¬ lam k = alpha), w k = 1 - A := by
    have := Finset.sum_filter_add_sum_filter_not
      (Finset.univ : Finset (Fin r)) (fun k => lam k = alpha) w
    rw [hsum] at this
    linarith [this]
  have hlow : ∑ k ∈ Finset.univ.filter (fun k => lam k = alpha), w k * lam k = alpha * A := by
    rw [hA, Finset.mul_sum]
    refine Finset.sum_congr rfl fun k hk => ?_
    have : lam k = alpha := (Finset.mem_filter.mp hk).2
    rw [this]; ring
  have hhigh : ∑ k ∈ Finset.univ.filter (fun k => ¬ lam k = alpha), w k * lam k
      = beta * (1 - A) := by
    rw [← hcompl, Finset.mul_sum]
    refine Finset.sum_congr rfl fun k hk => ?_
    have hne : lam k ≠ alpha := (Finset.mem_filter.mp hk).2
    rcases eq_or_lt_of_le (hw k) with h0 | h0
    · rw [← h0]; ring
    · have := hsupp k
      have hfac : (lam k - alpha) * (beta - lam k) = 0 := by
        rcases mul_eq_zero.mp this with h | h
        · exact absurd h (ne_of_gt h0)
        · exact h
      rcases mul_eq_zero.mp hfac with h | h
      · exact absurd (sub_eq_zero.mp h) hne
      · rw [sub_eq_zero.mp h]; ring
  have hsplit : ∑ k, w k * lam k = alpha * A + beta * (1 - A) := by
    have := Finset.sum_filter_add_sum_filter_not
      (Finset.univ : Finset (Fin r)) (fun k => lam k = alpha) (fun k => w k * lam k)
    rw [hlow, hhigh] at this
    linarith [this]
  rw [hsplit] at hmean
  field_simp
  nlinarith [hmean, sub_pos.mpr hab]

/-! ### 3. The converse: the endpoint profile is an extremiser -/

/-- The two-point profile with mass `β/(α+β)` at `α` and `α/(α+β)` at `β` attains equality
in the Kantorovich bound, for every window `0 < α ≤ β`.  With `kantorovich_equality_mass`
this makes the characterisation exact. -/
theorem kantorovich_extremiser_witness {alpha beta : ℝ} (halpha : 0 < alpha)
    (hab : alpha ≤ beta) :
    ∃ w lam : Fin 2 → ℝ,
      (∀ k, 0 ≤ w k) ∧ (∑ k, w k) = 1 ∧ (∀ k, alpha ≤ lam k) ∧ (∀ k, lam k ≤ beta) ∧
        4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
          = (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2 := by
  have hbeta : 0 < beta := lt_of_lt_of_le halpha hab
  have hpos : 0 < alpha + beta := by linarith
  refine ⟨![beta / (alpha + beta), alpha / (alpha + beta)], ![alpha, beta], ?_, ?_, ?_, ?_, ?_⟩
  · intro k
    fin_cases k <;> simp <;> positivity
  · simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
    field_simp
    ring
  · intro k
    fin_cases k
    · simp
    · simpa using hab
  · intro k
    fin_cases k
    · simpa using hab
    · simp
  · simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
    field_simp
    ring

/-! ### 4. The operational face: interior seeds break extremality -/

/-- **Strictness from a single interior seed.**  If even one seed carries positive weight
and a ratio strictly inside the window, the Kantorovich inequality is strict: such a
profile cannot suffer the worst-case pooling attenuation. -/
theorem kantorovich_strict_of_interior {r : ℕ} {w lam : Fin r → ℝ} {alpha beta : ℝ}
    (halpha : 0 < alpha) (hab : alpha ≤ beta) (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    (hlo : ∀ k, alpha ≤ lam k) (hhi : ∀ k, lam k ≤ beta)
    {j : Fin r} (hwj : 0 < w j) (hj1 : alpha < lam j) (hj2 : lam j < beta) :
    4 * (alpha * beta) * ((∑ k, w k) * (∑ k, w k * lam k ^ 2))
      < (alpha + beta) ^ 2 * (∑ k, w k * lam k) ^ 2 := by
  rcases lt_or_eq_of_le (weighted_kantorovich halpha hab hw hlo hhi) with h | h
  · exact h
  · exfalso
    obtain ⟨hsupp, -⟩ := kantorovich_equality_rigidity halpha hab hw hsum hlo hhi h
    have := hsupp j
    have hposprod : 0 < w j * ((lam j - alpha) * (beta - lam j)) :=
      mul_pos hwj (mul_pos (sub_pos.mpr hj1) (sub_pos.mpr hj2))
    exact absurd this (ne_of_gt hposprod)

/-! ### 5. Consequences for exp 554 -/

/-- **The `−0.0483` step is not a pooling artefact.**  Inside the recorded `±10%` seed
window `λₖ ∈ [1, 1.21]`, the worst-case attenuation factor is `2·1.1/2.21 > 0.9954`.  So if
every seed had merely held at the previous rung `0.4847`, the pooled reading would have
stayed strictly above `0.43636`; the recorded fall therefore records a genuine seedwise
decline. -/
theorem u120_step_not_imbalance_artefact {u v : Fin m → (Fin n → ℝ)} {lam : Fin m → ℝ}
    (hu0 : ∀ k, dot (u k) (u k) ≠ 0) (hv0 : ∀ k, dot (v k) (v k) ≠ 0)
    (hu : 0 < blockNormSq u)
    (hbal : ∀ k, nrm (v k) = lam k * nrm (u k))
    (hlo : ∀ k, (1 : ℝ) ≤ lam k) (hhi : ∀ k, lam k ≤ 121 / 100)
    (hcorr : ∀ k, (0.4847 : ℝ) ≤ corr (u k) (v k)) :
    0.43636 < pooledCorr u v := by
  have hsqrt : Real.sqrt ((1 : ℝ) * (121 / 100)) = 11 / 10 := by
    rw [show (1 : ℝ) * (121 / 100) = (11 / 10 : ℝ) ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num)]
  have h := pooled_kantorovich_bound (alpha := 1) (beta := 121 / 100) (rho := 0.4847)
    (by norm_num) (by norm_num) (by norm_num) hu0 hv0 hu hbal hlo hhi hcorr
  rw [hsqrt] at h
  nlinarith [h]

/-- **How extremal the seed window would have to be.**  For imbalance alone to carry a
pooled reading from `0.4847` down to `0.43636`, the worst-case attenuation factor
`2√(αβ)/(α+β)` must drop to `0.9003` or below, which needs a ratio window of ratio
`β/α ≥ 1.9` — far outside the recorded seed spread. -/
theorem u120_extremal_window_needed {alpha beta : ℝ} (halpha : 0 < alpha) (hab : alpha ≤ beta)
    (hfactor : 2 * Real.sqrt (alpha * beta) / (alpha + beta) ≤ 0.9003) :
    1.9 * alpha ≤ beta := by
  have hbeta : 0 < beta := lt_of_lt_of_le halpha hab
  have hpos : 0 < alpha + beta := by linarith
  have hsq : Real.sqrt (alpha * beta) ^ 2 = alpha * beta :=
    Real.sq_sqrt (mul_pos halpha hbeta).le
  have hsnn : 0 ≤ Real.sqrt (alpha * beta) := Real.sqrt_nonneg _
  have hmul : 2 * Real.sqrt (alpha * beta) ≤ 0.9003 * (alpha + beta) := by
    rw [div_le_iff₀ hpos] at hfactor
    linarith [hfactor]
  by_contra hcon
  push_neg at hcon
  -- with `β < 1.9α` the factor is forced above `0.9003`
  nlinarith [hsq, hsnn, sq_nonneg (Real.sqrt (alpha * beta) - alpha),
    sq_nonneg (beta - alpha), mul_pos halpha hbeta]

end Catalog.Algebra.ZeroFitDialU120Rigidity