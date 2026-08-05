# Magnitude Homology of Tope Graphs: The Boolean Arrangement, the Hypercube, and Hilbert Functions

**Author:** Aristotle
**Date:** 2026-08-05

---

## Abstract

The magnitude of a finite metric space, introduced by Leinster, is a numerical invariant that behaves like a cardinality; Hepworth and Willerton categorified it for graphs, producing a bigraded family of abelian groups $MH_{k,\ell}(G)$ whose graded Euler characteristic is the magnitude power series. The *tope graph* of a real hyperplane arrangement — vertices the chambers, edges the pairs of chambers separated by a single hyperplane — carries a metric in which distance equals the number of separating hyperplanes. A recent line of work determines the magnitude homology of tope graphs completely: it is *diagonal*, and its ranks are the values of Hilbert functions of Stanley–Reisner rings of simplicial complexes naturally attached to the arrangement; for reflection arrangements this computes the magnitude homology of Cayley graphs of Coxeter groups, and for central arrangements it exhibits a homological reciprocity.

This paper develops the theory in complete, self-contained detail for the smallest nontrivial family — the arrangement of the $n$ coordinate hyperplanes in $\mathbb{R}^n$ — and proves several structural results valid for arbitrary connected graphs. We establish: (i) the chamber geometry of the coordinate arrangement, including the identification of separation sets with symmetric differences; (ii) the resulting isometry $d(C_s, C_t) = |s \triangle t|$, identifying the tope graph with the $n$-cube; (iii) for every connected graph, freeness of $MH_{1,1}$ on ordered edges, surjectivity of the degree-$2$ magnitude differential in all lengths $\ell \ge 2$, and hence the vanishing $MH_{1,\ell} = 0$ for $\ell \ge 2$; (iv) the identification $MH_{2,2}(G) \cong \ker \delta_2$ for every connected graph, with rank $\#MC_{2,2}(G) - \#MC_{1,2}(G)$ in the finite case; (v) exact counts $\operatorname{rank} MC_{1,\ell} = 2^n\binom{n}{\ell}$ and $\operatorname{rank} MC_{2,\ell} = 2^n\big(\binom{2n}{\ell} - 2\binom{n}{\ell}\big)$ for the $n$-cube, yielding $MH_{2,2} \cong \mathbb{Z}^{2^n\binom{n+1}{2}}$ — exactly $2^n$ times the degree-$2$ value of the Hilbert function of a polynomial ring in $n$ variables, as the Stanley–Reisner description predicts — and the rank $2^n\big(\binom{2n}{\ell} - 3\binom{n}{\ell}\big)$ of the $(2,\ell)$-cycle group for all $\ell \ge 2$; and (vi) an isomorphism of the tope graph with the Cayley graph of the Coxeter group $(\mathbb{Z}/2)^n$ with respect to its simple reflections, together with the transport of all of the above along graph isomorphisms, which are shown to be isometries.

**Keywords:** magnitude homology; tope graph; hyperplane arrangement; hypercube; Coxeter group; Stanley–Reisner ring; Hilbert function; diagonality.

---

## 1. Introduction

### 1.1 Magnitude and its categorification

Let $(X,d)$ be a finite metric space and $q$ a formal variable. The *similarity matrix* of $X$ is $Z = (q^{d(x,y)})_{x,y \in X}$, and when $Z$ is invertible the **magnitude** of $X$ is the sum of all entries of $Z^{-1}$. Leinster introduced this quantity as an "effective number of points": it is multiplicative for $\ell^1$-products, additive for suitably transverse unions, and in the continuous setting encodes volume, surface area and even Minkowski dimension asymptotically.

For a finite connected graph $G$ with the shortest-path metric, magnitude is a rational function of $q$ that expands as a power series with integer coefficients,
$$\#G(q) = \sum_{\ell \ge 0} c_\ell(G)\, q^{\ell}.$$

Hepworth and Willerton categorified this invariant. Their **magnitude homology** $MH_{\ast,\ast}(G)$ is a bigraded abelian group with
$$\#G(q) \;=\; \sum_{k,\ell \ge 0} (-1)^k \operatorname{rank} MH_{k,\ell}(G)\, q^{\ell},$$
so that $c_\ell(G) = \sum_k (-1)^k \operatorname{rank} MH_{k,\ell}(G)$: the magnitude power series is the graded Euler characteristic of a homology theory. Magnitude homology sees strictly more than magnitude: it detects, for example, the presence of geodesics that fail to be unique, and it is functorial for distance-non-increasing maps in an appropriate sense.

### 1.2 Tope graphs

A finite collection $\mathcal{A} = \{H_1,\dots,H_m\}$ of affine hyperplanes in $\mathbb{R}^d$ cuts the complement $\mathbb{R}^d \setminus \bigcup_i H_i$ into finitely many connected components, the **chambers** or **topes**. Two topes are *adjacent* when exactly one hyperplane of $\mathcal{A}$ separates them; the resulting graph is the **tope graph** $T(\mathcal{A})$.

The metric of a tope graph is entirely combinatorial:

> **Separation principle.** In the tope graph of a real hyperplane arrangement, the distance between two topes equals the number of hyperplanes separating them.

This is a theorem of Tits in the Coxeter setting, and holds for all real arrangements (indeed for all oriented matroids). It is the reason tope graphs are so amenable: their metric geometry is set-theoretic.

Tope graphs are a wide class. Every finite Coxeter group $W$ has a reflection arrangement whose tope graph is the Cayley graph $\mathrm{Cay}(W,S)$ with respect to the simple reflections, the graph distance being word length. Tope graphs of arrangements are, up to the usual translations, exactly the *lopsided* / *complex of oriented matroids* graphs, and they include the hypercubes, the permutohedral graphs (weak Bruhat orders of symmetric groups), and more.

