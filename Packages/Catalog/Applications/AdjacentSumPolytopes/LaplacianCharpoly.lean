import Applications.AdjacentSumPolytopes.Inverse

/-!
# The characteristic polynomial of the squared transfer matrix, in closed form

`Inverse.lean` proved that the square of the inverse transfer matrix is a path Laplacian,
`A⁻² = neumannLaplacian s`.  Since a Laplacian is *tridiagonal*, its characteristic
polynomial obeys the classical three-term continuant recurrence, and this file solves that
recurrence in closed binomial form.  The consequences are closed forms for the whole even
half of the spectral data of the adjacent-sum model:

* `charpoly (A⁻²) = lapPoly (s+1)` with
  `(lapPoly n).coeff j = (−1)^{n+j} · C(n + j, 2j)` — a *complete* determination of every
  coefficient (contrast with the binomial staircase Conjecture 1 for `A` itself, of which
  only the cases `m = 0, 1, 2, s, s+1` are known);
* `charpoly (A²)` in closed form:
  `det(y I − A²) = ∑_{k=0}^{s+1} (−1)^k C(s+1+k, 2k) y^{s+1−k}`;
* consequently an **explicit binomial linear recurrence for the even-length cyclic
  adjacent-sum counts**, whose characteristic denominator is the above polynomial.

Since `det(x I − A)·det(x I + A) = det(x² I − A²)`, this pins down the product of the two
parity classes of the binomial staircase conjecture, i.e. the conjecture "squared".

## Main results

* `AdjSum.det_triMat_rec` : the three-term continuant recurrence for a tridiagonal matrix
  with constant diagonal `u`, corner `v` and off-diagonal `w`.
* `AdjSum.coeff_lapPoly` : `(lapPoly n).coeff j = (−1)^{n+j} C(n+j, 2j)` for all `j`.
* `AdjSum.charpoly_neumannLaplacian` : `charpoly (neumannLaplacian s) = lapPoly (s+1)`.
* `AdjSum.charpoly_adjMatZ_sq_coeff` :
  `charpoly (A²).coeff (s+1−k) = (−1)^k C(s+1+k, 2k)` for `k ≤ s+1`.
* `AdjSum.cycCount_even_recurrence` : the resulting explicit recurrence for the
  even-length cyclic counts.

-- !-- Lab Notes -- !--
* **Experiment.**  `charpoly (neumannLaplacian s)` for `s = 0..5` is
  `z − 1`, `z² − 3z + 1`, `z³ − 5z² + 6z − 1`, `z⁴ − 7z³ + 15z² − 10z + 1`,
  `z⁵ − 9z⁴ + 28z³ − 35z² + 15z − 1`, `z⁶ − 11z⁵ + 45z⁴ − 84z³ + 70z² − 21z + 1`, matching
  `(−1)^{n+j} C(n+j, 2j)` coefficient by coefficient (`n = s+1`).  For `s = 1` the derived
  recurrence for the even cyclic counts is `c(2m+3) = 3c(2m+1) − c(2m−1)`, i.e. the
  even-index Lucas numbers `3, 7, 18, 47, 123`.
* **Analysis.**  The mechanism is that inverting the transfer matrix trades density for
  sparsity: `A` is dense, `A⁻¹` is anti-bidiagonal, and `A⁻²` is tridiagonal.  Only the
  *squared* problem is tridiagonal, which is exactly why the closed form obtained here
  determines `P(x)·P(−x)` but not `P(x)` itself — the parity split of the staircase
  conjecture is the extraction of a square root of this polynomial.
* **Critique.**  The determinant recurrence is proved by two genuine Laplace expansions
  (row `0`, then column `0` of the minor), not by `decide`; the closed form is a two-step
  induction resting on the Pascal identity
  `C(m+2,2i+2) + C(m,2i+2) = C(m,2i) + 2 C(m+1,2i+2)`.
-/

namespace AdjSum

open Polynomial Matrix

/-! ### Tridiagonal continuants -/

/-- A tridiagonal matrix with diagonal `u` (except the last entry, which is `v`) and both
off-diagonals equal to `w`. -/
def triMat {R : Type*} [CommRing R] (u v w : R) (n : ℕ) : Matrix (Fin n) (Fin n) R := fun i j =>
  if (i : ℕ) = (j : ℕ) then (if (i : ℕ) + 1 = n then v else u)
  else if (i : ℕ) + 1 = (j : ℕ) ∨ (j : ℕ) + 1 = (i : ℕ) then w else 0

