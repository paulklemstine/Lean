# Future Directions: Shadow Complexity and Circuit Lower Bounds

## Synthesis

The shadow convolution theorem establishes a new bridge between combinatorial set theory and algebraic complexity. By proving that shadow complexity is sub-multiplicative under Minkowski sum and sub-additive under union, we have shown that the shadow profile is a *circuit-compatible invariant*: it can only grow in controlled ways through the operations available to algebraic circuits. This opens five interconnected research directions:

1. **Extending the framework** from formulas to algebraic branching programs (ABPs) and general circuits, where the key challenge is handling fan-out.
2. **Proving lower bounds** by computing shadow complexity of specific polynomials (permanent, determinant) and showing it exceeds $2^s$ for small $s$.
3. **Connecting to information theory** through the shadow entropy power inequality analogy.
4. **Bridging to tropical geometry** where shadows become tropical projections.
5. **Exploring the equality case** of the convolution inequality to characterize extremal support structures.

Each direction builds on the formally verified convolution theorem and sub-additivity, and each is testable through explicit computation.

---

## Direction 1: Shadow Complexity for Algebraic Branching Programs

**Conjecture:** If a polynomial $f$ is computed by an algebraic branching program (ABP) of width $w$ and length $d$, then $\Sigma(\mathrm{Supp}(f)) \leq (w+1)^d$.

**Test:** Compute shadow complexity for the $n \times n$ iterated matrix product $\mathrm{IMM}_{n,d}$ (the universal ABP polynomial) and verify $\Sigma \leq (n+1)^d$. For $n = 2, d = 3$: compute explicitly and compare to the bound $3^3 = 27$.

**Impact:** ABPs are the natural model between formulas and circuits. Tight shadow bounds for ABPs would immediately separate ABP complexity from formula complexity for explicit polynomials, as shadow complexity captures the "branching advantage."

**Catalog References:** `ShadowComplexity/Theorems.lean` (shadow convolution theorem provides the formula case).

**Proof Strategy:** The ABP structure constrains supports to be *layered Minkowski sums*: $\mathrm{Supp}(f) \subseteq L_1 + L_2 + \cdots + L_d$ where each $L_i$ has at most $w^2$ elements. Apply the sub-multiplicativity theorem iteratively: $\Sigma \leq \prod_i \Sigma(L_i) \leq \prod_i (w^2 + 1)$. The refined bound requires tracking the *trace structure* of the ABP — the fact that the final polynomial is a trace of a matrix product, which restricts which Minkowski sum elements actually contribute.

**Domain Bridges:** Connects algebraic complexity (ABPs) → combinatorial optimization (layered Minkowski sums) → linear algebra (trace structure).

**Lineage:** Extends Theorem 3.2 (shadow convolution) from pairs to sequences of Minkowski summands.

**Ambition:** Medium-high. The formula bound is proved; extending to ABPs requires new structural analysis of layered sums.

---

## Direction 2: Shadow Complexity of the Permanent — A Computational Attack

**Conjecture:** The shadow complexity of the $n \times n$ permanent satisfies $\Sigma(\mathrm{Supp}(\mathrm{perm}_n)) \geq n! \cdot n^{\Omega(1)}$, which exceeds $2^s$ for $s = n^{O(1)}$.

**Test:** Compute $\Sigma(\mathrm{Supp}(\mathrm{perm}_n))$ for $n = 2, 3, 4, 5$ and extrapolate the growth rate.
- $n = 2$: $\mathrm{perm}_2 = x_{11}x_{22} + x_{12}x_{21}$, support has 2 elements in $\mathbb{N}^4$.
- $n = 3$: Support has 6 elements in $\mathbb{N}^9$ (the 6 permutations).
- $n = 4$: Support has 24 elements in $\mathbb{N}^{16}$.

**Impact:** If $\Sigma(\mathrm{perm}_n)$ grows super-polynomially in $n$ faster than $2^{n^c}$ for all $c$, this would imply super-polynomial formula lower bounds for the permanent — a significant complexity theory result.

**Catalog References:** `ShadowComplexity/Defs.lean` (shadow_iter, shadowComplexity definitions).

**Proof Strategy:** Each permutation matrix is a 0-1 vector in $\{0,1\}^{n^2}$ with exactly one 1 per row and column. The shadow of the set of permutation matrices is related to *partial permutation matrices*. The key insight is that the $k$-th shadow of the set of $n \times n$ permutation matrices contains all partial permutation matrices of weight $n - k$, and the number of such matrices is $\binom{n}{n-k}^2 \cdot (n-k)!$ (choose $n-k$ rows and $n-k$ columns, then permute). This gives $a_k \geq \binom{n}{k}^2 \cdot (n-k)!$, and summing yields $\Sigma \geq \sum_k \binom{n}{k}^2 (n-k)!$.

**Domain Bridges:** Connects algebraic complexity → combinatorics of permutations → asymptotic analysis.

**Lineage:** Directly tests whether the framework from Theorem 4.2 can yield new lower bounds.

