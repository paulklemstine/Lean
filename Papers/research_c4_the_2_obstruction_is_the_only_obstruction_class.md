# The Ternary Pythagorean Trees: A Complete Classification

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

Let $\mathcal{N} = \{(m,n) \in \mathbb{Z}^2 : 1 \le n < m,\ \gcd(m,n) = 1,\ m+n \text{ odd}\}$ be the set of Euclid parameters of primitive Pythagorean triples, with distinguished root $(2,1)$ corresponding to $(3,4,5)$. We study the integer linear maps $(m,n) \mapsto (am+bn,\, cm+dn)$ that preserve $\mathcal{N}$, and the triples of such maps that organise $\mathcal{N}$ into a rooted ternary tree.

We prove three groups of results. **First**, a complete and finitely checkable characterisation of the node-preserving maps: such a map exists exactly when $a+c$ and $b+d$ are odd, no odd prime divides $ad-bc$, and the rows $(c,d)$ and $(a-c,\,b-d)$ are nonzero and nonnegative on the cone $0 < n < m$. A consequence, which we call the **power-of-two theorem**, is that the determinant of any node-preserving map is nonzero with $|\det|$ a power of $2$ — the sharp form of the "$\pm 2$ obstruction". **Second**, a complete classification: up to relabelling of the branches there are exactly three ternary Pythagorean trees, namely the Berggren triple (determinants $1,-1,1$), the Price triple (determinants $2,-2,2$), and a previously overlooked *mixed* triple $\{(1,3;0,2),\,(2,-1;1,0),\,(2,0;1,-1)\}$ with determinants $2,1,-2$. The existence of the mixed tree refutes the conjectured Berggren/Price dichotomy; the accompanying bound $|\det| \le 2$ for every branch confirms the quantitative half of that conjecture. **Third**, structural corollaries valid for *every* such tree: every branch strictly increases the Euclid parameter $m$; the node $(3,2)$ (triple $(5,12,13)$) is always a child of the root; every primitive Pythagorean triple is generated from $(3,4,5)$ exactly once; the branch densities satisfy the conservation law $\sum_i 1/\big(a_i(a_i+b_i)\big) = 1$; and the determinant spectrum $\sum_i |\det M_i| \in \{3,5,6\}$ separates the three trees.

**Keywords:** primitive Pythagorean triples; Euclid parameters; Berggren tree; Price tree; ternary tree; determinant obstruction; lattice cone; branch density.

---

## 1. Introduction

### 1.1 Background

Euclid's parametrisation sends a pair of integers $m > n \ge 1$ to the Pythagorean triple

$$(x,y,z) = (m^2 - n^2,\ 2mn,\ m^2 + n^2),$$

and it is classical that this is a bijection from

$$\mathcal{N} \;=\; \{(m,n) : 1 \le n < m,\ \gcd(m,n)=1,\ m+n \text{ odd}\}$$

onto the set of primitive Pythagorean triples with positive entries and even second leg. The root $(2,1)$ corresponds to $(3,4,5)$.

Since the mid-twentieth century it has been known that the primitive triples can be organised into an infinite rooted ternary tree in which every triple appears exactly once. Berggren's construction uses three matrices of determinant $\pm 1$; Price's uses three matrices of determinant $\pm 2$. In Euclid coordinates these are, respectively,

$$A = \begin{pmatrix}2&-1\\1&0\end{pmatrix},\quad B = \begin{pmatrix}2&1\\1&0\end{pmatrix},\quad C = \begin{pmatrix}1&2\\0&1\end{pmatrix}$$

and

$$P_0 = \begin{pmatrix}1&1\\0&2\end{pmatrix},\quad P_1 = \begin{pmatrix}2&0\\1&-1\end{pmatrix},\quad P_2 = \begin{pmatrix}2&0\\1&1\end{pmatrix},$$

acting by $(m,n) \mapsto (am+bn,\ cm+dn)$.

The natural classification question — *are these the only ones?* — has circulated as a conjecture in the following form: up to relabelling, the only ternary trees of integer linear maps on $\mathcal{N}$ with root $(2,1)$ are the Berggren triple (determinants $\pm 1$) and the Price triple (determinants $\pm 2$), and no triple with $|\det| \ge 3$ exists.

### 1.2 Results of this paper

We settle the question completely, and the answer differs from the conjecture in one essential respect.

* The determinant claim is true and can be strengthened dramatically: **every** node-preserving integer linear map has $|\det|$ equal to a power of two (Theorem 3.4). No odd prime can divide the determinant. Since all six classical matrices have $|\det| \le 2$, and since we classify all trees, it follows that no branch of any ternary Pythagorean tree has $|\det| \ge 3$ (Corollary 6.3).
* The classification claim is **false**. There is a third tree, mixing determinant regimes:

$$F_0 = \begin{pmatrix}1&3\\0&2\end{pmatrix}\ (\det 2),\qquad A\ (\det 1),\qquad P_1\ (\det -2).$$

  This triple is a genuine ternary tree on $\mathcal{N}$ (Theorem 5.3) whose determinant multiset is neither $\{\pm1,\pm1,\pm1\}$ nor $\{\pm2,\pm2,\pm2\}$, and is therefore not a relabelling of either classical tree.
* The corrected statement is a complete classification: **exactly three** ternary Pythagorean trees exist, up to relabelling (Theorem 6.2).

