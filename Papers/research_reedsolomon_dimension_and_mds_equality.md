# Reed–Solomon Codes: Dimension, the Singleton Bound, and MDS Equality

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We give a complete and self-contained development of the parameters of Reed–Solomon codes, organized around a single structural principle: the exact optimality of these codes is a *two-sided squeeze* between a universal upper bound valid for all linear codes and a construction-specific lower bound coming from root counting.

We package the space $P_{<k}$ of polynomials of degree less than $k$ over a field $F$ as a $k$-dimensional vector space, realize the Reed–Solomon encoder as the $F$-linear evaluation map $E : P_{<k} \to F^n$ at $n$ distinct points, and prove: (i) $E$ is injective when the evaluation points are distinct and $k \le n$, hence the code has dimension exactly $k$; (ii) every nonzero codeword has Hamming weight at least $n-k+1$; (iii) a general **Singleton bound** — for any linear code $C \subseteq F^n$ all of whose nonzero codewords have weight $\ge d$, with $1 \le d \le n$, one has $\dim C + d \le n+1$; and hence (iv) the minimum distance of a Reed–Solomon code is *exactly* $n-k+1$, so $\dim C + d = n+1$ and the code is maximum distance separable (MDS). An explicit minimum-weight codeword is exhibited as the evaluation vector of $\prod_{i \in T}(X - \alpha_i)$ for any $(k-1)$-subset $T$ of evaluation points.

We then develop the consequences. We prove the two-way **information-set characterization**: a $k$-dimensional code is MDS if and only if restriction to every $k$-subset of coordinates is a bijection. From it we derive interpolation, correction of any $n-k$ erasures, and unique decoding within radius $\lfloor (n-k)/2 \rfloor$. Finally we prove **MDS duality**: the dual of a Reed–Solomon code has dimension $n-k$ and minimum distance exactly $k+1$, hence is itself MDS. The $[5,3,3]$ code over $\mathbb{Z}/5\mathbb{Z}$, whose dual is $[5,2,4]$, is worked out as a concrete instance.

A methodological point emerges from the development: the Singleton bound as it is usually stated, with only the hypothesis $1 \le d$, is *false* as a formal statement, because the weight hypothesis is vacuous for the zero code. The correct statement carries $d \le n$, which is automatic once a nonzero codeword exists.

**Keywords:** Reed–Solomon codes; Singleton bound; MDS codes; minimum distance; Hamming weight; information sets; dual code; Lagrange interpolation; erasure correction.

---

## 1. Introduction

### 1.1 The design problem

A communication or storage channel corrupts symbols. To transmit $k$ symbols reliably one sends $n > k$, choosing the map from messages to transmitted strings so that the message survives corruption. The fundamental tension is between **rate** $k/n$, which one wants large, and **error tolerance**, which one also wants large. The quantity that measures error tolerance is the minimum Hamming distance between distinct transmitted strings.

This paper answers the design question in the sharpest possible form for one family of codes: it determines the minimum distance of Reed–Solomon codes *exactly*, and shows that no code of the same length and dimension over any alphabet can do better.

### 1.2 The shape of the argument

The exactness comes from two bounds proved by completely different means, which happen to coincide.

1. **A universal upper bound (Singleton).** For every linear code, $\dim C + d \le n+1$. The proof deletes $d-1$ coordinates and observes that the resulting puncturing map is injective; injective linear maps do not increase dimension. No property of the alphabet beyond "field" is used, and no polynomials appear.

2. **A construction-specific lower bound (root counting).** For the Reed–Solomon construction, $d \ge n-k+1$. The proof uses only that a nonzero polynomial of degree $m$ over a field has at most $m$ roots. No coding theory appears.

The two bounds meet. That they meet is not a coincidence but a reflection of the fact that both counting problems are governed by the same integer $k$: the number of coordinates one may delete before losing information, and the number of roots a message polynomial may have, are the same number.

### 1.3 Layering of the results

The development is elementary but structurally layered, and the layering is worth stating because it explains the order of the sections:

$$
\text{injectivity of } E \;\Longrightarrow\; \dim = k
\;\;\text{and}\;\;
\text{root counting} \;\Longrightarrow\; d \ge n-k+1
$$
$$
\Longrightarrow\; \text{MDS equality} \;\Longrightarrow\; \text{information sets} \;\Longrightarrow\; \text{duality.}
$$

Each arrow is a genuine dependency: the duality theorem consumes the information-set theorem, which consumes the weight bound and the dimension computation, which consume injectivity of the encoder.

### 1.4 Contributions

* A general Singleton bound for arbitrary linear subspaces of $F^n$, stated with the hypotheses that make it true (§4).
* The exact minimum distance $n-k+1$ of Reed–Solomon codes, together with an explicit extremal codeword (§5–6).
* The information-set characterization of MDS codes, **in both directions** (§7).
* Erasure correction and the unique-decoding radius as corollaries (§8).
* MDS duality: the dual Reed–Solomon code is $[n, n-k, k+1]$ (§9).
* A worked $[5,3,3]$ instance over $\mathbb{Z}/5\mathbb{Z}$ (§10).

