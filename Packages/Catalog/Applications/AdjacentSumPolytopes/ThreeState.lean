import Applications.AdjacentSumPolytopes.Recurrence

/-!
# The three-state model: an explicit shared denominator

For `s = 2` the transfer matrix is the `3 × 3` matrix

`adjMat 2 = !![1,1,1; 1,1,0; 1,0,0]`,

whose characteristic polynomial is `X³ − 2X² − X + 1`.  We compute it and read off the
explicit order-three recurrence

`c(m+3) = 2·c(m+2) + c(m+1) − c(m)`,

which — by the general theory of `Applications.AdjacentSumPolytopes.Recurrence` — is
obeyed by *both* the open and the cyclic counting sequences.  This is the smallest case
in which the shared denominator is a genuine cubic (the two-state case being the
Fibonacci quadratic `1 − X − X²`).

-- !-- Lab Notes -- !--
* **Hypothesis.** `charpoly (adjMat 2) = X³ − 2X² − X + 1`, hence the shared denominator
  `1 − 2X − X² + X³` for both parity classes.
* **Experiment.** Open counts `3, 6, 14, 31, 70, 157, 353, 793` and cyclic counts
  `2, 6, 11, 26, 57, 129, 289, 650`.  Check: `31 = 2·14 + 6 − 3`, `70 = 2·31 + 14 − 6`,
  `26 = 2·11 + 6 − 2`, `57 = 2·26 + 11 − 6` — both sequences obey the same recurrence,
  with different initial data (hence different numerators).
* **Analysis.** The two numerators are `3 + 0·X − X²` (open) and `2 + 2X − X²` (cyclic)
  as one sees from the first three terms; the denominators agree exactly, as proved.
* **Critique.** The characteristic polynomial is computed from the definition through
  `Matrix.det_fin_three`, not asserted; the recurrence is then a specialisation of the
  general Cayley–Hamilton theorem, and the initial values are verified by decision
  procedure.
-/

namespace AdjSum

open Matrix Polynomial

/-- The characteristic polynomial of the three-state adjacent-sum transfer matrix. -/
theorem charpoly_adjMatZ_two : (adjMatZ 2).charpoly = X ^ 3 - 2 * X ^ 2 - X + 1 := by
  rw [Matrix.charpoly, Matrix.det_fin_three]
  simp [charmatrix, adjMatZ, Fin.ext_iff]
  ring

theorem coeff_charpoly_two_zero : (adjMatZ 2).charpoly.coeff 0 = 1 := by
  rw [charpoly_adjMatZ_two]; simp

theorem coeff_charpoly_two_one : (adjMatZ 2).charpoly.coeff 1 = -1 := by
  rw [charpoly_adjMatZ_two]; simp [coeff_one, coeff_X]

theorem coeff_charpoly_two_two : (adjMatZ 2).charpoly.coeff 2 = -2 := by
  rw [charpoly_adjMatZ_two]; simp [coeff_one, coeff_X]

theorem coeff_charpoly_two_three : (adjMatZ 2).charpoly.coeff 3 = 1 := by
  rw [charpoly_adjMatZ_two]; simp [coeff_one, coeff_X]

/-- **Explicit cyclic recurrence for `s = 2`.** -/
theorem cycCount_two_rec (m : ℕ) :
    (cycCount 2 (m + 3) : ℤ)
      = 2 * cycCount 2 (m + 2) + cycCount 2 (m + 1) - cycCount 2 m := by
  have h := cycCount_recurrence 2 m
  rw [show (2 : ℕ) + 2 = 4 from rfl, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one] at h
  rw [coeff_charpoly_two_zero, coeff_charpoly_two_one, coeff_charpoly_two_two,
    coeff_charpoly_two_three] at h
  simp only [Nat.add_zero] at h
  linarith

/-- **Explicit open recurrence for `s = 2`** — the same recurrence, different initial
data. -/
theorem openCount_two_rec (m : ℕ) :
    (openCount 2 (m + 3) : ℤ)
      = 2 * openCount 2 (m + 2) + openCount 2 (m + 1) - openCount 2 m := by
  have h := openCount_recurrence 2 m
  rw [show (2 : ℕ) + 2 = 4 from rfl, Finset.sum_range_succ, Finset.sum_range_succ,
    Finset.sum_range_succ, Finset.sum_range_one] at h
  rw [coeff_charpoly_two_zero, coeff_charpoly_two_one, coeff_charpoly_two_two,
    coeff_charpoly_two_three] at h
  simp only [Nat.add_zero] at h
  linarith

/-- Initial data of the two sequences, verified by decision procedure. -/
theorem cycCount_two_initial :
    cycCount 2 0 = 2 ∧ cycCount 2 1 = 6 ∧ cycCount 2 2 = 11 := by
  refine ⟨?_, ?_, ?_⟩ <;> · rw [cycCount]; decide

theorem openCount_two_initial :
    openCount 2 0 = 3 ∧ openCount 2 1 = 6 ∧ openCount 2 2 = 14 := by
  refine ⟨?_, ?_, ?_⟩ <;> · rw [openCount]; decide

/-- Combining the recurrence with the initial data: the fourth cyclic count is `26`. -/
theorem cycCount_two_three : cycCount 2 3 = 26 := by
  have h := cycCount_two_rec 0
  obtain ⟨h0, h1, h2⟩ := cycCount_two_initial
  rw [h0, h1, h2] at h
  norm_num at h
  exact_mod_cast h

end AdjSum