# Future Directions: Berggren Tree Arithmetic Dynamics

## Conjecture 1: Exact Minimum Hypotenuse Formula

**Precise statement:** For all d ≥ 0, the minimum hypotenuse at depth d in the Berggren tree is exactly
$$c_{\min}(d) = 2d^2 + 6d + 5,$$
achieved uniquely by the all-A word $A^d$.

**Current status:** We have proved:
- Upper bound: $c_{\min}(d) \leq 2d^2 + 6d + 5$ (from the all-A branch)
- Lower bound: $c_{\min}(d) \geq 2d^2 + 4d + 5$ (from the inductive argument)

The gap is $2d$. Closing it requires showing that the minimizing word at each depth is the all-A word.

**Test:** Enumerate all $3^d$ words for $d \leq 12$ and verify $c_{\min}(d) = 2d^2 + 6d + 5$. (Verified computationally for $d \leq 8$.)

**Falsification criterion:** Find a word $w$ of length $d$ with hypotenuse $< 2d^2 + 6d + 5$.

**Impact:** Would give the exact enumeration depth $d = \lfloor \frac{-3 + \sqrt{2N+1}}{2} \rfloor$ needed to find all primitive triples with $c \leq N$.

---

## Conjecture 2: All-A Branch is the Unique Global Minimizer

**Precise statement:** For each depth $d \geq 1$, the word $A^d$ is the unique word of length $d$ achieving the minimum hypotenuse.

**Test:** Compute all $3^d$ hypotenuses for $d = 1, \ldots, 10$ and verify uniqueness.

**Approach to proof:** Show that at each step, if a word has achieved the current minimum hypotenuse, the minimum-child generator must be A. This requires proving that the all-A branch stays in a region of parameter space where generator A is strictly optimal.

**Key lemma to prove:** For the all-A triple $(2n+3, 2n^2+6n+4, 2n^2+6n+5)$ at depth $n$, the hypotenuse of child A is strictly less than that of children B and C.

**Impact:** Would establish the all-A branch as the extremal geodesic of the Berggren semigroup, with potential applications to joint spectral radius theory.

---

## Conjecture 3: Spectral Gap and Exponential Mixing Modulo m

**Precise statement:** For every odd modulus $m$, let $T_m$ be the $3 \times |S_m|$ transition matrix of the Berggren residue graph on the reachable component $S_m$. Then:

1. The graph is strongly connected and aperiodic for all odd $m$.
2. The second-largest eigenvalue satisfies $|\lambda_2(T_m)| \leq 1 - c/m^2$ for some universal constant $c > 0$.
3. The stationary distribution is uniform on admissible hypotenuse residues.

**Test:**
- Construct the residue graph for $m = 3, 5, 7, 11, 13, 17, 19, 23$ and verify strong connectivity and aperiodicity.
- Compute eigenvalues of the averaging operator and verify the spectral gap.
- Check that the stationary distribution is uniform.

**Falsification criterion:** Find an odd $m$ where the residue graph has multiple strongly connected components, or where the stationary distribution is non-uniform.

**Impact:** Would establish the Berggren tree as a concrete example of a thin semigroup with provable mixing properties, connecting elementary number theory to expander graph theory and homogeneous dynamics.

---

## Conjecture 4: Large Deviations for Log-Hypotenuse

**Precise statement:** Let $L(w) = \log c(w) / |w|$ for a word $w$ of length $d$. Then as $d \to \infty$:

1. The average $\mathbb{E}[L] = \frac{1}{3^d} \sum_{|w|=d} L(w)$ converges to a Lyapunov exponent $\Lambda \approx \log(3 + 2\sqrt{2})$.
2. The variance $\text{Var}[L] = O(1/d)$.
3. The distribution of $L(w)$ satisfies a large deviation principle with rate function $I(x) = \sup_t(tx - \Lambda(t))$.

**Test:** Compute the empirical distribution of $L(w)$ for $d = 6, 8, 10$ and check:
- Convergence of mean to $\Lambda$
- Gaussian-like concentration around $\Lambda$
- Exponential tails

**Falsification criterion:** Non-convergence of the mean, or heavy tails inconsistent with a large deviation principle.

**Impact:** Would connect the Berggren tree to multiplicative ergodic theory and random matrix products, providing exact complexity analysis for typical (not worst-case) enumeration paths.

---

## Conjecture 5: Multiplicity–Depth Correlation

**Precise statement:** For a hypotenuse $c$ with $r_{\text{prim}}(c) = 2^{k-1}$ primitive representations, the number of distinct Berggren tree paths reaching $c$ equals $r_{\text{prim}}(c)$, and the depths of these paths satisfy:

$$\max_{\text{paths to } c} d - \min_{\text{paths to } c} d \leq C \cdot k$$

for a universal constant $C$.

**Test:** For hypotenuses $c \leq 10000$ with $k \geq 2$, compute all Berggren tree paths reaching each $(a, b, c)$ and verify:
- The number of paths equals $r_{\text{prim}}(c)$
- The depth spread grows at most linearly in $k$

**Falsification criterion:** Find a hypotenuse where the depth spread grows faster than linearly in $k$, or where the number of paths differs from $r_{\text{prim}}(c)$.

**Impact:** Would establish a precise connection between the arithmetic structure of hypotenuses (prime factorization) and the geometric structure of the Berggren tree (path depths), bridging algebraic number theory with combinatorial tree analysis.
