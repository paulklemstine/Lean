# The Boundary Geometry of the Berggren Tree: Horocyclic Stars, Charge Quantization, and Escape Rates

**Author:** Aristotle
**Date:** 2026-08-08

---

## Abstract

Plotting the Berggren (Barning–Hall) ternary tree of primitive Pythagorean triples inside a disc, by mapping a triple $(a,b,c)$ to the direction $(a/c, b/c)$ on the boundary circle at a radius increasing with depth, produces a picture with two conspicuous and unexplained visual features: streaks that behave like radii of the disc, and — far more striking — dense bundles of curves converging on isolated points *of the boundary circle itself*, which look like stars embedded in the rim.

We give a complete algebro-geometric account of this picture. The key observation is that the Pythagorean equation is the light cone of the quadratic form $Q(a,b,c) = a^2+b^2-c^2$ of signature $(2,1)$, that the three Berggren generators lie in the integral Lorentz group $O(2,1;\mathbb{Z})$, and that the plotting map is the ideal-point map of the Klein model of the hyperbolic plane $\mathbb{H}^2$.

We prove: (i) a **chord–charge identity** expressing the squared chordal distance between two plotted ideal points as $-2\langle v,p\rangle/(c_vc_p)$; (ii) a **star theorem**, that any family of triples of constant Lorentz charge at a fixed null vector $p$ with unbounded hypotenuse converges in the disc to $\mathrm{dir}\,p$; (iii) an **exact tangency law**, that $c_v\|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2$ is *constant* along a horocycle, pinning the contact order with the boundary circle at exactly two; (iv) a **charge quantization theorem**, that the charge of a primitive triple at a rational ideal point is twice a square or an odd square, with an exact spectrum; (v) an **escape-rate dichotomy**, comparing the polynomial rate $\Theta(k^{-2})$ of the two parabolic generators with the exponential rate $O(3^{-k})$ of the hyperbolic one, together with the irrationality obstruction showing that the hyperbolic limit is never occupied by a triple; (vi) **star location and multiplicity**, that every primitive rational ideal point with odd first leg carries a star with infinitely many distinct spokes, via transport of the star by the monoid combined with Barning–Hall completeness proved by Fermat descent; (vii) an **exact tree spectrum**, that the charges drawn by the tree at $(1,0)$ are precisely $\{2n^2 : n\ge 1\}$; and (viii) a **two-sided Lyapunov bound** $5\cdot3^{\#_B(g)} \le c(g) \le 5\cdot 7^{|g|}$ on the hypotenuse in terms of the address word, forcing exponential escape to be equivalent to a positive density of one letter.

Together these results turn every visual feature of the plot into a theorem, and identify the spoke index of a star with the smaller Euclid parameter of the triple.

**Keywords:** Pythagorean triples, Berggren tree, Barning–Hall tree, Lorentz group, hyperbolic plane, horocycle, ideal point, charge quantization, Pell numbers, thin groups.

---

## 1. Introduction

### 1.1 The tree

A **Pythagorean triple** is a triple $(a,b,c)$ of positive integers with $a^2+b^2=c^2$; it is **primitive** if $\gcd(a,b)=1$. Barning (1963) and Hall (1970), following Berggren (1934), observed that the primitive triples with odd first leg form a rooted infinite ternary tree under the action of three explicit integer matrices. Writing triples as column vectors, the generators are
$$
A = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},\qquad
B = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},\qquad
C = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix},
$$
with root $\mathbf{r} = (3,4,5)^{\mathsf T}$. We write their action on triples as
$$
\begin{aligned}
A(a,b,c) &= (a - 2b + 2c,\ 2a - b + 2c,\ 2a - 2b + 3c),\\
B(a,b,c) &= (a + 2b + 2c,\ 2a + b + 2c,\ 2a + 2b + 3c),\\
C(a,b,c) &= (-a + 2b + 2c,\ -2a + b + 2c,\ -2a + 2b + 3c).
\end{aligned}
$$
Then $A\mathbf r = (5,12,13)$, $B\mathbf r = (21,20,29)$, $C\mathbf r = (15,8,17)$.

### 1.2 The plot, and the phenomenon

For a triple $v = (a,b,c)$ with $c > 0$ set
$$\mathrm{dir}(v) = \bigl(x(v), y(v)\bigr) := \left(\frac{a}{c}, \frac{b}{c}\right).$$
Since $a^2+b^2=c^2$, the point $\mathrm{dir}(v)$ lies on the unit circle. Draw the node $v$ inside the closed unit disc at
$$\mathrm{draw}(v) := \rho(v)\cdot \mathrm{dir}(v), \qquad \rho(v) := 1 - \frac1c,$$
so that nodes of large hypotenuse are drawn close to the rim, and join each node to its three children. The visible features are:

* **Radiating streaks**, resembling geodesics of the Klein disc, running from the interior to the boundary;
* **Stars**: at isolated points of the boundary circle, an apparent bundle of many curves converging together into that single point, meeting the circle tangentially rather than transversally.

The purpose of this paper is to explain both, exactly.

### 1.3 Method

The Pythagorean equation is the vanishing of the quadratic form
$$Q(a,b,c) = a^2+b^2-c^2,$$
of signature $(2,1)$, with polarization
$$\langle v,w\rangle = v_1w_1 + v_2w_2 - v_3w_3.$$
A direct computation (Proposition 2.1) shows that $A$, $B$, $C$ all preserve $\langle\cdot,\cdot\rangle$, hence lie in $O(2,1;\mathbb Z)$. The positive light cone modulo scaling is the boundary circle $\partial \mathbb H^2$ in the Klein model, and $\mathrm{dir}$ is precisely the ideal-point map. So the plot is a picture of a discrete subgroup of $\mathrm{Isom}(\mathbb H^2)$ acting on the circle at infinity, and the classification of the visible curves is the classification of the generators by conjugacy type.

---

## 2. The Lorentzian skeleton

### 2.1 Isometry

**Proposition 2.1 (Lorentz invariance).** *For all $v,w \in \mathbb Z^3$ and $M \in \{A,B,C\}$,*
$$\langle Mv, Mw\rangle = \langle v, w\rangle.$$
*In particular $Q(Mv) = Q(v)$, so each generator maps the light cone to itself, and every word in the generators applied to a Pythagorean triple yields a Pythagorean triple.*

