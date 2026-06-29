# Certified Robustness for Kemeny–Young Aggregation over Three Classes: A Formally Verified Approach

## Abstract

We present the first formally verified certified robustness theorem for multiclass classification via Kemeny–Young ranking aggregation over three candidates. The Kemeny–Young rule selects a full ranking of classes by maximizing a score function over the symmetric group S₃, making it fundamentally different from simpler argmax-based classifiers. We exploit the fact that for three candidates, each of the six permutation scores is an explicit affine-linear function of three pairwise margins, reducing the robustness analysis to elementary linear algebra. Our main result establishes that if the winning ranking has a score gap Δ over all competitors, then the Kemeny winner is preserved under any perturbation of the class scores bounded by ε < Δ/(12·Kd), where Kd is the Lipschitz constant of the score map. All results are formalized and verified in Lean 4 with Mathlib.

## 1. Introduction

Certified robustness — the ability to guarantee that a classifier's prediction is unchanged under bounded input perturbations — has become a central concern in trustworthy machine learning. Most existing certified robustness results apply to classifiers whose prediction is a simple argmax of a score vector. However, many practical decision rules involve more complex aggregation mechanisms.

**Kemeny–Young aggregation** is a principled method from social choice theory that selects the *full ranking* of candidates that best agrees with pairwise comparisons. Given scores h(x, i) for each class i at input x, one forms pairwise margins m_ij = h(x,i) - h(x,j) and then selects the permutation σ ∈ S_n maximizing the Kemeny score:

$$K(σ) = \sum_{i < j \text{ in σ}} m_{σ(i), σ(j)}$$

The winning class is then the top element of the optimal ranking. This is a genuine combinatorial optimization problem: the prediction passes through an argmax over permutations, not just over classes.

For n = 3 candidates, the symmetric group S₃ has only 6 elements, and each Kemeny score is an explicit affine-linear function of the three basic margins m₀₁, m₀₂, m₁₂. This finiteness makes exact robustness certification tractable.

## 2. Mathematical Framework

### 2.1 Pairwise Margins

Given a score map h : α → Fin 3 → ℝ, the **pairwise margin** between classes i and j at point x is:

$$\text{margin}(h, x, i, j) = h(x, i) - h(x, j)$$

The three basic margins are m₀₁, m₀₂, and m₁₂. Note that m_ji = -m_ij.

### 2.2 Kemeny Scores

The six permutations of {0, 1, 2} yield the following Kemeny scores:

| Ranking | Score expression |
|---------|-----------------|
| 0 ≻ 1 ≻ 2 | +m₀₁ + m₀₂ + m₁₂ |
| 0 ≻ 2 ≻ 1 | +m₀₁ + m₀₂ − m₁₂ |
| 1 ≻ 0 ≻ 2 | −m₀₁ + m₀₂ + m₁₂ |
| 1 ≻ 2 ≻ 0 | −m₀₁ − m₀₂ + m₁₂ |
| 2 ≻ 0 ≻ 1 | +m₀₁ − m₀₂ − m₁₂ |
| 2 ≻ 1 ≻ 0 | −m₀₁ − m₀₂ − m₁₂ |

Each score is a *signed sum* of three margins with coefficients in {+1, −1}.

### 2.3 Winner Region Characterization

A key structural result (Theorem `r012_dominates_iff` in our formalization) characterizes when ranking 0 ≻ 1 ≻ 2 is the unique Kemeny winner:

> *The ranking 0 ≻ 1 ≻ 2 is the unique Kemeny-optimal ranking if and only if all three basic margins are strictly positive: m₀₁ > 0, m₀₂ > 0, and m₁₂ > 0.*

By symmetry, each ranking's winner region is the intersection of three open half-spaces. The six winner regions tile the margin space (minus boundary hyperplanes) into six open cones.

## 3. Main Results

### 3.1 Perturbation Bounds

**Theorem (Margin Perturbation).** If |h(y,i) − h(x,i)| ≤ Kd·ε for all i ∈ {0,1,2}, then for all pairs i,j:

$$|\text{margin}(h, y, i, j) - \text{margin}(h, x, i, j)| \leq 2 \cdot K_d \cdot \varepsilon$$

*Proof.* The margin difference decomposes as (h(y,i) − h(x,i)) − (h(y,j) − h(x,j)), and the triangle inequality gives the bound. □

**Theorem (Score Perturbation).** Under the same hypotheses, for any ranking s:

$$|K_s(y) - K_s(x)| \leq 6 \cdot K_d \cdot \varepsilon$$

*Proof.* Each Kemeny score is a sum of three signed margins. Each margin perturbs by at most 2Kd·ε, and the triangle inequality gives 3 × 2Kd·ε = 6Kd·ε. □

**Theorem (Gap Perturbation).** The gap between any two Kemeny scores perturbs by at most:

$$|(K_s(y) - K_t(y)) - (K_s(x) - K_t(x))| \leq 12 \cdot K_d \cdot \varepsilon$$

### 3.2 Certified Robustness

**Theorem (Kemeny Winner Stability).** Let s⋆ be the unique Kemeny winner at x with gap:

$$\Delta = \min_{t \neq s^\star} \big(K_{s^\star}(x) - K_t(x)\big) > 0$$

If |h(y,i) − h(x,i)| ≤ Kd·ε for all i and 12·Kd·ε < Δ, then s⋆ remains the unique Kemeny winner at y.

