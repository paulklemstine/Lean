/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Proof Certificate Semirings: Basic Definitions

## Overview

This file defines the core algebraic structures for **Stone–Priestley duality
of tropical proof certificates**:

- `TropicalProofCertificateSemiring S` — a commutative semiring with idempotent
  addition, observers, and separation by compatible primes
- `CertificatePrimeCongruence S` — a prime ring congruence compatible with observers
- `certificateSpec S` — the prime congruence spectrum
- `certificateObservable` — the observable induced by a semiring element
- `ConstructibleCertificateObservable` — observables on the spectrum
- `ExtractedVerifier` / `ReversibleTraceAutomaton` — finite verifiers

## Bridge

Connects idempotent algebra → spectral geometry → certified computation →
proof complexity.
-/

import Mathlib

open Finset Function Set

noncomputable section

universe u v

namespace TropicalProofCertificates

/-! ## §1. Tropical Proof Certificate Semiring -/

/-- A **tropical proof certificate semiring** is a commutative semiring with
idempotent addition, observers, monotonicity, and certificate-compatible
prime separation. -/
class TropicalProofCertificateSemiring (S : Type u) extends CommSemiring S where
  add_idem : ∀ a : S, a + a = a
  Observer : Type u
  evalObs : Observer → S → Prop
  obs_mono : ∀ (o : Observer) (a b : S), a + b = b → evalObs o a → evalObs o b
  prime_sep : ∀ (C : RingCon S) (a b : S), ¬ C a b →
    ∃ P : RingCon S,
      (P ≠ ⊤) ∧
      (∀ {x y : S}, P (x * y) 0 → P x 0 ∨ P y 0) ∧
      (C ≤ P) ∧
      (¬ P a b) ∧
      (∀ (o : Observer) (x y : S), P x y → (evalObs o x ↔ evalObs o y))

variable {S : Type u} [TropicalProofCertificateSemiring S]

/-- The canonical tropical preorder: `a ≤_cert b` iff `a + b = b`. -/
def certLE (a b : S) : Prop := a + b = b

theorem certLE_refl (a : S) : certLE a a :=
  TropicalProofCertificateSemiring.add_idem a

theorem certLE_trans (a b c : S) (hab : certLE a b) (hbc : certLE b c) :
    certLE a c := by
  unfold certLE at *
  calc a + c = a + (b + c) := by rw [hbc]
    _ = (a + b) + c := (add_assoc a b c).symm
    _ = b + c := by rw [hab]
    _ = c := hbc

/-! ## §2. Certificate-Compatible Prime Congruences -/

/-- A **certificate prime congruence**: prime, proper, observer-compatible. -/
structure CertificatePrimeCongruence (S : Type u)
    [TropicalProofCertificateSemiring S] where
  toCongruence : RingCon S
  ne_top : toCongruence ≠ ⊤
  isPrime : ∀ {a b : S}, toCongruence (a * b) 0 →
    toCongruence a 0 ∨ toCongruence b 0
  obsCompat : ∀ (o : TropicalProofCertificateSemiring.Observer (S := S)) (x y : S),
    toCongruence x y →
    (TropicalProofCertificateSemiring.evalObs o x ↔
     TropicalProofCertificateSemiring.evalObs o y)

/-- The relation of a certificate prime congruence. -/
def CertificatePrimeCongruence.Rel
    (P : CertificatePrimeCongruence S) (a b : S) : Prop :=
  P.toCongruence a b

theorem CertificatePrimeCongruence.Rel_refl
    (P : CertificatePrimeCongruence S) (a : S) : P.Rel a a :=
  P.toCongruence.refl a

theorem CertificatePrimeCongruence.Rel_symm
    (P : CertificatePrimeCongruence S) {a b : S}
    (h : P.Rel a b) : P.Rel b a :=
  P.toCongruence.symm h

theorem CertificatePrimeCongruence.Rel_trans
    (P : CertificatePrimeCongruence S) {a b c : S}
    (hab : P.Rel a b) (hbc : P.Rel b c) : P.Rel a c :=
  P.toCongruence.trans hab hbc

/-- The **certificate spectrum**. -/
def certificateSpec (S : Type u) [TropicalProofCertificateSemiring S] :=
  CertificatePrimeCongruence S

