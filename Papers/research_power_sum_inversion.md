# Power-Sum Inversion: Explicit Reconstruction of Value Distributions from Bounded Moment Windows

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Let $\alpha$ be a finite index set and let $f : \alpha \to \mathbb{N}$ be a function whose values are bounded by $N$. Its *power sums* are $p_k(f) = \sum_{i \in \alpha} f(i)^k$ and its *value distribution* is the fibre-count function $c_f(v) = \#\{i : f(i) = v\}$. We prove that the finite window $p_0, p_1, \dots, p_N$ determines $c_f$ completely, and we do so constructively: there is a fixed rational matrix $W_N$, the coefficient matrix of the Lagrange basis of the nodes $0, 1, \dots, N$, such that
$$c_f(v) \;=\; \sum_{k=0}^{N} W_N(v,k)\, p_k(f) \qquad (v \le N)$$
for every bounded $f$ on every finite index set. From the explicit inverse we derive: rigidity of value distributions and of value multisets; rigidity up to a bijection of index sets transporting one function to the other (with equality of index cardinalities appearing as the $k=0$ component of the conclusion rather than as a hypothesis); a spectral corollary for diagonalisable rational matrices with small integral spectra; canonicity of the inversion operator (it is the unique linear functional performing the reconstruction); two-sidedness of the inverse, hence surjectivity of the moment map and its promotion to a linear automorphism of $\mathbb{Q}^{N+1}$; and a quantitative stability estimate in terms of the Lebesgue constant $\Lambda_N(v) = \sum_k |W_N(v,k)|$, which — because counts are integers — upgrades to *exact* recovery whenever $\Lambda_N(v)\,\varepsilon < 1$.

We then show that the true parameter is not the bound $N$ but the number of admissible values. If both functions take values in a common finite set $A$ of cardinality $m$, agreement of $p_0, \dots, p_{m-1}$ suffices, however large the elements of $A$. This window is sharp for every $A$: clearing denominators in the nodal weight vector $w_a = \prod_{b \ne a}(a-b)^{-1}$ and splitting it into positive and negative parts produces an explicit pair of functions with values in $A$ whose power sums agree for all $k < m-1$ but whose value distributions differ. Together these give an exact threshold: $m$ power sums suffice and $m-1$ do not.

**Keywords:** power sums, moment problem, Vandermonde matrix, Lagrange interpolation, value distribution, Lebesgue constant, exact recovery, nodal weights.

---

## 1. Introduction

### 1.1 The problem

A finite multiset of natural numbers can be described in two dual ways: by *how many* of each value it contains, or by its *aggregate statistics*. The first description is the histogram; the second is the sequence of power sums. Passing from histogram to power sums is trivial. The reverse direction is the classical **moment problem**, and in the analytic setting — measures on the real line — it is genuinely hard: infinitely many moments may be required, and even then uniqueness can fail.

This paper studies the discrete, bounded case, where the situation is completely different. If a function's values are natural numbers bounded by a known $N$, then finitely many power sums determine everything, the reconstruction is a single fixed linear map with rational entries, and the map's conditioning can be computed exactly.

The result should be regarded as a statement about *inverting a transposed Vandermonde system*, with the additional feature that the unknown vector is known a priori to be integral. That integrality is what turns a stability estimate into an exact-recovery theorem.

### 1.2 Contributions

1. **An explicit inverse operator.** We do not merely prove injectivity of the moment map; we exhibit the inverse as the coefficient matrix of the Lagrange basis of the nodes $0,\dots,N$ (Section 3), and derive all downstream statements from it.
2. **Rigidity, in several strengths.** Equal power sums up to $N$ force equal fibre counts, equal value multisets, and finally a bijection of index sets transporting one function to the other (Section 4).
3. **Canonicity and two-sidedness.** The inversion row is the unique linear functional with its defining property, and the coefficient matrix is a two-sided inverse, so the moment map is a linear automorphism of $\mathbb{Q}^{N+1}$ (Section 5).
4. **Quantitative stability with exact recovery.** The Lebesgue constant of the inversion controls the propagation of errors, and integrality of counts converts the bound into exact equality below an explicit noise threshold (Section 6).
5. **The correct parameter is the number of values.** Rigidity holds over an arbitrary node set $A$ of size $m$ with window $k < m$, over any field of characteristic zero, and is sharp: an explicit near-miss pair exists for every $A$ at window $k < m-1$ (Sections 7–8).

### 1.3 Notation

Throughout, $\alpha$ and $\beta$ are finite index sets, $\mathbb{N} = \{0, 1, 2, \dots\}$, and $\mathbb{Q}[X]$ is the polynomial ring over the rationals. For a finite set $S$ we write $\#S$ for its cardinality. All matrices are indexed by $\{0, 1, \dots, N\}$ unless stated otherwise. We adopt the convention $0^0 = 1$, so that $p_0(f) = \#\alpha$.

---

## 2. Definitions

**Definition 2.1 (Power sums).** For a finite index set $\alpha$ and $f : \alpha \to \mathbb{N}$, the $k$-th power sum is
$$p_k(f) \;=\; \sum_{i \in \alpha} f(i)^k \in \mathbb{N}.$$
In particular $p_0(f) = \#\alpha$.

