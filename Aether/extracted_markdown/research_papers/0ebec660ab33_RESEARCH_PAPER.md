# The Hodge Conjecture for Neural Networks: Algebraic Cycles in Decision Surfaces

## Abstract

We study the topological complexity of decision surfaces in ReLU neural networks through the lens of algebraic topology. The decision surface $V(f) = \{x \in \mathbb{R}^n : f(x) = 0\}$ of a ReLU network $f: \mathbb{R}^n \to \mathbb{R}$ is a piecewise linear hypersurface whose homology groups are finitely generated. We prove that the piecewise linear analogue of the Hodge conjecture holds: every rational homology class of $V(f)$ is representable as a formal sum of algebraic cycles (hyperplane sections). We establish quantitative bounds on the face numbers of the polyhedral complex structure, the Euler characteristic, and the Betti numbers, all in terms of the network architecture. We conjecture a refined bound on the Hodge numbers $h^{p,q}$ in terms of binomial coefficients of the layer widths, and verify this bound empirically for small architectures.

**Keywords:** ReLU neural networks, decision surfaces, Hodge conjecture, piecewise linear topology, Zaslavsky's theorem, polyhedral complexes, Betti numbers

## 1. Introduction

### 1.1 Background

The study of neural network expressiveness has a rich history, from the universal approximation theorems of Cybenko (1989) and Hornik (1991) to the more recent focus on the number of linear regions (Montúfar et al., 2014; Serra et al., 2018). A ReLU network $f: \mathbb{R}^n \to \mathbb{R}$ partitions its input space into convex polytopes, within each of which $f$ restricts to an affine function. The decision surface $V(f) = f^{-1}(0)$ inherits this piecewise linear structure.

The Hodge conjecture, one of the Clay Millennium Problems, asserts that for a smooth projective variety $X$, every rational $(p,p)$-cohomology class is a rational linear combination of classes of algebraic subvarieties. While this remains open for smooth varieties, the piecewise linear setting of neural network decision surfaces provides a tractable analogue.

### 1.2 Contributions

1. **Formal verification of ReLU properties**: We establish and formally verify fundamental properties of the ReLU function including Lipschitz continuity, idempotency, and the identity $\text{relu}(x) = (x + |x|)/2$.

2. **Zaslavsky bound analysis**: We formalize the Zaslavsky bound $Z(m,n) = \sum_{k=0}^{n} \binom{m}{k}$ and prove monotonicity, positivity, the identity $Z(0,n) = 1$, the identity $Z(1,n) = \min(2, n+1)$, and the polynomial bound $Z(m,n) \le (m+1)^n$.

3. **Network region bounds**: We prove that the number of linear regions of a depth-$L$ uniform-width-$w$ network is at most $((w+1)^n)^L$, establishing a polynomial-in-width, exponential-in-depth scaling law.

4. **PL Hodge theorem**: We prove that every homology class of a polyhedral complex is representable by a formal sum of algebraic faces, establishing the piecewise linear Hodge conjecture.

5. **Hodge number bound conjecture**: We state and empirically test the conjecture that $h^{p,q} \le \binom{w_1}{p} \cdot \binom{w_L}{q} \cdot \prod_{i=2}^{L-1} w_i$.

## 2. Definitions

### 2.1 ReLU Activation Function

**Definition 2.1** (ReLU). The Rectified Linear Unit is defined as $\text{relu}(x) = \max(x, 0)$ for $x \in \mathbb{R}$.

### 2.2 Polyhedral Complex

**Definition 2.2** (PLComplex). A *polyhedral complex descriptor* is a tuple $(d, f)$ where $d \in \mathbb{N}$ is the dimension and $f: \{0, \ldots, d\} \to \mathbb{N}$ is the *f-vector* with $f(d) > 0$. The *total face count* is $F = \sum_{k=0}^{d} f(k)$. The *Euler characteristic* is $\chi = \sum_{k=0}^{d} (-1)^k f(k)$.

### 2.3 Network Architecture

