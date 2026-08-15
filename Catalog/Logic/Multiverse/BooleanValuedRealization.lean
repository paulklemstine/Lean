/-
# Internal Boolean-Valued Realization of the Forcing Multiverse

This file answers *Direction 1* of the multiverse research programme: it builds a
**Boolean-valued universe whose generic quotients instantiate the abstract forcing
frame**, with forcing closure, directedness and the two opposite Continuum
Hypothesis branches **derived** from the construction rather than assumed as frame
axioms.

The development has four layers.

## Layer A — Boolean-valued semantics and generic quotients

Over an arbitrary Boolean algebra `B` we give the Boolean value `bval v p ∈ B` of a
propositional set-theoretic assertion `p`, define a **generic filter** (a proper
filter deciding every element), and prove the **truth lemma**

* `sat_quot_iff` : `sat (quot v U) p ↔ U.mem (bval v p)` ,

the propositional core of the Boolean-valued-model quotient theorem: the two-valued
quotient satisfies exactly the assertions whose Boolean value lies in the generic
filter.  Around it:

* `bval_eq_top_of_provable` — **forcing closure**: every theorem of classical
  propositional logic has Boolean value `⊤` (soundness of Boolean-valued semantics
  for a Hilbert calculus, by induction on derivations);
* `sat_quot_of_provable`, `sat_quot_of_forces` — everything forced by a condition
  in the generic filter is true in the quotient;
* `branch_of_undecided` — **branching**: an assertion whose Boolean value is
  neither `⊥` nor `⊤` is *true in one generic quotient and false in another*.

## Layer B — the pre-Boolean control frame of buttons and switches

Worlds are pairs `(S, g)` with `S` a finite set of *pushed buttons* and `g` a
setting of the *switches*; accessibility is `S ⊆ T`.  The frame is reflexive,
transitive and **directed** (`cacc_directed`), hence sound for `S4.2`
(`cacc_T`, `cacc_four`, `cacc_dot2`); pushed buttons are buttons in the sense of
`Catalog/Logic/Multiverse/ButtonsSwitches.lean` (`pushed_is_button`) and switches
are switches (`switch_is_switch`).

## Layer C — the realization: Layer B *is* the generic-quotient frame of Layer A

The Boolean algebra is the powerset `Set (Sw → Bool)` of switch settings; stage `S`
carries the assignment `cassign S`, and the generic filters used are the principal
ones at a generic point `g`.  The main theorem

* `realization` : `csat (S, g) p ↔ g ∈ bval (cassign S) p`

says that the control world `(S, g)` is *exactly* the generic quotient of the
Boolean-valued universe at stage `S` by the generic object `g`.  Consequently:

* `button_of_pos` — every **positive button formula** defines a button, *derived*
  from Boolean-valued monotonicity `bval_mono_of_pos`, not assumed;
* `cassign_union_btn` — amalgamation of stages on the algebra side, matching frame
  directedness;
* `CH_branches_derived` — both CH branches come from `branch_of_undecided` applied
  to the CH switch, whose Boolean value is provably neither `⊥` nor `⊤`;
* `five_fails`, `brouwer_fails` — the realized frame validates `.2` yet refutes
  `5` and `B`, so it is genuinely an `S4.2` frame.

## Layer D — ground/extension bimodality

Adding the converse **ground** modality we prove the mixed tense validity
`p → □ ◇̌ p` (`tense_axiom_valid`) while the unimodal Brouwer analogue `p → □ ◇ p`
**fails** on the very same frame (`brouwer_fails`): a concrete separation of the
mixed logic from the extension-only logic (`bimodal_separation`).  Grounds are
downward directed and possess a least element, the **mantle** (`mantle_least`).
-/
import Mathlib
import Logic.Multiverse.ButtonsSwitches

namespace BooleanValuedRealization

open Multiverse

/-! ## Layer A.1 — syntax and Boolean values -/

/-- Propositional set-theoretic assertions over atoms `α`, in the functionally
complete signature `{⊥, →}`. -/
inductive BForm (α : Type*) where
  | atom : α → BForm α
  | fls : BForm α
  | imp : BForm α → BForm α → BForm α
  deriving DecidableEq

namespace BForm
variable {α : Type*}

/-- Negation. -/
def neg (p : BForm α) : BForm α := .imp p .fls
/-- Verum. -/
def tru : BForm α := neg .fls
/-- Disjunction. -/
def disj (p q : BForm α) : BForm α := .imp (neg p) q
/-- Conjunction. -/
def conj (p q : BForm α) : BForm α := neg (.imp p (neg q))

