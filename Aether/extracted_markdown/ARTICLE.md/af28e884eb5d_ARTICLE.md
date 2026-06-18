# The Probability of the Impossible: How Infinitely Small Numbers Rescue a Mathematical Paradox

*What if every point on a dartboard had a real, positive probability of being hit — even though there are infinitely many points?*

## The Dartboard Paradox

Imagine throwing a dart at a circular dartboard. Classical probability tells us something deeply unsettling: every single point on that board has a probability of exactly zero of being hit. Not approximately zero — exactly zero. And yet, the dart *will* hit some point. The total probability must be 1.

This isn't a bug in the mathematics. It's a fundamental consequence of how we measure things with real numbers. If even a single point had a positive probability — say, one in a trillion trillion — then among the uncountably many points on the dartboard, infinitely many copies of that tiny probability would sum to infinity, not 1. The Archimedean property of the real numbers is the culprit: no matter how small a positive real number is, stack enough copies and it eventually exceeds any bound.

For decades, mathematicians accepted this as an inevitable feature of probability theory. But a new line of research asks: what if we used a different number system — one where "infinitely small" numbers actually exist?

## Numbers Beyond Numbers

In the 1970s, the mathematician John Horton Conway discovered a remarkable number system while analyzing combinatorial games. His "surreal numbers" form the largest possible ordered field: they contain all real numbers, but also numbers that are infinitely large (bigger than any integer) and infinitely small (positive, yet smaller than any fraction 1/n).

Conway's number ε = 1/ω, where ω is the first infinite surreal number, is the prototypical infinitesimal. It's positive — genuinely, rigorously greater than zero. But no matter how many copies you stack up (finitely), the sum never reaches 1. Ten copies of ε, a million copies, a googolplex of copies — all still infinitesimal.

This is precisely the property that breaks the dartboard paradox.

## A New Kind of Probability

Recent mathematical research has established that non-Archimedean ordered groups — algebraic structures where infinitesimals exist — can support a genuinely new kind of probability theory. The key results form a coherent picture:

**The Obstruction Theorem.** In any Archimedean number system (like the reals, or the rationals), it is mathematically impossible for a positive element to be infinitesimal relative to any other element. This theorem precisely identifies *why* standard probability forces point masses to zero: the Archimedean property leaves no room for infinitesimals.

**The Convexity Theorem.** In a non-Archimedean system, infinitesimals form a "convex cone": anything smaller than an infinitesimal (but still positive) is itself infinitesimal. This means infinitesimals aren't isolated curiosities — they form a robust, structurally rich collection.

**The Summation Bound.** The sum of finitely many infinitesimals remains controlled. If you add up n infinitesimals, each bounded by some unit u, the sum is bounded by n · u. For any fixed finite collection, the total stays infinitesimal. This is the mathematical guarantee that assigning infinitesimal probability to each of finitely many points produces a well-behaved total.

**The Anti-Cancellation Principle.** Perhaps most surprisingly, these infinitesimal measures inherit a deep structural property from an entirely different area of mathematics — the theory of Lorentzian polynomials. When all point masses share the same sign (as probabilities must), no accidental cancellation can occur. The total mass is strictly positive whenever at least one point carries positive mass. This connects probability theory to algebraic geometry in an unexpected way.

## The Discrimination Theorem

One of the most elegant consequences is what researchers call the "discrimination theorem." A uniform infinitesimal measure — one that assigns the same infinitesimal mass ε to every point — can distinguish between sets of different sizes in a way that classical probability cannot.

In standard probability on a continuous space, a singleton {x} and a pair {x, y} both have measure zero. They're indistinguishable. But with infinitesimal probability, {x} has measure ε while {x, y} has measure 2ε. These are genuinely different numbers in the surreal system. Every set of distinct cardinality receives a distinct measure.

This means infinitesimal probability doesn't just rescue the dartboard paradox — it provides *more* information than classical probability, not less. The price of admission is accepting a number system richer than the reals.

## Finite Additivity: The Working Engine

The practical engine of this new probability theory is finite additivity. If two events A and B cannot occur simultaneously (they're "disjoint"), then the probability of A-or-B equals the probability of A plus the probability of B. This ancient principle, dating back to the earliest formulations of probability, works perfectly with infinitesimal values.

The complementation identity holds as well: the probability of an event plus the probability of its complement equals the total probability mass. These aren't surprising theorems in themselves, but their verification in the surreal-valued setting demonstrates that the entire classical framework of finite probability theory transfers seamlessly to the infinitesimal world.

## The Bridge to Lorentzian Geometry

The most unexpected connection in this research is the bridge to Lorentzian polynomial theory. Lorentzian polynomials, studied by Petter Brändén and June Huh in work that contributed to Huh's 2022 Fields Medal, exhibit a remarkable "anti-cancellation" property: when weighted sums of derivatives all carry the same sign, no accidental zeroes can appear.

The anti-cancellation theorem for infinitesimal measures is the same phenomenon in a completely different setting. Positive point masses — whether real-valued or infinitesimal — cannot cancel each other out through summation. The structural reason is identical in both cases: sign coherence prevents destructive interference.

This cross-domain bridge suggests that anti-cancellation is not a peculiarity of polynomials or of measures, but a deep structural principle that manifests wherever signed quantities interact additively. Understanding this principle could illuminate both algebraic geometry and probability theory simultaneously.

## What This Means

The mathematical results established here don't claim that surreal-valued probability should replace standard probability theory. The Kolmogorov axioms, with their real-valued σ-additive measures, remain the workhorse of statistics, physics, and engineering.

But they reveal something about the *structure* of probability itself. The impossibility of positive point masses in ℝ is not a theorem about probability — it's a theorem about the Archimedean property of the real numbers. Change the number system, and the impossibility evaporates.

This has philosophical implications for how we think about events with probability zero. In standard theory, "probability zero" doesn't mean "impossible" — only "measure zero." But this distinction has always felt unsatisfying. With infinitesimal probability, we can make the distinction precise: a truly impossible event has probability exactly 0, while a possible-but-infinitely-unlikely event has probability ε > 0.

## The Road Ahead

Several tantalizing questions remain open. Can this theory extend to countably infinite or even uncountable collections? The current results handle finite sets rigorously, but the dartboard has uncountably many points. Does the framework generalize to σ-additivity (countable unions), or does the non-Archimedean setting fundamentally require only finite additivity?

There's also the question of conditional probability. If P(A) = ε and P(B) = ε², what is P(A|B)? In the surreal numbers, this quotient is well-defined — it equals ε/ε² = 1/ε = ω, an infinite number. This suggests that conditional probabilities in the infinitesimal world might naturally take infinite values, connecting to ideas in Bayesian reasoning about "improper priors."

Finally, the bridge to Lorentzian polynomials hints at deeper connections waiting to be discovered. If anti-cancellation is truly a universal principle, it should manifest in quantum mechanics, information theory, and combinatorics. Each such manifestation would be a new chapter in a story that begins with a simple question: what is the probability that a dart hits *this* exact point?

The answer, it turns out, depends on what kind of numbers you believe in.

---

*This article describes research in non-Archimedean probability theory, building on Conway's surreal numbers and connecting to the Lorentzian polynomial theory of Brändén and Huh. The mathematical results are fully verified using computer-checked proofs.*
