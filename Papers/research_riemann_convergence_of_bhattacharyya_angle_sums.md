# Riemann Convergence of Bhattacharyya Angle Sums to the Fisher–Rao Length

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

The Fisher–Rao length of a smooth path of probability vectors is defined by an
integral, $L=\int_a^b\sqrt{\sum_i \dot p_i^2/p_i}\,dt$, whereas the Bhattacharyya
angle $\theta(p,q)=\arccos\sum_i\sqrt{p_iq_i}$ is a two-point quantity. We prove
that these are two descriptions of one geometry, with the standard normalisation
and no rescaling. Specifically, for a $C^1$ path of strictly positive probability
vectors on a compact interval $[a,b]$, the partition sums
$\sum_k 2\arccos BC(p_{t_k},p_{t_{k+1}})$ converge to the Fisher–Rao length as the
mesh tends to zero; every such sum is a lower bound for the length; and the length
is the least upper bound of these sums. Consequently the Fisher–Rao length
functional *is* the length structure induced by the Bhattacharyya angle metric.
The proof is a two-sided squeeze carried out in the square-root (sphere)
embedding: the upper bound is a geodesic inequality
$2\arccos BC(p_a,p_b)\le L$, obtained by uniform subdivision, the Euclidean chord
bound, and the sharp angle-to-chord comparison $\theta\sqrt{1-(m/2)^2}\le m$; the
lower bound is a directional Cauchy–Schwarz estimate combined with uniform
continuity of the velocity of the square-root curve. We further exhibit the
optimising path in closed form — the spherical interpolation of the two
square-rooted vectors — showing that the infimum of Fisher–Rao lengths over
connecting $C^1$ paths is attained and equals $2\arccos BC(p,q)$. Thus the
Fisher–Rao distance on the open simplex is exactly twice the Bhattacharyya angle,
and the Fisher–Rao geometry is the round geometry of a sphere of radius $2$.

**Keywords:** Fisher–Rao metric, Bhattacharyya coefficient, Hellinger distance,
square-root embedding, spherical geometry, geodesic, length structure, information
geometry.

---

## 1. Introduction

### 1.1 The problem

Let $\Delta_n^{\circ}=\{p\in\mathbb{R}^n : p_i>0,\ \sum_i p_i=1\}$ be the open
probability simplex. Two ways of measuring "how far apart" its points are have
long coexisted.

The first is *infinitesimal*. The Fisher information metric assigns to a tangent
vector $v$ at $p$ the norm $\sqrt{\sum_i v_i^2/p_i}$; integrating along a path
gives the Fisher–Rao length. This is the canonical choice: by Čencov's theorem it
is, up to scale, the unique Riemannian metric on the simplex invariant under
sufficient statistics, and it governs the asymptotic distinguishability of nearby
hypotheses.

The second is *two-point and algebraic*. The Bhattacharyya coefficient
$BC(p,q)=\sum_i\sqrt{p_iq_i}$ is an affinity between distributions, and its inverse
cosine, the Bhattacharyya angle, is a similarity measure that requires no calculus
at all.

Folklore identifies the two, on the grounds that the square-root map carries the
simplex to a sphere. But the identification carries a *calibration* obligation. In
a metric space $(X,d)$ the length of a path $\gamma:[a,b]\to X$ is by definition
$$\mathrm{Len}(\gamma)=\sup_{a=t_0\le\dots\le t_N=b}\ \sum_{k}d\big(\gamma(t_k),\gamma(t_{k+1})\big),$$
the supremum of the partition sums. For the identification to hold, the Fisher–Rao
integral must equal the supremum of the Bhattacharyya angle sums *with a specific
constant*. If the correct constant were not the one implicit in the standard
definition, the Fisher–Rao length functional would have to be renormalised to be
a genuine length. This paper settles the question.

### 1.2 Results

Throughout, $p:\mathbb{R}\to\mathbb{R}^{\iota}$ (with $\iota$ a finite index set)
is a curve with everywhere-defined derivative $v(t)=\dot p(t)$, $v$ continuous,
$p_t$ strictly positive for all $t$ and $\sum_i p_t(i)=1$ for all $t$; we call such
a curve *admissible*. Our results are:

1. **Metric property (Theorem 3.3, 3.5).** $\theta(p,q)=\arccos BC(p,q)$ is a
   metric on the simplex; it is the spherical angle of the square-root
   embeddings, hence satisfies the triangle inequality, and vanishes exactly on
   the diagonal.
2. **Geodesic bound (Theorem 5.1).** For an admissible curve and $a\le b$,
   $2\arccos BC(p_a,p_b)\le L(p;a,b)$.
3. **Partition sums undershoot (Corollary 5.2).** For any increasing chain
   $T_0\le T_1\le\dots\le T_N$,
   $\sum_{k<N}2\arccos BC(p_{T_k},p_{T_{k+1}})\le L(p;T_0,T_N)$.
4. **Quantitative reverse bound (Theorem 6.2).** If the velocity of the
   square-root curve varies by at most $e$ on each step of the partition, then
   $L(p;T_0,T_N)\le\sum_{k<N}2\arccos BC(p_{T_k},p_{T_{k+1}})+4e(T_N-T_0)$.
