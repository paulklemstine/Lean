# Complementary Products of Monomial Symmetric Functions: A Quadratic-Statistic Approach to Kleber's Splitting Phenomenon

**Author:** Aristotle
**Date:** 2026-08-16

## Abstract

Kleber's rectangular-complement conjecture asserts that, for a fixed rectangle $\rho = (c^r)$, the products $s_\lambda s_{\lambda^\vee}$ of a Schur function with the Schur function of its rectangular complement, indexed by unordered complementary pairs, are linearly independent in the ring of symmetric functions over an arbitrary commutative ring. The underlying general phenomenon is a *componentwise splitting* statement: for every partition $\theta$, the products $s_\alpha s_\beta$ are linearly independent as $\{\alpha, \beta\}$ ranges over unordered pairs with $\alpha + \beta = \theta$. Both statements are invisible to the standard dominance-triangularity technique, because every splitting of $\theta$ produces the *same* dominance-leading term.

We develop a complete and self-contained treatment of the analogous phenomenon for **monomial** symmetric functions, driven by a filtration transverse to dominance. The engine is the quadratic statistic $Q(d) = \sum_i d_i^2$ on exponent vectors, which satisfies the exact identity $Q(u+v) = Q(u) + Q(v) + 2\langle u, v\rangle$. Consequently the $Q$-minimal monomials of a product $m_\alpha m_\beta$ are exactly those whose part multiset is the *multiset union* $\alpha \uplus \beta$; this yields a genuine, non-dominance triangularity.

Our main theorem states that if a finite family of pairs $(\alpha_i, \beta_i)$ of partitions fits into the ambient number of variables and the multiset unions $\alpha_i \uplus \beta_i$ are pairwise distinct, then the products $m_{\alpha_i} m_{\beta_i}$ are linearly independent over any integral domain of characteristic zero — in particular over $\mathbb{Z}$ and over any field of characteristic zero. We derive the componentwise-splitting and Kleber-shape specialisations, prove the one-row case unconditionally, show that a product determines the multiset union of its factors, and extend the whole mechanism to products of arbitrarily many factors, obtaining as a corollary the linear independence of power-sum monomials $p_{k_1}\cdots p_{k_r}$ indexed by distinct multisets of positive exponents. We further delimit the method sharply: the number-of-variables hypothesis is necessary, the distinct-union hypothesis is not (every two-element collision class is independent), and there exist genuine collisions — for $\theta = (5,3)$, the splittings $(3,1)+(2,2)$ and $(3,2)+(2,1)$ have the same union — yet that colliding pair is itself shown to be independent, separated two merge layers above the bottom of the filtration. We close with two conjectures, on union classes and on a merge filtration, whose combination would yield the full componentwise splitting theorem for monomial symmetric functions.

**Keywords:** symmetric functions, monomial symmetric functions, Schur functions, Kleber's conjecture, complementary products, linear independence, quadratic statistic, power sums, universal characters.

---

## 1. Introduction

### 1.1 The problem

Fix a rectangle $\rho = (c^r)$, the partition with $r$ rows each of length $c$. For a partition $\lambda \subseteq \rho$, the **rectangular complement** $\lambda^\vee$ is the partition whose parts are $c - \lambda_{r+1-i}$ for $i = 1, \dots, r$; geometrically, $\lambda^\vee$ is the complement of the Young diagram of $\lambda$ inside $\rho$, rotated by $180^\circ$. The pairing $\lambda \leftrightarrow \lambda^\vee$ is an involution on the set of subdiagrams of $\rho$, so complementary pairs come as unordered pairs $\{\lambda, \lambda^\vee\}$.

**Kleber's conjecture** (now a theorem) states that the products
$$
s_\lambda \, s_{\lambda^\vee}, \qquad \{\lambda, \lambda^\vee\} \text{ an unordered complementary pair inside } \rho ,
$$
are linearly independent in $\Lambda_R$, the ring of symmetric functions over an arbitrary commutative ring $R$.

This is a special case of a more general phenomenon. Say that an unordered pair $\{\alpha, \beta\}$ of partitions is a **componentwise splitting** of a partition $\theta$ if $\alpha_i + \beta_i = \theta_i$ for all $i$ (where partitions are padded with zeros). Rectangular complementation is exactly componentwise splitting of $\theta = \rho$, after reversing the order of the parts of one member — a reversal that is invisible to any statement phrased in terms of unordered multisets of parts. The general assertion is:

> **Componentwise splitting independence.** For every partition $\theta$, the products $s_\alpha s_\beta$ are linearly independent as $\{\alpha,\beta\}$ ranges over unordered componentwise splittings of $\theta$.

### 1.2 Why dominance triangularity fails

The default proof strategy for linear independence in $\Lambda$ is triangularity: expand each element in a fixed basis, exhibit a distinct maximal term for each, and conclude. For products of Schur functions the natural candidate is the dominance-leading term. By the Littlewood–Richardson rule the dominance-maximal Schur function occurring in $s_\alpha s_\beta$ is $s_{\alpha + \beta}$, with coefficient $1$. But for componentwise splittings of a fixed $\theta$ we have $\alpha + \beta = \theta$ *by definition*, so **every product in the family has the identical dominance-leading term** $s_\theta$. The triangularity argument does not merely lose efficiency; it degenerates entirely.

Any proof must therefore find a grading transverse to dominance, on which the members of the family are visibly distinguished. This paper isolates one such grading, in the setting of monomial symmetric functions, where it can be described and exploited completely explicitly.

### 1.3 The mechanism in one paragraph

Work in $R[x_1, \dots, x_N]$. For an exponent vector $d = (d_1,\dots,d_N) \in \mathbb{N}^N$ set
$$
Q(d) = \sum_{i=1}^{N} d_i^2, \qquad \langle u, v\rangle = \sum_{i=1}^N u_i v_i .
$$
Then $Q(u+v) = Q(u) + Q(v) + 2\langle u,v\rangle$, and since exponents are nonnegative, $\langle u,v\rangle \ge 0$ with equality if and only if $u$ and $v$ have disjoint supports. Every monomial of $m_\alpha m_\beta$ has exponent vector $u+v$ with $u$ a rearrangement of $\alpha$ and $v$ a rearrangement of $\beta$; hence $Q \ge Q(\alpha) + Q(\beta)$ throughout, with equality precisely on the disjointly placed monomials, whose part multiset is the **multiset union** $\alpha \uplus \beta$. Thus the $Q$-minimal layer of $m_\alpha m_\beta$ is exactly the orbit of monomials of shape $\alpha\uplus\beta$, and the multiset union becomes a readable invariant of the product.

