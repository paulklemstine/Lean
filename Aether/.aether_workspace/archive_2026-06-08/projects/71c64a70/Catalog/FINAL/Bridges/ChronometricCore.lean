/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chronometric Semiring Dynamics: Core Algebra and Spectral Semantics

Bridge: connects temporal involution to prime-spectrum semantics.
Bridge: connects idempotent semiring path aggregation to lipschitz_certified_robustness.
Bridge: connects causal closure to post_quantum_security protocol transcripts.

## Overview

This file formalizes **chronometric semirings** — idempotent semirings equipped with an
involutive time-reversal anti-automorphism and a causal closure operator on subsets.

## Main definitions

* `ChronometricSemiring` — idempotent semiring + time reversal + causal closure
* `chronoLE` — canonical preorder from idempotent addition
* `CanonicallyOrderedChronometricSemiring` — with antisymmetric canonical order
* `ChronoSemiringCong` — semiring congruence for chronometric semirings
* `TimeRevCongruence` — congruence stable under time reversal
* `TimeRevStable` — predicate for time-reversal invariant subsets
* `ChronoPrime` — prime congruence closed under reversal and causal closure
* `ChronoSpec` — the prime spectrum of chrono-prime congruences
* `chronoZeroLocus` / `chronoBasicOpen` — Zariski-style spectral sets
* `HasChronoPrimeSeparation` — prime separation axiom class
* `IsCausalFixedPoint` — characterization of causally closed sets
* `QuantumTraceSymmetric` — time-reversal fixed points
* `CongSaturated` — saturation under congruence

## Main results

* `chronoLE_refl`, `chronoLE_trans` — canonical preorder properties
* `thermodynamic_rev_rev_collapse` — time reversal is involutive
* `timeRev_mul_flip` — time reversal is an anti-automorphism on products
* `chronoZeroLocus_empty`, `chronoZeroLocus_union` — Zariski topology basics
* `chronoZeroLocus_causalClosure_invariant` — causal closure does not change spectra
* `chronoBasicOpen_mul_intersection` — D(ab) = D(a) ∩ D(b)
* `causal_fixedPoint_separation` — prime separation of non-causal elements
* `causal_fixedPoint_zeroLocus_reflection` — spectral reconstruction of causal theories
-/

import Mathlib

set_option maxHeartbeats 400000

universe u v

open Set Function

namespace Chrono

/-! ## Section 1: The Chronometric Semiring -/

/-- A **chronometric semiring** is an idempotent semiring with an involutive
time-reversal anti-automorphism and a causal closure operator on subsets.

Bridge: connects algebraic geometry (prime spectrum) to temporal semantics (causality). -/
class ChronometricSemiring (R : Type u) extends Semiring R where
  add_idem : ∀ a : R, a + a = a
  timeRev : R → R
  timeRev_involutive : Involutive timeRev
  timeRev_zero : timeRev 0 = 0
  timeRev_one : timeRev 1 = 1
  timeRev_add : ∀ a b : R, timeRev (a + b) = timeRev a + timeRev b
  timeRev_mul : ∀ a b : R, timeRev (a * b) = timeRev b * timeRev a
  causalClosure : Set R → Set R
  causal_extensive : ∀ S, S ⊆ causalClosure S
  causal_mono : ∀ {S T : Set R}, S ⊆ T → causalClosure S ⊆ causalClosure T
  causal_idem : ∀ S, causalClosure (causalClosure S) = causalClosure S
  causal_zero_mem : ∀ S, (0 : R) ∈ causalClosure S

variable {R : Type u} [ChronometricSemiring R]

/-! ### 1.1 Canonical preorder from idempotent addition -/

/-- The canonical order on a chronometric semiring: `a ≤ b` iff `a + b = b`.
Bridge: connects to lattice-theoretic cost aggregation for lipschitz_certified_robustness. -/
def chronoLE (a b : R) : Prop := a + b = b

/-- Reflexivity of the chronometric order, from additive idempotency. -/
theorem chronoLE_refl (a : R) : chronoLE a a :=
  ChronometricSemiring.add_idem a

/-- Transitivity of the chronometric order. -/
theorem chronoLE_trans {a b c : R} (hab : chronoLE a b) (hbc : chronoLE b c) :
    chronoLE a c := by
  unfold chronoLE at *
  calc a + c = a + (b + c) := by rw [hbc]
    _ = (a + b) + c := by rw [add_assoc]
    _ = b + c := by rw [hab]
    _ = c := hbc

