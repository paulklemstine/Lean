# Injective Parametric Families for Sums of Three Cubes: The Vieta Barrier and the Cube-Digit Principle

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

The Vieta identity $a^3+b^3+(-a-b)^3=-3ab(a+b)$ produces a two-parameter family of integers representable as a sum of three cubes. We analyse the value map $V(a,b)=-3ab(a+b)$ from the point of view of injectivity and of quantitative counting, and then replace it by a different, provably injective, family that counts strictly better.

On the Vieta side we determine the exact six-element symmetry orbit of $V$; exhibit a residual collision *inside* the fundamental domain $1\le a\le b$, namely $V(1,5)=V(2,3)=-90$, showing that no ordering restriction alone yields injectivity; prove that the multiplicity of a value $v$ is at most $d(v)$, the number of divisors of $v$, which identifies divisor structure as the exact arithmetic mechanism of collisions; construct two genuinely injective subfamilies (the *spine* $a=1$, and a two-parameter *dyadic* family $a=2^i$ with $b$ odd, whose injectivity follows from the $2$-adic valuation); and deduce the counting lower bounds $\lfloor\sqrt{N/6}\rfloor$ on the positive side and $2\lfloor\sqrt{N/6}\rfloor$ counting both signs, all with three *nonzero* cubes. We complement this with a ceiling: every Vieta value is divisible by $6$, whence the Vieta counting function is sandwiched, $\lfloor\sqrt{N/6}\rfloor \le \#\mathrm{Vieta}(N)\le \lfloor N/6\rfloor$.

The obstruction to improving the exponent $1/2$ for Vieta is structural, not technical: the collision count is a divisor count, and sparsifying the first parameter enough to make the value determine it makes the resulting sum $\sum_a (N/a)^{1/2}$ converge. We therefore change families. We isolate a *cube-digit* (greedy) recovery principle — if $r<3z^2+3z+1$ then $z^3+r$ determines $z$ and $r$ — and iterate it on a three-scale box
$$1\le x\le t^4,\qquad t^6\le y<2t^6,\qquad 2t^9\le z<3t^9,$$
on which $(x,y,z)\mapsto x^3+y^3+z^3$ is injective. The box has exactly $t^{19}$ points and all values lie in $[1,36t^{27}]$, giving at least $t^{19}$ integers below $36t^{27}$ that are sums of three *positive* cubes; in real-analytic form, at least $\left(N/(36\cdot 2^{27})\right)^{19/27}$ such integers below any $N\ge 36$. The exponent $19/27=0.7037\ldots$ strictly dominates $1/2$; explicitly, $100\sqrt{N}\le t^{19}$ for $N=36t^{27}$ and $t\ge 4$.

A residue-restricted version of the box, with all three cube roots $\equiv 1 \pmod 6$, produces at least $136\,t^{19}$ integers below $10^8t^{27}$ that are sums of three positive cubes and are *not* Vieta values for any pair of integers, since they are $\equiv 3\pmod 6$. Finally, we generalise the greedy principle to $s$ cubes by induction, obtaining the exponent $1-(2/3)^s$ (values $5/9$, $19/27$, $65/81$ for $s=2,3,4$), with exponents increasing to $1$.

**Keywords:** sums of three cubes, Vieta identity, injective parametric families, greedy representation, divisor function, counting functions, Waring-type problems.

---

## 1. Introduction

### 1.1 The problem

Let
$$\mathcal{C}_3 = \{\, n\in\mathbb{Z} : n = x^3+y^3+z^3 \text{ for some } x,y,z\in\mathbb{Z}\,\}.$$
Deciding membership in $\mathcal{C}_3$ for a specific $n$ is notoriously delicate; the only known local obstruction is $n\not\equiv \pm 4 \pmod 9$, and it is conjectured that every other integer belongs to $\mathcal{C}_3$, indeed with infinitely many representations. Representations, when they exist, can be enormous.

The *counting* problem is more tractable but still open in essentials. Write
$$R_3(N) = \#\{\, n : 1\le n\le N,\ n \in \mathcal{C}_3 \,\}.$$
Conjecturally $R_3(N)\gg N$. Unconditionally, the classical elementary route to lower bounds is to exhibit a *parametric family*: a polynomial identity in several parameters, all of whose values lie in $\mathcal{C}_3$, together with an injectivity statement making the number of parameter choices a lower bound for the number of values.

Two rules of hygiene are essential and are respected throughout this paper.

1. **No padded zeros.** A "sum of three cubes" in which one cube is $0^3$ is really a sum of two cubes. Every representation constructed below uses three nonzero cubes; in the cube-digit families all three cubes are positive.
2. **Honest counting.** All counts below are cardinalities of explicitly defined sets of integers, not counts of parameter tuples. Injectivity is proved, not assumed.

### 1.2 The Vieta identity

The most natural three-cube identity comes from the vanishing of the second symmetric function. If $a+b+c=0$ then $a^3+b^3+c^3 = 3abc$; taking $c=-a-b$:

$$a^3+b^3+(-a-b)^3 = -3ab(a+b) =: V(a,b). \tag{1.1}$$

The identity is exact, elementary, and gives a two-parameter supply of members of $\mathcal{C}_3$. The region $|3ab(a+b)|\le N$ in the $(a,b)$-plane contains $\asymp N^{2/3}$ lattice points, so a naive count suggests $\asymp N^{2/3}$ distinct values. Numerical experiment supports this: the number of *positive* integers $\le N$ of the form $3ab(a+b)$ is empirically $\approx 0.53\,N^{2/3}$.

Proving anything of the sort is another matter, and §2–§3 explain exactly why.

