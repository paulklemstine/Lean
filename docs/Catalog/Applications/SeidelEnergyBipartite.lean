/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Seidel energy of complete bipartite graphs — a spectral/combinatorial bridge

The **Seidel matrix** of a graph `G` on vertex set `V` is the symmetric matrix
`S` with `S i i = 0`, `S i j = -1` when `i ~ j` and `S i j = +1` when `i ≠ j` and
`¬ i ~ j`.  Equivalently `S = J - I - 2A` where `A` is the adjacency matrix and `J`
the all-ones matrix.  The **Seidel energy** of `G` is `∑ |λ|` over the eigenvalues
`λ` of `S`.

For the complete bipartite graph `K_{m,n}` the vertex set is `Fin m ⊕ Fin n`, and
two distinct vertices are adjacent exactly when they lie in different parts.  Hence
the Seidel matrix has entry `+1` inside a part and `-1` across parts, i.e.

  `S i j = w i * w j - δ i j`,   where `w = (+1 on the left, -1 on the right)`.

This is the rank-one structure `S = w wᵀ - I` (a `vecMulVec` minus the identity).
This file exploits that structure to compute the entire Seidel spectrum and the
Seidel energy in closed form:

* `Sd_charpoly_factored` : the characteristic polynomial factors as
  `(X + 1)^{m+n-1} (X - (m+n-1))`, so the Seidel spectrum of `K_{m,n}` is
  `{ m+n-1 }` together with `-1` of multiplicity `m+n-1`;
* `seidelEnergy_Kmn` : **the Seidel energy of `K_{m,n}` equals `2(m+n-1)`**.

The bridge `energy_eq_roots` connects the analytic definition of energy (a sum of
absolute values of the `IsHermitian` eigenvalues) with the algebraic object
`charpoly.roots`, which is what makes the rank-one determinant computation usable.
-/
import Mathlib

open Matrix Polynomial
open scoped BigOperators

noncomputable section

namespace SeidelBipartite

/-- The ±1 weight vector cutting `Fin m ⊕ Fin n` into its two parts:
`+1` on the left part, `-1` on the right part. -/
def wt (m n : ℕ) : (Fin m ⊕ Fin n) → ℝ := Sum.elim (fun _ => 1) (fun _ => -1)

/-- The **Seidel matrix** of the complete bipartite graph `K_{m,n}`, written in its
rank-one form `w wᵀ - I`. Its `(i,j)` entry is `+1` inside a part, `-1` across
parts, and `0` on the diagonal. -/
def Sd (m n : ℕ) : Matrix (Fin m ⊕ Fin n) (Fin m ⊕ Fin n) ℝ :=
  vecMulVec (wt m n) (wt m n) - 1

/-- The **Seidel energy** of a real symmetric matrix: the sum of the absolute
values of its (real) eigenvalues. -/
def seidelEnergy {V : Type*} [Fintype V] [DecidableEq V]
    {A : Matrix V V ℝ} (hA : A.IsHermitian) : ℝ := ∑ i, |hA.eigenvalues i|

/-- The Seidel matrix is real symmetric. -/
theorem Sd_herm (m n : ℕ) : (Sd m n).IsHermitian := by
  unfold Matrix.IsHermitian Sd
  rw [conjTranspose_sub]; congr 1
  · ext i j; simp [vecMulVec, mul_comm]
  · simp

/-- **Bridge lemma.** The energy (an analytic sum over eigenvalues) equals the sum
of `|·|` over the roots of the characteristic polynomial (an algebraic object). -/
theorem energy_eq_roots {V : Type*} [Fintype V] [DecidableEq V]
    {A : Matrix V V ℝ} (hA : A.IsHermitian) :
    seidelEnergy hA = (A.charpoly.roots.map (fun x => |x|)).sum := by
  unfold seidelEnergy
  rw [hA.roots_charpoly_eq_eigenvalues, Multiset.map_map, Finset.sum]
  simp [Function.comp]

