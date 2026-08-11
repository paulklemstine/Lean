# Certified Adversarial Robustness as a Cohomological Invariant of the Nerve of a Cover

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop a complete cohomological theory of when *local* robustness
certificates for a classifier assemble into a *global* certified $L^\infty$
perturbation radius. The certified sign data on a family of balls around anchor
points is shown to be a system of local sections of a locally constant
"decision sheaf" on the nerve of the cover, and — crucially — the sheaf
compatibility condition on overlaps is not an assumption but a consequence of
certification. We prove a discrete Poincaré lemma for arbitrary nerve graphs
with coefficients in an arbitrary abelian group: an antisymmetric overlap
discrepancy is a coboundary if and only if its holonomy vanishes around every
closed walk. Specialised to the decision sheaf, this yields the **Gluing
Theorem** — on a connected nerve, local $L^\infty$ certificates of radius $\rho$
always glue to a single global certificate of radius $\rho$ over the union of
the balls — and, via the intermediate value theorem, a sharp converse: a walk
with nonzero sign holonomy produces an explicit point of the decision boundary
within distance $\delta$ of an anchor, capping the uniform certified radius by
the overlap scale. The two directions combine into an equivalence: on a
connected nerve with overlap scale $\delta$, uniform certification at radius
$\delta$ *is* the vanishing of the sign holonomy of the decision sheaf. We then
count obstructions. We compute $H^1(\text{loop}, M) \cong M$ for every abelian
group $M$; $H^1(\text{discrete torus}, \mathbb{R}) \cong \mathbb{R}^2$; $H^1 =
0$ for every tree nerve; and, in general, the **Betti Number Law** $\dim H^1 =
|E| - |V| + 1$ for any finite connected nerve, so that $H^1 = 0$ exactly when
the nerve is a spanning tree. We give the obstruction a metric: on a loop of
$n+1$ regions with holonomy $H$, the least achievable uniform certificate
mismatch is exactly $|H|/(n+1)$, attained by the constant (harmonic)
representative. Finally we treat multi-class classifiers, where transitions are
relabellings: we prove the nonabelian discrete Poincaré lemma and exhibit an
explicit three-class cover, pairwise consistent everywhere, admitting no global
labelling. Throughout, the analytic hypothesis is only continuity of the score
— no Lipschitz constant is required to detect an obstruction.

**Keywords:** certified robustness, $L^\infty$ perturbation radius, nerve of a
cover, Čech cohomology, holonomy, first Betti number, decision boundary,
nonabelian monodromy.

---

## 1. Introduction

### 1.1 The locality problem in certification

Robustness certification aims to replace empirical attack-and-defend cycles by
proofs. For a classifier and an input $x$, a *certificate of radius $\rho$* is a
proof that no perturbation of $L^\infty$ norm at most $\rho$ changes the
decision at $x$. Randomised smoothing, interval bound propagation, Lipschitz
bounds and linear relaxations all produce certificates of this form.

Every such method is intrinsically pointwise. The output is a promise about a
single ball. A deployment, however, cares about a *region*: a distribution of
inputs, a data manifold, a family of reparametrisations of the weights. The
natural attempt is to certify many points and take the union. This raises two
questions that pointwise methods cannot answer:

1. **Consistency.** Do the local promises describe the same decision, or do they
   silently contradict one another across the gaps?
2. **Completeness.** If they are consistent, is the union genuinely certified,
   or only its sampled points?

We answer both, and show that the answer is a topological invariant.

### 1.2 Nerves, sheaves, and the shape of a cover

Given a family of sets $\{U_i\}_{i \in \iota}$, the **nerve** is the
combinatorial object recording which of them intersect: one vertex per set, one
edge per intersecting pair (and, in higher dimensions, one simplex per
multiple intersection). Nerve constructions are the standard bridge from
geometry to combinatorics, and are the technical basis of persistent homology.

A **sheaf** on such a cover assigns data to each patch together with restriction
maps, and its **cohomology** measures the failure of locally defined,
pairwise-compatible data to come from a single global object. The first
cohomology $H^1$ is exactly the group of such failures modulo the trivial ones.

Our thesis is that certification data forms a sheaf on the nerve of the cover by
certified balls, and that the failure of local certificates to glue is precisely
a class in $H^1$ of that nerve. Everything below makes this precise and
quantitative.

### 1.3 Contributions

* **Free sheaf axiom** (Theorem 3.2): certification *forces* agreement of
  decisions on overlaps.
* **Gluing and global $L^\infty$ certification** (Theorems 3.4, 3.5, 3.6).
* **Explicit adversarial witness from holonomy** (Theorems 4.2, 4.3, 4.4), with
  continuity as the only analytic hypothesis.
* **Certification–holonomy equivalence** (Theorems 4.5, 4.6).
* **Discrete Poincaré lemma** for arbitrary nerve graphs and arbitrary abelian
  coefficients (Theorem 5.4), with the tree corollary (Theorem 5.6).
* **Exact cohomology computations**: loop (Theorems 6.1–6.3), discrete torus
  (Theorem 7.4), and the general **Betti Number Law** (Theorem 8.3).
* **Quantitative defect theorem** (Theorem 6.6) and **certified radius transfer**
  (Theorem 5.8).
* **Nonabelian theory** for multi-class classifiers (Theorems 9.2–9.5), with a
  realised three-class obstruction.

---

## 2. Setting and definitions

Throughout, $E$ is a real normed vector space (for the $L^\infty$ statements,
$E = \mathbb{R}^d = \{$functions $\mathrm{Fin}\,d \to \mathbb{R}\}$ with
$\|y\| = \max_k |y_k|$), and $s : E \to \mathbb{R}$ is a **score function**; the
predicted class at $y$ is $\operatorname{sign} s(y)$, and $\{s = 0\}$ is the
**decision boundary**.

