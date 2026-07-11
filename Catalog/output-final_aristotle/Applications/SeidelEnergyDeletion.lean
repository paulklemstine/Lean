/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sharp threshold for the Seidel-energy increase of `K_{m,n}` under edge deletion

The **Seidel matrix** of a graph is `S = J - I - 2A`; its **Seidel energy** is the
sum of the absolute values of its eigenvalues.  For the complete bipartite graph
`K_{m,n}` (vertices `Fin m ⊕ Fin n`, edges across the two parts) the Seidel matrix
is the rank-one object `S = w wᵀ - I` with `w = (+1 on the left, -1 on the right)`.

A published conjecture asserts that the Seidel energy of `K_{m,n}` strictly
increases under *any* single edge deletion **iff both parts have size `≥ 3`**.
This file computes the two energies in closed form and *disproves* that threshold.

## The exact spectral computation (a cross-domain bridge)

The whole argument connects three areas: the combinatorics of `K_{m,n}`, the
linear algebra of low-rank perturbations, and the analysis of `Real.sqrt`.

* `Sd_charpoly_factored` / `seidelEnergy_Kmn` : the base graph has Seidel energy
  `2(m+n-1)` (its Seidel spectrum is `{m+n-1} ∪ {-1}^{m+n-1}`);
* `Sddel_charpoly` : deleting one *cross* edge turns the Seidel matrix into a
  rank-three perturbation of `-I`; the matrix determinant lemma
  (`charpoly_mul_comm_of_le`) collapses its characteristic polynomial to
  `(X+1)^{m+n-3} (X-1) (X² - (m+n-4)X - (3(m+n)-7))`;
* `Sddel_energy` : hence the deleted graph has Seidel energy
  `(m+n-2) + √((m+n-2)(m+n+6))`;
* `seidel_energy_increase_iff` : **the energy strictly increases iff `m+n ≥ 4`** —
  the genuinely sharp threshold;
* `SeidelConjecture`, `conjecture_is_false` : the "both parts `≥ 3`" conjecture is
  therefore false; `K_{2,2}` (both parts of size `2`) already exhibits a strict
  increase, computed exactly as `6 → 2 + 2√5` in `Ktwotwo_energies`.
-/
import Mathlib

open Matrix Polynomial
open scoped BigOperators

noncomputable section

namespace SeidelDeletion

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

/-! ### The edge-deleted Seidel matrix and its rank-three structure -/

/-- The `V × 3` matrix whose columns are the weight vector `w` and the two unit
vectors at the endpoints of the deleted cross edge. -/
def Uw (m n : ℕ) (a0 : Fin m) (b0 : Fin n) : Matrix (Fin m ⊕ Fin n) (Fin 3) ℝ :=
  Matrix.of (fun i => ![wt m n i, (if i = Sum.inl a0 then (1:ℝ) else 0),
                                  (if i = Sum.inr b0 then (1:ℝ) else 0)])

/-- The `3 × 3` core of the rank-three perturbation. -/
def Kmat : Matrix (Fin 3) (Fin 3) ℝ := !![1,0,0;0,0,2;0,2,0]

/-- The `3 × 3` matrix `Kmat · Uwᵀ Uw`, whose eigenvalues are the nonzero part of
the deleted spectrum. -/
def P3 (N : ℝ) : Matrix (Fin 3) (Fin 3) ℝ := !![N,1,-1;-2,0,2;2,2,0]

/-- The Seidel matrix of `K_{m,n}` with the single cross edge
`{inl a0, inr b0}` deleted: the `(inl a0, inr b0)` entry flips from `-1` to `+1`. -/
def Sddel (m n : ℕ) (a0 : Fin m) (b0 : Fin n) : Matrix (Fin m ⊕ Fin n) (Fin m ⊕ Fin n) ℝ :=
  Sd m n + 2 • (Matrix.single (Sum.inl a0) (Sum.inr b0) (1:ℝ)
              + Matrix.single (Sum.inr b0) (Sum.inl a0) (1:ℝ))

theorem Sddel_herm (m n : ℕ) (a0 : Fin m) (b0 : Fin n) : (Sddel m n a0 b0).IsHermitian := by
  have hsingle : ∀ (a b : Fin m ⊕ Fin n), (Matrix.single a b (1:ℝ))ᴴ = Matrix.single b a 1 := by
    intro a b; ext i j; simp [Matrix.conjTranspose_apply, Matrix.single_apply, and_comm]
  unfold Matrix.IsHermitian Sddel
  rw [conjTranspose_add, conjTranspose_smul, conjTranspose_add, (Sd_herm m n),
      hsingle, hsingle]
  simp [add_comm]

