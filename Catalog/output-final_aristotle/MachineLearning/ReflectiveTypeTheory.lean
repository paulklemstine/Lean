/-
# Reflective Type Theory: Proving Things About Proving Things

This file formalizes a small *reflective* propositional logic in which a
proposition may refer to its own provability, and studies the well-typed term

  "this proposition is provable but not provably provable"    (□A ∧ ¬□□A).

The modality `□` is read as *provability*, following the standard reading of
provability logic where `□A` means "`A` is provable".  We give a Kripke
semantics for the language and establish:

* `godelian_satisfiable_in_K` — the sentence `□A ∧ ¬□□A` is a *satisfiable*,
  well-typed term: there is a (non-transitive) model and world where it holds.
  Thus a reflective system whose provability predicate is *not* provably
  transitive can genuinely express "provable but not provably provable".

* `axiom4_of_transitive` — in any transitive frame the axiom `4` (`□A → □□A`)
  is valid.  This is exactly the semantic content of *Σ₁-completeness*
  ("if `A` is provable then it is provably provable").

* `godelian_unsat_in_transitive` — consequently, in every transitive frame
  (in particular in the frames of Gödel–Löb provability logic `GL`) the
  sentence `□A ∧ ¬□□A` is *unsatisfiable*.  So the "provable but not provably
  provable" phenomenon is impossible precisely when provability is provably
  transitive.

* `Kmodel_not_transitive` — the witnessing model above is not transitive,
  confirming that the contrast between the two results is real.

We further develop the semantics enough to prove the two landmark theorems of
provability logic:

* `axiomK`, `necessitation`, `axiomT_of_reflexive`, `sat_dia` — the normal
  modal logic `K` and the dual `◇`.

* `loeb_valid` — **Löb's theorem**: on transitive, converse-well-founded
  frames (the `GL` frames) the Löb schema `□(□A → A) → □A` is valid.

* `goedel_second_incompleteness` — **Gödel's second incompleteness theorem**
  as a corollary: on `GL` frames `□(¬□⊥) → □⊥`, i.e. a consistent system that
  is a `GL` frame cannot prove its own consistency.

