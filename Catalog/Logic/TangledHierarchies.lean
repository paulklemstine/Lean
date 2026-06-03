import Mathlib

/-!
# Tangled Hierarchies: Proof Systems That Reference Their Own Soundness

We formalize provability logic (GL) using Kripke semantics, prove Löb's theorem
semantically, and establish that self-referential proof systems inevitably create
"tangled hierarchies" where soundness cannot be internalized without inconsistency.

## Main Results

1. **GL Frame Irreflexivity**: Transitive converse-well-founded frames are irreflexive.
2. **Löb's Theorem (Semantic)**: In any GL frame, □(□φ → φ) → □φ is valid.
3. **Second Incompleteness (Semantic)**: A sound world in a GL frame cannot prove
   its own consistency.
4. **Tangling Inevitability**: Any world that proves its own soundness for all formulas
   is inconsistent.

## Mathematical Background

A **GL frame** (Gödel-Löb frame) is a Kripke frame (W, R) where R is transitive
and converse well-founded (no infinite R-ascending chains). These frames provide
the semantics for provability logic GL, which captures the behavior of the
provability predicate in Peano Arithmetic via Solovay's completeness theorem.

The key insight is that Löb's theorem, when interpreted in Kripke semantics,
shows that any "sound" world (one satisfying □φ → φ) cannot prove its own
soundness — creating an unavoidable "tangled hierarchy" where the soundness
predicate lives outside what the system can validate.
-/

open Classical in
noncomputable section

universe u

/-! ## Modal Formulas -/

/-- Modal formulas over propositional variables indexed by `α`.
    The language includes propositional variables, falsum, implication, and the box modality. -/
inductive MFormula (α : Type*) : Type _ where
  | var : α → MFormula α
  | bot : MFormula α
  | imp : MFormula α → MFormula α → MFormula α
  | box : MFormula α → MFormula α
  deriving Inhabited

namespace MFormula

variable {α : Type*}

/-- Negation: ¬φ ≡ φ → ⊥ -/
def neg (φ : MFormula α) : MFormula α := .imp φ .bot

/-- Top: ⊤ ≡ ⊥ → ⊥ -/
def top : MFormula α := neg .bot

/-- Diamond modality: ◇φ ≡ ¬□¬φ -/
def dia (φ : MFormula α) : MFormula α := neg (.box (neg φ))

/-- The consistency formula: Con ≡ ¬□⊥ ≡ □⊥ → ⊥ -/
def con : MFormula α := neg (.box .bot)

/-- The Löb formula for φ: □(□φ → φ) → □φ -/
def loebFormula (φ : MFormula α) : MFormula α :=
  .imp (.box (.imp (.box φ) φ)) (.box φ)

/-- The soundness formula for φ: □φ → φ -/
def soundnessFormula (φ : MFormula α) : MFormula α :=
  .imp (.box φ) φ

end MFormula

/-! ## GL Frames -/

/-- A GL frame: a type of worlds with a transitive, converse well-founded
    accessibility relation. These frames characterize provability logic GL. -/
structure GLFrame where
  /-- The type of possible worlds -/
  W : Type*
  /-- The accessibility relation (representing provability) -/
  R : W → W → Prop
  /-- Transitivity of the accessibility relation -/
  trans : ∀ {u v w : W}, R u v → R v w → R u w
  /-- Converse well-foundedness: no infinite ascending R-chains -/
  wf : WellFounded (Function.swap R)

/-! ## Kripke Semantics -/

/-- The forcing (satisfaction) relation for modal formulas in a GL frame
    with valuation V. `forces M V w φ` means world `w` satisfies `φ`
    under valuation `V`. -/
def forces {α : Type*} (M : GLFrame) (V : α → M.W → Prop) :
    M.W → MFormula α → Prop
  | w, .var p => V p w
  | _, .bot => False
  | w, .imp φ ψ => forces M V w φ → forces M V w ψ
  | w, .box φ => ∀ v, M.R w v → forces M V v φ

/-- A formula is valid in a GL frame if it holds at every world under every valuation. -/
def valid {α : Type*} (M : GLFrame) (φ : MFormula α) : Prop :=
  ∀ (V : α → M.W → Prop) (w : M.W), forces M V w φ

/-- A world is sound if □φ → φ holds for all formulas and valuations. -/
def worldSound {α : Type*} (M : GLFrame) (w : M.W) : Prop :=
  ∀ (V : α → M.W → Prop) (φ : MFormula α), forces M V w (.imp (.box φ) φ)

/-! ## Novel Definition: Tangled Proof System -/

/-- A **tangled proof system** is a GL frame equipped with a designated "standard" world
    representing the intended interpretation, together with a witness that the standard
    world is sound. The key insight is that while the standard world satisfies soundness
    externally, it cannot prove (internalize) this soundness without becoming inconsistent.

    The structure captures the fundamental tension in self-referential proof systems:
    the standard world "knows" it is sound (this is a meta-level fact), but cannot
    express this knowledge within the system without collapsing into inconsistency. -/
structure TangledSystem (α : Type*) where
  /-- The underlying GL frame -/
  frame : GLFrame
  /-- The standard/intended world -/
  std : frame.W
  /-- The standard world is sound: everything provable is true -/
  sound : worldSound (α := α) frame std

/-- The tangling depth of a world in a GL frame, computed via well-founded recursion.
    This measures the length of the longest R-chain starting from the world.
    A world with no successors has depth 0. -/
