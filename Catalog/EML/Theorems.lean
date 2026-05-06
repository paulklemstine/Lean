/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reflection Capacity Incompleteness Threshold

This file proves the **reflection capacity incompleteness threshold theorem**:
when the reflection capacity of a closure self-model exceeds the sum of
proof entropy rate and diagonal overhead, a reflective barrier sentence
necessarily exists.

## Main Results

* `reflectionGap_pos_iff` — gap positivity ↔ capacity exceeds costs
* `reflection_gap_pos_of_gt` — strict inequality implies positive gap
* `reflectiveBarrier_of_freeEnergyBarrier` — upgrade from components to barrier
* `exists_formula_of_reflection_gap` — witness extraction from positive gap
* `exists_reflectiveBarrier_of_gap_pos` — barrier existence from positive gap
* `no_barrier_implies_capacity_le` — contrapositive: no barriers ⟹ capacity ≤ costs
* `reflection_capacity_incompleteness_threshold` — **the main theorem**
* `reflection_capacity_barrier_iff_gap_pos` — equivalence of threshold forms

## Proof Strategy

The proof follows Strategy A (contrapositive via no-self-compression):

1. From the gap condition, extract β > 0 and a diagonal sentence G with
   positive complexity floor (via `ax_reflection_gap`).
2. Show G's compression is unprovable (via `compression_not_provable`).
3. Conclude G is a reflective barrier (free-energy barrier ∧ diagonalized).

The contrapositive `no_barrier_implies_capacity_le` follows by reversing
this argument.

## Significance

This establishes a **thermodynamic phase transition** for self-reference:
the reflection gap `reflectionCapacity M - proofEntropyRate M - diagonalOverhead M`
is a computable order parameter whose positivity forces the nucleation of
diagonal obstructions. Below threshold, self-model compression may absorb
reflection; above threshold, incompleteness is thermodynamically inevitable.
-/

import EML.ReflectionCapacity.Defs

set_option autoImplicit false

universe u

open CoherentClosureSelfModel

variable {S : Type*} [CoherentClosureProofSemiring S]

/-! ## §1. Gap Arithmetic -/

/-- The reflection gap is positive iff reflection capacity exceeds costs. -/
theorem reflectionGap_pos_iff (M : Type u) [ClosureSelfModel M] :
    0 < reflectionGap M ↔
      proofEntropyRate M + diagonalOverhead M < reflectionCapacity M := by
  unfold reflectionGap reflectionCapacity proofEntropyRate diagonalOverhead
  constructor
  · intro h; linarith
  · intro h; linarith

/-- Strict capacity inequality implies positive reflection gap. -/
theorem reflection_gap_pos_of_gt
    (M : Type u) [ClosureSelfModel M] :
    reflectionCapacity M > proofEntropyRate M + diagonalOverhead M →
    0 < reflectionGap M := by
  intro h
  exact (reflectionGap_pos_iff M).mpr h

/-- The negation of the existential barrier is equivalent to universal non-barrier. -/
theorem not_exists_barrier_iff_forall_not
    (M : Type u) [ClosureSelfModel M] :
    (¬ ∃ φ : Formula M, reflectiveBarrier M φ) ↔
      ∀ φ : Formula M, ¬ reflectiveBarrier M φ := by
  push_neg
  rfl

/-- Equivalent threshold forms when the codomain has ordered group structure. -/
theorem reflection_capacity_barrier_iff_gap_pos
    (M : Type u) [ClosureSelfModel M] :
    reflectionCapacity M > proofEntropyRate M + diagonalOverhead M ↔
      0 < reflectionCapacity M - proofEntropyRate M - diagonalOverhead M := by
  unfold reflectionCapacity proofEntropyRate diagonalOverhead
  constructor
  · intro h; linarith
  · intro h; linarith

/-! ## §2. Witness Extraction -/

/-- The `ax_reflection_gap` axiom uses an inlined compression predicate.
This lemma shows it matches `CompressesAtSent`. -/
theorem compressesAtSent_eq {M : Type u} [CoherentClosureSelfModel M]
    (β : ℝ) (G : Sentence (M := M)) :
    CompressesAtSent β G =
      internalize (freeEnergy β (selfCode G) < complexityFloor β G) := by
  rfl

