# The Erdős Extremal Function for Property B: A Counting Foundation and the Exact Values $m(1)=1$ and $m(2)=3$

## Abstract

A hypergraph has *Property B* when its vertices can be two-coloured so that no
edge is monochromatic. The **Erdős extremal function** $m(k)$ is the minimum
number of edges of a $k$-uniform hypergraph that fails Property B. We develop the
theory of $m(k)$ from first principles on an exact, finitary foundation. Two
Boolean-lattice counting identities — the number of subsets of an $N$-element
ground set containing (respectively, disjoint from) a fixed set $S$ is
$2^{N-|S|}$ — yield, via a union bound over colourings, a sharp existence theorem:
every hypergraph whose edges each have at least $k \ge 1$ vertices and which has
fewer than $2^{k-1}$ edges admits a proper two-colouring. As an immediate
consequence we obtain the classical **Erdős lower bound** $m(k) \ge 2^{k-1}$. We
then package $m(k)$ as a genuine extremal number (an infimum over all vertex
counts) and determine its first two exact values. For $k=1$ the single
vertex-edge gives $m(1)=1$. For $k=2$ we prove the sharp lower-bound step — *every
graph with at most two edges is two-colourable* — which upgrades the generic bound
$m(2)\ge 2$ to $m(2)\ge 3$; combined with the triangle as an explicit
minimum-edge witness this yields $m(2)=3$. All results are established
constructively, with the extremal witnesses exhibited explicitly and their
non-two-colourability verified by exhaustive finite check.

**Keywords:** Property B, hypergraph two-colouring, extremal function, Erdős
lower bound, probabilistic method, union bound, Boolean lattice, triangle graph.

---

## 1. Introduction

Let $H$ be a hypergraph: a finite ground set $V$ of *vertices* together with a
finite family of *edges*, each edge being a subset of $V$. A **two-colouring** is
a map $c : V \to \{\text{red}, \text{blue}\}$, conveniently encoded by its red
set $R = c^{-1}(\text{red}) \subseteq V$. The colouring is **proper** for $H$ if
no edge is monochromatic, i.e. for every edge $e$,
$$e \not\subseteq R \qquad\text{and}\qquad e \cap R \ne \varnothing.$$
A hypergraph admitting a proper two-colouring is said to **have Property B**
(Bernstein, 1908). A hypergraph is **$k$-uniform** if every edge has exactly $k$
vertices.

In 1963 Erdős asked for the minimum number of edges needed to defeat every
two-colouring, defining the extremal function
$$m(k) = \min\{\,|H| : H \text{ is $k$-uniform and has no proper two-colouring}\,\}.$$
He proved, by the probabilistic method, that $m(k) \ge 2^{k-1}$. Determining
$m(k)$ exactly is a notoriously hard problem: the known exact values are
$m(1)=1$, $m(2)=3$, and $m(3)=7$ (the Fano plane), while for $k \ge 4$ only
bounds are known. The best general lower bound, due to Radhakrishnan and
Srinivasan (2000), is $m(k) = \Omega\!\big(2^{k}\sqrt{k/\log k}\big)$; the best
upper bound is $O(k^{2} 2^{k})$.

This paper gives a complete, self-contained development of the foundations of
$m(k)$ and determines its first two exact values. Our contributions are:

1. **A finitary counting foundation** (Section 3). We prove the two
   Boolean-lattice interval identities and derive the sharp existence theorem via
   a deterministic union bound over the $2^{N}$ colourings, sidestepping measure
   theory entirely.
2. **The Erdős lower bound, repackaged** (Section 4). We phrase
   non-two-colourability precisely and obtain $2^{k-1} \le m(k)$.
3. **The extremal function as an infimum** (Section 5). We package $m(k)$ as
   $\inf$ of a concretely described set of realisable edge-counts.
4. **Exact values** (Sections 6–7). We prove $m(1)=1$ and $m(2)=3$. The heart is
   the sharp $k=2$ lower-bound step: *every graph with at most two edges is
   two-colourable*, which is new content beyond the generic probabilistic bound.

---

## 2. Notation and conventions