lemma val_succAbove {m : ℕ} (p : Fin (m + 1)) (x : Fin m) :
    ((p.succAbove x : Fin (m + 1)) : ℕ) = if (x : ℕ) < (p : ℕ) then (x : ℕ) else (x : ℕ) + 1 :=
  apply_ite Fin.val (x.castSucc < p) x.castSucc x.succ

lemma triMat_sub_succ_succ {R : Type*} [CommRing R] (u v w : R) (n : ℕ) :
    (triMat u v w (n + 2)).submatrix Fin.succ Fin.succ = triMat u v w (n + 1) := by
  ext i j
  simp only [Matrix.submatrix_apply, triMat, Fin.val_succ]
  split_ifs <;> first | rfl | (exfalso; omega)

lemma triMat_sub_two {R : Type*} [CommRing R] (u v w : R) (n : ℕ) :
    ((triMat u v w (n + 2)).submatrix Fin.succ ((1 : Fin (n + 2)).succAbove)).submatrix
      Fin.succ Fin.succ = triMat u v w n := by
  have h1 : ((1 : Fin (n + 2)) : ℕ) = 1 := by simp
  ext i j
  simp only [Matrix.submatrix_apply, triMat, Fin.val_succ, val_succAbove, h1]
  rw [if_neg (by omega : ¬ ((j : ℕ) + 1 < 1))]
  split_ifs <;> first | rfl | (exfalso; omega)

@[simp] lemma det_triMat_zero {R : Type*} [CommRing R] (u v w : R) :
    (triMat u v w 0).det = 1 := by
  simp

@[simp] lemma det_triMat_one {R : Type*} [CommRing R] (u v w : R) :
    (triMat u v w 1).det = v := by
  rw [Matrix.det_fin_one]
  simp [triMat]

