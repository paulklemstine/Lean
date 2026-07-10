# The Exact Vertex‑Ramsey Threshold for Clique Families on Complete Host Graphs

## Abstract

We determine, exactly and with explicit extremal witnesses, the threshold for
the *vertex‑Ramsey property* of clique families on the complete graph. Given a
finite palette of colors and, for each color $i$, a target clique size $s_i \ge
1$, we say a graph $G$ *vertex‑arrows* the family $(K_{s_i})_i$ if every coloring
of the vertices of $G$ contains, in some color $i$, a monochromatic $G$-clique on
$s_i$ vertices. Our central result is the sharp characterization
$$K_n \to_v (K_{s_i})_i \quad\Longleftrightarrow\quad \sum_i (s_i - 1) < n,$$
equivalently that the vertex‑Ramsey number of the family is exactly
$1 + \sum_i (s_i - 1)$. The positive direction follows from a general local
criterion — any host containing a clique on more than $\sum_i (s_i - 1)$ vertices
vertex‑arrows the family — combined with a weighted pigeonhole principle; the
negative direction is witnessed by an explicit capacity‑respecting coloring
constructed via an embedding into a disjoint union of bounded color classes. We
record monotonicity in the host graph and in the target sizes, specialize to the
classical monochromatic‑edge (pigeonhole) case, and extend the sufficiency
direction to arbitrary target graphs $H_i$, where the threshold
$\sum_i(|V(H_i)|-1) < n$ transfers verbatim. Finally, we contrast the *additive*
governing parameter $\sum_j(\omega(H_j)-1)$ of the vertex problem with the
*multiplicative* parameter $\psi = \prod_j (\omega(H_j)-1)$ that governs the
edge‑density / random‑perturbation regime, clarifying the sum‑versus‑product
dichotomy between coloring vertices and coloring connections.

**Keywords:** vertex‑Ramsey property, clique family, pigeonhole principle,
extremal coloring, Ramsey number, randomly perturbed graphs, Turán density.

---

## 1. Introduction

Ramsey theory studies the inevitability of order in large structures: partition a
sufficiently large system, and some part must contain a prescribed pattern. The
canonical graph‑theoretic instance colors the *edges* of a complete graph and
seeks monochromatic subgraphs. A parallel and in several respects simpler theory
colors the *vertices*. It is this vertex variant, in its multicolor,
multi‑target form, that we treat here.

The problem we solve is deterministic, but its motivation is not. In the theory
of *randomly perturbed graphs* one begins with a dense host $G_0$ on $n$
vertices, adds $m$ random edges, and asks for the threshold value of $m$ at which
the perturbed graph becomes Ramsey for a fixed family of targets. For the edge
variant, the relevant parameter is a product of clique numbers and the critical
host density is a Turán density $1 - 1/\psi$. Isolating the deterministic
combinatorial core of such results — the exact extremal thresholds and the
colorings that witness them — is both a prerequisite to the probabilistic theory
and interesting in its own right. The vertex side, developed below, admits a
completely clean and exact answer.

### 1.1 Contributions

1. A general sufficiency criterion (Theorem 3.2): any host graph containing a
   clique larger than $\sum_i(s_i-1)$ vertex‑arrows the clique family.
2. The exact threshold on the complete host (Theorem 4.3):
   $K_n \to_v (K_{s_i})_i \iff \sum_i(s_i-1) < n$, hence vertex‑Ramsey number
   $1 + \sum_i(s_i - 1)$.
3. An explicit extremal coloring (Theorem 4.1) realizing the lower bound.
4. Monotonicity in host and target (Propositions 3.4–3.5), the pigeonhole
   specialization (Section 5), and an extension to arbitrary target graphs
   (Theorem 6.1).
5. A conceptual account of the sum‑versus‑product dichotomy separating the
   vertex problem from the edge/density problem (Section 7).

---

## 2. Definitions

Throughout, a *graph* $G = (V, E)$ is finite and simple, and $G.\mathrm{Adj}(u,v)$
denotes adjacency. A finite set $S \subseteq V$ is a *clique* of $G$ if every two
distinct vertices of $S$ are adjacent; we write this $\mathrm{IsClique}(S)$. The
*complete graph* on $V$ is $K_V$ (or $K_n$ when $|V| = n$), in which all distinct
pairs are adjacent, so every subset is a clique.

Let $\kappa$ be a finite set of *colors*. A *coloring* is a function
$c : V \to \kappa$. For a color $i$, the *color class* is
$c^{-1}(i) = \{v : c(v) = i\}$.

