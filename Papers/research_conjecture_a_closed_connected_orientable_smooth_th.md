# Sharp Rigidity of Hopf Fibres, Extremality of Hopf-Invariant Tori, and the Linking-Form Obstruction to Embedding Three-Manifolds in the Four-Sphere

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We study three questions of four-dimensional geometry that share a common methodological feature: each reduces, under an appropriate symmetry, to the analysis of a single scalar function of a single variable.

First, we establish the exact quantitative rigidity of the fibres of the Hopf fibration $S^3 \to S^2$. For unit vectors $p, q \in \mathbb{C}^2$ let $D$ denote the Euclidean distance between their Hopf images in $\mathbb{R}^3$ and let $m$ denote the squared distance from $p$ to the circle orbit (Hopf fibre) of $q$. We prove the exact identity $D^2 = m(4-m)$. Because $m \in [0,2]$ always, this yields the sharp linear modulus of stability $\sqrt{m} \le D/\sqrt2$, with the constant $1/\sqrt2$ optimal (attained by orthogonal pairs) and the exponent $1$ optimal (no Hölder exponent $\alpha > 1$ admits any constant). In particular, the previously conjectured square-root modulus $\sqrt m \le C\sqrt{D}$ holds with $C=1$ but is not sharp: Hopf-fibre rigidity is Lipschitz, not merely Hölder.

Second, we show that this identity is dimension-free. On the unit sphere of an arbitrary complex inner product space, the phase-minimized distance $d_{\mathrm{ph}}(p,q) = \sqrt{2 - 2|\langle p,q\rangle|}$ equals $\min_{|u|=1}\|p - uq\|$, the minimum being attained; it is a metric, vanishing exactly on circle orbits; and it satisfies $m(4-m) = 2(2 - 2|\langle p,q\rangle|^2)$ with $m = d_{\mathrm{ph}}^2$, the right-hand side being the squared chordal distance of the corresponding complex lines. The sharp constant $1/\sqrt2$ therefore holds in every dimension.

Third, we refute a conjectured minimality property of the Clifford torus. Among the Hopf-invariant flat tori $T_r = \{(z,w) \in S^3 : |z| = r\}$, which are diagonally circle-invariant and separate the two coordinate circles, the area is $4\pi^2 r\sqrt{1-r^2}$. Hence the Clifford torus $r = \sqrt2/2$ is the *unique maximizer*, of area $2\pi^2$; the infimum of area over the family is $0$ and no minimizer exists. The Clifford parameter is the unique critical point of the reduced functional, so criticality — not minimality — is its unconstrained variational property.

Fourth, we determine the algebraic core of a conjectured obstruction to embedding closed three-manifolds in $S^4$. For the cyclic linking form $\ell_{n,q}(x,y) = qxy/n \bmod 1$ on $\mathbb{Z}/n$ with $\gcd(q,n)=1$ — the linking form of the lens space $L(n,q)$ — we prove that a metabolizer (a subgroup equal to its own annihilator) exists if and only if $n$ is a perfect square, the quantifier ranging over all subgroups. Combined with the classical fact that an embedded three-manifold has metabolic linking form, this rules out smooth embeddings of $L(n,q)$ in $S^4$ whenever $n$ is not a square, uniformly in $q$; and it shows that the linking form alone is insufficient, since $L(4,q)$ passes the test.

---

## 1. Introduction

### 1.1 Three conjectures

The four-dimensional world is the first in which smooth topology and geometry decouple violently from intuition, and it is correspondingly rich in plausible conjectures that turn out to be subtly — or grossly — false. This paper reports the resolution of three such statements, all belonging to the geometry of the three-sphere and its embeddings into four-space.

1. **Quantitative rigidity of almost-Hopf fibres.** The Hopf map identifies two unit vectors of $\mathbb{C}^2$ precisely when they differ by a unit phase. Conjecturally, this exact rigidity has a Hölder-$\tfrac12$ quantitative counterpart: there is a universal $C$ such that unit vectors with Hopf images at distance $\le \varepsilon$ can be aligned, after multiplication by a phase, to within $C\sqrt{\varepsilon}$, the exponent $\tfrac12$ being optimal.

2. **Clifford-torus extremality.** Conjecturally, among embedded tori in $S^3$ invariant under the diagonal circle action and separating the two coordinate circles, the Clifford torus uniquely minimizes area.

3. **Embedding obstruction for closed three-manifolds.** Conjecturally, a closed connected orientable smooth three-manifold embeds in $S^4$ exactly when it bounds two compact four-manifolds whose intersection pairings and linking forms satisfy the complementary conditions induced by the two components of the complement.

The verdicts are, respectively: *true but not sharp* (the correct modulus is linear, with optimal constant $1/\sqrt2$); *false*, the truth being unique maximality; and *partially resolvable*, in the sense that the linking-form half of the coupled obstruction has an exact, computable characterization for cyclic forms.

### 1.2 The method: symmetry reduction to one variable

The unifying technique is elementary but worth naming. In each case a symmetry group — the diagonal circle action in the first two problems, the cyclic structure of homology in the third — collapses the problem to a single scalar parameter, after which the entire question becomes a one-variable identity or inequality:

| Problem | Reduced variable | Reduced object |
|---|---|---|
| Hopf-fibre rigidity | $t = \lvert\langle p,q\rangle\rvert \in [0,1]$ | identity $D^2 = m(4-m)$, $m = 2-2t$ |
| Hopf-invariant tori | radius $r \in (0,1)$ | area functional $4\pi^2 r\sqrt{1-r^2}$ |
| Cyclic linking forms | divisor $d \mid n$ | annihilator rule $H_d^{\perp} = H_{n/d}$ |

Once the reduction is performed, no geometric estimation remains: the answers are visible.

### 1.3 Organization

Section 2 fixes notation. Section 3 proves the Hopf distance identity and its sharp consequences. Section 4 develops the dimension-free theory of the phase-minimized (chordal projective) metric. Section 5 computes the areas of Hopf-invariant tori and refutes the Clifford minimality conjecture. Section 6 characterizes metabolizers of cyclic linking forms and derives the lens-space obstruction. Section 7 presents the algorithms implicit in these results. Section 8 discusses applications, and Section 9 lists open problems generated by this work.

