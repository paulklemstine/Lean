# Berggren-Generated Pythagorean Triples in a Box: Exact Counting, Effective $\Theta(H)$ Bounds, and a Visible-Point Bijection

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Berggren's three unimodular matrices $B_1, B_2, B_3$ acting on the seed $(3,4,5)$
generate a ternary tree of integer triples. We prove, in effective and fully
explicit form, the following. First, the tree is exactly the set of positive
primitive Pythagorean triples $(a,b,c)$ whose first leg $a$ is odd (closure by
direct algebraic verification, completeness by a descent on the hypotenuse), and
the tree is *free*: distinct words in the generators produce distinct triples.
Second, writing $\mathcal{B}(H)$ for the set of tree triples lying in the box
$[1,H]^3$, we prove the two-sided bound

$$\frac{H}{100} \le \#\mathcal{B}(H) \le \min\Bigl(4H,\ \bigl(\lfloor\sqrt H\rfloor+1\bigr)^2\Bigr)
\qquad (H \ge 5),$$

so $\#\mathcal{B}(H) = \Theta(H)$ and consequently $\#\mathcal{B}(H)/H^3 \to 0$:
Berggren-generated triples occupy a vanishing proportion of the $H^3$ integer
points of the box. Third, and in contrast, we prove the *exact* identity
$\#\mathcal{P}(H) = 2\,\#\mathcal{B}(H)$, where $\mathcal{P}(H)$ is the set of all
ordered primitive Pythagorean triples in the same box; equivalently, every
primitive Pythagorean triple of the box is Berggren-generated up to swapping its
two legs. The advertised proportion "$1-o(1)$" of primitive triples is therefore
an exact $1$, with no error term. Fourth, we exhibit a bijection between
$\mathcal{B}(H)$ and the set of coprime, opposite-parity lattice points $(n,m)$
with $0<n<m$ and $m^2+n^2\le H$, reducing the whole counting problem to a
visible-point count in a circular wedge; this identifies the conjectural sharp
constant as $\#\mathcal{B}(H)/H \to 1/(2\pi)$, in agreement with computation to
five decimal places. Finally we analyse the growth geometry of the tree: the
generator $B_2$ is hyperbolic with expansion factor $3+2\sqrt2$, whereas $B_3$ is
unipotent and its orbit of a triple with hypotenuse $c$ has hypotenuse
$c + O(k^2)$ at depth $k$, giving a seed-independent $\Omega(\sqrt H)$ lower
bound on the depth of the tree inside the box.

**Keywords:** Pythagorean triples, Berggren tree, ternary tree of triples,
lattice point counting, visible lattice points, coprimality density, Gauss
circle problem, unipotent orbits, Euclid parametrisation.

---

## 1. Introduction

### 1.1 The object

A *Pythagorean triple* is a triple $(a,b,c)$ of positive integers with
$a^2+b^2=c^2$; it is *primitive* if $\gcd(a,b)=1$. Since $\gcd(a,b)=1$ forces
$\gcd(a,c)=\gcd(b,c)=1$, primitivity is equivalently the statement that no
integer $>1$ divides all three coordinates.

The set of primitive triples has two classical descriptions. The *Euclid
parametrisation* says every primitive triple with odd first leg is
$$(m^2-n^2,\ 2mn,\ m^2+n^2)$$
for a unique pair $0<n<m$ with $\gcd(n,m)=1$ and $n+m$ odd. The *Berggren
description*, discovered by B. Berggren in 1934 and rediscovered several times
since, is structural rather than parametric: the three integer matrices

$$
B_1 = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},
\qquad
B_2 = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},
\qquad
B_3 = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}
$$

acting on column vectors $(a,b,c)^{\mathsf T}$, applied repeatedly to the seed
$(3,4,5)$, generate every primitive triple with odd first leg exactly once.

### 1.2 The question

Both descriptions are qualitative. The question addressed here is quantitative:
**how many of the $H^3$ integer points of the box $[1,H]^3$ are
Berggren-generated?** and **how does that count compare with the number of
primitive Pythagorean triples in the same box?**

The answers we prove are, respectively, $\Theta(H)$ — hence a vanishing
proportion of $H^3$ — and *exactly one half of the ordered primitive triples*,
which is to say all of them once the two legs are regarded as unordered.

### 1.3 Overview of the argument

Section 2 fixes notation. Section 3 proves the structure theorem (closure and
completeness by descent, plus freeness). Section 4 proves the upper bound by a
two-square substitution. Section 5 proves the lower bound by an effective
coprimality density estimate. Section 6 assembles the $\Theta(H)$ statement and
the vanishing-density corollary. Section 7 proves the exact comparison with the
primitive triples. Section 8 gives the visible-point bijection and the
$1/(2\pi)$ analysis. Section 9 analyses the growth geometry of the generators.
Section 10 gives algorithms; Section 11 numerical evidence; Section 12
discussion and open problems.

---

## 2. Notation and definitions

**Definition 2.1 (triple, validity).** A *triple* is an element of
$\mathbb Z^3$, written $t=(a,b,c)$. We call $t$ **valid** if

$$a>0,\quad b>0,\quad c>0,\quad a^2+b^2=c^2,\quad \gcd(a,b)=1,\quad a \equiv 1 \pmod 2 .$$

Thus a valid triple is a positive primitive Pythagorean triple whose *first* leg
is odd.

**Definition 2.2 (the Berggren maps).** Define $\beta_1,\beta_2,\beta_3:\mathbb Z^3\to\mathbb Z^3$ by

$$
\begin{aligned}
\beta_1(a,b,c) &= (\,a-2b+2c,\ \ 2a-b+2c,\ \ 2a-2b+3c\,),\\
\beta_2(a,b,c) &= (\,a+2b+2c,\ \ 2a+b+2c,\ \ 2a+2b+3c\,),\\
\beta_3(a,b,c) &= (-a+2b+2c,\ -2a+b+2c,\ -2a+2b+3c\,).
\end{aligned}
$$

