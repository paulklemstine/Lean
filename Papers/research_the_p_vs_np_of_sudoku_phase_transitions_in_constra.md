# Constraint Graphs, Exact Colorability, and the Non-Universality of Clue-Density Thresholds in Generalized Sudoku

**Aristotle**  
**July 18, 2026**

## Abstract

An order-$n$ Sudoku consists of an $n^2\times n^2$ array partitioned into $n\times n$ blocks and filled with $n^2$ symbols subject to row, column, and block distinctness. We give a self-contained structural analysis that separates exact combinatorial facts from conjectural phase-transition claims. The Sudoku constraint graph has cells as vertices and joins distinct cells that share a row, column, or block. A filling is a valid Sudoku solution exactly when it is a proper coloring of this graph. For every $n\ge1$, the graph has chromatic number exactly $n^2$: a row supplies an $n^2$-clique, while the arithmetic construction

$$
G_n(r,c)=\bigl(n(r\bmod n)+\lfloor r/n\rfloor+c\bigr)\bmod n^2
$$

supplies a proper $n^2$-coloring and hence a completed grid. We then model clues as partial assignments. Solvability is antitone under clue inclusion, every restriction of a completed grid is solvable, and solvable instances exist with every clue count from $0$ to $n^4$. It follows that no deterministic clue-count threshold separates solvable from unsolvable instances. More strongly, any probabilistic threshold depends on the random clue ensemble: in the completion-restriction ensemble, solvability has probability one at every density. Thus a density such as $(n^2-1)/n^2$ cannot be universal without additional assumptions. We describe exact construction and validation algorithms, implications for clique-based preprocessing, and a principled experimental framework for studying satisfiability, uniqueness, and algorithm-specific hardness.

## 1. Introduction

Generalized Sudoku is a finite constraint satisfaction problem with unusually transparent geometry. Its variables are cells, its domains are symbols, and its binary disequality constraints arise from three overlapping families: rows, columns, and blocks. This makes Sudoku an instructive meeting point for algebraic constructions, graph coloring, random constraint satisfaction, and search complexity.

A common heuristic picture proposes that random Sudoku instances undergo a phase transition as the density of pre-filled cells increases. One suggested critical density is

$$
d_c(n)=\frac{n^2-1}{n^2}.
$$

This gives $d_c(2)=3/4$, $d_c(3)=8/9$, and $d_c(4)=15/16$. A related claim is that computational hardness peaks near such a transition and grows exponentially in $n^2$ for backtracking.

The attraction of this picture should not obscure a foundational issue: a clue density does not define a probability distribution. Clues can be sampled by deleting entries from a valid completion, by independently assigning symbols, by conditioning on local consistency, or by perturbing a completion. These choices induce different correlations and can yield incompatible satisfiability behavior at the same density.

This paper develops the structural facts needed before a threshold question can be posed. The results are:

1. valid completed Sudokus are exactly proper colorings of a natural constraint graph;
2. the graph's chromatic number is exactly $n^2$;
3. an explicit formula solves the empty grid for every $n\ge1$;
4. solvability is antitone under addition of clues;
5. every restriction of a completed solution remains solvable;
6. solvable clue systems occur at every possible clue count;
7. every sound clique upper-bound oracle applied to the whole graph must return at least $n^2$.

The first three identify the rigid combinatorial core. The next three show why density alone cannot determine solvability. The final result isolates a limitation that every sound clique-based preprocessing method must respect.

## 2. Generalized Sudoku and its constraint graph

Fix an integer $n\ge1$ and write $N=n^2$. Rows, columns, and symbols are indexed by

$$
[N]=\{0,1,\ldots,N-1\}.
$$

### Definition 2.1 (Cells and units)

The cell set is $C_n=[N]\times[N]$. A cell is written $p=(r,c)$. Two cells $(r,c)$ and $(r',c')$ lie in the same row when $r=r'$, in the same column when $c=c'$, and in the same block when

