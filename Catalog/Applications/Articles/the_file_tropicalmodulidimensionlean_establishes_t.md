# The Shape of All Curves: How Counting Edges Reveals the Geometry of Moduli Space

## A universe that catalogues shapes

Imagine a vast museum whose every exhibit is not a painting or a sculpture but an
entire *shape* — a smooth curve, a surface, a geometric object of a fixed complexity.
Mathematicians have such a museum. They call it a **moduli space**, and it is one of
the central organizing ideas of modern geometry. A moduli space is a space whose points
*are themselves* geometric objects. Walk a step in one direction and the curve you are
looking at bends a little more; walk in another and a handle on its surface grows or
shrinks. The moduli space of curves of genus `g`, written `M_g`, packages every
possible curve with `g` holes into a single continuous landscape.

These landscapes are gorgeous but notoriously difficult. `M_g` is a curved,
high-dimensional, singular world that has occupied geometers for over a century. So a
natural question arises: is there a *skeleton* of this museum — a simplified scaffold
that captures its essential shape, its dimension, its boundary, its combinatorial
backbone — without all the analytic difficulty?

There is. It is called the **tropical moduli space** `M_g^trop`, and this article is
about a clean, complete, machine-checked account of its most fundamental property: its
**dimension**, and the surprising fact that the entire dimension theory is, at heart,
nothing more than careful counting.

## Tropical geometry: when curves become graphs

"Tropical" geometry earned its whimsical name in honor of the Brazilian mathematician
Imre Simon, and it has nothing to do with the weather. It is a kind of geometry played
on a strange arithmetic where *adding* two numbers means taking their **minimum** (or
maximum), and *multiplying* them means ordinary **addition**. Under these rules, smooth
algebraic curves — the curving, continuous objects of classical geometry — degenerate
into something startlingly simple: **graphs**. Vertices and edges. Dots and lines.

A tropical curve is a connected graph in which:

- every **edge** has been assigned a positive **length**, turning the graph into a
  genuine metric space; and
- every **vertex** carries a non-negative integer **weight**, a bookkeeping device that
  remembers how much "hidden genus" got crushed down to that point when the smooth
  curve degenerated.

The **genus** of such a tropical curve is its total complexity, and it splits into two
contributions. The first is the number of independent loops in the graph — its **first
Betti number** `b₁`, the number of cuts you would need to make to turn the graph into a
tree. The second is the total vertex weight `W`, the genus hidden in the dots. The
fundamental relation is:

> **genus = (number of loops) + (total vertex weight)**, i.e. `g = b₁ + W`.

A figure-eight graph has two loops and no weight, so genus 2. A single point carrying
the weight `2` also has genus 2 — it is the totally degenerate limit of a genus-2 curve.
Everything in between fills out the tropical moduli space.

## The combinatorial type: forget the lengths, keep the shape

Here is the key move. A tropical curve carries two kinds of information: its
**combinatorial type** (which vertices, which edges, which weights — the wiring diagram)
and its **metric** (the actual edge lengths). If we slide the edge lengths around
continuously without ever shrinking one to zero, the wiring diagram never changes. So
`M_g^trop` is naturally tiled into **cones**: one cone for each combinatorial type, and
inside that cone, a point is just a choice of positive lengths for the edges. A type
with `e` edges contributes an `e`-dimensional cone (one coordinate per edge length).

The dimension of the whole space is therefore the **largest number of edges any
combinatorial type can have**. And to understand the space's combinatorics, we only need
to understand its combinatorial types. We can throw away the continuous metric data
entirely and reduce everything to *counting*.

This is the heart of the work described here. We record a combinatorial type by five
plain non-negative integers:

- `vert0` — the number of vertices of weight zero;
- `vertPos` — the number of vertices of positive weight;
- `edges` — the number of edges;
- `weight` — the total vertex weight `W`;
- `genus` — the genus `g`.

The total number of vertices is `v = vert0 + vertPos`. These five numbers are not free;
the geometry of degenerating curves forces three iron laws upon them.

## Three laws of counting

**Law 1 — The genus formula.** Connectedness of the graph and the definition of genus
combine into a single linear equation:

> `g + v = e + 1 + W`.

