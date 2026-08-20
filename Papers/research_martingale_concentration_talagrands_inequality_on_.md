# Talagrand's Convex Distance Inequality on Finite Product Spaces: A Complete Development with the Optimal Constant

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We give a complete, self-contained development of Talagrand's convex distance
inequality on finite product spaces, with the classical optimal constant $1/4$ in
the exponent, for arbitrary product measures with independent — but not
necessarily identically distributed — coordinates. The central result is the
exponential moment bound
$$\mathbb{E}\big[e^{\,d_T(A,X)^2/4}\big]\cdot \mathbb{P}(A) \le 1,$$
where $d_T(A,x)$ denotes the Euclidean distance from the origin to the convex
hull of the disagreement vectors $\big(\mathbf 1[x_i\neq y_i]\big)_{i\le n}$,
$y\in A$. From it we derive the deviation inequality
$\mathbb{P}(A)\mathbb{P}(S)\le e^{-t/4}$ whenever $d_T(A,\cdot)^2\ge t$ on $S$,
the weighted Hamming form $\mathbb{P}(A)\mathbb{P}(S)\le e^{-t^2/4}$, the
concentration of $1$-Lipschitz functionals about a median with constant $2$, and
the isoperimetric statement $\mathbb{P}(A)\ge 1/2 \Rightarrow \mathbb{P}(d_T^2\ge
t)\le 2e^{-t/4}$.

Beyond the main inequality we establish: the minimax (duality) identity
$d_T(A,x) = \sup\{ d_w(A,x) : w\ge 0,\ \|w\|_2\le 1\}$, obtained from compactness
of the hull and a variational inequality at the minimum-norm point; exact
evaluations of the convex distance to a singleton and to a subcube (cylinder),
which show the distance is non-degenerate and correctly normalised; the
concentration of certifiable functionals at the *certificate* scale,
$\mathbb{P}(A)\mathbb{P}(S)\le \exp(-(m-b)^2/(4K))$; and two applications where
this scale is strictly better than bounded differences — counting ones among
arbitrarily biased independent coins at scale $\sqrt{m}$, and the length of the
longest increasing subsequence of a random word at scale $\sqrt{\ell}$.

A separate analytic layer isolates the two ingredients on which the induction
rests: a weighted Hölder inequality for finite sums, and an *interpolation
lemma* stating that for every $r\in[0,1]$ there is $\lambda\in[0,1]$ with
$e^{(1-\lambda)^2/4}r^{-\lambda}\le 2-r$. We show that the optimal choice is
$\lambda = 1+2\log r$ and that the lemma reduces to the scalar inequality
$e^{u-u^2}\le 2-e^{-u}$ on $[0,1/2]$, a third-order tangency at $u=0$ which
pinpoints the optimality of the constant $1/4$ and which we prove from explicit
quartic Taylor bounds with certified remainders.

**Keywords:** concentration of measure, convex distance, product measures,
isoperimetry, certifiable functionals, longest increasing subsequence, Hölder
interpolation.

---

## 1. Introduction

### 1.1 The problem

Let $\Omega$ be a finite alphabet and let $X = (X_1,\dots,X_n)$ be independent
random variables with $X_i \sim \mu_i$ on $\Omega$. The concentration problem
asks: for which functions $f:\Omega^n\to\mathbb R$ is $f(X)$ tightly clustered
about a central value, and on what scale?

The classical answer, the bounded differences (Azuma–Hoeffding–McDiarmid)
inequality, states that if changing a single coordinate changes $f$ by at most
$c_i$, then $\mathbb{P}(|f - \mathbb{E}f| \ge t) \le 2\exp(-2t^2/\sum_i c_i^2)$.
The scale is $\big(\sum_i c_i^2\big)^{1/2}$, typically $\sqrt n$. For many
combinatorial functionals this is the wrong scale by a polynomial factor. The
canonical example is the length $L_n$ of the longest increasing subsequence of a
uniform random word or permutation of length $n$: here $L_n \asymp \sqrt n$ and
bounded differences yields fluctuations $O(\sqrt n)$, a statement with no content.

Talagrand's convex distance inequality resolves this by replacing the fixed
per-coordinate Lipschitz budget with a geometric quantity — the Euclidean
distance from the origin to a convex hull of disagreement patterns — whose
duality theory permits the Lipschitz *witness* to be chosen anew at each point of
the space.

### 1.2 Contributions

This paper presents:

1. A proof of the convex distance inequality
   $\mathbb{E}[e^{d_T(A,X)^2/4}]\,\mathbb{P}(A)\le 1$ for arbitrary (possibly
   non-identically-distributed) finite product measures, by induction on $n$
   (Theorem 4.1);
2. A clean separation of the analytic core: the weighted Hölder inequality
   (Lemma 3.1) and the interpolation lemma with the optimal constant
   (Theorem 3.5), including the exact optimiser $\lambda = 1 + 2\log r$ and the
   third-order tangency that certifies optimality (Section 3.3);
3. The minimax identity $d_T = \sup_w d_w$ (Theorem 5.4), proved via attainment
   of the infimum and a variational inequality (Lemmas 5.1, 5.2);
4. Exact convex distances to singletons and subcubes (Theorems 5.5, 5.6);
5. Concentration for Lipschitz and for certifiable functionals (Theorems 6.1–6.4)
   and two applications at strictly better than $\sqrt n$ scale (Sections 6.3,
   6.4);
6. Algorithms for computing the convex distance and for exercising the bounds
   numerically (Section 7).

Throughout we deliberately work with the *square* $d_T^2$, since that is the
quantity carried by the induction, and with representations of hull points by
explicit finite convex combinations rather than an abstract convex-hull operator;
this makes the geometric step of the induction (Lemma 4.3) elementary.

---

## 2. Definitions

Throughout, $\Omega$ is a finite alphabet with decidable equality, $n\in\mathbb N$,
and the ambient space is $\Omega^n$, whose elements are written $x = (x_1,\dots,
x_n)$.

