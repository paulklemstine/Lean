# The Analytic Structure of the Moduli Space of Flat Tori

**A complete metric theory of Teichmüller space in genus one: extremal quasiconformal distortion, the mapping class group action, successive minima, and the length spectrum**

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We develop, from first principles, the metric geometry of the Teichmüller space and the moduli space of marked flat tori. Starting from the algebra of quasiconformal dilatations of real-linear maps of the plane, we prove that the dilatation is submultiplicative under composition — an exact consequence of the multiplicativity of the Jacobian determinant — and use this to construct the Teichmüller metric intrinsically, without transporting it from any other structure. We then prove the fundamental identification $d_T = \tfrac12 d_{\mathbb{H}}$: the Teichmüller metric of the once-marked torus is exactly one half of the Poincaré metric of curvature $-1$ on the upper half plane, equivalently the extremal dilatation between two marked tori is the exponential of their hyperbolic distance. This gives an entirely explicit model in which every subsequent question can be answered in closed form.

Within this model we establish: (i) the mapping class group $SL(2,\mathbb{Z})$ acts by isometries, with a proper discontinuity theorem in its sharpest form — for every $R$ only finitely many classes displace a point by at most $R$ — from which the moduli pseudometric is a genuine metric on the quotient and its defining infimum is attained; (ii) the orbifold structure of the quotient, with two cone points of orders three and two (the hexagonal and square tori) proved to be inequivalent, and one cusp, characterized quantitatively by a parabolic class whose displacement is everywhere positive but has infimum zero; (iii) an exact displacement identity for the Möbius action, from which the Teichmüller translation length of an Anosov class is $\log\lambda(g)$ with $\lambda$ the larger eigenvalue, and the complete determination of the length spectrum as $\{\operatorname{arcosh}(n/2) : n\in\mathbb{Z},\, n\ge 3\}$, discrete, unbounded, with least element $\log\frac{3+\sqrt5}{2}=2\log\varphi$; (iv) the systolic functional, Hermite's constant $\gamma_2 = 2/\sqrt3$ with the hexagonal torus as the unique extremizer, the two-sided comparison $|d_M(\rho,\tau) - \tfrac12\log(1/\operatorname{sys}\tau)| \le \tfrac12\log 5$, Mahler's compactness criterion and properness of the moduli space; and (v) Minkowski's second theorem in the sharp invariant form $1 \le \operatorname{sys}\cdot\operatorname{sys}_2 \le 4/3$, with a collar lemma, uniqueness of the shortest geodesic on the thin part, and the exact determination of both extremal loci.

**Keywords:** Teichmüller space, moduli space of tori, quasiconformal dilatation, mapping class group, systole, Hermite's constant, Minkowski's second theorem, length spectrum, Mahler compactness.

---

## 1. Introduction

Teichmüller theory studies the space of complex structures on a fixed topological surface. In genus one the whole theory becomes explicit, and this explicitness is not a degeneration but a laboratory: every deep phenomenon of the higher-genus theory — the extremal quasiconformal map, the Teichmüller metric, the orbifold structure of moduli space, the thick-thin decomposition, Bers' formula for pseudo-Anosov translation lengths, Mumford compactness — has a genus-one shadow that can be computed in closed form. The purpose of this paper is to develop that shadow completely and rigorously, in a way that never appeals to the general theory.

Our development is deliberately bottom-up. Section 2 treats the algebra of dilatations of real-linear maps of $\mathbb{C}$. Section 3 constructs the Teichmüller space and metric of the torus and proves the main identification with the hyperbolic metric. Section 4 introduces the mapping class group and the moduli pseudometric. Section 5 proves the displacement identity and determines the length spectrum. Section 6 develops the systolic functional, Hermite's constant, and the metric separation of the cone points. Section 7 proves proper discontinuity and upgrades the pseudometric to a metric. Section 8 gives the cusp exhaustion and Mahler compactness. Section 9 treats successive minima and Minkowski's second theorem. Section 10 discusses computational aspects and applications; Section 11 lists open problems.

Throughout, $\mathbb{H} = \{z \in \mathbb{C} : \operatorname{Im} z > 0\}$, with the hyperbolic metric of curvature $-1$, whose distance we denote $d_{\mathbb{H}}$ and which satisfies the standard formula
$$\cosh d_{\mathbb{H}}(z,w) = 1 + \frac{|z-w|^2}{2\operatorname{Im}z\operatorname{Im}w}.$$
We write $\rho = -\tfrac12 + \tfrac{\sqrt3}{2}i$ for the hexagonal point and $i$ for the square point.

---

## 2. The dilatation of a real-linear map

### 2.1 Normal form

Every $\mathbb{R}$-linear map $f : \mathbb{C}\to\mathbb{C}$ has a unique expression
$$f(z) = a z + b\bar z, \qquad a, b \in \mathbb{C},$$
with Jacobian determinant $J(f) = |a|^2 - |b|^2$. We restrict attention throughout to the orientation-preserving nonsingular maps, i.e. those with
$$|b| < |a|,$$
and denote this set by $\mathcal{L}$. The image of the unit circle under $f$ is an ellipse with semi-axes $|a|+|b|$ and $|a|-|b|$.

**Definition 2.1 (Dilatation and Beltrami coefficient).** For $f = (a,b) \in \mathcal{L}$ set
$$K(f) = \frac{|a|+|b|}{|a|-|b|}, \qquad \mu(f) = \frac{b}{a}.$$

**Proposition 2.2.** For $f \in \mathcal{L}$: $J(f) > 0$; $K(f) \ge 1$; $K(f) = 1$ if and only if $b=0$, in which case $f(z) = az$ is complex-linear (conformal); $|\mu(f)| < 1$; and
$$K(f) = \frac{1+|\mu(f)|}{1-|\mu(f)|}.$$

*Proof.* Positivity of $J$ and of $|a|\pm|b|$ is immediate from $0 \le |b| < |a|$. Then $K \ge 1 \iff |a|+|b| \ge |a|-|b| \iff |b| \ge 0$, with equality iff $|b|=0$. The Beltrami formula follows by dividing numerator and denominator by $|a| > 0$. $\square$

We record the reformulation that drives everything below.

**Lemma 2.3 (Determinant form).** For $f \in \mathcal{L}$,
$$K(f) = \frac{(|a|+|b|)^2}{J(f)}.$$

*Proof.* $J(f) = (|a|+|b|)(|a|-|b|)$. $\square$

### 2.2 Composition and the determinant identity

**Definition 2.4.** For $f = (a,b)$ and $g = (c,d)$ define $f \circ g = (A,B)$ with
$$A = ac + b\bar d, \qquad B = ad + b\bar c .$$

**Proposition 2.5.** This is the composite map: $(f\circ g)(z) = f(g(z))$ for all $z$, and $f\circ g \in \mathcal{L}$ whenever $f, g \in \mathcal{L}$.

*Proof.* $f(g(z)) = a(cz+d\bar z) + b\overline{(cz+d\bar z)} = (ac+b\bar d)z + (ad+b\bar c)\bar z$. Membership in $\mathcal{L}$ follows from Theorem 2.6 below, which gives $|A|^2-|B|^2 = J(f)J(g) > 0$. $\square$

**Theorem 2.6 (Multiplicativity of the Jacobian).** With the notation above,
$$|A|^2 - |B|^2 = \bigl(|a|^2-|b|^2\bigr)\bigl(|c|^2-|d|^2\bigr).$$

