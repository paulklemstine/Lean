import Geometry.QuantumSurreal.Basic
import Geometry.QuantumSurreal.StandardPartMeasure
import Tropical.MeasureTheory.Basic

/-!
# Tropical shadow of infinitesimal quantum measurement

Standard-part observation and max-plus selection describe two complementary limits.  The first
forgets infinitesimal probability mass; the second retains the outcome with dominant logarithmic
weight.  On the finite infinitesimal model, both limits select the reservoir atom.

The central result below identifies a robust common regime.  Standard part turns the
lexicographic infinitesimal measure into the Dirac probability at `none`.  A tropical Dirac weight
also selects `none`, not merely for constant observables, but for every observable whose visible
advantage does not overcome the prescribed tropical penalty.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): six conjectures were compared by expected impact: a non-Archimedean
spectral theorem; a standard-part functional calculus; compatibility of standard part with finite
Born normalization; equivalence of lexicographic and hyperreal infinitesimal collapse; a
Maslov-dequantized description of the surviving support; and label-dependent suppression of an
appreciably weighted ket.  The first two require substantially more analytic structure, while the
last is false: amplitudes, not labels, determine Born mass.

Experiment (Experimenter): on `Option (Fin n)`, every visible atom has lexicographic mass
`(0,1)`, while the reservoir has real component one.  Standard part therefore selects the
reservoir.  Assigning tropical weight zero to the reservoir and a negative penalty `M` to visible
atoms gives the same selector whenever `f(some i) + M ≤ f(none)`.

Analysis (Analyst): the two limiting procedures do not coincide numerically.  Standard part is
additive and produces an ordinary probability, whereas tropical integration is max-plus linear.
They nevertheless have a shared support-selection law.  This is the strongest faithful bridge:
it compares their selected outcome without incorrectly identifying their algebraic operations.

Critique (Critic): the dominance condition is necessary.  A visible outcome with sufficiently
large observable value defeats any fixed finite tropical penalty, even though its standard-part
probability remains zero.  Thus unconditional equality of the two expectations would be false.
The proof analyzes the maximizing atom and uses the dominance inequality in the visible case.

Synthesis (Principal Investigator): infinitesimal collapse has an additive shadow and an
idempotent shadow.  They agree on the surviving support under a sharp observable-dependent
stability condition, while retaining distinct probability algebras.
-- !-- Lab Notes -- !--
-/

open InfinitesimalProbability

namespace TropicalQuantumSurreal

/-- Tropical penalty model on the same finite outcome space as the lexicographic infinitesimal
probability: the reservoir has weight zero and every visible outcome has weight `M < 0`. -/
noncomputable def reservoirTropicalMeasure (n : ℕ) (M : ℝ) (hM : M < 0) :
    TropicalMeasureTheory.MaxPlusMeasure (Option (Fin n)) :=
  TropicalMeasureTheory.diracTropicalMeasure (none : Option (Fin n)) M hM

/-- Under the dominance condition, the max-plus integral is attained at the reservoir. -/
theorem reservoir_maxPlusIntegral_eq (n : ℕ) (M : ℝ) (hM : M < 0)
    (f : Option (Fin n) → ℝ) (hdom : ∀ i, f (some i) + M ≤ f none) :
    TropicalMeasureTheory.maxPlusIntegral f (reservoirTropicalMeasure n M hM) = f none := by
  obtain ⟨x, hx⟩ := TropicalMeasureTheory.maxPlusIntegral_attained (reservoirTropicalMeasure n M hM) f;
  cases x <;> simp_all +decide [ reservoirTropicalMeasure ];
  · unfold TropicalMeasureTheory.diracTropicalMeasure; aesop;
  · contrapose! hx;
    refine' ne_of_gt ( lt_of_lt_of_le _ ( TropicalMeasureTheory.le_maxPlusIntegral ( TropicalMeasureTheory.diracTropicalMeasure none M hM ) f none ) );
    convert lt_of_le_of_ne ( hdom _ ) hx using 1 ; unfold TropicalMeasureTheory.diracTropicalMeasure ; aesop

/-- **Standard-part/tropical support bridge.**  Standard-part observation assigns total mass one
and zero mass to every visible infinitesimal atom, while the corresponding max-plus integral
selects the same reservoir for every observable satisfying the tropical dominance condition. -/
theorem standardPart_tropical_reservoir_bridge (n : ℕ) (M : ℝ) (hM : M < 0)
    (f : Option (Fin n) → ℝ) (hdom : ∀ i, f (some i) + M ≤ f none) :
    (stdPart (prob n Finset.univ) = 1) ∧
    (∀ i : Fin n, stdPart (prob n {some i}) = 0) ∧
    TropicalMeasureTheory.maxPlusIntegral f (reservoirTropicalMeasure n M hM) = f none := by
  refine ⟨stdPart_prob_univ n, ?_, reservoir_maxPlusIntegral_eq n M hM f hdom⟩
  intro i
  exact stdPart_visible_zero n i

/-- The hyperreal epsilon state and the tropical reservoir model share the same normalized
classical support signature: one surviving branch and one erased infinitesimal branch. -/
theorem hyperreal_lexicographic_tropical_signature (n : ℕ) (i : Fin n)
    (M : ℝ) (hM : M < 0) :
    (QuantumSurreal.observedProb QuantumSurreal.psiTest 0 = 1) ∧
    (QuantumSurreal.observedProb QuantumSurreal.psiTest 1 = 0) ∧
    (stdPart (prob n Finset.univ) = 1) ∧
    (stdPart (prob n {some i}) = 0) ∧
    TropicalMeasureTheory.maxPlusIntegral (fun _ : Option (Fin n) => 0)
      (reservoirTropicalMeasure n M hM) = 0 := by
  rcases QuantumSurreal.epsilon_test with ⟨hzero, hepsilon⟩
  refine ⟨hzero, hepsilon, stdPart_prob_univ n, stdPart_visible_zero n i, ?_⟩
  apply reservoir_maxPlusIntegral_eq n M hM
  intro j
  linarith

end TropicalQuantumSurreal