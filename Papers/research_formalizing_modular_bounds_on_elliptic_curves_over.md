# Exact Point Counts, Modular Invariants, and Moments for Short Weierstrass Families over Finite Fields

**Aristotle**

**Date:** 2026-08-09

---

## Abstract

Let $F$ be a finite field of odd characteristic with $q = \#F$ elements, and for $a,b \in F$ let $E_{a,b}$ denote the projective curve $y^2 = x^3 + ax + b$, counted as the affine solution set together with one point at infinity. We develop a purely elementary theory of the point count $\#E_{a,b}(F)$ built on a single observation: the number of square roots of $c \in F$ equals $\chi(c)+1$, where $\chi$ is the quadratic character of $F$. From this we obtain the exact counting formula $\#E_{a,b}(F) = q + 1 + S(a,b)$ with $S(a,b) = \sum_{x} \chi(x^3+ax+b)$, and hence the identification $a(a,b) := q+1-\#E_{a,b}(F) = -S(a,b)$ of the trace of Frobenius with a character sum.

We then prove, entirely within this framework: (i) a **2-torsion parity criterion**, namely that for a nonsingular curve the point count is even precisely when the cubic $x^3+ax+b$ has a root in $F$, together with the supporting **$0/1/3$ root dichotomy** that a nonsingular short Weierstrass cubic never has exactly two roots; (ii) **exact point counts for two supersingular families** — $\#E_{0,b}(F) = q+1$ for all $b$ when cubing is bijective (e.g. $p \equiv 2 \bmod 3$), yielding $3 \mid \#E$, and $\#E_{a,0}(F) = q+1$ for all $a$ when $\chi(-1)=-1$ (e.g. $p \equiv 3 \bmod 4$), yielding $4 \mid \#E$; (iii) the **twisting identity** $\#E_{a,b}(F) + \#E_{ad^2,bd^3}(F) = 2q+2$ for a nonsquare $d$; (iv) the **vanishing first moment** $\sum_{a,b} a(a,b) = 0$, equivalently the exact family total $\sum_{a,b} \#E_{a,b}(F) = q^2(q+1)$; (v) the **exact second moment** $\sum_{a,b} a(a,b)^2 = q^3 - q^2$, with its Chebyshev consequence $K \cdot \#\{(a,b) : a(a,b)^2 \ge K\} \le q^3-q^2$ and the existence of a curve with $a(a,b)^2 \ge q-1$; (vi) **exact vertical second moments** $\sum_b a(0,b)^2 = q(q-1)(1+\chi(-3))$ and $\sum_b a(a,b)^2 = q^2 - q(1+\chi(-3)+\chi(-a/3))$ for $a \ne 0$, when $\operatorname{char} F \nmid 6$; and (vii) a **cubic/quadratic bridge**, that cubing is bijective on $F$ if and only if $\chi(-3) = -1$, which over a prime field recovers the supplementary reciprocity law for $-3$.

The exact second moment gives Hasse's bound "on average" — for every $\lambda > 0$ at most a $\lambda^{-2}$ fraction of the family has $|a(a,b)| \ge \lambda\sqrt{q}$ — by an argument that uses no Weil conjectures, no Riemann–Roch, and no Jacobian. We record what the method does *not* reach (a pointwise Hasse bound), verify that bound exhaustively for $q \le 13$, and outline a moment-ladder route towards it.

**Keywords.** Elliptic curve, finite field, quadratic character, character sum, trace of Frobenius, supersingular, moment method, quadratic reciprocity.

---

## 1. Introduction

The number of points of an elliptic curve over a finite field is the fundamental arithmetic invariant of the curve. Hasse's theorem asserts that for a nonsingular curve over $\mathbb{F}_q$,
$$\bigl|\, \#E(\mathbb{F}_q) - (q+1) \,\bigr| \le 2\sqrt{q},$$
and the proof normally proceeds through the endomorphism ring of the curve, the Frobenius endomorphism acting on the Jacobian, and the Cauchy–Schwarz-type positivity of the degree pairing — machinery of substantial weight.

The purpose of this paper is to see how far one can get with none of that. The starting point is the elementary counting identity
$$\#\{y \in F : y^2 = c\} = \chi(c)+1,$$
where $\chi$ is the quadratic character. This turns point counting into character-sum evaluation, and a surprisingly rich body of exact results follows: exact counts for entire supersingular families, exact divisibility invariants depending only on $q \bmod 3$ and $q \bmod 4$, an exact parity criterion, an exact global second moment, and exact vertical second moments refined by the value of $\chi(-3)$.

The methodological theme is that **the wobble of the point count around $q+1$ is a character sum, and character sums of low-degree polynomials are computable in closed form**. Degree $1$ and degree $2$ are elementary; degree $3$ — the elliptic case — is exactly where the elementary method stops giving pointwise information. But *averages* of degree-$3$ sums reduce, by exchanging the order of summation, back to degree-$2$ sums, and so are computable. That reduction is the engine of §5 and §6.

### Organization

§2 fixes notation and derives the counting formula. §3 treats parity, 2-torsion, and the root dichotomy. §4 treats supersingular families, twisting, and the resulting modular invariants over prime fields. §5 computes the exact second moment and its Chebyshev consequences. §6 computes all quadratic character sums, counts the relevant conic, and derives the exact vertical moments and the cubic/quadratic bridge. §7 reports exhaustive computations over small prime fields. §8 discusses the boundary of the method and future directions.

