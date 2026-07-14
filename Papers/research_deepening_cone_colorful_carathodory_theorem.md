# The Cone Colorful Carathéodory Theorem in Arbitrary Finite Dimension

## Abstract

We establish the Colorful Carathéodory Theorem, specialized to the origin, in
arbitrary finite dimension, and derive from it a conical analogue in which convex
combinations are replaced by nonnegative (conical) combinations. Let $V$ be a
$d$-dimensional real inner product space and let $C_1, \dots, C_r$ be finite
families ("color classes") of vectors in $V$ with $r \ge d+1$. If the origin lies
in the convex hull of each $C_i$, then there exists a *colorful transversal*
$t = (t_i)_{i=1}^r$ with $t_i \in C_i$ whose convex hull contains the origin. The
threshold $r \ge d+1$ is sharp: it already fails for $r = d$ in dimension one.
We prove this via a nearest-point descent argument that combines three
ingredients — a supporting-hyperplane separation at the projection of the origin,
a Carathéodory support set constrained to a hyperplane (hence of cardinality at
most $d$), and a color pigeonhole — into a monovariant that strictly decreases the
distance from the origin to the transversal's convex hull unless that distance is
already zero. A short *homogeneity bridge*, valid precisely because the target is
the scale-invariant origin, shows that conical and convex representability of the
origin coincide, yielding the cone version as an immediate corollary. We give
explicit instantiations in the standard Euclidean space $\mathbb{R}^d$ with
exactly $d+1$ colors.

---

## 1. Introduction

Carathéodory's theorem is one of the foundational facts of convex geometry: a
point in the convex hull of a set $S \subseteq \mathbb{R}^d$ already lies in the
convex hull of at most $d+1$ points of $S$. Bárány's **Colorful Carathéodory
Theorem** (1982) is a striking refinement. Instead of one set, one is given
$d+1$ sets ("colors"), each containing a target point $x$ in its convex hull, and
the conclusion is that $x$ lies in the convex hull of a *rainbow* selection — one
point from each color. It is the engine behind Tverberg's theorem, the first
selection lemma, centerpoint results, and a family of algorithmic questions in
computational geometry.

This paper focuses on the case $x = 0$, the origin. This case is not a loss of
generality of the phenomenon (a translation reduces the general point to the
origin), and it enjoys an extra symmetry: the origin is fixed by scaling. This
scale-invariance lets us pass freely between two notions of "capturing the
origin":

- **convex**: the origin is a convex combination (nonnegative weights summing to
  one);
- **conical**: the origin is a *nontrivial* conical combination (nonnegative
  weights, not all zero).

We prove that these two notions coincide for the origin (Theorem 3.1, the
*homogeneity bridge*), prove the colorful theorem for the origin in arbitrary
finite dimension (Theorem 5.7), and deduce the conical colorful theorem
(Theorem 6.1). We close with explicit statements in $\mathbb{R}^d$ (Section 7).

Our proof of the colorful theorem is self-contained and constructive in spirit: a
descent over the finite set of colorful transversals, driven by a strict distance
monovariant.

---

## 2. Definitions and setting

Throughout, $V$ is a real vector space; from Section 4 onward it carries an inner
product $\langle\cdot,\cdot\rangle$ with induced norm $\|v\| = \sqrt{\langle v,v\rangle}$,
and from Section 5 onward it is finite-dimensional with $d := \dim_\mathbb{R} V$.
An index type $\iota$ (the *colors*) is finite of cardinality $r = |\iota|$; each
color $i$ carries a finite set $C_i \subseteq V$.

**Definition 2.1 (Conical capture of the origin).** A finite family
$(p_i)_{i \in s}$ (indexed by a finite set $s$) *conically captures the origin*,
written $\mathrm{ConicZero}(s, p)$, if there are weights $w : s \to \mathbb{R}$
with

$$
w_i \ge 0 \ (\forall i \in s), \qquad \exists\, j \in s: w_j > 0, \qquad
\sum_{i \in s} w_i\, p_i = 0.
$$

**Definition 2.2 (Convex capture of the origin).** The family *convexly captures
the origin*, written $\mathrm{ConvexZero}(s, p)$, if there are weights
$w : s \to \mathbb{R}$ with