### 1.3 The theorem being developed

The result motivating this paper is:

> **Theorem (Magnitude homology of tope graphs).** For every real hyperplane arrangement $\mathcal{A}$, the tope graph $T(\mathcal{A})$ is *diagonal*: $MH_{k,\ell}(T(\mathcal{A})) = 0$ whenever $k \ne \ell$. On the diagonal, the groups $MH_{\ell,\ell}(T(\mathcal{A}))$ are free abelian of rank
> $$\sum_{T \text{ a tope}} H\big(k[\Delta_T]; \ell\big),$$
> where $\Delta_T$ is a simplicial complex canonically attached to the tope $T$, $k[\Delta_T]$ is its Stanley–Reisner ring, and $H(-;\ell)$ denotes the Hilbert function in degree $\ell$. For central arrangements, a homological reciprocity relates the ranks in complementary degrees.

The proof in the general case uses poset combinatorics of the covector poset, the Edelman–Walker theorem identifying the homotopy type of intervals in that poset as wedges of spheres, and Alexander duality to translate sphere counts into face counts, hence into Hilbert functions.

### 1.4 What this paper does

We give a self-contained, fully rigorous development for the **coordinate (Boolean) arrangement** $\mathcal{A}_n = \{x_i = 0\}_{i=1}^n$ in $\mathbb{R}^n$, together with structural theorems valid for arbitrary connected graphs. In this case every $\Delta_T$ is the full simplex on $n$ vertices, so $k[\Delta_T] = k[x_1,\dots,x_n]$ and the predicted ranks are $2^n\binom{n+\ell-1}{\ell}$. We verify this prediction in bidegrees $(1,1)$ and $(2,2)$ by explicit computation, prove the off-diagonal vanishing in degree $1$ for *all* connected graphs, and compute the degree-$2$ chain and cycle groups in every length.

The specific results are collected in §3–§7. A running theme is that all the metric input reduces to a single dictionary — *separation = symmetric difference* — after which the homological computations are pure enumeration.

---

## 2. The magnitude chain complex

Throughout, $G = (V,E)$ is a simple graph, assumed connected, with shortest-path metric $d$.

**Definition 2.1 (magnitude chains).** For $k \ge 0$ and $\ell \ge 0$, a *generator of bidegree $(k,\ell)$* is a tuple $(x_0,x_1,\dots,x_k) \in V^{k+1}$ satisfying
1. $x_{i-1} \ne x_i$ for $i = 1,\dots,k$ (consecutive entries distinct), and
2. $\sum_{i=1}^{k} d(x_{i-1},x_i) = \ell$ (total length $\ell$).

The *magnitude chain group* $MC_{k,\ell}(G)$ is the free abelian group on these generators.

**Definition 2.2 (differential).** For $1 \le i \le k-1$ set
$$\partial_i(x_0,\dots,x_k) = \begin{cases} (x_0,\dots,\widehat{x_i},\dots,x_k) & \text{if } d(x_{i-1},x_i)+d(x_i,x_{i+1}) = d(x_{i-1},x_{i+1}), \\ 0 & \text{otherwise,}\end{cases}$$
where the hat denotes omission, and put $\delta_k = \sum_{i=1}^{k-1}(-1)^i \partial_i : MC_{k,\ell}(G) \to MC_{k-1,\ell}(G)$. (When the deletion is performed, the resulting tuple automatically has total length $\ell$; if $x_{i-1} = x_{i+1}$ the deletion condition fails, since it would force $d(x_{i-1},x_i) = 0$, so the result is a legitimate generator.) One checks $\delta_{k-1}\delta_k = 0$, and
$$MH_{k,\ell}(G) := \ker \delta_k / \operatorname{im}\delta_{k+1}.$$

**Remark 2.3 (length dominates degree).** In a connected graph, $x \ne y$ implies $d(x,y) \ge 1$. Hence a generator of bidegree $(k,\ell)$ has $\ell \ge k$, so $MC_{k,\ell}(G) = 0$ for $\ell < k$ and the whole theory is supported in the region $\ell \ge k$.

We record the two instances of Remark 2.3 that we use repeatedly.

**Lemma 2.4.** Let $G$ be connected. Then $MC_{1,0}(G) = 0$; $MC_{2,\ell}(G) = 0$ for $\ell < 2$; and $MC_{3,\ell}(G) = 0$ for $\ell < 3$.

*Proof.* Each summand $d(x_{i-1},x_i)$ is strictly positive, since consecutive entries are distinct and the graph is connected, so a $(k,\ell)$-generator forces $\ell \ge k$. $\square$

**Definition 2.5 (diagonality).** $G$ is *diagonal* if $MH_{k,\ell}(G) = 0$ for all $k \ne \ell$.

In low degrees, the complex we shall work with is
$$MC_{3,\ell}(G) \xrightarrow{\ \delta_3\ } MC_{2,\ell}(G) \xrightarrow{\ \delta_2\ } MC_{1,\ell}(G) \xrightarrow{\ 0\ } MC_{0,\ell}(G),$$
where $\delta_2(x,y,z) = -(x,z)$ if $d(x,y)+d(y,z)=d(x,z)$ and $0$ otherwise (signs are immaterial for the computations of rank and kernel; we work with $+$ below). Note that $MC_{0,\ell} = 0$ unless $\ell = 0$, so the differential out of degree $1$ vanishes for $\ell \ge 1$ and
$$MH_{1,\ell}(G) = MC_{1,\ell}(G)/\operatorname{im}\delta_2 \qquad (\ell \ge 1).$$