Throughout, $V$ is finite; we take $V = \{0, 1, \dots, N-1\}$ without loss of
generality. Edges are subsets of $V$, and a hypergraph $H$ is a finite family of
such subsets. We write $|X|$ for cardinality, $X \setminus Y$ for set difference,
$X^{c} = V \setminus X$ for complement within $V$, and $\mathcal{P}(V)$ for the
power set. Two sets are *disjoint*, written $X \cap Y = \varnothing$, when they
share no element. All quantities are natural numbers; $\lfloor\cdot\rfloor$ never
appears because our counts are exact powers of two.

---

## 3. The counting foundation

The entire theory rests on two elementary but sharp cardinality identities for
intervals in the Boolean lattice $\mathcal{P}(V)$.

### 3.1 Interval counts

**Lemma 3.1 (Superset count).** *Let $V$ be a ground set and $S \subseteq V$.
The number of subsets $A \subseteq V$ with $S \subseteq A$ is exactly
$2^{|V| - |S|}$.*

*Proof.* Restriction to the complement gives a bijection
$$\{A \subseteq V : S \subseteq A\} \;\longleftrightarrow\; \mathcal{P}(V \setminus S),
\qquad A \mapsto A \setminus S,$$
with inverse $B \mapsto B \cup S$. The map is well defined because $A \setminus S
\subseteq V \setminus S$; it is injective because $S \subseteq A, B$ forces
$A = (A \setminus S) \cup S$; and it is surjective because for $B \subseteq V
\setminus S$ the set $A = B \cup S$ satisfies $S \subseteq A$ and $A \setminus S
= B$. Hence the count equals $|\mathcal{P}(V \setminus S)| = 2^{|V \setminus S|}
= 2^{|V| - |S|}$. $\qquad\blacksquare$

**Lemma 3.2 (Disjointness count).** *Let $V$ be a ground set and $S \subseteq V$.
The number of subsets $A \subseteq V$ with $S \cap A = \varnothing$ is exactly
$2^{|V| - |S|}$.*

*Proof.* Complementation $A \mapsto V \setminus A$ is an involution of
$\mathcal{P}(V)$ that sends $\{A : S \cap A = \varnothing\}$ bijectively onto
$\{A : S \subseteq A\}$: indeed $S \cap A = \varnothing \iff S \subseteq V
\setminus A$. Apply Lemma 3.1. $\qquad\blacksquare$

### 3.2 The union bound and the existence theorem

We now bound the colourings that fail on a single edge and sum over edges.

**Theorem 3.3 (Sharp existence of a proper two-colouring).** *Let $k \ge 1$ and
let $H$ be a hypergraph on $V = \{0,\dots,N-1\}$ in which every edge has at least
$k$ vertices. If*
$$|H| < 2^{\,k-1},$$
*then $H$ has a proper two-colouring: there is a red set $R \subseteq V$ such that
every edge $e \in H$ satisfies $e \not\subseteq R$ and $e \cap R \ne \varnothing$.*

*Proof.* Fix an edge $e$ with $|e| \ge k$. A colouring $R$ is *bad for $e$* if
$e \subseteq R$ (all red) or $e \cap R = \varnothing$ (all blue). By Lemma 3.1
the number of $R \subseteq V$ with $e \subseteq R$ is $2^{N - |e|} \le 2^{N-k}$,
and by Lemma 3.2 the number with $e \cap R = \varnothing$ is likewise
$\le 2^{N-k}$. Hence the number of colourings bad for $e$ is at most
$$2^{N-k} + 2^{N-k} = 2^{\,N-k+1}.$$
Summing (union bound) over the fewer than $2^{k-1}$ edges, the number of
colourings that are bad for *some* edge is at most
$$|H| \cdot 2^{\,N-k+1} \;<\; 2^{\,k-1}\cdot 2^{\,N-k+1} \;=\; 2^{N}.$$
Since there are exactly $2^{N}$ colourings in total, at least one colouring is bad
for no edge; that colouring is proper. $\qquad\blacksquare$

The bound is *sharp* in the exponent: the factor $2^{k-1}$ cannot be increased in
general, as the extremal witnesses of Sections 6–7 show for small $k$.

