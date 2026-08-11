# Stars at Every Rational: The Berggren Tree of Pythagorean Triples in the Poincaré Half-Plane

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Plot the Berggren ternary tree of primitive Pythagorean triples in the Poincaré upper half-plane $\mathbb{H}$ using the Euclid embedding $z(m,n) = (n+i)/m$, and the result is not a diffuse cloud of points but a *star map*: pencils of straight rays radiate from the ideal points $0$ and $1$, and — less conspicuously but unmistakably — from $1/2$, from $1/3$, from $1/5$, and from every other visible rational on the boundary. This paper explains the phenomenon completely.

The organising object is a single integral linear form. For a rational ideal point $p/q$ in lowest terms and a Euclid seed $(m,n)$, define the **charge**
$$\chi_{p/q}(m,n) \;=\; pm - qn \;\in\; \mathbb{Z}.$$
We prove:

1. **The ray identity.** $\dfrac{p}{q} - \operatorname{Re}z(m,n) = \dfrac{\chi_{p/q}(m,n)}{q}\cdot \operatorname{Im}z(m,n)$, so the nodes of a fixed charge lie on one Euclidean ray emanating from $p/q$. These rays are the visible radial lines.
2. **The rays are hypercycles.** The hyperbolic distance from $z(m,n)$ to the complete geodesic joining $p/q$ to $\infty$ is exactly $\operatorname{arsinh}\!\big(|\chi_{p/q}(m,n)|/q\big)$: the star at $p/q$ is a discrete pencil of equidistant curves, at the quantised levels $\operatorname{arsinh}(k/q)$.
3. **Quantisation and the exact fan.** If $p+q$ is even (equivalently $p$ and $q$ are both odd) then every seed has *odd* charge at $p/q$: half the rays carry nothing. If $p+q$ is odd, every integer charge is realised, including $0$; and the charge-zero ray — the axis of the star — carries exactly one node, the seed $(q,p)$. For $p/q = 1/2$ that node is $(2,1)$, the root of the whole tree. Every admissible ray carries infinitely many nodes.
4. **A totient density law.** Each ray is parametrised unimodularly by an integer $s$ through $(m,n) = (kb+sq,\ ka+sp)$, where $pb-qa=1$; the node attached to $s$ is a genuine seed precisely under a coprimality condition on $(|k|,s)$. Consequently, on a ray of odd charge $k$ at an odd/odd rational, every window of $2|k|$ consecutive parameters contains exactly $2\varphi(|k|)$ nodes. A ray is always infinite, but its arithmetic density is $\varphi(|k|)/|k|$: rays of highly composite charge are visibly sparser.
5. **The Diophantine dictionary.** $\dfrac{n}{m} - \dfrac{p}{q} = -\dfrac{\chi_{p/q}(m,n)}{qm}$, so the rays of the star at $p/q$ are exactly the levels of approximation quality of $p/q$ by the slope $n/m$. The innermost ray $|\chi|=1$ consists of the Farey neighbours of $p/q$, and every node with $m \ge 2$ sits on the innermost ray of two distinct stars of denominator smaller than $m$.
6. **The visibility law.** At plot height $y$, adjacent rays of the star at $p/q$ are exactly $y/q$ apart. Hence at resolution $\varepsilon$ only the stars with $q \le y/\varepsilon$ are resolved, and the set of visible star centres in $(0,1]$ is the Farey set of level $Q=\lfloor y/\varepsilon\rfloor$, of cardinality $\sum_{q\le Q}\varphi(q)$ — ten centres at $Q=5$.
7. **Star transport.** Each of the three tree moves acts linearly on the star parameter $(p,q)$, carrying the fan at one rational to the fan at another and preserving the charge exactly. Transport preserves primitivity and the parity of $p+q$; consequently the all-charge $0$-star and the odd-charge $1$-star lie in different transport classes, and their visual asymmetry is permanent. The star at $k/(k+1)$ is carried onto the $0$-star by the word $B_1^{\,k}$, so infinitely many of the visible fans are one and the same fan, transported.

**Keywords:** Pythagorean triples, Berggren tree, Poincaré half-plane, hypercycle, charge, Euler totient, Farey fractions, Diophantine approximation, star transport.

---

## 1. Introduction

Two classical objects meet in this paper.

The **Berggren tree**, described by B. Berggren in 1934 and rediscovered many times since, exhibits the primitive Pythagorean triples as an infinite ternary tree rooted at $(3,4,5)$: three fixed integer matrices generate every primitive triple exactly once. It is the standard example of a free arithmetic structure.

The **Poincaré upper half-plane** $\mathbb{H} = \{z\in\mathbb{C} : \operatorname{Im}z>0\}$, with the metric $ds = |dz|/\operatorname{Im}z$, is the standard model of the hyperbolic plane. Its ideal boundary is $\mathbb{R}\cup\{\infty\}$, its geodesics are the vertical half-lines and the semicircles orthogonal to $\mathbb{R}$, and its distance obeys
$$\cosh d_{\mathbb{H}}(z,w) \;=\; 1 + \frac{|z-w|^2}{2\operatorname{Im}z\,\operatorname{Im}w}. \tag{1.1}$$

The bridge between them is Euclid's parametrisation, which converts a triple into a pair of integers $(m,n)$ and hence into a point of $\mathbb{H}$. When one plots the resulting point set, the picture is startlingly organised. Straight lines fan out from the ideal point $0$ and from the ideal point $1$; on close inspection more fans appear at $0.5$, at $0.333\ldots$, at $0.2$; and a single ray marches away from the base point in even strides.

The purpose of this paper is to prove that every feature of that picture is a theorem, and in particular to answer three questions raised by looking at it:

* **Which rationals carry fans?** All of them. Every rational boundary point $p/q$ carries a quantised pencil of radial lines, of angular spacing $1/q$ (Section 3).
* **Why are some fans half-empty and others full?** Because of a parity obstruction which depends only on the parity of $p+q$ (Sections 4 and 5).
* **Why does the eye see only the fans at $0,1,\tfrac12,\tfrac13,\tfrac15$?** Because the fan at $p/q$ has Euclidean ray spacing $y/q$ at plot height $y$, so only small denominators are resolvable; the visible centres are the Farey fractions of a level fixed by the plotting resolution (Section 8).

