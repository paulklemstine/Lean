/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Logarithmic Depth–Accuracy Trade-off for Hodge Message Passing

This file *sharpens* the qualitative `spectral_depth_threshold` of
`Catalog/Speculative/AutoResearch/HodgeSpectralThreshold.lean` — which only asserted that
*some* finite depth suffices — into a fully **explicit, constructive depth witness**.

If one layer of Hodge message passing contracts the Dirichlet energy by a factor
`0 < ρ < 1` (the regime established there by `mpStep_contraction`), then to drive the
residual energy below a tolerance `ε > 0` it is *enough* to use

  `N(ε) = ⌈ log_ρ (ε / ‖x‖²) ⌉`     (`hodgeDepth`)

layers.  This is the logarithmic depth law: accuracy improves geometrically, so depth
grows only like `log(1/ε)`.

## Main results

* `quadform_iterate_bound`     — (re-derived, self-contained) geometric energy decay
    `‖Tᵏx‖² ≤ ρᵏ ‖x‖²`.
* `pow_le_of_logb_le`          — the analytic core: `N ≥ log_ρ c ⇒ ρᴺ ≤ c` for `0<ρ<1`.
* `hodgeDepth`                 — the explicit `⌈log_ρ (ε/‖x‖²)⌉` depth.
* `hodgeDepth_residual_bound`  — **the explicit threshold**: every depth `k ≥ hodgeDepth`
    drives the residual energy below `ε`; a constructive witness for `spectral_depth_threshold`.
* `hodge_mp_log_depth`         — the same, specialized to the message-passing operator `mpStep`.

## Catalog synthesis

This realizes **Research Direction 3** of `HodgeSpectralThreshold`'s FUTURE_DIRECTIONS
("the depth–accuracy trade-off is logarithmic"): the geometric bound `quadform_iterate_bound`
combined with `Real.logb` monotonicity yields the closed-form `⌈log⌉` depth directly,
replacing the non-constructive `Tendsto`/`exists` argument of `spectral_depth_threshold`
with an explicit, evaluable depth formula.
-/
import Mathlib

namespace HodgeDepthLogarithmic

open Matrix Real

variable {n : ℕ}

-- !-- Lab Notebook -- !--
-- Hypothesis: The qualitative "finitely many layers suffice" threshold should admit an
--   explicit closed-form depth `⌈log_ρ(ε/‖x‖²)⌉`, turning the geometric decay `ρᵏ‖x‖²`
--   into a logarithmic depth–accuracy law.
-- Result: `hodgeDepth_residual_bound` proves the explicit witness sorry-free; it strictly
--   refines `spectral_depth_threshold` (which only produced an unspecified `N`).
-- Insight: The analytic crux `pow_le_of_logb_le` reduces `ρᴺ ≤ c` to `N·log ρ ≤ log c`
--   via `div_le_iff_of_neg` (note `log ρ < 0`!) and `Real.log_le_log_iff`.  The `⌈·⌉₊`
--   ceiling is exactly what `Nat.le_ceil` needs to supply `log_ρ c ≤ N`, even when the
--   logarithm is negative (then the ceiling is `0`, and zero layers already suffice).
-- Failure analysis: a naive `exact?` finds nothing for `ρᴺ ≤ c`; the sign flip from
--   `log ρ < 0` is the trap — using `div_le_iff` instead of `div_le_iff_of_neg` reverses
--   the inequality.  The `‖x‖² = 0` corner is handled separately since `log_ρ(ε/0)` is junk.
-- !-- end Lab Notebook -- !--

/-- One layer of gradient-descent Hodge message passing, `x ↦ x - α (L x)`
(matching `HodgeSpectralThreshold.mpStep`). -/
def mpStep (L : Matrix (Fin n) (Fin n) ℝ) (α : ℝ) (x : Fin n → ℝ) : Fin n → ℝ :=
  x - α • (L *ᵥ x)

-- !-- Geometric energy decay: induction on depth, multiplying the inductive bound by the
--    per-layer factor `ρ ≥ 0`. -- !--
theorem quadform_iterate_bound (T : (Fin n → ℝ) → (Fin n → ℝ)) (ρ : ℝ) (hρ : 0 ≤ ρ)
    (hstep : ∀ y, (T y) ⬝ᵥ (T y) ≤ ρ * (y ⬝ᵥ y)) (x : Fin n → ℝ) (k : ℕ) :
    (T^[k] x) ⬝ᵥ (T^[k] x) ≤ ρ ^ k * (x ⬝ᵥ x) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', pow_succ', mul_assoc]
    exact le_trans (hstep _) (mul_le_mul_of_nonneg_left ih hρ)

