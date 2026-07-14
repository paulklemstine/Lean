# Painting a Graph So No Two Neighbours Look Alike

## A colouring puzzle with a hidden rule

Imagine you are handed a network — dots joined by lines — and a box of
coloured pens. Your job is to colour *everything*: every dot and every line.
There are two rules. First, the ordinary one: things that touch must get
different colours. Two dots joined by a line, two lines meeting at a dot, a dot
and a line that touch — all must differ. This is called a **total colouring**,
because unlike ordinary map-colouring it paints the connections as well as the
places.

The second rule is subtler and far more interesting. Give each dot a
*fingerprint*: the set of colours you can see standing at that dot — its own
colour, together with the colours of every line leaving it. The rule is that
**no two dots that are directly connected may share the same fingerprint.** A
colouring that respects this is called **adjacent-vertex-distinguishing**, or
AVD for short. The idea is that a person standing at one dot should be able to
tell they are somewhere different from their neighbour just by looking at the
palette of colours around them.

The natural question is: *how many colours do you need?* For a given network,
what is the smallest palette that admits a total colouring in which every pair of
neighbours has a different fingerprint? That number is the star of this article,
and for one particular family of networks we can pin it down exactly.

## The central graph: a network turned inside out

The networks we study are not arbitrary. They are built by a specific recipe
from a starting graph $G$. Take $G$ — say a pentagon, or a triangle, or any
network of dots and lines — and perform two operations to produce its
**central graph** $C(G)$:

1. **Subdivide every line.** Put a new dot in the middle of each original edge,
   splitting it into two half-edges. These new dots are the *subdivision
   vertices*.
2. **Connect the strangers.** Take every pair of original dots that were *not*
   directly joined in $G$, and join them now.

The result is a strange hybrid. The original dots become extremely social:
each one is now connected to *every other original dot*, because either they
were connected before (and the connection is preserved through their shared
subdivided edge structure) or they were strangers (and step 2 just introduced
them). Meanwhile the subdivision dots stay shy — each sits on exactly one
former edge and touches only its two endpoints, so it has just two neighbours.

This lopsided structure — a clique-like core of highly connected original dots,
surrounded by a sparse fringe of degree-two subdivision dots — turns out to be
the entire secret behind the colouring bound.

## The star at a vertex forces your hand

Here is the first pressure point. Pick any original dot $v$ in the central
graph. Look at the "star" around it: the dot $v$ itself, plus all the lines
leaving $v$. In a total colouring, *all of these must get different colours* —
$v$ differs from each of its lines, and any two lines meeting at $v$ differ from
each other. So the number of colours you need is at least the size of this star.

How big is the star? An original dot in $C(G)$ is joined to every one of the
other $|V| - 1$ original dots (where $|V|$ is the number of original dots), and it
also touches some subdivision dots. Counting carefully, the degree of every
original vertex in $C(G)$ works out to exactly $|V| - 1$. Its star — itself plus
its incident lines — therefore has exactly $|V|$ elements. So:

> **Any total colouring of $C(G)$ needs at least $|V|$ colours.**

That is the floor. But the AVD rule pushes us one step higher, and the reason is
beautiful.

## Why $|V|$ colours can never be enough

Suppose we tried to get away with *exactly* $|V|$ colours. Consider two
original dots $a$ and $b$ that were **strangers** in the original graph $G$ — not
directly connected. In the central graph they *are* connected (step 2 introduced
them), so the AVD rule demands that their fingerprints differ.

But here is the trap. Both $a$ and $b$ have degree exactly $|V| - 1$, so the
star at each of them has exactly $|V|$ elements. With only $|V|$ colours
available, and $|V|$ elements in the star that must all be coloured differently,
you are forced to use **every single colour** at $a$. The fingerprint of $a$ is
therefore the *entire palette*. By the identical argument, the fingerprint of
$b$ is also the entire palette. So the two fingerprints are equal — the full set
of colours — and the AVD rule is violated. There is no escape.

This is the heart of the matter, and it deserves a name: the **adjacent
equal-degree obstruction**. Whenever two connected dots have the *same* degree
$\Delta$, and you offer only $\Delta + 1$ colours, both are forced to use the
whole palette and their fingerprints collide. In the central graph, *every*
pair of former strangers is such a pair, sitting at the shared degree $|V| - 1$.

The conclusion is clean and, remarkably, needs no special assumptions about the
original graph beyond having at least one pair of strangers:

> **Sharp lower bound.** For any finite network $G$ that contains at least one
> pair of non-adjacent distinct vertices, every adjacent-vertex-distinguishing
> total colouring of the central graph $C(G)$ uses **at least $|V| + 1$
> colours**.

The number that governs the whole problem is $|V| + 1$ — one more than the
number of original dots. Not the density of the graph, not its most crowded
vertex: just the raw count of dots, plus one.

## Why "plus one" is exactly right, and not more

The extra colour beyond $|V|$ is not a technicality — it is precisely what lets
neighbouring fingerprints pull apart. With $|V| + 1$ colours, each original dot
still uses $|V|$ of them across its star, but now it has a *choice* of which one
to leave out. Two neighbouring dots can leave out different colours, so their
fingerprints — each missing one colour from the palette — differ in exactly the
right place. The lone subdivision dots, with only two neighbours apiece, have
enormous freedom and never create fresh conflicts; they quietly absorb whatever
colours are left over. This is why $|V| + 1$ is believed to be not just a floor
but the exact answer for every non-complete graph.

## The regular case, and a pentagon

Historically this problem was first attacked for **regular** graphs — networks
where every dot has the same number of connections $d$. If a $d$-regular graph
is *not* complete (not everybody connected to everybody), then it must have a
pair of strangers, and a short counting argument shows it must have at least
$d + 2$ dots. Feeding $|V| \ge d + 2$ into the sharp bound above gives

$$|V| + 1 \ge (d + 2) + 1 = d + 3.$$

So every $d$-regular non-complete graph satisfies

> $$\chi''_a\bigl(C(G)\bigr) \ge d + 3,$$

where $\chi''_a$ denotes the smallest AVD-total palette size. This recovers the
classical regular bound — but now it is exposed as a mere shadow of the deeper,
regularity-free fact. The regularity was never doing the real work; it only
served to translate the honest quantity $|V| + 1$ into the language of degrees.

The pentagon $C_5$ makes the improvement concrete. The five-cycle is
$2$-regular, so the old regular reasoning promises only $d + 3 = 5$ colours. But
the pentagon has $|V| = 5$ dots, and the sharp bound says we need at least
$|V| + 1 = 6$. The true requirement is **six colours**, one more than the
regular estimate ever revealed. The structural viewpoint doesn't just reprove
the old result — it sharpens it.

## The moral of the story

Sometimes a hard-looking problem is hard only because we are looking at it
through the wrong lens. The AVD-total colouring number of a central graph *seems*
to depend on intricate details — the degree sequence, the pattern of
connections, whether the graph is regular. But strip away the surface and a
single structural fact does all the work: **in a central graph, every original
dot has the same degree $|V| - 1$, so every pair of former strangers is an
equal-degree neighbouring pair, and equal-degree neighbours cannot be told apart
on a palette that is too tight.**

From that one observation the entire lower bound $|V| + 1$ falls out, the
regular special case $d + 3$ becomes a one-line corollary, and the pentagon's
answer jumps from a loose $5$ to the exact $6$. The number of colours you need
to paint a central graph so that no two neighbours look alike is governed not by
how crowded the graph is, but simply by how many places it has — plus one for
good measure.
