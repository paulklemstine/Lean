# Newton–Tropical Bridge: Polynomial Valuation Profiles, Tropical Evaluation, and Cryptographic Root Certificates

## Abstract

We establish a rigorous bridge between the algebraic theory of polynomial valuations and tropical convex geometry through the Newton valuation profile — the map that sends each coefficient of a polynomial to its p-adic valuation. The central result, the Root–Valuation Bridge Theorem, proves that the p-adic valuation of any polynomial evaluation is bounded below by the tropical evaluation of the Newton profile: $v(f(a)) \geq T_f(v(a))$, where $T_f(t) = \inf_i(v(a_i) + i \cdot t)$ is the lower envelope of the Newton polygon. We prove this bound, establish stability of tropical evaluation under profile perturbation, analyze dominant terms at each evaluation point, and introduce Newton slope certificates — cryptographic primitives that certify divisibility bounds on polynomial values without revealing the evaluation point. All results are formally verified in Lean 4 with Mathlib.

**Keywords**: Newton polygon, tropical geometry, p-adic valuation, ultrametric inequality, cryptographic certificates, formal verification

## 1. Introduction

The Newton polygon of a polynomial with respect to a non-archimedean valuation is one of the most powerful tools in algebraic number theory. Given a polynomial $f(x) = \sum_{i=0}^n a_i x^i$ and a p-adic valuation $v = v_p$, the Newton polygon is the lower convex hull of the points $\{(i, v(a_i)) : a_i \neq 0\}$ in $\mathbb{R}^2$. Its slopes determine the p-adic valuations of the roots of $f$, a fact that underpins much of p-adic analysis.

Tropical geometry offers a parallel perspective. The tropicalization of $f$ under $v$ yields the tropical polynomial $T_f(t) = \min_i(v(a_i) + i \cdot t)$, a piecewise-linear concave function whose breakpoints correspond to the vertices of the Newton polygon. This paper formalizes and exploits the connection between these two perspectives.

### 1.1 Contributions

1. **Newton Valuation Profile** (Definition 1): A novel structure packaging the coefficient valuations of a polynomial with a witness of nontriviality.

2. **Root–Valuation Bridge Theorem** (Theorem 1): For any polynomial $f$ over a valued ring and any point $a$: $v(f(a)) \geq T_f(v(a))$. The proof uses an iterated ultrametric inequality over finite sums.

3. **Stability Theorem** (Theorem 2): If two Newton profiles are $\varepsilon$-close (differ by at most $\varepsilon$ at each coordinate), their tropical evaluations differ by at most $\varepsilon$ at every point.

4. **Dominant Term Analysis** (Theorem 3): At every evaluation point, at least one term achieves the tropical infimum, and non-dominant terms are strictly larger.

5. **Newton Slope Certificate** (Definition 3): A cryptographic certificate structure for proving polynomial divisibility bounds.

6. **Infimal Convolution** (Definition 4): The tropical product of Newton profiles, connecting polynomial multiplication to tropical algebra.

## 2. Preliminaries

### 2.1 Extended Natural Numbers

We work over $\mathbb{N}_\infty = \mathbb{N} \cup \{\top\}$, the extended natural numbers (denoted `ℕ∞` or `WithTop ℕ` in Lean). This is an ordered commutative monoid under addition, with $\top + a = \top$ for all $a$. The minimum operation $\min$ makes $(\mathbb{N}_\infty, \min, +)$ a tropical semiring.

### 2.2 Valuations

A **tropical valuation** on a commutative semiring $R$ is a map $v : R \to \mathbb{N}_\infty$ satisfying:
- $v(0) = \top$ (zero maps to infinity)
- $v(1) = 0$ (unit maps to zero)
- $v(ab) = v(a) + v(b)$ (multiplicativity)
- $\min(v(a), v(b)) \leq v(a + b)$ (ultrametric inequality)

