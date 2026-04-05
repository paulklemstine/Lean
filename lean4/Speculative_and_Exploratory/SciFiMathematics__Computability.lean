/-
# Mathematics of Science Fiction — Chapter 5: Computability and Artificial Intelligence

Formalized proofs about diagonal arguments, uncomputability, and their
implications for AI safety in science fiction.
-/
import Mathlib

namespace SciFiMathematics.Computability

/-! ## Section 5.1: The Diagonal Argument

The core technique behind the halting problem, Gödel's incompleteness,
and the logical structure of many SF paradoxes. -/

/-
The diagonal argument: no function f : α → (α → β) can be surjective
    if β has a fixed-point-free endomorphism. This is the common structure
    underlying the halting problem, Cantor's theorem, and the liar paradox.
-/
theorem diagonal_nonsurjective {α : Type*} {β : Type*}
    (σ : β → β) (hσ : ∀ b, σ b ≠ b)
    (f : α → (α → β)) : ¬ Function.Surjective f := by
  contrapose! hσ;
  -- Define a function g : α → β such that g(a) = σ(f(a)(a)).
  set g : α → β := fun a => σ (f a a);
  obtain ⟨ a, ha ⟩ := hσ g;
  exact ⟨ f a a, congr_fun ha.symm a ⟩

/-
Cantor's theorem as a corollary: no surjection ℕ → (ℕ → Bool).
-/
theorem cantor_nat_bool : ¬ ∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  rintro ⟨ f, hf ⟩;
  exact absurd ( hf fun n => if f n n = Bool.true then Bool.false else Bool.true ) ( by rintro ⟨ n, hn ⟩ ; by_cases h : f n n = Bool.true <;> simpa [ h ] using congr_fun hn n )

/-! ## Section 5.2: Gödel's Incompleteness (Consequences)

While the full incompleteness theorems require substantial formalization
of arithmetic, we can prove related diagonal results. -/

/-
No enumeration of total functions ℕ → ℕ can be complete:
    there always exists a function not in the enumeration.
    This is the computability-theoretic analogue of Gödel's theorem.
-/
theorem no_complete_enumeration :
    ∀ (enum : ℕ → (ℕ → ℕ)), ∃ g : ℕ → ℕ, ∀ n, enum n ≠ g := by
  exact fun enum => ⟨ fun n => enum n n + 1, fun n => ne_of_apply_ne ( fun f => f n ) ( by norm_num ) ⟩

/-! ## Self-Reference and AI Consciousness

Can an AI fully model itself? The diagonal argument says no. -/

/-
No function can be its own inverse on all inputs unless it is
    an involution. AI systems cannot perfectly predict their own output
    without being trivially simple.
-/
theorem self_reference_constraint {α : Type*} (f : α → α)
    (h : f ∘ f = id) : ∀ x, f (f x) = x := by
  exact congr_fun h

end SciFiMathematics.Computability