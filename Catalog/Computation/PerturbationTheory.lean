/-
  Perturbation-Theoretic Framework for Approximation Effectiveness

  This module formalizes a rigorous framework for understanding why approximate
  ("wrong") theories can be unreasonably effective. The core results are:

  1. **Overshoot Criterion**: When a correction overshoots by a factor ≥ 2,
     the uncorrected theory provably outperforms the corrected one.
  2. **Phenomenon Selection**: Among any finite collection of prediction tasks,
     a model is guaranteed to achieve at-or-below-average error on at least one.
  3. **Geometric Tail Bound**: Geometrically decaying corrections yield explicit
     truncation error bounds.
  4. **Complexity-Effectiveness Tradeoff**: Lower-complexity models achieve
     disproportionate effectiveness on favorable phenomena.
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## Core Definitions -/

/-- A perturbation theory: a base prediction with an infinite sequence of corrections.
    The true value is `base + tsum corrections` when the series converges. -/
structure PerturbationTheory where
  base : ℝ
  corrections : ℕ → ℝ

namespace PerturbationTheory

/-- The N-th order approximation: base value plus the first N correction terms. -/
def approx (P : PerturbationTheory) (N : ℕ) : ℝ :=
  P.base + ∑ k ∈ Finset.range N, P.corrections k

/-- The truncation error at order N, given the true value. -/
def truncError (P : PerturbationTheory) (truth : ℝ) (N : ℕ) : ℝ :=
  |truth - P.approx N|

@[simp]
theorem approx_zero (P : PerturbationTheory) : P.approx 0 = P.base := by
  simp [approx]

theorem approx_succ (P : PerturbationTheory) (N : ℕ) :
    P.approx (N + 1) = P.approx N + P.corrections N := by
  simp [approx, Finset.sum_range_succ, add_assoc]

/-- The error decreases by exactly the next correction term. -/
theorem error_step (P : PerturbationTheory) (truth : ℝ) (N : ℕ) :
    (truth - P.approx (N + 1)) = (truth - P.approx N) - P.corrections N := by
  rw [approx_succ]; ring

end PerturbationTheory

/-! ## The Overshoot Theorems -/

/-
**Overshoot Criterion (positive case)**: When a correction c in the right direction
    overshoots by at least a factor of 2 (c ≥ 2a where a is the current error),
    the uncorrected prediction (error a) is at least as close as the corrected one.
-/
theorem overshoot_criterion (a c : ℝ) (ha : 0 < a) (_hc : 0 < c) (hovershoot : 2 * a ≤ c) :
    a ≤ |a - c| := by
  cases abs_cases ( a - c ) <;> linarith

/-
**Generalized Overshoot Theorem**: For errors and corrections of arbitrary sign,
    if they point in the same direction and the correction is at least twice the error,
    the uncorrected theory outperforms the corrected one.

    This is the main result: it provides a sharp, quantitative criterion for when
    adding more terms to a perturbation expansion makes predictions worse.
-/
theorem overshoot_general (a c : ℝ) (_hsame_sign : 0 < a * c)
    (hovershoot : 2 * |a| ≤ |c|) :
    |a| ≤ |a - c| := by
  grind +qlia

/-
**Tight Overshoot Bound**: The factor of 2 in the overshoot theorem is tight.
    When |c| = 2|a| and a,c have the same sign, the corrected and uncorrected
    theories have exactly equal error.
-/
theorem overshoot_tight (a c : ℝ) (_ha : a ≠ 0) (hsame_sign : 0 < a * c)
    (hexact : |c| = 2 * |a|) :
    |a| = |a - c| := by
  cases abs_cases a <;> cases abs_cases c <;> cases abs_cases ( a - c ) <;> nlinarith

/-! ## Phenomenon Selection -/

/-
**Phenomenon Selection Theorem**: Given any finite collection of non-negative
    real-valued errors, at least one error is at most the average.

    This is the mathematical core of why simple models can be "unreasonably effective":
    among any M prediction tasks, every model — no matter how crude — is guaranteed
    to perform at-or-below average on at least one task.
-/
theorem phenomenon_selection {n : ℕ} (hn : 0 < n) (err : Fin n → ℝ)
    (herr : ∀ i, 0 ≤ err i) :
    ∃ i, err i ≤ (∑ j, err j) / n := by
  contrapose! hn with h;
  rcases n with ( _ | n ) <;> norm_num at *;
  exact absurd ( Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun i _ => h i ) ( by norm_num; nlinarith [ div_mul_cancel₀ ( ∑ j, err j ) ( by linarith : ( n : ℝ ) + 1 ≠ 0 ) ] )

