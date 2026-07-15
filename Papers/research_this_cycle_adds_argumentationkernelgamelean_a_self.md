# Stable Argumentation, Directed Kernels, and Terminating Games

## Abstract

We develop a self-contained dictionary among three notions: stable extensions of abstract argumentation frameworks, kernels of directed graphs, and P-position solutions of normal-play games. Reversing the arrows of an attack relation converts stability exactly into the kernel property, while the kernel axioms are equivalent to the recursive condition that a position is losing precisely when all of its options are non-losing. This correspondence yields several consequences. Terminal positions belong to every kernel, so the normal-play terminal convention follows from independence and absorption. The directed three-cycle has no kernel and hence no stable extension or consistent win–loss solution. In contrast, the directed four-cycle has two distinct alternating stable extensions. For well-founded move relations, recursive evaluation defines a kernel, and well-founded induction proves that it is unique. Thus every terminating normal-play game has a unique P-position solution, and every well-founded argumentation framework has a unique stable extension. We give finite algorithms, examples, applications, and directions toward cycle classification, kernel-perfect digraphs, grounded semantics, and Sprague–Grundy theory.

## 1. Introduction

Directed relations arise under different names in several disciplines. In abstract argumentation, an arrow records that one argument attacks another. In directed graph theory, arrows determine independent and absorbing subsets called kernels. In combinatorial game theory, arrows are legal moves, and one seeks the losing positions under normal play. The definitions look similar, but their arrow conventions obscure an exact identification.

The central observation is that reversing all attacks resolves the discrepancy. A stable extension attacks every excluded argument, whereas every vertex excluded from a kernel points toward the kernel. Consequently, stability for a relation is kernelhood for its transpose. A second observation is that the two kernel axioms combine into the familiar game recursion: a position lies in the kernel if and only if every legal option lies outside it.

This translation has substantive consequences. It identifies a common obstruction: the directed triangle has no stable extension, no kernel, and no consistent P-position labeling. It also distinguishes existence from uniqueness: the directed square has two alternating solutions. Finally, it identifies the structural source of determinacy. If play cannot continue indefinitely, recursive win–loss evaluation is legitimate; it produces a kernel, and induction along the well-founded relation makes that kernel unique.

The results apply to arbitrary, possibly infinite sets. No finiteness or decidability assumption is needed for the structural equivalences. Finiteness becomes relevant only when discussing explicit enumeration algorithms.

## 2. Directed relations and reversal

Let $X$ be a set and let $R\subseteq X\times X$ be a binary relation. We write $R(x,y)$ or $x\to y$ when an arrow runs from $x$ to $y$.

**Definition 2.1 (Reversed relation).** The reverse, transpose, or opposite relation $R^{\mathrm{op}}$ is defined by

$$
R^{\mathrm{op}}(x,y) \Longleftrightarrow R(y,x).
$$

Reversal is involutive: $(R^{\mathrm{op}})^{\mathrm{op}}=R$.

**Definition 2.2 (Independent set).** A subset $K\subseteq X$ is independent for $R$ if no arrow of $R$ joins two of its members. Explicitly,

$$
\forall x,y\in K,\quad \neg R(x,y).
$$

This directed formulation excludes every arrow whose source and target both lie in $K$. In particular, a vertex with a loop cannot belong to an independent set.

**Definition 2.3 (Absorbing set).** A subset $K\subseteq X$ is absorbing for $R$ if each excluded vertex has an outgoing arrow into $K$:

$$
\forall x\notin K,\quad \exists y\in K\text{ such that }R(x,y).
$$

**Definition 2.4 (Kernel).** A kernel of $R$ is a subset $K\subseteq X$ that is both independent and absorbing.

The word “kernel” here is the directed-graph notion associated with von Neumann and Morgenstern, not the null space of a linear map. It balances an internal prohibition with an external coverage property.

## 3. Stable extensions

Interpret $R(x,y)$ as “argument $x$ attacks argument $y$.”

**Definition 3.1 (Conflict-free set).** A subset $S\subseteq X$ is conflict-free if

