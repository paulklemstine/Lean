# The Impossible Lottery: How Mathematicians Learned to Give Every Point a Chance

## A paradox hiding in plain sight

Imagine spinning a perfect roulette wheel — not one with 37 numbered slots, but a wheel so perfectly smooth that it can land on any point along its circumference. What is the probability that it lands on exactly the point marked "0.5"?

The answer, according to modern probability theory, is zero.

Not approximately zero. Not "very small." Exactly, precisely, mathematically zero.

This answer is, on its face, absurd. The wheel *can* land on 0.5. It's a perfectly legitimate outcome. Yet the mathematical framework that governs everything from weather prediction to quantum mechanics assigns it a probability of nothing. Every single point on the wheel is individually impossible, yet one of them must occur.

Mathematicians have lived with this paradox for over a century. They've developed elegant workarounds — measuring intervals instead of points, using sophisticated tools called sigma-algebras. These workarounds are powerful and practical. But they come at a cost: in the standard framework, individual outcomes in continuous spaces are fundamentally invisible. They have no weight. They don't count.

A new mathematical construction suggests there might be another way.

## The Kolmogorov barrier

To understand why this matters, we need to step back to 1933, when the Russian mathematician Andrey Kolmogorov laid down the axioms that define modern probability. His framework was revolutionary — it unified discrete probability (coin flips, dice rolls) with continuous probability (Gaussian distributions, Brownian motion) under a single roof.

But Kolmogorov's framework came with a strict rule: probability measures must be *countably additive*. This means that if you have a collection of non-overlapping events — even infinitely many of them — the probability of their union must equal the sum of their individual probabilities.

This rule creates an iron constraint. If infinitely many singletons each carried the same positive probability ε, then by adding up enough of them, you'd exceed any finite bound. A thousand singletons would have mass 1000ε. A million would have mass 1000000ε. Eventually you'd blow past the total mass of 1, which is supposed to represent certainty.

The mathematical conclusion is inescapable: in any countably additive probability space with infinitely many equally-weighted atoms, each atom must have mass zero. There is no wiggle room. This isn't a limitation of our techniques — it's a theorem.

Or is it?

## Breaking the barrier with infinitely small numbers

The key insight is deceptively simple: what if we used numbers smaller than any positive real number, but still greater than zero?

Such numbers — called *infinitesimals* — have a long and turbulent history. Leibniz and Newton used them freely when inventing calculus in the 17th century. Mathematicians later banished them as logically incoherent. Then, in the 1960s, Abraham Robinson proved that infinitesimals could be made rigorous through what he called *nonstandard analysis*.

More recently, John Conway's *surreal numbers* — originally invented to analyze combinatorial games — provided another framework containing infinitesimals alongside ordinary numbers. In surreal arithmetic, there exist quantities like ε that satisfy 0 < ε < 1/n for every positive integer n.

If we could do probability with such numbers, the Kolmogorov barrier would dissolve. Each point could carry a positive infinitesimal mass, and the sum over all points would be exactly 1 — not approximately, but exactly, in the extended number system.

But formalizing this vision rigorously is enormously difficult. Surreal-valued measure theory doesn't yet exist as a mature mathematical discipline. The gap between the dream and the reality is vast.

## Building the bridge, one grid at a time

The new construction takes a different, more concrete approach. Instead of leaping directly to infinitesimal-valued probability on continuous spaces, it builds a ladder of finite approximations — and proves that this ladder has remarkable structural properties.

The idea is this: take the interval from 0 to 1 and approximate it with a grid of equally spaced points. If you use 10 points, each carries mass 1/10. Use 100 points, each carries mass 1/100. Use a million points, each carries mass 1/1,000,000.

At each level, you have a perfectly valid probability space. Every point has positive mass. The total is exactly 1. There is nothing mysterious or paradoxical about any individual grid.

What *is* remarkable is what happens when you look at the whole sequence of grids together.

## The three pillars

The new theory establishes three fundamental properties of these grid probabilities:

**Exact affine expectation.** For any linear observable — any quantity that varies proportionally with position — the expected value on the discrete grid equals the continuum integral *exactly*. Not approximately. Not in the limit. Exactly, for every grid size. If you compute the average of the function f(x) = 3x + 2 on a grid of 5 points or 5 million points, you get the same answer: 7/2. This is precisely the value you'd get from classical calculus.

This is surprising. Discrete approximations usually introduce error. Here, for an important class of functions, the error is identically zero.