/-
Adding a common right term preserves the chronometric order.
-/
theorem chronoLE_add_right {a b : R} (c : R) (hab : chronoLE a b) :
    chronoLE (a + c) (b + c) := by
  unfold chronoLE at *;
  rename_i h;
  cases h;
  simp_all +decide [ add_comm, add_left_comm, add_assoc ];
  rw [ ← add_assoc, hab ]

/-- The chronometric order is compatible with left multiplication. -/
theorem chronoLE_mul_mono_left {a b : R} (c : R) (hab : chronoLE a b) :
    chronoLE (c * a) (c * b) := by
  unfold chronoLE at *
  rw [← mul_add, hab]

/-- The chronometric order is compatible with right multiplication. -/
theorem chronoLE_mul_mono_right {a b : R} (c : R) (hab : chronoLE a b) :
    chronoLE (a * c) (b * c) := by
  unfold chronoLE at *
  rw [← add_mul, hab]

/-- Zero is the bottom element in the chronometric order. -/
theorem chronoLE_zero (a : R) : chronoLE 0 a := by
  unfold chronoLE; rw [zero_add]

/-- A stronger class with antisymmetric canonical order. -/
class CanonicallyOrderedChronometricSemiring (R : Type u)
    extends ChronometricSemiring R where
  chrono_antisymm : ∀ {a b : R}, chronoLE a b → chronoLE b a → a = b

/-! ## Section 2: Time-reversal properties -/

/-- Bridge: connects to thermodynamic reversibility.
Applying time reversal twice returns to the original element. -/
theorem thermodynamic_rev_rev_collapse (a : R) :
    ChronometricSemiring.timeRev (ChronometricSemiring.timeRev a) = a :=
  ChronometricSemiring.timeRev_involutive a

/-- Time reversal flips the order of multiplication.
Bridge: connects to quantum gate reversal in quantum_timeRev_normalization. -/
theorem timeRev_mul_flip (a b : R) :
    ChronometricSemiring.timeRev (a * b) =
    ChronometricSemiring.timeRev b * ChronometricSemiring.timeRev a :=
  ChronometricSemiring.timeRev_mul a b

/-- Time reversal preserves the chronometric order. -/
theorem timeRev_preserves_chronoLE {a b : R}
    (hab : chronoLE a b) :
    chronoLE (ChronometricSemiring.timeRev a) (ChronometricSemiring.timeRev b) := by
  unfold chronoLE at *
  rw [← ChronometricSemiring.timeRev_add, hab]

/-- An element is **quantum trace symmetric** if it is a fixed point of time reversal.
Bridge: connects to T-invariant observables in physics. -/
def QuantumTraceSymmetric (x : R) : Prop :=
  ChronometricSemiring.timeRev x = x

/-- Zero is quantum trace symmetric. -/
theorem quantumTraceSymmetric_zero : QuantumTraceSymmetric (0 : R) :=
  ChronometricSemiring.timeRev_zero

/-- One is quantum trace symmetric. -/
theorem quantumTraceSymmetric_one : QuantumTraceSymmetric (1 : R) :=
  ChronometricSemiring.timeRev_one

/-- The sum of two symmetric elements is symmetric. -/
theorem quantumTraceSymmetric_add {a b : R}
    (ha : QuantumTraceSymmetric a) (hb : QuantumTraceSymmetric b) :
    QuantumTraceSymmetric (a + b) := by
  unfold QuantumTraceSymmetric at *
  rw [ChronometricSemiring.timeRev_add, ha, hb]

/-! ## Section 3: Causal closure properties -/

/-- Causal closure is monotone. -/
theorem causalClosure_monotone {S T : Set R} (h : S ⊆ T) :
    ChronometricSemiring.causalClosure S ⊆ ChronometricSemiring.causalClosure T :=
  ChronometricSemiring.causal_mono h

/-- A set is a **causal fixed point** if it equals its own causal closure.
Bridge: connects to equilibrium states in thermodynamics. -/
def IsCausalFixedPoint (S : Set R) : Prop :=
  ChronometricSemiring.causalClosure S = S

