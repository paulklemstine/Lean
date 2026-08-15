/-
# NET-25 / Catalog·Logic — Dense final-step (EOS) inputs: expressivity-invariance and gain

Formal counterpart of the *boundary half* of the NET-25 law
**DENSE-FINAL-STEP-IS-THE-CURE**.

The decisive experimental control of round-net-25 compared two recurrent answer
paths whose cell and head weights are **byte-identical for a fixed seed**, and
which differ in exactly one architectural variable: the dimension `d` of the
learned end-of-sequence (EOS) vector that is fed at the *final carry step*.

| arm                | EOS dim `d` | params  | n=8 full        |
|--------------------|-------------|---------|-----------------|
| `pad384`  s0..s3   | 384         | 335,242 | 1.0000 × 4      |
| `pad384-zeroEOS`   | 20          | 334,878 | 0.7441 / 0.0259 |
| `pos28`   s0/s1    | 28          | 129,830 | 0.0049 / 0.0049 |
| `raw20-192` s0..s6 | 20          | 125,214 | 0.0806 … 0.0020 |

Since the EOS token is a *single learned vector* `e ∈ ℝ^d`, its whole effect on
the cell is the vector `W e ∈ ℝ^h`, where `W` is the (already present) input
matrix restricted to the EOS columns.  This file proves the two facts that
together turn the empirical law into a mechanism statement.

* **Expressivity invariance** (`boundaryBias_surjective`,
  `boundaryBias_range_eq`, `eos_dimension_no_expressivity_gain`):
  for every `d ≥ 1` the reachable set of boundary contributions is *all* of
  `ℝ^h`.  Widening the EOS from 20 to 384 dimensions adds **no** representable
  function.  Hence the measured flip `0.0259 → 1.0000` is provably *not* a
  capacity/expressivity effect — exactly as the identical-weights control
  suggested, and this refutes any capacity-based reading (H1) at the level of
  the boundary pathway.
* **Gain / conditioning** (`boundaryDrift_eq`, `inner_boundaryDrift`,
  `boundary_gain_ge`, `boundary_gain_ge_card`, `boundary_gain_strict_mono_dim`):
  the *dynamics* are not invariant.  Under gradient flow on the factorised
  parameterisation `v = W e`, the induced velocity of the effective boundary
  bias `v` is `v̇ = -(‖e‖² • g + W Wᵀ g)`, i.e. the update is preconditioned by
  the PSD matrix `‖e‖² I + W Wᵀ`.  With per-coordinate initialisation scale `c`
  the gain is at least `d · c² · ‖g‖²`: **linear in the EOS dimension**.

Conclusion, formally: EOS width is invisible to the function class and visible
to the optimiser.  That is precisely the "boundary-step backprop conditioning"
mechanism hypothesis of the paper, here proved at the level of the induced
gradient flow (the remaining, unproven, step is that this gain is what keeps the
digit readout in-distribution at depth).

Companion file: `Logic.DenseFinalStepCarryChain` (transition half).
-/

import Mathlib

namespace Logic.DenseFinalStep

open Finset Matrix

variable {h d : ℕ}

/-! ## The effective boundary bias -/

/-- The contribution of a learned EOS vector `e ∈ ℝ^d` to the cell's
pre-activation at the final carry step, through the input matrix `W`. -/
def boundaryBias (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ) : Fin h → ℝ :=
  W.mulVec e