**Definition 2.1 (Cover data).** A *cover datum* consists of an index type
$\iota$ of regions, a family of **anchors** $x : \iota \to E$, and a symmetric
**nerve relation** $A \subseteq \iota \times \iota$ recording which regions
overlap. We write $A_{ij}$ for "$i$ and $j$ overlap".

**Definition 2.2 (Walks).** A *walk* from $i$ is a finite list $l = [j_1, \dots,
j_k]$ with $A_{i j_1}, A_{j_1 j_2}, \dots, A_{j_{k-1} j_k}$; its *endpoint* is
$\operatorname{end}(i,l) = j_k$ (and $i$ if $l$ is empty). The nerve is
**connected** if for all $i,j$ there is a walk from $i$ with endpoint $j$.

**Definition 2.3 (Holonomy of a $1$-cochain).** Let $M$ be an abelian group. A
*$1$-cochain* is a map $c : \iota \times \iota \to M$; it is *antisymmetric* if
$c_{ji} = -c_{ij}$. Its **holonomy** along the walk $l$ from $i$ is
$$W_c(i,l) \;=\; c_{i j_1} + c_{j_1 j_2} + \cdots + c_{j_{k-1} j_k},
\qquad W_c(i, [\,]) = 0 .$$
The cochain is **cycle-consistent** if $W_c(i,l) = 0$ for every closed walk
($\operatorname{end}(i,l) = i$).

**Definition 2.4 (Coboundary).** $c$ is a **coboundary** on $A$ if there is a
*potential* $f : \iota \to M$ with $c_{ij} = f_j - f_i$ whenever $A_{ij}$. We
write $H^1$ for the quotient of the relevant cocycle space by the coboundaries.

**Definition 2.5 (Sign certificate).** For $\rho, \sigma \in \mathbb{R}$, say
$s$ is **sign-certified at $x$ with radius $\rho$ and sign $\sigma$**, written
$\mathrm{SC}(s, x, \rho, \sigma)$, if
$$\forall y,\quad \|y - x\| \le \rho \;\Longrightarrow\; \sigma\, s(y) > 0 .$$
We always take $\sigma \in \{+1, -1\}$. The datum
$\{\mathrm{SC}(s, x_i, \rho, \sigma_i)\}_{i}$ is the family of **local sections
of the decision sheaf**.

**Remark 2.6.** On $E = \mathbb{R}^d$ with the sup norm, $\|y - x\| \le \rho$
means $|y_k - x_k| \le \rho$ for every coordinate $k$; thus
$\mathrm{SC}(s,x,\rho,\sigma)$ is literally a certified $L^\infty$ perturbation
radius at $x$.

---

## 3. The decision sheaf glues

### 3.1 Compatibility is forced

**Lemma 3.1 (Certificate at the centre).** If $\mathrm{SC}(s,x,\rho,\sigma)$ and
$\rho \ge 0$, then $\sigma\, s(x) > 0$.

*Proof.* Apply the definition to $y = x$, using $\|x - x\| = 0 \le \rho$. $\square$

**Theorem 3.2 (Overlap Compatibility).** Let $\rho \ge 0$, $\sigma_i, \sigma_j
\in \{\pm 1\}$, and suppose $\mathrm{SC}(s, x_i, \rho, \sigma_i)$,
$\mathrm{SC}(s, x_j, \rho, \sigma_j)$ and $\|x_j - x_i\| \le \rho$. Then
$\sigma_i = \sigma_j$.

*Proof sketch.* Since $x_j$ is within $\rho$ of $x_i$, the first certificate
gives $\sigma_i s(x_j) > 0$; Lemma 3.1 applied to the second gives $\sigma_j
s(x_j) > 0$. If $\sigma_i = 1, \sigma_j = -1$ then $s(x_j) > 0$ and $-s(x_j) >
0$, a contradiction, and symmetrically for the other mixed case. $\square$

**Remark 3.3.** This is the sheaf compatibility condition for the decision
sheaf, and it is a *theorem*, not a hypothesis. Two certified regions whose
anchors are mutually within the certified radius cannot disagree.

### 3.2 Gluing along walks

Fix now a cover datum $(\iota, x, A)$, a radius $\rho \ge 0$, signs $\sigma :
\iota \to \{\pm1\}$, and assume:

* **(C)** $\mathrm{SC}(s, x_i, \rho, \sigma_i)$ for every $i$;
* **(O)** $A_{ij} \Rightarrow \|x_j - x_i\| \le \rho$ (*overlapping anchors are
  within the certified radius*).

**Theorem 3.4 (Constancy along walks).** Under (C) and (O), for every walk $l$
from $i$ we have $\sigma_{\operatorname{end}(i,l)} = \sigma_i$.

*Proof sketch.* Induction on the length of $l$. The empty walk is trivial. For
$l = j :: t$, Theorem 3.2 applied to the edge $A_{ij}$ (whose anchors satisfy
$\|x_j - x_i\| \le \rho$ by (O)) gives $\sigma_i = \sigma_j$, and the induction
hypothesis applied at $j$ gives $\sigma_{\operatorname{end}(j,t)} = \sigma_j$.
Since $\operatorname{end}(i, j::t) = \operatorname{end}(j,t)$, the two combine.
$\square$

**Theorem 3.5 (Global section).** If in addition the nerve is connected, then
$\sigma_i = \sigma_j$ for all $i,j$: the decision sheaf has a single global
section, and $H^0$ is the line of constants.

*Proof.* Given $i,j$, choose a walk $l$ from $i$ with endpoint $j$; Theorem 3.4
gives $\sigma_j = \sigma_i$. $\square$

**Theorem 3.6 (Gluing Theorem / global certificate).** Assume (C), (O), $\rho
\ge 0$, and that the nerve is connected. Fix any base index $i_0$. Then for
every $i$ and every $y$,
$$\|y - x_i\| \le \rho \;\Longrightarrow\; \sigma_{i_0}\, s(y) > 0 .$$
That is, the *union* $\bigcup_i \bar B(x_i, \rho)$ carries one certificate with
one constant sign.