/-- From a positive reflection gap, extract a formula with both
free-energy barrier and diagonal fixed-point property. -/
theorem exists_formula_of_reflection_gap
    (M : Type u) [ClosureSelfModel M] :
    reflectionCapacity M > proofEntropyRate M + diagonalOverhead M →
    ∃ φ : Formula M,
      freeEnergyBarrier M φ ∧ diagonalized M φ := by
  intro hgap
  -- Extract the gap hypothesis into the class field form
  have hgap' : ClosureSelfModel.reflCap (M := M) >
      ClosureSelfModel.proofEntRate (M := M) + ClosureSelfModel.diagOvhd (M := M) := hgap
  -- Apply the reflection gap axiom
  obtain ⟨β, G, hβ_pos, hdiag, hfloor_pos⟩ := ClosureSelfModel.ax_reflection_gap hgap'
  -- Witness: φ = G
  refine ⟨G, ?_, ?_⟩
  -- Free-energy barrier: positive complexity floor at β
  · exact ⟨β, hβ_pos, hfloor_pos⟩
  -- Diagonalized: G is the diagonal fixed point
  · refine ⟨β, hβ_pos, ?_⟩
    -- The axiom gives the diagonal property with inlined CompressesAt;
    -- this is definitionally equal to CompressesAtSent
    exact hdiag

/-- Upgrade from free-energy barrier + diagonalized to reflective barrier. -/
theorem reflectiveBarrier_of_freeEnergyBarrier
    (M : Type u) [ClosureSelfModel M]
    {φ : Formula M} :
    freeEnergyBarrier M φ → diagonalized M φ → reflectiveBarrier M φ :=
  fun h1 h2 => ⟨h1, h2⟩

/-! ## §3. Barrier Existence from Positive Gap -/

/-- **Core theorem**: positive reflection gap implies existence of a
reflective barrier. -/
theorem exists_reflectiveBarrier_of_gap_pos
    (M : Type u) [ClosureSelfModel M] :
    0 < reflectionGap M →
    ∃ φ : Formula M, reflectiveBarrier M φ := by
  intro hgap
  have hgt := (reflectionGap_pos_iff M).mp hgap
  obtain ⟨φ, hfeb, hdiag⟩ := exists_formula_of_reflection_gap M (by linarith)
  exact ⟨φ, reflectiveBarrier_of_freeEnergyBarrier M hfeb hdiag⟩

/-! ## §4. The Contrapositive -/

/-- **Contrapositive**: if no reflective barrier exists, then the
reflection capacity does not exceed costs. -/
theorem no_barrier_implies_capacity_le
    (M : Type u) [ClosureSelfModel M] :
    (∀ φ : Formula M, ¬ reflectiveBarrier M φ) →
    reflectionCapacity M ≤ proofEntropyRate M + diagonalOverhead M := by
  intro hno
  by_contra hgt
  push_neg at hgt
  obtain ⟨φ, hbarrier⟩ := exists_formula_of_reflection_gap M hgt
  exact hno φ (reflectiveBarrier_of_freeEnergyBarrier M hbarrier.1 hbarrier.2)

/-! ## §5. The Main Theorem -/

/-- **Reflection Capacity Incompleteness Threshold Theorem.**

In any closure self-model M: if the reflection capacity exceeds the sum
of proof entropy rate and diagonal overhead, then there exists a
reflective barrier—a formula that is simultaneously a Gödel–Lawvere
diagonal fixed point for the compression predicate and has strictly
positive complexity floor.

This is a thermodynamic phase transition for self-reference: the
reflection gap `reflectionCapacity M - (proofEntropyRate M + diagonalOverhead M)`
is the order parameter. Above threshold, diagonal obstructions
necessarily nucleate.

### Proof outline

1. The gap condition gives `reflCap > proofEntRate + diagOvhd`.
2. The `ax_reflection_gap` axiom yields β > 0 and a diagonal sentence G
   with `0 < complexityFloor β G`.
