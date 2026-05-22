/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib
import Pythagorean.ProbeComplexity.RepresentableDimension
import Pythagorean.ProbeComplexity.Theorems

/-!
# Compression Stability Under Probe Enlargement

This file develops a formal theory of **observational compression stability**
for probe families on finite presheaf models. The central result is a
**monotonicity + rigidity package**: enlarging a probe family can only increase
(never decrease) the measurement invariant, and equality holds exactly when
the larger family introduces no new separations.

## Main Definitions

* `ObProbeFamily.SeparatesElements` — a probe family separates two elements
  at an object if they have distinct probe signatures.
* `ObProbeFamily.NoNewSeparation` — a larger family introduces no new separations
  relative to a smaller one.
* `ObProbeFamily.ObsEq` — the observational equivalence relation induced by a
  probe family: two elements are equivalent iff they have the same probe signature.

## Main Results

* `measurementSpaceImageCard_mono` — objectwise monotonicity: enlarging the
  probe family increases the number of distinct signatures at each object.
* `measurementInvariant_mono` — global monotonicity: the measurement invariant
  is monotone under probe enlargement.
* `measurementInvariant_eq_of_noNewSeparation` — equality holds when the larger
  family introduces no new element separations.
* `noNewSeparation_of_measurementInvariant_eq` — conversely, equality of the
  invariant implies no new separations.
* `measurementInvariant_eq_iff_noNewSeparation` — the full iff characterization.
* `card_image_mono_of_refines` — abstract cross-domain theorem: if one function
  refines another (same outputs ⟹ same outputs), the image is at least as large.
* `strict_increase_of_newSeparation` — strict monotonicity when new separations
  exist.

## Cross-Domain Significance

The theorems formalize the categorical analogue of the **data processing inequality**
from information theory. Probe families define observational partitions; enlargement
refines partitions; refinement monotonically increases the number of equivalence
classes. Equality characterizes informational redundancy.

## References

* Shannon, C. E. "A Mathematical Theory of Communication" (1948).
* Blackwell, D. "Equivalent Comparisons of Experiments" (1953).
-/

open Finset Fintype CategoryTheory

noncomputable section

universe u v

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-! ### Abstract Cross-Domain Theorem: Image Cardinality Under Refinement -/

/-
**Abstract refinement lemma for image cardinality.**
If function `g` refines function `f` (meaning `g x = g y → f x = f y`),
then the image of `f` has cardinality at most the image of `g`.

This is the finite, deterministic analogue of the data processing inequality:
post-processing cannot increase the number of distinguishable outputs.

Mathematically: if `g` factors through `f` up to injectivity, the image of `f`
is a quotient of the image of `g`, hence has ≤ cardinality.
-/
theorem card_image_mono_of_refines {α β γ : Type*} [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : α → γ) (hfg : ∀ x y : α, g x = g y → f x = f y) :
    (Finset.univ.image f).card ≤ (Finset.univ.image g).card := by
  -- By definition of $f$ and $g$, there is a well-defined map $h$ from the image of $g$ to the image of $f$ such that $h(g(x)) = f(x)$.
  obtain ⟨h, hh⟩ : ∃ h : (Set.range g) → (Set.range f), ∀ x : α, h (Set.rangeFactorization g x) = Set.rangeFactorization f x := by
    refine' ⟨ _, _ ⟩;
    exact fun x => ⟨ f ( Classical.choose x.2 ), Set.mem_range_self _ ⟩;
    simp +decide [ Set.rangeFactorization ];
    exact fun x => hfg _ _ ( Classical.choose_spec ( Set.mem_range_self x ) );
  have h_surj : Function.Surjective h := by
    intro y
    obtain ⟨x, hx⟩ := y;
    obtain ⟨ y, rfl ⟩ := hx; exact ⟨ _, hh y ⟩ ;
  convert Fintype.card_le_of_surjective _ h_surj using 1;
  · rw [ Fintype.card_of_subtype ] ; aesop;
  · simp +decide [ Set.toFinset_card ];
    convert rfl;
    ext; simp [Set.mem_range]

