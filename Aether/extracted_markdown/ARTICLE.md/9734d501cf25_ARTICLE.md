# The Hidden Geometry of Counting: How Mathematicians Discovered Depth in Discrete Worlds

## A Microscope for the Invisible

Imagine you are sorting a deck of cards. Each time you swap two cards, you move closer to the sorted order — or so you hope. But how do you know the swaps are actually making progress? How do you know you won't get stuck in a loop, endlessly shuffling without arriving?

This question — seemingly trivial for a deck of 52 cards — becomes profound when the "cards" are the building blocks of networks, molecules, or economic systems. In the mathematical framework called *matroid theory*, developed in the 1930s by Hassler Whitney, the act of swapping elements follows strict combinatorial rules. These rules guarantee that certain optimization problems have clean solutions: you can always reach the best arrangement by a sequence of improving swaps.

But here's the catch: Whitney's rules only tell you that progress is *possible*. They say nothing about how *fast* you converge, how *stable* the optimum is, or how *deeply* the structure of the problem supports your descent. For decades, mathematicians have treated these as first-order questions — you either have the exchange property or you don't.

Now, a new mathematical theory reveals that there is an entire hidden hierarchy beneath the surface. Like geological strata that record eons of Earth's history in layers of rock, this hierarchy — called the *directional depth filtration* — measures how many layers of geometric regularity a combinatorial structure possesses. And the deeper the layers go, the more powerful the guarantees.

## The Ratio Transform: A Mathematical Microscope

The key idea begins with a deceptively simple operation. Take a function that assigns a positive real number to every way of distributing objects into bins — think of it as a weight function on configurations. Now ask: if I add one more object to bin number 3, by what factor does the weight change?

This factor is called the *ratio transform*, and it is the mathematical equivalent of zooming in with a microscope. The original function tells you the overall landscape of weights. The ratio transform tells you how the landscape *responds* to local perturbations. It's the difference between knowing the altitude of every point on a mountain and knowing the slope at every point.

Here's where it gets interesting. You can apply the ratio transform again to the result. Now you're looking at how the *slopes* change — a kind of second derivative, measuring the *curvature* of the landscape. And you can keep going: third, fourth, fifth derivatives, each one revealing finer structure that was invisible at the previous level.

The breakthrough is that at each level, you can ask a specific mathematical question: is this iterated transform still *log-concave*? Log-concavity is a powerful regularity condition — it means, roughly, that the function has no unexpected bumps or valleys. It's the discrete analog of a smooth, gently curving hill.

A function that stays log-concave through one level of the ratio transform has *depth 1*. If it survives two levels, depth 2. And so on. The *directional depth* is the number of layers of log-concavity that the function sustains under repeated microscopic examination.

## Why Depth Matters: The Multiplication Miracle

The first surprise is algebraic. If you multiply two functions together — pointwise, configuration by configuration — the depth of the product is *at least* as large as the minimum depth of the two factors. In mathematical language, the classes of functions with depth ≥ k form multiplicative monoids.

This is not obvious. Multiplying two functions can create complicated interference patterns. But the ratio transform has a beautiful property: the ratio transform of a product is the product of the ratio transforms. This means the depth hierarchy is preserved under the most natural algebraic operation on weight functions.

Why does this matter in practice? Because in combinatorial optimization, tropical geometry, and statistical mechanics, the functions that arise naturally are often products of simpler pieces. If each piece has high depth, the whole system inherits that depth — and with it, all the geometric guarantees that depth provides.

## The Tropical Connection: Where Algebra Meets Geometry

The second discovery connects depth to an entirely different world: *tropical geometry*.

Tropical geometry replaces ordinary addition with the "min" operation and ordinary multiplication with addition. It sounds bizarre, but this algebraic sleight of hand turns complicated polynomial equations into piecewise-linear structures — the geometry of folded paper rather than smooth curves. Over the past two decades, tropical geometry has revolutionized areas from algebraic geometry to phylogenetics.

The connection to depth comes through the logarithm. If you take a positive weight function and apply the negative logarithm, you get what physicists call an *energy landscape* and what tropical geometers call a *tropical potential*. The theorem is this: if the original function has depth at least 1, then the tropical potential is *supermodular* — a strong form of convexity adapted to lattice points.

But here's the deeper result. If the function has depth at least 2, then every one of its ratio transforms *also* produces a supermodular tropical potential. Depth 3 means the ratio transforms of the ratio transforms are supermodular. And so on. Each additional layer of depth gives you another layer of tropical convexity — a tower of increasingly refined geometric regularity.

This is the seed of what might become *higher tropical curvature theory*: a systematic way to measure how deeply a combinatorial structure supports convexity, going far beyond the first-order checks that current methods provide.

## Valuated Matroids: The Mathematical Arena

