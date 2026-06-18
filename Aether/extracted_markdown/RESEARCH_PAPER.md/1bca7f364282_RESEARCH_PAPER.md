# Iterated Shadow Geometry for Multivariate Polynomial Supports

## Abstract

We develop the theory of **iterated support shadows** for multivariate polynomials: a framework that precisely characterizes the combinatorial footprint of higher-order differentiation on exponent sets. Our central result, the **k-th Shadow Theorem**, establishes that the support of the family of all k-th order mixed partial derivatives of a polynomial f over a characteristic-zero ring is exactly the k-th shadow of the Newton support of f. We prove a **multi-index coefficient transport formula** expressing each derivative coefficient as a product of ascending factorials times a single ancestor coefficient, a **semigroup law** showing that shadow operations compose additively, and provide a **mass decomposition theorem** for multi-indices. We define the **discrete exchange property** as a finitary proxy for M-convexity and formulate the **Shadow Log-Concavity Conjecture**, supported by extensive computational experiments over matroid basis supports, simplex supports, and random exchange families. All main theorems are verified in the Lean 4 proof assistant with the Mathlib library.

---

## 1. Introduction

### 1.1 Motivation

The Newton support of a multivariate polynomial — the set of exponent vectors at which the polynomial has nonzero coefficients — is a fundamental combinatorial invariant. It determines the Newton polytope, controls the monomial complexity of the polynomial, and governs the behavior of systems of polynomial equations through the BKK theorem and its generalizations.

When we differentiate a polynomial, the support changes: some exponents shift, some terms vanish if their coefficients become zero. For *individual* mixed partial derivatives, the shift is deterministic: differentiating $\partial/\partial x_i$ subtracts one from the $i$-th exponent. But for the *family* of all mixed partials of a given order, the picture becomes combinatorial: which exponents survive across all possible derivative multi-indices?

This paper answers this question completely for polynomials over characteristic-zero rings: the surviving exponents are exactly the **k-th shadow** of the original support. This is not a bound or an approximation — it is an exact equality.

### 1.2 Relationship to Prior Work

**Lorentzian polynomials.** Brändén and Huh [1] proved that Lorentzian polynomials have log-concave coefficient sequences. Their theory relies on the fact that partial derivatives of Lorentzian polynomials remain Lorentzian. Our shadow framework provides a combinatorial skeleton for tracking which monomials survive this derivative recursion.

**M-convexity and discrete convex analysis.** Murota [2] developed the theory of M-convex sets and functions as discrete analogues of convex analysis. Our discrete exchange property is a finitary version of M-convexity adapted to finite support sets.

**Support compression for matroid polynomials.** The work on support compression for matroid basis generating polynomials [3] established that derivative leaf sets equal matroid independent sets. Our k-th shadow theorem vastly generalizes this from the multiaffine setting to arbitrary homogeneous and inhomogeneous polynomials.

**Weighted support shadows.** The quadratic shadow theory [4] established the exact equality between second-derivative support sets and quadratic shadows. Our work extends this from k=2 to arbitrary k, and provides the algebraic infrastructure (the coefficient transport formula) that makes the general case tractable.

### 1.3 Summary of Contributions

1. **Definition of k-th shadow** (Definition 3.1): A combinatorial operation on finite sets of multi-indices capturing all possible downward shifts of total mass k.

2. **Multi-index coefficient transport formula** (Theorem 4.3): An explicit formula expressing $\text{coeff}_\beta(\partial^\tau f)$ as a product of ascending factorials times $\text{coeff}_{\beta+\tau}(f)$.

3. **Support criterion** (Theorem 4.4): $\text{coeff}_\beta(\partial^\tau f) \neq 0$ if and only if $\text{coeff}_{\beta+\tau}(f) \neq 0$, for characteristic-zero rings.

4. **k-th Shadow Theorem** (Theorem 5.1): Exact equality between the k-th shadow of the Newton support and the union of derivative supports.

5. **Semigroup law** (Theorem 6.1): $\text{Shadow}_{a+b}(S) = \text{Shadow}_b(\text{Shadow}_a(S))$.

6. **Mass decomposition** (Lemma 6.2): Any multi-index of mass $a+b$ decomposes as a sum of multi-indices of mass $a$ and $b$.

7. **Shadow Log-Concavity Conjecture** (Conjecture 7.1): For M-convex support sets, the shadow profile is log-concave.

8. **Complete formal verification** in Lean 4 with the Mathlib library.

---

## 2. Notation and Preliminaries

