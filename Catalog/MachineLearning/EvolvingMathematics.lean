/-
Copyright (c) 2026. All rights reserved.
Released under Apache 2.0 license.

# Mathematics as an evolving ecosystem

This file gives a precise, deliberately operational model of the metaphor in the
prompt.  A theory profile records measured connectivity, proof density, and
axiom cost.  The labels `ZFC` and `ZFC + large cardinals` carry no numerical
facts by themselves, so the comparison theorem is first stated with the exact
necessary-and-sufficient empirical criterion and then instantiated on a small
illustrative census.
-/

import Mathlib

namespace EvolvingMathematics

/-- Quantitative data attached to a mathematical theory. -/
structure TheoryProfile where
  connections : ℚ
  proofDensity : ℚ
  axiomCount : ℚ
  connections_nonneg : 0 ≤ connections
  proofDensity_nonneg : 0 ≤ proofDensity
  axiomCount_pos : 0 < axiomCount

/-- Fitness is connectivity times proof density, divided by axiom cost. -/
def fitness (T : TheoryProfile) : ℚ :=
  T.connections * T.proofDensity / T.axiomCount

/-
The fitness comparison has a division-free, empirically checkable form.
-/
theorem fitness_lt_iff_cross_product (A B : TheoryProfile) :
    fitness A < fitness B ↔
      A.connections * A.proofDensity * B.axiomCount <
        B.connections * B.proofDensity * A.axiomCount := by
  unfold fitness; rw [ div_lt_div_iff₀ ];
  · exact A.axiomCount_pos;
  · exact B.axiomCount_pos

/-
Equality of fitness is likewise exactly equality of cross-products.
-/
theorem fitness_eq_iff_cross_product (A B : TheoryProfile) :
    fitness A = fitness B ↔
      A.connections * A.proofDensity * B.axiomCount =
        B.connections * B.proofDensity * A.axiomCount := by
  rw [ fitness, fitness, div_eq_div_iff ];
  · exact ne_of_gt A.axiomCount_pos;
  · exact ne_of_gt B.axiomCount_pos