/-- A basic open in the certificate spectrum: primes separating a, b. -/
def basicCertificateOpen (a b : S) : Set (certificateSpec S) :=
  {P | ¬ P.Rel a b}

/-! ## §3. Certificate Observables -/

/-- The observable for `s`: primes where `s` is non-zero. -/
def certificateObservable (s : S) : certificateSpec S → Prop :=
  fun P => ¬ P.Rel s 0

/-- A **constructible certificate observable** on a spectrum. -/
structure ConstructibleCertificateObservable (Spec : Type u) where
  carrier : Set Spec

/-- Join of constructible observables. -/
def ConstructibleCertificateObservable.join {Spec : Type u}
    (O₁ O₂ : ConstructibleCertificateObservable Spec) :
    ConstructibleCertificateObservable Spec :=
  ⟨O₁.carrier ∪ O₂.carrier⟩

/-- Meet of constructible observables. -/
def ConstructibleCertificateObservable.meet {Spec : Type u}
    (O₁ O₂ : ConstructibleCertificateObservable Spec) :
    ConstructibleCertificateObservable Spec :=
  ⟨O₁.carrier ∩ O₂.carrier⟩

/-- Empty observable. -/
def ConstructibleCertificateObservable.empty (Spec : Type u) :
    ConstructibleCertificateObservable Spec := ⟨∅⟩

/-- Universal observable. -/
def ConstructibleCertificateObservable.full (Spec : Type u) :
    ConstructibleCertificateObservable Spec := ⟨Set.univ⟩

/-! ## §4. Finite Spectral Separators -/

/-- A finite spectral separator for a pair `(a, b)`. -/
structure FiniteSpectralSeparator (a b : S) where
  primes : Finset (CertificatePrimeCongruence S)
  separates : ∃ P ∈ primes, ¬ P.Rel a b

/-! ## §5. Extracted Verifiers -/

/-- An **extracted verifier**: a finite-state acceptor. -/
structure ExtractedVerifier (α : Type*) where
  State : Type
  [finSt : Fintype State]
  [inhSt : Inhabited State]
  step : State → α → State
  start : State
  accept : State → Bool

attribute [instance] ExtractedVerifier.finSt ExtractedVerifier.inhSt

/-- The number of states. -/
def verifierStateComplexity {α : Type*} (V : ExtractedVerifier α) : ℕ :=
  @Fintype.card V.State V.finSt

/-- A **reversible trace automaton** with invertible transitions. -/
structure ReversibleTraceAutomaton (α : Type*) where
  State : Type
  [finSt : Fintype State]
  [inhSt : Inhabited State]
  step : State → α → State
  revStep : State → α → State
  left_inv : ∀ q a, revStep (step q a) a = q
  start : State
  accept : State → Bool

attribute [instance] ReversibleTraceAutomaton.finSt ReversibleTraceAutomaton.inhSt

/-- Convert a reversible automaton to a verifier. -/
def ReversibleTraceAutomaton.toVerifier {α : Type*}
    (A : ReversibleTraceAutomaton α) : ExtractedVerifier α where
  State := A.State
  step := A.step
  start := A.start
  accept := A.accept

/-- Reversible automaton step is injective in the state argument. -/
theorem ReversibleTraceAutomaton.step_injective {α : Type*}
    (A : ReversibleTraceAutomaton α) (a : α) :
    Function.Injective (fun q => A.step q a) := by
  intro q₁ q₂ h
  simp only at h
  have h₁ := A.left_inv q₁ a
  have h₂ := A.left_inv q₂ a
  rw [h] at h₁; exact h₁.symm.trans h₂

/-- A verifier **realizes** an observable. -/
def realizesObservable' {α X : Type*}
    (V : ExtractedVerifier α) (O : X → Prop) (stateOf : X → V.State) : Prop :=
  ∀ x : X, V.accept (stateOf x) = true ↔ O x

/-! ## §6. Proof Trace Alphabet and Finite Generation -/

/-- The **proof trace alphabet**. -/
def ProofTraceAlphabet (S : Type u) [TropicalProofCertificateSemiring S] := S

/-- **Finitely generated** certificate semiring. -/
class FinitelyGeneratedCertificateSemiring (S : Type u)
    [TropicalProofCertificateSemiring S] where
  generators : Finset S
  generates : ∀ s : S, s ∈ Subsemiring.closure (generators : Set S)

end TropicalProofCertificates