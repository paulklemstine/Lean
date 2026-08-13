import Physics.EntanglementMonotone.TraceNorm

/-!
# The variational trace norm equals the sum of the absolute eigenvalues

`Physics.EntanglementMonotone.TraceNorm` defines the trace norm of a Hermitian matrix
variationally, as the infimum of `tr P + tr Q` over Jordan decompositions `X = P - Q`.
Here we prove that this infimum is *attained* and equals the familiar spectral quantity

`‖X‖₁ = ∑ᵢ |λᵢ(X)|`.

The proof is a genuine duality argument: the upper bound comes from the Jordan pair built
from the positive and negative spectral parts, and the matching lower bound comes from weak
duality applied to the *sign operator* `W = U diag (sgn λ) Uᴴ`, which is shown to be a
Hermitian contraction.

As a corollary we obtain a sharp *faithfulness* criterion: a Hermitian matrix whose trace
norm does not exceed its trace is positive semidefinite
(`EntMonotone.posSemidef_of_traceNorm_le`).  For the logarithmic negativity this upgrades
"`E_N(ρ) = 0`" to "`ρ` is PPT".
-/

namespace EntMonotone

open Matrix ComplexOrder
open scoped MatrixOrder

variable {n : Type*} [Fintype n] [DecidableEq n]

/-! ## Diagonal bookkeeping -/

omit [Fintype n] in
/-- Difference of diagonal matrices, in pointwise form. -/
theorem diagonal_sub_fun (d e : n → ℂ) :
    diagonal d - diagonal e = diagonal (fun i => d i - e i) := by
  ext i j
  by_cases h : i = j <;> simp [Matrix.sub_apply, Matrix.diagonal_apply_ne, h]

omit [Fintype n] in
/-- Sum of diagonal matrices, in pointwise form. -/
theorem diagonal_add_fun (d e : n → ℂ) :
    diagonal d + diagonal e = diagonal (fun i => d i + e i) := by
  ext i j
  by_cases h : i = j <;> simp [Matrix.add_apply, Matrix.diagonal_apply_ne, h]

omit [Fintype n] [DecidableEq n] in
/-- The pointwise star of a real-valued family of complex numbers is itself. -/
theorem star_ofReal_fun (d : n → ℝ) :
    (star fun i => ((d i : ℝ) : ℂ)) = fun i => ((d i : ℝ) : ℂ) := by
  funext i
  simp

/-- A unitary conjugate of a real diagonal matrix is Hermitian. -/
theorem isHermitian_conj_diagonal (U : Matrix n n ℂ) (d : n → ℝ) :
    (U * diagonal (fun i => ((d i : ℝ) : ℂ)) * Uᴴ).IsHermitian := by
  unfold Matrix.IsHermitian
  rw [Matrix.conjTranspose_mul, Matrix.conjTranspose_mul, Matrix.conjTranspose_conjTranspose,
    Matrix.diagonal_conjTranspose, star_ofReal_fun, Matrix.mul_assoc]

/-! ## Unitary conjugation of a real diagonal matrix -/

section Conjugation

variable {U : Matrix n n ℂ} (hU1 : Uᴴ * U = 1) (hU2 : U * Uᴴ = 1)

include hU1 in
/-- Conjugation by a unitary preserves the trace. -/
theorem trace_conj_unitary (D : Matrix n n ℂ) : (U * D * Uᴴ).trace = D.trace := by
  rw [Matrix.trace_mul_comm (U * D) Uᴴ, ← Matrix.mul_assoc, hU1, Matrix.one_mul]

/-- Conjugating a nonnegative real diagonal matrix by a unitary gives a positive
semidefinite matrix. -/
theorem posSemidef_conj_diagonal (U : Matrix n n ℂ) {d : n → ℝ} (hd : ∀ i, 0 ≤ d i) :
    (U * diagonal (fun i => ((d i : ℝ) : ℂ)) * Uᴴ).PosSemidef :=
  (Matrix.PosSemidef.diagonal (by
    intro i
    simp [Complex.le_def, hd i])).mul_mul_conjTranspose_same _

include hU2 in
/-- `1 = U 1 Uᴴ` written with an explicit real diagonal. -/
theorem one_eq_conj_diagonal_one :
    (1 : Matrix n n ℂ) = U * diagonal (fun _ : n => ((1 : ℝ) : ℂ)) * Uᴴ := by
  rw [show (fun _ : n => ((1 : ℝ) : ℂ)) = fun _ : n => (1 : ℂ) by funext i; norm_num,
    Matrix.diagonal_one, Matrix.mul_one, hU2]

