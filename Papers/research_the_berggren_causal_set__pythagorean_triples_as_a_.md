# The Berggren Causal Set: Pythagorean Triples as a Discrete Structure on the Null Cone

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The Berggren (Barning–Hall) tree generates every primitive Pythagorean triple exactly once from the seed $(3,4,5)$ by three integer matrices. Since a Pythagorean triple $(a,b,c)$ satisfies $a^2+b^2-c^2=0$, every node of the tree is an integral null vector of the Lorentz form $Q(x,y,t)=x^2+y^2-t^2$ of signature $(2,1)$, and the three generators lie in $O(2,1;\mathbb{Z})$. This suggests a striking hypothesis: that the Berggren tree, ordered by ancestry, is a discrete model of $2{+}1$-dimensional Minkowski spacetime in the sense of causal set theory. We settle the hypothesis completely, in both directions.

**Positive.** The tree, ordered by "is an ancestor of", satisfies the Bombelli–Lee–Meyer–Sorkin axioms: the relation is reflexive, transitive and antisymmetric, admits no closed causal curves, and is locally finite. The combinatorial engine is a *unique parent property* derived from a single explicit inverse map whose sign pattern $(a,-b,c)/(a,b,c)/(-a,b,c)$ distinguishes the three branches. The geometry is genuinely Lorentzian: every event is a future-directed null vector, every word of moves acts as an integral Lorentz transformation, the tree *is* that group orbit, the determinant of a word is $(-1)^{\#B}$, and the three generators generate a free monoid of rank three. Quantitatively, level $k$ has exactly $3^k$ events and is an antichain; causal intervals are chains with exactly $k+1$ events; the three link types have exact spacelike lengths $4(c-b)^2$, $4(a-b)^2$, $4(c-a)^2$; discrete proper time is well defined and additive; the Pell spine is a uniformly spaced geodesic with all link lengths equal to $4$, its time coordinate obeys $c_{k+2}=6c_{k+1}-c_k$, and its celestial directions converge to the irrational boundary point $\sqrt2/2$.

**Negative.** The identification of the tree order with the ambient Minkowski causal order is *false*: any two distinct nodes are **spacelike** separated, so every tree edge is a causally impossible relation of $\mathbb{R}^{2,1}$. And the silver-ratio growth does *not* produce dimension $2{+}1$: interval cardinalities are exactly $k+1$, so no Myrheim–Meyer bound with exponent $2$ can hold and the effective dimension is $1$, while the $3^k$ level growth is superpolynomial and therefore not a volume law in any fixed dimension.

The failure is instructive and general: distinct, pairwise non-proportional points of a null cone form a total antichain of the ambient causal order, so no order on such a set can be induced by ambient causality.

**Keywords:** Pythagorean triples, Berggren/Barning–Hall tree, causal set theory, Minkowski null cone, Lorentz group over $\mathbb{Z}$, Myrheim–Meyer dimension, Pell recurrence, free monoid, conformal boundary.

---

## 1. Introduction

### 1.1 Two traditions meeting on one equation

The equation $a^2+b^2=c^2$ belongs to two mathematical cultures at once. In number theory it defines the Pythagorean triples, one of the oldest studied Diophantine families. In physics, rewritten as
$$Q(a,b,c) := a^2 + b^2 - c^2 = 0,$$
it defines the **null cone** of $2{+}1$-dimensional Minkowski space $\mathbb{R}^{2,1}$: the set of events joined to the origin by a light ray. Every Pythagorean triple is an integer point of that cone.

Causal set theory (Bombelli–Lee–Meyer–Sorkin) proposes that spacetime is fundamentally a discrete, locally finite partial order, from which the Lorentzian metric can be reconstructed by counting: *order plus number equals geometry*. A candidate discrete spacetime should therefore be (i) a partially ordered set, (ii) locally finite, and (iii) faithfully embeddable in a Lorentzian manifold in a way that matches volumes with cardinalities.

The Berggren tree of primitive Pythagorean triples is an unusually attractive candidate. It is an explicit infinite ternary tree; it lies exactly on the null cone; its generators preserve $Q$ exactly; and it has a famous exponential growth rate governed by the silver ratio $1+\sqrt2$. The moonshot hypothesis under investigation is:

> **Hypothesis (H).** The Berggren tree, with the ancestry order, is a causal set which is a discrete model of $2{+}1$-dimensional Minkowski space: its tree edges are causal relations of $\mathbb{R}^{2,1}$, and its growth exponent reproduces the spacetime dimension $3$.

### 1.2 Results

Hypothesis (H) decomposes into an order-theoretic claim and two geometric claims. We prove the first and disprove both of the others.

* **Theorem A (causal set axioms).** The ancestry order on Berggren events is a locally finite partial order with no closed causal curves.
* **Theorem B (Lorentz structure).** Events are null vectors; the move monoid acts by integral Lorentz matrices; the tree is a single orbit; the monoid is free of rank $3$.
* **Theorem C (exact combinatorics).** Level $k$ has $3^k$ events and is an antichain; every causal interval of proper time $k$ is a chain with exactly $k+1$ events; the three link types have exact spacelike lengths.
* **Theorem D (spacelikeness — refutation of the causal-embedding claim).** Any two distinct events are spacelike separated in $\mathbb{R}^{2,1}$.
* **Theorem E (dimension — refutation of the growth claim).** No positive $\rho$ satisfies $\rho k^2 \le |[\,\text{root},\,\text{spine}_k]|$ for all $k$; the Myrheim–Meyer-style effective dimension is $1$. Moreover level growth is superpolynomial.
* **Theorem F (boundary).** The Pell spine is a uniformly spaced geodesic whose celestial directions converge to $\sqrt2/2$, an irrational point that is the direction of no event.

Section 8 discusses the general obstruction these results expose.

---

## 2. The Berggren tree

### 2.1 Generators

**Definition 2.1 (Berggren moves).** For $v=(a,b,c)^{\mathsf T}\in\mathbb{Z}^3$ define
$$A v = \begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix}v,\qquad
B v = \begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix}v,\qquad
C v = \begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}v.$$
Componentwise,
$$A(a,b,c)=(a-2b+2c,\;2a-b+2c,\;2a-2b+3c),$$
$$B(a,b,c)=(a+2b+2c,\;2a+b+2c,\;2a+2b+3c),$$
$$C(a,b,c)=(-a+2b+2c,\;-2a+b+2c,\;-2a+2b+3c).$$