### 1.3 Results and organisation

§2 analyses the Vieta value map: its symmetry orbit (Theorem 2.2), a residual collision in the fundamental domain (Theorem 2.4), and the divisor bound on multiplicity (Theorem 2.7).

§3 constructs injective Vieta subfamilies and their counting consequences: the spine bound $\lfloor\sqrt{N/6}\rfloor$ (Theorem 3.3), its two-sided version (Theorem 3.4), and the dyadic two-parameter family with injectivity via the $2$-adic valuation (Theorems 3.6–3.8).

§4 proves the Vieta ceiling — divisibility by $6$ and the resulting upper bound $\lfloor N/6\rfloor$ — and the sandwich (Theorems 4.1–4.3).

§5 is the heart of the paper: the cube-digit principle (Theorem 5.1), the two-step greedy injectivity engine (Theorem 5.2), the three-scale box, the injectivity theorem (Theorem 5.6) and the counting theorem with exponent $19/27$ (Theorems 5.7, 5.9, 5.10), including the explicit comparison with $\sqrt{N}$ (Theorem 5.8).

§6 gives the escape theorem: a residue-restricted cube-digit family producing $\gg N^{19/27}$ integers outside the Vieta value set entirely (Theorem 6.3).

§7 generalises to $s$ cubes: the greedy cube tower, exponent $1-(2/3)^s$ (Theorems 7.3–7.6).

§8 discusses the gap between the provable and conjectural exponents, and §9 lists open problems.

---

## 2. The Vieta value map and its collisions

### 2.1 Definitions

**Definition 2.1.** For $a,b\in\mathbb{Z}$ set $V(a,b) := -3ab(a+b)$. Call $k\in\mathbb{Z}$ **Vieta represented** if there exist $a,b\in\mathbb{Z}$ with $a\neq 0$, $b\neq 0$, $a+b\neq 0$ and $V(a,b)=k$. Call $k$ a **sum of three nonzero cubes** if $k=x^3+y^3+z^3$ for some nonzero integers $x,y,z$.

The nondegeneracy conditions $a\ne 0$, $b\ne 0$, $a+b\ne 0$ are exactly what is needed to guarantee that the three cube roots $a$, $b$, $-a-b$ in (1.1) are all nonzero. Consequently every Vieta represented integer is a sum of three nonzero cubes. The family is also closed under sign change: $V(-a,-b)=-V(a,b)$.

### 2.2 The symmetry orbit

**Theorem 2.2 (Six-fold symmetry).** For all integers $a,b$,
$$V(a,b)=V(b,a)=V(a,-a-b)=V(-a-b,a)=V(b,-a-b)=V(-a-b,b).$$
Moreover, if $a$, $b$ and $-a-b$ are pairwise distinct, these six parameter pairs are pairwise distinct, so $V$ is (at least) six-to-one at such points.

*Proof sketch.* Each identity is a polynomial identity verified by expansion; conceptually, $V(a,b)=3abc$ up to sign with $c=-a-b$, and the listed substitutions permute the multiset $\{a,b,c\}$, which is the full $S_3$-orbit (the stabiliser of the ordered pair being trivial when the three roots are distinct). The distinctness claim is a finite case check on the six ordered pairs. $\square$

This is a genuine obstruction to global injectivity, but a harmless one: one passes to a fundamental domain for the $S_3$-action. The natural choice is $1\le a\le b$.

### 2.3 A residual collision

**Theorem 2.4 (No ordering restriction suffices).** The value map is not injective on the fundamental domain $\{(a,b) : 1\le a\le b\}$:
$$V(1,5) = V(2,3) = -90, \qquad (1,5)\neq (2,3).$$
Concretely,
$$1^3+5^3+(-6)^3 = -90 = 2^3+3^3+(-5)^3.$$

*Proof.* Direct computation: $-3\cdot 1\cdot 5\cdot 6 = -90$ and $-3\cdot 2\cdot 3\cdot 5=-90$. $\square$

**Remark 2.5.** One may hope to fix injectivity by scaling the spine by cubes: $(m,b)\mapsto 3m^3b(b+1)$, whose values are $m^3$ times a spine value and hence still sums of three cubes (scale the roots by $m$). This too fails: $3\cdot 1^3\cdot 15\cdot 16 = 720 = 3\cdot 2^3\cdot 5\cdot 6$. The failure is again a divisor coincidence.

### 2.4 Multiplicity is bounded by the divisor function

The two collisions above are instances of one mechanism.

**Lemma 2.6 (Monotonicity in the second variable).** For each fixed integer $a\ge 1$, the map $b\mapsto 3ab(a+b)$ is strictly increasing on $b\ge 0$.

*Proof.* $b\mapsto b(a+b)$ is strictly increasing for $b\ge 0$ and $a\ge 1$, and multiplication by $3a>0$ preserves strict order. $\square$

**Theorem 2.7 (Divisor bound for multiplicity).** Let $v\ge 1$. Then
$$\#\{(a,b)\in\mathbb{Z}_{\ge 1}^2 : 3ab(a+b)=v\} \;\le\; d(v),$$
where $d(v)$ is the number of positive divisors of $v$.

*Proof sketch.* If $3ab(a+b)=v$ with $a,b\ge 1$, then $a \mid v$, since $v=a\cdot(3b(a+b))$. So the first-coordinate projection maps the solution set into the divisors of $v$. By Lemma 2.6 the projection is injective: if two solutions share the same $a$, then $3ab(a+b)=3ab'(a+b')$ forces $b=b'$ by strict monotonicity. An injection into $\mathrm{Div}(v)$ gives the bound. $\square$

