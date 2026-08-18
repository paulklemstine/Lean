/-
# The knee of the median curve is the median of the knees

A *knee* of a retention curve `c : ℕ → ℝ` on a grid `G` at a bar `bar` is the least grid point
whose retention clears the bar.  The seed thread reports one knee per seed and then takes the
median of the three knees; a natural but unexamined alternative is to first average the three
curves and read a single knee off the aggregate.  This file proves these two operations agree
*exactly* when the aggregation is the (pointwise) **median** of the curves:

    `knee (fun t => med (c₀ t) (c₁ t) (c₂ t)) = med (knee c₀) (knee c₁) (knee c₂)`

(`knee_of_median_curve`).  The proof is pure threshold duality: `bar ≤ med(x)` iff at least two
of the three entries clear the bar (`le_tropMed3_iff`), and `med(k) ≤ t` iff at least two of the
three knees are `≤ t` (`tropMed3_le_iff`); monotone curves convert one into the other.

Two negative companions delimit the result:

* `mean_curve_knee_ne_median_knee` — the same statement fails for the *mean* of the curves:
  three explicit monotone step curves with knees `1, 2, 3` have mean-curve knee `3 ≠ 2`;
* `knee_median_needs_monotone` — monotonicity of the curves cannot be dropped.

Finally `net48_median_curve_knee` instantiates the theorem on the measured NET-48 knee triple
`{256, 224, 160}`: any three monotone curves realising those knees have median curve of knee
exactly `224`, the reported centre; `net48_median_curve_knee_nonvacuous` exhibits such curves.
-/
import Tropical.KneeMedian.TropicalNormalForm

namespace Catalog.Tropical.KneeMedian

/-- `IsKneeOn G bar c k`: `k` is the least point of the grid `G` at which the curve `c`
clears the bar. -/
def IsKneeOn {β : Type*} [LinearOrder β] (G : Finset ℕ) (bar : β) (c : ℕ → β) (k : ℕ) : Prop :=
  k ∈ G ∧ bar ≤ c k ∧ ∀ j ∈ G, bar ≤ c j → k ≤ j

/-- **Median–knee commutation.**  For monotone retention curves, the knee of the pointwise
median curve is the median of the individual knees. -/
theorem knee_of_median_curve {β : Type*} [LinearOrder β] {G : Finset ℕ} {bar : β}
    {c₀ c₁ c₂ : ℕ → β} {k₀ k₁ k₂ : ℕ}
    (m₀ : Monotone c₀) (m₁ : Monotone c₁) (m₂ : Monotone c₂)
    (h₀ : IsKneeOn G bar c₀ k₀) (h₁ : IsKneeOn G bar c₁ k₁) (h₂ : IsKneeOn G bar c₂ k₂) :
    IsKneeOn G bar (fun t => tropMed3 (c₀ t) (c₁ t) (c₂ t)) (tropMed3 k₀ k₁ k₂) := by
  set K : ℕ := tropMed3 k₀ k₁ k₂ with hK
  have hmemG : K ∈ G := by
    rcases tropMed3_eq_or k₀ k₁ k₂ with h | h | h
    · rw [hK, h]; exact h₀.1
    · rw [hK, h]; exact h₁.1
    · rw [hK, h]; exact h₂.1
  have htwo : (k₀ ≤ K ∧ k₁ ≤ K) ∨ (k₁ ≤ K ∧ k₂ ≤ K) ∨ (k₀ ≤ K ∧ k₂ ≤ K) :=
    (tropMed3_le_iff K k₀ k₁ k₂).mp (le_of_eq hK.symm)
  refine ⟨hmemG, ?_, ?_⟩
  · -- the median curve clears the bar at `K`, because two of the curves do
    rcases htwo with ⟨ha, hb⟩ | ⟨ha, hb⟩ | ⟨ha, hb⟩
    · exact (le_tropMed3_iff bar (c₀ K) (c₁ K) (c₂ K)).mpr
        (Or.inl ⟨le_trans h₀.2.1 (m₀ ha), le_trans h₁.2.1 (m₁ hb)⟩)
    · exact (le_tropMed3_iff bar (c₀ K) (c₁ K) (c₂ K)).mpr
        (Or.inr (Or.inl ⟨le_trans h₁.2.1 (m₁ ha), le_trans h₂.2.1 (m₂ hb)⟩))
    · exact (le_tropMed3_iff bar (c₀ K) (c₁ K) (c₂ K)).mpr
        (Or.inr (Or.inr ⟨le_trans h₀.2.1 (m₀ ha), le_trans h₂.2.1 (m₂ hb)⟩))
  · -- minimality: if the median curve clears the bar at `j`, two knees are `≤ j`
    intro j hj hbar
    rcases (le_tropMed3_iff bar (c₀ j) (c₁ j) (c₂ j)).mp hbar with
      ⟨ha, hb⟩ | ⟨ha, hb⟩ | ⟨ha, hb⟩
    · exact (tropMed3_le_iff j k₀ k₁ k₂).mpr (Or.inl ⟨h₀.2.2 j hj ha, h₁.2.2 j hj hb⟩)
    · exact (tropMed3_le_iff j k₀ k₁ k₂).mpr
        (Or.inr (Or.inl ⟨h₁.2.2 j hj ha, h₂.2.2 j hj hb⟩))
    · exact (tropMed3_le_iff j k₀ k₁ k₂).mpr
        (Or.inr (Or.inr ⟨h₀.2.2 j hj ha, h₂.2.2 j hj hb⟩))

