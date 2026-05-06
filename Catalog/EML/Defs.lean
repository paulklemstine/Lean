/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Reflection Capacity Threshold: Definitions

This file defines the framework for the **reflection capacity incompleteness
threshold theorem**: excess thermodynamic reflection capacity forces the
existence of internally uncompressible reflective sentences.

## Main Definitions

* `CoherentClosureSelfModel` — base class: diagonal lemma, free energy, etc.
* `CoherentClosureProofSemiring` — algebraic proof semiring
* `ClosureSelfModel` — extension with quantitative reflection parameters
* `Formula`, `reflectionCapacity`, `proofEntropyRate`, `diagonalOverhead`
* `reflectionGap` — gap invariant
* `freeEnergyBarrier`, `diagonalized`, `reflectiveBarrier`
-/

import Mathlib

set_option autoImplicit false

universe u

/-! ## §1. Coherent Closure Self-Models -/

/-- A **coherent closure self-model**: abstract formal system with
self-reference, provability internalization, soundness, and
thermodynamic structure. -/
class CoherentClosureSelfModel (M : Type u) where
  Sentence : Type u
  Code : Type u
  proves : Sentence → Prop
  provSent : Sentence → Sentence
  negSent : Sentence → Sentence
  iffSent : Sentence → Sentence → Sentence
  internalize : Prop → Sentence
  selfCode : Sentence → Code
  freeEnergy : ℝ → Code → ℝ
  complexityFloor : ℝ → Sentence → ℝ
  ax_diagonal : ∀ (Ψ : Sentence → Sentence),
    ∃ G, proves (iffSent G (negSent (provSent (Ψ G))))
  ax_necessitation : ∀ {φ : Sentence}, proves φ → proves (provSent φ)
  ax_internalize_sound : ∀ {P : Prop}, proves (internalize P) → P
  ax_neg_consistent : ∀ {φ : Sentence}, proves φ → proves (negSent φ) → False
  ax_iff_mp : ∀ {φ ψ : Sentence}, proves (iffSent φ ψ) → proves φ → proves ψ
  ax_iff_mpr : ∀ {φ ψ : Sentence}, proves (iffSent φ ψ) → proves ψ → proves φ
  ax_neg_intro : ∀ {φ : Sentence}, (proves φ → False) → proves (negSent φ)
  ax_freeEnergy_ge_floor : ∀ (β : ℝ) (G : Sentence),
    0 < β → complexityFloor β G ≤ freeEnergy β (selfCode G)
  ax_complexityFloor_nonneg : ∀ (β : ℝ) (G : Sentence),
    0 < β → 0 ≤ complexityFloor β G

namespace CoherentClosureSelfModel

variable {M : Type u} [CoherentClosureSelfModel M]

/-- Compression predicate: `freeEnergy β (selfCode G) < complexityFloor β G`. -/
def CompressesAt (beta : ℝ) (G : Sentence (M := M)) : Prop :=
  freeEnergy beta (selfCode G) < complexityFloor beta G

/-- Internalized compression sentence. -/
def CompressesAtSent (beta : ℝ) (G : Sentence (M := M)) : Sentence (M := M) :=
  internalize (CompressesAt beta G)

/-- Strict compression is semantically false (free-energy lower bound). -/
theorem compressesAt_false (beta : ℝ) (hβ : 0 < beta) (G : Sentence (M := M)) :
    ¬ CompressesAt beta G :=
  not_lt.mpr (ax_freeEnergy_ge_floor beta G hβ)

/-- Strict compression is unprovable (soundness + lower bound). -/
theorem compression_not_provable (beta : ℝ) (hβ : 0 < beta) (G : Sentence (M := M)) :
    ¬ proves (CompressesAtSent beta G) :=
  fun hC => compressesAt_false beta hβ G (ax_internalize_sound hC)

/-- Free-energy diagonal sentence existence. -/
theorem exists_freeEnergy_liar (beta : ℝ) :
    ∃ G : Sentence (M := M),
      proves (iffSent G (negSent (provSent (CompressesAtSent beta G)))) :=
  ax_diagonal (CompressesAtSent beta ·)

/-- **Free-Energy No-Self-Compression Theorem.**
For any β > 0, there exists a diagonal sentence whose compression is unprovable. -/
theorem freeEnergy_no_self_compression (beta : ℝ) (hβ : 0 < beta) :
    ∃ G : Sentence (M := M),
      proves (iffSent G (negSent (provSent (CompressesAtSent beta G)))) ∧
      ¬ proves (CompressesAtSent beta G) := by
  obtain ⟨G, hG⟩ := exists_freeEnergy_liar (M := M) beta
  exact ⟨G, hG, compression_not_provable beta hβ G⟩

