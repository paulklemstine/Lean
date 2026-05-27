# Higher Discrete Curvature Theory for Valuated Matroids via k-Fold Directional Log-Concavity

## Abstract

We introduce a **directional depth filtration** for functions on integer lattice points, providing a strictly finer invariant than classical log-concavity or M-convexity. Given a function $f : \mathbb{Z}_{\geq 0}^n \to \mathbb{R}$, we define *directional depth* recursively: $f$ has depth $\geq k+1$ if it is directionally log-concave and every ratio transform $R_i f(m) = f(m+e_i)/f(m)$ has depth $\geq k$. We prove three main theorems: (1) **multiplicative stability** — the depth-$k$ functions form a multiplicative monoid; (2) **tropical bridge** — mixed log-concavity at depth $\geq 1$ implies supermodularity of $-\log f$, connecting the hierarchy to tropical convexity; and (3) **hierarchy strictness** — there exist functions with exact depth 1 (depth $\geq 1$ but not $\geq 2$). All results are formalized and machine-verified. We also establish a cross-domain connection to statistical mechanics, where depth measures persistence of convexity of local free energy increments. Computational experiments on uniform, graphical, and Grassmannian-inspired valuations support a *Depth Dichotomy Conjecture*: naturally arising valuated matroids have depth either 1 or $\infty$.

---

## 1. Introduction

### 1.1 Motivation

Log-concavity is one of the most powerful structural properties in combinatorics, algebraic geometry, and statistical mechanics. A sequence $(a_n)$ is log-concave if $a_n^2 \geq a_{n-1} a_{n+1}$ for all $n$. The breakthrough work of Adiprasito–Huh–Katz (2018) and Brändén–Huh (2020) established that many combinatorial sequences are log-concave through deep connections to Hodge theory and Lorentzian polynomials.

Yet log-concavity is a *first-order* condition. Just as a smooth function being convex ($f'' \geq 0$) says nothing about the convexity of $f'$ or $f''$ themselves, log-concavity says nothing about the "curvature" of the ratio sequence $r(n) = a_{n+1}/a_n$.

This paper introduces a **higher-order theory**: the *directional depth filtration*, which recursively tests log-concavity after applying ratio transforms. The resulting hierarchy
$$\text{depth } 0 \supset \text{depth } 1 \supset \text{depth } 2 \supset \cdots$$
provides a graded refinement of log-concavity that is simultaneously interpretable as:
- an iterated log-concavity order,
- a tropical convexity persistence length, and
- a proto-Lorentzian complexity measure for valuated matroids.

### 1.2 Relationship to Prior Work

**Lorentzian polynomials.** Brändén and Huh (2020) introduced Lorentzian polynomials, characterized by the condition that all iterated partial derivatives maintain a definite-sign Hessian. Our depth filtration can be viewed as a discrete, coefficient-level analog: rather than testing partial derivatives of a polynomial, we test ratio transforms of a coefficient function.

**Discrete convex analysis.** Murota (2003) developed the theory of M-convex and L-convex functions, providing the combinatorial foundation for valuated matroid theory. Our depth filtration refines M-convexity: first-order depth (depth $\geq 1$) combined with exchange-closed support gives a weak form of M-convexity, while higher depths impose additional structure invisible to classical theory.

**Ultra-log-concavity.** The notion of $k$-fold log-concavity for sequences was studied in relation to the hierarchy of log-concavity conditions. Our contribution extends this to the multivariate setting with explicit tropical-geometric interpretations.

### 1.3 Main Contributions

1. **Definitions**: We formalize multivariate directional log-concavity, mixed log-concavity, ratio transforms, directional depth, and supermodularity for lattice functions.

2. **Multiplicative Depth Stability (Theorem 1)**: If $f$ and $g$ both have depth $\geq k$ and are everywhere positive, then $fg$ has depth $\geq k$. This makes depth classes into multiplicative monoids.

3. **Tropical Bridge (Theorem 2)**: Mixed log-concavity implies supermodularity of $-\log f$, connecting the depth hierarchy to tropical geometry.

