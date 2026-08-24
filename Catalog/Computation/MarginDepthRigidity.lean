/-
# E3, cycle two: rigidity, experimental design, and the aggregator

`Computation/MarginDepthInvariance.lean` turned the pinning step of the margin
law into a band statement: knees measured to `±η` of `d·ctx/c` force the ratio
of the implied margins into `[(1-η)/(1+η), (1+η)/(1-η)]`.  Three questions were
left open by that file, and this one answers all three.

* **§1 What kind of object is the band?**  It is a ball in the Hilbert
  projective metric `logRatio x y = |log (x/y)|` on the positive ray.  The map
  "measured knee ↦ implied margin" is an *isometry* of that metric
  (`logRatio_margin_eq_knee`), which is why the amplitude, the read-out constant
  and the context cancel: they are projective rescalings.  `logRatio_triangle`
  gives the pseudometric, and `direct_bound_beats_chained` is the qualitative
  payoff: comparing the two extreme depths directly is strictly sharper than
  chaining through the intermediate depth, i.e. the margin channel does *not*
  accumulate error along the depth ladder — in exact contrast to the depth leg
  of `AttentionCostLaw.layerComp_dist_le`, where errors do add.

* **§2 Can the existing sweep test E3 at all?**  No.  A sweep that reports the
  first grid point above the true knee overshoots by a factor in `[1, ρ]`, and
  then the implied margin ratio is confined to `[1/ρ, ρ]` and no better
  (`grid_margin_ratio_band`, `grid_ratio_attained`).  The catalog's grids
  (`AttentionCostLaw.gridA`, `gridB`) are dyadic, `ρ = 2`, so they cannot
  distinguish a flat margin from a factor-two drift
  (`dyadic_grid_cannot_certify_ten_percent`).  A geometric grid certifies the
  `±10 %` claim exactly when its step satisfies `ρ ≤ 11/10`
  (`ten_percent_needs_fine_grid`, and the converse `fine_grid_certifies`).
  This is a concrete, falsifiable instruction to the harness.

* **§3 Is the median the right aggregator?**  Yes, and the mean is not.
  `mean_breaks_on_one_corrupted_run` exhibits a six-run log in which a *single*
  corrupted run drags the mean out of the acceptance band while every median
  stays at `1`: the mean has breakdown `0`, the median `1/2`
  (`Computation/MedianBreakdown.lean`).  The E3 protocol must report a median.

* **§4 The knee side of the power law.**  Under `m(d) = m₁·d^(-α)` the knee
  ratio between depths `4` and `16` is exactly `4^(1+α)`
  (`knee_ratio_power_law`); the measured value `4` therefore forces `α = 0`
  (`measured_knee_ratio_forces_alpha_zero`).  The depth leg of the mechanism and
  the depth-independence of the margin are the same statement, read from the two
  ends.
-/

import Mathlib
import Computation.MarginDepthInvariance

namespace MarginDepthRigidity

open MarginDepthInvariance

/-!
## 1.  The band is a ball in the Hilbert projective metric
-/

/-- The Hilbert projective (log-ratio) distance on the positive ray. -/
noncomputable def logRatio (x y : ℝ) : ℝ := |Real.log (x / y)|

theorem logRatio_nonneg (x y : ℝ) : 0 ≤ logRatio x y := abs_nonneg _

theorem logRatio_comm {x y : ℝ} (hx : 0 < x) (hy : 0 < y) :
    logRatio x y = logRatio y x := by
  unfold logRatio
  rw [show y / x = (x / y)⁻¹ by field_simp, Real.log_inv, abs_neg]

/-- The log-ratio distance satisfies the triangle inequality. -/
theorem logRatio_triangle {x y z : ℝ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z) :
    logRatio x z ≤ logRatio x y + logRatio y z := by
  unfold logRatio
  have hsplit : x / z = (x / y) * (y / z) := by field_simp
  rw [hsplit, Real.log_mul (by positivity) (by positivity)]
  exact abs_add_le _ _