end CoherentClosureSelfModel

/-! ## §2. Coherent Closure Proof Semiring -/

/-- A **coherent closure proof semiring**: bounded distributive lattice
with closure operator (nucleus). -/
class CoherentClosureProofSemiring (S : Type*) extends DistribLattice S, BoundedOrder S where
  cl : S → S
  cl_extensive : ∀ (x : S), x ≤ cl x
  cl_idempotent : ∀ (x : S), cl (cl x) = cl x
  cl_monotone : ∀ {x y : S}, x ≤ y → cl x ≤ cl y

/-! ## §3. Closure Self-Model with Quantitative Reflection Parameters -/

/-- A **closure self-model** extends a coherent closure self-model with
quantitative invariants controlling the incompleteness phase transition.

`ax_reflection_gap`: when reflection capacity exceeds proof entropy rate
+ diagonal overhead, there exists β > 0 and a diagonal sentence G such that:
1. G is a fixed point: `G ↔ ¬Prov(CompressesAt(β, G))`
2. G has positive complexity floor: `0 < complexityFloor β G` -/
class ClosureSelfModel (M : Type u) extends CoherentClosureSelfModel M where
  reflCap : ℝ
  proofEntRate : ℝ
  diagOvhd : ℝ
  reflCap_nonneg : 0 ≤ reflCap
  proofEntRate_nonneg : 0 ≤ proofEntRate
  diagOvhd_nonneg : 0 ≤ diagOvhd
  ax_reflection_gap : reflCap > proofEntRate + diagOvhd →
    ∃ (β : ℝ) (G : Sentence), 0 < β ∧
      proves (iffSent G (negSent (provSent
        (internalize (freeEnergy β (selfCode G) < complexityFloor β G))))) ∧
      0 < complexityFloor β G

/-! ## §4. Public API -/

open CoherentClosureSelfModel

/-- Formulas in the self-model (alias for Sentence). -/
abbrev Formula (M : Type u) [ClosureSelfModel M] :=
  CoherentClosureSelfModel.Sentence (M := M)

/-- **Reflection capacity** of the model. -/
noncomputable def reflectionCapacity (M : Type u) [ClosureSelfModel M] : ℝ :=
  ClosureSelfModel.reflCap (M := M)

/-- **Proof entropy rate** of the model. -/
noncomputable def proofEntropyRate (M : Type u) [ClosureSelfModel M] : ℝ :=
  ClosureSelfModel.proofEntRate (M := M)

/-- **Diagonal overhead** of the model. -/
noncomputable def diagonalOverhead (M : Type u) [ClosureSelfModel M] : ℝ :=
  ClosureSelfModel.diagOvhd (M := M)

/-- **Reflection gap**: `reflectionCapacity M - proofEntropyRate M - diagonalOverhead M`.
Order parameter for the incompleteness phase transition. -/
noncomputable def reflectionGap (M : Type u) [ClosureSelfModel M] : ℝ :=
  reflectionCapacity M - proofEntropyRate M - diagonalOverhead M

/-- A formula exhibits a **free-energy barrier**: positive complexity floor
at some positive temperature. -/
def freeEnergyBarrier (M : Type u) [ClosureSelfModel M]
    (φ : Formula M) : Prop :=
  ∃ β : ℝ, 0 < β ∧ 0 < complexityFloor β φ

/-- A formula is **diagonalized**: Gödel–Lawvere fixed point for
the compression predicate. -/
def diagonalized (M : Type u) [ClosureSelfModel M]
    (φ : Formula M) : Prop :=
  ∃ β : ℝ, 0 < β ∧
    proves (iffSent φ (negSent (provSent (CompressesAtSent β φ))))

/-- A formula is a **reflective barrier**: both a free-energy barrier
and diagonalized. These are the fundamental obstructions to
self-compression—self-referential sentences that are
thermodynamically irreducible.

- **Thermodynamic**: positive complexity floor
- **Logical**: asserts its own incompressibility -/
def reflectiveBarrier (M : Type u) [ClosureSelfModel M]
    (φ : Formula M) : Prop :=
  freeEnergyBarrier M φ ∧ diagonalized M φ

/-- `reflectiveBarrier` unfolds as the conjunction. -/
theorem reflectiveBarrier_def {M : Type u} [ClosureSelfModel M] (φ : Formula M) :
    reflectiveBarrier M φ ↔ freeEnergyBarrier M φ ∧ diagonalized M φ :=
  Iff.rfl