*Proof sketch.* Expand both sides in real and imaginary parts of $a,b,c,d$. Writing $|A|^2 = |ac|^2 + |b\bar d|^2 + 2\operatorname{Re}(ac\overline{b\bar d})$ and $|B|^2 = |ad|^2 + |b\bar c|^2 + 2\operatorname{Re}(ad\overline{b\bar c})$, one checks that the two cross terms coincide, $\operatorname{Re}(ac\bar b d) = \operatorname{Re}(ad\bar b c)$, and cancel; the remaining terms are exactly $|a|^2|c|^2 + |b|^2|d|^2 - |a|^2|d|^2 - |b|^2|c|^2 = (|a|^2-|b|^2)(|c|^2-|d|^2)$. $\square$

**Theorem 2.7 (Submultiplicativity).** For $f, g \in \mathcal{L}$,
$$K(f\circ g) \le K(f)\,K(g).$$

*Proof.* By the triangle inequality, $|A| \le |a||c| + |b||d|$ and $|B| \le |a||d| + |b||c|$, hence
$$|A| + |B| \le (|a|+|b|)(|c|+|d|).$$
By Lemma 2.3 and Theorem 2.6,
$$K(f\circ g) = \frac{(|A|+|B|)^2}{J(f)J(g)} \le \frac{(|a|+|b|)^2(|c|+|d|)^2}{J(f)J(g)} = K(f)K(g). \qquad \square$$

**Remark 2.8.** The naive route fails: bounding the minor axis from below by the triangle inequality gives only
$$|A| - |B| \ \ge\ (|a|-|b|)(|c|-|d|) - 2|b||d|,$$
which loses exactly the term $2|b||d|$ and is too weak to give submultiplicativity. The repair is to bound the *product* $(|A|-|B|)(|A|+|B|)$ exactly, which is Theorem 2.6; the desired minor-axis inequality $|A|-|B|\ge(|a|-|b|)(|c|-|d|)$ is then a consequence rather than an input. Submultiplicativity is therefore an algebraic identity in disguise, not an analytic estimate.

**Proposition 2.9 (Inverse).** For $f=(a,b) \in \mathcal{L}$ the inverse map is $f^{-1} = (\bar a / J(f),\ -b/J(f)) \in \mathcal{L}$, and
$$K(f^{-1}) = K(f).$$
Moreover every $f\in\mathcal{L}$ is injective.

*Proof.* A direct computation gives $f(f^{-1}(z)) = z$ using $J(f) = a\bar a - b\bar b$. Since $\|\bar a/J\| = |a|/J$ and $\|-b/J\| = |b|/J$, both numerator and denominator of $K$ are divided by $J$ and the quotient is unchanged. Injectivity: if $f(z)=0$ with $z \ne 0$ then $|a||z| = |b||z|$, contradicting $|b|<|a|$. $\square$

---

## 3. Teichmüller space of the torus and the main identification

### 3.1 Marked tori

A **marked flat torus** is the quotient $\mathbb{C}/\Lambda_\tau$, $\Lambda_\tau = \mathbb{Z}+\mathbb{Z}\tau$, $\tau \in \mathbb{H}$, together with the ordered basis $(1,\tau)$ of $\Lambda_\tau$. Two marked tori $\tau, \tau'$ are compared through the maps of the plane carrying the marking of the first to the marking of the second, i.e. maps with $1\mapsto 1$ and $\tau \mapsto \tau'$.

