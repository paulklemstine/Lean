# $p$-adic Berggren Dynamics: The Tree of Pythagorean Triples as a Finite Dynamical System

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The three Berggren (Barning–Hall) matrices generate the ternary tree that produces every primitive Pythagorean triple exactly once, starting from $(3,4,5)$. They are integral isometries of the Lorentz form $q(a,b,c)=a^2+b^2-c^2$, and over $\mathbb{R}$ they realise a discrete group of isometries of the hyperbolic plane: two parabolic (unipotent) generators and one hyperbolic generator with eigenvalues $-1$ and $3\pm2\sqrt2$. We study the reduction of this system modulo $p^k$, that is, its $p$-adic dynamics.

We prove that each generator restricts to a bijection of the null cone modulo any modulus, so the tree becomes a finite invertible dynamical system. We determine its phase space exactly: the null cone in $(\mathbb{Z}/p)^3$ has precisely $p^2$ points for every odd prime $p$, hence $p^2-1$ nonzero points and $p+1$ null directions. We show that the unipotent generators have order exactly $p^k$ in $\mathrm{GL}_3(\mathbb{Z}/p^k)$ — a pure $p$-power, the algebraic signature of pro-$p$ behaviour — and that this is sharp: $B_1^{p^k}=I$ modulo $p^k$ but not modulo $p^{k+1}$. For the hyperbolic generator we prove a Frobenius formula on its $2\times2$ block $U=3+2J$ with $J^2=2$, deducing that $\operatorname{ord}(B_2 \bmod p)$ divides $p-1$ when $2$ is a quadratic residue modulo $p$ and divides $p+1$ otherwise; in all cases it divides $p^2-1$. Equivalently, and by quadratic reciprocity, $B_2$ possesses a nonzero eigenvector on the null cone if and only if $p\equiv\pm1\pmod 8$: an exact split/inert dichotomy. Modulo $p$ the hyperbolic generator has no nonzero fixed vector, whereas each unipotent generator fixes an isotropic line of $p$ points.

A Hensel lifting argument gives $B_2^{(p^2-1)p^k}\equiv I \pmod{p^{k+1}}$, so every point of $(\mathbb{Z}/p^{k+1})^3$ is periodic, and for every integer vector $v$ one has $|B_2^{N}v-v|_p\le p^{-(k+1)}$ with $N=(p^2-1)p^k$: the hyperbolic generator is periodic to arbitrary $p$-adic precision. In sharp contrast to the real picture, the reduced dynamics is never ergodic: every $B_2$-orbit has at most $p+1$ points, so at least $p-1$ orbits are required to cover the $p^2-1$ nonzero null vectors. At $p=2$ the system collapses completely — all three generators reduce to the identity — and this degeneracy is exactly the classical parity structure of Pythagorean triples: every vertex of the tree is (odd, even, odd). Finally, a pigeonhole bound shows that the boundary of the tree cannot embed in any fixed finite level: as soon as $3^d>p^2$, two distinct words of length $d$ collide modulo $p$, so no $p$-adic Cantor set exists at a finite level and the box dimension of the reduction is at most $2$.

**Keywords:** Pythagorean triples, Berggren tree, Lorentz form, $p$-adic dynamics, unipotent and hyperbolic matrices, quadratic reciprocity, Hensel lifting, null cone.

---

## 1. Introduction

### 1.1 The tree of Pythagorean triples

A *Pythagorean triple* is a triple of positive integers $(a,b,c)$ with $a^2+b^2=c^2$; it is *primitive* if $\gcd(a,b,c)=1$. Berggren (1934), rediscovered by Barning (1963) and Hall (1970), observed that the three matrices

$$
B_1=\begin{pmatrix}1&-2&2\\ 2&-1&2\\ 2&-2&3\end{pmatrix},\qquad
B_2=\begin{pmatrix}1&2&2\\ 2&1&2\\ 2&2&3\end{pmatrix},\qquad
B_3=\begin{pmatrix}-1&2&2\\ -2&1&2\\ -2&2&3\end{pmatrix},
$$

acting on column vectors, generate from the root $(3,4,5)$ an infinite ternary tree containing every primitive triple exactly once. The first level is $(5,12,13)$, $(21,20,29)$, $(15,8,17)$.

The structural reason is Lorentzian. Define
$$
q(a,b,c) = a^2+b^2-c^2 ,
$$
the quadratic form of signature $(2,1)$. A triple is Pythagorean precisely when it lies on the *null cone* $\{q=0\}$, and each $B_i$ preserves $q$. Thus $\langle B_1,B_2,B_3\rangle$ is a discrete subgroup of the integral orthogonal group $\mathrm{O}(2,1;\mathbb{Z})$, and the tree is one of its orbits on the cone.

The three generators are of different geometric types. Their characteristic polynomials are
$$
\chi_{B_1}(x)=\chi_{B_3}(x)=(x-1)^3, \qquad \chi_{B_2}(x)=(x+1)(x^2-6x+1),
$$
so $B_1$ and $B_3$ are unipotent (parabolic isometries of the hyperbolic plane) while $B_2$ is hyperbolic, with eigenvalues $-1$ and $3\pm2\sqrt2 = (1\pm\sqrt2)^2$, the square of the fundamental unit of $\mathbb{Z}[\sqrt2]$.

### 1.2 The question

The real and hyperbolic-geometric theory of this tree is classical. This paper develops the complementary *local* theory: what happens when the whole system is reduced modulo $p^k$, i.e. viewed $p$-adically?