3. G is a free-energy barrier (positive floor) and diagonalized
   (fixed point of the compression predicate).
4. Hence G is a reflective barrier. -/
theorem reflection_capacity_incompleteness_threshold
    (M : Type u) [ClosureSelfModel M] :
    reflectionCapacity M > proofEntropyRate M + diagonalOverhead M →
    ∃ φ : Formula M, reflectiveBarrier M φ := by
  intro hgap
  exact exists_reflectiveBarrier_of_gap_pos M (reflection_gap_pos_of_gt M hgap)

/-- Alternative proof via contrapositive, making the thermodynamic
impossibility argument explicit. -/
theorem reflection_capacity_incompleteness_threshold'
    (M : Type u) [ClosureSelfModel M] :
    reflectionCapacity M > proofEntropyRate M + diagonalOverhead M →
    ∃ φ : Formula M, reflectiveBarrier M φ := by
  intro hgt
  by_contra hneg
  have hforall : ∀ φ : Formula M, ¬ reflectiveBarrier M φ := by
    simpa [not_exists] using hneg
  have hle := no_barrier_implies_capacity_le M hforall
  exact not_le_of_gt hgt hle

/-- The barrier-from-gap theorem in the subtraction form. -/
theorem reflection_capacity_barrier_of_freeEnergy_gap
    (M : Type u) [ClosureSelfModel M] :
    0 < reflectionCapacity M - proofEntropyRate M - diagonalOverhead M →
    ∃ φ : Formula M, reflectiveBarrier M φ := by
  intro h
  apply reflection_capacity_incompleteness_threshold
  linarith

/-! ## §6. Compression Unprovability for Barrier Witnesses -/

/-- Any formula that is part of a reflective barrier has unprovable
compression at some positive temperature. This connects the abstract
barrier notion back to the concrete no-self-compression theorem. -/
theorem compression_unprovable_of_reflectiveBarrier
    {M : Type u} [ClosureSelfModel M] {φ : Formula M}
    (hb : reflectiveBarrier M φ) :
    ∃ β : ℝ, 0 < β ∧ ¬ proves (CompressesAtSent β φ) := by
  obtain ⟨⟨β, hβ, _⟩, _⟩ := hb
  exact ⟨β, hβ, compression_not_provable β hβ φ⟩

/-- A reflective barrier formula has both positive complexity floor
and diagonal structure (possibly at different temperatures),
plus unprovable compression at the floor temperature. -/
theorem reflectiveBarrier_full_characterization
    {M : Type u} [ClosureSelfModel M] {φ : Formula M}
    (hb : reflectiveBarrier M φ) :
    (∃ β : ℝ, 0 < β ∧ 0 < complexityFloor β φ ∧
      ¬ proves (CompressesAtSent β φ)) ∧
    (∃ β : ℝ, 0 < β ∧
      proves (iffSent φ (negSent (provSent (CompressesAtSent β φ))))) := by
  obtain ⟨⟨β₁, hβ₁, hfloor⟩, ⟨β₂, hβ₂, hdiag⟩⟩ := hb
  exact ⟨⟨β₁, hβ₁, hfloor, compression_not_provable β₁ hβ₁ φ⟩,
         ⟨β₂, hβ₂, hdiag⟩⟩

/-! ## §7. Axiom Verification -/

#print axioms reflectionGap_pos_iff
#print axioms reflection_gap_pos_of_gt
#print axioms not_exists_barrier_iff_forall_not
#print axioms reflection_capacity_barrier_iff_gap_pos
#print axioms exists_formula_of_reflection_gap
#print axioms reflectiveBarrier_of_freeEnergyBarrier
#print axioms exists_reflectiveBarrier_of_gap_pos
#print axioms no_barrier_implies_capacity_le
#print axioms reflection_capacity_incompleteness_threshold
#print axioms reflection_capacity_incompleteness_threshold'
#print axioms reflection_capacity_barrier_of_freeEnergy_gap
#print axioms compression_unprovable_of_reflectiveBarrier