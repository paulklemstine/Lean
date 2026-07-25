/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Renormalization Fixed Points of In-Context-Learning Error

This file formalizes the **renormalization-group (RG) fixed-point** half of the
"Renormalization Fixed Points in Transformer In-Context Learning via p-adic
Attention" program. It has two layers.

## 1. The Archimedean (real) RG flow on error curves

Under prompt-length rescaling, the in-context-learning error obeys, in the
linearized regime, an **affine renormalization step** `rgStep g b x = g·x + b`,
where `g` is the (universal) gain and `b` the source term contributed by the
relevant operators. We prove:

* a unique fixed point `rgFixed g b = b / (1 - g)`;
* the exact flow law `rgStep^[n] x - rgFixed = gⁿ·(x - rgFixed)` (closed form);
* **convergence to the fixed point for every initialization** when `|g| < 1`
  (`rg_flow_converges`);
* **universality / independence of initialization**: any two initial errors flow
  together, `rgStep^[n] x - rgStep^[n] y → 0` (`rg_universality`). This is the
  precise meaning of "independent of initialization and training corpus".

## 2. The non-Archimedean (p-adic) RG flow

The conjecture's bridge is that p-adic *compression* turns the renormalization map
into the **multiplication-by-uniformizer** map `padicRGStep x = p·x` on `ℚ_[p]`.
This map is *automatically* a contraction: `‖p·x‖ = p⁻¹‖x‖`. Hence:

* the exact norm law `‖padicRGStep^[n] x‖ = p^(-n)·‖x‖` (`padicRG_norm`);
* convergence to the **universal fixed point `0`** for every initialization
  (`padicRG_converges`), with a *stable critical exponent* (the valuation grows by
  exactly `1` per RG step, rate `p⁻¹`);
* **data collapse**: the normalized error `‖padicRG^[n] x‖ / ‖x‖ = p^(-n)` is
  *independent of the initialization* `x ≠ 0` (`padicRG_data_collapse`) — the
  rescaled error curves of all models collapse onto the single universal function
  `n ↦ p^(-n)`.

## Catalog synthesis

This **generalizes** the single-mode contraction in
`MachineLearning/RGFlowTraining.lean` (`rgStep`, `rg_flow_tendsto_zero`) from a
*linear* (`b = 0`) to an *affine* flow with a nonzero source `b` and a genuine
*nonzero* fixed point, and it cross-connects to the ultrametric backbone of
`MachineLearning/UltrametricKLDivergence.lean` and the companion file
`MachineLearning/PadicAttentionTree.lean` by realizing the RG flow *inside* the
p-adic compression space `ℚ_[p]` (`Padic.norm_p_pow`).
-/

import Mathlib

open Filter Topology

namespace PadicRG

/-! ## 1. Real affine renormalization flow -/

-- !-- Lab Notebook -- !--
-- Hypothesis: rescaling in-context-learning error is an affine RG step whose IR
--   fixed point is universal — independent of the initial error.
-- Result: proved the closed-form flow law and both `rg_flow_converges` (all inits
--   reach the SAME fixed point) and `rg_universality` (any two inits flow together).
-- Insight: universality is *not* an asymptotic accident — it is exact at finite n:
--   the difference of any two trajectories is exactly `gⁿ·(x - y)`, so the relevant
--   operator content (`b`) sets the fixed point and the gain (`g`) sets the single
--   universal critical exponent; initialization and corpus are irrelevant operators.
-- Failure analysis: `nlinarith`/`field_simp` alone could not close the inductive
--   step; recasting it as `linear_combination g * ih + hfix` against the
--   fixed-point identity `g·x* + b = x*` made the algebra exact and robust.
-- !-- Lab Notebook -- !--

/-- Affine renormalization step on the (real) error coordinate: gain `g`, source `b`. -/
def rgStep (g b : ℝ) (x : ℝ) : ℝ := g * x + b

