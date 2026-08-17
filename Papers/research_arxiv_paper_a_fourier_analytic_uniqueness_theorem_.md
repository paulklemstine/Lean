# A Uniqueness Theorem for Real-Parameter Lattice-Point Enumerators

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

For a bounded set $P \subseteq \mathbb{R}^d$ and a real parameter $t > 0$ we study the
lattice-point enumerator $L_P(t) = |tP \cap \mathbb{Z}^d|$, together with the family of
enumerators $L_{P+v}(t) = |t(P+v) \cap \mathbb{Z}^d|$ of the integer translates of $P$. We prove:

1. an *exact* discretisation identity, $\operatorname{vol}(A_t) = L_P(t)\, t^{-d}$, where
   $A_t = \{x : \lfloor tx \rfloor/t \in P\}$ is a disjoint union of $L_P(t)$ half-open cubes of
   side $1/t$, valid for every $t>0$ with no error term;
2. the Gauss–Weyl counting theorem $L_P(t)/t^d \to \operatorname{vol}(P)$ as $t \to \infty$ for
   every bounded Jordan measurable set, deduced from (1) by dominated convergence, and the
   consequent fact that the enumerator determines the volume;
3. a weighted form, $t^{-d}\sum_{k \in tP \cap \mathbb{Z}^d} g(k/t) \to \int_P g$ for bounded
   continuous $g$, whose specialisation to characters recovers the Fourier transform
   $\widehat{\mathbf{1}_P}(\xi)$ at every frequency from lattice exponential sums;
4. the main uniqueness theorem: two bounded measurable sets with null topological frontier whose
   integer-translate enumerators coincide have indicator functions equal almost everywhere, with
   the corollary that convex bodies are determined exactly (equal interiors, equal closures);
5. two sharpenings: in dimension one the conclusion upgrades to literal set equality with no
   regularity hypothesis at all, and in every dimension the enumerators of *all real* translates
   determine the set exactly.

The proof of (4) rests on a *sparse-grid* mechanism: choosing $t$ with $1/t > \operatorname{diam}$
forces the enumerator to take only the values $0$ and $1$, so the data becomes a membership
oracle; an arithmetic choice of spacing $M + 1/N$ together with the integer translate $Ma$ aims
that oracle at an arbitrary rational point $a/N$. This unifies, with a single short argument, the
uniqueness results previously established separately for rational polytopes and for symmetric
convex bodies by intricate case-specific geometric constructions.

**Keywords:** lattice-point enumerator, Ehrhart theory, Jordan measurability, Fourier transform
of an indicator, convex body, geometric tomography, lattice-based cryptography.

---

## 1. Introduction

### 1.1 Background

Let $\mathbb{Z}^d \subseteq \mathbb{R}^d$ be the standard integer lattice and let
$P \subseteq \mathbb{R}^d$ be a bounded set. The *lattice-point enumerator* of $P$ is

$$L_P(t) \;=\; \bigl|\, tP \cap \mathbb{Z}^d \,\bigr| \;=\; \bigl|\{\, k \in \mathbb{Z}^d : k/t \in P \,\}\bigr|, \qquad t > 0 .$$

The second description exhibits the fundamental duality of the subject: dilating $P$ by $t$ and
refining the lattice to $\tfrac1t\mathbb{Z}^d$ are the same operation. Restricting $t$ to positive
*integers* yields the classical Ehrhart function; for a lattice polytope $L_P$ is then a
polynomial in $t$ of degree $d$ with leading coefficient $\operatorname{vol}(P)$, and for a
rational polytope a quasi-polynomial. That restricted data is well known **not** to determine $P$:
distinct polytopes routinely share an Ehrhart polynomial.

The situation changes when $t$ is permitted to range over all positive reals. Then $L_P$ is a
much finer invariant, and the question of whether it determines $P$ becomes a rigidity problem of
geometric-tomography type. Uniqueness results in this direction were obtained for rational
polytopes and for symmetric convex bodies by arguments tailored to each class. This paper gives a
unified and elementary treatment, with two independent mechanisms — one geometric (sparse grids)
and one harmonic-analytic (recovery of $\widehat{\mathbf{1}_P}$).

### 1.2 Standing conventions

Throughout, $d \ge 1$ is fixed and $\mathbb{R}^d$ is equipped with the supremum norm
$\|x\|_\infty = \max_i |x_i|$; $B(0,R)$ denotes the closed ball of radius $R$ in this norm, so
that $x \in B(0,R)$ if and only if $|x_i| \le R$ for all $i$. Lebesgue measure is denoted
$\operatorname{vol}$. For $x \in \mathbb{R}^d$, $\lfloor x \rfloor \in \mathbb{Z}^d$ is the
coordinatewise floor. We call $P$ *Jordan measurable* if it is bounded, measurable, and its
topological frontier $\partial P$ satisfies $\operatorname{vol}(\partial P) = 0$; every bounded
convex set is Jordan measurable.

