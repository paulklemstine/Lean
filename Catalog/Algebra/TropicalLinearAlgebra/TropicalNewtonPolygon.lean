/-
# The tropical Newton polygon: the spectral radius is the largest tropical root

`TropicalCharPoly.lean` shows that a tropical eigenvalue is *a* corner of the tropical
characteristic polynomial `p_A(x) = max_k (c_k + (n−k)·x)`.  Conjecture **C2** of
`FUTURE_DIRECTIONS.md` asks for the whole corner locus.  This file settles the extremal
part of that conjecture and the coefficient formula behind it:

* `maxCycleMean_submatrix_le` — the max-plus spectral radius is monotone under principal
  submatrices (every cycle of a principal submatrix is a cycle of the whole matrix);
* `isGreatest_charCoeff_div` — **coefficient formula for the spectral radius**:
  `λ(A) = max_{1 ≤ k ≤ n} c_k / k`, the largest slope of the Newton polygon of `p_A`;
* `isGreatest_tropicalRoot` — **`λ(A)` is exactly the largest tropical root of the
  characteristic polynomial**: it is a corner (by `eigen_isTropicalRoot`), and beyond it
  the degree-`0` monomial `n·x` strictly dominates every other monomial, so no larger
  corner exists.

Together these say that the top of the Newton polygon of `p_A` is the tropical spectrum,
which is the extremal case of the principal-submatrix description conjectured in C2.
-/
import Mathlib
import Algebra.TropicalLinearAlgebra.TropicalCharPoly
import Algebra.TropicalLinearAlgebra.TropicalPerronFrobenius

namespace TropicalLA

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]

omit [DecidableEq ι] in
/-- **Monotonicity of the spectral radius under (principal) submatrices.**  A closed walk of
the submatrix indexed by `f` is a closed walk of `A` with the same weight, hence its mean is
dominated by the maximum cycle mean of `A`.  Taking `f` to be the inclusion of a nonempty
subset gives monotonicity under principal submatrices. -/
theorem maxCycleMean_submatrix_le (A : Matrix ι ι ℝ) {J : Type*} [Fintype J] [Nonempty J]
    (f : J → ι) : maxCycleMean (A.submatrix f f) ≤ maxCycleMean A := by
  set B := A.submatrix f f with hB
  obtain ⟨m, c, hm, _, hc, hcw⟩ := exists_critical_cycle_maxCycleMean (A := B)
  have hpath : pathWeight A (fun t => f (c t)) m = pathWeight B c m := by
    simp [pathWeight, hB]
  have hclosed : (fun t => f (c t)) m = (fun t => f (c t)) 0 := by
    simp only
    rw [hc]
  have hle := cycle_le_maxCycleMean (A := A) m (fun t => f (c t)) hclosed
  rw [hpath, hcw] at hle
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  nlinarith

/-- **Coefficient formula for the tropical spectral radius.**  The maximum cycle mean is the
largest of the normalised characteristic coefficients `c_k / k` — the largest slope of the
Newton polygon of the tropical characteristic polynomial. -/
theorem isGreatest_charCoeff_div (A : Matrix ι ι ℝ) :
    IsGreatest {μ : ℝ | ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card ι ∧ μ = charCoeff A k / k}
      (maxCycleMean A) := by
  obtain ⟨v, hv⟩ := exists_tropEigen A
  constructor
  · obtain ⟨k, hk0, hkn, hkeq⟩ := exists_charCoeff_eq_of_eigen hv
    refine ⟨k, hk0, hkn, ?_⟩
    have hk : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
    rw [hkeq]
    field_simp
  · rintro μ ⟨k, hk0, hkn, rfl⟩
    have hk : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk0
    have hle := charCoeff_le_of_eigen hv hkn
    rw [div_le_iff₀ hk]
    linarith [hle]

/-- **The tropical spectral radius is the largest tropical root of the characteristic
polynomial.**  It is a root (a corner of `p_A`) by `eigen_isTropicalRoot`, and for
`x > λ(A)` the degree-`0` monomial `n·x` strictly beats every other monomial, so the
maximum defining `p_A(x)` is attained only once and `x` is not a root. -/
theorem isGreatest_tropicalRoot (A : Matrix ι ι ℝ) :
    IsGreatest {x : ℝ | IsTropicalRoot A x} (maxCycleMean A) := by
  obtain ⟨v, hv⟩ := exists_tropEigen A
  refine ⟨(eigen_isTropicalRoot hv).1, ?_⟩
  rintro x hx
  by_contra hlt
  push_neg at hlt
  obtain ⟨k₁, k₂, hk₁n, hk₂n, hne, hk₁, hk₂⟩ := hx
  -- one of the two attaining degrees is nonzero
  obtain ⟨k, hk0, hkn, hkval⟩ :
      ∃ k : ℕ, 0 < k ∧ k ≤ Fintype.card ι ∧
        charCoeff A k + ((Fintype.card ι : ℝ) - k) * x = charPolyVal A x := by
    rcases Nat.eq_zero_or_pos k₁ with rfl | h₁
    · exact ⟨k₂, by omega, hk₂n, hk₂⟩
    · exact ⟨k₁, h₁, hk₁n, hk₁⟩
  -- the degree-zero monomial is a lower bound for `p_A(x)`
  have hzero_le : (Fintype.card ι : ℝ) * x ≤ charPolyVal A x := by
    have hmem : (0 : ℕ) ∈ Finset.range (Fintype.card ι + 1) := by simp
    have := Finset.le_sup' (fun j : ℕ => charCoeff A j + ((Fintype.card ι : ℝ) - j) * x) hmem
    simpa [charPolyVal] using this
  -- but the degree-`k` monomial is strictly smaller than `n·x`
  have hck : charCoeff A k ≤ (k : ℝ) * maxCycleMean A :=
    charCoeff_le_of_eigen hv hkn
  have hkpos : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk0
  have hstrict : charCoeff A k + ((Fintype.card ι : ℝ) - k) * x < (Fintype.card ι : ℝ) * x := by
    have : (k : ℝ) * maxCycleMean A < (k : ℝ) * x := by
      exact mul_lt_mul_of_pos_left hlt hkpos
    nlinarith
  rw [hkval] at hstrict
  linarith

end TropicalLA