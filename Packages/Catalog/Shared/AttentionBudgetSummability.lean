import Shared.AttentionBudgetScaling

/-!
# The summability criterion: context stability is exactly convergence of the attention
profile

Cycle 3.  Cycles 1–2 exhibited two regimes — geometric decay (context-stable budget)
and a flat band (budget growing linearly with the context).  Geometric decay is however
far from necessary, and the true boundary is identified here.

**Main theorem** (`ctxStable_iff_summable`).  For a positive sorted attention profile
`w` and an interior gate `0 < τ < 1`,

    CtxStable w τ  ↔  Summable w.

Neither the gate nor the model enters: a finite key budget serves *every* context length
precisely when the sorted attention weights form a convergent series.  This upgrades the
sufficient condition of cycle 1 (geometric decay) to a characterisation, and it makes
the observed dichotomy gate-independent — an unexpected rigidity, since one would expect
a harsher gate to shrink the class of stable models.

**Phase transition** (`zipf_phase_transition`).  On the Zipf family
`w i = 1 / (i+1)^s` the criterion becomes `1 < s`: the attention budget undergoes a
sharp phase transition at Zipf exponent `1`, with a bounded budget above it and a budget
diverging with the context below it.  Measuring the knee at two context lengths
therefore locates a model on either side of `s = 1`.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 3):
 (H9)  Geometric decay is not necessary; the true criterion is convergence of the
       profile.                                                              [BOLD]
 (H10) The criterion is independent of the gate `τ ∈ (0,1)`: stability is a
       property of the profile, not of the measurement bar.                  [BOLD]
 (H11) On Zipf profiles there is a critical exponent, and it is exactly `1`.

Experimenter: H9 and H10 are the two directions of `ctxStable_iff_summable` (the
statement quantifies over an arbitrary interior gate, so gate-independence is a
corollary, recorded as `ctxStable_gate_independent`).  H11 is `zipf_phase_transition`,
proved by feeding the `p`-series criterion into the main theorem.

Analyst: the forward direction is the informative one.  If the budget `K` works at every
context length then `τ · headMass w n ≤ headMass w K` for all `n`, i.e. the partial sums
are *bounded* — for a positive series, boundedness is summability.  The knee is thus a
finite-sample probe of an infinite-series property, which explains why a two-point
measurement can be genuinely predictive and also why it can never certify an exact value
(cf. `exact_flatness_refuted`).

Critic: the hypothesis `0 < τ` is load-bearing (with `τ ≤ 0` every profile is trivially
stable with `K = 0`) and so is `τ < 1` (at `τ = 1` no truncation below the context length
ever passes, and stability fails for every profile).  Both are interior conditions
satisfied by the measured gate `0.98`.
-/

namespace AttentionBudget

open Finset Filter

/-! ## The summability criterion -/

