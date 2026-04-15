/-! # CatalogBuild.Speculative.SciFi.Paradoxes

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3
-/

import Mathlib

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

