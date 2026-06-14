/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib
import Logic.HomotopyTypeTheory
import Speculative.AutoResearch.PathSpaceHLevels

set_option autoImplicit false

/-!
# The Equivalence Calculus: `IsEquiv`, 2-out-of-3, and Univalence-lite Transport

This file *extends* `Speculative.AutoResearch.PathSpaceHLevels` and the catalog's
synthetic homotopy module `Logic.HomotopyTypeTheory` by promoting the *fibrewise*
characterisation of equivalences

    a map is a bijection ⇔ all of its homotopy fibres are contractible
    (`HoTT.bijective_iff_contr_fibers`)

into a first-class predicate `HoTT.IsEquiv f := ∀ b, IsContr (HFiber f b)` together
with its full structural calculus. This realises **Direction 1** (the `IsEquiv`
fibre layer and the 2-out-of-3 law) and **Direction 2** (univalence-lite: transport
of algebraic structure along *abstract* equivalences presented fibrewise) of the
path-spaces program.

The conceptual theme is **duality/representation**: an equivalence is represented
synthetically by the *contractibility of every fibre* (a property of the homotopy
"spectrum" of the map), and this representation is shown to be perfectly dual to the
classical algebraic datum `Function.Bijective`. Every structural law about
equivalences is thereby translated into bijection bookkeeping that Mathlib closes
mechanically — the homotopical side and the set-theoretic side are two faces of one
object.

## Main results

* `HoTT.isEquiv_iff_bijective` — the fibrewise predicate `IsEquiv` coincides with
  `Function.Bijective` (the representation dictionary).
* `HoTT.isEquiv_id`, `HoTT.isEquiv_comp` — `IsEquiv` is reflexive and closed under
  composition.
* `HoTT.isEquiv_of_homotopy` — `IsEquiv` is stable under pointwise homotopy.
* `HoTT.isEquiv_cancel_left`, `HoTT.isEquiv_cancel_right`,
  `HoTT.isEquiv_comp_of_isEquiv` — the **2-out-of-3 law**: from any two of
  `f`, `g`, `g ∘ f` being equivalences the third follows.
* `HoTT.isContr_of_equiv`, `HoTT.isMereProp_of_equiv` — h-levels transport along
  equivalences.
* `HoTT.magma_comm_transport_equiv`, `HoTT.magma_assoc_transport_equiv` —
  **univalence-lite**: commutativity and associativity transport along any magma
  homomorphism whose underlying map is an equivalence (presented fibrewise),
  generalising the catalog's `HoTT.magma_comm_transport` / `magma_assoc_transport`
  from named isomorphisms to abstract equivalences.
-/

-- !-- Lab Notebook -- !--
-- Hypothesis: The fibrewise ↔ `bijective_iff_contr_fibers` should let us define
--   `IsEquiv f := ∀ b, IsContr (HFiber f b)` and derive the entire equivalence
--   calculus (refl, comp, homotopy-stability, 2-out-of-3) purely as corollaries of
--   `Function.Bijective` bookkeeping, and to transport algebraic structure along
--   abstract equivalences by feeding the bijection into the catalog's named-iso
--   transport lemmas.
-- Result: All target theorems proved with `sorry = 0`. The 2-out-of-3 law holds
--   verbatim for `IsContr`-fibre equivalences with NO extra coherence condition —
--   answering the falsifiable question of Direction 1 in the affirmative — because
--   in `Type` an equivalence is exactly a bijection and bijections satisfy
--   2-out-of-3 on the nose.
-- Insight: `IsEquiv` is a *representation* of bijectivity: contractibility of all
--   fibres (a homotopy-spectral datum) is dual to the algebraic datum
--   `Function.Bijective`. Once the dictionary `isEquiv_iff_bijective` is in place,
--   the homotopical questions become finite assemblies over `Function.Bijective.comp`
--   and `Function.Injective`/`Surjective` cancellation — exactly as conjectured.
-- Failure analysis: The only subtlety is the *direction* of the cancellation laws:
--   `cancel_left` (knowing `g` and `g∘f`) recovers `f` and needs `g` injective for
--   surjectivity of `f`; `cancel_right` (knowing `f` and `g∘f`) recovers `g` and
--   needs `f` surjective for injectivity of `g`. Both inputs are supplied by the
--   ambient equivalences, so no coherence hypothesis is required.

