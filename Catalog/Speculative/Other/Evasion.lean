/-! # CatalogBuild.Speculative.Other.Evasion

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11
-/

import Mathlib

noncomputable section

/-- An evasion strategy: given search history, choose a hiding location. -/
structure EvasionStrategy (α : Type*) where
  hide : (ℕ → Set α) → ℕ → α
  causal : ∀ (s₁ s₂ : ℕ → Set α) (n : ℕ),
    (∀ i, i < n → s₁ i = s₂ i) → hide s₁ n = hide s₂ n




/-- Whether the evader is caught at step n. -/
def EvasionStrategy.isCaught {α : Type*} (e : EvasionStrategy α)
    (search : ℕ → Set α) (n : ℕ) : Prop :=
  e.hide search n ∈ search n




/-- An evasion strategy successfully evades forever. -/
def EvasionStrategy.successfulEvasion {α : Type*} (e : EvasionStrategy α)
    (search : ℕ → Set α) : Prop :=
  ∀ n : ℕ, ¬(e.isCaught search n)




/-- A perfect evasion strategy evades all searches. -/
def EvasionStrategy.isPerfect {α : Type*} (e : EvasionStrategy α) : Prop :=
  ∀ search : ℕ → Set α, e.successfulEvasion search




/-- An adaptive search strategy for a finite game on Fin n. -/
def AdaptiveSearch (n : ℕ) := ℕ → Fin n




/-- Whether search catches a static target within T steps. -/
def catches (n : ℕ) (search : AdaptiveSearch n) (target : Fin n) (T : ℕ) : Prop :=
  ∃ t, t ≤ T ∧ search t = target




/-- An exhaustive search catches any target within n steps. -/
theorem exhaustive_search_catches {n : ℕ}
    (search : AdaptiveSearch n) (target : Fin n)
    (h_exhaustive : ∀ i : Fin n, ∃ t, t < n ∧ search t = i) :
    catches n search target n := by
  obtain ⟨t, ht, heq⟩ := h_exhaustive target
  exact ⟨t, by omega, heq⟩




/-- [Section: # CatalogBuild.Speculative.Other.Evasion
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11] -/
theorem evasion_lower_bound (n : ℕ) (hn : 2 ≤ n) :
    ∀ (search : AdaptiveSearch n),
      ∃ (target : Fin n), ¬catches n search target (n - 2) := by
  intro search
  by_cases h_targ : ∀ i : Fin n, ∃ t < n - 1, search t = i;
  · have h_pigeonhole : Finset.card (Finset.image search (Finset.range (n - 1))) = n := by
      rw [ show Finset.image search ( Finset.range ( n - 1 ) ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ t, ht, rfl ⟩ := h_targ x; exact Finset.mem_image_of_mem _ ( Finset.mem_range.mpr ht ) ] ; simp +decide [ Finset.card_univ ] ;
    exact absurd h_pigeonhole ( ne_of_lt ( lt_of_le_of_lt ( Finset.card_image_le ) ( by simpa using Nat.sub_lt ( by linarith ) zero_lt_one ) ) );
  · push_neg at h_targ;
    exact ⟨ h_targ.choose, fun ⟨ t, ht₁, ht₂ ⟩ => h_targ.choose_spec t ( by omega ) ht₂ ⟩




/-- A transfinite evasion strategy indexed by ordinals. -/
structure TransfiniteEvasion (α : Type*) where
  hide : Ordinal → α
  evasion_depth : Ordinal




/-- [Section: # CatalogBuild.Speculative.Other.Evasion
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 11] -/
theorem transfinite_evasion_finite_bound {n : ℕ} (hn : 0 < n)
    (e : TransfiniteEvasion (Fin n)) :
    ∃ (search : Ordinal → Fin n), ∃ t : Ordinal, t < Ordinal.omega0 ∧
      search t = e.hide t := by
  exact ⟨ fun _ => e.hide 0, 0, Ordinal.omega0_pos, rfl ⟩




/-- A computationally bounded evasion strategy. -/
structure BoundedEvasionStrategy (α : Type*) extends EvasionStrategy α where
  complexity : ℕ → ℕ
  poly_bounded : ∃ (c k : ℕ), ∀ n, complexity n ≤ c * n ^ k + c

end

end


end


end
