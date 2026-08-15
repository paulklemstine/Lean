import Physics.EntanglementMonotone.TraceNormSpectral
import Physics.EntanglementMonotone.LogNegativity

/-!
# Strong duality, multiplicativity of the trace norm, and additivity of `E_N`

The variational trace norm of `Physics.EntanglementMonotone.TraceNorm` is an infimum and the
weak duality bound `Re tr (X W) ≤ ‖X‖₁` is a supremum bound.  Here we show that **both are
attained**:

* `EntMonotone.exists_jordanPair_traceNorm_eq` : the primal infimum is a minimum, realised by
  the spectral Jordan pair;
* `EntMonotone.exists_contraction_traceNorm_eq` : the dual supremum is a maximum, realised by
  the sign operator of the spectrum.

Strong duality is exactly what is needed to turn the *sub*multiplicativity of the trace norm
under Kronecker products into an equality:

* `EntMonotone.traceNorm_kronecker` : `‖A ⊗ B‖₁ = ‖A‖₁ ‖B‖₁` for Hermitian `A`, `B`.

The upper bound comes from tensoring the two optimal Jordan pairs, the lower bound from
tensoring the two optimal contractions — the latter is a contraction because of the identity
`1 - W ⊗ V = ½ ((1 - W) ⊗ (1 + V) + (1 + W) ⊗ (1 - V))`.

Combining this with the fact that partial transposition factorises through the regrouping of
tensor factors gives the headline result

* `EntMonotone.logNeg_tensorBipartite` : `E_N(ρ ⊗ σ) = E_N(ρ) + E_N(σ)`,

i.e. the logarithmic negativity is *additive*, while the negativity itself is not
(`EntMonotone.negativity_tensorBipartite`: `N(ρ ⊗ σ) = 2 N(ρ) N(σ) + N(ρ) + N(σ)`).
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

/-! ## Attainment of the primal and dual optima -/

section Attainment

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The spectral Jordan pair of a unitarily diagonalised Hermitian matrix. -/
theorem jordanPair_conj_diagonal (U : Matrix n n ℂ) (lam : n → ℝ) :
    IsJordanPair (U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ)
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

section Conj

variable {U : Matrix n n ℂ} (hU1 : Uᴴ * U = 1) (hU2 : U * Uᴴ = 1)

