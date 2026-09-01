import Probability.NET89GateStaircase

/-!
# NET-89, cycle 6: mass-share rigidity — when a mixture *is* one of its components

Cycle 1 refuted the midpoint prediction P1 in the strongest possible way: three profile
pairs with identical component knees realise the min, the midpoint and the max of the
mediant sandwich, so no formula in the component knees can exist
(`no_component_knee_formula`).  That is a purely negative result, and it left direction
**D1**: the witnesses that reach the ends of the sandwich all have wildly asymmetric total
mass, which suggests the position inside the sandwich is governed by a *single scalar*,
the mass share of the two domains.

This cycle proves that suggestion, and proves more than was conjectured.

* `retained_pool_convex` — the exact identity behind the mediant sandwich: the pooled
  retained-mass curve is the **convex combination**, with weight the mass share
  `massShare`, of the two component curves.  The sandwich of cycle 1 is the corollary that
  a convex combination lies between its endpoints; everything below uses the identity.
* `kstar_pool_le_kstar_gate_up` and `kstar_gate_down_le_kstar_pool` — the pooled knee is
  the *dominant component's own knee read at two shifted gates*, `τ/λ` and
  `(τ - (1-λ))/λ`.  The width of the gate window is exactly `(1-λ)/λ`, the reciprocal mass
  ratio, so it shrinks to zero as one domain takes over the mass.
* `pool_knee_eq_component_knee_of_gate_window` — **the rigidity theorem.**  If the shifted
  gate window fits inside one staircase step of the dominant profile (the steps of cycle
  5), then the pooled knee is *exactly* the dominant component knee.  Mixing is then
  invisible: `k*_mix = k*_code`, with no error term.
* `pool_knee_eq_component_knee_of_dominance` — the same conclusion from a bare lower bound
  on the mass share, and `mass_dominance_threshold_lt_one` shows that bound is achievable:
  whenever the gate is strictly interior to its step the threshold share is `< 1`.
* `net89_mixed_starts_at_code_level` — the verdict "the mixed domain **starts at code's
  level**" formalised: under mass dominance the interleaved knee at context `2n` is
  `2·k*_code(n)` up to the (provably irremovable, cycle 4) one-key parity slack.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 6, ranked):
 (H1) The mediant sandwich is a shadow of an exact convex-combination identity with
      weight the mass share.                                                  [BOLD]
 (H2) Consequently the pooled knee is a component knee at a shifted gate, with shift
      exactly the reciprocal mass ratio.
 (H3) Rigidity: once the shift is smaller than one staircase step, the mixture knee
      equals the dominant component knee exactly — P1 fails, but a *mass-weighted*
      law holds with an explicit validity region.                             [BOLD]
 (H4) The threshold mass share is `< 1` under strict gate interiority, so H3 is
      always achievable and never vacuous.

Experimenter: H1–H4 formalised below, zero sorries.  The gate-window hypotheses of the
rigidity theorem are discharged from a bare inequality on the mass share in
`pool_knee_eq_component_knee_of_dominance`.

Analyst: the cycle-1 refutation and the cycle-6 rigidity are consistent because the
cycle-1 witnesses violate exactly the interiority hypothesis: they place the gate at a
mass ratio where the two shifted gates straddle a step edge.  The correct reading of
NET-89's P1 is therefore not "the midpoint law is false" but "the midpoint law is the
wrong invariant: the mass share, not the knee positions, controls the mixture."

Critic: `mass_dominance_threshold_lt_one` is what keeps the rigidity theorem from being
vacuous, and it is proved from strict interiority alone — a condition the reported
protocol can check from the retained-mass table it already records.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v w : ℕ → ℝ} {a b τ : ℝ} {n k : ℕ}

/-! ## 1. The mass share and the convex-combination identity -/

/-- The **mass share** of the first domain in a pooled context: the fraction of the total
attention mass of a context of length `n` contributed by the first domain. -/
noncomputable def massShare (a b : ℝ) (u v : ℕ → ℝ) (n : ℕ) : ℝ :=
  a * headMass u n / (a * headMass u n + b * headMass v n)

lemma massShare_pos (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) : 0 < massShare a b u v n := by
  have hU := headMass_pos hu hn
  have hV := headMass_pos hv hn
  exact div_pos (by positivity) (by positivity)

