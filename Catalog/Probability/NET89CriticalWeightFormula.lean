import Probability.NET89CriticalWeight

/-!
# NET-89, cycle 15: the closed formula for the mixing-ratio critical weight

Cycle 14 defined the **critical weight** of a mixing-ratio sweep — the infimum of the set
of weights at which the pooled knee has already collapsed onto the dominant component's
knee — proved it is exactly the kink of the sweep, and computed it (`= 2`) for one explicit
profile pair.  What it did *not* give is a formula: an expression for the kink in terms of
quantities measurable on the two **pure** domains.  That was direction **D6**
("Closed Formula for the Mixing-Ratio Critical Weight").  This cycle closes it.

The formula.  Write `Hu`, `Hv` for the head masses of the two components, `K` for the
dominant component's knee at gate `τ` and context `n`.  Then the pass condition of the
pooled profile `pool a 1 u v` at budget `K` is *linear* in the weight `a`, so it is a
half-line, and its endpoint is

  `passWeight u v n τ K = (τ · Hv n − Hv K) / (Hu K − τ · Hu n)`,

four head masses of the two pure domains and nothing else.  The results:

* `pool_pass_iff_linear` — the pooled gate condition at a budget `k ≤ n` is exactly the
  linear inequality `τ (a·Hu n + Hv n) ≤ a·Hu K + Hv K`; no division survives.
* `pool_pass_iff_passWeight_le` — when the *dominant excess* `D = Hu K − τ·Hu n` is
  positive the condition is precisely `passWeight ≤ a`: the collapse region is a half-line
  with a computable endpoint.
* `dominant_knee_le_pool_knee` — under domination the pooled knee is never below the
  dominant knee, so collapse is equivalent to a single pass at budget `K`.
* `collapse_iff_passWeight_le` — collapse at weight `a` ⟺ `passWeight u v n τ K ≤ a`.
* `critWeight_eq_max_passWeight` — **the closed formula**:
  `critWeight u v n τ = max 0 (passWeight u v n τ (kstar u n τ))`.
  A mixing-ratio sweep therefore needs *no* mixed measurement: its kink is predicted by
  four pure-domain head masses.
* `net89_critical_weight_formula` — the headline, with the truncation at `0` made explicit:
  a non-degenerate boundary (`0 < critWeight`) occurs exactly when `Hv K < τ · Hv n`, i.e.
  exactly when the *weak* domain fails the gate at the dominant knee.
* `critWeight_uA_vFlat_by_formula` — the cycle-14 value `2` recomputed from the formula
  `(0.7·4 − 1)/(10 − 0.7·13) = 1.8/0.9 = 2`, an independent check of both cycles.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 15, ranked):
 (H1) The pooled pass condition at a fixed budget is linear in the mixing weight, hence the
      collapse region is a half-line and the critical weight is its endpoint.
 (H2) That endpoint is a ratio of four pure-domain head masses, so a ratio sweep is
      predictable without any mixed measurement.                                  [BOLD]
 (H3) The boundary is interior (`0 < critWeight`) iff the weak domain fails the gate at the
      dominant knee — the phase transition has a one-line experimental signature. [BOLD]
 (H4) The formula reproduces the cycle-14 computed value `2` exactly.

Experimenter: H1–H4 formalised below, zero sorries.  The one structural hypothesis is
positivity of the dominant excess `D = Hu K − τ·Hu n`; it is *not* automatic (it fails when
the dominant domain only barely clears its own gate) and it is discharged explicitly, by
`norm_num`, in the computed case (`D = 9/10`).

Analyst: the reason the sweep is predictable is that `retained (pool a 1 u v) n k` is a
linear-fractional (Möbius) function of `a` with positive denominator, so each gate condition
is a half-line and each budget contributes one kink.  What cycle 14 saw as a staircase with
kinks `8/19` and `2` is exactly `passWeight` evaluated at budgets `2` and `1`.  Nothing here
appeals to attention, only to the order structure of retained mass, which is why the formula
is testable against any measured sweep.

Critic: the formula is stated with `max 0` because the collapse region can be all of
`(0, ∞)`, in which case the infimum `0` is *not* attained and no positive kink exists; the
degenerate case is not swept under the rug but is characterised (`net89_critical_weight_formula`,
second component).  The concrete instance is a genuine arithmetic check against an
independently proved value, not a `decide`.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v : ℕ → ℝ} {τ a : ℝ} {n k : ℕ}

/-! ## 1. The pooled gate condition is linear in the mixing weight -/