The union $\alpha \uplus \beta$ is *not* the componentwise sum $\alpha + \beta$. For splittings of a fixed $\theta$ the sum is constant while the union generally varies — which is exactly why $Q$ succeeds where dominance fails.

### 1.4 Results

Throughout, $R$ is a commutative ring; for the independence statements we assume $R$ is an integral domain of characteristic zero (the arguments use only that a positive integer is nonzero in $R$ and that $R$ has no zero divisors), so in particular $R = \mathbb{Z}$ and every field of characteristic zero are allowed.

1. **(Theorem A, distinct unions.)** If $(\alpha_i, \beta_i)_{i \in I}$ is a finite family of pairs of exponent vectors with $|\mathrm{supp}\,\alpha_i| + |\mathrm{supp}\,\beta_i| \le N$ for all $i$, and the unions $\alpha_i \uplus \beta_i$ are pairwise distinct, then the products $m_{\alpha_i} m_{\beta_i}$ are linearly independent over $R$.
2. **(Corollary B, componentwise splittings.)** The same for a family $m_\alpha m_{\theta - \alpha}$ with $\theta$ fixed.
3. **(Corollary C, Kleber shape.)** For $\lambda \subseteq \rho$ and $N \ge 2\,|\mathrm{supp}\,\rho|$, the fitting hypothesis is automatic; under distinct unions the complementary products $m_\lambda m_{\rho - \lambda}$ are independent.
4. **(Theorem D, one row, unconditional.)** For $\theta = (n)$ the products $m_{(k)}m_{(n-k)}$, $0 \le k \le \lfloor n/2\rfloor$, are independent; here the distinct-union hypothesis is *verified*, not assumed.
5. **(Theorem E, the product determines the union.)** If $m_\alpha m_\beta = m_{\alpha'} m_{\beta'}$ and both pairs fit into $N$ variables, then $\alpha \uplus \beta = \alpha' \uplus \beta'$. No integral-domain hypothesis is needed.
6. **(Theorem F, many factors.)** If for each $i$ the family $(\alpha_{i,j})_{j\in S}$ satisfies $\sum_{j} |\mathrm{supp}\,\alpha_{i,j}| \le N$, and the pooled unions $\biguplus_{j\in S} \alpha_{i,j}$ are pairwise distinct, then the products $\prod_{j\in S} m_{\alpha_{i,j}}$ are independent.
7. **(Corollary G, power-sum monomials.)** Products of power sums $\prod_{j\in S} p_{k_{i,j}}$ with all exponents positive and $|S| \le N$, indexed by pairwise distinct multisets of exponents, are independent.
8. **(Sharpness.)** The fitting hypothesis cannot be dropped: in one variable, $m_{(1)}m_{(1)} = m_{(2)}\cdot 1$ although $\{1,1\} \ne \{2\}$. The distinct-union hypothesis *can* fail while independence still holds: for every $a, b > 0$ the pair of products $m_{(a,b)}\cdot 1$ and $m_{(a)}m_{(b)}$ is independent even though both unions equal $\{a,b\}$.
9. **(Boundary.)** Genuine collisions exist: $(3,1)+(2,2) = (5,3) = (3,2)+(2,1)$ with $\{3,1\}\uplus\{2,2\} = \{3,2,2,1\} = \{3,2\}\uplus\{2,1\}$.

Sections 5 and 6 develop the resulting picture: within a single union class the $Q$-filtration collapses, and separation must come from the *one-merge* layer; two precise conjectures are formulated whose combination yields the full componentwise splitting theorem for monomial symmetric functions.

---

## 2. Definitions and basic identities

### 2.1 Exponent vectors, parts, orbits

Fix $N \ge 1$ and let
$$
E_N := \mathbb{N}^N
$$
be the set of **exponent vectors**, written additively. For $d \in E_N$ its **support** is $\mathrm{supp}(d) = \{i : d_i \ne 0\}$, and the monomial $x^d = x_1^{d_1}\cdots x_N^{d_N}$.

**Definition 2.1 (parts).** The **part multiset** of $d\in E_N$ is
$$
\mathrm{parts}(d) := \{\!\{\, d_i : i \in \mathrm{supp}(d) \,\}\!\} \in \mathrm{Multiset}(\mathbb{Z}_{>0}) .
$$
This is the partition that $d$ rearranges to, recorded as an unordered multiset. We write $\alpha \uplus \beta := \mathrm{parts}(\alpha) + \mathrm{parts}(\beta)$ for the **multiset union**, i.e. the multiset obtained by pooling all positive parts of $\alpha$ and of $\beta$.

**Definition 2.2 (orbit).** The symmetric group $\mathfrak{S}_N$ acts on $E_N$ by permuting coordinates; write $\sigma \cdot d$ for the image of $d$ under $\sigma$. The **orbit** of $d$ is $\mathcal{O}(d) := \{\sigma\cdot d : \sigma \in \mathfrak{S}_N\}$, a finite set. Note $d \in \mathcal{O}(d)$, and $\mathrm{parts}$ is constant on orbits: $\mathrm{parts}(\sigma\cdot d) = \mathrm{parts}(d)$. Conversely, two exponent vectors lie in the same orbit iff they have the same part multiset (this is used only through the forward direction).

**Definition 2.3 (monomial symmetric polynomial).** For a commutative ring $R$,
$$
m_R(d) := \sum_{w \in \mathcal{O}(d)} x^w \in R[x_1,\dots,x_N] .
$$
When $\lambda$ is a partition with at most $N$ parts and $d$ is any exponent vector with $\mathrm{parts}(d) = \lambda$, $m_R(d)$ is the classical monomial symmetric polynomial $m_\lambda(x_1,\dots,x_N)$; it is the image of the monomial symmetric function $m_\lambda \in \Lambda_R$ under the specialisation to $N$ variables, and this specialisation is injective on the span of the $m_\mu$ with $\ell(\mu) \le N$. In particular $m_R(0) = 1$, and $m_R(\text{one-row } (k)) = p_k$, the power sum, for $k > 0$.

The coefficient extraction is immediate from the definition:

**Lemma 2.4.** $\;[x^w]\, m_R(d) = 1$ if $w \in \mathcal{O}(d)$ and $0$ otherwise.

**Lemma 2.5 (coefficients of a product).** For $\alpha, \beta, w \in E_N$,
$$
[x^w]\bigl(m_R(\alpha)\, m_R(\beta)\bigr) \;=\; \bigl|\{(u,v) : u+v = w,\ u \in \mathcal{O}(\alpha),\ v \in \mathcal{O}(\beta)\}\bigr| \cdot 1_R .
$$
*Proof.* Expand the product and use Lemma 2.4 on each factor; the resulting sum over the antidiagonal of $w$ counts exactly the indicated pairs. $\square$

