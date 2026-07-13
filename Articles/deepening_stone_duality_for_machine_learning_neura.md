# The Hidden Logic of Neural Networks: A Boolean Shadow

Deep learning has a reputation for being a black box. We feed a network
numbers, it returns numbers, and somewhere in the middle a vast tangle of
weights conspires to draw a decision boundary through space. But hidden inside
even the most opaque network there lives a small, crisp, entirely
comprehensible object — a piece of pure logic. This article is about how to find
it, and about a beautiful old theorem, born in the 1930s far from any computer,
that explains exactly what it is.

## Neurons that say yes or no

Start with the simplest picture of a neuron. It looks at an input, computes a
weighted sum, and then decides: fire, or stay quiet. On, or off. One bit.

Now stack $k$ such neurons in a network. For any given input $x$, each neuron
produces one bit, so together they produce a string of $k$ bits — a tuple like
$(1, 0, 1, 1, 0)$. We call this the **activation pattern** of $x$. It is a
compact summary of "which neurons woke up" when the network looked at $x$.

Here is the first key observation. Two inputs that produce the *same* activation
pattern are, from the network's internal point of view, indistinguishable at
that layer: every neuron treated them identically. So the network silently
partitions its entire input space into groups — one group per activation
pattern. Each group is called an **activation cell**. All the geometry, all the
smooth arithmetic of weighted sums, ultimately collapses into a finite question:
*which cell does my input fall into?*

The set of all possible activation patterns is easy to describe. With $k$
neurons, each independently on or off, there are exactly

$$2^k$$

possible patterns. Call this finite collection the **pattern space** $P$. It is
the network's private alphabet.

## From geometry to logic

Once you have a finite alphabet, you can start doing logic with it. Consider any
*set* $S$ of patterns — say, "all patterns in which neuron 3 fires" or "the two
specific patterns $(1,0,0)$ and $(0,1,1)$." Each such set $S$ carves out a
**region** of the input space: precisely those inputs $x$ whose pattern happens
to belong to $S$. Write this region as

$$\text{region}(S) = \{\, x : \text{pattern of } x \in S \,\}.$$

This assignment — from *sets of patterns* to *regions of input space* — is the
star of our story. It is the network's **dual**, and it turns out to be a
perfect translator between two worlds. On one side sits combinatorial logic:
finite sets of bit-strings, combined with *and*, *or*, and *not*. On the other
side sits geometry: regions of a possibly high-dimensional input space. The
translator respects everything:

- The empty set of patterns maps to the empty region; the set of *all* patterns
  maps to the *whole* input space.
- The union of two pattern-sets maps to the union of their regions
  ($\text{region}(S \cup T) = \text{region}(S) \cup \text{region}(T)$).
- Their intersection maps to the intersection of regions.
- The complement of a pattern-set maps to the complement region
  ($\text{region}(S^c) = \text{region}(S)^c$).

In the language of algebra, the region map is a **homomorphism of Boolean
algebras**. Everything you can say with the logical connectives *and*, *or*,
*not* about patterns translates faithfully into set operations on input regions,
and vice versa. The messy analog machine has a clean logical skeleton.

## An old theorem wakes up

This is where a classical result enters, one of the jewels of twentieth-century
mathematics: **Stone duality**, proved by Marshall Stone in 1936. Stone's
theorem says that every Boolean algebra — every abstract system of *ands*,
*ors*, and *nots* — is secretly the algebra of "clopen" (simultaneously closed
and open) subsets of a certain topological space, its **Stone space**, built
from the algebra's ultrafilters. It is a dictionary between *syntax* (logic) and
*semantics* (space).

For our finite pattern space, this dictionary becomes wonderfully concrete. A
finite space, given the natural discrete topology, is what topologists call a
**Stone space**: it is compact, it is Hausdorff (distinct points can be
separated), and it is totally disconnected (it crumbles into isolated points).
On such a space *every* subset is clopen, so the Boolean algebra of clopen sets
is simply the full collection of all subsets of $P$. The network's pattern
space is, on the nose, a Stone space, and the region map is exactly the duality
Stone described — realized in the concrete world of neural computation.

