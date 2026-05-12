/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Hecke Trapdoor Duality: Core Definitions

## Mathematical Overview

This file establishes the foundational definitions for **tropical Hecke trapdoor
duality**, a framework connecting idempotent harmonic analysis to cryptographic
trapdoor design.

The central objects are:
- **Tropical min-plus convolution** on finite monoids
- **Hecke operators** as convolution kernels
- **Spectral levels** measuring minimal tropical weights
- **Decoding fibers** as preimage sets under encoding operators
- **Trapdoor flags** that guarantee unique minimal witnesses
- **Certified decoding** with soundness and completeness

The key phenomenon: a privileged **Hecke-adapted flag** creates hidden
low-complexity tropical eigenslices that act as trapdoors for certified decoding,
while generic inversion requires extremal witness search over the Hecke envelope.

## References

* Litvinov, Maslov, Shpiz — Idempotent functional analysis
* Cohen, Gaubert, Quadrat — Max-plus algebra and discrete event systems
* Akian, Gaubert, Guterman — Tropical Perron-Frobenius theory
-/

noncomputable section

open Finset Function

namespace TropicalHeckeTrapdoor

/-! ## §1. Tropical Convolution on Finite Monoids -/

variable {G : Type*} [Fintype G] [DecidableEq G] [Monoid G]

/-- The set of all factorization pairs `(a, b)` with `a * b = x` in a finite monoid. -/
def factorPairs (x : G) : Finset (G × G) :=
  (Finset.univ ×ˢ Finset.univ).filter (fun p => p.1 * p.2 = x)

/-- Factorization pairs are nonempty for any element of a monoid. -/
theorem factorPairs_nonempty (x : G) : (factorPairs x).Nonempty := by
  refine ⟨(1, x), ?_⟩
  simp [factorPairs, Finset.mem_filter]

/-- **Tropical min-plus convolution** on a finite monoid.
    `(tropConv f k)(x) = min_{(a,b) : a*b=x} (f(a) + k(b))`

    This is the fundamental operation of tropical harmonic analysis on monoids. -/
def tropConv (f k : G → ℤ) (x : G) : ℤ :=
  (factorPairs x).inf' (factorPairs_nonempty x) (fun p => f p.1 + k p.2)

/-- Tropical convolution is bounded above by any particular factorization. -/
theorem tropConv_le_of_factor (f k : G → ℤ) (a b : G) (x : G) (hab : a * b = x) :
    tropConv f k x ≤ f a + k b := by
  unfold tropConv
  exact Finset.inf'_le (f := fun p : G × G => f p.1 + k p.2)
    (show (a, b) ∈ factorPairs x by simp [factorPairs, hab])

/-- Tropical convolution achieves its minimum at some factorization. -/
theorem tropConv_exists_witness (f k : G → ℤ) (x : G) :
    ∃ a b, a * b = x ∧ tropConv f k x = f a + k b := by
  obtain ⟨⟨a, b⟩, hmem, hmin⟩ := Finset.exists_mem_eq_inf' (factorPairs_nonempty x)
    (fun p => f p.1 + k p.2)
  simp [factorPairs] at hmem
  exact ⟨a, b, hmem, hmin⟩

/-! ## §2. Tropical Hecke Operators -/

/-- A **tropical Hecke operator** on a finite monoid `G` is a convolution kernel
    `G → ℤ` that acts on tropical functions by min-plus convolution. -/
structure TropicalHeckeOperator (G : Type*) [Fintype G] [DecidableEq G] [Monoid G] where
  /-- The convolution kernel -/
  kernel : G → ℤ

/-- Apply a Hecke operator to a function via tropical convolution. -/
def TropicalHeckeOperator.apply (T : TropicalHeckeOperator G) (f : G → ℤ) : G → ℤ :=
  tropConv f T.kernel

/-- A **tropical Hecke family** is a finite collection of Hecke operators. -/
structure TropicalHeckeFamily (G : Type*) [Fintype G] [DecidableEq G] [Monoid G] where
  /-- The collection of operators -/
  ops : Finset (TropicalHeckeOperator G)

/-! ## §3. Spectral Levels and Weight Measures -/

set_option linter.unusedSectionVars false in
/-- The **tropical weight** of a function: the minimum value it attains. -/
def tropWeight (f : G → ℤ) : ℤ :=
  Finset.univ.inf' Finset.univ_nonempty (fun g => f g)

set_option linter.unusedSectionVars false in
/-- The tropical weight is bounded above by the value at any point. -/
theorem tropWeight_le (f : G → ℤ) (g : G) : tropWeight f ≤ f g :=
  Finset.inf'_le _ (Finset.mem_univ g)

set_option linter.unusedSectionVars false in
/-- The tropical weight is achieved at some point. -/
theorem tropWeight_exists_witness (f : G → ℤ) :
    ∃ g : G, tropWeight f = f g := by
  obtain ⟨g, _, hg⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty (fun g => f g)
  exact ⟨g, hg⟩

/-- The **spectral level** of a function under a Hecke operator:
    the minimum tropical weight of the output after applying `T`. -/
def spectralLevel (T : TropicalHeckeOperator G) (f : G → ℤ) : ℤ :=
  tropWeight (T.apply f)

/-- The **spectral support** of a function under a Hecke operator:
    the set of elements where the output achieves its minimum. -/
def spectralSupport (T : TropicalHeckeOperator G) (f : G → ℤ) : Finset G :=
  Finset.univ.filter (fun g => T.apply f g = spectralLevel T f)

