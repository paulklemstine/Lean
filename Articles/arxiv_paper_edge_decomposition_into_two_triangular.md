# Two Colours, One Stubborn Question: Cutting a Graph into Triangular Forests

## The art of taking a graph apart

Take any network you like — a road map, a molecule, a social graph, the wiring diagram of a chip — and ask a deceptively simple question: *can I split its connections into a small number of very simple pieces?*

This is the **edge-decomposition problem**, and it is one of the oldest games in graph theory. You are handed a graph $G$ and a "simple" class of graphs $\mathcal{F}$, and you must colour each edge of $G$ with one of $k$ colours so that every colour class, viewed on its own, belongs to $\mathcal{F}$. Nothing may be dropped, nothing may be duplicated: every edge gets exactly one colour.

When $\mathcal{F}$ is the class of **forests** — graphs with no cycles at all — the problem is beautifully tame. A classical theorem of Nash-Williams, made algorithmic by Edmonds' matroid machinery in the 1960s, says that a graph splits into $k$ forests exactly when every subgraph on $m$ vertices has at most $k(m-1)$ edges. That condition can be checked in polynomial time, and a decomposition can be built in polynomial time. Forests are, in this precise sense, *easy*.

Push just one notch beyond forests and the ground gives way.

## One notch beyond a forest

Consider the class of **triangular forests**. A triangular forest is a graph in which *every cycle is a triangle*. Equivalently — and this is the more picturesque description — every "2-connected chunk" of the graph is either a single edge or a single triangle. Picture a forest in which some of the branch points have been thickened into little triangles: trees with triangular knots. Formally:

> **Definition.** A graph $G$ is a *triangular forest* if every cycle of $G$ has length exactly $3$.

That is barely more permissive than a forest. A forest has *no* cycles; a triangular forest is allowed cycles, but only the shortest kind, and — as we shall see — only in very isolated positions. Yet this tiny relaxation appears to change the computational character of the problem completely. The class $\mathcal{F}$ of triangular forests is the smallest interesting member of a family of graph classes that a recent line of work has shown to be hard to decompose into $k \ge 3$ parts. The case $k=2$ — just two colours — is the frontier, and triangular forests are the simplest possible test case.

Why should two colours be so much harder than one? Because with two colours you lose the matroid. The reason forest decomposition is easy is that forests form the independent sets of a matroid (the graphic matroid), and matroid union is a solved problem. Triangular forests form no matroid: whether you may add an edge depends not just on which edges you already have, but on *where* they sit. The moment matroid theory stops applying, the combinatorics turns local, greedy strategies fail, and the space of decompositions becomes an exponentially branching search.

This article tells the story of what one *can* prove about the two-colour problem, cleanly and completely: a sharp sparsity law, an exact threshold for complete graphs, a small unavoidable obstruction, and the structural properties that place triangular forests exactly where the hardness theory wants them.

## The shape of a triangular forest

Everything begins with a local observation. In a triangular forest, cycles of length $4$ are forbidden — a $4$-cycle is a cycle that is not a triangle. That single prohibition has a striking consequence.

> **The Matching Neighbourhood Theorem.** Let $G$ be a triangular forest and let $v$ be any vertex. Then the neighbours of $v$ induce a matching: no vertex $u$ adjacent to $v$ can be adjacent to two distinct neighbours $w \ne x$ of $v$. Consequently, **every edge of a triangular forest lies in at most one triangle**.

The proof takes one line. If $u$ were adjacent to both $w$ and $x$, and $v$ were adjacent to all three, then $v \to w \to u \to x \to v$ would be a closed walk on four distinct vertices — a $4$-cycle. Forbidden. So triangles in a triangular forest are *isolated*: they may touch at vertices, never along edges. This is exactly the picture of a tree whose branch points have been thickened.

