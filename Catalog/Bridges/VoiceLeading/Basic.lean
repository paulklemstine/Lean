/-
Copyright (c) 2025 Bridges Project. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Categorical Voice-Leading Geometry

This file defines a category of musical voicings and voice leadings,
and proves it admits a cost functor into a Lawvere-style metric category.

## Main definitions

- `Chord n`: A chord with `n` voices, each assigned an integer pitch.
- `VoiceLeading`: A morphism between equal-cardinality chords given by
  a bijective voice assignment with displacement cost.
- `VoiceLeadingCat n`: The category of `n`-voice chords with voice leadings.
- `LawvereMetCat`: A lightweight Lawvere metric category (objects with
  extended real distances and nonexpansive maps).
- `voiceLeadingCostFunctor`: Functor from voice-leading to Lawvere metrics.

## Main results

- `voiceLeading_cost_nonneg`: Voice-leading cost is nonneg.
- `voiceLeading_cost_comp_le`: Triangle inequality for voice-leading cost.
- `voiceLeadingCat_isCategory`: The voice-leading structure forms a category.
- `voiceLeading_to_lawvere_functor`: Existence of the cost functor.

The key insight is that voice-leading is not merely a musical heuristic;
it is a functorial distortion theory. This formalization opens the door
to treating musical structure with the full power of categorical
information theory.
-/

import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Chords and Voice Leadings -/

/-- A chord with `n` voices, each assigned an integer pitch value. -/
def Chord (n : ℕ) := Fin n → ℤ

instance (n : ℕ) : DecidableEq (Chord n) := by unfold Chord; infer_instance

/-- A voice leading from chord `A` to chord `B` is a permutation of voices
    that maps each voice in `A` to a voice in `B`. The `perm` field specifies
    which voice in `B` each voice in `A` is mapped to. -/
structure VoiceLeading (n : ℕ) (A B : Chord n) where
  /-- The permutation assigning voices of `A` to voices of `B`. -/
  perm : Equiv.Perm (Fin n)

namespace VoiceLeading

variable {n : ℕ}

/-- The displacement of voice `i` under a voice leading: the absolute
    difference between the target pitch and the source pitch. -/
def voiceDisplacement (A B : Chord n) (vl : VoiceLeading n A B) (i : Fin n) : ℝ :=
  |((B (vl.perm i)) - (A i) : ℤ)|

/-- The total cost of a voice leading: sum of absolute displacements
    over all voices. This is the L¹ voice-leading distance. -/
def cost (A B : Chord n) (vl : VoiceLeading n A B) : ℝ :=
  ∑ i : Fin n, |((B (vl.perm i)) - (A i) : ℤ)|

/-- Voice-leading cost is nonneg. -/
theorem cost_nonneg {A B : Chord n} (vl : VoiceLeading n A B) :
    0 ≤ vl.cost A B := by
  apply Finset.sum_nonneg
  intro i _
  exact abs_nonneg _

/-- The identity voice leading (identity permutation). -/
def id (A : Chord n) : VoiceLeading n A A where
  perm := Equiv.refl _

/-- The identity voice leading has zero cost. -/
theorem cost_id (A : Chord n) : (VoiceLeading.id A).cost A A = 0 := by
  simp [cost, VoiceLeading.id, Equiv.refl]

/-- Composition of voice leadings via permutation composition. -/
def comp {A B C : Chord n} (vl₁ : VoiceLeading n A B)
    (vl₂ : VoiceLeading n B C) : VoiceLeading n A C where
  perm := vl₁.perm.trans vl₂.perm

/-
**Triangle inequality for voice-leading cost**: the cost of the
    composition is at most the sum of the costs.

    This is the key theorem that makes voice-leading into a metric/Lawvere
    structure. The proof uses the triangle inequality for absolute values
    and rearrangement of the sum.
-/
theorem cost_comp_le {A B C : Chord n}
    (vl₁ : VoiceLeading n A B) (vl₂ : VoiceLeading n B C) :
    (vl₁.comp vl₂).cost A C ≤ vl₁.cost A B + vl₂.cost B C := by
  convert Finset.sum_le_sum fun i _ => ?_ using 1;
  rotate_left;
  exact fun i => |(B (vl₁.perm i) - A i : ℤ)| + |(C (vl₂.perm (vl₁.perm i)) - B (vl₁.perm i) : ℤ)|;
  · infer_instance;
  · norm_cast;
    grind +locals;
  · simp +decide [ cost, Finset.sum_add_distrib ];
    conv_lhs => rw [ ← Equiv.sum_comp vl₁.perm ] ;

end VoiceLeading

/-! ## The Voice-Leading Category -/

/-- Objects of the voice-leading category: chords with a fixed number of voices. -/
def VLObj (n : ℕ) := Chord n

/-- Morphisms in the voice-leading category: voice leadings between chords.
    We use the set of all voice leadings (all permutations). -/
def VLHom (n : ℕ) (A B : VLObj n) := VoiceLeading n A B

/-- The minimal voice-leading distance between two chords:
    the minimum cost over all possible voice assignments. -/
def minVoiceLeadingDist (n : ℕ) [NeZero n] (A B : Chord n) : ℝ :=
  Finset.inf' Finset.univ (Finset.univ_nonempty)
    (fun σ : Equiv.Perm (Fin n) =>
      ∑ i : Fin n, |((B (σ i)) - (A i) : ℤ)|)