---

## 2. Notation and preliminaries

We identify $\mathbb{R}^4 \cong \mathbb{C}^2$ and write points as pairs $p = (z,w)$ of complex numbers. The Hermitian pairing is
$$\langle p, q\rangle = z\overline{z'} + w\overline{w'}, \qquad p = (z,w),\; q = (z',w'),$$
and $\|p\|^2 = \langle p,p\rangle = |z|^2+|w|^2$. The unit three-sphere is $S^3 = \{p : \|p\| = 1\}$.

**Definition 2.1 (Unit pair).** A pair $(z,w) \in \mathbb{C}^2$ is a *unit pair* if $|z|^2 + |w|^2 = 1$.

**Definition 2.2 (Diagonal circle action).** For $u \in \mathbb{C}$ with $|u| = 1$, set $u\cdot(z,w) = (uz, uw)$. The orbits of this action on $S^3$ are the *Hopf fibres*.

**Definition 2.3 (Hopf map).** The Hopf map $H : \mathbb{C}^2 \to \mathbb{R}^3$ is
$$H(z,w) = \bigl(2\operatorname{Re}(z\overline{w}),\; 2\operatorname{Im}(z\overline{w}),\; |z|^2 - |w|^2\bigr).$$
It maps $S^3$ onto the unit two-sphere $S^2$, and $H(p) = H(q)$ for unit $p,q$ if and only if $q = u\cdot p$ for some unit phase $u$.

**Definition 2.4 (Hopf and fibre distances).** For $p = (z,w)$, $q = (z',w')$ set
$$D^2(p,q) = \|H(p) - H(q)\|^2 = \sum_{i=1}^{3}\bigl(H(p)_i - H(q)_i\bigr)^2,$$
$$\delta^2(u; p, q) = \|p - u\cdot q\|^2 = |z - uz'|^2 + |w - uw'|^2,\qquad m(p,q) = 2 - 2\,|\langle p,q\rangle| .$$
We will show that $m(p,q) = \min_{|u|=1}\delta^2(u;p,q)$ for unit pairs, so $m$ deserves the name *squared fibre distance*.

---

## 3. Sharp quantitative rigidity of Hopf fibres

### 3.1 The two quadratic computations

**Lemma 3.1 (Polarization for the Hopf map).** For arbitrary $p = (z,w)$, $q = (z',w') \in \mathbb{C}^2$,
$$D^2(p,q) = \bigl(|z|^2+|w|^2+|z'|^2+|w'|^2\bigr)^2 - 4\,\bigl|\langle p,q\rangle\bigr|^2 .$$

*Proof sketch.* Expand all three components of $H(p) - H(q)$ in real coordinates. Every term is a polynomial of degree four in the eight real variables $\operatorname{Re}z, \operatorname{Im}z, \dots$, and the asserted equality is a polynomial identity, verified by direct expansion. The mechanism is the classical fact that $H$ is the composite of the Hermitian outer product with the traceless-Hermitian coordinates: writing $P = pp^{*}$, one has $H(p) = (\operatorname{tr}(P\sigma_1), \operatorname{tr}(P\sigma_2), \operatorname{tr}(P\sigma_3))$ in terms of Pauli matrices, and $\|H(p)-H(q)\|^2 = 2\|P - Q\|_{HS}^2 - (\operatorname{tr}(P-Q))^2$ expands to the stated form. $\square$

**Corollary 3.2.** If $p$ and $q$ are unit pairs then, writing $t = |\langle p,q\rangle|$,
$$D^2(p,q) = 4\,(1 - t^2).$$

**Corollary 3.3 (Cauchy–Schwarz).** For unit pairs, $t \le 1$. Indeed $D^2 \ge 0$, and Corollary 3.2 forces $t^2 \le 1$.

**Lemma 3.4 (Exact expansion against a phase).** For unit pairs $p, q$ and $|u| = 1$,
$$\delta^2(u; p, q) = 2 - 2\operatorname{Re}\bigl(\langle p,q\rangle\,\overline{u}\bigr).$$

*Proof sketch.* Expand $\|p - u\cdot q\|^2 = \|p\|^2 + |u|^2\|q\|^2 - 2\operatorname{Re}\langle p, u q\rangle$ and use $\|p\| = \|q\| = |u| = 1$ together with $\langle p, uq\rangle = \overline{u}\langle p,q\rangle$. $\square$

**Proposition 3.5 (The fibre distance is a minimum, and it is attained).** For unit pairs $p, q$:

1. $m(p,q) \le \delta^2(u;p,q)$ for every unit phase $u$;
2. there exists a unit phase $u_\star$ with $\delta^2(u_\star;p,q) = m(p,q)$; explicitly, $u_\star = \langle p,q\rangle/|\langle p,q\rangle|$ when $\langle p,q\rangle \ne 0$, and $u_\star = 1$ otherwise;
3. $0 \le m(p,q) \le 2$.

*Proof sketch.* (1) By Lemma 3.4 it suffices that $\operatorname{Re}(\langle p,q\rangle\overline{u}) \le |\langle p,q\rangle\overline{u}| = |\langle p,q\rangle|$. (2) With $s = \langle p,q\rangle \ne 0$ and $u_\star = s/|s|$ one computes $s\overline{u_\star} = |s|$, a positive real, so the inequality in (1) is an equality. (3) follows from $0 \le t \le 1$ (Corollary 3.3). $\square$

### 3.2 The identity

**Theorem 3.6 (Hopf Distance Identity).** For unit pairs $p, q \in \mathbb{C}^2$,
$$D^2(p,q) = m(p,q)\,\bigl(4 - m(p,q)\bigr).$$

*Proof.* With $t = |\langle p,q\rangle|$ we have $m = 2 - 2t$ by definition, hence $m(4-m) = (2-2t)(2+2t) = 4(1 - t^2) = D^2$ by Corollary 3.2. $\square$

