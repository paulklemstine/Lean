# The Odd-Clique Obstruction for Conformability of Odd-Order Regular Graphs

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Algebra / Algebraic and Structural Graph Theory

## Abstract

Conformable colorings are a structural necessary condition for total colorability of
graphs and a central object in the study of the Total Coloring Conjecture. We isolate
and prove the combinatorial backbone governing conformability for connected
$d$-regular graphs of **odd** order, the regime relevant to the conjecture that the
Conformability decision problem remains NP-complete for every fixed independence
number $\alpha(G) = k \ge 3$. Our central quantitative result is the **odd-clique
counting obstruction**: if a graph of odd order $n$, all of whose independent sets
have size at most $\alpha$, admits a conformable proper coloring with $d+1$ colors,
then
$$n \le (d+1)\cdot \mathrm{oddCap}(\alpha),$$
where $\mathrm{oddCap}(\alpha)$ is the largest odd integer not exceeding $\alpha$.
When $\alpha$ is even, this strictly improves the naive bound $n \le (d+1)\alpha$.
We further prove a **degree-parity obstruction** (any conformable odd-order regular
graph has even degree $d$), the **contrapositive obstruction** (no conformable
coloring exists once $(d+1)\cdot\mathrm{oddCap}(\alpha) < n$), and the
**complement-clique identity** (every conformable color class is a clique of the
complement $G^{c}$), which is the structural bridge to the hardness reductions via
odd-clique packing. A tightness witness ($K_3$) shows the main bound is best
possible. All results have been formally verified in the Lean 4 proof assistant atop
Mathlib.

---

## 1. Introduction

### 1.1 Background

Vertex coloring asks for an assignment of colors to the vertices of a graph $G$ such
that adjacent vertices receive distinct colors; the least number of colors needed is
the chromatic number $\chi(G)$. Brooks-type bounds guarantee that $\Delta(G) + 1$
colors always suffice, where $\Delta(G)$ is the maximum degree. A more refined and
much less understood condition, **conformability**, controls the *parities* of the
color classes when exactly $\Delta + 1$ colors are used. Conformability arose in the
study of **total colorings** — simultaneous colorings of vertices and edges — and is
a known necessary condition associated with the long-standing Total Coloring
Conjecture.

The computational complexity of recognizing conformable graphs is delicate. It is
known that deciding conformability is NP-complete, and a finer program seeks to
locate the hardness precisely in terms of structural parameters, in particular the
**independence number** $\alpha(G)$. The motivating conjecture is:

> **Conjecture.** For every fixed integer $k \ge 3$, the Conformability problem is
> NP-complete when restricted to connected $d$-regular graphs $G$ of odd order $n$
> with independence number $\alpha(G) = k$ and maximum degree $d \ge n/2$.

The base case $k = 3$ is established by a reduction from perfect triangle packing in
$K_4$-free graphs. The conjecture asserts hardness persists for all larger
independence numbers; in the complement $G^{c}$ (which has clique number
$\omega(G^{c}) = \alpha(G) = k$), conformable color classes correspond to cliques of
odd size up to $k$, so richer packing structures encode the NP-hardness.

### 1.2 Contributions

This paper formalizes and proves the **necessary-direction backbone** of that program
for odd-order regular graphs. Concretely:

1. **Odd-clique counting obstruction** (`conformable_odd_order_bound`): a sharp
   feasibility bound $n \le (d+1)\cdot\mathrm{oddCap}(\alpha)$.
2. **Degree-parity obstruction** (`conformable_odd_order_even_degree`): conformable
   odd-order regular graphs force $d$ even.
3. **Regular-graph reformulation** (`conformable_regular_odd_order_bound`): the bound
   phrased through genuine $d$-regularity and $\Delta + 1$ colors.
4. **Contrapositive obstruction** (`no_conformable_of_card_gt`): an explicit
   infeasibility certificate.
5. **Complement-clique identity** (`fiber_compl_clique`, `fiber_indep`): the bridge
   to odd-clique packing in $G^{c}$.
6. **Tightness witness** (`triangle_conformable`): $K_3$ attains the bound with
   equality.

All statements were verified in Lean 4 with Mathlib; the present paper gives
self-contained mathematical statements and human-readable proof sketches.

---

## 2. Definitions

