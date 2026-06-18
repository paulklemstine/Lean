# The Hidden Layers of Discrete Geometry

**How mathematicians discovered that repeating a simple operation reveals invisible structure in combinatorial landscapes**

---

When you look at a mountain range, you see peaks and valleys — the shape of the terrain. But a geologist sees more: the curvature of each ridge, how steeply the slopes fall away, whether the rock bends smoothly or fractures sharply. The curvature tells a deeper story than the height alone.

In 2025, a team of researchers asked an analogous question about a very different kind of landscape — not one made of rock and earth, but of numbers arranged on a lattice. What they found was a hidden hierarchy of geometric structure, invisible to standard tools, that connects fields as distant as tropical geometry, statistical physics, and combinatorial optimization. The key was an operation so simple it seems almost trivial: divide one value by its neighbor, then repeat.

## The Ratio Transform: A Mathematical Microscope

Imagine a function that assigns a positive number to every point on a grid. Think of it as an altitude map, but instead of a continuous surface, you have discrete values at each grid point. Mathematicians call such a function "log-concave" if, looking along any axis, the values never grow too fast — more precisely, if the square of each value is at least as large as the product of its two neighbors. It is the discrete cousin of concavity, the property that makes parabolas curve downward.

Log-concavity is powerful. It appears throughout mathematics, from the binomial coefficients (the numbers in Pascal's triangle) to the theory of matroids (abstract structures capturing the essence of linear independence). In 2020, Petter Brändén and June Huh proved that the coefficients of so-called Lorentzian polynomials are always log-concave — a result that helped earn Huh a Fields Medal.

But the new work goes further. Instead of just checking whether a function is log-concave, the researchers applied what they call the *ratio transform*. For each direction on the grid, you compute the ratio of each value to its neighbor: if your altitude at position *m* is 10 and at position *m* + 1 it is 8, the ratio is 0.8. You now have a new function — the ratio function. The question is: *is this new function also log-concave?*

If it is, you can apply the ratio transform again. And again. Each time, you peel away another layer, like an onion, revealing progressively finer geometric structure. The number of times you can repeat this process before log-concavity fails is what the researchers call the *directional depth* of the original function.

## A New Invariant Is Born

Depth zero means the function is not even log-concave. Depth one means it is log-concave, but its ratio transform is not. Depth five means you can peel away five layers and still find log-concavity at each level. And some functions — like the Gaussian bell curve discretized on a grid — have *infinite* depth: no matter how many times you apply the ratio transform, the result is always log-concave.

This number — the depth — turns out to be far more than a curiosity. The researchers proved three fundamental properties that elevate it from a definition to a genuine mathematical invariant:

**First, depth is multiplicative.** If you multiply two functions together, the depth of the product is at least as large as the minimum of their individual depths. This means the set of functions with depth at least *k* forms a natural algebraic structure (a multiplicative monoid), and these structures nest inside each other like Russian dolls: every function of depth 5 is also of depth 4, of depth 3, and so on.

**Second, depth connects to tropical geometry.** The negative logarithm of a depth-1 function is "supermodular" — a property that, in the tropical world, corresponds to convexity. Higher depth means this convexity persists through multiple layers of the ratio transform, creating what the researchers call a "tropical convexity tower." Each level of the tower is a new convex potential, derived from the previous one by the ratio transform.

**Third, depth detects exchange structure.** In the theory of matroids — abstract combinatorial structures that generalize the notion of independence — there is a fundamental "exchange axiom": if you have two independent sets and one has an element the other lacks, you can swap elements to produce new independent sets. The researchers showed that depth, combined with a support condition, implies a version of this exchange law for the tropicalized function. This connects the depth hierarchy directly to the theory of valuated matroids.

## Why It Matters: From Pascal's Triangle to Optimization

To understand why anyone should care about this, consider the problem of combinatorial optimization. You have a discrete set of options — say, different ways to assign tasks to workers, or different routes through a network — and you want to find the best one. The "landscape" of objective values over these options is exactly the kind of discrete function the depth filtration analyzes.

Standard convexity makes continuous optimization tractable: gradient descent works because the landscape has no misleading valleys. In the discrete world, the analogous role is played by *M-convexity*, a concept introduced by Kazuo Murota in the 1990s as part of his "discrete convex analysis" program. M-convex functions are the discrete functions for which greedy-type algorithms work correctly.

The depth filtration refines M-convexity. A function might satisfy the exchange axiom (depth ≥ 1) but fail at depth 2, meaning its ratio transforms do not preserve log-concavity. The researchers conjecture that for naturally arising combinatorial structures — matroids from graphs, Grassmannians, algebraic varieties — the depth is always either 1 or infinite, with no natural examples of intermediate depth. If true, this would reveal a sharp dichotomy in the combinatorial world: either a structure has the minimal amount of regularity, or it has an infinite amount.

## The Statistical Physics Connection

There is another way to read the depth filtration, one that connects to the physics of matter.

In statistical mechanics, the function *f*(*m*) represents the probability of a system being in state *m*. The quantity −log *f*(*m*) is the energy of that state. The ratio transform then computes the *chemical potential*: how much the energy changes when you add one particle at a particular site. In this language, depth measures how many times the response of the system to perturbations remains "well-behaved" — convex and predictable.

A system with infinite depth is one where not only is the energy landscape convex, but the response to perturbations is convex, and the response to perturbations of the response is convex, and so on to infinity. This is a remarkably strong form of thermodynamic stability.

The researchers proved that for Gaussian-type weight functions — which arise naturally in statistical mechanics as Boltzmann distributions for harmonic potentials — the depth is indeed infinite. For more exotic potentials with anharmonic terms, the depth can be finite, providing a quantitative measure of how far the system is from ideal thermodynamic behavior.

## Computational Detection

One of the most practical aspects of the new theory is that depth is computable. Given a function on a finite grid, you can determine its exact depth by a straightforward recursive algorithm: check log-concavity, compute the ratio transform, and repeat. The researchers implemented this algorithm and tested it on hundreds of examples from different families.

The computational results are striking. Gaussian and geometric functions have depth exceeding any tested bound (consistent with infinite depth). Uniform matroid valuations on small sets consistently show high depth. Graphical matroids — those coming from networks — show high depth for trees and cycles, with the first hints of finite depth appearing only for complex graph topologies with overlapping circuits.

Most provocatively, the researchers could not find a single "natural" example with depth exactly 2 or 3. Every naturally arising function they tested had either depth 0 or 1 (failing or barely passing log-concavity) or appeared to have infinite depth. This supports their Depth Dichotomy Conjecture, though a proof — or a counterexample — remains to be found.

## A New Language for an Old Subject

The theory of matroids is nearly a century old, tracing back to Hassler Whitney's 1935 paper. Valuated matroids — matroids equipped with a "valuation" that measures the quality of each basis — were introduced by Andreas Dress and Walter Wenzel in the 1990s and have become central to tropical geometry.

The depth filtration adds a new dimension to this theory. Where previous invariants measured properties of a single function (is it log-concave? does it satisfy the exchange axiom?), depth measures an entire *hierarchy* of properties simultaneously. It is as if, instead of asking "is this surface curved?", you ask "how deeply is this surface curved?" — and find that the answer, for many natural surfaces, is "infinitely."

This opens several avenues for future research. Can depth be computed efficiently for large-scale matroids? Does infinite depth always correspond to an underlying algebraic structure (as it does for Lorentzian polynomials)? Can the depth filtration be extended to continuous domains, providing a new notion of higher-order convexity for functions on vector spaces?

Perhaps most intriguingly, can the depth hierarchy be used as a practical tool in optimization? If a function has high depth, it should be "easier" to optimize, in some precise sense, than one with low depth. Making this intuition rigorous could have implications for algorithm design in combinatorial optimization, machine learning, and statistical inference.

The answers to these questions remain open. But the depth filtration has already revealed something beautiful: that hidden inside the simplest operation — dividing a function by its neighbor — lies an infinite hierarchy of geometric structure, waiting to be discovered.

---

*The research described here builds on foundational work by Brändén and Huh on Lorentzian polynomials, Murota's discrete convex analysis, and the theory of tropical geometry. The computational results were generated by algorithms that exhaustively test log-concavity at each depth level, providing rigorous lower bounds on the depth invariant.*