/-- Characteristic polynomial of the Seidel matrix, via the matrix determinant
lemma for the rank-one term (`charpoly_vecMulVec`) and the scalar shift
(`charpoly_sub_scalar`). -/
theorem Sd_charpoly (m n : ℕ) :
    (Sd m n).charpoly = (X + C 1)^(m+n) - ((m:ℝ)+n) • (X + C 1)^(m+n-1) := by
  have hcard : Fintype.card (Fin m ⊕ Fin n) = m + n := by simp
  have hdot : (wt m n) ⬝ᵥ (wt m n) = (m + n : ℝ) := by
    simp [wt, dotProduct, Fintype.sum_sum_type]
  unfold Sd
  have h1 : (1 : Matrix (Fin m ⊕ Fin n) (Fin m ⊕ Fin n) ℝ) = Matrix.scalar _ (1:ℝ) := by simp
  rw [h1, charpoly_sub_scalar, charpoly_vecMulVec, hcard, hdot]
  simp [sub_comp, pow_comp, smul_comp, X_comp, add_comm]

/-- The characteristic polynomial factors into linear pieces:
`(X+1)^{m+n-1} (X - (m+n-1))`. -/
theorem Sd_charpoly_factored (m n : ℕ) (hN : 1 ≤ m + n) :
    (Sd m n).charpoly = (X + C 1)^(m+n-1) * (X - C ((m:ℝ)+n-1)) := by
  rw [Sd_charpoly, smul_eq_C_mul]
  have hpow : (X + C (1:ℝ))^(m+n) = (X + C 1)^(m+n-1) * (X + C 1) := by
    conv_lhs => rw [show m+n = (m+n-1)+1 by omega]
    rw [pow_succ]
  rw [hpow]
  have hC : C ((m:ℝ)+n-1) = C ((m:ℝ)+n) - 1 := by
    rw [show ((m:ℝ)+n-1) = ((m:ℝ)+n) - 1 by ring, C_sub, C_1]
  rw [hC]; simp only [C_1]; ring

/-- The **Seidel spectrum** of `K_{m,n}` as a multiset: the eigenvalue `m+n-1`
(once) together with `-1` of multiplicity `m+n-1`. -/
theorem Sd_roots (m n : ℕ) (hN : 1 ≤ m + n) :
    (Sd m n).charpoly.roots = (m+n-1) • {(-1:ℝ)} + {((m:ℝ)+n-1)} := by
  rw [Sd_charpoly_factored m n hN,
     roots_mul (mul_ne_zero (pow_ne_zero _ (by intro h; simpa using congrArg (fun p => p.eval 0) h))
       (X_sub_C_ne_zero _)), roots_pow]
  have : (X + C (1:ℝ)).roots = {(-1:ℝ)} := by simpa using roots_X_add_C (1:ℝ)
  rw [this, roots_X_sub_C]

/-- **Main theorem.** The Seidel energy of the complete bipartite graph `K_{m,n}`
(for `m + n ≥ 1`) equals `2 (m + n - 1)`.  This is a closed-form spectral
invariant of a purely combinatorial object, obtained from the rank-one structure
of the Seidel matrix. -/
theorem seidelEnergy_Kmn (m n : ℕ) (hN : 1 ≤ m + n) :
    seidelEnergy (Sd_herm m n) = 2 * ((m:ℝ) + n - 1) := by
  rw [energy_eq_roots, Sd_roots m n hN]
  have ha : (0:ℝ) ≤ (m:ℝ)+n-1 := by
    have : (1:ℝ) ≤ (m:ℝ)+n := by exact_mod_cast hN
    linarith
  rw [Multiset.map_add, Multiset.sum_add, Multiset.map_nsmul, Multiset.sum_nsmul]
  simp only [Multiset.map_singleton, Multiset.sum_singleton, abs_neg, abs_one, abs_of_nonneg ha]
  rw [nsmul_eq_mul, mul_one]
  have hp : ((m+n-1 : ℕ):ℝ) = (m:ℝ)+n-1 := by rw [Nat.cast_sub hN]; push_cast; ring
  rw [hp]; ring

end SeidelBipartite