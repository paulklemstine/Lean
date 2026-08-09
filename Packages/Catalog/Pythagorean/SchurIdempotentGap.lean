import Pythagorean.SchurIdempotentGammaTwo

/-!
# A sharp gap for the factorization norm of boolean matrices

Building on `Pythagorean.SchurIdempotentGammaTwo`, this file proves a *gap theorem* for the
factorization norm of boolean matrices (equivalently, for the norm of idempotent Schur
multipliers):

* `gammaTwoLE_tri2_iff` : the `2 × 2` triangular truth matrix `[[1,1],[1,0]]` has
  `‖A‖_{γ₂} = 2√3/3 = 2/√3` **exactly**.  The upper bound is an explicit two-dimensional
  factorization; the lower bound is an elementary sum-of-squares certificate coming from the
  dual semidefinite program.
* `gammaTwo_gap` : if `A` is boolean and `‖A‖_{γ₂} ≤ c` with `c < 2√3/3`, then `A` is a
  blow-up of a partial identity matrix, hence `‖A‖_{γ₂} ≤ 1`.

Consequently **no boolean matrix has factorization norm strictly between `1` and `2√3/3`**:
the spectrum of `γ₂`-norms of idempotent Schur multipliers has a gap immediately above the
contractive case, and the gap is attained by a `2 × 2` matrix.
-/

namespace SchurIdempotent

open Finset

variable {m n : ℕ}

/-! ## Submatrices -/

/-- The factorization norm does not increase when passing to a submatrix. -/
theorem GammaTwoLE.submatrix {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE A c)
    {m' n' : ℕ} (σ : Fin m' → Fin m) (τ : Fin n' → Fin n) :
    GammaTwoLE (fun i j => A (σ i) (τ j)) c := by
  obtain ⟨F⟩ := h
  exact ⟨{ dim := F.dim, x := fun i => F.x (σ i), y := fun j => F.y (τ j),
           x_bound := fun i => F.x_bound (σ i), y_bound := fun j => F.y_bound (τ j),
           factor := fun i j => F.factor (σ i) (τ j) }⟩

/-! ## The sum-of-squares lower bound -/

/-- **Sum-of-squares certificate.**  If a matrix with `‖A‖_{γ₂} ≤ c` contains the pattern
`[[1,1],[1,0]]` as a (not necessarily contiguous) `2 × 2` submatrix, then `c ≥ 2√3/3`.

The certificate is `0 ≤ ‖√3 b - 2p + q‖² + 2‖-√3 a + p + q‖²`, where `a, b` are the
factorization vectors of the two rows and `p, q` those of the two columns; expanding gives
`0 ≤ 6‖a‖² + 3‖b‖² + 6‖p‖² + 3‖q‖² - 12√3 ≤ 18c - 12√3`. -/
theorem gammaTwo_ge_of_triPattern {A : Fin m → Fin n → ℝ} {c : ℝ} (h : GammaTwoLE A c)
    {i i' : Fin m} {j j' : Fin n}
    (hij : A i j = 1) (hij' : A i j' = 1) (hi'j : A i' j = 1) (hi'j' : A i' j' = 0) :
    2 * Real.sqrt 3 / 3 ≤ c := by
  obtain ⟨F⟩ := h
  set s3 := Real.sqrt 3 with hs3def
  have hs3 : s3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  set a : Fin F.dim → ℝ := F.x i with ha
  set b : Fin F.dim → ℝ := F.x i' with hb
  set p : Fin F.dim → ℝ := F.y j with hp
  set q : Fin F.dim → ℝ := F.y j' with hq
  have hap : ∑ t, a t * p t = 1 := by rw [ha, hp, F.factor i j, hij]
  have haq : ∑ t, a t * q t = 1 := by rw [ha, hq, F.factor i j', hij']
  have hbp : ∑ t, b t * p t = 1 := by rw [hb, hp, F.factor i' j, hi'j]
  have hbq : ∑ t, b t * q t = 0 := by rw [hb, hq, F.factor i' j', hi'j']
  have hexp : ∀ t, (s3 * b t - 2 * p t + q t) ^ 2 + 2 * (-(s3) * a t + p t + q t) ^ 2
      = 6 * (a t) ^ 2 + 3 * (b t) ^ 2 + 6 * (p t) ^ 2 + 3 * (q t) ^ 2
        - 4 * s3 * (b t * p t) + 2 * s3 * (b t * q t)
        - 4 * s3 * (a t * p t) - 4 * s3 * (a t * q t) := by
    intro t
    linear_combination ((b t) ^ 2 + 2 * (a t) ^ 2) * hs3
  have hnn : (0:ℝ) ≤ ∑ t, ((s3 * b t - 2 * p t + q t) ^ 2 + 2 * (-(s3) * a t + p t + q t) ^ 2) :=
    Finset.sum_nonneg fun t _ => by positivity
  rw [Finset.sum_congr rfl fun t _ => hexp t] at hnn
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum] at hnn
  rw [hap, haq, hbp, hbq] at hnn
  have hA1 : ∑ t, (a t) ^ 2 ≤ c := F.x_bound i
  have hA2 : ∑ t, (b t) ^ 2 ≤ c := F.x_bound i'
  have hA3 : ∑ t, (p t) ^ 2 ≤ c := F.y_bound j
  have hA4 : ∑ t, (q t) ^ 2 ≤ c := F.y_bound j'
  linarith

