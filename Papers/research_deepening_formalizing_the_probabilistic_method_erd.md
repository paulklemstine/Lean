# Property B and the First-Moment Threshold for Hypergraph Two-Colorability

## Abstract

We present a self-contained development of *Property B* — the two-colorability
of hypergraphs — through the lens of the probabilistic method. Our central
result is Erdős's 1963 first-moment theorem in a sharp form: a hypergraph in
which every edge contains at least $k \ge 1$ vertices and which has fewer than
$2^{k-1}$ edges admits a red/blue vertex coloring with no monochromatic edge.
The argument is a finite union bound over the $2^N$ colorings of an
$N$-vertex ground set, resting on two elementary Boolean-lattice interval
counts. We derive the classical $k$-uniform statement, the extremal-function
lower bound $m(k) \ge 2^{k-1}$ in contrapositive form, and an explicit sharp
witness for $k = 2$: the triangle is a non-two-colorable $2$-uniform hypergraph
with exactly three edges, yielding $m(2) = 3$. We discuss algorithms,
numerical illustrations, connections to Ramsey theory, and directions toward
the Radhakrishnan–Srinivasan improvement and a Lovász-Local-Lemma variant.

## 1. Introduction

A recurring theme in modern combinatorics is that objects with desirable
properties can be shown to exist without being constructed. The *probabilistic
method*, developed and championed by Paul Erdős, proves existence by exhibiting
a probability distribution under which the desired property holds with positive
probability. If a random object is "good" more than $0\%$ of the time, at least
one good object must exist.

One of the cleanest applications is to **Property B**, the question of whether
the vertices of a hypergraph can be colored with two colors so that no edge is
monochromatic. Named after Felix Bernstein, who studied set systems admitting
such colorings, Property B has been a proving ground for the probabilistic
method for over sixty years. Erdős (1963) showed that any hypergraph whose edges
are $k$-element sets and which has fewer than $2^{k-1}$ edges has Property B.
This paper gives a complete, elementary account of that theorem and its
immediate consequences, deliberately replacing the probabilistic language with
an equivalent finite counting argument that makes every constant explicit.

### Contributions

1. Two Boolean-lattice interval-counting lemmas (superset count and disjoint
   count), each yielding $2^{|G|-|S|}$.
2. The sharp first-moment theorem: edges of size $\ge k$ and fewer than
   $2^{k-1}$ edges imply two-colorability.
3. The classical $k$-uniform specialization.
4. The contrapositive extremal lower bound $m(k) \ge 2^{k-1}$.
5. An explicit extremal witness establishing $m(2) = 3$ via the triangle.

## 2. Definitions

Throughout, $N, k \in \mathbb{N}$ and the vertex set is $V = \{0, 1, \dots, N-1\}$,
identified with a finite type of size $N$.

**Definition 2.1 (Hypergraph).** A *hypergraph* on $V$ is a finite family
$H$ of subsets of $V$. Each $e \in H$ is an *edge*. The hypergraph is
*$k$-uniform* if $|e| = k$ for every edge $e$.

**Definition 2.2 (Two-coloring).** A *two-coloring* is a subset $R \subseteq V$;
we regard the vertices in $R$ as *red* and those in $V \setminus R$ as *blue*.

**Definition 2.3 (Monochromatic edge).** An edge $e$ is *monochromatic* under
$R$ if it is entirely red, $e \subseteq R$, or entirely blue,
$e \cap R = \varnothing$ (equivalently $e$ and $R$ are disjoint).

**Definition 2.4 (Property B / proper two-coloring).** A coloring $R$ is *proper*
if no edge is monochromatic, i.e. for every edge $e$ we have $e \not\subseteq R$
and $e$ is not disjoint from $R$ — equivalently every edge contains both a red and
a blue vertex. The hypergraph *has Property B* if a proper coloring exists.

