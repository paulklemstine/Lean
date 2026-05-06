# GL3 Tropical Satake Certified Robustness for Borda-Count Hecke Score Aggregation

## Abstract

We develop a formally verified robustness theory for multiclass classifiers whose final prediction is determined by Borda-count aggregation of pairwise score comparisons. Working over a finite label type with arbitrary cardinality, we prove tight perturbation bounds for both the weighted Borda surrogate Ω_i(S) = Σ_{j≠i}(S_i − S_j) and the thresholded Borda score B_i(S) = Σ_{j≠i} 𝟙[S_i > S_j]. Our main results establish explicit certified robustness radii: a margin threshold of 4(n−1)η for the weighted Borda winner and a pairwise separation threshold of 2η for the discrete Borda winner, where η bounds the per-class score perturbation. All theorems are machine-verified in Lean 4 with Mathlib, establishing the first formally certified robustness theory for rank-aggregation-based classifiers. We specialize these results to the GL3 tropical Satake score family, obtaining explicit perturbation certificates for multiclass decisions built from the full pairwise comparison graph.

**Keywords**: certified robustness, Borda count, rank aggregation, tropical geometry, formal verification, Lean 4

---

## 1. Introduction

### 1.1 Motivation

Adversarial robustness certification has emerged as a central concern in machine learning, yet most existing certified defense methods focus on simple decision rules: argmax of class scores, binary classifiers, or plurality voting. Real-world multiclass systems increasingly employ more sophisticated aggregation mechanisms drawn from social choice theory, including Borda counts, Copeland rules, and Condorcet methods.

The Borda count—which ranks each class by the number of pairwise comparisons it wins—is particularly natural for settings where class scores represent distinct "views" or "features" of the input, as arises in representation-theoretic approaches to classification. In the GL3 tropical Satake framework, each class is associated with a Hecke eigenvalue, and the final classification decision aggregates pairwise comparisons between these eigenvalues.

### 1.2 Contributions

We make the following contributions:

1. **Pairwise margin perturbation bound** (Theorem 1): We prove that each pairwise margin S_i − S_j changes by at most 2η when individual class scores change by at most η. This 2× amplification factor is tight and cannot be improved.

2. **Weighted Borda Lipschitz bound** (Theorem 2): The weighted Borda surrogate Ω_i satisfies |Ω_i(T) − Ω_i(S)| ≤ 2(n−1)η, yielding a Lipschitz constant of 2(n−1) for the aggregation map.

3. **Weighted Borda winner certification** (Theorem 3): If the weighted Borda margin exceeds 4(n−1)η, the strict winner is preserved under any η-bounded perturbation.

4. **Pairwise sign stability** (Theorem 4): Pairwise comparisons with margins exceeding 2η cannot flip sign under η-bounded perturbations.

5. **Thresholded Borda invariance** (Theorem 5): Under uniform pairwise separation 2η < |S_i − S_j| for all i ≠ j, the discrete Borda score vector is exactly preserved.

6. **Borda winner certification** (Theorem 6): Combining the above yields a certified robustness radius for the discrete Borda winner.

7. **Structural algebraic identities**: We prove Ω_i = nS_i − Σ_k S_k and Ω_i − Ω_j = n(S_i − S_j), revealing that the weighted Borda winner always coincides with the argmax of the original scores.

All results are formalized and machine-verified in Lean 4 with Mathlib.

### 1.3 Relation to existing work

Certified robustness for neural networks has been extensively studied through randomized smoothing (Cohen et al., 2019), interval bound propagation, and abstract interpretation. However, these methods certify robustness of the *score function* rather than the *aggregation rule*. Our work is complementary: given any certified perturbation bound on individual class scores, we derive certified robustness of the aggregate decision.

The connection to social choice theory is intentional. The Borda count is one of the most studied voting rules, known for its resistance to certain forms of manipulation (Saari, 2001). Our perturbation analysis can be viewed as a quantitative stability theorem for the Borda rule under bounded "voter error"—a perspective that may be of independent interest in computational social choice.

---

## 2. Definitions and Setup

### 2.1 Score vectors and perturbations

Let α be a finite type with n = |α| elements (the class labels). A *score vector* is a function S : α → ℝ assigning a real-valued score to each class. A *perturbation* is a pair (S, T) of score vectors satisfying

∀ c ∈ α, |T(c) − S(c)| ≤ η

for some η ≥ 0. The parameter η represents the maximum per-class score change, which in the GL3 tropical Satake setting arises as K · ε where K is the tropical Lipschitz constant and ε is the input perturbation bound.

