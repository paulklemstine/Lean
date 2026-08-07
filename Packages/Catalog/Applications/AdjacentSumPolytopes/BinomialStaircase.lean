import Applications.AdjacentSumPolytopes.Determinant

/-!
# The binomial staircase: a closed form for the characteristic polynomial

This file proves the headline **Conjecture 1** of `FUTURE_DIRECTIONS.md`: for every slack
`s` and every `0 ≤ m ≤ s + 1`,

`coeff of X^{s+1-m} in charpoly (adjMat s) = (−1)^{⌊(m+1)/2⌋} · C(⌊(s+1+m)/2⌋, m)`.

The proof is a chain of four structural steps, none of which uses the spectral picture.

1. **Unitriangular factorisation.**  `adjMat s = J · L` with `J` the reversal permutation
   and `L` the all-ones lower unitriangular matrix.  Multiplying the characteristic matrix
   by `L^{-1}` on the right turns it into the extremely sparse *stair matrix*
   `stairG x e d n` with `x` on the diagonal, `−x` on the subdiagonal and `e` on the
   antidiagonal `i + j = d`.  Since `det L = 1`,
   `charpoly (adjMat s) = det (stair X (−1) s)` and
   `charpoly (−adjMat s) = det (stair X 1 s)`.

2. **A Laplace recurrence for the stair determinants.**  Expanding along the first row
   (which has exactly two nonzero entries) and then along the last column of the first
   minor, while the second minor is `−1` times the transpose of a stair matrix with the
   *opposite* antidiagonal sign, gives the sign-flipping recurrence

   `det (stair x e (n+2)) = x² · det (stair x e n) + e · det (stair x (−e) (n+1))`.

   Specialising `e = ∓1` couples the two parity classes:
   `P_{s+2} = X² P_s − R_{s+1}` and `R_{s+2} = X² R_s + P_{s+1}`, where `P` and `R` are the
   characteristic polynomials of `A_s` and `−A_s`.

3. **A binomial recurrence.**  The candidate coefficients
   `sc s m = (−1)^{⌊(m+1)/2⌋} C(⌊(s+1+m)/2⌋, m)` satisfy exactly the matching recurrence
   `sc (s+2) (m+1) = sc s (m+1) + (−1)^{m+1} · sc (s+1) m`, because
   `⌊(s+3+m)/2⌋ = ⌊(s+1+m)/2⌋ + 1` and Pascal's rule.

4. **Two-step induction.**  Feeding 2 and 3 into a simultaneous induction over the pair
   `(P_s, R_s)` gives the closed form.

## Main results

* `AdjSum.det_stair_rec` : the sign-flipping stair recurrence.
* `AdjSum.charpoly_eq_det_stair`, `AdjSum.charpoly_neg_eq_det_stair` : the two
  characteristic polynomials as stair determinants.
* `AdjSum.charpoly_adjMatZ_succ_two` : `P_{s+2} = X² P_s − R_{s+1}`.
* `AdjSum.charpoly_neg_adjMatZ_succ_two` : `R_{s+2} = X² R_s + P_{s+1}`.
* `AdjSum.charpoly_adjMatZ_succ_four` : `P_{s+4} = (2X² − 1) P_{s+2} − X⁴ P_s`.
* `AdjSum.charpoly_coeff_adjMatZ` : **the binomial staircase**, Conjecture 1.
* `AdjSum.charpoly_coeff_neg_adjMatZ` : the companion formula for `−A_s`.
* `AdjSum.charpoly_adjMatZ_eq_sum` : the staircase as one polynomial identity.
* `AdjSum.cycCount_binomial_recurrence`, `AdjSum.openCount_binomial_recurrence` : the
  resulting fully explicit binomial linear recurrences for both lattice-point classes.

-- !-- Lab Notes -- !--
* **Experiment.** Exact Faddeev–LeVerrier computation of `charpoly (adjMat s)` for
  `s ≤ 8` gives the coefficient rows `1, −1`; `1, −1, −1`; `1, −2, −1, 1`;
  `1, −2, −3, 1, 1`; `1, −3, −3, 4, 1, −1`; … matching
  `(−1)^{⌊(m+1)/2⌋} C(⌊(s+1+m)/2⌋, m)` in every entry.
* **Analysis.** The two parity classes are *not* independent: the recurrence of step 2
  flips the antidiagonal sign, so `P` and `R` interleave.  This is the algebraic shadow of
  the fact that the eigenvalues of `A_s` alternate in sign.
* **Critique.** The identity `⌊(m+2)/2⌋ + ⌊(m+1)/2⌋ = m + 1` is what makes the sign
  pattern `+, −, −, +` consistent with Pascal's rule; without it the recurrence of step 3
  would fail at every odd `m`.