/-- **Expressivity invariance, surjectivity form.**  As soon as the EOS input has
at least one dimension, *every* boundary contribution `v ∈ ℝ^h` is realisable. -/
theorem boundaryBias_surjective (hd : 0 < d) (v : Fin h → ℝ) :
    ∃ (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ), boundaryBias W e = v := by
  refine ⟨Matrix.of fun i _ => v i, fun j => if j = ⟨0, hd⟩ then 1 else 0, ?_⟩
  funext i
  simp [boundaryBias, Matrix.mulVec, dotProduct, Finset.sum_ite_eq' univ (⟨0, hd⟩ : Fin d)]

/-- **Expressivity invariance, range form.**  The realisable set of boundary
contributions is the whole space, for every positive EOS width. -/
theorem boundaryBias_range_eq (hd : 0 < d) :
    {v : Fin h → ℝ | ∃ (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ),
        boundaryBias W e = v} = Set.univ := by
  ext v
  simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
  exact boundaryBias_surjective hd v

/-- **No expressivity gain from EOS width.**  For any two positive EOS widths
`d₁, d₂` the realisable boundary contributions coincide.  In particular the
20-dimensional and the 384-dimensional EOS of the identical-weights control span
exactly the same function class. -/
theorem eos_dimension_no_expressivity_gain {d₁ d₂ : ℕ} (h₁ : 0 < d₁) (h₂ : 0 < d₂) :
    {v : Fin h → ℝ | ∃ (W : Matrix (Fin h) (Fin d₁) ℝ) (e : Fin d₁ → ℝ),
        boundaryBias W e = v}
      = {v : Fin h → ℝ | ∃ (W : Matrix (Fin h) (Fin d₂) ℝ) (e : Fin d₂ → ℝ),
        boundaryBias W e = v} := by
  rw [boundaryBias_range_eq h₁, boundaryBias_range_eq h₂]

/-! ## Gradient flow on the factorised boundary bias

With `L` a loss depending on the boundary bias `v = W e` only, write
`g = ∇_v L ∈ ℝ^h`.  The chain rule gives `∇_W L = g eᵀ` and `∇_e L = Wᵀ g`, so
gradient flow is `Ẇ = -g eᵀ`, `ė = -Wᵀ g`, and the induced velocity of `v` is
`v̇ = Ẇ e + W ė`.  We take that expression as the definition and compute it. -/

/-- Induced velocity of the effective boundary bias under gradient flow on the
factors `(W, e)`, with `g` the loss gradient w.r.t. `v = W e`. -/
def boundaryDrift (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ) (g : Fin h → ℝ) :
    Fin h → ℝ :=
  (-(vecMulVec g e)).mulVec e + W.mulVec (-(vecMul g W))

/-- Outer-product identity: `(g eᵀ) e = ‖e‖² g`. -/
theorem vecMulVec_mulVec_self (g : Fin h → ℝ) (e : Fin d → ℝ) :
    (vecMulVec g e).mulVec e = (∑ j, e j ^ 2) • g := by
  funext i
  simp only [Matrix.mulVec, dotProduct, vecMulVec_apply, Pi.smul_apply, smul_eq_mul]
  rw [Finset.sum_mul]
  exact Finset.sum_congr rfl fun j _ => by ring

/-- `W (Wᵀ g) = (W Wᵀ) g`. -/
theorem mulVec_vecMul_eq (W : Matrix (Fin h) (Fin d) ℝ) (g : Fin h → ℝ) :
    W.mulVec (vecMul g W) = (W * Wᵀ).mulVec g := by
  funext i
  simp only [Matrix.mulVec, dotProduct, vecMul, Matrix.mul_apply, Matrix.transpose_apply,
    Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun j _ => by ring

/-- **Closed form of the boundary drift.**  The factorised parameterisation
preconditions the descent direction by the PSD matrix `‖e‖² I + W Wᵀ`. -/
theorem boundaryDrift_eq (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ) (g : Fin h → ℝ) :
    boundaryDrift W e g = -((∑ j, e j ^ 2) • g + (W * Wᵀ).mulVec g) := by
  have h1 : (-(vecMulVec g e)).mulVec e = -((∑ j, e j ^ 2) • g) := by
    rw [Matrix.neg_mulVec, vecMulVec_mulVec_self]
  have h2 : W.mulVec (-(vecMul g W)) = -((W * Wᵀ).mulVec g) := by
    rw [Matrix.mulVec_neg, mulVec_vecMul_eq]
  rw [boundaryDrift, h1, h2, neg_add]

/-- The descent rate of the effective boundary bias along the loss gradient:
`⟨g, -v̇⟩ = ‖e‖²‖g‖² + ‖Wᵀ g‖²`. -/
theorem inner_boundaryDrift (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ) (g : Fin h → ℝ) :
    (∑ i, g i * (-boundaryDrift W e g) i)
      = (∑ j, e j ^ 2) * (∑ i, g i ^ 2) + ∑ j, (vecMul g W) j ^ 2 := by
  have hquad : ∑ i, g i * ((W * Wᵀ).mulVec g) i = ∑ j, (vecMul g W) j ^ 2 := by
    have h1 : ∑ i, g i * ((W * Wᵀ).mulVec g) i = g ⬝ᵥ ((W * Wᵀ) *ᵥ g) := rfl
    rw [h1, Matrix.dotProduct_mulVec, ← Matrix.vecMul_vecMul, ← Matrix.dotProduct_mulVec,
      Matrix.mulVec_transpose]
    simp [dotProduct, sq]
  rw [boundaryDrift_eq, neg_neg]
  calc ∑ i, g i * (((∑ j, e j ^ 2) • g + (W * Wᵀ).mulVec g)) i
      = ∑ i, ((∑ j, e j ^ 2) * g i ^ 2 + g i * ((W * Wᵀ).mulVec g) i) := by
        refine Finset.sum_congr rfl fun i _ => ?_
        simp only [Pi.add_apply, Pi.smul_apply, smul_eq_mul]
        ring
    _ = (∑ i, (∑ j, e j ^ 2) * g i ^ 2) + ∑ i, g i * ((W * Wᵀ).mulVec g) i :=
        Finset.sum_add_distrib
    _ = (∑ j, e j ^ 2) * (∑ i, g i ^ 2) + ∑ j, (vecMul g W) j ^ 2 := by
        rw [← Finset.mul_sum, hquad]

/-- **Boundary gain bound.**  The descent rate on the effective boundary bias is
at least `‖e‖² ‖g‖²`; the `W Wᵀ` term only helps. -/
theorem boundary_gain_ge (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ) (g : Fin h → ℝ) :
    (∑ j, e j ^ 2) * (∑ i, g i ^ 2) ≤ ∑ i, g i * (-boundaryDrift W e g) i := by
  rw [inner_boundaryDrift]
  have : (0 : ℝ) ≤ ∑ j, (vecMul g W) j ^ 2 :=
    Finset.sum_nonneg fun j _ => sq_nonneg _
  linarith

/-- **Dense-EOS gain is linear in the EOS dimension.**  If the EOS vector is
initialised with per-coordinate scale at least `c`, the descent rate on the
boundary bias is at least `d · c² · ‖g‖²`.  This is the formal content of
"the final step's input pathway must be rich": with the *same* cell weights, the
384-dimensional EOS enjoys a `384/20 ≈ 19×` larger boundary gain than the
20-dimensional one. -/
theorem boundary_gain_ge_card (W : Matrix (Fin h) (Fin d) ℝ) (e : Fin d → ℝ)
    (g : Fin h → ℝ) {c : ℝ} (hc : ∀ j, c ≤ |e j|) (hc0 : 0 ≤ c) :
    (d : ℝ) * c ^ 2 * (∑ i, g i ^ 2) ≤ ∑ i, g i * (-boundaryDrift W e g) i := by
  have hnorm : (d : ℝ) * c ^ 2 ≤ ∑ j, e j ^ 2 := by
    have hterm : ∀ j ∈ (univ : Finset (Fin d)), c ^ 2 ≤ e j ^ 2 := by
      intro j _
      have := hc j
      have : c ^ 2 ≤ |e j| ^ 2 := by nlinarith [abs_nonneg (e j)]
      simpa [sq_abs] using this
    have := Finset.sum_le_sum hterm
    simpa [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using this
  have hg : (0 : ℝ) ≤ ∑ i, g i ^ 2 := Finset.sum_nonneg fun i _ => sq_nonneg _
  calc (d : ℝ) * c ^ 2 * (∑ i, g i ^ 2)
      ≤ (∑ j, e j ^ 2) * (∑ i, g i ^ 2) := by nlinarith
    _ ≤ ∑ i, g i * (-boundaryDrift W e g) i := boundary_gain_ge W e g

/-- **Sharpness of the gain bound.**  With `W = 0` the descent rate equals
`‖e‖² ‖g‖²` exactly, so `boundary_gain_ge` cannot be improved in general: the
EOS norm is the whole of the guaranteed gain. -/
theorem boundary_gain_eq_of_W_zero (e : Fin d → ℝ) (g : Fin h → ℝ) :
    ∑ i, g i * (-boundaryDrift (0 : Matrix (Fin h) (Fin d) ℝ) e g) i
      = (∑ j, e j ^ 2) * (∑ i, g i ^ 2) := by
  rw [inner_boundaryDrift]
  simp

/-- Strict monotonicity in the EOS width, for a nonzero gradient and a strictly
positive initialisation scale: widening the EOS strictly increases the
guaranteed boundary gain.  (`d₁ < d₂`, same per-coordinate scale `c > 0`.) -/
theorem boundary_gain_strict_mono_dim {d₁ d₂ : ℕ} (hlt : d₁ < d₂) {c : ℝ} (hc : 0 < c)
    {g : Fin h → ℝ} (hg : ∃ i, g i ≠ 0) :
    (d₁ : ℝ) * c ^ 2 * (∑ i, g i ^ 2) < (d₂ : ℝ) * c ^ 2 * (∑ i, g i ^ 2) := by
  obtain ⟨i, hi⟩ := hg
  have hgpos : 0 < ∑ i, g i ^ 2 :=
    Finset.sum_pos' (fun j _ => sq_nonneg _) ⟨i, Finset.mem_univ i, by positivity⟩
  have hd : (d₁ : ℝ) < d₂ := by exact_mod_cast hlt
  have hc2 : 0 < c ^ 2 := pow_pos hc 2
  exact mul_lt_mul_of_pos_right (mul_lt_mul_of_pos_right hd hc2) hgpos

/-! ## The two halves together -/

/-- **NET-25 boundary dichotomy.**  For any two positive EOS widths the
representable boundary contributions are *identical* (no expressivity gain),
while — with equal per-coordinate initialisation scale `c > 0` and a nonzero
loss gradient — the guaranteed gradient-flow gain on the boundary bias is
*strictly larger* for the wider EOS.  Any measured difference between the two
arms is therefore an optimisation/conditioning effect, never a capacity one. -/
theorem net25_boundary_dichotomy {d₁ d₂ : ℕ} (h₁ : 0 < d₁) (hlt : d₁ < d₂)
    {c : ℝ} (hc : 0 < c) {g : Fin h → ℝ} (hg : ∃ i, g i ≠ 0) :
    ({v : Fin h → ℝ | ∃ (W : Matrix (Fin h) (Fin d₁) ℝ) (e : Fin d₁ → ℝ),
        boundaryBias W e = v}
      = {v : Fin h → ℝ | ∃ (W : Matrix (Fin h) (Fin d₂) ℝ) (e : Fin d₂ → ℝ),
        boundaryBias W e = v})
    ∧ (d₁ : ℝ) * c ^ 2 * (∑ i, g i ^ 2) < (d₂ : ℝ) * c ^ 2 * (∑ i, g i ^ 2) :=
  ⟨eos_dimension_no_expressivity_gain h₁ (h₁.trans hlt),
    boundary_gain_strict_mono_dim hlt hc hg⟩

/-! ## Gradient flow: exponential contraction at a rate linear in the EOS width

We now close the loop: the `d`-linear gain of `boundary_gain_ge_card` is fed into a
Grönwall argument, giving an explicit contraction rate for the effective boundary
bias and hence an explicit *training-budget* prediction — the sufficient budget
shrinks like `1 / d`.  This is the falsifiable sharpening of the paper's open
item "threshold 28–384 untested". -/

/-- Half the squared distance of the boundary bias to its target. -/
noncomputable def boundaryLoss {h : ℕ} (v vstar : Fin h → ℝ) : ℝ :=
  (1 / 2) * ∑ i, (v i - vstar i) ^ 2

/-- **Exponential contraction of the boundary bias.**  If along a differentiable
trajectory `v` with velocity `w` the descent rate on the quadratic boundary loss
is at least `κ` times the squared residual, then the loss decays at rate
`exp (-2 κ t)`. -/
theorem boundaryLoss_exp_decay {h : ℕ} (v w : ℝ → Fin h → ℝ) (vstar : Fin h → ℝ) (κ : ℝ)
    (hv : ∀ t i, HasDerivAt (fun s => v s i) (w t i) t)
    (hgain : ∀ t, κ * ∑ i, (v t i - vstar i) ^ 2 ≤ ∑ i, (v t i - vstar i) * (-(w t i)))
    {t : ℝ} (ht : 0 ≤ t) :
    boundaryLoss (v t) vstar ≤ boundaryLoss (v 0) vstar * Real.exp (-(2 * κ * t)) := by
  set L : ℝ → ℝ := fun s => (1 / 2) * ∑ i, (v s i - vstar i) ^ 2 with hL
  have hLderiv : ∀ s, HasDerivAt L (∑ i, (v s i - vstar i) * w s i) s := by
    intro s
    have hstep : ∀ i : Fin h, HasDerivAt (fun r => (v r i - vstar i) ^ 2)
        (2 * (v s i - vstar i) * w s i) s := by
      intro i
      have h0 : HasDerivAt (fun r => v r i - vstar i) (w s i) s := (hv s i).sub_const (vstar i)
      simpa using h0.pow 2
    have h1 : HasDerivAt (fun r => ∑ i, (v r i - vstar i) ^ 2)
        (∑ i, 2 * (v s i - vstar i) * w s i) s := HasDerivAt.fun_sum (fun i _ => hstep i)
    have h2 := h1.const_mul (1 / 2 : ℝ)
    convert h2 using 1
    rw [Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring
  set F : ℝ → ℝ := fun s => L s * Real.exp (2 * κ * s) with hF
  have hFderiv : ∀ s, HasDerivAt F
      ((∑ i, (v s i - vstar i) * w s i) * Real.exp (2 * κ * s)
        + L s * (Real.exp (2 * κ * s) * (2 * κ))) s := by
    intro s
    have hexp : HasDerivAt (fun r => Real.exp (2 * κ * r))
        (Real.exp (2 * κ * s) * (2 * κ)) s := by
      have := (hasDerivAt_id s).const_mul (2 * κ)
      simpa [mul_comm] using this.exp
    exact (hLderiv s).mul hexp
  have hFnonpos : ∀ s, deriv F s ≤ 0 := by
    intro s
    rw [(hFderiv s).deriv]
    have hg := hgain s
    have hsum : (∑ i, (v s i - vstar i) * w s i) ≤ -(κ * ∑ i, (v s i - vstar i) ^ 2) := by
      have hneg : ∑ i, (v s i - vstar i) * (-(w s i)) = -∑ i, (v s i - vstar i) * w s i := by
        rw [← Finset.sum_neg_distrib]
        exact Finset.sum_congr rfl fun i _ => by ring
      linarith [hneg ▸ hg]
    have hexppos : 0 < Real.exp (2 * κ * s) := Real.exp_pos _
    have h3 := mul_le_mul_of_nonneg_right hsum (le_of_lt hexppos)
    have hLs : L s = (1 / 2) * ∑ i, (v s i - vstar i) ^ 2 := rfl
    rw [hLs]
    nlinarith [h3]
  have hanti : Antitone F :=
    antitone_of_deriv_nonpos (fun s => (hFderiv s).differentiableAt) hFnonpos
  have hkey : L t * Real.exp (2 * κ * t) ≤ L 0 := by simpa [hF] using hanti ht
  have hEpos : (0 : ℝ) < Real.exp (2 * κ * t) := Real.exp_pos _
  have hfin : L t ≤ L 0 * Real.exp (-(2 * κ * t)) := by
    rw [Real.exp_neg]
    have h4 : L t = (L t * Real.exp (2 * κ * t)) * (Real.exp (2 * κ * t))⁻¹ := by field_simp
    calc L t = (L t * Real.exp (2 * κ * t)) * (Real.exp (2 * κ * t))⁻¹ := h4
      _ ≤ L 0 * (Real.exp (2 * κ * t))⁻¹ := mul_le_mul_of_nonneg_right hkey (by positivity)
  simpa [boundaryLoss, hL] using hfin

/-- **Dense-EOS contraction.**  If the boundary bias evolves by the factorised
gradient flow `boundaryDrift` with an EOS vector whose coordinates never fall
below scale `c`, the quadratic boundary loss contracts at rate `2 d c²`:
*the contraction exponent is linear in the EOS width.* -/
theorem dense_eos_exp_decay {h d : ℕ} (v : ℝ → Fin h → ℝ) (w : ℝ → Fin h → ℝ)
    (vstar : Fin h → ℝ) (W : ℝ → Matrix (Fin h) (Fin d) ℝ) (e : ℝ → Fin d → ℝ) {c : ℝ}
    (hc0 : 0 ≤ c) (hc : ∀ t j, c ≤ |e t j|)
    (hv : ∀ t i, HasDerivAt (fun s => v s i) (w t i) t)
    (hflow : ∀ t, w t = boundaryDrift (W t) (e t) (fun i => v t i - vstar i))
    {t : ℝ} (ht : 0 ≤ t) :
    boundaryLoss (v t) vstar
      ≤ boundaryLoss (v 0) vstar * Real.exp (-(2 * ((d : ℝ) * c ^ 2) * t)) := by
  refine boundaryLoss_exp_decay v w vstar ((d : ℝ) * c ^ 2) hv (fun s => ?_) ht
  have hgain := boundary_gain_ge_card (W s) (e s) (fun i => v s i - vstar i)
    (fun j => hc s j) hc0
  have hrw : ∑ i, (v s i - vstar i) * (-(w s i))
      = ∑ i, (fun i => v s i - vstar i) i
          * (-boundaryDrift (W s) (e s) (fun i => v s i - vstar i)) i := by
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [hflow s]
    rfl
  rw [hrw]
  calc (d : ℝ) * c ^ 2 * ∑ i, (v s i - vstar i) ^ 2
      = (d : ℝ) * c ^ 2 * ∑ i, ((fun i => v s i - vstar i) i) ^ 2 := rfl
    _ ≤ _ := hgain

/-- **Budget law.**  With contraction rate `2 κ > 0`, a training time
`t ≥ log (L₀ / ε) / (2 κ)` already brings the boundary loss below `ε`.
Instantiated at `κ = d c²` (`dense_eos_exp_decay`), the sufficient budget scales
like `1 / d`: this is the falsifiable prediction replacing the untested
"threshold between 28 and 384". -/
theorem boundary_budget_sufficient {L₀ ε κ t : ℝ} (hL₀ : 0 < L₀) (hε : 0 < ε) (hκ : 0 < κ)
    (ht : Real.log (L₀ / ε) / (2 * κ) ≤ t) :
    L₀ * Real.exp (-(2 * κ * t)) ≤ ε := by
  have h2κ : 0 < 2 * κ := by linarith
  have hlog : Real.log (L₀ / ε) ≤ 2 * κ * t := by
    rw [div_le_iff₀ h2κ] at ht
    linarith [ht]
  have hpos : 0 < L₀ / ε := div_pos hL₀ hε
  have hexp : Real.exp (-(2 * κ * t)) ≤ Real.exp (-Real.log (L₀ / ε)) :=
    Real.exp_le_exp.mpr (by linarith)
  have hval : Real.exp (-Real.log (L₀ / ε)) = ε / L₀ := by
    rw [Real.exp_neg, Real.exp_log hpos]
    field_simp
  calc L₀ * Real.exp (-(2 * κ * t)) ≤ L₀ * Real.exp (-Real.log (L₀ / ε)) := by nlinarith
    _ = L₀ * (ε / L₀) := by rw [hval]
    _ = ε := by field_simp

/-- The sufficient training budget is strictly decreasing in the EOS width:
for `d₁ < d₂` and fixed initialisation scale `c > 0`, target `ε` and initial loss
`L₀ > ε`, the budget `log (L₀/ε) / (2 d c²)` is strictly smaller for `d₂`. -/
theorem boundary_budget_strict_anti_dim {d₁ d₂ : ℕ} (h₁ : 0 < d₁) (hlt : d₁ < d₂)
    {c L₀ ε : ℝ} (hc : 0 < c) (hε : 0 < ε) (hL₀ : ε < L₀) :
    Real.log (L₀ / ε) / (2 * ((d₂ : ℝ) * c ^ 2))
      < Real.log (L₀ / ε) / (2 * ((d₁ : ℝ) * c ^ 2)) := by
  have hc2 : 0 < c ^ 2 := pow_pos hc 2
  have hd₁ : (0 : ℝ) < d₁ := by exact_mod_cast h₁
  have hd : (d₁ : ℝ) < d₂ := by exact_mod_cast hlt
  have hlogpos : 0 < Real.log (L₀ / ε) := Real.log_pos (by rw [lt_div_iff₀ hε]; linarith)
  have hden₁ : 0 < 2 * ((d₁ : ℝ) * c ^ 2) := by positivity
  have hden : 2 * ((d₁ : ℝ) * c ^ 2) < 2 * ((d₂ : ℝ) * c ^ 2) := by nlinarith
  exact div_lt_div_of_pos_left hlogpos hden₁ hden

/-! ## Lab notes (round-net-25, measured)

`pad384` vs `pad384-zeroEOS`: identical GRUCell/head weights per seed
(construction order matches), differing only in the EOS parameter count
(384-d vs 20-d), giving `n = 8` full accuracy `1.0000` vs `0.7441 / 0.0259`.
`cap384-raw` (471,582 params, 20-d EOS) fails at `0.0078 / 0.0063`, so raw
parameter count is not the lever; `pos28` (28-d EOS) fails at `0.0049`, so the
threshold lies strictly between 28 and 384 and position information is not the
lever.  The theorems above show why width can matter at all *only* through the
optimisation geometry: the realisable set is width-independent
(`eos_dimension_no_expressivity_gain`) while the boundary gain grows like `d`
(`boundary_gain_ge_card`).  With `c` fixed, `d = 20 → 384` multiplies the
guaranteed gain by `19.2`.
-/

end Logic.DenseFinalStep