# The Probabilistic Method as Finite Counting: De-randomised Ramsey, Turán, Caro–Wei, Local Lemma and MAX-CUT Bounds

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The probabilistic method establishes the existence of combinatorial structures by exhibiting a probability distribution under which the desired property holds with positive probability. We show that, for the classical finite landmarks of the method, the probability space is dispensable: each theorem can be re-derived as a statement about finite cardinalities, a greedy algorithm, or a local-search procedure, and the resulting arguments are in several cases both simpler and quantitatively stronger than their probabilistic ancestors.

We develop five threads. (i) Erdős's lower bound $R(k,k) > 2^{k/2}$ is obtained as a strict inequality between two integers — the number of colourings of $K_n$ that are monochromatic on some $k$-set, versus the total number $2^{\binom{n}{2}}$ of colourings — the analytic core being the elementary estimate $2^{k+2} < (k!)^2$ for $k \ge 3$. (ii) The deletion method is realised as a double count over all colourings together with an explicit minimum-element transversal, yielding $R(k,k) > n - t$ whenever $2\binom{n}{k} < (t+1)2^{\binom{k}{2}}$; at $k=6$ this gives $R(6,6) > 18$, strictly beyond the reach of the union bound, which already fails at $n=18$. Combined with the Erdős–Szekeres recursion this produces the two-sided sandwich $2^{k/2} < R(k,k) \le 4^{k-1}$. (iii) The Caro–Wei inequality $\alpha(G) \ge \sum_v 1/(\deg v + 1)$ — classically proved by a random vertex ordering — is proved by minimum-degree greedy deletion, and yields $\alpha(G)\ge n/(\Delta+1)$, $\alpha(G) \ge n^2/(2m+n)$, Turán's theorem $m \le (1-1/r)n^2/2$ for $K_{r+1}$-free graphs on an arbitrary finite vertex type with no divisibility hypothesis, and the off-diagonal bound $R(3,k+1) > k^2$. (iv) An exact count of the Turán graph gives the subtraction-free identity $2r\,e(T(n,r)) + s(r-s) = (r-1)n^2$ with $s = n \bmod r$, hence the exact extremal number $\mathrm{ex}(n,K_{r+1}) = ((r-1)n^2 - s(r-s))/(2r)$ for all $n$ and $r\ge 1$; as a consequence the widely quoted floor formula $\lfloor(1-1/r)n^2/2\rfloor$ is correct precisely when $s(r-s) < 2r$, and fails first at $n=12$, $r=8$, where the true value is $62$ and the floor formula predicts $63$. (v) The Lovász Local Lemma, in both asymmetric (lopsided) and symmetric $e\,p\,(d+1)\le 1$ forms, is established in a finite weighted probability space by the Erdős–Lovász double induction; because such a space is a finite set, the conclusion "positive probability" is literally "non-empty", and a terminating exhaustive search is certified to return a good sample point. We also treat MAX-CUT, where a finite averaging identity and a local-search exchange identity each yield $m \le 2\cdot\mathrm{cut}$, and where the maximum cut of $K_n$ is shown to equal $e(T(n,2))$, linking the MAX-CUT and Turán threads.

**Keywords:** probabilistic method, Ramsey numbers, Turán's theorem, Caro–Wei inequality, Lovász Local Lemma, de-randomisation, deletion method, MAX-CUT.

---

## 1. Introduction

### 1.1 The method and its reputation

The probabilistic method, inaugurated by Erdős in 1947 and systematised by Alon and Spencer, proves that an object with property $P$ exists by placing a probability measure on a space of candidates and showing $\mathbb{P}[P] > 0$. It is spectacularly effective, and it is universally described as *non-constructive*: the proof does not produce the object.

This description conflates two things.

* **Finitary non-constructivity.** The proof uses averaging rather than explicit construction. This is a feature of the *presentation*, not of the mathematics: if the sample space is finite, "positive probability" is the assertion that a certain finite set is non-empty, and the argument reduces to a comparison of integers.
* **Computational non-constructivity.** The search implied by the argument is exponential and no efficient algorithm is known. This is a genuine obstruction, and for Ramsey colourings it remains open.

The present work is a systematic study of the first phenomenon. For each classical application we exhibit a finitary avatar of the probabilistic argument and, wherever possible, an explicit algorithm.

### 1.2 Contributions

1. A uniform *counting* framework in which a two-colouring of $K_n$ is a subset of the pair set, and the union bound is the subadditivity of cardinality on a union of finite sets (§2).
2. The de-randomised Erdős bound $R(k,k) > 2^{k/2}$ and the arithmetic engine $2^{k+2} < (k!)^2$ (§2).
3. The deletion method as a double count plus an explicit minimum-element transversal, with an exact quantitative gain at $k=6$ (§3).
4. A greedy proof of Caro–Wei relativised to arbitrary vertex subsets, and the resulting cascade of corollaries including a hypothesis-free Turán bound (§4).
5. The exact Turán edge identity, the exact extremal number for all $n,r$, and a counterexample to the floor formula (§5).
6. The Lovász Local Lemma in a finite weighted probability space, with a certified terminating search (§6).
7. MAX-CUT by finite averaging and by local search, with the identity $\mathrm{maxcut}(K_n) = e(T(n,2))$ (§7).
8. Erdős's property B theorem, obtained by re-using the counting lemmas of §2 verbatim (§8).

### 1.3 Notation

$G = (V,E)$ is a finite simple graph, $n = |V|$, $m = |E|$; $\deg(v)$ is the degree of $v$, $\Delta$ the maximum degree, $\alpha(G)$ the independence number (largest set of pairwise non-adjacent vertices), $\omega(G)$ the clique number, $G^c$ the complement. $G$ is *$K_j$-free* if it contains no clique on $j$ vertices. $T(n,r)$ denotes the Turán graph: $V$ is split into $r$ classes of sizes as equal as possible and two vertices are adjacent iff they lie in different classes. $\binom{n}{k}$ is a binomial coefficient. $R(k,k)$ is the diagonal Ramsey number: the least $m$ such that every graph on $m$ vertices contains a clique or an independent set of size $k$.

