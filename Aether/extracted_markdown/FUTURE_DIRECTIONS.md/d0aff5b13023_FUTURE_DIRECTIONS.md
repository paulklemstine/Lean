# Future Directions: Tropical Language Evolution

## Breakthrough-Level Research Opportunities

This document outlines concrete, actionable research directions opened by the tropical phylogenetics framework. Each direction includes hypotheses, proof strategies, and cross-domain connections.

---

## Direction 1: Tropical Mutual Information for Language Families

### Hypothesis
There exists a natural **idempotent mutual information** functional I_trop(X; Y) defined on pairs of languages that quantifies shared evolutionary history through the min-plus semiring, paralleling Shannon's mutual information but in the tropical setting.

### Formal Target
Define:
```
I_trop(L₁, L₂) = H_trop(L₁) + H_trop(L₂) - H_trop(L₁, L₂)
```
where H_trop is a tropical entropy (e.g., the tropical analogue of Rényi entropy at the idempotent limit). Prove that:
1. I_trop(L, L) = H_trop(L) (self-information equals entropy)
2. I_trop(L₁, L₂) ≥ 0 (non-negativity)
3. I_trop is monotone under tropical diffusion (shared information cannot increase under independent evolution)

### Proof Strategy
- Define tropical entropy as the value of the tropical permanent or min-plus eigenvalue of the joint cost matrix
- Use the nonexpansiveness theorem to prove monotonicity
- Connect to Maslov dequantization: as temperature → 0 in the free energy, Shannon MI → tropical MI

### Cross-Domain Connections
- **Information theory**: Establishes a tropical channel capacity theorem for evolutionary channels
- **Machine learning**: Tropical MI could serve as a loss function for unsupervised phylogenetic clustering
- **Statistical physics**: Connects to zero-temperature limits of partition functions

### Team Assignment
Algebra team (semiring axioms) + Dynamics team (monotonicity) + Semantics team (information-theoretic interpretation)

---

## Direction 2: Tropical Gromov Reconstruction from Incomplete Word Lists

### Hypothesis
When lexical data is incomplete (some word meanings are unattested for some languages), the Gromov product and tropical four-point condition can be used to reconstruct a **partial tree** that is unique up to the missing data, with quantifiable uncertainty bounds.

### Formal Target
Define a partial distance matrix D_partial where some entries are missing. Prove:
1. If the observed entries satisfy the four-point condition, there exists a unique tree T compatible with all observed distances
2. The unobserved distances are bounded: d_min(u,v) ≤ d_true(u,v) ≤ d_max(u,v) where the bounds are computable from the observed data
3. The reconstruction is **stable**: small perturbations in observed distances produce small changes in the tree topology

### Proof Strategy
- Formalize the Gromov product: (x|y)_z = (d(x,z) + d(y,z) - d(x,y))/2
- Use the four-point condition to bound missing entries: d(u,v) ≤ d(u,w) + d(w,v) and d(u,v) ≥ |d(u,w) - d(w,v)| for observed intermediate w
- Prove a Lipschitz stability bound for the neighbor-joining algorithm under bounded perturbations

### Cross-Domain Connections
- **Archaeology**: Fragmentary inscriptions and dead languages with limited attestation
- **Bioinformatics**: Incomplete gene sequences, missing taxa
- **Metric geometry**: Extends Gromov hyperbolicity theory to partial metric spaces

### Team Assignment
Graph team (reconstruction algorithms) + Phylogeny team (stability analysis)

---

## Direction 3: Stability of Phylogenetic Trees Under Lexical Coding Noise

### Hypothesis
The coding invariance theorem (Theorem 7.2) extends to an **approximate** version: if coding errors are bounded by ε, the reconstructed tree topology is preserved as long as ε is below a computable threshold depending on the minimum internal edge length.

### Formal Target
Prove:
1. If d and d' are distance matrices with ||d - d'||_∞ ≤ ε, and d satisfies the strict four-point condition with gap δ > 0, then d' satisfies the four-point condition whenever ε < δ/4
2. The Robinson-Foulds distance between trees reconstructed from d and d' is zero when ε < δ/4
3. For edge lengths, |length(e) - length'(e)| ≤ 2ε for every edge e

### Proof Strategy
- Formalize the strict four-point condition with gap: the largest pairwise sum exceeds the second-largest by at least δ
- Use the triangle inequality for ||·||_∞ to propagate error bounds through the four-point computation
- Show neighbor-joining topology is determined by the ordering of Q-matrix entries, which is stable under small perturbations

### Cross-Domain Connections
- **Robust statistics**: Provides breakdown point analysis for phylogenetic methods
- **Coding theory**: Error-correcting codes for phylogenetic signals
- **Numerical analysis**: Condition numbers for tree reconstruction

### Team Assignment
Phylogeny team (combinatorial stability) + Algebra team (perturbation bounds)

