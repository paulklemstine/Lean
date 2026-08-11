# The Rational Star Pencils of the Berggren Tree

### Charge, hypercycles, quantisation, Farey visibility, and a totient density law for the Pythagorean tree in the Poincaré half-plane

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Plotting the Berggren ternary tree of primitive Pythagorean triples in the Poincaré upper half-plane through the Euclid embedding $z(m,n) = (n+i)/m$ produces a star map: pencils of straight rays fanning out of points on the ideal boundary. The two conspicuous fans sit at the ideal points $0$ and $1$, but fainter fans are visible at $1/2$, $1/3$, $1/5$, $2/5$ and beyond. We give a complete and exact account of this phenomenon.

To each rational ideal point $p/q$ in lowest terms and each integral pair $(m,n)$ we attach the **charge** $\chi_{p/q}(m,n) = pm - qn$. We prove: (i) the nodes of a fixed charge lie on a single Euclidean ray emanating from $p/q$, since $p/q - \operatorname{Re}z = (\chi/q)\operatorname{Im}z$, so the rays of the picture are exactly the level sets of the charge; (ii) each such ray is a **hypercycle**, at hyperbolic distance exactly $\operatorname{arsinh}(|\chi|/q)$ from the complete geodesic over $p/q$, so the charge is a hyperbolic width and a fan is a quantised ladder of hypercycles; (iii) a **parity quantisation dichotomy** — the set of charges realised by Euclid seeds at $p/q$ is all of $\mathbb{Z}$ when $p+q$ is odd, and exactly the odd integers when $p+q$ is even — with every realised ray infinite, proved through an explicit unimodular parametrisation of a ray; (iv) the axis of a fan carries at most one node, namely $(m,n) = (q,p)$, and does so precisely when $p+q$ is odd (at $p/q = 1/2$ that node is the root $(2,1)$ of the tree); (v) a **visibility law**: adjacent rays of the fan at $p/q$ are separated by exactly $y/q$ at plot height $y$, hence the fans resolved at resolution $\varepsilon$ are precisely those of denominator $q \le y/\varepsilon$, a Farey set of cardinality $\sum_{q\le Q}\varphi(q)$; (vi) a **Diophantine dictionary** $n/m - p/q = -\chi/(qm)$, identifying the innermost rays $|\chi|=1$ with Farey neighbours of $p/q$ and showing that every node with $m \ge 2$ is an innermost node of two distinct fans of denominator $< m$; (vii) a **totient density law**: on a ray of odd charge $k$ at an odd/odd rational, every window of $2|k|$ consecutive parameters carries exactly $2\varphi(|k|)$ nodes, so a ray has arithmetic density $\varphi(|k|)/|k|$; and (viii) a **transport action** of the three Berggren moves on the fan parameter $(p,q)$, under which the charge is exactly covariant, primitivity is preserved, and the parity of $p+q$ is invariant — whence the $0$-fan and the $1$-fan lie in different transport classes and their visual asymmetry is permanent.

**Keywords:** Pythagorean triples, Berggren tree, Poincaré half-plane, hypercycle, charge, Farey fractions, Euler totient, unimodular parametrisation, Diophantine approximation, parity quantisation.

---

## 1. Introduction

### 1.1 The picture

Three objects meet in this paper.

**Primitive Pythagorean triples.** A triple $(a,b,c)$ of positive integers with $a^2+b^2=c^2$ and $\gcd(a,b,c)=1$. Euclid's parametrisation writes each of them uniquely (with the even leg listed second) as
$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2)$$
for a **Euclid seed** $(m,n)$: a pair of positive integers with $0<n<m$, $\gcd(m,n)=1$ and $m+n$ odd.

**The Berggren tree.** In seed coordinates the three classical Berggren matrices become the three affine moves
$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n),$$
each of which maps Euclid seeds to Euclid seeds, and which generate every Euclid seed from the root $(2,1)$ exactly once. (Preservation of seedhood is immediate: positivity and $n' < m'$ follow from $0<n<m$; a common divisor of $2m-n$ and $m$ divides $n$; and each move changes the coordinate sum by an even amount.)

**The Poincaré half-plane.** $\mathbb{H} = \{z\in\mathbb{C}: \operatorname{Im}z>0\}$ with $ds = |dz|/\operatorname{Im}z$, ideal boundary $\mathbb{R}\cup\{\infty\}$, geodesics the vertical rays and the semicircles orthogonal to $\mathbb{R}$, distance given by
$$\cosh d(z,w) = 1 + \frac{|z-w|^2}{2\operatorname{Im}z\,\operatorname{Im}w}.$$

The bridge is the **Euclid embedding**
$$z(m,n) = \frac{n+i}{m} = \frac{n}{m} + \frac{i}{m},$$
which is injective on seeds (the height recovers $m$, then the real part recovers $n$). Rendering the node set produces a picture with three unmistakable features: nested arcs, one distinguished ray marching off at constant speed, and — the subject of this paper — **pencils of straight rays fanning out of boundary points**, obvious at $0$ and $1$ and visible at $0.5$, $0.333\ldots$, $0.2$ and elsewhere.

### 1.2 Background: the radial coordinate

For orientation we record the elementary identity governing the radial structure of the picture; it is not needed for the results on fans but it explains the shell structure the reader sees.

**Proposition 1.1.** For every $m\ge1$, $n\ge0$,
$$\cosh d_{\mathbb{H}}\big(i,\ z(m,n)\big) = \frac{m^2+n^2+1}{2m} = \frac{c+1}{2m}, \qquad c = m^2+n^2.$$

*Proof.* With $z=i$, $w=(n+i)/m$ one has $\operatorname{Im}w = 1/m$ and $|z-w|^2 = (n^2 + (m-1)^2)/m^2$; substituting into the distance formula and simplifying gives the claim. $\square$