end BForm

variable {α : Type*} {B : Type*} [BooleanAlgebra B]

/-- The **Boolean value** of an assertion in the Boolean-valued universe
determined by the atomic assignment `v`. -/
def bval (v : α → B) : BForm α → B
  | .atom a => v a
  | .fls => ⊥
  | .imp p q => bval v p ⇨ bval v q

@[simp] theorem bval_atom (v : α → B) (a : α) : bval v (.atom a) = v a := rfl
@[simp] theorem bval_fls (v : α → B) : bval v (.fls : BForm α) = ⊥ := rfl
@[simp] theorem bval_imp (v : α → B) (p q : BForm α) :
    bval v (.imp p q) = bval v p ⇨ bval v q := rfl

@[simp] theorem bval_neg (v : α → B) (p : BForm α) :
    bval v p.neg = (bval v p)ᶜ := by
  simp [BForm.neg, himp_bot]

@[simp] theorem bval_tru (v : α → B) : bval v (BForm.tru : BForm α) = ⊤ := by
  simp [BForm.tru]

@[simp] theorem bval_disj (v : α → B) (p q : BForm α) :
    bval v (p.disj q) = bval v p ⊔ bval v q := by
  simp [BForm.disj, himp_eq, sup_comm]

@[simp] theorem bval_conj (v : α → B) (p q : BForm α) :
    bval v (p.conj q) = bval v p ⊓ bval v q := by
  simp [BForm.conj, himp_eq, compl_sup, inf_comm]

/-! ## Layer A.2 — forcing closure: soundness of Boolean-valued semantics -/

section HilbertValues

variable (a b c : B)

/-- Boolean-algebra form of the first Hilbert axiom. -/
theorem himp_ax1 : a ⇨ (b ⇨ a) = ⊤ := by
  rw [eq_top_iff, le_himp_iff, le_himp_iff]
  exact inf_le_left.trans inf_le_right

/-- Boolean-algebra form of the second Hilbert axiom (the distribution axiom). -/
theorem himp_ax2 : (a ⇨ b ⇨ c) ⇨ ((a ⇨ b) ⇨ (a ⇨ c)) = ⊤ := by
  rw [eq_top_iff, le_himp_iff, le_himp_iff, le_himp_iff]
  calc ⊤ ⊓ (a ⇨ b ⇨ c) ⊓ (a ⇨ b) ⊓ a
      ≤ ((a ⇨ b ⇨ c) ⊓ a) ⊓ ((a ⇨ b) ⊓ a) :=
        le_inf (le_inf (inf_le_left.trans (inf_le_left.trans inf_le_right)) inf_le_right)
          (le_inf (inf_le_left.trans inf_le_right) inf_le_right)
    _ ≤ (b ⇨ c) ⊓ b := inf_le_inf himp_inf_le himp_inf_le
    _ ≤ c := himp_inf_le

/-- Boolean-algebra form of double-negation elimination. -/
theorem himp_ax3 : aᶜᶜ ⇨ a = ⊤ := by rw [compl_compl, himp_self]

end HilbertValues

/-- A Hilbert calculus for classical propositional logic. -/
inductive Provable {α : Type*} : BForm α → Prop
  | ax1 (p q : BForm α) : Provable (.imp p (.imp q p))
  | ax2 (p q r : BForm α) :
      Provable (.imp (.imp p (.imp q r)) (.imp (.imp p q) (.imp p r)))
  | ax3 (p : BForm α) : Provable (.imp (BForm.neg (BForm.neg p)) p)
  | mp {p q : BForm α} : Provable (.imp p q) → Provable p → Provable q

/-- **Forcing closure.**  Every theorem of classical propositional logic receives
Boolean value `⊤` in every Boolean-valued universe: the forcing relation is closed
under logical consequence. -/
theorem bval_eq_top_of_provable (v : α → B) {p : BForm α} (h : Provable p) :
    bval v p = ⊤ := by
  induction h with
  | ax1 p q => exact himp_ax1 (bval v p) (bval v q)
  | ax2 p q r => exact himp_ax2 (bval v p) (bval v q) (bval v r)
  | ax3 p => rw [bval_imp, bval_neg, bval_neg]; exact himp_ax3 (bval v p)
  | @mp p q _ _ ihpq ihp =>
      have h1 : bval v p ⇨ bval v q = ⊤ := by simpa using ihpq
      rw [eq_top_iff]
      calc (⊤ : B) = bval v p ⊓ (bval v p ⇨ bval v q) := by rw [h1, ihp]; simp
        _ ≤ bval v q := inf_himp_le