---

## 2. Ramsey's lower bound as an inequality between integers

### 2.1 Colourings as subsets

Let $\mathrm{Pairs}(n)$ be the set of all two-element subsets of $\{0,\dots,n-1\}$, so $|\mathrm{Pairs}(n)| = \binom{n}{2}$, and for $K \subseteq \{0,\dots,n-1\}$ let $\mathrm{Pairs}(K)$ be the two-element subsets of $K$, of cardinality $\binom{|K|}{2}$.

**Definition 2.1 (Colouring).** A *two-colouring* of $K_n$ is a subset $S \subseteq \mathrm{Pairs}(n)$ — the red edges; the rest are blue. There are exactly $2^{\binom{n}{2}}$ colourings.

**Definition 2.2 (Monochromatic set).** $S$ is *monochromatic on* $K$ if $\mathrm{Pairs}(K) \subseteq S$ or $\mathrm{Pairs}(K) \cap S = \varnothing$.

The whole of §2 rests on two counting lemmas that are instances of a single bijection.

**Lemma 2.3 (Supersets).** For finite sets $T \subseteq E$, the number of subsets of $E$ containing $T$ is $2^{|E|-|T|}$.

**Lemma 2.4 (Disjoint sets).** For finite sets $T \subseteq E$, the number of subsets of $E$ disjoint from $T$ is $2^{|E|-|T|}$.

*Proof of both.* The map $S \mapsto S \setminus T$ (resp. $S\mapsto S$) is a bijection from the family in question onto the power set of $E \setminus T$. $\square$

**Lemma 2.5 (Bad colourings for one $k$-set).** For $|K| = k$ with $K$ inside the vertex set, the number of colourings monochromatic on $K$ is at most $2\cdot 2^{\binom{n}{2} - \binom{k}{2}}$.

*Proof.* The family splits into the colourings containing $\mathrm{Pairs}(K)$ and those disjoint from it; apply Lemmas 2.3 and 2.4 with $E = \mathrm{Pairs}(n)$, $T = \mathrm{Pairs}(K)$, and add. $\square$

**Lemma 2.6 (Union bound).** The number of colourings monochromatic on *some* $k$-set is at most $\binom{n}{k}\cdot 2 \cdot 2^{\binom{n}{2}-\binom{k}{2}}$.

*Proof.* The family is the union, over the $\binom{n}{k}$ many $k$-subsets $K$, of the families of Lemma 2.5; the cardinality of a union of finite sets is at most the sum of their cardinalities. $\square$

Lemma 2.6 is the counting shadow of the probabilistic union bound. No measure is involved: it is the subadditivity of cardinality.

### 2.2 The expectation argument, de-randomised

**Theorem 2.7 (Existence of a good colouring).** Let $k \le n$ and suppose $2\binom{n}{k} < 2^{\binom{k}{2}}$. Then some colouring of $K_n$ is monochromatic on no $k$-set.

*Proof.* By Lemma 2.6 the bad colourings number at most $\binom{n}{k}\,2\,2^{\binom{n}{2}-\binom{k}{2}}$. Multiplying the hypothesis by $2^{\binom{n}{2}-\binom{k}{2}}$ gives that this is strictly less than $2^{\binom{n}{2}}$, the total. A proper subfamily of a finite family cannot be all of it. $\square$

**Theorem 2.8 (Graph form).** Under the hypothesis of Theorem 2.7 there is a graph $G$ on $n$ vertices with both $G$ and $G^c$ being $K_k$-free.

*Proof.* Let $G$ have edge set the red pairs of a good colouring $S$. A $k$-clique of $G$ is a $k$-set all of whose pairs are red, so $S$ is monochromatic there; a $k$-clique of $G^c$ likewise gives a $k$-set with no red pair. Both are excluded. $\square$

### 2.3 The arithmetic engine

**Theorem 2.9.** For every $k \ge 3$, $\;2^{k+2} < (k!)^2$.

*Proof.* Induction. Base $k=3$: $32 < 36$. Step: multiplying the left side by $2$ and the right by $(k+1)^2 \ge 16$ preserves the strict inequality. $\square$

Equivalently $2\cdot 2^{k/2} < k!$, which is exactly the inequality needed to make the counting hypothesis hold up to $n = 2^{k/2}$.

**Theorem 2.10 (Counting hypothesis from the size bound).** If $k \ge 3$ and $n^2 \le 2^k$ then $2\binom{n}{k} < 2^{\binom{k}{2}}$.

*Proof sketch.* Bound $\binom{n}{k} \le n^k/k!$ and $n^k \le 2^{k^2/2}$, and note $\binom{k}{2} = k^2/2 - k/2$; the deficit $2^{k/2}$ is absorbed by $k!/2 > 2^{k/2}$, which is Theorem 2.9. $\square$

**Theorem 2.11 (Erdős, 1947, de-randomised).** If $3\le k$ and $n^2 \le 2^k$ (i.e. $n \le 2^{k/2}$) and $k \le n$, then there is a graph on $n$ vertices such that neither it nor its complement contains a $K_k$.

*Proof.* Theorem 2.10 then Theorem 2.8. $\square$

**Definition 2.12.** Say $m$ *is Ramsey for $k$*, written $\mathrm{IsRamsey}(m,k)$, if every graph on $m$ vertices contains a clique of size $k$ or an independent set of size $k$.

Ramsey witnesses are monotone downward: if $m \le n$ and some graph on $n$ vertices has both it and its complement $K_k$-free, then $m$ is not Ramsey for $k$ (restrict along an injection).