*Proof.* By Theorem 3.5, $\sigma_{i_0} = \sigma_i$; then apply (C) at $i$.
$\square$

**Corollary 3.7 (Coordinate / $L^\infty$ form).** Let $E = \mathbb{R}^d$ with
the sup norm. Under the hypotheses of Theorem 3.6, for every region $i$ and
every $y$ with $|y_k - x_{i,k}| \le \rho$ for all coordinates $k$, we have
$\sigma_{i_0} s(y) > 0$. Perturbing each coordinate of any anchor by at most
$\rho$ never changes the decision, and the decision is the same everywhere on
the cover.

*Proof.* The sup norm of $y - x_i$ is $\le \rho$ iff each coordinate difference
is, so Theorem 3.6 applies. $\square$

**Theorem 3.8 (Local certification $\Leftrightarrow$ global certification).**
Let $\iota$ be nonempty, $\delta \ge 0$, the nerve connected, and assume (O)
with $\delta$. Then
$$\exists\, \sigma : \iota \to \{\pm 1\} \ \forall i,\ \mathrm{SC}(s, x_i,
\delta, \sigma_i)
\quad\Longleftrightarrow\quad
\exists\, \tau \in \{\pm 1\}\ \forall i, y,\ \|y - x_i\| \le \delta \Rightarrow
\tau\, s(y) > 0 .$$

*Proof.* ($\Rightarrow$) is Theorem 3.6 with $\tau = \sigma_{i_0}$.
($\Leftarrow$) take $\sigma_i := \tau$ for all $i$. $\square$

This is the precise sense in which *there is no gap between local and global
certification on a connected cover* — provided the certificates exist at all.
The remaining question, and the substance of the theory, is when they do.

---

## 4. The converse: holonomy caps the certified radius

The failure mode is a **sign flip along a walk**: $s(x_a) > 0$ at the start and
$s(x_b) \le 0$ at the end. We show this is not merely incompatible with gluing;
it produces a *located* adversarial witness.

**Lemma 4.1 (Locating the flip).** Let $p : \iota \to \mathbb{R}$, let $l$ be a
walk from $a$ with $p(a) > 0$ and $\neg\,(p(\operatorname{end}(a,l)) > 0)$. Then
there is an edge $A_{uv}$ with $p(u) > 0$ and $p(v) \le 0$.

*Proof sketch.* Induction along the walk: if the value stays positive at the
next vertex, recurse; otherwise the current edge is the flip. The empty walk
case is vacuous since then $\operatorname{end}(a, l) = a$. $\square$

**Theorem 4.2 (Intermediate value witness).** Let $s$ be continuous on a real
normed space and let $u, v \in E$ with $s(u) > 0$ and $s(v) \le 0$. Then there
is $z$ with $s(z) = 0$ and $\|z - u\| \le \|v - u\|$.

*Proof sketch.* The path $\gamma(t) = u + t(v-u)$ is continuous, so $s \circ
\gamma$ is continuous on $[0,1]$ with $s(\gamma(0)) = s(u) > 0 \ge s(v) =
s(\gamma(1))$. By the intermediate value theorem there is $t \in [0,1]$ with
$s(\gamma(t)) = 0$. Setting $z = \gamma(t)$, we get $\|z - u\| = |t|\,\|v - u\|
\le \|v-u\|$. $\square$

**Theorem 4.3 (Holonomy produces a nearby boundary point).** Let $s$ be
continuous, let (O) hold with overlap scale $\delta$, let $l$ be a walk from $a$
with $s(x_a) > 0$ and $\neg\,(s(x_{\operatorname{end}(a,l)}) > 0)$. Then there
are a region $u$ on the walk and a point $z \in E$ with
$$s(z) = 0 \quad\text{and}\quad \|z - x_u\| \le \delta .$$

*Proof.* Apply Lemma 4.1 to $p = s \circ x$ to get an edge $A_{uv}$ with
$s(x_u) > 0 \ge s(x_v)$; apply Theorem 4.2 to $x_u, x_v$ to get $z$ with $s(z) =
0$ and $\|z - x_u\| \le \|x_v - x_u\| \le \delta$ by (O). $\square$

**Theorem 4.4 (No certificate at the overlap scale).** Under the hypotheses of
Theorem 4.3, there is a region $u$ such that **no** sign $\tau$ satisfies
$\mathrm{SC}(s, x_u, \delta, \tau)$.

*Proof.* Take $u, z$ from Theorem 4.3. If $\mathrm{SC}(s, x_u, \delta, \tau)$
held, then $\tau s(z) > 0$ since $\|z - x_u\| \le \delta$; but $s(z) = 0$ gives
$\tau s(z) = 0$, a contradiction. $\square$

**Theorem 4.5 (Holonomy obstructs uniform certification).** Under the same
hypotheses, there is **no** family $\sigma : \iota \to \mathbb{R}$ with
$\mathrm{SC}(s, x_i, \delta, \sigma_i)$ for all $i$. Equivalently: the uniform
certified $L^\infty$ radius of the cover is strictly less than the overlap scale
$\delta$.

*Proof.* Immediate from Theorem 4.4 applied to $\sigma_u$. $\square$

**Theorem 4.6 (Certification kills holonomy).** Conversely, if the nerve is
connected, (O) holds at scale $\delta \ge 0$, and every region is certified at
radius $\delta$ with sign $\sigma_i \in \{\pm 1\}$, then $\sigma_i = \sigma_j$
for all $i,j$ and $\sigma_i s(x_j) > 0$ for all $i,j$: the decision sheaf has no
holonomy whatsoever.

*Proof.* Theorem 3.5 gives constancy; then $\sigma_i s(x_j) = \sigma_j s(x_j) >
0$ by Lemma 3.1. $\square$

