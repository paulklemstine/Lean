/-! # CatalogBuild.Speculative.RudyRucker.DiagonalArguments

Auto-generated from theorem catalog database.
Domain: Speculative/RudyRucker
Declarations: 4
-/

import Mathlib

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


/-- For any family of sets indexed by α, there exists a set of α not
in the range — the "Russell set" that diagonalizes against the family.
This is the constructive content of Russell's paradox. -/
theorem russell_diagonal {α : Type*} (f : α → Set α) :
    ∃ S : Set α, ∀ a, f a ≠ S := by
  use {x | x ∉ f x}
  intro a ha
  replace ha := Set.ext_iff.mp ha a
  aesop


/-- König's theorem: if κᵢ < μᵢ for all i, then Σᵢ κᵢ < Πᵢ μᵢ.
This is a far-reaching generalization of Cantor's theorem that Rucker
calls "the most important theorem in cardinal arithmetic." -/
theorem konig_cardinal {ι : Type*} (κ μ : ι → Cardinal)
    (h : ∀ i, κ i < μ i) :
    Cardinal.sum κ < Cardinal.prod μ := by
  convert Cardinal.sum_lt_prod _ _ _; aesop


/-- Every order-preserving function on a complete lattice has a fixed point.
(Knaster-Tarski theorem) -/
theorem knaster_tarski {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : ∃ x, f x = x := by
  set x := sSup {a : α | f a ≥ a}
  have hfx_ge_x : f x ≥ x :=
    sSup_le fun a ha => le_trans ha (hf (le_sSup ha))
  exact ⟨x, le_antisymm (le_sSup (by aesop)) hfx_ge_x⟩

