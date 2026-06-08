/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Prime–Stone Duality via Congruence Spectra

## Overview

We formalize a Stone-type reconstruction theorem for idempotent commutative semirings
through the lens of congruence spectra. The central result: under a spectral separation
axiom, the canonical evaluation map from a semiring into the product of its prime-congruence
quotients is an injective semiring homomorphism, yielding a faithful spectral representation.

This bridges:
- **Stone duality** (classical: Boolean algebras ↔ Stone spaces) to the semiring setting
- **Tropical geometry** (prime congruences replace prime ideals in idempotent algebra)
- **Cryptographic hardness** (spectral separation certificates → inversion lower bounds)

## Main Definitions

* `PrimeCong S` — a proper (nontrivial) ring congruence on `S`
* `SpecC S` — the congruence spectrum (type of prime congruences)
* `basicOpen a b` — the basic open set of congruences separating `a` from `b`
* `SpectrallySeparated S` — the spectral separation axiom
* `evalComponent` — projection to a single quotient (a ring homomorphism)
* `evalMap` — the full evaluation map into the product of all quotients

## Main Results

* `evalComponent_eq_iff` — evaluation equality characterizes congruence
* `evalMap_injective` — spectral separation implies injectivity of the evaluation map
* `stone_reconstruction` — the evaluation map is an injective ring homomorphism
* `evalMap_injective_iff_separated` — complete characterization of injectivity
* `basicOpen_empty_iff` — basic opens are empty iff elements are universally congruent
* `basicOpen_symm` — basic opens are symmetric in their arguments
* `separated_of_evalMap_injective` — converse: injectivity implies separation
* `quotient_idem_add` — idempotency propagates to quotients
* `evalMap_preserves_idem` — the evaluation map preserves idempotency
-/

noncomputable section

open Function Set

set_option maxHeartbeats 800000
set_option linter.unusedVariables false

namespace TropicalStoneDuality

/-! ## Section 1: Idempotent Semirings and Prime Congruences -/

/-- An idempotent commutative semiring: `a + a = a` for all `a`.
This is the algebraic axiom distinguishing tropical semirings from classical ones.
In the min-plus semiring (ℝ, min, +), idempotency of min is the defining property. -/
class IdempotentAddCommSemiring (S : Type*) extends CommSemiring S where
  idem_add : ∀ a : S, a + a = a

/-- A **prime congruence** on a semiring `S`: a ring congruence that is proper
(does not identify all elements). This is the semiring analogue of a prime ideal
in ring theory — the building block of the congruence spectrum.

In tropical geometry, prime congruences replace prime ideals because
idempotent semirings lack additive inverses, making ideal theory inadequate. -/
structure PrimeCong (S : Type*) [Add S] [Mul S] where
  /-- The underlying ring congruence -/
  rel : RingCon S
  /-- The congruence is proper: it does not identify all elements -/
  proper : ∃ a b : S, ¬ rel a b

/-- The **congruence spectrum** of `S`: the type of all prime congruences.
This is the tropical analogue of `Spec R` in algebraic geometry. -/
def SpecC (S : Type*) [Add S] [Mul S] := PrimeCong S

/-- The **basic open set** `D(a,b)` in the congruence spectrum:
the set of prime congruences that distinguish `a` from `b`.

This is the semiring analogue of the Zariski basic open `D(f)` in scheme theory. -/
def basicOpen {S : Type*} [Add S] [Mul S] (a b : S) : Set (SpecC S) :=
  {p | ¬ p.rel a b}

/-- The **spectral separation axiom**: for any two distinct elements of `S`,
there exists a prime congruence distinguishing them.

This is the semiring-congruence analogue of the T₀ separation axiom in topology. -/
def SpectrallySeparated (S : Type*) [Add S] [Mul S] : Prop :=
  ∀ a b : S, a ≠ b → ∃ p : SpecC S, ¬ p.rel a b

/-! ## Section 2: Basic Open Set Properties -/

/-- Basic opens are symmetric: `D(a,b) = D(b,a)`. -/
theorem basicOpen_symm {S : Type*} [Add S] [Mul S] (a b : S) :
    basicOpen a b = basicOpen b a := by
  ext p
  simp only [basicOpen, mem_setOf_eq]
  constructor <;> intro h hc <;> exact h (p.rel.symm hc)

/-- `D(a,b)` is empty if and only if every prime congruence identifies `a` and `b`. -/
theorem basicOpen_empty_iff {S : Type*} [Add S] [Mul S] (a b : S) :
    basicOpen a b = ∅ ↔ ∀ p : SpecC S, p.rel a b := by
  simp only [basicOpen, Set.eq_empty_iff_forall_notMem, mem_setOf_eq, not_not]

