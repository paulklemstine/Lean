/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Theorem A: Finite Prime-Congruence Separation for Certificate Semantics

## Main Results

* `exists_certificate_prime_separating` — **Theorem A**: distinct elements are
  separated by a certificate-compatible prime congruence.
* `exists_finite_spectral_separator` — the separator can be packaged finitely.
* `basicCertificateOpen_nonempty` — basic opens are nonempty for distinct pairs.
* `certificate_separation_from_bottom` — separation from the trivial congruence.
* `basicCertificateOpen_symm` — basic opens are symmetric.
* `certificateRep_injective_via_separation` — the representation is injective.
* `certificateObservable_eq_iff` — observable equality characterized.
* `separation_implies_quotient_distinction` — quotient-level separation.

## Bridge

This is the foundational separation theorem: the certificate spectrum is
rich enough to distinguish any two distinct semiring elements. Without
separation, no representation or extraction theorem is possible.
-/

import Mathlib
import Speculative.AutoResearch.TropicalProofCertificates.Basic

open Finset Function Set

noncomputable section

namespace TropicalProofCertificates

variable {S : Type*} [TropicalProofCertificateSemiring S]

/-- Bot RingCon relates only equal elements. -/
private theorem ringCon_bot_eq {a b : S} (h : (⊥ : RingCon S) a b) : a = b := by
  have : (⊥ : RingCon S).toSetoid.r a b := h
  rw [show (⊥ : RingCon S).toSetoid = ⊥ from rfl] at this
  exact this

/-! ## Theorem A: Prime Certificate Separation -/

/-- **Theorem A (Certificate Prime Separation).**
For any two distinct elements `a ≠ b` in a tropical proof certificate semiring,
there exists a certificate-compatible prime congruence separating them. -/
theorem exists_certificate_prime_separating {a b : S} (h : a ≠ b) :
    ∃ P : CertificatePrimeCongruence S, ¬ P.Rel a b := by
  have hbot : ¬ (⊥ : RingCon S) a b := fun hab => h (ringCon_bot_eq hab)
  obtain ⟨P, hne, hprime, _, hnsep, hcompat⟩ :=
    TropicalProofCertificateSemiring.prime_sep (⊥ : RingCon S) a b hbot
  exact ⟨⟨P, hne, hprime, hcompat⟩, hnsep⟩

/-- Distinct elements admit a finite spectral separator (singleton suffices). -/
theorem exists_finite_spectral_separator {a b : S} (h : a ≠ b) :
    ∃ _ : FiniteSpectralSeparator a b, True := by
  obtain ⟨P, hP⟩ := exists_certificate_prime_separating h
  exact ⟨⟨{P}, P, Finset.mem_singleton_self P, hP⟩, trivial⟩

/-- Basic certificate opens are nonempty for distinct elements. -/
theorem basicCertificateOpen_nonempty {a b : S} (h : a ≠ b) :
    (basicCertificateOpen a b).Nonempty :=
  let ⟨P, hP⟩ := exists_certificate_prime_separating h; ⟨P, hP⟩

/-- Separation from the trivial congruence. -/
theorem certificate_separation_from_bottom {a b : S} (h : a ≠ b) :
    ∃ P : CertificatePrimeCongruence S,
      (⊥ : RingCon S) ≤ P.toCongruence ∧ ¬ P.Rel a b := by
  have hbot : ¬ (⊥ : RingCon S) a b := fun hab => h (ringCon_bot_eq hab)
  obtain ⟨P, hne, hprime, hle, hnsep, hcompat⟩ :=
    TropicalProofCertificateSemiring.prime_sep (⊥ : RingCon S) a b hbot
  exact ⟨⟨P, hne, hprime, hcompat⟩, hle, hnsep⟩

/-- Separation from any congruence. -/
theorem exists_certificate_prime_over_congruence
    (C : RingCon S) {a b : S} (h : ¬ C a b) :
    ∃ P : CertificatePrimeCongruence S, C ≤ P.toCongruence ∧ ¬ P.Rel a b := by
  obtain ⟨P, hne, hprime, hle, hnsep, hcompat⟩ :=
    TropicalProofCertificateSemiring.prime_sep C a b h
  exact ⟨⟨P, hne, hprime, hcompat⟩, hle, hnsep⟩

/-- Basic opens are symmetric. -/
theorem basicCertificateOpen_symm (a b : S) :
    basicCertificateOpen a b = basicCertificateOpen b a := by
  ext P; simp only [basicCertificateOpen, Set.mem_setOf_eq, CertificatePrimeCongruence.Rel]
  exact not_congr ⟨P.toCongruence.symm, P.toCongruence.symm⟩

/-- Certificate observable equality is characterized by agreement at all primes. -/
theorem certificateObservable_eq_iff (a b : S) :
    certificateObservable a = certificateObservable b ↔
    ∀ P : certificateSpec S, P.Rel a 0 ↔ P.Rel b 0 := by
  constructor
  · intro h P
    have := congr_fun h P
    simp only [certificateObservable] at this
    exact not_iff_not.mp (iff_of_eq this)
  · intro h
    ext P
    simp only [certificateObservable]
    exact not_iff_not.mpr (h P)

/-- The full representation map is injective: distinct elements are
distinguished by some certificate prime congruence. -/
theorem certificateRep_injective_via_separation :
    ∀ a b : S, a ≠ b →
    ∃ P : CertificatePrimeCongruence S, ¬ P.Rel a b :=
  fun _ _ h => exists_certificate_prime_separating h

/-- For any `a ≠ b`, the quotient images of `a` and `b` differ at some
certificate prime. This is the quotient-level formulation of separation. -/
theorem separation_implies_quotient_distinction {a b : S} (h : a ≠ b) :
    ∃ P : CertificatePrimeCongruence S,
      P.toCongruence.toQuotient a ≠ P.toCongruence.toQuotient b := by
  obtain ⟨P, hP⟩ := exists_certificate_prime_separating h
  exact ⟨P, fun heq => hP (P.toCongruence.eq.mp heq)⟩

/-- Separation is preserved under the product map: the encoding into
products of quotients is injective. -/
theorem product_encoding_injective :
    ∀ a b : S, (∀ P : CertificatePrimeCongruence S, P.Rel a b) → a = b := by
  intro a b hall
  by_contra h
  obtain ⟨P, hP⟩ := exists_certificate_prime_separating h
  exact hP (hall P)

/-- The intersection of all certificate prime congruences is the identity
(equality). This is the spectral density / faithfulness theorem. -/
theorem sInf_certificate_primes_eq_bot :
    ∀ a b : S, (∀ P : CertificatePrimeCongruence S, P.Rel a b) → a = b :=
  product_encoding_injective

end TropicalProofCertificates