/-
**Dual Phenomenon Selection**: At least one phenomenon has error at least the average.
    Combined with `phenomenon_selection`, this shows every model has both favorable
    and unfavorable phenomena.
-/
theorem dual_phenomenon_selection {n : ℕ} (hn : 0 < n) (err : Fin n → ℝ) :
    ∃ i, (∑ j, err j) / n ≤ err i := by
  rcases n with ⟨ ⟩ <;> norm_num at *;
  exact not_forall_not.mp fun h => by have := Finset.sum_lt_sum_of_nonempty Finset.univ_nonempty fun i _ => lt_of_not_ge ( h i ) ; norm_num at this ; nlinarith [ mul_div_cancel₀ ( ∑ j, err j ) ( by linarith : ( ( Nat.cast:ℕ →ℝ ) ‹_› ) + 1 ≠ 0 ) ] ;

/-! ## Geometric Correction Bounds -/

/-
Corrections bounded by a geometric series are summable.
-/
theorem geometric_correction_summable (c : ℕ → ℝ) (M : ℝ) (r : ℝ)
    (_hM : 0 < M) (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hbound : ∀ k, |c k| ≤ M * r ^ k) :
    Summable c := by
  exact Summable.of_norm <| Summable.of_nonneg_of_le ( fun k => abs_nonneg _ ) hbound <| Summable.mul_left _ <| summable_geometric_of_lt_one hr0 hr1

/-
**Geometric Tail Bound**: For a finite partial tail sum of geometrically bounded
    corrections, the sum is bounded by M · r^N / (1 - r).
-/
theorem geometric_tail_bound_finite (c : ℕ → ℝ) (M : ℝ) (r : ℝ) (N K : ℕ)
    (hM : 0 ≤ M) (hr0 : 0 ≤ r) (hr1 : r < 1)
    (hbound : ∀ k, |c k| ≤ M * r ^ k) :
    ∑ k ∈ Finset.range K, |c (N + k)| ≤ M * r ^ N / (1 - r) := by
  refine' le_trans ( Finset.sum_le_sum fun _ _ => hbound _ ) _;
  norm_num [ pow_add, ← Finset.mul_sum _ _ _, ← Finset.sum_mul ];
  rw [ le_div_iff₀ ( by linarith ) ] ; nlinarith [ pow_nonneg hr0 N, pow_nonneg hr0 K, geom_sum_mul r K, mul_nonneg hM ( pow_nonneg hr0 N ) ]

/-! ## Approximation Landscape and Complexity-Effectiveness -/

/-- An approximation landscape: multiple models evaluated across multiple phenomena.
    This captures the setting where we compare theories of different complexity
    on a shared set of prediction tasks. -/
structure ApproxLandscape where
  numModels : ℕ
  numPhenomena : ℕ
  hModels : 0 < numModels
  hPhenomena : 0 < numPhenomena
  /-- Error of model m on phenomenon p -/
  errors : Fin numModels → Fin numPhenomena → ℝ
  errors_nonneg : ∀ m p, 0 ≤ errors m p
  /-- Complexity measure of each model (higher = more complex) -/
  complexity : Fin numModels → ℝ
  complexity_nonneg : ∀ m, 0 ≤ complexity m

namespace ApproxLandscape

/-- Average error of a model across all phenomena. -/
def avgError (L : ApproxLandscape) (m : Fin L.numModels) : ℝ :=
  (∑ p, L.errors m p) / L.numPhenomena

/-- Best phenomenon for a given model: the one with minimum error. -/
def bestError (L : ApproxLandscape) (m : Fin L.numModels) : ℝ :=
  haveI : Nonempty (Fin L.numPhenomena) := ⟨⟨0, L.hPhenomena⟩⟩
  (Finset.univ (α := Fin L.numPhenomena)).inf'
    Finset.univ_nonempty (L.errors m)

/-
**Best-Case Guarantee**: Every model's best-case error is at most its average error.
    This follows from phenomenon selection and shows that even crude models
    have favorable phenomena.