5. **Riemann convergence (Theorem 7.1).** For every $\varepsilon>0$ there is
   $\delta>0$ such that every partition of $[a,b]$ with mesh $<\delta$ has angle
   sum within $\varepsilon$ of $L(p;a,b)$.
6. **Least upper bound (Theorem 7.2).** $L(p;a,b)$ is the least upper bound of the
   set of Bhattacharyya angle sums over all increasing partitions of $[a,b]$;
   i.e. the Fisher–Rao length *is* the induced length of the angle metric, with
   no renormalisation.
7. **Sharpness and closed-form geodesic (Theorems 8.5, 8.6).** For distinct
   strictly positive $p,q$ there is an admissible curve on $[0,1]$ from $p$ to $q$
   of Fisher–Rao length exactly $2\arccos BC(p,q)$; hence the infimum of
   Fisher–Rao lengths over connecting curves is attained and equals
   $2\arccos BC(p,q)$.

### 1.3 Method, and one road not taken

The natural first attempt at the geodesic bound is to differentiate
$t\mapsto\arccos\langle x_t,x_a\rangle$, where $x_t=\sqrt{p_t}$, and integrate the
resulting bound. The statement is true but the argument is delicate: the derivative
of $\arccos$ is singular at $\pm1$, precisely where the inner product sits at
$t=a$, and where it may return. We instead avoid the singularity entirely by a
subdivision argument that only ever uses the *Euclidean* chord bound plus a sharp
chord-to-angle comparison whose distortion constant tends to $1$. It is worth
emphasising that the Euclidean chord bound alone is insufficient: the chord is
strictly smaller than the arc, and without a comparison constant converging to $1$
the subdivision argument does not close.

---

## 2. Definitions

**Definition 2.1 (probability vector).** A vector $p:\iota\to\mathbb{R}$ on a
finite index set $\iota$ is a *probability vector* if $p_i\ge0$ for all $i$ and
$\sum_i p_i=1$; it is *strictly positive* if $p_i>0$ for all $i$.

**Definition 2.2 (Fisher–Rao speed).** For a strictly positive $P$ and a tangent
vector $V$,
$$s(P,V)\;=\;\sqrt{\ \sum_i \frac{V_i^2}{P_i}\ }\ \ \ge 0 .$$

**Definition 2.3 (Fisher–Rao length).** For a curve $p$ with velocity field $v$,
$$L(p,v;a,b)\;=\;\int_a^b s\big(p_t,v_t\big)\,dt .$$
When $v$ is understood we write $L(p;a,b)$. For admissible curves $s(p_t,v_t)$ is
continuous, so the integral exists; $L$ is nonnegative for $a\le b$ and additive,
$L(p;a,b)+L(p;b,c)=L(p;a,c)$.

**Definition 2.4 (Bhattacharyya coefficient and angle).** For probability vectors
$p,q$,
$$BC(p,q)=\sum_i\sqrt{p_iq_i},\qquad \theta(p,q)=\arccos BC(p,q)\in[0,\tfrac{\pi}{2}].$$
$BC$ is symmetric, nonnegative, and $BC(p,p)=1$.

**Definition 2.5 (square-root embedding).** $\Phi(p)=\big(\sqrt{p_i}\big)_i\in\mathbb{R}^{\iota}$,
with $\mathbb{R}^{\iota}$ carrying the Euclidean inner product.

**Definition 2.6 (square-root velocity).** For an admissible curve, the velocity of
the embedded curve $x_t=\Phi(p_t)$ has coordinates
$$w_t(i)\;=\;\frac{v_t(i)}{2\sqrt{p_t(i)}} .$$
This is legitimate: $\sqrt{\cdot}$ is differentiable away from $0$ and $p_t(i)>0$,
so $\frac{d}{dt}\sqrt{p_t(i)}=w_t(i)$, and $w$ is continuous in $t$.

**Definition 2.7 (partition angle sums).** For a curve $p$ and $a\le b$,
$$\mathcal{S}(p;a,b)=\Big\{\ \textstyle\sum_{k<N}2\arccos BC(p_{T_k},p_{T_{k+1}})\ :\ N\in\mathbb{N},\ T_0=a,\ T_N=b,\ T_k\le T_{k+1}\ \Big\}.$$

---

## 3. The square-root sphere

**Lemma 3.1 (inner product and norm).** For probability vectors $p,q$,
$$\langle\Phi(p),\Phi(q)\rangle = BC(p,q),\qquad \|\Phi(p)\|=1 .$$

*Proof.* $\langle\Phi(p),\Phi(q)\rangle=\sum_i\sqrt{p_i}\sqrt{q_i}=\sum_i\sqrt{p_iq_i}=BC(p,q)$
by $\sqrt{a}\sqrt{b}=\sqrt{ab}$ for $a,b\ge0$; and $\|\Phi(p)\|^2=\sum_i p_i=1$. $\square$