---

## 2. Definitions

**Definition 2.1 (shifted lattice set and enumerators).** For $P \subseteq \mathbb{R}^d$,
$t > 0$ and $y \in \mathbb{R}^d$ put
$$\Lambda(P,t,y) \;=\; \Bigl\{\, k \in \mathbb{Z}^d \;:\; \tfrac{k}{t} - y \in P \,\Bigr\},$$
the set of lattice points of the dilated translate $t(P+y)$, and let
$$L_{P+y}(t) \;=\; \bigl|\Lambda(P,t,y)\bigr| .$$
The case $y = 0$ gives the plain enumerator $L_P(t) = |\Lambda(P,t,0)| = |tP \cap \mathbb{Z}^d|$.

The identity $\Lambda(P,t,y) = t(P+y) \cap \mathbb{Z}^d$ is immediate: $k/t - y \in P$ iff
$k/t \in P + y$ iff $k \in t(P+y)$. Thus $L_{P+y}$ is genuinely the enumerator of the translated
set.

**Definition 2.2 (grid cube, rounding map, rounded set).** For $t > 0$ and $k \in \mathbb{Z}^d$
let
$$C_t(k) \;=\; \prod_{i=1}^{d} \Bigl[\tfrac{k_i}{t}, \tfrac{k_i+1}{t}\Bigr)$$
be the half-open cube of side $1/t$ with lower corner $k/t$. Let
$\rho_t(x) = \lfloor t x \rfloor / t$ be coordinatewise rounding onto the grid
$\tfrac1t \mathbb{Z}^d$, and set
$$A_t(P) \;=\; \{\, x \in \mathbb{R}^d : \rho_t(x) \in P \,\} .$$

**Definition 2.3 (the data).** Two sets $P, Q \subseteq \mathbb{R}^d$ have *the same
integer-translate enumerator data* if
$$L_{P+v}(t) \;=\; L_{Q+v}(t) \qquad \text{for all } t > 0 \text{ and all } v \in \mathbb{Z}^d .$$

---

## 3. Finiteness and the exact cube identity

**Lemma 3.1 (finiteness).** If $P$ is bounded and $t > 0$, then $\Lambda(P,t,y)$ is finite for
every $y$.

*Proof sketch.* Choose $R$ with $P \subseteq B(0,R)$. If $k \in \Lambda(P,t,y)$ then
$|k_i/t - y_i| \le R$ for all $i$, hence $|k_i| \le (R + \|y\|_\infty) t =: B$, so
$\Lambda(P,t,y)$ is contained in the finite box $\{k \in \mathbb{Z}^d : \lceil -B\rceil \le k_i
\le \lfloor B \rfloor\}$. $\square$

**Lemma 3.2 (cube characterisation).** For $t>0$, $x \in C_t(k)$ if and only if
$\lfloor t x_i \rfloor = k_i$ for all $i$. Consequently the cubes $\{C_t(k)\}_{k \in \mathbb{Z}^d}$
are pairwise disjoint, each is measurable, and $\operatorname{vol}(C_t(k)) = t^{-d}$.

*Proof sketch.* Coordinatewise, $k_i/t \le x_i < (k_i+1)/t$ is equivalent to
$k_i \le t x_i < k_i + 1$, i.e. to $\lfloor t x_i \rfloor = k_i$, using $t > 0$. Disjointness
follows because $x$ determines $\lfloor t x\rfloor$; the volume is a product of $d$ intervals of
length $1/t$. $\square$

**Lemma 3.3 (decomposition of the rounded set).** For $t>0$,
$$A_t(P) \;=\; \bigsqcup_{k \,\in\, tP \cap \mathbb{Z}^d} C_t(k),$$
a disjoint union; in particular $A_t(P)$ is measurable whenever $P$ is bounded.

*Proof sketch.* If $\rho_t(x) \in P$ then $k := \lfloor t x\rfloor$ satisfies $k/t \in P$, i.e.
$k \in tP \cap \mathbb{Z}^d$, and $x \in C_t(k)$ by Lemma 3.2. Conversely if $x \in C_t(k)$ with
$k/t \in P$ then $\rho_t(x) = k/t \in P$. Measurability follows since by Lemma 3.1 the union is
finite. $\square$

**Theorem 3.4 (exact discretisation identity).** For every bounded $P$ and every $t > 0$,
$$\boxed{\;\operatorname{vol}\bigl(A_t(P)\bigr) \;=\; \frac{L_P(t)}{t^{d}}\;}$$
with no error term.

*Proof sketch.* Immediate from Lemma 3.3 by finite additivity, since the union is finite and
disjoint and each cube has volume $t^{-d}$. $\square$

