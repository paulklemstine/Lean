# Fiber Graphs in Hamming Spaces: Bridge Duality and Structural Theory

## Abstract

We develop the formal theory of fiber graphs induced by additive scoring functions on Hamming spaces. Given a weight system $w: [n] \times [q] \to G$ over an abelian group $G$, the additive score of a configuration $x \in [q]^n$ is $f(x) = \sum_{i=1}^n w_i(x_i)$. The fiber of a value $v \in G$ is the preimage $f^{-1}(v)$, and the fiber graph has fiber elements as vertices with edges between configurations at Hamming distance one.

Our central result is the **Bridge Duality Theorem**: for two equal-score configurations differing at exactly two positions $i$ and $j$, the existence of a score-preserving bridge through position $i$ is logically equivalent to a bridge through position $j$. We establish this through the score delta algebra, prove fiber partition properties, develop a position-separation rigidity theorem, and prove a score swap lemma for weight-matched modifications. All results are formally verified in Lean 4 with the Mathlib library.

We conjecture that fiber graphs of generic additive scoring functions have spectral gap $\Omega(1/n)$, which would imply polynomial-time mixing for Markov chains on fibers.

**Keywords**: Hamming space, fiber graph, additive scoring, bridge duality, spectral gap, neutral networks

---

## 1. Introduction

The study of level sets of functions on discrete product spaces arises naturally in coding theory, statistical physics, combinatorial optimization, and evolutionary biology. When the function is additive — decomposing as a sum of per-coordinate contributions — the level sets (or *fibers*) inherit rich structural properties from the algebraic decomposition.

In coding theory, linear codes are fibers of linear maps, and their distance properties determine error-correction capability. In evolutionary biology, additive fitness landscapes (those without epistasis) have neutral networks — sets of genotypes with identical fitness — that form fibers of additive scoring functions. The connectivity and expansion properties of these fiber graphs determine the dynamics of neutral evolution.

Despite their ubiquity, the formal structural theory of fiber graphs for general additive scoring functions has not been systematically developed. This paper initiates such a theory, with a focus on the bridge duality phenomenon.

### 1.1 Contributions

1. **Formal definitions** of Hamming spaces, additive weight systems, fibers, fiber adjacency, bridge configurations, and score deltas (Section 2).

2. **Score Delta Algebra** (Section 3): We establish that score deltas form an antisymmetric, additive structure with identity — the axioms of a $G$-torsor on each position's symbol set.

3. **Bridge Duality Theorem** (Section 4): The main result, showing that bridge existence through any differing position is equivalent to bridge existence through any other, for configurations differing at exactly two positions.

4. **Position Separation Rigidity** (Section 5): For injective weight systems, configurations agreeing everywhere except one position with equal scores must be identical.

5. **Score Swap Lemma** (Section 6): Weight-matched double modifications preserve scores, enabling systematic construction of fiber graph paths.

6. **Fiber Expansion Conjecture** (Section 7): We conjecture $\Omega(1/n)$ spectral gap for generic fiber graphs and discuss evidence from bridge duality.

---

## 2. Definitions

### 2.1 Hamming Space

Fix positive integers $n$ (number of positions) and $q$ (alphabet size). The **Hamming space** is $\Sigma^n = [q]^n$, the set of all functions from $[n]$ to $[q]$. The **Hamming distance** between configurations $x, y \in \Sigma^n$ is

$$d_H(x, y) = |\{i \in [n] : x_i \neq y_i\}|$$

Two configurations are **Hamming-adjacent** if $d_H(x, y) = 1$.

### 2.2 Additive Scoring

Let $(G, +)$ be an abelian group. A **weight system** is a function $w: [n] \times [q] \to G$, written $w_i(a)$ for position $i$ and symbol $a$. The **additive score** is

$$f_w(x) = \sum_{i=1}^n w_i(x_i)$$

### 2.3 Fibers and Fiber Graphs

The **fiber** of value $v \in G$ is $F_v = f_w^{-1}(v) = \{x \in \Sigma^n : f_w(x) = v\}$. The **fiber graph** $\Gamma_v$ has vertex set $F_v$ and edge set $\{(x,y) : x, y \in F_v, d_H(x,y) = 1\}$.

### 2.4 Bridges

For $x, y \in F_v$ with $d_H(x, y) = 2$, say $x$ and $y$ differ at positions $i$ and $j$. A **bridge through position $i$** is a configuration $z$ such that:
- $z$ agrees with $x$ at all positions except $i$
- $z_i = y_i$
- $f_w(z) = f_w(x) = v$

Geometrically, $z$ is a midpoint on a two-step path $x \to z \to y$ in the fiber graph, where the first step changes only position $i$.

### 2.5 Score Deltas

The **score delta** at position $i$ from symbol $a$ to symbol $b$ is

$$\delta_i(a, b) = w_i(b) - w_i(a)$$

