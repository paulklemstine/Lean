/-
# The Diagonal Argument: Self-Reference and Undecidability

Rudy Rucker identifies the diagonal argument as the single most important
proof technique in the foundations of mathematics. It appears in:
- Cantor's uncountability proof
- Russell's paradox
- Gödel's incompleteness theorems
- Turing's halting problem
- Tarski's undefinability of truth

This module formalizes several manifestations of the diagonal argument,
following Rucker's unified presentation in "Infinity and the Mind."
-/

import Mathlib

namespace DiagonalArguments

/-! ## The Abstract Diagonal Lemma

Rucker presents the diagonal argument in its most general form:
given any binary relation, we can always construct an object that
"diagonalizes" against any enumeration. -/

/-- Lawvere's fixed point theorem: if there is a surjection from A to (A → B),
then every endofunction on B has a fixed point. This is the categorical
essence of all diagonal arguments, as Rucker hints at. -/
theorem lawvere_fixed_point {A B : Type*} (e : A → A → B)
    (he : ∀ f : A → B, ∃ a, e a = f) :
    ∀ g : B → B, ∃ b, g b = b := by
  intro g
  obtain ⟨a, ha⟩ := he (fun x => g (e x x))
  exact ⟨e a a, by simpa using (congr_fun ha a).symm⟩

/-! ## The Halting Problem

Rucker connects Cantor's diagonal argument to Turing's proof that
the halting problem is undecidable. We formalize the abstract structure. -/

/-- Cantor's theorem restated: there is no surjection from α to (α → Bool).
This captures the essence of the halting problem: if we could enumerate
all decision procedures, we could diagonalize against the enumeration. -/
theorem cantor_no_surjection_bool (α : Type*) :
    ¬ ∃ f : α → (α → Bool), Function.Surjective f := by
  rintro ⟨f, hf⟩
  have ⟨g, hg⟩ : ∃ g : α → Bool, ∀ a, g a ≠ f a a :=
    ⟨fun a => !f a a, fun a => by simp⟩
  obtain ⟨a, ha⟩ := hf g
  exact hg a (by rw [ha])

/-! ## Russell's Paradox (Type-Theoretic Version)

Rucker discusses Russell's paradox as a manifestation of the diagonal
argument. In type theory, Russell's paradox manifests as the fact that
there can be no surjection from a set to its power set — which we have
already proven above as Cantor's theorem. Here we show a related result:
the "Russell set" construction always produces a set outside any given
family. -/

/-- For any family of sets indexed by α, there exists a set of α not
in the range — the "Russell set" that diagonalizes against the family.
This is the constructive content of Russell's paradox. -/
theorem russell_diagonal {α : Type*} (f : α → Set α) :
    ∃ S : Set α, ∀ a, f a ≠ S := by
  use {x | x ∉ f x}
  intro a ha
  replace ha := Set.ext_iff.mp ha a
  aesop

/-! ## König's Theorem

Rucker discusses König's theorem as a powerful generalization of
Cantor's theorem in cardinal arithmetic. -/

/-- König's theorem: if κᵢ < μᵢ for all i, then Σᵢ κᵢ < Πᵢ μᵢ.
This is a far-reaching generalization of Cantor's theorem that Rucker
calls "the most important theorem in cardinal arithmetic." -/
theorem konig_cardinal {ι : Type*} (κ μ : ι → Cardinal)
    (h : ∀ i, κ i < μ i) :
    Cardinal.sum κ < Cardinal.prod μ := by
  convert Cardinal.sum_lt_prod _ _ _; aesop

/-! ## Fixed Point Theorems from Diagonalization

Rucker notes that diagonal arguments don't always yield paradoxes —
sometimes they yield fixed point theorems. -/

/-- Every order-preserving function on a complete lattice has a fixed point.
(Knaster-Tarski theorem) -/
theorem knaster_tarski {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : ∃ x, f x = x := by
  set x := sSup {a : α | f a ≥ a}
  have hfx_ge_x : f x ≥ x :=
    sSup_le fun a ha => le_trans ha (hf (le_sSup ha))
  exact ⟨x, le_antisymm (le_sSup (by aesop)) hfx_ge_x⟩

end DiagonalArguments