---

## 2. Setup and the Counting Formula

Throughout, $F$ is a finite field with $q = \#F$ and $\operatorname{char} F \ne 2$.

**Definition 2.1 (Quadratic character).** The quadratic character $\chi : F \to \{-1,0,1\}$ is defined by $\chi(0)=0$, $\chi(c) = 1$ if $c$ is a nonzero square, and $\chi(c) = -1$ otherwise. It is multiplicative: $\chi(cd) = \chi(c)\chi(d)$, and $\sum_{c \in F} \chi(c) = 0$.

**Definition 2.2 (The family).** For $a, b \in F$ put $f_{a,b}(x) = x^3 + ax + b$. The *affine locus* is
$$A_{a,b} = \{(x,y) \in F^2 : y^2 = f_{a,b}(x)\},$$
and the *point count* is $\#E_{a,b} = \#A_{a,b} + 1$ (adjoining the point at infinity). The *trace of Frobenius* is
$$a(a,b) = q + 1 - \#E_{a,b},$$
the *character sum* is
$$S(a,b) = \sum_{x \in F} \chi(f_{a,b}(x)),$$
the *root set* is $R_{a,b} = \{x \in F : f_{a,b}(x) = 0\}$, and the *discriminant quantity* is
$$\Delta(a,b) = 4a^3 + 27b^2,$$
whose vanishing is equivalent to $f_{a,b}$ having a repeated root in the algebraic closure. We call the curve *nonsingular* when $\Delta(a,b) \ne 0$.

**Lemma 2.3 (Square-root count).** For every $c \in F$, $\#\{y \in F : y^2 = c\} = \chi(c) + 1$.

*Proof sketch.* If $c = 0$ the unique root is $y=0$ and $\chi(0)+1 = 1$. If $c \ne 0$ and $c = e^2$, the roots are $\pm e$, distinct since $\operatorname{char} F \ne 2$, and $\chi(c)+1 = 2$. If $c$ is a nonsquare there are no roots and $\chi(c)+1 = 0$. $\square$

**Theorem 2.4 (Counting Formula).** For all $a,b \in F$,
$$\#A_{a,b} = q + S(a,b), \qquad \#E_{a,b} = q + 1 + S(a,b), \qquad a(a,b) = -S(a,b).$$

*Proof sketch.* Partition $A_{a,b}$ by the value of $x$. By Lemma 2.3 the fibre over $x$ has $\chi(f_{a,b}(x))+1$ elements; summing over the $q$ values of $x$ gives $\#A_{a,b} = q + S(a,b)$. The remaining two equalities are definitional rearrangements. $\square$

Theorem 2.4 is the only bridge we need between geometry and analysis; everything below is a statement about $S$.

---

## 3. Parity, 2-Torsion, and the Root Dichotomy

**Lemma 3.1 (Parity of the character sum).** For all $a,b$,
$$S(a,b) \equiv q - \#R_{a,b} \pmod 2.$$

*Proof sketch.* Term by term: $\chi(f_{a,b}(x))$ is $0$ when $x \in R_{a,b}$ and $\pm 1$ otherwise, and $\pm 1 \equiv 1 \pmod 2$. Hence $S(a,b)$ is congruent mod $2$ to the number of $x \notin R_{a,b}$, which is $q - \#R_{a,b}$. $\square$

**Corollary 3.2.** $\#E_{a,b} \equiv 1 + \#R_{a,b} \pmod 2$.

*Proof sketch.* Combine Theorem 2.4 with Lemma 3.1: $\#E_{a,b} = q+1+S(a,b) \equiv q+1+q-\#R_{a,b} \equiv 1 + \#R_{a,b} \pmod 2$. $\square$

The parity criterion now requires only the following purely algebraic fact.

**Lemma 3.3 (Two roots determine the coefficients).** If $r \ne s$ and $f_{a,b}(r) = f_{a,b}(s) = 0$, then
$$a = -(r^2+rs+s^2), \qquad b = rs(r+s),$$
and consequently, for all $u$,
$$f_{a,b}(u) = (u-r)(u-s)(u+r+s).$$

*Proof sketch.* Subtracting the two vanishing conditions gives $(r-s)(r^2+rs+s^2+a) = 0$; since $r \ne s$ the second factor vanishes, determining $a$. Substituting back into $f_{a,b}(r)=0$ determines $b$. The factorization is then verified by expansion. $\square$

**Theorem 3.4 (0/1/3 dichotomy).** If $\Delta(a,b) \ne 0$ then $\#R_{a,b} \in \{0,1,3\}$.

*Proof sketch.* If $\#R_{a,b} \ge 2$, choose distinct roots $r,s$. By Lemma 3.3 the cubic factors as $(u-r)(u-s)(u+r+s)$, so $R_{a,b} = \{r, s, -(r+s)\}$. It remains to see the third root is distinct from the first two. If $r = -(r+s)$ then $s = -2r$, and substituting into $\Delta = 4a^3+27b^2$ with $a,b$ as in Lemma 3.3 gives $\Delta(a,b) = 0$, contradicting nonsingularity; the case $s = -(r+s)$ is symmetric. Hence exactly three distinct roots. $\square$