/-! ## The exact factorization norm of the triangular truth matrix -/

theorem tri2_entries : tri2 0 0 = 1 ∧ tri2 0 1 = 1 ∧ tri2 1 0 = 1 ∧ tri2 1 1 = 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> simp [tri2]

/-- The explicit optimal two-dimensional factorization of the triangular truth matrix:
four vectors of equal length `√(2√3/3)` at consecutive angles of `30°`. -/
theorem tri2_gammaTwoLE_sharp : GammaTwoLE tri2 (2 * Real.sqrt 3 / 3) := by
  set s3 := Real.sqrt 3 with hs3def
  have hs3 : s3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
  have hs3pos : 0 < s3 := Real.sqrt_pos.2 (by norm_num)
  set c : ℝ := 2 * s3 / 3 with hc
  have hcpos : 0 < c := by rw [hc]; positivity
  set r : ℝ := Real.sqrt c with hr
  have hr2 : r ^ 2 = c := Real.sq_sqrt hcpos.le
  refine ⟨{ dim := 2,
            x := ![![r, 0], ![r / 2, r * s3 / 2]],
            y := ![![r * s3 / 2, r / 2], ![r * s3 / 2, -(r / 2)]],
            x_bound := ?_, y_bound := ?_, factor := ?_ }⟩
  · intro i
    fin_cases i <;> rw [Fin.sum_univ_two] <;> simp <;> nlinarith [hr2, hs3]
  · intro j
    fin_cases j <;> rw [Fin.sum_univ_two] <;> simp <;> nlinarith [hr2, hs3]
  · intro i j
    fin_cases i <;> fin_cases j <;> rw [Fin.sum_univ_two] <;> simp [tri2] <;>
      nlinarith [hr2, hs3, hcpos]

/-- **The factorization norm of `[[1,1],[1,0]]` is exactly `2√3/3`.** -/
theorem gammaTwoLE_tri2_iff (c : ℝ) : GammaTwoLE tri2 c ↔ 2 * Real.sqrt 3 / 3 ≤ c := by
  constructor
  · intro h
    obtain ⟨e00, e01, e10, e11⟩ := tri2_entries
    exact gammaTwo_ge_of_triPattern h (i := 0) (i' := 1) (j := 0) (j' := 1) e00 e01 e10 e11
  · intro h
    exact tri2_gammaTwoLE_sharp.mono h

/-! ## The gap theorem -/

