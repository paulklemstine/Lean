# Planck-Foam Topology: Quantum Fluctuation Geometry at $10^{-35}$ Metres

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We develop a rigorous topological model of Wheeler's spacetime foam in which the Planck-scale bifurcation of geometry is encoded as a *branched quotient space*. Given a topological space $X$ (macroscopic spacetime), a **branch locus** $S \subseteq X$ (the set of Planck cells at which the geometry bifurcates), and an index set $\iota$ of **sheets**, the **foam** $\mathcal{F}(X,S,\iota)$ is the quotient of $X \times \iota$ (with $\iota$ discrete) by the relation identifying $(x,i)$ with $(y,j)$ exactly when $x = y$ and either $i = j$ or $x \notin S$. The line with two origins is the special case $X = \mathbb{R}$, $S = \{0\}$, $|\iota| = 2$.

We prove a complete separation-axiom characterisation: with at least two sheets, $\mathcal{F}(X,S,\iota)$ is Hausdorff iff $X$ is Hausdorff **and** $S$ is open; it is $T_1$ iff $X$ is; and it fails $R_1$ whenever some branch point lies outside $\mathrm{int}\,S$, so the failure of Hausdorffness is not repairable by a Kolmogorov quotient. We prove an **invisibility theorem**: when $\mathrm{int}\,S = \varnothing$, every continuous map from the foam to a Hausdorff space factors uniquely through the macroscopic projection $\pi : \mathcal{F}(X,S,\iota) \to X$, so no Hausdorff-valued observable resolves the branching. We exhibit a faithful $\mathrm{Sym}(\iota)$ gauge action, faithful exactly when $S \neq \varnothing$, acting trivially on all such observables.

We quantify the failure of metrizability: the set of ordered pairs of distinct foam points with non-disjoint neighbourhood filters is in bijection with $(S \setminus \mathrm{int}\,S) \times \{(i,j) : i \neq j\}$, so its cardinality is $|S \setminus \mathrm{int}\,S| \cdot (|\iota|^2 - |\iota|)$ — a pure **boundary** quantity, independent of branch density. We determine the covering locus exactly: $\pi$ is a covering map iff $S$ is clopen, which on connected $X$ forces $S = \varnothing$ or $S = X$; for closed $S$, $\pi$ is nonetheless always a local homeomorphism.

On the stochastic side we equip the $N$-cell Planck lattice with a Bernoulli($p$) branch measure and compute exactly: the probability of a Hausdorff foam is $(1-p)^N \le e^{-pN}$; the Shannon entropy over $n$ cells is $n\,\mathcal{H}(p)$ with maximum $n\log 2$ attained iff $p = 1/2$; the second moment of the branch count is $np(1-p) + (np)^2$, hence variance $np(1-p)$, yielding the Chebyshev concentration bound $p(1-p)/(N\varepsilon^2)$ for the branch density. An **entropy–geometry duality** identifies the maximal-entropy value with $\log(2^{\mathrm{exc}})$, where $\mathrm{exc} = |S|\,(|\iota|-1)$ is the excess cardinality of the foam over its macroscopic shadow. Finally, we analyse the scale-halving renormalisation flow $\ell \mapsto 2\ell$ on lattice foams and show it is **persistent**: the only fixed lattice foam is $S = \{0\}$, the tower of any nonzero lattice converges to $\{0\}$ rather than to smooth spacetime, and that limit is still non-Hausdorff with metric defect exactly $2$.

**Keywords:** Wheeler foam, non-Hausdorff topology, branched quotient, line with two origins, Planck scale, covering space, Shannon entropy, renormalisation flow.

---

## 1. Introduction

### 1.1 The physical problem

Wheeler's *spacetime foam* hypothesis holds that the smooth pseudo-Riemannian description of spacetime cannot persist below the Planck length
$$\ell_P = \sqrt{\hbar G / c^3} \approx 1.616 \times 10^{-35}\ \mathrm{m}.$$
The heuristic estimate is that metric fluctuations $\delta g$ over a region of size $L$ scale as $\ell_P / L$, so at $L \sim \ell_P$ the fluctuations are $O(1)$ and the geometry — including the topology — is no longer determinate.

Formalising "the topology is not determinate" is delicate. Path-integral approaches sum over topologies; causal-set approaches discretise; loop approaches replace the manifold with combinatorial data. This paper explores a fourth, deliberately minimal option that keeps the point-set language intact:

> **Modelling principle.** If the geometry at a Planck cell has no single answer, the cell should be represented by *several coincident points* — one per branch of the fluctuation — which are topologically inseparable from each other and indistinguishable to any observer outside the cell.

The mathematical object that realises this principle is a **non-Hausdorff branched quotient**, of which the classical *line with two origins* is the two-sheeted, one-cell instance. Non-Hausdorff manifolds are usually treated as pathologies. Here we treat the pathology as the physics and ask what it entails.

### 1.2 Contributions

1. A general construction $\mathcal{F}(X,S,\iota)$ and a complete separation-axiom analysis (§3).
2. A universal property showing the foam is invisible to Hausdorff-valued observables (§4).
3. A faithful sheet-permutation gauge group acting trivially on observables (§5).
4. An exact counting formula and an entropy–geometry duality (§6, §7).
5. An exact metric-defect formula, showing the obstruction to metrizability is a boundary count (§8).
6. A covering-space dichotomy, closing the question of when the foam is a bona fide multi-sheeted spacetime (§9).
7. A stochastic layer with exact first and second moments, Chebyshev concentration of the branch density, and exponential improbability of smoothness (§10).
8. A renormalisation analysis of lattice foams, including the **refutation** of the natural conjecture that only the trivial and total branch loci are fixed points (§11).

Two claims that arose naturally in the course of the work turned out to be **false** and are recorded as such in §12, because a negative result is as informative as a positive one here.

---

## 2. The foam construction

