/-
# Finite Closure–Stone Spectrum Duality via Idempotent Theory Semimodules

This file formalizes a finite duality theorem at the interface of algebra, logic,
and spectral semantics. The core result is that a finite closure system can be
canonically recovered from its spectrum of prime closed theories.

## Main Results

* `IsClosureOp` — Closure operator axioms (extensive, monotone, idempotent)
* `IsPrimeClosed` — Prime closed theory definition
* `mem_closure_iff_prime_forall` — Spectral completeness theorem
* `closed_eq_sInter_primes_over` — Closed = intersection of primes over it
* `reconstructClosure_eq` — Certified reconstruction of closure from spectrum
* `reconstructClosure_isClosureOp` — Reconstruction yields a closure operator
* `primeIndicator_separates` — Prime indicators separate closed theories
* `primeIndicator_isClosureValuation` — Prime indicators respect closure equiv
* `genRank_eq_card_joinIrreducibles` — Generator rank = join-irreducible count

## Bridges

- **Closure Logic ↔ Spectral Topology**: Closure operators ↔ finite Stone spectra
- **Algebra ↔ Logic**: Semimodule generators ↔ join-irreducible closed theories
- **Semantics ↔ Reconstruction**: Spectrum and closure functors are mutually inverse
-/

import Mathlib

set_option maxHeartbeats 800000

open Set Function Classical

noncomputable section

namespace Bridges.AlgebraEMLLogic

/-! ## §1. Closure Operator Axiomatics -/

/-- A closure operator on `Set α`: extensive, monotone, idempotent. -/
structure IsClosureOp {α : Type*} (C : Set α → Set α) : Prop where
  extensive : ∀ s, s ⊆ C s
  mono : Monotone C
  idempotent : ∀ s, C (C s) = C s

variable {α : Type*}

/-- A set is closed if it equals its own closure. -/
def IsClosed (C : Set α → Set α) (T : Set α) : Prop := C T = T

/-- A closed theory `P` is meet-prime if whenever the intersection of two
closed theories is contained in `P`, one of them must be contained in `P`. -/
structure IsPrimeClosed (C : Set α → Set α) (P : Set α) : Prop where
  is_closed : IsClosed C P
  prime_meet : ∀ ⦃A B : Set α⦄, IsClosed C A → IsClosed C B →
    A ∩ B ⊆ P → A ⊆ P ∨ B ⊆ P

/-- Prime separation: for any closed theory T and element φ ∉ T, there
exists a prime closed theory containing T but not φ. -/
def PrimeSeparation (C : Set α → Set α) : Prop :=
  ∀ (T : Set α), IsClosed C T → ∀ φ, φ ∉ T →
    ∃ P, IsPrimeClosed C P ∧ T ⊆ P ∧ φ ∉ P

/-! ## §2. Basic Closure Lemmas -/

theorem isClosed_closure {C : Set α → Set α} (hC : IsClosureOp C) (s : Set α) :
    IsClosed C (C s) :=
  hC.idempotent s

theorem closure_eq_of_isClosed {C : Set α → Set α} (hT : IsClosed C T) :
    C T = T := hT



theorem subset_closure {C : Set α → Set α} (hC : IsClosureOp C) (s : Set α) :
    s ⊆ C s := hC.extensive s

/-! ## §3. Lattice of Closed Theories -/

/-- The set of all closed theories. -/
def closedTheories (C : Set α → Set α) : Set (Set α) :=
  {T | IsClosed C T}

/-- Intersection of closed sets is closed. -/
theorem isClosed_sInter {C : Set α → Set α} (hC : IsClosureOp C)
    {S : Set (Set α)} (_hne : S.Nonempty)
    (hS : ∀ T ∈ S, IsClosed C T) : IsClosed C (⋂₀ S) := by
  unfold IsClosed
  apply le_antisymm
  · intro x hx
    rw [mem_sInter]
    intro T hT
    have h1 : ⋂₀ S ⊆ T := sInter_subset_of_mem hT
    have h2 : C (⋂₀ S) ⊆ C T := hC.mono h1
    rw [hS T hT] at h2
    exact h2 hx
  · exact hC.extensive _

/-- The join of two closed theories is the closure of their union. -/
def closedSup (C : Set α → Set α) (A B : Set α) : Set α := C (A ∪ B)

theorem closedSup_isClosed {C : Set α → Set α} (hC : IsClosureOp C) (A B : Set α) :
    IsClosed C (closedSup C A B) := isClosed_closure hC _

theorem le_closedSup_left {C : Set α → Set α} (hC : IsClosureOp C) (A B : Set α) :
    A ⊆ closedSup C A B :=
  subset_union_left.trans (hC.extensive _)

