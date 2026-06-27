/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# A Depth–Width Separation for ReLU Networks via Total Variation

This file proves a self-contained **depth–width tradeoff** of Telgarsky type:
a deep, width-`O(1)` ReLU network (the `k`-fold composition of the tent map,
realizable with constant width and depth `O(k)`) oscillates `2^k` times on
`[0,1]`, and *any* single-hidden-layer ("shallow") ReLU network that
approximates it to accuracy `ε < 1/2` at the dyadic nodes must have **L¹ weight
mass `≥ 2^k(1 - 2ε)`**, hence — under a per-neuron weight bound `A` — width
`≥ 2^k(1-2ε)/A`.  The separation is exponential in depth.

## The engine: discrete total variation

The deep tent `tent^[k]` takes the alternating values `0,1,0,1,…` on the `2^k+1`
dyadic nodes `i/2^k` (`tent_iterate_dyadic`), so its discrete total variation
over that grid is exactly `2^k` (`tent_discreteTV`).  Total variation is the
right invariant because:

* it can only *drop* by `2ε` per node under an `ε`-approximation
  (reverse triangle inequality), so an approximant inherits TV `≥ 2^k(1-2ε)`;
* a shallow net `c + Σ_j a_j · relu(x - t_j)` has discrete total variation
  `≤ Σ_j |a_j|` over *any* grid, because each ramp difference across a cell of
  width `Δ` lies in `[0, Δ]` (`shallowNet_discreteTV_le`).

Chaining the two bounds gives the weight lower bound, and a per-neuron cap gives
the width lower bound.

## Main results

* `tent_iterate_dyadic` — `tent^[k](i/2^k) = i mod 2`.
* `tent_discreteTV` — discrete total variation of `tent^[k]` is `2^k`.
* `shallowNet_discreteTV_le` — shallow-net total variation `≤ Σ_j |a_j|`.
* `depth_separation_weight_lower_bound` — L¹ weight mass `≥ 2^k(1-2ε)`.
* `depth_separation_width_lower_bound` — width `≥ 2^k(1-2ε)/A` under cap `A`.

-- !-- Lab Notes -- !--
Hypothesis: depth manufactures oscillation count, and oscillation count is a
  *conserved, additive* quantity (total variation) that shallow nets can only
  produce in proportion to their L¹ weight mass. Therefore matching a depth-`k`
  tent forces exponential weight mass / width on any shallow net.
Experiment: replace the analytic "count crossings via IVT" route by a purely
  algebraic total-variation accounting. The deep tent's grid TV is computed
  exactly (`2^k`) from the dyadic alternation; the shallow net's grid TV is
  bounded by `Σ|a_j|` from the elementary ramp inequality `0 ≤ relu(b-t) -
  relu(a-t) ≤ b-a`.
Analysis: the argument is weight-magnitude *sensitive* (it produces `Σ|a_j| ≥
  2^k(1-2ε)`), which is exactly Telgarsky's separation; it is *stronger* than a
  pure Lipschitz bound and avoids any continuity/IVT machinery. The key failure
  mode of the IVT route — crossings collapsing at shared dyadic nodes — never
  arises here because TV sums signed node-to-node increments directly.
Critique: the bound degrades as `ε → 1/2` (TV floor `2^k(1-2ε) → 0`), which is
  correct: a constant `1/2` trivially "approximates" within `1/2`. The guard
  `ε < 1/2` keeps the floor positive. The width corollary additionally needs a
  per-neuron cap `A`, without which infinite-precision weights evade any width
  bound — also the correct boundary.
Synthesis: total variation is the conserved currency of the depth–width
  tradeoff; depth mints it for free (geometric growth `2^k`), shallow width must
  buy it linearly (`Σ|a_j|`).
-- !-- -- !--
-/
import Mathlib
import MachineLearning.UniversalApproximation.QuantitativeBoundsCore

namespace MachineLearning.UniversalApproximation

open Finset

/-- The tent map on `[0,1]`: `tent x = 1 - |2x - 1|`.  It satisfies `tent 0 = 0`,
`tent (1/2) = 1`, `tent 1 = 0`, and maps `[0,1]` onto `[0,1]`. -/
noncomputable def tent (x : ℝ) : ℝ := 1 - |2 * x - 1|

/-- Discrete total variation of `g` over the `2^k`-cell dyadic grid of `[0,1]`. -/
noncomputable def discreteTV (k : ℕ) (g : ℝ → ℝ) : ℝ :=
  ∑ i ∈ Finset.range (2 ^ k), |g (((i : ℝ) + 1) / 2 ^ k) - g ((i : ℝ) / 2 ^ k)|