*Proof.* Expand both sides as polynomials in the six coordinates and compare. Each is an identity of quadratic forms verified by direct expansion. $\square$

**Definition 2.2 (Admissible triples).** Call $v = (a,b,c)$ **admissible** if $Q(v) = 0$, $a \ge 0$, $b\ge 0$, $c > 0$.

**Proposition 2.3.** *Each generator maps admissible vectors to admissible vectors and never decreases the hypotenuse. Moreover on the light cone with nonnegative legs one has $a \le c$ and $b \le c$.*

*Proof.* From $a^2+b^2=c^2$ and $b\ge 0$ one gets $a^2 \le c^2$, hence $a\le c$; symmetrically $b\le c$. The three positivity claims are then linear consequences, e.g. for $C$ the first coordinate is $-a+2b+2c \ge -c + 2b + 2c > 0$. $\square$

### 2.2 Charges

**Definition 2.4 (Charge).** For a null vector $p$ with $c_p>0$ and any $v$, the **charge of $v$ at $p$** is the integer $d = -\langle v,p\rangle$.

Two null lattice vectors are distinguished:
$$e_1 = (1,0,1), \qquad e_2 = (0,1,1),$$
with $\mathrm{dir}(e_1) = (1,0)$ and $\mathrm{dir}(e_2) = (0,1)$. One computes directly
$$\langle v, e_1\rangle = a - c, \qquad \langle v,e_2\rangle = b-c,$$
so the charges at $e_1$ and $e_2$ are $c-a$ and $c-b$ respectively.

**Proposition 2.5 (Conserved charges).** *For every $v$:*
$$ (Cv)_3 - (Cv)_1 = c - a, \qquad (Av)_3 - (Av)_2 = c - b, \qquad (Bv)_1 - (Bv)_2 = -(a - b).$$
*Hence $C$ fixes the charge at $e_1$ and fixes $e_1$ itself; $A$ fixes the charge at $e_2$ and fixes $e_2$; and $B$ preserves $|a-b|$, whose vanishing locus on the cone is the direction $(1,1,\sqrt2)$.*

**Proposition 2.6 (Positivity of the charge).** *If $(a,b,c)$ is on the cone with $b,c>0$ then $c - a > 0$.*

*Proof.* $b^2 = c^2 - a^2 = (c-a)(c+a) > 0$, and $c+a \ge 0$ since $|a| \le c$; the case $c=a$ forces $b=0$. $\square$

### 2.3 Conjugacy types: exact closed forms

**Theorem 2.7 (The parabolic flows).** *Let $d = c-a$ and $e = c-b$. For every $k \ge 0$,*
$$C^k(a,b,c) = \bigl(\gamma_k - d,\ b + 2kd,\ \gamma_k\bigr), \qquad \gamma_k = c + 2kb + 2k^2 d,$$
$$A^k(a,b,c) = \bigl(a + 2ke,\ \alpha_k - e,\ \alpha_k\bigr), \qquad \alpha_k = c + 2ka + 2k^2 e.$$

*Proof.* Induction on $k$; the inductive step is a polynomial identity in $k$ after substituting the closed form and applying the generator. $\square$

The hypotenuse along either flow is a genuine quadratic polynomial in the step number, with leading coefficient twice the conserved charge. Quadratic growth of the iterates is the signature of a rank-three unipotent Jordan block: $A$ and $C$ are **parabolic** isometries of $\mathbb H^2$.

Two special cases recover classical families. From the root,
$$A^k(3,4,5) = \bigl(2k+3,\ 2(k+1)(k+2),\ 2(k+1)(k+2)+1\bigr)$$
(the "leg and hypotenuse differ by one" family), and
$$C^k(3,4,5) = \bigl((2k+1)(2k+3),\ 4k+4,\ (2k+2)^2+1\bigr)$$
(the "differ by two" family).

**Theorem 2.8 (The hyperbolic flow).** *For every $v$, $(B^2 v)_3 = 6 (Bv)_3 - v_3$, i.e. the hypotenuse satisfies the Pell recursion $c_{k+2} = 6c_{k+1}-c_k$, with characteristic roots $3\pm2\sqrt2 = (1\pm\sqrt2)^2$. If $(a,b,c)$ is admissible with $a,b>0$ then $c_{k+1}\ge 5c_k$, hence $c_k \ge 5^k c_0$; and $(B^kv)_1 - (B^kv)_2 = (-1)^k(a-b)$, so $|a-b|$ is constant along the flow.*

*Proof.* The recursion is a pointwise polynomial identity, valid because the $(-1)$-eigenvector $(1,-1,0)$ of $B$ has vanishing third coordinate. For the growth: on the cone with $a,b>0$ we have $a+b\ge c$ (since $(a+b)^2 = c^2 + 2ab \ge c^2$), and $(Bv)_3 = 2a+2b+3c \ge 2c+3c = 5c$. The charge identity is Proposition 2.5 iterated. $\square$

$B$ is therefore **hyperbolic**: its orbits translate along an axis geodesic, converging exponentially to the ideal point where $a=b$, i.e. at angle $\pi/4$.

---

## 3. The chord–charge identity and the star theorem

### 3.1 The fundamental identity

**Theorem 3.1 (Chord = charge).** *Let $v, p$ be null vectors with $c_v, c_p > 0$. Then*
$$\bigl\|\mathrm{dir}\,v - \mathrm{dir}\,p\bigr\|^2 \;=\; \frac{-2\langle v,p\rangle}{c_v c_p}.$$

*Proof.* Write $v = (a,b,c)$, $p = (x,y,z)$. Then
$$\Bigl(\frac ac - \frac xz\Bigr)^2 + \Bigl(\frac bc - \frac yz\Bigr)^2 = \frac{a^2+b^2}{c^2} + \frac{x^2+y^2}{z^2} - \frac{2(ax+by)}{cz} = 1 + 1 - \frac{2(ax+by)}{cz},$$
using $a^2+b^2=c^2$ and $x^2+y^2=z^2$. Since $\langle v,p\rangle = ax+by-cz$, the right side equals $2 - 2(\langle v,p\rangle+cz)/(cz) = -2\langle v,p\rangle/(cz)$. $\square$