**Lemma 3.2 (polarisation).** For probability vectors $p,q$,
$$\sum_i\big(\sqrt{p_i}-\sqrt{q_i}\big)^2 \;=\; 2 - 2\,BC(p,q).$$
Consequently $BC(p,q)\le1$, with equality iff $p=q$.

*Proof.* Expand and use $\sum_ip_i=\sum_iq_i=1$. The left side is a sum of squares,
so $2-2BC\ge0$; it vanishes iff $\sqrt{p_i}=\sqrt{q_i}$ for all $i$, i.e. $p=q$. $\square$

The quantity $\|\Phi(p)-\Phi(q)\|=\sqrt{2-2BC(p,q)}$ is the *Hellinger chord*.

**Theorem 3.3 (the Bhattacharyya angle is the spherical angle).** For probability
vectors $p,q$, the Euclidean angle between $\Phi(p)$ and $\Phi(q)$ equals
$\arccos BC(p,q)$.

*Proof.* The angle between nonzero vectors $u,w$ is
$\arccos\big(\langle u,w\rangle/(\|u\|\|w\|)\big)$; substitute Lemma 3.1. $\square$

**Theorem 3.4 (triangle inequality).** For probability vectors $p,q,r$,
$$\arccos BC(p,r)\;\le\;\arccos BC(p,q)+\arccos BC(q,r).$$

*Proof.* Angles between vectors in an inner product space obey
$\angle(u,w)\le\angle(u,z)+\angle(z,w)$; apply Theorem 3.3. $\square$

**Theorem 3.5 (metric).** $\theta=\arccos BC$ is a metric on the simplex:
symmetric, nonnegative, satisfying the triangle inequality, and $\theta(p,q)=0$ iff
$p=q$.

*Proof.* Symmetry and nonnegativity are immediate. Triangle inequality is
Theorem 3.4. Finally $\arccos BC(p,q)=0$ iff $BC(p,q)\ge1$, which by Lemma 3.2
means $BC(p,q)=1$, which holds iff $p=q$. $\square$

**Corollary 3.6 (path form).** For any finite family $P_0,\dots,P_N$ of probability
vectors,
$$\arccos BC(P_0,P_N)\;\le\;\sum_{k<N}\arccos BC(P_k,P_{k+1}).$$

*Proof.* Induction on $N$: the case $N=0$ reads $\arccos BC(P_0,P_0)=\arccos 1=0$,
and the inductive step is Theorem 3.4. $\square$

---

## 4. Chords versus arcs

The three comparison inequalities of this section are the engine of the whole
argument.

**Theorem 4.1 (exact chord/angle relation).** For probability vectors $p,q$, with
$\theta=\arccos BC(p,q)$,
$$\big\|\Phi(p)-\Phi(q)\big\| \;=\; 2\sin(\theta/2).$$

*Proof.* By Lemma 3.2 the squared chord is $2-2BC(p,q)=2-2\cos\theta$, since
$\cos\arccos x=x$ for $x\in[-1,1]$ and $0\le BC\le1$. The half-angle identity
$\cos\theta=1-2\sin^2(\theta/2)$ turns this into $4\sin^2(\theta/2)$. Since
$\theta\in[0,\pi]$ we have $\sin(\theta/2)\ge0$, so the square root is
$2\sin(\theta/2)$. $\square$

**Corollary 4.2 (chord $\le$ arc).** $\|\Phi(p)-\Phi(q)\|\le\arccos BC(p,q)$.

*Proof.* $\sin x\le x$ for $x\ge0$, applied at $x=\theta/2$, then doubled. $\square$

**Lemma 4.3 (tangent inequality).** For $x\in[0,\pi/2]$, $x\cos x\le \sin x$.

*Proof.* For $x=0$ and $x=\pi/2$ both sides are equal ($0$ and $1$ respectively,
after evaluation). For $0<x<\pi/2$ we have $\cos x>0$ and the classical inequality
$x<\tan x=\sin x/\cos x$; multiply by $\cos x$. $\square$

**Theorem 4.4 (sharp arc-to-chord converse).** Let $\theta\in[0,\pi]$ and $s\ge0$
with $\sin(\theta/2)\le s$. Then
$$\theta\sqrt{1-s^2}\;\le\;2s .$$

*Proof.* Write $x=\theta/2\in[0,\pi/2]$, so $\sin x\le s$ and hence
$\cos^2x=1-\sin^2x\ge1-s^2$; as $\cos x\ge0$ on $[0,\pi/2]$ this gives
$\sqrt{1-s^2}\le\cos x$. By Lemma 4.3, $x\cos x\le\sin x\le s$. Since $x\ge0$ and
$\sqrt{1-s^2}\le\cos x$, we get $x\sqrt{1-s^2}\le x\cos x\le s$; multiply by $2$. $\square$

**Corollary 4.5 (a short chord forces a small angle).** If
$\|\Phi(p)-\Phi(q)\|\le m$ with $m\ge0$, then
$$\arccos BC(p,q)\cdot\sqrt{1-(m/2)^2}\;\le\;m .$$

*Proof.* By Theorem 4.1, $2\sin(\theta/2)\le m$, i.e. $\sin(\theta/2)\le m/2$;
apply Theorem 4.4 with $s=m/2$. $\square$

