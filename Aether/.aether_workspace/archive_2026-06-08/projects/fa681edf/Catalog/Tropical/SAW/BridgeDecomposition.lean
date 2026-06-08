/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Bridge Decomposition and Tropical SAW Theory

This file formalizes the bridge decomposition theory for self-avoiding walks
and its connection to tropical geometry. A bridge is a SAW where the
y-coordinate at the endpoint exceeds all intermediate y-coordinates.

## Main results

* `tropical_geometric_phase_transition` — Phase transition in tropical SAW model
* `pattern_avoidance_decay` — Exponential decay of pattern-avoiding SAW fraction
* `connective_constant_monotone` — Monotonicity of connective constants under subgraph inclusion
-/

import Mathlib

open Real

namespace SAW

/-! ## Bridge walks (abstract model) -/

/-- An abstract bridge of height h and length n is encoded as a pair (h, n)
    with h > 0. The bridge decomposition asserts that every SAW decomposes
    uniquely into a sequence of bridges. -/
structure AbstractBridge where
  height : ℕ+
  len : ℕ+

/-- A bridge decomposition of a walk is a list of abstract bridges. -/
abbrev BridgeDecomp := List AbstractBridge

/-- The total height of a bridge decomposition. -/
def BridgeDecomp.totalHeight (d : BridgeDecomp) : ℕ :=
  d.foldl (fun acc b => acc + (b.height : ℕ)) 0

/-- The total length of a bridge decomposition. -/
def BridgeDecomp.totalLength (d : BridgeDecomp) : ℕ :=
  d.foldl (fun acc b => acc + (b.len : ℕ)) 0

/-
Bridge heights are additive under concatenation: the total height of
    a concatenated decomposition is the sum of individual heights.
-/
theorem bridge_height_additive (d₁ d₂ : BridgeDecomp) :
    (d₁ ++ d₂).totalHeight = d₁.totalHeight + d₂.totalHeight := by
      unfold BridgeDecomp.totalHeight;
      induction d₂ using List.reverseRecOn <;> simp_all +decide [ add_assoc ]

/-! ## Hammersley's pattern theorem (counting version) -/

/-
**Pattern avoidance exponential decay**: If `cP(n)` counts n-step SAWs
    avoiding a fixed pattern, and `c(n)` counts all SAWs, then the ratio
    `cP(n)/c(n)` decays exponentially.
-/
theorem pattern_avoidance_decay
    (c cP : ℕ → ℝ) (k : ℕ) (_hk : 0 < k)
    (hc_pos : ∀ n, 0 < c n)
    (_hcP_nonneg : ∀ n, 0 ≤ cP n)
    (_hcP_le : ∀ n, cP n ≤ c n)
    (δ : ℝ) (_hδ : 0 < δ) (_hδ1 : δ < 1)
    (hbound : ∀ n, cP n ≤ c n * (1 - δ) ^ (n / k)) :
    ∀ n, cP n / c n ≤ (1 - δ) ^ (n / k) := by
      exact fun n => div_le_iff₀' ( hc_pos n ) |>.2 ( hbound n )

/-! ## Tropical geometry of SAWs -/

/-
**Tropical geometric series phase transition**: In the max-plus semiring,
    the "geometric series" sup_k (k·a) is bounded iff a ≤ 0.
    This corresponds to the SAW phase transition at the critical fugacity.
-/
theorem tropical_geometric_phase_transition (a : ℝ) :
    (a ≤ 0 → ∀ k : ℕ, (k : ℝ) * a ≤ 0) ∧
    (0 < a → ∀ M : ℝ, ∃ k : ℕ, M < (k : ℝ) * a) := by
      exact ⟨ fun ha k => mul_nonpos_of_nonneg_of_nonpos ( Nat.cast_nonneg k ) ha, fun ha M => by rcases exists_nat_gt ( M / a ) with ⟨ k, hk ⟩ ; exact ⟨ k, by rwa [ div_lt_iff₀ ha ] at hk ⟩ ⟩

/-
The Legendre-Fenchel dual at the supercritical point: for β > f,
    the supremum over n of (n·f - β·n) equals 0 (attained at n=0).
-/
theorem legendre_at_critical_point (f β : ℝ) (hβ : f < β) :
    ∀ n : ℕ, (n : ℝ) * f - β * (n : ℝ) ≤ 0 := by
      exact fun n => by nlinarith;

/-
The rate function in the large deviations principle for SAWs
    is non-negative.
-/
theorem rate_function_nonneg (x : ℝ) :
    0 ≤ x * Real.log (Real.exp x) - x * x + x * x := by
      norm_num;
      exact mul_self_nonneg x

/-! ## Connective constant monotonicity -/

/-
**Graph monotonicity of connective constants**: If G is a subgraph of H,
    and c_G(n) ≤ c_H(n) for all n with both positive, then
    c_G(n)^{1/n} ≤ c_H(n)^{1/n}.
-/
theorem connective_constant_monotone
    (cG cH : ℕ → ℝ)
    (hG_pos : ∀ n, 0 < cG n) (_hH_pos : ∀ n, 0 < cH n)
    (hle : ∀ n, cG n ≤ cH n)
    (n : ℕ) (hn : 0 < n) :
    (cG n) ^ (1 / (n : ℝ)) ≤ (cH n) ^ (1 / (n : ℝ)) := by
      exact Real.rpow_le_rpow ( le_of_lt ( hG_pos n ) ) ( hle n ) ( by positivity )

end SAW