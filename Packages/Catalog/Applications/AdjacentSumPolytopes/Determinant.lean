import Applications.AdjacentSumPolytopes.Recurrence

/-!
# The transfer matrix is unimodular

The last row of the adjacent-sum transfer matrix is the unit vector `e₀` (only `b = 0`
satisfies `s + b ≤ s`), and deleting that row together with the first column shifts the
model down by one unit of slack.  Laplace expansion along the last row therefore gives the
one-step recurrence

`det(adjMat (s+1)) = (−1)^{s+1} · det(adjMat s)`,

whence the closed form `det(adjMat s) = (−1)^{⌊(s+1)/2⌋}`: the transfer matrix is
**unimodular** for every slack, with a period-four sign pattern `+, −, −, +`.

This settles sub-conjecture (S2) of `FUTURE_DIRECTIONS.md` and, via
`Matrix.det_eq_sign_charpoly_coeff`, the `m = s + 1` (constant-term) case of the binomial
staircase Conjecture 1, whose prediction there is `(−1)^{⌊(s+2)/2⌋}·C(s+1, s+1)`.

## Main results

* `AdjSum.det_adjMatZ_succ` : the Laplace recurrence `det A_{s+1} = (−1)^{s+1} det A_s`.
* `AdjSum.det_adjMatZ` : `det(adjMat s) = (−1)^{⌊(s+1)/2⌋}`.
* `AdjSum.isUnit_det_adjMatZ` : unimodularity, hence invertibility over `ℤ`.
* `AdjSum.charpoly_coeff_zero_adjMatZ` : the constant term of the characteristic
  polynomial is `(−1)^{⌊(s+2)/2⌋}`, the `m = s+1` case of the binomial conjecture.

-- !-- Lab Notes -- !--
* **Experiment.** `det(adjMat s)` for `s = 0..9` is `1, −1, −1, 1, 1, −1, −1, 1, 1, −1`,
  matching `(−1)^{⌊(s+1)/2⌋}` and the constant terms of the characteristic polynomials
  tabulated in `ComputationalEvidence.md` §2.
* **Analysis.** The recurrence is *not* a similarity: it changes the size of the matrix,
  and the sign `(−1)^{s+1}` is exactly the Laplace cofactor sign of the corner entry.  The
  period-four pattern is the parity of `s(s+1)/2`, i.e. the sign of the reversal
  permutation of `s+1` letters — consistent with `A_s = P_rev · L` for the lower
  unitriangular `L`.
* **Critique.** Unimodularity is what makes every `2×2` window of `Mⁿ` have determinant
  `±1`, which is the Catalan-type input required by Conjecture 4 (arctangent closed forms
  beyond `s = 1`); it is stated over `ℤ` so that no division is involved.
-/

namespace AdjSum

open Finset

/-- Powers of `-1` only depend on the exponent modulo `2`. -/
lemma neg_one_pow_eq_of_mod_two {a b : ℕ} (h : a % 2 = b % 2) :
    ((-1 : ℤ)) ^ a = ((-1 : ℤ)) ^ b := by
  rw [neg_one_pow_eq_pow_mod_two, neg_one_pow_eq_pow_mod_two (n := b), h]

/-- The parity bookkeeping behind the closed form of the determinant. -/
lemma mod_two_step (s : ℕ) : (s + 1 + (s + 1) / 2) % 2 = ((s + 2) / 2) % 2 := by
  rcases Nat.even_or_odd s with ⟨m, hm⟩ | ⟨m, hm⟩ <;> subst hm
  · have h1 : (m + m + 1) / 2 = m := by omega
    have h2 : (m + m + 2) / 2 = m + 1 := by omega
    rw [h1, h2]
    omega
  · have h1 : (2 * m + 1 + 1) / 2 = m + 1 := by omega
    have h2 : (2 * m + 1 + 2) / 2 = m + 1 := by omega
    rw [h1, h2]
    omega

