# The Maximum-Overlap Law for Register Allocation: An Exact Chromatic Formula on Interval Interference Graphs

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

Register allocation — the assignment of program variables to a fixed bank of processor
registers — is classically modeled as coloring the *interference graph* $G$, whose vertices
are variables and whose edges connect variables that are simultaneously live. In this
generality, computing the chromatic number $\chi(G)$ is NP-hard, and a natural conjectured
formula $\chi(G) = \max(\Delta(G)+1,\ \omega(G))$ — relating the chromatic number to the
maximum degree $\Delta$ and the clique number $\omega$ — is *false* (the Petersen graph is a
counterexample: $\Delta+1 = 4$, $\omega = 2$, but $\chi = 3$). We show that the interference
graphs arising from the standard linear-scan compilation pipeline, in which every variable
occupies a single contiguous live range, are *interval graphs* and hence *perfect*, and on
this class an exact and efficiently computable law holds. Writing $D$ for the **maximum
overlap** — the largest number of variables simultaneously live at any single program point —
we prove
$$\chi(G) = \omega(G) = D.$$
The engine of the proof is the one-dimensional case of Helly's theorem: any set of pairwise
overlapping intervals shares a common point, namely the maximum of their left endpoints. This
converts each clique into a concrete "deep" program point, identifying the abstract clique
number with the linearly computable maximum overlap. We further show $D \le \Delta + 1$,
exhibiting the overlap law as a strict sharpening of the classical greedy degree bound
$\chi \le \Delta+1$, and we derive the optimality of linear-scan register allocation: $D$
registers always suffice, via a greedy coloring in a latest-start-first perfect elimination
order, and $D$ registers are necessary. We discuss the geometric reformulation of spilling and
outline extensions to spill minimization, degree-based spill approximation, and SSA
destruction.

## 1. Introduction

A processor executes arithmetic on a small set of registers — sixteen to thirty-two on typical
architectures — while programs routinely manipulate hundreds or thousands of variables. The
compiler's *register allocator* decides which variables reside in registers, which must be
kept in slower memory (*spilled*), and how registers are time-shared among variables whose
lifetimes do not conflict. This is one of the most performance-critical phases of compilation.

The dominant abstraction, due to Chaitin and refined by many, is **graph coloring**. Build a
graph $G$ with one vertex per variable, joining two vertices when the corresponding variables
*interfere* — that is, when both are simultaneously *live* at some program point. A legal
register assignment using $k$ registers is exactly a proper $k$-coloring of $G$: interfering
variables (adjacent vertices) receive distinct registers (colors). The minimum number of
registers needed without spilling is the chromatic number $\chi(G)$.

For general graphs $\chi(G)$ is NP-hard to compute, and one is tempted to seek a closed-form
proxy. Two classical bounds frame the answer:

- **Greedy upper bound.** $\chi(G) \le \Delta(G) + 1$, where $\Delta(G)$ is the maximum
  degree, because a one-at-a-time coloring never faces more than $\Delta$ forbidden colors.
- **Clique lower bound.** $\chi(G) \ge \omega(G)$, where $\omega(G)$ is the size of the largest
  set of pairwise-adjacent vertices, since a clique needs one color per vertex.

A seductive conjecture unifies these into $\chi(G) = \max(\Delta(G)+1,\ \omega(G))$. **This is
false in general.** The Petersen graph is $3$-regular ($\Delta + 1 = 4$) and triangle-free
($\omega = 2$), yet $3$-colorable ($\chi = 3$); the formula predicts $4$. No degree-and-clique
formula captures $\chi$ on arbitrary graphs.

The resolution is to exploit the structure of *real* interference graphs. Under the widely used
**linear-scan** discipline, and more generally whenever each variable is live across a single
contiguous span of program points, the interference graph is an **interval graph**: variables
are line segments (their live ranges) and edges record overlaps. Interval graphs are chordal,
hence perfect, so $\chi(G) = \omega(G)$ exactly. Our contribution is to make this concrete and
computational: we identify $\omega(G)$ with the geometric **maximum overlap** $D$ and derive
the full chain $\chi(G) = \omega(G) = D$, together with algorithmic optimality and a sharpened
degree bound.

### Contributions

1. A formal model of contiguous live ranges, their interference graph, and the depth/overlap
   functions (Section 3).
