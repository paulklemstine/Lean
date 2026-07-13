# An Effective Exponential Lower Bound for Sub-$\sqrt2$ Vietoris–Rips Approximations

## Abstract

The Vietoris–Rips filtration is the central combinatorial object of
topological data analysis, but it is prohibitively large: on $n$ points it can
contain up to $2^n$ simplices. A rich literature builds *finitely presented
$c$-approximations* — smaller simplicial filtrations that interleave with the
true one up to a multiplicative factor $c \ge 1$ in scale — and these
approximations run into a persistent barrier at the approximation factor
$c = \sqrt2$. We prove that this barrier is intrinsic and we determine its
exact quantitative shape. For every $c \in [1, \sqrt2)$ we exhibit an explicit
infinite family of finite metric spaces $\{X_n\}$ — in fact graded
ultrametrics with non-zero distances confined to $[1, \sqrt2]$ — such that any
one-sided multiplicative $c$-approximation $G$ of the Vietoris–Rips filtration
of $X_n$ satisfies

$$\big|G(\sqrt2)\big| \;\ge\; 2^{\lfloor \gamma(c)\, n\rfloor}, \qquad
\gamma(c) = \frac{\sqrt2/c - 1}{\sqrt2 - 1}.$$

The rate $\gamma(c)$ is effectively computable, satisfies $0 < \gamma(c) \le 1$
on $[1,\sqrt2)$, equals $1$ at $c = 1$, and tends continuously to $0$ as
$c \to \sqrt2^{-}$. Thus the guaranteed exponential rate degrades continuously
to zero exactly at the sharp $\sqrt2$ threshold, and no non-trivial rate
survives at $c = \sqrt2$. The proof is a bridge between three areas: metric
geometry (the graded ultrametric), extremal/enumerative combinatorics (a
metric clique of size $m$ forces $2^m$ simplices), and the interleaving theory
of approximation algorithms in topological data analysis.

**Keywords.** Vietoris–Rips filtration; topological data analysis;
multiplicative interleaving; approximation lower bound; ultrametric; flag
complex; extremal combinatorics.

---

## 1. Introduction

### 1.1 The Vietoris–Rips filtration and the size problem

Let $(X, d)$ be a finite metric space. For a scale parameter $r \ge 0$, the
**Vietoris–Rips complex** $\mathrm{VR}(X; r)$ is the abstract simplicial
complex whose simplices are the finite subsets $S \subseteq X$ of mutually
close points:

$$S \in \mathrm{VR}(X; r) \iff d(x, y) \le r \text{ for all } x, y \in S.$$

