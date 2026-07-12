# Property B for Sparse Uniform Hypergraphs: A Finite Double-Counting Proof of the Erdős Bound $m(k) \ge 2^{k-1}$

## Abstract

A $k$-uniform hypergraph has **Property B** if its vertices can be two-colored
so that no edge is monochromatic. In 1963 Paul Erdős proved that every
$k$-uniform hypergraph with fewer than $2^{k-1}$ edges has Property B, and hence
that the minimum number $m(k)$ of edges in a non-two-colorable $k$-uniform
hypergraph satisfies $m(k) \ge 2^{k-1}$. We present a completely finite,
measure-free development of this result. The engine is a pair of
Boolean-lattice interval identities: over an $N$-element ground set, the number
of subsets containing a fixed $k$-set is $2^{N-k}$, and — by the complementation
involution — the number of subsets disjoint from it is also $2^{N-k}$. A union
bound over the edges then yields Property B directly as a counting inequality:
if the number of monochromatizing colorings summed over all edges is strictly
less than the total number $2^N$ of colorings, a proper coloring must exist. We
give the two interval counts, a per-edge monochromatic bound, the main theorem,
its contrapositive $m(k) \ge 2^{k-1}$, and two concrete corollaries, including
$m(3) \ge 4$. We situate the bound relative to the exact value $m(3) = 7$
(the Fano plane) and the Radhakrishnan–Srinivasan lower bound, and discuss
extensions to the non-uniform and local-lemma settings.

**Keywords:** Property B, hypergraph two-coloring, probabilistic method, union
bound, Boolean lattice, Erdős, first-moment method.

---

## 1. Introduction

The **probabilistic method** proves the existence of a combinatorial object by
placing a probability measure on a family of candidates and showing the desired
object occurs with positive probability. Its earliest and most quotable success
is Erdős's 1963 theorem on the two-colorability of sparse hypergraphs. This
paper gives a self-contained, purely finite account of that theorem in which
every probability is replaced by an exact count of subsets, so that the entire
argument reduces to elementary cardinality identities on the Boolean lattice.

The property in question is named after Felix Bernstein, who introduced it in
1908.

**Definition (informal).** A hypergraph *has Property B* — equivalently, is
*two-colorable* — if there is a two-coloring of its vertices under which no edge
is monochromatic.

Erdős's contribution was quantitative: he pinned down how *sparse* a hypergraph
must be to guarantee Property B, and thereby how *dense* a non-two-colorable one
must be. The key function is

$$m(k) \ :=\ \min\{\,|H| : H \text{ is a } k\text{-uniform hypergraph without Property B}\,\}.$$

The main theorem of this paper is the classical lower bound $m(k) \ge 2^{k-1}$,
proved by a double count that never leaves the finite world.

### 1.1 Historical and conceptual background

The question of two-coloring set systems predates the probabilistic method by
half a century. Bernstein's 1908 study asked, in effect, whether a family of
sets can always be "cut" by a subset that meets every member and omits at least
one point of every member. For finite $k$-uniform families this is exactly the
demand that no edge be swallowed by a single color. The subject lay largely
dormant until Erdős reframed it as a counting problem and, in one stroke,
produced an exponential guarantee valid for all $k$.

What makes the result a landmark is not the numerical bound itself but the
*method*. Rather than exhibiting a good coloring — a task that is genuinely hard
and, for the densest instances, algorithmically subtle — Erdős showed that the
failures are too few to fill the space of possibilities. This inversion, proving
existence by counting non-existence, is the beating heart of the probabilistic
method, and Property B is its cleanest illustration precisely because the
underlying probability space is finite and uniform: every count is an integer,
and no measure theory is required.

We emphasize this finiteness throughout. Where a probabilist would write "the
probability that a random coloring monochromatizes edge $e$ is $2^{1-k}$," we
write "the number of colorings that monochromatize $e$ is $2 \cdot 2^{N-k}$," and
the two statements differ only by the harmless division by $2^N$. Keeping the
development integer-valued makes every step a verifiable statement about the
sizes of explicit finite sets.

### 1.2 Contributions

1. Two Boolean-lattice interval identities (Section 3): over an $N$-element
   ground set the number of subsets containing a fixed $k$-set and the number
   disjoint from it are both $2^{N-k}$, the second obtained from the first by a
   complementation involution.
