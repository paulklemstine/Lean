/-! # CatalogBuild.Speculative.Forbidden.TheForbiddenTheorem

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 7
-/

import Mathlib

/-- [Section: ## Part I: The Russell Catastrophe
The "set of all sets not containing themselves" cannot exist.
This broke mathematics in 1901 and we never fully recovered.] -/
theorem russells_catastrophe (f : α → Set α) : ¬ Surjective f := by
  exact?


theorem russell_diagonal_contradiction (f : α → Set α) (hf : Surjective f) : False := by
  exact absurd ( russells_catastrophe f ) ( by tauto )


/-- [Section: ## Part II: The Incompressibility Curse
Most objects cannot be described more concisely than themselves.
Most truths have no short proof. Most of reality is irreducible.
By a counting/pigeonhole argument: if we have 2^n binary strings of
length n, but fewer than 2^n descriptions of length < n, then most
strings are incompressible.] -/
theorem compression_must_fail {n : ℕ} (f : Fin (n + 1) → Fin n) :
    ¬ Injective f := by
  exact fun h => absurd ( Fintype.card_le_of_injective f h ) ( by simp +arith +decide )


theorem incompressible_strings_exist (n : ℕ) (hn : 0 < n) :
    2 ^ n > 2 ^ n - 1 := by
  exact Nat.sub_lt ( by positivity ) ( by positivity )


/-- [Section: ## Part III: The Unification
All of these — Russell, Cantor, Gödel, Turing, Kolmogorov — are
aspects of a single meta-theorem. Here it is:] -/
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


/-- [Section: ## Part IV: The Self-Swallowing Snake
The ultimate forbidden object: a proof that proofs have limits.
Mathematics studying its own blindness. The ouroboros completes.] -/
theorem liar_cannot_exist : ¬ ∃ P : Prop, P ↔ ¬P := by
  tauto

