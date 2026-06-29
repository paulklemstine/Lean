# When Trees Meet Cliques: Cracking the Base of Erdős Problem 550

## A puzzle hidden in every crowd

Imagine you are organizing a conference. Every pair of attendees either already knows each other or does not. You would like a guarantee: *no matter how the acquaintances fall out*, you can always find a sizeable group who are mutual strangers, **or** a sizeable group who all know each other. This is the founding intuition of **Ramsey theory** — the mathematics of unavoidable order. Push any large enough system around however you like, and some pristine pattern will still survive.

The numbers that measure exactly *how large* a system must be before a pattern becomes unavoidable are called **Ramsey numbers**. They are notoriously hard to pin down. The legendary Paul Erdős liked to say that if aliens demanded the value of the Ramsey number for a clique of six versus a clique of six, humanity should marshal all its computers to find it — but if they demanded the clique of seven, we should simply attack the aliens, because we could never compute it in time.

This article is about one of Erdős's many pointed questions — **Problem 550** — and a clean, fully rigorous resolution of its foundational pieces. The story braids together two of combinatorics' most beloved objects: **trees**, the sparsest connected graphs, and **complete multipartite graphs**, dense graphs assembled from cliques-of-strangers. The punchline is a precise formula, proven with no hand-waving, that tells you exactly when a tree pattern becomes unavoidable in two-colored networks.

## The cast of characters

Let us meet the objects.

A **graph** is a collection of vertices (dots) with some pairs joined by edges (lines). The **complete graph** $K_n$ is the graph on $n$ vertices in which *every* pair is joined — the maximally social network where everyone knows everyone.

A **tree** is a connected graph with no cycles. If a graph is a tree on $n$ vertices, it has exactly $n-1$ edges; remove any one and it falls apart. Trees are the skeletons of connectivity: paths, stars, caterpillars, and branching hierarchies are all trees. The crucial fact we will lean on is humble but powerful: every finite tree with at least two vertices has a **leaf**, a vertex with exactly one neighbor. Peel leaves off one at a time and a tree dissolves gracefully.

A **complete multipartite graph** $K_{m_1, \ldots, m_k}$ is built from $k$ groups (called *parts*) of sizes $m_1, \ldots, m_k$. Two vertices are joined precisely when they lie in *different* parts. Inside a part: total strangers. Across parts: complete acquaintance. When every part has size one — that is, $m_1 = \cdots = m_k = 1$ — there is nothing to be a stranger to, and the graph collapses into the complete graph $K_k$. We write this identification as
$$K_{1,\ldots,1} \cong K_k.$$

Finally, the **Ramsey number** $R(G, H)$ is the smallest number $N$ such that every way of coloring the edges of $K_N$ with two colors — say **red** and **blue** — forces either a red copy of $G$ or a blue copy of $H$. There is no escape: paint the giant complete graph however you wish, and one of the two target patterns appears in its color.

## Erdős's conjecture

Erdős Problem 550 concerns the Ramsey number of a tree against a complete multipartite graph. Fix the number of parts $k \ge 2$ and the part sizes $1 \le m_1 \le \cdots \le m_k$. The conjecture asserts that for all sufficiently large $n$ and **every** tree $T$ on $n$ vertices,
$$R(T, K_{m_1, \ldots, m_k}) \le (k-1)\bigl(R(T, K_{m_1, m_2}) - 1\bigr) + m_1.$$

Read it slowly. It says the Ramsey number of a tree against a $k$-part graph is controlled by the Ramsey number against the simplest **two-part** graph $K_{m_1, m_2}$ — multiplied out across the $k-1$ "extra" parts, with a small additive correction $m_1$. It is a *recursion in disguise*: the hard, many-part quantity is bounded by the easy, two-part quantity. If true, it tames a whole hierarchy of Ramsey numbers in one stroke.

The conjecture has a beautiful skeleton. Two questions immediately present themselves:

