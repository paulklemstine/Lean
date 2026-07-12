import Pythagorean.TropicalAction.Basic

/-!
# Tropical Action Spectrum — Spectral Theorems

Proves the central spectral theorems of tropical mechanics:

1. **Eigenvector lower bound**: A tropical eigenvector provides a lower
   bound on all path costs (the variational principle).
2. **Eigenvalue Lipschitz continuity**: The tropical eigenvalue is
   1-Lipschitz in the sup-norm of the Lagrangian.
3. **Cycle cost eigenpair bound**: Eigenpairs control cycle costs.
-/

namespace TropicalAction

open Finset BigOperators

noncomputable section

variable {n : ℕ} [NeZero n]

-- ============================================================
-- Eigenvector inequalities
-- ============================================================

/-- The min-plus eigenvector equation implies an entrywise inequality:
    L i j + v j ge mu + v i for all i, j. -/
theorem eigenpair_entry_bound (L : Fin n → Fin n → ℝ) (mu : ℝ) (v : Fin n → ℝ)
    (hev : IsTropEigenpair L mu v) (i j : Fin n) :
    mu + v i ≤ L i j + v j := by
  exact hev i ▸ Finset.inf'_le _ (Finset.mem_univ _)

/-- **Tropical Variational Principle**: If (mu, v) is a tropical eigenpair,
    then the (N+1)-step minimum cost from i to j is bounded below by
    (N+1) * mu + v i - v j. The telescoping sum of the eigenvector equation
    along any path yields this bound. -/
theorem eigenvector_lower_bound (L : Fin n → Fin n → ℝ) (mu : ℝ) (v : Fin n → ℝ)
    (hev : IsTropEigenpair L mu v) (N : ℕ) (i j : Fin n) :
    (N + 1 : ℝ) * mu + v i - v j ≤ minCostPath L N i j := by
  induction' N with N ih generalizing i j
  · simpa [minCostPath_zero] using by linarith [eigenpair_entry_bound L mu v hev i j]
  · convert Finset.le_inf' _ _ _ using 1
    · exact ⟨i, Finset.mem_univ _⟩
    · intro k hk; have := eigenpair_entry_bound L mu v hev k j
      norm_num at *; linarith [ih i k]

/-
============================================================
Eigenpair and eigenvalue relationship
============================================================

The cycle cost is bounded below by the eigenpair: if (mu, v) is
    a tropical eigenpair, then every cycle of length k+1 has cost
    at least (k+1) * mu. Follows from eigenvector_lower_bound with i = j.
-/
theorem eigenpair_cycle_lower_bound (L : Fin n → Fin n → ℝ) (mu : ℝ)
    (v : Fin n → ℝ) (hev : IsTropEigenpair L mu v) (k : ℕ) (i : Fin n) :
    (k + 1 : ℝ) * mu ≤ cycleCost L k i := by
  convert eigenvector_lower_bound L mu v hev k i i using 1 ; ring

/-
If (mu, v) is a tropical eigenpair, then mu le cycleMean L k i
    for all cycle lengths k+1 and vertices i.
-/
theorem eigenpair_le_cycleMean (L : Fin n → Fin n → ℝ) (mu : ℝ) (v : Fin n → ℝ)
    (hev : IsTropEigenpair L mu v) (k : ℕ) (i : Fin n) :
    mu ≤ cycleMean L k i := by
  exact le_div_iff₀' ( Nat.cast_add_one_pos _ ) |>.2 ( eigenpair_cycle_lower_bound L mu v hev k i )

/-
A tropical eigenpair eigenvalue is at most the tropical eigenvalue.
-/
theorem eigenpair_implies_eigenvalue_le (L : Fin n → Fin n → ℝ) (mu : ℝ)
    (v : Fin n → ℝ) (hev : IsTropEigenpair L mu v) :
    mu ≤ tropEigenvalue L := by
  convert Finset.le_inf' _ _ _;
  exact fun p _ => eigenpair_le_cycleMean L mu v hev _ _

-- ============================================================
-- Lipschitz continuity
-- ============================================================

/-- The min-cost path is Lipschitz in the Lagrangian: if all entries
    of L1 and L2 differ by at most eps, then min-cost paths differ
    by at most (N+1)*eps. -/