**Refinement invariance.** If you take a coarse grid and subdivide each cell into k equal parts, creating a finer grid, the expected value of any observable lifted from the coarse grid is perfectly preserved. No information is gained or lost. The probability is *coherent* under refinement.

This is the property that suggests something deeper is going on. Coherence under scale change is a hallmark of structures that survive the passage to a continuum limit. Physicists recognize it as a form of *renormalization group invariance* — the same property that governs phase transitions and quantum field theory.

**The shadow principle.** As the grid becomes infinitely fine, the discrete expectations converge to the classical continuum values. The grid probability "shadows" classical probability — it agrees with it on every observable that classical probability can see.

Together, these three properties paint a striking picture: the grid probabilities form a coherent, refinement-stable scaffold that reproduces classical probability as its "shadow" while maintaining the property that every individual point has positive mass.

## Why the impossible lottery stays impossible (classically)

The theory also proves, rigorously, why the Kolmogorov barrier exists. The impossibility theorem shows that no finitely additive real-valued function on the natural numbers can simultaneously assign every singleton the same positive mass and keep total mass bounded.

The proof is elegant in its simplicity. If every point has mass ε > 0, then the set {0, 1, 2, ..., N} has mass (N+1)ε by finite additivity. Choose N large enough that (N+1)ε > 1 — which is always possible because the real numbers are *Archimedean* (there are no infinitesimals). Contradiction.

This theorem draws a sharp line. On one side: classical, Archimedean probability, where equal positive atoms on an infinite set are provably impossible. On the other side: non-Archimedean probability, where the rules change because infinitesimal numbers exist.

The grid construction lives on the Archimedean side but points toward the non-Archimedean side. Each grid is finite and Archimedean. But the *sequence* of grids, viewed as a single mathematical object, behaves like a bridge between the two worlds.

## From games to rare events

The implications reach far beyond abstract measure theory.

**Decision theory.** In economics and game theory, some outcomes are "infinitely unlikely" but not impossible. A chess player who considers every possible response — no matter how foolish — reasons about events of infinitesimal probability. The current framework for this, called *trembling-hand perfection*, uses limits of sequences of mixed strategies. Non-Archimedean probability could provide a direct, single-model treatment where infinitesimal trembles are genuine probabilities.

**Rare-event modeling.** In risk analysis — nuclear reactor safety, asteroid impacts, financial black swans — events of extremely low probability carry enormous consequences. Classical probability can assign these events small but positive probabilities. But when the number of possible failure modes is vast, classical models must assign some of them probability exactly zero, losing the ability to reason about them individually. An infinitesimal framework treats each failure mode as genuinely possible.

**Epistemology.** Philosophers of science have long debated whether probability zero means impossibility. If you randomly select a real number between 0 and 1, every specific outcome has probability zero, but clearly some outcome must occur. Non-Archimedean probability resolves this by giving each outcome a positive (infinitesimal) probability, aligning the mathematics with the philosophical intuition.

## The road ahead

The current construction is a foundation, not a finished building. The grid probabilities are valued in ordinary rational numbers, not in surreal numbers or hyperreals. The bridge to a true infinitesimal-valued probability on the full continuum remains a conjecture — supported by strong structural evidence, but not yet proven.

The conjecture is precise: there exists a finitely additive probability valued in a non-Archimedean ordered field, defined on all subsets of the interval [0, 1], that assigns each point a positive infinitesimal mass and reproduces classical expectations for polynomial observables.

Testing this conjecture requires building new mathematical infrastructure — surreal-valued integration, non-Archimedean measure theory, and formal connections to Robinson's nonstandard analysis and Loeb's measure construction.

What the grid construction provides is a *proof of concept*: a rigorous demonstration that the key structural properties (exact expectation, refinement coherence, shadow convergence) are not merely plausible but provable. The finite models work. The question is whether they can be unified into a single infinite model.

## A new lens on an old paradox

Mathematics progresses by questioning its own foundations. The probability framework that Kolmogorov built in 1933 has been spectacularly successful. But its treatment of individual points in continuous spaces — assigning them probability zero — has always been a philosophical thorn.

The grid probability construction doesn't overthrow Kolmogorov. It suggests that his framework is one view of a richer landscape. Classical probability is the shadow cast by a higher-dimensional structure where every point matters, every outcome has weight, and the infinitely small is not the same as nothing.

In the impossible lottery, every ticket might win after all. You just need the right kind of numbers to see it.
