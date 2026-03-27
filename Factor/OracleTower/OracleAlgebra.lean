import Mathlib

/-!
# Oracle Algebra: Lattices, Monoids, and Galois Connections

## Beyond Flatland Part III — Algebraic Structures

This file develops the algebraic theory of oracle operators, showing they form
rich structures: partial orders, lattices, and connections to Galois theory.
-/

open Finset Function Set

/-! ## Section 5: The Oracle Partial Order

Oracles can be ordered by refinement: O₁ ≤ O₂ if truthSet(O₂) ⊆ truthSet(O₁),
meaning O₁ is "more accepting" than O₂. We explore this ordering.
-/

/-- An oracle is an idempotent function. -/
def IsOracle' {α : Type*} (O : α → α) : Prop := ∀ x, O (O x) = O x

/-- Truth set of an oracle. -/
def oracleTruth {α : Type*} (O : α → α) : Set α := {x | O x = x}


theorem refined_oracle_dominance {α : Type*} (O₁ O₂ : α → α)
    (h1 : IsOracle' O₁) (h2 : IsOracle' O₂)
    (hrefine : oracleTruth O₂ ⊆ oracleTruth O₁) :
    ∀ x, O₁ (O₂ x) = O₂ x := by
  exact fun x => hrefine ( h2 x )


theorem id_truth_maximal {α : Type*} (O : α → α) :
    oracleTruth O ⊆ oracleTruth (id : α → α) := by
  exact fun x hx => by aesop;


theorem product_oracle {α β : Type*} (O₁ : α → α) (O₂ : β → β)
    (h1 : IsOracle' O₁) (h2 : IsOracle' O₂) :
    IsOracle' (fun p : α × β => (O₁ p.1, O₂ p.2)) := by
  exact fun p => by aesop;


theorem product_truth_set {α β : Type*} (O₁ : α → α) (O₂ : β → β) :
    oracleTruth (fun p : α × β => (O₁ p.1, O₂ p.2)) =
    (oracleTruth O₁) ×ˢ (oracleTruth O₂) := by
  exact Set.ext fun x => by unfold oracleTruth; aesop;

/-! ## Section 6: Oracle Monoid Structure

The set of all oracles on a type, under composition, forms a monoid
when we restrict to commuting families.
-/

/-
Theorem 21.1: The identity is an oracle.
-/
theorem id_is_oracle' {α : Type*} : IsOracle' (id : α → α) := by
  exact fun x => rfl


theorem compose_commuting_oracles {α : Type*} (O₁ O₂ : α → α)
    (h1 : IsOracle' O₁) (h2 : IsOracle' O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    IsOracle' (O₁ ∘ O₂) := by
  unfold IsOracle' at *; aesop;


theorem compose_truth_intersection {α : Type*} (O₁ O₂ : α → α)
    (h1 : IsOracle' O₁) (h2 : IsOracle' O₂)
    (hcomm : ∀ x, O₁ (O₂ x) = O₂ (O₁ x)) :
    oracleTruth (O₁ ∘ O₂) = oracleTruth O₁ ∩ oracleTruth O₂ := by
  grind +locals

/-! ## Section 7: The Modular Oracle Hierarchy

The modular oracle mod n maps ℤ → ℤ via x ↦ x % n. We study the hierarchy
of these oracles across different moduli.
-/

/-- The modular oracle: reduction mod n. -/
def modOracle (n : ℕ) (x : ℤ) : ℤ := x % (n : ℤ)


theorem modOracle_is_oracle (n : ℕ) (hn : n ≥ 1) : IsOracle' (modOracle n) := by
  exact fun x => Int.emod_emod _ _


theorem modOracle_truth_set (n : ℕ) (hn : n ≥ 1) :
    oracleTruth (modOracle n) = {x : ℤ | 0 ≤ x ∧ x < n} := by
  ext x; exact ⟨fun hx => by exact ⟨by
  exact hx.symm ▸ Int.emod_nonneg _ ( by positivity ), by
    exact Int.emod_lt_of_pos x ( by positivity ) |> fun h => hx.symm ▸ h⟩, fun hx => by
    exact Int.emod_eq_of_lt hx.1 hx.2⟩;


theorem modOracle_divisor_dominance (m n : ℕ) (hm : m ≥ 1) (hn : n ≥ 1) (hdvd : m ∣ n) :
    ∀ x : ℤ, modOracle m (modOracle n x) = modOracle m x := by
  obtain ⟨ k, hk ⟩ := hdvd; simp +decide [ hk, modOracle ] ;

/-! ## Section 8: Oracle Galois Connections

Oracles naturally give rise to Galois connections between the poset of
subsets and the poset of oracles.
-/


theorem truth_monotone {α : Type*} (O₁ O₂ : α → α)
    (h : ∀ x, O₁ x = x → O₂ x = x) :
    oracleTruth O₁ ⊆ oracleTruth O₂ := by
  exact fun x hx => h x hx


theorem floor_is_oracle : IsOracle' (fun x : ℤ => x) := by
  exact fun x => rfl

/-! ## Section 9: Boolean Oracle Algebra

On a finite Boolean type, oracles correspond to choosing a subset and
projecting onto it.
-/

/-
Theorem 24.1: On Bool, there are exactly 3 oracles:
    id, const true, const false. We verify each.
-/
theorem bool_id_oracle : IsOracle' (id : Bool → Bool) := by
  exact?

theorem bool_const_true_oracle : IsOracle' (fun _ : Bool => true) := by
  -- The constant function true is an oracle because applying it twice is the same as applying it once.
  simp [IsOracle']

theorem bool_const_false_oracle : IsOracle' (fun _ : Bool => false) := by
  -- The constant function false is an oracle because applying it twice is the same as applying it once.
  simp [IsOracle']


theorem bool_not_not_oracle : ¬ IsOracle' (fun b : Bool => !b) := by
  exact fun h => by have := h Bool.true; simp +decide at this;


theorem bool_and_oracle (b : Bool) : IsOracle' (fun x : Bool => x && b) := by
  grind +locals


theorem bool_or_oracle (b : Bool) : IsOracle' (fun x : Bool => x || b) := by
  intro x; cases x <;> cases b <;> rfl