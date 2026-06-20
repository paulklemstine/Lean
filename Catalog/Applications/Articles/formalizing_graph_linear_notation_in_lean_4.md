# The Largest Name a Graph Can Have

## A fingerprint for networks

Imagine you are handed two tangled diagrams of dots and lines — two *graphs*. One was drawn by a chemist describing a molecule; the other by a sociologist mapping a friendship circle. They look nothing alike on the page. Yet a nagging question remains: are they secretly *the same* network, just drawn with the dots in a different order?

This is the **graph isomorphism problem**, one of the most famous and stubborn questions in all of computer science. Two graphs are *isomorphic* if you can rename the dots of one to turn it into the other — same connections, different labels. Telling whether two drawings are the same graph in disguise is easy for tiny examples and maddening for large ones. The trouble is that a graph on $n$ dots can be drawn in $n!$ different orderings, and $n!$ grows astronomically: a mere $15$ dots already admit more than a *trillion* orderings.

What if every graph had a single, canonical *name* — a number so carefully chosen that two graphs share the name **if and only if** they are the same network in disguise? Then comparing two graphs would reduce to comparing two numbers. That is exactly the object we build and rigorously establish here. We call it **graph linear notation**, written $\mathrm{gln}$.

## From a picture to a number

The first step is to turn a graph into a number at all. Every graph on the vertex set $\{0, 1, \dots, n-1\}$ has an **adjacency matrix**: an $n \times n$ grid of $0$s and $1$s, where the entry in row $i$, column $j$ is $1$ when dots $i$ and $j$ are connected, and $0$ otherwise.

A grid of bits is just a long binary number waiting to be read. We read the grid row by row and assign each cell its own power of two. The cell in row $i$, column $j$ gets the weight $2^{\,i \cdot n + j}$. Summing the weights of all the *filled* cells produces a single natural number we call the **adjacency code**:

$$\mathrm{adjCode}(G) \;=\; \sum_{i=0}^{n-1}\sum_{j=0}^{n-1} a_{ij}\,\cdot\, 2^{\,i \cdot n + j},$$

where $a_{ij} = 1$ if dots $i$ and $j$ are adjacent and $a_{ij} = 0$ otherwise.

This is nothing more than reading the adjacency matrix as one big binary integer. And here is the first guarantee, which we prove with full rigor:

> **The code never lies.** Two graphs with the same adjacency code are literally the same graph (on the same labeled vertices). In symbols, $\mathrm{adjCode}$ is *injective*.

The reason is the most elementary fact about binary numbers: every natural number has *exactly one* binary expansion. Since we placed every matrix cell at its own distinct power of two — the map $(i,j) \mapsto i\cdot n + j$ sends different cells to different exponents — recovering the matrix from the number is just reading off its bits. No two different $0/1$ patterns can ever collide.

## The catch: the same graph, many codes

So far we have a perfect fingerprint for *labeled* graphs — graphs where the dots come with fixed names. But that is not quite what we want. The chemist and the sociologist labeled their dots arbitrarily. Relabel the dots, and the adjacency matrix gets its rows and columns shuffled, which usually changes the code entirely.

Concretely, if $\sigma$ is a permutation — a relabeling — of the vertices, we can form a relabeled graph in which dots $i$ and $j$ are joined exactly when $\sigma(i)$ and $\sigma(j)$ were joined in the original. Each of the $n!$ relabelings generally yields a *different* code. A single underlying network therefore wears up to $n!$ numeric disguises. A fingerprint that changes when you rename the dots is no fingerprint at all.

## The trick: choose the loudest name

The resolution is beautifully simple. If one graph has many possible codes — one for each way of ordering its vertices — then **pick the biggest one**.

$$\mathrm{gln}(G) \;=\; \max_{\sigma}\; \mathrm{adjCode}\big(\text{relabel } G \text{ by } \sigma\big).$$

This is the graph linear notation. Among all $n!$ numeric disguises a graph can wear, $\mathrm{gln}$ singles out the maximum. Think of it as letting the graph shout all of its possible names at once and keeping only the loudest.

Because we are choosing the maximum over a *finite* collection of numbers (there are finitely many relabelings), this maximum genuinely exists and is *achieved* by at least one specific ordering. We establish this as a theorem in its own right:

> **The maximum is attained.** There is an actual relabeling $\sigma$ that realizes the value $\mathrm{gln}(G)$. The optimal ordering is not a wishful abstraction; it is a concrete arrangement of the dots.

The ordering that achieves the maximum is, in effect, the *canonical drawing* of the graph — the one preferred arrangement out of all the messy possibilities.

## Why the loudest name is the perfect name

Maximizing over relabelings does something almost magical: it makes the resulting number *blind to labels* while still seeing *everything else*. This is the heart of the construction, and it splits into two halves.