Throughout, $X$ is a topological space, $S \subseteq X$ is a subset called the **branch locus**, and $\iota$ is a nonempty type of **sheet indices**, always given the discrete topology.

**Definition 2.1 (Foam relation).** On $X \times \iota$ define
$$(x, i) \sim (y, j) \iff x = y \ \wedge \ \big( i = j \ \vee \ x \notin S \big).$$

**Lemma 2.2.** $\sim$ is an equivalence relation.

*Proof.* Reflexivity and symmetry are immediate. For transitivity, suppose $(x,i)\sim(y,j)\sim(z,k)$. Then $x = y = z$. If $x \notin S$ the second clause holds outright; otherwise both steps must have used $i = j$ and $j = k$, so $i = k$. $\square$

**Definition 2.3 (Foam).** The **foam** is the quotient space
$$\mathcal{F}(X,S,\iota) := (X \times \iota)\big/\!\sim,$$
with the quotient topology. Write $[x,i]$ for the class of $(x,i)$.

**Definition 2.4 (Sheets and projection).** For $i \in \iota$ the **sheet inclusion** is $s_i : X \to \mathcal{F}(X,S,\iota)$, $s_i(x) = [x,i]$. The **macroscopic projection** is $\pi : \mathcal{F}(X,S,\iota) \to X$, $\pi([x,i]) = x$ (well defined since $\sim$ preserves the first coordinate).

**Lemma 2.5 (Basic structure).**
(a) $\pi \circ s_i = \mathrm{id}_X$, and each $s_i$ is continuous; $\pi$ is continuous, surjective, and a quotient map.
(b) $s_i(x) = s_j(y)$ iff $x = y$ and ($i = j$ or $x \notin S$).
(c) Every point of the foam is $s_i(x)$ for some $i, x$.
(d) A set $U \subseteq \mathcal{F}(X,S,\iota)$ is open iff $s_i^{-1}(U)$ is open in $X$ for every $i$.

*Proof sketch.* (a)–(c) are direct from the definition; the quotient-map property of $\pi$ holds because $\pi$ is continuous, surjective, and admits the continuous section $s_{i_0}$. (d) is the definition of the quotient topology transported along the homeomorphism $X \times \iota \cong \coprod_{i} X$ afforded by discreteness of $\iota$. $\square$

**Example 2.6 (Line with two origins).** $X = \mathbb{R}$, $S = \{0\}$, $\iota = \{0,1\}$. The foam has two points over $0$ and one over each $x \neq 0$.

**Example 2.7 (Lattice foam).** $X = \mathbb{R}$, $S = \Lambda_\ell := \{\ell n : n \in \mathbb{Z}\}$, $\iota = \{0,1\}$: a doubled point at every Planck site of spacing $\ell$.

**Example 2.8 (Stochastic Planck foam).** $X = \mathbb{R}$; fix $N$ Planck cells and a finite subset $A \subseteq \{0,\dots,N-1\}$ of *excited* cells; put $S = \{\ell k : k \in A\}$, $\iota = \{0,1\}$. This is the object on which §10 places a probability measure.

**Definition 2.9 (Foam structure of a sheet).** For $S$ closed, each $s_i$ is an **open embedding**: $s_i$ is injective onto its image, and $s_i(U)$ is open for every open $U$, because $s_j^{-1}(s_i(U)) = U$ for $j = i$ and $U \setminus S$ for $j \neq i$, both open. Hence **the foam is locally homeomorphic to $X$** whenever $S$ is closed: it is a "manifold" in every local sense.

---

## 3. Separation axioms

**Theorem 3.1 ($T_1$).** If $\iota$ is nonempty, then $\mathcal{F}(X,S,\iota)$ is $T_1$ if and only if $X$ is $T_1$.

*Proof sketch.* ($\Leftarrow$) The complement of $\{[x,i]\}$ pulls back along $s_j$ to $X \setminus \{x\}$ (for $j = i$, or when $x \in S$) or to $X\setminus\{x\}$ again (otherwise), open by $T_1$-ness of $X$; apply Lemma 2.5(d). ($\Rightarrow$) $\{x\} = s_{i_0}^{-1}(\{s_{i_0}(x)\})$ is closed as the preimage of a closed set. $\square$

**Theorem 3.2 (Separation Theorem).** Suppose $\iota$ has at least two elements. Then
$$\mathcal{F}(X,S,\iota)\ \text{is Hausdorff} \iff X \ \text{is Hausdorff and } S \ \text{is open}.$$

*Proof sketch.* ($\Leftarrow$) Let $u \neq v$. If $\pi(u) \neq \pi(v)$, separate their projections in $X$ and pull back along $\pi$ (Lemma 3.4 below). If $\pi(u) = \pi(v) = x$ then $x \in S$ and $u = s_i(x)$, $v = s_j(x)$ with $i \neq j$; since $S$ is open, $s_i(S)$ and $s_j(S)$ are disjoint open neighbourhoods (disjointness uses that on $S$ the sheets are never identified).

($\Rightarrow$) Hausdorffness of $X$ follows by pulling back along the embedding $s_{i_0}$. For openness of $S$: let $x \in S$ and pick $i \neq j$. Hausdorffness gives disjoint open $U \ni s_i(x)$, $V \ni s_j(x)$. Then $s_i^{-1}(U) \cap s_j^{-1}(V)$ is an open neighbourhood $W$ of $x$. If some $y \in W$ had $y \notin S$, then $s_i(y) = s_j(y)$ would lie in $U \cap V = \varnothing$. Hence $W \subseteq S$, so $x \in \mathrm{int}\,S$. $\square$

**Corollary 3.3 (Physical dichotomy).** A branch locus with empty interior — in particular any nonempty discrete set of Planck sites — always destroys Hausdorffness; a branch locus that is open never does. In particular the lattice foam and the stochastic Planck foam are Hausdorff **iff** no cell is excited.