/-- The rank-three decomposition `Sddel + I = Uw (Kmat Uwᵀ)`. -/
theorem Mdecomp (m n : ℕ) (a0 : Fin m) (b0 : Fin n) :
    Sddel m n a0 b0 + 1 = Uw m n a0 b0 * (Kmat * (Uw m n a0 b0)ᵀ) := by
  ext i j
  simp only [Sddel, Sd, Matrix.add_apply, Matrix.sub_apply, Matrix.one_apply,
    Matrix.smul_apply, Matrix.mul_apply, Uw, Kmat, Matrix.of_apply, Matrix.transpose_apply,
    Matrix.single, vecMulVec_apply, Fin.sum_univ_three]
  simp only [Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val,
    zero_mul, add_zero, zero_add]
  by_cases hia : i = Sum.inl a0 <;> by_cases hjb : j = Sum.inr b0 <;>
    by_cases hib : i = Sum.inr b0 <;> by_cases hja : j = Sum.inl a0 <;>
    simp_all [eq_comm]

/-- The Gram matrix `Uwᵀ Uw` of the three columns. -/
theorem gram_eq (m n : ℕ) (a0 : Fin m) (b0 : Fin n) :
    (Uw m n a0 b0)ᵀ * (Uw m n a0 b0) = !![(m:ℝ)+n,1,-1;1,1,0;-1,0,1] := by
  ext p q
  fin_cases p <;> fin_cases q <;>
    simp [Matrix.mul_apply, Matrix.transpose_apply, Uw, Matrix.of_apply,
      wt, Fintype.sum_sum_type, Finset.sum_ite_eq', mul_comm]

theorem KG_eq (N : ℝ) : Kmat * !![N,1,-1;1,1,0;-1,0,1] = P3 N := by
  ext p q; fin_cases p <;> fin_cases q <;>
    simp [Kmat, P3, Matrix.mul_apply, Fin.sum_univ_three]

theorem P3_charpoly (N : ℝ) : (P3 N).charpoly = X^3 - C N * X^2 + (4 * C N - 8) := by
  rw [Matrix.charpoly, Matrix.det_fin_three]
  simp only [charmatrix, P3, RingHom.mapMatrix_apply, Matrix.map_apply, Matrix.of_apply,
    Matrix.cons_val', Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.empty_val', Matrix.cons_val_fin_one, Matrix.scalar_apply,
    Matrix.diagonal_apply, Matrix.sub_apply, Matrix.cons_val, Fin.reduceEq, if_true, if_false,
    map_ofNat, map_one, map_neg, map_zero]
  ring_nf

theorem cubic_comp (N : ℝ) :
    (X^3 - C N * X^2 + (4 * C N - 8)).comp (X + C 1)
      = (X - C 1) * (X^2 - C (N-4) * X - C (3*N-7)) := by
  simp only [sub_comp, add_comp, mul_comp, pow_comp, X_comp, C_comp, ofNat_comp, C_1]
  rw [show C (N-4) = C N - 4 by rw [map_sub, map_ofNat],
      show C (3*N-7) = 3 * C N - 7 by rw [map_sub, map_mul, map_ofNat, map_ofNat]]
  ring

/-- **Characteristic polynomial of the edge-deleted Seidel matrix.** -/
theorem Sddel_charpoly (m n : ℕ) (a0 : Fin m) (b0 : Fin n) (h3 : 3 ≤ m + n) :
    (Sddel m n a0 b0).charpoly
      = (X + C 1)^(m+n-3) * ((X - C 1) * (X^2 - C ((m:ℝ)+n-4)*X - C (3*((m:ℝ)+n)-7))) := by
  have hcard : Fintype.card (Fin m ⊕ Fin n) = m + n := by simp
  have hSd : Sddel m n a0 b0 = (Sddel m n a0 b0 + 1) - Matrix.scalar _ (1:ℝ) := by simp
  rw [hSd, charpoly_sub_scalar, Mdecomp,
     charpoly_mul_comm_of_le (Uw m n a0 b0) (Kmat * (Uw m n a0 b0)ᵀ)
        (by rw [hcard, Fintype.card_fin]; exact h3),
     hcard, Fintype.card_fin,
     show Kmat * (Uw m n a0 b0)ᵀ * Uw m n a0 b0 = Kmat * ((Uw m n a0 b0)ᵀ * Uw m n a0 b0) from
       (Matrix.mul_assoc _ _ _), gram_eq, KG_eq, P3_charpoly,
     mul_comp, pow_comp, X_comp, cubic_comp]

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

/-- Energy of any Hermitian matrix whose characteristic polynomial has the
"edge-deleted" shape. -/
theorem energy_of_shape {V : Type*} [Fintype V] [DecidableEq V]
    (A : Matrix V V ℝ) (hA : A.IsHermitian) (m n : ℕ) (h3 : 3 ≤ m + n)
    (hchar : A.charpoly = (X + C 1)^(m+n-3) *
       ((X - C 1) * (X^2 - C ((m:ℝ)+n-4)*X - C (3*((m:ℝ)+n)-7)))) :
    seidelEnergy hA = ((m:ℝ)+n-2) + Real.sqrt (((m:ℝ)+n-2)*((m:ℝ)+n+6)) := by
  set N : ℝ := (m:ℝ)+n with hN
  have hNge : (3:ℝ) ≤ N := by rw [hN]; exact_mod_cast h3
  have h4c : (0:ℝ) ≤ 4*(3*N-7) := by nlinarith
  have hD : 0 ≤ (N-4)^2 + 4*(3*N-7) := by nlinarith
  set s : ℝ := Real.sqrt ((N-4)^2+4*(3*N-7)) with hs
  have hsnn : 0 ≤ s := Real.sqrt_nonneg _
  have hge : |N-4| ≤ s := by
    have h := Real.sqrt_le_sqrt (show (N-4)^2 ≤ (N-4)^2+4*(3*N-7) by linarith)
    rwa [Real.sqrt_sq_eq_abs] at h
  have hsD : s = Real.sqrt ((N-2)*(N+6)) := by rw [hs]; congr 1; ring
  have hne1 : (X + C (1:ℝ))^(m+n-3) ≠ 0 :=
    pow_ne_zero _ (by intro h; simpa using congrArg (fun p => p.eval 0) h)
  have hne2 : (X - C (1:ℝ)) ≠ 0 := X_sub_C_ne_zero _
  have hneQ : (X^2 - C (N-4) * X - C (3*N-7)) ≠ 0 := by
    intro h
    have := congrArg (fun p => Polynomial.coeff p 2) h
    simp [coeff_X_pow] at this
  rw [energy_eq_roots, hchar,
      roots_mul (mul_ne_zero hne1 (mul_ne_zero hne2 hneQ)), roots_mul (mul_ne_zero hne2 hneQ),
      roots_pow]
  have hr1 : (X + C (1:ℝ)).roots = {(-1:ℝ)} := by simpa using roots_X_add_C (1:ℝ)
  rw [hr1, roots_X_sub_C, quad_roots (N-4) (3*N-7) hD, ← hs]
  simp only [Multiset.map_add, Multiset.sum_add, Multiset.map_nsmul, Multiset.sum_nsmul,
    Multiset.map_singleton, Multiset.sum_singleton, abs_neg, abs_one]
  have hrp : |(N - 4 + s)/2| = (N-4+s)/2 := by
    apply abs_of_nonneg; cases abs_cases (N-4) with
    | inl h => linarith [h.1] | inr h => linarith [h.1]
  have hrm : |(N - 4 - s)/2| = -((N-4-s)/2) := by
    apply abs_of_nonpos; cases abs_cases (N-4) with
    | inl h => linarith [h.1] | inr h => linarith [h.1]
  rw [hrp, hrm]
  have hcast : ((m+n-3 : ℕ):ℝ) = N - 3 := by rw [hN, Nat.cast_sub h3]; push_cast; ring
  rw [nsmul_eq_mul, mul_one, hcast, hsD]
  ring

/-- **Seidel energy of the edge-deleted graph** `K_{m,n} - e` (for `m+n ≥ 3`). -/
theorem Sddel_energy (m n : ℕ) (a0 : Fin m) (b0 : Fin n) (h3 : 3 ≤ m + n) :
    seidelEnergy (Sddel_herm m n a0 b0)
      = ((m:ℝ)+n-2) + Real.sqrt (((m:ℝ)+n-2)*((m:ℝ)+n+6)) :=
  energy_of_shape (Sddel m n a0 b0) (Sddel_herm m n a0 b0) m n h3 (Sddel_charpoly m n a0 b0 h3)

/-! ### The sharp threshold, and the refutation of the conjecture -/

/-- **Sharp threshold.** For any single cross-edge deletion of `K_{m,n}` (with
`m+n ≥ 3`), the Seidel energy strictly increases **iff `m + n ≥ 4`**.  In
particular the true threshold does not require *both* parts to have size `≥ 3`. -/
theorem seidel_energy_increase_iff (m n : ℕ) (a0 : Fin m) (b0 : Fin n) (h3 : 3 ≤ m + n) :
    seidelEnergy (Sd_herm m n) < seidelEnergy (Sddel_herm m n a0 b0) ↔ 4 ≤ m + n := by
  rw [seidelEnergy_Kmn m n (by omega), Sddel_energy m n a0 b0 h3]
  set N : ℝ := (m:ℝ)+n with hN
  have hNge : (3:ℝ) ≤ N := by rw [hN]; exact_mod_cast h3
  have key : (2*(N-1) < (N-2) + Real.sqrt ((N-2)*(N+6))) ↔ 3 < N := by
    have key2 : N < Real.sqrt ((N-2)*(N+6)) ↔ 3 < N := by
      rw [Real.lt_sqrt (by linarith)]; constructor <;> intro h <;> nlinarith
    constructor
    · intro h; rw [← key2]; linarith
    · intro h; have := key2.mpr h; linarith
  rw [key, hN]
  constructor
  · intro h
    by_contra hc
    have : (m:ℝ) + n ≤ 3 := by exact_mod_cast (show m + n ≤ 3 by omega)
    linarith
  · intro h
    have : (4:ℝ) ≤ (m:ℝ) + n := by exact_mod_cast h
    linarith

/-- The concrete `K_{2,2}` witness: energy `6` before deletion, `2 + 2√5` after. -/
theorem Ktwotwo_energies :
    seidelEnergy (Sd_herm 2 2) = 6 ∧
    seidelEnergy (Sddel_herm 2 2 ⟨0, by norm_num⟩ ⟨0, by norm_num⟩) = 2 + 2 * Real.sqrt 5 := by
  refine ⟨by rw [seidelEnergy_Kmn 2 2 (by norm_num)]; norm_num, ?_⟩
  rw [Sddel_energy 2 2 _ _ (by norm_num)]
  push_cast
  rw [show ((2:ℝ)+2-2) = 2 by norm_num, show ((2:ℝ)+2+6) = 10 by norm_num,
      show (2:ℝ)*10 = 20 by norm_num, show (20:ℝ) = 4 * 5 by norm_num, Real.sqrt_mul (by norm_num),
      show Real.sqrt 4 = 2 by rw [show (4:ℝ) = 2^2 by norm_num, Real.sqrt_sq (by norm_num)]]

/-- The published conjecture, as a formal statement: for every complete bipartite
graph `K_{m,n}` with `m+n ≥ 3` and every deleted cross edge, the Seidel energy
strictly increases **iff both parts have size `≥ 3`**. -/
def SeidelConjecture : Prop :=
  ∀ (m n : ℕ) (a0 : Fin m) (b0 : Fin n), 3 ≤ m + n →
    (seidelEnergy (Sd_herm m n) < seidelEnergy (Sddel_herm m n a0 b0) ↔ (3 ≤ m ∧ 3 ≤ n))

/-- **The conjecture is false.**  `K_{2,2}` — both parts of size `2` — already has
strictly increasing Seidel energy under a cross-edge deletion (`6 < 2 + 2√5`),
even though neither part reaches size `3`. -/
theorem conjecture_is_false : ¬ SeidelConjecture := by
  intro H
  have hiff := H 2 2 ⟨0, by norm_num⟩ ⟨0, by norm_num⟩ (by norm_num)
  have hinc : seidelEnergy (Sd_herm 2 2)
      < seidelEnergy (Sddel_herm 2 2 ⟨0, by norm_num⟩ ⟨0, by norm_num⟩) :=
    (seidel_energy_increase_iff 2 2 _ _ (by norm_num)).mpr (by norm_num)
  exact absurd (hiff.mp hinc) (by norm_num)

end SeidelDeletion