/-- The causal closure of any set is itself a causal fixed point. -/
theorem causalClosure_fixed_iff (S : Set R) :
    IsCausalFixedPoint (ChronometricSemiring.causalClosure S) :=
  ChronometricSemiring.causal_idem S

/-- The universal set is a causal fixed point. -/
theorem isCausalFixedPoint_univ : IsCausalFixedPoint (Set.univ : Set R) := by
  unfold IsCausalFixedPoint
  ext x; simp only [Set.mem_univ, iff_true]
  exact ChronometricSemiring.causal_extensive _ (Set.mem_univ x)

/-! ## Section 4: Semiring congruences and time-reversal congruences -/

/-- A semiring congruence on a chronometric semiring. -/
structure ChronoSemiringCong (R : Type u) [ChronometricSemiring R] where
  rel : R → R → Prop
  refl' : ∀ a, rel a a
  symm' : ∀ {a b}, rel a b → rel b a
  trans' : ∀ {a b c}, rel a b → rel b c → rel a c
  add_compat : ∀ {a b c d}, rel a b → rel c d → rel (a + c) (b + d)
  mul_compat : ∀ {a b c d}, rel a b → rel c d → rel (a * c) (b * d)

namespace ChronoSemiringCong

variable (C : ChronoSemiringCong R)

/-- Convert to a `Setoid`. -/
def toSetoid : Setoid R where
  r := C.rel
  iseqv := ⟨C.refl', @C.symm', @C.trans'⟩