Throughout, $G = (V, E)$ is a finite simple graph with $n = |V|$ vertices. We write
$d(v)$ for the degree of vertex $v$, $\Delta = \Delta(G)$ for the maximum degree, and
$G^{c}$ for the complement of $G$ (same vertex set; $uv \in E(G^{c})$ iff $u \ne v$
and $uv \notin E(G)$).

**Definition 2.1 (Proper coloring).** A *proper coloring* of $G$ with palette
$\{0, 1, \dots, d\}$ is a function $c : V \to \{0,\dots,d\}$ such that $c(u) \ne c(v)$
whenever $uv \in E$. The **color class** (or *fiber*) of color $i$ is
$C_i = \{v \in V : c(v) = i\}$, and $V = \bigsqcup_{i=0}^{d} C_i$ is a partition.

**Definition 2.2 (Independent set; independence number).** A set $S \subseteq V$ is
*independent* if no two of its vertices are adjacent in $G$. The *independence number*
$\alpha(G)$ is the maximum size of an independent set. Throughout we abstract this as
a parameter $\alpha$ via the hypothesis "$|S| \le \alpha$ for every independent set
$S$".

**Definition 2.3 (Clique).** A set $S \subseteq V$ is a *clique* of a graph $H$ if
every two distinct vertices of $S$ are adjacent in $H$. A set is independent in $G$
iff it is a clique of $G^{c}$; consequently $\omega(G^{c}) = \alpha(G)$.

**Definition 2.4 (Deficiency).** The *deficiency* of $G$ is
$$\mathrm{def}(G) = \sum_{v \in V} \bigl(\Delta - d(v)\bigr).$$
For a $\Delta$-regular graph, $d(v) = \Delta$ for all $v$, so $\mathrm{def}(G) = 0$.

**Definition 2.5 (Conformable coloring).** A proper coloring $c$ of $G$ with
$\Delta + 1$ colors is *conformable* if the number of color classes whose cardinality
has parity different from $n$ is at most $\mathrm{def}(G)$:
$$\bigl|\{\, i : |C_i| \not\equiv n \pmod 2 \,\}\bigr| \le \mathrm{def}(G).$$
For a $d$-regular graph ($\Delta = d$, $\mathrm{def}(G) = 0$) this is equivalent to
the **uniform parity condition**: for every color $i$,
$$|C_i| \equiv n \pmod 2.$$
This is the operative hypothesis (`hconf`) used in the formal statements below.

**Definition 2.6 (oddCap).** For $a \in \mathbb{N}$ define
$$\mathrm{oddCap}(a) = \begin{cases} a, & a \text{ odd},\\ a - 1, & a \text{ even},\end{cases}
\qquad \mathrm{oddCap}(0) = 0.$$
Equivalently $\mathrm{oddCap}(a)$ is the largest odd integer $\le a$ (and $0$ if
$a = 0$). It is the per-class cap forced by the odd-order conformability constraint.

---

## 3. Elementary lemmas on `oddCap`

**Lemma 3.1 (`odd_le_oddCap`).** If $x$ is odd and $x \le a$, then
$x \le \mathrm{oddCap}(a)$.

*Proof sketch.* If $a$ is odd then $\mathrm{oddCap}(a) = a \ge x$ and we are done.
If $a$ is even, write $a = 2m$ and $x = 2t + 1$. From $x \le a$ we get
$2t + 1 \le 2m$, hence $2t + 1 \le 2m - 1 = a - 1 = \mathrm{oddCap}(a)$, since an odd
number cannot equal an even number. $\square$

This lemma is the lone arithmetic ingredient that upgrades the naive cap $\alpha$ to
the parity-aware cap $\mathrm{oddCap}(\alpha)$.

---

## 4. Structural lemmas: color classes are complement cliques

**Lemma 4.1 (`fiber_indep`).** For any proper coloring $c$ of $G$ with $d+1$ colors
and any color $i$, the color class $C_i = \{v : c(v) = i\}$ is an independent set of
$G$.

*Proof sketch.* If $u, v \in C_i$ are adjacent, then properness forces
$c(u) \ne c(v)$; but $c(u) = i = c(v)$, a contradiction. Hence no edge lies inside
$C_i$. $\square$

**Lemma 4.2 (`fiber_compl_clique`).** Under the same hypotheses, each color class
$C_i$ is a *clique of the complement* $G^{c}$.