/-- The **pass weight** of a budget `k`: the endpoint of the half-line of mixing weights at
which the pooled profile clears the gate at budget `k`.  It is built from four head masses
of the two *pure* domains. -/
noncomputable def passWeight (u v : ℕ → ℝ) (n : ℕ) (τ : ℝ) (k : ℕ) : ℝ :=
  (τ * headMass v n - headMass v k) / (headMass u k - τ * headMass u n)

/-- The pooled gate condition at a budget below the context length, cleared of division. -/
lemma pool_pass_iff_linear (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) (hkn : k ≤ n)
    (ha : 0 < a) :
    τ ≤ retained (pool a 1 u v) n k ↔
      τ * (a * headMass u n + headMass v n) ≤ a * headMass u k + headMass v k := by
  have hun : 0 < headMass u n := headMass_pos hu hn
  have hvn : 0 < headMass v n := headMass_pos hv hn
  have hden : 0 < a * headMass u n + headMass v n := by positivity
  rw [retained, min_eq_left hkn, headMass_pool, headMass_pool, le_div_iff₀ (by simpa using hden)]
  constructor <;> intro h <;> linarith

/-- **The collapse condition at a fixed budget is a half-line.**  If the dominant excess
`Hu k − τ·Hu n` is positive, the pooled profile clears the gate at budget `k` exactly for
weights at or above `passWeight u v n τ k`. -/
lemma pool_pass_iff_passWeight_le (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hkn : k ≤ n) (ha : 0 < a) (hD : 0 < headMass u k - τ * headMass u n) :
    τ ≤ retained (pool a 1 u v) n k ↔ passWeight u v n τ k ≤ a := by
  rw [pool_pass_iff_linear hu hv hn hkn ha, passWeight, div_le_iff₀ hD]
  constructor <;> intro h <;> nlinarith

/-! ## 2. Collapse is a single pass at the dominant knee -/

/-- Under domination the pooled knee never drops below the dominant component's knee. -/
lemma dominant_knee_le_pool_knee (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k) (ha : 0 < a) :
    kstar u n τ ≤ kstar (pool a 1 u v) n τ := by
  have hlow : min (kstar u n τ) (kstar v n τ) ≤ kstar (pool a 1 u v) n τ :=
    min_le_kstar_pool ha one_pos hu hv hn hτ
  have huv : kstar u n τ ≤ kstar v n τ := kstar_le_of_dominates hv hn hτ hdom
  rwa [min_eq_left huv] at hlow

/-- **Collapse, characterised by the formula.**  For a positive weight the pooled knee equals
the dominant component's knee exactly when the weight is at least the pass weight of that
knee. -/
theorem collapse_iff_passWeight_le (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k) (ha : 0 < a)
    (hD : 0 < headMass u (kstar u n τ) - τ * headMass u n) :
    kstar (pool a 1 u v) n τ = kstar u n τ ↔ passWeight u v n τ (kstar u n τ) ≤ a := by
  have hKn : kstar u n τ ≤ n := kstar_le_context hu hn hτ
  have hiff := pool_pass_iff_passWeight_le (k := kstar u n τ) hu hv hn hKn ha hD
  constructor
  · intro hcol
    refine hiff.mp ?_
    have := gate_le_retained_kstar (w := pool a 1 u v) (pool_pos ha one_pos hu hv) hn hτ
    rwa [hcol] at this
  · intro hle
    have hpass : τ ≤ retained (pool a 1 u v) n (kstar u n τ) := hiff.mpr hle
    exact le_antisymm (kstar_le_of_pass hpass) (dominant_knee_le_pool_knee hu hv hn hτ hdom ha)

/-! ## 3. The closed formula for the critical weight -/

/-- **The closed formula.**  The critical weight of a mixing-ratio sweep — the kink at which
the pooled knee collapses onto the dominant component's knee — is
`max 0 ((τ·Hv n − Hv K)/(Hu K − τ·Hu n))` with `K` the dominant knee: four head masses of the
two *pure* domains.  No mixed measurement is needed to predict the kink of a sweep. -/
theorem critWeight_eq_max_passWeight (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k)
    (hD : 0 < headMass u (kstar u n τ) - τ * headMass u n) :
    critWeight u v n τ = max 0 (passWeight u v n τ (kstar u n τ)) := by
  set c := passWeight u v n τ (kstar u n τ) with hc
  have hmem : ∀ b : ℝ, 0 < b → c ≤ b → b ∈ collapseSet u v n τ := fun b hb hcb =>
    ⟨hb, (collapse_iff_passWeight_le hu hv hn hτ hdom hb hD).mpr hcb⟩
  have hne : (collapseSet u v n τ).Nonempty :=
    ⟨max 1 c, hmem _ (lt_of_lt_of_le one_pos (le_max_left _ _)) (le_max_right _ _)⟩
  refine le_antisymm ?_ ?_
  · rcases le_or_gt c 0 with hc0 | hc0
    · rw [max_eq_left hc0]
      by_contra hlt
      push_neg at hlt
      have h2 : critWeight u v n τ / 2 ∈ collapseSet u v n τ :=
        hmem _ (by linarith) (by linarith)
      have := critWeight_le_of_mem h2
      linarith
    · exact le_trans (critWeight_le_of_mem (hmem c hc0 le_rfl)) (le_max_right _ _)
  · refine le_csInf hne fun b hb => ?_
    exact max_le hb.1.le
      ((collapse_iff_passWeight_le hu hv hn hτ hdom hb.1 hD).mp hb.2)

