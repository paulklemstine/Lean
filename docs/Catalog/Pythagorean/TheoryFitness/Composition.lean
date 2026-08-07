/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# The multiplicative-reuse phase transition

Composing two developments pools their dependency closures, so a dependency used
by both is charged once instead of twice; but composition also costs an
**adapter layer** `A` reconciling the two interfaces.  This file proves that the
resulting fitness change is governed by an exact threshold:

* `compose_gain_iff_adapter_lt_shared` : composition strictly increases fitness
  **iff** the adapter cost is strictly below the shared dependency mass, with the
  matching `=` and `>` cases (`compose_neutral_iff`, `compose_loss_iff`);
* `compose_gain_iff_density` : the same threshold in normalised *density* form,
  `adapterDensity < dependencyDensity`;
* `multiplicative_gain_iff` and `multiplicative_gain_of_large_corpus` : when the
  composite proves a *product* corpus, multiplicative growth of the corpus
  eventually beats the additive growth of cost, whatever the adapter charge;
* `phaseTransitionUp` / `phaseTransitionDown` : a fully computed instance
  exhibiting both phases across the threshold.
-/

import Pythagorean.TheoryFitness.Core

namespace TheoryFitness

open Finset

/-- Dependency mass shared by two developments: declarations occurring in both
transitive closures, charged once. -/
def sharedMass (ℓ : ℕ → ℕ) (T U : Theory) : ℕ := ∑ i ∈ T.closure ∩ U.closure, ℓ i

/-- Cost of the composite: the pooled closure plus an adapter layer. -/
def composeCost (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ) : ℕ := cost ℓ (merge T U) + A

/-- Cost of keeping the two developments separate: every shared dependency is
paid for twice. -/
def duplicateCost (ℓ : ℕ → ℕ) (T U : Theory) : ℕ := cost ℓ T + cost ℓ U

theorem composeCost_add_sharedMass (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ) :
    composeCost ℓ T U A + sharedMass ℓ T U = duplicateCost ℓ T U + A := by
  have h := cost_merge_add_cost_inter ℓ T U
  simp only [composeCost, duplicateCost, sharedMass]
  omega

/-- Fitness of the composite development. -/
def composedFitness (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ) : ℚ :=
  ((merge T U).proves.card : ℚ) / (composeCost ℓ T U A : ℚ)

/-- Fitness of the same corpus proved by two separate, duplicating
developments. -/
def duplicatedFitness (ℓ : ℕ → ℕ) (T U : Theory) : ℚ :=
  ((merge T U).proves.card : ℚ) / (duplicateCost ℓ T U : ℚ)

/-! ### The exact threshold -/

/-- **Phase transition, strict gain.**  Composition strictly increases fitness
exactly when the adapter layer is cheaper than the duplicated dependency mass it
removes. -/
theorem compose_gain_iff_adapter_lt_shared (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ)
    (hn : 0 < (merge T U).proves.card) (hdup : 0 < duplicateCost ℓ T U)
    (hcomp : 0 < composeCost ℓ T U A) :
    duplicatedFitness ℓ T U < composedFitness ℓ T U A ↔ A < sharedMass ℓ T U := by
  have hnQ : (0 : ℚ) < ((merge T U).proves.card : ℚ) := by exact_mod_cast hn
  have hdQ : (0 : ℚ) < (duplicateCost ℓ T U : ℚ) := by exact_mod_cast hdup
  have hcQ : (0 : ℚ) < (composeCost ℓ T U A : ℚ) := by exact_mod_cast hcomp
  have hkey := composeCost_add_sharedMass ℓ T U A
  unfold duplicatedFitness composedFitness
  rw [div_lt_div_iff_of_pos_left hnQ hdQ hcQ]
  constructor
  · intro h
    have : composeCost ℓ T U A < duplicateCost ℓ T U := by exact_mod_cast h
    omega
  · intro h
    have : composeCost ℓ T U A < duplicateCost ℓ T U := by omega
    exact_mod_cast this