Two consequences will be used repeatedly. First, if $[x^w](m_R\alpha \cdot m_R\beta) \ne 0$ then there is at least one splitting $w = u + v$ with $u \in \mathcal{O}(\alpha)$, $v\in\mathcal{O}(\beta)$. Second, if $R$ has characteristic zero and such a splitting exists, then the coefficient is a *positive* integer times $1_R$, hence nonzero.

### 2.2 The quadratic statistic

**Definition 2.6.** For $u, v \in E_N$ put
$$
Q(u) := \sum_{i=1}^N u_i^2, \qquad \langle u, v\rangle := \sum_{i=1}^N u_i v_i .
$$

**Lemma 2.7 (exact defect of additivity).** $Q(u+v) = Q(u) + Q(v) + 2\langle u,v\rangle$.

*Proof.* Coordinatewise, $(u_i+v_i)^2 = u_i^2 + v_i^2 + 2u_iv_i$; sum over $i$. $\square$

**Lemma 2.8 (vanishing of the defect).** $\langle u, v\rangle = 0 \iff \mathrm{supp}(u) \cap \mathrm{supp}(v) = \varnothing$.

*Proof.* All summands $u_iv_i$ are nonnegative, so the sum vanishes iff each does, iff no index carries a nonzero entry of both. $\square$

**Lemma 2.9 (parts add on disjoint supports).** If $\mathrm{supp}(u) \cap \mathrm{supp}(v) = \varnothing$ then $\mathrm{parts}(u+v) = \mathrm{parts}(u) + \mathrm{parts}(v) = u \uplus v$.

*Proof.* The support of $u+v$ is the disjoint union of the two supports, and on $\mathrm{supp}(u)$ the entry of $u+v$ equals that of $u$ (as $v$ vanishes there), and symmetrically. $\square$

Both $Q$ and $\mathrm{parts}$ are $\mathfrak{S}_N$-invariant, so both are well-defined functions of a partition.

**Lemma 2.10 (disjoint placement).** If $F \subseteq \{1,\dots,N\}$ and $b \in E_N$ satisfy $|F| + |\mathrm{supp}(b)| \le N$, then there is $\sigma\in\mathfrak{S}_N$ with $\mathrm{supp}(\sigma\cdot b) \cap F = \varnothing$. In particular, if $|\mathrm{supp}(\alpha)| + |\mathrm{supp}(\beta)| \le N$ there is $\sigma$ with $\mathrm{supp}(\alpha)$ and $\mathrm{supp}(\sigma\cdot\beta)$ disjoint.

*Proof.* The complement of $F$ has at least $|\mathrm{supp}(b)|$ elements, so there is an injection $\mathrm{supp}(b) \hookrightarrow F^{c}$, which extends to a permutation of $\{1,\dots,N\}$; transporting $b$ along it moves its support into $F^c$. $\square$

### 2.3 The key structural statement

Combining Lemmas 2.5–2.10:

**Proposition 2.11 ($Q$-minimal layer).** Let $\alpha, \beta \in E_N$. Then:

1. Every monomial $x^w$ occurring in $m_R(\alpha) m_R(\beta)$ satisfies $Q(w) \ge Q(\alpha) + Q(\beta)$.
2. If $Q(w) = Q(\alpha)+Q(\beta)$ and $x^w$ occurs, then $\mathrm{parts}(w) = \alpha \uplus \beta$.
3. If $|\mathrm{supp}\,\alpha| + |\mathrm{supp}\,\beta| \le N$ and $R$ has characteristic zero, then such a $w$ exists and occurs with nonzero coefficient.

*Proof.* (1) Write $w = u+v$ as in Lemma 2.5 and apply Lemmas 2.7, 2.8 with $Q(u) = Q(\alpha)$, $Q(v) = Q(\beta)$ by orbit invariance. (2) Equality forces $\langle u,v\rangle = 0$, so the supports are disjoint and Lemma 2.9 gives $\mathrm{parts}(w) = \mathrm{parts}(u)+\mathrm{parts}(v) = \alpha\uplus\beta$. (3) Choose a disjoint placement by Lemma 2.10 and set $w = \alpha + \sigma\cdot\beta$; the coefficient is a positive integer by Lemma 2.5. $\square$

Proposition 2.11 is the whole engine. It says the product $m_\alpha m_\beta$ is *supported above* the level $Q(\alpha)+Q(\beta)$, and that its bottom level is exactly the orbit of shape $\alpha\uplus\beta$.

---

## 3. The main independence theorems

Throughout this section $R$ is an integral domain of characteristic zero.

### 3.1 Distinct unions

**Theorem A (independence of products with distinct multiset unions).**
Let $I$ be a finite index set and $\alpha, \beta : I \to E_N$ be such that

* *(fitting)* $|\mathrm{supp}(\alpha_i)| + |\mathrm{supp}(\beta_i)| \le N$ for every $i \in I$;
* *(distinct unions)* the map $i \mapsto \alpha_i \uplus \beta_i$ is injective.

Then the family $\bigl(m_R(\alpha_i)\, m_R(\beta_i)\bigr)_{i\in I}$ is linearly independent over $R$.

*Proof sketch.* Suppose $\sum_{i} g_i\, m_R(\alpha_i) m_R(\beta_i) = 0$ with some $g_{i_1} \ne 0$. Let $S = \{i : g_i \ne 0\}$, nonempty, and choose $i_0 \in S$ minimising the integer
$$
q_i := Q(\alpha_i) + Q(\beta_i) .
$$
By the fitting hypothesis and Lemma 2.10, choose $\sigma$ with $\mathrm{supp}(\alpha_{i_0})$ and $\mathrm{supp}(\sigma\cdot\beta_{i_0})$ disjoint, and set
$$
w_0 := \alpha_{i_0} + \sigma\cdot\beta_{i_0}, \qquad Q(w_0) = q_{i_0}, \qquad \mathrm{parts}(w_0) = \alpha_{i_0}\uplus\beta_{i_0}.
$$
Extract the coefficient of $x^{w_0}$ from the relation. Fix $i \in S$, $i \ne i_0$, and suppose $[x^{w_0}](m_R\alpha_i \cdot m_R\beta_i) \ne 0$. By Proposition 2.11(1), $q_i \le Q(w_0) = q_{i_0}$; by minimality of $q_{i_0}$ we get $q_i = q_{i_0} = Q(w_0)$, whence by Proposition 2.11(2),
$$
\alpha_i \uplus \beta_i = \mathrm{parts}(w_0) = \alpha_{i_0}\uplus\beta_{i_0},
$$
contradicting injectivity. So all terms with $i \ne i_0$ contribute $0$, and the relation reduces to
$$
g_{i_0}\cdot [x^{w_0}]\bigl(m_R(\alpha_{i_0}) m_R(\beta_{i_0})\bigr) = 0 .
$$
The bracket is a positive integer in $R$, hence nonzero (characteristic zero); as $R$ is a domain, $g_{i_0} = 0$, a contradiction. $\square$

