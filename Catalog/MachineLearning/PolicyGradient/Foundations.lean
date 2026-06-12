/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Differential Geometry of Softmax Policy Gradients

This file builds, from scratch, the first-order theory of the softmax policy
parameterization used in policy-gradient reinforcement learning. The central
discovery formalized here is that the entire first-order theory is **purely
algebraic over a finite probability vector** and needs no measure theory: the
log-derivative (REINFORCE) identity, the closed form of the Fisher information
matrix, and its positive-semidefiniteness are all finite-sum facts.

## Main Results

- `softmaxPolicy_pos`     — the softmax policy is strictly positive.
- `softmaxPolicy_sum_one` — the softmax policy is a probability distribution.
- `softmaxScore_expect_zero` — the log-derivative identity `E_π[ψ_j] = 0`.
- `fisherInfo_eq`         — closed form `F_{jk} = π_j δ_{jk} − π_j π_k`.
- `fisherInfo_symm`       — the Fisher matrix is symmetric.
- `fisherInfo_psd`        — `F` is positive semidefinite, realized as a variance.

-- !-- Lab Notebook -- !--
Hypothesis: The first-order geometry of softmax PG (score, Fisher metric)
  can be formalized with finite `Finset` sums alone, with no probability
  measure theory, by treating the policy as a positive vector summing to one.
Result: Confirmed. All six theorems close over `Fin n` real sums.
Insight: The single reusable engine is "expand, push constants through
  `Finset.mul_sum`, collapse indicators with `Finset.sum_ite_eq'`, reduce to
  the sum-to-one law". The Fisher PSD identity is realized as a genuine
  variance `vᵀ F v = E_π[(⟨v, ψ(·)⟩)²] ≥ 0`.
Failure analysis: `softmaxPolicy_sum_one` was first stated without `[NeZero n]`
  and was disproved (for `n = 0` the empty sum is `0 ≠ 1`); adding nonemptiness
  fixed it. The PSD identity needed a triple-sum reordering rather than a
  one-shot `simp`; the matrix-level facts (next cycle) want a clean
  `Finset`-indexed quadratic-form API.
-- !-- Lab Notebook -- !--
-/
import Mathlib

namespace Catalog.PolicyGradient

open scoped BigOperators

variable {n : ℕ}

/-- The softmax policy induced by logits `z : Fin n → ℝ`. -/
noncomputable def softmaxPolicy (z : Fin n → ℝ) (j : Fin n) : ℝ :=
  Real.exp (z j) / ∑ a, Real.exp (z a)

/-- Expectation of `f` under the finite distribution `p`. -/
def expectVal (p f : Fin n → ℝ) : ℝ := ∑ a, p a * f a

/-- The score (log-derivative) of the softmax policy w.r.t. logit `j`,
evaluated at action `a`: `ψ_j(a) = δ_{aj} − p_j`. -/
def score (p : Fin n → ℝ) (j a : Fin n) : ℝ := (if a = j then 1 else 0) - p j

/-- The (matrix) Fisher information: `F_{jk} = E_π[ψ_j ψ_k]`. -/
def fisherInfo (p : Fin n → ℝ) (j k : Fin n) : ℝ :=
  ∑ a, p a * score p j a * score p k a

-- !-- The denominator of softmax is a sum of strictly positive exponentials, and
-- `j : Fin n` witnesses nonemptiness, so it is positive; a quotient of positives. -- !--
theorem softmaxPolicy_pos (z : Fin n → ℝ) (j : Fin n) : 0 < softmaxPolicy z j := by
  exact div_pos (Real.exp_pos _)
    (Finset.sum_pos (fun _ _ => Real.exp_pos _) ⟨j, Finset.mem_univ _⟩)

-- !-- Sum of `exp (z a) / D` over `a` is `(∑ exp) / D = 1` since `D = ∑ exp ≠ 0`. -- !--
theorem softmaxPolicy_sum_one [NeZero n] (z : Fin n → ℝ) :
    ∑ j, softmaxPolicy z j = 1 := by
  unfold softmaxPolicy
  rw [← Finset.sum_div,
    div_self <| ne_of_gt <|
      Finset.sum_pos (fun _ _ => Real.exp_pos _) Finset.univ_nonempty]

-- !-- `E_π[ψ_j] = ∑_a p_a(δ_{aj} − p_j) = p_j − p_j·(∑_a p_a) = 0` by sum-to-one. -- !--
theorem softmaxScore_expect_zero (p : Fin n → ℝ) (hp : ∑ a, p a = 1) (j : Fin n) :
    expectVal p (fun a => score p j a) = 0 := by
  unfold expectVal score
  simp +decide [mul_sub, ← Finset.sum_mul _ _ _, hp]

-- !-- Expand `p_a(δ_{aj} − p_j)(δ_{ak} − p_k)`, collapse the two indicators, and
-- use `∑ p = 1` to land on `p_j δ_{jk} − p_j p_k`. -- !--
theorem fisherInfo_eq (p : Fin n → ℝ) (hp : ∑ a, p a = 1) (j k : Fin n) :
    fisherInfo p j k = (if j = k then p j else 0) - p j * p k := by
  unfold fisherInfo score
  simp_all +decide [mul_sub, sub_mul, Finset.sum_add_distrib, Finset.mul_sum _ _ _,
    Finset.sum_mul _ _ _, sub_sub, add_assoc]
  simp_all +decide [← mul_assoc, ← Finset.sum_mul _ _ _]
  grind

-- !-- Symmetry is immediate from commutativity of the product inside the sum. -- !--
theorem fisherInfo_symm (p : Fin n → ℝ) (j k : Fin n) :
    fisherInfo p j k = fisherInfo p k j := by
  unfold fisherInfo
  exact Finset.sum_congr rfl (fun _ _ => by ring)

-- !-- `vᵀ F v = ∑_{j,k} v_j v_k E_π[ψ_j ψ_k] = E_π[(∑_j v_j ψ_j)²] ≥ 0` after a
-- triple-sum reordering (`Finset.sum_comm`) and recognizing the square. -- !--
theorem fisherInfo_psd (p : Fin n → ℝ) (hp : ∀ a, 0 ≤ p a) (v : Fin n → ℝ) :
    0 ≤ ∑ j, ∑ k, v j * v k * fisherInfo p j k := by
  -- Expand `fisherInfo` via its definition.
  have h_expand : ∑ j, ∑ k, v j * v k * fisherInfo p j k
      = ∑ j, ∑ k, ∑ a, v j * v k * p a * (score p j a) * (score p k a) := by
    simp +decide only [fisherInfo, mul_assoc, Finset.mul_sum _ _ _]
  -- The triple sum is the variance `E_π[(∑_j v_j ψ_j)²]`.
  have h_rewrite : ∑ j, ∑ k, ∑ a, v j * v k * p a * (score p j a) * (score p k a)
      = ∑ a, p a * (∑ j, v j * (score p j a)) * (∑ k, v k * (score p k a)) := by
    simp +decide only [mul_comm, Finset.mul_sum _ _ _, mul_left_comm]
    exact Eq.symm (by
      rw [Finset.sum_comm]
      exact Finset.sum_congr rfl fun _ _ => Finset.sum_comm.trans
        (Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring))
  exact h_expand.symm ▸ h_rewrite.symm ▸ Finset.sum_nonneg fun a _ => by
    nlinarith only [hp a, mul_self_nonneg (∑ j, v j * score p j a)]

end Catalog.PolicyGradient