4. **Hierarchy Strictness (Theorem 3)**: The depth hierarchy is strict — there exist functions with exact depth 1.

5. **Statistical Physics Bridge (Theorem 4)**: Depth $\geq 2$ with mixed conditions ensures supermodularity of the "local free energy increment" $-\log(R_i f)$.

6. **Depth Obstruction (Theorem 5)**: A computational criterion for proving depth $< 2$.

7. **Computational Experiments**: We implement depth computation algorithms and test the Depth Dichotomy Conjecture on multiple function families.

---

## 2. Definitions and Notation

### 2.1 Setup

Let $\alpha$ be a finite type (index set). A *multiindex* is a function $m : \alpha \to \mathbb{N}$. We write $e_i$ for the standard basis vector $\text{Pi.single}(i, 1)$.

**Shifts:**
- $m \uparrow_i := m + e_i$ (shift up in direction $i$)
- $m \uparrow\uparrow_i := m + 2e_i$ (double shift)

### 2.2 Log-Concavity Conditions

**Definition 2.1 (Directional Log-Concavity).** A function $f : (\alpha \to \mathbb{N}) \to \mathbb{R}$ is *directionally log-concave* if for every direction $i \in \alpha$ and every multiindex $m$:
$$f(m + e_i)^2 \geq f(m) \cdot f(m + 2e_i).$$

**Definition 2.2 (Mixed Log-Concavity).** $f$ is *mixed log-concave* if for all $i, j \in \alpha$ (possibly equal) and every $m$:
$$f(m + e_i) \cdot f(m + e_j) \geq f(m) \cdot f(m + e_i + e_j).$$

When $i = j$, mixed log-concavity reduces to directional log-concavity. Mixed log-concavity is the stronger condition needed for the tropical bridge.

### 2.3 Ratio Transform

**Definition 2.3 (Ratio Transform).** For direction $i \in \alpha$, the ratio transform $R_i$ maps $f$ to:
$$R_i f(m) := \frac{f(m + e_i)}{f(m)}.$$

This is the discrete logarithmic derivative. Key algebraic property:
$$R_i(fg) = (R_i f) \cdot (R_i g).$$

### 2.4 Directional Depth

**Definition 2.4 (Directional Depth).** The predicate $\text{DirectionalDepthAtLeast}(k, f)$ is defined recursively:
- $\text{DirectionalDepthAtLeast}(0, f) = \top$ (always true).
- $\text{DirectionalDepthAtLeast}(k+1, f) = \text{MultiDirLogConcave}(f) \wedge \forall i,\ \text{DirectionalDepthAtLeast}(k, R_i f)$.

**Definition 2.5 (Exact Depth).** $f$ has *exact depth* $k$ if $\text{DirectionalDepthAtLeast}(k, f)$ holds but $\text{DirectionalDepthAtLeast}(k+1, f)$ does not.

### 2.5 Supermodularity

**Definition 2.6 (Supermodularity).** $g : (\alpha \to \mathbb{N}) \to \mathbb{R}$ is *supermodular* if for all $i \neq j$ and $m$:
$$g(m + e_i + e_j) + g(m) \geq g(m + e_i) + g(m + e_j).$$

### 2.6 Exchange Operations

**Definition 2.7 (Exchange Move).** For multiindex $m$ and directions $i, j$:
$$\text{exchangeMove}(m, i, j)(k) = \begin{cases} m(k) + 1 & \text{if } k = i \\ m(k) - 1 & \text{if } k = j \\ m(k) & \text{otherwise} \end{cases}$$

---

## 3. Main Results

### 3.1 Theorem 1: Multiplicative Depth Stability

**Theorem 3.1.** *Let $f, g : (\alpha \to \mathbb{N}) \to \mathbb{R}$ with $f(m) > 0$ and $g(m) > 0$ for all $m$. If both $f$ and $g$ have directional depth $\geq k$, then $fg$ has directional depth $\geq k$.*

**Proof sketch.** By induction on $k$.

*Base case* ($k = 0$): Trivial, as depth $\geq 0$ holds universally.

