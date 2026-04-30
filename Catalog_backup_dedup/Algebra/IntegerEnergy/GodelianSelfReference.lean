import Mathlib

/-! # CatalogBuild.Logic.GodelianSelfReference

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3
-/

/-- [Section: # CatalogBuild.Logic.GodelianSelfReference
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3] -/
theorem cantor_via_bool (α : Type*) : ¬ ∃ f : α → α → Bool, Surjective f := by
  convert cantor_via_lawvere ( Bool.not ) _;
  grobner

/-- [Section: # CatalogBuild.Logic.GodelianSelfReference
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 3] -/
theorem no_self_deciding_predicate (α : Type*) :
    ¬ ∃ (eval : α → α → Prop) (_ : Surjective eval),
      ∃ neg : α, ∀ a, eval neg a ↔ ¬ eval a a := by
        norm_num +zetaDelta at *;
        intro x hx y; use y; by_cases h : x y y <;> simp +decide [ h ] ;

theorem no_enumeration_of_subsets :
    ¬ ∃ f : ℕ → Set ℕ, Surjective f := by
      -- Apply the fact that there is no surjection from a set to its power set.
      apply cantor_via_lawvere;
      swap;
      exact fun b => ¬b;
      grind