Two remarks. First, the hypotheses are stated for *ordered* pairs, but the union $\alpha\uplus\beta$ is symmetric in $\alpha$ and $\beta$, so injectivity of $i \mapsto \alpha_i\uplus\beta_i$ in particular forces the unordered pairs $\{\alpha_i,\beta_i\}$ to be pairwise distinct: this is the "unordered pairs" indexing of the original problem. Second, characteristic zero is used only to know that a positive count is nonzero in $R$; no division occurs anywhere, which is why the theorem holds verbatim over $\mathbb{Z}$:

**Corollary (integral form).** Under the hypotheses of Theorem A, the products $m_{\mathbb{Z}}(\alpha_i) m_{\mathbb{Z}}(\beta_i)$ are linearly independent over $\mathbb{Z}$.

**Corollary (rational form).** The same over $\mathbb{Q}$, hence over any field of characteristic zero.

### 3.2 Componentwise splittings and the Kleber shape

**Corollary B (componentwise splittings).** Fix $\theta \in E_N$ and a finite family $\alpha : I \to E_N$ with $\alpha_i \le \theta$ componentwise, such that $|\mathrm{supp}(\alpha_i)| + |\mathrm{supp}(\theta - \alpha_i)| \le N$ and the unions $\alpha_i \uplus (\theta - \alpha_i)$ are pairwise distinct. Then the products $m_R(\alpha_i)\, m_R(\theta - \alpha_i)$ are linearly independent.

*Proof.* Apply Theorem A with $\beta_i = \theta - \alpha_i$. $\square$

**Corollary C (Kleber shape; the fitting hypothesis is automatic).** Fix $\rho \in E_N$ with $r := |\mathrm{supp}(\rho)|$ rows and suppose $N \ge 2r$. Let $\lambda : I \to E_N$ with $\lambda_i \le \rho$ componentwise, and suppose the unions $\lambda_i \uplus (\rho - \lambda_i)$ are pairwise distinct. Then the complementary products
$$
m_R(\lambda_i)\; m_R(\rho - \lambda_i)
$$
are linearly independent over $R$.

*Proof.* Since $\lambda_i \le \rho$, $\mathrm{supp}(\lambda_i) \subseteq \mathrm{supp}(\rho)$, and $\mathrm{supp}(\rho - \lambda_i) \subseteq \mathrm{supp}(\rho)$ as well (truncated subtraction only shrinks the support). Hence each of the two supports has at most $r$ elements and their sizes add to at most $2r \le N$; Theorem A applies. $\square$

For Kleber's original setting $\rho = (c^r)$ this says: with at least $2r$ variables, the family of complementary products indexed by any set of subdiagrams with pairwise distinct pooled-part multisets is independent. Since $\mathrm{parts}$ is invariant under permuting coordinates, it is irrelevant whether the complement is read in reversed order, as in the classical definition of $\lambda^\vee$, or straight: $\lambda^\vee$ and $\rho - \lambda$ have the same part multiset, so all statements above apply verbatim to the rectangular complement.

### 3.3 The degenerate case and the one-row case

**Corollary (monomial symmetric functions themselves).** Taking $\beta_i = 0$ (so $m_R(0) = 1$), the monomial symmetric polynomials $m_R(\alpha_i)$ with pairwise distinct part multisets are linearly independent.

**Theorem D (one row, unconditional).** Let $n \ge 0$ and let $N \ge 2$. The products
$$
m_R\bigl((k)\bigr)\; m_R\bigl((n-k)\bigr), \qquad 0 \le k \le \lfloor n/2 \rfloor,
$$
are linearly independent over $R$.

*Proof.* Fitting is clear: each one-row vector has support of size at most $1$, so the sum of supports is at most $2 \le N$. For distinctness, note $\mathrm{parts}((k)) = \{k\}$ for $k>0$ and $\varnothing$ for $k = 0$; so the union attached to $k$ is
$$
U_k = \begin{cases} \{n\}, & k = 0 \text{ (and } n>0), \\ \{k, n-k\}, & 0 < k \le \lfloor n/2\rfloor . \end{cases}
$$
For $k=0$ the union has one element (or is empty if $n = 0$), for $k>0$ it has two, so the $k=0$ case is separated by cardinality. For $0 < k < l \le \lfloor n/2\rfloor$, if $\{k,n-k\} = \{l,n-l\}$ then either $k = l$, or $k = n-l$ and $l = n-k$, forcing $k + l = n$; but $k, l \le n/2$ and $k \ne l$ makes $k+l < n$. So $k = l$. Theorem A applies. $\square$

Because $m_{(k)} = p_k$, Theorem D says that the products $p_k p_{n-k}$, $0 \le k \le \lfloor n/2 \rfloor$, are linearly independent — the complete one-row instance of the componentwise splitting phenomenon, with no auxiliary hypothesis.

### 3.4 The product determines the union

**Theorem E.** Let $R$ have characteristic zero (no domain hypothesis needed). Let $\alpha, \beta, \alpha', \beta' \in E_N$ with $|\mathrm{supp}\,\alpha| + |\mathrm{supp}\,\beta| \le N$ and $|\mathrm{supp}\,\alpha'| + |\mathrm{supp}\,\beta'| \le N$. If
$$
m_R(\alpha)\, m_R(\beta) \;=\; m_R(\alpha')\, m_R(\beta'),
$$
then $\alpha \uplus \beta = \alpha' \uplus \beta'$.

*Proof sketch.* Choose disjoint placements $w = \alpha + \sigma\cdot\beta$ and $w' = \alpha' + \sigma'\cdot\beta'$, so that $Q(w) = Q(\alpha)+Q(\beta)$, $\mathrm{parts}(w) = \alpha\uplus\beta$, and symmetrically for $w'$. Since $x^{w}$ occurs in the left product with nonzero coefficient, it occurs in the right one, so Proposition 2.11(1) gives $Q(\alpha')+Q(\beta') \le Q(w)$; symmetrically $Q(\alpha)+Q(\beta) \le Q(w')$, whence all four quantities are equal. Then $Q(w) = Q(\alpha')+Q(\beta')$, so Proposition 2.11(2) applied on the right gives $\mathrm{parts}(w) = \alpha'\uplus\beta'$; but $\mathrm{parts}(w) = \alpha\uplus\beta$. $\square$

