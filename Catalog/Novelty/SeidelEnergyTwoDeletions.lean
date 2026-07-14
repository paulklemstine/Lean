/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Seidel energy of `K_{m,n}` under the deletion of two independent edges

This file **deepens** the single-edge analysis of the Seidel energy of the
complete bipartite graph `K_{m,n}`.  Recall the **Seidel matrix** of a graph is
`S = J - I - 2A`; for `K_{m,n}` (vertices `Fin m ⊕ Fin n`, all edges across the
two parts) it is the rank-one object `S = w wᵀ - I` with
`w = (+1 on the left, -1 on the right)`.  Its **Seidel energy** is the sum of the
absolute values of its eigenvalues; the base graph has energy `2(m+n-1)`.

Deleting a *single* cross edge is a rank-three perturbation and increases the
energy exactly when `m+n ≥ 4`.  Here we treat the deletion of **two independent
(vertex-disjoint) cross edges** `{inl a0, inr b0}` and `{inl a1, inr b1}` with
`a0 ≠ a1` and `b0 ≠ b1`.  This is a genuine rank-five perturbation of `-I`, and
the whole spectral computation goes through in closed form:

* `Sddel2_charpoly` : the characteristic polynomial collapses to
  `(X+1)^{m+n-5} (X-1)² (X+3) (X² - (m+n-4)X - (3(m+n)-11))`, using the matrix
  determinant lemma (`charpoly_mul_comm_of_le`) to reduce a `5×5` core, whose
  determinant is computed via `det_fin_five`;
* `Sddel2_energy` : the resulting graph has Seidel energy
  `(m+n) + √((m+n+2)² - 32)`;
* `seidel_two_deletions_increase` : **for all `m,n ≥ 2` with `m+n ≥ 5` the Seidel
  energy strictly increases** under any two-independent-edge deletion — there is
  *no* threshold obstruction, in sharp contrast with the single-edge case whose
  threshold is `m+n ≥ 4`;
* `Ktwothree_two_deletions` : the concrete witness `K_{2,3}`, whose energy jumps
  `8 → 5 + √17` when two independent edges are removed.

The argument is a cross-domain bridge: the combinatorics of `K_{m,n}`, the linear
algebra of low-rank perturbations, and the analysis of `Real.sqrt`.
-/
import Mathlib

open Matrix Polynomial Finset
open scoped BigOperators

noncomputable section

namespace SeidelTwoDeletions

/-- Explicit Laplace expansion of a `4 × 4` determinant (Mathlib provides
`det_fin_three` but not `det_fin_four` at this version). -/
theorem _root_.Matrix.det_fin_four {R : Type*} [CommRing R] (A : Matrix (Fin 4) (Fin 4) R) :
    det A =
      A 0 0 * (A 1 1 * (A 2 2 * A 3 3 - A 2 3 * A 3 2) - A 1 2 * (A 2 1 * A 3 3 - A 2 3 * A 3 1) + A 1 3 * (A 2 1 * A 3 2 - A 2 2 * A 3 1))
      - A 0 1 * (A 1 0 * (A 2 2 * A 3 3 - A 2 3 * A 3 2) - A 1 2 * (A 2 0 * A 3 3 - A 2 3 * A 3 0) + A 1 3 * (A 2 0 * A 3 2 - A 2 2 * A 3 0))
      + A 0 2 * (A 1 0 * (A 2 1 * A 3 3 - A 2 3 * A 3 1) - A 1 1 * (A 2 0 * A 3 3 - A 2 3 * A 3 0) + A 1 3 * (A 2 0 * A 3 1 - A 2 1 * A 3 0))
      - A 0 3 * (A 1 0 * (A 2 1 * A 3 2 - A 2 2 * A 3 1) - A 1 1 * (A 2 0 * A 3 2 - A 2 2 * A 3 0) + A 1 2 * (A 2 0 * A 3 1 - A 2 1 * A 3 0)) := by
  simp only [det_succ_row_zero, submatrix_apply, Fin.succ_zero_eq_one, submatrix_submatrix,
    det_unique, Fin.default_eq_zero, Function.comp_apply, Fin.succ_one_eq_two, Fin.sum_univ_succ,
    Fin.val_zero, Fin.zero_succAbove, univ_unique, Fin.val_succ, Fin.val_eq_zero,
    Fin.succ_succAbove_zero, sum_singleton, Fin.succ_succAbove_one,
    show (Fin.succ (2 : Fin 3)) = (3 : Fin 4) from rfl,
    show ((1 : Fin 4).succAbove (2 : Fin 3)) = (3 : Fin 4) from rfl,
    show ((2 : Fin 4).succAbove (2 : Fin 3)) = (3 : Fin 4) from rfl,
    show ((3 : Fin 4).succAbove (2 : Fin 3)) = (2 : Fin 4) from rfl]
  ring

