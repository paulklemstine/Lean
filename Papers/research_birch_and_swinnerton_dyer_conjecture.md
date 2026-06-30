# A Sharp Turán–Caro–Wei Lower Bound on the Independence Number

## Abstract

We give a complete, self-contained development of the classical lower bound on
the independence number of a finite simple graph in terms of its order and size.
The central result states that every graph with $n$ vertices and $m$ edges
contains an independent set of size at least $n^2/(2m + n)$. We prove this via
the sharper vertex-weighted bound of Caro and Wei — that some independent set $S$
satisfies $\sum_{v} 1/(\deg(v)+1) \le |S|$ — combined with the handshake
identity $\sum_v \deg(v) = 2m$ and the arithmetic–harmonic mean inequality
(a corollary of Cauchy–Schwarz). We also examine, and refute, the frequently
cited bound $n^2/(4m)$: it is the output of the probabilistic deletion method but
is valid only when $n \le 2m$, failing dramatically for sparse graphs (for
$n = 100$, $m = 1$ it claims an independent set of $2500$ vertices in a
$100$-vertex graph). The bound $n^2/(2m+n)$ is always valid, never exceeds $n$,
coincides with Turán's extremal value on disjoint unions of equal cliques, and
strictly improves on $n^2/(4m)$ exactly in the regime where the latter is even
legal. We give precise statements, full proof sketches, an algorithmic
realization, numerical demonstrations, and a discussion of applications and
extensions.

**Keywords.** Independence number, Turán's theorem, Caro–Wei bound,
probabilistic method, handshake lemma, Cauchy–Schwarz inequality, extremal graph
theory.

---

## 1. Introduction

Let $G$ be a finite simple graph with vertex set $V$, $|V| = n$, and edge set of
cardinality $m$. A set $S \subseteq V$ is **independent** if no two of its
vertices are adjacent. The **independence number** $\alpha(G)$ is the maximum size
of an independent set. Computing $\alpha(G)$ exactly is NP-hard, but strong and
universally valid *lower* bounds — guarantees that a large independent set must
exist — are available and have been central to extremal and probabilistic graph
theory since the mid-twentieth century.

The cleanest such guarantee involves only the two coarsest graph invariants, the
order $n$ and the size $m$. Our main theorem is the following.

> **Theorem 1 (Turán / Caro–Wei bound).** Every finite simple graph with $n$
> vertices and $m$ edges satisfies
> $$\alpha(G) \;\ge\; \frac{n^2}{2m + n}.$$

This paper presents a complete derivation of Theorem 1 from first principles. The
argument factors into three independent and individually elementary components:

1. a **vertex-weighted refinement** (Theorem 2, Caro–Wei) producing an
   independent set whose size dominates $\sum_v 1/(\deg(v)+1)$;
2. the **handshake identity** $\sum_v \deg(v) = 2m$ (Lemma 5); and
3. the **arithmetic–harmonic mean inequality** $n^2/\sum_v f_v \le \sum_v 1/f_v$
   for positive $f_v$ (Lemma 6), a consequence of Cauchy–Schwarz.

A secondary contribution is a careful analysis of the widely quoted bound
$n^2/(4m)$. We show it is *false in general*, identify the precise source of the
error (a probability constraint violated in the sparse regime), and prove that
$n^2/(2m+n)$ is the correct universal statement that additionally improves on
$n^2/(4m)$ wherever the latter is meaningful.

---

## 2. Definitions and notation

Throughout, $G = (V, E)$ is a finite simple graph: $V$ is a finite set, and
adjacency is a symmetric, irreflexive relation on $V$. We write $u \sim v$ to mean
$u$ and $v$ are adjacent.

- **Order and size.** $n = |V|$ is the *order*; $m = |E|$ is the *size*.
- **Degree.** For $v \in V$, $\deg(v) = |\{u \in V : u \sim v\}|$ is the number of
  neighbors of $v$.
- **Independent set.** $S \subseteq V$ is independent if $u \not\sim v$ for all
  distinct $u, v \in S$. The independence number is
  $\alpha(G) = \max\{|S| : S \text{ independent}\}$.
- **Relative degree.** For a vertex subset $W \subseteq V$ and $v \in V$, the
  *relative degree* $\deg_W(v) = |\{u \in W : v \sim u\}|$ counts the neighbors of
  $v$ that lie inside $W$. When $W = V$ this is the ordinary degree:
  $\deg_V(v) = \deg(v)$.