/-- Left multiplication compatibility. -/
theorem mul_left (f : R) {a b : R} (h : C.rel a b) : C.rel (f * a) (f * b) :=
  C.mul_compat (C.refl' f) h

/-- Right multiplication compatibility. -/
theorem mul_right (f : R) {a b : R} (h : C.rel a b) : C.rel (a * f) (b * f) :=
  C.mul_compat h (C.refl' f)

end ChronoSemiringCong

/-- A **time-reversal congruence**: a semiring congruence stable under timeRev.
Bridge: connects congruence theory to temporal symmetry. -/
structure TimeRevCongruence (R : Type u) [ChronometricSemiring R]
    extends ChronoSemiringCong R where
  stable_timeRev :
    ∀ ⦃a b : R⦄, rel a b →
      rel (ChronometricSemiring.timeRev a) (ChronometricSemiring.timeRev b)

namespace TimeRevCongruence

variable (C : TimeRevCongruence R)

/-- Time-reversal stability. -/
theorem quotient_timeRev_wellDefined {a b : R} (h : C.rel a b) :
    C.rel (ChronometricSemiring.timeRev a) (ChronometricSemiring.timeRev b) :=
  C.stable_timeRev h

/-- The quotient time-reversal function. -/
noncomputable def quotientTimeRev :
    Quotient C.toChronoSemiringCong.toSetoid → Quotient C.toChronoSemiringCong.toSetoid :=
  Quotient.map ChronometricSemiring.timeRev (fun _ _ h => C.stable_timeRev h)

/-- The quotient time-reversal is involutive.
Bridge: connects to thermodynamic_rev_rev_collapse on quotient spaces. -/
theorem quotientTimeRev_involutive : Involutive C.quotientTimeRev := by
  intro q
  induction q using Quotient.inductionOn with
  | h a =>
    simp only [quotientTimeRev, Quotient.map_mk]
    exact Quotient.sound (C.toChronoSemiringCong.toSetoid.iseqv.1 _)
      |>.symm ▸ by
        show Quotient.mk _ (ChronometricSemiring.timeRev (ChronometricSemiring.timeRev a)) =
             Quotient.mk _ a
        congr 1
        exact ChronometricSemiring.timeRev_involutive a

/-- Quotient time-reversal respects multiplication (anti-homomorphism). -/
theorem quotient_rev_respects_mul (a b : R) :
    C.quotientTimeRev (Quotient.mk C.toChronoSemiringCong.toSetoid (a * b)) =
    Quotient.mk C.toChronoSemiringCong.toSetoid
      (ChronometricSemiring.timeRev b * ChronometricSemiring.timeRev a) := by
  simp only [quotientTimeRev, Quotient.map_mk]
  congr 1
  exact ChronometricSemiring.timeRev_mul a b

/-- Quotient time-reversal respects addition. -/
theorem quotient_rev_respects_add (a b : R) :
    C.quotientTimeRev (Quotient.mk C.toChronoSemiringCong.toSetoid (a + b)) =
    Quotient.mk C.toChronoSemiringCong.toSetoid
      (ChronometricSemiring.timeRev a + ChronometricSemiring.timeRev b) := by
  simp only [quotientTimeRev, Quotient.map_mk]
  congr 1
  exact ChronometricSemiring.timeRev_add a b

end TimeRevCongruence

/-- A subset is **time-reversal stable** if closed under `timeRev`.
Bridge: connects to T-invariant observables in quantum mechanics. -/
def TimeRevStable (S : Set R) : Prop :=
  ∀ ⦃x⦄, x ∈ S → ChronometricSemiring.timeRev x ∈ S

/-- The empty set is time-reversal stable. -/
theorem timeRevStable_empty : TimeRevStable (∅ : Set R) :=
  fun _ hx => hx.elim

/-- The universal set is time-reversal stable. -/
theorem timeRevStable_univ : TimeRevStable (Set.univ : Set R) :=
  fun _ _ => trivial

/-- The intersection of time-reversal stable sets is stable. -/
theorem timeRevStable_inter {S T : Set R}
    (hS : TimeRevStable S) (hT : TimeRevStable T) :
    TimeRevStable (S ∩ T) :=
  fun _ ⟨hxS, hxT⟩ => ⟨hS hxS, hT hxT⟩

/-- A subset is **congruence-saturated** if congruent elements are co-membered.
Bridge: connects to lattice_crypto indistinguishability. -/
def CongSaturated (C : TimeRevCongruence R) (S : Set R) : Prop :=
  ∀ ⦃a b⦄, C.rel a b → a ∈ S → b ∈ S

/-! ## Section 5: Chrono-prime congruences and the spectrum -/

/-- A **chrono-prime** congruence: prime, time-reversal closed on vanishing,
and causally closed on vanishing.
Bridge: connects prime ideal theory to temporal computation semantics. -/
def ChronoPrime (C : TimeRevCongruence R) : Prop :=
  (∀ a b : R, C.rel (a * b) 0 → C.rel a 0 ∨ C.rel b 0) ∧
  (∀ a : R, C.rel a 0 → C.rel (ChronometricSemiring.timeRev a) 0) ∧
  (∀ S : Set R, (∀ x ∈ S, C.rel x 0) →
    ∀ y ∈ ChronometricSemiring.causalClosure S, C.rel y 0)

/-- The **chrono-prime spectrum**.
Bridge: connects spectral algebraic geometry to causal temporal semantics. -/
structure ChronoSpec (R : Type u) [ChronometricSemiring R] where
  carrier : TimeRevCongruence R
  isPrime : ChronoPrime carrier

/-- Zero locus: chrono-primes where all elements of `S` vanish.
Bridge: connects Zariski topology to causal observability. -/
def chronoZeroLocus (S : Set R) : Set (ChronoSpec R) :=
  { P | ∀ ⦃x⦄, x ∈ S → P.carrier.rel x 0 }

/-- Basic open set: complement of zero locus for single element.
Bridge: connects to observable distinguishability in post_quantum_security. -/
def chronoBasicOpen (x : R) : Set (ChronoSpec R) :=
  { P | ¬ P.carrier.rel x 0 }

/-- The zero locus of the empty set is the whole spectrum. -/
theorem chronoZeroLocus_empty :
    chronoZeroLocus (∅ : Set R) = Set.univ := by
  ext P; simp [chronoZeroLocus]

/-- Zero loci are antitone. -/
theorem chronoZeroLocus_mono {S T : Set R} (h : S ⊆ T) :
    chronoZeroLocus T ⊆ chronoZeroLocus S :=
  fun P hP _ hx => hP (h hx)

/-- The zero locus of a union is the intersection of zero loci. -/
theorem chronoZeroLocus_union (S T : Set R) :
    chronoZeroLocus (S ∪ T) = chronoZeroLocus S ∩ chronoZeroLocus T := by
  ext P
  constructor
  · intro hP
    exact ⟨fun _ hx => hP (Or.inl hx), fun _ hx => hP (Or.inr hx)⟩
  · intro ⟨hS, hT⟩ _ hx
    rcases hx with hxS | hxT
    · exact hS hxS
    · exact hT hxT

/-- **Causal closure does not change spectral observability.**
Bridge: connects causal propagation to algebraic geometry. -/
theorem chronoZeroLocus_causalClosure_invariant (S : Set R) :
    chronoZeroLocus (ChronometricSemiring.causalClosure S) = chronoZeroLocus S := by
  ext P
  constructor
  · intro hP _ hxS
    exact hP (ChronometricSemiring.causal_extensive S hxS)
  · intro hP _ hx
    exact P.isPrime.2.2 S (fun y hy => hP hy) _ hx

/-
D(ab) = D(a) ∩ D(b): basic opens are multiplicative.
Bridge: connects multiplicative spectral structure to quantum gate composition.
-/
theorem chronoBasicOpen_mul_intersection (a b : R) :
    chronoBasicOpen (a * b) = chronoBasicOpen a ∩ chronoBasicOpen b := by
  cases ‹ChronometricSemiring R›;
  ext; simp [chronoBasicOpen];
  rename_i h₁ h₂ h₃ h₄ h₅ h₆ h₇ h₈ h₉ h₁₀ h₁₁ h₁₂;
  cases h₁₂ ; simp_all +decide [ TimeRevCongruence ];
  rename_i h₁₂ h₁₃;
  cases h₁₂;
  rename_i h₁₄ h₁₅;
  cases h₁₄ ; simp_all +decide [ ChronoSemiringCong ];
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ ChronoPrime ];
  · by_cases ha : ‹R → R → Prop› a 0 <;> simp_all +decide;
    · rename_i h₁₆ h₁₇ h₁₈ h₁₉ h₂₀ h₂₁;
      simpa [ * ] using h₂₁ ha ( h₁₇ b );
    · rename_i h₁₆ h₁₇ h₁₈ h₁₉ h₂₀ h₂₁;
      convert h₂₁ ( h₁₇ a ) h using 1 ; simp +decide [ * ];
  · exact fun ha => Or.resolve_left ( h₁₃.1 a b h ) ha

/-- Time reversal symmetry on zero loci.
Bridge: connects T-symmetry to quantum_timeRev_symmetry observables. -/
theorem quantum_timeRev_symmetry_on_zeroLocus (S : Set R)
    (P : ChronoSpec R)
    (hP : P ∈ chronoZeroLocus S) (x : R) (hx : x ∈ S) :
    P.carrier.rel (ChronometricSemiring.timeRev x) 0 :=
  P.isPrime.2.1 _ (hP hx)

/-! ## Section 6: Causal fixed-point separation -/

/-- Prime separation axiom class.
Bridge: connects prime separation (algebraic geometry) to causal reasoning. -/
class HasChronoPrimeSeparation (R : Type u) [ChronometricSemiring R] : Prop where
  sep :
    ∀ (S : Set R) (x : R),
      x ∉ ChronometricSemiring.causalClosure S →
      ∃ P : ChronoSpec R, ¬ P.carrier.rel x 0 ∧
        (∀ y ∈ S, P.carrier.rel y 0)

/-- **Causal fixed-point separation**: if an element is not in the causal
closure of a set, some chrono-prime separates them.
Bridge: connects to lattice_crypto security via hardness separation. -/
theorem causal_fixedPoint_separation
    [HasChronoPrimeSeparation R]
    (S : Set R) (x : R)
    (hx : x ∉ ChronometricSemiring.causalClosure S) :
    ∃ P : ChronoSpec R,
      ¬ P.carrier.rel x 0 ∧ ∀ y ∈ S, P.carrier.rel y 0 :=
  HasChronoPrimeSeparation.sep S x hx

/-- **Spectral reconstruction of causal fixed points.**
Bridge: connects temporal algebra to spectral geometry. -/
theorem causal_fixedPoint_zeroLocus_reflection
    [HasChronoPrimeSeparation R]
    (S : Set R)
    (hS : IsCausalFixedPoint S) :
    S = {x | ∀ P : ChronoSpec R, (∀ y ∈ S, P.carrier.rel y 0) →
        P.carrier.rel x 0} := by
  ext x
  constructor
  · intro hxS P hP; exact hP x hxS
  · intro hx
    by_contra hxS
    have hxCC : x ∉ ChronometricSemiring.causalClosure S := by
      rw [hS]; exact hxS
    obtain ⟨P, hPx, hPS⟩ := HasChronoPrimeSeparation.sep S x hxCC
    exact hPx (hx P hPS)

end Chrono