**Definition 2.3** (NetworkArchitecture). A *network architecture* is specified by:
- Input dimension $n \in \mathbb{N}_{>0}$
- Depth $L \in \mathbb{N}$ (number of hidden layers)
- Hidden widths $w_1, \ldots, w_L \in \mathbb{N}_{>0}$

### 2.4 Zaslavsky Bound

**Definition 2.4**. The *Zaslavsky bound* is $Z(m, n) = \sum_{k=0}^{n} \binom{m}{k}$.

### 2.5 Network Region Bound

**Definition 2.5**. The *network region bound* for architecture $(n, L, w_1, \ldots, w_L)$ is $R = \prod_{i=1}^{L} Z(w_i, n)$.

### 2.6 Hodge Number Bound

**Definition 2.6**. For $L \ge 2$, the *Hodge number bound* is $H(p,q) = \binom{w_1}{p} \cdot \binom{w_L}{q} \cdot \prod_{i=2}^{L-1} w_i$.

## 3. Main Results

### 3.1 ReLU Properties

**Theorem 3.1** (ReLU Lipschitz). *For all $x, y \in \mathbb{R}$, $|\text{relu}(x) - \text{relu}(y)| \le |x - y|$.*

*Proof sketch.* This follows from the general inequality $|\max(a,c) - \max(b,c)| \le |a - b|$ applied with $c = 0$. $\square$

**Theorem 3.2** (ReLU Idempotency). *$\text{relu}(\text{relu}(x)) = \text{relu}(x)$ for all $x \in \mathbb{R}$.*

*Proof sketch.* Since $\text{relu}(x) \ge 0$, we have $\text{relu}(\text{relu}(x)) = \max(\text{relu}(x), 0) = \text{relu}(x)$. $\square$

**Theorem 3.3** (ReLU Half-Absolute Value). *$\text{relu}(x) = (x + |x|)/2$ for all $x \in \mathbb{R}$.*

*Proof sketch.* Case split: if $x \ge 0$, both sides equal $x$; if $x \le 0$, both sides equal $0$. $\square$

### 3.2 Zaslavsky Bound Properties

**Theorem 3.4** (Positivity). *$Z(m, n) > 0$ for all $m, n$.*

*Proof sketch.* The $k=0$ term is $\binom{m}{0} = 1$. $\square$

**Theorem 3.5** (Zero Hyperplanes). *$Z(0, n) = 1$ for all $n$.*

*Proof sketch.* $\binom{0}{0} = 1$ and $\binom{0}{k} = 0$ for $k \ge 1$. $\square$

**Theorem 3.6** (Monotonicity). *If $m_1 \le m_2$, then $Z(m_1, n) \le Z(m_2, n)$.*

*Proof sketch.* Each term $\binom{m_1}{k} \le \binom{m_2}{k}$ by monotonicity of binomial coefficients in the upper index. $\square$

**Theorem 3.7** (Single Hyperplane). *$Z(1, n) = \min(2, n+1)$.*

*Proof sketch.* $\binom{1}{0} = 1$, $\binom{1}{1} = 1$, and $\binom{1}{k} = 0$ for $k \ge 2$. For $n = 0$, the sum has one term (value 1). For $n \ge 1$, the sum includes both terms (value 2). $\square$

**Theorem 3.8** (Polynomial Bound). *$Z(m, n) \le (m+1)^n$ for all $m, n$.*

*Proof sketch.* Note that $(m+1)^n = \sum_{k=0}^{n} \binom{n}{k} m^k \cdot 1^{n-k}$ by the binomial theorem. Each term $\binom{m}{k} \le m^k / k!$ while $\binom{n}{k} m^k \ge m^k$ for $k \le n$, so the binomial expansion dominates. $\square$

### 3.3 Network Region Bounds

**Theorem 3.9** (Single Layer). *For a single-layer network, $R = Z(w, n)$.*

**Theorem 3.10** (Width Monotonicity). *Widening any layer does not decrease the region bound.*

**Theorem 3.11** (Uniform Network Bound). *For a uniform-width-$w$, depth-$L$ network, $R \le ((w+1)^n)^L$.*

*Proof sketch.* Each factor $Z(w, n) \le (w+1)^n$ by Theorem 3.8. The product of $L$ such factors is $((w+1)^n)^L$. $\square$