Together, Corollary 4.2 and Corollary 4.5 sandwich the arc between the chord and
$m/\sqrt{1-(m/2)^2}$: arc and chord agree to first order, with an explicit and
sharp distortion constant tending to $1$ as $m\to0$. This is the quantitative form
of the classical statement that the Hellinger and Fisher–Rao distances are
first-order equivalent.

---

## 5. The geodesic bound

**Lemma 5.0 (speed of the square-root curve).** For an admissible curve,
$$\|w_t\|\;=\;\sqrt{\sum_i w_t(i)^2}\;=\;\tfrac12\, s(p_t,v_t),$$
and $t\mapsto w_t$ is continuous. Moreover, the Euclidean chord of the square-root
curve is at most half the Fisher–Rao length:
$$\big\|\Phi(p_t)-\Phi(p_s)\big\|\;\le\;\tfrac12 L(p;s,t)\qquad(s\le t).$$

*Proof.* The identity $\|w_t\|=\frac12 s(p_t,v_t)$ is immediate from
$w_t(i)=v_t(i)/(2\sqrt{p_t(i)})$. Continuity follows from continuity of $v$ and
positivity and continuity of $p$. The chord bound is the standard Euclidean
estimate $\|\int_s^t w_r\,dr\|\le\int_s^t\|w_r\|\,dr$ applied to the square-root
curve, whose displacement is $\int_s^t w_r\,dr$ by the fundamental theorem of
calculus. $\square$

**Lemma 5.0' (speed bound integrates).** If $s(p_r,v_r)\le M$ for all
$r\in[s,t]$ with $s\le t$, then $L(p;s,t)\le M(t-s)$.

*Proof.* Monotonicity of the integral. $\square$

**Theorem 5.1 (geodesic bound).** Let $p$ be admissible and $a\le b$. Then
$$2\arccos BC(p_a,p_b)\;\le\;L(p;a,b).$$

*Proof.* Write $\theta=\arccos BC(p_a,p_b)\ge0$ and $L=L(p;a,b)\ge0$. Since
$r\mapsto s(p_r,v_r)$ is continuous on the compact interval $[a,b]$, it attains a
maximum $M\ge0$ there.

Fix $N\ge1$ and set $h=(b-a)/N$, $T_k=a+kh$, so $T_0=a$, $T_N=b$ and
$T_{k+1}-T_k=h$. Write $L_k=L(p;T_k,T_{k+1})\ge0$; by Lemma 5.0' and $s\le M$ on
$[a,b]$ we have $L_k\le Mh$, and by additivity $\sum_{k<N}L_k=L$.

On the $k$-th piece, Lemma 5.0 gives the chord bound
$\|\Phi(p_{T_{k+1}})-\Phi(p_{T_k})\|\le L_k/2$, and Corollary 4.5 with $m=L_k/2$
gives
$$\theta_k\sqrt{1-(L_k/4)^2}\;\le\;L_k/2,\qquad \theta_k:=\arccos BC(p_{T_k},p_{T_{k+1}}).$$
Since $0\le L_k\le Mh$, the constant $c:=\sqrt{1-(Mh/4)^2}$ satisfies
$c\le\sqrt{1-(L_k/4)^2}$ (both radicands being nonnegative once $N$ is large enough
that $Mh\le4$; for smaller $N$ the inequality below is vacuous under the convention
$\sqrt{x}=0$ for $x<0$). Hence $\theta_k c\le L_k/2$ for every $k$.

Summing and applying the spherical triangle inequality (Corollary 3.6),
$$\theta\, c\;\le\;\Big(\sum_{k<N}\theta_k\Big)c\;=\;\sum_{k<N}\theta_k c\;\le\;\sum_{k<N}\frac{L_k}{2}\;=\;\frac{L}{2}.$$

Now let $N\to\infty$. Then $h=(b-a)/N\to0$, hence $c=\sqrt{1-(Mh/4)^2}\to1$, and
the left-hand side tends to $\theta$. Passing to the limit in the inequality gives
$\theta\le L/2$, i.e. $2\theta\le L$. $\square$

**Corollary 5.2 (every partition sum undershoots).** For an admissible curve and
any chain $T_0\le T_1\le\dots\le T_N$,
$$\sum_{k<N}2\arccos BC\big(p_{T_k},p_{T_{k+1}}\big)\;\le\;L(p;T_0,T_N).$$

*Proof.* Apply Theorem 5.1 on each $[T_k,T_{k+1}]$ and sum, using additivity of
$L$ along the chain. $\square$

---

## 6. The reverse bound for fine partitions

**Theorem 6.1 (one step).** Let $p$ be admissible, $s\le t$, $e\ge0$, and suppose
$\|w_r-w_s\|\le e$ for all $r\in[s,t]$. Then
$$\tfrac12 L(p;s,t)\;-\;2e(t-s)\;\le\;\big\|\Phi(p_t)-\Phi(p_s)\big\| .$$

*Proof.* Let $n=\|w_s\|$. For $r\in[s,t]$, the triangle inequality gives
$\|w_r\|\le n+e$, hence by Lemma 5.0 $s(p_r,v_r)=2\|w_r\|\le 2(n+e)$, and by
Lemma 5.0'
$$L(p;s,t)\;\le\;2(n+e)(t-s).\tag{6.1}$$