**Definition 2.2 (Value distribution).** The value distribution, or fibre-count function, of $f$ is
$$c_f(v) \;=\; \#\{\, i \in \alpha : f(i) = v \,\} \in \mathbb{N}, \qquad v \in \mathbb{N}.$$

**Definition 2.3 (Value multiset).** The value multiset of $f$ is the image multiset $\mathcal{V}(f) = \{\!\{\, f(i) : i \in \alpha \,\}\!\}$, so that $c_f(v)$ is exactly the multiplicity of $v$ in $\mathcal{V}(f)$.

**Definition 2.4 ($N$-boundedness).** $f$ is $N$-bounded if $f(i) \le N$ for all $i \in \alpha$. Then $c_f(v) = 0$ for $v > N$.

**Definition 2.5 (Lagrange basis of the interval nodes).** For $0 \le v \le N$ let
$$L^{(N)}_v(X) \;=\; \prod_{\substack{0 \le j \le N \\ j \ne v}} \frac{X - j}{v - j} \;\in\; \mathbb{Q}[X].$$
It is the unique polynomial of degree $\le N$ with $L^{(N)}_v(j) = \delta_{jv}$ for $0 \le j \le N$; its degree is exactly $N$.

**Definition 2.6 (Inversion matrix).** The **inversion matrix** $W_N$ is defined by
$$W_N(v,k) \;=\; \big[X^k\big] L^{(N)}_v(X), \qquad 0 \le v, k \le N,$$
the $k$-th monomial coefficient of the $v$-th Lagrange basis polynomial.

**Definition 2.7 (Transposed Vandermonde matrix).** $V^{\mathsf T}_N$ is the matrix with entries $V^{\mathsf T}_N(k, j) = j^k$ for $0 \le k, j \le N$; equivalently the transpose of the Vandermonde matrix of the nodes $0, 1, \dots, N$.

**Definition 2.8 (Lebesgue constant of the inversion).** For $v \le N$,
$$\Lambda_N(v) \;=\; \sum_{k=0}^{N} \big| W_N(v,k) \big| \;\in\; \mathbb{Q}_{\ge 0},$$
the $\ell^1$-norm of the $v$-th row of the inversion matrix.

**Definition 2.9 (Nodal weights).** For a nonempty finite $A \subseteq \mathbb{N}$ with $\#A = m$ and $a \in A$, the nodal weight is the top-degree coefficient of the Lagrange basis polynomial of $a$ relative to the nodes $A$:
$$w_a \;=\; \big[X^{m-1}\big] \prod_{\substack{b \in A \\ b \ne a}} \frac{X - b}{a - b} \;=\; \prod_{\substack{b \in A \\ b \ne a}} \frac{1}{a-b}.$$

---

## 3. The inversion formula

The entire development rests on one elementary identity.

**Lemma 3.1 (Moment identity).** If $f$ is $N$-bounded then for every $k$,
$$p_k(f) \;=\; \sum_{j=0}^{N} c_f(j)\, j^k .$$

*Proof sketch.* Partition $\alpha$ into the fibres $f^{-1}(j)$, $0 \le j \le N$; these exhaust $\alpha$ by $N$-boundedness. Each element of $f^{-1}(j)$ contributes $j^k$ to $p_k(f)$, and there are $c_f(j)$ of them. $\square$

Lemma 3.1 says exactly that the moment vector $(p_0, \dots, p_N)$ is the image of the count vector $(c_f(0), \dots, c_f(N))$ under $V^{\mathsf T}_N$. Inverting the system is therefore inverting a transposed Vandermonde matrix — and the Lagrange basis is precisely a closed form for that inverse.

**Theorem 3.2 (Delta identity: $W_N$ is a left inverse of $V^{\mathsf T}_N$).** For $0 \le v, j \le N$,
$$\sum_{k=0}^{N} W_N(v,k)\, j^k \;=\; \begin{cases} 1, & j = v,\\ 0, & j \ne v.\end{cases}$$

*Proof sketch.* Since $\deg L^{(N)}_v = N$, the polynomial equals the sum of its first $N+1$ monomials, so the left-hand side is just $L^{(N)}_v(j)$, evaluated at the node $j$. The defining interpolation property of the Lagrange basis gives $\delta_{jv}$. $\square$

**Theorem 3.3 (Explicit inversion of the transposed Vandermonde system).** Let $c : \{0,\dots,N\} \to \mathbb{Q}$ be arbitrary and let $m_k = \sum_{j=0}^{N} c(j) j^k$ be its power moments. Then for every $v \le N$,
$$c(v) \;=\; \sum_{k=0}^{N} W_N(v,k)\, m_k .$$

*Proof sketch.* Expand $m_k$, exchange the two finite sums, and apply Theorem 3.2 to the inner sum:
$$\sum_k W_N(v,k) \sum_j c(j) j^k = \sum_j c(j) \sum_k W_N(v,k) j^k = \sum_j c(j)\,\delta_{jv} = c(v). \qquad \square$$

