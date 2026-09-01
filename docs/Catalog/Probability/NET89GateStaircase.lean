import Probability.NET89ParityGenericity

/-!
# NET-89, cycle 5: the gate staircase and the resolution limit of a reported knee

Cycle 4 showed that the one-key parity slack in the mixed knee is *generic*: for every
pair of positive profiles both ends of the bracket `{2K - 1, 2K}` are realised, the odd
end on a gate interval of positive length.  That refuted the hope of removing the slack,
and it left a quantitative successor question, posed as direction **D2** of the previous
cycle: *how precisely does a reported knee depend on the gate?*

This file answers it.  The gate-to-knee map `τ ↦ k*(w, n, τ)` is a **staircase** whose
step widths are exactly the individual normalised key masses

  `stepWidth w n k = w k / headMass w n`,

so the reported knee carries an intrinsic error bar:

* `retained_eq_sum_stepWidth` — the retained-mass curve is the partial-sum sequence of the
  step widths, and the widths sum to `1` over a full context (`sum_stepWidth_eq_one`).
* `knee_constant_on_step` / `knee_stability_radius` — the knee is *exactly* constant on the
  half-open interval between two consecutive retained values, giving each reported knee an
  explicit stability radius in gate units.
* `knee_unstable_at_step_edge` — and the radius is sharp: if the gate sits on a retained
  value, then *every* positive perturbation below one step width moves the knee by exactly
  one key.  Gate placement is therefore not a free parameter of the protocol.
* `mix_step_splits_pool_step` — under interleaving each pooled step splits into two mixed
  steps, one per domain, and in the balanced case
  (`balanced_mix_stepWidth_halves`) each mixed step is *exactly half* the pooled step.
* `net89_mixed_resolution_halves` and `net89_mixed_gate_flip` — hence the headline of this
  cycle: **the increment doubling of NET-89 is paid for by a halving of the gate
  resolution.**  A mixed measurement is exactly twice as sensitive to gate placement as
  the pure measurement it is compared against, and the flip is exhibited explicitly.

-- !-- Lab Notes -- !--
Hypothesizer (cycle 5, ranked):
 (H1) `τ ↦ k*` is a staircase whose steps are the normalised key masses, so every
      reported knee has an error bar of one key mass.                        [BOLD]
 (H2) The stability radius is sharp: at a step edge an arbitrarily small gate
      perturbation moves the knee.
 (H3) Interleaving splits each pooled step into one step per domain; balanced
      interleaving halves every step, so mixed measurements lose one bit of gate
      resolution per domain doubling.                                        [BOLD]
 (H4) Consequently the reported `+8` versus `+4` comparison is only meaningful if the
      gate is at least one mixed step away from any retained value — a testable
      precondition on the protocol, not on the model.

Experimenter: H1–H4 are all formalised below with zero sorries.  H2 is proved in the
strong "for every ε in the step" form, so the instability is not a limiting statement.

Analyst: the reason cycle 4's refutation is *not* bad news is visible here.  The parity
slack and the gate resolution are the same phenomenon seen twice: a mixed context has
twice as many, hence half as wide, staircase steps as the pooled context it refines, and
one extra step is exactly one parity unit.  "Rises at double the rate" and "resolves at
half the precision" are two readings of one identity, `mix_step_splits_pool_step`.

Critic: no theorem here is vacuous.  `stepWidth_pos` keeps every step of positive width,
`knee_unstable_at_step_edge` produces a genuine knee *change* rather than a bracket, and
`net89_mixed_gate_flip` is stated at an explicit gate with an explicit perturbation range.
-/

namespace Catalog.Probability.NET89MixedDomainKnee

open Finset AttentionBudget

variable {u v w : ℕ → ℝ} {τ : ℝ} {n k : ℕ}

/-! ## 1. Step widths -/

/-- The width, in gate units, of the `k`-th step of the knee staircase: the normalised
mass of the `k`-th key of a context of length `n`. -/
noncomputable def stepWidth (w : ℕ → ℝ) (n k : ℕ) : ℝ := w k / headMass w n

lemma stepWidth_pos (hw : ∀ i, 0 < w i) (hn : 0 < n) (k : ℕ) : 0 < stepWidth w n k :=
  div_pos (hw k) (headMass_pos hw hn)

