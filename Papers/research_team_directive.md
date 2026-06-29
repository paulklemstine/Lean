# Tropical Separation Implies Finite Max-Plus Classifier with Certified Margin

## Abstract

We establish a formal bridge theorem converting existential coordinate-wise separation data into an explicit max-plus (tropical) scoring rule on finite feature sets with a provable positive margin. Given a finite feature map φ : α → ι → ℝ over a finite index type ι, and finite sets P (positive) and N (negative), we prove that the existence of a single coordinate uniformly separating all positives from all negatives implies the existence of a weight vector w : ι → ℝ and margin γ > 0 such that the tropical score max_i(w_i + φ(p)_i) exceeds max_i(w_i + φ(n)_i) + γ for all p ∈ P, n ∈ N. The margin is explicitly realized as the minimum pairwise gap on the separating coordinate. All results are machine-verified with complete formal proofs.

**Keywords:** tropical geometry, max-plus algebra, certified margins, finite separation, formal verification, idempotent analysis

---

## 1. Introduction

### 1.1 Motivation

The classification problem — assigning labels to data points based on measured features — is central to machine learning, statistics, and pattern recognition. Classical approaches such as support vector machines (SVMs) seek linear separators (hyperplanes) with maximum margin, where the margin quantifies robustness to perturbation.

Tropical (max-plus) geometry offers an alternative framework where the basic operation is not the inner product ⟨w, φ⟩ = Σ_i w_i · φ_i but the tropical score max_i(w_i + φ_i). This seemingly simple change has profound geometric consequences: tropical hyperplanes are piecewise-linear, tropical convex sets have polyhedral structure, and tropical linear algebra is governed by idempotent semiring axioms.

Despite extensive theoretical development of tropical geometry (Mikhalkin, Itenberg–Mikhalkin–Shustin, Maclagan–Sturmfels), the connection to concrete classification problems with certified margins has remained largely informal. This paper fills that gap.

### 1.2 Contributions

1. **Formal definitions** of tropical score (`tropicalScore`) and tropical separation (`tropicallySeparates`) over finite types, using Finset.sup' for the max-plus evaluation.

2. **Main separation theorem** (`exists_tropical_separator_with_margin`): if a single coordinate uniformly separates P from N, then a tropical classifier with positive margin exists.

3. **Explicit margin computation** (`tropicalCoordMargin`, `tropicalCoordMargin_pos`): the margin equals the minimum pairwise coordinate gap, and is provably positive.

4. **Constructive classifier** (`exists_weights_realizing_margin`): explicit weight construction realizing the computed margin.

5. **Concrete validation** on a small example with 4 points and 2 features.

6. **Complete formal verification** of all results with no unproven assumptions (no `sorry`).

### 1.3 Related Work

**Tropical convexity.** Develin and Sturmfels (2004) introduced tropical convex hulls and proved tropical analogs of classical convexity theorems. Joswig (2005) studied tropical halfspaces. Our work contributes the first formally verified finite separation theorem with explicit margins.

**Max-plus linear algebra.** Butkovič (2010) provides a comprehensive treatment of max-plus linear systems, eigenvalue problems, and optimization. Our tropical score is a max-plus linear functional; the separation theorem is a feasibility result for max-plus inequality systems.

**Certified robustness.** The Lipschitz-based margin preservation approach of `TropicalSatakeMargin.lean` (using inner-product scores and L¹ perturbation bounds) is complementary to our result. That work certifies robustness under perturbation for fixed classifiers; our work constructs classifiers with guaranteed margins from separation data.

**Formal mathematics.** The use of interactive theorem provers for machine learning theory is relatively new. Our work demonstrates that nontrivial classification theorems can be fully machine-verified using Mathlib's extensive library for real analysis, order theory, and finite combinatorics.

---

## 2. Definitions and Notation

### 2.1 Setting

Let α be an arbitrary type (the data domain), and let ι be a finite nonempty type (the feature index set). A feature map is a function φ : α → ι → ℝ, where φ(x)(i) represents the i-th feature of data point x.

Let P, N : Finset α be finite sets of positive and negative examples, respectively.

### 2.2 Tropical Score

**Definition 2.1** (Tropical Score). Given weight vector w : ι → ℝ and feature vector φ : ι → ℝ, the tropical score is:

```
tropicalScore(w, φ) = max_{i ∈ ι} (w_i + φ_i)
```