-/

namespace AdjSum

open Polynomial Matrix Finset

/-! ### Stair matrices -/

variable {R : Type*} [CommRing R]

/-- The *stair matrix*: `x` on the diagonal, `−x` on the subdiagonal, and `e` on the
antidiagonal `i + j = d`.  (Entries add where the patterns overlap.) -/
def stairG (x e : R) (d n : ℕ) : Matrix (Fin n) (Fin n) R := fun i j =>
  (if (i : ℕ) = (j : ℕ) then x else 0) - (if (i : ℕ) = (j : ℕ) + 1 then x else 0)
    + (if (i : ℕ) + (j : ℕ) = d then e else 0)

lemma stairG_apply (x e : R) (d n : ℕ) (i j : Fin n) :
    stairG x e d n i j = (if (i : ℕ) = (j : ℕ) then x else 0)
      - (if (i : ℕ) = (j : ℕ) + 1 then x else 0) + (if (i : ℕ) + (j : ℕ) = d then e else 0) :=
  rfl

/-- The square stair matrix of size `n + 1` whose antidiagonal sits at level `n`. -/
abbrev stair (x e : R) (n : ℕ) : Matrix (Fin (n + 1)) (Fin (n + 1)) R := stairG x e n (n + 1)

/-- Deleting the first row and column lowers both the size and the antidiagonal level. -/
lemma stairG_sub_succ_succ (x e : R) (d n : ℕ) :
    (stairG x e (d + 2) (n + 1)).submatrix Fin.succ Fin.succ = stairG x e d n := by
  ext i j
  simp only [Matrix.submatrix_apply, stairG_apply, Fin.val_succ]
  congr 1
  · congr 1 <;> (split_ifs <;> first | rfl | omega)
  · split_ifs <;> first | rfl | omega

/-- Deleting the last row and column lowers the size only. -/
lemma stairG_sub_castSucc (x e : R) (d n : ℕ) :
    (stairG x e d (n + 1)).submatrix Fin.castSucc Fin.castSucc = stairG x e d n := by
  ext i j
  simp [Matrix.submatrix_apply, stairG_apply]

/-- When the antidiagonal level is two below the maximal one, the last column has a single
nonzero entry, so the determinant simply picks up a factor `x`. -/
lemma det_stairG_shift (x e : R) (n : ℕ) :
    (stairG x e n (n + 2)).det = x * (stairG x e n (n + 1)).det := by
  rw [Matrix.det_succ_column (stairG x e n (n + 2)) (Fin.last (n + 1))]
  have hcol : ∀ i : Fin (n + 2), stairG x e n (n + 2) i (Fin.last (n + 1))
      = if i = Fin.last (n + 1) then x else 0 := by
    intro i
    have hi : (i : ℕ) < n + 2 := i.isLt
    by_cases h : i = Fin.last (n + 1)
    · subst h
      simp only [stairG_apply, Fin.val_last, if_true]
      rw [if_neg (by omega), if_neg (by omega)]
      ring
    · have hne : (i : ℕ) ≠ n + 1 := by simpa [Fin.ext_iff] using h
      simp only [stairG_apply, Fin.val_last, if_neg h]
      rw [if_neg hne, if_neg (by omega), if_neg (by omega)]
      ring
  simp only [hcol]
  rw [Finset.sum_eq_single (Fin.last (n + 1))]
  · simp only [Fin.val_last, Fin.succAbove_last, stairG_sub_castSucc]
    rw [show ((-1 : R) ^ ((n + 1) + (n + 1))) = 1 from by rw [← two_mul, pow_mul]; simp]
    simp [mul_comm]
  · intro b _ hb; simp [hb]
  · intro h; exact absurd (Finset.mem_univ _) h

/-- The minor obtained by deleting the first row and the last column is `−1` times the
transpose of a stair matrix with the **opposite** antidiagonal sign. -/
lemma stairG_sub_succ_castSucc (x e : R) (n : ℕ) :
    (stairG x e (n + 2) (n + 3)).submatrix Fin.succ Fin.castSucc
      = -(stairG x (-e) (n + 1) (n + 2))ᵀ := by
  ext i j
  simp only [Matrix.submatrix_apply, Matrix.neg_apply, Matrix.transpose_apply, stairG_apply,
    Fin.val_succ, Fin.val_castSucc]
  split_ifs <;> first | (exfalso; omega) | ring

lemma det_stairG_sub_succ_castSucc (x e : R) (n : ℕ) :
    ((stairG x e (n + 2) (n + 3)).submatrix Fin.succ Fin.castSucc).det
      = (-1) ^ (n + 2) * (stairG x (-e) (n + 1) (n + 2)).det := by
  rw [stairG_sub_succ_castSucc, Matrix.det_neg, Matrix.det_transpose]
  simp

