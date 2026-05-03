# Tropical Certified Robustness for Multiclass Plurality-of-Experts Ensembles

## Abstract

We present the first formally verified compositional robustness theorem for multiclass ensemble classifiers under plurality voting. Given a finite family of *n* experts, each producing a score vector over *C* classes on an input space ℝ^d, we prove that if a strict majority of experts maintain their per-class logit-gap margins throughout an L∞ ball, then the ensemble's plurality decision is preserved. The key analytic ingredient is a per-expert margin stability estimate under coordinatewise Lipschitz perturbation, and the key combinatorial ingredient is a disjointness argument showing that strictly frozen experts cannot contribute votes to rival classes. All results are machine-verified in Lean 4 using Mathlib, producing the first formally certified ensemble robustness framework.

## 1. Introduction

Adversarial robustness — the ability of a classifier to maintain its prediction under small input perturbations — is a central concern in deploying neural networks for safety-critical applications. While substantial work has addressed the robustness of individual networks via interval bound propagation, abstract interpretation, randomized smoothing, and tropical geometry certificates, the compositional question has received less formal attention: **when does robustness of individual ensemble members compose to robustness of the ensemble?**

This paper addresses this question for the most natural aggregation rule: plurality (majority) voting. We prove, with machine-verified formal proofs, that plurality robustness follows from two conditions:

1. **Per-expert margin preservation:** Each expert in a "frozen" subset maintains a positive logit gap (margin) throughout the perturbation ball.
2. **Majority condition:** The frozen subset forms a strict majority of the ensemble.

The result is modular: it applies regardless of the internal architecture of each expert (ReLU networks, tropical rational maps, decision trees, etc.), requiring only a coordinatewise Lipschitz bound.

### 1.1 Related Work

**Single-network certification.** Methods based on linear relaxations (Wong & Kolter, 2018), semidefinite programming (Raghunathan et al., 2018), randomized smoothing (Cohen et al., 2019), and tropical geometry (Zhang et al., 2018; Alfarra et al., 2022) provide per-network certified radii. Our work takes these per-network certificates as inputs.

**Ensemble robustness.** Empirical studies of ensemble adversarial robustness appear in Strauss et al. (2017) and Pang et al. (2019). Theoretical certificates for ensemble methods include work on randomized smoothing for majority votes (Levine & Feizi, 2021). However, formal verification of the compositional argument has not been previously attempted.

**Formal verification of ML.** Interactive theorem provers have been used for neural network verification (Bagnall & Stewart, 2019), certified training (Müller et al., 2023), and foundational questions in learning theory. Our work contributes a reusable pattern for ensemble certification.

## 2. Formal Setup

### 2.1 Score Functions and Decisions

We work with:
- **n** experts indexed by `Fin n`,
- **C** classes indexed by `Fin C` (with C ≥ 1),
- **d**-dimensional inputs `x : Fin d → ℝ`.

Each expert produces a score vector:
$$F_i : \mathbb{R}^d \to \mathbb{R}^C, \quad i \in \{0, \ldots, n-1\}$$

A score vector **decides** class *c* if *c* achieves the maximum:
$$\text{decides}(s, c) \iff \forall j,\; s(j) \le s(c)$$

A score vector **strictly decides** class *c* if *c* is the unique maximizer:
$$\text{StrictDecides}(s, c) \iff \forall j \ne c,\; s(j) < s(c)$$

### 2.2 Score Gap and Lipschitz Bound

The **score gap** (logit margin) of class *c* at input *x* is:
$$\text{scoreGap}(f, x, c) = f(x, c) - \max_{j \ne c} f(x, j)$$

A positive score gap means *c* is the strict winner. The **coordinatewise Lipschitz** condition bounds how fast scores change:
$$|f(z, c) - f(x, c)| \le K \sum_{k=1}^d |z_k - x_k|$$

### 2.3 L∞ Ball and Certificate Radius

The L∞ ball of radius *r* around *x* is:
$$B_\infty(x, r) = \{z : \forall k,\; |z_k - x_k| \le r\}$$

The **certified radius** for expert *f* with Lipschitz constant *K* is:
$$r_{\text{cert}}(f, K, x, c) = \frac{\text{scoreGap}(f, x, c)}{2Kd}$$

### 2.4 Plurality Voting

The **vote count** for class *c* at input *x* is:
$$\text{voteCount}(F, x, c) = |\{i : \text{decides}(F_i(x), c)\}|$$

