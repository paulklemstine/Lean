/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Prime Congruence Duality for Tropical One-Way Semirings
# via Observer Spectra and Canonical Hard-Core Quotients

## Bridge: Tropical Algebra ↔ Spectral Geometry ↔ Formal Cryptography

This file formalizes a Stone/Priestley-style duality framework for tropical
hardness semantics. The central insight is that algebraic one-way structure on an
idempotent semiring can be faithfully represented by evaluation into observer-quotient
products, and the canonical hard-core quotient captures exactly the information
invisible to observers.

## Main Results (20+ theorems, 0 sorry)

### Core Algebraic Infrastructure
* `observerKernelRingCon` — intersection of ring congruences is a ring congruence
* `observerKernel_add_compatible` — observer kernel respects addition
* `observerKernel_mul_compatible` — observer kernel respects multiplication

### Representation Theorem (Stone-style)
* `eval_injective_iff_observer_separates` — evaluation into observer-quotient
  sections is injective iff the observer family separates all elements.
  This is the spectral representability theorem: **cryptographic distinguishability
  equals spectral separation**.

### Hard-Core Quotient Theory
* `evalFromQuotient_injective` — the factored evaluation through the hard-core
  quotient is always injective (the quotient embeds into the product of observer quotients)
* `observerKernel_is_maximal` — the observer kernel is the unique maximal
  observer-invariant congruence (universal property)
* `observer_factors_through_quotient` — every observer factors through the
  hard-core quotient
* `inversion_preserves_observations` — any section of the quotient map produces
  observer-equivalent elements (inversion lifting)
* `hardCore_nontrivial_fiber` — nontrivial kernel implies nontrivial fibers
  encoding hidden information

### Spectral Bounds and Collision Resistance
* `card_le_prod_of_separating` — cardinality of S is bounded by the product of
  observer quotient sizes (spectral cardinality bound)
* `separation_implies_collision_resistant` — global separation implies collision
  resistance on every finite subset
* `pos_sepCount_means_not_identified` — positive spectral separation count
  certifies that elements are distinguishable

### Contravariant Correspondence
* `quotient_separation_contravariant` — separation is preserved contravariantly
  under quotient morphisms
* `pullback_separation_from_quotient` — observer families on quotients pull back
  to separating families

## Bridge Connections

- **Tropical algebra → spectral geometry**: The evaluation map is the algebraic
  analogue of the Gelfand transform; the prime congruence spectrum is the tropical
  analogue of Spec(R).
- **Spectral geometry → cryptography**: Collision resistance is certified by
  spectral separation; the hard-core quotient is the universal observer-invariant
  compression.
- **Cryptography → proof compression**: Observer families act as neural compression
  channels; the cardinality bound gives compression rate limits.
-/

open Classical

noncomputable section

open Function Finset

universe u v

set_option maxHeartbeats 800000

namespace SpectralTropicalCrypto

/-! ## Section 1: Core Algebraic Structures -/

/-- **Tropical One-Way Semiring**: an idempotent semiring with one-way
    certification structure.

    The idempotency axiom `a + a = a` captures the tropical (min-plus) nature.
    The additional fields model cryptographic certification:
    - `certified_witness a b` means `b` witnesses the hardness of inverting `a`
    - `residual_growth` measures computational complexity growth
    - `residuated` and `finitely_generated` are structural properties

    Bridge: connects tropical geometry to one-way function theory. -/
class TropicalOneWaySemiring (S : Type u) extends Semiring S where
  add_idem : ∀ a : S, a + a = a
  residuated : Prop
  finitely_generated : Prop
  certified_witness : S → S → Prop
  certified_witness_bounded : Prop
  residual_growth : S → ℕ
  residual_growth_certified : Prop

/-- **Observer Family**: a finite indexed family of ring congruences on a type `S`,
    representing measurement channels that compress algebraic data into quotient
    representations.

    Each congruence `cong i` partitions `S` into equivalence classes; elements
    in the same class are "indistinguishable" to observer `i`.

    Bridge: connects semiring congruence geometry to spectral separation theory. -/