**Definition 2.5 (Property B function).** For $k \ge 1$, let $m(k)$ be the least
number of edges in a non-two-colorable $k$-uniform hypergraph. Equivalently,
$m(k)$ is the largest integer such that every $k$-uniform hypergraph with fewer
than $m(k)$ edges has Property B.

## 3. Boolean-lattice interval counts

The engine of the whole development is the observation that fixing part of a
subset's membership leaves a power-set of free choices.

**Lemma 3.1 (Superset count).** Let $G$ be a finite set and $S \subseteq G$.
The number of subsets $A \subseteq G$ with $S \subseteq A$ equals
$2^{|G| - |S|}$.

*Proof.* The map $A \mapsto A \setminus S$ is a bijection between
$\{A \subseteq G : S \subseteq A\}$ and the power set of $G \setminus S$. It is
injective because $S \subseteq A, B$ implies $A = (A\setminus S) \cup S$ and
$B = (B \setminus S)\cup S$, so $A \setminus S = B \setminus S$ forces
$A = B$. It is surjective because any $B \subseteq G \setminus S$ is the image of
$B \cup S$. Hence the count equals $|\mathcal{P}(G \setminus S)| = 2^{|G|-|S|}$.
$\qquad\blacksquare$

**Lemma 3.2 (Disjoint count).** Let $G$ be a finite set and $S \subseteq G$.
The number of subsets $A \subseteq G$ with $A \cap S = \varnothing$ equals
$2^{|G|-|S|}$.

*Proof.* The complement involution $A \mapsto G \setminus A$ carries the family
$\{A \subseteq G : A \cap S = \varnothing\}$ bijectively onto
$\{A \subseteq G : S \subseteq A\}$: indeed $A$ is disjoint from $S$ iff every
element of $S$ lies outside $A$, i.e. inside $G \setminus A$, i.e.
$S \subseteq G \setminus A$. The result follows from Lemma 3.1.
$\qquad\blacksquare$

## 4. The first-moment theorem

**Theorem 4.1 (Property B, sharp form).** Let $H$ be a hypergraph on an
$N$-vertex set such that every edge has at least $k \ge 1$ vertices. If
$|H| < 2^{k-1}$, then $H$ has Property B: there exists a coloring $R$ such that
every edge $e$ satisfies $e \not\subseteq R$ and $e \cap R \ne \varnothing$.

*Proof.* There are exactly $2^N$ colorings, identified with subsets
$R \subseteq V$. Call a coloring *bad for $e$* if $e$ is monochromatic under it.
By Lemma 3.1 the colorings with $e \subseteq R$ number $2^{N-|e|}$; by Lemma 3.2
the colorings with $e \cap R = \varnothing$ number $2^{N-|e|}$. Since
$|e| \ge k$, and $x \mapsto 2^{N-x}$ is nonincreasing, each of these counts is at
most $2^{N-k}$. Hence the colorings bad for $e$ number at most
$$2 \cdot 2^{N-k} = 2^{N-k+1}.$$
Summing over the edges and using the union (sub-additivity) bound, the number of
colorings that are bad for *some* edge is at most
$$\sum_{e \in H} 2^{N-k+1} = |H| \cdot 2^{N-k+1} < 2^{k-1} \cdot 2^{N-k+1} = 2^{N}.$$
Thus strictly fewer than $2^N$ colorings are bad, so at least one of the $2^N$
colorings is proper. $\qquad\blacksquare$

Two remarks. First, the hypothesis is on a *lower* bound of edge sizes, so the
theorem covers hypergraphs with edges of mixed sizes, not merely uniform ones —
this is why we call it the sharp form. Second, the strict inequality
$|H| < 2^{k-1}$ is exactly what makes the final estimate strict; equality
$|H| = 2^{k-1}$ is not enough in general, as the triangle ($k=2$, $|H|=2$? no)
and Fano plane witnesses below illustrate the true threshold behaviour.