$$
\forall x,y\in S,\quad \neg R(x,y).
$$

**Definition 3.2 (Stable extension).** A subset $S\subseteq X$ is stable for $R$ if it is conflict-free and attacks every argument outside it:

$$
\forall x\notin S,\quad \exists y\in S\text{ such that }R(y,x).
$$

A stable extension is internally compatible and externally decisive. The quantifier pattern is almost that of a kernel, but the covering arrow points outward from $S$ rather than inward toward it.

**Theorem 3.3 (Stable–Kernel Equivalence).** For every relation $R$ on $X$ and every subset $S\subseteq X$,

$$
S\text{ is stable for }R
\quad\Longleftrightarrow\quad
S\text{ is a kernel of }R^{\mathrm{op}}.
$$

**Proof sketch.** Conflict-freeness is invariant under reversal: an arrow between two members remains an internal arrow after its direction is reversed. For the external condition, an excluded $x$ is attacked by some $y\in S$ exactly when $R(y,x)$, which is equivalent to $R^{\mathrm{op}}(x,y)$. Thus the stable coverage condition for $R$ is precisely absorption for $R^{\mathrm{op}}$. The two pairs of defining conditions coincide. $\square$

No acyclicity, finiteness, or choice principle is involved. This is a direct equivalence of definitions.

## 4. Normal-play game solutions

Interpret $R(x,y)$ as “the player to move may move from $x$ to $y$.” A P-position is losing for the player about to move and winning for the previous player; an N-position is winning for the next player.

**Definition 4.1 (P-position solution).** A subset $P\subseteq X$ is a game solution for $R$ if, for every $x\in X$,

$$
x\in P
\quad\Longleftrightarrow\quad
\forall y\in X,\; R(x,y)\Rightarrow y\notin P.
$$

The forward implication says that no move leads from one P-position to another. The reverse implication says that if all options are outside $P$, then the current position is in $P$. Its contrapositive states that every position outside $P$ has at least one move into $P$.

**Theorem 4.2 (Kernel–Game Equivalence).** A subset $P\subseteq X$ is a kernel of $R$ if and only if it is a P-position solution for $R$.

**Proof sketch.** Suppose first that $P$ is a kernel. If $x\in P$, independence implies that every successor $y$ lies outside $P$. Conversely, if every successor of $x$ lies outside $P$ but $x\notin P$, absorption supplies a successor in $P$, a contradiction. Hence the biconditional in Definition 4.1 holds.

Conversely, suppose the biconditional holds. If $x,y\in P$ and $R(x,y)$, the forward implication at $x$ says $y\notin P$, a contradiction; thus $P$ is independent. If $x\notin P$, the right side of the biconditional must be false, so there exists $y$ with $R(x,y)$ and $y\in P$. Thus $P$ is absorbing. $\square$

Combining Theorems 3.3 and 4.2 yields the full dictionary.

**Corollary 4.3 (Three-Way Dictionary).** For every attack relation $R$ and subset $S\subseteq X$, the following are equivalent:

1. $S$ is a stable extension of $R$;
2. $S$ is a kernel of $R^{\mathrm{op}}$;
3. $S$ is a P-position solution of the reversed-arrow game $R^{\mathrm{op}}$.

This corollary permits any result stated in one vocabulary to be translated into the other two.

## 5. Terminal positions and the boundary condition

**Definition 5.1 (Terminal position).** A position $t\in X$ is terminal if it has no outgoing move:

$$
\forall y\in X,\quad \neg R(t,y).
$$

**Proposition 5.2 (Terminal Positions Are Forced into Kernels).** If $K$ is any kernel of $R$ and $t$ is terminal, then $t\in K$.

**Proof sketch.** If $t\notin K$, absorption requires some $y\in K$ with $R(t,y)$. This contradicts terminality. $\square$

**Corollary 5.3.** Every terminal position belongs to every P-position solution.

This shows that the normal-play boundary rule is a theorem of the kernel axioms. Once independence and absorption are imposed, a position with no move cannot consistently be classified as winning.

## 6. Cyclic obstructions and multiplicity

### 6.1 The directed triangle

