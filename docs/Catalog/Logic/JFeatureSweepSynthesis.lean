/-
# Synthesis: what a flat j-feature sweep does and does not establish

This file ties together the three strands of the paper-248 analysis.

* `pval_maxRatio_eq_one` : the **uncalibrated** scan statistic
  `max_k rate(cell k) / globalRate` is `≥ 1` on *every* draw of the null
  ensemble (pigeonhole, `Logic.JFeature.exists_fiber_rate_ge_globalRate`), so the
  naive test "the best cell exceeds the global rate" has permutation p-value
  exactly `1`.  Only a max-statistic calibration can say anything.
* `sweep_blindness_two_views` : a carrier living in the *joint* structure is
  invisible to marginal features in **two independent statistical views** — the
  contingency view (enrichment ratio exactly `1`, this development) and the
  regression view (degree-1 `R² ≤ 0`, `Logic.PhaseRoute.Rsq_additive_nonpos`).
  Flatness of a marginal sweep is therefore a property of the *test*, not
  evidence about the carrier.
-/
import Logic.JFeatureMarginalBlindness
import Logic.JFeatureMaxStatistic
import Logic.PhaseRouteAlignment

namespace Logic.JFeature

open Finset

section NaiveScan

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]
variable {κ : Type*} [Fintype κ] [DecidableEq κ]
variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- The raw (uncalibrated) scan statistic of a sweep: the largest cell-to-global
rate ratio over the scanned feature cells, evaluated on a null draw `w` whose
hit set is `Hs w`. -/
noncomputable def maxRatioStat (u : ι → κ) (Hs : Ω → Finset ι)
    (hκ : (univ : Finset κ).Nonempty) (w : Ω) : ℝ :=
  (univ : Finset κ).sup' hκ
    (fun k => rate (Hs w) (univ.filter (fun i => u i = k)) / globalRate (Hs w))

omit [Fintype Ω] [Nonempty Ω] in
/-- **The scan statistic never drops below `1`.**  Pure pigeonhole: some cell
always carries at least a proportional share of the hits. -/
theorem one_le_maxRatioStat (u : ι → κ) (Hs : Ω → Finset ι)
    (hκ : (univ : Finset κ).Nonempty) (hne : ∀ w, (Hs w).Nonempty) (w : Ω) :
    1 ≤ maxRatioStat u Hs hκ w := by
  obtain ⟨k, _, hk⟩ := exists_fiber_rate_ge_globalRate u (Hs w)
  have hg : 0 < globalRate (Hs w) := by
    have h1 : 0 < ((Hs w).card : ℝ) := by
      have : 0 < (Hs w).card := Finset.card_pos.2 (hne w)
      exact_mod_cast this
    have h2 : (0:ℝ) < (Fintype.card ι : ℝ) := by
      have : 0 < Fintype.card ι := Fintype.card_pos
      exact_mod_cast this
    unfold globalRate; positivity
  have h1 : (1:ℝ) ≤ rate (Hs w) (univ.filter (fun i => u i = k)) / globalRate (Hs w) := by
    rw [le_div_iff₀ hg, one_mul]
    exact hk
  refine le_trans h1 ?_
  rw [maxRatioStat]
  exact Finset.le_sup' (f := fun k =>
    rate (Hs w) (univ.filter (fun i => u i = k)) / globalRate (Hs w)) (Finset.mem_univ k)

/-- **The naive scan test has permutation p-value exactly `1`.**  Comparing the
observed best-cell ratio against the value `1` — rather than against the null
distribution of the *maximum* — rejects on the entire null ensemble.  This is
the formal content of the extreme-value demonstration: a raw max of `1.5578`
over 105 cells is meaningless without the max-statistic null. -/
theorem pval_maxRatio_eq_one [DecidableEq Ω] (u : ι → κ) (Hs : Ω → Finset ι)
    (hκ : (univ : Finset κ).Nonempty) (hne : ∀ w, (Hs w).Nonempty) :
    pval (maxRatioStat u Hs hκ) 1 = 1 :=
  pval_eq_one_of_floor (one_le_maxRatioStat u Hs hκ hne)

end NaiveScan

section TwoViews

open Logic.PhaseRoute

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
variable [Nonempty α] [Nonempty β]

omit [Nonempty α] [Nonempty β] in
/-- The real-valued indicator of the permutation-graph hit set is the alignment
target `graphInd` of `Logic.PhaseRoute`. -/
lemma indicator_graphFinset_eq_graphInd (σ : α ≃ β) (x : α × β) :
    (if x ∈ graphFinset σ then (1:ℝ) else 0) = graphInd σ x := by
  by_cases h : x.2 = σ x.1 <;> simp [graphFinset, graphInd, h]

/-- **Two independent views of the same blindness.**  For the joint carrier
`graphFinset σ`:

* contingency view — the enrichment ratio of the cell cut out by *any* feature
  of the first coordinate is exactly `1`;
* regression view — *every* additive (singleton-feature) predictor has
  coefficient of determination `R² ≤ 0` for the same target;

while the joint cell is enriched by the unbounded factor `card β`.  A sweep that
finds `R ≈ 1` and `R² ≈ 0` on marginal features has learned nothing about the
presence of a joint carrier. -/
theorem sweep_blindness_two_views {κ : Type*} [DecidableEq κ]
    (σ : α ≃ β) (hcard : 2 ≤ Fintype.card α) (u : α → κ) (k : κ)
    (hS : (univ.filter (fun a => u a = k)).Nonempty)
    (hSc : (univ.filter (fun a => u a = k))ᶜ.Nonempty) :
    enrich (graphFinset σ) (univ.filter (fun x : α × β => u x.1 = k)) = 1 ∧
      (∀ (f : α → ℝ) (g : β → ℝ), Rsq (graphInd σ) (additive f g) ≤ 0) ∧
      rate (graphFinset σ) (graphFinset σ)
        = (Fintype.card β : ℝ) * globalRate (graphFinset σ) := by
  have hpos : 0 < Fintype.card α := lt_of_lt_of_le (by norm_num) hcard
  refine ⟨?_, ?_, graph_joint_rate_eq_card_mul_globalRate σ hpos⟩
  · exact enrich_marginal_feature_eq_one (graphFinset_rowBalanced σ) one_pos u k hS hSc
  · intro f g
    exact Rsq_additive_nonpos σ hcard f g

end TwoViews

end Logic.JFeature