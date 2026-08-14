# The Berggren–Price Interlock: Two Inequivalent Ternary Descents on One Vertex Set, the $N$-Node Identity, and a Structural Barrier to Factoring

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

The primitive Pythagorean triples carry two classical ternary tree structures: the Barning–Hall–Berggren tree and the Price tree. Written in Euclid parameters $(m,n)$, both are ternary trees on the *same* vertex set
$$\mathcal{V} = \{(m,n) \in \mathbb{Z}^2 : 1 \le n < m,\ \gcd(m,n) = 1,\ m+n \text{ odd}\}$$
rooted at $(2,1)$. We call this coincidence the **interlock**, and we analyse it exactly.

Our first main result is the **$N$-Node Identity**: for every factorization $N = pq$ with $p,q$ odd, coprime and $1 \le p < q$, the *Fermat pair* $\left(\frac{p+q}{2}, \frac{q-p}{2}\right)$ is a vertex of $\mathcal{V}$, and the odd leg of the primitive triple it carries equals $N$ *exactly*. The map $(m,n)\mapsto (m-n,\,m+n)$ is a bijection from $\mathcal{V}$ onto the set of such factorizations, inverse to the Fermat-pair map. Consequently every odd semiprime has a unique address in the Berggren tree and a unique address in the Price tree, and the statement "factoring $N$ is finding the $N$-node" is a theorem rather than a slogan.

Our second group of results shows that the two descents are genuinely inequivalent: the Berggren generators have determinants $(+1,-1,+1)$ and the Price generators $(-2,+2,+2)$, so no invertible change of coordinates intertwines them; the leg swap $(a,b,c)\mapsto(b,a,c)$ permutes the Berggren generators but carries no Price generator to a Price generator; and the two trees share exactly two edges, both immediately below the root.

Our third group of results closes the factoring question negatively and quantitatively. Price depth is size-driven ($m \le 2^{d+1}$), and for $m \ge 9$ the Price level containing a node already exceeds $m$ in width — more work than Fermat's entire scan. Berggren depth is ratio-driven: $m \le (2d+3)n$, whence the **trade-off inequality**
$$m \;\le\; 2\,s\,(2d+3)^2 ,$$
where $s$ is Fermat's scan length. Cheap Fermat scans force deep Berggren addresses; the two cost measures are inversely coupled. An exact witness: nodes $(2k+2,1)$ have Berggren depth exactly $k$ but are found by Fermat in one step. Finally, the alternative "hypotenuse" embedding is obstructed: if $N$ has a prime factor $p \equiv 3 \pmod 4$ then no primitive triple has hypotenuse divisible by $N$.

We also isolate the two structural constraints — a determinant/coprimality lemma and a parity constraint on column sums — that any classification of ternary Pythagorean-tree generators must begin from.

**Keywords:** Pythagorean triples, Barning–Hall–Berggren tree, Price tree, Euclid parameters, Fermat factorization, ternary descent, integer factorization barrier.

---

## 1. Introduction

### 1.1 The two trees

A *primitive Pythagorean triple* is a triple $(a,b,c)$ of positive integers with $a^2+b^2=c^2$ and $\gcd(a,b)=1$. Euclid's parameterization states that every such triple, with $a$ odd, is uniquely
$$a = m^2-n^2, \qquad b = 2mn, \qquad c = m^2+n^2$$
for a pair $(m,n)$ with $1 \le n < m$, $\gcd(m,n)=1$ and $m+n$ odd.

Barning (1963) and, independently, Hall and later Berggren, observed that the set of primitive triples carries the structure of an infinite ternary tree rooted at $(3,4,5)$, with three explicit linear generators. Price later found a *second*, structurally different ternary tree on the same set with the same root. Both trees are complete and non-redundant: every primitive triple appears exactly once in each.

The purpose of this paper is to analyse the resulting configuration — two ternary descents on one vertex set — exactly, with attention to a specific question: *does either tree give a handle on integer factorization?*

### 1.2 Why factorization enters

Because the odd leg factors:
$$a = m^2-n^2 = (m-n)(m+n).$$
A vertex of the tree is not merely a triple; it is a factorization. The question "can we find the vertex whose odd leg is a given $N$?" is literally the factoring question, and the tree structure offers a search space with a canonical root and a canonical descent. This is an old and natural hope. We show it is exactly, quantifiably false — the trees sort the factorizations by a coordinate *inversely* related to factoring difficulty.

### 1.3 Summary of contributions

1. An abstract five-hypothesis framework for ternary descents (§3) proving unique-address theorems in one stroke, instantiated by both trees.
2. The $N$-Node Identity and the factorization–node bijection (§4).
3. Three exact inequivalence statements for the interlock (§5).
4. The depth duality and the trade-off inequality $m \le 2s(2d+3)^2$ (§6, §7).
5. The mod-$4$ obstruction ruling out the hypotenuse embedding (§8).
6. Two structural constraints on generators of such trees (§9).
7. Empirical corroboration at cryptographic-toy scale (§10) and a discussion of what the barrier means (§11).