Section 2 fixes notation and recalls the geometry of the embedding. Sections 3–9 contain the main results. Section 10 gives algorithms, Section 11 discusses the picture as a whole, and Section 12 lists open problems.

---

## 2. The embedding

### 2.1 Seeds, triples, and the three moves

**Definition 2.1 (Euclid seed).** A pair $(m,n)$ of positive integers is a *Euclid seed* if
$$0 < n < m, \qquad \gcd(m,n)=1, \qquad m+n \text{ odd}.$$

The map $(m,n)\mapsto (m^2-n^2,\ 2mn,\ m^2+n^2)$ is a bijection from Euclid seeds onto primitive Pythagorean triples with the even leg listed second. We write $c = c(m,n) = m^2+n^2$ for the **hypotenuse** and $t = n/m \in (0,1)$ for the **slope**. The root seed is $(2,1)$, giving $(3,4,5)$.

**Definition 2.2 (Berggren moves in seed coordinates).**
$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n).$$

These are Euclid's conjugates of the three classical Berggren matrices acting on triples.

**Proposition 2.3.** Each move carries Euclid seeds to Euclid seeds.

*Proof.* Positivity and $n'<m'$ follow from $0<n<m$. A common divisor of $2m-n$ and $m$ divides $n$, hence divides $\gcd(m,n)=1$; the other two moves are identical in this respect. Finally each move changes the coordinate sum by an even amount, so the oddness of $m+n$ persists. $\square$

Berggren's theorem asserts that iterating the three moves from $(2,1)$ produces every Euclid seed exactly once. The proof is a descent: given a seed $(M,N)\ne(2,1)$, its parent is $(M-2N,N)$ if $M>3N$, $(N,M-2N)$ if $2N<M\le 3N$, and $(N,2N-M)$ if $M\le 2N$; the first coordinate strictly decreases, and the degenerate boundary cases $M=2N$, $M=3N$ are excluded by coprimality and parity.

### 2.2 The half-plane embedding and the radial law

**Definition 2.4.** For a Euclid seed put
$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \frac{n}{m} + \frac{i}{m} \;\in\; \mathbb{H},$$
with base point $i$. Since $\operatorname{Im}z = 1/m$ recovers $m$ and $\operatorname{Re}z = n/m$ then recovers $n$, the embedding is injective.

**Theorem 2.5 (Radial law).** For all $m \ge 1$, $n \ge 0$,
$$\cosh d_{\mathbb{H}}\big(i,\,z(m,n)\big) \;=\; \frac{m^2+n^2+1}{2m} \;=\; \frac{c+1}{2m}.$$

*Proof.* Apply $(1.1)$ with $z=i$, $w=(n+i)/m$: $\operatorname{Im}w = 1/m$ and $|z-w|^2 = \big(n^2+(m-1)^2\big)/m^2$, so $\cosh d = 1 + \tfrac{m}{2}\cdot\big(n^2+(m-1)^2\big)/m^2 = (m^2+n^2+1)/(2m)$. $\square$

**Corollary 2.6 (Trajectory window).** $\tfrac12\log c \le d_{\mathbb{H}}(i,z(m,n)) \le \tfrac12\log\big(2(c+1)\big)$, so the radius of a node is $\tfrac12\log c$ up to an additive error confined to $[0,\tfrac12\log2 + 1/2c]$.

*Proof.* $\cosh(\tfrac12\log c) = (c+1)/(2\sqrt c)$, so the lower bound is $m\le\sqrt c$, which is $m^2\le m^2+n^2$. For the upper bound, $\cosh d \le e^d \le 2\cosh d$ gives $d\le \log\big((c+1)/m\big)$, and $n<m$ forces $2m^2 \ge c+1$, whence $(c+1)/m \le \sqrt{2(c+1)}$. $\square$

So the hypotenuse is, up to a bounded error, the exponential of twice the hyperbolic radius. The angular structure of the picture is the subject of the rest of the paper.

### 2.3 The hypercycle theorem

A *hypercycle* is a curve of constant hyperbolic distance from a geodesic. In the half-plane, the geodesic joining a real point $x$ to $\infty$ is the vertical ray $\gamma_x = \{x+is : s>0\}$, and its hypercycles are the Euclidean rays emanating from $x$.

**Theorem 2.7 (Hypercycle theorem).** Let $z\in\mathbb{H}$ satisfy $x - \operatorname{Re}z = \lambda\operatorname{Im}z$ for a real $\lambda$. Then
$$d_{\mathbb{H}}(z, \gamma_x) \;=\; \operatorname{arsinh}|\lambda|,$$
the infimum being attained at the point of $\gamma_x$ of height $\operatorname{Im}(z)\sqrt{1+\lambda^2}$.

*Proof.* With $y = \operatorname{Im}z$ and $w = x+is$, formula $(1.1)$ gives
$$\cosh d(z,w) = \frac{(\operatorname{Re}z-x)^2 + y^2 + s^2}{2ys} = \frac{(1+\lambda^2)y^2+s^2}{2ys} \;\ge\; \sqrt{1+\lambda^2}$$
by the arithmetic–geometric mean inequality, with equality exactly at $s = y\sqrt{1+\lambda^2}$. Since $\operatorname{arcosh}\sqrt{1+\lambda^2} = \operatorname{arsinh}|\lambda|$, the claim follows. $\square$

Theorem 2.7 is the reason the "straight lines" of the picture are geometrically meaningful: a Euclidean ray from a boundary point is not a geodesic, but it is the next best thing — a level set of the distance to one.

---

## 3. The charge at a rational ideal point

We now fix a rational boundary point and measure how a node sits relative to it.

**Definition 3.1 (Charge).** Let $p/q$ be a rational in lowest terms, with $q \ge 1$. The **charge** of the integral pair $(m,n)$ at $p/q$ is the integral linear form
$$\chi_{p/q}(m,n) \;=\; pm - qn.$$

Two special cases are the classical ones: $\chi_{0/1}(m,n) = -n$ and $\chi_{1/1}(m,n) = m-n$. These recover the two conspicuous stars of the picture, at the ideal points $0$ and $1$.

