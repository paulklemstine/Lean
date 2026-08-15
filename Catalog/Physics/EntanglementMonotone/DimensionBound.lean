import Physics.EntanglementMonotone.MaxEntangled
import Physics.EntanglementMonotone.TraceNormSpectral

/-!
# A sharp dimensional ceiling for the logarithmic negativity

The logarithmic negativity of a state on `ℂ^α ⊗ ℂ^β` cannot exceed
`½ log (dim α · dim β)`.  The argument is a Cauchy–Schwarz / Hilbert–Schmidt estimate:

* the trace norm of a Hermitian matrix of size `N` is at most `√N` times its
  Hilbert–Schmidt norm (`EntMonotone.traceNorm_sq_le_card_mul`, from
  `∑|λᵢ| ≤ √N √(∑λᵢ²)`);
* partial transposition permutes matrix entries, hence preserves the Hilbert–Schmidt norm
  (`EntMonotone.trace_ptrans_sq`);
* the purity `tr ρ²` of a state is at most `1` (`EntMonotone.re_trace_sq_le_one_of_isState`).

Together with `Physics.EntanglementMonotone.MaxEntangled`, where the maximally entangled state
is shown to have logarithmic negativity exactly `log d`, this proves that the maximally
entangled state is a *global maximiser* of the logarithmic negativity on `ℂ^d ⊗ ℂ^d`
(`EntMonotone.logNeg_le_logNeg_maxEntangled`), so the ceiling is sharp.
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

/-! ## Hilbert–Schmidt norm and the trace norm -/

section Frobenius

variable {n : Type*} [Fintype n] [DecidableEq n]

/-- The trace of the square of a diagonalised Hermitian matrix is `∑ᵢ λᵢ²`. -/
theorem trace_sq_conj_diagonal {U : Matrix n n ℂ} (hU1 : Uᴴ * U = 1) (lam : n → ℝ) :
    ((U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ)
      * (U * diagonal (fun i => ((lam i : ℝ) : ℂ)) * Uᴴ)).trace
      = ∑ i, (((lam i) ^ 2 : ℝ) : ℂ) := by
  have hprod : ∀ D S : Matrix n n ℂ, (U * D * Uᴴ) * (U * S * Uᴴ) = U * (D * S) * Uᴴ := by
    intro D S
    rw [Matrix.mul_assoc (U * D) Uᴴ (U * S * Uᴴ), ← Matrix.mul_assoc Uᴴ (U * S) Uᴴ,
      ← Matrix.mul_assoc Uᴴ U S, hU1, Matrix.one_mul, ← Matrix.mul_assoc,
      Matrix.mul_assoc U D S]
  rw [hprod, trace_conj_unitary hU1, Matrix.diagonal_mul_diagonal, Matrix.trace_diagonal]
  refine Finset.sum_congr rfl fun i _ => ?_
  push_cast
  ring

/-- The Hilbert–Schmidt norm squared of a Hermitian matrix is `∑ᵢ λᵢ²`. -/
theorem re_trace_sq_eq_sum_sq {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    (X * X).trace.re = ∑ i, (hX.eigenvalues i) ^ 2 := by
  have h := trace_sq_conj_diagonal (U := eigU hX) (eigU_conjTranspose_mul hX) hX.eigenvalues
  rw [← spectral_eq hX] at h
  rw [h, Complex.re_sum]
  exact Finset.sum_congr rfl fun i _ => Complex.ofReal_re _

/-- **Cauchy–Schwarz bound**: `‖X‖₁² ≤ N ‖X‖_HS²` for a Hermitian `N × N` matrix. -/
theorem traceNorm_sq_le_card_mul {X : Matrix n n ℂ} (hX : X.IsHermitian) :
    (traceNorm X) ^ 2 ≤ (Fintype.card n : ℝ) * (X * X).trace.re := by
  rw [traceNorm_eq_sum_abs_eigenvalues hX, re_trace_sq_eq_sum_sq hX]
  have h := sq_sum_le_card_mul_sum_sq (s := (Finset.univ : Finset n))
    (f := fun i => |hX.eigenvalues i|)
  simpa [Finset.card_univ, sq_abs] using h

end Frobenius

/-! ## Purity of a state -/

section Purity

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

omit [DecidableEq α] [DecidableEq β] in
/-- Partial transposition preserves the Hilbert–Schmidt norm: it merely permutes the entries
of the matrix. -/
theorem trace_ptrans_sq (X : Matrix (α × β) (α × β) ℂ) :
    (ptrans X * ptrans X).trace = (X * X).trace := by
  have h := sum_swap_second (fun u v : α × β => X v u * X u v)
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, ptrans, Matrix.of_apply]
  rw [Finset.sum_comm]
  rw [h]
  exact Finset.sum_comm