Geometrically, the identity says that the map $m \mapsto D^2 = m(4-m)$ is a fixed, dimension-independent reparametrization of the "distance to the fibre" by the "distance downstairs". It is a concave increasing bijection $[0,2] \to [0,4]$, with slope $4$ at $m = 0$ and slope $0$ at $m = 2$: the Hopf map is a submersion of local expansion factor $2$ near the diagonal, and degenerates exactly at antipodal image pairs.

### 3.3 Sharp stability

**Theorem 3.7 (Sharp linear stability).** For unit pairs $p, q$,
$$m(p,q) \le \tfrac12\,D^2(p,q).$$
Equivalently: if $\|H(p) - H(q)\| \le \varepsilon$, then there is a unit phase $u$ with $\|p - u\cdot q\| \le \varepsilon/\sqrt2$.

*Proof.* By Proposition 3.5(3), $m \le 2$, hence $4 - m \ge 2$; multiply by $m \ge 0$ and use Theorem 3.6 to get $D^2 = m(4-m) \ge 2m$. The alignment statement follows by taking $u = u_\star$ from Proposition 3.5(2). $\square$

**Definition 3.8 (Hölder stability).** For $C, \alpha \in \mathbb{R}$ say that *$(C,\alpha)$-stability* holds if for all unit pairs $p,q$ and all $\varepsilon \ge 0$ with $D^2(p,q) \le \varepsilon^2$, there is a unit phase $u$ with $\delta^2(u;p,q) \le (C\varepsilon^{\alpha})^2$.

**Corollary 3.9.** $(1/\sqrt2, 1)$-stability holds. Moreover $(1, \tfrac12)$-stability holds, so the originally conjectured square-root modulus is valid with $C = 1$.

*Proof sketch.* The first claim is Theorem 3.7. For the second: if $\varepsilon \le 2$ then $m \le \varepsilon^2/2 \le \varepsilon$ (using $\varepsilon^2 \le 2\varepsilon$); if $\varepsilon > 2$ then $m \le 2 < \varepsilon$ outright. Either way $m \le \varepsilon = (1\cdot\varepsilon^{1/2})^2$. $\square$

**Theorem 3.10 (Optimality of the constant).** If $0 \le C < 1/\sqrt2$ then $(C,1)$-stability fails.

*Proof.* Take $p = (1,0)$, $q = (0,1)$, which are orthogonal unit pairs. Then $t = 0$, so $D^2 = 4$ and $m = 2$; moreover, by Lemma 3.4, $\delta^2(u;p,q) = 2$ for *every* unit phase $u$: no alignment is possible at all. Applying $(C,1)$-stability with $\varepsilon = 2$ would give $2 \le (2C)^2 = 4C^2$, i.e. $C \ge 1/\sqrt2$. $\square$

**Theorem 3.11 (Optimality of the exponent).** For every $C \in \mathbb{R}$ and every $\alpha > 1$, $(C,\alpha)$-stability fails.

*Proof sketch.* Consider the near-fibre family: $p = (1,0)$ and, for $x \in [0,1]$,
$$q_x = \Bigl(1-x,\ \sqrt{1 - (1-x)^2}\Bigr).$$
This is a unit pair, $t = 1 - x$, and therefore
$$D^2(p,q_x) = 8x - 4x^2, \qquad m(p,q_x) = 2x .$$
Set $\varepsilon = \sqrt{8x - 4x^2}$, so the hypothesis of stability holds with equality. Stability would give $2x = m \le (C\varepsilon^{\alpha})^2 = C^2(8x-4x^2)^{\alpha} \le C^2 (8x)^{\alpha}$. For $\alpha > 1$ the right side is $O(x^{\alpha}) = o(x)$ as $x \downarrow 0$, a contradiction for small $x$. Quantitatively, choosing $x = y/8$ with $y \le \min\{1/2,\ a^{1/(\alpha-1)}\}$ and $a = (4C^2+1)^{-1}$ makes $C^2(8x)^{\alpha} = C^2 y^{\alpha} \le C^2 y a < y/4 = 2x$, the desired contradiction. $\square$

### 3.4 Interpretation: two different extremes

The two optimality proofs use configurations at opposite ends of the sphere, and the contrast is instructive. Define the *stability ratio* $\rho = m/D^2 \in [1/4, 1/2]$. From the identity, $\rho = 1/(4-m)$, so:

* $\rho \to 1/4$ as $m \to 0$: for *nearby* points the Hopf map is a Riemannian submersion up to the scaling factor $2$, and the sharp local statement is $\sqrt m \approx D/2$;
* $\rho = 1/2$ exactly at $m = 2$, i.e. for orthogonal $p, q$, whose Hopf images are antipodal.

The globally optimal constant is thus governed by the antipodal configuration, while the impossibility of a superlinear modulus is governed by the near-diagonal configuration. Both are needed; neither suffices alone.

---

## 4. The dimension-free theory: the circle-quotient metric

Nothing in Section 3 used the dimension: only the Hermitian pairing and the scalar $t$. We now record the general theory.

Let $E$ be a complex inner product space with Hermitian pairing $\langle \cdot,\cdot\rangle$, linear in the first argument, and let $S(E)$ denote its unit sphere.

**Definition 4.1 (Phase distance).** For $p, q \in E$,
$$d_{\mathrm{ph}}(p,q) = \sqrt{\,2 - 2\,\bigl|\langle p,q\rangle\bigr|\,}.$$

**Theorem 4.2 (It is the distance to the circle orbit).** Let $p, q \in S(E)$. Then:

1. $d_{\mathrm{ph}}(p,q) \le \|p - u q\|$ for every $u \in \mathbb{C}$ with $|u| = 1$;
2. the bound is attained: there exists a unit $u$ with $\|p - uq\| = d_{\mathrm{ph}}(p,q)$;

hence $d_{\mathrm{ph}}(p,q) = \min_{|u| = 1}\|p - uq\| = \operatorname{dist}\bigl(p,\ \mathbb{T}\cdot q\bigr)$, the distance from $p$ to the circle orbit of $q$.