1. **What is the base term** $R(T, K_{m_1, m_2})$ in the cleanest case?
2. **Is the bound tight** — can equality actually happen?

This work answers both, exactly and unconditionally, in the most luminous special case: the **all-ones case**, where every $m_i = 1$.

## The all-ones case is Chvátal's theorem

Set $m_1 = \cdots = m_k = 1$. Then $K_{m_1,\ldots,m_k} = K_{1,\ldots,1} = K_k$, and the two-part base graph becomes $K_{1,1} = K_2$ — a single edge. The conjectured bound reads
$$R(T, K_k) \le (k-1)\bigl(R(T, K_2) - 1\bigr) + 1.$$

We will see in a moment that $R(T, K_2) = n$ exactly. Substituting, the bound becomes
$$R(T, K_k) \le (k-1)(n-1) + 1.$$

This is precisely a celebrated 1977 result of **Vašek Chvátal**: for any tree $T$ on $n$ vertices and any complete graph $K_k$,
$$R(T, K_k) = (k-1)(n-1) + 1.$$

So the all-ones case of Erdős 550 *is* Chvátal's theorem. Proving the bound is tight in this case means proving the matching **lower bound** $R(T, K_k) > (k-1)(n-1)$ — and that is one of the two centerpieces here.

## Centerpiece one: the exact base case

First, the foundation. What is $R(T, K_2)$, the Ramsey number of an $n$-vertex tree against a single edge?

**Theorem (exact base case).** *For every tree $T$ on $n$ vertices,*
$$R(T, K_{1,1}) = R(T, K_2) = n.$$

The proof is a gem of economy. Consider any two-coloring of the complete graph $K_n$. There are only two possibilities:

- **Every edge is red.** Then the red graph is the entire complete graph $K_n$. Since $T$ is a graph on $n$ vertices, and *every* $n$-vertex graph sits inside the complete graph on $n$ vertices, we find a red copy of $T$.
- **Some edge is blue.** A single blue edge *is* a blue copy of $K_2$.

Either way, we win. So $K_n$ "arrows" to $(T, K_2)$: the upper bound $R(T, K_2) \le n$ holds. Remarkably, this upper half needs nothing about $T$ being a tree — only that $T$ lives on $n$ vertices and therefore embeds in $K_n$.

The matching lower bound — that $K_{n-1}$ does **not** arrow to $(T, K_2)$ — is where being a tree matters. Color all of $K_{n-1}$ red. There is no blue edge at all, so certainly no blue $K_2$. And a red copy of $T$ is impossible: $T$ is *connected* on $n$ vertices, but the red graph lives on only $n-1$ vertices, too few to host it. Hence $R(T, K_2) > n - 1$, and combined with the upper bound, $R(T, K_2) = n$ exactly.

This pins down the base term of the Erdős recursion. In the language of the formalization, the colored complete graph on $n$ vertices satisfies the "arrowing" relation `RamseyArrows n T K₂`, while the one on $n-1$ vertices does not.

## Centerpiece two: tightness via disjoint cliques

Now the deeper half — the lower bound that certifies the all-ones Erdős bound is *tight*:

**Theorem (Chvátal lower bound).** *For every tree $T$ on $n$ vertices and every $k \ge 1$,*
$$R(T, K_k) > (k-1)(n-1).$$

Equivalently: there exists a red/blue coloring of the complete graph on $(k-1)(n-1)$ vertices with **no red copy of $T$ and no blue copy of $K_k$**. We must *build* such a coloring — a witness to the impossibility of a pattern.

The construction is elegant and visual. Take $(k-1)(n-1)$ vertices and split them into $k-1$ **blocks**, each of size $n-1$. Color an edge **red** if its two endpoints lie in the *same* block, and **blue** if they lie in *different* blocks. The red graph is therefore a disjoint union of $k-1$ cliques, each on $n-1$ vertices. (In the formalization this is the `blockGraph (k-1) (n-1)`, with two vertices adjacent in red exactly when their block indices agree.)

