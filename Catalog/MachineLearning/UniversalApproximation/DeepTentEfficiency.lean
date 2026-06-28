/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Deep ReLU Efficiency: the Constant-Width / Logarithmic-Size Upper Bound

The catalog file `MachineLearning.UniversalApproximation.TentDepthSeparation`
proves the **shallow lower bound** of the width–depth tradeoff: any
single-hidden-layer ReLU network matching the depth-`k` tent `tent^[k]` to
accuracy `ε < 1/2` (under a per-neuron weight cap `A`) needs width
`≥ 2^k (1 - 2ε) / A`, i.e. *exponential* in the depth.

This file supplies the matching **deep upper bound**, turning the one-sided
lower bound into a genuine two-sided separation:

* the tent map is *exactly* a 2-ReLU-neuron block, `tent x = 1 - relu(2x-1) -
  relu(1-2x)` (`tentBlock_eval`), using `|y| = relu y + relu (-y)`;
* therefore `tent^[k]` is realized by `k` stacked copies of that block — a depth
  `k`, constant-width-`2` network of *total size* `2k` (`deepTent_realizes`,
  `deepTent_size`);
* the same network has discrete total variation exactly `2^k`
  (`deepTent_discreteTV`), i.e. `2^k` oscillations from only `2k` neurons —
  size grows *logarithmically* in the oscillation count (`deep_size_log`).

The capstone `depth_width_separation` states both sides at once: a network of
size `2k` realizes a target that *forces* shallow width `≥ 2^k(1-2ε)/A`.

## Formalism

A scalar `ReLUBlock` is a map `x ↦ c + Σ_{j<m} a_j · relu (w_j x - t_j)`; its
`size` is the neuron count `m`. A deep network is a `List ReLUBlock` evaluated by
composition (`evalNet`), with `netSize` the sum of block sizes.

-- !-- Lab Notes -- !--
Hypothesis: the exponential *shallow* width forced by `tent^[k]` is paid for, on
  the deep side, by only `O(k)` neurons; concretely the tent is one 2-neuron
  block and `tent^[k]` is its `k`-fold stack. So the separation is genuinely
  two-sided: size `2k` deep vs width `Ω(2^k)` shallow.
Experiment: introduce a scalar `ReLUBlock`/`evalNet`/`netSize` formalism, prove
  the algebraic identity `tentBlock.eval = tent` via `|y| = relu y + relu (-y)`,
  then lift to `tent^[k]` by induction using `Function.iterate_succ'`. Reuse the
  catalog's `tent_discreteTV` and `depth_separation_width_lower_bound` verbatim
  for the total-variation count and the shallow lower bound.
Analysis: the decisive identity is purely algebraic (no continuity / IVT), so the
  realization is *exact*, not approximate — `evalNet (deepTent k) = tent^[k]` as
  functions. The "logarithmic size" law `netSize (deepTent k) = 2 · log₂ (2^k)`
  is then immediate from `Nat.log_pow`.
Critique: the formalism is scalar (1-D in / 1-D out per block), matching the
  catalog's 1-D tent; multi-input blocks would be needed for the `[-1,1]^n`
  statement (left to FUTURE_DIRECTIONS). The size measure counts hidden neurons,
  which is the standard notion for the tradeoff. The strict numeric gap
  `2k < 2^k` holds only for `k ≥ 3` (checked: `k = 0,1,2` give equality up to
  `6 < 8`), so the asymptotic statement is guarded accordingly.
Synthesis: depth converts a linear neuron budget into an exponential oscillation
  budget; this file certifies the conversion rate (`2k ↦ 2^k`) exactly and pairs
  it with the catalog's matching shallow obstruction.
-- !-- -- !--
-/
import Mathlib
import MachineLearning.UniversalApproximation.TentDepthSeparation

namespace MachineLearning.UniversalApproximation

open Finset Function

/-- A scalar ReLU block: `x ↦ c + Σ_{j<m} a_j · relu (w_j x - t_j)`. -/
structure ReLUBlock where
  /-- number of hidden neurons -/
  m : ℕ
  /-- output bias -/
  c : ℝ
  /-- output weights -/
  a : Fin m → ℝ
  /-- input weights -/
  w : Fin m → ℝ
  /-- neuron thresholds -/
  t : Fin m → ℝ

/-- Evaluate a block. -/
noncomputable def ReLUBlock.eval (B : ReLUBlock) (x : ℝ) : ℝ :=
  B.c + ∑ j : Fin B.m, B.a j * relu (B.w j * x - B.t j)

