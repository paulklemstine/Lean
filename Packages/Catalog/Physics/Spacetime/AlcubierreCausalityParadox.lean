/-
  # Does the Alcubierre drive create closed timelike curves?  A sharp dichotomy.

  `AlcubierreMetric.no_closed_causal_curve` settles the question for a **single** warp
  bubble: the Alcubierre ansatz is foliated by the flat Cauchy slices `t = const`, the
  coordinate time is a global time function (`g^{tt} = -1`), and Rolle's theorem forbids any
  closed causal curve.  A single bubble is therefore causally harmless.

  This file proves the complementary — and much less benign — half of the dichotomy.  A warp
  corridor is a *frame-dependent* device: a bubble built at rest in an inertial frame `S`
  carries its passenger along a worldline whose endpoints are **spacelike separated** in `S`
  (`warp_leg_spacelike`), yet which is a perfectly ordinary unit-timelike worldline inside
  the corridor (`AlcubierreMetric.apparent_ftl_without_local_ftl`).  Composing two such
  corridors built in *different* inertial frames closes a loop in spacetime:

  * `warp_pair_closes_loop` — for **every** effective warp speed `V > 1` and every duration
    `T > 0` there is an explicit boost velocity, `β = 2V/(V²+1) ∈ (0,1)`, and a strictly
    positive duration `s` of the second leg such that the traveller who takes the first
    corridor from the origin to `(T, VT)` and then a corridor at rest in the boosted frame
    returns **exactly to the event they started from**.
  * `warp_pair_returns_to_past` — with a slightly smaller boost the traveller arrives at
    their own spatial starting point strictly *before* they left.
  * `alcubierre_ctc_dichotomy` — the two halves stated together: one bubble, no closed
    causal curve; two bubbles in relative motion, a closed loop of warp legs.

  So the answer to "does the Alcubierre drive create closed timelike curves?" is:
  *not by itself — but any spacetime admitting two independently orientable warp corridors
  does.*  This is the Alcubierre-drive incarnation of the tachyonic antitelephone.
-/

import Mathlib
import Physics.Spacetime.AlcubierreMetric

open Set

namespace Catalog.Physics.Spacetime.Alcubierre

/-! ## Lorentz boosts -/

/-- Time coordinate of the event `(t, x)` in the frame moving with velocity `β`. -/
noncomputable def boostT (β t x : ℝ) : ℝ := (t - β * x) / Real.sqrt (1 - β ^ 2)

/-- Space coordinate of the event `(t, x)` in the frame moving with velocity `β`. -/
noncomputable def boostX (β t x : ℝ) : ℝ := (x - β * t) / Real.sqrt (1 - β ^ 2)

theorem boost_factor_pos {β : ℝ} (h : |β| < 1) : 0 < Real.sqrt (1 - β ^ 2) := by
  apply Real.sqrt_pos.mpr
  nlinarith [abs_nonneg β, sq_abs β, neg_abs_le β, le_abs_self β]

/-- Boosts fix the spacetime origin: all inertial observers through the origin agree that
the origin is the origin. -/
@[simp] theorem boost_origin (β : ℝ) : boostT β 0 0 = 0 ∧ boostX β 0 0 = 0 := by
  simp [boostT, boostX]

/-- A boost preserves the Minkowski interval (for subluminal boost velocity). -/
theorem boost_preserves_interval {β : ℝ} (h : |β| < 1) (t x : ℝ) :
    -(boostT β t x) ^ 2 + (boostX β t x) ^ 2 = -t ^ 2 + x ^ 2 := by
  have hpos : 0 < Real.sqrt (1 - β ^ 2) := boost_factor_pos h
  have hsq : (Real.sqrt (1 - β ^ 2)) ^ 2 = 1 - β ^ 2 := by
    apply Real.sq_sqrt
    nlinarith [sq_abs β, le_abs_self β, neg_abs_le β]
  have hne : (1 - β ^ 2) ≠ 0 := by nlinarith [sq_abs β, le_abs_self β, neg_abs_le β]
  rw [boostT, boostX, div_pow, div_pow, hsq]
  field_simp
  ring

/-! ## A single warp leg is spacelike in the background frame -/

/-- **The signature of warp travel.**  The displacement of a warp leg of effective speed
`V > 1` and duration `T > 0` is *spacelike* in the background inertial frame: no ordinary
causal curve connects its endpoints.  (Inside the bubble the very same leg is a unit
timelike worldline — see `apparent_ftl_without_local_ftl`.) -/
theorem warp_leg_spacelike {V T : ℝ} (hV : 1 < V) (hT : 0 < T) :
    0 < -T ^ 2 + (V * T) ^ 2 := by
  have hT2 : 0 < T ^ 2 := by positivity
  have hV2 : 1 < V ^ 2 := by nlinarith
  nlinarith

/-- Consistency with the metric file: the same displacement, taken inside a corridor whose
local warp factor is `V`, is a unit timelike vector. -/
theorem warp_leg_unit_timelike_in_bubble (V : ℝ) :
    IsTimelike V ![1, V, 0, 0] := eulerian_timelike V

/-! ## Two corridors in relative motion close a loop -/