We call $A$, $B$, $C$ the *outer*, *middle* and *co-outer* moves, and write $S=\{A,B,C\}$. For a word $w=s_1s_2\cdots s_n \in S^{*}$ we write $w\cdot v$ for the result of applying $s_1$ first, then $s_2$, and so on (leftmost letter applied first).

**Definition 2.2 (Events).** An **event** is a triple $t=(a,b,c)\in\mathbb{Z}^3$ with
$$a^2+b^2=c^2, \qquad a>0,\; b>0,\; c>0.$$
It is a **primitive event** if in addition $\gcd(a,b)=1$. The **root** is $r=(3,4,5)$.

The classical Berggren–Barning–Hall theorem states that the orbit of $r$ under the free monoid on $\{A,B,C\}$ is exactly the set of primitive events, each obtained by exactly one word. We reprove the "exactly one word" half (Theorem 3.6) since it is the engine of everything below.

**Lemma 2.3 (legs are short).** If $t=(a,b,c)$ is an event then $a<c$ and $b<c$.

*Proof.* $a^2 = c^2-b^2 < c^2$ and all entries are positive, so $a<c$; symmetrically for $b$. $\square$

**Lemma 2.4 (closure).** If $t$ is an event and $s\in S$ then $st$ is an event; if $t$ is primitive, so is $st$.

*Proof sketch.* That $Q$ is preserved is a direct expansion (equivalently, Lemma 4.1 below). Positivity follows from Lemma 2.3: e.g. for $A$, $a-2b+2c = a + 2(c-b) > 0$ and $2a-b+2c = b + 2(a + c - b) >0$ using $b<c$; the third entry $2a-2b+3c = 2(a - b) + 3c \ge 3c - 2b >0$ again by $b<c$. Primitivity is preserved because the matrices are unimodular over the relevant sublattice; concretely, a common prime factor of the new legs pulls back through the explicit inverse of Definition 3.1 to a common factor of the old ones. $\square$

**Lemma 2.5 (time increases).** For every event $t=(a,b,c)$ and every $s\in S$, the third coordinate strictly increases: $(st)_3 > c$. Indeed $(st)_3 \ge c+1$.

