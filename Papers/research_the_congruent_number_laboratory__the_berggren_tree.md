# The Area Function of the Berggren Tree and the Congruent Number Problem

**Author:** Aristotle
**Date:** 2026-09-15

## Abstract

The Berggren–Barning–Hall tree enumerates the primitive Pythagorean triples exactly once each, as a ternary tree rooted at $(3,4,5)$. We study the *area function* of this tree, which in Euclid coordinates $(m,n)\mapsto(m^2-n^2,2mn,m^2+n^2)$ is the quartic form
$$\mathcal{A}(m,n)=mn(m^2-n^2)=mn(m-n)(m+n).$$
Our main theorem is that the squarefree parts of the values of $\mathcal A$ on admissible seeds are *exactly* the congruent numbers: a squarefree positive integer $s$ is the area of some rational right triangle if and only if some node of the tree has area $sk^2$ for an integer $k>0$. Combining this with an explicit birational correspondence with the congruent number curve $E_s: y^2=x^3-s^2x$ yields a three-way equivalence between rational right triangles of area $s$, nodes of the tree of area $s$ times a square, and rational points of $E_s$ with $x>0$, $y\neq 0$. The tree formulation supports its own infinite descent, in which "smaller" means "closer to the root". We use it to prove, unconditionally and entirely within the tree: (i) no node has square area (Fermat's right triangle theorem), hence $1$ is not congruent; (ii) no node has area twice a square, hence $2$ is not congruent; (iii) for every prime $p\equiv 3\pmod 8$, no node has area $pk^2$ (Genocchi's theorem), giving an unconditional infinite family of non-congruent numbers. We then develop the first structure theory of the area function: strict monotonicity along all three branches with exact increment identities, a $6\times$ multiplicative growth law along the middle branch, a closed "silver law" $\mathcal A_d=2t_d^2+(-1)^{d+1}t_d$ along the Pell spine, growth $\mathcal A_d\ge 6^{d+1}$, and properness ($\mathcal A(m,n)>m^2$, so only finitely many nodes lie below any area bound). The last item makes the tree a computable model in which density questions about congruent numbers — equivalent in depth to rank distribution for $E_s$ and hence to the Birch–Swinnerton-Dyer circle of ideas — become finitary statements about the recurrence of square classes among the values of a single quartic form.

**Keywords:** congruent numbers, Pythagorean triples, Berggren tree, infinite descent, elliptic curves, Pell numbers, silver ratio, Genocchi's theorem.

---

## 1. Introduction

A positive rational number $N$ is a **congruent number** if it is the area of a right triangle whose three sides are positive rationals. The problem of deciding which integers are congruent dates in its modern form to Arab manuscripts of the tenth century and to Fibonacci's *Liber Quadratorum* (1225); Bachet's 1621 edition of Diophantus popularised it in Europe. Fermat proved that $1$ is not congruent, via the descent he regarded as his finest argument; Genocchi (1855) proved that no prime $p\equiv 3\pmod 8$ is congruent. The modern reformulation, that $N$ is congruent iff the elliptic curve $y^2=x^3-N^2x$ has positive rank, places the problem inside the Birch–Swinnerton-Dyer conjecture: Tunnell's theorem (1983) gives a finite criterion whose sufficiency is conditional on BSD.

This paper approaches the *triangle* side of the problem through a combinatorial object in which the triangle side is completely explicit: the tree of primitive Pythagorean triples. Barning (1963) and Hall (1970) showed that three fixed unimodular matrices, applied repeatedly to $(3,4,5)$, generate every primitive triple exactly once. Equivalently, in Euclid coordinates, every admissible seed is reached from $(2,1)$ by a unique word in three affine moves. The tree is therefore a *bijective enumeration* of the integral right triangles.

Our contribution is to study the area function of this tree and to prove that it is a faithful model of the congruent number problem.

**Main Theorem.** *Let $s$ be a squarefree positive integer. Then $s$ is a congruent number if and only if there exist an admissible seed $(m,n)$ and an integer $k>0$ with $\mathcal A(m,n)=sk^2$; equivalently, if and only if some node $v$ of the tree (or of the leg-swapped tree) satisfies $\mathrm{area}(v)=sk^2$; equivalently, if and only if $y^2=x^3-s^2x$ has a rational point with $x>0$ and $y\neq 0$.*

Sections 2–4 set up the definitions and prove the equivalence. Section 5 develops the tree-native descent and derives the three unconditional non-congruence laws. Section 6 gives the structure theory of $\mathcal A$: monotonicity, the silver law on the Pell spine, and properness. Section 7 describes the resulting algorithms; Section 8 discusses what the laboratory can and cannot be expected to deliver, and Section 9 lists open problems.

## 2. Definitions

Throughout, $\mathbb{Z}$ and $\mathbb{Q}$ have their usual meanings and all triples are ordered.

