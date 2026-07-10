# The Shape of a Decision: Algebraic Cycles Hidden Inside Neural Networks

## A boundary you cannot see

Every time a neural network decides between "cat" and "dog," "spam" and "not spam," or "benign" and "malignant," it draws an invisible boundary through the space of all possible inputs. On one side of the boundary the answer is *yes*; on the other side it is *no*. That boundary — the set of inputs on which the network is perfectly undecided — is called the **decision surface**. It is where the network changes its mind.

For the most common kind of network, built from the humble *rectified linear unit* (ReLU), this surface has a startlingly rigid geometry. It is not a smooth, curving sheet like the surface of a soap bubble. Instead it is *piecewise linear*: it is stitched together from perfectly flat polygonal panels, like a geodesic dome or a paper model folded from flat sheets. The whole surface is a crumpled origami of flat faces.

This article is about a surprising bridge between that origami and one of the most famous unsolved problems in pure mathematics — the **Hodge conjecture** — and about a clean, provable statement that emerges once you cross the bridge. The punchline, stated up front, is a pair of facts:

1. For a ReLU network's decision surface, the analogue of the Hodge conjecture is **true**, and true for an almost embarrassingly simple reason.
2. The genuinely interesting question is not *whether* the surface's holes come from flat algebraic pieces, but *how many* holes there can be — and this number is controlled, exponentially, by the *width* of the network.

Let me unpack both.

## What the Hodge conjecture asks

In pure geometry, mathematicians study shapes called *projective varieties* — the solution sets of polynomial equations. Such a shape can have "holes" of various dimensions, and the bookkeeping of those holes is done by an algebraic gadget called **cohomology**. A hole is recorded as a *cohomology class*.

Some of these classes are especially concrete: they come from actual geometric sub-shapes sitting inside the variety, called **algebraic cycles**. Think of a circle drawn on the surface of a doughnut — it is a genuine curve you can point to, and it "detects" the doughnut's hole. The Hodge conjecture, one of the Clay Institute's million-dollar Millennium Prize Problems, asks whether *every* hole of a certain natural type can be detected this way: is every rational cohomology class a combination of algebraic cycles?

For general smooth varieties this is fiendishly hard and remains open. But something remarkable happens when we replace the smooth polynomial world with the *piecewise linear* world of neural networks.

## Why it becomes easy — and why that's the point

The decision surface $V(f) = \{x : f(x) = 0\}$ of a ReLU network is assembled from flat faces. Here is the key observation: **each flat face is itself an algebraic cycle**. A flat panel is exactly the set of points satisfying a single linear equation — a *hyperplane section*. Linear equations are the simplest possible polynomial equations, so every panel is, by definition, an algebraic piece.

Now the topology of any such cellular shape is computed from its panels. Every "hole," every homology class, is a formal combination of these flat cells. Since the cells are already algebraic, *every* class is automatically a combination of algebraic cycles.

We can state this cleanly.

> **Piecewise-Linear Hodge Representability.** Let $V(f)$ be the decision surface of a ReLU network, decomposed into its flat cells. Then every homology class of $V(f)$ is represented by a genuine cycle supported on those cells, each of which is a hyperplane section. In particular, every class is a rational combination of algebraic cycles.

The proof is a single structural remark. Working over a field, homology in a fixed degree is a *subquotient* $Z/B$ of the group of cellular chains: $Z$ is the group of *cycles* (chains with no boundary) and $B \subseteq Z$ is the group of *boundaries*. Passing from a cycle to its homology class is just the quotient map $Z \to Z/B$, and quotient maps are always surjective. So every class *is* the class of an actual cycle — and cycles are combinations of the flat cells. Existence is free.

This is why the "Hodge conjecture for neural networks" is true but, on its own, not the interesting statement. The interesting content is quantitative.

## The real question: how many holes can a network draw?

If existence is automatic, *counting* is where the mathematics lives. How complicated can a decision surface be? How many independent holes — how large a **Betti number** — can a network of a given size produce?

There is a beautiful two-part answer, one part topological and one part combinatorial.

**The topological half.** Over a field, the dimension of homology (the Betti number) is a subquotient dimension. Dimensions only shrink under passing to subgroups and quotients, so
$$\dim(Z/B) \le \dim Z \le \dim C,$$
where $C$ is the whole chain group. In words: *the number of independent holes is at most the number of cells.* You cannot manufacture more topological complexity than you have flat panels to build it from. Alongside this comes an exact accounting identity,
$$\beta + \operatorname{rank} B = \operatorname{rank} Z,$$
which says the Betti number $\beta$, plus the rank of the boundaries, equals the rank of the cycles — the local Euler-characteristic relation of the chain complex.