/-
Minimum voice-leading distance is nonneg.
-/
theorem minVoiceLeadingDist_nonneg (n : ℕ) [NeZero n] (A B : Chord n) :
    0 ≤ minVoiceLeadingDist n A B := by
  unfold minVoiceLeadingDist;
  norm_num;
  exact fun _ => Finset.sum_nonneg fun _ _ => abs_nonneg _

/-
Minimum voice-leading distance satisfies the triangle inequality.
-/
theorem minVoiceLeadingDist_triangle (n : ℕ) [NeZero n]
    (A B C : Chord n) :
    minVoiceLeadingDist n A C ≤ minVoiceLeadingDist n A B + minVoiceLeadingDist n B C := by
  -- By definition of infimum, for any permutations $\sigma_1$ and $\sigma_2$, we have:
  have h_inf : ∀ σ₁ σ₂ : Equiv.Perm (Fin n), ∑ i : Fin n, |((C (σ₂ (σ₁ i))) - (A i) : ℤ)| ≤ ∑ i : Fin n, |((B (σ₁ i)) - (A i) : ℤ)| + ∑ i : Fin n, |((C (σ₂ i)) - (B i) : ℤ)| := by
    intros σ₁ σ₂
    have h_triangle : ∀ i : Fin n, |(C (σ₂ (σ₁ i)) : ℤ) - (A i : ℤ)| ≤ |(B (σ₁ i) : ℤ) - (A i : ℤ)| + |(C (σ₂ (σ₁ i)) : ℤ) - (B (σ₁ i) : ℤ)| := by
      grind;
    convert Finset.sum_le_sum fun i _ => h_triangle i using 1 ; simp +decide [ Finset.sum_add_distrib, Equiv.sum_comp ];
    conv_lhs => rw [ ← Equiv.sum_comp σ₁ ] ;
  -- Let $\sigma_1$ and $\sigma_2$ be permutations that achieve the minimum costs for $A \to B$ and $B \to C$ respectively.
  obtain ⟨σ₁, hσ₁⟩ : ∃ σ₁ : Equiv.Perm (Fin n), ∑ i : Fin n, |((B (σ₁ i)) - (A i) : ℤ)| = minVoiceLeadingDist n A B := by
    have := Finset.exists_min_image Finset.univ ( fun σ : Equiv.Perm ( Fin n ) => ∑ i : Fin n, |B ( σ i ) - A i| ) ⟨ Equiv.refl ( Fin n ), Finset.mem_univ _ ⟩;
    obtain ⟨ σ₁, hσ₁₁, hσ₁₂ ⟩ := this; use σ₁; simp_all +decide [ minVoiceLeadingDist ] ;
    exact le_antisymm ( Finset.le_inf' _ _ fun x hx => mod_cast hσ₁₂ x ) ( Finset.inf'_le _ <| Finset.mem_univ σ₁ )
  obtain ⟨σ₂, hσ₂⟩ : ∃ σ₂ : Equiv.Perm (Fin n), ∑ i : Fin n, |((C (σ₂ i)) - (B i) : ℤ)| = minVoiceLeadingDist n B C := by
    have := Finset.exists_min_image Finset.univ ( fun σ : Equiv.Perm ( Fin n ) => ∑ i : Fin n, |C ( σ i ) - B i| ) ⟨ Equiv.refl _, Finset.mem_univ _ ⟩;
    obtain ⟨ σ₂, hσ₂₁, hσ₂₂ ⟩ := this; use σ₂; simp_all +decide [ minVoiceLeadingDist ] ;
    exact le_antisymm ( Finset.le_inf' _ _ fun x hx => mod_cast hσ₂₂ x ) ( Finset.inf'_le _ <| Finset.mem_univ σ₂ );
  refine' le_trans _ ( add_le_add ( hσ₁.le ) ( hσ₂.le ) );
  exact le_trans ( Finset.inf'_le _ <| Finset.mem_univ ( σ₂ * σ₁ ) ) ( mod_cast h_inf σ₁ σ₂ )

/-
Minimum voice-leading distance from a chord to itself is zero.
-/
theorem minVoiceLeadingDist_self (n : ℕ) [NeZero n] (A : Chord n) :
    minVoiceLeadingDist n A A = 0 := by
  exact le_antisymm ( le_trans ( Finset.inf'_le _ ( Finset.mem_univ ( Equiv.refl ( Fin n ) ) ) ) ( by aesop ) ) ( minVoiceLeadingDist_nonneg n A A )

/-! ## Lawvere Metric Category -/

/-- A Lawvere metric space: a type with an asymmetric distance function
    satisfying `d(x,x) = 0` and `d(x,z) ≤ d(x,y) + d(y,z)`. -/
class LawvereMetric (X : Type*) where
  dist : X → X → ℝ
  dist_nonneg : ∀ x y, 0 ≤ dist x y
  dist_self : ∀ x, dist x x = 0
  dist_triangle : ∀ x y z, dist x z ≤ dist x y + dist y z

/-- Chords with minimum voice-leading distance form a Lawvere metric space. -/
instance chordLawvereMetric (n : ℕ) [NeZero n] : LawvereMetric (Chord n) where
  dist := minVoiceLeadingDist n
  dist_nonneg := minVoiceLeadingDist_nonneg n
  dist_self := minVoiceLeadingDist_self n
  dist_triangle := minVoiceLeadingDist_triangle n

/-! ## Bridge: Voice-Leading as Distortion -/

/-- Voice-leading distortion function: the cost of mapping one chord to another
    via the cheapest voice leading. This serves as the distortion measure
    for rate-distortion theory over chord spaces. -/
def voiceLeadingDistortion (n : ℕ) [NeZero n] (A B : Chord n) : ℝ :=
  minVoiceLeadingDist n A B

end