**Half one: isomorphic graphs get the same notation.** Suppose two graphs are really the same network drawn differently. Then their pools of possible codes — the codes you get by trying every relabeling — are *identical* pools, just reached through different starting points. Two identical pools have the same maximum. So:

> **Isomorphism invariance.** If $G$ and $H$ are isomorphic, then $\mathrm{gln}(G) = \mathrm{gln}(H)$.

This is the "no false negatives" half: the same graph can never accidentally receive two different notations.

**Half two: graphs with the same notation must be isomorphic.** This is the deeper and more valuable direction — the "no false positives" guarantee. Suppose $\mathrm{gln}(G) = \mathrm{gln}(H)$. Each side achieves its maximum at some specific ordering, producing relabeled graphs $G'$ and $H'$ with $\mathrm{adjCode}(G') = \mathrm{adjCode}(H')$. But we already proved the code never lies: equal codes force $G' = H'$ as labeled graphs. Since $G'$ and $H'$ are merely relabelings of $G$ and $H$, the chain of relabelings stitches $G$ and $H$ together into an honest isomorphism. So:

> **Completeness.** If $\mathrm{gln}(G) = \mathrm{gln}(H)$, then $G$ and $H$ are isomorphic.

Put the two halves together and you get the headline result, an exact equivalence:

$$\boxed{\;\mathrm{gln}(G) = \mathrm{gln}(H) \quad\Longleftrightarrow\quad G \text{ and } H \text{ are isomorphic.}\;}$$

A single natural number — the loudest binary name a graph can shout — is a **complete invariant**. Two graphs are the same network if and only if they carry the same notation. The tangled question of whether two drawings hide the same structure collapses into the trivial question of whether two integers are equal.

## A tiny worked example

Take the smallest interesting case: graphs on two vertices, $\{0, 1\}$. There are only two simple graphs: the *empty* graph with no edge, and the *single-edge* graph joining $0$ and $1$.

For the empty graph every cell is $0$, so every relabeling gives code $0$, and $\mathrm{gln} = 0$.

For the single-edge graph, the symmetric adjacency matrix has $1$s in the off-diagonal cells $(0,1)$ and $(1,0)$, contributing $2^{0\cdot 2 + 1} + 2^{1\cdot 2 + 0} = 2^{1} + 2^{2} = 2 + 4 = 6$. Swapping the two labels maps these cells to each other, leaving the code unchanged at $6$. So $\mathrm{gln} = 6$.

Two graphs, two distinct notations — $0$ and $6$ — exactly mirroring the fact that there are precisely two graphs on two vertices up to isomorphism. The notation has counted them for us.

This is no accident. Because equal notation means isomorphism and isomorphism means equal notation, the *number of distinct values* the notation can take on $n$ vertices is precisely the number of genuinely different graphs on $n$ vertices. For $n = 0, 1, 2, 3, 4, 5, \dots$ that sequence is $1, 1, 2, 4, 11, 34, \dots$ — a famous integer sequence cataloguing the graphs of each size. Counting notations *is* counting graphs.

## Why this matters

It is worth being honest about what is, and is not, being claimed. Graph linear notation does **not** make graph isomorphism *fast*: computing $\mathrm{gln}$ by brute force still walks through all $n!$ orderings, so for large graphs it is hopelessly slow. What it gives instead is something different and durable — a *mathematically airtight definition* of a canonical name, with a proof that the definition does exactly what a canonical name should do.

That guarantee is the bedrock on which practical tools are built. Real-world *graph canonization* engines — the software that lets chemists deduplicate enormous molecule databases, that lets program analyzers recognize when two pieces of code have the same call structure, that lets network scientists match patterns across social graphs — all rest on the same conceptual promise: *produce one representative per isomorphism class, and never confuse two distinct classes.* Graph linear notation is that promise distilled to its mathematical essence and verified down to the last bit.

The same idea echoes far beyond graphs. Whenever we want to compare objects that come in many equivalent disguises — chemical structures up to atom renumbering, data records up to reordering, geometric shapes up to rotation — the winning strategy is the one on display here: define a numeric score, optimize it over all the disguises, and prove that the optimum sees through the disguise without seeing the disguise itself. Canonicalization by maximization is a pattern that quietly powers a great deal of modern computation.

## The shape of an idea

Strip away the machinery and a single elegant motif remains. A graph is a structure that can be *named* in many ways, none of them privileged. To find the one true name, we do not appeal to convention or arbitrary choice. We let the structure speak in every voice it has and we listen for the loudest. That loudest voice — the maximum binary code over all relabelings — turns out to be a perfect echo of the structure itself: silent to how the dots were labeled, eloquent about how they are connected.

It is a small miracle of mathematics that such a brute, almost crude recipe — "try everything and keep the biggest" — yields an object of pristine precision: a complete invariant, exact in both directions, for the elusive notion of when two networks are truly the same.