lemma massShare_lt_one (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) : massShare a b u v n < 1 := by
  have hU := headMass_pos hu hn
  have hV := headMass_pos hv hn
  rw [massShare, div_lt_one (by positivity)]
  nlinarith

lemma one_sub_massShare (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) :
    1 - massShare a b u v n = b * headMass v n / (a * headMass u n + b * headMass v n) := by
  have hU := headMass_pos hu hn
  have hV := headMass_pos hv hn
  have hD : a * headMass u n + b * headMass v n ≠ 0 := by positivity
  rw [massShare]
  field_simp
  ring

/-- **The convex-combination identity.**  Pooling two domains averages their retained-mass
curves with weight the mass share.  This is the exact form of the mediant sandwich of
cycle 1. -/
theorem retained_pool_convex (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i)
    (hv : ∀ i, 0 < v i) (hn : 0 < n) (k : ℕ) :
    retained (pool a b u v) n k =
      massShare a b u v n * retained u n k + (1 - massShare a b u v n) * retained v n k := by
  have hU := headMass_pos hu hn
  have hV := headMass_pos hv hn
  have hD : a * headMass u n + b * headMass v n ≠ 0 := by positivity
  rw [one_sub_massShare ha hb hu hv hn, massShare, retained, retained, retained,
    headMass_pool, headMass_pool]
  field_simp

/-! ## 2. The pooled knee is a component knee at two shifted gates -/

/-- Reading the dominant component at the **raised** gate `τ/λ` over-estimates the pooled
knee: the second domain's mass can only help. -/
theorem kstar_pool_le_kstar_gate_up (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i)
    (hv : ∀ i, 0 < v i) (hn : 0 < n) (hup : τ / massShare a b u v n ≤ 1) :
    kstar (pool a b u v) n τ ≤ kstar u n (τ / massShare a b u v n) := by
  have hL0 := massShare_pos ha hb hu hv hn
  have hL1 := massShare_lt_one ha hb hu hv hn
  set L := massShare a b u v n with hL
  set K := kstar u n (τ / L) with hK
  have hpassu : τ / L ≤ retained u n K := gate_le_retained_kstar hu hn hup
  rw [div_le_iff₀ hL0] at hpassu
  refine kstar_le_of_pass ?_
  rw [retained_pool_convex ha hb hu hv hn]
  have h2 : 0 ≤ (1 - L) * retained v n K :=
    mul_nonneg (by linarith) (retained_nonneg hv n K)
  nlinarith

/-- Reading the dominant component at the **lowered** gate `(τ - (1-λ))/λ` under-estimates
the pooled knee: the second domain contributes at most all of its mass. -/
theorem kstar_gate_down_le_kstar_pool (ha : 0 < a) (hb : 0 < b) (hu : ∀ i, 0 < u i)
    (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1) :
    kstar u n ((τ - (1 - massShare a b u v n)) / massShare a b u v n)
      ≤ kstar (pool a b u v) n τ := by
  have hL0 := massShare_pos ha hb hu hv hn
  have hL1 := massShare_lt_one ha hb hu hv hn
  set L := massShare a b u v n with hL
  set M := kstar (pool a b u v) n τ with hM
  have hpp : ∀ i, 0 < pool a b u v i := pool_pos ha hb hu hv
  have hpass : τ ≤ retained (pool a b u v) n M := gate_le_retained_kstar hpp hn hτ
  rw [retained_pool_convex ha hb hu hv hn] at hpass
  have hv1 : retained v n M ≤ 1 := retained_le_one hv n M hn
  have hprod : (1 - L) * retained v n M ≤ (1 - L) * 1 :=
    mul_le_mul_of_nonneg_left hv1 (by linarith)
  refine kstar_le_of_pass ?_
  rw [div_le_iff₀ hL0]
  nlinarith

/-! ## 3. Rigidity: a dominant domain dictates the mixture knee exactly -/

/-- The budget just below the knee genuinely fails the gate. -/
lemma retained_pred_kstar_lt (hK : 1 ≤ kstar w n τ) :
    retained w n (kstar w n τ - 1) < τ := by
  by_contra hcon
  push_neg at hcon
  have := kstar_le_of_pass hcon
  omega

