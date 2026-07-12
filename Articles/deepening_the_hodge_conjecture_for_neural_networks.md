# The Shape of a Decision

## When a neural network draws a line in the sand

Every classifier draws a boundary. Show a trained network thousands of images of cats and dogs, and somewhere inside its tangle of numbers a surface forms — the exact place where the machine changes its mind. On one side, *cat*; on the other, *dog*; and on the surface itself, perfect indecision. That surface is the network's decision boundary, and its geometry is where the network keeps its knowledge.

For the enormously popular family of *rectified-linear* networks — the ones built from the humble rule "output the input if it is positive, otherwise output zero" — this boundary is not some smooth, curving manifold. It is a **piecewise-linear** object: a patchwork of flat pieces, stitched together along creases, like an origami sheet or the faceted surface of a cut gemstone. The network carves its input space into a mosaic of regions, and inside each region it behaves like a perfectly ordinary linear map. The decision surface is the seam where these flat facets meet.

This article is about a single, sturdy number attached to that faceted surface — a number that refuses to change no matter how you wiggle the network's weights, as long as you don't tear the surface. It is called the **Euler characteristic**, and the result we describe pins it down exactly for the decision surfaces of rectified-linear networks. The punchline is a form of *rigidity*: the topology of a network's decision boundary is far more constrained than the boundary's ever-shifting shape would suggest.

## Counting, the oldest kind of geometry

Long before calculus, people knew how to count corners. Leonhard Euler noticed in the eighteenth century that if you take any convex solid — a cube, a pyramid, a soccer ball — and count its vertices $V$, its edges $E$, and its faces $F$, you always get

$$V - E + F = 2.$$

A cube: $8 - 12 + 6 = 2$. A tetrahedron: $4 - 6 + 4 = 2$. A soccer ball with its pentagons and hexagons: still $2$. The individual counts change wildly from shape to shape, but that particular alternating sum is stubbornly, magically constant. Deform the solid, add facets, shave off corners — as long as you don't punch a hole through it, the number $2$ survives.

That alternating sum is the Euler characteristic. Its deep meaning, uncovered over the following two centuries, is that it is a **topological invariant**: it measures something about the *connectivity and holes* of a shape, not its size or its precise cut. A doughnut has Euler characteristic $0$; a two-holed pretzel, $-2$. The number counts holes, weighted by dimension, with alternating signs.

The modern way to compute it uses *homology*. To a shape one attaches a ladder of vector spaces — one for each dimension — recording its "$0$-dimensional holes" (connected pieces), "$1$-dimensional holes" (loops you cannot fill in), "$2$-dimensional holes" (voids), and so on. The dimensions of these spaces are the **Betti numbers** $b_0, b_1, b_2, \dots$, and the Euler characteristic is their alternating sum:

$$\chi = b_0 - b_1 + b_2 - \cdots.$$

Here is the miracle, in its most useful form. To *build* the ladder of homology spaces you must record not just how big each level is, but exactly how the levels connect — the "boundary maps" that say which edges bound which faces. Those connecting maps are delicate; nudge them and the Betti numbers themselves can jump. And yet the alternating sum does not. **The Euler characteristic can be read off from the sizes of the raw building blocks alone, before you know a single thing about how they connect.** This is the Euler–Poincaré principle, and it is the engine of everything below.

## From origami to algebra

Take a rectified-linear network and look at its decision surface — the folded, faceted seam of indecision. Because everything is piecewise-linear, the surface comes pre-assembled as a **cellular complex**: a finite collection of flat cells glued along shared faces. There are $2$-dimensional facets, the $1$-dimensional edges where they meet, and the $0$-dimensional vertices where edges meet. Call the spaces spanned by these cells $C_2$, $C_1$, and $C_0$. Boundary maps connect them,

$$C_2 \xrightarrow{\;d_2\;} C_1 \xrightarrow{\;d_1\;} C_0,$$

where $d_1$ sends each edge to its two endpoints and $d_2$ sends each facet to the loop of edges around its rim. The defining law of any such complex is that *the boundary of a boundary is empty*: $d_1 \circ d_2 = 0$. The rim of a facet is a closed loop, so tracing its endpoints cancels out.

The homology of the surface now lives in three places, and each is a familiar algebraic object:

- **$H_0$**, the connected components, is a *cokernel*: the vertices, modulo those that are already the endpoints of edges. Its dimension is
$$\dim H_0 = \dim C_0 - \operatorname{rank} d_1.$$
- **$H_2$**, the enclosed voids, is a *kernel*: the facets whose rims vanish — the closed shells. Its dimension is
$$\dim H_2 = \dim C_2 - \operatorname{rank} d_2.$$
- **$H_1$**, the loops that are not filled in, is the subtle middle case, a *subquotient*: cycles (edge-loops with no endpoints) modulo boundaries (rims of facets). Rank–nullity gives
$$\dim H_1 = \dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2.$$