**Lemma 3.4 (Confinement).** If $\pi(u) \neq \pi(v)$ and $X$ is Hausdorff, then $u$ and $v$ have disjoint neighbourhoods. Non-Hausdorffness is therefore confined entirely to the Planck fibres.

**Theorem 3.5 (No repair by Kolmogorov quotient).** Assume $X$ is $T_1$, $|\iota| \ge 2$, and there is $x \in S \setminus \mathrm{int}\,S$. Then $\mathcal{F}(X,S,\iota)$ is not $R_1$.

*Proof sketch.* $R_1$ says any two topologically distinguishable points have disjoint neighbourhoods. The foam is $T_1$ by Theorem 3.1, so all distinct points are distinguishable; but $s_i(x)$ and $s_j(x)$ ($i\ne j$) are not separable by Theorem 3.2's argument. $\square$

This matters physically: one cannot rescue a Hausdorff spacetime by declaring topologically indistinguishable points equal, because the offending points *are* distinguishable — they are just not separable.

**Theorem 3.6 (Branching limits).** Let $\ell > 0$ and let $x = \ell k$ be an excited Planck site of the lattice foam. Define $y_n = x + \ell/(n+2)$. Then no $y_n$ is a branch point, $y_n \to x$ in $\mathbb{R}$, and the single foam sequence $u_n := s_0(y_n) = s_1(y_n)$ satisfies
$$u_n \to s_0(x) \quad\text{and}\quad u_n \to s_1(x), \qquad s_0(x) \ne s_1(x).$$

*Proof sketch.* The spacing estimate: if $0 < t < \ell$ then $\ell k + t$ is not a lattice site, since $\ell m = \ell k + t$ forces $k < m < k+1$. Hence $y_n \notin S$, so $s_0(y_n) = s_1(y_n)$. Continuity of $s_0$ and $s_1$ then gives convergence to $s_0(x)$ and to $s_1(x)$ respectively, and these differ because $x \in S$. $\square$

This is the constructive face of non-Hausdorffness: **one trajectory, two limit geometries**. Where the fluctuation is "heading" is not determined by the trajectory.

**Theorem 3.7 (Connectivity survives).** For any $\ell$ and any configuration $A$, the Planck foam over the line is path connected.

*Proof sketch.* The foam is the union of the two sheet images $s_0(\mathbb{R})$ and $s_1(\mathbb{R})$, each the continuous image of a path-connected space, hence path connected. Since the branch locus is finite, its complement is nonempty; picking $x_0 \notin S$ gives $s_0(x_0) = s_1(x_0)$, a common point of the two images. A union of two path-connected sets with a common point is path connected. $\square$

Branching multiplies points but does not tear spacetime: the foam is a connected, path-connected, locally Euclidean, $T_1$, non-Hausdorff space.

---

## 4. The invisibility theorem

**Theorem 4.1 (Universal Hausdorff factorisation).** Assume $\iota$ is nonempty and $\mathrm{int}\,S = \varnothing$. Let $Y$ be a Hausdorff space and $f : \mathcal{F}(X,S,\iota) \to Y$ continuous. Then there exists a **unique** continuous $g : X \to Y$ with $f = g \circ \pi$.

*Proof sketch.* Set $g := f \circ s_{i_0}$ for a fixed base sheet $i_0$; it is continuous. To see $f = g \circ \pi$ it suffices to prove $f(s_i(x)) = f(s_{i_0}(x))$ for all $i, x$. If $x \notin S$ the two arguments are equal. If $x \in S$, then $x \notin \mathrm{int}\,S$, so every neighbourhood of $x$ contains a point $y \notin S$; hence $s_i(x)$ and $s_{i_0}(x)$ have no disjoint neighbourhoods (any pair of neighbourhoods contains a common $s(y)$). A continuous map into a Hausdorff space identifies non-separated points: if $f(s_i(x)) \ne f(s_{i_0}(x))$, pull back disjoint neighbourhoods of the two images to obtain disjoint neighbourhoods of the two branches, a contradiction. Uniqueness follows since $\pi$ is surjective. $\square$

**Corollary 4.2 (Observational blindness).** No continuous $\mathbb{R}$-valued (or $\mathbb{R}^n$-valued, or manifold-valued) observable on the Planck foam distinguishes two branches over a Planck site.

Thus $X$ is the **universal Hausdorff-valued receptacle** of the foam: measurements factor through the smooth shadow, even though the foam is not homeomorphic to $X$ (they have different cardinalities, by §6). The model therefore predicts exactly what experiment reports — nothing.

---

## 5. The sheet-permutation gauge group

**Definition 5.1.** For $\sigma \in \mathrm{Sym}(\iota)$ define $\Sigma_\sigma : \mathcal{F}(X,S,\iota) \to \mathcal{F}(X,S,\iota)$ by $\Sigma_\sigma([x,i]) = [x,\sigma(i)]$.

**Lemma 5.2.** $\Sigma_\sigma$ is well defined, a homeomorphism, and $\pi \circ \Sigma_\sigma = \pi$.

*Proof sketch.* Well-definedness: the relation $\sim$ is $\sigma$-equivariant in the second coordinate. Continuity follows from the quotient property; $\Sigma_{\sigma^{-1}}$ is the inverse. Commutation with $\pi$ is immediate. $\square$

**Theorem 5.3 (Faithfulness).** $\sigma \mapsto \Sigma_\sigma$ is a group homomorphism $\mathrm{Sym}(\iota) \to \mathrm{Homeo}(\mathcal{F}(X,S,\iota))$, and it is **injective if and only if $S \neq \varnothing$**.

*Proof sketch.* Homomorphy is a computation. If $x \in S$ and $\Sigma_\sigma = \mathrm{id}$, then $[x,\sigma(i)] = [x,i]$ for all $i$, and since $x \in S$ this forces $\sigma(i) = i$. Conversely if $S = \varnothing$ the foam is $X$ and every $\Sigma_\sigma$ is the identity. $\square$