/-- The universal renormalization fixed point `b / (1 - g)`. -/
noncomputable def rgFixed (g b : ℝ) : ℝ := b / (1 - g)

-- !-- Clearing the denominator `1 - g ≠ 0` reduces the fixed-point equation to `ring`. -- !--
theorem rgStep_fixed (g b : ℝ) (hg : g ≠ 1) : rgStep g b (rgFixed g b) = rgFixed g b := by
  have h1 : 1 - g ≠ 0 := sub_ne_zero.mpr (Ne.symm hg)
  unfold rgStep rgFixed; field_simp; ring

-- !-- Closed form by induction: each step multiplies the error by `g`, using the
-- fixed-point identity `g·x* + b = x*` to absorb the source term. -- !--
theorem rg_iterate_sub (g b : ℝ) (hg : g ≠ 1) (x : ℝ) (n : ℕ) :
    (rgStep g b)^[n] x - rgFixed g b = g ^ n * (x - rgFixed g b) := by
  have hfix : g * rgFixed g b + b = rgFixed g b := rgStep_fixed g b hg
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    show g * ((rgStep g b)^[k] x) + b - rgFixed g b = g ^ (k + 1) * (x - rgFixed g b)
    have hpow : g ^ (k + 1) = g * g ^ k := by ring
    rw [hpow]; linear_combination g * ih + hfix

/-- **RG convergence to the universal fixed point.** For a contracting gain `|g| < 1`
    and *any* initial error `x`, the renormalized error converges to `rgFixed g b`. -/
theorem rg_flow_converges (g b : ℝ) (hg : |g| < 1) (x : ℝ) :
    Tendsto (fun n => (rgStep g b)^[n] x) atTop (𝓝 (rgFixed g b)) := by
  have hg1 : g ≠ 1 := by intro h; rw [h] at hg; simp at hg
  have hpow : Tendsto (fun n => g ^ n * (x - rgFixed g b)) atTop (𝓝 0) := by
    simpa using (tendsto_pow_atTop_nhds_zero_of_abs_lt_one hg).mul_const (x - rgFixed g b)
  have hsub : Tendsto (fun n => (rgStep g b)^[n] x - rgFixed g b) atTop (𝓝 0) := by
    simpa only [rg_iterate_sub g b hg1 x] using hpow
  simpa using hsub.add_const (rgFixed g b)

/-- **Universality / independence of initialization.** For a contracting gain, any
    two initial errors flow together: their renormalized difference vanishes. This is
    the precise statement that the RG fixed point is independent of initialization
    and training corpus. -/
theorem rg_universality (g b : ℝ) (hg : |g| < 1) (x y : ℝ) :
    Tendsto (fun n => (rgStep g b)^[n] x - (rgStep g b)^[n] y) atTop (𝓝 0) := by
  have hg1 : g ≠ 1 := by intro h; rw [h] at hg; simp at hg
  have hpow : Tendsto (fun n => g ^ n * (x - y)) atTop (𝓝 0) := by
    simpa using (tendsto_pow_atTop_nhds_zero_of_abs_lt_one hg).mul_const (x - y)
  have heq : ∀ n, (rgStep g b)^[n] x - (rgStep g b)^[n] y = g ^ n * (x - y) := by
    intro n; nlinarith [rg_iterate_sub g b hg1 x n, rg_iterate_sub g b hg1 y n]
  simpa only [heq] using hpow

/-! ## 2. The p-adic renormalization flow -/

