import Mathlib

/-!
# Round-7 closure DIGITLATTICE: the digit-convolution relaxation is not isolated

Experiment 328 linearised the base-`b` digit equations of `N = p q` by setting
`w_{ij} = p_i q_j` and observed that the factorisation target sits *at* the
Gaussian heuristic, so lattice reduction returns generic short vectors instead
of the factorisation.  This file proves the exact structural reason, in the
smallest nontrivial case (two digits per factor), and it is a statement about
*all* `N`, not a heuristic:

* `digitVal_rankOne` : the encoding is faithful — the digit convolution of a
  rank-one matrix `w = u ⊗ v` evaluates to the product of the two numbers
  `u₀ + u₁ b` and `v₀ + v₁ b`.  Factorisations are exactly the rank-one
  solutions.
* `det_rankOne` : rank-one matrices have vanishing determinant; the determinant
  is therefore the obstruction that the linear relaxation throws away.
* `commutator_digitVal` : the "carry commutator" `w = [[0,1],[-1,0]]` lies in the
  kernel of the digit functional for *every* base `b`.  It has squared norm `2`,
  a constant independent of `N`.
* `exists_spurious_solution` : consequently every factorisation target has a
  **non-rank-one companion solution at squared distance at most `8`** — the
  relaxed problem has spurious solutions in an `O(1)` ball around the target,
  whatever the size of `N`.  Since the target's own squared norm grows like the
  product of the digit norms (`sqNorm_rankOne_ge_four` gives the first step),
  short-vector search cannot separate the factorisation from the noise.
-/

namespace Round7DigitLattice

open Finset

/-- The digit-convolution functional in base `b`: `w ↦ Σ_{i,j} w_{ij} b^{i+j}`,
for two-digit factors. -/
def digitVal (b : ℤ) (w : Matrix (Fin 2) (Fin 2) ℤ) : ℤ :=
  ∑ i : Fin 2, ∑ j : Fin 2, w i j * b ^ ((i : ℕ) + (j : ℕ))

/-- The rank-one (genuine factorisation) matrix `u ⊗ v`. -/
def rankOne (u v : Fin 2 → ℤ) : Matrix (Fin 2) (Fin 2) ℤ := fun i j => u i * v j

/-- The two-digit number encoded by a digit vector. -/
def digitNum (b : ℤ) (u : Fin 2 → ℤ) : ℤ := u 0 + u 1 * b

/-- **Faithfulness of the encoding.** The relaxation variable `w = u ⊗ v`
evaluates to the product of the two encoded numbers: rank-one solutions of the
digit equation are exactly the factorisations. -/
theorem digitVal_rankOne (b : ℤ) (u v : Fin 2 → ℤ) :
    digitVal b (rankOne u v) = digitNum b u * digitNum b v := by
  simp [digitVal, rankOne, digitNum, Fin.sum_univ_two, pow_succ]
  ring

/-- **The discarded constraint.** Rank-one matrices are exactly the ones the
determinant kills; the linear relaxation cannot see it. -/
theorem det_rankOne (u v : Fin 2 → ℤ) : (rankOne u v).det = 0 := by
  rw [Matrix.det_fin_two]
  simp [rankOne]
  ring

/-- The carry commutator `[[0,1],[-1,0]]`. -/
def commMat : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; -1, 0]

/-- **The commutator is in the kernel** of the digit functional, for every base:
`b^{0+1} - b^{1+0} = 0`.  This is the degeneracy created by linearisation. -/
theorem commutator_digitVal (b : ℤ) : digitVal b commMat = 0 := by
  simp [digitVal, commMat, Fin.sum_univ_two]

/-- The squared Frobenius norm of a digit matrix. -/
def sqNorm (w : Matrix (Fin 2) (Fin 2) ℤ) : ℤ := ∑ i : Fin 2, ∑ j : Fin 2, (w i j) ^ 2

