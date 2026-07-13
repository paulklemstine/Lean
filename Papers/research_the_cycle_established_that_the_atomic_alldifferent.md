# The AllDifferent Satisfiability Threshold: An Enumerative–Order-Theoretic–Chromatic Chain

## Abstract

The **AllDifferent** constraint — a set of variables required to take pairwise-distinct values from a shared alphabet — is a cornerstone of combinatorial optimization, constraint programming, and recreational mathematics alike. We establish, as a single self-contained chain of results, that the atomic AllDifferent constraint possesses a *sharp satisfiability threshold* located exactly at the **balance point** where the number of demands equals the number of resources. We prove that this threshold admits three simultaneous characterizations: an **enumerative** one, in which the number of satisfying assignments is the falling factorial and serves as an order parameter that is positive below the threshold and identically zero above it; an **order-theoretic** one, in which satisfiability is a monotone (down-closed) event whose boundary is a single up-set frontier; and a **chromatic** one, in which the constraint is a proper coloring of a complete graph, colorable with $k$ colors precisely when the number of demands does not exceed $k$. We then apply the chain to Sudoku: every line of an $n^2 \times n^2$ grid sits *exactly* at the balance point, and the closed-form cyclic Latin square $L(i,j) = i + j$ solves all row and column constraints yet provably violates a box constraint already at order $n = 2$, demonstrating that box demands are genuinely independent of the line demands. We close with a program of five conjectures lifting this exact deterministic picture to random, multi-constraint, and quantitative regimes.

**Keywords:** AllDifferent, satisfiability threshold, falling factorial, partition function, complete-graph coloring, monotone event, Latin square, Sudoku, phase transition, constraint satisfaction.

---

## 1. Introduction

Constraint satisfaction problems (CSPs) sit at the interface of logic, combinatorics, and computation. Among the primitive building blocks of practical CSPs, none is more ubiquitous than the **AllDifferent** (or "all-distinct") constraint: a collection of variables that must be assigned pairwise-distinct values from a common domain. AllDifferent constraints model timetabling (no two events in one room at one time), frequency assignment, register allocation, experimental design (Latin squares), and — most famously — Sudoku, in which each row, column, and box is an AllDifferent block over the alphabet $\{1, \dots, 9\}$.

A basic structural question underlies all of these applications: **when is an AllDifferent block satisfiable, and how many solutions does it have?** The pigeonhole principle answers the first question in a sentence — you cannot assign distinct values to more variables than there are values — but the deeper content lies in how *sharply* the answer flips and in how many independent mathematical structures agree on the location of the flip.

This paper develops the answer as a *chain*: each result is built from its predecessor, and the chain follows a single distinguished object — a **partition function** identified with the falling factorial — from an enumerative statement, through an order-theoretic one, to a chromatic one, and finally into concrete facts about Sudoku grids. The unifying theme is that satisfiability of AllDifferent is a **phase transition** with a sharp, exactly-computable boundary at the balance point *demands = resources*, and that this single boundary is visible from three vantage points at once.

### 1.1 Contributions

1. We define the **partition function** $Z(k,m) = k^{\underline m}$ (the falling factorial) and prove it counts satisfying assignments exactly (Theorem 3.1).
2. We prove the order parameter is **positive iff** $m \le k$ and **zero iff** $m > k$ (Theorems 3.2–3.3), yielding the **sharp threshold**: satisfiable iff $m \le k$ (Theorem 4.1).
3. We prove satisfiability is a **monotone, down-closed** event (Theorem 4.2), giving the order-theoretic skeleton of the transition.
4. We establish the **chromatic bridge**: the constraint is a proper coloring of the complete graph $K_m$, colorable with $k$ colors iff $m \le k$ (Theorem 5.1).
5. We show every **Sudoku line sits exactly at the balance point** (Theorem 6.1), and that the **cyclic Latin square** solves lines but fails boxes (Theorems 6.2–6.4), certifying that box constraints are genuinely new.

---

## 2. Definitions