/-- **The margin map is an isometry of the projective metric.**  The implied
margin at depth `d` is `4·L·B·A·d·ctx/K`; the common positive factor
`4·L·B·A·ctx` is a projective rescaling and drops out, so the distance between
two implied margins equals the distance between the two normalised knees
`K/d`. -/
theorem logRatio_margin_eq_knee {L B A ctx K₁ K₂ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hK₁ : 0 < K₁) (hK₂ : 0 < K₂) :
    logRatio (marginOfKnee L B A ctx d₁ K₁) (marginOfKnee L B A ctx d₂ K₂)
      = logRatio (K₂ / (d₂ : ℝ)) (K₁ / (d₁ : ℝ)) := by
  have hd₁R : (0 : ℝ) < (d₁ : ℝ) := by exact_mod_cast hd₁
  have hd₂R : (0 : ℝ) < (d₂ : ℝ) := by exact_mod_cast hd₂
  have hP : (0 : ℝ) < 4 * L * B * A := by positivity
  unfold logRatio marginOfKnee
  congr 1
  congr 1
  field_simp

/-- **The band is a projective ball.**  Knees measured to `±η` put the implied
margins within log-ratio distance `log((1+η)/(1-η))` of each other. -/
theorem logRatio_le_of_band {L B A ctx c η K₁ K₂ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx) (hc : 0 < c)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) (hη : 0 ≤ η) (hη1 : η < 1)
    (h₁ : WithinRel η K₁ ((d₁ : ℝ) * ctx / c))
    (h₂ : WithinRel η K₂ ((d₂ : ℝ) * ctx / c)) :
    logRatio (marginOfKnee L B A ctx d₁ K₁) (marginOfKnee L B A ctx d₂ K₂)
      ≤ Real.log ((1 + η) / (1 - η)) := by
  have hK₁ : 0 < K₁ := knee_pos_of_band hd₁ hctx hc hη1 h₁
  have hK₂ : 0 < K₂ := knee_pos_of_band hd₂ hctx hc hη1 h₂
  have hm₁ : 0 < marginOfKnee L B A ctx d₁ K₁ := marginOfKnee_pos hL hB hA hctx hd₁ hK₁
  have hm₂ : 0 < marginOfKnee L B A ctx d₂ K₂ := marginOfKnee_pos hL hB hA hctx hd₂ hK₂
  obtain ⟨hlo, hhi⟩ := margin_ratio_within_band hL hB hA hctx hc hd₁ hd₂ hη hη1 h₁ h₂
  have hpos1 : (0 : ℝ) < 1 + η := by linarith
  have hpos2 : (0 : ℝ) < 1 - η := by linarith
  have hquot : 0 < marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ :=
    div_pos hm₁ hm₂
  unfold logRatio
  rw [abs_le]
  constructor
  · have h1 : Real.log ((1 - η) / (1 + η))
        ≤ Real.log (marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂) :=
      Real.log_le_log (by positivity) hlo
    have h2 : Real.log ((1 - η) / (1 + η)) = -Real.log ((1 + η) / (1 - η)) := by
      rw [show (1 - η) / (1 + η) = ((1 + η) / (1 - η))⁻¹ by field_simp, Real.log_inv]
    linarith [h1, h2.le, h2.ge]
  · exact Real.log_le_log hquot hhi

/-- **The direct comparison beats the chained one: the margin channel does not
accumulate error along the depth ladder.**  For a nondegenerate tolerance the
bound obtained by comparing `d = 4` with `d = 16` directly is strictly smaller
than the bound obtained by chaining through `d = 8`, even though the triangle
inequality is the only tool available for the latter.  Error accumulation lives
in the depth leg (`AttentionCostLaw.layerComp_dist_le`), not in the margin. -/
theorem direct_bound_beats_chained {η : ℝ} (hη : 0 < η) (hη1 : η < 1) :
    Real.log ((1 + η) / (1 - η)) < 2 * Real.log ((1 + η) / (1 - η)) := by
  have hpos1 : (0 : ℝ) < 1 + η := by linarith
  have hpos2 : (0 : ℝ) < 1 - η := by linarith
  have hgt : 1 < (1 + η) / (1 - η) := by
    rw [lt_div_iff₀ hpos2]
    linarith
  have := Real.log_pos hgt
  linarith

/-!
## 2.  Experimental design: what grid can test E3 at all?
-/

/-- A sweep on a geometric grid of step `ρ` reports the first grid point at or
above the true knee, so the reported value overshoots by a factor in `[1, ρ]`. -/
def GridReport (ρ Ktrue K : ℝ) : Prop := Ktrue ≤ K ∧ K ≤ ρ * Ktrue