/-! ### The base Seidel matrix of `K_{m,n}` and its energy -/

/-- The ±1 weight vector splitting `Fin m ⊕ Fin n` into its two parts. -/
def wt (m n : ℕ) : (Fin m ⊕ Fin n) → ℝ := Sum.elim (fun _ => 1) (fun _ => -1)

/-- The Seidel matrix of `K_{m,n}`, in rank-one form `w wᵀ - I`. -/
def Sd (m n : ℕ) : Matrix (Fin m ⊕ Fin n) (Fin m ⊕ Fin n) ℝ :=
  vecMulVec (wt m n) (wt m n) - 1

/-- Seidel energy: the sum of `|eigenvalue|` of a real symmetric matrix. -/
def seidelEnergy {V : Type*} [Fintype V] [DecidableEq V]
    {A : Matrix V V ℝ} (hA : A.IsHermitian) : ℝ := ∑ i, |hA.eigenvalues i|

theorem Sd_herm (m n : ℕ) : (Sd m n).IsHermitian := by
  unfold Matrix.IsHermitian Sd
  rw [conjTranspose_sub]; congr 1
  · ext i j; simp [vecMulVec, mul_comm]
  · simp

/-- **Bridge lemma.** Energy = `∑ |root|` over the characteristic polynomial. -/
theorem energy_eq_roots {V : Type*} [Fintype V] [DecidableEq V]
    {A : Matrix V V ℝ} (hA : A.IsHermitian) :
    seidelEnergy hA = (A.charpoly.roots.map (fun x => |x|)).sum := by
  unfold seidelEnergy
  rw [hA.roots_charpoly_eq_eigenvalues, Multiset.map_map, Finset.sum]
  simp [Function.comp]

theorem Sd_charpoly (m n : ℕ) :
    (Sd m n).charpoly = (X + C 1)^(m+n) - ((m:ℝ)+n) • (X + C 1)^(m+n-1) := by
  have hcard : Fintype.card (Fin m ⊕ Fin n) = m + n := by simp
  have hdot : (wt m n) ⬝ᵥ (wt m n) = (m + n : ℝ) := by
    simp [wt, dotProduct, Fintype.sum_sum_type]
  unfold Sd
  have h1 : (1 : Matrix (Fin m ⊕ Fin n) (Fin m ⊕ Fin n) ℝ) = Matrix.scalar _ (1:ℝ) := by simp
  rw [h1, charpoly_sub_scalar, charpoly_vecMulVec, hcard, hdot]
  simp [sub_comp, pow_comp, smul_comp, X_comp, add_comm]

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

theorem Sd_roots (m n : ℕ) (hN : 1 ≤ m + n) :
    (Sd m n).charpoly.roots = (m+n-1) • {(-1:ℝ)} + {((m:ℝ)+n-1)} := by
  rw [Sd_charpoly_factored m n hN,
     roots_mul (mul_ne_zero (pow_ne_zero _ (by intro h; simpa using congrArg (fun p => p.eval 0) h))
       (X_sub_C_ne_zero _)), roots_pow]
  have : (X + C (1:ℝ)).roots = {(-1:ℝ)} := by simpa using roots_X_add_C (1:ℝ)
  rw [this, roots_X_sub_C]

/-- The Seidel energy of `K_{m,n}` equals `2(m+n-1)`. -/
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

/-! ### The two-edge-deleted Seidel matrix and its rank-five structure -/