noncomputable def tanglingDepth (M : GLFrame) (w : M.W) : ℕ :=
  M.wf.fix (fun w ih =>
    if h : ∃ v, M.R w v then
      (ih (h.choose) (h.choose_spec)) + 1
    else 0) w

/-! ## Key Theorems -/

/-
**GL frames are irreflexive**: No world can access itself.
    This follows from converse well-foundedness: a self-loop would create
    an infinite ascending chain w R w R w R ···
-/
theorem gl_irrefl (M : GLFrame) (w : M.W) : ¬ M.R w w := by
  have := M.wf;
  cases' this.has_min { w } ( by simp +decide ) with x hx;
  aesop

/-
**Löb's Theorem (Semantic Version)**: In any GL frame,
    if w ⊨ □(□φ → φ), then w ⊨ □φ.

    This is the semantic counterpart of Löb's theorem in provability logic:
    if a system proves that provability of φ implies φ, then it proves φ.

    The proof uses well-founded induction on the converse of R:
    Given w ⊨ □(□φ → φ), for any v with wRv, by the induction hypothesis
    all R-successors of v satisfy φ (giving v ⊨ □φ), and then
    v ⊨ □φ → φ yields v ⊨ φ.
-/
theorem loeb_semantic {α : Type*} (M : GLFrame) (V : α → M.W → Prop)
    (φ : MFormula α) (w : M.W)
    (h : forces M V w (.box (.imp (.box φ) φ))) :
    forces M V w (.box φ) := by
  unfold forces at *;
  -- By induction on the structure of the formula φ.
  have h_ind : ∀ (v : M.W), M.R w v → forces M V v φ := by
    intro v hv
    have h_ind_step : ∀ (u : M.W), M.R v u → forces M V u φ := by
      intro u hu;
      induction' u using M.wf.induction with u ih;
      have := h u ( M.trans hv hu );
      exact this fun y hy => ih y hy ( M.trans hu hy )
    exact h v hv h_ind_step;
  assumption

/-
**Gödel's Second Incompleteness Theorem (Semantic Version)**:
    A sound, consistent world in a GL frame cannot prove its own consistency.

    More precisely: if w satisfies □⊥ → ⊥ (soundness for ⊥, equivalently consistency),
    then w does NOT satisfy □(□⊥ → ⊥).

    Proof: If w ⊨ □(□⊥ → ⊥), then by Löb's theorem, w ⊨ □⊥.
    By soundness, w ⊨ ⊥. Contradiction.
-/
theorem second_incompleteness {α : Type*} (M : GLFrame) (V : α → M.W → Prop)
    (w : M.W) (hsound : forces M V w (.imp (.box .bot) .bot))
    (hcon : ¬ forces M V w (MFormula.bot (α := α))) :
    ¬ forces M V w (.box (.imp (.box .bot) .bot)) := by
  contrapose! hcon; have := loeb_semantic M V MFormula.bot w; simp_all +decide [ forces ] ;

/-
**Tangling Inevitability**: In a tangled proof system, the standard world
    cannot prove its own soundness even for a single formula (⊥).

    This shows that tangled hierarchies are unavoidable: any sound, consistent
    system necessarily has its soundness predicate "outside" what it can prove.
-/
theorem tangling_inevitable {α : Type*} (T : TangledSystem α)
    (V : α → T.frame.W → Prop)
    (hcon : ¬ forces T.frame V T.std (MFormula.bot (α := α))) :
    ¬ forces T.frame V T.std (.box (.imp (.box .bot) .bot)) := by
  -- Apply the second incompleteness theorem to the standard world.
  apply second_incompleteness;
  · exact T.sound V MFormula.bot;
  · assumption

/-
**Sound worlds are reflexively closed**: If w is sound for all formulas,
    then □φ → φ, meaning anything provable is true at w.
-/
theorem sound_world_box_to_forces {α : Type*} (M : GLFrame) (V : α → M.W → Prop)
    (w : M.W) (hw : worldSound (α := α) M w) (φ : MFormula α)
    (hbox : forces M V w (.box φ)) : forces M V w φ := by
  apply hw V φ hbox

/-
**Tangling dichotomy**: A sound world in a GL frame either has no accessible
    worlds (and is trivially omniscient), or there exists some formula whose
    soundness it cannot prove — the system is necessarily incomplete.
-/
theorem tangling_dichotomy {α : Type*} (M : GLFrame) (w : M.W)
    (hw : worldSound (α := α) M w) :
    (¬ ∃ v, M.R w v) ∨
    (∃ (V : α → M.W → Prop) (φ : MFormula α),
      ¬ forces M V w (.box (.imp (.box φ) φ))) := by
  by_contra h;
  push_neg at h;
  convert second_incompleteness M ( fun _ _ => False ) w _ _;
  all_goals tauto

/-
In a GL frame, if a world has no accessible successors, it trivially satisfies
    □φ for all φ (vacuous provability).
-/
theorem box_vacuous {α : Type*} (M : GLFrame) (V : α → M.W → Prop)
    (w : M.W) (h : ¬ ∃ v, M.R w v) (φ : MFormula α) :
    forces M V w (.box φ) := by
  exact fun v hv => False.elim ( h ⟨ v, hv ⟩ )

/-
**The Löb formula is valid in GL frames**: □(□φ → φ) → □φ holds at every
    world in every GL frame.
-/
theorem loeb_valid {α : Type*} (M : GLFrame) (φ : MFormula α) :
    valid (α := α) M (MFormula.loebFormula φ) := by
  intro V w; exact loeb_semantic M V φ w;

end