---

## 2. Definitions and conventions

Throughout, $F$ is a field, $n$ and $k$ are natural numbers, and $F^n$ denotes the space of functions $\{0,1,\dots,n-1\} \to F$, an $n$-dimensional $F$-vector space under coordinatewise operations.

**Definition 2.1 (Hamming weight and distance).** For $x \in F^n$, the *Hamming weight* is
$$\mathrm{wt}(x) = \#\{\, i : x_i \neq 0 \,\},$$
and for $x, y \in F^n$ the *Hamming distance* is $d(x,y) = \#\{i : x_i \ne y_i\} = \mathrm{wt}(x-y)$. Hamming distance is a metric; in particular $d(x,z) \le d(x,y) + d(y,z)$.

**Definition 2.2 (Linear code).** A *linear code of length $n$ over $F$* is an $F$-subspace $C \subseteq F^n$. Its elements are *codewords*, and its *dimension* is $\dim_F C$. Because $C$ is closed under subtraction, the minimum distance between distinct codewords equals the minimum weight of a nonzero codeword.

**Definition 2.3 (Minimum distance).** For a linear code $C$,
$$d_{\min}(C) = \min \{\, \mathrm{wt}(c) : c \in C,\ c \neq 0 \,\},$$
defined whenever $C \neq \{0\}$; equivalently, the least element of the set of weights of nonzero codewords, which is nonempty precisely when $C \ne \{0\}$. A code with $\dim C = k$ and $d_{\min}(C) = d$ is called an $[n,k,d]$ code.

**Definition 2.4 (Message space).** For $k \in \mathbb{N}$, let
$$P_{<k} = \{\, p \in F[X] : \deg p < k \,\} \subseteq F[X],$$
where by convention $\deg 0 = -\infty < 0$, so $0 \in P_{<k}$ for all $k$ and $P_{<0} = \{0\}$. This is an $F$-subspace of $F[X]$.

**Definition 2.5 (Reed–Solomon encoder and code).** Let $\alpha = (\alpha_0,\dots,\alpha_{n-1}) \in F^n$. The *encoder* is
$$E_{k,\alpha} : P_{<k} \longrightarrow F^n, \qquad E_{k,\alpha}(p) = \bigl(p(\alpha_0), \dots, p(\alpha_{n-1})\bigr),$$
and the *Reed–Solomon code* is its image,
$$\mathrm{RS}_k(\alpha) = E_{k,\alpha}(P_{<k}) \subseteq F^n .$$

**Definition 2.6 (Restriction / puncturing).** For a linear code $C \subseteq F^n$ and a subset $S$ of coordinates, the *restriction map* is the linear map
$$\rho_S : C \longrightarrow F^S, \qquad \rho_S(c) = (c_i)_{i \in S}.$$

**Definition 2.7 (Dual code).** The *dual* of $C \subseteq F^n$ with respect to the standard bilinear form $\langle x, y\rangle = \sum_i x_i y_i$ is
$$C^\perp = \Bigl\{\, y \in F^n : \textstyle\sum_{i} y_i c_i = 0 \text{ for all } c \in C \,\Bigr\},$$
again a subspace of $F^n$.

---

## 3. The message space and the encoder

**Lemma 3.1 (Linearity).** $E_{k,\alpha}$ is $F$-linear.

*Proof.* Evaluation at a point is a ring homomorphism $F[X] \to F$ and in particular $F$-linear: $(p+q)(\alpha_i) = p(\alpha_i) + q(\alpha_i)$ and $(cp)(\alpha_i) = c\,p(\alpha_i)$. These identities hold coordinatewise, hence for the tuple. $\square$

Consequently $\mathrm{RS}_k(\alpha)$, being the image of a linear map, is a linear code.

**Theorem 3.2 (Dimension of the message space).** $\dim_F P_{<k} = k$.

*Proof.* The monomials $1, X, \dots, X^{k-1}$ lie in $P_{<k}$, are linearly independent (a nontrivial vanishing combination would be a nonzero polynomial equal to $0$), and span it: any $p$ with $\deg p < k$ is by definition an $F$-combination of them. So they form a basis of cardinality $k$. $\square$

**Lemma 3.3 (Degree bound).** If $p \in P_{<k}$ and $p \ne 0$, then $\deg p \le k-1$.

*Proof.* Immediate from $\deg p < k$ and integrality of the degree of a nonzero polynomial. $\square$

**Theorem 3.4 (Injectivity of the encoder).** If $\alpha_0, \dots, \alpha_{n-1}$ are pairwise distinct and $k \le n$, then $E_{k,\alpha}$ is injective.

