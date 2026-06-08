import Mathlib
import Speculative.BenfordQuadratic.Defs
import Speculative.BenfordQuadratic.Bounds

/-!
# Convergence of Renormalized Logarithmic Height

## Overview

This file proves that for escaping orbits of the quadratic map T_c(x) = x² + c,
the renormalized logarithmic height sequence

  aₙ = 2⁻ⁿ · log|T_c⁽ⁿ⁾(x)|

converges. This constructs a discrete Böttcher coordinate without importing complex
dynamics—it is the renormalization invariant that governs Benford statistics.

## Proof Architecture

Using the escape growth inequality from `Bounds.lean`:
1. Show |aₙ₊₁ - aₙ| ≤ C/2ⁿ⁺¹ eventually (from the log deviation bound).
2. Telescope: |aₘ - aₙ| ≤ Σ_{k=n}^{m-1} C/2^{k+1}.
3. Bound the geometric sum to show the sequence is Cauchy.
4. Extract the limit by completeness of ℝ.

## Cross-domain significance

The limiting value Λ_c(x) = lim aₙ is the discrete canonical height. It satisfies
the functional equation Λ_c(T_c(x)) = 2·Λ_c(x), making it a semiconjugacy from
T_c to the doubling map in logarithmic coordinates.
-/

noncomputable section

open Real Filter Topology Set

/-
Step bound: the difference between consecutive renormalized log-heights is bounded
by (log 2)/2^(n+1) for orbit points in the escape region. This is the key estimate
that makes the telescoping argument work.

Specifically, if |quadOrbit c x n| ≥ |c| + 2, then
  |renormLogHeight c x (n+1) - renormLogHeight c x n| ≤ log 2 / 2^(n+1).
-/
theorem renormLogHeight_step_bound
    (c x : ℤ) (n : ℕ)
    (hlarge : Int.natAbs (quadOrbit c x n) ≥ Int.natAbs c + 2) :
    |renormLogHeight c x (n + 1) - renormLogHeight c x n| ≤ Real.log 2 / 2 ^ (n + 1) := by
  convert div_le_div_of_nonneg_right ( quad_log_deviation_bound c ( quadOrbit c x n ) hlarge ) ( pow_nonneg zero_le_two ( n + 1 ) ) using 1 ; norm_num [ renormLogHeight ] ; ring;
  cases abs_cases ( logHeight ( quadMap c ( quadOrbit c x n ) ) - logHeight ( quadOrbit c x n ) * 2 ) <;> cases abs_cases ( logHeight ( quadMap c ( quadOrbit c x n ) ) * 2⁻¹ ^ n * ( 1 / 2 ) - 2⁻¹ ^ n * logHeight ( quadOrbit c x n ) ) <;> nlinarith [ pow_pos ( by norm_num : ( 0 : ℝ ) < 2⁻¹ ) n ]

/-
For escaping orbits, the renormalized log-height sequence converges.
This is the central convergence theorem: the existence of the canonical height.
-/
theorem exists_limit_renormLogHeight
    (c x : ℤ)
    (hesc : Escapes c x) :
    ∃ L : ℝ, Tendsto (renormLogHeight c x) atTop (nhds L) := by
  -- By definition of Escapes, there exists N such that for all n ≥ N, |quadOrbit c x n| ≥ |c| + 2.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ n ≥ N, (quadOrbit c x n).natAbs ≥ (c.natAbs + 2) := by
    exact ⟨ hesc.choose + 1, fun n hn => by linarith [ hesc.choose_spec n ( by linarith ), le_max_right 2 ( Int.natAbs c + 1 ) ] ⟩;
  -- Using the step bound, show that the sequence is Cauchy.
  have h_cauchy : CauchySeq (fun n => renormLogHeight c x (n + N)) := by
    -- Apply the step bound to each term in the sequence.
    have h_step_bound : ∀ n, |renormLogHeight c x (n + N + 1) - renormLogHeight c x (n + N)| ≤ Real.log 2 / 2 ^ (n + N + 1) := by
      exact fun n => renormLogHeight_step_bound c x ( n + N ) ( hN _ ( by linarith ) );
    fapply cauchySeq_of_le_geometric;
    exacts [ 1 / 2, Real.log 2 / 2 ^ ( N + 1 ), by norm_num, fun n => by rw [ dist_comm ] ; simpa [ add_comm, add_left_comm, add_assoc, pow_add, div_eq_mul_inv, mul_assoc, mul_comm, mul_left_comm ] using h_step_bound n ];
  rcases cauchySeq_tendsto_of_complete h_cauchy with ⟨ L, hL ⟩;
  exact ⟨ L, by simpa only [ Filter.tendsto_add_atTop_iff_nat ] using hL ⟩

end