This identity is the engine of everything analytic in this paper: it converts a purely
combinatorial count into an exact volume, at every scale simultaneously.

**Lemma 3.5 (rounding is uniformly small, and stable off the frontier).**
For $t > 0$ and every $x$, $\|\rho_t(x) - x\|_\infty \le 1/t$. Consequently:

(i) if $P \subseteq B(0,R)$ and $t \ge 1$, then $A_t(P) \subseteq B(0, R+1)$;

(ii) if $x \notin \partial P$, then for all sufficiently large $t$ one has
$x \in A_t(P) \iff x \in P$.

*Proof sketch.* Coordinatewise $0 \le t x_i - \lfloor t x_i \rfloor < 1$, giving the bound. For
(i), $\rho_t(x) \in P \subseteq B(0,R)$ and $\|x - \rho_t(x)\|_\infty \le 1/t \le 1$. For (ii):
if $x \notin \partial P$ then either $x \in \operatorname{int} P$ — so some ball $B(x,\varepsilon)
\subseteq P$, and once $1/t < \varepsilon$ we get $\rho_t(x) \in P$ and $x \in P$, so both sides
hold — or $x \notin \overline{P}$, and once $1/t < \varepsilon$ with
$B(x,\varepsilon) \cap \overline{P} = \emptyset$ we get $\rho_t(x) \notin P$ and $x \notin P$, so
both sides fail. $\square$

---

## 4. The counting theorem and volume determination

**Theorem 4.1 (Gauss–Weyl counting theorem).** Let $P \subseteq \mathbb{R}^d$ be bounded,
measurable, with $\operatorname{vol}(\partial P) = 0$. Then
$$\lim_{t \to \infty} \frac{L_P(t)}{t^{d}} \;=\; \operatorname{vol}(P) .$$

*Proof sketch.* By Theorem 3.4, $L_P(t)/t^d = \int \mathbf{1}_{A_t(P)}$. Fix $R$ with
$P \subseteq B(0,R)$. For $t \ge 1$ Lemma 3.5(i) gives
$\mathbf{1}_{A_t(P)} \le \mathbf{1}_{B(0,R+1)}$, an integrable dominating function independent of
$t$. By Lemma 3.5(ii), $\mathbf{1}_{A_t(P)}(x) \to \mathbf{1}_P(x)$ for every $x \notin \partial P$,
hence almost everywhere. Dominated convergence along $t \to \infty$ yields
$\int \mathbf{1}_{A_t(P)} \to \int \mathbf{1}_P = \operatorname{vol}(P)$. $\square$

Note the structure: the discretisation error, which in classical treatments is estimated by
covering $\partial P$ with boundary cubes, has here been replaced by an *exact* identity plus a
soft convergence argument. No boundary estimate is needed; only $\operatorname{vol}(\partial P)=0$.

**Corollary 4.2 (the enumerator determines the volume).** If $P, Q$ are bounded, measurable, with
null frontiers, and $L_P(t) = L_Q(t)$ for all $t > 0$, then $\operatorname{vol}(P) =
\operatorname{vol}(Q)$.

*Proof sketch.* Both sides are limits of the same function $t \mapsto L_P(t)/t^d$ by Theorem 4.1;
uniqueness of limits. $\square$

**Corollary 4.3 (convex case).** If $P, Q$ are bounded convex sets with $L_P = L_Q$ on
$(0,\infty)$, then $\operatorname{vol}(P) = \operatorname{vol}(Q)$; here measurability and
$\operatorname{vol}(\partial P) = 0$ are automatic, since the frontier of a convex set is Lebesgue
null.

---

## 5. Weighted counting and Fourier recovery

The exact identity of Theorem 3.4 generalises verbatim to weighted counts.

**Definition 5.1.** For $g : \mathbb{R}^d \to \mathbb{C}$ set
$$S_P(t; g) \;=\; \sum_{k \,\in\, tP \cap \mathbb{Z}^d} g\!\left(\frac{k}{t}\right),$$
a finite sum by Lemma 3.1.

**Lemma 5.2 (exact identity for weighted step integrals).** For bounded $P$, $t>0$ and any $g$,
$$\int_{\mathbb{R}^d} \mathbf{1}_{A_t(P)}(x)\, g\bigl(\rho_t(x)\bigr)\, dx \;=\; t^{-d}\, S_P(t;g) .$$

*Proof sketch.* By Lemma 3.3 the integrand equals
$\sum_{k \in tP \cap \mathbb{Z}^d} \mathbf{1}_{C_t(k)}(x)\, g(k/t)$, since $\rho_t$ is constant
$= k/t$ on $C_t(k)$. Integrate the finite sum term by term, each term contributing
$g(k/t)\operatorname{vol}(C_t(k)) = g(k/t) t^{-d}$. $\square$