*Proof.* By linearity it suffices to show the kernel is trivial. Let $p \in P_{<k}$ with $p(\alpha_i) = 0$ for all $i$, and suppose $p \ne 0$. Then $\deg p \le k - 1 \le n-1$, while $p$ has at least $n$ distinct roots $\alpha_0,\dots,\alpha_{n-1}$. A nonzero polynomial over a field (an integral domain) has at most $\deg p$ roots. Since $n > \deg p$, this is a contradiction. Hence $p = 0$. $\square$

**Theorem 3.5 (Dimension of the code).** Under the hypotheses of Theorem 3.4,
$$\dim_F \mathrm{RS}_k(\alpha) = k .$$

*Proof.* An injective linear map induces an isomorphism onto its image, so $\mathrm{RS}_k(\alpha) \cong P_{<k}$ as $F$-vector spaces, and dimensions agree; apply Theorem 3.2. $\square$

The code therefore has $|F|^k$ codewords and rate $k/n$: no information is lost, and no redundancy is wasted on collapsing messages.

---

## 4. Puncturing and the Singleton bound

The two lemmas of this section are pure linear algebra and apply to every linear code.

**Lemma 4.1 (Weight of a vector vanishing on a set).** Let $c \in F^n$ and let $S$ be a set of coordinates with $c_i = 0$ for all $i \in S$. Then $\mathrm{wt}(c) \le n - |S|$.

*Proof.* The support $\{i : c_i \ne 0\}$ is contained in the complement of $S$, whose cardinality is $n - |S|$. $\square$

**Lemma 4.1′ (Exact weight).** If the zero set of $c$ is *exactly* $S$, i.e. $c_i = 0 \iff i \in S$, then $\mathrm{wt}(c) = n - |S|$.

*Proof.* The support is exactly the complement of $S$. $\square$

**Lemma 4.2 (Injectivity of restriction).** Let $C \subseteq F^n$ be a linear code in which every nonzero codeword has weight at least $d$, and let $S$ be a set of coordinates with $n - |S| < d$. Then $\rho_S : C \to F^S$ is injective.

*Proof.* By linearity, suppose $\rho_S(c) = 0$, i.e. $c$ vanishes on $S$. By Lemma 4.1, $\mathrm{wt}(c) \le n - |S| < d$. If $c \ne 0$ this contradicts the weight hypothesis. Hence $c = 0$. $\square$

**Theorem 4.3 (Singleton bound).** Let $C \subseteq F^n$ be a linear code and $d$ an integer with $1 \le d \le n$, such that every nonzero codeword of $C$ has weight at least $d$. Then
$$\dim_F C + d \le n + 1 .$$

*Proof.* Since $d \le n$ we have $n + 1 - d \le n$, so we may choose a set $S$ of exactly $n+1-d$ coordinates. Then $n - |S| = d - 1 < d$, so by Lemma 4.2 the restriction $\rho_S : C \to F^S$ is injective. An injective linear map satisfies $\dim C \le \dim F^S = |S| = n+1-d$, which is the claim. $\square$

**Remark 4.4 (Why $d \le n$ is necessary).** Without the hypothesis $d \le n$ the statement is false. Take $C = \{0\}$. It has no nonzero codewords, so "every nonzero codeword has weight $\ge d$" holds *vacuously* for every $d$, in particular for $d = n+2$; but $\dim C + d = n + 2 > n+1$. The hypothesis $d \le n$ is not a technicality to be dismissed: it is exactly the assertion that the weight hypothesis is not vacuous, and it is automatically satisfied in every application, since the existence of a single nonzero codeword $c$ gives $d \le \mathrm{wt}(c) \le n$.

**Definition 4.5 (MDS).** An $[n,k,d]$ code is *maximum distance separable* (MDS) if $d = n-k+1$, i.e. if the Singleton bound holds with equality: $\dim C + d = n+1$.

---

## 5. The root-counting lower bound

**Theorem 5.1 (Weight lower bound).** Let $\alpha_0,\dots,\alpha_{n-1}$ be pairwise distinct, $1 \le k \le n$. Then every nonzero $c \in \mathrm{RS}_k(\alpha)$ satisfies
$$\mathrm{wt}(c) \ \ge\ n - k + 1 .$$

*Proof.* Write $c = E_{k,\alpha}(p)$. If $p = 0$ then $c = 0$, excluded; so $p \ne 0$ and $\deg p \le k-1$ by Lemma 3.3. Let
$$Z = \{\, i : p(\alpha_i) = 0 \,\}$$
be the set of zero coordinates of $c$. The map $i \mapsto \alpha_i$ is injective, so it carries $Z$ bijectively onto a set of $|Z|$ distinct roots of $p$. Since $p \ne 0$ has at most $\deg p \le k-1$ roots, $|Z| \le k-1$. By Lemma 4.1′, $\mathrm{wt}(c) = n - |Z| \ge n - (k-1) = n-k+1$. $\square$

