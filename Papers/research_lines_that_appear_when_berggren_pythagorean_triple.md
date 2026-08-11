# The Rational Stars of the Berggren Tree: Charge Quantisation, Resolution, and a Totient Brightness Law

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We give a complete arithmetic and metric analysis of the radial line structure that appears when the Berggren ternary tree of primitive Pythagorean triples is embedded in the Poincaré upper half-plane by the Euclid map $z(m,n) = (n+i)/m$. Rendered, the node set exhibits pencils ("stars") of straight lines emanating from certain boundary points — conspicuously $0$ and $1$, and more faintly near $0.2$, $0.33$, $0.5$ — together with one distinguished ray into the interior. We prove that these features are governed by four exact laws.

Attached to each boundary rational $p/q$ in lowest terms and each node $z(m,n)$ is the **star charge** $k = qn - pm$. We show that the node lies on the Euclidean line $\operatorname{Re} z = p/q + (k/q)\operatorname{Im} z$, that this line is a hypercycle at hyperbolic distance exactly $\operatorname{arsinh}(|k|/q)$ from the geodesic over $p/q$, that consecutive nodes along it are at hyperbolic distances tending to $0$, and that the line converges to its ideal tip $p/q$.

The four laws are then: **(i) Quantisation** — if $p$ and $q$ are both odd, every charge is odd, and conversely every integer permitted by this parity constraint is the charge of infinitely many nodes, realised by an explicit $\mathrm{SL}_2(\mathbb{Z})$ construction; the charge $0$ occurs iff $(q,p)$ is itself a Euclid seed, i.e. iff $p+q$ is odd. **(ii) Resolution** — nodes on distinct rays of the star at $p/q$ have $\sinh$-widths differing by at least $\delta(p/q)$, where $\delta = 1/q$ if $p+q$ is odd and $2/q$ if $p,q$ are both odd, and the bound is attained; consequently the boundary rationals of $[0,1]$ with $\delta \ge 2/5$ are exactly $0, \tfrac15, \tfrac13, \tfrac12, \tfrac35, 1$, which is precisely the observed list of visible fans (with $\tfrac14$ correctly excluded by the even-denominator penalty), and for every $\varepsilon > 0$ only finitely many rationals have $\delta \ge \varepsilon$. **(iii) Brightness** — in ray coordinates the two Euclid-seed conditions collapse to $\gcd(A,k)=1$, so a window of $2k$ consecutive ray parameters carries exactly $2\varphi(k)$ nodes when $p,q$ are both odd or when $k$ is even, and exactly $\varphi(k) = \varphi(2k)$ in the remaining mixed regime; unit rays are completely full. **(iv) Rationality of stars** — two nodes collinear with an irrational ideal point coincide, so no star exists off $\mathbb{Q}$.

We complement this with the metric background — the radial law $\cosh d(i,z(m,n)) = (m^2+n^2+1)/(2m)$, the step-length trichotomy separating the parabolic fan orbits (steps $\to 0$) from the hyperbolic Pell spine (steps $\to \log(1+\sqrt2)$), and the ball count $\Theta(e^{2R})$ — and derive a no-free-lunch theorem: for a hypotenuse collision witnessing a factorisation of $N$ with extracted divisor $g$, the two witnesses satisfy $d \ge \log g - \log 2$, while the smallest ball guaranteed to contain both already holds $\Theta(N)$ nodes. Geodesic search in this embedding cannot beat exhaustive search.

**Keywords:** Pythagorean triples, Berggren tree, Poincaré half-plane, hypercycle, star charge, Euler totient, parabolic and hyperbolic Möbius dynamics, Pell equation, integer factorisation, volume growth.

---

## 1. Introduction

### 1.1 The two objects

Let $\mathbb{H} = \{z \in \mathbb{C} : \operatorname{Im} z > 0\}$ be the upper half-plane with the hyperbolic metric $ds = |dz|/\operatorname{Im} z$, whose distance function satisfies
$$\cosh d(z,w) \;=\; 1 + \frac{|z-w|^2}{2\operatorname{Im}z\,\operatorname{Im}w},$$
whose geodesics are the vertical half-lines and the semicircles orthogonal to $\mathbb{R}$, and whose ideal boundary is $\mathbb{R}\cup\{\infty\}$.

Let the **Euclid seeds** be the pairs of positive integers $(m,n)$ with
$$0 < n < m, \qquad \gcd(m,n) = 1, \qquad m+n \text{ odd},$$
so that $(m,n)\mapsto(m^2-n^2,\,2mn,\,m^2+n^2)$ is a bijection onto the primitive Pythagorean triples. Berggren's theorem states that the three maps
$$B_1(m,n) = (2m-n,\ m), \qquad B_2(m,n) = (2m+n,\ m), \qquad B_3(m,n) = (m+2n,\ n)$$
generate every Euclid seed from the root $(2,1)$ exactly once, so that the seeds form an infinite ternary tree.

### 1.2 The embedding and the phenomenon

**Definition 1.1.** For a Euclid seed $(m,n)$ put
$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \frac nm + \frac im \;\in\; \mathbb{H}.$$
The map is injective: $\operatorname{Im}z = 1/m$ recovers $m$, and $\operatorname{Re}z = n/m$ then recovers $n$.

Rendering the node set $\{z(m,n)\}$ for $m$ up to a few hundred produces a picture with unmistakable large-scale structure: sharp pencils of straight lines radiating from the ideal points $0$ and $1$, weaker pencils near $0.2$, $0.\overline{3}$ and $0.5$, no pencil near $0.25$, and a single bright ray moving into the interior. This paper explains every one of those features exactly.

### 1.3 Organisation

Section 2 fixes the metric background and the radial law. Section 3 defines the star charge and proves that the fans are hypercycles of shrinking step length converging to their ideal tips. Section 4 proves the quantisation law and the realisation theorem, and combines them into the charge spectrum. Section 5 proves the resolution law and the finite visibility hierarchy, and identifies the visible rationals. Section 6 proves the totient brightness law. Section 7 shows that no star exists at an irrational point, and relates this to the dynamics of the three moves. Section 8 gives the collision geometry and the no-free-lunch theorem. Sections 9–11 give algorithms, discussion, and open problems.

---

## 2. Metric background: the radial law

**Theorem 2.1 (Exact radial formula).** For every $m \ge 1$ and $n \ge 0$,
$$\cosh d_{\mathbb{H}}\big(i,\ z(m,n)\big) \;=\; \frac{m^2+n^2+1}{2m} \;=\; \frac{c+1}{2m},$$
where $c = m^2+n^2$ is the hypotenuse of the associated triple.