/-- The `V × 5` matrix whose columns are the weight vector `w` and the four unit
vectors at the endpoints of the two deleted cross edges. -/
def Uw (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n) :
    Matrix (Fin m ⊕ Fin n) (Fin 5) ℝ :=
  Matrix.of (fun i => ![wt m n i,
    (if i = Sum.inl a0 then (1:ℝ) else 0),
    (if i = Sum.inr b0 then (1:ℝ) else 0),
    (if i = Sum.inl a1 then (1:ℝ) else 0),
    (if i = Sum.inr b1 then (1:ℝ) else 0)])

/-- The `5 × 5` core coefficient matrix: `[1] ⊕ [[0,2],[2,0]] ⊕ [[0,2],[2,0]]`. -/
def Kmat : Matrix (Fin 5) (Fin 5) ℝ :=
  !![1,0,0,0,0; 0,0,2,0,0; 0,2,0,0,0; 0,0,0,0,2; 0,0,0,2,0]

/-- The `5 × 5` matrix `Kmat · Uwᵀ Uw`, whose eigenvalues are the nonzero part of
the deleted spectrum. -/
def P5 (N : ℝ) : Matrix (Fin 5) (Fin 5) ℝ :=
  !![N,1,-1,1,-1; -2,0,2,0,0; 2,2,0,0,0; -2,0,0,0,2; 2,0,0,2,0]

/-- The Seidel matrix of `K_{m,n}` with the two independent cross edges
`{inl a0, inr b0}` and `{inl a1, inr b1}` deleted. -/
def Sddel2 (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n) :
    Matrix (Fin m ⊕ Fin n) (Fin m ⊕ Fin n) ℝ :=
  Sd m n
    + 2 • (Matrix.single (Sum.inl a0) (Sum.inr b0) (1:ℝ)
         + Matrix.single (Sum.inr b0) (Sum.inl a0) (1:ℝ))
    + 2 • (Matrix.single (Sum.inl a1) (Sum.inr b1) (1:ℝ)
         + Matrix.single (Sum.inr b1) (Sum.inl a1) (1:ℝ))

theorem Sddel2_herm (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n) :
    (Sddel2 m n a0 a1 b0 b1).IsHermitian := by
  have hsingle : ∀ (a b : Fin m ⊕ Fin n), (Matrix.single a b (1:ℝ))ᴴ = Matrix.single b a 1 := by
    intro a b; ext i j; simp [Matrix.conjTranspose_apply, Matrix.single_apply, and_comm]
  unfold Matrix.IsHermitian Sddel2
  rw [conjTranspose_add, conjTranspose_add, conjTranspose_smul, conjTranspose_smul,
      conjTranspose_add, conjTranspose_add, (Sd_herm m n), hsingle, hsingle, hsingle, hsingle]
  simp [add_comm]

/-- The rank-five decomposition `Sddel2 + I = Uw (Kmat Uwᵀ)`. -/
theorem Mdecomp (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n)
    (ha : a0 ≠ a1) (hb : b0 ≠ b1) :
    Sddel2 m n a0 a1 b0 b1 + 1 = Uw m n a0 a1 b0 b1 * (Kmat * (Uw m n a0 a1 b0 b1)ᵀ) := by
  ext i j
  simp only [Sddel2, Sd, Matrix.add_apply, Matrix.sub_apply, Matrix.one_apply,
    Matrix.smul_apply, Matrix.mul_apply, Uw, Kmat, Matrix.of_apply, Matrix.transpose_apply,
    Matrix.single, vecMulVec_apply, Fin.sum_univ_five]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val,
    zero_mul, add_zero, zero_add]
  by_cases hia0 : i = Sum.inl a0 <;> by_cases hjb0 : j = Sum.inr b0 <;>
    by_cases hib0 : i = Sum.inr b0 <;> by_cases hja0 : j = Sum.inl a0 <;>
    by_cases hia1 : i = Sum.inl a1 <;> by_cases hjb1 : j = Sum.inr b1 <;>
    by_cases hib1 : i = Sum.inr b1 <;> by_cases hja1 : j = Sum.inl a1 <;>
    simp_all [eq_comm]

