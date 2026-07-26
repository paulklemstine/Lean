/-
# Extremal Determinants of `4 × 4` Integer Matrices with Bounded Entries

For a bound `B ≥ 0`, consider the integer matrices whose entries all lie in the
symmetric range `{-B, …, B}`.  How large can the determinant be?

This file studies the order‑`4` case, which is the smallest order for which a
*Hadamard matrix* exists and hence the first genuinely interesting instance of
the classical **maximal determinant problem**.

The headline results are:

* `hadamardMat_det` — an explicit `±B` matrix (a scaled order‑`4` Hadamard
  matrix) attains determinant `16 · B⁴`.  Its rows are mutually orthogonal
  (`hadamardMat_mul_transpose`), which is exactly the algebraic reason the
  determinant is as large as it can be.
* `abs_det_four_le` — every `4 × 4` matrix with entries bounded by `B` has
  `|det| ≤ 24 · B⁴` (the Leibniz/permutation bound, a specialisation of the
  general order‑`n` estimate `abs_det_le_factorial`).
* `maxDet_lower`, `maxDet_upper` — combining the two, the maximum determinant
  `M(B)` over this family satisfies `16 · B⁴ ≤ M(B) ≤ 24 · B⁴`, and the lower
  end is achieved.
* `claimed_lt_true` — the quantity `(2k-1)⁴ - 2(2k-1)² + 1`, once floated as a
  candidate for the maximum on the range `{-(2k-1), …, 2k-1}`, is not even an
  upper bound: for every `k ≥ 1` the explicit construction already exceeds it
  (and for `k = 1` the candidate is `0`, while the true value is `16`).

The exact value of `M(B)` is `16 · B⁴`; pinning the upper bound down from `24`
to `16` is precisely Hadamard's inequality (equivalently the Hadamard–Fischer
determinant inequality for positive‑semidefinite matrices), recorded as a future
direction.

-- !-- Lab Notes -- !--
-- Hypothesis: On the symmetric entry range of radius `B`, the largest `4 × 4`
--   determinant is `16 · B⁴`, achieved by a scaled Hadamard matrix, and the
--   originally circulated formula `(2k-1)⁴ - 2(2k-1)² + 1` is incorrect.
-- Experiment: Built the explicit `±B` Hadamard matrix and computed its
--   determinant (`16 B⁴`) and Gram matrix (`4B² · I`, i.e. orthogonal rows).
--   Bounded a generic determinant by the permutation sum (`24 B⁴`).  Evaluated
--   the circulated formula at `k = 1`: it gives `0`, whereas the construction
--   gives `16`.
-- Analysis: The construction is a true lower bound and the permutation sum a
--   true upper bound, bracketing the maximum in `[16 B⁴, 24 B⁴]`.  Orthogonality
--   of the rows is the structural certificate for the lower bound: it forces
--   `(det)² = det(A Aᵀ) = (4B²)⁴`.  The circulated formula is false — it
--   under‑counts by an order of magnitude and is negative-to-zero for small `k`.
-- Critique: The bracket is honest but not tight; the gap `24 → 16` is exactly
--   Hadamard's inequality, which is a nontrivial analytic input.  No theorem
--   here is vacuous: each has explicit numerical witnesses and the refutation is
--   a strict inequality with a concrete matrix.
-- Synthesis: A clean, self-contained account of the order-`4` maximal
--   determinant problem: exact achievability, a permutation upper bound, the
--   orthogonality certificate, and a rigorous refutation of the circulated
--   formula.
-- !-- End Lab Notes -- !--
-/
import Mathlib

set_option maxHeartbeats 800000

open Matrix
open scoped Nat

namespace MaxDeterminant4x4