**Corollary 3.4 (Single edge).** *Any single edge of size $\ge 2$ is
two-colourable.* Taking $H = \{e\}$ with $|e| \ge 2 = k$ gives $|H| = 1 <
2^{2-1} = 2$; apply Theorem 3.3. $\qquad\blacksquare$

---

## 4. Non-two-colourability and the Erdős lower bound

**Definition 4.1.** A hypergraph $H$ on $V$ is **non-two-colourable** if it has
no proper two-colouring; equivalently, for every red set $R \subseteq V$ there
is an edge $e \in H$ with $e \subseteq R$ or $e \cap R = \varnothing$ (some edge
is monochromatic under $R$).

Theorem 3.3 is exactly the contrapositive of a lower bound on the number of edges
of any non-two-colourable system.

**Theorem 4.2 (Edge lower bound).** *Let $k \ge 1$ and let $H$ be a hypergraph
each of whose edges has at least $k$ vertices. If $H$ is non-two-colourable, then*
$$|H| \;\ge\; 2^{\,k-1}.$$

*Proof.* If $|H| < 2^{k-1}$, Theorem 3.3 produces a proper two-colouring $R$,
contradicting non-two-colourability (which supplies a monochromatic edge under
that very $R$). $\qquad\blacksquare$

Specialising to uniform hypergraphs gives Erdős's classical bound
$m(k) \ge 2^{k-1}$, which we make precise once $m(k)$ is defined.

---

## 5. The extremal function as an infimum

To speak of $m(k)$ as a number we collect all realisable edge-counts.

**Definition 5.1.** For $k \in \mathbb{N}$ let
$$\mathcal{M}(k) = \Big\{\, c \in \mathbb{N} \;:\; \exists\, N,\ \exists\ H
\text{ on } \{0,\dots,N-1\},\ (\forall e \in H,\ |e| = k),\ |H| = c,\
H \text{ non-two-colourable} \,\Big\},$$
the set of edge-counts realised by non-two-colourable $k$-uniform hypergraphs
over all ground-set sizes. Define the **Erdős extremal function**
$$m(k) = \inf \mathcal{M}(k).$$

Because $\mathcal{M}(k) \subseteq \mathbb{N}$, the infimum is attained whenever
$\mathcal{M}(k)$ is nonempty, and $m(k) = \min \mathcal{M}(k)$.

**Theorem 5.2 (Lower bound for the extremal function).** *For $k \ge 1$, every
$c \in \mathcal{M}(k)$ satisfies $c \ge 2^{k-1}$. Consequently, if
$\mathcal{M}(k) \ne \varnothing$ then*
$$m(k) \;\ge\; 2^{\,k-1}.$$

*Proof.* If $c \in \mathcal{M}(k)$, witnessed by a $k$-uniform non-two-colourable
$H$ with $|H| = c$, then every edge has exactly $k \ge k$ vertices, so Theorem
4.2 gives $c = |H| \ge 2^{k-1}$. The bound on the infimum follows since a lower
bound for every element of a nonempty set of naturals is a lower bound for its
infimum. $\qquad\blacksquare$

---

## 6. The value $m(1) = 1$

**Theorem 6.1.** $m(1) = 1$.

*Proof.* *Upper bound.* Consider $V = \{0\}$ and the $1$-uniform hypergraph
$H = \{\{0\}\}$, with a single edge. For any red set $R \subseteq \{0\}$ we have
either $R = \varnothing$, whence the edge $\{0\}$ is disjoint from $R$ (all blue),
or $R = \{0\}$, whence $\{0\} \subseteq R$ (all red). In both cases the edge is
monochromatic, so $H$ is non-two-colourable and $1 \in \mathcal{M}(1)$; hence
$m(1) \le 1$.

*Lower bound.* Since $\mathcal{M}(1)\ne\varnothing$, Theorem 5.2 with $k=1$ gives
$m(1) \ge 2^{1-1} = 2^{0} = 1$.

Combining, $m(1) = 1$. $\qquad\blacksquare$

Note the lower bound is exactly the trivial threshold $2^{0}=1$; a single
one-vertex edge is unavoidably monochromatic under either colour.

---

## 7. The value $m(2) = 3$

