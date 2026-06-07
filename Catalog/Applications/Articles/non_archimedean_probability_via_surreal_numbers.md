# The Lottery of Infinity: How Mathematicians Tamed Impossible Probabilities

## The Paradox That Haunted Probability Theory

Imagine an infinite lottery — a cosmic raffle where every positive integer gets a ticket. What's the probability that ticket #7 wins? In a fair lottery, every ticket should have an equal chance. But here's the paradox: if each ticket has probability zero, then even a million tickets combined have probability zero. And if each ticket has any positive probability, no matter how small — say, one in a trillion — then adding up infinitely many of those gives infinity, not one.

This isn't a puzzle for amateurs. It's a fundamental tension at the heart of probability theory that has troubled mathematicians since Émile Borel and Andrei Kolmogorov laid the foundations of modern probability in the early twentieth century. Their solution was elegant but unsatisfying: simply decree that individual points can have probability zero and build the entire theory around sets rather than points.

For most of mathematics, this works brilliantly. But it leaves a philosophical scar. When we say "pick a random real number between 0 and 1," every specific number has probability zero. The number 0.5 is, in this technical sense, *impossible* — yet clearly someone could draw it. The framework treats the possible as if it were impossible.

## A Number System Beyond the Real

The resolution comes from an unexpected direction: a number system invented by mathematician John Horton Conway while studying games. In the 1970s, Conway discovered the *surreal numbers* — an extraordinarily vast number system that contains not only every real number and every infinite ordinal, but also infinitesimal quantities: numbers that are positive yet smaller than any fraction 1/n.

Think of an infinitesimal ε as a number so small that no matter how many copies you add together — a million, a billion, a googol — the sum never reaches even 1/1000. In the real numbers, no such positive quantity exists. That's the *Archimedean property*: for any positive real number, stack enough copies and you'll eventually exceed any target. But surreal numbers break this barrier. They contain infinitesimals by design.

This immediately suggests a tantalizing possibility: what if we used infinitesimals as probabilities?

## Building the Impossible

The new research establishes that this intuition can be made mathematically rigorous. The key construction is breathtakingly simple: in a non-Archimedean ordered field (a number system containing infinitesimals), assign probability ε to each element, where ε is infinitesimal.

The first surprise is that this works at all. The measure μ(A) = |A| · ε, where |A| counts the elements in set A, satisfies the most fundamental law of probability: *finite additivity*. If two events can't happen simultaneously, the probability of either occurring equals the sum of their individual probabilities. Mathematically: μ(A ∪ B) = μ(A) + μ(B) when A and B don't overlap.

The second surprise is normalization. For any finite space with n elements, setting ε = 1/n gives a probability measure where the total probability is exactly 1 — not approximately 1, not infinitely close to 1, but precisely 1. The infinitesimals are calibrated perfectly.

The third surprise — and the deepest — is that conditional probability becomes trivially well-defined. In standard probability, computing P(A | B) = P(A ∩ B) / P(B) breaks down when B is a single point, because P({x}) = 0 and you can't divide by zero. Entire branches of measure theory — regular conditional distributions, disintegration theorems — exist to work around this limitation. With infinitesimal probability, P({x}) = ε > 0, and the division goes through cleanly. Moreover, the infinitesimals cancel: P(A | B) reduces to the classical counting formula |A ∩ B| / |B|.

## The Archimedean Boundary

Perhaps the most illuminating result is what the research calls the *infinitesimal dichotomy*: an ordered field permits infinitesimal probability measures if and only if it violates the Archimedean property. This is not merely a technical observation — it's a sharp characterization of where standard probability fails and infinitesimal probability begins.

The real numbers are Archimedean: every positive real exceeds some 1/n. The surreal numbers are not. The boundary between these two worlds is precisely the boundary between "individual points must have probability zero" and "individual points can have genuinely positive, infinitesimal probability."

This dichotomy theorem connects probability to deep questions in algebra and logic. The existence of non-Archimedean ordered fields is guaranteed by the compactness theorem of first-order logic — the same theorem that undergirds Abraham Robinson's nonstandard analysis. Infinitesimal probability, it turns out, is not an exotic curiosity but an inevitable consequence of mathematical logic.

## Why Infinitesimals Don't Cancel

There's a subtle algebraic principle at work beneath the surface. When you add positive quantities — even infinitesimal ones — in an ordered field, the sum remains positive. Ten infinitesimals are bigger than one infinitesimal. A billion infinitesimals are bigger still. This *anti-cancellation* property, proved rigorously in the research, is what prevents the measure from collapsing. It's the algebraic engine that makes infinitesimal probability coherent.

In the real numbers, this property holds too, but it's useless for probability because there are no infinitesimals to work with. The combination of anti-cancellation *with* the existence of infinitesimals is what makes non-Archimedean probability possible. It's a beautiful interplay between algebra and analysis.

## Conditioning on the Impossible

The philosophical implications are striking. In Bayesian reasoning, we constantly want to condition on specific observations: "Given that the temperature is exactly 72.3°F, what's the probability of rain?" Standard probability theory handles this through limiting arguments, density functions, and regularity conditions — a tower of technical apparatus built to avoid dividing by zero.

Infinitesimal probability dissolves the problem. Every observation, no matter how specific, has positive (infinitesimal) probability. Bayes' theorem applies directly. The apparatus of regular conditional probabilities becomes unnecessary — or rather, it's revealed as a real-valued approximation to a cleaner non-Archimedean truth.

This resonates with work by philosophers Sylvia Wenmackers and Leon Horsten on "fair infinite lotteries," and with Vieri Benci and Mauro Di Nasso's theory of numerosities. The current research puts these ideas on firm algebraic footing, showing that the key properties — additivity, normalization, positivity, and the counting formula for conditional probability — all hold exactly, not approximately.

## The Road Ahead

The framework opens several avenues. Can infinitesimal probability be extended from finite additivity to a suitable form of infinite additivity? The answer is delicate: standard countable additivity fails (it would force the probabilities to be zero, bringing us back to square one), but there may be weaker forms of infinite additivity compatible with infinitesimals.

Another direction is integration theory. If we can define an integral with respect to infinitesimal measures, we might recover expectation values that are infinitely close to the standard ones but carry more information. This could have applications in decision theory, where the difference between probability zero and probability ε might matter — for instance, in Pascal's Wager or in reasoning about extremely unlikely catastrophic risks.

Perhaps most exciting is the connection to game theory. Conway's surreal numbers arose from the study of combinatorial games, and probability theory in the surreal numbers could lead to a unified framework for games of chance — where the strategic structure of a game and the probabilistic structure of its uncertainty live in the same mathematical universe.

The impossible lottery now has a resolution. Every ticket gets a positive probability. The total is exactly one. And the mathematics, far from being a parlor trick, reveals a deep truth: the Archimedean property is not a law of nature but a choice, and choosing differently opens a richer world of probability.

---

*This article describes research extending classical probability theory into non-Archimedean ordered fields, building on Conway's surreal numbers and connecting algebraic anti-cancellation principles to measure theory.*
