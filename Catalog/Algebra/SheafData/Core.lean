import Mathlib

/-!
# Sheaf-Theoretic Data Integration: Core Theory

This module establishes the mathematical foundations for viewing databases as
presheaves on the poset of feature subsets. We formalize the Čech complex for
data consistency, prove the fundamental coboundary identity δ² = 0, characterize
consistent configurations via defect vanishing, establish the Laplacian connection,
and prove optimality of mean-based imputation.

## Main Definitions

* `cechDelta0` — The 0th Čech coboundary map: δ⁰(f)(i,j) = f(j) - f(i)
* `cechDelta1` — The 1st Čech coboundary map: δ¹(g)(i,j,k) = g(j,k) - g(i,k) + g(i,j)
* `consistencyDefect` — L² measure of pairwise data inconsistency
* `OverlapNerve` — Weighted graph structure capturing source overlaps
* `laplacianForm` — Quadratic form from the overlap graph Laplacian

## Main Results

* `cech_coboundary_sq_zero` — δ¹ ∘ δ⁰ = 0 (fundamental cohomological identity)
* `defect_zero_iff_consistent` — Defect vanishes iff all sources agree
* `weighted_defect_eq_twice_laplacian` — Weighted defect = 2·(Laplacian quadratic form)
* `mean_minimizes_deviation` — Mean imputation minimizes total squared deviation
* `defect_rescale` — Defect scales quadratically under uniform perturbation

## References

The Čech complex formalization follows the standard algebraic topology approach
applied to the novel setting of data integration. The Laplacian connection
establishes a bridge to spectral graph theory.
-/

noncomputable section

open Finset BigOperators

/-! ## §1. The Čech Complex for Data Sources

We define the coboundary operators of the Čech complex associated to a
collection of data sources. The 0-cochains represent data values at each
source, the 1-cochains represent pairwise comparison data, and the
2-cochains represent triple comparison data.

The fundamental identity δ¹ ∘ δ⁰ = 0 means that any pairwise disagreement
pattern arising from actual source data is automatically "closed" — it has
no triple-level obstruction. Obstructions in H¹ = ker(δ¹)/im(δ⁰) represent
genuinely irreconcilable data conflicts.
-/

section CechComplex

variable {ι : Type*} {G : Type*} [AddCommGroup G]

/-- The 0th Čech coboundary: measures pairwise disagreement between sources.
    δ⁰(f)(i,j) = f(j) - f(i) computes how much source j disagrees with source i. -/
def cechDelta0 (f : ι → G) (i j : ι) : G := f j - f i

/-- The 1st Čech coboundary: measures triple inconsistency.
    δ¹(g)(i,j,k) = g(j,k) - g(i,k) + g(i,j) is the alternating sum around a triangle. -/
def cechDelta1 (g : ι → ι → G) (i j k : ι) : G := g j k - g i k + g i j

/-
**The Čech Coboundary Identity (δ² = 0)**.

This is the fundamental algebraic identity underlying sheaf cohomology.
For any 0-cochain f (data values at sources), applying the coboundary twice
always yields zero. This means the image of δ⁰ is contained in the kernel
of δ¹, giving a well-defined cohomology group H¹.

Proof idea: Direct expansion using the group law.
  (δ¹ ∘ δ⁰)(f)(i,j,k) = (f(k) - f(j)) - (f(k) - f(i)) + (f(j) - f(i))
                        = f(k) - f(j) - f(k) + f(i) + f(j) - f(i) = 0
-/
theorem cech_coboundary_sq_zero (f : ι → G) (i j k : ι) :
    cechDelta1 (cechDelta0 f) i j k = 0 := by
  unfold cechDelta1 cechDelta0; abel;

/-
The coboundary of a constant cochain is zero: constant data is consistent.
-/
theorem cechDelta0_const (g : G) (i j : ι) : cechDelta0 (fun _ => g) i j = 0 := by
  exact sub_self g

/-
The coboundary is antisymmetric: δ⁰(f)(i,j) = -δ⁰(f)(j,i).
-/
theorem cechDelta0_antisymm (f : ι → G) (i j : ι) :
    cechDelta0 f i j = -cechDelta0 f j i := by
  unfold cechDelta0;
  rw [ neg_sub ]