theorem sqNorm_commMat : sqNorm commMat = 2 := by
  simp [sqNorm, commMat, Fin.sum_univ_two]

/-- The target's squared norm is the product of the digit norms; in particular a
target with all digits nonzero has squared norm at least `4`, and it grows with
the digits, whereas the perturbation below stays of size `O(1)`. -/
theorem sqNorm_rankOne (u v : Fin 2 → ℤ) :
    sqNorm (rankOne u v) = (u 0 ^ 2 + u 1 ^ 2) * (v 0 ^ 2 + v 1 ^ 2) := by
  simp [sqNorm, rankOne, Fin.sum_univ_two]
  ring

private theorem one_le_sq {a : ℤ} (ha : a ≠ 0) : 1 ≤ a ^ 2 := by
  rcases lt_or_gt_of_ne ha with h | h <;> nlinarith

theorem sqNorm_rankOne_ge_four {u v : Fin 2 → ℤ} (hu0 : u 0 ≠ 0) (hu1 : u 1 ≠ 0)
    (hv0 : v 0 ≠ 0) (hv1 : v 1 ≠ 0) : 4 ≤ sqNorm (rankOne u v) := by
  rw [sqNorm_rankOne]
  have h1 : 1 ≤ u 0 ^ 2 := one_le_sq hu0
  have h2 : 1 ≤ u 1 ^ 2 := one_le_sq hu1
  have h3 : 1 ≤ v 0 ^ 2 := one_le_sq hv0
  have h4 : 1 ≤ v 1 ^ 2 := one_le_sq hv1
  nlinarith

/-- **Spurious solutions surround every target.** For every factorisation target
`u ⊗ v` there is a matrix `w` with the *same* digit value (hence a solution of
the relaxed system for the same `N`), with **nonzero determinant** — so `w` is
not a factorisation — at squared distance at most `8` from the target,
independently of the size of `N`.  The relaxed lattice problem therefore cannot
isolate the factorisation. -/
theorem exists_spurious_solution (b : ℤ) (u v : Fin 2 → ℤ) :
    ∃ w : Matrix (Fin 2) (Fin 2) ℤ,
      digitVal b w = digitVal b (rankOne u v) ∧ w.det ≠ 0 ∧
        sqNorm (w - rankOne u v) ≤ 8 := by
  -- perturb the target by `c • commMat` with `c ∈ {1, 2}`
  have key : ∀ c : ℤ, digitVal b (rankOne u v + c • commMat) = digitVal b (rankOne u v) := by
    intro c
    simp [digitVal, Fin.sum_univ_two, commMat, Matrix.add_apply]
    ring
  have hdet : ∀ c : ℤ, (rankOne u v + c • commMat).det
      = c * (u 0 * v 1 - u 1 * v 0) + c ^ 2 := by
    intro c
    rw [Matrix.det_fin_two]
    simp [rankOne, commMat, Matrix.add_apply]
    ring
  have hdist : ∀ c : ℤ, sqNorm ((rankOne u v + c • commMat) - rankOne u v) = 2 * c ^ 2 := by
    intro c
    have : (rankOne u v + c • commMat) - rankOne u v = c • commMat := by
      abel
    rw [this]
    simp [sqNorm, commMat, Matrix.smul_apply, Fin.sum_univ_two]
    ring
  set D : ℤ := u 0 * v 1 - u 1 * v 0 with hD
  by_cases hD1 : D + 1 = 0
  · -- use `c = 2`
    refine ⟨rankOne u v + (2 : ℤ) • commMat, key 2, ?_, ?_⟩
    · have hDv : D = -1 := by omega
      rw [hdet 2, hDv]; norm_num
    · rw [hdist 2]; norm_num
  · -- use `c = 1`
    refine ⟨rankOne u v + (1 : ℤ) • commMat, key 1, ?_, ?_⟩
    · rw [hdet 1]
      simpa using hD1
    · rw [hdist 1]; norm_num

end Round7DigitLattice