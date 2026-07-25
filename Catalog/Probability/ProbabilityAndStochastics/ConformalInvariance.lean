/-
# A measurable interface for conformal covariance of random curves

The analytic construction of Schramm–Loewner evolution is separated here from
its functorial content.  A simply connected domain equipped with a conformal
chart has a measurable curve space, while a reference law lives on a standard
curve space.  Pulling that law back through a chart produces the domain law.
The principal result proves that this construction is independent of the chart
whenever transition maps preserve the reference law.

This formulation isolates three structural consequences used throughout the
probability theory of random interfaces: coherence under composition, recovery
under inverse transport, and invariance of all measurable curve events.  The
last section links conformal transport with a Borel–Cantelli estimate from the
probability catalog: summable exceptional events remain almost surely finite
after a measurable equivalence of curve spaces.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A chart-based construction of an interface law should
  descend to an intrinsic domain law exactly when every chart transition
  preserves the standard law. Six falsifiable conjectures were ranked by impact:
  full chart descent; covariance under non-bijective conformal maps;
  reconstruction from finite-dimensional driving observables; compatibility
  with time reversal; stability under Carathéodory domain limits; and functorial
  coupling of several interfaces.
Experiment (Experimenter): Transport was tested first on finite curve spaces,
  where charts are permutations.  Composition and inverse transport survived;
  the non-bijective version failed because inverse transport cannot recover mass
  merged by the map.  The surviving statement was then formulated for arbitrary
  measurable equivalences.
Analysis (Analyst): Bijectivity, rather than complex differentiability, is the
  decisive ingredient in chart independence.  The specifically analytic SLE
  burden is therefore concentrated in proving that transition maps preserve the
  standard law.  Once this is known, event probabilities and null exceptional
  sets descend formally.
Critique (Critic): No existence claim for the Loewner chain or Brownian driving
  process is hidden in the interface.  The chart-transition hypothesis is
  explicit and indispensable.  Measurability is retained on both sides, and the
  inverse theorem rules out a vacuous one-way covariance statement.
Synthesis (Principal Investigator): The resulting descent theorem gives a clean
  boundary between conformal analysis and probability.  A transported
  Borel–Cantelli theorem shows that almost-sure finiteness statements are also
  intrinsic under changes of chart.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.PosetTheory.BrocardBorelCantelli

open Filter MeasureTheory

namespace SLEInterface

/-- Transport a random-interface law along a measurable map of curve spaces. -/
noncomputable def transport {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]
    (f : X → Y) (μ : Measure X) : Measure Y := Measure.map f μ

/-- The law on a domain curve space induced from a standard law and a chart to
that standard curve space. -/
noncomputable def chartLaw {X H : Type*} [MeasurableSpace X] [MeasurableSpace H]
    (chart : X ≃ᵐ H) (standardLaw : Measure H) : Measure X :=
  transport chart.symm standardLaw

/-- Transport is coherent under consecutive measurable changes of curve space. -/
theorem transport_comp {X Y Z : Type*}
    [MeasurableSpace X] [MeasurableSpace Y] [MeasurableSpace Z]
    (μ : Measure X) (f : X → Y) (g : Y → Z)
    (hf : Measurable f) (hg : Measurable g) :
    transport g (transport f μ) = transport (g ∘ f) μ := by
  unfold transport
  exact Measure.map_map hg hf