**Theorem 3.5 (2-torsion criterion).** If $\Delta(a,b) \ne 0$ then
$$2 \mid \#E_{a,b} \iff \exists x \in F,\ x^3+ax+b = 0.$$

*Proof sketch.* By Corollary 3.2, $\#E_{a,b}$ is even iff $\#R_{a,b}$ is odd. By Theorem 3.4, $\#R_{a,b} \in \{0,1,3\}$, so $\#R_{a,b}$ is odd iff $\#R_{a,b} \ne 0$, i.e. iff the cubic has a root. $\square$

Geometrically, a root $r$ gives the point $(r,0)$, which equals its own inverse in the group law and hence has order $2$; the theorem says that the presence of such a point is not merely sufficient but necessary for even order.

**Remark 3.6 (Sharpness).** Nonsingularity cannot be dropped in Theorem 3.4 or Theorem 3.5. Over $F = \mathbb{F}_5$ take $(a,b) = (2,2)$. Then $\Delta(2,2) = 4\cdot 8 + 27 \cdot 4 = 140 \equiv 0$, the cubic factors as $x^3+2x+2 = (x-1)^2(x+2)$ and has exactly the two distinct roots $\{1,3\}$ — the value excluded by Theorem 3.4 — while the point count is $7$, odd, despite a root existing.

---

## 4. Supersingular Families, Twisting, and Modular Invariants

### 4.1 The cube family

**Theorem 4.1.** If $x \mapsto x^3$ is a bijection of $F$, then $S(0,b) = 0$ for every $b \in F$, hence $\#E_{0,b} = q+1$ and $a(0,b) = 0$.

*Proof sketch.* Reindex: $S(0,b) = \sum_x \chi(x^3+b) = \sum_t \chi(t+b)$ by bijectivity of cubing, $= \sum_u \chi(u) = 0$ by translation invariance of the index set and $\sum_{u}\chi(u)=0$. $\square$

**Lemma 4.2.** If $\gcd(q-1, 3) = 1$ then $x \mapsto x^3$ is a bijection of $F$.

*Proof sketch.* On the cyclic group $F^\times$ of order $q-1$, the map $u \mapsto u^3$ is bijective when $3$ is coprime to the group order; and $0 \mapsto 0$. Injectivity on all of $F$ follows, and injectivity implies bijectivity on a finite set. $\square$

**Corollary 4.3 (Modular invariant mod 3).** Let $p > 2$ be a prime with $p \equiv 2 \pmod 3$. Then for every $b \in \mathbb{F}_p$, the curve $y^2 = x^3+b$ has exactly $p+1$ points and $a(0,b) = 0$; in particular $3 \mid \#E_{0,b}$.

*Proof sketch.* $p \equiv 2 \bmod 3$ gives $3 \nmid p-1$, so Lemma 4.2 and Theorem 4.1 apply and $\#E_{0,b} = p+1 \equiv 0 \pmod 3$. $\square$

### 4.2 The linear family

**Theorem 4.4.** If $\chi(-1) = -1$ then $S(a,0) = 0$ for every $a \in F$, hence $\#E_{a,0} = q+1$ and $a(a,0)=0$.

*Proof sketch.* The polynomial $f_{a,0}(x) = x^3+ax$ is odd: $f_{a,0}(-x) = -f_{a,0}(x)$. Hence $\chi(f_{a,0}(-x)) = \chi(-1)\chi(f_{a,0}(x)) = -\chi(f_{a,0}(x))$. Summing over $x$ and using that $x \mapsto -x$ permutes $F$ yields $S(a,0) = -S(a,0)$, so $S(a,0)=0$. $\square$

**Corollary 4.5 (Modular invariant mod 4).** Let $p$ be a prime with $p \equiv 3 \pmod 4$. Then for every $a \in \mathbb{F}_p$, the curve $y^2 = x^3+ax$ has exactly $p+1$ points and $a(a,0) = 0$; in particular $4 \mid \#E_{a,0}$.

*Proof sketch.* For $p \equiv 3 \bmod 4$, $-1$ is a nonsquare mod $p$, so $\chi(-1)=-1$ and Theorem 4.4 applies; $p+1 \equiv 0 \pmod 4$. $\square$

**Remark 4.6.** For $a \ne 0$ the curve $y^2 = x^3+ax$ always has the $2$-torsion point $(0,0)$, so by Theorem 3.5 its point count is even for every odd $p$ — consistent with, but weaker than, Corollary 4.5.

**Remark 4.7 (Necessity of the congruences).** These are genuine congruence conditions, not artifacts. Over $\mathbb{F}_{13}$, which is $1 \bmod 3$ and $1 \bmod 4$, the curves $y^2 = x^3+1$ and $y^2 = x^3+2$ have $12$ and $19$ points respectively.

### 4.3 Quadratic twisting

**Theorem 4.8 (Twisting).** Let $d \in F$ with $\chi(d) = -1$. Then for all $a,b$,
$$S(ad^2, bd^3) = -S(a,b), \qquad a(ad^2, bd^3) = -a(a,b), \qquad \#E_{a,b} + \#E_{ad^2,bd^3} = 2q+2.$$