Each of these three formulas is a careful piece of linear algebra — a cokernel here, a kernel there, and in the middle a quotient of a subspace that requires knowing that the rim-space really does sit inside the loop-space (which is exactly the law $d_1 \circ d_2 = 0$). None of them is automatic.

## The rigidity theorem

Now watch the differentials disappear. Form the alternating sum of the three homology dimensions and substitute the formulas above:

$$
\dim H_0 - \dim H_1 + \dim H_2
= \big(\dim C_0 - \operatorname{rank} d_1\big) - \big(\dim C_1 - \operatorname{rank} d_1 - \operatorname{rank} d_2\big) + \big(\dim C_2 - \operatorname{rank} d_2\big).
$$

Every rank term cancels in pairs. What is left is the clean statement:

> **Euler characteristic of a decision surface.** For the cellular complex of any rectified-linear network's decision surface,
> $$\dim H_0 - \dim H_1 + \dim H_2 = \dim C_0 - \dim C_1 + \dim C_2.$$

The left-hand side is topology — components minus loops plus voids. The right-hand side is pure bookkeeping — how many vertices, edges, and facets the surface has. The boundary maps $d_1$ and $d_2$, which encode the entire intricate wiring of the surface, have vanished from the equation. **You can compute the Euler characteristic by counting cells, without ever understanding how they connect.**

This is not a coincidence of the three-term case. Underneath sits a general **Euler–Poincaré principle**: for a numerical model of a chain complex of any length, in which the homology dimensions obey the natural rank–nullity relations, the alternating sum of homology dimensions equals the alternating sum of chain dimensions, up to a single leftover term coming from the very top of the complex:

$$\sum_n (-1)^n\, \dim H_n \;=\; \sum_n (-1)^n \dim C_n \;-\; (-1)^L \operatorname{rank} d_L.$$

The proof is an induction that *telescopes*: each rank appears twice with opposite signs and annihilates its neighbour, leaving only the boundary term at the very end. When the complex is **bounded** — when nothing spills out of the top, so $\operatorname{rank} d_L = 0$ — that last term is gone and the two alternating sums are equal on the nose. A decision surface, being a finite faceted object, is bounded; hence its Euler characteristic is exactly its cell-count alternating sum.

## Why this matters: complexity you can bound in advance

The rigidity is more than elegant. It is *predictive*, because the number of cells a rectified-linear network can create is itself bounded by the network's architecture. A network's hidden layers have widths $w_1, w_2, \dots$; each neuron can be "on" or "off," and the input space is chopped into at most $\prod_i 2^{w_i}$ activation regions. The decision surface inherits a matching ceiling on its cell counts. Combining this with the rigidity theorem yields a bound that needs no training data, no weights, no forward passes — only the shape of the network:

$$|\chi| \;\le\; 3 \cdot \prod_i 2^{w_i}.$$

Read this as a statement about *expressive power*. The Euler characteristic is a coarse measure of how topologically complicated a decision boundary can be — how many separate pieces, how many loops, how many enclosed pockets it can carve out of the world. The inequality says that this complexity is capped, exponentially in the widths, and that the cap is a property of the wiring diagram alone. A narrow network simply cannot draw a boundary with too many holes, no matter how it is trained. The topology of what a network can *know* is written into its architecture before it ever sees an example.

There is a second, subtler payoff. Because the Euler characteristic depends only on cell counts and not on the differentials, it is **stable under training**. As a network learns, its weights drift continuously, its facets flex and slide, and its individual Betti numbers may flicker up and down. But so long as the combinatorial type of the surface is preserved — so long as no facet collapses or is born — the alternating sum stays fixed. The Euler characteristic is a conserved quantity of learning, an anchor of topological identity amid the churn of gradient descent.

## The larger dream

The title of the broader program that gave rise to this work invokes one of mathematics' most famous unsolved problems: the Hodge conjecture, which asks whether the deepest topological features of certain geometric spaces must always come from *algebraic* sources — from honest polynomial equations rather than mere continuous flexibility. The dream animating this line of research is an analogue for neural networks: to understand the topology of a decision boundary entirely in terms of the discrete, algebraic combinatorics of the network's activation regions.

The Euler characteristic result is the first firm rung on that ladder. It shows that at least one genuine topological invariant of the decision surface — the alternating sum of all its Betti numbers — is *completely determined* by algebraic cell-counting, and is bounded, in advance, by the architecture alone. The finer dream is a whole "Hodge diamond" of such invariants, one for each way of splitting complexity by the depth at which neurons activate; the single Euler number described here is its first shadow.

For now, the moral is clean and surprisingly concrete. A neural network's decision boundary is an origami surface, endlessly reconfigurable as the network learns. But threaded through all that motion is one number — components minus loops plus voids — that you can compute by counting flat pieces, that never changes unless the surface tears, and that the network's own width forbids from ever growing too large. Beneath the shifting shape of a decision lies a rigid, countable skeleton. That skeleton is the shape of what the machine can know.