**Corollary 1.2.** $\tfrac12\log c \le d_{\mathbb{H}}(i,z(m,n)) \le \tfrac12\log(2(c+1))$, so $|d - \tfrac12\log c|\le \log 2$.

*Proof.* $\cosh(\tfrac12\log c) = (c+1)/(2\sqrt c)$, so the lower bound is $m\le\sqrt c$. For the upper bound, $\cosh d\le e^d \le 2\cosh d$ gives $d\le \log((c+1)/m)$, and $n<m$ forces $2m^2\ge c+1$, whence $(c+1)/m \le \sqrt{2(c+1)}$. $\square$

Thus the hypotenuse is the radial coordinate to within $\log 2$: nodes are organised into shells by $c$. The *angular* structure is the fan structure, and that is what we now determine.

### 1.3 Results and organisation

Section 2 defines the charge and proves the ray identity and the hypercycle theorem. Section 3 establishes the parity obstruction and the axis theorem. Section 4 gives the unimodular parametrisation of a ray and the realisation theorem, completing the description of every fan. Section 5 proves the visibility law and the Farey count. Section 6 gives the Diophantine dictionary, the Farey neighbour characterisation of innermost rays, and the two-principal-stars theorem. Section 7 proves the totient density law. Section 8 develops the transport action and the parity invariant. Section 9 gives algorithms, Section 10 numerical evidence, Section 11 discussion, Section 12 open problems.

---

## 2. Charge, rays, and hypercycles

### 2.1 The charge

**Definition 2.1 (Charge).** For integers $p,q$ and a pair $(m,n)$, the **charge of $(m,n)$ at $p/q$** is
$$\chi_{p/q}(m,n) \;=\; p\,m - q\,n \;\in\; \mathbb{Z}.$$
We write $\chi$ when $p/q$ is clear. Throughout, $p/q$ is in lowest terms, $q \ge 1$.

Two familiar special cases: $\chi_{0/1}(m,n) = -n$ and $\chi_{1/1}(m,n) = m-n$. These are, respectively, the parameter of the classical $0$-star and the parameter of the classical $1$-star.

### 2.2 The rays

**Theorem 2.2 (Rational star line).** Let $q \ge 1$, $m \ge 1$, and write $z = z(m,n)$. Then
$$\frac{p}{q} - \operatorname{Re} z \;=\; \frac{\chi_{p/q}(m,n)}{q}\cdot \operatorname{Im} z .$$
Consequently all seeds with a common charge at $p/q$ lie on one and the same Euclidean ray emanating from the ideal point $p/q$, of Euclidean slope $q/\chi$ (vertical when $\chi=0$).

*Proof.* $\dfrac pq - \dfrac nm = \dfrac{pm-qn}{qm} = \dfrac{\chi}{q}\cdot\dfrac1m$, and $\operatorname{Im}z = 1/m$. $\square$

This single line is the whole visual phenomenon: **the rays of the picture are the level sets of the charge**, and there is one such pencil at every rational boundary point. The classical fans at $0$ and $1$ are the case $q=1$, in which the charge is smallest and the rays widest.

### 2.3 The rays are hypercycles

Recall that for a geodesic $\gamma$ in $\mathbb{H}$ and $r>0$, the locus $\{z : d(z,\gamma) = r\}$ is a *hypercycle*, a pair of Euclidean rays or arcs meeting $\partial\mathbb{H}$ at the endpoints of $\gamma$ at angle $\ne \pi/2$. The following makes the identification exact.

**Theorem 2.3 (Hypercycle theorem).** Let $x\in\mathbb{R}$, let $\gamma_x$ be the vertical geodesic from $x$ to $\infty$, and let $z\in\mathbb{H}$ satisfy $x - \operatorname{Re}z = u\operatorname{Im}z$. Then
$$d_{\mathbb{H}}(z,\gamma_x) = \operatorname{arsinh}|u|,$$
the infimum being attained at the point of $\gamma_x$ of height $\operatorname{Im}(z)\sqrt{1+u^2}$.

*Proof.* Put $y = \operatorname{Im}z$ and $w = x+is$. Then $(\operatorname{Re}z - x)^2 = u^2y^2$, so
$$\cosh d(z,w) = 1 + \frac{u^2y^2 + (y-s)^2}{2ys} = \frac{(1+u^2)y^2 + s^2}{2ys} \;\ge\; \sqrt{1+u^2}$$
by AM–GM, with equality iff $s = y\sqrt{1+u^2}$. Since $\operatorname{arcosh}\sqrt{1+u^2} = \operatorname{arsinh}|u|$, the claim follows. $\square$

**Corollary 2.4 (The fan is a ladder of hypercycles).** The hyperbolic distance from $z(m,n)$ to the complete geodesic over $p/q$ is
$$d_{\mathbb{H}}\big(z(m,n),\ \gamma_{p/q}\big) \;=\; \operatorname{arsinh}\!\left(\frac{|\chi_{p/q}(m,n)|}{q}\right),$$
which depends on the node only through its charge. The fan at $p/q$ is therefore a discrete pencil of hypercycles at the quantised levels $\operatorname{arsinh}(k/q)$, $k \in \mathbb{Z}$.

*Proof.* Combine Theorems 2.2 and 2.3 with $u = \chi/q$. $\square$

**Corollary 2.5 (Off-axis separation and band containment).** Every node of nonzero charge at $p/q$ lies at distance at least $\operatorname{arsinh}(1/q)$ from the axis $\gamma_{p/q}$, and every node of charge $|\chi| \le K$ lies within the band of width $\operatorname{arsinh}(K/q)$. The lower bound is attained: the seed $(3,2)$ has charge $-1$ at $1/2$, hence lies at distance exactly $\operatorname{arsinh}(1/2)$ from $\gamma_{1/2}$.

Since $q \mapsto \operatorname{arsinh}(1/q)$ is strictly decreasing, **fans of large denominator are squeezed into thin pencils** — the quantitative form of this observation is the visibility law of Section 5.