Formally, this is implemented as `Finset.univ.sup' Finset.univ_nonempty (fun i => w i + φ i)`, using the nonemptiness of `Finset.univ` for a `Nonempty` type.

### 2.3 Tropical Separation

**Definition 2.2** (Tropical Separation). Weight vector w with margin γ *tropically separates* P from N with respect to feature map φ if:

```
∀ p ∈ P, ∀ n ∈ N, tropicalScore(w, φ(p)) ≥ tropicalScore(w, φ(n)) + γ
```

### 2.4 Coordinate Margin

**Definition 2.3** (Tropical Coordinate Margin). Given a separating coordinate i₀ and nonempty product P ×ˢ N, the coordinate margin is:

```
tropicalCoordMargin(φ, i₀, P, N) = min_{(p,n) ∈ P × N} (φ(p)(i₀) - φ(n)(i₀))
```

Implemented as `(P ×ˢ N).inf' hPN (fun pn => φ pn.1 i₀ - φ pn.2 i₀)`.

---

## 3. Main Results

### 3.1 Basic Properties of Tropical Scores

**Theorem 3.1** (Coordinate Lower Bound). For any w, φ, and i:
```
tropicalScore(w, φ) ≥ w_i + φ_i
```

*Proof.* The supremum of a nonempty finite set is at least any of its elements. Follows directly from `Finset.le_sup'`. □

**Theorem 3.2** (Universal Upper Bound). If w_i + φ_i ≤ a for all i, then:
```
tropicalScore(w, φ) ≤ a
```

*Proof.* The supremum of a set bounded above by a is at most a. Follows from `Finset.sup'_le`. □

**Theorem 3.3** (Dominant Coordinate). If w_i + φ_i ≤ w_{i₀} + φ_{i₀} for all i, then:
```
tropicalScore(w, φ) = w_{i₀} + φ_{i₀}
```

*Proof.* Combine Theorems 3.1 and 3.2 using antisymmetry. □

### 3.2 Main Separation Theorem

**Theorem 3.4** (Tropical Separation from Coordinate Witness). Let φ : α → ι → ℝ be a feature map and P, N : Finset α. If there exists i₀ : ι such that φ(n)(i₀) < φ(p)(i₀) for all p ∈ P, n ∈ N, then there exist w : ι → ℝ and γ > 0 such that w tropically separates P from N with margin γ.

*Proof sketch.* We handle two cases:

**Case 1: P = ∅ or N = ∅.** The conclusion is vacuously true. Take w = 0, γ = 1.

**Case 2: P and N are both nonempty.** Extract the separating coordinate i₀. We need to construct w such that tropicalScore(w, φ(x)) = φ(x)(i₀) for all x ∈ P ∪ N.

**Step 2a: Compute the suppression bound.** Since P ∪ N is finite, let:
```
M = Σ_{x ∈ P ∪ N} Σ_{i ∈ ι} |φ(x)(i) - φ(x)(i₀)|
```
This crude but effective bound satisfies M ≥ φ(x)(i) - φ(x)(i₀) for all x ∈ P ∪ N and all i.

**Step 2b: Construct the weight vector.**
```
w_i = { 0       if i = i₀
       { -M      if i ≠ i₀
```

**Step 2c: Verify dominance.** For any x ∈ P ∪ N and i ≠ i₀:
```
w_i + φ(x)(i) = -M + φ(x)(i) ≤ φ(x)(i₀) = w_{i₀} + φ(x)(i₀)
```
since M ≥ φ(x)(i) - φ(x)(i₀). By Theorem 3.3, tropicalScore(w, φ(x)) = φ(x)(i₀).

**Step 2d: Establish the margin.**
```
tropicalScore(w, φ(p)) - tropicalScore(w, φ(n)) = φ(p)(i₀) - φ(n)(i₀) > 0
```

Take γ = tropicalCoordMargin(φ, i₀, P, N) = min_{(p,n)} (φ(p)(i₀) - φ(n)(i₀)). By Theorem 3.5 below, γ > 0, and by definition of inf', φ(p)(i₀) - φ(n)(i₀) ≥ γ for each pair. □

### 3.3 Margin Positivity

**Theorem 3.5** (Coordinate Margin Positivity). If i₀ separates all pairs (φ(n)(i₀) < φ(p)(i₀) for all p ∈ P, n ∈ N) and P ×ˢ N is nonempty, then:
```
tropicalCoordMargin(φ, i₀, P, N) > 0
```