Why does this defeat both patterns?

**No red tree.** Each red connected component is a single block of size $n-1$. But $T$ is connected with $n$ vertices. A connected graph on $n$ vertices cannot squeeze into a component of only $n-1$ vertices — there simply isn't room. So no block hosts a red $T$, and since blocks don't talk to each other in red, no red copy of $T$ exists anywhere. This is the substantive direction: it is exactly where connectivity of the tree does the work.

**No blue clique $K_k$.** The blue graph is the complete $(k-1)$-partite graph whose parts are the $k-1$ blocks. A clique in a complete multipartite graph can use at most one vertex from each part — a clique is a *transversal*. With only $k-1$ parts, the largest blue clique has $k-1$ vertices. A blue $K_k$ would need $k$ mutually adjacent vertices, hence $k$ distinct parts — one more than exists. Impossible.

So this single coloring avoids both targets on $(k-1)(n-1)$ vertices, proving $R(T, K_k) > (k-1)(n-1)$. Paired with Chvátal's upper bound, the value is sharp.

## The bridge: $K_{1,\ldots,1} \cong K_k$, made honest

A subtle but vital piece glues the multipartite framing to the complete-graph framing. It would be tempting to *declare* that the all-ones multipartite graph "is" the complete graph by fiat. But mathematics demands an honest identification, not a rename. So the work proves containment in **both** directions:

- The complete graph $K_k$ embeds into the multipartite graph with $k$ singleton parts (every two singleton parts are different, hence joined).
- The all-singletons multipartite graph embeds back into $K_k$ (collapsing each singleton part to its index).

Two mutual embeddings establish a genuine isomorphism $K_{1,\ldots,1} \cong K_k$. This is the hinge on which the all-ones case of Erdős 550 turns into Chvátal's theorem — and it is proven, not assumed.

There is a companion structural fact in the same spirit: **any** complete multipartite graph $K_{m_1,\ldots,m_k}$ embeds into the complete graph on its full vertex set. Blue cliques, in other words, always live inside blue complete graphs — a containment that will anchor the inductive attack on the *full* multipartite conjecture in future work.

## Why this is satisfying

What makes this resolution beautiful is the contrast between the two halves. The **upper bound** for the base case is almost a tautology — a two-case split with no cleverness required. The **lower bounds** are constructive: you must *exhibit* a coloring that thwarts both patterns, and verify that connectivity and the pigeonhole structure of multipartite cliques conspire to make it work. The all-ones case lands exactly on Chvátal's classical theorem, confirming that Erdős's recursive bound is not merely an inequality but, at its base, *tight*.

The numbers come out clean. For a path on $5$ vertices versus the triangle $K_3$, the formula gives $R = 2 \cdot 4 + 1 = 9$: any two-coloring of $K_9$ forces a red $5$-vertex path or a blue triangle, and the disjoint-clique coloring on $8$ vertices shows $8$ is not enough. For a star on $n$ vertices versus $K_k$, the same $(k-1)(n-1)+1$ formula applies. The recursion compresses an entire family of hard questions into one transparent rule.

## The road ahead

This cycle nailed down the **lower-bound / tightness** half and the **exact base case** of Erdős 550 in its all-ones specialization. The natural frontier is the matching **upper bound** for general complete graphs — the greedy "embed the tree one leaf at a time" argument, which uses the existence of leaves to grow a red tree inside any sufficiently red-dense coloring. Beyond that lies the **full multipartite conjecture**, where blue copies of $K_{m_1,\ldots,m_k}$ are assembled part by part, peeling off dense blocks of size $R(T, K_{m_1,m_2}) - 1$, with the additive $m_1$ absorbing the final part. The base case and the multipartite-containment lemma proven here are exactly the two endpoints of that induction; only the peeling step remains.

Ramsey theory promises that order is unavoidable. Erdős Problem 550 asks *how soon*. For trees against cliques, we now know the answer — sharply, at its foundation, and beyond doubt.