/-- The purity of a state is at most one. -/
theorem re_trace_sq_le_one_of_isState {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    (ρ * ρ).trace.re ≤ 1 := by
  have hherm := hρ.pos.isHermitian
  have hsum : ∑ i, hherm.eigenvalues i = 1 := by
    have h := hherm.trace_eq_sum_eigenvalues
    rw [hρ.trace_one] at h
    have := congrArg Complex.re h
    simpa [Complex.re_sum] using this.symm
  have hle : ∑ i, (hherm.eigenvalues i) ^ 2 ≤ (∑ i, hherm.eigenvalues i) ^ 2 :=
    Finset.sum_sq_le_sq_sum_of_nonneg (fun i _ => hρ.pos.eigenvalues_nonneg i)
  rw [re_trace_sq_eq_sum_sq hherm]
  rw [hsum] at hle
  simpa using hle

end Purity

/-! ## The dimensional ceiling -/

section Ceiling

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- The trace norm of the partial transpose of a state is at most `√(dim α · dim β)`. -/
theorem traceNorm_ptrans_le_sqrt_card {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    traceNorm (ptrans ρ)
      ≤ Real.sqrt ((Fintype.card α : ℝ) * (Fintype.card β : ℝ)) := by
  have hherm := ptrans_isHermitian hρ.pos.isHermitian
  have hsq : (traceNorm (ptrans ρ)) ^ 2
      ≤ ((Fintype.card α : ℝ) * (Fintype.card β : ℝ)) := by
    have h := traceNorm_sq_le_card_mul hherm
    rw [trace_ptrans_sq] at h
    refine h.trans ?_
    have hcard : (Fintype.card (α × β) : ℝ) = (Fintype.card α : ℝ) * (Fintype.card β : ℝ) := by
      rw [Fintype.card_prod]; push_cast; ring
    rw [hcard]
    have hpos : (0 : ℝ) ≤ (Fintype.card α : ℝ) * (Fintype.card β : ℝ) := by positivity
    nlinarith [re_trace_sq_le_one_of_isState hρ, hpos]
  have hnn : 0 ≤ traceNorm (ptrans ρ) := traceNorm_nonneg _
  have := Real.sqrt_le_sqrt hsq
  rwa [Real.sqrt_sq hnn] at this

/-- **Dimensional ceiling for the logarithmic negativity**:
`E_N(ρ) ≤ ½ log (dim α · dim β)`. -/
theorem logNeg_le_log_dim {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    logNeg ρ ≤ Real.log ((Fintype.card α : ℝ) * (Fintype.card β : ℝ)) / 2 := by
  have h := traceNorm_ptrans_le_sqrt_card hρ
  have hpos : (0 : ℝ) < traceNorm (ptrans ρ) :=
    lt_of_lt_of_le zero_lt_one (one_le_traceNorm_ptrans hρ)
  have hlog := Real.log_le_log hpos h
  rw [logNeg]
  refine hlog.trans (le_of_eq ?_)
  rw [Real.log_sqrt (by positivity)]

end Ceiling

/-! ## Sharpness: the maximally entangled state is the global maximiser -/

section Sharp

variable {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]

/-- **The maximally entangled state maximises the logarithmic negativity.**  On `ℂ^d ⊗ ℂ^d`
no state has logarithmic negativity larger than `log d`, and `Φ_d` attains it. -/
theorem logNeg_le_logNeg_maxEntangled {ρ : Matrix (α × α) (α × α) ℂ} (hρ : IsState ρ) :
    logNeg ρ ≤ logNeg (maxEntangled : Matrix (α × α) (α × α) ℂ) := by
  have h := logNeg_le_log_dim hρ
  rw [logNeg_maxEntangled]
  refine h.trans (le_of_eq ?_)
  rw [show ((Fintype.card α : ℝ) * (Fintype.card α : ℝ)) = (Fintype.card α : ℝ) ^ 2 by ring,
    Real.log_pow]
  push_cast
  ring

end Sharp

end EntMonotone