For $2$-uniform hypergraphs (ordinary graphs) the generic bound of Theorem 5.2
only gives $m(2) \ge 2^{1} = 2$. The exact value requires a strictly sharper
lower-bound step together with a matching witness.

### 7.1 The sharp lower-bound step

**Theorem 7.1 (Every graph with $\le 2$ edges is two-colourable).** *Let $H$ be a
$2$-uniform hypergraph on $V$ with $|H| \le 2$. Then $H$ has a proper
two-colouring.*

*Proof.* We treat the possible edge-counts.

- $|H| = 0$: any $R$ (e.g. $R = \varnothing$) is vacuously proper.
- $|H| = 1$: the single edge has $2$ vertices; by Corollary 3.4 (or directly,
  colour one endpoint red) it is two-colourable.
- $|H| = 2$: write $H = \{e_1, e_2\}$ with $|e_1| = |e_2| = 2$. There are two
  cases.
  * **$e_1 \cap e_2 \ne \varnothing$:** pick a common vertex $v \in e_1 \cap
    e_2$ and set $R = \{v\}$. Each $e_i$ contains $v \in R$, so $e_i \cap R \ne
    \varnothing$; and since $|e_i| = 2 > 1 = |R \cap e_i|$, each $e_i$ has a
    vertex outside $R$, so $e_i \not\subseteq R$. Thus $R$ is proper.
  * **$e_1 \cap e_2 = \varnothing$:** write $e_1 = \{a_1, b_1\}$ and $e_2 =
    \{a_2, b_2\}$ with the four vertices distinct, and set $R = \{a_1, a_2\}$.
    Then $a_i \in e_i \cap R$ while $b_i \in e_i \setminus R$, so each edge meets
    and misses $R$. Thus $R$ is proper.

In every case a proper two-colouring exists. $\qquad\blacksquare$

Structurally, two distinct $2$-element edges cannot close a cycle (a cycle needs
at least three edges), so a graph with at most two edges is a forest, and forests
are bipartite; the case analysis above makes the bipartition explicit.

**Corollary 7.2.** *A $2$-uniform hypergraph with $\le 2$ edges is not
non-two-colourable.* Immediate from Theorem 7.1 and Definition 4.1.
$\qquad\blacksquare$

**Corollary 7.3.** *Every $c \in \mathcal{M}(2)$ satisfies $c \ge 3$.*

*Proof.* If $c \in \mathcal{M}(2)$ were $\le 2$, its witnessing $2$-uniform
non-two-colourable graph would have $\le 2$ edges, contradicting Corollary 7.2.
$\qquad\blacksquare$

### 7.2 The triangle witness

**Definition 7.4.** The **triangle** is the graph on $V = \{0,1,2\}$ with edge
set
$$T = \{\{0,1\}, \{1,2\}, \{0,2\}\}.$$
It is $2$-uniform and has exactly $3$ edges.

**Lemma 7.5.** *The triangle $T$ is non-two-colourable.*

*Proof.* There are $2^{3} = 8$ colourings $R \subseteq \{0,1,2\}$. By symmetry it
suffices to note that any $R$ contains either $\le 1$ or $\ge 2$ of the three
vertices. If $|R| \ge 2$, two vertices are red and the edge joining them is
$\subseteq R$ (all red). If $|R| \le 1$, two vertices are blue and the edge
joining them is disjoint from $R$ (all blue). Either way some edge is
monochromatic. (Exhaustively: $R = \varnothing$ and $R=\{0,1,2\}$ make all edges
mono; each singleton leaves the opposite edge all blue; each pair makes its own
edge all red.) Hence no $R$ is proper. $\qquad\blacksquare$

Thus $3 \in \mathcal{M}(2)$.

### 7.3 The exact value

**Theorem 7.6.** $m(2) = 3$.

*Proof.* By Lemma 7.5, $3 \in \mathcal{M}(2)$, so $m(2) \le 3$. By Corollary 7.3,
every element of $\mathcal{M}(2)$ is $\ge 3$, so $m(2) = \inf\mathcal{M}(2) \ge 3$.
Hence $m(2) = 3$, realised uniquely (up to isomorphism) by the triangle.
$\qquad\blacksquare$

---

## 8. Algorithms

The theory above is constructive and yields three natural procedures.

