# Compositional Robustness Certificates for Hierarchical Decision Trees via GL3 Tropical Satake Margin Analysis

## Abstract

We establish a compositional robustness theorem for hierarchical classifiers built from binary decision trees whose internal-node decisions are induced by tropicalized GL3 Hecke score aggregates. While prior work in the GL3 tropical Satake robustness program has addressed flat decoders—argmax, top-*k*, ECOC, and one-vs-one—hierarchical trees introduce genuinely new mathematics because robustness is no longer a one-shot multiclass margin statement but a *pathwise composition* of local tropical margin certificates. We prove that if each internal node on the clean classification path has a positive local margin exceeding a Lipschitz-derived threshold, then the entire predicted leaf label is preserved under perturbation. The resulting certified robustness radius is:

$$r^*(x) = \min_{v \in \text{path}} \frac{\Delta_v(x)}{2K_v}$$

where $\Delta_v(x)$ is the local chosen-vs-other margin at node $v$ and $K_v$ is the nodewise Lipschitz constant. All results are formally verified in Lean 4 with Mathlib, providing machine-checked mathematical certainty.

## 1. Introduction

### 1.1 Motivation

Adversarial robustness—the stability of classifier predictions under small input perturbations—is a central concern in deploying machine learning systems in safety-critical domains. The standard approach certifies robustness for flat classifiers: given scores $s_1(x), \ldots, s_n(x)$ and an argmax decision rule, a perturbation of radius $r$ preserves the prediction if the margin between the winning score and all others exceeds $2Lr$, where $L$ is the Lipschitz constant.

However, many real-world classification systems are *hierarchical*. ImageNet's label space, for instance, is organized as a WordNet taxonomy. Medical diagnosis follows anatomical and etiological hierarchies. Document classification uses topic trees. In these settings, the classification decision is not a single argmax but a sequence of binary comparisons along a root-to-leaf path in a decision tree.

### 1.2 The Composition Principle

The central insight of this work is that hierarchical robustness decomposes into independent local certificates. Consider a binary decision tree where each internal node $v$ compares two score aggregates $S_L(v, x)$ and $S_R(v, x)$, directing the input left or right. For a clean input $x$ classified along path $\pi = (v_1, v_2, \ldots, v_d)$, the classifier output is determined by the sequence of binary decisions.

**Key Observation.** If each binary decision on the path is individually preserved under perturbation, then the entire path—and hence the leaf label—is preserved. This reduces hierarchical robustness to a conjunction of independent local margin conditions.

### 1.3 Contributions

1. **Sign-preservation lemma** (`hierarchical_robust_of_path_margins`): We prove that if $2K_v r < \Delta_v(x)$ for all nodes $v$ on the clean path, then $\Delta_v(y) > 0$ for all $y$ with $d(y, x) \leq r$.

2. **Classifier invariance** (`hierarchical_classifier_constant_on_ball`): We derive that the classifier output $F(y) = F(x)$ for all $y$ in the certified ball.