**Theorem 3.2 (The ray identity).** For every $m\ge1$ and $n\ge0$,
$$\frac{p}{q} - \operatorname{Re}z(m,n) \;=\; \frac{\chi_{p/q}(m,n)}{q}\cdot \operatorname{Im}z(m,n).$$
Hence the nodes of a fixed charge $k$ at $p/q$ all lie on the single Euclidean ray through $p/q$ of parameter $k/q$.

*Proof.* $\dfrac{p}{q} - \dfrac{n}{m} = \dfrac{pm-qn}{qm} = \dfrac{\chi_{p/q}(m,n)}{q}\cdot\dfrac1m$. $\square$

**Theorem 3.3 (The rays are hypercycles).** For every seed $(m,n)$,
$$d_{\mathbb{H}}\Big(z(m,n),\ \gamma_{p/q}\Big) \;=\; \operatorname{arsinh}\frac{\big|\chi_{p/q}(m,n)\big|}{q},$$
where $\gamma_{p/q}$ is the complete geodesic joining $p/q$ to $\infty$. The distance depends on the node only through the charge; the star at $p/q$ is therefore a discrete pencil of hypercycles at the quantised levels $\operatorname{arsinh}(k/q)$, $k \in \mathbb{Z}$.

*Proof.* Combine Theorems 3.2 and 2.7 with $\lambda = \chi_{p/q}(m,n)/q$. $\square$

This is the exact sense in which the radial lines exist: they are not artefacts of the plotting, and they are not geodesics; they are the level sets of the hyperbolic distance to the vertical geodesic over $p/q$, and the levels form a discrete quantised ladder whose rung spacing is governed by $1/q$.

**Corollary 3.4 (The innermost rung and the visibility hierarchy).** Every node off the axis of the star at $p/q$ lies at distance at least $\operatorname{arsinh}(1/q)$ from that axis, and the sub-fan of charges $|k| \le K$ is confined to a band of hyperbolic width $\operatorname{arsinh}(K/q)$. The lower bound is attained: the seed $(3,2)$ realises the level $\operatorname{arsinh}(1/2)$ at the star $1/2$. Since $q\mapsto \operatorname{arsinh}(1/q)$ is strictly decreasing, a star of large denominator is squeezed into a thin pencil.

*Proof.* Immediate from Theorem 3.3 and $|\chi|\ge1$ for a non-zero integer, together with the computation $\chi_{1/2}(3,2) = 1\cdot3 - 2\cdot2 = -1$. $\square$

---

## 4. Quantisation: which rays can carry nodes

Not every rung of the ladder is occupied. The obstruction is a parity condition, and it depends only on the parity of $p+q$.

**Theorem 4.1 (Parity quantisation).** Suppose $p$ and $q$ are both odd — equivalently, $p+q$ is even. Then every Euclid seed has *odd* charge at $p/q$. Thus half the rays of the pencil at such a rational are empty.

*Proof.* Write $\chi = pm - qn$. Since $m+n$ is odd, exactly one of $m,n$ is even. If $m$ is even then $n$ is odd, and $pm$ is even while $qn$ is odd, so $\chi$ is odd; if $m$ is odd then $n$ is even, $pm$ is odd and $qn$ is even, and again $\chi$ is odd. $\square$

For $p=q=1$ this is the classical statement that the $1$-star realises only the odd parameters $u=m-n$; the theorem shows the phenomenon is not special to $1$, but is shared by $1/3$, $1/5$, $3/5$, $3/7$, … — every fan whose centre has both entries odd.

**Example 4.2.** No Euclid seed has charge $2$ at $1/3$: the ray of parameter $2/3$ from the ideal point $1/3$ is entirely empty, and so is every even ray of that fan.

**Theorem 4.3 (The axis carries at most one node).** Let $q>0$, $\gcd(p,q)=1$, and let $(m,n)$ be a Euclid seed. Then $\chi_{p/q}(m,n)=0$ if and only if $(m,n)=(q,p)$.

*Proof.* $\chi=0$ says $pm = qn$. Since $\gcd(p,q)=1$, $q \mid m$; since $\gcd(m,n)=1$ and $m \mid qn$ (as $pm = qn$ and $m\mid pm$), we get $m \mid q$. Hence $m=q$, and cancelling $m$ in $mp = mn$ gives $n = p$. The converse is the computation $pq - qp = 0$. $\square$

**Theorem 4.4 (Axis dichotomy).** For coprime $0<p<q$, the axis of the star at $p/q$ carries a node if and only if $p+q$ is odd.

*Proof.* By Theorem 4.3 the only candidate is $(q,p)$, which satisfies $0<p<q$ and $\gcd(q,p)=1$ automatically; it is a Euclid seed precisely when $q+p$ is odd. $\square$

**Example 4.5.** The stars at $1/2$, $1/4$, $2/5$ have a node exactly on their centre line; those at $1/3$, $1/5$, $3/5$ have a *hole* along the axis. The axis node of the star at $1/2$ is the seed $(2,1)$ — the root of the entire tree, the triple $(3,4,5)$. So the fan visible at $0.5$ is centred on the tree's own origin.

---

## 5. Realisation: every admissible ray is infinite

Quantisation says which rays *cannot* carry nodes. The converse — that every unobstructed ray really is populated, and infinitely so — needs a construction. It comes from a unimodular change of variables that trades the node coordinates $(m,n)$ for the pair (charge, parameter).

**Definition 5.1 (Ray parametrisation).** Let $\gcd(p,q)=1$ and choose integers $a,b$ with $pb-qa=1$. For a charge $k$ and a parameter $s\in\mathbb{Z}$ set
$$\Sigma(k,s) \;=\; \big(kb+sq,\ ka+sp\big) \;\in\; \mathbb{Z}^2.$$

**Proposition 5.2 (Dictionary).** For all $k,s$:

1. $\chi_{p/q}\big(\Sigma(k,s)\big) = k$, identically in $s$;
2. $s$ is recovered from the pair by $s = b\,n - a\,m$, so $\Sigma$ is a bijection of $\mathbb{Z}^2$ onto $\mathbb{Z}^2$;
3. $m+n = k(a+b) + s(p+q)$, so the parity of the node is an explicit affine function of $s$;
4. $\gcd(k,s)=1$ if and only if $\gcd(m,n)=1$.

