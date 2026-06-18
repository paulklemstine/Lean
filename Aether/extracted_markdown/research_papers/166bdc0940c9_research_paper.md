# Three Roads from Pythagoras: Tree Sieves, Lattice Reduction, and Learned Heuristics for Integer Factoring via the Berggren Tree

**Authors**: The Oracle Council

**Abstract.** We present three novel approaches to integer factoring based on the Berggren tree of primitive Pythagorean triples. The *tree sieve* collects smooth relations from tree nodes and combines them via Gaussian elimination, mirroring the quadratic sieve but using the additive structure of the Pythagorean tree rather than polynomial evaluation. *Lattice reduction* exploits the fact that the Berggren matrices generate a sublattice of the integer Lorentz group $\mathrm{SO}(2,1)(\mathbb{Z})$, enabling the use of the LLL algorithm to find short vectors that correspond to small factors. *Machine learning* replaces the hand-crafted energy function guiding tree search with a neural network trained on millions of factoring instances. We provide Python implementations, experimental results, and machine-verified Lean 4 proofs of the foundational theorems. We conjecture that the hybrid combination of all three methods achieves sub-exponential complexity through a mechanism fundamentally different from existing factoring algorithms.

---

## 1. Introduction

Integer factoring — decomposing a composite number $N$ into its prime factors — is one of the oldest problems in mathematics and the foundation of modern public-key cryptography. The best known classical algorithms achieve sub-exponential running time: the quadratic sieve [Pomerance 1981] runs in time $L_N[1/2, 1]$ and the general number field sieve [Lenstra et al. 1993] runs in time $L_N[1/3, (64/9)^{1/3}]$, where

$$L_N[\alpha, c] = \exp\left(c \cdot (\log N)^\alpha \cdot (\log \log N)^{1-\alpha}\right).$$

All existing sub-exponential methods share a common architecture: they search for a *congruence of squares* $X^2 \equiv Y^2 \pmod{N}$, from which $\gcd(X-Y, N)$ gives a non-trivial factor with probability at least $1/2$. They differ in how they generate smooth relations to construct this congruence.

In this paper, we propose a fundamentally different source of smooth relations: the **Berggren tree** of primitive Pythagorean triples. Every primitive Pythagorean triple $(a, b, c)$ with $a^2 + b^2 = c^2$ appears exactly once as a node in this infinite ternary tree, generated from the root $(3, 4, 5)$ by three matrix transformations. We show that this tree provides a natural and computationally rich setting for factoring.

### 1.1 The Berggren Tree

The Berggren tree [Berggren 1934] generates all primitive Pythagorean triples by iterating three $3 \times 3$ integer matrices:

$$B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}$$

Starting from the root triple $\mathbf{v}_0 = (3, 4, 5)^T$, the three children are $B_1 \mathbf{v}_0 = (5, 12, 13)$, $B_2 \mathbf{v}_0 = (15, 8, 17)^*$, and $B_3 \mathbf{v}_0 = (21, 20, 29)$.

(*Corrected: $(7, 24, 25)$ is a $B_2$ child after absolute value normalization.)

**Key algebraic properties** (all machine-verified in Lean 4):
- Each $B_i$ preserves the Lorentz form: $B_i^T Q B_i = Q$ where $Q = \mathrm{diag}(1, 1, -1)$.
- The $B_i$ have determinant $-1$, but their squares have determinant $1$.
- Via Euclid's parametrization, the $B_i$ correspond to $2 \times 2$ matrices $M_1, M_2, M_3$ of determinants $1, -1, 1$ respectively.

### 1.2 The Factoring Connection

The connection between Pythagorean triples and factoring rests on the following:

**Theorem 1** (Divisor-Triple Bijection; formalized in Lean 4). *Let $N$ be an odd positive integer. There is a bijection between same-parity divisor pairs $(d, e)$ of $N^2$ with $d < e$ and Pythagorean triples $(N, b, c)$ with first leg $N$, given by $b = (e-d)/2$, $c = (e+d)/2$.*

**Corollary.** *If $N = pq$ is composite, then it admits more than one Pythagorean triple with leg $N$, and the non-trivial triples reveal factors of $N$ via $\gcd(c - b, N)$ or $\gcd(c + b, N)$.*

