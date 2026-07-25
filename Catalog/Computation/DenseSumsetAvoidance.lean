import Mathlib
import Logic.TFoldSumsetAvoidance

/-!
# Finite first-moment bounds for dense sets without large sumsets

For a finite ambient set `U`, this file counts subsets of `U` containing a fixed
configuration and combines those counts by a finite union bound.  The resulting
criterion simultaneously enforces a lower bound on the size of the chosen set
and exclusion of every sumset in a prescribed finite family.

The argument isolates the finite probabilistic kernel used in the study of dense
sets without large sumsets: a fixed `T ⊆ U` is contained in exactly
`2^(|U|-|T|)` subsets of `U`.  Consequently, the total number of sets containing
one of a family of configurations is bounded by the sum of these powers.
The sharp integer sumset-growth theorem from `Logic.TFoldSumsetAvoidance` then
turns lower bounds on the two summands into a uniform exponent.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The random-set argument should first be separated
from structural additive combinatorics.  For any finite family of forbidden
sets, exact counting plus a union bound ought to give a deterministic existence
criterion that also permits an arbitrary density threshold.

Experiment (Experimenter): Small universes were enumerated.  A fixed set of
size `t` inside an `N`-element universe occurred in `2^(N-t)` subsets.  The union
bound was often strict because one subset can contain several forbidden
configurations.  For integer sumsets, replacing the true sumset cardinality by
`|A|+|B|-1` gave the predicted uniform upper bound.

Analysis (Analyst): Two independent costs compete: subsets below the requested
density threshold, and subsets containing a forbidden sumset.  If their counts
sum to less than `2^|U|`, a set outside both classes exists.  This formulation
makes no independence assumptions and exposes exactly where stronger structural
counting of candidate pairs is required for logarithmic thresholds.

Critique (Critic): Avoidance alone would admit the empty set and hence be
vacuous for density questions.  The main criterion explicitly counts all sets
below a supplied cardinality threshold.  The additive corollary requires both
summands to be nonempty; without this condition the sharp `|A+B|` lower bound
is false.  Overlaps among bad events only improve the estimate, so no hidden
disjointness assumption is made.

Synthesis (Principal Investigator): Exact containment counting, a finite union
bound, and sharp torsion-free sumset growth combine into a reusable bridge from
additive structure to dense avoidance.  The remaining asymptotic challenge is
to replace the raw number of candidate pairs by structural fingerprints.
-- !-- Lab Notes -- !--
-/

open Finset Pointwise

namespace DenseSumsetAvoidance

/-- Subsets of `U` whose cardinality is below `d`. -/
noncomputable def smallSubsets (U : Finset α) (d : ℕ) : Finset (Finset α) := by
  classical
  exact U.powerset.filter (fun S => S.card < d)

/-- Subsets of `U` which contain at least one member of the forbidden family. -/
noncomputable def badSubsets (U : Finset α) (F : Finset (Finset α)) : Finset (Finset α) := by
  classical
  exact U.powerset.filter (fun S => ∃ T ∈ F, T ⊆ S)

/-- A fixed `T ⊆ U` is contained in exactly `2^(|U|-|T|)` subsets of `U`. -/
theorem card_supersets_eq_pow [DecidableEq α] (U T : Finset α) (hTU : T ⊆ U) :
    (U.powerset.filter (fun S => T ⊆ S)).card = 2 ^ (U.card - T.card) := by
  rw [show U.powerset.filter (fun S => T ⊆ S) = Finset.Icc T U by
    ext S
    simp [Finset.mem_Icc, and_comm]]
  exact Finset.card_Icc_finset hTU

