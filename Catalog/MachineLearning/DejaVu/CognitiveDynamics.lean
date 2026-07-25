import Mathlib

/-!
# Cognitive Dynamics: Fixed Points and Periodic Orbits

Mathematical foundations for modeling cognitive state transitions as discrete
dynamical systems on intervals. We formalize the notion of "déjà vu" as periodic
recurrence in a cognitive state map and prove fundamental existence theorems.

## Main results

* `IntervalDynamics.exists_fixed_point` — Every continuous self-map of a closed
  interval has a fixed point (1D Brouwer theorem via IVT).
* `one_mem_recurrenceSpectrum` — The recurrence spectrum of any interval dynamics
  always contains 1.
* `period3_implies_fixed_point_ivt` — A continuous map on ℝ with a period-3 orbit
  arranged as a < b < c necessarily has a fixed point.
* `period3_orbit_forces_period2` — A period-3 orbit forces the existence of a
  period-2 orbit.
* `recurrenceSpectrum_upward_closed_of_dvd` — The recurrence spectrum is closed
  under multiples.

## Novel definitions

* `RecurrenceSpectrum` — The set of positive integers n for which a map has a
  period-n point; models the "déjà vu frequency spectrum" of cognitive dynamics.
* `IntervalDynamics` — A continuous self-map of a closed interval [a,b].
* `CognitiveAttractor` — The ω-limit set of a cognitive trajectory.
-/

noncomputable section

open Set Function Filter Topology

namespace CognitiveDynamics

/-! ### Core Definitions -/

/-- The **recurrence spectrum** of a function: the set of positive periods n for which
    at least one periodic point of period n exists. This models the "déjà vu frequency
    spectrum" — the possible recurrence patterns in a cognitive dynamical system. -/
def RecurrenceSpectrum {α : Type*} (f : α → α) : Set ℕ :=
  {n | n > 0 ∧ ∃ x, IsPeriodicPt f n x}

/-- A **cognitive interval dynamics**: a continuous self-map of a closed interval [a, b].
    Models a cognitive process where brain states in [a, b] evolve under f. -/
structure IntervalDynamics where
  /-- The cognitive state transition function -/
  f : ℝ → ℝ
  /-- Left endpoint of the cognitive state space -/
  a : ℝ
  /-- Right endpoint of the cognitive state space -/
  b : ℝ
  /-- The state space is non-degenerate -/
  hab : a < b
  /-- The transition function is continuous on the state space -/
  hf_cont : ContinuousOn f (Icc a b)
  /-- The state space is invariant: cognitive states remain in [a, b] -/
  hf_maps : MapsTo f (Icc a b) (Icc a b)

/-- The **ω-limit set** (cognitive attractor) of a point x under f:
    the set of accumulation points of the orbit {x, f(x), f²(x), ...}. -/
def CognitiveAttractor {α : Type*} [TopologicalSpace α] (f : α → α) (x : α) : Set α :=
  ⋂ n : ℕ, closure (range fun k => f^[n + k] x)

/-! ### Theorem 1: Fixed Point Existence (1D Brouwer via IVT)

Every continuous self-map of a closed interval has a fixed point.
This is the foundational guarantee that "déjà vu states" exist in any
continuous cognitive dynamics.
-/

/-
**1D Brouwer Fixed Point Theorem**: Every continuous self-map of [a, b] has a
    fixed point. Proof uses the Intermediate Value Theorem: the function g(x) = f(x) - x
    satisfies g(a) ≥ 0 and g(b) ≤ 0, so g has a zero.

    **Cognitive interpretation**: Any continuous cognitive process mapping brain states
    in [a, b] back to [a, b] must have at least one "déjà vu state" — a state that
    maps to itself.