**Corollary 3.4 (Uniqueness of solutions).** Two vectors $c, d : \{0,\dots,N\} \to \mathbb{Q}$ with the same power moments $m_k$ for all $k \le N$ agree at every node.

**Theorem 3.5 (Inversion formula for value distributions).** Let $f$ be $N$-bounded on a finite index set. Then for every $v \le N$,
$$c_f(v) \;=\; \sum_{k=0}^{N} W_N(v,k)\, p_k(f),$$
an identity in $\mathbb{Q}$ between an integer on the left and a rational combination of integers on the right.

*Proof sketch.* Apply Theorem 3.3 to $c = c_f$ and use Lemma 3.1 to identify $m_k$ with $p_k(f)$. $\square$

### 3.1 Small inversion matrices

The tables below are the exact monomial expansions of the Lagrange bases; the last column records the Lebesgue constants of Definition 2.8.

| $N$ | $v$ | $\big(W_N(v,0), \dots, W_N(v,N)\big)$ | $\Lambda_N(v)$ |
|---|---|---|---|
| $1$ | $0$ | $(1, -1)$ | $2$ |
| $1$ | $1$ | $(0, 1)$ | $1$ |
| $2$ | $0$ | $(1, -\tfrac32, \tfrac12)$ | $3$ |
| $2$ | $1$ | $(0, 2, -1)$ | $3$ |
| $2$ | $2$ | $(0, -\tfrac12, \tfrac12)$ | $1$ |

*Worked example.* Take $N = 2$ and $f : \{1,2,3\} \to \mathbb{N}$ with values $0, 1, 1$. Then $p_0 = 3$, $p_1 = 2$, $p_2 = 2$, and the three rows give
$$c_f(0) = 3 - 3 + 1 = 1, \qquad c_f(1) = 0 + 4 - 2 = 2, \qquad c_f(2) = 0 - 1 + 1 = 0,$$
which is indeed the histogram of $\{\!\{0,1,1\}\!\}$.

---

## 4. Rigidity theorems

**Theorem 4.1 (Rigidity of value distributions).** Let $f : \alpha \to \mathbb{N}$ and $g : \beta \to \mathbb{N}$ be $N$-bounded functions on finite index sets $\alpha$ and $\beta$. If $p_k(f) = p_k(g)$ for all $k \le N$, then $c_f(v) = c_g(v)$ for all $v \in \mathbb{N}$.

*Proof sketch.* For $v \le N$ apply Theorem 3.5 to both sides; the two rational expressions are term-by-term identical because the power sums agree on the window. The resulting equality of rationals is an equality of the underlying integers. For $v > N$ both counts vanish by $N$-boundedness. $\square$

Note the shape of the hypothesis: nothing whatsoever is assumed about the relationship between $\alpha$ and $\beta$.

**Corollary 4.2 (Equal cardinalities).** Under the hypothesis of Theorem 4.1, $\#\alpha = \#\beta$. This is the $k = 0$ component of the hypothesis, and is a genuine conclusion rather than an assumption.

**Corollary 4.3 (Equal value multisets).** Under the hypothesis of Theorem 4.1, $\mathcal{V}(f) = \mathcal{V}(g)$, since multiset equality is exactly pointwise equality of multiplicities.

**Theorem 4.4 (Rigidity up to relabelling).** Under the hypothesis of Theorem 4.1, there exists a bijection $e : \alpha \to \beta$ with $g(e(i)) = f(i)$ for all $i \in \alpha$.

*Proof sketch.* For each $v$, Theorem 4.1 gives $\#f^{-1}(v) = \#g^{-1}(v)$, hence a bijection $e_v : f^{-1}(v) \to g^{-1}(v)$ between the corresponding fibres. Since $\alpha$ is the disjoint union of its $f$-fibres and $\beta$ of its $g$-fibres, assembling the $e_v$ produces a bijection $e$ of the total sets that is fibre-preserving by construction, i.e. satisfies $g \circ e = f$. $\square$

Theorem 4.4 is the strongest form of the statement: agreement of the power sums on the window $\{0, \dots, N\}$ is *equivalent* to the two labelled data sets being equal up to relabelling of the index set. (The converse implication is immediate, since power sums are invariant under relabelling.)

**Theorem 4.5 (Spectral corollary).** Let $A$ and $B$ be diagonal rational matrices, of possibly different sizes, whose diagonal entries are natural numbers bounded by $N$. If $\operatorname{tr}(A^k) = \operatorname{tr}(B^k)$ for all $k \le N$, then $A$ and $B$ have the same eigenvalue multiplicities.

*Proof sketch.* For a diagonal matrix with diagonal $f$, $\operatorname{tr}(A^k) = \sum_i f(i)^k = p_k(f)$. Apply Theorem 4.1. $\square$

Because trace of powers is a similarity invariant, Theorem 4.5 extends verbatim to any pair of diagonalisable rational matrices whose eigenvalue lists take values in $\{0,\dots,N\}$: the first $N+1$ power traces determine the spectrum with multiplicity.

---

## 5. Canonicity, two-sidedness and the moment automorphism

The inversion matrix is not one choice among many.