We also isolate the *reason* the naive conjecture failed. The determinant is not the invariant of a tree; what is invariant is (i) the $2$-adic constraint on each branch, and (ii) a **density budget** which the three branches must exactly exhaust: $\sum_i 1/\big(a_i(a_i+b_i)\big) = 1$ (Theorem 8.2). The mixed tree exists because the budget equation $1 = \frac14 + \frac12 + \frac14$ admits a second realisation.

### 1.3 Organisation

Section 2 fixes definitions. Section 3 proves the determinant obstruction and the characterisation of node-preserving maps. Section 4 proves rigidity results valid for all trees (growth, forced root child, generation). Section 5 verifies that the three explicit triples are trees. Section 6 proves the classification. Section 7 gives the dictionary with primitive triples. Section 8 develops the conservation law and the determinant spectrum. Section 9 reports the computational evidence, Section 10 discusses applications and Section 11 lists open directions.

---

## 2. Definitions

**Definition 2.1 (Node).** A pair $(m,n) \in \mathbb{Z}^2$ is a **node** if $1 \le n < m$, $\gcd(m,n) = 1$ and $m+n$ is odd. We write $\mathcal{N}$ for the set of nodes and call $(2,1)$ the **root**.

**Definition 2.2 (Integer map).** An **integer map** is a quadruple $M = (a,b;c,d) \in \mathbb{Z}^4$, thought of as the matrix $\begin{pmatrix}a&b\\c&d\end{pmatrix}$, acting on pairs by
$$M \cdot (m,n) \;=\; (am+bn,\ cm+dn).$$
Its **determinant** is $\det M = ad - bc$.

**Definition 2.3 (Node preservation).** $M$ **preserves** $\mathcal{N}$ if $M\cdot(m,n) \in \mathcal{N}$ for every $(m,n) \in \mathcal{N}$.

**Definition 2.4 (Ternary Pythagorean tree).** A triple $T = (M_0, M_1, M_2)$ of integer maps is a **ternary Pythagorean tree** if:

1. *(preservation)* each $M_i$ preserves $\mathcal{N}$;
2. *(the root has no parent)* $M_i \cdot (m,n) \ne (2,1)$ for every node $(m,n)$ and every $i$;
3. *(covering)* every node $\ne (2,1)$ equals $M_i \cdot (m,n)$ for some $i$ and some node $(m,n)$;
4. *(uniqueness)* if $M_i \cdot (x,y) = M_j \cdot (u,v)$ with $(x,y), (u,v)$ nodes, then $i = j$, $x = u$ and $y = v$.

Conditions (2)–(4) say precisely that assigning to each non-root node its unique parent makes $\mathcal{N}$ the vertex set of a rooted tree with root $(2,1)$ in which every vertex has exactly three children, labelled by $\{0,1,2\}$.

**Definition 2.5 (Euclid map and primitive triples).** For $(m,n) \in \mathbb{Z}^2$ put $\tau(m,n) = (m^2-n^2,\ 2mn,\ m^2+n^2)$. A triple $(x,y,z)$ is a **primitive Pythagorean triple with even second leg** (PPT) if $x^2+y^2=z^2$, $x,y > 0$, $\gcd(x,y) = 1$ and $y$ is even.

**Definition 2.6 (Branch density).** For an integer map $M = (a,b;c,d)$, its **branch density** is the rational number
$$\rho(M) \;=\; \frac{1}{a(a+b)}$$
(well-defined for node-preserving $M$, since Lemma 4.1 gives $a \ge 1$ and $a+b \ge 1$).

---

## 3. The obstruction and the characterisation

### 3.1 The Bézout identity behind everything

**Lemma 3.1 (Divisor transfer).** Let $M = (a,b;c,d)$, let $\gcd(m,n) = 1$, and write $(X,Y) = M\cdot(m,n)$. If an integer $g$ divides both $X$ and $Y$, then $g \mid \det M$.

*Proof.* Choose $u,v$ with $um+vn=1$. Expanding,
$$(ud-vc)X + (va-ub)Y = (ad-bc)(um+vn) = \det M,$$
which is a $\mathbb{Z}$-linear combination of $X$ and $Y$. $\square$

This single identity is the source of all obstructions: a node-preserving map must have coprime images, and Lemma 3.1 says the determinant is the only obstacle.

### 3.2 Necessary conditions

**Lemma 3.2 (Parity).** If $M$ preserves $\mathcal{N}$ then $a+c$ and $b+d$ are odd.

*Proof.* Apply $M$ to the two nodes $(2,1)$ and $(3,2)$. Oddness of the coordinate sum of the images gives $2(a+c) + (b+d)$ odd and $3(a+c)+2(b+d)$ odd. The first forces $b+d$ odd, and then the second forces $a+c$ odd. $\square$

**Lemma 3.3 (Cone conditions).** If $M$ preserves $\mathcal{N}$ then
$$c \ge 0,\quad c+d \ge 0,\quad (c,d)\ne(0,0), \qquad a - c \ge 0,\quad (a-c)+(b-d) \ge 0,\quad (a-c,\,b-d) \ne (0,0).$$

*Proof.* Preservation demands $Y = cm+dn \ge 1$ and $X - Y = (a-c)m + (b-d)n \ge 1$ on all nodes, so it suffices to show that a linear form $\ell(m,n) = pm+qn$ that is $\ge 1$ on all nodes must satisfy $p \ge 0$, $p+q\ge 0$ and $(p,q)\ne(0,0)$. The last is clear from $\ell(2,1)\ge 1$. For $p \ge 0$: if $p \le -1$, evaluate at the node $(m,1)$ with $m = 2(|q|+2)$ even, obtaining $\ell \le -m + |q| < 0$. For $p+q\ge 0$: if $p+q \le -1$, evaluate at the spine node $(m,m-1)$ with $m = |q|+2$, obtaining $\ell = (p+q)m - q \le -m + |q| < 0$. $\square$

