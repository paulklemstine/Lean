# Counting Perfect Pairings: Why Some Networks Insist on Powers of Two

Imagine a grand ballroom at the close of an evening. Every dancer must
leave arm in arm with a partner, and there is a strict rule: two people
may pair up only if they already know each other. How many different ways
can the whole room walk out perfectly paired?

This is the question of **perfect matchings**, and it is one of the oldest
and most stubborn questions in combinatorics. Replace "dancers who know
each other" with "vertices joined by an edge," and you get a graph; a
*perfect matching* is a way of splitting all the vertices into pairs so
that each pair is connected by an edge. Counting these pairings sits at the
heart of statistical physics (where physicists call the count a
*dimer partition function*), of chemistry (where it measures how many ways
double bonds can be arranged in a molecule), and of pure mathematics (where
it is a notoriously hard cousin of the determinant known as the
*permanent*).

For most graphs the number of perfect matchings is a chaotic, seemingly
random integer. But every so often a family of graphs behaves with uncanny
discipline, and the count lands on a strikingly clean value. This article
is about one such family, and about a single clean law that explains why
its matchings are always an exact **power of two** — $1, 2, 4, 8, 16,
\dots$ — never anything in between.

## The smallest interesting room

Start with the smallest room worth studying: a square. Four dancers,
$A, B, C, D$, seated around a table, each acquainted only with the two
neighbors beside them. In graph language this is the four-cycle $C_4$: four
vertices in a ring, each joined to its two neighbors.

How many ways can everyone leave paired? There are exactly two. Either the
two "horizontal" edges are used ($A$ with $B$, $C$ with $D$), or the two
"vertical" edges are used ($B$ with $C$, $D$ with $A$). There is no third
option — the diagonals are not edges, so nobody can partner an
acquaintance-less stranger across the table.

$$\text{matchings of } C_4 = 2.$$

Two is the smallest count that is genuinely a *choice*: a graph with a
single perfect matching offers no freedom at all, while the square offers
precisely one binary decision. This makes $C_4$ the atom of our story — the
simplest gadget that says "yes or no," "this way or that."

The same is true of the hexagon $C_6$, six dancers in a ring. Trace it
carefully and you will again find exactly two perfect matchings: the "odd"
edges or the "even" edges, and nothing else. In fact *every* even cycle —
square, hexagon, octagon, and onward — has exactly two perfect matchings.
Each is a self-contained coin flip.

## Stacking coins

Now comes the idea that turns a single coin flip into a law. Suppose we
take many squares and lay them side by side — say $n$ separate squares,
with **no edges running between different squares**. Nobody in square number
three has ever met anybody in square number seven; the only acquaintances
are within one's own square.

What are the perfect matchings of this whole assembly? Because the squares
are completely disconnected from one another, a global pairing cannot
possibly send a dancer from one square to a partner in another — there is
no edge to do it. So every square must resolve its own pairing internally,
and it must do so *completely independently* of every other square.

Each square has two internal choices. With $n$ squares, and each choice
made freely and independently, the number of global pairings is

$$2 \times 2 \times \cdots \times 2 = 2^n.$$

There it is: the number of perfect matchings of $n$ independent squares is
always a power of two. Not approximately, not usually — *exactly*, and *by
construction*. The randomness that plagues generic matching counts
evaporates the moment the graph decomposes into independent binary gadgets.

## The law behind the law

The power-of-two phenomenon is really a shadow of a more general and more
beautiful principle, which we can state precisely. Take **any** graph $G$
whatsoever — call it a *block* — and make $n$ separate copies of it, with no
edges joining different copies. Call the result a *block graph*. Then:

> **Multiplicative Law.** The number of perfect matchings of a block graph
> built from $n$ independent copies of $G$ equals the number of perfect
> matchings of a single copy of $G$, raised to the power $n$:
> $$M(\text{$n$ copies of } G) = M(G)^{\,n}.$$

The proof is a clean bijection rather than a brute-force count, and it is
worth savoring because it makes the mechanism transparent. A perfect
matching of the whole assembly must, as we argued, keep each copy self-
contained: it never sends a vertex to another block, because there is no
edge to carry it there. So a global matching is nothing more and nothing
less than a *list* — one perfect matching chosen in each of the $n$ blocks.
Conversely, any such list glues back together into a global matching. The
global matchings and the lists of local matchings are in perfect one-to-one
correspondence, and the number of lists of length $n$ drawn from a pool of
$M(G)$ options is exactly $M(G)^n$.

Set $M(G) = 2$ — take the block to be a square, or a hexagon, or any even
cycle — and the general law collapses to the headline result:

$$M(\text{$n$ independent squares}) = 2^n.$$

The power of two is simply the multiplicative law wearing its most elegant
special case.

## Where the story came from

The result began life as a bolder-sounding conjecture. One might guess
that in *any* connected graph whose edges come in two flavors — call them
"one-matching" and "two-matching" edges — such that no single perfect
matching ever mixes the two flavors, the number of perfect matchings is
forced to be a power of two. The intuition is appealing: if matchings
really do split into independent binary choices, then counting them should
multiply twos together.

The contribution here is to extract the rigorous, provable heart of that
intuition. The essential structural fact is *independence*: the count is a
power of two precisely when the matchings decompose into independent
two-way choices. The block-graph model captures exactly this independence
and proves the law cleanly, with the even cycles serving as the canonical
two-choice gadgets. A single square is itself connected and already yields
the power of two $2 = 2^1$, matching the "connected" spirit of the original
guess; the block model then shows the same phenomenon persisting at any
scale.

## Why anyone should care

Perfect matchings are not an abstract game. In physics, the square-lattice
*dimer model* — molecules or spins pairing off on a grid — is a cornerstone
of exactly solvable statistical mechanics, and its partition function is
literally a matching count. In chemistry, the matchings of a molecule's
graph (its *Kekulé structures*) predict stability and reactivity. In
computer science, counting matchings is the canonical example of a problem
believed to be intractable in general (it is `#P`-complete), which makes the
rare families where the count is *forced* into a rigid, predictable form
genuinely valuable: they are islands of order in a computationally hostile
sea.

The lesson of the power-of-two law is that this order comes from
**modularity**. When a system decomposes into independent, identical
modules, its global complexity is not a mystery to be computed but a
formula to be read off: local choices raised to the number of modules.
Whenever you find a count that is suspiciously clean — a power of two, a
factorial, a neat product — it is worth asking whether some hidden
independence is doing the arithmetic for you.

## The frontier

The clean disconnected model is only the beginning. The natural next step
is to make the graph genuinely connected while preserving the power-of-two
count, by gluing gadgets together along *forcing edges* — edges that belong
to every perfect matching and therefore act like rigid rivets that neither
add nor remove matching choices. Conjecturally, such forced-tree gluings
keep the count an exact power of two, finally closing the gap between the
disconnected model and the original connected conjecture.

Two further questions beckon. First, is there a *spectral signature* — a
fingerprint in the eigenvalues of the graph — that detects exactly when a
matching count is a power of two? The integrality of $\log_2$ of the count
smells like the kind of rigidity that eigenvalues love to enforce. Second,
are the even cycles, up to gluing, the *only* connected two-choice gadgets?
The evidence is suggestive: two perfect matchings means the difference
between them is a single alternating cycle, and the graphs that support
exactly one such cycle are precisely the even rings.

From a square on a napkin to a conjectural classification of an entire
family of graphs, the through-line is a single, humble observation: when
choices are independent, you multiply. Sometimes the most powerful theorems
are the ones that tell you, rigorously, that nothing complicated is going
on.
