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
for probe families on finite presheaf models. The central package is a
**monotonicity + rigidity** result: enlarging a probe family can only increase
(never decrease) the measurement invariant, and equality holds exactly when
the larger family introduces no new separations.

## Main Definitions

* `ObProbeFamily.ObsEq` — the observational equivalence relation induced by a
  probe family: two elements are equivalent iff they have the same probe signature.
* `ObProbeFamily.SeparatesElements` — a probe family separates two elements
  at an object if they have distinct probe signatures.
* `ObProbeFamily.NoNewSeparation` — a larger family introduces no new separations
  relative to a smaller one.
* `ObProbeFamily.Refines` — `P'` refines `P` if `P'`-equivalence implies `P`-equivalence.
* `ObProbeFamily.RedundantOver` — `P'` is redundant over `P` if they induce the same
  observational equivalence relation (mutual refinement).

## Main Results

### Monotonicity (Data Processing Inequality)
* `measurementSpaceImageCard_mono` — objectwise monotonicity under probe enlargement.
* `measurementInvariant_mono` — global monotonicity of the measurement invariant.

### Equality and Redundancy
* `measurementInvariant_eq_of_noNewSeparation` — equality holds when the larger
  family introduces no new element separations.
* `noNewSeparation_of_measurementInvariant_eq` — equality of the invariant implies
  no new separations (rigidity).
* `measurementInvariant_eq_iff_noNewSeparation` — the full iff characterization.

### Strict Monotonicity
* `strict_increase_of_newSeparation` — strict monotonicity when new separations exist.

### Cross-Domain Bridges
* `card_image_mono_of_refines` — abstract partition refinement monotonicity
  (the data processing inequality for deterministic channels).
* `data_processing_inequality_for_measurementInvariant` — named bridge to
  information theory.
* `measurementInvariant_eq_of_presheafSeparates_superset` — saturated families
  are stable under enlargement.

## Cross-Domain Significance

The theorems formalize the categorical analogue of the **data processing inequality**
from information theory. Probe families define observational partitions; enlargement
refines partitions; refinement monotonically increases the number of equivalence
classes. Equality characterizes informational redundancy.
-/

open Finset Fintype CategoryTheory

noncomputable section

universe u v

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

variable {Ob : Type u} [Fintype Ob] [DecidableEq Ob]

/-! ## Section 1: Abstract Cross-Domain Theorem — Image Cardinality Under Refinement -/

/-
**Abstract refinement lemma for image cardinality.**
If function `g` refines function `f` (meaning `g x = g y → f x = f y`),
then the image of `f` has cardinality at most the image of `g`.

This is the finite, deterministic analogue of the **data processing inequality**:
post-processing cannot increase the number of distinguishable outputs.
-/
theorem card_image_mono_of_refines {α β γ : Type*} [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : α → γ) (hfg : ∀ x y : α, g x = g y → f x = f y) :
    (Finset.univ.image f).card ≤ (Finset.univ.image g).card := by
  -- Let $S = \{ y \in \gamma \mid \exists x \in \alpha, g(x) = y \}$.
  set S := Finset.image g Finset.univ with hS_def;
  -- Define a function $h : S \to \beta$ by $h(y) = f(x)$ for any $x \in \alpha$ such that $g(x) = y$.
  have h_exists : ∃ h : S → β, ∀ x : α, h ⟨g x, Finset.mem_image_of_mem g (Finset.mem_univ x)⟩ = f x := by
    exact ⟨ fun ⟨ y, hy ⟩ => f ( Classical.choose ( Finset.mem_image.mp hy ) ), fun x => hfg _ _ ( Classical.choose_spec ( Finset.mem_image.mp ( Finset.mem_image_of_mem g ( Finset.mem_univ x ) ) ) |>.2 ) ⟩;
  cases' h_exists with h hh; have := Finset.card_le_card ( show Finset.image f Finset.univ ⊆ Finset.image h Finset.univ from ?_ ) ; simp_all +decide ;
  · exact this.trans ( Finset.card_image_le.trans ( by simp +decide [ hS_def ] ) );
  · grind +locals

