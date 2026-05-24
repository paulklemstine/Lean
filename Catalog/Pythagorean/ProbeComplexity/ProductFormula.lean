/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib
import Pythagorean.ProbeComplexity.Theorems

/-!
# Product Formula for Probe Complexity κ

This file establishes the **product upper bound** for probe complexity of finite categories:

$$κ(C × D) ≤ κ(C) · |Ob(D)| + κ(D) · |Ob(C)|$$

and proves that the naïve `max` law fails structurally.

## Main Definitions

* `LiftLeftProbes` — lifts a probe family from `C` to `C × D`.
* `LiftRightProbes` — lifts a probe family from `D` to `C × D`.
* `NonThinWitness'` — existence of a genuine parallel pair of morphisms.
* `buildProductSeparatingFamily` — constructs a separating family for `C × D`.

## Main Results

* `probeComplexity_prod_le` — **Product upper bound**: `κ(C × D) ≤ κ(C) · |D| + κ(D) · |C|`.
* `probeComplexity_prod_thin_left_le` — **Thin-factor bound**: if `C` is thin,
  `κ(C × D) ≤ κ(D) · |C|`.
* `probeComplexity_prod_discrete_right_lb` — **Lower bound**: if `C` has a parallel pair and `D`
  is discrete, `κ(C × D) ≥ Fintype.card D`.
* `max_lt_probeComplexity_prod` — **Refutation of max-law**.
-/

open CategoryTheory Finset Fintype

noncomputable section

set_option linter.unusedSectionVars false

universe u v

variable (C : Type u) [Category C] [Fintype C] [DecidableEq C]
variable (D : Type v) [Category D] [Fintype D] [DecidableEq D]

/-! ## New Definitions -/

/-- **Lift left probes**: given a probe family `SC` in `C`, produce a family in `C × D`
by pairing each probe with every object of `D`. This is `SC ×ˢ Finset.univ`. -/
def LiftLeftProbes (SC : ProbeFamily C) : ProbeFamily (C × D) :=
  SC ×ˢ Finset.univ

/-- **Lift right probes**: given a probe family `SD` in `D`, produce a family in `C × D`
by pairing every object of `C` with each probe. This is `Finset.univ ×ˢ SD`. -/
def LiftRightProbes (SD : ProbeFamily D) : ProbeFamily (C × D) :=
  Finset.univ ×ˢ SD

/-- A **non-thin witness** for a category `C` is evidence that there exist two distinct
parallel morphisms. Categories with such a witness require at least one probe. -/
structure NonThinWitness' (C : Type u) [Category C] where
  X : C
  Y : C
  f : X ⟶ Y
  g : X ⟶ Y
  hne : f ≠ g

/-- **Build the product separating family** from separating families for each factor.
The construction unions the left-lifted and right-lifted families. -/
def buildProductSeparatingFamily
    (SC : ProbeFamily C) (SD : ProbeFamily D) : ProbeFamily (C × D) :=
  LiftLeftProbes C D SC ∪ LiftRightProbes C D SD

/-! ## Cardinality Lemmas -/

@[simp]
theorem card_liftLeftProbes (SC : ProbeFamily C) :
    (LiftLeftProbes C D SC).card = SC.card * Fintype.card D := by
  simp [LiftLeftProbes, Finset.card_product]

@[simp]
theorem card_liftRightProbes (SD : ProbeFamily D) :
    (LiftRightProbes C D SD).card = Fintype.card C * SD.card := by
  simp [LiftRightProbes, Finset.card_product]

/-- The product separating family has cardinality at most
`|SC| · |D| + |C| · |SD|`. -/
theorem card_buildProductSeparatingFamily_le
    (SC : ProbeFamily C) (SD : ProbeFamily D) :
    (buildProductSeparatingFamily C D SC SD).card
      ≤ SC.card * Fintype.card D + Fintype.card C * SD.card := by
  unfold buildProductSeparatingFamily
  calc (LiftLeftProbes C D SC ∪ LiftRightProbes C D SD).card
      ≤ (LiftLeftProbes C D SC).card + (LiftRightProbes C D SD).card :=
        Finset.card_union_le _ _
    _ = SC.card * Fintype.card D + Fintype.card C * SD.card := by simp

/-! ## Morphism Decomposition in Product Categories -/

/-- Morphisms in the product category are equal iff both components are equal. -/
theorem prod_hom_eq_iff {X Y : C × D} {f g : X ⟶ Y} :
    f = g ↔ f.1 = g.1 ∧ f.2 = g.2 :=
  ⟨fun h => ⟨congr_arg Prod.fst h, congr_arg Prod.snd h⟩,
   fun ⟨h1, h2⟩ => Prod.ext h1 h2⟩

/-! ## Separation by Lifted Probes -/