---

## 3. Parity quantisation and the axis

### 3.1 Half the rays can be empty

**Theorem 3.1 (Parity quantisation).** If $p$ and $q$ are both odd, then every Euclid seed has *odd* charge at $p/q$.

*Proof.* Modulo $2$, $\chi = pm - qn \equiv m - n \equiv m+n \equiv 1$, using $p\equiv q\equiv 1$ and the seed condition. $\square$

So at $1/3$, $1/5$, $3/5$, $5/7$, … the fan is *half empty*: the rays of even charge carry no node at all. Two immediate instances: no seed has charge $2$ at $1/3$; every seed has odd charge at $1/5$. This explains and unifies the classical asymmetry between the two conspicuous stars: at $p/q = 1/1$ both entries are odd and the charge $m-n$ is always odd, while at $p/q = 0/1$ the entries have opposite parity and the charge $-n$ takes every value.

### 3.2 The axis

**Theorem 3.2 (The axis carries at most one node).** Let $p/q$ be in lowest terms with $q\ge1$ and let $(m,n)$ be a Euclid seed. Then $\chi_{p/q}(m,n)=0$ if and only if $(m,n) = (q,p)$.

*Proof.* $\chi = 0$ means $pm = qn$. Since $\gcd(p,q)=1$, $q \mid m$; since $\gcd(m,n)=1$ and $m \mid qn$ (from $pm=qn$ with $\gcd(m,n)=1$ giving $m\mid q$), we get $m \mid q$. Hence $m = q$, and then $qp = qn$ gives $n=p$. The converse is a substitution. $\square$

**Theorem 3.3 (When the axis is occupied).** For coprime $0<p<q$, there exists a Euclid seed of charge $0$ at $p/q$ if and only if $p+q$ is odd; the seed is $(q,p)$.

*Proof.* By Theorem 3.2 the only candidate is $(q,p)$, which satisfies $0<p<q$ and $\gcd(q,p)=1$; it is a Euclid seed exactly when $q+p$ is odd. $\square$

**Example 3.4.** At $p/q = 1/2$ the axis node is $(2,1)$, the root of the Berggren tree and the seed of $(3,4,5)$: the tree's origin sits exactly on the centre line of the fan at $0.5$. At $1/3$ and $1/5$ the axis is empty — those fans have a hole down the middle.

---

## 4. The unimodular parametrisation and the realisation theorem

Theorem 3.1 rules charges out. We now rule them in.

### 4.1 Parametrising a ray

Because $\gcd(p,q)=1$, there are integers $a,b$ with $pb - qa = 1$. Define
$$\sigma(k,s) \;=\; \big(k b + s q,\ \ k a + s p\big), \qquad s \in \mathbb{Z}.$$

**Proposition 4.1 (Properties of $\sigma$).** With $pb-qa=1$:
1. **Constant charge.** $\chi_{p/q}(\sigma(k,s)) = k$ for all $s$, since $p(kb+sq) - q(ka+sp) = k(pb-qa) = k$.
2. **Inversion.** $b\,\sigma_2 - a\,\sigma_1 = s$, so the substitution $(k,s)\mapsto \sigma(k,s)$ is unimodular; in particular it is a bijection of $\mathbb{Z}^2$ onto itself and $\{\sigma(k,s): s\in\mathbb{Z}\}$ is the full solution set of $pm-qn=k$.
3. **Coprimality transfer.** $\gcd(\sigma_1,\sigma_2) = 1 \iff \gcd(k,s)=1$. (Both directions follow from the two Bézout expressions supplied by 1 and 2.)
4. **Parity.** $\sigma_1 + \sigma_2 = k(a+b) + s(p+q)$, an explicit affine function of $s$.

Item 3 is the heart of the matter: the arithmetic of the *node* is converted into the arithmetic of the *(charge, parameter)* pair.

**Proposition 4.2 (Ordering past a bound).** Suppose $0<p<q$. Set
$$S_0(k,a,b) \;=\; |ka| + |kb| + |k(b-a)| + 1 .$$
Then for every integer $s \ge S_0$, the pair $\sigma(k,s)$ satisfies $0 < \sigma_2 < \sigma_1$.

*Proof.* $\sigma_2 = ka + sp \ge -|ka| + s \ge 1$ using $p\ge1$ and $s \ge |ka|+1$; and $\sigma_1 - \sigma_2 = k(b-a) + s(q-p) \ge -|k(b-a)| + s \ge 1$ using $q-p\ge1$. $\square$

### 4.2 Realisation

**Theorem 4.3 (Realisation theorem).** Let $0<p<q$ be coprime and let $k\ne0$ be an integer which, in case $p+q$ is even, is odd. Then for every bound $M$ there is a Euclid seed $(m,n)$ with $m>M$ and $\chi_{p/q}(m,n) = k$.

*Proof.* Take $a,b$ with $pb-qa=1$ and consider $\sigma(k,s)$ for large $s$. Three conditions must be met.

*Ordering.* By Proposition 4.2, $0<\sigma_2<\sigma_1$ holds for every $s \ge S_0$.

*Primitivity.* By Proposition 4.1(3) it is equivalent to $\gcd(k,s)=1$.

*Parity.* By 4.1(4), $\sigma_1+\sigma_2 = k(a+b)+s(p+q)$. If $p+q$ is even then $p,q$ are both odd, so $pb-qa=1$ forces $b-a$ odd, hence $a+b$ odd; with $k$ odd the sum is odd $+$ even $=$ odd, *identically in $s$*. If $p+q$ is odd, the requirement is the single congruence $s \equiv \epsilon \pmod 2$ with $\epsilon \equiv 1 - k(a+b)$; note that if $\epsilon$ is even then $k(a+b)$ is odd, so $k$ is odd.