Let $n \geq 1$ be the number of variables. A **multi-index** is an element $\alpha \in \mathbb{N}^n$ (equivalently, a finitely supported function $\text{Fin}\,n \to \mathbb{N}$). The **mass** of $\alpha$ is $|\alpha| = \sum_{i=0}^{n-1} \alpha_i$.

For $\alpha, \beta \in \mathbb{N}^n$, write $\alpha \leq \beta$ for the coordinatewise partial order: $\alpha_i \leq \beta_i$ for all $i$. Write $\alpha - \beta$ for the truncated subtraction: $(\alpha - \beta)_i = \max(\alpha_i - \beta_i, 0)$.

The **Newton support** of a polynomial $f \in R[x_0, \ldots, x_{n-1}]$ is $\text{Supp}(f) = \{\alpha : \text{coeff}_\alpha(f) \neq 0\}$.

The **partial derivative** $\partial_i f = \frac{\partial f}{\partial x_i}$ is defined as the unique derivation sending $x_i \mapsto 1$ and $x_j \mapsto 0$ for $j \neq i$. For a monomial $x^\alpha$, we have $\partial_i(x^\alpha) = \alpha_i \cdot x^{\alpha - e_i}$ where $e_i$ is the $i$-th standard basis vector.

---

## 3. Definitions

### 3.1 k-th Shadow

**Definition 3.1** (k-th Shadow). Let $S \subseteq \mathbb{N}^n$ be a finite set. The **k-th shadow** of $S$ is:
$$\text{Shadow}_k(S) = \{\beta \in \mathbb{N}^n : \exists \alpha \in S, \exists \tau \in \mathbb{N}^n, \, \tau \leq \alpha, \, |\tau| = k, \, \beta = \alpha - \tau\}$$

Equivalently, $\beta \in \text{Shadow}_k(S)$ iff there exists $\alpha \in S$ such that $\beta \leq \alpha$ and $|\alpha| - |\beta| \geq k$ with $\alpha - \beta$ having mass at least $k$, and we can find a path of mass exactly $k$ from $\alpha$ down to $\beta$.

**Properties:**
- $\text{Shadow}_0(S) = S$ (the only mass-0 multi-index is 0).
- $\text{Shadow}_k(S) \subseteq \text{Shadow}_{k'}(S')$ whenever $S \subseteq S'$ (monotonicity).
- $\text{Shadow}_k(\emptyset) = \emptyset$ for all $k$.

### 3.2 Iterated Partial Derivative

**Definition 3.2** (Iterated Mixed Partial Derivative). For a multi-index $\tau \in \mathbb{N}^n$, define:
$$\partial^\tau f = \prod_{i=0}^{n-1} \left(\frac{\partial}{\partial x_i}\right)^{\tau_i} f$$

Since mixed partial derivatives of polynomials commute, the order of application is irrelevant.

In our formalization, we define $\partial^\tau f$ by processing coordinates $0, 1, \ldots, n-1$ sequentially:
$$\partial^\tau f = \partial_{n-1}^{\tau_{n-1}} \circ \cdots \circ \partial_1^{\tau_1} \circ \partial_0^{\tau_0}(f)$$

### 3.3 Derivative Shadow Profile

**Definition 3.3**. The **derivative shadow profile** of $f$ is the function:
$$\text{DSP}(f)(k) = |\text{Shadow}_k(\text{Supp}(f))|$$

### 3.4 Discrete Exchange Property

**Definition 3.4**. A finite set $S \subseteq \mathbb{N}^n$ satisfies the **discrete exchange property** if for all $\alpha, \beta \in S$ and all $i$ with $\alpha_i > \beta_i$, there exists $j$ with $\beta_j > \alpha_j$ such that $\alpha - e_i + e_j \in S$.

This is a finitary version of M-convexity. For matroid basis indicator vectors, it reduces to the symmetric basis exchange axiom.

---

## 4. Coefficient Transport Formula

### 4.1 Single Derivative

**Theorem 4.1** (Single Derivative Coefficient). For any polynomial $f$, variable $i$, and multi-index $m$:
$$\text{coeff}_m(\partial_i f) = (m_i + 1) \cdot \text{coeff}_{m + e_i}(f)$$

*Proof sketch.* By linearity, it suffices to check on monomials. For $f = c \cdot x^\alpha$:
$$\partial_i(c \cdot x^\alpha) = c \cdot \alpha_i \cdot x^{\alpha - e_i}$$
Taking $\text{coeff}_m$ gives $c \cdot \alpha_i$ when $m = \alpha - e_i$ (i.e., $\alpha = m + e_i$), and 0 otherwise. Since $\alpha_i = (m + e_i)_i = m_i + 1$, the formula follows. $\square$