3. **Explicit certificate** (`robustness_of_radius_lt_path_certificate`): We prove that $r^* = \inf'_{v \in s} \Delta_v(x)/(2K_v)$ is a valid robustness radius using `Finset.inf'`.

4. **Additive budget variant** (`hierarchical_robust_of_summed_losses`): We prove robustness under heterogeneous perturbation budgets summed across nodes.

5. **Aggregate Lipschitz bridge** (`margin_diff_lipschitz_of_aggregate_lipschitz`): We prove the $2L$ factor relating individual-aggregate Lipschitz constants to margin-difference Lipschitz constants.

6. **Formal verification**: All results are machine-checked in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 2. Mathematical Framework

### 2.1 Setting

Let $(X, d)$ be a metric space of inputs. Fix a finite type $\iota$ indexing tree nodes and a type $\gamma$ of class labels.

**Definition 2.1** (Local Margin). For score aggregates $S_L, S_R : \iota \to X \to \mathbb{R}$ and branch direction $g : \iota \to \{L, R\}$, the *local margin* at node $v$ is:

$$\Delta_v(x) = \begin{cases} S_R(v, x) - S_L(v, x) & \text{if } g(v) = R \\ S_L(v, x) - S_R(v, x) & \text{if } g(v) = L \end{cases}$$

A positive margin $\Delta_v(x) > 0$ means the clean decision at node $v$ is correct (the chosen branch has higher score).

### 2.2 Lipschitz Assumptions

We assume the score difference $S_R(v, \cdot) - S_L(v, \cdot)$ satisfies a nodewise Lipschitz condition:

$$|(S_R(v, y) - S_L(v, y)) - (S_R(v, z) - S_L(v, z))| \leq K_v \cdot d(y, z)$$

for all $y, z \in X$. When individual aggregates are each $L_v$-Lipschitz, this holds with $K_v = 2L_v$ (Theorem 5.1).

### 2.3 Classifier Specification

The classifier $F : X \to \gamma$ is specified axiomatically: there exists a "clean" path $\pi \subseteq \iota$ such that for any input $y$, if $\Delta_v(y) > 0$ for all $v \in \pi$, then $F(y) = F(x)$. This cleanly separates the analytic robustness argument from the combinatorial tree semantics.

## 3. Main Theorems

### 3.1 Path Margin Preservation (Theorem 3.1)

**Theorem** (`hierarchical_robust_of_path_margins`). *Let $\pi$ be a list of internal nodes, $K : \iota \to \mathbb{R}_{\geq 0}$, $x \in X$, $r \in \mathbb{R}$. Suppose:*
1. *$K_v \geq 0$ for all $v \in \pi$,*
2. *$|(S_R(v,y) - S_L(v,y)) - (S_R(v,z) - S_L(v,z))| \leq K_v \cdot d(y,z)$ for all $v \in \pi$, $y, z \in X$,*
3. *$2 K_v r < \Delta_v(x)$ for all $v \in \pi$.*

*Then for all $y \in X$ with $d(y, x) \leq r$ and all $v \in \pi$: $\Delta_v(y) > 0$.*

**Proof sketch.** Fix $v \in \pi$ and $y$ with $d(y,x) \leq r$. By the Lipschitz condition:
$$|\Delta_v(y) - \Delta_v(x)| \leq K_v \cdot d(y, x) \leq K_v \cdot r$$

This follows by case-splitting on $g(v)$: when $g(v) = R$, $\Delta_v = S_R - S_L$ and the Lipschitz bound applies directly; when $g(v) = L$, $\Delta_v = S_L - S_R = -(S_R - S_L)$ and we use $|{-}a| = |a|$.

From $|\Delta_v(y) - \Delta_v(x)| \leq K_v r$ we extract:
$$\Delta_v(y) \geq \Delta_v(x) - K_v r > 2K_v r - K_v r = K_v r \geq 0$$

where the last inequality uses $K_v \geq 0$. ∎

### 3.2 Classifier Invariance (Theorem 3.2)

**Theorem** (`hierarchical_classifier_constant_on_ball`). *Under the hypotheses of Theorem 3.1, if additionally $F(x) = \ell$ and $F(y) = \ell$ whenever all path margins are positive at $y$, then $F(y) = \ell$ for all $y$ with $d(y,x) \leq r$.*

**Proof.** Immediate composition: Theorem 3.1 gives positive margins, the specification gives the label. ∎

### 3.3 Explicit Certificate (Theorem 3.3)

**Theorem** (`robustness_of_radius_lt_path_certificate`). *Let $s$ be a nonempty finite set of nodes with $K_v > 0$ for all $v \in s$. If*
$$r < \inf'_{v \in s} \frac{\Delta_v(x)}{2K_v}$$
*then $F(y) = \ell$ for all $y$ with $d(y,x) \leq r$.*

**Proof.** For each $v \in s$, `Finset.inf'_le` gives $\inf'_{v \in s} f(v) \leq f(v)$, so $r < \Delta_v(x)/(2K_v)$. Multiplying by $2K_v > 0$ yields $2K_v r < \Delta_v(x)$. The rest follows from Theorem 3.1. ∎

### 3.4 Additive Budget Variant (Theorem 3.4)

**Theorem** (`hierarchical_robust_of_summed_losses`). *Let $\Delta : \iota \to X \to \mathbb{R}$ be margin functions, $K : \iota \to \mathbb{R}_{\geq 0}$ Lipschitz constants, and $\ell : \iota \to \mathbb{R}_{\geq 0}$ loss budgets. If for all $v \in s$ and all $y \in X$:*
$$|\Delta_v(y) - \Delta_v(x)| \leq K_v \sum_{u \in s} \ell_u \quad \text{and} \quad K_v \sum_{u \in s} \ell_u < \Delta_v(x)$$
*then $F(y) = \ell$ for all $y \in X$.*