/-- Transport by a measurable equivalence and then by its inverse recovers the
original interface law. -/
theorem transport_equiv_inverse {X Y : Type*}
    [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (e : X ≃ᵐ Y) :
    transport e.symm (transport e μ) = μ := by
  rw [transport, transport, Measure.map_map e.symm.measurable e.measurable]
  convert Measure.map_id
  exact e.symm_comp_self

/-- Consequently, transport along a measurable equivalence is injective on laws. -/
theorem transport_equiv_injective {X Y : Type*}
    [MeasurableSpace X] [MeasurableSpace Y] (e : X ≃ᵐ Y) :
    Function.Injective (transport e : Measure X → Measure Y) := by
  intro μ ν h
  have hback := congrArg (transport e.symm) h
  simpa only [transport, Measure.map_map e.symm.measurable e.measurable,
    e.symm_comp_self, Measure.map_id] using hback

/-- **Chart-independence (conformal descent).** If the transition between two
charts preserves the standard interface law, both charts induce the same law on
the original curve space. -/
theorem chartLaw_independent {X H : Type*}
    [MeasurableSpace X] [MeasurableSpace H]
    (standardLaw : Measure H) (c₁ c₂ : X ≃ᵐ H)
    (htransition : transport (c₂ ∘ c₁.symm) standardLaw = standardLaw) :
    chartLaw c₁ standardLaw = chartLaw c₂ standardLaw := by
  have h := congrArg (transport c₂.symm) htransition
  unfold chartLaw transport at h ⊢
  rw [Measure.map_map c₂.symm.measurable
    (c₂.measurable.comp c₁.symm.measurable)] at h
  rw [show c₂.symm ∘ (c₂ ∘ c₁.symm) = c₁.symm by funext x; simp] at h
  exact h

/-- A measurable event has the same probability before and after an invertible
change of curve coordinates. -/
theorem transport_image_event {X Y : Type*}
    [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (e : X ≃ᵐ Y) {A : Set X} (hA : MeasurableSet A) :
    transport e μ (e '' A) = μ A := by
  rw [transport, Measure.map_apply e.measurable (e.measurableSet_image.mpr hA)]
  rw [e.preimage_image]

/-- Measurable equivalences commute with the event that infinitely many members
of a sequence occur, at the level of probability. -/
theorem transport_frequently_event {X Y : Type*}
    [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (e : X ≃ᵐ Y) (E : ℕ → Set X)
    (hE : ∀ n, MeasurableSet (E n)) :
    transport e μ {y | ∃ᶠ n in atTop, y ∈ e '' E n} =
      μ {x | ∃ᶠ n in atTop, x ∈ E n} := by
  have hfreq : {y | ∃ᶠ n in atTop, y ∈ e '' E n} =
      e '' {x | ∃ᶠ n in atTop, x ∈ E n} := by
    ext y
    constructor
    · intro hy
      have hevent : ∀ᶠ n in atTop, (y ∈ e '' E n ↔ e.symm y ∈ E n) := by
        filter_upwards [] with n
        constructor
        · rintro ⟨x, hx, hxy⟩
          subst y
          simpa using hx
        · intro hx
          exact ⟨e.symm y, hx, by simp⟩
      have hy' : ∃ᶠ n in atTop, e.symm y ∈ E n :=
        (frequently_congr hevent).mp hy
      exact ⟨e.symm y, hy', by simp⟩
    · rintro ⟨x, hx, rfl⟩
      have hevent : ∀ᶠ n in atTop, (x ∈ E n ↔ e x ∈ e '' E n) := by
        filter_upwards [] with n
        constructor
        · intro hn
          exact ⟨x, hn, rfl⟩
        · rintro ⟨z, hz, hzx⟩
          have : z = x := e.injective hzx
          simpa [this] using hz
      exact (frequently_congr hevent).mp hx
  rw [hfreq, transport, Measure.map_apply e.measurable]
  · rw [e.preimage_image]
  · apply e.measurableSet_image.mpr
    have heq : {x | ∃ᶠ n in atTop, x ∈ E n} = limsup E atTop := by
      ext x
      exact mem_limsup_iff_frequently_mem.symm
    rw [heq]
    exact MeasurableSet.measurableSet_limsup hE

/-- **Conformal Borel–Cantelli bridge.** A factorial-decay bound for exceptional
interface events implies that, after any invertible measurable change of curve
coordinates, almost no curve belongs to infinitely many transported events. -/
theorem transported_factorial_exceptional_events {X Y : Type*}
    [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (e : X ≃ᵐ Y) (E : ℕ → Set X) (C : ℝ)
    (hC : 0 ≤ C) (hE : ∀ n, MeasurableSet (E n))
    (hbound : ∀ n,
      μ (E n) ≤ ENNReal.ofReal (C / Real.sqrt (Nat.factorial n))) :
    transport e μ {y | ∃ᶠ n in atTop, y ∈ e '' E n} = 0 := by
  rw [transport_frequently_event μ e E hE]
  exact BrocardBorelCantelli.brocard_heuristic_finite E C hC hbound

end SLEInterface