**Definition 2.1 (Vertex‑arrowing a clique family).**
Let $s : \kappa \to \mathbb{N}$ assign each color a target size. A graph $G$
*vertex‑arrows* the family $(K_{s_i})_{i \in \kappa}$, written
$G \to_v (K_{s_i})_i$, if for every coloring $c : V \to \kappa$ there exist a
color $i$ and a finite set $S \subseteq V$ such that
- every vertex of $S$ has color $i$ (i.e. $c(v) = i$ for all $v \in S$),
- $|S| = s_i$, and
- $S$ is a clique of $G$.

Intuitively: no coloring avoids a monochromatic $G$-clique of the prescribed size
in some color.

**Definition 2.2 (Vertex‑Ramsey number).**
The *vertex‑Ramsey number* of a clique family $(K_{s_i})_i$ is the least
$n$ such that $K_n \to_v (K_{s_i})_i$.

**Definition 2.3 (Escape capacity).**
The *escape capacity* of the family is $C(s) = \sum_{i \in \kappa} (s_i - 1)$.
It measures the total number of vertices a colorer may use while keeping every
color class strictly below its target size.

---

## 3. The general sufficiency criterion

The heart of the positive direction is a weighted pigeonhole principle. We use
$\mathbb{N}$ subtraction (truncated), so $s_i - 1 = 0$ when $s_i = 0$; all
statements below are stated for the sizes that matter.

**Lemma 3.1 (Weighted pigeonhole).**
Let $\kappa$ be finite, $s : \kappa \to \mathbb{N}$, and $A$ a finite set of
vertices with $C(s) = \sum_i (s_i - 1) < |A|$. Then for every coloring
$c$ there is a color $i$ whose class within $A$ has size at least $s_i$:
$$|\{v \in A : c(v) = i\}| \ge s_i.$$

*Proof.* Suppose not: $|\{v \in A : c(v) = i\}| \le s_i - 1$ for every $i$.
Partitioning $A$ by color and summing,
$$|A| = \sum_i |\{v \in A : c(v)=i\}| \le \sum_i (s_i - 1) = C(s) < |A|,$$
a contradiction. $\qquad\blacksquare$

**Theorem 3.2 (Clique sufficiency criterion).**
Let $G$ be a graph containing a clique $K \subseteq V$ with
$C(s) < |K|$. Then $G \to_v (K_{s_i})_i$.

*Proof.* Fix a coloring $c$. Apply Lemma 3.1 with $A = K$: some color $i$ has
$|\{v \in K : c(v) = i\}| \ge s_i$. Choose a subset $S$ of that class with
$|S| = s_i$. Every vertex of $S$ has color $i$, and $S \subseteq K$ is a subset of
a clique, hence itself a clique of $G$. Thus $S$ witnesses the arrowing. $\qquad\blacksquare$

Theorem 3.2 is the master lemma: every positive result below specializes it.

**Proposition 3.4 (Monotonicity in the host).**
If $G \to_v (K_{s_i})_i$ and $G \le G'$ (that is, $G'$ has all the edges of $G$
and possibly more on the same vertex set), then $G' \to_v (K_{s_i})_i$.

*Proof.* Any witnessing set $S$ that is a clique of $G$ remains a clique of $G'$,
since adjacency only increases. $\qquad\blacksquare$

**Proposition 3.5 (Monotonicity in the targets).**
If $G \to_v (K_{s_i})_i$ and $t_i \le s_i$ for all $i$, then
$G \to_v (K_{t_i})_i$.

*Proof.* Given a coloring, obtain a monochromatic clique $S$ of size $s_i$ in some
color $i$; take any subset of $S$ of size $t_i \le s_i$. It is still
monochromatic and still a clique. $\qquad\blacksquare$

---

## 4. The exact threshold on the complete graph

We now specialize to $G = K_n$ and prove sharpness. Assume $s_i \ge 1$ for all
$i$ (a target of size $0$ is trivially achieved and can be discarded).

### 4.1 The extremal coloring (lower bound witness)

**Theorem 4.1 (Capacity‑respecting coloring).**
Let $\mathrm{cap} : \kappa \to \mathbb{N}$ be capacities with
$|V| \le \sum_i \mathrm{cap}_i$. Then there is a coloring $c : V \to \kappa$ such
that every color class has size at most its capacity:
$$|\{v : c(v) = i\}| \le \mathrm{cap}_i \quad\text{for all } i.$$

*Proof.* Consider the disjoint union $D = \coprod_{i \in \kappa}
\{1, \dots, \mathrm{cap}_i\}$, whose cardinality is $\sum_i \mathrm{cap}_i \ge
|V|$. Since $|V| \le |D|$, there is an injection $f : V \hookrightarrow D$.
Define $c(v)$ to be the color index of the block containing $f(v)$. For each
color $i$, the vertices with $c(v) = i$ inject (via $f$) into the $i$-block of $D$,
which has exactly $\mathrm{cap}_i$ elements; hence
$|\{v : c(v) = i\}| \le \mathrm{cap}_i$. $\qquad\blacksquare$