$$
w_i \ge 0 \ (\forall i \in s), \qquad \sum_{i \in s} w_i = 1, \qquad
\sum_{i \in s} w_i\, p_i = 0.
$$

**Definition 2.3 (Colorful transversal).** Given color classes
$(C_i)_{i \in \iota}$, a *colorful transversal* is a map $t : \iota \to V$ with
$t_i \in C_i$ for every color $i$. Its *range* is $\{t_i : i \in \iota\}$.

We freely use that $\mathrm{ConvexZero}(s, \mathrm{id})$ for a finite set
$s \subseteq V$ is equivalent to $0 \in \operatorname{conv}(s)$, where
$\operatorname{conv}$ denotes the convex hull; see Lemma 4.1.

---

## 3. The homogeneity bridge

**Theorem 3.1 (Homogeneity bridge).** For any finite family $(p_i)_{i \in s}$ of
vectors,

$$
\mathrm{ConicZero}(s, p) \iff \mathrm{ConvexZero}(s, p).
$$

*Proof.* ($\Rightarrow$) Suppose $w_i \ge 0$, not all zero, with
$\sum_i w_i p_i = 0$. Let $s^\star = \sum_{i \in s} w_i$. Since all $w_i \ge 0$
and at least one $w_j > 0$, we have $s^\star \ge w_j > 0$. Define
$w'_i = w_i / s^\star$. Then $w'_i \ge 0$, $\sum_i w'_i = 1$, and, by linearity,
$\sum_i w'_i p_i = (1/s^\star)\sum_i w_i p_i = 0$. Hence
$\mathrm{ConvexZero}(s, p)$.

($\Leftarrow$) A convex combination has nonnegative weights summing to $1$; in
particular the weights are not all zero (their sum is $1 \ne 0$), so some
$w_j > 0$, and the same vanishing linear combination witnesses
$\mathrm{ConicZero}(s, p)$. $\qquad\blacksquare$

The result hinges on the origin being homogeneous: $\lambda \cdot 0 = 0$ for all
$\lambda > 0$, so rescaling a vanishing combination preserves vanishing. For a
general target $x \ne 0$ the two notions genuinely differ.

---

## 4. From capture to convex hulls

**Lemma 4.1 (Convex capture equals hull membership).** For a finite set
$s \subseteq V$,

$$
\mathrm{ConvexZero}(s, \mathrm{id}) \iff 0 \in \operatorname{conv}(s).
$$

*Proof.* Unfolding the convex hull of a finite set as the set of centers of mass
of nonnegative weight systems summing to one, both sides assert the existence of
weights $w \ge 0$ with $\sum_{x \in s} w_x = 1$ and $\sum_{x \in s} w_x\, x = 0$.
The only bookkeeping is that the hull description allows the degenerate all-zero
weight vector when $s = \emptyset$; the constraint $\sum w_x = 1$ excludes it.
$\qquad\blacksquare$