These are the actions of $B_1,B_2,B_3$.

**Definition 2.3 (the tree).** The *Berggren tree* $\mathcal{T}\subseteq\mathbb Z^3$
is the smallest set containing $(3,4,5)$ and closed under $\beta_1,\beta_2,\beta_3$.
We say $t$ is *reachable*, written $t \in \mathcal{T}$, if it lies in this set.
Equivalently, $t\in\mathcal T$ iff $t = \beta_{w_1}\beta_{w_2}\cdots\beta_{w_\ell}(3,4,5)$
for some word $w \in \{1,2,3\}^{\ell}$; we write $\rho(w)$ for that triple.

**Definition 2.4 (the boxes).** For $H \in \mathbb N$ put

$$
\begin{aligned}
\mathcal{B}(H) &= \{\,t \in \mathcal T : 1\le a,b,c \le H \,\}, \\
\mathcal{P}(H) &= \{\,(a,b,c) : 1 \le a,b,c\le H,\ a^2+b^2=c^2,\ \gcd(a,b)=1\,\},\\
\mathcal{P}^{\mathrm{odd}}(H) &= \{\,t \in \mathcal P(H) : a \text{ odd}\,\},\\
\mathcal{Q}(H) &= \{\,(n,m)\in\mathbb N^2 : 1\le n<m,\ \gcd(n,m)=1,\ n+m \text{ odd},\ m^2+n^2\le H\,\}.
\end{aligned}
$$

Note that $\mathcal P(H)$ counts *ordered* triples: $(3,4,5)$ and $(4,3,5)$ are
two of its elements.

**Remark 2.5 (the box condition is a hypotenuse condition).** If $(a,b,c)$ is a
positive Pythagorean triple then $a<c$ and $b<c$ (because $a^2 = c^2-b^2 < c^2$
and $a,c>0$). Hence $t \in \mathcal B(H) \iff t\in\mathcal T$ and $c \le H$. The
same holds for $\mathcal P(H)$. This makes all the counts below counts of
triples with bounded hypotenuse, and makes the depth-first enumeration of
Section 10 correct.

---

## 3. The structure theorem

### 3.1 Closure

**Lemma 3.1 (each generator preserves validity).** If $t$ is valid then so are
$\beta_1(t)$, $\beta_2(t)$ and $\beta_3(t)$.

*Proof sketch.* Four things must be checked for each $\beta_i$.

*(i) Pythagorean identity.* Expanding, e.g. for $\beta_2$,
$$(a+2b+2c)^2 + (2a+b+2c)^2 - (2a+2b+3c)^2 = -a^2-b^2+c^2 = 0,$$
an identity of polynomials which reduces to $a^2+b^2=c^2$; the same computation
works for $\beta_1$ and $\beta_3$ up to signs.

*(ii) Positivity.* For a positive Pythagorean triple one has $c<a+b$ (square
both sides: $c^2 = a^2+b^2 < (a+b)^2$ since $2ab>0$), and $a<c$, $b<c$. Then
for $\beta_1$: $a-2b+2c > a-2b+2b = a > 0$ using $c>b$; similarly for the other
coordinates and generators, every coordinate is a positive combination after
substituting one of $c<a+b$, $a<c$, $b<c$.

*(iii) Primitivity.* Primitivity of $(a,b,c)$ is equivalent to the statement
$$\forall d\in\mathbb Z:\ d\mid a,\ d\mid b,\ d\mid c \implies d \in\{\pm1\},$$
and the coordinates of $\beta_i(t)$ are integer linear combinations of $a,b,c$
while the inverse matrices $B_i^{-1}$ are again integral (each $B_i$ has
determinant $\pm 1$). Hence a common divisor of the image coordinates divides
the source coordinates, and conversely; primitivity transfers.

*(iv) Parity of the first leg.* If $a$ is odd and $(a,b,c)$ is primitive, then
$b$ is even and $c$ is odd (see Lemma 7.1). Then $a-2b+2c$, $a+2b+2c$ and
$-a+2b+2c$ are all odd. $\square$

**Theorem 3.2 (closure).** Every $t\in\mathcal T$ is valid.

*Proof.* Induction on the generation of $\mathcal T$: the seed $(3,4,5)$ is
valid, and Lemma 3.1 propagates validity along each generator. $\square$

### 3.2 Completeness by descent

Fix a valid triple $(a,b,c)$ and define the three *parent forms*

$$u = a + 2b - 2c, \qquad v = 2a + b - 2c, \qquad w = 3c-2a-2b .$$

They are exactly the coordinates read off by the inverse matrices: for each $i$
there are signs $(\varepsilon_i,\delta_i)\in\{\pm1\}^2$ with
$$B_i^{-1}(a,b,c) = (\varepsilon_i u,\ \delta_i v,\ w),$$
namely $(\varepsilon,\delta) = (+,-)$ for $B_1$, $(+,+)$ for $B_2$, $(-,+)$ for
$B_3$.

**Lemma 3.3 (the parent hypotenuse strictly decreases).** For a positive
Pythagorean triple, $0 < w < c$, where $w=3c-2a-2b$.

*Proof sketch.* $w<c$ is $2c < 2a+2b$, i.e. $c<a+b$, proved above. For $w>0$
we need $2(a+b) < 3c$; squaring, $4(a+b)^2 = 4(c^2+2ab) \le 8c^2 < 9c^2$
using $2ab \le a^2+b^2 = c^2$. $\square$

**Lemma 3.4 (sign dichotomy).** For a valid triple, $u$ and $v$ are not both
$\le 0$.