**Theorem 4.2 (Lower bound: no arrowing above the threshold).**
If $s_i \ge 1$ for all $i$ and $|V| \le C(s) = \sum_i (s_i - 1)$, then
$K_n \not\to_v (K_{s_i})_i$.

*Proof.* Apply Theorem 4.1 with $\mathrm{cap}_i = s_i - 1$; the hypothesis
$|V| \le \sum_i (s_i - 1)$ is exactly the capacity condition. This yields a
coloring $c$ with every class of size at most $s_i - 1$. Under $c$, no color $i$
can host a monochromatic set of size $s_i$: a monochromatic set in color $i$
lies inside the color class $\{v : c(v)=i\}$, whose size is at most
$s_i - 1 < s_i$. Hence $c$ defeats every attempt at arrowing. $\qquad\blacksquare$

### 4.2 The characterization

**Theorem 4.3 (Exact vertex‑Ramsey threshold).**
For target sizes with $s_i \ge 1$,
$$K_n \to_v (K_{s_i})_i \quad\Longleftrightarrow\quad \sum_i (s_i - 1) < n.$$
Equivalently, the vertex‑Ramsey number of $(K_{s_i})_i$ equals
$$N(s) = 1 + \sum_i (s_i - 1).$$

*Proof.* ($\Leftarrow$) If $\sum_i(s_i-1) < n = |V|$, then $K_n$ itself is a
clique on $n > C(s)$ vertices, so Theorem 3.2 gives the arrowing. ($\Rightarrow$)
Contrapositive: if $\sum_i(s_i-1) \ge n$, Theorem 4.2 exhibits a coloring with no
monochromatic clique of target size, so $K_n \not\to_v (K_{s_i})_i$. The
equivalent numerical form follows since $\sum_i(s_i-1) < n$ is
$1 + \sum_i(s_i-1) \le n$. $\qquad\blacksquare$

The boundary case $\sum_i (s_i - 1) = n$ lies on the colorer's side: with exactly
$n$ units of capacity the extremal coloring succeeds, which is why the threshold
is strict ($<$, not $\le$).

---

## 5. The monochromatic‑edge (pigeonhole) specialization

Take every target to be an edge, $s_i \equiv 2$, over an $r$-color palette
$\kappa = \{1,\dots,r\}$. Then $C(s) = \sum_{i=1}^r (2-1) = r$, and Theorem 4.3
collapses to the classical pigeonhole principle.

**Corollary 5.1 (Monochromatic‑edge threshold).**
$K_n \to_v (K_2, \dots, K_2)$ (with $r$ colors) if and only if $r < n$.

*Proof.* Immediate from Theorem 4.3 with $C(s) = r$. $\qquad\blacksquare$

**Examples.**
- *Triangle, two colors.* Since $2 < 3$, every $2$-coloring of $K_3$ has a
  monochromatic edge.
- *Single edge, two colors.* Since $2 \not< 2$, coloring the two endpoints of
  $K_2$ with distinct colors avoids a monochromatic edge. The threshold has no
  slack.

Corollary 5.1 identifies the pigeonhole principle as the $s_i \equiv 2$ shadow of
the general threshold, and the general threshold as the pigeonhole weighted by
required team sizes.

---

## 6. Arbitrary target graphs

The completeness of $K_n$ was used only to promote a monochromatic set to a
clique. This lets us replace clique targets by arbitrary target graphs.

