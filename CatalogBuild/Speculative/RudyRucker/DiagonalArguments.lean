/-! # CatalogBuild.Speculative.RudyRucker.DiagonalArguments

Auto-generated from theorem catalog database.
Domain: Speculative/RudyRucker
Declarations: 4
-/

import Mathlib

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

