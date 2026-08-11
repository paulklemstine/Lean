# Deep Holes of Binary Lattices: the Exact Covering Radius, the Covering Weight Enumerator, and the Sharp Packing–Covering Inequality in Rank Two

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Let $Q(x,y) = ax^2 + bxy + cy^2$ be a positive-definite rational quadratic form on the lattice
$L = \mathbb{Z}^2$. Two invariants govern its geometry: the homogeneous minimum
$\lambda_1(Q) = \min\{Q(m) : m \in L \setminus \{0\}\}$ (the packing datum) and the covering
radius squared $\mu(Q) = \max_{t \in \mathbb{Q}^2} \min_{m \in L} Q(t-m)$ (the covering datum).
We determine $\mu$ exactly. Writing the form in a reduced basis, $0 \le b \le a \le c$, so that
$a = \lambda_1$, and writing $D = 4ac - b^2$ for the discriminant, we prove

$$\mu(Q) \;=\; \frac{a\,c\,(a-b+c)}{4ac-b^2},$$

attained at the circumcentre $h = \big(c(2a-b)/D,\; a(2c-b)/D\big)$ of the Delaunay triangle with
vertices $0, e_1, e_2$, and at no point further away. Five consequences follow. (i) A
quantitative strictness identity $\mu - \lambda_1/4 = a(2c-b)^2/\big(4(4ac-b^2)\big) > 0$,
proving that the classical inequality $\mu \ge \lambda_1/4$ is strict in every rank $\ge 2$ case
in the plane, with rank one the unique equality case. (ii) The **sharp** planar packing–covering
inequality $\mu \ge \lambda_1/3$, with equality exactly for the hexagonal form
$a(x^2+xy+y^2)$. (iii) A half-lattice point is a deepest hole if and only if the lattice is
rectangular ($b=0$). (iv) The universal ceiling $\mu \le (a+c)/2$, with $\mu(\mathbb{Z}^2)=1/2$
and $\mu(A_2) = 1/3$. (v) A complete determination of the **covering weight enumerator**
$W(Q) = \{4\mu(v/2) : v \in L/2L\}$, the multiset of coset minima on the four classes of $L/2L$:
$W(Q) = \{0,\,a,\,c,\,a+c-|b|\}$; its smallest nonzero entry is $\lambda_1$, and $W$ determines
$(a,|b|,c)$, so in rank two the covering weight enumerator is a *complete* isometry invariant. In
particular, any pair of distinct lattices with identical coset-minimum data must have rank at
least three.

**Keywords:** binary quadratic form, covering radius, deep hole, inhomogeneous minimum, Delaunay
triangle, packing–covering inequality, hexagonal lattice, weight enumerator, reduction theory.

---

## 1. Introduction

### 1.1 Two radii

A lattice $L$ in Euclidean space carries two elementary metric invariants of opposite character.
The **packing radius** is half the distance between the two closest lattice points; the
**covering radius** is the largest distance from an arbitrary point of the ambient space to the
lattice. Equivalently, the packing radius is the largest $r$ such that open balls of radius $r$
centred at lattice points are disjoint, and the covering radius is the smallest $R$ such that
closed balls of radius $R$ centred at lattice points cover space.

The packing radius is a minimum over a discrete set; it is computed by a finite search, and its
theory — Minkowski's theorem, reduction theory, the classification of extreme forms — is
classical. The covering radius is a *maximum of a minimum* over a continuum. The extra
quantifier makes it substantially harder: a candidate deep hole must be certified against all
infinitely many lattice points at once, and the maximisation is over a continuous family of
candidates. Exact covering radii are known in few families.

This paper settles the planar case completely and in closed form.

### 1.2 Physical and computational significance

The covering radius is the natural mathematical model of an **interstitial site**: in a crystal,
the deepest hole is the position an impurity or an intercalated ion occupies, and $\mu$ measures
how large such a guest can be before it strains the host. It is also the **worst-case
distortion** of a lattice vector quantiser, the device that encodes a continuous signal by its
nearest lattice point; and the ratio $\mu/\lambda_1$ is the standard figure of merit comparing
the covering economy of a lattice with its packing density. Our sharp inequality
$\mu \ge \lambda_1/3$, with rigidity at the hexagonal lattice, is precisely the statement that the
honeycomb is simultaneously optimal for planar packing and for planar covering.

### 1.3 Results

Throughout, $L = \mathbb{Z}^2$ and $Q$ is a positive-definite rational binary quadratic form.

- **Theorem A (four coset minima).** For a reduced form the covering weight enumerator is
  $W(Q) = \{0, a, c, a+c-|b|\}$, realised by the four classes of $L/2L$ in the order
  $(0,0), (1,0), (0,1), (1,1)$; every half-point gap of the lattice occurs among these values.
- **Theorem B (completeness).** $W$ determines $(a,|b|,c)$; two reduced binary forms with the
  same enumerator agree after the coordinate flip $y \mapsto -y$. In rank two, $W$ is a complete
  isometry invariant, and its least nonzero entry is $\lambda_1$.
- **Theorem C (strictness).** Every positive-definite binary form satisfies $\mu > \lambda_1/4$.
- **Theorem D (exact covering radius).** For a reduced form,
  $\mu = ac(a-b+c)/(4ac-b^2)$, attained at the circumcentre of a Delaunay triangle.
- **Theorem E (sharp constant).** $\mu \ge \lambda_1/3$, with equality exactly for
  $a(x^2+xy+y^2)$.