end CechComplex

/-! ## §2. Consistency Defect

The consistency defect is the L² measure of how much data sources disagree.
It equals zero precisely when all sources report identical values — the
sheaf condition. This provides a quantitative relaxation of the exact sheaf
condition, measuring "how far" a presheaf is from being a sheaf.
-/

section ConsistencyDefect

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The consistency defect: total squared pairwise disagreement.
    defect(f) = Σ_{i,j} (f(j) - f(i))² -/
def consistencyDefect (f : ι → ℝ) : ℝ :=
  ∑ i : ι, ∑ j : ι, (f j - f i) ^ 2

/-- Data sources are consistent when they all report the same value. -/
def IsConsistent (f : ι → ℝ) : Prop := ∀ i j : ι, f i = f j

/-
**Defect Non-negativity**: The consistency defect is always ≥ 0.
    This follows from each summand being a square.
-/
theorem defect_nonneg (f : ι → ℝ) : 0 ≤ consistencyDefect f := by
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _

/-
**Defect Characterization**: The defect vanishes if and only if all sources
    report identical values. This characterizes the sheaf condition as the
    zero locus of the defect functional.

    Forward: If each (f(j) - f(i))² ≥ 0 and their sum is 0, each must be 0.
    Backward: If all values agree, each difference is 0.
-/
theorem defect_zero_iff_consistent (f : ι → ℝ) :
    consistencyDefect f = 0 ↔ IsConsistent f := by
  constructor <;> intro h;
  · unfold consistencyDefect at h;
    rw [ Finset.sum_eq_zero_iff_of_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _ ] at h;
    simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, sq_nonneg, sub_eq_zero ];
    exact fun i j => h i j ▸ rfl;
  · exact Finset.sum_eq_zero fun i hi => Finset.sum_eq_zero fun j hj => by simp +decide [ h i j ] ;

/-
**Quadratic Scaling**: Scaling all values by α scales the defect by α².
    This reflects the quadratic nature of the L² defect measure.
-/
theorem defect_scale (f : ι → ℝ) (α : ℝ) :
    consistencyDefect (fun i => α * f i) = α ^ 2 * consistencyDefect f := by
  unfold consistencyDefect; rw [ Finset.mul_sum ] ; congr; ext i; rw [ Finset.mul_sum ] ; congr; ext j; ring;

end ConsistencyDefect

/-! ## §3. The Overlap Nerve and Laplacian Connection

We introduce the **Overlap Nerve**: a weighted graph whose vertices are data
sources and whose edge weights measure the extent of feature overlap between
sources. The consistency defect, weighted by overlap, turns out to equal
twice the Laplacian quadratic form of the overlap graph.

This is a key bridge between database theory and spectral graph theory:
- The algebraic connectivity (Fiedler value) of the overlap graph bounds
  the minimum defect achievable by non-trivial data.
- Connected components of the overlap graph correspond to independently
  reconcilable data clusters.
-/

section LaplacianConnection

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The overlap nerve: a symmetric non-negative weight function on pairs of sources.
    w(i,j) represents the number of shared features between sources i and j. -/
structure OverlapNerve (ι : Type*) [Fintype ι] where
  /-- Edge weight between sources -/
  weight : ι → ι → ℝ
  /-- Weights are non-negative -/
  weight_nonneg : ∀ i j, 0 ≤ weight i j
  /-- Weights are symmetric -/
  weight_symm : ∀ i j, weight i j = weight j i

/-- Weighted consistency defect using the overlap nerve. -/
def weightedDefect (G : OverlapNerve ι) (f : ι → ℝ) : ℝ :=
  ∑ i : ι, ∑ j : ι, G.weight i j * (f j - f i) ^ 2

/-- The Laplacian quadratic form x^T L x, where L is the graph Laplacian
    of the overlap nerve. L(i,i) = deg(i), L(i,j) = -w(i,j) for i ≠ j.
    The quadratic form computes Σ_i deg(i)·x(i)² - Σ_{i,j} w(i,j)·x(i)·x(j). -/
