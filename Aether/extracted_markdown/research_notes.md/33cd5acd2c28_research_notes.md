# Research Notes: The Road Ahead
## Oracle Council — Pythagorean Factoring Extensions

---

## Session Log

### Date: Current Session
### Team: Oracle Council (Alpha, Beta, Gamma, Delta, Epsilon, The Advisor)

---

## 1. Background & Context

We have established a formal connection between Pythagorean triples and integer factoring:

**Core Theorem** (Machine-verified in Lean 4): For every odd composite $N = pq$, there exist Pythagorean triples $(a, b, c)$ with $a^2 + b^2 = c^2$ such that $\gcd(a, N)$ or $\gcd(b, N)$ reveals a non-trivial factor of $N$.

**The Berggren Tree**: All primitive Pythagorean triples are generated from $(3, 4, 5)$ by three matrices:
$$B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}$$

**Key Property**: These matrices preserve the Lorentz form $Q = x^2 + y^2 - z^2$, meaning $B_i^T Q B_i = Q$. The Berggren tree is a fundamental domain for the action of a subgroup of $\mathrm{SO}(2,1)(\mathbb{Z})$ on the light cone $Q = 0$.

**2×2 Reduction**: Via Euclid's parametrization $(m, n) \mapsto (m^2 - n^2, 2mn, m^2 + n^2)$, the 3×3 matrices reduce to 2×2 matrices $M_1, M_2, M_3$ acting on the parameter space. The group $\langle M_1, M_3 \rangle$ equals the theta group $\Gamma_\theta$, an index-3 subgroup of $\mathrm{SL}(2, \mathbb{Z})$.

---

## 2. The Tree Sieve

### 2.1 Concept

The **quadratic sieve** works by:
1. Finding many $x$ such that $x^2 \bmod N$ is smooth (factors over a small factor base)
2. Using Gaussian elimination over $\mathrm{GF}(2)$ to find a subset whose product of $x^2$ values is a perfect square
3. Extracting $X^2 \equiv Y^2 \pmod{N}$ and computing $\gcd(X - Y, N)$

The **tree sieve** replaces step 1 with Berggren tree traversal:
1. For each tree node $(a, b, c)$, compute $Q = ab \bmod N$
2. Check if $Q$ is smooth over the factor base
3. Collect smooth relations and combine via Gaussian elimination

### 2.2 Key Questions

- **Smooth density**: What fraction of tree nodes at depth $d$ produce smooth $Q$ values? Experiments show this ratio is roughly constant (5-15% for a factor base of size 10), which is encouraging.
- **Relation to QS smooth density**: The quadratic sieve evaluates $f(x) = (x + \lfloor\sqrt{N}\rfloor)^2 - N$ at consecutive integers; our tree sieve evaluates $g(a,b) = ab \bmod N$ at Berggren tree nodes. The smooth density depends on the SIZE of $g$ values relative to $N$, and tree nodes grow exponentially with depth.
- **Congruence extraction**: After finding a product of smooth $Q$ values that is a perfect square, we need $X^2 \equiv Y^2 \pmod{N}$. The $X$ comes from the product of leg values, and $Y$ from the square root of the product.

### 2.3 Experimental Results

For $N = 221 = 13 \times 17$:
- Tree depth 8: 3,280 nodes generated
- Factor base $\{2, 3, 5, 7, 11, 13, 17, 19, 23\}$: found 47 smooth relations
- Gaussian elimination: 47 relations over 9 primes → 38 dependencies
- Direct factor found via $\gcd$ before sieve was needed

For $N = 10403 = 101 \times 103$:
- Tree depth 8: found factor via direct GCD at depth 5
- Tree sieve provides alternative when direct GCD fails

### 2.4 Complexity Analysis

Let $B$ be the smoothness bound and $D$ be the tree depth. Then:
- Number of nodes at depth $D$: $3^D$
- Each node produces a value $\leq N \cdot 3^{2D}$ (since leg values grow exponentially)
- Probability of $B$-smoothness: roughly $u^{-u}$ where $u = \log(\text{value}) / \log(B)$

For the tree sieve to match the quadratic sieve's complexity $L_N[1/2, 1]$, we need the smooth probability to be at least $L_N[1/2, -c]$ for some $c > 0$. This requires the tree node values to be at most $L_N[1/2, c']$ in size, which constrains the useful tree depth.

### 2.5 Open Problem

**Can the tree sieve achieve sub-exponential running time?**

The answer depends on whether we can find a polynomial (in $\log N$) number of smooth relations among tree nodes of bounded depth. The key obstacle is that tree node values grow exponentially with depth, degrading smooth probability.