The relative degree is the technical device that makes the induction in Section 4
clean: it lets us track how degrees change as vertices are deleted, working
entirely inside the ambient vertex set rather than passing to genuinely smaller
graphs.

---

## 3. The handshake identity and an edge bound

We first record two elementary facts that connect local degree data to the global
size $m$.

> **Lemma 5 (Handshake identity, weighted form).** For every finite simple graph,
> $$\sum_{v \in V} \big(\deg(v) + 1\big) \;=\; 2m + n.$$

*Proof sketch.* Summing the standard handshake identity $\sum_v \deg(v) = 2m$ —
each edge contributes $1$ to the degree of each of its two endpoints, hence $2$ to
the total — with $\sum_v 1 = n$ gives the claim. $\qquad\blacksquare$

> **Lemma 7 (Edge bound).** For every finite simple graph,
> $$2m + n \;\le\; n^2.$$

*Proof sketch.* A simple graph on $n$ vertices has at most $\binom{n}{2} =
n(n-1)/2$ edges, so $2m \le n(n-1) = n^2 - n$, whence $2m + n \le n^2$.
$\qquad\blacksquare$

Lemma 7 guarantees that the bound of Theorem 1 is never vacuous: it yields
$n^2/(2m+n) \ge 1$, so a nonempty independent set always exists (true trivially,
but a useful consistency check).

---

## 4. The Caro–Wei vertex-weighted bound

The heart of the development is the following refinement, which is sharper than
Theorem 1 because it adapts to the full degree sequence rather than only to the
average degree.

> **Theorem 2 (Caro–Wei).** Every finite simple graph $G$ contains an independent
> set $S$ with
> $$\sum_{v \in V} \frac{1}{\deg(v) + 1} \;\le\; |S|.$$

We prove a localized version relative to an arbitrary vertex subset $W$, from
which Theorem 2 follows by taking $W = V$.

> **Lemma 3 (Localized Caro–Wei).** For every $W \subseteq V$ there exists an
> independent set $S \subseteq W$ with
> $$\sum_{v \in W} \frac{1}{\deg_W(v) + 1} \;\le\; |S|.$$

*Proof sketch.* We induct on $|W|$ using strong induction.

If $W = \varnothing$, take $S = \varnothing$; both sides are $0$.

Otherwise pick a vertex $v_0 \in W$ of *maximum* relative degree,
$\deg_W(v_0) = \max_{v \in W} \deg_W(v) =: d_0$.

*Case $d_0 = 0$.* Then no vertex of $W$ has a neighbor in $W$, so $W$ itself is
independent and every term $1/(\deg_W(v)+1) = 1$. Taking $S = W$ gives
$\sum_{v \in W} 1 = |W| = |S|$.

*Case $d_0 \ge 1$.* Apply the inductive hypothesis to $W' = W \setminus \{v_0\}$,
obtaining an independent set $S \subseteq W'$ with
$\sum_{v \in W'} 1/(\deg_{W'}(v) + 1) \le |S|$. Since $S \subseteq W' \subseteq W$
and $S$ is independent in $G$, it remains a valid candidate for $W$. It therefore
suffices to show
$$\sum_{v \in W} \frac{1}{\deg_W(v)+1} \;\le\; \sum_{v \in W'} \frac{1}{\deg_{W'}(v)+1}.$$