**Theorem 5.1 (Uniqueness of the inversion operator).** Fix $v \le N$ and suppose $a : \{0,\dots,N\} \to \mathbb{Q}$ satisfies
$$c(v) \;=\; \sum_{k=0}^{N} a_k \sum_{j=0}^{N} c(j)\, j^k$$
for *every* $c : \{0,\dots,N\} \to \mathbb{Q}$. Then $a_k = W_N(v,k)$ for all $k \le N$.

*Proof sketch.* Both $a$ and the $v$-th row of $W_N$ are left inverses, on the row indexed by $v$, of the invertible matrix $V^{\mathsf T}_N$; equivalently, testing the hypothesis on the standard basis vectors $c = \delta_j$ shows that $a$ and $W_N(v,\cdot)$ have the same pairing with every column of $V^{\mathsf T}_N$, and the columns span $\mathbb{Q}^{N+1}$ because the Vandermonde determinant $\prod_{i<j}(j-i)$ is nonzero. $\square$

**Theorem 5.2 (Vandermonde invertibility).** The Vandermonde matrix of the nodes $0, 1, \dots, N$ over $\mathbb{Q}$, and hence its transpose, is invertible; its determinant is $\prod_{0 \le i < j \le N} (j - i) = \prod_{j=1}^{N} j! \ne 0$.

