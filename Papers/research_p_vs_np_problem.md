# Certified Robustness for Sequential-Elimination Classifiers via Tropical Gap Certificates

## Abstract

We develop a rigorous mathematical framework for certifying the robustness of sequential-elimination (instant-runoff voting) classifiers under bounded input perturbations. The central construction is the **gap certificate** — a recursive predicate asserting that at each round of elimination, the current loser's score is separated from all surviving candidates by a margin γ. We prove that when a score perturbation is bounded coordinatewise by ε and 2ε < γ, the entire elimination order — and hence the final winner — is preserved identically. Composing this with a Lipschitz bound on the score map yields explicit, computable robustness radii in input space. All results are formalized and machine-verified. The framework applies to any multiclass classifier whose decision rule can be expressed as iterated minimum-selection, including piecewise-linear (ReLU) neural networks with tropical score maps.

**Keywords**: certified robustness, instant-runoff voting, sequential elimination, gap certificate, Lipschitz stability, tropical geometry, adversarial robustness

---

## 1. Introduction

The vulnerability of machine learning classifiers to adversarial perturbations — small, often imperceptible modifications of the input that change the predicted label — has motivated a growing body of work on **certified robustness**: provable guarantees that no perturbation within a specified ball can alter the classifier's output.

Most existing certification methods target single-round argmax classifiers: given scores $v_1, \ldots, v_m$ for $m$ classes, the prediction is $\arg\max_i v_i$, and certification reduces to showing that the maximum score's lead exceeds twice the perturbation bound. This approach, while effective for simple softmax classifiers, does not extend to more complex decision rules.

In this paper, we consider classifiers whose decision rule is **sequential elimination** (equivalently, instant-runoff voting or IRV): the candidate with the minimum score is eliminated, the scores are recomputed on the remaining set, and the process repeats until a single winner remains. This decision rule arises naturally in hierarchical classification, multi-stage tournament selection, and ensemble methods where classes are progressively pruned.

Our contributions are:

1. **Gap Certificate** (Definition 5): A recursive predicate `EliminationGapCertified` that, when satisfied, provides the inductive fuel for stability proofs through all rounds of elimination.

2. **Perturbation Lemma** (Theorem 1): The algebraic core showing that a gap of γ shrinks by at most 2ε under coordinatewise ε-perturbation — see `gap_preserved_under_perturbation` in @Catalog/Bridges/IRVStability.lean.

3. **Elimination-Order Stability** (Theorem 2): The full inductive theorem that gap certification with parameter γ and perturbation bound ε < γ/2 preserves the entire elimination sequence — see `eliminationOrderOn_stable` in @Catalog/Bridges/IRVStability.lean.

4. **Winner Stability** (Theorem 3): As a corollary, the IRV winner is preserved — see `irvWinnerOn_stable` and `irvWinner_stable` in @Catalog/Bridges/IRVStability.lean.

5. **Lipschitz Robustness Corollary** (Theorem 4): Composition with a K-Lipschitz score map yields an explicit robustness radius r < γ/(2K) in input space — see `irvWinner_certified_robust` in @Catalog/Bridges/IRVStability.lean.

---

## 2. Preliminaries and Definitions

### 2.1 Setting

Fix a positive integer $m$ (the number of candidates/classes) and let $[m] = \{0, 1, \ldots, m-1\}$ denote the candidate set, formalized as `Fin m`. A **score vector** is a function $v : [m] \to \mathbb{R}$.

For a nonempty finite subset $S \subseteq [m]$, we define the **round loser** as any element achieving the minimum score:

$$\text{roundLoser}(S, v) = \arg\min_{i \in S} v(i)$$

In the formalization (@Catalog/Bridges/IRVStability.lean, `roundLoser`), this is implemented via `Classical.choose` on the witness provided by `Finset.exists_min_image`, ensuring well-definedness without assuming decidable equality on reals.

### 2.2 Pairwise Distinctness

**Definition 1** (`PairwiseDistinctOn`). Scores $v$ are **pairwise distinct on** $S$ if for all $i, j \in S$ with $i \neq j$, $v(i) \neq v(j)$.

This condition ensures the uniqueness of the minimizer at each round, preventing ties that would require tie-breaking rules.

