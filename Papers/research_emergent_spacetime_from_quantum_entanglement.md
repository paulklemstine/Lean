# Emergent Spacetime from Quantum Entanglement: A Combinatorial Theory of Einstein–Rosen Bridges

**Aristotle**

---

## Abstract

We develop a complete, self-contained combinatorial model in which the geometry of a
spatial slice of spacetime is *reconstructed* from the entanglement structure of a
quantum state, and in which the slogan "ER = EPR" — entangled pairs are joined by
microscopic Einstein–Rosen bridges — becomes a family of sharp theorems.

The model is a finite weighted graph $G$ of *cells*, whose edge weights are areas of
elementary surface elements, together with a distinguished set of *boundary* cells.
Entropy of a boundary region is the area of the minimal bulk surface anchored to it
(the discrete Ryu–Takayanagi prescription). To this well-studied min-cut picture we add
a genuinely geometric observable, the **throat capacity** $E(A,B)$: the area of the
smallest surface separating $A$ from $B$, with no homology constraint. We prove:

1. **Bridge detection.** For distinct cells $u,v$, $E(u,v) > 0$ if and only if a path of
   positive-area edges joins $u$ to $v$. A single real number decides bulk connectivity.
2. **The cross-section bound $I(A:B) \le 2E(A,B)$**, the toy-model form of the
   holographic inequality $I \le 2E_W$. Its engine is a sharp four-variable Boolean
   splitting inequality. Combined with $E(A,B) \le \min(S(A),S(B))$ this yields the
   **ER = EPR sandwich** $\tfrac12 I(A:B) \le E(A,B) \le \min(S(A),S(B))$, with all three
   quantities equal for a single throat.
3. **Emergent spacetime is tree-like.** The capacity kernel satisfies a Gomory–Hu
   inequality $\min(E(u,v),E(v,w)) \le E(u,w)$, so the emergent distance
   $d(u,v) = e^{-E(u,v)}$ is an *ultrametric*, hence a $0$-hyperbolic metric space —
   the discrete avatar of the negative curvature of anti-de Sitter space. Moreover
   $d(u,v) \le e^{-I(u:v)/2}$: distance decays exponentially in entanglement.
4. **Reconstruction.** In models without hidden bulk cells, the table of two-point mutual
   informations determines the entire emergent metric space: two such states with equal
   entanglement data have isometric emergent geometries.
5. **Monogamy.** Three capacities always form an isosceles triple whose two smallest
   members coincide, and a cell maximally entangled with a partner has no other bridge
   at all: a wormhole has exactly two mouths.
6. **Bit threads.** Flows through the bulk obey weak duality — no divergence-free,
   capacity-respecting flow can carry more than the throat cross-section — and the bound
   is attained for the elementary wormhole: max-flow equals min-cut for a single
   Einstein–Rosen bridge.
7. **A renormalisation flow.** Merging cells pushes the geometry forward functorially,
   widens throats, contracts the emergent metric ($1$-Lipschitz), and never decreases
   entropies; an explicit four-cell example shows the contraction is strict.
8. **$n$ Bell pairs.** The emergent space of $n$ independent Bell pairs of weights $w_i$
   is exactly $n$ two-point wormholes: distance $e^{-w_i}$ inside a pair, maximal distance
   $1$ across pairs, and at any scale in the window $[\max_i e^{-w_i}, 1)$ the clusters of
   the emergent ultrametric are precisely the Bell pairs.

---

## 1. Introduction

### 1.1 The idea

Two ideas from the last two decades of quantum gravity sit at the heart of this paper.

The first is the **Ryu–Takayanagi prescription**: in a holographic system, the
entanglement entropy of a boundary region $A$ equals the area of the minimal bulk surface
anchored to $\partial A$. Entropy, an information-theoretic quantity, is measured by a
*geometric* one.

The second is **ER = EPR**: the proposal that an entangled pair of particles is connected
by a microscopic Einstein–Rosen bridge — a wormhole. On this view, spacetime connectivity
is not a separate ingredient of physics but a *consequence* of entanglement. Van Raamsdonk's
thought experiment sharpens it: disentangle two halves of a holographic state and the bulk
pinches off; the two halves fly apart, and in the limit space itself is torn in two.

Both statements are, in their native setting, statements about continuous manifolds,
quantum field theories and an incompletely understood duality. This paper asks a
narrower question with a complete answer:

> In the simplest combinatorial model that supports a Ryu–Takayanagi prescription, what
> exactly does ER = EPR say, and is it true?

The answer is that it says a great deal, and all of it is true — with a caveat and a
sharp constant at each step. Entanglement does not merely *correlate* with connectivity;
it *quantifies* the width of the bridge, it *determines* the distance function, and the
distance function it determines is not an arbitrary metric but an ultrametric — a
tree.

### 1.2 What is new here

The min-cut model of holographic entropy is classical: subadditivity, strong
subadditivity, monogamy of mutual information and purity are all known to follow from
surface recombination. Our contribution is to move past *entropy inequalities* into
*geometry*:

- we introduce the throat capacity as an observable in its own right and prove it detects
  connectivity exactly (§3);
- we prove the toy-model cross-section inequality $I \le 2E$ with a sharp constant, from a
  four-variable Boolean lemma (§4);
- we show that the resulting distance function is an ultrametric, hence $0$-hyperbolic,
  and that it is reconstructible from two-point entanglement data alone (§5);
- we prove monogamy statements that force the wormhole network to be a tree, and that a
  maximally entangled cell has exactly one neighbour (§6);
- we introduce flows ("bit threads") and prove weak duality against throat capacity, with
  a matching flow for the elementary wormhole (§7);
- we construct a functorial coarse-graining operation and prove it is a metric contraction
  which is strict in general (§8);
- we compute the emergent geometry of $n$ Bell pairs completely (§9).

Everything below is stated and proved for finite models with real, nonnegative,
symmetric areas. No continuum limit, no field theory, and no unproved duality is used.

---

## 2. The model

### 2.1 Geometries, regions, areas

Fix a finite set $V$ of **cells** — the discrete spatial slice.

**Definition 2.1 (Geometry).** A *geometry* on $V$ is a function $w : V \times V \to \mathbb{R}$
with $w(x,y) = w(y,x)$ and $w(x,y) \ge 0$ for all $x,y$. We think of $w(x,y)$ as the area
of the elementary surface element separating cell $x$ from cell $y$; $w(x,y)=0$ means the
two cells are not adjacent.

**Definition 2.2 (Region and area).** A *region* is a Boolean function $f : V \to \{\textsf{true},
\textsf{false}\}$, identified with the set $\{x : f(x) = \textsf{true}\}$. Its *area* — the area of the
surface bounding it — is
$$
\operatorname{area}(f) \;=\; \frac12 \sum_{x \in V}\sum_{y \in V} [\,f(x) \ne f(y)\,]\; w(x,y),
$$
where $[\,\cdot\,]$ is $1$ if the condition holds and $0$ otherwise.

