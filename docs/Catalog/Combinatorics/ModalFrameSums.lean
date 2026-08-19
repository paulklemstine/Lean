/-
# Cycle 5, Part IV: Disjoint Unions and the Closure Package

The last structural operation needed for a definability *theory* is the disjoint union
of frames.  Together with the bounded morphisms of Part II it yields a small
Goldblatt–Thomason-style closure package for the frame class of any `ModalSystem`, and
two further limitative theorems that no amount of axiom-hunting can evade.

## Main results

* `valid_sum_iff` — a formula is valid on the disjoint union `F ⊎ G` iff it is valid on
  both summands.  (Both directions use the truth lemma for bounded morphisms of
  Part II: the two injections are bounded morphisms, and every world of the sum lies in
  the image of one of them.)
* `ModalSystem.frameSound_sum` / `ModalSystem.frameSound_of_sum_left` — the frame class
  of every modal proof system is closed under disjoint unions *and* reflects them.
* `universal_not_definable` — "every world sees every world" is not modally definable:
  it fails for `loopFrame ⊎ loopFrame` though it holds for `loopFrame`.
* `exists_reflexive_not_definable` — "some world is reflexive" is not modally
  definable: `succFrame ⊎ loopFrame` has a reflexive world, but the summand `succFrame`
  does not.
* `tangledSystem_frameSound_sum` — a sanity check of Part II's closed-form description:
  the frame class of the self-sound system (`R = Eq`) *is* closed under disjoint unions,
  as the closure package predicts.
* `frameClass_closure_package` — the three closure properties gathered for an arbitrary
  `ModalSystem`.
-/

import Mathlib
import Combinatorics.ModalFrameDefinabilityLimits

namespace FrameDefinability

open GLPLogic TangledSoundness

universe u u'

variable {α : Type}

/-! ## Part A — Disjoint unions of Kripke frames -/

/-- The **disjoint union** of two Kripke frames: worlds are the sum type, and
accessibility never crosses between the summands. -/
@[reducible] def KFrame.sum (F : KFrame.{u}) (G : KFrame.{u}) : KFrame.{u} where
  W := F.W ⊕ G.W
  R := fun x y =>
    match x, y with
    | .inl a, .inl b => F.R a b
    | .inr a, .inr b => G.R a b
    | _, _ => False

/-- The left injection is a bounded morphism into the sum. -/
def sumInl (F G : KFrame.{u}) : BoundedMorphism F (KFrame.sum F G) where
  toFun := Sum.inl
  forth := fun h => h
  back := fun {_} {u} h => by
    cases u with
    | inl b => exact ⟨b, h, rfl⟩
    | inr b => exact absurd h (by simp)

/-- The right injection is a bounded morphism into the sum. -/
def sumInr (F G : KFrame.{u}) : BoundedMorphism G (KFrame.sum F G) where
  toFun := Sum.inr
  forth := fun h => h
  back := fun {_} {u} h => by
    cases u with
    | inl b => exact absurd h (by simp)
    | inr b => exact ⟨b, h, rfl⟩

/-- **Validity is determined summand-wise.**  This is the second closure property of
definable classes (after invariance under surjective bounded morphic images). -/
theorem valid_sum_iff (F G : KFrame.{u}) (φ : MFormula α) :
    Valid (KFrame.sum F G) α φ ↔ (Valid F α φ ∧ Valid G α φ) := by
  constructor
  · intro h
    refine ⟨fun V w => ?_, fun V w => ?_⟩
    · have := h (fun p x => match x with | .inl a => V p a | .inr _ => False) (.inl w)
      exact (sat_boundedMorphism (sumInl F G) _ φ w).mp this
    · have := h (fun p x => match x with | .inl _ => False | .inr a => V p a) (.inr w)
      exact (sat_boundedMorphism (sumInr F G) _ φ w).mp this
  · rintro ⟨hF, hG⟩ V w
    cases w with
    | inl a => exact sat_image_of_valid (sumInl F G) hF V a
    | inr b => exact sat_image_of_valid (sumInr F G) hG V b

/-! ## Part B — The closure package for `ModalSystem` frame classes -/

