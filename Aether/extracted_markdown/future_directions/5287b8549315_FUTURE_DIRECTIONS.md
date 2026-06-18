# Future Directions: Tropical Spectral Cryptanalysis

This document outlines five concrete research directions opened by the formalization of tropical spectral exponent recovery. Each direction includes a precise mathematical statement, a proof strategy, cross-domain connections, and justification for why it would constitute a breakthrough.

---

## 1. Maximum Cycle Mean Equals Tropical Eigenvalue for Finite Matrices

### Statement
Let $G$ be an $m \times m$ tropical matrix (min-plus or max-plus) over $\mathbb{R} \cup \{+\infty\}$. Define the **maximum cycle mean** as:
$$\lambda^*(G) = \max_{k=1}^{m} \max_{i_1, \ldots, i_k \text{ distinct}} \frac{G_{i_1 i_2} + G_{i_2 i_3} + \cdots + G_{i_k i_1}}{k}$$
Then the tropical eigenvalue (the value $\lambda$ such that $G \otimes v = \lambda \odot v$ for some finite eigenvector $v$) equals $\lambda^*(G)$ when $G$ is irreducible.

### Proof Strategy
1. Formalize weighted directed graphs and cycle weights as `Finset.sum` over cycle indices.
2. Define irreducibility as strong connectivity of the support graph.
3. Prove the lower bound: for any cycle of mean $\mu$, iterating the cycle shows $(G^n)_{ii} \geq n\mu$ for vertices on the cycle.
4. Prove the upper bound: any path of length $n$ can be decomposed into cycles plus a bounded acyclic remainder, giving $(G^n)_{ij} \leq n\lambda^* + C$.
5. Extract the eigenvalue from the limit $\lim_{n\to\infty} (G^n)_{ii}/n = \lambda^*$.

### Cross-Domain Connections
- **Graph algorithms**: This is Karp's theorem (1978), connecting tropical eigenvalues to the minimum/maximum mean cycle problem solvable in $O(mn)$ time.
- **Control theory**: In max-plus linear systems $x(k+1) = G \otimes x(k)$, the cycle mean determines the asymptotic throughput.
- **Cryptanalysis**: Computing the cycle mean gives an efficient algorithm for the eigenvalue, which is the first step in the spectral attack.

### Why Breakthrough
This would be the first formalization of the Cuninghame-Green / Karp cycle mean theorem in any proof assistant, establishing a verified bridge between combinatorial graph algorithms and tropical spectral theory.

---

## 2. Eventual Periodic Affine Diagonal Growth for Irreducible Tropical Matrices

### Statement
Let $G$ be an irreducible $m \times m$ tropical matrix with tropical eigenvalue $\lambda$. Then for each index $i$, there exist constants $c_i \in \mathbb{R}$, a period $p \in \mathbb{N}^+$, and a threshold $N \in \mathbb{N}$ such that:
$$\forall n \geq N,\quad (G^n)_{ii} = n\lambda + c_i + \pi_i(n)$$
where $\pi_i$ is periodic with period $p$ dividing the cyclicity of $G$.

In the **critical** case (when $i$ lies on a critical cycle), $\pi_i = 0$ and:
$$\forall n \geq N,\quad (G^n)_{ii} = n\lambda + c_i$$

### Proof Strategy
1. Build on Direction 1 by establishing the eigenvalue.
2. Formalize the critical graph as the subgraph of edges achieving the maximum cycle mean.
3. Prove the CSR (Critical-to-Supercritical Reduction) decomposition: separate $G$ into its critical and non-critical components.
4. Show that tropical powers on critical vertices stabilize to the affine law using the fact that optimal paths eventually use only critical edges.
5. For general vertices, prove the periodic correction term by analyzing the cyclicity of the critical graph.

### Cross-Domain Connections
- **Discrete-event systems**: The eventual periodicity is the mathematical foundation of steady-state analysis in manufacturing, scheduling, and railway timetabling.
- **Automata theory**: The periodic structure connects to the star height problem and the Burnside property of max-plus matrix semigroups.
- **Cryptanalysis**: The periodic correction term introduces a bounded ambiguity in exponent recovery, but the dominant linear term still leaks the exponent modulo the cyclicity.

### Why Breakthrough
This is the full Cuninghame-Green theorem (1962/1979), a cornerstone of max-plus algebra that has never been formalized. It would establish verified foundations for the entire field of tropical dynamical systems.

---

## 3. Polynomial-Time Exponent Recovery Algorithm from Diagonal Observations