Reduction transforms an infinite, freely branching, expansive system into a finite one. The set $(\mathbb{Z}/p^k)^3$ is finite, so all orbits are finite and every point is (pre)periodic; since each generator is invertible over $\mathbb{Z}$, every point is in fact periodic. The questions that then arise are quantitative: the size of the phase space, the periods of the generators, the number of orbits, the persistence (or not) of the unipotent/hyperbolic classification, and the fate of the boundary of the tree.

### 1.3 Summary of results

1. **Invariance and invertibility** (Theorems 2.1, 2.3). Each $B_i$ preserves $q$ over an arbitrary commutative ring and has an integral inverse; hence each induces a bijection of the null cone modulo any modulus.
2. **Phase space** (Theorem 3.1). For odd $p$, $\#\{v \in (\mathbb{Z}/p)^3 : q(v)=0\} = p^2$; there are $p^2-1$ nonzero null vectors and $p+1$ null directions.
3. **Unipotent generators** (Theorems 4.2, 4.3, 4.5). $B_1=I+N_1$ with $N_1^3=0$; $\operatorname{ord}(B_1 \bmod p^k)=p^k$ exactly for odd $p$; sharpness: $B_1^{p^k}\not\equiv I \pmod{p^{k+1}}$; the fixed set modulo $p$ is the isotropic line $\{(0,t,t)\}$ of $p$ points.
4. **Hyperbolic generator** (Theorems 5.2–5.6). $B_2$ is conjugate to $\mathrm{diag}(-1)\oplus U$ with $U=3+2J$, $J^2=2$, $\det U=1$; Frobenius gives $U^p=3+2\cdot 2^{(p-1)/2}J$; hence $\operatorname{ord}(B_2\bmod p) \mid p-1$ in the split case and $\mid p+1$ in the inert case, always $\mid p^2-1$. $B_2$ has a nonzero null eigenvector iff $2$ is a square modulo $p$ iff $p\equiv\pm1\pmod 8$, and no nonzero fixed vector at all.
5. **Depth and $p$-adic contraction** (Theorems 6.2, 6.3). $B_2^{(p^2-1)p^k}\equiv I \pmod{p^{k+1}}$, hence $|B_2^Nv-v|_p\le p^{-(k+1)}$ for all integer $v$; the analogous statement for $B_1$ holds with $N=p^k$ and precision $p^{-k}$.
6. **Non-ergodicity** (Theorem 7.2). Every $B_2$-orbit modulo $p$ has at most $p+1$ elements, so $B_2$ is never transitive on the punctured null cone; at least $p-1$ orbits are needed.
7. **The prime $2$** (Theorems 8.1, 8.3). All three generators are the identity modulo $2$, so the tree collapses to a point; equivalently, every vertex of the tree is (odd, even, odd) and no vertex has two odd legs.
8. **No finite-level Cantor set** (Theorems 9.1, 9.2). If $3^d > p^2$, two distinct words of length $d$ have the same image modulo $p$; in particular the boundary does not embed into any fixed $\mathbb{Z}/p^k$.

Throughout, $p$ denotes a prime; "odd prime" always means $p\ne2$. Statements labelled *Theorem* are proved; statements labelled *Conjecture* are supported by computation and stated in §11.

---

## 2. The system and its invariants

Let $R$ be a commutative ring. Regard $B_1,B_2,B_3 \in \mathrm{M}_3(R)$ by reducing their integer entries, and define
$$
q_R(v) = v_0^2+v_1^2-v_2^2,\qquad \mathcal{C}(R) = \{v\in R^3 : q_R(v)=0\}.
$$

**Theorem 2.1 (Lorentz invariance).** *For every commutative ring $R$, every $i\in\{1,2,3\}$ and every $v\in R^3$, $q_R(B_iv)=q_R(v)$. The same holds for the inverses $B_i^{-1}$.*

*Proof.* A direct expansion. For $B_2$, with $v=(a,b,c)$,
$$
(a+2b+2c)^2+(2a+b+2c)^2-(2a+2b+3c)^2 = a^2+b^2-c^2 ,
$$
an identity of polynomials with integer coefficients, hence valid in every commutative ring; likewise for $B_1$ and $B_3$. $\square$

**Theorem 2.2 (Determinants and inverses).** *$\det B_1=\det B_3 = 1$ and $\det B_2 = -1$. Explicitly*
$$
B_1^{-1}=\begin{pmatrix}1&2&-2\\ -2&-1&2\\ -2&-2&3\end{pmatrix},\quad
B_2^{-1}=\begin{pmatrix}1&2&-2\\ 2&1&-2\\ -2&-2&3\end{pmatrix},\quad
B_3^{-1}=\begin{pmatrix}-1&-2&2\\ 2&1&-2\\ -2&-2&3\end{pmatrix},
$$
*all with integer entries, so all three generators are units of $\mathrm{M}_3(R)$ for every $R$.*

**Theorem 2.3 (Finite invertible dynamics).** *For every commutative ring $R$ and every $i$, the map $v\mapsto B_iv$ is a bijection of $\mathcal{C}(R)$ onto itself. In particular, for $R=\mathbb{Z}/p^k$ each generator induces a permutation of the finite set $\mathcal{C}(\mathbb{Z}/p^k)$, and every point of the reduced system is periodic.*

*Proof.* By Theorem 2.1 the map sends $\mathcal{C}(R)$ into itself, and so does the map induced by $B_i^{-1}$ (whose inverse-invariance is the same computation). These two maps are mutually inverse, so each is a bijection of $\mathcal{C}(R)$. Finiteness of $\mathcal{C}(\mathbb{Z}/p^k)$ then forces periodicity. $\square$

Define the *word map*: for $w = (i_1,\dots,i_d)$ a word in $\{1,2,3\}$, put $B_w = B_{i_1}\cdots B_{i_d}$ and let $r = (3,4,5)$ be the root. Since $q(r)=0$ and each generator preserves $q$, an immediate induction gives:

**Proposition 2.4.** *For every word $w$ and every commutative ring $R$, $q_R(B_w r)=0$: the whole tree lies on the null cone.*

---

## 3. The phase space: counting the null cone

**Theorem 3.1 (Null-cone census).** *Let $p$ be an odd prime. Then*
$$
\#\,\mathcal{C}(\mathbb{Z}/p) = p^2 .
$$
*Consequently there are $p^2-1$ nonzero null vectors and $(p^2-1)/(p-1)=p+1$ null directions (projective null points).*

*Proof.* Fibre the cone over the light-cone coordinate $u = v_2-v_0$, a linear functional on $(\mathbb{Z}/p)^3$. We show every fibre has exactly $p$ points.

Suppose first $u\ne0$. On the cone, $v_1^2 = v_2^2-v_0^2 = (v_2-v_0)(v_2+v_0) = u\,(v_2+v_0)$. Since $u$ is invertible, $v_2+v_0 = v_1^2 u^{-1}$ is determined by $v_1$; combined with $v_2-v_0=u$ and the invertibility of $2$, both $v_0$ and $v_2$ are determined by $v_1$. Conversely, for each $v_1=b$ the vector
$$
\Bigl(\tfrac{1}{2}\bigl(b^2u^{-1}-u\bigr),\; b,\; \tfrac{1}{2}\bigl(b^2u^{-1}+u\bigr)\Bigr)
$$
lies on the cone and in the fibre. So the fibre is the graph of a map from $\mathbb{Z}/p$, hence has $p$ points.

Now suppose $u = 0$, i.e. $v_2=v_0$. Then $q(v)=v_1^2=0$, so $v_1=0$ and the fibre is the isotropic line $\{(s,0,s) : s\in\mathbb{Z}/p\}$, again with $p$ points.

There are $p$ values of $u$ and each fibre has $p$ points, giving $p^2$. $\square$

The uniformity of the fibres — including the degenerate one — is precisely the nondegeneracy and isotropy of $q$ over $\mathbb{Z}/p$: the projective conic $q=0$ in $\mathbb{P}^2(\mathbb{F}_p)$ is a smooth conic with $p+1$ rational points, each contributing $p-1$ nonzero vectors, plus the origin: $(p+1)(p-1)+1=p^2$.

---

## 4. The unipotent generators

**Lemma 4.1 (Nilpotent decomposition).** *$B_1 = I+N_1$ and $B_3=I+N_3$ with*
$$
N_1=\begin{pmatrix}0&-2&2\\ 2&-2&2\\ 2&-2&2\end{pmatrix},\qquad
N_3=\begin{pmatrix}-2&2&2\\ -2&0&2\\ -2&2&2\end{pmatrix},
$$
*and*
$$
N_1^2=\begin{pmatrix}0&0&0\\ 0&-4&4\\ 0&-4&4\end{pmatrix},\quad N_1^3=0,\qquad
N_3^2=\begin{pmatrix}-4&0&4\\ 0&0&0\\ -4&0&4\end{pmatrix},\quad N_3^3=0 .
$$
*Moreover $N_1^2=0$ in $\mathrm{M}_3(R)$ if and only if $4=0$ in $R$. Hence the nilpotency index is $3$ at every odd prime power and drops to $2$ modulo $2$ and modulo $4$.*

**Lemma 4.2 (Unipotent power formula).** *In any (possibly noncommutative) ring, if $X^3=0$ then for all $n\ge0$*
$$
(I+X)^n = I + nX + \binom{n}{2}X^2 .
$$

*Proof.* Induction on $n$, using $\binom{n+1}{2}=\binom n2+n$ and $X^3=0$ to kill the only surviving cross term. $\square$

**Theorem 4.3 (Exact order of the unipotent generators).** *Let $p$ be an odd prime and $k\ge1$. Then in $\mathrm{GL}_3(\mathbb{Z}/p^k)$*
$$
B_1^{\,p^k}=I, \qquad B_3^{\,p^k}=I,
$$
*and conversely $B_1^{\,m}=I$ in $\mathrm{GL}_3(\mathbb{Z}/p^k)$ implies $p^k \mid m$. Hence $\operatorname{ord}(B_1 \bmod p^k) = p^k$ exactly: the order is a pure $p$-power with no prime-to-$p$ part.*

*Proof.* By Lemmas 4.1 and 4.2, $B_1^{\,n}=I+nN_1+\binom n2 N_1^2$. Take $n=p^k$. Then $n\equiv0 \pmod{p^k}$, and $\binom{p^k}{2} = p^k\cdot\frac{p^k-1}{2}$ is an integer multiple of $p^k$ because $p^k$ is odd; so both correction terms vanish modulo $p^k$ and $B_1^{p^k}=I$. The same computation applies to $B_3$.

For the converse, read the $(0,1)$ entry of $I+mN_1+\binom m2N_1^2$: since $(N_1)_{01}=-2$ and $(N_1^2)_{01}=0$, the entry equals $-2m$. Thus $B_1^m=I$ forces $2m\equiv0 \pmod{p^k}$; as $p^k$ is odd, $\gcd(p^k,2)=1$ and $p^k\mid m$. $\square$

**Corollary 4.4 (Sharpness of depth).** *For odd $p$ and $k\ge0$, $B_1^{\,p^k}=I$ modulo $p^k$ but $B_1^{\,p^k}\ne I$ modulo $p^{k+1}$.*

*Proof.* If $B_1^{p^k}=I$ in $\mathrm{GL}_3(\mathbb{Z}/p^{k+1})$ then Theorem 4.3 with $k+1$ gives $p^{k+1}\mid p^k$, a contradiction. $\square$

