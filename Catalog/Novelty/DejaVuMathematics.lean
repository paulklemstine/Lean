import MachineLearning.DejaVu.CognitiveDynamics

/-!
# Recurrence, continuity, and the limits of the déjà-vu analogy

A recurrence event is represented by a positive iterate returning to its initial
state. The results below separate existence of recurrence, density of recurrent
states, and recurrence visible through an observation map. Continuous interval
dynamics guarantee the first, but not the second; and a non-faithful observation
can report recurrence that is absent from the underlying trajectory.
-/

noncomputable section

open Set Function
open CognitiveDynamics

namespace DejaVuMathematics

/-- States returning after at least one transition. -/
def PeriodicStates {S : Type*} (f : S → S) : Set S :=
  {s | ∃ n > 0, f^[n] s = s}

/-- Recurrence is transported by a semiconjugacy of dynamical systems. -/
theorem periodicStates_mapsTo_of_semiconj {S T : Type*} {f : S → S} {g : T → T}
    (h : S → T) (hsemi : Semiconj h f g) :
    MapsTo h (PeriodicStates f) (PeriodicStates g) := by
  intro s hs
  rcases hs with ⟨n, hn, hs⟩
  refine ⟨n, hn, ?_⟩
  rw [← hsemi.iterate_right, hs]

/-- A faithful dynamical encoding preserves and reflects all positive returns. -/
theorem periodicStates_preimage_of_injective_semiconj
    {S T : Type*} {f : S → S} {g : T → T}
    (h : S → T) (hsemi : Semiconj h f g) (hinj : Injective h) :
    h ⁻¹' PeriodicStates g = PeriodicStates f := by
  ext s
  constructor
  · rintro ⟨n, hn, hs⟩
    refine ⟨n, hn, hinj ?_⟩
    rw [hsemi.iterate_right]
    exact hs
  · intro hs
    exact periodicStates_mapsTo_of_semiconj h hsemi hs

/-- Every state except the image of a constant transition is nonperiodic. -/
theorem periodicStates_constant (c : ℝ) :
    PeriodicStates (fun _ : ℝ => c) = {c} := by
  ext x
  constructor
  · rintro ⟨n, hn, hx⟩
    cases n with
    | zero => omega
    | succ n =>
      have hc : (fun _ : ℝ => c)^[n + 1] x = c := by
        rw [Function.iterate_succ_apply]
        exact Function.iterate_fixed (f := fun _ : ℝ => c) (by rfl) n
      exact Set.mem_singleton_iff.mpr (hx ▸ hc)
  · rintro (rfl : x = c)
    exact ⟨1, by omega, by simp⟩

/-- Continuity alone does not make periodic states dense, even on the real line. -/
theorem continuous_dynamics_need_not_have_dense_periodicStates :
    ∃ f : ℝ → ℝ, Continuous f ∧ ¬ Dense (PeriodicStates f) := by
  refine ⟨fun _ => 0, continuous_const, ?_⟩
  rw [periodicStates_constant]
  intro hd
  have hclosure : closure ({0} : Set ℝ) = Set.univ := dense_iff_closure_eq.mp hd
  have hmem : (1 : ℝ) ∈ closure ({0} : Set ℝ) := by rw [hclosure]; trivial
  simp at hmem

/-- Any continuous self-map of a nondegenerate closed interval has a periodic
state in that interval. Thus recurrence existence is robust, while density is
not. -/
theorem interval_dynamics_has_periodic_state (D : IntervalDynamics) :
    ∃ s ∈ Icc D.a D.b, s ∈ PeriodicStates D.f := by
  obtain ⟨s, hs, hfix⟩ := D.exists_fixed_point
  exact ⟨s, hs, 1, by omega, by simp [hfix]⟩

/-- The logistic transition at parameter `3.83` preserves the unit interval. -/
theorem logistic_383_maps_unitInterval :
    MapsTo (fun x : ℝ => (383 / 100) * x * (1 - x)) (Icc 0 1) (Icc 0 1) := by
  intro x hx
  rcases hx with ⟨hx0, hx1⟩
  constructor
  · have hxone : 0 ≤ 1 - x := by linarith
    positivity
  · nlinarith [sq_nonneg (x - (1 / 2 : ℝ))]

/-- At parameter `3.83`, the logistic transition has exactly the two fixed states
`0` and `283/383`. This algebraic classification does not assign either state a
probability or a population incidence. -/
theorem logistic_383_fixed_point_iff (x : ℝ) :
    (383 / 100) * x * (1 - x) = x ↔ x = 0 ∨ x = 283 / 383 := by
  constructor
  · intro hx
    have hfactor : x * (383 * x - 283) = 0 := by nlinarith
    rcases mul_eq_zero.mp hfactor with hzero | hlinear
    · exact Or.inl hzero
    · right
      field_simp
      linarith
  · rintro (rfl | rfl)
    · norm_num
    · norm_num

/-- A constant observation reports a fixed observation at every time, regardless
of whether the underlying state returns. Hence observational recurrence is not
state recurrence unless faithfulness assumptions are imposed. -/
theorem constant_observation_false_positive
    {S O : Type*} (f : S → S) (observe : S → O) (o : O)
    (hobs : ∀ s, observe s = o) (s : S) (hnon : s ∉ PeriodicStates f) :
    (fun _ : O => o) (observe s) = observe s ∧ s ∉ PeriodicStates f := by
  exact ⟨by rw [hobs], hnon⟩

/-!
-- !-- Lab Notes -- !--

**Hypothesis.** Continuous interval dynamics force at least one recurrent state,
but neither continuity nor the existence of one cycle should imply that recurrent
states fill the state space. Recurrence should be invariant under faithful
changes of coordinates and unreliable under lossy observation.

**Experiment.** Positive-return states were collected into `PeriodicStates`.
Semiconjugacy transported them forward, while injectivity supplied the reverse
implication. Constant dynamics supplied an adversarial test of the density claim.
At the proposed logistic parameter `3.83`, interval invariance and the fixed-point
equation were checked exactly over the rationals.

**Analysis.** Existence survives: the interval fixed-point theorem always gives a
period-one state. Density fails: a continuous constant transition has exactly one
periodic state. Faithful encoding preserves all positive returns, whereas a
constant observation can display a fixed observation along an arbitrary state
trajectory. The logistic parameter has two algebraic fixed states, but this says
nothing about a `70%` incidence rate.

**Critique.** The rejected density claim confused continuity with a much stronger
chaotic hypothesis. Topological density, natural density, invariant-measure
weight, and lifetime population incidence are distinct quantities. A period-three
orbit can support strong one-dimensional chaos theorems, but it does not identify
any of those quantities with an empirical percentage. Numerical iteration near
an attracting cycle is also not an exact proof of minimal period.

**Synthesis.** Recurrence is mathematically inevitable for continuous self-maps of
compact intervals, but widespread recurrence is not. A defensible cognitive
model therefore requires both a faithful observation mechanism and a specified
probability measure before it can make incidence predictions.

-- !-- End Lab Notes -- !--
-/

end DejaVuMathematics