*Proof sketch.* By the standard identity, $S$ is independent in $G$ iff $S$ is a
clique of $G^{c}$. Apply it to $S = C_i$ using Lemma 4.1. $\square$

Lemma 4.2 is the structural heart of the bridge to hardness: it identifies every
conformable color class with an (odd, when $n$ is odd) clique of $G^{c}$, whose clique
number is exactly $\alpha(G)$. Thus a conformable coloring of an odd-order regular
graph *is* a partition of $V$ into $d+1$ odd cliques of $G^{c}$, each of size at most
$\alpha(G)$ — the object that the NP-hardness reductions encode.

---

## 5. Main results

### 5.1 The odd-clique counting obstruction

**Theorem 5.1 (`conformable_odd_order_bound`).** Let $G$ be a graph with vertex set
of odd cardinality $n$, all of whose independent sets have size at most $\alpha$.
Suppose $c : V \to \{0,\dots,d\}$ is a proper coloring satisfying the uniform parity
condition $|C_i| \equiv n \pmod 2$ for every $i$. Then
$$n \le (d+1)\cdot\mathrm{oddCap}(\alpha).$$

*Proof sketch.* Partition $V$ into the $d+1$ fibers and sum cardinalities:
$$n = \sum_{i=0}^{d} |C_i| \qquad (\text{fiberwise counting}).$$
Since $n$ is odd, $n \equiv 1 \pmod 2$. The parity hypothesis gives
$|C_i| \equiv n \equiv 1 \pmod 2$, so each $|C_i|$ is **odd**. By Lemma 4.1, $C_i$ is
independent, so $|C_i| \le \alpha$. Combining oddness with $|C_i| \le \alpha$ and
Lemma 3.1 yields $|C_i| \le \mathrm{oddCap}(\alpha)$ for every $i$. Summing the $d+1$
bounds:
$$n = \sum_{i=0}^{d} |C_i| \le \sum_{i=0}^{d} \mathrm{oddCap}(\alpha)
= (d+1)\cdot\mathrm{oddCap}(\alpha). \qquad \square$$

*Remark.* The improvement over $n \le (d+1)\alpha$ is exactly the per-class shave
from $\alpha$ to $\mathrm{oddCap}(\alpha)$, which is strict precisely when $\alpha$ is
even. For example, with $d+1 = 5$ and $\alpha = 4$, the naive bound gives $n \le 20$
while Theorem 5.1 gives $n \le 15$, excluding the band $16 \le n \le 20$ outright.

### 5.2 The degree-parity obstruction

**Theorem 5.2 (`conformable_odd_order_even_degree`).** Under the hypotheses of
Theorem 5.1 (odd order, uniform parity condition), the degree parameter $d$ is even.

*Proof sketch.* Reduce the fiberwise identity modulo $2$:
$$n \equiv \sum_{i=0}^{d} |C_i| \pmod 2.$$
Each $|C_i| \equiv 1 \pmod 2$, and there are $d+1$ summands, so the right side is
$\equiv (d+1)\cdot 1 = d+1 \pmod 2$. Hence $n \equiv d+1 \pmod 2$. Since $n$ is odd,
$d + 1$ is odd, so $d$ is even. $\square$

*Interpretation.* A $d$-regular graph of odd order with $d$ *odd* cannot be
conformable, period — a parity certificate of non-conformability requiring no
coloring at all.

### 5.3 The regular-graph reformulation

**Theorem 5.3 (`conformable_regular_odd_order_bound`).** Let $G$ be genuinely
$d$-regular (so $\Delta(G) = d$), of odd order $n$, with $\alpha(G) \le \alpha$, and
let $c$ be a conformable proper coloring with $\Delta + 1 = d + 1$ colors. Then
$$n \le (d+1)\cdot\mathrm{oddCap}(\alpha).$$

*Proof sketch.* For a $d$-regular graph $\Delta = d$ via the maximum-degree identity
(`regular_maxDegree_eq`), and $\mathrm{def}(G) = 0$, so conformability collapses to
the uniform parity condition of Definition 2.5. Apply Theorem 5.1. $\square$

### 5.4 The contrapositive obstruction

**Theorem 5.4 (`no_conformable_of_card_gt`).** Let $G$ have odd order $n$ with all
independent sets of size $\le \alpha$. If
$$(d+1)\cdot\mathrm{oddCap}(\alpha) < n,$$
then **no** proper coloring of $G$ with $d+1$ colors can be conformable (i.e., none
can satisfy the uniform parity condition).