### 2.2 Pairwise margins

The *pairwise margin* between classes i and j is:

m(S, i, j) := S(i) − S(j)

This represents the strength of preference for class i over class j.

### 2.3 Weighted Borda score

The *weighted Borda score* (Copeland-margin surrogate) for class i is:

Ω_i(S) := Σ_{j≠i} m(S, i, j) = Σ_{j≠i} (S_i − S_j)

This is a continuous relaxation of the Borda count that sums the actual margins rather than just their signs.

### 2.4 Thresholded Borda score

The *thresholded Borda score* for class i is:

B_i(S) := Σ_{j≠i} 𝟙[S_i > S_j]

This is the classical Borda count: the number of pairwise comparisons that class i wins.

### 2.5 Winners

Class w is a *strict weighted Borda winner* if Ω_j(S) < Ω_w(S) for all j ≠ w.

Class w is a *strict Borda winner* if B_j(S) < B_w(S) for all j ≠ w.

---

## 3. Main Results

### 3.1 Pairwise margin perturbation (Theorem 1)

**Theorem (pairMargin_diff_le).** For any score vectors S, T with |T(c) − S(c)| ≤ η for all c,

|m(T, i, j) − m(S, i, j)| ≤ 2η.

*Proof.* We expand:

m(T, i, j) − m(S, i, j) = (T_i − T_j) − (S_i − S_j) = (T_i − S_i) − (T_j − S_j).

By the triangle inequality:

|(T_i − S_i) − (T_j − S_j)| ≤ |T_i − S_i| + |T_j − S_j| ≤ η + η = 2η. ∎

The factor 2 is tight: taking T_i = S_i + η and T_j = S_j − η achieves equality.

### 3.2 Weighted Borda perturbation (Theorem 2)

**Theorem (weightedBorda_diff_le).** For any score vectors S, T with |T(c) − S(c)| ≤ η for all c,

|Ω_i(T) − Ω_i(S)| ≤ 2(n−1)η.

*Proof.* We have:

Ω_i(T) − Ω_i(S) = Σ_{j≠i} [m(T,i,j) − m(S,i,j)].

By the triangle inequality for sums:

|Σ_{j≠i} [m(T,i,j) − m(S,i,j)]| ≤ Σ_{j≠i} |m(T,i,j) − m(S,i,j)| ≤ Σ_{j≠i} 2η = 2(n−1)η. ∎

### 3.3 Weighted Borda winner certification (Theorem 3)

**Theorem (weightedBorda_certified_winner).** If Ω_w(S) − Ω_j(S) > 4(n−1)η for all j ≠ w, then w is a strict weighted Borda winner under T.

*Proof.* By Theorem 2:

Ω_w(T) ≥ Ω_w(S) − 2(n−1)η,
Ω_j(T) ≤ Ω_j(S) + 2(n−1)η.

Therefore:

Ω_w(T) − Ω_j(T) ≥ [Ω_w(S) − Ω_j(S)] − 4(n−1)η > 0. ∎

The factor 4(n−1) arises because both the winner's score can decrease and the challenger's score can increase, each by up to 2(n−1)η.

### 3.4 Pairwise sign stability (Theorem 4)

**Theorem (pairMargin_sign_stable).** If 2η < m(S, i, j), then 0 < m(T, i, j).

**Theorem (pairMargin_no_flip).** If 2η < |m(S, i, j)|, then 0 < m(S, i, j) ↔ 0 < m(T, i, j).

*Proof.* From Theorem 1, m(T, i, j) ≥ m(S, i, j) − 2η > 0. The biconditional follows by considering both signs. ∎

### 3.5 Thresholded Borda invariance (Theorem 5)

**Theorem (bordaScore_eq_of_all_pairwise_margin).** If 2η < |m(S, i, j)| for all i ≠ j, then B_i(T) = B_i(S) for all i.

*Proof.* Each indicator 𝟙[T_i > T_j] = 𝟙[m(T,i,j) > 0] equals 𝟙[m(S,i,j) > 0] = 𝟙[S_i > S_j] by Theorem 4. Since the Borda score is a sum of these indicators, it is preserved. ∎

### 3.6 Borda winner certification (Theorem 6)

**Theorem (borda_certified_winner).** If w is a strict Borda winner under S and 2η < |m(S, i, j)| for all i ≠ j, then w is a strict Borda winner under T.

*Proof.* By Theorem 5, B_i(T) = B_i(S) for all i, so the winner is trivially preserved. ∎

### 3.7 Structural identities