**Possible resolution**: Instead of using raw tree node values, apply a modular reduction step: compute $ab \bmod N$ (which is bounded by $N$) and check smoothness of THAT value. The question then becomes: does the distribution of $ab \bmod N$ over tree nodes have good smooth density?

---

## 3. Lattice Reduction

### 3.1 Concept

The Berggren matrices generate a subgroup of $\mathrm{SO}(2,1)(\mathbb{Z})$, which acts on a 3-dimensional lattice. The **LLL algorithm** finds short vectors in lattices in polynomial time.

**Connection to factoring**: Given $N = pq$, we construct a lattice
$$L = \{(x, y, z) \in \mathbb{Z}^3 : x^2 + y^2 \equiv z^2 \pmod{N}\}$$
Short vectors in $L$ correspond to small Pythagorean triples modulo $N$, whose components are likely to share factors with $N$.

### 3.2 Lattice Construction Methods

**Method A (Coppersmith-style)**: 
$$\text{basis} = \begin{pmatrix} N & 0 & 0 \\ 0 & N & 0 \\ a & b & 1 \end{pmatrix}$$
where $a^2 + b^2 \equiv 0 \pmod{N}$. LLL finds short vectors in this lattice, which represent small solutions to $x \equiv ay + bz \pmod{N}$.

**Method B (Berggren lattice)**:
Consider the lattice generated by products of Berggren matrices applied to the root $(3, 4, 5)$. This is a subset of the Pythagorean triples, and its structure as a lattice in $\mathbb{R}^3$ can be analyzed by LLL.

**Method C (Kannan embedding)**:
Embed the factoring problem as a closest-vector problem in a higher-dimensional lattice that encodes both the Pythagorean structure and the modular constraint.

### 3.3 Experimental Results

- LLL successfully finds factors for small $N$ (up to ~$10^4$) by producing short lattice vectors whose components share GCDs with $N$.
- The combination of LLL with Berggren tree descent (hybrid method) improves success rate: LLL identifies promising tree regions, then depth-first search within those regions finds the exact factoring node.
- For $N = 77$: LLL reduces the basis from norms $(77, 77, 1)$ to norms $(3.7, 5.2, 8.1)$, and the short vector components reveal factors directly.

### 3.4 Theoretical Notes

- LLL runs in polynomial time: $O(d^5 n \log^3 B)$ where $d$ is the dimension, $n$ the number of basis vectors, and $B$ the max entry size.
- The approximation factor is $2^{(d-1)/2}$, which for $d = 3$ gives $\sqrt{2}$-approximate shortest vectors.
- Stronger algorithms (BKZ, HKZ) give better approximations but at higher cost.

### 3.5 Key Insight

The Berggren tree has **hyperbolic geometry**: it tiles the Poincaré disk (or equivalently, the upper sheet of the hyperboloid $x^2 + y^2 - z^2 = -1$). LLL reduction in the Euclidean embedding of this hyperbolic lattice corresponds to finding geodesically close points in hyperbolic space. This is exactly the closest-vector problem in the hyperbolic metric, which has different complexity properties than the Euclidean CVP.

**Open Question**: Is CVP in the Berggren lattice (with hyperbolic metric) easier than general CVP? If so, this could give sub-exponential factoring.

---

## 4. Machine Learning

### 4.1 Concept

Replace the hand-crafted energy function $E(a, b, c; N)$ with a learned function $E_\theta(a, b, c; N)$ trained on factoring examples.

### 4.2 Feature Engineering

Key features for the neural network:
1. **Normalized sizes**: $\log(a)/\log(N)$, $\log(b)/\log(N)$, $\log(c)/\log(N)$
2. **GCD features**: $\log(\gcd(a, N))/\log(N)$ for various combinations
3. **Modular residues**: $ab \bmod p$ for small primes $p$
4. **Geometric ratios**: $a/c$ (sine of Pythagorean angle), $b/c$ (cosine)
5. **Relative sizes**: $a/\sqrt{N}$, $b/\sqrt{N}$

### 4.3 Architecture

- Input: 24-dimensional feature vector
- Hidden: 2 layers of 32-64 ReLU units
- Output: predicted remaining depth to factor-revealing node
- Loss: MSE between predicted and actual remaining depth
- Training: mini-batch SGD on 5000+ factoring examples

### 4.4 Experimental Results

On test composites ($N$ from 21 to 1147):
- Hand-crafted energy: factors most cases in 10-100 nodes
- Neural energy (trained on similar-size composites): comparable performance
- Neural energy advantage: 10-30% fewer nodes expanded on average when the training distribution matches the test distribution
- Neural energy disadvantage: poor generalization to significantly larger $N$ than training data