/-- At the threshold, composition is fitness-neutral. -/
theorem compose_neutral_iff (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ)
    (hn : 0 < (merge T U).proves.card) (hdup : 0 < duplicateCost ℓ T U)
    (hcomp : 0 < composeCost ℓ T U A) :
    duplicatedFitness ℓ T U = composedFitness ℓ T U A ↔ A = sharedMass ℓ T U := by
  have hnQ : (0 : ℚ) < ((merge T U).proves.card : ℚ) := by exact_mod_cast hn
  have hdQ : (0 : ℚ) < (duplicateCost ℓ T U : ℚ) := by exact_mod_cast hdup
  have hcQ : (0 : ℚ) < (composeCost ℓ T U A : ℚ) := by exact_mod_cast hcomp
  have hkey := composeCost_add_sharedMass ℓ T U A
  unfold duplicatedFitness composedFitness
  rw [div_eq_div_iff (ne_of_gt hdQ) (ne_of_gt hcQ)]
  constructor
  · intro h
    have h' : (composeCost ℓ T U A : ℚ) = (duplicateCost ℓ T U : ℚ) := by
      have := mul_left_cancel₀ (ne_of_gt hnQ) h
      linarith [this]
    have : composeCost ℓ T U A = duplicateCost ℓ T U := by exact_mod_cast h'
    omega
  · intro h
    have : composeCost ℓ T U A = duplicateCost ℓ T U := by omega
    rw [this]

/-- Above the threshold, composition strictly decreases fitness: an expensive
adapter destroys the benefit of reuse. -/
theorem compose_loss_iff (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ)
    (hn : 0 < (merge T U).proves.card) (hdup : 0 < duplicateCost ℓ T U)
    (hcomp : 0 < composeCost ℓ T U A) :
    composedFitness ℓ T U A < duplicatedFitness ℓ T U ↔ sharedMass ℓ T U < A := by
  have hnQ : (0 : ℚ) < ((merge T U).proves.card : ℚ) := by exact_mod_cast hn
  have hdQ : (0 : ℚ) < (duplicateCost ℓ T U : ℚ) := by exact_mod_cast hdup
  have hcQ : (0 : ℚ) < (composeCost ℓ T U A : ℚ) := by exact_mod_cast hcomp
  have hkey := composeCost_add_sharedMass ℓ T U A
  unfold duplicatedFitness composedFitness
  rw [div_lt_div_iff_of_pos_left hnQ hcQ hdQ]
  constructor
  · intro h
    have : duplicateCost ℓ T U < composeCost ℓ T U A := by exact_mod_cast h
    omega
  · intro h
    have : duplicateCost ℓ T U < composeCost ℓ T U A := by omega
    exact_mod_cast this

/-! ### Normalised (density) form of the threshold -/

/-- Fraction of the duplicated cost that is shared dependency mass. -/
def dependencyDensity (ℓ : ℕ → ℕ) (T U : Theory) : ℚ :=
  (sharedMass ℓ T U : ℚ) / (duplicateCost ℓ T U : ℚ)

/-- Adapter cost as a fraction of the duplicated cost. -/
def adapterDensity (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ) : ℚ :=
  (A : ℚ) / (duplicateCost ℓ T U : ℚ)

/-- **Threshold in density form.**  There is a critical dependency density,
namely the adapter density, above which composition pays and below which it does
not.  Both quantities are directly measurable on a corpus. -/
theorem compose_gain_iff_density (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ)
    (hn : 0 < (merge T U).proves.card) (hdup : 0 < duplicateCost ℓ T U)
    (hcomp : 0 < composeCost ℓ T U A) :
    duplicatedFitness ℓ T U < composedFitness ℓ T U A ↔
      adapterDensity ℓ T U A < dependencyDensity ℓ T U := by
  have hdQ : (0 : ℚ) < (duplicateCost ℓ T U : ℚ) := by exact_mod_cast hdup
  rw [compose_gain_iff_adapter_lt_shared ℓ T U A hn hdup hcomp]
  unfold adapterDensity dependencyDensity
  rw [div_lt_div_iff_of_pos_right hdQ]
  exact_mod_cast Iff.rfl

/-! ### Multiplicative candidate populations -/

/-- Fitness of a composite whose corpus is the *product* of the two component
corpora: independent candidate populations multiply. -/
def productFitness (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ) : ℚ :=
  ((T.proves.card * U.proves.card : ℕ) : ℚ) / (composeCost ℓ T U A : ℚ)

/-- Fitness of a single component. -/
theorem fitness_eq (ℓ : ℕ → ℕ) (T : Theory) :
    fitness ℓ T = (T.proves.card : ℚ) / (cost ℓ T : ℚ) := rfl