/-! ### Probe Signature Refinement Under Enlargement -/

/-
When `P ⊆ P'`, equal `P'`-signatures imply equal `P`-signatures. This is the
key refinement property: more probes means finer discrimination.
-/
theorem probeSignature_refines
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    (Y : Ob) :
    ∀ x y : F Y, probeSignature P' r Y x = probeSignature P' r Y y →
      probeSignature P r Y x = probeSignature P r Y y := by
  intro x y hxy; ext Z; specialize hxy; replace hxy := congr_fun hxy ⟨ Z, hPP' Z.2 ⟩ ; aesop;

/-! ### Objectwise Monotonicity -/

/-- **Objectwise monotonicity.** At each object `Y`, the number of distinct probe
signatures increases (or stays the same) when the probe family is enlarged. -/
theorem measurementSpaceImageCard_mono
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)]
    (Y : Ob) :
    measurementSpaceImageCard P r Y ≤ measurementSpaceImageCard P' r Y := by
  unfold measurementSpaceImageCard
  exact card_image_mono_of_refines _ _ (probeSignature_refines r hPP' Y)

/-! ### Global Monotonicity -/

/-- **Theorem 1: Monotonicity under probe enlargement.**
The measurement invariant is monotone: `P ⊆ P'` implies
`measurementInvariant P r ≤ measurementInvariant P' r`.

This is the formal expression of the principle that enlarging the family
of observables can only refine distinguishability, never coarsen it. -/
theorem measurementInvariant_mono
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)] :
    measurementInvariant P r ≤ measurementInvariant P' r := by
  unfold measurementInvariant
  exact Finset.sum_le_sum (fun Y _ => measurementSpaceImageCard_mono r hPP' Y)

/-! ### Observational Equivalence and Separation -/

/-- Two elements at the same object are **observationally equivalent** under a
probe family if they have the same probe signature. This defines the fundamental
equivalence relation whose classes are the "indistinguishability classes" of the
measurement system. -/
def ObProbeFamily.ObsEq
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamily Ob)
    (r : ∀ Y Z, F Y → F Z)
    (Y : Ob) (x y : F Y) : Prop :=
  probeSignature P r Y x = probeSignature P r Y y

/-- Observational equivalence is an equivalence relation. -/
theorem ObProbeFamily.ObsEq_equivalence
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamily Ob) (r : ∀ Y Z, F Y → F Z) (Y : Ob) :
    Equivalence (P.ObsEq r Y) :=
  ⟨fun _ => rfl, fun h => h.symm, fun h1 h2 => h1.trans h2⟩

/-- A probe family **separates elements** `x` and `y` at object `Y` if they
have distinct probe signatures. -/
def ObProbeFamily.SeparatesElements
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P : ObProbeFamily Ob)
    (r : ∀ Y Z, F Y → F Z)
    {Y : Ob} (x y : F Y) : Prop :=
  probeSignature P r Y x ≠ probeSignature P r Y y

