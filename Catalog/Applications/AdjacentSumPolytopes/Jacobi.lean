import Applications.AdjacentSumPolytopes.ThreeState

/-!
# The Jacobi derivative identity in the three-state case

`Applications.AdjacentSumPolytopes.Recurrence` proved the Jacobi identity

`(∑ₙ tr(Mⁿ) Xⁿ) · p(X) = k·p(X) − X·p′(X)`,   `p(X) = det(I − XM)`,

for `k = 2`.  Here we prove the `k = 3` case for an *arbitrary* `3 × 3` matrix over a
commutative ring, and specialise it to the three-state adjacent-sum transfer matrix
`adjMat 2`.  The proof needs the two nontrivial Newton relations in size three:

* `trace_sq_three` : `tr(M²) = (tr M)² − 2·e₂(M)`;
* `pow_three_eq` : the Cayley–Hamilton identity `M³ = (tr M)·M² − e₂(M)·M + (det M)·I`,

where `e₂` is the sum of the principal `2 × 2` minors.  Both are proved entrywise, so no
`Nontrivial` hypothesis and no eigenvalue theory is needed.

As a corollary we obtain the explicit rational generating function of the cyclic
adjacent-sum counts in the three-state model,
`∑_d cycCount 2 d · X^d = (2 + 2X − 3X²)/(1 − 2X − X² + X³)`.

-- !-- Lab Notes -- !--
* **Hypothesis.** The `k = 2` numerator `2 − (tr M)X` is the shadow of the general
  Jacobi numerator `k·p − X·p′`; in size three it must be `3 − 2e₁X + e₂X²`.
* **Experiment.** For `M = adjMat 2` one has `e₁ = 2`, `e₂ = −1`, `e₃ = det M = −1`, so
  `p = 1 − 2X − X² + X³` and the predicted numerator is `3 − 4X − X²`.  Check against the
  trace sequence `t₀,…,t₄ = 3, 2, 6, 11, 26`:
  `t₀ = 3`; `t₁ − 2t₀ = 2 − 6 = −4`; `t₂ − 2t₁ − t₀ = 6 − 4 − 3 = −1`;
  `t₃ − 2t₂ − t₁ + t₀ = 11 − 12 − 2 + 3 = 0`; `t₄ − 2t₃ − t₂ + t₁ = 26 − 22 − 6 + 2 = 0`.
  Shifting by one gives the cyclic numerator `2 + 2X − 3X²`:
  `2`, `6 − 4 = 2`, `11 − 12 − 2 = −3`, `26 − 22 − 6 + 2 = 0`.
* **Analysis.** What makes the size-three case work without splitting fields is that
  only *two* Newton relations are needed: the quadratic one (a direct entry computation)
  and Cayley–Hamilton (also a direct entry computation).  All higher relations are the
  linear recurrence, i.e. the numerator has degree `< k` automatically.
* **Critique.** The identity is not a tautology: both nontrivial coefficients of the
  numerator are computed, and the `X²` coefficient `e₂` is precisely where the naive
  guess "numerator `= k − (tr M)X`" fails.
-/

namespace AdjSum

open Matrix Polynomial PowerSeries

/-- The second elementary symmetric function of the eigenvalues of a `3 × 3` matrix: the
sum of its principal `2 × 2` minors. -/
def sym2 {R : Type*} [CommRing R] (M : Matrix (Fin 3) (Fin 3) R) : R :=
  M 0 0 * M 1 1 - M 0 1 * M 1 0 + M 0 0 * M 2 2 - M 0 2 * M 2 0 + M 1 1 * M 2 2 - M 1 2 * M 2 1

/-- **Newton's second identity in size three.** -/
theorem trace_sq_three {R : Type*} [CommRing R] (M : Matrix (Fin 3) (Fin 3) R) :
    Matrix.trace (M ^ 2) = (Matrix.trace M) ^ 2 - 2 * sym2 M := by
  simp [pow_two, Matrix.trace, Matrix.diag, Matrix.mul_apply, Fin.sum_univ_three, sym2]
  ring

/-- **Cayley–Hamilton in size three**, proved entrywise. -/
theorem pow_three_eq {R : Type*} [CommRing R] (M : Matrix (Fin 3) (Fin 3) R) :
    M ^ 3 = Matrix.trace M • M ^ 2 - sym2 M • M + M.det • (1 : Matrix (Fin 3) (Fin 3) R) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [pow_succ, pow_zero, Matrix.mul_apply, Matrix.trace, Matrix.diag, Matrix.det_fin_three,
      Fin.sum_univ_three, sym2] <;> ring