*Proof sketch.* The substitution $x = du$ gives $f_{ad^2,bd^3}(du) = d^3 f_{a,b}(u)$, and $\chi(d^3) = \chi(d)^3 = -1$. As $u$ ranges over $F$ so does $du$, so $S(ad^2,bd^3) = \sum_u \chi(d^3 f_{a,b}(u)) = -S(a,b)$. The trace and point-count statements follow from Theorem 2.4. $\square$

**Corollary 4.9 (Vanishing first moment).** For every $a \in F$, $\sum_{b \in F} S(a,b) = 0$; hence $\sum_{a}\sum_b a(a,b) = 0$ and
$$\sum_{a,b \in F} \#E_{a,b} = q^2(q+1).$$

*Proof sketch.* Exchange the order of summation: $\sum_b S(a,b) = \sum_x \sum_b \chi(x^3+ax+b)$, and for fixed $x$ the inner sum is $\sum_b \chi(c+b)$ over a full translation of $F$, hence $\sum_u \chi(u) = 0$. The family total follows from $\#E_{a,b} = q+1-a(a,b)$. $\square$

Thus the *average* curve in the family has exactly $q+1$ points.

---

## 5. The Exact Second Moment

The vanishing first moment says nothing about the size of the fluctuation. The second moment does, and it can be computed exactly.

**Lemma 5.1 (Sum of a shifted product).** Let $\operatorname{char} F \ne 2$ and $w \ne 0$. Then
$$\sum_{c \in F} \chi\bigl(c(c+w)\bigr) = -1.$$

*Proof sketch.* The $c=0$ term vanishes. For $c \ne 0$, factor $c(c+w) = c^2(1 + wc^{-1})$ and use $\chi(c^2)=1$, so the sum equals $\sum_{c \ne 0}\chi(1 + wc^{-1})$. The map $c \mapsto 1 + wc^{-1}$ is a bijection from $F \setminus \{0\}$ onto $F \setminus \{1\}$ (with inverse $t \mapsto w(t-1)^{-1}$), so the sum is $\sum_{t \ne 1}\chi(t) = 0 - \chi(1) = -1$. $\square$

**Lemma 5.2 (Two-shift correlation).** For $u, v \in F$,
$$\sum_{b \in F}\chi\bigl((b+u)(b+v)\bigr) = \begin{cases} q-1, & u = v,\\ -1, & u \ne v.\end{cases}$$

*Proof sketch.* Substituting $b = c - u$ reduces to $\sum_c \chi(c(c + (v-u)))$. If $u = v$ this is $\sum_c \chi(c^2) = q-1$ (the value is $1$ for all $c \ne 0$ and $0$ at $c=0$). If $u \ne v$, apply Lemma 5.1 with $w = v-u \ne 0$. $\square$

**Definition 5.3 (Collision count).** For $a \in F$ put
$$N(a) = \#\{(x,y) \in F^2 : x^3+ax = y^3+ay\}.$$

**Proposition 5.4 (Vertical moment via collisions).** For all $a \in F$,
$$\sum_{b \in F} S(a,b)^2 = q\,N(a) - q^2.$$

*Proof sketch.* Expand $S(a,b)^2 = \sum_{x}\sum_y \chi\bigl(f_{a,b}(x) f_{a,b}(y)\bigr)$ and exchange summation so that $b$ is summed innermost. Writing $u = x^3+ax$ and $v = y^3+ay$, we have $f_{a,b}(x)f_{a,b}(y) = (b+u)(b+v)$, so Lemma 5.2 gives the inner sum as $q-1$ when $u=v$ and $-1$ otherwise. Hence
$$\sum_b S(a,b)^2 = \sum_{(x,y)} \bigl(-1 + q\cdot \mathbb{1}[u=v]\bigr) = -q^2 + q N(a). \qquad \square$$

**Lemma 5.5 (Horizontal correlation).** For $x, y \in F$,
$$\sum_{a \in F}\Bigl(-1 + q\,\mathbb{1}\bigl[x^3+ax = y^3+ay\bigr]\Bigr) = \begin{cases} q^2 - q, & x = y,\\ 0, & x \ne y.\end{cases}$$

*Proof sketch.* If $x = y$ the indicator is always $1$ and the sum is $q(q-1)$. If $x \ne y$, the condition $x^3+ax = y^3+ay$ factors as $(x-y)(x^2+xy+y^2+a) = 0$, so it holds for exactly one value of $a$, namely $a = -(x^2+xy+y^2)$. The sum is then $-q + q\cdot 1 = 0$. $\square$

**Theorem 5.6 (Exact second moment).** Let $\operatorname{char} F \ne 2$. Then
$$\sum_{a \in F}\sum_{b \in F} S(a,b)^2 = q^3 - q^2, \qquad \text{equivalently} \qquad \sum_{a,b} a(a,b)^2 = q^3 - q^2.$$

*Proof sketch.* By the proof of Proposition 5.4,
$$\sum_a \sum_b S(a,b)^2 = \sum_x \sum_y \sum_a \bigl(-1 + q\,\mathbb{1}[x^3+ax=y^3+ay]\bigr).$$
By Lemma 5.5 the innermost double sum contributes $q^2-q$ when $x=y$ and $0$ otherwise, so the total is $q \cdot (q^2-q) = q^3-q^2$. Since $a(a,b) = -S(a,b)$, the squares agree. $\square$

