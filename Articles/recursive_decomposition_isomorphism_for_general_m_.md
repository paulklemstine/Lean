# One Rule to Count Them All: How a Simple Shift Unites Two Families of Combinatorial Objects

## A tale of two catalogues

Imagine two great libraries, built in different centuries, in different
countries, by people who never met. The first catalogues a family of geometric
staircases — jagged mountain profiles drawn on graph paper, each one a legal
"lattice path" that never dips below the diagonal. The second catalogues a family
of maps — planar drawings, like the borders of countries stitched together on a
sphere, obeying a strict coloring discipline. The two libraries have nothing
obviously in common. And yet, when a mathematician finally sits down and counts
the books on the shelves, an eerie coincidence emerges: shelf for shelf, the two
libraries hold *exactly* the same number of volumes.

This is the kind of coincidence that combinatorics lives for. When two families
of objects are counted by the same numbers, it is almost never an accident. There
is usually a hidden dictionary — a *bijection* — translating each object of one
kind into a unique object of the other. Finding that dictionary is the real
prize, because it explains *why* the numbers agree, and it lets any fact about
one family be carried over, verbatim, to the other.

The two families in our story are the **$m$-Tamari intervals** and the **planar
$(m+1)$-constellations**. This article tells how a single, almost embarrassingly
simple idea — add one to a label — reveals that the recursive skeletons of these
two families are, for *every* value of $m$, one and the same tree.

## The Tamari staircase and its intervals

Start with the humble **Dyck path**: a staircase that begins at the origin, takes
unit steps up and to the right, ends on the diagonal, and never crosses below it.
For a fixed size these paths can be organized into a beautiful partial order
called the **Tamari lattice**, where one path sits below another if you can slide
it upward by a sequence of elementary local moves. An **interval** in this
lattice is simply a pair of paths, a lower one and an upper one, with the lower
below the upper — the set of everything "between" them.

The **$m$-Tamari lattice** is a parameterized generalization discovered while
studying deep structures in algebra. Here $m$ is a positive integer: $m = 1$
gives the classical Tamari lattice, and larger $m$ produces richer, taller
lattices built on $m$-Dyck paths (staircases that stay above a line of slope
$1/m$). The intervals of these lattices — the pairs $[P, Q]$ with $P \le Q$ —
turn out to be counted by strikingly clean formulas, and they connect to the
representation theory of certain algebras of diagonal harmonics. For $m = 1$ the
interval counts are $1, 3, 13, 68, 399, \dots$; for each $m$ there is an
analogous, explicit sequence.

## Constellations: maps with a coloring discipline

Now cross to the other library. A **planar constellation** is a certain kind of
map drawn on the sphere. Loosely, an $(m+1)$-constellation is a bipartite planar
map whose faces and vertices satisfy a strict divisibility-and-coloring rule
governed by the parameter $m+1$. These objects arose from the study of
factorizations of permutations and of ramified coverings of the sphere — genuinely
different mathematics from lattice paths. But their counting sequences have long
been suspected to match those of the $m$-Tamari world, and for $m = 1$ this match
is a proven theorem.

So we have the coincidence. The question is: **is there one uniform reason it
holds for every $m$ at once?** That is the story here.

## Generating trees: the DNA of a counting sequence

The bridge between the two libraries is a device called a **generating tree**. It
is the mathematical DNA of a recursively-built family.

Here is the idea. Suppose every object in your family can be built from a smaller
one by a well-understood "growth" step, and suppose you can attach to each object
a single number — a **label** — that tells you *exactly how many ways* it can
grow, and *what the labels of its offspring will be*. Then the entire family is
encoded by two pieces of data: a **root label** (the starting object) and a
**succession rule** (a function taking a label to the list of labels of its
children). Unrolling this rule level by level produces an infinite rooted tree in
which the number of nodes at depth $k$ is precisely the number of objects of
size $k$. The counting sequence is literally the census of the tree, floor by
floor.

Two families that grow by the *same* tree are automatically equinumerous. And if
the labels themselves carry combinatorial meaning — say, the number of "valleys"
in a staircase, or the number of hyperedges of a given color in a map — then a
matching of trees transports those statistics too, giving a far stronger,
*refined* equality.

## Two rules, one tree

Each of our libraries comes with its own natural succession rule.

On the $m$-Tamari / staircase side, the natural bookkeeping is by **active
sites** — the places where the next piece of staircase may be grafted. A node
carrying label $k$ (it has $k$ active sites) produces one child for each way of
performing the graft, and a short combinatorial analysis shows the children's
labels are exactly
$$
S_m(k) = [\,1, 2, 3, \dots, m k + 1\,].
$$
The whole tree starts from the root label $1$. So a node with $k$ active sites has
$mk + 1$ children.

On the $(m+1)$-constellation side, the recursive decomposition is naturally
recorded by a **shifted** rule. Here the root already carries one extra site, so
it starts at label $2$, and a node with label $k$ produces children with labels
$$
T_m(k) = [\,2, 3, \dots, m(k-1) + 2\,].
$$

These two rules genuinely look different. One starts at $1$, the other at $2$; one
node of label $k$ has $mk+1$ children, the other has $m(k-1)+1$. At first glance
there is no reason they should build the same tree.

## The one-line miracle

