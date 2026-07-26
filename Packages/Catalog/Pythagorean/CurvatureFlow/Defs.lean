import Mathlib

/-!
# Discrete Curvature Flow: Definitions and Variance Theory

This file establishes the mathematical foundations for discrete curvature flow on
triangulated surfaces. We formalize the key concepts in an abstract setting:

- **Curvature variance**: The average squared deviation of curvature from the mean,
  serving as a Lyapunov function for the flow.
- **Pairwise decomposition identity**: The fundamental algebraic identity connecting
  variance to pairwise differences, enabling local analysis of edge flips.
- **Descent systems**: Abstract framework for monotone variance-decreasing processes
  with guaranteed progress bounds.

## Main Results

- `cVar_nonneg`: Curvature variance is non-negative.
- `cVar_eq_zero_iff`: Variance is zero iff all values equal the mean.
- `pairwise_sq_diff_eq`: The pairwise decomposition identity
  `∑ᵢ ∑ⱼ (fᵢ - fⱼ)² = 2n · ∑ᵢ (fᵢ - f̄)²`.
- `sum_preserving_preserves_mean`: Operations preserving total curvature preserve the mean.

## Cross-Domain Connections

The variance framework connects discrete differential geometry to:
- **Statistical mechanics**: Variance = thermal energy, Gauss-Bonnet = energy conservation.
- **Information theory**: Variance = Fisher information of the curvature distribution.
- **Optimization**: Variance descent = projected gradient descent on a convex function.
-/

open Finset BigOperators

namespace DiscreteCurvatureFlow

/-! ## Mean and Variance Definitions -/

/-- Mean of a real-valued function on `Fin n`. -/
noncomputable def fMean (n : ℕ) (f : Fin n → ℝ) : ℝ :=
  (∑ i, f i) / n

/-- Curvature variance: the average squared deviation from the mean.
This serves as the Lyapunov function for discrete curvature flow. -/
noncomputable def cVar (n : ℕ) (f : Fin n → ℝ) : ℝ :=
  (∑ i, (f i - fMean n f) ^ 2) / n

/-- Sum of squared deviations from mean (unnormalized variance). -/
noncomputable def sumSqDev (n : ℕ) (f : Fin n → ℝ) : ℝ :=
  ∑ i, (f i - fMean n f) ^ 2

/-! ## Basic Variance Properties -/

/-
The sum of squared deviations from the mean is non-negative.
-/
theorem sumSqDev_nonneg (n : ℕ) (f : Fin n → ℝ) : 0 ≤ sumSqDev n f := by
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-
**Curvature variance is non-negative.** This is the foundation of the
Lyapunov argument: the flow's potential function is bounded below.
-/
theorem cVar_nonneg (n : ℕ) (f : Fin n → ℝ) : 0 ≤ cVar n f := by
  exact div_nonneg ( by exact Finset.sum_nonneg fun _ _ => sq_nonneg _ ) ( by positivity )

/-
Sum of deviations from mean is zero.
-/
theorem sum_dev_eq_zero {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) :
    ∑ i, (f i - fMean n f) = 0 := by
  simp +decide [ hn.ne', fMean ];
  rw [ mul_div_cancel₀ _ ( by positivity ), sub_self ]

/-
If the sum of squares of reals is zero, each term is zero.
-/
theorem sum_sq_eq_zero_iff {n : ℕ} (g : Fin n → ℝ) :
    ∑ i, g i ^ 2 = 0 ↔ ∀ i, g i = 0 := by
  exact ⟨ fun h i => sq_eq_zero_iff.mp ( by rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => sq_nonneg _ ] at h; aesop ), fun h => by simp +decide [ h ] ⟩

