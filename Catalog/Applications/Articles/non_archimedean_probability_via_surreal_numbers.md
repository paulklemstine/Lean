# The Probability of the Impossible: How Infinitely Small Numbers Rescue Probability Theory

*What if every point on a dartboard had a real, positive probability of being hit — not zero, but a number so small it defies ordinary arithmetic?*

## The Paradox of the Perfect Dart

Imagine throwing a perfectly precise dart at a circular dartboard. Where will it land? Standard probability theory gives a surprising answer: the probability of hitting any specific point — say, dead center — is exactly zero. Not approximately zero. Not really, really small. *Mathematically zero.*

This seems absurd. The dart will land *somewhere*. And wherever it lands, that specific landing spot had probability zero of being chosen. How can something with zero probability actually happen?

For nearly a century, mathematicians have lived with this paradox by accepting it as a feature, not a bug. The Russian mathematician Andrei Kolmogorov laid down the rules of probability in 1933, and his framework — built on real numbers between 0 and 1 — simply doesn't have room for a positive probability at every point on a continuous dartboard. If every point had some tiny positive probability p > 0, and you added up infinitely many copies of p, you'd get infinity. Since the total probability must equal 1, something has to give. The conclusion: individual points must have probability zero.

But what if we changed the number system?

## Numbers Between Zero and Zero

In the 1970s, the brilliant combinatorialist John Conway invented a number system called the *surreal numbers* — a vast landscape of quantities that includes all the familiar real numbers, but also numbers that are infinitely large, and crucially, numbers that are *infinitesimally small*.

An infinitesimal is a positive number that is smaller than 1/2, smaller than 1/100, smaller than 1/1,000,000 — smaller than any positive fraction you can name — and yet still positive. Not zero. A genuine, positive quantity, just unimaginably tiny.

In the real number system, no such number exists. The Archimedean property of the reals guarantees that if you take any positive number, no matter how small, and add it to itself enough times, you'll eventually exceed 1. Infinitesimals violate this principle: add an infinitesimal to itself a billion times, and you're still smaller than 1.

This is not science fiction. These number systems are mathematically rigorous, with well-defined addition, multiplication, and division. They've been studied for decades in a field called *nonstandard analysis*, pioneered by Abraham Robinson in the 1960s. What's new is using them as the foundation for probability theory.

## Every Point Gets a Chance

Here's the key idea: if we allow our probability measure to take values in a non-Archimedean field — a number system with infinitesimals — then we can assign a positive infinitesimal probability ε to every single point on the dartboard.

The paradox dissolves. Why doesn't the sum blow up to infinity? Because ε is infinitesimal. Adding ε to itself a million times gives you a million times ε, which is still infinitesimal — still less than any ordinary positive number. No finite collection of points can accumulate enough probability to reach 1. The probability is distributed uniformly, with each point carrying its tiny share.

This isn't just philosophy. New mathematical research has proven rigorously that such measures satisfy all the standard rules of probability:

- **The complement rule**: The probability of something not happening equals 1 minus the probability of it happening.
- **Monotonicity**: If event A is contained in event B, then A is no more probable than B.
- **Inclusion-exclusion**: The probability of A or B equals P(A) + P(B) minus P(A and B).
- **Sub-additivity**: The probability of A or B is at most P(A) + P(B).

All of these hold exactly, not approximately, in the non-Archimedean setting.

## The Anti-Concentration Theorem

One of the most striking results in this new theory is the **Anti-Concentration Theorem**: in a uniform infinitesimal probability space, the measure of *any finite set* is infinitesimal. 

Think about what this means. You can pick any million points on the dartboard. Their combined probability is still infinitesimally small — nowhere close to 1. The probability is spread so thin that no finite collection of points can capture a meaningful fraction of it. The bulk of the probability lives in the "continuum" — it's an irreducibly infinite phenomenon.

This is proven by a lovely algebraic argument. If each point has weight ε, then n points have weight nε. And a key theorem about infinitesimals shows that multiplying an infinitesimal by any natural number gives another infinitesimal. The proof uses what might be called the "2n trick": to show that nε is small, you observe that 2n·ε is also less than 1 (since ε is infinitesimal for *all* natural multipliers), which means nε < 1/2 — and the same argument with any multiplier shows nε is arbitrarily small.

## Conditioning on the Impossible

Perhaps the most philosophically significant application is to *conditional probability* — the probability of A given that B has happened.

In standard probability, conditional probability is defined as P(A|B) = P(A∩B)/P(B). But this formula breaks down when P(B) = 0, since you can't divide by zero. This is a real problem: in continuous probability, every specific outcome has probability zero, so you can never condition on a specific outcome using the standard formula.

Statisticians work around this with elaborate technical machinery — regular conditional distributions, disintegration theorems, Radon-Nikodym derivatives. These tools work, but they're complex and sometimes unintuitive.

In the non-Archimedean framework, the problem vanishes. Since every singleton {x} has probability ε > 0 (positive, though infinitesimal), you can always divide by it. And the result is elegant: conditioning on the event "the dart lands at point x" gives you exactly the *Dirac delta* at x — probability 1 if x is in your target set, probability 0 if it isn't.

This is called the **Dirac Recovery Theorem**: the infinitesimal framework naturally produces the Dirac delta as an honest conditional distribution, with no limiting arguments or distributional trickery required. What physicists and engineers have been doing informally with delta functions for a century turns out to have a rigorous algebraic foundation.

## The Algebraic Heart

What makes this all work is a surprisingly simple algebraic fact about infinitesimals: they form what mathematicians call an *ideal* in the field. Specifically:

1. Zero is infinitesimal (trivially).
2. The negative of an infinitesimal is infinitesimal.
3. The sum of two infinitesimals is infinitesimal.
4. The product of an infinitesimal with any bounded quantity is infinitesimal.

Property 3 is the subtle one — it requires the "2n trick" mentioned above. But once you have these four properties, the entire theory of infinitesimal probability measures follows as a consequence.

And there's a beautiful boundary result: in the real numbers (or any Archimedean field), the only infinitesimal is zero. This means our new theory reduces to standard probability when the value field is ℝ. Non-Archimedean probability is a genuine extension, not a replacement.

## A Bridge Between Worlds

This research connects several traditionally separate areas of mathematics. It bridges *algebra* (the theory of ordered fields), *probability theory* (measure and conditioning), *set theory* (Conway's surreal numbers), and *mathematical logic* (the Archimedean property and its negation).

It also resonates with a philosophical tradition going back to the Italian mathematician Bruno de Finetti, who argued in the 1970s that *finitely additive* probability is more fundamental than countably additive probability. De Finetti would have been delighted: finite additivity, when paired with an enlarged number system, enables phenomena that countable additivity forbids.

## What's Next

The framework opens several exciting avenues. Can we define *expectation* and *integration* for infinitesimal-valued measures? Can we prove analogues of the law of large numbers? And can the theory shed light on longstanding puzzles in Bayesian epistemology, where philosophers debate whether it's rational to have "uniform priors" over infinite hypothesis spaces?

The mathematics suggests a clear answer: yes, you can have a uniform distribution over infinitely many hypotheses — you just need to allow infinitesimal probabilities. Every hypothesis gets a fair, positive, infinitely small chance. None is favored. None is excluded.

The impossible, it turns out, just needs smaller numbers.