*Proof.* Each term φ(p)(i₀) - φ(n)(i₀) is strictly positive by hypothesis. The infimum of a nonempty finite set of positive reals is positive. □

### 3.4 Constructive Classifier

**Theorem 3.6** (Weights Realizing the Margin). Given separating coordinate i₀ with P, N nonempty, there exists w : ι → ℝ such that:
1. γ := tropicalCoordMargin(φ, i₀, P, N) > 0
2. ∀ p ∈ P, ∀ n ∈ N, tropicalScore(w, φ(p)) ≥ tropicalScore(w, φ(n)) + γ

The weight construction is the same as in Theorem 3.4. □

---

## 4. Algorithm

### 4.1 Tropical Separation Algorithm

**Input:** Feature map φ : α → ι → ℝ, positive set P, negative set N, separating coordinate i₀.

**Output:** Weight vector w : ι → ℝ and margin γ > 0.

```
Algorithm TropicalSeparator(φ, P, N, i₀):
  1. Compute M = Σ_{x ∈ P ∪ N} Σ_{i ∈ ι} |φ(x)(i) - φ(x)(i₀)|
  2. Set w[i₀] = 0
  3. For each i ≠ i₀: set w[i] = -M
  4. Compute γ = min_{p ∈ P, n ∈ N} (φ(p)(i₀) - φ(n)(i₀))
  5. Return (w, γ)
```

**Complexity:** O(|P ∪ N| · |ι|) time, O(|ι|) space for the weight vector.

### 4.2 Coordinate Search

If the separating coordinate is not known a priori:

```
Algorithm FindSeparatingCoordinate(φ, P, N):
  For each i ∈ ι:
    min_gap = min_{p ∈ P, n ∈ N} (φ(p)(i) - φ(n)(i))
    If min_gap > 0:
      Return i
  Return None  // No uniform coordinate witness exists
```

**Complexity:** O(|ι| · |P| · |N|) time.

---

## 5. Concrete Example

### 5.1 Setup

Consider α = Fin 4, ι = Fin 2 (4 data points, 2 features):

| Point | Feature 0 | Feature 1 | Label    |
|-------|-----------|-----------|----------|
| 0     | 10        | 1         | Positive |
| 1     | 8         | 2         | Positive |
| 2     | 3         | 5         | Negative |
| 3     | 2         | 7         | Negative |

### 5.2 Separation Analysis

**Coordinate 0:** min positive = 8, max negative = 3. Gap = 5 > 0. ✓ Separates.

**Coordinate 1:** Positive values {1, 2}, negative values {5, 7}. Negatives are *higher*. ✗ Does not separate.

Coordinate 0 is the separating coordinate with margin γ = min(10-3, 10-2, 8-3, 8-2) = min(7, 8, 5, 6) = 5.

### 5.3 Weight Construction

M = Σ_{x ∈ {0,1,2,3}} Σ_{i ∈ {0,1}} |φ(x)(i) - φ(x)(0)|
  = (|10-10| + |1-10|) + (|8-8| + |2-8|) + (|3-3| + |5-3|) + (|2-2| + |7-2|)
  = (0 + 9) + (0 + 6) + (0 + 2) + (0 + 5) = 22

Weight vector: w = (0, -22).

Tropical scores:
- Point 0: max(0+10, -22+1) = max(10, -21) = 10
- Point 1: max(0+8, -22+2) = max(8, -20) = 8
- Point 2: max(0+3, -22+5) = max(3, -17) = 3
- Point 3: max(0+2, -22+7) = max(2, -15) = 2

Margin: min(10-3, 10-2, 8-3, 8-2) = 5. ✓

### 5.4 Formal Verification

The concrete example is fully verified:
```
theorem example_tropical_separator :
    ∃ w : Fin 2 → ℝ, ∃ γ : ℝ, 0 < γ ∧
      tropicallySeparates examplePhi w γ ({0, 1} : Finset (Fin 4))
                                         ({2, 3} : Finset (Fin 4))
```

This is proved by instantiating the main theorem with `⟨0, examplePhi_sep⟩`.

---

## 6. Discussion

### 6.1 Strength of the Hypothesis