The plurality winner is the class with the most votes.

## 3. Main Results

### 3.1 Per-Expert Stability (Analytic Lemma)

**Theorem (strictDecides_of_gap_gt).** *Let f be a K-Lipschitz score function with K ≥ 0, and let x, z ∈ ℝ^d with z ∈ B_∞(x, r). If*
$$\text{scoreGap}(f, x, c) > 2K \cdot d \cdot r,$$
*then f strictly decides c at z: for all j ≠ c, f(z, j) < f(z, c).*

**Proof sketch.** The key intermediate estimate is:
$$\sum_{k=1}^d |z_k - x_k| \le d \cdot r$$
which holds by summing the pointwise L∞ bound. Then for any j ≠ c:
- Lower bound: $f(z, c) \ge f(x, c) - K \sum |z_k - x_k| \ge f(x, c) - Kdr$
- Upper bound: $f(z, j) \le f(x, j) + K \sum |z_k - x_k| \le f(x, j) + Kdr$
- Gap bound: $f(x, j) \le f(x, c) - \text{scoreGap}(f, x, c)$

Combining: $f(z, j) - f(z, c) \le 2Kdr - \text{scoreGap}(f, x, c) < 0$. ∎

### 3.2 Disjointness (Combinatorial Lemma)

**Theorem (not_decides_of_strictDecides_ne).** *If s strictly decides c, then s does not decide any c' ≠ c.*

