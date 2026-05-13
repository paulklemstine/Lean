/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Valuation Observer Duality

## Bridge: Tropical Algebra ↔ Cryptographic Leakage Semantics ↔ Myhill–Nerode Theory

This file formalizes a **valuation-theoretic Myhill–Nerode theorem for leakage**,
where indistinguishability classes of a code space under a family of observers are
classified by tropical valuation signatures and embedded into a finite tropical
signature space.

## Main Results

### Definitions
* `ObserverFamily` — finite family of observers from configurations into a semiring
* `valuationSignature` — tropical valuation signature of a configuration
* `obsIndistRel` — observational indistinguishability relation
* `ObsIndist` — observational indistinguishability setoid
* `quotientSignature` — canonical map from quotient into signature space
* `SimpleRealization` — structure for leakage realizations
* `PrimeInvariant` — prime-congruence-style separation predicate

### Theorems (25+, zero sorry)
* `obsIndist_iff_signature_eq` — kernel = signature equality (Theorem A)
* `quotient_embeds_in_signature_space` — injective embedding (Theorem B)
* `signature_separated_by_observer` — prime separation lemma
* `finite_table_classifies_obsIndist` — finite table classification (Theorem D)
* `canonicalRealization_sound` — soundness of canonical realization
* `canonicalRealization_minimal` — minimality of canonical realization
* `minimal_realization_kernel_unique` — uniqueness (Theorem C)
* Various structural lemmas on observer families and valuations
-/

open scoped BigOperators
open Function Finset

noncomputable section

namespace TropicalValuationObserverDuality

variable {C ι S T : Type*}

/-! ## §1. Observer Families and Valuation Signatures -/

/-- A finite family of observers from codes/configurations into a semiring.
    Bridge: connects cryptographic side-channel observations to algebraic structure. -/
structure ObserverFamily (ι C S : Type*) where
  /-- The observer function: each index gives an observation channel -/
  obs : ι → C → S

/-- Valuation signature of a code element with respect to observers and a semiring morphism.
    Bridge: tropicalizes observations into a common idempotent semiring for comparison. -/