/-- Explicit cofactor expansion of a `4 × 4` determinant along the first row. -/
theorem det_fin_four {R : Type*} [CommRing R] (M : Matrix (Fin 4) (Fin 4) R) :
    M.det =
      M 0 0 * (M 1 1 * (M 2 2 * M 3 3 - M 2 3 * M 3 2) - M 1 2 * (M 2 1 * M 3 3 - M 2 3 * M 3 1) + M 1 3 * (M 2 1 * M 3 2 - M 2 2 * M 3 1))
    - M 0 1 * (M 1 0 * (M 2 2 * M 3 3 - M 2 3 * M 3 2) - M 1 2 * (M 2 0 * M 3 3 - M 2 3 * M 3 0) + M 1 3 * (M 2 0 * M 3 2 - M 2 2 * M 3 0))
    + M 0 2 * (M 1 0 * (M 2 1 * M 3 3 - M 2 3 * M 3 1) - M 1 1 * (M 2 0 * M 3 3 - M 2 3 * M 3 0) + M 1 3 * (M 2 0 * M 3 1 - M 2 1 * M 3 0))
    - M 0 3 * (M 1 0 * (M 2 1 * M 3 2 - M 2 2 * M 3 1) - M 1 1 * (M 2 0 * M 3 2 - M 2 2 * M 3 0) + M 1 2 * (M 2 0 * M 3 1 - M 2 1 * M 3 0)) := by
  simp [Matrix.det_succ_row_zero, Fin.sum_univ_succ, Matrix.submatrix_apply, Fin.succAbove]
  ring

/-! ## The extremal construction: a scaled order-`4` Hadamard matrix -/

/-- A scaled order-`4` Hadamard matrix: all entries are `±B` and the rows are
mutually orthogonal. -/
def hadamardMat (B : ℤ) : Matrix (Fin 4) (Fin 4) ℤ :=
  !![B, B, B, B; B, -B, B, -B; B, B, -B, -B; B, -B, -B, B]

/-- The construction realises determinant `16 · B⁴`. -/
theorem hadamardMat_det (B : ℤ) : (hadamardMat B).det = 16 * B ^ 4 := by
  rw [det_fin_four]; simp [hadamardMat]; ring

/-- Every entry of the construction has absolute value `|B|`. -/
theorem hadamardMat_entry_abs (B : ℤ) (i j : Fin 4) : |hadamardMat B i j| = |B| := by
  fin_cases i <;> fin_cases j <;> simp [hadamardMat, abs_neg]

/-- For `B ≥ 0`, every entry lies in the symmetric range `{-B, …, B}`. -/
theorem hadamardMat_entry_le (B : ℤ) (hB : 0 ≤ B) (i j : Fin 4) : |hadamardMat B i j| ≤ B := by
  rw [hadamardMat_entry_abs, abs_of_nonneg hB]