---

## 3. The coordinate arrangement and its chambers

Fix $n \ge 0$ and let $\mathcal{A}_n$ be the arrangement of the $n$ coordinate hyperplanes $H_i = \{x \in \mathbb{R}^n : x_i = 0\}$.

**Definition 3.1.** For $s \subseteq \{1,\dots,n\}$ put
$$C_s = \{x \in \mathbb{R}^n : x_i > 0 \text{ for all } i \in s,\ \ x_i < 0 \text{ for all } i \notin s\}.$$

**Proposition 3.2 (chamber geometry).** For every $s$:
1. $C_s \ne \emptyset$;
2. $C_s$ is convex;
3. no point of $C_s$ lies on any hyperplane of $\mathcal{A}_n$, i.e. $x_i \ne 0$ for all $x \in C_s$ and all $i$;
4. if $s \ne t$ then $C_s \cap C_t = \emptyset$.

*Proof.* (1) The sign vector $\varepsilon^s$ with $\varepsilon^s_i = 1$ for $i \in s$ and $-1$ otherwise lies in $C_s$.

(2) Let $x,y \in C_s$ and $a,b \ge 0$ with $a+b=1$. If $u,v > 0$ then $au+bv > 0$: if $a = 0$ then $b = 1$ and $au+bv = v > 0$, otherwise $au > 0$ and $bv \ge 0$. Applying this coordinatewise to $x_i,y_i$ for $i \in s$, and to $-x_i,-y_i$ for $i \notin s$, gives $ax+by \in C_s$.

(3) Immediate from the strict inequalities.

(4) Follows from Theorem 3.3 below: if $s \ne t$ then $s \triangle t \ne \emptyset$, so any $x \in C_s \cap C_t$ would satisfy $x_i^2 = x_i \cdot x_i < 0$ for some $i$, absurd. $\square$

The next statement is the combinatorial heart of the whole development.

**Theorem 3.3 (separation equals symmetric difference).** Let $x \in C_s$, $y \in C_t$ and $i \in \{1,\dots,n\}$. Then
$$i \in s \,\triangle\, t \iff x_i\, y_i < 0,$$
that is, iff the hyperplane $H_i$ separates $x$ from $y$. Consequently the set of hyperplanes separating $C_s$ from $C_t$ is $\{H_i : i \in s \triangle t\}$, of cardinality $|s \triangle t|$.

*Proof.* Four cases. If $i \in s$ and $i \in t$ then $x_i > 0$ and $y_i > 0$, so $x_iy_i > 0$ and $i \notin s \triangle t$. If $i \notin s$ and $i \notin t$ then $x_i<0,\ y_i<0$, so again $x_iy_i>0$ and $i \notin s\triangle t$. If $i \in s \setminus t$ then $x_i>0>y_i$, so $x_iy_i<0$ and $i \in s\triangle t$; symmetrically for $i \in t \setminus s$. In all four cases the two sides agree. $\square$

Note that Theorem 3.3 in particular shows the separation data are *independent of the chosen representatives* $x \in C_s$, $y \in C_t$ — a fact one needs before the tope graph is even well defined.

---

## 4. The tope graph is the hypercube

**Definition 4.1.** The **tope graph** $T_n$ of $\mathcal{A}_n$ has vertex set the subsets $s \subseteq \{1,\dots,n\}$, with $s \sim t$ iff $|s \triangle t| = 1$.

By Theorem 3.3 this is exactly the abstract "separated by one hyperplane" relation. Symmetry follows from $s \triangle t = t \triangle s$ and irreflexivity from $|s \triangle s| = 0$.

**Lemma 4.2 (flip).** For every $s$ and every $i$, $s$ is adjacent to $s \triangle \{i\}$.

*Proof.* $s \triangle (s \triangle \{i\}) = \{i\}$, of cardinality $1$. $\square$

**Lemma 4.3 (descent step).** If $i \in s \triangle t$ then $|(s \triangle \{i\}) \triangle t| + 1 = |s \triangle t|$.

*Proof.* Using associativity and commutativity of $\triangle$, $(s\triangle\{i\})\triangle t = (s \triangle t)\triangle\{i\}$, and since $i \in s \triangle t$ this equals $(s\triangle t)\setminus\{i\}$; deleting an element of a set drops its cardinality by one. $\square$

**Theorem 4.4 (metric identification).** For all $s,t$,
$$d_{T_n}(s,t) = |s \,\triangle\, t|.$$
In particular $T_n$ is connected, and $T_n$ is isomorphic as a metric graph to the $n$-dimensional hypercube $Q_n$ with the Hamming metric.

*Proof.* ($\le$) By induction on $m = |s\triangle t|$. If $m = 0$ then $s = t$ and the empty walk works. Otherwise pick $i \in s \triangle t$; by Lemma 4.2, $s$ is adjacent to $s' = s \triangle \{i\}$, and by Lemma 4.3, $|s' \triangle t| = m-1$, so by induction there is a walk from $s'$ to $t$ of length $\le m-1$; prepending the edge gives a walk of length $\le m$.

($\ge$) Let $p$ be any walk $s = u_0, u_1, \dots, u_L = t$. Each step changes the symmetric difference with $t$ by at most one element in cardinality: $|u_{j+1}\triangle t| \ge |u_j \triangle t| - 1$, because $u_{j+1} = u_j \triangle \{i\}$ for some $i$ and $(u_j\triangle\{i\})\triangle t$ differs from $u_j \triangle t$ by inserting or deleting $i$. Since $|u_L \triangle t| = 0$ and $|u_0 \triangle t| = |s\triangle t|$, we get $L \ge |s\triangle t|$.