**Summary (Certification–Holonomy Equivalence).** Combining Theorems 4.5 and
4.6: on a connected nerve with overlap scale $\delta$,
$$\text{uniform certification at radius } \delta \iff
\text{vanishing sign holonomy of the decision sheaf}.$$
Certification is a cohomological property, not an analytic one. Note also the
minimality of the analytic hypothesis: only *continuity* of $s$ is used, and it
is used only in Theorem 4.2. No Lipschitz constant, smoothness, or architectural
assumption enters.

**Remark 4.7 (Why signs and not margins).** One might try to phrase the
obstruction with $\mathbb{R}$-valued margin discrepancies. That fails to be an
obstruction at all: on a tree nerve every real discrepancy is a coboundary
(Theorem 5.6), so margin data can always be reconciled. The correct coefficient
object is the *sign*, a $\{\pm 1\}$-valued (equivalently $\mathbb{Z}/2$-valued)
local section, whose holonomy is a genuine invariant. This is the structural
reason the theory is $\mathbb{Z}/2$-flavoured at its core, with $\mathbb{R}$
coefficients supplying the quantitative refinements of §6.

---

## 5. The discrete Poincaré lemma for nerve graphs

We now prove the general algebraic theorem underlying §§3–4, for arbitrary
abelian coefficients.

Let $M$ be an abelian group, $A$ a symmetric nerve relation on $\iota$, and $c :
\iota \times \iota \to M$ antisymmetric.

**Lemma 5.1 (Concatenation).** $W_c(i, l_1 {+\!\!+} l_2) = W_c(i, l_1) +
W_c(\operatorname{end}(i,l_1), l_2)$, and $\operatorname{end}(i, l_1 {+\!\!+}
l_2) = \operatorname{end}(\operatorname{end}(i,l_1), l_2)$.

*Proof.* Induction on $l_1$. $\square$

**Lemma 5.2 (Reversal negates holonomy).** For the reversed walk $\bar l$ (the
walk from $\operatorname{end}(i,l)$ back to $i$),
$$W_c(\operatorname{end}(i,l), \bar l) = -\,W_c(i, l).$$

*Proof sketch.* Induction on $l$, using Lemma 5.1 and antisymmetry $c_{ji} =
-c_{ij}$ at the final step. This is the *only* place antisymmetry is used, and
without it the theorem below is false in the sufficiency direction. $\square$

**Lemma 5.3 (Discrete fundamental theorem of calculus).** If $c_{ij} = f_j -
f_i$ for every edge, then $W_c(i,l) = f(\operatorname{end}(i,l)) - f(i)$ for
every walk. Hence every coboundary is cycle-consistent.

*Proof.* Telescoping induction on $l$. $\square$

**Theorem 5.4 (Discrete Poincaré Lemma).** Let $\iota$ be nonempty, $A$
symmetric and connected, and $c$ antisymmetric with values in an abelian group
$M$. Then
$$c \text{ is a coboundary on } A \iff c \text{ is cycle-consistent}.$$

*Proof sketch.* ($\Rightarrow$) is Lemma 5.3. ($\Leftarrow$): fix a base region
$b$ and, for each $i$, a walk $p_i$ from $b$ to $i$; set $f_i := W_c(b, p_i)$.
Given an edge $A_{ij}$, the concatenation $p_i {+\!\!+} (j :: \bar p_j)$ is a
*closed* walk at $b$ (it runs $b \to i \to j \to b$), so cycle-consistency gives
$$W_c(b, p_i) + c_{ij} + W_c(j, \bar p_j) = 0 .$$
By Lemma 5.2, $W_c(j, \bar p_j) = -W_c(b, p_j) = -f_j$, hence $f_i + c_{ij} -
f_j = 0$, i.e. $c_{ij} = f_j - f_i$. $\square$

**Corollary 5.5 (Loop obstruction certificate).** If some closed walk has
$W_c(i,l) \ne 0$, then $c$ is not a coboundary. A single loop with nonzero
holonomy is a complete proof of non-gluability.

**Theorem 5.6 (Tree nerves have vanishing $H^1$).** Let the nerve be a rooted
tree: a root $r$, a parent map $\pi$, and a rank function with $\operatorname{rk}
(\pi(i)) < \operatorname{rk}(i)$ for $i \ne r$, with $A_{ij}$ iff one of $i,j$ is
the parent of the other. Then *every* antisymmetric $M$-valued $c$ is a
coboundary — no cycle-consistency hypothesis is needed.

*Proof sketch.* Define the potential by well-founded recursion on rank: $f_r =
0$ and $f_i = f_{\pi(i)} + c_{\pi(i) i}$. Each tree edge equation then holds by
construction in one orientation and by antisymmetry in the other. $\square$

**Corollary 5.7.** Every closed walk in a tree nerve has vanishing holonomy, for
every antisymmetric discrepancy: tree-shaped covers cannot host a cohomological
obstruction.

### 5.1 Quantitative gluing

Take $M = \mathbb{R}$ and suppose each overlap discrepancy is small.

**Lemma 5.8a (Holonomy growth).** If $|c_{xy}| \le \varepsilon$ for every edge,
then $|W_c(i,l)| \le |l| \cdot \varepsilon$ for every walk $l$.

*Proof.* Induction with the triangle inequality. $\square$

**Lemma 5.8b (Lipschitz potential).** If moreover $c_{ij} = f_j - f_i$ on edges
and $j = \operatorname{end}(i,l)$, then $|f_j - f_i| \le |l| \cdot \varepsilon$.

**Theorem 5.8 (Certified radius transfer).** Suppose the local certified radii
$r : \iota \to \mathbb{R}$ form a global section (i.e. $c_{ij} = r_j - r_i$ on
edges), every overlap discrepancy satisfies $|c_{xy}| \le \varepsilon$ with
$\varepsilon \ge 0$, and every region is reachable from a base region $i_0$ by a
walk of length at most $D$ (the nerve has diameter $\le D$). Then
$$r_j \;\ge\; r_{i_0} - D\varepsilon \qquad \text{for every region } j .$$

