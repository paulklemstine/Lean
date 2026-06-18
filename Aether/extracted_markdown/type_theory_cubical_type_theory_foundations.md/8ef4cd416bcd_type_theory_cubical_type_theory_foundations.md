# When Paths Become Proofs: A New Mathematics of Identity

*How a radical rethinking of what "equals" means is connecting geometry, physics, and logic in ways nobody expected*

---

What does it mean for two things to be the same? The question sounds almost childishly simple. Two plus two equals four. A circle is a circle. Your reflection in a mirror is you — sort of.

But mathematicians have spent the better part of a century wrestling with this question, and their answers have upended entire fields. The latest chapter in this story involves a seemingly bizarre idea: that equality itself has *shape*. That the statement "A equals B" doesn't merely record a fact — it traces a *path* through mathematical space, and different paths carry different information about *how* and *why* two things are identical.

This idea, which goes by the technical name of *cubical type theory*, has just taken a significant leap forward. Researchers have built a working computational framework that makes these "paths of identity" into concrete, checkable mathematical objects — and in doing so, they've uncovered unexpected connections between the foundations of mathematics, Einstein's theory of relativity, and the topology of shapes.

## The Trouble with Equals Signs

Every student learns that the equals sign is simple: it says two sides are the same. But consider this. You can prove that 2 + 3 = 5 by counting. You can also prove it by rearranging blocks, or by appealing to the definition of addition, or by using properties of the number line. Each proof is different. Each takes a different *route* to the same conclusion.

Classical mathematics says: "Who cares? Equal is equal." But starting in the 2000s, a group of mathematicians — inspired by the Fields Medal–winning work of Vladimir Voevodsky — argued that this attitude throws away valuable information. The different *proofs* of an equality are like different paths connecting two cities. The fact that a path exists tells you the cities are connected, but the paths themselves carry geometric information: one might go through mountains, another along the coast.

This is not a metaphor. In a precise mathematical sense, proofs of equality *are* paths. And the collection of all such paths between two objects forms a space — a *path space* — with its own geometry.

## Building an Interval from Scratch

The new framework starts with the simplest possible geometric object: an interval. Think of a line segment with two endpoints — call them 0 and 1. A "path" from A to B is then a function that starts at A when you plug in 0 and arrives at B when you plug in 1. In between, it traces a continuous route through whatever mathematical universe you're working in.

This sounds obvious, but the power lies in what you can *do* with these paths once you have them.

The first major theorem proved in the new framework is called *cubical function extensionality*. Stated informally: if two functions agree pointwise — meaning they give the same output for every input — then they are connected by a path in the space of all functions. This is not trivial. The space of functions is infinite-dimensional, and the theorem says that pointwise agreement is enough to guarantee a global geometric connection.

The proof is elegant. Given functions *f* and *g* and a path between *f(x)* and *g(x)* for every input *x*, you construct a function-space path by evaluating all the pointwise paths simultaneously. At interval parameter *t*, the path gives you the function *x ↦ (path from f(x) to g(x), evaluated at t)*. The endpoints work out exactly, and you have your global path.

## Equivalences Preserve Geometry

The second breakthrough involves *equivalences* — bijective correspondences between mathematical structures. When you have a perfect dictionary translating between type A and type B (every element of A maps to exactly one element of B, and vice versa), the classical view says A and B are "essentially the same." But the cubical view says something much stronger: the *path geometry* is preserved.

The theorem says that the mapping between A and B induces a bijection between their path spaces. If there's a path from *a* to *a'* in A, there's a corresponding path from their translations in B — and this correspondence is one-to-one and onto. No paths are created or destroyed by the equivalence.

This result is sometimes called a "shadow of univalence," referencing Voevodsky's famous Univalence Axiom, which asserts that equivalent structures are literally identical. The new framework doesn't go quite that far — it doesn't require modifying the logical foundations — but it captures the essential geometric content: equivalences don't just preserve cardinality; they preserve the full topology of identity.

## When Physics Meets Paths

Perhaps the most surprising application connects this abstract framework to Einstein's special relativity.

In special relativity, the *spacetime interval* between two events is a fundamental invariant. It measures a kind of "distance" through space and time that all observers agree on, no matter how fast they're moving. When you switch from one observer's frame to another's — a mathematical operation called a *Lorentz boost* — the coordinates of events change, but the interval stays the same.

This invariance is usually stated as an equation: the interval before the boost equals the interval after. But in the cubical framework, it becomes something more: a *path*. The equality between the two intervals is witnessed by a cubical path — a concrete mathematical object that encodes not just the fact of invariance, but the *reason* for it.