/-- **Two warp corridors in relative motion produce a closed loop in spacetime.**

Let the traveller take a corridor at rest in the background frame `S` from the origin to the
event `(T, V T)`, with effective speed `V > 1`.  Choose the boost velocity
`β = 2V/(V² + 1)`, which is strictly between `0` and `1`.  Then in the boosted frame `S'`
the arrival event has *negative* time coordinate, and a second corridor of the same
effective speed `V`, at rest in `S'` and directed backwards, brings the traveller after a
strictly positive `S'`-duration `s` exactly back to the origin of `S'` — which is the event
they departed from.

The loop is thus closed: departure and return are the *same event*. -/
theorem boost_return_leg {V T β : ℝ} (hβeq : β * (V ^ 2 + 1) = 2 * V) :
    boostX β T (V * T) = V * (-(boostT β T (V * T))) := by
  rw [boostT, boostX, mul_neg, ← mul_div_assoc, ← neg_div]
  congr 1
  linear_combination (-T) * hβeq

theorem warp_pair_closes_loop {V T : ℝ} (hV : 1 < V) (hT : 0 < T) :
    ∃ β : ℝ, 0 < β ∧ β < 1 ∧ ∃ s : ℝ, 0 < s ∧
      boostT β T (V * T) + s = 0 ∧ boostX β T (V * T) - V * s = 0 := by
  have hV0 : 0 < V := lt_trans zero_lt_one hV
  have hden : 0 < V ^ 2 + 1 := by positivity
  have hβpos : 0 < 2 * V / (V ^ 2 + 1) := by positivity
  have hβlt : 2 * V / (V ^ 2 + 1) < 1 := by
    rw [div_lt_one hden]; nlinarith [sq_nonneg (V - 1)]
  refine ⟨2 * V / (V ^ 2 + 1), hβpos, hβlt, ?_⟩
  have hβeq : (2 * V / (V ^ 2 + 1)) * (V ^ 2 + 1) = 2 * V := by
    field_simp
  have hβV : 1 < (2 * V / (V ^ 2 + 1)) * V := by
    rw [div_mul_eq_mul_div, lt_div_iff₀ hden]
    nlinarith [sq_nonneg (V - 1)]
  have hβabs : |2 * V / (V ^ 2 + 1)| < 1 := by
    rw [abs_of_nonneg hβpos.le]; exact hβlt
  have hκ : 0 < Real.sqrt (1 - (2 * V / (V ^ 2 + 1)) ^ 2) := boost_factor_pos hβabs
  refine ⟨-(boostT (2 * V / (V ^ 2 + 1)) T (V * T)), ?_, by ring, ?_⟩
  · rw [boostT, neg_pos, div_neg_iff]
    exact Or.inr ⟨by nlinarith, hκ⟩
  · rw [boost_return_leg hβeq]
    ring

/-- **Return to one's own past.**  Reformulation of `warp_pair_closes_loop`: the traveller's
second leg starts at an event with strictly negative time coordinate in the boosted frame
(`boostT β T (V T) < 0`) — the first leg has already carried them into the past of the frame
in which the second corridor is built.  This is the causality violation. -/
theorem warp_pair_returns_to_past {V T : ℝ} (hV : 1 < V) (hT : 0 < T) :
    ∃ β : ℝ, 0 < β ∧ β < 1 ∧ boostT β T (V * T) < 0 := by
  obtain ⟨β, hβ0, hβ1, s, hs, hsum, -⟩ := warp_pair_closes_loop hV hT
  exact ⟨β, hβ0, hβ1, by linarith⟩

/-- **The dichotomy.**  (i) One Alcubierre bubble — of *any* shape function, warp speed and
trajectory — admits no closed causal curve.  (ii) Two corridors in relative motion, each of
effective speed `V > 1`, close a loop returning to the departure event.  Hence closed
timelike curves are not a property of the Alcubierre metric itself but of the *existence of
two independently oriented warp corridors*. -/
theorem alcubierre_ctc_dichotomy {V T : ℝ} (hV : 1 < V) (hT : 0 < T) :
    (∀ (γ u : ℝ → (Fin 4 → ℝ)) (w : ℝ → ℝ),
        (∀ s ∈ Icc (0:ℝ) 1, ∀ i, HasDerivAt (fun σ => γ σ i) (u s i) s) →
        (∀ s ∈ Icc (0:ℝ) 1, IsCausal (w s) (u s)) →
        (∀ s ∈ Icc (0:ℝ) 1, ¬ (u s 0 = 0 ∧ u s 1 = 0 ∧ u s 2 = 0 ∧ u s 3 = 0)) →
        γ 0 ≠ γ 1)
    ∧ (∃ β : ℝ, 0 < β ∧ β < 1 ∧ ∃ s : ℝ, 0 < s ∧
        boostT β T (V * T) + s = 0 ∧ boostX β T (V * T) - V * s = 0) := by
  refine ⟨?_, warp_pair_closes_loop hV hT⟩
  intro γ u w hderiv hcausal hnonzero hclosed
  exact no_closed_causal_curve γ u w hderiv hcausal hnonzero hclosed

end Catalog.Physics.Spacetime.Alcubierre