Dividing by the number $q^2$ of parameter pairs, the mean square of the trace of Frobenius over the family is *exactly* $q-1$ — an identity with no error term, matching the square-root heuristic precisely.

**Theorem 5.7 (Chebyshev / Hasse on average).** For every $K \in \mathbb{Z}$,
$$K \cdot \#\{(a,b) \in F^2 : a(a,b)^2 \ge K\} \le q^3 - q^2.$$

*Proof sketch.* On the set $T$ of pairs with $a(a,b)^2 \ge K$ we have $K\,\#T \le \sum_{T} a(a,b)^2$; since every term is nonnegative this is at most the full sum, which is $q^3-q^2$ by Theorem 5.6. $\square$

**Corollary 5.8.** For every $\lambda > 0$, the number of pairs $(a,b)$ with $|a(a,b)| \ge \lambda\sqrt{q}$ is at most $q^2/\lambda^2$. In particular, taking $\lambda = 2$, at most a quarter of the family could violate the Hasse bound; and the proportion violating $|a| \ge \lambda \sqrt q$ tends to $0$ as $\lambda \to \infty$, uniformly in $q$.

**Theorem 5.9 (Extremal existence).** There exist $a,b \in F$ with $a(a,b)^2 \ge q-1$.

*Proof sketch.* If every term satisfied $a(a,b)^2 \le q-2$, then the total would be at most $q^2(q-2) = q^3-2q^2 < q^3-q^2$, contradicting Theorem 5.6. $\square$

Combined with Hasse's theorem, the extremal trace in the family therefore lies between $\sqrt{q-1}$ and $2\sqrt q$: the second moment alone pins the size of the largest fluctuation to within a constant factor.

---

## 6. Complete Quadratic Sums, the Conic, and the Vertical Moments

Proposition 5.4 reduces the vertical second moment to the collision count $N(a)$. Computing $N(a)$ exactly requires the full theory of quadratic character sums of quadratic polynomials. In this section $\operatorname{char} F \notin \{2,3\}$.

**Lemma 6.1 (Roots of a quadratic).** For $\beta,\gamma \in F$,
$$\#\{y \in F : y^2+\beta y + \gamma = 0\} = \chi(\beta^2-4\gamma) + 1.$$

*Proof sketch.* Complete the square: substituting $y = z - \beta/2$ turns the condition into $z^2 = (\beta^2-4\gamma)/4$, and $\chi$ is unchanged by multiplication by the nonzero square $1/4$. Apply Lemma 2.3. $\square$

**Lemma 6.2 (Hyperbola count).** For $D \in F$,
$$\#\{(u,t) \in F^2 : t^2 = u^2 - D\} = \begin{cases} 2q-1, & D=0,\\ q-1, & D \ne 0.\end{cases}$$

*Proof sketch.* The change of variables $(s,r) \mapsto (u,t) = ((s+r)/2, (r-s)/2)$ is a bijection of $F^2$ turning $t^2 = u^2 - D$ into $sr = D$. If $D \ne 0$ each $s \ne 0$ has exactly one $r$, giving $q-1$; if $D = 0$ the locus is the union of the two axes, of size $2q-1$. $\square$

**Lemma 6.3 (Shifted square sum).** $\displaystyle\sum_{u \in F}\chi(u^2 - D) = \begin{cases} q-1, & D=0,\\ -1, & D \ne 0.\end{cases}$

*Proof sketch.* By Lemma 2.3, $\chi(u^2-D) = \#\{t : t^2 = u^2-D\} - 1$; summing over $u$ and applying Lemma 6.2 gives $(2q-1)-q = q-1$ when $D=0$ and $(q-1)-q = -1$ otherwise. $\square$

**Theorem 6.4 (Complete quadratic character sum).** Let $\alpha \ne 0$ and $\beta,\gamma \in F$. Then
$$\sum_{v \in F} \chi(\alpha v^2 + \beta v + \gamma) = \begin{cases} (q-1)\,\chi(\alpha), & \beta^2 - 4\alpha\gamma = 0,\\ -\chi(\alpha), & \beta^2-4\alpha\gamma \ne 0.\end{cases}$$

*Proof sketch.* Multiply inside by $\alpha$ and complete the square: $\alpha(\alpha v^2+\beta v+\gamma) = (\alpha v + \beta/2)^2 - D$ with $D = \beta^2/4 - \alpha\gamma$. Since $\chi(\alpha)^2 = 1$, $\chi(\alpha v^2+\beta v+\gamma) = \chi(\alpha)\chi\bigl((\alpha v + \beta/2)^2 - D\bigr)$. As $v$ runs over $F$ so does $\alpha v + \beta/2$; apply Lemma 6.3, noting $D=0 \iff \beta^2-4\alpha\gamma = 0$. $\square$

**Theorem 6.5 (Conic count).** For $c \in F$,
$$\#\{(x,y) \in F^2 : x^2+xy+y^2 = c\} = q + \begin{cases} (q-1)\,\chi(-3), & c = 0,\\ -\chi(-3), & c \ne 0.\end{cases}$$

*Proof sketch.* For fixed $x$ the equation is the quadratic $y^2+xy+(x^2-c)=0$ in $y$, whose root count is $\chi(x^2 - 4(x^2-c))+1 = \chi(-3x^2+4c)+1$ by Lemma 6.1. Summing over $x$ and applying Theorem 6.4 with $\alpha = -3 \ne 0$, $\beta = 0$, $\gamma = 4c$ — whose discriminant $0 - 4(-3)(4c) = 48c$ vanishes iff $c=0$ — gives the stated value. $\square$

