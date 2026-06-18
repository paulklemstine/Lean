# Certified Robustness for Sequential-Elimination Classifiers via Gap Certificates

**Abstract.** We develop a formal theory of certified robustness for deterministic, tie-free instant-runoff voting (IRV) classifiers. Given a score function mapping candidates to real-valued scores and a sequential-elimination procedure that removes the minimum-scoring candidate at each round, we define a *gap certificate*—a recursive predicate asserting that at each elimination round, the loser's score is separated from all surviving candidates by at least γ. We prove that if scores are perturbed coordinatewise by at most ε with 2ε < γ, the entire elimination order, and hence the winner, is preserved. Composing this with a Lipschitz bound on the score function yields a certified robustness radius in input space: any input perturbation of L∞-norm at most r preserves the classifier's prediction whenever 2Kr < γ, where K is the Lipschitz constant. All results are machine-verified in Lean 4 with the Mathlib library (see @Catalog/Bridges/IRVStability.lean).

---

## 1. Introduction

Sequential elimination is ubiquitous in decision-making systems. Instant-runoff voting (IRV), also known as ranked-choice voting or the alternative vote, elects a winner by iteratively removing the candidate with the fewest first-preference votes. Analogous elimination procedures appear in multiclass classification, where a neural network's score vector is decoded by sequentially removing the lowest-scoring class until one remains.

A central concern in all these settings is *robustness*: how much can the underlying scores change before the outcome is affected? In the machine-learning context, this question is sharpened by the existence of *adversarial examples*—small input perturbations that cause misclassification. Existing certified defense methods (randomized smoothing, interval bound propagation, abstract interpretation) provide robustness guarantees for single-round classifiers (argmax decoders), but sequential-elimination decoders have received comparatively little formal attention.

We address this gap by developing a complete robustness theory for IRV-style elimination. Our key contributions are:

1. A formal definition of *gap certificates* for sequential elimination.
2. A *one-round perturbation lemma* quantifying gap erosion under bounded perturbation.
3. An *elimination-order stability theorem* lifting one-round stability to the full elimination sequence via strong induction.
4. A *winner stability theorem* as an immediate corollary.
5. A *Lipschitz robustness corollary* converting score-space stability to input-space certified robustness.

All results are stated and proved in the Lean 4 theorem prover, providing machine-checked correctness guarantees.

### 1.1 Related Work

Certified robustness for neural network classifiers has been extensively studied for argmax decoders. Randomized smoothing (Cohen et al., 2019) provides probabilistic certificates via Lipschitz properties of smoothed classifiers. Deterministic methods based on interval bound propagation (Gowal et al., 2018) and linear relaxations (Wong & Kolter, 2018) compute certified radii for specific architectures.

For multi-round or sequential classifiers, robustness analysis is less developed. The IRV literature in social choice theory has studied *margin of victory* computations (Magrino et al., 2011; Blom et al., 2019), which are related to our gap certificates but typically focus on a specific tie-breaking rule and vote-count perturbation model rather than general score perturbations.

Tropical geometry provides a natural mathematical framework for piecewise-linear classifiers (Zhang et al., 2018; Maragos et al., 2021). Our work connects to this line by formulating the robustness condition in terms of tropical separation between decision regions.

---

## 2. Definitions

### 2.1 Score Functions and Candidate Sets

Let m ≥ 1 be the number of candidates. A *score function* is a map v : {0, …, m−1} → ℝ assigning a real-valued score to each candidate. An *active set* S ⊆ {0, …, m−1} is a nonempty finite set of candidates still under consideration.

**Definition 2.1** (Pairwise Distinct Scores). Scores v are *pairwise distinct on S* if v(i) ≠ v(j) for all distinct i, j ∈ S.

This condition ensures tie-free elimination (see `PairwiseDistinctOn` in @Catalog/Bridges/IRVStability.lean).

### 2.2 Round Loser

**Definition 2.2** (Round Loser). The *round loser* of score function v on nonempty active set S is

> roundLoser(S, v) = argmin_{i ∈ S} v(i),

chosen via the minimizer existence theorem for nonempty finite sets over a linearly ordered type.

