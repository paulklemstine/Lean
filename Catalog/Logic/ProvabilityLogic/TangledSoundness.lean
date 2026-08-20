/-
# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

A proof system "references its own soundness" when the reflection schema
`□φ → φ` — *whatever is provable is true* — is available **inside** the system it
validates.  On the Kripke side this is the *reflection (soundness) schema* holding at
a world of a frame.  This file proves that internalised soundness is **exactly** a
strange loop: a world validates its own soundness schema iff it accesses itself, and
therefore no well-founded (GL / provability) hierarchy can host a sound world.

## Main results

* `uniformlySound_iff_selfLoop` — **soundness = tangle.**  A world `w` of a Kripke
  frame validates every instance `□φ → φ` (for every valuation) **iff** `R w w`.
* `loebAt_irrefl` — a world validating every Löb instance is irreflexive.
* `no_sound_loeb_world`, `sound_loeb_frame_isEmpty` — **the tangle is unavoidable:**
  no world can validate both soundness and Löb; a frame validating both schemas is
  empty.  This is the semantic form of Gödel's second incompleteness theorem for
  the full reflection schema.
* `uniformlySound_isTangled`, `uniformlySound_no_grading` — a frame with a sound
  world is `TangledHierarchies.IsTangled` and admits **no** ℕ-valued level grading:
  the hierarchy of levels must genuinely collapse.
* `soundnessExt_*` — **the cost is exactly one loop.**  Every frame extends to one
  with a sound world (`KFrame.soundnessExt`), the extension preserves all truths of
  the original (generated-submodel truth lemma `soundnessExt_sat_some`), and it
  contains exactly one self-loop and exactly one sound world.
* `lfp_boxOp_eq_univ_iff_wf` — **modal fixed points.**  The least fixed point of the
  box operator on `Set W` is everything **iff** the frame is converse well-founded;
  `selfLoop_lfp_ne_univ` shows a single tangle destroys this fixed-point principle.
* `namesSoundness_two_world`, `serial_of_global_self_soundness`,
  `glFrame_isEmpty_of_global_self_soundness` — **the internal soundness predicate.**
  A frame can carry a propositional variable naming *its own* soundness set
  (a genuine modal fixed point, non-vacuous: some world sound, some not), but if the
  system asserts that predicate everywhere then every world has a successor, and a
  converse well-founded (GL) frame with a globally asserted soundness predicate is
  empty.

## Relationship to catalog
Builds on `Logic.ProvabilityLogic.GLPFrames` (`MFormula`, `GLFrame`, `forces`,
`loeb_valid`) and on `Logic.TangledHierarchies` (`IsTangled`, `HasSelfLoop`,
`tangled_has_no_grading`).  `GLFrame` is by construction converse well-founded, so
tangles are invisible there; the general `KFrame` here is the ambient category in
which the tangle can be exhibited, and `GLFrame.toKFrame` (with
`sat_toKFrame_eq_forces`) embeds the catalog's GL frames into it.
-/

import Mathlib
import Logic.ProvabilityLogic.GLPFrames
import Logic.TangledHierarchies

namespace TangledSoundness

open GLPLogic

universe u

variable {α : Type*}

/-! ## Part 0 — General Kripke frames

`GLFrame` bakes in transitivity and converse well-foundedness, so it can never host a
tangle.  We work in the ambient class of *arbitrary* Kripke frames and embed GL frames
into it. -/

/-- A **Kripke frame**: a set of worlds with an accessibility relation.  No
well-foundedness is assumed — that is precisely what a tangle destroys. -/
structure KFrame : Type (u + 1) where
  /-- The worlds. -/
  W : Type u
  /-- The accessibility relation. -/
  R : W → W → Prop

/-- Kripke satisfaction for `GLPLogic.MFormula` on a general frame. -/
def sat (F : KFrame) (V : α → F.W → Prop) : F.W → MFormula α → Prop
  | w, .var p => V p w
  | _, .bot => False
  | w, .imp φ ψ => sat F V w φ → sat F V w ψ
  | w, .box φ => ∀ v, F.R w v → sat F V v φ

@[simp] theorem sat_var (F : KFrame) (V : α → F.W → Prop) (w : F.W) (p : α) :
    sat F V w (.var p) ↔ V p w := Iff.rfl

