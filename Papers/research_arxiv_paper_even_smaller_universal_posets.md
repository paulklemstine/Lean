# Bounds for Induced-Universal Posets: Counting, Overlap, and an Explicit Bipartite Host

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

A poset $H$ is *induced-universal* for the $n$-element posets if every partial order on $n$ points occurs as an induced subposet of $H$; write $U(n)$ for the least number of points of such a host. The classical principal-ideal embedding gives $U(n) \le 2^{n}$, and a recent line of work shows that for every $\eta>0$ and all sufficiently large $n$ there is a host of size $2^{(1+\eta)n/2}$, via a transitivity-preserving labelling scheme and the Szemerédi Regularity Lemma. We develop, from first principles, the quantitative landscape surrounding that theorem.

On the upper side we sharpen the naive bound to $U(n) \le 2^{n}-1$ by observing that the empty label is never used, so the naive bound is never attained; and we construct an explicit *tagged-neighbourhood host* on $k + 2^{k}l$ points that contains every $(k,l)$-bipartite poset as an induced subposet, attaining the exponent $n/2$ on the balanced bipartite family with no asymptotics and no regularity argument. We prove that the tag coordinate is necessary.

On the lower side we prove a counting bound $2^{kl} \le N^{k+l}$ for any host of the $(k,l)$-bipartite family, hence $N \ge 2^{kl/(k+l)}$ and $\log_2 U(n) \ge (n-1)/4$ for all $n \ge 1$; we re-derive it through the comparability-graph functor, on the graph side, where the regularity lemma lives. We then develop a purely structural *overlap method*, orthogonal to counting: if two $n$-element posets share no common induced subposet on more than $s$ points, any host has $\ge 2n-s$ points. This yields $U(n) \ge 2n-1$, and with a third poset $U(n) \ge 3n - \lceil n/2\rceil - 3 \sim \tfrac52 n$. Finally, by playing a geometric family of chain-unions $C_{4^{0}},\dots,C_{4^{k-1}}$ against each other and applying a Bonferroni inequality for $k$ sets, we prove $2k\,4^{k} \le 3\,U(4^{k})$ and $n\log_4 n \le 6\,U(n)$ for all $n$, so $U(n)/n \to \infty$; ratio $4$ is above the threshold ratio $2$ at which the method degenerates.

We also prove $U$ strictly increasing, and determine $U(0)=0$, $U(1)=1$, $U(2)=3$, $U(3)=5$, $7 \le U(4) \le 8$, the last by an explicit eight-point host verified against all $219$ four-element orders. The exact values show that the counting bound is lossy already at $n=2$.

**Keywords:** universal poset, induced subposet, adjacency labelling scheme, comparability graph, Szemerédi Regularity Lemma, Bonferroni inequality, extremal set theory.

---

## 1. Introduction

### 1.1 The problem

Let $P=(X,\le_P)$ and $H=(V,\le_H)$ be posets. An **induced embedding** of $P$ into $H$ is a map $f : X \to V$ with
$$f(x) \le_H f(y) \iff x \le_P y \qquad \text{for all } x,y \in X .$$
Such a map is automatically injective: if $f(x)=f(y)$ then reflexivity of $\le_H$ gives both $f(x)\le_H f(y)$ and $f(y) \le_H f(x)$, hence $x \le_P y$ and $y \le_P x$, hence $x=y$ by antisymmetry. The image of $f$, with the order it inherits from $H$, is a copy of $P$; we say $P$ is an **induced subposet** of $H$.

**Definition 1.1.** $H$ is **induced-universal for size $n$** if every partial order on an $n$-element set embeds into $H$ as an induced subposet. Define
$$U(n) \;=\; \min\{\,|V| : (V,\le) \text{ is a finite poset, induced-universal for size } n\,\}.$$

The minimum is over a nonempty set of naturals (Theorem 2.2 below supplies a host), so it exists and is attained.

The problem is to determine $U(n)$. It is the poset analogue of the classical *induced-universal graph* problem, and it is equivalent to a question about adjacency labelling schemes (Section 8).

### 1.2 What is known, and what this paper proves

The elementary upper bound is $U(n) \le 2^{n}$, from the principal-ideal embedding into the Boolean lattice. The state of the art is the theorem that for every $\eta > 0$ and every sufficiently large $n$ there is an induced-universal host of size $2^{(1+\eta)n/2}$; that construction proceeds by a labelling scheme designed so that transitivity is automatically preserved, and its central step invokes the Szemerédi Regularity Lemma.

This paper is a self-contained development of the surrounding quantitative theory. The results are summarised in the following table (all proved below).

| Statement | Location |
|---|---|
| $U(n) \le 2^{n}-1$, so $U(n) < 2^{n}$ always | Thm 2.4, Cor 2.5 |
| Counting: a $(k,l)$-bipartite host on $N$ points has $2^{kl}\le N^{k+l}$ | Thm 3.3 |
| Analytic form: $N \ge 2^{kl/(k+l)}$; balanced form $2^{m}\le N^{2}$ | Cor 3.4, Cor 3.5 |
| $\tfrac{n-1}{4} \le \log_2 U(n) \le n$ for $n\ge1$ | Thm 3.7 |
| Tagged-neighbourhood host: $k+2^{k}l$ points, $(k,l)$-bipartite-universal | Thm 4.2 |
| The tag coordinate is necessary | Prop 4.3 |
| Balanced bipartite sandwich $2^{m/2}\le U_{\mathrm{bip}}(m,m)\le m2^{m}+m$ | Cor 4.4 |
| Overlap principle: incompatible pair $\Rightarrow$ $N \ge 2n-s$ | Thm 5.3 |
| $U(n)\ge 2n-1$ | Cor 5.5 |
| $U(n)\ge 3n-\lceil n/2\rceil-3$ | Thm 5.8 |
| $U$ strictly increasing | Thm 5.9 |
| $U(0)=0$, $U(1)=1$, $U(2)=3$, $U(3)=5$, $7\le U(4)\le 8$ | Thm 6.1–6.4 |
| Chain-union overlap lemma | Lem 7.2 |
| Bonferroni family bound for $k$ posets | Thm 7.3 |
| $2k4^{k}\le 3U(4^{k})$; $n\log_4 n \le 6U(n)$; $U(n)/n\to\infty$ | Thm 7.5–7.7 |
| Comparability functor; counting bound re-derived on graphs | Thm 8.2–8.3 |
| Regularity for comparability graphs | Thm 8.4 |

