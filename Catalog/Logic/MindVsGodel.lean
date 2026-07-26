import Mathlib

/-!
# Mind, diagonal sentences, and description limits

This file isolates the mathematical core shared by Gödel's sentence, the
Lucas–Penrose discussion, Chaitin-style incompressibility, and Berry-style
naming paradoxes. No claim about the empirical powers of human minds is
assumed: the results apply uniformly to any proposed recognizer.
-/

namespace MindVsGodel

/-- A minimal semantic interface for a system discussing coded sentences.
`accepts c` means that the system recognizes code `c`; `trueAt c` is its
intended semantic truth predicate. -/
structure SemanticSystem (Code : Type*) where
  accepts : Code → Prop
  trueAt : Code → Prop

namespace SemanticSystem

variable {Code : Type*} (S : SemanticSystem Code)

/-- A code is Gödelian for a system when its truth says exactly that the
system does not accept that very code. -/
def IsGodelCode (g : Code) : Prop := S.trueAt g ↔ ¬ S.accepts g

/-- Semantic soundness: every accepted sentence is true. -/
def Sound : Prop := ∀ c, S.accepts c → S.trueAt c

/-- Semantic completeness: every true sentence is accepted. -/
def Complete : Prop := ∀ c, S.trueAt c → S.accepts c

/-- A sound system cannot recognize one of its own Gödel sentences. -/
theorem sound_rejects_own_godel {g : Code} (hdiag : S.IsGodelCode g)
    (hsound : S.Sound) : ¬ S.accepts g := by
  intro haccept
  exact (hdiag.mp (hsound g haccept)) haccept

/-- Under soundness, the system's Gödel sentence is true but unrecognized. -/
theorem godel_truth_and_unrecognizability {g : Code} (hdiag : S.IsGodelCode g)
    (hsound : S.Sound) : S.trueAt g ∧ ¬ S.accepts g := by
  have hrejected := sound_rejects_own_godel S hdiag hsound
  exact ⟨hdiag.mpr hrejected, hrejected⟩

/-- No semantically sound and complete system can contain a Gödel code for
its own acceptance predicate. This is the precise obstruction behind the
claim that one fixed algorithm consistently recognizes all such truths. -/
theorem no_sound_complete_self_recognizer {g : Code} (hdiag : S.IsGodelCode g) :
    ¬ (S.Sound ∧ S.Complete) := by
  rintro ⟨hsound, hcomplete⟩
  obtain ⟨htrue, hrejected⟩ := godel_truth_and_unrecognizability S hdiag hsound
  exact hrejected (hcomplete g htrue)

/-- Accepting one's own Gödel sentence is incompatible with soundness. Thus
"consistently recognizing" it cannot mean merely adding it to the accepted
set while retaining the same self-referential interpretation. -/
theorem own_godel_acceptance_implies_unsound {g : Code}
    (hdiag : S.IsGodelCode g) (haccept : S.accepts g) : ¬ S.Sound := by
  intro hsound
  exact (sound_rejects_own_godel S hdiag hsound) haccept

end SemanticSystem

section Chaitin

/-- A finite Chaitin-style counting theorem: when there are `m` programs and
`n` possible outputs with `m < n`, some output has no program producing it.
This is the finite combinatorial core of incompressibility arguments. -/
theorem exists_incompressible_output {m n : ℕ} (h : m < n)
    (machine : Fin m → Fin n) : ∃ output : Fin n, ∀ program : Fin m,
      machine program ≠ output := by
  by_contra! hall
  have hsurj : Function.Surjective machine := by
    intro output
    obtain ⟨program, hp⟩ := hall output
    exact ⟨program, hp⟩
  have hcard := Fintype.card_le_of_surjective machine hsurj
  simp only [Fintype.card_fin] at hcard
  exact (Nat.not_le_of_lt h) hcard

/-- For every bit budget `k`, a machine with `2^k` programs misses some value
among `2^k + 1` targets. -/
theorem chaitin_bit_budget (k : ℕ) (machine : Fin (2 ^ k) → Fin (2 ^ k + 1)) :
    ∃ output : Fin (2 ^ k + 1), ∀ program : Fin (2 ^ k),
      machine program ≠ output := by
  exact exists_incompressible_output (Nat.lt_succ_self (2 ^ k)) machine

end Chaitin

section Berry

/-- A finite Berry-style naming theorem: fewer admissible descriptions than
objects forces an unnamed object, independently of how descriptions denote. -/
theorem berry_unnamed_object {Descriptions Objects : Type*}
    [Fintype Descriptions] [Fintype Objects]
    (hcard : Fintype.card Descriptions < Fintype.card Objects)
    (denotes : Descriptions → Objects) :
    ∃ x : Objects, ∀ d : Descriptions, denotes d ≠ x := by
  by_contra! hall
  have hsurj : Function.Surjective denotes := by
    intro x
    obtain ⟨d, hd⟩ := hall x
    exact ⟨d, hd⟩
  exact (Nat.not_le_of_lt hcard) (Fintype.card_le_of_surjective denotes hsurj)

/-- If `x` is not denoted by any admissible description, then any purported
admissible description denoting `x` yields a contradiction. This identifies
Berry's key boundary: the metalanguage phrase selecting an unnamed object
cannot simultaneously be admitted as a name in the same correct scheme. -/
theorem berry_selector_not_internalizable {Description Object : Type*}
    (denotes : Description → Object) (x : Object)
    (hunnamed : ∀ d, denotes d ≠ x) : ¬ ∃ d, denotes d = x := by
  exact fun ⟨ d, hd ⟩ => hunnamed d hd

end Berry

end MindVsGodel