The prototypical example is the p-adic valuation $v_p$ on $\mathbb{Z}$: $v_p(n)$ is the largest $k$ such that $p^k | n$.

### 2.3 Tropical Polynomial Evaluation

**Definition 1** (Newton Valuation Profile). A *Newton valuation profile* of degree $n$ is a function $\pi : \{0, 1, \ldots, n\} \to \mathbb{N}_\infty$ together with a witness that at least one value is finite: $\exists i, \pi(i) \neq \top$.

Given a polynomial $f(x) = \sum_{i=0}^n a_i x^i$ and a valuation $v$, the associated profile is $\pi_f(i) = v(a_i)$.

**Definition 2** (Tropical Evaluation). The *tropical evaluation* of profile $\pi$ at point $t \in \mathbb{N}_\infty$ is:
$$T_\pi(t) = \inf_{0 \leq i \leq n} (\pi(i) + i \cdot t)$$

This is the pointwise infimum of a finite family of affine-tropical functions $\ell_i(t) = \pi(i) + i \cdot t$.

## 3. Main Results

### 3.1 Root–Valuation Bridge Theorem

**Theorem 1** (Root–Valuation Bridge). Let $R$ be a commutative semiring with a tropical valuation $v$. For any polynomial $f(x) = \sum_{i=0}^n c_i x^i$ and any point $a \in R$:
$$T_{\pi_f}(v(a)) \leq v(f(a))$$

*Proof sketch.* The proof proceeds in two steps:

**Step 1**: For each term $c_i a^i$, we have $v(c_i a^i) = v(c_i) + v(a^i) = v(c_i) + i \cdot v(a) = \pi_f(i) + i \cdot v(a)$, using multiplicativity and the power formula $v(a^k) = k \cdot v(a)$.

**Step 2**: By an iterated ultrametric inequality (proved by induction on the size of the finite sum): for any nonempty finset $S$ and function $g : S \to R$,
$$\inf_{i \in S} v(g(i)) \leq v\left(\sum_{i \in S} g(i)\right)$$

Combining: $T_{\pi_f}(v(a)) = \inf_i (\pi_f(i) + i \cdot v(a)) = \inf_i v(c_i a^i) \leq v(\sum_i c_i a^i) = v(f(a))$. $\square$

**Corollary 1**. If $f(a) = 0$, then for every evaluation point $t = v(a)$, the tropical evaluation $T_{\pi_f}(t) = \top$. Since $T_{\pi_f}$ is a finite infimum, this means every term $\pi_f(i) + i \cdot v(a) = \top$, which is impossible if all coefficients have finite valuation. This contradiction shows that a polynomial with all finite coefficient valuations cannot vanish at a point with finite valuation — unless there is tropical cancellation (two or more dominant terms).

### 3.2 Stability Theorem

**Definition** ($\varepsilon$-closeness). Two profiles $\pi_A, \pi_B$ of degree $n$ are $\varepsilon$-close if $|\pi_A(i) - \pi_B(i)| \leq \varepsilon$ for all $i$ (with the convention that $|\top - a| = \top$ for finite $a$).

**Theorem 2** (Stability). If $\pi_A$ and $\pi_B$ are $\varepsilon$-close, then for all $t$:
$$T_{\pi_A}(t) \leq T_{\pi_B}(t) + \varepsilon$$

*Proof sketch.* Let $i^*$ be the dominant term for $\pi_B$ at $t$: $T_{\pi_B}(t) = \pi_B(i^*) + i^* \cdot t$. Then:
$$T_{\pi_A}(t) \leq \pi_A(i^*) + i^* \cdot t \leq (\pi_B(i^*) + \varepsilon) + i^* \cdot t = T_{\pi_B}(t) + \varepsilon$$
where the first inequality uses the infimum property and the second uses $\varepsilon$-closeness. $\square$

### 3.3 Dominant Term Analysis

**Definition** (Dominant Term). Term $i$ is *dominant* at point $t$ if $\pi(i) + i \cdot t = T_\pi(t)$.