/-- One step of the retained-mass curve costs exactly one normalised key mass. -/
lemma retained_succ (hk : k < n) :
    retained w n (k + 1) = retained w n k + stepWidth w n k := by
  have h1 : min (k + 1) n = k + 1 := by omega
  have h2 : min k n = k := by omega
  have hsucc : headMass w (k + 1) = headMass w k + w k := by
    simp [headMass, Finset.sum_range_succ]
  rw [retained, retained, stepWidth, h1, h2, hsucc]
  ring

/-- The retained-mass curve is the partial-sum sequence of the step widths. -/
lemma retained_eq_sum_stepWidth (hk : k ≤ n) :
    retained w n k = ∑ i ∈ range k, stepWidth w n i := by
  induction k with
  | zero => simp [retained, headMass]
  | succ m ih =>
      rw [Finset.sum_range_succ, ← ih (by omega), retained_succ (by omega)]

/-- The steps of a full context partition the whole gate range `[0, 1]`. -/
lemma sum_stepWidth_eq_one (hw : ∀ i, 0 < w i) (hn : 0 < n) :
    ∑ i ∈ range n, stepWidth w n i = 1 := by
  rw [← retained_eq_sum_stepWidth le_rfl, retained_self hw hn]

/-! ## 2. The staircase: exact local constancy of the knee in the gate -/

/-- **The step of the staircase.**  On the half-open gate interval
`(retained w n (k-1), retained w n k]` the knee is *identically* `k`. -/
theorem knee_constant_on_step (hw : ∀ i, 0 < w i) (hn : 0 < n) {m : ℕ}
    (hfail : retained w n m < τ) (hpass : τ ≤ retained w n (m + 1)) :
    kstar w n τ = m + 1 :=
  kstar_eq_of_fail_pass hw hn (le_trans hpass (retained_le_one hw n (m + 1) hn)) hfail hpass