**Theorem 5.4 (Gauge invariance of observables).** If $\mathrm{int}\,S = \varnothing$, every continuous Hausdorff-valued $f$ on the foam satisfies $f \circ \Sigma_\sigma = f$ for all $\sigma$.

*Proof.* By Theorem 4.1, $f = g \circ \pi$, and $\pi \circ \Sigma_\sigma = \pi$. $\square$

Theorems 5.3 and 5.4 together constitute a gauge principle *derived* rather than postulated: the symmetry is faithful exactly when there is foam, and simultaneously invisible to every observable.

---

## 6. Counting: the excess of a foam

**Theorem 6.1 (Skeleton decomposition).** As a set,
$$\mathcal{F}(X,S,\iota) \ \cong\ S^{c} \ \sqcup\ (S \times \iota).$$

*Proof sketch.* Off $S$ all sheets are identified, giving one point per element of $S^c$; on $S$ no two sheets are identified, giving $|\iota|$ points per element of $S$. $\square$

**Corollary 6.2 (Counting formula).** For finite $X$ and $\iota$,
$$\#\mathcal{F}(X,S,\iota) = \#S^c + \#S \cdot \#\iota = \#X + \#S\,(\#\iota - 1).$$

**Definition 6.3 (Excess).** $\mathrm{exc}(X,S,\iota) := \#\mathcal{F}(X,S,\iota) - \#X = \#S \cdot (\#\iota - 1)$: exactly one extra point per branch point per extra sheet.

For two-sheeted foam, $\mathrm{exc} = \#S$: **the excess *is* the number of Planck branch points.**

---

## 7. Stochastic foam I: entropy and the entropy–geometry duality

Fix a finite set $s$ of Planck cells and $p \in [0,1]$. A configuration is a subset $A \subseteq s$ of excited cells with **Bernoulli weight**
$$w_p^{s}(A) := \prod_{i \in s} \begin{cases} p & i \in A\\ 1-p & i \notin A.\end{cases}$$

**Lemma 7.1 (Probability measure and mean).** $\sum_{A \subseteq s} w_p^s(A) = 1$ and $\sum_{A \subseteq s} w_p^s(A)\,\#A = \#s \cdot p$.

*Proof sketch.* Induction on $s$, splitting the powerset of $s \cup \{a\}$ into subsets containing and omitting $a$; the recursion $w^{s\cup\{a\}}_p(A) = (1-p)\,w^s_p(A)$ and $w^{s\cup\{a\}}_p(A\cup\{a\}) = p\,w^s_p(A)$ makes both identities immediate. $\square$

**Definition 7.2.** The **foam entropy** (in nats) is $H_p(s) := -\sum_{A \subseteq s} w_p^s(A)\,\log w_p^s(A)$.

**Theorem 7.3 (Extensivity).** For $0 < p < 1$,
$$H_p(s) = \#s \cdot \mathcal{H}(p), \qquad \mathcal{H}(p) := -p\log p - (1-p)\log(1-p).$$

*Proof sketch.* The key identity, proved by induction on $s$, is
$$\sum_{A\subseteq s} w^s_p(A) \log w^s_p(A) = \#s\,\big(p\log p + (1-p)\log(1-p)\big),$$
using the same two-branch recursion together with $\sum_A w = 1$ and $\log(cw) = \log c + \log w$. $\square$

**Corollary 7.4 (One bit per Planck cell).** $H_p(s) \le \#s \cdot \log 2$, with equality if and only if $p = 1/2$ or $s = \varnothing$.

*Proof.* $\mathcal{H}(p) \le \log 2$ with equality iff $p = 1/2$. $\square$

**Theorem 7.5 (Entropy–geometry duality).** For the two-sheeted foam over the cell set $s$, at the maximal-entropy value $p = 1/2$,
$$H_{1/2}(s) = \log\big(2^{\,\mathrm{exc}}\big), \qquad \mathrm{exc} = \mathrm{exc}(s, s, \{0,1\}) = \#s.$$

*Proof.* $H_{1/2}(s) = \#s \log 2$ by Theorem 7.3 and $\mathcal{H}(1/2) = \log 2$; and $2^{\#s}$ is precisely the number of distinct branch configurations, i.e. the number of distinct foam geometries the branch bits can produce. $\square$

This is an *exact* identity, not an asymptotic one: the counting entropy of the skeleton decomposition and the Shannon entropy of the Bernoulli foam measure coincide with no error term. Geometry and information agree on the nose.

**Theorem 7.6 (Smoothness is exponentially improbable).** For $N$ Planck cells,
$$\Pr[\mathcal{F} \text{ is Hausdorff}] = \sum_{A : \mathcal{F}(A)\ \mathrm{Hausdorff}} w_p(A) = (1-p)^N \ \le\ e^{-pN}.$$

*Proof sketch.* By Corollary 3.3 the foam is Hausdorff iff $A = \varnothing$ (a nonempty finite subset of $\mathbb{R}$ is never open), so the sum collapses to the single term $w_p(\varnothing) = (1-p)^N$. The bound follows from $1 - p \le e^{-p}$. $\square$

**Corollary 7.7 (Maximal-entropy foam).** At $p = 1/2$ the probability of a Hausdorff foam over $N$ cells is $2^{-N}$.

**Theorem 7.8 (Continuum limit).** At fixed macroscopic length $L > 0$ and fixed $p > 0$, the expected number of branch points in $[0,L]$ diverges as the Planck spacing $\ell \to 0^+$.

*Proof sketch.* The number of cells is $\lfloor L/\ell\rfloor$ and the mean branch count is $p\lfloor L/\ell\rfloor \to \infty$. $\square$

---

## 8. Stochastic foam II: concentration of the branch density