This might sound like a distinction without a difference, but it has real consequences. The path carries information about *how* the invariance arises, and it can be composed with other paths to derive further invariances. When you iterate a symmetry transformation — applying a Lorentz boost, then another, then another — the cubical framework automatically produces paths connecting all the intermediate results. The algebraic structure of symmetry becomes geometric.

## Higher Shapes from Simple Rules

The framework also tackles one of the deepest problems in modern mathematics: constructing *higher-dimensional shapes* from simple rules.

Consider a circle. You can describe it as having one point and one loop — a path that starts and ends at the same point. But in classical mathematics, you can't easily build types (mathematical structures) with this kind of circular connectivity. You need *higher inductive types*: types where the constructors can include not just points but paths between points.

True higher inductive types require modifications to the logical foundations that most systems don't support. But the new framework provides a workaround: *suspension approximations*. A suspension takes a set of points and glues them into a shape by adding a "north pole" and a "south pole" and connecting each point to both poles via a path.

The key theorem establishes a *universal property*: for any target structure with the right shape (a north, a south, and paths between them for each point of the original set), there is exactly one map from the suspension that respects the structure. This uniqueness theorem is mathematically powerful — it means the suspension is completely characterized by its gluing data, without needing to specify its internal structure.

## The Path Count Invariant

One of the most computationally testable results involves counting. When the interval and the type are both finite, the set of all paths between two elements is also finite. You can count them.

The theorem proves that this count is invariant under equivalences: if you translate from type A to type B, the number of paths between any pair of corresponding elements stays the same. This is a purely combinatorial consequence of the bijection theorem, but it yields concrete, checkable predictions.

For instance, consider a three-point interval {0, 1, 2} with endpoints 0 and 2, and a two-element type {a, b}. There are exactly 2 paths from *a* to *b*: the function can send the middle point 1 to either *a* or *b*. If you translate to any other two-element type via a bijection, you'll again get exactly 2 paths. This can be verified by exhaustive enumeration — and it always works.

## Interpolation as Identity

Another connection links the cubical framework to *analysis* — the mathematics of continuous change.

The affine interpolation between two real numbers *y₀* and *y₁* — the function *p(t) = (1-t)·y₀ + t·y₁* — is precisely a cubical path. At *t = 0*, you get *y₀*; at *t = 1*, you get *y₁*; in between, you get a smooth transition. The formal framework proves that this path always stays between its endpoints.

This means that every time an engineer designs a smooth transition — a crossfade between audio signals, a gradient blend in computer graphics, a control parameter ramp in robotics — they are, whether they know it or not, constructing a cubical path. The theory of identity and the practice of interpolation turn out to be the same thing.

## What Makes This Different

Previous approaches to higher-dimensional identity in mathematics required either working in specially designed logical systems (like Homotopy Type Theory) or axiomatically assuming principles that couldn't be computed with. The new framework works entirely within a standard mathematical environment. No new axioms are needed. Every theorem is mechanically verified. Every construction computes.

This is possible because the framework is deliberately modest in its ambitions. It doesn't claim to implement the full Univalence Axiom or genuine higher inductive types. Instead, it builds *shadows* and *approximations* that capture the essential mathematical content while remaining computationally tractable. The suspension approximation, for instance, doesn't have path constructors in the type-theoretic sense — but it has a universal property that gives it the same mathematical power.

## A Bridge Between Worlds

The deepest significance of this work may be as a *bridge*. It connects:

- **Geometry and Logic**: Paths are proofs; topology is reasoning.
- **Physics and Foundations**: Symmetry invariance is a special case of identity.
- **Analysis and Algebra**: Continuous interpolation and discrete equivalence are both instances of the same path structure.
- **Computation and Theory**: Everything is mechanically verified and concretely executable.

These connections suggest that the rigid boundaries between mathematical fields are artifacts of our notation, not features of the mathematics itself. When you have the right notion of identity — one that carries geometric information — seemingly unrelated results in different fields turn out to be instances of a single principle.

## What Comes Next

The framework opens several avenues for future exploration. Can the suspension construction be extended to produce genuine sphere-like objects with detectable nontrivial topology? Can the path-counting invariant be extended to infinite types using measure theory? Can the Lorentz invariance path be composed with other physical symmetries to produce a path-theoretic account of the full Poincaré group?

Perhaps most ambitiously: can this framework serve as the foundation for a new kind of mathematics where geometric structure is built into the very notion of identity — not as an axiom to be assumed, but as a consequence of how mathematical objects are constructed?

The equals sign, it turns out, has been hiding a universe inside it. We are only beginning to explore what's there.