def laplacianForm (G : OverlapNerve ι) (f : ι → ℝ) : ℝ :=
  ∑ i : ι, (∑ j : ι, G.weight i j) * f i ^ 2 -
  ∑ i : ι, ∑ j : ι, G.weight i j * f i * f j

/-
**Laplacian-Defect Identity**: The weighted consistency defect equals
    twice the Laplacian quadratic form.

    This is the fundamental bridge connecting database consistency (a data
    integration concept) to spectral graph theory (an algebraic concept).

    Proof: Expand (f(j) - f(i))² = f(j)² - 2f(i)f(j) + f(i)² and use symmetry
    of weights to combine the f(j)² and f(i)² terms into 2·Σ deg(i)·f(i)².
    The cross terms give -2·Σ w(i,j)·f(i)·f(j).
-/
theorem weighted_defect_eq_twice_laplacian (G : OverlapNerve ι) (f : ι → ℝ) :
    weightedDefect G f = 2 * laplacianForm G f := by
  unfold weightedDefect laplacianForm;
  simp +decide [ sub_sq, mul_sub, Finset.sum_sub_distrib, mul_assoc, Finset.mul_sum _ _ _, Finset.sum_add_distrib ];
  simp +decide only [mul_add, mul_sub, sum_add_distrib, sum_sub_distrib, sum_mul];
  simp +decide only [mul_comm, mul_assoc, Finset.mul_sum _ _ _, mul_left_comm];
  rw [ ← Finset.sum_comm ] ; ring;
  simp +decide only [G.weight_symm, ← sum_mul] ; ring;

/-
The weighted defect is non-negative (Laplacian is positive semidefinite).
-/
theorem weighted_defect_nonneg (G : OverlapNerve ι) (f : ι → ℝ) :
    0 ≤ weightedDefect G f := by
  exact Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => mul_nonneg ( G.weight_nonneg i j ) ( sq_nonneg _ )

end LaplacianConnection

/-! ## §4. Optimal Imputation: Mean Minimization

When data sources disagree, a fundamental question is: what single "consensus"
value minimizes the total disagreement? The answer is the arithmetic mean.

This section proves that the mean minimizes the sum of squared deviations,
a result that connects classical statistics to the sheaf-theoretic framework.
The mean is the unique element of the 0th cohomology H⁰ that best approximates
the inconsistent data.
-/

section MeanImputation

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Sum of squared deviations from a constant value c. -/
def deviationSum (f : ι → ℝ) (c : ℝ) : ℝ :=
  ∑ i : ι, (f i - c) ^ 2

/-- The arithmetic mean of source values. -/
def sourceMean (f : ι → ℝ) : ℝ :=
  (∑ i : ι, f i) / (Fintype.card ι : ℝ)

/-
**Bias-Variance Decomposition**: The sum of squared deviations from an
    arbitrary constant c decomposes as the sum of squared deviations from
    the mean plus n times the squared distance from c to the mean.

    This is the key identity underlying the optimality of the mean.
-/
theorem deviation_decomposition (f : ι → ℝ) (c : ℝ)
    (hn : (Fintype.card ι : ℝ) ≠ 0) :
    deviationSum f c = deviationSum f (sourceMean f) +
      (Fintype.card ι : ℝ) * (sourceMean f - c) ^ 2 := by
  unfold deviationSum sourceMean;
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
  simp +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, mul_assoc, mul_comm, mul_left_comm, hn ] ; ring;
  simp +decide [ sq, mul_assoc, hn ]

/-
**Mean Minimizes Deviation**: The arithmetic mean minimizes the total
    squared deviation among all constant imputations.

    This is the L² projection onto the space of constant functions —
    the 0th cohomology group of the Čech complex.
-/
theorem mean_minimizes_deviation (f : ι → ℝ) (c : ℝ)
    (hn : (Fintype.card ι : ℝ) ≠ 0) :
    deviationSum f (sourceMean f) ≤ deviationSum f c := by
  rw [ deviation_decomposition f c hn ];
  exact le_add_of_nonneg_right ( mul_nonneg ( Nat.cast_nonneg _ ) ( sq_nonneg _ ) )