**Theorem (weightedBorda_eq_card_mul_sub_sum).**

Ω_i(S) = n · S_i − Σ_k S_k.

**Theorem (weightedBorda_sub_weightedBorda).**

Ω_i(S) − Ω_j(S) = n · (S_i − S_j).

These identities reveal that the weighted Borda score is an affine transformation of the original class score. In particular, the weighted Borda winner always coincides with the class with the highest score S_i. This means the weighted Borda certification theorem, while formally about the aggregated score, is mathematically equivalent to certifying the argmax of S directly—but with the constant factor n in the margin.

The genuinely new content lies in the thresholded Borda theorem (Theorem 5–6), where the discrete rank structure introduces a qualitatively different robustness condition: pairwise separation rather than winner margin.

### 3.8 Specialization to GL3 (n = 3)

For n = 3 classes, the constants simplify:
- Weighted Borda perturbation: |Ω_i(T) − Ω_i(S)| ≤ 4η
- Winner certification threshold: Ω_w(S) − Ω_j(S) > 8η
- Pairwise sign stability: 2η < |S_i − S_j|

Given the GL3 tropical Satake perturbation bound |S_c(x+δ) − S_c(x)| ≤ K·ε, the certified input perturbation radii are:

- **Weighted Borda**: ε < [Ω_w(x) − Ω_j(x)] / (8K) for all j ≠ w
- **Thresholded Borda**: ε < min_{i≠j} |S_i(x) − S_j(x)| / (2K)

---

## 4. Formal Verification

All theorems are formalized in Lean 4 with Mathlib. The formalization consists of approximately 260 lines of Lean code, including:

- 7 definitions (pairMargin, weightedBorda, bordaScore, winner predicates)
- 14 theorems, all proved without sorry
- Only standard axioms used (propext, Classical.choice, Quot.sound)

The proof architecture follows a clean dependency chain:
```
pairMargin_diff_le
  ├─→ weightedBorda_diff_le ──→ weightedBorda_certified_winner ──→ gl3_weightedBorda_certified_radius
  ├─→ pairMargin_sign_stable
  ├─→ pairMargin_sign_stable_neg
  └─→ pairMargin_no_flip ──→ bordaScore_eq_of_pairwise_margin
                                  └─→ bordaScore_eq_of_all_pairwise_margin
                                        └─→ borda_certified_winner ──→ gl3_borda_certified_radius

weightedBorda_eq_card_mul_sub_sum
  ├─→ weightedBorda_sub_weightedBorda
  └─→ weightedBorda_diff_le_card3
```

The formalization is parametric in the label type α (with `[Fintype α] [DecidableEq α]`), so it applies to any finite number of classes, not just 3.

---

## 5. Applications

### 5.1 Adversarial robustness certification

The primary application is certifying adversarial robustness for multiclass classifiers that use Borda aggregation. Given a classifier with:
- n class labels
- Per-class score Lipschitz constant K
- Input perturbation bound ε

The certified robustness radius for the Borda winner is:

ε_certified = min_{i≠j} |S_i(x) − S_j(x)| / (2K)

This provides a provably correct certificate: if ‖δ‖∞ ≤ ε_certified, the Borda winner cannot change.

### 5.2 Ensemble methods

Borda aggregation naturally arises in ensemble methods where multiple models vote on a classification. Each model's score for each class contributes to pairwise comparisons. Our theory certifies that ensemble decisions are robust when individual model scores are sufficiently stable.

### 5.3 Multi-criteria decision making

In settings where multiple criteria (features, objectives, metrics) are used to rank alternatives, the Borda count provides a principled aggregation mechanism. Our perturbation theory gives quantitative guarantees on the stability of the final ranking under measurement noise.

### 5.4 Computational social choice

The pairwise sign stability theorem (Theorem 4) is a quantitative stability result for the Borda rule under bounded voter error. This connects to the literature on distance-based manipulation complexity in computational social choice.

---

## 6. Discussion: A Bridge Between Voting Theory and Machine Learning

*For a general audience*

Imagine you're organizing a cooking competition with three contestants. Each judge scores every dish, and the winner is determined by counting pairwise victories: Chef A beats Chef B if more judges preferred A's dish. This is essentially the Borda count—one of the oldest and most studied voting methods, dating back to Jean-Charles de Borda in 1781.

Now imagine the judges' scores are slightly noisy—perhaps one judge was distracted, or the lighting made a dish look different. How much noise can you tolerate before the wrong chef wins?

