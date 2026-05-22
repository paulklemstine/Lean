/-
# Characterization of Equivalences by Contractible Fibers

This file proves that a function is (part of) a quasi-equivalence if and
only if all of its fibers are contractible. This is the structural bridge
between HoTT and category-theoretic thinking.
-/

import Logic.HoTT.Basic

universe u v w

namespace HoTT

/-! ## Forward direction: equivalence implies contractible fibers -/

/-
If `f` is part of a QEquiv, then every fiber of `f` is contractible.
    The center of contraction for the fiber over `b` is `(invFun b, rightInv b)`.
-/
theorem equiv_implies_fibers_contr
    {A : Sort u} {B : Sort v} (f : A → B)
    (e : QEquiv A B) (hf : e.toFun = f) :
    ∀ b : B, isContr (fiber f b) := by
  intro b
  unfold fiber;
  constructor;
  swap;
  exact ⟨ e.invFun b, hf ▸ e.rightInv b ⟩;
  rintro ⟨ a, ha ⟩;
  have := e.leftInv a; aesop;

/-! ## Backward direction: contractible fibers imply equivalence -/

/-
If all fibers of `f` are contractible, then `f` is part of a QEquiv.
    The inverse is constructed by picking the center of each fiber.
-/
noncomputable def fibers_contr_implies_equiv
    {A : Sort u} {B : Sort v} (f : A → B)
    (hfibers : ∀ b : B, isContr (fiber f b)) :
    QEquiv A B where
  toFun := f
  invFun b := (hfibers b).choose.1
  leftInv a := by
    have h := (hfibers (f a)).choose_spec ⟨a, rfl⟩
    exact congrArg PSigma.fst h.symm
  rightInv b := (hfibers b).choose.2

/-- The constructed equivalence has `f` as its forward map. -/
theorem fibers_contr_implies_equiv_toFun
    {A : Sort u} {B : Sort v} (f : A → B)
    (hfibers : ∀ b : B, isContr (fiber f b)) :
    (fibers_contr_implies_equiv f hfibers).toFun = f := rfl

/-! ## The main biconditional -/

/-
**Characterization of Equivalences by Contractible Fibers.**

    A function `f : A → B` is (the forward map of) a quasi-equivalence
    if and only if all of its fibers are contractible. This identifies
    the notion of equivalence with a homotopical property of fibers,
    which is the conceptual hinge of univalence.
-/
theorem qequiv_iff_all_fibers_contr
    {A : Sort u} {B : Sort v} (f : A → B) :
    (∃ e : QEquiv A B, e.toFun = f) ↔
    (∀ b : B, isContr (fiber f b)) := by
  constructor;
  · rintro ⟨ e, rfl ⟩ b;
    -- Apply the theorem that states if `f` is part of a QEquiv, then every fiber of `f` is contractible.
    apply equiv_implies_fibers_contr e.toFun e rfl;
  · exact fun h => ⟨ fibers_contr_implies_equiv f h, fibers_contr_implies_equiv_toFun f h ⟩

/-! ## Corollaries -/

/-
A bijection (function with two-sided inverse) has contractible fibers.
-/
theorem bijection_has_contr_fibers
    {A : Sort u} {B : Sort v} (f : A → B) (g : B → A)
    (hfg : ∀ b, f (g b) = b) (hgf : ∀ a, g (f a) = a) :
    ∀ b : B, isContr (fiber f b) := by
  intros b
  use ⟨g b, hfg b⟩;
  rintro ⟨ a, ha ⟩ ; exact psigma_eq ( by aesop ) ( by aesop )

/-
The identity function has contractible fibers.
-/
theorem id_has_contr_fibers (A : Sort u) :
    ∀ a : A, isContr (fiber id a) := by
  intro a;
  convert singletonContraction a using 1;
  -- By definition of fiber, we have fiber id a = Σ' x : A, id x = a.
  simp [fiber];
  grind

end HoTT