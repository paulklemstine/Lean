# Canonical Path Poincaré Inequality for Cayley Graphs: A Formally Verified Framework

## Abstract

We formalize the Jerrum–Sinclair canonical path method for Cayley graphs of finite groups, producing the first machine-verified proof of the quantitative Poincaré inequality

$$\text{Var}(f) \leq \frac{\kappa \cdot L}{2|G|^2} \cdot \mathcal{E}_S(f)$$

where $\kappa$ is the directed-edge congestion, $L$ is the maximum path length, and $\mathcal{E}_S(f)$ is the Dirichlet energy. Our formalization in Lean 4 with Mathlib decomposes the proof into four independently verified components: (1) a telescoping identity along word paths, (2) a Cauchy–Schwarz bound on path energy, (3) a variance–pairwise-difference identity, and (4) the main inequality assembling these pieces via a congestion condition. We instantiate the framework for the symmetric group $S_5$ with bubble-sort canonical paths, computing exact congestion $\kappa = 188$, maximum path length $L = 10$, and certifying a spectral gap lower bound $\mathcal{E}_S(f)/(|S| \cdot \text{Var}(f)) \geq 3.83$. The formalization opens a certified pipeline from combinatorial routing data to analytic expansion bounds.

## 1. Introduction

### 1.1 Motivation

The spectral gap of a graph—the smallest nonzero eigenvalue of its Laplacian—is among the most important quantities in discrete mathematics. It controls random walk mixing times, expansion properties, concentration of measure, and the rate of information diffusion. For Cayley graphs of finite groups, the spectral gap connects group-theoretic structure to analytic behavior, with implications for algorithm design, cryptography, and statistical physics.

Computing spectral gaps exactly is computationally expensive (it requires eigenvalue computation on $|G| \times |G|$ matrices), but *bounding* them from below via combinatorial certificates is often tractable. The canonical path method, introduced by Jerrum and Sinclair (1989) and systematized by Diaconis and Stroock (1991), provides exactly such certificates: given a system of paths routing between all pairs of vertices with bounded congestion, one obtains a Poincaré inequality and hence a spectral gap lower bound.

### 1.2 Contributions

1. **Formally verified Poincaré inequality.** We prove in Lean 4 that for any canonical path system on a Cayley graph with congestion $\kappa$ and maximum length $L$:
$$\text{Var}(f) \leq \frac{\kappa \cdot L}{2|G|^2} \cdot \mathcal{E}_S(f) \qquad \text{for all } f : G \to \mathbb{R}.$$

2. **Spectral gap certificate.** We derive the lower bound:
$$\frac{\mathcal{E}_S(f)}{|S| \cdot \text{Var}(f)} \geq \frac{2|G|^2}{|S| \cdot \kappa \cdot L}$$
converting routing data into certified expansion.

3. **Computational case study.** We instantiate the framework for $S_5$ with bubble-sort canonical paths, computing exact congestion $\kappa = 188$ and maximum path length $L = 10$.

4. **Cross-domain bridge.** The certified Poincaré inequality connects to random walk mixing, equilibration in statistical physics, and derandomization in computational complexity.

### 1.3 Related Work

The canonical path method originates in Jerrum and Sinclair's work on approximating the permanent (1989). Diaconis and Stroock (1991) gave the general Poincaré inequality formulation. Sinclair (1992) provided an excellent survey. The method has been applied to card shuffling (Aldous, 1983), the Ising model (Jerrum and Sinclair, 1993), and numerous other Markov chains.

Prior formal verification work on spectral theory includes Affeldt et al.'s formalization of the spectral theorem in Coq. Our work appears to be the first formalization of the canonical path method itself.

## 2. Mathematical Setup

### 2.1 Notation

- $G$: a finite group with identity $1$
- $S \subseteq G$: a finite generating set
- $|G| = n$, $|S| = d$ (the degree)
- $f : G \to \mathbb{R}$: a real-valued function on $G$

### 2.2 Dirichlet Energy

The Dirichlet energy measures the total variation of $f$ along edges:
$$\mathcal{E}_S(f) = \sum_{x \in G} \sum_{s \in S} (f(sx) - f(x))^2.$$

This is the unnormalized version. The normalized energy $\mathcal{E}_S(f)/(2|G|)$ corresponds to the quadratic form of the graph Laplacian.

### 2.3 Variance