/-! ## Layer A.3 — generic filters and the truth lemma -/

/-- A **generic filter** on a Boolean algebra: a proper filter deciding every
element.  Generic filters are the generic objects whose quotients are the
two-valued universes of the multiverse. -/
structure Generic (B : Type*) [BooleanAlgebra B] where
  /-- Membership in the filter. -/
  mem : B → Prop
  /-- The filter is nontrivial. -/
  top_mem : mem ⊤
  /-- The filter is proper. -/
  bot_notMem : ¬ mem ⊥
  /-- The filter is upward closed. -/
  up : ∀ {a b : B}, mem a → a ≤ b → mem b
  /-- The filter is closed under meets. -/
  inf_mem : ∀ {a b : B}, mem a → mem b → mem (a ⊓ b)
  /-- Genericity: every element is decided. -/
  decides : ∀ a : B, mem a ∨ mem aᶜ

namespace Generic
variable (U : Generic B)

theorem compl_mem_iff (a : B) : U.mem aᶜ ↔ ¬ U.mem a := by
  constructor
  · intro hc ha
    exact U.bot_notMem (by simpa using U.inf_mem ha hc)
  · intro ha
    rcases U.decides a with h | h
    · exact absurd h ha
    · exact h

theorem himp_mem_iff (a b : B) : U.mem (a ⇨ b) ↔ (U.mem a → U.mem b) := by
  constructor
  · intro h ha
    exact U.up (U.inf_mem h ha) himp_inf_le
  · intro h
    by_cases ha : U.mem a
    · exact U.up (h ha) le_himp
    · have hc : U.mem aᶜ := (U.compl_mem_iff a).2 ha
      exact U.up hc (le_himp_iff.2 (by simp))

end Generic

/-- Two-valued satisfaction of an assertion at a two-valued world. -/
def sat (w : α → Prop) : BForm α → Prop
  | .atom a => w a
  | .fls => False
  | .imp p q => sat w p → sat w q

@[simp] theorem sat_atom (w : α → Prop) (a : α) : sat w (.atom a) ↔ w a := Iff.rfl
@[simp] theorem sat_fls (w : α → Prop) : ¬ sat w (.fls : BForm α) := id
@[simp] theorem sat_imp (w : α → Prop) (p q : BForm α) :
    sat w (.imp p q) ↔ (sat w p → sat w q) := Iff.rfl
@[simp] theorem sat_neg (w : α → Prop) (p : BForm α) :
    sat w p.neg ↔ ¬ sat w p := Iff.rfl
@[simp] theorem sat_tru (w : α → Prop) : sat w (BForm.tru : BForm α) := id

@[simp] theorem sat_conj (w : α → Prop) (p q : BForm α) :
    sat w (p.conj q) ↔ sat w p ∧ sat w q := by
  simp only [BForm.conj, sat_neg, sat_imp]
  tauto

@[simp] theorem sat_disj (w : α → Prop) (p q : BForm α) :
    sat w (p.disj q) ↔ sat w p ∨ sat w q := by
  simp only [BForm.disj, sat_imp, sat_neg]
  tauto

/-- Satisfaction depends only on the atomic truth values. -/
theorem sat_congr {w w' : α → Prop} (h : ∀ a, w a ↔ w' a) (p : BForm α) :
    sat w p ↔ sat w' p := by
  induction p with
  | atom a => exact h a
  | fls => rfl
  | imp p q ihp ihq => simp [ihp, ihq]

/-- The **generic quotient**: the two-valued world obtained from the Boolean-valued
universe by collapsing along the generic filter `U`. -/
def quot (v : α → B) (U : Generic B) : α → Prop := fun a => U.mem (v a)

/-- **Truth lemma.**  An assertion holds in the generic quotient iff its Boolean
value belongs to the generic filter. -/
theorem sat_quot_iff (v : α → B) (U : Generic B) (p : BForm α) :
    sat (quot v U) p ↔ U.mem (bval v p) := by
  induction p with
  | atom a => rfl
  | fls => exact iff_of_false id U.bot_notMem
  | imp p q ihp ihq => rw [sat_imp, ihp, ihq, bval_imp, U.himp_mem_iff]

