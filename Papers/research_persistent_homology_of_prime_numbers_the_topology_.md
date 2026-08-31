# The Topology of Arithmetic: Persistent Homology of the Prime Point Cloud

**Aristotle**

*2026-08-31*

---

## Abstract

We study the Vietoris–Rips persistent homology of the prime numbers viewed as a point cloud on the real line, $P = \{p_1, p_2, p_3, \dots\} = \{2, 3, 5, 7, \dots\} \subset \mathbb{R}$, and determine its barcode completely.

Four groups of results are established. First, a *vanishing theorem*: for an arbitrary point cloud on a line, the mod-$2$ first homology of the Rips complex vanishes at every scale, so the prime cloud has no degree-one barcode at all; this is sharp, since an explicit four-point planar configuration carries an essential one-cycle. Second, a *rigidity theorem*: for a cloud on a line the degree-zero barcode is the multiset of consecutive gaps, the Betti curve $b_0(\varepsilon, n) = 1 + \#\{i < n : g_i > \varepsilon\}$ is a complete invariant of that barcode, and the barcode is $2\delta$-stable under $\delta$-perturbations of the cloud. Third, an *atomicity theorem* and a consequent refutation: every bar of the prime barcode has length $1$ (once) or an even length $\ge 2$, so the bar-length spectrum is supported on the lattice $\{1\} \cup 2\mathbb{N}$; the number of bars shorter than $2$ among the first $n$ is exactly $1$, whereas an exponential law of any mean $\mu > 0$ predicts $n(1 - e^{-2/\mu}) \to \infty$ such bars. No exponential (Poisson) law, in particular none with mean $\log x$, describes the raw prime barcode. Fourth, a *dictionary* between arithmetic and topology: the twin-prime counting function is exactly the Betti defect at scale $2$, via the identity $b_0(2, n) + \#\{i < n : g_i = 2\} = n$, so the twin prime conjecture is equivalent to the unboundedness of $n - b_0(2, n)$; the same translation puts the bounded-gaps theorem of Zhang and Maynard–Tao in the form "the scale-$246$ Betti defect is unbounded"; and, contrary to naive expectation, at *every* fixed scale the prime cloud has arbitrarily many connected components.

Numerical evidence to $10^6$ (78 497 bars, mean length $12.74$, longest bar $114$ starting at $492\,113$, $8\,169$ twin bars, $b_0(2, n) = 70\,328$) confirms every identity exactly.

**Keywords:** persistent homology, Vietoris–Rips complex, prime gaps, twin primes, Betti curve, bounded gaps, Cramér model.

---

## 1. Introduction

Persistent homology extracts, from a finite metric space, a multiscale summary of its shape: one inflates each point to a ball of radius $\varepsilon/2$, records the homotopy type of the resulting union (combinatorially, of the Vietoris–Rips complex), and tracks the birth and death of homological features as $\varepsilon$ grows. The output is a *barcode*: a multiset of intervals, one per feature.

The primes furnish a canonical infinite point cloud, and the question of what its barcode looks like is natural, concrete, and — as it turns out — completely answerable in degree zero and completely trivial in degree one. Our aim in this paper is to answer it, and then to run the answer in the opposite direction: to express arithmetic statements about prime gaps as statements about the topology of the cloud.