**8.1 Certifying two-colourability by exhaustive census.** Given a hypergraph on
$N$ vertices, iterate over all $2^{N}$ red sets and return the first that is
proper, or report non-two-colourability. This is the decision procedure behind
Lemma 7.5; it runs in $O(2^{N} \cdot \|H\|)$ time, where $\|H\|$ is the total
edge size, and is exact.

**8.2 The union-bound counting check.** Given $k$ and $|H|$, decide whether the
existence guarantee of Theorem 3.3 applies by testing $|H| < 2^{k-1}$. This is
$O(1)$ arithmetic and returns a *certificate of colourability* without exhibiting
the colouring.

**8.3 Extremal-value search.** To determine $m(k)$ empirically for small $k$,
enumerate candidate $k$-uniform hypergraphs in increasing edge-count order and
test each for non-two-colourability via 8.1, halting at the first
non-two-colourable system. This locates the extremal witness (e.g. the triangle
for $k=2$) and, when combined with the analytic lower bound, certifies the exact
value.

---

## 9. Applications and context

**The probabilistic method.** Theorem 3.3 is the prototypical
positive-probability existence argument. The same union-bound skeleton — bound a
single-event failure probability, sum over polynomially or exponentially many
events, conclude the total is $<1$ — underlies the Erdős–Ramsey lower bound for
diagonal Ramsey numbers, the existence of graphs of high girth and high chromatic
number, and much of coding theory.

**Not-all-equal satisfiability.** A proper two-colouring is precisely a
satisfying assignment of a *not-all-equal SAT* instance in which each clause is an
edge. The extremal function $m(k)$ measures the sparsest unsatisfiable
monotone NAE instance, connecting hypergraph colouring to the phase transitions
of random constraint satisfaction.

**Existence versus construction.** The exponential lower bound $m(k)\ge 2^{k-1}$
is easy and non-constructive; explicit non-two-colourable hypergraphs with few
edges are hard to build, and the exact value of $m(k)$ is open for all
$k \ge 4$. The determination of $m(1)$, $m(2)$, and (classically) $m(3)=7$
illustrates how quickly the difficulty escalates.

---

## 10. Discussion and future work

We have laid an exact, finitary foundation for Property B — two lattice counting
identities and a deterministic union bound — and used it to package the Erdős
extremal function $m(k)$ as a genuine extremal number, determining $m(1)=1$ and
$m(2)=3$. The decisive new step is the sharp $k=2$ lower bound (Theorem 7.1),
which the generic probabilistic argument cannot see. Natural continuations:

1. **$m(3) = 7$ via the Fano plane.** Realise the Fano plane as a $3$-uniform
   hypergraph on $7$ vertices, verify non-two-colourability (upper bound
   $m(3)\le 7$), and prove the matching lower bound by ruling out every
   $3$-uniform system with $\le 6$ edges — a structural/greedy argument
   substantially harder than the $k=2$ case.
2. **Monotonicity and unconditional nonemptiness.** Show $m$ is weakly increasing
   and that the complete $k$-uniform hypergraph on $2k-1$ vertices is
   non-two-colourable, so $\mathcal{M}(k)\ne\varnothing$ for all $k\ge 1$ and the
   lower bound applies unconditionally.
3. **The Radhakrishnan–Srinivasan improvement.** Upgrade the lower bound to
   $m(k)=\Omega\!\big(2^{k}\sqrt{k/\log k}\big)$ through a semi-random colouring
   that flips coins and then locally recolours the few offending edges.
4. **$r$-colourings.** Replace the two-element colour set with $r$ colours,
   swapping the powerset census for an $r$-ary function count to obtain
   $m_r(k) \gtrsim r^{k-1}$.

---

## References (classical)

- F. Bernstein, *Zur Theorie der trigonometrischen Reihe*, 1908.
- P. Erdős, *On a combinatorial problem*, Nordisk Mat. Tidskr., 1963.
- P. Erdős, *On a combinatorial problem II*, Acta Math. Acad. Sci. Hungar., 1964.
- J. Radhakrishnan and A. Srinivasan, *Improved bounds and algorithms for
  hypergraph 2-coloring*, Random Structures & Algorithms, 2000.