/-- The spectral support is always nonempty. -/
theorem spectralSupport_nonempty (T : TropicalHeckeOperator G) (f : G → ℤ) :
    (spectralSupport T f).Nonempty := by
  obtain ⟨g, hg⟩ := tropWeight_exists_witness (T.apply f)
  exact ⟨g, Finset.mem_filter.mpr ⟨Finset.mem_univ g, hg.symm⟩⟩

/-- The **spectral support radius**: the cardinality of the spectral support. -/
def spectralSupportRadius (T : TropicalHeckeOperator G) (f : G → ℤ) : ℕ :=
  (spectralSupport T f).card

/-! ## §4. Decoding Fibers and Witnesses -/

/-- A **codeword** in the tropical Hecke setting is simply a function `G → ℤ`. -/
abbrev Codeword (G : Type*) [Fintype G] [DecidableEq G] [Monoid G] := G → ℤ

/-- The **decoding fiber**: the set of all messages whose encoding equals `y`. -/
def decodingFiber (T : TropicalHeckeOperator G) (y : Codeword G) : Set (Codeword G) :=
  { f | T.apply f = y }

/-- A witness is **minimal** in a set if its tropical weight is ≤ all others. -/
def IsMinimalWeight (S : Set (Codeword G)) (w : Codeword G) : Prop :=
  w ∈ S ∧ ∀ w' ∈ S, tropWeight w ≤ tropWeight w'

/-! ## §5. Trapdoor Flag -/

/-- A **trapdoor flag** for a Hecke operator is auxiliary data that enables
    efficient certified decoding. It consists of:
    - A decoding function that produces a candidate witness
    - A proof that the candidate is always in the fiber (soundness)
    - A proof that the candidate has minimal weight (optimality)
    - A proof that any other minimal-weight witness equals it (uniqueness) -/
structure TrapdoorFlag (T : TropicalHeckeOperator G) where
  /-- The trapdoor decoding function -/
  decode : Codeword G → Codeword G
  /-- Soundness: decoding produces an element of the fiber -/
  sound : ∀ y, T.apply (decode y) = y
  /-- Optimality: the decoded witness has minimal weight in the fiber -/
  optimal : ∀ y f, T.apply f = y → tropWeight (decode y) ≤ tropWeight f
  /-- Uniqueness: any fiber element with the same weight equals the decoded witness -/
  unique : ∀ y f, T.apply f = y → tropWeight f = tropWeight (decode y) → f = decode y

/-- A received word is **decodable** if it lies in the image of the encoding operator. -/
def Decodable (T : TropicalHeckeOperator G) (y : Codeword G) : Prop :=
  ∃ f, T.apply f = y

/-- A **decoding certificate** is a proof that a witness is in the fiber
    and is the unique minimal-weight element. -/
structure DecodingCertificate (T : TropicalHeckeOperator G) (y : Codeword G)
    (w : Codeword G) : Prop where
  /-- The witness is in the fiber -/
  inFiber : T.apply w = y
  /-- The witness has minimal weight -/
  isMinimal : ∀ f, T.apply f = y → tropWeight w ≤ tropWeight f
  /-- The witness is the unique minimal element -/
  isUnique : ∀ f, T.apply f = y → tropWeight f = tropWeight w → f = w

/-! ## §6. Problem Reductions -/

/-- The **generic decode problem**: given T and y, find an f in the decoding fiber. -/
structure GenericDecodeProblem (T : TropicalHeckeOperator G) where
  /-- The received word -/
  y : Codeword G
  /-- The received word is decodable -/
  decodable : Decodable T y

/-- The **extremal witness problem**: given T and y, find a minimal-weight witness. -/
structure ExtremalWitnessProblem (T : TropicalHeckeOperator G) where
  /-- The received word -/
  y : Codeword G
  /-- The received word is decodable -/
  decodable : Decodable T y

/-- A **solution** to the generic decode problem. -/
structure GenericDecodeSolution (T : TropicalHeckeOperator G)
    (P : GenericDecodeProblem T) where
  /-- The decoded message -/
  witness : Codeword G
  /-- Correctness: encoding the witness gives the received word -/
  correct : T.apply witness = P.y

/-- A **solution** to the extremal witness problem. -/
structure ExtremalWitnessSolution (T : TropicalHeckeOperator G)
    (P : ExtremalWitnessProblem T) where
  /-- The decoded message -/
  witness : Codeword G
  /-- Correctness -/
  correct : T.apply witness = P.y
  /-- Minimality -/
  minimal : ∀ f, T.apply f = P.y → tropWeight witness ≤ tropWeight f

/-! ## §7. Hecke-Stable Codes -/

/-- A **Hecke-stable code** is a set of codewords that is invariant under
    a family of Hecke operators. -/
structure HeckeStableCode (G : Type*) [Fintype G] [DecidableEq G] [Monoid G] where
  /-- The set of codewords in the code -/
  carrier : Set (Codeword G)
  /-- The encoding operator -/
  encoder : TropicalHeckeOperator G
  /-- The stabilizing family -/
  family : Finset (TropicalHeckeOperator G)
  /-- Stability: applying any family operator preserves membership -/
  stable : ∀ T ∈ family, ∀ f ∈ carrier, T.apply f ∈ carrier

/-! ## §8. Semiring Morphisms -/

/-- An **order-compatible tropical morphism** between weight types. -/
structure TropicalMorphism (Γ Δ : Type*) [LinearOrder Γ] [Add Γ]
    [LinearOrder Δ] [Add Δ] where
  /-- The underlying map -/
  toFun : Γ → Δ
  /-- Preserves addition -/
  map_add : ∀ a b, toFun (a + b) = toFun a + toFun b
  /-- Preserves order -/
  map_mono : Monotone toFun

end TropicalHeckeTrapdoor