noncomputable section

namespace HoTT

universe u v w

/-! ## The fibrewise equivalence predicate -/

-- !-- A map is an equivalence iff every homotopy fibre is contractible; this is the
-- synthetic (homotopy-spectral) representation of `Function.Bijective`. -- !--
/-- A map is an **equivalence** when all of its homotopy fibres are contractible.
This is the HoTT-native definition of a type equivalence. -/
def IsEquiv {A : Type u} {B : Type v} (f : A → B) : Prop :=
  ∀ b, IsContr (HFiber f b)

-- !-- The representation dictionary: it is exactly `bijective_iff_contr_fibers`
-- read backwards. -- !--
/-- **Representation dictionary.** The fibrewise predicate `IsEquiv` is exactly
`Function.Bijective`. -/
theorem isEquiv_iff_bijective {A : Type u} {B : Type v} (f : A → B) :
    IsEquiv f ↔ Function.Bijective f :=
  (bijective_iff_contr_fibers f).symm

/-- An equivalence is bijective. -/
theorem IsEquiv.bijective {A : Type u} {B : Type v} {f : A → B} (h : IsEquiv f) :
    Function.Bijective f :=
  (isEquiv_iff_bijective f).mp h

/-- A bijection is an equivalence. -/
theorem IsEquiv.of_bijective {A : Type u} {B : Type v} {f : A → B}
    (h : Function.Bijective f) : IsEquiv f :=
  (isEquiv_iff_bijective f).mpr h

/-! ## Reflexivity, composition, homotopy-stability -/

-- !-- `id` is bijective, then transport across the dictionary. -- !--
/-- The identity map is an equivalence. -/
theorem isEquiv_id {A : Type u} : IsEquiv (id : A → A) :=
  IsEquiv.of_bijective Function.bijective_id

-- !-- Compose the two underlying bijections via `Function.Bijective.comp`. -- !--
/-- Equivalences are closed under composition. -/
theorem isEquiv_comp {A : Type u} {B : Type v} {C : Type w}
    {f : A → B} {g : B → C} (hf : IsEquiv f) (hg : IsEquiv g) :
    IsEquiv (g ∘ f) :=
  IsEquiv.of_bijective (hg.bijective.comp hf.bijective)

-- !-- Rewrite `g` to `f` via `funext` of the pointwise homotopy; `IsEquiv f`
-- closes the goal. -- !--
/-- Equivalence is stable under pointwise homotopy. -/
theorem isEquiv_of_homotopy {A : Type u} {B : Type v} {f g : A → B}
    (h : ∀ a, f a = g a) (hf : IsEquiv f) : IsEquiv g := by
  rw [show g = f from funext fun x => (h x).symm]; exact hf

/-! ## The 2-out-of-3 law -/

-- !-- Restatement of `isEquiv_comp` to complete the 2-out-of-3 triangle. -- !--
/-- **2-out-of-3, first leg.** If `f` and `g` are equivalences, so is `g ∘ f`. -/
theorem isEquiv_comp_of_isEquiv {A : Type u} {B : Type v} {C : Type w}
    {f : A → B} {g : B → C} (hf : IsEquiv f) (hg : IsEquiv g) :
    IsEquiv (g ∘ f) :=
  isEquiv_comp hf hg

-- !-- From `g`, `g∘f` bijective: `f` injective since `g∘f` is; `f` surjective since
-- `g∘f` is surjective and `g` is injective (`hg.1 ha` cancels the outer `g`). -- !--
/-- **2-out-of-3, second leg.** If `g` and `g ∘ f` are equivalences, so is `f`. -/
theorem isEquiv_cancel_left {A : Type u} {B : Type v} {C : Type w}
    {f : A → B} {g : B → C} (hg : IsEquiv g) (hgf : IsEquiv (g ∘ f)) :
    IsEquiv f := by
  have hg' := hg.bijective
  have hgf' := hgf.bijective
  refine IsEquiv.of_bijective ⟨fun a a' haa' => hgf'.1 (congrArg g haa'), fun b => ?_⟩
  obtain ⟨a, ha⟩ := hgf'.2 (g b)
  exact ⟨a, hg'.1 ha⟩