*Proof sketch.* Expand $\|p - uq\|^2 = 2 - 2\operatorname{Re}(u\langle q,p\rangle)$ and optimize over the unit circle, exactly as in Lemma 3.4 and Proposition 3.5; the optimal phase is $\overline{s}/|s|$ with $s = \langle p,q\rangle$ (any phase if $s = 0$). $\square$

**Theorem 4.3 (Triangle inequality).** For $p,q,r \in S(E)$,
$$d_{\mathrm{ph}}(p,r) \le d_{\mathrm{ph}}(p,q) + d_{\mathrm{ph}}(q,r).$$

*Proof.* Choose optimal phases $u$ for $(p,q)$ and $v$ for $(q,r)$, so that $\|p - uq\| = d_{\mathrm{ph}}(p,q)$ and $\|q - vr\| = d_{\mathrm{ph}}(q,r)$. The product $uv$ is a unit phase, and
$$d_{\mathrm{ph}}(p,r) \le \|p - (uv)r\| \le \|p - uq\| + \|uq - (uv)r\| = \|p-uq\| + \|q - vr\|,$$
using Theorem 4.2(1) for the first inequality, the ordinary triangle inequality for the second, and $\|u(q - vr)\| = \|q - vr\|$ for the last equality. $\square$

**Theorem 4.4 (Rigidity / equality case).** For $p,q \in S(E)$: $d_{\mathrm{ph}}(p,q) = 0$ if and only if $p = uq$ for some unit phase $u$.

*Proof sketch.* If the distance vanishes, the attained minimum gives $\|p - u q\| = 0$ for the optimal phase. Conversely $|\langle uq, q\rangle| = 1$ makes the defining radicand vanish. $\square$

Together, Theorems 4.2–4.4 say that $d_{\mathrm{ph}}$ descends to a genuine metric on the quotient $S(E)/\mathbb{T}$, i.e. on the projectivization $\mathbb{P}(E)$; it is the *chordal* Fubini–Study distance, realized as the Hausdorff-type distance between circle orbits.

**Theorem 4.5 (Dimension-free identity).** For $p,q \in S(E)$, with $m = d_{\mathrm{ph}}(p,q)^2$ and $t = |\langle p,q\rangle|$,
$$m\,(4 - m) = 2\bigl(2 - 2t^2\bigr) = 4(1 - t^2).$$

*Proof.* $m = 2 - 2t$, so $m(4-m) = (2-2t)(2+2t) = 4(1-t^2)$. $\square$

The quantity $4(1-t^2)$ is the squared chordal distance between the complex lines $[p]$ and $[q]$: for rank-one projections $P = pp^{*}$, $Q = qq^{*}$, one has $\|P - Q\|_{HS}^2 = 2(1-t^2)$, so $4(1-t^2) = 2\|P-Q\|_{HS}^2$. In $E = \mathbb{C}^2$, this is exactly $D^2$, and Theorem 4.5 specializes to Theorem 3.6.

**Corollary 4.6 (Sharp linear stability in all dimensions).** If $4(1-t^2) \le \varepsilon^2$ then $m \le \varepsilon^2/2$; that is, two complex lines within chordal distance $\varepsilon$ have unit representatives within $\varepsilon/\sqrt2$.

*Proof.* From Theorem 4.5 and $m \le 2$: $\varepsilon^2 \ge m(4-m) \ge 2m$. $\square$

**Proposition 4.7 (Consistency).** For unit pairs $(z,w)$ and $(z',w')$, viewed as vectors of $\mathbb{C}^2$ with its standard Hermitian pairing, $d_{\mathrm{ph}}^2 = m$ as defined in Section 3.

*Proof sketch.* The two pairings differ by complex conjugation, which does not change the modulus. $\square$

Thus the sharp constant $1/\sqrt2$ of Theorem 3.7 is not a feature of dimension four; it is a feature of the Cauchy–Schwarz defect of a Hermitian form. What *is* special to $\mathbb{C}^2$ is only the identification of the quotient with a round two-sphere via $H$.

---

## 5. Hopf-invariant tori: the Clifford torus maximizes area

### 5.1 The family and its geometry

**Definition 5.1.** For $0 \le r \le 1$ let
$$T_r = \{(z,w) \in \mathbb{C}^2 : |z| = r,\ |w| = \sqrt{1-r^2}\},$$
parametrized by $\Phi_r(s,t) = \bigl(r e^{is},\ \sqrt{1-r^2}\,e^{it}\bigr)$, $(s,t) \in [0,2\pi]^2$.

**Proposition 5.2 (Basic properties).** For $0 < r < 1$:

1. $T_r \subset S^3$: indeed $\|\Phi_r(s,t)\|^2 = r^2 + (1-r^2) = 1$;
2. $T_r$ is invariant under the diagonal circle action: $e^{i\theta}\cdot\Phi_r(s,t) = \Phi_r(s+\theta, t+\theta)$;
3. $T_r$ separates the two coordinate circles $C_1 = \{(z,0): |z|=1\}$ and $C_2 = \{(0,w): |w|=1\}$, in the concrete sense that $|z| = 1 > r$ on $C_1$ while $|z| = 0 < r$ on $C_2$, and $|z| = r$ on $T_r$;
4. $T_r$ is the Hopf preimage of the circle of latitude $\{x_3 = 2r^2 - 1\} \cap S^2$; in particular $T_{\sqrt2/2}$, the *Clifford torus*, is the preimage of the equator.

*Proof sketch.* (1)–(3) are immediate from the parametrization. (4): the third Hopf coordinate is $|z|^2 - |w|^2 = r^2 - (1-r^2) = 2r^2 - 1$. $\square$

### 5.2 The first fundamental form and the area

**Lemma 5.3 (Tangent frame).** The partial derivatives of $\Phi_r$ are
$$\partial_s \Phi_r = \bigl(i r e^{is},\ 0\bigr), \qquad \partial_t \Phi_r = \bigl(0,\ i\sqrt{1-r^2}\,e^{it}\bigr),$$
these being genuine derivatives of the coordinate maps.

