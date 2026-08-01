/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Ultrafilter Overspill and Non-Standard Transfer

Establishes the **overspill principle** for ultrafilters on ℕ and
proves transfer theorems illuminating which arithmetic results
survive in non-Archimedean settings.

## Main Result

* `overspill_diagonal` — diagonal overspill: existence of overflow functions

## Catalog References
- `Bridges/DependentUltraproduct.lean`: `ultrafilter_transfer_and`,
  `ultrafilter_bounded_forall_transfer`
- `Bridges/NonArchimedeanComputation.lean`: `padic_arithmetic_depth_bound`
-/

import Mathlib

set_option maxHeartbeats 800000

open Set Filter

namespace NonstandardArithmetic

/-! ## Diagonal overspill -/

section Overspill

variable (U : Ultrafilter ℕ)

/-- For a decreasing sequence of large sets that eventually omits every index,
there is an unbounded index-dependent stage that remains large pointwise. -/

theorem overspill_diagonal
    (S : ℕ → Set ℕ)
    (hS_mem : ∀ n, S n ∈ U)
    (hS_dec : ∀ n, S (n + 1) ⊆ S n)
    (hS_leave : ∀ i, ∃ n, i ∉ S n) :
    ∃ f : ℕ → ℕ, (∀ n, {i | n ≤ f i} ∈ U) ∧
                   ({i | i ∈ S (f i)} ∈ U) := by
  -- Define f using the diagonal overspill theorem from h_overspill.
  obtain ⟨f, hf⟩ : ∃ f : ℕ → ℕ, (∀ n, {i | n ≤ f i} ∈ U) ∧ (∀ i, i ∈ S 0 → i ∈ S (f i)) := by
    -- Define f(i) as the largest n such that i ∈ S n.
    have hf_def : ∀ i ∈ S 0, ∃ n, i ∈ S n ∧ ∀ m > n, i ∉ S m := by
      intro i hi
      obtain ⟨n, hn⟩ : ∃ n, i ∈ S n ∧ ∀ m > n, i ∉ S m := by
        have h_finite : Set.Finite {n | i ∈ S n} := by
          obtain ⟨ n, hn ⟩ := hS_leave i;
          exact Set.finite_iff_bddAbove.2 ⟨ n, fun m hm => not_lt.1 fun contra => hn <| Set.mem_of_subset_of_mem ( show S n ⊇ S m from by exact Nat.le_induction ( by tauto ) ( fun k hk ih => by tauto ) m contra.le ) hm ⟩
        exact ⟨ Finset.max' ( h_finite.toFinset ) ⟨ 0, h_finite.mem_toFinset.mpr hi ⟩, h_finite.mem_toFinset.mp ( Finset.max'_mem _ _ ), fun m hm h => not_lt_of_ge ( Finset.le_max' _ _ ( h_finite.mem_toFinset.mpr h ) ) hm ⟩;
      use n;
    choose! f hf₁ hf₂ using hf_def; use f; (
    refine' ⟨ fun n => _, hf₁ ⟩;
    refine' Filter.mem_of_superset ( hS_mem n ) _;
    intro i hi; contrapose! hf₂;
    exact ⟨ i, by exact Set.mem_of_subset_of_mem ( show S n ⊆ S 0 from by exact Nat.recOn n ( by tauto ) fun n ihn => by exact Set.Subset.trans ( hS_dec n ) ihn ) hi, n, not_le.mp hf₂, hi ⟩);
  exact ⟨ f, hf.1, Filter.mem_of_superset ( hS_mem 0 ) hf.2 ⟩

end Overspill

end NonstandardArithmetic