Thus each unipotent generator gains exactly one $p$-adic digit per $p$-th power — no more, no less.

**Theorem 4.5 (Fixed sets of the unipotent generators).** *Over any commutative ring, $B_1(0,1,1)^{\!\top}=(0,1,1)^{\!\top}$ and $B_3(1,0,1)^{\!\top}=(1,0,1)^{\!\top}$, and both fixed vectors are null. Modulo an odd prime $p$, the fixed set of $B_1$ is exactly the isotropic line $\{(0,t,t):t\in\mathbb{Z}/p\}$, of cardinality $p$; symmetrically for $B_3$ with $\{(t,0,t)\}$.*

*Proof.* The first assertion is a two-line multiplication, and $q(0,t,t)=t^2-t^2=0$. For the classification, write $B_1v=v$ as $N_1v=0$; the three equations read $-2v_1+2v_2=0$, $2v_0-2v_1+2v_2=0$, $2v_0-2v_1+2v_2=0$. As $2$ is invertible, the first gives $v_1=v_2$ and the second then gives $v_0=0$. Conversely every such vector is fixed. $\square$

Geometrically: a parabolic isometry of the hyperbolic plane fixes exactly one point of the boundary circle, and the fixed set here is exactly one isotropic line, entirely inside the cone.

---

## 5. The hyperbolic generator modulo $p$

### 5.1 Block decomposition

**Lemma 5.1.** *Let*
$$
W=\begin{pmatrix}1&1&0\\ -1&1&0\\ 0&0&1\end{pmatrix},\qquad
S = \begin{pmatrix}-1&0&0\\0&1&0\\0&0&1\end{pmatrix},\qquad
\iota(U)=\begin{pmatrix}1&0&0\\ 0&3&2\\ 0&4&3\end{pmatrix} .
$$
*Then $B_2 W = W\,(S\,\iota(U))$ over every commutative ring, where $U=\begin{pmatrix}3&2\\4&3\end{pmatrix}$. Moreover $W\cdot\begin{pmatrix}1&-1&0\\1&1&0\\0&0&2\end{pmatrix} = 2I$, so $W$ is invertible whenever $2$ is.*

Thus $B_2$ acts as $-1$ on the spacelike eigenvector $(1,-1,0)$ (note $q(1,-1,0)=2\ne0$) and as $U$ on the complementary plane.

**Lemma 5.2 (The block is $3+2\sqrt2$).** *Set $J=\begin{pmatrix}0&1\\2&0\end{pmatrix}$. Then $J^2=2I$ and $U=3I+2J$, with $\det U = 9-8=1$; equivalently $(3+2J)(3-2J)=I$. So $U$ realises multiplication by the norm-one unit $3+2\sqrt2 = (1+\sqrt2)^2$ of $\mathbb{Z}[\sqrt2]$ in the basis $\{1,\sqrt2\}$.*

### 5.2 Frobenius and the split/inert dichotomy

**Theorem 5.3 (Frobenius on the hyperbolic block).** *Let $p$ be an odd prime. In $\mathrm{M}_2(\mathbb{Z}/p)$,*
$$
U^p = 3I + 2\cdot 2^{(p-1)/2}\,J .
$$

*Proof.* Scalars commute with everything, so the freshman's dream applies: $(3I+2J)^p = (3I)^p+(2J)^p$ in characteristic $p$. Now $(3I)^p = 3^pI = 3I$ and $(2J)^p = 2^pJ^p = 2J^p$ by Fermat's little theorem. Since $p$ is odd, $J^p = (J^2)^{(p-1)/2}J = 2^{(p-1)/2}J$. $\square$

**Theorem 5.4 (Period of the hyperbolic generator).** *Let $p$ be an odd prime.*
1. *If $2$ is a quadratic residue modulo $p$, then $B_2^{\,p-1}=I$ in $\mathrm{GL}_3(\mathbb{Z}/p)$.*
2. *If $2$ is not a quadratic residue modulo $p$, then $B_2^{\,p+1}=I$.*
3. *In all cases $B_2^{\,p^2-1}=I$, i.e. $\operatorname{ord}(B_2\bmod p)\mid p^2-1$.*

*Proof.* By Euler's criterion $2^{(p-1)/2}=\pm1$ according to the quadratic character of $2$.

*Split case.* $2^{(p-1)/2}=1$ gives $U^p=3I+2J=U$ by Theorem 5.3, and multiplying by $U^{-1}$ (which exists since $\det U=1$) yields $U^{p-1}=I$. The sign block satisfies $S^{p-1}=I$ because $p-1$ is even. Conjugating back through Lemma 5.1 — legitimate since $2$ is invertible modulo $p$ — gives $B_2^{p-1}=I$.

*Inert case.* $2^{(p-1)/2}=-1$ gives $U^p = 3I-2J = U^{-1}$, whence $U^{p+1}=I$; and $S^{p+1}=I$ since $p+1$ is even. Conjugating back gives $B_2^{p+1}=I$.

*General bound.* $p^2-1=(p-1)(p+1)$ is a multiple of both $p-1$ and $p+1$, so in either case $B_2^{p^2-1}=I$. $\square$

**Theorem 5.5 (Null eigenvectors and $p \bmod 8$).** *Let $p$ be an odd prime. The following are equivalent:*
1. *$B_2$ has a nonzero eigenvector lying on the null cone modulo $p$;*
2. *$2$ is a square modulo $p$;*
3. *$p\equiv \pm1 \pmod 8$.*

*Proof.* $(2)\Rightarrow(1)$: if $s^2=2$ in $\mathbb{Z}/p$, then $v=(1,1,s)$ satisfies $q(v)=1+1-s^2=0$ and a direct computation gives $B_2v=(3+2s)v$, where $(3+2s)(3-2s)=9-4s^2=1$, so the eigenvalue is a unit.