This is precisely the question our theorems answer, in the context of machine learning classifiers rather than cooking competitions. Modern AI systems often make decisions by comparing multiple "scores" and aggregating the results—essentially running an election among possible classifications. Our formal proofs provide exact, mathematically guaranteed thresholds: as long as the noise stays below a precise bound (which we compute explicitly), the correct winner is guaranteed to be selected.

What makes this result particularly satisfying is the interplay between two mathematical worlds:

1. **Continuous analysis**: The score perturbation bound |ΔS| ≤ η is an analytic (continuous) statement about real-valued functions.

2. **Discrete combinatorics**: The Borda count is fundamentally discrete—it counts wins and losses, with no room for "partial" victories.

Our theorems bridge these worlds by showing that sufficiently large continuous margins guarantee discrete stability. The key insight is that each pairwise comparison S_i > S_j? is protected by a "buffer zone" of width 2η. As long as the true margin exceeds this buffer, the comparison result cannot flip, and therefore the entire Borda ranking is preserved.

This is reminiscent of how digital circuits work: analog voltages represent binary bits, and the circuit is designed with sufficient noise margins that the digital interpretation is always correct. Our theorems provide the mathematical analogue for AI decision-making.

The connection to tropical geometry (the "GL3 tropical Satake" part of the title) comes from the particular way the class scores are computed in the representation-theoretic framework. Tropical geometry—a combinatorial shadow of algebraic geometry where addition replaces multiplication and min/max replaces addition—provides the score functions. The tropical Lipschitz property of these scores feeds directly into our perturbation bound as the constant K, completing the chain from input perturbation to certified classification.

---

## 7. Future Directions

1. **Sharper local certificates**: The global pairwise separation condition in Theorem 6 can be weakened. Only those pairwise comparisons whose flip could reduce the winner's Borda lead below second place need to be controlled. Formalizing this optimal condition would yield tighter certificates.

2. **Condorcet and Copeland rules**: The pairwise sign stability theorem (Theorem 4) immediately applies to other comparison-based voting rules. Extending the full certification to Condorcet winners and Copeland scoring is a natural next step.

3. **Weighted voting**: In ensemble methods, different models may have different reliabilities. Extending the theory to weighted Borda counts Σ w_j · 𝟙[S_i > S_j] with non-uniform weights is straightforward but requires tracking the weight vector.

4. **Probabilistic certificates**: Combining our deterministic bounds with randomized smoothing could yield probabilistic robustness certificates that are tighter in practice.

5. **Higher-rank groups**: The GL3 specialization suggests generalizations to GL_n for arbitrary n, where the representation-theoretic structure provides richer score families.

---

## References

- Cohen, J., Rosenfeld, E., & Kolter, J.Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
- Saari, D.G. (2001). *Decisions and Elections: Explaining the Unexpected*. Cambridge University Press.
- de Borda, J.C. (1781). Mémoire sur les élections au scrutin. *Mémoires de l'Académie Royale des Sciences*.

---

## Appendix: Complete Lean 4 Theorem Statements

```lean
-- Perturbation bounds
theorem pairMargin_diff_le : |pairMargin T i j - pairMargin S i j| ≤ 2 * η
theorem weightedBorda_diff_le : |weightedBorda T i - weightedBorda S i| ≤ 2 * (n-1) * η

-- Winner certification
theorem weightedBorda_certified_winner : margin > 4(n-1)η → strictWinnerWeighted T w
theorem borda_certified_winner : strictWinnerBorda S w → pairwise_sep → strictWinnerBorda T w

-- Sign stability
theorem pairMargin_sign_stable : 2η < m(S,i,j) → 0 < m(T,i,j)
theorem pairMargin_no_flip : 2η < |m(S,i,j)| → (0 < m(S,i,j) ↔ 0 < m(T,i,j))

-- Borda invariance
theorem bordaScore_eq_of_all_pairwise_margin : pairwise_sep → B_i(T) = B_i(S)

-- Structural identities
theorem weightedBorda_eq_card_mul_sub_sum : Ω_i = n·S_i - Σ S_k
theorem weightedBorda_sub_weightedBorda : Ω_i - Ω_j = n·(S_i - S_j)

-- GL3 specializations
theorem weightedBorda_diff_le_card3 : |α| = 3 → |Ω_i(T) - Ω_i(S)| ≤ 4η
theorem gl3_weightedBorda_certified_radius : margin > 4(n-1)Kε → strictWinnerWeighted T w
theorem gl3_borda_certified_radius : strict_winner ∧ pairwise_sep → strictWinnerBorda T w
```
