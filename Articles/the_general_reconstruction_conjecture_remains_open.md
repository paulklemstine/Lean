# Reconstructing a Graph from Its Missing-Vertex Snapshots

## The puzzle of the shuffled deck

Imagine a network drawn on a sheet of paper. Its dots are vertices and its lines are edges. Now make one copy of the drawing for each vertex, erase a different vertex from every copy, and erase every line that touched the missing vertex. Finally, shuffle the copies.

Could someone recover the original network?

This is the graph reconstruction problem. Each altered copy is called a **vertex-deleted card**, and the collection of all cards is the graph’s **deck**. The celebrated Reconstruction Conjecture says that every finite simple graph with at least three vertices is determined, up to relabeling, by its deck. “Simple” means that no edge begins and ends at the same vertex and no pair of vertices carries more than one edge. “Up to relabeling” is essential: the names attached to vertices do not matter; only the pattern of adjacency matters.

The general conjecture remains open. Yet the deck is far from mute. A clean counting principle explains how local snapshots preserve global information, and it already reconstructs two opposite kinds of networks—the graph with no edges and the graph with every possible edge. It also shows that taking complements, which exchanges edges and nonedges, respects the entire reconstruction problem.

## What the cards remember

Let $G$ be a finite simple graph with vertex set $V$, and let $n=|V|$. For a vertex $v$, the card $G-v$ is the induced graph on $V\setminus\{v\}$: two surviving vertices are adjacent in $G-v$ exactly when they were adjacent in $G$.

Two graphs $G$ and $H$ have the **same deck** if their vertices can be paired so that deleting paired vertices produces isomorphic cards. This paired formulation remembers multiplicity: if one card shape occurs several times, every occurrence counts.

The first key idea is broader than graphs. Suppose $\mathcal A$ is any family of $k$-element subsets of an $n$-element set. Say that $A\in\mathcal A$ **survives deletion of $v$** when $v\notin A$. Count all pairs $(v,A)$ for which $A$ survives deletion of $v$.

For a fixed vertex $v$, the number of such pairs is the number of members surviving that deletion. But for a fixed set $A$, exactly $n-k$ vertices lie outside $A$, so $A$ survives exactly $n-k$ deletions. Counting the same pairs in these two ways gives the Double-Counting Identity:

$$
\sum_{v\in V}|\{A\in\mathcal A:v\notin A\}|=(n-k)|\mathcal A|.
$$

This tiny equation is the engine of the story. Every object supported on $k$ vertices appears in precisely the cards obtained by deleting one of the other $n-k$ vertices.

## Kelly’s counting principle

Now choose a finite pattern graph $F$ with $k$ vertices. An **induced copy of $F$ in $G$** is a $k$-element vertex set $S\subseteq V$ for which the graph induced by $G$ on $S$ is isomorphic to $F$. Copies are counted by their vertex sets, not by the number of isomorphisms from $F$ onto them.

Apply the Double-Counting Identity to the family of all vertex sets inducing $F$. A copy on $S$ remains visible in the card $G-v$ exactly when $v\notin S$. Therefore the total number of induced copies of $F$ seen across all cards is

$$
\sum_{v\in V}N_F(G-v)=(n-k)N_F(G),
$$

where $N_F(X)$ denotes the number of vertex subsets of $X$ inducing a graph isomorphic to $F$. This is the counting form of **Kelly’s Lemma**.

The formula turns a pile of overlapping partial views into a global count. If $k<n$, then $n-k>0$, so

$$
N_F(G)=\frac{1}{n-k}\sum_{v\in V}N_F(G-v).
$$

Thus the deck determines how many induced copies of every smaller fixed pattern occur in the original graph, provided the card isomorphisms allow those card-level counts to be compared. The proven identity itself is unconditional: it applies to every finite graph and every finite pattern.

This resembles inference from overlapping scans. A feature confined to $k$ locations is absent only when one of those locations is removed; all other deletions preserve it. Correcting for the fixed multiplicity $n-k$ recovers the original feature count.

## Recovering the number of edges

Take $F$ to be a single edge on two vertices. Then $N_F(G)$ is simply the number of edges, denoted $m(G)$. Every edge has two endpoints. It disappears from the two cards that delete those endpoints and survives in the other $n-2$ cards. Hence the Edge-Sum Identity states

$$
\sum_{v\in V}m(G-v)=(n-2)m(G).
$$

Suppose $G$ and $H$ have the same deck and $n\ge 3$. Corresponding cards are isomorphic, so they have equal edge counts. Their edge-count sums are therefore equal. Both original graphs have the same number $n$ of vertices because the deck correspondence pairs their vertex sets. Consequently,