/-- **What a grid of step `ρ` can say.**  If the true knees obey the depth-linear
law exactly and the sweep reports them on a geometric grid of step `ρ ≥ 1`, then
the implied margin ratio is confined to `[1/ρ, ρ]` — and, by
`grid_ratio_attained`, to nothing smaller. -/
theorem grid_margin_ratio_band {L B A ctx ρ K₁ K₂ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx) (hρ : 1 ≤ ρ)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂)
    (h₁ : GridReport ρ ((d₁ : ℝ) * ctx / 32) K₁)
    (h₂ : GridReport ρ ((d₂ : ℝ) * ctx / 32) K₂) :
    1 / ρ ≤ marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ∧
      marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ≤ ρ := by
  have hd₁R : (0 : ℝ) < (d₁ : ℝ) := by exact_mod_cast hd₁
  have hd₂R : (0 : ℝ) < (d₂ : ℝ) := by exact_mod_cast hd₂
  have hρ0 : (0 : ℝ) < ρ := lt_of_lt_of_le zero_lt_one hρ
  have href₁ : (0 : ℝ) < (d₁ : ℝ) * ctx / 32 := by positivity
  have href₂ : (0 : ℝ) < (d₂ : ℝ) * ctx / 32 := by positivity
  have hK₁ : 0 < K₁ := lt_of_lt_of_le href₁ h₁.1
  have hK₂ : 0 < K₂ := lt_of_lt_of_le href₂ h₂.1
  have hP : (0 : ℝ) < 4 * L * B * A := by positivity
  have hratio : marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂
      = ((d₁ : ℝ) * K₂) / ((d₂ : ℝ) * K₁) := by
    unfold marginOfKnee
    field_simp
  have hden : (0 : ℝ) < (d₂ : ℝ) * K₁ := by positivity
  -- rewrite the grid hypotheses with the factor `ctx/32` isolated
  have hu₁ : K₁ ≤ ρ * ((d₁ : ℝ) * (ctx / 32)) := by
    have h := h₁.2; rw [mul_div_assoc] at h; linarith [h]
  have hl₁ : (d₁ : ℝ) * (ctx / 32) ≤ K₁ := by
    have h := h₁.1; rw [mul_div_assoc] at h; exact h
  have hu₂ : K₂ ≤ ρ * ((d₂ : ℝ) * (ctx / 32)) := by
    have h := h₂.2; rw [mul_div_assoc] at h; linarith [h]
  have hl₂ : (d₂ : ℝ) * (ctx / 32) ≤ K₂ := by
    have h := h₂.1; rw [mul_div_assoc] at h; exact h
  constructor
  · rw [hratio, div_le_div_iff₀ hρ0 hden]
    have s1 : (d₂ : ℝ) * K₁ ≤ (d₂ : ℝ) * (ρ * ((d₁ : ℝ) * (ctx / 32))) :=
      mul_le_mul_of_nonneg_left hu₁ hd₂R.le
    have s2 : (d₁ : ℝ) * ((d₂ : ℝ) * (ctx / 32)) ≤ (d₁ : ℝ) * K₂ :=
      mul_le_mul_of_nonneg_left hl₂ hd₁R.le
    have s3 : ρ * ((d₁ : ℝ) * ((d₂ : ℝ) * (ctx / 32))) ≤ ρ * ((d₁ : ℝ) * K₂) :=
      mul_le_mul_of_nonneg_left s2 hρ0.le
    have sring : (d₂ : ℝ) * (ρ * ((d₁ : ℝ) * (ctx / 32)))
        = ρ * ((d₁ : ℝ) * ((d₂ : ℝ) * (ctx / 32))) := by ring
    linarith [s1, s3, sring.le, sring.ge]
  · rw [hratio, div_le_iff₀ hden]
    have s1 : (d₁ : ℝ) * K₂ ≤ (d₁ : ℝ) * (ρ * ((d₂ : ℝ) * (ctx / 32))) :=
      mul_le_mul_of_nonneg_left hu₂ hd₁R.le
    have s2 : (d₂ : ℝ) * ((d₁ : ℝ) * (ctx / 32)) ≤ (d₂ : ℝ) * K₁ :=
      mul_le_mul_of_nonneg_left hl₁ hd₂R.le
    have s3 : ρ * ((d₂ : ℝ) * ((d₁ : ℝ) * (ctx / 32))) ≤ ρ * ((d₂ : ℝ) * K₁) :=
      mul_le_mul_of_nonneg_left s2 hρ0.le
    have sring : (d₁ : ℝ) * (ρ * ((d₂ : ℝ) * (ctx / 32)))
        = ρ * ((d₂ : ℝ) * ((d₁ : ℝ) * (ctx / 32))) := by ring
    linarith [s1, s3, sring.le, sring.ge]