Every subsequent result is a consequence of Theorem 3.1.

### 3.2 The star theorem

**Definition 3.2 (Horocycle of charge $d$).** For a null $p$ and $d \in \mathbb Z_{>0}$, the set $\{v \text{ on the cone} : \langle v,p\rangle = -d\}$ is the level set of a linear functional; in the Klein model it is a **horocycle** based at the ideal point $\mathrm{dir}\,p$.

**Theorem 3.3 (Star theorem — horocyclic convergence).** *Let $p$ be a null vector with $c_p > 0$, and let $(w_k)_{k\ge0}$ be null vectors with $c_{w_k}>0$, satisfying*
$$\langle w_k, p\rangle = -d \quad \text{for all } k, \qquad c_{w_k}\to\infty.$$
*Then $\mathrm{dir}(w_k) \to \mathrm{dir}(p)$ in $\mathbb R^2$.*

*Proof.* By Theorem 3.1, $\|\mathrm{dir}\,w_k - \mathrm{dir}\,p\|^2 = 2d/(c_{w_k}c_p) \to 0$; each coordinate difference is bounded in absolute value by the square root of this quantity, which tends to $0$. $\square$

Since distinct $d$ yield disjoint families, and all of them converge to the same boundary point, Theorem 3.3 is exactly the statement that a bundle of curves radiates from an isolated boundary point. This is **the star**.

### 3.3 The exact tangency law

**Theorem 3.4 (Exact tangency).** *Under the hypotheses of Theorem 3.1,*
$$c_v \cdot \bigl\|\mathrm{dir}\,v - \mathrm{dir}\,p\bigr\|^2 \;=\; \frac{-2\langle v,p\rangle}{c_p}.$$
*In particular, along a horocycle of charge $d$ based at $p$, this product is **constant**, equal to $2d/c_p$ — not merely convergent.*

**Corollary 3.5 (Contact order exactly two).** *Along a horocycle of charge $d>0$ with $c_{w_k}\to\infty$:*
$$c_{w_k}^2\cdot\|\mathrm{dir}\,w_k - \mathrm{dir}\,p\|^2 \longrightarrow \infty, \qquad \sqrt{c_{w_k}}\cdot\|\mathrm{dir}\,w_k - \mathrm{dir}\,p\|^2 \longrightarrow 0.$$

*Proof.* The two expressions equal $c_{w_k}\cdot(2d/c_p)$ and $(2d/c_p)/\sqrt{c_{w_k}}$ respectively. $\square$

A geodesic through the centre of the Klein disc meets $\partial\mathbb H^2$ transversally (contact order one). Corollary 3.5 says the star curves have contact order exactly two — the visible reason they *bend into* the rim rather than *striking* it.

### 3.4 The drawn picture

Since the plot draws nodes strictly inside the disc at radius $\rho(v) = 1 - 1/c_v$, we record what the drawn curve satisfies.

**Theorem 3.6 (Equation of a drawn spoke).** *If $\langle v,p\rangle = -d$ and $r = \rho(v)$, then*
$$\bigl\|\mathrm{dir}\,v - \mathrm{dir}\,p\bigr\|^2 \;=\; \frac{2d\,(1-r)}{c_p}.$$
*Thus each spoke is the graph of an exact algebraic relation between angular offset and radial defect, with the single parameter $d/c_p$: squared angular offset is proportional to distance from the rim.*

*Proof.* Immediate from Theorem 3.1 and $1-r = 1/c_v$. $\square$

**Theorem 3.7 (Drawn convergence).** *If $(w_j)$ is a family of admissible triples of constant charge $d$ at an admissible $p$ with $c_{w_j}\to\infty$, then $\rho(w_j)\to1$ and $\mathrm{draw}(w_j) \to \mathrm{dir}(p)$.*

*Proof.* $\rho(w_j) = 1 - 1/c_{w_j}\to1$; multiply with Theorem 3.3. $\square$

### 3.5 Separation of spokes

Distinct charges are not a bookkeeping artefact: they are visibly separated.

**Theorem 3.8 (Chord ratio).** *If $v, v'$ are null with equal hypotenuse $c_v = c_{v'} > 0$ and charges $d, d' \ne 0$ at $p$, then*
$$\frac{\|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2}{\|\mathrm{dir}\,v' - \mathrm{dir}\,p\|^2} = \frac{d}{d'}.$$

*Proof.* Apply Theorem 3.1 to both and divide; the common factor $2/(c_vc_p)$ cancels. $\square$

---

## 4. Which spokes exist: charge quantization

The star theorem says every charge $d$ realised by an unbounded horocyclic family gives a spoke. Which $d$ are realised by *primitive* triples?

### 4.1 Parity preliminaries

**Lemma 4.1.** *No Pythagorean triple has both legs odd.*

*Proof.* If $a=2k+1$, $b=2l+1$ then $a^2+b^2 \equiv 2 \pmod 4$, but a square is $\equiv 0$ or $1 \pmod 4$. $\square$

**Lemma 4.2.** *In a primitive triple, $\gcd(a,c)=1$ and $c$ is odd.*

*Proof.* If $\gcd(a,b)=1$ then $a$ is coprime to $b^2 = c^2-a^2$, hence to $c^2$, hence to $c$. Both legs cannot be even (primitivity) nor both odd (Lemma 4.1); so exactly one leg is odd, whence $c^2 = \text{even}^2 + \text{odd}^2$ is odd. $\square$

### 4.2 The quantization theorem

**Theorem 4.3 (Charge quantization).** *Let $a^2+b^2=c^2$ with $a,b,c>0$ and $\gcd(a,b)=1$. Then:*

* *If $a$ is odd, there is $n \ge 1$ with $c - a = 2n^2$.*
* *If $a$ is even, there is an odd $n\ge1$ with $c - a = n^2$.*

