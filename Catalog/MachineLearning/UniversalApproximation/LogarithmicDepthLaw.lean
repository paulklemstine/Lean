/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# The Width–Depth Gap Is Unbounded

`MachineLearning.UniversalApproximation.DeepTentEfficiency` certifies both sides
of the tradeoff for the depth-`k` tent: a deep network of total size `2k`
(`deepTent_size`) realizes a target (`deepTent_realizes`) that forces *any*
shallow `ε`-approximant (`ε < 1/2`, weight cap `A`) to width `≥ 2^k(1-2ε)/A`
(`depth_width_separation`).

This file shows the gap between the two is **unbounded**: for any ratio `R`,
there is a depth `k` at which the forced shallow width exceeds `R` times the deep
size `2k`. The engine is the elementary growth fact that `2^k` eventually
dominates any linear function of `k` (`linear_lt_two_pow`, via `sq_le_two_pow`).

## Main results

* `sq_le_two_pow` — `k^2 ≤ 2^k` for `k ≥ 4`.
* `linear_lt_two_pow` — for every real `C`, some `k` has `C·k < 2^k`.
* `width_depth_gap_unbounded` — for `0 < A`, `ε < 1/2`, and any `R`, there is a
  depth `k` such that every shallow `ε`-approximant of `deepTent k` has width
  `> R · netSize (deepTent k)`. The deep size is `O(log)` in the oscillation
  count while the shallow width is `Ω(2^k)`, so the quotient diverges.

-- !-- Lab Notes -- !--
Hypothesis: the two-sided bound `size 2k` vs `width ≥ 2^k(1-2ε)/A` is not just a
  fixed-`k` separation but an asymptotic one — the ratio shallow/deep diverges.
Experiment: isolate the purely arithmetic core `C·k < 2^k` (real `C`), proved by
  reducing to `k^2 ≤ 2^k` for `k ≥ 4` (Nat induction) and choosing `k` above both
  `4` and `C`. Then feed `C = 2RA/(1-2ε)` into `depth_width_separation`.
Analysis: the divergence is genuinely exponential-over-linear; the constant
  `2RA/(1-2ε)` shows exactly how the threshold `R`, the weight cap `A`, and the
  accuracy margin `1-2ε` enter. The guard `ε < 1/2` is essential — at `ε = 1/2`
  the constant `1/2` approximates everything and the lower bound collapses.
Critique: `R` is allowed to be any real (negative `R` makes the claim trivially
  hold, which is fine); the substance is large positive `R`. The proof never uses
  continuity, only the algebraic realization and the catalog weight bound.
Synthesis: depth's logarithmic neuron cost vs shallow's linear-in-oscillation
  cost makes the advantage of depth grow past every bound.
-- !-- -- !--
-/
import Mathlib
import MachineLearning.UniversalApproximation.DeepTentEfficiency

namespace MachineLearning.UniversalApproximation

open Finset

/-
`k^2 ≤ 2^k` for all `k ≥ 4`.
-/
theorem sq_le_two_pow (k : ℕ) (hk : 4 ≤ k) : k ^ 2 ≤ 2 ^ k := by
  induction' hk with k hk ih <;> norm_num [ Nat.pow_succ' ] at * ; nlinarith

/-
`2^k` eventually dominates any linear function `C·k`.
-/
theorem linear_lt_two_pow (C : ℝ) : ∃ k : ℕ, C * (k : ℝ) < 2 ^ k := by
  cases' exists_nat_gt C with k hk;
  use 4 * k + 4;
  norm_num [ pow_add, pow_mul ];
  nlinarith [ show ( 16 : ℝ ) ^ k ≥ ↑k ^ 2 + 1 by exact mod_cast Nat.recOn k ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ' ] at * ; nlinarith ]

/-
**The width–depth gap is unbounded.**

Fix a weight cap `A > 0`, an accuracy `ε < 1/2`, and any ratio `R`. There is a
depth `k` such that every shallow ReLU network that approximates the depth-`k`
deep tent `deepTent k` to accuracy `ε` (with all weights bounded by `A`) has
width strictly greater than `R` times the deep network's size `netSize (deepTent k)
= 2k`. Since the deep size is logarithmic in the oscillation count `2^k`, the
ratio of shallow width to deep size diverges.
-/
theorem width_depth_gap_unbounded (A ε R : ℝ) (hA : 0 < A) (hε : ε < 1 / 2) :
    ∃ k : ℕ, ∀ (w : ℕ) (a t : Fin w → ℝ) (c : ℝ),
      (∀ j, |a j| ≤ A) →
      (∀ i ≤ 2 ^ k,
        |evalNet (deepTent k) ((i : ℝ) / 2 ^ k)
          - shallowNet w a t c ((i : ℝ) / 2 ^ k)| ≤ ε) →
      R * (netSize (deepTent k) : ℝ) < (w : ℝ) := by
        -- Let δ = 1 - 2*ε > 0 (from hε : ε < 1/2). Set C = 2 * R * A / δ.
        set δ : ℝ := 1 - 2 * ε
        have hδ_pos : 0 < δ := by
          exact sub_pos_of_lt ( by linarith )
        set C : ℝ := 2 * R * A / δ;
        obtain ⟨ k, hk ⟩ := linear_lt_two_pow C;
        refine' ⟨ k, fun w a t c ha hb => _ ⟩;
        -- By depth_width_separation, we have w ≥ 2^k * δ / A.
        have h_w_ge : (w : ℝ) ≥ 2 ^ k * δ / A := by
          apply depth_separation_width_lower_bound k w a t c ε A hA ha;
          intro i hi; specialize hb i hi; rw [ ← deepTent_realizes k ] at *; aesop;
        rw [ deepTent_size ];
        rw [ ge_iff_le, div_le_iff₀ ] at h_w_ge <;> norm_num at * <;> nlinarith [ mul_div_cancel₀ ( 2 * R * A ) hδ_pos.ne' ]

end MachineLearning.UniversalApproximation