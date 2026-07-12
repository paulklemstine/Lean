import Mathlib.Logic.Function.Basic
import Mathlib.Data.Set.Finite.Basic
import Mathlib.Data.Set.Insert
import Mathlib.Data.Set.Image
import Mathlib.Order.Basic
import Mathlib.Tactic.Common

/-!
# Mind Tools — Mathematics as Cognitive Extension (foundations)

This file gives a self-contained formal model of Rudy Rucker's notion of a
**mind tool**: a mathematical/formal structure that *extends* what a cognitive
agent can reach beyond what it can directly apprehend.

## The model

We work with an abstract space of `Statement`s.  We model a statement as a
*property of natural numbers* (`Set ℕ`); nothing below depends on this choice
except the incompleteness results, which use that the space of statements is
uncountable.  This is the "second-order arithmetic truth" reading: statements
are arbitrary predicates on the naturals.

A `FormalSystem` is identified with the set of statements it proves (its
theorems).  This is the extensional / Lindenbaum view of a theory.

* `LePow F G`  (`F ≼ G`) — *`G` is at least as powerful as `F`*: every theorem
  of `F` is a theorem of `G`.
* `LtPow F G`  (`F ≺ G`) — *`G` is strictly more powerful than `F`*.
* `Enumerable F` — the theorems of `F` can be listed by a function `ℕ → Statement`.
  This models "directly apprehensible / recursively enumerable" knowledge: a
  finite mind, or a finite axiomatization with a recursively enumerable proof
  system, only ever reaches countably many statements.
* `IsMindTool B F` — relative to a *brain* `B`, the system `F` is a mind tool
  iff it strictly extends `B` (`B ≺ F`): it proves things the brain does not.

The order-theoretic lemmas here (`≼` is a partial order, `≺` is a strict order,
incomparable systems exist) are used by the other files in this directory.
-/

namespace MindTools

/-- The space of statements.  A statement is modelled as a property of natural
numbers.  The only feature of this choice used below is that `Set ℕ` is
uncountable (Cantor), which drives the incompleteness phenomena. -/
abbrev Statement := Set ℕ

/-- A formal system, identified with the set of statements it proves. -/
@[ext]
structure FormalSystem where
  /-- The theorems of the system. -/
  Thm : Set Statement

/-- `F ≼ G`: `G` is at least as powerful as `F` — every theorem of `F` is a
theorem of `G`. -/
def LePow (F G : FormalSystem) : Prop := F.Thm ⊆ G.Thm

/-- `F ≺ G`: `G` is strictly more powerful than `F`. -/
def LtPow (F G : FormalSystem) : Prop := F.Thm ⊂ G.Thm

@[inherit_doc] scoped infix:50 " ≼ " => LePow
@[inherit_doc] scoped infix:50 " ≺ " => LtPow

/-- A system is *enumerable* when its theorems can be listed by a function
`ℕ → Statement`.  This is our formal stand-in for "directly apprehensible":
a recursively enumerable theory, or a finite mind, reaches only countably many
statements. -/
def Enumerable (F : FormalSystem) : Prop :=
  ∃ e : ℕ → Statement, F.Thm ⊆ Set.range e

/-- Relative to a brain `B`, a system `F` is a **mind tool** when it proves
strictly more than the brain can: `B ≺ F`. -/
def IsMindTool (B F : FormalSystem) : Prop := B ≺ F

/-- The complete, sound system: it proves every statement.  (Sound only in the
degenerate sense that "everything is true"; used as the ceiling of the
hierarchy.) -/
def Complete : FormalSystem := ⟨Set.univ⟩

/-- The empty system, proving nothing. -/
def Trivial : FormalSystem := ⟨∅⟩

/-! ### `≼` is a partial order -/

theorem lePow_refl (F : FormalSystem) : F ≼ F := le_refl _

theorem lePow_trans {F G H : FormalSystem} (h₁ : F ≼ G) (h₂ : G ≼ H) : F ≼ H :=
  subset_trans h₁ h₂

theorem lePow_antisymm {F G : FormalSystem} (h₁ : F ≼ G) (h₂ : G ≼ F) : F = G :=
  FormalSystem.ext (Set.Subset.antisymm h₁ h₂)

/-! ### `≺` is a strict order compatible with `≼` -/

theorem ltPow_iff {F G : FormalSystem} : F ≺ G ↔ F ≼ G ∧ ¬ G ≼ F :=
  ssubset_iff_subset_not_subset

theorem ltPow_irrefl (F : FormalSystem) : ¬ F ≺ F :=
  ssubset_irrefl _

theorem ltPow_trans {F G H : FormalSystem} (h₁ : F ≺ G) (h₂ : G ≺ H) : F ≺ H :=
  ssubset_trans h₁ h₂

theorem ltPow_asymm {F G : FormalSystem} (h : F ≺ G) : ¬ G ≺ F := by
  intro h'; exact ltPow_irrefl F (ltPow_trans h h')

theorem LtPow.lePow {F G : FormalSystem} (h : F ≺ G) : F ≼ G := h.subset

/-- A mind tool relative to `B` is transitive: a mind tool over a mind tool over
`B` is a mind tool over `B`. -/
theorem IsMindTool.trans {B F G : FormalSystem}
    (h₁ : IsMindTool B F) (h₂ : IsMindTool F G) : IsMindTool B G :=
  ltPow_trans h₁ h₂

/-- No system is a mind tool relative to itself: genuine cognitive extension is
irreflexive. -/
theorem not_isMindTool_self (F : FormalSystem) : ¬ IsMindTool F F :=
  ltPow_irrefl F

end MindTools