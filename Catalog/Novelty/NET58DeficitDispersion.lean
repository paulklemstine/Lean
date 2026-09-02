import Novelty.NET58BudgetCrossing

/-!
# NET-58 capstone: the gap you cannot close is the variance you cannot explain

`Novelty.NET58RelationalImportance` produced two quantities that at first sight belong to
different worlds:

* `relationalDeficit` — a *selection* quantity: how much retained attention mass the best
  possible static (content-only) eviction policy still loses to the per-context oracle;
* the pooled dispersion `∑ᵢ ∑_w (a w i - ā i)²` — a *regression* quantity: the part of the
  importance variance that no function of key content can ever explain
  (`pooled_condMean_optimal`, `Rsq_le_intrinsic_ceiling`).

This file proves that the first is controlled by the second:

`deficit ≤ √(B · dispersion / |W|)`   (`deficit_le_sqrt_dispersion`)

so a single measurable number bounds both the achievable `R²` of any content probe *and* the
retained-mass gap of every content-based eviction policy.  The two ceilings of the round are one
Cauchy–Schwarz step apart.

* `pooled_dispersion_eq` — the two ways of writing the dispersion (per context, per key) agree,
  identifying the bound's right-hand side with the `SS_within` of the ANOVA ceiling.
* `deficit_le_sqrt_dispersion` — the main bound.
* `swap_dispersion`, `swap_deficit_ratio` — **sharpness**: on the two-context swap witness the
  bound evaluates to `(u-v)/√2` while the true deficit is `(u-v)/2`, so the general inequality
  overestimates by exactly the factor `√2`, independently of `u` and `v`; the `√`-shape of the
  bound is therefore correct and only its constant is loose.
* `deficit_eq_zero_of_dispersion_zero` — the boundary case: if the contexts agree, the deficit
  vanishes, so the bound is qualitatively tight at zero as well.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the `10`-point oracle gap and the `1 - R² = 0.671` unexplained
variance are not independent measurements but two readings of one population quantity; a
Cauchy–Schwarz step should convert one into the other at a price of `√B`.

Experiment (Experimenter): on the swap witness (`ComputationalEvidence.md`, §4) with `B = 1`,
`|W| = 2`, dispersion `(u-v)²`, the bound evaluates to `0.70711·(u-v)` against a true deficit of
`0.5·(u-v)`; the ratio `√2/2` was checked for `(u,v) ∈ {(1,0), (0.9,0.4), (0.99,0.98)}` before
being proved in general.

Analysis (Analyst): the `√B` factor is the price of selecting `B` keys instead of one and the
`1/|W|` is the averaging over contexts.  Both are visible in the measured table: the probe's
oracle deficit is `0.1518` at `B = 32` and `0.1015` at `B = 64`, i.e. large at every aggressive
budget, exactly as a `√B`-priced dispersion term predicts once the per-key dispersion is fixed.

Critique (Critic): the inequality is one-sided by necessity — a converse is false, since
dispersion carried by keys that no budget-`B` policy would ever retain costs nothing.  Hence
sharpness is stated as an exact constant on a witness (`swap_deficit_ratio`) plus the boundary
converse (`deficit_eq_zero_of_dispersion_zero`), not as a two-sided bound.
-/

namespace Catalog.Novelty.NET58DeficitDispersion

open Finset Catalog.Novelty.ProbeRetentionLimits Catalog.Novelty.NET58RelationalImportance
  Catalog.Novelty.NET58BudgetCrossing

section Main

variable {ι : Type*} [Fintype ι] {W : Type*} [Fintype W]

/-- The dispersion of the contexts about their average, summed per context or per key: the same
number, and the `SS_within` of the ANOVA ceiling. -/
theorem pooled_dispersion_eq (a : W → ι → ℝ) :
    ∑ w, sse (a w) (avgImportance a) = ∑ i, ∑ w, (a w i - avgImportance a i) ^ 2 := by
  simp only [sse]
  exact Finset.sum_comm