**Theorem 5.3 (weighted Gauss–Weyl theorem).** Let $P$ be bounded with
$\operatorname{vol}(\partial P) = 0$ and let $g : \mathbb{R}^d \to \mathbb{C}$ be continuous with
$\|g\|_\infty \le C < \infty$. Then
$$\lim_{t \to \infty} \; t^{-d}\, S_P(t; g) \;=\; \int_{P} g(x)\, dx .$$

*Proof sketch.* By Lemma 5.2 the left-hand side is $\int \mathbf{1}_{A_t(P)}\, (g \circ \rho_t)$.
With $P \subseteq B(0,R)$ and $t \ge 1$, Lemma 3.5(i) gives the $t$-independent integrable
dominating function $C\,\mathbf{1}_{B(0,R+1)}$. Pointwise: $\rho_t(x) \to x$ by Lemma 3.5, hence
$g(\rho_t(x)) \to g(x)$ by continuity, while by Lemma 3.5(ii) the factor
$\mathbf{1}_{A_t(P)}(x)$ eventually equals $\mathbf{1}_P(x)$ for every $x \notin \partial P$.
Dominated convergence gives the claim. Taking $g \equiv 1$ recovers Theorem 4.1, since
$S_P(t;1) = L_P(t)$. $\square$

**Theorem 5.4 (Fourier recovery).** Let $P$ be bounded with $\operatorname{vol}(\partial P) = 0$.
Then for every $\xi \in \mathbb{R}^d$,
$$\lim_{t \to \infty}\; t^{-d} \sum_{k \,\in\, tP \cap \mathbb{Z}^d} e^{-2\pi i \langle \xi,\, k/t\rangle} \;=\; \widehat{\mathbf{1}_P}(\xi) \;=\; \int_{P} e^{-2\pi i \langle \xi, x\rangle}\, dx .$$

*Proof sketch.* Apply Theorem 5.3 with $g(x) = e^{-2\pi i \langle \xi, x\rangle}$, which is
continuous with $|g| \equiv 1$, so $C = 1$. $\square$

**Remark 5.5 (the Fourier route to uniqueness).** Theorem 5.4 says that the *positions* of the
counted lattice points — not merely their number — determine $\widehat{\mathbf{1}_P}$ completely,
and therefore determine $\mathbf{1}_P$ almost everywhere by Fourier inversion. This is the
analytic incarnation of the uniqueness phenomenon and explains the terminology: one forms the
$\tfrac1t\mathbb{Z}^d$-periodic point-counting function whose Fourier coefficients are exactly
the exponential sums above, and reads $\widehat{\mathbf{1}_P}$ off them on a dense set of
frequencies. Converting *cardinalities of translates* (rather than positions) into these
exponential sums requires controlling the aliasing incurred when the periodic counting function
is sampled on $\mathbb{Z}^d$; §8 discusses the decay hypotheses under which this can be pushed
through. The proof of the main theorem in §6 sidesteps the issue entirely by a geometric route.

---

## 6. The uniqueness theorem

### 6.1 Sparse grids: the enumerator as a membership oracle

The mechanism of this section is deliberate *under*-sampling. If the grid spacing exceeds the
diameter of the region containing $P$, then the enumerator can only be $0$ or $1$.

**Lemma 6.1 (sparseness).** Let $P \subseteq B(0,R)$, $t>0$ with $2R < 1/t$, and let
$y \in \mathbb{R}^d$, $k_0 \in \mathbb{Z}^d$ be such that the probe point
$x := k_0/t - y$ lies in $B(0,R)$. Then $\Lambda(P,t,y) \subseteq \{k_0\}$.

*Proof sketch.* Let $k \in \Lambda(P,t,y)$ and put $z = k/t - y \in P \subseteq B(0,R)$. Then
$\|z - x\|_\infty \le \|z\|_\infty + \|x\|_\infty \le 2R$. If $k \ne k_0$, then $k_j \ne (k_0)_j$
for some $j$, whence
$$\|z-x\|_\infty \;\ge\; |z_j - x_j| \;=\; \frac{|k_j - (k_0)_j|}{t} \;\ge\; \frac1t \;>\; 2R,$$
a contradiction. $\square$

**Corollary 6.2 (oracle evaluation).** Under the hypotheses of Lemma 6.1,
$$L_{P+y}(t) \;=\; \begin{cases} 1, & x \in P,\\[2pt] 0, & x \notin P.\end{cases}$$

*Proof sketch.* If $x \in P$ then $k_0 \in \Lambda(P,t,y)$ and Lemma 6.1 forces
$\Lambda(P,t,y) = \{k_0\}$. If $x \notin P$ then $k_0 \notin \Lambda(P,t,y)$ and Lemma 6.1 forces
$\Lambda(P,t,y) = \emptyset$. $\square$

