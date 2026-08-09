import Mathlib

/-!
# Exponential surjectivity onto unitaries and the scalar/special-unitary split

This file is the second instalment of the *quantum EML scalar logarithm* thread
(see `Catalog/NumberTheory/EMLQuantumScalarLog.lean` for the original
unit-circle theorem and `Catalog/NumberTheory/EMLQuantumScalarLogSharp.lean` for
the sharpened analytic statements).  The catalog files are compiled
independently, so the scalar lemma `scalar_smul_one_mem_unitary` is restated
here; everything else is new.

We settle the two structural "future directions" that were left open, namely
surjectivity of the exponential from selfadjoint elements onto unitaries
(direction 4) and the determinant/trace bookkeeping needed for `SU(2)`
(direction 5).

## Main results

* `exists_circle_point_notMem` : a finite subset of `ℂ` cannot contain the whole
  unit circle; explicitly, some `-exp (θ i)` avoids it.  (Cardinality meets
  the topology of the circle.)
* `exists_isSelfAdjoint_exp_I_smul_eq` : **exponential surjectivity.**  In any
  unital C⋆-algebra, every unitary with *finite spectrum* is `exp (i x)` for a
  selfadjoint `x`.  The point of the proof is the rotation trick: Mathlib's
  `expUnitary_argSelfAdjoint` needs `-1` to be outside the spectrum, and a
  finite spectrum can always be rotated off `-1` by a scalar `exp (-iθ)`, whose
  logarithm is then absorbed back into `θ • 1 + x`.
* `Matrix.exists_isHermitian_exp_I_smul_eq` : the matrix corollary — every
  unitary matrix over `ℂ` is `exp (i H)` for a Hermitian `H`.  This is the
  missing step towards `U(2)` coverage.
* `exists_scalar_smul_specialUnitary` : **determinant tracking.**  Every unitary
  matrix factors as a unimodular scalar times a matrix of determinant one.
* `scalarLog_smul_one_det_ne_one` : an *obstruction*: the scalar logarithmic
  factor `log (1 + t i) • 1` is never special unitary in `2 × 2` matrices for
  `t ≠ 0`, because its determinant `log (1 + t i) ^ 2` cannot equal `1`.  Hence
  the `SU(2)` part of the program genuinely requires the non-scalar factor
  produced by `exists_scalar_smul_specialUnitary`.
-/

noncomputable section

open Complex Real NormedSpace Pointwise

/-! ### A unimodular scalar is unitary -/

