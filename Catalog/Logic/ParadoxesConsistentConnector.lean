import Mathlib

/-!
# Paradoxes as Theorems: a Bridge between Boolean Algebra and Self-Reference

This self-contained file makes precise the slogan *"the Liar, Berry and Russell
paradoxes can all be **theorems** of a consistent formal system, but only if
classical (Boolean) logic is rejected."*

The mathematical content is a **cross-domain bridge**:

* On the *algebraic* side we work inside an arbitrary `BooleanAlgebra`, a purely
  order-theoretic / lattice object.
* On the *logical* side we study *self-negating* sentences — the abstract shape
  shared by the Liar (`this sentence is false`), Russell (`the set of all sets
  that do not contain themselves`) and Berry (`the least number not nameable in
  fewer than nineteen syllables`).  In every one of these, a sentence is
  equivalent to *its own negation*.

The connecting theorem `boolean_neg_fixpoint_trivial` says:

> In **any** Boolean algebra, a truth value equal to its own complement forces
> the algebra to collapse (`⊥ = ⊤`).

Contrapositively, a *nontrivial* Boolean algebra admits **no** negation
fixed point, so a consistent theory containing a self-negating (Liar-style)
sentence cannot be Boolean-valued.  Hence *paradoxes as theorems require
rejecting classical logic.*

We then exhibit the positive half: **Belnap's four-valued logic** `BV`
(`T`rue, `F`alse, `B`oth, `N`either) *does* have a designated negation
fixed point `B`, and we build an explicit six-sentence paraconsistent theory
in which three distinct paradox sentences (Liar / Russell / Berry) are all
provable *gluts* while the theory stays nontrivial and non-explosive.

Nothing here depends on any other project file; it imports only Mathlib.
-/

namespace ParadoxesConsistentConnector

/-! ## 1. The classical (Boolean) obstruction

The bridge theorem: any negation fixed point in a Boolean algebra trivialises it.
This is the algebraic core of *"the Liar is inconsistent classically."* -/

/-- **Bridge theorem (Boolean algebra ↔ self-reference).**
In every Boolean algebra, a truth value equal to its own complement collapses
the whole algebra to a single point (`⊥ = ⊤`).  Equivalently: no consistent
Boolean-valued theory can contain a Liar-style self-negating sentence. -/
theorem boolean_neg_fixpoint_trivial {α : Type*} [BooleanAlgebra α] (x : α)
    (h : xᶜ = x) : (⊥ : α) = ⊤ := by
  have h1 : x ⊓ xᶜ = ⊥ := inf_compl_eq_bot
  have h2 : x ⊔ xᶜ = ⊤ := sup_compl_eq_top
  rw [h] at h1 h2
  simp only [inf_idem, sup_idem] at h1 h2
  rw [← h1, ← h2]

/-- Contrapositive form: in a **nontrivial** Boolean algebra (where `⊥ ≠ ⊤`)
there is no negation fixed point.  A classical two-valued world cannot host a
Liar. -/
theorem no_boolean_neg_fixpoint {α : Type*} [BooleanAlgebra α] [Nontrivial α]
    (x : α) : xᶜ ≠ x := by
  intro h
  exact (bot_ne_top (α := α)) (boolean_neg_fixpoint_trivial x h)

/-- The concrete Liar at the level of `Prop`: no proposition is equivalent to its
own negation.  This is the classical reading of *"this sentence is false."* -/
theorem no_liar_prop (P : Prop) : ¬ (P ↔ ¬ P) := by
  intro h; tauto

/-- Classical **explosion**: once a proposition and its negation both hold, every
proposition follows.  This is exactly why the Liar cannot be a classical theorem
without trivialising the system. -/
theorem classical_explosion (P Q : Prop) (hp : P) (hn : ¬ P) : Q :=
  absurd hp hn

/-! ## 2. Belnap's four-valued algebra `BV`

To make paradoxes into theorems we move to a paraconsistent, four-valued setting.
`B` ("both true and false", a *glut*) and `N` ("neither", a *gap*) are the two
non-classical values. -/

/-- The four Belnap truth values. -/
inductive BV | T | F | B | N
deriving DecidableEq, Repr, Fintype

namespace BV

/-- Belnap negation: swaps `T`/`F` and fixes the non-classical values `B`, `N`. -/
def neg : BV → BV
  | T => F | F => T | B => B | N => N

/-- Designation: a value counts as *asserted / provable* iff it is at-least-true. -/
def des : BV → Bool
  | T => true | B => true | F => false | N => false

/-- Belnap conjunction (meet in the truth order `F ≤ N,B ≤ T`). -/
def conj : BV → BV → BV
  | T, x => x | x, T => x
  | F, _ => F | _, F => F
  | B, B => B | N, N => N
  | B, N => F | N, B => F

/-- Belnap disjunction (join in the truth order). -/
def disj : BV → BV → BV
  | F, x => x | x, F => x
  | T, _ => T | _, T => T
  | B, B => B | N, N => N
  | B, N => T | N, B => T

/-- Negation is an involution. -/
theorem neg_neg (v : BV) : neg (neg v) = v := by cases v <;> rfl

/-- De Morgan law (`¬(a ∧ b) = ¬a ∨ ¬b`) for the four-valued algebra. -/
theorem deMorgan_conj (a b : BV) : neg (conj a b) = disj (neg a) (neg b) := by
  cases a <;> cases b <;> rfl

