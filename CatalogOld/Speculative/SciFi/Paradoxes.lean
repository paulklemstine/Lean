/-
# Mathematics of Science Fiction — Chapter 12: The Grandfather Paradox and Diagonal Arguments

Formalized proofs of Cantor's theorem and diagonal arguments, which share
the same self-referential structure as the grandfather paradox.
-/
import Mathlib

namespace SciFiMathematics.Paradoxes

/-! ## Section 12.1: Cantor's Diagonal Theorem -/

/-
Cantor's theorem: there is no surjection from a set to its power set.
-/
theorem cantor_no_surjection (A : Type*) :
    ¬ ∃ f : A → Set A, Function.Surjective f := by
  intro ⟨ f, hf ⟩;
  -- Consider the set $D = \{ x \in A \mid x \notin f(x) \}$.
  set D := {x : A | x ∉ f x};
  cases' hf D with x hx ; replace hx := Set.ext_iff.mp hx x ; aesop

/-
The diagonal set construction: given f : A → Set A, the set
    {a : a ∉ f(a)} cannot be in the range of f.
-/
theorem diagonal_not_in_range {A : Type*} (f : A → Set A) :
    {a | a ∉ f a} ∉ Set.range f := by
  simp +zetaDelta at *;
  exact fun x hx => by simpa using Set.ext_iff.mp hx x;

/-! ## The Halting Problem as a Diagonal Argument -/

/-
No function f : α → (α → Bool) can cover all functions α → Bool.
-/
theorem no_enumeration_of_functions (α : Type*) [Nonempty α] :
    ¬ ∃ f : α → (α → Bool), Function.Surjective f := by
  intro ⟨ f, hf ⟩;
  obtain ⟨ g, hg ⟩ := hf ( fun x => if f x x = Bool.true then Bool.false else Bool.true );
  have := congr_fun hg g; by_cases h : f g g = true <;> simp +decide [ h ] at this;

/-! ## The Liar Paradox and Fixed Points of Negation -/

/-
Negation has no fixed point in Bool: there is no b such that !b = b.
-/
theorem negation_no_fixed_point : ¬ ∃ b : Bool, (!b) = b := by
  decide +revert

/-! ## The Grandfather Paradox Formalized -/

/-
The grandfather paradox: if a function has no fixed point,
    then there is no x with f(x) = x.
-/
theorem grandfather_paradox {α : Type*} (f : α → α)
    (h_no_fp : ∀ x, f x ≠ x) :
    ¬ ∃ x, f x = x := by
  exact fun ⟨ x, hx ⟩ => h_no_fp x hx

end SciFiMathematics.Paradoxes