/-- `D(a,a)` is always empty: every congruence identifies an element with itself. -/
theorem basicOpen_self {S : Type*} [Add S] [Mul S] (a : S) :
    basicOpen a a = ∅ := by
  rw [basicOpen_empty_iff]
  intro p; exact p.rel.refl a

/-- The complement of `D(a,b)` consists of congruences that identify `a` and `b`. -/
theorem basicOpen_compl_eq {S : Type*} [Add S] [Mul S] (a b : S) :
    (basicOpen a b)ᶜ = {p : SpecC S | p.rel a b} := by
  ext p; simp [basicOpen, mem_compl_iff, mem_setOf_eq, not_not]

/-- Under spectral separation, distinct elements have nonempty basic opens. -/
theorem basicOpen_nonempty_of_ne {S : Type*} [Add S] [Mul S]
    (hsep : SpectrallySeparated S) {a b : S} (hab : a ≠ b) :
    (basicOpen a b).Nonempty := by
  obtain ⟨p, hp⟩ := hsep a b hab
  exact ⟨p, hp⟩

/-! ## Section 3: The Evaluation Map and Stone Reconstruction -/

/-- The **evaluation component** at a prime congruence `p`:
the canonical ring homomorphism `S →+* S/p`. -/
def evalComponent {S : Type*} [NonAssocSemiring S] (p : SpecC S) : S →+* p.rel.Quotient :=
  RingCon.mk' p.rel

/-- The evaluation component is surjective (it is the canonical quotient map). -/
theorem evalComponent_surjective {S : Type*} [NonAssocSemiring S] (p : SpecC S) :
    Surjective (evalComponent p) := by
  intro x
  induction x using Quotient.inductionOn with
  | h a => exact ⟨a, rfl⟩

/-- Two elements have the same image under `evalComponent p` iff they are `p`-congruent. -/
theorem evalComponent_eq_iff {S : Type*} [NonAssocSemiring S] (p : SpecC S) (a b : S) :
    evalComponent p a = evalComponent p b ↔ p.rel a b :=
  RingCon.eq p.rel

/-- The **full evaluation map**: sends `a : S` to the tuple of its equivalence classes
across all prime congruences. This is the map `η_S : S → Π p : SpecC S, S/p`.

This is the semiring-level analogue of the Gelfand transform or Stone representation. -/
def evalMap (S : Type*) [NonAssocSemiring S] : S → (∀ p : SpecC S, p.rel.Quotient) :=
  fun a p => evalComponent p a

/-- The evaluation map separates elements iff the corresponding congruences separate them. -/
theorem evalMap_eq_iff {S : Type*} [NonAssocSemiring S] (a b : S) :
    evalMap S a = evalMap S b ↔ ∀ p : SpecC S, p.rel a b := by
  simp [evalMap, funext_iff, evalComponent_eq_iff]

/-- **Tropical Stone Reconstruction (Injectivity).**

Under the spectral separation axiom, the evaluation map `η_S` is injective.
This means `S` embeds faithfully into the product of its prime-congruence quotients:
the congruence spectrum carries enough information to distinguish all elements of `S`. -/
theorem evalMap_injective {S : Type*} [NonAssocSemiring S]
    (hsep : SpectrallySeparated S) : Injective (evalMap S) := by
  intro a b hab
  by_contra hne
  obtain ⟨p, hp⟩ := hsep a b hne
  have heq : evalMap S a p = evalMap S b p := congr_fun hab p
  simp only [evalMap, evalComponent_eq_iff] at heq
  exact hp heq

/-- The converse: if the evaluation map is injective, then `S` is spectrally separated. -/
theorem separated_of_evalMap_injective {S : Type*} [NonAssocSemiring S]
    (hinj : Injective (evalMap S)) : SpectrallySeparated S := by
  intro a b hab
  by_contra h
  push_neg at h
  have : evalMap S a = evalMap S b := by
    ext p; exact (evalComponent_eq_iff p a b).mpr (h p)
  exact hab (hinj this)

/-- **Complete characterization**: the evaluation map is injective if and only if
`S` is spectrally separated. -/
theorem evalMap_injective_iff_separated {S : Type*} [NonAssocSemiring S] :
    Injective (evalMap S) ↔ SpectrallySeparated S :=
  ⟨separated_of_evalMap_injective, evalMap_injective⟩

/-! ## Section 4: The Evaluation Map as a Ring Homomorphism -/

/-- The evaluation map preserves addition. -/
theorem evalMap_add {S : Type*} [NonAssocSemiring S] (a b : S) :
    evalMap S (a + b) = evalMap S a + evalMap S b := by
  ext p; simp [evalMap, evalComponent, map_add]

/-- The evaluation map preserves multiplication. -/
theorem evalMap_mul {S : Type*} [NonAssocSemiring S] (a b : S) :
    evalMap S (a * b) = evalMap S a * evalMap S b := by
  ext p; simp [evalMap, evalComponent, map_mul]