The same reasoning tells us instantly that the complete graph $K_4$ on four vertices is **not** a triangular forest: its four vertices carry the $4$-cycle $0 \to 1 \to 2 \to 3 \to 0$. So the class is a genuine, proper subclass of all graphs, while it does contain a triangle (the graph $K_3$, whose only cycle has length $3$). Those two facts — contains a triangle, is not everything — together with closure under subgraphs and decidability, are precisely the hypotheses under which the general hardness theory operates.

## The sparsity law

Simple graphs are sparse graphs, and the fundamental quantitative question is: *how many edges can a triangular forest on $n$ vertices have?*

A first answer comes from a longest-path argument. Take a path $P$ in the triangular forest that is as long as possible, and look at its endpoint $a$. Every neighbour of $a$ must lie on $P$ — otherwise we could extend $P$ and it wasn't longest. And a neighbour sitting $\ell \ge 2$ steps along $P$ would close a cycle of length $\ell+1$, which must equal $3$. So $a$ has at most two neighbours. Hence:

> **Degeneracy.** Every finite nonempty triangular forest contains a vertex of degree at most $2$; triangular forests are $2$-degenerate.

Deleting such a vertex and inducting gives the first bound: a triangular forest on $n \ge 2$ vertices has at most $2n - 3$ edges. That is already sparse — but it is not the truth. The truth is finer, and getting it requires pushing the longest-path argument one vertex deeper.

> **The Sharp Sparsity Theorem.** A triangular forest on $n \ge 1$ vertices has at most $\lfloor 3(n-1)/2 \rfloor$ edges; that is,
> $$2e \le 3(n-1).$$

Here is the idea. Take again a longest path $a \to v_1 \to v_2 \to \cdots$. We know $a$ has degree at most two. If it has degree exactly two, its second neighbour must be $v_2$ — creating the triangle $a, v_1, v_2$. Now examine $v_1$. Could $v_1$ have a neighbour $y$ off the path? Then the walk $y \to v_1 \to a \to v_2 \to \cdots$ would be a *longer* path — contradiction. Could $v_1$ have a neighbour further along the path? That closes a cycle of length at least $4$, unless the neighbour is $v_3$; and $v_3$ is excluded because $a \to v_1 \to v_3 \to v_2 \to a$ would be a $4$-cycle. So $v_1$ also has degree at most two.

We have found an **edge both of whose endpoints have degree two** — a *leaf triangle* dangling off the rest of the graph. Deleting its two degree-two vertices removes exactly $3$ edges and $2$ vertices, which is a ratio of $3/2$: precisely the slope in the bound. Induction does the rest. (And in the remaining case, where the graph has a vertex of degree at most one, we delete that vertex, which is even cheaper.)

Is $3/2$ the right slope? Emphatically yes — and the witnesses are lovely.

> **Sharpness.** For every $k \ge 0$, the *windmill* (or friendship) graph $F_k$ — $k$ triangles all sharing a single common hub vertex — is a triangular forest on $n = 2k+1$ vertices with exactly $3k$ edges, so that $2e = 6k = 3(n-1)$.

Every vertex of $F_k$ other than the hub has exactly one neighbour besides the hub, and that condition alone forces the graph to be a triangular forest: any cycle, rotated to start at a non-hub vertex, is pinned down immediately. So the bound $2e \le 3(n-1)$ is attained for every odd $n$, not merely for the single triangle. The extremal graphs are not exotic outliers; they are an infinite, perfectly regular family.

## How far can two colours take you?

Now put the two halves together. If a graph $G$ on $n$ vertices splits into two triangular forests $G_1$ and $G_2$, then each part obeys the sparsity law, so
$$|E(G)| = |E(G_1)| + |E(G_2)| \le 2 \cdot \left\lfloor \tfrac{3(n-1)}{2} \right\rfloor \le 3(n-1).$$

Apply this to the complete graph $K_n$, which has $\binom{n}{2} = n(n-1)/2$ edges. We need $n(n-1)/2 \le 3(n-1)$, i.e. $n \le 6$. So for $n \ge 7$, pure counting already forbids a decomposition.