Everything is elementary and self-contained (only `Mathlib`'s `WellFounded`
infrastructure is used, for Löb's theorem).
-/

import Mathlib

namespace ReflectiveTypeTheory

/-! ## Syntax -/

/-- Propositional modal formulas.  `box p` is read "`p` is provable". -/
inductive Form where
  | atom : ℕ → Form
  | bot : Form
  | imp : Form → Form → Form
  | box : Form → Form
deriving DecidableEq

/-- Negation `¬p := p → ⊥`. -/
def Form.neg (p : Form) : Form := Form.imp p Form.bot

/-- Conjunction, defined classically via `¬(p → ¬q)`. -/
def Form.and (p q : Form) : Form := Form.neg (Form.imp p (Form.neg q))

/-- The dual modality `◇p := ¬□¬p`. -/
def Form.dia (p : Form) : Form := (Form.box p.neg).neg

/-- The reflective Gödelian sentence "`A` is provable but not provably provable":
`□A ∧ ¬□□A`. -/
def godelianReflection (A : Form) : Form := (A.box).and (A.box.box).neg

/-! ## Kripke semantics -/

/-- A Kripke model: a set of worlds `W`, an accessibility relation `R`, and a
valuation `V` of atoms.  `R w v` means "`v` is accessible from `w`". -/
structure Model where
  W : Type
  R : W → W → Prop
  V : ℕ → W → Prop

/-- Satisfaction of a formula at a world. `box p` holds at `w` iff `p` holds at
every accessible world. -/
def sat (M : Model) : Form → M.W → Prop
  | Form.atom n, w => M.V n w
  | Form.bot, _ => False
  | Form.imp p q, w => sat M p w → sat M q w
  | Form.box p, w => ∀ v, M.R w v → sat M p v

/-- A formula is *valid* in a model if it holds at every world. -/
def valid (M : Model) (p : Form) : Prop := ∀ w, sat M p w

@[simp] lemma sat_neg (M : Model) (p : Form) (w : M.W) :
    sat M p.neg w ↔ ¬ sat M p w := by
  simp [Form.neg, sat]

/-- Satisfaction of the defined conjunction agrees with meta-level `∧`. -/
lemma sat_and (M : Model) (p q : Form) (w : M.W) :
    sat M (p.and q) w ↔ (sat M p w ∧ sat M q w) := by
  simp [Form.and, Form.neg, sat]

/-- Satisfaction of the defined diamond agrees with the existential reading. -/
theorem sat_dia (M : Model) (p : Form) (w : M.W) :
    sat M p.dia w ↔ ∃ v, M.R w v ∧ sat M p v := by
  simp only [Form.dia, Form.neg, sat]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    exact h (fun v hv hpv => hc v hv hpv)
  · rintro ⟨v, hv, hpv⟩ h
    exact h v hv hpv

/-! ## The normal modal logic `K` -/

/-- The distribution axiom `K`: `□(p → q) → (□p → □q)` is valid in every model. -/
theorem axiomK (M : Model) (p q : Form) (w : M.W) :
    sat M (Form.imp (Form.box (Form.imp p q))
      (Form.imp (Form.box p) (Form.box q))) w := by
  intro h1 h2 v hv
  exact h1 v hv (h2 v hv)

/-- The necessitation rule: if `p` is valid then `□p` is valid. -/
theorem necessitation (M : Model) (p : Form) (h : valid M p) :
    valid M (Form.box p) := fun _ _ _ => h _

/-- The reflection axiom `T` (`□p → p`) is valid exactly on reflexive frames. -/
theorem axiomT_of_reflexive (M : Model) (hrefl : Reflexive M.R) (p : Form)
    (w : M.W) : sat M (Form.imp (Form.box p) p) w :=
  fun h => h w (hrefl w)

/-! ## "Provable but not provably provable" is satisfiable

We build an explicit three-world, non-transitive model `Kmodel` and a world at
which `□A ∧ ¬□□A` holds.  The worlds form a chain `wa → wb → wc`; the atom `A`
is true exactly at `wb`.  Then at `wa`: every accessible world (`wb`) satisfies
`A`, so `□A` holds; but `wb` accesses `wc` where `A` fails, so `□A` fails at
`wb`, whence `□□A` fails at `wa`. -/

/-- The three worlds of the witnessing model. -/
inductive KW | wa | wb | wc
deriving DecidableEq

/-- A non-transitive Kripke model witnessing `□A ∧ ¬□□A`. -/
def Kmodel : Model where
  W := KW
  R := fun a b => (a = KW.wa ∧ b = KW.wb) ∨ (a = KW.wb ∧ b = KW.wc)
  V := fun _ w => w = KW.wb

/-- **The Gödelian reflective sentence is a satisfiable, well-typed term.**
There is a model and world at which `□A ∧ ¬□□A` holds. -/
theorem godelian_satisfiable_in_K :
    sat Kmodel (godelianReflection (Form.atom 0)) KW.wa := by
  rw [godelianReflection, sat_and]
  constructor
  · -- `□A` at `wa`: the only accessible world is `wb`, where `A` is true.
    intro v hv
    rcases hv with ⟨_, h⟩ | ⟨h, _⟩
    · exact h
    · exact absurd h (by decide)
  · -- `¬□□A` at `wa`: `wb` is accessible and accesses `wc`, where `A` fails.
    intro h
    have := h KW.wb (Or.inl ⟨rfl, rfl⟩) KW.wc (Or.inr ⟨rfl, rfl⟩)
    exact absurd (show KW.wc = KW.wb from this) (by decide)

/-- The witnessing model is genuinely non-transitive. -/
theorem Kmodel_not_transitive : ¬ Transitive Kmodel.R := by
  intro h
  have : Kmodel.R KW.wa KW.wc :=
    h (Or.inl ⟨rfl, rfl⟩) (Or.inr ⟨rfl, rfl⟩)
  rcases this with ⟨_, h2⟩ | ⟨h1, _⟩
  · exact absurd h2 (by decide)
  · exact absurd h1 (by decide)

/-! ## Transitive frames: provability is provably transitive

On transitive frames the axiom `4` holds, which is the semantic form of
Σ₁-completeness: whatever is provable is provably provable.  Hence the
reflective sentence `□A ∧ ¬□□A` becomes *unsatisfiable*. -/

/-- **Axiom 4** (`□A → □□A`) is valid on transitive frames. -/
theorem axiom4_of_transitive (M : Model) (htrans : Transitive M.R)
    (p : Form) (w : M.W) (h : sat M (Form.box p) w) :
    sat M (Form.box (Form.box p)) w := by
  intro v hv u hu
  exact h u (htrans hv hu)

/-- **On transitive frames the reflective sentence `□A ∧ ¬□□A` is
unsatisfiable.**  When provability is provably transitive, "provable but not
provably provable" cannot occur. -/
theorem godelian_unsat_in_transitive (M : Model) (htrans : Transitive M.R)
    (A : Form) (w : M.W) : ¬ sat M (godelianReflection A) w := by
  rw [godelianReflection, sat_and]
  rintro ⟨h1, h2⟩
  exact h2 (axiom4_of_transitive M htrans A w h1)

/-! ## Löb's theorem and Gödel's second incompleteness theorem

The frames of Gödel–Löb provability logic `GL` are the transitive,
converse-well-founded frames.  On these frames the Löb schema is valid, and
Gödel's second incompleteness theorem follows by taking `A := ⊥`. -/

/-- **Löb's theorem** (semantic form): on transitive, converse-well-founded
frames the Löb schema `□(□A → A) → □A` is valid.

`hwf` asserts that `fun a b => R b a` is well-founded, i.e. `R` has no infinite
ascending chain — the standard "converse well-founded" condition for `GL`. -/
theorem loeb_valid (M : Model) (htrans : Transitive M.R)
    (hwf : WellFounded (fun a b => M.R b a)) (A : Form) (w : M.W) :
    sat M (Form.imp (Form.box (Form.imp (Form.box A) A)) (Form.box A)) w := by
  intro hbox
  show ∀ v, M.R w v → sat M A v
  by_contra hcon
  push_neg at hcon
  obtain ⟨v0, hv0, hnv0⟩ := hcon
  -- Take an `R`-maximal accessible world `u` at which `A` fails.
  obtain ⟨u, huS, hmax⟩ :=
    hwf.has_min {x | M.R w x ∧ ¬ sat M A x} ⟨v0, hv0, hnv0⟩
  obtain ⟨hRwu, hnAu⟩ := huS
  -- From `□(□A → A)` at `w` and `R w u` we get `□A → A` at `u`.
  have himp := hbox u hRwu
  have hnbox : ¬ sat M (Form.box A) u := fun hb => hnAu (himp hb)
  -- Hence some `u'` accessible from `u` fails `A`; by transitivity `R w u'`.
  have hex : ∃ u', M.R u u' ∧ ¬ sat M A u' := by
    by_contra hc; push_neg at hc; exact hnbox hc
  obtain ⟨u', hRuu', hnAu'⟩ := hex
  -- This contradicts the maximality of `u`.
  exact hmax u' ⟨htrans hRwu hRuu', hnAu'⟩ hRuu'

/-- **Gödel's second incompleteness theorem** (semantic form): on `GL` frames
`□(¬□⊥) → □⊥`.  Reading `¬□⊥` as the consistency statement, a system whose
provability is a `GL` frame *proves its own consistency only if it is
inconsistent*.  This is the instance `A := ⊥` of Löb's theorem, using that
`(□⊥).neg = (□⊥ → ⊥)` definitionally. -/
theorem goedel_second_incompleteness (M : Model) (htrans : Transitive M.R)
    (hwf : WellFounded (fun a b => M.R b a)) (w : M.W) :
    sat M (Form.imp (Form.box (Form.box Form.bot).neg) (Form.box Form.bot)) w :=
  loeb_valid M htrans hwf Form.bot w

/-! ## A concrete `GL` frame

To confirm the `GL` theorems above are non-vacuous, here is an explicit
transitive, converse-well-founded model on `ℕ` with `R a b := b < a`. -/

/-- A concrete `GL` model on the naturals: `R a b` iff `b < a`. -/
def GLmodel : Model where
  W := ℕ
  R := fun a b => b < a
  V := fun _ _ => True

theorem GLmodel_transitive : Transitive GLmodel.R :=
  fun _ _ _ hab hbc => lt_trans hbc hab

theorem GLmodel_converse_wf : WellFounded (fun a b => GLmodel.R b a) := by
  simpa [GLmodel] using (wellFounded_lt : WellFounded (· < · : ℕ → ℕ → Prop))

/-- Löb's schema holds in the concrete `GL` model, for every formula and world. -/
theorem loeb_valid_GLmodel (A : Form) (w : ℕ) :
    sat GLmodel (Form.imp (Form.box (Form.imp (Form.box A) A)) (Form.box A)) w :=
  loeb_valid GLmodel GLmodel_transitive GLmodel_converse_wf A w

/-- The reflective sentence `□A ∧ ¬□□A` is unsatisfiable in the concrete `GL`
model (a special case of `godelian_unsat_in_transitive`). -/
theorem godelian_unsat_GLmodel (A : Form) (w : ℕ) :
    ¬ sat GLmodel (godelianReflection A) w :=
  godelian_unsat_in_transitive GLmodel GLmodel_transitive A w

end ReflectiveTypeTheory