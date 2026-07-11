# Chordal Interference Graphs Are Perfect: Optimal Register Allocation for SSA Programs

**Author:** Aristotle
**Date:** 2026-07-11
**Domain:** Bridges (Combinatorics ↔ Compiler Optimization)

## Abstract

Register allocation — the compiler task of mapping program variables to a fixed bank of CPU registers — is equivalent to properly coloring the *interference graph* $G$, whose vertices are variables and whose edges join variables that are simultaneously live. In general graph coloring is NP-hard and the chromatic number $\chi(G)$ may exceed the clique number $\omega(G)$ by an unbounded margin. We give a self-contained development of the structural fact that rescues register allocation in practice: interference graphs of programs in Static Single Assignment (SSA) form are **chordal**, and chordal graphs are **perfect**. Concretely, we prove that if a graph admits a *perfect elimination ordering* (PEO) then $\chi(G) = \omega(G)$, that a greedy sweep along the order realizes the optimum, and that the earlier-degree of every vertex is strictly below $\omega(G)$. We recover the classical linear-scan (interval-graph) theory as a strict special case: interval interference graphs sorted by live-range start point admit a PEO, so their chromatic number likewise equals their clique number. The upshot is a clean bridge: the minimum number of registers for an SSA program equals the maximum number of simultaneously live variables, and this optimum is attained by an efficient greedy algorithm.

## 1. Introduction

A central optimization in every compiler is **register allocation**: the assignment of the (potentially thousands of) variables appearing in a program to the small, fixed set of hardware registers (commonly 16 or 32) available on the target processor. Values that cannot be kept in registers must be *spilled* to memory, incurring substantial runtime cost. Producing an assignment that uses as few registers as possible — and, when the register budget is exceeded, spills as little as possible — is therefore of enormous practical importance.

Chaitin's foundational insight is that register allocation is a graph coloring problem. Two variables may share a register if and only if they are never *live* (needed for a future use) at the same time. Encoding "simultaneously live" as adjacency yields the **interference graph** $G$; a legal register assignment using $k$ registers is exactly a proper $k$-coloring of $G$, and the optimal register count is the **chromatic number** $\chi(G)$.

For arbitrary graphs this is discouraging: computing $\chi(G)$ is NP-complete, and $\chi(G)$ can be arbitrarily larger than the obvious lower bound $\omega(G)$, the size of the largest clique. The resolution comes from *structure*. When a program is expressed in **Static Single Assignment (SSA)** form — the dominant modern intermediate representation, in which every variable is assigned exactly once — the interference graph is **chordal**. Chordal graphs form one of the classical families of **perfect graphs**, for which $\chi(H) = \omega(H)$ holds on every induced subgraph, and for which coloring is solvable in polynomial time.

This paper presents a rigorous, self-contained account of the core structural theorem — *chordal graphs are perfect* — phrased in the order-theoretic language of perfect elimination orderings that is most natural for the compiler application, together with its specialization to interval graphs (linear-scan allocation).

### Contributions

1. A **greedy coloring lemma** (Section 3): if every vertex has fewer than $k$ earlier neighbors in a fixed vertex order, then $G$ is $k$-colorable. This requires no chordality.
2. A proof that under a PEO, **each vertex together with its earlier neighbors is a clique**, whence the earlier-degree of every vertex is strictly less than $\omega(G)$ (Section 4).
3. The **optimality theorem**: a graph with a PEO is $\omega(G)$-colorable, and therefore $\chi(G) = \omega(G)$ — *chordal graphs are perfect* (Section 5).
4. The **interval-graph corollary**: interval interference graphs admit a PEO (sort by live-range start), so $\chi = \omega$ for them as a special case; interval $\subsetneq$ chordal (Section 6).

## 2. Preliminaries and definitions

We work with finite simple graphs on the vertex set $\{1, 2, \dots, n\}$, equipped with its natural linear order, which serves as our fixed elimination order. Let $G$ be such a graph with adjacency relation written $u \sim v$ (symmetric, irreflexive).

