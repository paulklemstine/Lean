import Probability.NET89SignalResolution

/-!
# NET-89, cycle 14: the critical weight of a mixing-ratio sweep

Cycle 9 proved that the collapse region of a mixing-ratio sweep — the set of weights at
which the pooled knee already equals the dominant component's knee — is upward closed and
non-empty, so a phase boundary exists.  Direction **D5** asked for the boundary itself:
a *lower* witness to match the upper one, and if possible an exact value.

This cycle supplies both, in the two forms the question has.

* `collapseSet`, `critWeight` — the collapse region and its infimum, the **critical
  weight** of the sweep.
* `collapse_of_critWeight_lt` and `not_collapse_of_lt_critWeight` — the critical weight is
  exactly the kink: strictly above it the knee has collapsed, strictly below it has not.
  The sweep is therefore a step function of the weight with one identified threshold, not
  merely an eventually constant one.
* `one_le_critWeight_of_pool_knee_ne` — **the general lower witness.**  A single balanced
  measurement whose pooled knee misses the dominant knee already forces the critical weight
  above the balance point, so the boundary is interior whenever a balanced experiment shows
  an excess.  This is the missing half of cycle 9.
* `kstar_pool_uA_sweep` and `critWeight_uA_vFlat` — **the exact value in a computed case.**
  For the cycle-1 witness pair the whole sweep is determined: the knee is `3` below
  `8/19`, `2` on `[8/19, 2)`, and `1` from `2` on, so the critical weight is *exactly* `2`
  and the sweep has two kinks at explicitly computed rational weights.
* `net89_phase_boundary_interior` — the headline: the boundary is a genuine interior
  number, bracketed strictly away from both ends, and the balanced protocol of the report
  sits *below* it.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 14, ranked):
 (H1) The infimum of the collapse region is attained and separates the sweep exactly.
 (H2) A balanced measurement with a pooled excess is already a lower witness.    [BOLD]
 (H3) For an explicit pair the critical weight is a computable rational.          [BOLD]
 (H4) The sweep between the two extremes is itself a staircase with rational kinks,
      not a single jump.                                                          [BOLD]

Experimenter: H1–H4 formalised below, zero sorries.  The computed pair is the cycle-1
witness `uA = (10, 1, 1, 1)` against `vFlat = (1, 1, 1, 1)` at gate `7/10` and context `4`;
the two kinks are at `a = 8/19` and `a = 2`, and the second is the critical weight.

Analyst: cycle 9 said the sweep kinks and plateaus; cycle 14 says where.  The kink location
is not a new measurement: it is the weight at which the crossing gate `τ` moves between two
consecutive normalised head masses of the *pooled* profile, so it is computable from the two
component profiles alone.  For the reported 50/50 protocol (`a = 1`) the computed pair sits
strictly below its critical weight `2`, which is exactly why the balanced pooled knee `2`
exceeds the dominant knee `1`.

Critic: `critWeight` is an infimum over a set that could a priori be empty, so every
statement about it carries either a membership witness or the cycle-9 non-emptiness
hypothesis; none is vacuous.  The exact sweep theorem is a genuine three-case computation —
each case is a strict failure at one budget and a pass at the next — and not a `decide`.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ a : ℝ} {n : ℕ}

/-! ## 1. The collapse region and its infimum -/

/-- The **collapse region** of a mixing-ratio sweep: the weights at which the pooled knee
has already collapsed onto the first (dominant) component's knee. -/
def collapseSet (u v : ℕ → ℝ) (n : ℕ) (τ : ℝ) : Set ℝ :=
  {a : ℝ | 0 < a ∧ kstar (pool a 1 u v) n τ = kstar u n τ}

/-- The **critical weight** of the sweep: the infimum of the collapse region. -/
noncomputable def critWeight (u v : ℕ → ℝ) (n : ℕ) (τ : ℝ) : ℝ := sInf (collapseSet u v n τ)

lemma collapseSet_bddBelow (u v : ℕ → ℝ) (n : ℕ) (τ : ℝ) :
    BddBelow (collapseSet u v n τ) := ⟨0, fun _ ha => ha.1.le⟩

lemma mem_collapseSet_iff : a ∈ collapseSet u v n τ ↔
    0 < a ∧ kstar (pool a 1 u v) n τ = kstar u n τ := Iff.rfl

lemma critWeight_le_of_mem (ha : a ∈ collapseSet u v n τ) : critWeight u v n τ ≤ a :=
  csInf_le (collapseSet_bddBelow u v n τ) ha

lemma critWeight_nonneg (hne : (collapseSet u v n τ).Nonempty) : 0 ≤ critWeight u v n τ :=
  le_csInf hne fun _ hb => hb.1.le

