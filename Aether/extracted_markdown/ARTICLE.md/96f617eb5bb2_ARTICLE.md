# The Probability of the Impossible: How Infinitesimals Unlock a New Mathematics of Chance

*What if every point on a number line could have its own tiny, non-zero probability — even when there are infinitely many of them?*

---

## The Paradox at the Heart of Probability

Flip a coin, and you know the odds: fifty-fifty. Roll a die, and each face has a one-in-six chance. But what happens when the possibilities become infinite?

Pick a random real number between 0 and 1. The probability of choosing exactly 0.5 is... zero. The probability of choosing exactly π/4 is zero. In fact, the probability of choosing *any specific number* is zero. And yet, you *must* choose some number. This is one of the deepest paradoxes in modern mathematics: in standard probability theory, almost every individual outcome is literally impossible, even though one of them must occur.

For nearly a century, mathematicians have simply accepted this. The conventional framework, built on the real number system, forces us to assign probability zero to individual points in a continuous space. It's not a bug — it's a feature of how real numbers work.

But what if it didn't have to be this way?

## The Archimedean Barrier

The root of the problem has a name: the **Archimedean property**. Named after the ancient Greek mathematician, it says something deceptively simple: given any positive number, no matter how small, if you add it to itself enough times, you can exceed any bound.

Think of it this way: a millimeter is tiny, but stack enough millimeters and you'll reach the Moon. A gram is light, but accumulate enough grams and you'll outweigh the Sun. In the real numbers, there is no quantity so small that it remains small when repeated infinitely.

This is precisely what blocks infinitesimal probabilities. If you try to assign some tiny positive probability ε to each natural number 1, 2, 3, ..., then the total probability would be ε + ε + ε + ... = ∞. The Archimedean property guarantees this: no matter how small ε is, repeated addition will eventually blow past any finite bound.

New research has now made this barrier mathematically precise: **in any Archimedean ordered system, for any positive weight ε and any bound b, there exists some finite sum of copies of ε that exceeds b.** This isn't just intuition — it's a theorem with a rigorous proof. And it tells us exactly where to look for a way around the obstacle.

## Beyond the Real: Conway's Surreal Numbers

In the 1970s, the mathematician John Horton Conway invented a number system so vast that it contains not only every real number, but also numbers that are infinitely large — and infinitely small.

Conway called them **surreal numbers**, a name that captures their dreamlike quality. In this system, there exist positive quantities so small that no finite number of copies can sum to 1. These are true infinitesimals — not approximations, not limits, but actual positive numbers that are smaller than every positive real number.

The surreal numbers form a rich algebraic structure: you can add them, compare them, and order them. They satisfy the axioms of an ordered additive group. But crucially, they break the Archimedean property. In the surreal numbers, there exist elements ε where ε, 2ε, 3ε, 1000ε, and even ω·ε (where ω is an infinite number) all remain bounded.

This is the key insight: **the Archimedean property is not a universal law of mathematics. It is a specific property of specific number systems. And those systems that lack it — the non-Archimedean systems — can host a fundamentally different kind of probability theory.**

## A New Kind of Measure

The research introduces what might be called an **infinitesimal probability measure**: a way of assigning weights to sets of outcomes that satisfies the basic laws of probability, but uses infinitesimal values.

The construction is elegant in its simplicity. Given any positive infinitesimal ε in a non-Archimedean ordered group, define the measure of any finite set S to be |S| · ε — the number of elements times the infinitesimal weight. This gives:

- **Every point gets positive probability.** Unlike standard probability, no outcome is "impossible."
- **The measure is finitely additive.** The probability of "A or B" (when A and B are disjoint) equals the probability of A plus the probability of B.
- **The total remains bounded.** Despite assigning positive weight to every point, the sum over any finite collection stays below a fixed bound.

The research proves several key properties of this measure. It is **strictly monotone**: larger sets always have strictly larger measure. It satisfies **partition additivity**: if you split a set into disjoint pieces, the total measure equals the sum of the pieces' measures. And the measure of any non-empty set is strictly positive — there are no "invisible" events.

## The Probability Dichotomy

Perhaps the most striking result is what the researchers call the **Probability Dichotomy**: for any ordered algebraic system, exactly one of two situations holds.

Either the system is Archimedean — in which case uniform infinitesimal probability is provably impossible — or it is non-Archimedean, in which case such measures exist and are well-behaved. There is no middle ground, no partial solution, no system that is "almost" non-Archimedean.

This dichotomy is the mathematical equivalent of a phase transition. Cross the boundary from Archimedean to non-Archimedean, and the entire character of probability theory changes. Properties that seemed fundamental — like "individual points have zero probability" — turn out to be artifacts of working in the wrong number system.

## Beyond Uniform: Weighted Infinitesimal Probability

The framework extends beyond uniform measures. The researchers also construct **weighted infinitesimal measures**, where different outcomes can have different infinitesimal probabilities. A coin that's slightly biased at the infinitesimal level, a die where each face has a different infinitesimal weight — these become mathematically precise objects.

The key theorem here is that any weighted measure with all-positive weights remains strictly positive on non-empty sets. In the language of probability: if no outcome is truly impossible, then no event is truly impossible either.

## Why It Matters

This isn't merely an abstract exercise. The relationship between infinitesimals and probability has deep connections to several active areas of mathematics and science:

**Decision theory and game theory.** In strategic situations with infinitely many options, the standard framework forces us to say that some strategies have "zero probability" of being chosen — even when we want to model an agent that might choose any strategy. Infinitesimal probabilities provide a way to keep all options on the table.

**Foundations of physics.** Quantum mechanics assigns probability amplitudes to outcomes, and some interpretations require dealing with continuous probability distributions. Infinitesimal probability offers an alternative foundation where the probability of each specific quantum state is genuinely positive, not merely "non-zero in a measure-theoretic sense."

**Philosophy of probability.** The assignment of probability zero to possible events has long troubled philosophers. If something *can* happen, shouldn't it have *some* positive probability? The non-Archimedean framework says yes.

## The Road Ahead

The current results establish the foundations: the impossibility theorem, the existence theorem, the dichotomy, and the key structural properties. But they also open doors to deeper questions.

Can the theory be extended to countable additivity? The current framework uses finite additivity — the measure of a finite union of disjoint sets equals the sum of their measures. Extending to countable additivity would require developing a theory of infinite series in non-Archimedean groups, a challenging open problem.

What about integration? Standard probability theory builds on integration with respect to a measure. Developing a theory of integration with infinitesimal measures could lead to new ways of computing expected values and other statistical quantities.

And perhaps most tantalizingly: what happens when these ideas meet the surreal numbers' game-theoretic origins? Conway originally invented surreal numbers to analyze combinatorial games. Probability theory on surreal numbers could bridge the gap between deterministic game theory and probabilistic reasoning, creating a unified framework for strategic decision-making under uncertainty.

The ancient Greeks discovered the Archimedean property. For two millennia, it seemed like an immutable law of quantity. Now we know it's a choice — and making a different choice opens up entirely new mathematics.

---

*This article describes research building on Conway's surreal number theory and connecting to nonstandard analysis. The key results include a formal impossibility theorem for Archimedean probability, an existence theorem for non-Archimedean probability, and a structural dichotomy showing these are the only two possibilities.*