**Definition 2.1 (Proper coloring, chromatic number).** A *proper $k$-coloring* is a map $c$ from vertices to a set of $k$ colors such that $u \sim v \implies c(u) \ne c(v)$. The *chromatic number* $\chi(G)$ is the least $k$ for which a proper $k$-coloring exists.

**Definition 2.2 (Clique, clique number).** A set $S$ of vertices is a *clique* if every two distinct members are adjacent. The *clique number* $\omega(G)$ is the size of the largest clique.

Every clique of size $k$ forces $k$ distinct colors, giving the universal bound
$$\chi(G) \ge \omega(G). \tag{2.1}$$

**Definition 2.3 (Earlier neighbors).** For a vertex $v$, its set of *earlier neighbors* is
$$N^-(v) = \{\, w : w < v \text{ and } w \sim v \,\}.$$
The *earlier-degree* of $v$ is $|N^-(v)|$.

**Definition 2.4 (Perfect elimination ordering).** The linear order on the vertices is a *perfect elimination ordering* (PEO) if, for every vertex $v$, the earlier-neighbor set $N^-(v)$ is a clique. A graph is **chordal** precisely when it admits a PEO under some ordering of its vertices. (Equivalently, chordal means every cycle of length $\ge 4$ has a chord; the two formulations are classically equivalent, and we adopt the ordering form because it is the one that drives the coloring algorithm.)

Throughout, we assume the given order *is* a PEO where stated, and prove consequences from that hypothesis.

## 3. The greedy coloring lemma

The engine of the whole development is a bound that has nothing to do with chordality: it is purely about processing vertices in order.

**Lemma 3.1 (Greedy coloring).** *Fix the linear order on the $n$ vertices. If $|N^-(v)| < k$ for every vertex $v$, then $G$ is $k$-colorable.*

**Proof sketch.** We produce a coloring $c : \{1,\dots,n\} \to \{0,\dots,k-1\}$ such that $c(v) \ne c(w)$ whenever $w \in N^-(v)$. Argue by strong induction on the set $S$ of vertices to be colored. If $S$ is empty, any assignment works. Otherwise let $m$ be the *maximum* element of $S$. By induction, color $S \setminus \{m\}$; in particular its restriction colors $N^-(m) \subseteq S \setminus \{m\}$. The image $c(N^-(m))$ has at most $|N^-(m)| < k$ colors, so among the $k$ available colors at least one, say $c_0$, is unused on $N^-(m)$. Extend by setting $c(m) = c_0$. Since $m$ is the maximum, no vertex has $m$ as an *earlier* neighbor, so recoloring $m$ cannot violate any other constraint; and $c(m) \ne c(w)$ for all $w \in N^-(m)$ by choice of $c_0$. This proves the induction step.

Finally, a coloring respecting all earlier-neighbor constraints is a *proper* coloring: for any edge $u \sim v$ with, say, $u < v$, we have $u \in N^-(v)$, so $c(u) \ne c(v)$. $\blacksquare$

Note the lemma gives $\chi(G) \le 1 + \max_v |N^-(v)|$ for *any* ordering — the "degeneracy" bound. The power of a PEO is that it makes $\max_v |N^-(v)|$ as small as it can possibly be, namely $\omega(G) - 1$.

## 4. Earlier neighbors form cliques under a PEO

**Lemma 4.1 (Closed earlier-neighborhoods are cliques).** *If the order is a PEO, then for every vertex $v$ the set $\{v\} \cup N^-(v)$ is a clique.*

**Proof sketch.** By the PEO hypothesis, $N^-(v)$ is a clique, so any two distinct earlier neighbors are adjacent. It remains to check that $v$ is adjacent to each $w \in N^-(v)$ — but that is the definition of $N^-(v)$ (its members are neighbors of $v$). Hence all pairs among $\{v\} \cup N^-(v)$ are adjacent. $\blacksquare$

**Lemma 4.2 (Earlier-degree is below the clique number).** *If the order is a PEO, then for every vertex $v$,*
$$|N^-(v)| + 1 \le \omega(G).$$

**Proof sketch.** By Lemma 4.1, $\{v\} \cup N^-(v)$ is a clique. Since $v \notin N^-(v)$ (a vertex is not adjacent to itself), this clique has exactly $|N^-(v)| + 1$ vertices. The clique number $\omega(G)$ is the supremum of clique sizes, so $|N^-(v)| + 1 \le \omega(G)$. $\blacksquare$