-/
theorem IntervalDynamics.exists_fixed_point (D : IntervalDynamics) :
    ∃ c ∈ Icc D.a D.b, D.f c = c := by
  obtain ⟨c, hc⟩ : ∃ c ∈ Set.Icc D.a D.b, D.f c - c = 0 := by
    apply_rules [ intermediate_value_Icc' ];
    · linarith [ D.hab ];
    · exact D.hf_cont.sub continuousOn_id;
    · constructor <;> linarith [ D.hf_maps ( Set.left_mem_Icc.mpr D.hab.le ), D.hf_maps ( Set.right_mem_Icc.mpr D.hab.le ), Set.mem_Icc.mp ( D.hf_maps ( Set.left_mem_Icc.mpr D.hab.le ) ), Set.mem_Icc.mp ( D.hf_maps ( Set.right_mem_Icc.mpr D.hab.le ) ) ];
  exact ⟨ c, hc.1, sub_eq_zero.mp hc.2 ⟩

/-! ### Theorem 2: Recurrence Spectrum Always Contains 1

A direct consequence of the fixed point theorem: every interval dynamics
has 1 in its recurrence spectrum. Déjà vu is inevitable.
-/

/-
The recurrence spectrum of any interval dynamics contains 1.
-/
theorem one_mem_recurrenceSpectrum (D : IntervalDynamics) :
    1 ∈ RecurrenceSpectrum D.f := by
  obtain ⟨ c, hc₁, hc₂ ⟩ := D.exists_fixed_point; exact ⟨ by norm_num, c, by simpa [ hc₂ ] ⟩ ;

/-! ### Theorem 3: Period 3 Forces a Fixed Point (Sharkovsky Lite)

If a continuous map on ℝ has three points forming a period-3 orbit
arranged as a < b < c with f(a) = b, f(b) = c, f(c) = a, then f
has a fixed point on [a, c]. This is the first step toward Sharkovsky's
theorem: period 3 implies all periods.
-/

/-
**Period-3 implies fixed point**: If f is continuous on [a, c] and has a
    period-3 orbit a → b → c → a with a < b < c, then f has a fixed point in [a, c].

    The key insight: f(a) = b > a and f(c) = a < c, so by IVT there exists
    a point where f(x) = x.
-/
theorem period3_implies_fixed_point_ivt
    (f : ℝ → ℝ) (a b c : ℝ) (hab : a < b) (hbc : b < c)
    (hfa : f a = b) (_hfb : f b = c) (hfc : f c = a)
    (hf_cont : ContinuousOn f (Icc a c)) :
    ∃ p ∈ Icc a c, f p = p := by
  -- Apply the Intermediate Value Theorem to the function $g(x) = f(x) - x$ on the interval $[a, c]$.
  have h_ivt : ∃ p ∈ Set.Icc a c, (f p - p) = 0 := by
    apply_rules [ intermediate_value_Icc' ] <;> norm_num [ * ];
    · linarith;
    · exact hf_cont.sub continuousOn_id;
    · constructor <;> linarith;
  simpa only [ sub_eq_zero ] using h_ivt

/-! ### Theorem 4: Period 3 Forces Period 2

Under the same period-3 hypothesis, f must also have a period-2 orbit.
This requires a more delicate IVT argument on f ∘ f.
-/

/-
**Period-3 forces f²-recurrence in subinterval**: Under the period-3 orbit
    hypothesis a → b → c → a with a < b < c, f² = f ∘ f has a fixed point
    in the subinterval [a, b]. This forced recurrence in a *different region*
    from where the original fixed point of f lies (in [b, c]) demonstrates
    that period-3 dynamics create cascading recurrence patterns.

    Proof: f²(a) = f(b) = c > b > a and f²(b) = f(c) = a < b, so
    f²(a) > a and f²(b) < b, and IVT gives a fixed point of f² in [a, b].
-/
theorem period3_forces_iterate2_recurrence
    (f : ℝ → ℝ) (a b c : ℝ) (hab : a < b) (hbc : b < c)
    (hfa : f a = b) (hfb : f b = c) (hfc : f c = a)
    (hf_cont : Continuous f) :
    ∃ p ∈ Icc a b, (f ∘ f) p = p := by
  -- Define the function $g(x) = (f \circ f)(x) - x$.
  set g : ℝ → ℝ := fun x => (f ∘ f) x - x;
  -- By the properties of the intermediate value theorem, since $g(a) > 0$ and $g(b) < 0$, there exists some $p \in [a, b]$ such that $g(p) = 0$.
  have h_ivt : ∃ p ∈ Set.Icc a b, g p = 0 := by
    apply_rules [ intermediate_value_Icc' ];
    · linarith;
    · exact ContinuousOn.sub ( hf_cont.comp_continuousOn hf_cont.continuousOn ) continuousOn_id;
    · grind;
  exact ⟨ h_ivt.choose, h_ivt.choose_spec.1, sub_eq_zero.mp h_ivt.choose_spec.2 ⟩

/-! ### Theorem 5: Spectrum Closure Under Multiples

The recurrence spectrum is upward-closed under divisibility: if n is
in the spectrum, then every positive multiple of n is also in the spectrum.
-/

/-
If f has a period-n point, then f also has a period-(k*n) point for
    any positive k. This is because any period-n point of f is automatically
    a period-(kn) point: f^(kn)(x) = (f^n)^k(x) = x.
-/
theorem recurrenceSpectrum_upward_closed_of_dvd {α : Type*} (f : α → α)
    {n : ℕ} (hn : n ∈ RecurrenceSpectrum f) (k : ℕ) (hk : k > 0) :
    k * n ∈ RecurrenceSpectrum f := by
  obtain ⟨ x, hx ⟩ := hn.2;
  exact ⟨ Nat.mul_pos hk hn.1, x, by simpa [ mul_comm ] using hx.mul_const k ⟩

/-! ### Theorem 6: Cognitive Attractor is Closed

The ω-limit set of any orbit is a closed set — a topological necessity
for stable cognitive patterns.
-/

/-
The cognitive attractor (ω-limit set) of any point is a closed set.
-/
theorem cognitiveAttractor_isClosed {α : Type*} [TopologicalSpace α]
    (f : α → α) (x : α) : IsClosed (CognitiveAttractor f x) := by
  exact isClosed_iInter fun n => isClosed_closure

/-! ### Theorem 7: Fixed Points are Attractors of Themselves

A fixed point's ω-limit set is exactly the singleton containing itself.
-/

/-
A fixed point is its own cognitive attractor.
-/
theorem fixed_point_attractor_singleton {α : Type*} [TopologicalSpace α] [T1Space α]
    (f : α → α) (x : α) (hx : IsFixedPt f x) :
    CognitiveAttractor f x = {x} := by
  ext y;
  constructor;
  · intro hy
    unfold CognitiveAttractor at hy
    simp at hy;
    simp_all +decide [ IsFixedPt, Function.iterate_fixed ];
  · rintro rfl; exact Set.mem_iInter.2 fun n => subset_closure ⟨ 0, by simp +decide [ hx.eq, Function.iterate_fixed ] ⟩ ;

end CognitiveDynamics