-- !-- From `f`, `g∘f` bijective: `g` surjective since `g∘f` is; `g` injective by
-- pulling both inputs back along surjective `f` and cancelling with `g∘f`. -- !--
/-- **2-out-of-3, third leg.** If `f` and `g ∘ f` are equivalences, so is `g`. -/
theorem isEquiv_cancel_right {A : Type u} {B : Type v} {C : Type w}
    {f : A → B} {g : B → C} (hf : IsEquiv f) (hgf : IsEquiv (g ∘ f)) :
    IsEquiv g := by
  have hf' := hf.bijective
  have hgf' := hgf.bijective
  refine IsEquiv.of_bijective ⟨fun b b' hbb' => ?_, fun c => ?_⟩
  · obtain ⟨a, rfl⟩ := hf'.2 b
    obtain ⟨a', rfl⟩ := hf'.2 b'
    exact congrArg f (hgf'.1 hbb')
  · obtain ⟨a, ha⟩ := hgf'.2 c
    exact ⟨f a, ha⟩

/-! ## Transport of h-levels along equivalences -/

-- !-- `e` and `e.symm` form a retraction, so `isContr_retract` carries the centre
-- of `A` to a centre of `B`. -- !--
/-- Contractibility transports along an equivalence. -/
theorem isContr_of_equiv {A : Type u} {B : Type v} (e : A ≃ B)
    (hA : IsContr A) : IsContr B :=
  isContr_retract e e.symm e.apply_symm_apply hA

-- !-- Pull two points of `B` back along `e.symm`, equate them by `hA`, then push
-- the equality forward with `congrArg e` and `e.apply_symm_apply`. -- !--
/-- Being a mere proposition transports along an equivalence. -/
theorem isMereProp_of_equiv {A : Type u} {B : Type v} (e : A ≃ B)
    (hA : IsMereProp A) : IsMereProp B := fun x y => by
  rw [← e.apply_symm_apply x, ← e.apply_symm_apply y, hA (e.symm x) (e.symm y)]

/-! ## Univalence-lite: structure transport along fibrewise equivalences -/

-- !-- Repackage `φ` as a `MagmaIso` via `hφ.bijective`, then invoke the catalog's
-- `magma_comm_transport`. -- !--
/-- **Univalence-lite (commutativity).** If `φ : M → N` is a magma homomorphism
whose underlying map is an equivalence (presented fibrewise) and `M` is
commutative, then `N` is commutative. Generalises `HoTT.magma_comm_transport`
from named isomorphisms to abstract equivalences. -/
theorem magma_comm_transport_equiv {M N : Magma} (φ : MagmaHom M N)
    (hφ : IsEquiv φ.toFun)
    (hcomm : ∀ (a b : M.Carrier), M.op a b = M.op b a) :
    ∀ (x y : N.Carrier), N.op x y = N.op y x :=
  magma_comm_transport ⟨φ, hφ.bijective⟩ hcomm

-- !-- Same repackaging into a `MagmaIso`, then `magma_assoc_transport`. -- !--
/-- **Univalence-lite (associativity).** Associativity transports along any magma
homomorphism whose underlying map is an equivalence. Generalises
`HoTT.magma_assoc_transport`. -/
theorem magma_assoc_transport_equiv {M N : Magma} (φ : MagmaHom M N)
    (hφ : IsEquiv φ.toFun)
    (hassoc : ∀ (a b c : M.Carrier), M.op (M.op a b) c = M.op a (M.op b c)) :
    ∀ (x y z : N.Carrier), N.op (N.op x y) z = N.op x (N.op y z) :=
  magma_assoc_transport ⟨φ, hφ.bijective⟩ hassoc

end HoTT

end