/-- The sign operator associated with a real spectrum. -/
noncomputable def signOfSpectrum (U : Matrix n n ℂ) (lam : n → ℝ) : Matrix n n ℂ :=
  U * diagonal (fun i => ((if 0 ≤ lam i then (1 : ℝ) else -1 : ℝ) : ℂ)) * Uᴴ

include hU2 in
/-- The sign operator is a Hermitian contraction. -/
theorem isContraction_signOfSpectrum (lam : n → ℝ) :
    IsContraction (signOfSpectrum U lam) := by
  have hone := one_eq_conj_diagonal_one (U := U) hU2
  refine ⟨?_, ?_, ?_⟩
  · exact isHermitian_conj_diagonal U (fun i => if 0 ≤ lam i then (1 : ℝ) else -1)
  · rw [signOfSpectrum]
    have hsub : (1 : Matrix n n ℂ)
        - (U * diagonal (fun i => ((if 0 ≤ lam i then (1 : ℝ) else -1 : ℝ) : ℂ)) * Uᴴ)
        = U * diagonal (fun i =>
            (((1 - if 0 ≤ lam i then (1 : ℝ) else -1) : ℝ) : ℂ)) * Uᴴ := by
      rw [hone, ← Matrix.sub_mul, ← Matrix.mul_sub, diagonal_sub_fun]
      congr 2
      funext i
      push_cast
      ring
    rw [hsub]
    refine posSemidef_conj_diagonal U ?_
    intro i
    by_cases h : 0 ≤ lam i
    · rw [if_pos h]; norm_num
    · rw [if_neg h]; norm_num
  · rw [signOfSpectrum]
    have hadd : (1 : Matrix n n ℂ)
        + (U * diagonal (fun i => ((if 0 ≤ lam i then (1 : ℝ) else -1 : ℝ) : ℂ)) * Uᴴ)
        = U * diagonal (fun i =>
            (((1 + if 0 ≤ lam i then (1 : ℝ) else -1) : ℝ) : ℂ)) * Uᴴ := by
      rw [hone, ← Matrix.add_mul, ← Matrix.mul_add, diagonal_add_fun]
      congr 2
      funext i
      push_cast
      ring
    rw [hadd]
    refine posSemidef_conj_diagonal U ?_
    intro i
    by_cases h : 0 ≤ lam i
    · rw [if_pos h]; norm_num
    · rw [if_neg h]; norm_num

include hU1 hU2 in
/-- **The trace norm of a unitarily diagonalised Hermitian matrix is the sum of the absolute
values of its spectrum.**  Both bounds are proved: the upper one from the Jordan pair of
spectral positive and negative parts, the lower one from weak duality with the sign
operator. -/
theorem traceNorm_conj_diagonal (lam : n → ℝ) :
    traceNorm (U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ) = ∑ i, |lam i| := by
  refine le_antisymm ?_ ?_
  · have hJ : IsJordanPair (U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ)
        (U * diagonal (fun i => ((max (lam i) 0 : ℝ) : ℂ)) * Uᴴ)
        (U * diagonal (fun i => ((max (-(lam i)) 0 : ℝ) : ℂ)) * Uᴴ) := by
      refine ⟨posSemidef_conj_diagonal U (fun i => le_max_right _ _),
        posSemidef_conj_diagonal U (fun i => le_max_right _ _), ?_⟩
      rw [← Matrix.sub_mul, ← Matrix.mul_sub, diagonal_sub_fun]
      have hfun : (fun i => ((max (lam i) 0 : ℝ) : ℂ) - ((max (-(lam i)) 0 : ℝ) : ℂ))
          = fun i => ((lam i : ℝ) : ℂ) := by
        funext i
        rw [← Complex.ofReal_sub]
        congr 1
        rcases le_total (lam i) 0 with h | h
        · rw [max_eq_right h, max_eq_left (by linarith)]; ring
        · rw [max_eq_left h, max_eq_right (by linarith)]; ring
      rw [hfun]
    have hle := traceNorm_le hJ
    have hval : ((U * diagonal (fun i => ((max (lam i) 0 : ℝ) : ℂ)) * Uᴴ).trace
        + (U * diagonal (fun i => ((max (-(lam i)) 0 : ℝ) : ℂ)) * Uᴴ).trace).re
        = ∑ i, |lam i| := by
      rw [trace_conj_unitary hU1, trace_conj_unitary hU1, Matrix.trace_diagonal,
        Matrix.trace_diagonal, ← Finset.sum_add_distrib, Complex.re_sum]
      refine Finset.sum_congr rfl fun i _ => ?_
      rcases le_total (lam i) 0 with h | h
      · rw [max_eq_right h, max_eq_left (by linarith : (0 : ℝ) ≤ -(lam i))]
        simp [abs_of_nonpos h]
      · rw [max_eq_left h, max_eq_right (by linarith : -(lam i) ≤ (0 : ℝ))]
        simp [abs_of_nonneg h]
    rwa [hval] at hle
  · have hherm : (U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ).IsHermitian :=
      isHermitian_conj_diagonal U lam
    have hdual := re_trace_mul_le_traceNorm hherm (isContraction_signOfSpectrum hU2 lam)
    have hval : ((U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ) * signOfSpectrum U lam).trace.re
        = ∑ i, |lam i| := by
      have hprod : ∀ D S : Matrix n n ℂ, (U * D * Uᴴ) * (U * S * Uᴴ) = U * (D * S) * Uᴴ := by
        intro D S
        rw [Matrix.mul_assoc (U * D) Uᴴ (U * S * Uᴴ), ← Matrix.mul_assoc Uᴴ (U * S) Uᴴ,
          ← Matrix.mul_assoc Uᴴ U S, hU1, Matrix.one_mul, ← Matrix.mul_assoc,
          Matrix.mul_assoc U D S]
      rw [signOfSpectrum, hprod]
      rw [trace_conj_unitary hU1, Matrix.diagonal_mul_diagonal, Matrix.trace_diagonal,
        Complex.re_sum]
      refine Finset.sum_congr rfl fun i _ => ?_
      by_cases h : 0 ≤ lam i
      · rw [if_pos h]
        simp [abs_of_nonneg h]
      · rw [if_neg h]
        push_neg at h
        simp [abs_of_neg h]
    rwa [hval] at hdual