/-- **The sign-flipping stair recurrence.**  Laplace expansion along the first row of
`stair x e (n+2)`, whose only nonzero entries sit in the first and the last column. -/
theorem det_stair_rec (x e : R) (n : ℕ) :
    (stair x e (n + 2)).det = x ^ 2 * (stair x e n).det + e * (stair x (-e) (n + 1)).det := by
  have hrow : ∀ j : Fin (n + 3), stairG x e (n + 2) (n + 3) 0 j
      = (if j = 0 then x else 0) + (if j = Fin.last (n + 2) then e else 0) := by
    intro j
    have hj : (j : ℕ) < n + 3 := j.isLt
    have h0 : ((0 : Fin (n + 3)) : ℕ) = 0 := rfl
    simp only [stairG_apply, h0, Fin.ext_iff, Fin.val_last]
    split_ifs <;> first | (exfalso; omega) | ring
  show (stairG x e (n + 2) (n + 3)).det = _
  rw [Matrix.det_succ_row_zero]
  simp only [hrow, add_mul, mul_add, ite_mul, zero_mul, mul_ite, mul_zero,
    Finset.sum_add_distrib, Finset.sum_ite_eq' Finset.univ, Finset.mem_univ, if_true]
  rw [Fin.succAbove_zero, Fin.succAbove_last, stairG_sub_succ_succ, det_stairG_shift,
    det_stairG_sub_succ_castSucc]
  have h0 : ((0 : Fin (n + 3)) : ℕ) = 0 := rfl
  have hsq : ((-1 : R) ^ (n + 2)) * ((-1 : R) ^ (n + 2)) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul]; simp
  have key : ∀ a b : R, ((-1 : R) ^ (n + 2)) * a * (((-1 : R) ^ (n + 2)) * b) = a * b := by
    intro a b
    calc ((-1 : R) ^ (n + 2)) * a * (((-1 : R) ^ (n + 2)) * b)
        = (((-1 : R) ^ (n + 2)) * ((-1 : R) ^ (n + 2))) * (a * b) := by ring
      _ = a * b := by rw [hsq, one_mul]
  rw [h0, Fin.val_last, pow_zero, one_mul, key]
  ring

/-! ### The unitriangular factorisation -/

/-- The all-ones lower unitriangular matrix `L`, the second factor of `adjMat s = J · L`. -/
def onesLower (R : Type*) [CommRing R] (n : ℕ) : Matrix (Fin n) (Fin n) R :=
  fun i j => if (j : ℕ) ≤ (i : ℕ) then 1 else 0

lemma det_onesLower (n : ℕ) : (onesLower R n).det = 1 := by
  rw [Matrix.det_of_lowerTriangular]
  · simp [onesLower]
  · intro i j hij
    exact if_neg (not_le.mpr (by simpa [onesLower] using hij))