### 4.2 Iterated Single-Variable Derivative

**Theorem 4.2** (Iterated Derivative Coefficient). For variable $i$, iteration count $k$, and multi-index $m$:
$$\text{coeff}_m(\partial_i^k f) = \left(\prod_{j=0}^{k-1}(m_i + j + 1)\right) \cdot \text{coeff}_{m + k \cdot e_i}(f)$$

*Proof.* By induction on $k$. The base case $k = 0$ is trivial. For the inductive step:
$$\text{coeff}_m(\partial_i^{k+1} f) = \text{coeff}_m(\partial_i(\partial_i^k f)) = (m_i + 1) \cdot \text{coeff}_{m+e_i}(\partial_i^k f)$$
By the inductive hypothesis:
$$= (m_i + 1) \cdot \prod_{j=0}^{k-1}((m+e_i)_i + j + 1) \cdot \text{coeff}_{(m+e_i) + k \cdot e_i}(f)$$
Since $(m+e_i)_i = m_i + 1$, the inner product becomes $\prod_{j=0}^{k-1}(m_i + j + 2) = \prod_{j=1}^{k}(m_i + j + 1)$. Combining with the leading factor gives $\prod_{j=0}^{k}(m_i + j + 1)$. $\square$

### 4.3 Full Multi-Index Formula

**Theorem 4.3** (Multi-Index Coefficient Transport). For any multi-index $\tau$ and polynomial $f$:
$$\text{coeff}_\beta(\partial^\tau f) = \left(\prod_{i=0}^{n-1} \prod_{j=0}^{\tau_i - 1}(\beta_i + j + 1)\right) \cdot \text{coeff}_{\beta + \tau}(f)$$

*Proof.* By induction on the list of coordinates being processed. The key insight is that applying $\partial_i^{\tau_i}$ shifts only the $i$-th coordinate of the lookup index, so the scalar factors from different coordinates are independent. Formally, we prove a helper lemma for an arbitrary nodup sublist of coordinates and use it with $[0, 1, \ldots, n-1]$.

The scalar factor $\prod_i \prod_j (\beta_i + j + 1)$ equals $\prod_i (\beta_i + 1)(\beta_i + 2) \cdots (\beta_i + \tau_i)$, which is a product of ascending factorials. $\square$

### 4.4 Support Criterion

**Theorem 4.4** (Support Criterion). Over a characteristic-zero ring with no zero-divisors for $\mathbb{N}$-action:
$$\text{coeff}_\beta(\partial^\tau f) \neq 0 \iff \text{coeff}_{\beta + \tau}(f) \neq 0$$

*Proof.* The scalar factor $\prod_i \prod_j (\beta_i + j + 1)$ is a positive integer (each factor is at least 1). In a characteristic-zero ring, the image of a positive integer under the canonical map $\mathbb{N} \to R$ is nonzero. By the no-zero-divisors condition, the product is nonzero iff the ancestor coefficient is nonzero. $\square$

---

## 5. The k-th Shadow Theorem

**Theorem 5.1** (k-th Shadow Theorem). Let $f$ be a polynomial over a characteristic-zero ring $R$ with $\text{NoZeroSMulDivisors}(\mathbb{N}, R)$. Then:
$$\beta \in \text{Shadow}_k(\text{Supp}(f)) \iff \exists \tau \text{ with } |\tau| = k : \text{coeff}_\beta(\partial^\tau f) \neq 0$$

*Proof.*
$(\Rightarrow)$: Given $\beta \in \text{Shadow}_k(\text{Supp}(f))$, there exist $\alpha \in \text{Supp}(f)$, $\tau \leq \alpha$ with $|\tau| = k$ and $\beta = \alpha - \tau$. Then $\beta + \tau = \alpha$, so $\text{coeff}_{\beta + \tau}(f) = \text{coeff}_\alpha(f) \neq 0$. By the support criterion, $\text{coeff}_\beta(\partial^\tau f) \neq 0$.

$(\Leftarrow)$: Given $\tau$ with $|\tau| = k$ and $\text{coeff}_\beta(\partial^\tau f) \neq 0$, the support criterion gives $\text{coeff}_{\beta + \tau}(f) \neq 0$, so $\alpha := \beta + \tau \in \text{Supp}(f)$. Since $\tau \leq \beta + \tau = \alpha$ and $\beta = \alpha - \tau$ (from $\beta + \tau - \tau = \beta$), we have $\beta \in \text{Shadow}_k(\text{Supp}(f))$. $\square$

---

## 6. Semigroup Law