*Proof.* Suppose $u \le 0$, i.e. $a \le 2(c-b)$. Since $b<c$ the right-hand side
is positive, so squaring is legitimate: $c^2-b^2 = a^2 \le 4(c-b)^2$, and dividing
by $c-b>0$ gives $c+b \le 4(c-b)$, i.e. $5b \le 3c$. Symmetrically $v\le 0$ gives
$5a \le 3c$. If both held we would get
$$25c^2 = 25(a^2+b^2) \le 9c^2+9c^2 = 18c^2,$$
which is absurd for $c>0$. $\square$

**Lemma 3.5 (degenerate forms).** For a valid triple: $u \ne 0$; and $v=0$ if
and only if $(a,b,c) = (3,4,5)$.

*Proof sketch.* If $u=0$ then $a = 2(c-b)$ is even, contradicting $a$ odd. If
$v=0$ then $b = 2(c-a)$, and substituting into $a^2+b^2=c^2$ yields
$a^2 + 4(c-a)^2 = c^2$, i.e. $(5a-3c)(a-c) = 0$; since $a<c$ we get $5a=3c$, and
with $\gcd(a,b)=1$ this pins $(a,b,c)=(3,4,5)$. $\square$

**Lemma 3.6 (the parent is valid).** Let $(a,b,c)$ be valid and not the seed.
Choose the signs $\varepsilon = \operatorname{sgn}(u)$,
$\delta = \operatorname{sgn}(v)$; by Lemmas 3.4–3.5 at least one of $u,v$ is
positive, and one checks the pair $(\varepsilon,\delta)$ is one of the three
admissible patterns $(+,-),(+,+),(-,+)$. Then $p = (\varepsilon u, \delta v, w)$
is valid, and $\beta_i(p) = (a,b,c)$ for the corresponding index $i$.

*Proof sketch.* The Pythagorean identity $u^2+v^2=w^2$ is a polynomial identity
modulo $a^2+b^2=c^2$; positivity of $|u|,|v|,w$ follows from Lemmas 3.3–3.5;
primitivity transfers backwards because the matrices are unimodular; and
$\varepsilon u$ is odd because $u \equiv a \pmod 2$. Finally $B_i B_i^{-1} = I$
gives $\beta_i(p)=(a,b,c)$. $\square$

**Theorem 3.7 (completeness).** Every valid triple lies in $\mathcal T$.

*Proof.* Strong induction on $c$. If $(a,b,c)=(3,4,5)$ it is the seed. Else by
Lemma 3.6 it has a valid parent $p$ with hypotenuse $w<c$ (Lemma 3.3), which by
induction lies in $\mathcal T$; applying $\beta_i$ puts $(a,b,c)$ in $\mathcal T$.
$\square$

