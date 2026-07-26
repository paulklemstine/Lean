import Mathlib
import Bridges.ProbabilityAndStochastics.LibraryOfBabel

/-!
# Finite truth tables and the boundary of diagonal arguments

A bounded language over a finite alphabet has an exact finite truth oracle.  This
chapter separates that fact from two genuinely different impossibility results:
no predictor works uniformly for every semantics, and no countable table of
Boolean sequences exhausts all Boolean sequences.  A finite diagonal theorem
also shows precisely what remains of Cantor's argument on a square finite table.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): exact truth on a fixed finite language is compatible
with both adversarial failure under varying semantics and diagonal escape from
an indexed family; the quantifier order and the size of the index set determine
which conclusion is valid.
Experiment (Experimenter): words were identified with the existing finite-word
model, exact and adversarial oracles were evaluated pointwise, and diagonal
complements were tested on square Boolean matrices and infinite Boolean tables.
Analysis (Analyst): finiteness defeats a noncomputability claim for a fixed
bounded language, but not the uniform claim `there exists one oracle for every
semantics`.  Diagonalization concerns surjectivity of a family onto a function
space, not the practical size of a finite truth table.
Critique (Critic): unknown answers are explicitly scored as incorrect.  The
infinite diagonal is a theorem about arbitrary Boolean sequences, not a claim
that a concrete Turing jump has been constructed.  The 95-percent statement is
proved through exact pointwise correctness rather than an unstated distribution.
Synthesis (Principal Investigator): exact finite tabulation, adversarial
quantifier reversal, finite diagonal escape, and countable diagonal escape give
a single hierarchy of sharply delimited claims.
-- !-- end Lab Notes -- !--
-/

namespace FiniteTruthDiagonal

/-- A statement is a fixed-length word in the established finite library model. -/
abbrev Statement (alphabet length : ℕ) := LibraryOfBabel.Word alphabet length

/-- Answers may assert truth, assert falsity, or abstain. -/
inductive Answer where
  | yes | no | unknown
  deriving DecidableEq, Fintype

/-- Definite answers embed Boolean truth values. -/
def answerOfBool : Bool → Answer
  | true => .yes
  | false => .no

/-- Correctness counts abstention as failure. -/
def Correct {α : Type*} (truth : α → Bool) (oracle : α → Answer) (x : α) : Prop :=
  oracle x = answerOfBool (truth x)

instance {α : Type*} (truth : α → Bool) (oracle : α → Answer) :
    DecidablePred (Correct truth oracle) := fun x => by
  unfold Correct
  infer_instance

/-- Number of correctly answered inputs on a finite domain. -/
def correctCount {α : Type*} [Fintype α] (truth : α → Bool) (oracle : α → Answer) : ℕ :=
  (Finset.univ.filter (Correct truth oracle)).card

/-- The exact oracle is correct pointwise. -/
lemma exactOracle_correct {α : Type*} (truth : α → Bool) (x : α) :
    Correct truth (fun y => answerOfBool (truth y)) x := by
  unfold Correct
  rfl

/-- An exact oracle answers every element of a finite domain correctly. -/
lemma exactOracle_count {α : Type*} [Fintype α] (truth : α → Bool) :
    correctCount truth (fun x => answerOfBool (truth x)) = Fintype.card α := by
  unfold correctCount
  rw [Finset.filter_eq_self.mpr]
  · exact Finset.card_univ
  · intro x hx
    exact exactOracle_correct truth x

/-- Every fixed semantics on a finite bounded language has an oracle meeting a
95-percent benchmark; indeed the witness is exact on every statement. -/
theorem finite_language_has_accurate_oracle (alphabet length : ℕ)
    (truth : Statement alphabet length → Bool) :
    ∃ oracle : Statement alphabet length → Answer,
      95 * Fintype.card (Statement alphabet length) ≤
        100 * correctCount truth oracle := by
  refine ⟨fun x => answerOfBool (truth x), ?_⟩
  rw [exactOracle_count]
  omega