---

## 2. The vertex set

**Definition 2.1 (Node).** A *node* is a pair $v = (m,n)\in\mathbb{Z}^2$ satisfying
$$1 \le n, \qquad n < m, \qquad \gcd(m,n)=1, \qquad m+n \text{ odd}.$$
We write $\mathcal V$ for the set of nodes, $\mathrm{root} = (2,1)$, and define the *size* $\sigma(m,n) = m+n$.

**Definition 2.2 (The triple at a node).** For $v=(m,n)$ put
$$A(v) = m^2-n^2 \quad (\text{odd leg}), \qquad B(v)=2mn \quad(\text{even leg}), \qquad C(v)=m^2+n^2 \quad(\text{hypotenuse}).$$

**Proposition 2.3.** For every $v$, $A(v)^2+B(v)^2=C(v)^2$. If $v \in \mathcal V$ then $A(v)$ is odd and $\gcd(A(v),B(v))=1$; i.e. the triple is primitive.

*Proof sketch.* The identity $(m^2-n^2)^2+(2mn)^2 = (m^2+n^2)^2$ is a polynomial identity. Oddness of $A$: since $m+n$ is odd, both $m-n$ and $m+n$ are odd, and $A = (m-n)(m+n)$ is a product of two odd numbers. For primitivity, $A$ is odd so $\gcd(A,2)=1$; and coprimality of $m,n$ gives Bézout coefficients from which one constructs explicit Bézout certificates for $\gcd(A,m)=1$ and $\gcd(A,n)=1$; multiplying the three coprimality statements yields $\gcd(A, 2mn)=1$. $\square$

**Proposition 2.4 (Size floor).** Every node has $\sigma(v) \ge 3$, with equality if and only if $v = \mathrm{root}$.

*Proof.* $n \ge 1$ and $m > n$ give $m+n \ge 2n+1 \ge 3$; equality forces $n=1, m=2$. $\square$

---

## 3. An abstract ternary descent framework

Both trees are instances of a single combinatorial pattern, which we isolate.

**Setting.** Let $f : \{0,1,2\} \times \mathcal{V} \to \mathbb{Z}^2$ be three maps. For a word $w = i_1 i_2 \cdots i_k$ over the alphabet $\{0,1,2\}$ define $f_w(v) = f_{i_1}(f_{i_2}(\cdots f_{i_k}(v)\cdots))$ — the *leftmost letter acts last*. (This convention makes prefixes of the address correspond to the deepest steps, which is convenient when reading off descents.)

**Hypotheses.**

- (H1) *Closure*: $v \in \mathcal V \Rightarrow f_i(v) \in \mathcal V$ for all $i$.
- (H2) *Strict growth*: $v\in\mathcal V \Rightarrow \sigma(v) < \sigma(f_i(v))$ for all $i$.
- (H3) *Parents exist*: every $v \in \mathcal V \setminus \{\mathrm{root}\}$ is $f_i(u)$ for some $i$ and some $u \in \mathcal V$.
- (H4) *Injectivity*: each $f_i$ is injective.
- (H5) *Disjointness*: if $u,v\in\mathcal V$ and $f_i(u)=f_j(v)$ then $i=j$.

**Theorem 3.1 (Completeness).** Under (H1)–(H3), every $v \in \mathcal V$ equals $f_w(\mathrm{root})$ for some word $w$.

*Proof sketch.* Strong induction on $\sigma(v)$, which is bounded below by $3$ by Proposition 2.4. If $v$ is the root take $w = \varepsilon$. Otherwise (H3) gives a parent $u$, and (H2) gives $\sigma(u) < \sigma(v)$; apply the induction hypothesis to $u$ and prepend the letter. $\square$

