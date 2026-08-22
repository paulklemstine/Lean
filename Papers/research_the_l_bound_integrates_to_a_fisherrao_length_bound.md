# The $L^1$ Bound Integrates to a Fisher–Rao Length Bound

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

We prove that along any smooth curve of strictly positive probability vectors on a finite sample space, the $L^1$ distance between the endpoints is bounded above by the Fisher–Rao length of the curve, with optimal constant $1$. The infinitesimal engine is a single application of the Cauchy–Schwarz inequality on the simplex, $\sum_i |v_i| \le \big(\sum_i v_i^2/p_i\big)^{1/2}$, valid because $\sum_i p_i = 1$; integrating this pointwise speed comparison against the fundamental theorem of calculus yields the global statement. We establish a localized version whose hypotheses are imposed only on the interval of integration, and derive the total-variation form: the probability of any event changes by at most half the Fisher–Rao length. We show the inequality is strict for every non-degenerate curve in an exactly solvable two-point family, for which the Fisher–Rao length equals $\arcsin r$ while the $L^1$ displacement equals $r$; the same family shows the constant $1$ is asymptotically attained and therefore optimal. Passing to the square-root (Bhattacharyya) embedding of the simplex into the unit sphere, where the Fisher–Rao speed equals twice the Euclidean speed, we prove a strictly stronger *chord bound*, $\|\sqrt{p(b)} - \sqrt{p(a)}\|_2 \le L/2$, which requires no simplex constraint, and its statistical reformulation $1 - \mathrm{BC}(p(a),p(b)) \le L^2/8$ in terms of the Bhattacharyya coefficient. We prove a Pythagorean tensorization identity: squared Fisher–Rao speeds add over independent factors, the cross term vanishing because velocity fields of simplex curves have total mass zero. Finally we establish a smoothness-free discrete analogue: for an arbitrary finite path of probability vectors, the $L^1$ displacement between the endpoints is at most the sum of twice the Bhattacharyya angles of the consecutive steps.

**Keywords:** Fisher–Rao metric, information geometry, total variation distance, Cauchy–Schwarz inequality, Bhattacharyya coefficient, Hellinger distance, probability simplex, curve length.

---

## 1. Introduction

### 1.1 Two metrics on the space of distributions

Let $\iota$ be a finite index set with $|\iota| = n$ and let
$$\Delta^{\circ} \;=\; \Big\{ p : \iota \to \mathbb{R} \;\Big|\; p_i > 0 \text{ for all } i,\; \textstyle\sum_i p_i = 1 \Big\}$$
denote the open probability simplex. Two structures compete for the title of "the" distance on $\Delta^{\circ}$.

The first is extrinsic and operational: the $L^1$ distance
$$\|p - q\|_1 \;=\; \sum_i |p_i - q_i|,$$
whose half is the total variation distance $d_{\mathrm{TV}}(p,q) = \sup_{S \subseteq \iota} |p(S) - q(S)|$. It is a flat metric — the restriction of the ambient $\ell^1$ norm — and it is the natural currency of hypothesis testing, mixing times, and coupling arguments.