The factor $\tfrac12$ removes the double count. Two elementary reformulations are used
constantly.

**Lemma 2.3 (One-sided forms of the area).** For every region $f$,
$$
\operatorname{area}(f) \;=\; \sum_{x}\sum_{y} [\,f(x)=\textsf{true} \text{ and } f(y)=\textsf{false}\,]\,w(x,y)
\;=\; \sum_{f(x)=\textsf{true}}\;\sum_{f(y)=\textsf{false}} w(x,y).
$$

*Proof sketch.* For each ordered pair $(x,y)$ the summand $[f(x)\ne f(y)]\,w(x,y)$ splits as
$[f(x)=\textsf{true},f(y)=\textsf{false}]\,w(x,y) + [f(y)=\textsf{true},f(x)=\textsf{false}]\,w(x,y)$ (a four-case check on the
values of $f(x),f(y)$). Swapping the summation indices in the second term and using
$w(x,y)=w(y,x)$ shows the two double sums are equal, so each equals half the original
sum. The last expression is the same sum with the indicator absorbed into the range. $\square$

The area function is symmetric under complementation, $\operatorname{area}(f) = \operatorname{area}(\neg f)$, and it is
*submodular*:
$$
\operatorname{area}(f \wedge g) + \operatorname{area}(f \vee g) \;\le\; \operatorname{area}(f) + \operatorname{area}(g),
$$
which is the source of every entropy inequality below. Both facts follow from pointwise
inequalities on the Boolean indicator $[\,\cdot \ne \cdot\,]$.

Two cells $x,y$ are **adjacent** when $w(x,y) > 0$; a **bulk path** from $u$ to $v$ is a
finite chain $u = x_0, x_1, \dots, x_k = v$ of consecutively adjacent cells (the case $k=0$
being allowed). We write $u \rightsquigarrow v$.

### 2.2 Holographic models, entropy, mutual information

**Definition 2.4 (Holographic model).** A *holographic model* is a geometry $w$ on $V$
together with a subset $\partial V \subseteq V$ of **boundary cells**. Cells outside $\partial V$
are *hidden bulk cells*. A model has **no hidden bulk** if $\partial V = V$.

**Definition 2.5 (Admissibility and entropy).** Let $A$ be a region supported on the
boundary. A region $f$ is *admissible for $A$* if $f$ and $A$ agree on every boundary cell:
$f(v) = A(v)$ for all $v \in \partial V$. Hidden cells are free. The **entropy** of $A$ is
$$
S(A) \;=\; \min \{\operatorname{area}(f) : f \text{ admissible for } A\}.
$$
The minimum is over a nonempty finite set (take $f = A$), so it is attained; a minimiser is
called a **minimal surface** for $A$.

This is the discrete Ryu–Takayanagi prescription: $S(A)$ is the area of the smallest bulk
surface homologous to $A$. The homology constraint is exactly the condition "$f$ agrees
with $A$ on the boundary".

**Definition 2.6 (Mutual information).** For disjoint boundary regions $A, B$,
$$
I(A : B) \;=\; S(A) + S(B) - S(A \cup B).
$$

Submodularity of areas gives $I(A:B) \ge 0$ (subadditivity) at once, and the standard
recombination arguments give strong subadditivity and monogamy of mutual information. We
record one further classical inequality that will be used and that is not a direct
consequence of subadditivity alone.

**Theorem 2.7 (Araki–Lieb).** For disjoint boundary regions $A$ and $B$,
$$
S(A) \;\le\; S(A\cup B) + S(B), \qquad\text{hence}\qquad |S(A) - S(B)| \;\le\; S(A \cup B).
$$

*Proof sketch.* Let $C$ be the boundary complement of $A \cup B$. Two observations
suffice. First, entropy is *pure*: $S(X) = S(\partial V \setminus X)$ for boundary regions
$X$, because a region and its complement bound the same surface. Second, on the boundary,
the complement of $A$ is exactly $C \cup B$. Therefore $S(A) = S(C \cup B) \le S(C) + S(B)$
by subadditivity, and $S(C) = S(A \cup B)$ by purity again. Exchanging $A$ and $B$ and
combining gives the two-sided form. $\square$

**Definition 2.8 (Single cell).** For $u \in V$ write $\{u\}$ for the region containing
only $u$.

**Lemma 2.9 (Star area).** For any geometry and any cell $u$,
$\operatorname{area}(\{u\}) = \sum_{y \ne u} w(u,y)$: the surface enclosing a single cell has area equal
to the total weight of the edges incident to it.

Consequently, in a model with no hidden bulk, $S(\{u\}) = \sum_{y\ne u} w(u,y)$ and
$I(u:v) = 2\,w(u,v)$ — the mutual information of two cells is twice the area of the edge
joining them. This last identity is the exact sense in which "the geometry *is* the
entanglement" in the hidden-bulk-free case.

**Example 2.10 (The elementary wormhole).** Let $V = \{0,1\}$, both cells on the boundary,
and $w(0,1) = w \ge 0$. Then $S(\{0\}) = S(\{1\}) = w$, $S(\{0,1\}) = 0$, and
$I(0:1) = 2w$. This *pair model* is the smallest Einstein–Rosen bridge, and it will
saturate every inequality below.

---

## 3. Throat capacity: the width of a bridge

Entropy is constrained: the competing surfaces must be homologous to a boundary region. To
measure the *bridge* between two regions rather than the entropy of one, we drop the
constraint.

**Definition 3.1 (Separating surface).** A region $\sigma$ *separates* $A$ from $B$ if
$A \subseteq \sigma$ and $B \cap \sigma = \emptyset$; that is, $\sigma(v) = \textsf{true}$
whenever $A(v) = \textsf{true}$, and $\sigma(v) = \textsf{false}$ whenever $B(v) = \textsf{true}$.

**Definition 3.2 (Throat capacity).** For regions $A,B$ the *throat capacity* is
$$
E(A,B) \;=\; \min \{ \operatorname{area}(\sigma) : \sigma \text{ separates } A \text{ from } B\},
$$
with $E(A,B) = 0$ by convention if no separating region exists. When $A$ and $B$ are
disjoint the family is nonempty ($\sigma = A$ works), so the minimum is attained.

$E(A,B)$ is the cross-section of the Einstein–Rosen bridge joining $A$ to $B$: the
discrete analogue of the entanglement wedge cross-section $E_W$. Note the difference from
entropy: $E$ minimises over *all* separating regions, not only over those homologous to a
boundary region, and it is a function of a *pair* of regions.

