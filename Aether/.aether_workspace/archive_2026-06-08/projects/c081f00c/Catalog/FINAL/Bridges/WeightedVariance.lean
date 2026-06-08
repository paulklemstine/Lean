import Mathlib
import Pythagorean.CurvatureFlow.Defs

/-!
# Weighted Curvature Variance and Discrete Wasserstein Gradient Flows

This file develops the theory of **weighted curvature variance** on discrete
triangulations, generalizing the unweighted theory in `Defs.lean`. The key
insight is that positive vertex weights define a discrete probability measure,
and the weighted variance measures curvature heterogeneity in the
2-Wasserstein geometry.

## Main Definitions

- `WeightedTriangCurv`: A triangulation with vertex curvatures and positive weights.
- `weightedCurvMean`: The weighted mean curvature.
- `weightedCurvVar`: The weighted curvature variance.
- `conditionNumber`: The ratio w_max / w_min controlling convergence rate.
- `WeightedFlowSystem`: A flow system with condition-number-dependent progress.

## Main Results

- `weightedCurvVar_nonneg`: Weighted variance is non-negative.
- `weightedCurvVar_eq_zero_iff`: Weighted variance vanishes iff curvature is constant.
- `weighted_pairwise_sq_diff_eq`: The weighted pairwise decomposition identity.
- `WeightedFlowSystem.convergence`: Convergence in O(κ · V₀/ε) steps.
- `weighted_var_cross_domain_bound`: Cross-domain: Popoviciu's inequality.

## References

- Generalizes `DiscreteCurvatureFlow.cVar_nonneg`, `cVar_eq_zero_iff`,
  `pairwise_sq_diff_eq` from `Pythagorean.CurvatureFlow.Defs`.
-/

open Finset BigOperators

namespace WeightedCurvature

/-! ## Core Definitions -/

/-- A weighted triangulation curvature structure: curvatures and positive weights
on a finite vertex set `Fin n`. -/
structure WeightedTriangCurv (n : ℕ) where
  K : Fin n → ℝ
  w : Fin n → ℝ
  w_pos : ∀ i, 0 < w i

variable {n : ℕ}

/-- Total weight: the sum of all vertex weights. -/
noncomputable def totalWeight (wt : WeightedTriangCurv n) : ℝ :=
  ∑ i : Fin n, wt.w i

/-- The total weight is positive when n > 0. -/
theorem totalWeight_pos (hn : 0 < n) (wt : WeightedTriangCurv n) :
    0 < totalWeight wt := by
  unfold totalWeight
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  exact Finset.sum_pos (fun i _ => wt.w_pos i) Finset.univ_nonempty

/-- The weighted mean curvature. -/
noncomputable def weightedCurvMean (wt : WeightedTriangCurv n) : ℝ :=
  (∑ i : Fin n, wt.w i * wt.K i) / totalWeight wt

/-- The weighted curvature variance: expected squared deviation from
weighted mean, weighted by the vertex weights. -/
noncomputable def weightedCurvVar (wt : WeightedTriangCurv n) : ℝ :=
  (∑ i : Fin n, wt.w i * (wt.K i - weightedCurvMean wt) ^ 2) / totalWeight wt

/-! ## Weighted Variance: Non-negativity -/

/-- Each term in the weighted sum of squared deviations is non-negative. -/
theorem weighted_term_nonneg (wt : WeightedTriangCurv n) (i : Fin n) :
    0 ≤ wt.w i * (wt.K i - weightedCurvMean wt) ^ 2 :=
  mul_nonneg (le_of_lt (wt.w_pos i)) (sq_nonneg _)

/-
**Weighted curvature variance is non-negative.**
Generalizes `DiscreteCurvatureFlow.cVar_nonneg`.
-/
theorem weightedCurvVar_nonneg (hn : 0 < n) (wt : WeightedTriangCurv n) :
    0 ≤ weightedCurvVar wt := by
  exact div_nonneg ( Finset.sum_nonneg fun _ _ => mul_nonneg ( le_of_lt ( wt.w_pos _ ) ) ( sq_nonneg _ ) ) ( Finset.sum_nonneg fun _ _ => le_of_lt ( wt.w_pos _ ) )

