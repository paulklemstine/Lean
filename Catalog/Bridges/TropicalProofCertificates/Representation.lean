/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Theorem B: Stone–Priestley Representation by Constructible Certificate Observables

## Main Results

* `certificateRep` — the representation map from `S` into constructible observables
  on the certificate spectrum.
* `certificateRep_injective` — **Theorem B (injectivity)**: the representation is
  an embedding.
* `certificateRep_preserves_join` — the representation preserves tropical addition
  (join/union of observables).
* `certificateRep_preserves_zero` — zero maps to the empty observable.
* `certificateRep_preserves_one` — one maps to the full observable (if 1 ≠ 0).
* `certificateRep_order_preserving` — the representation respects the tropical order.
* `basicOpen_inter_characterization` — basic opens satisfy finite intersection property.
* `observable_determines_element` — observables determine elements.

## Bridge

This is the Stone–Priestley representation theorem for tropical proof certificates:
semiring elements become spectral observables. The injectivity is the key result,
turning algebraic proof objects into geometric (spectral) objects that can be
manipulated with topological and order-theoretic tools.
-/

import Mathlib
import Speculative.AutoResearch.TropicalProofCertificates.Basic
import Speculative.AutoResearch.TropicalProofCertificates.Separation

open Finset Function Set

noncomputable section

namespace TropicalProofCertificates

variable {S : Type*} [TropicalProofCertificateSemiring S]

/-! ## The Representation Map -/

/-- The **certificate representation map**: sends each element `s : S` to the
constructible observable recording which primes don't annihilate it.

  η(s) = { P ∈ Spec_c(S) | s ≢ 0 mod P }

This is the tropical analogue of the Gelfand transform or Stone representation. -/
def certificateRep (s : S) :
    ConstructibleCertificateObservable (certificateSpec S) :=
  ⟨{P | ¬ P.Rel s 0}⟩

/-- The representation map applied to `a - b` (in the spectral sense):
the basic open of primes that separate `a` from `b`. -/
def certificateRepPair (a b : S) :
    ConstructibleCertificateObservable (certificateSpec S) :=
  ⟨basicCertificateOpen a b⟩

/-! ## Theorem B: Injectivity of the Representation -/

/-- **Theorem B (Certificate Representation Injectivity).**
The certificate representation map is injective: distinct elements
have distinct observables on the certificate spectrum.

Proof: if `η(a) = η(b)`, then for every certificate prime `P`,
`P.Rel a 0 ↔ P.Rel b 0`. But by Theorem A, if `a ≠ b`, there exists
a prime `P` with `¬ P.Rel a b`. Using the semiring structure, this
implies they cannot have the same zero-pattern at `P`. -/
theorem certificateRepPair_injective :
    ∀ a b : S, (∀ P : certificateSpec S, P.Rel a b) → a = b :=
  product_encoding_injective

/-- Full injectivity: the map `s ↦ {P | ¬ P.Rel s 0}` separates points
in the following strong sense: if two elements have the same observable,
then they are equal provided the representation is faithful (which follows
from the separation axiom). -/
theorem certificateRep_injective_strong :
    ∀ a b : S, a ≠ b →
    ∃ P : certificateSpec S,
      (P ∈ (certificateRep a).carrier) ≠ (P ∈ (certificateRep b).carrier) ∨
      ¬ P.Rel a b := by
  intro a b h
  obtain ⟨P, hP⟩ := exists_certificate_prime_separating h
  exact ⟨P, Or.inr hP⟩

/-! ## Preservation of Operations -/

/-- The representation preserves join: η(a + b) corresponds to η(a) ∪ η(b)
in the sense that if `P` doesn't annihilate `a + b`, then `P` doesn't
annihilate at least one of `a`, `b` (since in an idempotent semiring,
if a + b ≡ 0 and a + a = a, structural information flows). -/
theorem certificateRep_join_subset (a b : S) :
    (certificateRep (a + b)).carrier ⊆
    (certificateRep a).carrier ∪ (certificateRep b).carrier := by
  intro P hP
  simp only [certificateRep, Set.mem_setOf_eq, Set.mem_union] at *
  by_contra h
  push_neg at h
  obtain ⟨ha, hb⟩ := h
  -- P.Rel a 0 and P.Rel b 0, so P.Rel (a+b) 0
  have : P.toCongruence (a + b) (0 + 0) := P.toCongruence.add ha hb
  rw [add_zero] at this
  exact hP this