/-
**Variance is zero if and only if all values equal the mean.**
This characterizes the equilibrium states of discrete curvature flow:
a triangulation is in equilibrium (zero variance) precisely when
curvature is uniformly distributed — the discrete analog of a
constant-curvature metric.
-/
theorem cVar_eq_zero_iff {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) :
    cVar n f = 0 ↔ ∀ i, f i = fMean n f := by
  convert sum_sq_eq_zero_iff ( fun i => f i - fMean n f ) using 1;
  · exact div_eq_zero_iff.trans ( by norm_num [ hn.ne' ] );
  · simp +decide only [sub_eq_zero]

/-! ## Sum-Preservation and Mean Invariance

A key property of discrete curvature flow is that it preserves the total
curvature (discrete Gauss-Bonnet theorem). This section shows that
sum-preserving operations preserve the mean. -/

/-
**Sum-preserving operations preserve the mean.** This is the discrete
analog of the Gauss-Bonnet theorem: edge flips change individual vertex
curvatures but preserve total curvature, hence the mean curvature.
-/
theorem sum_preserving_preserves_mean {n : ℕ} (hn : 0 < n)
    (f g : Fin n → ℝ) (h : ∑ i, f i = ∑ i, g i) :
    fMean n f = fMean n g := by
  unfold fMean; aesop;

/-! ## Pairwise Decomposition Identity

The KEY algebraic identity for local analysis of edge flips. It decomposes
variance into pairwise squared differences:

  ∑ᵢ ∑ⱼ (fᵢ - fⱼ)² = 2n · ∑ᵢ (fᵢ - f̄)²

This means when an edge flip changes curvatures at 4 vertices, only O(n)
of the O(n²) pairwise terms change, enabling local progress analysis. -/

/-
The double sum of squared differences expands as
`2n · ∑ fᵢ² - 2 · (∑ fᵢ)²`.
-/
theorem double_sum_sq_diff {n : ℕ} (f : Fin n → ℝ) :
    ∑ i : Fin n, ∑ j : Fin n, (f i - f j) ^ 2 =
    2 * n * ∑ i, f i ^ 2 - 2 * (∑ i, f i) ^ 2 := by
  -- Expand the square and rearrange terms.
  simp (config := { decide := true }) only [sub_sq, sum_add_distrib, sum_sub_distrib];
  simpa [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] using by ring;

/-
The sum of squared deviations from the mean equals
`∑ fᵢ² - (∑ fᵢ)² / n`.
-/
theorem sumSqDev_expand {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) :
    sumSqDev n f = ∑ i, f i ^ 2 - (∑ i, f i) ^ 2 / n := by
  unfold sumSqDev fMean; ring;
  norm_num [ Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sq, mul_assoc, mul_comm, mul_left_comm, hn.ne', div_eq_mul_inv ] ; ring;
  simpa [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul ] using by ring;

/-
**Pairwise decomposition identity.** The fundamental identity:
`∑ᵢ ∑ⱼ (fᵢ - fⱼ)² = 2n · ∑ᵢ (fᵢ - f̄)²`.

This connects the "global" variance (deviations from mean) to "local"
pairwise differences, bridging:
- **Geometry**: vertex curvature deviations ↔ edge curvature differences
- **Physics**: thermal energy ↔ nearest-neighbor interactions
- **Information theory**: Fisher information ↔ mutual information
-/
theorem pairwise_sq_diff_eq {n : ℕ} (hn : 0 < n) (f : Fin n → ℝ) :
    (∑ i : Fin n, ∑ j : Fin n, (f i - f j) ^ 2 : ℝ) =
    2 * ↑n * sumSqDev n f := by
  convert double_sum_sq_diff f using 1 ; rw [ sumSqDev_expand hn f ] ; ring;
  simp +decide [ mul_assoc, mul_comm, mul_left_comm, hn.ne' ]

/-! ## Novel Definition: Discrete Curvature Flow System

A `FlowSystem` captures the abstract structure of any variance-decreasing
process on a finite vertex set with a conservation law (Gauss-Bonnet). -/

/-- **A discrete curvature flow system.** This novel mathematical structure
abstracts the key properties shared by:
- Greedy edge-flip curvature flow on triangulated surfaces
- Discrete Ricci flow (Chow-Luo)
- Curvature diffusion via discrete heat equation
- Gradient descent on curvature variance

The structure captures: a non-negative Lyapunov function (variance),
monotone decrease, and a progress guarantee that prevents stalling. -/
structure FlowSystem where
  /-- The Lyapunov function value at each step -/
  V : ℕ → ℝ
  /-- The Lyapunov function is non-negative (variance ≥ 0) -/
  V_nonneg : ∀ k, 0 ≤ V k
  /-- The flow is monotone decreasing (each step reduces or preserves variance) -/
  V_mono : ∀ k, V (k + 1) ≤ V k
  /-- Progress rate: minimum decrease per step when above threshold -/
  δ : ℝ
  /-- The progress rate is positive -/
  δ_pos : 0 < δ
  /-- **Progress guarantee**: when the Lyapunov function is above the threshold,
  the flow makes guaranteed progress of at least δ. This is the key property
  that ensures polynomial-time convergence. -/
  progress : ∀ k, V k ≥ δ → V k - V (k + 1) ≥ δ

/-! ## Monotonicity Lemmas -/

/-
The Lyapunov function is bounded above by its initial value.
-/
theorem FlowSystem.V_le_V0 (S : FlowSystem) (k : ℕ) : S.V k ≤ S.V 0 := by
  exact Nat.recOn k ( by norm_num ) fun n ih => by linarith [ S.V_mono n ] ;

/-
Telescoping: the total decrease over k steps equals V(0) - V(k).
-/
theorem FlowSystem.telescope (S : FlowSystem) (k : ℕ) :
    (Finset.range k).sum (fun i => S.V i - S.V (i + 1)) = S.V 0 - S.V k := by
  rw [ Finset.sum_range_sub' ]

/-
Each step decrease is non-negative.
-/
theorem FlowSystem.step_nonneg (S : FlowSystem) (k : ℕ) :
    0 ≤ S.V k - S.V (k + 1) := by
  exact sub_nonneg_of_le ( S.V_mono k )

end DiscreteCurvatureFlow