**Definition 2.1 (Hamming indicator).** For $u,v \in \Omega$ set
$h(u,v) = 0$ if $u = v$ and $h(u,v) = 1$ otherwise. For $x,y\in\Omega^n$ the
*disagreement vector* is $U(x,y) = \big(h(x_1,y_1),\dots,h(x_n,y_n)\big)\in
\{0,1\}^n$.

**Definition 2.2 (Squared Euclidean norm).** For $v\in\mathbb R^n$, $\ \mathrm{sq}(v)
= \sum_{i=1}^n v_i^2$.

**Definition 2.3 (Hull representation).** Let $A\subseteq\Omega^n$ be finite and
$x\in\Omega^n$. A vector $v\in\mathbb R^n$ *represents* $A$ at $x$ if there exist
$k\in\mathbb N$, weights $\alpha_1,\dots,\alpha_k\ge 0$ with $\sum_j\alpha_j = 1$,
and points $y^{(1)},\dots,y^{(k)}\in A$ with
$$v_i = \sum_{j=1}^k \alpha_j\, h\big(x_i, y^{(j)}_i\big) \qquad (1\le i\le n).$$
Equivalently — and this equivalence is used freely below — $v$ represents $A$ at
$x$ if and only if there is a weight function $\alpha : A \to [0,\infty)$ with
$\sum_{y\in A}\alpha_y = 1$ and $v_i = \sum_{y\in A}\alpha_y h(x_i,y_i)$. The two
encodings (an indexed list of points, possibly with repetitions, versus a weight
supported on $A$) define the same set of vectors: one passes from a list to a
weight by aggregating duplicates, and back by enumerating the support.

Representing vectors satisfy $0 \le v_i \le 1$ coordinatewise, being convex
combinations of $0/1$ values.

**Definition 2.4 (Convex distance).** For $A\subseteq \Omega^n$ nonempty and
$x \in\Omega^n$,
$$d_T(A,x)^2 \;=\; \inf\big\{ \mathrm{sq}(v) : v \text{ represents } A \text{ at } x\big\}.$$
We write $d_T^2(A,x)$ for this quantity; it is finite and nonnegative, and
the infimum is attained (Lemma 5.1). By convention $d_T^2(\emptyset,x)$ is the
infimum of the empty set, and all statements below either assume $A\neq\emptyset$
or handle the empty case separately.

**Definition 2.5 (Weighted Hamming distance).** For $w\in[0,\infty)^n$,
$$d_w(A,x) \;=\; \min_{y\in A}\ \sum_{i=1}^n w_i\, h(x_i,y_i).$$
A weight $w$ is *admissible* if $w\ge 0$ and $\sum_i w_i^2\le 1$.

**Definition 2.6 (Product measure).** Given weights $p_i:\Omega\to[0,\infty)$ with
$\sum_{a\in\Omega} p_i(a) = 1$ for each $i$, put
$$\mathrm{wt}(x) = \prod_{i=1}^n p_i(x_i), \qquad
\mathbb{P}(S) = \sum_{x\in S}\mathrm{wt}(x),$$
and define the exponential moment functional
$$E(A) \;=\; \sum_{x\in\Omega^n} \mathrm{wt}(x)\, e^{\,d_T^2(A,x)/4}
\;=\;\mathbb{E}\big[e^{\,d_T^2(A,X)/4}\big].$$
The measure is *i.i.d.* if all $p_i$ coincide. All results below hold in the
general, coordinate-dependent case.

**Basic properties.** $d_T^2(A,x)\ge 0$; $d_T^2(A,x) = 0$ if $x\in A$ (take the
point mass at $x$); $d_T^2(A,x) \le n$ (any single $y\in A$ gives $\mathrm{sq}(U(x,y))
\le n$); and $d_T^2$ is antitone in $A$: if $\emptyset\neq A\subseteq B$ then
$d_T^2(B,x)\le d_T^2(A,x)$, since every representation of $A$ is a representation
of $B$.

**Lemma 2.7 (Easy half of duality).** *For every admissible $w$, every nonempty
$A$ and every $x$,*
$$d_w(A,x)^2 \;\le\; d_T^2(A,x).$$

*Proof sketch.* Let $v$ represent $A$ at $x$ with weights $\alpha_y$. Then
$$\sum_i w_i v_i = \sum_{y\in A}\alpha_y \sum_i w_i h(x_i,y_i) \ \ge\
\Big(\min_{y\in A}\sum_i w_i h(x_i,y_i)\Big)\sum_y \alpha_y = d_w(A,x),$$
while Cauchy–Schwarz gives $\sum_i w_i v_i \le \|w\|_2\,\mathrm{sq}(v)^{1/2} \le
\mathrm{sq}(v)^{1/2}$. Hence $\mathrm{sq}(v)\ge d_w(A,x)^2$ for every representing $v$;
take the infimum. $\square$

---

## 3. The analytic core

Two purely analytic facts drive the induction.

### 3.1 Weighted Hölder inequality for finite sums

**Lemma 3.1 (Weighted Hölder).** *Let $S$ be a finite index set, $q,f,g:S\to
[0,\infty)$, and $\lambda\in[0,1]$. Assume $F = \sum_{i} q_i f_i > 0$ and
$G = \sum_i q_i g_i > 0$. Then*
$$\sum_{i\in S} q_i\, f_i^{\lambda} g_i^{1-\lambda} \;\le\; F^{\lambda}\,G^{1-\lambda}.$$

*Proof sketch.* Normalise: $f_i^\lambda g_i^{1-\lambda} = F^\lambda G^{1-\lambda}
\big(f_i/F\big)^\lambda\big(g_i/G\big)^{1-\lambda}$. The two-point weighted
AM–GM inequality $s^\lambda t^{1-\lambda}\le \lambda s + (1-\lambda)t$ for
$s,t\ge0$ gives
$$\big(f_i/F\big)^\lambda\big(g_i/G\big)^{1-\lambda} \le \lambda \frac{f_i}{F} +
(1-\lambda)\frac{g_i}{G}.$$
Multiplying by $q_i \ge 0$, summing, and using $\sum_i q_i f_i/F = 1 =
\sum_i q_i g_i/G$ collapses the right-hand side to $F^\lambda G^{1-\lambda}$.
$\square$

