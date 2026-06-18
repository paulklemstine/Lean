# Future Directions: Tropical Compositional Stability

## Overview

The tropical compositional stability theorem — that max-plus neural network layers are 1-Lipschitz at any depth — opens five concrete research frontiers. Each direction below includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Perron-Frobenius Theory and Asymptotic Depth Behavior

### Hypothesis
For a square tropical weight matrix $W$, the iterated aggregation $F_W^n(x)$ converges (up to additive normalization) to a tropical eigenvector: a vector $v$ satisfying $F_W(v) = v + \lambda$ for some tropical eigenvalue $\lambda \in \mathbb{R}$.

### Proof Strategy
1. Define the tropical eigenvalue problem: $\max_i(W(i,j) + v(i)) = v(j) + \lambda$.
2. Show that the sequence $F_W^n(x) - n\lambda$ is eventually periodic (known classically for irreducible matrices).
3. Formalize the max-plus spectral theorem: every irreducible matrix has a unique eigenvalue equal to the maximum cycle mean.
4. Connect to the stability theorem: convergence rate is bounded by the cyclicity of the critical graph.

### Key Lemmas to Formalize
- Maximum cycle mean computation for directed weighted graphs
- Tropical matrix powers and periodicity
- Connection between eigenvalue and long-term average growth

### Cross-Domain Impact
- **Operations research:** Optimal scheduling and resource allocation
- **Dynamical systems:** Fixed-point analysis of iterated max-plus maps
- **Machine learning:** Characterization of tropical network convergence during inference

### Estimated Difficulty: Medium-High
The classical theory is well-developed (Butkovič, 2010) but formalization requires substantial graph theory infrastructure.

---

## Direction 2: Certified Adversarial Radii for Tropical Classifiers

### Hypothesis
For a tropical classifier with $k$ classes and depth $d$, the certified $\ell^\infty$ robustness radius at input $x$ is exactly $\text{margin}(x) / 2$, independent of depth. Moreover, this bound is tight: there exists an adversarial example at distance exactly $\text{margin}(x) / 2$.

### Proof Strategy
1. Use the 1-Lipschitz bound to establish the lower bound on certified radius.
2. Construct an explicit adversarial example achieving the bound by perturbing the coordinate that achieves the supremum in the argmax-defining step.
3. Extend to multi-class margins: certified radius = min margin over all alternative classes.
4. Compare with Randomized Smoothing radii for standard networks.

### Key Lemmas to Formalize
- Margin definition for tropical classifiers
- Tightness construction: explicit adversarial perturbation
- Comparison theorem: tropical certified radius ≥ standard certified radius for same margin

### Cross-Domain Impact
- **AI safety:** Provably robust classification for safety-critical systems
- **Adversarial ML:** New baseline for certified robustness benchmarks
- **Verification:** Integration with neural network verification tools

### Estimated Difficulty: Medium
The upper bound follows directly from our theorems; tightness requires careful construction.

---

## Direction 3: Residuated Semantics and Quantitative Linear Logic

### Hypothesis
The tropical semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$ with residual $a \multimap c = c - a$ forms a residuated lattice, and tropical aggregation layers are residuated maps. The compositional stability theorem is then a statement about cut-elimination in a quantitative proof system.

### Proof Strategy
1. Formalize the residuated lattice structure on $\text{WithBot}\ \mathbb{R}$.
2. Define tropical residual: $a \multimap c = c - a$ with appropriate $\bot$ conventions.
3. Prove the Galois connection: $a \otimes b \leq c \iff b \leq a \multimap c$.
4. Show that tropical aggregation preserves joins (is a sup-lattice morphism), hence has a right adjoint.
5. Interpret composition as cut in a quantitative sequent calculus; stability becomes cut-admissibility.

### Key Lemmas to Formalize
- `WithBot ℝ` as a residuated lattice
- Tropical Galois connection
- Sup-preservation of tropical aggregation
- Connection to Girard's linear logic