This variant captures scenarios where perturbation effects are distributed across channels with heterogeneous budgets—a natural model for residual/tropical skip decompositions.

## 4. The GL3 Tropical Satake Connection

### 4.1 Tropicalized Hecke Score Aggregates

In the GL3 tropical Satake framework, class scores arise from tropicalizations of Hecke operators on the GL(3) Satake transform. The score for class $c$ at input $x$ takes the form:

$$S_c(x) = \bigoplus_{w \in W} \lambda_w^{(c)} \odot \phi_w(x)$$

where $\oplus = \max$, $\odot = +$ in the tropical semiring, $W$ is the Weyl group of GL(3), $\lambda_w^{(c)}$ are Satake parameters, and $\phi_w$ are feature maps.

### 4.2 From Flat to Hierarchical

Previous work established Lipschitz control for individual tropical score aggregates. Our bridge lemma (Theorem 5.1) converts these individual-aggregate bounds into margin-difference bounds with the canonical factor of 2. The hierarchical theorems then compose these local bounds along decision paths, enabling certified robustness for tree-structured decoders that were previously out of reach.

### 4.3 Why Hierarchies Matter

Flat argmax decoders compare all classes simultaneously, yielding a single "weakest competitor" bottleneck. Hierarchical decoders decompose this into a sequence of binary comparisons, each potentially with a *different* Lipschitz constant. This is significant because:

- **Coarser distinctions are easier.** The "animal vs. object" comparison typically has a much larger margin than "golden retriever vs. labrador retriever." A flat decoder's certificate is bottlenecked by the hardest comparison.
- **Different features have different stability.** Color features may be more robust to noise than texture features. Hierarchical certificates can exploit this heterogeneity.
- **The certified radius can *increase*.** When the Lipschitz constants $K_v$ at coarser levels are smaller (because coarser features are more stable), the hierarchical certificate $\min_v \Delta_v/(2K_v)$ can exceed the flat certificate $\min_c (s_{\text{winner}} - s_c)/(2L)$.

## 5. Bridge Lemma: Aggregate to Margin Lipschitz

**Theorem 5.1** (`margin_diff_lipschitz_of_aggregate_lipschitz`). *If $|S_L(y) - S_L(z)| \leq L \cdot d(y,z)$ and $|S_R(y) - S_R(z)| \leq L \cdot d(y,z)$ for all $y, z$, then:*
$$|(S_R(y) - S_L(y)) - (S_R(z) - S_L(z))| \leq 2L \cdot d(y,z)$$

**Proof.** Triangle inequality:
$$|(S_R(y) - S_R(z)) - (S_L(y) - S_L(z))| \leq |S_R(y) - S_R(z)| + |S_L(y) - S_L(z)| \leq 2L \cdot d(y,z)$$
∎

## 6. Formal Verification

All theorems are formalized and verified in Lean 4 using Mathlib. The formalization uses:

- `MetricSpace α` for the perturbation domain
- `List ι` for ordered paths and `Finset ι` for unordered node sets
- `Finset.inf'` for the minimum-over-nonempty-set operation
- Standard real analysis lemmas (`abs_le`, `abs_neg`, `mul_comm`, etc.)

The axiom trace shows only standard foundations:
```
propext, Classical.choice, Quot.sound
```

No custom axioms, `sorry` statements, or `@[implemented_by]` annotations are used.

### 6.1 Proof Architecture

The formalization follows a clean separation of concerns:

1. **Analytic layer**: The sign-preservation lemma handles all real analysis (Lipschitz bounds, absolute values, inequalities).
2. **Compositional layer**: The classifier invariance theorem combines sign preservation with the tree specification.
3. **Certificate layer**: The explicit certificate theorem extracts the quantitative radius using `Finset.inf'` arithmetic.
4. **Bridge layer**: The aggregate Lipschitz lemma connects to the tropical Satake score machinery.

This modular structure means each layer can be independently verified and reused.

## 7. Applications

### 7.1 Certified Hierarchical Image Classification

For ImageNet-style hierarchical classifiers with $d$ levels, our certificate gives:
$$r^*(x) = \min_{i=1}^d \frac{\Delta_{v_i}(x)}{2K_{v_i}}$$