**Corollary (Certified Radius).** The Kemeny winner is preserved for all perturbations satisfying:

$$\varepsilon < \frac{\Delta}{12 \cdot K_d}$$

**Theorem (Label Stability).** Under the same conditions, if the top class of s⋆ is c, then c is the Kemeny winner class at y.

### 3.3 Tightness of the Constant

The factor 12 arises from the worst-case analysis: each score involves 3 margin terms (contributing 6Kd·ε), and comparing two scores doubles this (contributing 12Kd·ε). For specific rankings, sharper constants may be achievable by exploiting algebraic cancellations in the score difference formulas. For example, the difference between scores of rankings 0≻1≻2 and 0≻2≻1 is exactly 2m₁₂, which perturbs by at most 4Kd·ε rather than 12Kd·ε. A ranking-pair-specific analysis could improve the certified radius for particular winner transitions.

## 4. Formal Verification

All results are formalized in Lean 4 using Mathlib. The key design decisions:

1. **Explicit enumeration**: We define `KemenyRanking` as an inductive type with 6 constructors rather than working with `Equiv.Perm (Fin 3)`. This makes case analysis trivial and avoids permutation group machinery.

2. **Closed-form scores**: Each Kemeny score is defined directly as a sum of signed margins. The proof that these match the abstract Kemeny objective is verified by `kemenyScore_unfold`.

3. **Linear arithmetic**: All perturbation bounds reduce to linear arithmetic over ℝ, which Lean's `linarith` tactic handles automatically once the absolute value hypotheses are decomposed via `abs_le`.

The formalization is approximately 200 lines of Lean code with complete proofs and no axioms beyond the standard ones (`propext`, `Classical.choice`, `Quot.sound`).

## 5. Applications

### 5.1 Adversarial Robustness in Multi-Class Neural Networks

When a neural network produces logits for 3 classes, the Kemeny–Young rule provides a more robust decision boundary than simple argmax. Our theorem gives an explicit formula for the certified perturbation radius, which can be computed efficiently from the network's output at any test point.

### 5.2 Election Auditing

In ranked-choice elections with 3 candidates, our result quantifies how much measurement error in vote tallies can be tolerated before the Kemeny winner changes. If the margin of victory exceeds 12 times the maximum possible counting error, the election result is certified correct.

### 5.3 Sensor Fusion and Multi-Criteria Decision Making

When three alternatives are scored by multiple noisy sensors, Kemeny aggregation provides a principled ranking. Our robustness radius tells practitioners exactly how much sensor noise can be tolerated while maintaining confidence in the top-ranked alternative.

## 6. Discussion: Making the Result Accessible

### The Elevator Pitch

Imagine you're choosing between three candidates — say, three job applicants, three medical treatments, or three investment options. You have numerical scores for each candidate across several criteria. Instead of just picking whoever has the highest single score, Kemeny–Young aggregation considers *all possible orderings* of the candidates and selects the one that best matches the pairwise comparisons.

Our theorem answers a practical question: **How much can the scores wobble before the winner changes?**

Think of it like a ball sitting at the bottom of a bowl. If the bowl is deep, small bumps won't dislodge the ball. The "depth of the bowl" is the Kemeny gap Δ — how much better the winning ranking scores than its closest competitor. Our theorem says the winner is safe as long as the perturbation stays within Δ/12K of the original scores, where K measures how sensitive the scores are to the input.

### Historical Context

The Kemeny–Young method was introduced by John Kemeny (co-inventor of BASIC) in 1959 and later refined by H.P. Young. It is the unique rule satisfying a natural set of axioms for rank aggregation, making it a principled choice for combining multiple preference orderings.

Certified robustness, on the other hand, emerged from the adversarial machine learning literature of the 2010s, driven by the discovery that neural networks are vulnerable to imperceptible input perturbations. The marriage of these two ideas — classical social choice optimization with modern robustness certification — is what makes our result novel.

### Why This Matters Beyond Theory

Most certified robustness results handle classifiers that simply output the class with the highest score. Our result handles a classifier where the prediction passes through a **combinatorial optimization layer** — maximizing an objective function over all 6 permutations. This demonstrates that Lipschitz-based robustness certification extends naturally to optimization-based decision rules, opening the door to certifying robustness for more complex aggregation pipelines in machine learning.

## 7. Future Directions

1. **Extension to n > 3 candidates**: The Kemeny problem is NP-hard for general n, but for small n the explicit score formula approach generalizes. For n = 4 (24 permutations), the same framework applies with a certified radius of Δ/(2·n(n−1)·Kd).

2. **Sharper constants via winner-specific analysis**: Different winner regions have different distances to their boundaries. A winner-specific certified radius could replace the uniform factor 12 with tighter constants.

3. **Probabilistic extensions**: Combining deterministic Kemeny robustness with randomized smoothing could yield probabilistic certificates for much larger radii.

4. **Integration with tropical geometry**: The Kemeny score regions are polyhedral cones, and their intersection with tropical hypersurfaces from the GL₃ Satake framework could yield novel geometric insights into multiclass robustness.

## References

- J.G. Kemeny, "Mathematics without numbers," *Daedalus*, 88(4):577–591, 1959.
- H.P. Young and A. Levenglick, "A consistent extension of Condorcet's election principle," *SIAM J. Appl. Math.*, 35(2):285–300, 1978.
- The Lean 4 theorem prover: https://leanprover.github.io/
- Mathlib: https://leanprover-community.github.io/mathlib4_docs/
