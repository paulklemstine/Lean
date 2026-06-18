# Certified Robustness for Instant-Runoff Classifiers via Gap Certificates

## Abstract

We present a formal theory of certified adversarial robustness for classifiers based on instant-runoff (sequential elimination) voting over multiclass score functions. The central contribution is the *gap certificate*—a recursive condition requiring that at every round of the elimination process, the current loser's score lies at least γ below all surviving competitors. We prove that when input perturbations of L∞-radius r are processed by a K-Lipschitz score function, the elimination order and final winner are invariant provided 2Kr < γ. All results are formalized and machine-verified. We provide precise definitions, proof sketches, computational demonstrations, and connections to tropical geometry and adversarial machine learning.

**Keywords**: certified robustness, instant-runoff voting, adversarial perturbation, gap certificate, Lipschitz continuity, sequential elimination, tropical geometry

---

## 1. Introduction

Adversarial robustness—the stability of a classifier's output under bounded perturbations to its input—has emerged as a central concern in trustworthy AI [Goodfellow et al. 2015, Madry et al. 2018]. Most certified robustness results apply to *argmax classifiers*, which select the class with the highest score. However, more complex decision procedures, including sequential elimination (instant-runoff) methods, appear naturally in tropical neural architectures and ensemble methods.

The instant-runoff decision rule operates as follows: given m candidate classes with scores v(1), ..., v(m), the class with the minimum score is eliminated. Scores are recomputed on the reduced candidate set, and the process repeats until one class remains. This procedure generalizes simple argmax classification and arises in architectures where tropical (max-plus) scoring functions produce structured piecewise-linear decision boundaries.

The challenge for robustness certification is the *cascading effect*: a small perturbation that changes the loser in one round reshuffles the entire subsequent elimination sequence. Our approach handles this cascade through a *recursive gap certificate* that ensures stability at every round simultaneously.

### 1.1 Contributions

1. **Gap certificate framework** (Definition 4): A recursive predicate `EliminationGapCertified` that captures the margin condition at every elimination round.

2. **One-round perturbation lemma** (Theorem 1): If a candidate has gap γ and scores are perturbed by at most ε, the residual gap is at least γ − 2ε.

3. **Elimination-order stability** (Theorem 2): Under a gap certificate with parameter γ and perturbation bound ε satisfying 2ε < γ, the complete elimination sequence is preserved.

4. **Winner stability** (Theorem 3): The IRV winner is invariant under the same conditions.

5. **Lipschitz robustness certificate** (Theorem 4): For a K-Lipschitz score function, any input within L∞-radius γ/(2K) yields the same IRV winner.

All results are formalized in @file:Catalog/Bridges/IRVStability.lean.

---

## 2. Preliminaries

### 2.1 Notation

Let m ≥ 1 denote the number of candidate classes, indexed by Fin(m) = {0, 1, ..., m−1}. A *score vector* is a function v : Fin(m) → ℝ. For a subset S ⊆ Fin(m), we write v|_S for the restriction of v to S.

The L∞ norm on score perturbations is ‖v' − v‖_∞ = max_i |v'(i) − v(i)|. We say v' is ε-close to v if |v'(i) − v(i)| ≤ ε for all i.

### 2.2 Pairwise Distinctness

**Definition 1** (PairwiseDistinctOn). Scores v are *pairwise distinct on S* if for all i, j ∈ S with i ≠ j, we have v(i) ≠ v(j). This is a tie-freeness condition that ensures the elimination procedure is deterministic.

```
def PairwiseDistinctOn (S : Finset (Fin m)) (v : Fin m → ℝ) : Prop :=
  ∀ i ∈ S, ∀ j ∈ S, i ≠ j → v i ≠ v j
```

### 2.3 Gap Certificate (One Round)

**Definition 2** (HasGapAtLeast). Candidate i has *gap at least γ in S under v* if i ∈ S and v(i) + γ ≤ v(j) for every j ∈ S with j ≠ i. Equivalently, i is the unique minimizer of v on S with margin γ.