Combining, $d(s,t) = |s\triangle t|$. Connectivity is the finiteness of this distance. $\square$

**Corollary 4.5 (counts of low chains).** For $\ell \ge 1$,
$$\operatorname{rank} MC_{1,\ell}(T_n) \;=\; 2^n \binom{n}{\ell}.$$

*Proof.* A $(1,\ell)$-generator is a pair $(x,y)$ with $x \ne y$ and $d(x,y) = \ell$, i.e. $|x\triangle y| = \ell$. The map $(x,y) \mapsto (x, x\triangle y)$ is a bijection onto pairs consisting of a vertex $x$ (there are $2^n$) and an $\ell$-element set of coordinates (there are $\binom{n}{\ell}$), with inverse $(x,a) \mapsto (x, x\triangle a)$; the condition $x \ne y$ corresponds to $a \ne \emptyset$, which is automatic for $\ell \ge 1$. $\square$

In particular the number of ordered edges of $T_n$ is $2^n n$.

---

## 5. Structural results for arbitrary connected graphs

The following hold for every connected graph $G$; the arrangement plays no role.

**Theorem 5.1 ($MH_{1,1}$ is free on ordered edges).** For a connected graph $G$,
$$MH_{1,1}(G) \;\cong\; \mathbb{Z}\big[\{(x,y) \in V\times V : x \sim y\}\big],$$
the free abelian group on the ordered edges of $G$.

*Proof.* By Lemma 2.4, $MC_{2,1}(G) = 0$, so $\operatorname{im}\delta_2 = 0$ in length $1$; and the differential out of degree $1$ is zero for $\ell = 1$. Hence $MH_{1,1}(G) = MC_{1,1}(G)$, the free abelian group on pairs $(x,y)$ with $x\ne y$ and $d(x,y) = 1$. Finally $d(x,y) = 1$ is equivalent to $x \sim y$, and adjacency already forces $x \ne y$. $\square$

**Lemma 5.2 (geodesic first step).** Let $G$ be connected and $d(x,y) \ge 2$. Then there exists $z$ with $x \sim z$, $z \ne y$, and $d(x,z) + d(z,y) = d(x,y)$.

*Proof.* Choose a walk $p$ from $x$ to $y$ of length $d(x,y)$; since $d(x,y) \ge 1$ it is not the empty walk, so $p = (x \sim z) \cdot q$ for some neighbour $z$ of $x$ and walk $q$ from $z$ to $y$ of length $d(x,y)-1$. Then $d(x,z) = 1$ and $d(z,y) \le d(x,y)-1$; the triangle inequality gives $d(x,y) \le 1 + d(z,y)$, whence $d(z,y) = d(x,y)-1$ and the additivity holds. If $z = y$ then $d(x,y) = 1$, contradicting $d(x,y)\ge 2$. $\square$

**Theorem 5.3 (surjectivity of $\delta_2$ in lengths $\ge 2$).** Let $G$ be connected and $\ell \ge 2$. Then $\delta_2 : MC_{2,\ell}(G) \to MC_{1,\ell}(G)$ is surjective.

*Proof.* It suffices to hit each generator $(x,y)$ with $x \ne y$ and $d(x,y) = \ell \ge 2$. By Lemma 5.2 there is $z$ with $x \sim z$, $z \ne y$ and $d(x,z)+d(z,y) = \ell$. Then $(x,z,y)$ is a $(2,\ell)$-generator ($x \ne z$ since $x \sim z$, and $z \ne y$), and since the deletion condition $d(x,z)+d(z,y) = d(x,y)$ holds, $\delta_2(x,z,y) = \pm(x,y)$. $\square$

**Corollary 5.4 (degree-one diagonality).** For every connected graph $G$ and every $\ell \ge 2$,
$$MH_{1,\ell}(G) = 0.$$

*Proof.* For $\ell \ge 1$, $MH_{1,\ell}(G) = MC_{1,\ell}(G)/\operatorname{im}\delta_2$, and Theorem 5.3 says the quotient is trivial for $\ell \ge 2$. $\square$

Corollary 5.4 is the degree-$1$ case of diagonality, valid with no hypotheses beyond connectivity. (Diagonality in *all* degrees is a genuine restriction; it holds for tope graphs, and fails for e.g. odd cycles of length $\ge 5$.)

**Theorem 5.5 (splitting of the chain complex in length $\ell \ge 2$).** For $G$ connected and $\ell \ge 2$,
$$MC_{2,\ell}(G) \;\cong\; \ker \delta_2 \;\oplus\; MC_{1,\ell}(G).$$

*Proof.* $MC_{1,\ell}(G)$ is free, hence projective, so the surjection $\delta_2$ of Theorem 5.3 splits: there is $\sigma : MC_{1,\ell} \to MC_{2,\ell}$ with $\delta_2\sigma = \mathrm{id}$, and then $MC_{2,\ell} = \ker\delta_2 \oplus \operatorname{im}\sigma$ with $\operatorname{im}\sigma \cong MC_{1,\ell}$. $\square$

**Theorem 5.6 (nothing maps into bidegree $(2,2)$).** For $G$ connected, $MC_{3,2}(G) = 0$, hence $\delta_3 = 0$ in length $2$ and
$$MH_{2,2}(G) \;=\; \ker\big(\delta_2 : MC_{2,2}(G)\to MC_{1,2}(G)\big).$$

*Proof.* A $(3,2)$-generator would be a tuple $(x_0,x_1,x_2,x_3)$ with consecutive entries distinct and $d(x_0,x_1)+d(x_1,x_2)+d(x_2,x_3) = 2$; but each summand is $\ge 1$, so the sum is $\ge 3$. Thus $MC_{3,2}(G) = 0$ and every homomorphism out of it is zero. $\square$

