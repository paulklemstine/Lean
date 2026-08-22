/-
# The Modal Theory of Clock-and-Switch Worlds

This file is the logic-side payoff of the combinatorial representation theorem in
`Combinatorics.CWorldFiltration`.  It connects that theorem to the catalog's Kripke
semantics (`TangledSoundness.KFrame`, `TangledSoundness.sat`, `GLPLogic.MFormula`).

## Main results

* `sat_bddMorphism` — the **p-morphism lemma** for the catalog's satisfaction relation:
  a bounded morphism `f : X → Y` of preorders satisfies
  `sat (orderFrame X) (V ∘ f) x φ ↔ sat (orderFrame Y) V (f x) φ` for every modal
  formula `φ`.  The `box` case is exactly where `forth` and `back` are each used once.
* `valid_of_image` — validity transfers along surjective bounded morphisms.
* `valid_boundedPoset_iff_valid_cworld` — **the modal theory of the clock-and-switch
  worlds is exactly the modal theory of the finite rooted directed posets.**  One
  direction is the observation that every `CWorld (Fin n) (Fin m)` is itself such a
  poset (or empty); the other is the representation theorem plus the p-morphism lemma.
  Thus a modal formula can be refuted on some finite bounded poset iff it can be
  refuted on a product of a chain with a Boolean cube — a genuinely combinatorial
  criterion for a logical property.
* `valid_dot2_boundedPoset` — a worked instance of the transfer: the S4.2 axiom
  `◇□p → □◇p` is verified on clock-and-switch worlds (where directedness is the
  concrete "advance the clock, union the switches" construction) and then *exported*
  to every finite rooted directed poset by the transfer theorem.
-/

import Combinatorics.CWorldFiltration
import Logic.ProvabilityLogic.TangledSoundness

namespace CWorldFiltration

open Function GLPLogic TangledSoundness

universe u v

/-- The Kripke frame attached to a preorder: accessibility is `≤`. -/
def orderFrame (X : Type u) [Preorder X] : KFrame.{u} where
  W := X
  R := (· ≤ ·)

@[simp] theorem orderFrame_R {X : Type u} [Preorder X] (x y : X) :
    (orderFrame X).R x y ↔ x ≤ y := Iff.rfl

/-- `φ` is **valid** on the preorder `X` (with variables in `α`). -/
def FValid (X : Type u) [Preorder X] (α : Type v) (φ : MFormula α) : Prop :=
  ∀ (V : α → X → Prop) (x : X), sat (orderFrame X) V x φ

/-! ## The p-morphism lemma -/

/-- **P-morphism lemma.**  Satisfaction is invariant along a bounded morphism, when the
valuation upstairs is pulled back from downstairs.  `forth` gives one inclusion in the
`box` case, `back` the other. -/
theorem sat_bddMorphism {X : Type u} {Y : Type u} [Preorder X] [Preorder Y]
    (f : BddMorphism X Y) {α : Type v} (V : α → Y → Prop) (φ : MFormula α) (x : X) :
    sat (orderFrame X) (fun p x => V p (f.toFun x)) x φ ↔ sat (orderFrame Y) V (f.toFun x) φ := by
  induction φ generalizing x with
  | var p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
      simp only [sat_imp]
      exact imp_congr (ihφ x) (ihψ x)
  | box φ ih =>
      simp only [sat_box, orderFrame_R]
      constructor
      · intro h u hu
        obtain ⟨y, hxy, rfl⟩ := f.back x u hu
        exact (ih y).mp (h y hxy)
      · intro h y hxy
        exact (ih y).mpr (h (f.toFun y) (f.forth hxy))

/-- Validity transfers to surjective bounded morphic images. -/
theorem valid_of_image {X : Type u} {Y : Type u} [Preorder X] [Preorder Y]
    (f : BddMorphism X Y) (hf : Surjective f.toFun) {α : Type v} {φ : MFormula α}
    (h : FValid X α φ) : FValid Y α φ := by
  intro V y
  obtain ⟨x, rfl⟩ := hf y
  exact (sat_bddMorphism f V φ x).mp (h _ x)

/-! ## The modal theory of clock-and-switch worlds -/

/-- Everything is vacuously valid on the empty clock-and-switch world. -/
theorem fValid_cworld_zero (m : ℕ) {α : Type v} (φ : MFormula α) :
    FValid (CWorld (Fin 0) (Fin m)) α φ := fun _ x => x.clock.elim0

/-- **The modal theory of the clock-and-switch worlds is the modal theory of the finite
rooted directed posets.**  Refutability on a finite bounded poset is equivalent to
refutability on a product of a chain with a Boolean cube. -/
theorem valid_boundedPoset_iff_valid_cworld {α : Type v} (φ : MFormula α) :
    (∀ (P : Type) (_ : PartialOrder P) (_ : Fintype P), (∃ r : P, ∀ p, r ≤ p) →
        (∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z) → FValid P α φ) ↔
      (∀ n m : ℕ, FValid (CWorld (Fin n) (Fin m)) α φ) := by
  constructor
  · intro h n m
    rcases n with _ | n
    · exact fValid_cworld_zero m φ
    · exact h (CWorld (Fin (n + 1)) (Fin m)) inferInstance inferInstance
        CWorld.isRooted CWorld.directed
  · intro h P _ _ hroot hdir
    obtain ⟨f, hf⟩ := representable_of_rooted_directed P hroot hdir
    exact valid_of_image f hf (h 1 (Fintype.card P))

/-! ## A worked transfer: the S4.2 axiom -/

/-- On a directed preorder the S4.2 axiom `◇□p → □◇p` is valid. -/
theorem fValid_dot2_of_directed {X : Type u} [Preorder X]
    (hdir : ∀ x y : X, ∃ z, x ≤ z ∧ y ≤ z) {α : Type v} (p : α) :
    FValid X α (MFormula.imp (MFormula.dia (MFormula.box (MFormula.var p)))
      (MFormula.box (MFormula.dia (MFormula.var p)))) := by
  intro V x hx y hxy
  -- `hx : ¬ ∀ u ≥ x, ¬ (∀ v ≥ u, V p v)`, i.e. some `u ≥ x` forces `□p`
  simp only [MFormula.dia, MFormula.neg, sat_imp, sat_box, sat_bot, orderFrame_R] at hx ⊢
  intro hy
  refine hx fun u hxu hu => ?_
  obtain ⟨z, huz, hyz⟩ := hdir u y
  exact hy z hyz (hu z huz)

/-- The S4.2 axiom holds on every finite rooted directed poset — obtained by verifying
it on the clock-and-switch worlds (where directedness is the explicit
"advance the clock, take the union of the switches" construction) and transferring
along the representation theorem. -/
theorem valid_dot2_boundedPoset (P : Type) [PartialOrder P] [Fintype P]
    (hroot : ∃ r : P, ∀ p, r ≤ p) (hdir : ∀ x y : P, ∃ z, x ≤ z ∧ y ≤ z)
    {α : Type v} (p : α) :
    FValid P α (MFormula.imp (MFormula.dia (MFormula.box (MFormula.var p)))
      (MFormula.box (MFormula.dia (MFormula.var p)))) := by
  refine (valid_boundedPoset_iff_valid_cworld _).mpr ?_ P inferInstance inferInstance hroot hdir
  intro n m
  exact fValid_dot2_of_directed (fun x y => CWorld.directed x y) p

end CWorldFiltration