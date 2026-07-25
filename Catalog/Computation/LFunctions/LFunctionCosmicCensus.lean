/-
# A rigorous census boundary for L-functions

This study separates two assertions that are often conflated: a countable arithmetic
parameter space does yield a countable family of analytic functions, whereas finitely
many initial Euler or Dirichlet coefficients do not determine an arbitrary convergent
Dirichlet series.  The positive census theorem is therefore conditional on a faithful
countable code; the negative theorem exhibits explicit analytic witnesses against any
finite-prefix classification.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Six falsifiable targets were ranked by impact. (1, open-problem
category) the Selberg class admits a faithful countable arithmetic code; (2, cross-domain)
analytic Dirichlet L-functions are faithfully indexed at each fixed modulus; (3,
cross-domain) no finite coefficient prefix classifies all bounded convergent Dirichlet
series; (4, open-problem category) bounded conductor and degree give finite Selberg-class
fibres; (5, cross-domain) any family injecting into finite rational arithmetic packets is
countable; (6, open-problem category) primitive Selberg-class counting has polynomial
growth in the conductor.

Experiment (Experimenter): Target (3) was tested with two monomial Dirichlet series whose
sole nonzero coefficients occur beyond an arbitrary cutoff.  Analytic uniqueness proves
their L-series differ.  Target (5) was reduced to an explicit dependent injection into a
countable packet type.  Existing character rigidity and finite character groups settle
target (2).

Analysis (Analyst): Targets (2), (3), and (5) survive.  Targets (1), (4), and (6) remain
conjectural: the Selberg axioms do not presently supply the proposed finite determining
packet.  In particular, analytic rigidity uses the entire coefficient sequence, not a
finite list of Euler factors.  Elliptic curves over the rationals also form a countable,
not uncountable, family; arbitrary complex j-invariants do not all define arithmetic
L-functions over the rationals.

Critique (Critic): The finite-data premise was challenged rather than assumed.  The main
negative result quantifies over every cutoff and uses bounded, normalized coefficient
sequences with genuine convergent L-series.  The positive result explicitly requires
injectivity of the code, preventing a vacuous claim that metadata alone determines an
L-function.  No list is advertised as the first hundred Selberg-class members, because
no classification or tie-breaking theorem justifies such a list.

Synthesis (Principal Investigator): The resulting boundary theorem combines computation
(finite observation), analysis (Dirichlet-series uniqueness), arithmetic (Dirichlet
characters), and set theory (countable coding).  It identifies the exact missing bridge
for a cosmic census: a faithful arithmetic code, not merely finitely many local samples.
-- !-- End Lab Notes -- !--
-/

import Novelty.LFunctions.AnalyticCensus
import NumberTheory.Langlands.HeckeFactorization

open LSeries Complex

namespace LFunctionCosmicCensus

open AnalyticLFunctionCensus

/-- Two coefficient sequences agree through a finite observational cutoff. -/
def AgreeThrough (N : ℕ) (f g : ℕ → ℂ) : Prop :=
  ∀ n, n ≤ N → f n = g n

/-
Beyond every finite cutoff there are two normalized, bounded coefficient sequences
that agree on all observed coefficients but define distinct analytic Dirichlet series.
-/
theorem finite_prefix_ambiguity (N : ℕ) :
    ∃ f g : ℕ → ℂ,
      f 0 = 0 ∧ g 0 = 0 ∧
      (∀ n, n ≠ 0 → ‖f n‖ ≤ 1) ∧
      (∀ n, n ≠ 0 → ‖g n‖ ≤ 1) ∧
      AgreeThrough N f g ∧ LSeries f ≠ LSeries g := by
  use fun n => if n = N + 1 then 1 else 0, fun n => if n = N + 2 then 1 else 0;
  refine' ⟨ by aesop, by aesop, _, _, _, _ ⟩ <;> norm_num;
  · aesop;
  · aesop;
  · intro n hn; aesop;
  · exact AnalyticLFunctionCensus.spikeLSeries_injective.ne ( by aesop )

/-
There is no universal finite-prefix classifier for normalized bounded Dirichlet
series.  Thus finitely many Euler-style observations cannot by themselves prove a
census theorem for a class governed only by analytic convergence.
-/
theorem no_universal_finite_prefix_classifier :
    ¬ ∃ N : ℕ, ∀ f g : ℕ → ℂ,
      f 0 = 0 → g 0 = 0 →
      (∀ n, n ≠ 0 → ‖f n‖ ≤ 1) →
      (∀ n, n ≠ 0 → ‖g n‖ ≤ 1) →
      AgreeThrough N f g → LSeries f = LSeries g := by
  intro hN
  obtain ⟨N, hN⟩ := hN
  obtain ⟨f, g, hf0, hg0, hf_bound, hg_bound, h_agree, h_ne⟩ := finite_prefix_ambiguity N
  exact absurd (hN f g hf0 hg0 hf_bound hg_bound h_agree) (by simp [h_ne])

/-- A finite arithmetic packet records discrete global invariants and finitely many
rational local factors.  Its fields are intentionally discrete; allowing an arbitrary
complex root number would destroy the immediate countability argument. -/
structure ArithmeticPacket where
  degree : ℕ
  conductor : ℕ
  rootSign : Bool
  gammaShifts : List ℚ
  exceptionalEulerFactors : List (ℕ × List ℚ)
  deriving DecidableEq, Countable

/-
A family carrying a faithful arithmetic-packet code is countable.  This is the
precise conditional form of the proposed finite-data census argument.
-/
theorem countable_of_faithful_arithmetic_packet
    {ι : Type*} (packet : ι → ArithmeticPacket) (faithful : Function.Injective packet) :
    Countable ι := by
  exact Function.Injective.countable faithful

/-- The actual analytic Dirichlet L-functions, over all moduli, form a countable set. -/
theorem analytic_dirichlet_census_countable :
    (Set.range analyticDirichletFamily).Countable := by
  exact analyticDirichletUniverse_countable

/-- At fixed nonzero modulus, the arithmetic-to-analytic map is both faithful and has
finite image.  This is an unconditional finite conductor slice of the census. -/
theorem fixed_modulus_faithful_and_finite {N : ℕ} [NeZero N] :
    Function.Injective
        (fun χ : DirichletCharacter ℂ N => LSeries (charCoeff χ)) ∧
      (Set.range (fun χ : DirichletCharacter ℂ N =>
        LSeries (charCoeff χ))).Finite := by
  constructor
  · exact charLSeries_injOn_fixedMod
  · exact charLSeries_finite_fixedMod

/-
Coprime conductor factorization gives a multiplicative census of degree-one
arithmetic characters, linking the analytic census with the Chinese remainder theorem.
-/
theorem coprime_character_census_multiplicative
    (m k : ℕ) [NeZero m] [NeZero k] (h : m.Coprime k) :
    Nat.card (DirichletCharacter ℂ (m * k)) =
      Nat.card (DirichletCharacter ℂ m) * Nat.card (DirichletCharacter ℂ k) := by
  have h_iso : Nonempty (DirichletCharacter ℂ (m * k) ≃* DirichletCharacter ℂ m × DirichletCharacter ℂ k) := by
    exact ⟨ HeckeFactorization.heckeFactorization m k h ⟩;
  simpa using Nat.card_congr h_iso.some.toEquiv

end LFunctionCosmicCensus