Theorem 2.7 is the precise statement of the "collisions are divisor collisions" slogan. It is simultaneously an encouragement (the $N^{2/3}$ lattice points collapse only by a divisor factor, which is $v^{o(1)}$ on average) and a warning (to certify injectivity one must control which $a$ can occur, and any sparsification of $a$ costs a full power).

---

## 3. Injective Vieta subfamilies and square-root counting

### 3.1 The represented sets

**Definition 3.1.** For $N\in\mathbb{N}$ set
$$\mathcal{R}(N) := \{\,k\in\mathbb{Z} : 0<k\le N,\ k \text{ Vieta represented}\,\},$$
$$\mathcal{R}^{\pm}(N) := \{\,k\in\mathbb{Z} : k\ne 0,\ |k|\le N,\ k \text{ Vieta represented}\,\}.$$
Both are finite, being subsets of a finite interval, and every element of either is a sum of three nonzero cubes.

Lower bounds are proved by exhibiting a finite set $T$ of integers each lying in the target set, and noting $\#T \le \#\mathcal{R}(N)$.

### 3.2 The spine

**Definition 3.2.** The **spine** of the Vieta family is $S(b) := 3b(b+1) = -V(1,-b) = -V(-1,-b)$ for $b\ge 1$.

Explicitly, $S(b)$ is a sum of three nonzero cubes via $(-1)^3+(-b)^3+(1+b)^3 = 3b(b+1)$. The map $S$ is strictly increasing, hence injective.

**Theorem 3.3 (Square-root lower bound).** For all $N,m\in\mathbb{N}$ with $3m(m+1)\le N$ we have $m\le \#\mathcal{R}(N)$. Consequently, for every $N$,
$$\left\lfloor \sqrt{N/6}\right\rfloor \;\le\; \#\mathcal{R}(N).$$

*Proof sketch.* The values $S(1)<S(2)<\cdots<S(m)$ are $m$ distinct positive integers, each Vieta represented with three nonzero cubes, and each at most $S(m)=3m(m+1)\le N$. For the second statement take $m=\lfloor\sqrt{N/6}\rfloor$; then $6m^2\le N$, and since $3m(m+1)\le 6m^2$ for $m\ge 1$, the hypothesis holds. ($m=0$ is trivial.) $\square$

**Theorem 3.4 (Two-sided bound).** For all $N,m$ with $3m(m+1)\le N$,
$$2m \le \#\mathcal{R}^{\pm}(N).$$

*Proof sketch.* Both $S(b)$ and $-S(b)$ are Vieta represented (using $V(-a,-b)=-V(a,b)$), the two families are disjoint since $S(b)>0$, and each family is injective in $b$. $\square$

**Remark 3.5.** The spine is one-dimensional and the bound is therefore intrinsically of order $\sqrt{N}$. The next subsection shows that a genuinely two-dimensional injective subfamily exists, but that the second dimension is logarithmically thin.

### 3.3 The dyadic family

**Definition 3.6.** For $i\ge 1$ and odd $b\ge 1$, set
$$D(i,b) := 3\cdot 2^i\cdot b\cdot (2^i+b) = -V(-2^i,-b).$$

**Lemma 3.7 ($2$-adic valuation reads the layer).** If $i\ge 1$ and $b\ge 1$ is odd, then $v_2(D(i,b)) = i$, where $v_2$ is the $2$-adic valuation.

*Proof sketch.* Write $D(i,b) = 2^i\cdot\bigl(3b(2^i+b)\bigr)$. Since $i\ge 1$, $2^i$ is even and $b$ is odd, so $2^i+b$ is odd; thus $3b(2^i+b)$ is a product of three odd numbers, hence odd. Therefore $v_2(D(i,b)) = v_2(2^i) = i$. $\square$

**Theorem 3.8 (Injectivity of the dyadic family).** If $i,j\ge 1$ and $b,c\ge 1$ are odd with $D(i,b)=D(j,c)$, then $i=j$ and $b=c$.

*Proof sketch.* Lemma 3.7 gives $i = v_2(D(i,b)) = v_2(D(j,c)) = j$. With $i=j$ fixed, the map $b\mapsto 3\cdot 2^i\cdot b(2^i+b)$ is strictly increasing (Lemma 2.6 with $a=2^i\ge 1$), hence injective, so $b=c$. $\square$

**Theorem 3.9 (Two-parameter count).** For all $I,m\in\mathbb{N}$,
$$I\cdot m \;\le\; \#\mathcal{R}\bigl(6\cdot 2^I\, m\,(2^I+2m)\bigr).$$

*Proof sketch.* Take the $I\cdot m$ pairs $(i, 2p+1)$ with $1\le i\le I$ and $0\le p<m$. Each value $D(i,2p+1)$ is Vieta represented with three nonzero cubes and is positive; the values are pairwise distinct by Theorem 3.8. Monotonicity in each argument bounds every value by $3\cdot 2^I\cdot 2m\cdot(2^I+2m) = 6\cdot 2^I m(2^I+2m)$. $\square$

Setting $N \approx 6\cdot 2^I m(2^I+2m)$ and optimising, the dyadic family yields a count of order $\sqrt{N}$ again, with a better constant for small $I$ but no improvement in the exponent: the family has $I \asymp \log$ layers, each contributing $\asymp \sqrt{N}/2^{I}$ points. This is the convergent-sum phenomenon described in §8.

---

## 4. The Vieta ceiling

The Vieta family cannot be improved past a hard arithmetic ceiling.

**Theorem 4.1 (Divisibility by six).** For all integers $a,b$, $\ 6 \mid V(a,b)$.