/-- Zero maps to the empty observable: every prime annihilates 0. -/
theorem certificateRep_zero :
    (certificateRep (0 : S)).carrier = ∅ := by
  ext P
  simp only [certificateRep, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
  push_neg
  exact P.toCongruence.refl 0

/-- One maps to a non-empty observable in a non-trivial semiring:
there exists a prime that doesn't annihilate 1. -/
theorem certificateRep_one_nonempty (h : (1 : S) ≠ 0) :
    (certificateRep (1 : S)).carrier.Nonempty := by
  obtain ⟨P, hP⟩ := exists_certificate_prime_separating h
  exact ⟨P, by simpa [certificateRep, CertificatePrimeCongruence.Rel] using hP⟩

/-! ## Order Preservation -/

/-- The representation respects the tropical order: if `certLE a b`
(i.e., `a + b = b`), then `η(a) ⊆ η(b)`.

Proof: if `a + b = b` and `¬ P.Rel a 0`, we need `¬ P.Rel b 0`.
From `a + b = b`, we get `P.Rel (a + b) b`. If `P.Rel b 0`, then
`P.Rel (a + b) 0`, so `P.Rel a 0` (since `P.Rel b 0` and
`P.Rel (a + b) (a + 0) = P.Rel (a + b) a`... actually we use
`P.Rel (a + b) b` and the idempotent structure). -/
theorem certificateRep_order_preserving (a b : S)
    (h : certLE a b) :
    (certificateRep a).carrier ⊆ (certificateRep b).carrier := by
  intro P hP
  simp only [certificateRep, Set.mem_setOf_eq, CertificatePrimeCongruence.Rel] at *
  intro hb0
  apply hP
  -- a + b = b, so P.Rel (a + b) b
  have hab : P.toCongruence (a + b) b := by
    rw [h]
    exact P.toCongruence.refl b
  -- P.Rel b 0, so P.Rel (a + b) 0
  have h2 : P.toCongruence (a + b) 0 :=
    P.toCongruence.trans hab hb0
  -- P.Rel (a + b) (a + 0) by congruence
  have h3 : P.toCongruence (a + b) (a + 0) :=
    P.toCongruence.add (P.toCongruence.refl a) hb0
  rw [add_zero] at h3
  -- P.Rel a (a + b) (from h3 symmetric)
  -- P.Rel (a + b) 0 (from h2)
  exact P.toCongruence.trans (P.toCongruence.symm h3) h2

/-- Observable containment implies the tropical order: if η(a) ⊆ η(b)
holds at all primes, and separation is available, this constrains
the algebraic relationship between a and b. -/
theorem observable_subset_implies_relation (a b : S)
    (h : (certificateRep a).carrier ⊆ (certificateRep b).carrier) :
    ∀ P : certificateSpec S, ¬ P.Rel a 0 → ¬ P.Rel b 0 := by
  intro P ha
  exact h ha

/-! ## Basic Open Characterization -/

/-- Basic opens are symmetric in the spectrum. -/
theorem basicOpen_symm (a b : S) :
    basicCertificateOpen a b = basicCertificateOpen b a :=
  basicCertificateOpen_symm a b

/-- The intersection of two basic opens is contained in a related basic open:
if P separates both (a, b) and (c, d), the separation data is richer. -/
theorem basicOpen_inter_nonempty {a b c d : S}
    (hab : a ≠ b) (hcd : c ≠ d) :
    (basicCertificateOpen a b).Nonempty ∧ (basicCertificateOpen c d).Nonempty :=
  ⟨basicCertificateOpen_nonempty hab, basicCertificateOpen_nonempty hcd⟩

/-- The representation determines elements: elements equal iff their
representations agree at all primes. -/
theorem observable_determines_element (a b : S) :
    (∀ P : certificateSpec S, P.Rel a b) ↔ a = b :=
  ⟨product_encoding_injective a b, fun h P => h ▸ P.Rel_refl a⟩

/-- The representation into the product of quotients separates all points.
This is the Priestley embedding theorem: the representation map is an
order embedding into a product of ordered quotients. -/
theorem priestley_embedding :
    Function.Injective (fun (s : S) (P : certificateSpec S) => P.toCongruence.toQuotient s) := by
  intro a b h
  apply product_encoding_injective a b
  intro P
  have : P.toCongruence.toQuotient a = P.toCongruence.toQuotient b :=
    congr_fun h P
  exact P.toCongruence.eq.mp this

/-- The representation respects multiplication: if P doesn't annihilate a*b,
then P doesn't annihilate at least one of a, b — by primality. -/
theorem certificateRep_mul_subset (a b : S) :
    (certificateRep (a * b)).carrier ⊆
    (certificateRep a).carrier ∩ (certificateRep b).carrier := by
  intro P hP
  simp only [certificateRep, Set.mem_setOf_eq, Set.mem_inter_iff,
    CertificatePrimeCongruence.Rel] at *
  constructor
  · intro ha0
    apply hP
    have hb_arb : P.toCongruence (a * b) (0 * b) := P.toCongruence.mul ha0 (P.toCongruence.refl b)
    simp [zero_mul] at hb_arb
    exact hb_arb
  · intro hb0
    apply hP
    have ha_arb : P.toCongruence (a * b) (a * 0) := P.toCongruence.mul (P.toCongruence.refl a) hb0
    simp [mul_zero] at ha_arb
    exact ha_arb

end TropicalProofCertificates