Theorem C is logically subsumed by Theorem D but is stated separately: its proof is a
*certificate* argument, independent of the exact formula, and it isolates the hexagonal lattice as
the unique obstruction to the natural two-torsion certificate.

### 1.4 Method

All statements are reduced to elementary algebra in the coefficient triple $(a,b,c)$ using two
devices. First, a **reduction theorem** (Section 3) proving from scratch that every
positive-definite binary form has a basis with $0 \le b \le a \le c$ and $a = \lambda_1$; the
proof shows a minimal vector is primitive, completes it to a basis by Bézout, and applies one
shear. Second, a **translation identity** (Section 5) showing that recentring the form at the
candidate deep hole converts it into $Q(x,y) - ax - cy + \mu$, so the two bounds become,
respectively, an integer inequality and a concavity statement.

---

## 2. Definitions

Throughout, $L = \mathbb{Z}^2$ and coordinates are taken with respect to a fixed basis; a
quadratic form is written both as a symmetric matrix $B$ with $Q(x) = x^{\mathsf T} B x$ and in
coefficients, $Q(x,y) = ax^2 + bxy + cy^2$ with $a = B_{11}$, $b = B_{12} + B_{21}$, $c = B_{22}$.

**Definition 2.1 (positive definiteness).** $Q$ is *positive definite* if $Q(x) > 0$ for every
nonzero $x \in \mathbb{Q}^2$.

**Definition 2.2 (homogeneous minimum).** $\lambda_1(Q) = \min \{ Q(m) : m \in L,\, m \neq 0\}$,
the least energy of a nonzero lattice vector. (For a rational positive-definite form the minimum
is attained: values lie in a discrete set and $Q(m) \to \infty$.)

**Definition 2.3 (gap, or inhomogeneous minimum at a shift).** For $t \in \mathbb{Q}^2$ set
$$\mu(t) \;=\; \min_{m \in L} Q(t - m),$$
the squared distance from $t$ to the lattice. We say $t$ *has gap* $\gamma$ when $\mu(t) =
\gamma$; equivalently, $Q(t-m) \ge \gamma$ for all $m \in L$ with equality for at least one $m$.
The function $t \mapsto \mu(t)$ is $L$-periodic.

**Definition 2.4 (covering radius squared).** $\mu(Q) = \sup_{t} \mu(t)$. A point attaining the
supremum is a *deep hole*. Equivalently, $\mu(Q)$ is the least $\gamma$ such that every point of
the plane lies within squared distance $\gamma$ of $L$.

**Definition 2.5 (reduced form).** $(a,b,c)$ is *reduced* if $0 < a$ and $|b| \le a \le c$; it is
*normalised reduced* if moreover $0 \le b$. Since $y \mapsto -y$ is an isometry of $L$ changing
$b$ to $-b$, normalisation is harmless.

**Definition 2.6 (discriminant).** $D = 4ac - b^2 = 4\det B$. For a reduced form, $D \ge 4a^2 -
a^2 = 3a^2 > 0$.

**Definition 2.7 (half-points and $2$-torsion shifts).** For $v \in L$, the *half-point* is
$v/2$. Its gap depends only on the class of $v$ in $L/2L$, a group of order $4$ with
representatives $(0,0), (1,0), (0,1), (1,1)$, since translating $v$ by $2L$ translates $v/2$ by
$L$. Moreover $\mu(v/2) = \tfrac14 \min\{Q(u) : u \equiv v \bmod 2L\}$: the *coset minimum*,
scaled.

**Definition 2.8 (covering weight enumerator).**
$$W(Q) \;=\; \big\{\, 4\,\mu(v/2) \;:\; v \in L/2L \,\big\}
        \;=\; \big\{\, \min\{Q(u) : u \equiv v \bmod 2L\} \;:\; v \in L/2L \,\big\},$$
a multiset of four rationals. For $Q = x^2 + y^2$ it is $\{0,1,1,2\}$, the Hamming weight
enumerator of $\mathbb{F}_2^2$; the general case is a *weighted* analogue.

**Definition 2.9 (Delaunay triangle).** A triangle with lattice-point vertices is *Delaunay* if
its circumscribed circle contains no lattice point in its interior. For a normalised reduced
basis $(v,w)$ the triangle $\{0, v, w\}$ is Delaunay, and the fundamental parallelogram is the
union of $\{0,v,w\}$ and its point reflection, glued along the short diagonal $[v,w]$ of squared
length $a - b + c$.

---

## 3. Reduction theory

The statements below all take place in a reduced basis, so the first task is to produce one, with
the additional property that the first coefficient is the homogeneous minimum. We include the
argument because it is short and because it is what makes every later theorem apply to an
arbitrary lattice rather than to a normal form.

**Lemma 3.1 (minimal vectors are primitive).** If $Q(v) = \lambda_1$ with $v \neq 0$ then
$\gcd(v_0,v_1) = 1$.

*Proof.* If $v = k u$ with $|k| \ge 2$ and $u \in L \setminus \{0\}$ then $Q(v) = k^2 Q(u) \ge 4
Q(u) > Q(u) \ge \lambda_1$, contradicting minimality. $\square$

**Lemma 3.2 (change of basis in coefficients).** In the basis $(v, w)$ the form has coefficients
$$\big(Q(v),\; \beta(v,w),\; Q(w)\big), \qquad
\beta(v,w) = 2a v_0 w_0 + b (v_0 w_1 + v_1 w_0) + 2 c v_1 w_1,$$
i.e. $Q(xv + yw) = Q(v) x^2 + \beta(v,w) xy + Q(w) y^2$. A shear $w \mapsto w + kv$ changes the
middle coefficient by $2k\,Q(v)$ and leaves $Q(v)$ fixed.

