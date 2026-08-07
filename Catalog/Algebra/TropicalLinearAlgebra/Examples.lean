/-
# Worked 2 × 2 examples and sharpness results

Concrete computations in the max-plus algebra of `2 × 2` real matrices.  These are the
"experimental data" behind the general theory: closed formulas for the tropical product
and determinant in dimension two, an explicit eigenpair, and a counterexample showing
that the supermultiplicativity `tdet A + tdet B ≤ tdet (A ⊗ B)` is **strict** in general
(so the tropical determinant is not multiplicative).
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalPerronFrobenius
import Algebra.TropicalLinearAlgebra.TropicalCharPoly

namespace TropicalLA
namespace Examples

/-- Suprema over a two-element index set are binary maxima. -/
theorem sup'_fin2 (f : Fin 2 → ℝ) :
    (Finset.univ : Finset (Fin 2)).sup' Finset.univ_nonempty f = max (f 0) (f 1) := by
  apply le_antisymm
  · refine Finset.sup'_le _ _ fun j _ => ?_
    fin_cases j
    · exact le_max_left _ _
    · exact le_max_right _ _
  · exact max_le (Finset.le_sup' f (Finset.mem_univ 0)) (Finset.le_sup' f (Finset.mem_univ 1))

/-- The two permutations of a two-element set. -/
theorem perm_fin2 : ∀ σ : Equiv.Perm (Fin 2), σ = 1 ∨ σ = Equiv.swap 0 1 := by decide

/-- Closed formula for the tropical product of `2 × 2` matrices. -/
theorem tmul_fin2 (A B : Matrix (Fin 2) (Fin 2) ℝ) (i j : Fin 2) :
    tmul A B i j = max (A i 0 + B 0 j) (A i 1 + B 1 j) := by
  rw [tmul]
  exact sup'_fin2 (fun k => A i k + B k j)

/-- Closed formula for the tropical determinant of a `2 × 2` matrix: the better of the
two assignments. -/
theorem tdet_fin2 (A : Matrix (Fin 2) (Fin 2) ℝ) :
    tdet A = max (A 0 0 + A 1 1) (A 0 1 + A 1 0) := by
  have h1 : permWeight A 1 = A 0 0 + A 1 1 := by
    simp [permWeight, Fin.sum_univ_two]
  have h2 : permWeight A (Equiv.swap 0 1) = A 0 1 + A 1 0 := by
    simp [permWeight, Fin.sum_univ_two, Equiv.swap_apply_left, Equiv.swap_apply_right]
  apply le_antisymm
  · refine Finset.sup'_le _ _ fun σ _ => ?_
    rcases perm_fin2 σ with h | h <;> subst h
    · rw [h1]; exact le_max_left _ _
    · rw [h2]; exact le_max_right _ _
  · refine max_le ?_ ?_
    · rw [← h1]; exact permWeight_le_tdet A 1
    · rw [← h2]; exact permWeight_le_tdet A (Equiv.swap 0 1)

/-- **The tropical determinant is not multiplicative.**  For
`A = [[0,0],[0,0]]` and `B = [[0,0],[-1,-1]]` one has
`tdet A + tdet B = -1 < 0 = tdet (A ⊗ B)`, so the supermultiplicativity
`tdet_tmul_ge` is strict. -/
theorem tdet_tmul_strict :
    ∃ A B : Matrix (Fin 2) (Fin 2) ℝ, tdet A + tdet B < tdet (tmul A B) := by
  refine ⟨Matrix.of ![![0, 0], ![0, 0]], Matrix.of ![![0, 0], ![-1, -1]], ?_⟩
  rw [tdet_fin2, tdet_fin2, tdet_fin2]
  simp only [tmul_fin2, Matrix.of_apply, Matrix.cons_val', Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.empty_val', Matrix.cons_val_fin_one]
  norm_num

/-- An explicit eigenpair: for `A = [[0,2],[2,0]]` the constant vector `0` is a tropical
eigenvector with eigenvalue `2`. -/
theorem isTropEigen_example :
    IsTropEigen (Matrix.of ![![(0 : ℝ), 2], ![2, 0]]) 2 ![0, 0] := by
  intro i
  rw [tmulVec]
  rw [sup'_fin2 (fun j => (Matrix.of ![![(0 : ℝ), 2], ![2, 0]]) i j + (![0, 0] : Fin 2 → ℝ) j)]
  fin_cases i <;> norm_num

/-- Consequently the maximum cycle mean of that matrix is `2`, and it is its unique
tropical eigenvalue. -/
theorem maxCycleMean_example : maxCycleMean (Matrix.of ![![(0 : ℝ), 2], ![2, 0]]) = 2 :=
  ((tropEigen_iff_eq_maxCycleMean _ 2).mp ⟨_, isTropEigen_example⟩).symm

/-- The characteristic polynomial of the example has `2` as a tropical root: the maximum
defining `p_A(2)` is attained at two different degrees. -/
theorem isTropicalRoot_example : IsTropicalRoot (Matrix.of ![![(0 : ℝ), 2], ![2, 0]]) 2 :=
  (eigen_isTropicalRoot isTropEigen_example).1

end Examples
end TropicalLA