**Corollary 2.13 ($R(k,k) > 2^{k/2}$).** If $3 \le k$, $n^2 \le 2^k$ and $\mathrm{IsRamsey}(m,k)$, then $n < m$.

---

## 3. The deletion method

### 3.1 Double counting and averaging

For a colouring $S$ let $\mathrm{mono}_k(S)$ be the number of $k$-sets on which $S$ is monochromatic.

**Lemma 3.1 (Double count).** $\displaystyle \sum_{S} \mathrm{mono}_k(S) \;=\; \sum_{|K| = k} \#\{S : S \text{ monochromatic on } K\} \;\le\; \binom{n}{k}\cdot 2\cdot 2^{\binom{n}{2}-\binom{k}{2}},$ the sums ranging over all $2^{\binom{n}{2}}$ colourings and all $k$-subsets $K$ respectively.

*Proof.* Both sides count pairs $(S,K)$ with $S$ monochromatic on $K$; then apply Lemma 2.5. $\square$

**Theorem 3.2 (Averaging).** If $k \le n$ and $2\binom{n}{k} < (t+1)2^{\binom{k}{2}}$, then some colouring $S$ has $\mathrm{mono}_k(S) \le t$.

*Proof.* Otherwise every colouring has at least $t+1$ bad sets, so the left side of Lemma 3.1 is at least $(t+1)2^{\binom{n}{2}}$, contradicting the hypothesis after multiplying it by $2^{\binom{n}{2}-\binom{k}{2}}$. $\square$

### 3.2 An explicit transversal

The step usually phrased "choose one vertex from each bad set" needs no choice principle when the ground set is linearly ordered.

**Lemma 3.3 (Minimum-element transversal).** Let $B$ be a finite family of non-empty finite subsets of a linearly ordered finite set. Put $T = \{\min K : K \in B\}$. Then $|T| \le |B|$ and $T \cap K \ne \varnothing$ for every $K \in B$.

*Proof.* $T$ is the image of $B$ under $\min$, hence no larger; and $\min K \in T \cap K$. $\square$

### 3.3 The bound

**Theorem 3.4 (Deletion method).** Let $1 \le k \le n$ and $2\binom{n}{k} < (t+1)2^{\binom{k}{2}}$. Then there is a two-colouring of the complete graph on $n-t$ vertices with no monochromatic $k$-set; equivalently there is a graph $G$ on $n-t$ vertices with $G$ and $G^c$ both $K_k$-free. Hence $R(k,k) > n-t$.

*Proof.* Take $S$ with $\mathrm{mono}_k(S)\le t$ (Theorem 3.2) and let $B$ be its family of bad $k$-sets. Lemma 3.3 gives $T$ with $|T| \le t$ meeting every member of $B$. Set $W = V \setminus T$, so $|W| \ge n-t$. No $k$-subset of $W$ is monochromatic, since such a subset would lie in $B$ and hence meet $T$. Choose an order-embedding of $\{0,\dots,n-t-1\}$ into a $(n-t)$-subset of $W$ and pull back the colouring along it: cliques of the pull-back and of its complement map to monochromatic $k$-subsets of $W$. $\square$

Taking $t = 0$ recovers Theorem 2.8, so the deletion bound is a strict generalisation.

**Proposition 3.5 (An exact gain at $k=6$).** $2\binom{19}{6} = 54264 < 65536 = 2\cdot 2^{\binom{6}{2}}$, so Theorem 3.4 with $n=19$, $t=1$ produces a graph on $18$ vertices with $G$, $G^c$ both $K_6$-free, i.e. $R(6,6) > 18$. By contrast the union bound of Theorem 2.7 is unavailable at $n=18$: $2\binom{18}{6} = 37128 \ge 32768 = 2^{\binom{6}{2}}$.

### 3.4 The upper bound and the sandwich

**Theorem 3.6 (Erdős–Szekeres).** If a vertex set $W$ has at least $\binom{s+t}{s}$ elements, then every graph on $W$ contains a clique of size $s+1$ or an independent set of size $t+1$.

*Proof sketch.* Induction on $s+t$. Fix $v \in W$; its neighbourhood or its non-neighbourhood is large enough (since $\binom{s+t}{s} = \binom{s+t-1}{s-1} + \binom{s+t-1}{s}$, one of the two parts has at least the corresponding size) to apply the induction hypothesis, and $v$ extends the resulting clique or independent set. $\square$

**Corollary 3.7.** $\mathrm{IsRamsey}\big(\binom{2k-2}{k-1}, k\big)$ holds for $k \ge 1$, and since $\binom{2m}{m}\le 4^m$ (immediate induction, or from $\sum_j \binom{2m}{j} = 4^m$), $R(k,k) \le 4^{k-1}$.

**Theorem 3.8 (Ramsey sandwich).** For $k \ge 3$ and $n^2 \le 2^k$: $\;n < R(k,k) \le 4^{k-1}$. In particular $2^{k/2} < R(k,k) \le 4^{k-1}$.

---

## 4. Caro–Wei by greedy deletion

### 4.1 Relative degrees

**Definition 4.1.** For a vertex subset $t \subseteq V$ let $\deg_t(v) = |\{w \in t : v \sim w\}|$, the degree of $v$ *measured inside* $t$. Then $\deg_V(v) = \deg(v)$, and $t' \subseteq t$ implies $\deg_{t'}(v) \le \deg_t(v)$.

**Definition 4.2.** The *closed neighbourhood of $v$ inside $t$* is $B_t(v) = \{v\} \cup \{w \in t : v \sim w\}$; if $v \in t$ then $B_t(v) \subseteq t$ and $|B_t(v)| = \deg_t(v)+1$ (using that $v$ is not adjacent to itself).

### 4.2 The induction

