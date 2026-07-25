/-
Copyright (c) 2026 Stereographic Neural Attention Research Team. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Neural Attention — Sparsity of the Cauchy kernel

Building on `StereographicAttention.Core`, this file establishes the *sparsity*
behaviour of stereographic attention.  The headline conjecture of the program is
that the Cauchy kernel produces approximately `√N`-sparse attention rows.  Here we
prove the rigorous backbone of that claim:

* an exact **active-region characterization**: a key is "active" at threshold `τ`
  iff it lies in a ball of radius `√(1/τ - 1)` around the query;
* **monotonicity**: closer keys always score higher (the score is a strictly
  decreasing function of distance);
* a **Markov sparsity bound**: the number of keys whose score reaches `τ` is at
  most `(total score) / τ`, equivalently `τ · #active ≤ Σ scores`;
* a clean corollary `τ · #active ≤ N` since every score is `≤ 1`.

The deterministic Markov bound is the rigorous core; the `√N` refinement (needing a
geometric bound `Σ scores = O(√N)` for spread-out keys) is recorded as a conjecture
in `FUTURE_DIRECTIONS.md`.

-- !-- Lab Notebook: StereographicAttention.Sparsity -- !--
-- !-- Hypothesis: Cauchy attention is intrinsically sparse — far keys get          -- !--
-- !--   near-zero weight, so few keys are "active" at any fixed threshold.          -- !--
-- !-- Result: proved the active-region ball characterization, monotonicity, and a  -- !--
-- !--   Markov bound τ·#active ≤ Σ scores ≤ N.                                      -- !--
-- !-- Insight: sparsity is two facts glued together — (1) activity = membership in  -- !--
-- !--   a metric ball (geometry), (2) Markov on nonnegative scores (analysis).      -- !--
-- !--   The √N story is exactly the gap between Σ scores ≤ N and Σ scores = O(√N).  -- !--
-- !-- Failure analysis: the Markov step does NOT need τ>0 in the `τ·#active ≤ Σ`    -- !--
-- !--   form; positivity of τ only re-enters when dividing to read off #active.     -- !--
-- !-- End Lab Notebook -- !--
-/

import Mathlib

open scoped BigOperators

namespace StereographicAttention

variable {E : Type*} [NormedAddCommGroup E]

/-- The **Cauchy attention kernel** `K(q,k) = 1 / (1 + ‖q - k‖²)` (see
`StereographicAttention.Core` for the geometric development).  Re-stated here so this
file is self-contained for independent checking. -/
noncomputable def cauchyKernel (q k : E) : ℝ := 1 / (1 + ‖q - k‖ ^ 2)

-- !-- Lab Notebook: cauchyKernel_active_iff -- !--
-- !-- Hypothesis: the τ-active set is exactly a metric ball around the query.       -- !--
-- !-- Result: proved. τ ≤ 1/(1+s) ⇔ s ≤ 1/τ - 1, with s = ‖q-k‖².                  -- !--
-- !-- Insight: this turns the "select important keys" step into a range query in   -- !--
-- !--   Euclidean space — the hook for sub-linear nearest-neighbour retrieval.      -- !--
-- !-- End Lab Notebook -- !--
-- !-- A key is active at threshold τ iff it lies in the ball ‖q-k‖² ≤ 1/τ - 1. -- !--
theorem cauchyKernel_active_iff (q k : E) {τ : ℝ} (hτ : 0 < τ) :
    τ ≤ cauchyKernel q k ↔ ‖q - k‖ ^ 2 ≤ 1 / τ - 1 := by
  unfold cauchyKernel
  rw [le_div_iff₀ (by positivity)]
  have hτinv : τ * (1 / τ) = 1 := by field_simp
  constructor
  · intro h; nlinarith [mul_pos hτ (show (0:ℝ) < 1 / τ by positivity)]
  · intro h; nlinarith [mul_le_mul_of_nonneg_left h (le_of_lt hτ)]

-- !-- Closer keys score at least as high: K is antitone in the query–key distance. -- !--
theorem cauchyKernel_antitone (q k₁ k₂ : E) (h : ‖q - k₁‖ ≤ ‖q - k₂‖) :
    cauchyKernel q k₂ ≤ cauchyKernel q k₁ := by
  unfold cauchyKernel
  apply one_div_le_one_div_of_le
  · positivity
  · have hsq : ‖q - k₁‖ ^ 2 ≤ ‖q - k₂‖ ^ 2 := by
      nlinarith [norm_nonneg (q - k₁), norm_nonneg (q - k₂)]
    linarith

-- !-- The total attention mass over N keys is at most N (each score ≤ 1). -- !--
theorem cauchy_total_weight_le {N : ℕ} (q : E) (key : Fin N → E) :
    (∑ i, cauchyKernel q (key i)) ≤ (N : ℝ) := by
  have hle : ∀ i, cauchyKernel q (key i) ≤ 1 := by
    intro i
    unfold cauchyKernel
    rw [div_le_one (by positivity)]
    nlinarith [sq_nonneg ‖q - key i‖]
  calc (∑ i, cauchyKernel q (key i)) ≤ ∑ _i : Fin N, (1 : ℝ) :=
        Finset.sum_le_sum (fun i _ => hle i)
    _ = (N : ℝ) := by simp

