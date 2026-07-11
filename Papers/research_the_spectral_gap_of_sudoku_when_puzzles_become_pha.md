# The Spectral Gap of Constraint-Satisfaction Swap Chains: Connectivity, Not Clue Count, Is the Order Parameter

**Author:** Aristotle
**Date:** 2026-07-11

## Abstract

A constraint-satisfaction puzzle such as Sudoku is defined by a finite set of
admissible completions. A standard way to sample a random completion is the
**swap chain**: from a current completion, repeatedly apply a *compatible swap* —
a local move exchanging two entries while preserving every constraint — with some
holding probability. The mixing speed of this chain is governed by its **spectral
gap** $1-\lambda_2$, the distance between the top eigenvalue $1$ and the second
eigenvalue. We construct the swap chain from first principles as a symmetric,
doubly stochastic transition matrix attached to an arbitrary finite *move graph*
$G$, and we establish the exact dictionary between the algebra of the chain and
the combinatorics of $G$. The central identity is that one step of the chain is
$I - cL$ for the graph Laplacian $L$, from which the entire spectral picture
follows: the chain is stochastic and symmetric; a vector is fixed iff it is
harmonic on $G$; disconnection of $G$ forces a nonconstant harmonic function and
hence a vanishing gap; connection of $G$ forces every harmonic function to be
constant (a discrete maximum principle), making $1$ a simple eigenvalue. An
explicit two-state model exhibits the gap $2c>0$ in the connected case versus $0$
in the disconnected case for puzzles with the *same* number of completions and
clues, directly refuting the folklore that the gap is a function of clue count.
Finally, a conservation law — every compatible swap preserves each line's value
multiset (each Sudoku row sums to $36$) — explains why the move graph decomposes
into invariant blocks. The conclusion is structural: connectivity of the move
graph, not clue count, is the order parameter for mixing.

## 1. Introduction

### 1.1 Motivation and the folklore claim

Constraint-satisfaction problems (CSPs) — Sudoku being the archetype — are
naturally studied through their solution spaces. Given a partially filled $9\times
9$ grid, the admissible completions are the fillings that respect the row, column,
and box constraints. To sample such a completion uniformly at random, one uses a
Markov chain whose moves are *local* and *constraint-preserving*. The archetypal
move is a **compatible swap**: exchange the entries of two cells so that all
constraints remain satisfied.

A persistent piece of folklore asserts that these chains undergo a phase
transition governed by the **clue count**. In the Sudoku setting one hears of a
critical density $d_c = 17/81$ (seventeen being the minimum number of clues for a
uniquely-solvable grid, over eighty-one cells): below it the gap is large (fast
mixing, many solutions); at it the gap collapses (slow mixing, hard puzzles);
above roughly $30/81$ the chain becomes absorbing (a unique solution, no moves).
The implicit claim is that a *single scalar*, the number of clues, controls the
spectral gap.

### 1.2 Contribution

We test this claim by modeling the swap chain intrinsically and computing its
spectral dictionary exactly. The clue-count story turns out to be **false as
stated**, but it points toward a correct theorem once the order parameter is
identified. Our contributions are:

1. A first-principles construction of the swap chain as a symmetric, doubly
   stochastic matrix on an arbitrary finite move graph $G$, valid for any holding
   parameter $0 \le c \le 1/\Delta$ (Section 3).
2. The Laplacian identity $P = I - cL$ and its consequences: stochasticity,
   symmetry, uniform stationarity, and the harmonic characterization of fixed
   vectors (Section 3–4).
3. **Reducibility $\Rightarrow$ vanishing gap** (Theorem 5.1): a disconnected
   move graph admits a nonconstant harmonic function — the indicator of a
   connected component — for *every* holding rate, forcing $\lambda_2 = 1$ and gap
   $0$.
4. **Irreducibility $\Rightarrow$ simple top eigenvalue** (Theorem 5.2): a
   connected move graph makes every harmonic function constant, via a discrete
   maximum principle, so $1$ is simple.
5. An explicit **two-state model** (Section 6) exhibiting gap $2c>0$ (connected)
   versus $0$ (disconnected) for puzzles with identical counts, refuting the
   clue-count slogan.
6. A **conservation law** (Section 7): compatible swaps preserve each line's value
   multiset; each valid Sudoku row sums to $36$, seeding the block decomposition
   of the move graph.

The upshot: connectivity of the move graph, not clue count, is the order
parameter for mixing. The "phase transition" is the reducible/irreducible
dichotomy.

## 2. Preliminaries

Let $G=(V,E)$ be a finite simple graph, $V$ its vertex set (the admissible
completions), and $E$ its edges (pairs of completions joined by a single
compatible swap). We write $y \sim x$ for adjacency, $N(x) = \{y : y \sim x\}$ for
the neighborhood, and $\deg(x) = |N(x)|$ for the degree. Let $\Delta = \max_x
\deg(x)$ be the maximum degree.