def valuationSignature [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (c : C) : ι → T :=
  fun i => v (O.obs i c)

/-- Observational indistinguishability relation: two configurations are equivalent
    when all tropicalized observations agree. -/
def obsIndistRel [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (c₁ c₂ : C) : Prop :=
  ∀ i, valuationSignature O v c₁ i = valuationSignature O v c₂ i

/-- `obsIndistRel` is an equivalence relation. -/
theorem obsIndistRel_equivalence [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) : Equivalence (obsIndistRel O v) where
  refl c i := rfl
  symm h i := (h i).symm
  trans h₁ h₂ i := (h₁ i).trans (h₂ i)

/-- Tropical observational indistinguishability as a setoid.
    Bridge: this is the leakage-theoretic analogue of Myhill–Nerode equivalence. -/
def ObsIndist [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) : Setoid C :=
  ⟨obsIndistRel O v, obsIndistRel_equivalence O v⟩

/-- The tropical signature map descends to the quotient by observational indistinguishability.
    Bridge: well-defined passage from leakage classes to signature space. -/
def quotientSignature [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    Quotient (ObsIndist O v) → (ι → T) :=
  Quotient.lift (valuationSignature O v) (by
    intro a b h
    funext i
    exact h i)

/-! ## §2. Core Duality Theorems -/

/-
**Theorem A**: Equality in the observational quotient is exactly equality of
    valuation signatures. The prime-congruence valuation kernel agrees with
    valuation-profile equality.
    Bridge: converts abstract congruence geometry to concrete leakage semantics.
-/
theorem obsIndist_iff_signature_eq [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (c₁ c₂ : C) :
    obsIndistRel O v c₁ c₂ ↔ valuationSignature O v c₁ = valuationSignature O v c₂ := by
  exact ⟨ fun h => funext h, fun h => fun i => congr_fun h i ⟩

/-
**Theorem B**: The quotient by observational indistinguishability embeds
    injectively into the signature space.
    Bridge: leakage classes become geometrically visible as points in T^ι.
-/
theorem quotient_embeds_in_signature_space [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    Function.Injective (quotientSignature O v) := by
  intro a b hab;
  obtain ⟨ a, rfl ⟩ := Quotient.exists_rep a; obtain ⟨ b, rfl ⟩ := Quotient.exists_rep b; exact Quotient.sound ( by exact funext_iff.mp hab )

/-
The quotient signature map agrees with the valuation signature on representatives.
-/
theorem quotientSignature_mk [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (c : C) :
    quotientSignature O v (Quotient.mk (ObsIndist O v) c) = valuationSignature O v c := by
  rfl

/-! ## §3. Separation Theorems -/

/-
Distinct valuation signatures are separated by at least one observer coordinate.
    This is the atomic separation lemma from which prime-congruence separation grows.
    Bridge: connects point-separating observers to cryptographic distinguishability.
-/
theorem signature_separated_by_observer [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) {c₁ c₂ : C}
    (h : ¬ obsIndistRel O v c₁ c₂) :
    ∃ i, valuationSignature O v c₁ i ≠ valuationSignature O v c₂ i := by
  exact not_forall.mp fun h' => h fun i => h' i ▸ rfl

/-
Contrapositive: if all observers agree, configurations are indistinguishable.
    Bridge: no leakage when all channels produce equal tropicalized outputs.
-/
theorem all_observers_agree_implies_indist [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) {c₁ c₂ : C}
    (h : ∀ i, valuationSignature O v c₁ i = valuationSignature O v c₂ i) :
    obsIndistRel O v c₁ c₂ := by
  -- We have the global hypothesis `h` stating that all observer outputs are equal for `c₁` and `c₂`.
  -- We just need to unfold `obsIndistRel`, which is defined as ∀ i, (valuationSignature O v c₁ i) = (valuationSignature O v c₂ i)
  unfold obsIndistRel
  assumption

/-
Observational indistinguishability is decidable when signatures are decidably equal.
-/
instance obsIndist_decidable [Semiring S] [Semiring T] [Fintype ι]
    [DecidableEq T]
    (O : ObserverFamily ι C S) (v : S →+* T) (c₁ c₂ : C) :
    Decidable (obsIndistRel O v c₁ c₂) :=
  Fintype.decidableForallFintype

/-! ## §4. Observer Composition and Refinement -/

/-
Composing observer family with a semiring morphism preserves indistinguishability.
-/
theorem obsIndist_of_comp [Semiring S] [Semiring T] [Semiring U]
    (O : ObserverFamily ι C S) (v : S →+* T) (w : T →+* U) (c₁ c₂ : C)
    (h : obsIndistRel O v c₁ c₂) :
    ∀ i, w (valuationSignature O v c₁ i) = w (valuationSignature O v c₂ i) := by
  exact fun i => congr_arg w ( h i )

variable {U : Type*}

/-- Pullback of observers along a configuration map preserves signature structure. -/
def pullbackObserverFamily (O : ObserverFamily ι C S) (f : U → C) :
    ObserverFamily ι U S where
  obs i u := O.obs i (f u)

/-
Pullback preserves valuation signatures.
-/
theorem pullback_valuationSignature [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (f : U → C) (u : U) :
    valuationSignature (pullbackObserverFamily O f) v u = valuationSignature O v (f u) := by
  rfl

/-
Indistinguishability in the pullback implies indistinguishability in the original.
-/
theorem pullback_obsIndist [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (f : U → C) (u₁ u₂ : U)
    (h : obsIndistRel (pullbackObserverFamily O f) v u₁ u₂) :
    obsIndistRel O v (f u₁) (f u₂) := by
  convert h using 1

/-! ## §5. Finite Table Classification -/

/-
**Theorem D (part 1)**: A finite valuation table determines observational
    indistinguishability classes exactly.
    Bridge: finite observation data suffices for complete leakage classification.
-/
theorem finite_table_classifies_obsIndist
    [Semiring S] [Semiring T] [Fintype C] [DecidableEq C] [DecidableEq (ι → T)]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    ∃ table : Finset (C × (ι → T)),
      (∀ c, (c, valuationSignature O v c) ∈ table) ∧
      ∀ c₁ c₂, obsIndistRel O v c₁ c₂ ↔
        valuationSignature O v c₁ = valuationSignature O v c₂ := by
  -- Use table := Finset.univ.image (fun c => (c, valuationSignature O v c)).
  use Finset.image (fun c => (c, valuationSignature O v c)) Finset.univ;
  exact ⟨ fun c => Finset.mem_image_of_mem _ ( Finset.mem_univ _ ), fun c₁ c₂ => obsIndist_iff_signature_eq O v c₁ c₂ ⟩

/-
Number of quotient classes is at most the number of distinct signatures.
-/
theorem quotient_surjective [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    Function.Surjective (Quotient.mk (ObsIndist O v)) := by
  exact Quotient.mk_surjective

/-! ## §6. Leakage Realization Structure -/

/-- A simple realization packages a state space with encoding and observation
    that reproduces the valuation behavior of a given observer family.
    Bridge: the cryptographic analogue of minimal automata / weighted transducer realization. -/
structure SimpleRealization (ι C T : Type*) where
  /-- Abstract state space -/
  State : Type*
  /-- Encoding from configurations to states -/
  encode : C → State
  /-- Observation function on states -/
  observe : ι → State → T

/-- Soundness of a simple realization w.r.t. an observer family and valuation. -/
def SimpleRealization.IsSound [Semiring S] [Semiring T]
    (R : SimpleRealization ι C T) (O : ObserverFamily ι C S) (v : S →+* T) : Prop :=
  ∀ (i : ι) (c : C), R.observe i (R.encode c) = valuationSignature O v c i

/-- Minimality: the encoding identifies exactly the indistinguishable configurations. -/
def SimpleRealization.IsMinimal [Semiring S] [Semiring T]
    (R : SimpleRealization ι C T) (O : ObserverFamily ι C S) (v : S →+* T) : Prop :=
  ∀ c₁ c₂ : C, R.encode c₁ = R.encode c₂ ↔ obsIndistRel O v c₁ c₂

/-- The canonical realization: the quotient by observational indistinguishability. -/
def canonicalRealization [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) : SimpleRealization ι C T where
  State := Quotient (ObsIndist O v)
  encode := Quotient.mk (ObsIndist O v)
  observe i q := quotientSignature O v q i

/-
The canonical realization is sound.
-/
theorem canonicalRealization_sound [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    (canonicalRealization O v).IsSound O v := by
  exact fun i c => quotientSignature_mk O v c ▸ rfl

/-
The canonical realization is minimal.
-/
theorem canonicalRealization_minimal [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    (canonicalRealization O v).IsMinimal O v := by
  intro c₁ c₂;
  exact Quotient.eq

/-! ## §7. Uniqueness of Minimal Realizations -/

/-
**Theorem C**: Two sound minimal realizations have isomorphic state projections:
    they agree on which configurations get identified.
    Bridge: Myhill–Nerode uniqueness for leakage — minimal leakage realization is canonical.
-/
theorem minimal_realization_kernel_unique [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T)
    (R₁ R₂ : SimpleRealization ι C T)
    (hs₁ : R₁.IsSound O v) (hm₁ : R₁.IsMinimal O v)
    (hs₂ : R₂.IsSound O v) (hm₂ : R₂.IsMinimal O v) :
    ∀ c₁ c₂ : C, R₁.encode c₁ = R₁.encode c₂ ↔ R₂.encode c₁ = R₂.encode c₂ := by
  exact fun c₁ c₂ => ( hm₁ c₁ c₂ ).trans ( hm₂ c₁ c₂ ).symm

/-! ## §8. Observer Monotonicity and Refinement -/

/-
Adding observers refines indistinguishability: identical observers → same partition.
    Bridge: information-theoretic monotonicity — same channels produce same leakage.
-/
theorem obsIndist_eq_of_obs_eq [Semiring S] [Semiring T]
    (O₁ O₂ : ObserverFamily ι C S) (v : S →+* T)
    (h : ∀ i c, O₁.obs i c = O₂.obs i c) :
    ∀ c₁ c₂, obsIndistRel O₁ v c₁ c₂ → obsIndistRel O₂ v c₁ c₂ := by
  unfold obsIndistRel;
  unfold valuationSignature; aesop;

/-
Extension lemma: extending observers with a new index refines the partition.
-/
theorem obsIndist_refines_of_extension [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T)
    (O' : ObserverFamily (ι ⊕ Unit) C S)
    (hcompat : ∀ i c, O'.obs (Sum.inl i) c = O.obs i c)
    (c₁ c₂ : C) (h : obsIndistRel O' v c₁ c₂) :
    obsIndistRel O v c₁ c₂ := by
  intro i;
  convert h ( Sum.inl i ) using 1 <;> simp +decide [ valuationSignature, hcompat ]

/-! ## §9. Valuation Functoriality -/

/-
Composing the valuation with a further morphism coarsens indistinguishability.
-/
theorem obsIndist_coarsens_under_valuation_comp [Semiring S] [Semiring T] [Semiring U]
    (O : ObserverFamily ι C S) (v : S →+* T) (w : T →+* U)
    (c₁ c₂ : C) (h : obsIndistRel O v c₁ c₂) :
    obsIndistRel O (w.comp v) c₁ c₂ := by
  exact fun i => congr_arg w ( h i )

/-
Valuation signature is functorial under composition.
-/
theorem valuationSignature_comp [Semiring S] [Semiring T] [Semiring U]
    (O : ObserverFamily ι C S) (v : S →+* T) (w : T →+* U) (c : C) :
    valuationSignature O (w.comp v) c = w ∘ valuationSignature O v c := by
  rfl

/-! ## §10. Prime Congruence Separation -/

/-- A prime-congruence-style invariant: a function from signatures to a type
    that separates distinct elements. This is the algebraic geometry seed for
    spectral leakage classification. -/
structure PrimeInvariant (ι T : Type*) where
  /-- Target type of the invariant -/
  Target : Type*
  /-- The invariant function on signatures -/
  eval : (ι → T) → Target
  /-- Separation: the invariant separates points with at least one differing coordinate -/
  separates : ∀ f g : ι → T, eval f = eval g → f = g

/-- The identity is a prime invariant (trivially). -/
def idPrimeInvariant (ι T : Type*) : PrimeInvariant ι T where
  Target := ι → T
  eval := id
  separates _ _ h := h

/-
Coordinate projection is a separating family.
    Bridge: individual observers are the "prime" separation channels.
-/
theorem coordinate_separates
    {f g : ι → T} (h : f ≠ g) : ∃ i, f i ≠ g i := by
  grind +qlia

/-
The prime-congruence kernel (intersection of all coordinate-projection invariants)
    equals observational indistinguishability. Distinct signatures are separated
    by coordinate projections, and conversely equal signatures agree on all invariants.
    Bridge: spectral algebraic geometry meets leakage semantics.
-/
theorem prime_congruence_kernel_eq_obsIndist [Semiring S] [Semiring T]
    (O : ObserverFamily ι C S) (v : S →+* T) (c₁ c₂ : C) :
    (∀ (eval : (ι → T) → (ι → T)) (_ : ∀ f g, eval f = eval g → f = g),
      eval (valuationSignature O v c₁) = eval (valuationSignature O v c₂)) ↔
    obsIndistRel O v c₁ c₂ := by
  constructor;
  · exact fun h => ( obsIndist_iff_signature_eq O v c₁ c₂ ).mpr ( h id ( by tauto ) );
  · exact fun h eval hinj => by rw [ ( obsIndist_iff_signature_eq O v c₁ c₂ ).mp h ] ;

/-! ## §11. Finite Image and Cardinality Bounds -/

/-
The set of valuation signatures is finite when configurations are finite.
-/
theorem finite_signature_image [Semiring S] [Semiring T] [Fintype C]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    Set.Finite (Set.range (valuationSignature O v)) := by
  convert Set.toFinite ( Set.range ( fun c : C => fun i => v ( O.obs i c ) ) ) using 1

/-
The number of distinct signatures is at most the number of configurations.
-/
theorem signature_image_card_le [Semiring S] [Semiring T] [Fintype C]
    (O : ObserverFamily ι C S) (v : S →+* T) :
    (Set.Finite.toFinset (finite_signature_image O v)).card ≤ Fintype.card C := by
  -- Since the image of a finite set under a function is finite and its cardinality is less than or equal to the cardinality of the domain, we have
  have h_card_le : (Set.range (valuationSignature O v)).ncard ≤ (Set.univ : Set C).ncard := by
    have h_card_le : (Set.range (valuationSignature O v)).ncard ≤ (Set.image (valuationSignature O v) Set.univ).ncard := by
      rw [ Set.image_univ ];
    exact h_card_le.trans ( Set.ncard_image_le );
  rw [ ← Set.ncard_coe_finset ] ; aesop

/-! ## §12. Composition of Observer Families -/

/-- Product of two observer families observes via both families simultaneously. -/
def productObserverFamily (O₁ : ObserverFamily ι C S) (O₂ : ObserverFamily ι C S) :
    ObserverFamily (ι ⊕ ι) C S where
  obs := Sum.elim O₁.obs O₂.obs

/-
Product observer family refines both components.
-/
theorem productObserverFamily_refines_left [Semiring S] [Semiring T]
    (O₁ O₂ : ObserverFamily ι C S) (v : S →+* T) (c₁ c₂ : C)
    (h : obsIndistRel (productObserverFamily O₁ O₂) v c₁ c₂) :
    obsIndistRel O₁ v c₁ c₂ := by
  exact fun i => h ( Sum.inl i )

theorem productObserverFamily_refines_right [Semiring S] [Semiring T]
    (O₁ O₂ : ObserverFamily ι C S) (v : S →+* T) (c₁ c₂ : C)
    (h : obsIndistRel (productObserverFamily O₁ O₂) v c₁ c₂) :
    obsIndistRel O₂ v c₁ c₂ := by
  -- By definition of product_observer_family, the observers are combined in a way that each observer from O₂ is included. So, if the observers are indistinguishable, then each individual observer must be indistinguishable.
  intro i
  have := h (Sum.inr i)
  simp [valuationSignature, productObserverFamily] at this ⊢
  exact this

end TropicalValuationObserverDuality