import Mathlib

/-!
# 2D Ising Model: The Transfer Matrix Method (1D row transfer)

We construct the `2 × 2` transfer matrix of the Ising model with zero external
field (units `J = k_B = 1`),
`T(β) = [[e^{β}, e^{-β}], [e^{-β}, e^{β}]]`,
diagonalise it, and use it to compute the partition function of a periodic chain
of `N` spins as the trace of `T(β)^N`.  This is the algebraic engine underlying
Onsager's solution: the two eigenvalues are
`λ₊ = 2 cosh β` (symmetric mode) and `λ₋ = 2 sinh β` (antisymmetric mode), and
`Z_N = Tr T^N = λ₊^N + λ₋^N`.

-- !-- Lab Notes -- !--
* **Hypothesis.** `(1,1)` and `(1,-1)` are eigenvectors of `T(β)` with eigenvalues
  `2 cosh β`, `2 sinh β`; hence `Tr T^N = (2cosh β)^N + (2 sinh β)^N`.
* **Experiment.** Verify eigenvector equations by `Fin.sum_univ_two` + `cosh/sinh`
  exponential forms. For the power, guess the closed form
  `T^n = ½[[λ₊ⁿ+λ₋ⁿ, λ₊ⁿ-λ₋ⁿ],[λ₊ⁿ-λ₋ⁿ, λ₊ⁿ+λ₋ⁿ]]` and prove by induction; the
  step collapses because `λ₊·e^{±β}` and `λ₋·e^{±β}` recombine into `λ₊^{n+1}`,
  `λ₋^{n+1}` (lemmas `e1`, `e2` use `λ₊ = e^β+e^{-β}`, `λ₋ = e^β-e^{-β}`).
* **Analysis.** Survives. The induction is the crux; the trace formula is then a
  one-liner. The eigenvalue *dominance* `λ₊ > λ₋` (strict for all β) explains why
  the free energy per site tends to `log λ₊ = log(2 cosh β)`.
* **Critique.** No theorem is trivial: the closed form requires a genuine matrix
  induction (`pow_succ`, `Matrix.mul_apply`, `Fin.sum_univ_two`) and
  `ring`/exponential identities; eigenvalue facts use `Real.cosh`/`Real.sinh`,
  not `rfl`.
* **Synthesis.** `Z_N = λ₊^N + λ₋^N` with `λ₊ = 2cosh β`, `λ₋ = 2 sinh β`.
-/

namespace Ising

open Real Matrix