/-- **The continuant recurrence.**  Laplace expansion along the first row, and then along
the first column of the second minor, gives the classical three-term recurrence for
tridiagonal determinants. -/
theorem det_triMat_rec {R : Type*} [CommRing R] (u v w : R) (n : ℕ) :
    (triMat u v w (n + 2)).det
      = u * (triMat u v w (n + 1)).det - w ^ 2 * (triMat u v w n).det := by
  have h1 : ((1 : Fin (n + 2)) : ℕ) = 1 := by simp
  have h0 : ((0 : Fin (n + 2)) : ℕ) = 0 := rfl
  have h0' : ((0 : Fin (n + 1)) : ℕ) = 0 := rfl
  rw [Matrix.det_succ_row_zero]
  rw [Finset.sum_eq_add_of_mem (0 : Fin (n + 2)) (1 : Fin (n + 2))
      (by simp) (by simp) (by simp) ?_]
  · have e00 : triMat u v w (n + 2) 0 0 = u := by
      simp only [triMat, h0]
      norm_num
    have e01 : triMat u v w (n + 2) 0 1 = w := by
      simp only [triMat, h1, h0]
      norm_num
    rw [e00, e01, Fin.succAbove_zero, triMat_sub_succ_succ]
    have hsecond : ((triMat u v w (n + 2)).submatrix Fin.succ ((1 : Fin (n + 2)).succAbove)).det
        = w * (triMat u v w n).det := by
      rw [Matrix.det_succ_column_zero, Finset.sum_eq_single (0 : Fin (n + 1))]
      · simp only [Matrix.submatrix_apply, h0', pow_zero, one_mul]
        have hval : triMat u v w (n + 2) (Fin.succ 0) ((1 : Fin (n + 2)).succAbove 0) = w := by
          simp only [triMat, val_succAbove, h1, Fin.val_succ, h0']
          norm_num
        rw [hval, Fin.succAbove_zero, triMat_sub_two]
      · intro b _ hb
        have hbv : 1 ≤ (b : ℕ) := by
          rcases Nat.eq_zero_or_pos (b : ℕ) with h | h
          · exact absurd (Fin.ext (by simpa using h)) hb
          · exact h
        have hz : triMat u v w (n + 2) (Fin.succ b) ((1 : Fin (n + 2)).succAbove 0) = 0 := by
          simp only [triMat, val_succAbove, h1, Fin.val_succ, h0']
          norm_num
          omega
        simp only [Matrix.submatrix_apply]
        rw [hz]
        ring
      · intro h
        exact absurd (Finset.mem_univ _) h
    rw [hsecond, h0, h1]
    ring
  · intro k _ hk
    obtain ⟨hk0, hk1⟩ := hk
    have a0 : (k : ℕ) ≠ 0 := fun h => hk0 (Fin.ext (by rw [h, h0]))
    have a1 : (k : ℕ) ≠ 1 := fun h => hk1 (Fin.ext (by rw [h, h1]))
    have hzz : triMat u v w (n + 2) 0 k = 0 := by
      simp only [triMat, h0]
      rw [if_neg (by omega), if_neg (by omega)]
    rw [hzz]
    ring

/-! ### The Laplacian characteristic polynomial in closed form -/

/-- The characteristic polynomial of the `n`-site path Laplacian with one Dirichlet and one
Neumann end, defined by its continuant recurrence. -/
noncomputable def lapPoly : ℕ → ℤ[X]
  | 0 => 1
  | 1 => X - C 1
  | (n + 2) => (X - C 2) * lapPoly (n + 1) - lapPoly n

/-- **Closed form of the Laplacian characteristic polynomial.**  Every coefficient is a
binomial coefficient with alternating sign: `(lapPoly n).coeff j = (−1)^{n+j} C(n+j, 2j)`.
(For `j > n` both sides vanish, since then `2j > n + j`.) -/
theorem coeff_lapPoly : ∀ (n j : ℕ),
    (lapPoly n).coeff j = (-1 : ℤ) ^ (n + j) * ((n + j).choose (2 * j) : ℤ)
  | 0, j => by
      rcases Nat.eq_zero_or_pos j with rfl | hj
      · simp [lapPoly]
      · rw [lapPoly, Polynomial.coeff_one, if_neg (by omega),
          Nat.choose_eq_zero_of_lt (by omega)]
        simp
  | 1, j => by
      rw [lapPoly, Polynomial.coeff_sub, Polynomial.coeff_X, Polynomial.coeff_C]
      match j with
      | 0 => norm_num
      | 1 => norm_num
      | (k + 2) =>
        rw [Nat.choose_eq_zero_of_lt (by omega)]
        norm_num
  | (n + 2), j => by
      have ih1 := coeff_lapPoly (n + 1)
      have ih0 := coeff_lapPoly n
      rw [lapPoly, Polynomial.coeff_sub, ih0,
        show (X - C 2) * lapPoly (n + 1) = X * lapPoly (n + 1) - C 2 * lapPoly (n + 1) by ring,
        Polynomial.coeff_sub, Polynomial.coeff_C_mul]
      match j with
      | 0 =>
        rw [Polynomial.mul_coeff_zero, ih1]
        simp only [Polynomial.coeff_X_zero, zero_mul, zero_sub, Nat.mul_zero,
          Nat.choose_zero_right, Nat.add_zero, Nat.cast_one, mul_one]
        have h1 : ((-1 : ℤ)) ^ (n + 1) = -((-1 : ℤ) ^ n) := by rw [pow_succ]; ring
        have h2 : ((-1 : ℤ)) ^ (n + 2) = ((-1 : ℤ) ^ n) := by rw [pow_add]; norm_num
        rw [h1, h2]
        ring
      | (i + 1) =>
        rw [Polynomial.coeff_X_mul, ih1, ih1]
        have hbin : (n + 1 + i + 2).choose (2 * (i + 1)) + (n + 1 + i).choose (2 * (i + 1))
            = (n + 1 + i).choose (2 * i) + 2 * ((n + 1 + i + 1).choose (2 * (i + 1))) := by
          have p1 : (n + 1 + i + 2).choose (2 * i + 2)
              = (n + 1 + i + 1).choose (2 * i + 1) + (n + 1 + i + 1).choose (2 * i + 2) :=
            Nat.choose_succ_succ (n + 1 + i + 1) (2 * i + 1)
          have p2 : (n + 1 + i + 1).choose (2 * i + 1)
              = (n + 1 + i).choose (2 * i) + (n + 1 + i).choose (2 * i + 1) :=
            Nat.choose_succ_succ (n + 1 + i) (2 * i)
          have p3 : (n + 1 + i + 1).choose (2 * i + 2)
              = (n + 1 + i).choose (2 * i + 1) + (n + 1 + i).choose (2 * i + 2) :=
            Nat.choose_succ_succ (n + 1 + i) (2 * i + 1)
          have e : 2 * (i + 1) = 2 * i + 2 := by ring
          rw [e, p1, p2, p3]
          omega
        have hbinZ : ((n + 1 + i + 2).choose (2 * (i + 1)) : ℤ)
            + ((n + 1 + i).choose (2 * (i + 1)) : ℤ)
            = ((n + 1 + i).choose (2 * i) : ℤ)
              + 2 * (((n + 1 + i + 1).choose (2 * (i + 1)) : ℤ)) := by
          exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) hbin
        rw [show n + 1 + (i + 1) = (n + 1 + i) + 1 by ring,
          show n + (i + 1) = (n + 1 + i) by ring,
          show n + 2 + (i + 1) = (n + 1 + i) + 2 by ring, pow_succ, pow_add]
        norm_num
        linear_combination ((-1 : ℤ) ^ n * (-1 : ℤ) ^ i) * hbinZ

/-- The tridiagonal determinant with diagonal `X − 2`, corner `X − 1` and off-diagonal `1`
is `lapPoly n`. -/
theorem det_triMat_charmatrix (n : ℕ) :
    (triMat (X - C 2) (X - C (1 : ℤ)) 1 n).det = lapPoly n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => simp [lapPoly]
    | 1 => rw [det_triMat_one, lapPoly]
    | (m + 2) =>
      rw [det_triMat_rec, ih (m + 1) (by omega), ih m (by omega), lapPoly]
      ring

/-- The characteristic matrix of the Neumann path Laplacian is the reversal of the
tridiagonal matrix `triMat (X−2) (X−1) 1`. -/
lemma charmatrix_neumannLaplacian (s : ℕ) :
    charmatrix (neumannLaplacian s)
      = (triMat (X - C 2) (X - C (1 : ℤ)) 1 (s + 1)).submatrix Fin.rev Fin.rev := by
  refine Matrix.ext fun i j => ?_
  have hi : ((Fin.rev i : Fin (s + 1)) : ℕ) = s - (i : ℕ) := by
    rw [Fin.val_rev]
    omega
  have hj : ((Fin.rev j : Fin (s + 1)) : ℕ) = s - (j : ℕ) := by
    rw [Fin.val_rev]
    omega
  have hi' := i.isLt
  have hj' := j.isLt
  simp only [Matrix.submatrix_apply, triMat, hi, hj]
  by_cases h : i = j
  · subst h
    rw [charmatrix_apply_eq, if_pos rfl, neumannLaplacian_apply, if_pos rfl]
    by_cases h0 : (i : ℕ) = 0
    · rw [if_pos h0, if_pos (show s - (i : ℕ) + 1 = s + 1 by omega)]
    · rw [if_neg h0, if_neg (show ¬ (s - (i : ℕ) + 1 = s + 1) by omega)]
  · have hne : (i : ℕ) ≠ (j : ℕ) := fun hc => h (Fin.ext hc)
    rw [charmatrix_apply_ne (neumannLaplacian s) i j h, neumannLaplacian_apply,
      if_neg hne, if_neg (show ¬ (s - (i : ℕ) = s - (j : ℕ)) by omega)]
    by_cases hadj : (i : ℕ) + 1 = (j : ℕ) ∨ (j : ℕ) + 1 = (i : ℕ)
    · rw [if_pos hadj,
        if_pos (show s - (i : ℕ) + 1 = s - (j : ℕ) ∨ s - (j : ℕ) + 1 = s - (i : ℕ) by omega)]
      simp
    · rw [if_neg hadj,
        if_neg (show ¬ (s - (i : ℕ) + 1 = s - (j : ℕ) ∨ s - (j : ℕ) + 1 = s - (i : ℕ)) by omega)]
      simp

/-- **The characteristic polynomial of the Neumann path Laplacian.** -/
theorem charpoly_neumannLaplacian (s : ℕ) :
    (neumannLaplacian s).charpoly = lapPoly (s + 1) := by
  rw [Matrix.charpoly, charmatrix_neumannLaplacian,
    show ((triMat (X - C 2) (X - C (1 : ℤ)) 1 (s + 1)).submatrix Fin.rev Fin.rev)
        = (triMat (X - C 2) (X - C (1 : ℤ)) 1 (s + 1)).submatrix
            (Fin.revPerm : Equiv.Perm (Fin (s + 1))) (Fin.revPerm : Equiv.Perm (Fin (s + 1)))
      from rfl,
    Matrix.det_submatrix_equiv_self (Fin.revPerm : Equiv.Perm (Fin (s + 1))),
    det_triMat_charmatrix]

/-- The characteristic polynomial of `A⁻²`, in closed binomial form. -/
theorem charpoly_invAdjMatZ_sq (s : ℕ) :
    (invAdjMatZ s ^ 2).charpoly = lapPoly (s + 1) := by
  rw [invAdjMatZ_sq, charpoly_neumannLaplacian]

/-! ### The characteristic polynomial of `A²` -/

/-- **Closed form for the characteristic polynomial of the squared transfer matrix.**
`det(y I − A²) = ∑_{k ≤ s+1} (−1)^k C(s+1+k, 2k) y^{s+1−k}`, coefficient by coefficient. -/
theorem charpoly_adjMatZ_sq_coeff (s k : ℕ) (hk : k ≤ s + 1) :
    ((adjMatZ s) ^ 2).charpoly.coeff (s + 1 - k) = (-1 : ℤ) ^ k * ((s + 1 + k).choose (2 * k) : ℤ) := by
  have hdeg : ((adjMatZ s) ^ 2).charpoly.natDegree = s + 1 := by
    rw [Matrix.charpoly_natDegree_eq_dim]
    simp
  have hrev : ((adjMatZ s) ^ 2).charpoly.reverse.coeff k
      = ((adjMatZ s) ^ 2).charpoly.coeff (s + 1 - k) := by
    rw [Polynomial.coeff_reverse, hdeg, Polynomial.revAt_le hk]
  rw [← hrev, reverse_charpoly_adjMatZ_sq, charpoly_invAdjMatZ_sq]
  rw [show ((-1 : ℤ[X]) ^ (s + 1)) = C ((-1 : ℤ) ^ (s + 1)) by simp,
    Polynomial.coeff_C_mul, coeff_lapPoly]
  have hsign : ((-1 : ℤ) ^ (s + 1)) * ((-1 : ℤ) ^ (s + 1 + k)) = (-1 : ℤ) ^ k := by
    rw [← pow_add]
    rw [show s + 1 + (s + 1 + k) = 2 * (s + 1) + k by ring, pow_add, pow_mul]
    norm_num
  rw [← mul_assoc, hsign]

/-! ### The parity product bridge -/

/-- Composing a characteristic polynomial with `q` is the determinant of `q I - M`. -/
theorem charpoly_comp_eq_det {s : ℕ} (A : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ) (q : ℤ[X]) :
    A.charpoly.comp q
      = Matrix.det (q • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) - A.map C) := by
  have h := RingHom.map_det (Polynomial.eval₂RingHom (C : ℤ →+* ℤ[X]) q) (charmatrix A)
  rw [Matrix.charpoly, show A.charmatrix.det.comp q
      = (Polynomial.eval₂RingHom (C : ℤ →+* ℤ[X]) q) A.charmatrix.det from rfl, h]
  congr 1
  refine Matrix.ext fun i j => ?_
  have hC : ∀ a : ℤ, (Polynomial.eval₂RingHom (C : ℤ →+* ℤ[X]) q) (C a) = C a := by
    intro a
    simp
  by_cases hij : i = j
  · subst hij
    rw [RingHom.mapMatrix_apply, Matrix.map_apply, charmatrix_apply_eq, map_sub, hC]
    simp
  · rw [RingHom.mapMatrix_apply, Matrix.map_apply, charmatrix_apply_ne A i j hij, map_neg, hC]
    simp [Matrix.one_apply_ne hij]

/-- **The parity product identity.**  `det(x I − A) · det(x I + A) = det(x² I − A²)`, written
entirely in terms of characteristic polynomials:
`charpoly A · (−1)^{s+1} (charpoly A)(−x) = (charpoly A²)(x²)`.
Combined with `charpoly_adjMatZ_sq_coeff` this determines the *product* of the two parity
classes of the binomial staircase conjecture in closed form. -/
theorem charpoly_mul_charpoly_neg {s : ℕ} (A : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ) :
    A.charpoly * ((-1 : ℤ[X]) ^ (s + 1) * A.charpoly.comp (-X))
      = (A ^ 2).charpoly.comp (X ^ 2) := by
  have h1 : A.charpoly
      = Matrix.det ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) - A.map C) := by
    simpa using charpoly_comp_eq_det A X
  have h2 := charpoly_comp_eq_det A (-X)
  have h3 := charpoly_comp_eq_det (A ^ 2) (X ^ 2)
  have hneg : ((-1 : ℤ[X]) ^ (s + 1))
        * Matrix.det ((-X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) - A.map C)
      = Matrix.det ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) + A.map C) := by
    rw [show ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) + A.map C)
        = -((-X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) - A.map C) by
      rw [neg_sub]
      module]
    rw [Matrix.det_neg]
    simp
  have hprod : ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) - A.map C)
      * ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) + A.map C)
      = ((X : ℤ[X]) ^ 2) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) - (A ^ 2).map C := by
    have hcomm : ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X])) * (A.map C)
        = (A.map C) * ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X])) := by
      rw [Matrix.smul_mul, Matrix.one_mul, Matrix.mul_smul, Matrix.mul_one]
    have hsq : ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]))
        * ((X : ℤ[X]) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]))
        = ((X : ℤ[X]) ^ 2) • (1 : Matrix (Fin (s + 1)) (Fin (s + 1)) ℤ[X]) := by
      rw [Matrix.smul_mul, Matrix.one_mul, smul_smul, sq]
    have hmap : (A ^ 2).map C = (A.map C) * (A.map C) := by
      rw [sq, Matrix.map_mul]
    rw [sub_mul, mul_add, mul_add, hcomm, hsq, hmap]
    abel
  rw [h2, h3, h1, hneg, ← Matrix.det_mul, hprod]