**Corollary 4.2 (Classical $k$-uniform Property B).** Every $k$-uniform
hypergraph ($k \ge 1$) with fewer than $2^{k-1}$ edges has Property B.

*Proof.* A $k$-uniform hypergraph has all edges of size exactly $k \ge k$, so
Theorem 4.1 applies. $\qquad\blacksquare$

**Corollary 4.3 (Two-colorability, membership form).** Under the hypotheses of
Corollary 4.2 there is a coloring $R$ such that every edge both meets $R$ and
meets its complement.

## 5. The extremal function

**Definition 5.1 (Non-two-colorable).** $H$ is *non-two-colorable* if for every
coloring $R$ some edge is monochromatic.

**Theorem 5.2 (Extremal lower bound).** If $H$ is non-two-colorable and every
edge has at least $k \ge 1$ vertices, then $|H| \ge 2^{k-1}$. In particular for
$k$-uniform $H$, $m(k) \ge 2^{k-1}$.

*Proof.* Contrapositive of Theorem 4.1: if $|H| < 2^{k-1}$ then $H$ has Property
B, contradicting non-two-colorability. $\qquad\blacksquare$

This is the precise sense in which $2^{k-1}$ is a genuine threshold: it is a
*guaranteed floor* on the number of edges any stubborn (non-two-colorable)
hypergraph must contain.

## 6. A sharp witness: $m(2) = 3$

The lower bound $m(k) \ge 2^{k-1}$ needs a matching construction to be pinned
down. For $k = 2$ the extremal configuration is the triangle.

**Definition 6.1 (Triangle hypergraph).** Let $T$ be the $2$-uniform hypergraph
on $\{0,1,2\}$ with edge set $\{\{0,1\}, \{1,2\}, \{0,2\}\}$, so $|T| = 3$.

**Proposition 6.2.** $T$ is $2$-uniform, has exactly three edges, and is
non-two-colorable.

*Proof.* Each edge has size $2$, and the three listed edges are distinct, so
$|T| = 3$. For non-two-colorability, note a $2$-uniform hypergraph is
two-colorable iff it is bipartite as a graph. Among any two-coloring of three
vertices with two colors, two vertices share a color by pigeonhole; in the
complete graph on $\{0,1,2\}$ that pair is an edge, which is then monochromatic.
Exhaustively, each of the $2^3 = 8$ colorings $R \subseteq \{0,1,2\}$ leaves at
least one of the three edges monochromatic. Hence no proper coloring exists.
$\qquad\blacksquare$

**Corollary 6.3.** $m(2) \le 3$, and combined with Theorem 5.2 ($m(2) \ge 2$)
plus the elementary fact that every graph with at most two edges is bipartite
(hence $m(2) \ge 3$), we obtain $m(2) = 3$.

For completeness we record the next value. The smallest non-two-colorable
$3$-uniform hypergraph is the **Fano plane**, the projective plane of order $2$,
whose seven lines are its edges; it certifies $m(3) = 7$ (its non-two-colorability
is the classical statement that the Fano plane's lines cannot be two-colored
without a monochromatic line). This value comfortably exceeds the general lower
bound $2^{3-1} = 4$, showing the first-moment bound is not tight for all $k$.

## 7. Algorithms

The proof is constructive in the weak sense of the probabilistic method: it
guarantees a proper coloring exists among $2^N$ candidates. Three natural
algorithmic tasks arise.

**(A) Exhaustive verification of Property B.** Enumerate all $2^N$ colorings and
test each edge for monochromaticity; report the first proper coloring or declare
the hypergraph non-two-colorable. Complexity $O(2^N \cdot \sum_e |e|)$. This is
how the triangle's non-two-colorability is certified.

**(B) First-moment feasibility check.** Given edge-size lower bound $k$ and edge
count $m$, decide whether Theorem 4.1 guarantees Property B by testing
$m < 2^{k-1}$. Complexity $O(1)$ after reading the parameters. Useful as a fast
sufficient certificate before attempting (A).