**Remark 5.2.** Note where each hypothesis enters. Distinctness of the $\alpha_i$ converts "coordinates where $c$ vanishes" into "distinct roots of $p$" — without it the count collapses. The hypothesis $k \ge 1$ ensures the message space is nonzero so the statement is not vacuous, and $k \le n$ keeps $n-k+1 \ge 1$.

---

## 6. The MDS theorem

**Lemma 6.1 (A nonzero codeword exists).** If $1 \le k$ and $n \ge 1$, then the all-ones vector $(1,1,\dots,1)$ lies in $\mathrm{RS}_k(\alpha)$ and is nonzero. (It is the encoding of the constant polynomial $1$, which has degree $0 < k$.) In particular $\mathrm{RS}_k(\alpha) \ne \{0\}$ and $d_{\min}$ is defined and attained.

**Theorem 6.2 (Reed–Solomon codes are MDS).** Let $\alpha_0,\dots,\alpha_{n-1}$ be pairwise distinct and $1 \le k \le n$. Then
$$d_{\min}\bigl(\mathrm{RS}_k(\alpha)\bigr) = n - k + 1,$$
and therefore
$$\dim_F \mathrm{RS}_k(\alpha) + d_{\min}\bigl(\mathrm{RS}_k(\alpha)\bigr) = n + 1 .$$

*Proof.* Write $C = \mathrm{RS}_k(\alpha)$ and $d = d_{\min}(C)$, which exists by Lemma 6.1.

*Lower bound.* By Theorem 5.1 every nonzero codeword has weight $\ge n-k+1$; the minimum over a nonempty set of such weights is therefore $\ge n-k+1$.

*Upper bound.* By definition, every nonzero codeword has weight $\ge d$. Moreover $1 \le d$ (a nonzero vector has positive weight) and $d \le n$ (weights are at most $n$), so Theorem 4.3 applies and gives $\dim C + d \le n+1$. By Theorem 3.5, $\dim C = k$, whence $d \le n - k + 1$.

Combining, $d = n-k+1$; substituting into $\dim C = k$ gives the displayed equality. $\square$

### 6.1 An explicit minimum-weight codeword

The bound is not only attained abstractly; the extremal codewords can be written down.

**Theorem 6.3 (Explicit extremal codeword).** Under the hypotheses of Theorem 6.2, let $T$ be any set of exactly $k-1$ coordinates and put
$$p_T(X) = \prod_{i \in T} (X - \alpha_i) \in F[X].$$
Then $p_T \in P_{<k}$ and $c = E_{k,\alpha}(p_T)$ satisfies $c \ne 0$ and $\mathrm{wt}(c) = n-k+1$.

*Proof.* Each factor $X - \alpha_i$ is monic of degree $1$ and nonzero, so the product is monic of degree exactly $|T| = k-1 < k$; hence $p_T \in P_{<k}$ and $p_T \ne 0$. Its roots are exactly the $\alpha_i$ for $i \in T$ (a product in an integral domain vanishes iff a factor does). Since $j \mapsto \alpha_j$ is injective, $p_T(\alpha_j) = 0$ if and only if $j \in T$. So the zero set of $c$ is exactly $T$, and Lemma 4.1′ gives $\mathrm{wt}(c) = n - (k-1) = n-k+1$. In particular $c \ne 0$ because $n - k + 1 \ge 1$. $\square$

Thus the minimum distance is achieved by the most transparent polynomials imaginable, and there is at least one extremal codeword for each of the $\binom{n}{k-1}$ choices of $T$.

---

## 7. Information sets: a characterization of MDS

**Theorem 7.1 (MDS $\Rightarrow$ every $k$-set is an information set).** Let $C \subseteq F^n$ be a linear code with $\dim C = k$ such that every nonzero codeword has weight $\ge n-k+1$. Then for every set $S$ of exactly $k$ coordinates, $\rho_S : C \to F^S$ is a **bijection**.

*Proof.* With $d = n-k+1$ we have $n - |S| = n-k = d-1 < d$, so Lemma 4.2 gives injectivity. Both $C$ and $F^S$ have dimension $k$, and an injective linear endomorphism-like map between finite-dimensional spaces of equal dimension is surjective (rank–nullity). Hence $\rho_S$ is bijective. $\square$

**Theorem 7.2 (Converse: information sets $\Rightarrow$ MDS).** Let $C \subseteq F^n$ be a linear code with $k \le n$ such that $\rho_S$ is injective for every set $S$ of exactly $k$ coordinates. Then every nonzero codeword of $C$ has weight $\ge n-k+1$.

*Proof.* Suppose $c \in C$, $c \ne 0$, and $\mathrm{wt}(c) < n-k+1$, i.e. $\mathrm{wt}(c) \le n-k$. Let $Z$ be the zero set of $c$; by Lemma 4.1′, $|Z| = n - \mathrm{wt}(c) \ge k$. Choose a subset $S \subseteq Z$ with $|S| = k$. Then $c$ vanishes on $S$, so $\rho_S(c) = 0 = \rho_S(0)$ with $c \ne 0$, contradicting injectivity. $\square$