$$\text{Var}(f) = \frac{1}{|G|} \sum_{x \in G} (f(x) - \bar{f})^2, \qquad \bar{f} = \frac{1}{|G|}\sum_{x \in G} f(x).$$

### 2.4 Canonical Path Data

A canonical path system consists of:
- A function $\gamma : G \times G \to \text{List}(S)$ assigning to each ordered pair $(x, y)$ a word $\gamma(x,y) = [s_1, \ldots, s_k]$ in generators such that $s_1 \cdot s_2 \cdots s_k \cdot x = y$.
- A length bound $L$: $|\gamma(x,y)| \leq L$ for all $x, y$.
- A congestion bound $\kappa$: each directed edge $(g, s)$ is traversed by at most $\kappa$ paths.

### 2.5 Congestion Condition

Define the total path energy:
$$\mathcal{T}(f) = \sum_{x \in G} \sum_{y \in G} \sum_{i=0}^{|\gamma(x,y)|-1} (f(v_{i+1}(x,y)) - f(v_i(x,y)))^2$$

where $v_i(x,y) = (\gamma(x,y)[0:i].\text{prod}) \cdot x$ is the $i$-th intermediate vertex.

The **congestion condition** states:
$$\mathcal{T}(f) \leq \kappa \cdot \mathcal{E}_S(f) \qquad \text{for all } f.$$

This holds when each directed edge $(g, s)$ is used by at most $\kappa$ canonical paths.

## 3. Main Results

### 3.1 Telescoping Identity (Theorem 1)

**Statement.** For any word $[s_1, \ldots, s_k]$ and any $x \in G$:
$$f(s_1 \cdots s_k \cdot x) - f(x) = \sum_{i=0}^{k-1} \big(f(v_{i+1}) - f(v_i)\big)$$
where $v_i = (s_1 \cdots s_i) \cdot x$.

**Proof sketch.** This is the finite telescoping sum identity $f(v_k) - f(v_0) = \sum_{i=0}^{k-1}(f(v_{i+1}) - f(v_i))$, specialized to the vertices along a word path. In Lean, we use `Finset.sum_range_sub` directly.

### 3.2 Cauchy–Schwarz on Paths (Theorem 2)

**Statement.** For any word connecting $x$ to $y$:
$$(f(y) - f(x))^2 \leq |\gamma(x,y)| \cdot \sum_{i=0}^{|\gamma|-1} (f(v_{i+1}) - f(v_i))^2.$$

**Proof sketch.** Apply the telescoping identity to get $f(y) - f(x) = \sum a_i$, then Cauchy–Schwarz: $(\sum a_i)^2 \leq n \sum a_i^2$.

### 3.3 Variance as Pairwise Differences (Theorem 3)

**Statement.**
$$\text{Var}(f) = \frac{1}{2|G|^2} \sum_{x \in G} \sum_{y \in G} (f(y) - f(x))^2.$$

**Proof sketch.** Expand both sides algebraically. The variance expands to $\sum f^2/|G| - \bar{f}^2$. The pairwise sum expands to $2|G|\sum f^2 - 2(\sum f)^2$, which after dividing by $2|G|^2$ gives the same expression.

### 3.4 Main Poincaré Inequality (Theorem 4)

**Statement.** If the congestion condition holds:
$$\text{Var}(f) \leq \frac{\kappa \cdot L}{2|G|^2} \cdot \mathcal{E}_S(f).$$

**Proof sketch.**
1. By Theorem 3: $\text{Var}(f) = \frac{1}{2|G|^2} \sum_{x,y} (f(y)-f(x))^2$.
2. By Theorem 2 and the length bound: $(f(y)-f(x))^2 \leq L \cdot \sum_i (\text{increment}_i)^2$.
3. Sum over pairs: $\sum_{x,y} (f(y)-f(x))^2 \leq L \cdot \mathcal{T}(f)$.
4. By the congestion condition: $\mathcal{T}(f) \leq \kappa \cdot \mathcal{E}_S(f)$.
5. Combine: $\text{Var}(f) \leq \frac{\kappa \cdot L}{2|G|^2} \cdot \mathcal{E}_S(f)$.

### 3.5 Spectral Gap Lower Bound (Theorem 5)

**Statement.** For all $f$ with $\text{Var}(f) > 0$:
$$\frac{\mathcal{E}_S(f)}{|S| \cdot \text{Var}(f)} \geq \frac{2|G|^2}{|S| \cdot \kappa \cdot L}.$$