/-- **Multiplicative reuse criterion.**  With a product corpus, the composite
beats its first component exactly when the second component's corpus is larger
than the cost ratio.  Costs add (at worst), candidates multiply. -/
theorem multiplicative_gain_iff (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ)
    (hT : 0 < cost ℓ T) (hcomp : 0 < composeCost ℓ T U A) :
    fitness ℓ T < productFitness ℓ T U A ↔
      T.proves.card * composeCost ℓ T U A
        < T.proves.card * U.proves.card * cost ℓ T := by
  have hTQ : (0 : ℚ) < (cost ℓ T : ℚ) := by exact_mod_cast hT
  have hcQ : (0 : ℚ) < (composeCost ℓ T U A : ℚ) := by exact_mod_cast hcomp
  unfold fitness productFitness
  rw [div_lt_div_iff₀ hTQ hcQ]
  exact_mod_cast Iff.rfl

/-- **Multiplicative growth eventually beats additive cost.**  Since the
composite cost is at most `cost T + cost U + A` while the candidate population
multiplies, any second component with a sufficiently large corpus makes
composition profitable, whatever the adapter charge. -/
theorem multiplicative_gain_of_large_corpus (ℓ : ℕ → ℕ) (T U : Theory) (A : ℕ)
    (hT : 0 < cost ℓ T) (hn : 0 < T.proves.card)
    (hcomp : 0 < composeCost ℓ T U A)
    (hbig : cost ℓ T + cost ℓ U + A < cost ℓ T * U.proves.card) :
    fitness ℓ T < productFitness ℓ T U A := by
  have hle : composeCost ℓ T U A ≤ cost ℓ T + cost ℓ U + A := by
    have := cost_merge_le ℓ T U
    simp only [composeCost]
    omega
  rw [multiplicative_gain_iff ℓ T U A hT hcomp]
  calc T.proves.card * composeCost ℓ T U A
      ≤ T.proves.card * (cost ℓ T + cost ℓ U + A) :=
        Nat.mul_le_mul_left _ hle
    _ < T.proves.card * (cost ℓ T * U.proves.card) :=
        (Nat.mul_lt_mul_left hn).2 hbig
    _ = T.proves.card * U.proves.card * cost ℓ T := by ring

/-! ### A computed instance of the phase transition

Two developments of four declarations each, sharing two of them, all
declarations of source length `10`.  Duplicated cost is `80`, pooled cost `60`,
so the shared mass is `20`: the transition sits exactly at adapter cost `20`. -/

/-- Uniform source length. -/
def uniformLen : ℕ → ℕ := fun _ => 10

/-- First library: declarations `0,1,2,3`, proving statements `0,1`. -/
def libA : Theory where
  closure := {0, 1, 2, 3}
  proves := {0, 1}

/-- Second library: declarations `2,3,4,5`, proving statements `2,3`. -/
def libB : Theory where
  closure := {2, 3, 4, 5}
  proves := {2, 3}

theorem sharedMass_libs : sharedMass uniformLen libA libB = 20 := by
  decide

theorem duplicateCost_libs : duplicateCost uniformLen libA libB = 80 := by
  decide

/-- Below the threshold (`A = 10 < 20`) composition strictly increases fitness:
`4/80 < 4/70`. -/
theorem phaseTransitionUp :
    duplicatedFitness uniformLen libA libB
      < composedFitness uniformLen libA libB 10 := by
  rw [compose_gain_iff_adapter_lt_shared _ _ _ _ (by decide) (by decide) (by decide)]
  decide

/-- Above the threshold (`A = 30 > 20`) composition strictly decreases fitness:
`4/90 < 4/80`. -/
theorem phaseTransitionDown :
    composedFitness uniformLen libA libB 30
      < duplicatedFitness uniformLen libA libB := by
  rw [compose_loss_iff _ _ _ _ (by decide) (by decide) (by decide)]
  decide

/-- Exactly at the threshold composition is fitness-neutral. -/
theorem phaseTransitionCritical :
    duplicatedFitness uniformLen libA libB
      = composedFitness uniformLen libA libB 20 := by
  rw [compose_neutral_iff _ _ _ _ (by decide) (by decide) (by decide)]
  decide

end TheoryFitness