/-- **Mass-share rigidity.**  If the two shifted gates `(τ - (1-λ))/λ` and `τ/λ` fall
inside one and the same staircase step of the dominant profile, then the pooled knee is
*exactly* the dominant component's knee: mixing leaves no trace at all. -/
theorem pool_knee_eq_component_knee_of_gate_window (ha : 0 < a) (hb : 0 < b)
    (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1)
    (hK : 1 ≤ kstar u n τ)
    (hupper : τ / massShare a b u v n ≤ retained u n (kstar u n τ))
    (hlower : retained u n (kstar u n τ - 1) <
      (τ - (1 - massShare a b u v n)) / massShare a b u v n) :
    kstar (pool a b u v) n τ = kstar u n τ := by
  have hL0 := massShare_pos ha hb hu hv hn
  have hL1 := massShare_lt_one ha hb hu hv hn
  set L := massShare a b u v n with hL
  set K := kstar u n τ with hKdef
  have hsucc : K - 1 + 1 = K := by omega
  have hmono : (τ - (1 - L)) / L ≤ τ / L :=
    div_le_div_of_nonneg_right (by linarith) hL0.le
  have hup : kstar u n (τ / L) = K := by
    have hfail : retained u n (K - 1) < τ / L := lt_of_lt_of_le hlower hmono
    rw [knee_constant_on_step hu hn (m := K - 1) hfail (by rw [hsucc]; exact hupper), hsucc]
  have hdown : kstar u n ((τ - (1 - L)) / L) = K := by
    have hpass : (τ - (1 - L)) / L ≤ retained u n K := le_trans hmono hupper
    rw [knee_constant_on_step hu hn (m := K - 1) hlower (by rw [hsucc]; exact hpass), hsucc]
  have h1 := kstar_pool_le_kstar_gate_up ha hb hu hv hn
    (le_trans hupper (retained_le_one hu n K hn))
  have h2 := kstar_gate_down_le_kstar_pool (τ := τ) ha hb hu hv hn hτ
  rw [hup] at h1
  rw [hdown] at h2
  omega

/-- The same rigidity from a bare **lower bound on the mass share**: once the first domain
carries a large enough fraction of the attention mass, the pooled knee collapses onto its
own knee.  The two thresholds are computed from the retained-mass table alone. -/
theorem pool_knee_eq_component_knee_of_dominance (ha : 0 < a) (hb : 0 < b)
    (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hτ : τ ≤ 1)
    (hK : 1 ≤ kstar u n τ)
    (h1 : τ / retained u n (kstar u n τ) ≤ massShare a b u v n)
    (h2 : (1 - τ) / (1 - retained u n (kstar u n τ - 1)) < massShare a b u v n) :
    kstar (pool a b u v) n τ = kstar u n τ := by
  have hL0 := massShare_pos ha hb hu hv hn
  have hL1 := massShare_lt_one ha hb hu hv hn
  set L := massShare a b u v n with hL
  set K := kstar u n τ with hKdef
  have hKn : K ≤ n := kstar_le_context hu hn hτ
  have hRK : 0 < retained u n K :=
    div_pos (headMass_pos hu (by omega : 0 < min K n)) (headMass_pos hu hn)
  have hRpred : retained u n (K - 1) < 1 := retained_lt_one hu (by omega)
  rw [div_le_iff₀ hRK] at h1
  rw [div_lt_iff₀ (by linarith)] at h2
  refine pool_knee_eq_component_knee_of_gate_window ha hb hu hv hn hτ hK ?_ ?_
  · rw [div_le_iff₀ hL0]
    nlinarith
  · rw [lt_div_iff₀ hL0]
    nlinarith

/-- **The rigidity hypothesis is achievable.**  If the gate is strictly interior to its
staircase step, the mass share required by `pool_knee_eq_component_knee_of_dominance` is
strictly below `1`, so a sufficiently mass-dominant domain always dictates the knee. -/
theorem mass_dominance_threshold_lt_one (hu : ∀ i, 0 < u i) (hn : 0 < n) (hτ : τ ≤ 1)
    (hK : 1 ≤ kstar u n τ) (hstrict : τ < retained u n (kstar u n τ)) :
    max (τ / retained u n (kstar u n τ))
        ((1 - τ) / (1 - retained u n (kstar u n τ - 1))) < 1 := by
  set K := kstar u n τ with hKdef
  have hKn : K ≤ n := kstar_le_context hu hn hτ
  have hRK : 0 < retained u n K :=
    div_pos (headMass_pos hu (by omega : 0 < min K n)) (headMass_pos hu hn)
  have hRpred : retained u n (K - 1) < 1 := retained_lt_one hu (by omega)
  have hfail : retained u n (K - 1) < τ := retained_pred_kstar_lt hK
  refine max_lt ?_ ?_
  · rw [div_lt_one hRK]; exact hstrict
  · rw [div_lt_one (by linarith)]; linarith