**Proof.** Rearrange the Poincaré inequality and divide by $|S|$.

### 3.6 Certified Expansion (Theorem 6)

**Statement.**
$$\mathcal{E}_S(f) \geq \frac{2|G|^2}{\kappa \cdot L} \cdot \text{Var}(f).$$

This bridges to Markov chain mixing: the spectral gap of the random walk is at least $2|G|/(|S| \cdot \kappa \cdot L)$, giving mixing time $O(\kappa \cdot L \cdot |S| \cdot \log|G| / (2|G|))$.

## 4. Computational Case Study: $S_5$ with Bubble Sort

### 4.1 Setup

We consider $G = S_5$ (120 elements), $S$ = adjacent transpositions $\{(01), (12), (23), (34)\}$ ($|S| = 4$).

The canonical path from $x$ to $y$ is defined by bubble-sorting $y \cdot x^{-1}$: apply adjacent swaps to sort the permutation, recording the sequence of transpositions.

### 4.2 Computed Values

| Parameter | $S_3$ | $S_4$ | $S_5$ |
|-----------|-------|-------|-------|
| $\|G\|$ | 6 | 24 | 120 |
| $\|S\|$ | 2 | 3 | 4 |
| Max path length $L$ | 3 | 6 | 10 |
| Congestion $\kappa$ | 5 | 28 | 188 |
| Poincaré const $\kappa L/(2\|G\|^2)$ | 0.2083 | 0.1458 | 0.0653 |
| Spectral gap $\geq 2\|G\|^2/(\|S\|\kappa L)$ | 2.40 | 2.29 | 3.83 |

### 4.3 Numerical Verification

For the test function $f(\sigma) = \text{inv}(\sigma)$ (number of inversions) on $S_5$:
- $\mathcal{E}_S(f) = 480.0$
- $\text{Var}(f) = 4.167$
- Actual ratio $\mathcal{E}/(\|S\| \cdot \text{Var}) = 28.8$
- Certified lower bound: $3.83$

The bound is satisfied with a factor of $7.5\times$ to spare.

### 4.4 Congestion by Generator

The congestion varies across generators:
- Transposition $(0,1)$: max usage varies
- Transposition $(1,2)$: typically higher congestion (central position)
- Edge generators carry less load than central ones

This reflects the combinatorial structure of bubble sort, where central positions participate in more sorting operations.

## 5. Congestion Growth Conjecture

### 5.1 Empirical Data

| $n$ | $\kappa(S_n)$ | $L$ | $\kappa/n^4$ | $\kappa/n^8$ |
|-----|--------------|-----|-------------|-------------|
| 3 | 5 | 3 | 0.062 | 6.2×10⁻⁴ |
| 4 | 28 | 6 | 0.109 | 4.3×10⁻⁴ |
| 5 | 188 | 10 | 0.301 | 3.0×10⁻⁴ |

### 5.2 Analysis

The empirical growth exponent from $n=4$ to $n=5$ is approximately $8.5$, significantly exceeding the originally conjectured $O(n^4)$. The data is more consistent with $\kappa = \Theta(n^8)$ or faster growth. This suggests:

**Revised conjecture:** For bubble-sort canonical paths on $S_n$ with adjacent transpositions, $\kappa(S_n) = O(n^c)$ where $c \approx 8$-$9$.

The maximum path length is exactly $L = n(n-1)/2$ (the maximum number of inversions), so the spectral gap lower bound scales as $\Omega(n!^2 / (n \cdot n^c \cdot n^2)) = \Omega(n!^2 / n^{c+3})$.

### 5.3 Comparison with Known Results

The exact spectral gap of the random transposition walk on $S_n$ is $2/n$ (Diaconis–Shahshahani, 1981). For adjacent transpositions, the gap is $\Theta(n^{-3})$ (more precisely, $1 - \cos(\pi/n) \approx \pi^2/(2n^2)$ for the normalized walk). Our bubble-sort canonical path bound gives a polynomial lower bound but with a much worse exponent than the true gap, as expected for this general method.

## 6. Cross-Domain Connections

### 6.1 Random Walk Mixing