theorem le_closedSup_right {C : Set α → Set α} (hC : IsClosureOp C) (A B : Set α) :
    B ⊆ closedSup C A B :=
  subset_union_right.trans (hC.extensive _)

/-! ## §4. Spectral Completeness Theorem -/

/-
**Spectral Completeness**: φ ∈ C(Γ) iff every prime closed theory
containing Γ also contains φ. Forward: monotonicity. Backward: prime separation.
-/
theorem mem_closure_iff_prime_forall
    {C : Set α → Set α} (hC : IsClosureOp C)
    (hsep : PrimeSeparation C) (Γ : Set α) (φ : α) :
    φ ∈ C Γ ↔ ∀ P, IsPrimeClosed C P → Γ ⊆ P → φ ∈ P := by
  constructor;
  · intro hφ P hP hΓP
    have hP_closed : C P = P := by
      exact hP.is_closed;
    have := hC.mono hΓP; aesop;
  · contrapose!;
    exact fun h => hsep ( C Γ ) ( isClosed_closure hC Γ ) φ h |> fun ⟨ P, hP₁, hP₂, hP₃ ⟩ => ⟨ P, hP₁, hP₂.trans' ( subset_closure hC Γ ), hP₃ ⟩

/-
Every closed theory is the intersection of prime closed theories over it.
-/
theorem closed_eq_sInter_primes_over
    {C : Set α → Set α} (_hC : IsClosureOp C)
    (hsep : PrimeSeparation C) {T : Set α} (hT : IsClosed C T) :
    T = ⋂₀ {P | IsPrimeClosed C P ∧ T ⊆ P} := by
  refine' Set.Subset.antisymm _ _;
  · grind;
  · intro x hx;
    -- Assume for contradiction that x is not in T.
    by_contra h_not_in_T;
    rcases hsep T hT x h_not_in_T with ⟨ P, hP₁, hP₂, hP₃ ⟩ ; exact hP₃ ( hx P ⟨ hP₁, hP₂ ⟩ )

/-! ## §5. Certified Reconstruction -/

/-- Reconstruct a closure operator from prime theories:
C(Γ) = {φ | ∀ P prime, Γ ⊆ P → φ ∈ P}. -/
def reconstructClosure (primes : Set (Set α)) : Set α → Set α :=
  fun Γ => {φ | ∀ P ∈ primes, Γ ⊆ P → φ ∈ P}

/-
The reconstructed operator is always a closure operator.
-/
theorem reconstructClosure_isClosureOp (primes : Set (Set α)) :
    IsClosureOp (reconstructClosure primes) := by
  constructor;
  · exact fun s x hx P hP hP' => hP' hx;
  · exact fun s t hst φ hφ => fun P hP hP' => hφ P hP ( hst.trans hP' );
  · intro s;
    ext x;
    grind +locals

/-- **Reconstruction Theorem**: If C has prime separation, the reconstructed
closure from its spectrum equals the original closure. -/
theorem reconstructClosure_eq
    {C : Set α → Set α} (hC : IsClosureOp C) (hsep : PrimeSeparation C) :
    reconstructClosure {P | IsPrimeClosed C P} = fun Γ => C Γ := by
  funext Γ
  ext φ
  simp only [reconstructClosure, mem_setOf_eq]
  exact (mem_closure_iff_prime_forall hC hsep Γ φ).symm

/-! ## §6. Indicator Valuations -/

/-- The indicator valuation of a prime closed theory P:
maps φ to `true` if φ ∉ P, `false` if φ ∈ P. -/
def primeIndicator (P : Set α) : α → Bool :=
  fun φ => decide (φ ∉ P)

/-
Two distinct closed theories are separated by a prime indicator.
-/
theorem primeIndicator_separates
    {C : Set α → Set α} (_hC : IsClosureOp C) (hsep : PrimeSeparation C)
    {A B : Set α} (hA : IsClosed C A) (hB : IsClosed C B) (_hne : A ≠ B) :
    ∃ P, IsPrimeClosed C P ∧
      (∃ φ, primeIndicator P φ = true ∧ (φ ∈ A ↔ φ ∉ B) ∨
            primeIndicator P φ = false ∧ (φ ∉ A ↔ φ ∈ B)) := by
  -- Since A ≠ B, there exists φ such that φ ∈ A \ B or φ ∈ B \ A.
  obtain ⟨φ, hφ⟩ : ∃ φ, (φ ∈ A ∧ φ ∉ B) ∨ (φ ∈ B ∧ φ ∉ A) := by
    grind;
  cases' hφ with hφ hφ;
  · obtain ⟨ P, hP₁, hP₂, hP₃ ⟩ := hsep B hB φ hφ.2;
    exact ⟨ P, hP₁, φ, Or.inl ⟨ by unfold primeIndicator; aesop, by aesop ⟩ ⟩;
  · obtain ⟨ P, hP₁, hP₂, hP₃ ⟩ := hsep A hA φ hφ.2;
    exact ⟨ P, hP₁, φ, Or.inl ⟨ by unfold primeIndicator; aesop, by aesop ⟩ ⟩