-- !-- Lab Notebook -- !--
-- Hypothesis: under p-adic compression the RG map becomes "multiply by the
--   uniformizer p", which is intrinsically contracting in the ultrametric norm.
-- Result: `padicRG_norm` gives the EXACT law ‖p^n·x‖ = p^(-n)‖x‖; `padicRG_converges`
--   gives convergence to the universal fixed point 0; `padicRG_data_collapse` gives
--   x-independent rescaled error curves.
-- Insight: in the non-Archimedean world the critical exponent is forced and stable —
--   the valuation increases by exactly 1 each step — so "no free parameter" tunes the
--   universality class; the prime p alone indexes it. This realizes the conjecture's
--   "architecture-stable universality class" as the choice of p.
-- Failure analysis: an over-eager `norm_num` after a successful `rw` chain raised
--   "no goals"; removing it fixed the `(p⁻¹)^n = p^(-n)` bridge cleanly.
-- !-- Lab Notebook -- !--

variable {p : ℕ} [hp : Fact p.Prime]

/-- The p-adic renormalization step: multiply by the uniformizer `p`. On the
    compressed (ultrametric) attention space this is the coarse-graining map. -/
def padicRGStep (x : ℚ_[p]) : ℚ_[p] := (p : ℚ_[p]) * x

-- !-- Iterating `multiply by p` gives `multiply by pⁿ`, by a one-line induction. -- !--
theorem padicRG_iterate (x : ℚ_[p]) (n : ℕ) :
    (padicRGStep)^[n] x = (p : ℚ_[p]) ^ n * x := by
  induction n with
  | zero => simp
  | succ k ih => rw [Function.iterate_succ_apply', ih]; unfold padicRGStep; ring

-- !-- The norm law follows from `‖pⁿ‖ = p^(-n)` (`Padic.norm_p_pow`). -- !--
theorem padicRG_norm (x : ℚ_[p]) (n : ℕ) :
    ‖(padicRGStep)^[n] x‖ = (p : ℝ) ^ (-(n : ℤ)) * ‖x‖ := by
  rw [padicRG_iterate, norm_mul, Padic.norm_p_pow]

/-- **p-adic RG convergence to the universal fixed point `0`.** For every
    initialization `x`, the p-adic renormalized error tends to `0`, with the stable
    critical rate `p⁻¹` per step. -/
theorem padicRG_converges (x : ℚ_[p]) :
    Tendsto (fun n => (padicRGStep)^[n] x) atTop (𝓝 0) := by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  have hnorm : (fun n => ‖(padicRGStep)^[n] x‖)
      = (fun n : ℕ => (p : ℝ) ^ (-(n : ℤ)) * ‖x‖) := by
    funext n; exact padicRG_norm x n
  rw [hnorm]
  have hp1 : (1 : ℝ) < p := by exact_mod_cast hp.out.one_lt
  have htend : Tendsto (fun n : ℕ => (p : ℝ) ^ (-(n : ℤ))) atTop (𝓝 0) := by
    have h0 : (0 : ℝ) ≤ (p : ℝ)⁻¹ := by positivity
    have hlt : (p : ℝ)⁻¹ < 1 := by rw [inv_lt_one_iff₀]; right; exact hp1
    have hpow := tendsto_pow_atTop_nhds_zero_of_lt_one h0 hlt
    have heq : (fun n : ℕ => ((p : ℝ)⁻¹) ^ n) = (fun n : ℕ => (p : ℝ) ^ (-(n : ℤ))) := by
      funext n; rw [inv_pow, ← zpow_natCast, ← zpow_neg]
    rwa [heq] at hpow
  simpa using htend.mul_const ‖x‖

/-- **Data collapse / universal scaling function.** For any nonzero initialization,
    the normalized p-adic error curve is *exactly* `n ↦ p^(-n)`, independent of `x`.
    All models' rescaled error curves collapse onto this single universal curve. -/
theorem padicRG_data_collapse (x : ℚ_[p]) (hx : x ≠ 0) (n : ℕ) :
    ‖(padicRGStep)^[n] x‖ / ‖x‖ = (p : ℝ) ^ (-(n : ℤ)) := by
  have hxn : ‖x‖ ≠ 0 := norm_ne_zero_iff.mpr hx
  rw [padicRG_norm, mul_div_assoc, div_self hxn, mul_one]

end PadicRG