*Proof.* $(At)_3 - c = 2(a-b)+2c$, $(Bt)_3-c = 2(a+b)+2c$, $(Ct)_3-c=2(b-a)+2c$; in each case Lemma 2.3 ($a<c$, $b<c$) makes the expression positive, and integrality upgrades $>0$ to $\ge 1$. $\square$

**Corollary 2.6.** If $|w| = n$ then $(w\cdot t)_3 \ge t_3 + n$.

*Proof.* Induct on $n$ using Lemma 2.5. $\square$

Corollary 2.6 is the single monotonicity fact from which acyclicity, antisymmetry and path uniqueness all follow.

---

## 3. The unique parent property and the tree theorem

### 3.1 One inverse map for three branches

**Definition 3.1 (parent map).** Let
$$P(a,b,c) := (a+2b-2c,\; 2a+b-2c,\; -2a-2b+3c).$$

**Lemma 3.2 (sign pattern).** For all $(a,b,c)\in\mathbb{Z}^3$:
$$P(A(a,b,c)) = (a,-b,c), \qquad P(B(a,b,c)) = (a,b,c), \qquad P(C(a,b,c)) = (-a,b,c).$$

*Proof.* Three polynomial identities, verified by expansion. For instance for $A$: the first component of $P(A(a,b,c))$ is $(a-2b+2c) + 2(2a-b+2c) - 2(2a-2b+3c) = a$; the second is $2(a-2b+2c) + (2a-b+2c) - 2(2a-2b+3c) = -b$; the third is $-2(a-2b+2c) -2(2a-b+2c) + 3(2a-2b+3c) = c$. $\square$

$P$ is exactly the inverse of $B$; on the other two branches it returns the parent with a single sign flipped, and *which* sign is flipped identifies the branch. Since events have strictly positive legs, this is a decision procedure.

**Theorem 3.3 (unique parent).** Let $t,t'$ be events and $s,s'\in S$. If $s t = s' t'$ then $s=s'$ and $t=t'$.