*Proof.* Put $z = i$, $w = (n+i)/m$. Then $\operatorname{Im}w = 1/m$ and
$$|z-w|^2 = \frac{n^2}{m^2} + \Big(1-\frac1m\Big)^2 = \frac{n^2 + (m-1)^2}{m^2},$$
so $\cosh d = 1 + \tfrac m2 \cdot \tfrac{n^2+(m-1)^2}{m^2} = \tfrac{2m + n^2 + m^2 - 2m + 1}{2m}$. $\square$

The hypotenuse thus appears as the numerator of a hyperbolic cosine, although the embedding used only the ratios $n/m$ and $1/m$.

**Theorem 2.2 (Logarithmic trajectory law).** For every Euclid seed,
$$\tfrac12\log c \;\le\; d_{\mathbb{H}}\big(i, z(m,n)\big) \;\le\; \tfrac12\log\big(2(c+1)\big),$$
so $\big|d - \tfrac12\log c\big| \le \log 2$.

*Proof.* Since $\cosh$ is increasing on $[0,\infty)$ and $\cosh(\tfrac12\log c) = (c+1)/(2\sqrt c)$, the lower bound is equivalent to $m \le \sqrt c$, i.e. $m^2 \le m^2+n^2$. For the upper bound, $\cosh d \le e^d \le 2\cosh d$ gives $d \le \log((c+1)/m)$, and $n<m$ forces $n^2+1\le m^2$, i.e. $2m^2 \ge c+1$, whence $(c+1)/m \le \sqrt{2(c+1)}$. $\square$

**Corollary 2.3 (Trajectory window).** The residual $\rho(m,n) = d(i,z(m,n)) - \tfrac12\log c$ satisfies $0 \le \rho \le \tfrac12\log 2 + 1/(2c)$: every node lies in a hyperbolic annulus of width $\approx \tfrac12\log 2 = 0.34657\ldots$ around the sphere of radius $\tfrac12\log c$.

**Theorem 2.4 (Exact two-node distance).** For $m,m'\ge1$, $n,n'\ge0$,
$$\cosh d_{\mathbb{H}}\big(z(m,n),\ z(m',n')\big) \;=\; \frac{(nm'-n'm)^2 + m^2 + m'^2}{2mm'} .$$