**(C) Randomized coloring with expected-few-tries.** Sample $R$ uniformly; accept
if proper. Under the theorem's hypothesis, a uniformly random coloring is proper
with probability $> 0$, and in fact with probability at least
$1 - m \cdot 2^{-(k-1)} > 0$; the expected number of trials to success is at most
$(1 - m\,2^{-(k-1)})^{-1}$. This turns the counting existence proof into a Las
Vegas algorithm.

## 8. Numerical illustrations

The accompanying computations demonstrate: (i) the interval counts of Lemmas
3.1–3.2 over concrete ground sets; (ii) the union-bound inequality
$m \cdot 2^{N-k+1} < 2^N$ for parameters satisfying $m < 2^{k-1}$; (iii)
exhaustive verification that random sparse hypergraphs are two-colorable; and
(iv) exhaustive confirmation that the triangle and the Fano plane are
non-two-colorable, matching $m(2)=3$ and $m(3)=7$.

## 9. Applications and connections

The first-moment template — *color randomly, bound bad events, conclude a good
event survives* — is the same argument that underlies:

- **Ramsey lower bounds.** Coloring the edges of a complete graph at random shows
  $R(k,k) > 2^{k/2}$: monochromatic cliques are too rare to be unavoidable in
  small graphs.
- **Coding theory.** Random codes meeting the Gilbert–Varshamov bound exist
  because the fraction of "too-close" codeword pairs is $< 1$.
- **Hypergraph coloring in practice.** Property B is the combinatorial heart of
  constraint-satisfaction and SAT instances (a monochromatic edge is an
  unsatisfied clause), where sparsity guarantees satisfiability.

Its close cousin, the **Lovász Local Lemma**, relaxes the global sparsity
hypothesis to a *local* one: if each edge intersects few others, two-colorability
still follows even when the total number of edges is large.

## 10. Discussion and future work

The first-moment bound $m(k) \ge 2^{k-1}$ is the entry point to a rich extremal
theory. Three directions stand out.

1. **Extremal function $m(k)$.** With the lower bound established and the witness
   $m(2)=3$ realized by the triangle, the next targets are the matching value
   $m(3)=7$ (Fano plane) and a general packaging of $m(k)$ as an explicit
   extremal number via minimization over non-two-colorable configurations.

2. **Random / alteration improvement.** The lower bound can be sharpened to the
   Radhakrishnan–Srinivasan estimate
   $m(k) = \Omega\!\big(2^k \sqrt{k/\log k}\big)$ via a semi-random (recoloring)
   argument, which reduces the number of monochromatic edges after an initial
   random coloring.

3. **Local-lemma two-colorability.** Combining the chain-rule form of the Lovász
   Local Lemma with a bounded edge-intersection hypothesis yields a *local*
   version of Property B: a $k$-uniform hypergraph in which each edge meets fewer
   than $2^{k-3}$ others is two-colorable, regardless of the total edge count.

## 11. Conclusion

Property B crystallizes the probabilistic method into one line: paint at random,
count the failures, and if the failures cannot cover every painting, a success
must exist. The finite counting presentation makes every constant transparent
and the threshold $2^{k-1}$ manifest, while the triangle witness shows the theory
is sharp already at $k = 2$. From this small seed grow Ramsey theory, coding
theory, and the local-lemma refinements that dominate modern combinatorics.

## References (classical)

- P. Erdős, *On a combinatorial problem*, Nordisk Mat. Tidskr. 11 (1963).
- P. Erdős, *On a combinatorial problem II*, Acta Math. Acad. Sci. Hungar. 15 (1964).
- J. Radhakrishnan and A. Srinivasan, *Improved bounds and algorithms for
  hypergraph two-coloring*, Random Structures & Algorithms 16 (2000).
- N. Alon and J. H. Spencer, *The Probabilistic Method*, Wiley.