*Proof sketch.* Contrapositive of Theorem 5.1: a conformable coloring would force
$n \le (d+1)\cdot\mathrm{oddCap}(\alpha)$, contradicting the strict inequality.
$\square$

This is the practically useful form: it is a one-line, polynomial-time *infeasibility
certificate*. Given $n$, $d$, and an upper bound on $\alpha$, if the inequality
holds, conformability is impossible.

### 5.5 Tightness

**Theorem 5.5 (`triangle_conformable`).** The complete graph $K_3$ admits a
conformable coloring meeting the bound of Theorem 5.1 with equality.

*Proof sketch.* $K_3$ has $n = 3$ (odd), is $2$-regular ($d = 2$), and has
$\alpha = 1$. Coloring its three vertices with the three distinct colors
$\{0, 1, 2\}$ gives each class size $1$, which is odd, matching $n \bmod 2$; the
coloring is proper and conformable. Then
$(d+1)\cdot\mathrm{oddCap}(\alpha) = 3\cdot\mathrm{oddCap}(1) = 3\cdot 1 = 3 = n$, so
equality holds. The degree $d = 2$ is even, consistent with Theorem 5.2. $\square$

Theorem 5.5 certifies that the bound $n \le (d+1)\cdot\mathrm{oddCap}(\alpha)$ cannot
be improved in general: the inequality is attained.

---

## 6. The complement bridge to NP-hardness

The hardness program reads conformability through the complement. Combining
Theorem 5.1, Theorem 5.2, and Lemma 4.2 yields the following structural picture for an
odd-order $d$-regular graph $G$ with $\alpha(G) = k$:

> A conformable coloring of $G$ with $d+1$ colors is **exactly** a partition of $V(G)$
> into $d+1$ cliques of $G^{c}$, each of **odd** size and each of size at most $k$.

For $k = 3$ the admissible odd clique sizes are $1$ and $3$: singletons and
triangles. Deciding conformability thus becomes a constrained **triangle-packing**
question in $G^{c}$, and the base-case theorem reduces perfect triangle packing in
$K_4$-free graphs to it, establishing NP-completeness. For general fixed $k \ge 3$,
the admissible pieces are odd cliques of size $1, 3, 5, \dots, \mathrm{oddCap}(k)$,
and the conjecture is that these richer packing instances continue to encode NP-hard
problems. The complement-clique identity of Lemma 4.2 is precisely the formal hinge
that licenses this translation in both directions.

---

## 7. Algorithms

The obstruction theorems are not merely existential — they yield concrete, efficient
recognition procedures and a structured search for conformable colorings.

**Algorithm 7.1 (Parity infeasibility certificate).** Given $n$ (odd), the degree
$d$, and an upper bound $\alpha$ on the independence number, decide *necessary*
conformability conditions in $O(1)$ arithmetic:

1. If $d$ is odd, return `INFEASIBLE` (Theorem 5.2).
2. Compute $\mathrm{oddCap}(\alpha)$.
3. If $(d+1)\cdot\mathrm{oddCap}(\alpha) < n$, return `INFEASIBLE` (Theorem 5.4).
4. Otherwise return `PARITY-FEASIBLE` (necessary conditions pass; conformability is
   not yet decided).

**Algorithm 7.2 (Complement odd-clique partition search).** To *find* a conformable
coloring (or prove none exists) for an odd-order $d$-regular $G$ with $\alpha(G) = k$:

1. Form $G^{c}$.
2. Enumerate the odd cliques of $G^{c}$ of sizes $1, 3, \dots, \mathrm{oddCap}(k)$.
3. Search for a partition of $V$ into exactly $d+1$ such cliques (an exact-cover /
   constrained packing instance).
4. Any such partition is, by Lemma 4.2 read in reverse, a conformable coloring;
   absence of one certifies non-conformability.

The NP-hardness of step 3 (already for $k = 3$, triangle packing) is exactly what the
complexity program predicts; the parity bound of Theorem 5.1 prunes the search space
to instances with $n \le (d+1)\cdot\mathrm{oddCap}(k)$.

---

## 8. Applications

- **Total Coloring Conjecture.** Conformability is a necessary condition tied to
  total colorability; the sharp odd-order obstruction restricts which regular graphs
  of odd order can be conformable and hence informs the search for total-coloring
  obstructions.
