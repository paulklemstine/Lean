# Universal Posets: Counting Bounds, Structural Bounds, and Explicit Hosts

**Author:** Aristotle
**Date:** 2026-08-07

---

## Abstract

A poset $H$ is *universal* for the $n$-element posets if every partial order on $n$ points occurs as an induced subposet of $H$. Let $U(n)$ denote the least number of points of such a host. We develop a rigorous quantitative theory of $U(n)$, combining three independent mechanisms.

From above, principal-ideal labelling in the Boolean lattice gives $U(n) \le 2^n$, and we show the empty label is never used, so that $U(n)\le 2^n-1$ and the naive bound is *never attained*. We also show that this is optimal for the ideal scheme: every nonempty subset genuinely occurs as a label.

From below, a counting argument over the height-two ("bipartite") subclass yields, for every host of the $(k,l)$-bipartite posets on $N$ points, the inequality $2^{kl}\le N^{k+l}$, hence $N \ge 2^{kl/(k+l)}$; splitting $n$ points as evenly as possible gives $\tfrac{n-1}{4}\le \log_2 U(n)\le n$ for all $n\ge 1$.

We then exhibit an explicit **tagged-neighbourhood host** of size $k + 2^k l$ that is universal for the $(k,l)$-bipartite class, showing that on the extremal subclass the exponent $n/2$ — the exponent achieved asymptotically for the full class by the regularity-based construction of Bastide–Groenland–Nenadov and its recent improvement — is attained by an elementary construction. We prove that the tag coordinate cannot be dropped.

A third, purely structural mechanism, the **overlap method**, is developed in full. If two $n$-element posets have no common induced subposet on more than $s$ points, then every host containing both has at least $2n-s$ points. The chain against the antichain gives $U(n)\ge 2n-1$; a three-poset Bonferroni argument gives $U(n)\ge 3n-\lceil n/2\rceil-3$; and a *geometric family* of block-chain posets with ratio $4$ gives $2k\cdot 4^k \le 3\,U(4^k)$, hence $n\log_4 n \le 6\,U(n)$ and $U(n)/n\to\infty$. We show that ratio $2$ is the exact threshold at which the method degenerates.

Finally we establish exact and near-exact small values, $U(0)=0$, $U(1)=1$, $U(2)=3$, $U(3)=5$, $7\le U(4)\le 8$; strict monotonicity $U(n)<U(n+1)$ via deletion of a maximal point; and a comparability-graph bridge under which the poset counting bound is re-derived from a graph counting bound and Szemerédi regularity applies to comparability graphs of finite posets.

**Keywords:** universal poset, induced subposet, adjacency labelling, Boolean lattice, comparability graph, Szemerédi Regularity Lemma, overlap method, extremal combinatorics.

---

## 1. Introduction

### 1.1 The problem

Let $P=(X,\le_P)$ and $H=(Y,\le_H)$ be partially ordered sets. An **induced embedding** of $P$ into $H$ is an injective map $f:X\to Y$ with
$$f(x)\le_H f(y)\iff x\le_P y \qquad\text{for all } x,y\in X.$$
Note the biconditional: an order-preserving map is not enough, the map must also *reflect* the order. In this situation we say $P$ is an **induced subposet** of $H$.

A poset $H$ is **universal for the $n$-element posets** if every partial order on an $n$-element set embeds into $H$ in this sense. Write
$$U(n) = \min\{\,|H| : H \text{ is universal for the } n\text{-element posets}\,\}.$$
This minimum exists because the Boolean lattice on $n$ points is such a host (Theorem 3.1), so the set of admissible sizes is nonempty and $U$ is a well-defined function $\mathbb{N}\to\mathbb{N}$.

### 1.2 Why one cares

The question is the order-theoretic instance of the **induced-universal graph** and **adjacency labelling** problem. A host on $N$ points is equivalent to a labelling scheme that assigns to each element of an arbitrary $n$-element poset a label of $\lceil \log_2 N\rceil$ bits, such that the order relation between any two elements is decidable from their two labels alone, with no further information. Such schemes are the backbone of compact routing tables, distributed data structures, and succinct encodings of relational data; the quantity $\log_2 U(n)$ is exactly the optimal label length.

### 1.3 State of the art and the contribution of this work

The classical bounds are $2^{n/4}\lesssim U(n)\le 2^n$. Bastide, Groenland and Nenadov brought the upper exponent below $n$, and a subsequent improvement — the motivating result of this paper's context — shows that for every $\eta>0$ and all sufficiently large $n$ there is a universal host of size $2^{(1+\eta)n/2}$, by means of a transitivity-preserving labelling scheme inspired by the Boolean lattice, using among other tools the Szemerédi Regularity Lemma. Thus
$$\tfrac14 \;\le\; \liminf_n \tfrac{\log_2 U(n)}{n} \;\le\; \limsup_n \tfrac{\log_2 U(n)}{n} \;\le\; \tfrac12 ,$$
and pinning down the constant is open.

The present work is a rigorous, from-first-principles development of the *quantitative skeleton* of the problem. Everything below is proved in full. We do not reproduce the regularity-based construction; instead we (i) isolate the subclass on which its exponent $n/2$ is elementary and explicit, (ii) prove the counting lower bound in the sharpest general form, (iii) develop the structural overlap method to its natural limit, and (iv) build the bridge to graphs through which regularity enters.

---

## 2. Definitions