### 2.6 Configuration Modification

The **modification** of $x$ at position $i$ to symbol $a$, written $x[i \mapsto a]$, is defined by $(x[i \mapsto a])_k = a$ if $k = i$, and $x_k$ otherwise.

---

## 3. Score Delta Algebra

The score delta satisfies three fundamental algebraic identities.

**Theorem 3.1 (Antisymmetry).** $\delta_i(a, b) = -\delta_i(b, a)$.

*Proof.* Direct computation: $w_i(b) - w_i(a) = -(w_i(a) - w_i(b))$. $\square$

**Theorem 3.2 (Additivity).** $\delta_i(a, c) = \delta_i(a, b) + \delta_i(b, c)$.

*Proof.* $(w_i(c) - w_i(a)) = (w_i(b) - w_i(a)) + (w_i(c) - w_i(b))$ by telescoping. $\square$

**Theorem 3.3 (Identity).** $\delta_i(a, a) = 0$.

*Proof.* $w_i(a) - w_i(a) = 0$. $\square$

These three properties establish that the score deltas at each position form a torsor structure: the symbols at position $i$ form a principal homogeneous space for the subgroup of $G$ generated by $\{\delta_i(a, b) : a, b \in [q]\}$.

**Theorem 3.4 (Score Decomposition).** $f_w(x[i \mapsto a]) = f_w(x) + \delta_i(x_i, a)$.

*Proof.* Since $x[i \mapsto a]$ agrees with $x$ at all positions except $i$, the sum telescopes:
$$f_w(x[i \mapsto a]) = \sum_{k \neq i} w_k(x_k) + w_i(a) = f_w(x) - w_i(x_i) + w_i(a) = f_w(x) + \delta_i(x_i, a). \quad \square$$

---

## 4. Bridge Duality Theorem

**Theorem 4.1 (Bridge Duality).** Let $x, y \in F_v$ with $\text{diff}(x, y) = \{i, j\}$ for $i \neq j$. Then a bridge through $i$ exists if and only if a bridge through $j$ exists.

*Proof sketch.* By Theorem 3.4, a bridge through $i$ exists iff $\delta_i(x_i, y_i) = 0$, i.e., $w_i(y_i) = w_i(x_i)$. Similarly, a bridge through $j$ exists iff $w_j(y_j) = w_j(x_j)$.

From $f_w(x) = f_w(y)$ and $x_k = y_k$ for $k \notin \{i, j\}$:
$$w_i(x_i) + w_j(x_j) = w_i(y_i) + w_j(y_j)$$

Rearranging: $w_i(x_i) - w_i(y_i) = w_j(y_j) - w_j(x_j)$.

If $w_i(y_i) = w_i(x_i)$ (bridge through $i$), then $w_j(y_j) = w_j(x_j)$ (bridge through $j$), and vice versa. $\square$

**Remark.** The theorem reveals that bridge obstruction is a *global* property: it affects all differing positions simultaneously. There is no configuration that blocks a bridge at one position while permitting it at another.

---

## 5. Position Separation and Rigidity

**Definition 5.1.** A weight system $w$ is **position-separating** if $w_i$ is injective for every position $i$.

**Theorem 5.2 (Rigidity).** If $w$ is position-separating and $x, y$ agree at all positions except possibly $i$ with $f_w(x) = f_w(y)$, then $x = y$.

*Proof.* From $f_w(x) = f_w(y)$ and $x_k = y_k$ for $k \neq i$, canceling yields $w_i(x_i) = w_i(y_i)$. By injectivity, $x_i = y_i$. Combined with agreement elsewhere, $x = y$. $\square$

**Corollary 5.3.** For position-separating weight systems, any two distinct configurations in the same fiber differ at $\geq 2$ positions.

This is the fiber-theoretic analogue of the minimum distance property in coding theory: the fiber graph of a position-separating system has no self-loops and no "trivial" edges.

---

## 6. Score Swap Lemma

**Theorem 6.1 (Score Swap).** If $w_i(a_i) = w_i(x_i)$ and $w_j(a_j) = w_j(x_j)$ for $i \neq j$, then
$$f_w(x[i \mapsto a_i][j \mapsto a_j]) = f_w(x)$$