$$
\left\lfloor\frac r n\right\rfloor=
\left\lfloor\frac {r'} n\right\rfloor,
\qquad
\left\lfloor\frac c n\right\rfloor=
\left\lfloor\frac {c'} n\right\rfloor.
$$

There are $N^2=n^4$ cells. The blocks are the $n^2$ Cartesian products of intervals of $n$ consecutive rows and $n$ consecutive columns.

### Definition 2.2 (Sudoku filling and solution)

A filling is a function $g:C_n\to[N]$. It is a valid Sudoku solution if any two distinct cells in a common row, column, or block receive different symbols.

Because each unit contains exactly $N$ cells and there are exactly $N$ available symbols, pairwise distinctness implies that every symbol occurs exactly once in every row, column, and block.

### Definition 2.3 (Constraint graph)

The Sudoku constraint graph $\Gamma_n$ is the simple graph with vertex set $C_n$. Distinct vertices are adjacent precisely when their cells share a row, column, or block.

A proper coloring of a graph by a color set $K$ is a map from vertices to $K$ assigning different colors to adjacent vertices. The chromatic number $\chi(\Gamma)$ is the least cardinality of a color set admitting a proper coloring. A clique is a set of pairwise adjacent vertices.

### Theorem 2.4 (Sudoku–coloring equivalence)

For every filling $g:C_n\to[N]$, the following are equivalent:

1. $g$ is a valid Sudoku solution;
2. $g$ is a proper coloring of $\Gamma_n$ with the $N=n^2$ symbols as colors.

**Proof sketch.** By definition, an edge of $\Gamma_n$ joins exactly two distinct cells sharing a row, column, or block. The Sudoku condition says exactly that the endpoints of each such edge receive different values. Thus the two predicates quantify over the same forbidden equalities. $\square$

This theorem is not merely an analogy. It identifies Sudoku completion with extension of a partial graph coloring on a graph having highly structured overlapping cliques.

## 3. An explicit completion

The upper bound on the chromatic number comes from an arithmetic construction. For $0\le r,c<N$, define

$$
G_n(r,c)=\bigl(n(r\bmod n)+\lfloor r/n\rfloor+c\bigr)\bmod N.
$$

The term

$$
D_n(r)=n(r\bmod n)+\lfloor r/n\rfloor
$$

is a permutation of $[N]$. Indeed, writing $r=nq+s$ with $0\le q,s<n$ gives $D_n(r)=ns+q$, which swaps the two base-$n$ digits of $r$.

We record the elementary uniqueness principle underlying the construction.

### Lemma 3.1 (Base-$n$ digit uniqueness)

Let $a,a',b,b'$ be nonnegative integers with $b,b'<n$. If

$$
na+b=na'+b',
$$

then $a=a'$ and $b=b'$.

**Proof sketch.** Reduction modulo $n$ gives $b=b'$. Subtracting these equal remainders gives $na=na'$, and cancellation by the positive integer $n$ gives $a=a'$. $\square$

### Lemma 3.2 (Reduced modular cancellation)

Let $0\le x,y<M$. If

$$
(k+x)\bmod M=(k+y)\bmod M,
$$

then $x=y$. The same conclusion holds for $(x+k)\bmod M=(y+k)\bmod M$.

**Proof sketch.** Equal residues after adding the same $k$ imply $x\equiv y\pmod M$. Since both are the unique representatives in $[0,M-1]$, they are equal. Commutativity gives the right-addition version. $\square$

### Lemma 3.3 (Row distinctness)

For fixed $r$, if $G_n(r,c)=G_n(r,c')$, then $c=c'$.

**Proof sketch.** The row-dependent term $D_n(r)$ is constant. Both $c$ and $c'$ lie in $[N]$, so Lemma 3.2 cancels the common term modulo $N$. $\square$

### Lemma 3.4 (Column distinctness)

For fixed $c$, if $G_n(r,c)=G_n(r',c)$, then $r=r'$.

**Proof sketch.** For $r<N$, both $r\bmod n$ and $\lfloor r/n\rfloor$ are below $n$, so $D_n(r)<N$. Canceling the common column term modulo $N$ yields $D_n(r)=D_n(r')$. Lemma 3.1 applied to

$$
n(r\bmod n)+\lfloor r/n\rfloor
=n(r'\bmod n)+\lfloor r'/n\rfloor
$$

identifies both base-$n$ digits. Reconstructing $r=n\lfloor r/n\rfloor+(r\bmod n)$ gives $r=r'$. $\square$

### Lemma 3.5 (Block distinctness)

Suppose $(r,c)$ and $(r',c')$ lie in the same block. If $G_n(r,c)=G_n(r',c')$, then $r=r'$ and $c=c'$.

**Proof sketch.** Write

$$
r=nq+s,\qquad c=nt+u,
$$

with $0\le s,u<n$. Within one block, $q=\lfloor r/n\rfloor$ and $t=\lfloor c/n\rfloor$ are fixed. Rearranging the unreduced expression gives

$$
n(r\bmod n)+(c\bmod n)
+igl(\lfloor r/n\rfloor+n\lfloor c/n\rfloor\bigr).
$$

The parenthesized block-dependent term is common to both cells. The first term is below $N$. Modular cancellation therefore identifies

$$
n(r\bmod n)+(c\bmod n)
=n(r'\bmod n)+(c'\bmod n).
$$

Base-$n$ digit uniqueness identifies the within-block row and column. Combining these with the common block coordinates gives equality of both full coordinates. $\square$

### Theorem 3.6 (Explicit Sudoku completion)

For every $n\ge1$, the filling $G_n$ is a valid order-$n$ Sudoku solution.

**Proof sketch.** Lemmas 3.3, 3.4, and 3.5 show that equal values cannot occur in two distinct cells of a row, column, or block, respectively. These are exactly the Sudoku constraints. $\square$

### Corollary 3.7 (Universal solvability of the empty grid)

Every empty order-$n$ Sudoku with $n\ge1$ admits a completion.

The construction takes $O(n^4)$ arithmetic operations to materialize because the grid has $n^4$ cells, and it uses $O(n^4)$ space if stored. A streaming implementation needs only $O(1)$ auxiliary space beyond its output.

## 4. Exact chromatic number

### Lemma 4.1 (Canonical row clique)

Every row of $\Gamma_n$ is a clique of cardinality $N=n^2$.

**Proof sketch.** Distinct cells in one row share that row, hence are adjacent. There are exactly $N$ columns. $\square$

### Theorem 4.2 (Exact chromatic number)

For every $n\ge1$,

$$
\chi(\Gamma_n)=n^2.
$$

**Proof sketch.** Lemma 4.1 forces $\chi(\Gamma_n)\ge n^2$, since all vertices of an $n^2$-clique require distinct colors. The explicit completion in Theorem 3.6 is, by Theorem 2.4, a proper coloring using $n^2$ colors, so $\chi(\Gamma_n)\le n^2$. The bounds coincide. $\square$

This equality expresses the tightness of the Sudoku alphabet. The graph locally demands all $n^2$ symbols in a row, while the global row–column–block interaction requires no additional symbols.

### Proposition 4.3 (Lower bound for sound clique oracles)

Consider any rule that assigns to each vertex subset $U$ a natural number $B(U)$ such that every finite clique contained in $U$ has size at most $B(U)$. Then

$$
B(C_n)\ge n^2.
$$

**Proof sketch.** Apply soundness to the clique formed by the first row, which is contained in the full vertex set and has cardinality $n^2$. $\square$

The proposition does not say that clique information is useless. It says that every sound clique upper-bound mechanism must accommodate the canonical row obstruction. Any stronger pruning claim must exploit information beyond merely assigning too small an upper bound to the whole graph.

## 5. Partial assignments and solvability

### Definition 5.1 (Clue system)

A clue system $c$ assigns to every cell either no symbol or one symbol in $[N]$. Its support is

$$
\operatorname{supp}(c)=\{p\in C_n:c(p)\text{ is present}\}.
$$

A filling $g$ extends $c$ if $g(p)=c(p)$ at every clue cell. The clue system is solvable if some valid Sudoku solution extends it.

### Definition 5.2 (Clue inclusion)

For clue systems $c_1$ and $c_2$, write $c_1\preceq c_2$ if every clue present in $c_1$ is present with the same value in $c_2$. Thus $c_2$ is obtained from $c_1$ by adding zero or more clues without changing existing values.

### Theorem 5.3 (Antitonicity of solvability)

If $c_1\preceq c_2$ and $c_2$ is solvable, then $c_1$ is solvable.

**Proof sketch.** Let $g$ be a valid completion extending $c_2$. Every clue of $c_1$ is also a clue of $c_2$ with the same value, so $g$ extends $c_1$. $\square$

The set of solvable clue systems is therefore downward closed under clue deletion. Dually, the set of unsolvable systems is upward closed under consistent clue addition.

### Definition 5.4 (Restriction of a completion)

Given a valid completed grid $g$ and a cell set $S\subseteq C_n$, define the restriction clue system $c_{g,S}$ by displaying $g(p)$ when $p\in S$ and leaving $p$ blank otherwise.

### Theorem 5.5 (Every solution restriction is solvable)

For every valid completed grid $g$ and every cell set $S$, the clue system $c_{g,S}$ is solvable.

**Proof sketch.** The same grid $g$ is a valid completion and agrees with every displayed clue by construction. $\square$

### Lemma 5.6 (Exact support)

For every valid completion $g$ and cell set $S$,

$$
\operatorname{supp}(c_{g,S})=S.
$$

**Proof sketch.** A clue is displayed at $p$ if and only if the construction's membership test places $p$ in $S$. $\square$

### Theorem 5.7 (Solvability at every clue count)

For every $n\ge1$ and every integer $k$ satisfying $0\le k\le n^4$, there exists a solvable order-$n$ clue system with exactly $k$ clues.

**Proof sketch.** Construct the completion $G_n$ from Theorem 3.6. Choose any $k$-element subset $S$ of the $n^4$ cells and form $c_{G_n,S}$. Theorem 5.5 gives solvability, while Lemma 5.6 gives exactly $k$ clues. $\square$

### Corollary 5.8 (No deterministic clue-count separator)

There is no clue count $k_0$ such that every clue system below $k_0$ is solvable and every clue system at or above $k_0$ is unsolvable. In particular, clue density alone cannot deterministically classify solvability.

The statement is deliberately about existence, not uniqueness. Restricting a completion always preserves at least one solution, but may preserve many.

## 6. Consequences for phase-transition claims

A random-instance statement requires an ensemble: for every $n$ and density parameter $d$, a probability distribution on clue systems. Let

$$
P_n(d)=\Pr[\text{the sampled clue system is solvable}].
$$

Only after defining this distribution does $P_n(d)$ have meaning.

### 6.1 Completion-restriction ensemble

Sample a completed grid $g$, select a random cell set $S$ according to any distribution—fixed-size, independent Bernoulli selection, or a spatially correlated process—and reveal $g$ on $S$. Theorem 5.5 immediately yields

$$
P_n(d)=1
$$

for every attainable density $d$. This ensemble has no satisfiability transition, even though its clue counts can range over the entire interval from $0$ to $n^4$.

### 6.2 Independently assigned values

Alternatively, select clue cells and assign symbols independently. Such assignments can contain immediate collisions. Conditioning away visible row, column, and block collisions produces a more interesting ensemble, but its remaining long-range correlations differ from those of a restricted completion. The structural results here do not determine its threshold; they show why it must be named and analyzed separately.

### 6.3 Refutation of universality, not of all thresholds

The candidate

$$
d_c(n)=\frac{n^2-1}{n^2}
$$

cannot be an ensemble-independent satisfiability threshold. The completion-restriction ensemble is a countermodel to universality because its solvability probability never drops. This does not preclude a sharp threshold near that value—or elsewhere—for a specifically defined random-value ensemble.

The distinction is common in probabilistic combinatorics. Density controls the amount of information, while correlations control its compatibility. Equal one-cell marginals and equal expected density need not imply equal global behavior.

## 7. Algorithms and numerical demonstrations

### Algorithm 7.1 (Arithmetic completion)

**Input:** a positive block size $n$.  
**Output:** an $n^2\times n^2$ completed Sudoku.

For each row $r$ and column $c$, compute $G_n(r,c)$. Materializing all $n^4$ entries takes $O(n^4)$ time and $O(n^4)$ output space. The arithmetic per cell is constant-cost under a unit-cost integer model; with bit complexity, operands have $O(\log n)$ bits.

### Algorithm 7.2 (Constraint validation)

For every row, column, and block, collect its entries and compare the set with $[N]$. There are $3N$ units, each containing $N$ values, so hash-set validation takes expected $O(N^2)=O(n^4)$ time and $O(N)=O(n^2)$ auxiliary space when units are processed sequentially.

### Algorithm 7.3 (Constraint-graph construction)

Create one vertex per cell. For each unordered cell pair, add an edge exactly when the cells share a row, column, or block. The direct pairwise algorithm takes $O(n^8)$ peer tests because there are $n^4$ vertices. A unit-based implementation can add all pairs within each of the $3N$ units in $O(N^3)=O(n^6)$ insertion attempts, with duplicates removed by sets.

### Numerical examples

For $n=2$, the formula produces

$$
\begin{matrix}
0&1&2&3\\
2&3&0&1\\
1&2&3&0\\
3&0&1&2
\end{matrix}.
$$

Each row, column, and $2\times2$ block contains $\{0,1,2,3\}$. For $n=3$, the row shifts are

$$
0,3,6,1,4,7,2,5,8,
$$

which generates a $9\times9$ completion. For any chosen $k$, selecting $k$ coordinates and revealing their formula values yields a solvable clue system whose known witness is the full arithmetic grid.

These demonstrations should not be mistaken for empirical evidence of a random threshold. They illustrate exact structural results and provide controls for future experiments.

## 8. Hardness: what remains unproved

The structural theorems do not establish an average-case running-time peak, an exponential lower bound, or a $P$ versus $NP$ separation. Those questions require additional definitions.

First, “backtracking” denotes a family of algorithms. Search-tree size can change dramatically with variable ordering, value ordering, propagation, learning, restarts, and symmetry breaking. A meaningful lower bound must fix these rules or quantify over a precisely specified class.

Second, the notation $O(\exp(n^2))$ is an upper bound. To claim unavoidable exponential behavior one would seek a lower bound such as $\exp(\Omega(n^2))$ on an explicit instance family or with high probability in a named ensemble.

Third, satisfiability, uniqueness, number of solutions, solver time, search-tree nodes, and refutation width are distinct observables. Their maxima and transition windows need not coincide. An instance can be unsatisfiable but locally contradictory and easy; another can be satisfiable but force extensive branching.

The coloring equivalence provides a route forward. It allows graph-coloring encodings, clique reasoning, and proof-complexity techniques to be applied while preserving Sudoku's row–column–block geometry.

## 9. Applications and experimental design

The results suggest a reproducible pipeline for phase-transition studies.

1. **Specify the ensemble.** State how clue locations and values are sampled, including all conditioning.
2. **Couple densities monotonically when possible.** Generate a nested sequence of clue sets so Theorem 5.3 applies pathwise.
3. **Separate observables.** Record existence, uniqueness, number of solutions, search nodes, and wall-clock time independently.
4. **Specify the solver.** Publish branching, propagation, learning, restart, and tie-breaking rules.
5. **Use exact controls.** Include completion restrictions, which must remain solvable at all densities, as a check on the generator and solver.
6. **Report finite-size scaling.** Compare multiple values of $n$ rather than extrapolating from the standard $9\times9$ case.
7. **Distinguish upper and lower complexity claims.** Empirical runtimes support observations about tested implementations, not universal asymptotic lower bounds.

Beyond puzzles, the same methodology applies to scheduling, frequency assignment, register allocation, and other graph-coloring CSPs. Constraint density does not encode constraint geometry or value correlation; careful ensembles are essential in all of them.

## 10. Discussion

Three layers of Sudoku should be kept separate. The first is **structural feasibility**: the empty grid is solvable, and the graph needs exactly $n^2$ colors. The second is **partial-assignment compatibility**: clues prescribe colors and ask whether the partial coloring extends. The third is **algorithmic performance**: a selected method searches for a completion or contradiction.

The explicit formula resolves the first layer uniformly. The clue restriction and antitonicity theorems organize the second. The third remains dependent on both the ensemble and the solver.

The candidate density $(n^2-1)/n^2$ may still serve as an experimental hypothesis in a particular model, but it is not forced by the exact chromatic number. The fact that the graph needs $n^2$ colors is a statement about alphabet size, whereas clue density measures the proportion of precolored vertices. Conflating these two quantities produces an appealing number without a universal mechanism.

Likewise, canonical cliques explain a necessary local demand but not the full global difficulty of extending a partial coloring. Rows, columns, and blocks overlap in a structured way, and contradictions can emerge from interactions not captured by one clique in isolation.

## 11. Future work

Several concrete directions follow.

A first task is to compare locally permutation-invariant ensembles with equal expected density and one-cell marginals but different correlations, especially locally consistent independent assignments versus perturbations of random completions. Their thresholds are expected to differ.

A second task is to study proof complexity separately from satisfiability. In an independently assigned, locally consistent clue ensemble, the density maximizing median resolution width may differ from the density maximizing satisfiability variance.

A third task is algorithm-specific lower bounds. For a fixed deterministic variable and value ordering, one may seek explicit order-$n$ instances requiring $\exp(\Omega(n^2))$ search-tree nodes while admitting shorter certificates in stronger proof systems.

A fourth task is to test the limits of clique-only preprocessing. The canonical $n^2$-cliques impose unavoidable oracle bounds, but bounded-width consistency may detect global block interactions invisible to local clique summaries.

Finally, uniqueness deserves its own probability curve. Completion restrictions guarantee existence at every density, but not uniqueness. A completion-restriction ensemble could therefore exhibit a uniqueness transition even though its existence probability is constantly one.

## 12. Conclusion

Generalized Sudoku has an exact graph-theoretic core. A filling is a proper coloring of its constraint graph; the graph's chromatic number is exactly $n^2$; and an explicit base-$n$ digit construction completes every empty grid. Clue systems form a partial order under inclusion, with solvability downward closed. Restrictions of completions give solvable instances at every clue count.

These results rule out any deterministic or ensemble-independent satisfiability threshold based on clue density alone. They do not rule out phase transitions. Rather, they identify what a valid phase-transition claim must contain: a probability distribution on clues, a precise observable, and, for hardness claims, a specified algorithm or proof system. The mathematics therefore shifts the question from “What is the universal Sudoku density?” to the more productive question “Which ensemble, which transition, and which notion of complexity?”