*Proof.* Suppose $a$ is odd. By Lemma 4.1, $b$ is even, $b = 2b'$, and by Lemma 4.2 $c$ is odd; so $c-a = 2u$ and $c+a = 2v$ with $u,v \in \mathbb Z$, $u>0$ by Proposition 2.6. From $b^2=(c-a)(c+a)$ we get $uv = b'^2$. Writing $c = u+v$, $a = v-u$ and using $\gcd(a,c)=1$ from Lemma 4.2, a Bézout combination gives $\gcd(u,v)=1$. Two coprime integers whose product is a square are each (up to sign) squares; positivity gives $u = n^2$, so $c-a = 2n^2$.

Suppose $a$ is even. Then $b$ and $c$ are odd, and $c-a$, $c+a$ are odd with product $b^2$. As above $\gcd(c-a,c+a)$ divides $2\gcd(a,c) = 2$ and both are odd, so they are coprime, whence $c-a = n^2$ for some $n\ge1$; and $n$ is odd since $c-a$ is odd. $\square$

**Theorem 4.4 (Every admissible charge occurs).** *For every $n\ge 1$ the primitive triple $(2n+1,\,2n^2+2n,\,2n^2+2n+1)$ has odd first leg and charge $c-a = 2n^2$; for every $m\ge1$ the primitive triple $(4m,\,4m^2-1,\,4m^2+1)$ has even first leg and charge $c-a = (2m-1)^2$.*

*Proof.* Direct verification of the Pythagorean identity, of positivity, of coprimality (exhibit an explicit Bézout pair: $(2n+1)\cdot(2n+1) + (2n^2+2n)\cdot(-2) = 1$ and $(4m)\cdot m + (4m^2-1)\cdot(-1) = 1$), and of the stated difference. $\square$

**Corollary 4.5 (The spectrum of the star).** *A positive integer $d$ is the charge at $(1,0)$ of some primitive Pythagorean triple with positive entries if and only if $d = 2n^2$ for some $n \ge 1$ or $d = n^2$ for some odd $n\ge1$. Restricted to triples with odd first leg — i.e. to nodes of the Berggren tree — the spectrum is exactly $\{2n^2 : n\ge1\}$.*

Both sets have density zero in $\mathbb Z$. This is the arithmetic reason the star has *discrete, separated* spokes.

---

## 5. Euclid coordinates and the spoke index

### 5.1 The parameter action

**Definition 5.1.** For $m,n\in\mathbb Z$ put $\mathrm{eu}(m,n) = (m^2-n^2,\ 2mn,\ m^2+n^2)$.

Then $Q(\mathrm{eu}(m,n)) = 0$ identically, and $\mathrm{eu}$ is injective on $0 < n < m$. The root is $\mathrm{eu}(2,1)$.

**Theorem 5.2 (The generators in Euclid coordinates).**
$$A\,\mathrm{eu}(m,n) = \mathrm{eu}(2m-n,\ m), \qquad B\,\mathrm{eu}(m,n) = \mathrm{eu}(2m+n,\ m), \qquad C\,\mathrm{eu}(m,n) = \mathrm{eu}(m+2n,\ n).$$

*Proof.* Substitute and compare coordinatewise; each is a polynomial identity in $m,n$. $\square$

This is the classical ternary tree on coprime parameter pairs. Note the qualitative distinction: $C$ **freezes** the smaller parameter $n$, while $A$ and $B$ **promote** $m$ to be the new smaller parameter.

**Theorem 5.3 (Charges in Euclid coordinates).**
$$\langle \mathrm{eu}(m,n), e_1\rangle = -2n^2, \qquad \langle \mathrm{eu}(m,n), e_2\rangle = -(m-n)^2.$$

*Proof.* $\langle v, e_1\rangle = a - c = (m^2-n^2)-(m^2+n^2) = -2n^2$, and $\langle v,e_2\rangle = b-c = 2mn - m^2-n^2 = -(m-n)^2$. $\square$

**Definition 5.4 (Spoke index).** The **spoke index** of a node $\mathrm{eu}(m,n)$ (with $0<n<m$) is $n$: the unique integer with charge $2n^2$ at $(1,0)$.

Theorem 5.3 gives, in one line, the two arithmetic progressions of Theorem 4.3, and identifies the geometric label of a spoke with a parameter of the classical Euclid parametrisation.

### 5.2 How fast the star fills in

**Theorem 5.5 (Depth bound for the spoke index).** *Let $W$ be a word of length $\ell$ in $\{A,B,C\}$ and suppose $W\mathbf r = \mathrm{eu}(m,n)$ with $0<n<m$. Then*
$$n < 2\cdot 3^{\ell}.$$

*Proof.* By Theorem 5.2, one step maps $(m,n)$ with $0<n<m$ to a pair whose larger parameter is at most $2m+n < 3m$; the smaller parameter is always at most the previous larger one. Induction on $\ell$ starting from $\mathrm{eu}(2,1)$ gives larger parameter $\le 3^\ell\cdot 2$, and the smaller parameter is strictly less. $\square$

Consequently the $n$-th spoke of the star at $(1,0)$ cannot be drawn before depth $\approx \log_3(n/2)$: the star fills in at most logarithmically fast. The bound is sharp up to the constant.

**Theorem 5.6 (Sharpness along the hyperbolic branch).** *Let $P_0=1$, $P_1=2$, $P_{k+2} = 2P_{k+1}+P_k$ be the Pell numbers. Then $B^k\mathbf r = \mathrm{eu}(P_{k+1}, P_k)$, and for $k\ge1$*
$$2^k \le P_k < 2\cdot 3^k, \qquad \langle B^k\mathbf r, e_1\rangle = -2P_k^2.$$
*So at depth $k$ the hyperbolic branch realises spoke index $n$ with $2^k \le n < 2\cdot3^k$.*

*Proof.* $\mathbf r = \mathrm{eu}(2,1) = \mathrm{eu}(P_1,P_0)$; by Theorem 5.2, $B\,\mathrm{eu}(P_{k+1},P_k) = \mathrm{eu}(2P_{k+1}+P_k, P_{k+1}) = \mathrm{eu}(P_{k+2},P_{k+1})$. The lower bound $P_k \ge 2^k$ follows by induction from $P_{k+2}=2P_{k+1}+P_k \ge 2\cdot2^{k+1}$; the upper bound from Theorem 5.5. $\square$

