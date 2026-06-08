/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib
import Pythagorean.ProbeComplexity.ToposCompressionDefs

/-!
# Compression Additivity Under Categorical Products

This file develops the theory of compression complexity under categorical products
of finite presheaf models, establishing that product behaves like an additive dimension.

## Main Definitions

* `FinitePresheafModel` — a bundled finite presheaf model.
* `FinitePresheafModel.prod` — the product of two finite presheaf models.
* `compressionComplexity` — compression complexity of a bundled model.
* `ProbeIndependent` — structural separability hypothesis for full additivity.
* `distinguishabilityCardAt` — distinguishability at an object, bridging to
  information theory.

## Main Results

* `compression_prod_le` — **Sub-additivity**: `κ(M₁ × M₂) ≤ κ(M₁) + κ(M₂)`.
* `compression_le_prod_left` / `compression_le_prod_right` — **Lower bounds**.
* `max_le_compression_prod` — `max(κ M₁, κ M₂) ≤ κ(M₁ × M₂)`.
* `compression_prod_eq_of_independent` — **Conditional additivity**.
* `distinguishabilityCardAt_prod` — **Cross-domain multiplicativity**.
-/

open Finset Fintype Classical

noncomputable section

set_option linter.unusedSectionVars false
set_option linter.unusedVariables false

universe u v

/-! ## Bundled Finite Presheaf Model -/

/-- A **finite presheaf model** bundles a finite type of objects, a family of finite
fibers, and restriction maps between fibers. -/
structure FinitePresheafModel where
  Ob : Type
  instFintypeOb : Fintype Ob
  instDecidableEqOb : DecidableEq Ob
  Fib : Ob → Type
  instFintypeFib : ∀ Y, Fintype (Fib Y)
  instDecidableEqFib : ∀ Y, DecidableEq (Fib Y)
  res : ∀ Y Z, Fib Y → Fib Z

attribute [instance] FinitePresheafModel.instFintypeOb
  FinitePresheafModel.instDecidableEqOb
  FinitePresheafModel.instFintypeFib
  FinitePresheafModel.instDecidableEqFib

/-! ## Basic compression lemmas -/

section BasicCompression

variable {Ob : Type} [Fintype Ob] [DecidableEq Ob]
  {F : Ob → Type} {r : ∀ Y Z, F Y → F Z}

/-- Minimality: compression ≤ card of any separating family. -/
theorem presheafMinCompression_le (P : Finset Ob) (hP : ProbeSeparates F r P) :
    presheafMinCompression' F r ≤ P.card :=
  Nat.sInf_le ⟨P, rfl, hP⟩