end MeanImputation

/-! ## §5. Defect Monotonicity Under Source Addition

Adding a new data source can only increase the total inconsistency, provided
the new source disagrees with at least one existing source. More precisely,
the defect is monotone with respect to adding sources.
-/

section DefectMonotonicity

/-- The defect of a restriction to a subset of sources. -/
def restrictedDefect {ι : Type*} [Fintype ι] [DecidableEq ι]
    (f : ι → ℝ) (S : Finset ι) : ℝ :=
  ∑ i ∈ S, ∑ j ∈ S, (f j - f i) ^ 2

/-
**Defect Monotonicity**: Restricting to a subset decreases the defect.
    This reflects that fewer sources means fewer potential disagreements.
-/
theorem restricted_defect_le_total {ι : Type*} [Fintype ι] [DecidableEq ι]
    (f : ι → ℝ) (S : Finset ι) :
    restrictedDefect f S ≤ consistencyDefect f := by
  refine' le_trans ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ S ) fun _ _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _ ) _;
  exact Finset.sum_le_sum fun i _ => Finset.sum_le_sum_of_subset_of_nonneg ( Finset.subset_univ _ ) fun _ _ _ => sq_nonneg _

end DefectMonotonicity

/-! ## §6. Tropical Consistency Valuation

The tropical semiring (ℝ ∪ {∞}, min, +) provides an alternative framework
for consistency analysis. Under the log transform, multiplicative consistency
probabilities become additive costs, and the optimal merge strategy reduces
to a shortest-path problem.

We define the tropical consistency cost and prove its key properties.
-/

section TropicalConsistency

/-- The tropical consistency cost: for error rate r ∈ (0,1) and overlap count C,
    the tropical cost is -C · log(1-r), which equals -log((1-r)^C).
    This is the negative log-probability of consistency. -/
def tropicalCost (r : ℝ) (C : ℕ) : ℝ := -(C : ℝ) * Real.log (1 - r)

/-
**Tropical Additivity**: The tropical cost is additive in the overlap count.
    This means combining independent overlap regions corresponds to adding
    costs in the tropical semiring.
-/
theorem tropical_cost_add (r : ℝ) (C₁ C₂ : ℕ) :
    tropicalCost r (C₁ + C₂) = tropicalCost r C₁ + tropicalCost r C₂ := by
  unfold tropicalCost; push_cast; ring;

/-
The tropical cost is non-negative when r ∈ (0,1).
-/
theorem tropical_cost_nonneg (r : ℝ) (hr0 : 0 < r) (hr1 : r < 1) (C : ℕ) :
    0 ≤ tropicalCost r C := by
  exact mul_nonneg_of_nonpos_of_nonpos ( neg_nonpos_of_nonneg ( Nat.cast_nonneg _ ) ) ( Real.log_nonpos ( by linarith ) ( by linarith ) )

/-
**Tropical Monotonicity**: More overlaps means higher consistency cost.
-/
theorem tropical_cost_mono (r : ℝ) (hr0 : 0 < r) (hr1 : r < 1)
    (C₁ C₂ : ℕ) (h : C₁ ≤ C₂) :
    tropicalCost r C₁ ≤ tropicalCost r C₂ := by
  unfold tropicalCost; nlinarith [ show ( C₁ : ℝ ) ≤ C₂ by norm_cast, Real.log_le_sub_one_of_pos ( by linarith : 0 < 1 - r ) ] ;

end TropicalConsistency

/-! ## §7. Conjecture: Spectral Gap and Consistency Threshold

**Conjecture**: For an overlap nerve with algebraic connectivity λ₂ > 0
(the smallest positive eigenvalue of the Laplacian), the minimum defect
of any non-constant data configuration is bounded below by 2λ₂.

This would establish a "consistency threshold": data that is even slightly
inconsistent must have defect at least 2λ₂, with no intermediate values.
The gap is determined purely by the topology of the overlap network.

This conjecture is testable: compute λ₂ for random graphs and verify the
bound against the minimum non-zero defect found by optimization.
-/

end