/-- **Laplace recurrence.**  Expanding along the last row (which is the unit vector `e₀`)
and deleting the first column returns the transfer matrix with one unit less slack. -/
theorem det_adjMatZ_succ (s : ℕ) :
    (adjMatZ (s + 1)).det = (-1) ^ (s + 1) * (adjMatZ s).det := by
  rw [Matrix.det_succ_row (adjMatZ (s + 1)) (Fin.last (s + 1))]
  have hzero : ∀ j ∈ (Finset.univ : Finset (Fin (s + 2))), j ≠ 0 →
      (-1) ^ ((Fin.last (s + 1) : Fin (s + 2)) : ℕ) ^ 0 * (0 : ℤ) = 0 := by
    intro j _ _
    ring
  rw [Finset.sum_eq_single (0 : Fin (s + 2))]
  · have hentry : adjMatZ (s + 1) (Fin.last (s + 1)) 0 = 1 := by
      simp [adjMatZ]
    have hsub : (adjMatZ (s + 1)).submatrix (Fin.last (s + 1)).succAbove
        ((0 : Fin (s + 2)).succAbove) = adjMatZ s := by
      ext a b
      rw [Matrix.submatrix_apply, Fin.succAbove_last, Fin.zero_succAbove]
      simp only [adjMatZ, Fin.val_castSucc, Fin.val_succ]
      by_cases h : (a : ℕ) + (b : ℕ) ≤ s
      · rw [if_pos (by omega), if_pos h]
      · rw [if_neg (by omega), if_neg h]
    rw [hentry, hsub]
    simp
  · intro j _ hj
    have hval : (j : ℕ) ≠ 0 := by
      intro hc
      exact hj (Fin.ext (by simpa using hc))
    have hentry : adjMatZ (s + 1) (Fin.last (s + 1)) j = 0 := by
      simp only [adjMatZ, Fin.val_last]
      rw [if_neg (by omega)]
    rw [hentry]
    ring
  · intro h
    exact absurd (Finset.mem_univ _) h

/-- **Unimodularity in closed form.**  `det(adjMat s) = (−1)^{⌊(s+1)/2⌋}`. -/
theorem det_adjMatZ (s : ℕ) : (adjMatZ s).det = (-1) ^ ((s + 1) / 2) := by
  induction s with
  | zero =>
    rw [Matrix.det_fin_one]
    norm_num [adjMatZ]
  | succ k ih =>
    rw [det_adjMatZ_succ, ih, ← pow_add]
    exact neg_one_pow_eq_of_mod_two (mod_two_step k)

/-- The transfer matrix is invertible over `ℤ`. -/
theorem isUnit_det_adjMatZ (s : ℕ) : IsUnit ((adjMatZ s).det) := by
  rw [det_adjMatZ]
  rcases Nat.even_or_odd ((s + 1) / 2) with h | h
  · rw [h.neg_one_pow]
    exact isUnit_one
  · rw [h.neg_one_pow]
    exact (isUnit_one (M := ℤ)).neg

/-- **The constant term of the characteristic polynomial**, i.e. the `m = s+1` case of the
binomial staircase conjecture: it equals `(−1)^{⌊(s+2)/2⌋} · C(s+1, s+1)`. -/
theorem charpoly_coeff_zero_adjMatZ (s : ℕ) :
    (adjMatZ s).charpoly.coeff 0 = (-1) ^ ((s + 2) / 2) := by
  have hdet := Matrix.det_eq_sign_charpoly_coeff (adjMatZ s)
  rw [det_adjMatZ, Fintype.card_fin] at hdet
  have hunit : ((-1 : ℤ)) ^ (s + 1) * ((-1 : ℤ)) ^ (s + 1) = 1 := by
    rw [← pow_add, ← two_mul, pow_mul]
    norm_num
  have hval : (adjMatZ s).charpoly.coeff 0
      = ((-1 : ℤ)) ^ (s + 1) * ((-1 : ℤ)) ^ ((s + 1) / 2) := by
    calc (adjMatZ s).charpoly.coeff 0 = 1 * (adjMatZ s).charpoly.coeff 0 := (one_mul _).symm
      _ = ((-1 : ℤ)) ^ (s + 1) * (((-1 : ℤ)) ^ (s + 1) * (adjMatZ s).charpoly.coeff 0) := by
          rw [← mul_assoc, hunit, one_mul]
      _ = ((-1 : ℤ)) ^ (s + 1) * ((-1 : ℤ)) ^ ((s + 1) / 2) := by rw [← hdet]
  rw [hval, ← pow_add]
  exact neg_one_pow_eq_of_mod_two (mod_two_step s)

end AdjSum