Basic properties are immediate from the definition and from $\operatorname{area}(\sigma) = \operatorname{area}(\neg\sigma)$:

**Proposition 3.3.** $E(A,B) \ge 0$; $E(A,B) = E(B,A)$; and $E$ is monotone in the
geometry: if $w \le w'$ pointwise then $E_w(A,B) \le E_{w'}(A,B)$ for disjoint $A,B$.
Symmetry holds because complementing a minimal $A$–$B$ separating surface produces a
$B$–$A$ separating surface of the same area.

The monotonicity statement is already a form of Van Raamsdonk's principle: *more
entanglement means a wider bridge*.

### 3.1 A positive number detects a wormhole

**Lemma 3.4 (Zero area means closed).** A surface has zero area if and only if no
positive weight crosses it: $\operatorname{area}(\sigma) = 0$ iff $w(x,y) = 0$ for all $x$ with
$\sigma(x)=\textsf{true}$ and $y$ with $\sigma(y)=\textsf{false}$.

*Proof sketch.* Both directions use Lemma 2.3: the area is a sum of nonnegative terms
$w(x,y)$ over crossing pairs, and a sum of nonnegative reals vanishes iff every term
does. $\square$

**Lemma 3.5 (Closed regions absorb paths).** If $\sigma$ is closed in the sense of Lemma
3.4 and $u \rightsquigarrow v$ with $\sigma(u) = \textsf{true}$, then $\sigma(v) = \textsf{true}$.

*Proof sketch.* Induct along the path: a positive-weight step out of $\sigma$ is precisely
what closedness forbids. $\square$

**Theorem 3.6 (Bridge detection).** Let $u \ne v$. Then
$$
E(u,v) > 0 \quad\Longleftrightarrow\quad u \rightsquigarrow v .
$$
Bulk connectivity is decided by a single real number.

*Proof sketch.* ($\Leftarrow$, contrapositive of the forward direction) Suppose no path
joins $u$ to $v$. Let $R = \{x : u \rightsquigarrow x\}$ be the reachable set. Then $R$
contains $u$, misses $v$, and is closed under positive-weight steps, so $R$ separates $u$
from $v$ and $\operatorname{area}(R) = 0$ by Lemma 3.4; hence $E(u,v) = 0$.

($\Rightarrow$) Suppose $E(u,v) = 0$ and let $\sigma$ be a minimal separating surface, so
$\operatorname{area}(\sigma) = 0$. By Lemma 3.4 $\sigma$ is closed; by Lemma 3.5 any path from $u$ would
stay inside $\sigma$, but $\sigma(v) = \textsf{false}$, so no path reaches $v$. $\square$

---

## 4. Entanglement is bounded by the cross-section

We now prove the central quantitative statement. Its combinatorial core is a small
Boolean inequality, whose sharp constant $2$ is exactly the $2$ appearing in the
holographic bound $I \le 2E_W$.

**Lemma 4.1 (Splitting inequality).** For all bits $a_1,a_2,b_1,b_2 \in \{\textsf{true},\textsf{false}\}$,
$$
[\,a_1 \wedge b_1 \ne a_2 \wedge b_2\,] + [\,\neg a_1 \wedge b_1 \ne \neg a_2 \wedge b_2\,]
\;\le\; [\,b_1 \ne b_2\,] + 2\,[\,a_1 \ne a_2\,].
$$
The constant $2$ cannot be improved: for $a_1 = \textsf{true}$, $a_2 = \textsf{false}$, $b_1 = b_2 = \textsf{true}$
both sides equal $2$.

*Proof sketch.* Sixteen cases. If $a_1 = a_2$ the right-hand side is $[b_1\ne b_2]$ and
the left-hand side is at most that, since conjunction with a common bit can only merge
values. If $a_1 \ne a_2$ the right-hand side is at least $2$, which already dominates the
left-hand side. $\square$

**Proposition 4.2 (Area splitting).** For any regions $\sigma$ and $g$,
$$
\operatorname{area}(\sigma \wedge g) + \operatorname{area}(\neg\sigma \wedge g) \;\le\; \operatorname{area}(g) + 2\operatorname{area}(\sigma).
$$

*Proof sketch.* Apply Lemma 4.1 pointwise with $a_i = \sigma(x_i)$, $b_i = g(x_i)$ for
each ordered pair of cells, multiply by $w(x,y) \ge 0$ and sum. $\square$

**Theorem 4.3 (Cross-section bound).** For disjoint boundary regions $A$ and $B$,
$$
I(A:B) \;\le\; 2\,E(A,B).
$$

*Proof sketch.* Choose a minimal separating surface $\sigma$ for the pair $(A,B)$, so
$\operatorname{area}(\sigma) = E(A,B)$, and a minimal surface $g$ for the region $A \cup B$, so
$\operatorname{area}(g) = S(A\cup B)$. The two halves of $g$ cut by $\sigma$ are admissible for $A$ and
$B$ respectively: on a boundary cell $v$, $g(v) = A(v) \vee B(v)$, while $\sigma(v) = \textsf{true}$
if $A(v)=\textsf{true}$ and $\sigma(v)=\textsf{false}$ if $B(v) = \textsf{true}$; checking the three possible cases
gives $(\sigma \wedge g)(v) = A(v)$ and $(\neg\sigma \wedge g)(v) = B(v)$. Hence, by
minimality of $S$,
$$
S(A) + S(B) \;\le\; \operatorname{area}(\sigma \wedge g) + \operatorname{area}(\neg \sigma \wedge g)
\;\le\; \operatorname{area}(g) + 2\operatorname{area}(\sigma) \;=\; S(A\cup B) + 2E(A,B),
$$
using Proposition 4.2 in the middle. Rearranging is the claim. $\square$

**Theorem 4.4 (The ER = EPR sandwich).** Let $A$ and $B$ be disjoint boundary regions.
Then
$$
\tfrac12\, I(A:B) \;\le\; E(A,B) \;\le\; \min\bigl(S(A),\, S(B)\bigr).
$$

*Proof sketch.* The left inequality is Theorem 4.3. For the right one, let $f$ be a
minimal surface for $A$. Since $f$ agrees with $A$ on the boundary and $A,B$ are disjoint
boundary regions, $f$ contains $A$ and misses $B$, i.e. $f$ separates $A$ from $B$; hence
$E(A,B) \le \operatorname{area}(f) = S(A)$. Symmetry of $E$ gives the same with $B$. $\square$

So the bridge cross-section is squeezed between half the mutual information of its two
mouths and the entropy of either mouth.

**Theorem 4.5 (ER = EPR, quantitative form).** Let $u \ne v$ be boundary cells with
$I(u:v) > 0$. Then
$$
E(u,v) \;\ge\; \tfrac12 I(u:v) \;>\; 0,
$$
and consequently $u \rightsquigarrow v$: entangled cells are joined by an
Einstein–Rosen bridge whose cross-section is at least half their mutual information.

