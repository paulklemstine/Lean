/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

-- This file develops the RG-flow viewpoint on top of the spectral picture in
-- `MachineLearning/NTKSpectral.lean`; the relevant results there
-- (`ntkGram`, `ntk_mode_decay`, `ntk_optimal_tendsto_zero`) are referenced in the
-- docstrings. The development below is self-contained (`import Mathlib` only).

/-!
# Neural Network Training as Renormalization-Group Flow

This file formalizes the **renormalization-group (RG) picture of gradient-based
training** in the linearized / Neural-Tangent-Kernel (NTK) regime, building
directly on `Catalog/MachineLearning/NTKSpectral.lean`.

## The physical picture

In the NTK regime the training residual `r` evolves by `r_{k+1} = (I - η Θ) r_k`
with `Θ = JᵀJ` the NTK Gram matrix (cf. `NTKSpectral.ntkGram`). Diagonalizing `Θ`
turns the matrix recurrence into independent scalar modes, each rescaled by its
**gain** `g_i = 1 - η λ_i` (cf. `NTKSpectral.ntk_mode_decay`).

A single training step is therefore a *diagonal flow* `rgStep` on mode space that
rescales mode `i` by `g_i`. This is precisely a **renormalization-group step**:

* iterating the step is a discrete RG semigroup (`rgStep_semigroup`);
* modes with large NTK eigenvalue have small gain and decay fastest — these are
  the **high-frequency / irrelevant** directions that training "integrates out"
  (`rg_scale_separation`);
* the surviving **relevant** directions are the slow modes, and the RG flow runs
  to an **IR fixed point** which is exactly the kernel of the NTK
  (`rgStep_fixed_iff`);
* when every mode is contracting, the flow converges to that fixed point
  (`rg_flow_tendsto_zero`), a multi-mode generalization of
  `NTKSpectral.ntk_optimal_tendsto_zero`.

## Main results

* `rgStep_iterate` — closed form of the diagonal RG flow: `(rgStep)^[k] v i = g_i^k v_i`.
* `rgStep_semigroup` — the RG/training steps form a discrete one-parameter
  semigroup: coarse-graining to scale `k+m` = scale `m` then scale `k`.
* `rg_scale_separation` — **separation of scales**: a faster-contracting
  (higher-frequency) mode becomes negligible relative to a slower one; its
  amplitude ratio tends to `0`. This is the RG act of *integrating out* fast modes.
* `rgStep_fixed_iff` — the **IR fixed points** of the training flow are exactly the
  residuals annihilated by every active NTK eigenvalue (the NTK kernel).
* `rg_flow_tendsto_zero` — if every gain has `|g_i| < 1` the whole flow converges to
  the IR fixed point `0`.

## References

* Jacot, Gabriel, Hongler, *Neural Tangent Kernel* (2018).
* The RG interpretation of coarse-graining/optimization dynamics is folklore in the
  physics-of-learning literature; here it is given a fully verified algebraic core.
-/

open Filter
open scoped BigOperators

namespace RGFlowTraining

-- !-- Lab Notebook -- !--
-- Hypothesis: NTK-regime gradient descent is a renormalization-group flow on the
--   space of spectral modes. Each step rescales mode i by its gain g_i = 1-ηλ_i;
--   high NTK-eigenvalue modes contract fastest and are "integrated out", leaving a
--   relevant low-eigenvalue subspace whose IR fixed point is the NTK kernel.
-- Result: Formalized the diagonal RG step `rgStep`, its closed-form iterate
--   (g_i^k v_i), the semigroup law, scale separation (fast modes vanish relative
--   to slow ones), the fixed-point = NTK-kernel characterization, and global
--   convergence to the IR fixed point when all gains contract.
-- Insight: The "integrating out high-frequency modes" slogan becomes the precise
--   statement that the *ratio* of a fast mode to a slow mode tends to 0 — a
--   geometric-sequence fact once the iterate is in closed form. The RG semigroup
--   is exactly `Function.iterate_add`, and the IR fixed point is exactly the
--   kernel of the NTK, linking optimization dynamics to linear algebra.
-- Failure analysis: A continuous-time RG-flow ODE formulation was avoided (heavy
--   matrix-exponential API). The discrete diagonal flow captures the same scaling
--   physics with clean, fully verified proofs and reuses NTKSpectral directly.

/-- The per-mode **gain** of one training step: mode `i` with NTK eigenvalue `lam`
is rescaled by `1 - lr * lam` (cf. `NTKSpectral.ntk_mode_decay`). -/
def gain (lr lam : ℝ) : ℝ := 1 - lr * lam

/-- One **renormalization-group / training step**, modeled as the diagonal flow on
mode space that rescales each spectral mode `i` by its gain `1 - lr*(lam i)`. -/
def rgStep {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ) : Fin d → ℝ :=
  fun i => gain lr (lam i) * v i