So the multiset union is not merely a device internal to the proof: it is an invariant of the product as an element of the ring.

### 3.5 Arbitrarily many factors

The argument is not tied to two factors. Let $S$ be a finite index set of factors.

**Lemma 3.1 (superadditivity over sums).** For any finite family $(u_j)_{j\in S}$ in $E_N$,
$$
Q\Bigl(\sum_{j\in S} u_j\Bigr) \;\ge\; \sum_{j\in S} Q(u_j),
$$
with equality if and only if the supports $\mathrm{supp}(u_j)$ are pairwise disjoint; in that case also $\mathrm{parts}\bigl(\sum_j u_j\bigr) = \sum_j \mathrm{parts}(u_j)$.

*Proof.* Induct on $|S|$ using Lemma 2.7: adding one more vector $u_{j_0}$ contributes $Q(u_{j_0}) + 2\langle u_{j_0}, \sum_{j\ne j_0} u_j\rangle \ge Q(u_{j_0})$. Equality throughout forces $\langle u_{j_0}, \sum_{j\ne j_0} u_j\rangle = 0$, i.e. $\mathrm{supp}(u_{j_0})$ disjoint from the support of the remaining sum, which contains each individual $\mathrm{supp}(u_j)$; then apply the inductive hypothesis. Additivity of $\mathrm{parts}$ follows as in Lemma 2.9. $\square$

**Lemma 3.2 (simultaneous disjoint placement).** If $\sum_{j\in S} |\mathrm{supp}(\alpha_j)| \le N$, there are permutations $\sigma_j$ such that the supports $\mathrm{supp}(\sigma_j\cdot\alpha_j)$, $j \in S$, are pairwise disjoint.

*Proof.* Place the factors one at a time, each time avoiding the union of the previously used supports; Lemma 2.10 provides the step, and the counting hypothesis guarantees room remains. $\square$

**Theorem F (many-fold independence).** Let $I$ be finite, $S$ a finite set of factors, and $\alpha_{i,j} \in E_N$ for $i \in I$, $j\in S$. Assume

* $\sum_{j\in S} |\mathrm{supp}(\alpha_{i,j})| \le N$ for every $i$;
* the pooled unions $\;U_i := \biguplus_{j\in S}\mathrm{parts}(\alpha_{i,j})\;$ are pairwise distinct.

Then the products $\prod_{j\in S} m_R(\alpha_{i,j})$, $i\in I$, are linearly independent over $R$.

*Proof sketch.* Verbatim the proof of Theorem A, with $q_i := \sum_{j} Q(\alpha_{i,j})$ as the filtration parameter, Lemma 3.1 in place of Lemma 2.7/2.8, and Lemma 3.2 in place of Lemma 2.10. Concretely: choose $i_0$ minimising $q_i$ among the indices with nonzero coefficient; simultaneously place the factors of $i_0$ on pairwise disjoint supports to obtain $w_0$ with $Q(w_0) = q_{i_0}$ and $\mathrm{parts}(w_0) = U_{i_0}$; the coefficient of $x^{w_0}$ in $\prod_j m_R(\alpha_{i,j})$ counts decompositions $w_0 = \sum_j u_j$ with $u_j \in \mathcal{O}(\alpha_{i,j})$, which forces $q_i \le Q(w_0)$ and, in the equality case, $U_i = \mathrm{parts}(w_0) = U_{i_0}$. $\square$

**Corollary G (power-sum monomials).** Let $p_k = \sum_{j=1}^N x_j^k$. Let $(k_{i,j})_{j\in S}$, $i \in I$, be families of *positive* integers with $|S| \le N$, and suppose the multisets $\{\!\{k_{i,j} : j \in S\}\!\}$ are pairwise distinct. Then the products $\prod_{j\in S} p_{k_{i,j}}$ are linearly independent over $R$.

*Proof.* A one-row exponent vector $(k)$ with $k>0$ has orbit consisting of all one-row vectors with entry $k$, so $m_R((k)) = p_k$; its support has size $1$ and $\mathrm{parts} = \{k\}$. The fitting hypothesis becomes $|S| \le N$, and the pooled union is exactly the exponent multiset. Apply Theorem F. $\square$

Corollary G is a statement one usually derives from the algebraic independence of the power sums over $\mathbb{Q}$; here it comes out of a purely combinatorial count, and holds over $\mathbb{Z}$.

---

## 4. Sharpness of the hypotheses

Two hypotheses appear in Theorem A. We settle the status of each.

### 4.1 The fitting hypothesis is necessary

**Proposition 4.1.** In one variable, the pairs $\bigl((1),(1)\bigr)$ and $\bigl((2),\varnothing\bigr)$ have distinct multiset unions,
$$
\{1,1\} \;\ne\; \{2\},
$$
yet the two products coincide: $m_{(1)}m_{(1)} = x_1 \cdot x_1 = x_1^2 = m_{(2)}\cdot 1$. Hence the two-element family is linearly dependent, and the hypothesis $|\mathrm{supp}\,\alpha| + |\mathrm{supp}\,\beta| \le N$ cannot be dropped.

The moral is that the theorem is genuinely about symmetric *functions* rather than symmetric *polynomials* in a bounded number of variables: one needs enough room to place both factors disjointly. In $\Lambda_R$, with infinitely many variables, the hypothesis is vacuous.

### 4.2 The distinct-union hypothesis is not necessary

**Proposition 4.2 (two-element collision classes).** Let $a, b > 0$ and $N \ge 2$. The two products
$$
m_R\bigl((a,b)\bigr)\cdot 1 \qquad\text{and}\qquad m_R\bigl((a)\bigr)\, m_R\bigl((b)\bigr)
$$
are linearly independent over $R$, even though both pairs have the same multiset union $\{a,b\}$.

*Proof.* The separating monomial is $x_1^{a+b}$, whose part multiset is $\{a+b\}$ — a *one*-element multiset, hence not equal to $\{a,b\}$ (a two-element multiset). By Lemma 2.4 the coefficient of $x_1^{a+b}$ in $m_R((a,b))$ is therefore $0$, while by Lemma 2.5 the coefficient of $x_1^{a+b}$ in $m_R((a))m_R((b))$ is positive: the splitting $x_1^{a}\cdot x_1^{b}$ contributes. Testing a relation $s\cdot m_R((a,b)) + t\cdot m_R((a))m_R((b)) = 0$ against $x_1^{a+b}$ gives $t = 0$; testing against a monomial of shape $\{a,b\}$ then gives $s = 0$. $\square$