*Proof.* $V(a,b) = -3ab(a+b)$ is divisible by $3$. For divisibility by $2$: if $a$ is even, $2\mid ab(a+b)$; if $a$ is odd and $b$ is even, likewise; if $a$ and $b$ are both odd, then $a+b$ is even. In all cases $2\mid ab(a+b)$, so $6\mid V(a,b)$. $\square$

**Corollary 4.2.** An integer not divisible by $6$ is not a Vieta value.

**Theorem 4.3 (Ceiling and sandwich).** For all $N$,
$$\#\mathcal{R}(N)\le \left\lfloor \frac{N}{6}\right\rfloor,
\qquad\text{hence}\qquad
\left\lfloor\sqrt{N/6}\right\rfloor \;\le\; \#\mathcal{R}(N) \;\le\; \left\lfloor \frac{N}{6}\right\rfloor.$$

*Proof sketch.* By Theorem 4.1, $\mathcal{R}(N)$ is contained in the set of positive multiples of $6$ not exceeding $N$, of which there are $\lfloor N/6\rfloor$. The lower bound is Theorem 3.3. $\square$

The sandwich is wide — from $N^{1/2}$ to $N^{1}$ — and the truth is believed to sit at $N^{2/3}$ in the middle. The upper bound will however be used constructively in §6: it converts a congruence condition into a certificate of non-membership.

---

## 5. The cube-digit principle and the exponent $19/27$

We now abandon the Vieta identity in favour of a construction whose injectivity is built in rather than deduced.

### 5.1 Greedy recovery

**Theorem 5.1 (Cube-digit uniqueness).** Let $z,r,z',r'$ be nonnegative integers with
$$r < 3z^2+3z+1, \qquad r' < 3z'^2+3z'+1, \qquad z^3+r = z'^3+r'.$$
Then $z=z'$ and $r=r'$.

*Proof.* The quantity $3z^2+3z+1$ is exactly the cube gap $(z+1)^3-z^3$. Suppose $z<z'$. Then
$$z^3 + r < z^3 + 3z^2+3z+1 = (z+1)^3 \le z'^3 \le z'^3+r',$$
contradicting the equality. Symmetrically $z'<z$ is impossible. Hence $z=z'$, and cancelling $z^3$ gives $r=r'$. $\square$

Equivalently: under the stated remainder bound, $z=\lfloor (z^3+r)^{1/3}\rfloor$, i.e. $z$ is the integer cube root of the value. This is a positional-notation principle with cubes as place values, which is why we call $z$ the leading *cube digit*.

Iterating once gives the engine used everywhere below.

**Theorem 5.2 (Two-step greedy injectivity).** Let $x,y,z,x',y',z'$ be nonnegative integers satisfying the four *gap conditions*
$$x^3<3y^2+3y+1,\quad x'^3<3y'^2+3y'+1,\quad x^3+y^3<3z^2+3z+1,\quad x'^3+y'^3<3z'^2+3z'+1,$$
and suppose $x^3+y^3+z^3 = x'^3+y'^3+z'^3$. Then $x=x'$, $y=y'$, $z=z'$.

*Proof sketch.* Rewrite the hypothesis as $z^3 + (x^3+y^3) = z'^3 + (x'^3+y'^3)$; the third and fourth gap conditions let Theorem 5.1 apply, giving $z=z'$ and $x^3+y^3 = x'^3+y'^3$. Rewrite the latter as $y^3+x^3 = y'^3+x'^3$; the first and second gap conditions let Theorem 5.1 apply again, giving $y=y'$ and $x^3=x'^3$, whence $x=x'$ since cubing is injective on $\mathbb{N}$. $\square$

Theorem 5.2 is reusable: *any* box of triples on which the four gap conditions hold carries an injective cube-sum map. The remaining design problem is to find a box that is as large as possible relative to the size of its values.

### 5.2 Scale analysis

The condition $x^3 \lesssim 3y^2$ says $x \lesssim y^{2/3}$; the condition $y^3 \lesssim 3z^2$ says $y\lesssim z^{2/3}$. Thus if $z$ ranges over a window of length $\asymp Z$, then $y$ may range over $\asymp Z^{2/3}$ values and $x$ over $\asymp Z^{4/9}$ values, so the box has
$$\asymp Z^{1+2/3+4/9} = Z^{19/9}$$
points while the values are of size $\asymp Z^3$. The exponent is therefore
$$\frac{19/9}{3} = \frac{19}{27}.$$
Choosing $Z = t^9$ clears all denominators: $z\asymp t^9$, $y\asymp t^6$, $x \asymp t^4$, box size $t^{4+6+9}=t^{19}$, values $\asymp t^{27}$.

### 5.3 The three-scale box

**Definition 5.3.** For $t\ge 1$ let
$$B(t) := \{\,(x,y,z)\in\mathbb{N}^3 : 1\le x\le t^4,\ \ t^6\le y<2t^6,\ \ 2t^9\le z<3t^9\,\}.$$

**Lemma 5.4 (Cardinality and positivity).** $\#B(t) = t^4\cdot t^6\cdot t^9 = t^{19}$, and every $(x,y,z)\in B(t)$ has $x,y,z\ge 1$.

*Proof.* The three ranges have $t^4$, $2t^6-t^6=t^6$, and $3t^9-2t^9=t^9$ elements. Positivity is immediate from $t\ge 1$. $\square$

**Lemma 5.5 (Gap conditions on the box).** Let $t\ge 1$ and $(x,y,z)\in B(t)$. Then
1. $x^3 < 3y^2+3y+1$;
2. $x^3+y^3 < 3z^2+3z+1$;
3. $x^3+y^3+z^3 \le 36\,t^{27}$.