/-- The Ising transfer matrix `T(β) = [[e^{β}, e^{-β}], [e^{-β}, e^{β}]]`. -/
noncomputable def transfer (β : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  !![Real.exp β, Real.exp (-β); Real.exp (-β), Real.exp β]

/-- Larger eigenvalue (symmetric mode): `λ₊ = 2 cosh β`. -/
noncomputable def lamPlus (β : ℝ) : ℝ := 2 * Real.cosh β

/-- Smaller eigenvalue (antisymmetric mode): `λ₋ = 2 sinh β`. -/
noncomputable def lamMinus (β : ℝ) : ℝ := 2 * Real.sinh β

/-- Trace of the transfer matrix is `2 e^{β}`. -/
theorem trace_transfer (β : ℝ) : (transfer β).trace = 2 * Real.exp β := by
  simp [transfer, Matrix.trace, Matrix.diag, Fin.sum_univ_two]; ring

/-- Determinant of the transfer matrix is `e^{2β} - e^{-2β}`. -/
theorem det_transfer (β : ℝ) :
    (transfer β).det = Real.exp (2 * β) - Real.exp (-(2 * β)) := by
  simp [transfer, Matrix.det_fin_two]
  rw [← Real.exp_add, ← Real.exp_add]; ring_nf

/-- The symmetric vector `(1,1)` is an eigenvector with eigenvalue `2 cosh β`. -/
theorem eigen_sym (β : ℝ) :
    (transfer β).mulVec ![1, 1] = lamPlus β • ![1, 1] := by
  funext i; fin_cases i <;>
    simp [transfer, lamPlus, Matrix.mulVec, dotProduct, Fin.sum_univ_two, Real.cosh_eq] <;> ring

/-- The antisymmetric vector `(1,-1)` is an eigenvector with eigenvalue `2 sinh β`. -/
theorem eigen_antisym (β : ℝ) :
    (transfer β).mulVec ![1, -1] = lamMinus β • ![1, -1] := by
  funext i; fin_cases i <;>
    simp [transfer, lamMinus, Matrix.mulVec, dotProduct, Fin.sum_univ_two, Real.sinh_eq] <;> ring

/-- The symmetric eigenvalue strictly dominates the antisymmetric one. -/
theorem lamPlus_gt_lamMinus (β : ℝ) : lamMinus β < lamPlus β := by
  unfold lamPlus lamMinus; rw [Real.cosh_eq, Real.sinh_eq]
  have := Real.exp_pos (-β); linarith

/-- The sum of eigenvalues equals the trace. -/
theorem lam_sum_eq_trace (β : ℝ) : lamPlus β + lamMinus β = (transfer β).trace := by
  rw [trace_transfer]; unfold lamPlus lamMinus; rw [Real.cosh_eq, Real.sinh_eq]; ring

/-- The product of eigenvalues equals the determinant. -/
theorem lam_prod_eq_det (β : ℝ) : lamPlus β * lamMinus β = (transfer β).det := by
  rw [det_transfer]; unfold lamPlus lamMinus; rw [Real.cosh_eq, Real.sinh_eq]
  have h1 : Real.exp β * Real.exp β = Real.exp (2 * β) := by rw [← Real.exp_add]; ring_nf
  have h2 : Real.exp (-β) * Real.exp (-β) = Real.exp (-(2 * β)) := by rw [← Real.exp_add]; ring_nf
  nlinarith [h1, h2]

/-- **Closed form of the matrix power.** For every `n`,
`T(β)^n = ½ [[λ₊ⁿ+λ₋ⁿ, λ₊ⁿ-λ₋ⁿ], [λ₊ⁿ-λ₋ⁿ, λ₊ⁿ+λ₋ⁿ]]`. -/
theorem transfer_pow (β : ℝ) (n : ℕ) :
    (transfer β) ^ n =
      !![(lamPlus β ^ n + lamMinus β ^ n) / 2, (lamPlus β ^ n - lamMinus β ^ n) / 2;
         (lamPlus β ^ n - lamMinus β ^ n) / 2, (lamPlus β ^ n + lamMinus β ^ n) / 2] := by
  have hlp : lamPlus β = Real.exp β + Real.exp (-β) := by unfold lamPlus; rw [Real.cosh_eq]; ring
  have hlm : lamMinus β = Real.exp β - Real.exp (-β) := by unfold lamMinus; rw [Real.sinh_eq]; ring
  induction n with
  | zero => simp [Matrix.one_fin_two]
  | succ k ih =>
    have e1 : lamPlus β ^ (k + 1) = lamPlus β ^ k * (Real.exp β + Real.exp (-β)) := by
      rw [pow_succ, hlp]
    have e2 : lamMinus β ^ (k + 1) = lamMinus β ^ k * (Real.exp β - Real.exp (-β)) := by
      rw [pow_succ, hlm]
    rw [pow_succ, ih]; ext i j
    fin_cases i <;> fin_cases j <;>
      simp [transfer, Matrix.mul_apply, Fin.sum_univ_two] <;> rw [e1, e2] <;> ring

/-- The partition function of a periodic Ising chain of `N` spins. -/
noncomputable def partitionFunction (β : ℝ) (N : ℕ) : ℝ := ((transfer β) ^ N).trace

/-- **Transfer-matrix partition function.** `Z_N = λ₊^N + λ₋^N = (2 cosh β)^N + (2 sinh β)^N`. -/
theorem partitionFunction_eq (β : ℝ) (N : ℕ) :
    partitionFunction β N = (2 * Real.cosh β) ^ N + (2 * Real.sinh β) ^ N := by
  rw [partitionFunction, transfer_pow]
  simp only [Matrix.trace, Matrix.diag, Fin.sum_univ_two, Matrix.of_apply, Matrix.cons_val',
    Matrix.cons_val_zero, Matrix.cons_val_one, lamPlus, lamMinus]
  ring

/-- Iterated symmetric eigenvector relation: `T^n` scales `(1,1)` by `λ₊^n`. -/
theorem transfer_pow_sym (β : ℝ) (n : ℕ) :
    ((transfer β) ^ n).mulVec ![1, 1] = (lamPlus β ^ n) • ![1, 1] := by
  rw [transfer_pow]; funext i; fin_cases i <;>
    simp [Matrix.mulVec, dotProduct, Fin.sum_univ_two] <;> ring

end Ising