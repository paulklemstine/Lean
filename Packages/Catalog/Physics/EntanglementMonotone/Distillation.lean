import Physics.EntanglementMonotone.Additivity
import Physics.EntanglementMonotone.DimensionBound

/-!
# An operational corollary: exact PPT distillation rates

Monotonicity (`EntMonotone.logNeg_mono`), additivity
(`EntMonotone.logNeg_tensorBipartite`) and the exact value of the logarithmic negativity of
the maximally entangled state (`EntMonotone.logNeg_maxEntangled`) combine into an operational
statement about entanglement distillation:

> if a PPT operation (in particular an LOCC protocol) turns `ρ ⊗ σ` **exactly** into a
> maximally entangled state of local dimension `D`, then `log D ≤ E_N(ρ) + E_N(σ)`.

Specialising to `σ = ρ` on `ℂ^d ⊗ ℂ^d` gives the two-copy rate bound `log d ≤ E_N(ρ)`: no
protocol can exactly distil more than `E_N` ebits per copy.  In particular a PPT input, for
which `E_N = 0`, yields no maximal entanglement at all — the bound-entanglement obstruction.
-/

namespace EntMonotone

open Matrix Kronecker ComplexOrder
open scoped MatrixOrder

section Distillation

variable {α γ : Type*} [Fintype α] [DecidableEq α] [Fintype γ] [DecidableEq γ]

/-- **Exact PPT distillation rate bound.**  If a PPT operation maps `ρ ⊗ σ` exactly onto the
maximally entangled state of the composite local system, then the amount of entanglement
produced, `log (dim α · dim γ)`, is at most `E_N(ρ) + E_N(σ)`. -/
theorem log_dim_le_logNeg_add_of_exact_distillation [Nonempty α] [Nonempty γ]
    {ρ : Matrix (α × α) (α × α) ℂ} {σ : Matrix (γ × γ) (γ × γ) ℂ}
    (hρ : IsState ρ) (hσ : IsState σ)
    {Λ : Matrix ((α × γ) × (α × γ)) ((α × γ) × (α × γ)) ℂ →
      Matrix ((α × γ) × (α × γ)) ((α × γ) × (α × γ)) ℂ}
    (hΛ : IsPPTOperation Λ)
    (hdist : Λ (tensorBipartite ρ σ) = maxEntangled) :
    Real.log ((Fintype.card α : ℝ) * (Fintype.card γ : ℝ)) ≤ logNeg ρ + logNeg σ := by
  have hstate := tensorBipartite_isState hρ hσ
  have hmono := logNeg_mono hΛ hstate
  rw [hdist, logNeg_maxEntangled, logNeg_tensorBipartite hρ hσ] at hmono
  refine le_trans (le_of_eq ?_) hmono
  rw [Fintype.card_prod]
  push_cast
  ring

/-- **Two-copy rate bound.**  Exactly distilling a maximally entangled state of local
dimension `d²` from two copies of a state on `ℂ^d ⊗ ℂ^d` requires `E_N(ρ) ≥ log d`: the
logarithmic negativity is an upper bound on the exact PPT distillation rate. -/
theorem log_card_le_logNeg_of_exact_two_copy_distillation [Nonempty α]
    {ρ : Matrix (α × α) (α × α) ℂ} (hρ : IsState ρ)
    {Λ : Matrix ((α × α) × (α × α)) ((α × α) × (α × α)) ℂ →
      Matrix ((α × α) × (α × α)) ((α × α) × (α × α)) ℂ}
    (hΛ : IsPPTOperation Λ)
    (hdist : Λ (tensorBipartite ρ ρ) = maxEntangled) :
    Real.log (Fintype.card α : ℝ) ≤ logNeg ρ := by
  have h := log_dim_le_logNeg_add_of_exact_distillation hρ hρ hΛ hdist
  rw [show ((Fintype.card α : ℝ) * (Fintype.card α : ℝ)) = (Fintype.card α : ℝ) ^ 2 by ring,
    Real.log_pow] at h
  push_cast at h
  linarith

/-- **Bound entanglement obstruction.**  A PPT state is useless for exact distillation: no
PPT operation turns two copies of it into a maximally entangled state of local dimension at
least `2`. -/
theorem no_exact_distillation_from_isPPT [Nonempty α] (hd : 2 ≤ Fintype.card α)
    {ρ : Matrix (α × α) (α × α) ℂ} (hρ : IsState ρ) (hppt : IsPPT ρ)
    {Λ : Matrix ((α × α) × (α × α)) ((α × α) × (α × α)) ℂ →
      Matrix ((α × α) × (α × α)) ((α × α) × (α × α)) ℂ}
    (hΛ : IsPPTOperation Λ) :
    Λ (tensorBipartite ρ ρ) ≠ maxEntangled := by
  intro hdist
  have h := log_card_le_logNeg_of_exact_two_copy_distillation hρ hΛ hdist
  rw [logNeg_eq_zero_of_isPPT hρ hppt] at h
  have hlog : 0 < Real.log (Fintype.card α : ℝ) := by
    refine Real.log_pos ?_
    have : (2 : ℝ) ≤ (Fintype.card α : ℝ) := by exact_mod_cast hd
    linarith
  linarith

end Distillation

end EntMonotone