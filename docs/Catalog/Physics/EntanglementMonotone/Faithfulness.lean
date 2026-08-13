import Physics.EntanglementMonotone.MaxEntangled
import Physics.EntanglementMonotone.TraceNormSpectral

/-!
# Faithfulness of the logarithmic negativity on the PPT class

Combining the spectral description of the trace norm
(`EntMonotone.traceNorm_eq_sum_abs_eigenvalues`) with the definition of the logarithmic
negativity we obtain the exact vanishing criterion

`E_N(ρ) = 0  ↔  ρ is PPT`,

for any state `ρ`.  Since separable states are PPT, a strictly positive logarithmic
negativity certifies entanglement; the maximally entangled state of local dimension `d ≥ 2`
is thereby proved to be non-separable.
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-! ## Vanishing criterion -/

/-- **Faithfulness on the PPT class.** A state has vanishing logarithmic negativity exactly
when it is PPT. -/
theorem isPPT_iff_logNeg_eq_zero {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    IsPPT ρ ↔ logNeg ρ = 0 := by
  constructor
  · exact logNeg_eq_zero_of_isPPT hρ
  · intro h
    have hpos := traceNorm_ptrans_pos hρ
    have hone : traceNorm (ptrans ρ) = 1 := by
      have hexp := Real.exp_log hpos
      rw [show Real.log (traceNorm (ptrans ρ)) = 0 from h, Real.exp_zero] at hexp
      exact hexp.symm
    have hherm := ptrans_isHermitian hρ.pos.isHermitian
    refine posSemidef_of_traceNorm_le hherm ?_
    rw [hone, trace_ptrans, hρ.trace_one, Complex.one_re]

/-- The same criterion phrased with the negativity. -/
theorem isPPT_iff_negativity_eq_zero {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    IsPPT ρ ↔ negativity ρ = 0 := by
  constructor
  · exact negativity_eq_zero_of_isPPT hρ
  · intro h
    refine (isPPT_iff_logNeg_eq_zero hρ).mpr ?_
    have hone : traceNorm (ptrans ρ) = 1 := by
      unfold negativity at h
      linarith
    rw [logNeg, hone, Real.log_one]

/-- A state is entangled beyond the PPT class exactly when its logarithmic negativity is
strictly positive. -/
theorem logNeg_pos_iff_not_isPPT {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ) :
    0 < logNeg ρ ↔ ¬ IsPPT ρ := by
  constructor
  · intro h hppt
    rw [logNeg_eq_zero_of_isPPT hρ hppt] at h
    exact lt_irrefl 0 h
  · intro h
    rcases lt_or_eq_of_le (logNeg_nonneg hρ) with h1 | h1
    · exact h1
    · exact absurd ((isPPT_iff_logNeg_eq_zero hρ).mpr h1.symm) h

/-! ## Separable states -/

/-- A separable state: a convex combination of product operators. -/
def IsSeparable (ρ : Matrix (α × β) (α × β) ℂ) : Prop :=
  ∃ (m : ℕ) (w : Fin m → ℝ) (A : Fin m → Matrix α α ℂ) (B : Fin m → Matrix β β ℂ),
    (∀ i, 0 ≤ w i) ∧ (∀ i, (A i).PosSemidef) ∧ (∀ i, (B i).PosSemidef) ∧
      ρ = ∑ i, ((w i : ℝ) : ℂ) • (A i ⊗ₖ B i)

/-- **Separable states are PPT.** -/
theorem isPPT_of_isSeparable {ρ : Matrix (α × β) (α × β) ℂ} (h : IsSeparable ρ) : IsPPT ρ := by
  obtain ⟨m, w, A, B, hw, hA, hB, hρ⟩ := h
  have hpt : ptrans ρ = ∑ i, ((w i : ℝ) : ℂ) • (A i ⊗ₖ (B i)ᵀ) := by
    rw [hρ, ptrans_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [ptrans_smul, ptrans_kronecker]
  rw [IsPPT, hpt]
  refine Matrix.posSemidef_sum _ fun i _ => ?_
  refine (posSemidef_kronecker (hA i) (hB i).transpose).smul ?_
  simp [Complex.le_def, hw i]

/-- Separable states have vanishing logarithmic negativity. -/
theorem logNeg_eq_zero_of_isSeparable {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ)
    (h : IsSeparable ρ) : logNeg ρ = 0 :=
  logNeg_eq_zero_of_isPPT hρ (isPPT_of_isSeparable h)

/-- **Entanglement detection.** A state with strictly positive logarithmic negativity is not
separable. -/
theorem not_isSeparable_of_logNeg_pos {ρ : Matrix (α × β) (α × β) ℂ} (hρ : IsState ρ)
    (h : 0 < logNeg ρ) : ¬ IsSeparable ρ := by
  intro hsep
  rw [logNeg_eq_zero_of_isSeparable hρ hsep] at h
  exact lt_irrefl 0 h

/-- The maximally entangled state of local dimension at least `2` is not separable. -/
theorem not_isSeparable_maxEntangled {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]
    (hd : 2 ≤ Fintype.card α) : ¬ IsSeparable (maxEntangled : Matrix (α × α) (α × α) ℂ) :=
  not_isSeparable_of_logNeg_pos maxEntangled_isState (logNeg_maxEntangled_pos hd)

end EntMonotone