**Theorem 4.3 (Relative Caro–Wei).** For every $t \subseteq V$ there is an independent set $s \subseteq t$ with
$$\sum_{v \in t} \frac{1}{\deg_t(v)+1} \;\le\; |s|.$$

*Proof.* Strong induction on $|t|$. If $t = \varnothing$ take $s = \varnothing$. Otherwise choose $v \in t$ minimising $\deg_t$, put $d = \deg_t(v)$ and $B = B_t(v)$, so $|B| = d+1$ and $B \subseteq t$. The set $t \setminus B$ is a proper subset of $t$ (it omits $v$), so the induction hypothesis yields an independent $s' \subseteq t\setminus B$ with $\sum_{u \in t\setminus B} 1/(\deg_{t\setminus B}(u)+1) \le |s'|$.

*Independence of $s := \{v\}\cup s'$.* Every $u \in s'$ lies outside $B$, hence $u \ne v$ and $u\not\sim v$; and $s'$ is independent. Non-adjacency is symmetric, so $s$ is independent, and $v \notin s'$ gives $|s| = |s'|+1$.

*Counting.* Split the sum over $t$ as the sum over $t\setminus B$ plus the sum over $B$. For $u \in B \subseteq t$ minimality gives $\deg_t(u)\ge d$, hence $1/(\deg_t(u)+1) \le 1/(d+1)$, so the $B$-block contributes at most $|B|/(d+1) = 1$. For $u \in t\setminus B$ monotonicity of relative degree gives $\deg_{t\setminus B}(u)\le \deg_t(u)$, hence $1/(\deg_t(u)+1) \le 1/(\deg_{t\setminus B}(u)+1)$, so the $(t\setminus B)$-block is at most $|s'|$. Therefore the total is at most $|s'| + 1 = |s|$. $\square$

The proof is literally the greedy algorithm: pick a minimum-degree vertex, output it, delete its closed neighbourhood, recurse.

**Theorem 4.4 (Caro–Wei).** $\displaystyle \sum_{v\in V} \frac{1}{\deg(v)+1} \;\le\; \alpha(G).$

*Proof.* Apply Theorem 4.3 with $t=V$, note $\deg_V = \deg$, and that the size of any independent set is at most $\alpha(G)$. $\square$

### 4.3 Corollaries

**Corollary 4.5 (Maximum-degree bound).** $\displaystyle \alpha(G) \ge \frac{n}{\Delta+1}.$

*Proof.* $\deg(v)\le\Delta$ termwise, so $n/(\Delta+1) = \sum_v 1/(\Delta+1) \le \sum_v 1/(\deg(v)+1) \le \alpha(G)$. $\square$

Equivalently, in integers, $n \le \alpha(G)\,(\Delta+1)$.

**Lemma 4.6 (Sedrakyan / Cauchy–Schwarz).** For positive reals $a_1,\dots,a_n$: $\displaystyle \sum_i \frac{1}{a_i} \ge \frac{n^2}{\sum_i a_i}$.