/-- **Capstone bound.**  The retained-mass deficit that no content-only eviction policy can
avoid is at most `√(B · dispersion / |W|)`, the dispersion being exactly the variance that no
content-measurable score can explain. -/
theorem deficit_le_sqrt_dispersion [Nonempty W] (a : W → ι → ℝ) {B : ℕ} {T : Finset ι}
    (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w)) :
    relationalDeficit a O T
      ≤ Real.sqrt (B * ((∑ w, sse (a w) (avgImportance a)) / Fintype.card W)) := by
  have hW : (0 : ℝ) < Fintype.card W := by
    exact_mod_cast Fintype.card_pos_iff.mpr ‹Nonempty W›
  -- per context: the oracle's excess over the mean-profile selection is a Cauchy–Schwarz term
  have hper : ∀ w : W, retained (a w) (O w) - retained (avgImportance a) T
      ≤ Real.sqrt ((B : ℝ) * sse (a w) (avgImportance a)) := by
    intro w
    have hmean : retained (avgImportance a) (O w) ≤ retained (avgImportance a) T :=
      retained_le_of_isTopSet_true hT (hO w).card
    have hcs : |∑ i ∈ O w, (a w i - avgImportance a i)|
        ≤ Real.sqrt ((O w).card * sse (a w) (avgImportance a)) :=
      abs_sum_error_le (a w) (avgImportance a) (O w)
    rw [(hO w).card] at hcs
    have hsplit : ∑ i ∈ O w, (a w i - avgImportance a i)
        = retained (a w) (O w) - retained (avgImportance a) (O w) := by
      simp [retained, Finset.sum_sub_distrib]
    have h1 := (abs_le.mp hcs).2
    rw [hsplit] at h1
    linarith
  have hsum : ∑ w, (retained (a w) (O w) - retained (avgImportance a) T)
      ≤ ∑ w : W, Real.sqrt ((B : ℝ) * sse (a w) (avgImportance a)) :=
    Finset.sum_le_sum fun w _ => hper w
  have hnn : ∀ w : W, 0 ≤ (B : ℝ) * sse (a w) (avgImportance a) := fun w => by
    have := sse_nonneg (a w) (avgImportance a); positivity
  have hcs2 : ∑ w : W, Real.sqrt ((B : ℝ) * sse (a w) (avgImportance a))
      ≤ Real.sqrt ((Finset.univ : Finset W).card *
          ∑ w : W, (B : ℝ) * sse (a w) (avgImportance a)) :=
    sum_sqrt_le_sqrt_card_mul_sum _ _ hnn
  rw [Finset.card_univ, ← Finset.mul_sum] at hcs2
  -- the deficit is the average of the per-context losses
  have hdef : relationalDeficit a O T
      = (∑ w, (retained (a w) (O w) - retained (avgImportance a) T)) / Fintype.card W := by
    have hexp : ∑ w, (retained (a w) (O w) - retained (avgImportance a) T)
        = (∑ w, retained (a w) (O w)) - (Fintype.card W : ℝ) * retained (avgImportance a) T := by
      rw [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
    rw [hexp, relationalDeficit, avgRetained]
    field_simp
  set X : ℝ := (B : ℝ) * ∑ w, sse (a w) (avgImportance a) with hX
  have hXnn : 0 ≤ X := by
    have hs : 0 ≤ ∑ w, sse (a w) (avgImportance a) :=
      Finset.sum_nonneg fun w _ => sse_nonneg _ _
    rw [hX]; positivity
  have hrw : (B : ℝ) * ((∑ w, sse (a w) (avgImportance a)) / Fintype.card W)
      = X / Fintype.card W := by rw [hX]; ring
  have hsq : Real.sqrt (X / Fintype.card W)
      = Real.sqrt X / Real.sqrt (Fintype.card W) := Real.sqrt_div hXnn _
  have hstep : Real.sqrt (Fintype.card W * X) / Fintype.card W
      = Real.sqrt X / Real.sqrt (Fintype.card W) := by
    have hs : 0 < Real.sqrt (Fintype.card W) := Real.sqrt_pos.mpr hW
    rw [Real.sqrt_mul (le_of_lt hW), div_eq_div_iff (ne_of_gt hW) (ne_of_gt hs)]
    nlinarith [Real.sq_sqrt (le_of_lt hW), Real.sqrt_nonneg X]
  rw [hrw, hsq, hdef, ← hstep]
  exact (div_le_div_iff_of_pos_right hW).mpr (hsum.trans hcs2)

end Main

/-! ### Sharpness on the swap witness -/

section Sharp

variable (u v : ℝ)

/-- The dispersion of the two-context swap witness is `(u-v)²`. -/
theorem swap_dispersion :
    ∑ w, sse (swapImp u v w) (avgImportance (swapImp u v)) = (u - v) ^ 2 := by
  simp only [sse, Fin.sum_univ_two, swapImp_avg]
  simp only [swapImp, Matrix.cons_val_zero, Matrix.cons_val_one]
  ring

/-- **Sharpness of the capstone bound.**  On the swap witness the true deficit is `(u-v)/2` and
the bound is `(u-v)/√2`: the inequality is off by exactly the factor `√2`, for every `u > v`.
The `√dispersion` shape is therefore right; only the constant is loose. -/
theorem swap_deficit_ratio (huv : v < u) :
    relationalDeficit (swapImp u v) swapOracle {0} = (u - v) / 2 ∧
      Real.sqrt ((1 : ℕ) * ((∑ w, sse (swapImp u v w) (avgImportance (swapImp u v))) /
        Fintype.card (Fin 2))) = (u - v) / Real.sqrt 2 := by
  constructor
  · have hstat : retained (avgImportance (swapImp u v)) ({0} : Finset (Fin 2)) = (u + v) / 2 := by
      simp [retained]
    rw [relationalDeficit, swap_oracle_retained, hstat]
    ring
  · rw [swap_dispersion]
    have h2 : ((1 : ℕ) : ℝ) * ((u - v) ^ 2 / (Fintype.card (Fin 2) : ℝ))
        = (u - v) ^ 2 / 2 := by
      simp
    rw [h2, Real.sqrt_div (sq_nonneg _), Real.sqrt_sq (le_of_lt (by linarith : (0 : ℝ) < u - v))]

/-- The boundary converse: if all contexts agree, the deficit vanishes. -/
theorem deficit_eq_zero_of_dispersion_zero {ι : Type*} [Fintype ι] {W : Type*} [Fintype W]
    [Nonempty W] (a : W → ι → ℝ) {B : ℕ} {T : Finset ι}
    (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w))
    (hzero : ∀ w, sse (a w) (avgImportance a) = 0) :
    relationalDeficit a O T = 0 := by
  have hub := deficit_le_sqrt_dispersion a hT hO
  have hlb := relationalDeficit_nonneg a hT hO
  simp only [hzero, Finset.sum_const_zero, zero_div, mul_zero, Real.sqrt_zero] at hub
  linarith

end Sharp

end Catalog.Novelty.NET58DeficitDispersion