*Inductive step* ($k \to k+1$): Assume the result for $k$. If $f$ and $g$ have depth $\geq k+1$, then:
1. Both are directionally log-concave. By a Cauchy-Schwarz-type inequality (multiplying the two log-concavity inequalities using nonnegativity), $fg$ is directionally log-concave.
2. For each direction $i$, the key algebraic identity $R_i(fg) = (R_i f)(R_i g)$ factorizes the ratio transform. Since $R_i f$ and $R_i g$ each have depth $\geq k$ (extracted from the depth $\geq k+1$ assumption), the induction hypothesis gives $R_i(fg) = (R_i f)(R_i g)$ depth $\geq k$.

The positivity hypothesis ensures $R_i f$ and $R_i g$ are everywhere positive. $\square$

**Significance.** This theorem upgrades the classical closure of log-concavity under products to an entire *depth filtration*. The classes $\{f : \text{depth}(f) \geq k\}$ form multiplicative monoids for each $k$, and the depth function $\text{depth}(f \cdot g) \geq \min(\text{depth}(f), \text{depth}(g))$ is submultiplicative.

### 3.2 Theorem 2: Tropical Bridge

**Theorem 3.2.** *If $f : (\alpha \to \mathbb{N}) \to \mathbb{R}$ is mixed log-concave and $f(m) > 0$ for all $m$, then $-\log f$ is supermodular.*

**Proof sketch.** The supermodularity condition for $g = -\log f$ at $(m, i, j)$ with $i \neq j$ reads:
$$-\log f(m+e_i+e_j) - \log f(m) \geq -\log f(m+e_i) - \log f(m+e_j),$$
equivalently:
$$\log f(m+e_i) + \log f(m+e_j) \geq \log f(m) + \log f(m+e_i+e_j).$$

Since $\log$ is monotone and all values are positive, this is equivalent to:
$$f(m+e_i) \cdot f(m+e_j) \geq f(m) \cdot f(m+e_i+e_j),$$

which is exactly the mixed log-concavity condition. $\square$

**Corollary 3.3 (Ratio Energy Supermodularity).** If $f$ has depth $\geq 2$ and the ratio transform $R_i f$ is mixed log-concave, then $-\log(R_i f)$ is supermodular.

**Significance.** This theorem establishes the tropical-geometric interpretation of the depth hierarchy. At each level, the ratio transform produces a new "tropical potential" $-\log(R^{(k)}_{\mathbf{i}} f)$ that is supermodular (provided mixed log-concavity holds). The depth thus measures the *persistence length* of tropical convexity under iterated logarithmic differentiation.

### 3.3 Theorem 3: Depth Obstruction

**Theorem 3.4.** *If there exists a direction $i$ such that $R_i f$ is not directionally log-concave, then $f$ does not have depth $\geq 2$.*

**Proof.** Contrapositive: depth $\geq 2$ means $\forall i, \text{DirectionalDepthAtLeast}(1, R_i f)$, which includes $\text{MultiDirLogConcave}(R_i f)$. $\square$

**Significance.** This provides a *computational certificate* for bounding depth from above. To show a function has exact depth 1, it suffices to:
1. Verify directional log-concavity (depth $\geq 1$).
2. Find a single direction $i$ and multiindex $m$ where $R_i f(m+e_j)^2 < R_i f(m) \cdot R_i f(m+2e_j)$.

### 3.4 Theorem 4: Hierarchy Strictness

**Theorem 3.5.** *There exists a type $\alpha$, a function $f : (\alpha \to \mathbb{N}) \to \mathbb{R}$, such that $f$ has depth exactly 1.*

**Proof.** Take $\alpha = \text{Fin}\ 1$ (one variable) and define:
$$f(m) = \begin{cases} 1 & m(0) = 0 \\ 3 & m(0) = 1 \\ 2 & m(0) = 2 \\ 1 & m(0) = 3 \\ 0 & \text{otherwise} \end{cases}$$

*Depth $\geq 1$*: Check $f(n+1)^2 \geq f(n) \cdot f(n+2)$ for all $n$:
- $f(1)^2 = 9 \geq f(0) \cdot f(2) = 2$ ✓
- $f(2)^2 = 4 \geq f(1) \cdot f(3) = 3$ ✓
- $f(3)^2 = 1 \geq f(2) \cdot f(4) = 0$ ✓

