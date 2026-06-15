# The Hidden Geometry of Sequences: How Mathematicians Found a New Way to Measure Curvature

*A simple operation on number sequences reveals deep connections between combinatorics, tropical geometry, and optimization theory*

---

In the early 2000s, two mathematicians named Petter Brändén and June Huh embarked on an unlikely collaboration that would eventually earn Huh the Fields Medal — mathematics' highest honor. Their work concerned a class of mathematical objects called *Lorentzian polynomials*, which they showed lurk beneath the surface of an astonishing range of mathematical structures. From the coefficients of polynomials to the internal geometry of crystal lattices, the same pattern kept appearing: a particular kind of "curvature" that, once you knew how to look for it, seemed to be everywhere.

Now, new research has extended their ideas in a surprising direction, introducing a measurement tool called *directional depth* that reveals hidden structure in sequences of numbers. The discovery connects three seemingly unrelated mathematical worlds — and suggests that a fundamental principle of mathematical smoothness may be more universal than anyone realized.

## The Art of Dividing

Consider a simple sequence of positive numbers: say, 1, 2, 4, 8, 16. Each term is double the previous one. Now perform what mathematicians call the *ratio transform*: divide each term by the one before it. You get 2, 2, 2, 2 — a perfectly constant sequence.

That constancy is remarkable. Most sequences, when you compute their successive ratios, produce something messy. But sequences with nice geometric properties — sequences that arise naturally in probability, combinatorics, and physics — tend to produce ratio sequences that are well-behaved.

The key insight of directional depth theory is to ask: what happens if you apply the ratio transform *again*? And again? How many times can you iterate this operation before the resulting sequence loses its mathematical "niceness"?

For a geometric sequence like 1, 2, 4, 8, the answer is: forever. The ratio transform produces a constant, and a constant stays constant under further transformations. But for the binomial coefficients — 1, 10, 45, 120, 210, 252, 210, 120, 45, 10, 1 — the answer is more nuanced. These numbers, which count the ways to choose subsets, are beautifully smooth in a precise mathematical sense, but their iterated ratio transforms eventually lose that smoothness.

The *directional depth* is precisely this count: the number of times you can iterate the ratio transform while preserving a property called log-concavity.

## The Log-Concavity Revolution

To understand why this matters, you need to know about log-concavity — one of the most important structural properties in modern mathematics.

A sequence is log-concave if each middle term, when squared, is at least as large as the product of its neighbors. The binomial coefficients satisfy this: C(10,5)² = 63,504 ≥ C(10,4) × C(10,6) = 44,100. This looks like a dry algebraic condition, but its consequences are profound.

Log-concavity implies that a sequence has a single peak — it rises to a maximum and then falls, never bouncing back up. This means you can efficiently find the largest term using simple algorithms, without having to examine every entry. In probability theory, log-concave distributions (which include the familiar normal distribution) can be sampled efficiently, estimated from data, and composed without losing their nice properties.

The Brändén-Huh revolution showed that log-concavity is far more common than anyone expected. Sequences that arise from counting faces of geometric objects, from evaluating graph polynomials, from measuring intersections in algebraic geometry — nearly all of them turn out to be log-concave. A century-old web of conjectures, from Rota's conjecture about chromatic polynomials to Mason's conjecture about independent sets, fell like dominoes once the right conceptual framework was found.

## Going Deeper

Directional depth theory takes this a step further by asking: is there structure *beyond* log-concavity? And the answer is yes.

When you apply the ratio transform to a log-concave sequence, you get a new sequence that records how the growth rate changes. If this ratio sequence is itself log-concave, the original sequence has depth at least 1. If the ratio-of-ratios is log-concave, the depth is at least 2. And so on.

This creates a *filtration* — a nested sequence of sets:

> All positive sequences ⊃ Log-concave sequences ⊃ Depth ≥ 1 ⊃ Depth ≥ 2 ⊃ ⋯

Each level captures a stricter notion of mathematical regularity. At the bottom sits the vast ocean of arbitrary positive sequences. At the top, at infinite depth, sit the perfectly smooth sequences — the geometric progressions and their relatives.

The filtration is not just a classification scheme. It has real mathematical teeth. The new research proves that:

- **Products preserve depth**: If two sequences each have depth k, their pointwise product also has depth k. This mirrors how Lorentzian polynomials are closed under multiplication.