## When is the shadow faithful?

A translator is only useful if nothing is lost in translation. When does the
region map lose no information — when is it **injective**, so that different
pattern-sets always produce different regions? The answer is crisp and
satisfying:

> **The region map is faithful if and only if the network realizes every
> possible pattern.**

If some activation pattern never actually occurs — no input ever lights up the
neurons in that exact configuration — then that pattern is invisible to the
geometry. Adding or removing it from a pattern-set changes nothing on the input
side. The dual detects these ghost patterns precisely: they are the "kernel" of
the translation, the information the network's logic contains but its geometry
cannot see. This is the working-model version of Stone's reconstruction theorem:
you can rebuild the logic from the geometry exactly when the logic is fully
witnessed.

## Atoms and cells

Boolean algebras have indivisible building blocks called **atoms** — the
smallest nonzero elements. For our algebra of pattern-sets, the atoms are the
singletons: the one-element sets $\{p\}$, each naming a single pattern. Under the
region map, an atom $\{p\}$ becomes exactly the activation cell of $p$: the set
of all inputs producing pattern $p$.

These cells behave exactly as a good partition should:

- **They never overlap.** Distinct patterns have disjoint cells — an input has
  one and only one pattern.
- **They cover everything.** Every input lands in some cell, so the cells
  together fill the entire input space.
- **A cell is inhabited exactly when its pattern is realized.** Empty cells
  correspond precisely to the ghost patterns above.

So the network's decision structure is completely captured by this tiling of
input space into logical atoms, and the abstract Boolean algebra tells you the
whole combinatorics of how those atoms combine.

## Counting the possible decisions

Because the dual is a faithful homomorphism whenever the network realizes all
patterns, we can *count* the number of distinct regions such a network can
express. Sets of patterns are subsets of a $2^k$-element space, and there are

$$2^{(2^k)}$$

of them. Each yields a distinct region. So a $k$-neuron network that uses its
full repertoire distinguishes exactly $2^{2^k}$ different regions of input
space. For $k = 3$ that is already $256$; for $k = 5$ it is more than four
billion. This double-exponential is the raw expressive capacity of the logical
layer — the number of yes/no questions about the input the network can, in
principle, phrase.

## The geometry the logic forgets

There is one more twist, and it is the most revealing part of the story. The
Boolean/topological picture is powerful, but it is deliberately *blind* to
geometry. It knows how cells combine; it does not know their shape.

Bring the shape back. For a genuine **perceptron layer** — where each neuron
fires when a linear (affine) function of the input exceeds a threshold — each
neuron's "on" region is a **half-space**, one side of a flat hyperplane slicing
through the input space. A cell is the set of inputs that satisfy a fixed on/off
verdict for *every* neuron at once, so it is an intersection of half-spaces. And
an intersection of half-spaces is always **convex**: if two points lie in a
cell, so does the entire straight segment between them.

This convexity is a fact about the input space that the Boolean dual simply
cannot see. Two networks could have identical logical duals — the same abstract
Boolean algebra, the same atoms, the same combinatorics — while carving space
into cells of very different shapes. The perceptron layer, in other words,
carries strictly more structure than its Stone shadow. The dual captures the
*logic* of the network exactly; the *geometry* is extra information layered on
top.

## Why this matters

This correspondence reframes what a neural network *is*. Beneath the analog
surface of weights and sums lives a finite Boolean algebra, and by a classical
duality that algebra is the same thing as a compact, crumbly topological space —
the network's pattern space — together with a faithful translation into the
regions of its input world. The messy part (real-valued arithmetic) and the
clean part (finite logic) are joined by a bridge that has been sitting in
mathematics since 1936.

Practically, this suggests a principled way to reason about what a network can
and cannot express: count its patterns, study which are realized, examine the
convex tiling they induce. Philosophically, it says something gentler about
black boxes. The opacity of a neural network is not fundamental. Inside every
one of them is a small clear crystal of logic, and an old theorem tells us
exactly how to read it.