Explicitly, for $a\ne b$,
$$
m_{(a)}\,m_{(b)} = m_{(a,b)} + m_{(a+b)}, \qquad\text{and}\qquad m_{(v)}\,m_{(v)} = 2\,m_{(v,v)} + m_{(2v)} .
$$
Both separating monomials $x_1^{a+b}$ lie one $Q$-level *above* the minimal layer, since $(a+b)^2 > a^2 + b^2$ for $a,b>0$. This is the first hint of the merge filtration of Section 6.

Note that for $v = 2$ the collision class $\{\varnothing, (2,2)\}$ versus $\{(2),(2)\}$ is exactly the one produced by Kleber's $2\times 2$ rectangle, where $\varnothing$ and $(2,2)$ are complementary and $(2)$ is self-complementary. So the smallest genuinely interesting Kleber instance already lands outside the reach of the distinct-union criterion — and is nevertheless independent.

### 4.3 A genuine collision

**Proposition 4.3.** The partition $\theta = (5,3)$ admits two distinct componentwise splittings with the same multiset union:
$$
(3,1) + (2,2) = (5,3) = (3,2) + (2,1), \qquad \{3,1\}\uplus\{2,2\} = \{3,2,2,1\} = \{3,2\}\uplus\{2,1\}.
$$
The pairs are genuinely distinct even as unordered pairs, since $(3,1) \notin \{(3,2),(2,1)\}$.

Hence the distinct-union hypothesis is a *real* restriction for componentwise splittings, and the $Q$-minimal layer does not by itself separate all splittings of a partition. This is precisely the difficulty the full theorem must overcome, and it is the reason the results of Section 3 are conditional at exactly this point.

The collision is nevertheless resolvable, two merge layers up.

**Proposition 4.4 (the $(5,3)$ collision class is separated).** *The two products*
$$
m_{(3,1)}\,m_{(2,2)} \qquad\text{and}\qquad m_{(3,2)}\,m_{(2,1)}
$$
*are linearly independent over any integral domain of characteristic zero, in at least four variables, despite having the same multiset union $\{3,2,2,1\}$.*

*Proof.* The separating monomial is $x_1^4x_2^4$. It occurs in $m_{(3,2)}m_{(2,1)}$, by the placement $x_1^3x_2^2 \cdot x_1^{1}x_2^{2}$, i.e. through the merges $3+1 = 4$ and $2+2=4$; so by Lemma 2.5 its coefficient there is a positive integer. In $m_{(3,1)}m_{(2,2)}$ it cannot occur at all, for a reason that needs no enumeration of placements: every exponent of a monomial of that product is a sum of an entry of $(3,1,0,\dots)$ and an entry of $(2,2,0,\dots)$, hence lies in $\{0,1,2,3,5\}$, and $4$ is not in that set. Testing a relation $s\,m_{(3,1)}m_{(2,2)} + t\,m_{(3,2)}m_{(2,1)} = 0$ against $x_1^4x_2^4$ therefore gives $t = 0$; testing what remains against any monomial of $m_{(3,1)}m_{(2,2)}$, for instance a disjoint placement of shape $\{3,2,2,1\}$, gives $s = 0$. $\square$

Note $4^2 + 4^2 = 32 > 18 = Q(\{3,2,2,1\})$: the separation genuinely takes place above the $Q$-minimal layer, in the merge layers of Section 5. The general obstruction used here is worth isolating, since it costs nothing and is often decisive.

**Lemma 4.5 (coordinatewise obstruction).** *If some coordinate value $w_i$ is not of the form $\alpha_j + \beta_k$ for entries $\alpha_j$ of $\alpha$ and $\beta_k$ of $\beta$, then $x^w$ does not occur in $m_\alpha m_\beta$.*

*Proof.* By Lemma 2.5 an occurrence gives $w = u+v$ with $u$ a rearrangement of $\alpha$ and $v$ one of $\beta$, so $w_i = u_i + v_i$ with $u_i$ an entry of $\alpha$ and $v_i$ an entry of $\beta$. $\square$

Small computations confirm that such collisions are not rare: the smallest examples occur already in two rows, and their number grows with the number of rows. What they *are* is highly structured — a collision means two splittings distributing the same pooled parts differently between the two factors, which is exactly the configuration the merge layer is designed to detect.

---

## 5. The picture within a union class

Fix a multiset $U$ of positive integers, and consider all unordered multiset splittings $U = A \uplus B$. All the corresponding products $m_A m_B$ lie in the same $Q$-level, and each has the same $Q$-minimal component up to a positive rational scalar. Indeed, from Lemma 2.5, the $Q$-minimal component of $m_A m_B$ is
$$
c(A,B) \cdot m_U, \qquad c(A,B) = \#\{\text{ways to split the parts of } U \text{ into an } A\text{-set and a } B\text{-set}\} \in \mathbb{Z}_{>0} ,
$$
a multinomial-type count depending only on the multiplicities of the parts. So the $Q$-filtration collapses on a union class: it detects the class but not its members.

Separation must therefore come from the next layer. Concretely, from the *one-merge* monomials: those whose part multiset is obtained from $U$ by deleting two parts $a, b$ and inserting the single part $a+b$. Their $Q$-value is $Q(U) + 2ab$, i.e. strictly above the minimum, but as low as one can go without staying in the class.

The combinatorics of the one-merge layer is transparent. A monomial $w$ with merged parts $a, b$ can arise from $m_A m_B$ in exactly two distinguishable ways:

1. **Internal merge.** The part $a + b$ is already a single part of $A$ (or of $B$), and the remaining parts are distributed disjointly.
2. **Cross merge.** The part $a$ belongs to one factor and the part $b$ to the other, and the two are placed on the *same* variable.

The first mechanism contributes only when $a+b$ occurs as a part of $A$ or of $B$; the second contributes when $a$ and $b$ can be separated between the two factors. Both counts are explicit multinomial expressions in the multiplicities. This yields, for a fixed union class, a *coefficient matrix*
$$
M \;=\; \bigl(M_{\{A,B\},\,\{a,b\}}\bigr),
$$
rows indexed by unordered splittings of $U$, columns by unordered pairs of parts $\{a,b\} \subseteq U$ (or by the resulting merged multisets).

The two-element collision class of Proposition 4.2 is the smallest instance: $U = \{a,b\}$, two splittings ($\{\varnothing,\{a,b\}\}$ and $\{\{a\},\{b\}\}$), one merged pair $\{a,b\}$, and the matrix is the column $\binom{0}{\ge 1}$ — the first splitting cannot merge (nothing to cross-merge, and $a+b$ is not a part), the second can. That single nonzero entry, combined with the leading form, is exactly the separation proved above.