Let $C_3$ be the relation on $\{0,1,2\}$ with arrows

$$
0\to1,\qquad 1\to2,\qquad 2\to0.
$$

**Theorem 6.1 (No Kernel on the Directed Three-Cycle).** The directed cycle $C_3$ has no kernel.

**Proof sketch.** An empty set is not absorbing. Suppose a kernel $K$ is nonempty and, by cyclic symmetry, take $0\in K$. Independence forces $1\notin K$. Because $1$ has only the successor $2$, absorption forces $2\in K$. But $2\to0$ is then an arrow between two members of $K$, contradicting independence. The same argument applies regardless of which vertex is initially chosen. $\square$

**Corollary 6.2 (No Stable Extension on the Directed Three-Cycle).** The directed three-cycle has no stable extension.

**Proof sketch.** Reversing a directed three-cycle produces another directed three-cycle. Apply Theorem 3.3 and Theorem 6.1. $\square$

**Corollary 6.3 (No Consistent Win–Loss Labeling).** The move graph $C_3$ has no P-position solution.

The obstruction can also be read as failed alternation. If $0$ is P, then $2$ is N, then $1$ is P, which forces $0$ to be N. An odd number of negations cannot close consistently around the cycle.

### 6.2 The directed square

Let $C_4$ be the relation on $\{0,1,2,3\}$ with arrows

$$
0\to1,\qquad 1\to2,\qquad 2\to3,\qquad 3\to0.
$$

**Proposition 6.4 (Alternating Kernel of the Four-Cycle).** The set $\{0,2\}$ is a kernel of $C_4$.

**Proof sketch.** There is no arrow between $0$ and $2$, so the set is independent. The excluded vertex $1$ points to $2$, and the excluded vertex $3$ points to $0$, so it is absorbing. $\square$

**Theorem 6.5 (Two Stable Extensions of the Four-Cycle).** The directed four-cycle has the two distinct stable extensions

$$
\{0,2\}\qquad\text{and}\qquad\{1,3\}.
$$

**Proof sketch.** In each alternating pair, no selected vertex attacks the other. Every excluded vertex is attacked by the preceding selected vertex. Hence both sets satisfy conflict-freeness and stable coverage. They are distinct because, for example, $0$ belongs only to the first. $\square$

The square establishes that dropping well-foundedness can lead not only to nonexistence, as on $C_3$, but also to nonuniqueness. Parity explains these examples: an alternating binary labeling closes on an even cycle and fails on an odd one.

## 7. Well-founded recursion

Cycles make definitions circular. To recover existence and uniqueness, we rule out infinite descent along moves.

**Definition 7.1 (Well-founded move relation).** A move relation $R$ is well-founded for backward induction if there is no infinite play

$$
x_0\to x_1\to x_2\to\cdots.
$$

Equivalently, every nonempty collection of positions contains a position with no successor inside that collection. For a finite graph, this condition is equivalent to acyclicity.

When $R$ is well-founded, one can define a predicate $L(x)$ recursively by

$$
L(x) \Longleftrightarrow \forall y,\; R(x,y)\Rightarrow \neg L(y).
$$

The value at $x$ depends only on values strictly later in play. Well-foundedness guarantees that the recursion is legitimate even if $X$ is infinite and game lengths have no uniform finite bound.

**Lemma 7.2 (Recursive Losing-Position Equation).** The recursively defined predicate $L$ satisfies, for every $x\in X$,

$$
L(x) \Longleftrightarrow \forall y,\; R(x,y)\Rightarrow \neg L(y).
$$

This is the unfolding equation of well-founded recursion.

**Theorem 7.3 (Existence of a Kernel in a Well-Founded Digraph).** If $R$ is well-founded, then

$$
K_L=\{x\in X:L(x)\}
$$

is a kernel of $R$.

**Proof sketch.** If $x\in K_L$ and $R(x,y)$, the recursive equation gives $y\notin K_L$. Hence no arrow joins two members of $K_L$, proving independence. If $x\notin K_L$, then the universal condition on the right side of the equation is false. Therefore some successor $y$ satisfies $L(y)$, so $y\in K_L$. This proves absorption. $\square$