$(1)\Rightarrow(2)$: by Lemma 5.1 the eigenvalues of $B_2$ over $\overline{\mathbb{F}_p}$ are $-1$ (eigenvector $(1,-1,0)$, with $q=2\ne0$) and the eigenvalues $3\pm2s$ of $U$, which are rational over $\mathbb{Z}/p$ only when $s^2=2$ is solvable. Since a null eigenvector must be a $\mathbb{Z}/p$-rational eigenvector not proportional to $(1,-1,0)$, its eigenvalue lies in the $U$-block, forcing $2$ to be a square.

$(2)\Leftrightarrow(3)$: the supplementary law of quadratic reciprocity, $\left(\frac2p\right)=(-1)^{(p^2-1)/8}$. $\square$

So the split/inert behaviour of the prime $p$ in $\mathbb{Q}(\sqrt2)$ is exactly the hyperbolic/elliptic dichotomy of the reduced Berggren move: for $p\equiv\pm1 \pmod 8$ the boost keeps its two null eigendirections and acts on each by a scalar of finite order; for $p\equiv\pm3\pmod 8$ the eigendirections are conjugate over $\mathbb{F}_{p^2}$ and the move is a rotation of order dividing $p+1$.

**Theorem 5.6 (No nonzero fixed vector).** *Let $p$ be an odd prime and $v\in(\mathbb{Z}/p)^3$ with $B_2v=v$. Then $v=0$. Consequently, modulo $p$ the unipotent generator has exactly $p$ fixed points and the hyperbolic generator exactly one.*

*Proof.* Writing out $B_2v=v$ coordinatewise and subtracting $v$ gives $2(v_1+v_2)=0$, $2(v_0+v_2)=0$, $2(v_0+v_1+v_2)=0$. Since $2$ is invertible, $v_1+v_2=v_0+v_2=v_0+v_1+v_2=0$; subtracting the first two from the third yields $v_2 = 0$, and then $v_0=v_1=0$. The count for $B_1$ is Theorem 4.5. $\square$

**Theorem 5.7 (Genuine noncommutativity).** *For every odd prime $p$, $B_1B_2 \ne B_2B_1$ in $\mathrm{M}_3(\mathbb{Z}/p)$.*

*Proof.* The $(0,0)$ entries are $1$ and $9$ respectively, and $9-1=8$ vanishes modulo $p$ only for $p=2$. $\square$

The reduced system is therefore a nonabelian permutation group on the finite cone for every odd prime; the collapse at $p=2$ is not a shadow of some general abelianisation.

---

## 6. Depth: lifting to $\mathbb{Z}/p^k$

Call an integer matrix $A$ *entrywise divisible* by $d$, written $d \mid A$, if $d$ divides every entry.

**Lemma 6.1 (Hensel step).** *Let $A\in\mathrm{M}_3(\mathbb{Z})$, $p$ a prime and $j\ge1$. If $p^j \mid (A-I)$ entrywise, then $p^{\,j+1} \mid (A^p-I)$ entrywise.*

*Proof.* Set $X=A-I$. Expanding $(I+X)^p$ and collecting terms gives $A^p - I = pX + X^2C$ for some integer matrix $C$ (formally: $(I+X)^n=I+nX+X^2C_n$ by induction). The first summand is divisible by $p\cdot p^j = p^{j+1}$, and the second by $p^{2j}$, which is divisible by $p^{j+1}$ since $j\ge1$. $\square$

**Lemma 6.1′ (Hensel lift).** *If $p \mid (A-I)$ entrywise, then $p^{\,k+1} \mid (A^{p^k}-I)$ entrywise for all $k\ge0$.*

*Proof.* Induction on $k$, applying Lemma 6.1 to $A^{p^k}$. $\square$

**Theorem 6.2 ($p$-adic periodicity of the hyperbolic generator).** *For every odd prime $p$ and every $k\ge0$,*
$$
B_2^{\,(p^2-1)p^k} = I \quad\text{in } \mathrm{GL}_3(\mathbb{Z}/p^{k+1}).
$$
*In particular every $v\in(\mathbb{Z}/p^{k+1})^3$, and hence every point of the null cone at depth $k+1$, is a periodic point of period dividing $(p^2-1)p^k$.*

*Proof.* Theorem 5.4(3) says $B_2^{p^2-1}\equiv I \pmod p$, i.e. $p$ divides $B_2^{p^2-1}-I$ entrywise over $\mathbb{Z}$. Apply Lemma 6.1′ with $A = B_2^{p^2-1}$: then $p^{k+1}$ divides $A^{p^k}-I = B_2^{(p^2-1)p^k}-I$ entrywise, which is the claim after reduction. $\square$

**Theorem 6.3 ($p$-adic contraction).** *Let $p$ be an odd prime, $k\ge0$, $N=(p^2-1)p^k$, and let $v\in\mathbb{Z}^3$ be arbitrary. Then every coordinate of $B_2^{\,N}v-v$ is divisible by $p^{k+1}$; equivalently, in the $p$-adic metric,*
$$
\bigl|B_2^{\,N}v - v\bigr|_p \le p^{-(k+1)} .
$$
*Similarly, for the unipotent generator, every coordinate of $B_1^{\,p^k}v-v$ is divisible by $p^k$, so $|B_1^{p^k}v-v|_p \le p^{-k}$.*

