# The Mathematics of Almost Impossible Events

## When Zero Probability Doesn't Mean Impossible

Throw a dart at a dartboard. What's the probability it lands on any particular point? According to standard probability theory, the answer is exactly zero. Every single point on the board has probability zero, yet the dart *must* land somewhere. Mathematicians call this the "problem of measure zero" — it's one of the most philosophically troubling features of modern probability.

For nearly a century, mathematicians have lived with this paradox by distinguishing between "impossible" and "probability zero." But what if there were a number system where we could give every point a tiny, positive probability — not zero, but something smaller than any fraction you could name?

Such numbers exist. They're called *infinitesimals*, and a new mathematical framework shows how they can revolutionize our understanding of probability.

## Numbers Smaller Than Small

In the 1970s, the British mathematician John Horton Conway invented a vast number system called the *surreal numbers*. Conway's system contains all ordinary numbers — 1, π, one-third — but also numbers that are infinitely large and infinitely small. The number ε (epsilon) is positive, definitely not zero, yet smaller than 1/10, smaller than 1/1000, smaller than 1/googol. It's smaller than any positive fraction, period.

These aren't approximations or limits. In Conway's system, infinitesimals are precise, well-defined numbers with their own arithmetic. You can add them, multiply them, divide by them. The expression 1/ε is a perfectly good number — it's just infinitely large.

The question that launched this research: Can we build a coherent probability theory using these exotic numbers?

## The Impossibility Wall

To understand why this matters, consider a fundamental impossibility in standard probability. Suppose you want to assign the same positive probability p to every natural number: 1, 2, 3, 4, and so on. Each number gets probability p > 0. Pick any small positive number for p — say, p = 0.001. Then the first 1001 numbers alone would have total probability greater than 1, which is absurd (total probability can never exceed 1).

This argument works for *any* positive real number p, no matter how small. The conclusion is ironclad: in real-number probability, you cannot give every element of an infinite set the same positive probability.

But what if p is infinitesimal?

If p = ε, where ε is a positive infinitesimal, then 1000 × ε is still infinitesimal — still less than 1. In fact, n × ε < 1 for every ordinary natural number n. That's precisely what "infinitesimal" means. The impossibility argument collapses because there is no finite n for which n × ε exceeds 1.

## Building the Framework

The new theory formalizes this intuition with mathematical precision. The core structure is a *finitely additive probability measure* — a function that assigns a non-negative number to every event, with the whole space receiving probability 1, and disjoint events receiving probabilities that add up correctly.

The critical choice: instead of requiring this function to take values in the real numbers, we allow it to take values in any *linearly ordered field* — a number system with addition, multiplication, division, and a consistent notion of "less than." The surreal numbers are the ultimate example, but any non-Archimedean field works.

A field is called *Archimedean* if, for any positive number ε, you can always find a natural number n large enough that n × ε > 1. The real numbers are Archimedean. The surreal numbers are not. This single property — the Archimedean property — turns out to be the exact dividing line between probability theories that can and cannot assign positive mass to every point.

**The Impossibility Theorem**: In any Archimedean field, if you try to assign the same positive probability δ to every element of an infinite set, some finite collection of elements will have total probability exceeding 1. This is a mathematical impossibility — the framework breaks.

**The Characterization Theorem**: If a probability measure assigns the same probability ε to every element of an infinite set, then ε must be a positive infinitesimal — it must satisfy n × ε < 1 for every natural number n. This forces the ambient field to be non-Archimedean.

Together, these results establish a perfect duality: *uniform infinite point masses exist if and only if the number system contains infinitesimals*.

## Bayes' Theorem Unleashed

Perhaps the most striking consequence involves conditional probability. In standard probability, you cannot condition on an event with probability zero. If you ask "What's the probability of rain, given that this specific atom moved left?" the standard answer is: the question is meaningless, because the atom's position has probability zero.

In the infinitesimal framework, every event has positive probability, so conditional probability is always well-defined. The classic Bayes' theorem — the engine behind everything from spam filters to medical diagnostics — extends seamlessly:

P(A|B) × P(B) = P(B|A) × P(A)

This formula holds even when P(A) and P(B) are infinitesimal. The result is a probability theory where you can ask — and answer — conditional probability questions about *any* event, no matter how specific.

The law of total probability also generalizes: P(A) = P(A|B) × P(B) + P(A|Bᶜ) × P(Bᶜ), allowing complete probability decompositions even when both B and its complement have infinitesimal probability.

## Why It Matters

This isn't just mathematical aesthetics. The framework has implications across several fields:

**Philosophy of probability**: The distinction between "impossible" and "probability zero" has troubled philosophers since Kolmogorov's axiomatization in the 1930s. Infinitesimal probability dissolves this distinction: impossible events have probability 0, while merely "infinitely unlikely" events have infinitesimal probability.

**Bayesian reasoning**: Many Bayesian models involve conditioning on specific observations that have measure zero in continuous distributions. The infinitesimal framework provides a rigorous foundation for this practice, which has historically required workarounds like "regular conditional distributions" or "disintegration."

**Game theory**: In extensive-form games, players must sometimes reason about what they would do at information sets that are reached with probability zero. Infinitesimal probabilities give these hypothetical situations genuine probabilistic weight.

**Physics**: Quantum mechanics frequently involves path integrals over continuous spaces. While the mathematical foundation of path integrals remains notoriously shaky, infinitesimal probability offers a potential alternative to the measure-theoretic framework that has so far resisted complete formalization.

## The Shape of Future Mathematics

The results established here open several research directions. Can the framework support a full theory of integration — summing infinitesimal quantities to obtain finite results? Can infinitesimal conditional probability replace the technically demanding theory of regular conditional distributions? And perhaps most ambitiously: does the surreal number line, with its extraordinarily rich structure, support probability measures that capture phenomena invisible to real-valued probability?

Conway's surreal numbers were originally invented to analyze combinatorial games — mathematical abstractions of chess, Go, and their relatives. That a number system born from game theory should find application in probability theory is one of those unexpected connections that make mathematics feel less like human invention and more like discovery.

The dart lands somewhere on the board. In this new mathematics, every "somewhere" has its own small but genuine probability. Nothing is truly impossible — some things are just infinitely unlikely.

---

*This research establishes the first machine-verified formalization of non-Archimedean probability theory, with complete proofs of 15 theorems including Bayes' theorem for infinitesimal events, the impossibility of uniform measures in Archimedean fields, and the characterization of infinitesimal point masses.*