/-! ## 4. A concrete certificate that the hypotheses are met -/

lemma massShare_uB_vFlat : massShare 1 1 uB vFlat 4 = 103 / 107 := by
  norm_num [massShare, headMass, uB, vFlat, Finset.sum_range_succ]

lemma retained_uB_one : retained uB 4 1 = 100 / 103 := by
  norm_num [retained, headMass, uB, Finset.sum_range_succ]

lemma retained_uB_zero : retained uB 4 0 = 0 := by
  norm_num [retained, headMass]

/-- **Non-vacuity.**  The head-heavy witness `uB` of cycle 1, pooled with the gapless
`vFlat`, satisfies both mass-share thresholds at the gate `7/10`, and the rigidity theorem
then predicts the pooled knee to be `1` — which is exactly the value computed
independently in cycle 1 (`kstar_poolB`).  The hypotheses of
`pool_knee_eq_component_knee_of_dominance` are therefore satisfiable, and its prediction
is confirmed against a previously computed value. -/
theorem dominance_hypotheses_realised :
    (7 / 10 : ℝ) / retained uB 4 (kstar uB 4 (7 / 10)) ≤ massShare 1 1 uB vFlat 4 ∧
      (1 - 7 / 10 : ℝ) / (1 - retained uB 4 (kstar uB 4 (7 / 10) - 1)) <
        massShare 1 1 uB vFlat 4 ∧
      kstar (pool 1 1 uB vFlat) 4 (7 / 10) = kstar uB 4 (7 / 10) := by
  have hK : kstar uB 4 (7 / 10) = 1 := kstar_uB
  have h1 : (7 / 10 : ℝ) / retained uB 4 (kstar uB 4 (7 / 10)) ≤ massShare 1 1 uB vFlat 4 := by
    rw [hK, retained_uB_one, massShare_uB_vFlat]; norm_num
  have h2 : (1 - 7 / 10 : ℝ) / (1 - retained uB 4 (kstar uB 4 (7 / 10) - 1)) <
      massShare 1 1 uB vFlat 4 := by
    rw [hK, massShare_uB_vFlat]
    norm_num [retained_uB_zero]
  exact ⟨h1, h2, pool_knee_eq_component_knee_of_dominance one_pos one_pos uB_pos vFlat_pos
    (by norm_num) (by norm_num) (by rw [hK]) h1 h2⟩

/-! ## 5. "Starts at code's level", formalised -/

/-- **The NET-89 verdict, first half.**  When one domain (the report's Python code)
dominates the attention mass, the interleaved knee at the doubled context is exactly twice
that domain's own knee, up to the one-key parity slack shown in cycle 4 to be
irremovable.  The mixed measurement therefore *starts at code's level* not by coincidence
but because code carries the mass. -/
theorem net89_mixed_starts_at_code_level (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i)
    (hn : 0 < n) (hτ : τ ≤ 1) (hK : 1 ≤ kstar u n τ)
    (h1 : τ / retained u n (kstar u n τ) ≤ massShare 1 1 u v n)
    (h2 : (1 - τ) / (1 - retained u n (kstar u n τ - 1)) < massShare 1 1 u v n) :
    2 * kstar u n τ ≤ kstar (mix u v) (2 * n) τ + 1 ∧
      kstar (mix u v) (2 * n) τ ≤ 2 * kstar u n τ := by
  have hrig : kstar (pool 1 1 u v) n τ = kstar u n τ :=
    pool_knee_eq_component_knee_of_dominance one_pos one_pos hu hv hn hτ hK h1 h2
  have hbr := kstar_mix_bracket hu hv hn hτ
  rw [hrig] at hbr
  exact hbr

end Catalog.Probability.NET89MixedDomainKnee