**Theorem 5.3 (Two-sidedness; dual delta identity).** For $0 \le k, k' \le N$,
$$\sum_{j=0}^{N} j^k\, W_N(j, k') \;=\; \begin{cases}1, & k = k',\\ 0, & \text{otherwise.}\end{cases}$$
Equivalently, $V^{\mathsf T}_N \cdot W_N^{\mathsf T} = I$ as well as $W_N^{\mathsf T} \cdot V^{\mathsf T}_N = I$.

*Proof sketch.* Two routes. (i) Matrix algebra: a one-sided inverse of a square matrix over a field is two-sided, so Theorem 3.2 already gives it. (ii) Interpolation directly: interpolate the monomial $X^k$ (of degree $k < N+1$) through the nodes, obtaining $X^k = \sum_{j} j^k L^{(N)}_j(X)$, and extract the coefficient of $X^{k'}$ on both sides. The second route generalises verbatim to arbitrary node sets over arbitrary fields and is what we use in Section 7. $\square$

**Corollary 5.4 (Moment map is an automorphism).** The $\mathbb{Q}$-linear map
$$\mathcal{M}_N : \mathbb{Q}^{N+1} \to \mathbb{Q}^{N+1}, \qquad \mathcal{M}_N(c)_k = \sum_{j=0}^{N} c(j)\, j^k$$
is a linear automorphism, with inverse given by $\mathcal{M}_N^{-1}(m)_v = \sum_k W_N(v,k) m_k$.

Thus the moment map is *onto* as well as injective: **every** prescribed vector of $N+1$ moments is realised by exactly one rational weighting of the nodes $0,\dots,N$. (Realisability by a *nonnegative integer* weighting is of course a different and much more restrictive question.)

**Proposition 5.5 (Non-degeneracy of the Lebesgue constant).** For every $v \le N$, $\Lambda_N(v) > 0$.

*Proof sketch.* If the $v$-th row of $W_N$ were zero, the polynomial $L^{(N)}_v$ would be zero, contradicting $L^{(N)}_v(v) = 1$. $\square$

Proposition 5.5 guarantees that the stability criterion of the next section is never vacuous (a zero Lebesgue constant would formally allow arbitrarily large $\varepsilon$).

---

## 6. Stability and exact recovery

Real data give approximate power sums. The following two results quantify the consequences.

**Theorem 6.1 (Stability).** Let $f, g$ be $N$-bounded on finite index sets and let $\varepsilon \in \mathbb{Q}$ satisfy
$$\big| p_k(f) - p_k(g) \big| \;\le\; \varepsilon \qquad \text{for all } k \le N.$$
Then for every $v \le N$,
$$\big| c_f(v) - c_g(v) \big| \;\le\; \Lambda_N(v)\,\varepsilon .$$

*Proof sketch.* Subtract the two instances of Theorem 3.5 to write $c_f(v) - c_g(v) = \sum_k W_N(v,k)\,(p_k(f) - p_k(g))$; then apply the triangle inequality and bound each factor, which is exactly the $\ell^1$–$\ell^\infty$ duality pairing whose constant is $\Lambda_N(v)$. $\square$

**Theorem 6.2 (Robust exact recovery).** In the setting of Theorem 6.1, if additionally
$$\Lambda_N(v)\,\varepsilon \;<\; 1,$$
then $c_f(v) = c_g(v)$ exactly.

*Proof sketch.* $c_f(v)$ and $c_g(v)$ are integers. If they differed, their difference would have absolute value at least $1$, contradicting the bound $|c_f(v) - c_g(v)| \le \Lambda_N(v)\varepsilon < 1$ from Theorem 6.1. $\square$

Theorem 6.2 is the practically important statement: it converts a purely qualitative injectivity result into a usable error budget. Given a measurement accuracy $\varepsilon$ on the power sums, the histogram entry at $v$ is *provably exactly* recovered as soon as $\varepsilon < 1/\Lambda_N(v)$.

### 6.1 The size of the Lebesgue constant

The Lebesgue constant is a purely combinatorial quantity attached to the nodes and to $v$. Because $L^{(N)}_0(X) = \prod_{j=1}^{N} (1 - X/j)$ has coefficients of alternating sign (the elementary symmetric functions of the positive nodes being positive), the $\ell^1$-norm of its coefficient vector equals $|L^{(N)}_0(-1)|$, giving
$$\Lambda_N(0) \;=\; \prod_{j=1}^{N} \Big(1 + \frac{1}{j}\Big) \;=\; N + 1,$$
in agreement with the table of Section 3.1 ($\Lambda_1(0) = 2$, $\Lambda_2(0) = 3$). Interior nodes behave far worse: the alternating-sign structure is lost, and the $\ell^1$-norms of the interior rows grow exponentially in $N$, reflecting the classical ill-conditioning of moment inversion on equispaced nodes. This growth is not an artifact of the method — by Theorem 5.1 the inversion row is unique, so $\Lambda_N(v)$ is an intrinsic conditioning constant of the problem, not of a particular algorithm.

**Design consequence.** Since $\Lambda_N(v)$ is exactly computable in rational arithmetic for any given $N$, one can, before collecting data, compute the accuracy $1/\Lambda_N(v)$ needed to guarantee exact recovery at each value $v$. Recovery at the extreme nodes is cheap; recovery in the middle of the range is expensive.

---

## 7. Arbitrary node sets: the number of values is the real parameter

The bound $N$ entered the argument only by constraining the *set* of achievable values to $\{0,\dots,N\}$, a set of $N+1$ elements. Replacing it by an arbitrary node set shows what is really going on. In this section $F$ is a field (characteristic zero suffices; more precisely, all that is needed is that distinct nodes have invertible differences and that natural-number counts embed injectively into $F$).

**Definition 7.1 (Nodal inverse coefficients).** For a finite $S \subseteq F$ and $v \in S$, let $L^S_v(X) = \prod_{b \in S, b \ne v} \frac{X-b}{v-b}$ and let $\mathrm{ni}_S(v,k) = [X^k] L^S_v(X)$.

**Theorem 7.2 (Delta identity over an arbitrary node set).** For $v, j \in S$,
$$\sum_{k=0}^{\#S - 1} \mathrm{ni}_S(v,k)\, j^k \;=\; \delta_{jv}.$$

**Theorem 7.3 (Inversion over an arbitrary node set).** For any $c : S \to F$ and any $v \in S$,
$$c(v) \;=\; \sum_{k=0}^{\#S-1} \mathrm{ni}_S(v,k) \sum_{j \in S} c(j)\, j^k .$$

**Theorem 7.4 (Node-set rigidity).** Let $f : \alpha \to F$ and $g : \beta \to F$ be functions on finite index sets, both taking values in a common finite $S \subseteq F$. If $\sum_{i} f(i)^k = \sum_j g(j)^k$ for all $k < \#S$, then $f$ and $g$ have the same value distribution: $\#f^{-1}(v) = \#g^{-1}(v)$ for every $v \in F$.

*Proof sketch.* For $v \in S$ apply Theorem 7.3 to the count vectors, noting that the power sums are exactly the power moments of the count vector supported on $S$; for $v \notin S$ both counts vanish. $\square$

**Corollary 7.5 (Sparse rigidity over $\mathbb{N}$).** If $f$ and $g$ take values in a common $T \subseteq \mathbb{N}$ with $\#T = m$, and $p_k(f) = p_k(g)$ for all $k < m$, then $c_f = c_g$ — regardless of how large the elements of $T$ are.

*Proof sketch.* Embed $T$ into $\mathbb{Q}$ by the (injective) canonical map, so that $\#\iota(T) = \#T$; power sums and counts are preserved by the embedding; apply Theorem 7.4. $\square$

Taking $T = \{0,\dots,N\}$ recovers Theorem 4.1. Taking $T = \{0, 10^6\}$ shows that two power sums — the cardinality and the sum — suffice to determine the histogram of a function known to take only those two values. The window length is $\#T$, never the magnitude of $T$'s elements.

**Theorem 7.6 (Dual delta identity over an arbitrary node set).** For $k, k' < \#S$,
$$\sum_{j \in S} j^k\, \mathrm{ni}_S(j, k') \;=\; \delta_{kk'} .$$

*Proof sketch.* Interpolation of the monomial: since $\deg X^k = k < \#S$, Lagrange interpolation of $X^k$ through the nodes $S$ is exact, giving the polynomial identity $X^k = \sum_{j \in S} j^k L^S_j(X)$. Extracting the coefficient of $X^{k'}$ on both sides yields the claim. Notably this argument requires no matrix algebra at all. $\square$

---

## 8. Sharpness: the window cannot be shortened

Theorem 7.6 does more than tidy up the linear algebra: its last column is the engine of the sharpness construction.

**Definition 8.1 (Nodal weight vector).** For nonempty finite $A \subseteq \mathbb{N}$ with $\#A = m$, put $w_a = \mathrm{ni}_A(a, m-1)$ for $a \in A$ (the top-degree coefficient of $L^A_a$).

**Proposition 8.2 (Closed form).** $\displaystyle w_a = \prod_{\substack{b \in A \\ b \ne a}} \frac{1}{a - b}$.

*Proof sketch.* $L^A_a(X) = \prod_{b \ne a}(X - b) \big/ \prod_{b \ne a}(a-b)$; the numerator is monic of degree $m-1$, so the coefficient of $X^{m-1}$ is the reciprocal of the denominator. $\square$

**Proposition 8.3 (Annihilation and normalisation).** For $k < m$,
$$\sum_{a \in A} a^k\, w_a \;=\; \begin{cases}0, & k < m-1,\\ 1, & k = m-1.\end{cases}$$

*Proof sketch.* This is exactly the case $k' = m-1$ of Theorem 7.6, transported along the embedding $A \hookrightarrow \mathbb{Q}$. $\square$

In particular $w$ is a nonzero rational vector supported on $A$ that annihilates all power moments of order $< m-1$: a canonical element of the kernel of the *truncated* moment map. This is what makes the near-miss.

**Construction 8.4 (Near-miss pair).** Let $D = \prod_{a \in A} \mathrm{den}(w_a)$ be a common denominator, and set $z_a = D\, w_a \in \mathbb{Z}$, so that $z \ne 0$ and, by Proposition 8.3,
$$\sum_{a \in A} z_a\, a^k = 0 \qquad (k < m-1).$$
Split $z$ into its positive and negative parts, $z_a = z_a^{+} - z_a^{-}$ with $z_a^{\pm} \in \mathbb{N}$ and $z_a^{+} z_a^{-} = 0$. Let $\mathcal{S}^{+}$ be the multiset containing each $a \in A$ with multiplicity $z_a^{+}$, and $\mathcal{S}^{-}$ likewise with multiplicities $z_a^{-}$, and let $f, g$ be functions on finite index sets realising $\mathcal{S}^{+}$ and $\mathcal{S}^{-}$ respectively.

**Theorem 8.5 (Insufficiency of the window $k < \#A - 1$).** For every nonempty finite $A \subseteq \mathbb{N}$ the functions $f, g$ of Construction 8.4 take values in $A$, satisfy
$$p_k(f) = p_k(g) \qquad \text{for all } k < \#A - 1,$$
and have different value distributions.

*Proof sketch.* Equality of power sums on the short window is the identity $\sum_a z_a^{+} a^k = \sum_a z_a^{-} a^k$, which is precisely $\sum_a z_a a^k = 0$ rearranged, and this holds for $k < m-1$ by Construction 8.4. The distributions differ because $z \ne 0$: pick $a$ with $z_a \ne 0$; then exactly one of $z_a^{+}, z_a^{-}$ is nonzero, so the counts of the value $a$ in $\mathcal{S}^{+}$ and $\mathcal{S}^{-}$ differ. Non-vanishing of $z$ follows from $w_a = \prod_{b \ne a}(a-b)^{-1} \ne 0$. $\square$

**Theorem 8.6 (Exact threshold).** Let $A \subseteq \mathbb{N}$ be nonempty and finite with $\#A = m$. Then:

1. *(Sufficiency)* For all finite index sets $\alpha, \beta$ and all $f : \alpha \to \mathbb{N}$, $g : \beta \to \mathbb{N}$ with values in $A$: if $p_k(f) = p_k(g)$ for all $k < m$, then $c_f = c_g$.
2. *(Necessity)* There exist such $f, g$ with values in $A$ satisfying $p_k(f) = p_k(g)$ for all $k < m - 1$ and $c_f \ne c_g$.

*Proof sketch.* (1) is Corollary 7.5; (2) is Theorem 8.5. $\square$

**Corollary 8.7 (Interval case).** For every $N \ge 1$ there exist $N$-bounded functions on finite index sets whose power sums agree for all $k < N$ but whose value distributions differ. Hence the window $p_0, \dots, p_N$ of Theorem 4.1 is optimal.

### 8.1 The construction in examples

- $A = \{0,1,2\}$, $m = 3$. Weights $w = (\tfrac12, -1, \tfrac12)$; common denominator $2$; $z = (1, -2, 1)$. The near-miss pair is $\mathcal{S}^{+} = \{\!\{0, 2\}\!\}$ versus $\mathcal{S}^{-} = \{\!\{1,1\}\!\}$. Both have $p_0 = 2$ and $p_1 = 2$; they diverge at $p_2$ ($4$ versus $2$). This is exactly the classical minimal example, produced here by a generic recipe.
- $A = \{0,1,5\}$, $m = 3$. Weights $w = (\tfrac15, -\tfrac14, \tfrac1{20})$; common denominator $20$; $z = (4, -5, 1)$. The pair is $\{\!\{0,0,0,0,5\}\!\}$ versus $\{\!\{1,1,1,1,1\}\!\}$: five elements each, both summing to $5$, wildly different histograms. They diverge at $p_2$ ($25$ versus $5$).
- $A = \{0,1,2,3\}$, $m = 4$. Weights $(-\tfrac16, \tfrac12, -\tfrac12, \tfrac16)$; $z = (-1, 3, -3, 1)$, i.e. the pair $\{\!\{1,1,1,3\}\!\}$ versus $\{\!\{0,2,2,2\}\!\}$: equal $p_0, p_1, p_2$, different histograms.

The binomial pattern $z_a = (-1)^{m-1-a}\binom{m-1}{a}$ visible in the interval cases is no accident: for $A = \{0,\dots,m-1\}$ one has $w_a = (-1)^{m-1-a} / \big(a!\,(m-1-a)!\big)$, so clearing the denominator $(m-1)!$ gives exactly the alternating binomial coefficients — the coefficient vector of the $(m-1)$-st finite difference operator, whose annihilation of polynomials of degree $< m-1$ is the classical statement behind the construction.

---

## 9. Algorithms

The results above are constructive, and translate directly into three procedures.

### 9.1 Building the inversion matrix

**Input:** $N \in \mathbb{N}$ (or a general node set $A$).
**Output:** the exact rational matrix $W_N$.

Compute the master polynomial $M(X) = \prod_{j=0}^{N} (X - j)$ by repeated multiplication ($O(N^2)$ coefficient operations), then for each node $v$ divide out the factor $(X - v)$ by synthetic division ($O(N)$ per node) and scale by $\prod_{j \ne v}(v-j)^{-1}$. The total cost is $O(N^2)$ exact rational operations, and the resulting rows are the desired coefficient vectors. A direct product-of-linear-factors expansion per node costs $O(N^2)$ per node, $O(N^3)$ overall, and should be avoided for large $N$.

### 9.2 Distribution recovery with a certificate

**Input:** a bound $N$, measured power sums $\tilde p_0, \dots, \tilde p_N$ and an error bound $\varepsilon$ with $|\tilde p_k - p_k| \le \varepsilon/2$.
**Output:** the exact histogram $(c(0), \dots, c(N))$ together with a per-node certificate of correctness.

Form $\hat c(v) = \sum_k W_N(v,k)\,\tilde p_k$ and round to the nearest integer. By Theorem 6.2, if $\Lambda_N(v)\varepsilon < 1$ then the rounded value is provably the true count; otherwise the algorithm reports the node as uncertified. The cost after precomputation is $O(N)$ per node, $O(N^2)$ overall, plus $O(N^2)$ for the Lebesgue constants.

### 9.3 Near-miss synthesis on an arbitrary node set

**Input:** a nonempty finite $A \subseteq \mathbb{N}$.
**Output:** two multisets with values in $A$, equal power sums for all $k < \#A - 1$, and different histograms.

Compute the nodal weights $w_a = \prod_{b \ne a}(a-b)^{-1}$ in exact arithmetic ($O(m^2)$ operations), clear denominators to get $z \in \mathbb{Z}^m$ (optionally dividing by $\gcd$ to obtain the primitive witness), and emit the positive and negative parts as multisets. Correctness is Theorem 8.5.

---

## 10. Applications

**Streaming and sketching.** A stream of quantised observations is often summarised by running power sums, which are trivially mergeable across shards and updatable in $O(1)$ per item. If the alphabet of possible values is a known finite set $A$, Theorem 8.6 says the sketch consisting of the first $\#A$ power sums is a *lossless* summary of the histogram, and Theorem 6.2 gives the arithmetic precision at which the summary remains lossless.

**Database aggregates.** A query engine holding cached aggregates $\sum x, \sum x^2, \dots$ over a column with a small domain can answer exact per-value count queries without touching the base data.

**Spectral fingerprints.** Graphs and matrices whose spectra are known to be small integers (adjacency spectra of certain strongly regular or highly structured graphs, permutation-like matrices, projections) are determined up to spectral multiplicity by their first few power traces, by Theorem 4.5.

**Privacy analysis.** The theorems are also negative results about aggregate release: publishing $\#A$ power sums of a quantised attribute reveals the exact histogram of that attribute, and Theorem 6.2 quantifies how much noise (relative to $1/\Lambda$) must be added before the reconstruction demonstrably fails. Conversely, Theorem 8.5 shows that releasing one power sum fewer leaves genuine ambiguity — an ambiguity realised by an explicit pair of populations.

**Chemistry and inverse problems by moments.** Recovery of discrete mass distributions supported on a known finite grid is exactly the setting of Theorem 7.4: the grid supplies the nodes, and the window length is the grid size.

---

## 11. Discussion

Three features distinguish the treatment given here from a bare injectivity statement.

**Explicitness.** Having the inverse operator rather than merely knowing it exists is what makes the stability theory possible: $\Lambda_N(v)$ is a property of the inverse, invisible to an abstract injectivity proof. Theorem 5.1 shows nothing is lost by this choice — the operator is unique, so its Lebesgue constant is the intrinsic conditioning of the problem.

**Integrality as a resource.** The passage from Theorem 6.1 to Theorem 6.2 uses only that counts are integers, but it changes the character of the result completely: from a continuity statement to a guarantee of exactness within a computable radius. This is the same mechanism that underlies exact recovery in integer compressed sensing and error-correcting codes, in an unusually transparent form.

**Cardinality, not magnitude.** The most useful practical corollary is Theorem 8.6. It is easy to assume that reconstructing a distribution over values up to $10^6$ requires $10^6$ moments; in fact it requires only as many moments as there are attainable values. The threshold is exact in both directions, so this is a complete answer for the discrete moment problem on a known finite support.

**Limitations.** The results assume that a finite superset of the attainable values is known in advance; without such a support hypothesis, no finite window of power sums determines the distribution (arbitrarily large values can hide in the tail). The conditioning is genuinely bad for interior nodes at large $N$, so the guarantees of Section 6 are strong for small alphabets and demanding for large ones. Finally, the surjectivity statement of Corollary 5.4 concerns *rational* weightings; characterising which integer moment vectors arise from genuine nonnegative histograms is the discrete truncated moment problem, and is not addressed here.

---

## 12. Future directions

Five falsifiable conjectures suggest themselves.

**C1. The Lebesgue constant of the interval nodes.** For the nodes $0, \dots, N$, we conjecture $\Lambda_N(0) = N+1$ in general (verified above for $N \le 2$ and derived from the sign-alternation of $L^{(N)}_0$), and, more ambitiously, an exact closed form for $\Lambda_N(v)$ at all interior nodes together with the identification of the maximising node. The key insight is that $L^{(N)}_0(X) = \prod_{j=1}^{N}(1 - X/j)$ has coefficients of alternating sign, so the $\ell^1$-norm of its coefficient vector equals $|L^{(N)}_0(-1)| = \prod_{j=1}^{N}(1 + 1/j) = N+1$; sign alternation is exactly the positivity of the elementary symmetric functions of the positive nodes. A closed form would turn the qualitative robustness statement of Theorem 6.2 into a usable error budget.

**C2. Quantised separation on arbitrary node sets.** Let $A \subseteq \mathbb{N}$ with $\#A = m+1$ and let $f, g$ take values in $A$ with power sums agreeing for all $k < m$. We conjecture that if their value distributions differ then the top moment gap is *quantised*:
$$\big| p_m(f) - p_m(g) \big| \;\ge\; \frac{\prod_{a \in A}\prod_{b \in A,\, b > a} (b-a)}{D_A}$$
for an explicit $D_A$ depending only on the nodal weights — with the interval case $A = \{0,\dots,N\}$ giving the bound $N!$. The key insight is that the count difference is an integer multiple of the nodal weight vector $w$, so the top moment lives in the lattice generated by $1/w$. Theorem 8.5 produces the extremal witness for every $A$; a matching lower bound would show that the witness is not merely an example but the minimiser.

**C3. Optimality of the stability estimate.** We conjecture that for every $N$ and $v \le N$ there are bounded functions $f, g$ and an $\varepsilon > 0$ with $|p_k(f) - p_k(g)| \le \varepsilon$ for all $k \le N$ and $|c_f(v) - c_g(v)| \ge c\,\Lambda_N(v)\,\varepsilon$ for an absolute constant $c > 0$. The key insight is that the extremal input for the $\ell^1$–$\ell^\infty$ duality bound of Theorem 6.1 is the sign pattern of the inverse row, which is realised by the positive/negative split of the nodal weight vector — exactly the construction of Section 8. Together with C1 this would pin down the conditioning of power-sum inversion completely, turning Theorem 6.2 from a sufficient criterion into a sharp threshold.

**C4. Optimal node selection.** Given freedom to choose which $m$ power sums to observe (not necessarily $p_0, \dots, p_{m-1}$), which index set minimises the resulting Lebesgue constants? Generalised Vandermonde determinants (Schur functions) enter here, and the answer is plausibly related to the classical superiority of Chebyshev-like distributions in interpolation.

**C5. Multivariate power-sum inversion.** For functions valued in $\{0,\dots,N\}^d$, the analogous question asks which finite set of mixed moments $\sum_i f_1(i)^{k_1}\cdots f_d(i)^{k_d}$ determines the joint distribution. Tensor-product Lagrange bases give sufficiency for the full box of multi-indices; the sharp minimal window, presumably related to the combinatorics of the vanishing ideal of the node grid, is open.

---

## 13. Conclusion

For $\mathbb{N}$-valued functions on finite index sets with values in a known finite palette $A$, the first $\#A$ power sums are a complete, lossless invariant of the value distribution — and one power sum fewer is not. The reconstruction is performed by a single canonical rational matrix, the coefficient matrix of the Lagrange basis of the nodes $A$; the matrix is the unique linear operator that performs the task; it is a two-sided inverse of the transposed Vandermonde matrix, so the moment map is a linear automorphism; and the $\ell^1$-norms of its rows measure, exactly, how much perturbation of the observed power sums can be tolerated before the integrality of counts no longer forces exact recovery. Everything in the theory — rigidity up to relabelling, the spectral corollary, robust recovery, and the sharp threshold — flows from possessing that one explicit inverse.