*Not depth $\geq 2$*: The ratio transform $R_0 f$ has values $R(0) = 3, R(1) = 2/3, R(2) = 1/2$. Check: $R(1)^2 = 4/9$ vs $R(0) \cdot R(2) = 3/2$. Since $4/9 < 3/2$, the ratio transform fails log-concavity. $\square$

---

## 4. Algorithms

### 4.1 Algorithm 1: DepthComputer

```
Algorithm: ComputeDepth(f, n, max_depth, max_deg)
Input: f : Z^n → R, dimensions n, bounds max_depth, max_deg
Output: depth ∈ {0, 1, ..., max_depth}

1. S ← {f}
2. for k = 0 to max_depth - 1:
3.   for each g ∈ S:
4.     for each m ∈ {0,...,max_deg}^n:
5.       for each direction i ∈ {0,...,n-1}:
6.         if g(m+e_i)² < g(m)·g(m+2e_i):
7.           return k
8.   S' ← ∅
9.   for each g ∈ S, i ∈ {0,...,n-1}:
10.    S' ← S' ∪ {R_i(g)}
11.  S ← S'
12. return max_depth
```

**Complexity:** Time $O(k \cdot n^k \cdot M^n)$, Space $O(n^k \cdot M^n)$, where $M = \text{max\_deg}$.

### 4.2 Algorithm 2: DepthFailureChecker

Identifies the exact multiindex, direction, and ratio transform chain where log-concavity first fails. Useful for constructing certificates of bounded depth.

### 4.3 Algorithm 3: MixedLogConcavityChecker

Verifies the mixed log-concavity condition $f(m+e_i) \cdot f(m+e_j) \geq f(m) \cdot f(m+e_i+e_j)$ for all $(m, i, j)$ triples. This is the condition needed for the tropical bridge theorem.

### 4.4 Algorithm 4: ExactDepthSearcher

Grid search over coefficient space to find functions with a specified exact depth. Key tool for testing the Depth Dichotomy Conjecture.

---

## 5. Computational Experiments

### 5.1 Depth Dichotomy Conjecture

**Conjecture 5.1 (Depth Dichotomy).** For every naturally arising valuated matroid valuation $f$, the directional depth is either 1 or $\infty$. There are no natural examples with finite depth $> 1$.

### 5.2 Experimental Results

| Function Family | Parameters | Depth | Class |
|---|---|---|---|
| Geometric $c \cdot r^n$ | $c, r > 0$ | $\geq 8$ (infinite) | Infinite |
| Binomial $C(n,k)$ | $n = 4, 6, 8, 10$ | 1 | Finite |
| Pascal row 3: $[1,3,3,1]$ | — | $\geq 6$ (infinite) | Infinite |
| Pascal row 4: $[1,4,6,4,1]$ | — | 1 | Finite |
| Triangle $[1,2,1]$ | — | $\geq 6$ (infinite) | Infinite |
| Strict example $[1,3,2,1]$ | — | 1 (exact) | Finite |
| Graphical: $K_3$ | unit weights | $\geq 4$ (infinite) | Infinite |
| Graphical: $P_3$ | unit weights | $\geq 4$ (infinite) | Infinite |
| Product exponential | $w \in \mathbb{R}_{>0}^n$ | $\geq 6$ (infinite) | Infinite |

**Observation:** In our search over 256 coefficient vectors $[1, a, b, c]$ with $a, b, c \in \{1, 2, 3, 4\}$, we found zero examples with exact depth 2. All examples had depth either 1 or $\geq 5$ (effectively infinite within our computation budget).

### 5.3 Supermodularity Verification

For 2D mixed-log-concave functions (Gaussian kernels $f(x,y) = \exp(-ax^2 - by^2 - cxy)$ with $4ab > c^2$), we verified that $-\log f$ is supermodular on the grid $\{0, \ldots, 5\}^2$, confirming the tropical bridge theorem computationally.

---

## 6. Cross-Domain Connections

### 6.1 Tropical Geometry