**Theorem 5.7 (rank formula).** Let $G$ be a connected graph with finitely many chains in bidegrees $(2,\ell)$ and $(1,\ell)$, and let $\ell \ge 2$. Then $\ker\delta_2$ is free abelian and
$$\operatorname{rank}\ker\delta_2 \;+\; \operatorname{rank} MC_{1,\ell}(G) \;=\; \operatorname{rank} MC_{2,\ell}(G).$$
In particular, for a finite connected graph,
$$MH_{2,2}(G) \;\cong\; \mathbb{Z}^{\,\operatorname{rank} MC_{2,2}(G) - \operatorname{rank} MC_{1,2}(G)}.$$

*Proof.* Immediate from Theorem 5.5 (which gives the rank identity and, as a direct summand of a free module over the principal ideal domain $\mathbb{Z}$, the freeness of $\ker\delta_2$) combined with Theorem 5.6 for the last statement. $\square$

**Theorem 5.8 (diagonal cycles).** For $G$ connected, the map $(x,y) \mapsto (x,y,x)$ from ordered edges to $(2,2)$-generators is injective and lands in $\ker\delta_2$. Hence $MH_{2,2}(G)$ contains a free abelian subgroup of rank the number of ordered edges of $G$; in particular $MH_{2,2}(G) \ne 0$ whenever $G$ has at least one edge.

*Proof.* If $x \sim y$ then $x \ne y$, $y \ne x$ and $d(x,y)+d(y,x) = 2$, so $(x,y,x)$ is a $(2,2)$-generator; the map is clearly injective on ordered edges. The deletion condition for the middle entry reads $d(x,y)+d(y,x) = d(x,x)$, i.e. $2 = 0$, which fails; so $\partial_1(x,y,x) = 0$ and $\delta_2(x,y,x) = 0$. Freeness of the span follows since distinct generators are part of a basis, and Theorem 5.6 identifies $\ker\delta_2$ with $MH_{2,2}$. $\square$

---

## 6. The magnitude homology of the coordinate arrangement

We now specialise to $G = T_n \cong Q_n$ and use the dictionary of Theorem 4.4.

**Theorem 6.1 (degree-2 chains, all lengths).** For $\ell \ge 1$, the $(2,\ell)$-generators of $T_n$ are in bijection with triples $(y, a, b)$ where $y \subseteq \{1,\dots,n\}$ is a tope and $a, b \subseteq \{1,\dots,n\}$ are *nonempty* with $|a|+|b| = \ell$; the bijection sends $(x,y,z)$ to $(y,\, x \triangle y,\, y \triangle z)$.

*Proof.* Given $(x,y,z)$ with $x \ne y$, $y \ne z$ and $d(x,y)+d(y,z) = \ell$, set $a = x\triangle y$, $b = y\triangle z$; by Theorem 4.4, $|a| + |b| = \ell$, and $x \ne y$, $y \ne z$ say precisely $a \ne \emptyset \ne b$ (since $u \triangle v = \emptyset$ iff $u = v$). Conversely $(y,a,b) \mapsto (y\triangle a,\, y,\, y \triangle b)$ is an inverse, using $u \triangle (u \triangle a) = a$. $\square$

**Lemma 6.2 (Vandermonde bijection).** The set of ordered pairs $(a,b)$ of subsets of an $n$-element set with $|a|+|b| = \ell$ is in bijection with the set of $\ell$-element subsets of a $2n$-element set; hence it has cardinality $\binom{2n}{\ell}$.

*Proof.* Identify the $2n$-set with the disjoint union of two copies of the $n$-set; a subset of the union is exactly a pair of subsets, and its size is the sum of the sizes. Counting by the size $j = |a|$ recovers the Vandermonde identity $\sum_{j}\binom{n}{j}\binom{n}{\ell - j} = \binom{2n}{\ell}$. $\square$

**Lemma 6.3.** For $\ell \ge 1$, the number of ordered pairs $(a,b)$ of subsets of an $n$-set with $|a|+|b| = \ell$ and at least one of $a,b$ empty is $2\binom{n}{\ell}$.

*Proof.* If $a = \emptyset$ then $|b| = \ell$: there are $\binom{n}{\ell}$ such pairs; symmetrically for $b = \emptyset$. The two families are disjoint because $\ell \ge 1$ prevents $a = b = \emptyset$. $\square$

**Theorem 6.4 (chain ranks of the tope graph).** For $\ell \ge 1$,
$$\operatorname{rank} MC_{1,\ell}(T_n) = 2^n\binom{n}{\ell}, \qquad \operatorname{rank} MC_{2,\ell}(T_n) = 2^n\left(\binom{2n}{\ell} - 2\binom{n}{\ell}\right).$$
In particular $\operatorname{rank} MC_{2,2}(T_n) = 2^n n^2$.

*Proof.* The first formula is Corollary 4.5. For the second, combine Theorem 6.1 with Lemmas 6.2 and 6.3: the number of admissible $(a,b)$ is $\binom{2n}{\ell} - 2\binom{n}{\ell}$, and there are $2^n$ choices of $y$. For $\ell = 2$, $\binom{2n}{2} - 2\binom{n}{2} = n(2n-1) - n(n-1) = n^2$. (Alternatively: a $(2,2)$-generator is a middle vertex together with an ordered pair of neighbours, and every vertex of $Q_n$ has degree $n$.) $\square$

**Theorem 6.5 (the diagonal in length 2).** For every $n$,
$$MH_{2,2}(T_n) \;\cong\; \mathbb{Z}^{\,2^n\binom{n+1}{2}}.$$