### 2.3 Gap Certificate

**Definition 2** (`HasGapAtLeast`). Candidate $i$ has **gap at least** $\gamma$ in $S$ under $v$ if $i \in S$ and

$$\forall j \in S,\; j \neq i \implies v(i) + \gamma \leq v(j).$$

This asserts that $i$ is the unique minimizer with margin $\gamma$.

### 2.4 Sequential Elimination

**Definition 3** (`eliminationOrderOn`). The **elimination order** on $(S, v)$ is defined recursively:
- If $|S| \leq 1$: return $[\min(S)]$.
- Otherwise: let $i = \text{roundLoser}(S, v)$; return $i :: \text{eliminationOrderOn}(S \setminus \{i\}, v)$.

Termination is guaranteed by the strict decrease $|S \setminus \{i\}| < |S|$.

**Definition 4** (`irvWinnerOn`). The **IRV winner** on $(S, v)$ is defined by the same recursion but returns only the final survivor:
- If $|S| \leq 1$: return $\min(S)$.
- Otherwise: let $i = \text{roundLoser}(S, v)$; return $\text{irvWinnerOn}(S \setminus \{i\}, v)$.

**Definition 5** (`EliminationGapCertified`). The elimination of $v$ on $S$ is **gap-certified with parameter** $\gamma$ if:
- If $|S| \leq 1$: trivially true.
- Otherwise: $\text{roundLoser}(S, v)$ has gap at least $\gamma$ in $S$ under $v$, **and** the elimination of $v$ on $S \setminus \{\text{roundLoser}(S, v)\}$ is gap-certified with parameter $\gamma$.

This recursive predicate encodes that the minimum-gap across all rounds of elimination is at least $\gamma$.

---

## 3. Main Results

### 3.1 Uniqueness of the Strict Minimizer

**Lemma 1** (`roundLoser_eq_of_strict_min`). *If $i \in S$ and $v(i) < v(j)$ for all $j \in S \setminus \{i\}$, then $\text{roundLoser}(S, v) = i$.*

*Proof sketch.* The round loser $\ell = \text{roundLoser}(S, v)$ satisfies $v(\ell) \leq v(j)$ for all $j \in S$ (by the specification of `exists_min_image`). If $\ell \neq i$, then $v(i) < v(\ell)$ by the strict minimum hypothesis, contradicting $v(\ell) \leq v(i)$. $\square$

This lemma is critical because it shows that under a gap certificate, the `Classical.choose`-based round loser definition agrees with the intuitively "correct" loser.

### 3.2 The Perturbation Lemma

**Theorem 1** (`gap_preserved_under_perturbation`). *Let $S \subseteq [m]$, $v, v' : [m] \to \mathbb{R}$, and suppose candidate $i$ has gap at least $\gamma$ in $S$ under $v$. If $|v'(k) - v(k)| \leq \varepsilon$ for all $k$, then for all $j \in S$ with $j \neq i$:*

$$v'(i) + (\gamma - 2\varepsilon) \leq v'(j).$$

*Proof sketch.* From $|v'(k) - v(k)| \leq \varepsilon$, we get $v'(i) \leq v(i) + \varepsilon$ and $v(j) - \varepsilon \leq v'(j)$. The gap hypothesis gives $v(i) + \gamma \leq v(j)$. Combining:

$$v'(i) + (\gamma - 2\varepsilon) \leq (v(i) + \varepsilon) + (\gamma - 2\varepsilon) = v(i) + \gamma - \varepsilon \leq v(j) - \varepsilon \leq v'(j). \quad\square$$

The formal proof is a direct `linarith` invocation after unpacking absolute values, confirming the clean algebraic structure.

### 3.3 Elimination-Order Stability

**Theorem 2** (`eliminationOrderOn_stable`). *If the elimination of $v$ on $S$ is gap-certified with parameter $\gamma$, $0 \leq \varepsilon$, $2\varepsilon < \gamma$, and $|v'(k) - v(k)| \leq \varepsilon$ for all $k$, then:*