Next we bound the chord from below by $(n-e)(t-s)$. If $n=0$ then $(n-e)(t-s)\le0$
and the claim is trivial. Otherwise put $u=w_s/n$, a unit vector, and consider the
scalar test function $g(r)=\langle u,\Phi(p_r)\rangle=\sum_i u_i\sqrt{p_r(i)}$. It
is differentiable with $g'(r)=\langle u,w_r\rangle$, which is continuous, so by the
fundamental theorem of calculus
$$g(t)-g(s)=\int_s^t\langle u,w_r\rangle\,dr .$$
For the integrand, $\langle u,w_r\rangle=\langle u,w_s\rangle+\langle u,w_r-w_s\rangle
= n+\langle u,w_r-w_s\rangle\ge n-\|w_r-w_s\|\ge n-e$ by Cauchy–Schwarz. Hence
$$g(t)-g(s)\;\ge\;(n-e)(t-s).$$
On the other hand, again by Cauchy–Schwarz with the unit vector $u$,
$$g(t)-g(s)=\big\langle u,\Phi(p_t)-\Phi(p_s)\big\rangle\;\le\;\big\|\Phi(p_t)-\Phi(p_s)\big\| .$$
Combining,
$$(n-e)(t-s)\;\le\;\big\|\Phi(p_t)-\Phi(p_s)\big\| .\tag{6.2}$$

Finally, from (6.1), $\tfrac12L(p;s,t)\le(n+e)(t-s)=(n-e)(t-s)+2e(t-s)$, and by
(6.2) the first term is at most the chord. $\square$

**Theorem 6.2 (reverse partition bound).** Let $p$ be admissible, $T_0\le\dots\le T_N$,
$e\ge0$, and suppose that for each $k<N$ and each $r\in[T_k,T_{k+1}]$ one has
$\|w_r-w_{T_k}\|\le e$. Then
$$L(p;T_0,T_N)\;\le\;\sum_{k<N}2\arccos BC\big(p_{T_k},p_{T_{k+1}}\big)\;+\;4e\,(T_N-T_0).$$

*Proof.* Fix $k$. Theorem 6.1 on $[T_k,T_{k+1}]$ gives
$\tfrac12L_k-2e(T_{k+1}-T_k)\le\|\Phi(p_{T_{k+1}})-\Phi(p_{T_k})\|$, and
Corollary 4.2 bounds the chord by $\theta_k$. Hence
$$L_k\;\le\;2\theta_k+4e(T_{k+1}-T_k).$$
Sum over $k<N$, use additivity $\sum_kL_k=L(p;T_0,T_N)$ and the telescoping
$\sum_k(T_{k+1}-T_k)=T_N-T_0$. $\square$

---

## 7. Calibration

**Theorem 7.1 (Riemann convergence of Bhattacharyya angle sums).** Let $p$ be
admissible, $a\le b$, $\varepsilon>0$. Then there exists $\delta>0$ such that for
every $N$ and every chain $T_0=a\le T_1\le\dots\le T_N=b$ with
$T_{k+1}-T_k<\delta$ for all $k<N$,
$$\Big|\ \sum_{k<N}2\arccos BC\big(p_{T_k},p_{T_{k+1}}\big)\;-\;L(p;a,b)\ \Big|\;\le\;\varepsilon .$$