**Theorem 6.6 (Exact collision counts).** With $\operatorname{char} F \notin \{2,3\}$,
$$N(0) = 2q-1 + (q-1)\chi(-3), \qquad N(a) = 2q-1-\chi(-3)-\chi(-a/3) \quad (a \ne 0).$$

*Proof sketch.* Split the defining condition. For $x = y$ it always holds ($q$ pairs). For $x \ne y$, $x^3+ax = y^3+ay$ is equivalent to $x^2+xy+y^2 = -a$. By inclusion–exclusion,
$$N(a) = q + \#\{(x,y) : x^2+xy+y^2 = -a\} - \#\{x : 3x^2 = -a\}.$$
Theorem 6.5 evaluates the conic term with $c = -a$, and Lemma 2.3 evaluates the diagonal correction as $\chi(-a/3)+1$. Simplifying in the two cases $a=0$, $a \ne 0$ (noting $\chi(0)=0$) gives the formulas. $\square$

**Theorem 6.7 (Exact vertical second moments).** With $\operatorname{char} F \notin \{2,3\}$,
$$\sum_{b \in F} a(0,b)^2 = q(q-1)\bigl(1+\chi(-3)\bigr),$$
and for $a \ne 0$,
$$\sum_{b \in F} a(a,b)^2 = q^2 - q\bigl(1 + \chi(-3) + \chi(-a/3)\bigr).$$

*Proof sketch.* Substitute Theorem 6.6 into Proposition 5.4 and use $a(a,b)^2 = S(a,b)^2$. $\square$

**Consistency check.** Summing the second formula over the $q-1$ nonzero $a$ and adding the first gives, using $\sum_{a \ne 0}\chi(-a/3) = 0$,
$$q(q-1)(1+\chi(-3)) + (q-1)\bigl(q^2 - q(1+\chi(-3))\bigr) = (q-1)q^2 = q^3-q^2,$$
in agreement with Theorem 5.6 — and, notably, the dependence on $\chi(-3)$ cancels exactly.

**Corollary 6.8 (Supersingularity of the cube family is exactly $\chi(-3)=-1$).** The family $y^2 = x^3+b$ satisfies $a(0,b) = 0$ for every $b$ if and only if $\chi(-3) = -1$.

*Proof sketch.* A sum of squares of integers vanishes iff each term does, so the condition is equivalent to $\sum_b a(0,b)^2 = 0$, i.e. by Theorem 6.7 to $q(q-1)(1+\chi(-3)) = 0$. As $q > 1$ and $\chi(-3) \in \{\pm 1\}$ (note $-3 \ne 0$), this holds iff $\chi(-3) = -1$. $\square$

**Theorem 6.9 (Cubic/quadratic bridge).** With $\operatorname{char} F \notin \{2,3\}$, the map $x \mapsto x^3$ is a bijection of $F$ if and only if $\chi(-3) = -1$.

*Proof sketch.* The collision count at $a=0$ measures exactly the failure of injectivity of cubing: $N(0) = q$ if and only if the collision locus $\{(x,y) : x^3=y^3\}$ is the diagonal, i.e. iff cubing is injective, i.e. (finiteness) bijective. By Theorem 6.6, $N(0) = q$ is equivalent to $(q-1)(\chi(-3)+1) = 0$, i.e. to $\chi(-3) = -1$. $\square$

Equivalently: $F$ contains a primitive cube root of unity iff $-3$ is a square in $F$ — the cube roots of unity being $(-1 \pm \sqrt{-3})/2$.

**Corollary 6.10 (Supplementary reciprocity for $-3$).** Let $p > 3$ be prime. Then $-3$ is a nonsquare modulo $p$ if and only if $p \equiv 2 \pmod 3$.

*Proof sketch.* By Theorem 6.9 it suffices to show that cubing is bijective on $\mathbb{F}_p$ iff $p \equiv 2 \bmod 3$. If $p \equiv 2 \bmod 3$ then $3 \nmid p-1$ and Lemma 4.2 applies. Conversely if $p \equiv 1 \bmod 3$ then $3 \mid \#\mathbb{F}_p^\times$, so by Cauchy's theorem there is an element $z \ne 1$ of order $3$; then $z^3 = 1^3$ with $z \ne 1$, so cubing is not injective. (The case $p \equiv 0 \bmod 3$ is excluded by $p > 3$.) $\square$

This is a classical supplement to quadratic reciprocity, obtained here as a consequence of counting points on a family of curves.

---

## 7. Exhaustive Verification over Small Prime Fields

The following statements have been verified by exhaustive enumeration over $\mathbb{F}_p$ for the primes indicated. They corroborate the theorems above and, in the case of Hasse's bound, test a statement the elementary method does *not* prove.