/-- Number of hidden neurons in a block. -/
def ReLUBlock.size (B : ReLUBlock) : ℕ := B.m

/-- Evaluate a deep network (list of blocks) by composition. -/
noncomputable def evalNet : List ReLUBlock → ℝ → ℝ
  | [], x => x
  | B :: L, x => B.eval (evalNet L x)

/-- Total number of hidden neurons in a deep network. -/
def netSize (L : List ReLUBlock) : ℕ := (L.map ReLUBlock.size).sum

/-- The tent map as a single 2-neuron ReLU block:
`1 - relu(2x-1) - relu(-2x+1)`. -/
noncomputable def tentBlock : ReLUBlock :=
  { m := 2, c := 1, a := ![-1, -1], w := ![2, -2], t := ![1, -1] }

/-- The depth-`k` deep tent network: `k` stacked copies of `tentBlock`. -/
noncomputable def deepTent (k : ℕ) : List ReLUBlock := List.replicate k tentBlock

/-
**The tent map is exactly a 2-neuron ReLU block.**
-/
theorem tentBlock_eval (x : ℝ) : tentBlock.eval x = tent x := by
  unfold tentBlock; norm_num [ tent, ReLUBlock.eval ] ;
  erw [ Fin.sum_univ_two ] ; norm_num [ relu ] ; ring;
  grind

/-- The empty network is the identity. -/
@[simp] theorem evalNet_nil (x : ℝ) : evalNet [] x = x := rfl

/-
**`tent^[k]` is realized exactly by the depth-`k` deep tent network.**
-/
theorem deepTent_realizes (k : ℕ) : evalNet (deepTent k) = tent^[k] := by
  induction' k with k ih;
  · rfl
  · ext x; simp +decide [ *, Function.iterate_succ_apply', deepTent ] ;
    rw [ ← ih, show evalNet ( List.replicate ( k + 1 ) tentBlock ) x = tentBlock.eval ( evalNet ( deepTent k ) x ) from rfl, tentBlock_eval ]

/-
**The deep tent network has total size `2k`** — constant width `2`, depth `k`.
-/
theorem deepTent_size (k : ℕ) : netSize (deepTent k) = 2 * k := by
  unfold netSize deepTent; norm_num [ mul_comm ] ;
  exact Or.inl rfl

/-
The deep tent network has discrete total variation `2^k` (catalog count).
-/
theorem deepTent_discreteTV (k : ℕ) :
    discreteTV k (evalNet (deepTent k)) = 2 ^ k := by
      rw [ deepTent_realizes, tent_discreteTV ]

/-
**Logarithmic-size law.** The deep network realizing `2^k` oscillations uses
`2 · log₂(2^k) = 2k` neurons: size grows logarithmically in the oscillation count.
-/
theorem deep_size_log (k : ℕ) :
    netSize (deepTent k) = 2 * Nat.log 2 (2 ^ k) := by
      rw [ Nat.log_pow ] <;> norm_num [ deepTent_size ]

/-
For `k ≥ 3` the deep size `2k` is *strictly* below the oscillation count `2^k`.
-/
theorem two_mul_lt_two_pow (k : ℕ) (hk : 3 ≤ k) : 2 * k < 2 ^ k := by
  induction hk <;> norm_num [ Nat.pow_succ ] at * ; linarith

/-
**Two-sided width–depth separation.**

A depth-`k`, constant-width-`2` network of total size `2k` realizes the target
`tent^[k]`; yet *any* shallow (single-hidden-layer) ReLU network that
approximates that same target to accuracy `ε < 1/2`, with every weight bounded by
`A > 0`, must have width at least `2^k (1 - 2ε) / A`. Linear (in depth) deep size
versus exponential shallow width.
-/
theorem depth_width_separation (k w : ℕ) (a t : Fin w → ℝ) (c ε A : ℝ)
    (hA : 0 < A) (hbound : ∀ j, |a j| ≤ A)
    (happ : ∀ i ≤ 2 ^ k,
      |evalNet (deepTent k) ((i : ℝ) / 2 ^ k)
        - shallowNet w a t c ((i : ℝ) / 2 ^ k)| ≤ ε) :
    netSize (deepTent k) = 2 * k ∧
      (2 : ℝ) ^ k * (1 - 2 * ε) / A ≤ (w : ℝ) := by
        convert depth_separation_width_lower_bound k w a t c ε A hA hbound _;
        · rw [ deepTent_size ] ; norm_num;
        · simpa only [ deepTent_realizes ] using happ

end MachineLearning.UniversalApproximation