### Statement
Given:
- An observable diagonal entry $d = (G^a)_{ii}$ of an unknown tropical matrix power,
- The tropical eigenvalue $\lambda$ (computable in $O(mn)$ time via Karp's algorithm),
- The offset $c_i$ and period $p$ (computable from the critical graph),

there exists a polynomial-time algorithm that returns the finite set of candidate exponents:
$$\mathcal{A} = \left\{ n \in \mathbb{N} : n \geq N,\ n\lambda + c_i + \pi_i(n) = d \right\}$$
and $|\mathcal{A}| \leq p$. In the critical case ($p = 1$), the exponent is uniquely determined:
$$a = \frac{d - c_i}{\lambda}$$

### Proof Strategy
1. Formalize the algorithm as a Lean function returning `Finset ℕ`.
2. Prove soundness: every returned candidate satisfies the diagonal equation.
3. Prove completeness: every valid exponent appears in the output.
4. Prove the complexity bound by analyzing the loop over residues modulo $p$.
5. For the critical case, prove uniqueness using `affine_diag_exponent_unique` from our formalization.

### Cross-Domain Connections
- **Cryptanalysis**: This is a concrete attack algorithm. Given a tropical one-way function $f(a) = (G^a)_{ii}$, the algorithm inverts $f$ in polynomial time, breaking any scheme relying on the hardness of tropical discrete logarithm.
- **Signal processing**: The algorithm can be viewed as a spectral demodulator for max-plus signals.
- **Complexity theory**: The polynomial-time invertibility contrasts with the (conjectured) hardness of tropical discrete logarithm in the non-diagonal case, suggesting a phase transition in tropical computational complexity.

### Why Breakthrough
This would be the first formally verified cryptanalytic algorithm in tropical algebra, with rigorous soundness and completeness proofs. It demonstrates that tropical spectral leakage is algorithmically exploitable.

---

## 4. Tropical Spectral Leakage in Weighted Automata Identification

### Statement
Let $\mathcal{A} = (Q, \Sigma, \delta, w, q_0, F)$ be a weighted automaton over the max-plus semiring with transition weight matrix $G_\sigma$ for each input symbol $\sigma$. For a unary alphabet ($|\Sigma| = 1$), the weight of the unique word of length $n$ is:
$$w(a^n) = \alpha^T \otimes G^n \otimes \beta$$
where $\alpha, \beta$ are initial/final weight vectors.

**Theorem**: If $G$ is irreducible with tropical eigenvalue $\lambda \neq 0$, then the sequence $\{w(a^n)\}_{n \geq 1}$ eventually satisfies:
$$w(a^n) = n\lambda + C + \rho(n)$$
with $\rho$ periodic, and the triple $(\lambda, C, \rho)$ is recoverable from $O(m^2)$ observations of $w(a^n)$.

### Proof Strategy
1. Reduce to the matrix power case using the bilinear form $\alpha^T G^n \beta$.
2. Apply the eventual periodicity theorem (Direction 2) to the matrix entries.
3. Show that the bilinear form inherits the affine-plus-periodic structure.
4. Prove the identification bound $O(m^2)$ by showing that $m^2$ consecutive observations determine the $m^2$ matrix entries up to tropical gauge equivalence.

### Cross-Domain Connections
- **Formal language theory**: Connects tropical spectral theory to the Myhill-Nerode theorem for weighted languages.
- **Machine learning**: Weighted automata are used in speech recognition, natural language processing, and sequence modeling. Spectral identification enables learning these models from output observations.
- **Systems biology**: Gene regulatory networks modeled as max-plus automata can be identified from time-series data using the spectral fingerprint.

### Why Breakthrough
This would establish a formal bridge between tropical spectral theory and automata identification, opening a new verified approach to the weighted automata learning problem.

---

## 5. Tropical Spectral Rigidity: Eigenvalue Determines Exponent Class

### Statement (Tropical Spectral Rigidity Principle)
Let $\mathcal{C}$ be the class of irreducible tropical matrices with tropical eigenvalue $\lambda$ and cyclicity $p$. Define the **spectral equivalence** relation: $G_1 \sim_s G_2$ if and only if $(G_1^n)_{ii} = (G_2^n)_{ii}$ for all $i$ and all sufficiently large $n$.

**Conjecture**: $G_1 \sim_s G_2$ if and only if $G_1$ and $G_2$ have:
1. The same tropical eigenvalue $\lambda$,
2. The same cyclicity $p$,
3. The same critical graph structure (up to isomorphism),
4. The same offset vector $(c_1, \ldots, c_m)$.

In particular, the diagonal power sequence of an irreducible tropical matrix is determined (up to finite initial transient) by a finite set of spectral invariants.

### Proof Strategy
1. Prove the forward direction using the eventual affine-periodic characterization.
2. For the backward direction, construct matrices achieving given spectral invariants using the CSR decomposition.
3. Show that the spectral invariants form a complete invariant system for diagonal power equivalence.
4. Connect to the existing catalog theorem `tropical_eigenvalue_determines_char` by showing that character determination is a special case of spectral rigidity.

### Cross-Domain Connections
- **Representation theory**: This is a tropical analogue of the spectral theorem for normal operators, and connects to the tropical Langlands program.
- **Cryptanalysis**: Spectral rigidity implies that tropical matrix-based cryptosystems leak their entire spectral invariant structure, not just the eigenvalue.
- **Dynamical systems**: Spectral rigidity for tropical matrices parallels the marked length spectrum rigidity for Riemannian manifolds, suggesting deep geometric connections.

### Why Breakthrough
This would be a fundamental structure theorem for tropical matrix semigroups, analogous to the spectral theorem in classical linear algebra. It would show that tropical matrices are "spectrally transparent" — their asymptotic behavior is completely determined by a finite, efficiently computable set of invariants. This has profound implications for both cryptanalysis (tropical systems cannot hide structure) and systems theory (tropical dynamical systems are identifiable from observations).

---

## Research Team Directive

Each direction above is designed to be pursued independently, with the following workflow:
1. **Hypothesis**: State the precise mathematical claim.
2. **Computational validation**: Test with concrete examples using the Python demos.
3. **Lean skeleton**: Write the theorem statement and helper lemma statements with `sorry`.
4. **Bottom-up proof**: Prove helper lemmas from simplest to hardest.
5. **Integration**: Connect to existing formalized results.
6. **Documentation**: Write research paper sections and update this roadmap.

Directions 1 and 3 are the most immediately actionable, building directly on the scalar diagonal results formalized in `SpectralCryptanalysis.lean`. Direction 2 is the deepest mathematical challenge. Directions 4 and 5 are the most conceptually ambitious, opening new fields of tropical spectral identification and rigidity.