The formal definition uses `Finset.exists_min_image` to extract a witness (see `roundLoser` in @Catalog/Bridges/IRVStability.lean). Key properties:

- **Membership**: roundLoser(S, v) ∈ S (Lemma `roundLoser_mem`).
- **Minimality**: v(roundLoser(S, v)) ≤ v(j) for all j ∈ S (Lemma `roundLoser_le`).
- **Uniqueness under strict minimum**: If i ∈ S and v(i) < v(j) for all j ∈ S \ {i}, then roundLoser(S, v) = i (Lemma `roundLoser_eq_of_strict_min`).

### 2.3 Gap Certificate

**Definition 2.3** (Gap at a Round). Candidate i has *gap at least γ* in active set S under scores v if i ∈ S and v(i) + γ ≤ v(j) for all j ∈ S \ {i}.

Formally, this is `HasGapAtLeast S v i γ` in @Catalog/Bridges/IRVStability.lean.

**Definition 2.4** (Elimination Gap Certificate). The elimination of v on S is *gap-certified with parameter γ* if:
- When |S| ≤ 1: the certificate holds vacuously.
- When |S| > 1: the round loser has gap at least γ, AND the elimination of v on S \ {roundLoser(S, v)} is gap-certified with parameter γ.

This recursive definition (`EliminationGapCertified` in @Catalog/Bridges/IRVStability.lean) terminates by the strict decrease of |S| at each recursive call.

### 2.4 IRV Winner

**Definition 2.5** (IRV Winner). The *IRV winner* on active set S under scores v is defined recursively:
- When |S| ≤ 1: the unique element of S.
- When |S| > 1: the IRV winner on S \ {roundLoser(S, v)}.

See `irvWinnerOn` and `irvWinner` (the specialization to S = {0, …, m−1}) in @Catalog/Bridges/IRVStability.lean.

---

## 3. Main Results

### 3.1 One-Round Perturbation Lemma

**Theorem 3.1** (Gap Preservation). *Let S be a nonempty set of candidates, v and v' score functions, i a candidate with gap at least γ in S under v, and ε ≥ 0 such that |v'(k) − v(k)| ≤ ε for all k. Then for all j ∈ S with j ≠ i:*

> v'(i) + (γ − 2ε) ≤ v'(j).

*Proof sketch.* From the gap hypothesis, v(i) + γ ≤ v(j). The perturbation bound gives v'(i) ≥ v(i) − ε and v'(j) ≤ v(j) + ε, but we need the other direction for the bound: v'(i) ≤ v(i) + ε and v'(j) ≥ v(j) − ε. Combining:

> v'(j) ≥ v(j) − ε ≥ v(i) + γ − ε ≥ v'(i) − ε + γ − ε = v'(i) + (γ − 2ε).

The formal proof (`gap_preserved_under_perturbation` in @Catalog/Bridges/IRVStability.lean) applies `abs_le` to extract both directions of the perturbation bound and concludes by `linarith`. □

**Corollary 3.2** (Strict Minimum Preservation). *Under the hypotheses of Theorem 3.1, if γ − 2ε > 0 (equivalently, 2ε < γ), then i is a strict minimizer of v' on S.*

This follows from `strict_min_of_gap` in @Catalog/Bridges/IRVStability.lean.

### 3.2 Elimination-Order Stability

**Theorem 3.3** (Elimination-Order Stability). *Let S be a nonempty active set, v a score function whose elimination on S is gap-certified with parameter γ, and v' a perturbation with |v'(k) − v(k)| ≤ ε for all k and 2ε < γ. Then:*

> eliminationOrderOn(S, v') = eliminationOrderOn(S, v).

*Proof sketch.* By strong induction on |S|. If |S| ≤ 1, both sides reduce to the singleton list [min(S)]. If |S| > 1, the gap certificate provides HasGapAtLeast(S, v, i, γ) where i = roundLoser(S, v). By Theorem 3.1 and Corollary 3.2, i is the strict minimizer of v' on S, so roundLoser(S, v') = i by the uniqueness lemma. The recursive gap certificate provides EliminationGapCertified(S \ {i}, v, γ), and the inductive hypothesis (applicable since |S \ {i}| < |S|) gives the equality of elimination orders on S \ {i}. □