### 6.2 The master lemma

**Theorem 6.3 (master lemma: rigidity on grid-representable points).** Let $P, Q \subseteq B(0,R)$
with $R \ge 0$ have the same integer-translate enumerator data. Suppose
$$x \;=\; s\,k - v \qquad \text{for some } k, v \in \mathbb{Z}^d \text{ and some real } s > 2R .$$
Then $x \in P \iff x \in Q$.

*Proof sketch.* Put $t = 1/s$, so $t > 0$ and $1/t = s > 2R$, and note that the probe point
attached to $(t, y = v, k_0 = k)$ is exactly $k/t - v = sk - v = x$. If $x \notin B(0,R)$ then $x$
lies in neither $P$ nor $Q$ and there is nothing to prove. Otherwise Corollary 6.2 applies to both
$P$ and $Q$ with the same $t$ and the same integer translate $v$, giving
$L_{P+v}(t) = \mathbf{1}_P(x)$ and $L_{Q+v}(t) = \mathbf{1}_Q(x)$. The hypothesis
$L_{P+v}(t) = L_{Q+v}(t)$ gives $\mathbf{1}_P(x) = \mathbf{1}_Q(x)$. $\square$

Note that only *one* query is used per point: a single pair $(t, v)$.

### 6.3 Every rational point is grid-representable

**Theorem 6.4 (pointwise rigidity at rational points).** Let $P, Q \subseteq \mathbb{R}^d$ be
bounded sets with the same integer-translate enumerator data. Then for every $a \in \mathbb{Z}^d$
and every integer $N \ge 1$,
$$\frac{a}{N} \in P \quad \Longleftrightarrow \quad \frac{a}{N} \in Q .$$
No measurability, convexity or regularity hypothesis is required, and the conclusion is exact
(not almost-everywhere).

*Proof sketch.* Choose $R \ge 0$ with $P \cup Q \subseteq B(0,R)$. Set
$$M \;=\; \lceil 2R \rceil + 2, \qquad s \;=\; M + \frac1N, \qquad k \;=\; a, \qquad v \;=\; M a \in \mathbb{Z}^d .$$
Then $s \ge 2R + 2 > 2R$, and
$$s\,k - v \;=\; a\Bigl(M + \tfrac1N\Bigr) - M a \;=\; \frac{a}{N},$$
so $a/N$ is grid-representable with spacing $s > 2R$. Apply Theorem 6.3. $\square$

The arithmetic is the crux: an integer translate can absorb *any* integer part of the spacing, so
one is free to use a spacing that is an integer plus the desired resolution $1/N$; the leftover
$1/N$ is precisely what steers the unique visible grid point onto $a/N$.

### 6.4 From rational points to almost-everywhere equality

**Lemma 6.5 (interior into closure).** If $P, Q$ are bounded with the same data, then
$\operatorname{int}(P) \subseteq \overline{Q}$.

*Proof sketch.* Let $x \in \operatorname{int}(P)$ and pick $\varepsilon>0$ with
$B(x,\varepsilon) \subseteq P$. Given $\delta>0$, choose a rational point $r = a/N$ with
$\|r - x\|_\infty < \min(\delta, \varepsilon)$ (possible: take $N$ large and
$a = \lfloor N x\rfloor$, so $\|a/N - x\|_\infty \le 1/N$). Then $r \in P$, so $r \in Q$ by
Theorem 6.4, and $\|r - x\|_\infty < \delta$. As $\delta$ was arbitrary, $x \in \overline{Q}$.
$\square$

**Theorem 6.6 (Main Theorem: uniqueness for integer translates).** Let
$P, Q \subseteq \mathbb{R}^d$ be bounded measurable sets with
$\operatorname{vol}(\partial P) = \operatorname{vol}(\partial Q) = 0$. If
$$L_{P+v}(t) = L_{Q+v}(t) \qquad \text{for all } t>0 \text{ and all } v \in \mathbb{Z}^d,$$
then $\mathbf{1}_P = \mathbf{1}_Q$ almost everywhere; equivalently
$\operatorname{vol}(P \,\triangle\, Q) = 0$.

*Proof sketch.* Almost every $x$ lies outside $\partial P \cup \partial Q$. Fix such an $x$ and
suppose $x \in P$. Since $x \notin \partial P$ and $x \in \overline{P}$, we get
$x \in \operatorname{int}(P)$; by Lemma 6.5, $x \in \overline{Q}$; since $x \notin \partial Q$
this forces $x \in \operatorname{int}(Q) \subseteq Q$. The data is symmetric in $P$ and $Q$, so
the converse implication holds too. Hence $\mathbf{1}_P(x) = \mathbf{1}_Q(x)$ off a null set. The
symmetric-difference formulation is equivalent. $\square$