*Proof sketch.* Theorem 4.3 gives positivity of $E$; Theorem 3.6 converts positivity into
a bulk path. $\square$

**Theorem 4.6 (Sharpness).** In the elementary wormhole of Example 2.10,
$$
E(0,1) = w, \qquad I(0:1) = 2w = 2\,E(0,1).
$$
Hence Theorem 4.3 is an equality, and in Theorem 4.4 all three quantities equal $w$.

*Proof sketch.* The region $\{0\}$ separates $0$ from $1$ and has area $w$, so
$E \le w$; and $E \ge \tfrac12 I = w$ by Theorem 4.3. $\square$

---

## 5. Emergent spacetime is a tree

We now upgrade "there is a bridge" to "here is the distance".

**Definition 5.1 (Capacity kernel).** For cells $u,v$ put $\operatorname{cap}(u,v) = E(\{u\},\{v\})$.
It is symmetric, nonnegative, and positive exactly on connected pairs (Theorem 3.6).

**Theorem 5.2 (Gomory–Hu inequality).** For any cells $u \ne w$ and any third cell $v$,
$$
\min\bigl(\operatorname{cap}(u,v),\, \operatorname{cap}(v,w)\bigr) \;\le\; \operatorname{cap}(u,w).
$$

*Proof sketch.* Let $\sigma$ realise $\operatorname{cap}(u,w)$, so $\sigma(u)=\textsf{true}$, $\sigma(w)=\textsf{false}$,
$\operatorname{area}(\sigma) = \operatorname{cap}(u,w)$. The third cell lies on one of the two sides. If
$\sigma(v)=\textsf{true}$ then $\sigma$ separates $v$ from $w$, so $\operatorname{cap}(v,w) \le \operatorname{area}(\sigma)$; if
$\sigma(v)=\textsf{false}$ then $\sigma$ separates $u$ from $v$, so $\operatorname{cap}(u,v) \le \operatorname{area}(\sigma)$.
Either way the minimum of the two is at most $\operatorname{cap}(u,w)$. $\square$

The hypothesis $u \ne w$ is essential: $\operatorname{cap}(u,u) = 0$, since no surface can separate a
cell from itself, and the inequality fails for $u=w$ joined to $v$.

**Definition 5.3 (Emergent distance).** For cells $u,v$ set
$$
d(u,v) \;=\; \begin{cases} 0, & u = v,\\[2pt] e^{-\operatorname{cap}(u,v)}, & u \ne v.\end{cases}
$$
Wide bridges mean nearby points; the absence of a bridge means the maximal distance $1$.

**Theorem 5.4 (Emergent spacetime is an ultrametric space).** $d$ is a metric on $V$,
and it satisfies the strong triangle inequality
$$
d(u,w) \;\le\; \max\bigl(d(u,v),\, d(v,w)\bigr) \qquad \text{for all } u,v,w.
$$
In particular $0 \le d \le 1$, $d(u,v) = 0$ iff $u=v$, and $d$ is symmetric.

*Proof sketch.* Nonnegativity, symmetry and the vanishing-diagonal characterisation are
immediate since $e^{-t} > 0$ always and $\operatorname{cap}$ is symmetric and nonnegative. For the
strong triangle inequality, the degenerate cases $u = w$, $u = v$, $v = w$ are trivial.
Otherwise Theorem 5.2 says $\min(\operatorname{cap}(u,v),\operatorname{cap}(v,w)) \le \operatorname{cap}(u,w)$; applying the
order-reversing map $t \mapsto e^{-t}$ turns the minimum of capacities into the maximum of
distances and reverses the inequality. The ordinary triangle inequality follows since the
maximum of two nonnegative numbers is at most their sum. $\square$

Two remarks. First, ultrametricity is *strictly* stronger than the triangle inequality; it
is the hallmark of tree-like geometry (all triangles isosceles, balls nested or disjoint,
"being close" transitive). Second, the exponential is used only for being order-reversing
— any decreasing reparametrisation of $\operatorname{cap}$ works — but $e^{-t}$ has two extra virtues:
it normalises "no bridge" to distance exactly $1$, and it converts the additive bound
$I \le 2E$ into the multiplicative statement of Theorem 5.7.

**Theorem 5.5 (Zero hyperbolicity).** Every ultrametric space satisfies Gromov's
four-point condition with $\delta = 0$: for all points $x,y,z,t$,
$$
d(x,y) + d(z,t) \;\le\; \max\bigl(d(x,z)+d(y,t),\; d(x,t)+d(y,z)\bigr).
$$
In particular the emergent spacetime of any geometry is $0$-hyperbolic.

*Proof sketch.* Suppose both terms on the right are strictly smaller than the left. Apply
the strong triangle inequality four times: to $d(x,y)$ through $z$ and through $t$, and to
$d(z,t)$ through $x$ and through $y$. Each application offers two alternatives; in each
branch, the assumed strict inequalities eliminate one alternative, and the surviving four
bounds combine linearly into $d(x,y)+d(z,t) < d(x,y)+d(z,t)$, a contradiction. $\square$

Negative curvature is the geometric signature of anti-de Sitter space; $0$-hyperbolicity
is its extreme discrete form. The emergent spacetime of an entangled state is not merely
*some* metric space — it is as negatively curved as a metric space can be.

**Theorem 5.6 (Disentangling tears space apart).** For $u \ne v$,
$$
d(u,v) = 1 \iff \text{no bridge joins } u \text{ to } v,
\qquad
d(u,v) < 1 \iff u \rightsquigarrow v .
$$

*Proof sketch.* $e^{-\operatorname{cap}} = 1$ iff $\operatorname{cap} = 0$ iff (Theorem 3.6) there is no path. $\square$

**Theorem 5.7 (Distance decays exponentially in entanglement).** For distinct boundary
cells $u,v$ of a holographic model,
$$
d(u,v) \;\le\; e^{-I(u:v)/2}.
$$

*Proof sketch.* $\operatorname{cap}(u,v) \ge \tfrac12 I(u:v)$ by Theorem 4.3; apply $e^{-(\cdot)}$. $\square$

This is Van Raamsdonk's "distance is minus the logarithm of entanglement", as a theorem
with an explicit constant.

**Theorem 5.8 (Monotonicity).** If $w \le w'$ pointwise, then $d_{w'} \le d_{w}$
pointwise: adding entanglement can only bring the emergent spacetime closer together.

### 5.1 A hierarchy of scales

Ultrametricity has an immediate structural consequence with a physical reading.