**Definition 2.1 (universal host).** For a type $\alpha$ and a poset $H$, say $H$ is a **universal host for $\alpha$** if for every partial order relation $r$ on $\alpha$ there exists $f:\alpha\to H$ with $f(x)\le f(y)\iff r(x,y)$ for all $x,y$.

**Lemma 2.2 (automatic injectivity).** Any such $f$ is injective.

*Proof.* If $f(x)=f(y)$ then $f(x)\le f(y)$ and $f(y)\le f(x)$, so $r(x,y)$ and $r(y,x)$, so $x=y$ by antisymmetry of $r$. $\square$

Thus "universal host" and "contains every $n$-element poset as an induced subposet" coincide; there is no need to demand injectivity separately.

**Definition 2.3 ($U(n)$).** $U(n)$ is the least $N$ for which there exists a partial order on an $N$-element set that is a universal host for the $n$-element posets. (Formally one takes the infimum over a nonempty set of naturals, so the infimum is attained.)

**Definition 2.4 (bipartite posets).** For $k,l\ge 0$ and a relation $R\subseteq \{1,\dots,k\}\times\{1,\dots,l\}$, the **$(k,l)$-bipartite poset** $B_R$ has ground set the disjoint union of a $k$-set $A$ and an $l$-set $B$, with $a < b$ exactly when $a\in A$, $b\in B$, and $R(a,b)$; no two elements of $A$ are comparable, and no two elements of $B$ are comparable.

**Lemma 2.5.** $B_R$ is a partial order, and $R\mapsto B_R$ is injective.

*Proof.* Reflexivity is by construction. Transitivity: any comparable pair with distinct endpoints goes from $A$ to $B$, and no chain of two such steps exists, so transitivity holds vacuously beyond the diagonal. Antisymmetry: two distinct comparable elements have one in $A$ and one in $B$, and the relation is never reversed. Injectivity: $R(a,b)$ is recovered as "$a\le b$ in $B_R$". $\square$

**Definition 2.6 (bipartite universality).** A poset $H$ is **$(k,l)$-bipartite universal** if for every $R$ there is $f$ with $f(x)\le f(y)\iff x\le y$ in $B_R$. Every universal host for a $(k+l)$-element ground set is $(k,l)$-bipartite universal, since each $B_R$ is a partial order on such a set.

**Definition 2.7 (common induced bound).** Let $P,Q$ be posets on the same $n$-element ground set $X$. Say $P$ and $Q$ have **common induced bound $s$**, written $\mathrm{cib}(P,Q)\le s$, if for every $A\subseteq X$ and every map $\varphi$ injective on $A$ with
$$x\le_P y \iff \varphi(x)\le_Q \varphi(y)\qquad (x,y\in A),$$
we have $|A|\le s$. In words: no configuration of more than $s$ points sits, order-isomorphically, inside both $P$ and $Q$.

**Definition 2.8 (comparability graph).** For a relation $r$ on $\alpha$, the **comparability graph** $\mathrm{Comp}(r)$ has vertex set $\alpha$ and edge set $\{\{x,y\} : x\ne y,\ r(x,y)\text{ or } r(y,x)\}$.

---

## 3. Upper bounds: the Boolean and ideal hosts

### 3.1 The Boolean lattice

**Theorem 3.1 (Boolean universality).** For any set $X$, the power set $2^X$ ordered by inclusion is a universal host for $X$: for every partial order $r$ on $X$, the principal-ideal map
$$\iota(x) = \{\,y\in X : r(y,x)\,\}$$
satisfies $\iota(x)\subseteq\iota(y)\iff r(x,y)$.

*Proof.* ($\Leftarrow$) If $r(x,y)$ and $z\in\iota(x)$, i.e. $r(z,x)$, then $r(z,y)$ by transitivity, so $z\in\iota(y)$. ($\Rightarrow$) $x\in \iota(x)$ by reflexivity, so $x\in\iota(y)$, i.e. $r(x,y)$. $\square$

**Corollary 3.2.** $U(n)\le 2^n$.

### 3.2 Deleting the empty label

**Theorem 3.3.** Let $\mathcal{N}_n$ be the poset of **nonempty** subsets of an $n$-element set, ordered by inclusion. Then $|\mathcal{N}_n| = 2^n-1$ and $\mathcal{N}_n$ is a universal host for the $n$-element posets. Consequently
$$U(n) \le 2^n - 1, \qquad\text{so}\qquad U(n) < 2^n \ \text{ for every } n .$$

*Proof.* Reflexivity gives $x\in\iota(x)$, so every principal ideal is nonempty; the embedding of Theorem 3.1 therefore lands in $\mathcal{N}_n$. Deleting $\varnothing$ from a $2^n$-element poset leaves $2^n-1$ points. $\square$

**Theorem 3.4 (optimality of the ideal scheme).** For every nonempty $S\subseteq X$ and every $x\in S$ there is a partial order $r$ on $X$ with $\{y : r(y,x)\} = S$. Hence *every* nonempty subset occurs as a principal-ideal label, and no further point can be deleted from $\mathcal{N}_n$ while retaining the ideal labelling.

*Proof.* Take $r(a,b)$ to hold iff $a=b$, or ($a\in S$, $b=x$, $a\ne x$). Reflexivity is built in. Transitivity: a nontrivial step always ends at $x$ and starts at an element $\ne x$, so two nontrivial steps cannot be composed; composing with a trivial step is harmless. Antisymmetry: a nontrivial step is never reversible, since it would force $x\ne x$. Finally $\{y:r(y,x)\} = \{x\}\cup(S\setminus\{x\}) = S$. $\square$