/-- Knees are unique, so the commutation theorem determines the knee of the median curve. -/
theorem IsKneeOn.unique {β : Type*} [LinearOrder β] {G : Finset ℕ} {bar : β} {c : ℕ → β}
    {k k' : ℕ}
    (h : IsKneeOn G bar c k) (h' : IsKneeOn G bar c k') : k = k' :=
  le_antisymm (h.2.2 k' h'.1 h'.2.1) (h'.2.2 k h.1 h.2.1)

/-! ## The general `2k+1`-seed version -/

/-- **Median–knee commutation for any odd number of seeds.**  If `2k+1` monotone retention
curves have knees `K i`, then the pointwise median curve has knee exactly the median of the
`K i`.  The proof is threshold duality in both directions: clearing the bar for the median
curve is a majority event, and being `≤ t` for the median knee is the same majority event. -/
theorem knee_of_median_curve_general {β : Type*} [LinearOrder β] {k : ℕ} {G : Finset ℕ}
    {bar : β} {c : Fin (2 * k + 1) → ℕ → β} {K : Fin (2 * k + 1) → ℕ}
    (hmono : ∀ i, Monotone (c i)) (hknee : ∀ i, IsKneeOn G bar (c i) (K i)) :
    IsKneeOn G bar (fun t => tropMedian (fun i => c i t)) (tropMedian K) := by
  classical
  obtain ⟨i₀, hi₀⟩ := tropMedian_mem_range K
  refine ⟨by rw [hi₀]; exact (hknee i₀).1, ?_, ?_⟩
  · -- at the median knee, at least `k+1` curves have already cleared the bar
    have hmaj : k + 1 ≤ (Finset.univ.filter fun i => K i ≤ tropMedian K).card :=
      (tropMedian_le_iff K (tropMedian K)).mp le_rfl
    refine (le_tropMedian_iff (fun i => c i (tropMedian K)) bar).mpr ?_
    refine le_trans hmaj (Finset.card_le_card ?_)
    intro i hi
    have hKi : K i ≤ tropMedian K := (Finset.mem_filter.mp hi).2
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ i,
      le_trans (hknee i).2.1 (hmono i hKi)⟩
  · -- minimality: a majority of curves clearing the bar at `j` forces a majority of knees `≤ j`
    intro j hj hbar
    have hmaj : k + 1 ≤ (Finset.univ.filter fun i => bar ≤ c i j).card :=
      (le_tropMedian_iff (fun i => c i j) bar).mp hbar
    refine (tropMedian_le_iff K j).mpr (le_trans hmaj (Finset.card_le_card ?_))
    intro i hi
    exact Finset.mem_filter.mpr ⟨Finset.mem_univ i,
      (hknee i).2.2 j hj (Finset.mem_filter.mp hi).2⟩

/-! ## Explicit step curves, and the failure of the mean -/

/-- The unit step curve that switches on at `k`. -/
noncomputable def stepCurve (k : ℕ) : ℕ → ℝ := fun t => if k ≤ t then 1 else 0

theorem stepCurve_monotone (k : ℕ) : Monotone (stepCurve k) := by
  intro s t hst
  unfold stepCurve
  by_cases h : k ≤ s
  · rw [if_pos h, if_pos (le_trans h hst)]
  · rw [if_neg h]
    split_ifs <;> norm_num

theorem isKneeOn_stepCurve {G : Finset ℕ} {k : ℕ} (hk : k ∈ G) :
    IsKneeOn G 1 (stepCurve k) k := by
  refine ⟨hk, ?_, ?_⟩
  · simp [stepCurve]
  · intro j _ hj
    by_contra hlt
    push_neg at hlt
    rw [stepCurve, if_neg (by omega)] at hj
    norm_num at hj

/-- The commutation theorem is not vacuous: explicit monotone step curves realise any triple
of grid knees, and their median curve has the median knee. -/
theorem knee_of_median_curve_nonvacuous {G : Finset ℕ} {k₀ k₁ k₂ : ℕ}
    (h₀ : k₀ ∈ G) (h₁ : k₁ ∈ G) (h₂ : k₂ ∈ G) :
    IsKneeOn G 1 (fun t => tropMed3 (stepCurve k₀ t) (stepCurve k₁ t) (stepCurve k₂ t))
      (tropMed3 k₀ k₁ k₂) :=
  knee_of_median_curve (stepCurve_monotone k₀) (stepCurve_monotone k₁) (stepCurve_monotone k₂)
    (isKneeOn_stepCurve h₀) (isKneeOn_stepCurve h₁) (isKneeOn_stepCurve h₂)

/-- **The mean does not commute with the knee.**  Three monotone step curves with knees
`1, 2, 3` have a mean curve whose knee (at the same bar) is `3`, not the median `2`.  So the
commutation theorem is a property of the median specifically. -/
theorem mean_curve_knee_ne_median_knee :
    IsKneeOn {1, 2, 3} 1 (fun t => (stepCurve 1 t + stepCurve 2 t + stepCurve 3 t) / 3) 3 ∧
      tropMed3 1 2 3 = 2 ∧ (3 : ℕ) ≠ tropMed3 1 2 3 := by
  refine ⟨?_, ?_, ?_⟩
  · refine ⟨by decide, ?_, ?_⟩
    · norm_num [stepCurve]
    · intro j hj hbar
      fin_cases hj
      · norm_num [stepCurve] at hbar
      · norm_num [stepCurve] at hbar
      · exact le_rfl
  · norm_num [tropMed3]
  · norm_num [tropMed3]

/-- **Monotonicity is needed.**  Without it the commutation fails: a curve that clears the bar
early and then falls back is counted by its own knee but not by the median curve.  Here the
knees are `1, 2, 3` with median `2`, yet the median curve is below the bar at `2`. -/
theorem knee_median_needs_monotone :
    ∃ (c₀ c₁ c₂ : ℕ → ℝ) (k₀ k₁ k₂ : ℕ),
      IsKneeOn {1, 2, 3} 1 c₀ k₀ ∧ IsKneeOn {1, 2, 3} 1 c₁ k₁ ∧ IsKneeOn {1, 2, 3} 1 c₂ k₂ ∧
        ¬ IsKneeOn {1, 2, 3} 1 (fun t => tropMed3 (c₀ t) (c₁ t) (c₂ t)) (tropMed3 k₀ k₁ k₂) := by
  refine ⟨fun t => if t = 2 then 0 else 1, stepCurve 2, stepCurve 3, 1, 2, 3, ?_, ?_, ?_, ?_⟩
  · refine ⟨by decide, by norm_num, ?_⟩
    intro j hj _
    fin_cases hj <;> omega
  · exact isKneeOn_stepCurve (by decide)
  · exact isKneeOn_stepCurve (by decide)
  · intro hcon
    have hval : tropMed3 1 2 3 = 2 := by norm_num [tropMed3]
    rw [hval] at hcon
    have h := hcon.2.1
    norm_num [stepCurve, tropMed3] at h

/-! ## The NET-48 instance -/

/-- With the measured 16× knees `256, 224, 160`, the pointwise median of any three monotone
retention curves realising them has knee exactly `224` — the reported centre of the
distribution is itself a knee, of the median model. -/
theorem net48_median_curve_knee {β : Type*} [LinearOrder β] {G : Finset ℕ} {bar : β}
    {c₀ c₁ c₂ : ℕ → β}
    (m₀ : Monotone c₀) (m₁ : Monotone c₁) (m₂ : Monotone c₂)
    (h₀ : IsKneeOn G bar c₀ 256) (h₁ : IsKneeOn G bar c₁ 224) (h₂ : IsKneeOn G bar c₂ 160) :
    IsKneeOn G bar (fun t => tropMed3 (c₀ t) (c₁ t) (c₂ t)) 224 := by
  have h := knee_of_median_curve m₀ m₁ m₂ h₀ h₁ h₂
  have hval : tropMed3 256 224 160 = 224 := by norm_num [tropMed3]
  rwa [hval] at h

/-- Non-vacuity of the NET-48 instance. -/
theorem net48_median_curve_knee_nonvacuous :
    IsKneeOn {160, 224, 256} 1
      (fun t => tropMed3 (stepCurve 256 t) (stepCurve 224 t) (stepCurve 160 t)) 224 :=
  net48_median_curve_knee (stepCurve_monotone 256) (stepCurve_monotone 224)
    (stepCurve_monotone 160) (isKneeOn_stepCurve (by decide))
    (isKneeOn_stepCurve (by decide)) (isKneeOn_stepCurve (by decide))

end Catalog.Tropical.KneeMedian