The next result is the key uniqueness argument.

**Theorem 7.4 (Uniqueness of Kernels under Well-Foundedness).** A well-founded directed relation has at most one kernel.

**Proof sketch.** Let $K$ and $M$ be kernels. Use well-founded induction on $x$, assuming that membership in $K$ and $M$ agrees for every successor of $x$. Suppose $x\in K$ but $x\notin M$. Since $M$ is absorbing, some successor $y$ of $x$ lies in $M$. By the induction hypothesis, $y\in K$, contradicting independence of $K$. The case $x\in M$ but $x\notin K$ is symmetric. Hence membership agrees at $x$, and induction yields $K=M$. $\square$

Combining existence and uniqueness gives the main graph theorem.

**Theorem 7.5 (Unique Kernel Theorem).** Every well-founded directed graph has exactly one kernel, namely the recursively defined set of losing positions $K_L$.

## 8. Determinacy and stable semantics

The game-theoretic consequence is immediate.

**Theorem 8.1 (Determinacy of Terminating Normal-Play Games).** If a normal-play game admits no infinite sequence of moves, then it has exactly one P-position solution. A position is in that solution precisely when all of its legal options lie outside it.

**Proof sketch.** The well-founded move relation has a unique kernel by Theorem 7.5, and kernels are exactly P-position solutions by Theorem 4.2. $\square$

This is a form of Zermelo-style backward determinacy for terminating perfect-information games. It supplies not only labels but a strategy: from any N-position, absorption gives a move to a P-position. From a P-position, every move goes to an N-position.

For argumentation, arrow reversal must be handled explicitly.

**Definition 8.2 (Well-founded attack framework).** An attack relation $A$ is well-founded if there is no infinite backward attack chain

$$
x_0\leftarrow x_1\leftarrow x_2\leftarrow\cdots,
$$

or equivalently if the reversed relation $A^{\mathrm{op}}$ is a well-founded move relation.

**Theorem 8.3 (Unique Stable Extension under Well-Foundedness).** Every well-founded attack framework has exactly one stable extension.

**Proof sketch.** Since $A^{\mathrm{op}}$ is well-founded, Theorem 7.5 gives it a unique kernel. By Theorem 3.3, kernels of $A^{\mathrm{op}}$ are exactly stable extensions of $A$. Therefore existence and uniqueness transfer directly. $\square$

The cycle examples show that the hypothesis has real content. The odd cycle may destroy existence, while the even cycle may destroy uniqueness.

## 9. Algorithms

### 9.1 Backward evaluation on a finite acyclic graph

For a finite acyclic move graph, choose a topological ordering in which every successor of a vertex is processed earlier. Label a vertex P if all of its successors are labeled N; otherwise label it N. The P-vertices form the unique kernel.

With adjacency lists, topological sorting and labeling each take $O(|X|+|R|)$ time and $O(|X|+|R|)$ storage. If a winning strategy is desired, store one P-successor for each N-vertex.

**Algorithm 9.1 (Backward Kernel Evaluation).**

1. Compute a reverse topological order of the vertices.
2. Initialize all labels as unknown.
3. Process vertices in that order.
4. Label $x$ P if every successor is already labeled N.
5. Otherwise label $x$ N and record a successor labeled P.
6. Return the set of P-labeled vertices.

Correctness follows from Lemma 7.2 and Theorem 7.5.

### 9.2 Exhaustive kernel enumeration

For small cyclic graphs, all subsets can be tested. A candidate is rejected if it contains an internal arrow or if some excluded vertex has no edge into the candidate. This requires $O(2^{|X|}(|X|+|R|))$ time in a straightforward implementation and $O(|X|+|R|)$ auxiliary space beyond the output. It is not intended for large graphs, but it transparently demonstrates zero kernels on $C_3$ and two on $C_4$.

### 9.3 Stable-extension enumeration

Stable extensions can be enumerated either directly or by reversing every edge and enumerating kernels. The latter method makes the bridge operational. For each candidate $S$, verify conflict-freeness and check that every excluded vertex is attacked by some member of $S$. Its worst-case complexity is again exponential because the output itself may be large.