2. A per-edge monochromatic count (Section 4): a fixed edge of size $k$ is
   monochromatized by at most $2 \cdot 2^{N-k}$ colorings.
3. The Property B theorem and its contrapositive $m(k) \ge 2^{k-1}$ (Section 5).
4. Two corollaries (Section 6): single-edge hypergraphs and the instance
   $m(3) \ge 4$, with context on the exact value $m(3) = 7$.

---

## 2. Definitions

Throughout, $V$ is a finite set of **vertices**, $N := |V|$, and all colorings
and edge families are finite.

**Definition 2.1 (hypergraph, $k$-uniform).** A *hypergraph* on $V$ is a finite
family $H$ of subsets of $V$, called *edges*. It is *$k$-uniform* if every edge
$e \in H$ satisfies $|e| = k$.

**Definition 2.2 (coloring).** A *two-coloring* of $V$ is a subset
$R \subseteq V$; the vertices in $R$ are *red* and those in $V \setminus R$ are
*blue*. There are exactly $2^N$ two-colorings.

**Definition 2.3 (monochromatic edge).** An edge $e$ is *monochromatic* under
$R$ if it is entirely red or entirely blue, i.e. if
$$e \subseteq R \quad \text{or} \quad e \cap R = \varnothing.$$

**Definition 2.4 (proper coloring, Property B).** A coloring $R$ is *proper* for
$H$ if no edge of $H$ is monochromatic; equivalently, for every $e \in H$ we
have $e \not\subseteq R$ and $e \cap R \ne \varnothing$. The hypergraph $H$ is
*two-colorable* — it has *Property B* — if a proper coloring exists.

**Definition 2.5 ($m(k)$).** $m(k)$ is the least number of edges in a
$k$-uniform hypergraph that does not have Property B.

---

## 3. Boolean-lattice interval counts

The entire proof rests on counting subsets of a finite ground set $G$ (in the
application $G = V$) that stand in a fixed relation to a distinguished set $S$.
Write $\mathcal{P}(G)$ for the power set of $G$.

**Lemma 3.1 (superset count).** *Let $S \subseteq G$ with $|G| = N$ and
$|S| = k$. Then*
$$\#\{A \subseteq G : S \subseteq A\} \ =\ 2^{\,N-k}.$$

*Proof.* The map $A \mapsto A \setminus S$ is a bijection between
$\{A \subseteq G : S \subseteq A\}$ and $\mathcal{P}(G \setminus S)$. It is
well-defined because $A \setminus S \subseteq G \setminus S$; it is injective
because $S \subseteq A$ lets us recover $A = (A \setminus S) \cup S$; and it is
surjective because any $B \subseteq G \setminus S$ is the image of
$B \cup S$. Hence the count is $|\mathcal{P}(G \setminus S)| =
2^{|G \setminus S|} = 2^{N-k}$. $\square$

**Lemma 3.2 (disjoint count).** *Under the hypotheses of Lemma 3.1,*
$$\#\{A \subseteq G : A \cap S = \varnothing\} \ =\ 2^{\,N-k}.$$

*Proof.* The complementation map $A \mapsto G \setminus A$ is an involution on
$\mathcal{P}(G)$ that carries the condition "$A$ is disjoint from $S$" to the
condition "$S \subseteq G \setminus A$." It is therefore a bijection between
$\{A : A \cap S = \varnothing\}$ and $\{A : S \subseteq A\}$, and the two sets
have equal cardinality. By Lemma 3.1 that common value is $2^{N-k}$. $\square$

These two identities are exactly the boundary cases needed to count the two ways
an edge can be monochromatic — all red (Lemma 3.1) and all blue (Lemma 3.2).

---

## 4. The per-edge monochromatic bound

Fix the ground set $G = V$, so $N = |V|$, and consider a single edge $e$ with
$|e| = k$.

**Lemma 4.1 (per-edge count).** *For any edge $e$ with $|e| = k$, the number of
colorings $R \subseteq V$ that make $e$ monochromatic satisfies*
$$\#\{R \subseteq V : e \subseteq R \text{ or } e \cap R = \varnothing\}
\ \le\ 2^{\,N-k} + 2^{\,N-k} \ =\ 2\cdot 2^{\,N-k}.$$