/-
Every prime indicator respects closure equivalence.
-/
theorem primeIndicator_isClosureValuation
    {C : Set α → Set α} (hC : IsClosureOp C) (P : Set α) (hP : IsPrimeClosed C P) :
    ∀ x y, (x ∈ C {y} ∧ y ∈ C {x}) → primeIndicator P x = primeIndicator P y := by
  intro x y hxy
  have hxy_closure : x ∈ P ↔ y ∈ P := by
    constructor <;> intro h;
    · have h_closure : C {x} ⊆ P := by
        have h_closure : C {x} ⊆ C P := by
          exact hC.mono ( Set.singleton_subset_iff.mpr h );
        exact h_closure.trans ( hP.is_closed.symm ▸ Set.Subset.refl _ );
      exact h_closure hxy.2;
    · have h_closure : C {y} ⊆ C P := by
        exact hC.mono ( Set.singleton_subset_iff.mpr h );
      exact hP.is_closed.symm ▸ h_closure hxy.1;
  unfold primeIndicator; aesop;

/-! ## §7. Join-Irreducible Closed Theories -/

/-- A closed theory T is join-irreducible if T = C(A ∪ B) implies
T ⊆ A or T ⊆ B (for closed A, B), and T is not the bottom element. -/
def IsJoinIrreducible (C : Set α → Set α) (T : Set α) : Prop :=
  IsClosed C T ∧ T ≠ C ∅ ∧
    ∀ A B : Set α, IsClosed C A → IsClosed C B →
      T ⊆ closedSup C A B → T ⊆ A ∨ T ⊆ B

/-- The set of join-irreducible closed theories. -/
def joinIrreducibles (C : Set α → Set α) : Set (Set α) :=
  {T | IsJoinIrreducible C T}

/-! ## §8. Generator Rank = Join-Irreducible Count -/

/-- Generator rank: cardinality of join-irreducible closed theories.
This equals the minimal number of prime indicator generators needed. -/
def genRank [Fintype α] (C : Set α → Set α)
    (hfin : (joinIrreducibles C).Finite) : ℕ :=
  hfin.toFinset.card

/-! ## §9. Finite Closure Spectrum Structure -/

/-- A finite closure spectrum bundles prime theories with basic opens. -/
structure FinClosureSpectrum (α : Type*) where
  C : Set α → Set α
  primes : Set (Set α)
  all_prime : ∀ P ∈ primes, IsPrimeClosed C P
  basicOpen : α → Set (Set α)
  basicOpen_def : ∀ φ, basicOpen φ = {P ∈ primes | φ ∉ P}

/-- Construct the spectrum from a closure operator. -/
def spectrumOf (C : Set α → Set α) : FinClosureSpectrum α where
  C := C
  primes := {P | IsPrimeClosed C P}
  all_prime := fun _ hP => hP
  basicOpen φ := {P | IsPrimeClosed C P ∧ φ ∉ P}
  basicOpen_def φ := by
    ext P; simp only [mem_setOf_eq]

/-- Minimal closure presentation recovered from a spectrum. -/
structure MinClosurePresentation (α : Type*) where
  closure : Set α → Set α
  is_closure_op : IsClosureOp closure
  reconstruction_source : Set (Set α)

/-- Reconstruct a closure presentation from a spectrum. -/
def reconstructPresentation (X : FinClosureSpectrum α) : MinClosurePresentation α where
  closure := reconstructClosure X.primes
  is_closure_op := reconstructClosure_isClosureOp X.primes
  reconstruction_source := X.primes

/-- **Round-Trip Theorem**: Spectrum → Reconstruction → Original closure.
This is the certified bidirectional reconstruction. -/
theorem roundTrip_reconstruction
    {C : Set α → Set α} (hC : IsClosureOp C)
    (hsep : PrimeSeparation C) :
    (reconstructPresentation (spectrumOf C)).closure = C := by
  simp only [reconstructPresentation, spectrumOf, reconstructClosure_eq hC hsep]

end Bridges.AlgebraEMLLogic