**Lemma 5.4 (Coefficients).** With respect to the Euclidean (real part of the Hermitian) inner product of $\mathbb{C}^2 \cong \mathbb{R}^4$,
$$E = \langle \partial_s\Phi_r, \partial_s\Phi_r\rangle_{\mathbb{R}} = r^2, \qquad F = \langle \partial_s\Phi_r, \partial_t\Phi_r\rangle_{\mathbb{R}} = 0, \qquad G = \langle \partial_t\Phi_r, \partial_t\Phi_r\rangle_{\mathbb{R}} = 1 - r^2 .$$

*Proof sketch.* Each tangent vector has one vanishing component, so $F = 0$ identically; the diagonal entries are the squared moduli $|ire^{is}|^2 = r^2$ and $|i\sqrt{1-r^2}e^{it}|^2 = 1-r^2$. $\square$

Since $E$ and $G$ are constants, $T_r$ is a *flat* torus: it is the quotient of the plane by the rectangular lattice $2\pi r\mathbb{Z} \times 2\pi\sqrt{1-r^2}\,\mathbb{Z}$.

**Theorem 5.5 (Area formula).** For $0 \le r \le 1$,
$$\operatorname{Area}(T_r) = \int_0^{2\pi}\!\!\int_0^{2\pi} \sqrt{EG - F^2}\;dt\,ds = 4\pi^2\, r\sqrt{1-r^2}.$$

*Proof.* By Lemma 5.4 the integrand equals $\sqrt{r^2(1-r^2)} = r\sqrt{1-r^2}$, a constant; multiply by the area $4\pi^2$ of the fundamental square. $\square$

### 5.3 Extremality

**Theorem 5.6 (Clifford value).** $\operatorname{Area}(T_{\sqrt2/2}) = 2\pi^2$.

*Proof.* $1 - (\sqrt2/2)^2 = 1/2 = (\sqrt2/2)^2$, so $r\sqrt{1-r^2} = 1/2$ at $r = \sqrt2/2$. $\square$

**Theorem 5.7 (Unique maximality).** For all $r \in [0,1]$, $\operatorname{Area}(T_r) \le 2\pi^2$, with equality if and only if $r = \sqrt2/2$.

*Proof.* Put $\sigma = \sqrt{1-r^2}$, so $r^2 + \sigma^2 = 1$ and $r,\sigma \ge 0$. Then $(r - \sigma)^2 \ge 0$ gives $2r\sigma \le r^2 + \sigma^2 = 1$, i.e. $r\sigma \le 1/2$, with equality iff $r = \sigma$, i.e. $r^2 = 1/2$. Multiply by $4\pi^2$ and apply Theorem 5.5. $\square$

**Theorem 5.8 (Infimum zero; no minimizer).** For every $\delta > 0$ there is $r \in (0,1)$ with $0 < \operatorname{Area}(T_r) < \delta$. Consequently $\inf_{0<r<1}\operatorname{Area}(T_r) = 0$ and the infimum is not attained.

*Proof sketch.* Take $r = \min\{1/2,\ \delta/(8\pi^2)\}$. Then $\sqrt{1-r^2} \in (0,1]$, so
$0 < \operatorname{Area}(T_r) = 4\pi^2 r\sqrt{1-r^2} \le 4\pi^2 r \le \delta/2 < \delta$. $\square$

**Theorem 5.9 (Refutation).** The statement "for all $r \in (0,1)$, $\operatorname{Area}(T_{\sqrt2/2}) \le \operatorname{Area}(T_r)$" is false.

*Proof.* By Theorem 5.8 choose $r$ with $\operatorname{Area}(T_r) < \pi^2 < 2\pi^2 = \operatorname{Area}(T_{\sqrt2/2})$. $\square$

Thus the conjectured minimality fails inside the most natural test family, and fails badly: the conjectured minimizer is the unique maximizer.

### 5.4 What the Clifford torus really is: the unique critical point

**Theorem 5.10 (Derivative of the reduced functional).** On $(0,1)$ the map $r \mapsto \operatorname{Area}(T_r)$ is differentiable with
$$\frac{d}{dr}\operatorname{Area}(T_r) = 4\pi^2\,\frac{1 - 2r^2}{\sqrt{1-r^2}} .$$

*Proof sketch.* Differentiate $4\pi^2 r\sqrt{1-r^2}$ by the product and chain rules: $\sqrt{1-r^2} - r^2/\sqrt{1-r^2} = (1-2r^2)/\sqrt{1-r^2}$. $\square$

**Theorem 5.11 (Unique critical point).** For $r \in (0,1)$: $\frac{d}{dr}\operatorname{Area}(T_r) = 0 \iff r = \sqrt2/2$.

*Proof.* The denominator is positive, and $1 - 2r^2 = 0$ has the unique positive root $r = 1/\sqrt2 = \sqrt2/2$. $\square$

Criticality of the area functional in a symmetric family is the correct algebraic shadow of minimality of the surface: the Clifford torus is a minimal surface in $S^3$, and this is precisely what Theorem 5.11 detects. What Theorem 5.7 adds is that this critical point is a *maximum* of area within the family. Hence any true extremality statement for the Clifford torus must be constrained: minimality among *minimal* tori (as in the resolution of the Willmore problem), or minimality of a curvature-weighted energy. Unconstrained area minimization in the Hopf-invariant class is simply the wrong problem: its infimum is $0$ and is approached by degenerating tori collapsing onto a coordinate circle.

---

## 6. Linking forms and the embedding obstruction

### 6.1 Setting

Let $Y$ be a closed connected orientable smooth three-manifold. If $Y$ embeds smoothly in $S^4$, the complement has two components with closures $X_1, X_2$, compact smooth four-manifolds with $\partial X_i = Y$ and $S^4 = X_1 \cup_Y X_2$. Two classical consequences of Alexander duality and the Mayer–Vietoris sequence constrain $Y$:

* **(Doubling.)** $H_1(Y;\mathbb{Z}) \cong G \oplus G$ for some finite abelian group $G$ (when $H_1$ is finite);
* **(Metabolicity.)** the linking form $\ell : \operatorname{Tors}H_1(Y) \times \operatorname{Tors}H_1(Y) \to \mathbb{Q}/\mathbb{Z}$ is *metabolic*: some subgroup $H$ satisfies $H = H^{\perp}$, where $H^\perp = \{x : \ell(x,y) = 0 \ \forall y \in H\}$.

These topological inputs are classical and are used here only to interpret the algebra; everything proved below is a theorem about finite cyclic linking forms, independent of the topology.

The conjecture motivating this section proposes that the *coupled* system — intersection pairings of $X_1$ and $X_2$ together with the linking form of $Y$ — characterizes embeddability. We isolate and completely solve its linking-form component in the cyclic case, which is the case of lens spaces.

### 6.2 Cyclic linking forms

The lens space $L(n,q)$, $\gcd(q,n)=1$, has $H_1 = \mathbb{Z}/n$ and linking form $\ell_{n,q}(x,y) = qxy/n \bmod 1$. We work with integer representatives.

**Definition 6.1.** For $n, q \in \mathbb{N}$ and $x, y \in \mathbb{Z}$, say the form *vanishes* on $(x,y)$, written $\ell_{n,q}(x,y) = 0$, if $n \mid qxy$ in $\mathbb{Z}$. For $d \in \mathbb{Z}$ let $H_d = \{x \in \mathbb{Z} : d \mid x\}$, the preimage in $\mathbb{Z}$ of the subgroup of $\mathbb{Z}/n$ generated by $d$. For a set $S$ of representatives put $S^{\perp} = \{x : \ell_{n,q}(x,y) = 0 \text{ for all } y \in S\}$, and call $S$ a *metabolizer* if $S = S^{\perp}$.

**Lemma 6.2 (Subgroups are divisor subgroups).** Let $n > 0$ and let $H \le \mathbb{Z}$ be a subgroup containing $n$ (i.e. a subgroup of $\mathbb{Z}/n$, pulled back). Then $H = H_d$ for a unique $d > 0$ with $d \mid n$.

*Proof sketch.* Every subgroup of $\mathbb{Z}$ is cyclic, $H = a\mathbb{Z}$; take $d = |a|$, which is nonzero since $n \in H$ and $n \ne 0$, and divides $n$ since $n \in H$. $\square$

**Lemma 6.3 (Annihilator rule).** Let $d \mid n$, $d > 0$, and $\gcd(q,n) = 1$. Then
$$H_d^{\perp} = H_{n/d}.$$

*Proof.* Write $n = de$. ($\subseteq$) If $x \in H_d^{\perp}$, testing against $y = d$ gives $n \mid qxd$, i.e. $de \mid qxd$, so $e \mid qx$; since $\gcd(q,n)=1$ and $e \mid n$, also $\gcd(q,e) = 1$, whence $e \mid x$, i.e. $x \in H_e = H_{n/d}$. ($\supseteq$) If $x = ec$ and $y = dk$ then $qxy = q\,ec\,dk = n\,(qck)$, so $n \mid qxy$. $\square$

**Theorem 6.4 (Metabolizer criterion for divisor subgroups).** Let $n > 0$, $d \mid n$, $d > 0$, $\gcd(q,n)=1$. Then $H_d$ is a metabolizer for $\ell_{n,q}$ if and only if $n = d^2$.

*Proof.* By Lemma 6.3, $H_d = H_d^{\perp}$ iff $H_d = H_{n/d}$; two divisor subgroups with positive generators coincide iff the generators are equal, so this says $d = n/d$, i.e. $n = d^2$. $\square$

**Theorem 6.5 (Main criterion).** Let $n > 0$ and $\gcd(q,n) = 1$. Then $\ell_{n,q}$ admits a metabolizer — that is, there exists a subgroup $H \le \mathbb{Z}/n$ with $H = H^{\perp}$ — if and only if $n$ is a perfect square.

*Proof.* ($\Rightarrow$) By Lemma 6.2 any such $H$ is $H_d$ with $d \mid n$, $d>0$; Theorem 6.4 gives $n = d^2$. ($\Leftarrow$) If $n = m^2$ with $m > 0$, then $m \mid n$ and Theorem 6.4 shows $H_m$ is a metabolizer. $\square$

Two features deserve emphasis. First, the criterion is *uniform in $q$*: the finer arithmetic of the lens parameter is invisible to metabolicity. Second, the quantifier ranges over all subgroups, not merely the obvious candidates, so the negative conclusions below are genuine and not an artefact of a restricted search.

### 6.3 Consequences for lens spaces

**Corollary 6.6.** For every $q$ coprime to $3$, the linking form $\ell_{3,q}$ admits no metabolizer. Hence, by the classical metabolicity constraint, $L(3,q)$ does not embed smoothly in $S^4$.

**Corollary 6.7.** The same conclusion holds for every $n$ that is not a perfect square, e.g. $n \in \{2,3,5,6,7,8,10,11,12,\dots\}$: no lens space $L(n,q)$ with such $n$ embeds smoothly in $S^4$.

**Proposition 6.8 (Positive control).** For $\gcd(q,4)=1$, $\ell_{4,q}$ *does* admit a metabolizer, namely $H_2$. Similarly $\ell_{9,q}$ admits $H_3$. The linking-form obstruction therefore does not, by itself, exclude $L(4,q)$ or $L(9,q)$.

This is the precise sense in which the linking form is only *half* of the conjectured obstruction: it detects $|H_1|$ up to squares and nothing more; the intersection pairings of the two complementary regions must supply the rest.

### 6.4 The doubling shadow

**Theorem 6.9 (Square order from doubling).** If a finite abelian group $A$ admits an isomorphism $A \cong G \oplus G$, then $|A| = |G|^2$ is a perfect square.

*Proof.* $|A| = |G \oplus G| = |G|\cdot|G|$. $\square$

**Corollary 6.10.** $\mathbb{Z}/3$ is not isomorphic to $G \oplus G$ for any finite abelian $G$; hence, by the classical doubling constraint, no closed orientable three-manifold with first homology $\mathbb{Z}/3$ — for instance $L(3,q)$ — embeds smoothly in $S^4$.