/-- Left-lifted probes separate morphisms that differ in the first coordinate. -/
theorem left_lift_separates
    (SC : ProbeFamily C)
    (hSC : SC.IsSeparating)
    {X Y : C × D} {f g : X ⟶ Y}
    (hfg : f.1 ≠ g.1) :
    ∃ Z ∈ LiftLeftProbes C D SC, ∃ h : Z ⟶ X, h ≫ f ≠ h ≫ g := by
  by_contra h_contra
  push_neg at h_contra
  apply hfg
  apply hSC f.1 g.1
  intro Z hZ h₁
  have hZmem : (Z, X.2) ∈ LiftLeftProbes C D SC := by
    simp [LiftLeftProbes, Finset.mem_product]; exact hZ
  have := h_contra (Z, X.2) hZmem (h₁, 𝟙 X.2)
  exact congr_arg Prod.fst this

/-- Right-lifted probes separate morphisms that differ in the second coordinate. -/
theorem right_lift_separates
    (SD : ProbeFamily D)
    (hSD : SD.IsSeparating)
    {X Y : C × D} {f g : X ⟶ Y}
    (hfg : f.2 ≠ g.2) :
    ∃ Z ∈ LiftRightProbes C D SD, ∃ h : Z ⟶ X, h ≫ f ≠ h ≫ g := by
  by_contra h_contra
  push_neg at h_contra
  apply hfg
  apply hSD f.2 g.2
  intro Z hZ h₂
  have hZmem : (X.1, Z) ∈ LiftRightProbes C D SD := by
    simp [LiftRightProbes, Finset.mem_product]; exact hZ
  have := h_contra (X.1, Z) hZmem (𝟙 X.1, h₂)
  exact congr_arg Prod.snd this

/-- The product separating family is separating for the product category. -/
theorem buildProductSeparatingFamily_isSeparating
    (SC : ProbeFamily C) (SD : ProbeFamily D)
    (hSC : SC.IsSeparating) (hSD : SD.IsSeparating) :
    (buildProductSeparatingFamily C D SC SD).IsSeparating := by
  intro X Y f g hall
  rw [prod_hom_eq_iff]
  constructor
  · by_contra hne
    obtain ⟨Z, hZ, h, hh⟩ := left_lift_separates C D SC hSC hne
    exact hh (hall Z (Finset.mem_union_left _ hZ) h)
  · by_contra hne
    obtain ⟨Z, hZ, h, hh⟩ := right_lift_separates C D SD hSD hne
    exact hh (hall Z (Finset.mem_union_right _ hZ) h)

/-! ## Theorem 1: Product Upper Bound for κ -/

/-- **Product upper bound for probe complexity (Theorem 1).**

For finite categories `C` and `D`,
$$κ(C × D) ≤ κ(C) · |Ob(D)| + κ(D) · |Ob(C)|.$$

A separating family for `C × D` can be assembled by replicating each `C`-probe
across every object of `D`, and each `D`-probe across every object of `C`. -/
theorem probeComplexity_prod_le :
    probeComplexity (C × D) ≤
      probeComplexity C * Fintype.card D + probeComplexity D * Fintype.card C := by
  obtain ⟨SC, hSCcard, hSCsep⟩ := probeComplexity_achieved (C := C)
  obtain ⟨SD, hSDcard, hSDsep⟩ := probeComplexity_achieved (C := D)
  calc probeComplexity (C × D)
      ≤ (buildProductSeparatingFamily C D SC SD).card :=
        probeComplexity_le_of_separating _ _
          (buildProductSeparatingFamily_isSeparating C D SC SD hSCsep hSDsep)
    _ ≤ SC.card * Fintype.card D + Fintype.card C * SD.card :=
        card_buildProductSeparatingFamily_le C D SC SD
    _ = probeComplexity C * Fintype.card D + probeComplexity D * Fintype.card C := by
        rw [hSCcard, hSDcard]; ring

/-! ## Theorem 2: Thin-Factor Bound -/

/-- A category is **thin** if every hom-set has at most one morphism. -/
def IsThinCategory' (C : Type u) [Category C] : Prop :=
  ∀ (X Y : C) (f g : X ⟶ Y), f = g