Conversely we record the positivity statement used for sufficiency.

**Lemma 3.4 (Cone positivity).** If $p \ge 0$, $p+q\ge0$ and $(p,q)\ne(0,0)$, then $pm+qn \ge 1$ for every node $(m,n)$ — indeed for every integer pair with $1 \le n < m$.

*Proof.* If $p = 0$ then $q \ge 1$ and $pm+qn = qn \ge 1$. If $p \ge 1$ and $q \ge 0$ then $pm+qn \ge m \ge 2$. If $p \ge 1$ and $q < 0$ then $pm+qn > pm+qm = (p+q)m \ge 0$ using $n<m$ and $q<0$, and integrality gives $\ge 1$. $\square$

### 3.3 The power-of-two theorem

**Theorem 3.5 (Odd prime obstruction).** If $M$ preserves $\mathcal{N}$, then no odd prime divides $\det M$. In particular $\det M \ne 0$, and $|\det M|$ is a power of $2$.

*Proof.* Suppose $p \ge 3$ is a prime dividing $\det M$. We exhibit a node whose image has both coordinates divisible by $p$; since the image of a node must be coprime, this is a contradiction.

*Case 1: $p \mid a$ and $p \mid c$.* Take the node $(p+1, p)$, which is legitimate: consecutive integers are coprime and their sum $2p+1$ is odd. Its image is $\big(a(p+1)+bp,\ c(p+1)+dp\big)$, and both entries are divisible by $p$.

*Case 2: $p \nmid c$.* Since $p \nmid c$ there is $s$ with $cs + d \equiv 0 \pmod p$. Because $p$ is odd, the arithmetic progression $s + p\mathbb{Z}$ contains arbitrarily large even integers; pick an even $m \ge 2$ with $m \equiv s \pmod p$. Then $(m,1)$ is a node ($m$ even, $\gcd(m,1)=1$, $m+1$ odd) and $Y = cm+d \equiv 0 \pmod p$. From the identity
$$c\,X \;=\; c(am+b) \;=\; a(cm+d) - \det M \;=\; a\,Y - \det M,$$
we get $p \mid cX$, and since $p \nmid c$ and $p$ is prime, $p \mid X$.

*Case 3: $p \nmid a$.* Symmetrically, choose $s$ with $as + b \equiv 0 \pmod p$ and an even $m \ge 2$ with $m \equiv s$; then $p \mid X$, and $aY = cX + \det M$ gives $p \mid aY$, hence $p \mid Y$.

These cases are exhaustive (if Case 1 fails then $p\nmid a$ or $p\nmid c$). Since $3 \mid 0$, the theorem also excludes $\det M = 0$. A nonzero integer with no odd prime factor has absolute value a power of $2$. $\square$

### 3.4 Sufficiency: the characterisation

**Definition 3.6 (Admissibility).** $M = (a,b;c,d)$ is **admissible** if
1. $a+c$ and $b+d$ are odd;
2. no odd prime divides $\det M$;
3. $c \ge 0$, $c+d\ge0$, $(c,d)\ne(0,0)$;
4. $a-c \ge 0$, $(a-c)+(b-d) \ge 0$, $(a-c,b-d)\ne(0,0)$.

**Theorem 3.7 (Characterisation).** An integer map preserves $\mathcal{N}$ if and only if it is admissible.

*Proof.* Necessity is Lemmas 3.2, 3.3 and Theorem 3.5. For sufficiency, let $M$ be admissible and $(m,n)$ a node, $(X,Y) = M\cdot(m,n)$.

*Odd sum.* $X + Y = (a+c)m + (b+d)n$; writing $a+c$ and $b+d$ as odd numbers and using $m+n$ odd, this sum is odd.

*Bounds.* Lemma 3.4 applied to $(c,d)$ gives $Y \ge 1$; applied to $(a-c,\,b-d)$ it gives $X - Y \ge 1$, hence $1 \le Y < X$.

*Coprimality.* Let $q$ be a prime dividing $\gcd(X,Y)$. By Lemma 3.1, $q \mid \det M$. If $q = 2$ then $X+Y$ would be even, contradicting the previous paragraph. If $q$ is odd, it contradicts condition (2). Hence $\gcd(X,Y)=1$ and $(X,Y)$ is a node. $\square$

Theorem 3.7 is *effective*: admissibility involves only linear inequalities, two parities, and a factorisation of a single integer, so the node-preserving maps in any box $|a|,|b|,|c|,|d| \le R$ can be enumerated exactly.

---

## 4. Rigidity: what every tree must do

Throughout this section $M$ is node-preserving and $T = (M_0,M_1,M_2)$ is a ternary Pythagorean tree.

**Lemma 4.1 (Positivity of the top row).** $a \ge 1$ and $a+b \ge 1$.

*Proof.* Since $c \ge 0$ and $a \ge c$ we have $a \ge 0$; if $a = 0$ then $c = 0$ too, so $\det M = ad - bc = 0$, contradicting Theorem 3.5. Hence $a \ge 1$. For the second claim, add the two cone inequalities: $a+b = \big[(a-c)+(b-d)\big] + (c+d) \ge 0$. Suppose $a+b=0$, i.e. $b = -a$. If $c+d \ge 1$, evaluate at the spine nodes $(m,m-1)$: the first image coordinate is $am + b(m-1) = a$, a constant, while the second is $(c+d)m - c \to \infty$, contradicting $Y < X$ for large $m$. So $c+d = 0$, whence $\det M = ad - bc = ad + ac = a(c+d) = 0$, contradicting Theorem 3.5. Hence $a+b \ge 1$. $\square$