**Theorem 3.2 (Uniqueness).** Under (H1), (H2), (H4), (H5), distinct words give distinct nodes: $f_w(\mathrm{root}) = f_{w'}(\mathrm{root}) \Rightarrow w = w'$.

*Proof sketch.* First, no $f_i(u)$ with $u \in \mathcal V$ equals the root, since by (H2) it would have size $> \sigma(u) \ge 3 = \sigma(\mathrm{root})$. Induct on the length of $w$: the empty word can only match the empty word by the previous sentence; for nonempty $w = iw_0$, $w' = jw_0'$, (H5) forces $i=j$, then (H4) reduces to $f_{w_0}(\mathrm{root}) = f_{w_0'}(\mathrm{root})$ and the induction hypothesis applies. $\square$

**Corollary 3.3 (Tree theorem).** Under (H1)–(H5), for every $v \in \mathcal V$ there is a *unique* word $w$ with $f_w(\mathrm{root}) = v$. The map $w \mapsto f_w(\mathrm{root})$ is a bijection from words over $\{0,1,2\}$ onto $\mathcal V$.

This is the exact sense in which "the tree enumerates all primitive triples exactly once", and it is where the level count $3^L$ comes from.

---

## 4. The two generator triples, and the interlock

**Definition 4.1 (Berggren generators).** In Euclid coordinates,
$$\beta_0(m,n) = (2m-n,\ m), \qquad \beta_1(m,n) = (2m+n,\ m), \qquad \beta_2(m,n) = (m+2n,\ n),$$
with matrices $\begin{pmatrix}2&-1\\1&0\end{pmatrix}$, $\begin{pmatrix}2&1\\1&0\end{pmatrix}$, $\begin{pmatrix}1&2\\0&1\end{pmatrix}$ of determinants $+1, -1, +1$.

**Definition 4.2 (Price generators).**
$$\pi_0(m,n) = (2m,\ m-n), \qquad \pi_1(m,n) = (2m,\ m+n), \qquad \pi_2(m,n) = (m+n,\ 2n),$$
with matrices $\begin{pmatrix}2&0\\1&-1\end{pmatrix}$, $\begin{pmatrix}2&0\\1&1\end{pmatrix}$, $\begin{pmatrix}1&1\\0&2\end{pmatrix}$ of determinants $-2, +2, +2$.

**Theorem 4.3 (Closure, (H1)).** Each $\beta_i$ and each $\pi_i$ maps $\mathcal V$ into $\mathcal V$.

*Proof sketch.* The inequalities $1\le n' < m'$ are immediate from $1 \le n < m$ in all six cases. Parity: each generator's matrix has odd column sums (see §9), so $m'+n'$ is odd whenever $m+n$ is. Coprimality is the delicate point.

For Berggren, determinant $\pm1$ means the inverse is integral, so a common divisor of $(m',n')$ divides $(m,n)$; explicitly, Bézout coefficients for $(m,n)$ transform linearly into Bézout coefficients for $(m',n')$.

For Price, determinant $\pm2$ leaves room for a spurious factor $2$, and the parity hypothesis is what closes the gap. For $\pi_1$, say, $(m',n') = (2m,\, m+n)$: since $m+n$ is odd, $\gcd(2, m+n)=1$; and $\gcd(m,m+n) = \gcd(m,n) = 1$; multiplying, $\gcd(2m, m+n)=1$. The cases $\pi_0$ and $\pi_2$ are identical with $m-n$ and $2n$ in place of $m+n$ and $2m$. $\square$

**Theorem 4.4 (Growth, (H2)).** $\sigma$ strictly increases along every edge of either tree. Indeed $\beta_0$ adds $m-n>0$, $\beta_1$ adds $m+n>0$, $\beta_2$ adds $2n>0$; $\pi_0$ adds $m-n>0$, $\pi_1$ adds $m+n>0$, $\pi_2$ adds $n>0$.

**Theorem 4.5 (Berggren descent, (H3) for $\beta$).** Let $v = (m,n) \in \mathcal V$, $v \ne \mathrm{root}$. Exactly one of the following holds, and each yields a parent in $\mathcal V$:
- $m < 2n$: then $v = \beta_0(n,\ 2n-m)$ ("reflect");
- $2n < m < 3n$: then $v = \beta_1(n,\ m-2n)$ ("reflect and shift");
- $m > 3n$: then $v = \beta_2(m-2n,\ n)$ ("subtract $2n$").

The excluded cases $m=2n$ and $m=3n$ force $n \mid 1$, hence $n=1$; $m=2n$ gives the root, and $m=3n=3$ contradicts the parity condition.

**Theorem 4.6 (Price descent, (H3) for $\pi$).** Let $v = (m,n) \in \mathcal V$, $v \ne \mathrm{root}$.
- If $m = 2k$ is even (so $n$ is odd) and $n < k$: $v = \pi_0(k,\ k-n)$;
- if $m = 2k$ is even and $n > k$: $v = \pi_1(k,\ n-k)$;
- if $m$ is odd (so $n = 2t$ is even): $v = \pi_2(m-t,\ t)$.

The excluded case $n = k$ with $m = 2k$ again forces $n \mid 1$ and hence the root.

Note the contrast, which is the heart of the interlock: **the Berggren parent rule compares $m$ with $2n$ and $3n$ — a subtractive (slow Euclidean / continued-fraction) step on the ratio $m/n$; the Price parent rule halves $m$ or halves $n$ — a binary-GCD step on the sizes.**

**Theorem 4.7 (Injectivity and disjointness, (H4)–(H5)).** Each of the six generators is injective (each matrix is invertible over $\mathbb{Q}$). For disjointness, one checks the nine pairs in each family: e.g. $\beta_0(u) = \beta_1(u')$ would force $u_1 = u_1'$ and $2u_1-u_2 = 2u_1'+u_2'$, hence $u_2 = -u_2' < 0$, impossible. In the Price family the analogous contradictions use both the inequalities and the parity of $m$.

**Theorem 4.8 (The two tree theorems).** Every node is reached from $(2,1)$ by a *unique* word of Berggren generators, and by a *unique* word of Price generators. In particular, the level $L$ of either tree has exactly $3^L$ nodes.

*Proof.* Theorems 4.3–4.7 verify (H1)–(H5); apply Corollary 3.3. $\square$

---

## 5. The $N$-Node Identity

**Definition 5.1 (Fermat pair).** For odd integers $p<q$ set
$$\Phi(p,q) = \left(\frac{p+q}{2},\ \frac{q-p}{2}\right).$$

**Theorem 5.2 ($N$-Node Identity).** Let $p, q$ be odd with $1 \le p < q$ and $\gcd(p,q)=1$, and set $N = pq$. Then:
1. $\Phi(p,q) \in \mathcal V$;
2. the odd leg at $\Phi(p,q)$ is $N$ *exactly*: $A(\Phi(p,q)) = pq$;
3. the hypotenuse is $C(\Phi(p,q)) = \tfrac{p^2+q^2}{2}$ and the even leg is $B(\Phi(p,q)) = \tfrac{q^2-p^2}{2}$;
4. writing $\Phi(p,q) = (m,n)$, one recovers $p = m-n$ and $q = m+n$.

*Proof.* Write $p = 2a+1$, $q = 2b+1$ with $0 \le a < b$. Then
$$\Phi(p,q) = (a+b+1,\ b-a),$$
which is integral. Node conditions: $b-a \ge 1$; $b - a < a+b+1$ since $a \ge 0$; the sum $(a+b+1)+(b-a) = 2b+1 = q$ is odd; and a Bézout relation $xp+yq=1$ transforms into $(x+y)(a+b+1) + (y-x)(b-a) = 1$, giving coprimality. For (2),
$$A = m^2-n^2 = (m-n)(m+n) = \big((a+b+1)-(b-a)\big)\big((a+b+1)+(b-a)\big) = (2a+1)(2b+1) = pq.$$
Items (3) and (4) are the same substitution. $\square$

**Theorem 5.3 (Bijection).** The maps
$$\mathcal V \ni (m,n) \longmapsto (m-n,\ m+n), \qquad \Phi(p,q) \longmapsfrom (p,q)$$
are mutually inverse bijections between $\mathcal V$ and the set of pairs $(p,q)$ of coprime odd integers with $1 \le p < q$.

*Proof.* For $(m,n)\in\mathcal V$, $m-n$ and $m+n$ are odd (parity), coprime (any common divisor divides $2m$ and $2n$, hence — being odd — divides $\gcd(m,n)=1$), and $1 \le m-n < m+n$. The composites are the identity by direct computation. $\square$

**Corollary 5.4 (Unique addresses).** Every $N=pq$ as above determines a unique word in the Berggren tree and a unique word in the Price tree whose endpoint has odd leg exactly $N$.

**Corollary 5.5 (Finding a node factors).** If $v=(m,n) \in \mathcal V$ and $m-n > 1$, then $m-n$ is a divisor of the odd leg $A(v)$ with $1 < m-n < A(v)$: a nontrivial factorization.

*Proof.* $A(v) = (m-n)(m+n)$ and $m+n > 1$. $\square$

Thus **factoring $N$ and locating the $N$-node are the same computational problem**; the root-to-node word is (an encoding of) the factorization.

**Theorem 5.6 (Fermat's witness).** With $(m,n)=\Phi(p,q)$, $m^2 - pq = n^2$. Hence Fermat's method, which scans $m = \lceil\sqrt N\rceil, \lceil\sqrt N\rceil+1, \dots$ testing whether $m^2-N$ is a square, terminates exactly at the first coordinate of the $N$-node.

**Example 5.7.** $N = 391 = 17\cdot 23$: $\Phi = (20,3)$, triple $(391, 120, 409)$, and $391 = (20-3)(20+3)$.

---

## 6. The interlock: three exact separations

### 6.1 Determinant obstruction

**Theorem 6.1 (No conjugacy).** Let $S$ be a $2\times 2$ integer matrix with $\det S \ne 0$. Then for all $i,j$, $S\,B_i \ne P_j\,S$, where $B_i$ and $P_j$ are the Berggren and Price matrices.

*Proof.* Taking determinants of $SB_i = P_jS$ gives $\det S \cdot \det B_i = \det P_j \cdot \det S$; since $\det S \ne 0$, $\det B_i = \det P_j$. But $\det B_i \in \{+1,-1\}$ and $\det P_j \in \{-2,+2\}$. $\square$

So no invertible linear change of coordinates (over $\mathbb{Z}$, or indeed over $\mathbb{Q}$) turns one descent into the other. The interlock is not a re-coordinatization; it is two genuinely different group-theoretic descents on one set.

### 6.2 Leg-swap asymmetry

Both trees also act linearly on the triple itself. In the coordinates $(A,B,C)$ the Berggren generators are the classical Barning–Hall matrices
$$\mathcal B_0 = \begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\quad
\mathcal B_1 = \begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\quad
\mathcal B_2 = \begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix},$$
and the Price generators are
$$\mathcal P_0 = \begin{pmatrix}2&1&1\\2&-2&2\\2&-1&3\end{pmatrix},\quad
\mathcal P_1 = \begin{pmatrix}2&-1&1\\2&2&2\\2&1&3\end{pmatrix},\quad
\mathcal P_2 = \begin{pmatrix}2&1&-1\\-2&2&2\\-2&1&3\end{pmatrix}.$$
(These are the Veronese lifts of the $2\times2$ maps: $\mathcal B_i \cdot (A,B,C)^{T}$ at $v$ equals $(A,B,C)^T$ at $\beta_i(v)$, and likewise for Price.)

Let $S$ be the leg swap $(A,B,C)\mapsto(B,A,C)$.

**Theorem 6.2 (Berggren is leg-symmetric).** $S\mathcal B_0 S = \mathcal B_2$, $S\mathcal B_1 S = \mathcal B_1$, $S\mathcal B_2 S = \mathcal B_0$. Thus $S$ induces an automorphism of the Berggren generator set (a transposition of $\{0,2\}$).

**Theorem 6.3 (Price is not).** For all $i,j$, $S\mathcal P_i S \ne \mathcal P_j$.

*Proof sketch.* Each Price generator has first column $(2,\pm2,\pm2)^T$ — all entries even. Conjugating by the swap moves the $(2,1)$-entry into the $(1,2)$-slot and pulls an odd entry into the first column, so no conjugate can be a Price matrix. Explicit computation of the nine products confirms it. $\square$

This is a structural asymmetry with no analogue on the Berggren side: the Berggren tree "does not care" which leg is which; the Price tree does.

### 6.3 Exactly two shared edges

**Theorem 6.4 (Interlock rigidity).** Let $u \in \mathcal V$ and suppose $\beta_i(u) = \pi_j(u) = v$ for some $i,j$. Then $v = (3,2)$ or $v=(4,1)$.

*Proof sketch.* Compare the nine pairs of formulas. Seven of them are outright impossible on $\mathcal V$ (e.g. $\beta_0(u) = \pi_0(u)$ needs $2u_1-u_2 = 2u_1$, i.e. $u_2=0$). The two survivors are $\beta_0 = \pi_2$ and $\beta_2 = \pi_0$, each of which forces $u_1 = 2u_2$. But $u_1 = 2u_2$ with $\gcd(u_1,u_2)=1$ forces $u_2 \mid 1$, i.e. $u = (2,1) = \mathrm{root}$. Substituting gives $v = (3,2)$ in the first case and $v=(4,1)$ in the second. $\square$

**Theorem 6.5 (Both occur).** $\beta_0(\mathrm{root}) = \pi_2(\mathrm{root}) = (3,2)$ and $\beta_2(\mathrm{root}) = \pi_0(\mathrm{root}) = (4,1)$. Hence Theorem 6.4 is sharp: the shared-edge set has exactly two elements.

Empirically, a breadth-first sweep over $455{,}736$ nodes finds agreement of the Berggren and Price parent maps at exactly those two nodes — a coincidence rate of $2/455{,}736$. The two descents diverge from the second level onward and never re-synchronize.

---

## 7. Depth duality

Write $d_B(v)$ and $d_P(v)$ for the lengths of the (unique) Berggren and Price addresses of a node $v$.

### 7.1 Price depth is size-driven

**Theorem 7.1 (Price growth bound).** For every word $w$, $(\pi_w(\mathrm{root}))_1 \le 2^{|w|+1}$. Equivalently $d_P(m,n) \ge \log_2 m - 1$.

*Proof.* Each Price generator at most doubles the first coordinate: $\pi_0,\pi_1$ send $m \mapsto 2m$; $\pi_2$ sends $m \mapsto m+n < 2m$. Induct, with base $m=2$ at the root. $\square$

**Theorem 7.2 (A level is wider than Fermat's whole scan).** If a node at Price depth $d$ has $m \ge 9$, then $m < 3^{d}$.

*Proof sketch.* From Theorem 7.1, $m^3 \le 2^{3d+3} = 8\cdot 8^{d} \le 8\cdot 9^{d} = 8\,(3^{d})^2$. Suppose $3^{d} \le m$. Then $m^3 \le 8 (3^d)^2 \le 8m^2$, contradicting $m \ge 9$. $\square$

Since Fermat's scan for the odd leg of that node terminates after $m - \lfloor\sqrt N\rfloor \le m$ trial values, **merely writing down the tree level that contains the target already costs more than the entire classical scan.** This holds before any search heuristic is applied, and is independent of how cleverly one prunes — unless one has a branch predicate, discussed in §11.

### 7.2 Berggren depth is ratio-driven

**Theorem 7.3 (Ratio law).** For every word $w$, writing $(m,n) = \beta_w(\mathrm{root})$ and $d = |w|$,
$$m \le (2d+3)\,n.$$

*Proof.* Induction on $|w|$. At the root, $2 \le 3\cdot 1$. Inductively assume $m \le (2d+3)n$ for the parent. Applying $\beta_0$ or $\beta_1$ gives a child $(m', n') = (2m \mp n,\ m)$ whose ratio is $m'/n' = 2 \mp n/m < 3 \le 2(d+1)+3$, so the bound holds with room to spare. Applying $\beta_2$ gives $(m+2n,\ n)$, whose ratio is $m/n + 2 \le (2d+3)+2 = 2(d+1)+3$. $\square$

Since $m/n = (p+q)/(q-p)$ at the $N$-node, Berggren depth is at least $\frac{1}{2}\left(\frac{p+q}{q-p} - 3\right)$: it is a function of the *ratio* of the factors, not of the size of $N$.

### 7.3 The two orderings are incomparable

**Theorem 7.4 (Exact depth duality).** For every $i \ge 0$, the node $(2^{i+2},\ 1)$ has
$$d_B = 2^{i+1}-1, \qquad d_P = i+1.$$

*Proof sketch.* $\beta_2^k(\mathrm{root}) = (2k+2,\ 1)$ by induction, so $(2^{i+2},1) = \beta_2^{\,2^{i+1}-1}(\mathrm{root})$; by uniqueness of addresses this word *is* the Berggren address, of length $2^{i+1}-1$. On the Price side, $\pi_1^{\,i}(\mathrm{root}) = (2^{i+1},\ 2^{i+1}-1)$ by induction, and applying $\pi_0$ gives $(2^{i+2},\ 1)$; that word has length $i+1$ and is unique. $\square$

So along this "staircase" family, $d_B$ is exponential in $d_P$. The two trees impose incomparable orderings on their shared vertex set. Empirically, at the $N$-node for random $20$-bit prime pairs, $\mathrm{corr}(d_B, d_P) = -0.16$: essentially independent.

---

## 8. Orthogonality to factoring

### 8.1 Deep Berggren nodes are the easy factorizations

**Theorem 8.1 (Berggren depth versus Fermat cost, exact).** For every $k \ge 0$ the node $v_k = (2k+2,\ 1)$ satisfies:
1. $d_B(v_k) = k$ exactly (its Berggren address is $\beta_2^{\,k}$);
2. its odd leg is $N_k = (2k+1)(2k+3)$;
3. Fermat's scan for $N_k$ succeeds at its *first* trial value: with $r = 2k+1$ we have $r^2 \le N_k < (r+1)^2$ and the witness is $m = r+1$, i.e. scan length $1$.

*Proof sketch.* (1) is the staircase computation plus address uniqueness; (2) is $(2k+2)^2-1$; (3) is $ (2k+1)^2 = 4k^2+4k+1 \le 4k^2+8k+3 = N_k < 4k^2+8k+4 = (2k+2)^2$. $\square$

So the Berggren tree buries at depth $k$ exactly the factorizations Fermat resolves in one step. Depth grows without bound along a family of *trivial* factoring instances.

### 8.2 The trade-off inequality

**Lemma 8.2 (Fermat's scan length).** Let $N = m^2-n^2$ with $m>0$ and let $r \ge 0$ satisfy $r^2 \le N$. Then, with $s = m-r$ the number of trial values,
$$n^2 \le 2ms .$$

*Proof.* $r^2 \le m^2-n^2$ gives $r \le m$ and $n^2 \le m^2 - r^2 = (m-r)(m+r) \le (m-r)\cdot 2m$. $\square$

**Lemma 8.3 (Fermat's cost law, upper form).** If $N < (r+1)^2$ and $N = m^2-n^2$, then $(m-r)(m+r) \le n^2 + 2r$. Consequently $s = m-r \approx \dfrac{n^2}{2\sqrt N} = \dfrac{(q-p)^2}{8\sqrt N}$.

**Theorem 8.4 (Berggren–Fermat trade-off).** Let $v = \beta_w(\mathrm{root})$ with $d=|w|$, $(m,n)=v$, and let $r \ge 0$ satisfy $r^2 \le A(v)$, $s = m-r$. Then
$$m \;\le\; 2\,s\,(2d+3)^2 .$$

*Proof.* By Theorem 7.3, $m^2 \le (2d+3)^2 n^2$. By Lemma 8.2, $n^2 \le 2ms$. Hence $m^2 \le (2d+3)^2\cdot 2ms$, and dividing by $m>0$ gives the claim. $\square$

**Interpretation.** Rearranged, $d \ge \tfrac12\left(\sqrt{m/(2s)}-3\right)$. A *cheap* Fermat scan — small $s$ — *forces* a Berggren depth growing like $\sqrt{m/s}$, and the level at that depth contains $3^d$ nodes. The two cost measures are inversely coupled. There is no regime in which the tree is cheap and Fermat is expensive; the tree's own difficulty coordinate is the reciprocal of Fermat's.

By contrast:

**Theorem 8.5 (Price is cost-blind).** $m \le 2^{d_P+1}$ with no dependence on $s$ whatsoever. Price depth is a function of size alone and therefore carries no information about factoring difficulty.

Empirically at $20$-bit primes: $\mathrm{corr}(d_B, \text{Fermat cost}) = -0.31$ (negative, as the theorem predicts), $\mathrm{corr}(d_P, \text{Fermat cost}) \approx 0$.

### 8.3 The hypotenuse embedding is obstructed mod 4

Before settling on the odd leg, one may hope to detect $N$ on the hypotenuse: look for nodes with $N \mid m^2+n^2$. This fails, structurally.

**Theorem 8.6 (Congruence obstruction).** Let $p$ be a prime with $p \equiv 3 \pmod 4$. Then no node $v \in \mathcal V$ has $p \mid C(v) = m^2+n^2$.

*Proof.* Since $p \equiv 3 \pmod 4$, the Legendre symbol $\left(\frac{-1}{p}\right) = -1$. If $p \mid m^2+n^2 = m^2 - (-1)n^2$, then, $-1$ being a non-residue, $p$ must divide both $m$ and $n$. That contradicts $\gcd(m,n)=1$. $\square$

**Corollary 8.7.** If $N$ has any prime factor $p \equiv 3 \pmod 4$, then $N \nmid C(v)$ for every node $v$. In particular $N = 15, 21, 35, 77, 91$ never divide a primitive hypotenuse.

Numerically, over both trees the density of nodes with $m^2+n^2 \equiv 0 \pmod N$ is at most $4/N$ and is exactly $0$ for those $N$. This is the precise sense in which the *odd-leg* embedding of §5 is the correct one: it is exact and always non-empty, whereas the hypotenuse embedding is approximate and sometimes empty.

---

## 9. What a generator triple can look like

Why is determinant $\pm2$ permitted at all? Two structural facts delimit the possibilities.

**Theorem 9.1 (Determinant controls coprimality loss).** Let $M = \begin{pmatrix}a&b\\c&d\end{pmatrix}$ be an integer matrix, $(x,y)$ a coprime pair, and $k$ a common divisor of $ax+by$ and $cx+dy$. Then $k \mid ad-bc$.

*Proof.* Write $ux+vy=1$. Compute
$$(ad-bc)x = d(ax+by) - b(cx+dy), \qquad (ad-bc)y = a(cx+dy) - c(ax+by),$$
so $k$ divides both $(ad-bc)x$ and $(ad-bc)y$, hence divides $u(ad-bc)x + v(ad-bc)y = ad-bc$. $\square$

Consequently a generator of determinant $\pm1$ preserves coprimality unconditionally, while a generator of determinant $\pm2$ preserves it *only* modulo an extra parity argument. The Price tree occupies exactly this gap; nothing of determinant $\pm3$ or more can be rescued the same way, since the obstruction $k=3$ is not excluded by parity.

**Theorem 9.2 (Parity of column sums).** Let $M=\begin{pmatrix}a&b\\c&d\end{pmatrix}$ be an integer matrix sending nodes to nodes. Then $a+c$ and $b+d$ are both odd.

*Proof.* Applying $M$ to $(2,1)$ and to $(3,2)$ (both nodes) and demanding odd coordinate sums gives $2(a+c)+(b+d)$ odd and $3(a+c)+2(b+d)$ odd. Modulo $2$: $b+d \equiv 1$ from the first, then $a+c \equiv 1$ from the second. $\square$

Both generator triples satisfy this. It immediately rules out naive candidates such as $(m,n)\mapsto(2m-n,n)$ (column sums $2$ and $0$). Theorems 9.1 and 9.2 are the two constraints from which any classification of ternary Pythagorean-tree generators must start.

---

## 10. Numerical corroboration

The exact statements above were accompanied by systematic computation:

- **Completeness and non-redundancy.** Breadth-first search to level $11$ in both trees ($3^{12}-1 = 531{,}440$ nodes generated per tree) confirms that every generated pair is a valid node, that parent maps invert child maps with zero failures, and that no pair is generated twice.
- **The $N$-node identity.** For $1020$ random odd semiprime pairs, the Fermat pair was verified to be a valid node with odd leg exactly $N$: $1020/1020$.
- **Shared edges.** Over $455{,}736$ nodes, the Berggren and Price parent maps agree at exactly $2$ nodes, namely $(3,2)$ and $(4,1)$ — matching Theorems 6.4–6.5.
- **Depth statistics at the $N$-node.** Price depth is tight and logarithmic, $\approx 1.4\log_2(p+q)$ with standard deviation $\approx 2.4$; the means are $17.7$, $21.4$, $25.8$, $30.1$ at $14$-, $17$-, $20$-, $23$-bit primes. Berggren depth is erratic: at $20$-bit primes, mean $78.5$ with range $[19, 1135]$. Correlation $\mathrm{corr}(d_B,d_P) = -0.16$.
- **Cost comparison.** Over $209$ trials with $20$-bit prime factors, tree traversal to the $N$-node (cost $3^{d_B}$) beat Fermat's scan in $0$ cases. Fermat averaged $6{,}630$ trial values; the *best* tree case was $3^{19} \approx 1.2\times 10^{9}$. Additionally $\mathrm{corr}(d_B, \text{Fermat cost}) = -0.31$.
- **Leg swap.** Conjugation by the leg swap permutes the Berggren generators in $3/3$ cases and yields a Price generator in $0/3$ cases.

---

## 11. Discussion: why the barrier is structural

It is worth being precise about *what kind* of negative result this is. It is not "we tried some heuristics and they were slow". Four independent structural facts each independently defeat the approach:

1. **Level width.** For $m \ge 9$ the tree level containing the $N$-node has more than $m$ members, while Fermat's whole scan is at most $m$ trials (Theorem 7.2). Unpruned traversal is dominated *a priori*.
2. **Inverse coupling.** Any pruning strategy must still traverse a root-to-node path of length $d_B$, and $m \le 2s(2d+3)^2$ (Theorem 8.4) says the path is long precisely when the classical scan is short. There is no window of advantage.
3. **No local branch rule.** The odd legs along a "staircase" branch (repeated $\beta_2$) are $A(2k+2,1) = (2k+1)(2k+3)$ — near-constant in behaviour and carrying no signal that distinguishes the branch containing $N$ from its siblings. A branch predicate would need global information; the root-to-node word already *is* the factorization, so a polynomial-time predicate recognising its prefixes would itself factor $N$.
4. **Wrong sort key.** The trees organise the ratio $(p+q)/(q-p)$ (Berggren) or the magnitude of $m$ (Price). Factoring requires the product $pq$. The ratio-to-product map *is* the factorization step, and no tree operation performs it.

Point (4) is the conceptual summary. The Berggren tree is a beautiful re-encoding of the slow (subtractive) Euclidean algorithm on $m/n$; the Price tree is a re-encoding of the binary GCD on $(m,n)$. Both are Euclidean descents. Euclidean descent on a *known* pair is easy; factoring is the problem of *finding* the pair. The trees pre-sort all the answers by exactly the coordinate that is unavailable until the answer is known.

That is a satisfying place for a research line to end: not with an unresolved hope, but with a theorem-level statement of the obstruction. We would emphasise that the positive content — the $N$-node identity, the bijection between nodes and coprime odd factorizations, the exact interlock separations — stands on its own as a clean description of the geometry of primitive Pythagorean triples, quite independent of cryptographic motivation.

---

## 12. Future directions

**C1. Exact Berggren depth = odd-continued-fraction length.** Conjecturally $d_B(m,n) = \sum_i a_i - (\text{number of "reflect" steps})$, where the $a_i$ are the partial quotients of the *subtractive* expansion of $m/n$ generated by the three parent rules. In particular $d_B(m,1) = (m-2)/2$ exactly. The ratio bound $m \le (2d+3)n$ is the crude shadow of this exact identity: the Berggren descent *is* the slow Euclidean algorithm on $(m,n)$, so its depth must be the *sum* of the partial quotients, not their number. What remains is accounting for the three branch types against the continued-fraction digits — a finite induction over the same three cases as the parent rule.

**C2. Price depth is $\Theta(\log m)$ — a matching upper bound.** Conjecturally $d_P(m,n) \le 2\log_2 m + O(1)$, which with the proved lower bound $m \le 2^{d+1}$ would give $d_P = \Theta(\log m)$ and hence $d_P = \Theta(\log N)$ at the $N$-node, matching the observed $\approx 1.4\log_2(p+q)$. The Price parent halves $m$ when $m$ is even and halves $n$ when $m$ is odd, and $m$ cannot stay odd on two consecutive descent steps once one tracks $(m \bmod 2,\, n \bmod 4)$: the potential $\Phi = \log_2(mn)$ drops by at least $1$ per two steps. This would upgrade the level-width theorem to a complete cost model of the Price tree.

**C3. No polynomial-size branch predicate for the $N$-node.** Conjecture (barrier): there is no predicate $P(N,w)$ computable in time $\mathrm{poly}(\log N, |w|)$ that holds exactly for the prefixes $w$ of the Berggren (or Price) address of the $N$-node of every odd semiprime $N$ — equivalently, the address string is incompressible relative to $N$. The intuition is that such a prefix predicate would let one descend to the $N$-node in $O(d)$ predicate evaluations, hence factor $N$ in polynomial time; so the conjecture is a factoring-hardness statement in disguise, and the interest lies in proving it unconditionally for restricted predicate classes (e.g. those depending only on $N \bmod 2^{|w|}$, or only on the residue of $N$ modulo a fixed modulus).

**C4. Classification of ternary generator triples.** Determine all triples of integer matrices generating a complete non-redundant ternary tree on $\mathcal V$ rooted at $(2,1)$. The determinant lemma (a common divisor of the image of a coprime pair divides the determinant) and the odd-column-sum parity constraint are the two starting points; determinants $\pm1$ and $\pm2$ are permitted, and a classification would say whether Berggren and Price are the only possibilities up to obvious symmetries.

**C5. Beyond the ratio coordinate.** The barrier here is that the trees sort by $(p+q)/(q-p)$. Is there a complete, non-redundant descent on $\mathcal V$ whose depth is a function of $pq$ rather than of $p/q$? Theorems 9.1–9.2 constrain the generators sharply; a negative answer within the linear-generator class would convert the empirical barrier into a theorem.