/-- The Gram matrix `Uwᵀ Uw` of the five columns (for independent edges). -/
theorem gram_eq (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n)
    (ha : a0 ≠ a1) (hb : b0 ≠ b1) :
    (Uw m n a0 a1 b0 b1)ᵀ * (Uw m n a0 a1 b0 b1)
      = !![(m:ℝ)+n,1,-1,1,-1; 1,1,0,0,0; -1,0,1,0,0; 1,0,0,1,0; -1,0,0,0,1] := by
  ext i j;
  simp +decide [ Matrix.mul_apply, Uw ];
  fin_cases i <;> fin_cases j <;> simp +decide [ wt ];
  · exact ha.symm;
  · tauto;
  · assumption;
  · assumption

theorem KG_eq (N : ℝ) :
    Kmat * !![N,1,-1,1,-1; 1,1,0,0,0; -1,0,1,0,0; 1,0,0,1,0; -1,0,0,0,1] = P5 N := by
  ext p q; fin_cases p <;> fin_cases q <;>
    simp [Kmat, P5, Matrix.mul_apply, Fin.sum_univ_five]

/-- The auxiliary charmatrix in fully evaluated `!!` form. -/
def Bmat (N : ℝ) : Matrix (Fin 5) (Fin 5) (Polynomial ℝ) :=
  !![X-C N, -1, 1, -1, 1; C 2, X, -C 2, 0, 0; -C 2, -C 2, X, 0, 0;
     C 2, 0, 0, X, -C 2; -C 2, 0, 0, -C 2, X]

theorem charmatrix_P5 (N : ℝ) : charmatrix (P5 N) = Bmat N := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [charmatrix, P5, Bmat, Matrix.scalar_apply, Matrix.diagonal]

set_option maxHeartbeats 800000 in
/-- **Characteristic polynomial of the `5×5` core `P5`.** -/
theorem P5_charpoly (N : ℝ) :
    (P5 N).charpoly = (X - C 2)^2 * (X + C 2) * (X^2 - C (N-2)*X - C (2*N-8)) := by
  rw [Matrix.charpoly, charmatrix_P5]
  have e0 : (Bmat N).submatrix Fin.succ (Fin.succAbove 0)
      = !![X,-C 2,0,0; -C 2,X,0,0; 0,0,X,-C 2; 0,0,-C 2,X] := by
    ext i j; fin_cases i <;> fin_cases j <;> rfl
  have e1 : (Bmat N).submatrix Fin.succ (Fin.succAbove 1)
      = !![C 2,-C 2,0,0; -C 2,X,0,0; C 2,0,X,-C 2; -C 2,0,-C 2,X] := by
    ext i j; fin_cases i <;> fin_cases j <;> rfl
  have e2 : (Bmat N).submatrix Fin.succ (Fin.succAbove 2)
      = !![C 2,X,0,0; -C 2,-C 2,0,0; C 2,0,X,-C 2; -C 2,0,-C 2,X] := by
    ext i j; fin_cases i <;> fin_cases j <;> rfl
  have e3 : (Bmat N).submatrix Fin.succ (Fin.succAbove 3)
      = !![C 2,X,-C 2,0; -C 2,-C 2,X,0; C 2,0,0,-C 2; -C 2,0,0,X] := by
    ext i j; fin_cases i <;> fin_cases j <;> rfl
  have e4 : (Bmat N).submatrix Fin.succ (Fin.succAbove 4)
      = !![C 2,X,-C 2,0; -C 2,-C 2,X,0; C 2,0,0,X; -C 2,0,0,-C 2] := by
    ext i j; fin_cases i <;> fin_cases j <;> rfl
  rw [det_succ_row_zero, Fin.sum_univ_five, e0, e1, e2, e3, e4]
  simp only [Bmat, Matrix.det_fin_four, Matrix.of_apply, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.cons_val, Fin.val_zero, Fin.val_one, Fin.val_two, Fin.isValue,
    map_sub, map_mul, map_ofNat]
  norm_num
  ring