*Proof.* $\operatorname{Im}z\operatorname{Im}w = 1/(mm')$ and $|z-w|^2 = \big((nm'-n'm)^2 + (m'-m)^2\big)/(m^2m'^2)$; substitute into the distance formula and simplify. $\square$

The integer $nm'-n'm$, the **seed cross product**, is the sole arithmetic invariant entering the metric.

Finally we record the distance from a point to a vertical geodesic, which is what converts the visual "straight lines" into hyperbolic objects.

**Theorem 2.5 (Hypercycle theorem).** Let $x \in \mathbb{R}$, let $\gamma_x$ be the vertical geodesic from $x$ to $\infty$, and let $z\in\mathbb{H}$ satisfy $\operatorname{Re}z - x = u \operatorname{Im}z$. Then
$$\sinh d(z, \gamma_x) = |u|, \qquad\text{equivalently}\qquad d(z,\gamma_x) = \operatorname{arsinh}|u|,$$
the infimum being attained at the point of $\gamma_x$ of height $\operatorname{Im}(z)\sqrt{1+u^2}$.

*Proof.* With $w = x+is$ and $y = \operatorname{Im}z$,
$$\cosh d(z,w) = 1 + \frac{u^2y^2 + (y-s)^2}{2ys} = \frac{(1+u^2)y^2 + s^2}{2ys} \;\ge\; \sqrt{1+u^2}$$
by AM–GM, with equality iff $s = y\sqrt{1+u^2}$; and $\cosh d = \sqrt{1+u^2}$ means $\sinh d = |u|$. $\square$

Thus a Euclidean straight line through an ideal point is a **hypercycle**: a curve of constant hyperbolic distance from a geodesic, not itself a geodesic unless $u = 0$.

---

## 3. Star charges and the geometry of a single ray

### 3.1 Definition and the line equation

**Definition 3.1 (Star charge).** For a boundary rational $p/q$ (with $q>0$, $\gcd(p,q)=1$) and a node $z(m,n)$, the **star charge** is the integer
$$k(p,q;m,n) \;=\; qn - pm .$$

**Theorem 3.2 (Equation of the radial line).** For $m,q>0$,
$$\operatorname{Re}z(m,n) \;=\; \frac pq \;+\; \frac{k}{q}\,\operatorname{Im}z(m,n).$$

*Proof.* $\operatorname{Re}z = n/m$, $\operatorname{Im}z = 1/m$, and $\tfrac nm - \tfrac pq = \tfrac{qn-pm}{qm} = \tfrac kq \cdot \tfrac 1m$. $\square$

So the nodes of a fixed charge at a fixed rational are exactly collinear along one Euclidean line through $p/q$: the **ray** of charge $k$. Its parameter is $k/q$.

**Corollary 3.3 (A ray is a hypercycle of width $\operatorname{arsinh}(|k|/q)$).** Combining Theorems 2.5 and 3.2,
$$\sinh d_{\mathbb{H}}\big(z(m,n),\ \gamma_{p/q}\big) \;=\; \frac{|k(p,q;m,n)|}{q} .$$
In particular two nodes with the same charge at $p/q$ are at equal hyperbolic distance from $\gamma_{p/q}$: the ray is a hypercycle, and the charge is (up to the factor $q$) the hyperbolic width.

**Lemma 3.4 (Charge is a lattice invariant).** $k(p,q; m+tq,\ n+tp) = k(p,q;m,n)$ for all $t$. So the integer points of a ray are the lattice translates of one another by the primitive vector $(q,p)$.

*Proof.* $q(n+tp) - p(m+tq) = qn-pm$. $\square$

### 3.2 The arithmetic of a ray, and unit rays

**Lemma 3.5.** Any common divisor $d$ of $m$ and $n$ divides $k(p,q;m,n)$.

*Proof.* $k = qn - pm$ is an integer combination of $m$ and $n$. $\square$

**Theorem 3.6 (Unit rays are fully populated).** Let $(m,n)$ be a Euclid seed with $|k(p,q;m,n)| = 1$ and $p<q$. Then $(m+2tq,\ n+2tp)$ is a Euclid seed for every $t \ge 0$.

*Proof.* Positivity and $n' < m'$ follow from $p<q$. Coprimality: the gcd of the translated pair divides its charge (Lemma 3.5), which is $\pm1$ by Lemma 3.4. Parity: $(m+2tq)+(n+2tp) = (m+n) + 2t(p+q)$ has the same parity as $m+n$. $\square$

Thus on a ray of charge $\pm1$ no coprimality sieve operates at all; only the parity translation step $2(q,p)$ is needed. These are the **brightest lines** of every rational star.

### 3.3 Steps along a ray and the ideal tip

**Theorem 3.7 (Cross product along a ray).** For nodes at lattice distance $t$ along the ray of charge $k$,
$$n\,(m + tq) - (n+tp)\,m \;=\; t\,k .$$
Consequently, by Theorem 2.4,
$$\cosh d\big(z(m,n),\ z(m+tq,\ n+tp)\big) \;=\; \frac{(tk)^2 + m^2 + (m+tq)^2}{2m(m+tq)} .$$

**Theorem 3.8 (Steps along a ray tend to zero).** Fix $p/q$ and a node $(m,n)$ with $m,q>0$, and let $z_j = z(m+2jq,\ n+2jp)$. Then
$$\cosh d(z_j, z_{j+1}) \;=\; 1 \;+\; \frac{4k^2 + 4q^2}{2\,(m+2jq)\,(m+2jq+2q)} \;\longrightarrow\; 1,$$
hence $d(z_j,z_{j+1}) \to 0$ as $j \to \infty$.

*Proof.* Apply Theorem 3.7 with $t = 2$ at the node $(m+2jq,\ n+2jp)$, whose charge is again $k$ by Lemma 3.4; the displayed identity follows after simplification. Since $m+2jq \ge 2j+1$, the error term is $O(1/j^2)$ and tends to $0$; monotonicity of $\cosh$ on $[0,\infty)$ transfers this to the distances. $\square$

**Theorem 3.9 (A ray converges to its ideal tip).** With $z_j$ as above, $z_j \to p/q$ in $\mathbb{C}$.

*Proof.* $|\operatorname{Re}z_j - p/q| = |k| / \big(q(m+2jq)\big)$ by Theorem 3.2, and $\operatorname{Im}z_j = 1/(m+2jq)$; both are $O(1/j)$. $\square$

Theorems 3.8 and 3.9 together say that a ray renders as a *smooth straight line gliding into the boundary*, rather than as a scatter of separated dots: this is the visual mechanism by which the fans become visible at all.

---

## 4. Quantisation and realisation: the charge spectrum

### 4.1 The parity obstruction

**Theorem 4.1 (Quantisation at a both-odd rational).** If $p$ and $q$ are both odd and $(m,n)$ is a Euclid seed, then $k(p,q;m,n)$ is odd.

*Proof.* Work modulo $2$. Since $p \equiv q \equiv 1$ and $m+n \equiv 1$, we get $k = qn - pm \equiv n + m \equiv 1$. $\square$

So at a both-odd rational, exactly half of the pencil — the even-charge rays — is empty.

### 4.2 The $\mathrm{SL}_2(\mathbb{Z})$ realisation

The converse requires producing, for each admissible charge, infinitely many seeds. The right change of variables is a Bézout matrix.

**Lemma 4.2 (Determinant-one change of variables).** Suppose $qx - py = 1$ with $x,y \in \mathbb{Z}$. If $A,k \in \mathbb{Z}$ are coprime, then
$$m = qA + yk, \qquad n = pA + xk$$
are coprime, and satisfy $k(p,q;m,n) = k$ and $xm - yn = A$.

*Proof.* The matrix $\begin{pmatrix} q & y \\ p & x\end{pmatrix}$ has determinant $qx-py = 1$, hence lies in $\mathrm{SL}_2(\mathbb{Z})$ and preserves primitivity of integer vectors; explicitly, if $uA + vk = 1$ then $(ux - vp)m + (vq-uy)n = u(xm-yn) + v(qn-pm) = uA + vk = 1$. The identities $qn - pm = k(qx-py) = k$ and $xm - yn = A(qx-py) = A$ are direct. $\square$

**Theorem 4.3 (Realisation of every admissible charge).** Let $0 < p < q$ with $\gcd(p,q)=1$, let $k \ne 0$ be an integer which is odd in case $p+q$ is even, and let $B$ be any bound. Then there is a Euclid seed $(m,n)$ with $m > B$ and $k(p,q;m,n) = k$. Hence every admissible ray of every rational star carries infinitely many nodes.

*Proof sketch.* Choose Bézout data $qx - py = 1$ and set $T = x+y$. Take
$$A \;=\; \big(1 + kT\big) \;+\; 2k^2 j$$
with $j$ a large positive integer, and put $(m,n) = (qA+yk,\ pA+xk)$. Then:

*Coprimality.* $A \equiv 1 \pmod{k}$, so $\gcd(A,k)=1$; Lemma 4.2 gives $\gcd(m,n)=1$.

*Charge.* $k(p,q;m,n) = k$ by Lemma 4.2.

*Parity.* Modulo $2$, $m+n \equiv (p+q)A + Tk$ with $A \equiv 1 + kT$. If $p+q$ is odd, this is $\equiv 1 + kT + Tk = 1$. If $p+q$ is even, then $p$ and $q$ are both odd, and $qx-py=1$ forces $x - y$ odd, hence $T = x+y$ odd; with $k$ odd, $(p+q)A + Tk \equiv 0 + 1 = 1$. Either way $m+n$ is odd. (Both cases are the single $\mathbb{Z}/2$ identity $(P+Q)A + (X+Y)K = 1$ under $QX-PY=1$, $A = 1 + K(X+Y)$, and $P+Q=1$ or $K=1$.)

*Size and ordering.* For $j$ large, $A$ is positive and as large as desired, so $m = qA + yk$ exceeds $B$, $n = pA+xk > 0$, and $m - n = (q-p)A + (y-x)k > 0$ since $q>p$. $\square$

**Theorem 4.4 (The central ray).** Let $0<p<q$ be coprime and let $(m,n)$ be a Euclid seed. Then $k(p,q;m,n) = 0$ iff $(m,n) = (q,p)$. In particular the central ray — the geodesic $\gamma_{p/q}$ itself — carries a node iff $(q,p)$ is a Euclid seed, i.e. iff $p+q$ is odd, and then exactly one.

*Proof.* If $qn = pm$ then $q \mid pm$ with $\gcd(p,q)=1$ gives $q\mid m$, and symmetrically $m \mid q$, so $m = q$ and then $n = p$. Conversely $q\cdot p - p \cdot q = 0$. $\square$

**Theorem 4.5 (Charge spectrum).** Let $0<p<q$ be coprime. An integer $k$ is the star charge at $p/q$ of some Euclid seed if and only if
$$p+q \text{ is odd} \qquad\text{or}\qquad k \text{ is odd}.$$

*Proof.* Necessity: if $p+q$ is even then, $p/q$ being in lowest terms, $p$ and $q$ are both odd, and Theorem 4.1 applies. Sufficiency: for $k \ne 0$ use Theorem 4.3; for $k=0$ the hypothesis forces $p+q$ odd, and $(q,p)$ is then a seed of charge $0$ by Theorem 4.4. $\square$

Thus a star with $p+q$ odd is **fully populated** (every ray, including the central geodesic), while a star with $p,q$ both odd has **only its odd rays**, and no node on its central geodesic.

---

## 5. The resolution law and the visible rationals

**Definition 5.1 (Resolution).** For coprime $p \le q$ with $q>0$ set
$$\operatorname{gap}(p,q) \;=\; \begin{cases} 1, & p+q \text{ odd},\\ 2, & p, q \text{ both odd},\end{cases} \qquad\qquad \delta(p/q) \;=\; \frac{\operatorname{gap}(p,q)}{q}.$$

By Corollary 3.3 the quantity $\sinh d(z, \gamma_{p/q}) = |k|/q$ is the natural "angular coordinate" of the star at $p/q$: it is the observable that separates one ray from the next.

**Theorem 5.2 (Resolution law, lower bound).** Let $p,q$ be as above with $p$ or $q$ odd, and let $(m_1,n_1)$, $(m_2,n_2)$ be Euclid seeds whose charges at $p/q$ satisfy $|k_1| \ne |k_2|$. Then
$$\Big|\sinh d\big(z_1,\gamma_{p/q}\big) - \sinh d\big(z_2, \gamma_{p/q}\big)\Big| \;=\; \frac{\big||k_1| - |k_2|\big|}{q} \;\ge\; \delta(p/q).$$

*Proof.* The equality is Corollary 3.3. For the bound: if $p+q$ is odd, $\big||k_1|-|k_2|\big|$ is a nonzero integer, hence $\ge 1$. If $p,q$ are both odd, both charges are odd by Theorem 4.1, so $|k_1|$ and $|k_2|$ are both odd and their difference is a nonzero even integer, hence $\ge 2$ in absolute value. $\square$

**Theorem 5.3 (Sharpness).** For every coprime $0<p<q$ there exist Euclid seeds $(m_1,n_1)$, $(m_2,n_2)$ with
$$\Big|\sinh d\big(z_1,\gamma_{p/q}\big) - \sinh d\big(z_2,\gamma_{p/q}\big)\Big| \;=\; \delta(p/q).$$

*Proof.* Apply Theorem 4.3 twice, with charges $k_1 = 1$ and $k_2 = 1 + \operatorname{gap}(p,q)$. Both are admissible: $k_1$ is odd always, and $k_2 = 2$ when $p+q$ is odd (admissible since $p+q$ is odd), $k_2 = 3$ when $p,q$ are both odd (admissible since $3$ is odd). Their $\sinh$-widths are $1/q$ and $(1+\operatorname{gap})/q$. $\square$

So $\delta(p/q)$ is exactly the angular resolution of the star at $p/q$: the smaller the denominator, and the *worse* the parity of $p+q$, the more open — hence the more visible — the fan.

**Theorem 5.4 (The visible rationals).** For coprime $p \le q$ with $q > 0$,
$$\delta(p/q) \;\ge\; \tfrac25 \iff \frac pq \in \Big\{\, \tfrac01,\ \tfrac15,\ \tfrac13,\ \tfrac12,\ \tfrac35,\ \tfrac11 \,\Big\}.$$

*Proof.* $\delta \ge 2/5$ forces $q \le 5$ since $\operatorname{gap}\le 2$; a finite check over $q\le5$ and coprime $p\le q$ gives the list. Explicitly, the admitted values are $\delta(0/1) = 1$ (gap $1$), $\delta(1/1) = 2$ (gap $2$), $\delta(1/2) = 1/2$, $\delta(1/3) = 2/3$ (gap $2$), $\delta(1/5) = \delta(3/5) = 2/5$ (gap $2$); the excluded ones are $\delta(2/3) = 1/3$, $\delta(1/4) = \delta(3/4) = 1/4$, and $\delta(2/5) = \delta(4/5) = 1/5$, all below $2/5$. $\square$

Numerically the list is $0,\ 0.2,\ 0.\overline3,\ 0.5,\ 0.6,\ 1$ — exactly the boundary points at which fans are visible in a rendered star map, together with the (initially unnoticed, then confirmed) fan at $0.6$. The exclusion of $1/4 = 0.25$ despite $4 < 5$ is the signature of the parity law: an even denominator forfeits the factor-two bonus.

**Theorem 5.5 (Finite visibility hierarchy).** For every $\varepsilon > 0$, the set of pairs $(p,q)$ with $0 < q$, $p \le q$ and $\delta(p/q) \ge \varepsilon$ is finite.

*Proof.* $\operatorname{gap}(p,q) \le 2$, so $\delta \ge \varepsilon$ forces $q \le 2/\varepsilon$, and then $p \le q$. $\square$

Consequently the star map has a discrete, computable hierarchy of visible directions at every scale: zooming in reveals new fans, always finitely many at a time.

---

## 6. The brightness law: a totient census of a ray

Resolution measures the spacing *between* rays. Brightness measures the density of nodes *along* one ray. The tool is again the Bézout change of variables.

**Definition 6.1 (Ray parameter).** Fix Bézout data $qx - py = 1$. For an integer point $(m,n)$, its **ray parameter** is $A = xm - yn$.

**Lemma 6.2 (Ray coordinates).** With $qx-py=1$ and $k = qn-pm$,
$$m = qA + yk, \qquad n = pA + xk, \qquad m+n = (p+q)A + (x+y)k .$$
Thus $(A,k)$ is a complete coordinate system on $\mathbb{Z}^2$, in which $k$ indexes the ray and $A$ the position along it.

*Proof.* Each is the identity $\big(\text{expression}\big)\cdot(qx-py)$ expanded, using $qx-py=1$. $\square$

**Theorem 6.3 (Coprimality in ray coordinates).** $\gcd(m,n) = 1 \iff \gcd(A,k) = 1$.

*Proof.* Both directions are Bézout manipulations. If $um+vn=1$, then $(uq+vp)A + (uy+vx)k = u m + v n = 1$ using Lemma 6.2. Conversely if $uA+vk=1$, then $(ux-vp)m + (vq-uy)n = u(xm-yn) + v(qn-pm) = uA + vk = 1$. $\square$

This is the structural heart of the census: **the charge is the only arithmetic obstruction along a ray.** In particular, on the unit rays $k=\pm1$ every lattice point is primitive.

The remaining condition is parity, $m+n = (p+q)A + (x+y)k$ odd. There are three regimes.

**Lemma 6.4 (Bézout parity at a both-odd star).** If $p$ and $q$ are both odd and $qx-py=1$, then $x+y$ is odd.

*Proof.* Modulo $2$, $1 = qx - py \equiv x + y$. $\square$

**Lemma 6.5 (Parity-free regimes).** Assume $\gcd(A,k)=1$.
1. If $p,q$ are both odd and $k$ is odd, then $(p+q)A + (x+y)k$ is odd for **every** $A$: indeed $p+q$ is even and $(x+y)k$ is odd by Lemma 6.4.
2. If $p+q$ is odd and $k$ is even, then $A$ must be odd (else $2 \mid \gcd(A,k)$), so $(p+q)A + (x+y)k \equiv 1 \cdot 1 + 0 = 1$ is odd for **every** admissible $A$.

In both cases the only sieve on the ray is $\gcd(A,k) = 1$. $\square$

**Lemma 6.6 (Mixed regime: a parity class).** If $p+q$ is odd and $k$ is odd, then
$$(p+q)A + (x+y)k \ \text{ is odd} \iff A + (x+y) \ \text{ is odd} \iff A \equiv \begin{cases} 1 \pmod 2, & x+y \text{ even},\\ 0 \pmod 2, & x+y \text{ odd}.\end{cases}$$
So the parity condition pins $A$ to a single residue class modulo $2$. $\square$

**Lemma 6.7 (Coprime window count).** For all $k, a \ge 0$,
$$\#\{A \in [a,\ a+2k) : \gcd(A,k) = 1\} \;=\; 2\,\varphi(k) .$$

*Proof.* Split the window into two consecutive windows of length $k$; each contains exactly $\varphi(k)$ integers coprime to $k$, since coprimality to $k$ depends only on $A \bmod k$ and each residue class occurs once. $\square$

**Lemma 6.8 (Coprime window count with a parity class).** For odd $k$ and any $a, e$,
$$\#\{A \in [a,\ a+2k) : \gcd(A,k) = 1,\ A \equiv e \!\!\pmod 2\} \;=\; \varphi(k) .$$

*Proof.* Since $k$ is odd, the map $A \mapsto A$ if $A \equiv e$, else $A \mapsto A+k$, is a bijection from $\{A \in [a,a+k) : \gcd(A,k)=1\}$ onto the set in question: adding $k$ flips the parity while preserving coprimality with $k$, and the image lands in $[a, a+2k)$; the inverse subtracts $k$ from those elements that exceed $a+k$. Hence the count is $\varphi(k)$. $\square$

Putting these together gives the brightness law.

**Theorem 6.9 (Brightness trichotomy).** Fix coprime $p,q$ and Bézout data $qx-py=1$, and let $k \ge 1$ be an admissible charge. Consider a window of $2k$ consecutive ray parameters $A \in [a, a+2k)$. The number of these for which $(qA+yk,\ pA+xk)$ is a Euclid seed is
$$\begin{array}{llll}
\textbf{(i)} & p,q \text{ both odd},\ k \text{ odd:} & \quad 2\varphi(k) & \text{(full brightness)},\\[2pt]
\textbf{(ii)} & p+q \text{ odd},\ k \text{ even:} & \quad 2\varphi(k) & \text{(full brightness)},\\[2pt]
\textbf{(iii)} & p+q \text{ odd},\ k \text{ odd:} & \quad \varphi(k) = \varphi(2k) & \text{(half brightness)}.
\end{array}$$

*Proof.* By Theorem 6.3 the coprimality condition on the node is $\gcd(A,k)=1$. In cases (i) and (ii) the parity condition is then automatic by Lemma 6.5, and Lemma 6.7 gives $2\varphi(k)$. In case (iii) the parity condition is the single congruence of Lemma 6.6, and Lemma 6.8 gives $\varphi(k)$; multiplicativity of $\varphi$ with $k$ odd gives $\varphi(2k) = \varphi(2)\varphi(k) = \varphi(k)$. $\square$

**Corollary 6.10 (Linear density).** The ray of charge $k$ has asymptotic linear density $\varphi(k)/k$ of nodes among its lattice points in the full-brightness regimes, and $\varphi(k)/(2k)$ in the mixed regime. In particular:
- a unit ray ($k = 1$) at a both-odd star is **completely full**: every lattice point is a node;
- a ray of prime charge $r$ has density $1 - 1/r$;
- a ray of charge $105 = 3\cdot5\cdot7$ has density $\tfrac23\cdot\tfrac45\cdot\tfrac67 \approx 0.457$, visibly dotted.

**Remark 6.11 (Conservation of light).** The two laws compensate exactly. At a both-odd star the rays are spaced $2/q$ apart in $\sinh$ but each carries $2\varphi(k)$ nodes per period $2k$; at a mixed-parity star the rays are twice as finely spaced ($1/q$) and each carries half as many, $\varphi(k)$. The total node density near the boundary point is parity-independent; parity only redistributes it between angular resolution and per-ray intensity.

---

## 7. Why the stars sit at the rationals

**Theorem 7.1 (No star at an irrational point).** Let $\alpha$ be irrational and $c \in \mathbb{R}$, and suppose the nodes $z(m,n)$ and $z(m',n')$ both satisfy $\operatorname{Re} z = \alpha + c\operatorname{Im} z$. Then $(m,n) = (m',n')$.

*Proof.* The hypotheses read $n/m = \alpha + c/m$ and $n'/m' = \alpha + c/m'$, i.e. $n = \alpha m + c$ and $n' = \alpha m' + c$. Subtracting, $\alpha(m-m') = n-n'$. If $m \ne m'$, then $\alpha = (n-n')/(m-m') \in \mathbb{Q}$, a contradiction. Hence $m = m'$, and then $n=n'$. $\square$