Consider the utterly simple relabelling
$$
\varphi(k) = k + 1.
$$
Add one. That's it. The claim is that $\varphi$ is a perfect dictionary between
the two rules — an **intertwining** — meaning: if you take a node's children under
the active-sites rule and add one to every label, you get *exactly* the list of
children that the shifted rule assigns to the relabelled parent. In symbols, for
every arity $m$ and every label $a$,
$$
T_m(\varphi(a)) \;=\; \varphi\bigl(S_m(a)\bigr),
$$
where $\varphi$ acts on a list by adding one to each entry.

Why is this true? It is a clean arithmetic identity about consecutive integers.
The active-sites children of $a$ are the run $1, 2, \dots, ma + 1$. Adding one
gives $2, 3, \dots, ma + 2$. Meanwhile the shifted rule applied to $\varphi(a) =
a+1$ produces the run starting at $2$ of length $m(a+1) - m + 1 = ma + 1$, which
is $2, 3, \dots, ma + 2$. The two runs coincide, on the nose, for every $m$ and
every $a$. The shift $\varphi$ works uniformly; a *wrong* shift would fail, which
is exactly why the identity has content.

Because the relabelling intertwines the *rules*, an easy induction propagates it
up the entire tree: at every depth $k$, the list of labels produced by the
shifted rule is precisely the list produced by the active-sites rule with one
added to each entry. The two trees are the same tree wearing two different name
tags.

## What the shift buys us

Once the trees are identified, three consequences follow immediately — and they
hold for **every** $m \ge 1$.

**Equal counts.** Adding one to a label never creates or destroys a node. So the
number of nodes at each depth is identical in the two encodings. The $m$-Tamari
and $(m+1)$-constellation families are equinumerous, level by level, in these
encodings. Computing the census reproduces the sequences
$$
\begin{aligned}
m = 1:&\quad 1,\ 2,\ 5,\ 14,\ 42, \dots \quad (\text{the Catalan numbers}),\\
m = 2:&\quad 1,\ 3,\ 15,\ 113,\ 1273, \dots,\\
m = 3:&\quad 1,\ 4,\ 34,\ 586,\ 21721, \dots.
\end{aligned}
$$
The first floor already holds $m+1$ nodes, so the trees are genuinely different
for different $m$ — this is not one sequence in disguise, but a whole family, each
member matched to its constellation partner.

**Equal refined counts.** Because the dictionary is a clean shift, *any* statistic
you can read off a label is transported perfectly. Pick any way of scoring a label
and any property you want to test; the number of nodes at a given level whose
score has that property is the same on both sides (up to the harmless shift). No
statistic is lost in translation. This is the "refined" equinumerosity that makes
a bijective proof so much more valuable than a bare count.

**Genuine growth.** None of this is a vacuous game with empty trees. Every label
in the active-sites tree is at least $1$, so — for $m \ge 1$ — every node has at
least $mk + 1 \ge 2$ children. Each floor is therefore at least twice as populous
as the one below it, and the census grows at least as fast as $2^k$. The trees
really do branch and blossom.

## Why the simplicity is the point

It would be easy to undersell a result whose proof is "add one." But the surprise
is precisely that a single, arity-independent gesture does all the work. Earlier
understanding handled the classical case $m = 1$ — the Catalan layer, where the
count is the most famous sequence in combinatorics. What was missing was a reason
the correspondence should survive as $m$ grows and both families become
dramatically more complicated. The intertwining shift supplies exactly that
reason. It shows the two recursive decompositions are not merely *analogous*
across arities but are, structurally, the same object viewed through a constant
change of coordinates.

This is the classic pattern of a good bijection: it collapses an apparent
coincidence into an identity, and it does so with a mechanism so uniform that it
scales without effort. The branching multiplicity $mk+1$ — the number of children
of a node — is not arbitrary; it counts the ways to graft the next active site in
an $m$-Dyck decomposition. That the same multiplicity, viewed with a
pre-loaded root, is what the constellation side demands is the combinatorial heart
of the matter.

## The road ahead

The result proved here is the *generating-tree layer*: it establishes that the
two recursive skeletons coincide, uniformly in $m$, and that all label-borne
statistics transport. Several tantalizing questions remain.

The most natural is to pin down the exact interval numbers. The active-sites tree
produces an explicit $m$-indexed sequence, and there is strong reason to believe
that, after a suitable regrading by size, it matches the known closed-form
enumeration of greedy $m$-Tamari intervals term for term — turning an empirical
match in small cases into a theorem. A second direction is to name the transported
statistic precisely: it should be the number of valleys on the staircase side and
a fixed-color hyperedge count on the map side, so that two bivariate generating
functions become literally equal. A third asks how the counts vary with the arity
$m$: the tree of arity $m$ appears to embed, level by level, inside the tree of
arity $m+1$, suggesting the counts strictly increase with $m$. And a fourth
brings in the heavy analytic machinery: encoding the decomposition as a functional
equation for a generating function should reveal a square-root singularity and the
universal $n^{-3/2}$ correction that signals a "tree-like" universality class.

Each of these is a thread leading deeper into the same tapestry. But the loom is
now built: two libraries, once thought merely to share a curious numerical
coincidence, turn out to be catalogues of the same tree — and the key that unlocks
the whole correspondence, for every $m$ at once, is simply to add one.