/-- The order-three trace recurrence of a `3 × 3` matrix. -/
theorem trace_pow_rec_three {R : Type*} [CommRing R] (M : Matrix (Fin 3) (Fin 3) R) (n : ℕ) :
    Matrix.trace (M ^ (n + 3)) =
      Matrix.trace M * Matrix.trace (M ^ (n + 2))
        - sym2 M * Matrix.trace (M ^ (n + 1)) + M.det * Matrix.trace (M ^ n) := by
  have h : M ^ (n + 3) = Matrix.trace M • M ^ (n + 2) - sym2 M • M ^ (n + 1) + M.det • M ^ n := by
    have h3 : M ^ (n + 3) = M ^ n * M ^ 3 := by rw [← pow_add]
    rw [h3, pow_three_eq, Matrix.mul_add, Matrix.mul_sub, Matrix.mul_smul, Matrix.mul_smul,
      Matrix.mul_smul, Matrix.mul_one, ← pow_add, ← pow_succ]
  rw [h, Matrix.trace_add, Matrix.trace_sub, Matrix.trace_smul, Matrix.trace_smul,
    Matrix.trace_smul, smul_eq_mul, smul_eq_mul, smul_eq_mul]

/-- **Jacobi derivative identity, three-state case.**  With
`p(X) = det(I − XM) = 1 − e₁X + e₂X² − e₃X³` one has
`(∑ₙ tr(Mⁿ)Xⁿ)·p(X) = 3 − 2e₁X + e₂X² = 3·p(X) − X·p′(X)`. -/
theorem jacobi_three_state {R : Type*} [CommRing R] (M : Matrix (Fin 3) (Fin 3) R) :
    (PowerSeries.mk fun n => Matrix.trace (M ^ n)) *
        (1 - PowerSeries.C (Matrix.trace M) * PowerSeries.X
              + PowerSeries.C (sym2 M) * PowerSeries.X ^ 2
              - PowerSeries.C M.det * PowerSeries.X ^ 3)
      = PowerSeries.C 3 - PowerSeries.C (2 * Matrix.trace M) * PowerSeries.X
          + PowerSeries.C (sym2 M) * PowerSeries.X ^ 2 := by
  set A : PowerSeries R := PowerSeries.mk fun n => Matrix.trace (M ^ n) with hA
  have expand : A * (1 - PowerSeries.C (Matrix.trace M) * PowerSeries.X
        + PowerSeries.C (sym2 M) * PowerSeries.X ^ 2
        - PowerSeries.C M.det * PowerSeries.X ^ 3)
      = A - PowerSeries.C (Matrix.trace M) * (A * PowerSeries.X ^ 1)
          + PowerSeries.C (sym2 M) * (A * PowerSeries.X ^ 2)
          - PowerSeries.C M.det * (A * PowerSeries.X ^ 3) := by
    rw [pow_one]; ring
  rw [expand]
  ext n
  rw [map_sub, map_add, map_sub, PowerSeries.coeff_C_mul, PowerSeries.coeff_C_mul,
    PowerSeries.coeff_C_mul, PowerSeries.coeff_mul_X_pow', PowerSeries.coeff_mul_X_pow',
    PowerSeries.coeff_mul_X_pow', hA]
  match n with
  | 0 => simp [Matrix.trace_one]
  | 1 =>
      rw [if_pos (by omega), if_neg (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_C_mul, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      simp [Matrix.trace_one, pow_one]
      ring
  | 2 =>
      rw [if_pos (by omega), if_pos (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C_mul]
      rw [show (2 : ℕ) - 1 = 1 from rfl, show (2 : ℕ) - 2 = 0 from rfl, pow_one, pow_zero,
        trace_sq_three, Matrix.trace_one]
      simp only [PowerSeries.coeff_C, PowerSeries.coeff_X, PowerSeries.coeff_X_pow,
        Fintype.card_fin, Nat.cast_ofNat]
      norm_num
      ring
  | (n + 3) =>
      rw [if_pos (by omega), if_pos (by omega), if_pos (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C_mul]
      have h1 : n + 3 - 1 = n + 2 := by omega
      have h2 : n + 3 - 2 = n + 1 := by omega
      have h3 : n + 3 - 3 = n := by omega
      rw [h1, h2, h3, trace_pow_rec_three M n]
      simp only [PowerSeries.coeff_C, PowerSeries.coeff_X, PowerSeries.coeff_X_pow,
        show n + 3 ≠ 0 from by omega, show n + 3 ≠ 1 from by omega,
        show n + 3 ≠ 2 from by omega, if_false]
      ring

/-! ## The three-state instance -/

lemma trace_adjMatZ_two : Matrix.trace (adjMatZ 2) = 2 := by
  rw [Matrix.trace_fin_three]
  norm_num [adjMatZ]

lemma sym2_adjMatZ_two : sym2 (adjMatZ 2) = -1 := by
  simp [sym2, adjMatZ]

lemma det_adjMatZ_two : (adjMatZ 2).det = -1 := by
  simp [Matrix.det_fin_three, adjMatZ]

/-- **Jacobi identity for the three-state adjacent-sum matrix.**
`(∑ₙ tr(Mⁿ)Xⁿ)·(1 − 2X − X² + X³) = 3 − 4X − X²`. -/
theorem jacobi_adjMat_two :
    (PowerSeries.mk fun n => Matrix.trace ((adjMatZ 2) ^ n)) *
        (1 - PowerSeries.C 2 * PowerSeries.X - PowerSeries.X ^ 2 + PowerSeries.X ^ 3)
      = PowerSeries.C 3 - PowerSeries.C 4 * PowerSeries.X - PowerSeries.X ^ 2 := by
  have h := jacobi_three_state (adjMatZ 2)
  rw [trace_adjMatZ_two, sym2_adjMatZ_two, det_adjMatZ_two] at h
  have e1 : (PowerSeries.C (-1 : ℤ)) = -1 := by simp
  rw [e1] at h
  have e2 : ((2 : ℤ) * 2) = 4 := by norm_num
  rw [e2] at h
  linear_combination h

/-- The cyclic generating function of the three-state model is rational with numerator
`2 + 2X − 3X²` over the shared denominator `1 − 2X − X² + X³`. -/
theorem cycSeries_two_closed :
    cycSeries 2 * (1 - PowerSeries.C 2 * PowerSeries.X - PowerSeries.X ^ 2 + PowerSeries.X ^ 3)
      = PowerSeries.C 2 + PowerSeries.C 2 * PowerSeries.X
          - PowerSeries.C 3 * PowerSeries.X ^ 2 := by
  have expand : cycSeries 2 * (1 - PowerSeries.C 2 * PowerSeries.X - PowerSeries.X ^ 2
        + PowerSeries.X ^ 3)
      = cycSeries 2 - PowerSeries.C 2 * (cycSeries 2 * PowerSeries.X ^ 1)
          - (cycSeries 2 * PowerSeries.X ^ 2) + (cycSeries 2 * PowerSeries.X ^ 3) := by
    rw [pow_one]; ring
  rw [expand]
  ext n
  rw [map_add, map_sub, map_sub, PowerSeries.coeff_C_mul, PowerSeries.coeff_mul_X_pow',
    PowerSeries.coeff_mul_X_pow', PowerSeries.coeff_mul_X_pow', cycSeries]
  obtain ⟨h0, h1, h2⟩ := cycCount_two_initial
  match n with
  | 0 =>
      rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_C_mul, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      norm_num [h0]
  | 1 =>
      rw [if_pos (by omega), if_neg (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_C_mul, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      norm_num [h0, h1]
  | 2 =>
      rw [if_pos (by omega), if_pos (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_C_mul, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      rw [show (2 : ℕ) - 1 = 1 from rfl, show (2 : ℕ) - 2 = 0 from rfl, h0, h1, h2]
      norm_num
  | (n + 3) =>
      rw [if_pos (by omega), if_pos (by omega), if_pos (by omega)]
      simp only [PowerSeries.coeff_mk, map_add, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_C_mul, PowerSeries.coeff_X, PowerSeries.coeff_X_pow]
      have e1 : n + 3 - 1 = n + 2 := by omega
      have e2 : n + 3 - 2 = n + 1 := by omega
      have e3 : n + 3 - 3 = n := by omega
      rw [e1, e2, e3, cycCount_two_rec n]
      simp
      ring

/-- The open generating function of the three-state model has numerator `3 − X²` over the
*same* denominator: an explicit instance of the shared-denominator theorem. -/
theorem openSeries_two_closed :
    openSeries 2 * (1 - PowerSeries.C 2 * PowerSeries.X - PowerSeries.X ^ 2 + PowerSeries.X ^ 3)
      = PowerSeries.C 3 - PowerSeries.X ^ 2 := by
  have expand : openSeries 2 * (1 - PowerSeries.C 2 * PowerSeries.X - PowerSeries.X ^ 2
        + PowerSeries.X ^ 3)
      = openSeries 2 - PowerSeries.C 2 * (openSeries 2 * PowerSeries.X ^ 1)
          - (openSeries 2 * PowerSeries.X ^ 2) + (openSeries 2 * PowerSeries.X ^ 3) := by
    rw [pow_one]; ring
  rw [expand]
  ext n
  rw [map_add, map_sub, map_sub, PowerSeries.coeff_C_mul, PowerSeries.coeff_mul_X_pow',
    PowerSeries.coeff_mul_X_pow', PowerSeries.coeff_mul_X_pow', openSeries]
  obtain ⟨h0, h1, h2⟩ := openCount_two_initial
  match n with
  | 0 =>
      rw [if_neg (by omega), if_neg (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_X_pow]
      norm_num [h0]
  | 1 =>
      rw [if_pos (by omega), if_neg (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_X_pow]
      norm_num [h0, h1]
  | 2 =>
      rw [if_pos (by omega), if_pos (by omega), if_neg (by omega)]
      simp only [PowerSeries.coeff_mk, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_X_pow]
      rw [show (2 : ℕ) - 1 = 1 from rfl, show (2 : ℕ) - 2 = 0 from rfl, h0, h1, h2]
      norm_num
  | (n + 3) =>
      rw [if_pos (by omega), if_pos (by omega), if_pos (by omega)]
      simp only [PowerSeries.coeff_mk, map_sub, PowerSeries.coeff_C,
        PowerSeries.coeff_X_pow]
      have e1 : n + 3 - 1 = n + 2 := by omega
      have e2 : n + 3 - 2 = n + 1 := by omega
      have e3 : n + 3 - 3 = n := by omega
      rw [e1, e2, e3, openCount_two_rec n]
      simp
      ring

end AdjSum