A function $f : V \to \mathbb{R}$ is identified with a vector indexed by $V$. The
**graph Laplacian** acts by
$$(Lf)(x) = \deg(x)\,f(x) - \sum_{y \sim x} f(y).$$
A function $f$ is **harmonic** if $Lf = 0$, i.e. $\deg(x)\,f(x) = \sum_{y\sim x}
f(y)$ for all $x$: the value at each vertex is the (unnormalized) sum, equivalently
the average, of the values at its neighbors.

We call $G$ **connected** (preconnected) if every pair of vertices is joined by a
walk, and **disconnected** otherwise. Reachability is the equivalence relation
"joined by a walk"; its classes are the connected components.

## 3. The swap chain

### 3.1 Definition

**Definition 3.1 (Swap chain).** For a finite move graph $G$ and a holding
parameter $c \in \mathbb{R}$, the *swap chain* transition matrix $P = P_{G,c}$ is
$$P(x,y) = \begin{cases} 1 - c\,\deg(x) & \text{if } y = x,\\ c & \text{if } y \sim x,\\ 0 & \text{otherwise.}\end{cases}$$

Intuitively: from state $x$, follow each of the $\deg(x)$ incident swap-edges with
probability $c$ each, and otherwise remain in place. For $0 \le c \le 1/\Delta$ the
diagonal entries are nonnegative and $P$ is a bona fide stochastic matrix.

### 3.2 Stochasticity and symmetry

**Theorem 3.2 (Row sums).** For every $x$, $\sum_{y} P(x,y) = 1$.

*Proof sketch.* Separate the diagonal term from the off-diagonal ones. The
off-diagonal contributions are $c$ over the $\deg(x)$ neighbors, summing to
$c\,\deg(x)$; adding the diagonal $1 - c\,\deg(x)$ gives $1$. $\square$

**Theorem 3.3 (Symmetry).** $P(x,y) = P(y,x)$ for all $x,y$.

*Proof sketch.* The diagonal case is trivial. Off the diagonal, $P(x,y)$ and
$P(y,x)$ both equal $c$ when $x \sim y$ (adjacency is symmetric) and both equal
$0$ otherwise. $\square$

A symmetric stochastic matrix is doubly stochastic, so the **uniform
distribution** is stationary and all eigenvalues are real.

### 3.3 The Laplacian identity

**Theorem 3.4 (One step is $I - cL$).** For every $f : V \to \mathbb{R}$ and every
$x$,
$$(Pf)(x) = f(x) + c\Big(\sum_{y \sim x} f(y) - \deg(x)\,f(x)\Big) = f(x) - c\,(Lf)(x).$$

*Proof sketch.* Expand $(Pf)(x) = \sum_y P(x,y)\,f(y)$ using Definition 3.1: the
diagonal contributes $(1 - c\,\deg(x))\,f(x)$ and the neighbors contribute
$c\sum_{y \sim x} f(y)$. Collecting terms yields the stated Laplacian form.
$\square$

This identity is the engine of the paper: it converts every spectral question
about $P$ into a combinatorial question about $L$, and hence about $G$.

## 4. Harmonic functions and the top eigenvalue

**Corollary 4.1 (Constants are fixed; $\lambda_1 = 1$).** The constant vector
$\mathbf{1}$ satisfies $P\mathbf{1} = \mathbf{1}$.

*Proof sketch.* Apply Theorem 3.4 with $f \equiv 1$: $\sum_{y\sim x} 1 = \deg(x) =
\deg(x)\cdot 1$, so the Laplacian term vanishes. $\square$

Since $P$ is doubly stochastic, $1$ is the largest eigenvalue, $\lambda_1 = 1$.

**Theorem 4.2 (Harmonic characterization of fixed vectors).** Let $c \ne 0$. Then
$Pf = f$ if and only if $f$ is harmonic:
$$\sum_{y \sim x} f(y) = \deg(x)\,f(x) \quad \text{for all } x.$$

*Proof sketch.* By Theorem 3.4, $Pf = f$ iff $c\,(Lf)(x) = 0$ for all $x$. Since
$c \ne 0$, this holds iff $(Lf)(x) = 0$ for all $x$, i.e. $f$ is harmonic.
$\square$

Thus the eigenspace for the eigenvalue $1$ is precisely the space of harmonic
functions on $G$. The spectral gap is strictly positive **only if** this space is
one-dimensional (the constants). We now determine when that happens.

## 5. The dichotomy: connectivity is the order parameter

### 5.1 Reducibility forces a vanishing gap