*Proof.* Entrywise divisibility of $B_2^N-I$ (Theorem 6.2 over $\mathbb{Z}$) passes to matrix–vector products: if $p^{k+1}$ divides every entry of $M$ then it divides every coordinate of $Mv$. Apply this with $M = B_2^N-I$. For $B_1$, Lemma 4.2 gives $B_1^{p^k}-I = p^kN_1 + \binom{p^k}{2}N_1^2$, and both coefficients are divisible by $p^k$ (Theorem 4.3). $\square$

This is the precise sense in which the *hyperbolic* generator — which expands without bound at the archimedean place — is $p$-adically recurrent: its expansion factor $3+2\sqrt2$ is a $p$-adic unit, and units are torsion in every finite quotient up to a pro-$p$ correction. Numerically, for $p=5$, $k=2$, $N=600$, the vector $B_2^{600}(3,4,5)$ has $460$-digit entries, yet agrees with $(3,4,5)$ to three $5$-adic digits.

---

## 7. Orbit structure and the failure of ergodicity

**Lemma 7.1.** *If $M^m=I$ then $M^n = M^{n \bmod m}$ for all $n$. Hence the forward orbit of any $v$ under $M$ has at most $m$ elements.*

**Theorem 7.2 (Short orbits; no transitivity).** *Let $p$ be an odd prime. There is $m$ with $1\le m\le p+1$ and $B_2^{\,m}=I$ in $\mathrm{GL}_3(\mathbb{Z}/p)$; consequently every $B_2$-orbit in $(\mathbb{Z}/p)^3$ has at most $p+1$ points. Since the punctured null cone has $p^2-1=(p-1)(p+1)$ points and $p\ge3$, no single orbit can exhaust it: $B_2$ is never transitive on the nonzero null vectors, and at least $p-1$ orbits are needed.*

*Proof.* Take $m=p-1$ in the split case and $m=p+1$ in the inert case (Theorem 5.4); both are at most $p+1$. Lemma 7.1 bounds orbits by $m$. If a single orbit covered the punctured cone we would get $p^2-1\le p+1$, i.e. $p^2\le p+2$, false for $p\ge3$. Dividing the cardinality by the maximal orbit length gives the lower bound $(p^2-1)/(p+1)=p-1$ on the number of orbits. $\square$

This is the sharpest structural difference between the real and the reduced pictures. Over $\mathbb{R}$, the hyperbolic generator acting on the boundary circle has dense orbits accumulating at its two fixed null directions; modulo $p$, the dynamics is a disjoint union of at most $(p+1)$-cycles. Whatever the reduction preserves, it is not mixing.

**Theorem 7.3 (Explicit orbits in the split case).** *Suppose $s^2=2$ in $\mathbb{Z}/p$. Then, with $v=(1,1,s)$ a null eigenvector,*
$$
B_2^{\,n} v = (3+2s)^n\, v \quad \text{for all } n\ge 0,
$$
*and $B_2^{\,n}v=v$ if and only if $(3+2s)^n=1$. Hence the exact period of $B_2$ on this null line equals the multiplicative order of the unit $3+2\sqrt2$ in $(\mathbb{Z}/p)^\times$.*

*Proof.* Induction from $B_2v=(3+2s)v$; for the converse, compare first coordinates, using that $v_0=1$. $\square$

**Computed orbit data.** Direct enumeration of $B_2$ acting on the $p^2-1$ nonzero null vectors gives:

| $p$ | $p \bmod 8$ | $2$ square? | $\operatorname{ord}(B_2)$ | $\#$ orbits | orbit lengths |
|---|---|---|---|---|---|
| $3$ | $3$ | no | $4$ | $2$ | $4^2$ |
| $5$ | $5$ | no | $6$ | $4$ | $6^4$ |
| $7$ | $7$ | yes | $6$ | $10$ | $3^4,\,6^6$ |
| $11$ | $3$ | no | $12$ | $10$ | $12^{10}$ |
| $13$ | $5$ | no | $14$ | $12$ | $14^{12}$ |
| $17$ | $1$ | yes | $8$ | $36$ | $8^{36}$ |

In every case the order is $p-1$ or a divisor of it (split) resp. $p+1$ or a divisor (inert), and the number of orbits is at least $p-1$, as Theorem 7.2 requires.

---

## 8. The prime $2$: total collapse and the parity of the tree

**Theorem 8.1 (Collapse at $2$).** *In $\mathrm{M}_3(\mathbb{Z}/2)$ we have $B_1=B_2=B_3=I$. Consequently, every word in the generators reduces to $I$ modulo $2$, and every vertex of the tree satisfies $B_w r \equiv r \equiv (1,0,1) \pmod 2$.*

*Proof.* Every off-diagonal entry of each $B_i$ is even and every diagonal entry is odd. The statement about words follows by induction on the length; $(3,4,5)\equiv(1,0,1)$. $\square$

The mod-$2$ system is a single fixed point: the "if false" scenario for the whole programme is realised at exactly one prime, and only there.

**Theorem 8.2 (Nilpotency degeneracy at $2$).** *$N_1^2=0$ in $\mathrm{M}_3(R)$ if and only if $4=0$ in $R$. Hence the unipotent generators have nilpotency index $3$ modulo every odd prime power and index $2$ modulo $2$ and modulo $4$.*

**Theorem 8.3 (Parity of the tree).** *For every word $w$, the triple $B_wr = (a,b,c)$ satisfies $a\equiv1$, $b\equiv0$, $c\equiv1 \pmod 2$. In particular no vertex of the tree has two odd legs.*

*Proof.* This is Theorem 8.1 read over $\mathbb{Z}$: the residues mod $2$ are invariant along the tree and equal those of the root. $\square$

So the classical parity constraint on primitive Pythagorean triples — exactly one leg even — is, from the present viewpoint, a fixed-point theorem for the $2$-adic Berggren dynamics. Degeneracy at $2$ and arithmetic rigidity at $2$ are the same phenomenon.