The two constraints are logically distinct. Doubling implies square order, which for cyclic forms is equivalent to metabolicity (Theorem 6.5); but doubling is strictly stronger, since $\mathbb{Z}/4$ has square order and a metabolizer while admitting no splitting $G \oplus G$ (that would force $G = \mathbb{Z}/2$ and $A = \mathbb{Z}/2\oplus\mathbb{Z}/2 \ne \mathbb{Z}/4$). The example $L(4,q)$ therefore separates the two halves of the coupled obstruction, and shows exactly where the conjecture's insistence on coupling earns its keep.

---

## 7. Algorithms

The results above are effective. We record the four algorithms they encode, with their complexity.

### 7.1 Optimal phase alignment

**Input:** unit vectors $p, q$ in $\mathbb{C}^N$. **Output:** the optimal phase $u_\star$, the phase distance, and a certificate.

1. Compute $s = \langle p,q\rangle = \sum_j p_j\overline{q_j}$; cost $O(N)$.
2. If $s = 0$, set $u_\star = 1$; otherwise $u_\star = s/|s|$.
3. Return $d_{\mathrm{ph}} = \sqrt{2 - 2|s|}$ and check $\|p - u_\star q\| = d_{\mathrm{ph}}$ to numerical precision.

Correctness is Theorem 4.2. Complexity $O(N)$ time, $O(1)$ extra space — a single inner product replaces a one-dimensional optimization over the circle.

### 7.2 Hopf stability certificate

**Input:** unit pairs $p,q \in \mathbb{C}^2$. **Output:** $D^2$, $m$, the identity residual, and the ratio $m/D^2$.

1. Compute $H(p), H(q)$ and $D^2 = \|H(p)-H(q)\|^2$; $O(1)$.
2. Compute $t = |\langle p,q\rangle|$ and $m = 2-2t$.
3. Report the residual $|D^2 - m(4-m)|$ (zero in exact arithmetic, Theorem 3.6) and $\rho = m/D^2 \in [1/4,1/2]$.

This certifies both the identity and the sharp bound $m \le D^2/2$ numerically.

### 7.3 Extremal search in the Hopf-invariant torus family

**Input:** none (or a subinterval of radii). **Output:** the area-maximizing radius and value.

1. The reduced functional is $A(r) = 4\pi^2 r\sqrt{1-r^2}$.
2. $A$ is strictly unimodal on $[0,1]$ (Theorem 5.7), so ternary/golden-section search converges linearly to $r^\star$; each evaluation is $O(1)$, and $k$ iterations give accuracy $O(0.618^k)$.
3. Compare against the closed form $r^\star = \sqrt2/2$, $A(r^\star) = 2\pi^2$.

The point of running the search is that the closed form is a *derived* fact: the search independently confirms unimodality and the location of the extremum, and simultaneously exhibits $A(r)\to 0$ as $r \to 0^+$, i.e. the failure of minimality.

### 7.4 Metabolizer search for cyclic linking forms

**Input:** $n \ge 1$ and $q$ with $\gcd(q,n)=1$. **Output:** a metabolizer generator $d$ or a proof of nonexistence.

1. Enumerate divisors $d$ of $n$ by trial division up to $\sqrt n$: $O(\sqrt n)$.
2. For each $d$, compute $H_d^{\perp} = H_{n/d}$ (Lemma 6.3) and test $d = n/d$.
3. Return the unique $d$ with $d^2 = n$ if it exists; otherwise report that no subgroup of $\mathbb{Z}/n$ is self-annihilating.

By Theorem 6.5 the answer is simply "is $n$ a perfect square", computable in $O(\log n)$ arithmetic operations by integer square root; the divisor enumeration is retained because it also *exhibits* the annihilator pairing $d \leftrightarrow n/d$, which is the structural content, and because it generalizes to non-cyclic forms where no closed-form criterion is available.

---

## 8. Applications and interpretation

**Numerical linear algebra and quantum information.** Theorem 4.2 and Corollary 4.6 are exactly the statements needed to compare *rays* rather than vectors. In quantum mechanics a pure state is a unit vector modulo phase, and the operationally meaningful distance is the phase-minimized one: the fidelity is $t^2 = |\langle p,q\rangle|^2$, and $d_{\mathrm{ph}}^2 = 2 - 2t$ is the squared Bures-type chordal distance between the rays. Corollary 4.6 states that a small error in the *density matrix* $pp^{*}$ implies a proportionally small error in the state vector after phase alignment, with the explicit optimal factor $1/\sqrt2$; the ratio degrades from $1/2$ (nearby states) to $1/\sqrt2$ (orthogonal states) exactly as described by the identity $m(4-m) = D^2$. This is the rigorous version of the folklore claim that "global phase can always be fixed stably".

**Sampling and interpolation on the three-sphere.** Corollary 3.9 and Theorem 3.10 give the exact Lipschitz constant relating computations upstairs on $S^3$ to computations downstairs on $S^2$: refining a mesh on the base sphere to resolution $\varepsilon$ resolves fibres to $\varepsilon/\sqrt2$, and no better. This governs, for instance, the error of algorithms that lift spherical designs or quadrature rules through the Hopf map to rotation-group discretizations.

**Variational geometry.** The Clifford refutation is a caution about the phrase "the Clifford torus is extremal". Within the natural symmetry class the area functional is $4\pi^2 r\sqrt{1-r^2}$: unimodal, maximized at Clifford, with infimum zero. Any correct extremality theorem must therefore constrain the class (to minimal surfaces, or to a curvature-penalized energy such as the Willmore functional) — the constraint is not a technical convenience but the entire content.

**Low-dimensional topology.** Theorem 6.5 turns the linking-form half of the embedding problem for lens spaces into an integer square test. It is a complete answer for that half, and simultaneously a proof of its incompleteness as a standalone criterion (Proposition 6.8). The pattern — one obstruction sees only the order of the homology up to squares, while the complementary obstruction sees the group structure — is precisely the coupling that the embedding conjecture posits.

---

## 9. Discussion and future directions