*Proof.* (1) $p(kb+sq) - q(ka+sp) = k(pb-qa) = k$. (2) $b(ka+sp) - a(kb+sq) = s(pb-qa) = s$. (3) Immediate. (4) The substitution has determinant $pb-qa=1$, so it is invertible over $\mathbb{Z}$; a Bézout relation for $(k,s)$ transports to one for $(m,n)$ through (1) and (2), and conversely. $\square$

Item (4) is the crux: the arithmetic of the node has been transported verbatim to the arithmetic of the pair (charge, parameter). Coprimality of the seed is no longer a condition on two large numbers whose relation to the ray is opaque, but a condition on $k$ and $s$ alone.

**Theorem 5.3 (Realisation).** Let $0<p<q$ be coprime and let $k \ne 0$ be an integer, required to be odd in the case $p+q$ even. Then for every bound $M$ there exists a Euclid seed $(m,n)$ with $m>M$ and $\chi_{p/q}(m,n)=k$.

*Sketch.* Take $\Sigma(k,s)$ and choose the parameter $s$ in a suitable residue class modulo $2$ (fixing the parity of $m+n$ via Proposition 5.2(3)) and coprime to $k$ (securing $\gcd(m,n)=1$ via 5.2(4)). Such $s$ exist in every long enough interval — if $p+q$ is odd the parity of $m+n$ can be switched freely by moving $s$ by $1$, and if $p+q$ is even the parity of $m+n$ equals that of $k(a+b)$, which the hypothesis that $k$ be odd, together with $pb-qa=1$ forcing $a+b$ odd, makes odd as required. Taking $s$ large makes $m = kb+sq$ exceed $M$, and $0<n<m$ holds for all large $s$ because $0<p<q$. $\square$

**Corollary 5.4 (Every admissible ray is infinite).** Under the hypotheses of Theorem 5.3, the set of Euclid seeds of charge $k$ at $p/q$ is infinite.

**Theorem 5.5 (The exact fan).** For coprime $0<p<q$, the set of charges realised by Euclid seeds at $p/q$ is
$$\big\{\chi_{p/q}(m,n) : (m,n) \text{ a Euclid seed}\big\} \;=\;
\begin{cases}
\mathbb{Z}, & p+q \text{ odd},\\[2pt]
\{k \in \mathbb{Z} : k \text{ odd}\}, & p+q \text{ even}.
\end{cases}$$

*Proof.* If $p+q$ is odd: charge $0$ is realised by the axis node of Theorem 4.4, and every $k\ne0$ by Theorem 5.3. If $p+q$ is even: only odd charges occur by Theorem 4.1, and every odd charge occurs by Theorem 5.3. $\square$

Theorem 5.5 is the complete description of a fan. It says the picture contains exactly two kinds of star: *full* stars, with a node on the axis and a ray at every integer level, and *half stars*, with an empty axis and rays only at the odd levels. The type is read off from the parity of $p+q$: the ideal point $0 = 0/1$ is full, the ideal point $1 = 1/1$ is a half star, $1/2$ is full, $1/3$ and $1/5$ are half stars.

---

## 6. How densely a ray is populated: a totient law

A ray is infinite; how thick is it? The unimodular dictionary reduces the question to counting integers coprime to a fixed modulus in a window, which is exactly what Euler's totient function does.

**Theorem 6.1 (Coprimality is the only obstruction at an odd/odd rational).** Let $0<p<q$ be coprime with $p$ and $q$ both odd, let $k$ be an odd charge, and let $a,b$ satisfy $pb-qa=1$. Then for all parameters $s$ beyond an explicit bound depending only on $(k,a,b)$, the pair $\Sigma(k,s)$ is a Euclid seed if and only if $\gcd(|k|,s)=1$.

*Sketch.* Beyond the bound $|ka|+|kb|+|k(b-a)|+1$, the inequalities $0 < ka+sp < kb+sq$ hold, because $0<p<q$ makes both $sp$ and $s(q-p)$ dominate the constant terms. Coprimality of the pair is equivalent to $\gcd(k,s)=1$ by Proposition 5.2(4). Parity is automatic: $p+q$ is even and $a+b$ is odd (since $pb-qa=1$ with $p,q$ odd forces $b-a$ odd), so $m+n = k(a+b)+s(p+q)$ is odd for odd $k$, independently of $s$. $\square$

The parity condition — the very condition that switches off half the rays at such a rational — has been absorbed once and for all, leaving pure coprimality. Counting is now classical.

**Theorem 6.2 (Window counts).** For all $K \ge 1$ and all $N \ge 0$:

1. $\#\{s \in [N, N+2K) : \gcd(K,s)=1\} = 2\varphi(K)$;
2. $\#\{s \in [N,N+2K) : \gcd(K,s)=1,\ s \text{ odd}\} = \varphi(2K)$;
3. $\#\{s \in [N,N+2K) : \gcd(K,s)=1,\ s \text{ even}\} = 2\varphi(K)-\varphi(2K)$;
4. if $K$ is odd, both parity classes contain exactly $\varphi(K)$ parameters.

*Proof.* (1) Split the window of length $2K$ into two windows of length $K$; each contains exactly $\varphi(K)$ integers coprime to $K$, since the coprimality condition is periodic modulo $K$ and one full period contains $\varphi(K)$ of them. (2) $\gcd(2K,s)=1$ if and only if $\gcd(K,s)=1$ and $s$ is odd; a window of length $2K$ is one full period of the modulus $2K$ and so contains $\varphi(2K)$ integers coprime to it. (3) Subtract (2) from (1). (4) For odd $K$, multiplicativity gives $\varphi(2K)=\varphi(2)\varphi(K)=\varphi(K)$, and then (3) also yields $\varphi(K)$. $\square$

**Theorem 6.3 (Totient density law for a ray).** Let $0<p<q$ be coprime with $p,q$ both odd, let $k$ be an odd charge and put $K=|k|$. Then in every window of $2K$ consecutive parameters beyond the bound of Theorem 6.1, the ray of charge $k$ at $p/q$ carries exactly
$$2\varphi(K) \;=\; 2\varphi(2K)$$
nodes of the Berggren tree. The ray is therefore infinite but of arithmetic density $\varphi(K)/K$ in its parameter.