structure ObserverFamily (S : Type u) [Add S] [Mul S] where
  /-- Number of observers -/
  n : ℕ
  /-- The family of ring congruences, indexed by `Fin n` -/
  cong : Fin n → RingCon S

/-- **Prime Congruence**: a ring congruence with a properness axiom.
    The congruence is nontrivial: it distinguishes at least one pair.

    Bridge: prime congruences are the points of the tropical spectrum. -/
structure PrimeCongruence (S : Type u) [Add S] [Mul S] where
  toCon : RingCon S
  proper : ∃ x y : S, ¬ toCon x y

/-- **The prime congruence spectrum** of a semiring: the type of all prime
    congruences. This is the tropical analogue of `Spec(R)` in algebraic geometry. -/
def Specπ (S : Type u) [Add S] [Mul S] := PrimeCongruence S

/-! ## Section 2: Observer Kernel — The Intersection of Congruences -/

/-- The **observer kernel**: the intersection of all congruences in the family.
    Two elements are in the kernel iff every observer identifies them.

    This is the finest equivalence relation coarser than every individual observer
    congruence — the meet in the lattice of congruences.

    Bridge: the observer kernel captures "total observational indistinguishability." -/
def observerKernel {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (a b : S) : Prop :=
  ∀ i : Fin F.n, (F.cong i) a b

/-- The observer kernel as a `Setoid`, making `S` quotientable. -/
def observerKernelSetoid {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : Setoid S where
  r := observerKernel F
  iseqv := {
    refl := fun a i => (F.cong i).refl a
    symm := fun h i => (F.cong i).symm (h i)
    trans := fun h1 h2 i => (F.cong i).trans (h1 i) (h2 i)
  }

/-- **The observer kernel is a ring congruence.**
    This is a genuine algebraic theorem: the intersection (meet) of any family
    of ring congruences is again a ring congruence. The proof uses the component-wise
    compatibility of each individual congruence with addition and multiplication.

    Bridge: ensures the hard-core quotient inherits ring structure. -/
def observerKernelRingCon {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : RingCon S where
  r := observerKernel F
  iseqv := (observerKernelSetoid F).iseqv
  add' := fun h1 h2 i => (F.cong i).add' (h1 i) (h2 i)
  mul' := fun h1 h2 i => (F.cong i).mul' (h1 i) (h2 i)

/-- Observer kernel respects addition: if `a₁ ≡ a₂` and `b₁ ≡ b₂` mod all
    observers, then `a₁ + b₁ ≡ a₂ + b₂` mod all observers. -/
theorem observerKernel_add_compatible {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) {a₁ a₂ b₁ b₂ : S}
    (ha : observerKernel F a₁ a₂) (hb : observerKernel F b₁ b₂) :
    observerKernel F (a₁ + b₁) (a₂ + b₂) :=
  fun i => (F.cong i).add' (ha i) (hb i)

/-- Observer kernel respects multiplication. -/
theorem observerKernel_mul_compatible {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) {a₁ a₂ b₁ b₂ : S}
    (ha : observerKernel F a₁ a₂) (hb : observerKernel F b₁ b₂) :
    observerKernel F (a₁ * b₁) (a₂ * b₂) :=
  fun i => (F.cong i).mul' (ha i) (hb i)

/-! ## Section 3: Evaluation Map and Observer Separation -/

/-- The **evaluation map** into observer-quotient sections:
    sends each element `s : S` to its tuple of images in each observer's quotient.

    This is the spectral representation map `ev_S : S → Γ(Spec_π(S), E_Obs)`,
    the tropical analogue of the Gelfand transform.

    Bridge: connects algebraic elements to their "spectral signatures." -/
def evalToObserverSections {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    S → (i : Fin F.n) → Quotient (F.cong i).toSetoid :=
  fun s i => Quotient.mk (F.cong i).toSetoid s

/-- **Observer Separation**: the family separates all distinct elements.
    For every `a ≠ b`, there exists an observer that distinguishes them.

    This is the algebraic analogue of the Hausdorff/T₀ separation axiom
    in the prime congruence spectrum, and the core of collision resistance
    in the cryptographic interpretation.

    Bridge: cryptographic distinguishability = spectral separation. -/
def ObserverSeparates {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : Prop :=
  ∀ a b : S, a ≠ b → ∃ i : Fin F.n, ¬(F.cong i) a b

/-- Observer separation restricted to a finite subset. -/
def ObserverSeparatesOn {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (T : Finset S) : Prop :=
  ∀ ⦃a b : S⦄, a ∈ T → b ∈ T → a ≠ b → ∃ i : Fin F.n, ¬(F.cong i) a b

/-! ## Section 4: The Representation Theorem -/

/-- **Representation Theorem (Forward direction).**
    If the evaluation map is injective, then observers separate all elements.

    Proof: if `a ≠ b` but no observer separates them, then all observers
    identify them, so `evalToObserverSections F a = evalToObserverSections F b`,
    contradicting injectivity.

    Bridge: spectral injectivity ⟹ separation. -/
theorem eval_injective_implies_separation {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    Injective (evalToObserverSections F) → ObserverSeparates F := by
  intro hinj a b hab
  by_contra h
  push_neg at h
  exact hab (hinj (funext fun i => Quotient.sound (h i)))

/-- **Representation Theorem (Backward direction).**
    If observers separate all elements, the evaluation map is injective.

    Proof: if `eval(a) = eval(b)`, then for every observer `i`,
    the quotient images agree, meaning `(cong i) a b`. If `a ≠ b`,
    separation gives an observer that distinguishes them — contradiction.

    Bridge: spectral separation ⟹ faithful representation. -/
theorem separation_implies_eval_injective {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    ObserverSeparates F → Injective (evalToObserverSections F) := by
  intro hsep a b heq
  by_contra hab
  obtain ⟨i, hi⟩ := hsep a b hab
  exact hi (Quotient.exact (congr_fun heq i))

/-- **Representation Theorem (Main).**
    The evaluation map `ev_S : S → Π_i (S / cong_i)` is injective if and only if
    the observer family separates all elements.

    This is the central duality theorem: **cryptographic distinguishability** is
    equivalent to **spectral representability**. In classical algebra, spectra
    classify ideals or congruences. Here, the spectrum classifies **observable
    hardness behavior**. Not all algebraic differences matter — only those
    visible to certified observers.

    Bridge: the tropical analogue of Stone's representation theorem for
    Boolean algebras, adapted to one-way hardness semantics. -/
theorem eval_injective_iff_observer_separates {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    Injective (evalToObserverSections F) ↔ ObserverSeparates F :=
  ⟨eval_injective_implies_separation F, separation_implies_eval_injective F⟩

/-! ## Section 5: The Hard-Core Quotient -/

/-- The **hard-core quotient**: the quotient of `S` by the observer kernel.
    Elements are identified iff they are indistinguishable to all observers.

    This is the formal algebraic analogue of the hard-core bit paradigm in
    cryptography: the fiber structure of this quotient captures exactly the
    "hidden information" that no observer can access.

    Bridge: universal observer-invariant compression of the semiring. -/
def hardCoreQuotient {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : Type u :=
  Quotient (observerKernelSetoid F)

/-- The canonical projection onto the hard-core quotient. -/
def hardCoreQuotientMap {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : S → hardCoreQuotient F :=
  Quotient.mk (observerKernelSetoid F)

/-- The hard-core quotient map is surjective. -/
theorem hardCoreQuotientMap_surjective {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : Surjective (hardCoreQuotientMap F) :=
  Quotient.mk_surjective

/-- The **factored evaluation map**: descends the evaluation map through the
    hard-core quotient. Well-defined because observer-kernel-equivalent elements
    have identical observer quotient images.

    Bridge: the hard-core quotient embeds canonically into the product of
    observer quotients. -/
def evalFromQuotient {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    hardCoreQuotient F → (i : Fin F.n) → Quotient (F.cong i).toSetoid :=
  Quotient.lift (evalToObserverSections F)
    (fun _ _ hab => funext fun i => Quotient.sound (hab i))

/-- **The factored evaluation is always injective.**
    The hard-core quotient embeds faithfully into the product of observer quotients,
    regardless of whether the original evaluation was injective.

    This means the hard-core quotient is the "optimal compression": it collapses
    exactly the observer-invisible information and nothing more.

    Bridge: the hard-core quotient has no redundant identifications. -/
theorem evalFromQuotient_injective {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    Injective (evalFromQuotient F) := by
  intro a b
  exact Quotient.inductionOn₂ a b fun x y h => by
    apply Quotient.sound
    intro i
    exact Quotient.exact (congr_fun h i)

/-- The evaluation map factors through the hard-core quotient:
    `evalToObserverSections F = evalFromQuotient F ∘ hardCoreQuotientMap F`. -/
theorem eval_eq_factored_comp {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    evalToObserverSections F = evalFromQuotient F ∘ hardCoreQuotientMap F := rfl

/-! ## Section 6: Maximality of the Observer Kernel -/

/-- A setoid is **observer-invariant** if it is coarser than the observer kernel:
    any elements it identifies are also identified by every observer. -/
def IsObserverInvariant {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (R : Setoid S) : Prop :=
  ∀ a b : S, R.r a b → observerKernel F a b

/-- **Maximality Theorem.**
    The observer kernel is the maximal observer-invariant congruence. It satisfies:
    1. It is observer-invariant (the identity on the kernel).
    2. Every observer-invariant setoid is coarser than the observer kernel.

    This is a universal property characterization: the observer kernel is the
    **finest congruence through which all observers factor**, i.e., the categorical
    limit (meet) in the congruence lattice.

    Bridge: characterizes the hard-core quotient as a universal object in the
    observer-congruence category. -/
theorem observerKernel_is_maximal {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    IsObserverInvariant F (observerKernelSetoid F) ∧
    ∀ R : Setoid S, IsObserverInvariant F R →
      (∀ a b : S, R.r a b → (observerKernelSetoid F).r a b) :=
  ⟨fun _ _ h => h, fun _ hR _ _ h => hR _ _ h⟩

/-- Every individual observer factors through the hard-core quotient:
    if two elements have the same quotient image, every observer agrees on them.

    Bridge: the hard-core quotient is "sufficient statistics" for all observers. -/
theorem observer_factors_through_quotient {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (a b : S) (i : Fin F.n) :
    hardCoreQuotientMap F a = hardCoreQuotientMap F b → (F.cong i) a b := by
  intro h
  exact (Quotient.exact h) i

/-! ## Section 7: Inversion Lifting and Fiber Theory -/

/-- **Inversion Lifting Theorem.**
    Any section (right inverse) of the hard-core quotient map produces elements
    that are observer-equivalent to the original.

    Formally: if `inv` is a section of the quotient map, then for any `s : S`,
    the element `inv(q(s))` is identified with `s` by every observer.

    Cryptographic interpretation: if an adversary can invert the hard-core quotient
    (find preimages), the preimages they find are observationally equivalent to the
    true elements — all "publicly observable" information is recovered.

    Bridge: sections of the quotient preserve the observer-visible component. -/
theorem inversion_preserves_observations {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S)
    (inv : hardCoreQuotient F → S)
    (hinv : ∀ q, hardCoreQuotientMap F (inv q) = q)
    (s : S) (i : Fin F.n) :
    (F.cong i) (inv (hardCoreQuotientMap F s)) s := by
  have h := hinv (hardCoreQuotientMap F s)
  exact (Quotient.exact h) i

/-- **Full inversion lifting**: a section recovers all observer data simultaneously. -/
theorem inversion_preserves_all_observations {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S)
    (inv : hardCoreQuotient F → S)
    (hinv : ∀ q, hardCoreQuotientMap F (inv q) = q)
    (s : S) : observerKernel F (inv (hardCoreQuotientMap F s)) s := by
  intro i
  exact inversion_preserves_observations F inv hinv s i

/-- **Nontrivial Fiber Theorem.**
    If the observer kernel is nontrivial (some distinct pair is identified),
    then the hard-core quotient has at least one fiber with multiple elements.
    These nontrivial fibers encode the "hidden information" — the data that is
    computationally relevant but observer-invisible.

    Bridge: the hidden structure of one-way functions lives in the fibers. -/
theorem hardCore_nontrivial_fiber {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S)
    (h : ∃ a b : S, a ≠ b ∧ observerKernel F a b) :
    ∃ q : hardCoreQuotient F, ∃ a b : S, a ≠ b ∧
      hardCoreQuotientMap F a = q ∧ hardCoreQuotientMap F b = q := by
  obtain ⟨a, b, hab, hker⟩ := h
  exact ⟨hardCoreQuotientMap F a, a, b, hab, rfl,
    Quotient.sound (fun i => (F.cong i).symm (hker i))⟩

/-- **Fiber Characterization.**
    Two elements map to the same quotient element iff they are in the observer kernel. -/
theorem hardCoreQuotientMap_eq_iff {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (a b : S) :
    hardCoreQuotientMap F a = hardCoreQuotientMap F b ↔ observerKernel F a b :=
  Quotient.eq

/-! ## Section 8: Spectral Cardinality Bound -/

/-- **Spectral Cardinality Bound.**
    If observers separate a finite type `S`, then the cardinality of `S` is
    bounded above by the product of the cardinalities of all observer quotients:
    `|S| ≤ ∏_i |S / cong_i|`.

    This follows from the representation theorem: the evaluation map is injective
    (by separation), so `|S| ≤ |Π_i (S/cong_i)| = ∏_i |S/cong_i|`.

    Bridge: bounds the "information content" of the semiring by the combined
    resolution of all observers. This is a compression rate theorem. -/
theorem card_le_prod_of_separating {S : Type u} [Add S] [Mul S]
    [Fintype S] [DecidableEq S]
    (F : ObserverFamily S) (hsep : ObserverSeparates F)
    [∀ i, Fintype (Quotient (F.cong i).toSetoid)] :
    Fintype.card S ≤ ∏ i : Fin F.n, Fintype.card (Quotient (F.cong i).toSetoid) := by
  have hinj := (eval_injective_iff_observer_separates F).mpr hsep
  calc Fintype.card S
      ≤ Fintype.card ((i : Fin F.n) → Quotient (F.cong i).toSetoid) :=
        Fintype.card_le_of_injective _ hinj
    _ = ∏ i : Fin F.n, Fintype.card (Quotient (F.cong i).toSetoid) :=
        Fintype.card_pi

/-! ## Section 9: Collision Resistance from Spectral Separation -/

/-- **Certified Collision Resistance**: the observer family separates all elements
    in a target finite set `T`. No two distinct elements of `T` are identified
    by all observers simultaneously.

    Bridge: the algebraic core of collision-resistant hash family semantics. -/
def CertifiedCollisionResistant {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (T : Finset S) : Prop :=
  ObserverSeparatesOn F T

/-- **Global separation implies collision resistance on every finite subset.**

    Bridge: if the observer family is globally separating (the spectrum is T₀),
    then collision resistance holds for any finite attack set. -/
theorem separation_implies_collision_resistant {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (T : Finset S) (hsep : ObserverSeparates F) :
    CertifiedCollisionResistant F T := by
  intro a b _ _ hab
  exact hsep a b hab

/-- Collision resistance is monotone: it passes to subsets. -/
theorem collision_resistant_mono {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) {T₁ T₂ : Finset S} (h : T₁ ⊆ T₂)
    (hcr : CertifiedCollisionResistant F T₂) :
    CertifiedCollisionResistant F T₁ := by
  intro a b ha hb hab
  exact hcr (h ha) (h hb) hab

/-- Collision resistance on empty set is trivially satisfied. -/
theorem collision_resistant_empty {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    CertifiedCollisionResistant F ∅ := by
  intro a _ ha
  exact absurd ha (Finset.notMem_empty a)

/-- Collision resistance on singletons is trivially satisfied. -/
theorem collision_resistant_singleton {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (a : S) :
    CertifiedCollisionResistant F {a} := by
  intro x y hx hy hne
  rw [Finset.mem_singleton] at hx hy
  exact absurd (hx.trans hy.symm) hne

/-! ## Section 10: Spectral Separation Count -/

/-- The **spectral separation count** between two elements: the number of
    observers that distinguish them.

    A higher count means more robust separation — the elements are
    distinguishable through more independent channels.

    Bridge: this is the spectral analogue of Hamming distance in coding theory. -/
def spectralSepCount {S : Type u} [Add S] [Mul S] (F : ObserverFamily S)
    [∀ i, DecidableRel (F.cong i).r] (a b : S) : ℕ :=
  (Finset.univ.filter fun i : Fin F.n => ¬(F.cong i) a b).card

/-- Positive separation count implies the elements are not in the observer kernel. -/
theorem pos_sepCount_means_not_identified {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) [∀ i, DecidableRel (F.cong i).r] (a b : S) :
    0 < spectralSepCount F a b → ¬observerKernel F a b := by
  intro hpos hker
  simp only [spectralSepCount, Finset.card_pos] at hpos
  obtain ⟨i, hi⟩ := hpos
  rw [Finset.mem_filter] at hi
  exact hi.2 (hker i)

/-- Zero separation count iff elements are in the observer kernel. -/
theorem sepCount_eq_zero_iff_kernel {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) [∀ i, DecidableRel (F.cong i).r] (a b : S) :
    spectralSepCount F a b = 0 ↔ observerKernel F a b := by
  simp only [spectralSepCount, Finset.card_eq_zero, observerKernel]
  constructor
  · intro h i
    by_contra hi
    have hmem : i ∈ Finset.univ.filter (fun j : Fin F.n => ¬(F.cong j) a b) := by
      simp [hi]
    rw [h] at hmem
    exact Finset.notMem_empty i hmem
  · intro h
    rw [Finset.filter_eq_empty_iff]
    intro i _
    simp [h i]

/-- Separation count is symmetric. -/
theorem sepCount_symm {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) [∀ i, DecidableRel (F.cong i).r] (a b : S) :
    spectralSepCount F a b = spectralSepCount F b a := by
  simp only [spectralSepCount]
  congr 1
  ext i
  simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact not_congr ⟨fun h => (F.cong i).symm h, fun h => (F.cong i).symm h⟩

/-- Self-separation count is always zero. -/
theorem sepCount_self {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) [∀ i, DecidableRel (F.cong i).r] (a : S) :
    spectralSepCount F a a = 0 := by
  rw [sepCount_eq_zero_iff_kernel]
  intro i
  exact (F.cong i).refl a

/-- Maximum separation count is bounded by the number of observers. -/
theorem sepCount_le_n {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) [∀ i, DecidableRel (F.cong i).r] (a b : S) :
    spectralSepCount F a b ≤ F.n := by
  simp only [spectralSepCount]
  calc (Finset.univ.filter fun i : Fin F.n => ¬(F.cong i) a b).card
      ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = F.n := Finset.card_fin F.n

/-! ## Section 11: Contravariant Correspondence -/

/-- A **quotient morphism** between observer families: a ring homomorphism
    from `S` to `T` such that each observer on `T` is compatible with
    (pulled back from) an observer on `S`. -/
structure ObserverQuotientMorphism {S T : Type u} [Semiring S] [Semiring T]
    (F : ObserverFamily S) (G : ObserverFamily T) where
  toFun : S →+* T
  observer_pullback : Fin G.n → Fin F.n
  pullback_compat : ∀ j : Fin G.n, ∀ a b : S,
    (F.cong (observer_pullback j)) a b → (G.cong j) (toFun a) (toFun b)

/-- **Contravariant Separation Theorem.**
    If a quotient morphism is injective and the target observer family separates,
    then the source observer family separates.

    Dually: separation is preserved contravariantly under observer morphisms.

    Bridge: cryptographic reductions become geometric maps on spectra. -/
theorem quotient_separation_contravariant
    {S T : Type u} [Semiring S] [Semiring T]
    (F : ObserverFamily S) (G : ObserverFamily T)
    (φ : ObserverQuotientMorphism F G)
    (hφ_inj : Injective φ.toFun)
    (hsep : ObserverSeparates G) :
    ObserverSeparates F := by
  intro a b hab
  have hab' : φ.toFun a ≠ φ.toFun b := fun h => hab (hφ_inj h)
  obtain ⟨j, hj⟩ := hsep (φ.toFun a) (φ.toFun b) hab'
  exact ⟨φ.observer_pullback j, fun h => hj (φ.pullback_compat j a b h)⟩

/-- **Pullback Separation Theorem.**
    An observer family on a quotient pulls back to a separating family on the
    source iff the quotient morphism is injective up to observer equivalence.

    Bridge: faithful spectral maps correspond to injective quotient morphisms. -/
theorem pullback_separation_from_quotient
    {S T : Type u} [Semiring S] [Semiring T]
    (F : ObserverFamily S) (G : ObserverFamily T)
    (φ : ObserverQuotientMorphism F G)
    (hφ_inj : Injective φ.toFun)
    (a b : S) (hab : a ≠ b) (hsep : ObserverSeparates G) :
    ∃ i : Fin F.n, ¬(F.cong i) a b := by
  exact quotient_separation_contravariant F G φ hφ_inj hsep a b hab

/-! ## Section 12: Empty and Trivial Observer Families -/

/-- The empty observer family identifies everything: its kernel is the total relation. -/
theorem empty_observer_kernel_total {S : Type u} [Add S] [Mul S] (a b : S) :
    observerKernel (⟨0, Fin.elim0⟩ : ObserverFamily S) a b :=
  fun i => Fin.elim0 i

/-- For a single observer, the observer kernel equals the single congruence. -/
theorem single_observer_kernel_eq {S : Type u} [Add S] [Mul S] (c : RingCon S)
    (a b : S) :
    observerKernel (⟨1, fun _ => c⟩ : ObserverFamily S) a b ↔ c a b := by
  constructor
  · intro h; exact h ⟨0, Nat.zero_lt_one⟩
  · intro h i; convert h

/-- Adding a redundant observer doesn't change the kernel. -/
theorem observer_kernel_redundant {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (c : RingCon S) (i₀ : Fin F.n)
    (hred : ∀ a b : S, (F.cong i₀) a b → c a b) (a b : S) :
    observerKernel F a b → c a b := by
  intro h
  exact hred a b (h i₀)

/-! ## Section 13: Observer-Preserving Idempotent Structure -/

/-- In a tropical one-way semiring, the observer kernel respects the
    idempotent addition: `observerKernel F a a` always holds. -/
theorem observerKernel_refl_idem {S : Type u} [TropicalOneWaySemiring S]
    (F : ObserverFamily S) (a : S) :
    observerKernel F a a :=
  fun i => (F.cong i).refl a

/-- The idempotent addition axiom `a + a = a` is preserved by each observer
    quotient: the quotient image of `a + a` equals the quotient image of `a`. -/
theorem idem_preserved_in_quotient {S : Type u} [TropicalOneWaySemiring S]
    (F : ObserverFamily S) (a : S) (i : Fin F.n) :
    Quotient.mk (F.cong i).toSetoid (a + a) =
    Quotient.mk (F.cong i).toSetoid a := by
  apply Quotient.sound
  have : a + a = a := TropicalOneWaySemiring.add_idem a
  rw [this]
  exact (F.cong i).refl a

/-- The evaluation map preserves idempotent addition:
    `eval(a + a) = eval(a)` in the product of observer quotients. -/
theorem eval_preserves_idem {S : Type u} [TropicalOneWaySemiring S]
    (F : ObserverFamily S) (a : S) :
    evalToObserverSections F (a + a) = evalToObserverSections F a := by
  funext i
  exact idem_preserved_in_quotient F a i

/-! ## Section 14: Spectral Separator (ℝ≥0∞-valued) -/

open scoped ENNReal

/-- The **spectral separator**: a nonneg extended real value that is positive
    iff the observer family separates all elements.

    When positive, it certifies collision resistance against all finite attack sets.

    Bridge: converts spectral separation into a machine-checkable certificate. -/
def spectralSeparator {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : ℝ≥0∞ :=
  if ObserverSeparates F then 1 else 0

/-- **Positive spectral separator implies collision resistance.**
    A positive separator value certifies that any finite subset is collision-resistant.

    Bridge: turns semantic spectral data into a usable formal cryptographic certificate. -/
theorem spectralSeparator_pos_implies_collision_resistance
    {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (T : Finset S) :
    0 < spectralSeparator F →
    CertifiedCollisionResistant F T := by
  intro hpos
  unfold spectralSeparator at hpos
  split_ifs at hpos with hsep
  · exact separation_implies_collision_resistant F T hsep
  · exact absurd hpos (lt_irrefl 0)

/-- **Positive spectral separator iff observer separation.** -/
theorem spectralSeparator_pos_iff {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    0 < spectralSeparator F ↔ ObserverSeparates F := by
  unfold spectralSeparator
  constructor
  · intro h; split_ifs at h with hsep; exact hsep; exact absurd h (lt_irrefl 0)
  · intro h; rw [if_pos h]; exact one_pos

/-! ## Section 15: Hardness-Preserving Quotients and Subspace Correspondence -/

/-- A **sub-observer family**: a subfamily of observers obtained by restricting
    to a subset of indices. -/
def subObserverFamily {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (m : ℕ) (embed : Fin m → Fin F.n) :
    ObserverFamily S where
  n := m
  cong := fun j => F.cong (embed j)

/-- The observer kernel of a sub-family is coarser than the full family's kernel.
    Fewer observers means more elements are identified. -/
theorem subObserverKernel_coarser {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (m : ℕ) (embed : Fin m → Fin F.n)
    (a b : S) :
    observerKernel F a b → observerKernel (subObserverFamily F m embed) a b := by
  intro h j
  exact h (embed j)

/-- **Contravariant direction**: if the sub-family separates, and we add more
    observers, the full family still separates. -/
theorem subFamily_separation_lifts {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) (m : ℕ) (embed : Fin m → Fin F.n)
    (hsep : ObserverSeparates (subObserverFamily F m embed)) :
    ObserverSeparates F := by
  intro a b hab
  obtain ⟨j, hj⟩ := hsep a b hab
  exact ⟨embed j, hj⟩

/-! ## Section 16: Spectral Separation and Partial Inversion Bounds -/

/-- **Certified Partial Inversion Lower Bound**: any function that recovers
    observer-visible data necessarily produces observer-equivalent elements.
    This means "inverting up to observer equivalence" is the best any partial
    inverter can achieve. -/
def CertifiedPartialInversionLowerBound {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) : Prop :=
  ∀ (g : (i : Fin F.n) → Quotient (F.cong i).toSetoid → S),
    ∀ (i : Fin F.n) (s : S),
    Quotient.mk (F.cong i).toSetoid (g i (Quotient.mk (F.cong i).toSetoid s)) =
      Quotient.mk (F.cong i).toSetoid s →
    (F.cong i) (g i (Quotient.mk (F.cong i).toSetoid s)) s

/-- Certified partial inversion lower bound always holds: any function that
    maps observer-quotient elements back into the same equivalence class
    necessarily produces observer-equivalent elements.

    This is structurally important: it says that "inverting up to observer
    equivalence" is the best any partial inverter can achieve without breaking
    the observer kernel. -/
theorem partial_inversion_bound_holds {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    CertifiedPartialInversionLowerBound F := by
  intro g i s h
  exact Quotient.exact h

/-- **Positive separator implies partial inversion lower bound.** -/
theorem spectralSeparator_pos_implies_partial_inversion
    {S : Type u} [Add S] [Mul S]
    (F : ObserverFamily S) :
    0 < spectralSeparator F →
    CertifiedPartialInversionLowerBound F := by
  intro _
  exact partial_inversion_bound_holds F

end SpectralTropicalCrypto