**Theorem 5.9 (Entanglement clusters at every scale).** For each $r \ge 0$ the relation
$$
u \sim_r v \quad :\Longleftrightarrow \quad d(u,v) \le r
$$
is an equivalence relation on $V$. The induced partitions are monotone in $r$: if
$r \le s$ then $\sim_r$ refines $\sim_s$.

*Proof sketch.* Reflexivity is $d(u,u) = 0 \le r$; symmetry is symmetry of $d$;
transitivity is exactly the strong triangle inequality, $d(u,w) \le \max(d(u,v),d(v,w)) \le r$.
Transitivity is *false* for a general metric — this is a purely ultrametric phenomenon.
Monotonicity is trivial. $\square$

The resulting family of nested partitions is an emergent renormalisation hierarchy: at
scale $r$ the boundary degrees of freedom organise into clusters, and as $r$ decreases the
clusters refine. Two unconnected cells stay in different clusters at every scale $r<1$
(Theorem 5.6).

### 5.2 Reconstruction: entanglement determines the geometry

**Theorem 5.10 (The emergent metric is a function of the entanglement data).** Let $M$
and $N$ be holographic models on the same cell set, both without hidden bulk cells,
with equal two-point mutual informations:
$$
I_M(u:v) = I_N(u:v) \qquad \text{for all } u,v.
$$
Then $d_M = d_N$; the identity map is an isometry of the emergent metric spaces. In
particular the emergent metric space — with its ultrametric structure, its
$0$-hyperbolicity and its full hierarchy of clusters — is an invariant of the entanglement
structure alone.

*Proof sketch.* Without hidden bulk, $I(u:v) = 2w(u,v)$ for $u \ne v$ (Lemma 2.9 and its
consequence), so equality of mutual informations forces equality of all off-diagonal
weights. Areas of regions do not see the diagonal, hence all cut weights agree; hence the
minima defining $\operatorname{cap}$ agree; hence $d$ agrees. $\square$

This is the precise sense in which *spacetime is reconstructed from entanglement* in this
model: the table $\{I(u:v)\}$, a purely information-theoretic object, determines a metric
space and all of its geometry.

---

## 6. Monogamy: a wormhole has two mouths

Entanglement is monogamous: a maximally entangled pair cannot be entangled with anything
else. If ER = EPR is to be believed, monogamy must have a geometric face.

**Theorem 6.1 (The wormhole network is a tree).** Let $u,v,w$ be cells with $u \ne w$ and
$v \ne w$. If $\operatorname{cap}(u,w) < \operatorname{cap}(u,v)$, then $\operatorname{cap}(u,w) = \operatorname{cap}(v,w)$.

Equivalently: of the three capacities of a triple, the two smallest are always equal —
capacity triangles are isosceles, with the "odd" side the long one.

*Proof sketch.* Apply Theorem 5.2 twice, in the forms
$\min(\operatorname{cap}(u,v),\operatorname{cap}(v,w)) \le \operatorname{cap}(u,w)$ and $\min(\operatorname{cap}(u,v),\operatorname{cap}(u,w)) \le \operatorname{cap}(v,w)$
(using symmetry). The hypothesis $\operatorname{cap}(u,w) < \operatorname{cap}(u,v)$ makes the first minimum equal to
$\operatorname{cap}(v,w)$ in the relevant branch, giving $\operatorname{cap}(v,w) \le \operatorname{cap}(u,w)$, and the second
minimum equal to $\operatorname{cap}(u,w)$, giving $\operatorname{cap}(u,w) \le \operatorname{cap}(v,w)$. $\square$

This isosceles law is exactly the condition characterising the leaf metrics of weighted
trees, and it is the capacity-level shadow of Theorem 5.4.

**Theorem 6.2 (Monogamy of Einstein–Rosen bridges).** Let $M$ be a holographic model
without hidden bulk cells and let $u \ne v$ be cells whose mutual information saturates
the entropy bound:
$$
I(u:v) \;=\; 2\,S(\{u\}).
$$
Then for every cell $z \notin \{u,v\}$ we have $w(u,z) = 0$ and $I(u:z) = 0$: the cell $u$
has no bridge other than the one to $v$. A wormhole has exactly two mouths.

*Proof sketch.* Without hidden bulk, $S(\{u\}) = \sum_{y \ne u} w(u,y)$ (Lemma 2.9) and
$I(u:v) = 2w(u,v)$. Saturation therefore reads
$$
2\,w(u,v) \;=\; 2\Bigl(w(u,v) + \sum_{y \ne u,v} w(u,y)\Bigr),
\qquad\text{i.e.}\qquad \sum_{y \ne u,v} w(u,y) = 0 .
$$
Since all weights are nonnegative, every term vanishes; in particular $w(u,z)=0$, and then
$I(u:z) = 2w(u,z) = 0$. $\square$

The positivity of areas is precisely where physics enters this argument. Note that the
no-hidden-bulk hypothesis is not cosmetic: with hidden cells $S(\{u\})$ is a genuine
min-cut and can be strictly smaller than the sum of incident weights, so saturation no
longer forces the edges to vanish.

**Corollary 6.3 (Geometric monogamy).** Under the hypotheses of Theorem 6.2, $v$ is the
*unique* neighbour of $u$ in the emergent geometry: if $w(u,z) > 0$ and $z \ne u$ then
$z = v$.

### 6.1 The lattice of minimal surfaces and wedge nesting

**Theorem 6.4 (Minimal surfaces form a lattice).** If $f$ and $g$ are both minimal
surfaces for the same boundary region $A$, then so are $f \wedge g$ and $f \vee g$.

*Proof sketch.* Both $f\wedge g$ and $f\vee g$ are admissible for $A$ (they agree with
$A$ on the boundary because $f$ and $g$ do), so both areas are $\ge S(A)$. Submodularity
gives $\operatorname{area}(f\wedge g) + \operatorname{area}(f\vee g) \le \operatorname{area}(f)+\operatorname{area}(g) = 2S(A)$. Two numbers each
at least $S(A)$ summing to at most $2S(A)$ must both equal $S(A)$. $\square$

**Theorem 6.5 (Entanglement wedge nesting).** Let $A \subseteq B$ be boundary regions.
Then one may choose minimal surfaces $f$ for $A$ and $g$ for $B$ with $f \subseteq g$: the
entanglement wedge of $A$ sits inside that of $B$.

*Proof sketch.* Take any minimal surfaces $f_0$ for $A$ and $g_0$ for $B$. Because
$A \subseteq B$ on the boundary, $f_0 \wedge g_0$ is admissible for $A$ and $f_0 \vee g_0$
is admissible for $B$. Their areas are therefore at least $S(A)$ and $S(B)$ respectively,
while submodularity bounds their sum by $S(A)+S(B)$; hence both are minimal. And
$f_0 \wedge g_0 \subseteq f_0 \vee g_0$. $\square$