```
def HasGapAtLeast (S : Finset (Fin m)) (v : Fin m → ℝ) (i : Fin m) (γ : ℝ) : Prop :=
  i ∈ S ∧ ∀ j ∈ S, j ≠ i → v i + γ ≤ v j
```

---

## 3. The Instant-Runoff Elimination Procedure

### 3.1 Round Loser

**Definition 3** (roundLoser). For a nonempty finite set S and score function v, the *round loser* is an element of S minimizing v, selected via the existence of a minimizer on a nonempty finite set.

The key property is that when the gap condition holds, the round loser is unique:

**Lemma 1** (roundLoser_eq_of_strict_min). If i ∈ S and v(i) < v(j) for all j ∈ S with j ≠ i, then roundLoser(S, v) = i.

*Proof sketch.* The round loser ℓ = roundLoser(S, v) satisfies v(ℓ) ≤ v(j) for all j ∈ S. If ℓ ≠ i, then v(i) < v(ℓ) by hypothesis, contradicting v(ℓ) ≤ v(i). □

### 3.2 Recursive Elimination

**Definition** (eliminationOrderOn). The elimination order on a nonempty set S is defined recursively:
- If |S| ≤ 1, return the singleton element.
- Otherwise, let i = roundLoser(S, v), and return i followed by eliminationOrderOn(S \ {i}, v).

**Definition** (irvWinnerOn). The IRV winner on S is the last element of the elimination order—equivalently, defined by the same recursion but returning only the final survivor.

**Definition** (irvWinner). The IRV winner on all candidates: irvWinnerOn(Fin(m), v).

### 3.3 Recursive Gap Certificate

**Definition 4** (EliminationGapCertified). The elimination of v on S is *gap-certified with parameter γ* if:
- When |S| ≤ 1: the condition holds trivially.
- When |S| > 1: the round loser i has HasGapAtLeast(S, v, i, γ), AND the elimination on S \ {i} is also gap-certified with parameter γ.

This recursive structure mirrors the elimination process itself and ensures that the margin condition holds at every round.

---

## 4. Main Results

### 4.1 One-Round Perturbation Lemma

**Theorem 1** (gap_preserved_under_perturbation). Let S ⊆ Fin(m), v and v' score functions, i ∈ S with HasGapAtLeast(S, v, i, γ), and |v'(k) − v(k)| ≤ ε for all k. Then for all j ∈ S with j ≠ i:

$$v'(i) + (\gamma - 2\varepsilon) \leq v'(j)$$

*Proof sketch.* From |v'(k) − v(k)| ≤ ε, we have v'(i) ≤ v(i) + ε and v(j) ≤ v'(j) + ε. The gap condition gives v(i) + γ ≤ v(j). Combining:

$$v'(i) + (\gamma - 2\varepsilon) \leq v(i) + \varepsilon + \gamma - 2\varepsilon = v(i) + \gamma - \varepsilon \leq v(j) - \varepsilon \leq v'(j)$$

The bound is tight: it is achieved when v'(i) = v(i) + ε and v'(j) = v(j) − ε. □

**Remark.** The factor of 2 in the gap erosion is fundamental: the perturbation can simultaneously raise the loser's score and lower a competitor's score, attacking the gap from both sides.

### 4.2 Strict Minimizer from Positive Gap

**Lemma 2** (strict_min_of_gap). If i ∈ S, δ > 0, and v(i) + δ ≤ v(j) for all j ∈ S \ {i}, then v(i) < v(j) for all j ∈ S \ {i}.

This converts a non-strict gap inequality into strict separation, which is needed to apply the uniqueness lemma for round losers.

### 4.3 Elimination-Order Stability

**Theorem 2** (eliminationOrderOn_stable). Let v and v' be score functions with |v'(i) − v(i)| ≤ ε for all i. If the elimination of v on S is gap-certified with parameter γ and 2ε < γ, then:

$$\text{eliminationOrderOn}(S, v') = \text{eliminationOrderOn}(S, v)$$

*Proof sketch.* By strong induction on |S|.

**Base case.** |S| ≤ 1: both sides return the singleton element.

**Inductive step.** |S| > 1. Let i = roundLoser(S, v). The gap certificate gives HasGapAtLeast(S, v, i, γ). By Theorem 1, for all j ∈ S \ {i}, v'(i) + (γ − 2ε) ≤ v'(j). Since γ − 2ε > 0 (from 2ε < γ), Lemma 2 gives v'(i) < v'(j) for all j ∈ S \ {i}. By Lemma 1, roundLoser(S, v') = i.

Therefore the first element of both elimination orders is i, and the remaining elements are eliminationOrderOn(S \ {i}, v') and eliminationOrderOn(S \ {i}, v) respectively. The gap certificate's recursive component gives that S \ {i} is also gap-certified, so the induction hypothesis applies. □

### 4.4 Winner Stability

**Theorem 3** (irvWinnerOn_stable). Under the same hypotheses as Theorem 2:

$$\text{irvWinnerOn}(S, v') = \text{irvWinnerOn}(S, v)$$

*Proof sketch.* The same inductive argument shows that the recursion unfolds identically for v and v', since the same candidate is eliminated at each step. The winner is determined by the last surviving candidate, which is the same in both cases. □

**Corollary** (irvWinner_stable). For the full candidate set, irvWinner(v') = irvWinner(v) under the same conditions.

### 4.5 Lipschitz Robustness Certificate

**Theorem 4** (irvWinner_certified_robust). Let s : ℝ^d → ℝ^m be a score function that is K-Lipschitz in the sense that for all z, z' ∈ ℝ^d with |z'(k) − z(k)| ≤ r for all k, we have |s(z')(i) − s(z)(i)| ≤ Kr for all i. Let x ∈ ℝ^d be an input whose elimination is gap-certified with parameter γ. Then for any x' with |x'(k) − x(k)| ≤ r for all k:

$$2Kr < \gamma \implies \text{irvWinner}(s(x')) = \text{irvWinner}(s(x))$$

Equivalently, the *certified robustness radius* is γ/(2K).

*Proof sketch.* The Lipschitz condition ensures |s(x')(i) − s(x)(i)| ≤ Kr for all i. Apply Theorem 3 with ε = Kr. The condition 2ε < γ becomes 2Kr < γ. □

---

## 5. Proof Architecture and Formal Verification Details

The formal development in @file:Catalog/Bridges/IRVStability.lean follows a carefully layered architecture designed for both mathematical clarity and proof-engineering efficiency.

### 5.1 Foundational Layer

The development begins with three core definitions: `PairwiseDistinctOn` (tie-freeness), `HasGapAtLeast` (single-round gap certificate), and `roundLoser` (minimum-score selector). The `roundLoser` is defined via `Classical.choose` applied to the Mathlib lemma `Finset.exists_min_image`, which guarantees the existence of a minimizer on any nonempty finite set with a linear order.

Two key properties of `roundLoser` are established as standalone lemmas:
- `roundLoser_mem`: the loser belongs to the active set
- `roundLoser_le`: the loser's score is at most that of any other active candidate

These are direct consequences of the `choose_spec` for the minimizer existence.

### 5.2 Uniqueness Layer

The lemma `roundLoser_eq_of_strict_min` bridges the gap between the existence-based definition of `roundLoser` and the uniqueness guaranteed by strict separation. The proof proceeds by contradiction: if the round loser were not the strict minimizer i, then i would have strictly lower score, contradicting the minimality of the round loser. This uses `Classical.not_not` and the contrapositive of the minimizer inequality.

### 5.3 Recursive Layer

The recursive definitions (`eliminationOrderOn`, `irvWinnerOn`, `EliminationGapCertified`) all terminate by `S.card`, with the key structural lemmas `erase_nonempty_of_card_gt_one` and `erase_card_lt` ensuring well-foundedness. These auxiliary lemmas handle the bookkeeping of showing that erasing an element from a set with more than one element yields a nonempty set of strictly smaller cardinality.

### 5.4 Perturbation Layer

The perturbation lemma `gap_preserved_under_perturbation` is a pure algebraic calculation resolved by `linarith` from the absolute value decomposition `abs_le.mp`. The proof extracts both directions of the absolute value inequality for coordinates i and j, then combines them with the original gap inequality in a single linear arithmetic step.

### 5.5 Induction Layer

The main stability theorems use strong induction on `S.card`. For `eliminationOrderOn_stable`, the induction is structured through `Nat.strong_induction_on`, with the key insight that the gap certificate's recursive structure provides exactly the induction hypothesis needed: after establishing that the same loser is eliminated in round k, the recursive component of the gap certificate certifies the remaining rounds.

The `irvWinnerOn_stable` proof follows a similar pattern but focuses only on the final output rather than the full elimination sequence. It uses `convert` to align the induction hypothesis with the recursive call structure.

## 6. Computational Aspects

### 6.1 Computing the Gap Certificate

Given a score vector v ∈ ℝ^m, the gap at each elimination round can be computed in O(m) time per round, for O(m²) total across all rounds. At each round with active set S:

1. Find i* = argmin_{i ∈ S} v(i).
2. Find the second minimum: v₂ = min_{j ∈ S, j ≠ i*} v(j).
3. The gap at this round is γ_round = v₂ − v(i*).
4. The overall gap is γ = min over all rounds of γ_round.

### 6.2 Certified Radius Computation

Given a K-Lipschitz score function and an input x:
1. Compute s(x).
2. Run the elimination procedure, recording the gap at each round.
3. Set γ = min-round gap.
4. The certified radius is r* = γ/(2K).

This computation is *exact*—not an approximation or a bound that might be tightened. The factor of 2 in the denominator is tight.

### 6.3 Comparison with Argmax Robustness

For standard argmax classifiers, the certified radius under L∞ perturbation with K-Lipschitz scores is:

$$r^*_{\text{argmax}} = \frac{v(\text{winner}) - v(\text{runner-up})}{2K}$$

For IRV classifiers, the certified radius is:

$$r^*_{\text{IRV}} = \frac{\min_{\text{round}} \gamma_{\text{round}}}{2K}$$

The IRV radius is always at most the argmax radius (since the first-round gap is at most the argmax margin), but it provides robustness for a more expressive classifier.

---

## 7. Connections to Tropical Geometry

The IRV elimination procedure has a natural interpretation in tropical geometry. A *tropical polynomial* in d variables is a function of the form:

$$p(x) = \max_{j \in J} (a_j + \langle w_j, x \rangle)$$

where J is a finite index set, a_j ∈ ℝ are coefficients, and w_j ∈ ℝ^d are weight vectors. When the score function s(x) = (p_1(x), ..., p_m(x)) is a vector of tropical polynomials, the IRV classifier partitions ℝ^d into regions where the elimination order is constant—the *tropical IRV complex*.

The gap certificate γ(x) varies continuously over each region and provides an intrinsic measure of distance to a decision boundary. The Lipschitz constant K of a tropical score function is determined by the weight vectors: K = max_{i,j} ‖w_{i,j}‖₁ in the L∞ → L∞ sense.

This connection suggests that for tropical architectures, the certified robustness radius can be computed in closed form from the network weights and the input's position relative to the tropical hypersurface.

---

## 8. Discussion

### 8.1 Tightness

The factor of 2 in the perturbation bound is tight. Consider m = 2 candidates with scores v(0) = 0, v(1) = γ. The gap is γ. A perturbation that sets v'(0) = ε, v'(1) = γ − ε gives gap γ − 2ε. When ε = γ/2, the gap vanishes and a tie occurs. Any larger perturbation can reverse the elimination order.

### 8.2 Tie-Freeness

The current framework assumes tie-free eliminations (guaranteed by PairwiseDistinctOn or, more practically, by the positive gap condition). This is not restrictive in the certified robustness setting: a positive gap certificate implies ties cannot occur, so the assumption is self-reinforcing.

### 8.3 Deterministic vs. Stochastic Scores

The theory handles deterministic score functions. Extension to stochastic settings (e.g., dropout at inference time, Bayesian neural networks) would require replacing pointwise perturbation bounds with probabilistic ones, likely yielding probabilistic robustness certificates.

### 8.4 Relation to Voting Theory

The IRV elimination procedure studied here is closely related to instant-runoff voting (IRV) in social choice theory, also known as the alternative vote or ranked-choice voting. In that setting, voters rank candidates and the candidate with the fewest first-choice votes is eliminated in each round, with their votes redistributed. Our framework studies a simplified version where scores are fixed (not redistributed), but the structural insight—that gap certificates provide cascading stability—applies equally to the redistributive setting when gaps are measured appropriately.

The connection to voting theory is more than an analogy. The stability of voting rules under perturbation is a classical topic in computational social choice, where it is studied under the rubric of *manipulation resistance* and *noise stability*. Our gap certificate framework provides a new quantitative tool for this analysis, with the advantage of yielding exact (not asymptotic) stability thresholds.

---

## 9. Future Work

Several directions merit investigation:

1. **Weighted elimination schemes.** Different rounds could use different scoring functions or weighting schemes, generalizing the uniform-gap framework.

2. **Adaptive gap certificates.** Rather than requiring a uniform gap γ at every round, allow round-dependent gaps γ_1, ..., γ_{m-1} with round-specific perturbation analysis.

3. **Tighter bounds for structured score functions.** For tropical polynomials and ReLU networks, the piecewise-linear structure could yield local Lipschitz constants much smaller than the global K, improving certified radii.

4. **Connection to computational social choice.** The stability of IRV under noise connects to the extensive literature on the robustness of voting rules [Xia 2020]. Our gap certificate framework could formalize notions of "manipulation resistance" in voting theory.

5. **Model-theoretic bridges.** The algebraic structure underlying our gap certificates connects to broader questions about the definability of robust classifiers in first-order theories of ordered fields, bridging to model theory and the Ax-Kochen framework.

---

## 10. Formal Verification

All definitions and theorems in this paper have been formalized and verified in Lean 4 with the Mathlib library. The complete formalization is available in @file:Catalog/Bridges/IRVStability.lean. The formalization consists of approximately 200 lines of definitions and proofs organized into seven parts:

| Component | Lines | Description |
|-----------|-------|-------------|
| Core definitions | §1 | PairwiseDistinctOn, HasGapAtLeast, roundLoser |
| Minimizer properties | §2 | roundLoser_mem, roundLoser_le, roundLoser_eq_of_strict_min |
| Recursive elimination | §3 | eliminationOrderOn, irvWinnerOn, irvWinner, EliminationGapCertified |
| Perturbation lemma | §4 | gap_preserved_under_perturbation, strict_min_of_gap |
| Order stability | §5 | eliminationOrderOn_stable |
| Winner stability | §6 | irvWinnerOn_stable, irvWinner_stable |
| Lipschitz robustness | §7 | irvWinner_certified_robust |

---

## 11. Conclusion

We have presented a complete, formally verified theory of certified adversarial robustness for instant-runoff classifiers. The gap certificate framework provides a clean recursive structure that mirrors the elimination process itself, and the resulting robustness certificates are tight—the factor of 2 in the gap erosion bound is optimal.

The key mathematical contributions are:
1. The identification of the gap certificate as the right recursive invariant for IRV stability.
2. The tight 2ε gap erosion bound, which is achieved by worst-case perturbations.
3. The clean composition with Lipschitz score functions, yielding practical certified radii.
4. The full formal verification of all results, providing the highest level of mathematical certainty.

The framework is general enough to apply to any sequential elimination procedure based on score minimization, and the tropical geometry connection opens natural avenues for architecture-specific optimizations.

## References

- Goodfellow, I.J., Shlens, J., and Szegedy, C. (2015). Explaining and harnessing adversarial examples. *ICLR*.
- Madry, A., Makelov, A., Schmidt, L., Tsipras, D., and Vladu, A. (2018). Towards deep learning models resistant to adversarial attacks. *ICLR*.
- Cohen, J., Rosenfeld, E., and Kolter, Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
- Xia, L. (2020). The smoothed possibility of social choice. *NeurIPS*.
- Zhang, H., Weng, T.-W., Chen, P.-Y., Hsieh, C.-J., and Daniel, L. (2018). Efficient neural network robustness certification with general activation functions. *NeurIPS*.