**Lemma 4.2 (Root minimality).** For every node $(m,n)$, $\ (M\cdot(m,n))_1 \ge 2a+b$, with equality at the root.

*Proof.* If $b \ge 0$ then $am+bn \ge 2a+b$ because $m\ge2$ and $n\ge1$. If $b<0$ then $n \le m-1$ gives $bn \ge b(m-1)$, so $am+bn \ge (a+b)m - b \ge 2(a+b) - b = 2a+b$, using $a+b\ge1$ and $m\ge2$. $\square$

**Lemma 4.3 (No identity branch).** If $M$ preserves $\mathcal{N}$ with $a=1, b=0$, then $c=0$ and $d=1$, i.e. $M$ is the identity. Consequently no branch of a tree has top row $(1,0)$, since the identity maps the root to the root, violating axiom (2).

*Proof.* $0 \le c \le a = 1$ and parity of $a+c$ force $c = 0$. Then $c+d\ge0$ and $(c,d)\ne(0,0)$ give $d\ge1$, and $\det M = d$ is odd by parity of $b+d$; as $|\det M|$ is a power of $2$ (Theorem 3.5), $d=1$. $\square$

**Theorem 4.4 (Growth).** Every branch of a ternary Pythagorean tree strictly increases the first Euclid parameter: $\big(M_i\cdot(m,n)\big)_1 > m$ for every node $(m,n)$.

*Proof.* Write $X = am+bn$. If $b \ge 1$ then $X \ge am + 1 > m$ if $a\ge1$. If $b = 0$ then $a\ge2$ by Lemma 4.3, so $X = am \ge 2m > m$. If $b < 0$ then $X = am+bn \ge am + b(m-1) = (a+b)m - b \ge m - b > m$, using $a+b\ge1$ and $n\le m-1$. $\square$

**Theorem 4.5 (Forced root child).** In every ternary Pythagorean tree there is exactly one index $i$ with $M_i\cdot(2,1) = (3,2)$.

*Proof.* $(3,2)$ is a node and is not the root, so it has a parent $(x,y)$ via some branch $i$. By Theorem 4.4, $x < 3$, and the only node with $m<3$ is $(2,1)$. Uniqueness of the index follows from axiom (4). $\square$

**Theorem 4.6 (Generation).** In every ternary Pythagorean tree, every node is obtained from the root $(2,1)$ by a finite word in the three branches.

*Proof.* Strong induction on $m$. If $(m,n) = (2,1)$, done. Otherwise axiom (3) supplies a parent $(x,y)$ with $M_i\cdot(x,y) = (m,n)$, and Theorem 4.4 gives $x < m$. Apply the inductive hypothesis to $(x,y)$. The induction terminates because $m \ge 2$ for all nodes. $\square$

**Corollary 4.7.** Every branch of every ternary Pythagorean tree has $|\det| = 2^k$ for some $k \ge 0$ (immediate from Theorem 3.5).

---

## 5. Three trees

We record the three triples and the descent rule that proves each is a tree. In each case the verification of Definition 2.4 amounts to: admissibility of each matrix (Theorem 3.7); an explicit *parent formula* for each region, together with a proof that the parent is a node; and a disjointness check.

**Theorem 5.1 (Berggren).** The triple $\{A, B, C\}$ with
$$A\cdot(m,n) = (2m-n,\ m),\quad B\cdot(m,n)=(2m+n,\ m),\quad C\cdot(m,n)=(m+2n,\ n)$$
(determinants $1,-1,1$) is a ternary Pythagorean tree.

*Proof sketch (descent by ratio).* Given a non-root node $(m,n)$, compare $m$ with $2n$ and $3n$.
* If $m < 2n$: the parent is $(n,\ 2n-m)$ via $A$.
* If $m = 2n$: coprimality forces $n = 1$, so $(m,n)=(2,1)$ is the root.
* If $2n < m < 3n$: the parent is $(n,\ m-2n)$ via $B$.
* If $m = 3n$: coprimality forces $n=1$, $m=3$, but then $m+n = 4$ is even — impossible.
* If $m > 3n$: the parent is $(m-2n,\ n)$ via $C$.

In each case one checks that the proposed parent is a node: the inequalities are immediate, coprimality follows because the inverse substitution is unimodular, and the parity is preserved. The images are the three disjoint regions $m<2n$, $2n<m<3n$, $3n<m$, which gives both uniqueness of the branch and non-attainment of the root. Injectivity within a branch follows from $\det \ne 0$. $\square$

**Theorem 5.2 (Price).** The triple $\{P_0,P_1,P_2\}$ with
$$P_0\cdot(m,n)=(m+n,\ 2n),\quad P_1\cdot(m,n)=(2m,\ m-n),\quad P_2\cdot(m,n)=(2m,\ m+n)$$
(determinants $2,-2,2$) is a ternary Pythagorean tree.

*Proof sketch (descent by parity and halving).* Given a non-root node $(m,n)$:
* If $n$ is even, write $n = 2k$; then $\gcd(m,k)=1$ and the parent is $(m-k,\ k)$ via $P_0$.
* If $n$ is odd then $m$ is even, $m = 2j$ with $\gcd(j,n)=1$. Compare $n$ with $j$:
  * $n < j$: parent $(j,\ j-n)$ via $P_1$;
  * $n = j$: then $m = 2n$, so coprimality forces $n=1$ and $(m,n)$ is the root;
  * $n > j$: parent $(j,\ n-j)$ via $P_2$.