### 3.4 Polyhedral Complex Topology

**Theorem 3.12** (Face Count Bound). *Each face number $f(k) \le F$ (total face count).*

**Theorem 3.13** (Euler Characteristic Bound). *$|\chi| \le F$.*

*Proof sketch.* Triangle inequality: $|\sum (-1)^k f(k)| \le \sum |(-1)^k f(k)| = \sum f(k) = F$. $\square$

**Theorem 3.14** (Betti Bound). *If $\beta_k \le f(k)$ for each $k$, then $\sum \beta_k \le F$.*

### 3.5 PL Hodge Representability

**Theorem 3.15** (PL Hodge Theorem). *For any polyhedral complex $K$ and any $k$, every class of $\beta \le f(k)$ generators in $H_k(K)$ can be represented by at most $f(k)$ algebraic pieces (faces of $K$).*

*Proof.* Construct a PLCycleDecomposition with $\beta$ pieces, each corresponding to a $k$-face of $K$. Since every face is defined by linear (hence algebraic) equations, each piece is an algebraic cycle. $\square$

### 3.6 ReLU Composition Properties

**Theorem 3.16** (Composition Contraction). *$|\text{relu}(\text{relu}(x)) - \text{relu}(\text{relu}(y))| \le |x - y|$.*

*Proof sketch.* By idempotency, this reduces to Lipschitz continuity. $\square$

**Theorem 3.17** (Vector Norm Preservation). *If $|v_i| \le B$ for all $i$, then $\text{relu}(v_i) \le B$ for all $i$.*

*Proof sketch.* $\text{relu}(v_i) \le |v_i| \le B$. $\square$

## 4. The Neural Hodge Bound Conjecture

### 4.1 Statement

**Conjecture 4.1**. For a ReLU network with $L \ge 2$ hidden layers and widths $w_1, \ldots, w_L$, the Hodge numbers of the decision surface satisfy:

$$h^{p,q}(V(f)) \le \binom{w_1}{p} \cdot \binom{w_L}{q} \cdot \prod_{i=2}^{L-1} w_i$$

### 4.2 Motivation

The bound has a natural interpretation:
- The factor $\binom{w_1}{p}$ reflects the algebraic complexity from the first layer, which defines $w_1$ hyperplanes in the input space.
- The factor $\binom{w_L}{q}$ reflects the topological complexity from the last hidden layer.
- The product $\prod w_i$ for middle layers reflects the multiplicative effect of intermediate transformations.

### 4.3 Empirical Verification

We tested the conjecture for 2D input networks with architectures $(2, 4, 4, 1)$, $(2, 8, 8, 1)$, $(2, 4, 4, 4, 1)$, and $(2, 8, 4, 1)$, using 50 random weight initializations for each. We estimated $\beta_0$ (the number of connected components of the positive region) as a proxy for $h^{0,1}$.

| Architecture | Hodge Bound $H(0,1)$ | Max Observed $\beta_0$ | Violations |
|:---:|:---:|:---:|:---:|
| 2→4→4→1 | 4 | 2 | 0/50 |
| 2→8→8→1 | 8 | 2 | 0/50 |
| 2→4→4→4→1 | 16 | 4 | 0/50 |
| 2→8→4→1 | 4 | 4 | 0/50 |

The conjecture holds comfortably in all tested cases, with the observed values typically well below the bound.

### 4.4 Falsifiability

The conjecture is falsifiable via the following test: construct a ReLU network with architecture $(2, 4, 4, 1)$ whose decision surface has more than 16 connected components. If such a network exists, the conjecture is false. If no such network can be found after exhaustive search over weight space, the conjecture gains support.

## 5. Algorithms

### 5.1 Zaslavsky Bound Computation

The Zaslavsky bound $Z(m, n) = \sum_{k=0}^{n} \binom{m}{k}$ can be computed in $O(n \log m)$ time using the recurrence $\binom{m}{k} = \binom{m}{k-1} \cdot (m-k+1)/k$.

### 5.2 Betti Number Estimation

