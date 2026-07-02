# The Shape That Refuses to Fit: Why the Petersen Graph Cannot Live on a Tropical Lattice

## A ten-pointed puzzle

Some mathematical objects are famous not for what they do but for what they *refuse* to do. The **Petersen graph** is one of them. Draw a pentagon, draw a five-pointed star inside it, and connect each pentagon corner to the matching star point. You now have ten dots and fifteen lines — a picture so symmetric it looks almost inevitable, and yet so stubborn that it serves as the standard counterexample to conjecture after conjecture in graph theory. Whenever someone guesses that "every graph with property X also has property Y," a wise colleague first checks the Petersen graph. More often than not, it is the spoiler.

This article is about one particular thing the Petersen graph refuses to do: it cannot be laid down, *without distorting a single distance*, inside a large and natural family of grid-like networks that arise from **tropical geometry**. That refusal turns out not to be an accident of one clever drawing. It is forced by two independent principles that fit together like a lock and key — one about *coloring*, one about *parity* — and the second principle is where the tropical world quietly enters.

## What "fitting without distortion" means

Imagine you have a small map — the Petersen graph — and a big city grid, and you want to place the map on the grid so that the walking distance between any two of your ten landmarks is *exactly* what the map says it should be. Not approximately. Exactly. In mathematics this is called an **isometric embedding**: a placement $f$ of the small graph's vertices into the big graph such that for every pair of vertices $u$ and $v$,
$$\operatorname{dist}_H\bigl(f(u),\,f(v)\bigr) = \operatorname{dist}_G(u,v),$$
where $\operatorname{dist}_G$ is shortest-path distance in the small graph $G$ and $\operatorname{dist}_H$ is shortest-path distance in the big host graph $H$.

Isometric embeddings are demanding. It is easy to place points so that *some* distances come out right; it is hard to get *all* of them right at once. Graphs that embed isometrically into grids (more precisely, into products of paths, the so-called hypercubes) are called **partial cubes**, and they have a beautifully clean theory. The Petersen graph is the classic example of a graph that is *not* a partial cube. Our story generalizes that fact dramatically: the Petersen graph fails to embed isometrically not just into cubes, but into an entire tropical family of hosts, all at once.

## The first key: distances protect colors

The first principle is elementary but powerful, and it has nothing to do with tropical anything. It says that isometric maps cannot hide the difficulty of coloring a graph.

Recall that a graph is **$n$-colorable** if we can paint its vertices with $n$ colors so that no edge joins two vertices of the same color. The smallest workable $n$ is the graph's chromatic number, a measure of how tangled its adjacencies are.

**Metric obstruction (any number of colors).** *Suppose $f$ places graph $G$ isometrically inside graph $H$. If $H$ can be properly colored with $n$ colors, then so can $G$.*

The proof is a single clean observation. Take a proper $n$-coloring $c$ of the host $H$. Define a coloring of $G$ by painting each vertex $v$ with the color $c(f(v))$ — just read off the color of its image. Why is this proper? If $u$ and $v$ are adjacent in $G$, their distance is exactly $1$. Because $f$ preserves distances perfectly, the distance between $f(u)$ and $f(v)$ is also exactly $1$, which means $f(u)$ and $f(v)$ are adjacent in $H$. Since $c$ was a proper coloring of $H$, adjacent images get different colors, so $u$ and $v$ get different colors too. Done.

Notice where the isometry is used: **exactly once**, to turn an edge of $G$ into an edge of $H$. This economy matters. If we only asked $f$ to be *some* map, a triangle could collapse onto a single edge and the argument would break. It is the rigidity of distance preservation — no crushing allowed — that carries a proper coloring safely backward across the map.

Turning this around gives the tool we need:

**Contrapositive.** *If $G$ cannot be $n$-colored but $H$ can, then $G$ has no isometric embedding into $H$.*

So to prove the Petersen graph does not fit somewhere, we need two facts: the Petersen graph is *hard* to color in some specific sense, and the host is *easy* to color in the same sense. The magic number here is $n = 2$.

## The Petersen graph is not two-colorable

A graph is $2$-colorable precisely when it is **bipartite** — its vertices split into two teams with every edge crossing between teams. There is a classical litmus test: *a graph is bipartite if and only if every closed walk has even length.* Equivalently, a graph fails to be bipartite exactly when it contains a closed walk of odd length.

To pin down the Petersen graph concretely, we use its elegant combinatorial description as the **Kneser graph $K(5,2)$**. Its ten vertices are the ten two-element subsets of $\{0,1,2,3,4\}$, and two vertices are joined by an edge precisely when the corresponding subsets are **disjoint**. For example $\{0,1\}$ and $\{2,3\}$ are adjacent (they share nothing), while $\{0,1\}$ and $\{1,2\}$ are not (they share the element $1$).

Inside this model we can point to an explicit odd cycle of length five:
$$\{0,1\} \to \{2,3\} \to \{4,0\} \to \{1,2\} \to \{3,4\} \to \{0,1\}.$$
Check each step: consecutive pairs really are disjoint, and after five hops we return to the start. Five is odd. So the Petersen graph contains an odd closed walk, and therefore:

**The Petersen graph is not two-colorable.**

This is the "hard" half of our lock: the source refuses to be split into two teams.