*Proof.* The set of monochromatizing colorings is the union of two sets: those
with $e \subseteq R$ (all red) and those with $e \cap R = \varnothing$ (all
blue). By the subadditivity of cardinality under union,
$$\#\{R : e \subseteq R \text{ or } e \cap R = \varnothing\}
\le \#\{R : e \subseteq R\} + \#\{R : e \cap R = \varnothing\}.$$
Lemma 3.1 bounds the first summand by $2^{N-k}$ and Lemma 3.2 bounds the second
by $2^{N-k}$. $\square$

The two constituent sets are in fact disjoint whenever $e \ne \varnothing$ (an
edge cannot be simultaneously all red and all blue), so for genuine edges the
bound is an equality; the inequality form is all we require and is robust to the
degenerate case $e = \varnothing$.

---

## 5. Property B for sparse hypergraphs

We now assemble the union bound.

**Theorem 5.1 (Property B for sparse hypergraphs).** *Let $H$ be a $k$-uniform
hypergraph on a finite vertex set $V$ with*
$$|H| \ <\ 2^{\,k-1}.$$
*Then $H$ is two-colorable.*

*Proof.* Suppose, for contradiction, that $H$ has no proper coloring. Then every
coloring $R \subseteq V$ is *bad*: it makes at least one edge monochromatic.
Equivalently, the power set $\mathcal{P}(V)$ is covered by the family of
"bad-for-$e$" sets,
$$\mathcal{P}(V) \ =\ \bigcup_{e \in H} \{R \subseteq V : e \subseteq R \text{ or } e \cap R = \varnothing\}.$$
Taking cardinalities and applying the union bound followed by Lemma 4.1,
$$2^{N} \ =\ |\mathcal{P}(V)|
\ \le\ \sum_{e \in H} \#\{R : e \subseteq R \text{ or } e \cap R = \varnothing\}
\ \le\ \sum_{e \in H} 2\cdot 2^{\,N-k}
\ =\ |H|\cdot 2^{\,N-k+1}.$$
Now use $k$-uniformity and the sparsity hypothesis. If $|H| < 2^{k-1}$ then
$$|H|\cdot 2^{\,N-k+1} \ <\ 2^{\,k-1}\cdot 2^{\,N-k+1} \ =\ 2^{\,N}.$$
Chaining the last two displays gives $2^N \le |H|\cdot 2^{N-k+1} < 2^N$, a
contradiction. Hence some coloring is not bad; that coloring is proper, and $H$
is two-colorable. $\square$

A remark on the arithmetic: the exponent bookkeeping $2^{k-1}\cdot 2^{N-k+1} =
2^{N}$ requires $k \ge 1$ and $k \le N$ so that $N-k+1 \ge 0$; in the
application both hold because a nonempty edge of a non-two-colorable $k$-uniform
hypergraph forces $1 \le k \le N$. When $k = 0$ the hypothesis
$|H| < 2^{-1} = 0$ (in the integer sense $|H| < 2^{0-1} = 2^0 \text{ truncated}$)
is handled degenerately: the empty hypergraph is vacuously two-colorable.

**Theorem 5.2 (contrapositive; the Erdős bound).** *If a $k$-uniform hypergraph
$H$ is not two-colorable, then $|H| \ge 2^{k-1}$. Consequently*
$$m(k) \ \ge\ 2^{\,k-1}.$$

*Proof.* Immediate from Theorem 5.1: if $|H| < 2^{k-1}$ then $H$ would be
two-colorable, contrary to assumption. Taking the minimum over all
non-two-colorable $k$-uniform hypergraphs gives $m(k) \ge 2^{k-1}$. $\square$

---

## 6. Corollaries and concrete instances

**Corollary 6.1 (single edge).** *A hypergraph consisting of a single edge $e$
with $|e| \ge 2$ is two-colorable.*

*Proof.* Because $|e| \ge 2$, the edge contains two distinct vertices $v \ne w$.
Color $R = \{w\}$: then $w \in e \cap R$ so $e \cap R \ne \varnothing$ (not all
blue), and $v \in e \setminus R$ so $e \not\subseteq R$ (not all red). Thus $e$
is not monochromatic and $R$ is proper. $\square$

The hypothesis $|e| \ge 2$ cannot be removed: a single vertex edge $e = \{v\}$
is monochromatic under *every* coloring (it is all red if $v \in R$ and all blue
otherwise), so a one-vertex edge is never two-colorable. This is also visible in
Theorem 5.1, whose bound $2^{k-1}$ equals $2^0 = 1$ when $k = 1$, offering no
room for even a single edge.