-- !-- Analytic core.  Take logs: `ρᴺ ≤ c ↔ N·log ρ ≤ log c` (both sides positive).  Since
--    `log ρ < 0`, `div_le_iff_of_neg` converts `log_ρ c = log c / log ρ ≤ N` into exactly
--    `N·log ρ ≤ log c`. -- !--
theorem pow_le_of_logb_le (ρ c : ℝ) (h0 : 0 < ρ) (h1 : ρ < 1) (hc : 0 < c) (N : ℕ)
    (hN : Real.logb ρ c ≤ N) : ρ ^ N ≤ c := by
  have hpos : (0:ℝ) < ρ ^ N := pow_pos h0 N
  have hlogρ : Real.log ρ < 0 := Real.log_neg h0 h1
  rw [Real.logb, div_le_iff_of_neg hlogρ] at hN
  have hkey : Real.log (ρ ^ N) ≤ Real.log c := by rw [Real.log_pow]; exact_mod_cast hN
  exact (Real.log_le_log_iff hpos hc).mp hkey

/-- The explicit logarithmic depth: `⌈log_ρ (ε / ‖x‖²)⌉` layers suffice to reach
tolerance `ε` when each layer contracts the energy by `ρ`. -/
noncomputable def hodgeDepth (ρ E0 ε : ℝ) : ℕ := ⌈Real.logb ρ (ε / E0)⌉₊

-- !-- Explicit depth threshold.  By `quadform_iterate_bound` the residual is `≤ ρᵏ‖x‖²`;
--    when `‖x‖² = 0` this is already `0 ≤ ε`, and otherwise `Nat.le_ceil` gives
--    `log_ρ(ε/‖x‖²) ≤ k`, so `pow_le_of_logb_le` yields `ρᵏ ≤ ε/‖x‖²`, hence `ρᵏ‖x‖² ≤ ε`. -- !--
theorem hodgeDepth_residual_bound (T : (Fin n → ℝ) → (Fin n → ℝ)) (ρ : ℝ)
    (h0 : 0 < ρ) (h1 : ρ < 1)
    (hstep : ∀ y, (T y) ⬝ᵥ (T y) ≤ ρ * (y ⬝ᵥ y))
    (x : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∀ k, hodgeDepth ρ (x ⬝ᵥ x) ε ≤ k → (T^[k] x) ⬝ᵥ (T^[k] x) ≤ ε := by
  intro k hk
  have hE0 : (0:ℝ) ≤ x ⬝ᵥ x := Finset.sum_nonneg fun i _ => mul_self_nonneg _
  have hbnd := quadform_iterate_bound T ρ (le_of_lt h0) hstep x k
  rcases eq_or_lt_of_le hE0 with hzero | hpos
  · rw [← hzero, mul_zero] at hbnd; linarith
  · have hN : Real.logb ρ (ε / (x ⬝ᵥ x)) ≤ k :=
      le_trans (Nat.le_ceil _) (by exact_mod_cast hk)
    have hcpos : 0 < ε / (x ⬝ᵥ x) := div_pos hε hpos
    have hpk : ρ ^ k ≤ ε / (x ⬝ᵥ x) := pow_le_of_logb_le ρ _ h0 h1 hcpos k hN
    have hfin : ρ ^ k * (x ⬝ᵥ x) ≤ ε := by rw [le_div_iff₀ hpos] at hpk; linarith
    linarith

-- !-- Specialization to the Hodge message-passing operator `mpStep L α`: under a global
--    per-layer energy contraction by `ρ`, depth `hodgeDepth` suffices.  Direct instance of
--    `hodgeDepth_residual_bound`. -- !--
theorem hodge_mp_log_depth (L : Matrix (Fin n) (Fin n) ℝ) (α ρ : ℝ)
    (h0 : 0 < ρ) (h1 : ρ < 1)
    (hstep : ∀ y, (mpStep L α y) ⬝ᵥ (mpStep L α y) ≤ ρ * (y ⬝ᵥ y))
    (x : Fin n → ℝ) (ε : ℝ) (hε : 0 < ε) :
    ∀ k, hodgeDepth ρ (x ⬝ᵥ x) ε ≤ k →
      ((mpStep L α)^[k] x) ⬝ᵥ ((mpStep L α)^[k] x) ≤ ε :=
  hodgeDepth_residual_bound (mpStep L α) ρ h0 h1 hstep x ε hε

end HodgeDepthLogarithmic