**Ambition:** Grand challenge. Success would resolve a major open problem in complexity theory.

---

## Direction 3: Shadow Entropy Power Inequality

**Conjecture:** Define the *shadow entropy* $H(S) = \log_2 \Sigma(S)$. Then for independent Minkowski summands:
$$H(A + B) \geq H(A) + H(B) - O(\log n)$$
with equality if and only if $A$ and $B$ are "shadow-independent" (their supports project to disjoint coordinates).

**Test:** Verify the lower bound computationally for random subsets of $\{0,1\}^n$ for $n \leq 8$. Compute $H(A + B)$, $H(A)$, $H(B)$ for 1000 random pairs and check the inequality.

**Impact:** An exact shadow entropy power inequality would be a new inequality in combinatorial information theory, connecting circuit complexity to entropy. It could yield tight lower bounds through information-theoretic arguments.

**Catalog References:** `ShadowComplexity/Theorems.lean` (sub-multiplicativity gives the upper bound $H(A+B) \leq H(A) + H(B)$; we conjecture the reverse direction also holds approximately).

**Proof Strategy:** The upper bound follows from our sub-multiplicativity theorem. The lower bound would follow from a "reverse Plünnecke-Ruzsa" inequality for shadow complexity: if $|A + B|$ is not too much larger than $|A| \cdot |B|$, the shadow profiles must also "convex combine" rather than cancel.

**Domain Bridges:** Connects combinatorics (Minkowski sums) → information theory (entropy power inequality) → additive combinatorics (Plünnecke-Ruzsa).

**Lineage:** Dual to Corollary 3.4 (sub-multiplicativity).

**Ambition:** High. A full characterization of equality would be a significant result in combinatorial information theory.

---

## Direction 4: Tropical Shadow Geometry

**Conjecture:** The shadow profile of a tropical variety $V = \mathrm{trop}(f)$ determines the *tropical Betti numbers* of $V$. Specifically, $a_k^{\mathrm{Supp}(f)}$ equals the $k$-th tropical homology rank of the Newton polytope complex.

**Test:** For the tropical curve $\mathrm{trop}(x + y + 1)$ in $\mathbb{R}^2$, compute the shadow profile of $\{(1,0), (0,1), (0,0)\}$ and compare to the tropical Betti numbers $(1, 0)$.

**Impact:** This would establish shadow complexity as a computable proxy for tropical homology, which is currently difficult to compute. It would bridge discrete combinatorics to tropical algebraic geometry.

**Catalog References:** `ShadowComplexity/Defs.lean` (lowerShadow definition as the tropical projection operation).

**Proof Strategy:** Interpret the shadow operation $\partial$ as the boundary map in a tropical chain complex. The set $\partial^k(S)$ becomes the $k$-th boundary of the "tropical simplex" associated to $S$. The shadow profile then computes ranks of the tropical homology groups via an Euler characteristic argument.

**Domain Bridges:** Connects combinatorial set theory → tropical geometry → algebraic topology → computational algebra.

**Lineage:** Reinterprets Definitions 2.1-2.4 in tropical language.

**Ambition:** Medium. The connection is conceptually natural but making it precise requires developing tropical homology machinery.

---

## Direction 5: Extremal Structures and Equality in the Convolution Bound

**Conjecture:** Equality holds in the convolution bound $a_k^{A+B} = \sum_i a_i^A \cdot a_{k-i}^B$ if and only if $A$ and $B$ are *coordinate-separated*: there exists a partition $[n] = I \sqcup J$ such that $A$ is supported on coordinates $I$ and $B$ is supported on coordinates $J$.

**Test:** For $n = 4$, enumerate all pairs $(A, B)$ of subsets of $\{0,1\}^4$ with $|A|, |B| \leq 4$, compute whether equality holds in the convolution bound for all $k$, and check whether the characterization is correct.

**Impact:** Characterizing equality would reveal the structural constraints that circuits impose on polynomial supports. Non-equality (which is generic) means that the convolution bound is strict, suggesting room for improvement.

**Catalog References:** `ShadowComplexity/Theorems.lean` (Theorem 3.2 provides the inequality; the question is when equality holds).

**Proof Strategy:** The forward direction (coordinate-separated implies equality) is straightforward: if $A$ and $B$ use disjoint coordinates, the Minkowski sum is a Cartesian product and all inclusions become equalities. The reverse direction requires showing that any "interaction" between coordinates of $A$ and $B$ causes strict inequality. This could be proved by finding, for each interacting coordinate, a specific vector in $\bigcup \partial^i(A) + \partial^{k-i}(B)$ that appears in multiple terms of the union (overcounting).

**Domain Bridges:** Connects extremal combinatorics → additive combinatorics (Freiman-Ruzsa theory) → circuit complexity (structural characterization of tight bounds).

**Lineage:** Refines Theorem 3.2 by characterizing the equality case.

**Ambition:** Medium. The conjecture is precise and testable, but the reverse direction may require delicate combinatorial arguments.