Each parent is a node by the same unimodular-substitution argument, and the images are the three disjoint regions "$n$ even", "$m$ even and $2n<m$", "$m$ even and $m<2n$". $\square$

**Theorem 5.3 (The mixed tree).** The triple $\{F_0, A, P_1\}$ with
$$F_0\cdot(m,n) = (m+3n,\ 2n),\quad A\cdot(m,n)=(2m-n,\ m),\quad P_1\cdot(m,n)=(2m,\ m-n)$$
(determinants $2,\,1,\,-2$) is a ternary Pythagorean tree.

*Proof sketch (hybrid descent).* Given a non-root node $(m,n)$:
* If $m < 2n$: the *ratio* rule applies — parent $(n,\ 2n-m)$ via $A$.
* If $m = 2n$: the root, as before.
* If $m > 2n$: the *parity* rule applies. If $n = 2k$ is even, the parent is $(m-3k,\ k)$ via $F_0$ — one checks $m - 3k > k$ precisely because $m > 2n = 4k$. If $n$ is odd then $m = 2j$ is even and the parent is $(j,\ j-n)$ via $P_1$, with $j > n$ because $m > 2n$.

The three image regions — $\{m<2n\}$ for $A$, $\{n$ even, $2n<m\}$ for $F_0$, and $\{m$ even, $n$ odd, $2n<m\}$ for $P_1$ — are pairwise disjoint: the first is separated from the other two by the ratio, and the last two by the parity of the second coordinate ($F_0$ always outputs an even second coordinate $2n$, while the second coordinate $m-n$ of a $P_1$-image is odd because $m+n$ is odd). Their union is all non-root nodes by the case analysis above. $\square$

**Theorem 5.4 (Refutation of the dichotomy).** There exists a ternary Pythagorean tree whose determinants are neither all $\pm1$ nor all $\pm2$. Consequently the conjecture that every ternary Pythagorean tree is a relabelling of the Berggren or the Price triple is false.

*Proof.* The mixed tree has determinant multiset $\{2,1,-2\}$; the multiset of determinants is invariant under relabelling of branches, and $\{2,1,-2\}$ is neither $\{\pm1,\pm1,\pm1\}$ nor $\{\pm2,\pm2,\pm2\}$. $\square$

The three trees are pairwise distinct as triples of matrices: for instance, the determinant multiset already distinguishes all three.

---

## 6. The classification

The classification is a forcing argument. Its finiteness rests on two observations: (i) the nodes with small $m$ are very few, and (ii) knowing one branch confines the other two to an explicit region.

**Lemma 6.1 (Small nodes).** The nodes with $m \le 5$ are exactly
$$(2,1),\ (3,2),\ (4,1),\ (4,3),\ (5,2),\ (5,4).$$
Moreover $(2,1)$ is the only node with $m \le 2$ and $(3,2)$ the only one with $m=3$.

*Proof.* Enumerate $1 \le n < m \le 5$ and discard pairs with $m+n$ even or $\gcd>1$. $\square$

**Image regions.** For the seven matrices occurring in the classification, the image of $\mathcal{N}$ is exactly:

| matrix | image of $\mathcal{N}$ |
|---|---|
| $A = (2,-1;1,0)$ | $\{m < 2n\}$ |
| $B = (2,1;1,0)$ | $\{2n < m < 3n\}$ |
| $C = (1,2;0,1)$ | $\{3n < m\}$ |
| $P_0 = (1,1;0,2)$ | $\{n \text{ even}\}$ |
| $P_1 = (2,0;1,-1)$ | $\{m \text{ even},\ 2n<m\}$ |
| $P_2 = (2,0;1,1)$ | $\{m \text{ even},\ m<2n\}$ |
| $F_0 = (1,3;0,2)$ | $\{n \text{ even},\ 2n<m\}$ |

Both inclusions in each row are elementary: the forward one by inspecting the formula, the backward one by writing down the parent as in Section 5.

**Root-child rigidity.** For a node-preserving $M$, the value $M\cdot(2,1) = (2a+b,\ 2c+d)$ pins $M$ down to a very short list, because $2a+b$ and $2c+d$ are two linear equations, the cone conditions bound $c$, the parity condition ties $a$ to $c \bmod 2$, and the determinant conditions (nonzero, not divisible by $3$) remove the residue. Explicitly:

* $M\cdot(2,1)=(3,2)$ $\Longrightarrow$ $M \in \{A,\ P_0\}$;
* $M\cdot(2,1)=(4,1)$ $\Longrightarrow$ $M \in \{C,\ P_1\}$;
* $M\cdot(2,1)=(4,3)$ $\Longrightarrow$ $M \in \{P_2,\ E_{43}\}$, where $E_{43} = (3,-2;2,-1)$, $\det = 1$;
* $M\cdot(2,1)=(5,2)$ $\Longrightarrow$ $M \in \{F_0,\ B,\ E_{52}\}$, where $E_{52} = (3,-1;2,-2)$, $\det = -4$.

The two *exotic* maps $E_{43}$ and $E_{52}$ genuinely preserve $\mathcal{N}$; they are eliminated in the classification not by admissibility but by the covering axiom. (Note $E_{52}$ has $|\det| = 4$ — an instance showing that the power-of-two theorem is not vacuous beyond $|\det|\le 2$ for *individual* maps, even though tree branches never exceed $2$.)