include hU1 in
/-- The spectral Jordan pair has objective value `∑ᵢ |λᵢ|`. -/
theorem trace_jordanPair_conj_diagonal (lam : n → ℝ) :
    ((U * diagonal (fun i => ((max (lam i) 0 : ℝ) : ℂ)) * Uᴴ).trace
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

include hU1 in
/-- The sign operator pairs with a diagonalised Hermitian matrix to give `∑ᵢ |λᵢ|`. -/
theorem re_trace_mul_signOfSpectrum (lam : n → ℝ) :
    ((U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ) * signOfSpectrum U lam).trace.re
      = ∑ i, |lam i| := by
  have hprod : ∀ D S : Matrix n n ℂ, (U * D * Uᴴ) * (U * S * Uᴴ) = U * (D * S) * Uᴴ := by
    intro D S
    rw [Matrix.mul_assoc (U * D) Uᴴ (U * S * Uᴴ), ← Matrix.mul_assoc Uᴴ (U * S) Uᴴ,
      ← Matrix.mul_assoc Uᴴ U S, hU1, Matrix.one_mul, ← Matrix.mul_assoc,
      Matrix.mul_assoc U D S]
  rw [signOfSpectrum, hprod, trace_conj_unitary hU1, Matrix.diagonal_mul_diagonal,
    Matrix.trace_diagonal, Complex.re_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  by_cases h : 0 ≤ lam i
  · rw [if_pos h]
    simp [abs_of_nonneg h]
  · rw [if_neg h]
    push_neg at h
    simp [abs_of_neg h]

end Conj

/-- **The primal infimum defining the trace norm is attained.** -/
theorem exists_jordanPair_traceNorm_eq {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    ∃ P Q, IsJordanPair X P Q ∧ (P.trace + Q.trace).re = traceNorm X := by
  have hJ := jordanPair_conj_diagonal (eigU hX) hX.eigenvalues
  rw [← spectral_eq hX] at hJ
  refine ⟨_, _, hJ, ?_⟩
  rw [trace_jordanPair_conj_diagonal (eigU_conjTranspose_mul hX) hX.eigenvalues,
    traceNorm_eq_sum_abs_eigenvalues hX]

/-- **Strong duality: the dual supremum is attained.**  For every Hermitian `X` there is a
Hermitian contraction `W` with `Re tr (X W) = ‖X‖₁`. -/
theorem exists_contraction_traceNorm_eq {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    ∃ W, IsContraction W ∧ (X * W).trace.re = traceNorm X := by
  refine ⟨signOfSpectrum (eigU hX) hX.eigenvalues,
    isContraction_signOfSpectrum (eigU_mul_conjTranspose hX) _, ?_⟩
  have h := re_trace_mul_signOfSpectrum (eigU_conjTranspose_mul hX) hX.eigenvalues
  rw [← spectral_eq hX] at h
  rw [h, traceNorm_eq_sum_abs_eigenvalues hX]

end Attainment

/-! ## Bilinearity of the Kronecker product -/

section Bilinear

variable {m n : Type*} [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n]

omit [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n] in
theorem kron_sub_left (A B : Matrix m m ℂ) (C : Matrix n n ℂ) :
    (A - B) ⊗ₖ C = A ⊗ₖ C - B ⊗ₖ C := by
  ext p q; simp [Matrix.kroneckerMap_apply, sub_mul]

omit [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n] in
theorem kron_sub_right (A : Matrix m m ℂ) (B C : Matrix n n ℂ) :
    A ⊗ₖ (B - C) = A ⊗ₖ B - A ⊗ₖ C := by
  ext p q; simp [Matrix.kroneckerMap_apply, mul_sub]

/-- The Kronecker product of two Hermitian contractions is a contraction.  The proof is the
operator identity `1 ∓ W ⊗ V = ½ ((1 ∓ W) ⊗ (1 ± V) + (1 ± W) ⊗ (1 ∓ V))`. -/
theorem isContraction_kronecker {W : Matrix m m ℂ} {V : Matrix n n ℂ}
    (hW : IsContraction W) (hV : IsContraction V) : IsContraction (W ⊗ₖ V) := by
  have hhalf : (0 : ℂ) ≤ (2 : ℂ)⁻¹ := by norm_num [Complex.le_def]
  refine ⟨?_, ?_, ?_⟩
  · unfold Matrix.IsHermitian
    rw [Matrix.conjTranspose_kronecker, hW.herm.eq, hV.herm.eq]
  · have key : (1 : Matrix (m × n) (m × n) ℂ) - W ⊗ₖ V
        = (2 : ℂ)⁻¹ • ((1 - W) ⊗ₖ (1 + V) + (1 + W) ⊗ₖ (1 - V)) := by
      rw [show (1 : Matrix (m × n) (m × n) ℂ) = (1 : Matrix m m ℂ) ⊗ₖ (1 : Matrix n n ℂ) from
        Matrix.one_kronecker_one.symm]
      simp only [Matrix.add_kronecker, Matrix.kronecker_add, kron_sub_left, kron_sub_right]
      module
    rw [key]
    exact Matrix.PosSemidef.smul
      ((posSemidef_kronecker hW.one_sub hV.one_add).add
        (posSemidef_kronecker hW.one_add hV.one_sub)) hhalf
  · have key : (1 : Matrix (m × n) (m × n) ℂ) + W ⊗ₖ V
        = (2 : ℂ)⁻¹ • ((1 - W) ⊗ₖ (1 - V) + (1 + W) ⊗ₖ (1 + V)) := by
      rw [show (1 : Matrix (m × n) (m × n) ℂ) = (1 : Matrix m m ℂ) ⊗ₖ (1 : Matrix n n ℂ) from
        Matrix.one_kronecker_one.symm]
      simp only [Matrix.add_kronecker, Matrix.kronecker_add, kron_sub_left, kron_sub_right]
      module
    rw [key]
    exact Matrix.PosSemidef.smul
      ((posSemidef_kronecker hW.one_sub hV.one_sub).add
        (posSemidef_kronecker hW.one_add hV.one_add)) hhalf

end Bilinear

/-! ## Multiplicativity of the trace norm -/

section Multiplicativity

variable {m n : Type*} [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n]

omit [DecidableEq m] in
/-- The trace of a product of two Hermitian matrices is real. -/
theorem im_trace_mul_of_isHermitian {A W : Matrix m m ℂ} (hA : A.IsHermitian)
    (hW : W.IsHermitian) : (A * W).trace.im = 0 := by
  rw [← Complex.conj_eq_iff_im]
  have h : (starRingEnd ℂ) (A * W).trace = ((A * W)ᴴ).trace := by
    rw [Matrix.trace_conjTranspose]; rfl
  rw [h, Matrix.conjTranspose_mul, hA.eq, hW.eq, Matrix.trace_mul_comm]

omit [DecidableEq m] in
/-- The trace of a positive semidefinite matrix is real. -/
theorem im_trace_of_posSemidef {P : Matrix m m ℂ} (hP : P.PosSemidef) : P.trace.im = 0 := by
  have h := (Complex.le_def.mp hP.trace_nonneg).2
  simpa using h.symm

/-- **Submultiplicativity**: tensoring two Jordan pairs gives a Jordan pair of the Kronecker
product. -/
theorem traceNorm_kronecker_le {A : Matrix m m ℂ} {B : Matrix n n ℂ}
    (hA : A.IsHermitian) (hB : B.IsHermitian) :
    traceNorm (A ⊗ₖ B) ≤ traceNorm A * traceNorm B := by
  obtain ⟨P, Q, hPQ, hval1⟩ := exists_jordanPair_traceNorm_eq hA
  obtain ⟨R, S, hRS, hval2⟩ := exists_jordanPair_traceNorm_eq hB
  have hJ : IsJordanPair (A ⊗ₖ B) (P ⊗ₖ R + Q ⊗ₖ S) (P ⊗ₖ S + Q ⊗ₖ R) := by
    refine ⟨(posSemidef_kronecker hPQ.posP hRS.posP).add
        (posSemidef_kronecker hPQ.posQ hRS.posQ),
      (posSemidef_kronecker hPQ.posP hRS.posQ).add
        (posSemidef_kronecker hPQ.posQ hRS.posP), ?_⟩
    rw [hPQ.decomp, hRS.decomp, kron_sub_left, kron_sub_right, kron_sub_right]
    abel
  have h := traceNorm_le hJ
  have hval : ((P ⊗ₖ R + Q ⊗ₖ S).trace + (P ⊗ₖ S + Q ⊗ₖ R).trace).re
      = traceNorm A * traceNorm B := by
    rw [← hval1, ← hval2]
    simp only [Matrix.trace_add, Matrix.trace_kronecker]
    have him : (P.trace + Q.trace).im = 0 := by
      rw [Complex.add_im, im_trace_of_posSemidef hPQ.posP, im_trace_of_posSemidef hPQ.posQ,
        add_zero]
    have hexp : P.trace * R.trace + Q.trace * S.trace + (P.trace * S.trace + Q.trace * R.trace)
        = (P.trace + Q.trace) * (R.trace + S.trace) := by ring
    rw [hexp, Complex.mul_re, him]
    simp [Complex.add_re]
  rwa [hval] at h

/-- **Supermultiplicativity**: tensoring two optimal contractions certifies the matching lower
bound.  This is where strong duality is used. -/
theorem le_traceNorm_kronecker {A : Matrix m m ℂ} {B : Matrix n n ℂ}
    (hA : A.IsHermitian) (hB : B.IsHermitian) :
    traceNorm A * traceNorm B ≤ traceNorm (A ⊗ₖ B) := by
  obtain ⟨W, hW, hWval⟩ := exists_contraction_traceNorm_eq hA
  obtain ⟨V, hV, hVval⟩ := exists_contraction_traceNorm_eq hB
  have hherm : (A ⊗ₖ B).IsHermitian := by
    unfold Matrix.IsHermitian
    rw [Matrix.conjTranspose_kronecker, hA.eq, hB.eq]
  have hdual := re_trace_mul_le_traceNorm hherm (isContraction_kronecker hW hV)
  have hval : ((A ⊗ₖ B) * (W ⊗ₖ V)).trace.re = traceNorm A * traceNorm B := by
    rw [← Matrix.mul_kronecker_mul, Matrix.trace_kronecker, Complex.mul_re,
      im_trace_mul_of_isHermitian hA hW.herm, hWval, hVval]
    ring
  rwa [hval] at hdual

/-- **The trace norm is multiplicative under Kronecker products.** -/
theorem traceNorm_kronecker {A : Matrix m m ℂ} {B : Matrix n n ℂ}
    (hA : A.IsHermitian) (hB : B.IsHermitian) :
    traceNorm (A ⊗ₖ B) = traceNorm A * traceNorm B :=
  le_antisymm (traceNorm_kronecker_le hA hB) (le_traceNorm_kronecker hA hB)

end Multiplicativity

/-! ## Invariance of the trace norm under relabelling -/

section Relabel

variable {m n : Type*} [Fintype m] [DecidableEq m] [Fintype n] [DecidableEq n]

omit [DecidableEq m] [DecidableEq n] in
theorem trace_submatrix_equiv (e : m ≃ n) (X : Matrix n n ℂ) :
    (X.submatrix e e).trace = X.trace := by
  simp only [Matrix.trace, Matrix.diag, Matrix.submatrix_apply]
  exact Fintype.sum_equiv e _ _ (fun i => rfl)

omit [DecidableEq m] [DecidableEq n] in
theorem traceNormSet_submatrix (e : m ≃ n) (X : Matrix n n ℂ) :
    traceNormSet (X.submatrix e e) = traceNormSet X := by
  ext r
  constructor
  · rintro ⟨P, Q, hPQ, rfl⟩
    refine ⟨P.submatrix e.symm e.symm, Q.submatrix e.symm e.symm,
      ⟨hPQ.posP.submatrix _, hPQ.posQ.submatrix _, ?_⟩, ?_⟩
    · have h := congrArg (fun M : Matrix m m ℂ => M.submatrix e.symm e.symm) hPQ.decomp
      simpa [Matrix.submatrix_submatrix, Function.comp] using h
    · rw [trace_submatrix_equiv e.symm, trace_submatrix_equiv e.symm]
  · rintro ⟨P, Q, hPQ, rfl⟩
    refine ⟨P.submatrix e e, Q.submatrix e e,
      ⟨hPQ.posP.submatrix _, hPQ.posQ.submatrix _, ?_⟩, ?_⟩
    · rw [hPQ.decomp]
      ext i j
      simp
    · rw [trace_submatrix_equiv e, trace_submatrix_equiv e]

omit [DecidableEq m] [DecidableEq n] in
/-- The trace norm only depends on the matrix up to relabelling of the index set. -/
theorem traceNorm_submatrix_equiv (e : m ≃ n) (X : Matrix n n ℂ) :
    traceNorm (X.submatrix e e) = traceNorm X := by
  rw [traceNorm, traceNorm, traceNormSet_submatrix]

end Relabel

/-! ## Additivity of the logarithmic negativity -/

section Additivity

variable {α β γ δ : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
  [Fintype γ] [DecidableEq γ] [Fintype δ] [DecidableEq δ]

/-- Regrouping of four tensor factors, `(A₁ ⊗ A₂) ⊗ (B₁ ⊗ B₂) ≃ (A₁ ⊗ B₁) ⊗ (A₂ ⊗ B₂)`. -/
def regroup : ((α × γ) × (β × δ)) ≃ ((α × β) × (γ × δ)) where
  toFun p := ((p.1.1, p.2.1), (p.1.2, p.2.2))
  invFun q := ((q.1.1, q.2.1), (q.1.2, q.2.2))
  left_inv _ := rfl
  right_inv _ := rfl

/-- The tensor product of two bipartite operators, regrouped so that the two `A`-factors and
the two `B`-factors are held together; this is the bipartite operator whose entanglement
across the `A|B` cut is being studied. -/
def tensorBipartite (ρ : Matrix (α × β) (α × β) ℂ) (σ : Matrix (γ × δ) (γ × δ) ℂ) :
    Matrix ((α × γ) × (β × δ)) ((α × γ) × (β × δ)) ℂ :=
  (ρ ⊗ₖ σ).submatrix regroup regroup

omit [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β] [Fintype γ] [DecidableEq γ]
  [Fintype δ] [DecidableEq δ] in
/-- Partial transposition factorises over the tensor product of bipartite operators. -/
theorem ptrans_tensorBipartite (ρ : Matrix (α × β) (α × β) ℂ) (σ : Matrix (γ × δ) (γ × δ) ℂ) :
    ptrans (tensorBipartite ρ σ) = tensorBipartite (ptrans ρ) (ptrans σ) := by
  ext ⟨⟨a, c⟩, ⟨b, d⟩⟩ ⟨⟨a', c'⟩, ⟨b', d'⟩⟩
  rfl

theorem tensorBipartite_posSemidef {ρ : Matrix (α × β) (α × β) ℂ}
    {σ : Matrix (γ × δ) (γ × δ) ℂ} (hρ : ρ.PosSemidef) (hσ : σ.PosSemidef) :
    (tensorBipartite ρ σ).PosSemidef :=
  (posSemidef_kronecker hρ hσ).submatrix _

theorem tensorBipartite_isState {ρ : Matrix (α × β) (α × β) ℂ} {σ : Matrix (γ × δ) (γ × δ) ℂ}
    (hρ : IsState ρ) (hσ : IsState σ) : IsState (tensorBipartite ρ σ) := by
  refine ⟨tensorBipartite_posSemidef hρ.pos hσ.pos, ?_⟩
  rw [tensorBipartite, trace_submatrix_equiv, Matrix.trace_kronecker, hρ.trace_one,
    hσ.trace_one, one_mul]

/-- The trace norm of the partial transpose is multiplicative over tensor products. -/
theorem traceNorm_ptrans_tensorBipartite {ρ : Matrix (α × β) (α × β) ℂ}
    {σ : Matrix (γ × δ) (γ × δ) ℂ} (hρ : ρ.IsHermitian) (hσ : σ.IsHermitian) :
    traceNorm (ptrans (tensorBipartite ρ σ))
      = traceNorm (ptrans ρ) * traceNorm (ptrans σ) := by
  rw [ptrans_tensorBipartite, tensorBipartite, traceNorm_submatrix_equiv,
    traceNorm_kronecker (ptrans_isHermitian hρ) (ptrans_isHermitian hσ)]

/-- **Additivity of the logarithmic negativity.**  `E_N(ρ ⊗ σ) = E_N(ρ) + E_N(σ)`. -/
theorem logNeg_tensorBipartite {ρ : Matrix (α × β) (α × β) ℂ} {σ : Matrix (γ × δ) (γ × δ) ℂ}
    (hρ : IsState ρ) (hσ : IsState σ) :
    logNeg (tensorBipartite ρ σ) = logNeg ρ + logNeg σ := by
  have h1 : traceNorm (ptrans ρ) ≠ 0 :=
    ne_of_gt (lt_of_lt_of_le zero_lt_one (one_le_traceNorm_ptrans hρ))
  have h2 : traceNorm (ptrans σ) ≠ 0 :=
    ne_of_gt (lt_of_lt_of_le zero_lt_one (one_le_traceNorm_ptrans hσ))
  rw [logNeg, logNeg, logNeg,
    traceNorm_ptrans_tensorBipartite hρ.pos.isHermitian hσ.pos.isHermitian,
    Real.log_mul h1 h2]

/-- The negativity itself is *not* additive: it obeys the multiplicative law
`N(ρ ⊗ σ) = 2 N(ρ) N(σ) + N(ρ) + N(σ)`.  This is precisely why the logarithm is taken. -/
theorem negativity_tensorBipartite {ρ : Matrix (α × β) (α × β) ℂ}
    {σ : Matrix (γ × δ) (γ × δ) ℂ} (hρ : ρ.IsHermitian) (hσ : σ.IsHermitian) :
    negativity (tensorBipartite ρ σ)
      = 2 * negativity ρ * negativity σ + negativity ρ + negativity σ := by
  rw [negativity, negativity, negativity, traceNorm_ptrans_tensorBipartite hρ hσ]
  ring

end Additivity

end EntMonotone