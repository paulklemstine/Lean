import Pythagorean.TropicalAction.Defs

/-!
# Tropical Action Spectrum — Basic Properties

Proves fundamental properties of min-cost paths and tropical eigenvalues:

1. **Intermediate vertex bound**: `minCostPath` is at most the cost
   through any intermediate vertex.
2. **Positivity**: Positive Lagrangians yield positive path costs.
3. **Monotonicity**: `minCostPath` is monotone in the Lagrangian.
4. **Tropical eigenvalue bounds**: Basic bounds from the definition.
-/

namespace TropicalAction

open Finset BigOperators

noncomputable section

variable {n : ℕ} [NeZero n]

-- ============================================================
-- Basic identities
-- ============================================================

/-- The base case: the 1-step minimum cost is just L. -/
@[simp]
theorem minCostPath_zero (L : Fin n → Fin n → ℝ) (i j : Fin n) :
    minCostPath L 0 i j = L i j := rfl

/-- The recursive step of `minCostPath` (Bellman equation). -/
theorem minCostPath_succ (L : Fin n → Fin n → ℝ) (N : ℕ) (i j : Fin n) :
    minCostPath L (N + 1) i j =
    Finset.univ.inf' Finset.univ_nonempty (fun k => minCostPath L N i k + L k j) := rfl

/-
============================================================
Intermediate vertex bounds
============================================================

`minCostPath` is at most the cost of routing through any specific
    intermediate vertex `k`.
-/
theorem minCostPath_le_via (L : Fin n → Fin n → ℝ) (N : ℕ)
    (i j k : Fin n) :
    minCostPath L (N + 1) i j ≤ minCostPath L N i k + L k j := by
  convert Finset.inf'_le _ ( Finset.mem_univ k ) using 1

/-
============================================================
Positivity
============================================================

If L has strictly positive entries, then all min-cost paths
    have strictly positive cost.
-/
theorem minCostPath_pos (L : Fin n → Fin n → ℝ)
    (hL : ∀ i j, 0 < L i j) (N : ℕ) (i j : Fin n) :
    0 < minCostPath L N i j := by
  induction N generalizing i j <;> simp_all +decide [ minCostPath ];
  exact fun k => add_pos ( by solve_by_elim ) ( hL _ _ )

/-
============================================================
Monotonicity in the Lagrangian
============================================================

If L1 le L2 pointwise, then minCostPath L1 le minCostPath L2.
-/
theorem minCostPath_mono (L1 L2 : Fin n → Fin n → ℝ)
    (hL : ∀ i j, L1 i j ≤ L2 i j) (N : ℕ) (i j : Fin n) :
    minCostPath L1 N i j ≤ minCostPath L2 N i j := by
  induction' N with N ih generalizing i j <;> simp +decide [ *, minCostPath_succ ];
  exact fun k => ⟨ k, by linarith [ ih i k, hL k j ] ⟩

/-
============================================================
Tropical eigenvalue bounds
============================================================

The tropical eigenvalue is a lower bound on every cycle mean.
-/
theorem tropEigenvalue_le_cycleMean (L : Fin n → Fin n → ℝ)
    (k : Fin n) (i : Fin n) :
    tropEigenvalue L ≤ cycleMean L k.val i := by
  exact Finset.inf'_le _ ( Finset.mem_univ ( i, k ) )

/-
There exists a cycle achieving the tropical eigenvalue.
-/
theorem tropEigenvalue_achieved (L : Fin n → Fin n → ℝ) :
    ∃ (k : Fin n) (i : Fin n), cycleMean L k.val i = tropEigenvalue L := by
  obtain ⟨ p, hp ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun p : Fin n × Fin n => cycleMean L p.2.val p.1 );
  exact ⟨ p.2, p.1, hp.2.symm ⟩

end

end TropicalAction