Theorem 3.4 is a statement about the *scheme*, not about $U$: it says that improving on $2^n$ by more than one point requires a labelling idea fundamentally different from principal ideals. That is precisely what the regularity-based construction supplies.

---

## 4. The counting lower bound

### 4.1 The bipartite class

**Theorem 4.1 (counting bound).** Let $H$ be a finite poset with $N$ points that is $(k,l)$-bipartite universal. Then
$$2^{\,kl} \;\le\; N^{\,k+l}.$$

*Proof.* For each of the $2^{kl}$ bipartite relations $R$, choose an induced embedding $F_R : A\sqcup B \to H$ of $B_R$. We claim $R\mapsto F_R$ is injective. Indeed, from $F_R$ alone one recovers $R$, since for $a\in A$, $b\in B$,
$$R(a,b) \iff a\le b \text{ in } B_R \iff F_R(a)\le F_R(b) \text{ in } H .$$
So if $F_R=F_S$ then $R=S$. Injectivity of a map from a set of size $2^{kl}$ into the set of all functions $A\sqcup B\to H$, of size $N^{k+l}$, gives the claim. $\square$

**Corollary 4.2 (analytic form).** If $H$ is nonempty and $k+l>0$, then
$$N \;\ge\; 2^{\,kl/(k+l)} .$$

*Proof.* Raise both sides of $2^{kl/(k+l)}$ to the power $k+l$: $\bigl(2^{kl/(k+l)}\bigr)^{k+l} = 2^{kl}\le N^{k+l}$, and $t\mapsto t^{k+l}$ is strictly increasing on $[0,\infty)$. $\square$

**Corollary 4.3 (balanced form).** If $H$ is $(m,m)$-bipartite universal with $m\ge1$, then $2^m\le N^2$; that is, on $n=2m$ points, $N\ge 2^{n/4}$.

*Proof.* Suppose $N^2 < 2^m$. Raising to the $m$-th power, $N^{2m} < 2^{m^2}$, contradicting $2^{m\cdot m}\le N^{m+m}$. $\square$

### 4.2 All $n$, and the logarithmic sandwich

**Theorem 4.4.** For every $n$, splitting the ground set into parts of sizes $\lfloor n/2\rfloor$ and $\lceil n/2\rceil$,
$$2^{\,\lfloor n/2\rfloor\cdot\lceil n/2\rceil} \;\le\; U(n)^{\,n}.$$

*Proof.* An optimal host is a universal host for a ground set of size $n$; transporting along the bijection between $\{1,\dots,n\}$ and the disjoint union of the two parts, it is $(\lfloor n/2\rfloor,\lceil n/2\rceil)$-bipartite universal. Apply Theorem 4.1 with $k+l=n$. $\square$

**Theorem 4.5 (logarithmic sandwich).** For every $n\ge 1$,
$$\frac{n-1}{4} \;\le\; \log_2 U(n) \;\le\; n .$$

*Proof.* Upper bound: $U(n)\le 2^n$ (Corollary 3.2) and $\log_2$ is monotone. Lower bound: taking $\log_2$ in Theorem 4.4 gives $\lfloor n/2\rfloor\lceil n/2\rceil \le n\log_2 U(n)$, and an elementary parity check gives $n(n-1)\le 4\lfloor n/2\rfloor\lceil n/2\rceil$ — for $n=2m$ both sides are at most $4m^2$, and for $n=2m+1$ the right side is $4m(m+1)$ while the left is $(2m+1)2m$. Dividing by $4n>0$ yields the claim. Note $U(n)\ge n\ge 1$, so the logarithm is defined. $\square$

The motivating theorem asserts $\log_2 U(n)\le(1+\eta)n/2$ for large $n$, so the exponent lies in $[1/4,1/2]$; Theorem 4.5 is the lower end, made unconditional and valid for every $n$.

---

## 5. The tagged-neighbourhood host: exponent $n/2$, explicitly

The counting bound of §4 is proved on the bipartite class. It is natural to ask how good a host for *that* class can be. The answer is an elementary construction attaining exponent $n/2$ — the exponent of the general asymptotic theorem.

**Definition 5.1 (tagged-neighbourhood host).** Fix $k,l$. Let
$$\mathcal{T}_{k,l} \;=\; \{1,\dots,k\}\ \sqcup\ \bigl(2^{\{1,\dots,k\}}\times\{1,\dots,l\}\bigr),$$
ordered by: elements of the first block are pairwise incomparable; elements of the second block are pairwise incomparable; and $a \le (S,j)$ exactly when $a\in S$.

**Lemma 5.2.** $\mathcal{T}_{k,l}$ is a partial order with exactly $k+2^k l$ points.

*Proof.* Reflexivity and antisymmetry are immediate (distinct comparable pairs go from block one to block two, never back). Transitivity: no two nontrivial steps compose, since block two has no element below anything. Cardinality: $k + 2^k\cdot l$. $\square$

**Theorem 5.3 (bipartite upper bound).** $\mathcal{T}_{k,l}$ is $(k,l)$-bipartite universal. Explicitly, for a relation $R$, the map
$$a \longmapsto a \quad (a\in A), \qquad b \longmapsto \bigl(\{a : R(a,b)\},\, b\bigr) \quad (b\in B)$$
is an induced embedding of $B_R$.

*Proof.* Four cases. Two bottom points: images are comparable iff equal, matching $B_R$. Bottom $a$ and top $b$: $a \le (\{a' : R(a',b)\},b)$ iff $a$ belongs to that set iff $R(a,b)$, matching. Top below bottom: never, in either poset. Two tops $b,b'$: the images are comparable iff the pairs are equal, and equality of pairs forces equality of second coordinates, i.e. $b=b'$ — matching the antichain structure of $B$. $\square$

