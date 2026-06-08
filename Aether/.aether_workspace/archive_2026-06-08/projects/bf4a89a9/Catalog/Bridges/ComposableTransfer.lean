/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Composable Theorem Transfer: A Calculus of Transportable Guarantees

This file establishes the foundational infrastructure for **compositional
transfer of certified properties** across chains of theory morphisms.
The key insight is that proof-bearing predicates propagate functorially
through `TheoryHom` composition, turning isolated correspondences into
a reusable calculus of cross-domain theorem transport.

## Main definitions

* `PreservesProperty` — a theory morphism preserves `P ⇒ Q` if
  `∀ x, P x → Q (φ.toFun x)`
* `CertifiedTransfer` — bundles a morphism with its preservation witness

## Main results

* `TheoryHom.preserves_comp` — composition of morphisms preserves
  composed predicates: if φ preserves P⇒Q and ψ preserves Q⇒R,
  then φ;ψ preserves P⇒R
* `TheoryHom.transport_theorem_comp` — the `Set.MapsTo` variant:
  composed morphisms map certified source sets into certified target sets
* `CertifiedTransfer.comp` — bundled composition of certified transfers
* Concrete instantiations with the catalog theories (Height, Cell,
  Dimension, Stability, Capacity)

## Design philosophy

This file elevates the theory morphism framework from a collection of
isolated bridges into a **calculus of transportable guarantees**. Once a
property is certified in one domain, it can be exported, composed, and
reinterpreted in another without reproving from scratch. This is the
formal seed of a "science of scientific analogy."
-/

import Mathlib
import Bridges.TheoryMorphisms

open Set Function

/-! ## §1. Predicate Preservation -/

/-- A theory morphism `φ : TheoryHom T₁ T₂` **preserves** predicate `P` to `Q`
    if every object satisfying `P` maps to an object satisfying `Q`. -/
def PreservesProperty {T₁ T₂ : ResearchTheory}
    (φ : TheoryHom T₁ T₂) (P : T₁.Carrier → Prop) (Q : T₂.Carrier → Prop) : Prop :=
  ∀ x, P x → Q (φ.toFun x)

/-! ## §2. The Composition Theorem -/

/-- **Compositional predicate transport**: if `φ` preserves `P ⇒ Q` and
    `ψ` preserves `Q ⇒ R`, then their composition preserves `P ⇒ R`.

    This is the central theorem: certified properties propagate functorially
    through chains of theory morphisms. -/
theorem TheoryHom.preserves_comp
    {T₁ T₂ T₃ : ResearchTheory}
    (φ : TheoryHom T₁ T₂)
    (ψ : TheoryHom T₂ T₃)
    (P : T₁.Carrier → Prop)
    (Q : T₂.Carrier → Prop)
    (R : T₃.Carrier → Prop)
    (hφ : PreservesProperty φ P Q)
    (hψ : PreservesProperty ψ Q R) :
    PreservesProperty (TheoryHom.comp φ ψ) P R :=
  fun x hPx => hψ (φ.toFun x) (hφ x hPx)

/-- **Set-theoretic transport composition**: composed morphisms map
    certified source sets into certified target sets.

    This `MapsTo` formulation is often more convenient for instantiation
    with concrete certified regions, margins, languages, or spectral classes. -/
theorem TheoryHom.transport_theorem_comp
    {T₁ T₂ T₃ : ResearchTheory}
    (φ : TheoryHom T₁ T₂)
    (ψ : TheoryHom T₂ T₃)
    (S₁ : Set T₁.Carrier)
    (S₂ : Set T₂.Carrier)
    (S₃ : Set T₃.Carrier)
    (hφ : MapsTo φ.toFun S₁ S₂)
    (hψ : MapsTo ψ.toFun S₂ S₃) :
    MapsTo (TheoryHom.comp φ ψ).toFun S₁ S₃ :=
  fun _ hx => hψ (hφ hx)