## 10. Applications

### 10.1 Structured debate and explainable decisions

An attack graph can model incompatible claims, legal arguments, diagnostic hypotheses, or policy proposals. A stable extension is a coherent accepted set that directly rebuts every rejected item. When the framework is well-founded, backward evaluation yields a unique verdict and an explanation chain: every excluded argument is defeated by an included one, and every included argument survives all relevant responses.

### 10.2 Game solving and planning

In a terminating game or planning system, the unique kernel marks states from which no move preserves kernel membership. Every non-kernel state has a transition into the kernel. This immediately gives a positional strategy and classifies terminal states without a separate special case.

### 10.3 Dependency networks

A kernel can select mutually noninteracting representatives while ensuring that every unselected vertex delegates to a selected one. In acyclic workflows, the unique selection is computable by backward evaluation. Cyclic dependencies warn that the selection may be absent or ambiguous.

### 10.4 Translation as a method

The dictionary transfers techniques between fields. Game recursion proves existence of graph kernels. Kernel obstructions explain failure of stable semantics. Argumentation terminology interprets multiple game solutions as competing coherent global positions. The value of the bridge lies in allowing a theorem, counterexample, or algorithm to travel without being reproved from scratch in each language.

## 11. Discussion

Three structural regimes emerge.

First, odd cyclic feedback can make the local rule globally inconsistent. The triangle is the minimal example: alternation around an odd loop returns with the opposite label.

Second, even cyclic feedback may permit several global solutions. The square supports two phases of the same alternating pattern. Thus the mere existence of a kernel does not imply determinacy.

Third, well-foundedness removes circular dependence altogether. Every recursive query eventually reaches terminal information, giving existence. The same order supports an induction comparing any two candidates, giving uniqueness.

The theorem on terminal positions is conceptually important in this classification. Terminal loss is often introduced as a rule of normal play. Here it is forced by absorption, showing that the graph-theoretic axioms already encode the boundary behavior of the game.

The results concern binary outcome classes. They do not yet measure the richer combinatorial structure of impartial games, distinguish among multiple winning moves, or analyze infinite play conventions. Nor do they classify kernels of all finite digraphs. Their purpose is to establish the exact common core on which those extensions can be built.

## 12. Future work

A first direction is a uniform classification of directed cycles. For positive even length, the two alternating subsets should be exactly the kernels; for odd length, no kernel exists. This would turn the triangle and square into instances of a complete parity theorem.

A second direction is kernel-perfectness: conditions ensuring that every induced subgraph has a kernel. Finite acyclic digraphs are a natural starting point, followed by broader hypotheses excluding odd directed cycles.

A third direction is to compare the recursively defined stable extension with grounded argumentation semantics. In a well-founded framework, one expects the unique stable extension to coincide with the least fixed point obtained by iterating the characteristic defense operator.

A fourth direction replaces the Boolean losing predicate by a Sprague–Grundy value. For an impartial terminating game, define

$$
g(x)=\operatorname{mex}\{g(y):R(x,y)\},
$$

where $\operatorname{mex}$ is the least excluded nonnegative integer. The zero-value positions should be exactly the kernel, while nim-addition should describe disjunctive sums.

Finally, algorithmic work may seek output-sensitive enumeration for cyclic graphs, compact certificates for nonexistence, and dynamic updates when attacks or moves are inserted and removed.

## 13. Conclusion

Stable argumentation, directed kernels, and normal-play P-positions are linked by an exact change of viewpoint. Reversing attacks converts stable extensions into kernels, and kernelhood is equivalent to the recursive losing-position equation. Terminal positions are therefore necessarily losing. The directed triangle demonstrates nonexistence, while the directed square demonstrates multiplicity. Well-foundedness eliminates both pathologies: recursive evaluation constructs a kernel, and induction proves it unique. The resulting theorem simultaneously expresses determinacy for terminating games, unique kernel existence for well-founded digraphs, and unique stable semantics for well-founded argumentation frameworks.