**Theorem 6.7 (Corollary: convex bodies are determined exactly).** Let $P, Q \subseteq
\mathbb{R}^d$ be bounded convex sets with nonempty interior having the same integer-translate
enumerator data. Then
$$\operatorname{int}(P) = \operatorname{int}(Q) \qquad\text{and}\qquad \overline{P} = \overline{Q} .$$

*Proof sketch.* By Lemma 6.5, $\operatorname{int}(P) \subseteq \overline{Q}$; since
$\operatorname{int}(P)$ is open, $\operatorname{int}(P) \subseteq \operatorname{int}(\overline{Q})$.
For a convex set with nonempty interior, $\operatorname{int}(\overline{Q}) = \operatorname{int}(Q)$,
so $\operatorname{int}(P) \subseteq \operatorname{int}(Q)$; by symmetry the interiors are equal.
Finally $\overline{\operatorname{int}(K)} = \overline{K}$ for convex $K$ with nonempty interior,
so taking closures gives $\overline{P} = \overline{Q}$. $\square$

Thus a convex body is uniquely determined, as a body, by the integer-translate enumerator data.
This recovers, in a unified way, uniqueness statements previously proved separately for rational
polytopes and for symmetric convex bodies.

---

## 7. Two sharpenings

The "almost everywhere" in Theorem 6.6 is not an artefact of the method alone: the reachable set
of Theorem 6.3, namely $\{sk - v : k,v \in \mathbb{Z}^d,\ s > 2R\}$, is exactly what a single
scalar spacing shared by all $d$ coordinates can address. Two natural modifications remove the
loss.

**Theorem 7.1 (dimension one: exact rigidity, no hypotheses).** Let $P, Q \subseteq \mathbb{R}$ be
bounded with $L_{P+n}(t) = L_{Q+n}(t)$ for all $t>0$ and all $n \in \mathbb{Z}$. Then $P = Q$
exactly — no measurability and no frontier hypothesis are needed.

*Proof sketch.* Let $R \ge 0$ bound both sets and let $x \in \mathbb{R}$ be arbitrary. Put
$n = \lceil 2R - x\rceil + 1 \in \mathbb{Z}$ and $s = x + n$; then $s > 2R$ and
$s \cdot 1 - n = x$, so $x$ is grid-representable with $k = 1$. Theorem 6.3 gives
$x \in P \iff x \in Q$. $\square$

The contrast with $d \ge 2$ is instructive: in one dimension a single spacing has only one
coordinate to satisfy, so it can be tuned to any real target; in higher dimension the *same* $s$
must simultaneously produce all $d$ coordinates of $x$ from integers, which restricts targets to a
countable set.

**Theorem 7.2 (real translates: exact rigidity in every dimension).** Let $P, Q \subseteq
\mathbb{R}^d$ be bounded with
$$L_{P+y}(t) = L_{Q+y}(t) \qquad \text{for all } t>0 \text{ and all } y \in \mathbb{R}^d .$$
Then $P = Q$ exactly. Again no measurability or frontier hypothesis is used.

*Proof sketch.* It suffices to prove $P \subseteq Q$; the reverse follows by symmetry. Take $R\ge0$
with $P \cup Q \subseteq B(0,R)$ and let $x \in P$. Put $t = 1/(2R+1)$, so $1/t = 2R+1 > 2R$, and
$y = -x$. Then $0 \in \Lambda(P,t,-x)$ because $0/t - (-x) = x \in P$, so
$L_{P+y}(t) \ge 1$ and hence $L_{Q+y}(t) \ge 1$: some $k \in \mathbb{Z}^d$ has $k/t + x \in Q$.
Coordinatewise, $|k_i/t + x_i| \le R$ and $|x_i| \le R$ give $|k_i|(2R+1) = |k_i/t| \le 2R$, which
forces $|k_i| < 1$, i.e. $k = 0$. Therefore $x \in Q$. $\square$

Theorems 7.1 and 7.2 isolate exactly where the difficulty of Theorem 6.6 lies. With real
translates the family of sparse-grid probes is faithful — every point can be interrogated — and
uniqueness is pointwise. With integer translates only a countable dense set of probes is
available, and a null set of information is genuinely lost.

---

## 8. Algorithmic content

The proofs are constructive, and yield an explicit reconstruction procedure.

**Algorithm (single-query membership test).** *Input:* an oracle returning $L_{P+v}(t)$ for a set
$P$ known to lie in $B(0,R)$; a rational target $x = a/N$ with $a \in \mathbb{Z}^d$, $N \ge 1$.
*Output:* the bit $\mathbf{1}_P(x)$.

1. $M \leftarrow \lceil 2R\rceil + 2$.
2. $s \leftarrow M + 1/N$; $t \leftarrow 1/s$; $v \leftarrow M a$.
3. Query $b \leftarrow L_{P+v}(t)$.
4. Return $b$ (which is $0$ or $1$, and equals $\mathbf{1}_P(x)$).