/-- Composition of the core charpoly with the shift `X ↦ X + 1`. -/
theorem P5cp_comp (N : ℝ) :
    ((X - C 2)^2 * (X + C 2) * (X^2 - C (N-2)*X - C (2*N-8))).comp (X + C 1)
      = (X - C 1)^2 * (X + C 3) * (X^2 - C (N-4)*X - C (3*N-11)) := by
  simp only [mul_comp, sub_comp, add_comp, pow_comp, X_comp, C_comp]
  rw [show C (N-2) = C N - 2 by rw [map_sub, map_ofNat],
      show C (2*N-8) = 2 * C N - 8 by rw [map_sub, map_mul, map_ofNat, map_ofNat],
      show C (N-4) = C N - 4 by rw [map_sub, map_ofNat],
      show C (3*N-11) = 3 * C N - 11 by rw [map_sub, map_mul, map_ofNat, map_ofNat],
      show C (1:ℝ) = 1 by simp, show C (2:ℝ) = 2 by rw [map_ofNat],
      show C (3:ℝ) = 3 by rw [map_ofNat]]
  ring

/-- **Characteristic polynomial of the two-edge-deleted Seidel matrix.** -/
theorem Sddel2_charpoly (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n)
    (ha : a0 ≠ a1) (hb : b0 ≠ b1) (h5 : 5 ≤ m + n) :
    (Sddel2 m n a0 a1 b0 b1).charpoly
      = (X + C 1)^(m+n-5) *
        ((X - C 1)^2 * (X + C 3) * (X^2 - C ((m:ℝ)+n-4)*X - C (3*((m:ℝ)+n)-11))) := by
  have hcard : Fintype.card (Fin m ⊕ Fin n) = m + n := by simp
  have hSd : Sddel2 m n a0 a1 b0 b1
      = (Sddel2 m n a0 a1 b0 b1 + 1) - Matrix.scalar _ (1:ℝ) := by simp
  rw [hSd, charpoly_sub_scalar, Mdecomp m n a0 a1 b0 b1 ha hb,
     charpoly_mul_comm_of_le (Uw m n a0 a1 b0 b1) (Kmat * (Uw m n a0 a1 b0 b1)ᵀ)
        (by rw [hcard, Fintype.card_fin]; exact h5),
     hcard, Fintype.card_fin,
     show Kmat * (Uw m n a0 a1 b0 b1)ᵀ * Uw m n a0 a1 b0 b1
        = Kmat * ((Uw m n a0 a1 b0 b1)ᵀ * Uw m n a0 a1 b0 b1) from (Matrix.mul_assoc _ _ _),
     gram_eq m n a0 a1 b0 b1 ha hb, KG_eq, P5_charpoly,
     mul_comp, pow_comp, X_comp, P5cp_comp]

/-! ### The quadratic factor and the analytic energy formula -/

theorem quad_factor (b c : ℝ) (hD : 0 ≤ b^2 + 4*c) :
    (X^2 - C b * X - C c)
      = (X - C ((b + Real.sqrt (b^2+4*c))/2)) * (X - C ((b - Real.sqrt (b^2+4*c))/2)) := by
  have hsq : (Real.sqrt (b^2+4*c))^2 = b^2+4*c := Real.sq_sqrt hD
  have e1 : ((b + Real.sqrt (b^2+4*c))/2) + ((b - Real.sqrt (b^2+4*c))/2) = b := by ring
  have e2 : ((b + Real.sqrt (b^2+4*c))/2) * ((b - Real.sqrt (b^2+4*c))/2) = -c := by
    have : ((b + Real.sqrt (b^2+4*c))/2) * ((b - Real.sqrt (b^2+4*c))/2)
        = (b^2 - (Real.sqrt (b^2+4*c))^2)/4 := by ring
    rw [this, hsq]; ring
  have expand : (X - C ((b + Real.sqrt (b^2+4*c))/2)) * (X - C ((b - Real.sqrt (b^2+4*c))/2))
      = X^2 - C (((b + Real.sqrt (b^2+4*c))/2) + ((b - Real.sqrt (b^2+4*c))/2)) * X
        + C (((b + Real.sqrt (b^2+4*c))/2) * ((b - Real.sqrt (b^2+4*c))/2)) := by
    rw [C_add, C_mul]; ring
  rw [expand, e1, e2, C_neg]; ring