@[simp] theorem sat_bot (F : KFrame) (V : α → F.W → Prop) (w : F.W) :
    sat F V w (MFormula.bot (α := α)) ↔ False := Iff.rfl

@[simp] theorem sat_imp (F : KFrame) (V : α → F.W → Prop) (w : F.W) (φ ψ : MFormula α) :
    sat F V w (.imp φ ψ) ↔ (sat F V w φ → sat F V w ψ) := Iff.rfl

@[simp] theorem sat_box (F : KFrame) (V : α → F.W → Prop) (w : F.W) (φ : MFormula α) :
    sat F V w (.box φ) ↔ ∀ v, F.R w v → sat F V v φ := Iff.rfl

/-- The underlying Kripke frame of a catalog `GLFrame`. -/
def _root_.GLPLogic.GLFrame.toKFrame (M : GLFrame) : KFrame where
  W := M.W
  R := M.R

/-- Satisfaction on the underlying frame of a GL frame is the catalog's `forces`. -/
theorem sat_toKFrame_eq_forces (M : GLFrame) (V : α → M.W → Prop) (w : M.W)
    (φ : MFormula α) : sat M.toKFrame V w φ ↔ forces M V w φ := by
  induction φ generalizing w with
  | var p => rfl
  | bot => rfl
  | imp φ ψ ihφ ihψ => simp only [sat_imp, forces, ihφ, ihψ]
  | box φ ih => simp only [sat_box, forces]; exact forall_congr' fun v => imp_congr_right fun _ => ih v

/-! ## Part 1 — The reflection (soundness) schema and the Löb schema -/

/-- The **reflection instance** for `φ`: `□φ → φ`, i.e. *if `φ` is provable then `φ`*.
The schema `{reflection φ | φ}` is the soundness predicate of the system, written in
the object language of the system itself. -/
def reflection (φ : MFormula α) : MFormula α := .imp (.box φ) φ

/-- The **Löb instance** for `φ`: `□(□φ → φ) → □φ`.  Provable in GL; the syntactic
expression of converse well-foundedness. -/
def loebInst (φ : MFormula α) : MFormula α := .imp (.box (reflection φ)) (.box φ)

/-- `w` is **uniformly sound** (for the language over `α`): every reflection instance
holds at `w`, under every valuation.  This is "the soundness predicate of the system
holds inside the system, at `w`". -/
def UniformlySoundAt (F : KFrame) (α : Type*) (w : F.W) : Prop :=
  ∀ (V : α → F.W → Prop) (φ : MFormula α), sat F V w (reflection φ)

/-- `w` **validates Löb**: every Löb instance holds at `w`, under every valuation. -/
def LoebAt (F : KFrame) (α : Type*) (w : F.W) : Prop :=
  ∀ (V : α → F.W → Prop) (φ : MFormula α), sat F V w (loebInst φ)

/-- A self-accessing world is uniformly sound: the tangle *creates* internal
soundness. -/
theorem uniformlySoundAt_of_selfLoop {F : KFrame} {w : F.W} (h : F.R w w) :
    UniformlySoundAt F α w := by
  intro V φ hbox
  exact hbox w h

/-- **Soundness = tangle.**  A world validates its own soundness schema (uniformly in
the valuation) *iff* it accesses itself.  One propositional variable suffices to force
the loop, so the equivalence is not an artefact of a rich language. -/
theorem uniformlySound_iff_selfLoop (F : KFrame) (p : α) (w : F.W) :
    UniformlySoundAt F α w ↔ F.R w w := by
  constructor
  · intro h
    have := h (fun _ v => F.R w v) (.var p)
    exact this (fun v hv => hv)
  · exact uniformlySoundAt_of_selfLoop

/-- **Löb forbids the loop.**  A world validating every Löb instance is irreflexive.
The witnessing valuation is `p ↦ {v | v ≠ w}`. -/
theorem loebAt_irrefl (F : KFrame) (p : α) (w : F.W) (h : LoebAt F α w) : ¬ F.R w w := by
  intro hww
  set V : α → F.W → Prop := fun _ v => v ≠ w with hV
  have hpremise : sat F V w (.box (reflection (.var p))) := by
    intro v hv hbox hvw
    subst hvw
    exact hbox v hv rfl
  have hconc : sat F V w (.box (MFormula.var p)) := h V (.var p) hpremise
  exact hconc w hww rfl