*Proof.* By Theorem 5.6, $MH_{2,2}(T_n) = \ker\delta_2$, and by Theorem 5.7 this is free of rank
$$\operatorname{rank} MC_{2,2} - \operatorname{rank} MC_{1,2} = 2^n n^2 - 2^n\binom{n}{2} = 2^n\left(n^2 - \binom{n}{2}\right).$$
The elementary identity $\binom{n}{2} + \binom{n+1}{2} = n^2$ — both sides count pairs $(i,j) \in \{1,\dots,n\}^2$, split according to $i<j$ versus $i \ge j$ — gives $n^2 - \binom{n}{2} = \binom{n+1}{2}$. $\square$

**Theorem 6.6 (cycles in arbitrary length).** For $\ell \ge 2$, the group of $(2,\ell)$-cycles of $T_n$ is free abelian of rank
$$2^n\left(\binom{2n}{\ell} - 3\binom{n}{\ell}\right).$$
For $\ell = 2$ this is $2^n\binom{n+1}{2}$, consistent with Theorem 6.5.

*Proof.* Theorem 5.7 gives $\operatorname{rank}\ker\delta_2 = \operatorname{rank} MC_{2,\ell} - \operatorname{rank} MC_{1,\ell}$, and Theorem 6.4 evaluates both terms. For $\ell = 2$: $\binom{2n}{2} - 3\binom{n}{2} = n(2n-1) - \tfrac{3n(n-1)}{2} = \tfrac{n^2+n}{2} = \binom{n+1}{2}$. $\square$

### 6.1 Comparison with the Stanley–Reisner prediction

For the coordinate arrangement, the simplicial complex attached to each of the $2^n$ topes is the full simplex on the $n$ hyperplanes, whose Stanley–Reisner ring has no relations: $k[\Delta_T] = k[x_1,\dots,x_n]$, with Hilbert function
$$H\big(k[x_1,\dots,x_n];\ell\big) = \binom{n+\ell-1}{\ell}.$$
The predicted diagonal ranks are therefore $2^n\binom{n+\ell-1}{\ell}$. Our computations confirm this in the two available degrees:

| $\ell$ | prediction $2^n\binom{n+\ell-1}{\ell}$ | computed |
|---|---|---|
| $1$ | $2^n\, n$ | $\operatorname{rank} MH_{1,1}(T_n) = 2^n n$ (Theorem 5.1 + Corollary 4.5) |
| $2$ | $2^n \binom{n+1}{2}$ | $\operatorname{rank} MH_{2,2}(T_n) = 2^n\binom{n+1}{2}$ (Theorem 6.5) |

and the off-diagonal vanishing $MH_{1,\ell}(T_n) = 0$ for $\ell \ge 2$ is Corollary 5.4.

The conceptual reason for the polynomial ring is visible in Theorem 6.1: a degree-$k$ chain of the tope graph records, at each tope, an ordered tuple of nonempty *sets of hyperplanes*; passing to homology collapses the ordering and merges the tuple into a multiset — that is, into a monomial in the hyperplanes — and the count of monomials of degree $\ell$ in $n$ variables is exactly $\binom{n+\ell-1}{\ell}$.

### 6.2 Homological reciprocity

The coordinate arrangement is *central*: all hyperplanes contain the origin. Central arrangements are invariant under the antipodal map $x \mapsto -x$, which on topes is the complementation $s \mapsto \{1,\dots,n\}\setminus s$. Complementation is an automorphism of the tope graph preserving distance ($|s^c \triangle t^c| = |s\triangle t|$), so it acts on all magnitude homology groups. The general reciprocity phenomenon for central arrangements — a duality between the ranks in complementary degrees, proved via Alexander duality on the associated complexes — is thus the homological shadow of this antipodal involution. For the Boolean case, the antipodal map is fixed-point-free and the free $\mathbb{Z}/2$-action it induces is visible in every rank formula above through the factor $2^n = 2\cdot 2^{n-1}$.

---

## 7. The Coxeter picture: Cayley graph of $(\mathbb{Z}/2)^n$

**Lemma 7.1 (graph isomorphisms are isometries).** If $e : G \xrightarrow{\ \sim\ } H$ is an isomorphism of simple graphs, then $d_H(e(x),e(y)) = d_G(x,y)$ for all $x,y$.

*Proof.* An isomorphism maps walks to walks of the same length, so $d_H(e(x),e(y)) \le d_G(x,y)$; applying the same to $e^{-1}$ gives the reverse inequality. $\square$

Since all of $MC_{k,\ell}$, $\delta_k$ and hence $MH_{k,\ell}$ are defined purely from the vertex set and the metric, Lemma 7.1 immediately yields:

**Corollary 7.2 (invariance).** A graph isomorphism $e: G \to H$ induces bijections of the $(k,\ell)$-generators commuting with the differentials, hence isomorphisms $MC_{k,\ell}(G)\cong MC_{k,\ell}(H)$, $\ker\delta_2^G \cong \ker\delta_2^H$ and $MH_{k,\ell}(G) \cong MH_{k,\ell}(H)$ for all $k,\ell$.

**Definition 7.3.** Let $W_n = (\mathbb{Z}/2)^n$, the Coxeter group of type $A_1^n$, with standard generating set $S = \{e_1,\dots,e_n\}$ of coordinate reflections. Its **Cayley graph** $\mathrm{Cay}(W_n,S)$ has vertex set $W_n$ and an edge between $g$ and $h$ whenever $g + h = e_i$ for some $i$.