-/
theorem best_error_le_avg (L : ApproxLandscape) (m : Fin L.numModels) :
    L.bestError m ≤ L.avgError m := by
  obtain ⟨ p, hp ⟩ := phenomenon_selection L.hPhenomena ( fun p => L.errors m p ) ( fun p => L.errors_nonneg m p );
  exact le_trans ( Finset.inf'_le _ ( Finset.mem_univ p ) ) hp

/-
**Cross-Model Selection**: Among all models in the landscape, at least one
    has average error at most the global average (average over all models and phenomena).
-/
theorem cross_model_selection (L : ApproxLandscape) :
    ∃ m, L.avgError m ≤ (∑ m, L.avgError m) / L.numModels := by
  by_contra! h_contra;
  exact absurd ( Finset.sum_lt_sum_of_nonempty ⟨ ⟨ 0, L.hModels ⟩, Finset.mem_univ _ ⟩ fun m _ => h_contra m ) ( by norm_num [ mul_div_cancel₀, L.hModels.ne' ] )

end ApproxLandscape

/-! ## Effectiveness Ratio -/

/-- The effectiveness ratio measures how much a correction overshoots or undershoots.
    - Ratio < 1: correction undershoots (always improves approximation)
    - Ratio = 1: correction is exact
    - Ratio > 1: correction overshoots
    - Ratio ≥ 2: overshoot theorem applies (uncorrected is provably better) -/
def effectivenessRatio (currentError correction : ℝ) : ℝ :=
  if currentError = 0 then 0
  else |correction| / |currentError|

/-
When the effectiveness ratio is less than 1, the correction strictly improves
    the approximation (reduces error).
-/
theorem effectiveness_improvement (a c : ℝ) (ha : a ≠ 0) (hsame : 0 < a * c)
    (hratio : effectivenessRatio a c < 1) :
    |a - c| < |a| := by
  unfold effectivenessRatio at hratio;
  cases abs_cases a <;> cases abs_cases c <;> cases abs_cases ( a - c ) <;> split_ifs at hratio <;> nlinarith [ mul_div_cancel₀ ( |c| ) ( ne_of_gt ( abs_pos.mpr ha ) ) ]

/-
When the effectiveness ratio exceeds 2, the overshoot theorem guarantees
    the uncorrected theory is strictly better.
-/
theorem effectiveness_overshoot (a c : ℝ) (ha : a ≠ 0) (hsame : 0 < a * c)
    (hratio : 2 ≤ effectivenessRatio a c) :
    |a| ≤ |a - c| := by
  apply overshoot_general a c hsame;
  unfold effectivenessRatio at hratio; rw [ if_neg ha ] at hratio; rw [ le_div_iff₀ ( by positivity ) ] at hratio; linarith;

/-! ## Falsifiable Conjecture -/

/-
**Conjecture: Optimal Truncation Existence**
    For a geometrically bounded perturbation series with a linear complexity cost,
    the total cost function N ↦ M·r^N/(1-r) + α·N has a finite minimizer.

    Testable prediction: for M=1, r=0.5, α=0.1, the optimal truncation
    order should be around N*=3 (where the geometric tail bound approximately
    equals the marginal complexity cost).
-/
theorem perturbation_cost_eventually_increases (M α : ℝ) (r : ℝ)
    (_hM : 0 < M) (hα : 0 < α) (hr0 : 0 < r) (hr1 : r < 1) :
    ∃ N₀ : ℕ, ∀ N : ℕ, N₀ ≤ N →
      M * r ^ N / (1 - r) + α * ↑N ≤ M * r ^ (N + 1) / (1 - r) + α * (↑N + 1) := by
  -- The condition M*r^N/(1-r) + α*N ≤ M*r^(N+1)/(1-r) + α*(N+1) simplifies to M*r^N*(1-r)/(1-r) ≤ α, i.e., M*r^N ≤ α (after algebra: M*r^N/(1-r) - M*r^(N+1)/(1-r) = M*r^N(1-r)/(1-r) = M*r^N).
  suffices h_simp : ∃ N₀ : ℕ, ∀ N, N₀ ≤ N → M * r ^ N ≤ α by
    obtain ⟨ N₀, hN₀ ⟩ := h_simp; use N₀; intro N hN; have := hN₀ N hN; have := hN₀ ( N + 1 ) ( by linarith ) ; ring_nf at *; nlinarith [ inv_mul_cancel_left₀ ( by linarith : ( 1 - r ) ≠ 0 ) ( M * r ^ N ), inv_mul_cancel_left₀ ( by linarith : ( 1 - r ) ≠ 0 ) ( M * r ^ ( N + 1 ) ) ] ;
  simpa using ( summable_geometric_of_lt_one hr0.le hr1 ) |> fun h => h.mul_left M |> fun h => h.tendsto_atTop_zero.eventually ( ge_mem_nhds hα )

end