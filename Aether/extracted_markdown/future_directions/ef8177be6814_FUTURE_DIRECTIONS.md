# Future Directions: Tropical Language Evolution

## Overview

This document outlines five concrete breakthrough research directions opened by the formalization of tropical phylogenetics and glottochronology. Each direction includes specific hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Mutual Information for Language Families

### Hypothesis
Define a tropical analogue of mutual information between two language profiles as the difference between independent and joint tropical costs:

$$I_{\text{trop}}(L_1; L_2) = \sum_i L_1(i) + \sum_i L_2(i) - \sum_i \min(L_1(i), L_2(i))$$

This quantity should satisfy chain-rule-like identities under tree-structured evolution and provide a measure of shared ancestry that decomposes along phylogenetic paths.

### Proof Strategy
1. Formalize tropical entropy as $H_{\text{trop}}(L) = \sum_i L(i)$.
2. Show $I_{\text{trop}}$ is nonneg and symmetric using `tropicalDivergence_nonneg` and the relationship between `tropicalLexCost` and `tropicalDivergence`.
3. Prove a data-processing inequality: tropical diffusion via `tropicalStep` cannot increase $I_{\text{trop}}$ (use the nonexpansiveness result).
4. Derive a chain rule under tree-structured composition.

### Cross-Domain Connections
- Information theory: formal bridge to rate-distortion theory for language coding
- Phylogenetics: information-theoretic characterization of tree topology
- Machine learning: tropical information bottleneck for language representation

### Team Tasks
- Define tropical entropy and mutual information in Lean
- Prove nonnegativity and data processing inequality
- Test on Indo-European lexical data (Swadesh lists)
- Connect to existing Mathlib information theory definitions

---

## Direction 2: Certified Quartet Reconstruction Algorithms

### Hypothesis
The four-point condition enables a certified quartet reconstruction algorithm: given pairwise tropical divergences among four languages, determine the unique tree topology (or certify that no tree explains the data). The algorithm should be:
- Correct: any output topology is consistent with the input distances
- Complete: if a tree topology exists, the algorithm finds it
- Certified: the correctness proof is machine-verified

### Proof Strategy
1. Formalize the three possible quartet topologies as an inductive type.
2. Define the quartet selection rule: choose the split $(ab|cd)$ when $d(a,b) + d(c,d)$ is the unique minimum among the three pairwise sums.
3. Prove correctness using `tropicalDivergence_fourPoint_fin1` as the base case.
4. Extend to multi-dimensional data with betweenness constraints using `tropicalDivergence_additive_of_between`.
5. Implement the algorithm in both Lean (verified) and Python (efficient).

### Cross-Domain Connections
- Algorithmic phylogenetics: first formally verified tree reconstruction algorithm
- Tropical geometry: connection to tropical Grassmannians and tree space
- Computational linguistics: automated language family classification

### Team Tasks
- Define quartet topology type and selection rule
- Prove soundness of quartet selection
- Implement neighbor-joining variant using tropical divergences
- Benchmark on Austronesian and Indo-European language families

---

## Direction 3: Stochastic Tropical Drift and Concentration Bounds

### Hypothesis
When lexical innovations occur as i.i.d. nonneg random variables along tree edges, the observed tropical divergence concentrates around its expected value (the tree path distance) with sub-Gaussian tails. Specifically, if each coordinate drift $\delta_i$ has mean $\mu$ and sub-Gaussian parameter $\sigma$, then:

$$\Pr[|\text{tropicalDivergence}(L_a, L_b) - n\mu \cdot d_T(a,b)| > t] \leq 2\exp(-t^2 / (2n\sigma^2))$$

where $n = |\iota|$ is the number of lexical items and $d_T$ is the tree path distance.

### Proof Strategy
1. Formalize the stochastic evolution model with i.i.d. edge drifts.
2. Use the deterministic path additivity theorem (`tropicalDivergence_additive_of_between`) as the structural backbone.
3. Apply Hoeffding's inequality (available in Mathlib or buildable) to the sum of independent absolute differences.
4. Derive confidence intervals for glottochronological dating.