/-- Logical theorems hold in **every** generic quotient. -/
theorem sat_quot_of_provable (v : α → B) (U : Generic B) {p : BForm α}
    (h : Provable p) : sat (quot v U) p := by
  rw [sat_quot_iff, bval_eq_top_of_provable v h]
  exact U.top_mem

/-- A **condition** `b` forces `p` when `b ≤ ⟦p⟧`. -/
def Forces (v : α → B) (b : B) (p : BForm α) : Prop := b ≤ bval v p

/-- Forcing is monotone in the condition: strengthening a condition preserves what
it forces. -/
theorem Forces.mono {v : α → B} {b c : B} {p : BForm α} (h : Forces v b p)
    (hc : c ≤ b) : Forces v c p := le_trans hc h

/-- Forcing is closed under modus ponens. -/
theorem Forces.mp {v : α → B} {b : B} {p q : BForm α}
    (h1 : Forces v b (.imp p q)) (h2 : Forces v b p) : Forces v b q := by
  rw [Forces, bval_imp] at h1
  exact (le_inf h2 h1).trans inf_himp_le

/-- **Generic truth from forcing.**  If a condition in the generic filter forces
`p`, then `p` is true in the generic quotient. -/
theorem sat_quot_of_forces {v : α → B} {b : B} {p : BForm α} (U : Generic B)
    (hb : U.mem b) (h : Forces v b p) : sat (quot v U) p :=
  (sat_quot_iff v U p).2 (U.up hb h)

/-! ## Layer A.4 — branching -/

/-- A Boolean algebra is **rich** when every nonzero element lies in some generic
filter (the Boolean prime ideal principle for `B`). -/
def Rich (B : Type*) [BooleanAlgebra B] : Prop :=
  ∀ b : B, b ≠ ⊥ → ∃ U : Generic B, U.mem b

/-- **Branching theorem.**  An assertion whose Boolean value is neither `⊥` nor `⊤`
is true in one generic quotient and false in another: undecidedness in the
Boolean-valued universe *produces* two opposite branches of the multiverse. -/
theorem branch_of_undecided (hR : Rich B) (v : α → B) (p : BForm α)
    (h0 : bval v p ≠ ⊥) (h1 : bval v p ≠ ⊤) :
    ∃ U V : Generic B, sat (quot v U) p ∧ ¬ sat (quot v V) p := by
  obtain ⟨U, hU⟩ := hR _ h0
  obtain ⟨V, hV⟩ := hR (bval v p)ᶜ (by simpa [compl_eq_bot] using h1)
  refine ⟨U, V, (sat_quot_iff v U p).2 hU, ?_⟩
  rw [sat_quot_iff]
  exact (V.compl_mem_iff _).1 hV

/-- The principal generic filter at a point of a powerset algebra. -/
def principalGeneric {Ω : Type*} (x : Ω) : Generic (Set Ω) where
  mem := fun s => x ∈ s
  top_mem := trivial
  bot_notMem := id
  up := fun h hle => hle h
  inf_mem := fun h1 h2 => ⟨h1, h2⟩
  decides := fun s => by
    by_cases hx : x ∈ s
    · exact Or.inl hx
    · exact Or.inr hx

@[simp] theorem principalGeneric_mem {Ω : Type*} (x : Ω) (s : Set Ω) :
    (principalGeneric x).mem s ↔ x ∈ s := Iff.rfl

/-- Powerset algebras are rich: a nonempty set belongs to the principal filter at
any of its points.  No choice principle is needed. -/
theorem rich_set (Ω : Type*) : Rich (Set Ω) := by
  intro b hb
  obtain ⟨x, hx⟩ := Set.nonempty_iff_ne_empty.2 (by simpa using hb)
  exact ⟨principalGeneric x, hx⟩

/-! ## Layer B — the pre-Boolean control frame of buttons and switches -/

section Control

variable {Btn Sw : Type*}

/-- A **control world**: a finite set of pushed buttons together with a setting of
all switches. -/
abbrev CWorld (Btn Sw : Type*) := Finset Btn × (Sw → Bool)

/-- **Forcing accessibility**: an extension may push further buttons and reset the
switches arbitrarily, but can never unpush a button. -/
def cacc (w v : CWorld Btn Sw) : Prop := w.1 ⊆ v.1