So although irrational boundary points are limits of nodes — indeed every point of $[0,1]$ is an accumulation point of the node set, since for any $t$ and any large $K$ the pair $(2^K, n)$ with $n$ the odd integer nearest $t\,2^K$ is a Euclid seed — **no irrational point is the centre of a fan.** A fan requires two nodes collinear with its tip; that is a rationality condition.

This dovetails with the dynamics of the three moves. On slopes $t = n/m$,
$$B_1: t \mapsto \frac{1}{2-t}, \qquad B_2: t \mapsto \frac1{2+t}, \qquad B_3: t \mapsto \frac{t}{1+2t},$$
with pairwise disjoint images $(\tfrac12,1)$, $(\tfrac13,\tfrac12)$, $(0,\tfrac13)$ — a trichotomy which also inverts the tree and reproves Berggren's theorem: the parent of $(M,N)\ne(2,1)$ is $(M-2N,N)$ if $M>3N$, $(N,M-2N)$ if $2N<M\le 3N$, and $(N,2N-M)$ if $M \le 2N$.

**Theorem 7.2 (Outer moves are parabolic).** $\dfrac{1}{1-B_1(t)} = \dfrac{1}{1-t}+1$ and $\dfrac{1}{B_3(t)} = \dfrac 1t + 2$. Hence
$$B_1^k(t) = 1 - \frac{1-t}{1+k(1-t)} \to 1, \qquad B_3^k(t) = \frac{t}{1+2kt} \to 0,$$
with the parabolic rates $k(1-B_1^k(t)) \to 1$ and $k\,B_3^k(t) \to \tfrac12$. $\square$

