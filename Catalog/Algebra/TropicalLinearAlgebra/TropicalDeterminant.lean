/-
# The tropical determinant

Over the max-plus semiring the determinant of `A` (there being no signs) is

  `tdet A = max_{σ ∈ S_ι} Σ_i A i (σ i)`,

i.e. the value of the **optimal assignment problem** for the weight matrix `A`.

Main results:

* `tdet_isGreatest` : the tropical determinant *is* the weight of a maximum-weight
  permutation, and that maximum is attained;
* `tdet_transpose`  : invariance under transposition;
* `tdet_tmul_ge`    : **supermultiplicativity** `tdet A + tdet B ≤ tdet (A ⊗ B)`
  (the tropical Cauchy–Binet inequality); equality can fail — see
  `TropicalLA.Examples.tdet_tmul_strict` in `Examples.lean`;
* `tdet_diag_le` and `tdet_eq_trace_of_diagonally_dominant` : the diagonal always
  gives a lower bound, with equality under a Monge-type dominance condition.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalMatrix

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The weight of the permutation `σ` in the matrix `A`. -/
def permWeight (A : Matrix ι ι ℝ) (σ : Equiv.Perm ι) : ℝ := ∑ i, A i (σ i)

/-- The **tropical determinant**: the maximal weight of a permutation. -/
noncomputable def tdet (A : Matrix ι ι ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (permWeight A)

theorem permWeight_le_tdet (A : Matrix ι ι ℝ) (σ : Equiv.Perm ι) : permWeight A σ ≤ tdet A :=
  Finset.le_sup' (permWeight A) (Finset.mem_univ σ)

theorem exists_permWeight_eq_tdet (A : Matrix ι ι ℝ) : ∃ σ, tdet A = permWeight A σ := by
  obtain ⟨σ, _, hσ⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := Equiv.Perm ι)) (permWeight A)
  exact ⟨σ, hσ⟩

/-- **The tropical determinant is the weight of a maximum-weight permutation.** -/
theorem tdet_isGreatest (A : Matrix ι ι ℝ) :
    IsGreatest {w : ℝ | ∃ σ : Equiv.Perm ι, w = permWeight A σ} (tdet A) := by
  refine ⟨?_, ?_⟩
  · obtain ⟨σ, hσ⟩ := exists_permWeight_eq_tdet A
    exact ⟨σ, hσ⟩
  · rintro w ⟨σ, rfl⟩
    exact permWeight_le_tdet A σ

/-- The determinant is unchanged by transposition: `σ ↦ σ⁻¹` matches the two families. -/
theorem tdet_transpose (A : Matrix ι ι ℝ) : tdet A.transpose = tdet A := by
  have key : ∀ (B : Matrix ι ι ℝ), tdet B.transpose ≤ tdet B := by
    intro B
    refine Finset.sup'_le _ _ fun σ _ => ?_
    have : permWeight B.transpose σ = permWeight B σ⁻¹ := by
      unfold permWeight
      rw [← Equiv.sum_comp σ (fun j => B j (σ⁻¹ j))]
      refine Finset.sum_congr rfl fun i _ => ?_
      simp [Matrix.transpose_apply]
    rw [this]
    exact permWeight_le_tdet B σ⁻¹
  refine le_antisymm (key A) ?_
  simpa using key A.transpose

/-- **Tropical supermultiplicativity (Cauchy–Binet inequality)**:
`tdet A + tdet B ≤ tdet (A ⊗ B)`.

The proof composes an optimal permutation for `A` with one for `B`: the product
matrix contains at least the composite assignment as one of its choices. -/
theorem tdet_tmul_ge [Nonempty ι] (A B : Matrix ι ι ℝ) : tdet A + tdet B ≤ tdet (tmul A B) := by
  obtain ⟨σ, hσ⟩ := exists_permWeight_eq_tdet A
  obtain ⟨τ, hτ⟩ := exists_permWeight_eq_tdet B
  have hB : permWeight B τ = ∑ i, B (σ i) (τ (σ i)) := by
    unfold permWeight
    rw [← Equiv.sum_comp σ (fun j => B j (τ j))]
  have hkey : permWeight A σ + permWeight B τ ≤ permWeight (tmul A B) (σ.trans τ) := by
    rw [hB]
    simp only [permWeight, Equiv.trans_apply, ← Finset.sum_add_distrib]
    exact Finset.sum_le_sum fun i _ => le_tmul A B i (τ (σ i)) (σ i)
  rw [hσ, hτ]
  exact le_trans hkey (permWeight_le_tdet _ _)

/-- Reindexing: the weights of `A` along permutations are exactly the sums used above,
so the identity permutation gives the trace bound. -/
theorem tdet_diag_le (A : Matrix ι ι ℝ) : ∑ i, A i i ≤ tdet A :=
  permWeight_le_tdet A 1

/-- If every off-diagonal entry is dominated by the corresponding diagonal entry
in the strong (row-wise) sense `A i j ≤ A i i` for all `j`, then the tropical
determinant is the tropical trace `Σ_i A i i`. -/
theorem tdet_eq_diag_of_dominant (A : Matrix ι ι ℝ) (h : ∀ i j, A i j ≤ A i i) :
    tdet A = ∑ i, A i i := by
  refine le_antisymm (Finset.sup'_le _ _ fun σ _ => ?_) (tdet_diag_le A)
  exact Finset.sum_le_sum fun i _ => h i (σ i)

end TropicalLA