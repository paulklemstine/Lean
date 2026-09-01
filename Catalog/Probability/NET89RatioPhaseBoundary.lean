import Probability.NET89MultiDomainResolution

/-!
# NET-89, cycle 9: the mixing-ratio sweep has a single phase boundary

Cycle 2 proved that under domination the pooled knee is *monotone* along a mixing-ratio
sweep, and cycle 6 proved that above an explicit mass-share threshold the pooled knee *is*
the dominant component's knee.  Direction **D3** asked whether these fit together into a
single crossing.  They do.

* `pool_knee_dominant_ratios_upward_closed` — the set of mixing ratios at which the pooled
  knee has already collapsed onto the dominant component's knee is **upward closed**: once
  the sweep reaches the dominant value it stays there.  So the sweep is a monotone staircase
  with one terminal plateau, not an oscillation.
* `exists_ratio_with_dominant_knee` — that plateau is **non-empty**: an explicit weight,
  computed from the two component head masses and the cycle-6 thresholds, already realises
  it.  Hence a genuine phase boundary exists, and it is a single crossing.
* `net89_ratio_sweep_phase_boundary` — the two statements combined, in the form a sweep
  experiment can falsify: below the boundary the knee may take any value in the sandwich,
  above it the knee is constant and equal to the dominant component's knee.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 9):
 (H1) The collapse region of a ratio sweep is upward closed (monotonicity + sandwich).
 (H2) It is non-empty, with an explicit witness weight computable from head masses and
      the cycle-6 thresholds.                                                 [BOLD]
 (H3) Hence the sweep has exactly one phase boundary — a kink, not a drift.   [BOLD]

Experimenter: H1–H3 formalised below, zero sorries.  The witness weight in H2 is
`T·Hv / ((1 − T)·Hu) + 1` with `T` the larger of the two cycle-6 thresholds.

Analyst: this is the sharpest available reply to the report's P1.  There is no formula for
the mixed knee in terms of the component knees (cycle 1), but there *is* a complete
qualitative description of the mixing-ratio sweep: monotone, sandwiched, and eventually
exactly equal to the dominant component's knee, with the transition at one identifiable
ratio.  A measured sweep that drifts rather than kinks refutes the domination hypothesis,
which is checkable curve by curve.

Critic: the upward-closure theorem uses domination, exactly as cycle 2 does, and the
existence theorem uses strict gate interiority, exactly as cycle 6 does; neither hypothesis
is hidden, and cycle 4's parity analysis shows what happens on the boundary itself.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ : ℝ} {n : ℕ}

/-! ## 1. The collapse region is upward closed -/

/-- **One-sided sweep.**  If the pooled knee has already collapsed onto the dominant
component's knee at some mixing ratio, it stays collapsed at every larger ratio: the
collapse region of a ratio sweep is an up-set. -/
theorem pool_knee_dominant_ratios_upward_closed (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k)
    {a₁ b₁ a₂ b₂ : ℝ} (ha₁ : 0 < a₁) (hb₁ : 0 < b₁) (ha₂ : 0 < a₂) (hb₂ : 0 < b₂)
    (hratio : a₂ * b₁ ≤ a₁ * b₂)
    (hcollapse : kstar (pool a₂ b₂ u v) n τ = kstar u n τ) :
    kstar (pool a₁ b₁ u v) n τ = kstar u n τ := by
  have hle : kstar (pool a₁ b₁ u v) n τ ≤ kstar (pool a₂ b₂ u v) n τ :=
    kstar_pool_ratio_mono hu hv hn hτ ha₁ hb₁ ha₂ hb₂ hdom hratio
  have hlow : min (kstar u n τ) (kstar v n τ) ≤ kstar (pool a₁ b₁ u v) n τ :=
    min_le_kstar_pool ha₁ hb₁ hu hv hn hτ
  have huv : kstar u n τ ≤ kstar v n τ := kstar_le_of_dominates hv hn hτ hdom
  rw [min_eq_left huv] at hlow
  omega