**Corollary 4.7 (Turán's independence bound).** $\displaystyle \alpha(G) \ge \frac{n^2}{2m+n}.$

*Proof.* Apply Lemma 4.6 with $a_v = \deg(v)+1$; the handshake identity $\sum_v \deg(v) = 2m$ gives $\sum_v a_v = 2m+n$. Combine with Theorem 4.4. $\square$

### 4.4 Turán's theorem via the complement

**Lemma 4.8.** If $G$ is $K_{r+1}$-free then $\omega(G)\le r$, hence $\alpha(G^c) = \omega(G) \le r$.

**Theorem 4.9 (Turán's theorem, greedy proof).** Let $r \ge 1$ and let $G$ be a $K_{r+1}$-free graph on a finite vertex set of size $n$. Then
$$m \;\le\; \left(1-\frac{1}{r}\right)\frac{n^2}{2}.$$
No divisibility hypothesis and no structural assumption on the vertex set are required.

*Proof.* For $n = 0$ both sides vanish. Otherwise, in $G^c$ each vertex has $\deg_{G^c}(v) = n-1-\deg_G(v)$, so
$$\sum_v \big(\deg_{G^c}(v)+1\big) = n^2 - 2m,$$
which is positive (it is a sum of positive terms). Sedrakyan's inequality applied to $a_v = \deg_{G^c}(v)+1$ gives
$$\frac{n^2}{n^2-2m} \;\le\; \sum_v \frac{1}{\deg_{G^c}(v)+1} \;\le\; \alpha(G^c) \;\le\; r,$$
the middle step being Caro–Wei on $G^c$ and the last Lemma 4.8. Hence $n^2 \le r(n^2-2m)$, i.e. $2rm \le (r-1)n^2$, which is the claim. $\square$

**Proposition 4.10 (Sharpness).** For $r=2$, $n=4$ the four-cycle (which is $T(4,2)$) is triangle-free with exactly $4$ edges, while $(1-\tfrac12)\cdot\tfrac{16}{2} = 4$. Thus the constant cannot be improved. Its maximum degree is $2$, so the corollary $\alpha \ge n/(\Delta+1) = 4/3$ is strict there ($\alpha = 2$): the loss is exactly the convexity slack in Sedrakyan's inequality.

### 4.5 An off-diagonal Ramsey bound with no probability

**Lemma 4.11.** If $G$ is triangle-free then $\Delta \le \alpha(G)$, because the neighbourhood of any vertex is an independent set.

**Theorem 4.12.** If $G$ is triangle-free then $n \le \alpha(G)\big(\alpha(G)+1\big)$; equivalently $\alpha(G) \ge \sqrt{n} - 1$.

*Proof.* $n \le \alpha(\Delta+1) \le \alpha(\alpha+1)$ by Corollary 4.5 and Lemma 4.11. $\square$

**Corollary 4.13 ($R(3,k+1) > k^2$).** Every graph on more than $k(k+1)$ vertices contains a triangle or an independent set of size $k+1$.

*Proof.* If it is triangle-free with $\alpha \le k$ then $n \le \alpha(\alpha+1)\le k(k+1)$, a contradiction. $\square$

---

## 5. The Turán graph, counted exactly

The bound of Theorem 4.9 is clean but, when $r \nmid n$, not attained. This section computes the truth.

### 5.1 Class sizes and the edge identity

Let $T(n,r)$ have vertex set $\{0,\dots,n-1\}$ with $u \sim v$ iff $u \not\equiv v \pmod r$; the classes are the residue classes mod $r$.

**Lemma 5.1 (Class sizes).** Write $n = qr+s$ with $s = n\bmod r$, $0 \le s < r$. Then class $i$ has $q+1$ elements if $i < s$ and $q$ elements otherwise. Consequently
$$\sum_{i<r} |C_i|^2 = s(q+1)^2 + (r-s)q^2 .$$

**Lemma 5.2 (Complete multipartite count).** For any partition of $n$ vertices into classes $C_0,\dots,C_{r-1}$, the complete multipartite graph on them satisfies
$$2\,e + \sum_i |C_i|^2 = n^2 .$$

*Proof.* Count ordered pairs $(u,v)$ of distinct-or-equal vertices: $n^2$ in total, of which $\sum_i |C_i|^2$ lie inside a class and the remaining $2e$ are the two orientations of the edges. $\square$

**Theorem 5.3 (Exact Turán edge identity).** For all $n$ and all $r \ge 1$, with $s = n \bmod r$,
$$2r\,e\big(T(n,r)\big) + s(r-s) \;=\; (r-1)\,n^2 .$$
The identity is subtraction-free (all quantities are natural numbers), and the correction term $s(r-s)$ vanishes exactly when $r \mid n$.

*Proof.* Substitute Lemma 5.1 into Lemma 5.2 and clear denominators using $n = qr+s$: expanding $s(q+1)^2+(r-s)q^2 = rq^2+2qs+s$ and $n^2 = (qr+s)^2$, one obtains $2r\,e = (r-1)n^2 - s(r-s)$ after elementary algebra. $\square$

**Corollary 5.4 (Real form).** $\displaystyle e\big(T(n,r)\big) = \left(1-\frac1r\right)\frac{n^2}{2} \;-\; \frac{s(r-s)}{2r},$ and equality with the clean value $\left(1-\frac1r\right)\frac{n^2}{2}$ holds **iff** $r \mid n$ (since $0\le s<r$ makes $s(r-s) = 0$ equivalent to $s=0$).

### 5.2 The exact extremal number

**Theorem 5.5 (Turán's theorem, exactly).** For every $n$ and every $r \ge 1$,
$$\mathrm{ex}(n, K_{r+1}) \;=\; \frac{(r-1)n^2 - s(r-s)}{2r}, \qquad s = n \bmod r,$$
and the value is attained by $T(n,r)$. That is, $T(n,r)$ is $K_{r+1}$-free with this many edges, and every $K_{r+1}$-free graph on $n$ vertices has at most this many.

*Proof.* $T(n,r)$ is $r$-partite hence $K_{r+1}$-free, and Theorem 5.3 gives its edge count in the stated closed form (division by $2r$ is exact). Maximality is the structural half of Turán's theorem: $T(n,r)$ maximises the edge count among $K_{r+1}$-free graphs on $n$ vertices. $\square$

### 5.3 The floor formula and where it fails

**Theorem 5.6.** For $r \ge 1$, $\;e\big(T(n,r)\big) = \left\lfloor \dfrac{(r-1)n^2}{2r} \right\rfloor$ **iff** $\;s(r-s) < 2r$.

*Proof.* By Theorem 5.3, $\lfloor (r-1)n^2/(2r)\rfloor = e(T(n,r)) + \lfloor s(r-s)/(2r)\rfloor$, and the second term vanishes iff $s(r-s)<2r$. $\square$

**Corollary 5.7 (Counterexample).** At $n=12$, $r=8$ we have $s = 4$ and $s(r-s) = 16 = 2r$, so the criterion fails: $e(T(12,8)) = 62$ while $\lfloor 7\cdot 144/16\rfloor = 63$. Hence the commonly quoted floor formula for the extremal number is false in general.

**Proposition 5.8 (First failure).** For every $r < 8$ and every $n$, $e(T(n,r)) = \lfloor (r-1)n^2/(2r)\rfloor$. Indeed with $s+t = r$, $s,t \ge 0$ and $r \le 7$, one always has $st < 2r$ (finite check over $s,t \le 7$). So $r=8$ is exactly the first modulus at which the extremal number can fall strictly below the floor of the clean value.

### 5.4 An integer-convexity route

An independent derivation of the same bound uses only integer convexity.

**Lemma 5.9.** Among all decompositions $n = c_0 + \dots + c_{r-1}$ into $r$ natural numbers, $\sum_i c_i^2$ is minimised by the balanced decomposition; in particular $r\sum_i c_i^2 \ge n^2$.

**Theorem 5.10 (Turán for $r$-colourable graphs, in integers).** If $G$ admits a proper $r$-colouring with class sizes $c_i$, then $2m + \sum_i c_i^2 \le n^2$, and hence $2rm \le (r-1)n^2$; equality forces balanced classes and a complete multipartite graph. Consequently $e(G) \le e(T(n,r))$ for every $r$-colourable $G$ on $n$ vertices, and $e(T(n,r))$ is the greatest such value.

---

## 6. The Lovász Local Lemma in a finite weighted space

### 6.1 The setting

**Definition 6.1 (Finite weighted probability space).** A finite type $\Omega$ together with weights $w : \Omega \to \mathbb{R}_{\ge 0}$ satisfying $\sum_{\omega} w(\omega) = 1$. The *probability* of an event $E \subseteq \Omega$ is $\mathbb{P}(E) = \sum_{\omega \in E} w(\omega)$.

This is a purely finitary object: monotonicity, $\mathbb{P}(\Omega)=1$, $\mathbb{P}(\varnothing)=0$ and the difference rule $\mathbb{P}(E \setminus F) = \mathbb{P}(E)-\mathbb{P}(E\cap F)$ are all finite-sum identities.

**Definition 6.2 (Avoidance event).** For bad events $A_i \subseteq \Omega$ indexed by a finite set $I$ and $S \subseteq I$, put $\mathrm{Av}(S) = \{\omega : \forall i \in S,\ \omega \notin A_i\}$.

### 6.2 The double induction

**Theorem 6.3 (Core estimate).** Let $\Gamma : I \to \mathcal{P}(I)$ be dependency sets and $x : I \to [0,1)$. Assume

* **(one-sided independence)** for all $i$ and all $S \subseteq I$ with $i \notin S$ and $S \cap \Gamma(i) = \varnothing$,
 $$\mathbb{P}\big(A_i \cap \mathrm{Av}(S)\big) \le \mathbb{P}(A_i)\,\mathbb{P}\big(\mathrm{Av}(S)\big);$$
* **(weight condition)** $\mathbb{P}(A_i) \le x_i \prod_{j \in \Gamma(i)} (1-x_j)$ for all $i$.

Then for every $S \subseteq I$ and every $i \notin S$,
$$\mathbb{P}\big(A_i \cap \mathrm{Av}(S)\big) \;\le\; x_i\,\mathbb{P}\big(\mathrm{Av}(S)\big).$$

*Proof sketch.* Induction on $|S|$. Split $S = S_1 \sqcup S_2$ with $S_1 = S \cap \Gamma(i)$ and $S_2 = S \setminus \Gamma(i)$. If $S_1 = \varnothing$ the one-sided hypothesis and the weight condition finish directly. Otherwise write
$$\mathbb{P}\big(A_i\cap \mathrm{Av}(S)\big) = \frac{\mathbb{P}\big(A_i \cap \mathrm{Av}(S_1)\cap\mathrm{Av}(S_2)\big)}{\mathbb{P}(\mathrm{Av}(S_2))}\cdot \mathbb{P}(\mathrm{Av}(S_2))$$
schematically, and bound the two factors separately: the numerator by $\mathbb{P}(A_i\cap \mathrm{Av}(S_2)) \le \mathbb{P}(A_i)\mathbb{P}(\mathrm{Av}(S_2))$ (one-sided independence, as $S_2$ misses $\Gamma(i)$), and the denominator from below by $\prod_{j \in S_1}(1-x_j)\,\mathbb{P}(\mathrm{Av}(S_2))$, which is the induction hypothesis applied one index of $S_1$ at a time. The weight condition then converts $\mathbb{P}(A_i)/\prod_{j\in S_1}(1-x_j)$ into $x_i$, since $S_1 \subseteq \Gamma(i)$ and each $1-x_j \in (0,1]$. $\square$

**Theorem 6.4 (General, asymmetric, lopsided Local Lemma).** Under the hypotheses of Theorem 6.3,
$$\mathbb{P}\Big(\bigcap_{i \in I} \overline{A_i}\Big) \;\ge\; \prod_{i\in I}(1-x_i) \;>\; 0 .$$

*Proof.* Peel the indices off one at a time: repeated application of Theorem 6.3 in the form $\mathbb{P}(\mathrm{Av}(S \cup \{i\})) \ge (1-x_i)\mathbb{P}(\mathrm{Av}(S))$ starting from $\mathrm{Av}(\varnothing) = \Omega$. Positivity holds because each $x_i < 1$. $\square$

### 6.3 The symmetric form

**Lemma 6.5.** For $D \ge 1$, $\left(\dfrac{D}{D+1}\right)^{D} \ge e^{-1}$, a consequence of $1+x \le e^x$.

**Theorem 6.6 (Symmetric Local Lemma).** Suppose $\mathbb{P}(A_i) \le p$ for all $i$, $|\Gamma(i)| \le d$ for all $i$, the one-sided independence hypothesis holds, $p \ge 0$, and
$$e\,p\,(d+1) \;\le\; 1 .$$
Then there is $\omega \in \Omega$ with $\omega \notin A_i$ for every $i$.

*Proof.* Set $D = \max(d,1)$ and $x_i = 1/(D+1)$ for all $i$. Then
$$x_i \prod_{j\in\Gamma(i)}(1-x_j) \;\ge\; \frac{1}{D+1}\left(\frac{D}{D+1}\right)^{d} \;\ge\; \frac{1}{e(d+1)} \;\ge\; p \;\ge\; \mathbb{P}(A_i),$$
using Lemma 6.5. Apply Theorem 6.4: the avoidance event has positive probability, hence is non-empty. $\square$

### 6.4 The existence proof is an algorithm

**Definition 6.7 (Exhaustive search).** $\mathrm{search}(A)$ enumerates $\Omega$ and returns the first $\omega$ lying in $\mathrm{Av}(I)$, or *failure* if there is none.

**Proposition 6.8 (Soundness).** Whatever $\mathrm{search}(A)$ returns avoids every bad event.

**Theorem 6.9 (Completeness).** Under the hypotheses of Theorem 6.4 (in particular under the symmetric condition $e\,p\,(d+1)\le 1$), $\mathrm{search}(A)$ never fails.

*Proof.* Theorem 6.4 gives $\mathbb{P}(\mathrm{Av}(I)) > 0$; a finite set of weight $0$ would be empty, so $\mathrm{Av}(I) \ne \varnothing$ and the enumeration finds a member. $\square$

This is the precise sense in which the Local Lemma is "an algorithm in disguise": it is a *termination certificate* for a deterministic finite search. The search is exponential in $|\Omega|$; making it efficient is the content of the Moser–Tardos resampling algorithm, which we discuss in §9.

---

## 7. MAX-CUT: averaging and local search

Let $G$ be a finite graph and for $S \subseteq V$ let $\mathrm{cut}(S)$ be the number of edges with exactly one endpoint in $S$.

### 7.1 Finite averaging

**Theorem 7.1 (Exact averaging identity).** $\displaystyle \sum_{S \subseteq V} \mathrm{cut}(S) \;=\; 2m\cdot 2^{\,n-2},$ i.e. the average cut over all $2^n$ bipartitions is exactly $m/2$.

*Proof.* Count triples: for each ordered adjacent pair $(u,v)$, the subsets $S$ with $u \in S$, $v \notin S$ number $2^{n-2}$; summing over the $2m$ ordered adjacent pairs gives the total. $\square$

**Corollary 7.2.** Some $S$ satisfies $m \le 2\,\mathrm{cut}(S)$; hence the exhaustive maximum $\mathrm{maxcut}(G) = \max_S \mathrm{cut}(S)$ satisfies $m \le 2\,\mathrm{maxcut}(G)$.

### 7.2 Local search

**Definition 7.3.** For $v \in V$ let $\mathrm{flip}(S,v)$ move $v$ to the other side, and let $c_S(v)$ be the number of neighbours of $v$ on the opposite side from $v$.

**Theorem 7.4 (Exchange identity).** $\;\mathrm{cut}(\mathrm{flip}(S,v)) + 2\,c_S(v) \;=\; \mathrm{cut}(S) + \deg(v)$, i.e. flipping $v$ changes the cut by exactly $\deg(v) - 2c_S(v)$.

*Proof.* Edges not incident to $v$ are unaffected. Among the $\deg(v)$ edges at $v$, exactly $c_S(v)$ are cut before the flip and $\deg(v)-c_S(v)$ afterwards. $\square$

**Definition 7.5.** $S$ is *locally maximal* if $\mathrm{cut}(\mathrm{flip}(S,v)) \le \mathrm{cut}(S)$ for every $v$.

**Theorem 7.6 (Local optima are 2-approximate).** If $S$ is locally maximal then $m \le 2\,\mathrm{cut}(S)$.

*Proof.* Theorem 7.4 with local maximality gives $\deg(v) \le 2c_S(v)$ for every $v$. Summing, and using the handshake identity $\sum_v \deg(v) = 2m$ together with the double count $\sum_v c_S(v) = 2\,\mathrm{cut}(S)$ (each cut edge is counted at both endpoints), yields $2m \le 4\,\mathrm{cut}(S)$. $\square$

**Theorem 7.7 (Termination with an explicit bound).** Any strictly improving run $S_0, S_1, \dots$ of local search — that is, with $\mathrm{cut}(S_i) < \mathrm{cut}(S_{i+1})$ — has at most $m$ steps.

*Proof.* $\mathrm{cut}(S_i) \ge i$ by induction, and $\mathrm{cut}(S_i)\le m$ always. $\square$

Moreover a maximiser exists and is locally maximal, so the two de-randomisations are consistent.

### 7.3 Complete graphs, and the bridge to Turán

**Theorem 7.8.** $\mathrm{maxcut}(K_n) = \lfloor n/2 \rfloor \cdot \lceil n/2 \rceil$.

*Proof.* For $K_n$, $\mathrm{cut}(S) = |S|(n-|S|)$, maximised at the balanced split; the upper bound follows from $4|S|(n-|S|) \le n^2$ and the identity $4\lfloor n/2\rfloor\lceil n/2\rceil + (n \bmod 2) = n^2$. $\square$

**Theorem 7.9 (MAX-CUT meets Turán).** $\mathrm{maxcut}(K_n) = e\big(T(n,2)\big) = \mathrm{ex}(n,K_3)$.

*Proof.* Compare Theorem 7.8 with Theorem 5.3 at $r=2$: $4e(T(n,2)) + s(2-s) = n^2$ with $s = n\bmod 2$, i.e. $4e(T(n,2)) + (n\bmod 2) = n^2$, the same identity as in Theorem 7.8. $\square$

So the largest bipartite subgraph of $K_n$ is exactly the extremal triangle-free graph — the MAX-CUT thread and the Turán thread meet.

---

## 8. Property B by the same counting

**Definition 8.1.** For a $k$-uniform hypergraph $H$ on a finite vertex set $V$ (a family of $k$-element subsets of $V$), a two-colouring is a subset $S \subseteq V$ (say, the red vertices). An edge $E$ is *monochromatic* if $E \subseteq S$ or $E \cap S = \varnothing$.

**Theorem 8.2 (Union bound for property B).** At most $|H|\cdot 2\cdot 2^{|V|-k}$ colourings make some edge monochromatic.

*Proof.* Lemmas 2.3 and 2.4 applied with $E := V$ and $T := $ an edge, then subadditivity of cardinality over the union across edges. $\square$

**Theorem 8.3 (Erdős, property B).** If $|H| < 2^{k-1}$, then $H$ admits a two-colouring with no monochromatic edge.

*Proof.* The bad colourings number at most $|H|\cdot 2^{|V|-k+1} < 2^{k-1}\cdot 2^{|V|-k+1} = 2^{|V|}$, the total number of colourings. $\square$

**Proposition 8.4 (Sharpness at $k=1$ and the shape of the bound).** For $k=1$ the hypothesis $|H| < 1$ forces $H = \varnothing$, and indeed a hypergraph containing a singleton edge has every colouring monochromatic on it — the bound cannot be relaxed at the boundary.

The point of §8 is methodological: the two counting lemmas of §2 are the *only* input, transferred verbatim from the Ramsey setting by changing the ground set from the pair set of $K_n$ to the vertex set of $H$.

---

## 9. Discussion

### 9.1 What survives de-randomisation, and at what cost

| Result | Probabilistic proof | Finitary avatar | Effective? |
|---|---|---|---|
| $R(k,k)>2^{k/2}$ | union bound on random colouring | strict inequality between two integer counts | search over $2^{\binom{n}{2}}$ colourings |
| deletion bound | expectation of bad-set count | double count + minimum-element transversal | same search, then an explicit deletion |
| Caro–Wei | random vertex order + linearity | minimum-degree greedy deletion | yes, near-linear time |
| Turán | none needed | exact count of $T(n,r)$ | yes, closed formula |
| Local Lemma | Erdős–Lovász induction | same induction in a finite weighted space | search over $\Omega$; efficient via resampling |
| MAX-CUT $\ge m/2$ | random bipartition | averaging identity; local-search exchange identity | yes, $\le m$ improvement steps |

Two of the six are genuinely efficient (Caro–Wei, MAX-CUT), one is a closed formula (Turán), and three reduce to certified terminating searches. This is a precise picture of where the difficulty in "non-constructive" actually resides: not in the logic of averaging, but in the size of the search space.

### 9.2 Where the finitary treatment is *stronger*

Three places, all of them a consequence of insisting on exact counts.

1. **Turán with no divisibility hypothesis.** Theorem 4.9 holds for every finite vertex set with no assumption relating $r$ and $n$, because the Cauchy–Schwarz step never needs balanced classes.
2. **The exact extremal number.** Theorem 5.5 gives $\mathrm{ex}(n,K_{r+1})$ in closed form for all $n,r$, and Corollary 5.7 exhibits $n=12$, $r=8$ as a genuine counterexample to the floor formula that is often quoted as a theorem. This is exactly the kind of error that survives in the literature when the divisible case is treated and the general case is "left to the reader".
3. **The deletion gain is exact, not asymptotic.** Proposition 3.5 exhibits a concrete $k$ at which the deletion bound proves something the union bound cannot, with both sides evaluated exactly.

### 9.3 Relation to algorithmic versions of the Local Lemma

Theorem 6.9 certifies that exhaustive search succeeds, which is the weakest useful form of constructivity. The Moser–Tardos algorithm — repeatedly resample the variables of a currently violated bad event — converges in expected $O(\sum_i x_i/(1-x_i))$ resamplings under the asymmetric condition of Theorem 6.4, and in the symmetric regime $e\,p\,(d+1)\le 1$ this is $O(n/d)$ resampling steps in the variable model. Carrying out that entropy-compression analysis in the same finite weighted framework is the natural next target: the witness-tree bound is itself a counting argument, so it should fit the pattern of §2 rather than requiring measure theory.

### 9.4 Methodological remarks

Three lessons emerged repeatedly.

* **Relativise the induction.** Caro–Wei is easy to prove *only* after the statement is relativised to an arbitrary subset $t$, with degrees measured inside $t$. The absolute statement has no induction; the relative one has a three-line induction.
* **Avoid subtraction.** The exact Turán identity is stated as $2r\,e + s(r-s) = (r-1)n^2$ rather than solving for $e$: the subtraction-free form is valid over the natural numbers and specialises to both the real formula and the divisibility criterion.
* **Reuse counting lemmas across settings.** §8 costs almost nothing given §2, because the two counting lemmas (supersets and disjoint sets) are stated for an abstract ground set. The same abstraction lets the same lemma serve the union bound, the double count of §3, and the property-B bound.

---

## 10. Future work

* **Moser–Tardos in the finite framework.** Carry out the entropy-compression / witness-tree analysis of resampling, giving an *efficient* constructive Local Lemma rather than a certified exhaustive search.
* **The second moment method.** Chebyshev-type arguments (threshold functions for random graphs) require variance, which in a finite weighted space is again a finite sum; the natural first target is the concentration of triangle counts.
* **Ramsey lower bounds beyond deletion.** The Lovász Local Lemma gives $R(k,k) > \tfrac{\sqrt 2}{e}k\,2^{k/2}(1+o(1))$; running that argument inside the framework of §6 with the pair-set dependency graph would be a genuine unification of §2, §3 and §6.
* **Sharper off-diagonal bounds.** Theorem 4.12 gives $R(3,k+1) > k^2$; the true growth is $\Theta(k^2/\log k)$, and the upper direction (Shearer's bound via the independence ratio of triangle-free graphs) is a Caro–Wei refinement that should fit the greedy framework.
* **Hypergraph Turán numbers.** The exact count of §5 is a complete-multipartite calculation; the analogous exact counts for $r$-partite $j$-uniform hypergraphs are open even in simple cases.
* **Property B quantitatively.** The union bound gives $m(k) \ge 2^{k-1}$; the deletion and Local Lemma refinements give $\Omega(2^k\sqrt{k/\log k})$, and both refinements are of exactly the type de-randomised in §3 and §6.

---

## 11. Conclusion

Across five classical landmarks of the probabilistic method — Erdős's Ramsey lower bound, the deletion method, Caro–Wei and its Turán corollaries, the Lovász Local Lemma, and MAX-CUT — the probability space is a convenience, not a necessity. Each argument has a finitary avatar that is a comparison of integers, a greedy algorithm, or a local search, and in three places the finitary treatment is quantitatively stronger than the textbook statement: Turán's theorem holds with no divisibility hypothesis, the exact extremal number refutes the folklore floor formula at $n=12$, $r=8$, and the deletion bound provably beats the union bound at $k=6$.

The residual difficulty in the probabilistic method is therefore computational rather than logical. "Positive probability" in a finite space means "non-empty", and non-empty means a search terminates. What separates Caro–Wei (a linear-time greedy algorithm) from the Ramsey bound (a search over $2^{\binom{n}{2}}$ colourings) is not the presence or absence of randomness but the structure of the search space — and the whole of algorithmic combinatorics lives in that gap.
