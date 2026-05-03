import Mathlib
import Cryptography.BerggrenSL2.MatRed

/-!
# Cayley–Hamilton for 2×2 Matrices and Characteristic Polynomial

We specialize the Cayley–Hamilton theorem to 2×2 matrices,
deriving the characteristic polynomial and the matrix equation
`g² = tr(g)·g - det(g)·I` which underlies both the trace
recurrence (used for power injectivity) and the finite-field
order analysis.
-/

open Matrix Polynomial

/-- The characteristic polynomial of a 2×2 matrix over a commutative ring
is `X² - tr(M)·X + det(M)`. This is Mathlib's `Matrix.charpoly_fin_two`
specialized to our setting. -/
theorem charpoly_SL2 {R : Type*} [CommRing R] [Nontrivial R]
    (M : Matrix (Fin 2) (Fin 2) R) :
    M.charpoly = X ^ 2 - C (Matrix.trace M) * X + C M.det :=
  Matrix.charpoly_fin_two M

/-
The Cayley–Hamilton identity for a 2×2 matrix with `det M = 1`:
`M² = tr(M) • M - 1`. This is the engine behind the trace recurrence.
-/
theorem cayleyHamilton_det_one {R : Type*} [CommRing R] [Nontrivial R]
    (M : Matrix (Fin 2) (Fin 2) R)
    (hdet : M.det = 1) :
    M ^ 2 = (Matrix.trace M) • M - 1 := by
  simp_all +decide [ sq, mul_two, mul_sub, sub_mul ];
  ext i j; fin_cases i <;> fin_cases j <;> simp +decide [ Matrix.det_fin_two, Matrix.trace_fin_two ] at *;
  · rw [ ← hdet ] ; norm_num [ Matrix.mul_apply ] ; ring;
  · simp +decide [ Matrix.mul_apply ] ; ring;
  · simp +decide [ Matrix.mul_apply, add_mul ];
    ring;
  · rw [ ← hdet ] ; norm_num [ Matrix.mul_apply ] ; ring

/-- The Cayley–Hamilton identity over `ZMod p` for a reduced matrix. -/
theorem cayleyHamilton_matRed
    {p : ℕ} [hp : Fact p.Prime]
    (g : Matrix (Fin 2) (Fin 2) ℤ)
    (hdet : g.det = 1) :
    (matRed p g) ^ 2 = (Matrix.trace (matRed p g)) • (matRed p g) - 1 := by
  exact cayleyHamilton_det_one (matRed p g) (det_matRed g hdet)

/-
For a matrix satisfying `M² = t·M - 1`, we can express `M^(n+2)` in terms
of `M^(n+1)` and `M^n`. This recurrence is key for analyzing the order of `M`.
-/
theorem pow_recurrence_from_cayley {R : Type*} [CommRing R]
    (M : Matrix (Fin 2) (Fin 2) R)
    (t : R)
    (hCH : M ^ 2 = t • M - 1)
    (n : ℕ) :
    M ^ (n + 2) = t • M ^ (n + 1) - M ^ n := by
  induction n <;> simp_all +decide [ pow_succ', mul_assoc, sub_mul, mul_sub, smul_mul_assoc ]