theorem cacc_refl : Reflexive (cacc (Btn := Btn) (Sw := Sw)) := fun _ => subset_rfl

theorem cacc_trans : Transitive (cacc (Btn := Btn) (Sw := Sw)) :=
  fun _ _ _ h1 h2 => h1.trans h2

/-- **Directedness is derived**, not assumed: two extensions of a world are
amalgamated by pushing the union of their buttons. -/
theorem cacc_directed [DecidableEq Btn] (v₁ v₂ : CWorld Btn Sw) :
    ∃ u, cacc v₁ u ∧ cacc v₂ u :=
  ⟨(v₁.1 ∪ v₂.1, v₁.2), Finset.subset_union_left, Finset.subset_union_right⟩

/-! ### `S4.2` soundness of the control frame -/

theorem cacc_T {P : CWorld Btn Sw → Prop} {w : CWorld Btn Sw}
    (h : box cacc P w) : P w := h w (cacc_refl w)

theorem cacc_four {P : CWorld Btn Sw → Prop} {w : CWorld Btn Sw}
    (h : box cacc P w) : box cacc (box cacc P) w :=
  fun _ hwv _ hvu => h _ (cacc_trans hwv hvu)

theorem cacc_K {P Q : CWorld Btn Sw → Prop} {w : CWorld Btn Sw}
    (h : box cacc (fun v => P v → Q v) w) (hp : box cacc P w) : box cacc Q w :=
  fun v hv => h v hv (hp v hv)

/-- **Axiom `.2`** `◇□p → □◇p`, derived from `cacc_directed`. -/
theorem cacc_dot2 [DecidableEq Btn] {P : CWorld Btn Sw → Prop} {w : CWorld Btn Sw}
    (h : dia cacc (box cacc P) w) : box cacc (dia cacc P) w := by
  obtain ⟨v, _, hbox⟩ := h
  intro u hwu
  obtain ⟨t, hvt, hut⟩ := cacc_directed (Sw := Sw) v u
  exact ⟨t, hut, hbox t hvt⟩

/-! ### Buttons and switches -/

/-- The assertion "button `b` has been pushed". -/
def pushedP (b : Btn) : CWorld Btn Sw → Prop := fun w => b ∈ w.1

/-- The assertion "switch `s` is on". -/
def switchP (s : Sw) : CWorld Btn Sw → Prop := fun w => w.2 s = true

/-- Pushed buttons really are **buttons** in the sense of the catalog file
`ButtonsSwitches`: once pushed, necessarily pushed. -/
theorem pushed_is_button (b : Btn) :
    Button (cacc (Btn := Btn) (Sw := Sw)) (pushedP b) :=
  fun _ _ hwv hw => hwv hw

/-- Switches really are **switches**: both values stay possible from every
world. -/
theorem switch_is_switch [DecidableEq Sw] (s : Sw) :
    Switch (cacc (Btn := Btn) (Sw := Sw)) (switchP s) := by
  intro w
  refine ⟨⟨(w.1, Function.update w.2 s true), subset_rfl, ?_⟩,
    ⟨(w.1, Function.update w.2 s false), subset_rfl, ?_⟩⟩
  · simp [switchP]
  · simp [switchP]

/-- Switches are **persistently** switchable: `□(◇p ∧ ◇¬p)`. -/
theorem switch_box_dia [DecidableEq Sw] (s : Sw) (w : CWorld Btn Sw) :
    box cacc (fun v => dia cacc (switchP s) v ∧ dia cacc (fun u => ¬ switchP s u) v) w :=
  fun v _ => switch_is_switch s v

/-! ### Failure of `5`: the frame is `S4.2`, not `S5` -/

/-- With at least one button available the frame refutes axiom `5` (`◇p → □◇p`):
an unpushed button is possibly still unpushed, but after pushing it this is no
longer possible. -/
theorem five_fails (b : Btn) (g : Sw → Bool) :
    ∃ (P : CWorld Btn Sw → Prop) (w : CWorld Btn Sw),
      dia cacc P w ∧ ¬ box cacc (dia cacc P) w := by
  refine ⟨fun v => ¬ pushedP b v, (∅, g),
    ⟨(∅, g), subset_rfl, by simp [pushedP]⟩, ?_⟩
  intro hbox
  obtain ⟨u, hu, hpu⟩ := hbox ({b}, g) (Finset.empty_subset _)
  exact hpu (hu (by simp))