1. **Hasse's bound.** For $p \in \{5,7,11,13\}$, $a(a,b)^2 \le 4p$ for all $p^2$ parameter pairs $(a,b)$, including the singular ones. The observed maxima of $a(a,b)^2$ are $16, 25, 36, 49$ against thresholds $4p = 20, 28, 44, 52$.
2. **Second moment.** For $p \in \{5,7,11,13,17,19\}$, $\sum_{a,b} a(a,b)^2 = p^3-p^2$ exactly: $100$, $294$, $1210$, $2028$, $4624$, $6498$.
3. **First supersingular family.** Over $\mathbb{F}_{11}$ ($11 \equiv 2 \bmod 3$), $\#E_{0,b} = 12$ for every $b$.
4. **Second supersingular family.** Over $\mathbb{F}_{11}$ ($11 \equiv 3 \bmod 4$), $\#E_{a,0} = 12$ for every $a$.
5. **Non-degeneracy.** Over $\mathbb{F}_{13}$ ($13 \equiv 1 \bmod 3$, $13 \equiv 1 \bmod 4$), $\#E_{0,1} = 12 \ne 19 = \#E_{0,2}$.
6. **Parity criterion.** Over $\mathbb{F}_5$: the curve $y^2 = x^3+1$ has the root $x = -1$ and $6$ points (even); the curve $y^2 = x^3+x+1$ has no root and $9$ points (odd).
7. **Sharpness of nonsingularity.** Over $\mathbb{F}_5$, the singular curve $y^2 = x^3+2x+2$ has $\Delta = 0$, exactly two roots, and $7$ points (odd) — violating both Theorem 3.4 and Theorem 3.5 in the absence of nonsingularity.
8. **Twisting.** Over $\mathbb{F}_5$ with the nonresidue $d = 2$: $\#E_{1,1} = 9$ and $\#E_{4,3} = 3$, summing to $12 = 2\cdot 5+2$.
9. **Vertical moments.** For $p \in \{5,7,11,13\}$ both formulas of Theorem 6.7 hold for every $a$; e.g. at $p = 7$ ($\chi(-3)=1$) one has $\sum_b a(0,b)^2 = 84 = 7\cdot 6\cdot 2$, while at $p=11$ ($\chi(-3)=-1$) the sum is $0$.
10. **Bridge.** For $p \in \{5,7,11,13,17,19,23\}$, cubing is bijective exactly for $p \in \{5,11,17,23\}$, exactly the primes with $\chi(-3)=-1$, exactly those with $p \equiv 2 \bmod 3$.

The empirical trace distribution over $\mathbb{F}_{11}$ is symmetric about $0$ (as forced by twisting), supported on $[-6,6] \subset [-2\sqrt{11}, 2\sqrt{11}]$, with mean $0$ and mean square exactly $10 = p-1$.

---

## 8. Discussion, Limits of the Method, and Future Directions

### 8.1 What the method reaches

The elementary machinery of this paper is exactly powerful enough for degree-$\le 2$ character sums. Every exact result above arises because some manipulation reduces the cubic sum $S(a,b)$ to a linear or quadratic one:

- The supersingular families reduce a cubic sum to a *linear* one, by reindexing along a bijection ($x \mapsto x^3$) or by an odd symmetry ($x \mapsto -x$).
- The moment computations reduce cubic sums to *quadratic* ones by exchanging the order of summation so that the parameter $b$ — which appears linearly in $f_{a,b}$ — is summed innermost.
- The vertical moments then require the complete evaluation of quadratic sums (Theorem 6.4) and the resulting conic count (Theorem 6.5), which is where $\chi(-3)$ enters.

### 8.2 What it does not reach

The conspicuous gap is a **pointwise** bound on $a(a,b)$ — Hasse's theorem. This is not a shortcoming of presentation but a genuine boundary: pointwise square-root cancellation for a cubic character sum is the Riemann Hypothesis for the associated curve, and no exchange-of-summation identity is known to produce it. The moment method gives the bound for all but a $\lambda^{-2}$ fraction of the family (Corollary 5.8), and exhaustive computation confirms it in the accessible range (§7), but the general pointwise statement remains outside the toolkit developed here.

### 8.3 Future directions

*The following research programme was distilled from the results above and from what resisted proof.*

Throughout, $F$ is a finite field with $q = \#F$ elements and odd characteristic, $\chi$ is the quadratic character, and for $a,b \in F$ we write $\#E_{a,b}$ for the number of points of $y^2 = x^3+ax+b$ (affine plus infinity), $a(a,b) = q+1-\#E_{a,b}$, and $S(a,b) = \sum_x \chi(x^3+ax+b) = -a(a,b)$.

What is already **proved** here: the counting formula, the parity/2-torsion criterion, the $0/1/3$ root dichotomy, the two supersingular families, twisting, the first moment $\sum a(a,b) = 0$, the exact second moment $\sum_{a,b} a(a,b)^2 = q^3-q^2$, the exact *vertical* moments, the bridge "cubing bijective $\iff \chi(-3)=-1$", and supplementary reciprocity for $-3$ over $\mathbb{F}_p$. What resisted: any *pointwise* bound on $a(a,b)$ — i.e. Hasse itself. That gap shapes the conjectures below.

**C1. The fourth moment is exactly $2q^5 - 3q^4 + O(q^3)$ with an explicit closed form.**

*Conjecture.* There are integers $c_3, c_2$ (depending only on $\chi(-3)$ and $\chi(-1)$) with
$$\sum_{a,b \in F} a(a,b)^4 = 2q^5 - 3q^4 + c_3 q^3 + c_2 q^2.$$