**Corollary 7.3.** For a $k$-dimensional linear code, being MDS is *equivalent* to every $k$-subset of coordinates being an information set. In particular (combining with Theorems 3.5 and 5.1), every set of $k$ coordinates is an information set for $\mathrm{RS}_k(\alpha)$.

**Corollary 7.4 (Interpolation, coding form).** Let $\alpha$ be injective, $1 \le k \le n$, $S$ a set of $k$ coordinates, and $v \in F^S$ arbitrary. Then there is a **unique** codeword $c \in \mathrm{RS}_k(\alpha)$ with $c_i = v_i$ for all $i \in S$.

*Proof.* Existence is surjectivity and uniqueness is injectivity of $\rho_S$, Theorem 7.1. $\square$

Corollary 7.4 is exactly Lagrange interpolation, transported through the encoder: given prescribed values at $k$ distinct points, there is a unique polynomial of degree $< k$ realizing them. The classical interpolation theorem and the extremality of Reed–Solomon codes are two readings of one fact.

---

## 8. Erasure and error correction

**Theorem 8.1 (Erasure correction).** Let $\alpha$ be injective, $1 \le k \le n$, and let $S$ be any set of at least $k$ coordinates. If $c_1, c_2 \in \mathrm{RS}_k(\alpha)$ agree on $S$, then $c_1 = c_2$. Hence any $n-k$ erasures can be corrected.

*Proof.* Suppose $c_1 \ne c_2$. Then $c_1 - c_2$ is a nonzero codeword vanishing on $S$, so by Lemma 4.1 its weight is at most $n - |S| \le n-k$, while Theorem 5.1 forces its weight to be at least $n-k+1$. Contradiction. $\square$

**Theorem 8.2 (Unique decoding).** Let $\alpha$ be injective, $1 \le k \le n$, and let $t$ satisfy $2t < n-k+1$. Then for any received word $y \in F^n$ there is at most one codeword $c \in \mathrm{RS}_k(\alpha)$ with $d(y,c) \le t$.

*Proof.* Suppose $c_1, c_2$ are codewords with $d(y,c_i) \le t$. By the triangle inequality and symmetry of the metric,
$$\mathrm{wt}(c_1 - c_2) = d(c_1,c_2) \le d(c_1,y) + d(y,c_2) \le 2t < n-k+1 .$$
If $c_1 \ne c_2$, then $c_1 - c_2$ is a nonzero codeword of weight $< n-k+1$, contradicting Theorem 5.1. $\square$

**Corollary 8.3 (Decoding radius).** Any $t \le \lfloor (n-k)/2 \rfloor$ errors are uniquely correctable, since then $2t \le n-k < n-k+1$.

The asymmetry between Theorems 8.1 and 8.2 is the fundamental economics of coding: $n-k$ erasures (known locations, unknown values) cost the same as $\lfloor (n-k)/2 \rfloor$ errors (unknown locations *and* values). Locating an error costs as much redundancy as repairing it.

**Remark 8.4 (Beyond unique decoding).** Theorem 8.2 is a statement about the *combinatorics* of the code: beyond radius $(n-k)/2$ two codewords can be equidistant from a received word and unique decoding becomes impossible in principle. It does not preclude *list decoding*, in which the decoder returns a short list of candidates; nor does it address the *algorithmic* question of finding the nearby codeword, for which classical syndrome-based algorithms run in $O(n^2)$ or better.

---

## 9. Duality

**Theorem 9.1 (Dimension of the dual).** For any linear code $C \subseteq F^n$,
$$\dim_F C + \dim_F C^\perp = n .$$

*Proof sketch.* The standard bilinear form $\langle x,y\rangle = \sum_i x_i y_i$ is nondegenerate, so $y \mapsto \langle y, -\rangle$ is a linear isomorphism $F^n \to (F^n)^*$. Under this isomorphism, $C^\perp$ corresponds exactly to the annihilator $C^\circ = \{\varphi \in (F^n)^* : \varphi|_C = 0\}$. The classical identity $\dim C + \dim C^\circ = \dim F^n = n$ for subspaces of a finite-dimensional space then gives the claim. $\square$

**Corollary 9.2.** For $\alpha$ injective and $k \le n$, $\dim_F \mathrm{RS}_k(\alpha)^\perp = n-k$.

**Theorem 9.3 (Dual weight bound: the dual of an MDS code is MDS).** Let $C \subseteq F^n$ have $\dim C = k \le n$ and suppose every nonzero codeword of $C$ has weight $\ge n-k+1$. Then every nonzero $y \in C^\perp$ has weight $\ge k+1$.

*Proof.* Suppose $y \in C^\perp$, $y \ne 0$, and $\mathrm{wt}(y) \le k$. Let $S_y = \{ i : y_i \ne 0\}$, so $|S_y| = \mathrm{wt}(y) \le k$; choose a set $T$ with $S_y \subseteq T$ and $|T| = k$ (possible since $k \le n$). Pick $j$ with $y_j \ne 0$; then $j \in S_y \subseteq T$.