The uniform coordinate witness hypothesis — that a single coordinate separates all pairs — is strong. It fails when separation requires different coordinates for different pairs. The tropical Hahn–Banach theorem (Future Direction 1) would address this by characterizing when general tropical separation is possible.

Despite its strength, the hypothesis covers important practical cases:
- **Feature engineering:** If domain experts can identify a single discriminative feature, the theorem immediately provides a certified classifier.
- **Boosting initialization:** The coordinate-witness classifier serves as a base learner for tropical boosting algorithms.
- **Screening rules:** The coordinate gap provides a quick test for whether a feature set admits easy tropical separation.

### 6.2 Relationship to Classical SVMs

The tropical separation theorem is analogous to the classical result that linearly separable data admits a maximum-margin hyperplane. Key differences:

| Property | Classical SVM | Tropical Classifier |
|----------|--------------|-------------------|
| Score function | Σ w_i · φ_i | max_i(w_i + φ_i) |
| Decision boundary | Hyperplane | Tropical hyperplane (piecewise-linear) |
| Margin | Distance to hyperplane | Min pairwise score gap |
| Optimization | Quadratic program | Closed-form construction |
| Robustness | Lipschitz in L² | Exact under coordinate perturbation |

### 6.3 Computational Aspects

The weight construction is deterministic and runs in O(|P ∪ N| · |ι|) time. No optimization is required. This makes tropical classifiers attractive for applications requiring:
- **Explainability:** The dominant coordinate is immediately identifiable.
- **Real-time certification:** The margin computation is a simple minimum over pairs.
- **Hardware efficiency:** The max-plus operation maps naturally to comparison-based hardware.

### 6.4 Limitations

1. **Single coordinate witness:** The current theorem requires one coordinate to dominate all others. Multi-coordinate tropical separation remains open.
2. **Pessimistic weights:** The suppression penalty M can be very large, leading to numerically extreme weight vectors. Tighter bounds (e.g., using per-coordinate ranges) would improve practical behavior.
3. **No generalization guarantee:** The margin is defined over the training set only. Tropical VC theory or Rademacher complexity bounds would be needed for test-set guarantees.

---

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps. Key priorities:

1. Tropical Hahn–Banach theorem (weakened hypothesis, general weights)
2. Tropical data processing inequality (information-theoretic margins)
3. Equivariant tropical separators (symmetric data)
4. Residuated duality (impossibility certificates)
5. Hierarchical tropical renormalization (deep feature architectures)

---

## 8. References

1. Butkovič, P. *Max-linear Systems: Theory and Algorithms.* Springer, 2010.
2. Develin, M. and Sturmfels, B. "Tropical convexity." *Documenta Mathematica* 9 (2004): 1–27.
3. Joswig, M. "Tropical halfspaces." *Combinatorial and Computational Geometry* 52 (2005): 409–431.
4. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* AMS, 2015.
5. Mikhalkin, G. "Enumerative tropical algebraic geometry in ℝ²." *Journal of the AMS* 18 (2005): 313–377.

---

## Appendix A: Complete Formal Proof Listing

The complete formal development is in `Catalog/Bridges/TropicalSeparationClassifier.lean`. Key formal statements:

```
-- Core definitions
def tropicalScore {ι : Type*} [Fintype ι] [Nonempty ι] (w φ : ι → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => w i + φ i)

def tropicallySeparates {α ι : Type*} [Fintype ι] [Nonempty ι]
    (φ : α → ι → ℝ) (w : ι → ℝ) (γ : ℝ) (P N : Finset α) : Prop :=
  ∀ p ∈ P, ∀ n ∈ N, tropicalScore w (φ p) ≥ tropicalScore w (φ n) + γ

-- Main theorem
theorem exists_tropical_separator_with_margin
    {α ι : Type*} [Fintype ι] [Nonempty ι] [DecidableEq ι] [DecidableEq α]
    (φ : α → ι → ℝ) (P N : Finset α)
    (hsep : ∃ i : ι, ∀ p ∈ P, ∀ n ∈ N, φ n i < φ p i) :
    ∃ w : ι → ℝ, ∃ γ : ℝ, 0 < γ ∧
      ∀ p ∈ P, ∀ n ∈ N,
        tropicalScore w (φ p) ≥ tropicalScore w (φ n) + γ
```

All 8 theorems are proved without `sorry`, using only standard axioms (propext, Classical.choice, Quot.sound).