The Poincaré inequality directly controls the $L^2$ mixing of the random walk. If $P$ is the transition matrix of the walk (applying a uniform random generator), then for any initial distribution $\mu_0$:
$$\|\mu_t - \pi\|_2^2 \leq (1 - \lambda)^{2t} \cdot \|\mu_0 - \pi\|_2^2$$
where $\lambda \geq 2|G|/(|S| \cdot \kappa \cdot L)$ is the certified spectral gap.

### 6.2 Electrical Network Analogy

The Dirichlet energy $\mathcal{E}_S(f)$ can be interpreted as the power dissipated in an electrical network where:
- Vertices are group elements
- Edges connect $x$ to $sx$ for $s \in S$
- $f(x)$ is the voltage at vertex $x$
- $(f(sx) - f(x))^2$ is the power on edge $(x, s)$

The canonical paths act as a routing certificate: they show that any voltage pattern dissipates enough power (bounded below by variance), which is a discrete analogue of the Dirichlet/Thomson principle.

### 6.3 Computational Complexity

The canonical path certificate can be computed in $O(|G|^2 \cdot L)$ time, which for $S_n$ is $O((n!)^2 \cdot n^2)$. For small $n$ this is feasible; for large $n$ one needs structural arguments to bound congestion without enumeration.

## 7. Formal Verification Details

### 7.1 Architecture

The formalization consists of:
- `Pythagorean/CayleyExpander/Defs.lean`: Core definitions (Dirichlet energy, variance, canonical path data)
- `Pythagorean/CayleyExpander/CanonicalPaths.lean`: Main theorems (Poincaré inequality, spectral gap)

### 7.2 Proof Structure

| Theorem | Lines | Key tactics |
|---------|-------|-------------|
| `telescope_word` | 3 | `Finset.sum_range_sub` |
| `finset_sum_sq_le` | 5 | Variance trick, `nlinarith` |
| `sqDiff_le_len_mul_sum_sqDiffs` | 4 | `convert`, telescoping + C-S |
| `variance_eq_pairwise` | 4 | `simp`, algebraic manipulation |
| `pairwise_le_lengthBound_mul_pathEnergy` | 7 | `Finset.sum_le_sum`, `gcongr` |
| `variance_le_congestion_mul_energy` | 4 | Chaining previous results |
| `spectralGap_lower_bound` | 5 | `field_simp`, rearrangement |
| `energy_ge_expansion_times_variance` | 3 | `field_simp`, direct from main |

All proofs use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### 7.3 Design Decisions

1. **Congestion as hypothesis.** We take the congestion bound as a hypothesis (`CongestionBound`) rather than deriving it from the path data. This separates the analytic inequality (which is fully verified) from the combinatorial counting (which requires problem-specific verification).

2. **Unnormalized energy.** We use $\mathcal{E}_S(f) = \sum_x \sum_{s \in S} (f(sx)-f(x))^2$ without the $1/(2|G|)$ normalization factor. This matches the existing catalog definitions and simplifies the algebraic manipulations.

3. **Left-multiplication convention.** Generators act by left multiplication: $s \cdot x$. The walk moves from $x$ to $sx$. This is consistent with the catalog but differs from some references that use right multiplication.

## 8. Future Work

1. **Automated congestion verification.** Develop tactics or decision procedures that can verify the congestion condition for specific path systems without manual proof.

2. **Representation-theoretic refinement.** For $S_n$, the spectral gap can be computed exactly from representation theory. Compare canonical path bounds with exact values and identify structural improvements.

3. **Non-group Markov chains.** Extend the framework to general reversible Markov chains via comparison theorems, connecting to the Markov chain Monte Carlo literature.

4. **High-dimensional expanders.** Generalize from graphs (1-dimensional) to simplicial complexes, connecting to the emerging theory of high-dimensional expansion.

## References

1. Aldous, D. (1983). Random walks on finite groups and rapidly mixing Markov chains. Séminaire de Probabilités XVII.
2. Diaconis, P., Shahshahani, M. (1981). Generating a random permutation with random transpositions. Z. Wahrscheinlichkeitstheorie.
3. Diaconis, P., Stroock, D. (1991). Geometric bounds on the largest eigenvalue of a Markov chain. Annals of Applied Probability.
4. Jerrum, M., Sinclair, A. (1989). Approximating the permanent. SIAM J. Comput.
5. Sinclair, A. (1992). Improved bounds for mixing rates of Markov chains and multicommodity flow. Combinatorics, Probability and Computing.