**Corollary 6.2 ($m(3) \ge 4$).** *Every $3$-uniform hypergraph with at most $3$
edges is two-colorable.*

*Proof.* Apply Theorem 5.1 with $k = 3$: the threshold is $2^{k-1} = 2^2 = 4$,
so any $H$ with $|H| \le 3 < 4$ is two-colorable. $\square$

**Sharpness for $k = 3$.** Corollary 6.2 is not tight. The extremal
non-two-colorable $3$-uniform hypergraph is the **Fano plane**: seven points,
seven lines, each line a triple, arranged so that every two-coloring produces a
monochromatic line. It has seven edges, and it is a classical fact that no
$3$-uniform hypergraph with six or fewer edges fails Property B. Hence
$$m(3) = 7,$$
comfortably exceeding the general lower bound of $4$. The counting proof
sacrifices tightness for uniformity: it produces an exponential lower bound for
*every* $k$ in a single stroke.

---

## 7. Algorithmic content

Although Theorem 5.1 is an existence statement, its proof is constructive in a
weak sense and suggests two practical procedures.

**Random sampling / expected-value witness.** Divide the counting inequality by
$2^N$. A uniformly random coloring makes a fixed edge $e$ monochromatic with
probability $2^{-(k-1)}$, so the expected number of monochromatic edges is
$|H|\cdot 2^{-(k-1)} < 1$ when $|H| < 2^{k-1}$. Since a nonnegative
integer-valued random variable with expectation below $1$ must sometimes be
zero, a single random coloring is proper with positive probability; sampling
colorings uniformly at random yields a proper one in $O(2^{k-1}/(2^{k-1}-|H|))$
expected trials.

**Method of conditional expectations (derandomization).** One can fix the color
of the vertices one at a time, always choosing the color that keeps the
conditional expected number of monochromatic edges below $1$. This converts the
probabilistic guarantee into a deterministic polynomial-time algorithm producing
a proper coloring, without any randomness. It is the algorithmic shadow of the
same first-moment inequality.

---

## 7.1 A worked probabilistic reformulation

It is instructive to run the argument once in explicitly probabilistic language,
to see that nothing is lost or gained. Equip the set of all colorings with the
uniform probability measure, so each of the $2^N$ colorings has probability
$2^{-N}$. For an edge $e$ with $|e| = k$, let $A_e$ be the event that $e$ is
monochromatic. By Lemma 4.1,
$$\Pr[A_e] = \frac{2 \cdot 2^{N-k}}{2^N} = 2^{\,1-k}.$$
Let $X = \sum_{e \in H} \mathbf{1}_{A_e}$ count the monochromatic edges. By
linearity of expectation,
$$\mathbb{E}[X] = \sum_{e \in H} \Pr[A_e] = |H| \cdot 2^{\,1-k}.$$
If $|H| < 2^{k-1}$ then $\mathbb{E}[X] < 1$. Since $X$ is a nonnegative
integer-valued random variable, $\mathbb{E}[X] < 1$ forces $\Pr[X = 0] > 0$: with
positive probability *no* edge is monochromatic, and any coloring witnessing
$X = 0$ is proper. This is the *first-moment method*, and it is identical to
Section 5 after multiplying through by $2^N$.

The probabilistic phrasing also clarifies *why* the threshold is exactly
$2^{k-1}$ and not, say, $2^k$: each edge has two "forbidden" colorings-per-scale
(all red and all blue) out of $2^k$ local color patterns on its $k$ vertices, so
the per-edge failure probability is $2/2^k = 2^{1-k}$, and the expected count
crosses $1$ exactly at $|H| = 2^{k-1}$.

## 7.2 Comparison of the bounds on $m(k)$

The table below records the small-$k$ landscape. The column "lower bound" is the
value $2^{k-1}$ proved here; "exact/known" records the true value where it is
known or the best current interval.

| $k$ | lower bound $2^{k-1}$ | exact or best known $m(k)$ |
|-----|------------------------|-----------------------------|
| $1$ | $1$ | $1$ (a single vertex-edge) |
| $2$ | $2$ | $3$ (an odd cycle, e.g. a triangle of edges) |
| $3$ | $4$ | $7$ (the Fano plane) |
| $4$ | $8$ | $23$ |
| $k$ (asymptotic) | $2^{k-1}$ | between $\Omega(2^k\sqrt{k/\ln k})$ and $O(2^k k^2)$ |