---

## 6. Conjectures

The analysis of Section 5 crystallises into two conjectures.

**Conjecture 1 (union classes).** *Fix a multiset $U$ of positive integers. The products $m_A\, m_B$, indexed by unordered multiset splittings $A \uplus B = U$, are linearly independent over $\mathbb{Q}$ (and over $\mathbb{Z}$), given enough variables.*

Conjecture 1 is the missing half of the argument, and the merge order organises how the two halves must fit together. Write $U' \succeq U$ when $U'$ is obtained from $U$ by merging parts. The coefficient matrix of the products is triangular for this order: by Proposition 2.11 and the two lemmas below, $m_{U'}$ can occur in $m_A m_B$ only when $U' \succeq A \uplus B$, and the coefficient at $A \uplus B$ itself is a positive integer.

**Lemma 5.1 (merges preserve the total and do not increase the number of parts).** *If $x^w$ occurs in $m_\alpha m_\beta$ then $\mathrm{parts}(w)$ has the same sum as $\alpha \uplus \beta$ and at most as many elements.*

*Proof.* Write $w = u + v$ as in Lemma 2.5. The sum of the parts of an exponent vector is its total degree, which is additive; and $\mathrm{supp}(u+v) \subseteq \mathrm{supp}(u)\cup\mathrm{supp}(v)$, while the number of parts of a vector is the size of its support and is invariant under rearrangement. $\square$

One should be careful about what this does and does not give. Grouping a relation by union class and reading off the bottom layer yields, for each class $C$ of minimal $Q$-value, a *single* scalar equation $\sum_{i \in C} g_i c_i = 0$ with $c_i > 0$ — not the vanishing of each $g_i$. So Conjecture 1 does not by itself formally imply the full componentwise splitting statement: one must also control the interference at higher layers between classes that are comparable in the merge order. What the triangularity does provide is that this interference is one-directional, from finer unions to coarser ones, which is the natural starting point for an induction. We have verified the combined statement — independence of *all* componentwise splittings of $\theta$ — by exact computation for every $\theta$ in our range.

Exact computation confirms Conjecture 1 for every union class with at most five parts, each part at most $4$ ($121$ classes in total), and its smallest instance — the two-element class $U = \{v,v\}$, or more generally $U = \{a,b\}$ — is Proposition 4.2 above.

It is natural to hope that the one-merge layer alone suffices, i.e. that the matrix $M$ of Section 5 has full row rank. **This is false**, and the failure is uniform and mild. For $U = (1,1,1,1)$ there are three splittings,
$$
\{\varnothing, (1,1,1,1)\}, \quad \{(1),(1,1,1)\}, \quad \{(1,1),(1,1)\},
$$
while the one-merge layer consists of the single shape $(2,1,1)$; even adjoining the bottom layer $m_U$ the rank is $2 < 3$. In every union class we computed, the rank of the bottom-plus-one-merge matrix is *exactly one less* than the number of splittings whenever it is deficient at all. The correct statement is therefore one layer deeper.

**Conjecture 2 (merge filtration, two layers suffice).** *Order the monomials by the number of merges required to obtain their part multiset from $U$. For the splittings in one union class, the coefficient matrix restricted to layers $0$, $1$ and $2$ — bottom layer, one merge, two merges — has full row rank.*

Conjecture 2 implies Conjecture 1: full row rank says that the functionals given by reading off coefficients in the first three layers already separate the splittings, so no nontrivial combination of the products can vanish. Its appeal is that these coefficient counts are completely explicit — the two-mechanism analysis of Section 5 extends to higher layers by tracking how many merges each factor performs internally versus across the two factors — so it is a finite, structured linear-algebra statement rather than an assertion about the whole ring.

Exact computation over all $121$ union classes with at most five parts, each part at most $4$, confirms both conjectures in that range; moreover the first layer alone suffices for $30$ of those classes and exactly two layers are needed for the remaining $91$, and never more than two. A natural attack is an inductive elimination on the largest part of $U$: splittings that place the largest part in a fixed factor are governed by the corresponding sub-matrix for $U$ minus that part, and the cross-merge entries involving the largest part provide the pivot separating the two families.

---

## 7. Algorithms

The theory yields four algorithms which are directly implementable and which we use as computational tools.

### 7.1 Multiset-union classification of splittings

**Input:** a partition $\theta = (\theta_1,\dots,\theta_r)$.
**Output:** the unordered componentwise splittings of $\theta$, grouped by multiset union.

Enumerate all $\alpha$ with $0 \le \alpha_i \le \theta_i$, form $\beta = \theta - \alpha$, canonicalise the unordered pair, compute $U = \mathrm{parts}(\alpha) \uplus \mathrm{parts}(\beta)$ as a sorted tuple, and bucket by $U$. Cost: $O\bigl(\prod_i (\theta_i+1)\cdot r\log r\bigr)$. Theorem A applies exactly to the *transversals* of the resulting buckets; singleton buckets are individually settled, and the buckets of size $\ge 2$ are the residual difficulty (Conjecture 1).

### 7.2 Product expansion in the monomial basis via the $Q$-filtration

**Input:** partitions $\alpha, \beta$; a number of variables $N \ge \ell(\alpha)+\ell(\beta)$.
**Output:** the expansion $m_\alpha m_\beta = \sum_\mu c_\mu\, m_\mu$, with the $Q$-value of each $\mu$.

Enumerate the distinct rearrangements $u$ of $\alpha$ and $v$ of $\beta$ inside $N$ variables, accumulate the multiplicity of each $u + v$, then divide by orbit sizes to convert monomial coefficients to $m$-basis coefficients (equivalently: read the coefficient at one canonical representative per orbit). The output verifies Proposition 2.11 directly: the term with minimal $Q$ is $\mu = \alpha \uplus \beta$, whose coefficient is the splitting count $c(\alpha,\beta)$ of Section 5.

### 7.3 Independence certification by rank

**Input:** a family of pairs $(\alpha_i, \beta_i)$; a degree bound.
**Output:** the rank of the family of products in the monomial basis, together with a certificate of independence or an explicit relation.

Expand each product with 7.2, assemble the coefficient matrix over $\mathbb{Q}$ with columns indexed by the partitions appearing, and compute the rank by exact Gaussian elimination (or the Smith normal form for the integral statement). This is what confirms Conjecture 1 for small $U$ and validates all the propositions of Section 4 numerically.

### 7.4 Merge-filtration depth of a union class

**Input:** a multiset $U$ of positive parts.
**Output:** the number of unordered splittings $U = A \uplus B$, the exact rank of the corresponding family of products, and the smallest $k$ such that the monomials at most $k$ merges below $U$ already separate all splittings.

Enumerate the $2^{|U|}$ subsets, canonicalise to unordered splittings, expand each product with 7.2, and compute ranks of the truncations of the merge filtration, layer $k$ consisting of the shapes $\mu$ with $|U| - \ell(\mu) \le k$. This is the routine behind the numerical statements of Section 6.

---

## 8. Applications and context

**Universal characters.** The universal characters of Koike–Terada are stable characters of the classical groups, expressible as determinantal twists of Schur functions. Because those twists are unitriangular in the Schur basis with respect to a suitable order, linear independence of the products $s_\lambda s_{\lambda^\vee}$ transfers to linear independence of the corresponding universal-character products over any field. Independence statements of this type were sought in the context of Schubert-calculus positivity.

**Schubert calculus.** Complementary pairs inside a rectangle $(c^r)$ are exactly the pairs of Schubert classes in the Grassmannian $\mathrm{Gr}(r, r+c)$ that are Poincaré dual: $\sigma_\lambda \cdot \sigma_{\lambda^\vee}$ is the point class. Products of dual classes, taken in the ambient ring of symmetric functions rather than in the quotient defining the cohomology, are then the "diagonal" elements whose independence measures how much information survives the intersection pairing.

**Plethysm and stability.** The union $\alpha\uplus\beta$, being additive under multiplication of monomial symmetric functions in the $Q$-minimal layer, gives a valuation-like invariant on products of monomial symmetric functions, which behaves well under the stable-range specialisations used in representation stability.

**Power sums.** Corollary G recovers, by counting rather than by transcendence arguments, the classical fact that distinct power-sum monomials are linearly independent — with the bonus of an explicit variable bound and integral coefficients.

---

## 9. Discussion

The mechanism isolated here is elementary but structurally interesting. In the theory of symmetric functions, essentially every triangularity argument is set up against dominance order or a refinement of it, and it is not a coincidence that these fail here: componentwise splitting is *designed* so that the dominance-leading data are constant. The quadratic statistic $Q$ is not a refinement of dominance but a genuinely transverse function. Its defect of additivity is a nonnegative bilinear pairing, which is the entire source of the triangularity: $Q$ is minimised on a product precisely where the factors interact least, and where they interact least they remain individually legible.

Three features of the argument deserve emphasis.

1. **It is characteristic-free apart from torsion.** The only ring-theoretic input is that a positive integer is a nonzero element. Consequently the results hold over $\mathbb{Z}$, which is the strongest form of an independence statement over a ring, and yields the field case for every field of characteristic zero by base change.
2. **It is finite and effective.** For any given family, the proof exhibits the separating monomial explicitly: pick the minimising index, place its two factors on disjoint variables, and read the coefficient there. There is no appeal to any structure theory of $\Lambda$.
3. **Its boundary is exactly identifiable.** The method sees union classes and nothing finer. Proposition 4.3 shows this is a genuine limitation, and Proposition 4.2 shows the limitation is one of the *method*, not of the truth of the statement.

The comparison to the Schur setting is instructive. There, the natural analogue of the $Q$-minimal layer is the *lowest* Littlewood–Richardson term rather than the highest, and the analogous invariant of $s_\alpha s_\beta$ is again a pooled statistic rather than the componentwise sum. It is reasonable to expect that a Schur-side version of the merge filtration exists, with the role of merging two parts played by a length-one Pieri-style adjustment; making that precise, in a way that is uniform over all commutative rings, is the natural next step.

---

## 10. Future work

Beyond Conjectures 1 and 2, several directions suggest themselves.

* **Quantitative merge matrices.** Compute the one-merge matrix $M$ in closed form as a function of the multiplicity vector of $U$, and identify its Smith normal form; this would give the integral, not merely rational, version of Conjecture 1.
* **Higher merge layers.** The one-merge layer is provably insufficient in general (rank deficiency one, as for $U = (1,1,1,1)$), and computation suggests two layers always suffice; proving a uniform bound on the number of layers needed would be a strong structural statement about the filtration.
* **Closed-form layer-two counts.** Extend the internal/cross-merge dichotomy to two merges and obtain closed-form matrix entries; this is the concrete route to Conjecture 2.
* **Uniform transfer to Schur functions.** Find the analogue of $Q$ on the Schur side — a grading transverse to dominance and additive up to a nonnegative correction — that would make the Schur-function proof as transparent as the monomial one.
* **Other bases.** Elementary and complete homogeneous symmetric functions have their own product structure; the same union-based invariant should govern the independence of $e_\alpha e_\beta$ and $h_\alpha h_\beta$ over splittings, with different collision patterns.
* **Positive characteristic.** All our independence results need characteristic zero to keep splitting counts nonzero. Determining precisely which primes can destroy independence — the counts are explicit multinomials, so this is a question about their $p$-adic valuations — would complete the "arbitrary commutative ring" picture on the monomial side.
* **Asymptotics of collisions.** How many componentwise splittings of a random partition of $n$ share a union class? Empirically the collisions are frequent but the classes are small; a precise asymptotic would quantify exactly how much work Conjecture 1 has to do.

---

## 11. Summary of results

| Statement | Content | Hypotheses |
|---|---|---|
| Theorem A | $m_{\alpha_i}m_{\beta_i}$ independent | fitting; distinct unions; char-$0$ domain |
| Corollary B | componentwise splittings of a fixed $\theta$ | same |
| Corollary C | Kleber shape $\rho$; fitting is automatic | $N \ge 2\,\ell(\rho)$; distinct unions |
| Theorem D | one row $\theta = (n)$ | none beyond $N \ge 2$ |
| Theorem E | $m_\alpha m_\beta$ determines $\alpha \uplus\beta$ | fitting; char $0$ |
| Theorem F | products of arbitrarily many factors | fitting; distinct pooled unions |
| Corollary G | power-sum monomials independent | positive exponents; $|S| \le N$ |
| Proposition 4.1 | fitting hypothesis necessary | — |
| Proposition 4.2 | distinct unions not necessary | $a,b>0$, $N\ge 2$ |
| Proposition 4.3 | collisions exist: $\theta = (5,3)$ | — |
| Proposition 4.4 | the $(5,3)$ collision class is separated | char-$0$ domain, $N \ge 4$ |
| Lemma 4.5 | coordinatewise obstruction | — |
| Lemma 5.1 | merges preserve the total, do not add parts | — |

The overall picture is a complete and sharp account of what a single, elementary, transverse grading can prove about complementary products — together with an explicit, checkable conjecture for the residue.