2. A one-dimensional Helly property in clique form: every clique of live ranges is contained in
   a single live set (Section 4), yielding $\omega(G) = D$.
3. Optimality of linear-scan allocation: $D$ registers suffice via a latest-start-first greedy
   coloring, and $D$ registers are necessary (Section 5), giving $\chi(G) = \omega(G) = D$.
4. The refinement $D \le \Delta + 1$, exhibiting the overlap law as strictly stronger than the
   greedy bound (Section 6).
5. A geometric reformulation of spilling and a research program of conjectures (Sections 7–8).

## 2. Related framing and the failed general formula

The maximum-degree bound $\chi \le \Delta+1$ and its Brooks refinement are foundational graph
theory; the clique bound $\chi \ge \omega$ is elementary. Their combination
$\chi = \max(\Delta+1, \omega)$ is attractive because it would make register counts
computable from two cheap statistics. The Petersen graph refutes it decisively. This failure is
not a technicality: it reflects the genuine hardness of $\chi$ on arbitrary graphs, where local
degree and clique data underdetermine the global coloring number.

The escape is to restrict the graph class. Perfect graphs — those for which $\chi(H) = \omega(H)$
for every induced subgraph $H$ — turn the lower bound into an equality. Interval graphs are a
classical, algorithmically friendly subclass of perfect graphs, and they are exactly the
interference graphs of contiguous-live-range programs. On this class we obtain a fully explicit
law.

## 3. Model and definitions

Fix a finite set of variables indexed by $\{0, 1, \dots, n-1\}$. Each variable $i$ has a
**live range** $[\ell_i, h_i]$ with integer endpoints, given by functions
$\ell, h : \{0,\dots,n-1\} \to \mathbb{N}$. We assume the well-formedness condition
$\ell_i \le h_i$ for all $i$ (a variable is born no later than it dies).

**Definition 3.1 (Liveness).** Variable $i$ is *live* at program point $t \in \mathbb{N}$ if
$\ell_i \le t \le h_i$.

**Definition 3.2 (Interference).** Distinct variables $i \ne j$ *interfere* if their live
ranges overlap:
$$\ell_i \le h_j \quad\text{and}\quad \ell_j \le h_i.$$
Interference is symmetric.

**Definition 3.3 (Interference graph).** The interference graph $G = G(\ell, h)$ is the simple
graph on vertex set $\{0,\dots,n-1\}$ with $i \sim j$ iff $i$ and $j$ interfere.

**Definition 3.4 (Live set and depth).** The *live set* at $t$ is
$L(t) = \{\, i : \ell_i \le t \le h_i \,\}$. The *depth* at $t$ is $\mathrm{depth}(t) = |L(t)|$,
the number of variables simultaneously live at $t$.

**Definition 3.5 (Maximum overlap).** The *maximum overlap* is
$$D \;=\; \max_{i} \ \mathrm{depth}(\ell_i),$$
the largest depth taken over the start points of the live ranges. (Because depth is piecewise
constant and can only increase at a start point, this equals the maximum depth over *all*
program points; restricting to start points makes $D$ computable by a single scan.)

A **proper $k$-coloring** assigns to each variable one of $k$ colors so that interfering
variables differ; the least such $k$ is the chromatic number $\chi(G)$. The **clique number**
$\omega(G)$ is the maximum size of a set of pairwise-interfering variables.

## 4. The one-dimensional Helly property and $\omega(G) = D$

The first structural fact is that a live set is always a clique.

**Lemma 4.1 (Live sets are cliques).** For every program point $t$, the live set $L(t)$ is a
clique of $G$.

*Proof sketch.* If $i, j \in L(t)$ are distinct, then $\ell_i \le t \le h_i$ and
$\ell_j \le t \le h_j$. Hence $\ell_i \le t \le h_j$ and $\ell_j \le t \le h_i$, which are
exactly the interference inequalities. So $i \sim j$. $\square$

Consequently $\mathrm{depth}(t) = |L(t)| \le \omega(G)$ for every $t$, and in particular
$D \le \omega(G)$. The converse — that every clique is confined to a single live set — is the
crux, and it is where one dimension works a small miracle.

**Theorem 4.2 (One-dimensional Helly property, clique form).** Let $S$ be a nonempty clique of
$G$. Let $m \in S$ maximize the start point, i.e. $\ell_m = \max_{i \in S} \ell_i$. Then every
member of $S$ is live at the point $\ell_m$; that is, $S \subseteq L(\ell_m)$.

