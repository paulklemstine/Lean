import Mathlib

/-!
# Self-duality and exact finite percolation thresholds

This file isolates the general symmetry argument behind exact self-dual crossing
probabilities. A crossing function on the Bernoulli parameter interval is
self-dual when complementing the parameter complements its value. Self-duality
forces value `1/2` at the midpoint; strict monotonicity makes that midpoint the
unique fair parameter and determines the strict subcritical and supercritical
inequalities.

The final theorems give the corresponding event-level statement. Any measurable
event exchanged with its complement by a measure-preserving transformation of a
probability space has probability exactly `1/2`.
-/

open Set MeasureTheory

namespace PercolationSelfDuality

/-- A real-valued crossing function is self-dual on the Bernoulli parameter
interval when parameter complementation also complements its value. -/
def IsSelfDualOnUnit (crossing : ℝ → ℝ) : Prop :=
  ∀ p ∈ Set.Icc (0 : ℝ) 1, crossing (1 - p) = 1 - crossing p

/-- Every self-dual crossing function takes the fair value at `p = 1/2`. -/
theorem crossing_half_of_selfDual {crossing : ℝ → ℝ}
    (hdual : IsSelfDualOnUnit crossing) :
    crossing (1 / 2 : ℝ) = 1 / 2 := by
  have h := hdual (1 / 2) (by constructor <;> norm_num)
  norm_num at h ⊢
  linarith

/-- Strict monotonicity makes every parameter below the self-dual point have
crossing value strictly below `1/2`. -/
theorem crossing_lt_half_of_lt {crossing : ℝ → ℝ}
    (hdual : IsSelfDualOnUnit crossing)
    (hmono : StrictMonoOn crossing (Set.Icc (0 : ℝ) 1))
    {p : ℝ} (hp0 : 0 ≤ p) (hp : p < 1 / 2) :
    crossing p < 1 / 2 := by
  rw [← crossing_half_of_selfDual hdual]
  exact hmono ⟨hp0, by linarith⟩ (by constructor <;> norm_num) hp

/-- Strict monotonicity makes every parameter above the self-dual point have
crossing value strictly above `1/2`. -/
theorem crossing_gt_half_of_lt {crossing : ℝ → ℝ}
    (hdual : IsSelfDualOnUnit crossing)
    (hmono : StrictMonoOn crossing (Set.Icc (0 : ℝ) 1))
    {p : ℝ} (hp : 1 / 2 < p) (hp1 : p ≤ 1) :
    1 / 2 < crossing p := by
  rw [← crossing_half_of_selfDual hdual]
  exact hmono (by constructor <;> norm_num) ⟨by linarith, hp1⟩ hp

/-- For a strictly increasing self-dual crossing function, the fair crossing
equation has the unique solution `p = 1/2` in the Bernoulli interval. -/
theorem crossing_eq_half_iff {crossing : ℝ → ℝ}
    (hdual : IsSelfDualOnUnit crossing)
    (hmono : StrictMonoOn crossing (Set.Icc (0 : ℝ) 1))
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    crossing p = 1 / 2 ↔ p = 1 / 2 := by
  constructor
  · intro heq
    rcases lt_trichotomy p (1 / 2) with hlt | heq' | hgt
    · have := crossing_lt_half_of_lt hdual hmono hp0 hlt
      linarith
    · exact heq'
    · have := crossing_gt_half_of_lt hdual hmono hgt hp1
      linarith
  · rintro rfl
    exact crossing_half_of_selfDual hdual

/-- Self-duality is equivalently antisymmetry of the centered crossing function
around the midpoint of the parameter interval. -/
theorem centered_crossing_antisymm {crossing : ℝ → ℝ}
    (hdual : IsSelfDualOnUnit crossing) {x : ℝ}
    (hx : x ∈ Set.Icc (-1 / 2 : ℝ) (1 / 2)) :
    crossing (1 / 2 + x) - 1 / 2 =
      -(crossing (1 / 2 - x) - 1 / 2) := by
  have hp : 1 / 2 - x ∈ Set.Icc (0 : ℝ) 1 := by
    constructor <;> dsimp at hx ⊢ <;> linarith [hx.1, hx.2]
  have h := hdual (1 / 2 - x) hp
  norm_num at h ⊢
  ring_nf at h ⊢
  linarith

/-- A measure-preserving symmetry that exchanges a measurable event with its
complement forces the event to have probability exactly `1/2`. -/
theorem measure_eq_half_of_preimage_eq_compl
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (symmetry : Ω → Ω)
    (hsymmetry : MeasurePreserving symmetry μ μ)
    (event : Set Ω) (hevent : MeasurableSet event)
    (hexchange : symmetry ⁻¹' event = eventᶜ) :
    μ event = 1 / 2 := by
  rw [ENNReal.eq_div_iff (by norm_num) (by norm_num)]
  rw [two_mul]
  have heq : μ eventᶜ = μ event := by
    rw [← hexchange]
    exact hsymmetry.measure_preimage hevent.nullMeasurableSet
  calc
    μ event + μ event = μ event + μ eventᶜ := congrArg (μ event + ·) heq.symm
    _ = μ Set.univ := measure_add_measure_compl hevent
    _ = 1 := measure_univ

/-- More generally, two measurable events exchanged by a measure-preserving
symmetry and forming a complementary pair both have probability `1/2`. -/
theorem exchanged_complementary_events_eq_half
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    [IsProbabilityMeasure μ] (symmetry : Ω → Ω)
    (hsymmetry : MeasurePreserving symmetry μ μ)
    (event dualEvent : Set Ω) (hevent : MeasurableSet event)
    (hdualEvent : dualEvent = eventᶜ)
    (hexchange : symmetry ⁻¹' event = dualEvent) :
    μ event = 1 / 2 ∧ μ dualEvent = 1 / 2 := by
  subst dualEvent
  have heventHalf := measure_eq_half_of_preimage_eq_compl
    μ symmetry hsymmetry event hevent hexchange
  constructor
  · exact heventHalf
  · have hsum := measure_add_measure_compl (μ := μ) hevent
    rw [measure_univ, heventHalf] at hsum
    rw [← ENNReal.add_left_inj (a := (1 / 2 : ENNReal)) (by norm_num)]
    rw [add_comm (μ eventᶜ), hsum]
    exact (ENNReal.add_halves 1).symm

end PercolationSelfDuality