$$
(n-2)m(G)=(n-2)m(H).
$$

Since $n-2>0$, cancellation yields the Edge Reconstruction Theorem:

$$
m(G)=m(H).
$$

The threshold $n\ge 3$ is not cosmetic. When $n=2$, the multiplier $n-2$ vanishes, so every edge is destroyed in every one-vertex card. The deck then cannot distinguish the two-vertex edge from two isolated vertices.

A numerical example makes the redundancy visible. Let $G$ have $6$ vertices and $8$ edges. Across its six cards, every edge survives $6-2=4$ times, so the sum of card edge counts must be

$$
4\cdot 8=32.
$$

The individual card counts may vary, but their sum cannot.

## Two graphs at opposite extremes

Once edge count is known, two classes become immediately reconstructible.

The **edgeless graph** on $n$ vertices has $0$ edges. If $G$ is edgeless, $H$ has the same deck, and $n\ge 3$, then edge reconstruction gives $m(H)=0$. A simple graph with no edges is edgeless, so $G$ and $H$ are isomorphic. This is the Edgeless Reconstruction Theorem.

At the opposite pole, the **complete graph** on $n$ vertices contains every possible edge and therefore has

$$
\binom n2
$$

edges. If $G$ is complete and $H$ has the same deck, then $H$ has the same order and the same number of edges. No simple graph on $n$ vertices can have more than $\binom n2$ edges, and reaching that bound means every pair is adjacent. Thus $H$ is complete and isomorphic to $G$. This is the Complete Reconstruction Theorem.

These conclusions are modest compared with the full conjecture, but they expose a general strategy: reconstruct a numerical invariant from the deck, then show that an extremal value of that invariant forces the entire graph.

## Turning every edge into a nonedge

The **complement** $G^c$ of a simple graph $G$ has the same vertices, with two distinct vertices adjacent in $G^c$ exactly when they are not adjacent in $G$. Empty becomes complete, complete becomes empty, sparse becomes dense.

Two structural facts make complementation especially useful. First, an isomorphism between $G$ and $H$ is automatically an isomorphism between $G^c$ and $H^c$, because preserving adjacency also preserves nonadjacency among distinct vertices. Second, deletion commutes with complementation:

$$
G^c-v=(G-v)^c.
$$

Indeed, both sides have the same surviving vertices, and each declares precisely the missing adjacencies of $G-v$ to be edges.

These observations prove the Complement-Deck Equivalence:

> Two simple graphs have the same vertex deck if and only if their complements have the same vertex deck.

One direction complements every card isomorphism. The reverse direction applies the same argument again, using $(G^c)^c=G$. This theorem is not restricted to finite graphs; it is a structural compatibility of deletion, isomorphism, and complementation.

The equivalence halves many paired questions. Any reconstruction theorem for a graph class can be transported to the complementary class. The edgeless and complete cases are the clearest example: they are mirror images under complementation.

## Where the frontier lies

The general Reconstruction Conjecture still asks for much more than edge count. Several concrete steps point forward.

One target is the **degree multiset**: the unordered list of the numbers of neighbors of all vertices. Another is a fully deck-based reconstruction theorem for counts of every smaller induced pattern. Such a result would elevate Kelly’s identity from an internal counting law to a comparison theorem between deck-equivalent graphs.

Regular graphs, whose vertices all have the same degree, are natural candidates because their degree data is rigid. Trees are another central target: they are connected graphs with no cycles and exactly $n-1$ edges. Complement compatibility adds a paired class—graphs whose complements are trees—and suggests a general transfer theorem for any property preserved under deck equivalence.

The deepest lesson is methodological. Each card is incomplete, and no single card remembers which vertex vanished. But incompleteness is repeated in a perfectly controlled way. A feature on $k$ vertices survives exactly $n-k$ deletions. That uniform redundancy turns a shuffled collection of losses into an exact global equation.

There is a useful philosophical reversal here. Missing data usually sounds like an obstacle, something to be repaired before analysis can begin. In a complete deck, however, the pattern of missingness is itself the measuring instrument. Every vertex is omitted once, every edge is omitted twice, and every $k$-vertex motif is omitted exactly $k$ times. The omissions are balanced. What one snapshot conceals, the ensemble reveals through symmetry.

This perspective reaches beyond graph theory: whenever local features have uniformly sized supports, systematically incomplete views can preserve exact totals. Reconstruction begins not by guessing the missing vertex, but by counting everything that did not go missing.