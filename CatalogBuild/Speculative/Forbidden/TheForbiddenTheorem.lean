/-! # CatalogBuild.Speculative.Forbidden.TheForbiddenTheorem

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.Forbidden.TheForbiddenTheorem
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem russells_catastrophe (f : α → Set α) : ¬ Surjective f := by
  exact?


/-- [Section: # CatalogBuild.Speculative.Forbidden.TheForbiddenTheorem
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem russell_diagonal_contradiction (f : α → Set α) (hf : Surjective f) : False := by
  exact absurd ( russells_catastrophe f ) ( by tauto )


/-- [Section: # CatalogBuild.Speculative.Forbidden.TheForbiddenTheorem
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7] -/
theorem compression_must_fail {n : ℕ} (f : Fin (n + 1) → Fin n) :
    ¬ Injective f := by
  exact fun h => absurd ( Fintype.card_le_of_injective f h ) ( by simp +arith +decide )


theorem incompressible_strings_exist (n : ℕ) (hn : 0 < n) :
    2 ^ n > 2 ^ n - 1 := by
  exact Nat.sub_lt ( by positivity ) ( by positivity )


theorem the_forbidden_theorem (f : α → α → Prop) :
    ¬ Surjective f := by
  intro h_surj;
  choose g hg using h_surj;
  -- Define the diagonal set D as {a | ¬(f a a)}
  set D : α → Prop := fun a => ¬(f a a);
  exact absurd ( congr_fun ( hg D ) ( g D ) ) ( by tauto )


theorem evil_is_constructive (f : α → Set α) :
    ∃ p : Set α, p ∉ Set.range f := by
  by_contra! h;
  exact russells_catastrophe f ( by tauto )


theorem liar_cannot_exist : ¬ ∃ P : Prop, P ↔ ¬P := by
  tauto


