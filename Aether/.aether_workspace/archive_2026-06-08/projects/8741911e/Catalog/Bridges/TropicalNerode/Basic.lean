import Mathlib

/-! # Tropical Neural Representation Theory: Core Nerode Theory

This file formalizes the abstract context-action framework and the tropical Myhill–Nerode
equivalence relation. The key results are:

1. `TropicalNerode` is an equivalence relation.
2. `TropicalNerode` is right-invariant under context application.
3. `TropicalNerode` is the **largest** right-invariant, observable-preserving relation.
4. Non-equivalence is witnessed by separating contexts.

## Mathematical Context

The tropical Myhill–Nerode theorem generalizes the classical Myhill–Nerode theorem to
compositional systems evaluated over arbitrary observable spaces. The key insight: contextual
indistinguishability defines the largest right-invariant congruence preserving observables.
-/

noncomputable section

/-! ## Context Action -/

/-- A `ContextAction` models a compositional system where contexts act on traces.
    The axiom `plug_comp` ensures that applying c₁ after c₂ equals applying (comp c₁ c₂). -/
class ContextAction (κ σ : Type*) where
  plug : κ → σ → σ
  comp : κ → κ → κ
  plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x

/-! ## Tropical Nerode Relation -/

/-- The tropical Nerode relation: x ~N y ⟺ ∀ c : κ, Obs(plug c x) = Obs(plug c y). -/
def TropicalNerode {κ σ M : Type*} (plug : κ → σ → σ) (Obs : σ → M) (x y : σ) : Prop :=
  ∀ c : κ, Obs (plug c x) = Obs (plug c y)

/-- Right-invariance: E(x,y) → ∀c, E(plug c x, plug c y). -/
def RightInvariant' {κ σ : Type*} (plug : κ → σ → σ) (E : σ → σ → Prop) : Prop :=
  ∀ ⦃x y⦄, E x y → ∀ c, E (plug c x) (plug c y)

/-- Observable preservation: E(x,y) → Obs(x) = Obs(y). -/
def ObsPreserving {σ M : Type*} (Obs : σ → M) (E : σ → σ → Prop) : Prop :=
  ∀ ⦃x y⦄, E x y → Obs x = Obs y

/-- A context c separates traces x and y. -/
def Separates {κ σ M : Type*} (plug : κ → σ → σ) (Obs : σ → M) (c : κ) (x y : σ) : Prop :=
  Obs (plug c x) ≠ Obs (plug c y)

/-! ## Equivalence Relation Properties -/

namespace TropicalNerode

variable {κ σ M : Type*} (plug : κ → σ → σ) (Obs : σ → M)

theorem refl (x : σ) : TropicalNerode plug Obs x x :=
  fun _ => _root_.rfl

theorem symm {x y : σ} (h : TropicalNerode plug Obs x y) :
    TropicalNerode plug Obs y x :=
  fun c => (h c).symm

theorem trans {x y z : σ} (hxy : TropicalNerode plug Obs x y)
    (hyz : TropicalNerode plug Obs y z) : TropicalNerode plug Obs x z :=
  fun c => (hxy c).trans (hyz c)

theorem equivalence : Equivalence (TropicalNerode plug Obs) :=
  ⟨refl plug Obs, fun h => symm plug Obs h, fun h₁ h₂ => trans plug Obs h₁ h₂⟩

/-- The Nerode setoid. -/
def nerodeSetoid : Setoid σ where
  r := TropicalNerode plug Obs
  iseqv := equivalence plug Obs

/-- Observable preservation from an identity context. -/
theorem obsPreserving_of_id {id_ctx : κ} (h_id : ∀ x, plug id_ctx x = x)
    {x y : σ} (hxy : TropicalNerode plug Obs x y) : Obs x = Obs y := by
  have := hxy id_ctx; rwa [h_id, h_id] at this

/-! ## Right-Invariance -/

/-- The tropical Nerode relation is right-invariant when contexts compose. -/
theorem rightInvariant
    (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x) :
    RightInvariant' plug (TropicalNerode plug Obs) := by
  intro x y hxy c c'
  rw [plug_comp, plug_comp]
  exact hxy (comp c' c)

/-! ## Maximality Theorem -/

/-- **Theorem A (Maximality):** The tropical Nerode relation is the largest relation
    that is both right-invariant and observable-preserving.
    If E(x,y) and E is right-invariant and observable-preserving, then x ~N y. -/
theorem isGreatest
    (E : σ → σ → Prop)
    (hEobs : ObsPreserving Obs E)
    (hEinv : RightInvariant' plug E) :
    ∀ ⦃x y⦄, E x y → TropicalNerode plug Obs x y := by
  intro x y hxy c
  exact hEobs (hEinv hxy c)

/-! ## Separator Certificates -/

/-- **Theorem E (Certified Inequivalence):** ¬(x ~N y) ↔ ∃ c, Separates c x y. -/
theorem not_iff_exists_separator (x y : σ) :
    ¬TropicalNerode plug Obs x y ↔ ∃ c, Separates plug Obs c x y := by
  simp [TropicalNerode, Separates, not_forall]

theorem separator_of_not_equiv {x y : σ}
    (h : ¬TropicalNerode plug Obs x y) :
    ∃ c, Separates plug Obs c x y :=
  (not_iff_exists_separator plug Obs x y).mp h

theorem not_equiv_of_separator {x y : σ} {c : κ}
    (h : Separates plug Obs c x y) :
    ¬TropicalNerode plug Obs x y :=
  (not_iff_exists_separator plug Obs x y).mpr ⟨c, h⟩

/-! ## Quotient Construction -/

/-- The tropical Nerode quotient. -/
abbrev NerodeQuotient := Quotient (nerodeSetoid plug Obs)

/-- The quotient map. -/
def toQuotient (x : σ) : NerodeQuotient plug Obs :=
  Quotient.mk (nerodeSetoid plug Obs) x

/-- Context action descends to the quotient. -/
def quotientPlug (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x)
    (c : κ) : NerodeQuotient plug Obs → NerodeQuotient plug Obs :=
  Quotient.map (plug c) (fun _ _ hxy => rightInvariant plug Obs comp plug_comp hxy c)

theorem quotientPlug_mk (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x)
    (c : κ) (x : σ) :
    quotientPlug plug Obs comp plug_comp c (toQuotient plug Obs x) =
      toQuotient plug Obs (plug c x) :=
  rfl

/-- x ~N y iff their quotient images are equal. -/
theorem iff_quotient_eq (x y : σ) :
    TropicalNerode plug Obs x y ↔
    toQuotient plug Obs x = toQuotient plug Obs y := by
  constructor
  · intro h; exact Quotient.sound h
  · intro h; exact Quotient.exact h

/-- The Nerode relation is a congruence. -/
theorem isCongruence
    (comp : κ → κ → κ)
    (plug_comp : ∀ c₁ c₂ x, plug c₁ (plug c₂ x) = plug (comp c₁ c₂) x) :
    Equivalence (TropicalNerode plug Obs) ∧
    RightInvariant' plug (TropicalNerode plug Obs) :=
  ⟨equivalence plug Obs, rightInvariant plug Obs comp plug_comp⟩

end TropicalNerode

end