/-- Finite union bound for containment events. -/
theorem card_badSubsets_le_sum [DecidableEq α] (U : Finset α) (F : Finset (Finset α))
    (hF : ∀ T ∈ F, T ⊆ U) :
    (badSubsets U F).card ≤ ∑ T ∈ F, 2 ^ (U.card - T.card) := by
  classical
  have hsub : badSubsets U F ⊆ F.biUnion (fun T => U.powerset.filter (fun S => T ⊆ S)) := by
    intro S hS
    simp only [badSubsets, Finset.mem_filter, Finset.mem_powerset] at hS
    obtain ⟨hSU, T, hTF, hTS⟩ := hS
    exact Finset.mem_biUnion.mpr ⟨T, hTF, by simp [hSU, hTS]⟩
  calc
    (badSubsets U F).card ≤ (F.biUnion (fun T => U.powerset.filter (fun S => T ⊆ S))).card :=
      Finset.card_le_card hsub
    _ ≤ ∑ T ∈ F, (U.powerset.filter (fun S => T ⊆ S)).card := Finset.card_biUnion_le
    _ = ∑ T ∈ F, 2 ^ (U.card - T.card) := by
      apply Finset.sum_congr rfl
      intro T hTF
      exact card_supersets_eq_pow U T (hF T hTF)

/-- **Dense finite avoidance criterion.** If the number of subsets below the
cardinality threshold plus the union-bound cost of all forbidden configurations
is smaller than the full powerset, then some subset has size at least `d` and
contains none of the forbidden configurations. -/
theorem exists_dense_avoiding [DecidableEq α] (U : Finset α) (F : Finset (Finset α))
    (d : ℕ) (hF : ∀ T ∈ F, T ⊆ U)
    (hcount : (smallSubsets U d).card + (∑ T ∈ F, 2 ^ (U.card - T.card)) < 2 ^ U.card) :
    ∃ S ⊆ U, d ≤ S.card ∧ ∀ T ∈ F, ¬ T ⊆ S := by
  classical
  have hbad := card_badSubsets_le_sum U F hF
  have hunion : (smallSubsets U d ∪ badSubsets U F).card < U.powerset.card := by
    rw [Finset.card_powerset]
    exact lt_of_le_of_lt (Finset.card_union_le _ _) (lt_of_le_of_lt (Nat.add_le_add_left hbad _) hcount)
  have hnsub : ¬ U.powerset ⊆ smallSubsets U d ∪ badSubsets U F := by
    intro hsub
    exact (not_le_of_gt hunion) (Finset.card_le_card hsub)
  have hex : ∃ S ∈ U.powerset, S ∉ smallSubsets U d ∪ badSubsets U F := by
    by_contra h
    apply hnsub
    intro S hS
    by_contra hmem
    exact h ⟨S, hS, hmem⟩
  obtain ⟨S, hSU, hnotunion⟩ := hex
  have hsmall : S ∉ smallSubsets U d := fun h => hnotunion (Finset.mem_union_left _ h)
  have hbadS : S ∉ badSubsets U F := fun h => hnotunion (Finset.mem_union_right _ h)
  refine ⟨S, (Finset.mem_powerset.mp hSU), ?_, ?_⟩
  · have h := hsmall
    simp only [smallSubsets, Finset.mem_filter, Finset.mem_powerset, not_and] at h
    exact Nat.le_of_not_gt (h (Finset.mem_powerset.mp hSU))
  · intro T hTF hTS
    apply hbadS
    simp only [badSubsets, Finset.mem_filter, Finset.mem_powerset]
    exact ⟨Finset.mem_powerset.mp hSU, T, hTF, hTS⟩

/-- The family of sumsets generated by a finite family of pairs. -/
noncomputable def sumsetFamily (P : Finset (Finset ℤ × Finset ℤ)) : Finset (Finset ℤ) := by
  classical
  exact P.image (fun p => p.1 + p.2)

/-- Every nonempty pair of integer sets of size at least `k` has a sumset of
size at least `2k-1`, in subtraction-free form.  This is the additive input to
the counting argument. -/
theorem two_mul_k_le_sumset_card_add_one (A B : Finset ℤ)
    (hA : A.Nonempty) (hB : B.Nonempty) (hkA : k ≤ A.card) (hkB : k ≤ B.card) :
    2 * k ≤ (A + B).card + 1 := by
  have hsum := cauchy_davenport_of_isAddTorsionFree hA hB
  omega