$$\text{eliminationOrderOn}(S, v') = \text{eliminationOrderOn}(S, v).$$

*Proof sketch.* By strong induction on $|S|$.

**Base case** ($|S| \leq 1$): Both sides return $[\min(S)]$, which is the unique element.

**Inductive step** ($|S| > 1$): Let $i = \text{roundLoser}(S, v)$. The gap certificate gives $\text{HasGapAtLeast}(S, v, i, \gamma)$. By Theorem 1, candidate $i$ has gap $\gamma - 2\varepsilon > 0$ under $v'$. By Lemma 1, $\text{roundLoser}(S, v') = i$ as well.

Both elimination orders therefore begin with $i$ and continue on $S \setminus \{i\}$. The gap certificate's recursive clause provides `EliminationGapCertified` for $S \setminus \{i\}$, and $|S \setminus \{i\}| < |S|$ triggers the induction hypothesis. $\square$

### 3.4 Winner Stability

**Theorem 3** (`irvWinnerOn_stable`). *Under the same hypotheses as Theorem 2:*

$$\text{irvWinnerOn}(S, v') = \text{irvWinnerOn}(S, v).$$

*Proof sketch.* By the same strong induction as Theorem 2. At each step, the round loser is identical under $v$ and $v'$, so the recursion proceeds on the same reduced set. The final singleton is therefore the same candidate. $\square$

**Corollary** (`irvWinner_stable`). *For $S = [m]$ (the full candidate set), the same conclusion holds for `irvWinner`.*

### 3.5 The Lipschitz Robustness Corollary

**Theorem 4** (`irvWinner_certified_robust`). *Let $s : \mathbb{R}^d \to \mathbb{R}^m$ be a score map satisfying the L∞-Lipschitz condition:*

$$\forall z, z' \in \mathbb{R}^d,\; \|z' - z\|_\infty \leq r \implies \|s(z') - s(z)\|_\infty \leq Kr$$

*(componentwise). If the elimination of $s(x)$ on $[m]$ is gap-certified with parameter $\gamma$, $K \geq 0$, $r \geq 0$, and $2Kr < \gamma$, then:*

$$\text{irvWinner}(s(x')) = \text{irvWinner}(s(x))$$

*for all $x'$ with $\|x' - x\|_\infty \leq r$.*

*Proof.* Set $\varepsilon = Kr$ in Theorem 3. The Lipschitz condition gives $|s(x')(i) - s(x)(i)| \leq Kr = \varepsilon$ for all $i$. The hypothesis $2Kr < \gamma$ is exactly $2\varepsilon < \gamma$. Apply `irvWinner_stable`. $\square$

This yields the explicit **certified robustness radius**:

$$r^* = \frac{\gamma}{2K}$$

Any perturbation of the input within the L∞-ball of radius $r < r^*$ is guaranteed to preserve the IRV classification.

---

## 4. Algorithmic Aspects

### 4.1 Computing the Gap Certificate

Given scores $v$ on $[m]$, computing the gap certificate is straightforward:

```
function compute_gap_certificate(v, S):
    if |S| ≤ 1: return ∞
    i* = argmin_{i ∈ S} v(i)
    γ_round = min_{j ∈ S, j ≠ i*} (v(j) - v(i*))
    γ_rest = compute_gap_certificate(v, S \ {i*})
    return min(γ_round, γ_rest)
```

The minimum gap γ across all rounds determines the certificate parameter. The algorithm runs in $O(m^2)$ time and $O(m)$ space.

### 4.2 Computing the Lipschitz Constant

For piecewise-linear (ReLU) networks, the Lipschitz constant K in the L∞ norm can be bounded by the product of weight matrix operator norms (in the $\ell^\infty \to \ell^\infty$ norm, i.e., the maximum absolute row sum). Tighter, input-dependent bounds can be obtained via interval bound propagation or linear relaxation methods.

### 4.3 Certification Pipeline

The full certification pipeline for a given input $x$:

1. Compute scores $v = s(x)$.
2. Run `compute_gap_certificate(v, [m])` to obtain $\gamma$.
3. Obtain or bound the Lipschitz constant $K$.
4. Report robustness radius $r^* = \gamma / (2K)$.

All steps are polynomial in $m$ and $d$, making certification efficient even for large-scale classifiers.

---

## 5. Connections to Tropical Geometry

The framework has deep connections to tropical mathematics. In the tropical semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$, the operation $\min$ replaces addition. The round loser selection $\arg\min_{i \in S} v(i)$ is the tropical analog of finding the "dominant monomial."

The gap certificate measures separation in the tropical sense: the gap $\gamma$ is the tropical distance between the minimum and the second minimum. Under the tropical Satake correspondence — which relates tropical geometry to representation-theoretic data — gap certificates correspond to the widths of Newton polytope facets.

For piecewise-linear classifiers (ReLU networks), the score map $s$ is a tropical rational function, making the entire certification framework intrinsically tropical. This perspective suggests generalizations to tropical convexity-based classifiers and connections to the Maslov dequantization of softmax classifiers.

---

## 6. Discussion

### 6.1 Comparison with Existing Methods

Most certified robustness methods for multiclass classifiers certify a single argmax operation. Our framework is strictly more general: it certifies the outcome of an arbitrary-depth sequential elimination process. When the elimination has only one round (i.e., $m = 2$, binary classification), our gap certificate reduces to the standard margin-based certificate.

Randomized smoothing provides probabilistic robustness certificates by averaging over Gaussian noise. Our certificates are deterministic and exact — they provide absolute guarantees rather than high-probability bounds. The tradeoff is that our certificates require Lipschitz bounds on the score map, which can be conservative for deep networks.

### 6.2 Strength of the Result

A notable feature of Theorem 2 is that it certifies the **entire elimination order**, not just the winner. This has implications for interpretability: in applications where the ranking of eliminated candidates matters (e.g., "second-best diagnosis"), the gap certificate provides stability guarantees for the full ranking.

### 6.3 Limitations

The framework assumes tie-free elimination (ensured by the gap certificate when $\gamma > 0$) and a fixed score function applied uniformly across rounds. Extensions to score functions that depend on the active set (as in true ranked-choice voting with ballot transfers) require additional structure.

---

## 7. Future Work

Several natural extensions suggest themselves:

1. **Adaptive gap certificates**: Allow $\gamma$ to vary across rounds, providing tighter certificates when early rounds have large gaps but later rounds are closer.

2. **Probabilistic relaxation**: Combine deterministic gap certificates with randomized smoothing for tighter probabilistic guarantees.

3. **Tropical neural architecture design**: Design network architectures whose tropical structure ensures large gap certificates by construction.

4. **Connection to the Karchmer-Wigderson theorem**: The rectangle cover lower bounds developed in related work on communication complexity may yield circuit depth lower bounds via the Karchmer-Wigderson connection, providing structural complexity-theoretic foundations for understanding the limitations of efficient certified robustness.

5. **Razborov's approximation method**: Monotone circuit complexity lower bounds, particularly for the clique function, may illuminate fundamental barriers to computing gap certificates efficiently for certain classes of functions.

---

## 8. References

1. Goodfellow, I.J., Shlens, J., & Szegedy, C. (2015). Explaining and harnessing adversarial examples. *ICLR 2015*.

2. Cohen, J., Rosenfeld, E., & Kolter, J.Z. (2019). Certified adversarial robustness via randomized smoothing. *ICML 2019*.

3. Wong, E., & Kolter, J.Z. (2018). Provable defenses against adversarial examples via the convex outer adversarial polytope. *ICML 2018*.

4. Karchmer, M., & Wigderson, A. (1990). Monotone circuits for connectivity require super-logarithmic depth. *SIAM Journal on Discrete Mathematics*, 3(2), 255–265.

5. Razborov, A.A. (1985). Lower bounds on the monotone complexity of some Boolean functions. *Doklady Akademii Nauk SSSR*, 281(4), 798–801.

6. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics, Vol. 161, AMS.

7. Zhang, H., Weng, T.-W., Chen, P.-Y., Hsieh, C.-J., & Daniel, L. (2018). Efficient neural network robustness certification with general activation functions. *NeurIPS 2018*.

---

## Appendix: Formal Verification

All definitions and theorems in this paper have been formalized and machine-verified. The complete formalization is available in @Catalog/Bridges/IRVStability.lean. The proof architecture follows the structure of this paper: core definitions (§2), the perturbation lemma (§3.2), the inductive stability theorem (§3.3), and the Lipschitz corollary (§3.5). The formalization totals approximately 220 lines including documentation.