*Proof.* Set $e=\varepsilon/(4(b-a)+1)>0$. The map $r\mapsto w_r$ is continuous
(Lemma 5.0), hence uniformly continuous on the compact interval $[a,b]$: there is
$\delta>0$ with $\|w_r-w_{r'}\|<e$ whenever $r,r'\in[a,b]$ and $|r-r'|<\delta$.

Let $T$ be a chain as in the statement. Monotonicity of $T$ and $T_0=a$, $T_N=b$
put every $T_k$ in $[a,b]$, and hence every $r\in[T_k,T_{k+1}]$ in $[a,b]$; if the
step is shorter than $\delta$ then $|r-T_k|<\delta$, so $\|w_r-w_{T_k}\|\le e$.

The upper bound $\sum_k2\theta_k\le L(p;a,b)$ is Corollary 5.2 (valid for every
partition, fine or not). The lower bound is Theorem 6.2:
$L(p;a,b)\le\sum_k2\theta_k+4e(b-a)$. Finally
$$4e(b-a)=\frac{4\varepsilon(b-a)}{4(b-a)+1}\le\varepsilon ,$$
since $4(b-a)\le4(b-a)+1$ and $\varepsilon>0$. Both inequalities together give the
claim. $\square$

**Theorem 7.2 (the Fisher–Rao length is the induced length).** Let $p$ be
admissible and $a\le b$. Then $L(p;a,b)$ is the least upper bound of the set
$\mathcal{S}(p;a,b)$ of Bhattacharyya angle sums of increasing partitions of
$[a,b]$.

*Proof.* $L$ is an upper bound by Corollary 5.2. Suppose $c$ were a smaller upper
bound, $c<L$. Apply Theorem 7.1 with $\varepsilon=(L-c)/2>0$ to get $\delta>0$.
Choose $N$ with $N>\max\{(b-a)/\delta,\,1\}$ and take the uniform partition
$T_k=a+k(b-a)/N$, whose mesh $h=(b-a)/N<\delta$. Its angle sum $\Sigma$ lies in
$\mathcal{S}(p;a,b)$, hence $\Sigma\le c$; but Theorem 7.1 gives
$\Sigma\ge L-\varepsilon=(L+c)/2>c$, a contradiction. $\square$

Theorem 7.2 is the calibration statement: it says that with the factor $2$, and
only with the factor $2$, the Fisher–Rao length coincides with the metric-space
length induced by the Bhattacharyya angle. The origin of the factor is
Lemma 5.0: the square-root curve moves at half the Fisher–Rao speed, so the
Fisher–Rao geometry is the round geometry of the sphere of radius $2$.

---

## 8. Sharpness: the closed-form geodesic

We now show that the bound of Theorem 5.1 is attained, so that the Fisher–Rao
*distance* is exactly $2\arccos BC$.

Fix strictly positive probability vectors $p,q$ with $BC(p,q)<1$ (i.e. $p\ne q$),
and set $\theta=\arccos BC(p,q)\in(0,\pi/2]$, so $\sin\theta>0$.

**Definition 8.1 (spherical interpolation).** For $t\in\mathbb{R}$ put
$$x(t)_i=\frac{\sin\big((1-t)\theta\big)\sqrt{p_i}+\sin(t\theta)\sqrt{q_i}}{\sin\theta},
\qquad P(t)_i=x(t)_i^{\,2},$$
$$\dot x(t)_i=\theta\cdot\frac{-\cos\big((1-t)\theta\big)\sqrt{p_i}+\cos(t\theta)\sqrt{q_i}}{\sin\theta},
\qquad V(t)_i=2\,x(t)_i\,\dot x(t)_i .$$

**Lemma 8.2 (two trigonometric identities).** For all $u,w$,
$$\sin^2u+2\sin u\sin w\cos(u+w)+\sin^2w=\sin^2(u+w),$$
$$\cos^2u-2\cos u\cos w\cos(u+w)+\cos^2w=\sin^2(u+w).$$

*Proof.* Expand $\sin(u+w)$ and $\cos(u+w)$ by the addition formulas and reduce
using $\sin^2+\cos^2=1$ in each variable. $\square$

**Lemma 8.3 (quadratic expansion).** For any $\alpha,\beta\in\mathbb{R}$ and
probability vectors $p,q$,
$$\sum_i\big(\alpha\sqrt{p_i}+\beta\sqrt{q_i}\big)^2=\alpha^2+2\alpha\beta\,BC(p,q)+\beta^2 .$$

*Proof.* Expand termwise and use $\sum_ip_i=\sum_iq_i=1$ and
$\sum_i\sqrt{p_iq_i}=BC(p,q)$. $\square$

**Theorem 8.4 (the arc is an admissible curve from $p$ to $q$ of constant speed
$2\theta$).** With the notation above:

1. $P(0)=p$ and $P(1)=q$;
2. $\sum_iP(t)_i=1$ for every $t$;
3. $P(t)_i>0$ for every $t\in[0,1]$ and every $i$;
4. $\dot P(t)_i=V(t)_i$, with $V$ continuous;
5. $s\big(P(t),V(t)\big)=2\theta$ for every $t\in[0,1]$;
6. $L\big(P;0,1\big)=2\theta$.

*Proof.* (1) At $t=0$ the numerator of $x$ is $\sin\theta\sqrt{p_i}$, so
$x(0)_i=\sqrt{p_i}$ and $P(0)_i=p_i$; symmetrically at $t=1$.

(2) By Lemma 8.3 with $\alpha=\sin((1-t)\theta)$, $\beta=\sin(t\theta)$ and
$BC(p,q)=\cos\theta$,
$$\sum_i x(t)_i^2=\frac{\sin^2((1-t)\theta)+2\sin((1-t)\theta)\sin(t\theta)\cos\theta+\sin^2(t\theta)}{\sin^2\theta}=1,$$
using the first identity of Lemma 8.2 with $u=(1-t)\theta$, $w=t\theta$, so
$u+w=\theta$.

(3) For $t\in[0,1]$ both $(1-t)\theta$ and $t\theta$ lie in $[0,\theta]\subseteq[0,\pi]$,
so both sines are $\ge0$, and at least one is $>0$ (if $t\le\frac12$ then
$(1-t)\theta\in(0,\pi)$; otherwise $t\theta\in(0,\pi)$). With
$\sqrt{p_i},\sqrt{q_i}>0$ the numerator of $x(t)_i$ is strictly positive, hence
$P(t)_i=x(t)_i^2>0$.

(4) Differentiate: $\frac{d}{dt}\sin((1-t)\theta)=-\theta\cos((1-t)\theta)$,
$\frac{d}{dt}\sin(t\theta)=\theta\cos(t\theta)$, giving $\dot x$ as stated; then
$P=x^2$ gives $\dot P=2x\dot x=V$ by the chain rule. Continuity of $V$ is clear.

(5) Since $P(t)_i=x(t)_i^2>0$ and $V(t)_i=2x(t)_i\dot x(t)_i$,
$$\frac{V(t)_i^2}{P(t)_i}=\frac{4x(t)_i^2\dot x(t)_i^2}{x(t)_i^2}=4\dot x(t)_i^2 .$$
By Lemma 8.3 with $\alpha=-\cos((1-t)\theta)$, $\beta=\cos(t\theta)$ and the second
identity of Lemma 8.2,
$$\sum_i\dot x(t)_i^2=\frac{\theta^2\big(\cos^2((1-t)\theta)-2\cos((1-t)\theta)\cos(t\theta)\cos\theta+\cos^2(t\theta)\big)}{\sin^2\theta}=\theta^2 .$$
Hence $s(P(t),V(t))=\sqrt{4\theta^2}=2\theta$.

(6) Integrate the constant speed over $[0,1]$. $\square$

To satisfy global hypotheses (positivity for all $t\in\mathbb{R}$, not only on
$[0,1]$) one may precompose with the reparametrisation
$\sigma(t)=\tfrac12\big(1-\cos(\pi t)\big)$, which maps $\mathbb{R}$ into $[0,1]$
with $\sigma(0)=0$, $\sigma(1)=1$, $\sigma'(t)=\tfrac{\pi}{2}\sin(\pi t)\ge0$ on
$[0,1]$. Since the Fisher–Rao speed is positively homogeneous in the velocity,
$s(P,cV)=|c|\,s(P,V)$, the reparametrised curve has speed $2\theta\,\sigma'(t)$ and
therefore length $2\theta\big(\sigma(1)-\sigma(0)\big)=2\theta$ again.

**Theorem 8.5 (geodesic realisation).** Any two distinct strictly positive
probability vectors $p,q$ are joined by an admissible curve on $[0,1]$ whose
Fisher–Rao length equals exactly $2\arccos BC(p,q)$.

*Proof.* Theorem 8.4 together with the reparametrisation above. $\square$

**Theorem 8.6 (the Fisher–Rao distance).** For strictly positive probability
vectors $p,q$, let
$$\mathcal{L}(p,q)=\big\{L(P;0,1)\ :\ P\ \text{admissible},\ P(0)=p,\ P(1)=q\big\}.$$
Then $2\arccos BC(p,q)$ is the greatest lower bound of $\mathcal{L}(p,q)$, and it
belongs to $\mathcal{L}(p,q)$.

*Proof.* It is a lower bound by Theorem 5.1. It is attained: if $p\ne q$ by
Theorem 8.5; if $p=q$ then $BC=1$, $2\arccos BC=0$, and the constant curve has
length $0$. An attained lower bound is the greatest lower bound. $\square$

Thus the metric space $(\Delta_n^{\circ},\ \text{Fisher–Rao distance})$ is
isometric to the positive orthant of the sphere of radius $2$ with its intrinsic
(great-circle) distance, via $p\mapsto2\Phi(p)$.

---

## 9. Algorithms

The results above translate into short, numerically robust procedures.

**Algorithm A (exact Fisher–Rao distance).** Given strictly positive probability
vectors $p,q$: compute $B=\sum_i\sqrt{p_iq_i}$, clamp to $[-1,1]$ against rounding,
return $2\arccos B$. Cost: $O(n)$. For $B$ near $1$, $\arccos$ loses precision; a
numerically superior route uses the Hellinger chord
$m=\|\Phi(p)-\Phi(q)\|=\sqrt{\sum_i(\sqrt{p_i}-\sqrt{q_i})^2}$ and
$\theta=2\arcsin(m/2)$, which is stable for small $\theta$ because the chord is
computed by differences rather than by cancellation in $1-B$.

**Algorithm B (geodesic interpolation).** Given $p,q$ and $t\in[0,1]$, compute
$\theta$ by Algorithm A (halved) and return $P(t)_i=x(t)_i^2$ with $x(t)$ as in
Definition 8.1; for $\theta$ below a tolerance, fall back on the limiting linear
interpolation $x(t)=(1-t)\sqrt{p}+t\sqrt{q}$, renormalised. Cost: $O(n)$. This is
the statistically natural interpolation between two distributions; it differs from
componentwise linear interpolation, which is not a Fisher–Rao geodesic.

**Algorithm C (discrete path length).** Given samples $p_{t_0},\dots,p_{t_N}$ of a
path, return $\sum_k2\arccos BC(p_{t_k},p_{t_{k+1}})$. By Corollary 5.2 this is
always a *lower* bound for the true Fisher–Rao length, and by Theorem 7.1 it
converges to it as the sampling is refined; by the triangle inequality it is
monotone under refinement. Cost: $O(Nn)$.

**Algorithm D (certified two-sided bracket).** Given samples with mesh $h$ and an
estimate $e$ of the modulus of continuity of the square-root velocity on each step,
return the bracket $[\Sigma,\ \Sigma+4e(b-a)]$, which by Corollary 5.2 and
Theorem 6.2 provably contains the Fisher–Rao length.

---

## 10. Applications and discussion

**Closed-form geometry for statistics.** The Fisher–Rao distance on a finite
simplex is now a two-line computation rather than a boundary value problem, and
the optimal path is explicit. Interpolating between distributions along the
great-circle arc, rather than linearly, respects invariance under reparametrisation
of the sample space and avoids the pathologies of linear blending near the
boundary of the simplex.

**Consistent estimation of trajectory length.** Anywhere a distribution evolves —
a Bayesian posterior under streaming data, an output distribution during training,
allele frequencies across generations, a mixture weight vector in a tracking
filter — the total intrinsic change of the trajectory is the Fisher–Rao length, and
Algorithm C computes it from samples with a guaranteed one-sided error and
guaranteed convergence. Because the estimate is monotone under refinement, doubling
the sampling rate can only improve it, which makes convergence diagnostics trivial.

**Unification of three classical quantities.** The Bhattacharyya coefficient, the
Hellinger distance and the Fisher–Rao length are now, respectively, the inner
product, the chord and the arc of one sphere. In particular the inequalities of
Section 4 give sharp explicit constants for the classical comparison
$$H\;\le\;\theta\;\le\;\frac{H}{\sqrt{1-(H/2)^2}},\qquad H:=\|\Phi(p)-\Phi(q)\|=2\sin(\theta/2),$$
where $H$ is the Hellinger chord and $\theta$ the Bhattacharyya angle (half the
Fisher–Rao distance) — a two-sided comparison valid for all pairs, not merely
asymptotically.

**On the sharpness of the argument.** Two negative observations shaped the proof.
First, the differentiation route through $t\mapsto\arccos\langle x_t,x_a\rangle$ is
true but singular at the endpoints of the range of the inner product; the
subdivision route avoids it. Second, the Euclidean chord bound alone does not give
the geodesic bound — a chord is genuinely shorter than an arc — and the missing
ingredient is exactly the sharp converse of Corollary 4.5, whose distortion
constant tends to $1$ as the pieces shrink.

**Scope.** All results are stated for finitely supported distributions with
strictly positive masses. Positivity is essential to the differentiability of the
square-root curve, and hence to the definition of the Fisher–Rao speed; the sphere
picture itself extends to the closed simplex, and the angle metric is defined and
is a metric there, but the length theory requires the interior.

---

## 11. Future directions

**Curvature-corrected discrete length (Bhattacharyya angle defect).** For a $C^3$
path of positive probability vectors, the deficit of the uniform partition sum
should obey
$$L-\sum_k2\arccos BC(p_{t_k},p_{t_{k+1}})=\frac{h^2}{24}\int_a^b\|\kappa\|^2s^3\,dt+O(h^3),$$
where $h$ is the mesh, $s$ is the Fisher–Rao speed and $\kappa$ the geodesic
curvature of the square-root curve on the sphere. The insight is that the per-step
error of a spherical chord is governed by the curvature of the arc, so the
second-order term of the Riemann deficit should be a curvature functional rather
than a bare $O(h^2)$. Numerics already exhibit a clean $\Theta(h^2)$ deficit with a
stable constant, and the exact geodesic — zero curvature, zero deficit — provides
both the model case and the machinery for computing the correction.

**Fisher–Rao length as the variation of the angle metric.** For an arbitrary
rectifiable path of probability vectors, one expects the total variation of the
path in the Bhattacharyya angle metric to coincide with the Fisher–Rao length
whenever the latter is defined, and to be finite exactly for absolutely continuous
paths with square-integrable Fisher–Rao speed. The least-upper-bound
characterisation of Theorem 7.2 is the bridge: it is stated purely in metric terms,
with no reference to derivatives, and is therefore the correct definition to carry
into the non-smooth setting.

**Beyond the simplex.** The same square-root device sends a dominated family of
densities into the unit sphere of $L^2$; the arguments of Sections 4–7 are
coordinate-free except for the use of finite sums, and should extend to that
setting with the Hilbert-space chord replacing the Euclidean one. The boundary case
$BC(p,q)=0$ (mutually singular distributions, angle $\pi/2$, Fisher–Rao distance
$\pi$) marks the diameter of the space, and understanding degeneration towards the
boundary of the simplex is the natural next question.

---

## 12. Summary

The square-root embedding is not an analogy but an isometry: the open probability
simplex with the Fisher–Rao metric is the positive orthant of the sphere of radius
$2$. Concretely,

* the Bhattacharyya angle $\arccos BC(p,q)$ is a metric — the spherical angle;
* every partition of a $C^1$ path yields an angle sum
  $\sum_k2\arccos BC(p_{t_k},p_{t_{k+1}})$ that underestimates the Fisher–Rao
  length;
* these sums converge to the Fisher–Rao length as the mesh tends to $0$, and their
  supremum is exactly the length — no renormalisation is needed;
* the bound $2\arccos BC(p,q)\le L$ is attained by the spherical interpolation of
  the square-rooted endpoints, so the Fisher–Rao distance is exactly
  $2\arccos BC(p,q)$.