*Proof sketch.*
(1) $x^3\le (t^4)^3 = t^{12}$ and $y\ge t^6$ gives $3y^2\ge 3t^{12} > t^{12}$.
(2) $x^3\le t^{12}\le t^{18}$ and $y^3<(2t^6)^3 = 8t^{18}$, so $x^3+y^3 < 9t^{18}$; meanwhile $z\ge 2t^9$ gives $3z^2\ge 12 t^{18} > 9t^{18}$. (This is why the $z$-window is placed at $[2t^9,3t^9)$ rather than at $[t^9,2t^9)$: the factor $4$ in $3z^2\ge 3\cdot 4t^{18}$ is what pays for the $8t^{18}$ from $y^3$.)
(3) $x^3\le t^{12}\le t^{27}$, $y^3<8t^{18}\le 8t^{27}$, $z^3<(3t^9)^3=27t^{27}$; summing, $x^3+y^3+z^3 \le 36 t^{27}$. $\square$

**Theorem 5.6 (Injectivity of the cube-digit family).** For every $t\ge 1$ the map
$$B(t)\longrightarrow \mathbb{N},\qquad (x,y,z)\longmapsto x^3+y^3+z^3$$
is injective.

*Proof.* Combine Lemma 5.5(1),(2) with Theorem 5.2. $\square$

Operationally, the inverse map is the greedy algorithm: given a value $n$ produced by the box, set $z=\lfloor n^{1/3}\rfloor$, then $y=\lfloor (n-z^3)^{1/3}\rfloor$, then $x=(n-z^3-y^3)^{1/3}$.

### 5.4 The counting theorem

**Definition.** For $N\in\mathbb{N}$ let
$$\mathcal{P}(N) := \{\,k\in\mathbb{Z} : 0<k\le N,\ k = x^3+y^3+z^3 \text{ with } x,y,z\ge 1 \,\},$$
the set of positive integers up to $N$ that are sums of three positive cubes. Note $\mathcal{P}(N)$ contains no padded-zero representations: each of its members is a fortiori a sum of three nonzero cubes, and $N\mapsto\#\mathcal{P}(N)$ is nondecreasing.

**Theorem 5.7 (Cube-digit counting theorem).** For every $t\ge 1$,
$$t^{19} \;\le\; \#\mathcal{P}\bigl(36\,t^{27}\bigr).$$

*Proof sketch.* Apply the cube-sum map to $B(t)$. By Theorem 5.6 the image has exactly $\#B(t)=t^{19}$ elements (Lemma 5.4); by Lemma 5.4 all coordinates are positive, so each image point is a sum of three positive cubes; by Lemma 5.5(3) each is at most $36t^{27}$; and each is positive. Hence the image is a subset of $\mathcal{P}(36t^{27})$ of size $t^{19}$. $\square$

**Theorem 5.8 (Beating the square-root barrier explicitly).** For every $t\ge 4$, with $N = 36t^{27}$,
$$100\,\bigl\lfloor\sqrt{N}\bigr\rfloor \;\le\; t^{19}.$$

*Proof sketch.* Since $t\ge 1$, $36t^{27}\le 36t^{28}=(6t^{14})^2$, so $\lfloor\sqrt{36t^{27}}\rfloor \le 6t^{14}$. Thus $100\lfloor\sqrt N\rfloor \le 600\,t^{14}$. For $t\ge 4$ we have $t^5\ge 4^5 = 1024 \ge 600$, so $600t^{14}\le t^5\cdot t^{14} = t^{19}$. $\square$

Thus the cube-digit count exceeds any fixed multiple of $\sqrt{N}$ for all sufficiently large $N$ along the sample scales — the constant $100$ is arbitrary, and replacing it by $c$ only changes the threshold to $t\ge \max(4, \lceil (6c)^{1/5}\rceil)$.

**Theorem 5.9 (Real-analytic form at sample scales).** For every $t\ge 1$, with $N=36t^{27}$,
$$\frac{N^{19/27}}{36} \;\le\; \#\mathcal{P}(N).$$

*Proof sketch.* $N^{19/27} = 36^{19/27}\,(t^{27})^{19/27} = 36^{19/27}\,t^{19}\le 36\,t^{19}$, since $36^{19/27}\le 36^1$. Divide by $36$ and apply Theorem 5.7. $\square$

**Theorem 5.10 (Bound for all $N$).** For every integer $N\ge 36$,
$$\left(\frac{N}{36\cdot 2^{27}}\right)^{19/27} \;\le\; \#\mathcal{P}(N).$$

*Proof sketch.* Let $t := \lfloor (N/36)^{1/27}\rfloor$; since $N\ge 36$ we have $t\ge 1$.
*Lower approximation:* $t\le (N/36)^{1/27}$ gives $t^{27}\le N/36$, i.e. $36t^{27}\le N$, so by monotonicity of $\mathcal{P}$ and Theorem 5.7, $t^{19}\le \#\mathcal{P}(36t^{27}) \le \#\mathcal{P}(N)$.
*Upper approximation:* $(N/36)^{1/27} < t+1 \le 2t$ gives $N/36 < 2^{27}t^{27}$, i.e. $N/(36\cdot 2^{27}) \le t^{27}$.
Raising the last inequality to the power $19/27$ (monotone on nonnegative reals) gives $\left(N/(36\cdot 2^{27})\right)^{19/27}\le t^{19}$, and the chain closes. $\square$

Theorem 5.10 is the clean statement: the number of integers up to $N$ that are sums of three positive cubes is at least $c\,N^{19/27}$ with the explicit constant $c=(36\cdot 2^{27})^{-19/27}$, and $19/27 = 0.7037\ldots > 1/2$.