### 1.3 Notation

$[n] = \{0,1,\dots,n-1\}$. For a poset $P$ and $x \in P$, the **principal down-set** is $\downarrow x = \{y : y \le x\}$. A **chain** is a totally ordered poset, an **antichain** one with no relations besides equality. $\mathcal{P}(S)$ is the power set of $S$, ordered by inclusion. $\lceil n/2 \rceil$ denotes $\lfloor (n+1)/2\rfloor$.

---

## 2. Upper bounds: the Boolean lattice and the ideal host

### 2.1 The principal-ideal embedding

**Lemma 2.1 (Ideals encode the order).** *Let $P$ be a poset on $X$. For $x,y \in X$,*
$$\downarrow x \subseteq \downarrow y \iff x \le y .$$

*Proof.* ($\Leftarrow$) If $x \le y$ and $z \in \downarrow x$, then $z \le x \le y$, so $z \in \downarrow y$ by transitivity. ($\Rightarrow$) Reflexivity gives $x \in \downarrow x \subseteq \downarrow y$, i.e. $x \le y$. $\square$

**Theorem 2.2 (Boolean host).** *For every poset $P$ on a set $X$, the map $x \mapsto \downarrow x$ is an induced embedding of $P$ into $\mathcal{P}(X)$. In particular, if $|X| = n$ then $\mathcal{P}(X)$ is an induced-universal host with $2^{n}$ points, so $U(n) \le 2^{n}$.*

*Proof.* Lemma 2.1 is exactly the induced-embedding condition; injectivity is automatic (Section 1.1), and $|\mathcal{P}(X)| = 2^{n}$. $\square$

Two remarks are worth isolating, because they will be used repeatedly.

**Remark 2.3 (Relation-level universality).** Theorem 2.2 says more than "every $n$-element poset embeds somewhere". Fixing the ground set $X$ once and for all, *every* partial order relation $r$ on $X$ is realised by the single map $x \mapsto \{y : r(y,x)\}$ built from $r$. It is convenient to package this as: a type $V$ with an order is a **universal host for the ground set $X$** if for every partial order $r$ on $X$ there is $f : X \to V$ with $f(x)\le f(y) \iff r(x,y)$. This relation-level phrasing is what makes the transfer to subclasses (bipartite, etc.) and the transport along bijections of $X$ trivial.

### 2.2 The naive bound is never attained

**Theorem 2.4 (Ideal host).** *Let $\mathcal{N}_n$ be the poset of all nonempty subsets of $[n]$, ordered by inclusion. Then $\mathcal{N}_n$ is induced-universal for size $n$, and $|\mathcal{N}_n| = 2^{n}-1$. Hence $U(n) \le 2^{n}-1$.*

*Proof.* By reflexivity, $x \in \downarrow x$, so every principal down-set is nonempty and the embedding of Theorem 2.2 already lands inside $\mathcal{N}_n$. $\square$

**Corollary 2.5.** $U(n) < 2^{n}$ for every $n \ge 0$.

One might hope to delete further points. As a *labelling scheme*, one cannot:

**Proposition 2.6 (Every nonempty label is used).** *For every nonempty $S \subseteq [n]$ and every $x \in S$ there is a partial order $r$ on $[n]$ with $\{y : r(y,x)\} = S$.*

*Proof.* Put $r(a,b)$ iff $a=b$, or ($a \in S$, $b = x$ and $a \ne x$). Reflexivity is clear. Transitivity: a nontrivial composite would require $b=x$ and $b \in S, b \ne x$, impossible. Antisymmetry: $a \ne b$ with both $r(a,b)$ and $r(b,a)$ would force $b = x = a$. Finally $\{y : r(y,x)\} = \{x\} \cup (S\setminus\{x\}) = S$. $\square$

Proposition 2.6 does *not* say $U(n) = 2^n - 1$; it says only that the down-set labelling itself cannot be trimmed. Indeed $U(3) = 5 < 7 = 2^3-1$. The gain must come from a different labelling, which is exactly what the $2^{(1+\eta)n/2}$ theorem provides.

---

## 3. The counting lower bound

### 3.1 Bipartite posets

