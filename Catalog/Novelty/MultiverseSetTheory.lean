/-
# Multiverse Set Theory — Mathematics Across Branches

A self-contained formalization of the *combinatorial core* of Hamkins'
set-theoretic multiverse.

We abstract a "model of ZFC" to a **world**: a truth assignment `α → Bool` on a
type `α` of atomic set-theoretic assertions (e.g. `CH`, `V = L`, "there is a
measurable cardinal").  A **sentence** is a propositional combination of atoms; a
**multiverse** is a collection of worlds.  A sentence is **independent** in a
multiverse when it is true in some world and false in another — the phenomenon
witnessed for `CH` by forcing.

**Forcing** is modeled by `flip`, which toggles the truth value of an atom,
producing a "generic extension" deciding the atom the other way.  A multiverse is
**forcing-closed** when stable under all flips (an abstraction of the multiverse
axioms).  Highlights:

* `forcingClosed_atom_independent` — in a nonempty forcing-closed multiverse
  **every** atomic sentence is independent (nothing is settled by forcing);
* `CH_independent` — in the concrete two-world multiverse `{Gödel, Cohen}`, the
  Continuum Hypothesis is independent;
* `CH_independent_under_VeqL_imp_CH` — even after adopting `V = L → CH` as a law
  of the multiverse, `CH` remains independent;
* `absolute_em` / `absolute_noncontradiction` — logical validities hold across
  *all* branches, in contrast to `CH`.

Everything is proved from first principles over `Mathlib`.
-/
import Mathlib

namespace MultiverseSetTheory

/-! ## Sentences, worlds, evaluation -/

/-- Propositional set-theoretic sentences over a type `α` of atomic assertions. -/
inductive Sentence (α : Type*) where
  | atom : α → Sentence α
  | tru : Sentence α
  | fls : Sentence α
  | neg : Sentence α → Sentence α
  | conj : Sentence α → Sentence α → Sentence α
  | disj : Sentence α → Sentence α → Sentence α
  | imp : Sentence α → Sentence α → Sentence α
  deriving DecidableEq

/-- A `World` (a model of the ambient set theory) is a truth assignment to atoms. -/
abbrev World (α : Type*) := α → Bool

/-- Boolean evaluation of a sentence in a world. -/
def eval {α} (w : World α) : Sentence α → Bool
  | .atom a => w a
  | .tru => true
  | .fls => false
  | .neg p => !(eval w p)
  | .conj p q => eval w p && eval w q
  | .disj p q => eval w p || eval w q
  | .imp p q => !(eval w p) || eval w q

/-- Satisfaction: world `w` models sentence `p`. -/
def Sat {α} (w : World α) (p : Sentence α) : Prop := eval w p = true

/-- A **multiverse** is a collection of worlds. -/
abbrev Multiverse (α : Type*) := Set (World α)

/-- `p` is **valid** across the multiverse `M` (true in every world). -/
def Valid {α} (M : Multiverse α) (p : Sentence α) : Prop := ∀ w ∈ M, Sat w p

/-- `p` is **refutable** across `M` (false in every world). -/
def Refutable {α} (M : Multiverse α) (p : Sentence α) : Prop := ∀ w ∈ M, ¬ Sat w p

/-- `p` is **independent** in `M`: true in some world and false in another. -/
def Independent {α} (M : Multiverse α) (p : Sentence α) : Prop :=
  (∃ w ∈ M, Sat w p) ∧ (∃ w ∈ M, ¬ Sat w p)

/-- `p` is **settled** in `M` if it is valid or refutable there. -/
def Settled {α} (M : Multiverse α) (p : Sentence α) : Prop :=
  Valid M p ∨ Refutable M p

/-! ## Basic satisfaction lemmas -/

@[simp] theorem Sat_atom {α} (w : World α) (a : α) : Sat w (.atom a) ↔ w a = true := Iff.rfl

@[simp] theorem Sat_tru {α} (w : World α) : Sat w (.tru : Sentence α) := rfl

@[simp] theorem not_Sat_fls {α} (w : World α) : ¬ Sat w (.fls : Sentence α) := by
  simp [Sat, eval]

@[simp] theorem Sat_neg {α} (w : World α) (p : Sentence α) : Sat w (.neg p) ↔ ¬ Sat w p := by
  simp [Sat, eval]

@[simp] theorem Sat_conj {α} (w : World α) (p q : Sentence α) :
    Sat w (.conj p q) ↔ Sat w p ∧ Sat w q := by
  simp [Sat, eval]

@[simp] theorem Sat_disj {α} (w : World α) (p q : Sentence α) :
    Sat w (.disj p q) ↔ Sat w p ∨ Sat w q := by
  simp [Sat, eval]

@[simp] theorem Sat_imp {α} (w : World α) (p q : Sentence α) :
    Sat w (.imp p q) ↔ (Sat w p → Sat w q) := by
  simp only [Sat, eval]; cases eval w p <;> cases eval w q <;> simp

/-! ## Logical validity is absolute across every multiverse -/

/-- Excluded middle holds in every world, hence across every multiverse. -/
theorem absolute_em {α} (M : Multiverse α) (p : Sentence α) : Valid M (.disj p (.neg p)) := by
  intro w _; simp only [Sat_disj, Sat_neg]; tauto

/-- Non-contradiction holds across every multiverse. -/
theorem absolute_noncontradiction {α} (M : Multiverse α) (p : Sentence α) :
    Valid M (.neg (.conj p (.neg p))) := by
  intro w _; simp

/-- Self-implication holds across every multiverse. -/
theorem absolute_self_imp {α} (M : Multiverse α) (p : Sentence α) : Valid M (.imp p p) := by
  intro w _; simp

/-! ## Interaction of validity, refutability and independence -/

/-- An independent sentence is not valid. -/
theorem Independent.not_valid {α} {M : Multiverse α} {p : Sentence α}
    (h : Independent M p) : ¬ Valid M p := by
  obtain ⟨_, w, hw, hns⟩ := h; intro hv; exact hns (hv w hw)

/-- An independent sentence is not refutable. -/
theorem Independent.not_refutable {α} {M : Multiverse α} {p : Sentence α}
    (h : Independent M p) : ¬ Refutable M p := by
  obtain ⟨⟨w, hw, hs⟩, _⟩ := h; intro hr; exact hr w hw hs

/-- An independent sentence is not settled. -/
theorem Independent.not_settled {α} {M : Multiverse α} {p : Sentence α}
    (h : Independent M p) : ¬ Settled M p := by
  rintro (hv | hr)
  · exact h.not_valid hv
  · exact h.not_refutable hr

/-- A valid sentence is never independent. -/
theorem Valid.not_independent {α} {M : Multiverse α} {p : Sentence α}
    (h : Valid M p) : ¬ Independent M p := fun hi => hi.not_valid h

/-- Independence is symmetric under negation. -/
theorem Independent_neg {α} {M : Multiverse α} {p : Sentence α} :
    Independent M (.neg p) ↔ Independent M p := by
  unfold Independent; simp only [Sat_neg]; tauto

/-! ## Forcing: toggling the truth value of an atom -/

/-- The "generic extension" of a world along atom `a`: flip the truth value of `a`. -/
def flip {α} [DecidableEq α] (w : World α) (a : α) : World α :=
  fun x => if x = a then !(w x) else w x

@[simp] theorem flip_self {α} [DecidableEq α] (w : World α) (a : α) :
    flip w a a = !(w a) := by
  simp [flip]

theorem flip_other {α} [DecidableEq α] (w : World α) {a x : α} (h : x ≠ a) :
    flip w a x = w x := by
  simp [flip, h]

@[simp] theorem eval_flip_atom {α} [DecidableEq α] (w : World α) (a : α) :
    eval (flip w a) (.atom a) = !(eval w (.atom a)) := by
  simp [eval]

/-- `flip` genuinely changes satisfaction of the atom it targets. -/
theorem Sat_flip_atom_iff {α} [DecidableEq α] (w : World α) (a : α) :
    Sat (flip w a) (.atom a) ↔ ¬ Sat w (.atom a) := by
  simp [Sat, eval]

/-- A multiverse is **forcing-closed** if it is stable under generic extensions
    (flipping any atom in any of its worlds). This abstracts the multiverse axiom
    that every universe has forcing extensions realizing the opposite of any
    forceable statement. -/
def ForcingClosed {α} [DecidableEq α] (M : Multiverse α) : Prop :=
  ∀ w ∈ M, ∀ a : α, flip w a ∈ M

/-- **Headline theorem.** In a nonempty forcing-closed multiverse, *every* atomic
    sentence is independent: forcing settles nothing. -/
theorem forcingClosed_atom_independent {α} [DecidableEq α] {M : Multiverse α}
    (hne : M.Nonempty) (hfc : ForcingClosed M) (a : α) : Independent M (.atom a) := by
  obtain ⟨w, hw⟩ := hne
  have hf : flip w a ∈ M := hfc w hw a
  cases h : w a with
  | true =>
    exact ⟨⟨w, hw, by simp [Sat, eval, h]⟩, ⟨flip w a, hf, by simp [Sat, eval, h]⟩⟩
  | false =>
    exact ⟨⟨flip w a, hf, by simp [Sat, eval, h]⟩, ⟨w, hw, by simp [Sat, eval, h]⟩⟩

/-- Consequently no atom is settled in a nonempty forcing-closed multiverse. -/
theorem forcingClosed_atom_not_settled {α} [DecidableEq α] {M : Multiverse α}
    (hne : M.Nonempty) (hfc : ForcingClosed M) (a : α) : ¬ Settled M (.atom a) :=
  (forcingClosed_atom_independent hne hfc a).not_settled

/-! ## The full multiverse -/

/-- The **full multiverse**: every conceivable world. -/
def full (α : Type*) : Multiverse α := Set.univ

theorem full_nonempty (α : Type*) [Nonempty (World α)] : (full α).Nonempty :=
  Set.univ_nonempty

theorem full_forcingClosed {α} [DecidableEq α] : ForcingClosed (full α) := by
  intro w _ a; trivial

/-- Every atom is independent in the full multiverse. -/
theorem full_atom_independent {α} [DecidableEq α] (a : α) :
    Independent (full α) (.atom a) :=
  forcingClosed_atom_independent Set.univ_nonempty full_forcingClosed a

/-- Two distinct atoms have *all four* joint truth values realized in the full
    multiverse: the Boolean combination `a ∧ ¬b` has a model. -/
theorem full_conj_neg_independent {α} [DecidableEq α] {a b : α} (hab : a ≠ b) :
    Independent (full α) (.conj (.atom a) (.neg (.atom b))) := by
  refine ⟨⟨fun x => decide (x = a), trivial, ?_⟩, ⟨fun _ => false, trivial, ?_⟩⟩
  · simp [Sat, eval, Ne.symm hab]
  · simp [Sat, eval]

/-! ## Cardinality of a finite multiverse -/

/-- The full multiverse over `n` atomic sentences has exactly `2^n` worlds. -/
theorem card_worlds (α : Type*) [Fintype α] [DecidableEq α] :
    Fintype.card (World α) = 2 ^ Fintype.card α := by
  simp

/-! ## A concrete instance: CH, V = L and a measurable cardinal -/

/-- Three atomic set-theoretic assertions. -/
inductive Claim
  | CH      -- the Continuum Hypothesis
  | VeqL    -- the axiom of constructibility `V = L`
  | Meas    -- "there exists a measurable cardinal"
  deriving DecidableEq, Fintype

open Claim

/-- Gödel's constructible universe `L`: satisfies `V = L`, hence `CH`, and has no
    measurable cardinal. -/
def godel : World Claim
  | CH => true
  | VeqL => true
  | Meas => false

/-- A Cohen forcing extension in which `CH` fails (so `V = L` fails as well). -/
def cohen : World Claim
  | CH => false
  | VeqL => false
  | Meas => false

/-- The two-world multiverse `{Gödel, Cohen}`. -/
def GC : Multiverse Claim := {godel, cohen}

/-- **The Continuum Hypothesis is independent** in the multiverse `{Gödel, Cohen}`:
    true in Gödel's `L`, false in the Cohen extension. -/
theorem CH_independent : Independent GC (.atom CH) := by
  refine ⟨⟨godel, Set.mem_insert _ _, ?_⟩, ⟨cohen, Set.mem_insert_of_mem _ rfl, ?_⟩⟩
  · rfl
  · simp [Sat, eval, cohen]

/-- `V = L` is likewise independent in `{Gödel, Cohen}`. -/
theorem VeqL_independent : Independent GC (.atom VeqL) :=
  ⟨⟨godel, Set.mem_insert _ _, rfl⟩,
    ⟨cohen, Set.mem_insert_of_mem _ rfl, by simp [Sat, eval, cohen]⟩⟩

/-- The implication `V = L → CH` is **valid** across `{Gödel, Cohen}`: unlike `CH`
    itself, it is a settled truth of this multiverse. -/
theorem VeqL_imp_CH_valid : Valid GC (.imp (.atom VeqL) (.atom CH)) := by
  intro w hw
  rcases hw with h | h <;> subst h <;> simp [Sat, eval, godel, cohen]

/-- The multiverse of worlds obeying the law `V = L → CH`. -/
def LawMV : Multiverse Claim := {w | Sat w (.imp (.atom VeqL) (.atom CH))}

theorem godel_mem_LawMV : godel ∈ LawMV := by simp [LawMV, Sat, eval, godel]

theorem cohen_mem_LawMV : cohen ∈ LawMV := by simp [LawMV, Sat, eval, cohen]

/-- **CH stays independent even after adopting `V = L → CH` as a law** of the
    multiverse: restricting to worlds that obey the implication does not settle
    `CH`.  (Both Gödel and Cohen obey the law yet disagree on `CH`.) -/
theorem CH_independent_under_VeqL_imp_CH : Independent LawMV (.atom CH) :=
  ⟨⟨godel, godel_mem_LawMV, rfl⟩,
    ⟨cohen, cohen_mem_LawMV, by simp [Sat, eval, cohen]⟩⟩

/-- In the full multiverse over `{CH, V=L, Meas}`, the conjunction
    `CH ∧ ¬(V = L)` — witnessed by Cohen-style forcing adding non-constructible
    reals while forcing `CH` — has a model. -/
theorem CH_and_not_VeqL_has_model :
    Independent (full Claim) (.conj (.atom CH) (.neg (.atom VeqL))) :=
  full_conj_neg_independent (by decide)

/-- The full multiverse over the three atoms has exactly `8` worlds. -/
theorem card_full_Claim : Fintype.card (World Claim) = 8 := by decide

end MultiverseSetTheory