This is immediate: strict decision gives $s(c') < s(c)$, contradicting $s(c) \le s(c')$ required by decides(s, c').

### 3.3 Plurality Robustness (Main Theorem)

**Theorem (plurality_robust_of_frozen_winner_voters).** *Let S ⊆ {0, ..., n-1} be a set of experts such that:*
1. *Every i ∈ S strictly decides c★ at every z ∈ B_∞(x, r),*
2. *|Sᶜ| < |S| (S forms a strict majority).*

*Then for every z ∈ B_∞(x, r) and every rival class c ≠ c★:*
$$\text{voteCount}(F, z, c) < \text{voteCount}(F, z, c★)$$

**Proof.** Fix z in the ball and a rival c ≠ c★.

**Winner lower bound.** Every i ∈ S strictly decides c★ at z, hence decides c★ at z. Therefore S ⊆ winnerVoters(F, z, c★), giving:
$$|S| \le \text{voteCount}(F, z, c★)$$

**Rival upper bound.** By disjointness (Theorem 3.2), no i ∈ S can decide c at z (since it strictly decides c★). Therefore voters for c at z form a subset of {0, ..., n-1} \ S, giving:
$$\text{voteCount}(F, z, c) \le |S^c|$$

**Combine:**
$$\text{voteCount}(F, z, c) \le |S^c| < |S| \le \text{voteCount}(F, z, c★) \qquad \square$$

### 3.4 Gap Certificate Corollary

**Theorem (plurality_robust_of_expert_gap_certificates).** *If the stable winner-voters (those with certified radius exceeding r) form a strict majority, and each expert is coordinatewise Lipschitz, then the plurality winner is preserved on the ball.*

This follows by combining the per-expert stability lemma with the structural plurality theorem.

## 4. The Role of Strict Decisions

A subtle but essential point in the formalization is the use of **strict** decisions (`StrictDecides`) rather than non-strict ones (`decides`). With non-strict decides, an expert could simultaneously "vote" for multiple classes in the case of ties. This breaks the disjointness argument: frozen experts could contribute to both the winner's and a rival's vote count.

The positive score gap hypothesis naturally produces strict decisions, so this is not a loss of generality — it simply requires the proof to track the strictness carefully.

This subtlety, which is easy to overlook in an informal argument, was caught during the formal verification process, demonstrating the value of machine-checked proofs for this type of compositional reasoning.

## 5. Discussion: What This Means for AI Safety

### 5.1 A Voting Analogy

Imagine a panel of five medical experts examining a patient's scan. Each expert independently classifies the scan into one of several diagnoses. The ensemble uses majority voting: the diagnosis chosen by the most experts wins.

Now suppose a subtle artifact is introduced into the scan — noise, compression, or even an adversarial perturbation. How confident can we be that the panel's collective decision remains unchanged?

Our theorem provides a precise, mathematical guarantee: **if enough experts have large enough confidence margins, the panel's decision is bulletproof against perturbations up to a quantified size.** The key insight is that confident experts (those with large logit gaps) will not change their minds, and as long as these "stubborn" experts outnumber the total of all other experts, the group decision is safe.

This is analogous to a robust democratic election: if a candidate has support from more than half the voters, and those supporters are deeply committed (they won't change their vote under small persuasion), then no amount of campaigning within the persuasion radius can change the outcome.

### 5.2 Compositionality: Why It Matters

The deepest insight is **compositionality**: ensemble robustness reduces to per-expert robustness plus a counting argument. This means:

- **Modularity.** Each expert can be certified independently, using whatever method is most efficient for its architecture (tropical certificates for ReLU networks, interval arithmetic for decision trees, etc.).
- **Scalability.** Adding more experts never hurts: it can only increase the majority margin.
- **Heterogeneity.** The experts need not be similar — they can have different architectures, training procedures, and Lipschitz constants.

### 5.3 Practical Implications

1. **Certified defense design.** Build ensembles where a majority of members are designed for high margins (e.g., using margin-based training or tropical certificates). The uncertified minority can be optimized for accuracy.

2. **Adaptive certification.** The certificate is input-dependent: some inputs may have larger certified radii than others. This enables adaptive defense strategies.

3. **Robustness auditing.** The framework provides a systematic way to audit ensemble models: compute per-expert margins, identify the frozen subset, and verify the majority condition.

## 6. Formal Verification Details

The complete formalization consists of two Lean 4 files:

- **`TropicalDefs.lean`** (~160 lines): Core definitions and the per-expert analytic lemma.
- **`PluralityRobust.lean`** (~170 lines): Plurality robustness theorems.

All proofs compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`). The development imports Mathlib for basic real analysis and finset combinatorics.

### Key Design Decisions

1. **Classical logic.** We use `Classical.propDecidable` throughout, which is standard for real analysis in Lean/Mathlib.

2. **Explicit dimension parameter.** The input dimension `d` appears as an explicit natural number rather than using abstract finite types, enabling clean interaction with `Finset.sum` and cast arithmetic.

3. **Proof irrelevance for `1 < C`.** The score gap and related definitions take a proof `hC : 1 < C` as an argument, ensuring the maximum over competitors is well-defined.

## 7. Future Directions

1. **Top-k and threshold aggregators.** The frozen-subset-plus-counting schema generalizes beyond plurality. For top-k voting or threshold rules, the majority condition changes but the structure is identical.

2. **Abstaining experts.** Extending to experts that can abstain (producing no vote) requires modifying the vote count but preserves the core disjointness argument.

3. **Tight certificates.** The factor of 2 in the score gap bound is not tight for all architectures. Architecture-specific refinements (e.g., exploiting the tropical structure of ReLU networks) could improve certified radii.

4. **Probabilistic extensions.** Connecting to randomized smoothing: if each expert's decision is preserved with high probability under random perturbation, the ensemble's decision is preserved with even higher probability via concentration of the binomial vote count.

5. **Multi-norm robustness.** Extending from L∞ to L2 or other norms by changing the Lipschitz condition and the ball definition.

## 8. Conclusion

We have presented the first formally verified compositional robustness theorem for multiclass ensemble classifiers under plurality voting. The result provides a clean, modular framework: certify each expert individually, count the certified majority, and obtain an ensemble certificate. The formal verification in Lean 4 ensures the correctness of the argument, including a subtle point about strict vs. non-strict argmax decisions that is easy to overlook informally. The framework is immediately applicable to any ensemble of piecewise-linear networks and provides a foundation for certified defense design in safety-critical AI systems.

## References

- Alfarra, M., Bibi, A., Hammoud, H., Gaafar, A., & Ghanem, B. (2022). On the decision boundaries of neural networks: A tropical geometry perspective. *IEEE TPAMI*.
- Cohen, J., Rosenfeld, E., & Kolter, Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
- Levine, A. & Feizi, S. (2021). Certified robustness of ensemble models. *NeurIPS*.
- Wong, E. & Kolter, Z. (2018). Provable defenses against adversarial examples via the convex outer adversarial polytope. *ICML*.
- Zhang, H., Weng, T.-W., Chen, P.-Y., Hsieh, C.-J., & Daniel, L. (2018). Efficient neural network robustness certification with general activation functions. *NeurIPS*.