**Theorem 6.2 (Classification).** Let $T = (M_0,M_1,M_2)$ be a ternary Pythagorean tree. Then, as a set,
$$\{M_0,M_1,M_2\} \;=\; \{A,B,C\} \quad\text{or}\quad \{P_0,P_1,P_2\} \quad\text{or}\quad \{F_0, A, P_1\}.$$
Conversely each of these three sets is a ternary Pythagorean tree. Hence, up to relabelling of the branches, there are exactly three ternary Pythagorean trees.

*Proof.* By Theorem 4.5 exactly one branch, say $M_{i_0}$, satisfies $M_{i_0}\cdot(2,1) = (3,2)$, and by root-child rigidity $M_{i_0} \in \{A, P_0\}$.

**Case I: $M_{i_0} = A$.** The image of $A$ is $\{m<2n\}$; by axiom (4) no other branch can produce a node with $m<2n$, and $m = 2n$ occurs only at the root, so both remaining branches map into $\{2n<m\}$.

The node $(4,1)$ is not the root, so some branch $j$ covers it, and $j \ne i_0$ because $(4,1)$ has $m>2n$. By root minimality (Lemma 4.2), $\big(M_j\cdot(2,1)\big)_1 \le 4$, and by axiom (2) with Lemma 6.1, $\big(M_j\cdot(2,1)\big)_1 \ge 3$; combined with $2n<m$ on the image and the list of small nodes, $M_j\cdot(2,1) = (4,1)$. Root-child rigidity gives $M_j \in \{C, P_1\}$.

*Subcase I.a: $M_j = C$.* The image of $C$ is $\{3n<m\}$, so the third branch $M_k$ maps into $\{2n<m<3n\}$ (the ray $m=3n$ is empty of nodes by parity). The node $(5,2)$ must be covered, necessarily by $k$: it fails $m<2n$ and fails $3n<m$. Root minimality plus Lemma 6.1 then force $M_k\cdot(2,1) = (5,2)$, giving $M_k \in \{F_0, B, E_{52}\}$. The node $(8,3)$ also lies in $\{2n<m<3n\}$ and so must be covered by $k$; but both $F_0$ and $E_{52}$ always output an *even* second coordinate, while $3$ is odd. Hence $M_k = B$, and $T$ is Berggren's tree.

*Subcase I.b: $M_j = P_1$.* The image of $P_1$ is $\{m$ even, $2n<m\}$, so the third branch $M_k$, which maps into $\{2n<m\}$, must always produce *odd* first coordinates. The node $(5,2)$ must be covered by $k$ ($A$ requires $m<2n$; $P_1$ requires $m$ even). Root minimality and Lemma 6.1 force $M_k\cdot(2,1)=(5,2)$, so $M_k \in \{F_0,B,E_{52}\}$. Now $B\cdot(3,2)=(8,3)$ has even first coordinate, contradicting the oddness just established; and $E_{52}$ cannot produce $(9,4)$, which must be covered by $k$. Hence $M_k = F_0$, and $T$ is the mixed tree.

**Case II: $M_{i_0} = P_0$.** The image of $P_0$ is $\{n$ even$\}$, so both other branches always produce odd second coordinates. The node $(4,1)$ is covered by some $j \ne i_0$; the same root-minimality argument (using that $\big(M_j\cdot(2,1)\big)_2$ is odd) forces $M_j\cdot(2,1) = (4,1)$, hence $M_j \in \{C, P_1\}$. But $C\cdot(3,2) = (7,2)$ has even second coordinate — excluded. So $M_j = P_1$, with image $\{m$ even, $2n<m\}$.

The third branch $M_k$ therefore produces only nodes with odd $n$ and, since its images have even $m$ (odd $n$ plus odd sum), with $m<2n$. The node $(4,3)$ must be covered by $k$, and root minimality forces $M_k\cdot(2,1)=(4,3)$, giving $M_k \in \{P_2, E_{43}\}$. But $E_{43}\cdot(3,2)=(5,4)$ has even second coordinate — excluded. Hence $M_k = P_2$ and $T$ is Price's tree.

The converse direction is Theorems 5.1, 5.2, 5.3. Finally, the three branches of any tree are pairwise distinct (if $M_i = M_j$ then $M_i\cdot(2,1)=M_j\cdot(2,1)$ and axiom (4) gives $i=j$), so the set description determines the triple up to relabelling. $\square$

**Corollary 6.3 (The corrected quantitative claim).** Every branch of every ternary Pythagorean tree has $|\det| \le 2$. In particular there is no ternary Pythagorean tree with a branch of determinant of absolute value $\ge 3$.

*Proof.* All seven matrices in Theorem 6.2 have determinants in $\{1,-1,2,-2\}$. $\square$

---

## 7. The dictionary with primitive Pythagorean triples

**Theorem 7.1 (Euclid correspondence).** The map $\tau(m,n) = (m^2-n^2,\ 2mn,\ m^2+n^2)$ is a bijection from $\mathcal{N}$ onto the set of primitive Pythagorean triples with positive entries and even second leg, and $\tau(2,1) = (3,4,5)$.