/-- The rows of the construction are mutually orthogonal: `A Aᵀ = 4B² · I`.
This orthogonality is the structural certificate that the determinant is
extremal, since it forces `(det A)² = det(A Aᵀ) = (4B²)⁴`. -/
theorem hadamardMat_mul_transpose (B : ℤ) :
    (hadamardMat B) * (hadamardMat B)ᵀ = (4 * B ^ 2) • (1 : Matrix (Fin 4) (Fin 4) ℤ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [hadamardMat, Matrix.mul_apply, Fin.sum_univ_four] <;> ring

/-! ## Upper bounds via the permutation expansion -/

/-- **Leibniz bound.** If every entry of an `n × n` integer matrix has absolute
value at most `B`, then `|det| ≤ n! · Bⁿ`. -/
theorem abs_det_le_factorial {n : Type*} [Fintype n] [DecidableEq n]
    (A : Matrix n n ℤ) (B : ℤ) (h : ∀ i j, |A i j| ≤ B) :
    |A.det| ≤ (Fintype.card n)! * B ^ (Fintype.card n) := by
  have := Matrix.det_le (A := A) (abv := AbsoluteValue.abs) (x := B) (fun i j => h i j)
  simpa [nsmul_eq_mul] using this

/-- Order-`4` specialisation: `|det| ≤ 24 · B⁴`. -/
theorem abs_det_four_le (A : Matrix (Fin 4) (Fin 4) ℤ) (B : ℤ) (h : ∀ i j, |A i j| ≤ B) :
    |A.det| ≤ 24 * B ^ 4 := by
  have := Matrix.det_le (A := A) (abv := AbsoluteValue.abs) (x := B) (fun i j => h i j)
  simpa using this

/-- Two-sided form of the order-`4` bound. -/
theorem det_four_le (A : Matrix (Fin 4) (Fin 4) ℤ) (B : ℤ) (h : ∀ i j, |A i j| ≤ B) :
    A.det ≤ 24 * B ^ 4 :=
  (abs_le.1 (abs_det_four_le A B h)).2

/-! ## The maximum, bracketed -/

/-- **Lower bound on the maximum.** For `B ≥ 0` there is an admissible matrix
whose determinant equals `16 · B⁴`; hence the maximum determinant over the
family is at least `16 · B⁴`. -/
theorem maxDet_lower (B : ℤ) (hB : 0 ≤ B) :
    ∃ A : Matrix (Fin 4) (Fin 4) ℤ, (∀ i j, |A i j| ≤ B) ∧ A.det = 16 * B ^ 4 :=
  ⟨hadamardMat B, hadamardMat_entry_le B hB, hadamardMat_det B⟩

/-- **Upper bound on the maximum.** Every admissible matrix has determinant at
most `24 · B⁴`. -/
theorem maxDet_upper (B : ℤ) :
    ∀ A : Matrix (Fin 4) (Fin 4) ℤ, (∀ i j, |A i j| ≤ B) → A.det ≤ 24 * B ^ 4 :=
  fun A h => det_four_le A B h

/-- The maximum determinant `M(B)` is bracketed: `16 · B⁴ ≤ M(B) ≤ 24 · B⁴`,
with the lower end attained by an explicit construction. -/
theorem maxDet_bracket (B : ℤ) (hB : 0 ≤ B) :
    ∃ A : Matrix (Fin 4) (Fin 4) ℤ,
      (∀ i j, |A i j| ≤ B) ∧ A.det = 16 * B ^ 4 ∧
      (∀ A' : Matrix (Fin 4) (Fin 4) ℤ, (∀ i j, |A' i j| ≤ B) → A'.det ≤ 24 * B ^ 4) :=
  ⟨hadamardMat B, hadamardMat_entry_le B hB, hadamardMat_det B, maxDet_upper B⟩

/-- Determinants scale as the fourth power of the entry bound. -/
theorem det_smul_four (c : ℤ) (M : Matrix (Fin 4) (Fin 4) ℤ) :
    (c • M).det = c ^ 4 * M.det := by
  rw [Matrix.det_smul]; simp

/-! ## Refuting the circulated formula -/

/-- The circulated candidate maximum `(2k-1)⁴ - 2(2k-1)² + 1` for the range
`{-(2k-1), …, 2k-1}` is not even an upper bound: for every `k ≥ 1` the explicit
construction already achieves a strictly larger determinant. -/
theorem claimed_lt_true (k : ℤ) (hk : 1 ≤ k) :
    ((2 * k - 1) ^ 4 - 2 * (2 * k - 1) ^ 2 + 1) < 16 * (2 * k - 1) ^ 4 := by
  nlinarith [sq_nonneg (2 * k - 1), sq_nonneg k, hk]

/-- Concrete refutation at `k = 1`: on the range `{-1, 0, 1}` the circulated
formula evaluates to `0`, yet there is an admissible matrix of determinant `16`. -/
theorem claimed_false_k_one :
    ∃ A : Matrix (Fin 4) (Fin 4) ℤ,
      (∀ i j, |A i j| ≤ (2 * 1 - 1 : ℤ)) ∧
      ((2 * 1 - 1 : ℤ) ^ 4 - 2 * (2 * 1 - 1) ^ 2 + 1) < A.det := by
  refine ⟨hadamardMat 1, hadamardMat_entry_le 1 (by norm_num), ?_⟩
  rw [hadamardMat_det]; norm_num

/-- Odd-radius specialisation: for `k ≥ 1`, on the range `{-(2k-1), …, 2k-1}`
there is a matrix of determinant `16 · (2k-1)⁴`, and every admissible matrix has
determinant at most `24 · (2k-1)⁴`. -/
theorem oddRange_bracket (k : ℤ) (hk : 1 ≤ k) :
    ∃ A : Matrix (Fin 4) (Fin 4) ℤ,
      (∀ i j, |A i j| ≤ 2 * k - 1) ∧ A.det = 16 * (2 * k - 1) ^ 4 ∧
      (∀ A' : Matrix (Fin 4) (Fin 4) ℤ, (∀ i j, |A' i j| ≤ 2 * k - 1) →
        A'.det ≤ 24 * (2 * k - 1) ^ 4) :=
  maxDet_bracket (2 * k - 1) (by linarith)

end MaxDeterminant4x4