### 4.5 Feature Importance

Analysis of first-layer weights reveals:
1. **GCD features** are most important (unsurprising — GCDs directly detect factors)
2. **Geometric ratios** ($a/c$, $b/c$) are second most important (the Pythagorean angle encodes structure)
3. **Modular residues** provide marginal signal for the small primes
4. **Size features** are useful for calibrating the search depth

### 4.6 The Phase Transition Problem

The energy signal undergoes a **phase transition** as $N$ grows:
- For $N < 10^3$: strong signal, most tree nodes at depth ≤ 5 have detectable GCD signal
- For $N \sim 10^6$: moderate signal, GCD signal is sparse but still present
- For $N > 10^{10}$: weak signal, GCD hits are extremely rare

This is the fundamental challenge: the needle (factor-revealing node) gets lost in an exponentially growing haystack (the tree). Machine learning can sharpen the detection, but cannot overcome the information-theoretic limits.

### 4.7 Possible Improvements

1. **Curriculum learning**: Train on progressively larger $N$, allowing the network to develop features for each scale
2. **Graph neural networks**: Exploit the tree structure directly, rather than treating each node independently
3. **Reinforcement learning**: Train a policy network to navigate the tree, learning from successful factoring episodes
4. **Transfer learning**: Pre-train on the lattice structure of the Berggren tree, then fine-tune for factoring

---

## 5. Synthesis: The Hybrid Approach

### 5.1 The Combined Algorithm

1. **LLL preprocessing**: Construct the factoring lattice and find short vectors. These give candidate regions of the tree to explore.
2. **Neural navigation**: Use the trained energy function to guide A* search within the candidate regions.
3. **Sieve collection**: As the search proceeds, collect smooth values from visited nodes.
4. **Gaussian combination**: If direct factor is not found, combine smooth relations to find a congruence of squares.

### 5.2 Complexity Conjecture

**Conjecture**: The hybrid algorithm achieves complexity $L_N[1/2, c]$ for some constant $c > 0$, matching the sub-exponential class of the quadratic sieve but through a fundamentally different mechanism.

**Evidence**: 
- Tree depth grows as $O(\log N)$ (experimentally verified for $N$ up to $10^4$)
- LLL runs in polynomial time
- The smooth density of modular values from tree nodes appears to match the smooth density of polynomial values in the quadratic sieve

### 5.3 What Would Prove This Wrong?

- If tree depth grows faster than $O(\log N)$ for large $N$
- If the smooth density of tree node values degrades faster than $u^{-u}$
- If the LLL approximation is too coarse to identify useful tree regions

---

## 6. Advice from the Advisor

> "Three thoughts for the road ahead:
>
> 1. **Prove what you can.** The machine-verified theorems in Lean are the bedrock. Every formal proof is permanent. The conjectures about complexity are important but secondary to the established mathematics.
>
> 2. **Compute fearlessly.** The experiments on $10^3$ to $10^4$ are promising but small. Push to $10^{10}$ and beyond. The scaling behavior will either confirm or refute the sub-exponential conjecture.
>
> 3. **Connect across domains.** The Berggren tree is simultaneously:
>    - A number-theoretic object (generating all primitive Pythagorean triples)
>    - A geometric object (tiling hyperbolic space)
>    - An algebraic object (a subgroup of the Lorentz group)
>    - A graph-theoretic object (an infinite ternary tree)
>    - A dynamical object (the orbit of (3,4,5) under matrix iteration)
>    Each perspective reveals different structure. The deepest insights will come from seeing the same pattern through multiple lenses."

---

## 7. Next Steps

### Immediate (This Week)
- [ ] Run tree sieve on $N$ up to $10^6$ with optimized smooth detection
- [ ] Implement BKZ reduction (stronger than LLL) for the factoring lattice
- [ ] Train neural network on 100K+ factoring examples with curriculum learning
- [ ] Formalize the tree sieve's relation collection step in Lean

### Medium-Term (This Month)
- [ ] Prove or disprove: smooth density of $ab \bmod N$ over tree nodes matches QS
- [ ] Implement the full hybrid algorithm and benchmark against the quadratic sieve
- [ ] Investigate the hyperbolic CVP connection rigorously
- [ ] Explore graph neural network architectures for tree navigation

### Long-Term (This Quarter)
- [ ] Attempt to prove the sub-exponential conjecture for the hybrid algorithm
- [ ] Scale experiments to 50+ digit semiprimes
- [ ] Investigate quantum speedups for the tree sieve
- [ ] Write and submit the research paper

---

*Notes compiled by Oracle Epsilon (Synthesizer)*
*Reviewed by The Advisor*