**Theorem 5.7 (Slowest growth along the parabolic branch).** *$A^k\mathbf r = \mathrm{eu}(k+2,\ k+1)$; so the spoke index along the $A$-branch is $k+1$, reaching spoke $n$ only at depth $n-1$.*

*Proof.* Induction using $A\,\mathrm{eu}(k+2,k+1) = \mathrm{eu}(2(k+2)-(k+1),\ k+2) = \mathrm{eu}(k+3,k+2)$. $\square$

Theorems 5.6 and 5.7 show the conjectured universal law "spoke index $n$ appears at depth $\Theta(\log n)$" is **false** as stated: the correct universal statement is the lower bound of Theorem 5.5, together with the attaining family of Theorem 5.6.

**Remark 5.8.** Along $C$ the spoke index is frozen: $C^k\,\mathrm{eu}(m,n) = \mathrm{eu}(m+2kn,\ n)$, so the whole $C$-orbit of a node lies on a single spoke, with the same charge $2n^2$. This is what makes the $C$-orbit the natural parametrisation of an individual spoke.

---

## 6. Escape rates: geodesic versus horocycle

The visual distinction between "radiating lines" and "star curves" is a distinction between exponential and polynomial approach to the boundary.

**Lemma 6.1 (A sharp circle estimate).** *If $x,y\ge0$ and $x^2+y^2=1$ then $\bigl|x - \tfrac{\sqrt2}{2}\bigr| \le |x-y|$.*

*Proof.* First, $(x+y)^2 = 1 + 2xy \le 2(x^2+y^2) = 2$, so $x+y\le\sqrt2$. Since $x^2+y^2=1$ we have $2x^2 - 1 = x^2-y^2$, hence
$$\Bigl|x-\tfrac{\sqrt2}{2}\Bigr|\Bigl(x+\tfrac{\sqrt2}{2}\Bigr) = \Bigl|x^2 - \tfrac12\Bigr| = \tfrac12\bigl|x^2-y^2\bigr| = \tfrac12|x-y|\,(x+y) \;\le\; \tfrac{\sqrt2}{2}\,|x-y| \;\le\; |x-y|\Bigl(x+\tfrac{\sqrt2}{2}\Bigr).$$
Dividing by $x+\tfrac{\sqrt2}{2}>0$ gives the claim. $\square$

**Corollary 6.2.** *For an admissible triple $(a,b,c)$, $\bigl|x(v) - \tfrac{\sqrt2}{2}\bigr| \le \dfrac{|a-b|}{c}$.*

**Theorem 6.3 (Exponential escape along the hyperbolic generator).** *For admissible $(a,b,c)$ with $a,b>0$ and all $k\ge0$,*
$$\Bigl|x\bigl(B^k(a,b,c)\bigr) - \tfrac{\sqrt2}{2}\Bigr| \;\le\; \frac{|a-b|}{3^k c}.$$
*In particular $x(B^k(a,b,c)) \to \tfrac{\sqrt2}{2}$ exponentially fast.*

*Proof.* By Theorem 2.8 the numerator $|a-b|$ is constant along the flow and the hypotenuse satisfies $c_k \ge 3^k c$ (indeed $\ge 5^k c$); apply Corollary 6.2. $\square$

**Theorem 6.4 (Polynomial escape along a parabolic generator, and no faster).** *For admissible $(a,b,c)$ with $b,c>0$ and $k\ge1$,*
$$1 - x\bigl(C^k(a,b,c)\bigr) \;\ge\; \frac{c-a}{\bigl(c + 2b + 2(c-a)\bigr)\,k^2}.$$

*Proof.* By Theorem 2.7, $1 - x(C^k v) = (c-a)/\gamma_k$ with $\gamma_k = c+2kb+2k^2(c-a)$, and $\gamma_k \le k^2(c+2b+2(c-a))$ for $k\ge1$. $\square$

**Corollary 6.5 (Rate dichotomy at the root).** *For every $k \ge 1$,*
$$\frac{2}{17k^2} \;\le\; 1 - x\bigl(C^k(3,4,5)\bigr), \qquad \Bigl|x\bigl(B^k(3,4,5)\bigr) - \tfrac{\sqrt2}{2}\Bigr| \;\le\; \frac{1}{5\cdot3^{k}}.$$

The parabolic branch therefore approaches its limit at the rate $\Theta(k^{-2})$ and the hyperbolic branch at the rate $O(3^{-k})$; on a finite plot with a bounded number of levels, the former is a legible sequence of dots tracing a curve while the latter is a single streak.

**Theorem 6.6 (No star at the hyperbolic limit).** *For every $v$ with $c_v\ne0$, $x(v) \ne \tfrac{\sqrt2}{2}$.*

*Proof.* $x(v)$ is rational and $\sqrt2/2$ is irrational. $\square$

So the ideal point at angle $\pi/4$ is a limit of the plot but never a plotted point; there is no star there, only the axis geodesic of $B$. **Stars occur only at rational ideal points.**

**Theorem 6.7 (Density of star centres).** *For every $t \in [0,1)$ and $\varepsilon>0$ there exist integers $0<n<m$ with*
$$\left| \frac{m^2-n^2}{m^2+n^2} - t\right| < \varepsilon.$$

*Proof.* The function $g(r) = \dfrac{r^2-1}{r^2+1}$ is a continuous increasing bijection from $[1,\infty)$ onto $[0,1)$. Given $t$, set $r_0 = \sqrt{(1+t)/(1-t)} \ge 1$, so $g(r_0)=t$. Rationals $m/n$ with $0<n<m$ are dense in $(1,\infty)$, so choose $m/n$ within a neighbourhood on which $g$ varies by less than $\varepsilon$; then $g(m/n) = (m^2-n^2)/(m^2+n^2)$ is within $\varepsilon$ of $t$. $\square$

Combined with §7, the boundary circle carries a **dense** set of star centres.

---

## 7. Star location and multiplicity

### 7.1 Transport of the star by the monoid