/-- **The tangle is unavoidable: no world can be both sound and Löbian.**  A system
that internalises its own soundness must give up the well-founded (Löb) discipline of
its provability predicate — the semantic core of Gödel's second incompleteness
theorem for the full reflection schema. -/
theorem no_sound_loeb_world (F : KFrame) (p : α) (w : F.W)
    (hs : UniformlySoundAt F α w) (hl : LoebAt F α w) : False :=
  loebAt_irrefl F p w hl ((uniformlySound_iff_selfLoop F p w).mp hs)

/-- A frame validating both the soundness schema and the Löb schema at every world has
**no worlds at all**: internalised soundness plus Löb is outright inconsistent. -/
theorem sound_loeb_frame_isEmpty (F : KFrame) (p : α)
    (hs : ∀ w, UniformlySoundAt F α w) (hl : ∀ w, LoebAt F α w) : IsEmpty F.W :=
  ⟨fun w => no_sound_loeb_world F p w (hs w) (hl w)⟩

/-- **GL frames are nowhere sound.**  No world of a catalog `GLFrame` — a transitive,
converse well-founded provability frame — validates its own soundness schema. -/
theorem glFrame_nowhere_sound (M : GLFrame) (p : α) (w : M.W) :
    ¬ UniformlySoundAt M.toKFrame α w := by
  intro h
  exact M.irrefl w ((uniformlySound_iff_selfLoop M.toKFrame p w).mp h)

/-! ## Part 2 — Bridge: a sound world has no level grading -/

/-- A frame with a uniformly sound world has a self-loop. -/
theorem uniformlySound_hasSelfLoop (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) : TangledHierarchies.HasSelfLoop F.R :=
  ⟨w, (uniformlySound_iff_selfLoop F p w).mp h⟩

/-- **Internal soundness makes the hierarchy tangled** in the sense of
`Logic.TangledHierarchies`. -/
theorem uniformlySound_isTangled (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) : TangledHierarchies.IsTangled F.R :=
  TangledHierarchies.isTangled_of_selfLoop (uniformlySound_hasSelfLoop F p w h)

/-- **No levels.**  A frame containing a world that validates its own soundness admits
*no* ℕ-valued rank strictly increasing along accessibility: the stratification into
metalevels is impossible, not merely inconvenient. -/
theorem uniformlySound_no_grading (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) :
    ¬ ∃ rank : F.W → ℕ, ∀ a b, F.R a b → rank a < rank b :=
  TangledHierarchies.tangled_has_no_grading (uniformlySound_isTangled F p w h)

/-! ## Part 3 — The soundness extension: the cost is exactly one loop -/

/-- The **soundness extension** of a frame: adjoin a top world `none` which accesses
every world of `F` *and itself*.  The new world is the system that talks about `F`
while remaining inside the picture — the minimal tangling of a hierarchy. -/
def KFrame.soundnessExt (F : KFrame) : KFrame where
  W := Option F.W
  R := fun x y =>
    match x, y with
    | none, _ => True
    | some u, some v => F.R u v
    | some _, none => False

@[simp] theorem soundnessExt_R_none (F : KFrame) (y : Option F.W) :
    (F.soundnessExt).R none y := trivial

@[simp] theorem soundnessExt_R_some_some (F : KFrame) (u v : F.W) :
    (F.soundnessExt).R (some u) (some v) ↔ F.R u v := Iff.rfl

@[simp] theorem soundnessExt_R_some_none (F : KFrame) (u : F.W) :
    ¬ (F.soundnessExt).R (some u) none := id

/-- The lifted valuation: unchanged on old worlds, false at the new top. -/
def liftVal {F : KFrame} (V : α → F.W → Prop) : α → (F.soundnessExt).W → Prop :=
  fun p x => match x with | none => False | some v => V p v

/-- **Truth lemma for the extension.**  The old worlds form a generated submodel: the
extension preserves and reflects the truth of every formula at every old world.  So
the tangle at the top costs nothing in the original hierarchy. -/
theorem soundnessExt_sat_some (F : KFrame) (V : α → F.W → Prop) (v : F.W)
    (φ : MFormula α) : sat (F.soundnessExt) (liftVal V) (some v) φ ↔ sat F V v φ := by
  induction φ generalizing v with
  | var p => rfl
  | bot => rfl
  | imp φ ψ ihφ ihψ => simp only [sat_imp, ihφ, ihψ]
  | box φ ih =>
      simp only [sat_box]
      constructor
      · intro h u hu
        exact (ih u).mp (h (some u) hu)
      · intro h x hx
        cases x with
        | none => exact absurd hx (soundnessExt_R_some_none F v)
        | some u => exact (ih u).mpr (h u hx)

