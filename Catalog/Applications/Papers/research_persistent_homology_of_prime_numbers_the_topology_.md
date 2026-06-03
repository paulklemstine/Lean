# Persistent Homology of Prime Numbers: The Topology of Arithmetic

## Abstract

We develop a rigorous framework for studying the prime number sequence through the lens of persistent homology. By treating the primes as a one-dimensional point cloud and constructing the Vietoris-Rips filtration, we establish that the zeroth persistent homology barcode is completely determined by the sequence of prime gaps. We prove the 1D Rips Component Theorem (Theorem 4.1), which expresses the number of connected components at scale ε as the count of gaps exceeding ε plus one. We establish a component derivative formula (Theorem 5.1) showing that the component count drops between integer scales k and k+1 equal the number of gaps of size exactly k+1, directly connecting the twin prime counting function to the topological filtration at scale ε = 2. We prove a barcode stability theorem (Theorem 7.1) bounding the perturbation of bar lengths under pointwise perturbation of the point cloud, yielding a quantitative 1D specialization of the general stability theorem in persistent homology. All results have been formally verified in Lean 4 using the Mathlib library.

**Keywords**: Persistent homology, prime numbers, Rips filtration, prime gaps, barcode, topological data analysis, Cramér's conjecture

---

## 1. Introduction

The prime number sequence $p_1 = 2, p_2 = 3, p_3 = 5, \ldots$ is one of the most studied objects in mathematics. The distribution of primes — captured by the prime counting function $\pi(x)$ and the prime gaps $g_n = p_{n+1} - p_n$ — has been the subject of intense study since Euclid.

In this paper, we apply the machinery of persistent homology to the prime point cloud $P_N = \{p_1, p_2, \ldots, p_N\} \subset \mathbb{R}$. The Vietoris-Rips filtration $\mathcal{R}_\varepsilon(P_N)$ connects $p_i$ and $p_j$ whenever $|p_i - p_j| \leq \varepsilon$, producing a nested family of simplicial complexes indexed by the scale parameter $\varepsilon \geq 0$.

Our main contributions are:

1. **The 1D Rips Component Theorem** (Theorem 4.1): For any sorted finite point cloud on the real line with $n$ points, the number of connected components at scale $\varepsilon$ equals $\#\{i : g_i > \varepsilon\} + 1$.

2. **The Component Derivative Formula** (Theorem 5.1): The drop in components between consecutive integer scales $k$ and $k+1$ equals the number of gaps equal to $k+1$.

3. **The Telescoping Barcode Identity** (Theorem 8.1): The total bar length in the $H_0$ barcode of a strictly increasing sequence equals $f(n-1) - f(0)$.

4. **The 1D Barcode Stability Theorem** (Theorem 7.1): If two sequences are $\delta$-close pointwise, their gap functions differ by at most $2\delta$ in absolute value.

5. **Cramér's Conjecture in Barcode Form**: We reformulate Cramér's conjecture as a statement about the asymptotic behavior of the maximum bar length.

## 2. Preliminaries

### 2.1 Sequences and Gaps

**Definition 2.1** (Gap Function). For a sequence $f: \mathbb{N} \to \mathbb{N}$, the *gap function* is $\text{gap}_f(i) = f(i+1) - f(i)$.

**Definition 2.2** (Strict Monotonicity). A sequence $f$ is *strictly increasing on* $[0, n)$ if $f(i) < f(j)$ whenever $i < j < n$.

**Theorem 2.1** (Gap Positivity). If $f$ is strictly increasing on $[0, n)$ and $i + 1 < n$, then $\text{gap}_f(i) > 0$.

### 2.2 Gap Counting Functions

**Definition 2.3**. For a sequence $f$ with $n$ points:
- $\text{countGapsLE}(f, n, \varepsilon) = \#\{i < n-1 : \text{gap}_f(i) \leq \varepsilon\}$
- $\text{countGapsGT}(f, n, \varepsilon) = \#\{i < n-1 : \text{gap}_f(i) > \varepsilon\}$
- $\text{countGapsEq}(f, n, k) = \#\{i < n-1 : \text{gap}_f(i) = k\}$

**Theorem 2.2** (Gap Partition). $\text{countGapsLE}(f, n, \varepsilon) + \text{countGapsGT}(f, n, \varepsilon) = n - 1$.

*Proof*. The two filter predicates $\text{gap}(i) \leq \varepsilon$ and $\text{gap}(i) > \varepsilon$ partition the natural numbers, so the filtered sets are complementary subsets of $\{0, \ldots, n-2\}$. ∎

## 3. The Rips Filtration on a 1D Point Cloud

### 3.1 Definition

**Definition 3.1** (Rips Components). For a sequence $f$ with $n$ points, the number of Rips-connected components at scale $\varepsilon$ is:
$$C_\varepsilon(f, n) = n - \text{countGapsLE}(f, n, \varepsilon)$$

This definition captures the key 1D insight: in one dimension, two points $f(i)$ and $f(j)$ with $i < j$ are in the same connected component at scale $\varepsilon$ if and only if every consecutive gap between them is at most $\varepsilon$. Adjacent points merge when their gap is bridged, and each bridging reduces the component count by exactly one.