For $k = 2$ the hypergraph is an ordinary graph and Property B is exactly
bipartiteness; the smallest non-bipartite graph is the triangle with three
edges, giving $m(2) = 3$ against the lower bound of $2$. The steady widening of
the gap as $k$ grows is the quantitative signature of how much the crude union
bound leaves on the table, and it is the engine of the open problem in
Section 8.

## 8. Discussion and related work

Property B sits at the origin of the probabilistic method and remains a live
research topic because the exact growth of $m(k)$ is unknown. The lower bound
established here, $m(k) \ge 2^{k-1}$, is the original 1963 estimate. The best
known bounds bracket $m(k)$ between roughly $2^k\sqrt{k/\ln k}$ (from below,
Radhakrishnan–Srinivasan 2000, via a random *recoloring* refinement of the union
bound) and $O(2^k k^2)$ (from above, via explicit or random constructions of
non-two-colorable hypergraphs). Determining the true order of magnitude is a
long-standing open problem.

The result is a paradigm case of the **first-moment method**: to show a
"bad-event" configuration is avoidable, bound the expected number of bad events
and observe that an expectation below $1$ forces a bad-event-free outcome. The
same skeleton underlies Erdős's counting lower bound for diagonal Ramsey
numbers, and the two theorems together form complementary pillars of the
elementary probabilistic method.

### 8.1 Applications and interpretations

The two-coloring condition is a template that recurs across applied mathematics.
In distributed computing, splitting tasks between two servers so that no critical
group of jobs lands entirely on one machine is a Property B instance; the bound
$m(k) \ge 2^{k-1}$ says that conflicts must be numerous — exponentially many in
the group size — before a balanced assignment becomes impossible. In circuit
design, partitioning components across two chips while keeping every functional
module split is the same problem. In discrepancy theory and derandomization,
Property B is the seed example that motivates the entire study of balancing set
systems with $\pm 1$ signs. And in the theory of random constraint satisfaction,
the sharp appearance of unsatisfiability as constraints accumulate — the
satisfiability threshold phenomenon — is the probabilistic descendant of the
crossover at $|H| = 2^{k-1}$ made visible here: below the threshold the system is
overwhelmingly likely to be satisfiable, above it, not.

A final interpretive remark: the equality of the all-red and all-blue counts,
which we obtained from the complementation involution $R \mapsto V \setminus R$,
is the color-symmetry of the problem made quantitative. Any argument for Property
B must respect this symmetry, and the cleanest ones — like the one here — build
it in from the start rather than breaking it.

---

## 9. Future directions

- **Sharpen the bound.** Establish the Radhakrishnan–Srinivasan improvement
  $m(k) = \Omega\!\big(2^k \sqrt{k/\ln k}\big)$ via the random-recoloring
  argument, or an easier alteration bound obtained by deleting a vertex from
  each bad edge.
- **Non-uniform Property B.** Generalize Theorem 5.1 to hypergraphs with edges
  of varying sizes, replacing the edge count by the weighted condition
  $\sum_{e \in H} 2^{\,1-|e|} < 1$, which reduces to $|H| < 2^{k-1}$ in the
  uniform case.
- **Local Lemma route.** Combine with the Lovász Local Lemma to obtain Property
  B under a *degree* condition — each edge intersecting few others — rather than
  a global edge-count condition. The symmetric Local Lemma gives two-colorability
  when each edge meets at most about $2^{k-3}$ others.
- **Upper bounds and constructions.** Establish the Fano plane as the extremal
  non-two-colorable $3$-uniform hypergraph, giving $m(3) = 7$ and matching the
  lower-bound direction with an explicit construction.

---

## 10. Conclusion

Property B distills the probabilistic method to its purest form. By replacing
probabilities with exact subset counts, we obtain a fully finite proof that a
$k$-uniform hypergraph with fewer than $2^{k-1}$ edges is two-colorable, and
hence that $m(k) \ge 2^{k-1}$. The argument is short, robust, and general — a
single union bound over the edges — and it seeds a family of derandomizable
algorithms for producing proper colorings. Sixty years after its discovery it
remains both a teaching example and a frontier, with the true growth rate of
$m(k)$ still open.