-- !-- Induction on `k`: `iterate_succ_apply'` peels one step, then `pow_succ`. -- !--
/-- **Closed form of the RG flow.** Iterating the diagonal step `k` times multiplies
each mode by `g_i^k`: `(rgStep)^[k] v i = (gain lr (lam i))^k * v i`. This is the
multi-mode generalization of `NTKSpectral.ntk_mode_decay`. -/
theorem rgStep_iterate {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (i : Fin d) :
    ∀ k, ((rgStep lr lam)^[k] v) i = (gain lr (lam i)) ^ k * v i := by
  intro k
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    simp only [rgStep]
    rw [ih, pow_succ]; ring

-- !-- `Function.iterate_add_apply` splits the iterate of a sum of scales. -- !--
/-- **RG semigroup law.** The training/RG steps form a discrete one-parameter
semigroup: coarse-graining to scale `k + m` equals coarse-graining to scale `m`
and then to scale `k`. -/
theorem rgStep_semigroup {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (k m : ℕ) :
    (rgStep lr lam)^[k + m] v = (rgStep lr lam)^[k] ((rgStep lr lam)^[m] v) :=
  Function.iterate_add_apply (rgStep lr lam) k m v

-- !-- Read off coordinatewise: the IR fixed condition `(1-lr·lam_i)v_i = v_i`
--     simplifies to `lr·(lam_i·v_i)=0`, and `lr ≠ 0` cancels. -- !--
/-- **IR fixed points = NTK kernel.** A residual is a fixed point of the training/RG
flow iff every active NTK eigenvalue annihilates it (`lam i * v i = 0` for all `i`).
Equivalently, the flow halts exactly on the kernel of the NTK — its infrared fixed
manifold. -/
theorem rgStep_fixed_iff {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (hlr : lr ≠ 0)
    (v : Fin d → ℝ) :
    rgStep lr lam v = v ↔ ∀ i, lam i * v i = 0 := by
  constructor;
  · intro h i; have := congr_fun h i; simp_all +decide [ rgStep, gain ] ;
    exact Classical.or_iff_not_imp_right.2 fun hi => mul_left_cancel₀ hi <| mul_left_cancel₀ hlr <| by linarith;
  · intro h; ext i; simp +decide [ *, rgStep, gain ] ;
    grind

-- !-- `rgStep_iterate` writes the ratio as `(|g_i|/|g_j|)^k · (|v_i|/|v_j|)`;
--     the base is `< 1`, so the geometric sequence times a constant tends to `0`. -- !--
/-- **Separation of scales (integrating out high-frequency modes).** If mode `i`
contracts strictly faster than mode `j` (`|g_i| < |g_j|`), then the relative
amplitude of the fast mode `i` to the slow mode `j` tends to `0` along the RG flow.
The high-frequency mode is asymptotically negligible — exactly the
renormalization-group act of integrating it out. (In the physically relevant regime
`v j ≠ 0` this is an honest amplitude ratio; the statement also holds trivially when
`v j = 0`, where the quotient is identically `0`.) -/
theorem rg_scale_separation {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (i j : Fin d)
    (hlt : |gain lr (lam i)| < |gain lr (lam j)|) :
    Tendsto (fun k => |((rgStep lr lam)^[k] v) i| / |((rgStep lr lam)^[k] v) j|)
      atTop (nhds 0) := by
  -- By `rgStep_iterate`, the k-th term equals `|(gain lr (lam i))^k * v i| / |(gain lr (lam j))^k * v j| = (|gain lr (lam i)|^k * |v i|) / (|gain lr (lam j)|^k * |v j|)`.
  have h_ratio : ∀ k, |(rgStep lr lam)^[k] v i| / |(rgStep lr lam)^[k] v j| = (|gain lr (lam i)| / |gain lr (lam j)|) ^ k * |v i| / |v j| := by
    intro k; rw [ rgStep_iterate, rgStep_iterate ] ; simp +decide [ abs_mul ] ; ring;
  simpa [ h_ratio ] using Filter.Tendsto.div_const ( Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( by positivity ) ( show |gain lr ( lam i )| / |gain lr ( lam j )| < 1 by rwa [ div_lt_one ( lt_of_le_of_lt ( by positivity ) hlt ) ] ) ) tendsto_const_nhds ) _

-- !-- Componentwise via `tendsto_pi_nhds`: each mode is `g_i^k v_i` with
--     `|g_i| < 1`, so `tendsto_pow_atTop_nhds_zero_of_abs_lt_one` gives `→ 0`. -- !--
/-- **Convergence to the IR fixed point.** If every mode is contracting
(`|g_i| < 1`), the whole RG/training flow converges to the infrared fixed point `0`.
This is the multi-mode generalization of `NTKSpectral.ntk_optimal_tendsto_zero`. -/
theorem rg_flow_tendsto_zero {d : ℕ} (lr : ℝ) (lam : Fin d → ℝ) (v : Fin d → ℝ)
    (hgain : ∀ i, |gain lr (lam i)| < 1) :
    Tendsto (fun k => (rgStep lr lam)^[k] v) atTop (nhds 0) := by
  rw [ tendsto_pi_nhds ];
  intro i; simpa [ rgStep_iterate ] using tendsto_pow_atTop_nhds_zero_of_abs_lt_one ( hgain i ) |> Tendsto.mul_const ( v i ) ;

end RGFlowTraining