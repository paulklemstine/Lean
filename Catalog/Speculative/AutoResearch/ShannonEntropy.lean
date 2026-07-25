import Mathlib

/-!
# Shannon Entropy on Finite Probability Distributions

This file develops a first-principles formalization of Shannon entropy
`H(p) = -∑ₓ p(x) · log p(x)` for distributions on a finite type, built on
Mathlib's `Real.negMulLog` (the function `x ↦ -x · log x`) which already carries
the analytic facts we need (continuity, concavity, the `0·log 0 = 0` convention).

We prove four cornerstone results of information theory:

* `entropy_nonneg` — entropy of a sub-distribution is non-negative.
* `entropy_prod`   — additivity of entropy over independent (product) distributions.
* `entropy_uniform` — the uniform distribution has entropy `log n`.
* `entropy_le_log_card` — the **maximum entropy theorem**: any distribution on an
  `n`-element type has entropy at most `log n`, via concave Jensen's inequality.

Together `entropy_uniform` and `entropy_le_log_card` show the uniform distribution
attains the maximum, the precise quantitative content of "uniform = maximal
uncertainty".

-- !-- Lab Notebook -- !--
Hypothesis:  Mathlib's `Real.negMulLog` and the `Finset.sum` / Jensen API are a
             sufficient substrate to build Shannon entropy from scratch, the only
             subtlety being the `0 * log 0 = 0` convention (handled for free by
             `negMulLog_zero`).
Result:      Four cornerstone theorems proved with `sorry = 0`. Additivity follows
             algebraically from `negMulLog_mul`; the maximum-entropy bound from
             `Real.concaveOn_negMulLog.le_map_sum` with uniform weights `1/n`.
Insight:     The maximum-entropy theorem is *exactly* concave Jensen applied to
             `negMulLog` with uniform weights: `(1/n) Σ f(pᵢ) ≤ f((1/n) Σ pᵢ) =
             f(1/n)`, then multiply by `n`. No calculus beyond the prepackaged
             concavity is needed.
Failure analysis: The `0 * log 0` convention makes naïve `-p * log p` brittle near
             zero; routing everything through `negMulLog` removes every edge case.
             Division-by-`n` forces a `[Nonempty α]` hypothesis on the uniform /
             upper-bound results (an empty type has `card = 0`).
-/

open Finset

namespace ShannonEntropy

variable {α β : Type*}

/-- Shannon entropy of a finite distribution: `H(p) = -∑ₓ p(x) log p(x)`,
expressed via `Real.negMulLog x = -x log x`. -/
noncomputable def entropy [Fintype α] (p : α → ℝ) : ℝ :=
  ∑ x, Real.negMulLog (p x)

/-- A finite probability distribution: non-negative weights summing to one. -/
structure IsProbDist [Fintype α] (p : α → ℝ) : Prop where
  nonneg : ∀ x, 0 ≤ p x
  sum_one : ∑ x, p x = 1

-- !-- entropy_nonneg: each term `negMulLog (p x)` is `≥ 0` for `p x ∈ [0,1]`
-- (`Real.negMulLog_nonneg`), so the sum of non-negatives is `≥ 0`. -- !--
/-- Entropy of a sub-distribution (weights in `[0,1]`) is non-negative. -/
theorem entropy_nonneg [Fintype α] {p : α → ℝ}
    (h0 : ∀ x, 0 ≤ p x) (h1 : ∀ x, p x ≤ 1) : 0 ≤ entropy p := by
  exact Finset.sum_nonneg fun x _ => Real.negMulLog_nonneg ( h0 x ) ( h1 x )

-- !-- entropy_prod: expand `negMulLog (p x * q y)` via `Real.negMulLog_mul`, then
-- factor the double sum using `∑ p = ∑ q = 1`; cross terms collapse to H(p), H(q). -- !--
/-- **Additivity of entropy over independent distributions.** For the product
distribution `(x,y) ↦ p x · q y`, entropy adds: `H(p⊗q) = H(p) + H(q)`. -/
theorem entropy_prod [Fintype α] [Fintype β] {p : α → ℝ} {q : β → ℝ}
    (hp : ∑ x, p x = 1) (hq : ∑ y, q y = 1) :
    entropy (fun z : α × β => p z.1 * q z.2) = entropy p + entropy q := by
  unfold entropy;
  -- Apply the distributive property of multiplication over addition.
  have h_dist : ∑ x : α × β, Real.negMulLog (p x.1 * q x.2) = ∑ x : α, ∑ y : β, (q y * Real.negMulLog (p x) + p x * Real.negMulLog (q y)) := by
    rw [ ← Finset.sum_product' ];
    exact Finset.sum_congr rfl fun _ _ => Real.negMulLog_mul _ _;
  simp_all +decide [ Finset.sum_add_distrib, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ]

-- !-- entropy_uniform: every term equals `negMulLog (1/n) = (1/n) log n`; summing
-- `n` of them gives `log n` (uses `card` positivity from `[Nonempty α]`). -- !--
/-- The uniform distribution on an `n`-element type has entropy `log n`. -/
theorem entropy_uniform [Fintype α] [Nonempty α] :
    entropy (fun _ : α => (1 / Fintype.card α : ℝ)) = Real.log (Fintype.card α) := by
  -- By substituting $p_i = 1/n$ into the definition of entropy, we get:
  simp [entropy, Real.negMulLog]

-- !-- entropy_le_log_card: concave Jensen (`Real.concaveOn_negMulLog.le_map_sum`)
-- with uniform weights `wᵢ = 1/n` gives `(1/n) Σ negMulLog(pᵢ) ≤ negMulLog(1/n)
-- = (1/n) log n`; multiplying through by `n` yields `H(p) ≤ log n`. -- !--
/-- **Maximum entropy theorem.** Any probability distribution on an `n`-element
type has entropy at most `log n`, with equality for the uniform distribution
(`entropy_uniform`). -/
theorem entropy_le_log_card [Fintype α] [Nonempty α] {p : α → ℝ}
    (hp : IsProbDist p) : entropy p ≤ Real.log (Fintype.card α) := by
  -- Apply Jensen's inequality with the concave function `Real.negMulLog` and weights `1 / Fintype.card α`.
  have h_jensen : (∑ x : α, (1 / Fintype.card α : ℝ) • Real.negMulLog (p x)) ≤ Real.negMulLog (∑ x : α, (1 / Fintype.card α : ℝ) • p x) := by
    convert ( Real.concaveOn_negMulLog.le_map_sum _ _ _ );
    · exact fun _ _ => by positivity;
    · simp;
    · exact fun i _ => hp.nonneg i;
  convert mul_le_mul_of_nonneg_left h_jensen ( Nat.cast_nonneg ( Fintype.card α ) ) using 1;
  · simp +decide [ Fintype.card_ne_zero, Finset.mul_sum _ _ _ ];
    rfl;
  · simp +decide [ ← Finset.mul_sum _ _ _, hp.sum_one, Real.negMulLog ]

end ShannonEntropy