**Theorem 7.4 (tope graph = Coxeter Cayley graph).** The indicator map
$$\iota : s \longmapsto \big(\mathbf{1}[1 \in s], \dots, \mathbf{1}[n \in s]\big) \in (\mathbb{Z}/2)^n$$
is an isomorphism of graphs $T_n \xrightarrow{\ \sim\ } \mathrm{Cay}(W_n,S)$.

*Proof.* $\iota$ is a bijection: injective because a subset is recovered as the support of its indicator, surjective because any vector is the indicator of its support. It satisfies $\iota(s \triangle t) = \iota(s) + \iota(t)$ (mod-$2$ addition is symmetric difference on indicators) and $\iota(\{i\}) = e_i$. Hence $|s\triangle t| = 1$ iff $s \triangle t = \{i\}$ for some $i$ iff $\iota(s)+\iota(t) = e_i$ for some $i$, which is adjacency in the Cayley graph. $\square$

**Corollary 7.5 (magnitude homology of $(\mathbb{Z}/2)^n$).** For $C_n := \mathrm{Cay}\big((\mathbb{Z}/2)^n, \{e_i\}\big)$:
1. $C_n$ is connected and $d_{C_n}(\iota s,\iota t) = |s \triangle t|$ (word length with respect to $S$);
2. $\operatorname{rank} MC_{1,\ell}(C_n) = 2^n\binom{n}{\ell}$; the number of ordered edges is $2^n n$;
3. $MH_{1,1}(C_n)$ is free abelian of rank $2^n n$, on the ordered edges;
4. $MH_{1,\ell}(C_n) = 0$ for all $\ell \ge 2$;
5. $MH_{2,2}(C_n) \cong \mathbb{Z}^{\,2^n\binom{n+1}{2}}$, and it is nonzero for $n \ge 1$;
6. for $\ell \ge 2$ the $(2,\ell)$-cycle group of $C_n$ is free of rank $2^n\big(\binom{2n}{\ell} - 3\binom{n}{\ell}\big)$.

*Proof.* Combine Theorem 7.4 with Corollary 7.2 and Theorems 4.4, 5.1, 5.8, 6.4, 6.5, 6.6 and Corollary 5.4. $\square$

This is the promised computation of the magnitude homology of the Cayley graph of a Coxeter group, in the case $W = (\mathbb{Z}/2)^n$. The Hilbert-function shape of the answer, $2^n\binom{n+\ell-1}{\ell}$ on the diagonal, is the statement that the magnitude homology of $W$ in degree $\ell$ is a copy, at every group element, of the degree-$\ell$ part of the polynomial ring on the simple reflections.

---

## 8. Algorithms

All the invariants above are effectively computable. We record three routines.

**Algorithm A (tope-graph metric).** *Input:* $n$, two subsets $s,t \subseteq \{1,\dots,n\}$ given as bitmasks. *Output:* $d(s,t)$. *Method:* return the population count of $s \oplus t$. *Complexity:* $O(1)$ machine words, $O(n)$ bit operations. Correctness is Theorem 4.4. This replaces a breadth-first search on $2^n$ vertices, and is the reason the whole theory is tractable at large $n$.

**Algorithm B (magnitude chain ranks).** *Input:* $n$, $k \in \{1,2\}$, $\ell$. *Output:* $\operatorname{rank} MC_{k,\ell}(T_n)$. *Method:* return $2^n\binom{n}{\ell}$ for $k=1$, and $2^n\big(\binom{2n}{\ell}-2\binom{n}{\ell}\big)$ for $k=2$. *Complexity:* $O(\ell)$ big-integer multiplications. Correctness is Theorem 6.4.

**Algorithm C (explicit rank of $\ker \delta_2$ by linear algebra).** *Input:* an arbitrary finite connected graph $G$ (adjacency lists), a length $\ell \ge 2$. *Output:* the rank of $\ker\delta_2$, i.e. of $MH_{2,\ell}$ when $\ell = 2$. *Method:* run all-pairs BFS to obtain $d$; enumerate $(2,\ell)$- and $(1,\ell)$-generators; assemble the matrix of $\delta_2$; return $\#\{(2,\ell)\text{-gens}\} - \operatorname{rank}(\delta_2)$. *Complexity:* $O(|V|(|V|+|E|))$ for the metric, then $O(\#MC_{2,\ell})$ to build the matrix (each column has at most one nonzero entry, so the rank is simply the number of *distinct* targets hit) and $O(\#MC_{2,\ell})$ to compute the rank by hashing. The special structure — $\delta_2$ sends each basis vector to $0$ or to a single basis vector — makes this exact rank computation linear rather than cubic, which is a genuine practical gain.

Algorithm C run on $T_n$ reproduces the closed forms of Theorems 6.4–6.6, and run on other graphs (cycles, trees, complete bipartite graphs) probes how special tope graphs are.

---

## 9. Applications and discussion

**Computability of magnitude.** Since $\#G(q) = \sum_{k,\ell}(-1)^k\operatorname{rank}MH_{k,\ell}(G)\,q^\ell$, diagonality collapses the alternating sum to a single term per length: for a diagonal graph,
$$\#G(q) = \sum_{\ell\ge 0} (-1)^{\ell}\operatorname{rank}MH_{\ell,\ell}(G)\, q^{\ell}.$$
For $T_n$ this reads $\#T_n(q) = 2^n\sum_{\ell\ge0}(-1)^\ell\binom{n+\ell-1}{\ell}q^\ell = 2^n(1+q)^{-n}$, matching the classical computation of the magnitude of the hypercube as the $n$-fold $\ell^1$-product of the two-point space, whose magnitude is $2/(1+q)$. That the homological answer reproduces the multiplicativity of magnitude under products is a strong consistency check on all the ranks above.