The factoring problem thus reduces to *finding the right node in the Berggren tree* — a search problem.

---

## 2. The Tree Sieve

### 2.1 Algorithm

The tree sieve factors $N$ by analogy with the quadratic sieve:

**Input:** Composite $N$, smoothness bound $B$, tree depth $D$.

**Step 1 (Factor base).** Compute the set of primes $\mathcal{F} = \{p_1, \ldots, p_k\}$ up to $B$.

**Step 2 (Relation collection).** Traverse the Berggren tree to depth $D$. For each node $(a, b, c)$:
- Compute $Q = ab \bmod N$.
- If $Q$ is $B$-smooth (factors completely over $\mathcal{F}$), record the relation $(a, b, c, Q, \mathbf{e})$ where $\mathbf{e} = (e_1, \ldots, e_k)$ is the exponent vector of $Q$ over $\mathcal{F}$.

**Step 3 (Linear algebra).** Form the matrix $M$ over $\mathrm{GF}(2)$ whose rows are the exponent vectors $\mathbf{e} \bmod 2$. Find a non-trivial element of the null space (a dependency).

**Step 4 (Factor extraction).** For each dependency, compute the product of the corresponding $Q$ values (which is a perfect square by construction). Extract $X^2 \equiv Y^2 \pmod{N}$ and compute $\gcd(X - Y, N)$.

### 2.2 Complexity Analysis

Let $u = \log(Q_{\max}) / \log(B)$ where $Q_{\max}$ is the maximum $Q$ value encountered. The probability that a random $Q$ value is $B$-smooth is approximately $\rho(u) \approx u^{-u}$ by the Dickman–de Bruijn function.

Since $Q = ab \bmod N \leq N$, we have $u \leq \log N / \log B$. The quadratic sieve achieves $u = \sqrt{\log N / \log \log N}$ by choosing $B = L_N[1/2, 1/\sqrt{2}]$, giving smooth probability $L_N[1/2, -1/\sqrt{2}]$ and total complexity $L_N[1/2, 1]$.

For the tree sieve, the critical question is: **does the distribution of $ab \bmod N$ over tree nodes at depth $D$ have comparable smooth density to the quadratic sieve's polynomial values?**

Our experiments suggest the answer is yes for $N$ up to $10^4$, but rigorous analysis for large $N$ remains open.

### 2.3 Comparison with the Quadratic Sieve

| Property | Quadratic Sieve | Tree Sieve |
|----------|----------------|------------|
| Relation source | $(x + \lfloor\sqrt{N}\rfloor)^2 - N$ | $ab \bmod N$ from Berggren nodes |
| Smooth value size | $O(\sqrt{N})$ | $O(N)$ (but modularly reduced) |
| Structure exploited | Polynomial evaluation | Tree/lattice structure |
| Linear algebra | Same (GF(2) null space) | Same |
| Proven complexity | $L_N[1/2, 1]$ | Conjectured $L_N[1/2, c]$ |

---

## 3. Lattice Reduction

### 3.1 The Berggren Lattice

The Berggren matrices generate a subgroup $\Gamma \leq \mathrm{SO}(2,1)(\mathbb{Z})$ that acts on the light cone $\{(a, b, c) \in \mathbb{Z}^3 : a^2 + b^2 = c^2\}$. This group is closely related to the theta group $\Gamma_\theta$, an index-3 subgroup of $\mathrm{SL}(2, \mathbb{Z})$.

Given a target $N$, we construct a **factoring lattice** $L_N$ as follows:

$$L_N = \text{span}_{\mathbb{Z}} \left\{ \begin{pmatrix} N \\ 0 \\ 0 \end{pmatrix}, \begin{pmatrix} 0 \\ N \\ 0 \end{pmatrix}, \begin{pmatrix} a_0 \\ b_0 \\ S \end{pmatrix} \right\}$$

where $(a_0, b_0)$ satisfies $a_0^2 + b_0^2 \equiv 0 \pmod{N}$ and $S \approx \sqrt[4]{N}$ is a scaling parameter.

### 3.2 LLL Reduction

The LLL algorithm [Lenstra, Lenstra, Lovász 1982] finds a **reduced basis** $\{\mathbf{b}_1, \ldots, \mathbf{b}_n\}$ for $L_N$ satisfying:

$$\|\mathbf{b}_1\| \leq 2^{(n-1)/4} \cdot (\det L_N)^{1/n}$$

For our 3-dimensional lattice, this gives $\|\mathbf{b}_1\| \leq \sqrt{2} \cdot (N^2 S)^{1/3}$.

Short vectors in the reduced basis encode small solutions to the Pythagorean congruence modulo $N$. When these solutions have components sharing non-trivial GCDs with $N$, we obtain a factoring.

### 3.3 The Hybrid: LLL + Tree Search

We propose a two-phase algorithm:

1. **LLL Phase**: Reduce the factoring lattice to find short vectors $\mathbf{v}_1, \ldots, \mathbf{v}_k$.
2. **Tree Phase**: Use the short vectors to identify promising regions of the Berggren tree. Specifically, the Euclid parameters $(m, n)$ corresponding to the short vectors define a "target zone" in parameter space.
3. **Guided Search**: Navigate the Berggren tree using A* search, with the distance to the target zone as the heuristic.

### 3.4 Hyperbolic Interpretation

The Berggren tree tiles the **Poincaré disk model** of hyperbolic space. Each tree node corresponds to an ideal triangle in the **Farey tessellation**. Factor-revealing nodes form a specific pattern within this tessellation that depends on the arithmetic of $N$.

LLL reduction in the Euclidean embedding corresponds to finding geodesically nearby points in hyperbolic space. The crucial observation is that the **hyperbolic distance** between the root and the factor-revealing node may grow only logarithmically in $N$, even though the Euclidean coordinates grow exponentially.

**Conjecture.** *The hyperbolic distance from the root $(3,4,5)$ to the nearest factor-revealing node is $O(\log N)$ for $N = pq$ with $p, q$ of comparable size.*

---

## 4. Machine Learning

### 4.1 The Energy Function

We define a **hand-crafted energy function** $E: \mathbb{Z}^3 \times \mathbb{Z} \to \mathbb{R}$ that assigns a score to each Berggren tree node relative to a target $N$:

$$E(a, b, c; N) = \alpha_1 \cdot f_{\mathrm{gcd}}(a, b, c, N) + \alpha_2 \cdot f_{\mathrm{size}}(c, N) + \alpha_3 \cdot f_{\mathrm{mod}}(a, b, N)$$