*Proof sketch.* *Well-defined:* the Pythagorean identity is formal; positivity follows from $m>n\ge1$; primitivity and the parity of the legs follow from $\gcd(m,n)=1$ together with $m+n$ odd via the classical coprime classification of Pythagorean triples. *Injective:* from $\tau(m,n)=\tau(m',n')$ one gets $m^2 = m'^2$ and $n^2=n'^2$ by adding and subtracting the first and third coordinates; positivity gives $m=m'$, $n=n'$. *Surjective:* given a PPT $(x,y,z)$, the coprime classification produces $m,n$ with $x = \pm(m^2-n^2)$, $y = 2mn$, $z = \pm(m^2+n^2)$; the hypothesis that the *second* leg is even selects the branch $x = m^2-n^2$, since $m^2-n^2$ is odd whenever $m+n$ is; replacing $(m,n)$ by $(-m,-n)$ if necessary makes both positive, and $x>0$ gives $n<m$. $\square$

**Theorem 7.2 (Generation of all triples).** Let $T$ be any ternary Pythagorean tree. Then every primitive Pythagorean triple with even second leg is $\tau$ of a node reachable from $(2,1)$ by a finite word in the three branches, and it occurs for exactly one node.

*Proof.* Combine Theorem 7.1 with the generation theorem 4.6, and use injectivity of $\tau$ for uniqueness. $\square$

Concretely, the first generation from $(3,4,5)$ is:

| tree | children of $(3,4,5)$ |
|---|---|
| Berggren | $(5,12,13)$, $(21,20,29)$, $(15,8,17)$ |
| Price | $(5,12,13)$, $(15,8,17)$, $(7,24,25)$ |
| Mixed | $(21,20,29)$, $(5,12,13)$, $(15,8,17)$ |

and by Theorem 4.5, $(5,12,13)$ is a child of $(3,4,5)$ in *every* ternary Pythagorean tree.

---

## 8. Conservation of branch density, and the determinant spectrum

### 8.1 Where the density comes from

Fix a node-preserving $M$ with top row $(a,b)$, $a\ge1$, $a+b\ge1$. The nodes whose $M$-image has first coordinate at most $B$ are the lattice points of the triangle
$$\Delta_M(B) = \{(x,y) : 0 < y < x,\ ax + by \le B\},$$
whose Euclidean area is $B^2/\big(2a(a+b)\big)$: the triangle has vertices $(0,0)$, $(B/a, 0)$ and $(B/(a+b),\ B/(a+b))$. Meanwhile the full cone slice $\{0<y<x \le B\}$ has area $B^2/2$. Since the node set is a fixed-density sublattice of the cone (defined by congruence and coprimality conditions that are uniform in dilation), the *proportion* of nodes produced by the branch $M$ is
$$\rho(M) = \frac{1}{a(a+b)}.$$

For a tree, the three branches partition the non-root nodes, and the densities must add to $1$. That heuristic is exactly borne out.

### 8.2 The conservation law

$$\rho(A) = \tfrac12,\quad \rho(B) = \tfrac16,\quad \rho(C) = \tfrac13,\quad \rho(P_0) = \tfrac12,\quad \rho(P_1)=\rho(P_2)=\tfrac14,\quad \rho(F_0)=\tfrac14.$$

**Theorem 8.2 (Branch-density conservation).** For every ternary Pythagorean tree $T$,
$$\rho(M_0) + \rho(M_1) + \rho(M_2) = 1.$$

*Proof.* By Theorem 6.2 there are exactly three cases, and
$$\tfrac12+\tfrac16+\tfrac13 = 1,\qquad \tfrac12+\tfrac14+\tfrac14 = 1,\qquad \tfrac14+\tfrac12+\tfrac14 = 1. \qquad\square$$

Read the other way, the identity is a *constraint* one can impose before searching: any candidate triple must solve the Diophantine budget equation
$$\frac{1}{a_0(a_0+b_0)} + \frac{1}{a_1(a_1+b_1)} + \frac{1}{a_2(a_2+b_2)} = 1,$$
whose relevant solutions in the admissible range are precisely $\{2,6,3\}$, $\{2,4,4\}$ (in two distinct matrix realisations). This is *why* three and not two: the multiset $\{2,4,4\}$ of denominators is realised both by Price's triple and by the hybrid $\{F_0,A,P_1\}$.

### 8.3 The determinant spectrum

**Theorem 8.3 (Determinant spectrum).** For every ternary Pythagorean tree,
$$|\det M_0| + |\det M_1| + |\det M_2| \in \{3,\ 5,\ 6\},$$
with value $3$ for Berggren, $6$ for Price and $5$ for the mixed tree. In particular the sum never exceeds $6$.

*Proof.* Immediate from Theorem 6.2 and the determinants $1,-1,1$; $2,-2,2$; $2,1,-2$. $\square$

Thus the determinant sum is a complete invariant of the three trees — but, crucially, *not* a constraint one could have guessed: the naive expectation of a uniform determinant per tree is exactly what the mixed tree violates.

---

## 9. Computational evidence

Theorem 3.7 turns node preservation into a finite test, and this was used to survey the landscape independently of the proofs.

**Admissible maps in a box.** Enumerating all $(a,b,c,d)$ with $|{\cdot}| \le R$ and applying the characterisation gives

| $R$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| # node-preserving maps | 1 | 8 | 18 | 39 | 67 | 93 | 138 | 197 |
| determinant magnitudes | $\{1\}$ | $\{1,2,4\}$ | $\{1,2,4,8\}$ | $\{1,\dots,16\}$ | $\{1,\dots,32\}$ | $\{1,\dots,32\}$ | $\{1,\dots,32\}$ | $\{1,\dots,64\}$ |

(the magnitude sets are the powers of two up to the indicated maximum). Only powers of two occur, in agreement with Theorem 3.5, and every power of two up to the observed maximum is attained.