*Proof.* By Theorem 6.1 the seed condition on the window coincides with $\gcd(K,s)=1$; apply Theorem 6.2(1). $\square$

**Example 6.4.** On the ray of charge $15$ at $1/3$, exactly $2\varphi(15)=16$ of every $30$ consecutive parameters give nodes: density $8/15 = 0.5333\ldots$. On the ray of charge $5$ the density is $4/5$; on the ray of charge $1$ it is $1$ — the innermost ray is completely populated. Numerically, counting seeds with $m \le 20000$ on the ray of charge $k$ at $p/q$ and normalising by the number of admissible first coordinates confirms the predicted densities: $1.0000$ at $(p/q,k)=(1/3,1)$, $0.6666$ at $(1/3,3)$, $0.8000$ at $(1/5,5)$.

So the arithmetic thickness of a ray is a purely multiplicative invariant of its charge. A ray of prime charge $\ell$ is nearly full, of density $1-1/\ell$; a ray whose charge has many distinct prime factors is thin. This is visible: the innermost rays of a fan are solid lines of points, and the outer rays of composite charge are perceptibly dotted.

---

## 7. What the charge means: Diophantine approximation and Farey neighbours

The charge is not only a geometric level. It is the numerator of an approximation error.

**Theorem 7.1 (Approximation dictionary).** For $q,m \ge 1$,
$$\frac{n}{m} - \frac{p}{q} \;=\; -\,\frac{\chi_{p/q}(m,n)}{qm}.$$
Consequently, for every real $K$,
$$\Big|\frac{n}{m}-\frac{p}{q}\Big| \le \frac{K}{qm} \iff \big|\chi_{p/q}(m,n)\big| \le K.$$

*Proof.* $\dfrac{n}{m}-\dfrac{p}{q} = \dfrac{qn-pm}{qm}$, which is $-\chi/(qm)$; the equivalence follows on dividing by the positive quantity $qm$. $\square$

The rays of the star at $p/q$ are therefore exactly the levels of approximation quality: a node lies on a low ray precisely when $p/q$ is a strong rational approximation to its slope, in the scale-invariant sense $|t-p/q| \le |k|/(qm)$. The innermost ray, $|\chi| = 1$, is the classical unimodular condition.