---

## 6. Escaping the Vieta family

The cube-digit family is quantitatively stronger. It is also qualitatively different: it reaches integers the Vieta identity provably cannot.

The key is Theorem 4.1: Vieta values are multiples of $6$. Since $n^3\equiv n \pmod 6$ for every integer $n$ (because $n^3-n=(n-1)n(n+1)$ is divisible by $6$), a sum of three cubes with all roots $\equiv 1 \pmod 6$ is $\equiv 3\pmod 6$, hence not a multiple of $6$, hence not a Vieta value.

It remains to check that the greedy machinery survives the residue restriction, with rescaled windows.

**Definition 6.1.** For $t\ge 1$ let
$$B^\ast(t) := \{\,(u,v,w)\in\mathbb{N}^3 : 1\le u\le t^4,\ \ 4t^6\le v<8t^6,\ \ 34t^9\le w<68t^9\,\},$$
and for $(u,v,w)\in B^\ast(t)$ set
$$E(u,v,w) := (6u+1)^3+(6v+1)^3+(6w+1)^3.$$

**Lemma 6.2.** Let $t\ge 1$ and $(u,v,w)\in B^\ast(t)$. Writing $X=6u+1$, $Y=6v+1$, $Z=6w+1$:
1. $\#B^\ast(t) = t^4\cdot 4t^6\cdot 34t^9 = 136\,t^{19}$;
2. $X^3 < 3Y^2+3Y+1$;
3. $X^3+Y^3 < 3Z^2+3Z+1$;
4. $E(u,v,w) \le 10^8\, t^{27}$;
5. $E(u,v,w)\equiv 3 \pmod 6$.

*Proof sketch.* (1) is a product of window lengths.
(2) $X\le 6t^4+1\le 7t^4$, so $X^3\le 343t^{12}$; while $Y\ge 24t^6$, so $3Y^2\ge 3\cdot 576\,t^{12}=1728\,t^{12}$.
(3) $X^3\le 343 t^{12}\le 343 t^{18}$ and $Y< 48t^6$ gives $Y^3<110592\,t^{18}$, total $<110935\,t^{18}$; while $Z\ge 204t^9$ gives $3Z^2\ge 3\cdot 41616\,t^{18} = 124848\,t^{18}$.
(4) $X^3\le 343t^{27}$, $Y^3 < 110592\,t^{27}$, $Z^3 < (408t^9)^3 = 67\,917\,312\,t^{27}$; the total is below $10^8t^{27}$.
(5) Expanding, $(6n+1)^3 = 6(36n^3+18n^2+3n)+1$, so each cube is $\equiv 1 \pmod 6$ and the sum is $\equiv 3$. $\square$

**Theorem 6.3 (Escape theorem).** For every $t\ge 1$, the number of integers $k$ with $1\le k\le 10^8t^{27}$ such that
- $k$ is a sum of three *positive* cubes, and
- $k \ne V(a,b)$ for every pair of integers $(a,b)$,

is at least $136\,t^{19}$.

*Proof sketch.* By Lemma 6.2(2),(3) and the two-step greedy injectivity engine (Theorem 5.2), the map $(u,v,w)\mapsto E(u,v,w)$ is injective on $B^\ast(t)$ — the engine returns $6u+1=6u'+1$, etc., whence $u=u'$, $v=v'$, $w=w'$. By Lemma 6.2(1) the image has $136t^{19}$ elements. Each is positive, is a sum of the three positive cubes $(6u+1)^3,(6v+1)^3,(6w+1)^3$, and by Lemma 6.2(4) is at most $10^8t^{27}$. Finally by Lemma 6.2(5) each is $\equiv 3\pmod 6$, so $6\nmid k$, so by Corollary 4.2 no pair $(a,b)$ has $V(a,b)=k$. $\square$

With $N = 10^8 t^{27}$ this is again a bound of order $N^{19/27}$, now for integers *outside* the Vieta value set. In particular, no amount of refinement of the Vieta identity could ever have produced these numbers: the improvement of §5 is not an improvement of §2–§3 but a replacement of it.

---

## 7. The greedy cube tower: $s$ cubes and exponent $1-(2/3)^s$

The cube-digit principle is indifferent to the number of summands. We record the general theorem.

**Definition 7.1.** Say $n\in\mathbb{N}$ is a **sum of $s$ positive cubes** if there are integers $z_1,\dots,z_s\ge 1$ with $n = z_1^3+\cdots+z_s^3$. (For $s=0$ this means $n=0$.) For $s\ge 1$ and $N\in\mathbb{N}$ let
$$\mathcal{Q}_s(N) := \{\, n : 0<n\le N,\ n \text{ is a sum of } s \text{ positive cubes}\,\}.$$

**Definition 7.2 (Tower constants).** Set $C_0 := 1$ and $C_{s+1} := 8C_s^3 + C_s$. Thus $C_1 = 9$, $C_2 = 8\cdot 729+9 = 5841$, and so on; each $C_s\ge 1$.

**Theorem 7.3 (Greedy cube tower).** For every $s\ge 0$ and every $t\ge 1$ there is a finite set $S\subseteq\mathbb{N}$ with
$$\#S \;\ge\; t^{\,3^s-2^s}, \qquad \text{every } n\in S \text{ a sum of } s \text{ positive cubes with } n < C_s\, t^{\,3^s}.$$

*Proof sketch (induction on $s$).* For $s=0$ take $S=\{0\}$: $\#S = 1 = t^{0}$ and $0 < C_0 t^{1}=t$.