In practice, coarser levels (animal vs. object) typically have both larger margins and smaller Lipschitz constants, so they rarely bottleneck the certificate. The bottleneck is usually a fine-grained distinction (breed-level), matching intuition.

### 7.2 Medical Diagnosis Trees

Medical diagnosis often follows a hierarchical protocol: symptom → organ system → disease category → specific condition. Our theorem certifies that small variations in patient measurements (within the certified radius) do not change the diagnosis at any level of the hierarchy.

### 7.3 Ensemble Decision Trees

Random forests and gradient-boosted trees make predictions via hierarchical paths. While individual tree robustness is a special case of our theorem, the additive budget variant (Theorem 3.4) additionally handles ensemble-level perturbation budgets.

## 8. Discussion: A Scientific American Perspective

### The Security Guard Analogy

Imagine a museum with a series of security checkpoints. Each guard checks one credential: "Are you an employee?" → "Are you authorized for this wing?" → "Do you have clearance for this vault?" A visitor who passes all checkpoints reaches the vault.

Now imagine a forger trying to sneak in by slightly altering their badge. Our theorem says: if each guard's check has enough "slack" (the real badge is clearly better than a forgery), and the forgery is close enough to the original, then every single guard will still let the real badge-holder through. The *certified radius* is the maximum amount of alteration where this guarantee holds.

The key insight is **composition**: we don't need to reason about the entire sequence of checkpoints as one monolithic verification. If each checkpoint is individually robust, the whole chain is robust. This is the difference between proving security "globally" (exponentially hard as the number of checkpoints grows) and proving it "locally" (linear in the number of checkpoints).

### Why Trees Beat Flat Comparisons

A flat classifier is like a single guard who checks your badge against *every other person's badge simultaneously*. This guard has to maintain a huge margin—the badge must be clearly different from the closest impostor among all possible impostors.

A hierarchical classifier is like a series of specialized guards, each comparing only two options: "employee or visitor?", "east wing or west wing?", etc. Each comparison is simpler, and the margin needed at each step can be smaller. More importantly, different guards can use different detection technologies—the first guard might use facial recognition (robust to lighting changes), while the vault guard uses fingerprints (robust to disguises). The hierarchical certificate exploits this *heterogeneity*.

### From Tropical Geometry to AI Safety

The tropical Satake transform is a piece of pure mathematics connecting algebraic geometry, representation theory, and combinatorics. The fact that it yields Lipschitz-controlled score functions is a bridge between abstract mathematics and concrete AI safety guarantees. Our compositional theorem extends this bridge from flat classifiers to the hierarchical structures that dominate real-world AI systems.

This is part of a broader trend: the most powerful tools for understanding AI systems often come from unexpected mathematical sources. Just as information theory (born from communication engineering) revolutionized statistics, and algebraic topology (born from pure mathematics) is transforming data analysis, tropical geometry may prove essential for understanding the robustness of neural network classifiers.

## 9. Future Directions

1. **Residual/skip decompositions**: The additive budget variant lays groundwork for handling skip connections in deep networks, where perturbation effects propagate through both direct and residual paths.

2. **Probabilistic certificates**: Extending from worst-case to probabilistic guarantees using concentration inequalities on the margin distribution.

3. **Adaptive trees**: Handling data-dependent tree structures where the path itself may change under perturbation (requiring a different, more complex analysis).

4. **Tighter bounds via representation theory**: Exploiting the specific structure of GL(3) Hecke operators to obtain tighter Lipschitz constants than generic estimates.

5. **Computational certification**: Implementing efficient algorithms to compute the path certificate $r^*(x)$ for given inputs, enabling real-time robustness monitoring.

## 10. Conclusion

We have established and formally verified the fundamental composition principle for hierarchical decision tree robustness: local margin certificates compose into global guarantees. The certified radius $r^*(x) = \min_v \Delta_v(x)/(2K_v)$ provides an explicit, computable robustness guarantee for any hierarchical classifier with Lipschitz-controlled score aggregates. By bridging tropical Satake representation theory with structured AI safety guarantees, this work opens the door to certifiably robust hierarchical classification systems.

## References

The formalization is self-contained and verified against Lean 4 v4.28.0 with Mathlib. All five theorems compile without `sorry` and use only standard axioms. The complete Lean source is available in `HierarchicalRobustness.lean`.