Rearranged, this says `b₁ = e − v + 1` (the standard Euler-characteristic count of
loops in a connected graph) and `g = b₁ + W`. Encoding it *additively* like this — with
no subtraction — turns out to be the secret to making every later argument trivial for a
computer to check, because subtraction of natural numbers is treacherous (it can't go
below zero), whereas addition is honest.

**Law 2 — Stability.** Not every weighted graph is allowed. A tropical curve must be
**stable**: it cannot have floppy, contractible pieces. The precise condition is that at
every vertex `x`, the quantity `2·weight(x) − 2 + valence(x)` is strictly positive (the
valence is the number of edge-ends meeting `x`). Stability is what guarantees the
moduli space is finite-dimensional and that each curve has only finitely many
symmetries. Summing this local condition over all vertices, and using the famous
**handshake lemma** of graph theory — *the sum of all vertex valences equals twice the
number of edges* — produces one clean global inequality:

> `3v ≤ 2W + 2e`.

This single line packages stability and the handshake lemma together, and it is the
engine behind every dimension bound.

**Law 3 — Connectedness.** A connected graph never has more vertices than one plus its
edge count:

> `v ≤ e + 1`,

with equality exactly when the graph is a tree.

A fourth, gentle bookkeeping fact rounds things out: since every positive-weight vertex
carries weight at least one, the number of such vertices never exceeds the total weight,
`vertPos ≤ W`.

That's the entire setup. Three linear laws over the integers. From them, the whole
dimension theory of `M_g^trop` tumbles out.

## The payoff: the dimension of moduli space

**The vertex bound.** Add Law 1 and Law 2 together and watch the weights and edges
cancel. The result is a clean ceiling on the number of vertices:

> **A stable tropical curve of genus `g` has at most `2g − 2` vertices.**
> (Formally: `v + 2 ≤ 2g`.)

**The edge bound — the dimension theorem.** Feed the vertex bound back into the genus
formula and discard the non-negative weight term, and you obtain the crown jewel:

> **A stable tropical curve of genus `g` has at most `3g − 3` edges.**
> (Formally: `e + 3 ≤ 3g`.)

Because each edge contributes one dimension to its cone, this says precisely that

> **`M_g^trop` has dimension `3g − 3`.**

This is the famous count first computed by Riemann in the 1850s for the *classical*
moduli space `M_g` — the number `3g − 3` is one of the oldest and most celebrated
constants in all of geometry. Here it reappears on the tropical skeleton, derived from
nothing but adding and subtracting three inequalities. The skeleton has exactly the
same dimension as the museum it scaffolds. That is no accident: `M_g^trop` is the
*boundary complex* of `M_g`, and dimensions match.

## The Jacobian and the Torelli map

There is a second classical structure that survives the tropical degeneration: the
**Jacobian**. To every curve, classical geometry attaches an abelian variety — a
higher-dimensional torus — built from the curve's loops. The map sending a curve to its
Jacobian is the celebrated **Torelli map**, and a deep theorem says it remembers almost
everything about the curve.

Tropically, the Jacobian becomes the **cycle space** of the graph: the lattice of all
the independent loops. Its dimension is exactly the first Betti number `b₁`. Combining
the genus formula with the loop count gives a beautifully simple identity:

> **dim(tropical Jacobian) = `b₁ = g − W`.**

In words: the Jacobian's dimension is the genus minus whatever genus got hidden inside
vertex weights. And because a connected graph always satisfies `v ≤ e + 1`, this
dimension is always non-negative — you can never have negative loops. The tropical
Torelli map thus *factors through* the Jacobian, sending each type to a lattice of
dimension `g − W`, and the picture degenerates gracefully: as weight accumulates at
vertices, loops disappear, and the Jacobian shrinks.

The extreme cases are illuminating. When the total weight equals the genus (`W = g`),
the Betti number is zero: the graph is a **tree**, has no loops, and its Jacobian is a
single point. Conversely, a weight-zero tree is forced to have genus zero — the
genus-`0` picture appears as the degenerate stratum where all the complexity has either
vanished or been swept into a single weighted point.

## A finite atlas

A moduli space is only tractable if you can get your arms around it. Could there be
infinitely many combinatorial types of a given genus, making the tropical fan an
unmanageable infinite mosaic? No. The three laws bound *every* invariant: vertices by
`2g`, edges by `3g`, weight by `g`. So every legal type is just a point in a finite box
of integer coordinates. Consequently:

> **For each fixed genus `g`, there are only finitely many combinatorial types.**

