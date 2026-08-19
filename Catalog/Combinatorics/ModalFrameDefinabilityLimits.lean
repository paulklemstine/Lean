/-
# Cycle 5, Part II: Bounded Morphisms, the Limits of Definability, and the Frame
# Classes of the Cycle-4 Witnesses

Part I (`Combinatorics.ModalFrameDefinability`) built the correspondence between modal
axioms and conditions on `KFrame.R`.  This file supplies the two things that turn a
list of correspondences into a *theory* of definability:

1. **A transfer principle.**  A bounded morphism (p-morphism) between `KFrame`s
   preserves and reflects `sat` (`sat_boundedMorphism`); a *surjective* one transports
   frame validity (`Valid_of_boundedMorphism_surjective`).  Since the theorems of a
   `ModalSystem` are just a set of formulas, the frame class of **every** modal proof
   system is closed under surjective bounded morphic images
   (`ModalSystem.frameSound_of_surjective`).
2. **Genuine limitative results.**  Irreflexivity and "at least two worlds" are *not*
   frame classes of any set of modal formulas, and therefore not the frame class of any
   `ModalSystem` (`irreflexive_not_definable`, `no_modalSystem_frameClass_irreflexive`,
   `two_worlds_not_definable`).  This is a sharp counterpoint to Part I: the Löb axiom
   defines the transitive converse-well-founded frames, yet irreflexivity — which those
   frames satisfy — is not definable on its own.

Finally we compute the frame classes of the **two Cycle-4 witnesses** exactly:

* `glValiditySystem_frameSound_iff` — a frame is sound for the GL validity system iff
  it is transitive and converse well-founded.  The system is *frame-complete for its
  own defining condition*.
* `tangledSystem_frameSound_iff` — a frame is sound for the self-sound (tangled) system
  iff its accessibility relation is **equality**: internalised soundness pins the
  semantics down to a disjoint union of single reflexive loops.
* `frameSound_isEmpty_of_reflection_loeb` and `frame_definability_dichotomy` — the
  Cycle-4 joint-inconsistency theorem read off from the frame classes: the two witness
  classes are nonempty and disjoint, and any system with both properties has only the
  empty frame.
-/

import Mathlib
import Combinatorics.ModalFrameDefinability

namespace FrameDefinability

open GLPLogic TangledSoundness

universe u u'

variable {α : Type}

/-! ## Part A — Bounded morphisms and the transfer of validity -/

