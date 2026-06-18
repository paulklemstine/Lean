# The Probability of the Impossible: How Mathematicians Are Rewriting the Rules of Chance

*When mathematicians discovered that some events can be more impossible than others, they had to invent a whole new kind of number to keep track.*

---

In the summer of 1654, Blaise Pascal and Pierre de Fermat exchanged a series of letters that would birth probability theory. They were solving a gambling problem: how to fairly divide stakes in an interrupted dice game. Their solution — assigning numbers between 0 and 1 to represent the likelihood of events — has served mathematics and science for nearly four centuries. But this elegant framework has a dirty secret: it lies about impossible things.

Consider a dartboard. You throw a dart at a circular target. What's the probability it lands on any specific point? The standard answer is zero — exactly zero. Every single point on the board has probability zero. And yet the dart *must* land somewhere. We have the strange situation where an event that is guaranteed to happen (the dart lands *somewhere*) is composed entirely of events that can't happen (the dart lands on *this* specific point). Mathematicians call this the "problem of measure zero" and have learned to live with it, the way people learn to live with a leaky roof.

But what if we fixed the roof?

## An Infinitely Thin Slice of Possibility

The core issue is that ordinary numbers aren't fine-grained enough to describe probabilities on continuous spaces. If you spread probability uniformly across infinitely many points, each point's share shrinks to zero — not to something very small, but to literally nothing. This creates genuine problems. In Bayesian statistics, you sometimes want to ask: "Given that this specific data point was observed, how likely is my hypothesis?" If the probability of observing that exact data point is zero, the question becomes a 0/0 division — mathematically meaningless.

The fix comes from an unexpected direction: surreal numbers, invented by the brilliant combinatorial mathematician John Horton Conway in the 1970s. Conway was studying games — not gambling games, but abstract two-player mathematical games. He discovered that the theory of games naturally produces a number system far richer than the real numbers we're used to. This system includes *infinitesimal* numbers — positive quantities that are smaller than any positive fraction, yet still definitively not zero.

Think of it this way: the number ε (epsilon, as mathematicians conventionally name it) is positive. It's definitely bigger than zero. But it's smaller than 1/2, smaller than 1/100, smaller than 1/1,000,000. It's smaller than one divided by any ordinary number you can name. It exists in the gaps between zero and everything else.

## Building Probability on Strange Ground

A team of researchers has now demonstrated that these exotic numbers can serve as the foundation for a new kind of probability theory — one that solves the problem of measure zero while preserving everything we love about classical probability.

The key construction is what they call an *infinitesimal probability space*. Like classical probability, it assigns a number to every event representing how likely that event is. Unlike classical probability, it does so using values from a non-Archimedean ordered field — a number system that contains infinitesimals. The axioms are clean: the probability of nothing happening is 0, the probability of something happening is 1, and if two events can't both happen, their individual probabilities add up to the probability of either happening. These are exactly the same axioms Kolmogorov laid down in 1933. The only change is the number system.

But what a change it is. With infinitesimal probabilities available, you can assign a positive — though infinitely small — probability to each point on the dartboard. Each point gets probability ε, and the "sum" of all these infinitesimals is exactly 1. No event is truly impossible unless it genuinely cannot occur. The dart analogy becomes honest: every point *is* possible, and the mathematics finally reflects that.

## Surprising Consequences

The theory produces several results that would startle a classical probabilist.

**Events can be "more impossible" than others.** In classical probability, all measure-zero events look the same — they all have probability zero. In the infinitesimal theory, a single point might have probability ε, while a pair of points has probability 2ε, and a specific curve through the space has probability ε^(1/2). These are all "infinitely unlikely" by classical standards, but infinitesimal probability can distinguish between them, creating a rich hierarchy of improbability.

**Conditioning on anything is legal.** The most practically important consequence is that Bayes' theorem — the cornerstone of modern statistics and machine learning — works everywhere. In the infinitesimal framework, P(A|B) = P(A∩B)/P(B) is well-defined as long as B is possible (P(B) > 0), which it always is in a regular probability space. No more hand-waving about "conditional density" or "limiting ratios." The formula just works.

**Classical probability is a shadow.** The researchers proved that standard probability theory is recovered by taking the "standard part" of infinitesimal probabilities — essentially rounding every infinitesimal to zero. Classical probability isn't wrong; it's coarse. It's the low-resolution version of a sharper theory.

## The Impossibility Theorem

Perhaps the most illuminating result is negative: the researchers proved that this construction is genuinely impossible using ordinary real numbers. In any number system satisfying the Archimedean property — the property that says if you add a positive number to itself enough times, you'll eventually exceed any target — you cannot assign equal positive weight to infinitely many elements while keeping the total finite. This is why we need infinitesimals: not as a convenience, but as a necessity.

The proof is elegant. If each element gets weight c > 0, then by the Archimedean property, there exists some N such that N × c > 1. But then the first N elements alone already exceed the total probability budget of 1. The only escape is a number system where "smaller than every 1/n but still positive" is a coherent concept.

## Products and Independence

The theory also handles the fundamental concept of independence — the idea that knowing one event doesn't help you predict another. The researchers constructed product probability spaces: given two independent infinitesimal probability spaces, you can combine them into a joint space where the probability of two independent events is the product of their individual probabilities. Even when each factor probability is infinitesimal, the product space retains all the right properties: normalization to 1, positivity of every singleton, and finite additivity.

This is not merely a technical exercise. Product measures are the backbone of statistics. Every time a data scientist assumes their data points are "independent and identically distributed," they're implicitly using a product measure. Having this work in the infinitesimal setting means the new theory can support real statistical reasoning, not just abstract measure theory.

## What Comes Next

The researchers point to several open frontiers. Can the theory be extended from finite additivity to a form of "surreal σ-additivity" that handles countable collections? Can it be connected to the existing framework of nonstandard analysis, where Abraham Robinson showed in the 1960s that infinitesimals could be made rigorous? And perhaps most tantalizingly: can infinitesimal probabilities illuminate problems in quantum mechanics, where the interpretation of probability has been debated since the field's founding?

There is also a striking connection to game theory — perhaps unsurprising given that surreal numbers were born from games. In combinatorial game theory, positions have surreal-number values that measure who is winning and by how much. When those values are infinitesimal, they mean one player has a vanishingly thin advantage. The new probability theory might let us reason about games of chance where some outcomes are infinitesimally more likely than others — a territory that standard probability has never been able to map.

For now, what the team has demonstrated is this: probability theory is not finished. The axioms Pascal and Fermat would recognize are unchanged, but the universe of numbers those axioms can speak about has been vastly expanded. In that expanded universe, every possibility — no matter how remote — has a name.

---

*The mathematics of infinitesimal probability builds on John Horton Conway's surreal numbers (1976) and draws connections to Abraham Robinson's nonstandard analysis (1966), Bruno de Finetti's finitely additive probability (1937), and Andrey Kolmogorov's axiomatization of probability (1933).*