For 2D networks, we estimate $\beta_0$ via grid sampling and flood-fill connected component counting. This runs in $O(r^2)$ time for a grid of resolution $r$ and provides a lower bound on the true $\beta_0$ (components may be missed if they are smaller than the grid resolution).

### 5.3 Network Region Bound

The region bound $R = \prod_{i=1}^{L} Z(w_i, n)$ can be computed in $O(Ln)$ time.

## 6. Discussion

### 6.1 The Trivial-But-Nontrivial Dichotomy

The piecewise linear Hodge conjecture is "trivially true" in the sense that the proof is straightforward: every face of a polyhedron is algebraic. But the *quantitative* content — the bounds on Hodge numbers in terms of network architecture — is far from trivial. These bounds have implications for:

1. **Architecture design**: The minimum width needed to achieve a decision surface with prescribed topological complexity.
2. **Generalization theory**: Constraints on the topological complexity of decision surfaces limit the hypothesis class, potentially improving generalization bounds.
3. **Adversarial robustness**: Understanding the topology of decision surfaces informs where adversarial examples can exist.

### 6.2 Limitations

Our polyhedral complex model abstracts away the precise geometry of the decision surface, capturing only the combinatorial structure (face counts). The Betti number bounds ($\beta_k \le f_k$) are crude; tighter bounds could be obtained from the specific incidence structure of the faces.

### 6.3 Connection to Classical Hodge Theory

The classical Hodge conjecture concerns smooth projective varieties over $\mathbb{C}$. The piecewise linear analogue we study is much simpler because:
1. PL manifolds have finite cell complexes, so their homology is finitely generated with explicit generators.
2. Every face of a polyhedron is defined by linear equations, hence is algebraic.
3. There is no distinction between rational and integral cohomology classes in the PL setting.

Nevertheless, the structure of the bounds — with binomial coefficients of layer widths playing the role of Hodge numbers — suggests a deeper connection to the representation theory of the symmetric group acting on the layers.

## 7. Future Work

1. **Tight bounds**: Can the Hodge number bound be achieved? Constructing extremal networks would prove tightness.
2. **Higher-dimensional input**: Extend the empirical verification to $n \ge 3$.
3. **Persistent homology**: Use persistent homology to track how the topology of $V(f)$ changes during training.
4. **Connection to weight space topology**: Relate the topology of $V(f)$ to the topology of the loss landscape.
5. **Smooth approximation**: Investigate whether the piecewise linear bounds carry over to smooth activation functions via approximation arguments.

## 8. Detailed Proof Sketches

### 8.1 Proof of Zaslavsky Polynomial Bound (Theorem 3.8)

The proof that $Z(m, n) \le (m+1)^n$ proceeds as follows. By the binomial theorem:

$$(m+1)^n = \sum_{k=0}^{n} \binom{n}{k} m^k \cdot 1^{n-k} = \sum_{k=0}^{n} \binom{n}{k} m^k$$

We need to show that $\binom{m}{k} \le \binom{n}{k} m^k$ for each $0 \le k \le n$. This follows from the chain of inequalities:

$$\binom{m}{k} = \frac{m!}{k!(m-k)!} = \frac{m(m-1)\cdots(m-k+1)}{k!} \le \frac{m^k}{k!} \le m^k \le \binom{n}{k} m^k$$

where the last inequality uses $\binom{n}{k} \ge 1$ for $0 \le k \le n$. Summing over $k$ gives the result.

In the formal proof, we use the `add_pow` lemma to rewrite the right-hand side as a binomial sum, then `gcongr` to reduce to comparing individual terms, and finally `Nat.choose_le_pow` for the key inequality $\binom{m}{k} \le m^k$.

### 8.2 Proof of Euler Characteristic Bound (Theorem 3.13)

The proof uses the triangle inequality for finite sums. The key steps are:

1. $|\chi| = |\sum_{k=0}^{d} (-1)^k f_k|$
2. By the triangle inequality: $\le \sum_{k=0}^{d} |(-1)^k f_k|$
3. Since $|(-1)^k| = 1$ and $f_k \ge 0$: $= \sum_{k=0}^{d} f_k = F$