/-- A **bounded morphism** (p-morphism) of Kripke frames: a map that preserves
accessibility (`forth`) and reflects it up to a preimage (`back`).  These are the
structure-preserving maps of modal model theory. -/
structure BoundedMorphism (F : KFrame.{u}) (G : KFrame.{u'}) where
  /-- The underlying map on worlds. -/
  toFun : F.W → G.W
  /-- Accessibility is preserved. -/
  forth : ∀ {w v : F.W}, F.R w v → G.R (toFun w) (toFun v)
  /-- Every successor of the image is the image of a successor. -/
  back : ∀ {w : F.W} {u : G.W}, G.R (toFun w) u → ∃ v, F.R w v ∧ toFun v = u

/-- **Truth lemma for bounded morphisms.**  Satisfaction of any modal formula at the
image world under a valuation equals satisfaction at the source world under the pulled
back valuation. -/
theorem sat_boundedMorphism {F : KFrame.{u}} {G : KFrame.{u'}} (f : BoundedMorphism F G)
    (V : α → G.W → Prop) (φ : MFormula α) (w : F.W) :
    sat G V (f.toFun w) φ ↔ sat F (fun p x => V p (f.toFun x)) w φ := by
  induction φ generalizing w with
  | var p => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ => exact imp_congr (ihφ w) (ihψ w)
  | box φ ih =>
      constructor
      · intro h v hwv
        exact (ih v).mp (h (f.toFun v) (f.forth hwv))
      · intro h u hu
        obtain ⟨v, hwv, rfl⟩ := f.back hu
        exact (ih v).mpr (h v hwv)

/-- **Validity transfers along surjective bounded morphisms.** -/
theorem Valid_of_boundedMorphism_surjective {F : KFrame.{u}} {G : KFrame.{u'}}
    (f : BoundedMorphism F G) (hsurj : Function.Surjective f.toFun)
    {φ : MFormula α} (h : Valid F α φ) : Valid G α φ := by
  intro V w
  obtain ⟨x, rfl⟩ := hsurj w
  exact (sat_boundedMorphism f V φ x).mpr (h _ x)

/-- Validity at a single world transfers *into* the target of a bounded morphism: if
`φ` is valid on `F` then it holds at every world in the image of `F`. -/
theorem sat_image_of_valid {F : KFrame.{u}} {G : KFrame.{u'}} (f : BoundedMorphism F G)
    {φ : MFormula α} (h : Valid F α φ) (V : α → G.W → Prop) (w : F.W) :
    sat G V (f.toFun w) φ :=
  (sat_boundedMorphism f V φ w).mpr (h _ w)

/-! ## Part B — Limitative results: what modal formulas cannot say -/

/-- The successor frame on `ℕ`: `n → n + 1`.  Irreflexive, and it maps onto the single
reflexive loop. -/
@[reducible] def succFrame : KFrame.{0} where
  W := ℕ
  R := fun n m => m = n + 1

theorem succFrame_irrefl : ∀ n, ¬ succFrame.R n n := by
  intro n h
  have hn : n = n + 1 := h
  omega

/-- Collapsing `ℕ` to the single self-accessing world of Cycle 4's `loopFrame` is a
bounded morphism: the back condition holds because every natural number has a
successor. -/
def collapseSucc : BoundedMorphism succFrame loopFrame where
  toFun := fun _ => ()
  forth := fun _ => trivial
  back := fun {w} {u} _ => ⟨w + 1, rfl, by cases u; rfl⟩

theorem collapseSucc_surjective : Function.Surjective collapseSucc.toFun := by
  intro u
  exact ⟨0, by cases u; rfl⟩

/-- **Irreflexivity is not modally definable.**  No set of modal formulas has the
irreflexive frames as its frame class: `succFrame` is irreflexive, it maps onto
`loopFrame` by a surjective bounded morphism, and `loopFrame` is reflexive. -/
theorem irreflexive_not_definable (Γ : Set (MFormula α)) :
    ¬ Defines α Γ (fun F : KFrame.{0} => ∀ w, ¬ F.R w w) := by
  intro hdef
  have hsucc : ∀ φ ∈ Γ, Valid succFrame α φ := (hdef succFrame).mpr succFrame_irrefl
  have hloop : ∀ φ ∈ Γ, Valid loopFrame α φ := fun φ hφ =>
    Valid_of_boundedMorphism_surjective collapseSucc collapseSucc_surjective (hsucc φ hφ)
  exact (hdef loopFrame).mp hloop () trivial

/-- A two-world frame with no accessibility at all. -/
@[reducible] def discreteTwo : KFrame.{0} where
  W := Bool
  R := fun _ _ => False

/-- A one-world frame with no accessibility at all. -/
@[reducible] def discreteOne : KFrame.{0} where
  W := Unit
  R := fun _ _ => False

/-- Collapsing the two-point discrete frame onto the one-point discrete frame. -/
def collapseTwo : BoundedMorphism discreteTwo discreteOne where
  toFun := fun _ => ()
  forth := fun h => h.elim
  back := fun h => h.elim

theorem collapseTwo_surjective : Function.Surjective collapseTwo.toFun := by
  intro u
  exact ⟨true, by cases u; rfl⟩

/-- **Cardinality is not modally definable either**: "the frame has at least two
worlds" is not the frame class of any set of modal formulas. -/
theorem two_worlds_not_definable (Γ : Set (MFormula α)) :
    ¬ Defines α Γ (fun F : KFrame.{0} => ∃ w v : F.W, w ≠ v) := by
  intro hdef
  have htwo : ∀ φ ∈ Γ, Valid discreteTwo α φ :=
    (hdef discreteTwo).mpr ⟨true, false, by simp⟩
  have hone : ∀ φ ∈ Γ, Valid discreteOne α φ := fun φ hφ =>
    Valid_of_boundedMorphism_surjective collapseTwo collapseTwo_surjective (htwo φ hφ)
  obtain ⟨w, v, hwv⟩ := (hdef discreteOne).mp hone
  exact hwv (by cases w; cases v; rfl)

/-! ## Part C — Frame classes of `ModalSystem`s -/

/-- Frame soundness (Cycle 3) is exactly validity of all theorems. -/
theorem frameSound_iff_valid (S : ModalSystem α) (F : KFrame.{u}) :
    S.FrameSound F ↔ ∀ φ : MFormula α, S.Thm φ → Valid F α φ := Iff.rfl

/-- **The frame class of any modal proof system is closed under surjective bounded
morphic images.**  This is the structural reason for all the limitative results below:
the frame class of a system can never distinguish a frame from its p-morphic image. -/
theorem frameSound_of_surjective (S : ModalSystem α) {F : KFrame.{u}}
    {G : KFrame.{u'}} (f : BoundedMorphism F G) (hsurj : Function.Surjective f.toFun)
    (h : S.FrameSound F) : S.FrameSound G :=
  fun φ hφ => Valid_of_boundedMorphism_surjective f hsurj (h φ hφ)

/-- **No modal proof system has the irreflexive frames as its frame class.**  Cycle 4's
`ModalSystem` abstraction is therefore genuinely weaker than first-order frame talk:
irreflexivity — the very property that separates the Löbian witness from the tangled
one — is invisible to it. -/
theorem no_modalSystem_frameClass_irreflexive (S : ModalSystem α) :
    ¬ (∀ F : KFrame.{0}, S.FrameSound F ↔ ∀ w, ¬ F.R w w) := by
  intro h
  have hsucc : S.FrameSound succFrame := (h succFrame).mpr succFrame_irrefl
  have hloop : S.FrameSound loopFrame :=
    frameSound_of_surjective S collapseSucc collapseSucc_surjective hsucc
  exact (h loopFrame).mp hloop () trivial

/-- A system proving the reflection schema is sound only for reflexive frames. -/
theorem reflexive_of_frameSound_of_reflection (S : ModalSystem α)
    (p : α) {F : KFrame.{u}} (hR : S.ProvesReflection) (hs : S.FrameSound F) :
    ∀ w, F.R w w :=
  ((defines_reflexive (α := α) p F).mp) (by
    rintro φ rfl
    exact hs _ (hR (MFormula.var p)))

/-- A system proving the Löb axiom is sound only for GL frames: transitivity and
converse well-foundedness are *forced* by frame soundness. -/
theorem gl_of_frameSound_of_loeb (S : ModalSystem α) (p : α)
    {F : KFrame.{u}} (hL : S.ProvesLoebAxiom) (hs : S.FrameSound F) :
    Transitive F.R ∧ WellFounded (Function.swap F.R) :=
  (valid_loeb_iff F p).mp (hs _ (hL (MFormula.var p)))

/-- **The joint-inconsistency theorem in frame form.**  Any system proving both the
reflection schema and the Löb axiom is sound only for the empty frame — even before one
knows that such a system is inconsistent. -/
theorem frameSound_isEmpty_of_reflection_loeb (S : ModalSystem α) (p : α)
    {F : KFrame.{u}} (hR : S.ProvesReflection) (hL : S.ProvesLoebAxiom)
    (hs : S.FrameSound F) : IsEmpty F.W :=
  isEmpty_of_valid_loeb_and_reflection F p (hs _ (hL (MFormula.var p)))
    (hs _ (hR (MFormula.var p)))

/-! ## Part D — The frame classes of the two Cycle-4 witnesses, computed exactly -/

/-- A transitive, converse well-founded `KFrame` *is* a GL frame. -/
def glFrameOfKFrame (F : KFrame.{0}) (htr : Transitive F.R)
    (hwf : WellFounded (Function.swap F.R)) : GLFrame where
  W := F.W
  R := F.R
  R_trans := fun h₁ h₂ => htr h₁ h₂
  R_wf := hwf

/-- **The GL validity system is frame-defined by the GL condition.**  A frame is sound
for `glValiditySystem` exactly when it is transitive and converse well-founded: the
system's frame class is precisely the class its defining axiom picks out. -/
theorem glValiditySystem_frameSound_iff (p : α) (F : KFrame.{0}) :
    (glValiditySystem α).FrameSound F ↔
      (Transitive F.R ∧ WellFounded (Function.swap F.R)) := by
  constructor
  · intro hs
    exact gl_of_frameSound_of_loeb (glValiditySystem α) p
      glValiditySystem_provesLoebAxiom hs
  · rintro ⟨htr, hwf⟩ φ hφ V w
    have := hφ (glFrameOfKFrame F htr hwf) V w
    exact (sat_toKFrame_eq_forces (glFrameOfKFrame F htr hwf) V w φ).mpr this

/-- The tangled system proves `p → □p`: at the single loop world, truth propagates to
all (i.e. to the one) successor. -/
theorem tangledSystem_proves_p_imp_box_p (p : α) :
    (tangledSystem α).Thm (.imp (MFormula.var p) (.box (MFormula.var p))) := by
  intro V w hp v _
  cases v
  cases w
  exact hp

/-- Every world of a frame whose accessibility is equality generates a copy of
`loopFrame`. -/
def loopInto {F : KFrame.{u}} (heq : ∀ w v : F.W, F.R w v ↔ v = w) (w : F.W) :
    BoundedMorphism loopFrame F where
  toFun := fun _ => w
  forth := fun _ => (heq w w).mpr rfl
  back := fun {_} {u} h => ⟨(), trivial, ((heq w u).mp h).symm⟩

/-- **The self-sound system is frame-defined by "accessibility = equality".**  Cycle 4's
tangled witness — the consistent system containing its own soundness predicate — is
sound exactly for the frames that are disjoint unions of single reflexive loops.  The
forward direction uses reflection (forcing reflexivity) together with `p → □p` (forcing
that no world sees anything else); the converse uses the truth lemma for the bounded
morphism `loopInto`. -/
theorem tangledSystem_frameSound_iff (p : α) (F : KFrame.{u}) :
    (tangledSystem α).FrameSound F ↔ ∀ w v : F.W, F.R w v ↔ v = w := by
  constructor
  · intro hs w v
    constructor
    · intro hwv
      have := hs _ (tangledSystem_proves_p_imp_box_p p) (fun _ x => x = w) w rfl v hwv
      exact this
    · rintro rfl
      exact reflexive_of_frameSound_of_reflection (tangledSystem α) p
        tangledSystem_provesReflection hs v
  · intro heq φ hφ V w
    have h := (sat_boundedMorphism (loopInto heq w) V φ ()).mpr (hφ _ ())
    exact h

/-- The two witness frame classes are **disjoint on nonempty frames**: a nonempty frame
cannot be sound for both Cycle-4 systems.  (Semantically this is the joint
inconsistency: soundness of a system for a nonempty frame implies consistency.) -/
theorem no_nonempty_frame_sound_for_both (p : α) (F : KFrame.{0}) [Nonempty F.W]
    (h₁ : (glValiditySystem α).FrameSound F) (h₂ : (tangledSystem α).FrameSound F) :
    False := by
  obtain ⟨htr, hwf⟩ := (glValiditySystem_frameSound_iff p F).mp h₁
  have heq := (tangledSystem_frameSound_iff p F).mp h₂
  obtain ⟨w⟩ := ‹Nonempty F.W›
  exact (hwf.irrefl).irrefl w ((heq w w).mpr rfl)

/-- **Capstone: frame definability separates the Cycle-4 witnesses and re-derives their
joint inconsistency.**

1. The Löbian witness is frame-defined by the GL condition, and its class contains a
   nonempty frame (the two-world chain of Cycle 3 is transitive and converse
   well-founded; here we use the one-point irreflexive frame).
2. The self-sound witness is frame-defined by "`R` is equality", and its class contains
   the nonempty `loopFrame`.
3. The two classes meet only in the empty frames, and *every* system with both
   properties is sound only for the empty frame. -/
theorem frame_definability_dichotomy (p : α) :
    (∀ F : KFrame.{0}, (glValiditySystem α).FrameSound F ↔
        (Transitive F.R ∧ WellFounded (Function.swap F.R))) ∧
      (∀ F : KFrame.{0}, (tangledSystem α).FrameSound F ↔ ∀ w v : F.W, F.R w v ↔ v = w) ∧
      (glValiditySystem α).FrameSound discreteOne ∧
      (tangledSystem α).FrameSound loopFrame ∧
      (∀ F : KFrame.{0}, (glValiditySystem α).FrameSound F →
        (tangledSystem α).FrameSound F → IsEmpty F.W) := by
  refine ⟨fun F => glValiditySystem_frameSound_iff p F,
    fun F => tangledSystem_frameSound_iff p F, ?_, ?_, ?_⟩
  · refine (glValiditySystem_frameSound_iff p discreteOne).mpr ⟨fun _ _ _ h _ => False.elim h, ?_⟩
    exact ⟨fun _ => Acc.intro _ (fun _ h => h.elim)⟩
  · exact (tangledSystem_frameSound_iff p loopFrame).mpr (fun w v => by
      constructor
      · intro _; cases w; cases v; rfl
      · intro _; trivial)
  · intro F h₁ h₂
    by_contra hne
    rw [not_isEmpty_iff] at hne
    exact no_nonempty_frame_sound_for_both p F h₁ h₂

end FrameDefinability

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H19. (Bold) The frame class of *every* `ModalSystem` is closed under surjective
--        bounded morphic images, so there are properties of frames — irreflexivity,
--        cardinality — that no modal proof system whatsoever can pin down, even though
--        the Löb axiom pins down the strictly stronger GL condition.
--   H20. (Bold) Both Cycle-4 witnesses are *exactly* frame-defined: their frame classes
--        can be computed in closed form, not merely bounded.
--   H21. The joint inconsistency of reflection and Löb is visible already at the level
--        of frame classes: their intersection consists of empty frames only.
--
-- Experiment (Experimenter):
--   H19: confirmed.  `sat_boundedMorphism` is a four-case induction; only the box case
--        has content, and it uses `forth` in one direction and `back` in the other.
--        The counterexample pair is `succFrame ↠ loopFrame` (irreflexivity) and
--        `discreteTwo ↠ discreteOne` (cardinality).  Note the first collapse *needs*
--        the back condition: it holds only because every `n` has the successor `n+1`.
--   H20: confirmed.  `glValiditySystem` ↦ {transitive, converse well-founded};
--        `tangledSystem` ↦ {R = Eq}.  The second was the surprise: reflection alone
--        gives only reflexivity, but the tangled system also proves `p → □p`, and the
--        valuation `x ↦ x = w` turns that into "`w` sees nothing but itself".  The
--        converse needed a bounded morphism *into* the frame (`loopInto`), i.e. the
--        truth lemma without surjectivity.
--   H21: confirmed as `ModalSystem.frameSound_isEmpty_of_reflection_loeb`, and
--        concretely for the two witnesses in `no_nonempty_frame_sound_for_both`.
--
-- Analysis (Analyst):
--   Definable classes are closed under p-morphic images; the Löb condition survives
--   this closure while irreflexivity does not, because converse well-foundedness of the
--   *whole* frame is destroyed by the collapse `succFrame ↠ loopFrame` while
--   irreflexivity is not.  So the reason Löb is definable is not that it implies
--   irreflexivity but that it implies a p-morphism-invariant strengthening of it.
--
-- Critique (Critic):
--   `frame_definability_dichotomy` has five components and each is used: dropping the
--   nonempty witnesses (2 and 3) would leave a statement satisfiable by an
--   inconsistent system, which is exactly the degenerate case Cycle 4 warned about.
--   The `IsEmpty` clause is proved from the two closed-form descriptions, not assumed.