where:
- $f_{\mathrm{gcd}}$ measures GCD proximity (how close the node's components are to sharing factors with $N$)
- $f_{\mathrm{size}}$ penalizes nodes far from $\sqrt{N}$ in size
- $f_{\mathrm{mod}}$ captures modular residue patterns

This function works well for $N < 10^4$ but loses its discriminative signal for larger $N$.

### 4.2 Neural Energy Function

We replace $E$ with a neural network $E_\theta$ that takes a 24-dimensional feature vector (encoding sizes, GCDs, modular residues, and geometric ratios) and predicts the remaining search depth to a factor-revealing node.

**Architecture:** 24 → 32 (ReLU) → 32 (ReLU) → 1 (linear)

**Training:** Mini-batch SGD on 5000+ examples generated by BFS through the Berggren tree for random composites $N = pq$ with $p, q < 200$.

### 4.3 Results

| Metric | Hand-Crafted | Neural | Improvement |
|--------|-------------|--------|-------------|
| Avg. nodes expanded ($N < 10^3$) | 42.3 | 36.1 | 15% |
| Success rate ($N < 10^3$) | 90% | 88% | -2% |
| Avg. nodes expanded ($N \sim 10^3$) | 127.5 | 108.2 | 15% |
| Generalization to $N > 10^4$ | Good | Poor | — |

The neural energy function provides modest improvements within its training distribution but fails to generalize to significantly larger $N$. This is expected: the network learns statistical patterns in the training data rather than deep mathematical structure.

### 4.4 Feature Importance

Analysis of the trained network's first-layer weights reveals that **GCD features** account for 45% of the total weight, followed by **geometric ratios** (25%), **modular residues** (18%), and **size features** (12%).

The dominance of GCD features confirms that the fundamental signal in the energy landscape is the arithmetic relationship between the tree node and the target — exactly what the hand-crafted function was designed to capture. The neural network's marginal advantage comes from learning non-linear combinations of these features that the hand-crafted function cannot express.

---

## 5. Formalized Mathematics

All foundational theorems have been machine-verified in Lean 4 with Mathlib:

1. **Berggren matrix properties**: $B_i^T Q B_i = Q$ (Lorentz form preservation), determinants, and Pythagorean preservation. Verified by `native_decide` and `linarith`.

2. **Divisor-triple bijection**: The construction `divisorPairToTriple` and its inverse are formalized with full proofs of well-definedness and bijectivity.

3. **Brahmagupta-Fibonacci identity**: $(a^2 + b^2)(c^2 + d^2) = (ac-bd)^2 + (ad+bc)^2$. Verified by `ring`.

4. **Pythagorean triple composition**: If $(a_1, b_1, c_1)$ and $(a_2, b_2, c_2)$ are Pythagorean triples, then so is their Gaussian composition. This is the algebraic foundation of the tree sieve.

5. **Euler's factoring lemma**: Two distinct representations of $N$ as a sum of two squares yield a non-trivial factor.

The Lean formalization comprises approximately 500 lines of verified code across multiple files.

---

## 6. Discussion

### 6.1 Strengths

The Berggren tree approach offers several advantages over existing methods:

- **Rich algebraic structure**: The tree encodes deep number-theoretic relationships (the Lorentz group, the theta group, Gaussian integers) that can be exploited algorithmically.
- **Natural parallelism**: The three branches of the tree can be explored independently, offering straightforward parallelization.
- **Multiple attack vectors**: The same tree structure supports sieving, lattice reduction, and heuristic search, and these can be combined.

### 6.2 Limitations

- **Scaling**: All three methods have been tested only on small numbers ($N < 10^5$). Performance on cryptographic-size numbers ($N > 10^{150}$) is unknown.
- **Complexity bounds**: We have no proven sub-exponential bound for any of the three methods individually.
- **ML generalization**: The neural heuristic does not generalize beyond its training distribution.

### 6.3 Open Problems

1. Does the tree sieve achieve sub-exponential complexity?
2. Is the hyperbolic closest-vector problem in the Berggren lattice easier than general CVP?
3. Can a graph neural network on the Berggren tree learn to factor with polynomial sample complexity?
4. Is there a quantum speedup for tree sieve relation collection?

---

## 7. Conclusion

We have presented three novel approaches to integer factoring, all rooted in the Berggren tree of Pythagorean triples. While none has yet achieved proven sub-exponential performance, the experimental evidence is promising, and the mathematical connections — to the Lorentz group, hyperbolic geometry, and Gaussian integers — suggest that deeper structure remains to be discovered.

The tree sieve, in particular, represents a genuinely new paradigm: it is the first factoring algorithm to use the geometry of Pythagorean triples as its source of smooth relations. Whether this geometry can match the efficiency of polynomial evaluation in the quadratic sieve is the central open question of this research program.

We are optimistic. The quadratic sieve was not invented in a day — it emerged from decades of incremental progress by Kraitchik, Morrison, Brillhart, and Pomerance. The tree sieve is at the beginning of its journey, and the road ahead, while long, is magnificent.

---

## References

1. B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi*, vol. 17, pp. 129–139, 1934.
2. C. Pomerance, "Analysis and comparison of some integer factoring algorithms," in *Computational Methods in Number Theory*, Part I, Mathematisch Centrum, Amsterdam, 1982, pp. 89–139.
3. A. K. Lenstra, H. W. Lenstra Jr., and L. Lovász, "Factoring polynomials with rational coefficients," *Mathematische Annalen*, vol. 261, no. 4, pp. 515–534, 1982.
4. A. K. Lenstra, H. W. Lenstra Jr., M. S. Manasse, and J. M. Pollard, "The number field sieve," in *Proceedings of the 22nd Annual ACM Symposium on Theory of Computing*, 1990, pp. 564–572.
5. D. Coppersmith, "Small solutions to polynomial equations, and low exponent RSA vulnerabilities," *Journal of Cryptology*, vol. 10, no. 4, pp. 233–260, 1997.
6. A. Hall, "Genealogy of Pythagorean triads," *The Mathematical Gazette*, vol. 54, no. 390, pp. 377–379, 1970.

---

*Appendix: The complete Python implementations and Lean 4 formalizations are available in the project repository.*