*Proof.* Direct expansion. $\square$

**Theorem 3.3 (existence of a reduced basis).** Let $Q$ be positive definite with homogeneous
minimum $\lambda_1$ attained at $v$. Then there is $w \in L$ with $\det(v,w) = 1$,
$|\beta(v,w)| \le \lambda_1$ and $Q(w) \ge \lambda_1$. Consequently, after possibly flipping the
sign of $w$, the form reads $\lambda_1 x^2 + b xy + c y^2$ with $0 \le b \le \lambda_1 \le c$.

*Proof sketch.* By Lemma 3.1 the vector $v$ is primitive, so Bézout supplies $w'$ with
$\det(v,w')=1$. By Lemma 3.2 the shear $w = w' + kv$ changes $\beta$ by $2k\lambda_1$; choosing
$k$ to be the nearest integer to $-\beta(v,w')/(2\lambda_1)$ gives $|\beta(v,w)| \le \lambda_1$.
Since $\{v, w\}$ is a basis, $w \neq 0$ and $Q(w) \ge \lambda_1$ by minimality. Finally replace
$w$ by $-w$ if $\beta < 0$; this negates $b$ and changes nothing else. $\square$

In a reduced basis, $\lambda_1 = a$: the minimum is attained at $e_1$ and, by the estimate of
Lemma 4.1 below, no other integer point does better.

---

## 4. The covering weight enumerator

### 4.1 The basic estimate

**Lemma 4.1.** If $|b| \le a$ then for all rationals $x,y$,
$$Q(x,y) \;\ge\; a\big(x^2 - |x||y|\big) + c\,y^2 .$$
Consequently, if also $a \le c$, then $Q(p,q) \ge a$ for every nonzero integer pair, so
$\lambda_1 = a$.

*Proof.* $bxy \ge -|b||x||y| \ge -a|x||y|$ because $|b| \le a$ and $|x||y| \ge 0$. For the
consequence, $x^2 - |x||y| + y^2 \ge 1$ for integers not both zero (it equals
$(|x|-|y|)^2 + |x||y|$, and if both are nonzero this is $\ge 1$; if one vanishes the other
contributes $\ge 1$), and $c \ge a$ absorbs the difference. $\square$

### 4.2 The four coset minima

**Theorem 4.2 (Theorem A).** Let $(a,b,c)$ be reduced, $0 < a$, $|b| \le a \le c$. Then:

1. the class $(0,0)$ has coset minimum $0$;
2. the class $(1,0)$ (i.e. $X$ odd, $Y$ even) has coset minimum $a$;
3. the class $(0,1)$ has coset minimum $c$;
4. the class $(1,1)$ has coset minimum $a + c - |b|$.

Equivalently, the half-point $v/2$ has gap $0$, $a/4$, $c/4$, $(a+c-|b|)/4$ respectively, and
$W(Q) = \{0, a, c, a+c-|b|\}$.

*Proof sketch.* Attainment is immediate: take $(0,0)$, $(1,0)$, $(0,1)$ and the sign pattern of
$(1,\pm 1)$ minimising $a \pm b + c$, which yields $a + c - |b|$. For the lower bounds, apply
Lemma 4.1.

(2) $X$ odd, $Y$ even. If $Y = 0$ then $Q \ge aX^2 \ge a$. Otherwise $|Y| \ge 2$ and $|X| \ge 1$;
Lemma 4.1 with $c \ge a$ gives
$Q \ge a\big(X^2 - |X||Y|\big) + cY^2 \ge a\big(X^2 - |X||Y| + Y^2\big) \ge a$, using
$X^2 - |X||Y| + Y^2 - 1 = (|X|-|Y|)^2 + (|X|-1)(|Y|-1) + |X| + |Y| - 2 \ge 0$.

(3) $X$ even, $Y$ odd. If $X=0$ then $Q \ge cY^2 \ge c$. Otherwise put $U = |X| \ge 2$,
$V = |Y| \ge 1$; by Lemma 4.1 it suffices that $a(U^2 - UV) + c(V^2-1) \ge 0$. If
$U^2 - UV \ge 0$ this is clear. If $U^2 - UV < 0$ then, since $a \le c$, replacing $a$ by $c$ only
decreases the left side, and $c(U^2 - UV + V^2 - 1) \ge 0$ because $U^2 + V^2 - UV \ge UV \ge 2$.

(4) $X, Y$ both odd, $U = |X| \ge 1$, $V = |Y| \ge 1$. Then
$Q(X,Y) \ge aU^2 + cV^2 - |b|UV$, so it suffices that
$a(U^2-1) + c(V^2-1) \ge |b|(UV-1)$. Since $|b| \le a \le c$, this follows from
$(U^2-1)+(V^2-1) \ge UV - 1$, i.e. from $U^2 + V^2 - UV \ge 1$, which holds because
$U^2+V^2 \ge 2UV$ and $UV \ge 1$. $\square$

**Theorem 4.3 (exhaustiveness).** For every $v \in L$, the gap $\mu(v/2)$ equals one of $0$,
$a/4$, $c/4$, $(a+c-|b|)/4$; that is, $4\mu(v/2) \in W(Q)$.

*Proof.* Write $v_i = r_i + 2k_i$ with $r_i \in \{0,1\}$. Then $v/2 = r/2 + k$ with $k \in L$, and
the gap is translation invariant, so $\mu(v/2) = \mu(r/2)$, which Theorem 4.2 evaluates. $\square$

### 4.3 Completeness

**Lemma 4.4 (order structure).** For a reduced triple, $0 \le a \le c \le a + c - |b|$, so $a$ is
the least nonzero entry of $W$ and $a+c-|b|$ is the greatest. The sum of the entries is
$2a + 2c - |b|$.

*Proof.* $c - a \ge 0$ and $(a+c-|b|) - c = a - |b| \ge 0$. $\square$

**Theorem 4.5 (Theorem B; completeness of $W$).** Let $(a,b,c)$ and $(a',b',c')$ be reduced with
$W(a,b,c) = W(a',b',c')$ as multisets. Then $a = a'$, $c = c'$ and $|b| = |b'|$. Consequently
there is $e \in \{1,-1\}$ with $Q(x,y) = Q'(x, ey)$ for all $x,y$: the two lattices are
isometric, by a coordinate flip.

*Proof.* Equality of multisets gives equality of the least nonzero entries, of the greatest
entries, and of the sums. By Lemma 4.4 these read $a = a'$, $a + c - |b| = a' + c' - |b'|$ and
$2a+2c-|b| = 2a'+2c'-|b'|$. Subtracting the second from the third gives $a + c = a' + c'$, hence
$c = c'$ and then $|b| = |b'|$. Finally $b' = \pm b$, and $ax^2+bxy+cy^2 = ax^2 + b'x(\pm y) +
cy^2$ with the matching sign. $\square$

Three remarks. (i) The argument uses only $\min$, $\max$ and the sum, never distinctness of the
entries — essential, because the hexagonal enumerator $W(x^2+xy+y^2) = \{0,1,1,1\}$ is degenerate.
(ii) Combined with Theorem 3.3, completeness holds for arbitrary positive-definite binary forms,
not merely reduced ones. (iii) The least nonzero entry of $W$ is always $\lambda_1$, so $W$
refines the packing datum; and since $W$ is a complete invariant in rank two, any two distinct
lattices sharing all coset minima necessarily live in rank $\ge 3$.

**Corollary 4.6 (extremes of the enumerator).** $\min\big(W(Q) \setminus \{0\}\big) = \lambda_1$
and $\max W(Q) = a + c - |b| = 4\mu(\tfrac12,\tfrac12)$, the packing invariant and the largest
half-point gap respectively.

---

## 5. The exact covering radius

Fix a normalised reduced triple $0 \le b \le a \le c$, $a > 0$, and set $D = 4ac - b^2 > 0$,
$$h = \Big(\tfrac{c(2a-b)}{D},\ \tfrac{a(2c-b)}{D}\Big), \qquad
\mu = \frac{ac(a-b+c)}{D}.$$

### 5.1 The translation identity

**Lemma 5.1 (stationarity).** The coordinates of $h$ satisfy $2a h_1 + b h_2 = a$ and
$b h_1 + 2c h_2 = c$.

*Proof.* Substituting and clearing $D$, both identities are polynomial identities in $a,b,c$:
$2ac(2a-b) + ab(2c-b) = a(4ac-b^2)$ and $bc(2a-b) + 2ac(2c-b) = c(4ac-b^2)$. $\square$

**Lemma 5.2 (translation identity).** For all rationals $x, y$,
$$Q(x - h_1,\ y - h_2) \;=\; Q(x,y) - a x - c y + \mu .$$

*Proof sketch.* Expanding the left side gives
$Q(x,y) - (2ah_1 + bh_2)x - (bh_1 + 2ch_2)y + Q(h)$. Lemma 5.1 turns the linear part into
$-ax - cy$, and a direct computation (using Lemma 5.1 again, in the form
$Q(h) = \tfrac12(a h_1 + c h_2)$) gives $Q(h) = \mu$. $\square$

Lemma 5.2 is the whole engine. Read at integer points, it produces the lower bound; read at
arbitrary rational points, it produces the upper bound.

### 5.2 Lower bound: the deep hole is that deep

**Lemma 5.3 (integer inequality).** For a reduced triple and all integers $p, q$,
$$a\,p(p-1) + c\,q(q-1) + b\,p\,q \;\ge\; 0 .$$

*Proof.* $p(p-1) \ge 0$ and $q(q-1) \ge 0$ for all integers, so if $pq \ge 0$ every term is
nonnegative. Suppose $pq < 0$. We use repeatedly the following remark: if $A, C \ge 0$ and
$0 \le X \le A + C$, then $bX \le b(A+C) \le aA + cC$, since $0 \le b \le a \le c$.

*Case $p \ge 1$, $q = -s$ with $s \ge 1$.* Here $a\,p(p-1) + c\,q(q-1) + b\,pq =
a\,p(p-1) + c\,s(s+1) - b\,ps$, and $A = p(p-1) \ge 0$, $C = s(s+1) \ge 0$ satisfy
$A + C - ps = p^2 + s^2 - ps + s - p \ge ps + s - p = p(s-1) + s > 0$, using
$p^2 + s^2 \ge 2ps$. The remark applies with $X = ps$.

*Case $p = -P$ with $P \ge 1$, $q \ge 1$.* Here the expression is
$a\,P(P+1) + c\,q(q-1) - b\,Pq$, and $A = P(P+1)$, $C = q(q-1)$ satisfy
$A + C - Pq = P^2 + q^2 - Pq + P - q \ge Pq + P - q = P(q+1) - q > 0$. $\square$

**Theorem 5.4 (the deep hole has gap exactly $\mu$).** $\mu(h) = \mu$; that is,
$Q(h - m) \ge \mu$ for every $m \in L$, with equality at $m \in \{(0,0), (1,0), (0,1)\}$.

*Proof.* By Lemma 5.2 with $(x,y) = (p,q) \in \mathbb{Z}^2$ (and evenness of $Q$ in the sign of
its argument),
$$Q(h - m) \;=\; Q(p,q) - ap - cq + \mu \;=\; \big[a\,p(p-1) + c\,q(q-1) + b\,pq\big] + \mu,$$
because $Q(p,q) - ap - cq = a(p^2-p) + c(q^2-q) + bpq$. Lemma 5.3 gives $\ge \mu$; the bracket
vanishes at $(0,0)$, $(1,0)$ and $(0,1)$. $\square$

The three equality points are exactly the vertices of the Delaunay triangle $\{0, e_1, e_2\}$:
$h$ is its circumcentre, and $\mu$ its circumradius squared. Indeed the triangle has squared side
lengths $a$, $c$, $a-b+c$ and area $\sqrt{D}/4$, so the classical formula
$R = \frac{\ell_1\ell_2\ell_3}{4\,\text{Area}}$ gives
$R^2 = \frac{a\,c\,(a-b+c)}{16 \cdot D/16} = \mu$, in agreement.

### 5.3 Upper bound: no point is deeper

**Lemma 5.5 (concavity bound).** For all rationals $x, y$,
$$a\,x(1-x-y) + c\,y(1-x-y) + (a-b+c)\,x\,y \;\le\; \mu .$$

*Proof.* Expanding, the left side equals $ax + cy - Q(x,y)$, which by Lemma 5.2 equals
$\mu - Q(x-h_1, y-h_2) \le \mu$ by positive definiteness. $\square$

**Lemma 5.6 (Lagrange identity for a triangle).** Let $T$ have vertices $P_1, P_2, P_3$ and let a
point $P$ have barycentric coordinates $(\ell_1,\ell_2,\ell_3)$, $\sum \ell_i = 1$. Then
$$\sum_i \ell_i \, Q(P - P_i) \;=\; \sum_{i<j} \ell_i \ell_j \, Q(P_i - P_j).$$
In particular, for the triangle $\{0, e_1, e_2\}$ and the point $(x,y)$ with weights
$(1-x-y,\, x,\, y)$, the right side is
$a\,x(1-x-y) + c\,y(1-x-y) + (a-b+c)\,x y$; and for the triangle $\{e_1, e_2, e_1+e_2\}$ and
the point $(x,y)$ with weights $(1-y,\, 1-x,\, x+y-1)$ it is the same expression evaluated at
$(1-x,\,1-y)$.

*Proof.* Both sides are quadratic in $P$ with the same second-order part and the same values at
the vertices; alternatively, expand using $\sum_i \ell_i = 1$. $\square$

**Lemma 5.7 (averaging).** If $\ell_1,\ell_2,\ell_3 \ge 0$ with $\sum \ell_i = 1$ and
$\sum \ell_i z_i \le M$, then $\min_i z_i \le M$.

**Theorem 5.8 (covering bound).** Every $t \in \mathbb{Q}^2$ satisfies $\mu(t) \le \mu$.

*Proof sketch.* Translating by $\lfloor t_i \rfloor$ we may assume $t = (x,y)$ with
$0 \le x, y < 1$; the unit cell is the union of the triangles $\{0, e_1, e_2\}$ (where
$x + y \le 1$) and $\{e_1, e_2, e_1+e_2\}$ (where $x+y \ge 1$), glued along the short diagonal.

*Case $x+y \le 1$.* The weights $(1-x-y, x, y)$ are nonnegative and sum to $1$. By Lemma 5.6 the
weighted average of $Q(t)$, $Q(t-e_1)$, $Q(t-e_2)$ equals
$a x(1-x-y) + c y (1-x-y) + (a-b+c)xy$, which is $\le \mu$ by Lemma 5.5. By Lemma 5.7 one of the
three vertices is within $\mu$ of $t$.

*Case $x+y \ge 1$.* Same argument with the weights $(1-y, 1-x, x+y-1)$ for the upper triangle;
the bound is Lemma 5.5 applied at $(1-x, 1-y)$. $\square$

Nonnegativity of the barycentric weights is exactly why the cell must be cut along the *short*
diagonal, which in turn is exactly where $b \ge 0$ is used; and $b \le a \le c$ is what makes the
triangle non-obtuse, i.e. makes the circumcentre lie inside it.

**Theorem 5.9 (Theorem D; the covering radius of a reduced binary lattice).** For
$0 \le b \le a \le c$, the point $h$ has gap $\mu$, and every $t$ has gap at most $\mu$; hence
$$\mu(Q) \;=\; \frac{a\,c\,(a-b+c)}{4ac - b^2}.$$

*Proof.* Theorem 5.4 and Theorem 5.8. $\square$

### 5.4 Removing reducedness

**Theorem 5.10 (arbitrary binary lattice).** Let $Q$ be a positive-definite rational form on
$\mathbb{Z}^2$ with homogeneous minimum $\lambda_1$. Then there exist $b, c$ with
$0 \le b \le \lambda_1 \le c$ and a shift $t$ such that $\mu(t) = \mathrm{cr}(\lambda_1, b, c)$
and $\mu(t') \le \mathrm{cr}(\lambda_1,b,c)$ for all $t'$, where
$\mathrm{cr}(a,b,c) = ac(a-b+c)/(4ac-b^2)$. In other words the covering radius squared of every
planar lattice is $\lambda_1 c(\lambda_1 - b + c)/(4\lambda_1 c - b^2)$ in its reduced
invariants.

*Proof sketch.* Theorem 3.3 produces a basis in which the form is reduced with leading
coefficient $\lambda_1$. The change of basis is unimodular, so it carries $L$ onto $L$ and
$\mathbb{Q}^2$ onto $\mathbb{Q}^2$; gaps are therefore preserved in both directions — lattice
points are pulled back by the inverse integer matrix, and rational shifts are pushed forward by
it. Apply Theorem 5.9 in the new basis and transport $h$ back. If the middle coefficient comes
out negative, flip the sign of the second basis vector. $\square$

---

## 6. Consequences

Throughout this section $(a,b,c)$ is normalised reduced, $a = \lambda_1$, $D = 4ac-b^2 > 0$.

**Theorem 6.1 (quantitative strictness).**
$$\mu - \frac{\lambda_1}{4} \;=\; \frac{a\,(2c-b)^2}{4\,(4ac-b^2)} \;>\; 0 .$$

*Proof.* Clearing denominators, $4ac(a-b+c) - a(4ac-b^2) = a\big(4c(a - b + c) - 4ac + b^2\big)
= a(4c^2 - 4bc + b^2) = a(2c-b)^2$; divide by $4D$. Positivity: $2c - b \ge 2a - a = a > 0$.
$\square$

Hence $\mu > \lambda_1/4$ for every planar lattice, and one recovers the classical inequality with
its equality case: in rank one, $Q = a x^2$ has deep hole $1/2$ and $\mu = a/4$ exactly, so rank
one is the unique equality case in the chain of rank-$n$ statements.

**Theorem 6.2 (Theorem C, by certificate).** For every positive-definite binary form there is a
rational shift $t$ with $Q(t - m) > \lambda_1/4$ for all $m \in L$; hence $\mu > \lambda_1/4$.

*Proof sketch.* In a reduced basis, if $|b| < c$ take $t = (\tfrac12,\tfrac12)$: by Theorem 4.2
its gap is $(a - |b| + c)/4 > a/4$. Otherwise $|b| = c$; combined with $|b| \le a \le c$ this
forces $a = c = |b|$, i.e. $Q = a(x^2 \pm xy + y^2)$, the hexagonal form. There take
$t = (\tfrac13, \pm\tfrac13)$: for integers $X \equiv Y \equiv 1 \pmod 3$ one has
$3 \mid X^2 + XY + Y^2$, and $X^2+XY+Y^2 > 0$, hence $X^2 + XY + Y^2 \ge 3$; scaling by $1/9$
gives gap $\ge a/3 > a/4$. $\square$

This certificate proof is worth keeping alongside Theorem 6.1 because it identifies the exact
obstruction to the naive approach, which the next statement makes precise.

**Theorem 6.3 (the hexagonal obstruction).** For the hexagonal form $x^2+xy+y^2$, every one of
the three nonzero classes of $L/2L$ contains a shortest vector, so every half-point has gap
exactly $\lambda_1/4 = 1/4$: no $2$-torsion shift certifies strictness. The $3$-torsion point
$(\tfrac13,\tfrac13)$ has gap $1/3$, and $\mu = 1/3$.

*Proof.* $W(1,1,1) = \{0,1,1,1\}$ by Theorem 4.2; the shortest vectors $(1,0), (0,1), (1,-1)$
represent the three nonzero classes. The last two claims are Theorem 5.9 with $(a,b,c) =
(1,1,1)$, whose deep hole is $h = (1/3, 1/3)$ and $\mu = 1\cdot 1 \cdot 1/3 = 1/3$. $\square$

**Theorem 6.4 (rectangularity criterion).** $(a-b+c)/4 \le \mu$ always, with equality if and only
if $b = 0$. Equivalently, a half-lattice point is a deepest hole precisely for rectangular
lattices.

*Proof.* Cross-multiplying, $4ac(a-b+c) - (a-b+c)(4ac-b^2) = (a-b+c)b^2 \ge 0$, giving the
inequality with equality iff $b^2(a-b+c) = 0$, i.e. iff $b=0$ (since $a - b + c \ge a > 0$).
$\square$

**Theorem 6.5 (ceiling).** $\mu \le (a+c)/2$.

*Proof.* Expanding,
$$(a+c)(4ac-b^2) - 2ac(a-b+c) \;=\; 2a^2c + 2ac^2 + 2abc - (a+c)b^2 .$$
Reducedness gives $b^2 \le a^2 \le ac$, so $(a+c)b^2 \le (a+c)ac = a^2c + ac^2$, and the right side
is at least $a^2c + ac^2 + 2abc \ge 0$. Divide by $2D > 0$. $\square$

**Examples 6.6.** $\mu(\mathbb{Z}^2) = \mathrm{cr}(1,0,1) = 1/2$, deep hole $(\tfrac12,\tfrac12)$,
the centre of a unit square. $\mu(A_2) = \mathrm{cr}(1,1,1) = 1/3$, deep hole
$(\tfrac13,\tfrac13)$, the centre of an equilateral triangle of side $1$.
$\mathrm{cr}(2,1,3) = 24/23$, $\mathrm{cr}(1,0,5) = 3/2$, $\mathrm{cr}(1,1,2) = 4/7$.

**Theorem 6.7 (Theorem E; sharp packing–covering inequality in rank two).** Every
positive-definite binary form satisfies
$$\mu \;\ge\; \frac{\lambda_1}{3},$$
with equality if and only if $b = a$ and $c = a$, i.e. exactly for the hexagonal form
$a(x^2+xy+y^2)$.

*Proof.* Cross-multiplying the claim $\mathrm{cr}(a,b,c) \ge a/3$ and simplifying,
$$3ac(a-b+c) - a(4ac-b^2) \;=\; a\big[(c-a)c + (2c-b)(c-b)\big].$$
Both bracketed products are nonnegative: $c \ge a$ gives $(c-a)c \ge 0$, and $b \le a \le c$
gives $2c - b > 0$ and $c - b \ge 0$. Hence $\mu \ge a/3$. Equality forces
$(c-a)c = 0$ and $(2c-b)(c-b) = 0$; since $c > 0$ and $2c - b > 0$, this is $c = a$ and $b = c$,
i.e. $a = b = c$. Conversely for $a=b=c$, $D = 3a^2$ and
$\mathrm{cr}(a,a,a) = a\cdot a \cdot a/(3a^2) = a/3$. $\square$

Combining with Theorem 5.10, the constant $1/3$ applies to every planar lattice, with no
reducedness hypothesis, and it strictly improves the universal constant $1/4$. The rigidity
clause characterises the hexagonal lattice by a single scalar inequality: it is the unique planar
lattice whose deep holes are as shallow as possible relative to its minimum.

---

## 7. Algorithms

The theory yields exact algorithms whose cost is dominated by reduction.

**Algorithm 7.1 (Gauss reduction).** Input an integral or rational triple $(a,b,c)$ with $a > 0$
and $4ac - b^2 > 0$. Repeat: if $c < a$, swap $a$ and $c$ (basis swap); if $|b| > a$, set
$k = -\mathrm{round}(b/2a)$, then $c \leftarrow ak^2 + bk + c$ and $b \leftarrow b + 2ka$ (shear).
Terminate when $|b| \le a \le c$; finally, if $b < 0$, set $b \leftarrow -b$ (flip). The quantity
$a + c$ strictly decreases at every swap, so termination is guaranteed; for integral input the
number of iterations is $O(\log \max(a,c))$, matching the Euclidean algorithm, and each iteration
costs $O(1)$ arithmetic operations.

**Algorithm 7.2 (covering radius and deep hole).** Reduce; return $D = 4ac-b^2$,
$\mu = ac(a-b+c)/D$ and $h = \big(c(2a-b)/D, a(2c-b)/D\big)$; if desired, transport $h$ back
through the recorded unimodular change of basis. Total cost: reduction plus $O(1)$ exact rational
operations. This replaces the naive approach — a continuous optimisation of a piecewise-quadratic
function over the fundamental cell, with a nearest-lattice-point subproblem at each candidate.

**Algorithm 7.3 (covering weight enumerator and recognition).** Reduce; return the sorted multiset
$\{0, a, c, a+c-|b|\}$. Conversely, given a multiset $W = \{w_1 \le w_2 \le w_3 \le w_4\}$ known
to come from a reduced binary lattice, recover $a = w_2$ (least nonzero entry),
$M = w_4$, $S = \sum w_i$, then $c = S - M - a$ and $|b| = a + c - M$. Validity requires only
$0 \le |b| \le a \le c$, which can be checked directly, and the recovery is $O(1)$ after sorting.

**Algorithm 7.4 (nearest lattice point / decoding).** For a target $t$, reduce, write
$t = (x,y)$ modulo $L$ in the reduced basis with $0 \le x,y < 1$, and test the three vertices of
the containing Delaunay triangle ($\{0,e_1,e_2\}$ if $x+y \le 1$, else
$\{e_1,e_2,e_1+e_2\}$); the closest of the three is a nearest lattice point, and the worst case
over $t$ is $\mu$. Correctness is the content of Theorem 5.8: within a Delaunay cell, a nearest
lattice point is always a vertex of that cell.

---

## 8. Discussion

### 8.1 Why the discriminant appears

Every earlier invariant of this circle of problems — the minimum, the coset minima, the
half-point gaps — is a *linear* expression in the coefficients $a, b, c$ with integer
coefficients. The covering radius is the first that involves the determinant. The reason is
structural: the deep hole is a circumcentre, and a circumradius is a ratio of a product of side
lengths to an area; the area of the lattice triangle is $\sqrt{D}/4$. Equivalently, the deep hole
is the solution of the linear system $2ah_1 + bh_2 = a$, $bh_1 + 2ch_2 = c$, whose Cramer
denominator is $D$. So the transition from packing data to covering data is exactly the
transition from the values of the form to the inverse of its Gram matrix.

### 8.2 The two halves of the proof

The lower bound is an *integrality* statement: $a p(p-1) + cq(q-1) + bpq \ge 0$ holds for integer
$p, q$ and fails badly for real ones (at $p = q = 1/2$ it equals $(b - a - c)/4 < 0$). The upper
bound is a *convexity* statement, holding for all real points and using no arithmetic at all. This
is the packing/covering dichotomy in miniature: packing bounds come from arithmetic, covering
bounds from geometry, and an exact covering radius requires the two to meet — the maximum of the
concave averaging function must be attained at a point whose distance to the lattice is computed
by the arithmetic side.

### 8.3 The role of the hexagonal lattice

The hexagonal lattice appears three times, and always as the extreme case. Its enumerator
$\{0,1,1,1\}$ is the unique degenerate one: all three nonzero classes of $L/2L$ contain a
shortest vector. Consequently it is the unique lattice for which the two-torsion certificate
fails to prove $\mu > \lambda_1/4$, forcing the three-torsion argument. And it is the unique
equality case of $\mu \ge \lambda_1/3$. These are three faces of one fact: the hexagonal lattice
has the most symmetric Delaunay decomposition, into equilateral triangles, and its deep holes are
as shallow as symmetry permits.

### 8.4 Sharpness and completeness

Two of our results are optimal in a strong sense. The constant $1/3$ cannot be improved (it is
attained), and the enumerator cannot be refined away: it is already a *complete* invariant in
rank two, so nothing is lost by passing from a lattice to its four coset minima. This localises
the search for interesting phenomena. The covering weight enumerator was introduced as a
candidate invariant strictly finer than the theta series — the generating function counting
lattice vectors of each norm — with the aim of separating isospectral lattices. In rank two the
question is moot, since $W$ separates everything; consequently **any** isospectral pair
distinguished by their coset minima must have rank at least three. In rank two, isospectrality
already implies isometry.

### 8.5 Relation to the general-rank picture

In rank $n$ the analogue of Theorem 5.9 would express $\mu$ as the maximum, over Delaunay cells,
of the circumradius squared of the cell. The rank-two proof is a complete instance of this
programme: the Delaunay decomposition consists of two congruent triangles, the maximum is over a
single congruence class, and reducedness makes the circumcentre lie inside its cell. In higher
rank the Delaunay decomposition is itself a hard object, the number of cell types grows, and the
circumcentre may fall outside a cell; but the two ingredients of our proof — the translation
identity turning the gap into a linear-plus-quadratic expression, and the barycentric averaging
argument — are dimension-independent.

---

## 9. Future work

1. **A Delaunay formula in every rank.** Prove that for a positive-definite form on
   $\mathbb{Z}^n$ the covering radius squared is the maximum over Delaunay cells of the
   circumradius squared, and that this maximum is a rational function of the Gram matrix with
   denominator a power of $\det Q$. In rank two the denominator is $4 \det Q$.
2. **The sharp constant in higher rank.** Determine, for each $n$, the least value of
   $\mu/\lambda_1$ over rank-$n$ lattices. Rank one gives $1/4$, rank two gives $1/3$ (attained
   uniquely by the hexagonal lattice); the extremal lattice is conjecturally the one with the
   most symmetric Delaunay decomposition in each rank.
3. **Completeness of the covering weight enumerator beyond rank two.** In rank $n$, $W(Q)$ has
   $2^n$ entries and remains an invariant under change of basis. Is it complete in rank three?
   The first candidate counterexamples are the classical isospectral pairs; each test is a finite
   computation, since only the bottom shells matter.
4. **Reconstruction from coset minima.** The rank-two recovery uses only three order-theoretic
   functionals of $W$ — the least nonzero entry, the greatest entry and the sum. In rank $n$ a
   diagonal form's enumerator is the weighted Hamming enumerator of $\mathbb{F}_2^n$, and a
   Möbius inversion over the Boolean lattice of subsets should recover the diagonal entries from
   the singletons; making this precise for general forms is the natural next step.
5. **Torsion order of the extremal shift.** For $\mathbb{Z}^n$ and for every diagonal form the
   deepest hole is $2$-torsion; the hexagonal lattice needs $3$-torsion. Is the torsion order of
   a deepest hole bounded in terms of the rank? Theorem 6.4 gives the rank-two answer: order $2$
   suffices exactly for rectangular lattices.
6. **Quantiser performance.** The same Delaunay geometry that computes the worst-case distortion
   $\mu$ also computes the mean-squared distortion, an integral of $Q$ over a Voronoi cell. An
   exact rational formula in $(a,b,c)$ for the second moment, paired with Theorem 5.9, would give
   a complete rank-two theory of lattice quantisation.

---

## 10. Summary of results

| Statement | Content |
|---|---|
| Reduced basis | Every planar lattice has a basis with $0 \le b \le a \le c$ and $a = \lambda_1$ |
| Coset minima | $W(Q) = \{0,\, a,\, c,\, a+c-\lvert b\rvert\}$, realised by the four classes of $L/2L$ |
| Extremes of $W$ | $\min(W \setminus \{0\}) = \lambda_1$, $\max W = 4\mu(\tfrac12,\tfrac12)$ |
| Completeness | $W$ determines $(a, \lvert b\rvert, c)$: a complete isometry invariant in rank two |
| Strictness | $\mu > \lambda_1/4$ for every planar lattice; rank one is the only equality case |
| Exact radius | $\mu = ac(a-b+c)/(4ac-b^2)$, attained at the Delaunay circumcentre |
| Excess | $\mu - \lambda_1/4 = a(2c-b)^2 / \big(4(4ac-b^2)\big)$ |
| Rectangularity | A half-point is a deepest hole $\iff b = 0$ |
| Ceiling | $\mu \le (a+c)/2$; $\mu(\mathbb{Z}^2) = 1/2$ |
| Sharp constant | $\mu \ge \lambda_1/3$, equality exactly for $a(x^2+xy+y^2)$; $\mu(A_2) = 1/3$ |