/-- The identity morphism preserves any predicate to itself. -/
theorem TheoryHom.preserves_id
    {T : ResearchTheory}
    (P : T.Carrier → Prop) :
    PreservesProperty (TheoryHom.id T) P P :=
  fun _ hx => hx

/-- Preservation is contravariant in the source predicate:
    if φ preserves P ⇒ Q and P' implies P, then φ preserves P' ⇒ Q. -/
theorem PreservesProperty.weaken_source
    {T₁ T₂ : ResearchTheory}
    {φ : TheoryHom T₁ T₂}
    {P P' : T₁.Carrier → Prop}
    {Q : T₂.Carrier → Prop}
    (h : PreservesProperty φ P Q)
    (hP : ∀ x, P' x → P x) :
    PreservesProperty φ P' Q :=
  fun x hx => h x (hP x hx)

/-- Preservation is covariant in the target predicate:
    if φ preserves P ⇒ Q and Q implies Q', then φ preserves P ⇒ Q'. -/
theorem PreservesProperty.strengthen_target
    {T₁ T₂ : ResearchTheory}
    {φ : TheoryHom T₁ T₂}
    {P : T₁.Carrier → Prop}
    {Q Q' : T₂.Carrier → Prop}
    (h : PreservesProperty φ P Q)
    (hQ : ∀ y, Q y → Q' y) :
    PreservesProperty φ P Q' :=
  fun x hx => hQ _ (h x hx)

/-! ## §3. Bundled Certified Transfer -/

/-- A **certified transfer** bundles a theory morphism with its
    predicate preservation witness. This is the fundamental unit
    of composable theorem transport. -/
structure CertifiedTransfer
    (T₁ T₂ : ResearchTheory)
    (P : T₁.Carrier → Prop)
    (Q : T₂.Carrier → Prop) where
  /-- The underlying theory morphism -/
  hom : TheoryHom T₁ T₂
  /-- The preservation certificate -/
  preserves : PreservesProperty hom P Q

/-- **Composition of certified transfers**: the core combinator that
    makes theorem transport reusable. -/
def CertifiedTransfer.comp
    {T₁ T₂ T₃ : ResearchTheory}
    {P : T₁.Carrier → Prop}
    {Q : T₂.Carrier → Prop}
    {R : T₃.Carrier → Prop}
    (ct₁ : CertifiedTransfer T₁ T₂ P Q)
    (ct₂ : CertifiedTransfer T₂ T₃ Q R) :
    CertifiedTransfer T₁ T₃ P R where
  hom := TheoryHom.comp ct₁.hom ct₂.hom
  preserves := TheoryHom.preserves_comp ct₁.hom ct₂.hom P Q R ct₁.preserves ct₂.preserves

/-- The identity certified transfer. -/
def CertifiedTransfer.id
    {T : ResearchTheory}
    {P : T.Carrier → Prop} :
    CertifiedTransfer T T P P where
  hom := TheoryHom.id T
  preserves := TheoryHom.preserves_id P

/-- **Apply a certified transfer**: given a certified object,
    produce a certified object in the target theory. -/
theorem CertifiedTransfer.apply
    {T₁ T₂ : ResearchTheory}
    {P : T₁.Carrier → Prop}
    {Q : T₂.Carrier → Prop}
    (ct : CertifiedTransfer T₁ T₂ P Q)
    (x : T₁.Carrier)
    (hx : P x) :
    Q (ct.hom.toFun x) :=
  ct.preserves x hx

/-! ## §4. Depth-Based Certified Properties -/

/-- An object has **certified depth at least n**. -/
def HasDepthAtLeast (T : ResearchTheory) (n : ℕ) (x : T.Carrier) : Prop :=
  n ≤ T.Inv x

/-- Every theory morphism preserves depth lower bounds.
    This is a canonical instance of predicate preservation. -/
theorem TheoryHom.preserves_depth
    {T₁ T₂ : ResearchTheory}
    (φ : TheoryHom T₁ T₂) (n : ℕ) :
    PreservesProperty φ (HasDepthAtLeast T₁ n) (HasDepthAtLeast T₂ n) :=
  fun x hx => le_trans hx (φ.monotone_inv x)

/-- **Compositional depth transfer**: depth certificates survive
    arbitrary chains of morphisms. Derived from the generic composition
    theorem applied to depth predicates. -/
theorem depth_transfer_comp
    {T₁ T₂ T₃ : ResearchTheory}
    (φ : TheoryHom T₁ T₂)
    (ψ : TheoryHom T₂ T₃)
    (n : ℕ) :
    PreservesProperty (TheoryHom.comp φ ψ) (HasDepthAtLeast T₁ n) (HasDepthAtLeast T₃ n) :=
  TheoryHom.preserves_comp φ ψ _ _ _
    (TheoryHom.preserves_depth φ n)
    (TheoryHom.preserves_depth ψ n)

/-! ## §5. Catalog Instantiations -/

/-- A height value is **arithmetically significant** if it is at least 2. -/
def ArithmeticallySignificant (x : HeightTheory.Carrier) : Prop :=
  2 ≤ HeightTheory.Inv x

/-- A cell parameter has **nontrivial complexity** if its invariant exceeds 2. -/
def NontrivialCellComplexity (x : CellTheory.Carrier) : Prop :=
  2 ≤ CellTheory.Inv x

/-- A stability parameter is **strongly stable** if its invariant exceeds 2. -/
def StronglyStable (x : StabilityTheory.Carrier) : Prop :=
  2 ≤ StabilityTheory.Inv x

/-- The height-to-cell morphism preserves arithmetic significance
    to nontrivial cell complexity. -/
theorem height_to_cell_preserves :
    PreservesProperty heightToCellMorphism
      ArithmeticallySignificant NontrivialCellComplexity := by
  intro x hx
  unfold NontrivialCellComplexity CellTheory heightToCellMorphism ArithmeticallySignificant HeightTheory at *
  simp only [_root_.id] at *
  nlinarith

/-- **Concrete transported property**: combining the catalog bridges
    via compositional transfer. The height→dimension→stability pipeline
    preserves depth-2 certificates. -/
theorem pipeline_preserves_depth2 :
    PreservesProperty heightToStabilityPipeline
      (HasDepthAtLeast HeightTheory 2) (HasDepthAtLeast StabilityTheory 2) :=
  depth_transfer_comp heightToDimension dimensionToStability 2

/-- **Full chain transfer**: height → cell and height → stability
    both preserve depth certificates, demonstrating two independent
    transfer paths from the same source theory. -/
theorem dual_path_transfer (n : ℕ) :
    PreservesProperty heightToCellMorphism
      (HasDepthAtLeast HeightTheory n) (HasDepthAtLeast CellTheory n)
    ∧ PreservesProperty heightToStabilityPipeline
      (HasDepthAtLeast HeightTheory n) (HasDepthAtLeast StabilityTheory n) :=
  ⟨TheoryHom.preserves_depth heightToCellMorphism n,
   depth_transfer_comp heightToDimension dimensionToStability n⟩

/-! ## §6. Transport of Existential Witnesses -/

/-- **Existential transport**: if there exists a certified object in the
    source and we have a certified transfer, then there exists a certified
    object in the target. -/
theorem CertifiedTransfer.transport_exists
    {T₁ T₂ : ResearchTheory}
    {P : T₁.Carrier → Prop}
    {Q : T₂.Carrier → Prop}
    (ct : CertifiedTransfer T₁ T₂ P Q)
    (h : ∃ x, P x) :
    ∃ y, Q y :=
  let ⟨x, hx⟩ := h
  ⟨ct.hom.toFun x, ct.preserves x hx⟩

/-- **Compositional existential transport**: existence witnesses
    survive composed certified transfers. -/
theorem transported_certified_property
    {T₁ T₂ T₃ : ResearchTheory}
    {P : T₁.Carrier → Prop}
    {Q : T₂.Carrier → Prop}
    {R : T₃.Carrier → Prop}
    (φ : TheoryHom T₁ T₂)
    (ψ : TheoryHom T₂ T₃)
    (x : T₁.Carrier)
    (hsource : P x)
    (hφ : ∀ x, P x → Q (φ.toFun x))
    (hψ : ∀ y, Q y → R (ψ.toFun y)) :
    R ((TheoryHom.comp φ ψ).toFun x) :=
  TheoryHom.preserves_comp φ ψ P Q R hφ hψ x hsource

/-- **Concrete instance**: height 5 is arithmetically significant,
    and this certificate transfers through the cell morphism. -/
theorem height5_cell_transfer :
    NontrivialCellComplexity (heightToCellMorphism.toFun (5 : ℕ)) :=
  height_to_cell_preserves (5 : ℕ)
    (show 2 ≤ HeightTheory.Inv (5 : ℕ) by simp [HeightTheory])

/-- **Concrete pipeline instance**: height 3 has depth ≥ 2,
    and this certificate survives the full pipeline. -/
theorem height3_pipeline_transfer :
    HasDepthAtLeast StabilityTheory 2 (heightToStabilityPipeline.toFun (3 : ℕ)) :=
  pipeline_preserves_depth2 (3 : ℕ)
    (show 2 ≤ HeightTheory.Inv (3 : ℕ) by simp [HeightTheory])

/-! ## §7. Predicate Lifting and Pushforward -/

/-- **Pushforward predicate**: given a morphism φ and a source predicate P,
    define the pushforward predicate on the target. -/
def TheoryHom.pushforward
    {T₁ T₂ : ResearchTheory}
    (φ : TheoryHom T₁ T₂)
    (P : T₁.Carrier → Prop) : T₂.Carrier → Prop :=
  fun y => ∃ x, P x ∧ φ.toFun x = y

/-- The pushforward trivially preserves P. -/
theorem TheoryHom.preserves_pushforward
    {T₁ T₂ : ResearchTheory}
    (φ : TheoryHom T₁ T₂)
    (P : T₁.Carrier → Prop) :
    PreservesProperty φ P (φ.pushforward P) :=
  fun x hx => ⟨x, hx, rfl⟩

/-- **Pushforward composition**: the pushforward of a composition
    refines the composition of pushforwards. -/
theorem TheoryHom.pushforward_comp_subset
    {T₁ T₂ T₃ : ResearchTheory}
    (φ : TheoryHom T₁ T₂)
    (ψ : TheoryHom T₂ T₃)
    (P : T₁.Carrier → Prop) :
    ∀ y, (TheoryHom.comp φ ψ).pushforward P y →
         ψ.pushforward (φ.pushforward P) y :=
  fun _ ⟨x, hPx, heq⟩ => ⟨φ.toFun x, ⟨x, hPx, rfl⟩, heq⟩

/-! ## §8. Concrete Three-Theory Chain -/

/-- **Three-theory chain transfer**: a concrete demonstration of
    the full compositional transfer pipeline.

    Height → Dimension → Stability → Capacity

    Each step preserves depth certificates, and the composition
    of all three steps also preserves them. -/
theorem three_theory_chain_transfer (n : ℕ) :
    PreservesProperty
      (TheoryHom.comp heightToStabilityPipeline stabilityToCapacity)
      (HasDepthAtLeast HeightTheory n)
      (HasDepthAtLeast CapacityTheory n) :=
  depth_transfer_comp heightToStabilityPipeline stabilityToCapacity n

/-- **MapsTo variant of three-theory chain**: the certified depth-n
    set in height theory maps into the certified depth-n set in
    capacity theory through the full chain. -/
theorem three_theory_chain_mapsTo (n : ℕ) :
    MapsTo
      (TheoryHom.comp heightToStabilityPipeline stabilityToCapacity).toFun
      {x : HeightTheory.Carrier | HasDepthAtLeast HeightTheory n x}
      {y : CapacityTheory.Carrier | HasDepthAtLeast CapacityTheory n y} :=
  fun _ hx => three_theory_chain_transfer n _ hx

/-! ## §9. Generic Predicate Transport Backup Theorem -/

/-- **Pure predicate transport composition**: for ordinary functions,
    compositional transport of certified predicates holds. This is
    the semantic model underlying all theory morphism transport. -/
theorem predicate_transport_comp
    {α β γ : Type}
    (f : α → β) (g : β → γ)
    (P : α → Prop) (Q : β → Prop) (R : γ → Prop)
    (hf : ∀ x, P x → Q (f x))
    (hg : ∀ y, Q y → R (g y)) :
    ∀ x, P x → R (g (f x)) :=
  fun x hPx => hg (f x) (hf x hPx)

/-- **Set.MapsTo composition backup**: the Set.MapsTo variant
    for plain functions. -/
theorem set_mapsTo_comp
    {α β γ : Type}
    (f : α → β) (g : β → γ)
    (S₁ : Set α) (S₂ : Set β) (S₃ : Set γ)
    (hf : MapsTo f S₁ S₂)
    (hg : MapsTo g S₂ S₃) :
    MapsTo (g ∘ f) S₁ S₃ :=
  hg.comp hf

/-! ## §10. Certified Transfer Chains -/

/-- A **transfer chain** witnesses that a predicate can be transported
    through an arbitrary finite sequence of theories via composition. -/
def transfer_chain_3
    {T₁ T₂ T₃ T₄ : ResearchTheory}
    {P₁ : T₁.Carrier → Prop}
    {P₂ : T₂.Carrier → Prop}
    {P₃ : T₃.Carrier → Prop}
    {P₄ : T₄.Carrier → Prop}
    (ct₁₂ : CertifiedTransfer T₁ T₂ P₁ P₂)
    (ct₂₃ : CertifiedTransfer T₂ T₃ P₂ P₃)
    (ct₃₄ : CertifiedTransfer T₃ T₄ P₃ P₄) :
    CertifiedTransfer T₁ T₄ P₁ P₄ :=
  (ct₁₂.comp ct₂₃).comp ct₃₄

/-- **Associativity of certified transfer composition**:
    (ct₁ ∘ ct₂) ∘ ct₃ has the same underlying function as ct₁ ∘ (ct₂ ∘ ct₃). -/
theorem CertifiedTransfer.comp_assoc
    {T₁ T₂ T₃ T₄ : ResearchTheory}
    {P₁ : T₁.Carrier → Prop}
    {P₂ : T₂.Carrier → Prop}
    {P₃ : T₃.Carrier → Prop}
    {P₄ : T₄.Carrier → Prop}
    (ct₁₂ : CertifiedTransfer T₁ T₂ P₁ P₂)
    (ct₂₃ : CertifiedTransfer T₂ T₃ P₂ P₃)
    (ct₃₄ : CertifiedTransfer T₃ T₄ P₃ P₄) :
    ((ct₁₂.comp ct₂₃).comp ct₃₄).hom.toFun =
      (ct₁₂.comp (ct₂₃.comp ct₃₄)).hom.toFun := by
  rfl

/-- **Concrete four-theory certified chain**: Height → Cell, Cell → Stability
    (via depth), Stability → Capacity. All certified depth-n properties
    transport through the full chain. -/
def four_theory_depth_chain (n : ℕ) :
    CertifiedTransfer HeightTheory CapacityTheory
      (HasDepthAtLeast HeightTheory n) (HasDepthAtLeast CapacityTheory n) :=
  { hom := TheoryHom.comp heightToStabilityPipeline stabilityToCapacity
    preserves := three_theory_chain_transfer n }

#check @TheoryHom.preserves_comp
#check @transported_certified_property
#check @CertifiedTransfer.comp
#check @predicate_transport_comp