/-- A boolean matrix that fails to be row rigid contains the pattern `[[1,1],[1,0]]` as a
`2 × 2` submatrix. -/
theorem exists_triPattern_of_not_rowRigid {A : Fin m → Fin n → ℝ} (hA : IsBoolean A)
    (hR : ¬ RowRigid A) :
    ∃ (i i' : Fin m) (j j' : Fin n),
      A i j = 1 ∧ A i j' = 1 ∧ A i' j = 1 ∧ A i' j' = 0 := by
  unfold RowRigid at hR
  push_neg at hR
  obtain ⟨i, i', j, hij, hi'j, j', hne⟩ := hR
  rcases hA i j' with h0 | h1
  · have h1' : A i' j' = 1 := by
      rcases hA i' j' with hz | ho
      · exact absurd (h0.trans hz.symm) hne
      · exact ho
    exact ⟨i', i, j, j', hi'j, h1', hij, h0⟩
  · have h0' : A i' j' = 0 := by
      rcases hA i' j' with hz | ho
      · exact hz
      · exact absurd (h1.trans ho.symm) hne
    exact ⟨i, i', j, j', hij, h1, hi'j, h0'⟩

/-- **Gap theorem.**  A boolean matrix whose factorization norm is smaller than `2√3/3` is a
blow-up of a partial identity matrix (so its norm is at most `1`).  Hence no boolean matrix
has factorization norm strictly between `1` and `2√3/3`. -/
theorem gammaTwo_gap {A : Fin m → Fin n → ℝ} {c : ℝ} (hA : IsBoolean A) (h : GammaTwoLE A c)
    (hc : c < 2 * Real.sqrt 3 / 3) : IsBlowUp A := by
  refine IsBlowUp.of_rowRigid hA ?_
  by_contra hR
  obtain ⟨i, i', j, j', h1, h2, h3, h4⟩ := exists_triPattern_of_not_rowRigid hA hR
  have := gammaTwo_ge_of_triPattern h h1 h2 h3 h4
  linarith

/-- Dichotomy form of the gap theorem. -/
theorem gammaTwo_dichotomy {A : Fin m → Fin n → ℝ} {c : ℝ} (hA : IsBoolean A)
    (h : GammaTwoLE A c) : GammaTwoLE A 1 ∨ 2 * Real.sqrt 3 / 3 ≤ c := by
  by_cases hc : c < 2 * Real.sqrt 3 / 3
  · exact Or.inl (gammaTwo_gap hA h hc).gammaTwoLE_one
  · exact Or.inr (not_lt.1 hc)

/-- The gap is sharp: the value `2√3/3` is attained by a boolean matrix which is not a
blow-up. -/
theorem gap_is_sharp :
    ¬ IsBlowUp tri2 ∧ GammaTwoLE tri2 (2 * Real.sqrt 3 / 3) :=
  ⟨tri2_not_isBlowUp, tri2_gammaTwoLE_sharp⟩

/-! ## The `3 × 3` staircase -/

/-- The `3 × 3` triangular truth matrix `[[1,1,1],[1,1,0],[1,0,0]]`. -/
def tri3 : Fin 3 → Fin 3 → ℝ := ![![1, 1, 1], ![1, 1, 0], ![1, 0, 0]]

theorem tri3_isBoolean : IsBoolean tri3 := by
  intro i j
  fin_cases i <;> fin_cases j <;> simp [tri3]

/-- The `3 × 3` staircase is not a blow-up of an identity matrix. -/
theorem tri3_not_isBlowUp : ¬ IsBlowUp tri3 := by
  intro h
  have h1 : tri3 1 0 = 1 := by simp [tri3]
  have h2 : tri3 2 0 = 1 := by simp [tri3]
  have := h.rowRigid 1 2 0 h1 h2 1
  simp [tri3] at this

/-- Two-sided bounds for the `3 × 3` staircase: `2√3/3 ≤ ‖T₃‖_{γ₂} ≤ √3`. -/
theorem tri3_bounds :
    GammaTwoLE tri3 (Real.sqrt 3) ∧ ∀ c : ℝ, GammaTwoLE tri3 c → 2 * Real.sqrt 3 / 3 ≤ c := by
  constructor
  · have := gammaTwoLE_sqrt_of_boolean tri3_isBoolean
    simpa using this
  · intro c h
    refine gammaTwo_ge_of_triPattern h (i := 1) (i' := 2) (j := 0) (j' := 1) ?_ ?_ ?_ ?_ <;>
      simp [tri3]


end SchurIdempotent