/-- The new top world is uniformly sound: the extension **does** internalise its own
soundness. -/
theorem soundnessExt_sound_none (F : KFrame) :
    UniformlySoundAt (F.soundnessExt) α none :=
  uniformlySoundAt_of_selfLoop trivial

/-- **Exactly one loop.**  If the original frame is irreflexive (e.g. any GL frame),
the extension has precisely one self-accessing world: the new top. -/
theorem soundnessExt_selfLoop_iff (F : KFrame) (hirr : ∀ v, ¬ F.R v v)
    (x : (F.soundnessExt).W) : (F.soundnessExt).R x x ↔ x = none := by
  cases x with
  | none => simp
  | some v => simpa using hirr v

/-- **Exactly one sound world.**  Over an irreflexive base frame, the top world of the
soundness extension is the unique world validating the soundness schema: the price of
internal soundness is one strange loop, and no more. -/
theorem soundnessExt_sound_iff (F : KFrame) (p : α) (hirr : ∀ v, ¬ F.R v v)
    (x : (F.soundnessExt).W) :
    UniformlySoundAt (F.soundnessExt) α x ↔ x = none := by
  rw [uniformlySound_iff_selfLoop _ p, soundnessExt_selfLoop_iff F hirr]

/-- The extension is **not** a GL frame: converse well-foundedness fails, exactly at
the sound world. -/
theorem soundnessExt_not_converse_wf (F : KFrame) :
    ¬ WellFounded (Function.swap (F.soundnessExt).R) := by
  intro h
  exact h.irrefl.irrefl (none : Option F.W) trivial

/-- Every GL frame embeds, truth-preservingly, into a frame that validates its own
soundness: the tangled hierarchy always exists, and it is conservative over the
untangled one. -/
theorem glFrame_extends_to_sound_frame (M : GLFrame) (p : α) :
    UniformlySoundAt ((M.toKFrame).soundnessExt) α none ∧
      (∀ (V : α → M.W → Prop) (v : M.W) (φ : MFormula α),
        sat ((M.toKFrame).soundnessExt) (liftVal V) (some v) φ ↔ forces M V v φ) ∧
      (∀ x, UniformlySoundAt ((M.toKFrame).soundnessExt) α x ↔ x = none) := by
  refine ⟨soundnessExt_sound_none _, ?_, ?_⟩
  · intro V v φ
    rw [soundnessExt_sat_some]
    exact sat_toKFrame_eq_forces M V v φ
  · exact soundnessExt_sound_iff _ p (fun v => M.irrefl v)

/-! ## Part 4 — Modal fixed points: the box operator on subsets -/

/-- The **box operator** on sets of worlds: `□X` is the set of worlds all of whose
successors lie in `X`. -/
def boxOp (F : KFrame) (X : Set F.W) : Set F.W := {w | ∀ v, F.R w v → v ∈ X}

theorem boxOp_mono (F : KFrame) : Monotone (boxOp F) :=
  fun _ _ hXY _ hw v hv => hXY (hw v hv)

/-- The box operator as a monotone map, so Mathlib's fixed-point calculus applies. -/
def boxHom (F : KFrame) : Set F.W →o Set F.W := ⟨boxOp F, boxOp_mono F⟩

/-- The accessibility-accessible worlds form a **fixed point** of the box operator:
`Acc (swap R)` is definitionally the box of itself. -/
theorem boxOp_accSet (F : KFrame) :
    boxOp F {w | Acc (Function.swap F.R) w} = {w | Acc (Function.swap F.R) w} := by
  ext w
  constructor
  · intro h
    exact Acc.intro w (fun v hv => h v hv)
  · intro h v hv
    exact h.inv hv