Moreover $B_1$ preserves $m-n$ and $B_3$ preserves $n$; by Theorem 3.2 these are the charges at the ideal points $1$ and $0$. So the $B_1$-orbits are exactly the rays of the $1$-star and the $B_3$-orbits exactly the rays of the $0$-star, in closed form
$$B_1^k(n+u,\ n) = \big(n+(k+1)u,\ n+ku\big), \qquad B_3^k(m,n) = (m+2kn,\ n).$$

**Theorem 7.3 (The middle move is hyperbolic).** $B_2$ fixes the irrational **silver slope** $t_\star = \sqrt2-1$ and satisfies $|B_2(s)-B_2(t)| = |s-t|/((2+s)(2+t)) \le |s-t|/4$ for $s,t\ge0$; hence $|B_2^k(t)-t_\star| \le 4^{-k}|t-t_\star|$. $\square$

**Theorem 7.4 (Step-length trichotomy).** Along a fan ray the hyperbolic step lengths tend to $0$ (Theorem 3.8). Along the **Pell spine** $\mu_k = B_2^k(2,1) = (2,1),(5,2),(12,5),(29,12),\ldots$ the seed cross products are $\pm1$ and the ratios $r_k = m_{k+1}/m_k$ satisfy $r_{k+1} = 2 + 1/r_k \to 1+\sqrt2$; therefore by Theorem 2.4
$$\cosh d(\mu_k,\mu_{k+1}) = \tfrac12\big(r_k + r_k^{-1}\big) + \frac{1}{2m_km_{k+1}} \longrightarrow \cosh\log(1+\sqrt2),$$
so the spine steps converge to $\log(1+\sqrt2) = 0.881373\ldots$, the translation length of the corresponding hyperbolic isometry. $\square$