It remains to produce arbitrarily large $s$ meeting the active congruence and coprime to $k$. If no congruence is active, or $\epsilon$ is odd, take $s = 1 + 2j|k|$: it is odd, and $s\equiv1\pmod{|k|}$ gives $\gcd(s,k)=1$. If $\epsilon$ is even then $k$ is odd, and $s = 2 + 2j|k|$ is even with $\gcd(s,|k|) = \gcd(2,|k|)=1$. Letting $j\to\infty$ makes $s$, and hence $\sigma_1 = kb+sq$, exceed any prescribed bound. $\square$

**Corollary 4.4 (Every admissible ray is infinite).** Under the hypotheses of Theorem 4.3, the set of Euclid seeds of charge $k$ at $p/q$ is infinite.

*Proof.* If it were finite its first coordinates would be bounded by some $M$, contradicting Theorem 4.3. $\square$

**Theorem 4.5 (The exact fan).** For coprime $0<p<q$, the set of charges realised by Euclid seeds at $p/q$ is
$$\{\chi_{p/q}(m,n) : (m,n) \text{ a Euclid seed}\} \;=\; \begin{cases} \mathbb{Z}, & p+q \text{ odd},\\[2pt] \{k\in\mathbb{Z} : k \text{ odd}\}, & p+q \text{ even}.\end{cases}$$

*Proof.* If $p+q$ is odd: charge $0$ is realised by $(q,p)$ (Theorem 3.3) and every $k\ne0$ by Theorem 4.3. If $p+q$ is even then $p$ and $q$ are both odd (they are coprime, so not both even), so Theorem 3.1 confines the charges to the odd integers, and Theorem 4.3 realises all of them. $\square$

This is a complete description of every fan in the picture: two-sided at an interior rational, spacing $1/q$ in the hypercycle parameter, with exactly half the rays extinguished precisely when $p$ and $q$ are both odd.

---

## 5. The visibility law: which fans the eye sees

Every rational carries a fan, yet a plot displays only finitely many. The reason is a matter of resolution, and it converts a geometric question into a counting problem.

**Theorem 5.1 (Separation at fixed height).** Two nodes at the same height $y = 1/m$ whose charges at $p/q$ differ by $d$ are separated in real part by exactly
$$\frac{|d|}{qm} \;=\; \frac{|d|\,y}{q}.$$

*Proof.* $\chi_{p/q}(m,n) - \chi_{p/q}(m,n') = -q(n-n')$, so $|n - n'| = |d|/q$, and the difference in real parts is $|n-n'|/m$. $\square$

**Corollary 5.2 (Adjacent ray gap).** Adjacent rays ($d = 1$) of the fan at $p/q$ are exactly $y/q$ apart at plot height $y$.

**Theorem 5.3 (Resolution criterion).** For $y>0$ and resolution $\varepsilon>0$, the fan at $p/q$ has adjacent rays at least $\varepsilon$ apart at height $y$ if and only if
$$q \;\le\; \frac{y}{\varepsilon}.$$

*Proof.* $\varepsilon \le y/q \iff \varepsilon q \le y \iff q \le y/\varepsilon$. $\square$

**Definition 5.4 (Farey star set).** For $Q \ge 1$ let $\mathcal{F}(Q)$ be the set of pairs $(p,q)$ with $1\le p\le q\le Q$ and $\gcd(p,q)=1$; these are the star centres in $(0,1]$ of denominator at most $Q$.

**Theorem 5.5 (Farey count).** $\#\mathcal{F}(Q) = \sum_{q=1}^{Q}\varphi(q)$.

*Proof.* Partition by denominator; for each $q$, the admissible numerators are the integers in $[1,q]$ coprime to $q$, of which there are $\varphi(q)$. $\square$

**Theorem 5.6 (Visibility law).** At plot height $y$ and resolution $\varepsilon$, put $Q = \lfloor y/\varepsilon\rfloor$. Then every fan centred at a point of $\mathcal{F}(Q)$ is resolved, no other centre in $(0,1]$ is, and the number of resolved centres is $\sum_{q\le Q}\varphi(q)$ — a finite set, namely the Farey fractions of level $Q$.

*Proof.* Combine Theorem 5.3 with Theorem 5.5. $\square$

**Example 5.7.** At $y = 1/2$ and $\varepsilon = 1/10$ one has $Q=5$ and $\#\mathcal{F}(5) = 1+1+2+2+4 = 10$: the centres $1/1, 1/2, 1/3, 2/3, 1/4, 3/4, 1/5, 2/5, 3/5, 4/5$ (together with the boundary centre $0$). This is precisely the set of fans a plot at that scale displays — including the fans at $0.2$ and $0.333\ldots$ mentioned at the outset, and excluding, say, $2/7$.

Thus **the visible star centres are the Farey fractions of level $\lfloor y/\varepsilon\rfloor$**: doubling the resolution raises $Q$ and brings in a new tier of fans, and the asymptotic $\sum_{q\le Q}\varphi(q)\sim 3Q^2/\pi^2$ (see Section 12) predicts how many.

---

## 6. Diophantine content: charges measure approximation

### 6.1 The dictionary

**Theorem 6.1 (Approximation dictionary).** For $q, m \ge 1$,
$$\frac{n}{m} - \frac{p}{q} \;=\; \frac{-\chi_{p/q}(m,n)}{q\,m}.$$
Consequently, for any $K \ge 0$,
$$\left|\frac{n}{m}-\frac pq\right| \le \frac{K}{qm} \iff \big|\chi_{p/q}(m,n)\big| \le K.$$

*Proof.* Immediate from the definition of the charge, then divide by the positive quantity $qm$. $\square$

So **the rays of a fan are the levels of approximation quality**: a node lies on a low ray at $p/q$ exactly when $p/q$ approximates its slope well in the strong sense $|t - p/q| \le K/(qm)$.

### 6.2 Innermost rays are Farey neighbours