## The second key: tropical valuations and the parity certificate

Now we build the hosts, and here is where the tropical world arrives.

Start with an **abelian group** $A$ — think of it as a set of "moves" you can add together and undo, like the integer vectors $\mathbb{Z}^k$ describing steps on a lattice. From a symmetric set $S$ of nonzero moves (symmetric meaning that whenever $s$ is allowed, so is its reverse $-s$), we build the **Cayley graph** of $A$: its vertices are the group elements, and two elements $g$ and $h$ are joined by an edge exactly when their difference $h - g$ is one of the permitted moves in $S$. Cayley graphs are the archetype of homogeneous, grid-like networks; every vertex sees the same local picture.

The tropical ingredient is how we *choose* the move set $S$. A **tropical valuation** is a homomorphism
$$v : A \to \mathbb{Z}$$
that respects addition: $v(a+b) = v(a) + v(b)$. The name comes from tropical (min-plus) algebra, where the value group $\mathbb{Z}$ is the natural home of "sizes" or "orders of magnitude," and shortest-path distance is itself a min-plus computation — addition along a path becomes ordinary summation, and choosing the best path becomes taking a minimum. A valuation assigns each group element an integer size, compatibly with the group law.

We then define the connection set to be the **odd part of the valuation**:
$$S = \{\, a \in A \;:\; v(a) \text{ is odd} \,\}.$$
This is a legitimate connection set for a Cayley graph. It is symmetric because $v(-a) = -v(a)$, and negating an integer never changes whether it is odd. And it excludes the identity because $v(0) = 0$ is even, so there are no self-loops. We call the resulting graph the **odd-valuation Cayley graph**.

Here is the punchline that makes these hosts *easy* to color:

**The odd-valuation Cayley graph is bipartite.** *Color each vertex $g$ by the parity of $v(g)$ — one color if $v(g)$ is even, the other if odd.* Consider any edge, joining $g$ to $h$. By definition of the connection set, the move $h - g$ has odd valuation, so
$$v(h) - v(g) = v(h - g) \text{ is odd},$$
which means $v(h)$ and $v(g)$ have *opposite* parities and therefore receive *different* colors. Every edge is properly colored, so the graph is two-colorable.

The parity of the valuation is doing double duty. It *defines* the edges (a move is allowed exactly when its size is odd), and simultaneously it *certifies* the two-coloring (its parity assigns the teams). This is the tropical valuation's fingerprint on the whole construction: a single integer-valued homomorphism, read modulo two, is both the architect of the graph and the proof that it is bipartite.

## Snapping the lock shut

Assemble the three facts:

1. The Petersen graph is **not** two-colorable.
2. Every odd-valuation tropical Cayley graph **is** two-colorable.
3. Isometric embeddings preserve colorability.

If the Petersen graph embedded isometrically into such a host, principle (3) would force the Petersen graph to inherit the host's two-colorability — contradicting (1). Therefore:

**Main theorem.** *The Petersen graph does not embed isometrically into any Cayley graph of an abelian group whose connection set is the odd part of an integer-valued tropical valuation.*

This is not a statement about one host. It rules out an *entire infinite family* of hosts in a single stroke, indexed by every abelian group and every valuation on it.

## A concrete picture: the integer lattice

To make it tangible, take $A = \mathbb{Z}^k$, the lattice of integer vectors, with the **coordinate-sum valuation**
$$v(x_1, \ldots, x_k) = x_1 + x_2 + \cdots + x_k.$$
A move has odd valuation exactly when the sum of its coordinates is odd. The resulting odd-valuation Cayley graph is precisely the familiar **bipartite integer lattice**, two-colored like an infinite checkerboard by the parity of the coordinate sum. Our theorem specializes to say: the Petersen graph cannot be drawn on any such checkerboard lattice, in any number of dimensions, without stretching or squashing some distance. The ten-pointed star simply has no faithful home there.

## Why this is more than a curiosity

The pleasing part of this result is how cleanly it *separates* into two layers. There is a **metric core** — distances protect colors — that knows nothing about groups, valuations, or the tropics; it works for any number of colors and any pair of graphs. And there is a **one-parameter certificate** — the parity of the valuation — that supplies the bipartiteness of the hosts. The tropical content is confined entirely to that certificate. Change the algebra generating your distances all you like; as long as the host's edges are the odd part of a valuation, the Petersen graph stays locked out.

This modularity is exactly what makes the boundary of the theorem so interesting. The parity certificate is the *only* place the oddness of the valuation is used. What if every generator had *even* valuation instead? Then the parity coloring collapses — every vertex gets the same color — and the host is free to contain odd cycles of its own. The coloring obstruction vanishes, and there may be room for a genuine isometric copy of the Petersen graph after all. Whether such an even-valuation host actually accommodates it is a sharp and, at present, open question. So too is whether the *rank* of the valuation — roughly, how many independent "sizes" it can measure — governs a threshold between rigidity and flexibility, and whether the true obstruction is not merely bipartiteness but the entire tropical *spectrum* of distances the Petersen metric demands.

What began as a stubborn ten-vertex diagram thus opens onto a landscape of graded, valued geometries, each asking the same question in a new dialect: which shapes can live faithfully here, and which, like the Petersen graph, will always refuse to fit?