**Corollary 5.4 (balanced sandwich on the bipartite class).** Let $n=2m$, $m\ge1$, and let $U_{\mathrm{bip}}(m,m)$ denote the least size of an $(m,m)$-bipartite universal host. Then
$$2^{m/2} \;\le\; U_{\mathrm{bip}}(m,m) \;\le\; m\cdot 2^m + m .$$
In terms of $n$: the exponent lies between $n/4$ and $n/2+o(n)$.

*Proof.* Combine Corollary 4.3 and Theorem 5.3 with $k=l=m$. $\square$

### 5.1 The tag is necessary

The second coordinate of the label may look redundant — the down-set already determines all comparabilities. It does not.

**Theorem 5.5.** Let $H$ be any host that is $(k,2)$-bipartite universal, and let $f$ be an induced embedding of the *empty* bipartite relation $R=\varnothing$. Then the two top points receive distinct images: $f(b_1)\ne f(b_2)$.

*Proof.* If $f(b_1)=f(b_2)$ then $f(b_1)\le f(b_2)$, hence $b_1\le b_2$ in $B_\varnothing$, which is false for distinct $b_1,b_2$ in the top antichain. $\square$

Thus a host must separate elements with identical neighbourhoods, which is exactly the job of the $\{1,\dots,l\}$ tag: without it the two top points of $B_\varnothing$ would both be labelled $\varnothing$. This one-line observation is the reason that "label by down-set" is not by itself a valid universal scheme, and it is the finite shadow of a real obstruction in the asymptotic constructions.

### 5.2 Where the counting bound leaks

Corollary 5.4 leaves a factor-two gap in the exponent. The gap is not an artefact of a poorly chosen class: on the balanced bipartite class there are $2^{n^2/4}$ posets, while a host of size $2^{n/2}$ admits roughly $2^{n^2/4}$ candidate embeddings, so the two counts match at exponent $n/2$, not $n/4$. The counting argument loses exactly a factor $2$ in the exponent because it treats *all* $N^{k+l}$ functions as available, ignoring that comparabilities in the host cannot be switched off and that host points are reused across embeddings. Repairing this loss for the full class is precisely what the regularity-based argument achieves.

The loss is visible already at $n=2$, as the next section shows.

---

## 6. The overlap method: structural lower bounds

Counting is not the only mechanism. The following is a purely structural one.

### 6.1 The two-poset bound

**Lemma 6.1 (overlap of two copies).** Let $H$ be a host, $P,Q$ posets on the same $n$-element ground set with $\mathrm{cib}(P,Q)\le s$, and $f,g$ induced embeddings of $P,Q$ into $H$. Then
$$\bigl|\,f(X)\cap g(X)\,\bigr| \;\le\; s .$$

*Proof.* Let $A = f^{-1}\bigl(f(X)\cap g(X)\bigr)$ and define $\varphi = g^{-1}\circ f$ on $A$ (well defined since $g$ is injective and $f(A)\subseteq g(X)$). For $x,y\in A$,
$$x\le_P y \iff f(x)\le_H f(y) \iff g(\varphi x)\le_H g(\varphi y) \iff \varphi x\le_Q \varphi y,$$
using that $f$ and $g$ are induced. Also $\varphi$ is injective on $A$. By Definition 2.7, $|A|\le s$; and $|A| = |f(X)\cap g(X)|$ since $f$ is injective. $\square$

**Theorem 6.2 (overlap bound).** If $P,Q$ are $n$-element posets with $\mathrm{cib}(P,Q)\le s$, then every host $H$ containing both as induced subposets satisfies $|H|\ge 2n-s$.

*Proof.* With $f,g$ as above, $|f(X)|=|g(X)|=n$ by injectivity, so
$$|H| \ \ge\ |f(X)\cup g(X)| \ =\ 2n - |f(X)\cap g(X)| \ \ge\ 2n-s. \qquad\square$$

**Lemma 6.3 (chain vs. antichain).** Let $C_n$ be the $n$-chain and $A_n$ the $n$-antichain. Then $\mathrm{cib}(C_n,A_n)\le 1$.

*Proof.* Suppose $|A|\ge 2$ with $x\ne y$ in $A$. In $C_n$, $x$ and $y$ are comparable, say $x\le y$; then $\varphi x \le \varphi y$ in $A_n$, i.e. $\varphi x=\varphi y$, contradicting injectivity of $\varphi$ on $A$. $\square$

**Theorem 6.4 (linear lower bound).** $U(n)\ge 2n-1$ for every $n$.

*Proof.* Theorem 6.2 with Lemma 6.3. $\square$

This is sharp for $n\le 3$ and gives an *argument-free* explanation of why no four-point host serves the three-element posets: such a host must contain a $3$-chain, leaving only one further point, and hence cannot contain a $3$-antichain.

### 6.2 Three posets

**Lemma 6.5 (Bonferroni for three sets).** For finite sets $A,B,C$,
$$|A|+|B|+|C| \le |A\cup B\cup C| + |A\cap B| + |A\cap C| + |B\cap C| .$$

*Proof.* $|A\cup B|+|A\cap B|=|A|+|B|$ and $|(A\cup B)\cup C| + |(A\cup B)\cap C| = |A\cup B|+|C|$; finally $(A\cup B)\cap C = (A\cap C)\cup(B\cap C)$ has size at most $|A\cap C|+|B\cap C|$. Combine. $\square$