The visual dichotomy — fans that glide tangentially into the boundary versus one ray marching away at constant speed — is exactly the dichotomy between parabolic and hyperbolic isometries. And it is consistent with Theorem 7.1: the spine's limit $\sqrt2-1$ is irrational, so no fan can form there.

---

## 8. Collisions, factorisation, and a no-free-lunch theorem

The Euclid embedding is attractive for a cryptographic reason: a number with two essentially different representations as a sum of two squares can be factored.

**Theorem 8.1 (Euler's two-representation method).** If $N$ is odd and $N = a^2+b^2 = c^2+d^2$ with both representations primitive and $\{a,b\} \ne \{c,d\}$, then
$$\gcd(N,\ ac+bd)\cdot\gcd(N,\ ad+bc) \;=\; N,$$
both factors being strictly between $1$ and $N$.

*Proof sketch.* $(ac+bd)(ad+bc) = (a^2+b^2)cd + (c^2+d^2)ab = N(ab+cd)$, so $N$ divides the product. Setting $g = \gcd(N,ac+bd)$, $h = \gcd(N,ad+bc)$, any common prime of $g,h$ would divide $(a+b)(c+d)$ and $(a-b)(c-d)$, contradicting primitivity and oddness; so $\gcd(g,h)=1$, $gh \mid N$ and $N \mid gh$. $\square$

**Definition 8.2.** A **collision** is a pair of distinct Euclid seeds with the same hypotenuse $N = m_1^2+n_1^2 = m_2^2+n_2^2$. Its **pivot** is $P = m_1m_2 + n_1n_2$ and its **divisor** $g = \gcd(N,P)$.

**Example 8.3.** $65 = 8^2+1^2 = 7^2+4^2$; $P = 60$, $g = \gcd(65,60) = 5$, complementary factor $\gcd(65, 39) = 13$.

**Theorem 8.4 (Collisions at every scale).** For every $j \ge 0$ the pairs $(20j+9,\ 10j+2)$ and $(20j+7,\ 10j+6)$ are Euclid seeds with common hypotenuse $N = 500j^2+400j+85$, and the extracted divisor is $5$. $\square$

**Theorem 8.5 (Colliding nodes are radially close).** Two seeds with the same hypotenuse $N$ have radii differing by at most $2\log 2$; the whole fibre over $N$ lies in an annulus of width $2\log2$ about the sphere of radius $\tfrac12\log N$ (Theorem 2.2). $\square$

**Theorem 8.6 (Exact collision distance).** For a collision,
$$\cosh d(z_1,z_2) \;=\; 1 + \frac{(N^2-P^2) + (m_1-m_2)^2}{2m_1m_2}.$$

*Proof.* By Theorem 2.4 the numerator involves the cross product squared, and the Brahmagupta–Fibonacci identity gives $N^2 = (m_1^2+n_1^2)(m_2^2+n_2^2) = P^2 + (n_1m_2 - n_2m_1)^2$. $\square$

**Theorem 8.7 (Two-sided law).** With the **pivot deficit** $D = N-P$,
$$\tfrac D2 \;\le\; \cosh d(z_1,z_2) - 1 \;\le\; 2D+2 .$$

*Proof sketch.* $N^2-P^2 = D(N+P)$, and $N/2 \le m_1m_2 \le N$ (each $m_i^2 > N/2$, and Cauchy–Schwarz), together with $0 \le (m_1-m_2)^2 \le N$ and $N \le N+P \le 2N$. $\square$

**Theorem 8.8 (The divisor pushes the witnesses apart).** $\cosh d(z_1,z_2) \ge 1 + g/2$, hence
$$d(z_1,z_2) \;\ge\; \log g - \log 2 .$$
If moreover $N \le g^2$ (a balanced factorisation), then $d(z_1,z_2) \ge \tfrac12\log N - \log 2$.

*Proof.* $g \mid N$ and $g \mid P$ with $P<N$, so $g \mid D$ and $D \ge g$; apply Theorem 8.7 and $\cosh x \le e^x$. $\square$

**Theorem 8.9 (Ball condition and volume growth).** A node lies in the ball of radius $R$ about $i$ iff
$$(m - \cosh R)^2 + n^2 \;\le\; \sinh^2 R,$$
i.e. iff the seed lies in the Euclidean disc of radius $\sinh R$ centred at $(\cosh R, 0)$. The number of nodes in that ball is $\Theta(e^{2R})$.

*Proof sketch.* The condition is Theorem 2.1 plus completing the square. Upper bound: $d\le R$ forces $c \le e^{2R}$, hence $m,n\le e^R$. Lower bound: sieve the box $\{m$ even, $2K<m\le4K\}\times\{n$ odd, $1\le n\le 2K\}$, whose $K^2$ pairs already have the right parity and ordering; removing those with a common odd divisor $d\ge3$ leaves at least $K^2/4$ seeds for large $K$, all within radius $\log K + 2$. $\square$

**Theorem 8.10 (No geodesic shortcut to factoring).** Let $N$ be odd with two primitive representations as a sum of two squares. The smallest ball about $i$ guaranteed to contain both corresponding nodes has radius $R \approx \tfrac12\log N + \log 2$, and hence contains $\Theta(e^{2R}) = \Theta(N)$ nodes.

*Proof.* Theorem 8.5 gives the radius; Theorem 8.9 gives the count. $\square$

The geodesic to a collision is *short* — length $\tfrac12\log N + O(1)$ — but the number of candidate endpoints at that radius is *linear* in $N$. The hyperbolic metric compresses the search space and the search target by the same exponential factor, and Theorem 8.8 closes the remaining loophole: even given one witness, the other is far away precisely when the collision is informative. Trial enumeration in $O(\sqrt N)$ remains optimal among these strategies.

For completeness: for a discrete path $z_0,\ldots,z_k$ with energy $E = \sum_j d(z_j,z_{j+1})^2$, Cauchy–Schwarz gives $E \ge d(z_0,z_k)^2/k$, so any $k$-step path from $i$ to a node of hypotenuse $c$ has energy at least $(\tfrac12\log c)^2/k$: minimising energy rewards *long* paths, the opposite of what a search wants.

---

## 9. Algorithms

**Algorithm A (Star census at a rational).** *Input:* coprime $p<q$, a charge bound $K$, a node bound $B$. *Output:* the rays of the star at $p/q$ with their nodes and widths.
1. Compute Bézout data $x,y$ with $qx-py = 1$ (extended Euclid, $O(\log q)$).
2. Set $\operatorname{gap} = 2$ if $p,q$ both odd, else $1$; the admissible charges are $k \equiv 1 \pmod{\operatorname{gap}}$, $|k|\le K$.
3. For each admissible $k$, iterate $A$ over $\mathbb{Z}$, form $(m,n) = (qA+yk,\ pA+xk)$, and keep those with $0<n<m\le B$ and $\gcd(A,k)=1$ and $m+n$ odd. By Theorem 6.3 the coprimality test is on $(A,k)$ alone.
4. Report the width $\operatorname{arsinh}(|k|/q)$ and, per period $2k$, the count predicted by Theorem 6.9.

Cost $O(K\cdot B/q)$ arithmetic operations, with a single $\gcd$ per candidate.

**Algorithm B (Node geometry).** *Input:* a seed $(m,n)$. *Output:* $c = m^2+n^2$; the radius $d = \operatorname{arcosh}((c+1)/(2m))$; for each rational $p/q$ of interest the charge $k = qn-pm$, the line parameter $k/q$, the width $\operatorname{arsinh}(|k|/q)$; the resolution $\delta(p/q)$. Constant time per rational.

**Algorithm C (Ray walk).** *Input:* a seed $(m,n)$ and a rational $p/q$ with charge $k$. *Output:* the nodes further out along the same ray, $(m+2tq,\ n+2tp)$, together with the exact step lengths from Theorem 3.7. When $|k|=1$ every $t$ yields a node (Theorem 3.6); otherwise sieve by $\gcd(A,k)=1$.

**Algorithm D (Visible-star ranking).** *Input:* a resolution threshold $\varepsilon$. *Output:* the sorted list of visible fans. Enumerate $q \le 2/\varepsilon$ and coprime $p\le q$, compute $\delta(p/q)$, keep those with $\delta \ge \varepsilon$, sort descending. Finiteness is Theorem 5.5; for $\varepsilon = 2/5$ the output is Theorem 5.4.

**Algorithm E (Ball enumeration).** *Input:* $R$. *Output:* the nodes within hyperbolic distance $R$ of $i$. By Theorem 8.9, loop over integer points of the Euclidean disc $(m-\cosh R)^2+n^2 \le \sinh^2 R$ intersected with the cone $0<n<m$, testing coprimality and parity. Cost $O(e^{2R}\log)$, versus $O(e^{4R})$ for a naive box scan.

**Algorithm F (Collision factoring).** *Input:* odd $N$. *Output:* a non-trivial factorisation, if $N$ has two primitive two-square representations. For $\sqrt{N/2} < m \le \sqrt N$, test whether $N-m^2$ is a perfect square and whether $(m,n)$ is a seed. Given two hits, return $\gcd(N, m_1m_2+n_1n_2)$ and $\gcd(N, m_1n_2+n_1m_2)$. Cost $O(\sqrt N)$; Theorem 8.10 says no hyperbolic search improves on this.

---

## 10. Discussion

The results assemble into one statement: **the star map of the Berggren tree is completely explicit, and every feature of it is a theorem.**

*Where the stars are.* At the rationals, and only there (Theorem 7.1). Rationality is exactly the condition for two nodes to be collinear with an ideal point.

*Which rays exist.* At $p/q$ the realised charges are all integers if $p+q$ is odd, and only the odd integers if $p,q$ are both odd (Theorem 4.5) — the whole spectrum, with the central geodesic populated iff $p+q$ is odd, and then by the single node $(q,p)$.

*How sharp a fan is.* Resolution $\delta(p/q) = \operatorname{gap}(p,q)/q$, attained (Theorems 5.2, 5.3), giving the exact visible list $\{0,\tfrac15,\tfrac13,\tfrac12,\tfrac35,1\}$ at threshold $2/5$ and a finite hierarchy at every threshold (Theorems 5.4, 5.5). This is the one place where the theory made a *prediction*: the fan at $0.6$ is present in the mathematics before it is noticed in the picture, and $1/4$ is absent from the picture despite its small denominator.

*How bright a ray is.* $\varphi(k)$ or $2\varphi(k)$ nodes per window of $2k$ ray parameters (Theorem 6.9), because in ray coordinates both defining conditions of a Euclid seed collapse to $\gcd(A,k)=1$ plus at most one parity class. Unit rays are completely full.

*Why the rays look like lines.* Because the steps along them tend to $0$ (Theorem 3.8) and they converge to their tips (Theorem 3.9) — the signature of parabolic dynamics — whereas the one exceptional ray, the Pell spine, has steps converging to the positive constant $\log(1+\sqrt2)$ (Theorem 7.4), the signature of hyperbolic dynamics.

*What it is not good for.* Factoring (Theorems 8.8, 8.10).

Two structural remarks. First, almost every quantity here is *exactly* computable, because the embedding is arithmetically transparent: $\operatorname{Im}z = 1/m$ and $\operatorname{Re}z = n/m$ are the seed coordinates in disguise, so hyperbolic invariants become rational functions of $m$ and $n$, and the single transcendental $\operatorname{arcosh}$ is removed by monotonicity. Second, the parity law is the one genuinely arithmetic input, and it is responsible for the only *asymmetry* in the picture: the compensation of Remark 6.11 means that the eye is really seeing a trade-off between angular spacing and per-ray density, decided entirely by $p+q \bmod 2$.

---

## 11. Future directions

**Vanishing width at irrationals.** For every irrational $\alpha \in (0,1)$ we conjecture
$$\inf\big\{\,d_{\mathbb{H}}\big(z(m,n),\ \gamma_\alpha\big) \ :\ (m,n)\ \text{a Euclid seed}\,\big\} \;=\; 0,$$
even though no positive-width hypercycle over $\alpha$ contains more than one node (Theorem 7.1). The mechanism should be continued fractions: a seed close to $\gamma_\alpha$ is a convergent $p_j/q_j$ of $\alpha$ of the right parity, since $|q_j\alpha - p_j| < 1/q_{j+1}$ makes the charge-like quantity $q_jn - p_jm$ small; and among any two consecutive convergents at least one has $p_j + q_j$ odd, because $p_{j+1}q_j - p_jq_{j+1} = \pm1$ forbids both from being even-even and forces the parity vector to cycle through $(0,1),(1,0),(1,1)$. The Bézout realisation of Theorem 4.3 supplies genuine seeds on any admissible ray, so the missing ingredient is exactly the convergent-parity lemma. Falsifiable by an irrational with a deliberately chosen parity pattern together with a certified positive lower bound.

**Exact volume asymptotics.** Conjecturally
$$\#\{\text{nodes within distance } R \text{ of } i\} \;=\; \frac{\pi+2}{4\pi^2}\,e^{2R} + O(e^{3R/2}), \qquad \frac{\pi+2}{4\pi^2} = 0.13023806\ldots$$
By Theorem 8.9 this is a Gauss circle problem in the seed cone with a coprimality-and-parity sieve: density $6/\pi^2 \cdot 2/3 = 4/\pi^2$, area factor $\pi/4 + 1/2$, and $\cosh^2 R \sim e^{2R}/4$. Direct enumeration gives ratios $0.12890, 0.13016, 0.13012, 0.13020, 0.13024, 0.13024$ at $R = 3,\ldots,8$. Any enumeration whose ratio stabilises away from $0.130238$ refutes it.

**Cesàro step statistics.** For an infinite word $w \in \{1,2,3\}^{\mathbb{N}}$ let $d_k$ be the step length between the $k$-th and $(k{+}1)$-st node of the corresponding path from the root. Conjecture: the Cesàro mean $\tfrac1K\sum_{k<K}d_k$ converges for every word, with set of limit values exactly $[0, \log(1+\sqrt2)]$, the endpoints attained only by $1^\infty/3^\infty$ and by $2^\infty$. The two endpoints are Theorem 7.4; the lever is the closed form of Theorem 2.4, in which the cross term is $\pm1$ along the spine and $u^2$ along a fan arm.

**Equidistribution.** Do the nodes with hypotenuse in $[N,2N]$ equidistribute on the corresponding annulus with respect to hyperbolic area? The slope model suggests the angular distribution is governed by the distribution of $n/m$ among seeds.

**Modular interpretation.** The three moves generate a subgroup of $\mathrm{PGL}_2(\mathbb{Z})$ acting on slopes by $t\mapsto 1/(2-t),\ 1/(2+t),\ t/(1+2t)$. Identifying the precise congruence subgroup and matching the seed trichotomy against a fundamental domain would place the star map inside modular-curve geometry, and might yield equidistribution for free. The quantisation asymmetry between $p+q$ odd and $p,q$ both odd should appear as a cusp width.

**Sharpened collision radius.** Theorem 8.5 bounds the difference of the two radii of a collision by $2\log 2$; the distance between the colliding nodes should be at most $\log N - \log(4m_1m_2) + O(1)$, since both lie on the level set $2m\cosh d = N+1$, an arc of controlled hyperbolic diameter. Theorem 8.7 gives the matching lower bound in terms of the pivot deficit; closing the gap would determine the collision geometry completely.

**A weighted depth law.** Depth in the tree is *not* proportional, up to bounded error, to the sum of the partial quotients of the slope: the right spine $B_3^k(2,1) = (2k+2,1)$ has depth $k$ and partial-quotient sum $2k+2$, while the left spine $(k+2,k+1)$ has depth $k$ and sum $k+2$; combining the two would force $k$ bounded. The structural reason is that $B_3$ adds $2$ to $m/n$, costing half a partial quotient per step, whereas $B_1$ accumulates at a parabolic fixed point and costs a whole one. A correctly weighted law may hold; formulating and proving it is open.

---

## Appendix A: numerical illustrations

**A.1 Charges and widths.** For the seed $(12,5)$ (triple $119,120,169$):

| $p/q$ | charge $k = qn-pm$ | line parameter $k/q$ | width $\operatorname{arsinh}(|k|/q)$ |
|---|---|---|---|
| $0/1$ | $5$ | $5$ | $2.31244$ |
| $1/1$ | $-7$ | $-7$ | $2.64412$ |
| $1/2$ | $-2$ | $-1$ | $0.88137$ |
| $1/3$ | $3$ | $1$ | $0.88137$ |
| $1/5$ | $13$ | $2.6$ | $1.68374$ |
| $3/5$ | $-11$ | $-2.2$ | $1.52966$ |

**A.2 The visible hierarchy.** The rationals of $[0,1]$ ranked by $\delta(p/q) = \operatorname{gap}(p,q)/q$:

| $p/q$ | $p+q$ | gap | $\delta$ | visible at $2/5$? |
|---|---|---|---|---|
| $0/1$ | odd | $1$ | $1$ | yes |
| $1/1$ | even | $2$ | $2$ | yes |
| $1/2$ | odd | $1$ | $0.5$ | yes |
| $1/3$ | even | $2$ | $0.667$ | yes |
| $2/3$ | odd | $1$ | $0.333$ | no |
| $1/4$, $3/4$ | odd | $1$ | $0.25$ | **no** |
| $1/5$, $3/5$ | even | $2$ | $0.4$ | yes |
| $2/5$, $4/5$ | odd | $1$ | $0.2$ | no |

The visible list is exactly $0/1,\ 1/5,\ 1/3,\ 1/2,\ 3/5,\ 1/1$. The two instructive entries are $1/4$, excluded despite $4 < 5$ because its even denominator forfeits the parity bonus, and $2/3$, excluded despite the small denominator $3$ for the same reason — while $1/3$, with both entries odd, is comfortably visible.

**A.3 Brightness.** Counts of Euclid seeds among $2k$ consecutive ray parameters:

| star | charge $k$ | regime | predicted count | $\varphi(k)$ |
|---|---|---|---|---|
| $1/3$ | $1$ | both odd | $2$ | $1$ |
| $1/3$ | $3$ | both odd | $4$ | $2$ |
| $1/3$ | $15$ | both odd | $16$ | $8$ |
| $1/2$ | $2$ | $p+q$ odd, $k$ even | $2$ | $1$ |
| $1/2$ | $3$ | mixed | $2$ | $2$ |
| $1/2$ | $15$ | mixed | $8$ | $8$ |

**A.4 The Pell spine.** Seeds $(2,1),(5,2),(12,5),(29,12),(70,29),(169,70)$; radii $0.9624, 1.4910, 2.6459, 3.5255, 4.4079, 5.2894$; step lengths $0.9624, 0.8838, 0.8838, 0.8814, 0.8814, \ldots \to \log(1+\sqrt2) = 0.881373$.