### Cross-Domain Connections
- Statistics: formal concentration inequalities for phylogenetic estimators
- Historical linguistics: quantified uncertainty in language dating
- Network tomography: analogous concentration results for network delay estimation

### Team Tasks
- Define stochastic evolution model in Lean (probability measures on drift vectors)
- Prove concentration bound using Mathlib probability theory
- Implement Monte Carlo simulations to validate bounds
- Apply to dating of Proto-Indo-European divergence

---

## Direction 4: Tropical Semantic Change Geometry

### Hypothesis
Extend the lexical cost model from presence/absence to semantic distance: define $L(i)$ not as a scalar but as a point in a tropical module, representing the semantic position of lexical item $i$. Semantic drift is then a tropical translation in this module. The key conjecture:

*Semantic change preserves tropical convexity: if a set of related meanings forms a tropically convex set in the ancestor language, its images under semantic drift remain tropically convex in descendant languages.*

### Proof Strategy
1. Define tropical convexity for subsets of $\mathbb{R}^n$ using coordinatewise min/max.
2. Show that additive translation (the drift model) preserves tropical convexity.
3. Prove that the coordinatewise median (`coordMedian3`) of tropically convex sets is tropically convex.
4. Use the median optimality theorem (`coordMedian3_minimizes`) to show that ancestral semantic categories are recoverable.

### Cross-Domain Connections
- Computational semantics: geometric models of meaning change
- Tropical geometry: new applications of tropical convexity theory
- Cognitive science: mathematical models of category evolution
- NLP: tropical word embeddings

### Team Tasks
- Define tropical convex sets and tropical modules in Lean
- Prove preservation of convexity under drift
- Implement tropical semantic embeddings using word2vec data
- Compare with classical semantic change models (e.g., Hamilton et al.)

---

## Direction 5: Categorical Equivalence Between Additive Tree Metrics and Tropical Ancestral Systems

### Hypothesis
There is a categorical equivalence (in the sense of category theory) between:
- **AdTree**: the category of finite additive tree metrics with distance-preserving maps
- **TropAnc**: the category of tropical ancestral systems, where objects are finite families of language profiles satisfying the betweenness condition, and morphisms are coordinatewise-monotone maps preserving tropical divergence

This equivalence maps a tree metric to its realization as tropical divergences on leaf profiles, and conversely maps a tropical ancestral system to the unique additive tree consistent with pairwise divergences.

### Proof Strategy
1. Define the category **AdTree** using the four-point condition as the defining property.
2. Define the category **TropAnc** using `IsBetween` and `tropicalDivergence`.
3. Construct the realization functor: given a tree, produce leaf profiles (this is the content of the path additivity theorem).
4. Construct the reconstruction functor: given profiles satisfying four-point, produce a tree (this requires formalizing additive tree reconstruction, e.g., via the Buneman tree).
5. Prove natural isomorphism between the two compositions.

### Cross-Domain Connections
- Category theory: new categorical perspective on metric phylogenetics
- Tropical geometry: functorial relationship between tropical and classical geometry
- Formal verification: first machine-verified categorical phylogenetics result
- Database theory: categorical framework for evolutionary data transformations

### Team Tasks
- Define AdTree and TropAnc categories in Lean using Mathlib category theory
- Construct and verify the two functors
- Prove the natural isomorphism
- Write expository paper connecting categorical algebra to historical linguistics

---

## Implementation Priority

| Priority | Direction | Difficulty | Impact |
|----------|-----------|------------|--------|
| 1 | Quartet Reconstruction | Medium | High |
| 2 | Stochastic Concentration | Medium | High |
| 3 | Tropical Mutual Information | Low | Medium |
| 4 | Semantic Change Geometry | High | High |
| 5 | Categorical Equivalence | Very High | Very High |

## Dependencies

- Directions 1 and 2 can proceed independently and in parallel.
- Direction 3 requires Mathlib probability theory infrastructure.
- Direction 4 builds on Direction 1 (tropical information measures).
- Direction 5 requires Directions 1–3 as foundational results.