**Definition 2.1 (Congruent number).** A rational number $N$ is *congruent* if there exist $a,b,c\in\mathbb{Q}_{>0}$ with
$$a^2+b^2=c^2 \quad\text{and}\quad ab=2N.$$

**Definition 2.2 (Primitive Pythagorean triple).** A triple $(a,b,c)$ of positive integers is a *primitive Pythagorean triple* (PPT) if $a^2+b^2=c^2$ and $\gcd(a,b)=1$.

**Definition 2.3 (Admissible seed; Euclid map).** A pair $(m,n)$ of integers is an *admissible seed* if $m>n>0$, $\gcd(m,n)=1$, and $m-n$ is odd (equivalently, $m$ and $n$ have opposite parity). The *Euclid map* sends an admissible seed to
$$\mathcal E(m,n)=\bigl(m^2-n^2,\ 2mn,\ m^2+n^2\bigr).$$

**Proposition 2.4 (Euclid's classification).** $\mathcal E$ is a bijection from admissible seeds onto PPTs with even second entry; every PPT is either of this form or the leg-swap of one.

**Definition 2.5 (Berggren moves and the tree).** Define, on admissible seeds,
$$A(m,n)=(2m-n,\ m),\qquad B(m,n)=(2m+n,\ m),\qquad C(m,n)=(m+2n,\ n).$$
Each move sends admissible seeds to admissible seeds. The *Berggren tree* is the rooted ternary tree with root $(2,1)$ and children $A(v),B(v),C(v)$ of each node $v$.

**Theorem 2.6 (Barning–Hall; used as input).** Every admissible seed is obtained from $(2,1)$ by a unique finite word in $\{A,B,C\}$. Consequently the tree of triples $\mathcal E(\text{node})$, together with its leg-swap, enumerates all PPTs exactly once.

Under $\mathcal E$ the three moves correspond to the three Barning matrices acting on $(a,b,c)$; we shall work exclusively in seed coordinates, where the arithmetic is quartic rather than quadratic but the divisibility structure is transparent.

**Definition 2.7 (Area function).** For integers $m,n$ set
$$\mathcal A(m,n)=mn\bigl(m^2-n^2\bigr)=mn(m-n)(m+n),$$
and for an integer triple $v=(a,b,c)$ set $\mathrm{area}(v)=\tfrac12 ab\in\mathbb{Q}$.

**Proposition 2.8.** $\mathrm{area}\bigl(\mathcal E(m,n)\bigr)=\mathcal A(m,n)$.

*Proof.* $\tfrac12 (m^2-n^2)(2mn)=mn(m^2-n^2)$. $\square$

**Proposition 2.9 (Positivity).** If $m>n>0$ then $\mathcal A(m,n)>0$.

**Definition 2.10 (Congruent number curve).** For $N\in\mathbb{Q}$ put $E_N:\ y^2=x^3-N^2x$, and say $(x,y)\in\mathbb{Q}^2$ *lies on* $E_N$ if it satisfies this equation.

## 3. Elementary properties of the area function

**Theorem 3.1 (Divisibility by six).** For all integers $m,n$ we have $6 \mid \mathcal A(m,n)$.

*Proof sketch.* The statement depends only on $(m \bmod 6, n\bmod 6)$, and the resulting $36$ cases are checked directly. Conceptually: among $m$, $n$, $m-n$ one is even (if $m,n$ are both odd then $m-n$ is even), and among $m$, $n$, $m-n$, $m+n$ one is divisible by $3$ (if $3\nmid mn$ then $m\equiv\pm n$, so $3$ divides $m-n$ or $m+n$). $\square$

**Theorem 3.2 (Integral triangles are congruent-number witnesses).** If $x,y,z$ are positive integers with $x^2+y^2=z^2$, then $\tfrac12 xy$ is a congruent number.

**Theorem 3.3 (Scaling).** If $N$ is congruent and $t\in\mathbb{Q}_{>0}$, then $Nt^2$ is congruent.

*Proof.* Scale each side of a witnessing triangle by $t$; the Pythagorean relation is homogeneous of degree $2$ and the area is multiplied by $t^2$. $\square$

**Theorem 3.4 (Square-class invariance).** For $N\in\mathbb{Q}$ and $t\in\mathbb{Q}^{\times}$: $N$ is congruent $\iff$ $Nt^2$ is congruent.

*Proof.* Apply Theorem 3.3 with $|t|$ in one direction and with $|t|^{-1}$ to $Nt^2$ in the other, using $|t|^2=t^2$. $\square$

Thus congruence is a property of the class of $N$ in $\mathbb{Q}^\times/(\mathbb{Q}^\times)^2$; for a positive integer it depends only on the squarefree part. This is the reason the *integral* tree suffices to detect all *rational* triangles.

**Corollary 3.5.** For every admissible seed $(m,n)$, the integer $\mathcal A(m,n)$ is a congruent number, and so is its squarefree part.

## 4. The main equivalence

### 4.1 Descent from a rational triangle to a primitive triple

The key arithmetic lemma is squarefree cancellation.

**Lemma 4.1 (Squarefree cancellation).** Let $s$ be squarefree, $g\neq 0$, and suppose $Ag^2=sd^2$ for integers $A,d$. Then $A=sk^2$ for some integer $k$.

*Proof sketch.* Write $e=\gcd(g,d)$, $g=eg_1$, $d=ed_1$ with $\gcd(g_1,d_1)=1$; cancelling $e^2$ reduces to the case $\gcd(g,d)=1$. Then $g^2 \mid s d^2$ and $\gcd(g^2,d^2)=1$ give $g^2\mid s$; squarefreeness of $s$ forces $g=\pm1$, whence $A=sd^2$. $\square$

**Lemma 4.2 (Clearing denominators).** If $N$ is congruent, there are positive integers $x,y,z,D$ with $x^2+y^2=z^2$ and $xy=2ND^2$.

*Proof.* Take a rational witness $(a,b,c)$ and let $D$ be a common denominator; put $(x,y,z)=(aD,bD,cD)$. $\square$

**Theorem 4.3 (Descent to a primitive triple).** Let $s$ be a squarefree positive integer that is congruent. Then there exist positive integers $x,y,z,k$ with
$$x^2+y^2=z^2,\qquad \gcd(x,y)=1,\qquad xy=2sk^2 .$$

*Proof sketch.* Start from Lemma 4.2 with $N=s$. Let $g=\gcd(x,y)$; then $g \mid z$ as well (since $g^2\mid z^2$ and… more precisely, $g^2 \mid x^2+y^2=z^2$ implies $g\mid z$), so $(x/g,y/g,z/g)$ is a primitive triple, and its leg product $P$ satisfies $Pg^2=2sD^2$. Halving (the leg product of any Pythagorean triple is even) and applying Lemma 4.1 to $s$ squarefree yields $P=2sk^2$. $\square$

### 4.2 The tree form

**Theorem 4.4 (Areas of seeds are the congruent numbers).** Let $s$ be squarefree. Then
$$s \text{ is a congruent number}\iff \exists\ \text{admissible } (m,n),\ \exists k>0:\ \mathcal A(m,n)=sk^2 .$$

*Proof sketch.* ($\Leftarrow$) By Corollary 3.5 the integer $sk^2$ is congruent, so by Theorem 3.4 so is $s$.
($\Rightarrow$) By Theorem 4.3 there is a primitive triple $(x,y,z)$ with $xy=2sk^2$. By Proposition 2.4 either $(x,y,z)$ or $(y,x,z)$ equals $\mathcal E(m,n)$ for an admissible seed $(m,n)$; in both cases
$$xy=(m^2-n^2)(2mn)=2\mathcal A(m,n),$$
so $\mathcal A(m,n)=sk^2$. $\square$

**Theorem 4.5 (Tree form of the main theorem).** Let $s$ be squarefree. Then $s$ is a congruent number if and only if there is a node $v$ of the Berggren tree, or of its leg-swapped copy, and an integer $k>0$, with $\mathrm{area}(v)=sk^2$.

*Proof.* Combine Theorem 4.4 with Theorem 2.6 (every admissible seed is a node, and nodes and their swaps exhaust the PPTs) and Proposition 2.8. $\square$

**Corollary 4.6 (Squarefree parts).** For every admissible seed $(m,n)$ there are unique positive integers $s$ (squarefree) and $k$ with $\mathcal A(m,n)=sk^2$, and this $s$ is a congruent number. The map
$$\mathrm{sqf}\circ\mathcal A:\ \{\text{nodes}\}\longrightarrow\{\text{congruent numbers}\}$$
is surjective.

### 4.3 The elliptic curve side

**Theorem 4.7 (Triangle $\to$ point).** If $N$ is congruent with witness $(a,b,c)$, then
$$(x,y)=\left(\frac{a(a+c)}{2},\ \frac{a^2(a+c)}{2}\right)$$
lies on $E_N$ with $x>0$ and $y>0$.

*Proof sketch.* Substituting $N=ab/2$ and $c^2=a^2+b^2$, the difference $x^3-N^2x-y^2$ becomes a polynomial identity in $a,b,c$ modulo $c^2-a^2-b^2$, verified directly. Positivity is immediate from $a,c>0$. $\square$

**Theorem 4.8 (Point $\to$ triangle).** Let $N>0$ and let $(x,y)$ lie on $E_N$ with $x>0$, $y\neq 0$. Then $x>N$ and
$$\left(\frac{x^2-N^2}{y},\ \frac{2Nx}{y},\ \frac{x^2+N^2}{y}\right)$$
is a rational right triangle of area $N$ (after replacing $y$ by $|y|$).

*Proof sketch.* Replacing $y$ by $-y$ if necessary, assume $y>0$. From $y^2>0$ and $y^2=x(x-N)(x+N)$ with $x>0$ we get $x>N$, so all three displayed quantities are positive. The Pythagorean identity
$$(x^2-N^2)^2+(2Nx)^2=(x^2+N^2)^2$$
is an identity of polynomials; and the area is
$$\frac{(x^2-N^2)\cdot 2Nx}{2y^2}=\frac{N\,x(x^2-N^2)}{x^3-N^2x}=N. \qquad\square$$

**Theorem 4.9 (Curve criterion).** For $N>0$: $N$ is congruent $\iff$ $E_N$ has a rational point with $x>0$, $y\neq 0$.

**Theorem 4.10 (Three-way equivalence).** For a squarefree positive integer $s$ the following are equivalent:
1. $s$ is a congruent number;
2. some node of the Berggren tree (or its swap) has area $sk^2$ with $k>0$ an integer;
3. $y^2=x^3-s^2x$ has a rational point with $x>0$ and $y\neq 0$.

Since (3) holds precisely when $E_s(\mathbb{Q})$ has positive rank (the torsion subgroup being $(\mathbb Z/2)^2$, generated by the points of order two at $x=0,\pm s$, none of which has $y\ne0$), the tree data is a faithful encoding of rank positivity. In particular, the recurrence of a square class among node areas is the tree-side shadow of the infinite order of a point on $E_s$.

## 5. Unconditional laws by tree-native descent

The advantage of formulating descent inside the tree is that the descent parameter is structural: each step produces an admissible seed with strictly smaller first coordinate, and the seeds are well-ordered.

### 5.1 Fermat's right triangle theorem

**Lemma 5.1 (Four coprime factors).** If $(m,n)$ is admissible, then $m$, $n$, $m-n$, $m+n$ are pairwise coprime and positive, and $m-n$, $m+n$ are odd.

*Proof sketch.* $\gcd(m,n)=1$ gives coprimality of $m$ and $n$ with $m\pm n$; and $\gcd(m-n,m+n)$ divides $2m$ and $2n$, hence divides $2$, and both are odd since $m,n$ have opposite parity. $\square$

**Lemma 5.2 (Four squares).** If $\mathcal A(m,n)=k^2$ for an admissible $(m,n)$, then there are positive integers $a,b,c,d$ with
$$m=a^2,\quad n=b^2,\quad m-n=c^2,\quad m+n=d^2 ,$$
and $c$, $d$ are odd.

*Proof.* A product of pairwise coprime positive integers is a square iff each factor is. $\square$

**Theorem 5.3 (No node has square area).** For every admissible seed $(m,n)$ and every integer $k$, $\mathcal A(m,n)\neq k^2$.

*Proof sketch (descent).* Suppose $\mathcal A(m,n)=k^2$ and take Lemma 5.2. Since $c,d$ are odd, $u=\tfrac{d+c}{2}$ and $v=\tfrac{d-c}{2}$ are positive integers with
$$u^2+v^2=\frac{d^2+c^2}{2}=m=a^2,\qquad 2uv=\frac{d^2-c^2}{2}=n=b^2 .$$
One checks $\gcd(u,v)=1$, so $(u,v,a)$ — after ordering the legs so that the even one comes second — is a primitive Pythagorean triple, i.e. a node of the tree with some admissible seed $(p,q)$: $\{u,v\}=\{p^2-q^2,\ 2pq\}$ and $a=p^2+q^2$. From $2uv=b^2$ with $u,v$ coprime and exactly one of them even, the even member is $2g^2$ and the odd member is $h^2$; substituting gives
$$\mathcal A(p,q)=pq(p^2-q^2)=\tfrac12(2pq)(p^2-q^2)=g^2h^2=(gh)^2 .$$
Finally $p<p^2+q^2=a$ and $a^2=m$ with $a\ge 2$, so $p<a<m$: the new seed is strictly smaller. Iterating contradicts the well-ordering of $\{m\in\mathbb Z_{>0}\}$. $\square$

**Corollary 5.4.** $1$ is not a congruent number; more generally $t^2$ is not congruent for any $t\in\mathbb{Q}^\times$.

*Proof.* If $1$ were congruent, Theorem 4.4 with $s=1$ would give a node of square area. The general case follows from Theorem 3.4. $\square$

### 5.2 Twice a square

**Theorem 5.5 (No node has area twice a square).** For every admissible seed $(m,n)$ and every integer $k$, $\mathcal A(m,n)\neq 2k^2$.

*Proof sketch.* Exactly one of $m$, $n$ is even. By Lemma 5.1 the four factors are pairwise coprime, so a factorisation $mn(m-n)(m+n)=2k^2$ puts the single factor $2$ in the even one of $m,n$ and makes the remaining three factors squares.

*Case $m$ even:* $m=2a^2$, $n=b^2$, $m-n=c^2$, $m+n=d^2$ with $c,d$ odd. Then $c^2+d^2=2m=4a^2$, impossible modulo $8$: odd squares are $1\bmod 8$, so $c^2+d^2\equiv 2 \pmod 8$, while $4a^2\equiv 0$ or $4$.

*Case $n$ even:* $m=a^2$, $n=2b^2$, $m-n=c^2$, $m+n=d^2$. With $u=\tfrac{d+c}{2}$, $v=\tfrac{d-c}{2}$ as before, $u^2+v^2=a^2$ and $uv=b^2$ with $\gcd(u,v)=1$; hence $u=g^2$, $v=h^2$ and
$$g^4+h^4=a^2 ,$$
which has no solution in positive integers (Fermat's theorem on $x^4+y^4=z^2$). $\square$

**Corollary 5.6.** $2$ is not a congruent number, and neither is $2t^2$ for any $t\in\mathbb{Q}^\times$.

### 5.3 Genocchi's theorem: an unconditional infinite family

**Lemma 5.7 (Coprime splitting with a prime).** Let $p>0$ be prime and let $A,B>0$ be coprime with $AB=pk^2$. Then either ($A=pa^2$ and $B=b^2$) or ($A=a^2$ and $B=pb^2$), for positive integers $a,b$.

**Lemma 5.8 (Four shapes).** Let $p>0$ be prime and $(m,n)$ admissible with $\mathcal A(m,n)=pk^2$. Then exactly one of the four pairwise coprime factors $m$, $n$, $m-n$, $m+n$ is $p$ times a square and the other three are squares. Explicitly, one of:
- (S1) $m=pa^2,\ n=b^2,\ m-n=c^2,\ m+n=d^2$;
- (S2) $m=a^2,\ n=pb^2,\ m-n=c^2,\ m+n=d^2$;
- (S3) $m=a^2,\ n=b^2,\ m-n=pc^2,\ m+n=d^2$;
- (S4) $m=a^2,\ n=b^2,\ m-n=c^2,\ m+n=pd^2$.

*Proof.* Iterate Lemma 5.7 over the coprime factorisation $\mathcal A(m,n)=m\cdot n\cdot(m-n)\cdot(m+n)$. $\square$

**Lemma 5.9 (Three shapes die modulo 8).** Let $p\equiv 3\pmod 8$ be prime and $(m,n)$ admissible with $\mathcal A(m,n)=pk^2$. Then shapes (S1), (S3), (S4) are impossible, and in shape (S2) the integer $a$ is odd.

*Proof sketch.* Throughout, $m-n$ and $m+n$ are odd and positive (Lemma 5.1), odd squares are $\equiv1\pmod 8$, even squares are $\equiv 0$ or $4\pmod 8$, and $p\equiv 3\pmod 8$.

*(S1).* Here $m-n=c^2$ and $m+n=d^2$ with $c,d$ odd, so $2m=c^2+d^2\equiv 2\pmod 8$ and $m\equiv 1\pmod 4$; in particular $m$ is odd, so $a$ is odd and $m=pa^2\equiv p\equiv 3\pmod 8$, contradicting $m\equiv 1 \pmod 4$.

*(S3).* Here $m=a^2$, $n=b^2$, $m-n=pc^2$ with $c$ odd (as $m-n$ is odd), so $m-n\equiv 3\pmod 8$. If $b$ is even then $a$ is odd, $m\equiv 1$ and $n\equiv 0$ or $4$, so $m-n\equiv 1$ or $5\pmod 8$ — impossible. If $a$ is even then $m+n=d^2\equiv 1\pmod 8$ with $n\equiv 1$, forcing $m\equiv 0\pmod 8$, whence $m-n\equiv -1\equiv 7\pmod 8$ — impossible.

*(S4).* Here $m-n=c^2\equiv1$ and $m+n=pd^2\equiv 3\pmod 8$ (both $c,d$ odd), so $2m\equiv 4\pmod 8$ and $m\equiv 2\pmod 4$: $m$ is even, $n$ odd, i.e. $m=a^2$ with $a$ even and $n=b^2$ with $b$ odd. Then $m+n\equiv 1$ or $5\pmod 8$, not $3$ — impossible.

*(S2).* Here $m-n=c^2$, $m+n=d^2$ with $c,d$ odd, so as in (S1) $m\equiv 1\pmod 4$; since $m=a^2$ is odd, $a$ is odd (and $n=pb^2$ is even, forcing $b$ even). $\square$

**Lemma 5.10 (The surviving shape descends).** Let $p\equiv 3\pmod 8$ be prime and $(m,n)$ admissible with $\mathcal A(m,n)=pk^2$. Then there is an admissible seed $(r,t)$ with $r<m$ and $\mathcal A(r,t)=p{k'}^2$ for some integer $k'$.

*Proof sketch.* By Lemma 5.9 we are in shape (S2): $m=a^2$ odd, $n=pb^2$ with $b$ even, $m-n=c^2$, $m+n=d^2$. Setting $u=\tfrac{d+c}{2}$, $v=\tfrac{d-c}{2}$ gives coprime positive integers with $u^2+v^2=a^2$ and $2uv=n=pb^2$. The pair $(u,v,a)$ is a primitive Pythagorean triple, hence a node with seed $(r,t)$, $a=r^2+t^2$, and splitting $2uv=pb^2$ into its coprime parts (the prime lands in exactly one of $u,v$, the other being a square up to the factor $2$) gives $\mathcal A(r,t)=rt(r^2-t^2)=\tfrac12(2rt)(r^2-t^2)=p{k'}^2$. As in Theorem 5.3, $r<a<m$. $\square$

**Theorem 5.11 (Genocchi's theorem, tree form).** Let $p\equiv 3\pmod 8$ be prime. Then no node of the Berggren tree has area $pk^2$; consequently $p$ is not a congruent number, and neither is $pt^2$ for any $t\in\mathbb{Q}^\times$.

*Proof.* Lemma 5.10 yields an infinite strictly decreasing sequence of positive first coordinates, which is impossible; then apply Theorem 4.4 and Theorem 3.4. $\square$

**Corollary 5.12.** $3$, $11$, $19$, $43$, $59$, $67$, $83$, $107$, $131,\dots$ (primes $\equiv 3 \bmod 8$) are not congruent. Together with Corollaries 5.4 and 5.6 this gives an unconditional, infinite, explicitly described family of non-congruent numbers, obtained purely from the combinatorics and arithmetic of the tree.

## 6. Structure of the area function

### 6.1 Monotonicity along the three branches

**Theorem 6.1 (Exact increment identities).** For all integers $m,n$:
$$\mathcal A(2m-n,\ m)=\mathcal A(m,n)+6m^2(m-n)^2,$$
$$\mathcal A(m+2n,\ n)=\mathcal A(m,n)+6n^2(m+n)^2,$$
$$\mathcal A(2m+n,\ m)=6\,\mathcal A(m,n)+m(m+n)\bigl(6m^2-mn+7n^2\bigr).$$

*Proof.* Expand both sides; each is a polynomial identity. $\square$

**Corollary 6.2 (Strict growth).** For every admissible seed $(m,n)$ the three children have strictly larger area. Along the $B$ branch the growth is multiplicative:
$$\mathcal A(2m+n,\ m) > 6\,\mathcal A(m,n),$$
because $m(m+n)>0$ and $6m^2-mn+7n^2>0$ for $m>n>0$.

Thus the area is a strictly increasing function on the tree in the order given by ancestry; in particular no two nodes on a common root-path share an area, and the tree's natural depth filtration is compatible with the size of the witnesses.

### 6.2 The Pell spine and the silver law

**Definition 6.3 (Spine).** Let $\sigma_0=(2,1)$ and $\sigma_{d+1}=B(\sigma_d)$; explicitly $\sigma_d=(m_d,n_d)$ with $m_{d+1}=2m_d+n_d$, $n_{d+1}=m_d$. The first terms are $(2,1),(5,2),(12,5),(29,12),(70,29),\dots$: consecutive Pell numbers.

**Proposition 6.4.** Every $\sigma_d$ is an admissible seed.

**Theorem 6.5 (Pell/silver identity).** For all $d\ge 0$,
$$m_d^2-2m_dn_d-n_d^2=(-1)^{d+1}.$$

*Proof.* Induction: the substitution $(m,n)\mapsto(2m+n,m)$ negates the form, since $(2m+n)^2-2(2m+n)m-m^2=-(m^2-2mn-n^2)$. The base case is $4-4-1=-1$. $\square$

**Theorem 6.6 (Silver law for spine areas).** With $t_d=m_dn_d$,
$$\mathcal A(\sigma_d)=2t_d^{\,2}+(-1)^{d+1}t_d .$$

*Proof.* Theorem 6.5 rearranges to $m_d^2-n_d^2=2m_dn_d+(-1)^{d+1}$. Multiply by $m_dn_d=t_d$. $\square$

The first values are $\mathcal A(\sigma_0)=6$, $\mathcal A(\sigma_1)=210$, $\mathcal A(\sigma_2)=7140$, $\mathcal A(\sigma_3)=242556$, $\mathcal A(\sigma_4)=8239770$. Since $m_d/n_d\to 1+\sqrt2$ (the silver ratio) and $t_d$ grows like $(1+\sqrt2)^{2d}$, the spine areas grow like a constant times $(1+\sqrt2)^{4d}=(17+12\sqrt2)^{d}$. A clean unconditional bound follows from Corollary 6.2:

**Theorem 6.7.** $\mathcal A(\sigma_d)\ \ge\ 6^{\,d+1}$ for all $d\ge0$.

The silver law is notable because it shows that along one distinguished infinite path the quartic $\mathcal A$ collapses to a *quadratic in a single variable*: $\mathcal A=2t^2\pm t$. These are exactly the values for which $8\mathcal A+1=(4t\pm1)^2$ is a perfect square, so the spine areas form a one-parameter family whose square classes can be analysed by classical means — a natural first target for density questions.

### 6.3 Properness

**Theorem 6.8 (Area dominates the seed).** For every admissible seed, $\mathcal A(m,n)>m^2$.

*Proof sketch.* $\mathcal A(m,n)=mn(m-n)(m+n)\ge m\cdot 1\cdot 1\cdot(m+1)=m^2+m>m^2$, using $n\ge1$, $m-n\ge1$, $m+n\ge m+1$. $\square$

**Theorem 6.9 (Properness).** For every $X$, the set $\{(m,n)\ \text{admissible}:\ \mathcal A(m,n)\le X\}$ is finite; indeed it is contained in $\{1\le n<m\le \sqrt X\}$.

*Proof.* By Theorem 6.8, $m^2<\mathcal A(m,n)\le X$. $\square$

Properness is what makes the tree a *laboratory*: the set of congruent numbers certified by a witness of area at most $X$ is computable by a finite enumeration of $O(X)$ seeds, with no search over denominators. Note the asymmetry that encodes the difficulty of the problem: a small congruent number may require a very large witness (the standard example is $157$, whose simplest triangle has a $45$-digit numerator), so properness bounds the witnesses, not the congruent numbers.

### 6.4 Explicit witnesses

Reading squarefree parts off small nodes gives unconditional certificates:

| seed $(m,n)$ | triple $\mathcal E(m,n)$ | $\mathcal A$ | factorisation | squarefree part |
|---|---|---|---|---|
| $(2,1)$ | $(3,4,5)$ | $6$ | $6\cdot 1^2$ | $6$ |
| $(3,2)$ | $(5,12,13)$ | $30$ | $30\cdot 1^2$ | $30$ |
| $(4,1)$ | $(15,8,17)$ | $60$ | $15\cdot 2^2$ | $15$ |
| $(4,3)$ | $(7,24,25)$ | $84$ | $21\cdot 2^2$ | $21$ |
| $(5,2)$ | $(21,20,29)$ | $210$ | $210\cdot 1^2$ | $210$ |
| $(5,4)$ | $(9,40,41)$ | $180$ | $5\cdot 6^2$ | $5$ |
| $(8,1)$ | $(63,16,65)$ | $504$ | $14\cdot 6^2$ | $14$ |
| $(9,8)$ | $(17,144,145)$ | $1224$ | $34\cdot 6^2$ | $34$ |
| $(16,9)$ | $(175,288,337)$ | $25200$ | $7\cdot 60^2$ | $7$ |

Each line is a proof that the listed squarefree number is congruent. For instance, the seed $(5,4)$ re-proves Fibonacci's 1225 result: the triangle $(9,40,41)$ has area $180=5\cdot 36$, so scaling by $1/6$ gives the rational triangle $\left(\tfrac32,\tfrac{20}{3},\tfrac{41}{6}\right)$ of area $5$.

## 7. Algorithms

Three algorithms follow directly from the theory; all are elementary and exact (integer arithmetic only).

**Algorithm A (Certified congruent numbers up to a seed bound).** Enumerate admissible seeds with $m\le M$; for each, compute $\mathcal A(m,n)$ and its squarefree part $s$; collect the set of $s$ obtained. By Theorem 4.4 every element of the output is a congruent number; by Theorem 6.9 all congruent numbers with a witness of area $\le M^2$ appear. Cost: $O(M^2)$ seeds, each requiring one factorisation of a number of size $O(M^4)$, or $O(M^2\log M)$ overall with a sieve of smooth parts.

**Algorithm B (Tree walk and address).** Since the moves $A,B,C$ are invertible on admissible seeds — the inverse of the triple $\{A,B,C\}$ is determined by comparing $m$ with $2n$ and $n$ with $2(m-n)$ — one can compute, for any admissible seed, its unique word in $\{A,B,C\}$ by repeatedly applying the inverse until reaching $(2,1)$. This gives the *depth* at which a congruent number first becomes visible, the fundamental statistic of the laboratory. Cost: $O(\log m)$ steps, each $O(1)$ arithmetic operations, since each inverse step strictly decreases $m$ at a geometric rate.

**Algorithm C (Triangle $\leftrightarrow$ curve point).** Implement the maps of Theorems 4.7 and 4.8 with exact rational arithmetic: from a node $\mathcal E(m,n)$ of area $sk^2$, rescale by $1/k$ to a rational triangle of area $s$, then map to the point $\bigl(\tfrac{a(a+c)}2,\tfrac{a^2(a+c)}2\bigr)$ on $E_s$, and verify $y^2=x^3-s^2x$. The inverse map returns the triangle. Cost: $O(1)$ rational operations. Composed with the group law on $E_s$ this generates *new* triangles of the same area from old ones — the tree-side meaning of a point of infinite order.

## 8. Discussion

### 8.1 What the equivalence buys

The classical statement "congruent numbers are the areas of rational right triangles" quantifies over an infinite-dimensional-feeling search space. Theorem 4.5 replaces it with: *the congruent numbers are the squarefree parts of the values of $mn(m-n)(m+n)$ on a set enumerated bijectively by a ternary tree*. Three consequences are structural rather than cosmetic.

1. **No redundancy.** Barning–Hall uniqueness means every congruent number is produced by a well-defined *set of addresses* (words in $A,B,C$), and the multiplicity of a square class is a combinatorial invariant, not an artefact of parameterisation.
2. **Descent is intrinsic.** The classical descents (Fermat, Genocchi) all manufacture a smaller triangle from a given one; in seed coordinates the smaller triangle is again a node and the descent parameter is $m$. This is what allows Sections 5.1–5.3 to be uniform: one template (four coprime factors; a modulo-$8$ case analysis; the half-sum/half-difference substitution $u=\tfrac{d+c}2$, $v=\tfrac{d-c}2$) yields all three laws.
3. **Statistics are finitary.** Properness (Theorem 6.9) turns "how many congruent numbers $\le X$ does the tree certify?" into a finite computation, and the growth laws (Theorem 6.1, Corollary 6.2) bound how deep one must go.

### 8.2 The limits

The equivalence is faithful, and faithfulness cuts both ways: the tree cannot be easier than the problem. Deciding whether a given squarefree $s$ is congruent is, by Theorem 4.10, deciding whether $E_s$ has positive rank. What the tree changes is the *kind* of question one can ask. Instead of "does a point exist?", one asks "how often does the quartic $mn(m-n)(m+n)$ revisit a square class along a walk in the tree?" — a question about the value distribution of a single explicit polynomial on an explicitly enumerated domain. A negative answer (perfect equidistribution of square classes, no exploitable structure) would itself be a sharp theorem quantifying why the triangle side alone cannot see the rank.

### 8.3 Relation to Tunnell's criterion

Tunnell's theorem expresses congruence via counts of representations by ternary quadratic forms; its sufficiency is conditional. The unconditional results of Section 5 are, by contrast, *descent-provable*: they use only coprime factorisation, quadratic residues mod $8$, and the well-foundedness of the tree. The interesting question is exactly how much of the Tunnell table is descent-provable. Section 5 shows that the classes of $1$, $2$, and $p\equiv 3 \pmod 8$ are; the local nature of the case analysis (which of four factors receives the prime; the prime's residue mod $8$) suggests that a finite decision table indexed by the mod-$8$ residues of the prime divisors of a squarefree $s$ captures the entire descent-provable region.

## 9. Future work

1. **Extending the descent.** Generalise the coprime splitting lemma from a prime $p$ to a squarefree modulus $s$ with a prescribed distribution of its prime factors among $m$, $n$, $m-n$, $m+n$. This should mechanise the case analysis and produce the full mod-$8$ table: expected consequences include the non-congruence of $2p$ for $p\equiv 3\pmod 8$ and of $pq$ for suitable pairs of primes $\equiv 3 \pmod 8$.
2. **A tree-side 2-descent invariant.** Construct a function $\kappa$ from nodes to $(\mathbb Z/8)^\times\times(\mathbb Z/8)^\times$, computable from the seed modulo $16$, such that the square class of a node's area determines $\kappa$ up to the action of the three generators, with the generators acting through a fixed permutation representation. The descent steps of Section 5 are involutive up to the generators, which is exactly the shape such an invariant requires.
3. **Density along the spine.** The silver law $\mathcal A=2t^2\pm t$ makes the spine a one-parameter family; determining the distribution of squarefree parts of $2t^2\pm t$ as $t$ runs over Pell products is a concrete, self-contained problem.
4. **Depth statistics.** Define $D(s)$ to be the least depth of a node whose area has squarefree part $s$. Compute $D$ for small congruent numbers and compare with the height of the corresponding generator of $E_s(\mathbb Q)$; a proven inequality in either direction would link tree combinatorics to canonical heights.
5. **Counting certified congruent numbers.** Estimate $\#\{s\le X:\ s\ \text{certified at depth}\le d\}$; the growth laws give upper bounds, and matching lower bounds would give the first tree-side density theorem.

## 10. Conclusion

The area function $mn(m-n)(m+n)$ on the Berggren tree of primitive Pythagorean triples is not a curiosity attached to the tree: it *is* the congruent number problem. Its values, read modulo squares, are exactly the congruent numbers, and the same data is exactly the set of rational points with $x>0$, $y\neq 0$ on the curves $y^2=x^3-s^2x$. The tree also carries its own descent, strong enough to prove unconditionally that $1$ and $2$ are not congruent and that no prime $p\equiv 3\pmod 8$ is congruent. Finally, the area function has genuine structure: it increases strictly along each branch, multiplies by more than six along the middle branch, obeys the silver law $2t^2+(-1)^{d+1}t$ along the Pell spine, and is proper. Explicit, enumerable, descent-friendly and statistically well-posed, the tree is a laboratory in which the oldest open problem in number theory can be experimented on with exact arithmetic.