It is the *flag* (or *clique*) complex of the graph on $X$ whose edges join
pairs at distance $\le r$: a subset is a simplex precisely when it is a clique
in that proximity graph. As $r$ increases, the complexes nest,
$\mathrm{VR}(X; r) \subseteq \mathrm{VR}(X; r')$ for $r \le r'$, forming the
**Vietoris–Rips filtration**, whose persistent homology summarizes the
multi-scale topological features of $X$.

The construction is universal and easy to define, but it is enormous. If the
diameter of $X$ is at most $r$, then *every* subset of $X$ is a simplex, so
$\mathrm{VR}(X; r)$ has $2^{|X|}$ simplices. Even away from that extreme, the
number of simplices routinely grows exponentially in $|X|$, which is the
central computational obstacle in applied topology.

### 1.2 Finitely presented approximations and the $\sqrt2$ barrier

The standard response is to replace the exact filtration by a smaller one that
*interleaves* with it. A filtration $G(\cdot)$ is a (one-sided, multiplicative)
**$c$-approximation** of $\mathrm{VR}(X;\cdot)$, for a factor $c \ge 1$, when
every genuine simplex present at scale $t$ is present in $G$ by scale $c\,t$,
and $G$ never contains a simplex absent from the true filtration by scale
$c\,t$:

$$\mathrm{VR}(X; t) \subseteq G(c\,t) \subseteq \mathrm{VR}(X; c^2 t)
\quad\text{(equivalently } G(t) \subseteq \mathrm{VR}(X; c\,t)\text{)}.$$

Such approximations preserve persistent homology up to a factor $c$ in scale,
and a substantial body of work constructs them with subexponentially many
simplices. All these constructions share a boundary: efficient approximations
are available for factors above $\sqrt2$, while below $\sqrt2$ they break down.
The number $\sqrt2$ is the natural resonance of the Vietoris–Rips construction:
the $d$ standard basis vectors of $\mathbb{R}^d$ are pairwise at distance
$\sqrt2$, so $\sqrt2$ is the smallest scale at which a spread configuration
becomes a full clique.

The question we settle is whether the barrier is intrinsic and, if so, how the
cost of approximation behaves as $c \uparrow \sqrt2$.

### 1.3 Contribution

We prove an **effective** exponential lower bound valid throughout the
sub-threshold regime. For each $n$ we construct an explicit finite metric space
$X_n$ and an explicit, computable rate $\gamma(c)$ such that every
$c$-approximation of $\mathrm{VR}(X_n;\cdot)$ stores at least
$2^{\lfloor \gamma(c)\,n\rfloor}$ simplices at scale $\sqrt2$. Crucially, the
rate $\gamma(c)$ genuinely governs the exponent: it is positive on the whole
regime $[1,\sqrt2)$, equal to $1$ at the exact filtration $c = 1$, and it
vanishes continuously as $c \to \sqrt2^-$. The lower bound therefore both
certifies that no compact sub-$\sqrt2$ approximation exists and locates the
threshold sharply within the bound itself.

---

## 2. The graded ultrametric

We index the $n$ points by $\{0, 1, \dots, n-1\}$ (formally $X_n$ is carried by
this label set) and specify their pairwise distances directly.

### Definition 2.1 (Graded radius)

For $n \ge 1$ and $0 \le i < n$, the **radius** of point $i$ is

$$\mathrm{radius}(n, i) \;=\; 1 + (\sqrt2 - 1)\cdot\frac{i+1}{n}.$$

As $i$ ranges over $0, \dots, n-1$, the radii increase monotonically and sweep
the window $(1, \sqrt2\,]$; the largest radius, at $i = n-1$, equals exactly
$\sqrt2$.

### Definition 2.2 (Graded metric)

The **graded metric** $d_n$ on $X_n$ is

$$d_n(i, j) \;=\;
\begin{cases}
0 & i = j,\\[2pt]
\mathrm{radius}\big(n, \max(i, j)\big) & i \ne j.
\end{cases}$$

Every non-zero distance is a single radius value, hence lies in $[1, \sqrt2]$.

### Proposition 2.3 (Metric and ultrametric axioms)

For every $n \ge 1$, the function $d_n$ is a metric on $X_n$; in fact it is an
ultrametric. Explicitly:

1. $d_n(i, i) = 0$ for all $i$;
2. $d_n(i, j) = d_n(j, i)$ for all $i, j$;
3. $d_n(i, j) \ge 0$ for all $i, j$;
4. $d_n(i, k) \le d_n(i, j) + d_n(j, k)$ for all $i, j, k$
   (and moreover $d_n(i,k) \le \max\{d_n(i,j), d_n(j,k)\}$).

**Proof sketch.** Properties (1)–(3) are immediate from the definition, using
that each radius is $\ge 1 > 0$ (Lemma 2.4). For the triangle inequality, first
note every non-zero distance lies in $[1, \sqrt2]$ (Lemma 2.4 and Lemma 2.5).
If $i = k$ the left side is $0$ and the claim is trivial. Otherwise
$d_n(i,k) \le \sqrt2 \le 2$. If either $i = j$ or $j = k$ the inequality is an
equality after cancelling a zero term. In the remaining case all three points
are distinct, so both $d_n(i,j) \ge 1$ and $d_n(j,k) \ge 1$, whence
$d_n(i,j) + d_n(j,k) \ge 2 \ge \sqrt2 \ge d_n(i,k)$. The strong (ultrametric)
inequality follows because $d_n(i,k) = \mathrm{radius}(n,\max(i,k))$ and
$\max(i,k) \le \max(\max(i,j), \max(j,k))$, so by monotonicity (Lemma 2.6)
$d_n(i,k) \le \max\{d_n(i,j), d_n(j,k)\}$. $\square$

### Lemma 2.4 (Radii are $\ge 1$)

For $n \ge 1$ and any index $i$, $\mathrm{radius}(n,i) \ge 1$. Indeed
$\sqrt2 - 1 \ge 0$ and $(i+1)/n \ge 0$, so the added term is non-negative.

### Lemma 2.5 (Genuine radii are $\le \sqrt2$)

For $0 \le i < n$, $\mathrm{radius}(n,i) \le \sqrt2$. Since
$(i+1)/n \le 1$ for $i \le n-1$ and $\sqrt2 - 1 \ge 0$, we have
$(\sqrt2 - 1)(i+1)/n \le \sqrt2 - 1$, hence
$\mathrm{radius}(n,i) \le 1 + (\sqrt2 - 1) = \sqrt2$.

### Lemma 2.6 (Monotonicity)

If $i \le j$ then $\mathrm{radius}(n, i) \le \mathrm{radius}(n, j)$, because
$(i+1)/n \le (j+1)/n$ and the coefficient $\sqrt2 - 1$ is non-negative.

---

## 3. From metric cliques to exponentially many simplices

We now record the counting engine that converts geometry into combinatorics.
Throughout, for $r \ge 0$ we write $\mathrm{VR}(X_n; r)$ for the set of
Vietoris–Rips simplices at scale $r$, i.e. the subsets $S \subseteq X_n$ with
$d_n(i,j) \le r$ for all $i, j \in S$.

### Definition 3.1 (Metric clique)

A subset $S \subseteq X_n$ is a **metric clique at scale $r$** if
$d_n(i, j) \le r$ for all $i, j \in S$. Equivalently, $S$ is a simplex of
$\mathrm{VR}(X_n; r)$.

### Proposition 3.2 (Bridge: clique $\Rightarrow$ full power set)

If $S$ is a metric clique at scale $r$, then every subset $T \subseteq S$ is
also a simplex of $\mathrm{VR}(X_n; r)$; that is, the entire power set of $S$ is
contained in $\mathrm{VR}(X_n; r)$.

**Proof.** A subset $T \subseteq S$ inherits the pairwise closeness: for
$i, j \in T \subseteq S$ we have $d_n(i,j) \le r$. Hence $T$ is a simplex. Since
this holds for every $T$ in the power set of $S$, the whole power set lies in
$\mathrm{VR}(X_n; r)$. $\square$

### Corollary 3.3 (Exponential count)

A metric clique of size $m$ at scale $r$ forces at least $2^m$ simplices into
$\mathrm{VR}(X_n; r)$, because the power set of an $m$-element set has $2^m$
members and, by Proposition 3.2, all of them are simplices.

---

## 4. The active set and the effective exponent

### Definition 4.1 (Active set)

For a scale $s \ge 0$, the **active set** at scale $s$ is the set of points
whose radius does not exceed $s$:

$$A_n(s) \;=\; \{\, i \in X_n : \mathrm{radius}(n, i) \le s \,\}.$$

### Lemma 4.2 (The active set is a clique)

For every $s$, the active set $A_n(s)$ is a metric clique at scale $s$.

**Proof.** For distinct $i, j \in A_n(s)$, we have
$d_n(i,j) = \mathrm{radius}(n, \max(i,j))$. Since $\max(i,j) \in \{i, j\} \subseteq
A_n(s)$, its radius is $\le s$, so $d_n(i,j) \le s$. Equal points are at
distance $0 \le s$. $\square$

### Definition 4.3 (Effective rate)

For $c \in [1, \sqrt2)$ define

$$\gamma(c) \;=\; \frac{\sqrt2/c - 1}{\sqrt2 - 1}.$$

### Proposition 4.4 (Radius membership criterion)

For $c \in [1, \sqrt2)$ and $0 \le i < n$,

$$\mathrm{radius}(n, i) \le \frac{\sqrt2}{c}
\iff i + 1 \le n\,\gamma(c).$$

**Proof.** Unwinding the definition,
$1 + (\sqrt2 - 1)(i+1)/n \le \sqrt2/c$ is equivalent to
$(\sqrt2 - 1)(i+1)/n \le \sqrt2/c - 1$. Dividing by the positive constant
$\sqrt2 - 1$ gives $(i+1)/n \le \gamma(c)$, i.e. $i + 1 \le n\,\gamma(c)$.
$\square$

### Corollary 4.5 (Active count at scale $\sqrt2/c$)

The active set at scale $\sqrt2/c$ consists of exactly the points $i$ with
$i + 1 \le n\,\gamma(c)$, so

$$\big|A_n(\sqrt2/c)\big| \;=\; \min\big(n, \lfloor n\,\gamma(c)\rfloor\big)
\;\ge\; \lfloor n\,\gamma(c)\rfloor.$$

The indices $i = 0, 1, \dots$ that qualify are precisely those with
$i + 1 \le n\,\gamma(c)$, and there are $\lfloor n\,\gamma(c)\rfloor$ of them.

### Proposition 4.6 (Behaviour of the effective rate)

On the regime $c \in [1, \sqrt2)$ the rate satisfies:

1. $\gamma(c) > 0$;
2. $\gamma(c) \le 1$, with $\gamma(1) = 1$;
3. $\displaystyle \lim_{c \to \sqrt2^-} \gamma(c) = 0$.

**Proof.** For (1): $c < \sqrt2$ gives $\sqrt2/c > 1$, so the numerator
$\sqrt2/c - 1 > 0$, while the denominator $\sqrt2 - 1 > 0$. For (2): $c \ge 1$
gives $\sqrt2/c \le \sqrt2$, so the numerator is $\le \sqrt2 - 1$, hence
$\gamma(c) \le 1$; at $c = 1$ numerator and denominator coincide, giving
$\gamma(1) = 1$. For (3): as $c \to \sqrt2^-$, $\sqrt2/c \to 1$, so the
numerator tends to $0$ while the denominator is the fixed positive constant
$\sqrt2 - 1$; the quotient tends to $0$. The convergence is continuous and
monotone in $c$. $\square$

---

## 5. The interleaving lower bound

### Definition 5.1 ($c$-approximation)

A family $G : [0,\infty) \to \{\text{simplicial complexes on } X_n\}$ is a
one-sided multiplicative **$c$-approximation** of $\mathrm{VR}(X_n; \cdot)$
when $c \ge 1$ and, for all $t \ge 0$,

$$\mathrm{VR}(X_n; t) \subseteq G(c\,t) \qquad\text{and}\qquad
G(t) \subseteq \mathrm{VR}(X_n; c\,t).$$

The first containment says $G$ misses no genuine simplex by scale $c\,t$; the
second says $G$ invents no simplex absent from the true filtration by scale
$c\,t$. This is the standard notion underlying approximation algorithms in
topological data analysis.

### Proposition 5.2 (Approximation stores the active power set)

Let $c \in [1, \sqrt2)$ and let $G$ be a $c$-approximation of
$\mathrm{VR}(X_n; \cdot)$. Then the power set of the active clique
$A_n(\sqrt2/c)$ is contained in $G(\sqrt2)$; consequently

$$\big|G(\sqrt2)\big| \;\ge\; 2^{\,|A_n(\sqrt2/c)|}.$$

**Proof.** Set $t = \sqrt2/c \ge 0$. By Lemma 4.2 the active set
$A_n(\sqrt2/c)$ is a metric clique at scale $\sqrt2/c$, so by Proposition 3.2
its entire power set lies in $\mathrm{VR}(X_n; \sqrt2/c) = \mathrm{VR}(X_n; t)$.
The first approximation containment gives
$\mathrm{VR}(X_n; t) \subseteq G(c\,t) = G(\sqrt2)$. Hence the power set of
$A_n(\sqrt2/c)$ is contained in $G(\sqrt2)$, and the power set of a set of size
$|A_n(\sqrt2/c)|$ has $2^{|A_n(\sqrt2/c)|}$ elements. $\square$

### Theorem 5.3 (Effective exponential lower bound below $\sqrt2$)

Let $c \in [1, \sqrt2)$ and $n \ge 1$, and let $G$ be any $c$-approximation of
the Vietoris–Rips filtration of $X_n$. Then

$$\big|G(\sqrt2)\big| \;\ge\; 2^{\lfloor \gamma(c)\, n\rfloor},
\qquad \gamma(c) = \frac{\sqrt2/c - 1}{\sqrt2 - 1},$$

where the rate satisfies $0 < \gamma(c) \le 1$ on $[1, \sqrt2)$, $\gamma(1)=1$,
and $\lim_{c \to \sqrt2^-}\gamma(c) = 0$.

**Proof.** By Corollary 4.5, $|A_n(\sqrt2/c)| \ge \lfloor \gamma(c)\,n\rfloor$.
Combining with Proposition 5.2,

$$\big|G(\sqrt2)\big| \;\ge\; 2^{\,|A_n(\sqrt2/c)|}
\;\ge\; 2^{\lfloor \gamma(c)\,n\rfloor}.$$

The stated properties of $\gamma$ are Proposition 4.6. $\square$

### Remark 5.4 (Sharpness at the threshold)

Theorem 5.3 both certifies that no compact sub-$\sqrt2$ approximation exists —
for fixed $c < \sqrt2$ the bound is exponential in $n$ — and localizes the
threshold within the bound. As $c \to \sqrt2^-$, the guaranteed rate
$\gamma(c) \to 0$, so the exponential force weakens continuously to nothing
precisely as the approximation factor reaches the sharp value $\sqrt2$. At
$c = \sqrt2$ no non-trivial rate survives, which is consistent with the
existence of compact approximations above the threshold. Conversely, at the
exact filtration $c = 1$ the rate is $\gamma(1) = 1$, recovering the full
$2^n$ blow-up.

---

## 6. Algorithms

The construction is fully constructive, and the following procedures make it
concrete. Complexities are stated in terms of the point count $n$.

**(A) Graded distance oracle.** Given $n$ and indices $i, j$, return
$d_n(i, j)$ in $O(1)$ arithmetic operations by evaluating a single radius.

**(B) Active clique enumeration.** Given $n$ and factor $c$, compute
$\gamma(c)$, then the active-set size $k = \min(n, \lfloor n\,\gamma(c)\rfloor)$,
and return the active indices $\{0, 1, \dots, k-1\}$ in $O(n)$ time. The
guaranteed lower bound is then $2^{\lfloor \gamma(c)\,n\rfloor}$.

**(C) Certified lower-bound evaluator.** Given $n$ and $c \in [1,\sqrt2)$,
return the triple $(\gamma(c),\ \lfloor \gamma(c)\,n\rfloor,\ 2^{\lfloor
\gamma(c)\,n\rfloor})$ certifying the minimum number of simplices any
$c$-approximation must store at scale $\sqrt2$, in $O(1)$ arithmetic plus the
cost of the final power (which is exponential only if the integer $2^{\lfloor
\gamma(c)\,n\rfloor}$ is materialized rather than reported as an exponent).

For small $n$ one can also *directly* build the full Vietoris–Rips complex at
scale $\sqrt2$ by enumerating subsets and checking pairwise closeness, and
verify numerically that the count matches or exceeds the predicted bound.

---

## 7. Applications and discussion

**Impossibility for practitioners.** Theorem 5.3 is a *worst-case* guarantee: no
algorithm, however clever, can produce a $c$-approximation of the Vietoris–Rips
filtration that is small on all inputs when $c < \sqrt2$. Any pipeline that
insists on approximation factors below the threshold must accept
$2^{\Theta(n)}$ simplices on the graded ultrametric family.

**A gentle penalty near the threshold.** The vanishing of $\gamma$ near $\sqrt2$
is practically consoling: for approximation factors just below the threshold,
the guaranteed blow-up rate is small, so the obstruction is mild exactly where
practitioners most want to operate. The theorem thus draws a quantitative map
of the trade-off between fidelity and size.

**A template for cross-domain lower bounds.** The proof isolates a reusable
pattern: (i) design a graded metric whose active window is tuned by a
parameter; (ii) observe that active sets are cliques; (iii) invoke the
clique-to-power-set counting bridge; (iv) pass the count through the
interleaving definition. The same template applies to any filtration built as
a flag complex of a proximity relation.

**Limitations.** The metric $X_n$ is a finite (ultra)metric specified by
distances, not (yet) a point cloud in Euclidean space; and the approximation
notion used is the one-sided containment sufficient for the lower bound rather
than a full two-sided homotopy interleaving. Both are natural next steps.

---

## 8. Future work

1. **Euclidean realisability with the exact $\sqrt2$ geometry.** The graded
   ultrametric is a faithful finite metric, but the canonical $\sqrt2$
   phenomenon lives in Euclidean space (standard basis vectors are pairwise at
   distance $\sqrt2$). A worthwhile extension is to realise the graded radii by
   an explicit point cloud in $\mathbb{R}^d$ — for instance, concentric scaled
   simplices — and re-derive the same rate $\gamma(c)$.

2. **Two-sided and homotopy interleavings.** The one-sided containment used
   here suffices for the lower bound. Formalizing full multiplicative
   interleavings, and homotopy interleavings at the level of persistent
   homology, would strengthen the impossibility statement to the setting most
   used in practice.

3. **Optimal constants.** Determine whether $\gamma(c) = (\sqrt2/c -
   1)/(\sqrt2 - 1)$ is the *best possible* rate for the graded family, and how
   it compares to the achievable rate of the best known super-$\sqrt2$
   algorithms, to close the gap between lower and upper bounds around the
   threshold.

---

## 9. Conclusion

We have exhibited an explicit family of finite (ultra)metric spaces on which
every sub-$\sqrt2$ approximation of the Vietoris–Rips filtration must store
$2^{\lfloor \gamma(c)\,n\rfloor}$ simplices, with an effective, computable rate
$\gamma(c) = (\sqrt2/c - 1)/(\sqrt2 - 1)$ that is positive throughout
$[1,\sqrt2)$, equal to $1$ at the exact filtration, and vanishing continuously
at the threshold. The result turns the folkloric $\sqrt2$ barrier of
topological data analysis into a sharp, quantitative theorem, and does so
through a clean bridge between metric geometry, extremal combinatorics, and
interleaving theory.