/-- A single-hidden-layer ("shallow") ReLU network with `w` neurons:
`x ↦ c + ∑_j a_j · relu (x - t_j)`. -/
noncomputable def shallowNet (w : ℕ) (a t : Fin w → ℝ) (c : ℝ) (x : ℝ) : ℝ :=
  c + ∑ j : Fin w, a j * relu (x - t j)

/-
Elementary ramp inequality: across a cell `[a,b]` (with `a ≤ b`) a single
ramp `relu (· - t)` increases by an amount in `[0, b - a]`.
-/
lemma ramp_diff_bound (t a b : ℝ) (hab : a ≤ b) :
    0 ≤ relu (b - t) - relu (a - t) ∧ relu (b - t) - relu (a - t) ≤ b - a := by
  unfold relu; cases max_cases ( b - t ) 0 <;> cases max_cases ( a - t ) 0 <;> constructor <;> linarith;

/-
**Dyadic alternation of the deep tent.** For `j ≤ 2^k`,
`tent^[k] (j / 2^k) = j mod 2`.
-/
theorem tent_iterate_dyadic (k j : ℕ) (hj : j ≤ 2 ^ k) :
    tent^[k] ((j : ℝ) / 2 ^ k) = ((j % 2 : ℕ) : ℝ) := by
  induction' k with k ih generalizing j ; simp_all +decide;
  · interval_cases j <;> norm_num;
  · by_cases hj' : j ≤ 2 ^ k;
    · convert ih j hj' using 1 ; norm_num [ pow_succ', tent ] ; ring;
      rw [ abs_of_nonpos ] <;> norm_num ; ring;
      exact le_trans ( mul_le_mul_of_nonneg_right ( Nat.cast_le.mpr hj' ) ( by positivity ) ) ( by norm_num [ mul_assoc, ← mul_pow ] );
    · -- For $j > 2^k$, write $j = 2^k + m$ with $m \leq 2^k$.
      obtain ⟨m, hm⟩ : ∃ m, j = 2 ^ k + m ∧ m ≤ 2 ^ k := by
        exact ⟨ j - 2 ^ k, by rw [ Nat.add_sub_cancel' ( le_of_not_ge hj' ) ], Nat.sub_le_of_le_add <| by rw [ pow_succ' ] at hj; linarith ⟩;
      -- For $j = 2^k + m$, we have $tent(j / 2^{k+1}) = 1 - |2*(j / 2^{k+1}) - 1| = 1 - |(2^k + m) / 2^k - 1| = 1 - |1 + m / 2^k - 1| = 1 - |m / 2^k| = 1 - m / 2^k = (2^k - m) / 2^k$.
      have h_tent : tent (j / 2 ^ (k + 1)) = (2 ^ k - m) / 2 ^ k := by
        unfold tent; push_cast [ hm ] ; ring; norm_num [ pow_succ' ] ;
        norm_num [ ← mul_pow ];
        ring;
      convert ih ( 2 ^ k - m ) ( Nat.sub_le _ _ ) using 1;
      · rw [ Nat.cast_sub hm.2 ] ; aesop;
      · cases k <;> cases m <;> simp_all +decide [ Nat.pow_succ' ];
        omega

/-
Adjacent dyadic nodes of the deep tent differ by exactly `1`.
-/
theorem tent_dyadic_consecutive_diff (k i : ℕ) (hi : i + 1 ≤ 2 ^ k) :
    |tent^[k] (((i : ℝ) + 1) / 2 ^ k) - tent^[k] ((i : ℝ) / 2 ^ k)| = 1 := by
  rw [ show ( ( i : ℝ ) + 1 ) / 2 ^ k = ( i + 1 : ℕ ) / 2 ^ k by norm_cast, tent_iterate_dyadic, tent_iterate_dyadic ] <;> norm_cast;
  · cases Nat.mod_two_eq_zero_or_one i <;> simp +decide [ *, Nat.add_mod ];
  · grind

/-
**The deep tent has discrete total variation exactly `2^k`.**
-/
theorem tent_discreteTV (k : ℕ) : discreteTV k (tent^[k]) = 2 ^ k := by
  convert Finset.sum_congr rfl fun i hi => tent_dyadic_consecutive_diff k i ?_;
  · norm_num;
  · linarith [ Finset.mem_range.mp hi ]

/-
**Shallow nets have total variation bounded by their L¹ weight mass.**
For any dyadic grid, `discreteTV k (shallowNet w a t c) ≤ ∑_j |a_j|`.
-/
theorem shallowNet_discreteTV_le (k w : ℕ) (a t : Fin w → ℝ) (c : ℝ) :
    discreteTV k (shallowNet w a t c) ≤ ∑ j : Fin w, |a j| := by
  refine' le_trans ( Finset.sum_le_sum _ ) _;
  use fun i => ∑ j, |a j| * ( 1 / 2 ^ k );
  · intro i hi; unfold shallowNet; simp +decide;
    rw [ ← Finset.sum_sub_distrib ];
    refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun j _ => _ );
    have := ramp_diff_bound ( t j ) ( i / 2 ^ k ) ( ( i + 1 ) / 2 ^ k ) ( by gcongr ; linarith ) ; simp_all +decide [ ← mul_sub, abs_mul ] ;
    exact mul_le_mul_of_nonneg_left ( abs_le.mpr ⟨ by ring_nf at *; linarith, by ring_nf at *; linarith ⟩ ) ( abs_nonneg _ );
  · norm_num [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ]

/-
An `ε`-approximant inherits total variation at least `2^k (1 - 2ε)`.
-/
theorem discreteTV_ge_of_approx (k : ℕ) (g : ℝ → ℝ) (ε : ℝ)
    (happ : ∀ i ≤ 2 ^ k, |tent^[k] ((i : ℝ) / 2 ^ k) - g ((i : ℝ) / 2 ^ k)| ≤ ε) :
    (2 : ℝ) ^ k * (1 - 2 * ε) ≤ discreteTV k g := by
  refine' le_trans _ ( Finset.sum_le_sum fun i hi => show |g ( ( i + 1 ) / 2 ^ k ) - g ( i / 2 ^ k )| ≥ 1 - 2 * ε from _ );
  · norm_num;
    linarith;
  · -- By the properties of the tent map and the hypothesis `happ`, we have:
    have h_tent : |tent^[k] (((i + 1) : ℝ) / 2 ^ k) - g (((i + 1) : ℝ) / 2 ^ k)| ≤ ε ∧ |tent^[k] ((i : ℝ) / 2 ^ k) - g ((i : ℝ) / 2 ^ k)| ≤ ε := by
      exact ⟨ by simpa using happ ( i + 1 ) ( by norm_cast; linarith [ Finset.mem_range.mp hi ] ), by simpa using happ i ( by norm_cast; linarith [ Finset.mem_range.mp hi ] ) ⟩;
    have h_tent_diff : |tent^[k] (((i + 1) : ℝ) / 2 ^ k) - tent^[k] ((i : ℝ) / 2 ^ k)| = 1 := by
      convert tent_dyadic_consecutive_diff k i ( by linarith [ Finset.mem_range.mp hi ] ) using 1;
    grind +qlia

/-- **Depth–width separation (weight form).** Any shallow ReLU network that
approximates the depth-`k` tent to accuracy `ε < 1/2` at all dyadic nodes must
carry L¹ weight mass at least `2^k (1 - 2ε)` — exponential in the depth. -/
theorem depth_separation_weight_lower_bound (k w : ℕ) (a t : Fin w → ℝ) (c ε : ℝ)
    (happ : ∀ i ≤ 2 ^ k,
      |tent^[k] ((i : ℝ) / 2 ^ k) - shallowNet w a t c ((i : ℝ) / 2 ^ k)| ≤ ε) :
    (2 : ℝ) ^ k * (1 - 2 * ε) ≤ ∑ j : Fin w, |a j| := by
  have h1 := discreteTV_ge_of_approx k (shallowNet w a t c) ε happ
  have h2 := shallowNet_discreteTV_le k w a t c
  linarith

/-- **Depth–width separation (width form).** If additionally every neuron weight
is bounded by `A > 0`, then approximating the depth-`k` tent to accuracy
`ε < 1/2` forces width `w ≥ 2^k (1 - 2ε) / A`. -/
theorem depth_separation_width_lower_bound (k w : ℕ) (a t : Fin w → ℝ) (c ε A : ℝ)
    (hA : 0 < A) (hbound : ∀ j, |a j| ≤ A)
    (happ : ∀ i ≤ 2 ^ k,
      |tent^[k] ((i : ℝ) / 2 ^ k) - shallowNet w a t c ((i : ℝ) / 2 ^ k)| ≤ ε) :
    (2 : ℝ) ^ k * (1 - 2 * ε) / A ≤ (w : ℝ) := by
  have hweight := depth_separation_weight_lower_bound k w a t c ε happ
  have hsum : ∑ j : Fin w, |a j| ≤ (w : ℝ) * A := by
    calc ∑ j : Fin w, |a j| ≤ ∑ _j : Fin w, A := by
            exact Finset.sum_le_sum (fun j _ => hbound j)
      _ = (w : ℝ) * A := by rw [Finset.sum_const]; simp [mul_comm]
  rw [div_le_iff₀ hA]
  linarith

end MachineLearning.UniversalApproximation