/-- Uniformly bounding every forbidden sumset by sharp integer sumset growth
bounds the complete first-moment cost by one common power of two. -/
theorem sum_sumset_cost_le [DecidableEq (Finset ℤ × Finset ℤ)]
    (U : Finset ℤ) (P : Finset (Finset ℤ × Finset ℤ)) (k : ℕ)
    (hP : ∀ p ∈ P, p.1.Nonempty ∧ p.2.Nonempty ∧ k ≤ p.1.card ∧ k ≤ p.2.card) :
    (∑ p ∈ P, 2 ^ (U.card - (p.1 + p.2).card))
      ≤ P.card * 2 ^ (U.card - (2 * k - 1)) := by
  calc
    (∑ p ∈ P, 2 ^ (U.card - (p.1 + p.2).card))
        ≤ ∑ _p ∈ P, 2 ^ (U.card - (2 * k - 1)) := by
      apply Finset.sum_le_sum
      intro p hp
      have hgrowth := two_mul_k_le_sumset_card_add_one p.1 p.2
        (hP p hp).1 (hP p hp).2.1 (hP p hp).2.2.1 (hP p hp).2.2.2
      apply Nat.pow_le_pow_right (by omega)
      have hlower : 2 * k - 1 ≤ (p.1 + p.2).card := by omega
      exact Nat.sub_le_sub_left hlower U.card
    _ = P.card * 2 ^ (U.card - (2 * k - 1)) := by
      simp [mul_comm]

/-- **Additive dense-avoidance theorem.** A cardinality-tail estimate and the
uniform first-moment estimate together produce a dense subset of `U` containing
none of the sumsets generated by `P`. -/
theorem exists_dense_without_prescribed_sumsets
    (U : Finset ℤ) (P : Finset (Finset ℤ × Finset ℤ)) (d k : ℕ)
    (hinside : ∀ p ∈ P, p.1 + p.2 ⊆ U)
    (hlarge : ∀ p ∈ P, p.1.Nonempty ∧ p.2.Nonempty ∧ k ≤ p.1.card ∧ k ≤ p.2.card)
    (hcount : (smallSubsets U d).card + P.card * 2 ^ (U.card - (2 * k - 1)) < 2 ^ U.card) :
    ∃ S ⊆ U, d ≤ S.card ∧ ∀ p ∈ P, ¬ p.1 + p.2 ⊆ S := by
  classical
  let F := sumsetFamily P
  have hFinside : ∀ T ∈ F, T ⊆ U := by
    intro T hT
    simp only [F, sumsetFamily, Finset.mem_image] at hT
    obtain ⟨p, hp, rfl⟩ := hT
    exact hinside p hp
  have hcost : (∑ T ∈ F, 2 ^ (U.card - T.card))
      ≤ P.card * 2 ^ (U.card - (2 * k - 1)) := by
    calc
      (∑ T ∈ F, 2 ^ (U.card - T.card))
          ≤ ∑ p ∈ P, 2 ^ (U.card - (p.1 + p.2).card) := by
        simpa [F, sumsetFamily] using
          (Finset.sum_image_le_of_nonneg (s := P)
            (g := fun p : Finset ℤ × Finset ℤ => p.1 + p.2)
            (f := fun T : Finset ℤ => 2 ^ (U.card - T.card)) (fun _ _ => Nat.zero_le _))
      _ ≤ P.card * 2 ^ (U.card - (2 * k - 1)) := sum_sumset_cost_le U P k hlarge
  have hcount' : (smallSubsets U d).card + (∑ T ∈ F, 2 ^ (U.card - T.card)) < 2 ^ U.card :=
    lt_of_le_of_lt (Nat.add_le_add_left hcost _) hcount
  obtain ⟨S, hSU, hdS, havoid⟩ := exists_dense_avoiding U F d hFinside hcount'
  refine ⟨S, hSU, hdS, ?_⟩
  intro p hp hsub
  apply havoid (p.1 + p.2) ?_ hsub
  simp only [F, sumsetFamily, Finset.mem_image]
  exact ⟨p, hp, rfl⟩

end DenseSumsetAvoidance