/-- Existence: the compression spectrum is nonempty when separable. -/
theorem compressionSpectrum_nonempty
    (hsep : ∃ P : Finset Ob, ProbeSeparates F r P) :
    (compressionSpectrum' F r).Nonempty := by
  obtain ⟨P, hP⟩ := hsep
  exact ⟨P.card, P, rfl, hP⟩

/-- Achievement: the minimum compression is realized. -/
theorem presheafMinCompression_achieved
    (hsep : ∃ P : Finset Ob, ProbeSeparates F r P) :
    ∃ P : Finset Ob, P.card = presheafMinCompression' F r ∧
      ProbeSeparates F r P :=
  Nat.sInf_mem (compressionSpectrum_nonempty hsep)

end BasicCompression

/-- The **probe-separability** condition for a bundled model. -/
def FinitePresheafModel.IsSeparable (M : FinitePresheafModel) : Prop :=
  ∃ P : Finset M.Ob, ProbeSeparates M.Fib M.res P

/-- **Compression complexity** of a finite presheaf model. -/
def compressionComplexity (M : FinitePresheafModel) : ℕ :=
  presheafMinCompression' M.Fib M.res

-- Local notation for readability
local notation "κ" => compressionComplexity

/-! ## Product Model -/

/-- The **product** of two finite presheaf models. Objects are pairs,
fibers are product fibers, and restriction acts componentwise. -/
def FinitePresheafModel.prod (M₁ M₂ : FinitePresheafModel) : FinitePresheafModel where
  Ob := M₁.Ob × M₂.Ob
  instFintypeOb := instFintypeProd M₁.Ob M₂.Ob
  instDecidableEqOb := instDecidableEqProd
  Fib := fun p => M₁.Fib p.1 × M₂.Fib p.2
  instFintypeFib := fun p => instFintypeProd (M₁.Fib p.1) (M₂.Fib p.2)
  instDecidableEqFib := fun p => instDecidableEqProd
  res := fun Y Z s => (M₁.res Y.1 Z.1 s.1, M₂.res Y.2 Z.2 s.2)

@[simp]
theorem FinitePresheafModel.prod_res (M₁ M₂ : FinitePresheafModel)
    (Y Z : M₁.Ob × M₂.Ob) (s : M₁.Fib Y.1 × M₂.Fib Y.2) :
    (FinitePresheafModel.prod M₁ M₂).res Y Z s =
    (M₁.res Y.1 Z.1 s.1, M₂.res Y.2 Z.2 s.2) := rfl

/-! ## Probe Family Constructions for Products -/

/-- Given probe families `P₁` on `M₁.Ob` and `P₂` on `M₂.Ob`, and basepoints
`b₁ ∈ M₁.Ob` and `b₂ ∈ M₂.Ob`, construct a probe family on the product model. -/
def prodProbeFamily {M₁ M₂ : FinitePresheafModel}
    (P₁ : Finset M₁.Ob) (P₂ : Finset M₂.Ob)
    (b₁ : M₁.Ob) (b₂ : M₂.Ob) : Finset (M₁.Ob × M₂.Ob) :=
  (P₁.map ⟨fun z₁ => (z₁, b₂), fun a b h => by simpa using h⟩) ∪
  (P₂.map ⟨fun z₂ => (b₁, z₂), fun a b h => by simpa using h⟩)

/-
The product probe family has cardinality at most `|P₁| + |P₂|`.
-/
theorem prodProbeFamily_card_le {M₁ M₂ : FinitePresheafModel}
    (P₁ : Finset M₁.Ob) (P₂ : Finset M₂.Ob)
    (b₁ : M₁.Ob) (b₂ : M₂.Ob) :
    (prodProbeFamily P₁ P₂ b₁ b₂).card ≤ P₁.card + P₂.card := by
  exact le_trans ( Finset.card_union_le _ _ ) ( add_le_add ( by simp +decide [ Finset.card_map ] ) ( by simp +decide [ Finset.card_map ] ) )

/-
The product probe family separates the product model.
-/
theorem prodProbeFamily_separates {M₁ M₂ : FinitePresheafModel}
    (P₁ : Finset M₁.Ob) (P₂ : Finset M₂.Ob)
    (b₁ : M₁.Ob) (b₂ : M₂.Ob)
    (hP₁ : ProbeSeparates M₁.Fib M₁.res P₁)
    (hP₂ : ProbeSeparates M₂.Fib M₂.res P₂) :
    ProbeSeparates (FinitePresheafModel.prod M₁ M₂).Fib
      (FinitePresheafModel.prod M₁ M₂).res
      (prodProbeFamily P₁ P₂ b₁ b₂) := by
  intro Y s t h; have := hP₁ Y.1; have := hP₂ Y.2; simp_all +decide [ Prod.ext_iff, ProbeSeparates ] ;
  have h₁ : ∀ Z₁ ∈ P₁, M₁.res Y.1 Z₁ s.1 = M₁.res Y.1 Z₁ t.1 := by
    intro Z₁ hZ₁; have := congr_fun h ⟨ ( Z₁, b₂ ), by
      exact Finset.mem_union_left _ ( Finset.mem_map.mpr ⟨ Z₁, hZ₁, rfl ⟩ ) ⟩ ; simp_all +decide [ probeSignature' ] ;
    injection this
  have h₂ : ∀ Z₂ ∈ P₂, M₂.res Y.2 Z₂ s.2 = M₂.res Y.2 Z₂ t.2 := by
    intro Z₂ hZ₂; have := congr_arg ( fun f => f ⟨ ( b₁, Z₂ ), by exact Finset.mem_union_right _ ( Finset.mem_map_of_mem _ hZ₂ ) ⟩ ) h; simp +decide [ probeSignature' ] at this;
    exact congr_arg Prod.snd this;
  exact Prod.ext ( hP₁ Y.1 ( funext fun Z => h₁ Z.1 Z.2 ) ) ( hP₂ Y.2 ( funext fun Z => h₂ Z.1 Z.2 ) )

/-! ## Sub-Additivity (Theorem 1) -/

/-- **Sub-additivity of compression complexity.**
`κ(M₁ × M₂) ≤ κ(M₁) + κ(M₂)`.

*Proof:* Construct a product probe family from optimal families for each factor. -/
theorem compression_prod_le
    (M₁ M₂ : FinitePresheafModel)
    (h₁ : M₁.IsSeparable) (h₂ : M₂.IsSeparable)
    [Nonempty M₁.Ob] [Nonempty M₂.Ob] :
    κ (FinitePresheafModel.prod M₁ M₂) ≤ κ M₁ + κ M₂ := by
  obtain ⟨P₁, hcard₁, hP₁⟩ := presheafMinCompression_achieved h₁
  obtain ⟨P₂, hcard₂, hP₂⟩ := presheafMinCompression_achieved h₂
  set b₁ := Classical.arbitrary M₁.Ob
  set b₂ := Classical.arbitrary M₂.Ob
  calc κ (FinitePresheafModel.prod M₁ M₂)
      ≤ (prodProbeFamily P₁ P₂ b₁ b₂).card :=
        presheafMinCompression_le _ (prodProbeFamily_separates P₁ P₂ b₁ b₂ hP₁ hP₂)
    _ ≤ P₁.card + P₂.card := prodProbeFamily_card_le P₁ P₂ b₁ b₂
    _ = κ M₁ + κ M₂ := by unfold compressionComplexity; rw [hcard₁, hcard₂]

/-! ## Lower Bounds (Theorem 3) -/

/-- Project a product probe family to M₁ objects. -/
def sliceProbeFamily {M₁ M₂ : FinitePresheafModel}
    (P : Finset (M₁.Ob × M₂.Ob)) : Finset M₁.Ob :=
  P.image Prod.fst

/-- The slice probe family has cardinality at most that of the original. -/
theorem sliceProbeFamily_card_le {M₁ M₂ : FinitePresheafModel}
    (P : Finset (M₁.Ob × M₂.Ob)) :
    (sliceProbeFamily P : Finset M₁.Ob).card ≤ P.card :=
  Finset.card_image_le

/-
If P separates the product model, then its first projection separates M₁.
Fix a basepoint s₂ in the second factor and embed M₁ into the product via
x ↦ (x, s₂). Any separating family on the product then induces separation
on the first factor through projection.
-/
theorem sliceProbeFamily_separates_left {M₁ M₂ : FinitePresheafModel}
    (P : Finset (M₁.Ob × M₂.Ob))
    (hP : ProbeSeparates (FinitePresheafModel.prod M₁ M₂).Fib
      (FinitePresheafModel.prod M₁ M₂).res P)
    (b₂ : M₂.Ob) (s₂ : M₂.Fib b₂) :
    ProbeSeparates M₁.Fib M₁.res (sliceProbeFamily P) := by
  intro Y₁ s₁ t₁ h_eq;
  convert congr_arg Prod.fst ( hP ( Y₁, b₂ ) ( show probeSignature' ( M₁.prod M₂ ).Fib ( M₁.prod M₂ ).res P ( Y₁, b₂ ) ( s₁, s₂ ) = probeSignature' ( M₁.prod M₂ ).Fib ( M₁.prod M₂ ).res P ( Y₁, b₂ ) ( t₁, s₂ ) from ?_ ) ) using 1;
  ext ⟨ Z, hZ ⟩ ; simp_all +decide [ funext_iff, probeSignature' ] ;
  exact Prod.ext ( h_eq _ <| Finset.mem_image_of_mem _ hZ ) rfl

/-
**Left factor lower bound.**
-/
theorem compression_le_prod_left
    (M₁ M₂ : FinitePresheafModel)
    (h : (FinitePresheafModel.prod M₁ M₂).IsSeparable)
    [Nonempty M₂.Ob] [∀ Y, Nonempty (M₂.Fib Y)] :
    κ M₁ ≤ κ (FinitePresheafModel.prod M₁ M₂) := by
  obtain ⟨P, hP⟩ := h
  have b₂ := Classical.arbitrary M₂.Ob
  have s₂ := Classical.arbitrary (M₂.Fib b₂)
  have := @sliceProbeFamily_separates_left;
  obtain ⟨ Q, hQ₁, hQ₂ ⟩ := presheafMinCompression_achieved ( by
    use P : ∃ P : Finset ( M₁.Ob × M₂.Ob ), ProbeSeparates ( M₁.prod M₂ ).Fib ( M₁.prod M₂ ).res P )
  generalize_proofs at *;
  exact le_trans ( presheafMinCompression_le _ ( this _ hQ₂ b₂ s₂ ) ) ( by linarith! [ sliceProbeFamily_card_le Q ] )

/-- Project a product probe family to M₂ objects. -/
def sliceProbeFamilyRight {M₁ M₂ : FinitePresheafModel}
    (P : Finset (M₁.Ob × M₂.Ob)) : Finset M₂.Ob :=
  P.image Prod.snd

/-
If P separates the product model, then its second projection separates M₂.
-/
theorem sliceProbeFamily_separates_right {M₁ M₂ : FinitePresheafModel}
    (P : Finset (M₁.Ob × M₂.Ob))
    (hP : ProbeSeparates (FinitePresheafModel.prod M₁ M₂).Fib
      (FinitePresheafModel.prod M₁ M₂).res P)
    (b₁ : M₁.Ob) (s₁ : M₁.Fib b₁) :
    ProbeSeparates M₂.Fib M₂.res (sliceProbeFamilyRight P) := by
  intro Y2 s2 t2 h; have := hP; simp_all +decide [ funext_iff, ProbeSeparates ] ;
  specialize hP ( b₁, Y2 ) ; unfold probeSignature' at hP ; simp_all +decide [ Function.Injective ] ;
  contrapose! hP;
  refine' ⟨ ⟨ s₁, s2 ⟩, ⟨ s₁, t2 ⟩, _, _ ⟩ <;> simp_all +decide [ funext_iff, ProbeSeparates ];
  · intro a ha; specialize h a.2 ( Finset.mem_image_of_mem _ ha ) ; unfold probeSignature' at h; aesop;
  · grind

/-
**Right factor lower bound.**
-/
theorem compression_le_prod_right
    (M₁ M₂ : FinitePresheafModel)
    (h : (FinitePresheafModel.prod M₁ M₂).IsSeparable)
    [Nonempty M₁.Ob] [∀ Y, Nonempty (M₁.Fib Y)] :
    κ M₂ ≤ κ (FinitePresheafModel.prod M₁ M₂) := by
  obtain ⟨ P, hP ⟩ := h;
  -- Since P separates M₁ × M₂, its second projection separates M₂.
  have h_second_proj : ProbeSeparates M₂.Fib M₂.res (sliceProbeFamilyRight P) := by
    convert sliceProbeFamily_separates_right P hP ( Classical.arbitrary M₁.Ob ) ( Classical.choice ( ‹∀ Y : M₁.Ob, Nonempty ( M₁.Fib Y ) › ( Classical.arbitrary M₁.Ob ) ) ) using 1;
  have h_card_le : (sliceProbeFamilyRight P : Finset M₂.Ob).card ≤ P.card := by
    exact Finset.card_image_le;
  have := presheafMinCompression_achieved ( show ∃ P : Finset ( M₁.prod M₂ ).Ob, ProbeSeparates ( M₁.prod M₂ ).Fib ( M₁.prod M₂ ).res P from ⟨ P, hP ⟩ );
  obtain ⟨ Q, hQ₁, hQ₂ ⟩ := this;
  have h_card_le_Q : (sliceProbeFamilyRight Q : Finset M₂.Ob).card ≤ Q.card := by
    exact Finset.card_image_le;
  exact le_trans ( presheafMinCompression_le _ ( sliceProbeFamily_separates_right _ hQ₂ ( Classical.arbitrary _ ) ( Classical.arbitrary _ ) ) ) ( by linarith! )

/-
**Combined lower bound.**
`max(κ M₁, κ M₂) ≤ κ(M₁ × M₂)`.
-/
theorem max_le_compression_prod
    (M₁ M₂ : FinitePresheafModel)
    (h : (FinitePresheafModel.prod M₁ M₂).IsSeparable)
    [Nonempty M₁.Ob] [Nonempty M₂.Ob]
    [∀ Y, Nonempty (M₁.Fib Y)] [∀ Y, Nonempty (M₂.Fib Y)] :
    max (κ M₁) (κ M₂) ≤ κ (FinitePresheafModel.prod M₁ M₂) := by
  exact max_le ( compression_le_prod_left M₁ M₂ h ) ( compression_le_prod_right M₁ M₂ h )

/-! ## Conditional Additivity (Theorem 2) -/

/-- Two models are **probe-independent** if every separating family on the product
has size at least `κ(M₁) + κ(M₂)`. -/
def ProbeIndependent (M₁ M₂ : FinitePresheafModel) : Prop :=
  ∀ (P : Finset (M₁.Ob × M₂.Ob)),
    ProbeSeparates (FinitePresheafModel.prod M₁ M₂).Fib
      (FinitePresheafModel.prod M₁ M₂).res P →
    κ M₁ + κ M₂ ≤ P.card

/-
**Conditional additivity.**
Under probe independence, `κ(M₁ × M₂) = κ(M₁) + κ(M₂)`.
-/
theorem compression_prod_eq_of_independent
    (M₁ M₂ : FinitePresheafModel)
    (h₁ : M₁.IsSeparable) (h₂ : M₂.IsSeparable)
    [Nonempty M₁.Ob] [Nonempty M₂.Ob]
    (hind : ProbeIndependent M₁ M₂) :
    κ (FinitePresheafModel.prod M₁ M₂) = κ M₁ + κ M₂ := by
  refine' le_antisymm ( compression_prod_le M₁ M₂ h₁ h₂ ) _;
  obtain ⟨ P, hP₁, hP₂ ⟩ := presheafMinCompression_achieved ( show ∃ P : Finset ( M₁.Ob × M₂.Ob ), ProbeSeparates ( M₁.prod M₂ ).Fib ( M₁.prod M₂ ).res P from by
                                                                obtain ⟨ P₁, hP₁ ⟩ := h₁
                                                                obtain ⟨ P₂, hP₂ ⟩ := h₂;
                                                                exact ⟨ _, prodProbeFamily_separates P₁ P₂ ( Classical.arbitrary _ ) ( Classical.arbitrary _ ) hP₁ hP₂ ⟩ );
  exact le_of_le_of_eq (hind P hP₂) hP₁

/-! ## Cross-Domain: Distinguishability (Theorem 4) -/

/-- Two sections are **probe-indistinguishable** if all restrictions agree. -/
def probeIndistinguishable (M : FinitePresheafModel) (Y : M.Ob) (s t : M.Fib Y) : Prop :=
  ∀ Z : M.Ob, M.res Y Z s = M.res Y Z t

/-- Probe indistinguishability is an equivalence relation. -/
theorem probeIndistinguishable_equivalence (M : FinitePresheafModel) (Y : M.Ob) :
    Equivalence (probeIndistinguishable M Y) where
  refl := fun _ _ => rfl
  symm := fun h Z => (h Z).symm
  trans := fun h₁ h₂ Z => (h₁ Z).trans (h₂ Z)

/-- The setoid of probe indistinguishability at object Y. -/
def probeSetoid (M : FinitePresheafModel) (Y : M.Ob) : Setoid (M.Fib Y) :=
  ⟨probeIndistinguishable M Y, probeIndistinguishable_equivalence M Y⟩

instance probeSetoid_decidableRel (M : FinitePresheafModel) (Y : M.Ob) :
    DecidableRel (probeSetoid M Y).r := by
  intro s t
  simp only [probeSetoid, probeIndistinguishable]
  exact Fintype.decidableForallFintype

/-- The **distinguishability cardinality** at an object Y. -/
noncomputable def distinguishabilityCardAt (M : FinitePresheafModel) (Y : M.Ob) : ℕ :=
  Fintype.card (Quotient (probeSetoid M Y))

/-
Two sections in the product are probe-indistinguishable iff
they are indistinguishable in each component.
-/
theorem probeIndistinguishable_prod_iff (M₁ M₂ : FinitePresheafModel)
    (Y : M₁.Ob × M₂.Ob)
    (s t : M₁.Fib Y.1 × M₂.Fib Y.2) :
    probeIndistinguishable (FinitePresheafModel.prod M₁ M₂) Y s t ↔
    (probeIndistinguishable M₁ Y.1 s.1 t.1 ∧ probeIndistinguishable M₂ Y.2 s.2 t.2) := by
  exact ⟨ fun h => ⟨ fun Z => congr_arg Prod.fst ( h ( Z, Y.2 ) ), fun Z => congr_arg Prod.snd ( h ( Y.1, Z ) ) ⟩, fun h Z => Prod.ext ( h.1 Z.1 ) ( h.2 Z.2 ) ⟩

/-
**Multiplicativity of distinguishability.**
The distinguishability cardinality at a product object equals the product of
the individual distinguishability cardinalities.

Cross-domain bridge: presheaf compression ↔ zero-error information theory.
-/
theorem distinguishabilityCardAt_prod (M₁ M₂ : FinitePresheafModel)
    (Y₁ : M₁.Ob) (Y₂ : M₂.Ob) :
    distinguishabilityCardAt (FinitePresheafModel.prod M₁ M₂) (Y₁, Y₂) =
    distinguishabilityCardAt M₁ Y₁ * distinguishabilityCardAt M₂ Y₂ := by
  have h_bij : Quotient (probeSetoid (M₁.prod M₂) (Y₁, Y₂)) ≃ Quotient (probeSetoid M₁ Y₁) × Quotient (probeSetoid M₂ Y₂) := by
    refine' Equiv.ofBijective ( fun x => Quotient.liftOn' x ( fun s => ( Quotient.mk'' s.1, Quotient.mk'' s.2 ) ) _ ) ⟨ fun x y h => _, fun x => _ ⟩;
    all_goals norm_num [ Quotient.eq ] at *;
    exact fun a b h => by simpa using probeIndistinguishable_prod_iff M₁ M₂ ( Y₁, Y₂ ) a b |>.1 h;
    · obtain ⟨ a, rfl ⟩ := Quotient.exists_rep x; obtain ⟨ b, rfl ⟩ := Quotient.exists_rep y; simp_all +decide [ Quotient.liftOn' ] ;
      exact Quotient.sound ( probeIndistinguishable_prod_iff M₁ M₂ ( Y₁, Y₂ ) a b |>.2 ⟨ Quotient.exact h.1, Quotient.exact h.2 ⟩ );
    · rcases x with ⟨ x₁, x₂ ⟩ ; rcases Quotient.exists_rep x₁ with ⟨ s₁, rfl ⟩ ; rcases Quotient.exists_rep x₂ with ⟨ s₂, rfl ⟩ ; exact ⟨ Quotient.mk'' ( s₁, s₂ ), rfl ⟩ ;
  convert Fintype.card_congr h_bij using 1;
  simp +decide [ distinguishabilityCardAt ]

/-! ## Compression Defect -/

/-- The **compression defect** measures the failure of exact additivity. -/
def compressionDefect (M₁ M₂ : FinitePresheafModel) : ℕ :=
  κ M₁ + κ M₂ - κ (FinitePresheafModel.prod M₁ M₂)

/-
Sub-additivity implies `κ(M₁ × M₂) + defect = κ(M₁) + κ(M₂)`.
-/
theorem compressionDefect_eq
    (M₁ M₂ : FinitePresheafModel)
    (h₁ : M₁.IsSeparable) (h₂ : M₂.IsSeparable)
    [Nonempty M₁.Ob] [Nonempty M₂.Ob] :
    κ (FinitePresheafModel.prod M₁ M₂) + compressionDefect M₁ M₂ = κ M₁ + κ M₂ := by
  exact Nat.add_sub_of_le ( compression_prod_le M₁ M₂ h₁ h₂ )

end