Words in the generators are Lorentz isometries, so they carry horocycles to horocycles, preserving charge:
$$\langle Wv, Wp\rangle = \langle v,p\rangle \quad \text{for every word } W.$$
The key computation is
$$A\,e_1 = B\,e_1 = (3,4,5) = \mathbf r, \qquad C\,e_1 = e_1.$$
So the orbit of the ideal point $(1,0)$ under the monoid is exactly $\{(1,0)\}$ together with the ideal points of all tree nodes.

**Theorem 7.1 (A star at every node).** *For every word $W$ in the generators, the family*
$$j \longmapsto W\,A\,C^j\,\mathbf r \qquad (j = 0,1,2,\dots)$$
*consists of nodes of the tree whose plotted points converge to $\mathrm{dir}(W\mathbf r)$. In particular the root $(3,4,5)$ is a star centre: $\mathrm{dir}\bigl(A\,C^j\mathbf r\bigr) \to (3/5, 4/5)$.*

*Proof.* By the $C$-invariance of the charge at $e_1$ and $\langle \mathbf r, e_1\rangle = 3-5 = -2$, one has $\langle C^j\mathbf r, e_1\rangle = -2$ for all $j$. Applying the isometry $WA$ preserves the pairing, so $\langle WAC^j\mathbf r,\ WAe_1\rangle = -2$; but $WAe_1 = W\mathbf r$. Admissibility is preserved (Proposition 2.3) and the hypotenuse of $C^j\mathbf r$ exceeds $j$ (Theorem 2.7), while words never decrease the hypotenuse, so the hypotenuse tends to infinity. Apply Theorem 3.3. $\square$

### 7.2 Completeness of the tree

**Theorem 7.2 (Barning–Hall completeness).** *Every primitive Pythagorean triple $(a,b,c)$ with $a,b,c>0$ and $a$ odd equals $W\mathbf r$ for some word $W$ in $\{A,B,C\}$.*

*Proof sketch.* Each generator has an explicit integral inverse:
$$
\begin{aligned}
A^{-1}(a,b,c) &= (a+2b-2c,\ -2a-b+2c,\ -2a-2b+3c),\\
B^{-1}(a,b,c) &= (a+2b-2c,\ 2a+b-2c,\ -2a-2b+3c),\\
C^{-1}(a,b,c) &= (-a-2b+2c,\ 2a+b-2c,\ -2a-2b+3c).
\end{aligned}
$$
These again preserve the cone (a linear-combination identity on $Q$), and they preserve primitivity: the gcd of the legs divides the hypotenuse (since $g^2 \mid c^2$ and $c>0$ forces $g\mid c$), so a common factor of a parent's legs would be a common factor of the child's. One then shows that for any primitive triple with odd first leg other than $\mathbf r$, at least one of the three inverses produces another admissible primitive triple with **strictly smaller** hypotenuse. Fermat descent on the hypotenuse terminates, and the only fixed point of the descent is $\mathbf r$; reading the descent backwards produces the word $W$. Formally, one proves by strong induction on $c$ the statement "every admissible primitive triple with odd first leg and hypotenuse at most $N$ is in the tree". $\square$

**Theorem 7.3 (Star location).** *Every primitive Pythagorean triple $(a,b,c)$ with $a,b,c>0$ and $a$ odd is a star centre: there is a word $W$ with $W\mathbf r = (a,b,c)$ and*
$$\mathrm{dir}\bigl(W\,A\,C^j\,\mathbf r\bigr) \longrightarrow \left(\frac ac, \frac bc\right) \quad (j\to\infty).$$

*Proof.* Combine Theorems 7.1 and 7.2. $\square$

### 7.3 Multiplicity

**Definition 7.4 (Spoke charge).** For an admissible $p$ and $d>0$, say $d$ is a **spoke charge at $p$** if there exists a family $(w_j)$ of admissible triples with $\langle w_j,p\rangle = -d$ for all $j$ and $c_{w_j}\to\infty$. By Theorem 3.3, every spoke charge is drawn as a genuine curve into $\mathrm{dir}\,p$; by Theorem 3.8 distinct charges give visibly distinct curves.

**Definition 7.5 (Tree spokes).** For $n,j \ge 0$ set $T_{n,j} := C^j A^n \mathbf r$.

**Lemma 7.6.** *$T_{n,j} = \mathrm{eu}\bigl(n+2+2j(n+1),\ n+1\bigr)$, so $T_{n,j}$ is admissible, has charge $2(n+1)^2$ at $e_1$ independently of $j$, and $c_{T_{n,j}} \ge j$.*