**Theorem 7.2 (Farey's theorem).** Let $q,m,s>0$ and suppose $qn-pm=1$. If $r/s$ lies strictly between $p/q$ and $n/m$, then $s \ge q+m$.

*Sketch.* Unimodularity gives $\dfrac{n}{m}-\dfrac{p}{q} = \dfrac1{qm}$. From $p/q < r/s$ and $r/s < n/m$ we get, clearing denominators, the integer inequalities $ps < rq$ and $rm < ns$, i.e. $rq - ps \ge 1$ and $ns - rm \ge 1$. Then
$$\frac{1}{qm} = \frac{n}{m}-\frac{p}{q} = \Big(\frac{n}{m}-\frac{r}{s}\Big) + \Big(\frac{r}{s}-\frac{p}{q}\Big) = \frac{ns-rm}{ms} + \frac{rq-ps}{qs} \;\ge\; \frac{1}{ms}+\frac{1}{qs},$$
and multiplying by $qms>0$ yields $s \ge q+m$. $\square$

**Theorem 7.3 (Sharpness).** The mediant $\dfrac{p+n}{q+m}$ lies strictly between $p/q$ and $n/m$, so the bound $q+m$ is attained.

*Proof.* Under $qn-pm=1$ one computes $\dfrac{p+n}{q+m}-\dfrac{p}{q} = \dfrac{qn-pm}{q(q+m)} = \dfrac{1}{q(q+m)}>0$ and $\dfrac{n}{m}-\dfrac{p+n}{q+m} = \dfrac{qn-pm}{m(q+m)}>0$. $\square$

**Corollary 7.4 (The innermost ray is a Farey neighbourhood).** A node of charge $-1$ at $p/q$ has slope differing from $p/q$ by exactly $1/(qm)$, and no rational of denominator smaller than $q+m$ lies strictly between $p/q$ and that slope. The nodes of the innermost ray are, in the precise Farey sense, best approximations to the star centre.

**Theorem 7.5 (Two principal stars).** Every Euclid seed $(m,n)$ with $m\ge2$ lies on the innermost ray of two *distinct* stars whose denominators are smaller than $m$: there are $(p,q)$ and $(p',q')$ with $0<q,q'<m$, $\chi_{p/q}(m,n) = -1$ and $\chi_{p'/q'}(m,n) = +1$.

*Sketch.* Since $\gcd(m,n)=1$ there are integers $u,v$ with $un+vm=1$. Reduce $u$ modulo $m$ to get $q \in (0,m)$ with $qn \equiv 1 \pmod m$, and let $p = (qn-1)/m$; then $qn-pm=1$, i.e. the charge at $p/q$ is $-1$. Replacing $q$ by $m-q$ and adjusting $p$ correspondingly gives a second star of denominator in $(0,m)$ at which the charge is $+1$. The two pairs are distinct because the charges differ. $\square$

So the fans are not a feature of a few privileged rationals with the rest of the tree scattered between them: *every* node is an innermost, best-approximation node of two different fans, each of smaller denominator than the node's own height parameter. The star system is a partition of the tree seen twice over, once from each side.

---

## 8. Visibility: why only a few fans are seen

If every rational carries a fan, the eye should see a uniform blur. It does not, and the reason is a resolution law.

**Theorem 8.1 (Separation at a fixed height).** Two nodes at the same height $y=1/m$ whose charges at $p/q$ differ by $d$ are separated in the real part by exactly
$$\frac{|d|}{qm} \;=\; \frac{|d|\,y}{q}.$$

*Proof.* $\operatorname{Re}z(m,n)-\operatorname{Re}z(m,n') = (n-n')/m$, and $\chi_{p/q}(m,n)-\chi_{p/q}(m,n') = -q(n-n')$. Substituting gives the claim. $\square$

**Corollary 8.2 (Adjacent ray gap).** At plot height $y$, two adjacent rays of the star at $p/q$ — charges $k$ and $k+1$ — are exactly $y/q$ apart.

**Theorem 8.3 (Resolution criterion).** Fix a plot height $y>0$ and a resolution $\varepsilon>0$. The star at $p/q$ is resolved at that height — meaning adjacent rays are at least $\varepsilon$ apart — if and only if
$$q \;\le\; \frac{y}{\varepsilon}.$$

*Proof.* $\varepsilon \le y/q \iff q\varepsilon \le y \iff q \le y/\varepsilon$, all quantities being positive. $\square$

**Definition 8.4.** For $Q\ge1$ let $\mathcal{F}(Q)$ be the set of star centres $p/q \in (0,1]$ in lowest terms with $q \le Q$.

**Theorem 8.5 (Farey count).** $\#\mathcal{F}(Q) = \sum_{q=1}^{Q}\varphi(q)$.

*Proof.* For each $q\le Q$, the admissible numerators are the $p\in[1,q]$ coprime to $q$, of which there are $\varphi(q)$; distinct denominators contribute disjoint sets of fractions in lowest terms. $\square$

**Corollary 8.6 (Visibility law).** At plot height $y$ and resolution $\varepsilon$, the set of resolvable star centres in $(0,1]$ is exactly $\mathcal{F}(Q)$ with $Q=\lfloor y/\varepsilon\rfloor$, a finite set of cardinality $\sum_{q\le Q}\varphi(q)$.

**Example 8.7.** At $y=1/2$ and a resolution of one part in ten, $Q=5$ and the resolvable centres are the ten fractions
$$\tfrac11,\ \tfrac12,\ \tfrac13,\ \tfrac23,\ \tfrac14,\ \tfrac34,\ \tfrac15,\ \tfrac25,\ \tfrac35,\ \tfrac45,$$
together with the centre $0$. This is precisely the list of fans a rendering at that scale displays — and it is why $0$, $1$, $0.5$, $0.333\ldots$ and $0.2$ are the star centres one notices first. Sharpening the resolution by a factor of $2$ takes $Q$ to $10$ and the count to $32$; by a factor of $10$ it takes $Q$ to $50$ and the count to $774$. Empirically $\sum_{q\le Q}\varphi(q)/Q^2$ takes the values $0.3200$, $0.3096$, $0.3044$, $0.3045$ at $Q = 10, 50, 100, 500$, consistent with the classical density $3/\pi^2 = 0.303964\ldots$ (Conjecture 12.1 below).

---

## 9. Star transport: the tree permutes the fans

The final structural fact is that the fans are not independent. The tree moves them.

**Definition 9.1 (Transport).** Define three linear maps on the star parameter $v=(p,q)\in\mathbb{Z}^2$:
$$T_1(p,q) = (2p-q,\ p), \qquad T_2(p,q) = (2p-q,\ -p), \qquad T_3(p,q) = (p,\ q-2p).$$

**Theorem 9.2 (Covariance).** For each $i \in \{1,2,3\}$ and all integral $(p,q)$ and $(m,n)$,
$$\chi_{(p,q)}\big(B_i(m,n)\big) \;=\; \chi_{T_i(p,q)}(m,n),$$
where $\chi_{(p,q)}(m,n)$ denotes $pm-qn$ for the (not necessarily reduced) parameter $(p,q)$.

*Proof.* Three polynomial identities. For $B_1$: $p(2m-n)-qm = (2p-q)m - pn$. For $B_2$: $p(2m+n)-qm = (2p-q)m + pn = (2p-q)m - (-p)n$. For $B_3$: $p(m+2n)-qn = pm - (q-2p)n$. $\square$

So a Berggren move does not merely relocate a node; it carries the entire fan at one rational onto the fan at another, *preserving the charge exactly*. The stars form a single orbit structure under the tree action, which is the conceptual reason no rational boundary point is exceptional.

**Theorem 9.3 (Transport preserves primitivity).** If $\gcd(p,q)=1$ then $\gcd$ of the entries of $T_i(p,q)$ is $1$, for each $i$; hence transport acts on rational ideal points in lowest terms. For a word $w$ in the three moves, write $T_w$ for the composite.

*Proof.* Each $T_i$ has determinant $\pm1$, hence is invertible over $\mathbb{Z}$ and preserves the ideal generated by the two entries. $\square$

**Theorem 9.4 (Parity is a transport invariant).** For each $i$ and each $(p,q)$, the sum of the entries of $T_i(p,q)$ has the same parity as $p+q$; hence so does $T_w(p,q)$ for every word $w$.

*Proof.* $(2p-q)+p = 3p-q \equiv p+q$, $(2p-q)-p = p-q \equiv p+q$, and $p+(q-2p) = q-p \equiv p+q$, all modulo $2$. $\square$

**Corollary 9.5 (The two classical stars are permanently different).** No word of Berggren moves transports the $0$-star $(0,1)$ to the $1$-star $(1,1)$, or conversely: their parameter sums have opposite parities. The visual asymmetry between the all-charge fan at $0$ and the odd-charge fan at $1$ is therefore intrinsic, not an artefact of the choice of root.

**Theorem 9.6 (The ladder collapses).** For every $k\ge0$, the word $B_1^{\,k}$ transports the star at $k/(k+1)$ onto the $0$-star:
$$T_{1}^{\,k}\big(k,\ k+1\big) \;=\; (0,1).$$
Moreover $\gcd(k,k+1)=1$ and $k+(k+1)$ is odd, so by Theorem 5.5 each ladder star realises *every* integer charge.

*Proof.* $T_1(k+1, k+2) = (2(k+1)-(k+2),\ k+1) = (k,\ k+1)$, so one application of $T_1$ walks the ladder down by one rung; induct, terminating at $(0,1)$. $\square$

Thus infinitely many of the visible fans — the ones at $1/2, 2/3, 3/4, 4/5, \ldots$, marching up towards the ideal point $1$ — are one single fan seen through different tree words. They are all of $0$-type: full, with an occupied axis. And none of them is ever a transport of the $1$-star, by Corollary 9.5. The picture consists of exactly two tree-inequivalent flavours of star, distinguished by a single bit of arithmetic.

---

## 10. Algorithms

**Algorithm A (Charge and ray data).** Given a rational $p/q$ in lowest terms and a seed $(m,n)$, return: the charge $k = pm-qn$; the hypercycle level $\operatorname{arsinh}(|k|/q)$; the Euclidean ray parameter $k/q$; the approximation error $n/m - p/q = -k/(qm)$; and the flag $|k|=1$ marking a Farey neighbour. Constant time.

**Algorithm B (Ray enumeration by the unimodular parametrisation).** Given $p/q$, a charge $k$, and a bound $M$: compute $(a,b)$ with $pb-qa=1$ by the extended Euclidean algorithm; then for $s$ from the bound $|ka|+|kb|+|k(b-a)|+1$ upwards, emit $\Sigma(k,s) = (kb+sq,\ ka+sp)$ whenever the arithmetic test holds — for $p,q,k$ all odd this test is simply $\gcd(|k|,s)=1$, and in general it is $\gcd(k,s)=1$ together with the parity of $k(a+b)+s(p+q)$. Cost $O(\log q)$ for the Bézout step and $O(\log |k|)$ per emitted node, versus $O(M)$ for a scan of all seeds.

**Algorithm C (Fan classification).** Given $p/q$: return "full" if $p+q$ is odd, listing the axis node $(q,p)$, and "half" if $p+q$ is even, in which case the axis is empty and only odd charges occur. Constant time. Together with Algorithm B this reconstructs the entire fan.

**Algorithm D (Resolved star centres).** Given a plot height $y$ and a resolution $\varepsilon$: set $Q = \lfloor y/\varepsilon\rfloor$ and emit all $p/q$ in lowest terms with $1 \le p \le q \le Q$. The output has $\sum_{q\le Q}\varphi(q)$ elements, computable in $O(Q\log\log Q)$ by a totient sieve, and the enumeration itself is $O(Q^2)$ with a $\gcd$ test or $O(Q^2)$ amortised by a Farey traversal.

**Algorithm E (Ray density).** Given an odd charge $k$ at an odd/odd rational: return the exact window count $2\varphi(|k|)$ per $2|k|$ consecutive parameters and the density $\varphi(|k|)/|k|$; the totient is computed from the factorisation of $|k|$ in $O(\sqrt{|k|})$ by trial division.

**Algorithm F (Star transport).** Given a word $w \in \{1,2,3\}^*$ and a star parameter $(p,q)$: fold the three linear maps $T_1,T_2,T_3$ along $w$. The result is the star whose fan the word carries onto the fan at $(p,q)$, with charges preserved. Cost $O(|w|)$; the parity of the parameter sum is invariant and can be used as a $O(1)$ obstruction test before running the fold.

---

## 11. Discussion

The results assemble into a single statement: **the star map is exact.** Every straight line the eye finds in the plot of the Berggren tree is a hypercycle for a rational ideal point, indexed by an integral charge; the set of occupied levels is determined by a parity bit; the population of each level is a totient; the set of levels one can actually see is a Farey set; and the tree action permutes the whole system by an integral linear representation on the star parameter.

Several features deserve comment.

**The charge is a triple invariant in disguise.** Written back in terms of the underlying Pythagorean triple $(A,B,C) = (m^2-n^2, 2mn, m^2+n^2)$, the charge $pm-qn$ is a linear form in the Euclid coordinates, which are the "square roots" of the triple. Its two classical instances $n$ and $m-n$ are, respectively, half the ratio $B/(2m)$ and the quantity whose square appears in $A = (m-n)(m+n)$. That such a modest form controls the entire hyperbolic angular geometry of the embedding is a consequence of the transparency of the embedding: $\operatorname{Im}z = 1/m$ and $\operatorname{Re}z = n/m$ are the seed coordinates barely disguised, so hyperbolic invariants become rational functions of $m$ and $n$, and the only transcendental step is a single $\operatorname{arsinh}$, which monotonicity removes.

**Two kinds of star, and only two.** The dichotomy in Theorem 5.5 is not a curiosity of small cases. It is enforced by an invariant of the tree action (Theorem 9.4), which means that the classification of fans into "full" and "half" is stable under the entire dynamics. In particular, the classical asymmetry between the $0$-star, which realises every charge, and the $1$-star, which realises only odd charges, is now explained: the two ideal points lie in different parity classes and no amount of tree motion can exchange them.

**Density is multiplicative.** Theorem 6.3 says a ray of charge $k$ has density $\varphi(|k|)/|k| = \prod_{\ell \mid k}(1-1/\ell)$ over the primes $\ell$ dividing $k$. This is directly visible in a high-resolution plot: rays of prime charge look continuous, and rays of charge $15$ or $105$ look dotted. It is also the first place where the arithmetic of the *label* of a ray, rather than of the nodes on it, becomes geometrically observable.

**Visibility is a Farey phenomenon.** Theorem 8.3 converts a question about seeing into a question about denominators, and Theorem 8.5 converts the count into the summatory totient. The practical upshot is a prediction about pictures: doubling the plotting resolution should approximately *quadruple* the number of discernible fans, since $\sum_{q\le Q}\varphi(q)$ grows quadratically in $Q$.

**Every node participates twice.** Theorem 7.5 removes the last suspicion that the fans might be a sparse decoration on a generic cloud. Each node is a best-approximation node — an innermost-ray node — for two different star centres of smaller denominator. The star structure is exhaustive.

---

## 12. Future directions

**Conjecture 12.1 (Farey visibility asymptotic).** The number of fans resolved at resolution $\varepsilon$ and height $y$ is
$$\#\mathcal{F}(Q) \;=\; \sum_{q\le Q}\varphi(q) \;=\; \frac{3}{\pi^2}Q^2 + O(Q\log Q), \qquad Q = \lfloor y/\varepsilon\rfloor.$$
The reduction from a geometric visibility question to the summatory totient is complete (Theorems 8.3 and 8.5); what remains is purely analytic, and nothing about hyperbolic geometry survives in it. The statement would be the first quantitative prediction about the picture itself: doubling the resolution quadruples the number of visible fans. Falsifiable by any enumeration whose ratio $\#\mathcal{F}(Q)/Q^2$ stabilises away from $3/\pi^2 = 0.30396\ldots$

**Conjecture 12.2 (Exact node count on a ray).** On the ray of odd charge $k$ at an odd/odd rational $p/q$, the number of nodes with first coordinate at most $M$ is
$$\frac{\varphi(|k|)}{|k|}\cdot\frac{M}{q} \;+\; O\big(\sigma_0(|k|) + q\big),$$
where $\sigma_0$ is the divisor-counting function. The window law already gives the exact periodic count $2\varphi(|k|)$ nodes per $2|k|$ consecutive parameters, so the only missing ingredient is the translation from the parameter $s$ to the seed size $m$, which is the linear map $m = kb+sq$; the density is therefore forced and the error term is an edge effect.

**Extension of the density law to mixed-parity centres.** Theorem 6.3 assumes $p$ and $q$ both odd, which makes the parity condition on nodes automatic. When $p+q$ is odd the parity condition genuinely constrains the parameter, and Theorem 6.2(2)–(3) predicts a count of $\varphi(2|k|)$ or $2\varphi(|k|)-\varphi(2|k|)$ per window depending on the residue class. Numerically, at $p/q=1/2$ the ray of charge $3$ has density $1/3$ rather than $2/3$ — exactly the predicted extra factor of $2$ for odd charge. Formulating and proving the mixed-parity law would complete Theorem 6.3.

**Equidistribution of charges.** Fix a large bound $M$ and consider the charges at $p/q$ of all seeds with $m\le M$. How are they distributed? The approximation dictionary suggests the distribution is governed by that of the slopes $n/m$, and one expects a limiting profile independent of $p/q$ after rescaling by $q$. Making this precise would explain the observed brightness profile of a fan.

**Modular interpretation.** The three moves generate a subgroup of $\mathrm{PGL}_2(\mathbb{Z})$, and the transport action of Definition 9.1 is its contragredient representation on the star parameter. Identifying the precise congruence subgroup, and matching the parity invariant of Theorem 9.4 against its cusps, would place the whole star picture inside modular-curve geometry; the two star types should appear as two cusp classes, with the quantisation asymmetry visible as a cusp width.

**Transport orbits of fans.** Theorem 9.6 shows the ladder $k/(k+1)$ collapses to the $0$-star. What are the full orbits of the transport action on primitive $(p,q)$? Since the parity of $p+q$ is invariant, there are at least two orbits; are there exactly two? A positive answer would say that the picture contains, up to the tree symmetry, precisely two distinct fans.

**The residual as a height.** The radius of a node is $\tfrac12\log c$ plus a residual confined to $[0,\tfrac12\log 2)$, and the residual is an explicitly computable bounded function on the tree that behaves like a Lyapunov function for the dynamics. Is it a local height in the Arakelov sense, and does its interplay with the charge — the radial and angular coordinates of the same node — encode anything further about the triple?

---

## Appendix A. Numerical tables

**A.1 Realised charges.** Charges $|k|\le 8$ realised by Euclid seeds with $m\le600$:

| star $p/q$ | $p+q$ | realised charges |
|---|---|---|
| $0/1$ | odd | $-8,\ldots,-1$ |
| $1/1$ | even | $1,3,5,7$ |
| $1/2$ | odd | $-8,\ldots,8$ (including $0$) |
| $1/3$ | even | $\pm1,\pm3,\pm5,\pm7$ |
| $1/5$ | even | $\pm1,\pm3,\pm5,\pm7$ |
| $2/5$ | odd | $-8,\ldots,8$ |
| $3/5$ | even | $\pm1,\pm3,\pm5,\pm7$ |
| $1/4$ | odd | $-8,\ldots,8$ |

(The stars at $0$ and $1$ are boundary points of the slope interval $(0,1)$, so only one sign occurs there.)

**A.2 The totient window law.** Number of nodes among $2|k|$ consecutive parameters on the ray of charge $k$:

| star | $k$ | observed | $2\varphi(|k|)$ | density $\varphi/|k|$ |
|---|---|---|---|---|
| $1/3$ | $1$ | $2$ | $2$ | $1.0000$ |
| $1/3$ | $3$ | $4$ | $4$ | $0.6667$ |
| $1/3$ | $5$ | $8$ | $8$ | $0.8000$ |
| $1/3$ | $9$ | $12$ | $12$ | $0.6667$ |
| $1/3$ | $15$ | $16$ | $16$ | $0.5333$ |
| $3/5$ | $15$ | $16$ | $16$ | $0.5333$ |

**A.3 Hypercycle levels.** The level $\operatorname{arsinh}(|k|/q)$ of the ray of charge $k$ at $p/q$:

| star | $k$ | level | sample nodes |
|---|---|---|---|
| $1/3$ | $1$ | $0.327450$ | $(4,1), (7,2), (10,3), (13,4)$ |
| $1/3$ | $3$ | $0.881374$ | $(6,1), (9,2), (15,4), (18,5)$ |
| $1/2$ | $3$ | $1.194763$ | $(7,2), (11,4), (19,8), (23,10)$ |
| $1/1$ | $3$ | $1.818446$ | $(4,1), (5,2), (7,4), (8,5)$ |

**A.4 Visibility.** Resolved star centres at plot height $y=1/2$:

| resolution $\varepsilon$ | $Q=\lfloor y/\varepsilon\rfloor$ | centres in $(0,1]$ |
|---|---|---|
| $0.1$ | $5$ | $10$ |
| $0.05$ | $10$ | $32$ |
| $0.01$ | $50$ | $774$ |
| $0.001$ | $500$ | $76116$ |

**A.5 Radii.** For comparison, the radial data of small seeds; $c=m^2+n^2$, $d=\operatorname{arcosh}\big((c+1)/2m\big)$:

| seed | triple | $c$ | $d$ | $d-\tfrac12\log c$ |
|---|---|---|---|---|
| $(2,1)$ | $(3,4,5)$ | $5$ | $0.962424$ | $0.157705$ |
| $(3,2)$ | $(5,12,13)$ | $13$ | $1.490996$ | $0.208522$ |
| $(4,1)$ | $(15,8,17)$ | $17$ | $1.450575$ | $0.033968$ |
| $(5,2)$ | $(21,20,29)$ | $29$ | $1.762747$ | $0.079099$ |
| $(12,5)$ | $(119,120,169)$ | $169$ | $2.645871$ | $0.080922$ |
| $(29,12)$ | $(697,696,985)$ | $985$ | $3.525494$ | $0.079174$ |

All residuals lie in $[0,\tfrac12\log2) = [0,0.346574)$, as Corollary 2.6 requires.
