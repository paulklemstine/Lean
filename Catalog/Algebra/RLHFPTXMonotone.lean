import Algebra.RLHFPTXExistence

/-!
# Comparative statics of the pretraining coefficient

For the PPO-ptx objective `J_γ(q) = objective β r p q + γ · ∑ d log q`, existence and uniqueness
of the optimum `q*_γ` are established in `Algebra.RLHFPTXExistence`.  This file describes how
that optimum, and the optimal value, move as the mix-in coefficient `γ` varies.  Everything is
derived from the two optimality inequalities alone (a Topkis-style argument), so no
differentiability of `γ ↦ q*_γ` is needed:

* `RLHF.ptx_crossentropy_mono` — the pretraining cross-entropy term `∑ d log q*_γ` is
  **monotonically increasing** in `γ`: a larger mix-in genuinely buys a better pretraining fit;
* `RLHF.ptx_rlhf_part_anti` — the pure RLHF part `𝔼[r] − β KL(·‖p)` is **monotonically
  decreasing** in `γ`: this is the *alignment tax*, and it is paid monotonically;
* `RLHF.ptx_value_anti` — the optimal PTX value itself is decreasing in `γ`;
* `RLHF.ptx_value_convex` — the optimal value is a **convex** function of `γ` (an envelope
  theorem: a maximum of affine functions of `γ`).
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-- Shorthand: the pretraining cross-entropy term of the PTX objective. -/
noncomputable def ptxTerm (d q : Ω → ℝ) : ℝ := ∑ y, d y * Real.log (q y)

omit [Nonempty Ω] in
theorem objectivePTX_eq_add_ptxTerm {β γ : ℝ} {r p d q : Ω → ℝ} :
    objectivePTX β γ r p d q = objective β r p q + γ * ptxTerm d q := rfl

omit [Nonempty Ω] in
/-- **Monotone comparative statics.**  Raising the pretraining coefficient improves the
pretraining cross-entropy of the optimal policy. -/
theorem ptx_crossentropy_mono {β γ₁ γ₂ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hγ : γ₁ < γ₂)
    (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂)
    (hmax₁ : ∀ q, IsPosDist q → objectivePTX β γ₁ r p d q ≤ objectivePTX β γ₁ r p d q₁)
    (hmax₂ : ∀ q, IsPosDist q → objectivePTX β γ₂ r p d q ≤ objectivePTX β γ₂ r p d q₂) :
    ptxTerm d q₁ ≤ ptxTerm d q₂ := by
  have hA := hmax₁ q₂ h₂
  have hB := hmax₂ q₁ h₁
  rw [objectivePTX_eq_add_ptxTerm, objectivePTX_eq_add_ptxTerm] at hA hB
  -- adding the two optimality inequalities cancels the RLHF parts
  have hsum : (γ₂ - γ₁) * ptxTerm d q₁ ≤ (γ₂ - γ₁) * ptxTerm d q₂ := by nlinarith [hA, hB]
  have hpos : 0 < γ₂ - γ₁ := by linarith
  exact le_of_mul_le_mul_left (by linarith [hsum]) hpos

omit [Nonempty Ω] in
/-- **The alignment tax is monotone.**  Raising the pretraining coefficient strictly costs on
the reward-minus-KL part of the objective. -/
theorem ptx_rlhf_part_anti {β γ₁ γ₂ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hγ : γ₁ < γ₂) (hγ₁ : 0 ≤ γ₁)
    (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂)
    (hmax₁ : ∀ q, IsPosDist q → objectivePTX β γ₁ r p d q ≤ objectivePTX β γ₁ r p d q₁)
    (hmax₂ : ∀ q, IsPosDist q → objectivePTX β γ₂ r p d q ≤ objectivePTX β γ₂ r p d q₂) :
    objective β r p q₂ ≤ objective β r p q₁ := by
  have hmono := ptx_crossentropy_mono hγ h₁ h₂ hmax₁ hmax₂
  have hA := hmax₁ q₂ h₂
  rw [objectivePTX_eq_add_ptxTerm, objectivePTX_eq_add_ptxTerm] at hA
  nlinarith [hA, hmono, mul_le_mul_of_nonneg_left hmono hγ₁]