Note that no normalisation of $q$ is required; $q$ enters only through the two
sums $F$ and $G$.

### 3.2 Explicit Taylor bounds

The interpolation lemma is quantitatively tight, so it cannot be proved by soft
convexity arguments; it needs certified polynomial bounds on $e^{\pm u}$.

**Lemma 3.2.** *For $0\le t\le 1$: $\ e^{t} \le 1 + t + \tfrac34 t^2$.*

**Lemma 3.3.** *For $0\le u\le 1$: $\ e^{-u} \le 1 - u + \tfrac{u^2}{2} +
\tfrac29 u^3$.*

**Lemma 3.4.** *For $0\le t \le 1$:*
$$e^{t} \le 1 + t + \tfrac{t^2}{2} + \tfrac{t^3}{6} + \tfrac{5}{96}t^4,
\qquad
e^{-t} \le 1 - t + \tfrac{t^2}{2} - \tfrac{t^3}{6} + \tfrac{5}{96}t^4 .$$

*Proof sketch.* All four follow from the standard truncated-series bound: for
$|t|\le 1$ and $N\ge 1$,
$$\Big| e^{t} - \sum_{m<N}\frac{t^m}{m!}\Big| \;\le\; |t|^{N}\,
\frac{N+1}{N!\,N},$$
together with the sharper one-sided estimate available for $t\ge0$. Evaluating the
remainder constants at $N=2,3,4$ gives $\tfrac34$, $\tfrac29$ and $\tfrac{5}{96}$
respectively. $\square$

### 3.3 The interpolation lemma and the constant $1/4$

**Theorem 3.5 (Interpolation lemma).** *For every $r\in[0,1]$ there exists
$\lambda\in[0,1]$ with*
$$e^{(1-\lambda)^2/4}\; r^{-\lambda} \;\le\; 2 - r .$$

*Proof.* Two regimes.

*Regime 1: $r < e^{-1/2}$.* Take $\lambda = 0$. The claim is $e^{1/4}\le 2-r$.
Since $r < e^{-1/2} \le 1 - \tfrac12 + \tfrac18 + \tfrac{2}{9}\cdot\tfrac18 =
0.6528$ by Lemma 3.3 at $u = 1/2$, and $e^{1/4}\le 1 + \tfrac14 +
\tfrac34\cdot\tfrac1{16} = 1.2969$ by Lemma 3.2 at $t = 1/4$, the two numeric
bounds combine to $e^{1/4} \le 1.2969 < 1.3472 < 2 - r$.

*Regime 2: $r \ge e^{-1/2}$.* Then $r>0$; write $u = -\log r \in [0,\tfrac12]$
and take $\lambda = 1 + 2\log r = 1 - 2u \in [0,1]$. Since $(1-\lambda)^2/4 = u^2$
and $r^{-\lambda} = e^{u\lambda} = e^{u-2u^2}$, the left-hand side is exactly
$e^{u-u^2}$, and the claim becomes the scalar inequality of Theorem 3.6. $\square$

**Theorem 3.6 (Scalar heart).** *For $0\le u\le \tfrac12$,*
$$e^{\,u-u^2}\;\le\;2 - e^{-u}.$$

*Proof sketch.* Set $t = u - u^2 \in[0,1]$ for $u\in[0,\tfrac12]$ (indeed
$0\le t\le \tfrac14$). By Lemma 3.4 applied to $t$ and to $u$,
$$e^{t}\le 1+t+\tfrac{t^2}{2}+\tfrac{t^3}{6}+\tfrac{5}{96}t^4,\qquad
e^{-u}\le 1-u+\tfrac{u^2}{2}-\tfrac{u^3}{6}+\tfrac{5}{96}u^4 .$$
It therefore suffices to verify the polynomial inequality
$$\Big(1+t+\tfrac{t^2}{2}+\tfrac{t^3}{6}+\tfrac{5}{96}t^4\Big) +
\Big(1-u+\tfrac{u^2}{2}-\tfrac{u^3}{6}+\tfrac{5}{96}u^4\Big) \;\le\; 2,
\qquad t = u-u^2,$$
on $[0,\tfrac12]$. Expanding in $u$ with $t = u - u^2$, so that $t^2 = u^2-2u^3+u^4$
and $t^3 = u^3 + O(u^4)$, the constant, linear and quadratic terms cancel
identically, and the cubic terms combine to $-u^3$; the residual polynomial is
$-u^3 + (\text{quartic and higher})$, whose higher coefficients are dominated by
$u^3$ on $[0,\tfrac12]$. $\square$

**Proposition 3.7 (Optimality of $1/4$).** *Let $c>0$ and suppose that for every
$r\in(0,1)$ there exists $\lambda\in[0,1]$ with $e^{c(1-\lambda)^2}r^{-\lambda}\le
2-r$. Then $c\le \tfrac14$.*

*Proof.* Write $r = e^{-u}$ with $u>0$ small and $\lambda = 1-2s$, $s\in[0,\tfrac12]$.
The logarithm of the left-hand side is $4cs^2 + u(1-2s)$, a convex quadratic in
$s$ minimised at $s = u/(4c)$ (which lies in $[0,\tfrac12]$ for small $u$) with
minimum value $u - u^2/(4c)$. The logarithm of the right-hand side expands as
$$\log\big(2-e^{-u}\big) = u - u^2 + u^3 + O(u^4).$$
The hypothesis therefore requires $u - u^2/(4c) \le u - u^2 + u^3 + O(u^4)$ for
all small $u>0$, i.e. $\big(1 - \tfrac1{4c}\big)u^2 \le u^3 + O(u^4)$, which forces
$1 - \tfrac1{4c}\le 0$, i.e. $c\le\tfrac14$. $\square$