**Definition 6.6.** Let $D_n$ be the disjoint union of a chain on the first $\lceil n/2\rceil$ indices and a chain on the remaining $\lfloor n/2\rfloor$: comparable exactly when on the same side, ordered by index.

**Lemma 6.7.** $\mathrm{cib}(C_n, D_n)\le \lceil n/2\rceil$ and $\mathrm{cib}(A_n, D_n)\le 2$.

*Proof.* A configuration common to $C_n$ and $D_n$ is a chain in $D_n$, hence contained in one of the two sides, of size at most $\lceil n/2\rceil$. A configuration common to $A_n$ and $D_n$ is an antichain in $D_n$, hence meets each side in at most one point. $\square$

**Theorem 6.8 (three-poset bound).** $U(n)\ \ge\ 3n - \bigl(3+\lceil n/2\rceil\bigr)$; asymptotically $U(n)\gtrsim \tfrac52 n - 3$.

*Proof.* Let $f,g,h$ be induced embeddings of $C_n$, $A_n$, $D_n$ into an optimal host $H$. Each image has $n$ points; by Lemmas 6.3 and 6.7 with Lemma 6.1, the three pairwise intersections have at most $1$, $\lceil n/2\rceil$ and $2$ points. Apply Lemma 6.5 and $|f(X)\cup g(X)\cup h(X)|\le |H|$. $\square$

Numerically, $3n-\lceil n/2\rceil-3$ overtakes $2n-1$ from $n=6$ onwards ($12$ vs. $11$ at $n=6$; $22$ vs. $19$ at $n=10$).

### 6.3 A geometric family: the method is superlinear

The natural question is whether the overlap method is intrinsically linear. It is not.

**Definition 6.9 (block chains).** For $n,d$ with $d\ge1$, let $\mathrm{BC}(n,d)$ be the poset on $\{0,\dots,n-1\}$ in which $x\le y$ exactly when $x\le y$ as integers *and* $\lfloor x/d\rfloor = \lfloor y/d\rfloor$. Thus $\mathrm{BC}(n,d)$ is a disjoint union of $\lceil n/d\rceil$ chains of length $d$ (the last possibly shorter). Note $\mathrm{BC}(n,1)=A_n$.

**Lemma 6.10 (pairwise overlap).** For $d\ge 1$,
$$\mathrm{cib}\bigl(\mathrm{BC}(n,e),\ \mathrm{BC}(n,d)\bigr)\ \le\ \Bigl(\bigl\lfloor \tfrac{n-1}{e}\bigr\rfloor+1\Bigr)\cdot d .$$

*Proof.* Let $A$ and $\varphi$ realise a common configuration. Map $x\mapsto\bigl(\lfloor x/e\rfloor,\ \varphi(x)\bmod d\bigr)$. The first coordinate takes at most $\lfloor (n-1)/e\rfloor+1$ values, the second at most $d$. This map is injective on $A$: if two points of $A$ agree in both coordinates, they lie in the same coarse block, hence are comparable in $\mathrm{BC}(n,e)$, hence their images are comparable in $\mathrm{BC}(n,d)$ and so lie in the same fine block; agreeing also modulo $d$ inside one fine block forces the images to coincide, and $\varphi$ is injective on $A$. Hence $|A|$ is at most the number of available pairs. $\square$

Informally: a common configuration splits into at most one chain per *coarse* block, and each such chain lives inside a single *fine* block, so has at most $d$ points.

**Theorem 6.11 (family lower bound).** Let $P_0,\dots,P_{k-1}$ be $n$-element posets with $\mathrm{cib}(P_i,P_j)\le s_{ij}$ for $j<i$. Then every host $H$ containing all of them satisfies
$$k\,n \;\le\; |H| \;+\; \sum_{i<k}\ \sum_{j<i} s_{ij}.$$

*Proof.* Let $A_i$ be the image of an induced embedding of $P_i$, so $|A_i|=n$. Bonferroni for $k$ sets gives $\sum_i |A_i| \le \bigl|\bigcup_i A_i\bigr| + \sum_{j<i}|A_i\cap A_j|$; bound the union by $|H|$ and each pairwise intersection by $s_{ij}$ using Lemma 6.1. $\square$

**Theorem 6.12 (superlinear bound).** For every $k$,
$$2\,k\,4^{k} \;\le\; 3\,U(4^{k}) .$$

*Proof.* Take $n=4^k$ and the geometric family $P_i=\mathrm{BC}(4^k, 4^i)$ for $0\le i<k$. For $j<i<k$, Lemma 6.10 gives $s_{ij}\le \bigl(\lfloor (4^k-1)/4^i\rfloor + 1\bigr)4^j = 4^{k-i}4^{j}$. Now the exact identity $3\sum_{j<i}4^j+1 = 4^i$ (immediate induction) gives, for each $i<k$,
$$3\sum_{j<i} 4^{k-i}4^{j} \;=\; 4^{k-i}\bigl(4^{i}-1\bigr) \;\le\; 4^{k},$$
so $3\sum_{i<k}\sum_{j<i}s_{ij}\le k\,4^k$. Theorem 6.11 gives $k4^k \le U(4^k) + \tfrac13 k 4^k$, i.e. $\tfrac23 k4^k \le U(4^k)$. $\square$

**Theorem 6.13 (general form and superlinearity).** For every $n$,
$$n\log_4 n \;\le\; 6\,U(n),$$
and consequently for every constant $C$ there are arbitrarily large $n$ with $U(n)\ge C\,n$; that is, $U(n)/n\to\infty$.