Throughout, $k$ and $m$ denote natural numbers; $k$ is the number of **resources** (available symbols) and $m$ is the number of **demands** (variables required to be pairwise distinct).

**Definition 2.1 (AllDifferent block).** An *AllDifferent block* with $m$ demands over $k$ resources is the constraint that an assignment $f : \{1, \dots, m\} \to \{1, \dots, k\}$ be **injective**. A *satisfying assignment* (or *solution*) is such an injective $f$. The block is *satisfiable* if a solution exists.

**Definition 2.2 (Falling factorial / partition function).** For natural numbers $k, m$, the **falling factorial** is
$$
k^{\underline m} \;=\; \prod_{i=0}^{m-1} (k - i) \;=\; k(k-1)(k-2)\cdots(k-m+1),
$$
with the empty product $k^{\underline 0} = 1$. We define the **partition function** of an AllDifferent block by
$$
Z(k, m) \;:=\; k^{\underline m}.
$$
When $m \le k$ this equals $k!/(k-m)!$; when $m > k$ it is $0$.

**Definition 2.3 (Complete graph).** The *complete graph* $K_m$ has vertex set $\{1,\dots,m\}$ with an edge between every pair of distinct vertices. A **proper $k$-coloring** of a graph $G$ is a map $c$ from vertices to a set of $k$ colors such that adjacent vertices receive different colors; $G$ is **$k$-colorable** if such a $c$ exists.

**Definition 2.4 (Sudoku of order $n$).** For $n \ge 1$, a *Sudoku grid of order $n$* is an $n^2 \times n^2$ array partitioned into $n^2$ boxes of size $n \times n$, to be filled from an alphabet of $n^2$ symbols so that each row, each column, and each box is an AllDifferent block. Classical Sudoku is order $n = 3$.

**Definition 2.5 (Cyclic square).** Over the cyclic group $\mathbb{Z}_N$ of integers modulo $N$, the *cyclic square* is the assignment $L : \mathbb{Z}_N \times \mathbb{Z}_N \to \mathbb{Z}_N$ given by $L(i, j) = i + j \pmod N$.

---

## 3. The partition function as order parameter

The strategic idea of the paper is to replace the yes/no question "is the block satisfiable?" with the quantitative question "how many solutions does it have?" The count is an **order parameter**: a quantity that is strictly positive in one phase and exactly zero in the other, so that its sign locates the transition.

**Theorem 3.1 (Enumerative identity).** *The number of satisfying assignments of an AllDifferent block with $m$ demands over $k$ resources equals $Z(k,m) = k^{\underline m}$. Equivalently, the number of injective maps from an $m$-element set into a $k$-element set is the falling factorial.*

*Proof sketch.* Build an injection one demand at a time. The first demand has $k$ available symbols; having chosen distinct symbols for the first $i$ demands, the $(i+1)$-st demand may take any of the remaining $k - i$ symbols. Multiplying over the $m$ steps yields $\prod_{i=0}^{m-1}(k-i) = k^{\underline m}$. Formally, the set of injective maps is in bijection with the set of embeddings of an $m$-element type into a $k$-element type, whose cardinality is exactly the falling factorial. $\qquad\blacksquare$

**Theorem 3.2 (Positivity of the order parameter).** *$Z(k,m) > 0$ if and only if $m \le k$.*

*Proof sketch.* $Z(k,m)$ is a product of $m$ consecutive descending integers starting from $k$. If $m \le k$, all factors $k, k-1, \dots, k-m+1$ are strictly positive, so the product is positive. If $m > k$, then one of the factors is $k - k = 0$ (reached when $i = k < m$), forcing the product to zero. $\qquad\blacksquare$

**Theorem 3.3 (Vanishing beyond criticality).** *$Z(k,m) = 0$ if and only if $m > k$.*

*Proof sketch.* Immediate contrapositive of Theorem 3.2, since $Z(k,m)$ is a natural number: it is zero exactly when it is not positive, i.e. exactly when $k < m$. $\qquad\blacksquare$