/-! ## Weighted deviation sum equals zero -/

/-
The weighted sum of deviations from the weighted mean is zero.
-/
theorem weighted_sum_dev_eq_zero (hn : 0 < n) (wt : WeightedTriangCurv n) :
    ∑ i : Fin n, wt.w i * (wt.K i - weightedCurvMean wt) = 0 := by
  simp +decide [ mul_sub, Finset.sum_sub_distrib, ← Finset.sum_mul _ _ _, weightedCurvMean, totalWeight ];
  rw [ mul_div_cancel₀ _ ( ne_of_gt ( Finset.sum_pos ( fun _ _ => wt.w_pos _ ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) ), sub_self ]

/-! ## Weighted Variance Zero Characterization -/

/-
Helper: if a weighted sum of non-negative terms is zero with positive weights,
each term is zero.
-/
theorem weighted_sum_nonneg_eq_zero {f : Fin n → ℝ} {w : Fin n → ℝ}
    (hw : ∀ i, 0 < w i) (hf : ∀ i, 0 ≤ f i)
    (hsum : ∑ i : Fin n, w i * f i = 0) :
    ∀ i, f i = 0 := by
  exact fun i => le_antisymm ( le_of_not_gt fun hi => absurd ( hsum ▸ Finset.single_le_sum ( fun i _ => mul_nonneg ( le_of_lt ( hw i ) ) ( hf i ) ) ( Finset.mem_univ i ) ) ( by nlinarith [ hw i, hf i ] ) ) ( hf i )

/-
**Weighted curvature variance is zero if and only if all curvatures are equal.**
Generalizes `DiscreteCurvatureFlow.cVar_eq_zero_iff`.

Forward direction uses positive weights to force each squared deviation to zero.
Backward direction substitutes constant curvature into the definition.
-/
theorem weightedCurvVar_eq_zero_iff (hn : 0 < n) (wt : WeightedTriangCurv n) :
    weightedCurvVar wt = 0 ↔ ∀ i j : Fin n, wt.K i = wt.K j := by
  constructor;
  · intro h i j;
    -- By definition of $weightedCurvVar$, we know that $\sum_{i=0}^{n-1} wt.w i * (wt.K i - weightedCurvMean wt)^2 = 0$.
    have h_sum_zero : ∑ i : Fin n, wt.w i * (wt.K i - weightedCurvMean wt) ^ 2 = 0 := by
      unfold weightedCurvVar at h; rw [ div_eq_iff ] at h <;> nlinarith [ totalWeight_pos hn wt ] ;
    -- By definition of $weightedCurvVar$, we know that each term in the sum is zero.
    have h_each_zero : ∀ i, wt.w i * (wt.K i - weightedCurvMean wt) ^ 2 = 0 := by
      exact fun i => by rw [ Finset.sum_eq_zero_iff_of_nonneg fun _ _ => mul_nonneg ( le_of_lt ( wt.w_pos _ ) ) ( sq_nonneg _ ) ] at h_sum_zero; aesop;
    simp_all +decide [ sub_eq_iff_eq_add, ne_of_gt ];
    cases h_each_zero i <;> cases h_each_zero j <;> linarith [ wt.w_pos i, wt.w_pos j ];
  · intro h;
    simp +decide [ ← h ⟨ 0, hn ⟩, weightedCurvVar ];
    unfold weightedCurvMean totalWeight; simp +decide [ ← Finset.sum_mul _ _ _, h _ ⟨ 0, hn ⟩ ] ;
    grind

/-! ## Weighted Pairwise Squared Difference Identity -/

/-
**Weighted pairwise decomposition identity.** Generalizes
`DiscreteCurvatureFlow.pairwise_sq_diff_eq`.

  V_w = (1 / (2W²)) · ∑_i ∑_j w_i · w_j · (K_i - K_j)²

This reveals weighted variance as a kernel-based discrepancy measure.
-/
theorem weighted_pairwise_sq_diff_eq (hn : 0 < n) (wt : WeightedTriangCurv n) :
    weightedCurvVar wt =
      (∑ i : Fin n, ∑ j : Fin n, wt.w i * wt.w j * (wt.K i - wt.K j) ^ 2) /
      (2 * totalWeight wt ^ 2) := by
  unfold weightedCurvVar;
  simp +decide only [mul_comm, mul_left_comm, mul_assoc, ← mul_sum];
  simp +decide only [mul_comm, mul_left_comm, sub_sq, mul_assoc, mul_add, mul_sub, sum_add_distrib,
    sum_sub_distrib, sum_mul];
  simp +decide only [mul_comm, mul_left_comm, mul_assoc, sub_mul, mul_sub, mul_add, add_mul, Finset.sum_add_distrib,
    Finset.sum_sub_distrib, Finset.mul_sum];
  simp +decide [ ← mul_assoc, ← Finset.mul_sum _ _ _, ← Finset.sum_mul, ← Finset.sum_comm, weightedCurvMean ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, sq, totalWeight ];
  simp +decide [ ← mul_assoc, ← Finset.sum_mul, mul_div_cancel₀ _ ( ne_of_gt ( show 0 < ∑ i, wt.w i from Finset.sum_pos ( fun _ _ => wt.w_pos _ ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩ ) ) ] ; ring;
  grind

/-! ## Condition Number -/

/-- The condition number of a weighted triangulation: the ratio of maximum
to minimum weight. Controls convergence rate of weighted curvature flow. -/
noncomputable def conditionNumber (hn : 0 < n) (wt : WeightedTriangCurv n) : ℝ :=
  haveI : Nonempty (Fin n) := ⟨⟨0, hn⟩⟩
  (Finset.univ.sup' Finset.univ_nonempty wt.w) /
  (Finset.univ.inf' Finset.univ_nonempty wt.w)

/-
The condition number is at least 1.
-/
theorem conditionNumber_ge_one (hn : 0 < n) (wt : WeightedTriangCurv n) :
    1 ≤ conditionNumber hn wt := by
  rw [ conditionNumber ];
  rw [ one_le_div ];
  · exact Finset.inf'_le _ ( Finset.mem_univ ⟨ 0, hn ⟩ ) |> le_trans <| Finset.le_sup' _ <| Finset.mem_univ _;
  · simp +zetaDelta at *;
    exact wt.w_pos

/-! ## Cross-Domain: Popoviciu's Inequality for Weighted Variance -/

/-
**Cross-domain theorem: Popoviciu's inequality for weighted variance.**
If all curvatures lie in [a,b], the weighted variance is at most (b-a)²/4.

This connects discrete geometry, statistics, and information theory.
-/
theorem weighted_var_cross_domain_bound (hn : 0 < n) (wt : WeightedTriangCurv n)
    (a b : ℝ) (hab : a ≤ b)
    (h_bounds : ∀ i, a ≤ wt.K i ∧ wt.K i ≤ b) :
    weightedCurvVar wt ≤ (b - a) ^ 2 / 4 := by
  -- By definition of $weightedCurvVar$, we know that
  have h_def : weightedCurvVar wt = (∑ i, wt.w i * wt.K i ^ 2) / totalWeight wt - (weightedCurvMean wt) ^ 2 := by
    unfold weightedCurvVar weightedCurvMean;
    -- Expand the squared term and simplify.
    have h_expand : ∑ i, wt.w i * (wt.K i - (∑ i, wt.w i * wt.K i) / totalWeight wt) ^ 2 = ∑ i, wt.w i * wt.K i ^ 2 - 2 * (∑ i, wt.w i * wt.K i) * (∑ i, wt.w i * wt.K i) / totalWeight wt + (∑ i, wt.w i * wt.K i) ^ 2 / totalWeight wt := by
      simp +decide [ sub_sq, mul_add, mul_sub, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, div_eq_mul_inv ] ; ring;
      simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, sq ];
      unfold totalWeight; ring;
      grind;
    rw [ h_expand ] ; ring;
  -- Since $a \leq K_i \leq b$, we have $K_i^2 \leq (a+b)K_i - ab$.
  have h_bound : ∀ i, wt.K i ^ 2 ≤ (a + b) * wt.K i - a * b := by
    exact fun i => by nlinarith only [ h_bounds i ] ;
  -- Applying the bound $K_i^2 \leq (a+b)K_i - ab$ to the sum, we get $\sum w_i K_i^2 \leq (a+b) \sum w_i K_i - ab \sum w_i$.
  have h_sum_bound : ∑ i, wt.w i * wt.K i ^ 2 ≤ (a + b) * ∑ i, wt.w i * wt.K i - a * b * ∑ i, wt.w i := by
    rw [ Finset.mul_sum _ _ _, Finset.mul_sum _ _ _ ];
    simpa only [ ← Finset.sum_sub_distrib ] using Finset.sum_le_sum fun i _ => by nlinarith only [ h_bound i, wt.w_pos i ] ;
  -- Substitute the bound into the definition of $weightedCurvVar$.
  have h_subst : weightedCurvVar wt ≤ ((a + b) * ∑ i, wt.w i * wt.K i - a * b * ∑ i, wt.w i) / totalWeight wt - (weightedCurvMean wt) ^ 2 := by
    exact h_def ▸ sub_le_sub_right ( div_le_div_of_nonneg_right h_sum_bound ( Finset.sum_nonneg fun _ _ => le_of_lt ( wt.w_pos _ ) ) ) _;
  -- Substitute the definition of `weightedCurvMean` into the inequality.
  have h_subst_mean : weightedCurvVar wt ≤ ((a + b) * (totalWeight wt * weightedCurvMean wt) - a * b * totalWeight wt) / totalWeight wt - (weightedCurvMean wt) ^ 2 := by
    convert h_subst using 3;
    unfold weightedCurvMean; rw [ mul_div_cancel₀ _ ( ne_of_gt ( totalWeight_pos hn wt ) ) ] ;
    rfl;
  refine le_trans h_subst_mean ?_;
  rw [ div_sub', div_le_iff₀ ] <;> nlinarith only [ sq_nonneg ( ( a + b ) - 2 * weightedCurvMean wt ), totalWeight_pos hn wt, hab ]

/-! ## Weighted Flow System: Convergence with Condition Number -/

/-- **A weighted curvature flow system.** Novel structure extending
`FlowSystem` with condition-number-dependent convergence guarantees.

This captures the key phenomenon: when weights are non-uniform, the
convergence rate degrades by a factor of κ = w_max/w_min. -/
structure WeightedFlowSystem where
  V : ℕ → ℝ
  V_nonneg : ∀ k, 0 ≤ V k
  V_mono : ∀ k, V (k + 1) ≤ V k
  δ : ℝ
  δ_pos : 0 < δ
  κ : ℝ
  κ_ge_one : 1 ≤ κ
  progress : ∀ k, V k ≥ δ / κ → V k - V (k + 1) ≥ δ / κ

/-
Lyapunov function is bounded above by its initial value.
-/
theorem WeightedFlowSystem.V_le_V0 (S : WeightedFlowSystem) (k : ℕ) :
    S.V k ≤ S.V 0 := by
  exact Nat.recOn k le_rfl fun n ih => by linarith [ S.V_mono n ] ;

/-
**Main convergence theorem for weighted curvature flow.**
The weighted flow reaches V < δ/κ within ⌈κ · V(0) / δ⌉ steps.

Proof by contradiction using telescoping sums.
-/
theorem WeightedFlowSystem.convergence (S : WeightedFlowSystem) :
    ∃ k : ℕ, k ≤ Nat.ceil (S.κ * S.V 0 / S.δ) ∧ S.V k < S.δ / S.κ := by
  refine' ⟨ ⌈S.κ * S.V 0 / S.δ⌉₊, le_rfl, _ ⟩;
  by_contra h_contra;
  -- By induction, we can show that $V(k) \leq V(0) - k \cdot \frac{\delta}{\kappa}$ for all $k$.
  have h_induction : ∀ k ≤ ⌈S.κ * S.V 0 / S.δ⌉₊, S.V k ≤ S.V 0 - k * (S.δ / S.κ) := by
    intro k hk
    induction' k with k ih;
    · norm_num;
    · have := S.progress k;
      norm_num +zetaDelta at *;
      linarith [ this ( by linarith [ ih ( Nat.le_of_lt hk ), show S.V ⌈S.κ * S.V 0 / S.δ⌉₊ ≤ S.V k from by exact Nat.le_induction ( by norm_num ) ( fun n hn ih => by linarith [ S.V_mono n ] ) _ hk.le ] ), ih ( Nat.le_of_lt hk ) ];
  have := h_induction ⌈S.κ * S.V 0 / S.δ⌉₊ le_rfl;
  nlinarith [ S.κ_ge_one, S.δ_pos, S.V_nonneg 0, mul_div_cancel₀ ( S.δ : ℝ ) ( show S.κ ≠ 0 by linarith [ S.κ_ge_one ] ), Nat.le_ceil ( S.κ * S.V 0 / S.δ ), mul_div_cancel₀ ( S.κ * S.V 0 ) ( show S.δ ≠ 0 by linarith [ S.δ_pos ] ) ]

/-
**Stability**: Once below threshold, variance stays below.
-/
theorem WeightedFlowSystem.stability (S : WeightedFlowSystem) (k j : ℕ)
    (hkj : k ≤ j) (hk : S.V k < S.δ / S.κ) : S.V j ≤ S.V k := by
  exact Nat.le_induction ( by norm_num ) ( fun n hn ih => by linarith [ S.V_mono n ] ) j hkj

/-! ## Uniform Weights Recovery -/

/-
When all weights are equal, the weighted mean equals the unweighted mean.
-/
theorem weightedCurvMean_uniform (hn : 0 < n) (K : Fin n → ℝ) :
    weightedCurvMean ⟨K, fun _ => 1, fun _ => one_pos⟩ =
    DiscreteCurvatureFlow.fMean n K := by
  unfold weightedCurvMean DiscreteCurvatureFlow.fMean; norm_num;
  unfold totalWeight; aesop;

/-
When all weights are equal, the weighted variance equals the unweighted variance.
-/
theorem weightedCurvVar_uniform (hn : 0 < n) (K : Fin n → ℝ) :
    weightedCurvVar ⟨K, fun _ => 1, fun _ => one_pos⟩ =
    DiscreteCurvatureFlow.cVar n K := by
  unfold weightedCurvVar DiscreteCurvatureFlow.cVar;
  simp +decide [ totalWeight, weightedCurvMean, DiscreteCurvatureFlow.fMean ]

/-! ## Scaling Invariance -/

/-
**Scaling invariance**: Multiplying all weights by a positive constant
does not change the weighted variance.
-/
theorem weightedCurvVar_scale_invariant (hn : 0 < n) (wt : WeightedTriangCurv n)
    (c : ℝ) (hc : 0 < c) :
    weightedCurvVar ⟨wt.K, fun i => c * wt.w i, fun i => mul_pos hc (wt.w_pos i)⟩ =
    weightedCurvVar wt := by
  unfold weightedCurvVar;
  unfold weightedCurvMean totalWeight;
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_pow, mul_assoc, mul_div_mul_left _ _ hc.ne', hc.ne' ]

/-! ## Falsifiable Conjecture: Tight Convergence Rate -/

/-- **Conjecture (Tight κ-Scaling):** The convergence time T(ε) for weighted
curvature flow satisfies T(ε) = Θ(κ · V₀/ε).

**Computational Test:** Generate random weighted triangulations with
n ∈ {50, 100, 200}, weights from Pareto(α) for α ∈ {1, 2, 4, 8}.
Run weighted greedy flow, measure T(ε) for ε = 0.01, and fit
log T vs log(κ · V₀/ε). Predict: slope ≈ 1 with R² > 0.95.

**Falsification:** If slope significantly differs from 1 (especially
if < 0.5 or > 2), the Θ-bound is wrong. -/
def tight_kappa_scaling_conjecture : Prop :=
  ∃ (C₁ C₂ : ℝ), 0 < C₁ ∧ C₁ ≤ C₂ ∧
    ∀ (S : WeightedFlowSystem),
      ∀ (ε : ℝ), 0 < ε →
        (∃ k : ℕ, ↑k ≤ C₂ * S.κ * S.V 0 / ε ∧ S.V k < ε) ∧
        (∀ k : ℕ, S.V k < ε → C₁ * S.κ * S.V 0 / ε ≤ ↑k)

end WeightedCurvature