*Proof sketch.* Fix $i \in S$. If $i = m$, then $\ell_m \le \ell_m \le h_m$ by
well-formedness, so $m \in L(\ell_m)$. If $i \ne m$, then $i \sim m$ because $S$ is a clique,
so the interference inequalities give $\ell_m \le h_i$. Combined with
$\ell_i \le \ell_m$ (maximality of $\ell_m$), we obtain $\ell_i \le \ell_m \le h_i$, i.e.
$i \in L(\ell_m)$. Thus $S \subseteq L(\ell_m)$. $\square$

The geometric content is precisely Helly's theorem in dimension one: *pairwise* overlapping
intervals share a *common* point, and that point is the maximum of the left endpoints. The gap
between "pairwise" and "common" — real in two or more dimensions — collapses on the line.

**Corollary 4.3 (Perfectness bound).** Every clique $S$ satisfies $|S| \le D$.

*Proof sketch.* By Theorem 4.2, $S \subseteq L(\ell_m)$ for some $m \in S$, so
$|S| \le |L(\ell_m)| = \mathrm{depth}(\ell_m) \le D$. The empty clique satisfies the bound
trivially. $\square$

**Theorem 4.4 (Clique number equals maximum overlap).** $\omega(G) = D$.

*Proof sketch.* Corollary 4.3 gives $\omega(G) \le D$. For the reverse, choose $m$ attaining
$D = \mathrm{depth}(\ell_m)$; by Lemma 4.1 the set $L(\ell_m)$ is a clique of size exactly $D$,
so $\omega(G) \ge D$. Hence equality, and the maximum is genuinely attained — this is a real
clique, not a definitional artifact. $\square$

## 5. Linear-scan optimality: $\chi(G) = D$

We now show that the geometric lower bound is also achievable, so the chromatic number equals
the maximum overlap.

**Theorem 5.1 (Sufficiency / linear-scan optimality).** The interference graph $G$ is
$D$-colorable: $D$ registers always suffice.

*Proof sketch.* Process the variables in a **latest-start-first** order (a perfect elimination
ordering). Formally, induct on the vertex set: at each step remove a vertex $m$ with the
maximum start point among the remaining vertices, color the rest by the inductive hypothesis,
and assign $m$ a free color. The already-colored interfering neighbors $N$ of $m$ all overlap
$m$ and have start points $\le \ell_m$; by the Helly argument each is live at $\ell_m$, so
$N \subseteq L(\ell_m) \setminus \{m\}$, whence
$$|N| \le \mathrm{depth}(\ell_m) - 1 \le D - 1 < D.$$
Fewer than $D$ colors are forbidden, so among $D$ colors one is free for $m$. Induction
completes a proper $D$-coloring. (The degenerate cases $n = 0$ and $n = 1$ are handled directly:
$D = 0$ with no vertices, and $D = 1$ with a single vertex.) $\square$

**Theorem 5.2 (Necessity).** Any proper coloring uses at least $D$ colors; i.e.
$\omega(G) \ge D$ forces $\chi(G) \ge D$.

*Proof sketch.* By Theorem 4.4 there is a clique of size $D$; its vertices are pairwise
interfering and so require $D$ distinct colors. Formally, a proper coloring restricted to a
$D$-clique is injective, so the image has $D$ colors. $\square$

**Theorem 5.3 (Maximum-overlap law).** For any contiguous-live-range program,
$$\chi(G) = \omega(G) = D.$$

*Proof sketch.* Theorem 5.1 gives $\chi(G) \le D$; Theorem 5.2 gives $\chi(G) \ge D$, so
$\chi(G) = D$. Combined with Theorem 4.4, $\chi(G) = \omega(G) = D$. This is the perfectness of
interval graphs made explicit and computational. $\square$

The algorithmic upshot: the optimal register count is computed by a single left-to-right scan
that tracks the current depth and reports its maximum, and an optimal assignment is produced by
the same scan in latest-start-first order.

## 6. Refining the greedy degree bound: $D \le \Delta + 1$

The classical guarantee $\chi \le \Delta + 1$ is recovered — and sharpened — by the overlap
law.

**Theorem 6.1.** $D \le \Delta(G) + 1$, where $\Delta(G)$ is the maximum degree of $G$.