The natural home for this theory is the world of *valuated matroids*, introduced by Andreas Dress and Walter Wenzel in 1992. A valuated matroid is like an ordinary matroid (a structure capturing the abstract essence of linear independence) equipped with a real-valued "cost" on each basis. The costs must satisfy a tropical exchange inequality — a quantitative version of the basis exchange axiom that governs all matroids.

The depth filtration turns out to detect structure in valuated matroids that is invisible to the standard exchange axiom alone. The exchange axiom is a single inequality involving pairs of bases. The depth filtration produces a cascade of increasingly refined inequalities, each one corresponding to a deeper layer of tropical convexity in the valuation.

A function with depth 1 and exchange-closed support satisfies a weak form of the M-convexity axiom from Kazuo Murota's *discrete convex analysis* — a powerful framework for optimization over discrete structures. This is the first rigorous evidence that the depth hierarchy refines M-convexity, one of the most important concepts in combinatorial optimization.

## The Strictness Surprise

Is this hierarchy just an artifact? Could it be that every reasonable function has infinite depth, making the whole classification trivial?

No. An explicit mathematical construction demonstrates a function that has depth exactly 1 — it is log-concave, but its ratio transform is not. The witness is remarkably simple: a function on a single variable taking the values 1, 3, 2, 1. It's log-concave (the middle values are large enough), but its ratio sequence 3, 2/3, 1/2 fails log-concavity because 3 × 1/2 > (2/3)².

This tiny example proves that the hierarchy is strict: there really is a mathematical distinction between depth 1 and depth 2. The depth invariant carries genuine information.

## Energy Landscapes and the Physics Connection

In statistical mechanics, the function f assigns a *Boltzmann weight* to each microstate of a physical system, and −log f is the *energy*. The ratio transform then computes the *chemical potential* — the free-energy cost of adding one more particle to a particular site. Supermodularity of the chemical potential means that the system has a convex response function: adding particles to one site makes it harder to add particles to other sites.

When the weight function has depth 2 or more, not only is the energy landscape tropically convex, but the chemical potentials themselves are convex — a property that guarantees stability of the equilibrium and fast convergence of sampling algorithms. Depth becomes a measure of how *deeply stable* a statistical-mechanical system is.

This interpretation opens a bridge between combinatorial optimization, tropical geometry, and the physics of complex systems. The same mathematical invariant — depth — captures structure in all three domains.

## The Dichotomy Conjecture

Computational experiments on naturally arising valuated matroids — from graphs, from uniform matroids, from Grassmannian-like constructions — reveal a striking pattern. Every natural example tested has either depth 1 or appears to have infinite depth. No natural example has been found with depth exactly 2, 3, or any other finite value above 1.

This leads to a bold conjecture: *for naturally arising valuated matroids, the depth is either 1 or infinite*. There is no intermediate regime. If true, this would mean that the depth filtration cleanly separates combinatorial structures into two classes: those with basic regularity and those with the full power of Lorentzian geometry — a rich algebraic-geometric structure recently elucidated by Petter Brändén and June Huh in their celebrated work on Lorentzian polynomials.

The conjecture is falsifiable: a single explicit valuated matroid with depth exactly 2 would disprove it. So far, none has been found.

## A New Language for Old Problems

What makes the depth filtration more than a curiosity is its simultaneous interpretability in multiple mathematical languages:

- In **combinatorics**, it measures how many layers of log-concavity a discrete function sustains.
- In **tropical geometry**, it measures the persistence length of tropical convexity under iterated differentiation.
- In **discrete optimization**, it refines the M-convexity classification that governs efficient algorithms.
- In **statistical physics**, it measures the depth of stability of an energy landscape.
- In **algebraic geometry**, it echoes the Hodge-Riemann positivity conditions that underlie the most powerful results in the field.

This multi-domain interpretability is rare in mathematics. It suggests that directional depth captures something fundamental about discrete structures — something that previous invariants saw only in shadow.

## Looking Forward

The theory is young, and many questions remain open. Can depth be computed efficiently for large systems? Does the dichotomy conjecture hold for all naturally arising matroids, or are there exotic counterexamples lurking in higher dimensions? Can the depth filtration be extended to continuous settings, providing a bridge to classical differential geometry?

Most ambitiously: does infinite depth characterize precisely the class of Lorentzian polynomials? If so, the depth filtration would provide a new, elementary characterization of one of the most powerful objects in modern mathematics — defined not through algebraic geometry or Hodge theory, but through the simple, iterative operation of computing ratios and checking concavity.

The tools are simple. The operation is elementary. But the layers of structure they reveal run deep — deeper, perhaps, than anyone expected. In the landscape of mathematics, it seems, the most profound features are sometimes hiding just one ratio transform away.