By Theorem 7.1, $\rho_T : C \to F^T$ is surjective. Choose $c \in C$ with
$$c_i = \begin{cases} 1, & i = j,\\ 0, & i \in T \setminus \{j\}. \end{cases}$$
(The values of $c$ outside $T$ are unconstrained and irrelevant.) Since $y$ vanishes off $S_y \subseteq T$,
$$0 = \sum_{i=0}^{n-1} y_i c_i = \sum_{i \in T} y_i c_i = y_j \cdot 1 = y_j,$$
contradicting $y_j \ne 0$. $\square$

**Theorem 9.4 (The dual Reed–Solomon code).** Let $\alpha$ be injective and $1 \le k < n$. Then $\mathrm{RS}_k(\alpha)^\perp$ is an
$$[\,n,\ n-k,\ k+1\,]$$
code, and it is MDS: with $k' = n-k$ its distance equals $n-k'+1 = k+1$.

*Proof.* The dimension is Corollary 9.2, and it is positive since $k < n$, so the dual is nonzero and its minimum distance is defined. Theorem 9.3 (applicable by Theorems 3.5 and 5.1) gives $d_{\min}(C^\perp) \ge k+1$. For the reverse, apply the Singleton bound (Theorem 4.3) to $C^\perp$: with $d' = d_{\min}(C^\perp)$, which satisfies $1 \le d' \le n$, we get $(n-k) + d' \le n+1$, i.e. $d' \le k+1$. Hence $d' = k+1$. $\square$

Duality is where the layering of the argument is most visible: Theorem 9.4 rests on Theorem 9.3, which rests on Theorem 7.1, which rests on Theorem 5.1 and Theorem 3.5, both of which rest on the root count for polynomials.

---

## 10. A worked example: the $[5,3,3]$ code over $\mathbb{Z}/5\mathbb{Z}$

Let $F = \mathbb{Z}/5\mathbb{Z}$, $n = 5$, evaluation points $\alpha = (0,1,2,3,4)$ (distinct, as $5$ is prime and these are the five residues), and $k = 3$. Messages are polynomials $a_0 + a_1X + a_2X^2$; there are $125$ of them.

The theorems predict, and one verifies directly:

| quantity | value | source |
|---|---|---|
| $\dim C$ | $3$ | Theorem 3.5 |
| $d_{\min}(C)$ | $3 = 5-3+1$ | Theorem 6.2 |
| $\dim C^\perp$ | $2$ | Corollary 9.2 |
| $d_{\min}(C^\perp)$ | $4 = 5-2+1$ | Theorem 9.4 |

Concretely, $p(X) = X^2+1$ encodes to
$$\bigl(p(0),p(1),p(2),p(3),p(4)\bigr) = (1,\,2,\,0,\,0,\,2) \pmod 5,$$
of weight $3$ — minimal. Consistently with Theorem 6.3, $X^2+1 = (X-2)(X-3)$ over $\mathbb{Z}/5\mathbb{Z}$: it is exactly the extremal polynomial $p_T$ for $T = \{2,3\}$, a set of $k-1 = 2$ evaluation points.

Since $d = 3$, this code corrects $\lfloor (5-3)/2 \rfloor = 1$ arbitrary symbol error, or any $2$ erasures. And by Corollary 7.3, *any* three of the five coordinates determine the codeword — for instance from the values at positions $0, 3, 4$ one recovers the quadratic uniquely.

---

## 11. Algorithms

The theory is constructive throughout; each theorem corresponds to a procedure.

### 11.1 Encoding

Given coefficients $(a_0,\dots,a_{k-1})$ and points $\alpha$, compute $c_i = \sum_{j} a_j \alpha_i^j$. Horner's rule evaluates one point in $k-1$ multiplications and additions, so the encoder costs $O(nk)$ field operations. (For evaluation points forming a multiplicative coset, an FFT-style multipoint evaluation reduces this to $O(n\log n)$.)

### 11.2 Erasure decoding by interpolation

By Corollary 7.4, given the values at any $k$ surviving coordinates $S = \{i_1,\dots,i_k\}$, the unique message is the Lagrange interpolant
$$p(X) = \sum_{m=1}^{k} c_{i_m} \prod_{\substack{l = 1 \\ l \ne m}}^{k} \frac{X - \alpha_{i_l}}{\alpha_{i_m} - \alpha_{i_l}} .$$
Building all $k$ basis polynomials costs $O(k^2)$ field operations; re-evaluating $p$ at the erased positions restores them.

### 11.3 Error decoding by exhaustive information sets