/-- **Löb's principle as induction on subsets** is *equivalent* to converse
well-foundedness: every pre-fixed point of the box operator is everything iff the
frame is converse well-founded.  (This is the semantic heart of the Löb rule:
"if `□X ⊆ X` then `X` is everything".) -/
theorem boxOp_prefixed_univ_iff_wf (F : KFrame) :
    (∀ X : Set F.W, boxOp F X ⊆ X → X = Set.univ) ↔
      WellFounded (Function.swap F.R) := by
  constructor
  · intro h
    have hacc := h {w | Acc (Function.swap F.R) w} (le_of_eq (boxOp_accSet F))
    refine ⟨fun w => ?_⟩
    have : w ∈ ({w | Acc (Function.swap F.R) w} : Set F.W) := by rw [hacc]; trivial
    exact this
  · intro hwf X hX
    ext w
    simp only [Set.mem_univ, iff_true]
    induction w using hwf.induction with
    | _ w ih => exact hX (fun v hv => ih v hv)

/-- **The least fixed point of the box operator is everything iff the frame is
converse well-founded.**  A fixed-point formulation of Löb's theorem: `μX.□X = ⊤`
exactly on GL frames. -/
theorem lfp_boxOp_eq_univ_iff_wf (F : KFrame) :
    OrderHom.lfp (boxHom F) = Set.univ ↔ WellFounded (Function.swap F.R) := by
  rw [← boxOp_prefixed_univ_iff_wf]
  constructor
  · intro h X hX
    have hle : OrderHom.lfp (boxHom F) ≤ X := OrderHom.lfp_le _ hX
    rw [h] at hle
    exact Set.eq_univ_of_univ_subset hle
  · intro h
    exact h _ (le_of_eq (OrderHom.map_lfp (boxHom F)))

/-- **One tangle destroys the fixed-point principle.**  If some world accesses itself,
the least fixed point of the box operator is not everything: `{w}ᶜ` is a proper
pre-fixed point. -/
theorem selfLoop_lfp_ne_univ (F : KFrame) {w : F.W} (h : F.R w w) :
    OrderHom.lfp (boxHom F) ≠ Set.univ := by
  intro hlfp
  have hwf : WellFounded (Function.swap F.R) := (lfp_boxOp_eq_univ_iff_wf F).mp hlfp
  exact hwf.irrefl.irrefl w h

/-- Combining: a frame with an internally sound world has no Löb fixed-point
principle. -/
theorem uniformlySound_lfp_ne_univ (F : KFrame) (p : α) (w : F.W)
    (h : UniformlySoundAt F α w) : OrderHom.lfp (boxHom F) ≠ Set.univ :=
  selfLoop_lfp_ne_univ F ((uniformlySound_iff_selfLoop F p w).mp h)

/-! ## Part 5 — The soundness predicate *named inside* the language -/

/-- Soundness of `w` **relative to a fixed valuation**: every reflection instance
holds at `w` under `V`.  Unlike `UniformlySoundAt`, this is the system's own,
valuation-relative notion of soundness. -/
def SoundAtV (F : KFrame) (V : α → F.W → Prop) (w : F.W) : Prop :=
  ∀ φ : MFormula α, sat F V w (reflection φ)

/-- `V` **names its own soundness** by the variable `s`: the extension of `s` is
exactly the set of worlds sound under `V`.  This is the tangled hierarchy in its
sharpest form — a fixed-point condition in which the soundness predicate of the
system occurs as a formula *of* the system. -/
def NamesSoundness (F : KFrame) (V : α → F.W → Prop) (s : α) : Prop :=
  ∀ w, V s w ↔ SoundAtV F V w

/-- Every reflexive world is sound relative to any valuation. -/
theorem soundAtV_of_selfLoop {F : KFrame} {V : α → F.W → Prop} {w : F.W}
    (h : F.R w w) : SoundAtV F V w := fun _ hbox => hbox w h

/-- The two-world frame `{f, t}` in which both worlds see `t` and only `t`. -/
def twoWorldTangle : KFrame where
  W := Bool
  R := fun _ y => y = true

/-- **Existence of an internal soundness predicate.**  On `twoWorldTangle` the
valuation `V () := {t}` satisfies the fixed-point condition: the variable names
exactly the sound worlds — and it does so *non-vacuously*, since `t` is sound and `f`
is not.  So a proof system genuinely can contain a correct predicate for its own
soundness; what it cannot do (Part 1) is *validate* that predicate uniformly while
staying well-founded. -/
theorem namesSoundness_two_world :
    NamesSoundness twoWorldTangle (fun (_ : Unit) (w : Bool) => w = true) () := by
  intro w
  cases w with
  | true =>
      simp only [true_iff]
      exact soundAtV_of_selfLoop rfl
  | false =>
      simp only [Bool.false_eq_true, false_iff]
      intro hsound
      have h := hsound (.var ())
      simp only [reflection, sat_imp, sat_box, sat_var] at h
      exact Bool.false_ne_true (h (fun v hv => hv))