Together, Theorems 3.2 and 3.3 exhibit the defining signature of a sharp transition: the order parameter is strictly positive throughout the satisfiable phase $\{m \le k\}$ and identically zero throughout the unsatisfiable phase $\{m > k\}$, with the switch occurring exactly at the balance point $m = k$.

---

## 4. The sharp threshold and its order-theoretic skeleton

**Theorem 4.1 (Sharp satisfiability threshold).** *An AllDifferent block with $m$ demands over $k$ resources is satisfiable if and only if $m \le k$.*

*Proof sketch.* Satisfiability means the existence of an injective assignment, i.e. that the count of injective assignments is positive. By Theorem 3.1 that count equals $Z(k,m)$, and by Theorem 3.2 it is positive exactly when $m \le k$. Concretely, a witness exists iff the type of embeddings is nonempty iff its cardinality is positive iff $m \le k$. $\qquad\blacksquare$

This is the pigeonhole principle promoted to an exact biconditional and equipped with an explicit solution count. We now record its structural consequence.

**Theorem 4.2 (Monotone down-closure).** *Satisfiability is a down-closed event in the number of demands: if an AllDifferent block with $m$ demands over $k$ resources is satisfiable and $m' \le m$, then the block with $m'$ demands over $k$ resources is also satisfiable.*