A conceptually transparent (if inefficient) decoder for up to $t = \lfloor (n-k)/2 \rfloor$ errors: for each $k$-subset $S$ of coordinates, interpolate the unique codeword agreeing with the received word $y$ on $S$, and test whether it lies within distance $t$ of $y$. Theorem 8.2 guarantees that at most one codeword passes the test, and if at most $t$ errors occurred then some $k$-subset avoids all of them, so the true codeword is found. The cost is $O\!\left(\binom{n}{k} k^2\right)$ — exponential in general, but a complete and correct decoder, and a direct algorithmic embodiment of the information-set theorem. Practical decoders (syndrome computation, key equation, Chien search) achieve $O(n^2)$ or $O(n\log^2 n)$; they compute the same answer, which is unique by Theorem 8.2.

### 11.4 Minimum-weight codeword generation

By Theorem 6.3, enumerate $(k-1)$-subsets $T$ and output the evaluation vector of $\prod_{i\in T}(X-\alpha_i)$: a family of $\binom{n}{k-1}$ codewords of exactly minimal weight, at $O(nk)$ each.

---

## 12. Applications

**Deep-space and satellite communication.** The concatenated coding standard used on deep-space missions pairs an inner convolutional code with an outer Reed–Solomon code over $\mathbb{F}_{256}$, precisely because the inner decoder fails in *bursts*, and a burst of bit errors confined to a few bytes is a small number of *symbol* errors for the outer code. MDS optimality means no alternative outer code of the same rate could do better.

**Optical storage.** CD and DVD error correction is a cross-interleaved pair of Reed–Solomon codes. Interleaving spreads a physical scratch across many codewords so each sees only one or two damaged symbols, within the correction radius $\lfloor (n-k)/2 \rfloor$.

**Two-dimensional barcodes.** QR codes carry Reed–Solomon redundancy at four selectable levels; the highest tolerates roughly 30% symbol loss, which is why a logo may cover part of a code.

**Distributed storage.** RAID-6 and cloud erasure coding store $k$ data shards as $n$ shards; by Theorem 8.1, any $k$ survivors reconstruct the file, and by Corollary 7.3 it does not matter *which* $k$. MDS is precisely the statement that storage overhead is minimal for the stated fault tolerance.

**Secret sharing.** Shamir's scheme is the Reed–Solomon code read as a cryptographic primitive: encode a secret $s$ as the constant term of a uniformly random $p \in P_{<k}$ and hand $p(\alpha_i)$ to participant $i$. Any $k$ participants interpolate $s$ (Corollary 7.4); any $k-1$ learn nothing, because for every candidate secret $s'$ there is exactly one polynomial consistent with their shares and with $p(0)=s'$ — again Corollary 7.4, applied to the $k$ points consisting of their shares together with $0$.

**Proof systems and low-degree testing.** Theorem 5.1, read contrapositively, says two distinct polynomials of degree $< k$ agree in at most $k-1$ places; over a large field, random spot checks therefore certify polynomial identities with overwhelming probability. This is the combinatorial engine of modern succinct arguments.

---

## 13. Discussion

### 13.1 What makes the argument tight

It is worth isolating why equality holds. The Singleton bound is proved by *deleting* $d-1$ coordinates; the root bound is proved by *counting roots* of a degree-$(k-1)$ polynomial. These are the same count from opposite sides: the puncturing argument says a code of dimension $k$ must contain a codeword vanishing on any prescribed $k-1$ coordinates (dimension count), and the polynomial construction *produces* that codeword explicitly as $\prod_{i\in T}(X-\alpha_i)$. The abstract obstruction and the concrete construction are in exact correspondence, which is why nothing is lost.

### 13.2 Boundary cases and hypothesis hygiene

Three boundary phenomena deserve explicit mention, because they are where informal statements of these theorems go wrong.

* **$k=0$.** The code is $\{0\}$; it has no nonzero codeword and its minimum distance is undefined (a minimum over an empty set). All distance statements accordingly assume $1 \le k$.
* **$k=n$.** The code is all of $F^n$, with $d = 1$; still MDS, and the dual is $\{0\}$, whose distance is undefined. Theorem 9.4 therefore assumes $k < n$.
* **Vacuity of the weight hypothesis.** As in Remark 4.4, "every nonzero codeword has weight $\ge d$" is vacuous when $C=\{0\}$, and the Singleton bound needs the guard $d \le n$. Every application supplies the guard automatically from the existence of a nonzero codeword.

### 13.3 The field-size constraint

Nothing here bounds $n$ by $|F|$ except implicitly: the construction requires $n$ *distinct* evaluation points in $F$, so $n \le |F|$. This is not an artifact. Nontrivial MDS codes cannot be arbitrarily long over a fixed field: the *MDS conjecture* asserts that for $2 \le k \le q-1$ the maximum length of an $[n,k,n-k+1]$ code over $\mathbb{F}_q$ is $q+1$, except for two sporadic families in characteristic $2$. Reed–Solomon codes (extended by an extra evaluation "at infinity") achieve $q+1$, so the conjecture asserts that Reed–Solomon codes and their relatives are essentially the *only* long MDS codes. This is why the alphabet of a practical code — $\mathbb{F}_{256}$, one byte — is chosen as large as it is.