/-- **The key factorisation.**  Multiplying a stair matrix by `L` on the right restores the
dense staircase pattern `[i + j ≤ s]`. -/
lemma stair_mul_onesLower (x e : R) (s : ℕ) (i j : Fin (s + 1)) :
    (stairG x e s (s + 1) * onesLower R (s + 1)) i j
      = (if (i : ℕ) = (j : ℕ) then x else 0) + (if (i : ℕ) + (j : ℕ) ≤ s then e else 0) := by
  have hi : (i : ℕ) ≤ s := Nat.lt_succ_iff.mp i.isLt
  have hj : (j : ℕ) ≤ s := Nat.lt_succ_iff.mp j.isLt
  rw [Matrix.mul_apply]
  have expand : ∀ k : Fin (s + 1), stairG x e s (s + 1) i k * onesLower R (s + 1) k j
      = (if (i : ℕ) = (k : ℕ) then (if (j : ℕ) ≤ (k : ℕ) then x else 0) else 0)
        - (if (i : ℕ) = (k : ℕ) + 1 then (if (j : ℕ) ≤ (k : ℕ) then x else 0) else 0)
        + (if (i : ℕ) + (k : ℕ) = s then (if (j : ℕ) ≤ (k : ℕ) then e else 0) else 0) := by
    intro k
    simp only [stairG_apply, onesLower]
    split_ifs <;> ring
  simp only [expand]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have hS1 : ∑ k : Fin (s + 1),
      (if (i : ℕ) = (k : ℕ) then (if (j : ℕ) ≤ (k : ℕ) then x else 0) else 0)
      = if (j : ℕ) ≤ (i : ℕ) then x else 0 := by
    rw [Finset.sum_eq_single_of_mem i (Finset.mem_univ i)
      (fun b _ hb => if_neg (fun h => hb (Fin.ext h.symm)))]
    simp
  have hS3 : ∑ k : Fin (s + 1),
      (if (i : ℕ) + (k : ℕ) = s then (if (j : ℕ) ≤ (k : ℕ) then e else 0) else 0)
      = if (i : ℕ) + (j : ℕ) ≤ s then e else 0 := by
    have hmem : (⟨s - (i : ℕ), by omega⟩ : Fin (s + 1)) ∈ Finset.univ := Finset.mem_univ _
    rw [Finset.sum_eq_single_of_mem ⟨s - (i : ℕ), by omega⟩ hmem
      (fun b _ hb => if_neg (fun h => hb (Fin.ext (by simp; omega))))]
    rw [if_pos (by simp; omega)]
    by_cases h : (i : ℕ) + (j : ℕ) ≤ s
    · rw [if_pos (show (j : ℕ) ≤ ((⟨s - (i : ℕ), by omega⟩ : Fin (s + 1)) : ℕ) by simp; omega),
        if_pos h]
    · rw [if_neg (show ¬ ((j : ℕ) ≤ ((⟨s - (i : ℕ), by omega⟩ : Fin (s + 1)) : ℕ)) by simp; omega),
        if_neg h]
  rw [hS1, hS3]
  rcases Nat.eq_zero_or_pos (i : ℕ) with h0 | hpos
  · have hS2 : ∑ k : Fin (s + 1),
        (if (i : ℕ) = (k : ℕ) + 1 then (if (j : ℕ) ≤ (k : ℕ) then x else 0) else 0) = 0 :=
      Finset.sum_eq_zero (fun k _ => if_neg (by omega))
    rw [hS2]
    split_ifs
    all_goals (try (exfalso; omega))
    all_goals ring
  · obtain ⟨t, ht⟩ : ∃ t, (i : ℕ) = t + 1 := ⟨(i : ℕ) - 1, by omega⟩
    have hS2 : ∑ k : Fin (s + 1),
        (if (i : ℕ) = (k : ℕ) + 1 then (if (j : ℕ) ≤ (k : ℕ) then x else 0) else 0)
        = if (j : ℕ) ≤ t then x else 0 := by
      have hmem : (⟨t, by omega⟩ : Fin (s + 1)) ∈ Finset.univ := Finset.mem_univ _
      rw [Finset.sum_eq_single_of_mem ⟨t, by omega⟩ hmem
        (fun b _ hb => if_neg (fun h => hb (Fin.ext (by simp; omega))))]
      rw [if_pos (show (i : ℕ) = ((⟨t, by omega⟩ : Fin (s + 1)) : ℕ) + 1 by simp; omega)]
    rw [hS2]
    split_ifs
    all_goals (try (exfalso; omega))
    all_goals ring

lemma diagonal_X_val (s : ℕ) (i j : Fin (s + 1)) :
    (if i = j then (X : ℤ[X]) else 0) = (if (i : ℕ) = (j : ℕ) then (X : ℤ[X]) else 0) := by
  by_cases h : i = j
  · rw [if_pos h, if_pos (congrArg Fin.val h)]
  · rw [if_neg h, if_neg (fun hh => h (Fin.ext hh))]

lemma charmatrix_adjMatZ (s : ℕ) :
    charmatrix (adjMatZ s) = stairG (X : ℤ[X]) (-1) s (s + 1) * onesLower ℤ[X] (s + 1) := by
  refine Matrix.ext fun i j => ?_
  rw [stair_mul_onesLower, Matrix.charmatrix_apply, Matrix.diagonal_apply, diagonal_X_val,
    show adjMatZ s i j = if (i : ℕ) + (j : ℕ) ≤ s then 1 else 0 from rfl]
  by_cases h : (i : ℕ) + (j : ℕ) ≤ s
  · rw [if_pos h, if_pos h]; simp only [map_one]; ring
  · rw [if_neg h, if_neg h]; simp only [map_zero]; ring

lemma charmatrix_neg_adjMatZ (s : ℕ) :
    charmatrix (-(adjMatZ s)) = stairG (X : ℤ[X]) 1 s (s + 1) * onesLower ℤ[X] (s + 1) := by
  refine Matrix.ext fun i j => ?_
  rw [stair_mul_onesLower, Matrix.charmatrix_apply, Matrix.diagonal_apply, diagonal_X_val,
    show (-(adjMatZ s)) i j = -(if (i : ℕ) + (j : ℕ) ≤ s then 1 else 0) from rfl]
  by_cases h : (i : ℕ) + (j : ℕ) ≤ s
  · rw [if_pos h, if_pos h]; simp only [map_one, map_neg]; ring
  · rw [if_neg h, if_neg h]; simp only [map_zero, map_neg]; ring