*Proof.* By Lemma 5.8b, $|r_j - r_{i_0}| \le |l|\varepsilon \le D\varepsilon$
for the connecting walk $l$; take the lower bound. $\square$

Thus vanishing cohomology gives *existence* of a global certificate, and the
metric geometry of the nerve (diameter, overlap discrepancy) gives its
*constant*.

---

## 6. Exact cohomology of the loop nerve, with arbitrary coefficients

The cyclic nerve models a cover $U_0, U_1, \dots, U_n$ with $U_i \cap U_{i+1}
\ne \emptyset$ cyclically. A $1$-cochain is a family $g : \mathbb{Z}/(n{+}1) \to
M$ (one value per overlap) and the coboundary is $(\delta f)_i = f_{i+1} - f_i$.
The **holonomy** is $\mathcal{H}(g) = \sum_i g_i$.

**Theorem 6.1 (Loop obstruction, arbitrary coefficients).** For any abelian
group $M$ and $g : \mathbb{Z}/(n{+}1) \to M$,
$$\exists f,\ \delta f = g \iff \sum_i g_i = 0 .$$

*Proof sketch.* ($\Rightarrow$) Reindexing by $i \mapsto i+1$ is a bijection, so
$\sum_i (f_{i+1} - f_i) = 0$. ($\Leftarrow$) Take the discrete primitive $f_k :=
\sum_{j < k} g_j$. For $k < n$ the equation $f_{k+1} - f_k = g_k$ is immediate;
at the wrap-around index $k = n$ one needs $f_0 - f_n = g_n$, i.e. $0 -
\sum_{j<n} g_j = g_n$, which is exactly the hypothesis $\sum_i g_i = 0$. $\square$

**Theorem 6.2 ($H^1$ of a loop is the coefficient group).** For every abelian
group $M$,
$$H^1(\text{loop}_{n+1}, M) \;=\; \frac{\{g : \mathbb{Z}/(n{+}1) \to M\}}
{\operatorname{im}\delta} \;\cong\; M,$$
the isomorphism being induced by the holonomy $\mathcal H$.

*Proof sketch.* Theorem 6.1 says $\operatorname{im}\delta = \ker \mathcal H$;
$\mathcal H$ is surjective (send $m$ to the indicator cochain $i \mapsto [i =
0]\,m$); apply the first isomorphism theorem. $\square$

**Theorem 6.3 (Real coefficients).** $H^1(\text{loop}, \mathbb{R}) \cong
\mathbb{R}$, so $\dim H^1 = 1$: the loop nerve carries exactly one independent
obstruction class, and two discrepancies are cohomologous iff they have the same
holonomy — the holonomy is a *complete* invariant.

**Theorem 6.4 ($\mathbb{Z}/2$ parity obstruction).** Interpret $g_i = 1 \in
\mathbb{Z}/2$ as "the predicted label flips across the overlap $U_i \cap
U_{i+1}$". If the number of flips around the loop is odd, then no globally
consistent labelling of the regions exists.

*Proof.* By Theorem 6.1 with $M = \mathbb{Z}/2$: $\sum_i g_i = 1 \ne 0$. $\square$

**Theorem 6.5 (Realised generator).** The single-flip pattern $g_i = [i = 0]$ has
holonomy $1$ in $\mathbb{Z}/2$ and is therefore a nontrivial class: the
$\mathbb{Z}/2$-cohomology of the loop is not abstractly nonzero but comes with an
exhibited generator. Two flip patterns are cohomologous iff they have the same
flip parity.

### 6.1 The quantitative defect theorem

Non-vanishing cohomology acquires a *metric* meaning.

**Theorem 6.6 (Defect Theorem).** Let $g : \mathbb{Z}/(n{+}1) \to \mathbb{R}$
have holonomy $H = \sum_j g_j$. Then
$$\min\Big\{\varepsilon \ge 0 \;:\; \exists f,\ \forall i,\
|(\delta f)_i - g_i| \le \varepsilon \Big\} \;=\; \frac{|H|}{n+1},$$
and the minimum is attained (it is a least element, not an infimum).

*Proof sketch.* *Lower bound.* Since $\sum_i (\delta f)_i = 0$, we have $\sum_i
((\delta f)_i - g_i) = -H$, so by the triangle inequality $|H| \le (n+1)
\varepsilon$ whenever every mismatch is $\le \varepsilon$.
*Attainment.* Set $g'_i := g_i - H/(n+1)$. Then $\sum_i g'_i = 0$, so by Theorem
6.1 there is $f$ with $\delta f = g'$, and the mismatch is the constant
$|(\delta f)_i - g_i| = |H|/(n+1)$ at *every* overlap. $\square$

**Corollary 6.7 (Adversarial witness scale).** A loop of $n+1$ regions with
nonzero holonomy $H$ admits no global certificate assignment whose per-overlap
mismatch is everywhere below $|H|/(n+1)$: for every $f$ there is an overlap $i$
with $|(\delta f)_i - g_i| \ge |H|/(n+1)$.

**Remark 6.8 (Discrete Hodge theory).** The extremal cochain in Theorem 6.6 is
the *constant* one, $H/(n+1)$ at every overlap. This is the discrete analogue of
the harmonic representative of a de Rham class: each cohomology class has a
unique constant representative, and its sup-norm is the metric size of the
class.

---

## 7. The discrete torus: two independent obstructions

Consider a cover periodic in two parameters, e.g. a two-parameter family of
weight reparametrisations, or a loop of layers crossed with a loop of input
directions. Its nerve is the **discrete torus**: the $(m{+}1) \times (n{+}1)$
grid $\mathcal{G} = \mathbb{Z}/(m{+}1) \times \mathbb{Z}/(n{+}1)$ with
wrap-around in both directions.