omit [Nonempty Ω] in
/-- The optimal PTX value decreases as the mix-in coefficient grows (the pretraining term is
nonpositive on probability distributions).  Stated in the strong form: the value at `γ₁` of an
optimal policy for `γ₁` dominates the `γ₂`-value of *every* positive policy. -/
theorem ptx_value_anti {β γ₁ γ₂ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hγ : γ₁ ≤ γ₂) (hd : ∀ y, 0 ≤ d y)
    (h₂ : IsPosDist q₂)
    (hmax₁ : ∀ q, IsPosDist q → objectivePTX β γ₁ r p d q ≤ objectivePTX β γ₁ r p d q₁) :
    objectivePTX β γ₂ r p d q₂ ≤ objectivePTX β γ₁ r p d q₁ := by
  -- the pretraining term is `≤ 0` since every probability mass is `≤ 1`
  have hq1 : ∀ y, q₂ y ≤ 1 := by
    intro y
    have hnn : ∀ z ∈ (univ : Finset Ω), 0 ≤ q₂ z := fun z _ => (h₂.1 z).le
    have := Finset.single_le_sum hnn (mem_univ y)
    rwa [h₂.2] at this
  have hterm : ptxTerm d q₂ ≤ 0 :=
    Finset.sum_nonpos fun y _ =>
      mul_nonpos_of_nonneg_of_nonpos (hd y) (Real.log_nonpos (h₂.1 y).le (hq1 y))
  have hstep : objectivePTX β γ₂ r p d q₂ ≤ objectivePTX β γ₁ r p d q₂ := by
    rw [objectivePTX_eq_add_ptxTerm, objectivePTX_eq_add_ptxTerm]
    nlinarith [hterm, mul_le_mul_of_nonpos_right hγ hterm]
  exact le_trans hstep (hmax₁ q₂ h₂)

omit [Nonempty Ω] in
/-- **Envelope theorem.**  The optimal PTX value is a convex function of the mix-in
coefficient: it is a maximum of functions affine in `γ`. -/
theorem ptx_value_convex {β γ₁ γ₂ θ : ℝ} {r p d q₁ q₂ qθ : Ω → ℝ} (h0 : 0 ≤ θ) (h1 : θ ≤ 1)
    (hθ : IsPosDist qθ)
    (hmax₁ : ∀ q, IsPosDist q → objectivePTX β γ₁ r p d q ≤ objectivePTX β γ₁ r p d q₁)
    (hmax₂ : ∀ q, IsPosDist q → objectivePTX β γ₂ r p d q ≤ objectivePTX β γ₂ r p d q₂) :
    objectivePTX β (θ * γ₁ + (1 - θ) * γ₂) r p d qθ
      ≤ θ * objectivePTX β γ₁ r p d q₁ + (1 - θ) * objectivePTX β γ₂ r p d q₂ := by
  have hsplit : objectivePTX β (θ * γ₁ + (1 - θ) * γ₂) r p d qθ
      = θ * objectivePTX β γ₁ r p d qθ + (1 - θ) * objectivePTX β γ₂ r p d qθ := by
    rw [objectivePTX_eq_add_ptxTerm, objectivePTX_eq_add_ptxTerm, objectivePTX_eq_add_ptxTerm]
    ring
  have hA := hmax₁ qθ hθ
  have hB := hmax₂ qθ hθ
  rw [hsplit]
  have h1' : (0:ℝ) ≤ 1 - θ := by linarith
  nlinarith [mul_le_mul_of_nonneg_left hA h0, mul_le_mul_of_nonneg_left hB h1']

end RLHF