/-
**Reverse direction for equal image cardinalities under refinement.**
If `g` refines `f` and they have the same image cardinality, then `f` refines `g` too.
This upgrades the surjection between images to a bijection.
-/
theorem image_card_eq_of_refines_and_eq {α β γ : Type*}
    [Fintype α] [DecidableEq β] [DecidableEq γ]
    (f : α → β) (g : α → γ)
    (hfg : ∀ x y : α, g x = g y → f x = f y)
    (heq : (Finset.univ.image f).card = (Finset.univ.image g).card) :
    ∀ x y : α, f x = f y → g x = g y := by
  -- Since $g$ refines $f$, the image of $g$ is a refinement of the image of $f$.
  have h_refinement : Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ) = Finset.card (Finset.image g Finset.univ) := by
    refine' Finset.card_bij ( fun x hx => x.1 ) _ _ _ <;> simp +decide;
    exact fun x y h => ⟨ h, hfg x y h ⟩;
  have h_bijection : Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ) = Finset.card (Finset.image (fun x => f x) Finset.univ) := by
    convert h_refinement using 1;
  have h_bijection : Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ) = Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ |> Finset.image (fun p => p.2)) := by
    convert h_bijection using 1;
    exact congr_arg Finset.card ( by ext; aesop );
  have h_bijection : Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ) = Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ |> Finset.image (fun p => p.2)) → ∀ p q : γ × β, p ∈ Finset.image (fun x => (g x, f x)) Finset.univ → q ∈ Finset.image (fun x => (g x, f x)) Finset.univ → p.2 = q.2 → p = q := by
    intro h p q hp hq h_eq
    have h_inj : Finset.card (Finset.image (fun p => p.2) (Finset.image (fun x => (g x, f x)) Finset.univ)) = Finset.card (Finset.image (fun x => (g x, f x)) Finset.univ) := by
      exact h.symm;
    exact Finset.card_image_iff.mp h_inj hp hq h_eq;
  exact fun x y hxy => congr_arg Prod.fst ( h_bijection ‹_› _ _ ( Finset.mem_image_of_mem _ ( Finset.mem_univ x ) ) ( Finset.mem_image_of_mem _ ( Finset.mem_univ y ) ) hxy )

/-! ## Section 2: Refinement Definitions -/

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