/-- De Morgan law (`¬(a ∨ b) = ¬a ∧ ¬b`) for the four-valued algebra. -/
theorem deMorgan_disj (a b : BV) : neg (disj a b) = conj (neg a) (neg b) := by
  cases a <;> cases b <;> rfl

/-- **Glut characterization.** A value is *both provable and its negation is
provable* exactly when it is the glut `B`.  This is the semantic signature of a
paradox: a sentence and its negation are simultaneously asserted. -/
theorem glut_iff (v : BV) : (des v = true ∧ des (neg v) = true) ↔ v = B := by
  cases v <;> simp [des, neg]

/-- **Belnap admits a designated negation fixed point** — the precise algebraic
fact that fails for every nontrivial Boolean algebra (`no_boolean_neg_fixpoint`).
This single value `B` is what turns the Liar into a theorem. -/
theorem has_designated_neg_fixpoint : ∃ v : BV, neg v = v ∧ des v = true :=
  ⟨B, rfl, rfl⟩

end BV

/-! ## 3. An explicit consistent paraconsistent theory

We package a "formal system" as a valuation of sentences into `BV` together with
a syntactic negation that is *coherent* with Belnap negation.  Provability means
the sentence is designated. -/

open BV

/-- A paraconsistent theory over a sentence type `S`: a truth-value assignment,
a syntactic negation, and a coherence condition tying them together. -/
structure ParaTheory (S : Type) where
  /-- Truth value of each sentence. -/
  val : S → BV
  /-- Syntactic negation of each sentence. -/
  sneg : S → S
  /-- Syntactic negation realizes Belnap negation on truth values. -/
  coherent : ∀ s, val (sneg s) = neg (val s)

/-- A sentence is *provable* iff its truth value is designated. -/
def ParaTheory.prov {S} (M : ParaTheory S) (s : S) : Prop := des (M.val s) = true

/-- A sentence is a *glut* (a genuine paradox) iff both it and its negation are
provable. -/
def ParaTheory.glut {S} (M : ParaTheory S) (s : S) : Prop :=
  M.prov s ∧ M.prov (M.sneg s)

instance {S} (M : ParaTheory S) (s : S) : Decidable (M.prov s) := by
  unfold ParaTheory.prov; infer_instance

/-- **Self-soundness (theorem schema).** In any coherent theory, a sentence is a
glut precisely when its truth value is `B`; hence gluts are exactly the sentences
witnessing genuine paradox. -/
theorem ParaTheory.glut_iff_B {S} (M : ParaTheory S) (s : S) :
    M.glut s ↔ M.val s = B := by
  unfold ParaTheory.glut ParaTheory.prov
  rw [M.coherent s]
  exact BV.glut_iff (M.val s)

/-! ### The six-sentence witness model

Sentences `0,1,2` are the three paradox witnesses (Liar / Russell / Berry),
each a self-negation fixed point valued `B`.  Sentence `3` is a genuine truth,
`4` a genuine falsehood (the non-explosion witness), `5` a gap. -/

/-- Truth-value assignment: three gluts, one truth, one falsehood, one gap. -/
def paradoxVal : Fin 6 → BV := ![B, B, B, T, F, N]

/-- Syntactic negation: the three paradox sentences are fixed points; `3`/`4`
swap; the gap `5` is fixed. -/
def paradoxNeg : Fin 6 → Fin 6 := ![0, 1, 2, 4, 3, 5]

/-- The explicit six-sentence paraconsistent theory. -/
def paradoxModel : ParaTheory (Fin 6) where
  val := paradoxVal
  sneg := paradoxNeg
  coherent := by decide

/-- **Liar, Russell, Berry are all theorems.** The three distinct paradox
sentences are simultaneously provable gluts. -/
theorem three_paradoxes_are_theorems :
    (0 : Fin 6) ≠ 1 ∧ (0 : Fin 6) ≠ 2 ∧ (1 : Fin 6) ≠ 2 ∧
      paradoxModel.glut 0 ∧ paradoxModel.glut 1 ∧ paradoxModel.glut 2 := by
  refine ⟨by decide, by decide, by decide, ?_, ?_, ?_⟩ <;>
    exact ⟨by decide, by decide⟩

/-- **Nontriviality.** Not every sentence is provable: sentence `4` is not. -/
theorem paradoxModel_nontrivial : ¬ paradoxModel.prov 4 := by decide

/-- **Non-explosion.** Even though gluts are present, provability does not spread
to every sentence — there is an unprovable sentence.  This is the failure of *ex
contradictione quodlibet* that distinguishes the paraconsistent theory from a
classical one. -/
theorem paradoxModel_non_explosion :
    paradoxModel.glut 0 ∧ ∃ s, ¬ paradoxModel.prov s :=
  ⟨⟨by decide, by decide⟩, ⟨4, by decide⟩⟩

/-! ## 4. The dichotomy, stated in one place

Putting the two sides of the bridge together. -/

/-- **Main connector theorem.**  The property *"there is a designated truth value
equal to its own negation"* — i.e. a consistent Liar — **holds** in Belnap's
four-valued logic yet **fails** in every nontrivial Boolean algebra.  Thus
turning the paradoxes into theorems is possible exactly by leaving classical
logic. -/
theorem liar_needs_nonclassical :
    (∃ v : BV, BV.neg v = v ∧ BV.des v = true) ∧
    (∀ (α : Type) [BooleanAlgebra α] [Nontrivial α] (x : α), xᶜ ≠ x) := by
  refine ⟨BV.has_designated_neg_fixpoint, ?_⟩
  intro α _ _ x
  exact no_boolean_neg_fixpoint x

end ParadoxesConsistentConnector