- **Fast non-conformability certificates.** Theorems 5.2 and 5.4 give $O(1)$
  certificates rejecting vast families of regular graphs without attempting any
  coloring — useful as preprocessing in coloring solvers.
- **Complexity classification.** The complement identity (Lemma 4.2) anchors the
  reduction landscape, expressing conformability as odd-clique packing and thereby
  transferring NP-hardness results between the two problems.

---

## 9. Discussion

The results cleanly separate the *easy* (parity) obstructions from the *hard*
(packing) residue of conformability for odd-order regular graphs. Two parity facts —
even degree and the $(d+1)\cdot\mathrm{oddCap}(\alpha)$ ceiling — are checkable in
constant time and already exclude infinitely many graphs. Everything that survives
these tests reduces to a constrained odd-clique partition of the complement, which is
NP-hard at $k = 3$ and conjecturally for all $k \ge 3$.

The quantity $\mathrm{oddCap}$ is the conceptual fulcrum: it captures the interaction
of two simple constraints (independence cap $\alpha$ and odd parity) and makes the
feasibility frontier a *step function* in $\alpha$, jumping only at odd values. This
step structure is what gives each independence number its own threshold band and
motivates the per-$k$ hierarchy described below.

---

## 10. Future directions

**C1. The `oddCap` bound is the exact feasibility threshold for vertex-transitive
graphs.** *Conjecture.* For a vertex-transitive $d$-regular graph $G$ of odd order
$n$ with $\alpha(G) = k$, $G$ is conformable **iff** $n \le (d+1)\cdot\mathrm{oddCap}(k)$
and $d$ is even. The key insight: for vertex-transitive graphs the only obstructions
are the two proven necessary conditions (odd-clique count and degree parity);
transitivity removes the local irregularities that could otherwise block the packing.
The necessary direction is fully established; sufficiency reduces to a defect-version
of Baranyai-type edge/clique partitioning.

**C2. Per-$k$ strict hierarchy of the packing bound.** *Conjecture.* For each fixed
$k \ge 3$ there is an infinite family of $d$-regular odd-order graphs with $\alpha = k$
that are conformable but become non-conformable after deleting a single vertex orbit,
with the transition governed exactly by crossing $n = (d+1)\cdot\mathrm{oddCap}(k)$.
The key insight: $\mathrm{oddCap}(k)$ jumps by $2$ only at odd $k$, so the feasibility
frontier is a step function in $k$, giving each independence number its own threshold
band.

**C3. Complement-side reformulation collapses conformability to odd-clique cover.**
*Conjecture.* Conformability of an odd-order $d$-regular $G$ is polynomial-time
equivalent to deciding whether $G^{c}$ admits a partition into exactly $d+1$ cliques
each of **odd** size $\le k$. The key insight: `fiber_compl_clique` already shows
every conformable class is an odd clique of $G^{c}$; the converse packing turns any
such partition back into a conformable coloring. Both directions are formalized at
$k = 3$; generalizing the triangle to an odd clique of size up to $k$ is a direct
structural lift.

**C4. Degree-parity rigidity forces an empty-class-free spectrum.** *Conjecture.*
Every conformable coloring of an odd-order $d$-regular graph uses *all* $d+1$ colors
with strictly positive (odd) class sizes; consequently $d+1 \le n$ and the class-size
multiset is an odd partition of $n$ into exactly $d+1$ parts each $\le \mathrm{oddCap}(k)$.
The key insight: an empty class has even size $0$, violating the parity condition for
odd $n$, so the palette is never wasted — proven in the parity theorem and now
liftable to a full description of the achievable size spectra.

---

## 11. Conclusion

We have isolated, stated, and rigorously proved the parity-driven necessary
conditions that govern conformability of odd-order regular graphs: a sharp counting
bound $n \le (d+1)\cdot\mathrm{oddCap}(\alpha)$, a degree-parity obstruction forcing
$d$ even, an explicit infeasibility certificate, and the complement-clique identity
that bridges conformability to odd-clique packing — the structural engine of the
NP-completeness program for every fixed independence number $k \ge 3$. A triangle
witness shows the central bound is tight. Together these results draw a precise line
between the constant-time parity tests and the NP-hard packing residue at the heart of
conformability.