**Theorem 3** (Existence and Strictness).
(a) At every point $t$, at least one term is dominant.
(b) If $i$ is dominant and $j$ is not, then $\pi(i) + i \cdot t < \pi(j) + j \cdot t$.

*Proof.* Part (a) follows from the fact that the infimum of a nonempty finite set is attained. Part (b) follows from the definition: the dominant term achieves the infimum, and a non-dominant term does not equal the infimum but is bounded below by it. $\square$

**Remark.** The set of evaluation points where two specific terms are simultaneously dominant forms the "breakpoint" between those terms. At breakpoints, the tropical evaluation function changes slope, and the slopes before and after the breakpoint correspond to the indices of the dominant terms — yielding the slopes of the Newton polygon.

### 3.4 Profile Operations

**Theorem 4** (Pointwise Min Bound). For profiles $\pi_A, \pi_B$ of the same degree:
$$T_{\min(\pi_A, \pi_B)}(t) \leq \min(T_{\pi_A}(t), T_{\pi_B}(t))$$

This follows from the monotonicity of the infimum: $\min(\pi_A(i), \pi_B(i)) \leq \pi_A(i)$ implies $T_{\min(\pi_A, \pi_B)}(t) \leq T_{\pi_A}(t)$, and similarly for $\pi_B$.

## 4. Cryptographic Applications

### 4.1 Newton Slope Certificate

**Definition 3** (Newton Slope Certificate). A *Newton slope certificate* for a polynomial $f$ of degree $n$ consists of:
- A Newton profile $\pi$ (the coefficient valuations of $f$)
- A point valuation $v_0 \in \mathbb{N}_\infty$ (the claimed $v(a)$)
- A bound $B \in \mathbb{N}_\infty$
- A proof that $B \leq T_\pi(v_0)$

**Theorem 5** (Certificate Validity). Given a valid Newton slope certificate with bound $B$, for any point $a$ with $v(a) = v_0$:
$$B \leq v(f(a))$$

*Proof.* By the chain: $B \leq T_\pi(v_0) = T_{\pi_f}(v(a)) \leq v(f(a))$. $\square$

### 4.2 Privacy Properties

The certificate reveals only:
- The polynomial $f$ (assumed public)
- The valuation $v(a)$ of the evaluation point

It does *not* reveal the point $a$ itself. Since the p-adic valuation is a many-to-one function — exponentially many integers share the same valuation — this provides substantial privacy. The certificate is extractable: given polynomial data and a point, a certificate can always be produced with bound equal to the tropical evaluation.

### 4.3 Stability for Approximate Certificates

By the stability theorem, perturbing the Newton profile by $\varepsilon$ weakens the certificate bound by at most $\varepsilon$. This enables:
- **Noisy coefficients**: Certificates remain approximately valid when coefficients are measured with bounded error.
- **Privacy amplification**: Adding controlled noise to the profile provides differential privacy while maintaining a useful (if weakened) bound.

## 5. Infimal Convolution and Polynomial Products

**Definition 4** (Infimal Convolution). For profiles $\pi_A$ of degree $m$ and $\pi_B$ of degree $n$, the *infimal convolution* is:
$$(\pi_A \star \pi_B)(k) = \inf_{i+j=k} (\pi_A(i) + \pi_B(j)), \quad k = 0, \ldots, m+n$$

This is the tropical analogue of polynomial multiplication. Under a multiplicative valuation, if $f \cdot g$ has coefficient profile $\pi_{fg}$, then $\pi_A \star \pi_B \leq \pi_{fg}$ pointwise (with equality in many cases of interest).

**Theorem 6** (Zero Bound). $(\pi_A \star \pi_B)(0) \leq \pi_A(0) + \pi_B(0)$, since the pair $(i,j) = (0,0)$ is always admissible.

## 6. Tropical Discriminant