theorem quad_roots (b c : ℝ) (hD : 0 ≤ b^2 + 4*c) :
    (X^2 - C b * X - C c).roots
      = {((b + Real.sqrt (b^2+4*c))/2)} + {((b - Real.sqrt (b^2+4*c))/2)} := by
  rw [quad_factor b c hD, roots_mul (mul_ne_zero (X_sub_C_ne_zero _) (X_sub_C_ne_zero _)),
      roots_X_sub_C, roots_X_sub_C]

/-- **Seidel energy of the two-edge-deleted graph** (for `m,n ≥ 2`, `m+n ≥ 5`).
It equals `(m+n) + √((m+n+2)² - 32)`. -/
theorem Sddel2_energy (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n)
    (ha : a0 ≠ a1) (hb : b0 ≠ b1) (h5 : 5 ≤ m + n) :
    seidelEnergy (Sddel2_herm m n a0 a1 b0 b1)
      = ((m:ℝ)+n) + Real.sqrt (((m:ℝ)+n+2)^2 - 32) := by
  rw [ energy_eq_roots, Sddel2_charpoly m n a0 a1 b0 b1 ha hb h5 ];
  rw [ Polynomial.roots_mul, Polynomial.roots_mul, Polynomial.roots_mul ];
  · have h_quad_roots : (X^2 - C ((m:ℝ) + n - 4) * X - C (3 * ((m:ℝ) + n) - 11)).roots = {((m:ℝ) + n - 4 + Real.sqrt (((m:ℝ) + n + 2) ^ 2 - 32)) / 2, ((m:ℝ) + n - 4 - Real.sqrt (((m:ℝ) + n + 2) ^ 2 - 32)) / 2} := by
      rw [ show ( X ^ 2 - C ( m + n - 4 : ℝ ) * X - C ( 3 * ( m + n ) - 11 : ℝ ) ) = ( X - C ( ( m + n - 4 + Real.sqrt ( ( m + n + 2 ) ^ 2 - 32 ) ) / 2 ) ) * ( X - C ( ( m + n - 4 - Real.sqrt ( ( m + n + 2 ) ^ 2 - 32 ) ) / 2 ) ) from _ ];
      · rw [ Polynomial.roots_mul <| mul_ne_zero ( Polynomial.X_sub_C_ne_zero _ ) ( Polynomial.X_sub_C_ne_zero _ ), Polynomial.roots_X_sub_C, Polynomial.roots_X_sub_C ] ; tauto;
      · exact Polynomial.funext fun x => by norm_num; linarith [ Real.mul_self_sqrt ( show 0 <= ( m + n + 2 : ℝ ) ^ 2 - 32 by nlinarith [ show ( m + n : ℝ ) ≥ 5 by norm_cast ] ) ] ;
    rw [ Polynomial.roots_pow, Polynomial.roots_pow, Polynomial.roots_X_add_C, Polynomial.roots_X_sub_C, h_quad_roots ] ; norm_num ; ring;
    rw [ abs_of_nonneg, abs_of_nonpos ] <;> norm_num [ Multiset.nsmul_singleton ] <;> ring;
    · rw [ Nat.cast_sub ] <;> push_cast <;> linarith;
    · nlinarith only [ show ( m : ℝ ) + n ≥ 5 by norm_cast, Real.sqrt_nonneg ( -28 + ( m : ℝ ) * 4 + ( m : ℝ ) * n * 2 + ( m : ℝ ) ^ 2 + ( n : ℝ ) * 4 + ( n : ℝ ) ^ 2 ), Real.mul_self_sqrt ( show 0 <= -28 + ( m : ℝ ) * 4 + ( m : ℝ ) * n * 2 + ( m : ℝ ) ^ 2 + ( n : ℝ ) * 4 + ( n : ℝ ) ^ 2 by nlinarith only [ show ( m : ℝ ) + n ≥ 5 by norm_cast ] ) ];
    · nlinarith only [ show ( m : ℝ ) + n ≥ 5 by norm_cast, Real.sqrt_nonneg ( -28 + ( m : ℝ ) * 4 + ( m : ℝ ) * n * 2 + ( m : ℝ ) ^ 2 + ( n : ℝ ) * 4 + ( n : ℝ ) ^ 2 ), Real.mul_self_sqrt ( show 0 <= -28 + ( m : ℝ ) * 4 + ( m : ℝ ) * n * 2 + ( m : ℝ ) ^ 2 + ( n : ℝ ) * 4 + ( n : ℝ ) ^ 2 by nlinarith only [ show ( m : ℝ ) + n ≥ 5 by norm_cast ] ) ];
  · exact mul_ne_zero ( pow_ne_zero 2 ( Polynomial.X_sub_C_ne_zero _ ) ) ( Polynomial.X_add_C_ne_zero _ );
  · exact ne_of_apply_ne ( Polynomial.eval 0 ) ( by norm_num; nlinarith [ ( by norm_cast : ( 5 : ℝ ) ≤ m + n ) ] );
  · exact mul_ne_zero ( pow_ne_zero _ ( Polynomial.X_add_C_ne_zero _ ) ) ( mul_ne_zero ( mul_ne_zero ( pow_ne_zero _ ( Polynomial.X_sub_C_ne_zero _ ) ) ( Polynomial.X_add_C_ne_zero _ ) ) ( by exact ne_of_apply_ne ( fun p => p.coeff 2 ) <| by norm_num [ Polynomial.coeff_one, Polynomial.coeff_X, sq, mul_assoc, sub_mul, add_mul ] ) )