/-- Companion to `five_fails`: the Brouwer axiom `p → □◇p` fails as well. -/
theorem brouwer_fails (b : Btn) (g : Sw → Bool) :
    ∃ (P : CWorld Btn Sw → Prop) (w : CWorld Btn Sw),
      P w ∧ ¬ box cacc (dia cacc P) w := by
  refine ⟨fun v => ¬ pushedP b v, (∅, g), by simp [pushedP], ?_⟩
  intro hbox
  obtain ⟨u, hu, hpu⟩ := hbox ({b}, g) (Finset.empty_subset _)
  exact hpu (hu (by simp))

end Control

/-! ## Layer C — the Boolean-valued realization of the control frame -/

section Realization

variable {Btn Sw : Type*}

/-- Atomic set-theoretic assertions: button assertions (persistent) and switch
assertions (toggleable, e.g. the Continuum Hypothesis). -/
inductive CAtom (Btn Sw : Type*) where
  | btn : Btn → CAtom Btn Sw
  | sw : Sw → CAtom Btn Sw
  deriving DecidableEq

/-- The space of generic objects: all switch settings. -/
abbrev Gen (Sw : Type*) := Sw → Bool

/-- The Boolean-valued assignment at **stage** `S` (the set of buttons already
pushed): a pushed button gets value `⊤`, an unpushed one `⊥`, and a switch gets the
set of generic objects turning it on. -/
def cassign (S : Finset Btn) : CAtom Btn Sw → Set (Gen Sw)
  | .btn b => {_g | b ∈ S}
  | .sw s => {g | g s = true}

/-- The atomic diagram of a control world. -/
def atomTrue (w : CWorld Btn Sw) : CAtom Btn Sw → Prop
  | .btn b => b ∈ w.1
  | .sw s => w.2 s = true

/-- Two-valued satisfaction at a control world. -/
def csat (w : CWorld Btn Sw) (p : BForm (CAtom Btn Sw)) : Prop := sat (atomTrue w) p

/-- The generic quotient of the stage-`S` Boolean-valued universe by the generic
point `g` has exactly the atomic diagram of the control world `(S, g)`. -/
theorem quot_cassign (S : Finset Btn) (g : Gen Sw) (a : CAtom Btn Sw) :
    quot (cassign S) (principalGeneric g) a ↔ atomTrue (S, g) a := by
  cases a with
  | btn b => simp [quot, cassign, atomTrue]
  | sw s => simp [quot, cassign, atomTrue]

/-- **Realization theorem.**  Truth at the control world `(S, g)` coincides with
membership of the generic object `g` in the Boolean value computed at stage `S`.
Thus every world of the abstract frame *is* a generic quotient of the
Boolean-valued universe, and the satisfaction relation is the one induced by the
Boolean values. -/
theorem realization (S : Finset Btn) (g : Gen Sw) (p : BForm (CAtom Btn Sw)) :
    csat (S, g) p ↔ g ∈ bval (cassign S) p := by
  rw [csat, ← sat_congr (fun a => quot_cassign S g a) p,
    sat_quot_iff (cassign S) (principalGeneric g) p]
  rfl

/-- Satisfaction of the CH-style switch atom at a control world. -/
theorem csat_atom_sw (S : Finset Btn) (g : Gen Sw) (s : Sw) :
    csat (S, g) (.atom (.sw s)) ↔ g s = true := Iff.rfl

/-! ### Positive button formulas and derived forcing closure -/

/-- The **positive button fragment**: built from button atoms by conjunction and
disjunction (and verum).  These are the assertions that forcing can only make
*more* true as buttons get pushed. -/
inductive Pos : BForm (CAtom Btn Sw) → Prop
  | atom (b : Btn) : Pos (.atom (.btn b))
  | tru : Pos BForm.tru
  | conj {p q} : Pos p → Pos q → Pos (p.conj q)
  | disj {p q} : Pos p → Pos q → Pos (p.disj q)