/-- **The resolution limit of a reported knee.**  Write `K` for the measured knee at gate
`τ`.  Then every gate within the explicit radius
`min (τ - retained w n (K-1)) (retained w n K - τ)` of `τ` returns the *same* knee.  The
radius is computable from the two retained-mass values the experiment already records. -/
theorem knee_stability_radius (hw : ∀ i, 0 < w i) (hn : 0 < n)
    (hK : 1 ≤ kstar w n τ) (τ' : ℝ)
    (hclose : |τ' - τ| <
      min (τ - retained w n (kstar w n τ - 1)) (retained w n (kstar w n τ) - τ)) :
    kstar w n τ' = kstar w n τ := by
  set K := kstar w n τ with hKdef
  obtain ⟨hlo, hhi⟩ := abs_lt.mp hclose
  have h1 : min (τ - retained w n (K - 1)) (retained w n K - τ) ≤ τ - retained w n (K - 1) :=
    min_le_left _ _
  have h2 : min (τ - retained w n (K - 1)) (retained w n K - τ) ≤ retained w n K - τ :=
    min_le_right _ _
  have hfail : retained w n (K - 1) < τ' := by linarith
  have hpass : τ' ≤ retained w n K := by linarith
  have hsucc : K - 1 + 1 = K := by omega
  rw [knee_constant_on_step hw hn (m := K - 1) hfail (by rw [hsucc]; exact hpass), hsucc]

/-- **Sharpness of the resolution limit.**  If the gate sits exactly on a retained-mass
value — a step edge — then *every* perturbation up to one full step width moves the knee
by exactly one key.  So the stability radius of `knee_stability_radius` cannot be
enlarged, and a knee reported at a gate near a step edge is not a measurement of the
model but of the gate. -/
theorem knee_unstable_at_step_edge (hw : ∀ i, 0 < w i) (hk : 0 < k) (hkn : k < n)
    {ε : ℝ} (hε : 0 < ε) (hεw : ε ≤ stepWidth w n k) :
    kstar w n (retained w n k) = k ∧ kstar w n (retained w n k + ε) = k + 1 := by
  have hn : 0 < n := by omega
  constructor
  · have hfail : retained w n (k - 1) < retained w n k :=
      retained_lt_retained hw (by omega) (by omega)
    have hsucc : k - 1 + 1 = k := by omega
    rw [knee_constant_on_step hw hn (m := k - 1) hfail (by rw [hsucc]), hsucc]
  · refine knee_constant_on_step hw hn (m := k) (by linarith) ?_
    rw [retained_succ hkn]
    linarith

/-! ## 3. Interleaving splits every step -/

/-- **The splitting identity.**  A pooled step is the sum of the two mixed steps it
refines: interleaving does not create or destroy gate resolution, it *subdivides* it, one
sub-step per domain. -/
theorem mix_step_splits_pool_step (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) :
    stepWidth (pool 1 1 u v) n k =
      stepWidth (mix u v) (2 * n) (2 * k) + stepWidth (mix u v) (2 * n) (2 * k + 1) := by
  have h0 : mix u v (2 * k) = u k := by simp [mix, Nat.mul_mod_right]
  have h1 : mix u v (2 * k + 1) = v k := by
    have hmod : (2 * k + 1) % 2 = 1 := by omega
    have hdiv : (2 * k + 1) / 2 = k := by omega
    simp [mix, hmod, hdiv]
  have hMu : 0 < headMass u n := headMass_pos hu hn
  have hMv : 0 < headMass v n := headMass_pos hv hn
  rw [stepWidth, stepWidth, stepWidth, h0, h1, headMass_mix_even, headMass_pool, pool]
  field_simp

/-- Under **balanced** interleaving of a domain with itself, every mixed step is exactly
half of the pooled step it refines: one bit of gate resolution is lost. -/
theorem balanced_mix_stepWidth_halves (hu : ∀ i, 0 < u i) (hn : 0 < n) :
    stepWidth (mix u u) (2 * n) (2 * k) = stepWidth (pool 1 1 u u) n k / 2 ∧
      stepWidth (mix u u) (2 * n) (2 * k + 1) = stepWidth (pool 1 1 u u) n k / 2 := by
  have h0 : mix u u (2 * k) = u k := by simp [mix, Nat.mul_mod_right]
  have h1 : mix u u (2 * k + 1) = u k := by
    have hmod : (2 * k + 1) % 2 = 1 := by omega
    have hdiv : (2 * k + 1) / 2 = k := by omega
    simp [mix, hmod, hdiv]
  have hMu : 0 < headMass u n := headMass_pos hu hn
  refine ⟨?_, ?_⟩
  · rw [stepWidth, stepWidth, h0, headMass_mix_even, headMass_pool, pool]
    field_simp
    ring
  · rw [stepWidth, stepWidth, h1, headMass_mix_even, headMass_pool, pool]
    field_simp
    ring

/-- **The resolution is at least halved by mixing.**  For *any* two domains, one of the
two mixed sub-steps of a pooled step is at most half as wide as that pooled step.  The
finest gate distinction a mixed experiment can make is therefore at most half of what the
corresponding pure experiment can make. -/
theorem net89_mixed_resolution_halves (hu : ∀ i, 0 < u i) (hv : ∀ i, 0 < v i) (hn : 0 < n) :
    min (stepWidth (mix u v) (2 * n) (2 * k)) (stepWidth (mix u v) (2 * n) (2 * k + 1))
      ≤ stepWidth (pool 1 1 u v) n k / 2 := by
  have hsplit := mix_step_splits_pool_step (u := u) (v := v) (k := k) hu hv hn
  rcases le_total (stepWidth (mix u v) (2 * n) (2 * k))
      (stepWidth (mix u v) (2 * n) (2 * k + 1)) with h | h
  · rw [min_eq_left h]; linarith
  · rw [min_eq_right h]; linarith

/-- **The NET-89 gate flip.**  At the explicit gate `τ = retained (mix u u) (2n) (2k)` the
balanced mixed knee is `2k`, yet a perturbation of *half* a pooled step already pushes it
to `2k + 1`.  Together with the increment doubling of cycle 1 this says: the mixed protocol
rises twice as fast *and* resolves the gate twice as coarsely, and both facts come from the
same subdivision of the staircase. -/
theorem net89_mixed_gate_flip (hu : ∀ i, 0 < u i) (hk : 0 < k) (hkn : k < n)
    {ε : ℝ} (hε : 0 < ε) (hεw : ε ≤ stepWidth (pool 1 1 u u) n k / 2) :
    kstar (mix u u) (2 * n) (retained (mix u u) (2 * n) (2 * k)) = 2 * k ∧
      kstar (mix u u) (2 * n) (retained (mix u u) (2 * n) (2 * k) + ε) = 2 * k + 1 := by
  have hn : 0 < n := by omega
  have hmp : ∀ i, 0 < mix u u i := mix_pos hu hu
  have hhalf := (balanced_mix_stepWidth_halves (u := u) (n := n) (k := k) hu hn).1
  have hεm : ε ≤ stepWidth (mix u u) (2 * n) (2 * k) := by rw [hhalf]; exact hεw
  exact knee_unstable_at_step_edge hmp (by omega) (by omega) hε hεm

end Catalog.Probability.NET89MixedDomainKnee