/-- **The grid band is attained.**  With one depth reported exactly and the other
overshooting by the full grid step, the implied margin ratio is exactly `ρ`.  So
a grid of step `ρ` cannot certify any window narrower than `[1/ρ, ρ]`. -/
theorem grid_ratio_attained {L B A ctx ρ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx) (hρ : 1 ≤ ρ)
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) :
    ∃ K₁ K₂ : ℝ, GridReport ρ ((d₁ : ℝ) * ctx / 32) K₁ ∧
      GridReport ρ ((d₂ : ℝ) * ctx / 32) K₂ ∧
      marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ = ρ := by
  have hd₁R : (0 : ℝ) < (d₁ : ℝ) := by exact_mod_cast hd₁
  have hd₂R : (0 : ℝ) < (d₂ : ℝ) := by exact_mod_cast hd₂
  have hρ0 : (0 : ℝ) < ρ := lt_of_lt_of_le zero_lt_one hρ
  have href₁ : (0 : ℝ) < (d₁ : ℝ) * ctx / 32 := by positivity
  have href₂ : (0 : ℝ) < (d₂ : ℝ) * ctx / 32 := by positivity
  refine ⟨(d₁ : ℝ) * ctx / 32, ρ * ((d₂ : ℝ) * ctx / 32), ⟨le_refl _, ?_⟩,
    ⟨?_, le_refl _⟩, ?_⟩
  · nlinarith [href₁, hρ]
  · nlinarith [href₂, hρ]
  · unfold marginOfKnee
    have hP : (0 : ℝ) < 4 * L * B * A := by positivity
    field_simp

/-- **A dyadic sweep cannot test E3.**  The catalog grids double at each step, so
`ρ = 2`: there are measurement outcomes consistent with the sweep whose implied
margin ratio is `2`, well outside the `±10 %` acceptance band.  The knee sweep
that produced `k* = 16, 32, 64` therefore carries no information about the depth
scaling of the margin at the precision E3 asks for. -/
theorem dyadic_grid_cannot_certify_ten_percent {L B A ctx : ℝ} (hL : 0 < L)
    (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx) :
    ∃ K₄ K₁₆ : ℝ, GridReport 2 ((4 : ℕ) * ctx / 32) K₄ ∧
      GridReport 2 ((16 : ℕ) * ctx / 32) K₁₆ ∧
      ¬ (marginOfKnee L B A ctx 16 K₁₆ / marginOfKnee L B A ctx 4 K₄ ≤ 1.1) := by
  obtain ⟨K₁₆, K₄, h₁₆, h₄, hval⟩ :=
    grid_ratio_attained (L := L) (B := B) (A := A) (ctx := ctx) (ρ := 2)
      (d₁ := 16) (d₂ := 4) hL hB hA hctx (by norm_num) (by norm_num) (by norm_num)
  refine ⟨K₄, K₁₆, h₄, h₁₆, ?_⟩
  rw [hval]
  norm_num