Wedge nesting is the consistency condition underlying subregion duality: information
accessible from a smaller region must be accessible from a larger one.

---

## 7. Bit threads: flowing through the bridge

The Ryu–Takayanagi prescription measures entanglement by *cutting* the bulk. There is a
dual picture that measures it by *flowing* through the bulk: entanglement is the maximum
number of Planck-thickness threads that can be routed from one boundary region to the
other. Here is the combinatorial version.

**Definition 7.1 (Bit thread configuration).** A *bit thread configuration* on a geometry
$w$ is a function $\phi : V \times V \to \mathbb{R}$ that is

- **antisymmetric**: $\phi(x,y) = -\phi(y,x)$ for all $x,y$ (threads are oriented), and
- **capacity-respecting**: $\phi(x,y) \le w(x,y)$ for all $x,y$ (no more threads may cross
  a surface element than its area).

Since $w$ is symmetric, antisymmetry upgrades the one-sided capacity bound to
$|\phi(x,y)| \le w(x,y)$, so nothing is lost by stating it one-sidedly.

**Definition 7.2 (Divergence, conservation, value).** The *divergence* at a cell is
$\operatorname{div}\phi(x) = \sum_{y} \phi(x,y)$. The configuration is *conserved* relative to a source
region $A$ and a sink region $B$ if $\operatorname{div}\phi(v) = 0$ for every cell $v$ outside
$A \cup B$. Its *value* is the total flux emitted by the source,
$$
\operatorname{val}(\phi) \;=\; \sum_{x \in A} \operatorname{div}\phi(x).
$$

**Lemma 7.3 (Antisymmetric kernels vanish on squares).** If $\phi$ is antisymmetric, then
for every subset $S \subseteq V$,
$$
\sum_{x \in S}\sum_{y \in S} \phi(x,y) \;=\; 0 .
$$

*Proof sketch.* Swapping the two summation indices and using antisymmetry shows the sum
equals its own negative. $\square$

**Theorem 7.4 (Weak duality).** Let $\phi$ be a bit thread configuration conserved
relative to $(A,B)$, and let $\sigma$ be *any* region separating $A$ from $B$. Then
$$
\operatorname{val}(\phi) \;\le\; \operatorname{area}(\sigma).
$$

*Proof sketch.* Three steps.

1. *Enlarge the source to $\sigma$.* Every cell of $\sigma$ that is not in $A$ is also not
   in $B$ (since $\sigma$ misses $B$), so its divergence vanishes by conservation. Hence
   $\operatorname{val}(\phi) = \sum_{x\in A}\operatorname{div}\phi(x) = \sum_{x \in \sigma}\operatorname{div}\phi(x)$.
2. *Cancel the interior.* Split each divergence as a sum over $\sigma$ and a sum over its
   complement: $\operatorname{div}\phi(x) = \sum_{y\in\sigma}\phi(x,y) + \sum_{y\notin\sigma}\phi(x,y)$.
   Summing over $x \in \sigma$, the first double sum vanishes by Lemma 7.3, leaving
   $\sum_{x\in\sigma}\sum_{y\notin\sigma}\phi(x,y)$: only the flux through the boundary of
   $\sigma$ survives.
3. *Apply capacities.* Termwise, $\phi(x,y) \le w(x,y)$, so this is at most
   $\sum_{x\in\sigma}\sum_{y\notin\sigma} w(x,y)$, which is exactly $\operatorname{area}(\sigma)$ by
   Lemma 2.3. $\square$

**Corollary 7.5 (Threads cannot outrun the bridge).** For disjoint $A$ and $B$, every
conserved configuration satisfies $\operatorname{val}(\phi) \le E(A,B)$.

**Theorem 7.6 (Max-flow = min-cut for a single Einstein–Rosen bridge).** In the elementary
wormhole of weight $w$ (Example 2.10), the configuration
$$
\phi(0,1) = w, \qquad \phi(1,0) = -w, \qquad \phi(x,x) = 0
$$
is a conserved bit thread configuration with source $\{0\}$ and sink $\{1\}$, and
$$
\operatorname{val}(\phi) \;=\; w \;=\; E(0,1) \;=\; \tfrac12 I(0:1),
$$
and no conserved configuration has larger value. The weak duality bound of Theorem 7.4 is
therefore attained.

*Proof sketch.* Antisymmetry and capacity are immediate; conservation is vacuous (there
are no cells outside source and sink). The value is $\operatorname{div}\phi(0) = \phi(0,0)+\phi(0,1) = w$.
Optimality is Corollary 7.5 together with $E(0,1) = w$ from Theorem 4.6, and the final
equality is $I(0:1) = 2w$. $\square$

The general converse — existence of a saturating flow for every geometry and every pair of
regions — is a max-flow–min-cut theorem and is stated as an open direction in §10. Note
that the proof of Theorem 7.4 uses neither finiteness (beyond summability) nor symmetry of
the weights except through Lemma 2.3.

The physical reading is worth stating plainly: entanglement is not merely *measured* by
the bridge cross-section, it is *transportable* through it. The threads are a concrete
picture of *where in the bulk the entanglement lives*.

---

## 8. A renormalisation flow on emergent spacetime

Coarse-graining a quantum state should coarse-grain its emergent geometry. Here is the
operation, and here is what it does.

**Definition 8.1 (Pushforward geometry).** Let $\pi : V \to W$ be any map of finite cell
sets, and write $\pi^{-1}(a)$ for the fibre over $a \in W$. The *pushforward* of a geometry
$w$ on $V$ is the geometry on $W$ given by
$$
(\pi_* w)(a,b) \;=\; \begin{cases} 0, & a = b,\\[2pt]
\displaystyle\sum_{x \in \pi^{-1}(a)}\ \sum_{y \in \pi^{-1}(b)} w(x,y), & a \ne b. \end{cases}
$$
Cells in a common fibre are merged; the area joining two coarse cells is the total area
joining their fibres.

**Theorem 8.2 (Coarse surfaces are invariant fine surfaces of equal area).** For every
region $\sigma$ of $W$,
$$
\operatorname{area}_{\pi_* w}(\sigma) \;=\; \operatorname{area}_{w}(\sigma \circ \pi).
$$

*Proof sketch.* Expand both sides as double sums. On the coarse side, group the terms of
the fine sum according to which fibres their endpoints lie in; the diagonal correction
$a=b$ costs nothing because within a single fibre $\sigma\circ\pi$ is constant, so the
separation indicator vanishes there anyway. $\square$

This identity is the engine of everything below. It says every coarse surface *pulls back*
to a fine surface of the same area — but not conversely: the fine surfaces that *split a
fibre* have no coarse counterpart. The whole renormalisation flow is this asymmetry.