### 3.2 Monotonicity

**Theorem 3.1** (Monotonicity of Gap Counts). $\text{countGapsLE}(f, n, \varepsilon_1) \leq \text{countGapsLE}(f, n, \varepsilon_2)$ whenever $\varepsilon_1 \leq \varepsilon_2$.

*Proof*. The filter set for $\varepsilon_1$ is a subset of the filter set for $\varepsilon_2$, since $\text{gap}(i) \leq \varepsilon_1 \implies \text{gap}(i) \leq \varepsilon_2$. ∎

**Theorem 3.2** (Antitonicity of Components). $C_{\varepsilon_2}(f, n) \leq C_{\varepsilon_1}(f, n)$ whenever $\varepsilon_1 \leq \varepsilon_2$.

*Proof*. Direct from the definition $C_\varepsilon = n - \text{countGapsLE}(\varepsilon)$ and Theorem 3.1. ∎

### 3.3 Edge Monotonicity

**Definition 3.2** (Rips Edges). The edge set at scale $\varepsilon$ is:
$$E_\varepsilon(f, n) = \{(i, j) : i < j < n, f(j) - f(i) \leq \varepsilon\}$$

**Theorem 3.3** (Edge Monotonicity). $E_{\varepsilon_1}(f, n) \subseteq E_{\varepsilon_2}(f, n)$ whenever $\varepsilon_1 \leq \varepsilon_2$.

*Proof*. If $(i, j)$ satisfies $f(j) - f(i) \leq \varepsilon_1 \leq \varepsilon_2$, it satisfies the condition for $\varepsilon_2$ by transitivity. ∎

## 4. The 1D Rips Component Theorem

**Theorem 4.1** (1D Rips Component Theorem). For $n \geq 1$:
$$C_\varepsilon(f, n) = \text{countGapsGT}(f, n, \varepsilon) + 1$$

*Proof*. By the Gap Partition (Theorem 2.2), $\text{countGapsLE} + \text{countGapsGT} = n - 1$. Since $\text{countGapsLE} \leq n - 1$ (Theorem 2.3, as the filter is a subset of $\{0, \ldots, n-2\}$) and $n \geq 1$, we have:
$$C_\varepsilon = n - \text{countGapsLE} = n - (n - 1 - \text{countGapsGT}) = \text{countGapsGT} + 1$$
The subtraction is valid in $\mathbb{N}$ because $\text{countGapsLE} \leq n - 1 \leq n$. ∎

**Remark**. This theorem gives a clean interpretation: at scale $\varepsilon$, there is one component for each unresolved gap (gaps strictly larger than $\varepsilon$), plus the essential component that never dies.

## 5. The Component Derivative Formula

**Theorem 5.1** (Component Derivative). For $n \geq 1$:
$$C_k(f, n) - C_{k+1}(f, n) = \text{countGapsEq}(f, n, k+1)$$

*Proof*. By Theorem 4.1:
$$C_k - C_{k+1} = (\text{countGapsGT}(k) + 1) - (\text{countGapsGT}(k+1) + 1) = \text{countGapsGT}(k) - \text{countGapsGT}(k+1)$$
The difference $\text{countGapsGT}(k) - \text{countGapsGT}(k+1)$ counts gaps $g$ satisfying $k < g$ but not $k+1 < g$, i.e., $g = k+1$. ∎

**Corollary 5.1** (Twin Prime Counting). For the prime point cloud:
$$C_1(\text{prime}, n) - C_2(\text{prime}, n) = \pi_2(p_n)$$
where $\pi_2(x)$ is the twin prime counting function (counting pairs with gap exactly 2 among the first $n$ primes, with the special case of the gap $p_2 - p_1 = 1$ excluded).

## 6. The H₀ Barcode

**Definition 6.1** (H₀ Barcode). The $H_0$ barcode of a sequence $f$ with $n$ points is a list of $n-1$ bars, where bar $i$ has:
- Birth: 0
- Death: $\text{gap}_f(i)$
- Length: $\text{gap}_f(i)$

The essential class (the component that never dies) is omitted.

**Theorem 6.1** (Bar-Gap Correspondence). Each bar's length equals the corresponding gap: $\text{length}(\text{bar}_i) = \text{gap}_f(i)$.

**Theorem 6.2** (Barcode Size). The barcode has exactly $n-1$ bars.

## 7. The 1D Barcode Stability Theorem

**Definition 7.1** (δ-Closeness). Sequences $f$ and $g$ are *δ-close on* $[0, n)$ if $|f(i) - g(i)| \leq \delta$ for all $i < n$.

**Theorem 7.1** (1D Barcode Stability). If $f$ and $g$ are $\delta$-close on $[0, n)$ and $i + 1 < n$, then:
$$|\text{gap}_f(i) - \text{gap}_g(i)| \leq 2\delta$$