/-
A useful sufficient condition: multiplying connectivity and proof density by
more than the relative axiom-cost increase strictly raises fitness.
-/
theorem fitness_grows_under_multiplicative_advantage
    (A B : TheoryProfile) (growth cost : ℚ)
    (hcost : 0 < cost)
    (hconn : B.connections = growth * A.connections)
    (hdensity : B.proofDensity = A.proofDensity)
    (haxioms : B.axiomCount = cost * A.axiomCount)
    (hApositive : 0 < A.connections * A.proofDensity)
    (hadvantage : cost < growth) :
    fitness A < fitness B := by
  unfold fitness;
  convert mul_lt_mul_of_pos_left hadvantage ( show 0 < A.connections * A.proofDensity / ( A.axiomCount * cost ) by exact div_pos hApositive ( mul_pos A.axiomCount_pos hcost ) ) using 1;
  · rw [ div_mul_eq_mul_div, mul_div_mul_right _ _ hcost.ne' ];
  · grind

/-! ## A concrete census

These rational values are an illustrative operationalization, not claims about
absolute proof-theoretic strength.  They can be replaced by any audited census;
the comparison theorem above says exactly what must then be checked.
-/

/-- Illustrative normalized census for ZFC. -/
def zfcProfile : TheoryProfile where
  connections := 10
  proofDensity := 4
  axiomCount := 9
  connections_nonneg := by norm_num
  proofDensity_nonneg := by norm_num
  axiomCount_pos := by norm_num

/-- Illustrative normalized census for ZFC plus large-cardinal principles. -/
def zfcLargeCardinalProfile : TheoryProfile where
  connections := 14
  proofDensity := 6
  axiomCount := 10
  connections_nonneg := by norm_num
  proofDensity_nonneg := by norm_num
  axiomCount_pos := by norm_num

/-
In the declared census, ZFC plus large cardinals has strictly higher fitness
than ZFC: `40/9 < 42/5`.
-/
theorem zfc_large_cardinals_higher_fitness :
    fitness zfcProfile < fitness zfcLargeCardinalProfile := by
  norm_num [fitness, zfcProfile, zfcLargeCardinalProfile]

/-
The exact fitness gap in the illustrative census is `178/45`.
-/
theorem zfc_large_cardinals_fitness_gap :
    fitness zfcLargeCardinalProfile - fitness zfcProfile = 178 / 45 := by
  norm_num [fitness, zfcProfile, zfcLargeCardinalProfile]

/-! ## Evolution on a finite landscape -/

/-- A global fitness maximum. -/
def IsGlobalMaximum {S : Type*} (F : S → ℚ) (s : S) : Prop :=
  ∀ t, F t ≤ F s

/-- An evolutionary landscape equipped with a natural-valued Lyapunov distance.
The axioms say that every nonstationary update improves fitness and decreases
its distance, and that stationary species are exactly global maxima. -/
structure Landscape (S : Type*) where
  profile : S → TheoryProfile
  evolve : S → S
  distance : S → ℕ
  distance_zero_iff_fixed : ∀ s, distance s = 0 ↔ evolve s = s
  distance_decreases : ∀ s, evolve s ≠ s → distance (evolve s) < distance s
  fitness_increases : ∀ s, evolve s ≠ s → fitness (profile s) < fitness (profile (evolve s))
  maximum_iff_fixed : ∀ s, IsGlobalMaximum (fun t => fitness (profile t)) s ↔ evolve s = s

/-
Once evolution reaches a fixed species, every later iterate is fixed there.
-/
theorem iterate_eq_of_fixed {S : Type*} (L : Landscape S) {s : S}
    (hs : L.evolve s = s) (n : ℕ) : L.evolve^[n] s = s := by
  exact Function.iterate_fixed hs n

/-
The Lyapunov distance bounds the number of evolutionary updates needed to
reach a fixed point.
-/
theorem evolves_to_fixed {S : Type*} (L : Landscape S) (s : S) :
    L.evolve (L.evolve^[L.distance s] s) = L.evolve^[L.distance s] s := by
  -- By induction on $n$, we show that $L.distance (L.evolve^[n] s) \leq L.distance s - n$.
  have h_ind : ∀ n ≤ L.distance s, L.distance (L.evolve^[n] s) ≤ L.distance s - n := by
    intro n hn
    induction' n with n ih
    · simp
    ·
      by_cases h : L.evolve ( L.evolve^[n] s ) = L.evolve^[n] s <;> simp_all +decide [ Function.iterate_succ_apply' ];
      · have := L.distance_zero_iff_fixed ( L.evolve^[n] s ) ; aesop;
      · exact Nat.le_sub_one_of_lt ( lt_of_lt_of_le ( L.distance_decreases _ h ) ( ih hn.le ) );
  grind +suggestions

/-
Consequently every initial theory reaches a global fitness maximum within
its Lyapunov distance.
-/
theorem evolves_to_global_maximum {S : Type*} (L : Landscape S) (s : S) :
    IsGlobalMaximum (fun t => fitness (L.profile t))
      (L.evolve^[L.distance s] s) := by
  apply (L.maximum_iff_fixed _).2
  exact evolves_to_fixed L s

/-
Before stabilization, each individual evolutionary step strictly raises
fitness.
-/
theorem fitness_strictly_increases_before_fixed {S : Type*} (L : Landscape S)
    (s : S) (h : L.evolve s ≠ s) :
    fitness (L.profile s) < fitness (L.profile (L.evolve s)) := by
  exact L.fitness_increases s h

/-! ## Competitive exclusion

Competitive exclusion is not a consequence of the scalar fitness formula alone:
two distinct profiles can have equal fitness.  The following certified
counterexample makes this obstruction explicit. -/

private def equalFitnessProfileA : TheoryProfile where
  connections := 1
  proofDensity := 2
  axiomCount := 1
  connections_nonneg := by norm_num
  proofDensity_nonneg := by norm_num
  axiomCount_pos := by norm_num

private def equalFitnessProfileB : TheoryProfile where
  connections := 2
  proofDensity := 1
  axiomCount := 1
  connections_nonneg := by norm_num
  proofDensity_nonneg := by norm_num
  axiomCount_pos := by norm_num

/-
Scalar fitness alone does not identify a unique niche: distinct theory
profiles can have exactly equal fitness.
-/
theorem equal_fitness_does_not_imply_equal_profile :
    equalFitnessProfileA ≠ equalFitnessProfileB ∧
      fitness equalFitnessProfileA = fitness equalFitnessProfileB := by
  exact ⟨ by rintro ⟨ ⟩, by unfold fitness; unfold equalFitnessProfileA; unfold equalFitnessProfileB; norm_num ⟩

/-! Competitive exclusion is therefore modeled as an additional, explicit
resource-allocation rule assigning at most one occupant to each niche. -/

/-- A niche allocation records its (optional) unique occupant. -/
structure NicheAllocation (N S : Type*) where
  occupant : N → Option S

/-- Species `s` occupies niche `n`. -/
def Occupies {N S : Type*} (E : NicheAllocation N S) (s : S) (n : N) : Prop :=
  E.occupant n = some s

/-
Competitive exclusion: two occupants of one niche must be the same species.
-/
theorem competitive_exclusion {N S : Type*} (E : NicheAllocation N S)
    {n : N} {s t : S} (hs : Occupies E s n) (ht : Occupies E t n) : s = t := by
  exact Option.some_inj.mp ( hs.symm.trans ht )

/-
Distinct species necessarily occupy distinct niches whenever both do occupy
some niche.
-/
theorem distinct_species_exclude_shared_niche {N S : Type*}
    (E : NicheAllocation N S) {s t : S} (hst : s ≠ t) :
    ¬ ∃ n, Occupies E s n ∧ Occupies E t n := by
  exact fun ⟨ n, hs, ht ⟩ => hst <| competitive_exclusion E hs ht

end EvolvingMathematics