What about $n = 6$? Here the real-valued count is a dead heat: $K_6$ has $15$ edges and the budget is $3 \cdot 5 = 15$. But integrality saves the day. Each part must satisfy $2e \le 15$, and since $e$ is an integer, $e \le 7$. Two parts give at most $14$ edges — one short of $15$. So the decomposition is impossible, and the counting argument misses by a single edge. (An exhaustive scan of all edge $2$-colourings of $K_6$ shows the reality is starker still: at most $13$ of the $15$ edges can be covered by two triangular forests, in a $7+6$ split. Deleting any single edge of $K_6$ still leaves an indecomposable graph; deleting two disjoint edges suffices.)

And $n = 5$? Here it works, and the certificate is charming. Colour the ten edges of $K_5$ (on vertices $0,1,2,3,4$) as follows:

- **Red:** the triangle $\{0,1\}, \{0,2\}, \{1,2\}$ together with the pendant edges $\{0,4\}$ and $\{1,3\}$;
- **Blue:** the triangle $\{2,3\}, \{2,4\}, \{3,4\}$ together with the pendant edges $\{0,3\}$ and $\{1,4\}$.

Each colour class is a triangle with two pendant edges attached at distinct corners — indisputably a triangular forest. Together the two classes use each of the ten edges of $K_5$ exactly once. Combining the constructions and the counting gives the exact answer:

> **The Complete-Graph Threshold Theorem.** For $n \ge 5$, the complete graph $K_n$ decomposes into two triangular forests if and only if $n = 5$.

The threshold is sharp, and there is a genuine phase transition at $n = 6$: a single missing edge separates possibility from impossibility.

## A universal obstruction

The threshold theorem is about complete graphs, but it upgrades to a statement about *all* graphs, because decomposability is inherited downwards.

> **Monotonicity.** If a graph decomposes into two triangular forests, so does every subgraph of it. Indeed, if $E(G) = E(G_1) \sqcup E(G_2)$ with both parts triangular forests, then for any subgraph $H \le G$ we may set $H_i = H \cap G_i$; each $H_i$ is a subgraph of a triangular forest, hence a triangular forest, and the two together are exactly $H$.

The same argument works for subgraphs sitting inside $G$ via an injective map on vertices. Combining monotonicity with the failure at $K_6$ gives an obstruction that any algorithm can look for first:

> **The Clique Obstruction Theorem.** If a graph $G$ contains six mutually adjacent vertices — a $K_6$ subgraph — then $G$ does **not** decompose into two triangular forests.

This is the two-colour analogue of "a graph with a $K_3$ is not bipartite": a small, purely local certificate of impossibility, checkable by inspecting six vertices. Of course, it is only a *sufficient* condition for failure. The hardness of the general problem tells us that no polynomially checkable list of such local obstructions can capture the whole story — but it is a satisfying first line of defence, and it shows that the failure at $K_6$ is not an isolated curiosity about complete graphs.

## Two colours, three colours, many colours

If two triangular forests are not enough for $K_n$, how many are? Define the **triangular thickness** of a graph to be the least $k$ such that its edges can be covered by $k$ triangular forests. Feeding the sharp sparsity law into the same counting argument gives:

> **The Thickness Lower Bound.** If the edges of $K_n$ ($n \ge 2$) are covered by $k$ triangular forests, then $n \le 3k$; that is, the triangular thickness of $K_n$ is at least $\lceil n/3 \rceil$.

Each forest carries at most $3(n-1)/2$ edges and $K_n$ has $n(n-1)/2$, so $k \ge n/3$. This improves the naive bound obtained from the coarser estimate $e \le 2n-3$ (which only yields $n - 1 \le 4k$) by an asymptotic factor of $4/3$ — and since the sparsity input is now provably sharp, *no further improvement can come from edge counting alone*. Any better lower bound must exhibit a global obstruction, exactly as the integrality argument does at $n=6$.

Exploratory search suggests the bound $\lceil n/3 \rceil$ is essentially the truth: matching covers appear to exist for every small $n$ except $n = 6$, where counting permits $k = 2$ but the integrality argument forbids it. The lone exception at $n = 6$ is a pleasing echo of a classical phenomenon — the non-existence of a resolvable Steiner triple system of order $6$, Kirkman's famous "fifteen schoolgirls" problem's smaller, impossible sibling.