**Theorem 8.1 (Second moment).** For any $p$ and finite cell set $s$ with $n = \#s$,
$$\sum_{A \subseteq s} w^s_p(A)\,(\#A)^2 = np(1-p) + (np)^2.$$

*Proof sketch.* Induction on $s$. Adjoining a cell $a$, the powerset splits into $A$ and $A \cup \{a\}$; using $\#(A\cup\{a\}) = \#A + 1$ one gets
$$w^{s\cup\{a\}}(A)(\#A)^2 = (1-p)\,w^s(A)(\#A)^2,$$
$$w^{s\cup\{a\}}(A\cup\{a\})(\#A+1)^2 = p\,w^s(A)(\#A)^2 + 2p\,w^s(A)\#A + p\,w^s(A).$$
Summing and applying the induction hypothesis together with Lemma 7.1 gives $np(1-p)+(np)^2 + 2np\cdot p + p = (n+1)p(1-p) + ((n+1)p)^2$ after simplification. $\square$

**Corollary 8.2 (Variance).** $\displaystyle\sum_{A\subseteq s} w^s_p(A)\big(\#A - np\big)^2 = np(1-p).$

*Proof.* Expand the square and use Theorem 8.1, Lemma 7.1, and normalisation. $\square$

**Theorem 8.3 (Chebyshev for the foam measure).** For $0 \le p \le 1$ and $t > 0$,
$$\sum_{\substack{A \subseteq s \\ |\#A - np| \ge t}} w^s_p(A) \ \le\ \frac{np(1-p)}{t^2}.$$

*Proof sketch.* On the summation range $1 \le (\#A - np)^2/t^2$; since all weights are nonnegative (each factor is $p \ge 0$ or $1-p \ge 0$), bounding the indicator by that ratio and extending the sum to all $A$ gives the variance divided by $t^2$. $\square$

**Theorem 8.4 (Branch density is macroscopically deterministic).** For $N \ge 1$ cells, $0 \le p \le 1$ and $\varepsilon > 0$,
$$\Pr\left[\ \left|\frac{\#A}{N} - p\right| \ \ge\ \varepsilon\ \right] \ \le\ \frac{p(1-p)}{N\varepsilon^2} \ \xrightarrow[N\to\infty]{}\ 0 .$$

*Proof.* Apply Theorem 8.3 with $t = N\varepsilon$, using $|\#A - Np| = N\,|\#A/N - p|$. $\square$

Physically: although each Planck cell is an independent coin flip, a macroscopic region contains $\sim L/\ell_P$ cells, and the observed branch density is then sharply concentrated at $p$. **The foam has a well-defined density even though it has no deterministic microstructure.** This is precisely the mechanism by which a stable effective description can emerge from a violently fluctuating substrate.

---

## 9. The metric defect

Non-Hausdorff spaces are not metrizable, so a genuine foam admits **no Planck-scale distance function**. We quantify the failure.

**Definition 9.1 (Defect set).** $\mathcal{D}(X,S,\iota) := \{(u,v) \in \mathcal{F}^2 : u \ne v \ \wedge\ \neg\,\mathrm{Disjoint}(\mathcal{N}_u, \mathcal{N}_v)\}$, where $\mathcal{N}_u$ is the neighbourhood filter of $u$. These are the ordered pairs a metric would have to separate but cannot.

**Theorem 9.2 (Localisation).** Let $X$ be Hausdorff, $x \in S$, $i \neq j$. Then $s_i(x)$ and $s_j(x)$ have disjoint neighbourhood filters **iff** $x \in \mathrm{int}\,S$.

*Proof sketch.* If $x \in \mathrm{int}\,S$, take $s_i(\mathrm{int}\,S)$ and $s_j(\mathrm{int}\,S)$: these are disjoint (no identification occurs over $S$) and open. Conversely, disjoint neighbourhoods pull back to a neighbourhood $W$ of $x$ contained in $S$, exactly as in Theorem 3.2. $\square$

**Theorem 9.3 (Characterisation of the defect set).** For Hausdorff $X$,
$$(u,v) \in \mathcal{D} \iff \exists\, x \in S \setminus \mathrm{int}\,S,\ \exists\, i \ne j,\ u = s_i(x),\ v = s_j(x).$$

*Proof sketch.* If $\pi(u) \ne \pi(v)$ the pair is separated by Lemma 3.4. If $\pi(u) = \pi(v) = x$ and $u \ne v$ then $x \in S$ and the branches differ; apply Theorem 9.2. $\square$

**Theorem 9.4 (Defect formula).** For Hausdorff $X$ and finite $\iota$, there is a bijection
$$\mathcal{D}(X,S,\iota) \ \cong\ (S \setminus \mathrm{int}\,S)\ \times\ \{(i,j) \in \iota^2 : i \ne j\},$$
hence
$$\#\mathcal{D}(X,S,\iota) = \#\big(S \setminus \mathrm{int}\,S\big)\cdot\big(\#\iota^2 - \#\iota\big),$$
and for two sheets $\#\mathcal{D} = 2\,\#\big(S\setminus\mathrm{int}\,S\big)$.

*Proof sketch.* Theorem 9.3 gives a surjection from the right-hand side; injectivity holds because $s_i(x) = s_j(y)$ with $x, y \in S$ forces $x=y$, $i=j$. The cardinality of the off-diagonal of a finite set is $\#\iota^2 - \#\iota$. $\square$

**Interpretation.** The distance from metrizability is a **purely boundary quantity**. It depends only on $\partial$-type data $S \setminus \mathrm{int}\,S$, not on the size, measure, or density of $S$. A branch locus can be measure-theoretically enormous yet metrically harmless (if open), or a single point and already fatal: the line with two origins has defect exactly $2$. In particular, *the metric defect is not a function of the branch density*.

**Corollary 9.5 (Non-metrizability).** If $S$ is not open, $\mathcal{F}(X,S,\iota)$ ($|\iota| \ge 2$) carries no metric inducing its topology.

---

## 10. The covering dichotomy

Is the foam a multi-sheeted covering of spacetime? The answer is a clean dichotomy.

**Definition 10.1 (Sheet number).** $\nu(x) := \#\,\pi^{-1}(\{x\})$.

**Lemma 10.2.** $\nu(x) = \#\iota$ for $x \in S$ and $\nu(x) = 1$ for $x \notin S$. If $S$ is closed then $\nu$ is upper semicontinuous.

**Theorem 10.3 (Local homeomorphism).** If $S$ is closed, $\pi$ is a local homeomorphism.

*Proof sketch.* By Definition 2.9 each sheet is an open embedding when $S$ is closed, and $\pi$ restricted to $s_i(X)$ inverts $s_i$; since the sheet images are open and cover the foam, $\pi$ is locally a homeomorphism. $\square$

**Definition 10.4 (Sheet index observable).** Fix $i_0 \in \iota$ and define $\mathrm{ind} : \mathcal{F} \to \iota$ by $\mathrm{ind}([x,i]) = i$ if $x \in S$ and $i_0$ otherwise. This is well defined precisely because non-branch points have singleton fibres.

**Theorem 10.5.** $\mathrm{ind}$ is continuous (for $|\iota| \ge 2$) **iff** $S$ is clopen.

**Theorem 10.6 (Covering Dichotomy).** For $|\iota| \ge 2$,
$$\pi : \mathcal{F}(X,S,\iota) \to X \ \text{is a covering map} \iff S\ \text{is clopen}.$$

*Proof sketch.* ($\Leftarrow$) If $S$ is clopen, the foam splits as the topological sum of the foam over $S$ (which is $S \times \iota$) and the foam over $S^c$ (which is $S^c$), and $\pi$ restricts to the trivial $\#\iota$-fold covering on the first and a homeomorphism on the second; both are locally trivial, and local triviality is a local condition on the base, which the clopen partition supplies. ($\Rightarrow$) A covering map has locally constant fibre cardinality. By Lemma 10.2, $\nu$ takes value $\#\iota \ge 2$ on $S$ and $1$ off it, so local constancy forces both $S$ and $S^c$ to be open. $\square$

**Corollary 10.7 (Connected spacetime).** If $X$ is connected and $|\iota| \ge 2$, then $\pi$ is a covering map iff $S = \varnothing$ (no foam) or $S = X$ (uniformly foamy space).

**Interpretation.** A "multi-sheeted spacetime" in the honest, covering-space sense exists only in the two degenerate regimes. A genuine Wheeler foam — isolated Planck branch points in a smooth background — is a locally Euclidean, non-covering, non-Hausdorff space, and the obstruction is precisely the failure of local constancy of the sheet number on the topological boundary of the branch locus. Note that this is the *same* boundary set $S \setminus \mathrm{int}\,S$ that controls the metric defect: one geometric invariant governs both obstructions.

---

## 11. Renormalisation: the foam is persistent

Coarse-graining should thin out the foam. Formally:

**Definition 11.1 (Coarse-graining map).** For $S' \subseteq S$, define $c_{S,S'} : \mathcal{F}(X,S,\iota) \to \mathcal{F}(X,S',\iota)$ by $[x,i] \mapsto [x,i]$.

**Theorem 11.2.** $c_{S,S'}$ is well defined, continuous, surjective, commutes with the macroscopic projections, and is functorial: $c_{S',S''}\circ c_{S,S'} = c_{S,S''}$ for $S'' \subseteq S' \subseteq S$. Moreover, for $|\iota| \ge 2$,
$$c_{S,S'} \text{ is injective} \iff S = S'.$$
At the bottom of the tower, $\mathcal{F}(X,\varnothing,\iota) \cong X$: **a foam with empty branch locus is just smooth spacetime.**

*Proof sketch.* Well-definedness: $S' \subseteq S$ makes $\sim_S$ finer than $\sim_{S'}$. Injectivity fails exactly at a point of $S \setminus S'$, where two sheets are distinct upstairs and identified downstairs. $\square$

**The physical flow.** Let $\Lambda_\ell := \{x \in \mathbb{R} : \exists n \in \mathbb{Z},\ x = \ell n\}$ be the lattice branch locus of Planck spacing $\ell$, and consider the **scale-halving step** $\ell \mapsto 2\ell$ (observing the foam at twice the Planck length).

**Lemma 11.3.** $\Lambda_{2\ell} \subseteq \Lambda_\ell$, with strict inclusion whenever $\ell \ne 0$.

**Theorem 11.4 (Classification of fixed points).** $\Lambda_{2\ell} = \Lambda_\ell \iff \ell = 0$. Since $\Lambda_0 = \{0\}$, the **only fixed lattice foam is the single-branch-point foam** $S = \{0\}$, i.e. the line with two origins.

*Proof sketch.* If $\ell \ne 0$ then $\ell \in \Lambda_\ell \setminus \Lambda_{2\ell}$ (as $\ell = 2\ell n$ forces $n = 1/2 \notin \mathbb{Z}$), so the inclusion is strict. Conversely $\Lambda_0 = \{0\} = \Lambda_{0}$. $\square$

**Theorem 11.5 (Limit of the tower).** For $\ell \ne 0$,
$$\bigcap_{k \ge 0} \Lambda_{2^k \ell} = \{0\}.$$

*Proof sketch.* $0$ lies in every $\Lambda_{2^k\ell}$. Conversely, if $x \ne 0$ lies in every $\Lambda_{2^k\ell}$ then $|x| \ge 2^k|\ell|$ for all $k$ (nonzero elements of $\Lambda_m$ have absolute value $\ge |m|$), which is impossible. $\square$

**Theorem 11.6 (Persistence).** The limit foam $\mathcal{F}(\mathbb{R},\{0\},\{0,1\})$ is **not** Hausdorff, and its metric defect is exactly $2$. Moreover every step of the flow destroys information: $c_{\Lambda_\ell, \Lambda_{2\ell}}$ is not injective for $\ell \ne 0$.

*Proof.* $\{0\}$ is not open in $\mathbb{R}$, so Theorem 3.2 applies; $\mathrm{int}\{0\} = \varnothing$, so $\#\mathcal{D} = 2 \cdot 1 = 2$ by Theorem 9.4; non-injectivity is Theorem 11.2 with $\Lambda_{2\ell} \subsetneq \Lambda_\ell$. $\square$

**Interpretation and a refuted conjecture.** One naturally conjectures that the only fixed points of the scale-halving flow are the trivial ones, $S = \varnothing$ and $S = \mathbb{R}$. Theorem 11.4 **refutes** this: the flow has a nontrivial fixed point, the single-branch-point foam, which is genuinely non-Hausdorff. And Theorem 11.5 shows the flow does not reach smooth spacetime from any nonzero lattice: it terminates one doubled point short. **Wheeler foam is renormalisation-persistent.** Coarse-graining thins the foam forever but never sterilises it — and since defect $2 \neq 0$, one can never blur one's way back to a metric space.

---

## 12. Refutations recorded

Two plausible claims arising in this programme are false; we record them because they sharpen the correct statements.

**Refutation 1 (No gauge anomaly from sections).** It is tempting to claim that when the branch locus has empty interior, $\pi$ admits no continuous section — an "anomaly" obstructing a global choice of branch. **This is false**: each sheet inclusion $s_i$ is a continuous section, and it is even an open embedding when $S$ is closed. The correct obstruction is not the nonexistence of a section but the failure of *local constancy of the fibre cardinality*, sharpened into the covering dichotomy of Theorem 10.6.

**Refutation 2 (RG fixed points are not only the trivial ones).** As discussed in §11, the conjecture that the scale-halving flow fixes only $S = \varnothing$ and $S = \mathbb{R}$ is false; the fixed lattice foams are exactly those of spacing $0$, i.e. $S = \{0\}$.

---

## 13. Numerical illustrations

Exact rational computation on small cell sets confirms the analytic formulas.

| Quantity | Parameters | Value | Prediction |
|---|---|---|---|
| Total mass $\sum_A w(A)$ | $p = 1/3$, $n = 0..5$ | $1,1,1,1,1,1$ | $1$ |
| Mean $\sum_A w(A)\#A$ | $p = 1/3$, $n = 4$ | $4/3$ | $np = 4/3$ |
| Mean | $p = 2/5$, $n = 6$ | $12/5$ | $12/5$ |
| Second moment | $p = 1/3$, $n = 3$ | $5/3$ | $np(1-p)+(np)^2 = 5/3$ |
| Second moment | $p = 2/5$, $n = 4$ | $88/25$ | $88/25$ |
| Variance | $p = 1/3$, $n = 5$ | $10/9$ | $np(1-p) = 10/9$ |
| Variance | $p = 2/5$, $n = 6$ | $36/25$ | $36/25$ |
| $\Pr[\text{Hausdorff}]$ | $p = 1/2$, $N = 5$ | $1/32$ | $(1-p)^N = 1/32$ |
| $\Pr[\text{Hausdorff}]$ | $p = 1/3$, $N = 4$ | $16/81$ | $16/81$ |

Entropy in nats: $H_{0.5}(4) = 2.772589 = 4\log 2$; $H_{0.3}(5) = 3.054322 = 5\,\mathcal{H}(0.3)$; $H_{0.7}(3) = 1.832593$; $H_{0.25}(6) = 3.374011$.

Two further sanity checks worth quoting. At $p = 1/2$ and $N = 40$, $\Pr[\text{Hausdorff}] = 2^{-40} \approx 9.1\times 10^{-13}$: even forty Planck cells make smoothness essentially impossible. And for $p = 1/2$, $\varepsilon = 0.05$, the Chebyshev bound $p(1-p)/(N\varepsilon^2)$ drops below $1\%$ once $N \ge 10^4$ — over a macroscopic length, where $N \sim L/\ell_P \sim 10^{35}$, the deviation bound is of order $10^{-33}$.

---

## 14. Discussion

### 14.1 What the model gets right

The construction reproduces, as theorems rather than assumptions, a cluster of features one would demand of any Planck-scale ontology:

- **Local ordinariness.** For closed branch loci the foam is locally homeomorphic to spacetime; nothing about a local experiment can detect the branching (Theorem 10.3, Definition 2.9).
- **Global inaccessibility.** Every continuous Hausdorff-valued observable factors through the smooth shadow (Theorem 4.1). The foam is *provably* invisible to the class of measurements physics uses.
- **Gauge structure.** An internal $\mathrm{Sym}(\iota)$ symmetry is faithful exactly when foam is present and acts trivially on observables (Theorems 5.3, 5.4).
- **Information bookkeeping.** One bit per Planck cell, with equality at maximal foaminess, and an exact identification of that entropy with the logarithm of the geometric excess (Corollary 7.4, Theorem 7.5).
- **Emergent determinism.** The branch density concentrates (Theorem 8.4), so a macroscopic effective geometry exists even though every cell fluctuates.
- **Robustness.** Coarse-graining never removes all branching (Theorems 11.4–11.6).

### 14.2 The two boundary theorems

A notable structural discovery is that the *same* set, $S \setminus \mathrm{int}\,S$, controls two apparently unrelated obstructions: the metric defect (Theorem 9.4) and the failure of the covering property (Theorem 10.6). In both cases the pathology is generated not by branch points *per se* but by branch points that are limits of smooth points. A Planck cell buried inside an open foamy region is harmless; a Planck cell adjacent to smooth spacetime is where the geometry breaks. This suggests that if the physical foam were "thick" — a fully open Planck-scale region rather than an isolated lattice — the model would degenerate into an ordinary metrizable covering. **The pathology is an interface phenomenon.**

### 14.3 Limitations

The model is topological only. It carries no metric (indeed provably cannot), no causal structure, no dynamics, and no quantum amplitude: the Bernoulli measure is a classical product measure over branch configurations, not a state. The sheets carry no internal labels beyond their index, so there is no notion of "which geometry" a branch represents. And $X = \mathbb{R}$ is a placeholder for a four-dimensional Lorentzian manifold; extending to that setting is straightforward for §§2–10, but the renormalisation analysis of §11 uses one-dimensional lattice arithmetic in an essential way.

### 14.4 Relation to other approaches

The construction sits between two familiar poles. It is *not* a discretisation: the base remains a continuum and the foam is locally Euclidean. It is also *not* a sum over topologies: a single fixed space carries all branches simultaneously, with a probability measure over branch loci rather than over geometries. What it shares with both is the prediction that Planck-scale structure is operationally inaccessible — but here that inaccessibility is a theorem with a precise scope (Hausdorff-valued continuous observables) rather than a dimensional-analysis estimate.

---

## 15. Future directions

**A. Homotopical rigidity.** For $X = \mathbb{R}$, a finite branch locus $S$ with $\#S = k$, and two sheets, we conjecture that $\mathcal{F}(\mathbb{R},S,\{0,1\})$ is weakly homotopy equivalent to a wedge of $k$ circles; in particular $\pi_1 \cong F_k$, the free group of rank $k$. The key insight is that each doubled Planck site behaves exactly like a branch cut gluing two contractible copies of the line along the complement of a point, and each such gluing should contribute one independent loop. Establishing this would give the foam a computable homotopy invariant that *does* see the branching, in sharp contrast to the invisibility theorem for Hausdorff-valued observables.

**B. Higher-dimensional and Lorentzian foam.** Replace $\mathbb{R}$ by a four-dimensional Lorentzian manifold and the lattice by a Poisson process of branch points at density $\ell_P^{-4}$. The separation, invisibility, gauge, counting, entropy, and concentration results carry over verbatim; the defect and covering theorems require the boundary $S \setminus \mathrm{int}\,S$, which for a Poisson point process is all of $S$. The open question is whether the branch density can be tied to a curvature scale.

**C. Dynamics on the foam.** Since the foam admits no metric, one cannot write a wave equation on it directly. But one can ask for the sheaf of continuous functions, or for the behaviour of a diffusion whose generator is defined on each sheet: what happens to a random walker reaching a branch point? A natural guess is that the process splits with weights determined by the sheet index, giving a stochastic-process avatar of the two-limit phenomenon of Theorem 3.6.

**D. Sharper concentration.** Chebyshev gives $O(1/(N\varepsilon^2))$. Since the branch count is a sum of independent Bernoulli variables, Hoeffding-type bounds should give $2e^{-2N\varepsilon^2}$, and a matching lower bound via the central limit theorem would pin the fluctuation of the branch density at the $\sqrt{N}$ scale exactly.

**E. Beyond two sheets.** All results are stated for general $\iota$, but the physically interesting question is whether $\#\iota$ should be fixed or itself fluctuate. A foam whose sheet number is a random variable per cell would have entropy $\sum_x \mathcal{H}(\text{distribution of } \nu(x))$ and defect $\sum_{x \in \partial S} (\nu(x)^2 - \nu(x))$; both formulas are immediate generalisations of Theorems 7.3 and 9.4, but the resulting space is no longer a quotient of a product and requires a genuinely new construction.

**F. Where the thread stands.** The core theory is complete: a full separation-axiom characterisation, the observational invisibility, the faithful gauge group, extensive entropy with the one-bit-per-cell bound, and Chebyshev concentration of the branch density. Of the five conjectures posed after the first phase, four are now settled — the metric defect is a boundary quantity; entropy–geometry duality holds as an exact identity with no error term; the covering locus is exactly the clopen regime; and the renormalisation fixed-point conjecture is *refuted*. Only the homotopical rigidity conjecture (A) remains open.

---

## 16. Summary of main results

1. **Separation Theorem.** With $\#\iota \ge 2$: $\mathcal{F}(X,S,\iota)$ is Hausdorff iff $X$ is Hausdorff and $S$ is open; it is $T_1$ iff $X$ is; and it fails $R_1$ whenever $S \not\subseteq \mathrm{int}\,S$.
2. **Branching limits.** Over an excited Planck site, one sequence of foam points converges to two distinct limits, and the foam is nonetheless path connected.
3. **Invisibility Theorem.** For $\mathrm{int}\,S = \varnothing$, every continuous Hausdorff-valued map on the foam factors uniquely through the macroscopic projection.
4. **Gauge Theorem.** $\mathrm{Sym}(\iota)$ acts by homeomorphisms over $X$, faithfully iff $S \neq \varnothing$, and trivially on all Hausdorff-valued observables.
5. **Counting.** $\#\mathcal{F} = \#X + \#S(\#\iota - 1)$.
6. **Entropy.** $H_p(s) = \#s\,\mathcal{H}(p) \le \#s\log 2$, with equality iff $p = 1/2$; and $H_{1/2}(s) = \log(2^{\mathrm{exc}})$.
7. **Smoothness probability.** $(1-p)^N \le e^{-pN}$.
8. **Concentration.** Second moment $np(1-p)+(np)^2$, variance $np(1-p)$, and $\Pr[|\#A/N - p| \ge \varepsilon] \le p(1-p)/(N\varepsilon^2)$.
9. **Metric defect.** $\#\mathcal{D} = \#(S \setminus \mathrm{int}\,S)\,(\#\iota^2 - \#\iota)$, hence $2\,\#(S\setminus\mathrm{int}\,S)$ for two sheets.
10. **Covering dichotomy.** $\pi$ is a covering map iff $S$ is clopen; on connected $X$, iff $S \in \{\varnothing, X\}$.
11. **Renormalisation persistence.** The scale-halving flow fixes $\Lambda_\ell$ iff $\ell = 0$; $\bigcap_k \Lambda_{2^k\ell} = \{0\}$ for $\ell \neq 0$; the limit foam is non-Hausdorff with defect $2$.