**Definition 5.0 (Component indicator).** For a base vertex $x_0$, let
$$\chi_{x_0}(y) = \begin{cases} 1 & \text{if } y \text{ is reachable from } x_0,\\ 0 & \text{otherwise.}\end{cases}$$

**Theorem 5.1 (Reducibility $\Rightarrow$ degenerate top eigenvalue).** If $G$ is
disconnected, then for *every* holding rate $c$ there is a nonconstant vector $f$
with $Pf = f$. Consequently the eigenvalue $1$ has multiplicity at least two,
$\lambda_2 = 1$, and the spectral gap is $0$.

*Proof sketch.* Since $G$ is disconnected there exist $x_0, y_0$ with $y_0$ not
reachable from $x_0$. Take $f = \chi_{x_0}$. At any vertex $x$, all neighbors of
$x$ lie in the same reachability class as $x$ (a single edge cannot change
reachability from $x_0$), so $\chi_{x_0}$ is constant on $N(x) \cup \{x\}$; hence
$\sum_{y\sim x}\chi_{x_0}(y) = \deg(x)\,\chi_{x_0}(x)$ and $\chi_{x_0}$ is
harmonic. By Theorem 3.4 this makes $\chi_{x_0}$ fixed by $P$ for every $c$ (the
argument does not even need $c \ne 0$). It is nonconstant because
$\chi_{x_0}(x_0) = 1 \ne 0 = \chi_{x_0}(y_0)$. Two independent eigenvectors
($\mathbf{1}$ and $\chi_{x_0}$) for eigenvalue $1$ give $\lambda_2 = 1$ and gap
$0$. $\square$

This is the true "no mixing / absorbing" regime, and it is triggered by
*disconnection of the swap graph*, with no reference whatsoever to clue count.

### 5.2 Irreducibility forces a simple top eigenvalue

**Theorem 5.2 (Irreducibility $\Rightarrow$ simple top eigenvalue; discrete
maximum principle).** Let $c \ne 0$ and let $G$ be connected. If $Pf = f$ then $f$
is constant. Hence the eigenvalue $1$ is simple.

*Proof sketch.* By Theorem 4.2, $f$ is harmonic. On a nonempty finite vertex set
$f$ attains a maximum $M = f(x_M)$. At $x_M$ the mean-value property gives
$\sum_{y\sim x_M} f(y) = \deg(x_M)\,M$; equivalently $\sum_{y\sim x_M}(M - f(y)) =
0$. Each summand is $\ge 0$ (since $M$ is the max), so a sum of nonnegative terms
vanishing forces every term to vanish: $f(y) = M$ for all $y \sim x_M$. Thus the
maximum propagates to all neighbors, then along any walk. Because $G$ is
connected, every vertex is reachable from $x_M$ by a walk, so $f \equiv M$ is
constant. $\square$

Simplicity of $\lambda_1$ is the necessary condition for a strictly positive gap;
in the connected case it holds, so genuine mixing is possible. (The *quantitative*
size of the gap is then governed by graph conductance via Cheeger-type
inequalities — see Section 8 and the Future Directions.)

## 6. The two-state model: same counts, opposite gaps

The dichotomy is exactly solvable on two completions.

**Theorem 6.1 (Connected two-state gap).** Let $G$ be the single edge on
$\{0,1\}$ (the complete graph on two vertices). Then the alternating vector
$(1,-1)$ is an eigenvector of $P$ with eigenvalue $1 - 2c$, and the spectral gap is
$$1 - (1 - 2c) = 2c,$$
which is strictly positive whenever $c > 0$.

*Proof sketch.* Here $\deg(0) = \deg(1) = 1$, so $P = \begin{pmatrix} 1-c & c \\ c
& 1-c \end{pmatrix}$. Direct multiplication gives $P(1,-1)^\top = (1-2c)(1,-1)^\top$.
The constant vector has eigenvalue $1$, so $\lambda_2 = 1-2c$ and the gap is $2c$.
$\square$

**Theorem 6.2 (Disconnected two-state gap).** Let $G$ be the empty graph on
$\{0,1\}$ (no edge). Then $P$ is the $2\times 2$ identity matrix: every vector is
fixed, $\lambda_2 = 1$, and the gap is $0$.

*Proof sketch.* With no edges, $\deg(0) = \deg(1) = 0$, so $P(x,x) = 1$ and all
off-diagonal entries are $0$; thus $P = I$. $\square$

**Consequence.** Two puzzles may have the *same* number of completions (two) and
can be arranged to have the same number of clues, yet exhibit gap $2c > 0$ or gap
$0$ depending solely on whether a compatible swap connects the two completions.
This refutes the slogan "the spectral gap is a function of the clue count." The
gap is a function of the **swap geometry**.

## 7. Why the move graph decomposes: a conservation law

Connectivity being decisive, we explain why real Sudoku move graphs so often fail
to be connected.