---

## 9. The boundary of the tree does not survive reduction

The tree is a rooted ternary tree; its *boundary* is the space of infinite words in three letters, a Cantor set. One might hope that reduction embeds it into $\mathbb{Z}_p^3$ as a $p$-adic Cantor set with a computable Hausdorff dimension. At any fixed finite level this fails, for counting reasons.

**Theorem 9.1 (Collision bound).** *Let $m\ge1$ and $d\ge1$ with $m^3 < 3^d$. Then there exist distinct words $w_1\ne w_2$ of length $d$ with $B_{w_1}r \equiv B_{w_2}r \pmod m$.*

*Proof.* The word map sends the $3^d$ words of length $d$ into $(\mathbb{Z}/m)^3$, a set of size $m^3<3^d$; pigeonhole. $\square$

**Theorem 9.2 (Quadratic collision bound on the cone).** *Let $p$ be an odd prime and $d$ with $3^d > p^2$. Then two distinct words of length $d$ have the same image modulo $p$.*

*Proof.* All images lie on the null cone modulo $p$ (Proposition 2.4), which has exactly $p^2$ points by Theorem 3.1; pigeonhole again. $\square$

The second bound is quadratic in $p$ rather than cubic, and it is the arithmetically meaningful one: the reduction of the boundary has box dimension at most $2$ in the naive sense, and no fixed level $\mathbb{Z}/p^k$ can hold a faithful copy of it. For $p=5$, $d=4$, the $81$ words of length $4$ produce only $12$ distinct residues.

What *does* survive is the inverse-limit statement of §6: the generators are periodic to any prescribed precision, so the dynamical system is well-defined and nontrivial over $\mathbb{Z}_p$, even though every finite truncation is a small finite permutation group. The right object to attach a dimension to is therefore not the image at a fixed level but the profinite limit — see §11.

---

## 10. Algorithms

Three routines suffice to reproduce all computations above; all are elementary and cheap.

**A. Order of a generator modulo $m$.** Compute successive powers of $B$ modulo $m$ until the identity is reached. Complexity $O(\operatorname{ord}(B)\cdot 27)$ ring operations, or $O(\log N \cdot 27)$ if instead one only verifies $B^N=I$ for a candidate exponent $N$ by binary exponentiation. For $B_1$ the answer is provably $p^k$; for $B_2$ modulo $p$ it is a divisor of $p\mp1$ decided by the Legendre symbol $\left(\frac2p\right)$, so one may verify rather than search.

**B. Null-cone enumeration and fibration.** Enumerate $(\mathbb{Z}/p)^3$ and retain $q=0$: $O(p^3)$. Better, use the fibration of Theorem 3.1 to *generate* the cone in $O(p^2)$: for each unit $u$ and each $b$, emit $\bigl(\tfrac12(b^2u^{-1}-u),\,b,\,\tfrac12(b^2u^{-1}+u)\bigr)$; then emit the isotropic line $(s,0,s)$. This is the constructive content of the census theorem.

**C. Orbit decomposition.** Union-find or simple marking over the punctured cone: start at an unvisited $v$, iterate $v\mapsto B_2v$ until return, record the length. Total cost $O(p^2)$ vector multiplications, since each null vector is visited once. The output is the cycle type of the permutation induced by $B_2$, from which the orbit count and the non-transitivity of Theorem 7.2 are immediate.

**D. Hensel verification.** To confirm $B_2^{(p^2-1)p^k}\equiv I \pmod{p^{k+1}}$, use binary exponentiation modulo $p^{k+1}$: $O(\log((p^2-1)p^k))$ matrix multiplications on $3\times3$ matrices with entries of size $O(k\log p)$.

---

## 11. Discussion, conjectures and future work

### 11.1 What is preserved and what is lost

The reduction preserves the *classification* and destroys the *dynamics*. Preserved: unipotence (with a pure $p$-power order and an isotropic fixed line), the hyperbolic block $3+2\sqrt2$ and its norm-one character, the noncommutativity of the group, the invariance of $q$, and the invertibility of the moves. Lost: infinite order, expansion, and above all mixing — Theorem 7.2 shows the reduced system is never ergodic on the null cone.

The one genuinely new local phenomenon is the split/inert dichotomy of Theorem 5.5: the hyperbolic generator is hyperbolic modulo $p$ exactly for $p\equiv\pm1\pmod 8$ and elliptic otherwise. This is the arithmetic of $\mathbb{Q}(\sqrt2)$ visible in the dynamics of right triangles.

### 11.2 Open problems

**Conjecture 1 (Null cone at depth $k$).** For every odd prime $p$ and every $k\ge1$,
$$
\#\{v\in(\mathbb{Z}/p^k)^3 : v_0^2+v_1^2-v_2^2 = 0\} = (p-1)p^{2k-1}\sum_{j=0}^{k-1}p^{-\lceil j/2\rceil} + p^{\,2k-\lceil k/2\rceil},
$$
which for $k=1$ is $p^2$ (Theorem 3.1) and for $k=2$ is $p^4+p^3-p^2$ — verified by enumeration for $p=3$ (value $99$) and $p=5$ (value $725$). The key insight is that the light-cone substitution $u=c-a$, $v=c+a$ turns the quadratic condition into $uv=b^2$, so the count is controlled by the $p$-adic valuation of $u$: fibres over units contribute uniformly, and it is exactly the valuation-$j$ strata — the singular locus of the cone — that break the naive guess $p^{2k}$. Establishing this is the missing ingredient for a box-counting dimension statement for the reduction of the boundary.