/-- The characteristic polynomial of the transfer matrix is a stair determinant. -/
theorem charpoly_eq_det_stair (s : ℕ) :
    (adjMatZ s).charpoly = (stair (X : ℤ[X]) (-1) s).det := by
  rw [Matrix.charpoly, charmatrix_adjMatZ, Matrix.det_mul, det_onesLower, mul_one]

/-- The characteristic polynomial of the *negated* transfer matrix is the stair determinant
with the opposite antidiagonal sign. -/
theorem charpoly_neg_eq_det_stair (s : ℕ) :
    (-(adjMatZ s)).charpoly = (stair (X : ℤ[X]) 1 s).det := by
  rw [Matrix.charpoly, charmatrix_neg_adjMatZ, Matrix.det_mul, det_onesLower, mul_one]

/-! ### The coupled two-step recurrences -/

/-- `P_{s+2} = X² P_s − R_{s+1}`. -/
theorem charpoly_adjMatZ_succ_two (s : ℕ) :
    (adjMatZ (s + 2)).charpoly
      = X ^ 2 * (adjMatZ s).charpoly - (-(adjMatZ (s + 1))).charpoly := by
  rw [charpoly_eq_det_stair, charpoly_eq_det_stair, charpoly_neg_eq_det_stair,
    det_stair_rec (X : ℤ[X]) (-1) s]
  rw [neg_neg]
  ring

/-- `R_{s+2} = X² R_s + P_{s+1}`. -/
theorem charpoly_neg_adjMatZ_succ_two (s : ℕ) :
    (-(adjMatZ (s + 2))).charpoly
      = X ^ 2 * (-(adjMatZ s)).charpoly + (adjMatZ (s + 1)).charpoly := by
  rw [charpoly_neg_eq_det_stair, charpoly_neg_eq_det_stair, charpoly_eq_det_stair,
    det_stair_rec (X : ℤ[X]) 1 s]
  ring

/-- **A pure four-step recurrence inside one parity class.**  Eliminating `R` between the
two coupled recurrences leaves `P_{s+4} = (2X² − 1) P_{s+2} − X⁴ P_s`. -/
theorem charpoly_adjMatZ_succ_four (s : ℕ) :
    (adjMatZ (s + 4)).charpoly
      = (2 * X ^ 2 - 1) * (adjMatZ (s + 2)).charpoly - X ^ 4 * (adjMatZ s).charpoly := by
  have h1 : (adjMatZ (s + 4)).charpoly
      = X ^ 2 * (adjMatZ (s + 2)).charpoly - (-(adjMatZ (s + 3))).charpoly :=
    charpoly_adjMatZ_succ_two (s + 2)
  have h2 : (-(adjMatZ (s + 3))).charpoly
      = X ^ 2 * (-(adjMatZ (s + 1))).charpoly + (adjMatZ (s + 2)).charpoly :=
    charpoly_neg_adjMatZ_succ_two (s + 1)
  have h3 : (adjMatZ (s + 2)).charpoly
      = X ^ 2 * (adjMatZ s).charpoly - (-(adjMatZ (s + 1))).charpoly :=
    charpoly_adjMatZ_succ_two s
  have h4 : (-(adjMatZ (s + 1))).charpoly
      = X ^ 2 * (adjMatZ s).charpoly - (adjMatZ (s + 2)).charpoly := by
    rw [h3]; ring
  rw [h1, h2, h4]
  ring

/-! ### The binomial coefficients and their recurrence -/

/-- The conjectured coefficient `sc s m = (−1)^{⌊(m+1)/2⌋} · C(⌊(s+1+m)/2⌋, m)`. -/
def sc (s m : ℕ) : ℤ := (-1) ^ ((m + 1) / 2) * (((s + 1 + m) / 2).choose m : ℤ)

@[simp] lemma sc_zero_right (s : ℕ) : sc s 0 = 1 := by simp [sc]

/-- Beyond the degree the binomial staircase vanishes, as it must. -/
lemma sc_eq_zero (s m : ℕ) (h : s + 1 < m) : sc s m = 0 := by
  unfold sc
  rw [Nat.choose_eq_zero_of_lt (by omega)]
  simp