**Theorem 6.2 (Farey's theorem).** Let $p/q$ and $n/m$ be fractions with $q,m>0$ and $qn - pm = 1$. Then no fraction $r/s$ with $0 < s < q+m$ satisfies $p/q < r/s < n/m$.

*Proof.* If $p/q < r/s < n/m$ then $rq - ps \ge 1$ and $ns - rm \ge 1$ (both are positive integers). Multiply the first by $m$ and the second by $q$ and add:
$$m(rq-ps) + q(ns-rm) = s(qn-pm) = s,$$
so $s \ge m + q$. $\square$

**Theorem 6.3 (Sharpness).** Under the same hypotheses the mediant $(p+n)/(q+m)$ satisfies $p/q < (p+n)/(q+m) < n/m$, so the bound $q+m$ is attained.

*Proof.* $(p+n)/(q+m) - p/q = (qn-pm)/(q(q+m)) = 1/(q(q+m)) > 0$, and $n/m - (p+n)/(q+m) = (qn-pm)/(m(q+m)) > 0$. $\square$

**Corollary 6.4 (Innermost rays).** A Euclid seed of charge $-1$ at $p/q$ satisfies $qn-pm=1$, hence its slope is a Farey neighbour of $p/q$: nothing of denominator smaller than $q+m$ lies strictly between them, and the slope differs from $p/q$ by exactly $1/(qm)$. The innermost spokes of a fan consist precisely of best rational approximations to its centre.

### 6.3 Every node feeds two fans

**Theorem 6.5 (Two principal stars).** Let $(m,n)$ be a Euclid seed with $m\ge2$. Then there are two distinct pairs $(p,q)\ne(p',q')$ with $0<q<m$, $0<q'<m$ and
$$\chi_{p/q}(m,n) = -1, \qquad \chi_{p'/q'}(m,n) = +1 .$$
Every node of the tree is therefore an innermost node of at least two of the fans, with denominators smaller than its own.

*Proof.* Since $\gcd(n,m)=1$, the residue $n$ is invertible modulo $m$; let $q \in (0,m)$ be the representative of $n^{-1}$, so $qn \equiv 1 \pmod m$ and $q \ne 0$ (for $m\ge2$). Choose $p$ with $qn - pm = 1$, i.e. $\chi_{p/q}(m,n) = pm-qn = -1$. Now set $q' = m - q \in (0,m)$; then $q'n = mn - qn \equiv -1 \pmod m$, so there is $p'$ with $q'n - p'm = -1$, i.e. $\chi_{p'/q'}(m,n) = +1$. The two pairs are distinct because the charge of $(m,n)$ at them differs. Both denominators are smaller than $m$. $\square$

---

## 7. How densely a ray is populated: a totient law

Theorem 4.5 says which rays exist; we now ask how thickly a ray is occupied. Fix $p/q$ with $p$ and $q$ both odd (the fans at $1/3$, $1/5$, $3/5$, …) and an odd charge $k$; write $K = |k|$.

**Theorem 7.1 (Coprimality is the only obstruction).** With $pb-qa=1$, for every integer $s \ge S_0(k,a,b)$ the pair $\sigma(k,s) = (kb+sq,\ ka+sp)$ is a Euclid seed if and only if $\gcd(K,s)=1$.

*Proof sketch.* Proposition 4.2 gives $0<\sigma_2<\sigma_1$. Proposition 4.1(3) turns primitivity into $\gcd(k,s)=1$. For parity: $p,q$ odd and $pb-qa=1$ force $a+b$ odd, so $\sigma_1+\sigma_2 = k(a+b) + s(p+q)$ is odd (odd $\cdot$ odd) plus even, hence odd, *identically in $s$*. Thus the parity condition is automatic and coprimality is the sole remaining constraint. $\square$

**Theorem 7.2 (Window count).** For all $K \ge 1$ and all $N\ge0$,
$$\#\{s \in [N,\ N+2K) : \gcd(K,s)=1\} \;=\; 2\varphi(K).$$

*Proof.* Split the window into the two blocks $[N,N+K)$ and $[N+K, N+2K)$, each a complete residue system modulo $K$, each therefore containing exactly $\varphi(K)$ integers coprime to $K$. $\square$

**Theorem 7.3 (Parity split).** For all $K,N$,
$$\#\{s\in[N,N+2K): \gcd(K,s)=1,\ s \text{ odd}\} = \varphi(2K), \qquad \#\{\ldots,\ s \text{ even}\} = 2\varphi(K)-\varphi(2K).$$
For odd $K$ both classes contain exactly $\varphi(K)$ parameters, since $\varphi(2K)=\varphi(2)\varphi(K)=\varphi(K)$.

*Proof.* Coprimality to $2K$ is equivalent to coprimality to $K$ together with oddness, and a window of length $2K$ contains exactly $\varphi(2K)$ integers coprime to $2K$. Subtract for the even class. $\square$

**Theorem 7.4 (Totient density law for a ray).** Let $p,q$ be odd with $0<p<q$ coprime, let $k$ be an odd charge and $K=|k|$. Then for every $N \ge S_0(k,a,b)$, the number of Berggren nodes on the ray of charge $k$ at $p/q$ whose unimodular parameter lies in the window $[N, N+2K)$ is exactly
$$2\varphi(K) \;=\; 2\varphi(2K).$$
Hence the ray is infinite but of arithmetic density $\varphi(K)/K$ in the parameter.

*Proof.* Combine Theorems 7.1 and 7.2. $\square$

**Interpretation.** The spoke of charge $1$ is completely full ($\varphi(1)/1 = 1$); the spoke of charge $3$ is two-thirds full; the spoke of charge $15$ has density $8/15$ and is visibly dotted. **Rays of highly composite charge are the faint ones.** Because the parameter $s$ and the seed size $m = kb+sq$ are related by an explicit linear map, this is also a density statement in $m$: the count of nodes on the ray with $m \le M$ is asymptotically $(\varphi(K)/K)(M/q)$.

**Example 7.5.** On the fan at $1/3$, an exhaustive count of seeds with $m\le 20000$ gives $6666$ nodes on the ray $k=1$ and $4444$ on the ray $k=3$; normalised by $M/q = 6666.7$ these are densities $0.9999$ and $0.6666$, against the predicted $1$ and $2/3$.

---

## 8. Transport: the tree permutes the fans

### 8.1 Covariance of the charge

**Theorem 8.1 (Star covariance).** For all integers $p,q,m,n$,
$$\chi_{p/q}\big(B_1(m,n)\big) = \chi_{(2p-q)/p}(m,n), \quad \chi_{p/q}\big(B_2(m,n)\big) = \chi_{(2p-q)/(-p)}(m,n), \quad \chi_{p/q}\big(B_3(m,n)\big) = \chi_{p/(q-2p)}(m,n),$$
where $\chi_{P/Q}$ is read as the bilinear form $Pm - Qn$ even when $(P,Q)$ is not normalised.

*Proof.* Three expansions. For $B_1$: $p(2m-n) - qm = (2p-q)m - pn$. For $B_2$: $p(2m+n)-qm = (2p-q)m + pn$. For $B_3$: $p(m+2n) - qn = pm - (q-2p)n$. $\square$

**Definition 8.2 (Transport action).** On the *star parameter* $v = (p,q) \in \mathbb{Z}^2$ define
$$T_1(p,q) = (2p-q,\ p), \qquad T_2(p,q) = (2p-q,\ -p), \qquad T_3(p,q)=(p,\ q-2p),$$
and extend to words $w \in \{1,2,3\}^*$ by composition. Theorem 8.1 reads: *the charge of a moved node at a fan equals the charge of the original node at the transported fan.* Charge is conserved by the tree, provided the fan moves with the node.

Note that $T_1$, $T_2$, $T_3$ are exactly the transposes-with-signs of the three Berggren matrices; this is why the covariance is exact and not merely up to sign.

**Proposition 8.3 (Primitivity is preserved).** If $\gcd(p,q)=1$ then $\gcd(T_i(p,q)) = 1$ for each $i$, and hence for every word. (Each $T_i$ has determinant $\pm1$.) So transport genuinely acts on rational ideal points in lowest terms.

### 8.2 The parity invariant

**Theorem 8.4 (Parity of $p+q$ is a transport invariant).** For each $i$ and every $v=(p,q)$, the parity of the coordinate sum of $T_i(v)$ equals that of $v$; hence the same holds for every word.

*Proof.* $T_1$: $(2p-q)+p = 3p - q \equiv p+q \pmod 2$. $T_2$: $(2p-q)-p = p-q \equiv p+q$. $T_3$: $p + (q-2p) = q - p \equiv p+q$. $\square$

**Corollary 8.5 (Permanent asymmetry of the two classical stars).** No word of Berggren transports carries $(0,1)$ to $(1,1)$ or $(1,1)$ to $(0,1)$: the sums $1$ and $2$ have different parities. Hence the $0$-fan (all charges) and the $1$-fan (odd charges only) lie in different transport classes. Their visual asymmetry is intrinsic, not an artefact of the choice of root.

Theorem 8.4 also *explains* the dichotomy of Theorem 4.5: the two classes of fan — full and half-empty — are exactly the two parity classes of the transport action, and the action can never mix them.

### 8.3 The ladder

**Definition 8.6.** For $k\ge0$ let $L_k = (k,\ k+1)$, the star parameter of the ideal point $k/(k+1)$.

**Theorem 8.7 (The ladder collapses to the $0$-star).** $T_1(L_{k+1}) = L_k$, hence $T_1^{\,k}(L_k) = L_0 = (0,1)$.

*Proof.* $T_1(k+1,k+2) = (2(k+1)-(k+2),\ k+1) = (k,\ k+1)$. Iterate. $\square$

**Corollary 8.8 (Infinitely many fans are one fan).** For every $k\ge1$, the fan at $k/(k+1)$ is the transport of the $0$-fan by the word $B_1^{\,k}$. Its parameter pair is coprime, its coordinate sum $2k+1$ is odd, so by Theorem 4.5 the fan is *full* — every integer charge occurs — and by Corollary 8.5 no word of transports carries the $1$-fan to it.

So the fans at $1/2, 2/3, 3/4, 4/5, \ldots$ marching towards the ideal point $1$ are all copies of the fan at $0$, each obtained from the previous one by a single application of the tree's first move. The picture is far more self-similar than it looks.

---

## 9. Algorithms

**Algorithm A (Charge and hypercycle level).** Input: a seed $(m,n)$ and a star centre $p/q$ in lowest terms. Output: the charge $\chi = pm-qn$, the Euclidean ray parameter $\chi/q$, the hyperbolic width $\operatorname{arsinh}(|\chi|/q)$, and the approximation error $n/m - p/q = -\chi/(qm)$. Constant time.

**Algorithm B (Ray enumeration by the unimodular parametrisation).** Input: $p/q$, a charge $k$, a bound $M$. Compute $a,b$ with $pb-qa=1$ by the extended Euclidean algorithm; set $s$ from the bound $S_0 = |ka|+|kb|+|k(b-a)|+1$; for $s$ from $S_0$ upward, form $(m,n) = (kb+sq,\ ka+sp)$, stop when $m > M$, and keep the pairs that are Euclid seeds — equivalently, when $p,q,k$ are all odd, keep exactly those with $\gcd(|k|,s)=1$. Cost $O(M/q)$ arithmetic operations plus one extended-gcd; the coprimality test can be replaced by a sieve of the parameter window, giving amortised $O(1)$ per candidate.

**Algorithm C (Fan census).** Input: a bound $m \le M$ and a star centre $p/q$. Enumerate all Euclid seeds with $m\le M$, compute their charges at $p/q$, and tabulate the multiset of realised charges. Verifies Theorems 3.1 and 4.5 empirically and produces the observed spoke densities of Theorem 7.4. Cost $O(M^2)$ for the naive seed enumeration, $O(M^2/\log)$ with a gcd sieve.

**Algorithm D (Visibility list).** Input: a plot height $y$ and resolution $\varepsilon$. Set $Q = \lfloor y/\varepsilon\rfloor$ and output all $p/q$ with $1\le p\le q\le Q$, $\gcd(p,q)=1$ — the resolved star centres — together with their count $\sum_{q\le Q}\varphi(q)$. Cost $O(Q^2)$, or $O(Q\log\log Q)$ for the count alone via a totient sieve.

**Algorithm E (Transport walk).** Input: a star parameter $(p,q)$ and a word $w$ in $\{1,2,3\}$. Apply $T_1,T_2,T_3$ letter by letter, renormalising signs; report the resulting fan, verifying that $p+q$ keeps its parity throughout and that $\gcd$ stays $1$. Cost $O(|w|)$.

---

## 10. Numerical evidence

**Realised charges.** Exhaustive enumeration of seeds with $m \le 400$, recording all charges of absolute value at most $8$:

| $p/q$ | $p+q$ | realised charges with $|\chi|\le8$ |
|---|---|---|
| $0/1$ | odd | $-8,\ldots,-1$ |
| $1/1$ | even | $1,3,5,7$ |
| $1/2$ | odd | $-8,\ldots,8$ (including $0$) |
| $1/3$ | even | $\pm1,\pm3,\pm5,\pm7$ |
| $1/5$ | even | $\pm1,\pm3,\pm5,\pm7$ |
| $2/5$ | odd | $-8,\ldots,8$ |

Exactly as Theorem 4.5 predicts: full fans in the odd-sum rows, odd charges only in the even-sum rows. (At $0/1$ the charge is $-n<0$ and at $1/1$ it is $m-n>0$, which is why those rows are one-sided: the ideal points are endpoints of the slope interval $(0,1)$.)

**Spoke densities.** Counting seeds with $m \le 20000$ on the ray of charge $k$ at $p/q$, normalised by the number $M/q$ of admissible $m$:

| $p/q$ | $k$ | count | count$/(M/q)$ | $\varphi(K)/K$ |
|---|---|---|---|---|
| $1/3$ | $1$ | $6666$ | $0.9999$ | $1$ |
| $1/3$ | $3$ | $4444$ | $0.6666$ | $0.6667$ |
| $1/5$ | $5$ | $3200$ | $0.8000$ | $0.8$ |
| $1/2$ | $3$ | $3333$ | $0.3333$ | $0.6667$ |
| $1/2$ | $6$ | $3333$ | $0.3333$ | $0.3333$ |

The odd/odd rows ($p+q$ even) realise the density $\varphi(K)/K$ of Theorem 7.4 exactly. The rows with $p+q$ odd lose a further factor $2$ when $K$ is odd — precisely the parity split of Theorem 7.3, since in that regime the parity of the node is *not* automatic and only one of the two residue classes mod $2$ survives.

**Visibility.** At $y=1/2$, $\varepsilon=1/10$ the resolved centres in $(0,1]$ number $\sum_{q\le5}\varphi(q) = 10$, and the enumerated list is $1/1,1/2,1/3,2/3,1/4,3/4,1/5,2/5,3/5,4/5$.

---

## 11. Discussion

The results assemble into one statement: **the star map produced by embedding the Berggren tree into the hyperbolic plane is a picture of the rational numbers, and every visible feature of it is exactly computable.**

- *Where the rays are.* At every rational $p/q$, one ray per integer charge $\chi = pm-qn$, all of them concurrent at $p/q$.
- *What a ray is.* A hypercycle at hyperbolic distance $\operatorname{arsinh}(|\chi|/q)$ from the geodesic over $p/q$; the charge is a hyperbolic width.
- *Which rays exist.* All of them when $p+q$ is odd; exactly the odd ones when $p+q$ is even. The axis, charge $0$, holds at most the single node $(q,p)$.
- *Which fans one sees.* Those with $q \le y/\varepsilon$: the Farey fractions of level $\lfloor y/\varepsilon\rfloor$, counted by $\sum_{q\le Q}\varphi(q)$.
- *What a low ray means.* Good Diophantine approximation: $|n/m - p/q| \le K/(qm) \iff |\chi|\le K$; the innermost rays are Farey neighbours, and every node is an innermost node of two fans.
- *How thick a ray is.* Arithmetic density $\varphi(|k|)/|k|$, exactly $2\varphi(|k|)$ nodes per window of $2|k|$ parameters.
- *How the fans relate.* The tree transports them by an integral linear action that conserves the charge, preserves primitivity, and — decisively — preserves the parity of $p+q$.

Two structural lessons deserve emphasis.

**Unimodularity is the engine.** Nearly every statement above is proved by the same manoeuvre: substitute the unimodular parametrisation $(m,n) = (kb+sq,\ ka+sp)$ and observe that a determinant-one substitution transports arithmetic faithfully. Coprimality of the node becomes coprimality of $(k,s)$; parity of the node becomes an affine congruence in $s$; the ordering $0<n<m$ becomes a linear inequality in $s$. Once the change of variables is in place, "which rays carry nodes and how densely" is a question about coprime residues in a window, and the answer is a totient.

**Geometry becomes arithmetic, exactly.** The visibility law is the sharpest example: "which fans does the plot resolve" is *a priori* a question about pixels, but the adjacent-ray gap is exactly $y/q$, with no error term, so the answer is literally "the Farey fractions of level $\lfloor y/\varepsilon\rfloor$". Nothing hyperbolic survives in the final statement. The same collapse happens with the hypercycle levels — a transcendental $\operatorname{arsinh}$ of a rational — and with the charge/approximation dictionary, where the error $n/m-p/q$ is *identically* $-\chi/(qm)$.

Finally, the parity invariant is worth dwelling on. It is a two-valued conserved quantity of a free ternary tree acting on the projective line over $\mathbb{Q}$, and it partitions the fans into two eternally separated families. That the two most conspicuous features of the picture — the fan at $0$ and the fan at $1$ — sit on opposite sides of this partition is the reason the picture looks lopsided, and no reparametrisation, rerooting or relabelling can make it symmetric.

---

## 12. Future directions

**Farey visibility asymptotic.** With $Q = \lfloor y/\varepsilon\rfloor$, the number of resolved fans is $\Phi(Q) = \sum_{q\le Q}\varphi(q)$, and the expected asymptotic is
$$\Phi(Q) = \frac{3}{\pi^2}Q^2 + O(Q\log Q).$$
The reduction of the geometric visibility question to $\Phi(Q)$ is complete and exact, so what remains is purely analytic. The payoff would be the first quantitative prediction about the picture itself: doubling the resolution quadruples the number of visible fans. Falsifiable by any enumeration whose ratio $\Phi(Q)/Q^2$ stabilises away from $3/\pi^2 = 0.30396\ldots$

**Exact node count on a ray.** On the ray of odd charge $k$ at an odd/odd rational $p/q$, the number of nodes with first coordinate at most $M$ should be
$$\frac{\varphi(|k|)}{|k|}\cdot\frac{M}{q} \;+\; O\big(\sigma_0(|k|) + q\big),$$
where $\sigma_0$ is the divisor-counting function. The exact periodic count is already known — $2\varphi(|k|)$ nodes per window of $2|k|$ consecutive parameters — so the only missing ingredient is the passage from the parameter $s$ to the seed size through the linear map $m = kb + sq$; the density is forced and the error is an edge effect.

**The even-sum fans.** The totient law was proved for $p$ and $q$ both odd, where the parity condition on the node is automatic. When $p+q$ is odd the parity condition selects one residue class of $s$ modulo $2$, and the numerical table shows the density halving when $K$ is odd but not when $K$ is even. Formulating and proving the exact four-case density law (parity of $p+q$ against parity of $K$) would complete Section 7.

**Angular equidistribution.** Do the nodes with hypotenuse in $[N,2N]$ equidistribute over the corresponding hyperbolic annulus? Equivalently, how are the slopes $n/m$ of seeds distributed? The star structure says the answer is far from a smooth density at any finite resolution: the fans impose a Farey-type filtration, and the equidistribution statement, if true, must hold only after averaging past the resolution scale.

**Modular interpretation of transport.** The three transports $T_1,T_2,T_3$ generate a subgroup of $\mathrm{GL}_2(\mathbb{Z})$ acting on star parameters. Identifying that group and its orbit structure on primitive $(p,q)$ — with the parity of $p+q$ as the obvious invariant, and the ladder $k/(k+1)$ as one explicit orbit — would place the fan system inside modular-curve geometry, where the parity dichotomy should appear as a cusp-width phenomenon.

**Higher stars and the second layer.** Every rational carries a fan, and a node lies on one ray of each of infinitely many fans. Is there a canonical "second-order" structure — a fan of fans — organising the star centres themselves? The ladder theorem, which collapses infinitely many fans onto the $0$-fan, is a first hint that the star centres inherit a tree structure of their own.

---

## Appendix: worked numbers

**Charges of small seeds at several centres.** Entries are $\chi_{p/q}(m,n) = pm-qn$.

| seed $(m,n)$ | at $0/1$ | at $1/1$ | at $1/2$ | at $1/3$ | at $2/5$ |
|---|---|---|---|---|---|
| $(2,1)$ | $-1$ | $1$ | $0$ | $-1$ | $-1$ |
| $(3,2)$ | $-2$ | $1$ | $-1$ | $-3$ | $-4$ |
| $(4,1)$ | $-1$ | $3$ | $2$ | $1$ | $3$ |
| $(5,2)$ | $-2$ | $3$ | $1$ | $-1$ | $0$ |
| $(7,4)$ | $-4$ | $3$ | $-1$ | $-5$ | $-6$ |
| $(8,1)$ | $-1$ | $7$ | $6$ | $5$ | $11$ |
| $(9,4)$ | $-4$ | $5$ | $1$ | $-3$ | $-2$ |
| $(12,5)$ | $-5$ | $7$ | $2$ | $-3$ | $-1$ |

Every entry in the $1/1$ and $1/3$ columns is odd, as Theorem 3.1 requires; the $1/2$ and $2/5$ columns take both parities. The single zero, at $(2,1)$ under $1/2$, is the unique axis node of that fan (Theorem 3.2), and it is the root of the tree.

**Hypercycle levels.** The node $(3,2)$ has charge $-1$ at $1/2$, hence lies at hyperbolic distance $\operatorname{arsinh}(1/2)=0.481212\ldots$ from the geodesic over $1/2$; the node $(7,4)$ has charge $-5$ at $1/3$, hence distance $\operatorname{arsinh}(5/3) = 1.28380\ldots$ from the geodesic over $1/3$; the node $(12,5)$ has charge $7$ at $1/1$, hence distance $\operatorname{arsinh}(7) = 2.64412\ldots$ from the geodesic over $1$.

**Farey counts.** $\Phi(Q) = \sum_{q\le Q}\varphi(q)$ for $Q=1,\ldots,10$: $1, 2, 4, 6, 10, 12, 18, 22, 28, 32$. The ratios $\Phi(Q)/Q^2$ are $1, 0.5, 0.444, 0.375, 0.4, 0.333, 0.367, 0.344, 0.346, 0.32$, drifting towards $3/\pi^2 = 0.30396\ldots$