The tropical moduli space is a **finite** cone complex — a finite number of cones glued
along their faces. This finiteness is what makes `M_g^trop` a genuine computational
object: one can, in principle, list every type, draw every cone, and study the whole
space by exhaustive search. For genus 2, for instance, there are only a handful of
types; the article's companion demonstration enumerates them all.

## The top cones are honest trivalent graphs

The dimension bound `e ≤ 3g − 3` raises an obvious question: is it *sharp*? Does the
maximum actually get attained? The answer is yes, and it comes with a beautiful
geometric portrait. The top-dimensional cones — the ones realizing `e = 3g − 3`,
`v = 2g − 2`, and zero vertex weight — correspond to graphs that are **trivalent**: every
single vertex has exactly three edges meeting it.

Why three? Apply the handshake lemma to a 3-regular graph: the sum of valences is `3v`,
and it equals `2e`, so `3v = 2e`. With zero weight, the genus is the Betti number, and
this equality forces precisely `|V| = 2b₁ − 2` and `|E| = 3b₁ − 3`. Trivalent graphs are
the maximally branched, maximally loopy stable graphs — the generic, "most spread out"
degenerations of a smooth curve — and they sit at the open top-dimensional faces of the
cone complex. For every genus `g ≥ 2` such a graph exists, so the `3g − 3` bound is
attained and the dimension count is exact, not merely an upper estimate.

A pleasant sanity check from everyday graph theory: a 3-regular graph must have an even
number of vertices (since `3v = 2e` forces `v` even), which matches `2g − 2` exactly.
The smallest case, genus 2, gives `v = 2`, `e = 3` — two vertices joined by three edges,
the so-called **theta graph**, the dumbbell's cousin. It is the generic genus-2 tropical
curve, and it lives at the very top of the two-dimensional `M_2^trop`.

## Why this matters

It would be easy to dismiss all of this as bookkeeping. It is not. Three things make
this circle of ideas important.

**First, it is a bridge.** Tropical geometry translates hard questions about continuous,
analytic moduli spaces into finite, combinatorial questions about graphs. The dimension
`3g − 3`, the structure of the boundary, the behavior of the Torelli map — phenomena
that classically require deep machinery — become statements about counting edges and
loops. `M_g^trop` is, in a precise sense made rigorous by Abramovich, Caporaso, and
Payne, the **Berkovich skeleton** of the classical `M_g`: a deformation retract that
captures its essential topology.

**Second, it is exact.** Every claim above is not merely argued but *proven* with
complete rigor, the kind of certainty a machine can verify line by line. The genus
formula, the stability inequality, and connectedness are encoded as three linear
relations among five integers, and from them the vertex bound, the edge bound, the
Jacobian dimension, finiteness, and the trivalent realization all follow by pure
integer arithmetic. The governing discovery is that **once the handshake lemma is
applied, the entire dimension theory of `M_g^trop` is linear over the integers.** There
is no analysis, no scheme theory, no limits — just honest counting, made airtight.

**Third, it opens doors.** With the numerical skeleton fixed, one can now ask the deeper
questions on solid ground: Can we enumerate every isomorphism class of stable graph,
not just every invariant vector? Is the tropical Jacobian's quadratic form always
positive semidefinite, landing the Torelli map in the cone of such forms? Do the
Torelli fibers stay finite, governed by the cographic matroid of the graph? Does edge
contraction organize the cones into a pure `(3g − 3)`-dimensional complex? And can the
whole thing be realized as a contractible metric space, the tropical shadow of the
Berkovich skeleton? Each of these is a concrete next step, and each rests on the
foundation laid here.

## The beauty of counting

There is a recurring miracle in mathematics: that the deepest structures often have the
simplest skeletons. The moduli space of curves is one of the most intricate objects ever
studied, a century-old challenge bristling with analytic subtlety. And yet its
dimension, its finiteness, its boundary, and the behavior of its Jacobian map are all
encoded in five integers tied together by three linear laws. Riemann's `3g − 3`, derived
in the 1850s through the analysis of differentials, reappears on the tropical skeleton
as the answer to a question a careful accountant could pose: *given the rules, how many
edges can a graph of genus `g` have?* The answer — `3g − 3` — is the same. The museum and
its scaffold share a dimension, and the scaffold can be built with nothing but counting.