/-- **Pascal's rule for the staircase.**  This is the exact shadow of the coupled
determinant recurrence. -/
lemma sc_rec (s m : ℕ) : sc (s + 2) (m + 1) = sc s (m + 1) + (-1) ^ (m + 1) * sc (s + 1) m := by
  unfold sc
  have h1 : (s + 2 + 1 + (m + 1)) / 2 = (s + 1 + (m + 1)) / 2 + 1 := by omega
  have h2 : (s + 1 + 1 + m) / 2 = (s + 1 + (m + 1)) / 2 := by omega
  rw [h1, h2]
  set K := (s + 1 + (m + 1)) / 2 with hK
  rw [Nat.choose_succ_succ K m]
  have hsign : ((-1 : ℤ)) ^ ((m + 1 + 1) / 2) = (-1) ^ (m + 1) * (-1) ^ ((m + 1) / 2) := by
    rw [← pow_add]
    refine neg_one_pow_eq_of_mod_two ?_
    rcases Nat.even_or_odd m with ⟨t, ht⟩ | ⟨t, ht⟩ <;> subst ht <;> omega
  rw [hsign]
  push_cast
  ring

/-! ### Base cases -/

lemma charpoly_adjMatZ_zero : (adjMatZ 0).charpoly = X - 1 := by
  rw [Matrix.charpoly, Matrix.det_fin_one, Matrix.charmatrix_apply]
  simp [adjMatZ]

lemma charpoly_neg_adjMatZ_zero : (-(adjMatZ 0)).charpoly = X + 1 := by
  rw [Matrix.charpoly, Matrix.det_fin_one, Matrix.charmatrix_apply]
  simp [adjMatZ]

lemma charpoly_adjMatZ_one : (adjMatZ 1).charpoly = X ^ 2 - X - 1 := by
  rw [Matrix.charpoly_fin_two]
  have ht : (adjMatZ 1).trace = 1 := by simp [Matrix.trace_fin_two, adjMatZ]
  have hd : (adjMatZ 1).det = -1 := by rw [Matrix.det_fin_two]; norm_num [adjMatZ]
  rw [ht, hd]
  simp
  ring

lemma charpoly_neg_adjMatZ_one : (-(adjMatZ 1)).charpoly = X ^ 2 + X - 1 := by
  rw [Matrix.charpoly_fin_two]
  have ht : (-(adjMatZ 1)).trace = -1 := by simp [Matrix.trace_fin_two, adjMatZ]
  have hd : (-(adjMatZ 1)).det = -1 := by rw [Matrix.det_fin_two]; norm_num [adjMatZ]
  rw [ht, hd]
  simp
  ring

/-! ### The two-step induction -/

lemma natDegree_charpoly_adjMatZ (s : ℕ) : (adjMatZ s).charpoly.natDegree = s + 1 := by
  rw [Matrix.charpoly_natDegree_eq_dim]; simp

lemma natDegree_charpoly_neg_adjMatZ (s : ℕ) : (-(adjMatZ s)).charpoly.natDegree = s + 1 := by
  rw [Matrix.charpoly_natDegree_eq_dim]; simp