/-- If `‖z‖ = 1` then `z • 1` is unitary in any complex star algebra. -/
theorem scalar_smul_one_mem_unitary {A : Type*} [Ring A] [StarRing A] [Algebra ℂ A]
    [StarModule ℂ A] {z : ℂ} (hz : ‖z‖ = 1) : z • (1 : A) ∈ unitary A := by
  have hzz : star z * z = 1 := by rw [Complex.star_def, Complex.conj_mul', hz]; norm_num
  have hzz' : z * star z = 1 := by rw [Complex.star_def, Complex.mul_conj', hz]; norm_num
  constructor
  · rw [star_smul, star_one, smul_mul_smul_comm, one_mul, hzz, one_smul]
  · rw [star_smul, star_one, smul_mul_smul_comm, one_mul, hzz', one_smul]

/-! ### A finite set misses a point of the unit circle -/

/-- A finite subset of `ℂ` cannot swallow the whole unit circle: there is a real
angle `θ` with `-exp (θ i) ∉ S`.  The proof compares the cardinality of `S`
with the injective image of the interval `[0, 2π)`. -/
theorem exists_circle_point_notMem {S : Set ℂ} (hS : S.Finite) :
    ∃ θ : ℝ, -Complex.exp ((θ : ℂ) * I) ∉ S := by
  by_contra hcon
  push_neg at hcon
  set f : ℝ → ℂ := fun θ => -Complex.exp ((θ : ℂ) * I) with hf
  have hinj : Set.InjOn f (Set.Ico 0 (2 * π)) := by
    intro a ha b hb hab
    simp only [hf, neg_inj] at hab
    obtain ⟨n, hn⟩ := Complex.exp_eq_exp_iff_exists_int.mp hab
    have hre : a = b + n * (2 * π) := by
      have := congrArg Complex.im hn; simpa using this
    have hpi : 0 < π := Real.pi_pos
    rcases ha with ⟨ha1, ha2⟩
    rcases hb with ⟨hb1, hb2⟩
    have hlt : (n : ℝ) < 1 := by nlinarith
    have hgt : (-1 : ℝ) < n := by nlinarith
    have hlt' : n < 1 := by exact_mod_cast hlt
    have hgt' : (-1 : ℤ) < n := by exact_mod_cast hgt
    have hn0 : n = 0 := by omega
    rw [hn0] at hre
    simpa using hre
  have hinf : (Set.Ico (0 : ℝ) (2 * π)).Infinite := Set.Ico_infinite (by positivity)
  have himg : (f '' Set.Ico 0 (2 * π)).Infinite := hinf.image hinj
  refine himg (hS.subset ?_)
  rintro _ ⟨θ, -, rfl⟩
  exact hcon θ

/-! ### Exponential surjectivity onto unitaries with finite spectrum -/

variable {A : Type*} [CStarAlgebra A]

/-- **Exponential surjectivity.**  In a unital C⋆-algebra every unitary whose
spectrum is finite (e.g. every unitary matrix) is the exponential `exp (i x)`
of a selfadjoint element `x`. -/
theorem exists_isSelfAdjoint_exp_I_smul_eq {u : A} (hu : u ∈ unitary A)
    (hfin : (spectrum ℂ u).Finite) :
    ∃ x : A, IsSelfAdjoint x ∧ NormedSpace.exp (I • x) = u := by
  letI : NormedAlgebra ℚ A := NormedAlgebra.restrictScalars ℚ ℂ A
  rcases subsingleton_or_nontrivial A with hA | hA
  · exact ⟨0, IsSelfAdjoint.zero A, Subsingleton.elim _ _⟩
  obtain ⟨θ, hθ⟩ := exists_circle_point_notMem hfin
  set c : ℂ := Complex.exp (-(θ : ℂ) * I) with hcdef
  have hcinv : c * Complex.exp ((θ : ℂ) * I) = 1 := by
    rw [hcdef, ← Complex.exp_add]; ring_nf; simp
  have hcinv' : Complex.exp (I * (θ : ℂ)) * c = 1 := by
    rw [hcdef, ← Complex.exp_add]; ring_nf; simp
  have hc : ‖c‖ = 1 := by rw [hcdef, Complex.norm_exp]; simp
  have hcu : c • u ∈ unitary A := by
    have h : c • u = (c • (1 : A)) * u := by rw [smul_mul_assoc, one_mul]
    rw [h]; exact mul_mem (scalar_smul_one_mem_unitary hc) hu
  have hspec : (-1 : ℂ) ∉ spectrum ℂ (c • u) := by
    rw [spectrum.smul_eq_smul c u (spectrum.nonempty u)]
    rintro ⟨z, hz, hzz⟩
    simp only [smul_eq_mul] at hzz
    have hzval : z = -Complex.exp ((θ : ℂ) * I) := by
      calc z = z * (c * Complex.exp ((θ : ℂ) * I)) := by rw [hcinv, mul_one]
        _ = (c * z) * Complex.exp ((θ : ℂ) * I) := by ring
        _ = -Complex.exp ((θ : ℂ) * I) := by rw [hzz]; ring
    exact hθ (hzval ▸ hz)
  have hnorm : ‖(c • u) - 1‖ < 2 := (Unitary.norm_sub_one_lt_two_iff hcu).mpr hspec
  set v : unitary A := ⟨c • u, hcu⟩ with hvdef
  have hv : selfAdjoint.expUnitary (Unitary.argSelfAdjoint v) = v :=
    expUnitary_argSelfAdjoint (by simpa [hvdef] using hnorm)
  set x0 : A := (Unitary.argSelfAdjoint v : A) with hx0def
  have hx0 : IsSelfAdjoint x0 := (Unitary.argSelfAdjoint v).2
  have hexp0 : NormedSpace.exp (I • x0) = c • u := by
    have := congrArg (fun w : unitary A => (w : A)) hv
    simpa [selfAdjoint.expUnitary_coe, hvdef] using this
  refine ⟨(θ : ℂ) • (1 : A) + x0, ?_, ?_⟩
  · have h1 : IsSelfAdjoint ((θ : ℂ) • (1 : A)) := by
      rw [IsSelfAdjoint, star_smul, star_one, Complex.star_def, Complex.conj_ofReal]
    exact h1.add hx0
  · have hsplit : I • ((θ : ℂ) • (1 : A) + x0) = (I * (θ : ℂ)) • (1 : A) + I • x0 := by
      rw [smul_add, smul_smul]
    have hcomm : Commute ((I * (θ : ℂ)) • (1 : A)) (I • x0) := by
      rw [← Algebra.algebraMap_eq_smul_one]
      exact Algebra.commutes _ _
    rw [hsplit, NormedSpace.exp_add_of_commute hcomm, hexp0]
    have hE : NormedSpace.exp ((I * (θ : ℂ)) • (1 : A)) = (Complex.exp (I * (θ : ℂ))) • (1 : A) := by
      rw [← Algebra.algebraMap_eq_smul_one, ← NormedSpace.algebraMap_exp_comm,
        Algebra.algebraMap_eq_smul_one, Complex.exp_eq_exp_ℂ]
    rw [hE, smul_mul_assoc, one_mul, smul_smul, hcinv', one_smul]

/-! ### The matrix corollary: every unitary matrix is `exp (i H)` -/

section Matrices

open scoped Matrix.Norms.L2Operator

/-- The C⋆-structure on complex square matrices coming from the `L²` operator
norm.  It is only used to transport the C⋆-algebra results above. -/
noncomputable local instance matrixCStarAlgebra (n : ℕ) :
    CStarAlgebra (Matrix (Fin n) (Fin n) ℂ) where

/-- **Every unitary matrix is the exponential of `i` times a Hermitian matrix.**
This is the finite-dimensional surjectivity statement (`n = 2` gives `U(2)`). -/
theorem Matrix.exists_isHermitian_exp_I_smul_eq {n : ℕ} {U : Matrix (Fin n) (Fin n) ℂ}
    (hU : U ∈ unitary (Matrix (Fin n) (Fin n) ℂ)) :
    ∃ H : Matrix (Fin n) (Fin n) ℂ, H.IsHermitian ∧ NormedSpace.exp (I • H) = U := by
  obtain ⟨H, hH, hexp⟩ := exists_isSelfAdjoint_exp_I_smul_eq hU (Matrix.finite_spectrum U)
  exact ⟨H, Matrix.isHermitian_iff_isSelfAdjoint.mpr hH, hexp⟩

end Matrices

/-! ### Determinant tracking: scalar times special unitary -/

variable {n : ℕ}

theorem norm_det_of_mem_unitary (U : Matrix (Fin n) (Fin n) ℂ)
    (hU : U ∈ unitary (Matrix (Fin n) (Fin n) ℂ)) : ‖U.det‖ = 1 := by
  have h2 := congrArg Matrix.det hU.1
  rw [Matrix.det_mul, show (star U : Matrix (Fin n) (Fin n) ℂ) = U.conjTranspose from rfl,
    Matrix.det_conjTranspose, Matrix.det_one] at h2
  have h3 : ‖star U.det * U.det‖ = 1 := by rw [h2]; simp
  rw [norm_mul, norm_star] at h3
  nlinarith [norm_nonneg U.det]

/-- **Determinant tracking.**  Every unitary matrix is a unimodular scalar times
a special unitary matrix; the scalar is an `n`-th root of the determinant. -/
theorem exists_scalar_smul_specialUnitary (hn : 0 < n) (U : Matrix (Fin n) (Fin n) ℂ)
    (hU : U ∈ unitary (Matrix (Fin n) (Fin n) ℂ)) :
    ∃ z : ℂ, ∃ V : Matrix (Fin n) (Fin n) ℂ, ‖z‖ = 1 ∧ V ∈ unitary (Matrix (Fin n) (Fin n) ℂ) ∧
      V.det = 1 ∧ U = z • V := by
  have hd : ‖U.det‖ = 1 := norm_det_of_mem_unitary U hU
  have hdne : U.det ≠ 0 := by intro h; rw [h] at hd; simp at hd
  have hn0 : (n : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hn.ne'
  set a : ℝ := U.det.arg / n with ha
  set z : ℂ := Complex.exp ((a : ℂ) * I) with hz
  have hznorm : ‖z‖ = 1 := Complex.norm_exp_ofReal_mul_I a
  have hzne : z ≠ 0 := Complex.exp_ne_zero _
  have hzn : z ^ n = U.det := by
    rw [hz, ← Complex.exp_nat_mul]
    have hcast : (n : ℂ) * ((a : ℂ) * I) = (U.det.arg : ℂ) * I := by
      rw [ha]; push_cast; field_simp
    rw [hcast]
    have h := Complex.norm_mul_exp_arg_mul_I U.det
    rw [hd] at h
    simpa using h
  refine ⟨z, z⁻¹ • U, hznorm, ?_, ?_, ?_⟩
  · have h : z⁻¹ • U = (z⁻¹ • (1 : Matrix (Fin n) (Fin n) ℂ)) * U := by
      rw [smul_mul_assoc, one_mul]
    rw [h]
    refine mul_mem (scalar_smul_one_mem_unitary ?_) hU
    rw [norm_inv, hznorm, inv_one]
  · rw [Matrix.det_smul, Fintype.card_fin, inv_pow, hzn]
    field_simp
  · rw [smul_smul, mul_inv_cancel₀ hzne, one_smul]

/-! ### The `SU(2)` obstruction for the scalar logarithmic factor -/

theorem arg_one_add_mul_I_ne_zero {t : ℝ} (ht : t ≠ 0) : (1 + (t : ℂ) * I).arg ≠ 0 := by
  intro h
  rcases Complex.arg_eq_zero_iff.mp h with ⟨-, him⟩
  simp at him
  exact ht him

/-- **Obstruction to `SU(2)`.**  For every nonzero real parameter the scalar
logarithmic factor `log (1 + t i) • 1` has determinant `≠ 1` in the `2 × 2`
matrix algebra; so, unitary as it may be, it never lies in `SU(2)`.  The
special unitary part must therefore come from the non-scalar factor of
`exists_scalar_smul_specialUnitary`. -/
theorem scalarLog_smul_one_det_ne_one {t : ℝ} (ht : t ≠ 0) :
    (Complex.log (1 + (t : ℂ) * I) • (1 : Matrix (Fin 2) (Fin 2) ℂ)).det ≠ 1 := by
  set z : ℂ := Complex.log (1 + (t : ℂ) * I) with hzdef
  have him : z.im ≠ 0 := by
    rw [hzdef, Complex.log_im]
    exact arg_one_add_mul_I_ne_zero ht
  rw [Matrix.det_smul, Fintype.card_fin, Matrix.det_one, mul_one]
  intro hsq
  have hfac : (z - 1) * (z + 1) = 0 := by ring_nf; linear_combination hsq
  rcases mul_eq_zero.mp hfac with h | h
  · apply him
    have : z = 1 := by linear_combination h
    rw [this]; simp
  · apply him
    have : z = -1 := by linear_combination h
    rw [this]; simp

end