*Proof.* Let $k=\lfloor\log_4 n\rfloor$, so $4^k\le n<4^{k+1}=4\cdot 4^k$. Monotonicity of $U$ (Theorem 7.1) and Theorem 6.12 give $2k4^k\le 3U(4^k)\le 3U(n)$. Then $k\,n \le k\cdot 4\cdot 4^k = 2\cdot(2k4^k)\le 6U(n)$. For superlinearity, apply this at $n=4^k$ with $k\ge 6C$. $\square$

**Remark 6.14 (the ratio-$2$ threshold).** The base $4$ is essential. Repeating the computation with ratio $2$ and $n=2^k$, the overlaps become $s_{ij}\le 2^{k-i}2^j$ and, for each $i$, $\sum_{j<i}2^{k-i}2^j = 2^{k}-2^{k-i}$ — almost a full copy $2^k=n$. Summing over $i<k$, the total overlap is $k\cdot 2^k - (2^{k+1}-2)$, so the surviving bound is
$$k\,n - \Bigl(k\,n - (2^{k+1}-2)\Bigr) \;=\; 2n-2,$$
*independent of $k$*: the geometric ladder buys nothing beyond the trivial linear bound. Ratio $2$ is therefore the exact threshold of the method — it is only for ratio $\ge 3$ that the overlap series converges fast enough to leave a constant fraction of the gain — and this explains why the three-poset argument of §6.2 stalled at $\tfrac52 n$.

**Remark 6.15 (intrinsic ceiling).** The overlap method cannot go beyond order $n\log n$. By Dilworth's theorem / Erdős–Szekeres, any $n$-element poset contains a chain or an antichain on $\Omega(\sqrt n)$ points, and any two $n$-element posets share a common induced chain or antichain on $\Omega(\log n)$ points; with $k$ posets the $\binom k2$ overlaps eventually dominate the gain $kn$. The exponential lower bound must therefore come from counting, as in §4.

---

## 7. Monotonicity, strict monotonicity, and small values

**Theorem 7.1 (monotonicity).** $U$ is monotone: $m\le n\Rightarrow U(m)\le U(n)$.

*Proof.* A host for the $n$-element posets serves the $m$-element ones for $m\le n$: extend an $m$-element poset by $n-m$ isolated points, embed, and restrict. $\square$

**Theorem 7.2 (strict monotonicity).** $U(n) < U(n+1)$ for every $n$. In particular $U$ is injective and has no plateaux.

*Proof.* Let $H$ be an optimal host for the $(n+1)$-element posets; $H$ is nonempty, so it has a maximal point $m$ (nothing lies strictly above $m$; equivalently $m\le z\Rightarrow z=m$). Let $P$ be any $n$-element poset and let $P^{+}$ be $P$ with a new greatest element $\top$ adjoined above everything. Let $F$ be an induced embedding of $P^{+}$ into $H$. For each $x\ne\top$ we have $x\le\top$, hence $F(x)\le F(\top)$. If $F(x)=m$ then $m\le F(\top)$, so $F(\top)=m=F(x)$ by maximality, contradicting injectivity of $F$ (Lemma 2.2) since $x\ne\top$. Hence $F$ restricted to $P$ avoids $m$, and $H\setminus\{m\}$ — a poset with $|H|-1$ points — is a universal host for the $n$-element posets. Therefore $U(n)\le U(n+1)-1$. $\square$

The same argument with a minimal point and a global bottom gives the same conclusion.

**Theorem 7.3 (small values).**
$$U(0)=0,\quad U(1)=1,\quad U(2)=3,\quad U(3)=5,\quad 7\le U(4)\le 8 .$$

*Proof sketches.*

*$U(0)=0$, $U(1)=1$:* immediate.

*$U(2)=3$.* Upper bound: $\mathcal{T}_{1,1}$ has $1+2^1\cdot 1 = 3$ points — a two-element chain plus an isolated point — and realises all three partial orders on two points (the antichain and the two chains), by Theorem 5.3 together with a direct check for the chain orientations. Lower bound: suppose $|H|\le 2$. Universality supplies a comparable pair $u<v$ (so $u\ne v$) and an incomparable pair $p,q$ (so $p\ne q$). With at most two points, $\{p,q\}=\{u,v\}$; but $u,v$ are comparable and $p,q$ are not — contradiction. Hence $|H|\ge3$.

*$U(3)=5$.* Lower bound: $2\cdot3-1=5$ by Theorem 6.4. Upper bound: the five-point host consisting of a *diamond* (a bottom point below two incomparable middle points, both below a top point) together with an isolated point realises all nineteen partial orders on three points; this is a finite check over the $19$ orders and the $5^3$ candidate maps, performed exhaustively.

*$7\le U(4)\le 8$.* Lower bound: $2\cdot 4-1=7$ by Theorem 6.4. Upper bound: there is an explicit eight-point host into which each of the $219$ partial orders on four points embeds as an induced subposet; the verification is a finite check over the $2^{12}=4096$ codes for reflexive relations on four points, filtered to the $219$ partial orders, each with a tabulated witness embedding. $\square$

**Remark 7.4.** The values $1,3,5$ suggest $U(n)=2n-1$, but exhaustive search over the naturally labelled seven-point posets finds no seven-point host for the four-element posets, so the pattern almost certainly breaks at $n=4$ — and it must break eventually, by Theorem 6.13 and *a fortiori* by Theorem 4.5.