**Theorem 7.1 (Row-multiset invariant).** Any valid Sudoku row is a bijection of
its nine cells onto the nine symbols $\{0,1,\dots,8\}$, and therefore its entries
sum to
$$0 + 1 + 2 + \cdots + 8 = 36.$$

*Proof sketch.* A bijection onto $\{0,\dots,8\}$ has the same entry-sum as the
identity listing, namely $\sum_{k=0}^{8} k = 36$. $\square$

A compatible swap permutes entries within lines and thus **preserves each line's
value multiset**; in particular the per-row sum $36$ is invariant along every walk
of the chain. Every such conserved statistic (row, column, and box multisets)
partitions the solution space into level sets, and no move crosses between level
sets. The connected components of the move graph therefore refine the fibers of
the multiset map. This is the combinatorial origin of the invariant blocks: the
walk is confined to a single joint multiset profile, and the number of chain
components is at least the number of jointly attainable profiles. (See Conjecture
2 in Section 9 for the conjectured converse.)

## 8. Algorithms

We summarize the computational procedures that instantiate the theory; full code
appears in the accompanying demonstrations.

**Algorithm A — Swap-chain matrix assembly.** Given a move graph $G$ on $n$
vertices and a rate $c$, build $P$ by placing $c$ on each edge, $0$ on non-edges,
and $1 - c\,\deg(x)$ on the diagonal. Complexity $O(n^2)$ time and space. The rate
is chosen as $c = 1/\Delta$ (or smaller) to guarantee stochasticity.

**Algorithm B — Spectral gap via symmetric eigendecomposition.** Since $P$ is
symmetric, compute its real eigenvalues, sort them in decreasing order, and return
$\lambda_1 - \lambda_2 = 1 - \lambda_2$. A self-contained Jacobi rotation sweep
suffices; complexity $O(n^3)$ per sweep with a small number of sweeps.

**Algorithm C — Connectivity test.** Determine whether $G$ is connected by
breadth-first search from an arbitrary vertex; the graph is connected iff every
vertex is visited. Complexity $O(n + |E|)$. By Theorems 5.1–5.2 this alone
predicts whether the gap is zero (disconnected) or positive (connected).

**Algorithm D — Empirical mixing time.** Iterate the row-stochastic power method
$\mu \mapsto \mu P$ from a point mass and measure total-variation distance to
uniform; the number of steps to fall below $\varepsilon$ is the empirical mixing
time, which scales like $(1/\text{gap})\log(1/\varepsilon)$.

## 9. Applications and discussion

The analysis applies verbatim to any CSP whose sampler is built from local,
constraint-preserving moves: graph coloring (Kempe-chain and single-vertex
recolorings), scheduling, lattice models in statistical physics, and
error-correcting codes. In each case the sampler is a symmetric walk on a move
graph, and the same dictionary holds: uniform stationarity, harmonic fixed
vectors, zero gap iff disconnected, simple top eigenvalue iff connected.

The practical message is a warning against scalar proxies for hardness. Counting
constraints (or clues) does not determine mixing; the connectivity and
bottleneck structure of the move graph does. Two instances that look identical to
a counting heuristic can have wildly different sampling difficulty. Diagnosing a
sampler therefore means examining its move graph — its connectivity first, then
its conductance.

## 10. Future directions

- **Quantitative gap from graph conductance.** For the max-degree lazy swap chain
  on a connected move graph, the gap should be bounded below by $c\,h(G)^2/(2\Delta)$,
  where $h(G)$ is the edge conductance and $\Delta$ the maximum degree — a Cheeger
  inequality applied to the very Laplacian appearing in one step of the chain.
- **Block decomposition from conserved multiset statistics.** The connected
  components of the swap-move graph are conjecturally *exactly* the level sets of
  the conserved row/column/box multisets, so the chain is irreducible iff all
  admissible completions share every such profile.
- **Uniqueness collapses the chain.** A puzzle with a unique completion yields a
  one-state chain (the $1\times 1$ identity); "unique solution" is the degenerate
  *fast* regime, not the slow one the folklore imagines.
- **Symmetry forces spectral degeneracy.** A nontrivial automorphism acting freely
  on completions makes $P$ commute with the induced permutation, forcing
  eigenvalue multiplicities and predictable degeneracies in the spectrum.

## 11. Conclusion

We replaced the folklore "gap versus clue count" picture with a structural one.
One step of the swap chain is $I - cL$; its fixed vectors are the harmonic
functions of the move graph; the top eigenvalue is degenerate exactly when the
graph is disconnected and simple exactly when it is connected. An explicit
two-state model shows the gap can be positive or zero for puzzles with identical
counts, and a conservation law explains why move graphs decompose into invariant
blocks. Connectivity of the graph of compatible swaps — not the number of clues —
is the order parameter for mixing.
