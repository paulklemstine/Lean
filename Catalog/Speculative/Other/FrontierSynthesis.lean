import Mathlib

/-! # CatalogBuild.Speculative.Other.FrontierSynthesis

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10
-/

noncomputable section

/-- Every triple is exactly one of null, timelike, or spacelike. -/
theorem triple_trichotomy (a b c : ℤ) :
    IsNull a b c ∨ IsTimelike a b c ∨ IsSpacelike a b c := by
  unfold IsNull IsTimelike IsSpacelike lorentzForm
  omega

/-- Null and timelike are mutually exclusive. -/
theorem null_not_timelike {a b c : ℤ} (h : IsNull a b c) : ¬IsTimelike a b c := by
  unfold IsNull IsTimelike lorentzForm at *; omega

/-- Null and spacelike are mutually exclusive. -/
theorem null_not_spacelike {a b c : ℤ} (h : IsNull a b c) : ¬IsSpacelike a b c := by
  unfold IsNull IsSpacelike lorentzForm at *; omega

/-- A prime is light (mod 4) if p ≡ 1 (mod 4). -/
def IsLightPrime_mod4 (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 1

/-- A prime is dark (mod 4) if p ≡ 3 (mod 4). -/
def IsDarkPrime_mod4 (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 3

/-- The identity function is the unique function satisfying f ∘ f = f and f = id. -/
theorem id_is_unique_idempotent_identity {α : Type*} (f : α → α)
    (_h_idem : f ∘ f = f) (h_id : ∀ x, f x = x) : f = id := by
  ext x; exact h_id x

/-- Every element is a fixed point of the identity. -/
theorem id_all_fixed {α : Type*} (x : α) : id x = x := rfl

/-- The identity is the unique function where every point is fixed. -/
theorem all_fixed_implies_id {α : Type*} (f : α → α) (h : ∀ x, f x = x) : f = id := by
  ext x; exact h x

/-- Composition with identity preserves any function. -/
theorem id_preserves_composition {α : Type*} (f : α → α) : f ∘ id = f ∧ id ∘ f = f := by
  exact ⟨Function.comp_id f, Function.id_comp f⟩

/-- [Section: # CatalogBuild.Speculative.Other.FrontierSynthesis
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10] -/
theorem vandermonde_vanishes_at_coincidence {n : ℕ} (ev : Fin n → ℝ)
    (i j : Fin n) (hij : i ≠ j) (heq : ev i = ev j) :
    ∏ k : Fin n, ∏ l ∈ Finset.Ioi k, (ev l - ev k) = 0 := by
  cases lt_or_gt_of_ne hij <;> simp_all +decide [ Finset.prod_eq_zero_iff, sub_eq_iff_eq_add ];
  · exact ⟨ i, j, by assumption, heq.symm ⟩;
  · exact ⟨ j, i, by assumption, by linarith ⟩

end