**Theorem 8.3 (Functoriality).** For $\pi : V \to W$ and $\rho : W \to X$,
$\rho_*(\pi_* w) = (\rho\circ\pi)_* w$ as geometries, not merely as cut functions.

*Proof sketch.* Both weights at $(c,d)$ with $c \ne d$ equal
$\sum_{x \in (\rho\pi)^{-1}(c)} \sum_{y \in (\rho\pi)^{-1}(d)} w(x,y)$, after regrouping the
fibres of $\pi$ inside the fibres of $\rho$. The point requiring care is that for $c \ne d$
the fibres $\rho^{-1}(c)$ and $\rho^{-1}(d)$ are disjoint, so the diagonal correction in
Definition 8.1 is never triggered — which is exactly why the composite is an equality
rather than an inequality. $\square$

**Theorem 8.4 (Coarse-graining widens throats).** For any $\pi$ and disjoint coarse
regions $A,B$ of $W$,
$$
E_{w}\bigl(A\circ\pi,\, B\circ\pi\bigr) \;\le\; E_{\pi_* w}(A,B).
$$
In particular, for cells $u,v$ with $\pi u \ne \pi v$,
$\operatorname{cap}_w(u,v) \le \operatorname{cap}_{\pi_* w}(\pi u, \pi v)$.

*Proof sketch.* A minimal coarse separating surface pulls back, by Theorem 8.2, to a fine
separating surface of the same area; the fine minimisation ranges over a *larger* family
of competitors. $\square$

**Theorem 8.5 (Coarse-graining is a metric contraction).** For all cells $u,v$,
$$
d_{\pi_*w}(\pi u, \pi v) \;\le\; d_w(u,v),
$$
i.e. $\pi$ is a $1$-Lipschitz map from the emergent ultrametric space of $w$ to that of
$\pi_* w$.

*Proof sketch.* If $\pi u = \pi v$ the left side is $0$. Otherwise apply the
order-reversing $e^{-(\cdot)}$ to Theorem 8.4. $\square$

**Theorem 8.6 (Coarse-graining cannot decrease entropy).** For a holographic model in
which a coarse cell is a boundary cell as soon as one of the cells it absorbs is, and for
every coarse boundary region $A$,
$$
S_w(A \circ \pi) \;\le\; S_{\pi_* w}(A).
$$

*Proof sketch.* Same mechanism: a minimal coarse surface pulls back to an admissible fine
surface of equal area. $\square$

**Theorem 8.7 (Rigidity).** If some minimal $u$–$v$ separating surface of $w$ is constant
on the fibres of $\pi$ — that is, if it is pulled back from a coarse surface $\tau$ with
$\tau(\pi u) = \textsf{true}$, $\tau(\pi v) = \textsf{false}$ — then
$\operatorname{cap}_{\pi_* w}(\pi u, \pi v) = \operatorname{cap}_w(u,v)$: nothing moves. The analogous statement holds
for entropies.

Together with the next example, Theorem 8.7 isolates the exact mechanism of the
renormalisation jump: **only surfaces that split a fibre can be lost.**

**Theorem 8.8 (The contraction is strict).** Consider four cells arranged in a path
$0 - 1 - 2 - 3$ with areas
$$
w(0,1) = 5,\qquad w(1,2) = 1, \qquad w(2,3) = 5,
$$
and all other weights $0$; and let $\pi$ merge the two waist cells $1$ and $2$. Then
$$
\operatorname{cap}_w(0,3) \le 1, \qquad \operatorname{cap}_{\pi_* w}(\pi 0, \pi 3) = 5,
$$
so $d_{\pi_* w}(\pi 0, \pi 3) < d_w(0,3)$ strictly.

*Proof sketch.* Upper bound: the region $\{0,1\}$ separates $0$ from $3$ and its bounding
surface consists of the single waist edge, of area $1$. Lower bound after merging: the
coarse geometry is a three-cell path with both edges of area $5$ (the two heavy edges
survive; the waist becomes an internal, hence invisible, edge inside the merged cell), so
*every* coarse surface separating the two ends cuts exactly one heavy edge, of area $5$.
Exhausting the two possible positions of the middle cell gives the exact value $5$. $\square$

The thin waist was the cheap surface, and merging destroyed it. That is the renormalisation
group of the model: as one coarse-grains, the emergent space contracts, and it contracts
discontinuously exactly when the surfaces that were doing the work get absorbed.

---

## 9. Worked example: the emergent space of $n$ Bell pairs

Let $V = \{1,\dots,n\} \times \{0,1\}$: two cells $(i,0),(i,1)$ for each of $n$ Bell pairs,
all on the boundary, with
$$
w\bigl((i,b),(j,c)\bigr) \;=\; \begin{cases} w_i, & i = j \text{ and } b \ne c, \\ 0, & \text{otherwise},\end{cases}
\qquad w_i \ge 0 .
$$
This is the *matching geometry*: $n$ independent throats and nothing else.

**Theorem 9.1.** For all $i,j,b,c$:

1. $\operatorname{area}(\{(i,b)\}) = w_i$;
2. $\operatorname{cap}\bigl((i,b),(i,\bar b)\bigr) = w_i$ — the throat capacity of a partner pair is
   exactly its Bell weight;
3. $\operatorname{cap}\bigl((i,b),(j,c)\bigr) = 0$ for $i \ne j$ — no bridge joins different pairs;
4. $d\bigl((i,b),(i,\bar b)\bigr) = e^{-w_i}$ and $d\bigl((i,b),(j,c)\bigr) = 1$ for $i\ne j$;
5. $w_i > 0$ if and only if the two mouths of pair $i$ are at distance strictly less
   than $1$.

*Proof sketch.* (1) is Lemma 2.9: only the partner edge is nonzero. (2) has an upper bound
from the surface around a single cell, of area $w_i$ by (1), and a lower bound for free
from Theorem 4.3 applied to $I\bigl((i,b):(i,\bar b)\bigr) = 2w_i$. (3) holds because no
bulk path leaves a pair, so Theorem 3.6 forces the capacity to vanish. (4) and (5) are
immediate from the definition of $d$. $\square$

This is the sharpest possible instance of the ER = EPR sandwich (Theorem 4.4): all three of
$\tfrac12 I$, $E$, and $\min(S,S)$ equal $w_i$.

**Theorem 9.2 (The clusters are exactly the Bell pairs).** Let $r$ satisfy
$$
\max_i e^{-w_i} \;\le\; r \;<\; 1 .
$$
Then two cells lie in the same cluster of the emergent ultrametric at scale $r$ if and only
if they belong to the same Bell pair.

*Proof sketch.* Across pairs the distance is $1 > r$, so distinct pairs are never merged;
inside a pair the distance is $e^{-w_i} \le r$, so every pair is a single cluster. $\square$