---

## Direction 4: Idempotent Bayesian Inference for Proto-Language Reconstruction

### Hypothesis
Proto-language reconstruction can be formulated as a **tropical posterior optimization**: given observed leaf languages and a prior on tree topologies, the maximum-likelihood proto-language at each internal node is the solution to a tropical linear system.

### Formal Target
Define a tropical likelihood:
```
L_trop(proto | leaves, tree) = min over edges e: (cost of evolution along e)
```
Prove:
1. The tropical MAP estimate exists and is unique for each internal node when edge weights are strictly positive
2. The MAP estimate coincides with the Fitch parsimony reconstruction for discrete character data
3. Under continuous characters, the MAP estimate is the tropical barycenter (Wasserstein-1 barycenter in the idempotent limit)

### Proof Strategy
- Model the likelihood as a min-plus system of equations
- Use tropical linear algebra (residuation theory) to solve for internal node values
- Show equivalence with Fitch's algorithm by analyzing the discrete limit

### Cross-Domain Connections
- **Bayesian statistics**: Tropicalization of posterior distributions
- **Optimization**: LP duality in the tropical setting
- **Historical linguistics**: Automated proto-language reconstruction with formal guarantees

### Team Assignment
Algebra team (tropical linear systems) + Semantics team (Bayesian interpretation) + Graph team (algorithmic implementation)

---

## Direction 5: Comparison of Tropical Linguistic Trees with Biological Phylogenetic Metrics

### Hypothesis
The tropical phylogenetic framework, when applied to biological sequence data, produces distance matrices that are **equivalent** to those produced by standard molecular phylogenetic methods (e.g., Jukes-Cantor, Kimura) under specific parameter regimes, but with stronger algebraic guarantees.

### Formal Target
1. Define a tropical substitution model for DNA/protein sequences analogous to the lexical replacement kernel
2. Prove that for substitution matrices of the form w(i,j) = -log P(j|i), the tropical closure recovers the log-likelihood distance
3. Show that under the molecular clock hypothesis, the tropical glottochronological dating formula specializes to the standard molecular clock formula: divergence time = genetic distance / (2 × mutation rate)
4. Identify the precise conditions under which tropical and probabilistic phylogenetics agree (characterize the tropicalization map from probability → min-plus)

### Proof Strategy
- Use Maslov dequantization (idempotent analysis) to relate the log-sum-exp operation of probabilistic phylogenetics to the min operation of tropical phylogenetics
- Show that as the "temperature" parameter β → ∞, the log-sum-exp likelihood → min cost
- Prove convergence of tree topologies under this limit

### Cross-Domain Connections
- **Molecular biology**: Unifies linguistic and biological tree reconstruction
- **Statistical physics**: Connects to zero-temperature limits and ground-state structures
- **Computer science**: Certified algorithms for biological sequence analysis

### Team Assignment
Full team collaboration — this is the capstone direction that unifies all threads

---

## Implementation Priorities

### Phase 1 (Immediate, 1-3 months)
- Direction 3 (Stability): Most accessible, builds directly on current results
- Direction 1 (Tropical MI): Definitional work, connects to well-established theory

### Phase 2 (Medium-term, 3-6 months)
- Direction 2 (Gromov reconstruction): Requires new theory but has clear applications
- Direction 4 (Bayesian inference): Connects to active research programs

### Phase 3 (Long-term, 6-12 months)
- Direction 5 (Biology comparison): Capstone result requiring all previous directions

### Validation Strategy
Each direction should be validated by:
1. **Computational experiments** on simulated data (Python implementation)
2. **Case studies** on real linguistic/biological datasets
3. **Formal verification** in Lean 4 of all core theorems
4. **Comparison** with existing methods on benchmark datasets

---

## Team Structure

| Team | Focus | Key Skills |
|------|-------|------------|
| **Algebra** | Tropical semiring identities, linear algebra, residuation | Abstract algebra, category theory |
| **Dynamics** | Nonexpansive operators, fixed points, convergence | Functional analysis, dynamical systems |
| **Graph** | Shortest paths, Steiner trees, reconstruction algorithms | Combinatorics, algorithm design |
| **Phylogeny** | Four-point condition, tree metrics, stability | Discrete mathematics, phylogenetics |
| **Semantics** | Information theory, coding invariance, cross-domain interpretation | Information theory, mathematical linguistics |

---

## Success Metrics

A direction is considered a **breakthrough** if it:
1. Produces at least one formally verified theorem that is new to the mathematical literature
2. Demonstrates practical applicability on real data
3. Opens at least two new research sub-directions
4. Connects at least two previously unrelated mathematical domains

The ultimate success metric: a complete, formally verified **tropical reconstruction theorem** that takes as input a distance matrix satisfying computable algebraic conditions and outputs a provably unique, optimal phylogenetic tree with exact dating.