/-- **H9/H10 — the summability criterion.**  A positive attention profile admits a
context-independent key budget at some (equivalently, every) interior gate exactly when
the profile is summable. -/
theorem ctxStable_iff_summable {w : ℕ → ℝ} (hw : ∀ i, 0 < w i) {τ : ℝ} (hτ0 : 0 < τ)
    (hτ1 : τ < 1) : CtxStable w τ ↔ Summable w := by
  constructor
  · rintro ⟨K, hK⟩
    by_contra hns
    have htend : Tendsto (fun n => headMass w n) atTop atTop :=
      (not_summable_iff_tendsto_nat_atTop_of_nonneg fun i => (hw i).le).mp hns
    obtain ⟨n, hn1, hn2⟩ :=
      ((htend.eventually_gt_atTop (headMass w K / τ)).and (eventually_ge_atTop 1)).exists
    have hpass : τ ≤ retained w n K :=
      le_trans (gate_le_retained_kstar hw (by omega) hτ1.le)
        (retained_mono hw n (hK n hn2))
    have hnpos : 0 < headMass w n := headMass_pos hw (by omega)
    rw [retained, le_div_iff₀ hnpos] at hpass
    have hle : headMass w (min K n) ≤ headMass w K := headMass_mono hw (min_le_left _ _)
    rw [div_lt_iff₀ hτ0] at hn1
    linarith
  · intro hsum
    have hS : ∀ m, headMass w m ≤ ∑' i, w i := fun m =>
      hsum.sum_le_tsum _ (fun i _ => (hw i).le)
    have h1 : headMass w 1 = w 0 := by simp [headMass]
    have hSpos : 0 < ∑' i, w i := lt_of_lt_of_le (hw 0) (h1 ▸ hS 1)
    have htend : Tendsto (fun m => headMass w m) atTop (nhds (∑' i, w i)) :=
      hsum.hasSum.tendsto_sum_nat
    have hlt : τ * (∑' i, w i) < ∑' i, w i := by nlinarith
    obtain ⟨k, hk⟩ := (htend.eventually_const_lt hlt).exists
    refine ⟨k, fun n hn => kstar_le_of_pass ?_⟩
    rcases le_or_gt n k with h | h
    · have hmin : min k n = n := min_eq_right h
      rw [retained, hmin, div_self (headMass_pos hw hn).ne']
      linarith
    · have hmin : min k n = k := min_eq_left h.le
      rw [retained, hmin, le_div_iff₀ (headMass_pos hw hn)]
      have : τ * headMass w n ≤ τ * (∑' i, w i) :=
        mul_le_mul_of_nonneg_left (hS n) hτ0.le
      linarith

/-- **Quantitative criterion.**  A budget `k` whose discarded tail mass is at most
`(1 - τ) * w 0` clears the gate at *every* context length.  This subsumes the geometric
estimate of cycle 1 and applies to any summable profile, in particular to supercritical
Zipf profiles. -/
theorem kstar_le_of_tail_small {w : ℕ → ℝ} (hw : ∀ i, 0 < w i) (hsum : Summable w) {τ : ℝ}
    {k : ℕ} (hk : 1 ≤ k) (htail : ∑' i, w (i + k) ≤ (1 - τ) * w 0) {n : ℕ} (hn : 1 ≤ n) :
    kstar w n τ ≤ k := by
  have hshift : Summable (fun i => w (i + k)) := (summable_nat_add_iff k).mpr hsum
  have hT0 : 0 ≤ ∑' i, w (i + k) := tsum_nonneg fun i => (hw (i + k)).le
  have hw0 : 0 < w 0 := hw 0
  have hτ1 : τ ≤ 1 := by nlinarith
  apply kstar_le_of_pass
  rcases le_or_gt n k with h | h
  · rw [retained, min_eq_right h, div_self (headMass_pos hw hn).ne']
    exact hτ1
  · have hmin : min k n = k := min_eq_left h.le
    have hA : w 0 ≤ headMass w k := by
      have h1 : headMass w 1 ≤ headMass w k := headMass_mono hw hk
      simpa [headMass] using h1
    have hkpos : 0 < headMass w k := headMass_pos hw (by omega)
    have hdiff : headMass w n - headMass w k ≤ ∑' i, w (i + k) := by
      have hrange : headMass w n - headMass w k = ∑ j ∈ Finset.range (n - k), w (j + k) := by
        have h1 : headMass w n - headMass w k = ∑ i ∈ Finset.Ico k n, w i := by
          rw [Finset.sum_Ico_eq_sub _ h.le]
          simp [headMass]
        rw [h1, Finset.sum_Ico_eq_sum_range]
        exact Finset.sum_congr rfl fun j _ => by rw [add_comm]
      rw [hrange]
      exact hshift.sum_le_tsum _ fun i _ => (hw (i + k)).le
    rw [retained, hmin, le_div_iff₀ (headMass_pos hw hn)]
    have hnpos : 0 < headMass w n := headMass_pos hw hn
    rcases le_or_gt 0 τ with hτ0 | hτ0
    · nlinarith [mul_le_mul_of_nonneg_left hdiff hτ0,
        mul_nonneg (sub_nonneg.mpr hτ1) hT0,
        mul_nonneg (sub_nonneg.mpr hτ1) (sub_nonneg.mpr hA)]
    · nlinarith

/-- Context stability does not depend on the gate: if a profile is stable at one
interior gate it is stable at all of them. -/
theorem ctxStable_gate_independent {w : ℕ → ℝ} (hw : ∀ i, 0 < w i) {τ σ : ℝ}
    (hτ0 : 0 < τ) (hτ1 : τ < 1) (hσ0 : 0 < σ) (hσ1 : σ < 1) (h : CtxStable w τ) :
    CtxStable w σ :=
  (ctxStable_iff_summable hw hσ0 hσ1).mpr ((ctxStable_iff_summable hw hτ0 hτ1).mp h)

/-! ## The Zipf phase transition -/

/-- The Zipf profile with exponent `s`. -/
noncomputable def zipf (s : ℝ) : ℕ → ℝ := fun i => 1 / ((i : ℝ) + 1) ^ s

lemma zipf_pos (s : ℝ) : ∀ i, 0 < zipf s i := by
  intro i
  have : (0 : ℝ) < (i : ℝ) + 1 := by positivity
  simp only [zipf]
  positivity

lemma summable_zipf_iff {s : ℝ} : Summable (zipf s) ↔ 1 < s := by
  have h2 := summable_nat_add_iff (f := fun m : ℕ => 1 / (m : ℝ) ^ s) 1
  simp only [Nat.cast_add, Nat.cast_one] at h2
  rw [Real.summable_one_div_nat_rpow] at h2
  exact h2

/-- **H11 — the Zipf phase transition.**  The attention budget of a Zipf profile is
context-stable exactly above the critical exponent `s = 1`: a bounded key budget for
`s > 1`, a budget growing without bound in the context length for `s ≤ 1`. -/
theorem zipf_phase_transition {s τ : ℝ} (hτ0 : 0 < τ) (hτ1 : τ < 1) :
    CtxStable (zipf s) τ ↔ 1 < s := by
  rw [ctxStable_iff_summable (zipf_pos s) hτ0 hτ1, summable_zipf_iff]

/-- Below (and at) the critical exponent no fixed key budget suffices: for every
candidate budget `K` some context length defeats it. -/
theorem zipf_budget_defeated {s τ : ℝ} (hs : s ≤ 1) (hτ0 : 0 < τ) (hτ1 : τ < 1) (K : ℕ) :
    ∃ n : ℕ, 1 ≤ n ∧ K < kstar (zipf s) n τ := by
  have hns : ¬ CtxStable (zipf s) τ := by
    rw [zipf_phase_transition hτ0 hτ1]
    exact not_lt.mpr hs
  by_contra hcon
  push_neg at hcon
  exact hns ⟨K, fun n hn => hcon n hn⟩

end AttentionBudget