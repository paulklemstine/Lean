import Mathlib

/-!
# Borsuk–Ulam and social aggregation

This file isolates a rigorous one-dimensional topological obstruction behind the
proposed connection with social choice.  A continuous real score on a circle
cannot strictly separate every profile from its antipode.  It also records two
limits of the interpretation: ranked profiles with their discrete topology make
every aggregation rule continuous, and binary majority is a continuous,
unanimous, non-dictatorial rule.
-/

namespace BorsukUlamSocialChoice

open Set
open scoped Real

/-- One-dimensional Borsuk–Ulam: a continuous `2π`-periodic real-valued map
has equal values at some antipodal pair. -/
theorem borsuk_ulam_circle (f : ℝ → ℝ) (hf : Continuous f)
    (hperiodic : ∀ x, f (x + 2 * Real.pi) = f x) :
    ∃ x ∈ Set.Icc (0 : ℝ) Real.pi, f x = f (x + Real.pi) := by
  let g : ℝ → ℝ := fun x => f x - f (x + Real.pi)
  have hg : Continuous g := hf.sub (hf.comp (continuous_id.add continuous_const))
  have hanti : g Real.pi = -g 0 := by
    dsimp [g]
    rw [show Real.pi + Real.pi = 0 + 2 * Real.pi by ring, hperiodic]
    ring_nf
  by_cases hle : g 0 ≤ 0
  · have hge : 0 ≤ g Real.pi := by rw [hanti]; linarith
    obtain ⟨x, hx, hgx⟩ := intermediate_value_Icc Real.pi_pos.le hg.continuousOn
      (show (0 : ℝ) ∈ Set.Icc (g 0) (g Real.pi) from ⟨hle, hge⟩)
    exact ⟨x, hx, sub_eq_zero.mp hgx⟩
  · have hge : g Real.pi ≤ 0 := by rw [hanti]; linarith
    have h0 : 0 ≤ g 0 := le_of_not_ge hle
    obtain ⟨x, hx, hgx⟩ := intermediate_value_Icc' Real.pi_pos.le hg.continuousOn
      (show (0 : ℝ) ∈ Set.Icc (g Real.pi) (g 0) from ⟨hge, h0⟩)
    exact ⟨x, hx, sub_eq_zero.mp hgx⟩

/-- A continuous circular social score cannot assign a strict orientation to
all antipodal profile pairs. -/
theorem no_continuous_strict_antipodal_score (f : ℝ → ℝ) (hf : Continuous f)
    (hperiodic : ∀ x, f (x + 2 * Real.pi) = f x) :
    ¬ ∀ x, f x < f (x + Real.pi) := by
  intro hstrict
  obtain ⟨x, -, hx⟩ := borsuk_ulam_circle f hf hperiodic
  exact (lt_irrefl (f x)) (hx ▸ hstrict x)

/-- In contrapositive form, a periodic score which strictly orders every profile
below its antipode must be discontinuous. -/
theorem strict_antipodal_score_discontinuous (f : ℝ → ℝ)
    (hperiodic : ∀ x, f (x + 2 * Real.pi) = f x)
    (hstrict : ∀ x, f x < f (x + Real.pi)) :
    ¬ Continuous f := by
  intro hf
  exact no_continuous_strict_antipodal_score f hf hperiodic hstrict

/-- Odd reversal symmetry forces a continuous circular social score to be
indifferent at some profile: its value is zero. -/
theorem reversal_symmetric_score_has_zero (f : ℝ → ℝ) (hf : Continuous f)
    (hperiodic : ∀ x, f (x + 2 * Real.pi) = f x)
    (hreversal : ∀ x, f (x + Real.pi) = -f x) :
    ∃ x ∈ Set.Icc (0 : ℝ) Real.pi, f x = 0 := by
  obtain ⟨x, hx, heq⟩ := borsuk_ulam_circle f hf hperiodic
  refine ⟨x, hx, ?_⟩
  rw [hreversal] at heq
  linarith

/-- Consequently, continuity, circular periodicity, reversal symmetry, and
universal decisiveness (`f x ≠ 0`) are mutually inconsistent. -/
theorem topological_social_choice_obstruction (f : ℝ → ℝ)
    (hperiodic : ∀ x, f (x + 2 * Real.pi) = f x)
    (hreversal : ∀ x, f (x + Real.pi) = -f x)
    (hdecisive : ∀ x, f x ≠ 0) :
    ¬ Continuous f := by
  intro hf
  obtain ⟨x, -, hx⟩ := reversal_symmetric_score_has_zero f hf hperiodic hreversal
  exact hdecisive x hx

/-! ## Why this is not Arrow's theorem -/

/-- On a discrete preference space every aggregation rule is continuous.  Thus
continuity alone imposes no restriction on the usual finite set of rankings. -/
theorem every_rule_continuous_on_discrete_profiles
    {Profile Outcome : Type*} [TopologicalSpace Profile] [DiscreteTopology Profile]
    [TopologicalSpace Outcome] (rule : Profile → Outcome) :
    Continuous rule := by
  exact continuous_of_discreteTopology

/-- Strict binary majority for an odd electorate. -/
def majority (n : ℕ) (profile : Fin n → Bool) : Bool :=
  decide (n / 2 < (Finset.univ.filter fun i => profile i = true).card)

/-- Binary majority is unanimous for every nonempty electorate. -/
theorem majority_unanimous (n : ℕ) (hn : 0 < n) (b : Bool) :
    majority n (fun _ => b) = b := by
  cases b
  · simp [majority]
  · simp [majority]
    omega

/-- With three voters, binary majority is not a dictatorship: for each proposed
dictator there is a profile on which the majority differs from that voter. -/
theorem majority_three_not_dictatorial :
    ¬ ∃ i : Fin 3, ∀ profile : Fin 3 → Bool, majority 3 profile = profile i := by
  intro h
  obtain ⟨i, hi⟩ := h
  let profile : Fin 3 → Bool := fun j => decide (j = i)
  have hcard : (Finset.univ.filter fun j => profile j = true).card = 1 := by
    rw [show (Finset.univ.filter fun j => profile j = true) = {i} by
      ext j
      simp [profile]]
    simp
  have hmajority : majority 3 profile = false := by
    simp [majority, hcard]
  have hvoter : profile i = true := by simp [profile]
  have := hi profile
  rw [hmajority, hvoter] at this
  contradiction

/-- The three-voter binary-majority rule is continuous (for the standard
finite/discrete profile topology), unanimous, and non-dictatorial.  This is a
formal counterexample to the unrestricted claim that every continuous social
choice function is dictatorial. -/
theorem continuous_unanimous_nondictatorial_binary_rule :
    ∃ rule : (Fin 3 → Bool) → Bool,
      Continuous rule ∧
      (∀ b, rule (fun _ => b) = b) ∧
      (¬ ∃ i : Fin 3, ∀ profile, rule profile = profile i) := by
  refine ⟨majority 3, continuous_of_discreteTopology, ?_, majority_three_not_dictatorial⟩
  intro b
  exact majority_unanimous 3 (by omega) b

end BorsukUlamSocialChoice