/-- The collapse region is non-empty under the cycle-9 hypotheses. -/
lemma collapseSet_nonempty (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ0 : 0 < τ) (hτ : τ ≤ 1) (hK : 1 ≤ kstar u n τ)
    (hstrict : τ < retained u n (kstar u n τ)) : (collapseSet u v n τ).Nonempty := by
  obtain ⟨a, ha, hcol⟩ := exists_ratio_with_dominant_knee hu hv hn hτ0 hτ hK hstrict
  exact ⟨a, ha, hcol⟩

/-! ## 2. The critical weight is exactly the kink -/

/-- **Above the critical weight the knee has collapsed.** -/
theorem collapse_of_critWeight_lt (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k)
    (hne : (collapseSet u v n τ).Nonempty) (ha : critWeight u v n τ < a) :
    kstar (pool a 1 u v) n τ = kstar u n τ := by
  obtain ⟨b, hb, hba⟩ := exists_lt_of_csInf_lt hne ha
  have ha0 : 0 < a := lt_trans hb.1 hba
  exact pool_knee_dominant_ratios_upward_closed hu hv hn hτ hdom ha0 one_pos hb.1 one_pos
    (by linarith) hb.2

/-- **Below the critical weight it has not.** -/
theorem not_collapse_of_lt_critWeight (ha0 : 0 < a) (ha : a < critWeight u v n τ) :
    kstar (pool a 1 u v) n τ ≠ kstar u n τ := fun hcol =>
  absurd (critWeight_le_of_mem ⟨ha0, hcol⟩) (not_le.mpr ha)

/-- **The sweep is a step function with one identified threshold.**  Strictly above the
critical weight the pooled knee equals the dominant component's knee; strictly below it
does not.  Cycle 9 located a plateau; this locates its edge. -/
theorem net89_sweep_threshold (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k)
    (hne : (collapseSet u v n τ).Nonempty) :
    (∀ a : ℝ, critWeight u v n τ < a → kstar (pool a 1 u v) n τ = kstar u n τ) ∧
      (∀ a : ℝ, 0 < a → a < critWeight u v n τ →
        kstar (pool a 1 u v) n τ ≠ kstar u n τ) :=
  ⟨fun _ ha => collapse_of_critWeight_lt hu hv hn hτ hdom hne ha,
    fun _ ha0 ha => not_collapse_of_lt_critWeight ha0 ha⟩

/-- **The general lower witness.**  If the *balanced* mixture already fails to collapse,
the critical weight is at least the balance point: a balanced experiment that shows a
pooled excess proves the phase boundary is interior.  This is the half of the boundary
cycle 9 left open. -/
theorem one_le_critWeight_of_pool_knee_ne (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k)
    (hne : (collapseSet u v n τ).Nonempty)
    (hbal : kstar (pool 1 1 u v) n τ ≠ kstar u n τ) : 1 ≤ critWeight u v n τ := by
  refine le_csInf hne fun b hb => ?_
  by_contra hlt
  push_neg at hlt
  exact hbal (pool_knee_dominant_ratios_upward_closed hu hv hn hτ hdom one_pos one_pos
    hb.1 one_pos (by linarith) hb.2)

/-! ## 3. The exact sweep of the cycle-1 witness pair -/

lemma pool_uA_pos (ha : 0 < a) : ∀ i, 0 < pool a 1 uA vFlat i :=
  pool_pos ha one_pos uA_pos vFlat_pos

lemma headMass_pool_uA : headMass (pool a 1 uA vFlat) 4 = 13 * a + 4 := by
  simp [headMass, pool, uA, vFlat, Finset.sum_range_succ]
  ring

/-- Below `8/19` the sweep sits at the flat domain's knee `3`. -/
lemma kstar_pool_uA_low (ha : 0 < a) (h : a < 8 / 19) :
    kstar (pool a 1 uA vFlat) 4 (7 / 10) = 3 := by
  have hden : (0 : ℝ) < 13 * a + 4 := by linarith
  refine kstar_eq_of_fail_pass (pool_uA_pos ha) (by norm_num) (by norm_num) (m := 2) ?_ ?_
  · rw [retained, show min 2 4 = 2 from rfl, headMass_pool_uA]
    rw [div_lt_iff₀ hden]
    simp [headMass, pool, uA, vFlat, Finset.sum_range_succ]
    linarith
  · rw [retained, show min 3 4 = 3 from rfl, headMass_pool_uA]
    rw [le_div_iff₀ hden]
    simp [headMass, pool, uA, vFlat, Finset.sum_range_succ]
    linarith

/-- On `[8/19, 2)` the sweep sits strictly between the two component knees. -/
lemma kstar_pool_uA_mid (h1 : 8 / 19 ≤ a) (h2 : a < 2) :
    kstar (pool a 1 uA vFlat) 4 (7 / 10) = 2 := by
  have ha : 0 < a := by linarith
  have hden : (0 : ℝ) < 13 * a + 4 := by linarith
  refine kstar_eq_of_fail_pass (pool_uA_pos ha) (by norm_num) (by norm_num) (m := 1) ?_ ?_
  · rw [retained, show min 1 4 = 1 from rfl, headMass_pool_uA]
    rw [div_lt_iff₀ hden]
    simp [headMass, pool, uA, vFlat]
    linarith
  · rw [retained, show min 2 4 = 2 from rfl, headMass_pool_uA]
    rw [le_div_iff₀ hden]
    simp [headMass, pool, uA, vFlat, Finset.sum_range_succ]
    linarith