lemma coeff_X_sq_mul (p : ℤ[X]) (d : ℕ) :
    (X ^ 2 * p).coeff d = if 2 ≤ d then p.coeff (d - 2) else 0 := by
  rw [mul_comm, Polynomial.coeff_mul_X_pow']

lemma neg_one_pow_mul_self (k : ℕ) : ((-1 : ℤ) ^ k) * ((-1 : ℤ) ^ k) = 1 := by
  rw [← pow_add, ← two_mul, pow_mul]; simp

/-- The simultaneous statement for both parity classes, proved by induction in steps of
one while carrying two consecutive slacks. -/
lemma charpoly_coeff_pair : ∀ s : ℕ,
    (∀ m ≤ s + 1, (adjMatZ s).charpoly.coeff (s + 1 - m) = sc s m) ∧
    (∀ m ≤ s + 1, (-(adjMatZ s)).charpoly.coeff (s + 1 - m) = (-1) ^ m * sc s m) ∧
    (∀ m ≤ s + 2, (adjMatZ (s + 1)).charpoly.coeff (s + 2 - m) = sc (s + 1) m) ∧
    (∀ m ≤ s + 2, (-(adjMatZ (s + 1))).charpoly.coeff (s + 2 - m) = (-1) ^ m * sc (s + 1) m) := by
  intro s
  induction s with
  | zero =>
    refine ⟨?_, ?_, ?_, ?_⟩
    · intro m hm
      interval_cases m <;>
        simp [charpoly_adjMatZ_zero, sc, Polynomial.coeff_one, Polynomial.coeff_X]
    · intro m hm
      interval_cases m <;>
        simp [charpoly_neg_adjMatZ_zero, sc, Polynomial.coeff_one, Polynomial.coeff_X]
    · intro m hm
      interval_cases m <;>
        simp [charpoly_adjMatZ_one, sc, Polynomial.coeff_one, Polynomial.coeff_X]
    · intro m hm
      interval_cases m <;>
        simp [charpoly_neg_adjMatZ_one, sc, Polynomial.coeff_one, Polynomial.coeff_X]
  | succ n ih =>
    obtain ⟨hA, hB, hA1, hB1⟩ := ih
    refine ⟨hA1, hB1, ?_, ?_⟩
    · intro m hm
      have hidx : n + 1 + 1 + 1 - m = n + 3 - m := by omega
      rw [hidx, charpoly_adjMatZ_succ_two n, Polynomial.coeff_sub, coeff_X_sq_mul]
      rcases m with _ | m'
      · have e2 : (-(adjMatZ (n + 1))).charpoly.coeff (n + 3 - 0) = 0 := by
          refine Polynomial.coeff_eq_zero_of_natDegree_lt ?_
          rw [natDegree_charpoly_neg_adjMatZ]; omega
        rw [e2, if_pos (by omega), show n + 3 - 0 - 2 = n + 1 - 0 from by omega, hA 0 (by omega)]
        simp
      · have hm' : m' ≤ n + 2 := by omega
        have e2 : (-(adjMatZ (n + 1))).charpoly.coeff (n + 3 - (m' + 1))
            = (-1) ^ m' * sc (n + 1) m' := by
          rw [show n + 3 - (m' + 1) = n + 2 - m' from by omega]
          exact hB1 m' hm'
        have e1 : (if 2 ≤ n + 3 - (m' + 1) then (adjMatZ n).charpoly.coeff (n + 3 - (m' + 1) - 2)
            else 0) = sc n (m' + 1) := by
          by_cases hle : m' ≤ n
          · rw [if_pos (by omega), show n + 3 - (m' + 1) - 2 = n + 1 - (m' + 1) from by omega]
            exact hA (m' + 1) (by omega)
          · rw [if_neg (by omega)]
            exact (sc_eq_zero n (m' + 1) (by omega)).symm
        rw [e1, e2, sc_rec n m']
        rw [pow_succ]
        ring
    · intro m hm
      have hidx : n + 1 + 1 + 1 - m = n + 3 - m := by omega
      rw [hidx, charpoly_neg_adjMatZ_succ_two n, Polynomial.coeff_add, coeff_X_sq_mul]
      rcases m with _ | m'
      · have e2 : (adjMatZ (n + 1)).charpoly.coeff (n + 3 - 0) = 0 := by
          refine Polynomial.coeff_eq_zero_of_natDegree_lt ?_
          rw [natDegree_charpoly_adjMatZ]; omega
        rw [e2, if_pos (by omega), show n + 3 - 0 - 2 = n + 1 - 0 from by omega, hB 0 (by omega)]
        simp
      · have hm' : m' ≤ n + 2 := by omega
        have e2 : (adjMatZ (n + 1)).charpoly.coeff (n + 3 - (m' + 1)) = sc (n + 1) m' := by
          rw [show n + 3 - (m' + 1) = n + 2 - m' from by omega]
          exact hA1 m' hm'
        have e1 : (if 2 ≤ n + 3 - (m' + 1)
            then (-(adjMatZ n)).charpoly.coeff (n + 3 - (m' + 1) - 2) else 0)
            = (-1) ^ (m' + 1) * sc n (m' + 1) := by
          by_cases hle : m' ≤ n
          · rw [if_pos (by omega), show n + 3 - (m' + 1) - 2 = n + 1 - (m' + 1) from by omega]
            exact hB (m' + 1) (by omega)
          · rw [if_neg (by omega), sc_eq_zero n (m' + 1) (by omega)]
            ring
        have hcollapse : ((-1 : ℤ) ^ (m' + 1)) * (((-1 : ℤ) ^ (m' + 1)) * sc (n + 1) m')
            = sc (n + 1) m' := by
          rw [← mul_assoc, neg_one_pow_mul_self, one_mul]
        rw [e1, e2, sc_rec n m', mul_add, hcollapse]

/-- **The binomial staircase (Conjecture 1).**  For every slack `s` and every
`0 ≤ m ≤ s + 1`, the coefficient of `X^{s+1-m}` in the characteristic polynomial of the
adjacent-sum transfer matrix is `(−1)^{⌊(m+1)/2⌋} · C(⌊(s+1+m)/2⌋, m)`. -/
theorem charpoly_coeff_adjMatZ (s m : ℕ) (hm : m ≤ s + 1) :
    (adjMatZ s).charpoly.coeff (s + 1 - m)
      = (-1) ^ ((m + 1) / 2) * (((s + 1 + m) / 2).choose m : ℤ) :=
  (charpoly_coeff_pair s).1 m hm

/-- The companion formula for the negated transfer matrix: the same staircase with an extra
global sign `(−1)^m`. -/
theorem charpoly_coeff_neg_adjMatZ (s m : ℕ) (hm : m ≤ s + 1) :
    (-(adjMatZ s)).charpoly.coeff (s + 1 - m)
      = (-1) ^ m * ((-1) ^ ((m + 1) / 2) * (((s + 1 + m) / 2).choose m : ℤ)) :=
  (charpoly_coeff_pair s).2.1 m hm

/-- The binomial staircase as a single polynomial identity. -/
theorem charpoly_adjMatZ_eq_sum (s : ℕ) :
    (adjMatZ s).charpoly = ∑ m ∈ Finset.range (s + 2), C (sc s m) * X ^ (s + 1 - m) := by
  refine Polynomial.ext fun k => ?_
  rw [Polynomial.finset_sum_coeff]
  have hterm : ∀ m ∈ Finset.range (s + 2),
      (C (sc s m) * X ^ (s + 1 - m)).coeff k = if s + 1 - m = k then sc s m else 0 := by
    intro m _
    rw [Polynomial.coeff_C_mul, Polynomial.coeff_X_pow]
    by_cases h : s + 1 - m = k
    · rw [if_pos h, if_pos h.symm, mul_one]
    · rw [if_neg h, if_neg (fun hh => h hh.symm), mul_zero]
  rw [Finset.sum_congr rfl hterm]
  by_cases hk : k ≤ s + 1
  · rw [Finset.sum_eq_single_of_mem (s + 1 - k) (Finset.mem_range.mpr (by omega))
      (fun b hb hbne => if_neg (fun h => hbne (by rw [Finset.mem_range] at hb; omega)))]
    rw [if_pos (by omega)]
    have h2 := charpoly_coeff_adjMatZ s (s + 1 - k) (by omega)
    rw [show s + 1 - (s + 1 - k) = k from by omega] at h2
    rw [h2]
    rfl
  · rw [Finset.sum_eq_zero (fun m hm => if_neg (by rw [Finset.mem_range] at hm; omega))]
    exact Polynomial.coeff_eq_zero_of_natDegree_lt (by rw [natDegree_charpoly_adjMatZ]; omega)

/-! ### Fully explicit Ehrhart-type recurrences

The abstract recurrences `cycCount_recurrence` and `openCount_recurrence` of
`Recurrence.lean` say that both lattice-point count classes obey the linear recurrence read
off the characteristic polynomial.  With the staircase in hand those recurrences become
completely explicit binomial identities. -/

/-- **Explicit binomial recurrence, cyclic class.** -/
theorem cycCount_binomial_recurrence (s m : ℕ) :
    ∑ k ∈ Finset.range (s + 2), sc s k * (cycCount s (m + (s + 1 - k)) : ℤ) = 0 := by
  have h' := cycCount_recurrence s m
  have hrefl := Finset.sum_range_reflect
    (fun i => (adjMatZ s).charpoly.coeff i * (cycCount s (m + i) : ℤ)) (s + 2)
  simp only [show ∀ k : ℕ, s + 2 - 1 - k = s + 1 - k from fun k => by omega] at hrefl
  have hg : ∀ k ∈ Finset.range (s + 2),
      sc s k * (cycCount s (m + (s + 1 - k)) : ℤ)
        = (adjMatZ s).charpoly.coeff (s + 1 - k) * (cycCount s (m + (s + 1 - k)) : ℤ) := by
    intro k hk
    rw [Finset.mem_range] at hk
    rw [charpoly_coeff_adjMatZ s k (by omega)]
    rfl
  rw [Finset.sum_congr rfl hg, hrefl, h']

/-- **Explicit binomial recurrence, open class.**  The same staircase governs both parity
classes — this is the shared characteristic denominator, now with named coefficients. -/
theorem openCount_binomial_recurrence (s m : ℕ) :
    ∑ k ∈ Finset.range (s + 2), sc s k * (openCount s (m + (s + 1 - k)) : ℤ) = 0 := by
  have h' := openCount_recurrence s m
  have hrefl := Finset.sum_range_reflect
    (fun i => (adjMatZ s).charpoly.coeff i * (openCount s (m + i) : ℤ)) (s + 2)
  simp only [show ∀ k : ℕ, s + 2 - 1 - k = s + 1 - k from fun k => by omega] at hrefl
  have hg : ∀ k ∈ Finset.range (s + 2),
      sc s k * (openCount s (m + (s + 1 - k)) : ℤ)
        = (adjMatZ s).charpoly.coeff (s + 1 - k) * (openCount s (m + (s + 1 - k)) : ℤ) := by
    intro k hk
    rw [Finset.mem_range] at hk
    rw [charpoly_coeff_adjMatZ s k (by omega)]
    rfl
  rw [Finset.sum_congr rfl hg, hrefl, h']

end AdjSum