### Cross-Domain Impact
- **Logic:** New model of quantitative linear logic from optimization
- **Programming languages:** Resource-typed languages with tropical semantics
- **Category theory:** Enriched profunctors and max-plus Lawvere metrics

### Estimated Difficulty: High
Requires careful handling of $-\infty$ and formalization of lattice-theoretic infrastructure.

---

## Direction 4: Categorical Semantics of Tropical Neural Composition

### Hypothesis
Tropical aggregation defines a category enriched over $([0,\infty], \geq, +)$ (the Lawvere metric monoidal category), where objects are finite types, morphisms are weight matrices, and composition is max-plus matrix multiplication. The stability theorem states that the hom-functor is nonexpansive.

### Proof Strategy
1. Define the tropical category: objects = finite types, $\text{Hom}(\iota, \kappa) = (\iota \to \kappa \to \mathbb{R})$.
2. Verify category axioms: composition = `tropicalCompose`, identity = tropical identity matrix.
3. Define the enrichment: equip hom-sets with the sup metric.
4. Prove that composition is a nonexpansive map $\text{Hom}(A,B) \times \text{Hom}(B,C) \to \text{Hom}(A,C)$.
5. Identify tropical aggregation as the enriched Yoneda embedding composed with evaluation.

### Key Lemmas to Formalize
- Tropical identity matrix and its unit laws
- Enriched category axioms
- Composition as a 1-Lipschitz bilinear (in tropical sense) map
- Connection to Lawvere metric spaces

### Cross-Domain Impact
- **Category theory:** Concrete worked example of enriched categories from applied math
- **Formal methods:** Compositional program verification via enriched semantics
- **Network science:** Metric structure on categories of weighted graphs

### Estimated Difficulty: Medium-High
The mathematics is clean but requires enriched category infrastructure not currently in Mathlib.

---

## Direction 5: Hybrid Tropical-ReLU Architectures with Compositional Guarantees

### Hypothesis
In a hybrid architecture where some layers are tropical (max-plus) and others are standard (ReLU), the overall Lipschitz constant is bounded by the product of the Lipschitz constants of the ReLU layers only — the tropical layers contribute factor 1.

### Proof Strategy
1. Formalize a general "layered network" type that alternates between tropical and standard layers.
2. Prove the multiplicative Lipschitz bound for heterogeneous compositions.
3. Show that inserting tropical layers as "stability barriers" between ReLU layers does not increase the Lipschitz constant.
4. Design architectures that maximize expressivity (ReLU layers) while bounding instability (tropical barriers).
5. Implement and benchmark on standard robustness tasks (MNIST, CIFAR-10).

### Key Lemmas to Formalize
- General composition of Lipschitz maps with different constants
- Tropical layers as "Lipschitz-1 identity" in the composition
- Expressivity analysis: what functions can hybrid networks represent?

### Cross-Domain Impact
- **Deep learning:** Principled architecture design for robust networks
- **Optimization:** Training methods for mixed tropical-standard layers
- **Verification:** Scalable certified robustness for practical networks

### Estimated Difficulty: Medium (theory) + High (implementation)
The theoretical bounds are straightforward extensions; the practical architecture design and training are open engineering challenges.

---

## Team Research Protocol

### Phase 1 (Months 1-3): Foundations
- Formalize Direction 2 (certified radii) as the most directly applicable extension
- Begin Direction 3 (residuated lattice on `WithBot ℝ`)
- Develop computational benchmarks for Direction 5

### Phase 2 (Months 4-6): Core Theory
- Formalize Direction 1 (tropical Perron-Frobenius) for irreducible matrices
- Complete Direction 3 and connect to linear logic
- Prototype hybrid architectures (Direction 5)

### Phase 3 (Months 7-12): Synthesis
- Formalize Direction 4 (categorical semantics) building on Directions 1-3
- Benchmark hybrid architectures against certified robustness baselines
- Publish comprehensive paper connecting all five directions

### Iteration Protocol
Each direction should maintain:
1. A Lean formalization file with current progress
2. A computational notebook with numerical experiments
3. A list of open sub-problems suitable for subagent-assisted proving
4. Cross-references to lemmas shared with other directions