- **Depth implies exchange properties**: Any sequence with positive depth satisfies an "exchange inequality" that is the hallmark of matroid theory — the abstract combinatorial framework behind efficient optimization.

- **Depth bridges to tropical geometry**: The depth filtration, viewed through logarithms, becomes a statement about concavity in the tropical semiring — the exotic algebra where addition replaces multiplication and minimum replaces addition.

## Three Worlds, One Invariant

Perhaps the most striking aspect of directional depth is how it unifies three different mathematical perspectives.

In the *multiplicative world* of log-concavity, depth measures iterated curvature. Each application of the ratio transform is like taking a discrete derivative of curvature, and depth counts how many derivatives preserve the curvature sign.

In the *tropical world*, the same condition becomes a statement about piecewise-linear functions. The logarithm converts multiplication to addition, and log-concavity becomes concavity. Depth in this world measures how many times you can differentiate a concave piecewise-linear function and stay concave — a tropical analog of classical smoothness.

In the *combinatorial world* of matroid theory, depth connects to the exchange axiom that makes greedy algorithms work. The exchange inequality — a(i)·a(j+1) ≤ a(i+1)·a(j) for all i ≤ j — is precisely the condition that guarantees a greedy selection strategy finds optimal solutions. Log-concavity implies this inequality, and depth measures how robust the exchange property is under perturbation.

This three-way correspondence is not a coincidence. It reflects a deep structural principle: the most "natural" sequences in mathematics — those that arise from counting, from geometry, from physics — tend to have multiple independent notions of regularity simultaneously. Directional depth captures this multi-faceted regularity in a single number.

## A Conjecture and Its Refutation

Science advances not just through discoveries but through the disciplined process of conjecture and refutation. The new research proposed a bold conjecture: that if you slightly perturb a geometric sequence — adding a tiny random noise to each term — the resulting sequence should still have high depth, with the depth growing logarithmically in the inverse of the noise level.

Computational experiments quickly falsified this conjecture in its strongest form. Even tiny perturbations of a geometric sequence can break log-concavity, dropping the depth to zero. This is because log-concavity is, in a sense, a *fragile* property — it requires a global consistency condition that random noise easily violates.

But the failure is instructive. It reveals that the sequences with high depth are not merely "close to geometric" in any simple metric sense. They occupy a more subtle geometric locus in the space of sequences, one that demands structural coherence at every scale. Understanding the precise geometry of this locus is one of the most promising open questions in the theory.

## From Abstract to Applied

While the theory is young, its applications are already taking shape. The exchange property derived from log-concavity provides certifiable guarantees for greedy algorithms in combinatorial optimization. The depth filtration offers a new tool for classifying probability distributions — going beyond the simple question "is it log-concave?" to the richer question "how deeply log-concave is it?"

In signal processing, depth provides a measure of "harmonic regularity" that distinguishes clean signals from noisy ones. A signal whose amplitude sequence has high depth is, in a precise sense, more regular than one that is merely monotone or convex. This has potential applications in audio analysis, financial time series, and biological growth modeling.

The tropical bridge opens connections to optimization over valuated structures — the kind of mathematics that underlies modern algebraic approaches to machine learning and neural network architecture. When tropical geometry meets discrete curvature theory, the result is a framework for understanding how information flows through computational structures.

## The Road Ahead

Mathematics often progresses by finding the right level of abstraction — the concept that is neither too specific to be useful nor too general to have consequences. Directional depth appears to sit at exactly this sweet spot.

The theory is provably correct: its key theorems have been verified with complete mathematical rigor, leaving no room for hidden errors. The filtration is genuinely nested, products preserve depth, and the bridges to tropical geometry and matroid theory are exact correspondences, not mere analogies.

What remains is to understand the landscape of sequences with finite but positive depth. Are there natural families of sequences that achieve depth exactly 2 but not 3? What is the precise boundary between finite and infinite depth? And can the theory be extended from sequences to functions on higher-dimensional lattices, capturing the full power of Brändén and Huh's Lorentzian framework?

These questions point toward what might be called *higher discrete curvature theory* — a new subfield at the intersection of combinatorics, tropical geometry, and mathematical physics. If the patterns found so far are any guide, the answers will connect to phenomena far beyond the world of sequences, touching on the fundamental question of why mathematical structures that arise naturally tend to be so remarkably well-behaved.

The curvature is there. We are just learning how to measure it.