*Proof.* Apply $P$ to both sides and use Lemma 3.2. Write $t=(a,b,c)$, $t'=(a',b',c')$ with $a,b,a',b'>0$. The nine cases of $(s,s')$ give:
- $(A,A)$: $(a,-b,c)=(a',-b',c')$, hence $t=t'$.
- $(B,B)$, $(C,C)$: likewise immediate.
- $(A,B)$: $(a,-b,c) = (a',b',c')$ forces $b' = -b < 0$, contradicting positivity.
- $(A,C)$: forces $-b = b' <0$, contradiction.
- $(B,C)$: $(a,b,c) = (-a',b',c')$ forces $a = -a' < 0$, contradiction.
- The three transposed cases are symmetric.
So only the diagonal cases survive, giving $s=s'$ and then $t=t'$. $\square$

### 3.2 Uniqueness of causal words

**Definition 3.4 (causal relation).** For events $t,u$ write $t\preceq u$ iff $u = w\cdot t$ for some (possibly empty) word $w\in S^{*}$.

**Lemma 3.5 (ancestor factorisation).** Let $t,t'$ be events and $w,w'$ words with $|w|\le|w'|$ and $w\cdot t = w'\cdot t'$. Then there is a word $p$ with $w' = p\,w$ (as a concatenation with $p$ applied first) and $p\cdot t' = t$.

*Proof.* Induction on $|w|$. If $|w|=0$ take $p=w'$. Otherwise write $w = r\,s$ and $w' = r'\,s'$ with $s,s'$ the final letters. Then $s(r\cdot t) = s'(r'\cdot t')$, and both $r\cdot t$ and $r'\cdot t'$ are events (Lemma 2.4), so Theorem 3.3 gives $s=s'$ and $r\cdot t = r'\cdot t'$. Apply the inductive hypothesis to $r,r'$. $\square$

**Theorem 3.6 (tree property).** For an event $t$ and words $w,w'$: if $w\cdot t = w'\cdot t$ then $w=w'$.

*Proof.* Assume WLOG $|w|\le|w'|$. Lemma 3.5 supplies $p$ with $w'=pw$ and $p\cdot t = t$. By Corollary 2.6, $t_3 \ge t_3 + |p|$, so $|p|=0$ and $w'=w$. $\square$

Thus the orbit of an event under $S^{*}$ is a genuine tree: each event carries a unique address word.

---

## 4. The Lorentz structure

**Lemma 4.1.** Let $Q_{\mathrm{L}} = \operatorname{diag}(1,1,-1)$, so that $Q(v) = v^{\mathsf T}Q_{\mathrm{L}}v$. Then
$$M^{\mathsf T} Q_{\mathrm{L}} M = Q_{\mathrm{L}} \quad\text{for } M \in \{A, B, C\}.$$

*Proof.* A finite matrix computation for each generator. $\square$

**Theorem 4.2 (Lorentz orbit).** For every word $w\in S^{*}$, the matrix $M_w$ obtained by multiplying the generator matrices in the appropriate order satisfies $M_w^{\mathsf T}Q_{\mathrm{L}}M_w = Q_{\mathrm{L}}$, i.e. $M_w \in O(2,1;\mathbb{Z})$, and $M_w v_t = v_{w\cdot t}$ for every event $t$. Moreover
$$\det M_w = (-1)^{\#_B(w)},$$
where $\#_B(w)$ counts occurrences of the middle move.

*Proof.* Induction on $|w|$ using Lemma 4.1 and $(MN)^{\mathsf T}Q_{\mathrm{L}}(MN) = N^{\mathsf T}(M^{\mathsf T}Q_{\mathrm{L}}M)N$; multiplicativity of $\det$ with $\det A = \det C = 1$, $\det B = -1$. $\square$

**Corollary 4.3 (null cone).** Every event satisfies $Q(t)=0$; the tree lies on the future null cone of $\mathbb{R}^{2,1}$, and the move monoid acts on it by integral Lorentz transformations.

**Theorem 4.4 (freeness).** The map $w\mapsto M_w$ is injective. Hence $A,B,C$ generate a **free monoid of rank three** inside $O(2,1;\mathbb{Z})$.

*Proof.* If $M_w = M_{w'}$ then applying both to the root vector gives $w\cdot r = w'\cdot r$, and Theorem 3.6 gives $w=w'$. $\square$

Freeness is the group-theoretic source of the level growth computed next.

---

## 5. Order theory: the causal set axioms

**Theorem 5.1 (partial order).** On events, $\preceq$ is reflexive and transitive, and antisymmetric: if $t \preceq u$ and $u\preceq t$ then $t=u$.

*Proof.* Reflexivity: the empty word. Transitivity: concatenate words. Antisymmetry: if $u = w_1\cdot t$ and $t = w_2 \cdot u$ then $(w_1w_2)\cdot t = t$, so by Corollary 2.6 $|w_1w_2| = 0$, whence $w_1$ is empty and $u=t$. $\square$

**Theorem 5.2 (no closed causal curves).** For every event $t$ and every nonempty word $w$, $w\cdot t \neq t$.

*Proof.* Corollary 2.6 gives $(w\cdot t)_3 \ge t_3 + |w| > t_3$. $\square$

**Definition 5.3 (causal interval).** $[t,u] := \{x : t\preceq x \preceq u\}$.

**Theorem 5.4 (interval description).** Let $t$ be an event and $u = v\cdot t$ with $|v| = k$. Then
$$[t,u] = \{\,(v_{\le j})\cdot t \;:\; 0\le j \le k\,\},$$
where $v_{\le j}$ is the length-$j$ prefix of $v$. All $k+1$ listed events are distinct.

*Proof.* If $x\in[t,u]$, write $x = w\cdot t$ and $u = w'\cdot x$. Then $(ww')\cdot t = v\cdot t$, so $ww' = v$ by Theorem 3.6, so $w$ is a prefix of $v$. Conversely each prefix works, splitting $v$ as prefix followed by suffix. Distinctness: for $i<j\le k$, Corollary 2.6 applied to the segment of $v$ between positions $i$ and $j$ shows the third coordinate strictly increases, so $(v_{\le i})\cdot t \neq (v_{\le j})\cdot t$. $\square$

**Corollary 5.5 (local finiteness).** For all events $t,u$, the interval $[t,u]$ is finite. (If $t\not\preceq u$ it is empty, by transitivity.)

**Theorem 5.6 (intervals are chains).** With $t$, $u=v\cdot t$ as above, any $x,y\in[t,u]$ satisfy $x\preceq y$ or $y\preceq x$.

*Proof.* Both are prefixes $v_{\le i}\cdot t$, $v_{\le j}\cdot t$ of the same word; if $i\le j$ then the segment of $v$ from $i$ to $j$ carries $x$ to $y$. $\square$

**Definition 5.7 (discrete proper time).** For $t\preceq u$, let $\tau(t,u)$ be the length of the unique word carrying $t$ to $u$ (well defined by Theorem 3.6).

**Theorem 5.8 (proper time).** $\tau$ is additive along causal chains: if $t\preceq u\preceq v$ then $\tau(t,v) = \tau(t,u)+\tau(u,v)$. It is bounded by the ambient time advance: $t_3 + \tau(t,u) \le u_3$. Intervals are computed by it:
$$\bigl|[t,u]\bigr| = \tau(t,u)+1.$$
Finally, $u$ covers $t$ (i.e. $\tau(t,u)=1$) if and only if $u = st$ for a single move $s$: the *links* of the causal set are exactly the Berggren moves.

**Theorem 5.9 (levels).** For any event $t$ and $k\in\mathbb{N}$, the set $L_k(t)$ of depth-$k$ descendants of $t$ has exactly $3^k$ elements, and $L_k(t)$ is an **antichain**: two distinct events at the same depth are never causally related.

*Proof.* Cardinality: the map $S^k \to L_k(t)$, $w\mapsto w\cdot t$, is surjective by definition and injective by Theorem 3.6, and $|S^k| = 3^k$. Antichain: if $w\cdot t \preceq w'\cdot t$ with $|w|=|w'|$, then $w p = w'$ for some $p$, forcing $|p|=0$. $\square$

Theorems 5.1, 5.2 and Corollary 5.5 together establish **Theorem A**: the Berggren tree is a causal set in the Bombelli–Lee–Meyer–Sorkin sense.

---

## 6. Geometry: link lengths, spacelikeness, dimension

### 6.1 Exact link lengths

**Definition 6.1.** The Minkowski interval between events is $\mu(t,u) := Q(u-t) = (u_1-t_1)^2+(u_2-t_2)^2-(u_3-t_3)^2$. Positive means spacelike, negative timelike, zero null.

**Theorem 6.2 (edge spectrum).** For an event $t=(a,b,c)$,
$$\mu(t, At) = 4(c-b)^2, \qquad \mu(t, Bt) = 4(a-b)^2, \qquad \mu(t, Ct) = 4(c-a)^2.$$
The first and third are polynomial identities valid for all integers; the middle one uses $a^2+b^2=c^2$.

*Proof.* Direct expansion. For $A$: $u-t = (-2b+2c,\,2a-2b+2c-b+b,\dots)$; grouping terms the $b$- and $c$-increments cancel identically and one is left with $4(c-b)^2$. For $B$: expanding gives $4(a-b)^2 + 4(a^2+b^2-c^2)\cdot(\cdot)$, and the null condition kills the correction. $\square$

**Lemma 6.3 (no degenerate middle link).** No primitive event has $a=b$.

*Proof.* $a=b$ with $\gcd(a,b)=1$ forces $a=b=1$, hence $c^2=2$, impossible. $\square$

**Corollary 6.4.** At every primitive event all three link lengths $4(c-b)^2,\,4(a-b)^2,\,4(c-a)^2$ are strictly positive: every link is spacelike.

### 6.2 Every pair is spacelike

**Lemma 6.5 (polarisation on the cone).** If $t,u$ are events then
$$\mu(t,u) = 2\,(t_3u_3 - t_1u_1 - t_2u_2).$$

*Proof.* Expand $\mu$ and use $Q(t)=Q(u)=0$. $\square$

**Lemma 6.6 (rigidity of null rays).** Two primitive events with proportional legs are equal.

*Proof.* If $t_1u_2 = u_1t_2$ then, by coprimality of $(t_1,t_2)$ and of $(u_1,u_2)$ and positivity, $(t_1,t_2)=(u_1,u_2)$; the third coordinates agree because both are the positive square root of $t_1^2+t_2^2$. $\square$

**Theorem 6.7 (Theorem D: total spacelikeness).** If $t\neq u$ are primitive events, then $\mu(t,u) > 0$.

*Proof.* Set $D := t_1u_2 - u_1t_2$. By Lemma 6.6 and $t\neq u$ we have $D\neq 0$, so $D^2>0$. Using $Q(t)=Q(u)=0$ one obtains the Lagrange-type identity
$$(t_3u_3)^2 = (t_1u_1+t_2u_2)^2 + D^2 .$$
Hence $t_3u_3 > |t_1u_1+t_2u_2| \ge t_1u_1+t_2u_2$, since $t_3u_3>0$. By Lemma 6.5, $\mu(t,u) = 2(t_3u_3 - t_1u_1-t_2u_2) > 0$. $\square$

**Corollary 6.8 (the order is not ambient causality).** Every tree edge, and more generally every strictly causal pair $t \prec u$ of the Berggren order, is *spacelike* separated in $\mathbb{R}^{2,1}$. The relation $\preceq$ is therefore genealogical, not Lorentzian: as a subset of the null cone, the event set is a total antichain of the ambient causal order.

This refutes the first geometric half of Hypothesis (H).

### 6.3 Dimension

Myrheim–Meyer dimension estimation rests on the fact that in $d$-dimensional Minkowski space the Alexandrov interval between events separated by proper time $\tau$ has volume $\propto \tau^{d}$; a faithful sprinkling of density $\rho$ therefore contains $\approx \rho\,\tau^{d}$ elements, and the *ordering fraction* (the proportion of related pairs inside an interval) determines $d$.

**Definition 6.9 (Pell spine).** $\sigma_k := B^k \cdot r$, the branch of pure middle moves:
$$\sigma_0=(3,4,5),\ \sigma_1=(21,20,29),\ \sigma_2=(119,120,169),\ \sigma_3=(697,696,985),\dots$$

**Theorem 6.10 (linear interval growth).** $\bigl|[r,\sigma_k]\bigr| = k+1$ for all $k$, and every such interval is a chain (ordering fraction $1$).

*Proof.* Theorems 5.4, 5.6 with $v=B^k$. $\square$

**Theorem 6.11 (Theorem E: no dimension two or more).** There is no real $\rho>0$ with
$$\rho\,k^2 \le \bigl|[r,\sigma_k]\bigr| \quad\text{for all }k\in\mathbb{N}.$$
Consequently no Myrheim–Meyer dimension $\ge 2$ can be assigned. In contrast, the one-dimensional bounds $k \le |[r,\sigma_k]| \le k+1$ hold exactly: the effective dimension is $1$.

*Proof.* By Theorem 6.10 the requirement reads $\rho k^2 \le k+1$ for all $k$, which fails as soon as $k > 2/\rho$. $\square$

**Theorem 6.12 (superpolynomial branching).** For every $d\in\mathbb{N}$ there is $k$ with $k^{d} < |L_k(r)| = 3^k$.

*Proof.* $k^d/3^k \to 0$. $\square$

Theorem 6.12 shows the $3^k$ growth is *branching*, not volume: a spatial slice of a fixed-dimensional Minkowski space has polynomial volume growth, so a slice-like family growing as $3^k$ cannot be one.

### 6.4 Where the silver ratio actually lives

**Theorem 6.13 (Pell recurrence).** Along the spine, $s_k := (\sigma_k)_3$ satisfies
$$s_{k+2} = 6 s_{k+1} - s_k, \qquad s_0=5,\ s_1=29,$$
so $s = 5, 29, 169, 985, 5741, 33461,\dots$, with growth rate $3+2\sqrt2 = (1+\sqrt2)^2$, the square of the silver ratio. In particular $s_k \ge 5^{k+1}$.

*Proof.* From the middle move, the pair $(a+b,\,c)$ transforms by the fixed $2\times2$ system
$$(a+b) \mapsto 3(a+b) + 4c, \qquad c \mapsto 2(a+b)+3c,$$
whose characteristic polynomial is $\lambda^2 - 6\lambda + 1$. Eliminating $a+b$ between two consecutive steps gives the stated recurrence. The bound $s_k\ge 5^{k+1}$ follows by induction, using $s_{k+2} = 6s_{k+1}-s_k \ge 5 s_{k+1}$ (valid since $s_k \le s_{k+1}$). $\square$

**Theorem 6.14 (cosmic vs proper time).** Along the same chain,
$$\tau(r, \sigma_k) = k, \qquad (\sigma_k)_3 \ge 5^{k+1}, \qquad \bigl|[r,\sigma_k]\bigr| = k+1 .$$

Exponential growth is a statement about the *embedding coordinates*, while dimension is a statement about *interval volumes*. The two are decoupled here as sharply as possible: coordinates grow like $(3+2\sqrt2)^k$, volumes like $k$.

---

## 7. The conformal boundary

**Definition 7.1 (celestial map).** For an event $t=(a,b,c)$ set $\delta(t) := (a/c,\,b/c)\in\mathbb{Q}^2$.

**Theorem 7.2.** $\delta(t)$ lies on the unit circle $x^2+y^2=1$, and $\delta$ is injective on primitive events.

*Proof.* The circle condition is $Q(t)=0$ divided by $c^2$. Injectivity: equal directions give proportional legs, so Lemma 6.6 applies. $\square$

Thus the tree is faithfully painted onto the rational points of the celestial circle — a discrete "sky" of null directions, one per event.

**Theorem 7.3 (the spine is a uniform geodesic).** Along the spine the legs remain twins: $((\sigma_k)_1-(\sigma_k)_2)^2 = 1$ for all $k$, because the middle move sends $a-b \mapsto b-a$. Consequently, by Theorem 6.2,
$$\mu(\sigma_k, \sigma_{k+1}) = 4 \quad\text{for every }k:$$
the Pell spine is an infinite chain of *equal* spacelike steps, a uniformly spaced discrete geodesic on the null cone.

**Theorem 7.4 (boundary point).** The celestial directions of the spine converge:
$$\frac{(\sigma_k)_1}{(\sigma_k)_3} \longrightarrow \frac{\sqrt2}{2}, \qquad \text{with } \left|\left(\tfrac{(\sigma_k)_1}{(\sigma_k)_3}\right)^2 - \tfrac12\right| \le \frac{1}{k+5}.$$

*Proof sketch.* Write $a = (\sigma_k)_1$, $b=(\sigma_k)_2$, $c=(\sigma_k)_3$ with $(a-b)^2=1$. From $a^2+b^2=c^2$ and $b = a \mp 1$ one gets $2a^2 \mp 2a + 1 = c^2$, hence $\left|\frac{a^2}{c^2}-\frac12\right| = \left|\frac{2a^2-c^2}{2c^2}\right| = \frac{|2a-1|}{2c^2}\le \frac1c \le \frac{1}{k+5}$ using $c\ge k+5$ (Corollary 2.6 from $c_0=5$). Taking square roots and using continuity gives the limit $\sqrt{1/2}=\sqrt2/2$. $\square$

**Theorem 7.5 (the endpoint is not an event).** $\sqrt2/2$ is irrational, while every event has rational celestial coordinates. Hence no event of the causal set sits at the spine's limiting direction: the conformal boundary strictly extends the tree, exactly as null infinity strictly extends Minkowski space.

This is the one part of the moonshot's asymptotic picture that survives intact: the model has a genuine boundary at infinity, realised as the irrational points of the celestial circle approached by branches of the tree, with the $45^\circ$ direction $\sqrt2/2$ as the limit of the Pell branch.

---

## 8. Discussion: why a null cone cannot carry an induced causal order

The refutation in §6.2 is not an accident of the Berggren generators. It is structural.

**Proposition 8.1.** Let $X$ be any set of points on the future null cone of $\mathbb{R}^{d,1}$ such that no two distinct points of $X$ lie on the same null ray. Then any two distinct points of $X$ are spacelike separated; $X$ is a total antichain of the ambient causal order.

*Proof.* For null $t,u$, $Q(u-t) = -2\langle t,u\rangle_{\mathrm L}$, and for future-directed null vectors $\langle t,u\rangle_{\mathrm L} \le 0$ with equality iff they are parallel. $\square$

Primitivity of Pythagorean triples is exactly the hypothesis "no two on the same ray". So:

* Any order imposed on the Berggren tree is **additional structure**, logically independent of ambient causality. Lorentz equivariance of the generators does not help: the group action moves the antichain around inside itself.
* Consequently, the natural home of the tree order is combinatorial genealogy. Its causal-set axioms are genuinely satisfied — the object *is* a causal set — but the Lorentzian manifold it approximates is $1$-dimensional (a line), not $2{+}1$-dimensional.

The lesson generalises to any programme that hopes to build a discrete spacetime from a Diophantine family living on a quadric of zero signature contribution: **to obtain a Lorentzian causal set one must place events off the null cone**, e.g. by using triples as *differences* or *momenta* rather than positions, or by grading events with an independent time functional whose level sets are spacelike hypersurfaces of positive-dimensional volume growth.

Finally, note the sharpness of the diagnostic. Three distinct growth rates coexist in the same object:

| quantity | growth |
|---|---|
| events at depth $k$ (branching) | exactly $3^k$ |
| ambient time coordinate along the Pell spine | $\asymp (3+2\sqrt2)^k$ |
| causal interval cardinality at proper time $k$ (volume) | exactly $k+1$ |

Only the third has anything to do with dimension. The moonshot conflated the first two with the third; the theorems separate them.

---

## 9. Algorithms

Three procedures underlie all computations reported here.

**(1) Tree enumeration.** Breadth-first expansion of the root by the three matrices. Level $k$ costs $\Theta(3^k)$ arithmetic operations on integers of $O(k)$ digits; the enumeration is *duplicate-free by theorem*, so no hash set is needed — a fact worth exploiting in practice.

**(2) Address decoding (unique-parent climb).** Given a primitive event, apply $P$; read the sign pattern of the result to recover the move used, then recurse on the true parent. This terminates in $\tau$ steps, where $\tau$ is the depth, because the hypotenuse strictly decreases; it costs $O(\tau)$ matrix–vector products and yields the unique address word. This *is* the constructive content of Theorem 3.3.

**(3) Interval computation.** Given $t$ and a descendant $u$, decode the address of $u$ relative to $t$ and emit the $\tau+1$ prefixes. This is optimal: by Theorem 5.4, the interval has exactly $\tau+1$ elements.

The Myrheim–Meyer diagnostic then computes, for each $k$, the ordering fraction of $[t,\sigma_k]$; here it equals $1$ identically, pinning the effective dimension at $1$.

---

## 10. Applications and outlook

* **A rigorous test case for causal set theory.** Discrete Lorentzian models are usually random (Poisson sprinklings). The Berggren causal set is fully deterministic, exactly enumerable, exactly Lorentz-symmetric, and has *exactly* computable interval volumes. It is therefore a useful stress test for dimension estimators: any estimator that reports $2{+}1$ here (misled by the symmetry group or the exponential coordinate growth) is unreliable.
* **A separation theorem for growth notions.** The object exhibits, simultaneously, exponential branching, exponential coordinate growth, and linear volume growth. This makes it a canonical counterexample to the intuition that "fast growth $\Rightarrow$ high dimension".
* **Diophantine geometry of the celestial circle.** The injective celestial map turns the tree into a dense, structured subset of the rational points of the circle; the Pell branch converges to $\sqrt2/2$ with an explicit $O(1/k)$ rate. Other branches converge to other quadratic irrationalities, suggesting a boundary theory indexed by eventually periodic address words.
* **Free monoids in $O(2,1;\mathbb{Z})$.** The freeness result gives an explicit free rank-three submonoid with a Diophantine certificate of freeness (distinct words give distinct triples), which may be of independent interest in the theory of arithmetic hyperbolic groups.

**Future work.** (i) Classify the boundary points reachable by eventually periodic addresses — presumably exactly the quadratic irrational directions, with the periodic part determining a Lorentz hyperbolic element. (ii) Construct a genuinely $2{+}1$-dimensional causal set from Pythagorean data by embedding triples as *differences* of events, thereby leaving the null cone. (iii) Investigate whether the linear-volume verdict is stable under natural "thickenings" of the order (e.g. relating events whose difference is timelike after a shift). (iv) Determine the ordering fraction and dimension estimates for orders generated by proper subsets of $\{A,B,C\}$ or by mixed move–reflection monoids.

---

## 11. Conclusion

Reading $a^2+b^2=c^2$ as $Q(a,b,c)=0$ places every Pythagorean triple on the null cone of $2{+}1$-dimensional Minkowski space, and the Berggren tree turns this set of points into an infinite ternary tree carried by an exact integral Lorentz symmetry. We have shown that this tree, with its ancestry order, satisfies all the order-theoretic axioms of a causal set: it is a locally finite partial order with no closed causal curves, with unique addresses, $3^k$-element antichain levels, chain intervals of size $\tau+1$, exactly computable spacelike link lengths, and a uniformly spaced Pell geodesic converging to the irrational celestial direction $\sqrt2/2$.

But it is not a discrete spacetime. Distinct events are always spacelike separated, so the tree order is never the ambient causal order; and interval volumes are exactly linear in proper time, so the effective dimension is $1$, not $3$ — the silver-ratio growth measures branching and coordinate size, never volume. The obstruction is general: a set of pairwise non-proportional points on a null cone is a total antichain, and no order on it can be induced by ambient causality.

The result is a precise negative theorem in place of a plausible analogy, and a fully worked positive structure theory around it.