Thus the interpolation lemma holds with $c = 1/4$ and with no larger constant,
and $1/4$ enters the main theorem at exactly this one point. The two curves in
Theorem 3.6 agree to second order at $u=0$ and separate only at order $u^3$, with
gap $u^3 + O(u^4)$: the entire strength of the concentration inequality rests on
this third-order tangency.

---

## 4. The convex distance inequality

### 4.1 Statement

**Theorem 4.1 (Convex distance inequality).** *Let $p_i$, $1\le i\le n$, be
probability weights on the finite alphabet $\Omega$ and let $\mathbb{P}$ be the
associated product measure on $\Omega^n$. Then for every $A\subseteq\Omega^n$,*
$$\mathbb{E}\big[e^{\,d_T^2(A,X)/4}\big]\cdot\mathbb{P}(A)\;\le\;1 .$$
*In particular this holds in the i.i.d. case $p_1=\dots=p_n$.*

### 4.2 Sections, projections and the geometric step

Write a point of $\Omega^{n+1}$ as $(a,y)$ with $a\in\Omega$ and $y\in\Omega^n$.

**Definition 4.2.** For $A\subseteq\Omega^{n+1}$ and $a\in\Omega$:
the *section* $A_a = \{y\in\Omega^n : (a,y)\in A\}$ and the *projection*
$\Pi A = \{y \in \Omega^n : \exists b\in\Omega,\ (b,y)\in A\}$.

**Lemma 4.3 (Mixing / geometric step).** *Let $A\subseteq\Omega^{n+1}$,
$a\in\Omega$, $y\in\Omega^n$, and $\lambda\in[0,1]$. Assume $\Pi A\neq\emptyset$,
and if $\lambda\neq 0$ assume also $A_a\neq\emptyset$. Then*
$$d_T^2\big(A,(a,y)\big) \;\le\; (1-\lambda)^2 \;+\; \lambda\, d_T^2(A_a,y)
\;+\;(1-\lambda)\, d_T^2(\Pi A, y).$$