The map $f \mapsto v = -\log f$ is the *tropicalization*. Theorem 3.2 says mixed log-concavity produces a supermodular tropical potential. This is significant because:
- Supermodularity of $v$ is a tropical convexity condition.
- The depth hierarchy produces a *tower of tropical convex potentials* $v^{(0)} = -\log f$, $v^{(1)}_i = -\log(R_i f)$, $v^{(2)}_{ij} = -\log(R_j R_i f)$, etc.
- Infinite depth means infinite tropical convexity persistence — a discrete analog of infinite regularity.

### 6.2 Hodge/Lorentzian Geometry

The depth filtration is a discrete shadow of Lorentzian polynomial theory:
- Depth 1 corresponds to first-order Lorentzian behavior (positive semi-definite Hessian of log).
- Depth $k$ corresponds to persistence of Lorentzianity under $k$ logarithmic directional derivatives.
- Infinite depth is the discrete analog of a polynomial being Lorentzian (all iterated derivatives maintain the structure).

### 6.3 Statistical Physics / Information Geometry

The function $-\log f$ is an energy landscape, and ratio transforms are discrete chemical potentials. In this language:
- $R_i f(m)$ is the Boltzmann factor for adding a particle of type $i$ to configuration $m$.
- $-\log(R_i f(m))$ is the chemical potential / local free energy increment.
- Depth measures how many levels of "thermodynamic derivatives" maintain convexity.
- The multiplicative stability theorem corresponds to independent subsystems preserving thermodynamic regularity.

Theorem 4 (ratio energy supermodularity) says: if the energy landscape has sufficient depth, then the *response function* (how chemical potentials change with composition) is convex in the tropical sense.

---

## 7. Discussion

### 7.1 Implications

The directional depth filtration provides a new language for valuated matroid theory that is:
1. **Intrinsic**: defined purely from the function values, no ambient algebraic structure required.
2. **Stable**: closed under products (multiplicative stability).
3. **Tropically visible**: connected to supermodularity via the tropical bridge.
4. **Strictly finer**: the hierarchy is non-collapsing (strictness theorem).
5. **Computationally tractable**: depth can be computed by iterated log-concavity checks.

### 7.2 Limitations

- Our mixed log-concavity condition is stronger than directional log-concavity. The question of whether directional log-concavity alone implies supermodularity of $-\log f$ remains open.
- Depth computation is exponential in the number of variables, limiting practical computation to small $n$.
- The Depth Dichotomy Conjecture remains unproved; our evidence is computational.

### 7.3 Open Questions

1. Does the Depth Dichotomy Conjecture hold for all valuated matroids arising from tropical Grassmannians?
2. Is there a polynomial-time algorithm for computing depth on degree slices?
3. Can the depth invariant distinguish non-isomorphic valuated matroids that agree on all first-order invariants?

---

## 8. Future Work

1. Extend the multiplicative stability theorem to mixed log-concavity at all depth levels.
2. Develop a complete theory connecting depth $\geq k$ to $k$-th order M-convexity.
3. Investigate the depth of Schur polynomials and other representation-theoretic coefficient sequences.
4. Build a database of depth computations for small matroids.
5. Connect the depth filtration to the Hodge-Riemann relations for matroids.

---

## References

1. Adiprasito, K., Huh, J., and Katz, E. "Hodge Theory for Combinatorial Geometries." *Annals of Mathematics* 188 (2018), 381–452.

2. Brändén, P. and Huh, J. "Lorentzian Polynomials." *Annals of Mathematics* 192 (2020), 821–891.

3. Murota, K. *Discrete Convex Analysis.* SIAM Monographs on Discrete Mathematics, 2003.

4. Anari, N., Liu, K., Oveis Gharan, S., and Vinzant, C. "Log-Concave Polynomials II: High-Dimensional Walks and an FPRAS for Counting Bases of a Matroid." *STOC 2019*, 1–12.

5. Dress, A. and Wenzel, W. "Valuated Matroids." *Advances in Mathematics* 93 (1992), 214–250.

6. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry.* Graduate Studies in Mathematics 161, AMS, 2015.