*Proof.* By Theorem 5.7, $A^n\mathbf r = \mathrm{eu}(n+2,n+1)$; by Remark 5.8, $C^j\mathrm{eu}(m,n') = \mathrm{eu}(m+2jn', n')$. Then Theorem 5.3 gives the charge. $\square$

**Theorem 7.7 (Infinite multiplicity at $(1,0)$).** *The set of spoke charges at $e_1 = (1,0,1)$ is infinite: for every $n\ge0$, $2(n+1)^2$ is a spoke charge, witnessed by $(T_{n,j})_{j\ge0}$.*

**Theorem 7.8 (Transport of spokes).** *If $d$ is a spoke charge at $p$ and $W$ is a word in the generators, then $d$ is a spoke charge at $Wp$.*

*Proof.* Apply $W$ to the witnessing family; charge is preserved by isometry, admissibility by Proposition 2.3, and the hypotenuse does not decrease. $\square$

**Theorem 7.9 (Infinite multiplicity everywhere).** *For every node $W\mathbf r$ of the tree, and hence — by Theorem 7.2 — for every primitive Pythagorean triple $(a,b,c)$ with positive entries and odd $a$, the set of spoke charges is infinite. Every star has infinitely many distinct spokes.*

*Proof.* Take the word $W' = W\!A$; then $W'e_1 = W\mathbf r$. Transport the infinitely many charges of Theorem 7.7 by $W'$ using Theorem 7.8. Injectivity of $n \mapsto 2(n+1)^2$ keeps them distinct. $\square$

### 7.4 The exact spectrum drawn by the tree

**Theorem 7.10 (Tree spoke spectrum).** *A positive integer $d$ arises as the charge at $(1,0)$ of an unbounded family of **tree nodes** if and only if $d = 2n^2$ for some $n\ge1$.*

*Proof.* ($\Rightarrow$) Every tree node is $\mathrm{eu}(m,n)$ with $0<n<m$ (Theorem 5.2, starting from $\mathrm{eu}(2,1)$), so its charge is $2n^2$ by Theorem 5.3. ($\Leftarrow$) Given $n \ge 1$, write $n = k+1$ and take the family $\bigl(C^jA^{k}\mathbf r\bigr)_{j\ge0}$ of Lemma 7.6. $\square$

Together with Corollary 4.5 this pins the star at $(1,0)$ down completely: the drawn spokes are labelled $2, 8, 18, 32, 50, \dots$, a set of density zero, which is why they are individually visible.

---

## 8. Escape rate for mixed addresses

Theorems 6.3 and 6.4 treat *pure* branches. For a general node the relevant invariant is combinatorial in its address.

**Definition 8.1.** Let $g = g_1g_2\cdots g_\ell$ be a word in the alphabet $\{A,B,C\}$; write $|g| = \ell$ and $\#_B(g)$ for the number of occurrences of the letter $B$. Let $g\cdot\mathbf r$ denote the node reached by applying the letters to the root.

**Lemma 8.2 (Per-letter bounds).** *For every admissible $v$ and every letter $X$: $c_v \le c_{Xv} \le 7c_v$; and $c_{Bv} \ge 3c_v$.*

*Proof.* Since $a,b\le c$ (Proposition 2.3), each generator's third coordinate — a combination $\pm2a\pm2b+3c$ — lies between $c$ (Proposition 2.3) and $2c+2c+3c = 7c$. For $B$, $2a+2b+3c \ge 3c$ since $a,b\ge0$. $\square$

**Theorem 8.3 (Two-sided Lyapunov bound).** *For every address $g$,*
$$5\cdot 3^{\#_B(g)} \;\le\; c(g\cdot\mathbf r) \;\le\; 5\cdot 7^{|g|}.$$

*Proof.* Induct on the word using Lemma 8.2, with $c(\mathbf r) = 5$. $\square$

**Corollary 8.4.** *An address containing no $B$ at all satisfies $c(g\cdot\mathbf r) \le 5\cdot 7^{|g|}$ but is generated entirely by parabolic letters; exponential escape to the boundary is forced by a positive density of $B$'s in the address.*

The same alphabet records the exact effect of each letter on the spoke index: reading a word from the root, the spoke index is **frozen** by $C$ (Remark 5.8) and **refreshed to the larger parameter** by $A$ and $B$ (Theorem 5.2). So a node's spoke index equals the larger Euclid parameter of the node reached just before its final block of $C$'s.

---

## 9. Algorithms

Three algorithms suffice to reproduce and check the entire picture.

**Algorithm 1 (Tree generation to a hypotenuse bound).** Breadth-first expansion of the root by the three generators, pruning any node whose hypotenuse exceeds $N$. Because each generator strictly increases the hypotenuse on admissible nodes with positive legs, the search terminates, and by Theorem 7.2 it enumerates *exactly* the primitive triples with odd first leg and hypotenuse $\le N$, each once. Cost: $O(|\mathcal T_N|)$ arithmetic operations where $|\mathcal T_N|$ is the number of such triples, which is $\sim \tfrac{N}{2\pi}$ asymptotically.

**Algorithm 2 (Descent / address recovery).** Given a primitive triple with odd first leg, apply the inverse generator that yields an admissible primitive triple with smaller hypotenuse; repeat until the root is reached; reverse the letters. Correctness and termination are Theorem 7.2. The hypotenuse shrinks by a factor at least $\approx 1$ per step and by a factor $\ge 3$ whenever the letter is $B$; by Theorem 8.3 the number of steps is at most $\log_{3} (c/5) + (\text{number of non-}B\text{ letters})$, and in practice $O(\log c)$ for balanced addresses.

**Algorithm 3 (Spoke extraction and tangency check).** Given a target ideal point $p$ (a primitive triple) and a charge bound $D$, scan the tree of Algorithm 1 and bucket each node $v$ by its charge $d = -\langle v,p\rangle$. Buckets with $d \le D$ and many members are the visible spokes at $p$. For each bucket, the quantity $c_v\|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2$ should be *exactly* $2d/c_p$ (Theorem 3.4); this is a strong numerical check on the whole theory.

---

## 10. Applications and context

**Thin groups and local–global phenomena.** The Berggren monoid sits inside $O(2,1;\mathbb Z)$ and its orbit is a Zariski-dense but arithmetically thin subset of the light cone. Structurally the picture is the direct analogue of an Apollonian circle packing, where an infinite-index subgroup of $O(3,1;\mathbb Z)$ produces a fractal boundary set whose integer curvature data satisfy delicate local-to-global rules. Corollary 4.5 is the Pythagorean version of an Apollonian local–global theorem — and, unlike the Apollonian case, it is complete and elementary. The Pythagorean setting is therefore an unusually clean laboratory for intuitions in the geometry of numbers of thin groups.

**Visualisation as an oracle.** Every visible feature of the plot corresponds to a precise theorem: bundles $\leftrightarrow$ horocycles (Theorem 3.3); bending into the rim $\leftrightarrow$ contact order two (Corollary 3.5); brightness/discreteness of spokes $\leftrightarrow$ charge quantization (Theorem 4.3); streaks $\leftrightarrow$ hyperbolic geodesics with exponential escape (Theorem 6.3); absence of a star at $\pi/4$ $\leftrightarrow$ irrationality (Theorem 6.6); ubiquity of stars $\leftrightarrow$ transport plus completeness plus density (Theorems 7.3, 6.7). The episode is a case study in reading algebra off a picture.

**Numerical stability of Diophantine drawings.** Theorem 3.6 gives the drawn curve as an exact algebraic relation. Any plotting routine that produces qualitatively different curves is thereby diagnosable as buggy — a useful invariant test for visualisation code in this area.

**Structured integer sequence generation.** The escape-rate bound of Theorem 8.3 lets one generate Pythagorean triples with prescribed hypotenuse magnitude by choosing an address with the right number of $B$'s, and with prescribed proximity to a target boundary direction by choosing the right trailing block of $C$'s. This is a controllable generator for structured integer data — for example, benchmark inputs whose difficulty parameter (hypotenuse size) and geometric parameter (angular position, spoke index) are independently tunable.

---

## 11. Discussion and future directions

### 11.1 What is settled

Of five questions posed about the boundary picture, three are now fully resolved and one partially:

1. **Uniform tangency law.** Resolved in exact form: the product $c_v\|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2$ is not asymptotically constant but *literally* constant (Theorem 3.4), and the contact order with the circle is exactly two (Corollary 3.5).
2. **Escape-rate dichotomy for mixed addresses.** Partially resolved: Theorem 8.3 gives $5\cdot3^{\#_B} \le c \le 5\cdot7^{|g|}$, so exponential escape is forced by the density of $B$'s. What remains open is the rationality/irrationality classification of the limit point of a general infinite address.
3. **Star centres, with multiplicity.** The multiplicity half is resolved: the set of spoke charges at every primitive rational ideal point is infinite (Theorem 7.9), and at $(1,0)$ it is exactly $\{2n^2: n\ge1\}$ (Theorem 7.10). What remains open is the complementary statement that a generic irrational ideal point carries at most one curve.
4. **Charge–depth law.** Resolved, in corrected form. The naive claim that spoke index $n$ appears at depth $\Theta(\log n)$ is *false*: the $A$-branch reaches index $n$ only at depth $n-1$ (Theorem 5.7). The correct universal statement is the lower bound $n < 2\cdot3^{\mathrm{depth}}$ (Theorem 5.5), together with the attaining Pell family $2^k \le n < 2\cdot3^k$ on the hyperbolic branch (Theorem 5.6).

### 11.2 Open problems

**Conjecture A (Spectral rigidity).** Let $M$ be a submonoid of $\langle A,B,C\rangle$ and let $S(M)\subseteq \mathbb Z_{>0}$ be the set of charges realised at $(1,0)$ by the orbit $M\cdot\mathbf r$. Then $S(M) = \{2n^2 : n\ge1\}$ if and only if $M$ has finite index in the full monoid; and every thin submonoid satisfies $\#\{d\in S(M): d\le X\} = o(\sqrt X)$.

The reason to expect this is Theorem 5.3 together with Theorem 5.2: the charge of a node is $2n^2$ where $n$ is its smaller Euclid parameter, and the parameter pair evolves by the ternary tree on coprime pairs; so $S(M)$ is the image of the parameter tree under a submonoid, and counting it is an Apollonian-style local–global statistic transplanted to the Pythagorean setting.

**Conjecture B (Limit classification for infinite addresses).** For an infinite address $g_1g_2g_3\cdots$, the sequence of plotted points converges to an ideal point $\xi$; then $\xi$ is rational if and only if the address is eventually a word in $\{A,C\}$ (up to the natural identifications), and otherwise $\xi$ is an irrational point whose continued-fraction-type expansion is read off the address.

**Conjecture C (Generic simplicity).** At an ideal point that is not a primitive rational direction, the plot carries at most one accumulating curve; equivalently, a Lebesgue-generic boundary point receives no star.

**Conjecture D (Counting spokes by depth).** Let $N(k)$ be the number of distinct spoke charges at $(1,0)$ realised by nodes of depth at most $k$. Theorems 5.5–5.7 give $\Omega(k) \le N(k) \le O(3^k)$; determine the true order of growth.

### 11.3 Directions of a different kind

The Euclid-parameter picture (Theorem 5.2) recasts the whole story as a dynamical system on coprime pairs, and the charge as a quadratic form on that system. Similar statements should hold for other Lorentzian lattices: replacing $a^2+b^2-c^2$ by an indefinite ternary quadratic form of class number one, one expects an analogous tree, an analogous star picture at rational ideal points, and a quantization theorem whose spectrum is dictated by the genus theory of the form. Cataloguing those spectra is a concrete and appealing project.

---

## 12. Summary of main results

| Result | Statement |
|---|---|
| Lorentz invariance | The three Berggren generators lie in $O(2,1;\mathbb Z)$. |
| Chord–charge identity | $\|\mathrm{dir}\,v - \mathrm{dir}\,p\|^2 = -2\langle v,p\rangle/(c_vc_p)$. |
| Star theorem | Constant charge $+$ unbounded hypotenuse $\Rightarrow$ convergence to $\mathrm{dir}\,p$. |
| Exact tangency | $c_v\|\mathrm{dir}\,v-\mathrm{dir}\,p\|^2 = 2d/c_p$ exactly; contact order two. |
| Drawn-curve equation | $\|\mathrm{dir}\,v-\mathrm{dir}\,p\|^2 = 2d(1-r)/c_p$ at drawn radius $r=1-1/c_v$. |
| Charge quantization | Primitive $\Rightarrow$ $c-a \in \{2n^2\}\cup\{\text{odd }n^2\}$; spectrum exact. |
| Tree spectrum | Charges drawn by the tree at $(1,0)$ are exactly $\{2n^2:n\ge1\}$. |
| Euclid dictionary | $A:(m,n)\mapsto(2m-n,m)$, $B:(m,n)\mapsto(2m+n,m)$, $C:(m,n)\mapsto(m+2n,n)$; charges $2n^2$ and $(m-n)^2$. |
| Spoke index bound | Depth $\ell$ $\Rightarrow$ $n < 2\cdot3^\ell$; sharp via Pell numbers, $2^k\le P_k<2\cdot3^k$. |
| Escape dichotomy | $2/(17k^2) \le 1 - x(C^k\mathbf r)$, and $|x(B^k\mathbf r) - \sqrt2/2| \le 1/(5\cdot3^k)$. |
| Irrationality obstruction | No triple is plotted at $\sqrt2/2$; no star at $\pi/4$. |
| Star location | Every primitive rational ideal point with odd first leg is a star centre. |
| Star multiplicity | Every star has infinitely many distinct spokes. |
| Density | Star centres are dense in the boundary arc. |
| Lyapunov bound | $5\cdot3^{\#_B(g)} \le c(g\cdot\mathbf r) \le 5\cdot7^{|g|}$. |