**Remark 7.5 (crossover).** The two lower-bound mechanisms are complementary. At $n=3$ the counting bound gives only $\log_2 U(3)\ge 1/2$, i.e. $U(3)\ge2$, against the exact value $5$; at $n=40$ it gives $U(40)\ge 2^{9.75}>860$, against the linear bound $79$. The crossover is near $n=20$–$24$.

---

## 8. The bridge to graphs, and regularity

**Theorem 8.1 (comparability is a functor on induced embeddings).** If $f$ is an induced embedding of $P$ into $H$, then $f$ is an induced-subgraph embedding of $\mathrm{Comp}(P)$ into $\mathrm{Comp}(H)$: for all $x\ne y$,
$$f(x)\sim f(y) \text{ in } \mathrm{Comp}(H) \iff x\sim y \text{ in }\mathrm{Comp}(P).$$

*Proof.* $f$ is injective (Lemma 2.2), so $f(x)\ne f(y)$ iff $x\ne y$; and comparability of images is equivalent to comparability of originals because $f$ both preserves and reflects $\le$. Both directions are needed: a merely order-preserving map does not induce an induced subgraph. $\square$

**Theorem 8.2 (exactness on height two).** The comparability graph of the $(k,l)$-bipartite poset $B_R$ is *exactly* the bipartite graph on $A\sqcup B$ with edge set $R$. The correspondence $R\mapsto \mathrm{Comp}(B_R)$ is a bijection onto the $(k,l)$-bipartite graphs.

*Proof.* Distinct elements of $A$ are incomparable in $B_R$, likewise in $B$; $a$ and $b$ are comparable iff $R(a,b)$. $\square$

**Definition 8.3.** A graph $G$ is **$(k,l)$-bipartite universal** if every bipartite graph with parts of sizes $k,l$ occurs as an induced subgraph.

**Theorem 8.4 (graph counting bound).** If $G$ is $(k,l)$-bipartite universal with $N$ vertices, then $2^{kl}\le N^{k+l}$.

*Proof.* Verbatim as Theorem 4.1: an induced embedding determines the bipartite relation, so the assignment relation $\mapsto$ embedding is injective into a set of size $N^{k+l}$. $\square$

**Corollary 8.5 (the poset bound, re-derived).** If $H$ is a $(k,l)$-bipartite universal poset with $N$ points, then $\mathrm{Comp}(H)$ is a $(k,l)$-bipartite universal graph, whence $2^{kl}\le N^{k+l}$ — Theorem 4.1 again, by a different route.

*Proof.* Theorems 8.1, 8.2 and 8.4. $\square$

The two routes are genuinely different proofs of the same inequality, and Corollary 8.5 quantifies a structural fact: **on the height-two class, passing to the comparability graph loses nothing.** For general posets the functor does lose information — orientation is forgotten — which is why a graph-theoretic construction must be re-oriented before it yields a poset.

**Theorem 8.6 (regularity for comparability graphs).** Let $H$ be a finite poset with a decidable order, $\varepsilon>0$, and $m\le |H|$. Then there is a partition $\mathcal P$ of the points of $H$ that is an equipartition, has between $m$ and $\mathrm{bd}(\varepsilon,m)$ parts for an absolute bound $\mathrm{bd}$ depending only on $\varepsilon$ and $m$, and is $\varepsilon$-uniform for $\mathrm{Comp}(H)$.

*Proof.* This is the Szemerédi Regularity Lemma applied to the graph $\mathrm{Comp}(H)$; the bound is independent of the poset. $\square$

Specialising to $B_R$ gives an $\varepsilon$-uniform equipartition of any bipartite graph of bounded part sizes. Theorem 8.6 is the door through which the regularity method enters the study of universal posets: the asymptotic host of size $2^{(1+\eta)n/2}$ is built by regularising the comparability graph, encoding each element by (a) its part in the partition and (b) its densities to the other parts — a transitivity-preserving refinement of the Boolean-lattice idea — and then re-orienting.

---

## 9. Algorithms

Three algorithms make the theory effective.

**(A) Principal-ideal labelling.** Given a poset $P$ on $n$ points as an $n\times n$ Boolean matrix, output for each $x$ the bitmask $\iota(x)=\{y: y\le x\}$. Cost $O(n^2)$; label length $n$ bits; comparison of two elements is a single bitmask containment test, $O(n/w)$ machine words. Correctness is Theorem 3.1. This is the $2^n$ (indeed $2^n-1$) scheme.

**(B) Tagged-neighbourhood labelling for height-two posets.** Given a bipartite relation $R$ on $k+l$ points, label $a\in A$ by $(\mathsf{bot},a)$ and $b\in B$ by $(\mathsf{top},N_R(b),b)$ where $N_R(b)=\{a:R(a,b)\}$. Cost $O(kl)$; label length $\lceil\log_2(k+2^k l)\rceil \approx k+\log_2 l$ bits. Comparison: $\mathsf{bot}\ a \le \mathsf{top}\ (S,b)$ iff $a\in S$; all other pairs comparable iff equal. Correctness is Theorem 5.3. On $n=2m$ points this is $m+\log_2 m$ bits, i.e. exponent $n/2$ — half the exponent of (A).

**(C) Overlap lower-bound certificate.** Given a family $P_0,\dots,P_{k-1}$ of $n$-element posets and a matrix $(s_{ij})$ of certified common induced bounds, output the lower bound $kn-\sum_{j<i}s_{ij}$ for $U(n)$. Cost $O(k^2)$ after the $s_{ij}$ are known. Correctness is Theorem 6.11. Instantiating with the chain/antichain pair, with the three-poset family, and with the geometric block-chain family reproduces Theorems 6.4, 6.8 and 6.12 respectively.

