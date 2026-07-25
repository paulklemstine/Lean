/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Variance Reduction Theory of Policy-Gradient Baselines

Building on `Foundations.lean`, this file formalizes the classical
control-variate ("baseline") theory of REINFORCE: subtracting a constant
baseline `b` from the return leaves the gradient *unbiased*, while choosing the
optimal baseline `b⋆` *minimizes* the estimator's second moment (hence its
variance). The optimal-baseline results all drop out of a single completed
square.

## Main Results

- `baseline_unbiased`         — `E_π[(R−b) s] = E_π[R s]` whenever `E_π[s] = 0`.
- `secondMoment_quadratic`    — `M(b) = A b² − 2B b + C`.
- `variance_reduction_amount` — the exact gain `M(b) − M(b⋆) = A·(b − b⋆)²`.
- `optimal_baseline_min`      — `b⋆ = B/A` minimizes the second moment.
- `optimal_baseline_strict`   — `b⋆` is the *unique* minimizer.

-- !-- Lab Notebook -- !--
Hypothesis: The optimal baseline `b⋆ = E[R s²]/E[s²]` and all its optimality
  properties follow from one completed-square identity, not separate proofs.
Result: Confirmed. `variance_reduction_amount` (the completed square) is the
  only nontrivial lemma; minimization, uniqueness, and the strict inequality
  are one-line corollaries via `sq_nonneg` / `mul_self_pos`.
Insight: Unbiasedness needs only `E_π[s] = 0` (proved as
  `softmaxScore_expect_zero`); the variance optimization is independent of the
  unbiasedness and works for ANY return `R` and ANY score `s`.
Failure analysis: A naive `nlinarith`/`ring` on the raw sums times out;
  factoring through the named moments `momA, momB, momC` and `Finset.mul_sum`
  is essential. The strictness proof needed only `A > 0` and `b ≠ b⋆`; the
  probability-nonnegativity hypothesis turned out to be unnecessary there.
-- !-- Lab Notebook -- !--
-/
import Mathlib

namespace Catalog.PolicyGradient

open scoped BigOperators

variable {n : ℕ}

/-- Expectation of `f` under the finite distribution `p` (mirrors `Foundations`). -/
def expectVal' (p f : Fin n → ℝ) : ℝ := ∑ a, p a * f a

/-- Second moment of the baselined gradient estimator `ĝ_b(a) = (R a − b) · s a`. -/
def secondMoment (p R s : Fin n → ℝ) (b : ℝ) : ℝ :=
  ∑ a, p a * ((R a - b) * s a) ^ 2

/-- Moment `A = E_π[s²]`. -/
def momA (p s : Fin n → ℝ) : ℝ := ∑ a, p a * (s a) ^ 2
/-- Moment `B = E_π[R s²]`. -/
def momB (p R s : Fin n → ℝ) : ℝ := ∑ a, p a * (R a * (s a) ^ 2)
/-- Moment `C = E_π[R² s²]`. -/
def momC (p R s : Fin n → ℝ) : ℝ := ∑ a, p a * ((R a) ^ 2 * (s a) ^ 2)

-- !-- `(R−b) s = R s − b s`, so the expectation splits and the `b·E[s]` term
-- vanishes by hypothesis `E_π[s] = 0`. -- !--
theorem baseline_unbiased (p R s : Fin n → ℝ) (b : ℝ)
    (hs : expectVal' p s = 0) :
    expectVal' p (fun a => (R a - b) * s a) = expectVal' p (fun a => R a * s a) := by
  unfold expectVal' at *
  have h : ∑ a, p a * ((R a - b) * s a)
      = ∑ a, p a * (R a * s a) - b * ∑ a, p a * s a := by
    rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun a _ => by ring
  rw [h, hs, mul_zero, sub_zero]

-- !-- Expand `((R−b)s)² = R²s² − 2b·R s² + b²·s²`, push `p_a` in and use
-- `Finset.mul_sum` to collect the moments `A, B, C`. -- !--
theorem secondMoment_quadratic (p R s : Fin n → ℝ) (b : ℝ) :
    secondMoment p R s b = momA p s * b ^ 2 - 2 * momB p R s * b + momC p R s := by
  unfold secondMoment momA momB momC
  ring_nf
  simp +decide [mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _,
    Finset.sum_add_distrib]
  ring

-- !-- With `b⋆ = B/A`, rewrite both second moments by `secondMoment_quadratic`;
-- the difference is the completed square `A·(b − b⋆)²` (clear `A` by `field_simp`). -- !--
theorem variance_reduction_amount (p R s : Fin n → ℝ) (b : ℝ)
    (hA : momA p s ≠ 0) :
    secondMoment p R s b - secondMoment p R s (momB p R s / momA p s)
      = momA p s * (b - momB p R s / momA p s) ^ 2 := by
  rw [secondMoment_quadratic, secondMoment_quadratic]
  field_simp
  ring

-- !-- `M(b) − M(b⋆) = A·(b−b⋆)² ≥ 0` since `A = E[s²] ≥ 0` and squares are nonneg. -- !--
theorem optimal_baseline_min (p R s : Fin n → ℝ) (hp : ∀ a, 0 ≤ p a)
    (hA : momA p s ≠ 0) (b : ℝ) :
    secondMoment p R s (momB p R s / momA p s) ≤ secondMoment p R s b := by
  have h := variance_reduction_amount p R s b hA
  have hA0 : 0 ≤ momA p s :=
    Finset.sum_nonneg fun a _ => mul_nonneg (hp a) (sq_nonneg _)
  nlinarith [mul_nonneg hA0 (sq_nonneg (b - momB p R s / momA p s))]

-- !-- If `b ≠ b⋆` then `A·(b−b⋆)² > 0` (strict, using `A > 0`), so `M(b⋆)`
-- is a strict minimum. -- !--
theorem optimal_baseline_strict (p R s : Fin n → ℝ)
    (hA : 0 < momA p s) (b : ℝ) (hb : b ≠ momB p R s / momA p s) :
    secondMoment p R s (momB p R s / momA p s) < secondMoment p R s b := by
  have h := variance_reduction_amount p R s b hA.ne'
  nlinarith [mul_pos hA (mul_self_pos.2 (sub_ne_zero.2 hb))]

end Catalog.PolicyGradient