theorem minCostPath_lipschitz (L1 L2 : Fin n → Fin n → ℝ) (eps : ℝ)
    (heps : ∀ i j, |L1 i j - L2 i j| ≤ eps) (N : ℕ) (i j : Fin n) :
    |minCostPath L1 N i j - minCostPath L2 N i j| ≤ (N + 1 : ℝ) * eps := by
  induction' N with N ih generalizing i j
  · simpa [minCostPath] using heps i j
  · have h_inf : ∀ (f g : Fin n → ℝ), ∀ (i : Fin n),
        |Finset.univ.inf' Finset.univ_nonempty f - Finset.univ.inf' Finset.univ_nonempty g| ≤
        Finset.univ.sup' Finset.univ_nonempty (fun i => |f i - g i|) := by
      intros f g i
      have h1 : ∀ (k : Fin n), f k ≥ Finset.univ.inf' Finset.univ_nonempty g -
          Finset.univ.sup' Finset.univ_nonempty (fun i => |f i - g i|) := by
        intro k
        linarith [abs_le.mp (Finset.le_sup' (fun i => |f i - g i|) (Finset.mem_univ k)),
                  Finset.inf'_le (fun i => g i) (Finset.mem_univ k)]
      have h2 : Finset.univ.inf' Finset.univ_nonempty f ≥ Finset.univ.inf' Finset.univ_nonempty g -
          Finset.univ.sup' Finset.univ_nonempty (fun i => |f i - g i|) := by
        exact Finset.le_inf' _ _ fun k hk => h1 k
      have h3 : ∀ (k : Fin n), g k ≥ Finset.univ.inf' Finset.univ_nonempty f -
          Finset.univ.sup' Finset.univ_nonempty (fun i => |f i - g i|) := by
        intros k
        have : g k ≥ f k - |f k - g k| := by
          cases abs_cases (f k - g k) <;> linarith
        exact le_trans (sub_le_sub (Finset.inf'_le _ (Finset.mem_univ k))
          (Finset.le_sup' (fun i => |f i - g i|) (Finset.mem_univ k))) this
      have h4 : Finset.univ.inf' Finset.univ_nonempty g ≥ Finset.univ.inf' Finset.univ_nonempty f -
          Finset.univ.sup' Finset.univ_nonempty (fun i => |f i - g i|) := by
        exact Finset.le_inf' _ _ fun k hk => h3 k
      exact abs_sub_le_iff.mpr ⟨by linarith, by linarith⟩
    refine le_trans (h_inf _ _ i) (Finset.sup'_le _ _ ?_)
    intro k hk; rw [abs_le]; constructor <;> push_cast <;>
      linarith [abs_le.mp (ih i k), abs_le.mp (heps k j)]

/-
**Tropical Eigenvalue Lipschitz Continuity**: The tropical eigenvalue
    is 1-Lipschitz in the sup-norm of the Lagrangian.
-/
theorem tropEigenvalue_lipschitz (L1 L2 : Fin n → Fin n → ℝ) (eps : ℝ)
    (heps : ∀ i j, |L1 i j - L2 i j| ≤ eps) (_heps_nn : 0 ≤ eps) :
    |tropEigenvalue L1 - tropEigenvalue L2| ≤ eps := by
  -- By minCostPath_lipschitz, we have |cycleMean L1 k.val i - cycleMean L2 k.val i| ≤ eps.
  have h_cycleMean_lipschitz : ∀ k : Fin n, ∀ i : Fin n, |cycleMean L1 k.val i - cycleMean L2 k.val i| ≤ eps := by
    -- By minCostPath_lipschitz, we have |cycleCost L1 k.val i - cycleCost L2 k.val i| ≤ (k.val + 1) * eps.
    have h_cycleCost_lipschitz : ∀ k : Fin n, ∀ i : Fin n, |cycleCost L1 k.val i - cycleCost L2 k.val i| ≤ (k.val + 1) * eps := by
      intro k i;
      convert minCostPath_lipschitz L1 L2 eps heps k i i using 1;
    intro k i; rw [ cycleMean, cycleMean ] ; rw [ abs_le ] ; constructor <;> nlinarith [ abs_le.mp ( h_cycleCost_lipschitz k i ), show ( k : ℝ ) + 1 > 0 by positivity, mul_div_cancel₀ ( cycleCost L1 ( k : ℕ ) i ) ( by positivity : ( k : ℝ ) + 1 ≠ 0 ), mul_div_cancel₀ ( cycleCost L2 ( k : ℕ ) i ) ( by positivity : ( k : ℝ ) + 1 ≠ 0 ) ] ;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ k, i, hk ⟩ := tropEigenvalue_achieved L2;
    linarith [ abs_le.mp ( h_cycleMean_lipschitz k i ), show tropEigenvalue L1 ≤ cycleMean L1 k.val i from TropicalAction.tropEigenvalue_le_cycleMean L1 k i ];
  · obtain ⟨ k, i, hk ⟩ := TropicalAction.tropEigenvalue_achieved L1;
    linarith [ abs_le.mp ( h_cycleMean_lipschitz k i ), TropicalAction.tropEigenvalue_le_cycleMean L2 k i ]

end

end TropicalAction