/-! ## 2. The collapse region is non-empty -/

/-- **The sweep always reaches the dominant knee.**  With the gate strictly interior to its
staircase step, an explicit finite weight already forces the pooled knee to equal the first
domain's knee.  The weight is computed from the two head masses and the cycle-6
thresholds. -/
theorem exists_ratio_with_dominant_knee (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ0 : 0 < τ) (hτ : τ ≤ 1) (hK : 1 ≤ kstar u n τ)
    (hstrict : τ < retained u n (kstar u n τ)) :
    ∃ a : ℝ, 0 < a ∧ kstar (pool a 1 u v) n τ = kstar u n τ := by
  set K := kstar u n τ with hKdef
  set T := max (τ / retained u n K) ((1 - τ) / (1 - retained u n (K - 1))) with hT
  have hT1 : T < 1 := mass_dominance_threshold_lt_one hu hn hτ hK hstrict
  have hKn : K ≤ n := kstar_le_context hu hn hτ
  have hRK : 0 < retained u n K :=
    div_pos (headMass_pos hu (by omega : 0 < min K n)) (headMass_pos hu hn)
  have hT0 : 0 < T := lt_of_lt_of_le (div_pos hτ0 hRK) (le_max_left _ _)
  have hU : 0 < headMass u n := headMass_pos hu hn
  have hV : 0 < headMass v n := headMass_pos hv hn
  have hden : 0 < (1 - T) * headMass u n := mul_pos (by linarith) hU
  have hfrac : 0 < T * headMass v n / ((1 - T) * headMass u n) :=
    div_pos (mul_pos hT0 hV) hden
  refine ⟨T * headMass v n / ((1 - T) * headMass u n) + 1, by linarith, ?_⟩
  set a := T * headMass v n / ((1 - T) * headMass u n) + 1 with ha
  have ha0 : 0 < a := by rw [ha]; linarith
  -- the mass share exceeds the threshold `T`
  have hbig : T * headMass v n / ((1 - T) * headMass u n) < a := by rw [ha]; linarith
  have hkey : T * headMass v n < a * ((1 - T) * headMass u n) := by
    rw [div_lt_iff₀ hden] at hbig
    linarith
  have hshare : T < massShare a 1 u v n := by
    rw [massShare, lt_div_iff₀ (by nlinarith : (0:ℝ) < a * headMass u n + 1 * headMass v n)]
    nlinarith
  refine pool_knee_eq_component_knee_of_dominance ha0 one_pos hu hv hn hτ hK ?_ ?_
  · exact le_trans (le_max_left _ _) hshare.le
  · exact lt_of_le_of_lt (le_max_right _ _) hshare

/-! ## 3. The phase boundary -/

/-- **The mixing-ratio sweep has a single phase boundary.**  There is a weight above which
the pooled knee is *identically* the dominant component's knee, and the property of being
at that value is preserved by every further increase of the weight.  A ratio sweep must
therefore show a kink followed by a plateau, never a drift — a falsifiable shape. -/
theorem net89_ratio_sweep_phase_boundary (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ0 : 0 < τ) (hτ : τ ≤ 1) (hK : 1 ≤ kstar u n τ)
    (hstrict : τ < retained u n (kstar u n τ))
    (hdom : ∀ k, retained v n k ≤ retained u n k) :
    ∃ a₀ : ℝ, 0 < a₀ ∧ ∀ a : ℝ, a₀ ≤ a → kstar (pool a 1 u v) n τ = kstar u n τ := by
  obtain ⟨a₀, ha₀, hcollapse⟩ :=
    exists_ratio_with_dominant_knee hu hv hn hτ0 hτ hK hstrict
  refine ⟨a₀, ha₀, fun a hle => ?_⟩
  have ha : 0 < a := lt_of_lt_of_le ha₀ hle
  exact pool_knee_dominant_ratios_upward_closed hu hv hn hτ hdom ha one_pos ha₀ one_pos
    (by linarith) hcollapse

end Catalog.Probability.NET89MixedDomainKnee