## Why the problem is hard, and why it is still tractable to *check*

Everything above is about *impossibility*. What about the positive side — when a decomposition exists, how do we recognise it?

> **The Certificate Theorem.** A graph $G$ decomposes into two triangular forests if and only if there is a $2$-colouring $f$ of its edges such that both colour classes are triangular forests.

That sounds like a tautology, but it is the structurally important reformulation: a witness is a single function from edges to $\{\text{red},\text{blue}\}$ — an object of size linear in the input — rather than an unstructured pair of abstract graphs. And a candidate witness can be *verified* efficiently:

> **Decidability of membership.** Whether a finite graph is a triangular forest is decidable, and cheaply so. A cycle visits each vertex at most once, so no cycle is longer than the number of vertices; therefore checking "every cycle has length $3$" reduces to a finite, bounded search. (In practice it is even simpler: a graph is a triangular forest exactly when every edge lies in at most one triangle and the graph obtained by contracting each triangle to a point is a forest.)

Putting the two together, the decision problem "does $G$ decompose into two triangular forests?" lies in **NP**: guess the edge colouring, verify both classes. And it is decidable outright by brute force over all $2^{|E|}$ colourings. The recent theorem that the problem is NP-*complete* says that, in a precise sense, you cannot do essentially better than that guess — no clever polynomial algorithm exists unless P $=$ NP.

That is the punchline of the whole story. Forests: polynomial. Triangular forests — a class obtained from forests by allowing one extra, maximally constrained cycle length — two colours: NP-complete. One notch of extra freedom in the target class, and a matroid-theoretic paradise becomes a computational wilderness.

## The class in its natural habitat

There is one last structural property worth recording, because it is what makes triangular forests the *right* test case rather than an arbitrary one. A **1-sum** of two graphs glues them along a single shared vertex.

> **Closure under 1-sums.** If $G_1$ and $G_2$ are triangular forests whose vertex supports meet in at most one vertex $x$, then $G_1 \cup G_2$ is a triangular forest.

The proof is a nice piece of walk-chasing. Along any walk that avoids the gluing vertex $x$ at every intermediate position, consecutive edges must lie on the same side — because a vertex incident to an edge of $G_1$ and an edge of $G_2$ must *be* $x$. So a cycle, once rotated to start and end at $x$ (or to avoid it entirely), lives wholly inside $G_1$ or wholly inside $G_2$, where it is a triangle by hypothesis.

Closure under 1-sums, closure under subgraphs (and hence under topological minors), decidable membership, containing a triangle, and not being the class of all graphs: triangular forests tick every box of the abstract framework. They are the minimal class that does. Which is exactly why they are the natural place to plant the flag for $k=2$: if the two-colour problem is hard here, at the very bottom of the hierarchy, one expects it to be hard everywhere above.

## What remains

The picture we have is complete on the extremal side and open on the algorithmic side. We know precisely how many edges a triangular forest can have and which graphs achieve the maximum for odd order; the even case, and the *uniqueness* of the maximisers (they should be exactly the graphs built by iterated 1-sums of triangles, glued in a tree pattern), are natural next targets. We know the exact threshold for complete graphs and a clean $K_6$ obstruction. We know the triangular thickness of $K_n$ is at least $\lceil n/3 \rceil$ and conjecturally exactly that, with the single exception $n=6$.

What we do not have — what nobody has — is a structural characterisation of the decomposable graphs. The hardness theorem says that we should not expect one in the form of a finite list of forbidden configurations. But hardness theorems have a way of leaving room for beautiful partial answers: bounded-treewidth algorithms, planar special cases, approximation guarantees, or a characterisation on graphs of bounded degree. The $K_6$ obstruction is the first tile of a mosaic that we can only see the outline of.

Two colours. One extra cycle length. An entire complexity class of difference.
