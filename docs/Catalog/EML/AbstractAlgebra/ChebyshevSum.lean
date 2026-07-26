/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Chebyshev's Sum Inequality and the Rearrangement Inequality

This file formalizes Chebyshev's sum inequality and the rearrangement inequality
for pairs, fundamental results in the theory of inequalities that exploit
monotonicity structure.

## Main results

* `EML.rearrangement_pair`: The rearrangement inequality for two pairs:
  if a₁ ≤ a₂ and b₁ ≤ b₂, then a₁b₂ + a₂b₁ ≤ a₁b₁ + a₂b₂.

* `EML.monotone_pair_mul_nonneg`: For monotone sequences a and b,
  (a i - a j) * (b i - b j) ≥ 0 for all i, j.

* `EML.chebyshev_sum_identity`: The algebraic identity underlying Chebyshev's inequality:
  2 * (n * ∑ aᵢbᵢ - (∑ aᵢ)(∑ bᵢ)) = ∑ᵢ ∑ⱼ (aᵢ - aⱼ)(bᵢ - bⱼ)

* `EML.chebyshev_sum_ineq`: Chebyshev's sum inequality:
  n * ∑ aᵢbᵢ ≥ (∑ aᵢ)(∑ bᵢ) when a and b are co-monotone.

* `EML.chebyshev_sum_ineq_anti`: Reverse Chebyshev:
  n * ∑ aᵢbᵢ ≤ (∑ aᵢ)(∑ bᵢ) when a is monotone and b is antitone.

## References

* Chebyshev, P.L. "Sur les expressions approchées des intégrales définies par les autres
  prises entre les mêmes limites" (1882).
* Hardy, Littlewood, Pólya, "Inequalities" (1934), Chapter 10.
-/

import Mathlib

namespace EML

open Finset BigOperators

/-! ### The Rearrangement Inequality for Pairs -/

/-
The rearrangement inequality for two pairs: concordant pairing dominates discordant.
If a₁ ≤ a₂ and b₁ ≤ b₂, then a₁b₂ + a₂b₁ ≤ a₁b₁ + a₂b₂.
Equivalently, (a₂ - a₁)(b₂ - b₁) ≥ 0.
-/
theorem rearrangement_pair {a₁ a₂ b₁ b₂ : ℝ} (ha : a₁ ≤ a₂) (hb : b₁ ≤ b₂) :
    a₁ * b₂ + a₂ * b₁ ≤ a₁ * b₁ + a₂ * b₂ := by
  nlinarith

/-
For monotone sequences, differences of corresponding terms have the same sign.
This is the pointwise version of the rearrangement principle.
-/
theorem monotone_pair_mul_nonneg {n : ℕ} {a b : Fin n → ℝ}
    (ha : Monotone a) (hb : Monotone b) (i j : Fin n) :
    0 ≤ (a i - a j) * (b i - b j) := by
  cases le_total i j <;> nlinarith [ ha ‹_›, hb ‹_› ]

/-! ### The Chebyshev Identity

The key algebraic identity: the "covariance" of two sequences over a finite set
equals half the sum of pairwise products of differences. -/

/-
The Chebyshev algebraic identity:
2 * (↑n * ∑ᵢ a(i) * b(i) - (∑ᵢ a(i)) * (∑ᵢ b(i)))
  = ∑ᵢ ∑ⱼ (a(i) - a(j)) * (b(i) - b(j))
This identity holds for arbitrary sequences — no monotonicity needed.
-/
theorem chebyshev_sum_identity (n : ℕ) (a b : Fin n → ℝ) :
    2 * ((n : ℝ) * ∑ i : Fin n, a i * b i - (∑ i : Fin n, a i) * (∑ i : Fin n, b i)) =
    ∑ i : Fin n, ∑ j : Fin n, (a i - a j) * (b i - b j) := by
  simp +decide [ sub_mul, mul_sub, Finset.mul_sum _ _ _, Finset.sum_mul ] ; ring;
  simpa [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] using by ring;

/-! ### Chebyshev's Sum Inequality -/

/-
**Chebyshev's Sum Inequality**: For co-monotone sequences a and b of length n,
the product of sums is bounded by n times the sum of products:
  n * ∑ aᵢbᵢ ≥ (∑ aᵢ)(∑ bᵢ)

Intuitively, pairing large values with large values and small with small
produces a larger total than any mixing.
-/
theorem chebyshev_sum_ineq (n : ℕ) (a b : Fin n → ℝ)
    (ha : Monotone a) (hb : Monotone b) :
    (∑ i : Fin n, a i) * (∑ i : Fin n, b i) ≤
    (n : ℝ) * ∑ i : Fin n, a i * b i := by
  -- From the identity: 2 * (n * ∑ aᵢbᵢ - (∑ aᵢ)(∑ bᵢ)) = ∑ᵢ ∑ⱼ (aᵢ - aⱼ)(bᵢ - bⱼ).
  have h1 : 2 * (n * ∑ i, a i * b i - (∑ i, a i) * (∑ i, b i)) = ∑ i, ∑ j, (a i - a j) * (b i - b j) := by
    exact chebyshev_sum_identity n a b
  linarith [show 0 ≤ ∑ i, ∑ j, (a i - a j) * (b i - b j) from
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => monotone_pair_mul_nonneg ha hb i j]

/-
**Reverse Chebyshev**: For contra-monotone sequences (a monotone, b antitone),
  n * ∑ aᵢbᵢ ≤ (∑ aᵢ)(∑ bᵢ)

Pairing large with small produces a smaller total.
-/
theorem chebyshev_sum_ineq_anti (n : ℕ) (a b : Fin n → ℝ)
    (ha : Monotone a) (hb : Antitone b) :
    (n : ℝ) * ∑ i : Fin n, a i * b i ≤
    (∑ i : Fin n, a i) * (∑ i : Fin n, b i) := by
  -- Apply the Chebyshev's sum inequality with $(-b)$ instead of $b$, noting that $-b$ is monotone.
  have := chebyshev_sum_ineq n a (-b) ha (hb.neg)
  simp_all +decide [ Finset.sum_neg_distrib, mul_neg ]

/-! ### Consequences -/

/-
Chebyshev applied to identical sequences gives the Cauchy-Schwarz-like bound:
  n * ∑ aᵢ² ≥ (∑ aᵢ)²  (the QM-AM inequality in disguise)
-/
theorem sum_sq_lower_bound (n : ℕ) (a : Fin n → ℝ) :
    (∑ i : Fin n, a i) ^ 2 ≤ (n : ℝ) * ∑ i : Fin n, a i ^ 2 := by
  -- By the Cauchy-Schwarz inequality, we have that for any vectors $u$ and $v$ of equal length, $(∑ i, u_i v_i)^2 ≤ (∑ i, u_i^2) (∑ i, v_i^2)$.
  have h_cauchy_schwarz : ∀ (u v : Fin n → ℝ), (∑ i, u i * v i)^2 ≤ (∑ i, u i^2) * (∑ i, v i^2) := by
    exact fun u v => sum_mul_sq_le_sq_mul_sq univ u v
  simpa using h_cauchy_schwarz 1 a

end EML