---

## 10. Discussion

Three mechanisms have been isolated, and they are mutually blind.

*Counting* (§4) sees only the number of posets and gives the only known exponential bound, $2^{(n-1)/4}$. It is vacuous for $n\le4$ and dominant from about $n=20$. Its intrinsic loss is the reuse of host points, worth exactly a factor two in the exponent (§5.2).

*Structure* (§6) sees only pairwise incompatibility. It is sharp for $n\le3$, superlinear ($\Omega(n\log n)$) but no better, and provably capped at $O(n\log n)$ by Remark 6.15. Its virtue is that it is the only mechanism that explains the small values.

*Construction* (§3, §5) gives the upper bounds. The ideal scheme is intrinsically $2^n$ (Theorem 3.4) and cannot be pushed further by deletion; the tagged-neighbourhood scheme reaches exponent $n/2$ but only on height two; the regularity-based scheme reaches $(1+\eta)n/2$ in general.

The residual gap — the interval $[1/4,1/2]$ for $\lim \log_2 U(n)/n$ — thus has an unusually clean diagnosis: on the class where both bounds are tightest (balanced bipartite posets), the two answers are $n/4$ and $n/2$, both realised by short, explicit arguments, and no third idea currently exists to decide between them.

The tag phenomenon (Theorem 5.5) deserves emphasis. It shows that the difficulty is not purely about *relations* but about *identity*: a host must distinguish elements with identical neighbourhoods. Any scheme that labels by neighbourhood alone is doomed; the surplus needed to separate twins is what the extra $\log_2 l$ bits pay for, and in the general asymptotic setting it is the source of the $\eta$.

---

## 11. Future directions

Throughout, $U(n)$ denotes the least number of points of a poset containing every $n$-element poset as an induced subposet.

**C1 (the exponent).** Determine $\lim_n \log_2 U(n)/n$, or show the limit exists. Currently $[1/4,1/2]$. Even deciding whether the exponent is $<1/2$ for the *bipartite* class would be decisive: Corollary 5.4 shows the two candidate answers there are $n/4$ and $n/2$.

**C2 (the overlap method).** (a) Is the $O(n\log n)$ ceiling of Remark 6.15 real? Prove that no family of $n$-element posets pushes the overlap bound past $Cn\log n$. (b) *[settled here]* The overlap method does reach order $n\log n$: Theorem 6.13. (c) Optimise the constant: the geometric family with ratio $4$ gives $\tfrac16 n\log_4 n$; ratio $2$ degenerates (Remark 6.14). What is the optimal ratio, and does a non-geometric family do better?

**C3 (bipartite versus general).** Is $U_{\mathrm{bip}}$ within a subexponential factor of $U$? If the height-two class already forces the true exponent, the whole problem reduces to bipartite graphs, where regularity is most effective.

**C4 (recursion).** *[half settled here]* $U$ is strictly increasing (Theorem 7.2). Does $U(n+1)\le 2U(n)+1$ hold? A positive answer would give $U(n)=O(2^n)$ by a route independent of the ideal scheme, and any improvement of the base would improve the exponent.

**C5 (small values).** Determine $U(4)$ exactly: is it $7$ or $8$? Computationally the answer appears to be $8$, which would already falsify $U(n)=2n-1$. Then $U(5)$, $U(6)$: the sequence $0,1,3,5,\ldots$ is not currently in any classification of integer sequences with a known continuation.

**C6 (labelling schemes with structure).** The tagged-neighbourhood host is a *two-layer* scheme. Is there a $k$-layer analogue for posets of height $k$, of size $2^{n/k+o(n)}$? A positive answer would show that bounded-height posets are strictly easier than general ones and would localise the difficulty in the unbounded-height regime.

**C7 (deletion beyond one point).** Theorem 3.3 deletes exactly one point from the Boolean lattice, and Theorem 3.4 shows no more can go with the same labelling. Is there a host of size $2^n - \omega(1)$? Is there one of size $2^n/n$?

**C8 (the graph bridge).** For general posets the comparability functor forgets orientation. Quantify the loss: how much larger must an induced-universal *graph* host be blown up to serve as an induced-universal *poset* host? A bound of the form $U(n)\le \mathrm{poly}(n)\cdot U_{\mathrm{graph}}(n)$ would transfer the entire graph literature.

---

## 12. Conclusion

We have assembled a complete, self-contained quantitative account of the universal-poset size function:
$$\max\Bigl(3n-\bigl\lceil\tfrac n2\bigr\rceil-3,\ \tfrac16 n\log_4 n,\ 2^{(n-1)/4}\Bigr) \;\le\; U(n) \;\le\; 2^n-1,$$
with $U(0),\dots,U(3) = 0,1,3,5$ exactly, $U(4)\in\{7,8\}$, $U$ strictly increasing, and — on the balanced bipartite subclass, where the counting bound is tightest — an explicit host of size $m2^m+m$ realising the exponent $n/2$ of the best known asymptotic construction. The comparability functor identifies the height-two poset problem with the bipartite graph problem exactly, which is why regularity-based graph technology is the right tool, and the tag obstruction identifies precisely where a naive neighbourhood labelling fails.

What remains is a single constant between $1/4$ and $1/2$, and a factor of two in an exponent that has resisted every idea so far tried.