**Lemma 6.2** (Mass Decomposition). Any multi-index $\tau$ with $|\tau| = a + b$ can be written as $\tau = \tau_1 + \tau_2$ with $|\tau_1| = a$ and $|\tau_2| = b$.

*Proof.* By induction on $a$. For $a = 0$, take $\tau_1 = 0$ and $\tau_2 = \tau$. For the inductive step, since $|\tau| \geq 1$, some coordinate $\tau_i \geq 1$. Set $\tau' = \tau - e_i$ with $|\tau'| = a - 1 + b$. By induction, $\tau' = \tau_1' + \tau_2'$ with $|\tau_1'| = a - 1$, $|\tau_2'| = b$. Then $\tau_1 = \tau_1' + e_i$ and $\tau_2 = \tau_2'$ work. $\square$

**Theorem 6.1** (Semigroup Law). For any finite $S \subseteq \mathbb{N}^n$ and $a, b \in \mathbb{N}$:
$$\text{Shadow}_{a+b}(S) = \text{Shadow}_b(\text{Shadow}_a(S))$$

*Proof.*
$(\subseteq)$: Given $\beta \in \text{Shadow}_{a+b}(S)$, let $\alpha \in S$, $\sigma \leq \alpha$, $|\sigma| = a+b$, $\beta = \alpha - \sigma$. Decompose $\sigma = \tau_1 + \tau_2$ with $|\tau_1| = a$, $|\tau_2| = b$. Then $\gamma = \alpha - \tau_1 \in \text{Shadow}_a(S)$, and $\tau_2 \leq \gamma$ (since $\tau_1 + \tau_2 \leq \alpha$ implies $\tau_2 \leq \alpha - \tau_1$). Moreover $\gamma - \tau_2 = (\alpha - \tau_1) - \tau_2 = \alpha - (\tau_1 + \tau_2) = \beta$.

$(\supseteq)$: Given $\beta \in \text{Shadow}_b(\text{Shadow}_a(S))$, let $\gamma \in \text{Shadow}_a(S)$, $\tau_2 \leq \gamma$, $|\tau_2| = b$, $\beta = \gamma - \tau_2$. Let $\alpha \in S$, $\tau_1 \leq \alpha$, $|\tau_1| = a$, $\gamma = \alpha - \tau_1$. Then $\sigma = \tau_1 + \tau_2$ with $|\sigma| = a + b$, $\sigma \leq \alpha$, and $\beta = \alpha - \sigma$. $\square$

---

## 7. The Shadow Log-Concavity Conjecture

### 7.1 Statement

**Conjecture 7.1** (Shadow Log-Concavity for Exchange Supports). If $S \subseteq \mathbb{N}^n$ is a finite set satisfying the discrete exchange property (Definition 3.4), then the shadow profile $a_k = |\text{Shadow}_k(S)|$ is log-concave:
$$a_k^2 \geq a_{k-1} \cdot a_{k+1} \quad \text{for all } 1 \leq k \leq \max_{\alpha \in S} |\alpha| - 1$$

### 7.2 Computational Evidence

We tested this conjecture systematically:

| **Support family** | **Parameters tested** | **Exchange?** | **Log-concave?** | **Counterexamples** |
|---|---|---|---|---|
| Uniform matroid $U_{r,n}$ | $3 \leq n \leq 9$, $1 \leq r < n$ | Yes | Yes | 0 |
| Full simplex (all monomials of degree d) | $2 \leq n \leq 5$, $2 \leq d \leq 6$ | Yes | Yes | 0 |
| Random exchange families | $n \leq 6$, $d \leq 5$, 600+ samples | Yes (by construction) | Yes | 0 |
| Graphic matroid (K4) | Fixed | Yes | Yes | 0 |
| Random non-exchange families | $n \leq 6$, $d \leq 5$, 2000+ samples | No | Mixed | N/A |

No counterexamples were found among exchange families. Non-exchange families can fail log-concavity, confirming that the exchange hypothesis is essential.

### 7.3 Special Cases

For full simplex supports $S_d^n = \{\alpha \in \mathbb{N}^n : |\alpha| = d\}$, we have $|\text{Shadow}_k(S_d^n)| = \binom{n + d - k - 1}{n - 1}$. The sequence $\binom{n+d-k-1}{n-1}$ for $k = 0, 1, \ldots, d$ is known to be log-concave (it equals the number of monomials of degree $d - k$ in $n$ variables).

For uniform matroid $U_{r,n}$ basis supports, the shadow profile is $|\text{Shadow}_k| = \binom{n}{r-k}$, and log-concavity follows from the log-concavity of binomial coefficients.

### 7.4 Stronger Ratio-Monotonicity

