/-! # CatalogBuild.Speculative.Other.FrontierSynthesis

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 10
-/

import Mathlib

noncomputable section

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

/-- (3, 4, 5) is the simplest Pythagorean triple — a null vector. -/

def IsLightPrime_mod4 (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 1

/-- A prime is dark (mod 4) if p ≡ 3 (mod 4). -/

def IsDarkPrime_mod4 (p : ℕ) : Prop := Nat.Prime p ∧ p % 4 = 3

/-- 2 is the unique twilight prime (neither light nor dark mod 4). -/

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

/-! ## §6: The Vandermonde Repulsion Factor -/

/-
PROBLEM
The Vandermonde product vanishes when two values coincide (eigenvalue repulsion).

PROVIDED SOLUTION
Since i ≠ j, either i < j or j < i. WLOG assume i < j (symmetric argument for j < i). Then j ∈ Finset.Ioi i, and the factor (ev j - ev i) = 0 appears in the inner product. The whole product is zero because one factor is zero. Use Finset.prod_eq_zero to find the zero factor.
-/

theorem vandermonde_vanishes_at_coincidence {n : ℕ} (ev : Fin n → ℝ)
    (i j : Fin n) (hij : i ≠ j) (heq : ev i = ev j) :
    ∏ k : Fin n, ∏ l ∈ Finset.Ioi k, (ev l - ev k) = 0 := by
  cases lt_or_gt_of_ne hij <;> simp_all +decide [ Finset.prod_eq_zero_iff, sub_eq_iff_eq_add ];
  · exact ⟨ i, j, by assumption, heq.symm ⟩;
  · exact ⟨ j, i, by assumption, by linarith ⟩

/-! ## §7: Prime Gap Growth — Arithmetic Expansion -/

/-
PROBLEM
For any gap size g, there exist g consecutive composite numbers.
    This is the "expansion of arithmetic spacetime."

PROVIDED SOLUTION
Use n = (g+1)! + 1. Then for 1 ≤ k ≤ g, n + k = (g+1)! + 1 + k. Since 2 ≤ k+1 ≤ g+1, we have (k+1) | (g+1)!, so (k+1) | (g+1)! + (k+1), hence (k+1) | (n + k). Since n + k ≥ (k+1) + 1 > k+1 ≥ 2, the number n+k has a proper factor k+1, so it is not prime.
-/

end