/-! ### The absence of a threshold obstruction -/

/-- **Main theorem.** For `K_{m,n}` with `m,n ≥ 2` and `m+n ≥ 5`, deleting *any*
two independent (vertex-disjoint) cross edges **strictly increases** the Seidel
energy.  Unlike the single-edge case (threshold `m+n ≥ 4`), the two-edge deletion
has no threshold obstruction at all: whenever such a pair of edges exists, the
energy goes up. -/
theorem seidel_two_deletions_increase (m n : ℕ) (a0 a1 : Fin m) (b0 b1 : Fin n)
    (ha : a0 ≠ a1) (hb : b0 ≠ b1) (h5 : 5 ≤ m + n) :
    seidelEnergy (Sd_herm m n) < seidelEnergy (Sddel2_herm m n a0 a1 b0 b1) := by
  rw [seidelEnergy_Kmn m n (by omega), Sddel2_energy m n a0 a1 b0 b1 ha hb h5]
  set N : ℝ := (m:ℝ)+n with hN
  have hNge : (5:ℝ) ≤ N := by rw [hN]; exact_mod_cast h5
  have hd : (0:ℝ) ≤ (N-2)^2 := sq_nonneg _
  have hlt : N - 2 < Real.sqrt ((N+2)^2 - 32) := by
    rw [show ((N:ℝ)+2)^2 - 32 = (N-2)^2 + (8*N - 32) by ring]
    have h1 : (0:ℝ) < (N-2)^2 + (8*N-32) := by nlinarith
    have hlt2 : (N-2)^2 < (N-2)^2 + (8*N-32) := by nlinarith
    calc N - 2 ≤ |N - 2| := le_abs_self _
      _ = Real.sqrt ((N-2)^2) := (Real.sqrt_sq_eq_abs _).symm
      _ < Real.sqrt ((N-2)^2 + (8*N-32)) := by
          apply Real.sqrt_lt_sqrt (sq_nonneg _) hlt2
  nlinarith [hlt]

/-- The concrete `K_{2,3}` witness: energy `8` before deletion, `5 + √17` after
removing two independent edges. -/
theorem Ktwothree_two_deletions :
    seidelEnergy (Sd_herm 2 3) = 8 ∧
    seidelEnergy (Sddel2_herm 2 3 ⟨0, by norm_num⟩ ⟨1, by norm_num⟩
      ⟨0, by norm_num⟩ ⟨1, by norm_num⟩) = 5 + Real.sqrt 17 := by
  refine ⟨by rw [seidelEnergy_Kmn 2 3 (by norm_num)]; norm_num, ?_⟩
  rw [Sddel2_energy 2 3 _ _ _ _ (by decide) (by decide) (by norm_num)]
  push_cast
  rw [show ((2:ℝ)+3+2)^2 - 32 = 17 by norm_num]
  norm_num

end SeidelTwoDeletions