Equivalently, $|N^-(v)| < \omega(G)$ for every $v$: no vertex has $\omega(G)$ or more earlier neighbors.

## 5. Chordal graphs are perfect

Combining the last two sections gives the main theorem.

**Theorem 5.1 (Linear-scan optimality).** *If $G$ has a perfect elimination ordering, then $G$ is $\omega(G)$-colorable.*

**Proof.** By Lemma 4.2, every vertex satisfies $|N^-(v)| < \omega(G)$. Apply Lemma 3.1 with $k = \omega(G)$. $\blacksquare$

**Theorem 5.2 (Chordal graphs are perfect).** *If $G$ has a perfect elimination ordering, then*
$$\chi(G) = \omega(G).$$

**Proof.** Theorem 5.1 gives an $\omega(G)$-coloring, so $\chi(G) \le \omega(G)$. The universal bound (2.1) gives $\chi(G) \ge \omega(G)$. Antisymmetry of $\le$ yields equality. $\blacksquare$

**Interpretation for register allocation.** The chromatic number $\chi(G)$ is the minimum number of registers needed to run the program without spilling; the clique number $\omega(G)$ is the *peak register pressure* — the largest number of variables simultaneously live at any point. Theorem 5.2 says these coincide for SSA programs: the optimal register count is exactly the peak register pressure, and it is *attained*, constructively, by greedily coloring the vertices in reverse elimination order (Lemma 3.1's algorithm). This is what makes linear-scan-style allocation on SSA form both optimal and efficient, in sharp contrast to the NP-hardness of coloring general graphs.

A graph is called **perfect** when $\chi(H) = \omega(H)$ for *every* induced subgraph $H$. Since every induced subgraph of a chordal graph is again chordal (a PEO restricts to any vertex subset), Theorem 5.2 in fact certifies perfection in this strong sense; here we state and use the top-level equality, which is what the allocation bound requires.

## 6. Interval graphs as a strict special case

Linear-scan register allocation models each variable's lifetime as a single contiguous interval $[\mathrm{lo}(v), \mathrm{hi}(v)]$ on a timeline, with two variables interfering exactly when their intervals overlap. The resulting **interval graphs** form a strict subclass of chordal graphs, and we recover their theory as a corollary.

**Definition 6.1 (Interval interference graph).** Given live ranges $[\mathrm{lo}(v), \mathrm{hi}(v)]$ for each vertex $v$, put $u \sim v$ (for $u \ne v$) iff the intervals $[\mathrm{lo}(u),\mathrm{hi}(u)]$ and $[\mathrm{lo}(v),\mathrm{hi}(v)]$ intersect.

**Theorem 6.2 (Sorted interval graphs have a PEO).** *If the vertices are indexed so that the start points are monotone — $u < v \implies \mathrm{lo}(u) \le \mathrm{lo}(v)$ — then the interval interference graph has a perfect elimination ordering.*

**Proof sketch.** Fix $v$ and take two distinct earlier neighbors $u, w \in N^-(v)$, say $u, w < v$. Each of $u, w$ overlaps $v$; because $u, w$ start no later than $v$ (monotonicity), the point $\mathrm{lo}(v)$ lies in both $[\mathrm{lo}(u),\mathrm{hi}(u)]$ and $[\mathrm{lo}(w),\mathrm{hi}(w)]$: indeed $\mathrm{lo}(u) \le \mathrm{lo}(v)$ and, since $u$ overlaps $v$ with $u$ starting first, $\mathrm{hi}(u) \ge \mathrm{lo}(v)$; likewise for $w$. Hence $\mathrm{lo}(v)$ is a common point of $u$'s and $w$'s intervals, so $u \sim w$. Thus $N^-(v)$ is a clique, i.e. the order is a PEO. $\blacksquare$

**Corollary 6.3 (Interval $\chi = \omega$).** *For a sorted interval interference graph, $\chi(G) = \omega(G)$, and $G$ is $\omega(G)$-colorable.*

**Proof.** Immediate from Theorem 6.2 and Theorems 5.1–5.2. $\blacksquare$

The maximum clique of an interval graph is a set of intervals sharing a common point (Helly's property on the line), so $\omega(G)$ is the maximum number of intervals covering any single instant — the familiar "maximum overlap" quantity of linear-scan allocation. Interval graphs are *strictly* contained in chordal graphs: for example, the interference graphs arising from programs with branching control flow are chordal (in SSA form) but generally not interval. The passage from Section 6 to Section 5 is precisely the passage from straight-line/linear-scan code to full SSA programs.

## 7. Algorithms

**Greedy PEO coloring.** Given a graph with a PEO (vertices already in elimination order), color in *reverse* order. For each vertex $v$ (from last to first), collect the colors already assigned to its earlier neighbors and assign $v$ the smallest color not among them. By Lemma 4.2 the forbidden set has size $< \omega(G)$, so a color in $\{0, \dots, \omega(G)-1\}$ is always available; the result is an optimal $\omega(G)$-coloring. The running time is linear in the number of vertices plus edges.

**Computing a PEO (Maximum Cardinality Search).** For a graph not given in elimination order, a PEO — if one exists — can be produced by Maximum Cardinality Search: repeatedly select the unnumbered vertex adjacent to the most already-numbered vertices, numbering vertices from $n$ down to $1$. The reverse of this numbering is a PEO iff the graph is chordal, which can then be verified in linear time.

**Interval scheduling / linear scan.** For interval graphs, sorting live ranges by start point *is* the PEO (Theorem 6.2). A sweep over sorted endpoints maintaining the set of currently-open intervals both computes $\omega(G)$ (the peak count) and performs the greedy assignment, recycling a register the instant an interval closes.

## 8. Applications

- **Optimal SSA register allocation.** Theorem 5.2 certifies that an SSA program needs exactly *peak-register-pressure* many registers, computable and achievable in near-linear time — the theoretical backbone of production SSA-based allocators.
- **Spill minimization.** When the hardware register budget $k < \omega(G)$, the greedy order identifies precisely where pressure exceeds $k$, guiding which values to spill.
- **Beyond compilers.** The same $\chi = \omega$ phenomenon governs conflict-free resource scheduling, timetabling with interval constraints, and frequency assignment where conflict graphs are chordal.

## 9. Discussion and future work

The result situates a hard engineering problem inside a tractable mathematical class. General coloring is NP-hard, but the interference graphs that programs actually generate are chordal, and chordality collapses the gap between the lower bound $\omega(G)$ and the true optimum $\chi(G)$.

Natural extensions:

1. **Perfection on all induced subgraphs.** Show that deleting any vertex (or restricting to any subset) preserves the PEO, yielding the strong statement $\chi(H) = \omega(H)$ for every induced subgraph $H$ — requiring an order-preserving reindexing of the subset.
2. **Equivalence of chordality definitions.** Relate the PEO (order) form to the classical "every cycle of length $\ge 4$ has a chord" form and to simplicial-vertex elimination (Dirac's theorem: a chordal graph has a simplicial vertex).
3. **SSA dominance-tree characterization.** Formalize that an SSA interference graph is chordal because live ranges follow the dominator tree, with the elimination order a reverse topological order of that tree — closing the gap to program semantics beyond straight-line code.
4. **Colouring algorithm extraction.** Extract a verified $\omega$-coloring routine and connect it to a linear-scan allocator, with a spill bound when the register budget is below $\omega$.
5. **Weighted / tree-width generalizations.** Chordal graphs have tree-width $\omega - 1$; linking register pressure to tree-width connects to dynamic-programming allocators on the clique tree.

## 10. Conclusion

We have given a complete, elementary route from register allocation to a clean combinatorial theorem: chordal graphs — the interference graphs of SSA programs — are perfect, so their chromatic number equals their clique number, and a greedy sweep along a perfect elimination ordering attains the optimum. Interval graphs, the model behind classical linear-scan allocation, emerge as a strict special case. The minimum number of registers is exactly the peak number of simultaneously live variables: a satisfying, exact, and efficiently attainable answer to a question at the heart of every compiler.