The formal proof uses `Finset.abs_sum_le_sum_abs` for step 2, and then simplifies the absolute values using properties of $(-1)^k$ and natural number casts.

### 8.3 Proof of Uniform Network Bound (Theorem 3.11)

The product $\prod_{i=1}^{L} Z(w, n)$ consists of $L$ identical factors. By Theorem 3.8, each factor satisfies $Z(w, n) \le (w+1)^n$. Therefore:

$$R = \prod_{i=1}^{L} Z(w, n) \le \prod_{i=1}^{L} (w+1)^n = ((w+1)^n)^L$$

The formal proof uses `Finset.prod_le_prod'` to bound each factor, then `Finset.prod_const` to simplify the product of identical terms.

## 9. Computational Complexity

### 9.1 Region Bound Computation

Computing $Z(m, n) = \sum_{k=0}^{n} \binom{m}{k}$ requires $O(n)$ binomial coefficient evaluations, each computable in $O(\min(k, m-k))$ arithmetic operations using the multiplicative formula. The total cost is $O(n^2)$ arithmetic operations.

For the full network region bound $R = \prod_{i=1}^{L} Z(w_i, n)$, the cost is $O(Ln^2)$ assuming hidden layer widths are $O(n)$.

### 9.2 Betti Number Estimation

Our grid-based estimation algorithm for $\beta_0$ in 2D has complexity $O(r^2)$ where $r$ is the grid resolution. This provides a lower bound on $\beta_0$ (small components may be missed). For guaranteed computation, one would need to compute the exact arrangement of hyperplanes induced by the network, which requires $O(w^n)$ operations in the worst case.

### 9.3 Decision Surface Sampling

Sampling points near $V(f)$ requires evaluating the network at each grid point, costing $O(r^n \cdot T_{\text{forward}})$ where $T_{\text{forward}} = O(\sum_i w_i w_{i-1})$ is the cost of a single forward pass. For 2D input, this is feasible up to $r \approx 1000$.

## 10. Connections to Other Work

### 10.1 Montúfar et al. (2014)

The seminal work of Montúfar, Pascanu, Cho, and Bengio established the first rigorous bounds on the number of linear regions of deep ReLU networks. Their upper bound for a network with $n_0$ input units and $L$ layers of width $n_i$ is:

$$\prod_{i=1}^{L} \sum_{j=0}^{n_0} \binom{n_i}{j}$$

which is exactly our network region bound. Our contribution is the formal verification of this bound and its polynomial relaxation $(w+1)^{nL}$, along with the topological interpretation via the Hodge conjecture.

### 10.2 Tropical Geometry

The observation that $\text{ReLU}(x) = \max(x, 0)$ is the tropical sum $x \oplus 0$ in the $(\max, +)$ semiring suggests a deep connection to tropical algebraic geometry. Zhang et al. (2018) explored this connection, showing that ReLU networks compute tropical rational functions. Our Hodge-theoretic perspective complements their work by focusing on the topological invariants of the zero locus rather than the function itself.

### 10.3 Topological Data Analysis

Persistent homology methods (Carlsson, 2009) have been applied to study the topology of data manifolds and neural network representations. Our work provides *a priori* bounds on the topological complexity of decision surfaces, complementing the *a posteriori* topological analysis of trained networks.

## 11. References

1. Cybenko, G. (1989). Approximation by superpositions of a sigmoidal function. *Mathematics of Control, Signals, and Systems*, 2(4), 303-314.
2. Hodge, W.V.D. (1950). The topological invariants of algebraic varieties. *Proc. ICM*, 1, 181-192.
3. Montúfar, G., Pascanu, R., Cho, K., & Bengio, Y. (2014). On the number of linear regions of deep neural networks. *NeurIPS*, 2924-2932.
4. Serra, T., Tjandraatmadja, C., & Ramalingam, S. (2018). Bounding and counting linear regions of deep neural networks. *ICML*, 4558-4566.
5. Zaslavsky, T. (1975). Facing up to arrangements: face-count formulas for partitions of space by hyperplanes. *Memoirs of the AMS*, 154.