/-- The sound worlds of `twoWorldTangle` are exactly the reflexive ones, so the
internal predicate above is nontrivial: it is false somewhere. -/
theorem twoWorldTangle_false_not_sound :
    ¬ SoundAtV twoWorldTangle (fun (_ : Unit) (w : Bool) => w = true) false := by
  have h := (namesSoundness_two_world false)
  simp only [Bool.false_eq_true, false_iff] at h
  exact h

/-- **Global self-soundness forces seriality.**  If a valuation names its own
soundness and the system *asserts* that predicate at every world (it claims to be
sound), then every world has a successor: the provability predicate can never run out
of witnesses.  The proof uses the single formula `¬s`. -/
theorem serial_of_global_self_soundness (F : KFrame) (V : α → F.W → Prop) (s : α)
    (hname : NamesSoundness F V s) (hglobal : ∀ w, V s w) (w : F.W) :
    ∃ v, F.R w v := by
  have hsound : SoundAtV F V w := (hname w).mp (hglobal w)
  have h := hsound (.imp (.var s) .bot)
  simp only [reflection, sat_imp, sat_box, sat_var, sat_bot] at h
  by_contra hno
  push_neg at hno
  exact h (fun v hv => absurd hv (hno v)) (hglobal w)

/-- **Semantic second incompleteness for the internal soundness predicate.**
A converse well-founded (GL) frame whose valuation names its own soundness and asserts
it everywhere is *empty*.  A well-founded provability hierarchy that proclaims its own
soundness has no models at all — the hierarchy must tangle or die. -/
theorem glFrame_isEmpty_of_global_self_soundness (M : GLFrame) (V : α → M.W → Prop)
    (s : α) (hname : NamesSoundness M.toKFrame V s) (hglobal : ∀ w, V s w) :
    IsEmpty M.W := by
  by_contra hne
  rw [not_isEmpty_iff] at hne
  obtain ⟨w⟩ := hne
  obtain ⟨m, -, hm⟩ := M.R_wf.has_min Set.univ ⟨w, trivial⟩
  obtain ⟨v, hv⟩ := serial_of_global_self_soundness M.toKFrame V s hname hglobal m
  exact hm v trivial hv

/-- **Synthesis: the tangle is forced, and one loop suffices.**  For any GL frame `M`:
(i) no world of `M` internalises soundness, yet (ii) `M` embeds truth-preservingly in
a frame with a unique sound world, whose accessibility relation is tangled and admits
no ℕ-grading. -/
theorem tangled_hierarchy_dichotomy (M : GLFrame) (p : α) :
    (∀ w : M.W, ¬ UniformlySoundAt M.toKFrame α w) ∧
      UniformlySoundAt ((M.toKFrame).soundnessExt) α none ∧
      TangledHierarchies.IsTangled ((M.toKFrame).soundnessExt).R ∧
      ¬ (∃ rank : ((M.toKFrame).soundnessExt).W → ℕ,
          ∀ a b, ((M.toKFrame).soundnessExt).R a b → rank a < rank b) ∧
      (∀ (V : α → M.W → Prop) (v : M.W) (φ : MFormula α),
        sat ((M.toKFrame).soundnessExt) (liftVal V) (some v) φ ↔ forces M V v φ) := by
  refine ⟨fun w => glFrame_nowhere_sound M p w,
    soundnessExt_sound_none _, ?_, ?_, ?_⟩
  · exact uniformlySound_isTangled _ p none (soundnessExt_sound_none _)
  · exact uniformlySound_no_grading _ p none (soundnessExt_sound_none _)
  · intro V v φ
    rw [soundnessExt_sat_some]
    exact sat_toKFrame_eq_forces M V v φ

end TangledSoundness

