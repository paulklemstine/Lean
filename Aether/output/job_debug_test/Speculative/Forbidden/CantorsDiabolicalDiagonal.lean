import Mathlib

/-! # CatalogBuild.Speculative.Forbidden.CantorsDiabolicalDiagonal

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 6
-/

/-- The anti-diagonal: the set of elements that defy their own classification.
`{x | x ∉ f x}` — "I am not what you say I am." -/
def antiDiagonal (f : α → Set α) : Set α := {x | x ∉ f x}

/-- [Section: # CatalogBuild.Speculative.Forbidden.CantorsDiabolicalDiagonal
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 6] -/
theorem antiDiagonal_not_in_range (f : α → Set α) :
    antiDiagonal f ∉ Set.range f := by
  -- Assume for contradiction that the anti-diagonal is in the range of f.
  by_contra h_contra
  obtain ⟨a, ha⟩ : ∃ a, f a = antiDiagonal f := by
    exact h_contra;
  unfold antiDiagonal at ha; replace ha := Set.ext_iff.mp ha a; aesop;

/-- [Section: # CatalogBuild.Speculative.Forbidden.CantorsDiabolicalDiagonal
Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 6] -/
theorem naturals_inject_but_cannot_surject :
    (∃ f : ℕ → ℝ, Injective f) ∧ (¬ ∃ f : ℕ → ℝ, Surjective f) := by
  refine' ⟨ ⟨ _, Nat.cast_injective ⟩, _ ⟩;
  intro h₂
  obtain ⟨f, hf⟩ := h₂
  have h_card : Cardinal.mk ℝ ≤ Cardinal.mk ℕ := by
    exact Cardinal.mk_le_of_surjective hf;
  contrapose! h_card; aesop;

theorem injection_to_powerset : ∃ f : α → Set α, Injective f := by
  exact ⟨ fun x => { x }, fun x y h => by simpa using h ⟩

theorem powerset_strictly_dominates :
    (∃ f : α → Set α, Injective f) ∧ (¬ ∃ f : Set α → α, Injective f) := by
  refine' ⟨ _, _ ⟩;
  · exact ⟨ _, Set.singleton_injective ⟩;
  · intro ⟨ f, hf ⟩;
    have := @cantor_no_surjection α;
    apply this ( Function.invFun f );
    exact?

theorem diagonal_defeats_enumeration (enum : ℕ → (ℕ → Prop)) :
    ∃ g : ℕ → Prop, ∀ n, g ≠ enum n := by
  exact ⟨ fun n => ¬( enum n ) n, fun n => fun h => by have := congr_fun h n; tauto ⟩