**Coxeter groups.** The isomorphism between tope graphs of reflection arrangements and Cayley graphs turns a statement about geometry into a statement about groups: the magnitude homology of a finite Coxeter group with word metric is diagonal, with ranks given by Hilbert functions distributed over group elements. Our $(\mathbb{Z}/2)^n$ computation is the base case; the same architecture applies to $A_{n-1}$ (symmetric groups, permutohedra), $B_n$, $D_n$, and the exceptional types, where the attached complexes are no longer simplices and the Hilbert functions are genuinely those of nontrivial Stanley–Reisner rings.

**Oriented matroids.** Nothing in §§3–4 used the ambient $\mathbb{R}^n$ beyond the sign vectors; the separation principle is a statement about the covector axioms. Tope graphs of oriented matroids therefore inherit the same theory, and one may hope for a purely axiomatic proof of diagonality.

**What diagonality buys.** Diagonal graphs are exactly those where magnitude homology contains no more information than magnitude *and the grading*; their magnitude series has unsigned coefficients that literally count basis elements. Known diagonal families include trees, complete graphs, and — by the theorem developed here — all tope graphs. Since tope graphs of arrangements are, up to isomorphism, precisely a natural class of *median-like* graphs, the result places diagonality firmly in the world of metric graph theory: the graphs where geodesics are governed by a separation system are the graphs with the simplest magnitude homology.

**Limits of the present development.** We have proved diagonality in degree $1$ for all connected graphs and computed the diagonal in bidegree $(2,2)$ exactly, together with the ranks of all $(2,\ell)$-cycle groups for the tope graph. The full diagonality statement — $MH_{k,\ell}(T_n) = 0$ for all $k \ne \ell$, not merely $k=1$ — requires the higher differentials and the filtration argument sketched in §1.3; the rank $2^n\binom{n+\ell-1}{\ell}$ on the diagonal for $\ell \ge 3$ likewise remains to be derived from the chain counts recorded in Theorem 6.4.

---

## 10. Future work

1. **All degrees.** Extend the explicit chain-level analysis from degrees $\le 2$ to arbitrary degree $k$, establishing full diagonality of the hypercube and the rank formula $2^n\binom{n+\ell-1}{\ell}$ directly.
2. **General arrangements.** Replace the Boolean arrangement by an arbitrary real arrangement: build the covector poset, its intervals and their order complexes, and carry through the Edelman–Walker/Alexander-duality argument.
3. **Other Coxeter types.** Compute the attached complexes and their Stanley–Reisner rings for the symmetric group (permutohedron) and the hyperoctahedral group, and compare with independently computed magnitude series.
4. **Reciprocity.** Formulate and prove the homological reciprocity for central arrangements as an isomorphism of graded groups induced by the antipodal involution, and identify the sign character.
5. **Oriented matroids.** Axiomatise the argument so that it applies to tope graphs of arbitrary oriented matroids, including non-realisable ones.
6. **Torsion.** All groups computed here are free abelian. Determine whether magnitude homology of tope graphs is torsion-free in general — the Stanley–Reisner picture suggests it is, but the higher differentials have not been analysed.

---

## 11. Summary of results

Let $T_n$ denote the tope graph of the arrangement of the $n$ coordinate hyperplanes in $\mathbb{R}^n$, equivalently the $n$-cube, equivalently the Cayley graph of $(\mathbb{Z}/2)^n$ with respect to its $n$ coordinate reflections.

| Statement | Reference |
|---|---|
| Chambers of the coordinate arrangement are nonempty, convex, pairwise disjoint, and off the hyperplanes | Prop. 3.2 |
| The set of hyperplanes separating $C_s$ from $C_t$ is $\{H_i : i \in s\triangle t\}$ | Thm. 3.3 |
| $d_{T_n}(s,t) = \lvert s \triangle t\rvert$; $T_n$ is connected | Thm. 4.4 |
| $MH_{1,1}(G)$ is free on the ordered edges, for any connected $G$ | Thm. 5.1 |
| $\delta_2$ is surjective in every length $\ell \ge 2$, for any connected $G$ | Thm. 5.3 |
| $MH_{1,\ell}(G) = 0$ for $\ell \ge 2$, for any connected $G$ | Cor. 5.4 |
| $MC_{2,\ell}(G) \cong \ker\delta_2 \oplus MC_{1,\ell}(G)$ for $\ell\ge2$ | Thm. 5.5 |
| $MH_{2,2}(G) = \ker\delta_2$, of rank $\#MC_{2,2}-\#MC_{1,2}$ when finite | Thms. 5.6, 5.7 |
| Ordered edges embed as diagonal $(2,2)$-cycles $(x,y)\mapsto(x,y,x)$ | Thm. 5.8 |
| $\operatorname{rank}MC_{1,\ell}(T_n) = 2^n\binom{n}{\ell}$, $\operatorname{rank}MC_{2,\ell}(T_n)=2^n(\binom{2n}{\ell}-2\binom{n}{\ell})$ | Thm. 6.4 |
| $MH_{2,2}(T_n)\cong\mathbb{Z}^{2^n\binom{n+1}{2}}$ — the Hilbert function of $k[x_1,\dots,x_n]$ at $2$, per tope | Thm. 6.5 |
| $(2,\ell)$-cycles of $T_n$ free of rank $2^n(\binom{2n}{\ell}-3\binom{n}{\ell})$ | Thm. 6.6 |
| Graph isomorphisms are isometries; all invariants transport | Lem. 7.1, Cor. 7.2 |
| $T_n \cong \mathrm{Cay}((\mathbb{Z}/2)^n, \{e_i\})$, and all computations transfer | Thm. 7.4, Cor. 7.5 |