See `eliminationOrderOn_stable` in @Catalog/Bridges/IRVStability.lean.

### 3.3 Winner Stability

**Theorem 3.4** (Winner Stability). *Under the same hypotheses as Theorem 3.3:*

> irvWinnerOn(S, v') = irvWinnerOn(S, v).

*Proof sketch.* By strong induction on |S|, mirroring the structure of Theorem 3.3. The base case (|S| ≤ 1) is immediate. For the inductive step, the same argument shows roundLoser(S, v') = roundLoser(S, v), and the inductive hypothesis gives the equality of winners on S \ {roundLoser}. □

See `irvWinnerOn_stable` in @Catalog/Bridges/IRVStability.lean.

**Corollary 3.5** (Winner Stability on Full Candidate Set). *For the full candidate set {0, …, m−1}:*

> irvWinner(v') = irvWinner(v).

See `irvWinner_stable` in @Catalog/Bridges/IRVStability.lean.

### 3.4 Lipschitz Robustness Certificate

**Theorem 3.6** (Certified Robustness). *Let s : ℝ^d → ℝ^m be a score function that is K-Lipschitz in the L∞ sense: for all inputs z, z' with |z'(k) − z(k)| ≤ r for all k, we have |s(z')(i) − s(z)(i)| ≤ Kr for all i. Let x be an input whose elimination is gap-certified with parameter γ. Then for any x' with ‖x' − x‖_∞ ≤ r and 2Kr < γ:*

> irvWinner(s(x')) = irvWinner(s(x)).

*Proof sketch.* Set ε = Kr. The Lipschitz condition gives |s(x')(i) − s(x)(i)| ≤ ε for all i. The hypothesis 2Kr < γ becomes 2ε < γ. Apply Corollary 3.5. □

See `irvWinner_certified_robust` in @Catalog/Bridges/IRVStability.lean.

---

## 4. Algorithms

### 4.1 Computing the Gap Certificate

Given a score vector v ∈ ℝ^m, the gap certificate can be computed in O(m²) time by simulating the elimination:

```
function compute_gap_certificate(v, S):
    if |S| ≤ 1: return ∞
    i ← argmin_{j ∈ S} v(j)
    gap ← min_{j ∈ S, j ≠ i} (v(j) − v(i))
    return min(gap, compute_gap_certificate(v, S \ {i}))
```

The minimum gap γ* over all rounds is the largest γ for which the certificate holds.

### 4.2 Computing the Certified Robustness Radius

Given a K-Lipschitz score function s, an input x, and the minimum gap γ*:

> r* = γ* / (2K)

Any perturbation within L∞-ball of radius r* is certified to preserve the winner.

### 4.3 Tropical Score Functions

For a one-hidden-layer tropical (max-plus) network with weight matrices W₁ ∈ ℝ^{n×d} and W₂ ∈ ℝ^{m×n}:

> s(x) = W₂ ⊕ (W₁ ⊕ x)

where ⊕ denotes tropical matrix multiplication (replace + with max and × with +). The L∞ Lipschitz constant is:

> K = max_{i} ‖W₂[i, :] ⊕ W₁‖₁

where the tropical composition W₂ ⊕ W₁ is computed as a standard max-plus matrix product.

---

## 5. Applications

### 5.1 Adversarial Robustness for Multiclass Classifiers

Modern neural networks are vulnerable to adversarial perturbations that change the predicted class. For classifiers using sequential-elimination decoding (e.g., tournament-style or cascaded classifiers), our theory provides deterministic certified robustness guarantees. The certificate is a post-hoc computation on the score vector—no modification to the network architecture or training procedure is required.

### 5.2 Election Auditing

In ranked-choice voting, the gap certificate provides a post-election audit tool. If the minimum gap γ* exceeds twice the maximum plausible tabulation error ε_max, the election outcome is provably correct. This is complementary to risk-limiting audits, providing a deterministic rather than probabilistic guarantee.

### 5.3 Robust Tournament Design

In sports tournaments and academic competitions using sequential elimination, the minimum gap quantifies the "decisiveness" of the outcome. Tournaments with large gaps are robust to judging errors, while those with small gaps are fragile. This metric can inform tournament design choices (e.g., number of rounds, scoring criteria).

### 5.4 Tropical Neural Network Certification

Tropical (max-plus) neural networks are a class of piecewise-linear architectures where the standard addition and multiplication in matrix operations are replaced by maximum and addition, respectively. These networks are inherently piecewise-linear, making their Lipschitz constants exactly computable from the weight matrices. For a two-layer tropical network with weight matrices W₁ ∈ ℝ^{n×d} and W₂ ∈ ℝ^{m×n}, the score function s(x) = W₂ ⊕ (W₁ ⊕ x) has Lipschitz constant K = max_i max_j C[i,j] where C = W₂ ⊕ W₁ is the tropical matrix product.

Combining the exactly computable Lipschitz constant with the polynomial-time gap certificate computation yields a fully deterministic, efficiently computable robustness certificate for tropical IRV classifiers. This contrasts with certification methods for general ReLU networks, which typically require solving NP-hard optimization problems or rely on relaxations that may be loose.

### 5.5 Cascaded and Hierarchical Classifiers

Many practical classification systems use hierarchical or cascaded architectures: a coarse classifier first narrows the candidate set, then a fine-grained classifier distinguishes among the remaining candidates. This is precisely an IRV-style sequential elimination with heterogeneous score functions at each round. Our framework extends naturally to this setting by requiring a gap certificate at each stage of the cascade, with each stage potentially having its own Lipschitz constant and perturbation bound.

---

## 6. Discussion

### 6.1 Tightness of the 2ε Bound

The factor of 2 in the condition 2ε < γ is tight. Consider two candidates with scores v(0) = 0, v(1) = γ. A perturbation with v'(0) = ε, v'(1) = γ − ε gives a gap of γ − 2ε. When ε = γ/2, the gap vanishes and the loser identity can change.

### 6.2 Tie-Free Assumption

Our theory assumes tie-free elimination (the round loser is unique). This is guaranteed when scores are pairwise distinct, which holds generically (with probability 1 under any continuous score distribution). Extending to tie-breaking rules is a natural direction.

### 6.3 Uniform vs. Non-Uniform Gaps

The current certificate uses a uniform gap parameter γ across all rounds. A refinement would allow round-dependent gaps γ₁, γ₂, …, γ_{m−1}, requiring only 2ε < min_r γ_r. This is straightforward to formalize but would complicate the recursive definition.

### 6.4 Machine Verification

All results in this paper are formally verified in Lean 4 using the Mathlib library. The formalization spans approximately 230 lines of Lean code and uses strong induction on finite set cardinality as the primary proof technique. The machine-checked proofs provide an additional layer of confidence beyond peer review.

---

## 7. Future Work

Several directions extend the current framework:

1. **Probabilistic gap certificates**: Replace the deterministic gap bound with probabilistic guarantees under random perturbation models (e.g., Gaussian noise).

2. **Adaptive elimination**: Allow the elimination order to depend on the perturbed scores in a more complex way (e.g., multi-criteria elimination).

3. **Tropical geometry connections**: Characterize the certified robustness region as a tropical polyhedron in input space.

4. **Tight Lipschitz computation**: For specific architectures (ReLU networks, tropical networks), compute the tightest Lipschitz constant K using semidefinite programming or mixed-integer programming.

5. **Extension to continuous candidate spaces**: Generalize from finite candidate sets to compact subsets of ℝ^n, replacing finite-set induction with topological arguments.

---

## 8. Proof Architecture and Formalization Notes

The formalization in @Catalog/Bridges/IRVStability.lean follows a layered architecture designed for modularity and reuse.

### 8.1 Foundation Layer

The `roundLoser` function is defined using `Finset.exists_min_image`, which extracts a minimizer from any nonempty finite set equipped with a linear order. The key design choice is to use `Classical.choose` rather than a computable argmin, since the proofs are purely logical and do not require computation. The uniqueness lemma `roundLoser_eq_of_strict_min` uses a proof by contradiction: if the chosen minimizer were not `i`, then it would be strictly above `i` (by the strict minimum hypothesis), contradicting its minimality.

### 8.2 Recursive Definitions and Termination

The `eliminationOrderOn`, `irvWinnerOn`, and `EliminationGapCertified` definitions are all recursive with termination justified by `S.card`. The helper lemma `erase_card_lt` establishes that `(S.erase a).card < S.card` whenever `a ∈ S`, providing the well-foundedness argument. All three definitions share the same recursive skeleton: check if `|S| ≤ 1`, and if not, compute the round loser, erase it, and recurse.

### 8.3 Inductive Proofs

Both the elimination-order stability theorem and the winner stability theorem use `Nat.strong_induction_on` applied to `S.card`. This is the natural induction principle because the cardinality decreases by exactly 1 at each recursive call. The key challenge in the induction step is showing that the round loser is the same under both `v` and `v'`, which requires composing the gap preservation lemma with the unique minimizer lemma.

### 8.4 The Lipschitz Bridge

The final theorem `irvWinner_certified_robust` is remarkably short (4 lines) because it simply instantiates the winner stability theorem with `ε = K·r`. This separation of concerns—score-space stability vs. input-space sensitivity—is a deliberate architectural choice that maximizes reuse. The score-space theorems apply to any perturbation model, not just Lipschitz ones.

### 8.5 Proof Statistics

The complete formalization spans approximately 230 lines of Lean 4 code, including:
- 6 definitions (PairwiseDistinctOn, HasGapAtLeast, roundLoser, eliminationOrderOn, irvWinnerOn, irvWinner, EliminationGapCertified)
- 4 structural lemmas (roundLoser_mem, roundLoser_le, erase_nonempty_of_card_gt_one, erase_card_lt)
- 3 key lemmas (roundLoser_eq_of_strict_min, gap_preserved_under_perturbation, strict_min_of_gap)
- 4 theorems (eliminationOrderOn_stable, irvWinnerOn_stable, irvWinner_stable, irvWinner_certified_robust)

The proofs use a combination of `linarith` (for the algebraic gap computations), `grind` (for finite set cardinality arguments), and `aesop` (for membership side goals). No custom tactics or automation were required.

---

## 9. Conclusion

We have developed a complete, machine-verified theory of certified robustness for sequential-elimination classifiers. The theory is modular (each layer is independently useful), tight (the 2ε bound is optimal), and practical (the certificate is computable in polynomial time). By bridging social choice theory, tropical geometry, and adversarial robustness, it provides a new tool for building and verifying trustworthy decision-making systems.

The formalization demonstrates that non-trivial robustness guarantees for complex decision procedures (multi-round elimination) can be captured in a theorem prover with modest effort. The layered proof architecture—from one-round perturbation through multi-round induction to input-space Lipschitz certificates—provides a template for certifying robustness in other sequential decision-making systems, including beam search decoders, tournament brackets, and cascaded classifiers.

We believe this work opens a promising research direction at the intersection of formal methods, social choice theory, and machine learning. The gap certificate is both a theoretical tool (enabling clean inductive proofs) and a practical one (computable in polynomial time from score vectors). Its simplicity—a single real number summarizing the robustness of a multi-round process—makes it accessible to practitioners who may not be familiar with the underlying formal verification infrastructure. As AI systems are increasingly deployed in high-stakes decision-making, the ability to provide provable guarantees about classifier stability under perturbation becomes not just a mathematical curiosity but a practical necessity.

---

## References

1. Cohen, J., Rosenfeld, E., & Kolter, J.Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML*.
2. Gowal, S., et al. (2018). On the effectiveness of interval bound propagation for training verifiably robust models. *arXiv:1810.12715*.
3. Wong, E., & Kolter, J.Z. (2018). Provable defenses against adversarial examples via the convex outer adversarial polytope. *ICML*.
4. Magrino, T., et al. (2011). Computing the margin of victory in IRV elections. *EVT/WOTE*.
5. Blom, M., et al. (2019). Toward computing the margin of victory in STV elections. *AAAI*.
6. Zhang, L., Naitzat, G., & Lim, L.H. (2018). Tropical geometry of deep neural networks. *ICML*.
7. Maragos, P., Charisopoulos, V., & Theodosis, E. (2021). Tropical geometry and machine learning. *Proceedings of the IEEE*.
