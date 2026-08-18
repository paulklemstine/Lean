/-
# The knee pipeline inherits the breakdown point of its aggregator

This file closes conjecture **C6** of `FUTURE_DIRECTIONS.md` by composing the two halves
proved separately in this development:

* `knee_of_median_curve_general` — for `2k+1` monotone retention curves, aggregating the
  curves pointwise by the median and *then* reading a knee gives the median of the individual
  knees;
* `tropMedian_breakdown` — a median of `2k+1` values cannot leave the range spanned by any
  `k+1` of them.

Composing them gives `knee_pipeline_breakdown`: if `k+1` of the seeds are trustworthy, the knee
of the median curve stays between the smallest and the largest trustworthy knee, no matter how
the remaining `k` seeds' entire curves are corrupted (they need not even resemble the clean
ones — only monotonicity is assumed, and that only so that they *have* knees).

The companion `mean_curve_knee_has_no_breakdown` shows the mean pipeline has breakdown point
`0`: two clean unit-step curves with knee `1` plus **one** corrupted step curve with knee `N`
give a mean curve whose knee is `N`, arbitrarily far outside the clean range `[1,1]`.  So the
robustness of the reported centre is a property of the tropical aggregator, not of averaging.

`net48_knee_pipeline_breakdown` is the NET-48 deployment reading: with seeds 1 and 2 fixed at
the measured knees `256` and `224`, any fourth measurement of the third seed leaves the knee of
the median curve inside `[224, 256]`.
-/
import Tropical.KneeMedian.KneeMedianCommutation
import Tropical.KneeMedian.TropicalRobustness

namespace Catalog.Tropical.KneeMedian

open Finset

/-- **Breakdown of the median knee pipeline.**  Let `c'` be `2k+1` monotone retention curves
with knees `K'`, and suppose that on an index set `T` of size at least `k+1` these knees agree
with a reference (clean) knee vector `K`.  Then the pointwise median curve has a knee, namely
`tropMedian K'`, and that knee lies between the smallest and the largest clean knee.

In words: corrupting at most `k` of the `2k+1` seeds — arbitrarily, curve and all — cannot move
the reported centre outside the interval spanned by the surviving seeds. -/
theorem knee_pipeline_breakdown {β : Type*} [LinearOrder β] {k : ℕ} {G : Finset ℕ} {bar : β}
    {c' : Fin (2 * k + 1) → ℕ → β} {K K' : Fin (2 * k + 1) → ℕ}
    (hmono : ∀ i, Monotone (c' i)) (hknee : ∀ i, IsKneeOn G bar (c' i) (K' i))
    (T : Finset (Fin (2 * k + 1))) (hT : k + 1 ≤ T.card) (hne : T.Nonempty)
    (hagree : ∀ i ∈ T, K i = K' i) :
    IsKneeOn G bar (fun t => tropMedian (fun i => c' i t)) (tropMedian K') ∧
      T.inf' hne K ≤ tropMedian K' ∧ tropMedian K' ≤ T.sup' hne K :=
  ⟨knee_of_median_curve_general hmono hknee, tropMedian_breakdown K K' T hT hne hagree⟩

/-- **The mean knee pipeline has breakdown point zero.**  Two clean seeds with knee `1` and a
single corrupted seed with knee `N` produce a *mean* curve whose knee is `N`: one bad seed out
of three drags the aggregate knee arbitrarily far outside the clean range `[1, 1]`.  Contrast
`knee_pipeline_breakdown`, where the median pipeline would have returned `1`. -/
theorem mean_curve_knee_has_no_breakdown (N : ℕ) (hN : 1 < N) :
    ∃ c : Fin 3 → ℕ → ℝ, (∀ i, Monotone (c i)) ∧
      IsKneeOn {1, N} 1 (c 0) 1 ∧ IsKneeOn {1, N} 1 (c 1) 1 ∧
      IsKneeOn {1, N} 1 (fun t => (c 0 t + c 1 t + c 2 t) / 3) N := by
  classical
  refine ⟨![stepCurve 1, stepCurve 1, stepCurve N], ?_, ?_, ?_, ?_⟩
  · intro i
    fin_cases i <;> simpa using stepCurve_monotone _
  · exact isKneeOn_stepCurve (by simp)
  · exact isKneeOn_stepCurve (by simp)
  · have hmemN : N ∈ ({1, N} : Finset ℕ) := by simp
    refine ⟨hmemN, ?_, ?_⟩
    · have h1 : stepCurve 1 N = 1 := by
        unfold stepCurve; rw [if_pos (le_of_lt hN)]
      have h2 : stepCurve N N = 1 := by
        unfold stepCurve; rw [if_pos le_rfl]
      simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
        Matrix.cons_val_two, Matrix.tail_cons, h1, h2]
      norm_num
    · intro j hj hbar
      have hj' : j = 1 ∨ j = N := by simpa using hj
      rcases hj' with rfl | rfl
      · exfalso
        have h1 : stepCurve 1 1 = 1 := by unfold stepCurve; rw [if_pos le_rfl]
        have h2 : stepCurve N 1 = 0 := by
          unfold stepCurve; rw [if_neg (by omega)]
        simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons,
          Matrix.cons_val_two, Matrix.tail_cons, h1, h2] at hbar
        norm_num at hbar
      · exact le_rfl

/-- **NET-48 deployment reading.**  Take three monotone retention curves whose knees are the
measured seed-1 and seed-2 values `256`, `224` together with an arbitrary third value `t`.
Then the knee of the median curve is `tropMed3 256 224 t`, and it lies in `[224, 256]`: a
fourth measurement of the third seed — whatever it reports — cannot move the reported centre
out of the interval pinned by the other two seeds. -/
theorem net48_knee_pipeline_breakdown {G : Finset ℕ} {bar : ℝ} {c₀ c₁ c₂ : ℕ → ℝ} {t : ℕ}
    (m₀ : Monotone c₀) (m₁ : Monotone c₁) (m₂ : Monotone c₂)
    (h₀ : IsKneeOn G bar c₀ 256) (h₁ : IsKneeOn G bar c₁ 224) (h₂ : IsKneeOn G bar c₂ t) :
    IsKneeOn G bar (fun s => tropMed3 (c₀ s) (c₁ s) (c₂ s)) (tropMed3 256 224 t) ∧
      224 ≤ tropMed3 256 224 t ∧ tropMed3 256 224 t ≤ 256 := by
  refine ⟨knee_of_median_curve m₀ m₁ m₂ h₀ h₁ h₂, ?_, ?_⟩
  · exact le_trans (by norm_num) (tropMed3_breakdown (256 : ℕ) 224 t).1
  · exact le_trans (tropMed3_breakdown (256 : ℕ) 224 t).2 (by norm_num)

end Catalog.Tropical.KneeMedian