A $0$-cochain is $f : \mathcal{G} \to \mathbb{R}$, with horizontal and vertical
coboundaries
$$(\delta_H f)_{(a,b)} = f_{(a+1,b)} - f_{(a,b)}, \qquad
(\delta_V f)_{(a,b)} = f_{(a,b+1)} - f_{(a,b)} .$$
A $1$-cochain is a pair $(h,v)$ of grid functions.

**Definition 7.1 (Flatness / plaquette cocycle condition).** $(h,v)$ is **flat**
if for every $p = (a,b)$,
$$h_{(a,b)} + v_{(a+1,b)} \;=\; v_{(a,b)} + h_{(a,b+1)} :$$
the total discrepancy around each unit square of the nerve vanishes. Coboundaries
are flat ($\delta^2 = 0$).

**Definition 7.2 (Row and column holonomies).**
$\mathcal{H}_{\mathrm{row}}(h, b) = \sum_a h_{(a,b)}$ and
$\mathcal{H}_{\mathrm{col}}(v, a) = \sum_b v_{(a,b)}$.

**Theorem 7.3 (Well-definedness and the gluing criterion).** For a flat $(h,v)$
the row holonomy is independent of the row and the column holonomy is
independent of the column. Moreover $(h,v)$ is a coboundary — $\exists f$ with
$\delta_H f = h$ and $\delta_V f = v$ — **iff both** holonomies vanish.

*Proof sketch.* Independence: summing the plaquette identity over a row shows
$\mathcal H_{\mathrm{row}}(h, b+1) = \mathcal H_{\mathrm{row}}(h,b)$, and dually.
Necessity: cyclic differences sum to zero. Sufficiency: define
$$f_{(a,b)} \;=\; \sum_{a' < a} h_{(a',0)} \;+\; \sum_{b' < b} v_{(a,b')},$$
integrating $h$ along the base row and $v$ up each column. The vertical equation
$\delta_V f = v$ uses only $\mathcal H_{\mathrm{col}} = 0$. The horizontal
equation requires converting the telescoping sum of $v$-differences between
adjacent columns into a telescoping sum of $h$-differences — this *is* the
plaquette identity, summed vertically — and then $\mathcal H_{\mathrm{row}} = 0$
closes the wrap-around. $\square$

**Theorem 7.4 ($H^1$ of the torus nerve).** With $\mathcal{Z}$ the space of flat
$1$-cochains,
$$H^1(\text{torus}, \mathbb{R}) \;=\; \mathcal{Z}/\operatorname{im}\delta
\;\cong\; \mathbb{R} \times \mathbb{R}, \qquad \dim H^1 = 2 ,$$
via $(h,v) \mapsto (\mathcal H_{\mathrm{row}}(h,0),
\mathcal H_{\mathrm{col}}(v,0))$. Two flat cochains are cohomologous iff both
their holonomies agree.

*Proof sketch.* Theorem 7.3 identifies $\operatorname{im}\delta$ with the kernel
of the holonomy pair. Surjectivity is witnessed by the constant flat cochains
$h \equiv r/(m{+}1)$, $v \equiv c/(n{+}1)$, which are flat trivially and realise
an arbitrary prescribed pair $(r,c)$. Apply the first isomorphism theorem.
$\square$

A doubly periodic cover therefore carries **two** independent adversarial
obstruction classes, in exact analogy with $b_1(T^2) = 2$.

---

## 8. The Betti Number Law

Path, loop and torus are instances of one law.

**Definition 8.1 (Finite oriented nerve graph).** A finite set $V$ of regions, a
finite set $E$ of overlaps, and maps $\mathrm{src}, \mathrm{tgt} : E \to V$. The
Čech complex in degrees $0,1$ is
$$(V \to \mathbb{R}) \xrightarrow{\ \delta\ } (E \to \mathbb{R}), \qquad
(\delta f)_e = f_{\mathrm{tgt}(e)} - f_{\mathrm{src}(e)},$$
with $H^1 := (E \to \mathbb{R}) / \operatorname{im}\delta$. Two regions are
adjacent when some edge joins them in either orientation.

**Theorem 8.2 ($H^0$ is the line of constants).** If $V \neq \emptyset$ and the
nerve is connected, then $\ker \delta = \mathbb{R}\cdot \mathbf{1}$, the span of
the constant certificate; hence $\dim \ker \delta = 1$ and $\dim
\operatorname{im}\delta = |V| - 1$.

*Proof sketch.* A cochain in $\ker\delta$ has no jump across any overlap, hence
is constant along every walk; connectivity makes it globally constant. The
constants are visibly in the kernel. Rank–nullity gives the image dimension.
$\square$

**Theorem 8.3 (Betti Number Law).** For a finite connected nonempty nerve graph,
$$\dim H^1 \;=\; |E| - |V| + 1 .$$

*Proof.* $\dim H^1 + \dim \operatorname{im}\delta = \dim (E \to \mathbb{R}) =
|E|$, and $\dim \operatorname{im}\delta = |V| - 1$ by Theorem 8.2. $\square$

**Corollary 8.4 (Gluing for arbitrary local data iff the nerve is a tree).**
$H^1 = 0 \iff |E| = |V| - 1$, i.e. the connected nerve is a spanning tree. In
that case $\delta$ is surjective: *every* overlap discrepancy is a coboundary.

**Remark 8.5 (Consistency check).** Path: $|E| = |V|-1$, Betti $0$, matching the
vanishing of $H^1$ for tree nerves (Theorem 5.6). Loop: $|E| = |V|$, Betti $1$,
matching Theorem 6.3. Torus: the *graph* Betti number of the grid is $|V|+1$,
and the plaquette relations cut it down to $2$ (Theorem 7.4); the discrepancy is
precisely the rank of the plaquette relation matrix, which is the subject of
Conjecture C1 in §11.