/-- **Thin-factor upper bound (Theorem 2).**
If `C` is a thin category, then `κ(C × D) ≤ κ(D) · |Ob(C)|`.
Since `κ(C) = 0`, only `D`-probes replicated across `C` are needed. -/
theorem probeComplexity_prod_thin_left_le
    (hC : IsThinCategory' C) :
    probeComplexity (C × D) ≤ probeComplexity D * Fintype.card C := by
  calc probeComplexity (C × D)
      ≤ probeComplexity C * Fintype.card D + probeComplexity D * Fintype.card C :=
        probeComplexity_prod_le C D
    _ = probeComplexity D * Fintype.card C := by
        rw [probeComplexity_eq_zero_of_subsingleton_hom hC]; ring

/-! ## Theorem 3: Lower Bound and Refutation of the Max-Law -/

/-- A category is **strictly discrete** if every hom-set between distinct objects is empty
and every endo-hom-set is a subsingleton (so the only endomorphism is `𝟙`). -/
structure IsStrictlyDiscrete (D : Type v) [Category D] : Prop where
  /-- Morphisms imply source equals target. -/
  hom_eq : ∀ (X Y : D) (_ : X ⟶ Y), X = Y
  /-- All hom-sets have at most one morphism (thinness). -/
  thin : ∀ (X Y : D) (f g : X ⟶ Y), f = g

/-- A strictly discrete category is thin. -/
theorem isStrictlyDiscrete_thin (hD : IsStrictlyDiscrete D) : IsThinCategory' D :=
  hD.thin

/-- A strictly discrete category has probe complexity zero. -/
theorem probeComplexity_strictlyDiscrete_eq_zero
    (hD : IsStrictlyDiscrete D) :
    probeComplexity D = 0 :=
  probeComplexity_eq_zero_of_subsingleton_hom hD.thin

/-
**Lower bound for product with discrete factor (Theorem 3a).**
If `C` has a non-thin witness (parallel pair) and `D` is strictly discrete, then
`κ(C × D) ≥ Fintype.card D`.

In a discrete category, a probe `(q, d)` can only access morphisms at objects
with second coordinate `d` (since the only morphisms in `D` are identities).
So we need at least one probe per object of `D`.
-/
theorem probeComplexity_prod_discrete_right_lb
    (hw : NonThinWitness' C)
    (hD : IsStrictlyDiscrete D) :
    Fintype.card D ≤ probeComplexity (C × D) := by
  have h_card_D_le_card_P : ∀ (P : ProbeFamily (C × D)), P.IsSeparating → Fintype.card D ≤ P.card := by
    intro P hP
    have h_surj : ∀ d : D, ∃ p ∈ P, p.2 = d := by
      intro d
      by_contra h_contra
      push_neg at h_contra
      have h_not_surj : ¬Function.Surjective (fun p : P => p.val.2) := by
        exact fun h => by obtain ⟨ p, hp ⟩ := h d; specialize h_contra p; aesop;
      generalize_proofs at *; (
      have h_not_surj : ∃ f g : (hw.X, d) ⟶ (hw.Y, d), f ≠ g ∧ ∀ p : P, ∀ h : p.val ⟶ (hw.X, d), h ≫ f = h ≫ g := by
        refine' ⟨ ( hw.f, 𝟙 d ), ( hw.g, 𝟙 d ), _, _ ⟩ <;> simp_all +decide [ Prod.ext_iff ];
        · exact hw.hne;
        · intro a b hab f g; specialize h_contra a b hab; have := hD.hom_eq b d g; aesop;
      generalize_proofs at *; (
      exact h_not_surj.elim fun f hf => hf.elim fun g hg => hg.1 ( hP _ _ fun p hp h => hg.2 ⟨ p, hp ⟩ h ) ;));
    have h_card_D_le_card_P : Fintype.card D ≤ Finset.card (Finset.image (fun p => p.2) P) := by
      exact Finset.card_le_card fun x hx => by obtain ⟨ p, hp, rfl ⟩ := h_surj x; exact Finset.mem_image_of_mem _ hp;
    exact h_card_D_le_card_P.trans ( Finset.card_image_le );
  obtain ⟨ P, hP₁, hP₂ ⟩ := probeComplexity_achieved ( C × D ) ; exact hP₁.symm ▸ h_card_D_le_card_P P hP₂;

/-- **Refutation of the max-law (Theorem 3b).**
Under explicit hypotheses, `max(κ(C), κ(D)) < κ(C × D)`.

This shows that `max` is structurally wrong as a product formula for κ.
The gap grows linearly with `|D|`: for a category `C` with a parallel pair
and a discrete category `D`, `max(κ(C), κ(D)) = κ(C)` while
`κ(C × D) ≥ |D|`. -/
theorem max_lt_probeComplexity_prod
    (hw : NonThinWitness' C)
    (hD : IsStrictlyDiscrete D)
    (hcard : probeComplexity C < Fintype.card D) :
    max (probeComplexity C) (probeComplexity D) < probeComplexity (C × D) := by
  rw [probeComplexity_strictlyDiscrete_eq_zero D hD]; simp
  exact lt_of_lt_of_le hcard (probeComplexity_prod_discrete_right_lb C D hw hD)

/-! ## Verified Computational Method -/

/-- The product separating family construction is correct. -/
theorem buildProductSeparatingFamily_correct
    {SC : ProbeFamily C} {SD : ProbeFamily D}
    (hSC : SC.IsSeparating) (hSD : SD.IsSeparating) :
    (buildProductSeparatingFamily C D SC SD).IsSeparating :=
  buildProductSeparatingFamily_isSeparating C D SC SD hSC hSD

end