*Proof sketch.* By Theorem 4.4 there is a clique $S$ with $|S| = D$. If $D = 0$ the bound is
trivial. Otherwise pick any $v \in S$; the other $D - 1$ members of $S$ are all neighbors of
$v$, so $\deg(v) \ge D - 1$, whence $\Delta(G) \ge D - 1$, i.e. $D \le \Delta(G) + 1$. $\square$

Since $\chi(G) = D$, this yields $\chi(G) \le \Delta(G) + 1$ as a corollary, but with a precise
accounting of the slack: the greedy bound is tight only when the deepest overlap already
saturates the neighborhood of one of its members. On typical programs $D$ is substantially
smaller than $\Delta + 1$, explaining why realistic code fits comfortably into modest register
banks and why the greedy bound alone is pessimistic.

## 7. Spilling as a one-dimensional covering problem

When the register budget $k$ is smaller than $D$, no proper $k$-coloring exists and some
variables must be spilled to memory. The overlap law recasts this. Define the **excess
profile** as the pointwise shortfall $\max(\mathrm{depth}(t) - k,\ 0)$. Every program point of
depth exceeding $k$ is *over-full* and must lose variables until its depth drops to $k$. Because
live ranges are intervals, a single eviction removes a variable from an entire contiguous run
of points at once, so relieving congestion is a covering problem on the line rather than an
opaque graph problem.

This viewpoint clarifies the classical **degree-based spilling** heuristic (repeatedly evict
the maximum-degree variable). On interval graphs, a vertex's degree is dominated by the depths
at its two endpoints; the maximum-degree variable therefore lies near a deepest, most congested
point — precisely where relief is most needed. The overlap law makes "degree" and "depth"
quantitatively comparable, opening the door to provable approximation guarantees (Section 8).

## 8. Discussion and future directions

The narrative is a clean instance of a recurring phenomenon: a problem that is intractable in
full generality becomes exactly solvable once the structure of real instances is recognized.
Register allocation is NP-hard as arbitrary graph coloring and resists any clean
degree-and-clique formula (Petersen), yet on the interval graphs produced by contiguous live
ranges it obeys the exact law $\chi = \omega = D$, with $D$ computable by one scan.

We record four testable directions.

**1. Spill minimization is governed by the overlap profile.** When $k < D$, the minimum number
of spilled variables should equal the total excess area of the overlap profile,
$\sum_t \max(\mathrm{depth}(t) - k, 0)$ appropriately counted over maximal over-full runs, with
an optimal spill set chosen greedily by evicting a variable spanning a deepest over-full point.
The exact $\chi = \omega = D$ identity turns spilling into a purely geometric question about the
depth function.

**2. Degree-based spilling is within a constant factor of optimal.** Repeatedly evicting the
maximum-degree vertex should yield a spill set of cost at most twice the optimum on interval
graphs, and this factor should be tight, because a vertex's degree is dominated by the depths at
its endpoints, tying the heuristic to the geometric congestion it relieves.

**3. SSA destruction preserves perfectness up to bounded blow-up.** Converting out of static
single assignment form (inserting copies at $\phi$-nodes) should increase the maximum overlap by
at most the maximum $\phi$-arity, and the interference graph should remain perfect when copies
are coalesced along a chordal schedule, since $\phi$-resolution only splices intervals at
basic-block boundaries and refines rather than tangles the interval structure.

**4. The overlap law fails exactly at the first non-interval obstruction.** Characterizing the
minimal structural feature (e.g. non-contiguous live ranges from control-flow merges) at which
the interference graph ceases to be an interval graph would pinpoint precisely when $\chi = D$
first breaks, marking the boundary of the exact regime.

## 9. Conclusion

For programs whose variables occupy contiguous live ranges — the regime of linear-scan
allocation and much of practical compilation — the interference graph is an interval graph, and
its chromatic number, clique number, and maximum live-range overlap coincide:
$$\chi(G) = \omega(G) = D.$$
The optimal number of registers is exactly the maximum number of simultaneously live variables,
attained by a single left-to-right scan; spilling is forced precisely when the register budget
drops below this overlap. The result sharpens the classical greedy bound $D \le \Delta + 1$ and
rests on the one-dimensional Helly property, which turns pairwise interval overlap into a common
witness point. What is intractable for arbitrary graphs becomes, for the line, a matter of
counting the tallest stack.