**The combinatorial half.** So how many cells are there? A ReLU network partitions its input space into *activation regions*: on each region, every neuron is either firing or silent, and $f$ is a single affine function. An **activation pattern** is the record of which neurons fire — one Boolean flag per hidden neuron. For a network with $L$ hidden layers of widths $w_1, \dots, w_L$, the number of possible activation patterns is exactly
$$\prod_{i=1}^{L} 2^{w_i} \;=\; 2^{\,w_1 + \cdots + w_L},$$
because each of the $w_i$ neurons in layer $i$ contributes an independent binary choice. Two to the power of the *total number of hidden neurons*.

There is a companion bound from the theory of hyperplane arrangements: $m$ hyperplanes cut space into at most $3^m$ sign-cells (each hyperplane assigns every point one of three states — above, on, or below), and any labelling of regions can realise at most that many.

**Putting the halves together** gives the headline theorem.

> **Width-Driven Betti Bound.** For the decision surface of a ReLU network with hidden widths $w_1, \dots, w_L$, every Betti number satisfies
> $$\beta \;\le\; \#\{\text{cells}\} \;\le\; \prod_{i=1}^{L} 2^{w_i} \;=\; 2^{\,\sum_i w_i}.$$

This is not a definitional triviality: the topological side genuinely uses the field structure (subquotient dimensions), the arithmetic side genuinely uses the product calculus of finite types, and the theorem is a real transitivity across the geometric bridge "number of cells $\le$ number of activation patterns."

## What this tells us about deep learning

The bound $2^{\sum_i w_i}$ is deliberately honest — and being honest, it is *loose*, and its looseness is informative. It depends only on the *total* neuron count, so it cannot yet distinguish a shallow-and-wide network from a deep-and-narrow one with the same number of neurons. Yet everything we know about deep learning says these two are not equal: depth seems to manufacture complexity far more efficiently than width.

This gap points to a sharper, still-conjectural refinement. The idea is that the *first* and *last* hidden layers play a special, "polarised" role. The first layer selects which input hyperplanes bound a face; the last selects which output half-spaces co-bound it; the interior layers only multiply the number of affine pieces linearly. This suggests a **bigraded** bound on the finer Hodge numbers $h^{p,q}$ of the surface:
$$h^{p,q}(V(f)) \;\le\; \binom{w_1}{p}\binom{w_L}{q}\prod_{i=2}^{L-1} w_i,$$
a Künneth-style product that separates the roles of the boundary layers from the interior — far finer than the crude $2^{\sum w_i}$.

A second theme is that *depth manufactures homology while width manufactures cycles*. Consider iterated "tent" folds: a depth-$k$ folding can create on the order of $2^k$ topological handles in a level set, even though the number of independent flat pieces needed per layer grows only linearly. The ratio (Betti number)/(cells per layer) then becomes an intrinsic complexity measure that cleanly separates deep from shallow representations — turning a count of how often a function crosses a threshold directly into a count of topological holes.

Finally, the exact identity $\beta + \operatorname{rank} B = \operatorname{rank} Z$ is a diagnostic tool. If a hidden neuron never fires simultaneously with its layer-mates, the corresponding boundary map loses rank, and the identity forces the surface to carry *more* holes than the generic bound would predict. In other words, **redundant neurons leave a topological fingerprint.**

## Why any of this matters

There is a growing recognition that to understand what neural networks *are* — not just how to train them — we need geometry and topology, not only statistics. The decision surface is the network's actual output as a geometric object, and its holes measure how tangled, how expressive, how potentially brittle the classifier is.

The bridge to the Hodge circle of ideas reframes a fashionable computational object in the language of one of mathematics' deepest conjectures, and in doing so clarifies what is easy and what is hard. Existence of algebraic representatives — the thing that is monstrously difficult for smooth varieties — is *automatic* here, because flatness is algebraicity. The difficulty migrates entirely into counting, where it becomes a precise question about network architecture: **how much topology can a given shape of network draw?**

The answer, for now, is bounded above by two raised to the number of hidden neurons. Tightening that bound — separating depth from width, boundary layers from interior — is where the geometry of intelligence gets genuinely interesting.