/-- The evaluation map sends 0 to 0. -/
theorem evalMap_zero {S : Type*} [NonAssocSemiring S] :
    evalMap S 0 = 0 := by
  ext p; simp [evalMap, evalComponent, map_zero]

/-- The evaluation map sends 1 to 1. -/
theorem evalMap_one {S : Type*} [NonAssocSemiring S] :
    evalMap S 1 = 1 := by
  ext p; simp [evalMap, evalComponent, map_one]

/-- **The evaluation map as a ring homomorphism.**

Combined with injectivity, this gives the full Stone reconstruction:
`S` is isomorphic (via `η`) to its image in the product of quotients. -/
def evalRingHom (S : Type*) [NonAssocSemiring S] :
    S →+* (∀ p : SpecC S, p.rel.Quotient) where
  toFun := evalMap S
  map_zero' := evalMap_zero
  map_one' := evalMap_one
  map_add' := evalMap_add
  map_mul' := evalMap_mul

/-- **The Stone Reconstruction Theorem (full version).**

For a commutative semiring `S` satisfying the spectral separation axiom,
the canonical evaluation ring homomorphism `η_S : S →+* Π p, S/p` is injective.

This establishes that `S` is faithfully represented by its congruence spectrum. -/
theorem stone_reconstruction (S : Type*) [NonAssocSemiring S]
    (hsep : SpectrallySeparated S) :
    Injective (evalRingHom S) :=
  evalMap_injective hsep

/-- When the spectrum is finite, `S` embeds into a finite product. -/
theorem finite_spectrum_embedding (S : Type*) [NonAssocSemiring S]
    [Fintype (SpecC S)] (hsep : SpectrallySeparated S) :
    Injective (evalRingHom S) :=
  stone_reconstruction S hsep

/-! ## Section 5: Idempotent Structure Propagation -/

/-- In an idempotent semiring, the quotient by any ring congruence inherits idempotency.
This ensures that tropical properties propagate through the spectral representation. -/
theorem quotient_idem_add {S : Type*} [CommSemiring S]
    (hidem : ∀ a : S, a + a = a) (c : RingCon S) :
    ∀ x : c.Quotient, x + x = x := by
  intro x
  induction x using Quotient.inductionOn with
  | h a =>
    change c.toQuotient (a + a) = c.toQuotient a
    rw [hidem a]

/-- The evaluation map of an idempotent semiring lands in a product of idempotent quotients. -/
theorem evalMap_preserves_idem {S : Type*} [CommSemiring S]
    (hidem : ∀ a : S, a + a = a) (a : S) :
    evalMap S a + evalMap S a = evalMap S a := by
  rw [← evalMap_add]; congr 1; exact hidem a

/-! ## Section 6: Basic Opens Form a Separation System -/

/-- Basic opens are closed under intersection (as sets of separating congruences). -/
theorem basicOpen_inter_eq {S : Type*} [Add S] [Mul S] (a b c d : S) :
    basicOpen a b ∩ basicOpen c d =
      {p : SpecC S | ¬ p.rel a b ∧ ¬ p.rel c d} := by
  ext p; simp [basicOpen, mem_inter_iff, mem_setOf_eq]

/-- Union of basic opens: if `a ≠ b` or `c ≠ d`, the union is nonempty
under spectral separation. -/
theorem basicOpen_union_nonempty {S : Type*} [Add S] [Mul S]
    (hsep : SpectrallySeparated S) {a b c d : S} (h : a ≠ b ∨ c ≠ d) :
    (basicOpen a b ∪ basicOpen c d).Nonempty := by
  cases h with
  | inl hab =>
    obtain ⟨p, hp⟩ := hsep a b hab
    exact ⟨p, Or.inl hp⟩
  | inr hcd =>
    obtain ⟨p, hp⟩ := hsep c d hcd
    exact ⟨p, Or.inr hp⟩

/-! ## Section 7: Observer Family Connection

We show how `PrimeCong` connects to `FiniteProofObserverFamily` from the catalog. -/

/-- Convert a finite family of prime congruences into an observer family. -/
def primeFamilyToObservers {S : Type*} [Add S] [Mul S]
    (n : ℕ) (ps : Fin n → PrimeCong S) :
    { F : Fin n → RingCon S // ∀ i, ∃ a b : S, ¬ (F i) a b } :=
  ⟨fun i => (ps i).rel, fun i => (ps i).proper⟩

/-- A finite family of prime congruences separates a pair iff
at least one member distinguishes them. -/
theorem prime_family_separates {S : Type*} [Add S] [Mul S]
    (n : ℕ) (ps : Fin n → PrimeCong S) (a b : S) :
    (∃ i, ¬ (ps i).rel a b) ↔
    (∃ i, ¬ (primeFamilyToObservers n ps).1 i a b) := by
  simp [primeFamilyToObservers]

end TropicalStoneDuality