/-- **The experimental signature of an interior boundary.**  The kink is at a strictly
positive weight exactly when the weak domain fails the gate at the dominant knee; otherwise
the sweep has collapsed at every positive weight and the critical weight is `0`. -/
theorem net89_critical_weight_formula (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n)
    (hτ : τ ≤ 1) (hdom : ∀ k, retained v n k ≤ retained u n k)
    (hD : 0 < headMass u (kstar u n τ) - τ * headMass u n) :
    critWeight u v n τ =
        max 0 ((τ * headMass v n - headMass v (kstar u n τ)) /
          (headMass u (kstar u n τ) - τ * headMass u n)) ∧
      (0 < critWeight u v n τ ↔ headMass v (kstar u n τ) < τ * headMass v n) := by
  have hform := critWeight_eq_max_passWeight hu hv hn hτ hdom hD
  refine ⟨hform, ?_⟩
  rw [hform, passWeight]
  constructor
  · intro hpos
    by_contra hcon
    push_neg at hcon
    have : (τ * headMass v n - headMass v (kstar u n τ)) /
        (headMass u (kstar u n τ) - τ * headMass u n) ≤ 0 :=
      div_nonpos_of_nonpos_of_nonneg (by linarith) hD.le
    rw [max_eq_left this] at hpos
    exact lt_irrefl 0 hpos
  · intro hlt
    have : 0 < (τ * headMass v n - headMass v (kstar u n τ)) /
        (headMass u (kstar u n τ) - τ * headMass u n) := div_pos (by linarith) hD
    exact lt_of_lt_of_le this (le_max_right _ _)

/-! ## 4. The formula against the computed case -/

/-- The head-heavy domain dominates the flat one at every budget of the cycle-1 protocol. -/
lemma retained_vFlat_le_uA (k : ℕ) : retained vFlat 4 k ≤ retained uA 4 k := by
  rcases le_or_gt 4 k with hk | hk
  · have hmin : min k 4 = 4 := by omega
    rw [retained, retained, hmin, div_self (headMass_pos vFlat_pos (by norm_num)).ne',
      div_self (headMass_pos uA_pos (by norm_num)).ne']
  · interval_cases k <;>
      norm_num [retained, headMass, uA, vFlat, Finset.sum_range_succ]

/-- **The formula reproduces the computed kink.**  For the cycle-1 witness pair the closed
formula gives `(7/10 · 4 − 1)/(10 − 7/10 · 13) = (9/5)/(9/10) = 2`, matching the critical
weight computed independently in cycle 14 by a three-case sweep. -/
theorem critWeight_uA_vFlat_by_formula :
    passWeight uA vFlat 4 (7 / 10) (kstar uA 4 (7 / 10)) = 2 ∧
      critWeight uA vFlat 4 (7 / 10) =
        max 0 (passWeight uA vFlat 4 (7 / 10) (kstar uA 4 (7 / 10))) := by
  have hD : 0 < headMass uA (kstar uA 4 (7 / 10)) - (7 / 10 : ℝ) * headMass uA 4 := by
    rw [kstar_uA]
    norm_num [headMass, uA, Finset.sum_range_succ]
  refine ⟨?_, critWeight_eq_max_passWeight uA_pos vFlat_pos (by norm_num) (by norm_num)
    retained_vFlat_le_uA hD⟩
  rw [passWeight, kstar_uA]
  norm_num [headMass, uA, vFlat, Finset.sum_range_succ]

/-- **The sweep's earlier kink, from the same formula.**  Cycle 14's staircase kinks at
`8/19` and `2`; the closed formula evaluated at the intermediate budget `2` returns `8/19`,
so both kinks of the sweep are pure-domain predictions. -/
theorem passWeight_uA_vFlat_at_two : passWeight uA vFlat 4 (7 / 10) 2 = 8 / 19 := by
  rw [passWeight]
  norm_num [headMass, uA, vFlat, Finset.sum_range_succ]

end Catalog.Probability.NET89MixedDomainKnee