*Proof sketch.* Fix $\varepsilon>0$ and choose weights $\alpha$ on $A_a$ and
$\beta$ on $\Pi A$ whose induced vectors are within $\varepsilon$ of optimal.
Lift each of them to a weight on $A$: a point $y'\in A_a$ lifts to $(a,y')\in A$,
which agrees with $(a,y)$ in the new coordinate; a point $y'\in \Pi A$ lifts to
some $(b,y')\in A$, which may disagree in the new coordinate. Mixing with weights
$\lambda$ and $1-\lambda$ produces a legitimate representation $v$ of $A$ at
$(a,y)$ whose new coordinate is at most $1-\lambda$ and whose remaining
coordinates are $\lambda\alpha$-averages plus $(1-\lambda)\beta$-averages. Hence
$$\mathrm{sq}(v) \le (1-\lambda)^2 + \sum_{i\le n}\big(\lambda\, v^{(1)}_i +
(1-\lambda)\,v^{(2)}_i\big)^2 \le (1-\lambda)^2 + \lambda\,\mathrm{sq}(v^{(1)}) +
(1-\lambda)\,\mathrm{sq}(v^{(2)})$$
by convexity of $s\mapsto s^2$, where $v^{(1)},v^{(2)}$ are the chosen
near-optimal vectors for the section and the projection. Let $\varepsilon\to0$.
$\square$

The crucial structural feature is that the new coordinate contributes
$(1-\lambda)^2$ — quadratically — while the inductive terms appear linearly.

### 4.3 Proof of Theorem 4.1

*Base case $n=0$.* The space $\Omega^0$ is a single point. If $A=\emptyset$ then
$\mathbb{P}(A)=0$ and the product vanishes; otherwise $A$ is the whole space,
$\mathbb{P}(A)=1$ and $d_T^2 = 0$, so $E(A)\mathbb{P}(A)=1$.

*Induction step.* Assume the statement in dimension $n$ and let
$A\subseteq\Omega^{n+1}$ be nonempty (the empty case is trivial). Let $B = \Pi A$,
$q = \mathbb{P}_{n}(B) > 0$ (the induced product measure on the last $n$
coordinates), and for each $a\in\Omega$ let $s_a = \mathbb{P}_n(A_a) \le q$ and
$r_a = s_a/q \in[0,1]$. Note $\mathbb{P}(A) = \sum_a p_1(a)\, s_a$.

Fix $a$ and let $\lambda = \lambda(a)\in[0,1]$ be supplied by Theorem 3.5 for
$r = r_a$. Exponentiating Lemma 4.3 and dividing by $4$,
$$e^{\,d_T^2(A,(a,y))/4} \le e^{(1-\lambda)^2/4}\,
\big(e^{\,d_T^2(A_a,y)/4}\big)^{\lambda}\,
\big(e^{\,d_T^2(B,y)/4}\big)^{1-\lambda}.$$
Multiply by $\mathrm{wt}_n(y)$, sum over $y\in\Omega^n$, and apply Lemma 3.1 with
$q_y = \mathrm{wt}_n(y)$, $f_y = e^{d_T^2(A_a,y)/4}$, $g_y = e^{d_T^2(B,y)/4}$:
$$\sum_y \mathrm{wt}_n(y)\, e^{\,d_T^2(A,(a,y))/4} \;\le\;
e^{(1-\lambda)^2/4}\; E_n(A_a)^{\lambda}\, E_n(B)^{1-\lambda}.$$
By the induction hypothesis $E_n(A_a)\le 1/s_a$ and $E_n(B)\le 1/q$ (when
$s_a = 0$ the corresponding term is handled by the degenerate choice $\lambda=0$),
so the right-hand side is at most
$$e^{(1-\lambda)^2/4}\, s_a^{-\lambda} q^{-(1-\lambda)}
= \frac1q\, e^{(1-\lambda)^2/4}\, r_a^{-\lambda} \;\le\; \frac{2-r_a}{q},$$
the last step being precisely Theorem 3.5. Summing over the first letter with
weights $p_1(a)$,
$$E_{n+1}(A) \;\le\; \frac1q \sum_{a} p_1(a)\,(2-r_a) = \frac{2 - \theta}{q},
\qquad \theta := \sum_a p_1(a)\, r_a = \frac{\mathbb{P}(A)}{q}\in[0,1].$$
Therefore
$$E_{n+1}(A)\,\mathbb{P}(A) \le \frac{(2-\theta)}{q}\cdot \theta q =
\theta(2-\theta) = 1 - (1-\theta)^2 \le 1 . \qquad\square$$

The proof uses independence only through the factorisation
$\mathrm{wt}(a,y) = p_1(a)\,\mathrm{wt}_n(y)$, and never uses that the $p_i$ are equal.

---

## 5. Geometry of the convex distance

### 5.1 Attainment and duality

**Lemma 5.1 (Attainment).** *For $A\neq\emptyset$ finite and any $x$, the
infimum defining $d_T^2(A,x)$ is attained: there is a representing $v^\star$ with
$\mathrm{sq}(v^\star) = d_T^2(A,x)$.*

*Proof sketch.* The set of representing vectors is the image of the compact
simplex $\{\alpha\in[0,1]^A : \sum_y\alpha_y = 1\}$ under the continuous linear
map $\alpha\mapsto\big(\sum_y \alpha_y h(x_i,y_i)\big)_i$, hence compact; the
continuous function $\mathrm{sq}$ attains its minimum there. $\square$

**Lemma 5.2 (Variational inequality).** *If $v^\star$ is a minimiser as above,
then for every representing $u$,*
$$\langle v^\star, u\rangle \;\ge\; \mathrm{sq}(v^\star).$$

*Proof sketch.* For $\tau\in[0,1]$ the vector $v_\tau = (1-\tau)v^\star + \tau u$
is representing (the representing set is convex). Hence
$\mathrm{sq}(v_\tau)\ge\mathrm{sq}(v^\star)$, i.e.
$2\tau\langle v^\star, u - v^\star\rangle + \tau^2\,\mathrm{sq}(u-v^\star)\ge0$.
Dividing by $\tau$ and letting $\tau\downarrow0$ gives
$\langle v^\star,u\rangle\ge \mathrm{sq}(v^\star)$. $\square$

**Theorem 5.3 (Hard half of duality).** *For $A\neq\emptyset$ and any $x$ there
exists an admissible $w$ (i.e. $w\ge0$, $\sum_i w_i^2\le1$) with*
$$d_T^2(A,x) \;\le\; d_w(A,x)^2 .$$

*Proof sketch.* If $d_T^2(A,x) = 0$ take $w=0$. Otherwise let $v^\star$ be the
minimiser, put $w = v^\star/\|v^\star\|_2$ (which is nonnegative, as representing
vectors are), and apply Lemma 5.2 to $u = U(x,y)$ for each $y\in A$:
$$\sum_i w_i h(x_i,y_i) = \frac{\langle v^\star, U(x,y)\rangle}{\|v^\star\|_2}
\ \ge\ \frac{\mathrm{sq}(v^\star)}{\|v^\star\|_2} = \|v^\star\|_2 = d_T(A,x).$$
Taking the minimum over $y\in A$ gives $d_w(A,x)\ge d_T(A,x)$. $\square$

**Theorem 5.4 (Minimax identity).** *For $A\neq\emptyset$ and any $x$,*
$$d_T(A,x) \;=\; \sup\big\{\, d_w(A,x)\ :\ w\ge0,\ \textstyle\sum_i w_i^2\le 1\,\big\},$$
*equivalently $d_T^2(A,x) = \big(\sup_w d_w(A,x)\big)^2$, and the supremum is
attained.*

*Proof.* Lemma 2.7 gives "$\ge$" for every admissible $w$, so $d_T \ge \sup_w
d_w$; the supremum is over a nonempty set bounded above by $d_T$. Theorem 5.3
exhibits an admissible $w$ realising the reverse inequality. $\square$

The minimax identity is the operational form of the theory: to prove that a point
$x$ is far from $A$, exhibit any admissible weight vector $w$ — chosen freely as a
function of $x$ — under which every point of $A$ is far from $x$.

### 5.2 Exact evaluations

**Theorem 5.5 (Singletons).** *For $y,x\in\Omega^n$,*
$$d_T^2(\{y\},x) = \sum_{i=1}^n h(x_i,y_i)^2 = \#\{i : x_i\neq y_i\},$$
*the plain Hamming distance. In particular if $x_i\neq y_i$ for all $i$ then
$d_T^2(\{y\},x) = n$.*

*Proof sketch.* The only representing vector is $U(x,y)$ itself, whose squared
norm is the stated sum since its entries are $0/1$. $\square$

This non-degeneracy statement matters: it shows the convex distance is not a
vacuous quantity and fixes its normalisation, so that the exponent $d_T^2/4$ is
comparable with squared Hamming distance.

**Definition (Cylinder / subcube).** For $B\subseteq\{1,\dots,n\}$ and
$c\in\Omega^n$, let $\mathrm{Cyl}(B,c) = \{y : y_i = c_i \text{ for all } i \in B\}$.

**Theorem 5.6 (Exact convex distance to a subcube).** *For all $B$, $c$, $x$,*
$$d_T^2\big(\mathrm{Cyl}(B,c),x\big) = \#\{ i\in B : x_i \neq c_i\}.$$

*Proof sketch.* Upper bound: the "patched" point $y$ with $y_i = c_i$ on $B$ and
$y_i = x_i$ off $B$ lies in the cylinder, and $U(x,y)$ is the indicator of
$\{i\in B : x_i\neq c_i\}$, of squared norm equal to its cardinality. Lower bound:
every point of the cylinder disagrees with $x$ on all of $D = \{i\in B: x_i\neq
c_i\}$, so every representing vector has $v_i = 1$ for $i\in D$, whence
$\mathrm{sq}(v)\ge |D|$. $\square$

Consequently, for any product measure,
$$\mathbb{P}\big(\mathrm{Cyl}(B,c)\big)\cdot \mathbb{P}\big(\#\{i\in B : X_i\neq c_i\}
\ge t\big) \le e^{-t/4},$$
an explicit, fully computable instance of the main theorem.

---

## 6. Concentration inequalities

### 6.1 From the moment bound to deviations

**Theorem 6.1 (Convex-distance deviation bound).** *For any $A, S\subseteq
\Omega^n$ and $t\in\mathbb R$, if $d_T^2(A,x)\ge t$ for all $x\in S$, then*
$$\mathbb{P}(A)\,\mathbb{P}(S)\;\le\; e^{-t/4}.$$

*Proof sketch.* For $x \in S$, $\mathrm{wt}(x) \le e^{-t/4}\,\mathrm{wt}(x)
e^{d_T^2(A,x)/4}$. Summing over $S$ and extending the sum to all of $\Omega^n$
gives $\mathbb{P}(S) \le e^{-t/4} E(A)$; multiply by $\mathbb{P}(A)$ and use
Theorem 4.1. $\square$

**Theorem 6.2 (Isoperimetric form).** *If $\mathbb{P}(A)\ge \tfrac12$ and
$d_T^2(A,\cdot)\ge t$ on $S$, then $\mathbb{P}(S)\le 2e^{-t/4}$.*

*Proof.* Immediate from Theorem 6.1. $\square$

**Theorem 6.3 (Weighted Hamming form).** *Let $w$ be admissible, $A\neq\emptyset$,
$t\ge0$, and suppose $d_w(A,x)\ge t$ for every $x\in S$. Then*
$$\mathbb{P}(A)\,\mathbb{P}(S)\;\le\;e^{-t^2/4}.$$

*Proof.* Combine Lemma 2.7 ($d_w^2 \le d_T^2$) with Theorem 6.1 applied at level
$t^2$. $\square$

### 6.2 Lipschitz functionals

**Theorem 6.4 (Concentration of $1$-Lipschitz functionals).** *Let $w$ be
admissible and let $f:\Omega^n\to\mathbb R$ satisfy*
$$f(x)\;\le\;f(y) + \sum_{i=1}^n w_i\, h(x_i,y_i)\qquad\text{for all } x,y .$$
*Let $A\neq\emptyset$ with $f\le m$ on $A$, and let $S$ be such that $f\ge m+t$ on
$S$, $t\ge0$. Then*
$$\mathbb{P}(A)\,\mathbb{P}(S)\;\le\; e^{-t^2/4}.$$
*If moreover $\mathbb{P}(A)\ge\tfrac12$ (so that $m$ is at least a median of $f$),
then*
$$\mathbb{P}(f \ge m+t)\;\le\;2\,e^{-t^2/4}.$$

*Proof sketch.* For $x\in S$ and $y\in A$, the Lipschitz hypothesis gives
$\sum_i w_i h(x_i,y_i)\ge f(x)-f(y)\ge (m+t)-m = t$, hence $d_w(A,x)\ge t$; apply
Theorem 6.3. The median form follows since $\mathbb{P}(A)\ge 1/2$. $\square$

**Example (number of ones, normalised).** On $\{0,1\}^n$ with independent coins of
arbitrary biases $\theta_i\in[0,1]$, let $f(x) = n^{-1/2}\#\{i : x_i = 1\}$. With
$w_i = n^{-1/2}$ (admissible, since $\sum_i w_i^2 = 1$) the Lipschitz hypothesis
holds, and Theorem 6.4 yields $\mathbb{P}(A)\mathbb{P}(S)\le e^{-t^2/4}$ for the
corresponding level sets — a sub-Gaussian tail requiring no independence structure
beyond the product form and no identical distribution.

### 6.3 Certifiable functionals: concentration at the certificate scale

The Lipschitz hypothesis of Theorem 6.4 is used only to produce, for each far
point $x$, a witness weight vector. Because the minimax identity (Theorem 5.4)
allows the witness to depend on $x$, one can do much better whenever the reason
that $f(x)$ is large is *localised*.

**Definition 6.5 (Certificate).** Let $f:\Omega^n\to\mathbb R$ and $m\in\mathbb R$.
A point $x$ *admits a certificate of size $K$ at level $m$* if there is
$J\subseteq\{1,\dots,n\}$ with $|J|\le K$ such that every $y$ with $y_i = x_i$
for all $i\in J$ satisfies $f(y)\ge m$.

**Theorem 6.6 (Certifiable concentration).** *Let $f$ be $1$-Lipschitz for the
plain Hamming metric, i.e. $f(z)\le f(y) + \sum_i h(z_i,y_i)$ for all $z,y$. Let
$K > 0$ and $b\le m$. Suppose $f\le b$ on a nonempty set $A$, and every $x\in S$
admits a certificate of size at most $K$ at level $m$. Then*
$$\mathbb{P}(A)\,\mathbb{P}(S)\;\le\;\exp\!\Big(-\frac{(m-b)^2}{4K}\Big).$$

*Proof sketch.* Fix $x \in S$ with certificate $J$, and set
$w_i = |J|^{-1/2}\mathbf 1[i\in J]$, an admissible weight ($\sum_i w_i^2 = 1$ if
$J \ne \emptyset$, and $0$ otherwise). Let $y\in A$. Let $y'$ agree with $x$ on
$J$ and with $y$ off $J$. By the certificate property $f(y')\ge m$, while
$1$-Lipschitzness gives $f(y')\le f(y) + \#\{i\in J : y_i\neq x_i\} \le b +
\#\{i\in J: y_i\neq x_i\}$. Hence $\#\{i\in J : y_i\neq x_i\}\ge m-b$ and
$$\sum_i w_i h(x_i,y_i) = \frac{\#\{i\in J : x_i\neq y_i\}}{\sqrt{|J|}}
\ \ge\ \frac{m-b}{\sqrt{K}} .$$
So $d_w(A,x) \ge (m-b)/\sqrt K$ and Theorem 6.3 applies, giving the exponent
$-(m-b)^2/(4K)$. Since $w$ depends on $x$, this argument is unavailable to any
formulation with a single global Lipschitz vector. $\square$

The deviation is therefore measured on the scale $\sqrt K$ — the *size of a
certificate* — rather than $\sqrt n$.

**Corollary 6.7 (Counting ones at the certificate scale).** *On $\{0,1\}^n$ with
independent coins of arbitrary biases, let $N(x) = \#\{i : x_i = 1\}$. For
$0 < b\le m$, if $N \le b$ on $A\neq\emptyset$ and $N\ge m$ on $S$, then*
$$\mathbb{P}(A)\,\mathbb{P}(S)\;\le\;\exp\!\Big(-\frac{(m-b)^2}{4\lceil m\rceil}\Big).$$

*Proof sketch.* $N$ is $1$-Lipschitz for the Hamming metric, and if $N(x)\ge m$
then any $\lceil m\rceil$ positions where $x$ has a one form a certificate of that
size. Apply Theorem 6.6 with $K = \lceil m\rceil$. $\square$

For $m = o(n)$ this is far stronger than the $\sqrt n$-scale bound: it detects
deviations of order $\sqrt m$ in a regime where the normalised Lipschitz form is
vacuous.

### 6.4 Longest increasing subsequence

Let $\Omega$ be a linearly ordered finite alphabet and $x\in\Omega^n$ a word. Say
$S\subseteq\{1,\dots,n\}$ *indexes a weakly increasing subsequence* of $x$ if
$x_i\le x_j$ whenever $i\le j$ in $S$, and let
$$L(x) = \max\{|S| : S \text{ indexes a weakly increasing subsequence of } x\}.$$

**Lemma 6.8.** *$L$ is $1$-Lipschitz for the plain Hamming metric:
$L(z) \le L(y) + \#\{i : z_i\neq y_i\}$.*

*Proof sketch.* Take an optimal increasing set $S$ for $z$ and delete the indices
where $z$ and $y$ differ; the remainder is increasing for $y$ and has size at
least $|S| - \#\{i : z_i \ne y_i\}$. $\square$

**Lemma 6.9 (Certificates for $L$).** *If $L(x)\ge \ell$ then $x$ admits a
certificate of size $\lceil\ell\rceil$ at level $\ell$: any witnessing increasing
subsequence of length $\lceil\ell\rceil$ does the job, since any word agreeing
with $x$ on those positions contains the same increasing subsequence.*

**Theorem 6.10 (Concentration of $L$).** *For any product measure on words of
length $n$, any $0<b\le \ell$, and sets $A, S$ with $L\le b$ on $A\neq\emptyset$
and $L\ge \ell$ on $S$,*
$$\mathbb{P}(A)\,\mathbb{P}(S)\;\le\;\exp\!\Big(-\frac{(\ell-b)^2}{4\lceil\ell\rceil}\Big).$$

Since $L\asymp\sqrt n$ in the classical uniform model, the deviation scale here is
$\sqrt{\ell}\asymp n^{1/4}$, matching the true order of the fluctuations up to
constants, whereas bounded differences only gives $\sqrt n$ — the same order as
$L$ itself, hence no information.

---

## 7. Algorithms

Three computational tasks arise naturally.

### 7.1 Computing the convex distance

$d_T^2(A,x)$ is the value of the quadratic program
$$\min_{\alpha \in \Delta(A)} \Big\| M_x\alpha \Big\|_2^2, \qquad
(M_x)_{i,y} = h(x_i,y_i),$$
the minimum-norm point in the polytope $\{M_x\alpha : \alpha\in\Delta(A)\}$, where
$\Delta(A)$ is the probability simplex on $A$. Two standard schemes solve it:

- **Frank–Wolfe with exact line search.** At iterate $v$, the linear minimisation
  oracle returns the column $U(x,y)$ minimising $\langle v, U(x,y)\rangle$ — i.e.
  the point of $A$ that is "most orthogonal" to the current vector — and the step
  size is available in closed form for a quadratic objective. Each iteration costs
  $O(n|A|)$; the objective error decays as $O(1/k)$.
- **Pairwise (away-step) Frank–Wolfe.** Additionally identifies the worst atom in
  the current active set and moves weight from it to the best atom. On a polytope
  this converges linearly, and in practice reaches machine precision in a few
  hundred iterations for the sizes used here.

The dual certificate is available for free: $w = v/\|v\|_2$ and the duality gap is
$\|v\|_2 - \min_{y\in A}\langle w, U(x,y)\rangle$, which is nonnegative and
vanishes exactly at the optimum by Theorem 5.4. This gives a rigorous a posteriori
bracket $[\,\min_y\langle w,U(x,y)\rangle,\ \|v\|_2\,]$ for $d_T(A,x)$.

### 7.2 Verifying the exponential moment bound

For small $|\Omega|$ and $n$ one can enumerate $\Omega^n$, compute $d_T^2(A,x)$
for each $x$, and evaluate $E(A)\mathbb{P}(A)$ directly. The quantity is always
$\le 1$ and typically close to $1$ for sets $A$ of moderate mass, illustrating the
tightness of the averaging step $\theta(2-\theta)\le 1$: equality would require
$\theta = 1$ at every stage of the recursion.

### 7.3 Evaluating the interpolation profile

For $r$ on a grid in $[0,1]$, compute
$$\Phi(r) = \min_{\lambda\in[0,1]} e^{(1-\lambda)^2/4} r^{-\lambda}$$
and compare with $2-r$. The minimiser is the projection of $1+2\log r$ onto
$[0,1]$, so no numerical optimisation is needed; the gap $2-r-\Phi(r)$ is
nonnegative, vanishes to third order as $r\to1$, and is maximised in the interior.

---

## 8. Discussion

**Why the convex distance is the right object.** The two descriptions of $d_T$ —
minimum norm in a convex hull, and supremum of weighted Hamming distances — play
complementary roles. The hull description is what the induction can process: the
mixing step (Lemma 4.3) is a statement about convex combinations, and its
quadratic-versus-linear asymmetry is exactly what the interpolation lemma is built
to exploit. The dual description is what applications need: it converts the
abstract inequality into a recipe (find a witness weight vector) and, crucially,
lets that recipe be point-dependent.

**Comparison with bounded differences.** McDiarmid's inequality corresponds to
fixing a single admissible $w$ for all $x$. Talagrand's theorem is the statement
that one may take a supremum over $w$ *inside* the probability, at the cost of
only a constant in the exponent. Whenever the "reason" that $f$ is large varies
from point to point — as with subsequences, cliques, tours, or covers — this
freedom converts a $\sqrt n$ scale into a $\sqrt K$ scale.

**Sharpness.** The constant $1/4$ enters at exactly one place, the interpolation
lemma, and it is optimal there: the reduced scalar inequality $e^{u-u^2}\le
2-e^{-u}$ on $[0,\tfrac12]$ has a third-order tangency at $u=0$, and any larger
exponent constant breaks the second-order cancellation. The other loss in the
argument, $\theta(2-\theta)\le 1$, is tight at $\theta=1$.

**Generality.** Nothing in the development requires identically distributed
coordinates, nor any structure on the alphabet beyond finiteness and decidable
equality. The alphabet may differ from coordinate to coordinate at the cost of
notation only. Finiteness of $A$ is used for compactness in the duality section;
the moment inequality itself is a statement about finite sums throughout.

**Limitations.** The results are stated for finite product spaces. Extension to
general product probability spaces follows the same induction once the hull is
replaced by a suitable closure, but the geometric step must then be phrased for
measurable sets and the attainment lemma replaced by weak compactness. Likewise,
functionals of *dependent* variables lie outside the scope; there, the natural
substitutes are martingale methods or the transportation approach.

---

## 9. Future directions

Several avenues suggest themselves.

1. **Beyond product measures.** Extend the induction to measures satisfying a
   Dobrushin-type contraction condition, where a section/projection decomposition
   still makes sense with a controlled loss per coordinate.
2. **Sharper certificate bounds.** For functionals with certificates of varying
   size, the current bound uses a uniform $K$; a refined argument averaging over
   certificate sizes should recover a mixed exponent.
3. **Two-sided and moment forms.** Convert the product-form bound
   $\mathbb{P}(A)\mathbb{P}(S)\le e^{-t^2/4}$ into moment inequalities for
   $|f - \mathrm{med}(f)|^q$ and into two-sided tail bounds with explicit constants.
4. **Applications catalogue.** Random travelling salesman tours, subgraph counts,
   first-passage percolation, empirical processes and randomised algorithms all
   admit certificates; each yields a concrete concentration statement from
   Theorem 6.6.
5. **Continuous alphabets.** Replace finite $\Omega$ by a Polish space and finite
   sets $A$ by measurable ones, checking that attainment and the variational
   inequality survive.
6. **Quantitative optimality.** Determine the exact optimal constant in the
   certifiable-functional bound; the factor $4$ inherited from the convex-distance
   exponent need not be optimal at the certificate scale.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Convex distance inequality | $\mathbb{E}[e^{d_T^2(A,X)/4}]\,\mathbb{P}(A)\le1$ for any finite product measure |
| Deviation bound | $d_T^2(A,\cdot)\ge t$ on $S$ $\Rightarrow$ $\mathbb{P}(A)\mathbb{P}(S)\le e^{-t/4}$ |
| Weighted Hamming form | $d_w(A,\cdot)\ge t$ on $S$, $w$ admissible $\Rightarrow$ $\mathbb{P}(A)\mathbb{P}(S)\le e^{-t^2/4}$ |
| Lipschitz concentration | $f\le m$ on $A$, $f\ge m+t$ on $S$ $\Rightarrow$ $\mathbb{P}(A)\mathbb{P}(S)\le e^{-t^2/4}$; median form $\le 2e^{-t^2/4}$ |
| Isoperimetry | $\mathbb{P}(A)\ge\frac12$ $\Rightarrow$ $\mathbb{P}(d_T^2\ge t)\le 2e^{-t/4}$ |
| Interpolation lemma | $\forall r\in[0,1]\ \exists\lambda\in[0,1]:\ e^{(1-\lambda)^2/4}r^{-\lambda}\le2-r$, optimal $\lambda = 1+2\log r$ |
| Weighted Hölder | $\sum_i q_if_i^\lambda g_i^{1-\lambda}\le(\sum_i q_if_i)^\lambda(\sum_i q_ig_i)^{1-\lambda}$ |
| Mixing step | $d_T^2(A,(a,y))\le(1-\lambda)^2+\lambda d_T^2(A_a,y)+(1-\lambda)d_T^2(\Pi A,y)$ |
| Minimax identity | $d_T(A,x)=\sup\{d_w(A,x): w\ge0,\ \|w\|_2\le1\}$ |
| Singleton | $d_T^2(\{y\},x)=\#\{i:x_i\neq y_i\}$ |
| Subcube | $d_T^2(\mathrm{Cyl}(B,c),x)=\#\{i\in B: x_i\neq c_i\}$ |
| Certifiable functionals | certificates of size $\le K$ $\Rightarrow$ $\mathbb{P}(A)\mathbb{P}(S)\le e^{-(m-b)^2/(4K)}$ |
| Counting ones | $\mathbb{P}(N\le b)\mathbb{P}(N\ge m)\le e^{-(m-b)^2/(4\lceil m\rceil)}$, arbitrary biases |
| Longest increasing subsequence | $\mathbb{P}(L\le b)\mathbb{P}(L\ge\ell)\le e^{-(\ell-b)^2/(4\lceil\ell\rceil)}$ |
