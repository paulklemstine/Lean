# The Hidden Geometry of Scoring Functions

## How a simple mathematical structure connects genetics, coding theory, and statistical physics

Imagine you're designing a new drug. Your molecule has five positions where you can attach different chemical groups — say, 10 options at each position. That's 100,000 possible molecules. You want the ones that bind to your target protein with a specific affinity score.

Now imagine that the score at each position contributes independently to the total — the binding energy is the sum of per-position contributions. This is called an *additive scoring function*, and it appears everywhere: in error-correcting codes for telecommunications, in the fitness landscapes of evolutionary biology, in the energy functions of statistical physics, and in the preference models of machine learning.

The question is deceptively simple: among all configurations with the same total score, which ones are "close" to each other? Where close means: you can transform one into the other by changing just one position at a time, staying at the same score throughout.

This is the question of *fiber graph connectivity*, and its answer reveals a beautiful mathematical structure hiding in plain sight.

---

## The Fiber Graph

Picture a vast space of configurations — every possible assignment of values to positions. Now slice this space horizontally at each score level. Each slice is a *fiber*: the set of all configurations that achieve exactly that score.

Within each fiber, draw a line between any two configurations that differ at exactly one position. The resulting network is the *fiber graph*. It captures the local structure of the score landscape: which configurations are one step away from each other within the same energy level (or fitness level, or code distance).

The fiber graph is not the same as the full configuration space. Two configurations might be neighbors in the full space (differing at one position) but live in different fibers. The fiber graph keeps only the "horizontal" connections.

## The Delta Algebra

The first surprise is algebraic. When you change a value at position *i* from *a* to *b*, the score changes by a quantity we call *δᵢ(a,b)* — the score delta. This delta satisfies three beautiful properties:

1. **Antisymmetry**: δᵢ(a,b) = −δᵢ(b,a). Undoing a change reverses its effect.
2. **Triangle identity**: δᵢ(a,b) + δᵢ(b,c) = δᵢ(a,c). Going from *a* to *c* via *b* gives the same total change as going directly.
3. **Conservation**: If two configurations have the same score, the sum of all their position-by-position deltas is exactly zero.

The conservation law is the most important. It says that any score-preserving transformation decomposes into local exchanges that *globally cancel*. The deltas at individual positions can be anything, but they must sum to zero. This is reminiscent of conservation laws in physics — energy, momentum, charge — where local changes are free but the global total is fixed.

## Bridge Duality: The Two-Position Theorem

Here's where things get genuinely surprising. Consider two configurations that have the same score but differ at exactly two positions — say, positions *i* and *j*. Can you get from one to the other in the fiber graph by changing one position at a time?

If you change position *i* first, you pass through an intermediate configuration. This intermediate has the "right" value at position *i* (matching the target) but the "wrong" value at position *j*. For this intermediate to have the correct score, the weight function at position *i* must assign the same weight to both the old and new values.

The *Bridge Duality Theorem* says: this intermediate exists through position *i* if and only if it exists through position *j*. The two bridges are logically equivalent. Either both positions offer a "free move" (the weights match), or neither does.

The proof is elegant. The conservation law for two differing positions gives: δᵢ + δⱼ = 0, so the deltas at *i* and *j* are negatives of each other. One is zero if and only if the other is zero.

This has a striking consequence: in the fiber graph, there are no "one-sided bottlenecks" between configurations that differ at exactly two positions. The graph is locally symmetric in a precise sense.

## Rigidity: When Weights Lock Configurations

What happens when the weight functions are *injective* — when different values at the same position always give different weights?

The *Position Separation Rigidity Theorem* gives a surprising answer: if two configurations have the same score and agree at every position except possibly one, they must be *identical*. You cannot change a single position without changing the score.

This means the fiber graph has no edges that correspond to isolated single-position swaps when the weights are injective. To move between distinct configurations in the same fiber, you must change at least two positions — and by bridge duality, you need at least three positions' worth of freedom to navigate through the fiber graph.

Combined with the bridge impossibility result — which shows that injective weights at two differing positions block all bridges through those positions — this reveals the deep rigidity of fibers under injective scoring.

## The Score Kernel: Algebraic Fingerprint of a Fiber

The *score kernel* is a new concept that captures the combinatorial degrees of freedom within a fiber. It consists of all "delta vectors" — one value per position — that sum to zero and are achievable by the weight functions.

Each element of the score kernel represents one possible pattern of local changes that preserves the global score. The kernel is closed under negation (every exchange can be reversed), and its structure determines the connectivity properties of the fiber graph.

Think of it as an algebraic fingerprint: two weight systems with isomorphic score kernels produce fiber graphs with the same qualitative structure, even if the actual weights are completely different.

## Uniform Weights and Symmetry

When all positions use the same weight function — a *uniform* weight system — the fiber graph gains an enormous symmetry. The score becomes invariant under any permutation of positions. Rearranging the values across positions doesn't change the total.

This symmetry is familiar: it's the reason that in error-correcting codes, the Hamming weight (number of 1s) determines the code properties regardless of *which* positions are 1. Uniform additive scoring is the mathematical common ancestor of Hamming weight, partition counting, and population genetics models where all loci contribute equally to fitness.

## Applications and Implications

The fiber graph framework applies broadly:

**Coding theory**: The fibers of the Hamming weight function are the *constant-weight codes*. The fiber graph is the Johnson graph, and its expansion properties determine the efficiency of random coding.

**Statistical physics**: The fibers of an energy function are the *energy shells*. Fiber graph connectivity determines whether Markov chain Monte Carlo methods can efficiently sample configurations at a fixed energy — a question central to computational physics.

**Evolutionary biology**: The fibers of a fitness function are the *neutral networks*. The connectivity of neutral networks determines how populations can explore genotype space without changing phenotype — the mathematical foundation of neutral evolution theory.

**Machine learning**: In scoring models where features contribute additively (linear models, wide neural networks at initialization), the fiber graph captures the geometry of the decision boundary.

## The Expansion Conjecture

The biggest open question is whether fiber graphs of generic additive scoring functions are *expanders* — whether every subset of configurations has many edges leaving it, relative to its size.

If true, this would mean that random walks on fibers mix rapidly, giving polynomial-time algorithms for sampling configurations at any target score. The bridge duality theorem provides the first structural evidence: it rules out the simplest possible bottleneck, where a one-sided barrier could trap a random walk.

Computational experiments on small systems show expansion ratios consistent with the conjecture, but a general proof remains elusive. The answer likely depends on a delicate interplay between the weight functions' injectivity properties and the alphabet size.

## Looking Forward

The fiber graph framework reveals that additive scoring — one of the simplest structures in mathematics — conceals a rich geometric theory. The interplay between local changes (deltas) and global constraints (conservation) creates networks whose properties govern sampling, evolution, and communication.

The deepest question may be whether this theory extends beyond additive scoring. What happens when the score function has interactions between positions — when it's not a sum but a more complex function? The delta algebra breaks down, but the fiber graph persists. Understanding how connectivity degrades as we move from additive to interactive scoring could illuminate the boundary between tractable and intractable computation in combinatorial optimization.

Mathematics has a way of finding unity in diversity. The same fiber graph that governs error correction in your cell phone also governs the neutral evolution of proteins in your cells. Both are consequences of a single mathematical principle: when local changes must globally cancel, the resulting geometry has structure far richer than anyone expected.