-- !-- Lab Notes -- !--
--
-- Hypothesis (Hypothesizer):
--   H1. "A world validates its own soundness schema iff it is reflexive" — internal
--       soundness *is* a strange loop, not merely a cause of one.
--   H2. "Löb-validity at a world implies irreflexivity", so soundness and Löb are
--       jointly unsatisfiable at any single world (semantic Gödel 2, schema form).
--   H3. "The cost of internal soundness is exactly one tangle": every frame extends
--       conservatively to a frame with a unique sound world.
--   H4. (Fixed-point form) "μX.□X = ⊤ iff the frame is converse well-founded", so a
--       single self-loop annihilates the Löb fixed-point principle.
--   H5. (Bold) "A frame can carry a propositional variable naming exactly its own
--       soundness set" — weak internalisation is consistent — "but asserting that
--       variable globally forces seriality, hence emptiness on GL frames."
--
-- Experiment (Experimenter):
--   • H1: `uniformlySound_iff_selfLoop`. The ⇐ direction is immediate; ⇒ needs the
--     valuation `p ↦ R w ·`, which makes `□p` true at `w` for free, so `p` at `w`
--     must be `R w w`. One variable suffices.
--   • H2: `loebAt_irrefl`, valuation `p ↦ (· ≠ w)`. Checking `□(□p→p)` at `w` splits
--     on whether the successor equals `w`; both cases close.  `no_sound_loeb_world`
--     and `sound_loeb_frame_isEmpty` follow.
--   • H3: `KFrame.soundnessExt` (adjoin a reflexive top seeing everything);
--     `soundnessExt_sat_some` is the generated-submodel truth lemma (induction on
--     formulas; the box case uses that old worlds never see the new top).
--     `soundnessExt_sound_iff` gives uniqueness over irreflexive bases.
--   • H4: `boxOp_accSet` shows `Acc (swap R)` is *literally* a fixed point of the box
--     operator; that single observation yields both directions of
--     `boxOp_prefixed_univ_iff_wf`, and Knaster–Tarski (`OrderHom.map_lfp`,
--     `OrderHom.lfp_le`) upgrades it to `lfp_boxOp_eq_univ_iff_wf`.
--   • H5: `namesSoundness_two_world` on the 2-world frame `x R y ↔ y = t`: `t` is
--     reflexive hence sound, `f` is refuted by the single formula `s` itself
--     (`□s` holds at `f` because `f`'s only successor is `t`, but `s` fails at `f`).
--     `serial_of_global_self_soundness` uses the formula `¬s`;
--     `glFrame_isEmpty_of_global_self_soundness` combines it with a converse-minimal
--     world obtained from `WellFounded.has_min`.
--
-- Analysis (Analyst):
--   Survived: all five hypotheses, with no `sorry`. The unifying structural pattern is
--   a *duality of quantifier position*: soundness quantified over all valuations
--   (`UniformlySoundAt`) is equivalent to a self-loop and hence incompatible with
--   well-foundedness; soundness relative to one fixed valuation (`SoundAtV`) can be
--   named inside the language on a well-behaved frame (`namesSoundness_two_world`) —
--   weak internalisation is cheap, uniform internalisation is fatal.  What fails, and
--   why: attempts to derive reflexivity from `NamesSoundness` alone are hopeless
--   (the 2-world model is a counterexample: `f` is irreflexive and the naming still
--   holds), so the second-incompleteness punch needs the extra premise that the
--   system *asserts* its soundness predicate (`hglobal`), which is exactly the
--   informal reading of "the system proves its own soundness".
--
-- Critique (Critic):
--   No theorem is vacuous: `uniformlySoundAt_of_selfLoop` and
--   `soundnessExt_sound_none` exhibit inhabited instances of the sound-world notion,
--   and `namesSoundness_two_world` is a concrete finite model, so the impossibility
--   results are not about empty notions.  The equivalences use only one propositional
--   variable (`p : α` is an explicit hypothesis, not a rich-language assumption).
--   `sound_loeb_frame_isEmpty` and `glFrame_isEmpty_of_global_self_soundness` conclude
--   `IsEmpty`, which is a genuine refutation, not a vacuity artefact: the hypotheses
--   are shown satisfiable in isolation (Parts 3 and 5).  No proof is circular; each
--   result depends only on earlier ones.
--
-- Synthesis (PI):
--   Internal soundness, well-foundedness, and nonemptiness form an inconsistent triad;
--   dropping well-foundedness costs exactly one self-loop and nothing else (the
--   extension is conservative).  Next-cycle conjectures in `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--