**Validation of the characterisation.** Comparing the criterion of Theorem 3.7 with direct verification of node preservation on all nodes with $m \le 200$, over all $13^4 = 28561$ matrices with entries in $[-6,6]$, produced no disagreements.

**Exhaustive tree search.** Among the $197$ node-preserving maps with entries bounded by $8$, one may search for triples whose images partition $\{(m,n)\in\mathcal{N} : m \le 200\} \setminus \{(2,1)\}$. Exactly three triples survive:

```
{(1,1;0,2), (2,0;1,-1), (2,0;1,1)}    determinants  2, -2,  2    (Price)
{(2,-1;1,0), (2,1;1,0), (1,2;0,1)}    determinants  1, -1,  1    (Berggren)
{(1,3;0,2), (2,-1;1,0), (2,0;1,-1)}   determinants  2,  1, -2    (mixed)
```

matching Theorem 6.2 exactly. (The search is a necessary condition only — partitioning a finite window — but its output coinciding with the proven classification is a strong consistency check.)

---

## 10. Discussion and applications

**A structural reading.** The two classical trees implement two different splitting principles on the cone $0<n<m$:

* Berggren splits by **ratio**: the three regions are $m/n \in (1,2)$, $(2,3)$, $(3,\infty)$. The special ratios $2$ and $3$ are exactly the ones where coprimality forces $n=1$ and parity intervenes.
* Price splits by **parity and halving**: either $n$ is even (halve it) or $m$ is even (halve it, with two signs for $|m/2 - n|$).

The mixed tree shows these principles are *composable*: use the ratio rule on the half-cone $m<2n$ and the parity rule on $m>2n$. That the composition closes up into a tree is not an accident but a consequence of the density budget: the ratio rule on $m<2n$ costs exactly $\frac12$, the same as Price's $P_0$, and the remaining $\frac12$ can be paid by the pair $\{P_1, F_0\}$ just as well as by $\{P_1,P_2\}$.

**Enumeration and search.** Any of the three trees gives an algorithm that enumerates every primitive Pythagorean triple exactly once, with no duplication test and no gcd computation, at cost $O(1)$ arithmetic per triple. The differing densities produce genuinely different traversal orders: Berggren's branch $B$ has density $\frac16$ and produces the "thin" region $2n<m<3n$, so a breadth-first traversal of the Berggren tree is markedly unbalanced in $m$ compared to Price's, which is $\frac12,\frac14,\frac14$. For applications that need triples with bounded hypotenuse, the density values predict the shape of the truncated tree and hence the best traversal.

**Cryptographic and coding side-notes.** Trees of primitive triples have been used as deterministic generators of structured integer data; the classification says such a generator has exactly three possible "shapes" under integer linear child rules, and that the determinant of any child rule is $2$-adically constrained. The power-of-two theorem also gives a fast rejection test: an integer matrix whose determinant has any odd prime factor cannot possibly be part of such a scheme.

**Why the conjecture failed.** The failure is instructive. Both classical trees have a uniform determinant, which made "the determinant" look like the invariant to classify by. It is not: determinant is not preserved by the operations that build trees (region-splitting and re-pairing of branches). The genuine invariants are the $2$-adic constraint (per branch) and the density budget (per tree). Once the search is organised around the budget equation, the third solution appears immediately.

---

## 11. Future directions

**Arity $k$.** For $k$ branches the density budget reads $\sum_{i<k} 1/\big(a_i(a_i+b_i)\big) = 1$, and the number $t(k)$ of $k$-ary trees on $\mathcal{N}$ with root $(2,1)$ should be finite for every $k$, with $t(2)=0$ and $t(3)=3$. A natural conjecture is $t(k)\ge3$ for all $k\ge3$ and, more importantly, that the bound $|\det|\le2$ on branches is *arity-independent*: the $\pm2$ ceiling is a property of $\mathcal{N}$, not of the number three.

**Other root sets.** Replacing $\mathcal{N}$ by the Euclid-parameter set of triples in an imaginary quadratic order, or by the parameter set of "almost-primitive" triples, changes the parity condition and hence the obstruction. Which prime obstructions survive?

**Affine and higher-degree child rules.** All maps considered here are linear. Allowing affine maps $(m,n)\mapsto(am+bn+e,\ cm+dn+f)$ enlarges the search space; the Bézout identity of Lemma 3.1 no longer applies verbatim, and it is unclear whether new trees appear.

**Metric properties of the three trees.** The three trees induce three different metrics on the set of primitive triples (tree distance). Comparing the distance from $(3,4,5)$ to a triple of hypotenuse $z$ across the three trees is a concrete question in the dynamics of the branch maps: the growth rate of $m$ per step is $2$ for Price's $P_1,P_2$, but between $1$ and $3$ for Berggren's, so the depth profiles differ.

**Effective bounds from the budget.** Can one prove Corollary 6.3 (branch determinants $\le 2$) *directly* from the density budget plus the power-of-two theorem, without going through the full classification? Such a proof would generalise to all arities in one stroke.

---

## 12. Conclusion

The set of primitive Pythagorean triples carries an unexpectedly rigid ternary structure. Any integer linear rule that acts on Euclid parameters has determinant a power of two — an obstruction traceable to a single Bézout identity — and any complete ternary child rule is one of exactly three: Berggren's ratio tree, Price's halving tree, and a hybrid that had been overlooked. The classical dichotomy is false; the classical determinant ceiling is true and is a shadow of a $2$-adic phenomenon. Behind both stands a simple accounting identity: the three branches occupy densities that must sum to exactly one, and the trees are precisely the ways of paying that bill.