/-- Every oracle on the bounded language is represented by its finite graph. -/
theorem finite_oracle_has_table (alphabet length : ℕ)
    (oracle : Statement alphabet length → Answer) :
    ∃ table : List (Statement alphabet length × Answer),
      ∀ x, (x, oracle x) ∈ table := by
  classical
  refine ⟨Finset.univ.toList.map (fun x => (x, oracle x)), ?_⟩
  intro x
  rw [List.mem_map]
  exact ⟨x, by simp, rfl⟩

/-- The adversarial semantics reverses every definite prediction and assigns a
fixed truth value to abstention. -/
def adversarialTruth {α : Type*} (oracle : α → Answer) (x : α) : Bool :=
  match oracle x with
  | .yes => false
  | .no => true
  | .unknown => true

/-- An answer is never correct against the semantics chosen adversarially from it. -/
lemma adversarial_incorrect {α : Type*} (oracle : α → Answer) (x : α) :
    ¬ Correct (adversarialTruth oracle) oracle x := by
  unfold Correct adversarialTruth
  cases h : oracle x <;> simp [answerOfBool]

/-- On a nonempty finite language, no single oracle reaches 95 percent against
every Boolean semantics.  The conclusion exposes the reversed quantifier order. -/
theorem no_uniform_accurate_oracle {α : Type*} [Fintype α] [Nonempty α] :
    ¬ ∃ oracle : α → Answer, ∀ truth : α → Bool,
      95 * Fintype.card α ≤ 100 * correctCount truth oracle := by
  rintro ⟨oracle, hall⟩
  have hzero : correctCount (adversarialTruth oracle) oracle = 0 := by
    unfold correctCount
    have hempty : Finset.univ.filter (Correct (adversarialTruth oracle) oracle) = ∅ :=
      Finset.filter_eq_empty_iff.mpr (fun x _ => adversarial_incorrect oracle x)
    rw [hempty]
    rfl
  specialize hall (adversarialTruth oracle)
  rw [hzero] at hall
  have hcard : 0 < Fintype.card α := Fintype.card_pos
  omega

/-- Complement the diagonal of a finite square Boolean table. -/
def finiteDiagonal {n : ℕ} (rows : Fin n → Fin n → Bool) : Fin n → Bool :=
  fun i => !(rows i i)

/-- The finite diagonal differs from every row at that row's own coordinate. -/
theorem finiteDiagonal_ne_row {n : ℕ} (rows : Fin n → Fin n → Bool) (i : Fin n) :
    finiteDiagonal rows ≠ rows i := by
  intro h
  have hi := congrFun h i
  unfold finiteDiagonal at hi
  cases hbit : rows i i <;> simp [hbit] at hi

/-- Consequently an `n`-row table cannot enumerate all Boolean functions on an
`n`-element domain, including at `n = 0` where there are no candidate rows. -/
theorem finite_boolean_table_not_surjective (n : ℕ)
    (rows : Fin n → (Fin n → Bool)) :
    ¬ Function.Surjective rows := by
  intro hsurj
  obtain ⟨i, hi⟩ := hsurj (finiteDiagonal rows)
  exact finiteDiagonal_ne_row rows i hi.symm

/-- Complement the diagonal of a natural-number-indexed Boolean table. -/
def diagonalJump (rows : ℕ → ℕ → Bool) : ℕ → Bool :=
  fun k => !(rows k k)

/-- The diagonal sequence differs from row `k` at coordinate `k`. -/
theorem diagonalJump_ne_row (rows : ℕ → ℕ → Bool) (k : ℕ) :
    diagonalJump rows ≠ rows k := by
  intro h
  have hk := congrFun h k
  unfold diagonalJump at hk
  cases hbit : rows k k <;> simp [hbit] at hk

/-- No natural-number-indexed family enumerates all Boolean sequences. -/
theorem no_enumeration_of_boolean_sequences (rows : ℕ → (ℕ → Bool)) :
    ¬ Function.Surjective rows := by
  intro hsurj
  obtain ⟨k, hk⟩ := hsurj (diagonalJump rows)
  exact diagonalJump_ne_row rows k hk.symm

/-- The existing exact cardinality theorem makes the bounded-domain size
explicit: there are `alphabet ^ length` encoded statements. -/
theorem bounded_statement_cardinality (alphabet length : ℕ) :
    Fintype.card (Statement alphabet length) = alphabet ^ length := by
  exact LibraryOfBabel.library_card alphabet length

end FiniteTruthDiagonal