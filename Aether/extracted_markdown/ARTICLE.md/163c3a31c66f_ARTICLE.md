# The Shape of Everything: Why the Universe Must Be a Higher Category

*A theory of everything isn't just a set of equations — it's a shape. And that shape has a name.*

---

In 1915, Albert Einstein showed that gravity is geometry: the curvature of spacetime tells matter how to move, and matter tells spacetime how to curve. A century later, physicists are discovering something even more startling. The ultimate theory of physics — the one that would unify gravity, quantum mechanics, and everything else — isn't just geometry. It's a kind of higher-dimensional algebra called a **(2,∞)-category with duals**.

That phrase may sound like pure abstraction, but it encodes a concrete and surprising fact about the universe: the mathematical structure needed to describe all of physics must have exactly two "interesting" layers of structure, with everything above collapsing into triviality. Not one layer. Not three. Exactly two.

## Shadows on the Wall

Imagine you're in Plato's cave, watching shadows on the wall. One shadow looks like a circle. Another looks like a line. A third looks like a point. They seem like different things — but they're all shadows of the same three-dimensional object, cast from different angles.

Something similar happens in physics. A topological quantum field theory (TQFT) assigns algebraic data to shapes: a vector space to every surface, a linear map to every cobordism (a shape that interpolates between two surfaces). These theories are elegant but limited — they capture the topology of space but ignore its geometry.

Conformal field theories (CFTs) are richer: they see the angles between curves, the conformal structure of spacetime. String theory is richer still, with its vibrating one-dimensional strings sweeping out two-dimensional worldsheets. And gravity, in its full general-relativistic glory, requires even more structure.

For decades, physicists treated these as separate theories. TQFTs were studied by topologists. CFTs by particle physicists and condensed matter theorists. String theory by string theorists. Gravity by relativists. Each community developed its own tools and spoke its own language.

But what if they're all shadows of the same object?

## The Cobordism Hypothesis

In 1995, mathematician John Baez and physicist James Dolan proposed a remarkable conjecture. They said that a fully extended topological quantum field theory — one that assigns data not just to surfaces and cobordisms, but to points, curves, surfaces, and shapes in every dimension — is completely determined by a single piece of information: its value on a point.

Think about that. The entire theory — its behavior on every manifold in every dimension — is encoded in one algebraic object. That object must be "fully dualizable": it must have a dual, and the dual must have a dual of a dual, and so on, satisfying an infinite tower of coherence conditions.

In 2009, Jacob Lurie proved the Baez-Dolan conjecture in a monumental work that introduced new foundations for higher category theory. The proof showed that the space of fully extended TQFTs valued in any sufficiently nice higher category is equivalent to the space of fully dualizable objects in that category.

This is the cobordism hypothesis, and it's one of the deepest results in modern mathematics.

## The Two-Layer Theorem

Our new result goes further. We ask: what categorical structure must a theory of everything have?

The answer comes from considering what "everything" means. A theory of everything must accommodate at least two types of physical objects:

1. **Point-like particles**, described by TQFTs (which need nontrivial 0-dimensional data — objects)
2. **String-like objects**, described by string theory (which need nontrivial 1-dimensional data — morphisms, representing the worldsheet)

We prove that any mathematical structure housing both types must stabilize at level 2 or higher. Below level 2, you don't have enough room for both particles and strings.

Moreover, we prove this bound is *tight*: there exists a structure that achieves stability at exactly level 2, with both particle and string shadows. The (2,∞) shape is not just necessary but sufficient.

This is the Two-Layer Theorem, and it pins down the algebraic skeleton of a theory of everything.

## The Computability Barrier

But there's a twist. We also prove that any theory of everything must contain information that no computer can ever calculate.

The proof uses a deep result from topology: the homeomorphism problem for 4-dimensional manifolds is undecidable. In three dimensions and below, you can always algorithmically determine whether two manifolds are the same shape. In four dimensions, you cannot — this is a consequence of the undecidability of the word problem for groups, proved by Markov in 1958.

Since a theory of everything must include 4-dimensional physics (we live in a 4-dimensional spacetime, after all), it must grapple with this undecidability. We prove that for each level of the arithmetical hierarchy — a classification of mathematical undecidability going back to Kleene and Post — there exists a dimension of physics that requires exactly that level of oracle information.

In other words, a theory of everything is not just hard to compute. It is *infinitely non-computable*: no matter how powerful an oracle you have, there are always aspects of the theory that lie beyond it.

## The Dimension Gap

We also prove a "no-go" theorem that explains a longstanding puzzle: why can't we derive gravity from purely topological methods?

The answer is structural. Gravity requires nontrivial 2-categorical data (the curvature of spacetime involves 2-dimensional surface effects). But topological methods operate at a lower categorical level. We prove that no structure with stability level 1 can simultaneously support both topological field theories and gravity. There is a dimensional gap that cannot be bridged.

This gap explains why decades of attempts to build quantum gravity from topological quantum field theory alone have failed. The categorical structure simply doesn't have enough room.

## Shadows of a Single Object

Perhaps the most beautiful implication of this work is the shadow picture. TQFTs, conformal field theories, string theories, and gravity are not separate theories. They are *truncations* — shadows — of a single object living in a higher category.

A TQFT sees only level 0 (objects/particles). A CFT or string theory sees levels 0 and 1 (objects and morphisms/worldsheets). Gravity sees levels 0, 1, and 2 (objects, morphisms, and 2-morphisms/curvature).

Each shadow loses information compared to the full theory, but each captures genuine aspects of the underlying reality. The theory of everything is the object casting all these shadows simultaneously.

## What It Means

These results suggest a striking picture of the mathematical universe. The theory of everything:

1. **Has a specific shape**: a (2,∞)-category with duals
2. **Is determined by a single datum**: a fully dualizable object (the cobordism hypothesis)
3. **Unifies all physics**: TQFTs, CFTs, string theories, and gravity are shadows
4. **Is fundamentally non-computable**: it contains oracle information at every level

The non-computability result is perhaps the most philosophically provocative. It means that even with a complete theory of everything in hand, we would still need experiments. The universe is not just a computation — it is a computation that requires oracles, and those oracles are the laws of physics themselves.

This is not a failure of mathematics. It is mathematics telling us something deep about the nature of physical reality: the universe is richer than any algorithm, and understanding it will always require both theory and experiment, forever intertwined.

The shape of everything, it turns out, is exactly two layers deep — and infinitely wide.