**Conjecture 2$'$ (Sharpness of the $p$-part of the period, corrected).** The natural guess is that for every odd prime $p$ and every $k\ge0$ the order of $B_2$ in $\mathrm{GL}_3(\mathbb{Z}/p^{k+1})$ equals $\operatorname{ord}(B_2\bmod p)\cdot p^k$, so that Theorem 6.2 would be sharp in its $p$-part. The mechanism would be that $B_2^{\operatorname{ord}(B_2 \bmod p)} = I+pN$ with $N\not\equiv 0 \pmod p$, making the pro-$p$ subgroup it generates torsion-free of level exactly one; the unipotent analogue of that statement is Corollary 4.4, which is a theorem. For $p\in\{3,5,7\}$ the orders modulo $p,p^2,p^3$ are indeed $(4,12,36)$, $(6,30,150)$, $(6,42,294)$.

**This guess is false as stated.** Direct computation shows that $p=13$ and $p=31$ are exceptions, and they are the only ones below $3000$:
$$
\operatorname{ord}(B_2 \bmod 13) = \operatorname{ord}(B_2 \bmod 13^2) = 14, \qquad \operatorname{ord}(B_2\bmod 13^3) = 182 = 14\cdot 13,
$$
$$
\operatorname{ord}(B_2 \bmod 31) = \operatorname{ord}(B_2 \bmod 31^2) = 30, \qquad \operatorname{ord}(B_2\bmod 31^3) = 930 = 30\cdot 31 .
$$
These are Wieferich-type primes for the unit $3+2\sqrt2$: the eigenvalue is already trivial to two $p$-adic digits, so the first Hensel step buys no new period. The corrected statement, which the data support, is: *for every odd prime $p$ there is a level $w_p\ge1$ (the Wieferich level of $3+2\sqrt2$ at $p$) with*
$$
\operatorname{ord}\bigl(B_2 \bmod p^{k}\bigr) = \operatorname{ord}(B_2\bmod p)\cdot p^{\max(0,\,k-w_p)},
$$
*with $w_p=1$ for all $p<3000$ except $w_{13}=w_{31}=2$.* Deciding whether $w_p$ is bounded, or whether the exceptional set is infinite, is exactly as hard as the corresponding classical question for Wieferich primes.

**Conjecture 3 (Orbit count of the hyperbolic generator).** Determine, as an explicit function of $p$ (and of $p \bmod 8$), the number of $B_2$-orbits on the null cone modulo $p$. Theorem 7.2 gives the lower bound $p-1$, and the table in §7 shows the count is genuinely sensitive to the multiplicative order of $3+2\sqrt2$: $2,4,10,10,12,36$ for $p=3,5,7,11,13,17$. A clean formula should follow from the split/inert case division together with the cycle structure of multiplication by $3+2\sqrt2$ on the $p+1$ null directions.

**Problem 4 (A profinite boundary).** Theorems 9.1–9.2 kill any Cantor set at a fixed finite level. Is there nevertheless a natural injection of the boundary of the tree into $\mathbb{Z}_p^3$ or into the projective null cone over $\mathbb{Z}_p$, and does it carry a computable Hausdorff dimension? The correct setting is presumably the inverse limit over $k$, with Conjecture 1 supplying the level-$k$ counts.

**Problem 5 (Local-global depth).** Call a primitive triple *$p$-adically deep* if it is close to $(3,4,5)$ in the $p$-adic metric. Which triples are deep, and how does $p$-adic depth correlate with depth in the tree? Theorem 6.3 shows that $p$-adic proximity to the root recurs with period $(p^2-1)p^k$ along the $B_2$-axis, which suggests a genuine tension between the two notions of depth.

**Problem 6 (Other quadratic forms and other trees).** The analysis used only that $q$ is a nondegenerate isotropic ternary form and that the hyperbolic generator is the matrix of a norm-one unit of a real quadratic order. Everything above should generalise to trees of solutions of $a^2+Db^2=c^2$ with the corresponding unit of $\mathbb{Z}[\sqrt D]$, replacing the condition "$2$ is a square modulo $p$" by a condition on the splitting of $p$ in $\mathbb{Q}(\sqrt D)$.

### 11.3 Applications

Beyond the intrinsic interest, two directions look practical. First, the mod-$p$ census and the orbit tables give exact obstructions for enumerating primitive triples by residue class: the reduction is far from equidistributed at any fixed level, so sieve-type arguments over the tree must account for the cycle structure. Second, the exact orders $\operatorname{ord}(B_1 \bmod p^k)=p^k$ and $\operatorname{ord}(B_2 \bmod p) \mid p\mp1$ make the reduced system a compact, fully analysed testbed for algorithms in arithmetic dynamics — orbit-counting, period-finding, and Hensel lifting — where the exact answers are known in advance.

---

## 12. Conclusion

The Berggren tree, reduced modulo a prime power, is a completely analysable finite dynamical system. Its phase space has exactly $p^2$ points; its two parabolic generators have order exactly $p^k$ at depth $k$ and each fixes one isotropic line; its hyperbolic generator has order dividing $p-1$ or $p+1$ according as $p\equiv\pm1$ or $\pm3 \pmod 8$, always dividing $p^2-1$, and it fixes nothing but the origin. Lifting by Hensel's principle, the hyperbolic generator is periodic to arbitrary $p$-adic precision, with period dividing $(p^2-1)p^{k}$ modulo $p^{k+1}$. Yet its orbits are short: the system is never transitive on the null cone, so the mixing of the real hyperbolic picture is entirely lost. At $p=2$ the system degenerates to a point — and that degeneracy is exactly the classical parity of Pythagorean triples. The infinite ternary boundary of the tree cannot be embedded at any fixed finite level; what remains, and what invites further work, is the profinite limit.