We also tested the stronger **ratio-monotonicity** condition: $a_{k+1}/a_k \leq a_k/a_{k-1}$ for all admissible $k$. This holds for all simplex supports and uniform matroids, and is implied by ultra-log-concavity.

---

## 8. Algorithms

### 8.1 Shadow Computation

**Algorithm 1: Compute k-th Shadow**

```
Input: S ⊂ ℕⁿ (finite), k ∈ ℕ
Output: Shadow_k(S)

1. result ← ∅
2. taus ← enumerate all τ ∈ ℕⁿ with |τ| = k
3. for each α ∈ S:
4.     for each τ ∈ taus:
5.         if τ ≤ α:
6.             result ← result ∪ {α - τ}
7. return result
```

**Complexity:** $O(|S| \cdot \binom{n+k-1}{k})$ time, $O(|\text{result}|)$ space.

### 8.2 Shadow Profile

**Algorithm 2: Compute Shadow Profile**

```
Input: S ⊂ ℕⁿ (finite)
Output: (a_0, a_1, ..., a_d) where d = max_{α ∈ S} |α|

1. d ← max{|α| : α ∈ S}
2. for k = 0, 1, ..., d:
3.     a_k ← |Shadow_k(S)|
4. return (a_0, ..., a_d)
```

**Complexity:** $O(d \cdot |S| \cdot \binom{n+d-1}{d})$ total.

### 8.3 Exchange Property Testing

**Algorithm 3: Test Discrete Exchange Property**

```
Input: S ⊂ ℕⁿ (finite)
Output: Boolean

1. for each α, β ∈ S:
2.     for each i with α_i > β_i:
3.         found ← false
4.         for each j with β_j > α_j:
5.             if α - e_i + e_j ∈ S: found ← true; break
6.         if not found: return false
7. return true
```

**Complexity:** $O(|S|^2 \cdot n^2)$ with hash set for $S$.

---

## 9. Discussion

### 9.1 Significance

The k-th Shadow Theorem provides the first complete characterization of the support geometry of iterated derivatives for arbitrary multivariate polynomials. Previous results were limited to specific cases: first derivatives (well-known), second derivatives (quadratic shadow theory [4]), or specific polynomial families (matroid basis polynomials [3]).

The semigroup law elevates the shadow operation from a combinatorial gadget to a genuine algebraic structure. It means that the "derivative complexity decay" of a polynomial is governed by a discrete dynamical system on the lattice of multi-indices.

### 9.2 Connections to Lorentzian Polynomials

The log-concavity conjecture, if proved, would establish a direct link between the combinatorial shadow geometry and the analytic theory of Lorentzian polynomials [1]. In the Lorentzian framework, the key property is that the Hessian matrix of a Lorentzian polynomial has exactly one positive eigenvalue. Our shadow profile captures the "combinatorial trace" of this spectral property through the derivative tower.

### 9.3 Limitations

1. The coefficient transport formula requires characteristic zero. In positive characteristic, the ascending factorial factors can vanish, allowing "accidental" cancellations that break the exact shadow correspondence.

2. The shadow profile can grow exponentially: $|\text{Shadow}_k(S)|$ can be as large as $\binom{n+k-1}{k}$ even for $|S| = 1$.

3. The log-concavity conjecture is open and may require techniques beyond the scope of elementary combinatorics — perhaps connections to the hard Lefschetz theorem or Hodge-Riemann relations.

---

## 10. Future Work

1. **Prove the Shadow Log-Concavity Conjecture** for matroid basis supports using the Brändén-Huh Lorentzian machinery.

2. **Tropical shadow theory**: Define shadows for tropical polynomials and connect to tropical Hodge theory.

3. **Shadow complexity bounds**: Use shadow profiles to derive circuit lower bounds for sparse polynomial identity testing.

4. **Continuous shadow flow**: Study the limit of shadow profiles as the degree grows, connecting to continuous convex geometry.

5. **Weighted shadows**: Extend the theory to weighted supports where each monomial carries a multiplicity, connecting to representation theory.

---

## References

[1] P. Brändén and J. Huh. "Lorentzian polynomials." *Annals of Mathematics*, 192(3):821–891, 2020.

[2] K. Murota. *Discrete Convex Analysis.* SIAM, 2003.

[3] Support compression for matroid basis polynomials. Formal verification in the Catalog project.

[4] Weighted support shadow for homogeneous polynomials. Formal verification in the Catalog project.

[5] J. Huh. "Combinatorial applications of the Hodge-Riemann relations." *Proceedings of the ICM*, 2018.

[6] A. Schrijver. *Combinatorial Optimization: Polyhedra and Efficiency.* Springer, 2003.
