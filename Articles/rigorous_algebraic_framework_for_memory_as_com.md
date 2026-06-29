# The Algebra of Forgetting: How Mathematics Reveals the Hidden Structure of Memory

## Every act of remembering is an act of compression

When you remember yesterday's breakfast, you don't replay a perfect recording. You recall fragments — the taste of coffee, the morning light — while discarding an ocean of detail. Your memory system, like every information-processing system in nature, is a *compression engine*. It takes the vast stream of experience and reduces it to something manageable.

But here's the surprising thing: that process of compression isn't arbitrary. It follows precise mathematical laws. A new algebraic framework reveals that information loss has structure — deep, elegant structure that connects three seemingly unrelated branches of mathematics.

## The Bottleneck Principle

Imagine a pipeline carrying water through a sequence of pipes of different diameters. The total flow is limited by the narrowest pipe — the bottleneck. Information works the same way. When data passes through a chain of processing stages, the total information that survives can never exceed what passes through the tightest bottleneck.

This intuition has been known informally for decades. But the new framework makes it precise and algebraic. Define the *compression rank* of any transformation as the number of distinguishable outputs it can produce. A camera sensor that maps the continuous visual field to a million pixels has compression rank one million. A summary algorithm that reduces a document to one of a thousand categories has compression rank one thousand.

The **Image Monotonicity Theorem** states: when you compose two transformations, the compression rank of the combination can never exceed the compression rank of either component. Formally, if *f* maps inputs to intermediate states and *g* maps intermediate states to outputs, then:

> rank(g ∘ f) ≤ min(rank(f), rank(g))

Information, once lost, cannot be recovered. This is not just a platitude — it's a theorem with algebraic teeth.

## The Steady State

Consider a system that processes the same type of input over and over. A neural network trained on successive batches of data. A bureaucracy processing applications through the same workflow. A river carving a channel through stone.

What happens to information capacity as you iterate? The compression rank sequence — rank(f), rank(f²), rank(f³), ... — is guaranteed to be *non-increasing*. Each additional pass through the transformation can only lose more information, never gain it.

But something remarkable happens: this sequence must eventually *stabilize*. After some finite number of iterations N, further iteration makes no difference: rank(f^N) = rank(f^(N+1)) = rank(f^(N+2)) = .... The system reaches a steady state where the surviving information is exactly the information that can survive indefinitely.

This is the **Stabilization Theorem**, and it follows from a deep algebraic fact about finite structures. In any finite algebraic system (technically, a finite monoid), every element has a power that is *idempotent* — applying it twice gives the same result as applying it once. The idempotent power represents the "long-run behavior" of the transformation: the permanent memory that persists after all transient information has been washed away.

## The Tropical Connection

Here is where the story takes an unexpected turn into tropical geometry — a branch of mathematics where addition becomes maximization and multiplication becomes addition. It sounds like mathematical nonsense, but tropical mathematics has deep connections to optimization, phylogenetics, and algebraic geometry.

Define the *tropical capacity* of a transformation as the logarithm of its compression rank: v(f) = log(rank(f)). The bottleneck inequality becomes:

> v(g ∘ f) ≤ min(v(f), v(g))

This is precisely the *tropical triangle inequality* — the defining property of an ultrametric space. In an ultrametric space, every triangle is isosceles with the two equal sides at least as long as the third. It's the geometry of hierarchical clustering, of p-adic numbers, of evolutionary trees.

The implication is striking: the space of all memory systems, equipped with tropical capacity as a distance measure, forms an ultrametric space. Memory systems that lose similar amounts of information are "close" in this tropical metric, and the hierarchical structure of the metric reflects a hierarchical structure of information loss.

## The Kernel Lattice

Every compression creates a pattern of equivalences: inputs that produce the same output become "the same" from the system's perspective. These equivalence classes form what mathematicians call a *congruence* — a partition of the input space that respects the algebraic structure.

The **Information Ordering Theorem** reveals that these congruences form a lattice — a partially ordered structure where any two elements have a unique least upper bound and greatest lower bound. If one compression makes finer distinctions than another (preserving more information), its congruence is a refinement of the other's, and it necessarily has higher compression rank.

This lattice structure means that for any finite input space, there is a complete hierarchy of all possible ways to compress information, from the finest (identity, no compression) to the coarsest (constant function, total amnesia). Every real memory system occupies a specific position in this lattice, and its position determines exactly how much and what kind of information it retains.

## Cascade Products and the Data Processing Inequality

When two memory systems operate in parallel — processing the same input independently — their combined system is a *cascade product*. The state space of the combined system is the Cartesian product of the individual state spaces.

The **Cascade Product Rank Bound** states that the compression rank of the combined system is at most the product of the individual ranks:

> rank(M₁ × M₂) ≤ rank(M₁) · rank(M₂)

In tropical capacity terms, this becomes additive: v(M₁ × M₂) ≤ v(M₁) + v(M₂). Information from parallel systems adds up, but never synergistically exceeds the sum of its parts. This is the algebraic shadow of the classical *data processing inequality* from information theory.

## Why This Matters

The framework connects three mathematical worlds:

1. **Semigroup theory** provides the algebraic backbone — the idempotent stabilization theorem, the structure theory of finite monoids, the Krohn-Rhodes decomposition that breaks any finite state machine into irreducible components.

2. **Tropical geometry** provides the metric structure — the capacity valuation, the ultrametric inequality, the connection to optimization and phylogenetics.

3. **Lattice theory** provides the ordering structure — the kernel congruence lattice, the information ordering, the hierarchy of compressions.

Each perspective illuminates aspects invisible to the others. The semigroup view explains *why* memory stabilizes (idempotent powers). The tropical view measures *how much* information survives (capacity valuation). The lattice view describes *what kind* of information is retained (congruence classes).

This synthesis suggests that information loss is not a nuisance to be minimized but a fundamental mathematical phenomenon with its own rich structure. Understanding that structure may lead to better algorithms for compression, more principled approaches to machine learning, and deeper insight into how biological memory systems achieve their remarkable efficiency.

The mathematics of forgetting, it turns out, is far more interesting than the mathematics of remembering.

---

*The algebraic framework for memory compression connects semigroup theory, tropical geometry, and lattice theory to reveal the hidden structure of information loss. All core results have been established as rigorous mathematical theorems.*