/-- The frame class of a modal proof system is closed under disjoint unions. -/
theorem frameSound_sum (S : ModalSystem α) {F G : KFrame.{u}}
    (hF : S.FrameSound F) (hG : S.FrameSound G) : S.FrameSound (KFrame.sum F G) :=
  fun φ hφ => (valid_sum_iff F G φ).mpr ⟨hF φ hφ, hG φ hφ⟩

/-- …and reflects them: a summand of a sound frame is sound. -/
theorem frameSound_of_sum_left (S : ModalSystem α) {F G : KFrame.{u}}
    (h : S.FrameSound (KFrame.sum F G)) : S.FrameSound F :=
  fun φ hφ => ((valid_sum_iff F G φ).mp (h φ hφ)).1

theorem frameSound_of_sum_right (S : ModalSystem α) {F G : KFrame.{u}}
    (h : S.FrameSound (KFrame.sum F G)) : S.FrameSound G :=
  fun φ hφ => ((valid_sum_iff F G φ).mp (h φ hφ)).2

/-- **The closure package.**  For every modal proof system, the class of frames sound
for it is closed under surjective bounded morphic images, closed under disjoint unions,
and reflects disjoint unions.  Every limitative theorem below is a corollary. -/
theorem frameClass_closure_package (S : ModalSystem α) :
    (∀ {F : KFrame.{u}} {G : KFrame.{u'}} (f : BoundedMorphism F G),
        Function.Surjective f.toFun → S.FrameSound F → S.FrameSound G) ∧
      (∀ {F G : KFrame.{u}}, S.FrameSound F → S.FrameSound G →
        S.FrameSound (KFrame.sum F G)) ∧
      (∀ {F G : KFrame.{u}}, S.FrameSound (KFrame.sum F G) →
        S.FrameSound F ∧ S.FrameSound G) :=
  ⟨fun f hsurj h => frameSound_of_surjective S f hsurj h,
    fun hF hG => frameSound_sum S hF hG,
    fun h => ⟨frameSound_of_sum_left S h, frameSound_of_sum_right S h⟩⟩

/-! ## Part C — Two more things modal formulas cannot say -/

/-- **Universality is not modally definable.**  `loopFrame` is universal, but the
disjoint union of two copies is not, and definable classes are closed under disjoint
unions. -/
theorem universal_not_definable (Γ : Set (MFormula α)) :
    ¬ Defines α Γ (fun F : KFrame.{0} => ∀ w v : F.W, F.R w v) := by
  intro hdef
  have hloop : ∀ φ ∈ Γ, Valid loopFrame α φ :=
    (hdef loopFrame).mpr (fun _ _ => trivial)
  have hsum : ∀ φ ∈ Γ, Valid (KFrame.sum loopFrame loopFrame) α φ := fun φ hφ =>
    (valid_sum_iff loopFrame loopFrame φ).mpr ⟨hloop φ hφ, hloop φ hφ⟩
  have := (hdef (KFrame.sum loopFrame loopFrame)).mp hsum (.inl ()) (.inr ())
  exact this

/-- **"Some world is reflexive" is not modally definable.**  The union
`succFrame ⊎ loopFrame` has a reflexive world, so it would validate `Γ`; but then the
summand `succFrame` validates `Γ` too, and it has no reflexive world. -/
theorem exists_reflexive_not_definable (Γ : Set (MFormula α)) :
    ¬ Defines α Γ (fun F : KFrame.{0} => ∃ w : F.W, F.R w w) := by
  intro hdef
  have hsum : ∀ φ ∈ Γ, Valid (KFrame.sum succFrame loopFrame) α φ :=
    (hdef (KFrame.sum succFrame loopFrame)).mpr ⟨.inr (), trivial⟩
  have hsucc : ∀ φ ∈ Γ, Valid succFrame α φ := fun φ hφ =>
    ((valid_sum_iff succFrame loopFrame φ).mp (hsum φ hφ)).1
  obtain ⟨n, hn⟩ := (hdef succFrame).mp hsucc
  exact succFrame_irrefl n hn

/-- Consequently no modal proof system has "some world is reflexive" as its frame
class: the property that Cycle 1 identified with internalised soundness cannot be
axiomatised by any system whatsoever. -/
theorem no_modalSystem_frameClass_exists_reflexive (S : ModalSystem α) :
    ¬ (∀ F : KFrame.{0}, S.FrameSound F ↔ ∃ w : F.W, F.R w w) := by
  intro h
  have hsum : S.FrameSound (KFrame.sum succFrame loopFrame) :=
    (h (KFrame.sum succFrame loopFrame)).mpr ⟨.inr (), trivial⟩
  obtain ⟨n, hn⟩ := (h succFrame).mp (frameSound_of_sum_left S hsum)
  exact succFrame_irrefl n hn

/-! ## Part D — Consistency check against the closed-form frame classes -/

/-- The frame class of the self-sound (tangled) system computed in Part II — the frames
with `R = Eq` — is indeed closed under disjoint unions, as the package requires. -/
theorem tangledSystem_frameSound_sum (p : α) (F G : KFrame.{0})
    (hF : (tangledSystem α).FrameSound F) (hG : (tangledSystem α).FrameSound G) :
    ∀ w v : (KFrame.sum F G).W, (KFrame.sum F G).R w v ↔ v = w := by
  have heqF := (tangledSystem_frameSound_iff p F).mp hF
  have heqG := (tangledSystem_frameSound_iff p G).mp hG
  rintro (a | a) (b | b)
  · simpa [KFrame.sum] using heqF a b
  · simp [KFrame.sum]
  · simp [KFrame.sum]
  · simpa [KFrame.sum] using heqG a b

/-- The GL frame class is likewise closed under disjoint unions: transitivity and
converse well-foundedness are inherited by the sum.  (Immediate from `frameSound_sum`
and the closed form of Part II, so no new well-foundedness argument is needed.) -/
theorem glValiditySystem_frameSound_sum (p : α) (F G : KFrame.{0})
    (hF : Transitive F.R) (hwF : WellFounded (Function.swap F.R))
    (hG : Transitive G.R) (hwG : WellFounded (Function.swap G.R)) :
    Transitive (KFrame.sum F G).R ∧
      WellFounded (Function.swap (KFrame.sum F G).R) := by
  have h₁ : (glValiditySystem α).FrameSound F :=
    (glValiditySystem_frameSound_iff p F).mpr ⟨hF, hwF⟩
  have h₂ : (glValiditySystem α).FrameSound G :=
    (glValiditySystem_frameSound_iff p G).mpr ⟨hG, hwG⟩
  exact (glValiditySystem_frameSound_iff p (KFrame.sum F G)).mp
    (frameSound_sum (glValiditySystem α) h₁ h₂)

end FrameDefinability

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H22. (Bold) Adding disjoint unions to the p-morphism invariance of Part II makes
--        the *existence* of a reflexive world — Cycle 1's exact characterisation of
--        internal soundness — undefinable, even though the *universality* of
--        reflexivity is definable by `T`.
--   H23. The closed-form frame classes of Part II must be closed under the operations
--        of the package; if one of them were not, Part II would contain an error.
--
-- Experiment (Experimenter):
--   H22: confirmed twice over — `exists_reflexive_not_definable` for axiom sets and
--        `no_modalSystem_frameClass_exists_reflexive` for proof systems.  So the
--        Cycle-1 slogan "soundness = tangle" is a statement about a *single world*
--        that no axiom set can globally express as "somewhere there is a tangle".
--   H23: confirmed for both witnesses (`tangledSystem_frameSound_sum`,
--        `glValiditySystem_frameSound_sum`).  The GL check is derived from the closed
--        form rather than re-proved, which is precisely the leverage frame
--        definability buys: a well-foundedness fact obtained without touching
--        `WellFounded`.
--
-- Analysis (Analyst):
--   Definability is invariance under (i) surjective p-morphic images and (ii) disjoint
--   unions.  "Every world is reflexive" survives both; "some world is reflexive"
--   survives (i) but not (ii); "no world is reflexive" survives (ii) but not (i).  The
--   three limitative theorems of Parts II and IV are exactly the three ways to fail.