/-- `P'` **refines** `P` if `P'`-equivalence implies `P`-equivalence:
the partition induced by `P'` is at least as fine as that induced by `P`. -/
def ObProbeFamily.Refines
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P' P : ObProbeFamily Ob)
    (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∀ ⦃Y : Ob⦄ ⦃x y : F Y⦄, P'.ObsEq r Y x y → P.ObsEq r Y x y

/-- `P'` is **redundant over** `P` if the two probe families induce identical
observational equivalence relations — no new distinctions and no lost distinctions.
This is mutual refinement: the information content is exactly the same. -/
def ObProbeFamily.RedundantOver
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P' P : ObProbeFamily Ob)
    (r : ∀ Y Z, F Y → F Z) : Prop :=
  ∀ ⦃Y : Ob⦄ ⦃x y : F Y⦄, P.ObsEq r Y x y ↔ P'.ObsEq r Y x y

/-! ## Section 3: Refinement Lemmas -/

/-- No new separation is equivalent to: `P`-equivalence implies `P'`-equivalence. -/
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

/-- Redundancy is equivalent to mutual refinement. -/
theorem redundantOver_iff_mutual_refinement
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    (P P' : ObProbeFamily Ob) (r : ∀ Y Z, F Y → F Z) :
    P'.RedundantOver P r ↔ (P'.Refines P r ∧ P.Refines P' r) := by
  constructor
  · intro h
    exact ⟨fun {Y x y} hxy => (h (x := x) (y := y)).mpr hxy,
           fun {Y x y} hxy => (h (x := x) (y := y)).mp hxy⟩
  · intro ⟨h1, h2⟩ Y x y
    exact ⟨fun hxy => h2 hxy, fun hxy => h1 hxy⟩

/-- Probe signature refinement: when `P ⊆ P'`, equal `P'`-signatures imply equal
`P`-signatures. -/
theorem probeSignature_refines
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    (Y : Ob) :
    ∀ x y : F Y, probeSignature P' r Y x = probeSignature P' r Y y →
      probeSignature P r Y x = probeSignature P r Y y := by
  intro x y hxy
  ext ⟨Z, hZ⟩
  exact congr_fun hxy ⟨Z, hPP' hZ⟩

/-- Enlargement refines observational equivalence: `P ⊆ P'` implies
that `P'`-equivalent elements are `P`-equivalent. -/
theorem ObsEq_of_le
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P') :
    ∀ ⦃Y : Ob⦄ ⦃x y : F Y⦄, ObProbeFamily.ObsEq P' r Y x y →
      ObProbeFamily.ObsEq P r Y x y :=
  fun {_} {_} {_} h => probeSignature_refines r hPP' _ _ _ h

/-- Subset implies refinement. -/
theorem ObProbeFamily.refines_of_subset
    {F : Ob → Type v} [∀ Y, Fintype (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P') :
    P'.Refines P r :=
  fun {_Y _x _y} hxy => ObsEq_of_le r hPP' hxy

/-! ## Section 4: Monotonicity (Data Processing Inequality) -/

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

/-- **Theorem 1: Monotonicity under probe enlargement (Data Processing Inequality).**
The measurement invariant is monotone: `P ⊆ P'` implies
`measurementInvariant P r ≤ measurementInvariant P' r`. -/
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

/-- **Data processing inequality for measurement invariant** — named bridge to
information theory. -/
theorem data_processing_inequality_for_measurementInvariant
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)] :
    measurementInvariant P r ≤ measurementInvariant P' r :=
  measurementInvariant_mono r hPP'

/-! ## Section 5: Equality and Redundancy -/

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
  refine' le_antisymm ( data_processing_inequality_for_measurementInvariant r hPP' ) ( Finset.sum_le_sum fun Y _ => _ );
  convert card_image_mono_of_refines ( probeSignature P' r Y ) ( probeSignature P r Y ) _;
  exact fun x y hxy => by_contra fun h => hred h |> fun h' => hxy |> fun hxy' => h' hxy'

/-
**Theorem 3: Equality implies redundancy (Rigidity).**
If the measurement invariant is unchanged under enlargement, then the
larger family introduces no new separations.
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
  intro Y x yq; simp_all +decide [ measurementInvariant ] ;
  contrapose! heq;
  refine' ne_of_lt ( Finset.sum_lt_sum _ _ );
  · exact fun i _ => measurementSpaceImageCard_mono r hPP' i;
  · refine' ⟨ Y, Finset.mem_univ _, _ ⟩;
    refine' lt_of_le_of_ne ( measurementSpaceImageCard_mono r hPP' Y ) _;
    intro h; have := image_card_eq_of_refines_and_eq ( probeSignature P r Y ) ( probeSignature P' r Y ) ( probeSignature_refines r hPP' Y ) ; simp_all +decide [ ObProbeFamily.SeparatesElements ] ;
    exact heq.1 ( this ( by simpa [ measurementSpaceImageCard ] using h ) x yq heq.2 )

/-- **Theorem 4 (Headline): The measurement invariant equality iff characterization.**
The measurement invariant is unchanged under probe enlargement if and only if
the larger family introduces no new element-level separations. -/
theorem measurementInvariant_eq_iff_noNewSeparation
    {F : Ob → Type v} [∀ Y, Fintype (F Y)] [∀ Y, DecidableEq (F Y)]
    {P P' : ObProbeFamily Ob}
    (r : ∀ Y Z, F Y → F Z)
    (hPP' : P ⊆ P')
    [DecidableEq (∀ Z : P, F ↑Z)]
    [DecidableEq (∀ Z : P', F ↑Z)] :
    measurementInvariant P r = measurementInvariant P' r ↔
      ObProbeFamily.NoNewSeparation P P' r :=
  ⟨noNewSeparation_of_measurementInvariant_eq r hPP',
    measurementInvariant_eq_of_noNewSeparation r hPP'⟩

/-! ## Section 6: Strict Monotonicity -/

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
  contrapose! hnew;
  have := noNewSeparation_of_measurementInvariant_eq r hPP' hnew; aesop;

/-! ## Section 7: Separating Family Saturation -/

/-
**Separating families saturate.**
If `P` already has injective probe signatures (i.e., separates the presheaf),
then any enlargement `P'` preserves the measurement invariant.
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
  intros Y x y hxy;
  contrapose! hxy;
  exact fun h => hxy <| hsep Y |> fun hsep => hsep.ne_iff.mpr <| by aesop;

end