-- !-- Lab Notebook: cauchy_sparsity_markov -- !--
-- !-- Hypothesis: #{keys with score ≥ τ} ≤ (Σ scores)/τ.                           -- !--
-- !-- Result: proved by summing the constant τ over the active set, dominating it  -- !--
-- !--   pointwise by the scores, then extending the sum to all keys (nonneg).       -- !--
-- !-- Insight: this is the falsifiable sparsity backbone. Pair with a bound         -- !--
-- !--   Σ scores ≤ C·√N to obtain the conjectured #active = O(√N/τ).               -- !--
-- !-- Failure analysis: stating it as `τ·#active ≤ Σ` (no division) keeps the proof -- !--
-- !--   division-free and robust, so it needs NO τ>0 hypothesis; positivity of τ    -- !--
-- !--   re-enters only when one divides by τ to read off #active ≤ (Σ scores)/τ.    -- !--
-- !-- End Lab Notebook -- !--
-- !-- MAIN SPARSITY THEOREM: at most (Σ scores)/τ keys can be τ-active. -- !--
theorem cauchy_sparsity_markov {N : ℕ} (q : E) (key : Fin N → E) (τ : ℝ) :
    τ * ((Finset.univ.filter (fun i => τ ≤ cauchyKernel q (key i))).card : ℝ)
      ≤ ∑ i, cauchyKernel q (key i) := by
  have hpos : ∀ i, 0 ≤ cauchyKernel q (key i) := fun i => by unfold cauchyKernel; positivity
  calc τ * ((Finset.univ.filter (fun i => τ ≤ cauchyKernel q (key i))).card : ℝ)
      = ∑ _i ∈ Finset.univ.filter (fun i => τ ≤ cauchyKernel q (key i)), τ := by
        rw [Finset.sum_const, nsmul_eq_mul, mul_comm]
    _ ≤ ∑ i ∈ Finset.univ.filter (fun i => τ ≤ cauchyKernel q (key i)), cauchyKernel q (key i) :=
        Finset.sum_le_sum (fun i hi => (Finset.mem_filter.mp hi).2)
    _ ≤ ∑ i, cauchyKernel q (key i) :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
          (fun i _ _ => hpos i)

-- !-- Combined bound: at most N/τ keys are ever active (Markov ∘ total-mass). -- !--
theorem cauchy_sparsity_card_le {N : ℕ} (q : E) (key : Fin N → E) (τ : ℝ) :
    τ * ((Finset.univ.filter (fun i => τ ≤ cauchyKernel q (key i))).card : ℝ) ≤ (N : ℝ) :=
  le_trans (cauchy_sparsity_markov q key τ) (cauchy_total_weight_le q key)

-- !-- Lab Notebook: cauchy_sublinear_mass_conjecture (GENERALIZATION LOOP) -- !--
-- !-- Hypothesis: for δ-separated keys in ℝ^d (d ≥ 3) the total Cauchy mass is     -- !--
-- !--   SUBLINEAR: Σ scores ≤ C·N^((d-2)/d), uniformly in N.                       -- !--
-- !-- Result: stated as a conjecture (sorry). A shell-counting heuristic gives the  -- !--
-- !--   exponent: ≈(ρ/δ)^d keys fill radius ρ, mass ≈ ∫ r^{d-1}/(1+r²) dr ≈ ρ^{d-2}, -- !--
-- !--   and ρ ≈ δ·N^{1/d}, hence ρ^{d-2} ≈ N^{(d-2)/d}.                             -- !--
-- !-- Insight: the program's advertised O(√N) is the d=4 SPECIAL CASE              -- !--
-- !--   ((d-2)/d = 1/2 ⇔ d = 4); generic dimension gives N^{(d-2)/d}, which → N as  -- !--
-- !--   d → ∞. So Cauchy sparsity degrades with dimension — a falsifiable claim.    -- !--
-- !-- Failure analysis: the bound is FALSE in a general normed space (infinitely    -- !--
-- !--   many δ-separated unit vectors equidistant from q force Σ = Θ(N)); finite    -- !--
-- !--   dimension is essential, hence the EuclideanSpace (Fin d) signature.         -- !--
-- !-- End Lab Notebook -- !--
/-- **CONJECTURE (generalization loop; not proved this cycle — `sorry`).**
For `δ`-separated keys in `ℝ^d` with `d ≥ 3`, the total Cauchy attention mass is
*sublinear*: bounded by `C · N^{(d-2)/d}` with `C` uniform in `N`.  The program's
advertised `O(√N)` sparsity is exactly the `d = 4` case.  The uniform-in-`N`
quantification is essential (otherwise `C = √N` trivializes it), and finite dimension
is essential (the bound fails in infinite dimensions).  See `FUTURE_DIRECTIONS.md`,
Direction 1.  The `sorry` stands in for the shell-counting packing argument. -/
theorem cauchy_sublinear_mass_conjecture (d : ℕ) (hd : 3 ≤ d) {δ : ℝ} (hδ : 0 < δ) :
    ∃ C : ℝ, ∀ (N : ℕ) (q : EuclideanSpace ℝ (Fin d))
      (key : Fin N → EuclideanSpace ℝ (Fin d)),
      (∀ i j, i ≠ j → δ ≤ ‖key i - key j‖) →
      (∑ i, cauchyKernel q (key i)) ≤ C * (N : ℝ) ^ (((d : ℝ) - 2) / (d : ℝ)) := by
  sorry

end StereographicAttention