Let each color $i$ carry a finite target graph $H_i$ on a vertex set $\beta_i$.
A *monochromatic copy* of $H_i$ in a host $G$ under a coloring $c$ is an injection
$f : \beta_i \to V$ that preserves adjacency (if $w, w'$ are adjacent in $H_i$
then $f(w), f(w')$ are adjacent in $G$) whose image is monochromatic
($c(f(w)) = i$ for all $w$). We say $G$ *graph‑vertex‑arrows* $(H_i)_i$ if every
coloring contains a monochromatic copy of some $H_i$.

**Theorem 6.1 (Arbitrary targets on the complete host).**
If $\sum_i (|\beta_i| - 1) < n$, then $K_n$ graph‑vertex‑arrows $(H_i)_i$: every
coloring contains a monochromatic copy of some $H_i$.

*Proof.* Set clique targets $s_i = |V(H_i)| = |\beta_i|$. By Theorem 4.3, the
hypothesis $\sum_i (|\beta_i| - 1) < n$ gives $K_n \to_v (K_{s_i})_i$, so any
coloring yields a monochromatic clique $S$ with $|S| = |\beta_i|$ in some color
$i$. Choose any bijection $\beta_i \to S$; call it $f$. It is injective, its
image $S$ is monochromatic, and — because $S$ is a clique of $K_n$ — every pair
$f(w), f(w')$ is adjacent, so $f$ trivially preserves the adjacencies of $H_i$.
Thus $f$ is a monochromatic copy of $H_i$. $\qquad\blacksquare$

Only the *vertex counts* $|V(H_i)|$ enter the bound; the internal structure of
the $H_i$ is irrelevant on the complete host. The matching converse for general
$H_i$ — sharpening $|V(H_i)|$ to the clique number $\omega(H_i)$ and constructing
an extremal coloring for arbitrary targets — is discussed in Section 8.

---

## 7. Sum versus product: vertices against connections

The clique number $\omega(H_j)$ — the size of the largest clique in $H_j$ —
appears in both the vertex problem treated here and in the edge/density theory
that motivates it, but in strikingly different arithmetic.

**Vertex side (this paper).** The governing quantity is the *sum*
$$\sum_j (\omega(H_j) - 1),$$
and the vertex‑Ramsey number of a clique family is one more than it,
$1 + \sum_j (\omega(H_j) - 1)$ (Theorem 4.3, with $s_j = \omega(H_j)$).

**Edge / density side.** In the random‑perturbation model, the governing quantity
is the *product*
$$\psi = \prod_j (\omega(H_j) - 1),$$
and the critical host edge density is the Turán density $\pi_c = 1 - 1/\psi$. The
conjectured sharp threshold for the number of random edges added to a host of
density just below $\pi_c$ has the form
$m_c(n) = \pi_c \binom{n}{2} + \Theta(n^{3/2})$, with a critical window of width
$\Theta(n^{3/2})$.

**Why the arithmetic differs.** Vertex colorings partition a *one‑dimensional*
resource, the vertex set; the maximal escape configuration places the capacities
$s_i - 1$ side by side, and disjoint capacities *add*. Edge colorings and density
extremal configurations live on the *two‑dimensional* set of pairs, where Turán‑
type extremal graphs are built by nesting independent parts; independent choices
*multiply*, producing $\psi = \prod_j(\omega(H_j)-1)$ and the density
$1 - 1/\psi$. The same atom $\omega(H_j) - 1$ thus surfaces additively when one
colors points and multiplicatively when one colors connections. Making this
dichotomy explicit clarifies precisely where each formula in the perturbation
conjecture originates.

---

## 8. Discussion and future work

The results above constitute the deterministic combinatorial core of the
vertex‑Ramsey threshold, with both extremal witnesses made explicit: the
capacity‑respecting coloring below the line and the forced monochromatic clique
above it. These are exactly the ingredients consumed by the probabilistic theory
of randomly perturbed graphs, where the extremal coloring is the obstruction that
random edges must destroy and the forced clique is the reason a controlled number
of random edges suffices.

Several avenues remain.

1. **General $H_j$, sharp both ways.** Theorem 6.1 handles arbitrary targets on
   the complete host in the sufficiency direction. Two refinements remain:
   sharpening the vertex count $|V(H_j)|$ to the clique number $\omega(H_j)$, and
   proving the matching converse (an extremal coloring on $K_n$ for general
   $H_j$).

2. **The Turán / edge side.** Establish $\mathrm{ex}(n, K_{\psi+1}) =
   (1 - 1/\psi)\binom{n}{2} + o(n^2)$ to connect $\psi$ explicitly to the host
   edge density $\pi_c = 1 - 1/\psi$ in the conjecture.

3. **The random‑perturbation model.** Introduce the perturbed graph
   $G_0 \cup G(n,m)$ and the window language of width $\Theta(n^{3/2})$. The
   sharp‑threshold statement is a deep probabilistic result; the deterministic
   pieces here (exact clique threshold, extremal coloring) are precisely the
   lemmas such proofs export.

4. **Quantitative window.** In the deterministic complete‑graph case the
   transition is a single value $N(s) = 1 + \sum_i(s_i-1)$; phrasing this as a
   degenerate critical window connects the sharp integer threshold to the
   $\Theta(n^{3/2})$-wide window of the probabilistic setting.

---

## 9. Conclusion

For clique families on the complete host we have determined the vertex‑Ramsey
threshold exactly: $K_n \to_v (K_{s_i})_i$ if and only if $\sum_i(s_i-1) < n$,
so the vertex‑Ramsey number is $1 + \sum_i(s_i-1)$. Both directions come with
explicit witnesses, the criterion generalizes to any host with a large clique
and to arbitrary target shapes, and the classical pigeonhole principle emerges as
the monochromatic‑edge special case. The additive parameter of the vertex problem
stands in clean contrast to the multiplicative parameter of the edge/density
theory, illuminating the sum‑versus‑product structure that underlies the broader
random‑perturbation conjecture.