**Definition 3.1.** Let $R \subseteq [k]\times[l]$. The **$(k,l)$-bipartite poset** $B(R)$ has ground set $[k] \sqcup [l]$ (elements written $a_i$ and $b_j$) with
$$a_i \le a_{i'} \iff i = i',\qquad b_j \le b_{j'} \iff j=j',\qquad a_i \le b_j \iff (i,j)\in R,\qquad b_j \not\le a_i .$$

**Lemma 3.2.** *$B(R)$ is a partial order for every $R$, and $R \mapsto B(R)$ is injective. Hence there are exactly $2^{kl}$ distinct $(k,l)$-bipartite posets.*

*Proof.* Reflexivity is immediate. Transitivity: the only composable pair of non-equalities would be $a \le b_j$ and $b_j \le a'$, and the latter never holds; every other composite reduces to an equality substitution. Antisymmetry: $a_i \le b_j$ and $b_j \le a_i$ cannot both hold. Injectivity: $R$ is recovered from $B(R)$ as the set of pairs with $a_i \le b_j$. $\square$

Call a host $H$ **$(k,l)$-bipartite-universal** if every $B(R)$ embeds into $H$ as an induced subposet. Any host universal for the $(k+l)$-element posets is in particular $(k,l)$-bipartite-universal, since $B(R)$ is such a poset.

### 3.2 The bound

**Theorem 3.3 (Counting bound).** *Let $H$ be a $(k,l)$-bipartite-universal poset with $N$ points. Then*
$$2^{kl} \;\le\; N^{\,k+l}.$$

*Proof.* For each $R \subseteq [k]\times[l]$ choose an induced embedding $F_R : [k]\sqcup[l] \to H$. The assignment $R \mapsto F_R$ is injective: if $F_R = F_S$, then for all $i,j$
$$(i,j) \in R \iff F_R(a_i) \le F_R(b_j) \iff F_S(a_i)\le F_S(b_j) \iff (i,j)\in S ,$$
so $R=S$. There are $2^{kl}$ relations $R$ and $N^{k+l}$ maps $[k]\sqcup[l] \to H$, so $2^{kl} \le N^{k+l}$. $\square$

The proof is an injection, not an entropy estimate: it is the observation that an induced copy *is* a complete record of the poset it copies.

**Corollary 3.4 (Analytic form).** *If $k+l > 0$ and $H$ is nonempty, then $N \ge 2^{\,kl/(k+l)}$.*

*Proof.* Set $x = kl/(k+l)$. Then $\left(2^{x}\right)^{k+l} = 2^{kl} \le N^{k+l}$, and taking $(k+l)$-th roots of nonnegative reals preserves the inequality. $\square$

**Corollary 3.5 (Balanced form).** *If $m \ge 1$ and $H$ is $(m,m)$-bipartite-universal with $N$ points, then $2^{m}\le N^{2}$; i.e. on $n = 2m$ points, $N \ge 2^{n/4}$.*

*Proof.* Suppose $N^{2} < 2^{m}$. Raising to the $m$-th power, $N^{2m} < 2^{m^{2}}$, contradicting $2^{m\cdot m}\le N^{m+m}$ from Theorem 3.3. $\square$

### 3.3 Consequences for $U(n)$

Splitting $[n]$ into parts of sizes $\lfloor n/2\rfloor$ and $\lceil n/2\rceil$ and applying Theorem 3.3 to a minimum host:

**Lemma 3.6.** *For every $n$,* $\;2^{\lfloor n/2\rfloor \cdot \lceil n/2\rceil} \le U(n)^{\,n}$.

**Theorem 3.7 (Logarithmic bounds).** *For every $n \ge 1$,*
$$\frac{n-1}{4} \;\le\; \log_2 U(n) \;\le\; n .$$

*Proof.* The upper bound is Theorem 2.2. For the lower bound, put $K = \lfloor n/2\rfloor\lceil n/2\rceil$. Taking $\log_2$ in Lemma 3.6 gives $K \le n \log_2 U(n)$. An elementary case split on the parity of $n$ gives $n(n-1) \le 4K$ (for $n = 2m$: $n(n-1) \le n^2 = 4m^2 = 4K$; for $n = 2m+1$: $4K = 4m(m+1) = (2m+1)^2 - 1 \ge n(n-1)$). Combining, $n(n-1)/4 \le K \le n\log_2 U(n)$; divide by $n > 0$. $\square$

Together with Theorem 2.4, $2^{(n-1)/4} \le U(n) \le 2^{n}-1$.

### 3.4 Where the factor of two is lost

The counting bound cannot be improved by a smarter choice of subclass. Restricted to the balanced bipartite family on $n = 2m$ points, there are $2^{n^{2}/4}$ posets to host; a host on $N = 2^{cn}$ points offers $N^{n} = 2^{cn^{2}}$ maps, and the injection of Theorem 3.3 is defeated only when $cn^2 < n^2/4$, i.e. $c < 1/4$. It is therefore *structurally impossible* for pure counting to certify $c > 1/4$: the method never observes that a single host point is reused by astronomically many different embeddings. Quantifying that reuse is exactly the role of the regularity method in the $2^{(1+\eta)n/2}$ theorem, and it is why we can construct explicit hosts of exponent $n/2$ (Section 4) that counting cannot see are near-optimal.

---

## 4. An explicit host attaining exponent $n/2$ on the bipartite family

### 4.1 The tagged-neighbourhood host

**Definition 4.1.** For $k,l \ge 0$ let
$$B_{k,l} \;=\; [k] \;\sqcup\; \bigl(\mathcal{P}([k]) \times [l]\bigr),$$
ordered by: the elements of $[k]$ are pairwise incomparable; the pairs $(S,t)$ are pairwise incomparable; and
$$a \le (S,t) \iff a \in S, \qquad (S,t) \not\le a .$$
This is a partial order (the verification is identical to Lemma 3.2, with $R$ replaced by membership), and
$$|B_{k,l}| \;=\; k + 2^{k}\,l .$$

**Theorem 4.2 (Bipartite universality of $B_{k,l}$).** *$B_{k,l}$ contains every $(k,l)$-bipartite poset as an induced subposet.*

*Proof.* Given $R \subseteq [k]\times[l]$, define
$$f(a_i) = i, \qquad f(b_j) = \bigl(N_R(j),\, j\bigr), \quad\text{where } N_R(j) = \{\,i : (i,j)\in R\,\}.$$
Check the four cases. $f(a_i)\le f(a_{i'})$ iff $i = i'$ iff $a_i \le a_{i'}$. $f(a_i) \le f(b_j)$ iff $i \in N_R(j)$ iff $(i,j) \in R$ iff $a_i \le b_j$. $f(b_j) \not\le f(a_i)$ and $b_j \not\le a_i$. Finally $f(b_j) \le f(b_{j'})$ iff $(N_R(j),j) = (N_R(j'),j')$, and comparing second coordinates this holds iff $j = j'$, iff $b_j \le b_{j'}$. $\square$

The point of the second coordinate is that the first coordinate alone is not injective.

**Proposition 4.3 (Necessity of the tag).** *Let $H$ be any poset containing every $(k,2)$-bipartite poset as an induced subposet, and let $f$ be an induced embedding of $B(\varnothing)$ (the poset with no relations). Then $f(b_0)\ne f(b_1)$, even though $b_0$ and $b_1$ have identical down-sets.*

*Proof.* If $f(b_0) = f(b_1)$ then $f(b_0)\le f(b_1)$, so $b_0 \le b_1$ in $B(\varnothing)$, i.e. $0 = 1$, a contradiction. $\square$

Thus a labelling by neighbourhoods alone is never injective when duplicates occur, and any correct scheme must carry a disambiguating coordinate. The tag costs a factor $l$ in the host size; on balanced parts that is a factor $n/2$, i.e. $\log_2(n/2)$ extra bits per element — negligible against the leading exponent.

### 4.2 The balanced sandwich

Let $U_{\mathrm{bip}}(k,l)$ be the least size of a $(k,l)$-bipartite-universal poset.

**Corollary 4.4 (Bipartite sandwich).** *For every $m\ge1$,*
$$2^{\,m/2} \;\le\; U_{\mathrm{bip}}(m,m) \;\le\; m\,2^{m} + m .$$
*On $n = 2m$ points this reads: exponent at least $n/4$, at most $n/2 + O(\log n)$.*

*Proof.* Lower: Corollary 3.5. Upper: Theorem 4.2 with $k=l=m$ and $|B_{m,m}| = m + 2^m m$. $\square$

So on the very subfamily that generates the general lower bound, the exponent $n/2$ of the deep theorem is attained by a construction one can write on a napkin. What the regularity-based argument buys is the extension of that exponent from height-$\le 2$ posets to *all* posets, at the cost of the $\eta$.

### 4.3 The general sandwich

Combining Theorem 2.2, Theorem 2.4 and Corollary 3.5 with the observation that a universal host for $n = 2m$ points is $(m,m)$-bipartite-universal:

**Theorem 4.5 (Sandwich for the full class).** *For $n = 2m$ with $m\ge1$: the poset $\mathcal{P}([n])$ is induced-universal with $2^{n}$ points, and every induced-universal $H$ on $N$ points satisfies $2^{m}\le N^{2}$, i.e. $N \ge 2^{n/4}$. The $2^{(1+\eta)n/2}$ theorem interpolates: for every $\eta>0$ and large $n$ there is a host of size $2^{(1+\eta)n/2}$.*

---

## 5. The overlap method: structural lower bounds

Counting is not the only source of lower bounds, and for small $n$ it is by far the weaker one. The following method uses no cardinality of the class at all; it uses *incompatibility of two members*.

**Definition 5.1.** Let $P,Q$ be posets on $[n]$. Say $(P,Q)$ has **common induced bound $s$** if every poset that embeds as an induced subposet into both $P$ and $Q$ has at most $s$ points. Concretely: whenever $A \subseteq [n]$ and $\varphi$ is injective on $A$ with
$$x \le_P y \iff \varphi(x) \le_Q \varphi(y) \qquad \text{for all } x,y\in A,$$
we have $|A| \le s$.

**Lemma 5.2 (Overlap of two induced copies).** *Let $H$ be a poset and $f,g$ induced embeddings of $P,Q$ into $H$, where $(P,Q)$ has common induced bound $s$. Then $|f([n]) \cap g([n])| \le s$.*

*Proof.* Let $A = \{x \in [n] : f(x) \in g([n])\}$, and let $\varphi = g^{-1}\circ f$ on $A$ ($g$ is injective, so $g^{-1}$ is defined on its image). Since $f$ is injective, $\varphi$ is injective on $A$. For $x,y \in A$, $g(\varphi(x)) = f(x)$ and $g(\varphi(y)) = f(y)$, so
$$x \le_P y \iff f(x)\le_H f(y) \iff g(\varphi x) \le_H g(\varphi y) \iff \varphi x \le_Q \varphi y .$$
So $|A| \le s$ by hypothesis, and $|f([n])\cap g([n])| = |f(A)| = |A| \le s$. $\square$

**Theorem 5.3 (Overlap principle).** *If $H$ is a host on $N$ points containing induced copies of two $n$-element posets $P,Q$ with common induced bound $s$, then*
$$N \;\ge\; 2n - s .$$

*Proof.* With $A = f([n])$, $B = g([n])$, we have $|A| = |B| = n$, $|A\cap B|\le s$ by Lemma 5.2, and $N \ge |A\cup B| = |A|+|B|-|A\cap B| \ge 2n-s$. $\square$

**Lemma 5.4.** *The $n$-chain and the $n$-antichain have common induced bound $1$.*

*Proof.* A common induced subposet is both totally ordered and totally unordered; two distinct points of it would be simultaneously comparable and incomparable. $\square$

**Corollary 5.5.** $U(n) \ge 2n-1$.

### 5.1 Three posets and the Bonferroni bound

**Lemma 5.6 (Bonferroni for three sets).** *For finite sets $A,B,C$,*
$$|A\cup B\cup C| \;\ge\; |A|+|B|+|C| - |A\cap B| - |A\cap C| - |B\cap C| .$$

**Definition 5.7.** Let $D_n$ be the poset on $[n]$ that is the disjoint union of the chain on $\{0,\dots,\lceil n/2\rceil - 1\}$ and the chain on the rest: $x \le y$ iff $x \le y$ as integers *and* $x,y$ lie on the same side.

Three overlap estimates:

* **Chain vs. antichain:** bound $1$ (Lemma 5.4).
* **Chain vs. $D_n$:** bound $\lceil n/2\rceil$. A common induced subposet is a chain, and a chain inside $D_n$ lies entirely within one of the two sides (points on opposite sides are incomparable); each side has at most $\lceil n/2\rceil$ points.
* **Antichain vs. $D_n$:** bound $2$. A common induced subposet is an antichain inside $D_n$, and it meets each side in at most one point, since two points on a side are comparable.

**Theorem 5.8 (Three-poset bound).** *For every $n$,*
$$U(n) \;\ge\; 3n - \bigl(3 + \lceil n/2\rceil\bigr).$$

*Proof.* Let $H$ be an optimal host, $A,B,C$ the images of induced copies of the chain, the antichain and $D_n$. Each has $n$ points; the three pairwise intersections have at most $1, \lceil n/2\rceil, 2$ points; Lemma 5.6 gives $N \ge |A\cup B\cup C| \ge 3n - 1 - \lceil n/2\rceil - 2$. $\square$

Asymptotically this is $\tfrac52 n$, and it exceeds $2n-1$ for all $n \ge 6$. At $n=4$ it gives exactly $7$.

### 5.2 Strict monotonicity

**Theorem 5.9.** *$U(n) < U(n+1)$ for every $n$; in particular $U$ is injective and strictly increasing.*

*Proof.* Let $H$ be an optimal host for size $n+1$, so $|H| = U(n+1) \ge n+1 \ge 1$, and fix a **maximal** point $m$ of $H$ (one with $m \le z \Rightarrow z = m$); a finite nonempty poset has one. We claim $H\setminus\{m\}$ is induced-universal for size $n$.

Let $P$ be a poset on $n$ points and let $P^{+}$ be $P$ with a new point $\top$ adjoined above everything; $P^{+}$ is a poset on $n+1$ points, so it has an induced embedding $F$ into $H$. For each $x \in P$ we have $x \le_{P^{+}} \top$, hence $F(x) \le F(\top)$. If $F(x) = m$ for some $x \in P$, then $m \le F(\top)$, so $F(\top) = m = F(x)$ by maximality, contradicting the injectivity of $F$ (as $x \ne \top$). Therefore $F$ restricted to $P$ is an induced embedding into $H \setminus \{m\}$.

Hence $U(n) \le U(n+1) - 1 < U(n+1)$. $\square$

---

## 6. Exact small values

**Theorem 6.1.** $U(0)=0$ and $U(1)=1$.

**Theorem 6.2.** $U(2)=3$.

*Proof.* Upper: $B_{1,1}$ of Definition 4.1 has $1 + 2^{1}\cdot 1 = 3$ points — a bottom point $a$, and the two pairs $(\varnothing,0)$ and $(\{a\},0)$ — and is universal for two-element posets: the antichain embeds as $\{a, (\varnothing,0)\}$, the chain as $\{a, (\{a\},0)\}$. Lower: a two-point host would have to contain both an induced chain of length $2$ and an induced antichain of size $2$, and with only two points these would be the same pair, comparable and incomparable at once; $U(2)\ge 3$ also follows from Corollary 5.5. $\square$

Note that the counting bound gives only $2^{1\cdot1} \le N^{2}$, i.e. $N \ge 2$: **the counting bound is already lossy at $n=2$.**

**Theorem 6.3.** $U(3)=5$.

*Proof.* Lower: Corollary 5.5 gives $U(3)\ge5$. Upper: there is an explicit five-point poset into which all $19$ partial orders on three labelled points embed as induced subposets; exhibiting the embeddings is a finite verification over all $2^{9}$ candidate relations on three points, of which $19$ are partial orders. $\square$

**Theorem 6.4.** $7 \le U(4) \le 8$.

*Proof.* Lower: Corollary 5.5 (or Theorem 5.8, which also gives $7$). Upper: an explicit eight-point host, together with an embedding for each of the $219$ partial orders on four labelled points, found by a finite search over all $2^{12}$ candidate relations on four points. $\square$

The value of $U(4)$ — $7$ or $8$ — is open here. Deciding it requires either a seven-point host or a proof that none exists; the search space is $2^{21}$ candidate orders on seven points times $219$ embedding requirements, which is feasible but was not carried out.

---

## 7. Superlinearity: a geometric family of chain-unions

All bounds of Section 5 are linear. The counting bound is exponential but only becomes numerically effective around $n \approx 25$. It is natural to ask whether the overlap method — which never counts posets — can see superlinear growth. It can, provided one plays *many* posets against each other simultaneously.

### 7.1 Chain-unions

**Definition 7.1.** For $d \ge 1$, let $C_{n,d}$ be the poset on $[n]$ in which $x \le y$ iff $x \le y$ as integers and $\lfloor x/d\rfloor = \lfloor y/d\rfloor$. That is: cut $[n]$ into consecutive blocks of length $d$, make each block a chain, and impose no relations across blocks. So $C_{n,1}$ is the antichain and $C_{n,n}$ is the chain.

**Lemma 7.2 (Chain-union overlap).** *For all $d \ge 1$ and $e \ge 1$, the pair $(C_{n,e}, C_{n,d})$ has common induced bound*
$$\Bigl(\Bigl\lfloor \frac{n-1}{e}\Bigr\rfloor + 1\Bigr)\cdot d ,$$
*i.e. (number of blocks of the coarse poset) $\times$ (block size of the fine poset).*

*Proof.* Let $A \subseteq [n]$ and $\varphi$ realise a common induced subposet. Map each $x \in A$ to the pair
$$\psi(x) = \bigl(\lfloor x/e\rfloor,\; \varphi(x) \bmod d\bigr).$$
The first coordinate takes at most $\lfloor (n-1)/e\rfloor + 1$ values, the second at most $d$, so it suffices to show $\psi$ is injective on $A$. Suppose $\psi(x)=\psi(y)$ with $x,y\in A$. Equal first coordinates mean $x,y$ lie in the same block of $C_{n,e}$, hence are comparable there; therefore $\varphi(x),\varphi(y)$ are comparable in $C_{n,d}$, hence lie in the same block of $C_{n,d}$, i.e. $\lfloor \varphi(x)/d\rfloor = \lfloor \varphi(y)/d\rfloor$. Equal second coordinates mean $\varphi(x)\equiv \varphi(y) \pmod d$. Same quotient and same remainder force $\varphi(x)=\varphi(y)$, and $\varphi$ is injective on $A$, so $x=y$. $\square$

The lemma is the heart of the matter: it converts a *chain* in the coarse poset into a *bounded* set in the fine poset, and the two constraints multiply rather than add.

### 7.2 The family bound

**Theorem 7.3 (Bonferroni family bound).** *Let $H$ be a host on $N$ points containing induced copies of $n$-element posets $P_0,\dots,P_{k-1}$, and suppose $(P_i,P_j)$ has common induced bound $s_{ij}$ for all $j<i$. Then*
$$k\,n \;\le\; N + \sum_{i<k}\ \sum_{j<i} s_{ij}.$$

*Proof.* Let $A_i$ be the image of the copy of $P_i$, so $|A_i| = n$. The Bonferroni inequality $\bigl|\bigcup_{i<k}A_i\bigr| \ge \sum_{i<k}|A_i| - \sum_{i<k}\sum_{j<i}|A_i\cap A_j|$ (proved by induction on $k$ using $|A\cup B| \ge |A| + |B| - |A\cap B|$) together with $|A_i \cap A_j| \le s_{ij}$ (Lemma 5.2) and $\bigl|\bigcup A_i\bigr| \le N$ gives the claim. $\square$

### 7.3 The geometric family

Take $n = 4^{k}$ and $P_i = C_{n,4^{i}}$ for $0\le i<k$: block sizes $1,4,16,\dots,4^{k-1}$.

**Lemma 7.4 (Overlap of geometric members).** *For $j < i < k$, the pair $(C_{n,4^{i}}, C_{n,4^{j}})$ has common induced bound $4^{\,k-i}\,4^{\,j}$.*

*Proof.* By Lemma 7.2 the bound is $(\lfloor (4^{k}-1)/4^{i}\rfloor + 1)\cdot 4^{j}$. Since $4^{k}-1 < 4^{k} = 4^{i}\cdot 4^{k-i}$, the floor is $< 4^{k-i}$, so $\lfloor\cdot\rfloor + 1 \le 4^{k-i}$. $\square$

**Lemma 7.5 (Overlap sum).** $\displaystyle 3\sum_{i<k}\sum_{j<i} 4^{\,k-i}4^{\,j} \;\le\; k\,4^{k}.$

*Proof.* Using $3\sum_{j<i}4^{j} + 1 = 4^{i}$ (immediate induction), $3\sum_{j<i}4^{j} = 4^{i}-1 \le 4^{i}$. Hence
$$3\sum_{i<k}\sum_{j<i}4^{k-i}4^{j} = \sum_{i<k}4^{k-i}\bigl(4^{i}-1\bigr) \le \sum_{i<k} 4^{k} = k\,4^{k}. \square$$

**Theorem 7.6 (Superlinear bound at powers of four).** *For every $k$,*
$$2\,k\,4^{k} \;\le\; 3\,U(4^{k}).$$

*Proof.* Apply Theorem 7.3 with $n = 4^{k}$, the $k$ posets $C_{n,4^{i}}$, and $s_{ij}=4^{k-i}4^{j}$ (Lemma 7.4). Then $k\,4^{k} \le U(4^{k}) + S$ where $3S \le k4^{k}$ by Lemma 7.5. Multiplying by $3$: $3k4^{k} \le 3U(4^{k}) + k4^{k}$, i.e. $2k4^{k}\le 3U(4^{k})$. $\square$

**Theorem 7.7 (General form; superlinearity).** *For every $n$,*
$$n \log_4 n \;\le\; 6\,U(n),$$
*where $\log_4 n$ denotes $\lfloor \log_4 n\rfloor$. Consequently $U(n)/n \to \infty$: for every $C$ and every $m$ there exists $n \ge m$ with $U(n) \ge Cn$.*

*Proof.* Let $k=\lfloor\log_4 n\rfloor$, so $4^{k}\le n < 4^{k+1} = 4\cdot 4^{k}$. Since $U$ is monotone (Theorem 5.9), $U(4^{k}) \le U(n)$, so Theorem 7.6 gives $2k4^{k}\le 3U(n)$. Then
$$k\,n \;\le\; k\cdot 4\cdot 4^{k} \;=\; 2\bigl(2k4^{k}\bigr) \;\le\; 2\cdot 3U(n) \;=\; 6U(n).$$
For superlinearity take $n = 4^{k}$ with $k \ge \max(6C, m)$: then $\log_4 n = k \ge 6C$ and $6Cn \le kn \le 6U(n)$, so $U(n) \ge Cn$. $\square$

### 7.4 Why the ratio must exceed $2$

Suppose we run the same argument with block sizes $r^{0},\dots,r^{k-1}$ for a ratio $r \ge 2$ and $n = r^{k}$. The overlap of $P_i$ and $P_j$ ($j<i$) is $r^{k-i}r^{j}$, so
$$\sum_{i<k}\sum_{j<i}r^{k-i}r^{j} = \sum_{i<k} r^{k-i}\cdot\frac{r^{i}-1}{r-1} \le \frac{k\,r^{k}}{r-1}.$$
Theorem 7.3 then gives $k r^{k}\bigl(1 - \tfrac{1}{r-1}\bigr) \le U(r^{k})$, which is a nontrivial (superlinear) bound exactly when $r > 2$. At $r = 2$ the two terms cancel and the bound degenerates to $0$: the geometric series of overlaps grows precisely as fast as the gain from an extra family member. So $r = 2$ is the threshold of the method, and $r=4$ is the smallest integer ratio comfortably above it, with the further virtue that $3\sum_{j<i}4^{j}+1 = 4^{i}$ is an exact identity in the integers, hiding no rounding.

The bound of Theorem 7.7 is $\Theta(n\log n)$ and therefore still infinitely far below $2^{(n-1)/4}$; its interest is methodological. It shows that a method with no counting content whatsoever nonetheless escapes linearity, and it isolates the exact reason — the multiplicativity in Lemma 7.2 — and the exact threshold at which the escape fails.

---

## 8. The comparability functor, labelling schemes, and regularity

### 8.1 Comparability graphs

**Definition 8.1.** The **comparability graph** $G(P)$ of a poset $P$ has the same vertices, with $x \sim y$ iff $x \ne y$ and ($x \le y$ or $y \le x$).

For height-$\le2$ posets the translation is an equivalence on the relation level:

**Theorem 8.2 (Comparability of a bipartite poset).** *$G(B(R))$ is the bipartite graph on $[k]\sqcup[l]$ whose edges are exactly the pairs $\{a_i, b_j\}$ with $(i,j)\in R$; no two $a$'s and no two $b$'s are adjacent.*

*Proof.* Two distinct $a_i,a_{i'}$ are incomparable in $B(R)$, likewise two $b$'s; and $a_i,b_j$ are comparable iff $a_i \le b_j$ iff $(i,j)\in R$. $\square$

**Theorem 8.3 (Functoriality and the graph counting bound).** *If $H$ is a $(k,l)$-bipartite-universal poset, then $G(H)$ contains every $(k,l)$-bipartite graph as an induced subgraph. Consequently, if $G$ is a graph on $N$ vertices containing all $(k,l)$-bipartite graphs as induced subgraphs, then $2^{kl}\le N^{k+l}$, and Theorem 3.3 follows.*

*Proof.* An induced poset embedding $f$ is injective, and for $x\ne y$ we have $f(x)\sim f(y)$ in $G(H)$ iff $f(x),f(y)$ are comparable iff $x,y$ are comparable iff $x\sim y$; so $f$ is an induced graph embedding. The graph counting bound is proved exactly as Theorem 3.3: distinct bipartite graphs cannot share an embedding, since adjacency between the two parts reconstructs the graph. $\square$

This is more than a restatement: the poset problem is now a problem about induced-universal *graphs*, where a large toolkit applies.

### 8.2 Regularity

**Theorem 8.4 (Regularity for comparability graphs).** *For every $\varepsilon>0$ and every $m$ there is a bound $M = M(\varepsilon,m)$ such that every finite poset $P$ with at least $m$ points admits a partition of its points into $t$ parts with $m \le t \le M$, all parts of sizes differing by at most one, which is $\varepsilon$-uniform for $G(P)$: for all but at most $\varepsilon t^{2}$ ordered pairs of parts $(V_i,V_j)$, and all $X\subseteq V_i$, $Y \subseteq V_j$ with $|X| \ge \varepsilon|V_i|$, $|Y|\ge \varepsilon |V_j|$, the edge densities satisfy $|d(X,Y) - d(V_i,V_j)| \le \varepsilon$.*

*Proof.* Apply the Szemerédi Regularity Lemma to $G(P)$; $M$ is the Szemerédi bound, independent of $P$. $\square$

Specialising to a $(k,l)$-bipartite relation gives a uniform equipartition of the corresponding bipartite graph, of size bounded independently of $R$. This is the form in which regularity is deployed in the construction of hosts of size $2^{(1+\eta)n/2}$: the host is built as a labelling scheme whose labels record, for each element, its position relative to a bounded regular partition together with a bounded amount of exceptional data, and the transitivity of the reconstructed order is guaranteed by the design of the labels rather than checked case by case.

### 8.3 Adjacency labelling schemes

**Definition 8.5.** An **adjacency labelling scheme** of length $L$ for the $n$-element posets consists of, for every poset $P$ on $n$ points, an injective assignment of $L$-bit labels to its points, and a single decoder $\delta : \{0,1\}^{L}\times\{0,1\}^{L}\to\{0,1\}$ (independent of $P$) with $\delta(\ell(x),\ell(y)) = 1 \iff x\le_P y$.

**Proposition 8.6 (Correspondence).**

*(i) An induced-universal host $H$ with $N$ points yields an adjacency labelling scheme of length $\lceil\log_2 N\rceil$: label $x$ by the index of $f(x)$ in $H$ and let $\delta$ be the order table of $H$.*

*(ii) Conversely, a scheme of length $L$ yields a set $V$ of at most $2^{L}$ labels carrying the decoder relation $u \preceq v \iff \delta(u,v)=1$, such that every $n$-element poset embeds into $(V,\preceq)$ as an induced substructure. If $\preceq$ is itself a partial order — which is the case for every scheme obtained from a host as in (i) — then $(V,\preceq)$ is an induced-universal host on at most $2^{L}$ points.*

*Consequently, the optimal length among schemes whose decoder relation is an order is exactly $\lceil\log_2 U(n)\rceil$.*

*Proof.* (i) is immediate from the definitions. For (ii), the labelling of a poset $P$ is injective and satisfies $\ell(x) \preceq \ell(y) \iff x \le_P y$, which is precisely an induced embedding into $(V,\preceq)$. Nothing forces $\preceq$ to be transitive or antisymmetric on labels that never co-occur; when it is, $(V,\preceq)$ is a host and the two notions coincide. $\square$

Thus:

* the Boolean-lattice host is the scheme "label $x$ by the characteristic vector of $\downarrow x$", of length $n$;
* the tagged-neighbourhood host is the scheme "label a top element by its neighbourhood plus its serial number", of length $k + \lceil\log_2 l\rceil + O(1)$ on $(k,l)$-bipartite posets — that is, $n/2 + O(\log n)$ bits on balanced parts;
* the counting bound says no scheme can have length below $(n-1)/4$;
* the $2^{(1+\eta)n/2}$ theorem says length $(1+\eta)n/2$ is achievable for all posets.

Labelling schemes of this kind are the mechanism behind succinct reachability structures, distributed ancestry queries in version-control and taxonomy systems, and local decidability of dominance relations without a global index. Halving the label length is a direct halving of the storage in all of these.

---

## 9. Algorithms

Three algorithmic ingredients are implicit above; we state them explicitly with their complexities.

**A. Principal-ideal labelling.** Input: a poset on $n$ points as an $n\times n$ Boolean matrix. Output: for each $x$, the $n$-bit label $\downarrow x$. Cost: $O(n^{2})$ time, $n$ bits per label. Decoding "$x \le y$?" is a subset test, $O(n/w)$ word operations. Correctness: Lemma 2.1.

**B. Tagged-neighbourhood labelling for bipartite posets.** Input: $R \subseteq [k]\times[l]$. Output: label $a_i \mapsto (\textsf{bot}, i)$, $b_j\mapsto(\textsf{top}, N_R(j), j)$. Cost: $O(kl)$ time; label length $k + \lceil \log_2 l\rceil + 1$ bits. Decoding: $a_i \le b_j$ iff bit $i$ of the neighbourhood field of $b_j$ is set; same-side comparisons are equality tests. Correctness: Theorem 4.2 and Proposition 4.3.

**C. Overlap lower-bound certificate.** Input: a family $P_0,\dots,P_{k-1}$ of $n$-element posets and a matrix of common induced bounds $s_{ij}$. Output: the certificate $N \ge kn - \sum_{i<k}\sum_{j<i}s_{ij}$. Cost: $O(k^{2})$ once the $s_{ij}$ are known; for the chain-union family, $s_{ij}$ is computed in $O(1)$ by Lemma 7.2. Correctness: Theorem 7.3. Optimising the family is the interesting part; Section 7.4 shows that geometric families with ratio $>2$ are the right choice and that the best exponent this method attains for chain-unions is $\Theta(n\log n)$.

**D. Exhaustive host verification.** Input: a candidate host $H$ on $N$ points (as an $N\times N$ Boolean matrix) and $n$. Procedure: enumerate all $2^{n^{2}}$ relations on $[n]$, filter the partial orders, and for each search the $N^{n}$ maps for an induced embedding. Cost: prohibitive in general, but for $n \le 4$ ($2^{16}$ relations, $219$ orders, $8^{4}=4096$ maps) it is a few million operations. This is how $U(3) \le 5$ and $U(4)\le 8$ are certified.

---

## 10. Discussion

**The corridor.** Combining everything, for all $n \ge 1$,
$$\max\Bigl(2n-1,\ 3n-\lceil n/2\rceil-3,\ \tfrac16 n\log_4 n,\ 2^{(n-1)/4}\Bigr)\ \le\ U(n)\ \le\ 2^{n}-1,$$
and the deep theorem narrows the ceiling to $2^{(1+\eta)n/2}$ for large $n$. The exponent of $U(n)$ lies in $[1/4,\,1/2]$.

**Two incomparable methods.** The counting bound is exponential but blind to structure; the overlap bound is structural but (for the families considered) at most $\Theta(n\log n)$. They are genuinely complementary: counting gives nothing useful for $n\le 20$, overlap gives the *exact* values at $n\le3$ and the sharp bound $7$ at $n=4$, and counting takes over around $n\approx25$. Neither method can currently reach the truth, and the reason is well localised: counting cannot see reuse of host points (Section 3.4); overlap cannot see that most of the $2^{n^{2}/4}$ posets are pairwise highly compatible.

**Where the $\eta$ comes from.** The tagged-neighbourhood host shows that on height-$\le2$ posets the exponent $n/2$ is achievable *exactly*, with only a $\log n$ additive overhead from the tag. The $\eta$ in the general theorem is therefore not a defect of the bipartite core; it is the price of extending the labelling to unbounded height, where transitivity across many levels must be enforced and the regular partition must be re-applied at each scale.

**Is $1/2$ the truth?** Three data points argue mildly for the upper end. (i) The counting bound is provably lossy in every case where the answer is known: $U(2)=3$ against a counting bound of $2$; $U(3)=5$ against $2^{1/2}$. (ii) The counting method has an intrinsic ceiling of $1/4$ (Section 3.4), so its failure to reach $1/2$ is not evidence that $1/2$ is wrong. (iii) The balanced bipartite family, which is where the counting bound is generated, is hosted by an explicit construction of exponent exactly $1/2$, and that construction is hard to improve: the neighbourhood field cannot be compressed below $k$ bits without collisions among the $2^{k}$ realisable neighbourhoods. Against this: nobody has produced a lower bound above $1/4$, and the general upper construction is far from tight in its lower-order terms.

---

## 11. Future work

1. **Decide $U(4)$.** Is there a seven-point induced-universal host for the four-element posets? This is a finite search of size $\approx 2^{21}\times 219 \times 7^{4}$ with heavy symmetry reduction available; settling it would give the fifth exact value and calibrate which of the two lower-bound methods is closer to the truth at small $n$.

2. **Push the overlap method past $n\log n$.** Lemma 7.2 is a product of two pigeonhole constraints. Families richer than chain-unions — for example, layered posets whose common induced subposets are bounded by a product of *three* constraints — might give $n\log^{2}n$ or $n^{1+c}$. Is there a family for which the overlap method yields a bound superpolynomial in $n$? Section 7.4 suggests the answer depends on how fast the overlap matrix decays off the diagonal.

3. **Hybridise counting and overlap.** A single argument that both counts posets and exploits incompatibility should beat both. Concretely: partition the $n$-element posets into incompatibility classes and apply the counting bound within each; the class structure would multiply the counting bound by the number of classes.

4. **Remove the $\eta$.** Is $U(n) = 2^{n/2 + o(n)}$, or even $O(n^{c}2^{n/2})$? The tagged-neighbourhood host suggests that on height-$\le2$ posets the polynomial-factor version is correct.

5. **Lower bounds above $2^{n/4}$.** Any bound of the form $2^{cn}$ with $c>1/4$ would be the first improvement over pure counting. Since counting has a hard ceiling at $1/4$, such a bound must use structure — plausibly a reuse argument showing that a single host point cannot serve too many embeddings simultaneously.

6. **Height-restricted classes.** Determine the exponent for posets of height at most $h$. Corollary 4.4 settles $h=2$ up to the gap $[1/4,1/2]$; is the answer $1/2$ for every fixed $h \ge 2$, or does it grow with $h$?

7. **Effective regularity.** The regularity-based construction is non-constructive in its bounds. Is there a construction of size $2^{(1+\eta)n/2}$ whose host and embeddings are computable in time polynomial in the host size?

---

## Appendix A: The full list of statements

For reference, the results proved above, in dependency order.

1. Ideals encode the order (Lemma 2.1) $\Rightarrow$ Boolean host (Thm 2.2) $\Rightarrow$ $U(n)\le2^{n}$.
2. Ideal host (Thm 2.4) $\Rightarrow$ $U(n)\le 2^{n}-1 < 2^{n}$ (Cor 2.5); every nonempty label is attained (Prop 2.6).
3. Bipartite posets are posets and are counted by $2^{kl}$ (Lem 3.2).
4. Counting bound $2^{kl}\le N^{k+l}$ (Thm 3.3); analytic form $N\ge 2^{kl/(k+l)}$ (Cor 3.4); balanced form $2^{m}\le N^{2}$ (Cor 3.5); $\tfrac{n-1}{4}\le\log_2 U(n)\le n$ (Thm 3.7).
5. Tagged-neighbourhood host $B_{k,l}$, $|B_{k,l}| = k+2^{k}l$, is $(k,l)$-bipartite-universal (Thm 4.2); the tag is necessary (Prop 4.3); balanced sandwich (Cor 4.4); sandwich for the full class (Thm 4.5).
6. Overlap of two induced copies (Lem 5.2); overlap principle $N\ge2n-s$ (Thm 5.3); chain vs. antichain has bound $1$ (Lem 5.4) $\Rightarrow$ $U(n)\ge2n-1$ (Cor 5.5); three-poset bound $U(n)\ge3n-\lceil n/2\rceil-3$ (Thm 5.8); $U$ strictly increasing (Thm 5.9).
7. $U(0)=0$, $U(1)=1$, $U(2)=3$, $U(3)=5$, $7\le U(4)\le8$ (Thms 6.1–6.4).
8. Chain-union overlap $\lceil n/e\rceil\cdot d$ (Lem 7.2); Bonferroni family bound (Thm 7.3); geometric overlaps (Lems 7.4, 7.5); $2k4^{k}\le3U(4^{k})$ (Thm 7.6); $n\log_4 n\le6U(n)$ and superlinearity (Thm 7.7); threshold ratio $2$ (Section 7.4).
9. Comparability of bipartite posets (Thm 8.2); functoriality and graph counting bound (Thm 8.3); regularity for comparability graphs (Thm 8.4); equivalence with labelling schemes (Prop 8.6).