/-- **An explicit binomial recurrence for the even-length cyclic counts.**  The number of
cyclic adjacent-sum points of even length satisfies the linear recurrence whose
characteristic polynomial is `charpoly (A²)`, all of whose coefficients are the binomials
above. -/
theorem cycCount_even_recurrence (s m : ℕ) :
    ∑ k ∈ Finset.range (s + 2),
        (-1 : ℤ) ^ k * ((s + 1 + k).choose (2 * k) : ℤ)
          * (cycCount s (2 * (m + (s + 1 - k)) + 1) : ℤ) = 0 := by
  have h := charpoly_trace_recurrence ((adjMatZ s) ^ 2) (m + 1)
  rw [show s + 1 + 1 = s + 2 from rfl] at h
  have htr : ∀ i : ℕ, Matrix.trace (((adjMatZ s) ^ 2) ^ (m + 1 + i))
      = (cycCount s (2 * (m + i) + 1) : ℤ) := by
    intro i
    rw [cycCount_eq, show 2 * (m + i) + 1 + 1 = 2 * (m + 1 + i) by omega, ← pow_mul]
  have h' : ∑ i ∈ Finset.range (s + 2),
      ((adjMatZ s) ^ 2).charpoly.coeff i * (cycCount s (2 * (m + i) + 1) : ℤ) = 0 := by
    rw [← h]
    exact Finset.sum_congr rfl (fun i _ => by rw [htr i])
  have hg : ∀ k ∈ Finset.range (s + 2),
      (-1 : ℤ) ^ k * ((s + 1 + k).choose (2 * k) : ℤ)
          * (cycCount s (2 * (m + (s + 1 - k)) + 1) : ℤ)
        = ((adjMatZ s) ^ 2).charpoly.coeff (s + 1 - k)
            * (cycCount s (2 * (m + (s + 1 - k)) + 1) : ℤ) := by
    intro k hk
    rw [Finset.mem_range] at hk
    rw [charpoly_adjMatZ_sq_coeff s k (by omega)]
  have hrefl := Finset.sum_range_reflect
    (fun i => ((adjMatZ s) ^ 2).charpoly.coeff i * (cycCount s (2 * (m + i) + 1) : ℤ)) (s + 2)
  simp only [show ∀ k : ℕ, s + 2 - 1 - k = s + 1 - k from fun k => by omega] at hrefl
  rw [Finset.sum_congr rfl hg, hrefl, h']

end AdjSum