*The key insight* is that the fourth moment reduces, exactly as the second moment did, to the $b$-sum $\sum_b \chi\bigl((b+u_1)(b+u_2)(b+u_3)(b+u_4)\bigr)$, and that this sum is *elementary* whenever the $u_i$ collide in pairs — the genuinely quartic case is the only Weil-type input, and it is governed by a single hyperelliptic curve of genus $1$ whose own count is again in the family. So the fourth moment should be self-referential and computable by the same collision bookkeeping that produced Theorem 6.6.

*Why now?* The second-moment proof already contains the entire machinery (complete quadratic sums, collision counts by inclusion–exclusion); only the degree-$4$ shift sum is missing, and the numerical table for $q = 5,7,11,13$ can pin the constants $c_3, c_2$ before any proof is attempted. A verified fourth moment would give $\#\{(a,b) : |a| \ge \lambda\sqrt q\} = O(q^2/\lambda^4)$, a genuine improvement on Corollary 5.8.

**C2. Hasse's bound follows from the moments plus twist symmetry.**

*Conjecture.* For every $a,b$ with $\Delta(a,b) \ne 0$, $a(a,b)^2 \le 4q$, and this is provable from (i) the exact second moment, (ii) the twisting identity, and (iii) the multiplicativity of the count under base change $F \to F_{q^n}$ — with no Riemann–Roch and no Jacobian.

*The key insight* is that $a(a,b)^2 \le 4q$ is equivalent to the positivity of the quantity $q^n + 1 - a_n$ on all extensions, and $a_n$ satisfies the Newton recursion $a_{n+1} = a_1 a_n - q\,a_{n-1}$ that can be *derived* from moment identities over each $F_{q^n}$ rather than from the Frobenius eigenvalue picture.

*Why now?* The whole development above is stated for an arbitrary finite field, not just a prime field, so the base-change tower is already expressible; and the exhaustive checks for $q \le 13$ show the bound holds throughout the accessible range.

**Further avenues.** (a) *Higher vertical moments.* Theorem 6.7 refines the global second moment by the arithmetic of $-3$; the analogous fourth vertical moment should involve $\chi(-1)$ and the count of a further conic, and would give an arithmetic-sensitive Chebyshev bound on each vertical line. (b) *Other families.* The same reduction applies verbatim to $y^2 = x^n + ax + b$ and to hyperelliptic families, where the innermost $b$-sum is again quadratic; exact second moments should follow with the conic replaced by a higher-degree collision variety. (c) *Modular invariants for other moduli.* Corollaries 4.3 and 4.5 give $3 \mid \#E$ and $4 \mid \#E$ from $q \bmod 3$ and $q \bmod 4$; a systematic search for congruence conditions forcing $m \mid \#E$ for other small $m$ — via torsion structures other than $2$-torsion — appears tractable by the same character-sum route. (d) *Distributional refinement.* The observed trace histograms are strikingly close to a semicircle; the moment ladder is precisely the standard route to a Sato–Tate-type limit law for the family, and the exact second moment is its first nontrivial rung.

---

## 9. Summary of Results

| Result | Statement |
|---|---|
| Counting formula | $\#E_{a,b} = q+1+S(a,b)$, $\;a(a,b) = -S(a,b)$ |
| Root dichotomy | $\Delta \ne 0 \Rightarrow \#R_{a,b} \in \{0,1,3\}$ |
| 2-torsion criterion | $\Delta \ne 0 \Rightarrow (2 \mid \#E_{a,b} \iff f_{a,b}$ has a root$)$ |
| Cube family | cubing bijective $\Rightarrow \#E_{0,b} = q+1$; $p\equiv 2 \bmod 3 \Rightarrow 3 \mid \#E_{0,b}$ |
| Linear family | $\chi(-1)=-1 \Rightarrow \#E_{a,0} = q+1$; $p \equiv 3 \bmod 4 \Rightarrow 4 \mid \#E_{a,0}$ |
| Twisting | $\chi(d) = -1 \Rightarrow \#E_{a,b} + \#E_{ad^2,bd^3} = 2q+2$ |
| First moment | $\sum_{a,b} a(a,b) = 0$; $\;\sum_{a,b}\#E_{a,b} = q^2(q+1)$ |
| Second moment | $\sum_{a,b} a(a,b)^2 = q^3-q^2$ |
| Chebyshev | $K\cdot\#\{a(a,b)^2 \ge K\} \le q^3-q^2$ |
| Extremal existence | $\exists (a,b) : a(a,b)^2 \ge q-1$ |
| Quadratic sums | $\sum_v \chi(\alpha v^2+\beta v+\gamma) = -\chi(\alpha)$ unless $\beta^2-4\alpha\gamma=0$, then $(q-1)\chi(\alpha)$ |
| Conic count | $\#\{x^2+xy+y^2=c\} = q - \chi(-3)$ for $c \ne 0$; $q + (q-1)\chi(-3)$ for $c=0$ |
| Vertical moments | $\sum_b a(0,b)^2 = q(q-1)(1+\chi(-3))$; $\sum_b a(a,b)^2 = q^2-q(1+\chi(-3)+\chi(-a/3))$ |
| Bridge | cubing bijective $\iff \chi(-3)=-1$ |
| Reciprocity | $p > 3$: $\chi_p(-3) = -1 \iff p \equiv 2 \bmod 3$ |