**Theorem 3.8 (Berggren's theorem, effective form).**
$$t \in \mathcal T \iff t \text{ is valid}.$$

### 3.3 Freeness

**Theorem 3.9 (freeness).** The word map $\rho:\{1,2,3\}^{*}\to\mathbb Z^3$ is
injective: distinct words produce distinct triples. Hence $\mathcal T$ is a free
ternary tree and every valid triple has a unique address.

*Proof sketch.* Two ingredients. (a) *No two distinct generators agree on valid
inputs:* the linear forms $u$ and $v$ of Definition 3.2 satisfy
$$u(\beta_1 t) = a,\quad u(\beta_2 t)=a,\quad u(\beta_3 t) = -a,$$
$$v(\beta_1 t) = -b,\quad v(\beta_2 t)=b,\quad v(\beta_3 t)=b,$$
so the sign pattern $(\operatorname{sgn} u, \operatorname{sgn} v)$ of the image
determines which generator was applied, provided $a,b>0$. Each $\beta_i$ is
individually injective (unimodular). (b) *The root is not a child:* for valid
$p$, every coordinate of $\beta_i(p)$ has hypotenuse $>5$, so
$\beta_i(p)\ne(3,4,5)$. Induction on word length finishes. $\square$

---

## 4. The upper bound

**Lemma 4.1 (two-square decomposition).** If $t=(a,b,c)$ is valid then there are
non-negative integers $M,N$ with
$$c+a = 2M^2, \qquad c-a = 2N^2 .$$

*Proof sketch.* By the classification of coprime Pythagorean triples there are
integers $m,n$ with $a = \pm(m^2-n^2)$, $b = \pm 2mn$, $c = \pm(m^2+n^2)$. As
$c>0$ we must have $c = m^2+n^2$; as $a$ is odd we must be in the branch
$a=m^2-n^2$ (the alternative $a = 2mn$ is even). Then $c+a = 2m^2$ and
$c-a=2n^2$, and $M=|m|$, $N=|n|$ work. $\square$

**Theorem 4.2 (sharp upper bound).** For every $H$,
$$\#\mathcal B(H) \le \bigl(\lfloor\sqrt H\rfloor+1\bigr)^2 .$$

*Proof.* Consider $\Phi(a,b,c) = (c+a,\ c-a)$.

*$\Phi$ is injective on $\mathcal B(H)$.* From $c+a$ and $c-a$ one recovers $a$
and $c$; then $b^2 = c^2-a^2$ and $b>0$ determine $b$.

*$\Phi$ lands in a small set.* By Lemma 4.1, $\Phi(t) = (2M^2, 2N^2)$. Since
$a \ge 1$ and $c \le H$ we get $2M^2 = c+a \le 2H$ (as $a<c\le H$) so $M^2 \le H$
and $M \le \lfloor\sqrt H\rfloor$; similarly $2N^2 = c-a \le 2H$ gives
$N \le \lfloor\sqrt H\rfloor$. Hence $\Phi(\mathcal B(H))$ is contained in the
image of $\{0,\dots,\lfloor\sqrt H\rfloor\}^2$ under $(M,N)\mapsto(2M^2,2N^2)$,
a set of at most $(\lfloor\sqrt H\rfloor+1)^2$ elements. $\square$

**Corollary 4.3 (linear upper bound).** For $H \ge 1$, $\#\mathcal B(H) \le 4H$.

*Proof.* Write $s=\lfloor\sqrt H\rfloor$, so $s \ge 1$ and $s^2 \le H$. Then
$(s+1)^2 = s^2+2s+1 \le s^2 + 2s^2 + s^2 = 4s^2 \le 4H$. $\square$

The bound $(\lfloor\sqrt H\rfloor+1)^2 \approx H$ is sharper than $4H$ and is
already within a factor $2\pi \approx 6.28$ of the truth.

---

## 5. The lower bound

### 5.1 An effective coprimality density

Let $S(X) = \{1,\dots,X\}^2$, $\mathrm{Cop}(X) = \{(n,m)\in S(X):\gcd(n,m)=1\}$.

**Lemma 5.1 (elementary sieve).** $\#\,(S(X)\setminus\mathrm{Cop}(X)) \le \sum_{g=2}^{X} \lfloor X/g\rfloor^2 .$

*Proof.* If $\gcd(n,m)=g>1$ then $(n,m) = g\cdot(n',m')$ with $1\le n',m'\le \lfloor X/g\rfloor$;
summing over the (not necessarily distinct) values of $g$ overcounts. $\square$

**Lemma 5.2 (tail estimate).** $\sum_{g\ge 2} 1/g^2 \le 25/36$.

*Proof sketch.* Take the terms $g=2,3$ exactly ($1/4+1/9 = 13/36$) and bound the
tail by telescoping: $\sum_{g\ge4} 1/g^2 \le \sum_{g \ge 4} \frac{1}{g(g-1)} = \frac13$.
Total $\le 13/36 + 12/36 = 25/36$. $\square$

**Proposition 5.3 (effective coprime density).** $11X^2 \le 36\,\#\mathrm{Cop}(X)$,
i.e. at least $11/36 = 0.3055\ldots$ of the pairs in $[1,X]^2$ are coprime.
(The truth is $6/\pi^2 = 0.6079\ldots$.)

*Proof.* Combine Lemmas 5.1 and 5.2: the number of non-coprime pairs is at most
$\tfrac{25}{36}X^2$, leaving at least $\tfrac{11}{36}X^2$ coprime ones. $\square$

**Proposition 5.4 (ordering and parity).** Let $\mathrm{Cop}^<(X)$ be the
coprime pairs with $n<m$ and $\mathrm{Cop}^{\ne}(X)$ those additionally of
opposite parity. Then
$$\#\mathrm{Cop}(X) \le 2\,\#\mathrm{Cop}^<(X) + 1, \qquad
\#\mathrm{Cop}^<(X) \le 2\,\#\mathrm{Cop}^{\ne}(X).$$
Consequently
$$11X^2 \le 144\,\#\mathrm{Cop}^{\ne}(X) + 36 .$$

*Proof sketch.* The first inequality is the involution $(n,m)\mapsto(m,n)$, whose
only fixed coprime point is $(1,1)$. For the second, if $n<m$ are coprime and
both odd, then $\bigl(\tfrac{m-n}{2}, \tfrac{m+n}{2}\bigr)$ is a coprime pair of
opposite parity with both entries $\le X$ and first $<$ second; this map is
injective, so the same-parity coprime pairs are at most as many as the
opposite-parity ones. $\square$

### 5.2 From pairs to triples

**Lemma 5.5 (Euclid's map produces valid triples).** If $1\le n<m$,
$\gcd(n,m)=1$ and $n+m$ is odd, then
$$E(n,m) := (m^2-n^2,\ 2mn,\ m^2+n^2)$$
is valid.

*Proof sketch.* Positivity is clear. The Pythagorean identity is the algebraic
identity $(m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2$. Primitivity follows from the
classification of coprime Pythagorean triples applied in the reverse direction,
using $\gcd(m,n)=1$ together with the opposite-parity hypothesis. Oddness of
$m^2-n^2$ is immediate from opposite parity. $\square$

**Theorem 5.6 (lower bound).** For $H \ge 5$, $H \le 100\,\#\mathcal B(H)$.

*Proof.* Set $X = \lfloor\sqrt{\lfloor H/2\rfloor}\rfloor$, so $X \ge 1$ for
$H\ge5$. If $(n,m)\in\mathrm{Cop}^{\ne}(X)$ then $m^2+n^2 \le 2X^2 \le H$, so by
Lemma 5.5 and Theorem 3.8 the triple $E(n,m)$ is a tree triple, and its
hypotenuse $m^2+n^2 \le H$ puts it in $\mathcal B(H)$ (Remark 2.5). The map $E$
is injective on such pairs, since $m^2+n^2$ and $m^2-n^2$ recover $m^2,n^2$ and
hence $m,n>0$. Therefore
$$\#\mathrm{Cop}^{\ne}(X) \le \#\mathcal B(H).$$
Now chain the estimates. By Proposition 5.4, $11X^2 \le 144\,\#\mathcal B(H)+36$.
By definition of $X$ we have $\lfloor H/2\rfloor < (X+1)^2 \le 4X^2$ (using
$X\ge1$), hence $H \le 2\lfloor H/2\rfloor+1 \le 8X^2 + 1$; and
$\#\mathcal B(H) \ge 1$ because $(3,4,5)\in\mathcal B(H)$ for $H\ge5$. Combining
these three facts gives $H \le 100\,\#\mathcal B(H)$. $\square$

The constant $100$ is not optimised; it results from the losses
$\tfrac{36}{11}$ (coprimality), $2$ (ordering), $2$ (parity), $2$ (the passage
from the square $[1,X]^2$ to the disc $m^2+n^2 \le H$), and rounding.

---

## 6. $\Theta(H)$ and vanishing density

**Theorem 6.1 (main counting theorem).** For all $H \ge 5$,
$$\frac{H}{100} \;\le\; \#\mathcal B(H) \;\le\; \min\Bigl(4H,\ \bigl(\lfloor\sqrt H\rfloor+1\bigr)^2\Bigr),$$
so $\#\mathcal B(H) = \Theta(H)$.

*Proof.* Theorem 5.6, Corollary 4.3 and Theorem 4.2. $\square$

**Corollary 6.2 (vanishing density in the box).**
$$\lim_{H\to\infty} \frac{\#\mathcal B(H)}{H^3} = 0 ,$$
indeed $\#\mathcal B(H)/H^3 \le 4/H$ for $H \ge 1$.

*Proof.* Immediate from $\#\mathcal B(H)\le 4H$ and $H^3 \ge H\cdot H\cdot H$; the
squeeze with $0 \le \#\mathcal B(H)/H^3 \le 4/H \to 0$ gives the limit. $\square$

Interpretation: choosing a lattice point uniformly at random from $[1,H]^3$, the
probability of landing on a Berggren triple is $O(1/H^2)$. In this sense the
tree is vanishingly thin in the box.

---

## 7. Exact comparison with the primitive Pythagorean triples

**Lemma 7.1 (parity of a primitive triple).** In a primitive Pythagorean triple
$(a,b,c)$, exactly one of $a,b$ is odd, and $c$ is odd.

*Proof.* Both legs even is excluded by $\gcd(a,b)=1$. If both are odd, write
$a = 2k+1$, $b=2\ell+1$; then $c^2 = a^2+b^2 = 4(k^2+k+\ell^2+\ell)+2 \equiv 2 \pmod 4$.
But squares are $0$ or $1$ mod $4$: contradiction. Hence exactly one leg is odd,
and then $c^2 \equiv 1 \pmod 2$, so $c$ is odd. $\square$

**Theorem 7.2 (the tree is exactly the odd-first-leg primitive triples of the box).**
$$\mathcal B(H) = \mathcal P^{\mathrm{odd}}(H).$$

*Proof.* $\subseteq$: a tree triple is valid (Theorem 3.2), hence primitive,
positive, Pythagorean and odd-first-legged, and it lies in the box by
hypothesis. $\supseteq$: a member of $\mathcal P^{\mathrm{odd}}(H)$ is precisely
a valid triple in the box, hence reachable by Theorem 3.7. $\square$

**Theorem 7.3 (the factor two).** For every $H$,
$$\#\mathcal P(H) = 2\,\#\mathcal B(H).$$

*Proof.* Split $\mathcal P(H)$ by the parity of its first coordinate:
$$\#\mathcal P(H) = \#\mathcal P^{\mathrm{odd}}(H) + \#\mathcal P^{\mathrm{even}}(H).$$
The leg swap $\sigma(a,b,c) = (b,a,c)$ maps $\mathcal P(H)$ to itself (the
Pythagorean identity is symmetric in $a,b$; $\gcd$ is symmetric; the box is
symmetric in the first two coordinates), is an involution, and by Lemma 7.1 it
exchanges $\mathcal P^{\mathrm{odd}}(H)$ and $\mathcal P^{\mathrm{even}}(H)$: if
$a$ is odd then $b$ is even, and vice versa. Hence the two halves have equal
cardinality, and $\#\mathcal P(H) = 2\,\#\mathcal P^{\mathrm{odd}}(H) = 2\,\#\mathcal B(H)$
by Theorem 7.2. $\square$

**Corollary 7.4 (completeness in the box, up to a swap).** For every
$t = (a,b,c) \in \mathcal P(H)$, either $t \in \mathcal B(H)$ or
$(b,a,c) \in \mathcal B(H)$.

*Proof.* By Lemma 7.1 one of $a,b$ is odd; put the odd one first and apply
Theorem 7.2. $\square$

**Remark 7.5.** Corollary 7.4 is the sharp form of the heuristic that the tree
captures a $(1-o(1))$ proportion of the primitive triples of the box. The
proportion is exactly $1$: viewed as a set of right *triangles* — with the two
legs unordered — the Berggren tree restricted to the box is literally the set of
all primitive Pythagorean triangles with hypotenuse at most $H$. There is no
error term to estimate.

---

## 8. The visible-point bijection and the constant $1/(2\pi)$

### 8.1 The bijection

**Theorem 8.1.** The Euclid map $E(n,m) = (m^2-n^2, 2mn, m^2+n^2)$ is a bijection
$$E : \mathcal Q(H) \;\xrightarrow{\ \sim\ }\; \mathcal B(H),$$
so $\#\mathcal B(H) = \#\mathcal Q(H)$ and, by Theorem 7.3,
$\#\mathcal P(H) = 2\,\#\mathcal Q(H)$.

*Proof sketch.* *Well-defined:* Lemma 5.5 plus $m^2+n^2 \le H$ and Remark 2.5.
*Injective:* $m^2 = \tfrac12\bigl((m^2+n^2)+(m^2-n^2)\bigr)$ and
$n^2 = \tfrac12\bigl((m^2+n^2)-(m^2-n^2)\bigr)$ recover $m,n$ from the image.
*Surjective:* given $t\in\mathcal B(H)$, Lemma 4.1 supplies $M,N \ge 0$ with
$c+a=2M^2$, $c-a=2N^2$; then $c = M^2+N^2 \le H$, $a = M^2-N^2 > 0$ so $N<M$,
$b^2 = c^2-a^2 = (2MN)^2$ so $b = 2MN$ and $N \ge 1$; coprimality of $a$ and $b$
forces $\gcd(N,M)=1$, and oddness of $a=M^2-N^2$ forces $N+M$ odd. Hence
$(N,M) \in \mathcal Q(H)$ and $E(N,M) = t$. $\square$

**Corollary 8.2 (transported bounds).** For $H \ge 5$,
$$H \le 100\,\#\mathcal Q(H), \qquad \#\mathcal Q(H) \le \bigl(\lfloor\sqrt H\rfloor+1\bigr)^2 .$$

Theorem 8.1 is the conceptual heart of the counting: it converts a question
about a three-dimensional orbit of a matrix semigroup into a question about
**visible lattice points** — points $(n,m)$ with $\gcd(n,m)=1$, i.e. points seen
from the origin with no other lattice point in between — inside the circular
wedge

$$W_H = \{(x,y) : 0 < x < y,\ x^2+y^2 \le H\},$$

subject to a parity condition.

### 8.2 The predicted constant

The wedge $W_H$ is an eighth of a disc of radius $\sqrt H$ and has area
$\tfrac{\pi H}{8}$. Three independent densities act on the lattice points inside
it:

1. **Area.** $\#\{(n,m) \in \mathbb Z^2 \cap W_H\} = \tfrac{\pi H}{8} + O(\sqrt H)$
   by the Gauss circle argument.
2. **Visibility.** The density of coprime pairs among all pairs is
   $1/\zeta(2) = 6/\pi^2$, by Möbius inversion:
   $\#\mathrm{Cop} = \sum_{d} \mu(d)\,\#\{\text{pairs both divisible by }d\}$.
3. **Parity.** Among coprime pairs, the three residue classes
   $(\text{odd},\text{odd})$, $(\text{odd},\text{even})$,
   $(\text{even},\text{odd})$ are equidistributed, so exactly $2/3$ of coprime
   pairs have opposite parity. (Formally: the local factor at the prime $2$ in
   the Möbius sieve contributes $\tfrac{2/4}{3/4} = \tfrac23$.)

Multiplying,

$$\#\mathcal Q(H) \;\sim\; \frac{\pi H}{8}\cdot\frac{6}{\pi^2}\cdot\frac{2}{3} \;=\; \frac{H}{2\pi} .$$

**Conjecture 8.3 (Lehmer-type constant for the Berggren box).**
$$\#\mathcal B(H) = \frac{H}{2\pi} + O\!\left(\sqrt H \log H\right),$$
in particular $\#\mathcal B(H)/H \to 1/(2\pi) = 0.1591549\ldots$

Computation supports this strongly: at $H = 4\cdot10^5$ one finds
$\#\mathcal B(H) = 63\,669$ and $\#\mathcal B(H)/H = 0.159172$, against
$1/(2\pi) = 0.159155$; the observed discrepancy is consistent with an error term
of size $O(\sqrt H)$ (see Section 11).

Note how the proved bounds bracket this: $1/100 \le \#\mathcal B(H)/H \le 1$,
while the truth is $\approx 0.159$. The upper bound
$(\lfloor\sqrt H\rfloor+1)^2 \approx H$ is off by exactly the factor $2\pi$,
which is precisely the geometric content the crude two-square argument throws
away.

---

## 9. Growth geometry of the generators

The three matrices have very different dynamical characters, and this dictates
the shape of the tree.

### 9.1 The hyperbolic generator $B_2$

**Theorem 9.1.** If $t=(a,b,c)$ is valid then $(\beta_2 t)_3 > 5c$; hence
along the pure-$B_2$ branch, $(\beta_2^{\,k} t)_3 \ge 5^k c$.

*Proof.* $(\beta_2 t)_3 = 2a+2b+3c$ and $a+b>c$, so $(\beta_2 t)_3 > 2c+3c = 5c$.
Iterate. $\square$

The exact expansion factor is the largest eigenvalue of $B_2$, the silver-ratio
square $3+2\sqrt 2 = 5.8284\ldots$. Starting from $(3,4,5)$ the pure-$B_2$
branch has hypotenuses
$$5,\ 29,\ 169,\ 985,\ 5741,\ 33461,\ 195025,\ \ldots$$
(alternate Pell numbers, whose triples $(3,4,5),(21,20,29),(119,120,169),\ldots$
are exactly the primitive triples whose legs differ by one).

### 9.2 The parabolic generator $B_3$

$B_3$ is unipotent: its characteristic polynomial is $(\lambda-1)^3$.

**Lemma 9.2 (invariant).** $(\beta_3 t)_3 - (\beta_3 t)_1 = c - a$ for every $t$.

*Proof.* $(-2a+2b+3c) - (-a+2b+2c) = c-a$. $\square$

**Theorem 9.3 (closed form for the parabolic orbit).** For every $k\ge0$ and
every $t=(a,b,c)$,
$$\beta_3^{\,k}(t) = \Bigl(a + k\,\gamma + 2k(k-1)(c-a),\ \ b + 2k(c-a),\ \ c + k\,\gamma + 2k(k-1)(c-a)\Bigr),$$
where $\gamma = -2a+2b+2c$.

*Proof.* Induction on $k$, expanding one application of $\beta_3$. $\square$

Thus the hypotenuse grows *quadratically*, not exponentially, along a $B_3$
orbit: $(\beta_3^{\,k}t)_3 = c + k\gamma + 2k(k-1)(c-a)$. From the seed this is
the beautifully explicit *parabolic spine*

$$\beta_3^{\,k}(3,4,5) = \bigl(4(k+1)^2-1,\ \ 4(k+1),\ \ 4(k+1)^2+1\bigr),$$

giving $(3,4,5), (15,8,17), (35,12,37), (63,16,65), (99,20,101), \ldots$ — the
family of triples with $c-a=2$.

**Theorem 9.4 (seed-independent depth bound).** Let $t$ be any valid triple with
hypotenuse $c$, and let $K$ satisfy $7K^2c \le H$. Then the parabolic orbit
$\{t, \beta_3 t, \dots, \beta_3^{K-1}t\}$ consists of $K$ distinct valid triples,
all inside the box $[1,H]^3$.

*Proof sketch.* Distinctness: the hypotenuse is strictly increasing along the
orbit (Theorem 9.3 with $\gamma>0$ and $c>a$). Boundedness: crude estimates
$\gamma \le 4c$ and $c-a \le c$ in Theorem 9.3 give
$(\beta_3^{\,k}t)_3 \le 7(k+1)^2c$, so $k<K$ implies the hypotenuse is at most
$7K^2c \le H$. $\square$

**Corollary 9.5.** Taking $t=(3,4,5)$: the tree inside the box $[1,H]^3$ contains
a path of length $\gg \sqrt H$. Combined with the general bound below, the tree
is extremely unbalanced.

### 9.3 A uniform depth bound

**Theorem 9.6.** For any word $w$ of length $d$, the triple $\rho(w)$ has
hypotenuse at most $5\cdot 6^{d}$. Equivalently, a triple with hypotenuse $c$
sits at depth at least $\log_6(c/5)$.

*Proof sketch.* For a valid triple, $2(a+b) \le 3c$ (Lemma 3.3), so each
generator's third coordinate $\pm2a\pm2b+3c \le 2(a+b)+3c \le 6c$. Iterate from
the seed's hypotenuse $5$. $\square$

So depths in the box range from $\Theta(\log H)$ (the generic, exponentially
branching bulk) to $\Omega(\sqrt H)$ (the parabolic whiskers). Empirically at
$H=10^5$ the tree contains $15\,919$ nodes with mean depth $15.4 \approx
1.34\log H$ and maximum depth $222 \approx 0.70\sqrt H$.

---

## 10. Algorithms

### 10.1 Enumerating the box via the tree

By Remark 2.5, membership in the box is the single condition $c \le H$, and by
Theorem 9.1 (and its analogues for $\beta_1,\beta_3$) every generator strictly
increases the hypotenuse. Hence a depth-first search from $(3,4,5)$, pruning any
node with $c>H$, enumerates $\mathcal B(H)$ exactly once each. Cost:
$O(\#\mathcal B(H)) = O(H)$ arithmetic operations and $O(\text{depth})$ space —
optimal up to constants, and with no duplicate detection needed, by freeness
(Theorem 3.9).

### 10.2 Enumerating the box via the parameter wedge

By Theorem 8.1 one may instead iterate over $2 \le m \le \lfloor\sqrt H\rfloor$
and $1 \le n < m$ with $m^2+n^2 \le H$, keeping the pairs with $\gcd(n,m)=1$ and
$n+m$ odd. Cost $O(H)$ pairs examined with $O(\log H)$ per gcd, i.e.
$O(H\log H)$; slightly slower than the tree walk but requiring no matrix
algebra, and it is the form in which the Möbius sieve of Section 8 applies.

### 10.3 Address of a triple (descent)

Given a valid triple, iterate: if $t = (3,4,5)$, stop; else compute
$u,v,w$, read the generator index from $(\operatorname{sgn}u,\operatorname{sgn}v)$,
and replace $t$ by $(|u|,|v|,w)$. The hypotenuse strictly decreases, and by
Theorem 9.6 the number of steps is at most $\log_6(c/5)$ for the generic branch
and at most $O(\sqrt c)$ in the worst (parabolic) case. This computes the unique
word $w$ with $\rho(w)=t$.

### 10.4 Sieved counting

To compute $\#\mathcal Q(H)$ for large $H$ without enumerating pairs, apply
Möbius inversion over the visibility condition:
$$\#\mathcal Q(H) = \sum_{\substack{d \ge 1 \\ d \text{ odd}}} \mu(d)\;\#\{(n,m): 0<n<m,\ n+m \text{ odd},\ d\mid n,\ d\mid m,\ m^2+n^2\le H\},$$
where only odd $d$ contribute because $d$ even would force $n,m$ both even,
violating the parity condition. Each inner count is a wedge lattice count of
radius $\sqrt H / d$, computable in $O(\sqrt H/d)$ time by summing over columns.
Total cost $O(\sqrt H \log H)$ — a genuine speedup over $O(H)$ enumeration, and
exactly the decomposition that Conjecture 8.3 seeks to make rigorous.

---

## 11. Numerical evidence

Direct enumeration gives:

| $H$ | $\#\mathcal B(H)$ | $H/100$ | $4H$ | $(\lfloor\sqrt H\rfloor+1)^2$ | $\#\mathcal P(H)$ | $\#\mathcal Q(H)$ | $\#\mathcal B(H)/H$ |
|---|---|---|---|---|---|---|---|
| $5$ | $1$ | $0.05$ | $20$ | $9$ | $2$ | $1$ | $0.2000$ |
| $50$ | $7$ | $0.5$ | $200$ | $64$ | $14$ | $7$ | $0.1400$ |
| $100$ | $16$ | $1$ | $400$ | $121$ | $32$ | $16$ | $0.1600$ |
| $1\,000$ | $158$ | $10$ | $4\,000$ | $1\,024$ | $316$ | $158$ | $0.1580$ |
| $5\,000$ | $792$ | $50$ | $20\,000$ | $5\,041$ | $1\,584$ | $792$ | $0.1584$ |
| $20\,000$ | $3\,186$ | $200$ | $80\,000$ | $20\,164$ | $6\,372$ | $3\,186$ | $0.1593$ |
| $100\,000$ | $15\,919$ | $1\,000$ | $400\,000$ | $100\,489$ | $31\,838$ | $15\,919$ | $0.15919$ |
| $400\,000$ | $63\,669$ | $4\,000$ | $1\,600\,000$ | $400\,689$ | $127\,338$ | $63\,669$ | $0.159172$ |

A sublinear Möbius-sieved computation (Section 10.4) extends the last column
much further: at $H = 10^7$ one gets $\#\mathcal B(H) = 1\,591\,579$ against
$H/(2\pi) = 1\,591\,549.43$, and at $H = 10^9$ one gets
$\#\mathcal B(H) = 159\,154\,994$ against $H/(2\pi) = 159\,154\,943.09$ — an
absolute error of $51$, i.e. $0.0016\sqrt H$.

Every row confirms the proved bounds, the identity $\#\mathcal P = 2\#\mathcal B$
of Theorem 7.3, and the bijection $\#\mathcal B = \#\mathcal Q$ of Theorem 8.1.
The last column converges to $1/(2\pi) = 0.1591549$; the normalised errors
$\bigl(\#\mathcal B(H)/H - 1/(2\pi)\bigr)\sqrt H$ stay bounded in $[-0.04, 0.02]$
across $H \in [1.2\cdot10^4, 4\cdot 10^5]$, consistent with an $O(\sqrt H)$ error
term in Conjecture 8.3.

Also verified computationally: every node with hypotenuse $\le 2000$ is a
primitive Pythagorean triple with odd first leg (Theorem 3.2); at $H=300$ there
are $94$ ordered primitive triples, $47$ tree triples, and $0$ exceptions to
Corollary 7.4; the parabolic spine matches the closed form
$c_k = 4(k+1)^2+1$; and the hyperbolic branch ratios approach $5.8284$.

---

## 12. Discussion

### 12.1 Three answers to one question

"How common are Pythagorean triples?" admits three sharp answers, all proved
above and all different:

- **In the box $[1,H]^3$:** a proportion $O(1/H^2)$ — vanishingly rare
  (Corollary 6.2).
- **Per unit of height:** exactly $\Theta(H)$ triples, with a conjectural
  density $1/(2\pi)$ per unit (Theorem 6.1, Conjecture 8.3).
- **Among primitive Pythagorean triples:** all of them, exactly, up to a leg
  swap (Corollary 7.4). The proportion is not $1-o(1)$ but exactly $1$.

The apparent tension dissolves once one notices that these compare the tree
against three different ambient sets: the $H^3$ points of the cube, the $H$ scale
of the hypotenuse, and the primitive triples themselves.

### 12.2 Where the constants are lost

The proof of Theorem 6.1 loses a factor $\approx 628$ between the two sides
($1/100$ vs $\approx 1$) while the truth sits at $0.159$. Tracing the losses:
the upper bound $(\lfloor\sqrt H\rfloor+1)^2$ throws away the *shape* of the
constraint region — it bounds the wedge $\{0<n<m,\ m^2+n^2\le H\}$ by the full
square $[0,\sqrt H]^2$, a loss of exactly $8/\pi$ — and it also ignores the
coprimality ($\pi^2/6$) and parity ($3/2$) conditions. Their product is
$\tfrac{8}{\pi}\cdot\tfrac{\pi^2}{6}\cdot\tfrac32 = 2\pi$, exactly the observed
discrepancy. On the lower side, the losses are the elementary sieve
($\tfrac{36}{11}$ instead of $\tfrac{\pi^2}{6}$), the two symmetry factors, and
the square-versus-disc inscription.

### 12.3 Relation to classical results

The visible-point count of Theorem 8.1 places this problem in the same family as
Lehmer's theorem on the number of coprime pairs in a region and the Gauss circle
problem. The novelty here is not the analytic content but the exactness of the
reduction: the tree count is *equal*, not merely asymptotic, to the wedge count,
and the equality is available for every $H$, with no error term.

### 12.4 Open problems

1. **Prove Conjecture 8.3.** The bijection is exact; what remains is a Möbius-weighted
   Gauss circle estimate for the wedge. The main term is straightforward; the
   error term requires uniform control of the lattice-point discrepancy for
   discs of radius $\sqrt H/d$ summed against $\mu(d)$.
2. **Sharpen the effective constants.** Replacing the crude sieve of
   Proposition 5.3 with an effective Möbius argument should push the proved
   interval from $[1/100, 1]$ to something like $[0.14, 0.18]$.
3. **The depth profile.** Prove that the maximal depth $D(H)$ of the tree inside
   the box satisfies $D(H) \asymp \sqrt H$ (the lower bound is Theorem 9.4; the
   upper bound requires ruling out mixed words that grow more slowly than the
   pure parabolic spine), and that the *typical* depth is $\Theta(\log H)$.
4. **Other seeds and other trees.** The three matrices generate a free semigroup;
   which other unimodular triples of matrices give free covering trees of a
   Diophantine set, and does the $\Theta(H)$-with-computable-constant phenomenon
   persist?
5. **Counting by hypotenuse vs by perimeter or area.** The wedge changes shape —
   for perimeter $2m(m+n)\le P$ one counts inside a hyperbola-bounded region
   instead of a disc — and the analogous constant becomes an integral over that
   region; making these effective is a bounded and attractive target.
6. **Higher-dimensional analogues.** Quaternion or Lipschitz-integer trees
   generating primitive quadruples $a^2+b^2+c^2=d^2$ admit similar matrix
   descriptions; the corresponding box counts should be $\Theta(H^2)$ with an
   explicit constant coming from a spherical shell rather than a circular wedge.

---

## 13. Summary of results

- **Structure.** The Berggren tree rooted at $(3,4,5)$ equals the set of positive
  primitive Pythagorean triples with odd first leg, and is a free ternary tree.
- **Upper bound.** $\#\mathcal B(H) \le (\lfloor\sqrt H\rfloor+1)^2 \le 4H$.
- **Lower bound.** $H \le 100\,\#\mathcal B(H)$ for $H\ge5$.
- **Order of growth.** $\#\mathcal B(H)=\Theta(H)$ and $\#\mathcal B(H)/H^3\to0$.
- **Exact comparison.** $\#\mathcal P(H) = 2\,\#\mathcal B(H)$, and every primitive
  Pythagorean triple of the box lies in the tree up to swapping the legs.
- **Reduction.** $\#\mathcal B(H) = \#\mathcal Q(H)$, a visible-point count in a
  circular wedge, whence the conjectural constant $1/(2\pi)$.
- **Geometry.** $B_2$ expands the hypotenuse by $3+2\sqrt2$; $B_3$ is unipotent
  with quadratic orbit growth $c_k = 4(k+1)^2+1$ from the seed, forcing depth
  $\Omega(\sqrt H)$ inside the box while the generic depth is $\Theta(\log H)$.