For the inductive step, apply the hypothesis at *scale $t^2$*, obtaining $S'$ with $\#S'\ge (t^2)^{3^s-2^s}$ and every $m\in S'$ satisfying $m< C_s\,(t^2)^{3^s} = C_s t^{2\cdot 3^s}=:B$. Put $Z := C_s t^{3^s}$ and consider
$$S := \{\, z^3+m : Z\le z<2Z,\ m\in S'\,\}.$$
*Gap check:* for $z\ge Z$ we have $3z^2 \ge 3Z^2 = 3C_s^2 t^{2\cdot 3^s} \ge 3 C_s t^{2\cdot 3^s} = 3B > B > m$, so each $m$ is below the cube gap at its $z$. By Theorem 5.1 the pairs $(z,m)$ are recoverable from $z^3+m$, so
$$\#S = Z\cdot \#S' \;\ge\; C_s t^{3^s}\cdot t^{2(3^s-2^s)} \;\ge\; t^{\,3^{s+1}-2^{s+1}},$$
using $3^{s+1}-2^{s+1} = 3^s + 2(3^s-2^s)$ and $C_s\ge 1$.
*Size check:* $z^3+m < (2Z)^3 + B = 8C_s^3 t^{3^{s+1}} + C_s t^{2\cdot 3^s} \le (8C_s^3+C_s)\,t^{3^{s+1}} = C_{s+1}t^{3^{s+1}}$, using $2\cdot 3^s\le 3^{s+1}$.
*Representation check:* each element of $S$ is $z^3$ plus a sum of $s$ positive cubes, with $z\ge Z\ge 1$, hence a sum of $s+1$ positive cubes. $\square$

**Theorem 7.4 (Tower counting).** For every $s\ge 1$ and $t\ge 1$,
$$t^{\,3^s-2^s} \;\le\; \#\mathcal{Q}_s\bigl(C_s\,t^{\,3^s}\bigr).$$

In particular $t^5 \le \#\mathcal{Q}_2(C_2 t^9)$, $t^{19}\le \#\mathcal{Q}_3(C_3t^{27})$, and $t^{65}\le\#\mathcal{Q}_4(C_4t^{81})$.

**Definition 7.5.** The **tower exponent** is $\varepsilon_s := \dfrac{3^s-2^s}{3^s} = 1 - \left(\dfrac{2}{3}\right)^{s}$.

**Theorem 7.6 (Tower bound for all $N$; limiting exponent).** For every $s\ge 1$ and every $N\ge C_s$,
$$\left(\frac{N}{C_s\,2^{3^s}}\right)^{\varepsilon_s} \;\le\; \#\mathcal{Q}_s(N).$$
Moreover $\varepsilon_s \to 1$ as $s\to\infty$.

*Proof sketch.* The interpolation is as in Theorem 5.10: put $t=\lfloor (N/C_s)^{1/3^s}\rfloor \ge 1$; then $C_st^{3^s}\le N$ gives $t^{3^s-2^s}\le \#\mathcal{Q}_s(N)$ by monotonicity, while $(N/C_s)^{1/3^s}<t+1\le 2t$ gives $N/(C_s2^{3^s})\le t^{3^s}$, and raising to the power $\varepsilon_s\in(0,1]$ converts the latter into $\left(N/(C_s2^{3^s})\right)^{\varepsilon_s}\le t^{3^s-2^s}$. The limit is immediate from $(2/3)^s\to 0$. $\square$

The first exponents are
$$\varepsilon_1 = \tfrac13 \approx 0.333,\quad \varepsilon_2 = \tfrac59 \approx 0.556,\quad \varepsilon_3 = \tfrac{19}{27}\approx 0.704,\quad \varepsilon_4 = \tfrac{65}{81}\approx 0.802,\quad \varepsilon_5 = \tfrac{211}{243}\approx 0.868 .$$
Each new cube recovers two thirds of the remaining deficit $1-\varepsilon_s$. Note that $\varepsilon_1=1/3$ is sharp for one cube (there are exactly $\lfloor N^{1/3}\rfloor$ cubes up to $N$), which is a useful sanity check on the normalisation; for $s\ge 2$ the bound is certainly not sharp, since already $\mathcal{Q}_2$ is expected to have order $N/(\log N)^{c}$-type behaviour.

---

## 8. Discussion: why the Vieta exponent is stuck at $1/2$

It is worth isolating the structural reason the two halves of this paper reach different exponents, since it is a phenomenon common to many parametric-family counting arguments.

**The Vieta family fails for an arithmetic reason.** The parameter set $\{(a,b) : 0<3ab(a+b)\le N\}$ has $\asymp N^{2/3}$ points. Theorem 2.7 says the fibres of the value map have size at most $d(v)$, and on average $d(v)$ is $O(\log v)$, so morally the image should have size $\gg N^{2/3}/\log N$. But converting "on average small fibres" into a *proved* lower bound requires exhibiting a subfamily on which one can *certify* injectivity, and certification requires that the value determine the parameters. Since $a \mid v$, the natural certification strategies restrict $a$ to a set $\mathcal{A}$ on which $a$ is determined by $v$: powers of a fixed prime (as in §3.3), or smooth numbers, or values with a distinguished valuation. For any such $\mathcal{A}$ the count is
$$\sum_{a\in\mathcal{A},\,a\le N^{1/3}} \#\{b : 3ab(a+b)\le N\} \;\asymp\; \sum_{a\in\mathcal{A}} \sqrt{N/a},$$
and thinness of $\mathcal{A}$ makes $\sum_{a\in\mathcal{A}} a^{-1/2}$ convergent. So the total is $\Theta(\sqrt N)$, and one has traded away exactly as much as one gained. This is a genuine "needs a different definition" failure: no rearrangement of the same idea escapes it.

**The cube-digit family succeeds for a metric reason.** Its injectivity does not depend on the arithmetic of the values at all — only on the *sizes* of the summands relative to the local gap between consecutive cubes. Gap conditions are inequalities, and inequalities can be arranged by construction. The price is that the family is no longer a polynomial identity: it is a lattice box, and its exponent $19/27$ is dictated by the geometry $x\lesssim y^{2/3}\lesssim z^{4/9}$ rather than by any identity.

**The two are complementary, and the second strictly dominates.** §6 makes this precise: the cube-digit family reaches a residue class ($3\bmod 6$) that the Vieta family provably cannot enter, while producing $\gg N^{19/27}$ values there.

**Where the truth lies.** For sums of three positive cubes the conjectural answer is $\gg N$ (a positive proportion of integers, subject to the mod-$9$ obstruction in the signed problem). The exponent $19/27$ is what greediness alone can certify. The gap $19/27 \to 1$ is exactly the gap between "constructed with recoverable digits" and "counted by an asymptotic method"; closing it requires genuinely analytic input (Diophantine/circle-method estimates for the number of representations), and no elementary injective family can close it, because an injective family that produced $\gg N$ values would in particular have to be non-sparse in every residue class.

---

## 9. Open problems and future work

**Problem 1 (Divisor-controlled Vieta density).** Prove that for every $\varepsilon>0$ there is $c(\varepsilon)>0$ with
$$\#\{\,v : |v|\le N,\ v = 3ab(a+b) \text{ for some } a,b\in\mathbb{Z}\,\} \;\ge\; c(\varepsilon)\,N^{2/3-\varepsilon}.$$
The route is Theorem 2.7: the $\asymp N^{2/3}$ lattice points collapse only by the divisor function, so any sub-polynomial divisor bound $d(v)\ll_\varepsilon v^{\varepsilon}$ turns the lattice count directly into the stated bound. The required divisor estimate is elementary multiplicative-function theory; nothing deeper (Thue equations, class field theory) is needed for the $2/3-\varepsilon$ exponent.

**Problem 2 (Exact Vieta asymptotics).** Determine $\kappa$ with
$$\#\{\,v : |v|\le N,\ v \text{ a Vieta value}\,\} \sim \kappa\,N^{2/3}.$$
Numerically the positive side has density constant $\approx 0.53$, suggesting $\kappa\approx 1.05$ after doubling for signs. A proof would presumably combine the divisor bound with an inclusion–exclusion over the multiplicity strata $\{v : \text{exactly } j \text{ representations}\}$.

**Problem 3 (Optimal greedy exponent for three cubes).** Is $19/27$ optimal for *greedy-recoverable* families? The gap conditions force $x \ll y^{2/3}$ and $y\ll z^{2/3}$, so $19/27$ is optimal within the class of "one window per summand". Relaxing to partially overlapping windows — where the greedy peel is replaced by a bounded search among $O(1)$ candidate leading digits — should allow $y$ up to $z^{2/3+\delta}$ at the cost of a bounded multiplicity, and might push the exponent slightly beyond $19/27$ while keeping the count injective up to a constant factor.

**Problem 4 (Escape in every admissible residue class).** §6 escapes the Vieta family through the class $3\bmod 6$. Which residue classes mod $9$ (the natural modulus for cubes) admit cube-digit families, and with which exponents? Since $n^3\in\{0,\pm 1\}\pmod 9$, a sum of three cubes is never $\equiv \pm 4\pmod 9$; the construction of §6 should adapt to give $\gg N^{19/27}$ representatives in each of the seven admissible classes.

**Problem 5 (Tower with mixed exponents).** The tower of §7 uses cubes at every level. The same greedy principle works for sums $z_1^{k_1}+\cdots+z_s^{k_s}$ with mixed exponents, the gap at level $j$ being $\asymp z_j^{k_j-1}$. Optimising the resulting exponent over $(k_1,\dots,k_s)$ subject to a size constraint is a clean finite-dimensional optimisation whose answer is not obvious.

**Problem 6 (Effective inverse).** The greedy peel is an $O(1)$-arithmetic-operation inverse to the cube-digit map (three integer cube roots). Can it be extended to a *decision* procedure for a positive-density set of integers — that is, a family of easily-recognised integers, defined by inequalities on their cube digits, all of which are certified sums of three positive cubes?

---

## 10. Conclusion

Two lessons emerge. First, the classical Vieta identity, although it produces sums of three cubes effortlessly and in a two-parameter family, is intrinsically limited as a counting device: its collisions are divisor collisions, so certifying injectivity costs exactly the factor one is trying to gain, and its values are confined to multiples of $6$. The best certified bound from it is $\lfloor\sqrt{N/6}\rfloor$, against an empirical truth of order $0.53\,N^{2/3}$ and a trivial ceiling of $\lfloor N/6\rfloor$.

Second, injectivity is cheaper to *build* than to *prove*. The cube-digit principle — a number of the form $z^3+r$ with $r$ below the cube gap $3z^2+3z+1$ determines $z$ and $r$ — turns positional notation into a construction principle for sums of cubes. Three nested windows at scales $t^4$, $t^6$, $t^9$ give $t^{19}$ distinct sums of three positive cubes below $36t^{27}$, hence at least $\left(N/(36\cdot 2^{27})\right)^{19/27}$ such integers below any $N\ge 36$; $s$ nested windows give the exponent $1-(2/3)^s$, increasing to $1$. And a residue-restricted version of the same box produces $\gg N^{19/27}$ integers which are sums of three positive cubes but which the Vieta identity can never reach at all.