*Proof*. The gap difference decomposes as:
$$\text{gap}_f(i) - \text{gap}_g(i) = (f(i+1) - g(i+1)) - (f(i) - g(i))$$
Each term is bounded by $\delta$ in absolute value, so the difference is bounded by $2\delta$ by the triangle inequality. ∎

**Remark**. This is a 1D specialization of the bottleneck stability theorem for persistent homology. In general, the bottleneck distance between barcodes of two point clouds is bounded by the Hausdorff distance between the clouds. Our result gives an explicit, gap-level bound that is sharper in the 1D setting.

## 8. The Telescoping Identity

**Theorem 8.1** (Telescoping). For a strictly increasing sequence $f$ on $[0, n+1)$:
$$\sum_{i=0}^{n-1} \text{gap}_f(i) = f(n) - f(0)$$

*Proof*. By induction on $n$. The base case $n = 1$ is immediate. For the inductive step:
$$\sum_{i=0}^{n} \text{gap}_f(i) = \sum_{i=0}^{n-1} \text{gap}_f(i) + \text{gap}_f(n) = (f(n) - f(0)) + (f(n+1) - f(n)) = f(n+1) - f(0)$$
The subtraction is valid because $f$ is strictly increasing. ∎

**Corollary 8.1** (Total Bar Length). For a strictly increasing sequence:
$$\text{totalBarLength}(\text{barcode}(f, n)) = f(n-1) - f(0)$$

For primes: the total length of all bars in the prime H₀ barcode equals $p_n - p_1 = p_n - 2$.

## 9. Cramér's Conjecture in Barcode Language

**Conjecture 9.1** (Cramér's Barcode Conjecture). The maximum bar length in the $H_0$ barcode of the first $n$ primes satisfies:
$$\frac{\max_i \text{gap}(p_i)}{\left(\log p_n\right)^2} \to 1 \quad \text{as } n \to \infty$$

This is equivalent to the classical statement of Cramér's conjecture, translated into topological language. The conjecture predicts that the "connectivity scale" — the minimum $\varepsilon$ at which the prime point cloud becomes a single connected component — grows as $(\log p_n)^2$.

## 10. Computational Predictions and Falsifiable Conjectures

### 10.1 Exponential Distribution Conjecture

**Conjecture 10.1**. For primes up to $x$, the normalized bar lengths $g_i / \log(p_i)$ converge in distribution to $\text{Exp}(1)$ as $x \to \infty$.

**Test**: Compute the empirical CDF of normalized gaps for primes up to $10^6$ and compare with $1 - e^{-t}$ using the Kolmogorov-Smirnov statistic.

### 10.2 Scale-2 Persistence Conjecture

**Conjecture 10.2** (Topological Twin Prime Conjecture). The number of bars of length exactly 2 in the prime $H_0$ barcode is unbounded, i.e., $\text{countGapsEq}(\text{prime}, n, 2) \to \infty$.

This is equivalent to the twin prime conjecture.

## 11. Discussion

### 11.1 Relationship to Classical Results

Our framework provides a clean topological interpretation of several classical results:

- **Bertrand's Postulate**: For every $n$, there exists a prime between $n$ and $2n$. In barcode terms: no bar has length exceeding $p_n$ (i.e., the gap is always less than the prime itself).

- **Prime Number Theorem**: The average bar length near the $n$-th prime is $\sim \log(p_n)$.

- **Zhang's Theorem** (2013): There are infinitely many bars of length $\leq 70{,}000{,}000$.

- **Maynard-Tao** (2014): There are infinitely many bars of length $\leq 246$.

### 11.2 Advantages of the Topological Perspective

1. **Multi-scale analysis**: The filtration provides a natural hierarchy of scales, revealing different arithmetic phenomena at different resolutions.

2. **Stability**: The barcode is robust to perturbation, making it useful for studying approximate models.

3. **Computational tools**: Persistent homology has a mature computational ecosystem that can be directly applied to prime data.

## 12. Future Work

- Extend to higher-dimensional embeddings (e.g., $(p_n, p_{n+1})$) to study $H_1$ features.
- Analyze the barcode entropy as a measure of prime regularity.
- Connect the filtration structure to sieve-theoretic methods.
- Study the persistence diagram of the Gaussian prime lattice in $\mathbb{Z}[i]$.

## References

1. Cramér, H. (1936). On the order of magnitude of the difference between consecutive prime numbers. *Acta Arithmetica*, 2(1), 23-46.
2. Edelsbrunner, H., & Harer, J. (2010). *Computational Topology: An Introduction*. American Mathematical Society.
3. Carlsson, G. (2009). Topology and Data. *Bulletin of the AMS*, 46(2), 255-308.
4. Maynard, J. (2015). Small gaps between primes. *Annals of Mathematics*, 181(1), 383-413.
5. Cohen-Steiner, D., Edelsbrunner, H., & Harer, J. (2007). Stability of persistence diagrams. *Discrete & Computational Geometry*, 37(1), 103-120.
6. Granville, A. (1995). Harald Cramér and the distribution of prime numbers. *Scandinavian Actuarial Journal*, 1995(1), 12-28.
