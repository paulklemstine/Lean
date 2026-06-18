# The Probability of the Impossible: How Infinitesimal Numbers Reshape Chance

*What if events with "zero probability" aren't really zero at all?*

---

Every time you throw a dart at a dartboard, something mathematically impossible happens. The dart hits a specific point — say, exactly 7.3 centimeters from the center — but the probability of hitting that exact point is, according to standard probability theory, precisely zero. Not approximately zero. Not very small. *Exactly* zero, the same probability as an event that truly cannot occur.

This isn't a paradox that mathematicians haven't noticed. It's a feature of the framework, built into the foundations by Andrey Kolmogorov in 1933. When you deal with continuous probability — the kind that governs everything from particle physics to stock prices — every single outcome individually has probability zero. Only collections of outcomes can have positive probability.

For decades, this was considered an acceptable quirk. But a team of mathematical researchers has now shown that there's a rigorous alternative: probability measures that assign every point a probability that is positive, well-defined, and adds up correctly — by using numbers smaller than any fraction, yet greater than zero.

## Beyond Real Numbers

The key lies in an extraordinary number system discovered by mathematician John Conway in the 1970s. Conway was studying mathematical games — two-player combinatorial games like Go and Chess — and realized that the positions in these games formed a number system far richer than the familiar real numbers. He called them *surreal numbers*.

Surreal numbers contain all the real numbers, but also contain infinitesimals — quantities that are positive yet smaller than 1/2, smaller than 1/1000, smaller than 1/googol, smaller than any positive fraction you could name. They also contain infinite numbers larger than any integer. The surreals form a complete, consistent mathematical universe where arithmetic works perfectly.

The question the research team posed was direct: can we build probability theory in this expanded universe?

## A Tale of Two Impossibilities

The answer turned out to be more subtle and more revealing than anyone expected. The team discovered not one result but two complementary impossibility theorems, and sandwiched between them, a construction that actually works.

**The first impossibility** is familiar: in the ordinary real numbers, there simply are no infinitesimals. This is the Archimedean property — for any positive real number, no matter how small, you can add it to itself enough times to exceed any bound. The team proved this rigorously: the reals contain no element that is positive yet smaller than every fraction.

**The second impossibility** is the surprise. Even if you move to a number system that *does* have infinitesimals — like the surreals — you still can't assign uniform infinitesimal probability to each natural number 1, 2, 3, ... and have the total come out to 1. The reason is elegant: if ε is infinitesimal, then ε < 1/(n+1) for every natural number n, which means the sum of ε over any finite collection of n numbers is less than n/(n+1), which is always less than 1. The partial sums are forever trapped below 1, never reaching it.

This is the **dual impossibility theorem**: in Archimedean fields, every positive number is too large to be a point probability (sums blow up); in non-Archimedean fields, infinitesimals are too small (sums can't reach 1). The countably infinite case is impossible from both directions.

## The Sweet Spot: Finite Worlds

Between these impossibilities lies fertile ground. For *finite* sample spaces — a die with six faces, a deck of 52 cards, a quantum system with finitely many states — surreal probability works beautifully. The team constructed what they call *infinitesimally perturbed measures*: you start with the uniform probability (1/6 for each face of a die, say) and add a tiny infinitesimal correction to each face, calibrated so the corrections sum to zero.

The result is a probability measure that sums to exactly 1, assigns a positive probability to each outcome, and — here's the crucial point — *distinguishes every single outcome with a unique probability*. In standard probability, a fair die assigns 1/6 to each face identically. You can't tell the faces apart from their probabilities alone. With infinitesimal perturbation, face 1 might get probability 1/6 + ε, face 2 gets 1/6 + 2ε, face 3 gets 1/6 - 3ε, and so on. Every face has a distinct probability fingerprint.

## Discrimination and Information

This ability to discriminate is not just a mathematical curiosity. The team formalized an *information ordering* on probability measures: measure μ is "more informative" than measure ν if every probability distinction that ν makes, μ also makes, plus at least one more. They proved that the uniform measure is the *least informative* possible measure — it distinguishes nothing — and that any infinitesimally perturbed measure is strictly more informative.

This has a philosophical interpretation that reaches beyond mathematics. In Bayesian statistics, you often need to express a "prior" belief before seeing data. The standard uniform prior says "I treat all outcomes equally." But an infinitesimally perturbed prior says "I treat all outcomes *almost* equally, but I have the structural capacity to distinguish them if I need to." It's the difference between knowing nothing and knowing almost nothing — and that "almost" carries genuine mathematical content.

## Conditional Probability Without Division by Zero

Perhaps the most practically significant result concerns conditional probability. In standard probability, if you want to compute the probability of event A given that event B occurred, you use Bayes' theorem: P(A|B) = P(A∩B)/P(B). But this formula divides by P(B), and if P(B) = 0, the conditional probability is undefined.

This is not a theoretical concern. In continuous probability, *every specific observation* has probability zero. If you observe that a particle is at exactly position x, and you want to update your beliefs, you're dividing by zero. Practitioners work around this using limit arguments and density functions, but the workarounds are mathematically unsatisfying.

With surreal probability on finite approximations, the problem evaporates. Every event has positive (at least infinitesimal) probability, so Bayes' theorem always works. The team proved that their conditional probability construction is well-defined and sums to 1, with no restrictions on which events you can condition on.

## Products and Independence

The researchers also showed that surreal probability measures compose correctly under products. If you have a surreal probability on dice faces and another on coin flips, the product measure on (face, flip) pairs is a valid surreal probability measure. The product of two well-behaved surreal measures is well-behaved. This means the framework handles independent events, joint distributions, and all the other machinery of probability theory.

## What Comes Next

The dual impossibility theorem points toward deep questions. The finite-only restriction means surreal probability is not a replacement for standard measure-theoretic probability — it's a complement, offering fine-grained discrimination in finite settings where standard probability is too coarse.

The most intriguing open direction connects to game theory. Conway's surreal numbers were born from games, and probability is the language of strategic decision-making under uncertainty. A theory that combines surreal games with surreal probability could yield a framework where infinitesimal strategic advantages — too small to detect with real-valued analysis — become mathematically tractable.

There are also connections to physics. Some interpretations of quantum mechanics assign probabilities to individual quantum states. If those probabilities could be infinitesimally different, they might encode additional information about the system's history or structure — information that real-valued probabilities, constrained to the Archimedean world, simply cannot express.

The mathematics of the infinitely small has always had a contentious history, from Leibniz's controversial infinitesimals through Robinson's nonstandard analysis to Conway's surreals. This new work suggests that infinitesimals aren't just a curiosity or a philosophical stance — they're a tool that solves genuine mathematical problems, in this case the ancient puzzle of probability zero events that somehow still happen.

Every time you throw that dart, something impossible happens. Perhaps it's time our mathematics learned to measure the impossible.