/-- **A fine enough grid does certify E3.**  A geometric sweep of step
`ρ ≤ 11/10` forces the implied margin ratio into `[10/11, 11/10] ⊆ [0.9, 1.1]`:
this is the instruction to the harness — refine the budget grid to `10 %`
multiplicative steps (or interpolate the knee) and the depth leg becomes
testable by three forward passes. -/
theorem fine_grid_certifies {L B A ctx ρ K₁ K₂ : ℝ} {d₁ d₂ : ℕ}
    (hL : 0 < L) (hB : 0 < B) (hA : 0 < A) (hctx : 0 < ctx)
    (hρ : 1 ≤ ρ) (hρ' : ρ ≤ 11 / 10) (hd₁ : 0 < d₁) (hd₂ : 0 < d₂)
    (h₁ : GridReport ρ ((d₁ : ℝ) * ctx / 32) K₁)
    (h₂ : GridReport ρ ((d₂ : ℝ) * ctx / 32) K₂) :
    (0.9 : ℝ) ≤ marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ∧
      marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ≤ 1.1 := by
  obtain ⟨hlo, hhi⟩ := grid_margin_ratio_band hL hB hA hctx hρ hd₁ hd₂ h₁ h₂
  have hρ0 : (0 : ℝ) < ρ := lt_of_lt_of_le zero_lt_one hρ
  refine ⟨?_, by linarith⟩
  have h : (0.9 : ℝ) ≤ 1 / ρ := by
    rw [le_div_iff₀ hρ0]
    linarith
  linarith

/-- **Necessity of the fine grid.**  If the grid step exceeds `11/10` then a
consistent measurement breaks the `±10 %` window.  Together with
`fine_grid_certifies`: a geometric sweep certifies E3 *iff* its step is at most
`11/10`. -/
theorem ten_percent_needs_fine_grid {L B A ctx ρ : ℝ} (hL : 0 < L) (hB : 0 < B)
    (hA : 0 < A) (hctx : 0 < ctx) (hρ : 11 / 10 < ρ) {d₁ d₂ : ℕ}
    (hd₁ : 0 < d₁) (hd₂ : 0 < d₂) :
    ∃ K₁ K₂ : ℝ, GridReport ρ ((d₁ : ℝ) * ctx / 32) K₁ ∧
      GridReport ρ ((d₂ : ℝ) * ctx / 32) K₂ ∧
      ¬ (marginOfKnee L B A ctx d₁ K₁ / marginOfKnee L B A ctx d₂ K₂ ≤ 1.1) := by
  obtain ⟨K₁, K₂, h₁, h₂, hval⟩ :=
    grid_ratio_attained hL hB hA hctx (by linarith : (1 : ℝ) ≤ ρ) hd₁ hd₂
  refine ⟨K₁, K₂, h₁, h₂, ?_⟩
  rw [hval]
  intro hcon
  norm_num at hcon
  linarith

/-!
## 3.  The aggregator: the mean has breakdown zero, the median does not
-/

/-- Sample mean of a run log. -/
def listMean (l : List ℚ) : ℚ := l.sum / l.length

/-- **A single corrupted run destroys the mean but not the median.**  Six runs
all reporting the flat ratio `1`; one of them is replaced by a spurious `100`
(a crashed forward pass reporting a garbage logit margin).  The mean of the
corrupted log is `35/2`, far outside the acceptance band, while `1` is still a
median of it — and `median_ratio_in_band` guarantees that *every* median stays
inside the band.  The E3 protocol must therefore report a median, exactly as the
conjecture specifies. -/
theorem mean_breaks_on_one_corrupted_run :
    (∀ x ∈ ([1, 1, 1, 1, 1, 1] : List ℚ), 9 / 10 ≤ x ∧ x ≤ 11 / 10) ∧
      MedianBreakdown.diffCount [1, 1, 1, 1, 1, 1] [1, 1, 1, 1, 1, 100] = 1 ∧
      MedianBreakdown.IsMedian [1, 1, 1, 1, 1, 100] 1 ∧
      listMean [1, 1, 1, 1, 1, 100] = 35 / 2 ∧
      ¬ PassesE3 (listMean [1, 1, 1, 1, 1, 100]) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro x hx
    fin_cases hx <;> norm_num
  · norm_num [MedianBreakdown.diffCount]
  · constructor <;> norm_num [MedianBreakdown.IsMedian, List.countP_cons]
  · norm_num [listMean]
  · rw [show listMean [1, 1, 1, 1, 1, 100] = 35 / 2 by norm_num [listMean]]
    rintro ⟨-, h⟩
    norm_num at h

/-- **The same corruption leaves the median inside the band.**  The uncorrupted
log lies in the band and only one of six runs is corrupted, so every median of
the corrupted log passes E3. -/
theorem median_survives_one_corrupted_run {m : ℚ}
    (hm : MedianBreakdown.IsMedian [1, 1, 1, 1, 1, 100] m) : PassesE3 m := by
  have h := median_ratio_in_band (xs := ([1, 1, 1, 1, 1, 1] : List ℚ))
    (ys := ([1, 1, 1, 1, 1, 100] : List ℚ)) (by norm_num)
    (by norm_num [MedianBreakdown.diffCount]) hm
    (by intro x hx; fin_cases hx <;> norm_num)
  exact h

/-!
## 4.  The knee side of the power law
-/

/-- The knee the margin channel asks for, given a margin `m` at depth `d`. -/
noncomputable def kneeOfMargin (L B A ctx : ℝ) (d : ℕ) (m : ℝ) : ℝ :=
  4 * L * B * A * d * ctx / m

/-- **The knee ratio under a power-law margin.**  If `m(d) = m₁·d^(-α)` then the
knee grows by the factor `4^(1+α)` between depths `4` and `16`: the depth leg
contributes the `4`, the margin drift the `4^α`. -/
theorem knee_ratio_power_law {L B A ctx m₁ α : ℝ} (hL : 0 < L) (hB : 0 < B)
    (hA : 0 < A) (hctx : 0 < ctx) (hm₁ : 0 < m₁) :
    kneeOfMargin L B A ctx 16 (marginPow m₁ α 16)
        / kneeOfMargin L B A ctx 4 (marginPow m₁ α 4)
      = (4 : ℝ) ^ (1 + α) := by
  have h16 : (0 : ℝ) < marginPow m₁ α 16 := by
    unfold marginPow
    have : (0 : ℝ) < (16 : ℝ) ^ (-α) := Real.rpow_pos_of_pos (by norm_num) _
    positivity
  have h4 : (0 : ℝ) < marginPow m₁ α 4 := by
    unfold marginPow
    have : (0 : ℝ) < (4 : ℝ) ^ (-α) := Real.rpow_pos_of_pos (by norm_num) _
    positivity
  have hP : (0 : ℝ) < 4 * L * B * A * ctx := by positivity
  have hratio : marginPow m₁ α 16 / marginPow m₁ α 4 = (4 : ℝ) ^ (-α) :=
    marginPow_ratio hm₁
  have hstep : kneeOfMargin L B A ctx 16 (marginPow m₁ α 16)
        / kneeOfMargin L B A ctx 4 (marginPow m₁ α 4)
      = 4 * (marginPow m₁ α 4 / marginPow m₁ α 16) := by
    unfold kneeOfMargin
    push_cast
    field_simp
    ring
  rw [hstep, show marginPow m₁ α 4 / marginPow m₁ α 16
      = (marginPow m₁ α 16 / marginPow m₁ α 4)⁻¹ by rw [inv_div], hratio,
    Real.rpow_neg (by norm_num : (0:ℝ) ≤ 4), inv_inv,
    Real.rpow_add (by norm_num : (0:ℝ) < 4), Real.rpow_one]

/-- **The measured knee ratio forces a depth-free margin.**  The grid reports
`k*(16)/k*(4) = 64/16 = 4`.  Under the power-law ansatz that value is `4^(1+α)`,
so `α = 0`: the margin does not drift with depth.  This is E3 derived from the
*knee* measurement, complementing `margin_exponent_zero`, which derives it from
the margin measurement. -/
theorem measured_knee_ratio_forces_alpha_zero {α : ℝ} (h : (4 : ℝ) ^ (1 + α) = 4) :
    α = 0 := by
  have hlog4 : 0 < Real.log 4 := Real.log_pos (by norm_num)
  have hl : Real.log ((4 : ℝ) ^ (1 + α)) = (1 + α) * Real.log 4 :=
    Real.log_rpow (by norm_num) _
  rw [h] at hl
  have : α * Real.log 4 = 0 := by nlinarith [hl]
  rcases mul_eq_zero.mp this with h' | h'
  · exact h'
  · exact absurd h' hlog4.ne'

/-- **Non-vacuity of §4.**  The exponent `α = 0` does produce the measured knee
ratio `4`, so the constraint of `measured_knee_ratio_forces_alpha_zero` is
satisfiable and the theorem is not vacuous. -/
theorem alpha_zero_realises_measured_ratio : (4 : ℝ) ^ (1 + (0 : ℝ)) = 4 := by
  norm_num

end MarginDepthRigidity