**Remark 8.6 (Design principle).** The number of independent ways a family of
local certificates can fail to glue is not a property of the classifier. It is
$|E| - |V| + 1$, a property of the *cover*. Every overlap beyond a spanning tree
is one additional independent obstruction. Cover design is therefore a
certified-robustness intervention: choosing a tree-shaped cover guarantees
gluability of arbitrary local data, at the cost of larger overlap scale $\delta$
and hence weaker radii — the fundamental trade-off of the theory.

**Remark 8.7 (Disconnected covers).** For a nerve with $k$ connected components
the correct statement is $\dim H^1 = |E| - |V| + k$; connectivity is genuinely
used in Theorem 8.2, and an empty cover has $H^0 = 0$.

---

## 9. Multi-class classifiers: nonabelian monodromy

For $k \ge 3$ classes, a local section is a *labelling* of the classes on a
region, and the transition datum on an overlap is a **relabelling**: an element
of the symmetric group $S_k$. Holonomy becomes an ordered product, which does not
commute.

**Definition 9.1.** Let $G$ be a group. A transition cochain is $c : \iota \times
\iota \to G$ with $c_{ji} = c_{ij}^{-1}$. Its **monodromy** along a walk is the
ordered product $P_c(i, l) = c_{i j_1} c_{j_1 j_2} \cdots c_{j_{k-1} j_k}$,
with $P_c(i, [\,]) = 1$. The cochain is a **multiplicative coboundary** if there
is $f : \iota \to G$ with $c_{ij} = f_i^{-1} f_j$ on every edge, and has
**trivial monodromy** if $P_c(i,l) = 1$ for every closed walk.

**Lemma 9.2.** $P_c(i, l_1 {+\!\!+} l_2) = P_c(i,l_1)\,
P_c(\operatorname{end}(i,l_1), l_2)$, and reversing a walk *inverts* its
monodromy: $P_c(\operatorname{end}(i,l), \bar l) = P_c(i,l)^{-1}$.

**Theorem 9.3 (Nonabelian Discrete Poincaré Lemma).** On a connected nonempty
nerve with symmetric $A$ and $c_{ji} = c_{ij}^{-1}$:
$$c \text{ is a multiplicative coboundary} \iff c \text{ has trivial monodromy}.$$

*Proof sketch.* ($\Rightarrow$) telescoping: $P_c(i,l) = f_i^{-1}
f_{\operatorname{end}(i,l)}$, which is $1$ on closed walks. ($\Leftarrow$) fix
$b$, choose walks $p_i$ from $b$ to $i$, set $f_i := P_c(b,p_i)$. For an edge
$A_{ij}$, the closed walk $p_i {+\!\!+} (j :: \bar p_j)$ gives $f_i\, c_{ij}\,
f_j^{-1} = 1$, i.e. $c_{ij} = f_i^{-1} f_j$. Commutativity is never used; the
only structural input is that reversal inverts. $\square$

**Theorem 9.4 (Multi-class monodromy obstruction).** If transporting the class
labels of a $k$-class classifier around a closed walk of overlapping regions
yields a nontrivial permutation of $\{1,\dots,k\}$, then no globally consistent
labelling of the cover exists.

*Proof.* Contrapositive of the necessity half of Theorem 9.3 with $G = S_k$.
$\square$

**Theorem 9.5 (A realised three-class obstruction).** Take three mutually
overlapping regions of a three-class problem and define the transition cochain
$$c_{xy} = \begin{cases} (0\,1) & x < y\\ (0\,1)^{-1} & y < x \\ \mathrm{id} &
x = y\end{cases}$$
(crossing an overlap "upwards" swaps classes $0$ and $1$). Then $c_{yx} =
c_{xy}^{-1}$ holds by construction, the monodromy around the triangle $0 \to 1
\to 2 \to 0$ is the transposition $(0\,1) \ne \mathrm{id}$, and consequently no
global relabelling $f$ with $c_{xy} = f_x^{-1} f_y$ exists.

*Proof.* Direct computation of the ordered product $c_{01} c_{12} c_{20} =
(0\,1)(0\,1)(0\,1)^{-1} = (0\,1)$, followed by Theorem 9.4. $\square$

Every *pairwise* overlap in Theorem 9.5 is consistent by construction; the
inconsistency is purely global. For $k = 2$ the group $S_2 \cong \mathbb{Z}/2$
is abelian and Theorem 9.4 collapses to the parity obstruction (Theorem 6.4):
binary robustness hides the nonabelian nature of the multi-class problem.

---

## 10. Algorithms and applications

### 10.1 The certification pipeline

The theory yields a concrete procedure, whose inputs are exactly what a
pointwise certifier already produces.

**Algorithm A (Nerve construction).** Given anchors $x_1, \dots, x_N$ and an
overlap scale $\delta$, build the graph $A_{ij} \iff \|x_j - x_i\|_\infty \le
\delta$. Cost: $O(N^2 d)$ naively, $O(N \log N \cdot d)$ with spatial indexing
for moderate $d$.

**Algorithm B (Betti number).** Compute the connected components by union–find
and return $\beta_1 = |E| - |V| + k$ where $k$ is the number of components.
Cost: $O(|E|\,\alpha(|V|))$. By Theorem 8.3 this is precisely the number of
independent obstruction classes of the cover.

**Algorithm C (Holonomy audit).** Choose a spanning forest; each non-tree edge
$e$ determines a fundamental cycle, and the holonomy of $e$ is the sum of the
discrepancies around it. The $\beta_1$ fundamental cycles give a basis of the
cycle space, hence a complete list of independent obstructions. Cost: $O(|E| \cdot
\text{diam})$.

**Algorithm D (Certificate gluing / refutation).** Run a pointwise certifier at
each anchor with radius $\delta$. If all succeed and the nerve is connected,
Theorem 3.6 outputs a single global certificate on $\bigcup_i \bar B(x_i,
\delta)$. If a sign flip is detected along a walk, Lemma 4.1 localises the
flipping edge in $O(\text{walk length})$ and Theorem 4.2 produces a boundary
point by bisection on the segment $[x_u, x_v]$ to precision $\eta$ in
$O(\log(\delta/\eta))$ score evaluations. The output is an explicit adversarial
witness $z$ with $s(z) = 0$ and $\|z - x_u\|_\infty \le \delta$.