Both hypotheses on $r$ are needed: without $r < 1$ distinct pairs would merge, and without
$e^{-w_i} \le r$ a pair with a thin throat would already be split. Within this window, the
emergent space of $n$ Bell pairs consists of exactly $n$ microscopic Einstein–Rosen bridges
and nothing else — a shattered spacetime whose only connectivity is entanglement.

---

## 10. Discussion and future directions

### 10.1 What the model shows

Reading the results as a single statement: *given the two-point entanglement data of a
holographic state with no hidden bulk, one can reconstruct a metric space; that space is
ultrametric, hence $0$-hyperbolic; distances decay exponentially in mutual information;
positive mutual information is equivalent to bulk connectivity; the bridge cross-section is
sandwiched between half the mutual information and the entropies of the mouths, with
equality for a single throat; maximal entanglement forces a bridge with exactly two mouths;
entanglement can be transported through the bridge as a flow whose maximal value is at
most the cross-section, with equality for a single throat; and coarse-graining contracts
this geometry $1$-Lipschitzly and functorially, strictly so whenever it absorbs the
surfaces that were carrying the min-cut.*

That is a considerable amount of ER = EPR, made precise and true. It is also, honestly, a
toy: the model has no dynamics, no time, no Einstein equations, and its "areas" are
combinatorial inputs rather than solutions of anything. What it isolates is the *purely
kinematic* content of the correspondence — the part that follows from the min-cut structure
alone. The fact that this part already yields negative curvature, monogamy, a
renormalisation flow, and a reconstruction theorem is the interesting news.

### 10.2 Algorithms

All quantities defined here are computable. For $|V| = n$ cells:

- **Area of a region**: $O(n^2)$ from the definition.
- **Throat capacity $E(A,B)$**: a minimum $s$–$t$ cut in an undirected weighted graph,
  computable in polynomial time by standard max-flow algorithms; the brute-force
  enumeration over $2^n$ regions is used for verification on small examples.
- **Entropy $S(A)$**: a minimum cut with the boundary values *fixed* — that is, an $s$–$t$
  min-cut in the graph obtained by contracting $A$ to a source and its boundary complement
  to a sink, the hidden cells remaining free. Also polynomial.
- **The whole capacity table $\{\operatorname{cap}(u,v)\}$**: $\binom{n}{2}$ min-cuts naively, or $n-1$
  min-cuts via a Gomory–Hu tree, whose existence is guaranteed by Theorem 5.2.
- **The cluster hierarchy**: single-linkage clustering on the capacity table, equivalently
  the dendrogram of the ultrametric $d$.
- **Bit threads**: a maximum flow; Theorem 7.4 says its value is a certificate bounded by
  any cut, and Theorem 7.6 verifies equality for the elementary wormhole.

### 10.3 Future directions

**C1. Strong duality: bit threads realise every Ryu–Takayanagi area.** For every finite
geometry $G$ and disjoint boundary regions $A$, $B$ there should exist a conserved thread
configuration $T$ with $\operatorname{val}(T) = E(A,B)$; consequently max-flow $=$ min-cut, and the
Ryu–Takayanagi entropy of any region is the maximal flux of a bit-thread configuration out
of it. The key insight is that the weak duality proved here uses only antisymmetry plus
capacity, so the missing half is precisely a constructive augmenting-path argument, which
on a finite weighted graph terminates because the set of achievable fluxes is a polytope
with rational vertices whenever the areas are rational. Why now? The cut side of the toy
dictionary is complete (subadditivity, strong subadditivity, monogamy, cyclic
inequalities, nesting), and the elementary wormhole case is already verified; a general
max-flow–min-cut theorem would immediately convert every entropy inequality proved by
surface recombination into a statement about threads — that is, about *where the
entanglement lives*.

**C2. Every finite ultrametric emergent geometry is a tensor-network tree.** For every
geometry $G$ there should be a weighted tree $T$ whose leaves are the cells of $G$ and
whose induced leaf metric is exactly the emergent distance; moreover $T$ can be taken to be
the Gomory–Hu tree of $G$, with at most $|V| - 1$ internal edges. The key insight is that
the emergent distance was proved to be an ultrametric and $0$-hyperbolic, and finite
ultrametric spaces are exactly the leaf metrics of weighted rooted trees; the capacity
hierarchy at varying scales already produces the laminar family of clusters that such a
tree must have. Why now? This would formalise the folklore that holographic states are
*tensor-network* states: the emergent bulk is not just some metric space, it is literally a
tree of contractions, and the tree is computable from two-point mutual informations alone.

**C3. A sharp entanglement-wedge cross-section law.** In every geometry without hidden bulk
cells, $E(A,B)$ should equal the maximum over bipartitions of the "one-sided" mutual
information, and in particular the bound $I(A:B) \le 2E(A,B)$ should be saturated **if and
only if** every minimal $A$–$B$ separating surface is homologous to $A \cup B$ —
equivalently, if and only if the bulk between $A$ and $B$ is a single throat. The key
insight is that the proof of the cross-section bound loses exactly one inequality — the
step in which the two halves of the minimal $A\cup B$ surface are compared with the true
minimal surfaces of $A$ and of $B$ — and controlling that step is precisely a homology
condition.

**C4. Coarse-graining is a metric contraction.** *(Closed in this cycle: Theorems 8.5 and
8.8 establish the $1$-Lipschitz contraction, its functoriality, its rigidity criterion, and
the strictness of the contraction in general.)* The remaining question is quantitative:
bound the jump $\operatorname{cap}_{\pi_*w} - \operatorname{cap}_w$ in terms of the total area of the fibre-splitting
surfaces destroyed by $\pi$.

**C5. Dynamics.** Everything here is kinematics on a fixed spatial slice. The natural next
object is a *sequence* of geometries — a discrete time evolution — with an entropy
production law, and the question of whether the induced motion of the emergent ultrametric
space obeys a discrete analogue of the Einstein equations. A concrete first target: show
that a local rearrangement of entanglement that preserves all one-cell entropies moves the
emergent metric by a bounded amount, a discrete "first law of entanglement".

---

## 11. Conclusion

Starting from nothing but a finite weighted graph and a minimisation principle, we obtained
a metric space whose distances are exponentials of minus the entanglement, whose curvature
is as negative as it can be, whose connectivity is exactly the positivity of mutual
information, whose bridges obey monogamy, whose entanglement can be transported as a
conserved flow, and which contracts functorially under coarse-graining. Two entangled cells
really are joined by a bridge; the bridge really is wider when they are more entangled; and
severing the entanglement really does place them at maximal distance.

ER = EPR, in this arena, is not a slogan. It is a theorem — several of them.