*Proof sketch.* By Theorem 4.1 the hypothesis gives $m \le k$; with $m' \le m$ we get $m' \le k$, and Theorem 4.1 again yields satisfiability. (Constructively: restrict any injective assignment on $m$ demands to the first $m'$ of them; a restriction of an injection is an injection.) $\qquad\blacksquare$

Theorem 4.2 is the **order-theoretic skeleton** of the transition. Satisfiability, viewed as a predicate on the number of demands (or, more generally, on a set of imposed clues ordered by inclusion), is monotone: once lost it is never regained. Consequently the satisfiable configurations form a downward-closed set with a single frontier — an up-set boundary — and it is precisely this monotonicity that guarantees the transition is *sharp*, with no reentrant phases.

**Corollary 4.3 (Value at criticality).** *At the balance point $m = k$, the number of solutions is $Z(k,k) = k!$, the number of permutations of the $k$ resources.*

*Proof sketch.* $Z(k,k) = k(k-1)\cdots 1 = k!$. At criticality every solution uses every symbol exactly once, i.e. is a bijection. $\qquad\blacksquare$

**Corollary 4.4 (Collapse just above criticality).** *One demand beyond the balance point forces $Z(k, k+1) = 0$.*

*Proof sketch.* $k + 1 > k$, so Theorem 3.3 gives $Z(k, k+1) = 0$; explicitly the product $k(k-1)\cdots 1 \cdot 0$ contains the factor $0$. $\qquad\blacksquare$

---

## 5. The chromatic bridge

The AllDifferent constraint has a natural graph-theoretic incarnation. Represent each demand as a vertex and join every pair of demands by an edge (they must differ). Assigning symbols so that no two joined demands coincide is precisely a proper coloring.

**Theorem 5.1 (Chromatic bridge).** *The complete graph $K_m$ is $k$-colorable if and only if $m \le k$. Equivalently, the chromatic number of $K_m$ is $m$, and an AllDifferent block on $m$ demands is exactly a proper coloring of $K_m$.*

*Proof sketch.* ($\Rightarrow$) A proper $k$-coloring $c$ of $K_m$ assigns colors to the $m$ vertices such that any two *distinct* vertices, being adjacent, receive distinct colors; hence $c$ is an injective map from $m$ vertices into $k$ colors, and by Theorem 4.1 this forces $m \le k$. ($\Leftarrow$) Conversely, if $m \le k$ then by Theorem 4.1 there is an injective assignment $f$ of the $m$ demands into $k$ symbols; interpreting symbols as colors, $f$ is a proper coloring of $K_m$ because adjacent (i.e. distinct) vertices receive distinct colors by injectivity. $\qquad\blacksquare$

Theorem 5.1 completes the trinity. The **same** boundary $m \le k$ is the positivity region of the falling factorial (enumerative), the down-set of satisfiable demand-counts (order-theoretic), and the colorability region of the complete graph (chromatic). These are not three theorems that happen to share a bound; they are three renderings of one phenomenon, each proved from the sharp threshold of Theorem 4.1.

---

## 6. Application to Sudoku

### 6.1 Every line sits exactly on the threshold

**Theorem 6.1 (Sudoku line at the balance point).** *Each line — row, column, or box — of a Sudoku grid of order $n$ has $m = k = n^2$. Its partition function is $Z(n^2, n^2) = (n^2)!$, which is strictly positive, while $Z(n^2, n^2 + 1) = 0$. Hence $n^2$ is the largest demand count for which the line's partition function is positive, and the line sits exactly at the balance point.*

*Proof sketch.* A line has $n^2$ cells (demands) drawing from $n^2$ symbols (resources), so $m = k = n^2$. By Corollary 4.3, $Z(n^2, n^2) = (n^2)!$, positive by Theorem 3.2 since $n^2 \le n^2$. By Corollary 4.4, $Z(n^2, n^2 + 1) = 0$. $\qquad\blacksquare$

Theorem 6.1 explains the peculiar tautness of Sudoku: every constraint block operates with zero slack. There are exactly as many symbols as cells, so a line is solvable (its solutions are the $(n^2)!$ permutations of the alphabet) but has no margin — one extra distinct demand would be impossible. Sudoku is engineered to live on the knife's edge of the transition, line by line.

### 6.2 The cyclic witness solves lines but fails boxes

The rows-and-columns-only relaxation of Sudoku is exactly the notion of a **Latin square**, and admits a famous closed form.

**Theorem 6.2 (Cyclic rows).** *For each fixed row $i$, the cyclic assignment $j \mapsto L(i,j) = i + j$ over $\mathbb{Z}_N$ is injective; hence every row of the cyclic square is an AllDifferent block.*

*Proof sketch.* The map $j \mapsto i + j$ is left-translation by $i$ in the group $\mathbb{Z}_N$, which is a bijection with inverse $x \mapsto x - i$; a bijection is injective. $\qquad\blacksquare$

**Theorem 6.3 (Cyclic columns).** *For each fixed column $j$, the cyclic assignment $i \mapsto L(i,j) = i + j$ over $\mathbb{Z}_N$ is injective; hence every column of the cyclic square is an AllDifferent block.*

*Proof sketch.* Symmetrically, $i \mapsto i + j$ is translation by $j$, a bijection, hence injective. $\qquad\blacksquare$

Thus the single closed-form witness $L(i,j) = i + j$ solves *all* row and column constraints simultaneously. The boxes, however, are a different matter.

**Theorem 6.4 (Boxes are genuinely new).** *At order $n = 2$ (the $4 \times 4$ grid, $N = 4$), the cyclic witness repeats a symbol inside the top-left $2 \times 2$ box: the distinct cells $(0,1)$ and $(1,0)$ satisfy $L(0,1) = L(1,0) = 1$. Hence the box AllDifferent constraint is not implied by the row and column constraints.*

*Proof sketch.* Compute directly in $\mathbb{Z}_4$: $L(0,1) = 0 + 1 = 1$ and $L(1,0) = 1 + 0 = 1$, while $(0,1) \ne (1,0)$ as cells. Both cells lie in the top-left $2 \times 2$ box, so the box contains a repeated symbol even though the cyclic square is a valid Latin square. Therefore a solution to the row/column relaxation need not solve the full Sudoku, and the box demands carry information independent of the line demands. $\qquad\blacksquare$

Theorem 6.4 is a certified witness for the intuition that **boxes strictly add constraints**: the feasible region of full Sudoku is properly contained in that of the Latin-square relaxation. This is the structural seed of the conjecture (Section 8) that box constraints strictly lower the critical clue density relative to Latin squares.

---

## 7. Algorithmic perspective

The results above are constructive and yield immediate algorithms.

- **Satisfiability decision** is $O(1)$: compare $m$ with $k$ (Theorem 4.1).
- **Solution counting** is $O(m)$ arithmetic operations: evaluate the falling factorial $Z(k,m) = \prod_{i=0}^{m-1}(k-i)$ (Theorem 3.1), short-circuiting to $0$ if a factor hits zero.
- **Witness construction** for a satisfiable block is $O(m)$: assign the $i$-th demand the $i$-th symbol (the identity injection), or use the cyclic rule $L(i,j)=i+j$ for a full Latin square (Theorems 6.2–6.3).
- **Monotone pruning**: because satisfiability is down-closed (Theorem 4.2), any search over sets of clues can prune an entire up-set once a contradiction is found — the algorithmic payoff of the order-theoretic skeleton.

The accompanying numerical demonstrations verify the enumerative identity against brute-force enumeration, exhibit the sign change of the order parameter across the balance point, confirm the chromatic characterization on small complete graphs, and reproduce the box failure of the cyclic square.

---

## 8. Discussion and future directions

The exactness of the deterministic picture — a threshold that is not asymptotic but an exact biconditional, an order parameter available in closed form, and three concurrent characterizations — makes the AllDifferent constraint an unusually clean laboratory for the phase-transition phenomena that pervade constraint satisfaction. We record five directions that lift this picture to the random, multi-constraint, and quantitative regimes.

**1. A sharp clue-density threshold for random puzzles.** Fix the order $n$ and reveal each cell of an $n^2 \times n^2$ grid independently with probability $p$, filling it consistently. We conjecture a critical density $p_c(n)$ below which a completion exists with high probability and above which it does not, with a shrinking transition window. Since satisfiability is monotone in the revealed clues (Theorem 4.2), the transition must be a single up-set boundary; the missing ingredient is probabilistic concentration.

**2. Boxes strictly lower the critical density.** We conjecture the full Sudoku CSP has strictly smaller critical clue density than its row/column (Latin square) relaxation, with a gap bounded below uniformly in $n$. Theorem 6.4 already certifies that the cyclic witness solves lines but fails boxes, so box demands are not implied by line demands.

**3. The vanishing partition function as an analytic order parameter.** We conjecture the falling-factorial partition function admits an analytic continuation in the alphabet size whose real zeros accumulate at the critical demand count, so the transition can be read off the zero set alone. Theorems 3.2–3.3 identify the positivity region exactly, making this an explicit zero-counting problem.

**4. A list-coloring (defective-clue) threshold.** If each cell receives a private list of allowed symbols of size $L$, we conjecture completion becomes possible above a critical $L_c(n)$ strictly below the naive $n^2$. The chromatic bridge (Theorem 5.1) places the AllDifferent = complete-graph-coloring equivalence on firm footing, so list-coloring machinery applies.

**5. Polynomial width of the transition window.** We conjecture the clue-density interval over which the completion probability falls from $0.99$ to $0.01$ shrinks like a fixed negative power of the grid side $n^2$, so the transition becomes discontinuous in the infinite-order limit. With the first moment (the partition function) computed exactly, a second-moment estimate is the remaining step.

---

## 9. Conclusion

We have shown that the atomic AllDifferent constraint has a sharp satisfiability threshold at the balance point *demands = resources* ($m = k$), and that this single boundary is simultaneously enumerative (positivity of the falling factorial), order-theoretic (monotone down-closure), and chromatic (colorability of the complete graph). Applied to Sudoku, the chain reveals that every line of an $n^2 \times n^2$ grid sits exactly on the threshold, and that box constraints are genuinely independent of line constraints, as certified by the cyclic Latin square's failure already at order $n = 2$. The falling-factorial partition function serves throughout as the analytic order parameter of the transition, and it is the natural object on which to build the random, multi-constraint, and quantitative refinements outlined above.