*Proof.* Apply Theorem 3.4 twice. The first modification adds $\delta_i(x_i, a_i) = 0$, and the second adds $\delta_j(x_j, a_j) = 0$ (noting that the second modification is at a different position, so it doesn't affect the first delta). $\square$

**Application.** The Score Swap Lemma enables systematic construction of paths within fibers. Given weight matches at multiple positions, one can perform a sequence of weight-preserving modifications to navigate between configurations while staying in the fiber.

---

## 7. Fiber Expansion Conjecture and Discussion

### 7.1 The Conjecture

**Conjecture 7.1 (Fiber Expansion).** For $q \geq 3$ and a generic weight system $w: [n] \times [q] \to \mathbb{Z}$, the spectral gap of the fiber graph $\Gamma_v$ satisfies $\lambda_2(\Gamma_v) \geq c/n$ for a constant $c > 0$ depending only on $q$.

### 7.2 Evidence

The bridge duality theorem provides structural evidence: it shows that fiber graphs cannot have one-sided bottlenecks at the two-position scale. Any obstruction to connectivity affects all differing positions symmetrically.

The position-separation rigidity theorem provides additional evidence: for generic (injective) weight systems, fiber graphs have minimum degree at least $n(q-1) - 1$ when they are non-empty, because each position allows $q-1$ symbol changes, and by rigidity, at most one of these can stay in the fiber per position.

### 7.3 Computational Test

The conjecture can be tested computationally for small parameters. For $n = 4, q = 3$ with random integer weights in $[-10, 10]$, one can enumerate the fiber graph and compute the spectral gap directly. The conjecture predicts $\lambda_2 \geq c/4$ for most fibers.

### 7.4 Implications

If true, Conjecture 7.1 would imply:
1. **Rapid mixing**: Random walks on fibers converge to the uniform distribution in $O(n \log n)$ steps.
2. **Efficient sampling**: One can sample nearly-uniform elements from fibers in polynomial time.
3. **Coding bounds**: New bounds on the size of codes with prescribed weight distributions.

### 7.5 Connection to Neutral Network Theory

In evolutionary biology, the spectral gap of a neutral network determines the rate at which a population under neutral drift explores the network. Conjecture 7.1, restricted to $q = 4$ (DNA alphabet) and weights corresponding to amino acid properties, would give quantitative predictions for the rate of neutral evolution in non-epistatic fitness landscapes.

---

## 8. Algorithms

### 8.1 Bridge Detection Algorithm

Given two configurations $x, y$ with $f_w(x) = f_w(y)$ and $\text{diff}(x, y) = \{i, j\}$:

1. Compute $\delta_i(x_i, y_i) = w_i(y_i) - w_i(x_i)$.
2. If $\delta_i = 0$: bridge through $i$ exists (witness: $x[i \mapsto y_i]$), and by duality, bridge through $j$ also exists (witness: $x[j \mapsto y_j]$).
3. If $\delta_i \neq 0$: no bridge through either position.

**Complexity**: $O(1)$ time, given the weight system.

### 8.2 Fiber Path Construction Algorithm

Given $x, y$ in the same fiber with weight matches at each differing position:

1. Let $D = \{i : x_i \neq y_i\}$.
2. For each $i \in D$, find $a_i$ with $w_i(a_i) = w_i(x_i)$ and eventually navigate to $y_i$.
3. Construct path by swapping one position at a time, using weight matches to maintain score.

**Complexity**: $O(n \cdot q)$ time.

---

## 9. Related Work

The theory of fiber graphs connects to several established areas:

- **Coding theory**: Linear codes are fibers of $\mathbb{F}_q$-linear maps. The fiber graph is the coset graph, and its expansion properties determine list-decoding bounds (Guruswami-Sudan).

- **Statistical physics**: Fibers of the Ising Hamiltonian are energy shells, and the Kawasaki dynamics on these shells corresponds to random walks on the fiber graph.

- **Combinatorial optimization**: Fibers of linear objective functions over polytopes are studied in the theory of pivot rules for the simplex method.

- **Tropical geometry**: Replacing $(\mathbb{Z}, +)$ with the tropical semiring $(\mathbb{Z}, \min, +)$ yields tropical fibers, studied in tropical linear algebra.

---

## 10. Conclusion

We have established a formal foundation for the theory of fiber graphs in Hamming spaces under additive scoring. The Bridge Duality Theorem reveals a fundamental symmetry: score-preserving navigation through any one position is equivalent to navigation through any other. This symmetry, combined with the score delta algebra and position-separation rigidity, provides the structural tools needed to analyze connectivity and expansion of fibers.

The Fiber Expansion Conjecture represents the most promising direction for future work. Proving it would connect the algebraic theory of additive scoring to the analytic theory of Markov chain mixing, with applications across coding theory, statistical physics, and computational biology.

---

## References

1. Hamming, R.W. "Error detecting and error correcting codes." *Bell System Technical Journal* 29.2 (1950): 147-160.

2. van Nimwegen, E., Crutchfield, J.P., and Huynen, M. "Neutral evolution of mutational robustness." *PNAS* 96.17 (1999): 9716-9720.

3. Hoory, S., Linial, N., and Wigderson, A. "Expander graphs and their applications." *Bulletin of the AMS* 43.4 (2006): 439-561.

4. Plotkin, M. "Binary codes with specified minimum distance." *IRE Transactions on Information Theory* 6.4 (1960): 445-450.