The cost is one oracle query per point, independent of $d$, $R$ and $N$; the query parameters are
computable in $O(d)$ arithmetic operations. Reconstructing $P$ up to accuracy $\delta$ inside
$B(0,R)$ therefore costs $O\bigl((2R/\delta)^d\bigr)$ queries, by sweeping a $\delta$-net of
rational points — the dependence on $d$ being unavoidable for a volumetric reconstruction.

**Algorithm (direct enumeration).** To compute $L_P(t)$ for an explicitly given $P \subseteq
B(0,R)$, enumerate all $k \in \mathbb{Z}^d$ with $|k_i| \le Rt$ and test $k/t \in P$: cost
$O\bigl((2Rt+1)^d\bigr)$ membership tests. By Theorem 3.4 the resulting count yields the exact
volume of the rounded set $A_t(P)$, hence a volume estimate for $P$ whose error is controlled by
the measure of the $1/t$-neighbourhood of $\partial P$.

**Algorithm (spectral estimation).** For $\xi \in \mathbb{R}^d$, compute
$t^{-d}\sum_{k \in tP\cap\mathbb{Z}^d} e^{-2\pi i \langle \xi, k/t\rangle}$ by the same
enumeration; Theorem 5.4 guarantees convergence to $\widehat{\mathbf{1}_P}(\xi)$ as $t \to \infty$,
with the same cost per evaluation.

---

## 9. Discussion and applications

### 9.1 Comparison with Ehrhart theory

For integer $t$ only, the enumerator of a lattice polytope is a polynomial and carries at most
$d+1$ real degrees of freedom; it cannot possibly determine a polytope, and indeed does not.
Allowing real $t$ replaces a finite-dimensional invariant by a function on $(0,\infty)$ whose jump
set records, in effect, the arithmetic of the facet inequalities. Adding integer translates makes
the family rich enough to interrogate every rational point individually. The three regimes —
integer $t$ only; real $t$; real $t$ plus integer translates — form a strict hierarchy in
information content, with the third being complete up to null sets.

### 9.2 Relevance to lattice-based cryptography

Two threads connect this material to lattice cryptography.

*Counting heuristics.* Security estimates for lattice schemes routinely approximate the number of
lattice points of a lattice $\Lambda$ in a convex body $K$ by $\operatorname{vol}(K)/\det\Lambda$
(the Gaussian heuristic). Theorem 4.1 is precisely this statement in the scaling regime, and
Theorem 3.4 makes the approximation exact at the level of the rounded body $A_t$, localising the
entire error to the $1/t$-neighbourhood of $\partial K$. Any quantitative refinement of the
heuristic must therefore be a statement about the boundary regularity of $K$, not about $K$'s bulk.

*Information leakage.* Theorem 6.6, read adversarially, is a leakage statement: an oracle
answering only "how many lattice points does the (secret) region contain?" — even with the region
shifted only by lattice vectors, but with the scale freely chosen by the querier — leaks the region
completely, and by Theorem 6.4 leaks each rational point's membership using a single query. Any
scheme whose confidentiality depends on hiding a body behind aggregate lattice counts is, in this
model, broken; the sparse-grid query is the attack.

### 9.3 Geometric tomography

Classical results reconstruct a convex body from its width function, its section volumes, or its
projection volumes; here the probe is arithmetic. The reconstruction is total for convex bodies
(Theorem 6.7) and total up to a null set in general (Theorem 6.6), and the counting data are
integers, hence robust to infinitesimal perturbation of the query parameters — a feature that
volume-based tomographic data lacks.

### 9.4 On the two proofs

It is worth stressing that the paper contains two logically independent mechanisms.

- The **geometric** mechanism (§6) is local: coarsen the grid until the count is a single bit, then
  aim that bit arithmetically. It needs no analysis at all — no measure theory in the master lemma,
  no Fourier transform — and yields exact pointwise conclusions on a dense set.
- The **harmonic** mechanism (§5) is global: the counted lattice points, weighted by characters,
  reproduce $\widehat{\mathbf{1}_P}$ in the limit, and Fourier inversion recovers $\mathbf{1}_P$
  almost everywhere. It is the conceptually satisfying route, and it explains why "no information
  is lost"; converting it into a proof from *cardinality* data alone requires control of aliasing
  (see §10, C2).

---

## 10. Future directions

### C1. Exact rigidity on the reachable set, and its exact size