**Lemma 4.2 (Hull of a transversal's range).** Let $\iota$ be finite and
$t : \iota \to V$. If $0 \in \operatorname{conv}(\{t_i : i \in \iota\})$, then
$\mathrm{ConvexZero}(\iota, t)$; i.e., the origin is a convex combination of the
$t_i$ *indexed by the colors*.

*Proof.* Membership in the hull of the range provides a finitely supported
weighting of *points* in the range. Pulling this weighting back along $t$ to a
weighting of *colors* (assigning to each color the weight of its image, and $0$
to colors outside the support) yields nonnegative color weights summing to one
whose weighted sum of the $t_i$ vanishes. $\qquad\blacksquare$

Lemmas 4.1 and 4.2 let us shuttle between the algebraic capture predicates and the
geometric convex-hull statements used in the descent argument.

---

## 5. The colorful Carathéodory theorem for the origin

We now assume $V$ is finite-dimensional, $d = \dim_\mathbb{R} V$, and prove the
main theorem. The proof rests on four lemmas.

### 5.1 A dimension bound on hyperplane support sets

**Lemma 5.1 (Support on a hyperplane is small).** Let $p \ne 0$ and let
$A \subseteq V$ be a finite, affinely independent set all of whose points satisfy
$\langle p, a\rangle = c$ for a common constant $c$. Then $|A| \le d$.

*Proof.* Consider the nonzero linear functional $f = \langle p, \cdot\rangle$.
Its kernel $\ker f$ is a hyperplane of dimension $d - 1$ (because $f$ is onto:
for any scalar $\lambda$, $f\big((\lambda/\|p\|^2)\,p\big) = \lambda$, so
$\operatorname{rank} f = 1$ and, by rank–nullity, $\dim \ker f = d - 1$). For any
$a, b \in A$ we have $f(a - b) = c - c = 0$, so all difference vectors lie in
$\ker f$; hence the vector span of the differences, $\operatorname{vspan}(A)$,
satisfies $\operatorname{vspan}(A) \subseteq \ker f$ and thus has dimension at
most $d - 1$. Affine independence gives
$\dim \operatorname{vspan}(A) + 1 = |A|$, whence $|A| \le (d-1) + 1 = d$.
$\qquad\blacksquare$

### 5.2 The descent step

**Lemma 5.2 (Moving toward a near-side point shortens the norm).** Let $K$ be
convex, $p, y \in K$, $p \ne 0$, and $\langle p, y\rangle < \|p\|^2$. Then there
is $q \in K$ with $\|q\| < \|p\|$.

*Proof.* Write $q_\theta = (1-\theta)p + \theta y = p + \theta(y - p)$ for
$\theta \in [0,1]$; by convexity $q_\theta \in K$. Expanding,

$$
\|q_\theta\|^2 = \|p\|^2 - 2\theta\big(\|p\|^2 - \langle p, y\rangle\big)
+ \theta^2\|y - p\|^2 .
$$

Set $\delta = \|p\|^2 - \langle p, y\rangle > 0$ and $\varepsilon = \|y - p\|^2 > 0$
(note $y \ne p$, else $\langle p,y\rangle = \|p\|^2$). Choosing
$\theta = \min(1,\ \delta/\varepsilon) > 0$ gives $\theta\varepsilon \le \delta$,
hence

$$
\|q_\theta\|^2 \le \|p\|^2 - 2\theta\delta + \theta\,(\theta\varepsilon)
\le \|p\|^2 - 2\theta\delta + \theta\delta = \|p\|^2 - \theta\delta < \|p\|^2 .
$$

Take $q = q_\theta$. $\qquad\blacksquare$

### 5.3 Separation at the nearest point

**Lemma 5.3 (Supporting hyperplane at the projection).** Let $K$ be convex and
let $p \in K$ realize the distance from the origin to $K$, i.e.
$\|0 - p\| = \inf_{w \in K}\|0 - w\|$. Then

$$
\langle p, w\rangle \ge \|p\|^2 \qquad \text{for all } w \in K.
$$

*Proof.* The variational characterization of the nearest point in a convex set
gives $\langle 0 - p,\ w - p\rangle \le 0$ for all $w \in K$. Expanding,
$-\langle p, w\rangle + \langle p, p\rangle \le 0$, i.e.
$\langle p, w\rangle \ge \|p\|^2$. $\qquad\blacksquare$

### 5.4 Extracting a small support set on the hyperplane

**Lemma 5.4 (Support finset on the supporting hyperplane).** Let $p \ne 0$,
$s \subseteq V$, $p \in \operatorname{conv}(s)$, and suppose every $x \in s$
satisfies $\|p\|^2 \le \langle p, x\rangle$. Then there is a finite
$A \subseteq s$ with $p \in \operatorname{conv}(A)$ and $|A| \le d$.

*Proof.* By Carathéodory choose a minimal, affinely independent $A_0 \subseteq s$
with $p \in \operatorname{conv}(A_0)$, say $p = \sum_{a \in A_0} w_a\, a$ with
$w_a \ge 0$, $\sum_a w_a = 1$. Pair the separation inequality with the weights:

$$
0 = \langle p, p\rangle - \|p\|^2\!\!\sum_{a} w_a
 = \sum_{a \in A_0} w_a\big(\langle p, a\rangle - \|p\|^2\big).
$$

Every summand is $\ge 0$ (weights nonnegative; brackets nonnegative by the
hypothesis), so each vanishes: $w_a > 0$ forces $\langle p, a\rangle = \|p\|^2$.
Let $A = \{a \in A_0 : w_a \ne 0\}$. Then still $p \in \operatorname{conv}(A)$
(dropping zero-weight points), $A$ remains affinely independent (a subset of an
affinely independent set), and every point of $A$ lies on the hyperplane
$\langle p, \cdot\rangle = \|p\|^2$. Lemma 5.1 gives $|A| \le d$.
$\qquad\blacksquare$

### 5.5 The color pigeonhole and a near-side vertex

**Lemma 5.5 (A color is free).** Let $\iota$ be finite, $f : \iota \to V$, and
$A \subseteq V$ finite with $A \subseteq \{f_i : i \in \iota\}$ and
$|A| < |\iota|$. Then there is a color $j$ such that every $a \in A$ is realized
by some color $i \ne j$ (i.e. $f_i = a$).

*Proof.* For each $a \in A$ choose a color $\varphi(a)$ with $f_{\varphi(a)} = a$.
If no color were free, then for every $j$ some $a \in A$ would be realized *only*
by $j$, i.e. $\varphi$ would be surjective onto $\iota$; but a surjection
$A \twoheadrightarrow \iota$ forces $|A| \ge |\iota|$, contradicting
$|A| < |\iota|$. $\qquad\blacksquare$

**Lemma 5.6 (Near-side vertex).** If $0 \in \operatorname{conv}(C)$ for a finite
$C \subseteq V$ and $p \ne 0$, then there is $y \in C$ with
$\langle p, y\rangle < \|p\|^2$.

*Proof.* Suppose not: $\langle p, x\rangle \ge \|p\|^2$ for all $x \in C$. The
half-space $H = \{x : \langle p, x\rangle \ge \|p\|^2\}$ is convex and contains
$C$, hence contains $\operatorname{conv}(C) \ni 0$. But $\langle p, 0\rangle = 0 <
\|p\|^2$, so $0 \notin H$ — a contradiction. $\qquad\blacksquare$

### 5.6 Main theorem

**Theorem 5.7 (Colorful Carathéodory for the origin).** Let $V$ be a
$d$-dimensional real inner product space and let $(C_i)_{i \in \iota}$ be finite
color classes with $|\iota| \ge d + 1$. If $0 \in \operatorname{conv}(C_i)$ for
every $i$, then there is a colorful transversal $t : \iota \to V$ (with
$t_i \in C_i$) such that $0 \in \operatorname{conv}(\{t_i : i \in \iota\})$.

*Proof.* Each $C_i$ is nonempty (its hull contains $0$), so colorful transversals
exist, and there are finitely many. For a transversal $s$, let $\rho(s)$ be the
distance from the origin to $\operatorname{conv}(\operatorname{range} s)$. Choose a
transversal $s_0$ minimizing $\rho$ (a minimum over a finite set), and let $p$ be
the nearest point of $\operatorname{conv}(\operatorname{range} s_0)$ to the
origin; this exists because the hull of a finite set is compact and convex. Then
$\|p\| = \rho(s_0)$.

If $p = 0$ we are done: $t = s_0$ works.

Otherwise $p \ne 0$. By Lemma 5.3, every point of
$\operatorname{conv}(\operatorname{range} s_0)$ — in particular every $s_0(i)$ —
satisfies $\langle p, x\rangle \ge \|p\|^2$. By Lemma 5.4 there is
$A \subseteq \operatorname{range} s_0$ with $p \in \operatorname{conv}(A)$ and
$|A| \le d$. Since $|A| \le d < d + 1 \le |\iota|$, Lemma 5.5 supplies a color $j$
that is *not needed* to realize $A$: every $a \in A$ equals $s_0(i)$ for some
$i \ne j$.

By Lemma 5.6 applied to $C_j$, pick $y \in C_j$ with
$\langle p, y\rangle < \|p\|^2$. Form the new transversal $s'$ by replacing color
$j$'s representative with $y$: $s'(j) = y$ and $s'(i) = s_0(i)$ for $i \ne j$.
Because every point of $A$ is realized by a color $\ne j$, we still have
$A \subseteq \operatorname{range} s'$, hence
$p \in \operatorname{conv}(A) \subseteq \operatorname{conv}(\operatorname{range} s')$;
also $y \in \operatorname{range} s'$. By Lemma 5.2 there is a point $q$ of
$\operatorname{conv}(\operatorname{range} s')$ with $\|q\| < \|p\|$. Therefore
$\rho(s') \le \|q\| < \|p\| = \rho(s_0)$, contradicting the minimality of $s_0$.

Hence $p = 0$, completing the proof. $\qquad\blacksquare$

The logic is a strict monovariant: any failed minimizer can be improved by
swapping its one free color, so the true minimizer must already reach the origin.

---

## 6. The cone colorful Carathéodory theorem

**Theorem 6.1 (Cone Colorful Carathéodory).** Let $V$ be a $d$-dimensional real
inner product space and let $(C_i)_{i \in \iota}$ be finite color classes with
$|\iota| \ge d + 1$. If each $C_i$ conically captures the origin
($\mathrm{ConicZero}(C_i, \mathrm{id})$), then there is a colorful transversal $t$
whose range conically captures the origin
($\mathrm{ConicZero}(\iota, t)$).

*Proof.* By the homogeneity bridge (Theorem 3.1), each $C_i$ convexly captures the
origin, and by Lemma 4.1 this means $0 \in \operatorname{conv}(C_i)$. Apply
Theorem 5.7 to obtain a colorful transversal $t$ with
$0 \in \operatorname{conv}(\operatorname{range} t)$. Lemma 4.2 upgrades this to
$\mathrm{ConvexZero}(\iota, t)$, and the homogeneity bridge (Theorem 3.1) once
more converts it to $\mathrm{ConicZero}(\iota, t)$. $\qquad\blacksquare$

The convex world carries the entire geometric burden; the conical statement rides
in on the bridge, front and back.

---

## 7. Explicit statements in $\mathbb{R}^d$

Specializing to the standard $d$-dimensional Euclidean space $\mathbb{R}^d$ (which
has dimension $d$) with exactly $d + 1$ colors gives the following clean corollaries.

**Corollary 7.1 (Cone colorful Carathéodory in $\mathbb{R}^d$).** Let
$C_0, \dots, C_d$ be $d + 1$ finite sets of vectors in $\mathbb{R}^d$, each
conically capturing the origin. Then there is a colorful transversal
$t = (t_0, \dots, t_d)$ with $t_i \in C_i$ whose range conically captures the
origin.

**Corollary 7.2 (Affine colorful Carathéodory in $\mathbb{R}^d$).** Let
$C_0, \dots, C_d$ be $d + 1$ finite sets of vectors in $\mathbb{R}^d$, each with
the origin in its convex hull. Then there is a colorful transversal
$t = (t_0, \dots, t_d)$ with $0 \in \operatorname{conv}(\{t_0, \dots, t_d\})$.

Both follow from Theorems 6.1 and 5.7, using $\dim \mathbb{R}^d = d$ and $d + 1$
colors, so the hypothesis $|\iota| \ge d + 1$ holds with equality.

---

## 8. Sharpness

The threshold $|\iota| \ge d + 1$ cannot be lowered to $d$, already for $d = 1$.
Take a single color $C_1 = \{+1, -1\} \subseteq \mathbb{R}^1$. It captures the
origin both convexly ($0 = \tfrac12(+1) + \tfrac12(-1)$) and conically. But any
transversal from one color selects a single number $t_1 \in \{+1, -1\}$, and a
lone nonzero number never captures the origin: $w\,t_1 = 0$ with $t_1 \ne 0$
forces $w = 0$, violating the nontriviality requirement. Thus $d = 1$ color fails
and $d + 1 = 2$ colors are necessary. The example generalizes to each dimension by
placing analogous one-dimensional obstructions along a coordinate axis, showing
$d$ colors are insufficient in $\mathbb{R}^d$.

This sharpness is mirrored in the proof: the pigeonhole step (Lemma 5.5) needs
$|A| \le d < |\iota|$, and $|A| \le d$ is exactly the best possible support bound
on a hyperplane (Lemma 5.1). Remove the $+1$ colors' worth of slack and no color
is guaranteed free.

---

## 9. Algorithms

The proof of Theorem 5.7 is a descent scheme and yields an algorithm.

**Nearest-transversal descent.** Maintain a current transversal $s$. Compute the
nearest point $p$ of $\operatorname{conv}(\operatorname{range} s)$ to the origin
(a convex quadratic program / projection). If $p = 0$, stop and output $s$.
Otherwise extract a Carathéodory support $A$ of $p$ (at most $d$ points, all on
the supporting hyperplane $\langle p, \cdot\rangle = \|p\|^2$), pigeonhole a free
color $j \notin$ colors$(A)$, choose $y \in C_j$ with $\langle p, y\rangle < \|p\|^2$
(guaranteed by Lemma 5.6), set $s(j) \leftarrow y$, and repeat. Each iteration
strictly decreases the distance $\rho(s)$, so the process terminates at a
transversal capturing the origin.

Bárány and Onn (1997) showed that a closely related scheme runs in polynomial
time (each projection and support extraction is polynomial, and the distance
monovariant controls the iteration count under mild genericity), giving a
constructive route to the colorful point. The conical version inherits this
algorithm verbatim through the homogeneity bridge: normalize the conical data to
convex data, run the descent, and rescale the output weights.

---

## 10. Applications

- **Tverberg's theorem.** The colorful Carathéodory theorem gives one of the
  cleanest proofs of Tverberg's theorem, which partitions $(d+1)(r-1)+1$ points
  in $\mathbb{R}^d$ into $r$ parts with intersecting convex hulls. Colorful
  arguments also yield quantitative "colorful Tverberg" strengthenings.
- **First selection lemma and centerpoints.** Depth statements — some point lies
  in a constant fraction of all simplices spanned by a point set — descend from
  colorful selection, underpinning data depth and robust statistics.
- **Feasibility of direction systems.** In the conical formulation, the theorem
  answers when a rainbow of *direction* families can be balanced: whenever each
  family already balances, one representative per family suffices, provided the
  number of families exceeds the ambient dimension. This is the natural setting
  for force-balancing, linear-programming feasibility of homogeneous systems, and
  scale-invariant resource models.

---

## 11. Discussion and future work

The origin case captures the full geometric difficulty of colorful Carathéodory;
the general-point case follows by translation. The homogeneity bridge is what
makes the conical extension effortless, and it is *specific to the origin* — for a
general target, conical and convex capture diverge, and a separate development is
required.

Natural next steps include:

1. **General target point.** Prove the colorful theorem for an arbitrary
   $x \in \bigcap_i \operatorname{conv}(C_i)$, either by translation or by running
   the descent with $x$ in place of the origin.
2. **Colorful Carathéodory numbers and uniqueness.** Quantify how many colorful
   transversals capture the origin, and study the minimality of the support.
3. **Colorful Helly and colorful Tverberg.** These live in the same family; the
   supporting-hyperplane and pigeonhole infrastructure should transfer.
4. **Sharpness in general dimension.** Construct explicit $d$-color families that
   fail, matching the $d+1$ threshold (the $\{+1,-1\}$ example gives $d=1$).
5. **Quantitative / algorithmic version.** A fully constructive, complexity-analyzed
   version of the descent, following Bárány–Onn.
6. **Cone Carathéodory number.** Combine with the conic Carathéodory bound to
   bound the support of the colorful transversal by $d + 1$.

---

## References (selected)

- I. Bárány, *A generalization of Carathéodory's theorem*, Discrete Mathematics
  40 (1982), 141–152.
- I. Bárány and S. Onn, *Colourful linear programming and its relatives*,
  Mathematics of Operations Research 22 (1997), 550–567.
- C. Carathéodory, *Über den Variabilitätsbereich der Koeffizienten von
  Potenzreihen, die gegebene Werte nicht annehmen*, Mathematische Annalen 64
  (1907), 95–115.