/-- **No new separation**: the larger family `P'` introduces no element-level
separations that `P` doesn't already make. Equivalently, `P` already distinguishes
every pair that `P'` distinguishes. -/
def ObProbeFamily.NoNewSeparation
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P P' : ObProbeFamily Ob)
    (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∀ ⦃Y : Ob⦄ ⦃x y : F Y⦄, P'.SeparatesElements r x y → P.SeparatesElements r x y

/-- No new separation is equivalent to: `P`-equivalence implies `P'`-equivalence.
(Contrapositive of the definition.) -/
theorem ObProbeFamily.noNewSeparation_iff_obsEq
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P P' : ObProbeFamily Ob) (r : ∀ Y Z, F Y → F Z) :
    P.NoNewSeparation P' r ↔
      ∀ ⦃Y : Ob⦄ ⦃x y : F Y⦄, P.ObsEq r Y x y → P'.ObsEq r Y x y := by
  simp only [ObProbeFamily.NoNewSeparation, ObProbeFamily.SeparatesElements, ObProbeFamily.ObsEq]
  constructor
  · intro h Y x y hobs
    by_contra hne
    exact absurd hobs (h hne)
  · intro h Y x y hsep hns
    exact hsep (h hns)

/-- Enlargement refines observational equivalence: `P ⊆ P'` implies
that `P'`-equivalent elements are `P`-equivalent. -/
theorem ObsEq_of_le
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P') :
    ∀ ⦃Y : Ob⦄ ⦃x y : F Y⦄, ObProbeFamily.ObsEq P' r Y x y →
      ObProbeFamily.ObsEq P r Y x y := by
  intro Y x y h
  exact probeSignature_refines r hPP' Y x y h

/-! ### Equality Characterization -/

/-- The measurement space image card equals the number of distinct probe
signatures, which equals the number of observational equivalence classes. -/
theorem measurementSpaceImageCard_eq_image_card
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    (P : ObProbeFamily Ob) (r : ∀ Y Z, F Y → F Z) (Y : Ob)
    [DecidableEq (∀ Z : P, F ↑Z)] :
    measurementSpaceImageCard P r Y = (Finset.univ.image (probeSignature P r Y)).card :=
  rfl

/-
**Key lemma for equality characterization.** If the image cardinalities are
equal AND the finer function refines the coarser one, then the two functions
have the same equivalence classes.
-/
theorem image_card_eq_of_refines_and_eq {α β γ : Type*}
    [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : α → γ)
    (hfg : ∀ x y : α, g x = g y → f x = f y)
    (heq : (Finset.univ.image f).card = (Finset.univ.image g).card) :
    ∀ x y : α, f x = f y → g x = g y := by
  have h_bij : ∃ ε : Finset.univ.image g ≃ Finset.univ.image f, ∀ x, ε ⟨g x, Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩ = ⟨f x, Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩ := by
    have h_bij : Function.Bijective (fun x : Finset.univ.image g => ⟨f (Classical.choose (Finset.mem_image.mp x.2)), Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩ : Finset.univ.image g → Finset.univ.image f) := by
      have h_bij : Function.Surjective (fun x : Finset.univ.image g => ⟨f (Classical.choose (Finset.mem_image.mp x.2)), Finset.mem_image_of_mem _ (Finset.mem_univ _)⟩ : Finset.univ.image g → Finset.univ.image f) := by
        intro x;
        obtain ⟨ y, hy ⟩ := Finset.mem_image.mp x.2;
        use ⟨ g y, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩;
        grind;
      have := Fintype.bijective_iff_surjective_and_card ( fun x : Finset.univ.image g => ⟨ f ( Classical.choose ( Finset.mem_image.mp x.2 ) ), Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩ : Finset.univ.image g → Finset.univ.image f ) ; aesop;
    refine' ⟨ Equiv.ofBijective _ h_bij, _ ⟩;
    intro x; have := Classical.choose_spec ( Finset.mem_image.mp ( show g x ∈ Finset.image g univ from Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ) ) ; aesop;
  cases' h_bij with ε hε h_bij; intro x y hxy; have := ε.injective ( by aesop : ε ⟨ g x, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩ = ε ⟨ g y, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩ ) ; aesop;

/-
**Theorem 2: Equality from redundancy.**
If the larger family introduces no new separations, the measurement
invariant is unchanged.
-/
theorem measurementInvariant_eq_of_noNewSeparation
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)]
    (hred : ObProbeFamily.NoNewSeparation P P' r) :
    measurementInvariant P r = measurementInvariant P' r := by
  -- Apply the results that show the equivalence of themeasurementSpaceImageCard.
  have h_image_count_eq (Y : Ob) : measurementSpaceImageCard P r Y = measurementSpaceImageCard P' r Y := by
    refine' le_antisymm _ _;
    · exact card_image_mono_of_refines _ _ fun x y hxy => ObsEq_of_le _ hPP' hxy;
    · convert card_image_mono_of_refines ( probeSignature P' r Y ) ( probeSignature P r Y ) _;
      intro x y hxy; specialize hred; contrapose! hred; aesop;
  exact Finset.sum_congr rfl fun Y _ => h_image_count_eq Y ▸ rfl

/-
**Theorem 3: Equality implies redundancy (rigidity).**
If the measurement invariant is unchanged under enlargement, then the
larger family introduces no new separations. This is the nontrivial
direction establishing rigidity.
-/
theorem noNewSeparation_of_measurementInvariant_eq
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)]
    (heq : measurementInvariant P r = measurementInvariant P' r) :
    ObProbeFamily.NoNewSeparation P P' r := by
  have h_eq_card : ∀ Y, (Finset.univ.image (probeSignature P r Y)).card = (Finset.univ.image (probeSignature P' r Y)).card := by
    exact fun Y => le_antisymm ( measurementSpaceImageCard_mono r hPP' Y ) ( by contrapose! heq; exact ne_of_lt ( Finset.sum_lt_sum ( fun Y _ => measurementSpaceImageCard_mono r hPP' Y ) ⟨ Y, Finset.mem_univ Y, heq ⟩ ) );
  intro Y x y hxy;
  have := image_card_eq_of_refines_and_eq ( probeSignature P r Y ) ( probeSignature P' r Y ) ( probeSignature_refines r hPP' Y ) ( h_eq_card Y );
  exact fun h => hxy <| this x y h

/-- **Theorem 4 (Headline): The measurement invariant equality iff characterization.**
The measurement invariant is unchanged under probe enlargement if and only if
the larger family introduces no new element-level separations. This is the
categorical analogue of the data processing equality condition. -/
theorem measurementInvariant_eq_iff_noNewSeparation
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)] :
    measurementInvariant P r = measurementInvariant P' r ↔
      ObProbeFamily.NoNewSeparation P P' r := by
  exact ⟨noNewSeparation_of_measurementInvariant_eq r hPP',
    measurementInvariant_eq_of_noNewSeparation r hPP'⟩