/-- Positive button formulas do not mention the switches: their Boolean value does
not distinguish generic objects. -/
theorem bval_pos_pointfree {S : Finset Btn} {p : BForm (CAtom Btn Sw)} (hp : Pos p)
    (g g' : Gen Sw) : g ∈ bval (cassign S) p ↔ g' ∈ bval (cassign S) p := by
  induction hp with
  | atom b => simp [cassign]
  | tru => simp
  | conj _ _ ih1 ih2 => simp only [bval_conj, Set.inf_eq_inter, Set.mem_inter_iff, ih1, ih2]
  | disj _ _ ih1 ih2 => simp only [bval_disj, Set.sup_eq_union, Set.mem_union, ih1, ih2]

/-- **Preservation theorem.**  Along the stage order the Boolean value of a
positive button formula only increases.  This is the Boolean-valued source of the
button phenomenon. -/
theorem bval_mono_of_pos {S T : Finset Btn} (hST : S ⊆ T)
    {p : BForm (CAtom Btn Sw)} (hp : Pos p) :
    bval (cassign S) p ≤ bval (cassign T) p := by
  induction hp with
  | atom b => exact fun g hg => hST hg
  | tru => simp
  | conj _ _ ih1 ih2 => simpa using inf_le_inf ih1 ih2
  | disj _ _ ih1 ih2 => simpa using sup_le_sup ih1 ih2

/-- **Buttons are derived, not assumed.**  Every positive button formula defines a
button of the control frame, as a consequence of the Boolean-valued preservation
theorem together with the realization theorem. -/
theorem button_of_pos {p : BForm (CAtom Btn Sw)} (hp : Pos p) :
    Button (cacc (Btn := Btn) (Sw := Sw)) (fun w => csat w p) := by
  intro w v hwv hw
  obtain ⟨S, g⟩ := w
  obtain ⟨T, h⟩ := v
  rw [realization] at hw ⊢
  exact bval_mono_of_pos hwv hp ((bval_pos_pointfree hp g h).1 hw)

/-- Amalgamation on the algebra side: the stage assignment sends a union of stages
to the join of their Boolean values, matching the frame directedness
`cacc_directed`. -/
theorem cassign_union_btn [DecidableEq Btn] (S T : Finset Btn) (b : Btn) :
    cassign (Sw := Sw) (S ∪ T) (.btn b) =
      cassign (Sw := Sw) S (.btn b) ∪ cassign (Sw := Sw) T (.btn b) := by
  ext g
  simp [cassign]

/-! ### The Continuum Hypothesis branches, derived -/

/-- The CH atom: a designated switch. -/
def chAtom (s : Sw) : BForm (CAtom Btn Sw) := .atom (.sw s)

/-- The Boolean value of CH is nonzero: some generic object makes CH true. -/
theorem bval_ch_ne_bot (S : Finset Btn) (s : Sw) :
    bval (cassign (Btn := Btn) S) (chAtom s) ≠ ⊥ := by
  intro h
  have hmem : (fun _ => true : Gen Sw) ∈ bval (cassign (Btn := Btn) S) (chAtom s) := by
    simp [chAtom, cassign]
  rw [h] at hmem
  exact hmem

/-- The Boolean value of CH is not `⊤`: some generic object makes CH false. -/
theorem bval_ch_ne_top (S : Finset Btn) (s : Sw) :
    bval (cassign (Btn := Btn) S) (chAtom s) ≠ ⊤ := by
  intro h
  have hmem : (fun _ => false : Gen Sw) ∈ bval (cassign (Btn := Btn) S) (chAtom s) := by
    rw [h]; trivial
  simp [chAtom, cassign] at hmem

/-- **Opposite CH branches, derived from the construction.**  Since the Boolean
value of CH is a proper nonzero element of the algebra, the branching theorem
supplies two generic quotients of one and the same Boolean-valued universe, one
satisfying CH and one refuting it.  Nothing about CH was assumed. -/
theorem CH_branches_derived (S : Finset Btn) (s : Sw) :
    ∃ U V : Generic (Set (Gen Sw)),
      sat (quot (cassign (Btn := Btn) S) U) (chAtom s) ∧
      ¬ sat (quot (cassign (Btn := Btn) S) V) (chAtom s) :=
  branch_of_undecided (rich_set _) _ _ (bval_ch_ne_bot S s) (bval_ch_ne_top S s)

/-- The two CH branches are realized by *control worlds*: at every stage both `CH`
and `¬CH` are accessible. -/
theorem CH_branches_in_frame (S : Finset Btn) (s : Sw) (g : Gen Sw) :
    dia cacc (fun w => csat w (chAtom s)) (S, g) ∧
    dia cacc (fun w => ¬ csat w (chAtom s)) (S, g) := by
  refine ⟨⟨(S, fun _ => true), subset_rfl, ?_⟩, ⟨(S, fun _ => false), subset_rfl, ?_⟩⟩
  · simpa [chAtom] using (csat_atom_sw S (fun _ => true) s).2 rfl
  · simp [chAtom, csat, atomTrue]

/-- **Packaged realization.**  One satisfaction relation — the Boolean-valued one —
for which every frame law (reflexivity, transitivity, directedness), the button
law, the switch law and both CH branch conditions hold. -/
theorem boolean_valued_realization [DecidableEq Btn] (s : Sw) (b : Btn) :
    Reflexive (cacc (Btn := Btn) (Sw := Sw)) ∧
    Transitive (cacc (Btn := Btn) (Sw := Sw)) ∧
    (∀ v₁ v₂ : CWorld Btn Sw, ∃ u, cacc v₁ u ∧ cacc v₂ u) ∧
    Button (cacc (Btn := Btn) (Sw := Sw)) (fun w => csat w (.atom (.btn b))) ∧
    Switch (cacc (Btn := Btn) (Sw := Sw)) (fun w => csat w (chAtom s)) ∧
    (∀ (S : Finset Btn) (g : Gen Sw) (p : BForm (CAtom Btn Sw)),
        csat (S, g) p ↔ g ∈ bval (cassign S) p) := by
  refine ⟨cacc_refl, cacc_trans, cacc_directed,
    button_of_pos (Pos.atom b), ?_, realization⟩
  intro w
  exact CH_branches_in_frame w.1 s w.2

end Realization

/-! ## Layer D — ground/extension bimodality -/

section Bimodal

variable {Btn Sw : Type*}

/-- The **ground** relation: `v` is a ground of `w` when it has pushed no more
buttons.  It is the converse of forcing accessibility. -/
def cgnd (w v : CWorld Btn Sw) : Prop := v.1 ⊆ w.1

theorem cgnd_refl : Reflexive (cgnd (Btn := Btn) (Sw := Sw)) := fun _ => subset_rfl

theorem cgnd_trans : Transitive (cgnd (Btn := Btn) (Sw := Sw)) :=
  fun _ _ _ h1 h2 => h2.trans h1

/-- Grounds are **downward directed**: two grounds of a world have a common ground,
the intersection of their pushed sets. -/
theorem cgnd_directed [DecidableEq Btn] (v₁ v₂ : CWorld Btn Sw) :
    ∃ u, cgnd v₁ u ∧ cgnd v₂ u :=
  ⟨(v₁.1 ∩ v₂.1, v₁.2), Finset.inter_subset_left, Finset.inter_subset_right⟩

/-- The **mantle**: the world with no button pushed is a ground of every world. -/
theorem mantle_least (w : CWorld Btn Sw) (g : Gen Sw) : cgnd w (∅, g) :=
  Finset.empty_subset _

/-- **Mixed validity.**  The tense axiom `p → □ ◇̌ p` ("whatever is true is, in
every forcing extension, true in some ground") is valid on the control frame,
because a world is a ground of each of its extensions. -/
theorem tense_axiom_valid (P : CWorld Btn Sw → Prop) (w : CWorld Btn Sw) (hp : P w) :
    box cacc (fun v => dia cgnd P v) w :=
  fun _ hwv => ⟨w, hwv, hp⟩

/-- **Separation of the bimodal logic from the extension-only logic.**  On one and
the same frame the mixed tense axiom `p → □ ◇̌ p` is valid while its unimodal
Brouwer analogue `p → □ ◇ p` fails.  Hence the ground modality genuinely adds
validities that the forcing modality alone cannot see. -/
theorem bimodal_separation (b : Btn) (g : Sw → Bool) :
    (∀ (P : CWorld Btn Sw → Prop) (w : CWorld Btn Sw), P w →
        box cacc (fun v => dia cgnd P v) w) ∧
    (∃ (P : CWorld Btn Sw → Prop) (w : CWorld Btn Sw),
        P w ∧ ¬ box cacc (dia cacc P) w) :=
  ⟨fun P w hp => tense_axiom_valid P w hp, brouwer_fails b g⟩

/-- Grounds see the mantle: from every world the button-free ground is reachable,
the multiverse-theoretic residue of the mantle being a common core. -/
theorem dia_gnd_mantle (w : CWorld Btn Sw) :
    dia cgnd (fun v => v.1 = ∅) w :=
  ⟨(∅, w.2), Finset.empty_subset _, rfl⟩

end Bimodal

end BooleanValuedRealization