**Algorithm E (Defect computation).** On a cycle of $n{+}1$ regions with
real-valued discrepancies $g$, return $|{\sum_i g_i}|/(n+1)$, the exact minimal
uniform mismatch (Theorem 6.6), and the harmonic representative $g_i -
H/(n+1)$. Cost: $O(n)$.

### 10.2 Consequences for practice

1. **Cover design is an intervention.** By Corollary 8.4, a tree-shaped nerve is
   obstruction-free for arbitrary local data. When the anchors' overlap graph is
   nearly a tree, few audits are needed; when it has many independent cycles,
   each must be checked.
2. **Auditing is cheap.** Detecting an obstruction requires only score
   evaluations at the anchors (a sign pattern) plus a bisection; no gradients,
   no Lipschitz estimate, no attack heuristic.
3. **Witnesses, not warnings.** A detected obstruction comes with an explicit
   input on the decision boundary within $\delta$ of a named anchor — actionable
   evidence rather than a failed certificate.
4. **Quantitative budgeting.** Theorem 5.8 turns per-overlap tolerance
   $\varepsilon$ and nerve diameter $D$ into a uniform certified radius $r_{i_0}
   - D\varepsilon$; Theorem 6.6 converts a residual holonomy into an unavoidable
   mismatch $|H|/(n+1)$.
5. **Multi-class auditing is monodromy computation.** For $k$ classes, the audit
   returns a permutation per fundamental cycle; the obstruction group is the
   image of the monodromy representation, and triviality of that image is exactly
   global label consistency (Theorem 9.3).

### 10.3 Scope and limitations

The Gluing Theorem is a statement about the *union of the certified balls*; it
does not certify points far from every anchor. The overlap hypothesis (O) ties
the certified radius to the anchor spacing: dense anchors give a small $\delta$
and thus a modest certified radius over a large union, while sparse anchors ask
for a large $\delta$ that pointwise certification may not deliver. The converse
theorems are sharp in the sense of producing a boundary point within $\delta$,
but they do not, by themselves, produce a *misclassified* point at $L^\infty$
distance exactly $\delta$ — obtaining that requires a lower bound on the growth
of $|s|$ past the boundary, i.e. a reverse Lipschitz hypothesis (Conjecture C3).

---

## 11. Future directions

**C1. Plaquette rank conjecture.** For a finite $2$-dimensional nerve (regions,
overlaps, triple overlaps), $\dim H^1 = |E| - |V| + 1 - \operatorname{rank}
\delta^1$, where $\delta^1$ is the plaquette coboundary; equivalently $\dim H^1 =
\dim \ker \delta^1 - (|V| - 1)$. This is verified at both extremes proved here:
the loop ($\operatorname{rank}\delta^1 = 0$, $\dim H^1 = 1$) and the discrete
torus, where the $(m{+}1)(n{+}1)$ plaquette relations have rank $|V| - 1$ and cut
$\dim H^1$ from $|V|+1$ to exactly $2$. The insight is that the drop from the
graph Betti number to the true Čech $H^1$ is precisely the rank of the plaquette
relation matrix, so counting adversarial obstructions of a real cover is a rank
computation, not a homotopy computation.

**C2. Betti number = maximal certified radius deficit.** For a connected cover of
a continuous score with overlap scale $\delta$, if the nerve has first Betti
number $b$, then the set of local certificate families that fail to glue is a
codimension-$b$ condition, and there exist scores realising exactly $b$
independent obstruction scales $|H_1|/L_1, \dots, |H_b|/L_b$, each an upper bound
on the certified $L^\infty$ radius of some region. The insight: the *number* of
independent loops of the cover controls the *number* of independent adversarial
directions.

**C3. Lipschitz refinement.** Upgrade the boundary-point witness of Theorem 4.3
to a *misclassification* witness. With a reverse-Lipschitz (non-degeneracy)
hypothesis on $s$ near the boundary, a zero at distance $\le \delta$ from an
anchor should yield an actual sign-flipped point at distance $\le \delta +
|s(x_u)|/\mu$, giving a two-sided bracket on the true certified radius.

**C4. Persistent obstructions.** Vary the overlap scale $\delta$ and record the
birth and death of holonomy classes: a persistence module of adversarial
obstructions, whose bars measure the range of scales at which a given
vulnerability is visible.

**C5. Nonabelian defect theorem.** Find the $S_k$-analogue of Theorem 6.6: given
a monodromy representation with image $\Gamma \le S_k$, what is the minimal
per-overlap "relabelling distance" achievable by a global labelling? A natural
candidate is a word-metric analogue of $|H|/(n+1)$ with respect to a generating
set of $\Gamma$.

---

## 12. Conclusion

Certified robustness has been treated as an analytic subject: bound a Lipschitz
constant, propagate an interval, solve a relaxation. The results assembled here
show that the *assembly* of certificates — the step from pointwise promises to
regional guarantees — is not analytic at all. It is cohomological, and it is
computable.

Concretely: certification forces the sheaf axiom; on a connected nerve local
certificates always glue into a single $L^\infty$ certificate over the union of
the balls; a failure to glue is exactly a nonzero holonomy class and produces,
by continuity alone, an explicit decision-boundary point within the overlap
scale of a named anchor; the number of independent ways failure can occur is
$|E| - |V| + 1$, zero precisely for tree-shaped covers; the size of a failure on
a loop is exactly $|H|/(n+1)$; and for multi-class problems the invariant is a
permutation monodromy that can be nontrivial even when every pairwise overlap is
consistent.

The upshot for practice is a shift in what one optimises. One does not only
train for large pointwise radii; one also *designs the cover* whose nerve one
must audit. Topology, in this setting, is not a metaphor for robustness. It is
the accounting system.
