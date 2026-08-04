/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Schnorr transcripts and the forking extractor

Basic data for the algebraic analysis of Schnorr witness extraction: a
transcript `(a, c, z)`, the verification predicate `z * gen = a + c * pub`, a
*forked* pair of transcripts sharing the commitment `a` but with distinct
challenges, and the extractor `(z₁ - z₂) * (c₁ - c₂)⁻¹`.

These definitions are used by `Cryptography.GameTheory.Extraction`.
-/

variable {q : ℕ}

/-- A Schnorr transcript: commitment `a`, challenge `c`, response `z`. -/
structure SchnorrTranscript (q : ℕ) where
  /-- The commitment. -/
  a : ZMod q
  /-- The challenge. -/
  c : ZMod q
  /-- The response. -/
  z : ZMod q

/-- The Schnorr verification equation `z * gen = a + c * pub`. -/
def schnorrVerifies (gen pub : ZMod q) (T : SchnorrTranscript q) : Prop :=
  T.z * gen = T.a + T.c * pub

/-- Two Schnorr transcripts sharing a commitment, with distinct challenges: the
output of a successful forking. -/
structure ForkedTranscript (q : ℕ) where
  /-- The common commitment. -/
  a : ZMod q
  /-- The first challenge. -/
  c₁ : ZMod q
  /-- The second challenge. -/
  c₂ : ZMod q
  /-- The first response. -/
  z₁ : ZMod q
  /-- The second response. -/
  z₂ : ZMod q
  /-- The two challenges differ; this is what makes extraction possible. -/
  hneq : c₁ ≠ c₂

/-- The Schnorr witness extractor applied to a forked pair of transcripts. -/
def schnorrExtract (ft : ForkedTranscript q) : ZMod q :=
  (ft.z₁ - ft.z₂) * (ft.c₁ - ft.c₂)⁻¹

@[simp] theorem schnorrVerifies_def (gen pub : ZMod q) (T : SchnorrTranscript q) :
    schnorrVerifies gen pub T ↔ T.z * gen = T.a + T.c * pub := Iff.rfl

/-- The honest Schnorr prover always verifies. -/
theorem schnorrVerifies_honest (gen x r c : ZMod q) :
    schnorrVerifies gen (x * gen) ⟨r * gen, c, r + c * x⟩ := by
  simp only [schnorrVerifies]
  ring