The relation between the two relative degrees is exact (Lemma 4 below): for
$u \in W'$,
$$\deg_W(u) = \deg_{W'}(u) + \mathbf{1}[u \sim v_0].$$
Hence the per-vertex weight gain in passing from $W$ to $W'$ is, for each
neighbor $u$ of $v_0$ in $W'$,
$$\frac{1}{\deg_{W'}(u)+1} - \frac{1}{\deg_W(u)+1}
 = \frac{1}{\deg_{W'}(u)+1} - \frac{1}{\deg_{W'}(u)+2}
 = \frac{1}{(\deg_{W'}(u)+1)(\deg_{W'}(u)+2)},$$
and $0$ for non-neighbors. Because $v_0$ has maximum degree, every neighbor $u$
satisfies $\deg_W(u) \le d_0$, i.e. $\deg_{W'}(u) + 1 \le d_0$, so each nonzero
gain is at least
$$\frac{1}{(\deg_{W'}(u)+1)(\deg_{W'}(u)+2)} \;\ge\; \frac{1}{d_0 (d_0 + 1)}.$$
Summing over the $d_0$ neighbors of $v_0$ in $W'$ (there are exactly
$\deg_W(v_0) = d_0$ of them, since $v_0 \in W$), the total weight gain is at least
$$d_0 \cdot \frac{1}{d_0(d_0+1)} = \frac{1}{d_0 + 1} = \frac{1}{\deg_W(v_0)+1}.$$
This is precisely the weight contributed by $v_0$ itself in the sum over $W$ —
the only term present in $W$ but absent in $W'$. Therefore
$$\sum_{v \in W'} \frac{1}{\deg_{W'}(v)+1}
 \;\ge\; \sum_{v \in W'} \frac{1}{\deg_W(v)+1} + \frac{1}{\deg_W(v_0)+1}
 \;=\; \sum_{v \in W} \frac{1}{\deg_W(v)+1},$$
completing the induction. $\qquad\blacksquare$

> **Lemma 4 (Degree under deletion).** For $W \subseteq V$, $v_0 \in W$, and any
> $u \in V$,
> $$\deg_W(u) = \deg_{W \setminus \{v_0\}}(u) + \mathbf{1}[u \sim v_0].$$

*Proof sketch.* The neighbors of $u$ inside $W$ are partitioned into those inside
$W \setminus \{v_0\}$ together with $v_0$ itself precisely when $u \sim v_0$;
counting gives the identity. $\qquad\blacksquare$

Theorem 2 is the special case $W = V$ of Lemma 3, using $\deg_V = \deg$.

---

## 5. The arithmetic–harmonic mean inequality

To pass from the degree-sequence-dependent bound of Theorem 2 to the $n, m$-only
bound of Theorem 1, we use the following standard inequality.

> **Lemma 6 (Arithmetic–harmonic mean inequality).** For positive reals
> $f_1, \dots, f_n$,
> $$\frac{n^2}{\sum_{i=1}^n f_i} \;\le\; \sum_{i=1}^n \frac{1}{f_i}.$$

*Proof sketch.* By the Cauchy–Schwarz inequality applied to the vectors with
components $\sqrt{f_i}$ and $1/\sqrt{f_i}$,
$$n^2 = \left(\sum_{i=1}^n \sqrt{f_i}\cdot \frac{1}{\sqrt{f_i}}\right)^2
 \le \left(\sum_{i=1}^n f_i\right)\left(\sum_{i=1}^n \frac{1}{f_i}\right).$$
Dividing by the positive quantity $\sum_i f_i$ yields the claim. Equivalently,
this is the inequality between the arithmetic mean $\frac1n\sum_i f_i$ and the
harmonic mean $n/\sum_i (1/f_i)$. $\qquad\blacksquare$

---

## 6. Proof of the main theorem

We now assemble the components.

*Proof of Theorem 1.* Apply Theorem 2 to obtain an independent set $S$ with
$$\sum_{v \in V} \frac{1}{\deg(v) + 1} \;\le\; |S|.$$
Apply Lemma 6 with $f_v = \deg(v) + 1 > 0$:
$$\frac{n^2}{\sum_{v}(\deg(v)+1)} \;\le\; \sum_{v} \frac{1}{\deg(v)+1}.$$
By the weighted handshake identity (Lemma 5), $\sum_v (\deg(v)+1) = 2m + n$.
Substituting and chaining the two inequalities,
$$\frac{n^2}{2m + n} \;\le\; \sum_{v} \frac{1}{\deg(v)+1} \;\le\; |S| \;\le\; \alpha(G),$$
which is the assertion of Theorem 1. Because the size of an independent set is an
integer, one may further conclude $\alpha(G) \ge \lceil n^2/(2m+n) \rceil$ when
the quotient is not an integer, and in particular $\alpha(G) \ge 1$ by Lemma 7.
$\qquad\blacksquare$

---

## 7. The folklore bound $n^2/(4m)$ is false

A persistent piece of folklore states the guarantee as $n^2/(4m)$. We explain its
origin, show it is false, and locate the error precisely.

### 7.1 Origin via probabilistic deletion

The probabilistic deletion method proceeds as follows. Fix $p \in [0,1]$. Sample
a random subset $R \subseteq V$ by including each vertex independently with
probability $p$. The expected number of retained vertices is $pn$, and the
expected number of retained edges (both endpoints sampled) is $p^2 m$. Deleting
one endpoint from each retained edge produces an independent set of expected size
at least
$$\mathbb{E}[|R|] - \mathbb{E}[\#\text{edges in } R] \;\ge\; pn - p^2 m.$$
Optimizing the quadratic $pn - p^2 m$ over $p$ gives the unconstrained maximizer
$p^\star = n/(2m)$ with value $n^2/(4m)$.

### 7.2 The constraint $p \le 1$ and the failure

The maximizer $p^\star = n/(2m)$ is a legal probability only if $p^\star \le 1$,
i.e. only if
$$n \le 2m.$$
For sparser graphs ($2m < n$) the optimum of the *constrained* problem
$p \in [0,1]$ is attained at the boundary $p = 1$, not at $p^\star$, and the value
$n^2/(4m)$ is unattainable. Reporting it anyway yields absurdities.

> **Counterexample.** Let $n = 100$ and $m = 1$ (a hundred vertices, a single
> edge). The folklore formula claims an independent set of size
> $$\frac{n^2}{4m} = \frac{100^2}{4 \cdot 1} = 2500,$$
> which exceeds $n = 100$. No graph on $100$ vertices can contain an independent
> set of $2500$ vertices. By contrast the true bound gives
> $$\frac{n^2}{2m+n} = \frac{10000}{102} \approx 98.04,$$
> hence $\alpha(G) \ge 99$ for this graph, which is exactly correct (delete one
> endpoint of the single edge).

### 7.3 The relationship between the two bounds

The two expressions are directly comparable.

> **Proposition 8.** For all $n \ge 1$ and $m \ge 1$,
> $$\frac{n^2}{2m+n} \;\ge\; \frac{n^2}{4m} \iff n \le 2m.$$

*Proof sketch.* Both numerators equal $n^2 > 0$, so the inequality between the
fractions reverses the inequality between the denominators:
$n^2/(2m+n) \ge n^2/(4m)$ iff $2m + n \le 4m$ iff $n \le 2m$. $\qquad\blacksquare$

Thus on the dense graphs where the deletion bound is legal ($n \le 2m$), the true
bound $n^2/(2m+n)$ is at least as large — a genuine strengthening — while on
sparse graphs ($n > 2m$) the deletion formula is simply invalid and the true
bound continues to hold. Moreover $n^2/(2m+n) \le n$ always (since
$2m + n \ge n$), so the true bound never makes an impossible promise.

---

## 8. Sharpness: Turán's extremal graphs

Theorem 1 is best possible: there is a family of graphs on which the inequality is
an equality, so the denominator $2m + n$ cannot be replaced by anything smaller.

> **Proposition 9 (Tightness).** Let $G$ be the disjoint union of $k$ cliques each
> of order $r$, so $n = kr$ and $m = k\binom{r}{2} = kr(r-1)/2$. Then
> $\alpha(G) = k$ and $n^2/(2m+n) = k$, so Theorem 1 holds with equality.

*Proof sketch.* An independent set can contain at most one vertex from each
clique, and choosing exactly one per clique is independent, so $\alpha(G) = k$.
For the formula, $2m + n = kr(r-1) + kr = kr^2 = n r$, hence
$n^2/(2m+n) = (kr)^2/(nr) = n \cdot kr / (nr) = k$. $\qquad\blacksquare$

Every vertex in such a graph has degree $r - 1$, so each Caro–Wei weight is
exactly $1/r$, the total weight is $n/r = k$, and the arithmetic–harmonic step is
also tight because all $f_v$ are equal. This is precisely the equality case of
Turán's theorem viewed through complementation: among graphs with given $n$ and
$m$, balanced disjoint unions of cliques minimize the independence number, and
they meet our bound exactly.

---

## 9. Algorithmic realization

The proof of Lemma 3 is constructive and yields a greedy algorithm — the
*minimum-degree greedy* (also known as the GREEDY-IS heuristic) — that produces an
independent set meeting the Caro–Wei guarantee, and hence Theorem 1.

**Minimum-degree greedy.** Repeatedly select a vertex of minimum degree in the
current graph, add it to the independent set, and delete it together with all its
neighbors; continue until no vertices remain.

This selection rule (minimum degree) is the operational complement of the
maximum-degree deletion used in the induction, and it provably returns a set of
size at least $\sum_v 1/(\deg(v)+1) \ge n^2/(2m+n)$. The algorithm runs in
$O(n + m)$ time with appropriate bucket-by-degree data structures, making the
guarantee not only existential but efficiently achievable.

A second, even simpler route to a set of size at least $\sum_v 1/(\deg(v)+1)$ in
expectation is the **random permutation method**: draw a uniformly random ordering
of the vertices and keep each vertex that precedes all of its neighbors in the
order. The probability that $v$ is kept is exactly $1/(\deg(v)+1)$ — $v$ must be
first among the $\deg(v)+1$ vertices of its closed neighborhood — and the kept set
is independent, so its expected size equals the Caro–Wei sum. Derandomizing by the
method of conditional expectations recovers the greedy algorithm.

---

## 10. Applications

The independence-number guarantee is a workhorse with broad reach.

- **Scheduling and conflict resolution.** Model tasks as vertices and pairwise
  conflicts as edges; an independent set is a set of mutually compatible tasks. The
  bound guarantees a large conflict-free batch from only the task and conflict
  counts.
- **Wireless frequency assignment.** Transmitters that interfere are adjacent; an
  independent set is a set of mutually non-interfering transmitters that may share a
  channel.
- **Coding theory.** Codewords with small pairwise distance form edges of a
  conflict graph; large independent sets correspond to large codes with guaranteed
  minimum distance.
- **Molecular and statistical-physics models.** Hard-core configurations (no two
  occupied adjacent sites) are exactly independent sets; lower bounds on their size
  bound ground-state occupancy.

In each setting the appeal is identical: a global existence guarantee follows from
two global counts, with no need to analyze the detailed structure of the conflict
graph.

---

## 11. Discussion and future work

The development above is deliberately modular: the Caro–Wei weighted bound
(Theorem 2) is the substantive combinatorial input, while the passage to the
$n,m$-only form (Theorem 1) is pure inequality manipulation via handshake and
Cauchy–Schwarz. This separation clarifies *why* the bound holds and isolates the
single place — maximum-degree induction — where graph structure is used.

Several directions extend the result.

- **Weighted and hypergraph analogues.** Caro–Wei generalizes to vertex-weighted
  independent sets and to bounds on independent sets in hypergraphs via
  inclusion–exclusion over the degree sequence.
- **Local refinements.** Replacing the global average degree with neighborhood
  statistics (e.g., triangle counts, as in the Shearer and Ajtai–Komlós–Szemerédi
  improvements for triangle-free graphs) yields strictly stronger bounds of order
  $\Omega\big(\tfrac{n}{d}\log d\big)$ for graphs of average degree $d$.
- **Algorithmic optimality.** Understanding the precise approximation ratio of the
  minimum-degree greedy algorithm relative to $\alpha(G)$ on structured graph
  classes remains an active topic.

The broader methodological lesson — that an "almost true" formula
($n^2/(4m)$) can be repaired into an "always true" one ($n^2/(2m+n)$) by
respecting a single feasibility constraint — recurs throughout the probabilistic
method, where optimizing a parameter without enforcing its natural range is a
common and instructive pitfall.

---

## Appendix: summary of the logical structure

$$
\underbrace{\text{Lemma 4}}_{\text{degree under deletion}}
\;\Rightarrow\;
\underbrace{\text{Lemma 3}}_{\text{localized Caro–Wei}}
\;\Rightarrow\;
\underbrace{\text{Theorem 2}}_{\text{Caro–Wei}}
$$
$$
\Big(\text{Theorem 2}\Big)
+\underbrace{\text{Lemma 5}}_{\text{handshake}}
+\underbrace{\text{Lemma 6}}_{\text{AM–HM}}
\;\Rightarrow\;
\underbrace{\text{Theorem 1}}_{\;\alpha(G)\ge n^2/(2m+n)\;}
$$
with Lemma 7 ensuring non-vacuity, Proposition 8 relating the bound to the
folklore $n^2/(4m)$, and Proposition 9 establishing sharpness.