**Theorem 3.1 (Existence, uniqueness and extremality of the affine map).** There is exactly one $f \in \mathcal{L}$ with $f(1)=1$ and $f(\tau)=\tau'$, namely
$$\mathrm{aff}(\tau,\tau') = \left(\frac{\tau'-\bar\tau}{\tau-\bar\tau},\ \frac{\tau-\tau'}{\tau-\bar\tau}\right).$$
Consequently it is the extremal (minimal-dilatation) marked map. Its dilatation is
$$K(\tau,\tau') = \frac{\bigl(|\tau'-\bar\tau| + |\tau'-\tau|\bigr)^2}{4\operatorname{Im}\tau\operatorname{Im}\tau'}.$$

*Proof sketch.* Admissibility ($|b|<|a|$) is the reflection inequality $|\tau'-\tau| < |\tau'-\bar\tau|$, which follows from Lemma 3.2 below. The two marking conditions are two complex-linear equations in $(a,b)$: $a+b=1$ and $a\tau + b\bar\tau = \tau'$, whose determinant is $\bar\tau - \tau \ne 0$; solving gives the stated $(a,b)$. Uniqueness makes extremality automatic. For the dilatation, note $|\tau - \bar\tau| = 2\operatorname{Im}\tau$, so $|a| = |\tau'-\bar\tau|/(2\operatorname{Im}\tau)$ and $|b| = |\tau'-\tau|/(2\operatorname{Im}\tau)$; Lemma 3.2 gives $J = \operatorname{Im}\tau'/\operatorname{Im}\tau$, and Lemma 2.3 finishes. $\square$

**Lemma 3.2 (Reflection identity).** For $\tau,\tau' \in \mathbb{H}$,
$$|\tau'-\bar\tau|^2 = |\tau'-\tau|^2 + 4\operatorname{Im}\tau\operatorname{Im}\tau' .$$
In particular $|\tau'-\tau| < |\tau'-\bar\tau|$.

*Proof.* Expand in real and imaginary parts: with $\tau = x+iy$, $\tau'=x'+iy'$, both sides equal $(x'-x)^2 + (y'+y)^2$ and $(x'-x)^2+(y'-y)^2 + 4yy'$ respectively. $\square$

**Proposition 3.3 (Groupoid property).** $\mathrm{aff}(\tau',\tau'')\circ\mathrm{aff}(\tau,\tau') = \mathrm{aff}(\tau,\tau'')$ and $\mathrm{aff}(\tau,\tau')^{-1} = \mathrm{aff}(\tau',\tau)$.

*Proof.* Both composites are marked maps from $\tau$ to $\tau''$ (resp. $\tau'$ to $\tau$), hence equal the affine one by uniqueness. $\square$

### 3.2 The Teichmüller metric

**Definition 3.4.** The Teichmüller distance on $\mathbb{H}$ is
$$d_T(\tau,\tau') = \tfrac12 \log K(\tau,\tau').$$

**Theorem 3.5.** $d_T$ is a metric on $\mathbb{H}$. Explicitly: $d_T \ge 0$; $d_T(\tau,\tau')=0 \iff \tau=\tau'$; $d_T(\tau,\tau')=d_T(\tau',\tau)$; and $d_T(\tau,\tau'') \le d_T(\tau,\tau') + d_T(\tau',\tau'')$.

*Proof.* Nonnegativity is $K \ge 1$. Vanishing forces $K=1$, i.e. $b=0$ in the affine map, i.e. $\tau=\tau'$ (Proposition 2.2 and Theorem 3.1). Symmetry is $K(f^{-1})=K(f)$ (Proposition 2.9) together with Proposition 3.3. The triangle inequality is submultiplicativity (Theorem 2.7) plus Proposition 3.3, after taking logarithms. $\square$

We stress that this is an *intrinsic* construction: the metric axioms are consequences of the quasiconformal calculus of Section 2, not of the theorem that follows.

**Theorem 3.6 (Main identification).** For all $\tau,\tau'\in\mathbb{H}$,
$$d_T(\tau,\tau') = \tfrac12\, d_{\mathbb{H}}(\tau,\tau'), \qquad\text{equivalently}\qquad K(\tau,\tau') = e^{\,d_{\mathbb{H}}(\tau,\tau')}.$$

*Proof.* Put $p = |\tau'-\bar\tau|$, $q = |\tau'-\tau|$, $y = \operatorname{Im}\tau$, $y'=\operatorname{Im}\tau'$, so that $0\le q<p$ and $p^2 = q^2 + 4yy'$ (Lemma 3.2), and $K = (p+q)^2/(4yy')$. Then
$$\cosh\bigl(2 d_T\bigr) = \cosh(\log K) = \frac{K + K^{-1}}{2} = \frac{(p+q)^4 + (4yy')^2}{2(p+q)^2\cdot 4yy'}.$$
Since $4yy' = p^2-q^2 = (p+q)(p-q)$, this simplifies to
$$\frac{(p+q)^2 + (p-q)^2}{2(p+q)(p-q)} = \frac{p^2+q^2}{p^2-q^2} = 1 + \frac{2q^2}{4yy'} = 1 + \frac{q^2}{2yy'} = \cosh d_{\mathbb{H}}(\tau,\tau').$$
As $\cosh$ is injective on $[0,\infty)$ and both $2d_T$ and $d_{\mathbb{H}}$ are nonnegative, $2d_T = d_{\mathbb{H}}$. $\square$

**Remark 3.7.** The constant $\tfrac12$ is forced: rescaling would break $K=1 \iff \tau=\tau'$. It says the Teichmüller metric of the once-marked torus is a hyperbolic metric of curvature $-4$.

### 3.3 Geodesics: the stretch line

**Definition 3.8.** The **stretch line** through the square torus is $\sigma_t = i e^{2t}$, $t\in\mathbb{R}$, i.e. the torus $\mathbb{C}/\langle 1, ie^{2t}\rangle$.

**Theorem 3.9.** $d_T(\sigma_s,\sigma_t) = |t-s|$; for $r\le s\le t$, $d_T(\sigma_r,\sigma_t) = d_T(\sigma_r,\sigma_s)+d_T(\sigma_s,\sigma_t)$; and the extremal dilatation along the line is $K(\sigma_s,\sigma_t) = e^{2|t-s|}$. In particular the Teichmüller space of the torus has infinite diameter.

*Proof.* For points with equal real part, $d_{\mathbb{H}}(iy, iy') = |\log y - \log y'|$; with $y = e^{2s}$, $y'=e^{2t}$ this is $2|t-s|$, and Theorem 3.6 halves it. Additivity is then the triangle equality for absolute values of an ordered triple, and $K = e^{d_{\mathbb{H}}}$ gives the dilatation. $\square$

Thus $\sigma$ is a unit-speed geodesic and distortion grows exponentially in Teichmüller distance — the structural reason the metric is a logarithm.

---

## 4. The mapping class group and the moduli pseudometric

Changing the marking of a torus means changing the ordered basis of the lattice by an element of $SL(2,\mathbb{Z})$; on the parameter $\tau$ this is the Möbius action
$$g\cdot\tau = \frac{a\tau+b}{c\tau+d}, \qquad g = \begin{pmatrix}a&b\\c&d\end{pmatrix}\in SL(2,\mathbb{Z}).$$

**Theorem 4.1.** $SL(2,\mathbb{Z})$ acts on $\mathbb{H}$ by isometries of $d_T$: $d_T(g\cdot\tau, g\cdot\tau') = d_T(\tau,\tau')$.

*Proof.* The action is the restriction of the $SL(2,\mathbb{R})$-action, which is by hyperbolic isometries; apply Theorem 3.6. $\square$

**Definition 4.2 (Moduli distance).** $\displaystyle d_M(\tau,\tau') = \inf_{g\in SL(2,\mathbb{Z})} d_T(\tau, g\cdot\tau')$.

**Theorem 4.3.** $d_M$ is a symmetric, $SL(2,\mathbb{Z})$-invariant pseudometric on $\mathbb{H}$ with $d_M \le d_T$, and $d_M(\tau, h\cdot\tau)=0$ for all $h$. It is *not* a metric on $\mathbb{H}$: e.g. $i$ and $i+1$ are distinct with $d_M = 0$.

*Proof sketch.* Boundedness below by $0$ makes the infimum well defined. Invariance on either side is a reindexing of the group (by $g\mapsto gh$ and $g\mapsto h^{-1}g$ respectively), using Theorem 4.1 for the left-hand case. Symmetry uses $d_T(\tau,g\cdot\tau') = d_T(\tau', g^{-1}\cdot\tau)$ and reindexing by $g\mapsto g^{-1}$. For the triangle inequality, for any $g,h$,
$$d_M(\tau,\tau'') \le d_T(\tau, (gh)\cdot\tau'') \le d_T(\tau,g\cdot\tau') + d_T(g\cdot\tau', (gh)\cdot\tau'') = d_T(\tau,g\cdot\tau') + d_T(\tau', h\cdot\tau''),$$
and taking infima over $h$ then $g$ concludes. $\square$

### 4.1 The orbifold points

**Theorem 4.4 (Two cone points).**
1. $S = \left(\begin{smallmatrix}0&-1\\1&0\end{smallmatrix}\right)$ fixes $i$, and $S \ne \pm 1$; hence the action is not free.
2. Every $g\in SL(2,\mathbb{Z})$ fixing $i$ satisfies $g^2 = \pm 1$: the stabilizer of $i$ has order $2$ in $PSL(2,\mathbb{Z})$.
3. $ST = \left(\begin{smallmatrix}0&-1\\1&1\end{smallmatrix}\right)$ fixes $\rho$, with $(ST)^3=-1$ and $ST, (ST)^2 \notin\{\pm1\}$: the stabilizer of $\rho$ has order $3$ in $PSL(2,\mathbb{Z})$.
4. Consequently $g\cdot\rho \ne i$ for every $g$: the two points lie in different orbits, and the moduli space carries at least two distinct orbifold singularities, of cone angles $\pi$ and $2\pi/3$.

*Proof sketch.* (1) and (3) are direct computations ($S\cdot i = -1/i = i$; $\rho$ satisfies $\rho^2+\rho+1=0$, so $-1/(\rho+1) = \rho$). (2) The equation $(ai+b)/(ci+d) = i$ gives $a = d$ and $b = -c$; then $\det g = a^2+c^2 = 1$, whose only integral solutions are $(\pm1,0),(0,\pm1)$, and in each case $g^2 = \pm 1$. (4) If $g\cdot\rho = i$ then $gSTg^{-1}$ fixes $i$, so by (2) its square is $\pm1$, whence $(ST)^2 = \pm 1$, contradicting (3) (compare the $(0,1)$ entry, which equals $-1$). $\square$

### 4.2 The cusp

**Theorem 4.5.** For the parabolic class $T:\tau\mapsto\tau+1$,
$$\cosh d_{\mathbb{H}}(\tau, T\cdot\tau) = 1 + \frac{1}{2(\operatorname{Im}\tau)^2}.$$
Hence $d_T(\tau,T\cdot\tau) > 0$ for every $\tau$, but for every $\varepsilon>0$ there is $\tau$ with $d_T(\tau,T\cdot\tau)<\varepsilon$: the translation length of $T$ is $0$ and is not attained.

*Proof.* The displacement formula is Theorem 5.1 with $(a,b,c,d)=(1,1,0,1)$. Positivity: $\cosh > 1$. For the infimum, take $\tau = iy$ with $y$ large. $\square$

This is the quantitative source of noncompactness: the moduli space has a cusp.

---

## 5. Displacement, translation lengths, and the length spectrum

### 5.1 The displacement identity

**Theorem 5.1 (Displacement identity).** Let $g = \left(\begin{smallmatrix}a&b\\c&d\end{smallmatrix}\right)$ have determinant $1$ (real entries) and $z = x+iy\in\mathbb{H}$. Then
$$\cosh d_{\mathbb{H}}(z, g\cdot z) \;=\; \frac{(a+d)^2-2}{2} \;+\; \frac{\bigl(c(x^2+y^2)-(a-d)x-b\bigr)^2}{2y^2}.$$

*Proof sketch.* Write $P(z) = cz^2 - (a-d)z - b$, the numerator of $g\cdot z - z$ after clearing $cz+d$. The standard formula for $\cosh d_{\mathbb{H}}$, together with $\operatorname{Im}(g\cdot z) = y/|cz+d|^2$, gives
$$\cosh d_{\mathbb{H}}(z,g\cdot z) = 1 + \frac{|P(z)|^2}{2y^2}.$$
The polynomial identity
$$|P(z)|^2 - y^2\bigl((a+d)^2-4\bigr) = \bigl(c(x^2+y^2)-(a-d)x-b\bigr)^2$$
holds modulo $ad-bc=1$ (expand; the difference is $-4y^2(ad-bc-1)$). Substituting gives the claim. $\square$

Everything about the isometry $g$ is now visible. The second term is a square over a positive number: it vanishes exactly on the *axis*
$$c(x^2+y^2)-(a-d)x - b = 0,$$
which is a nonempty subset of $\mathbb{H}$ precisely when $|{\rm tr}\,g| = |a+d| > 2$. Thus:

**Corollary 5.2 (Trichotomy).** $\inf_z d_{\mathbb{H}}(z,g\cdot z)$ is: $0$ and attained (a fixed point) if $|{\rm tr}\,g|<2$; $0$ and not attained if $|{\rm tr}\,g|=2$, $g\ne\pm1$; positive and attained if $|{\rm tr}\,g|>2$.

### 5.2 Translation length of an Anosov class

**Definition 5.3.** For $|{\rm tr}\,g|>2$, the **stretch factor** is the larger eigenvalue in absolute value,
$$\lambda(g) = \frac{|{\rm tr}\,g| + \sqrt{({\rm tr}\,g)^2-4}}{2} > 1, \qquad \lambda + \lambda^{-1} = |{\rm tr}\,g| .$$

**Theorem 5.4 (Bers' formula in genus one).** Let $g\in SL(2,\mathbb{Z})$ with $|{\rm tr}\,g|>2$ (an Anosov class). Then
$$\min_{\tau\in\mathbb{H}} d_T(\tau, g\cdot\tau) \quad\text{exists and equals}\quad \log\lambda(g).$$

*Proof.* By Theorem 5.1 the minimum of $\cosh d_{\mathbb{H}}(\cdot, g\cdot)$ is $\bigl(({\rm tr}\,g)^2-2\bigr)/2$, attained on the (nonempty) axis, so $\min_\tau d_{\mathbb{H}}(\tau,g\cdot\tau) = \operatorname{arcosh}\frac{({\rm tr}\,g)^2-2}{2}$. From $\lambda+\lambda^{-1}=|{\rm tr}\,g|$ one gets $\cosh(2\log\lambda) = \frac{\lambda^2+\lambda^{-2}}{2} = \frac{({\rm tr}\,g)^2-2}{2}$, so the hyperbolic translation length is $2\log\lambda$. Halving (Theorem 3.6) gives $\log\lambda$. $\square$

**Example 5.5 (Arnold's cat map).** For $g = \left(\begin{smallmatrix}2&1\\1&1\end{smallmatrix}\right)$, ${\rm tr}=3$ and $\lambda = \frac{3+\sqrt5}{2} = \varphi^2$ with $\varphi$ the golden ratio; the Teichmüller translation length is $\log\frac{3+\sqrt5}{2} = 2\log\varphi \approx 0.962424$.

**Theorem 5.6 (Spectral gap).** Every Anosov class of the torus satisfies $\lambda(g)\ge\frac{3+\sqrt5}{2}$ and hence
$$d_T(\tau,g\cdot\tau) \ \ge\ 2\log\varphi \qquad \text{for all } \tau .$$

*Proof.* ${\rm tr}\,g$ is an integer of absolute value $>2$, hence $\ge 3$; $\lambda$ is increasing in $|{\rm tr}|$. $\square$

### 5.3 The length spectrum

**Definition 5.7.** For $n\in\mathbb{Z}$, $n\ge3$, put
$$\ell(n) = \log\frac{n+\sqrt{n^2-4}}{2} = \operatorname{arcosh}(n/2).$$
The **Teichmüller length spectrum** of the torus is $\mathcal{S} = \{\,\log\lambda(g) : g \in SL(2,\mathbb{Z}),\ |{\rm tr}\,g|>2\,\}$.

**Theorem 5.8 (Complete determination of the spectrum).**
1. *(Realization)* For every integer $n\ge3$, the class $A_n = \left(\begin{smallmatrix}n&-1\\1&0\end{smallmatrix}\right)$ lies in $SL(2,\mathbb{Z})$ with trace $n$, and its Teichmüller translation length is exactly $\ell(n)$.
2. *(Exactness)* $\mathcal{S} = \{\ell(n) : n\in\mathbb{Z},\ n\ge3\}$.
3. *(Monotonicity)* $n\mapsto\ell(n)$ is strictly increasing on $\{n\ge3\}$, so $\mathcal S$ is order-isomorphic to $\mathbb{Z}\cap[3,\infty)$.
4. *(Discreteness)* If $\log\lambda(g)\le M$ then $|{\rm tr}\,g| \le 2e^M$; consequently $\mathcal{S}\cap(-\infty,M]$ is finite for every $M$.
5. *(Unboundedness)* $\mathcal S$ is unbounded above.
6. *(Bottom)* $\min\mathcal S = \ell(3) = \log\frac{3+\sqrt5}{2} = 2\log\varphi$, realized by the cat map.

*Proof sketch.* (1) $\det A_n = 0\cdot n - (-1)\cdot 1 = 1$ and ${\rm tr}\,A_n = n \ge 3 > 2$; apply Theorem 5.4. (2) "$\supseteq$" is (1); "$\subseteq$" holds because $\lambda(g)$ depends on $g$ only through $|{\rm tr}\,g|$, which is an integer $\ge3$. (3) Both $n$ and $\sqrt{n^2-4}$ are strictly increasing, and $\log$ is. (4) From $\lambda+\lambda^{-1}=|{\rm tr}|$ and $1<\lambda\le e^M$ we get $\lambda^{-1}\le 1$, hence $|{\rm tr}|\le e^M+1\le 2e^M$; combined with (2)–(3) this confines the parameter $n$ to the finite range $3\le n\le\lceil 2e^M\rceil$. (5) $\ell(n)\to\infty$. (6) Immediate from (2)–(3). $\square$

**Corollary 5.9 (Counting function).** $\#\{\ell\in\mathcal S : \ell \le L\} = \lfloor 2\cosh L\rfloor - 2$ for $L \ge \ell(3)$, which is asymptotic to $e^L$.

*Proof.* $\ell(n)\le L \iff n \le 2\cosh L$, and $n$ ranges over integers $\ge 3$. $\square$

The metric invariant on the left of Theorem 5.4 is thus computed by a purely arithmetic invariant: the trace of an integer matrix. This is the genus-one instance of the general principle that the pseudo-Anosov length spectrum of a moduli space is discrete with exponential counting function.

---

## 6. The systolic functional and Hermite's constant

### 6.1 Definition and attainment

The flat torus $\mathbb{C}/\Lambda_\tau$ has area $\operatorname{Im}\tau$ and closed geodesics of lengths $|m+n\tau|$, $(m,n)\in\mathbb{Z}^2\setminus\{0\}$. The scale-invariant combination is:

**Definition 6.1.** For $\tau\in\mathbb{H}$ and $(m,n)\ne(0,0)$ set $Q_{m,n}(\tau) = \dfrac{|m+n\tau|^2}{\operatorname{Im}\tau}$, and
$$\operatorname{sys}(\tau) \;=\; \min_{(m,n)\ne(0,0)} Q_{m,n}(\tau).$$

**Theorem 6.2 (Attainment and positivity).** The infimum is attained at some nonzero $(m,n)$, and $0<\operatorname{sys}(\tau)$.

*Proof.* Each $Q_{m,n}(\tau)>0$ for $(m,n)\ne 0$, since $m+n\tau=0$ with $\tau\notin\mathbb{R}$ forces $m=n=0$. The candidate value $Q_{1,0}=1/\operatorname{Im}\tau$ bounds the infimum above, and by properness of the positive definite quadratic form $|m+n\tau|^2$ on $\mathbb{Z}^2$ only finitely many $(m,n)$ satisfy $Q_{m,n}\le Q_{1,0}$. A minimum over a finite nonempty set is attained. $\square$

**Theorem 6.3 (Invariance).** For $g\in SL(2,\mathbb{Z})$, the family $\{Q_{m,n}\}$ is permuted by $g$: precisely, $Q_{m,n}(g\cdot\tau) = Q_{m',n'}(\tau)$ where $(m',n') = (md+nb,\, mc+na)$, a substitution of determinant $1$. Hence $\operatorname{sys}(g\cdot\tau)=\operatorname{sys}(\tau)$, and $\operatorname{sys}$ is a function on the moduli space.

*Proof sketch.* Substituting $g\cdot\tau = (a\tau+b)/(c\tau+d)$ and using $\operatorname{Im}(g\cdot\tau) = \operatorname{Im}\tau/|c\tau+d|^2$ gives $|m + n\,g\cdot\tau|^2 = |m(c\tau+d) + n(a\tau+b)|^2/|c\tau+d|^2$, and the two factors $|c\tau+d|^{2}$ cancel; the numerator is $|(md+nb)+(mc+na)\tau|^2$. The substitution is invertible over $\mathbb{Z}$ (its matrix has determinant $ad-bc=1$), so it permutes nonzero index vectors. $\square$

### 6.2 Hermite's constant

**Theorem 6.4 (Sharp systolic bound).** For every $\tau\in\mathbb{H}$,
$$\operatorname{sys}(\tau)\ \le\ \frac{2}{\sqrt3},$$
and this is attained: $\operatorname{sys}(\rho)=2/\sqrt3$, while $\operatorname{sys}(i)=1$. Hence Hermite's constant in dimension two is exactly $\gamma_2 = 2/\sqrt3$, with the hexagonal torus extremal.

*Proof sketch.* *Upper bound.* Move $\tau$ into the standard fundamental domain $\mathcal{D} = \{|{\rm Re}\,w|\le\tfrac12,\ |w|\ge1\}$ by some $g$; there $\operatorname{Im}(g\cdot\tau)\ge\sqrt3/2$, so $Q_{1,0}(g\cdot\tau) = 1/\operatorname{Im}(g\cdot\tau)\le 2/\sqrt3$; transport back with Theorem 6.3 (the extremal index vector becomes $(d,c)$).
*Sharpness.* For the hexagonal lattice one computes $|m+n\rho|^2 = m^2-mn+n^2$, an integer which is positive for $(m,n)\ne 0$, hence $\ge 1$; dividing by $\operatorname{Im}\rho = \sqrt3/2$ gives $Q_{m,n}(\rho)\ge 2/\sqrt3$, with equality at $(1,0)$. For the square torus $|m+ni|^2 = m^2+n^2 \ge 1$ and $\operatorname{Im} i = 1$. $\square$

**Proposition 6.5 (Systole on the fundamental domain).** If $|{\rm Re}\,w|\le\tfrac12$ and $|w|\ge1$ then
$$\operatorname{sys}(w) = \frac{1}{\operatorname{Im}w}.$$

*Proof.* For such $w$, $|m+nw|^2 = m^2 + 2mn\,{\rm Re}\,w + n^2|w|^2 \ge m^2-|mn|+n^2$, a positive integer for $(m,n)\ne0$, hence $\ge1$; and $(1,0)$ achieves $1$. $\square$

### 6.3 The systole as a Lipschitz invariant, and separation of the cone points

**Theorem 6.6 (Log-Lipschitz property).** For all $z,w\in\mathbb{H}$ and any fixed $(m,n)$,
$$\Bigl|\log Q_{m,n}(z) - \log Q_{m,n}(w)\Bigr| \le d_{\mathbb{H}}(z,w),$$
and consequently
$$\bigl|\log\operatorname{sys}(z)-\log\operatorname{sys}(w)\bigr| \le d_{\mathbb{H}}(z,w) = 2\,d_T(z,w), \qquad \log\frac{\operatorname{sys}z}{\operatorname{sys}w}\le 2\,d_M(z,w).$$

*Proof sketch.* Put $u = m+nz$, $v = m+nw$ and $\zeta = u\,\bar v\,\overline{(z-w)}$ — more precisely, the identity to use is
$$\operatorname{Im}\bigl((m+nz)\overline{(m+nw)}\,\overline{(z-w)}\bigr) \cdot(\text{normalization}) = |m+nz|^2\operatorname{Im}w - |m+nw|^2\operatorname{Im}z ,$$
so that the desired inequality $\bigl(Q(z)/Q(w)+Q(w)/Q(z)\bigr)/2 \le \cosh d_{\mathbb{H}}(z,w)$ becomes exactly $(\operatorname{Im}\zeta)^2\le|\zeta|^2$. Since $\cosh$ of the left-hand side is $\cosh\log(Q(z)/Q(w))$, taking $\operatorname{arcosh}$ gives the Lipschitz bound. For $\operatorname{sys}$, apply this to the index vector realizing the minimum at one of the two points; for the moduli statement, apply it to $z$ and $g\cdot w$ and use invariance (Theorem 6.3), then take the infimum over $g$. $\square$

**Theorem 6.7 (Metric separation of the cone points).** If every nonzero lattice vector of $z$ satisfies $Q\ge r$ while some nonzero lattice vector of $w$ satisfies $Q\le s$ with $0<s\le r$, then
$$d_M(z,w) \ \ge\ \tfrac12\log(r/s).$$
In particular
$$d_M(\rho, i) \ \ge\ \tfrac12\log\frac{2}{\sqrt3} \ \approx\ 0.0719 \ >\ 0 .$$

*Proof.* For each $g$, the index vector realizing $Q\le s$ at $w$ transports (Theorem 6.3) to an index vector at $g\cdot w$ with the same value; comparing with the lower bound $r$ at $z$ and applying Theorem 6.6 gives $d_{\mathbb{H}}(z,g\cdot w)\ge\log(r/s)$, uniformly in $g$. Halving and taking the infimum gives the claim. Insert $r = \operatorname{sys}\rho = 2/\sqrt3$ and $s = \operatorname{sys}i = 1$. $\square$

This is a *quantitative* separation of two orbits, obtained with no compactness, no properness, and no attainment of the infimum defining $d_M$.

---

## 7. Proper discontinuity and the metric on moduli space

**Theorem 7.1 (Proper discontinuity, sharp form).** For all $z,w\in\mathbb{H}$ and $R\in\mathbb{R}$, the set
$$\{g\in SL(2,\mathbb{Z}) : d_{\mathbb{H}}(z, g\cdot w)\le R\}$$
is finite.

*Proof sketch.* For $g = \left(\begin{smallmatrix}a&b\\c&d\end{smallmatrix}\right)$ we have $|cw+d|^2 = \operatorname{Im}w/\operatorname{Im}(g\cdot w)$ and $|aw+b|^2 = |g\cdot w|^2\,|cw+d|^2$. A bound $d_{\mathbb{H}}(z,g\cdot w)\le R$ forces $g\cdot w$ into a compact subset of $\mathbb{H}$, so it bounds $\operatorname{Im}(g\cdot w)$ from below and $|g\cdot w|$ from above; both displayed quantities are therefore bounded by explicit constants. Since the positive definite integral form $(c,d)\mapsto|cw+d|^2$ takes any bounded value only finitely often, and likewise for $(a,b)$, only finitely many matrices remain. $\square$

**Corollary 7.2.** (i) Every stabilizer $\{g : g\cdot z = z\}$ is finite — the local groups of the orbifold points are finite (of orders $2$ and $3$ projectively). (ii) For all $z,w$ the infimum defining $d_M$ is attained: there exists $g_0$ with $d_M(z,w) = d_T(z, g_0\cdot w)$.

*Proof.* (i) is the case $R=0$. (ii) The infimum may be computed over the finite set of $g$ with $d_T(z,g\cdot w)\le d_T(z,w)$, which is nonempty (it contains $1$). $\square$

**Theorem 7.3 (The moduli pseudometric is a metric on the quotient).**
$$d_M(z,w) = 0 \iff \exists\, g\in SL(2,\mathbb{Z}),\ g\cdot w = z .$$
Consequently $d_M$ descends to a genuine metric on the moduli space $\mathbb{H}/SL(2,\mathbb{Z})$, and distinct points of the moduli space are at positive distance. In particular $d_M(\rho,i)>0$, re-deriving Theorem 6.7 softly.

*Proof.* ($\Leftarrow$) is invariance (Theorem 4.3). ($\Rightarrow$) By Corollary 7.2(ii) the infimum is attained at some $g_0$, so $d_T(z,g_0\cdot w) = 0$, whence $g_0\cdot w = z$ by Theorem 3.5. $\square$

Note that attainment is genuinely needed: an infimum of strictly positive numbers over an infinite set can be $0$ — as Theorem 4.5 shows for the displacement of a parabolic.

---

## 8. Cusp exhaustion and Mahler compactness

### 8.1 Two-sided comparison with the distance to the hexagonal point

**Theorem 8.1 (Upper bound on the fundamental domain).** If $|{\rm Re}\,w|\le\tfrac12$ and $|w|\ge1$, then $d_{\mathbb{H}}(\rho,w)\le\log(5\operatorname{Im}w)$.

*Proof sketch.* With $w = x+iy$, $y\ge\sqrt3/2$,
$$\cosh d_{\mathbb{H}}(\rho,w) = 1 + \frac{(x+\tfrac12)^2 + (y-\tfrac{\sqrt3}{2})^2}{\sqrt3\,y} \le \tfrac52 y ,$$
and $e^{t}\le 2\cosh t$ converts this into $d_{\mathbb{H}}(\rho,w)\le\log(5y)$. $\square$

**Theorem 8.2 (Exhaustion comparison).** For every $\tau\in\mathbb{H}$,
$$\tfrac12\log\frac{1}{\operatorname{sys}\tau} \ \le\ d_M(\rho,\tau) \ \le\ \tfrac12\log\frac{5}{\operatorname{sys}\tau},$$
equivalently
$$\Bigl|\,d_M(\rho,\tau) - \tfrac12\log\frac{1}{\operatorname{sys}\tau}\,\Bigr| \ \le\ \tfrac12\log 5 .$$

*Proof.* The lower bound is Theorem 6.6 applied with $z=\rho$, using $\operatorname{sys}\rho = 2/\sqrt3 > 1$. For the upper bound, move $\tau$ into the fundamental domain by $g$; by Proposition 6.5, $\operatorname{sys}(g\cdot\tau) = 1/\operatorname{Im}(g\cdot\tau)$, and by Theorem 8.1, $d_M(\rho,\tau)\le d_T(\rho,g\cdot\tau) = \tfrac12 d_{\mathbb{H}}(\rho,g\cdot\tau)\le\tfrac12\log(5\operatorname{Im}(g\cdot\tau)) = \tfrac12\log(5/\operatorname{sys}\tau)$, using invariance of $\operatorname{sys}$. $\square$

So the multiplicative constant relating the distance to the thick part and the logarithmic systole is exactly $1$; the error is the universal additive constant $\tfrac12\log5\approx0.805$.

**Corollary 8.3 (Properness of the exhaustion).** For every $R$ there is $\varepsilon>0$ such that $d_M(\rho,\tau)\le R \Rightarrow \operatorname{sys}\tau\ge\varepsilon$, and for every $\varepsilon>0$ there is $R$ such that $\operatorname{sys}\tau\ge\varepsilon \Rightarrow d_M(\rho,\tau)\le R$. Also $\operatorname{sys}$ takes arbitrarily small positive values (take $\tau=iY$, $Y\to\infty$), so the moduli space has infinite diameter.

### 8.2 Continuity and compactness

**Theorem 8.4 (Continuity).** $\log\operatorname{sys}$ is $1$-Lipschitz for $d_{\mathbb{H}}$ (equivalently $2$-Lipschitz for $d_T$); in particular $\operatorname{sys}$ is continuous on $\mathbb{H}$.

*Proof.* Symmetrize Theorem 6.6. $\square$

Continuity is not formal: $\operatorname{sys}$ is defined as an infimum over the infinite set $\mathbb{Z}^2\setminus\{0\}$ of functions, and it is the *metric* estimate, not lattice combinatorics, that supplies it.

**Theorem 8.5 (Mahler's compactness criterion for rank-two lattices).** For every $\varepsilon>0$ there is a compact $K\subset\mathbb{H}$ such that $\operatorname{sys}(w)\ge\varepsilon$ for all $w\in K$ and every $\tau$ with $\operatorname{sys}\tau\ge\varepsilon$ has a translate $g\cdot\tau\in K$. Explicitly one may take the thick part of the fundamental domain,
$$K_\varepsilon = \Bigl\{w : |{\rm Re}\,w|\le\tfrac12,\ |w|\ge1,\ \operatorname{sys}w\ge\varepsilon\Bigr\} = \Bigl\{w: |{\rm Re}\,w|\le\tfrac12,\ |w|\ge1,\ \operatorname{Im}w\le 1/\varepsilon\Bigr\}.$$

*Proof.* By Proposition 6.5, on the fundamental domain the condition $\operatorname{sys}\ge\varepsilon$ is $\operatorname{Im}w\le1/\varepsilon$, so $K_\varepsilon$ is a closed bounded subset of $\mathbb{H}$ contained in the box $|{\rm Re}\,w|\le\frac12$, $\frac{\sqrt3}{2}\le\operatorname{Im}w\le\frac1\varepsilon$, hence compact (closedness uses continuity, Theorem 8.4). Every $\tau$ has a translate in the fundamental domain, and $\operatorname{sys}$ is invariant. Non-vacuity: $\rho\in K_\varepsilon$ whenever $\varepsilon\le2/\sqrt3$. $\square$

**Corollary 8.6 (Properness of the moduli space).** $\tau\mapsto d_M(\rho,\tau)$ is $\tfrac12$-Lipschitz for $d_{\mathbb{H}}$, hence continuous, and closed balls of the moduli space are compact: the moduli space of tori is a proper metric space. Consequently $\operatorname{sys}$ attains a maximum on every compact set and on every moduli ball.

---

## 9. Successive minima: the collar lemma and Minkowski's second theorem

### 9.1 The determinant inequality and the collar lemma

**Theorem 9.1 (Determinant inequality).** If $(m,n)$ and $(p,q)$ are $\mathbb{Z}$-independent (i.e. $mq-np\ne0$), then
$$Q_{m,n}(\tau)\cdot Q_{p,q}(\tau) \ \ge\ 1 .$$

*Proof.* Put $u = m+n\tau$, $v = p+q\tau$. Lagrange's identity gives $|u|^2|v|^2 = (\operatorname{Re}\bar uv)^2 + (\operatorname{Im}\bar uv)^2 \ge (\operatorname{Im}\bar u v)^2$, and $\operatorname{Im}(\bar u v) = (mq-np)\operatorname{Im}\tau$. Hence
$$Q_{m,n}Q_{p,q} = \frac{|u|^2|v|^2}{(\operatorname{Im}\tau)^2}\ \ge\ (mq-np)^2 \ \ge\ 1,$$
since a nonzero integer has square at least $1$. $\square$

Geometrically this is the statement that the lattice $\Lambda_\tau$, normalized to covolume $\operatorname{Im}\tau$, cannot have two short independent vectors: the parallelogram they span has area at least that of a fundamental domain.

**Theorem 9.2 (Collar lemma).** If $(m,n)$ realizes the systole of $\tau$, then for every $(p,q)$ independent of $(m,n)$,
$$Q_{p,q}(\tau)\ \ge\ \frac{1}{\operatorname{sys}\tau}.$$
On the thin part $\operatorname{sys}\tau<1$ this is a genuine gap, $\operatorname{sys}\tau<1<1/\operatorname{sys}\tau$.

*Proof.* Immediate from Theorem 9.1 with $Q_{m,n} = \operatorname{sys}\tau$. $\square$

**Corollary 9.3 (Uniqueness of the shortest geodesic on the thin part).** If $\operatorname{sys}\tau<1$, the index vector realizing the systole is unique up to sign; equivalently, a thin flat torus has exactly one shortest closed geodesic (traversed in two directions).

*Proof.* Two realizing vectors that are independent would give $\operatorname{sys}(\tau)^2\ge1$ by Theorem 9.1, contradicting $\operatorname{sys}\tau<1$. Dependent primitive integer vectors differ by sign. $\square$

The exclusion of the boundary case is necessary: the square torus has $\operatorname{sys}=1$ and *four* shortest vectors $\pm1,\pm i$.

### 9.2 The second successive minimum as an invariant

**Definition 9.4.** $\operatorname{sys}_2(\tau) = \inf\{\, r : \text{the set } \{Q_{m,n}(\tau)\le r\} \text{ contains two independent index vectors}\,\}$.

**Theorem 9.5 (Attainment, simultaneity, order).** The infimum is attained; moreover it is attained *together with* the systole: there exist independent $(m,n)$, $(p,q)$ with $Q_{m,n}(\tau)=\operatorname{sys}\tau$ and $Q_{p,q}(\tau)=\operatorname{sys}_2(\tau)$. Also $\operatorname{sys}\tau\le\operatorname{sys}_2\tau$.

*Proof sketch.* Fix a shortest vector $u_0$. If $(\alpha,\beta)$ is any independent pair, then at least one of $\alpha,\beta$ is independent of $u_0$ — for if $\det(u_0,\alpha)=\det(u_0,\beta)=0$ then $\det(\alpha,\beta)=0$ as $u_0\ne0$. Hence $\operatorname{sys}_2$ equals the minimum of $Q$ over vectors independent of $u_0$, which is attained by the same finiteness argument as Theorem 6.2. $\square$

**Theorem 9.6 (Invariance).** $\operatorname{sys}_2(g\cdot\tau)=\operatorname{sys}_2(\tau)$ for all $g\in SL(2,\mathbb{Z})$: the second minimum is a function on the moduli space.

*Proof sketch.* The index substitution $T_g:(m,n)\mapsto(md+nb, mc+na)$ of Theorem 6.3 is bijective on $\mathbb{Z}^2$ (its inverse is $T_{g^{-1}}$) and satisfies $\det(T_gu, T_gv) = \det(u,v)\cdot\det g = \det(u,v)$, so it preserves independence and all the values $Q$. $\square$

**Theorem 9.7 (Minkowski's second theorem, invariant form).** For every $\tau\in\mathbb{H}$,
$$1 \ \le\ \operatorname{sys}(\tau)\cdot\operatorname{sys}_2(\tau)\ \le\ \frac43 .$$

*Proof sketch.* Lower bound: Theorem 9.1 with a simultaneously realizing independent pair (Theorem 9.5). Upper bound: this needs reduction theory. Move $\tau$ into the fundamental domain; there the pair $(1,0),(0,1)$ is independent and $Q_{1,0}Q_{0,1} = |w|^2/(\operatorname{Im}w)^2$ with $|{\rm Re}\,w|\le\frac12$, $|w|\ge1$. This shows in fact the exact formula below, and $|w|^2/(\operatorname{Im}w)^2 = 1 + ({\rm Re}\,w)^2/(\operatorname{Im}w)^2 \le 1 + \frac{1/4}{3/4} = \frac43$ using $\operatorname{Im}w\ge\sqrt3/2$ and $|{\rm Re}\,w|\le\frac12$. $\square$

**Proposition 9.8 (Closed formula on the fundamental domain).** If $|{\rm Re}\,w|\le\tfrac12$ and $|w|\ge1$ then
$$\operatorname{sys}(w) = \frac{1}{\operatorname{Im}w}, \qquad \operatorname{sys}_2(w) = \frac{|w|^2}{\operatorname{Im}w}, \qquad \operatorname{sys}(w)\cdot\operatorname{sys}_2(w) = \frac{|w|^2}{(\operatorname{Im}w)^2}.$$

**Theorem 9.9 (Both extremal loci).**
1. $\operatorname{sys}(\tau)\operatorname{sys}_2(\tau) = 4/3$ **if and only if** $\tau$ lies in the mapping class group orbit of the hexagonal torus $\rho$.
2. $\operatorname{sys}(\tau)\operatorname{sys}_2(\tau) = 1$ **if and only if** $\tau$ is equivalent to a rectangular torus, i.e. some $g\cdot\tau$ has real part $0$ and imaginary part $\ge1$.

*Proof sketch.* Both directions use Proposition 9.8 after moving $\tau$ into the fundamental domain, where the product is $(x^2+y^2)/y^2$ with $|x|\le\frac12$, $x^2+y^2\ge1$. The product equals $4/3$ iff $x^2 = y^2/3$ and, with $x^2+y^2\ge1$ and $|x|\le\frac12$, this forces $(x,y)=(\pm\frac12,\frac{\sqrt3}{2})$, the two corners, which are the same point of moduli. The product equals $1$ iff $x=0$, i.e. $w=iy$ with $y\ge1$. Conversely, direct computation at $\rho$ gives $\operatorname{sys}\rho=\operatorname{sys}_2\rho=2/\sqrt3$, product $4/3$; at $iY$ with $Y\ge1$, $\operatorname{sys}=1/Y$ and $\operatorname{sys}_2=Y$, product $1$. $\square$

So the product of successive minima is a second natural shape coordinate on the moduli space, with the hexagonal orbifold point the unique maximum and the rectangular locus the exact minimum set.

---

## 10. Algorithms and computation

The theory above is completely effective. Four algorithms suffice to compute everything discussed.

**(A) Reduction to the fundamental domain.** Given $\tau\in\mathbb{H}$, repeat: translate by an integer so that $|{\rm Re}\,\tau|\le\frac12$; if $|\tau|<1$, replace $\tau$ by $-1/\tau$. The process terminates because each inversion strictly increases $\operatorname{Im}\tau$ while translations preserve it, and the imaginary parts in an orbit form a discrete set with a maximum. The number of iterations is $O(\log(1/\operatorname{Im}\tau))$ for a generic input; each step is $O(1)$ arithmetic. The accompanying matrix in $SL(2,\mathbb{Z})$ is accumulated along the way.

**(B) Systole and second minimum.** After reduction, the closed formulas of Proposition 9.8 apply, so both minima are $O(1)$ once the reduction is done. For an unreduced $\tau$ one may alternatively enumerate index vectors in a box: the bound $|m+n\tau|^2\le 1$ confines $|n|\le 1/\operatorname{Im}\tau$ and, for each $n$, $m$ to an interval of length $2$; the cost is $O(1/\operatorname{Im}\tau)$.

**(C) Distances.** $d_T(\tau,\tau') = \tfrac12\operatorname{arcosh}\bigl(1 + |\tau-\tau'|^2/(2\operatorname{Im}\tau\operatorname{Im}\tau')\bigr)$, and equivalently $\tfrac12\log K$ with $K$ given in closed form by Theorem 3.1 — a check of the main identification at every evaluation. For $d_M$, reduce both points and minimize $d_T(\tau, g\cdot\tau')$ over the finitely many $g$ of bounded word length; correctness of a finite search is guaranteed by Theorem 7.1, and Theorem 8.2 provides an a priori bracket for the answer.

**(D) Length spectrum.** By Theorem 5.8 the spectrum below $L$ is $\{\operatorname{arcosh}(n/2) : 3\le n\le 2\cosh L\}$; enumerating it is $O(e^L)$, and the enumeration is *exact* rather than approximate — a rare situation for a length spectrum.

---

## 11. Discussion and future directions

### 11.1 What the genus-one picture models

Every theorem above has a higher-genus analogue whose proof is far harder:

| genus one (proved here, in closed form) | general surfaces |
|---|---|
| the affine map is the unique marked linear map, hence extremal | Teichmüller's existence and uniqueness theorem for extremal quasiconformal maps |
| $d_T = \tfrac12 d_{\mathbb{H}}$ | Royden: the Teichmüller metric equals the Kobayashi metric |
| stretch line is a unit-speed geodesic | Teichmüller geodesics from quadratic differentials |
| translation length $=\log\lambda(g)$ | Bers' formula for pseudo-Anosov stretch factors |
| spectrum $=\{\operatorname{arcosh}(n/2)\}_{n\ge3}$, gap $2\log\varphi$ | discreteness of the pseudo-Anosov spectrum; minimal dilatation problems |
| $\operatorname{sys}\le 2/\sqrt3$ with hexagonal extremal | systolic inequalities, Hermite and Mumford constants |
| $|d_M(\rho,\cdot)-\tfrac12\log(1/\operatorname{sys})|\le\tfrac12\log5$ | the thick-thin decomposition |
| Mahler compactness | Mumford's compactness criterion |
| $1\le\operatorname{sys}\cdot\operatorname{sys}_2\le4/3$ | Minkowski's second theorem; Bers constants |

The list is also a map of what makes the general case hard: uniqueness of the extremal map is free in genus one and is a theorem in general; the trace of an integer matrix computes the translation length in genus one, while in general the stretch factor is an algebraic number with no closed form.

### 11.2 Open problems

**(E1) Royden rigidity from the dilatation axioms.** Is the dilatation calculus of Section 2 enough to force rigidity — i.e. can one prove, purely from submultiplicativity, the determinant identity and the equality case, that every isometry of the Teichmüller metric comes from a mapping class? In genus one this is the (already delicate) statement that isometries of $\mathbb{H}/SL(2,\mathbb{Z})$ are induced by the modular group together with complex conjugation.

**(E2) Higher-rank successive minima.** The methods of Section 9 are two-dimensional only in their reduction theory; the determinant inequality generalizes verbatim to Hermite–Minkowski minima $\lambda_1\cdots\lambda_n\ge1$ for unimodular lattices in $\mathbb{R}^n$. Which parts of Theorem 9.9 (exact determination of the extremal loci) survive in rank $3$, where the extremal lattice is the face-centered cubic?

**(E3) Effective moduli distances.** Theorem 8.2 gives the distance to the hexagonal point up to $\tfrac12\log5$. Is there an exact formula for $d_M(\rho,\tau)$ in terms of $\operatorname{sys}\tau$ and $\operatorname{sys}_2\tau$, at least on the fundamental domain? Equivalently, describe the cut locus of $\rho$ in the moduli orbifold.

**(E4) Counting with multiplicity.** Corollary 5.9 counts the *values* of the length spectrum. Counting Anosov *conjugacy classes* of length $\le L$ — the genus-one prime geodesic theorem — asks for the class number of binary quadratic forms of a given discriminant, and reconnects the metric picture with class field theory.

**(E5) Beyond the linear model.** All extremal maps here are affine. Establishing that no nonlinear quasiconformal homeomorphism of a torus respecting the marking beats the affine one requires the full length-area (Grötzsch) argument; formulating that argument in the present framework, so that Section 3 becomes a theorem about *all* quasiconformal maps rather than all linear ones, is the natural completion of the picture.

### 11.3 Concluding remarks

The unifying thread is that each analytic quantity has been reduced to an exact algebraic identity: submultiplicativity to multiplicativity of the Jacobian; the identification $d_T=\tfrac12 d_{\mathbb{H}}$ to the reflection identity for $\bar\tau$; the trichotomy of isometries to a perfect square over $2y^2$; the collar lemma to "a nonzero integer has square at least one"; and Mahler compactness to properness of a positive definite integral quadratic form. This is why the genus-one theory can be carried out completely: at every point where the general theory needs compactness or a variational principle, the torus offers an identity instead.

---

## Appendix: summary of numerical values

| quantity | value |
|---|---|
| Hermite's constant $\gamma_2 = \operatorname{sys}\rho$ | $2/\sqrt3 \approx 1.1547005$ |
| $\operatorname{sys}(i)$ | $1$ |
| lower bound for $d_M(\rho,i)$ | $\tfrac12\log(2/\sqrt3)\approx0.0719205$ |
| cat map stretch factor | $(3+\sqrt5)/2 = \varphi^2 \approx 2.6180340$ |
| bottom of the length spectrum | $2\log\varphi \approx 0.9624237$ |
| spectral values $\ell(n)=\operatorname{arcosh}(n/2)$, $n=3,4,5,6$ | $0.96242,\ 1.31696,\ 1.56680,\ 1.76275$ |
| additive constant in the exhaustion comparison | $\tfrac12\log5\approx0.8047190$ |
| range of $\operatorname{sys}\cdot\operatorname{sys}_2$ | $[1,\ 4/3]$ |