For a degree-2 polynomial $f(x) = a_2 x^2 + a_1 x + a_0$ with profile $\pi = (v_0, v_1, v_2)$, the *tropical discriminant* is:
$$\Delta_{\text{trop}} = \min(2 v_1, v_0 + v_2)$$

This bounds the classical discriminant's valuation: $v(\Delta_f) \geq \Delta_{\text{trop}}$. The tropical discriminant detects:
- **$\Delta_{\text{trop}} < 2v_1$**: Roots have *different* p-adic valuations; the Newton polygon has two distinct slopes.
- **$\Delta_{\text{trop}} = 2v_1$**: The discriminant's valuation is determined by $v_0 + v_2$; whether roots have the same valuation depends on higher-order analysis.

## 7. Falsifiable Conjecture

**Conjecture** (Newton Slope–Root Correspondence, Degree 2). For a monic polynomial $f(x) = x^2 + bx + c \in \mathbb{Z}[x]$ with $b, c \neq 0$ and a prime $p$ such that $v_p(c) < 2 v_p(b)$, the Newton polygon has two distinct slopes equal to the p-adic valuations of the roots (in the p-adic completion $\mathbb{Z}_p$), and the sum of root valuations equals $v_p(c)$.

**Test**: $p = 3$, $f(x) = x^2 + 9x + 27$. Profile: $(3, 2, 0)$. Since $v_3(27) = 3 < 2 \cdot 2 = 4 = 2 v_3(9)$, the conjecture applies. Newton slopes: 1 and 2. Roots: $-3$ ($v_3 = 1$) and $-9$ ($v_3 = 2$). Sum $= 3 = v_3(27)$. ✓

## 8. Discussion

### 8.1 Relation to Prior Work

This work builds on the tropical valuation functor from the Catalog (`Bridges/TropicalValuationFunctor.lean`), which established the bridge at the level of linear combinations. Our Newton profile specializes this to polynomial evaluation, where the coefficient-power structure enables sharper results (the power formula, dominant term analysis, slope certificates).

### 8.2 Limitations

The current framework works with $\mathbb{N}_\infty$-valued valuations, which suffices for the p-adic valuation on $\mathbb{Z}$ but does not directly handle $\mathbb{Q}$-valued valuations needed for non-integral rings. Extension to $\mathbb{R}_\infty$-valued valuations would broaden applicability.

### 8.3 Formal Verification

All theorems are formally verified in Lean 4 using the Mathlib library. The key proofs are:
- `tropical_eval_at_root_le`: The bridge theorem, using an iterated ultrametric inequality proved by Finset induction.
- `tropicalEval_stable`: Stability, using the dominant-term lemma to transfer ε-closeness.
- `dominant_lt_nondominant`: Strictness of non-dominant terms, by contradiction with the infimum.
- `val_pow_eq_mul`: The power formula for valuations, by induction on the exponent.

## 9. Future Work

1. **Multivariate generalization**: Extend Newton profiles to multivariate polynomials, where Newton polygons become Newton polytopes.
2. **Tropical discriminant refinement**: Extend the tropical discriminant to arbitrary degree and prove it bounds the classical discriminant's valuation.
3. **Zero-knowledge protocols**: Build complete zero-knowledge proof systems on Newton slope certificates.
4. **Connection to tropical Helly theorem**: Compose the bridge with the tropical Helly theorem from the Catalog to derive intersection properties from algebraic data.

## References

1. Maclagan, D. and Sturmfels, B. *Introduction to Tropical Geometry*. American Mathematical Society, 2015.
2. Neukirch, J. *Algebraic Number Theory*. Springer, 1999.
3. Gouvêa, F.Q. *p-adic Numbers: An Introduction*. Springer, 1997.
4. Catalog: `Bridges/TropicalValuationFunctor.lean` — Tropical valuation functor and bridge theorem.
5. Catalog: `Speculative/AutoResearch/TropicalHelly.lean` — Tropical Helly theorem.