end Conjugation

/-! ## Consequences for a Hermitian matrix -/

/-- The unitary diagonalising a Hermitian matrix. -/
noncomputable def eigU {X : Matrix n n ℂ} (hX : X.IsHermitian) : Matrix n n ℂ :=
  (hX.eigenvectorUnitary : Matrix n n ℂ)

theorem eigU_conjTranspose_mul {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    (eigU hX)ᴴ * eigU hX = 1 := by
  have h := Unitary.mem_iff.mp hX.eigenvectorUnitary.2
  rw [eigU, ← Matrix.star_eq_conjTranspose]
  exact h.1

theorem eigU_mul_conjTranspose {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    eigU hX * (eigU hX)ᴴ = 1 := by
  have h := Unitary.mem_iff.mp hX.eigenvectorUnitary.2
  rw [eigU, ← Matrix.star_eq_conjTranspose]
  exact h.2

/-- The spectral theorem in the concrete form `X = U D Uᴴ`. -/
theorem spectral_eq {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    X = eigU hX * diagonal (fun i => ((hX.eigenvalues i : ℝ) : ℂ)) * (eigU hX)ᴴ := by
  conv_lhs => rw [hX.spectral_theorem]
  rfl

/-- **The variational trace norm coincides with the spectral trace norm.** -/
theorem traceNorm_eq_sum_abs_eigenvalues {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    traceNorm X = ∑ i, |hX.eigenvalues i| := by
  have h := traceNorm_conj_diagonal (U := eigU hX) (eigU_conjTranspose_mul hX)
    (eigU_mul_conjTranspose hX) hX.eigenvalues
  rwa [← spectral_eq hX] at h

/-- **Faithfulness.** A Hermitian matrix whose trace norm does not exceed the real part of
its trace is positive semidefinite. -/
theorem posSemidef_of_traceNorm_le {X : Matrix n n ℂ} (hX : X.IsHermitian)
    (h : traceNorm X ≤ X.trace.re) : X.PosSemidef := by
  have hsum : ∑ i, |hX.eigenvalues i| ≤ ∑ i, hX.eigenvalues i := by
    rw [← traceNorm_eq_sum_abs_eigenvalues hX]
    refine le_trans h (le_of_eq ?_)
    rw [hX.trace_eq_sum_eigenvalues]
    simp
  have hnonneg : ∀ i, 0 ≤ hX.eigenvalues i := by
    intro i
    by_contra hi
    push_neg at hi
    have hlt : ∑ j, hX.eigenvalues j < ∑ j, |hX.eigenvalues j| := by
      refine Finset.sum_lt_sum (fun j _ => le_abs_self _) ⟨i, Finset.mem_univ i, ?_⟩
      calc hX.eigenvalues i < 0 := hi
        _ < |hX.eigenvalues i| := abs_pos.mpr (ne_of_lt hi)
    linarith
  exact hX.posSemidef_iff_eigenvalues_nonneg.mpr hnonneg

end EntMonotone