/-! ### Strict Monotonicity -/

/-
**Strict monotonicity under new separation.**
If the larger family separates at least one pair that the smaller family does not,
the measurement invariant strictly increases.
-/
theorem strict_increase_of_newSeparation
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)]
    (hnew : ∃ Y : Ob, ∃ x y : F Y,
      P'.SeparatesElements r x y ∧ ¬P.SeparatesElements r x y) :
    measurementInvariant P r < measurementInvariant P' r := by
  refine' lt_of_le_of_ne ( measurementInvariant_mono r hPP' ) _;
  exact fun h => by obtain ⟨ Y, x, y, h₁, h₂ ⟩ := hnew; have := noNewSeparation_of_measurementInvariant_eq r hPP' h; exact h₂ ( this h₁ ) ;

/-! ### Separating Family Saturation -/

/-
**Theorem 5: Separating families saturate.**
If `P` already has injective probe signatures (i.e., separates the presheaf),
then any enlargement `P'` preserves the measurement invariant.

This is the formal statement that "once you resolve everything, more probes
are redundant."
-/
theorem measurementInvariant_eq_of_presheafSeparates_superset
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)]
    (hsep : PresheafProbeSeparates P r) :
    measurementInvariant P r = measurementInvariant P' r := by
  apply measurementInvariant_eq_of_noNewSeparation r hPP';
  intro Y x y hxy; exact (by
  contrapose! hxy; simp_all +decide [ PresheafProbeSeparates ] ;
  exact fun h => hxy <| by have := hsep Y; exact this.ne_iff.mpr <| by have := h; exact by rintro rfl; exact this rfl;);

end