There is a specific set of expectations we test. A widely believed heuristic (Cramér's model) asserts that the primes behave, in the large, like a Poisson process of intensity $1/\log x$. If true in the most naive sense, this would predict that the degree-zero bar lengths of the prime cloud are exponentially distributed with mean $\log x$; and one might further guess that at some large scale — say $\varepsilon \sim \log^2 x$ — one-dimensional holes appear, with the longest such hole encoding the twin prime conjecture. We show that both of these expectations are false, the second for a dimensional reason and the first for a parity reason, and we identify the surviving arithmetic content: the twin prime conjecture *is* a statement about the degree-zero Betti number, evaluated at scale $2$.

### 1.1 Organisation

Section 2 fixes definitions. Section 3 proves the degree-one vanishing theorem and its sharpness. Section 4 identifies the degree-zero barcode with the gap sequence and establishes rigidity and stability of the Betti curve. Section 5 proves atomicity and refutes the exponential law. Section 6 develops the arithmetic–topology dictionary: twin primes, bounded gaps, and unboundedness of the component count. Section 7 gives algorithms. Section 8 reports numerics. Sections 9 and 10 discuss and propose future work.

---

## 2. Definitions

Throughout, $p_1 = 2 < p_2 = 3 < p_3 = 5 < \cdots$ enumerates the primes in increasing order, and

$$g_i \;=\; p_{i+1} - p_i \qquad (i \ge 1)$$

is the $i$-th prime gap. It will occasionally be convenient to index gaps from $0$, in which case $g_0 = p_2 - p_1 = 1$; we say explicitly which convention is in force where it matters. All statements below are indexed so that the first (length-$1$) bar is the $0$-th.

**Definition 2.1 (Point cloud on a line).** A *line cloud* is a strictly increasing map $p : \mathbb{N} \to \mathbb{R}$. Its $i$-th *gap* is $g_i = p(i+1) - p(i) > 0$. The *prime cloud* is $p(i) = p_{i+1}$, the $(i+1)$-st prime, so $g_0 = 1$, $g_1 = 2$, $g_2 = 2$, $g_3 = 4$, ….

**Definition 2.2 (Vietoris–Rips complex).** Let $(X, d)$ be a finite metric space and $\varepsilon \ge 0$. The Rips complex $\mathrm{R}_\varepsilon(X)$ is the abstract simplicial complex whose $k$-simplices are the $(k+1)$-element subsets of $X$ of diameter at most $\varepsilon$. It is monotone in $\varepsilon$, so $\{\mathrm{R}_\varepsilon(X)\}_{\varepsilon \ge 0}$ is a filtration.

**Definition 2.3 (Barcode, Betti curve).** For a field $\mathbb{F}$, the persistent homology $H_k(\mathrm{R}_\bullet(X); \mathbb{F})$ decomposes into interval modules; the multiset of intervals is the degree-$k$ *barcode*. The *Betti curve* is $\varepsilon \mapsto \dim_{\mathbb{F}} H_k(\mathrm{R}_\varepsilon(X); \mathbb{F})$, i.e. the number of bars containing $\varepsilon$. We work with $\mathbb{F} = \mathbb{F}_2$.

**Definition 2.4 (Betti curve of a line cloud).** For a line cloud $p$, scale $\varepsilon \in \mathbb{R}$ and $n \in \mathbb{N}$, set

$$b_0(p; \varepsilon, n) \;=\; 1 + \#\{\, i < n : p(i+1) - p(i) > \varepsilon \,\},$$

the number of connected components of $\mathrm{R}_\varepsilon(\{p(0), \dots, p(n)\})$. (Proposition 4.1 justifies the name.) We abbreviate $b_0(\varepsilon, n)$ for the prime cloud.

**Definition 2.5 (Barcode multiset, total persistence).** The degree-zero *barcode multiset* of the first $n+1$ points of a line cloud is $\mathcal{B}_n(p) = \{\!\{\, g_0, g_1, \dots, g_{n-1} \,\}\!\}$, a multiset of $n$ positive reals. Its *total persistence* is $\sum_{i<n} g_i$.

**Definition 2.6 (Betti defect, merge count).** The *merge count* at scale $\varepsilon$ is $M(\varepsilon, n) = \#\{ i < n : g_i \le \varepsilon \}$, and the *Betti defect* is $(n+1) - b_0(\varepsilon, n)$.

**Definition 2.7 (Chain-level degree one, mod 2).** Over $\mathbb{F}_2$ we model a $1$-chain of a line cloud $p$ at scale $\varepsilon$ as a finite set $E$ of ordered pairs $(a, b)$ with $a < b$ and $p(b) - p(a) \le \varepsilon$ (a *Rips edge*), with symmetric difference as addition. The *degree* of a vertex $v$ in $E$ is the number of edges of $E$ containing $v$; $E$ is a *cycle* if every degree is even. A *Rips triangle* is a triple $a < b < c$ with $p(c) - p(a) \le \varepsilon$; its boundary is the three-edge set $\{(a,b), (b,c), (a,c)\}$. The *boundary subgroup* is the subgroup generated by boundaries of Rips triangles, and $H_1 = \mathrm{cycles}/\mathrm{boundaries}$.

---

## 3. Degree one: the prime cloud has no holes

The mission-level intuition that the primes should have an interesting $H_1$ barcode is refuted in the strongest possible form: no cloud on a line has any $H_1$ at any scale.

**Lemma 3.1 (Umbrella lemma).** Let $p$ be a line cloud, $\varepsilon \ge 0$, and let $u, w \le M$ be indices with $p(M) - p(u) \le \varepsilon$ and $p(M) - p(w) \le \varepsilon$. Then $\{u, w, M\}$ has diameter at most $\varepsilon$; in particular $(u, w)$ (or $(w,u)$) is a Rips edge and, if $u, w, M$ are distinct, they span a Rips triangle.

*Proof.* Monotonicity of $p$ gives $p(u), p(w) \in [p(M) - \varepsilon, p(M)]$, an interval of length $\varepsilon$, so $|p(u) - p(w)| \le \varepsilon$, and the diameter of the triple is $\max(p(M) - \min(p(u), p(w))) \le \varepsilon$. $\square$

This is the *indifference-graph* property of the Rips graph of a line cloud: two neighbours of a vertex, both on the same side of it, are neighbours of each other.

**Theorem 3.2 (Vanishing of $H_1$ on a line).** Let $p$ be a line cloud and $\varepsilon \ge 0$. Every $1$-cycle of Rips edges is a sum of boundaries of Rips triangles. Consequently $H_1(\mathrm{R}_\varepsilon; \mathbb{F}_2) = 0$ for every $\varepsilon$, and the whole degree-one persistence module of a line cloud is zero.

*Proof sketch.* Descent on the measure $\Phi(E) = \sum_{(a,b) \in E} b$, the sum of upper endpoints. Let $E \ne \emptyset$ be a cycle and let $M$ be its largest vertex. Since $\deg_E(M)$ is even and positive, there are at least two distinct edges $(u, M)$, $(w, M)$ in $E$ with $u, w < M$. By Lemma 3.1 the triple $\{u, w, M\}$ spans a Rips triangle $T$; without loss of generality $u < w$. Replace $E$ by $E \mathbin{\triangle} \partial T$. This removes $(u, M)$ and $(w, M)$ and toggles $(u, w)$, so
$$\Phi(E \mathbin{\triangle} \partial T) - \Phi(E) \;=\; \pm w - 2M \;<\; 0,$$
since $w < M$. Symmetric difference with a boundary preserves the cycle condition (parity of every degree is unchanged mod $2$, since $\partial T$ has all degrees even at each of $u, w, M$ and zero elsewhere). Iterating, the strictly decreasing nonnegative integer measure forces termination at $E = \emptyset$; unwinding, the original $E$ is the sum of the triangle boundaries used. The argument is uniform in $\varepsilon$, hence applies slicewise to the whole filtration. $\square$

**Corollary 3.3 (No essential prime one-cycle).** There is no scale $\varepsilon$ at which the prime cloud carries an essential $1$-cycle. The conjectured degree-one prime barcode is empty, and no arithmetic information — in particular not the twin prime conjecture — can be stored in degree one.

The theorem is a statement about the *line*, not a weakness of the chain-level framework. The next result makes this precise.

**Theorem 3.4 (Sharpness in dimension one).** Let $d$ be the graph metric of the $4$-cycle on $\{0,1,2,3\}$: $d(i,j) = 1$ for adjacent indices and $d(0,2) = d(1,3) = 2$ (all further points placed at distance $100$). At scale $\varepsilon = 1$ the Rips complex has edges $\{01, 12, 23, 03\}$ and **no** $2$-simplex, since every triple of the four vertices contains an antipodal pair at distance $2$. Hence the boundary subgroup is trivial, while the square $\{01, 12, 23, 03\}$ is a cycle (each vertex has degree $2$). It therefore represents a nonzero class in $H_1$.

*Proof sketch.* If a scale admits no $2$-simplex then the boundary subgroup is $\{\emptyset\}$; the square is a nonempty cycle; so it is not a boundary. The verification that there is no triangle quantifies over *all* triples of indices, using the distance-$100$ separation for triples that leave $\{0,1,2,3\}$ and a finite case analysis inside. $\square$

**Remark 3.5.** Comparing the two theorems isolates the mechanism exactly: the umbrella lemma fails for the square, because the two neighbours $1$ and $3$ of the vertex $0$ are at distance $2$ from each other. One dimension is precisely the boundary between trivial and nontrivial degree-one homology, and the primes lie on the trivial side.

---

## 4. Degree zero: the barcode is the gap sequence, and the Betti curve remembers it

**Proposition 4.1 (Barcode of a line cloud).** Let $p$ be a line cloud. In $\mathrm{R}_\varepsilon(\{p(0), \dots, p(n)\})$, two consecutive points lie in the same component iff $g_i \le \varepsilon$, and a component is exactly a maximal run of consecutive indices with all internal gaps $\le \varepsilon$. Hence
$$b_0(p; \varepsilon, n) = 1 + \#\{ i < n : g_i > \varepsilon \},$$
and, in the persistence module, the class of the component ending at index $i$ dies exactly at $\varepsilon = g_i$. The degree-zero barcode of the first $n+1$ points is therefore
$$\{\!\{\, [0, g_i) : i < n \,\}\!\} \;\cup\; \{[0, \infty)\},$$
so bar lengths are the gaps and the total persistence is $\sum_{i<n} g_i = p(n) - p(0)$. For the primes, the total persistence of the first $n$ bars is $p_{n+1} - 2$.

*Proof sketch.* An edge joins $p(i)$ and $p(j)$, $i<j$, iff $p(j) - p(i) \le \varepsilon$, which by monotonicity forces every intermediate gap to be $\le \varepsilon$; so the connectivity relation is generated by the consecutive edges. The component count is one more than the number of "breaks", and the standard elder-rule matching in degree zero kills the younger component at the scale where the break closes. The telescoping sum gives total persistence. $\square$

**Proposition 4.2 (Betti defect counts merges).** For every $\varepsilon$ and $n$, $b_0(\varepsilon, n) \le n+1$ and
$$(n+1) - b_0(\varepsilon, n) \;=\; \#\{ i < n : g_i \le \varepsilon \} \;=\; M(\varepsilon, n).$$

*Proof.* Complementary counting on $\{i < n\}$ against the definition of $b_0$. $\square$

**Proposition 4.3 (Monotonicity).** For fixed $n$, $\varepsilon \mapsto b_0(p; \varepsilon, n)$ is antitone: enlarging the scale can only merge components. Formally, $\varepsilon_1 \le \varepsilon_2$ implies $b_0(p; \varepsilon_2, n) \le b_0(p; \varepsilon_1, n)$, since the filtered index set at $\varepsilon_2$ is contained in that at $\varepsilon_1$.

The Betti curve, being a summary statistic, might a priori lose information. It does not.

**Theorem 4.4 (Tail counts determine a finite multiset).** Let $A, B$ be finite multisets of reals with $\#\{a \in A : a > \varepsilon\} = \#\{b \in B : b > \varepsilon\}$ for every $\varepsilon \in \mathbb{R}$. Then $A = B$.

*Proof sketch.* Induct on $|A|$. Choosing $\varepsilon$ below all elements of both multisets (possible since both are finite) shows $|A| = |B|$; if both are empty we are done. Otherwise let $a = \max A$, $b = \max B$ and suppose $a < b$. Evaluating the hypothesis at $\varepsilon$ with $a \le \varepsilon < b$ gives $0 = \#\{x \in A: x > \varepsilon\} = \#\{x \in B : x > \varepsilon\} \ge 1$, a contradiction; symmetrically $b < a$ is impossible, so $a = b$. Write $A = a ::  A'$, $B = b :: B'$; the tail-count hypothesis transports to $A', B'$ (both counts drop by $1$ for $\varepsilon < a$ and are unchanged for $\varepsilon \ge a$), and induction finishes. $\square$

**Theorem 4.5 (The Betti curve is a complete invariant).** Let $p, q$ be line clouds and $n \in \mathbb{N}$. Then
$$\big(\forall \varepsilon,\; b_0(p; \varepsilon, n) = b_0(q; \varepsilon, n)\big) \iff \mathcal{B}_n(p) = \mathcal{B}_n(q).$$

*Proof.* By Definition 2.4, $b_0(p; \varepsilon, n) = 1 + \#\{x \in \mathcal{B}_n(p) : x > \varepsilon\}$: the Betti curve is $1$ plus the upper-tail counting function of the barcode multiset. The forward direction is Theorem 4.4; the converse is immediate. $\square$

**Corollary 4.6 (Window counts).** For $\varepsilon_1 \le \varepsilon_2$,
$$b_0(p; \varepsilon_1, n) - b_0(p; \varepsilon_2, n) \;=\; \#\{ i < n : \varepsilon_1 < g_i \le \varepsilon_2 \}.$$
Thus the Betti curve is the cumulative bar-length histogram, and individual bar-length counts are its discrete derivatives.

**Theorem 4.7 (Stability / interleaving).** Let $p, q$ be line clouds with $|p(i) - q(i)| \le \delta$ for all $i$. Then for every $\varepsilon$ and $n$,
$$b_0(q; \varepsilon + 2\delta, n) \;\le\; b_0(p; \varepsilon, n).$$

*Proof.* If $\varepsilon + 2\delta < q(i+1) - q(i)$ then, using $q(i+1) \le p(i+1) + \delta$ and $q(i) \ge p(i) - \delta$, we get $\varepsilon < p(i+1) - p(i)$. Hence the index set counted at $(q, \varepsilon+2\delta)$ injects into the one counted at $(p, \varepsilon)$, and the cardinalities compare. $\square$

Theorem 4.7 is the hard-stability guarantee for the whole programme: everything proved below about the prime barcode is robust under a bounded perturbation of the positions of the primes, so it reflects their *spacing* and not accidental features of their exact values.

---

## 5. Atomicity, and the refutation of the exponential law

We now specialise to the primes. Recall the $0$-indexed convention: $g_0 = 3 - 2 = 1$, $g_1 = 5 - 3 = 2$, etc.

**Lemma 5.1.** $g_0 = 1$; every gap is strictly positive; and $p_{n+1}$ is odd for every $n \ge 1$ (i.e. every prime after $2$ is odd).

*Proof.* $g_0 = 3 - 2 = 1$. Positivity is strict monotonicity of the prime enumeration. For oddness: the $n$-th prime for $n \ge 1$ is at least the second prime, $3$, and a prime $\ge 3$ is not divisible by $2$. $\square$

**Lemma 5.2 (Parity).** For every $i \ge 1$, $g_i$ is even.

*Proof.* $g_i = p_{i+2} - p_{i+1}$ with both terms odd by Lemma 5.1. $\square$

**Theorem 5.3 (Atomicity of the bar-length spectrum).** For every index $i$, exactly one of the following holds:
- $i = 0$ and $g_i = 1$;
- $i \ge 1$, $g_i$ is even and $g_i \ge 2$.

Hence the degree-zero bar-length spectrum of the prime cloud is supported on the lattice $\{1\} \cup 2\mathbb{N}_{\ge 1}$, a set of Lebesgue measure zero.

*Proof.* Combine Lemmas 5.1 and 5.2: for $i \ge 1$, $g_i$ is even and positive, hence $\ge 2$. $\square$

**Lemma 5.4 (Short bars).** For every $i$, $g_i < 2 \iff i = 0$.

**Theorem 5.5 (Exactly one short bar).** For every $n \ge 1$,
$$\#\{\, i < n : g_i < 2 \,\} \;=\; 1.$$

*Proof.* By Lemma 5.4 the filtered set is $\{0\}$, which lies in $\{0, \dots, n-1\}$ because $n \ge 1$. $\square$

**Theorem 5.6 (Refutation of the exponential / Poisson law).** Let $\mu > 0$ be any candidate mean. There exists $N \ge 1$ such that for all $n \ge N$,
$$\#\{\, i < n : g_i < 2 \,\} \;<\; n\,\big(1 - e^{-2/\mu}\big).$$
That is, the exponential law $\mathrm{Exp}(1/\mu)$ predicts $n(1-e^{-2/\mu}) \to \infty$ bars of length below $2$, whereas the true count is constantly $1$. Consequently no exponential law with any mean — in particular none with mean $\log x$ — describes the degree-zero bar lengths of the primes.

*Proof.* Set $c = 1 - e^{-2/\mu}$. Since $\mu > 0$, $-2/\mu < 0$, so $e^{-2/\mu} < 1$ and $c > 0$. Choose $N \ge \max(1, \lceil 1/c \rceil + 1)$, so that $n > 1/c$, i.e. $nc > 1$, for all $n \ge N$. By Theorem 5.5 the left side equals $1$ for all such $n$, and $1 < nc$. $\square$

**Remark 5.7 (What survives).** The refutation is a statement about the *support* of the barcode measure, not about its shape. Two conclusions follow. (i) The failure cannot be repaired by re-tuning $\mu$: it holds for all $\mu > 0$ simultaneously, and quantitatively rather than rhetorically. (ii) The correct form of the Cramér prediction must be applied to the barcode *rescaled by the local mean gap*: one should ask whether
$$\frac{1}{n}\,\#\{\, i < n : g_i \le t \log p_i \,\} \longrightarrow 1 - e^{-t} \qquad (t > 0),$$
which divides out the lattice while preserving the shape. That statement remains open; it is the honest form of the conjecture, and Theorem 4.5 guarantees that stating it in terms of $b_0(t \log x, n)$ loses nothing.

**Corollary 5.8 (Even-scale rigidity of the prime staircase).** For every $k \ge 1$ and every $n$, the function $\varepsilon \mapsto b_0(\varepsilon, n)$ is constant on the open interval $(2k, 2k+2)$: the prime Betti curve can only jump at even scales (and once, at scale $1$).

*Proof.* By Corollary 4.6, a jump between $\varepsilon_1 < \varepsilon_2$ in $(2k, 2k+2)$ requires a gap in $(\varepsilon_1, \varepsilon_2]$, hence a non-even gap value in $(2k, 2k+2)$ other than the value $1$ (which lies in no such interval for $k \ge 1$), contradicting Theorem 5.3. $\square$

**Corollary 5.9 (Atomicity is an arithmetic inequality).** For $n \ge 1$, $p_{n+1} \ge 2n + 1$, and the total persistence of the first $n$ prime bars satisfies $\sum_{i<n} g_i \ge 2n - 1$.

*Proof.* Total persistence telescopes to $p_{n+1} - 2$ (Proposition 4.1). By Theorem 5.3 the $n$ bars consist of one bar of length $1$ and $n-1$ bars of length $\ge 2$, so $p_{n+1} - 2 \ge 1 + 2(n-1) = 2n - 1$. $\square$

Thus running the topology backwards recovers the elementary linear lower bound for the $n$-th prime.

---

## 6. The arithmetic–topology dictionary

### 6.1 Twin primes as a Betti defect

**Lemma 6.1 (Three-way split of the bars).** For $n \ge 1$, writing $T(n) = \#\{ i < n : g_i = 2 \}$ for the number of twin-prime bars,
$$\#\{ i < n : g_i > 2 \} \;+\; T(n) \;+\; 1 \;=\; n.$$

*Proof.* Split $\{0, \dots, n-1\}$ into $\{g_i > 2\}$ and its complement. By Theorem 5.3 the complement consists of index $0$ (where $g_0 = 1$) together with the indices where $g_i = 2$: indeed, for $i \ge 1$, $g_i \le 2$ and $g_i$ even and positive forces $g_i = 2$. Index $0$ is not among the twin indices since $g_0 = 1 \ne 2$, so the complement has cardinality $T(n) + 1$. $\square$

**Theorem 6.2 (The twin prime counting function is a Betti defect).** For every $n \ge 1$,
$$b_0(2, n) \;+\; T(n) \;=\; n.$$
Equivalently, $T(n) = n - b_0(2, n)$: the twin-prime count is exactly the shortfall of the number of connected components of the first $n+1$ primes at scale $2$ below $n$.

*Proof.* $b_0(2,n) = 1 + \#\{i<n : g_i > 2\}$ by Proposition 4.1; add $T(n)$ and apply Lemma 6.1. $\square$

**Corollary 6.3 (A single Betti difference).** $T(n) = b_0(1, n) - b_0(2, n)$ for every $n$.

*Proof.* Corollary 4.6 with $\varepsilon_1 = 1, \varepsilon_2 = 2$ counts gaps in $(1, 2]$, which by Theorem 5.3 are exactly the gaps equal to $2$. $\square$

**Theorem 6.4 (Twin prime conjecture $=$ unbounded Betti defect).** The following are equivalent:
1. There are infinitely many twin primes, i.e. $\{ p : p \text{ and } p+2 \text{ prime} \}$ is infinite;
2. $\{ i : g_i = 2 \}$ is infinite;
3. for every $K \in \mathbb{N}$ there exists $n$ with $n - b_0(2, n) \ge K$: the Betti defect of the prime cloud at scale $2$ is unbounded.

*Proof sketch.* (1) $\Leftrightarrow$ (2) is the standard reindexing: a twin pair $(p, p+2)$ has no prime strictly between its members, so it is a pair of consecutive primes, i.e. a gap equal to $2$; conversely a gap of $2$ is a twin pair. (2) $\Rightarrow$ (3): from an infinite index set one extracts, for any $K$, a finite subset of size $K$, all of whose elements lie below some $n$; then $T(n) \ge K$, and $n - b_0(2,n) = T(n)$ by Theorem 6.2. (3) $\Rightarrow$ (2): if the index set were finite of cardinality $C$, then $T(n) \le C$ for all $n$, so the defect is bounded by $C$ — contradiction with $K = C+1$. The natural-number subtraction in the defect is harmless because $b_0(2,n) \le n$ for $n \ge 1$, again by Theorem 6.2. $\square$

The content of Theorem 6.4 is that the twin prime conjecture is not a statement about a *bar* of the prime barcode; it is a statement about a *Betti number* at the single fixed scale $2$, in the limit $n \to \infty$. Together with Corollary 3.3, it also locates the conjecture unambiguously in degree zero: there is no degree-one home for it.

### 6.2 Bounded gaps as an unbounded defect at a finite scale

**Theorem 6.5 (Small bars are early merges).** For any real $\varepsilon$, the following are equivalent:
1. $\{ i : g_i \le \varepsilon \}$ is infinite;
2. the Betti defect $(n+1) - b_0(\varepsilon, n)$ is unbounded in $n$.

*Proof.* By Proposition 4.2 the defect equals $M(\varepsilon, n) = \#\{i<n : g_i \le \varepsilon\}$, a counting function of an index set; a counting function of an index set is unbounded exactly when the set is infinite. $\square$

**Corollary 6.6 (Bounded gaps in barcode form).** Suppose that for every $N$ there exist primes $p < q$ with $p \ge N$ and $q - p \le B$ (the conclusion of the theorems of Zhang and of Maynard–Tao, valid with $B = 246$). Then infinitely many prime gaps are at most $B$, hence the prime cloud performs arbitrarily many merges at the fixed scale $B$: the scale-$B$ Betti defect is unbounded.

*Proof sketch.* If $q - p \le B$ with $p < q$ prime, then the gap immediately to the right of $p$ is at most $q - p \le B$, so there is an index $i$ with $p_{i+1} \ge N$ and $g_i \le B$; as $N$ is arbitrary the index set is infinite. Apply Theorem 6.5. $\square$

**Theorem 6.7 (Converse translation).** If the scale-$B$ Betti defect is unbounded, then $\liminf_{n} (p_{n+1} - p_n) \le B$.

*Proof sketch.* By Theorem 6.5 there are infinitely many indices with $g_i \le B$, so the gap sequence has a subsequence bounded by $B$; the liminf of a sequence with a subsequence bounded by $B$ is at most $B$. $\square$

Corollary 6.6 and Theorem 6.7 together say that the topological and arithmetic formulations of bounded gaps are *equivalent*, with the twin prime conjecture the case $B = 2$.

### 6.3 The cloud never connects

A natural expectation is that at a sufficiently large scale the prime cloud becomes connected. It does not, at any scale.

**Lemma 6.8 (Composite window).** For $2 \le k \le m$, the number $m! + k$ is composite: $k \mid m!$ (as $k \le m$ and $k \ge 2$), so $k \mid m! + k$, while $m! + k > k$.

**Theorem 6.9 (Arbitrarily long bars, arbitrarily late).** For all $L, N \in \mathbb{N}$ there exists $n \ge N$ with $g_n > L$.

*Proof sketch.* Choose $m = \max(L+2,\, p_{N+1} + 2)$ and let $c$ be the number of primes below $m! + 2$. The choice of $m$ makes $c \ge N+1$, so the index $c - 1$ is $\ge N$. The $(c-1)$-st prime is at most $m! + 1$, while the $c$-th prime is at least $m!+2$; but $m!+2, \dots, m!+m$ are all composite by Lemma 6.8, so the $c$-th prime is at least $m! + m + 1$. Hence $g_{c-1} \ge (m!+m+1) - (m!+1) = m > L$. $\square$

**Corollary 6.10 (Infinitely many long bars).** For every real $\varepsilon$, the set $\{ i : g_i > \varepsilon \}$ is infinite.

**Theorem 6.11 (Unbounded component count at every scale).** For every real $\varepsilon$ and every $K \in \mathbb{N}$ there exists $n$ with $b_0(\varepsilon, n) \ge K$. At every fixed scale, the prime cloud has arbitrarily many connected components; it is never eventually connected.

*Proof.* Combine Corollary 6.10 with $b_0(\varepsilon, n) = 1 + \#\{i<n : g_i > \varepsilon\}$: the counting function of an infinite index set is unbounded. $\square$

**Remark 6.12.** Theorems 6.5 and 6.11 are two sides of the same object. At a fixed scale $\varepsilon$, both the number of merges *and* the number of surviving components grow without bound; the prime barcode has infinitely many bars below $\varepsilon$ and infinitely many bars above $\varepsilon$, for every $\varepsilon$. The barcode never simplifies.

---

## 7. Algorithms

All computations reduce to the gap sequence, so the pipeline is linear after sieving.

**Algorithm A (Prime barcode).** Sieve to $X$ in $O(X \log\log X)$ time and $O(X)$ bits; emit consecutive differences. Output: the degree-zero barcode as a list of $\pi(X) - 1$ bar lengths. By Proposition 4.1 this *is* the barcode — no persistence pairing needs to be computed, which is what makes the prime cloud tractable at scales where general Rips persistence would be hopeless (a Rips complex on $78\,497$ points has $\sim 3 \times 10^9$ edges).

**Algorithm B (Betti curve and defects).** Given the bar lengths, sort them once in $O(n \log n)$; then $b_0(\varepsilon, n)$ for any $\varepsilon$ is $1$ plus the number of sorted entries exceeding $\varepsilon$, computable by binary search in $O(\log n)$. All window counts (Corollary 4.6), the twin count (Theorem 6.2) and the merge counts (Proposition 4.2) are two such queries each.

**Algorithm C (Exponential-law audit).** For a candidate mean $\mu$ compare, for each threshold $t$, the empirical count $\#\{i<n : g_i \le t\}$ with the prediction $n(1 - e^{-t/\mu})$. At $t < 2$ the empirical value is pinned at $1$ (Theorem 5.5), so the discrepancy is $\Theta(n)$ and the test rejects at every $\mu$; the audit also reports the smallest $n$ at which the prediction exceeds $1$, namely $n \ge \lceil 1/(1-e^{-2/\mu}) \rceil$.

**Algorithm D (Degree-one check).** For a small metric configuration, list the Rips edges and triangles at scale $\varepsilon$ and compute $\dim H_1 = (\#E - \mathrm{rank}\,\partial_1) - \mathrm{rank}\,\partial_2$ over $\mathbb{F}_2$ by Gaussian elimination on bit-vectors, in $O((\#E + \#T)\min(\#E,\#T)\,\#E/64)$ word operations. For prime windows the answer is always $0$ (Theorem 3.2); for the four-cycle metric it is $1$ (Theorem 3.4).

---

## 8. Numerical verification

Sieving to $X = 10^6$ yields $\pi(X) = 78\,498$ primes and $n = 78\,497$ bars.

| quantity | value |
|---|---|
| number of bars | $78\,497$ |
| mean bar length | $12.7391$ |
| $\log 10^6$ | $13.8155$ |
| longest bar | $114$, starting at $p = 492\,113$ |
| bars of odd length | $1$ (the bar from $2$ to $3$) |
| bars of length $< 2$ | $1$ |
| twin bars $T(n)$ | $8\,169$ |
| $b_0(2, n)$ | $70\,328$ |
| $b_0(2,n) + T(n)$ | $78\,497 = n$ ✓ |
| $b_0(1,n) - b_0(2,n)$ | $8\,169 = T(n)$ ✓ |
| total persistence | $999\,981 = p_{n+1} - 2$ ✓ |

The exponential-law audit: with $\mu = 12.7391$ (the empirical mean) the predicted number of bars shorter than $2$ is $78\,497 \times (1 - e^{-2/12.7391}) \approx 11\,405$; with $\mu = \log 10^6$ it is $\approx 10\,579$; with $\mu = 1000$ it is still $\approx 157$. The truth is $1$. For $\mu = 12.7391$, the prediction already exceeds $1$ at $n = 7$.

The merge identity was checked at $\varepsilon \in \{2, 4, 6, 12, 246\}$: for instance at $\varepsilon = 2$, defect $= 8\,170 =$ merge count; at $\varepsilon = 246$ all $78\,497$ bars have already merged, so the defect is $78\,497$ — consistent with the fact (Theorem 6.11) that at $10^6$ no gap yet exceeds $246$, while beyond $10^6$ infinitely many will.

Even-window rigidity: at $n = 20\,000$, $b_0$ is constant on $(2,4)$ (value $17\,629$), on $(4,6)$ ($15\,275$), on $(6,8)$ ($11\,467$), on $(20,22)$ ($2\,531$); the only odd-scale jump is at $1$, where $b_0$ drops from $20\,001$ to $20\,000$.

Interleaving: perturbing each of the first $5\,001$ primes by a uniform amount in $[-0.4, 0.4]$, the inequality $b_0^{\,\text{perturbed}}(\varepsilon + 0.8, n) \le b_0^{\,\text{prime}}(\varepsilon, n)$ holds at every tested scale.

Degree one: for the primes below $60$, $\dim H_1(\mathrm{R}_\varepsilon; \mathbb{F}_2) = 0$ at $\varepsilon \in \{2,4,6,8,14\}$ — indeed at every scale — while the four-cycle metric at scale $1$ has four edges, zero triangles and $\dim H_1 = 1$.

---

## 9. Discussion

The picture that emerges is of a barcode that is **topologically rigid but statistically non-Poisson**.

*Rigid*, in three senses. (i) It carries no information in degree one and never can, by a theorem about the line that is sharp at dimension one. (ii) Its degree-zero content is completely captured by the Betti curve, which is a lossless encoding of the gap multiset (Theorem 4.5); nothing is gained or lost by passing between bars and staircase. (iii) It is stable: a $\delta$-perturbation of the points moves the curve by at most $2\delta$ in scale, so all conclusions concern the *spacing* of the primes, not accidental features of their exact values.

*Non-Poisson*, for a reason that is structural rather than statistical: after the very first bar, every bar has even length, because $2$ is the only even prime. The barcode measure lives on a lattice, which no absolutely continuous law can charge. This is worth emphasising because the failure is often invisible in coarse statistics: the empirical mean bar length at $10^6$ is $12.74$ against a predicted $13.82$, an agreement good enough to lull one into accepting the model. The obstruction only becomes visible at the resolution of individual bar lengths — which is exactly the resolution at which persistent homology operates.

The positive content is the dictionary. Twin primes are a Betti defect at scale $2$; bounded gaps are a Betti defect at scale $246$; the elementary bound $p_n \ge 2n+1$ is the total-persistence inequality; and, in the other direction, the classical composite window $m!+2, \dots, m!+m$ becomes the assertion that the prime cloud is never connected. This dictionary does not, by itself, prove anything new about the primes: the topology is a faithful re-encoding, so a hard arithmetic statement remains a hard topological one. What it provides is a *coordinate system*. In it, the difference between what is known (bounded gaps: unbounded defect at scale $246$) and what is conjectured (twin primes: unbounded defect at scale $2$) is literally the value of a single parameter, and the natural interpolation — for which $B$ is the scale-$B$ defect unbounded? — is exactly the small-gaps programme.

A methodological remark. The mission that motivated this work conjectured a rich degree-one prime barcode with birth scale $\sim \log^2 x$. This was refuted for a dimensional reason. But the intuition behind it is not worthless: it is a *higher-dimensional* intuition applied to a one-dimensional embedding. Section 10 proposes the correct home for it.

---

## 10. Future directions

**Rescaled Cramér law for the even barcode.** Let $B_n(t) = \#\{ i < n : g_i \le t \log p_i \}/n$. Conjecture: $B_n(t) \to 1 - e^{-t}$ for every $t > 0$. The key insight is that the refutation of Section 5 is a statement about the *support* of the barcode measure (a lattice), not about its shape: dividing each bar by $\log p_i$ destroys the lattice while preserving the shape, so the Poisson prediction should be restated for the rescaled barcode and only then tested. Because the Betti curve is a complete invariant, this is equivalently a statement about the single explicit staircase $n^{-1}\big(n + 1 - b_0(t \log p_n, n)\big)$. The two elementary bounds — the lower bound conditionally on Hardy–Littlewood, the unconditional upper bound from Brun's sieve — are the natural first targets.

**Persistent homology in higher dimensions: the delay embedding.** Embed the primes in $\mathbb{R}^d$ by $\Phi_d(n) = (p_n, p_{n+1}, \dots, p_{n+d-1})$. Conjecture: for $d \ge 2$ the Rips filtration of $\Phi_d(\mathbb{N})$ has *nonvanishing* $H_1$, and the birth scale of its longest bar is $\asymp \log^2 x$ — matching the scale the original mission conjectured (wrongly) for the one-dimensional cloud. The key insight is that the $\log^2 x$ intuition was a dimensional one: correlations between *consecutive* gaps, invisible to a cloud on a line, become geometry in the delay embedding, and Hardy–Littlewood correlation constants should govern which loops appear.

**Interpolating the small-gaps programme topologically.** Define $B^\ast = \inf\{ B : \text{the scale-}B\text{ Betti defect is unbounded} \}$. Known: $B^\ast \le 246$. Conjectured: $B^\ast = 2$. Is there a topological route to lowering $B^\ast$ — for instance a monotonicity or interleaving argument relating defects at different scales, or a sieve statement most naturally phrased as a bound on a Betti curve rather than a counting function?

**Barcodes of other arithmetic clouds.** The framework applies verbatim to any increasing arithmetic sequence: primes in a fixed residue class, sums of two squares, smooth numbers, zeros of $\zeta$ on the critical line. Each has an atomicity signature (or none), a Betti staircase, and defects at distinguished scales; a comparative table of these signatures would be a compact way to read off how "lattice-like" versus "Poisson-like" each sequence is.

**Multiparameter persistence.** Filtering simultaneously by scale $\varepsilon$ and by position $x$ (the "prime number theorem direction") yields a two-parameter persistence module whose rank invariant is $b_0(\varepsilon, n)$ as a function of both variables. The rescaled Cramér law above is then a statement about the *shape of the fibered barcode along the curve* $\varepsilon = t \log x$, and multiparameter invariants may be the right language for the interaction between the two directions.

---

## 11. Conclusion

The primes, viewed as a point cloud on the line, have a shape, and we have determined it. In degree one there is nothing, for a reason that is a theorem about lines and is sharp at dimension one. In degree zero the barcode is the gap sequence; its Betti curve is a complete, stable invariant, constant between consecutive even scales; its bar lengths are pinned to the lattice $\{1\} \cup 2\mathbb{N}$, which rules out the exponential law for every mean and quantitatively so; its total persistence is $p_n - 2$, whose atomic lower bound is the inequality $p_n \ge 2n+1$; and its defects at fixed finite scales are precisely the twin prime counting function ($\varepsilon = 2$) and the bounded-gaps phenomenon ($\varepsilon = 246$). At every scale the cloud shatters into arbitrarily many components.

The primes are not random, and their barcode says so in one line of parity. What remains random-looking about them survives the rescaling by $\log x$ — and that is where the topology now points.