The second is intrinsic: the **Fisher–Rao metric**, the Riemannian structure on $\Delta^{\circ}$ given at the point $p$ by the quadratic form
$$\|v\|_p^2 \;=\; \sum_i \frac{v_i^2}{p_i}, \qquad v \in T_p\Delta^{\circ} = \Big\{ v : \textstyle\sum_i v_i = 0 \Big\}.$$
This is the Fisher information of the one-parameter family $p + tv$ at $t = 0$; by the Cramér–Rao bound it quantifies the local statistical distinguishability of nearby distributions. Uniquely among Riemannian metrics on the simplex, it is invariant under sufficient statistics (Chentsov's theorem), which is the precise sense in which it is *the* geometry of statistical inference.

Because the Fisher–Rao metric weights displacement in a coordinate $i$ by $1/p_i$, motion near the boundary of the simplex is expensive: the same $L^1$ increment costs vastly more Fisher–Rao length when it happens in a rare coordinate. A quantitative comparison of the two structures is therefore natural, and this paper supplies it in the strongest form: a *length* comparison, with optimal constant, together with several strengthenings and a discretization.

### 1.2 Statement of the main result

For a curve $t \mapsto p(t)$ in $\Delta^\circ$ with velocity field $v(t)$, define the **Fisher–Rao speed** and **Fisher–Rao length**
$$\sigma(t) \;=\; \sqrt{\sum_i \frac{v_i(t)^2}{p_i(t)}}, \qquad L_a^b \;=\; \int_a^b \sigma(t)\,dt.$$

> **Theorem A ($L^1$–Fisher–Rao length bound).** Let $a \le b$, let $p : \mathbb{R} \to (\iota \to \mathbb{R})$ be such that for every $t$ and $i$ the function $s \mapsto p_i(s)$ is differentiable at $t$ with derivative $v_i(t)$, let each $t \mapsto v_i(t)$ be continuous, and suppose $p_i(t) > 0$ and $\sum_i p_i(t) = 1$ for all $t$. Then
> $$\|p(b) - p(a)\|_1 \;\le\; \int_a^b \sqrt{\sum_i \frac{v_i(t)^2}{p_i(t)}}\;dt.$$

Equivalently, $d_{\mathrm{TV}}(p(a),p(b)) \le \tfrac{1}{2}L_a^b$.

The remainder of the paper is organized as follows. Section 2 fixes definitions and elementary properties. Section 3 proves the infinitesimal Cauchy–Schwarz bound and Theorem A, together with a localized variant. Section 4 analyses sharpness through an exactly solvable family. Section 5 develops the square-root embedding and proves the strictly stronger chord bound and its Hellinger/Bhattacharyya form. Section 6 proves the Pythagorean tensorization identity. Section 7 gives the smoothness-free discrete analogue. Sections 8–10 discuss algorithms, applications, and open directions.

---

## 2. Definitions and elementary properties

Throughout, $\iota$ is a finite index set and all sums $\sum_i$ run over $\iota$.

**Definition 2.1 ($L^1$ distance).** For $p, q : \iota \to \mathbb{R}$,
$$\ell_1(p,q) \;=\; \sum_i |p_i - q_i|.$$

**Definition 2.2 (Fisher–Rao speed).** For $p, v : \iota \to \mathbb{R}$ with $p$ strictly positive,
$$\sigma(p,v) \;=\; \sqrt{\sum_i \frac{v_i^2}{p_i}}.$$

**Definition 2.3 (Fisher–Rao length).** For a curve $p : \mathbb{R} \to (\iota \to \mathbb{R})$ with velocity field $v$, and $a, b \in \mathbb{R}$,
$$L(p,v;a,b) \;=\; \int_a^b \sigma(p(t), v(t))\,dt.$$

**Proposition 2.4.** $\ell_1$ is a pseudometric on $\iota \to \mathbb{R}$: it is nonnegative, symmetric, and satisfies the triangle inequality $\ell_1(p,r) \le \ell_1(p,q) + \ell_1(q,r)$.

*Proof.* Nonnegativity and symmetry are immediate from the corresponding properties of $|\cdot|$ applied termwise. For the triangle inequality, write $p_i - r_i = (p_i - q_i) + (q_i - r_i)$, apply the scalar triangle inequality coordinatewise, and sum. $\square$

**Proposition 2.5.** $\sigma(p,v) \ge 0$ always, and $L(p,v;a,b) \ge 0$ whenever $a \le b$. Moreover, if the integrand is continuous, the length is additive under concatenation:
$$L(p,v;a,b) + L(p,v;b,c) \;=\; L(p,v;a,c).$$

*Proof.* Nonnegativity is that of the square root; the integral of a nonnegative function over $[a,b]$ with $a \le b$ is nonnegative. Additivity is the additivity of the interval integral over adjacent intervals, which requires integrability on each piece; this holds because $t \mapsto \sigma(p(t),v(t))$ is continuous (Lemma 3.3). $\square$

**Proposition 2.6 (Total variation is half of $L^1$).** If $\sum_i p_i = \sum_i q_i = 1$, then for every subset $S \subseteq \iota$,
$$\Big| \sum_{i \in S} p_i - \sum_{i\in S} q_i \Big| \;\le\; \tfrac{1}{2}\,\ell_1(p,q),$$
with equality for $S = \{i : p_i \ge q_i\}$.

*Proof.* Let $D = \sum_{i\in S}(p_i - q_i)$ and $D' = \sum_{i \in S^c}(p_i - q_i)$. Since $\sum_i p_i = \sum_i q_i$, we have $D + D' = 0$, so $|D| = |D'|$. By the triangle inequality $|D| \le \sum_{i\in S}|p_i - q_i|$ and $|D| = |D'| \le \sum_{i\in S^c}|p_i-q_i|$. Adding the two and dividing by $2$ gives $|D| \le \tfrac12 \ell_1(p,q)$. $\square$

---

## 3. The main theorem

### 3.1 The infinitesimal bound

The entire result rests on the following pointwise comparison of speeds.

> **Theorem 3.1 (Infinitesimal $L^1 \le$ Fisher–Rao bound).** Let $p : \iota \to \mathbb{R}$ satisfy $p_i > 0$ for all $i$ and $\sum_i p_i = 1$, and let $v : \iota \to \mathbb{R}$ be arbitrary. Then
> $$\sum_i |v_i| \;\le\; \sqrt{\sum_i \frac{v_i^2}{p_i}}.$$

*Proof.* Split each summand using the strict positivity of $p_i$:
$$\sum_i |v_i| \;=\; \sum_i \left(\frac{|v_i|}{\sqrt{p_i}}\right)\left(\sqrt{p_i}\right).$$
Apply the Cauchy–Schwarz inequality to the vectors $x_i = |v_i|/\sqrt{p_i}$ and $y_i = \sqrt{p_i}$, in the form $\big(\sum_i x_i y_i\big)^2 \le \big(\sum_i x_i^2\big)\big(\sum_i y_i^2\big)$. Since $x_i^2 = v_i^2/p_i$ and $y_i^2 = p_i$, and $\sum_i p_i = 1$,
$$\Big(\sum_i |v_i|\Big)^2 \;\le\; \Big(\sum_i \frac{v_i^2}{p_i}\Big)\cdot 1.$$
Both sides being nonnegative, taking square roots (and using $\sqrt{x^2} = x$ for $x = \sum_i|v_i| \ge 0$) gives the claim. $\square$

Two remarks. First, the normalization $\sum_i p_i = 1$ is exactly what makes the constant $1$: for an unnormalized positive weight vector one obtains $\sum_i |v_i| \le \sigma(p,v)\sqrt{\sum_i p_i}$. Second, equality in Cauchy–Schwarz holds iff $|v_i|/\sqrt{p_i} \propto \sqrt{p_i}$, i.e. iff $|v_i| = c\, p_i$ for a constant $c$. Combined with $\sum_i v_i = 0$ (forced for tangent vectors to the simplex), equality at a point requires $v$ to have $|v_i| = c p_i$ with signs summing to zero — a condition that cannot be maintained along a curve without the curve degenerating, which is the structural reason for the strictness observed in Section 4.

### 3.2 Regularity infrastructure

**Lemma 3.2.** If $s \mapsto p_i(s)$ is differentiable at every $t$, then $t \mapsto p_i(t)$ is continuous.

*Proof.* Differentiability at a point implies continuity at that point; continuity at every point is continuity. $\square$

**Lemma 3.3.** Under the hypotheses of Theorem A, the maps
$$t \mapsto \sum_i |v_i(t)| \qquad\text{and}\qquad t \mapsto \sigma(p(t),v(t))$$
are continuous, hence integrable on every compact interval.

*Proof.* The first is a finite sum of compositions of the continuous $v_i$ with the absolute value. For the second, each $t \mapsto v_i(t)^2$ is continuous, each $t \mapsto p_i(t)$ is continuous by Lemma 3.2 and nonvanishing by hypothesis, so each quotient $v_i^2/p_i$ is continuous; a finite sum of continuous functions is continuous, and $\sqrt{\cdot}$ is continuous on $[0,\infty)$. $\square$

### 3.3 Proof of Theorem A

*Proof of Theorem A.* We proceed in four steps.

**Step 1 (Fundamental theorem of calculus, coordinatewise).** For each $i$, the function $s \mapsto p_i(s)$ has derivative $v_i$ everywhere and $v_i$ is continuous, hence integrable on $[a,b]$. Therefore
$$p_i(b) - p_i(a) \;=\; \int_a^b v_i(t)\,dt.$$

**Step 2 (Coordinatewise absolute bound).** Since $a \le b$, taking absolute values and using $\big|\int_a^b f\big| \le \int_a^b |f|$,
$$|p_i(b) - p_i(a)| \;\le\; \int_a^b |v_i(t)|\,dt.$$

**Step 3 (Sum and exchange).** Summing over the finite index set $\iota$ and exchanging the finite sum with the integral (legitimate since each $|v_i|$ is integrable),
$$\ell_1(p(b),p(a)) \;=\; \sum_i |p_i(b)-p_i(a)| \;\le\; \sum_i \int_a^b |v_i(t)|\,dt \;=\; \int_a^b \sum_i |v_i(t)|\,dt.$$

**Step 4 (Integrate the infinitesimal bound).** By Theorem 3.1 applied at each $t$ (using $p_i(t) > 0$ and $\sum_i p_i(t) = 1$),
$$\sum_i |v_i(t)| \;\le\; \sigma(p(t),v(t)) \qquad \text{for all } t \in [a,b].$$
Both sides are continuous by Lemma 3.3, hence integrable, and monotonicity of the integral over $[a,b]$ gives
$$\int_a^b \sum_i |v_i(t)|\,dt \;\le\; \int_a^b \sigma(p(t),v(t))\,dt \;=\; L(p,v;a,b).$$
Chaining Steps 3 and 4 proves the theorem. $\square$

### 3.4 Localization

Theorem A as stated asks for a globally defined positive probability curve. This is a genuine restriction: a straight segment $t \mapsto (1-t)p + tq$ in the simplex, extended to all of $\mathbb{R}$, leaves the simplex in finite time and violates positivity. The correct statement imposes hypotheses only where they are used.

> **Theorem 3.4 (Localized length bound).** Let $a \le b$. Suppose that for every $t$ in the closed interval $[a,b]$ and every $i$: the function $s \mapsto p_i(s)$ is differentiable at $t$ with derivative $v_i(t)$; each $t \mapsto v_i(t)$ is continuous on $[a,b]$; $p_i(t) > 0$; and $\sum_i p_i(t) = 1$. Then
> $$\ell_1(p(b),p(a)) \;\le\; L(p,v;a,b).$$

*Proof.* Identical to the proof of Theorem A, with continuity replaced by continuity on $[a,b]$ throughout: $t \mapsto p_i(t)$ is continuous on $[a,b]$ because it is differentiable there; the quotients $v_i^2/p_i$ are continuous on $[a,b]$ because the denominators do not vanish there; the fundamental theorem of calculus applies with derivative hypotheses on $[a,b]$; and the pointwise Cauchy–Schwarz bound is invoked only at $t \in [a,b]$. $\square$

The positivity requirement is not a technicality of the proof. If the curve touches the boundary, $v_i^2/p_i$ can be non-integrable and the Fisher–Rao length genuinely infinite while the $L^1$ displacement remains bounded by $2$; numerically, the integrand exhibits the expected blow-up as a coordinate approaches zero.

### 3.5 Total-variation and event forms

> **Corollary 3.5 (Total variation form).** Under the hypotheses of Theorem A,
> $$d_{\mathrm{TV}}\big(p(a),p(b)\big) \;=\; \tfrac{1}{2}\,\ell_1(p(b),p(a)) \;\le\; \tfrac{1}{2}\,L(p,v;a,b).$$

> **Corollary 3.6 (No event moves far).** Under the hypotheses of Theorem A, for every $S \subseteq \iota$,
> $$\Big|\sum_{i\in S} p_i(b) - \sum_{i\in S} p_i(a)\Big| \;\le\; \tfrac{1}{2}\,L(p,v;a,b).$$

*Proof.* Combine Proposition 2.6 (with $p = p(b)$, $q = p(a)$, both normalized) with Theorem A. $\square$

Corollary 3.6 is the statistically meaningful reading: *a curve of short Fisher–Rao length cannot change the probability of any event by more than half that length.* No test, no measurable set, no decision rule can detect more than $L/2$ worth of change.

---

## 4. Sharpness: an exactly solvable family

We now determine exactly how tight Theorem A is by computing both sides in closed form for a one-parameter family of curves in the two-point simplex.

**Definition 4.1.** For $r \in [0,1)$ define the curve $p^{(r)} : \mathbb{R} \to (\{1,2\}\to\mathbb{R})$ and velocity $v^{(r)}$ by
$$p^{(r)}(t) = \left(\frac{1 + r\sin t}{2},\; \frac{1 - r\sin t}{2}\right), \qquad v^{(r)}(t) = \left(\frac{r\cos t}{2},\; -\frac{r\cos t}{2}\right).$$

**Lemma 4.2.** $v^{(r)}$ is the velocity field of $p^{(r)}$; the coordinates sum to $1$ for all $t$; and if $|r| < 1$ then both coordinates are strictly positive for all $t$, since $|r\sin t| \le |r| < 1$.

**Lemma 4.3 (Speed).** For $|r| < 1$ and any $t$ with $r\cos t \ge 0$,
$$\sigma\big(p^{(r)}(t), v^{(r)}(t)\big) \;=\; \frac{r\cos t}{\sqrt{1 - r^2\sin^2 t}}.$$

*Proof.* Write $u = r\sin t$, so the coordinates are $(1\pm u)/2$ and the velocity components are $\pm r\cos t/2$. Then
$$\sum_i \frac{v_i^2}{p_i} = \frac{(r\cos t)^2/4}{(1+u)/2} + \frac{(r\cos t)^2/4}{(1-u)/2} = \frac{(r\cos t)^2}{2}\left(\frac{1}{1+u}+\frac{1}{1-u}\right) = \frac{(r\cos t)^2}{1-u^2}.$$
Taking the square root and using $r\cos t \ge 0$ gives the formula. $\square$

> **Theorem 4.4 (Exact length).** For $0 \le r < 1$,
> $$L\big(p^{(r)}, v^{(r)}; 0, \tfrac{\pi}{2}\big) \;=\; \arcsin r, \qquad \ell_1\Big(p^{(r)}(\tfrac{\pi}{2}), p^{(r)}(0)\Big) \;=\; r.$$

*Proof.* On $[0,\pi/2]$ we have $\cos t \ge 0$, so Lemma 4.3 applies and the length is
$$\int_0^{\pi/2} \frac{r\cos t}{\sqrt{1-r^2\sin^2 t}}\;dt.$$
The integrand is exactly $\frac{d}{dt}\arcsin(r\sin t)$: indeed, by the chain rule with $\frac{d}{dx}\arcsin x = 1/\sqrt{1-x^2}$ (valid since $|r\sin t| < 1$), the derivative of $\arcsin(r\sin t)$ is $r\cos t/\sqrt{1-r^2\sin^2 t}$. By the fundamental theorem of calculus the integral equals $\arcsin(r\sin \tfrac\pi2) - \arcsin(r\sin 0) = \arcsin r$.

For the $L^1$ displacement, the endpoints are $p^{(r)}(0) = (\tfrac12,\tfrac12)$ and $p^{(r)}(\tfrac\pi2) = (\tfrac{1+r}{2}, \tfrac{1-r}{2})$, so the displacement is $|r/2| + |-r/2| = r$. $\square$

Theorem A applied to this family therefore reads $r \le \arcsin r$ for $r \in [0,1)$ — the classical elementary inequality, recovered as an instance of information geometry.

> **Corollary 4.5 (Strictness).** For $0 < r < 1$,
> $$\ell_1\Big(p^{(r)}(\tfrac{\pi}{2}),p^{(r)}(0)\Big) \;<\; L\big(p^{(r)},v^{(r)};0,\tfrac{\pi}{2}\big).$$

*Proof.* Set $\theta = \arcsin r > 0$. The strict inequality $\sin\theta < \theta$ for $\theta > 0$ gives $r = \sin(\arcsin r) < \arcsin r$. $\square$

> **Corollary 4.6 (Optimality of the constant).** For every $\varepsilon > 0$ there exists $r \in (0,1)$ with
> $$L\big(p^{(r)},v^{(r)};0,\tfrac\pi2\big) \;\le\; (1+\varepsilon)\,\ell_1\Big(p^{(r)}(\tfrac\pi2),p^{(r)}(0)\Big).$$
> Consequently no constant $c < 1$ satisfies $\ell_1(p(b),p(a)) \le c\,L$ for all curves.

*Proof.* Put $d = \min\{1, \sqrt{\varepsilon}\}$ and $r = \sin d$; then $0 < r < 1$ and $\arcsin r = d$. We must show $d \le (1+\varepsilon)\sin d$. Using the elementary bound $\sin d > d - d^3/4$ valid for $0 < d \le 1$, it suffices that $d \le (1+\varepsilon)(d - d^3/4)$, i.e. that $(1+\varepsilon)d^2/4 \le \varepsilon$. Since $d^2 \le \varepsilon$ and $d^2 \le 1$, we get $(1+\varepsilon)d^2/4 \le (\varepsilon + \varepsilon^2)/4 \le \varepsilon$ whenever $\varepsilon \le 3$, and for larger $\varepsilon$ the inequality $d = 1$ gives $(1+\varepsilon)/4 \le \varepsilon$ directly. $\square$

The ratio $\arcsin r / r$ increases from $1$ (as $r \to 0^+$) to $\pi/2 \approx 1.5708$ (as $r \to 1^-$). Thus the deficit in Theorem A is second-order for short curves and bounded by the factor $\pi/2$ for this family even at maximal excursion.

---

## 5. The square-root embedding and the chord bound

### 5.1 The simplex as a piece of a sphere

**Definition 5.1.** The *square-root embedding* is $\Phi(p)_i = \sqrt{p_i}$.

**Proposition 5.2.** If $p_i \ge 0$ and $\sum_i p_i = 1$, then $\sum_i \Phi(p)_i^2 = 1$: the embedding maps the simplex into the unit sphere of $\mathbb{R}^\iota$, in fact onto its nonnegative orthant.

**Definition 5.3.** For $p$ strictly positive with velocity $v$, the *square-root velocity* is
$$\widetilde v_i \;=\; \frac{v_i}{2\sqrt{p_i}},$$
which is indeed $\frac{d}{dt}\sqrt{p_i(t)}$ by the chain rule, valid since $p_i > 0$.

> **Theorem 5.4 (Fisher–Rao is round).** For $p$ strictly positive,
> $$\sigma(p,v) \;=\; 2\sqrt{\sum_i \widetilde v_i^{\,2}}.$$
> That is, the Fisher–Rao speed is exactly twice the Euclidean speed of the square-root curve.

*Proof.* $\widetilde v_i^{\,2} = v_i^2/(4 p_i)$, so $\sum_i \widetilde v_i^{\,2} = \tfrac14 \sum_i v_i^2/p_i$. Taking square roots and multiplying by $2$ gives the claim. $\square$

Thus Fisher–Rao geometry on $\Delta^\circ$ is the round geometry of the sphere of radius $2$ (equivalently, the unit sphere rescaled), restricted to the positive orthant. Every statement below is a transported spherical fact.

### 5.2 The chord bound

> **Theorem 5.5 (Chord bound).** Let $a \le b$, let $p$ have continuous velocity field $v$ and satisfy $p_i(t) > 0$ for all $t, i$. Then
> $$\Big\| \Phi(p(b)) - \Phi(p(a)) \Big\|_2 \;=\; \sqrt{\sum_i \big(\sqrt{p_i(b)} - \sqrt{p_i(a)}\big)^2} \;\le\; \tfrac12\, L(p,v;a,b).$$
> No normalization hypothesis is required: this is a purely metric statement.

*Proof.* Let $\Delta_i = \sqrt{p_i(b)} - \sqrt{p_i(a)}$ and $D = \|\Delta\|_2$. If $D = 0$ the claim is the nonnegativity of the length, so assume $D > 0$ and consider the *scalar* test function
$$g(t) \;=\; \frac{1}{D}\sum_i \Delta_i \sqrt{p_i(t)}.$$
This device replaces vector-valued integration by ordinary one-dimensional calculus.

*Endpoint values.* $g(b) - g(a) = \frac{1}{D}\sum_i \Delta_i \big(\sqrt{p_i(b)} - \sqrt{p_i(a)}\big) = \frac{1}{D}\sum_i \Delta_i^2 = \frac{D^2}{D} = D$.

*Derivative.* By the chain rule and Definition 5.3, $g'(t) = \frac{1}{D}\sum_i \Delta_i \widetilde v_i(t)$, and $g'$ is continuous.

*Pointwise bound.* By Cauchy–Schwarz and Theorem 5.4,
$$\Big|\sum_i \Delta_i \widetilde v_i(t)\Big| \;\le\; \|\Delta\|_2\, \Big(\sum_i \widetilde v_i(t)^2\Big)^{1/2} \;=\; D \cdot \tfrac12\,\sigma(p(t),v(t)),$$
hence $g'(t) \le \tfrac12 \sigma(p(t),v(t))$ for every $t$.

*Integration.* Both $g'$ and $\sigma$ are continuous, hence integrable on $[a,b]$, and by the fundamental theorem of calculus and monotonicity of the integral,
$$D \;=\; g(b) - g(a) \;=\; \int_a^b g'(t)\,dt \;\le\; \int_a^b \tfrac12\sigma(p(t),v(t))\,dt \;=\; \tfrac12 L(p,v;a,b). \qquad\square$$

Theorem 5.5 is strictly stronger than Theorem A for short curves. Indeed, the coordinatewise inequality $(\sqrt{x}-\sqrt{y})^2 \le |x - y|$ for $x, y \ge 0$ — which follows from $|x-y| = |\sqrt x - \sqrt y|(\sqrt x + \sqrt y) \ge |\sqrt x - \sqrt y|^2$ — gives, upon summation,
$$\sum_i \big(\sqrt{p_i} - \sqrt{q_i}\big)^2 \;\le\; \ell_1(p,q),$$
i.e. twice the squared Hellinger distance is at most the $L^1$ distance. Combining with Theorem A yields the *weak* Hellinger bound $H^2(p(a),p(b)) \le \tfrac12 L$; Theorem 5.5, by contrast, gives the *quadratic* bound below.

### 5.3 Hellinger and Bhattacharyya forms

**Definition 5.6.** The *Bhattacharyya coefficient* of two nonnegative vectors is $\mathrm{BC}(p,q) = \sum_i \sqrt{p_i q_i}$; for probability vectors it is the Euclidean inner product $\langle \Phi(p), \Phi(q)\rangle$ of the square-root embeddings, hence the cosine of the spherical angle between them. The squared Hellinger distance is $H^2(p,q) = \tfrac12\sum_i(\sqrt{p_i}-\sqrt{q_i})^2 = 1 - \mathrm{BC}(p,q)$.

> **Theorem 5.7 (Quadratic overlap bound).** Under the hypotheses of Theorem A,
> $$1 - \mathrm{BC}\big(p(a),p(b)\big) \;\le\; \tfrac18\, L(p,v;a,b)^2.$$

*Proof.* For normalized $p(a), p(b)$,
$$\sum_i \big(\sqrt{p_i(b)}-\sqrt{p_i(a)}\big)^2 = \sum_i p_i(b) + \sum_i p_i(a) - 2\sum_i \sqrt{p_i(b)p_i(a)} = 2 - 2\,\mathrm{BC}(p(a),p(b)).$$
By Theorem 5.5, squaring the (nonnegative) chord bound gives $2 - 2\mathrm{BC} \le \tfrac14 L^2$, i.e. $1 - \mathrm{BC} \le \tfrac18 L^2$. $\square$

For small $L$ this is dramatically stronger than the linear bound: it says that overlap deficit — equivalently, squared Hellinger distance — is *second order* in the Fisher–Rao length, whereas $L^1$ displacement is only first order. Both are consistent with the exactly solvable family of Section 4. There the endpoints are $(\tfrac12,\tfrac12)$ and $(\tfrac{1+r}{2},\tfrac{1-r}{2})$, so
$$\mathrm{BC} = \sqrt{\tfrac{1+r}{4}} + \sqrt{\tfrac{1-r}{4}} = \tfrac12\big(\sqrt{1+r}+\sqrt{1-r}\big),$$
whence $1 - \mathrm{BC} = \tfrac{r^2}{8} + O(r^4)$, while $L^2/8 = (\arcsin r)^2/8 = \tfrac{r^2}{8} + O(r^4)$. The two agree to leading order: the chord bound is asymptotically tight as well.

---

## 6. Tensorization: Fisher–Rao is Pythagorean

Independent systems combine multiplicatively at the level of distributions and additively at the level of squared Fisher–Rao speed.

**Lemma 6.1 (Velocities are traceless).** If $t \mapsto p(t)$ is differentiable with velocity $v(t)$ and $\sum_i p_i(t) = 1$ for all $t$, then $\sum_i v_i(t) = 0$ for all $t$.

*Proof.* The function $s \mapsto \sum_i p_i(s)$ is constant equal to $1$, so its derivative is $0$; but by linearity of the derivative it is also $\sum_i v_i(t)$. Uniqueness of the derivative gives the claim. $\square$

> **Theorem 6.2 (Pythagorean tensorization).** Let $p \in \Delta^\circ(\iota)$ and $q \in \Delta^\circ(\kappa)$ be strictly positive probability vectors, and let $v : \iota\to\mathbb{R}$, $w : \kappa\to\mathbb{R}$ be tangent vectors with $\sum_j w_j = 0$. Consider the product point $(p\otimes q)_{(i,j)} = p_i q_j$ with velocity $(v\otimes q + p\otimes w)_{(i,j)} = v_i q_j + p_i w_j$. Then
> $$\sum_{(i,j)} \frac{(v_i q_j + p_i w_j)^2}{p_i q_j} \;=\; \sum_i \frac{v_i^2}{p_i} + \sum_j \frac{w_j^2}{q_j},$$
> equivalently $\sigma(p\otimes q,\, v\otimes q + p \otimes w) = \sqrt{\sigma(p,v)^2 + \sigma(q,w)^2}$.

*Proof.* Expand the square coordinatewise:
$$\frac{(v_i q_j + p_i w_j)^2}{p_i q_j} \;=\; \frac{v_i^2}{p_i}q_j \;+\; 2 v_i w_j \;+\; p_i\,\frac{w_j^2}{q_j}.$$
Sum over $j \in \kappa$ using $\sum_j q_j = 1$ and $\sum_j w_j = 0$: the middle term vanishes and
$$\sum_j \frac{(v_iq_j+p_iw_j)^2}{p_iq_j} \;=\; \frac{v_i^2}{p_i} + p_i \sum_j \frac{w_j^2}{q_j}.$$
Now sum over $i \in \iota$ using $\sum_i p_i = 1$, obtaining $\sum_i v_i^2/p_i + \sum_j w_j^2/q_j$. Taking square roots gives the speed form. $\square$

The vanishing of the cross term is precisely conservation of probability: by Lemma 6.1 a genuine simplex velocity is traceless, and independence turns the metric into an orthogonal direct sum. Consequently the Fisher–Rao length of a product curve of independently evolving systems is the length of the corresponding curve in a product Riemannian manifold — the geometry factorizes, and Theorem A applied to the product recovers the $L^1$ bound for the joint distribution.

---

## 7. The discrete, smoothness-free analogue

Theorem A needs differentiability. Its conclusion, however, survives in a purely combinatorial setting, where "length" becomes a sum of spherical steps.

> **Theorem 7.1 (Le Cam's inequality).** For probability vectors $p, q$ on $\iota$,
> $$\ell_1(p,q) \;\le\; 2\sqrt{1 - \mathrm{BC}(p,q)^2}.$$

*Proof.* Factor each term: $|p_i - q_i| = |\sqrt{p_i}-\sqrt{q_i}|\cdot(\sqrt{p_i}+\sqrt{q_i})$. By Cauchy–Schwarz,
$$\ell_1(p,q)^2 \;\le\; \Big(\sum_i (\sqrt{p_i}-\sqrt{q_i})^2\Big)\Big(\sum_i(\sqrt{p_i}+\sqrt{q_i})^2\Big).$$
Expanding and using normalization, $\sum_i(\sqrt{p_i}\mp\sqrt{q_i})^2 = 2 \mp 2\,\mathrm{BC}(p,q)$, so the right-hand side is $(2-2\mathrm{BC})(2+2\mathrm{BC}) = 4(1-\mathrm{BC}^2)$. Taking square roots gives the claim (and in passing shows $\mathrm{BC} \le 1$). $\square$

> **Corollary 7.2 (Single-step angular bound).** $\ell_1(p,q) \le 2\arccos \mathrm{BC}(p,q)$.

*Proof.* Since $\mathrm{BC} \in [0,1]$, write $\theta = \arccos\mathrm{BC} \in [0,\pi/2]$; then $\sqrt{1-\mathrm{BC}^2} = \sin\theta \le \theta$ by the elementary bound $\sin x \le x$ for $x \ge 0$. Apply Theorem 7.1. $\square$

The quantity $\arccos\mathrm{BC}(p,q)$ is exactly the geodesic distance between $\Phi(p)$ and $\Phi(q)$ on the unit sphere; twice it is the Fisher–Rao geodesic distance in the normalization of Definition 2.2 (consistent with the factor $2$ of Theorem 5.4). Corollary 7.2 is therefore the exact discrete counterpart of Theorem A for a single step.

> **Theorem 7.3 (Discrete Fisher–Rao length bound).** Let $p^{(0)}, p^{(1)}, \dots, p^{(N)}$ be any finite sequence of probability vectors on $\iota$ (nonnegative, summing to $1$; no other hypotheses). Then
> $$\ell_1\big(p^{(N)}, p^{(0)}\big) \;\le\; \sum_{k=0}^{N-1} 2\arccos \mathrm{BC}\big(p^{(k)}, p^{(k+1)}\big).$$

*Proof.* Induction on $N$. For $N = 0$ both sides are $0$. For the inductive step, the triangle inequality for $\ell_1$ (Proposition 2.4) gives
$$\ell_1\big(p^{(N+1)},p^{(0)}\big) \le \ell_1\big(p^{(N+1)},p^{(N)}\big) + \ell_1\big(p^{(N)},p^{(0)}\big),$$
and the first term is at most $2\arccos\mathrm{BC}(p^{(N)},p^{(N+1)})$ by Corollary 7.2 (using symmetry of $\ell_1$), while the second is handled by the inductive hypothesis. $\square$

Theorem 7.3 requires no derivative, no interval, no strict positivity, and no continuity. It applies verbatim to the trajectory of a Markov chain, to iterates of an optimization algorithm on the simplex, or to any sequence of empirical measures. In the smooth case, refining the partition of $[a,b]$ makes the right-hand side of Theorem 7.3 converge to the Fisher–Rao length, so Theorem 7.3 contains Theorem A in the limit — with the important caveat that the discrete bound is available even when the limit does not exist.

---

## 8. Algorithms

Three computational primitives follow directly from the theory.

**8.1 Fisher–Rao length by quadrature.** Given a curve and its velocity field, evaluate the integrand $\sigma(p(t),v(t)) = \big(\sum_i v_i(t)^2/p_i(t)\big)^{1/2}$ at quadrature nodes and sum. With the midpoint rule on $n$ subintervals and $|\iota| = m$, the cost is $\Theta(nm)$ and the error is $O(n^{-2})$ for a $C^2$ integrand. The integrand is smooth as long as the curve stays away from the boundary, and degrades sharply as $\min_i p_i(t) \to 0$; adaptive refinement near such points is essential.

**8.2 Discrete length via Bhattacharyya angles.** Given a sequence of distributions, compute $\mathrm{BC}(p^{(k)},p^{(k+1)}) = \sum_i \sqrt{p_i^{(k)}p_i^{(k+1)}}$ for each consecutive pair, take $\arccos$, and sum with weight $2$. The cost is $\Theta(Nm)$ for $N$ steps. Numerical caution: $\arccos$ loses precision when $\mathrm{BC} \approx 1$ (nearly coincident distributions); it is more accurate to compute the chord $c = \|\Phi(p)-\Phi(q)\|_2$ and use $2\arcsin(c/2)$, which is well-conditioned in that regime.

**8.3 Certified bound checking.** Given a curve, compute simultaneously (i) $\ell_1$ displacement, (ii) the chord $\|\Phi(p(b))-\Phi(p(a))\|_2$, (iii) the Fisher–Rao length $L$, and verify the chain
$$\ell_1 \le L, \qquad \text{chord} \le L/2, \qquad 1 - \mathrm{BC} \le L^2/8.$$
This is the natural regression test on any numerical implementation and, for the two-point family of Section 4, can be checked against the closed forms $\ell_1 = r$, $L = \arcsin r$.

---

## 9. Applications and discussion

**Sample complexity and statistical stability.** Fisher information is, by the Cramér–Rao bound and the local asymptotic normality theory, the local currency of statistical distinguishability. Corollary 3.6 converts a budget on Fisher–Rao length into a hard, non-asymptotic guarantee: no event's probability changes by more than $L/2$. If a learning procedure moves a model a Fisher–Rao distance of $0.1$, every single yes/no prediction shifts by at most $0.05$ in probability, uniformly over all events.

**Optimization on the simplex.** Natural gradient descent, mirror descent with the entropic mirror map, and replicator dynamics all trace curves in $\Delta^\circ$ whose intrinsic length is exactly (a constant multiple of) the Fisher–Rao length. Theorem A translates a bound on cumulative natural-gradient work into a bound on total-variation displacement of the model, independent of the algorithm's internal structure. Theorem 5.7 sharpens this quadratically for small steps, and Theorem 7.3 makes it applicable to the discrete iterates directly, with no interpolation.

**Markov chains and mixing.** Total variation is the standard metric for mixing times. Theorem 7.3 bounds total-variation displacement of a chain's law by an accumulation of per-step Bhattacharyya angles — a quantity computable from consecutive laws alone, without spectral information.

**Quantum speed limits.** The square-root embedding is exactly the passage from a classical distribution to a real, nonnegative amplitude vector, and Fisher–Rao length is the Fubini–Study length restricted to that real slice. Theorem 5.5 is thus the classical shadow of the Mandelstam–Tamm-type statement that the distance a state can travel is controlled by the energy expended. The Pythagorean tensorization of Theorem 6.2 mirrors the additivity of quantum Fisher information over independent subsystems.

**Comparison with other bounds.** The chain established here is
$$\underbrace{1-\mathrm{BC} \le \tfrac18 L^2}_{\text{second order}} \quad\text{and}\quad \underbrace{2\sqrt{1-\mathrm{BC}} \le L \quad (\text{chord form})}_{\text{first order, stronger}} \quad\text{and}\quad \underbrace{\ell_1 \le L}_{\text{Theorem A}}.$$
Together with Le Cam's two-sided comparison $1 - \mathrm{BC} \le \tfrac12 \ell_1 \le \sqrt{1-\mathrm{BC}^2}$, this places Fisher–Rao length above the entire Hellinger/total-variation hierarchy, and shows precisely where each inequality is tight: at first order in short curves for the chord and $L^1$ bounds, at second order for the Bhattacharyya bound.

**Limitations.** The hypotheses of strict positivity and normalization along the curve are essential and not removable. Positivity fails for curves that touch the boundary, where the Fisher–Rao length may diverge; the localized Theorem 3.4 is the right tool when positivity holds only on the interval of interest. Normalization is what fixes the constant at $1$; for unnormalized measures a factor $\sqrt{\sum_i p_i}$ reappears. Finally, the results are stated for a finite sample space; extension to general measure spaces (with Fisher–Rao length defined via the $L^2$ norm of $\dot p/\sqrt{p}$, i.e. the square-root density curve in $L^2$) is expected but requires genuine measure-theoretic infrastructure — see Section 10.

---

## 10. Future directions

Several concrete extensions suggest themselves.

1. **Infinite sample spaces.** Replace the finite index set by a general $\sigma$-finite measure space and the sum by an integral: define the Fisher–Rao speed of a curve of densities $p_t$ as $\|\dot p_t/\sqrt{p_t}\|_{L^2}$. The Cauchy–Schwarz step is unchanged; the work lies in the absolute continuity and dominated-convergence hypotheses needed to differentiate under the integral sign and to apply the fundamental theorem of calculus in a Banach-valued setting.

2. **Geodesic completion and the exact metric.** The Fisher–Rao geodesic distance on the simplex is $2\arccos\mathrm{BC}(p,q)$. It would be natural to prove directly that $L$ is minimized over all curves joining $p$ to $q$ by the spherical great-circle arc, and to deduce Theorem A from the sharp inequality $\ell_1(p,q) \le 2\arccos\mathrm{BC}(p,q)$ (which is Corollary 7.2), thereby identifying the exact extremal geometry.

3. **Equality analysis.** Characterize completely the curves for which Theorem A is asymptotically tight. The Cauchy–Schwarz equality condition $|v_i| = c\,p_i$ combined with $\sum_i v_i = 0$ suggests that near-tightness forces the curve to be, to leading order, an infinitesimal two-point excursion — exactly the family of Section 4.

4. **Curvature refinements.** The image of the simplex in the sphere is a totally geodesic positively curved region. Second-order (Bishop–Gromov-type) refinements of the chord bound, quantifying the deficit $\tfrac12 L - \|\Phi(p(b))-\Phi(p(a))\|_2$ in terms of the turning of the curve, would sharpen Theorem 5.5 into an equality with an explicit error term.

5. **Higher-order divergence bounds.** Extend the second-order overlap bound $1-\mathrm{BC}\le L^2/8$ to other $f$-divergences: for $f$-divergences whose local expansion is the Fisher metric, one expects $D_f(p(a)\|p(b)) \le c_f L^2$ with $c_f$ determined by $f''(1)$, subject to a boundedness condition preventing the blow-up of Kullback–Leibler-type divergences.

6. **Algorithmic guarantees.** Convert Theorem A into explicit stability guarantees for natural gradient and mirror descent: bound the total variation between successive model distributions by the cumulative natural-gradient norm, and combine with Theorem 7.3 to obtain per-iteration certificates that require no smoothness of the iterate sequence.

---

## 11. Conclusion

The $L^1$ distance and the Fisher–Rao metric are the flat and curved faces of the same object. We have shown that the curved face always dominates, at the level of lengths, with optimal constant $1$; that the inequality is nevertheless strict off the trivial case; that it refines through the square-root embedding into a spherical chord bound and a quadratic overlap bound; that it tensorizes Pythagoreanly; and that it persists, in exact discrete form, when all smoothness is discarded. The proof of the central inequality is a single application of Cauchy–Schwarz to the splitting $|v_i| = (|v_i|/\sqrt{p_i})\sqrt{p_i}$, made possible by the one fact that defines the simplex: probabilities sum to one.