/-- From `2` on the sweep has collapsed onto the head-heavy domain's knee `1`. -/
lemma kstar_pool_uA_high (h : 2 ≤ a) : kstar (pool a 1 uA vFlat) 4 (7 / 10) = 1 := by
  have ha : 0 < a := by linarith
  have hden : (0 : ℝ) < 13 * a + 4 := by linarith
  refine kstar_eq_of_fail_pass (pool_uA_pos ha) (by norm_num) (by norm_num) (m := 0) ?_ ?_
  · rw [retained, show min 0 4 = 0 from rfl]
    simp [headMass]
  · rw [retained, show min 1 4 = 1 from rfl, headMass_pool_uA]
    rw [le_div_iff₀ hden]
    simp [headMass, pool, uA, vFlat]
    linarith

/-- **The whole sweep, explicitly.**  For the cycle-1 witness pair the knee as a function of
the mixing weight is a three-step staircase with kinks at the rational weights `8/19` and
`2`. -/
theorem kstar_pool_uA_sweep (ha : 0 < a) :
    kstar (pool a 1 uA vFlat) 4 (7 / 10) =
      if 2 ≤ a then 1 else if 8 / 19 ≤ a then 2 else 3 := by
  by_cases h2 : 2 ≤ a
  · rw [if_pos h2]; exact kstar_pool_uA_high h2
  · rw [if_neg h2]
    push_neg at h2
    by_cases h1 : 8 / 19 ≤ a
    · rw [if_pos h1]; exact kstar_pool_uA_mid h1 h2
    · rw [if_neg h1]
      push_neg at h1
      exact kstar_pool_uA_low ha h1

/-- **The critical weight, computed.**  For the cycle-1 witness pair the phase boundary of
the mixing-ratio sweep is at weight exactly `2`: the head-heavy domain must carry twice the
weight of the flat one before the mixture inherits its knee. -/
theorem critWeight_uA_vFlat : critWeight uA vFlat 4 (7 / 10) = 2 := by
  have hmem : (2 : ℝ) ∈ collapseSet uA vFlat 4 (7 / 10) := by
    refine ⟨by norm_num, ?_⟩
    rw [kstar_pool_uA_high le_rfl, kstar_uA]
  refine le_antisymm (critWeight_le_of_mem hmem) ?_
  refine le_csInf ⟨2, hmem⟩ fun b hb => ?_
  by_contra hlt
  push_neg at hlt
  have hb0 : 0 < b := hb.1
  have hknee : kstar (pool b 1 uA vFlat) 4 (7 / 10) = 1 := by rw [hb.2, kstar_uA]
  rcases le_or_gt (8 / 19 : ℝ) b with hmid | hlow
  · rw [kstar_pool_uA_mid hmid hlt] at hknee; omega
  · rw [kstar_pool_uA_low hb0 hlow] at hknee; omega

/-- **The boundary is interior, and the reported protocol sits below it.**  The critical
weight of the computed pair is `2`: the balanced protocol (`a = 1`) is strictly inside the
non-collapsed regime, which is exactly why its pooled knee `2` exceeds the dominant
component's knee `1`; every weight above `2` collapses and every positive weight below `2`
does not.  A mixing-ratio sweep therefore has a *computable* kink, not merely an
asymptotic plateau. -/
theorem net89_phase_boundary_interior :
    critWeight uA vFlat 4 (7 / 10) = 2 ∧
      kstar (pool 1 1 uA vFlat) 4 (7 / 10) = 2 ∧ kstar uA 4 (7 / 10) = 1 ∧
      (∀ a : ℝ, 2 ≤ a → kstar (pool a 1 uA vFlat) 4 (7 / 10) = kstar uA 4 (7 / 10)) ∧
      (∀ a : ℝ, 0 < a → a < 2 → kstar (pool a 1 uA vFlat) 4 (7 / 10) ≠ kstar uA 4 (7 / 10)) := by
  refine ⟨critWeight_uA_vFlat, kstar_poolA, kstar_uA, fun a ha => ?_, fun a ha0 ha => ?_⟩
  · rw [kstar_pool_uA_high ha, kstar_uA]
  · rw [kstar_uA]
    rcases le_or_gt (8 / 19 : ℝ) a with hmid | hlow
    · rw [kstar_pool_uA_mid hmid ha]; omega
    · rw [kstar_pool_uA_low ha0 hlow]; omega

end Catalog.Probability.NET89MixedDomainKnee