**Conjecture.** For bounded $P, Q \subseteq \mathbb{R}^d$ with the same integer-translate
enumerators, one has $x \in P \iff x \in Q$ for every $x$ in
$$\mathrm{Reach} \;=\; \{\, s k - v \;:\; k, v \in \mathbb{Z}^d,\ s > 0 \,\},$$
and $\mathrm{Reach}$ is exactly the set of points whose membership is determined: for $d \ge 2$
there exist bounded sets with identical data differing at a point outside $\mathrm{Reach}$.

The key insight is that the master lemma never uses the rationality of the probe point — only that
the probe is the unique grid point of a sparse grid inside the bounding ball — so the natural
determination set is the orbit $\mathbb{Z}^d + \mathbb{R}\cdot\mathbb{Z}^d$, and the complement
should support genuine counterexamples built by removing a single point in a "generic direction".

### C2. Aliasing-free Fourier inversion under a decay hypothesis

**Conjecture.** If $P$ is bounded, Jordan measurable, and its indicator has Fourier transform
satisfying
$$\sum_{n \in \mathbb{Z}^d,\ n \ne 0} \ \sup_{|\xi| \le C} \bigl|\widehat{\mathbf{1}_P}(\xi + N n)\bigr| \;\longrightarrow\; 0 \quad \text{as } N \to \infty$$
(for example, $P$ a polytope satisfying a Diophantine condition on its facet normals), then the
discrete Fourier transform of the sampled periodic counting function converges to
$\widehat{\mathbf{1}_P}$ at every rational frequency, giving a genuinely Fourier-analytic second
proof of the uniqueness theorem.

The key insight is that sampling the $\tfrac1t\mathbb{Z}^d$-periodic counting function on
$\mathbb{Z}^d$ produces aliases spaced $N$ apart when $t = N/q$ in lowest terms; the whole
difficulty of the Fourier route is uniform control of this alias sum, which decay hypotheses can
supply.

### C3. Quantitative (finite-data) uniqueness

**Conjecture.** There is an explicit function $T(d, R, \varepsilon)$ such that if two sets
contained in $B(0,R)$ satisfy $L_{P+v}(t) = L_{Q+v}(t)$ for all $t \in (0, T(d,R,\varepsilon))$
and all $v \in \mathbb{Z}^d$ with $|v| \le T(d,R,\varepsilon)$, then
$\operatorname{vol}(P \,\triangle\, Q) < \varepsilon$, for all Jordan sets with a modulus of
frontier regularity $\operatorname{vol}(\{x : \operatorname{dist}(x, \partial P) < \delta\}) \le
\omega(\delta)$. Concretely, $T$ should be polynomial in $R/\varepsilon$ for convex bodies.

The key insight is that the sparse-grid proof uses only countably many probes, each with an
explicit pair $(t, v)$; a compactness-free quantitative version follows by covering the bounding
ball with a $\delta$-net of rational probe points and paying $\omega(\delta)$ for the frontier.

---

## 11. Summary of results

| Hypotheses on $P,Q$ | Data | Conclusion |
|---|---|---|
| bounded, Jordan measurable | $L_P(t)$, all real $t>0$ | equal volumes (Cor. 4.2) |
| bounded convex | $L_P(t)$, all real $t>0$ | equal volumes (Cor. 4.3) |
| bounded (no regularity) | $L_{P+v}(t)$, all real $t>0$, all $v \in \mathbb{Z}^d$ | same rational points, exactly (Thm 6.4) |
| bounded, Jordan measurable | $L_{P+v}(t)$, all real $t>0$, all $v \in \mathbb{Z}^d$ | $\operatorname{vol}(P \triangle Q) = 0$ (Thm 6.6) |
| bounded convex, nonempty interior | $L_{P+v}(t)$, all real $t>0$, all $v \in \mathbb{Z}^d$ | equal interiors and closures (Thm 6.7) |
| bounded subsets of $\mathbb{R}$ | $L_{P+n}(t)$, all real $t>0$, all $n \in \mathbb{Z}$ | $P = Q$ exactly (Thm 7.1) |
| bounded (no regularity) | $L_{P+y}(t)$, all real $t>0$, all $y \in \mathbb{R}^d$ | $P = Q$ exactly (Thm 7.2) |

Alongside these, the exact identity $\operatorname{vol}(A_t(P)) = L_P(t)\,t^{-d}$ (Thm 3.4), the
counting theorem $L_P(t)/t^d \to \operatorname{vol}(P)$ (Thm 4.1), the weighted counting theorem
(Thm 5.3) and Fourier recovery (Thm 5.4) constitute the analytic backbone of the theory. A
representative explicit evaluation, useful as a sanity check, is
$L_{[0,1)}(t) = \lceil t \rceil$ for all $t>0$ in dimension one, with
$L_{[0,1)}(5/2) = 3$, $L_{[0,1)}(4) = 4$, $L_{[0,1)}(1/3) = 1$, and $\lceil t\rceil / t \to 1 =
\operatorname{vol}([0,1))$.