### 13.4 Relation to classical statements

Theorem 6.2 is the classical statement that Reed–Solomon codes are MDS; the contribution of the present treatment is organizational: a clean separation between the alphabet-agnostic linear-algebra half (Section 4) and the polynomial half (Section 5), a two-directional information-set theorem (Section 7) that is then *reused* to obtain duality (Section 9) rather than re-deriving weights, and an explicit accounting of hypotheses.

---

## 14. Future directions

Derived from the results established above — the encoder $P_{<k} \to F^n$ is injective for distinct evaluation points, the code has dimension exactly $k$, every nonzero codeword has weight $\ge n-k+1$, the general Singleton bound $\dim C + d \le n+1$ holds for every linear code, the two combine to $d = n-k+1$, every $k$-subset of coordinates is an information set, and the dual code has dimension $n-k$ and minimum distance exactly $k+1$ — several natural extensions present themselves.

### 14.1 Generalized Reed–Solomon codes

Fix nonzero multipliers $v_0,\dots,v_{n-1} \in F^\times$ and define $\mathrm{GRS}_k(\alpha,v) = \{(v_i\,p(\alpha_i))_i : p \in P_{<k}\}$. Column scaling is a *weight-preserving* linear automorphism of $F^n$: it maps subspaces to subspaces of the same dimension and preserves supports exactly. Consequently every theorem above transports verbatim, and the resulting family is closed under duality — the dual of a generalized Reed–Solomon code is again one, for an explicitly computable multiplier vector. The converse direction of the information-set theorem (Theorem 7.2) is what makes this cheap: one recognizes the scaled code as MDS without recomputing any weights.

### 14.2 Weight enumerator of an MDS code

The number $A_w$ of codewords of weight $w$ in *any* $[n,k,n-k+1]$ code over $\mathbb{F}_q$ is determined by the parameters alone:
$$A_w = \binom{n}{w} \sum_{j=0}^{w-d} (-1)^j \binom{w}{j}\bigl(q^{\,w-d+1-j} - 1\bigr), \qquad d = n-k+1 .$$
The derivation is Möbius inversion over subsets of coordinates, and the input it needs is exactly Theorem 7.1: restriction to any $k$-set is bijective, so the number of codewords vanishing outside a prescribed set of size $w$ is $q^{\max(0,\,w-d+1)}$. Establishing this identity would give, for free, the complete weight distribution of every code discussed here.

### 14.3 Non-existence of long MDS codes over small fields

An $[n,k,n-k+1]$ code with $2 \le k \le n-2$ forces $n \le q + k - 1$, by a double count on parity-check columns in general position: the columns of a parity-check matrix of an MDS code are in *general position* in a space of dimension $n-k$, and counting incidences of such an arc with hyperplanes bounds its size. This is the elementary half of the MDS conjecture and follows from the machinery above, since the general-position property of the parity-check columns is a restatement of the dual code's MDS property (Theorem 9.4).

### 14.4 Further avenues

* **Extended and doubly extended codes.** Adjoining the coefficient of $X^{k-1}$ as an "evaluation at infinity" yields an $[q+1,k,q-k+2]$ MDS code over $\mathbb{F}_q$; the arguments of Sections 4–6 adapt with the degree bookkeeping shifted by one.
* **Algorithmic decoding.** A rigorous treatment of the Berlekamp–Massey / key-equation decoder, proving it outputs the codeword whose uniqueness is guaranteed by Theorem 8.2, would connect the combinatorial theory to the $O(n^2)$ algorithms actually deployed.
* **List decoding.** Beyond radius $(n-k)/2$, the Guruswami–Sudan algorithm returns all codewords within radius $n - \sqrt{nk}$, a strictly larger regime; the combinatorial bound underlying it (the Johnson bound) is a refinement of the counting in Theorem 8.2.
* **Folded and multiplicity codes.** Capacity-achieving list-decodable variants keep the polynomial-evaluation skeleton but bundle coordinates; the dimension and weight arguments generalize with the degree bound replaced by a bound on the number of high-multiplicity roots.

---

## 15. Conclusion

Reed–Solomon codes are optimal, exactly and not approximately, and the reason is a single elementary fact: a nonzero polynomial of degree less than $k$ has at most $k-1$ roots. From it follow the dimension count, the weight bound, and — after meeting the universal Singleton bound coming from pure linear algebra — the equality $d = n-k+1$. That equality then propagates: to the characterization of every $k$-subset of coordinates as an information set, to interpolation, to the correction of $n-k$ erasures and $\lfloor (n-k)/2 \rfloor$ errors, and to the fact that the dual code is optimal too, with parameters $[n,n-k,k+1]$.

The architecture of the argument — a universal upper bound and a constructive lower bound, proved by disjoint means and coinciding exactly — is the reason the theory is so stable, and the reason these codes have survived six decades of engineering practice unchanged.
