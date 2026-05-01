import Mathlib

/-! # CatalogBuild.Speculative.SciFi.Paradoxes_2

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3
-/

/-- [Section: # CatalogBuild.Speculative.SciFi.Paradoxes_2
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3] -/
theorem cantor_diagonal_witness (A : Type*) (f : A → Set A) :
    {a : A | a ∉ f a} ∉ Set.range f := by
  simp +zetaDelta at *;
  intro x hx; replace hx := Set.ext_iff.mp hx x; by_cases h : x ∈ f x <;> simp +decide [ h ] at hx;

/-- [Section: # CatalogBuild.Speculative.SciFi.Paradoxes_2
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 3] -/
theorem russell_style (A : Type*) (f : A → Set A) :
    ∀ a : A, f a ≠ {x | x ∉ f x} := by
  intro a h; have := Set.ext_iff.mp h a; simp +decide at this;

theorem lawvere_fixedpoint {A B : Type*} (φ : A → A → B)
    (h_surj : ∀ g : A → B, ∃ a, φ a = g) (f : B → B) :
    ∃ b : B, f b = b := by
  obtain ⟨ a, ha ⟩ := h_surj ( fun x ↦ f ( φ x x ) );
  exact ⟨ _, congr_fun ha a |> Eq.symm ⟩