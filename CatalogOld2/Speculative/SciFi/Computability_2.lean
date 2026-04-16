/-! # CatalogBuild.Speculative.SciFi.Computability_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 4
-/

import Mathlib

theorem diagonal_nonsurjective {α : Type*} {β : Type*}
    (σ : β → β) (hσ : ∀ b, σ b ≠ b)
    (f : α → (α → β)) : ¬ Function.Surjective f := by
  contrapose! hσ;
  -- Define a function g : α → β such that g(a) = σ(f(a)(a)).
  set g : α → β := fun a => σ (f a a);
  obtain ⟨ a, ha ⟩ := hσ g;
  exact ⟨ f a a, congr_fun ha.symm a ⟩


theorem cantor_nat_bool : ¬ ∃ f : ℕ → (ℕ → Bool), Function.Surjective f := by
  rintro ⟨ f, hf ⟩;
  exact absurd ( hf fun n => if f n n = Bool.true then Bool.false else Bool.true ) ( by rintro ⟨ n, hn ⟩ ; by_cases h : f n n = Bool.true <;> simpa [ h ] using congr_fun hn n )


theorem no_complete_enumeration :
    ∀ (enum : ℕ → (ℕ → ℕ)), ∃ g : ℕ → ℕ, ∀ n, enum n ≠ g := by
  exact fun enum => ⟨ fun n => enum n n + 1, fun n => ne_of_apply_ne ( fun f => f n ) ( by norm_num ) ⟩


theorem self_reference_constraint {α : Type*} (f : α → α)
    (h : f ∘ f = id) : ∀ x, f (f x) = x := by
  exact congr_fun h