Three of the five conjectures examined in this line of work are now settled in sharp form: the almost-Hopf-fibre stability conjecture (true, but with the wrong exponent), the Clifford-torus minimality conjecture (false; the truth is unique maximality), and the algebraic core of the three-manifold embedding obstruction (metabolicity $\iff$ square order). Each generates a well-posed successor problem.

### 9.1 From the circle quotient to Fubini–Study geometry

**Conjecture 9.1.** On the unit sphere of any complex inner product space, the phase-minimized distance $d_{\mathrm{ph}}(p,q) = \sqrt{2-2|\langle p,q\rangle|}$ — proved here to be a metric with sharp linear stability against the chordal projective distance — coincides with the quotient (Riemannian submersion) distance of $\mathbb{CP}^{n}$ under the Fubini–Study metric, up to the explicit chord/arc comparison $d_{\mathrm{ph}} = 2\sin(d_{FS}/2)$. Consequently the constant $1/\sqrt2$ proved in the $\mathbb{C}^2$ Hopf case is the optimal stability constant in every dimension, with extremal configurations exactly the orthogonal pairs.

The key insight is that both distances depend on the pair only through the single scalar $t = |\langle p,q\rangle|$, so the whole modulus is a one-variable algebraic identity, $m(4-m) = 2(2-2t^2)$, rather than a geometric estimate; what remains open is only the identification of the metric-space quotient with the Riemannian one. The dimension-free identity, the triangle inequality, the attainment of the minimum, and the vanishing-rigidity are all established here, so the remaining step is the comparison of a chordal metric with its geodesic completion — a self-contained analysis problem.

### 9.2 Constrained extremality replacing the false Clifford minimality claim

**Conjecture 9.2.** Within the Hopf-invariant family $T_r$ the area functional $4\pi^2 r\sqrt{1-r^2}$ has no interior minimizer, but the Willmore-type functional $W(r) = \int (1 + H^2)$ restricted to this family is uniquely minimized at $r = \sqrt2/2$; more generally, the Clifford torus minimizes area among Hopf-invariant tori that are additionally *minimal surfaces*, and that constraint singles out $r = \sqrt2/2$ as the unique critical point of the area functional.

The key insight is that in the symmetry-reduced picture the area becomes the single function $4\pi^2 r\sqrt{1-r^2}$, whose unique interior critical point is a maximum, so any correct extremality statement must be constrained: criticality, not minimality, is what the Clifford parameter satisfies. Since the reduced functional is available in closed form, its shape is fixed completely, and $r = \sqrt2/2$ is its only critical point, testing any candidate constrained functional is now a one-variable calculus exercise.

### 9.3 Beyond the cyclic case

**Conjecture 9.3.** For a finite abelian group $A$ with a nondegenerate symmetric linking form $\ell$, metabolicity is equivalent to the vanishing of the class of $(A,\ell)$ in the Witt group of linking forms; for $A$ cyclic this reduces exactly to the square-order criterion proved here, and for $A = \mathbb{Z}/p^{a_1}\oplus\cdots\oplus\mathbb{Z}/p^{a_k}$ it should reduce to a pairing-off condition on the multiset $\{a_i\}$ together with a Legendre-symbol condition on the diagonal coefficients.

The key insight is that the annihilator rule $H_d^\perp = H_{n/d}$ is a duality between complementary divisors; for a general $p$-group the analogous duality should pair the elementary divisors in inverse order, so metabolizers should correspond to perfect matchings of the elementary divisor multiset compatible with the quadratic residue data.

### 9.4 Coupling the two halves

**Conjecture 9.4.** For lens spaces the conjunction of the metabolicity criterion and the doubling criterion is *strictly weaker* than smooth embeddability: there exists $n = d^2$ with $H_1 = \mathbb{Z}/n$ of doubled form for which $L(n,q)$ nevertheless fails to embed, the failure being detected only by the intersection pairings of the complementary regions.

This is the precise falsifiable version of the assertion that the obstruction must be coupled. A counterexample would be a finite, explicitly parametrized object: a pair $(n,q)$ together with a computation of the two intersection forms.

### 9.5 Quantitative rigidity beyond the Hopf map

**Conjecture 9.5.** For the quaternionic Hopf fibration $S^7 \to S^4$, the analogous fibre distance $m$ and base distance $D$ satisfy the same identity $D^2 = m(4-m)$, with the same optimal constant $1/\sqrt2$ and the same near-diagonal ratio $1/4$.

The key insight is that the $\mathbb{C}^2$ computation used only the Cauchy–Schwarz defect of a Hermitian form; the quaternionic pairing has the same structure, and the corresponding "distance to the orbit of the unit quaternions" should again be $2 - 2|\langle p,q\rangle|$. A proof would establish that the entire quantitative theory is an artefact of division-algebra Cauchy–Schwarz rather than of any particular dimension.

---

## 10. Conclusion

We have settled three conjectures in four-dimensional geometry by the same device: find the symmetry, reduce to one variable, and read off the answer.

The exact identity $D^2 = m(4-m)$ makes the quantitative rigidity of Hopf fibres a triviality once stated, and simultaneously determines both optimal constants — the global constant $1/\sqrt2$ at antipodal images, the local constant $1/2$ near the diagonal — while ruling out any superlinear modulus. The identity is dimension-free, holding on the unit sphere of any complex inner product space, where the phase-minimized distance is a genuine metric on the projective quotient.

The area of a Hopf-invariant torus is $4\pi^2 r\sqrt{1-r^2}$, a unimodal function whose maximum is the Clifford torus and whose infimum is zero. Consequently the Clifford minimality conjecture is false as stated, and the correct unconstrained statement is unique maximality; criticality is the property that the Clifford parameter genuinely has.

The cyclic linking form $\ell_{n,q}$ is metabolic if and only if $n$ is a perfect square, uniformly in $q$. This settles the linking-form half of the conjectured embedding obstruction, yields the nonembedding of every lens space with non-square first homology, and — via the positive control at $n = 4$ — demonstrates that the linking form must indeed be coupled to the intersection pairings of the complementary regions, exactly as the conjecture proposes.
